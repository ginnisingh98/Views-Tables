--------------------------------------------------------
--  DDL for Package Body WSMPLBJT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLBJT" AS
/* $Header: WSMLBJTB.pls 120.3 2006/02/10 19:02:57 nlal noship $ */

x_exp_date 	DATE;


FUNCTION Material_Issue (
                          X_Wip_Entity_Id 		IN NUMBER,
                          X_Inventory_Item_Id 		IN NUMBER,
                          X_Organization_id 		IN NUMBER,
                          X_Quantity 			IN NUMBER,
                          X_Acct_Period_Id 		IN NUMBER,
                          X_Lot_Creation_Id 		IN NUMBER,
                          X_Lot_Number 			IN VARCHAR2,
                          X_Subinventory 		IN VARCHAR2,
                          X_Locator_Id 			IN NUMBER,
                          X_Revision 			IN VARCHAR2,
                          X_err_code 			OUT NOCOPY NUMBER,
                          X_err_msg 			OUT NOCOPY VARCHAR2,
                          X_passed_header_id 		IN  NUMBER DEFAULT null,
                          -- ST : Serial Support Project --
                          -- Return the transaction temp id also... --
                          X_Temp_id			OUT NOCOPY  NUMBER
                          -- ST : Serial Support Project --
                          )
RETURN NUMBER IS

X_header_id NUMBER;
-- ST : Serial Support Project : Commenting the below declaration --
-- X_Temp_Id NUMBER;
-- ST : Serial Support Project --
X_User_Id NUMBER := FND_GLOBAL.USER_ID;
X_Login_Id NUMBER := FND_GLOBAL.LOGIN_ID;
X_Op_Seq NUMBER;
X_Date DATE := SYSDATE;
X_Uom VARCHAR2(3);
X_type_id NUMBER;


BEGIN

    IF ( X_passed_header_id is null ) THEN

	SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
	INTO X_Header_Id
	FROM DUAL;

    ELSE
	X_Header_id := X_passed_header_id;

    END IF;

    SELECT MTL_MATERIAL_TRANSACTIONS_S.NEXTVAL
    INTO   X_Temp_Id
    FROM   DUAL;

    -- Select the Primary UOM for this item

    SELECT primary_uom_code
    INTO   X_UOM
    FROM   MTL_SYSTEM_ITEMS
    WHERE  INVENTORY_ITEM_ID = X_Inventory_Item_Id
    AND    ORGANIZATION_ID = X_Organization_Id;

    -- Select the first operation from the WIP routing.
    -- x_op_seq = 10 always in the changed solution.
/*
SELECT min(operation_seq_num)
INTO x_op_seq
FROM wip_operations
where wip_entity_id = X_Wip_Entity_Id
and organization_id = X-organization_Id;
*/

    -- We use the user-defined transaction type
    -- Changed to miscellaneous transaction types

/*
SELECT transaction_type_id
INTO x_type_id
FROM MTL_TRANSACTION_TYPES
WHERE TRANSACTION_TYPE_NAME = 'WSM WIP Issue';
*/

    insert into mtl_material_transactions_temp (
        last_update_date,
        creation_date,
        last_updated_by,
        created_by,
        last_update_login,
        transaction_header_id,
        transaction_source_id,
        inventory_item_id,
        organization_id,
        revision,
        subinventory_code,
        locator_id,
        transaction_quantity,
        primary_quantity,
        transaction_uom,
        transaction_type_id,
        transaction_action_id,
        transaction_source_type_id,
        transaction_date,
        acct_period_id,
        source_code,
        source_line_id,
        wip_entity_type,
        negative_req_flag,
        operation_seq_num,
        wip_supply_type,
        wip_commit_flag,
        process_flag,
        posting_flag,
        transaction_temp_id)
    values(
        X_date,   		/* LAST_UPDATE_DATE */
        X_date,   		/* CREATION_DATE */
        X_User_Id, 		/* LAST_UPDATED_BY */
        X_User_Id, 		/* CREATED_BY */
        X_Login_Id,
        X_Header_Id, 		/* TRANSACTION_HEADER_ID */
        X_Wip_Entity_Id, 	/* TRANSACTION_SOURCE_ID */
        X_Inventory_Item_Id,   /* INVENTORY_ITEM_ID */
        X_Organization_Id, 	/* ORGANIZATION_ID */
        X_Revision, 			/* REVISION */
        X_Subinventory, 	/* SUBINVENTORY_CODE */
        X_Locator_Id,
        -1 * X_Quantity,	/* TRANSACTION_QUANTITY */
        -1 * X_Quantity,	/* PRIMARY_QUANTITY */
        X_Uom,			/* UNIT_OF_MEASURE */
        35,			/* TRANSACTION_TYPE_ID */
        1, 			/* TRANSACTION_ACTION_ID */
        5,			/* TRANSACTION_SOURCE_TYPE_ID */
        X_date,			/* TRANSACTION_DATE */
        X_Acct_Period_Id,	/* ACCT_PERIOD_ID */
        'WSM',
        to_char(X_Lot_Creation_Id), /* SOURCE_LINE_ID */
        5,			/* WIP_ENTITY_TYPE */
        1, 			/* neg req flag */
        10,	 		/* op seq */
        '', 			/* supply type */
        'N',			/* WIP_COMMIT_FLAG */
        'Y',			/* PROCESS_FLAG */
        'Y',			/* POSTING_FLAG */
        X_temp_id		/* Transaction Temp Id */
    );

    INSERT INTO MTL_TRANSACTION_LOTS_TEMP (
        transaction_temp_id,
	-- ST : Serial Support Project --
	SERIAL_TRANSACTION_TEMP_ID,
	-- ST : Serial Support Project --
        last_update_date,
        creation_date,
        last_updated_by,
        created_by,
        last_update_login,
        transaction_quantity,
        primary_quantity,
        lot_number
    ) values (
        X_temp_id,
	-- ST : Serial Support Project --
	x_temp_id,
	-- ST : Serial Support Project --
        X_date,
        X_date,
        X_User_Id,
        X_User_Id,
        X_Login_Id,
        -1 * X_quantity,
        -1 * X_quantity,
        X_lot_number
    );

    return(X_Header_Id);

