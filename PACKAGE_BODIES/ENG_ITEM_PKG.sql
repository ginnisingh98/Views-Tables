--------------------------------------------------------
--  DDL for Package Body ENG_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ITEM_PKG" AS
/* $Header: ENGPITRB.pls 120.1.12010000.2 2010/08/03 20:29:03 umajumde ship $ */

-- +-------------------------- ITEM_TRANSFER ---------------------------------+
-- NAME
-- ITEM_TRANSFER

-- DESCRIPTION
-- Transfer the Engineering Item to Manufacturing, and set revisions.

-- REQUIRES
-- org_id: organization id
-- eng_item_id: original item id
-- mfg_item_id: new id for manufacturing item
-- lastloginid not used internally just kept to support already existing usage
-- mfg_description: new description for manufacturing item
-- ecn_name: associated change order
-- bom_rev_starting: new revision
-- segment1
-- segment2
-- segment3
-- segment4
-- segment5
-- segment6
-- segment7
-- segment8
-- segment9
-- segment10
-- segment11
-- segment12
-- segment13
-- segment14
-- segment15
-- segment16
-- segment17
-- segment18
-- segment19
-- segment20

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE ITEM_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_mfg_item_id			IN NUMBER,
X_last_login_id                 IN NUMBER,
X_mfg_description		IN VARCHAR2,
X_ecn_name			IN VARCHAR2,
X_bom_rev_starting		IN VARCHAR2,
X_segment1			IN VARCHAR2,
X_segment2			IN VARCHAR2,
X_segment3			IN VARCHAR2,
X_segment4			IN VARCHAR2,
X_segment5			IN VARCHAR2,
X_segment6			IN VARCHAR2,
X_segment7			IN VARCHAR2,
X_segment8			IN VARCHAR2,
X_segment9			IN VARCHAR2,
X_segment10			IN VARCHAR2,
X_segment11			IN VARCHAR2,
X_segment12			IN VARCHAR2,
X_segment13			IN VARCHAR2,
X_segment14			IN VARCHAR2,
X_segment15			IN VARCHAR2,
X_segment16			IN VARCHAR2,
X_segment17			IN VARCHAR2,
X_segment18			IN VARCHAR2,
X_segment19			IN VARCHAR2,
X_segment20			IN VARCHAR2
)
IS
  X_master_org		NUMBER;
  X_stmt_num		NUMBER;
BEGIN

  IF (X_eng_item_id = X_mfg_item_id) THEN

    X_stmt_num := 100;
    BEGIN
      UPDATE MTL_SYSTEM_ITEMS
      SET ENG_ITEM_FLAG = 'N',
          --DESCRIPTION = X_mfg_description,
          LAST_UPDATE_LOGIN = to_number(Fnd_Profile.Value('LOGIN_ID')),

          -----------------------------------
          -- Commented out by AS on 04/14/98
          -- See bug 647693.

          -- CREATED_BY = to_number(Fnd_Profile.Value('USER_ID')),
	  -- CREATION_DATE = SYSDATE,
          -----------------------------------

          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = to_number(Fnd_Profile.Value('USER_ID')),
          ENGINEERING_DATE = SYSDATE,
          ENGINEERING_ECN_CODE = X_ecn_name
      WHERE INVENTORY_ITEM_ID = X_eng_item_id
      AND ORGANIZATION_ID = X_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ITEM_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
    END;

    -- The following code included to trasfer master org item when
    -- transferring an item from eng to mfg. Bug #709403.
    X_stmt_num := 101;
    BEGIN
      SELECT MASTER_ORGANIZATION_ID
      INTO X_master_org
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = X_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_master_org := X_org_id;
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ITEM_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
    END;

    IF (X_master_org <> X_org_id) THEN
     X_stmt_num := 102;
     BEGIN
      UPDATE MTL_SYSTEM_ITEMS
      SET ENG_ITEM_FLAG = 'N',
          --DESCRIPTION = X_mfg_description,
          LAST_UPDATE_LOGIN = to_number(Fnd_Profile.Value('LOGIN_ID')),

          -----------------------------------
          -- Commented out by AS on 04/14/98
          -- See bug 647693.

          -- CREATED_BY = to_number(Fnd_Profile.Value('USER_ID')),
	  -- CREATION_DATE = SYSDATE,
          -----------------------------------

          LAST_UPDATE_DATE = SYSDATE,
          LAST_UPDATED_BY = to_number(Fnd_Profile.Value('USER_ID')),
          ENGINEERING_DATE = SYSDATE,
          ENGINEERING_ECN_CODE = X_ecn_name
      WHERE INVENTORY_ITEM_ID = X_eng_item_id
      AND ORGANIZATION_ID = X_master_org
      AND ENG_ITEM_FLAG <> 'N';
     EXCEPTION
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ITEM_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
     END;
    END IF;
  ELSE

    X_stmt_num := 101;
    BEGIN
      SELECT MASTER_ORGANIZATION_ID
      INTO X_master_org
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = X_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_master_org := X_org_id;
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'ITEM_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
    END;

  END IF;

