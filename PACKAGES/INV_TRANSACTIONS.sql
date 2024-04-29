--------------------------------------------------------
--  DDL for Package INV_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: INVVMWAS.pls 120.1 2005/06/11 07:21:42 appldev  $ */



--The Header id variable keeps track of the header id of a transaction across several serials

G_Header_Id NUMBER;

--Counts number of units being transacted. so we can update total quantity of transaction

G_Interface_Id NUMBER;


G_Serial_Id NUMBER;

PROCEDURE LINE_INTERFACE_INSERT(   p_Inventory_Item_Id IN NUMBER,
				   p_Item_Revision IN VARCHAR2,
				   p_Organization_Id IN NUMBER,
				   p_Transaction_Source_Id IN NUMBER,
				   p_Transaction_Action_Id IN NUMBER,
				   p_From_Subinventory_Code IN VARCHAR2,
				   p_To_Subinventory_Code IN VARCHAR2,
				   p_From_Locator_Id IN NUMBER,
				   p_To_Locator_Id IN NUMBER,
				   p_To_Organization  IN NUMBER,
				   p_Transaction_Type_Id IN NUMBER,
				   p_Transaction_Source_Type_Id IN NUMBER,
				   p_Transaction_Quantity IN NUMBER,
      				   p_Transaction_UOM IN VARCHAR2,
      				   p_Transaction_Date IN DATE,
				   p_Reason_Id IN NUMBER,
				   p_User_Id IN NUMBER,
				   x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
				   x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

PROCEDURE LOT_INTERFACE_INSERT(p_Transaction_Quantity IN NUMBER,
			       p_Lot_Number IN VARCHAR2,
			       p_User_Id IN NUMBER,
			       p_serial_number_control_code IN NUMBER);


PROCEDURE SERIAL_INTERFACE_INSERT(p_From_Serial IN VARCHAR2,
				  p_To_Serial   IN VARCHAR2,
				  p_User_Id     IN NUMBER,
				  p_lot_control_code IN NUMBER);

PROCEDURE PROCESS(x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
		  x_Status  OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


PROCEDURE GET_ACCT_ID(x_Transaction_Source_Id OUT NOCOPY /* file.sql.39 change */ NUMBER,
		      p_Transaction_Source_Id_AA IN NUMBER,
		      p_Transaction_Source_Id_Inv IN NUMBER,
		      p_Transaction_Source_Type_Id IN NUMBER);






/* We need the following Data type API's to use as wrappers on top of QM

1) When Serial Entered: if acct txn, Validate serial number, insert serial number into serial interface,
			and call quantity manager to update the quantities.
			if not acct txn, validate serial numer, check if From Sub,From Loc have changed.
			if so insert new row (same header id but different interface id) in lines table,
		 	if applicable enter new row in lots table, insert into serial interface table with
			new header id, call quantity manager.
--we can afford to call quantity manager at the end, because an error cannot be made here regarding
  quantity.

2) When Lot Number Changed: Call  Quantity manager.

3) When Txn UOM Entered: Insert into MTI (with qty = 0) new record and get new header id, interface id.

4) When Lot Qty Changed:  Call quantity manager. If there are no errors, Check lot number against existing
			  lots with given header id. If lot number exists then update existing row with
			  new quantity, otherwise validate lot number and insert new lot row with
			  existing header id.

5) When Quantity Changed: Call quantity manager.  If there are no errors, Update the row with the correct
 			  header and interface ids with the new quantity.

6) When SUBMIT Pressed: call process procedure with appropriate header and interface ids.


*/





/*
PROCEDURE Validate_Serial_Trigger(x_Message OUT VARCHAR2,
				  x_Status OUT VARCHAR2,
				  p_Transaction_Quantity IN NUMBER,
				  p_Lot_Control_Code IN NUMBER,
				  p_From_Serial IN VARCHAR2,
				  p_Current_Organization IN NUMBER,
				  p_Inventory_Item_Id IN NUMBER,
				  p_User_Id IN NUMBER);

*/

PROCEDURE SUBMIT_PRESSED(x_Status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			 x_Message OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
			 p_Transaction_Action_Id IN NUMBER,
			 p_To_Sub IN VARCHAR2,
			 p_To_Loc_Id IN NUMBER);




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
				   p_User_Id IN NUMBER);


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
			  x_message OUT NOCOPY /* file.sql.39 change */ VARCHAR2);


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
			  p_Organization_Id     IN     NUMBER);

PROCEDURE LOT_CHANGED(	p_total_serial_qty IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
			p_serial_number_control_code IN NUMBER,
			p_Lot_Number IN VARCHAR2,
			p_User_Id IN NUMBER);


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
			p_User_Id IN NUMBER);


END Inv_Transactions;

 

/
