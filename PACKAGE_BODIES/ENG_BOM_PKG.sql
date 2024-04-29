--------------------------------------------------------
--  DDL for Package Body ENG_BOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_BOM_PKG" AS
/* $Header: ENGPBTRB.pls 120.6.12010000.4 2010/08/03 20:28:45 umajumde ship $ */

  /***************************************************************************
  * Function : Get_GTIN_Structure_Type_Id
  * Returns : StructureTypeId of 'Packaging Hierarchy' / NULL
  * Parameters IN : None
  * Parameters OUT: None
  * Purpose : To get the structure type id of 'Packaging Hierarchy' if available
  *****************************************************************************/
  FUNCTION Get_GTIN_Structure_Type_Id RETURN NUMBER
  IS
    l_GTIN_Id NUMBER;
  BEGIN
    SELECT Structure_Type_Id
      INTO l_GTIN_Id
        FROM bom_structure_types_vl
    WHERE Structure_Type_Name ='Packaging Hierarchy';

    RETURN l_GTIN_Id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        Return NULL;
  END Get_GTIN_Structure_Type_Id;

-- +------------------------------ BOM_UPDATE --------------------------------+
-- NAME
-- BOM_UPDATE

-- DESCRIPTION
-- Update Bills: Flip assembly_type to 1 (manufacturing)