-- Note: We do not need to worry about costs and cross references since the
--       item id has not changed

  IF (X_eng_item_id <> X_mfg_item_id) THEN

    -- Copy rows for MTL_SYSTEM_ITEMS

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_SYSTEM_ITEMS(X_org_id,
                                               X_org_id,
                                               X_eng_item_id,
                                               X_mfg_item_id,
					       -1,
                                               X_mfg_description,
                                               X_ecn_name,
                                               X_segment1,
                                               X_segment2,
                                               X_segment3,
                                               X_segment4,
                                               X_segment5,
                                               X_segment6,
                                               X_segment7,
                                               X_segment8,
                                               X_segment9,
                                               X_segment10,
                                               X_segment11,
                                               X_segment12,
                                               X_segment13,
                                               X_segment14,
                                               X_segment15,
                                               X_segment16,
                                               X_segment17,
                                               X_segment18,
                                               X_segment19,
                                               X_segment20);

    -- Copy rows for MTL_ITEM_CATEGORIES

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_CATEGORIES(X_org_id,
                                                  X_org_id,
                                                  X_eng_item_id,
                                                  X_mfg_item_id,
						  -1,
                                                  X_mfg_description,
                                                  X_ecn_name);

    -- Copy rows for MTL_DESCR_ELEMENT_VALUES

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_DESCR_ELEMENT_VALUES(X_org_id,
                                                       X_org_id,
                                                       X_eng_item_id,
                                                       X_mfg_item_id,
						       -1,
                                                       X_mfg_description,
                                                       X_ecn_name);

    -- Copy rows for MTL_RELATED_ITEMS

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_RELATED_ITEMS(X_org_id,
                                                X_org_id,
                                                X_eng_item_id,
                                                X_mfg_item_id,
						-1,
                                                X_mfg_description,
                                                X_ecn_name);

    -- Copy rows for CST_ITEM_COSTS

    ENG_COPY_TABLE_ROWS_PKG.C_CST_ITEM_COSTS(X_org_id,
                                             X_org_id,
                                             X_eng_item_id,
                                             X_mfg_item_id,
					     -1,
                                             X_mfg_description,
                                             X_ecn_name);

    -- Copy rows for CST_ITEM_COST_DETAILS

    ENG_COPY_TABLE_ROWS_PKG.C_CST_ITEM_COST_DETAILS(X_org_id,
                                                    X_org_id,
                                                    X_eng_item_id,
                                                    X_mfg_item_id,
						    -1,
                                                    X_mfg_description,
                                                    X_ecn_name);

    -- Copy rows for MTL_ITEM_SUB_INVENTORIES

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_SUB_INVENTORIES(X_org_id,
                                                       X_org_id,
                                                       X_eng_item_id,
                                                       X_mfg_item_id,
						       -1,
                                                       X_mfg_description,
                                                       X_ecn_name);

    -- Copy rows for MTL_SECONDARY_LOCATORS

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_SECONDARY_LOCATORS(X_org_id,
                                                     X_org_id,
                                                     X_eng_item_id,
                                                     X_mfg_item_id,
						     -1,
                                                     X_mfg_description,
                                                     X_ecn_name);

    -- Copy rows for MTL_CROSS_REFERENCES

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_CROSS_REFERENCES(X_org_id,
                                                   X_org_id,
                                                   X_eng_item_id,
                                                   X_mfg_item_id,
						   -1,
                                                   X_mfg_description,
                                                   X_ecn_name);

    -- Copy rows for MTL_PENDING_ITEM_STATUS

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_PENDING_ITEM_STATUS(X_org_id,
                                                      X_org_id,
                                                      X_eng_item_id,
                                                      X_mfg_item_id,
						      -1,
                                                      X_mfg_description,
                                                      X_ecn_name);

    -- Copy rows for CST_STANDARD_COSTS

    ENG_COPY_TABLE_ROWS_PKG.C_CST_STANDARD_COSTS(X_org_id,
                                                 X_org_id,
                                                 X_eng_item_id,
                                                 X_mfg_item_id,
						 -1,
                                                 X_mfg_description,
                                                 X_ecn_name);

    -- Copy rows for CST_ELEMENTAL_COSTS

    ENG_COPY_TABLE_ROWS_PKG.C_CST_ELEMENTAL_COSTS(X_org_id,
                                                  X_org_id,
                                                  X_eng_item_id,
                                                  X_mfg_item_id,
						  -1,
                                                  X_mfg_description,
                                                  X_ecn_name);

    -- If item name has been changed, check if item exists in master
    -- organization. If not, it needs to be created.

    IF (X_master_org <> X_org_id) THEN

      -- Copy rows for MTL_SYSTEM_ITEMS for the master org

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_SYSTEM_ITEMS(X_org_id,
                                                 X_master_org,
                                                 X_eng_item_id,
                                                 X_mfg_item_id,
						 -1,
                                                 X_mfg_description,
                                                 X_ecn_name,
                                                 X_segment1,
                                                 X_segment2,
                                                 X_segment3,
                                                 X_segment4,
                                                 X_segment5,
                                                 X_segment6,
                                                 X_segment7,
                                                 X_segment8,
                                                 X_segment9,
                                                 X_segment10,
                                                 X_segment11,
                                                 X_segment12,
                                                 X_segment13,
                                                 X_segment14,
                                                 X_segment15,
                                                 X_segment16,
                                                 X_segment17,
                                                 X_segment18,
                                                 X_segment19,
                                                 X_segment20);

      -- Copy rows for each table that is org dependent for the item
      -- in the master org

      -- Copy rows for MTL_ITEM_CATEGORIES

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_CATEGORIES(X_org_id,
                                                  X_master_org,
                                                  X_eng_item_id,
                                                  X_mfg_item_id,
						  -1,
                                                  X_mfg_description,
                                                  X_ecn_name);

      -- CST_ITEM_COSTS

      ENG_COPY_TABLE_ROWS_PKG.C_CST_ITEM_COSTS(X_org_id,
                                               X_master_org,
                                               X_eng_item_id,
                                               X_mfg_item_id,
					       -1,
                                               X_mfg_description,
                                               X_ecn_name);
      -- CST_ITEM_COST_DETAILS

      ENG_COPY_TABLE_ROWS_PKG.C_CST_ITEM_COST_DETAILS(X_org_id,
                                                      X_master_org,
                                                      X_eng_item_id,
                                                      X_mfg_item_id,
						      -1,
                                                      X_mfg_description,
                                                      X_ecn_name);

      -- MTL_ITEM_SUB_INVENTORIES

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_SUB_INVENTORIES(X_org_id,
                                                         X_master_org,
                                                         X_eng_item_id,
                                                         X_mfg_item_id,
							 -1,
                                                         X_mfg_description,
                                                         X_ecn_name);

      -- MTL_SECONDARY_LOCATORS

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_SECONDARY_LOCATORS(X_org_id,
                                                       X_master_org,
                                                       X_eng_item_id,
                                                       X_mfg_item_id,
						       -1,
                                                       X_mfg_description,
                                                       X_ecn_name);

      -- MTL_CROSS_REFERENCES

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_CROSS_REFERENCES(X_org_id,
                                                     X_master_org,
                                                     X_eng_item_id,
                                                     X_mfg_item_id,
						     -1,
                                                     X_mfg_description,
                                                     X_ecn_name);

      -- MTL_PENDING_ITEM_STATUS

      ENG_COPY_TABLE_ROWS_PKG.C_MTL_PENDING_ITEM_STATUS(X_org_id,
                                                        X_master_org,
                                                        X_eng_item_id,
                                                        X_mfg_item_id,
						        -1,
                                                        X_mfg_description,
                                                        X_ecn_name);

      -- CST_STANDARD_COSTS

      ENG_COPY_TABLE_ROWS_PKG.C_CST_STANDARD_COSTS(X_org_id,
                                                   X_master_org,
                                                   X_eng_item_id,
                                                   X_mfg_item_id,
						   -1,
                                                   X_mfg_description,
                                                   X_ecn_name);

      -- CST_ELEMENTAL_COSTS

      ENG_COPY_TABLE_ROWS_PKG.C_CST_ELEMENTAL_COSTS(X_org_id,
                                                    X_master_org,
                                                    X_eng_item_id,
                                                    X_mfg_item_id,
						    -1,
                                                    X_mfg_description,
                                                    X_ecn_name);

      IF (X_bom_rev_starting IS NOT NULL) THEN
        ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_REVISIONS(X_inventory_item_id => X_mfg_item_id,
                                                     X_organization_id => X_master_org,
                                                     X_revision => X_bom_rev_starting,
                                                     X_last_update_date => SYSDATE,
                                                     X_last_updated_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                     X_creation_date => SYSDATE,
                                                     X_created_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                     X_last_update_login => to_number(Fnd_Profile.Value('LOGIN_ID')),
                                                     X_effectivity_date => SYSDATE,
                                                     X_change_notice => X_ecn_name,
                                                     X_implementation_date => SYSDATE);
      END IF;

    END IF; -- end of IF (X_master_org <> X_org_id) THEN

  END IF; -- end of IF (X_eng_item_id <> X_mfg_item_id) THEN

  -- Inserting the new revision in MTL_ITEM_REVISIONS.

  IF (X_bom_rev_starting IS NOT NULL) THEN

    ENG_COPY_TABLE_ROWS_PKG.C_MTL_ITEM_REVISIONS(X_inventory_item_id => X_mfg_item_id,
                                                 X_organization_id => X_org_id,
                                                 X_revision => X_bom_rev_starting,
                                                 X_last_update_date => SYSDATE,
                                                 X_last_updated_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                 X_creation_date => SYSDATE,
                                                 X_created_by => to_number(Fnd_Profile.Value('USER_ID')),
                                                 X_last_update_login => to_number(Fnd_Profile.Value('LOGIN_ID')),
                                                 X_effectivity_date => SYSDATE,
                                                 X_change_notice => X_ecn_name,
                                                 X_implementation_date => SYSDATE);

  END IF;

