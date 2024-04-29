--------------------------------------------------------
--  DDL for Package Body CS_INVENTORY_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_INVENTORY_TXNS" as
/* $Header: csdrtxnb.pls 115.5 99/07/16 08:57:07 porting ship $ */
/*******************************************************************************
	--
	--Private global variables and functions
	--
*******************************************************************************/

	procedure get_who_info
	(
		p_login_id	out	number,
		p_user_id		out	number,
		p_sys_dt		out	date
	) is
	begin
		p_login_id := FND_GLOBAL.Login_Id;
		p_user_id := FND_GLOBAL.User_Id;
		p_sys_dt := sysdate;
	end get_who_info;
	--
	--
/*******************************************************************************
	--
	--Public functions
	--
*******************************************************************************/
-- PROCEDURE to process all the interface records :
--
PROCEDURE Get_Default_Values (p_mfg_org_Id			OUT	NUMBER,
						p_Error_Flag			OUT	VARCHAR2,
						P_Error_Profile		OUT	VARCHAR2,
						p_transaction_Type		OUT	NUMBER,
						p_service_item_flex_code	OUT	VARCHAR2,
						P_Subinventory_Code		IN OUT	VARCHAR2,
						P_Source_Id              IN OUT  NUMBER) IS

p_transaction_action_id NUMBER;

BEGIN

	p_mfg_org_id :=
			FND_Profile.Value_Specific('CS_FIELD_SERVICE_ORGANIZATION');

	IF (NVL(p_mfg_org_id,0) = 0) THEN
		p_error_flag	:= 'Y';
		p_error_profile := 'CS_FIELD_SERVICE_ORGANIZATION';
		return;
	END IF;

	/* Get Transaction Type profile. If it is not set, error out **/

	p_transaction_type :=
			FND_Profile.Value_Specific('CS_FIELD_SERVICE_TRANSACTION_TYPE');
	IF (NVL(p_transaction_type,0) = 0) THEN
		p_error_flag := 'Y';
		p_error_profile := 'CS_FIELD_SERVICE_TRANSACTION_TYPE';
		return;
	END IF;

-- Added by Gmahajan 18th Nov'98
-- If transaction_action_id = 1 for the transaction type defined,
-- specifies Issue from Inventory. Only when
-- transaction_action_id = 1, the user should be allowed to inventory transactions

	SELECT transaction_action_id
	INTO   p_transaction_action_id
	FROM mtl_transaction_types
	WHERE transaction_type_id = to_number(fnd_profile.value_specific('CS_FIELD_SERVICE_TRANSACTION_TYPE'));

	IF p_transaction_action_id <> 1 THEN
	   p_error_flag := 'Y';
	   return;
     END IF;

	p_service_item_flex_code := FND_PROFILE.Value('SERVICE_ITEM_FLEX_CODE');

	/* Get Profile value of subinventory. If it exists,
		copy it as default value
		to the transactions block and set the corresponding
		locator properties. **/

	IF (p_Subinventory_Code IS NULL) THEN
		p_subinventory_Code :=
			FND_Profile.Value_Specific('CS_FIELD_SERVICE_SUBINVENTORY');
	END IF;

	p_error_flag := 'N';

End Get_Default_Values;

/*****************************************************************************/

Procedure Insert_Mtl_Interface_Records (
				P_Detail_Txn_Id		IN	NUMBER,
				P_Estimate_Id			IN 	NUMBER,
				P_Estimate_Detail_Id	IN	NUMBER,
				P_Organization_Id   	IN 	NUMBER,
				P_Inventory_Item_Id		IN	NUMBER,
				P_Uom_Code			IN	VARCHAR2,
				P_Quantity			IN	NUMBER,
				P_Revision			IN	VARCHAR2,
				p_serial_number		IN	VARCHAR2,
				p_lot_number			IN	NUMBER,
				P_Subinventory_Code		IN	VARCHAR2,
				P_Locator_Id			IN	NUMBER,
				p_transaction_type_id	IN	NUMBER) IS

	CURSOR	Mtl_Txn_Details IS
	SELECT	Transaction_Source_Type_Id,
			Transaction_Action_Id
	FROM		MTL_TRANSACTION_TYPES
	WHERE	TRANSACTION_TYPE_ID	= p_transaction_Type_Id;

	CURSOR	MTl_Item_Account IS
	SELECT	Cost_Of_Sales_Account
 	  FROM	MTL_SYSTEM_ITEMS
	WHERE	Inventory_Item_Id	= P_Inventory_Item_Id
	  AND	Organization_Id	= P_Organization_Id;

	l_transaction_interface_id	NUMBER;
	l_quantity				NUMBER;
	l_user_id					NUMBER;
	l_login_id				NUMBER;
	l_serial_number_ref			NUMBER;
	l_transaction_source_type_id	NUMBER;
	l_transaction_action_id		NUMBER;
	l_cost_of_sales_account		NUMBER;
	l_sys_dt					DATE;