-- REQUIRES
-- org_id: organization id
-- eng_item_id: bill that requires assembly_type to bee set to 1
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE BOM_UPDATE
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_implemented_only		IN NUMBER,
X_unit_number			IN VARCHAR2 DEFAULT NULL
)
IS
  X_stmt_num	NUMBER;
  X_GTIN_ST_TYPE_ID NUMBER;

  --BOM ER 9946990 begin
  l_parent_BIT NUMBER;
  l_PTO_flag varchar2(1);
  ATO_IN_KIT_EXCEPTION EXCEPTION;
  ATO_IN_MODEL_EXCEPTION EXCEPTION;

  cursor all_bills(X_org_id number, X_eng_item_id number, X_designator_option number , X_alt_bom_designator varchar2) is
  select bill_sequence_id from bom_structures_b
       WHERE ORGANIZATION_ID = X_org_id
       AND ASSEMBLY_ITEM_ID = X_eng_item_id
       AND ((X_designator_option = 2 AND
	   ALTERNATE_BOM_DESIGNATOR IS NULL)
        OR
        (X_designator_option = 3 AND
         ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
        OR
         X_designator_option = 1)
       AND nvl(effectivity_control , 1) <> 4;



   cursor comp_rows(bill_id IN NUMBER) is
   select msib.bom_item_type, msib.replenish_to_order_flag, bcb.optional
   from bom_components_b bcb, mtl_system_items_b msib
   where bcb.bill_sequence_id = bill_id
   and msib.inventory_item_id = bcb.component_item_id
   and msib.organization_id = bcb.pk2_value;

   --BOM ER 9946990 end
BEGIN

     --BOM ER 9946990 begin
    X_stmt_num := 350;

select msib.bom_item_type, msib.pick_components_flag into l_parent_BIT, l_PTO_flag from mtl_system_items_b msib where inventory_item_id = X_eng_item_id and organization_id = X_org_id;

for bill in  all_bills(X_org_id, X_eng_item_id, X_designator_option, X_alt_bom_designator)
    loop

	for comp in comp_rows(bill.bill_sequence_id)
        loop
	if l_parent_BIT = 4 and l_PTO_flag = 'Y'
          and comp.bom_item_type = 4 and comp.replenish_to_order_flag = 'Y'
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
	 then
        raise ATO_IN_KIT_EXCEPTION;
     end if;


     if l_parent_BIT = 1 and l_PTO_flag = 'Y'
          and comp.bom_item_type = 4 and comp.replenish_to_order_flag = 'Y' and nvl(comp.optional, 1) = 2
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
	 then
        raise ATO_IN_MODEL_EXCEPTION;
     end if;

    end loop;

end loop;

 --BOM ER 9946990 end

  X_stmt_num := 400;

  X_GTIN_ST_TYPE_ID := Get_GTIN_Structure_Type_Id;

  UPDATE BOM_BILL_OF_MATERIALS
  SET ASSEMBLY_TYPE = 1,
      LAST_UPDATE_DATE = sysdate,
      LAST_UPDATED_BY = to_number(fnd_profile.value('USER_ID'))
  WHERE ORGANIZATION_ID = X_org_id
  AND ASSEMBLY_ITEM_ID = X_eng_item_id
  AND ((X_designator_option = 2 AND
        ALTERNATE_BOM_DESIGNATOR IS NULL)
       OR
       (X_designator_option = 3 AND
        ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
       OR
       X_designator_option = 1)
  AND nvl(effectivity_control , 1) <> 4 -- Bug 4210718
  AND ((X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
      OR STRUCTURE_TYPE_ID IS NULL); --added for bug 9436790
  UPDATE BOM_EXPLOSIONS_ALL   -- Update Sql added for bug#9260472
     SET ASSEMBLY_TYPE = 1,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATED_BY = to_number(fnd_profile.value('USER_ID'))
   WHERE ORGANIZATION_ID   = X_org_id
     AND COMPONENT_ITEM_ID = X_eng_item_id
     AND ((X_designator_option = 2 AND
           ALTERNATE_BOM_DESIGNATOR IS NULL)
         OR
         (X_designator_option = 3 AND
           ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
         OR
          X_designator_option = 1)
  AND nvl(effectivity_control , 1) <> 4
  AND ((X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
      OR STRUCTURE_TYPE_ID IS NULL); --added for bug 9436790

  X_stmt_num := 401;
  If (PJM_UNIT_EFF.Enabled = 'Y' AND
      PJM_UNIT_EFF.Unit_Effective_Item(
         X_Item_ID => X_eng_item_id,
         X_Organization_ID => X_org_id) = 'Y')
  THEN
    DELETE FROM BOM_INVENTORY_COMPONENTS BIC
    WHERE ((X_implemented_only = 1 AND BIC.IMPLEMENTATION_DATE IS NULL)
      OR (X_transfer_option = 2 AND
           (BIC.FROM_END_ITEM_UNIT_NUMBER > X_unit_number
            OR (BIC.FROM_END_ITEM_UNIT_NUMBER < X_unit_number
		AND NVL(BIC.TO_END_ITEM_UNIT_NUMBER, X_unit_number)
              < X_unit_number)))
      OR (X_transfer_option = 3 AND
	   NVL(BIC.TO_END_ITEM_UNIT_NUMBER, X_unit_number) < X_unit_number))
    AND BIC.BILL_SEQUENCE_ID in  (SELECT BOM_T.BILL_SEQUENCE_ID
              FROM BOM_BILL_OF_MATERIALS BOM_T
              WHERE ORGANIZATION_ID = X_org_id
              AND ASSEMBLY_ITEM_ID = X_eng_item_id
              AND ASSEMBLY_TYPE = 1
              AND ((X_designator_option = 2 AND ALTERNATE_BOM_DESIGNATOR IS NULL)
                OR (X_designator_option = 3 AND ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
                OR (X_designator_option = 1))
              AND (X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
              AND nvl(BOM_T.effectivity_control , 1) <> 4 -- Bug 4210718
              );
  ELSE
    DELETE FROM BOM_INVENTORY_COMPONENTS BIC
    WHERE ((X_implemented_only = 1 AND BIC.IMPLEMENTATION_DATE IS NULL)
      OR (X_transfer_option = 2 AND
           (BIC.EFFECTIVITY_DATE > X_effectivity_date
            OR NVL(BIC.DISABLE_DATE, X_effectivity_date + 1)
              <= X_effectivity_date))
      OR (X_transfer_option = 3 AND NVL(BIC.DISABLE_DATE, X_effectivity_date +
		 1) <= X_effectivity_date))
    AND BIC.BILL_SEQUENCE_ID in  (SELECT BOM_T.BILL_SEQUENCE_ID
              FROM BOM_BILL_OF_MATERIALS BOM_T
              WHERE ORGANIZATION_ID = X_org_id
              AND ASSEMBLY_ITEM_ID = X_eng_item_id
              AND ASSEMBLY_TYPE = 1
              AND ((X_designator_option = 2 AND ALTERNATE_BOM_DESIGNATOR IS NULL)
                OR (X_designator_option = 3 AND ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
                OR (X_designator_option = 1))
              AND (X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
              AND nvl(BOM_T.effectivity_control , 1) <> 4 -- Bug 4210718
              );
  END IF;
EXCEPTION
  --BOM ER 9946990 begin
   WHEN ATO_IN_KIT_EXCEPTION THEN
	rollback;
     	FND_MESSAGE.SET_NAME('BOM', 'BOM_KIT_COMP_PRF_NOT_SET');
    	APP_EXCEPTION.RAISE_EXCEPTION;


   WHEN ATO_IN_MODEL_EXCEPTION THEN
	rollback;
     	FND_MESSAGE.SET_NAME('BOM', 'BOM_MODEL_COMP_PRF_NOT_SET');
    	APP_EXCEPTION.RAISE_EXCEPTION;

  --BOM ER 9946990 end

  WHEN OTHERS THEN
    ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'BOM_UPDATE',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);

END BOM_UPDATE;

-- +--------------------------- BOM_TRANSFER -----------------------------+
-- NAME
-- BOM_TRANSFER

-- DESCRIPTION
-- Transfer Bills

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- mfg_item_id
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- transfer option
--   1. all rows
--   2. current only
--   3. current and pending
-- alt_bom_designator
-- effectivity_date
-- last_login_id not used internally
-- ecn_name

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE BOM_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_transfer_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2,
X_effectivity_date		IN DATE,
X_last_login_id			IN NUMBER,
X_ecn_name			IN VARCHAR2,
X_unit_number			IN VARCHAR2 DEFAULT NULL
)
IS
  X_stmt_num			NUMBER;
  X_from_bill_sequence_id	NUMBER;
  X_GTIN_ST_TYPE_ID NUMBER;
  FLAG NUMBER;

  l_parent_BIT NUMBER;
  l_PTO_flag varchar2(1);
  ATO_IN_KIT_EXCEPTION EXCEPTION;
  ATO_IN_MODEL_EXCEPTION EXCEPTION;


  cursor all_bills(X_org_id number, X_eng_item_id number,
                 X_designator_option number, X_alt_bom_designator varchar2) is
  select bill_sequence_id from bom_structures_b
       WHERE ORGANIZATION_ID = X_org_id
       AND ASSEMBLY_ITEM_ID = X_eng_item_id
       AND ((X_designator_option = 2 AND
	   ALTERNATE_BOM_DESIGNATOR IS NULL)
        OR
        (X_designator_option = 3 AND
         ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
        OR
         X_designator_option = 1)
       AND nvl(effectivity_control , 1) <> 4;



cursor comp_rows(bill_id IN NUMBER) is
select msib.bom_item_type, msib.replenish_to_order_flag, bcb.optional
from bom_components_b bcb, mtl_system_items_b msib
where bcb.bill_sequence_id = bill_id
and msib.inventory_item_id = bcb.component_item_id
and msib.organization_id = bcb.pk2_value;

--BOM ER 9946990 end

  CURSOR BOM_CURSOR IS
    SELECT BILL_SEQUENCE_ID, ALTERNATE_BOM_DESIGNATOR
    FROM BOM_BILL_OF_MATERIALS
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_mfg_item_id
    AND nvl(effectivity_control, 1) <> 4 -- Bug 4210718
    AND Source_BILL_SEQUENCE_ID = BILL_SEQUENCE_ID; --R12

  -- BUG 3503220
  CURSOR BOM_COPIES IS
    SELECT BILL_SEQUENCE_ID, ALTERNATE_BOM_DESIGNATOR, assembly_item_id, organization_id, obj_name
    FROM BOM_BILL_OF_MATERIALS BOM_T
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_mfg_item_id
    AND nvl(BOM_T.effectivity_control, 1) <> 4 -- Bug 4210718
    AND ((X_designator_option = 2 AND
          BOM_T.ALTERNATE_BOM_DESIGNATOR IS NULL)
         OR
         (X_designator_option = 3 AND
          BOM_T.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
         OR
         (X_designator_option = 1));

BEGIN

 --BOM ER 9946990 begin

  X_stmt_num := 650;

BEGIN

select msib.bom_item_type, msib.pick_components_flag into l_parent_BIT, l_PTO_flag
from mtl_system_items_b msib where inventory_item_id = X_eng_item_id and organization_id = X_org_id;

for bill in  all_bills(X_org_id, X_eng_item_id,
                 X_designator_option, X_alt_bom_designator) loop

	for comp in comp_rows(bill.bill_sequence_id) loop
	if l_parent_BIT = 4 and l_PTO_flag = 'Y'
          and comp.bom_item_type = 4 and comp.replenish_to_order_flag = 'Y'
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
	 then
        raise ATO_IN_KIT_EXCEPTION;
     end if;


     if l_parent_BIT = 1 and l_PTO_flag = 'Y'
          and comp.bom_item_type = 4 and comp.replenish_to_order_flag = 'Y' and nvl(comp.optional, 1) = 2
          and nvl(FND_PROFILE.value('BOM:MANDATORY_ATO_IN_PTO'), 2) <> 1
	 then
        raise ATO_IN_MODEL_EXCEPTION;
     end if;

    end loop;

end loop;

EXCEPTION


  WHEN ATO_IN_KIT_EXCEPTION THEN
	rollback;
     	FND_MESSAGE.SET_NAME('BOM', 'BOM_KIT_COMP_PRF_NOT_SET');
    	APP_EXCEPTION.RAISE_EXCEPTION;


  WHEN ATO_IN_MODEL_EXCEPTION THEN
	rollback;
     	FND_MESSAGE.SET_NAME('BOM', 'BOM_MODEL_COMP_PRF_NOT_SET');
    	APP_EXCEPTION.RAISE_EXCEPTION;



WHEN OTHERS THEN
    ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'COMPONENT_TRANSFER',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);

END;


--BOM ER 9946990 end

  --- BOM_BILL_OF_MATERIALS

  X_stmt_num := 700;


  BEGIN

	X_GTIN_ST_TYPE_ID := Get_GTIN_Structure_Type_Id;

	-- Bug 3503263  While Specific Alternate of a Bill is being copied then Primary bill of Target Item is creaed.
	IF (x_eng_item_id<>x_mfg_item_id)and (x_designator_option = 3) then
		FLAG := 1;
	ELSE
		FLAG:= 0;
	END IF;
	-- Bug 3523263 Bug 4240131 inserted effectivity_control in table.
    INSERT INTO BOM_BILL_OF_MATERIALS(
      ASSEMBLY_ITEM_ID,
      ORGANIZATION_ID,
      ALTERNATE_BOM_DESIGNATOR,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      COMMON_ASSEMBLY_ITEM_ID,
      SPECIFIC_ASSEMBLY_COMMENT,
      PENDING_FROM_ECN,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ASSEMBLY_TYPE,
      BILL_SEQUENCE_ID,
      COMMON_BILL_SEQUENCE_ID,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      COMMON_ORGANIZATION_ID,
      NEXT_EXPLODE_DATE,
      EFFECTIVITY_CONTROL,
      source_bill_sequence_id, --R12
      pk1_value, --Bug 4707618
      pk2_value) --Bug 4707618
    SELECT
      X_mfg_item_id,
      ORGANIZATION_ID,
      BOM_T.ALTERNATE_BOM_DESIGNATOR,
      SYSDATE,
      to_number(Fnd_Profile.Value('USER_ID')),
      SYSDATE,
      to_number(Fnd_Profile.Value('USER_ID')),
      to_number(Fnd_Profile.Value('LOGIN_ID')),
      BOM_T.COMMON_ASSEMBLY_ITEM_ID,
      BOM_T.SPECIFIC_ASSEMBLY_COMMENT,
      BOM_T.PENDING_FROM_ECN,
      BOM_T.ATTRIBUTE_CATEGORY,
      BOM_T.ATTRIBUTE1,
      BOM_T.ATTRIBUTE2,
      BOM_T.ATTRIBUTE3,
      BOM_T.ATTRIBUTE4,
      BOM_T.ATTRIBUTE5,
      BOM_T.ATTRIBUTE6,
      BOM_T.ATTRIBUTE7,
      BOM_T.ATTRIBUTE8,
      BOM_T.ATTRIBUTE9,
      BOM_T.ATTRIBUTE10,
      BOM_T.ATTRIBUTE11,
      BOM_T.ATTRIBUTE12,
      BOM_T.ATTRIBUTE13,
      BOM_T.ATTRIBUTE14,
      BOM_T.ATTRIBUTE15,
      1,
      BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
      DECODE(BOM_T.COMMON_BILL_SEQUENCE_ID,BOM_T.BILL_SEQUENCE_ID,BOM_INVENTORY_COMPONENTS_S.CURRVAL,BOM_T.COMMON_BILL_SEQUENCE_ID),
      BOM_T.REQUEST_ID,
      BOM_T.PROGRAM_APPLICATION_ID,
      BOM_T.PROGRAM_ID,
      BOM_T.PROGRAM_UPDATE_DATE,
      BOM_T.COMMON_ORGANIZATION_ID,
      BOM_T.NEXT_EXPLODE_DATE,
      BOM_T.EFFECTIVITY_CONTROL,
      DECODE(BOM_T.COMMON_BILL_SEQUENCE_ID,BOM_T.BILL_SEQUENCE_ID,BOM_INVENTORY_COMPONENTS_S.CURRVAL,BOM_T.COMMON_BILL_SEQUENCE_ID),
      X_mfg_item_id,
      ORGANIZATION_ID
    FROM BOM_BILL_OF_MATERIALS BOM_T
    WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_eng_item_id
    AND ((X_designator_option = 2 AND
          BOM_T.ALTERNATE_BOM_DESIGNATOR IS NULL)
         OR
         (X_designator_option = 3 AND
          BOM_T.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
         OR
         (X_designator_option = 1))
    AND nvl(BOM_T.effectivity_control , 1) <> 4 -- Bug 4210718
    AND (X_GTIN_ST_TYPE_ID IS NULL or BOM_T.STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID);


  EXCEPTION

    WHEN OTHERS THEN
      ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'BOM_TRANSFER',
                                           stmt_num => X_stmt_num,
                                           message_name => 'ENG_ENUBRT_ERROR',
                                           token => SQLERRM);
  END;
  -- bug 3780577 : odaboval moved the ERES call after the LOOP
  --               in order to see the inventory components:
  /* THIS ERES CALL IS NOT MOVED TO A PLACE BELOW.
  -- ERES BEGIN
  -- If there is a parent eRecord, log a child record to accompany it
  -- ================================================================
  IF ENG_BOM_RTG_TRANSFER_PKG.G_PARENT_ERECORD_ID is NOT NULL THEN
    FOR BILL IN BOM_COPIES LOOP                                        -- BUG 3503220
      -- Log an erecord for each new bill inserted above               -- BUG 3503220

      ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord
      ( p_event_name       =>'oracle.apps.bom.billCreate'
      , p_event_key        =>to_char(BILL.bill_sequence_id)
      , p_user_key         =>ENG_BOM_RTG_TRANSFER_PKG.G_ITEM_NAME
                             ||'-'||ENG_BOM_RTG_TRANSFER_PKG.G_ORG_CODE||'-'||BILL.alternate_bom_designator
      , p_parent_event_key =>to_char(X_eng_item_id)||'-'||to_char(X_org_id)
                             ||'-'||to_char(X_mfg_item_id)
      );
    END LOOP;
  END IF;
  NOT USED ANYMORE. PLEASE SEE CALL BELOW. */
  -- ERES END
  -- ========

  FOR BOM1 IN BOM_CURSOR LOOP

    X_stmt_num := 701;
    BEGIN
      SELECT BILL_SEQUENCE_ID
      INTO X_from_bill_sequence_id
      FROM BOM_BILL_OF_MATERIALS
      WHERE ORGANIZATION_ID = X_org_id
      AND ASSEMBLY_ITEM_ID = X_eng_item_id
      AND NVL(ALTERNATE_BOM_DESIGNATOR,'NONE') = NVL(BOM1.ALTERNATE_BOM_DESIGNATOR,'NONE');
    EXCEPTION
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'BOM_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
    END;

      ENG_ITEM_PKG.COMPONENT_TRANSFER(X_org_id => X_org_id,
                                      X_eng_item_id =>  X_eng_item_id,
                                      X_designator_option => X_designator_option,
                                      X_alt_bom_designator => X_alt_bom_designator);

    BOM_COPY_BILL.COPY_BILL(from_sequence_id => X_from_bill_sequence_id,
                            to_sequence_id => BOM1.BILL_SEQUENCE_ID,
                            from_org_id => X_org_id,
                            to_org_id => X_org_id,
                            display_option => X_transfer_option,
                            user_id => to_number(Fnd_Profile.Value('USER_ID')),
                            to_item_id => X_mfg_item_id,
                            direction => 4,
                            to_alternate => BOM1.ALTERNATE_BOM_DESIGNATOR,
                            rev_date => X_effectivity_date,
			    e_change_notice => X_ecn_name,
			    rev_item_seq_id => NULL,
			    bill_or_eco => 1,
                            eco_eff_date => X_effectivity_date,
			    unit_number => X_unit_number,
			    from_item_id =>X_eng_item_id);

  END LOOP;
  IF FLAG=1 THEN -- 3503263
  UPDATE BOM_BILL_OF_MATERIALS BOM1
  SET BOM1.ALTERNATE_BOM_DESIGNATOR =NULL
  WHERE ORGANIZATION_ID = X_org_id
    AND ASSEMBLY_ITEM_ID = X_mfg_item_id
    AND (X_designator_option = 3 AND
          BOM1.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator);
END IF;

  -- Bug 4584490: Changes for bom business events support
  BEGIN
      FOR BILL IN BOM_COPIES
      LOOP
          Bom_Business_Event_PKG.Raise_Bill_Event(
              p_pk1_value         => Bill.assembly_item_id
            , p_pk2_value         => Bill.organization_id
            , p_obj_name          => Bill.obj_name
            , p_structure_name    => Bill.alternate_bom_designator
            , p_organization_id   => Bill.organization_id
            , p_structure_comment => NULL
            , p_Event_Name        => Bom_Business_Event_PKG.G_STRUCTURE_CREATION_EVENT
            );
      END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
      null;
      -- nothing is required to be done, process continues
  END;
  -- End Changes for bug 4584490
  -- bug 3780577 : odaboval moved the ERES BillCreate here
  --               in order to get the routing revisions.
  -- ERES BEGIN
  -- If there is a parent eRecord, log a child record to accompany it
  -- ================================================================
  IF ENG_BOM_RTG_TRANSFER_PKG.G_PARENT_ERECORD_ID is NOT NULL THEN
    FOR BILL IN BOM_COPIES LOOP                                        -- BUG 3503220
      -- Log an erecord for each new bill inserted above               -- BUG 3503220

      ENG_BOM_RTG_TRANSFER_PKG.Process_Erecord
      ( p_event_name       =>'oracle.apps.bom.billCreate'
      , p_event_key        =>to_char(BILL.bill_sequence_id)
      , p_user_key         =>ENG_BOM_RTG_TRANSFER_PKG.G_ITEM_NAME
                             ||'-'||ENG_BOM_RTG_TRANSFER_PKG.G_ORG_CODE||'-'||BILL.alternate_bom_designator
      , p_parent_event_key =>to_char(X_eng_item_id)||'-'||to_char(X_org_id)
                             ||'-'||to_char(X_mfg_item_id)
      );
    END LOOP;
  END IF;
  -- ERES END
  -- ========
END BOM_TRANSFER;

END ENG_BOM_PKG;

/