END ITEM_TRANSFER;

  /***************************************************************************
  * Function : Get_GTIN_Structure_Type_Id
  * Returns : StructureTypeId of 'Packaging Hierarchy' / NULL
  * Parameters IN : None
  * Parameters OUT: None
  * Purpose : To get the StructureTypeId of 'Packaging Hierarchy' if available
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

-- +--------------------------- COMPONENT_TRANSFER ----------------------------+
-- NAME
-- COMPONENT_TRANSFER

-- DESCRIPTION
-- Transfer Components: Flip the eng_item_flag to 'N' for each component of
--                      the bills.

-- REQUIRES
-- org_id: organization id
-- eng_item_id
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE COMPONENT_TRANSFER
(
X_org_id			IN NUMBER,
X_eng_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2
)
IS
  X_master_org  NUMBER;
  X_stmt_num	NUMBER;
  X_GTIN_ST_TYPE_ID NUMBER;

  --BOM ER 9946990 begin

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

BEGIN

  --BOM ER 9946990 begin

  X_stmt_num := 198;

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

--BOM ER 9946990 begin
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

  X_stmt_num := 199;

  X_GTIN_ST_TYPE_ID := Get_GTIN_Structure_Type_Id;

  BEGIN
  UPDATE MTL_SYSTEM_ITEMS
  SET ENG_ITEM_FLAG = 'N'
  WHERE ORGANIZATION_ID = X_org_id
  AND ENG_ITEM_FLAG <> 'N'
  AND INVENTORY_ITEM_ID IN
  (SELECT BIC.COMPONENT_ITEM_ID
   FROM BOM_INVENTORY_COMPONENTS BIC,
        BOM_BILL_OF_MATERIALS BOM
   WHERE BOM.ORGANIZATION_ID = X_org_id
   AND BOM.ASSEMBLY_ITEM_ID = X_eng_item_id
   AND ((X_designator_option = 2 AND
         BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
     OR (X_designator_option = 3 AND
         BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
     OR (X_designator_option = 1))
   AND (X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
   AND nvl(bom.effectivity_control, 1) <> 4 -- Bug 4210718
   AND BIC.BILL_SEQUENCE_ID = BOM.BILL_SEQUENCE_ID);


  EXCEPTION
  WHEN OTHERS THEN
    ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'COMPONENT_TRANSFER',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
  END;

/* The following SQL is added to fix Bug 1799242 */
-- Transfer Sub Components: Flip the eng_item_flag to 'N' for each
-- of the Substitute component for all the Components of
--                      the bills.

  X_stmt_num := 200;

  BEGIN
  UPDATE MTL_SYSTEM_ITEMS
  SET ENG_ITEM_FLAG = 'N'
  WHERE ORGANIZATION_ID = X_org_id
  AND ENG_ITEM_FLAG <> 'N'
  AND INVENTORY_ITEM_ID IN
  (select BSC.SUBSTITUTE_COMPONENT_ID
   from BOM_SUBSTITUTE_COMPONENTS BSC,
        BOM_INVENTORY_COMPONENTS BIC,
        BOM_BILL_OF_MATERIALS BOM
   WHERE
   BSC.COMPONENT_SEQUENCE_ID = BIC.COMPONENT_SEQUENCE_ID
   AND BOM.ORGANIZATION_ID = X_org_id
   AND BOM.ASSEMBLY_ITEM_ID = X_eng_item_id
   AND ((X_designator_option = 2 AND
         BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
     OR (X_designator_option = 3 AND
         BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
     OR (X_designator_option = 1))
   AND (X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
   AND nvl(bom.effectivity_control, 1) <> 4 -- Bug 4210718
   AND BIC.BILL_SEQUENCE_ID = BOM.BILL_SEQUENCE_ID);


  EXCEPTION

  WHEN OTHERS THEN
    ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'COMPONENT_TRANSFER',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
  END;

/* Changes for 1799242 end here */

  -- The following code included to trasfer master org item when
  -- transferring an item from eng to mfg. Bug #709403.
  X_stmt_num := 201;
  BEGIN
      SELECT MASTER_ORGANIZATION_ID
      INTO X_master_org
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = X_org_id;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        X_master_org := X_org_id;
      WHEN OTHERS THEN
        ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'COMPONENT_TRANSFER',
                                             stmt_num => X_stmt_num,
                                             message_name => 'ENG_ENUBRT_ERROR',
                                             token => SQLERRM);
  END;

  IF (X_master_org <> X_org_id) THEN
  	X_stmt_num := 200;
  	BEGIN
  	UPDATE MTL_SYSTEM_ITEMS
  	SET ENG_ITEM_FLAG = 'N'
  	WHERE ORGANIZATION_ID = X_master_org
  	AND ENG_ITEM_FLAG <> 'N'
  	AND INVENTORY_ITEM_ID IN
  	(SELECT BIC.COMPONENT_ITEM_ID
   	FROM BOM_INVENTORY_COMPONENTS BIC,
        	BOM_BILL_OF_MATERIALS BOM
   	WHERE BOM.ORGANIZATION_ID = X_org_id
   	AND BOM.ASSEMBLY_ITEM_ID = X_eng_item_id
   	AND ((X_designator_option = 2 AND
         	BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
     	OR (X_designator_option = 3 AND
         	BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
     	OR (X_designator_option = 1))
   	AND (X_GTIN_ST_TYPE_ID IS NULL or STRUCTURE_TYPE_ID <> X_GTIN_ST_TYPE_ID)
        AND nvl(bom.effectivity_control, 1) <> 4 -- Bug 4210718
   	AND BIC.BILL_SEQUENCE_ID = BOM.BILL_SEQUENCE_ID);


  	EXCEPTION
  	WHEN OTHERS THEN
    	ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'COMPONENT_TRANSFER',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
  	END;
  END IF;
END COMPONENT_TRANSFER;

-- +--------------------------- SET_OP_SEQ -----------------------------------+
-- NAME
-- SET_OP_SEQ

-- DESCRIPTION
-- Set Operation Sequence: Set operation_seq_num to 1 in table
--                         BOM_INVENTORY_COMPONENTS where there is no
--                         corresponding manufacturing routing.

-- REQUIRES
-- org_id: organization id
-- item_id: item to be updated
-- designator_option
--   1. all
--   2. primary only
--   3. specific only
-- alt_bom_designator

-- OUTPUT

-- NOTES

-- +--------------------------------------------------------------------------+

PROCEDURE SET_OP_SEQ
(
X_org_id			IN NUMBER,
X_item_id			IN NUMBER,
X_designator_option		IN NUMBER,
X_alt_bom_designator		IN VARCHAR2
)
IS
  DUMMY		NUMBER DEFAULT 0;
  X_stmt_num	NUMBER;
  X_unit_assembly	VARCHAR2(2) := 'N';

  l_primary_rtg_sequence_id NUMBER;
  l_primary_rtg_exists NUMBER;
  l_routing_sequence_id NUMBER;
  l_routing_type NUMBER;
  l_primary_rtg_type NUMBER;

CURSOR c_transfer_bills IS
  SELECT *
  FROM BOM_BILL_OF_MATERIALS BOM
  WHERE BOM.ORGANIZATION_ID = X_org_id
  AND BOM.ASSEMBLY_ITEM_ID = X_item_id
  AND nvl(bom.effectivity_control, 1) <> 4 -- Bug 4210718
  AND ((X_designator_option = 2 AND BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
    OR (X_designator_option = 3 AND BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
    OR (X_designator_option = 1));


BEGIN

  X_stmt_num := 300;
  -- Changes for bug 3801212
  -- Need to update the operation_seq_num in bom_inventory_components conditionally
  -- Case A: Primary bill is transferred
  --	   1) Primary routing_type = 1 (mfg): No update required
  --	   2) Primary routing_type = 2 (eng): update required
  -- Case B: Alternate bill is transferred
  --     Alternate routing exists
  --	   1) Alternate routing_type = 1 (mfg): No update required
  --	   2) Alternate routing_type = 2 (eng): update required
  --     Alternate routing does not exist
  --	   1) Primary routing_type = 1 (mfg): No update required
  --	   2) Primary routing_type = 2 (eng): update required
  l_primary_rtg_sequence_id := -1;
  l_primary_rtg_type := -1;
  l_primary_rtg_exists := 1;

  FOR ctb IN c_transfer_bills
  LOOP
	l_routing_sequence_id := -1;
	l_routing_type := -1;
	-- Step 1: Fetch the routing sequence id
	BEGIN
		IF ctb.ALTERNATE_BOM_DESIGNATOR IS NOT NULL AND l_primary_rtg_exists = 1
		THEN
			BEGIN
				X_stmt_num := 301;
				SELECT BOR.COMMON_ROUTING_SEQUENCE_ID, BOR.ROUTING_TYPE
				INTO l_routing_sequence_id, l_routing_type
				FROM BOM_OPERATIONAL_ROUTINGS BOR
				WHERE BOR.ASSEMBLY_ITEM_ID = ctb.ASSEMBLY_ITEM_ID
				AND BOR.ORGANIZATION_ID = ctb.ORGANIZATION_ID
				AND BOR.ALTERNATE_ROUTING_DESIGNATOR = ctb.ALTERNATE_BOM_DESIGNATOR;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				null;
			END;
		END IF;
		IF (l_routing_sequence_id = -1
		    AND  l_primary_rtg_exists = 1
		    AND (l_primary_rtg_sequence_id = -1 OR l_primary_rtg_type <> 1))
		THEN
			BEGIN
				X_stmt_num := 302;
				SELECT BOR.COMMON_ROUTING_SEQUENCE_ID, BOR.ROUTING_TYPE
				INTO l_routing_sequence_id, l_routing_type
				FROM BOM_OPERATIONAL_ROUTINGS BOR
				WHERE BOR.ASSEMBLY_ITEM_ID = ctb.ASSEMBLY_ITEM_ID
				AND BOR.ORGANIZATION_ID = ctb.ORGANIZATION_ID
				AND BOR.ALTERNATE_ROUTING_DESIGNATOR IS NULL;

				l_primary_rtg_sequence_id := l_routing_sequence_id;
				l_primary_rtg_type := l_routing_type;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				  l_primary_rtg_exists := 2;
			END;
		ELSIF (l_routing_sequence_id = -1 AND l_primary_rtg_sequence_id <> -1 AND l_primary_rtg_type = 1)
		THEN
			l_routing_sequence_id := l_primary_rtg_sequence_id;
			l_routing_type := l_primary_rtg_type;
		END IF;
		IF (l_routing_type <> 1 AND l_routing_sequence_id <> -1)
		THEN
			l_routing_sequence_id := -1;
		END IF;

	EXCEPTION
	WHEN OTHERS THEN
		ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'SET_OP_SEQ',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
	END;
	-- Step 2: Update OPERATION_SEQ_NUM Accordingly
	BEGIN
		IF ( l_routing_sequence_id = -1 )
		THEN
			X_stmt_num := 303;
			UPDATE BOM_INVENTORY_COMPONENTS
			SET OPERATION_SEQ_NUM = 1
		        WHERE BILL_SEQUENCE_ID = ctb.BILL_SEQUENCE_ID;
		ELSE
			X_stmt_num := 304;
			UPDATE BOM_INVENTORY_COMPONENTS BIC
		        SET BIC.OPERATION_SEQ_NUM = 1
		        WHERE BIC.BILL_SEQUENCE_ID = ctb.BILL_SEQUENCE_ID
		        AND NOT EXISTS (SELECT NULL
					FROM BOM_OPERATION_SEQUENCES BOS
					WHERE ROUTING_SEQUENCE_ID = l_routing_sequence_id
					AND BOS.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM);
		END IF;
	EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		FND_MESSAGE.SET_NAME('ENG', 'ENG_COMP_OP_COMBINATION');
		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN OTHERS THEN
		ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'SET_OP_SEQ',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
	END;

	IF (PJM_UNIT_EFF.Enabled = 'Y' AND
 	    PJM_UNIT_EFF.Unit_Effective_Item(
 	         X_Item_ID => X_item_id,
 	         X_Organization_ID => X_org_id) = 'Y')
 	THEN
	       X_unit_assembly := 'Y';
        ELSE
	       X_unit_assembly := 'N';
 	END IF;
	-- Step 3: Validate that there are no overlapping components created by result of the above update
	BEGIN
		X_stmt_num := 305;
		SELECT count(*)
		INTO DUMMY
		FROM BOM_INVENTORY_COMPONENTS BIC
		WHERE BIC.BILL_SEQUENCE_ID = ctb.BILL_SEQUENCE_ID
		AND EXISTS
		(SELECT NULL
		 FROM BOM_INVENTORY_COMPONENTS BIC2
		 WHERE BIC2.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
		 AND BIC2.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
		 AND BIC2.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
		 AND NVL(BIC2.ECO_FOR_PRODUCTION,2) = 2
		 AND BIC2.COMPONENT_SEQUENCE_ID <> BIC.COMPONENT_SEQUENCE_ID
		 AND NVL(BIC2.OLD_COMPONENT_SEQUENCE_ID, BIC2.COMPONENT_SEQUENCE_ID)
		         <> BIC.COMPONENT_SEQUENCE_ID
		 AND ((X_unit_assembly = 'Y'
		       AND BIC2.DISABLE_DATE IS NULL
		       AND (BIC.TO_END_ITEM_UNIT_NUMBER IS NULL
		            OR BIC.TO_END_ITEM_UNIT_NUMBER >= BIC2.FROM_END_ITEM_UNIT_NUMBER)
		       AND (BIC2.TO_END_ITEM_UNIT_NUMBER IS NULL
		            OR BIC.FROM_END_ITEM_UNIT_NUMBER <= BIC2.TO_END_ITEM_UNIT_NUMBER))
		     OR (X_unit_assembly = 'N'
		         AND BIC2.EFFECTIVITY_DATE BETWEEN BIC.EFFECTIVITY_DATE
			                           AND NVL(BIC.DISABLE_DATE - 1, BIC2.EFFECTIVITY_DATE + 1)))
		);
	EXCEPTION
	WHEN OTHERS THEN
		ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'SET_OP_SEQ',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
	END;
 	IF (DUMMY <> 0)
	THEN
 		IF (X_unit_assembly = 'Y')
		THEN
			FND_MESSAGE.SET_NAME('BOM', 'BOM_UNIT_OVERLAP');
		ELSE
			FND_MESSAGE.SET_NAME('ENG', 'ENG_COMP_OP_COMBINATION');
		END IF;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END LOOP;
