--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTION_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTION_LOVS" AS
/* $Header: INVMWALB.pls 120.1 2005/06/17 10:08:15 appldev  $ */

PROCEDURE GET_TXN_REASONS(x_txnreasonLOV OUT NOCOPY /* file.sql.39 change */ t_genref) IS
BEGIN
    OPEN x_txnreasonLOV FOR
	SELECT reason_id,reason_name,description
	FROM MTL_TRANSACTION_REASONS
	WHERE NVL(DISABLE_DATE,SYSDATE) >= SYSDATE;

END GET_TXN_REASONS;

PROCEDURE GET_CARRIER(x_getcarrierLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
		      p_FromOrganization_Id IN NUMBER,
		      p_ToOrganization_Id IN NUMBER,
		      p_carrier IN VARCHAR2)
  IS
BEGIN
   OPEN x_getcarrierLOV FOR
     select freight_code, description, distribution_account
     from
     org_enabled_freight_val_v
     where organization_id = (SELECT decode(FOB_POINT,1,TO_ORGANIZATION_ID,2, FROM_ORGANIZATION_ID) from mtl_interorg_parameters where TO_ORGANIZATION_ID = p_FromOrganization_Id and from_organization_id =p_ToOrganization_Id )
     AND freight_code LIKE p_carrier
     order by freight_code;
END GET_CARRIER;



PROCEDURE GET_TXN_TYPES(x_motxntypeLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
			p_transaction_source_type_id IN NUMBER) IS
begin
	open x_motxntypeLOV FOR
	   select transaction_type_id, transaction_type_name, description, transaction_action_id
	   from mtl_transaction_types
	   where transaction_source_type_id = p_transaction_Source_type_id;
END GET_TXN_TYPES;


PROCEDURE GET_TXN_TYPES(x_txntypeLOV OUT NOCOPY /* file.sql.39 change */ t_genref,
				p_Transaction_Action_Id IN NUMBER,
				p_Transaction_Source_Type_Id IN NUMBER,
				p_Transaction_Type_Name IN VARCHAR2) IS
BEGIN
    OPEN x_txntypeLOV FOR
        select transaction_type_id,transaction_type_name,description
	from mtl_transaction_types
	where transaction_action_id = p_Transaction_Action_Id and
	transaction_source_type_id = p_Transaction_Source_Type_Id and
	transaction_type_name like p_Transaction_Type_Name;

END GET_TXN_TYPES;

-- this procedure gets the accounts for a given organization and puts them in a
-- reference cursor.


PROCEDURE GET_ACCOUNT_ALIAS(x_Accounts_Info OUT NOCOPY /* file.sql.39 change */ t_genref,
			       p_Organization_Id IN NUMBER,
			       p_Description     IN VARCHAR2) IS
BEGIN
    OPEN x_Accounts_Info FOR
	select distribution_account,disposition_id,description from mtl_generic_dispositions
	where organization_id = p_Organization_Id and
	description like p_Description;

END GET_ACCOUNT_ALIAS;


PROCEDURE GET_ACCOUNTS(x_Accounts OUT NOCOPY /* file.sql.39 change */ t_genref,
		       p_Organization_Id IN NUMBER,
		       p_Concatenated_Segments IN VARCHAR2) IS
BEGIN
    OPEN x_Accounts FOR
	SELECT a.code_combination_id,a.concatenated_segments FROM gl_code_combinations_kfv a,
	org_organization_definitions b
	WHERE b.organization_id = p_Organization_Id AND
	      a.chart_of_accounts_id = b.chart_of_accounts_id AND
	      a.concatenated_segments like p_Concatenated_Segments
	      and a.enabled_flag = 'Y' and nvl(a.start_date_active,sysdate-1)<=sysdate and
              nvl(a.end_date_active,sysdate+1)>sysdate;
END GET_ACCOUNTS;

procedure GET_ITEMS(x_items OUT NOCOPY /* file.sql.39 change */ t_genref,
		    p_organization_id IN NUMBER,
		    p_concatenated_segments IN VARCHAR2) IS
