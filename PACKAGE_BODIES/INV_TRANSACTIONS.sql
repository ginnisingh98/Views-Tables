--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTIONS" AS
/* $Header: INVVMWAB.pls 120.1 2005/06/11 07:26:47 appldev  $ */


/****************************************************************************************/
/***********************LINE_INTERFACE_INSERT PROCEDURE*********************************/
/****************************************************************************************/
/**This procedure Inserts lines related transaction information in the                 **/
/**mtl_transactions_interface table                                                    **/
/**USED BY: ON_SUBMIT and ON_SERIAL Procedures                                         **/
/****************************************************************************************/
/****************************************************************************************/


PROCEDURE LINE_INTERFACE_INSERT(   p_Inventory_Item_Id IN NUMBER,
				   p_Item_Revision IN VARCHAR2,
				   p_Organization_Id IN NUMBER,
				   p_Transaction_Source_Id IN NUMBER,
				   p_Transaction_Action_Id IN NUMBER,
				   p_From_Subinventory_Code IN VARCHAR2,
				   p_To_Subinventory_Code IN VARCHAR2,
				   p_From_Locator_Id IN NUMBER,
				   p_To_Locator_Id IN NUMBER,
				   p_To_Organization IN NUMBER,
				   p_Transaction_Type_Id IN NUMBER,
				   p_Transaction_Source_Type_Id IN NUMBER,
				   p_Transaction_Quantity IN NUMBER,
      				   p_Transaction_UOM IN VARCHAR2,
      				   p_Transaction_Date IN DATE,
				   p_Reason_Id IN NUMBER,
				   p_User_Id IN NUMBER,
				   x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				   x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
l_dist_acct_id NUMBER; --Accounting info
l_source_id NUMBER;
BEGIN

IF p_Transaction_Source_Type_Id = 6 THEN
l_source_id := p_Transaction_Source_Id;
l_dist_acct_id :=NULL;

ELSIF p_Transaction_Source_Type_Id = 13 THEN
l_source_id :=NULL;
l_dist_acct_id := p_Transaction_Source_Id;
END IF;



--INSERTING VALUES INTO MTL_TRANSACTIONS_INTERFACE

	Insert into MTL_TRANSACTIONS_INTERFACE
     (
      transaction_interface_id,
      transaction_header_id,
      Source_Code,
      Source_Line_Id,
      Source_Header_Id,
      Process_flag,
      Transaction_Mode,
      Lock_Flag,
      Inventory_Item_Id,
      Organization_id,
      Subinventory_Code,
      Transfer_Subinventory,
      Locator_Id,
      Transfer_Locator,
      Transfer_Organization,
      Transaction_Type_Id,
      Transaction_Source_Type_Id,
      --transaction_source_name,
      Transaction_Action_Id,
      Transaction_Quantity,
      Transaction_UOM,
      Transaction_Date,
      Last_Update_Date,
      Last_Updated_By,
      Creation_Date,
      Created_By,
      reason_id,
      transaction_source_id,
      revision,
      distribution_account_id
     )
     Values (
             G_Interface_Id,          	-- Global Variable set/unset by On_Submit and On_Serial
             G_Header_Id,         	-- Same as above
             1,                		-- Source_Code,
             -1,                	-- Source_Line_Id,
             -1,                	-- Source_Header_Id,
             1,                 	-- Process_flag,
             1,                 	-- Transaction_Mode,
             2,                 	-- Lock_Flag,
             p_Inventory_Item_Id,       -- Inventory_Item_Id,
             p_Organization_Id,        	-- Organization_Id for
             p_From_Subinventory_Code,  -- Subinventory_Code
	     p_To_Subinventory_Code,    -- Transfer_Subinventory
	     p_From_Locator_Id,         -- Locator_ID
	     p_To_Locator_Id,		-- Transfer_Locator
	     p_To_Organization,
             p_Transaction_Type_Id,	-- Transaction_Type_Id,
             p_Transaction_Source_Type_Id,-- Transaction_Source_Type_Id,
            --'OnLine API Testing',      -- transaction_source_name
            -- 12831,             	-- Transaction_Source_id,is gl_code_combinations.code_combination_id
             p_Transaction_Action_Id,   -- Transaction_Action_Id
             p_Transaction_Quantity,   	-- Transaction_Quantity,
             p_Transaction_UOM, 	-- Transaction_UOM,
             p_Transaction_Date,   	-- Transaction_Date,
             sysdate,           	-- Last_Update_Date,
             p_User_Id,              	-- Last_Updated_By,
             sysdate,           	-- Creation_Date,
             p_User_Id,              	-- Created_By,
             p_Reason_Id,     	  	-- reason id,
	     l_source_id,    -- Transaction Source Id
	     p_Item_Revision,		--Inventory Item Revision
             l_dist_acct_id             -- distribution account
	     );

x_Message := ' ';
x_Status := 'C';


END;



/****************************************************************************************/
/***********************LOT_INTERFACE_INSERT PROCEDURE  *********************************/
/****************************************************************************************/
/**This procedure Inserts lot related transaction information in the                   **/
/**mtl_lot_numbers_interface table                                                     **/
/**USED BY: ON_SUBMIT and ON_SERIAL Procedures                                         **/
/****************************************************************************************/
/****************************************************************************************/

PROCEDURE LOT_INTERFACE_INSERT(p_Transaction_Quantity IN NUMBER,
			       p_Lot_Number IN VARCHAR2,
			       p_User_Id IN NUMBER,
			       p_serial_number_control_code IN NUMBER)

IS
BEGIN
--INSERTING VALUES INTO MTL_TRANSACTION_LOTS_INTERFACE

IF p_serial_number_control_code <>1 AND p_serial_number_control_code <>6 THEN

	Insert into MTL_TRANSACTION_LOTS_INTERFACE
       (
       transaction_interface_id,
       Source_Code,
       Source_Line_Id,
       Process_Flag, --Why is this one a VARCHAR2 whereas the rest are NUMBERs
       Last_Update_Date,
       Last_Updated_By,
       Creation_Date,
       Created_By,
       Lot_Number,
       Transaction_Quantity,
       Serial_transaction_temp_id
       )
       Values (
	  	G_Header_Id,  --Global Variable (set and unset in ON_SUBMIT and ON_SERIAL procs
		1,
		-1,
		'Y',
		sysdate,
		p_User_Id,
		sysdate,
		p_User_Id,
		p_Lot_Number,
		p_Transaction_Quantity,
		G_Serial_Id
	      );
ELSE
Insert into MTL_TRANSACTION_LOTS_INTERFACE
       (
       transaction_interface_id,
       Source_Code,
       Source_Line_Id,
       Process_Flag, --Why is this one a VARCHAR2 whereas the rest are NUMBERs
       Last_Update_Date,
       Last_Updated_By,
       Creation_Date,
       Created_By,
       Lot_Number,
       Transaction_Quantity,
       Serial_transaction_temp_id
       )
       Values (
	  	G_Header_Id,  --Global Variable (set and unset in ON_SUBMIT and ON_SERIAL procs
		1,
		-1,
		'Y',
		sysdate,
		p_User_Id,
		sysdate,
		p_User_Id,
		p_Lot_Number,
		p_Transaction_Quantity,
		NULL
	      );

END IF;

END;



/****************************************************************************************/
/***********************SERIAL_INTERFACE_INSERT PROCEDURE********************************/
/****************************************************************************************/
/**This procedure Inserts SN related transaction information in the                    **/
/**mtl_serial_numbers_interface table                                                  **/
/**USED BY: ON_SUBMIT and ON_SERIAL Procedures                                         **/
/****************************************************************************************/
/****************************************************************************************/



PROCEDURE SERIAL_INTERFACE_INSERT(p_From_Serial IN VARCHAR2,
				  p_To_Serial   IN VARCHAR2,
				  p_User_Id     IN NUMBER,
				  p_lot_control_code IN NUMBER)

IS
l_header_id NUMBER;
BEGIN
--INSERTING VALUES INTO MTL_SERIAL_NUMBERS_INTERFACE

IF p_lot_control_code = 1 THEN l_header_id := G_Interface_Id;
ELSE l_header_id := G_Serial_Id;
END IF;

    Insert into MTL_SERIAL_NUMBERS_INTERFACE
    (
      transaction_interface_id,
      Source_Code,
      Source_Line_Id,
      Process_flag, --Is this the same process_flag as above?
      Last_Update_Date,
      Last_Updated_By,
      Creation_Date,
      Created_By,
      Fm_Serial_Number,
      To_Serial_Number
     )
     Values (
             l_header_id,          	-- transaction_interface_id
             1,                		-- Source_Code,
             -1,                	-- Source_Line_Id,
             1,                 	-- Process_flag,
             sysdate,           	-- Last_Update_Date,
             p_User_Id,              	-- Last_Updated_By,
             sysdate,           	-- Creation_Date,
             p_User_Id,              	-- Created_By,
             p_From_Serial,     	-- from_Serial_Number,
	     p_To_Serial		-- To_Serial_Number
             );


END SERIAL_INTERFACE_INSERT;




/****************************************************************************************/
/******************************* PROCESS PROCEDURE **************************************/
/****************************************************************************************/
/**This procedure Actually processes the transaction online using information inserted **/
/**In the interface tables using the Mobile transactions form.                         **/
/****************************************************************************************/
/****************************************************************************************/

PROCEDURE PROCESS(x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		  x_Status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
IS
l_error_code VARCHAR2(80);
l_date_start DATE;
BEGIN
l_date_start :=sysdate;

   commit;
   --fnd_global.apps_initialize(1001, 20634, 401);

   IF mtl_online_transaction_pub.process_online
   (p_transaction_header_id => G_Header_Id,
    p_timeout => 120,
    p_error_code => l_error_code,
    p_error_explanation => x_Message)
   THEN
	x_Status := 'C';
       --dbms_output.put_line('Transaction processed');
       x_Message := 'Transaction Completed Successfully(start: '||to_char(l_date_start,'hh24:MI:SS')||' end: '||to_char(sysdate,'hh24:MI:SS')||')';
   ELSE
	x_Status := 'E';
       --dbms_output.put_line('Transaction failed:'||l_error_code);
       --dbms_output.put_line('Transaction failed:'||x_Message);
   END IF;
END PROCESS;




/****************************************************************************************/
/*******************************GET_ACCT_ID     PROCEDURE********************************/
/****************************************************************************************/
/**This procedure returns the correct txn source id.  If the source type is account    **/
/**alias then it will return the p_Transaction_Source_Id_AA.  If it is inventory, then **/
/**it will return p_Transaction_Source_Id_Inv.  This procedure is needed because on the**/
/**mobile txn form the transaction source is taken from different places depending on  **/
/**what the txn source type iswhether the transaction is                               **/
/****************************************************************************************/
/****************************************************************************************/

PROCEDURE GET_ACCT_ID(x_Transaction_Source_Id OUT NOCOPY /* file.sql.39 change */ NUMBER,
		      p_Transaction_Source_Id_AA IN NUMBER,
		      p_Transaction_Source_Id_Inv IN NUMBER,
		      p_Transaction_Source_Type_Id IN NUMBER)
IS
BEGIN

IF p_Transaction_Source_Type_Id = 6 THEN

x_Transaction_Source_Id := p_Transaction_Source_Id_AA;

ELSE

x_Transaction_Source_Id := p_Transaction_Source_Id_Inv;

END IF;

END GET_ACCT_ID;





--Beginning of attempt with quantity manager**

PROCEDURE SUBMIT_PRESSED(x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			 x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			 p_Transaction_Action_Id IN NUMBER,
			 p_To_Sub IN VARCHAR2,
			 p_To_Loc_Id IN NUMBER)
IS
BEGIN
IF p_Transaction_Action_Id = 2 or p_Transaction_Action_Id = 3 THEN
	UPDATE MTL_TRANSACTIONS_INTERFACE SET
	Transfer_Subinventory = p_To_Sub,
	Transfer_Locator = p_To_Loc_Id
	WHERE Transaction_Interface_Id = G_Interface_Id;
END IF;
	process(x_Message,
	x_Status);



END SUBMIT_PRESSED;








PROCEDURE UOM_ENTERED(x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			 p_Inventory_Item_Id IN NUMBER,
				   p_Item_Revision IN VARCHAR2,
				   p_Organization_Id IN NUMBER,
				   p_Transaction_Source_Id_AA IN NUMBER,
				   p_Transaction_Source_Id_Inv IN NUMBER,
				   p_Transaction_Action_Id IN NUMBER,
				   p_From_Subinventory_Code IN VARCHAR2,
				   p_To_Subinventory_Code IN VARCHAR2,
				   p_From_Locator_Id IN NUMBER,
				   p_To_Locator_Id IN NUMBER,
				   p_Transfer_Organization IN NUMBER,
				   p_Transaction_Type_Id IN NUMBER,
				   p_Transaction_Source_Type_Id IN NUMBER,
      				   p_Transaction_UOM IN VARCHAR2,
      				   p_Transaction_Date IN DATE,
				   p_Reason_Id IN NUMBER,
				   p_User_Id IN NUMBER)

IS
l_Transaction_Source_Id NUMBER;

Type t_ref IS REF CURSOR;

l_UOMS t_ref;

v_UOM VARCHAR2(3);
v_holder1 VARCHAR2(25);
v_holder2 VARCHAR2(50);
l_count NUMBER := 0;

BEGIN

x_Status := 'C';
--First we need to validate UOM (for now not using LOVs)

INV_TRANSACTION_LOVS.GET_VALID_UOMS(l_UOMS,
					p_Organization_Id,
					p_Inventory_Item_Id,
					p_Transaction_UOM);
LOOP
 FETCH l_UOMS INTO
v_UOM,v_holder1,v_holder2;
EXIT WHEN l_UOMS%NOTFOUND;
l_count := l_count + 1;



END LOOP;

IF l_count <> 1 THEN

  x_Status := 'E';
  x_Message := 'Not a Valid UOM.  Please Try Again...';
  RETURN;
END IF;




--insert into MTI values that have been entered.  Header is generated here.
--Qty is entered as 0, to be updated by txn_qty_changed field.
--in the case of serial controlled items everything is entered into the lines
--table except the from sub,from loc, and to sub and to loc  these will
--be entered in the SERIAL_ENTERED procedure.

--Generate Header and store as global variable.

SELECT mtl_material_transactions_s.NEXTVAL
 INTO G_Header_Id
FROM DUAL;

G_Interface_Id := G_Header_Id;

GET_ACCT_ID(l_Transaction_Source_Id,
	    p_Transaction_Source_Id_AA,
	    p_Transaction_Source_Id_Inv,
	    p_Transaction_Source_Type_Id);

LINE_INTERFACE_INSERT(   p_Inventory_Item_Id,
				   p_Item_Revision,
				   p_Organization_Id,
				   l_Transaction_Source_Id,
				   p_Transaction_Action_Id,
				   p_From_Subinventory_Code,
				   p_To_Subinventory_Code,
				   p_From_Locator_Id,
				   p_To_Locator_Id,
				   p_Transfer_Organization,
				   p_Transaction_Type_Id,
				   p_Transaction_Source_Type_Id,
				   0,
      				   p_Transaction_UOM,
      				   p_Transaction_Date,
				   p_Reason_Id,
				   p_User_Id,
				   x_Message,
				   x_Status);





END UOM_ENTERED;







PROCEDURE TXN_QTY_CHANGED(p_txn_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_txn_uom_code IN VARCHAR2,
			  p_prev_txn_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_serial_number_control_code IN NUMBER,
			  p_lot_control_code IN NUMBER,
			  p_primary_uom_code IN NUMBER,
			  p_organization_id IN NUMBER,
			  p_inventory_item_id IN NUMBER,
			  p_total_lot_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_transaction_action_id IN NUMBER,
			  x_done OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  x_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  x_message OUT NOCOPY /* file.sql.39 change */ VARCHAR2)

IS
l_txn_uom_code VARCHAR2(3);
l_primary_uom_code VARCHAR2(3);
l_txn_qty NUMBER;
BEGIN

l_txn_uom_code := p_txn_uom_code;
l_primary_uom_code := p_primary_uom_code;

INV_QTY_MANAGEMENT.when_txn_qty_entered(p_txn_qty,
					l_txn_uom_code,
					NULL,
					p_prev_txn_qty,
					p_serial_number_control_code,
					p_lot_control_code,
					l_primary_uom_code,
					p_organization_id,
					p_inventory_item_id,
					p_total_lot_qty,
					p_total_serial_qty,
					x_done,
					x_Status,
					x_message,
					p_transaction_action_id);


--We want to update the correct row of the MTI table based on the
--global header id such that

IF x_status = 'C' THEN

IF p_transaction_action_id <>27 THEN
	l_txn_qty := -p_txn_qty;
ELSE
	l_txn_qty := p_txn_qty;
END IF;

UPDATE MTL_TRANSACTIONS_INTERFACE SET
	transaction_quantity = l_txn_qty
	WHERE Transaction_Header_Id = G_Header_Id;

IF (p_transaction_action_id = 2 or p_transaction_action_id =3
	 or p_transaction_action_id = 1) AND
   (p_serial_number_control_code <>1 AND p_serial_number_control_code <>6) THEN

	UPDATE MTL_TRANSACTION_LOTS_INTERFACE SET
	transaction_quantity = p_txn_qty
	WHERE Transaction_Interface_Id = G_Interface_Id;

END IF;
END IF;

END TXN_QTY_CHANGED;















PROCEDURE LOT_QTY_CHANGED(p_Lot_Number          IN     VARCHAR2,
			  p_txn_qty             IN     NUMBER,
			  p_txn_uom_code        IN     VARCHAR2,
			  p_inventory_item_id   IN     NUMBER,
			  p_lot_control_code    IN     NUMBER,
			  p_serial_control_code IN     NUMBER,
			  p_current_lot_qty     IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_prev_lot_qty        IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_total_lot_qty       IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			  p_total_serial_qty    IN     NUMBER,
			  x_done                IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  x_lot_done               OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  x_Status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  x_Message                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			  p_Organization_Id     IN     NUMBER)
IS
l_primary_uom_code VARCHAR2(3);
BEGIN

select primary_uom_code into l_primary_uom_code
from mtl_system_items where
inventory_item_id = p_inventory_item_id and
organization_id = p_organization_id;
--Call quantity manager
INV_QTY_MANAGEMENT.when_lot_qty_entered(p_txn_qty,
			       p_txn_uom_code,
			       l_primary_uom_code,
			       p_inventory_item_id,
			       p_lot_control_code,
			       p_serial_control_code,
			       p_current_lot_qty,
			       p_prev_lot_qty,
			       p_total_lot_qty,
			       p_total_serial_qty,
			       x_done,
			       x_lot_done,
			       x_Status,
			       x_Message);

--update MTL_TRANSACTION_LOTS_INTERFACE table
IF x_Status = 'C' THEN

UPDATE MTL_TRANSACTION_LOTS_INTERFACE SET
	transaction_quantity = p_current_lot_qty
	WHERE Transaction_Interface_Id = G_Interface_Id
	AND Lot_Number = p_Lot_Number;
END IF;

END LOT_QTY_CHANGED;
















PROCEDURE LOT_CHANGED(	p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			p_serial_number_control_code IN NUMBER,
			p_Lot_Number IN VARCHAR2,
			p_User_Id IN NUMBER)
IS
BEGIN

--reset serial count for new lot, if item is serial controlled.
--this will only happen in the case of a receipt.

INV_QTY_MANAGEMENT.when_lot_num_entered(p_total_serial_qty,
		     p_serial_number_control_code);

IF p_serial_number_control_code <>1 AND p_serial_number_control_code <>6 THEN

SELECT mtl_material_transactions_s.NEXTVAL
 INTO G_Serial_Id
FROM DUAL;


END IF;

 LOT_INTERFACE_INSERT(0,
		      p_Lot_Number,
	   	      p_User_Id,
		      p_serial_number_control_code);
END LOT_CHANGED;















PROCEDURE SERIAL_ENTERED( x_done OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		     	x_lot_done OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		     	x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		     	x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		     	p_txn_qty IN NUMBER,
		     	p_txn_uom_code IN VARCHAR2,
			p_Organization_Id IN NUMBER,
		     	p_inventory_item_id IN NUMBER,
		     	p_current_lot_qty IN NUMBER,
		     	p_lot_control_code IN NUMBER,
		     	p_serial_control_code IN NUMBER,
	  	     	p_from_serial IN VARCHAR2,
		     	p_to_serial IN VARCHAR2,
		     	p_total_lot_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
		     	p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
		     	p_transaction_action_id IN NUMBER,
			p_User_Id IN NUMBER)
IS
Type t_ref IS REF CURSOR;
l_Serials t_ref;
v_serial_number VARCHAR2(30);
v_holder1 VARCHAR2(10);
v_holder2 NUMBER;
v_holder3 VARCHAR2(30);
l_prim VARCHAR2(3);

l_from_sub VARCHAR2(10);
l_from_loc NUMBER;
l_revision VARCHAR2(3);
--After add lot functionality too!!
l_count number := 0;
BEGIN

--For receipts line/lot information will not change and therefore this
--procedure is a simple matter of just calling the quantity manager, then
--inserting the serial into the mtl_serial_numbers_interface table.

--For Serial triggered Issues and transfers,
-- We will enforce that the item stays the same, from sub stays the same,
--the from loc stays the same, and also the Lot information remains the same.
--Therefore, this entails, simply validating the serial number, calling the
--quantity manager and inserting a row into the serial interface table.

x_Status := 'C';

INV_TRANSACTION_LOVS.GET_VALID_SERIALS(l_Serials,
					p_serial_control_code,
					p_inventory_item_id,
					p_organization_id,
					NULL,
					NULL,
					NULL,
					p_transaction_action_id,
					p_from_serial);


LOOP

FETCH l_Serials INTO
v_serial_number,v_holder1,v_holder2,v_holder3;
EXIT WHEN l_Serials%NOTFOUND;

l_count := l_count +1;


END LOOP;

IF l_count = 1 THEN
x_Status := 'C';
ELSE
x_Status := 'E';
x_Message := 'Not a valid Serial number.  Try Again...';
END IF;


IF x_Status = 'E' THEN RETURN;
ELSE
--Call quantity Manager:

select primary_uom_code into l_prim from mtl_system_items where
organization_id = p_Organization_Id
and inventory_item_id = p_inventory_item_id;

INV_QTY_MANAGEMENT.when_srl_num_entered(p_txn_qty,
		     p_txn_uom_code,
		     l_prim,
		     p_inventory_item_id,
		     p_current_lot_qty,
		     p_lot_control_code,
		     p_serial_control_code,
	  	     p_from_serial,
		     p_to_serial,
		     p_total_lot_qty,
		     p_total_serial_qty,
		     x_done,
		     x_lot_done,
		     x_Status,
		     x_Message,
		     p_transaction_action_id);

if x_Status = 'C' THEN

select revision,current_subinventory_code,current_locator_id
into l_revision,l_from_sub, l_from_loc from mtl_serial_numbers
where current_organization_id = p_organization_id and inventory_item_id =
p_inventory_item_id and serial_number = p_from_serial;

UPDATE MTL_TRANSACTIONS_INTERFACE SET
	subinventory_code = l_from_sub,
	revision = l_revision,
	locator_id = l_from_loc
	WHERE Transaction_Header_Id = G_Header_Id;


SERIAL_INTERFACE_INSERT(p_from_serial,
			p_to_serial,
			p_User_Id,
			p_lot_control_code);
END IF;

END IF;

END SERIAL_ENTERED;


END INV_Transactions;

/