/*
  BEGIN
    UPDATE BOM_INVENTORY_COMPONENTS BIC
    SET OPERATION_SEQ_NUM = 1
    WHERE NOT EXISTS
      (SELECT 'X'
       FROM BOM_OPERATIONAL_ROUTINGS BOR,
            BOM_BILL_OF_MATERIALS BOM,
            BOM_OPERATION_SEQUENCES BOS
       WHERE BIC.BILL_SEQUENCE_ID = BOM.BILL_SEQUENCE_ID
       AND BOR.ROUTING_TYPE = 1
       AND BOM.ASSEMBLY_ITEM_ID = BOR.ASSEMBLY_ITEM_ID
       AND BOM.ORGANIZATION_ID = BOR.ORGANIZATION_ID
       AND NVL(BOM.ALTERNATE_BOM_DESIGNATOR, 'NONE') =
           NVL(BOR.ALTERNATE_ROUTING_DESIGNATOR, 'NONE')
       AND BOR.COMMON_ROUTING_SEQUENCE_ID = BOS.ROUTING_SEQUENCE_ID
       AND BIC.OPERATION_SEQ_NUM = BOS.OPERATION_SEQ_NUM)
    AND BIC.BILL_SEQUENCE_ID IN
      (SELECT BOM2.BILL_SEQUENCE_ID
       FROM BOM_BILL_OF_MATERIALS BOM2
       WHERE BOM2.ORGANIZATION_ID = X_org_id
       AND BOM2.ASSEMBLY_ITEM_ID = X_item_id
       AND ((X_designator_option = 2 AND
             BOM2.ALTERNATE_BOM_DESIGNATOR IS NULL)
            OR
            (X_designator_option = 3 AND
             BOM2.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
            OR
            (X_designator_option = 1)));
  EXCEPTION
    WHEN OTHERS THEN
      ENG_BOM_RTG_TRANSFER_PKG.RAISE_ERROR(func_name => 'SET_OP_SEQ',
                                         stmt_num => X_stmt_num,
                                         message_name => 'ENG_ENUBRT_ERROR',
                                         token => SQLERRM);
  END;

  -- if found means the update caused an overlapping component effectivity
  -- date, then transfer will fail

  X_stmt_num := 301;

  IF (PJM_UNIT_EFF.Enabled = 'Y' AND
      PJM_UNIT_EFF.Unit_Effective_Item(
           X_Item_ID => X_item_id,
           X_Organization_ID => X_org_id) = 'Y')
  THEN
	X_unit_assembly := 'Y';
  ELSE
	X_unit_assembly := 'N';
  END IF;

  SELECT count(*)
  INTO DUMMY
  FROM BOM_INVENTORY_COMPONENTS BIC
  WHERE BIC.BILL_SEQUENCE_ID IN
    (SELECT BOM.BILL_SEQUENCE_ID
     FROM BOM_BILL_OF_MATERIALS BOM
     WHERE BOM.ORGANIZATION_ID = X_org_id
     AND BOM.ASSEMBLY_ITEM_ID = X_item_id
     AND ((X_designator_option = 2 AND
           BOM.ALTERNATE_BOM_DESIGNATOR IS NULL)
          OR
          (X_designator_option = 3 AND
           BOM.ALTERNATE_BOM_DESIGNATOR = X_alt_bom_designator)
          OR
          (X_designator_option = 1)))
     AND EXISTS
       (SELECT NULL
        FROM BOM_INVENTORY_COMPONENTS BIC2
        WHERE BIC2.BILL_SEQUENCE_ID = BIC.BILL_SEQUENCE_ID
        AND BIC2.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID
        AND BIC2.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
	AND NVL(BIC2.ECO_FOR_PRODUCTION,2) = 2
        AND BIC2.COMPONENT_SEQUENCE_ID <> BIC.COMPONENT_SEQUENCE_ID
        AND NVL(BIC2.OLD_COMPONENT_SEQUENCE_ID, BIC2.COMPONENT_SEQUENCE_ID) <> BIC.COMPONENT_SEQUENCE_ID
        AND ((X_unit_assembly = 'Y'
            AND BIC2.DISABLE_DATE IS NULL
	    AND (BIC.TO_END_ITEM_UNIT_NUMBER IS NULL
             OR BIC.TO_END_ITEM_UNIT_NUMBER >= BIC2.FROM_END_ITEM_UNIT_NUMBER)
            AND (BIC2.TO_END_ITEM_UNIT_NUMBER IS NULL
             OR BIC.FROM_END_ITEM_UNIT_NUMBER <= BIC2.TO_END_ITEM_UNIT_NUMBER))
	 OR (X_unit_assembly = 'N'
	    AND BIC2.EFFECTIVITY_DATE BETWEEN BIC.EFFECTIVITY_DATE AND
            NVL(BIC.DISABLE_DATE - 1, BIC2.EFFECTIVITY_DATE + 1))));

  IF (DUMMY <> 0) THEN
     IF (X_unit_assembly = 'Y') THEN
      FND_MESSAGE.SET_NAME('BOM', 'BOM_UNIT_OVERLAP');
     ELSE
      FND_MESSAGE.SET_NAME('ENG', 'ENG_COMP_OP_COMBINATION');
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
*/
END SET_OP_SEQ;

END ENG_ITEM_PKG;

/