BEGIN
   open x_items for
	select concatenated_segments, inventory_item_id, description,
     revision_qty_control_code, lot_control_code, location_control_code,
     serial_number_control_code, restrict_subinventories_code,
     restrict_locators_code
	from mtl_system_items_kfv
	where organization_id = p_organization_id
	and mtl_transactions_enabled_flag = 'Y'
	and concatenated_segments like p_concatenated_segments;
END;

--This procedure gets all the transactable items in an organization and returns
--them in a ref cursor back to the mobile server

PROCEDURE GET_TRANSACTABLE_ITEMS(x_Items OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Concatenated_Segments IN VARCHAR2,
				 p_Transaction_Action_Id IN NUMBER,
				 p_To_Organization_Id IN NUMBER DEFAULT
				 NULL)
  IS
BEGIN
    IF p_Transaction_Action_Id = 3 THEN
	OPEN x_Items FOR
	    select concatenated_segments,inventory_item_id,description,
	  revision_qty_control_code,lot_control_code,location_control_code,
	  serial_number_control_code,restrict_subinventories_code,
	  restrict_locators_code ,
	  Nvl(shelf_life_code, 1),
	  Nvl(shelf_life_days,0),
          Nvl(effectivity_control,1)
   	    from mtl_system_items_kfv
            where organization_id = p_Organization_Id
	    and mtl_transactions_enabled_flag = 'Y'
            and inventory_item_id IN
		(SELECT inventory_item_id
		 from mtl_system_items
		 where organization_id = p_To_Organization_Id
		 and mtl_transactions_enabled_flag = 'Y')
	    and concatenated_segments like p_Concatenated_Segments;
     ELSE
	OPEN x_Items FOR
	    select concatenated_segments,inventory_item_id,description,
	   	   revision_qty_control_code,lot_control_code,
		   serial_number_control_code,restrict_subinventories_code,restrict_locators_code,
		   location_control_code,Nvl(shelf_life_code, 1),Nvl(shelf_life_days,0), Nvl(effectivity_control,1)
	    from mtl_system_items_kfv
	    where organization_id = p_Organization_Id
	    and mtl_transactions_enabled_flag = 'Y'
	    and concatenated_segments like p_Concatenated_Segments;
     END IF;
END GET_TRANSACTABLE_ITEMS;

PROCEDURE GET_VALID_LOCATORS(x_Locators OUT NOCOPY /* file.sql.39 change */ t_genref,
				     p_Organization_Id IN NUMBER,
				     p_Subinventory_Code IN VARCHAR2,
				     p_Restrict_Locators_Code IN NUMBER,
				     p_Inventory_Item_Id IN NUMBER,
				     p_Concatenated_Segments IN VARCHAR2)

IS
   l_locator_id NUMBER;
BEGIN
   IF p_Restrict_Locators_Code = 1  THEN --Locators restricted to predefined list
	OPEN x_Locators FOR
 	    select a.inventory_location_id, a.concatenated_segments,a.description
	    FROM mtl_item_locations_kfv a,mtl_secondary_locators b
	    WHERE b.organization_id = p_Organization_Id and
	          b.inventory_item_id = p_Inventory_Item_Id and
	      	  b.subinventory_code = p_Subinventory_Code and
	      	  a.inventory_location_id = b.secondary_locator and
	      	  a.concatenated_segments like (p_concatenated_segments);
   ELSE --Locators not restricted
	OPEN x_Locators FOR
	     select inventory_location_id,concatenated_segments,description
	     FROM mtl_item_locations_kfv
	     WHERE organization_id = p_Organization_Id and
	      	   subinventory_code = p_Subinventory_Code and
	           concatenated_segments like (p_concatenated_segments);
   END IF;
END GET_VALID_LOCATORS;

PROCEDURE GET_VALID_TO_LOCS(x_Locators OUT NOCOPY /* file.sql.39 change */ t_genref,
				     p_Transaction_Action_Id IN NUMBER,
		           	     p_To_Organization_Id IN NUMBER,
				     p_Organization_Id IN NUMBER,
				     p_Subinventory_Code IN VARCHAR2,
				     p_Restrict_Locators_Code IN NUMBER,
				     p_Inventory_Item_Id IN NUMBER,
				     p_Concatenated_Segments IN VARCHAR2)