EXCEPTION WHEN OTHERS THEN

    X_err_code := SQLCODE;
    X_err_msg :=  'WSMPLBJT.Material_Issue  '|| SUBSTR(SQLERRM,1,60);
    return(0);

END Material_Issue;


FUNCTION get_assembly(
	X_component_item_id IN NUMBER,
	X_organization_id IN NUMBER,
	X_err_code OUT NOCOPY NUMBER,
	X_err_msg OUT NOCOPY VARCHAR2)
return NUMBER IS

x_assembly_id NUMBER := 0;

BEGIN

	select unique wcv.assembly_item_id
	into   x_assembly_id
	from   wsm_components_v wcv,
	       mtl_system_items msi
	where  wcv.component_item_id = X_component_item_id
	and    wcv.organization_id = X_organization_id
	and    msi.organization_id = X_organization_id
	and    msi.inventory_item_id = wcv.assembly_item_id
	and    msi.lot_control_code = 2 ;
	return(x_assembly_id);

EXCEPTION
	WHEN OTHERS THEN
		X_err_code := SQLCODE;
		X_err_msg :=  'WSMPLBJT.GET_ASSEMBLY  '|| SUBSTR(SQLERRM,1,60);
		RETURN (0);
END get_assembly;


FUNCTION get_id(
	X_item_name IN VARCHAR2,
	X_organization_id IN NUMBER,
	X_err_code OUT NOCOPY NUMBER,
	X_err_msg OUT NOCOPY VARCHAR2 )
return NUMBER IS

	x_temp_id NUMBER := 0;
BEGIN

-- abedajna 10/11/00
/* 	select inventory_item_id
**	into x_temp_id
**	from mtl_system_items
**	where segment1=X_item_name
**	and organization_id = X_organization_id;
*/

-- modification by abedajna 10/11/00

	select inventory_item_id
	into   x_temp_id
	from   mtl_system_items_kfv
	where  concatenated_segments = X_item_name
	and    organization_id = X_organization_id;

	return(x_temp_id);

EXCEPTION
	WHEN OTHERS THEN
		X_err_code := SQLCODE;
		X_err_msg :=  'WSMPLBJT.GET_ID  '|| SUBSTR(SQLERRM,1,60);
		RETURN(0);

END get_id;


FUNCTION next_job_name (
	X_Job_Name IN VARCHAR2,
	X_Organization_Id IN NUMBER,
	X_Item_Id IN NUMBER,
	X_Count IN NUMBER,
	X_err_code OUT NOCOPY NUMBER,
	X_err_msg OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

temp_name VARCHAR2(240);
dummy NUMBER;
ct NUMBER := X_Count;
x_sep VARCHAR2(30);

BEGIN

	SELECT nvl(NEW_LOT_SEPARATOR,'-')
	INTO   x_sep
	FROM   WSM_PARAMETERS
	WHERE  ORGANIZATION_ID =  X_Organization_Id;

	LOOP
		temp_name := X_Job_Name || x_sep || to_char(ct);
-- abb modification
		if ct = 0 then
			temp_name := X_Job_Name;
		end if; -- ct = 0

		SELECT 1
		INTO dummy
		FROM DUAL
		WHERE (EXISTS(
			SELECT 1
			FROM   wip_entities
			where  wip_entity_name = temp_name
			and    organization_id = X_Organization_id)
                /* Bugfix 4317714: Add second where clause to also check for mtl_lot_numbers if uniqueness constraint is across items */
                       OR EXISTS(
			 SELECT 1
			 FROM mtl_lot_numbers
			 where lot_number = temp_name
			 and organization_id = X_Organization_id
			 and inventory_item_id =  X_Item_Id));
		/* End bugfix 4317714 */
		ct := ct + 1;

	END LOOP;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		return(ct);

	WHEN OTHERS THEN
		X_err_code := SQLCODE;
		X_err_msg :=  'WSMPLBJT.NEXT_JOB_NAME  '|| SUBSTR(SQLERRM,1,60);
		return(ct);

END next_job_name;

END WSMPLBJT;

/