BEGIN
	get_who_info(l_login_id,l_user_id,l_sys_dt);

	SELECT	Mtl_Material_Transactions_S.NextVal
	  INTO	l_transaction_interface_id
	  FROM	DUAL;

		/** Since it is an issue, Inventory expects a negative
			quantity. **/
	l_quantity := p_quantity * -1;

	OPEN	Mtl_Txn_Details;
	FETCH	Mtl_Txn_Details
	 INTO	l_transaction_source_type_id,
			l_transaction_action_id;

	CLOSE	Mtl_txn_Details;

	OPEN		Mtl_Item_Account;
	FETCH	Mtl_Item_Account
	INTO		l_cost_of_sales_account;
	CLOSE	MTL_Item_Account;

	Insert into MTL_TRANSACTIONS_INTERFACE (
			Transaction_Interface_Id,
			Source_Code,			Organization_Id,
			Source_Line_Id, 		Source_Header_Id,
			Process_flag, 			Transaction_Mode,
			Lock_Flag,			Last_Update_Date,
			Last_Updated_By,		Creation_Date,
			Created_By,			Last_Update_Login,
			Inventory_Item_Id,		Revision,
			Transaction_Quantity,
			Transaction_UOM, 		Transaction_Date,
			Subinventory_Code,		Locator_Id,
			Transaction_Source_Type_Id, Transaction_Action_Id,
			Transaction_Type_Id,
			Transaction_Reference, 	Distribution_Account_Id)
	Values (
			l_transaction_interface_Id,
			'SERVICE',			p_organization_id,
			p_Estimate_Detail_Id,	p_estimate_id,
			1,					3,
			2,					sysdate,
			l_user_id,			sysdate,
			l_user_id,			l_login_id,
			p_inventory_Item_id,	p_revision,
			l_quantity,			p_uom_code,
			sysdate,
			p_subinventory_code,	p_locator_id,
			l_transaction_source_type_id,
			l_transaction_action_id,	p_transaction_type_id,
			p_estimate_id,			l_cost_of_sales_account);

	/** If the item is under lot control, enter a record in
	    MTL_TRANSACTION_LOTS_INTERFACE table.
	    01/23/98 - skolhatk **/

	IF (p_serial_number IS NOT NULL) THEN
		l_serial_number_ref := l_transaction_interface_id;
	ELSE
		l_serial_number_ref := NULL;
	END IF;

	IF (p_lot_number IS NOT NULL) THEN
		Insert into MTL_Transaction_Lots_Interface(
				Transaction_Interface_Id,	Source_Code,
				Source_Line_Id,			Lot_Number,
				Transaction_Quantity,
				Serial_Transaction_Temp_Id,	Last_Update_Date,
				Last_Updated_By,			Creation_Date,
				Created_By,				Last_Update_Login,
				Process_Flag)
		Values(
				l_transaction_interface_Id,	'SERVICE',
				p_Estimate_Detail_Id,		p_lot_number,
				-1,
				l_serial_number_ref, 		sysdate,
				l_user_id,				sysdate,
				l_user_id,				l_login_id,
				1);
	END IF;

	/** If the item is serialized, enter a record in
	    MTL_SERIAL_NUMBERS_INTERFACE table.
	    11/21/97 - skolhatk **/

	IF (p_serial_Number IS NOT NULL) THEN
		Insert into Mtl_Serial_Numbers_Interface (
				Transaction_Interface_Id,	Source_Code,
 				Source_Line_Id,			Last_Update_Date,
 				Last_Updated_By, 			Creation_Date,
 				Created_By, 				Last_Update_Login,
 				Fm_Serial_Number, 			Process_Flag)
 		Values(
				l_transaction_interface_Id,	'SERVICE',
				p_Estimate_Detail_Id,		sysdate,
				l_user_id,               	sysdate,
				l_user_id,               	l_login_id,
				p_serial_number,			1);
	END IF;


	Update Cs_Est_Details_Mtl_Txns
	   Set Interface_to_Inventory_Flag = 'Y'
	   Where Detail_Transaction_Id = p_Detail_Txn_Id;

End Insert_Mtl_Interface_Records ;

end cs_inventory_txns;

/