IS
l_org NUMBER;
l_Restrict_Locators_Code NUMBER;
BEGIN
    IF p_Transaction_Action_Id = 3 THEN
       l_org := p_To_Organization_Id;
       select restrict_locators_code into l_Restrict_Locators_Code
       from mtl_system_items
       where inventory_item_id = p_Inventory_Item_Id and organization_id = l_org;
    ELSE
       l_org := p_Organization_Id;
       l_Restrict_Locators_Code := p_Restrict_Locators_Code;
    END IF;

    GET_VALID_LOCATORS(x_Locators,
		   l_org,
		   p_Subinventory_Code,
		   l_Restrict_Locators_Code,
		   p_Inventory_Item_Id,
		   p_Concatenated_Segments);
END GET_VALID_TO_LOCS;

PROCEDURE GET_VALID_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
			 p_organization_id IN NUMBER,
			 p_subinventory_code IN VARCHAR2) IS
BEGIN
    open x_Zones for
	SELECT secondary_inventory_name, description, locator_type, asset_inventory
   	FROM mtl_secondary_inventories
	WHERE organization_id = p_organization_id
	AND secondary_inventory_name like p_subinventory_code;
END GET_VALID_SUBS;

PROCEDURE GET_FROM_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
		        p_organization_id IN NUMBER) IS
BEGIN
     open x_Zones for
        SELECT secondary_inventory_name,description,asset_inventory
        FROM mtl_secondary_inventories
	WHERE 	organization_id = p_Organization_Id;
END GET_FROM_SUBS;

PROCEDURE GET_FROM_SUBS(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Restrict_Subinventories_Code IN NUMBER,
				 p_Secondary_Inventory_Name IN VARCHAR2,
				 p_Transaction_Action_Id IN NUMBER)
	IS
	l_expense_to_asset VARCHAR2(1);
	BEGIN
	FND_PROFILE.GET('INV:EXPENSE_TO_ASSET_TRANSFER',l_expense_to_asset);

	IF( NVL(l_expense_to_asset,'2') = '1') THEN
		IF (p_Transaction_Action_Id <> 2 and p_Transaction_Action_Id <>3) THEN
			IF p_Restrict_Subinventories_Code = 1 THEN
				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_item_sub_trk_val_v
				WHERE 	organization_id = p_Organization_Id  AND
			      		inventory_item_id = p_Inventory_Item_Id AND
					secondary_inventory_name like p_Secondary_Inventory_Name;
			ELSE

				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_subinventories_trk_val_v
		 		WHERE organization_Id = p_Organization_Id AND
		      		 secondary_inventory_name like p_Secondary_Inventory_Name;
			END IF;
		ELSE
			IF p_Restrict_Subinventories_Code = 1 THEN
				OPEN x_Zones FOR
				SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_item_sub_trk_val_v
				WHERE 	organization_id = p_Organization_Id  AND
			      		inventory_item_id = p_Inventory_Item_Id AND
					secondary_inventory_name like p_Secondary_Inventory_Name;
			ELSE
				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_subinventories_trk_val_v
		 		WHERE organization_Id = p_Organization_Id AND
		      		 secondary_inventory_name like p_Secondary_Inventory_Name;
			END IF;
		END IF;
	ELSE
		IF (p_Transaction_Action_Id <> 2 and p_Transaction_Action_Id <>3) THEN
		IF p_Restrict_Subinventories_Code = 1 THEN
				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_item_sub_val_v
				WHERE 	organization_id = p_Organization_Id  AND
			      		inventory_item_id = p_Inventory_Item_Id AND
					secondary_inventory_name like p_Secondary_Inventory_Name;
			ELSE

				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_subinventories_trk_val_v
		 		WHERE organization_Id = p_Organization_Id AND
		      		 secondary_inventory_name like p_Secondary_Inventory_Name;
			END IF;
		ELSE
			IF p_Restrict_Subinventories_Code = 1 THEN
				OPEN x_Zones FOR
				SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_item_sub_trk_val_v
				WHERE 	organization_id = p_Organization_Id  AND
			      		inventory_item_id = p_Inventory_Item_Id AND
					secondary_inventory_name like p_Secondary_Inventory_Name;
			ELSE
				OPEN x_Zones FOR
		 		SELECT secondary_inventory_name,description,asset_inventory
				FROM mtl_subinventories_trk_val_v
		 		WHERE organization_Id = p_Organization_Id AND
		      		 secondary_inventory_name like p_Secondary_Inventory_Name;
			END IF;
		END IF;
	END IF;
END GET_FROM_SUBS;


PROCEDURE GET_TO_SUB(x_Zones OUT NOCOPY /* file.sql.39 change */ t_genref,
		        p_organization_id IN NUMBER,
			p_secondary_inventory_name IN VARCHAR2) IS
BEGIN
     open x_Zones for
        sELECT secondary_inventory_name,description,asset_inventory
        FROM mtl_secondary_inventories
	WHERE 	organization_id = p_Organization_Id
	AND secondary_inventory_name <> p_secondary_inventory_name;
END GET_TO_SUB;

PROCEDURE GET_TO_SUB(x_to_sub OUT NOCOPY /* file.sql.39 change */ t_genref,
		     p_Organization_Id IN NUMBER,
		     p_Inventory_Item_Id IN NUMBER,
		     p_from_Secondary_Name IN VARCHAR2,
		     p_Restrict_Subinventories_Code IN NUMBER,
		     p_Secondary_Inventory_Name IN VARCHAR2,
		     p_From_Sub_Asset_Inventory IN VARCHAR2,
		     p_Transaction_Action_Id IN NUMBER,
		     p_To_Organization_Id IN NUMBER,
		     p_Serial_Number_Control_Code IN NUMBER)
		     --p_Serial IN VARCHAR2)
IS
    l_expense_to_asset VARCHAR2(1);
    l_Inventory_Asset_Flag VARCHAR2(1);
    l_org NUMBER;
    l_Restrict_Subinventories_Code NUMBER;
    l_From_Sub VARCHAR2(10);
    l_From_Sub_Asset_Inventory VARCHAR2(1);
BEGIN
    IF p_Transaction_Action_Id = 3 THEN
	l_org := p_To_Organization_Id;
	select restrict_subinventories_code
	into l_Restrict_Subinventories_Code
	from mtl_system_items
	where organization_id = l_org
	and inventory_item_id = p_Inventory_Item_Id;
    ELSE
	l_org := p_Organization_Id;
	l_Restrict_Subinventories_Code := p_Restrict_Subinventories_Code;
    END IF;

    IF p_Serial_Number_Control_Code not in (1, 6) THEN
       l_from_sub:=p_from_secondary_name;
       l_from_sub_asset_inventory:=p_from_sub_asset_inventory;
	--select current_subinventory_code
	--into l_From_Sub
	--from mtl_serial_numbers
	--where current_organization_id = l_org
	--and serial_number = p_Serial
	--and inventory_item_id = p_Inventory_Item_Id;

	--select asset_inventory
	--into l_From_Sub_Asset_Inventory
	--from mtl_secondary_inventories
	--where organization_id = l_org
	--and secondary_inventory_name = l_From_Sub;
    ELSE
	l_From_Sub_Asset_Inventory := p_From_Sub_Asset_Inventory;
    END IF;

    SELECT Inventory_Asset_Flag
    INTO l_Inventory_Asset_Flag
    FROM mtl_system_items
    WHERE inventory_item_id = p_Inventory_Item_Id
    AND organization_id = l_org;

    FND_PROFILE.GET('INV:EXPENSE_TO_ASSET_TRANSFER',l_expense_to_asset);
    IF (nvl(l_expense_to_asset,'2') = '1') THEN
	IF l_Restrict_Subinventories_Code = 1 THEN
	    OPEN x_to_sub FOR
            	SELECT secondary_inventory_name,description
            	FROM MTL_ITEM_SUB_VAL_V
            	WHERE organization_id = l_org
              	AND inventory_item_id  = p_Inventory_Item_Id
              	AND secondary_inventory_name like p_Secondary_Inventory_Name;
        ELSE
	    OPEN x_to_sub FOR
            	SELECT secondary_inventory_name,description
	        FROM MTL_SUBINVENTORIES_VAL_V
            	WHERE ORGANIZATION_ID = l_org
              	AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
       	END IF;
    ELSE
	IF l_Restrict_Subinventories_Code = 1 THEN
            IF l_Inventory_Asset_Flag = 'Y' THEN
              	IF l_From_Sub_Asset_Inventory = 1 THEN
               	  	OPEN x_to_sub FOR
				SELECT secondary_inventory_name,description
                   		FROM MTL_ITEM_SUB_VAL_V
                   		WHERE ORGANIZATION_ID = l_org
                    		AND INVENTORY_ITEM_ID = p_Inventory_Item_Id
                     		AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
              	ELSE
                	OPEN x_to_sub FOR
                   		SELECT secondary_inventory_name,description
                   		FROM MTL_ITEM_SUB_EXP_VAL_V
                   		WHERE ORGANIZATION_ID = l_org
                     		AND INVENTORY_ITEM_ID = p_Inventory_Item_Id
                     		AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
              	END IF;
           ELSE
		OPEN x_to_sub FOR
               		SELECT secondary_inventory_name,description
               		FROM MTL_ITEM_SUB_VAL_V
               		WHERE ORGANIZATION_ID = l_org
                 	AND INVENTORY_ITEM_ID = p_Inventory_Item_Id
                 	AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
            	END IF;
         ELSE
            IF l_Inventory_Asset_Flag = 'Y' THEN
               IF l_From_Sub_Asset_Inventory = 1 THEN
        	  OPEN x_to_sub FOR
                  SELECT secondary_inventory_name,description
                  FROM MTL_SUBINVENTORIES_VAL_V
                  WHERE ORGANIZATION_ID = l_org
                  AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
               ELSE
                  OPEN x_to_sub FOR
                  SELECT secondary_inventory_name,description
                  FROM MTL_SUB_EXP_VAL_V
                  WHERE ORGANIZATION_ID = l_org
                  AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
               END IF;
           ELSE
	       OPEN x_to_sub FOR
               SELECT secondary_inventory_name,description
               FROM MTL_SUBINVENTORIES_VAL_V
               WHERE ORGANIZATION_ID = l_org
               AND SECONDARY_INVENTORY_NAME like p_Secondary_Inventory_Name;
           END IF;
         END IF;
      END IF;
END GET_TO_SUB;



PROCEDURE GET_ORG(x_org OUT NOCOPY /* file.sql.39 change */ t_genref,
		  p_responsibility_id IN NUMBER,
		  p_resp_application_id IN NUMBER) IS
BEGIN
   open x_org FOR
	select organization_code, organization_name, organization_id
	from org_access_view
	where responsibility_id = p_responsibility_id
	and p_resp_application_id = p_resp_application_id
	order by organization_code;

END;

PROCEDURE GET_TO_ORG(x_Organizations OUT NOCOPY /* file.sql.39 change */ t_genref,
		     p_From_Organization_Id IN NUMBER) IS

BEGIN
     OPEN x_Organizations FOR
        SELECT
      a.to_organization_id,b.organization_code,c.name, a.intransit_type
      FROM mtl_interorg_parameters a, mtl_parameters b,hr_all_organization_units c
	WHERE a.from_organization_id = p_From_Organization_Id AND
      a.to_organization_id = b.organization_id
      AND a.to_organization_id = c.organization_id
      order by 2;



END GET_TO_ORG;

PROCEDURE GET_VALID_UOMS(x_UOMS OUT NOCOPY /* file.sql.39 change */ t_genref,
			 p_Organization_Id IN NUMBER,
			 p_Inventory_Item_Id IN NUMBER,
			 p_UOM_Code IN VARCHAR2) IS
BEGIN

    OPEN x_UOMS FOR
	 SELECT uom_Code, unit_of_measure, description FROM mtl_item_uoms_view
	 WHERE organization_id = p_Organization_Id AND
	       inventory_item_id = p_Inventory_Item_Id AND
 	       uom_Code like p_UOM_Code;

END GET_VALID_UOMS;

PROCEDURE GET_VALID_LOTS(x_Lots OUT NOCOPY /* file.sql.39 change */ t_genref,
			 p_Organization_Id IN NUMBER,
			 p_Inventory_Item_Id IN NUMBER,
			 p_Lot IN VARCHAR2) IS
BEGIN
   OPEN x_Lots FOR
	 SELECT Lot_Number,to_char(expiration_date,'MM-DD-YYYY')
         FROM mtl_lot_numbers
	 WHERE organization_id = p_Organization_Id AND
	       inventory_item_id = p_Inventory_Item_Id AND
	       lot_number like (p_lot);

END GET_VALID_LOTS;

PROCEDURE GET_VALID_LOTS(x_Lots OUT NOCOPY /* file.sql.39 change */ t_genref,
			 p_Organization_Id IN NUMBER,
			 p_Inventory_Item_Id IN NUMBER,
			 p_subcode IN VARCHAR2,
			 p_revision IN VARCHAR2,
			 p_locatorid IN NUMBER,
			 p_Lot IN VARCHAR2) IS
BEGIN
   OPEN x_Lots FOR
	 SELECT b.Lot_Number,to_char(b.expiration_date,'MM-DD-YYYY')
         FROM mtl_onhand_quantities_detail a, mtl_lot_numbers b
-- Bug 2687570, use MOQD instead of MOQ because consigned stock is not visible in MOQ
	 WHERE a.organization_id = p_Organization_Id AND
     a.inventory_item_id = p_Inventory_Item_Id AND
     a.subinventory_code = p_subcode AND
     Nvl(a.revision, '##') = Nvl(p_revision,'##') AND
     Nvl(a.locator_id, '-1') = Nvl(p_locatorid ,'-1')AND
     a.lot_number = b.lot_number AND
     a.lot_number like (p_lot);

END GET_VALID_LOTS;









PROCEDURE GET_VALID_REVS(x_Revs OUT NOCOPY /* file.sql.39 change */ t_genref,
			 p_Organization_Id IN NUMBER,
			 p_Inventory_Item_Id IN NUMBER,
			 p_Revision IN VARCHAR2) IS
BEGIN
    OPEN x_Revs FOR
      SELECT revision, effectivity_date, Nvl(description,'')
      FROM mtl_item_revisions
      WHERE organization_Id = p_Organization_Id AND
	       inventory_item_id = p_Inventory_Item_Id AND
	       revision like (p_revision);

END GET_VALID_REVS;


PROCEDURE GET_VALID_SERIAL_REC_2(x_RSerials IN OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Serial_Number IN VARCHAR2) IS
BEGIN
    OPEN x_RSerials FOR
     	select serial_number,current_subinventory_code,current_locator_id, lot_number
 	from mtl_serial_numbers
	where Current_Organization_Id = p_Current_Organization_Id
	AND inventory_item_id = p_Inventory_Item_Id and current_status = 1
	and serial_number like p_Serial_Number;

END GET_VALID_SERIAL_REC_2;

PROCEDURE GET_VALID_SERIAL_REC_5(x_RSerials IN OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Current_Subinventory_Code IN VARCHAR2,
				 p_Current_Locator_Id IN NUMBER,
				 p_Lot_Number IN VARCHAR2,
				 p_Serial_Number IN VARCHAR2) IS
BEGIN

    OPEN x_RSerials FOR
	select serial_number,current_subinventory_code, current_locator_id,lot_number
	from mtl_serial_numbers
	where Current_Organization_Id = p_Current_Organization_Id
	and inventory_item_id = p_Inventory_Item_Id and current_status = 4
	and serial_number like p_serial_number;

    IF x_RSerials IS NULL and p_Serial_Number IS NOT NULL THEN
	OPEN x_RSerials FOR
	    select p_Serial_Number,p_Current_Subinventory_Code,p_Current_Locator_Id,
		   p_Lot_Number
	    from DUAL;
    END IF;

END GET_VALID_SERIAL_REC_5;


--During an issue, if it is the first serial number then
--we can accept any serial that resides in stores
--however, after the first serial has been scanned we must
--make sure that all subsequent serials are from the same
--locator and same sub.


PROCEDURE GET_VALID_SERIAL_ISSUE(x_RSerials OUT NOCOPY /* file.sql.39 change */ t_genref,
				 p_Current_Organization_Id IN NUMBER,
				 p_Current_Subinventory_Code IN VARCHAR2,
				 p_Current_Locator_Id IN NUMBER,
				 p_Current_Lot_Number IN VARCHAR2,
				 p_Inventory_Item_Id IN NUMBER,
				 p_Serial_Number IN VARCHAR2)
IS
BEGIN

    IF p_Current_Subinventory_Code IS NULL THEN
 	OPEN x_RSerials FOR
	    SELECT
	  a.serial_number,a.current_Subinventory_code,Nvl(a.current_locator_id,-1),
	  a.lot_number, a.revision ,b.expiration_date
 	    from mtl_serial_numbers a, mtl_lot_numbers b
	    where a.Current_organization_Id = p_Current_Organization_Id
	    and a.inventory_item_id = p_Inventory_Item_Id
	  and a.current_status = 3
	  AND a.lot_number = b.lot_number
	    and a.serial_number like p_serial_number;

 ELSE
       OPEN x_RSerials FOR
					select a.serial_number,
					a.current_subinventory_code,
					Nvl(a.current_locator_id,-1),
					a.lot_number, a.revision,
					b.expiration_date
	    from mtl_serial_numbers a , mtl_lot_numbers b
	    where a.Current_organization_Id = p_Current_Organization_Id
	    and a.inventory_item_id = p_Inventory_Item_Id
            and a.current_status = 3
	    and a.serial_number like p_serial_number
	    and a.current_subinventory_code = p_current_subinventory_code
	 and Nvl(a.current_locator_id,-1) = Decode(p_current_locator_id,'-1',Nvl(a.current_locator_id,-1),p_current_locator_id)
	 AND a.lot_number = b.lot_number;

   END IF;

END GET_VALID_SERIAL_ISSUE;

PROCEDURE GET_VALID_SERIALS(x_RSerials OUT NOCOPY /* file.sql.39 change */ t_genref,
			    p_Serial_Number_Control_Code IN NUMBER,
			    p_Inventory_Item_Id IN NUMBER,
		   	    p_Current_Organization_Id IN NUMBER,
			    p_Current_Subinventory_Code IN VARCHAR2,
			    p_Current_Locator_Id IN NUMBER,
			    p_Lot_Number IN VARCHAR2,
			    p_Transaction_Action_Id IN NUMBER,
			    p_Serial_Number IN VARCHAR2) IS

BEGIN
--Predefined and Receipt
    IF p_Transaction_Action_Id = 27 and p_Serial_Number_Control_Code = 2 THEN
       GET_VALID_SERIAL_REC_2(x_RSerials,
		       p_Current_Organization_Id,
		       p_Inventory_Item_Id,
		       p_Serial_Number);
    ELSIf p_Transaction_Action_Id = 27 and p_Serial_Number_Control_Code = 5 THEN
     --Dynamic serial entry upon receipt and Receipt
	GET_VALID_SERIAL_REC_5(x_RSerials,
		       p_Current_Organization_Id,
		       p_Inventory_Item_Id,
		       p_Current_Subinventory_Code,
	   	       p_Current_Locator_Id,
		       p_Lot_Number,
		       p_Serial_Number);
   ELSE
    --Issue or transfer transaction
	GET_VALID_SERIAL_ISSUE(x_RSerials,
			p_Current_Organization_Id,
			p_Current_Subinventory_Code,
			p_Current_Locator_Id,
			p_Lot_Number,
			p_Inventory_Item_Id,
			p_Serial_Number);

   END IF;
END GET_VALID_SERIALS;
END INV_TRANSACTION_LOVS;

/
