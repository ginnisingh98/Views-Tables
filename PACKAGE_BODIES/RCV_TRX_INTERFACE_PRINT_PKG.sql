--------------------------------------------------------
--  DDL for Package Body RCV_TRX_INTERFACE_PRINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_TRX_INTERFACE_PRINT_PKG" as
/* $Header: RCVTIR7B.pls 120.2 2005/06/21 18:57:09 wkunz noship $ */

PROCEDURE print_rcv_transaction (
X_interface_transaction_id    IN NUMBER) IS

rcv_trx     rcv_transactions_interface%ROWTYPE;
X_progress  VARCHAR2(4) := '000';

BEGIN

  dbms_output.enable (50000);

  /*
  ** get the transaction
  */
  X_progress := '010';

  SELECT *
  INTO   rcv_trx
  FROM   rcv_transactions_interface
  WHERE  interface_transaction_id = X_interface_transaction_id;

  /*
  ** print the columns of the transaction
  */
  dbms_output.put_line('Interface_Transaction_Id 	    : ' ||
     TO_CHAR(rcv_trx.Interface_Transaction_Id));
  dbms_output.put_line('Group_Id 			    : ' ||
     TO_CHAR(rcv_trx.Group_Id));
  dbms_output.put_line('Last_Update_Date         	    : ' ||
     TO_CHAR(rcv_trx.Last_Update_Date));
  dbms_output.put_line('Last_Updated_By 		    : ' ||
     TO_CHAR(rcv_trx.Last_Updated_By));
  dbms_output.put_line('Last_Update_Login 		    : ' ||
     TO_CHAR(rcv_trx.Last_Update_Login));
  dbms_output.put_line('Transaction_Type 		    : ' ||
     rcv_trx.Transaction_Type);
  dbms_output.put_line('Transaction_Date 		    : ' ||
     TO_CHAR(rcv_trx.Transaction_Date));
  dbms_output.put_line('Processing_Status_Code 		    : ' ||
     rcv_trx.Processing_Status_Code);
  dbms_output.put_line('Processing_Mode_Code 		    : ' ||
     rcv_trx.Processing_Mode_Code);
  dbms_output.put_line('Processing_Request_Id 		    : ' ||
     TO_CHAR(rcv_trx.Processing_Request_Id));
  dbms_output.put_line('Transaction_Status_Code 	    : ' ||
     rcv_trx.Transaction_Status_Code);
  dbms_output.put_line('Category_Id 			    : ' ||
     TO_CHAR(rcv_trx.Category_Id));
  dbms_output.put_line('Quantity 			    : ' ||
     TO_CHAR(rcv_trx.Quantity));
  dbms_output.put_line('Unit_Of_Measure 		    : ' ||
     rcv_trx.Unit_Of_Measure);
  dbms_output.put_line('Interface_Source_Code 		    : ' ||
     rcv_trx.Interface_Source_Code);
  dbms_output.put_line('Interface_Source_Line_Id 	    : ' ||
     TO_CHAR(rcv_trx.Interface_Source_Line_Id));
  dbms_output.put_line('Inv_Transaction_Id 		    : ' ||
     TO_CHAR(rcv_trx.Inv_Transaction_Id));
  dbms_output.put_line('Item_Id 			    : ' ||
     TO_CHAR(rcv_trx.Item_Id));
  dbms_output.put_line('Item_Description 		    : ' ||
     rcv_trx.Item_Description);
  dbms_output.put_line('Item_Revision 			    : ' ||
     rcv_trx.Item_Revision);
  dbms_output.put_line('Uom_Code 			    : ' ||
     rcv_trx.Uom_Code);
  dbms_output.put_line('Employee_Id 			    : ' ||
     TO_CHAR(rcv_trx.Employee_Id));
  dbms_output.put_line('Auto_Transact_Code 		    : ' ||
     rcv_trx.Auto_Transact_Code);
  dbms_output.put_line('Shipment_Header_Id 		    : ' ||
     TO_CHAR(rcv_trx.Shipment_Header_Id));
  dbms_output.put_line('Shipment_Line_Id 		    : ' ||
     TO_CHAR(rcv_trx.Shipment_Line_Id));
  dbms_output.put_line('Ship_To_Location_Id 		    : ' ||
     TO_CHAR(rcv_trx.Ship_To_Location_Id));
  dbms_output.put_line('Primary_Quantity 		    : ' ||
     TO_CHAR(rcv_trx.Primary_Quantity));
  dbms_output.put_line('Primary_Unit_Of_Measure 	    : ' ||
     rcv_trx.Primary_Unit_Of_Measure);
  dbms_output.put_line('Receipt_Source_Code 		    : ' ||
     rcv_trx.Receipt_Source_Code);
  dbms_output.put_line('Vendor_Id 			    : ' ||
     TO_CHAR(rcv_trx.Vendor_Id));
  dbms_output.put_line('Vendor_Site_Id 			    : ' ||
     TO_CHAR(rcv_trx.Vendor_Site_Id));
  dbms_output.put_line('From_Organization_Id 		    : ' ||
     TO_CHAR(rcv_trx.From_Organization_Id));
  dbms_output.put_line('To_Organization_Id 		    : ' ||
     TO_CHAR(rcv_trx.To_Organization_Id));
  dbms_output.put_line('Routing_Header_Id 		    : ' ||
     TO_CHAR(rcv_trx.Routing_Header_Id));
  dbms_output.put_line('Routing_Step_Id 		    : ' ||
     TO_CHAR(rcv_trx.Routing_Step_Id));
  dbms_output.put_line('Source_Document_Code 		    : ' ||
     rcv_trx.Source_Document_Code);
  dbms_output.put_line('Parent_Transaction_Id 		    : ' ||
     TO_CHAR(rcv_trx.Parent_Transaction_Id));
  dbms_output.put_line('Po_Header_Id 			    : ' ||
     TO_CHAR(rcv_trx.Po_Header_Id));
  dbms_output.put_line('Po_Revision_Num 		    : ' ||
     TO_CHAR(rcv_trx.Po_Revision_Num));
  dbms_output.put_line('Po_Release_Id 			    : ' ||
     TO_CHAR(rcv_trx.Po_Release_Id));
  dbms_output.put_line('Po_Line_Id 			    : ' ||
     TO_CHAR(rcv_trx.Po_Line_Id));
  dbms_output.put_line('Po_Line_Location_Id 		    : ' ||
     TO_CHAR(rcv_trx.Po_Line_Location_Id));
  dbms_output.put_line('Po_Unit_Price 			    : ' ||
     TO_CHAR(rcv_trx.Po_Unit_Price));
  dbms_output.put_line('Currency_Code 			    : ' ||
     rcv_trx.Currency_Code);
  dbms_output.put_line('Currency_Conversion_Type 	    : ' ||
     rcv_trx.Currency_Conversion_Type);
  dbms_output.put_line('Currency_Conversion_Rate            : ' ||
     TO_CHAR(rcv_trx.Currency_Conversion_Rate));
  dbms_output.put_line('Currency_Conversion_Date            : ' ||
     TO_CHAR(rcv_trx.Currency_Conversion_Date));
  dbms_output.put_line('Po_Distribution_Id 		    : ' ||
     TO_CHAR(rcv_trx.Po_Distribution_Id));
  dbms_output.put_line('Requisition_Line_Id 		    : ' ||
     TO_CHAR(rcv_trx.Requisition_Line_Id));
  dbms_output.put_line('Req_Distribution_Id 		    : ' ||
     TO_CHAR(rcv_trx.Req_Distribution_Id));
  dbms_output.put_line('Charge_Account_Id 		    : ' ||
     TO_CHAR(rcv_trx.Charge_Account_Id));
  dbms_output.put_line('Substitute_Unordered_Code 	    : ' ||
     rcv_trx.Substitute_Unordered_Code);
  dbms_output.put_line('Receipt_Exception_Flag 		    : ' ||
     rcv_trx.Receipt_Exception_Flag);
  dbms_output.put_line('Accrual_Status_Code 		    : ' ||
     rcv_trx.Accrual_Status_Code);
  dbms_output.put_line('Inspection_Status_Code 		    : ' ||
     rcv_trx.Inspection_Status_Code);
  dbms_output.put_line('Inspection_Quality_Code 	    : ' ||
     rcv_trx.Inspection_Quality_Code);
  dbms_output.put_line('Destination_Type_Code 		    : ' ||
     rcv_trx.Destination_Type_Code);
  dbms_output.put_line('Deliver_To_Person_Id 		    : ' ||
     TO_CHAR(rcv_trx.Deliver_To_Person_Id));
  dbms_output.put_line('Location_Id 			    : ' ||
     TO_CHAR(rcv_trx.Location_Id));
  dbms_output.put_line('Deliver_To_Location_Id 		    : ' ||
     TO_CHAR(rcv_trx.Deliver_To_Location_Id));
  dbms_output.put_line('Subinventory 			    : ' ||
     rcv_trx.Subinventory);
  dbms_output.put_line('Locator_Id 			    : ' ||
     TO_CHAR(rcv_trx.Locator_Id));
  dbms_output.put_line('Wip_Entity_Id 			    : ' ||
     TO_CHAR(rcv_trx.Wip_Entity_Id));
  dbms_output.put_line('Wip_Line_Id 			    : ' ||
     TO_CHAR(rcv_trx.Wip_Line_Id));
  dbms_output.put_line('Department_Code 		    : ' ||
     rcv_trx.Department_Code);
  dbms_output.put_line('Wip_Repetitive_Schedule_Id 	    : ' ||
     TO_CHAR(rcv_trx.Wip_Repetitive_Schedule_Id));
  dbms_output.put_line('Wip_Operation_Seq_Num 		    : ' ||
     TO_CHAR(rcv_trx.Wip_Operation_Seq_Num));
  dbms_output.put_line('Wip_Resource_Seq_Num 		    : ' ||
     TO_CHAR(rcv_trx.Wip_Resource_Seq_Num));
  dbms_output.put_line('Bom_Resource_Id 		    : ' ||
     TO_CHAR(rcv_trx.Bom_Resource_Id));
  dbms_output.put_line('Shipment_Num 			    : ' ||
     rcv_trx.Shipment_Num);
  dbms_output.put_line('Freight_Carrier_Code 		    : ' ||
     rcv_trx.Freight_Carrier_Code);
  dbms_output.put_line('Bill_Of_Lading 			    : ' ||
     rcv_trx.Bill_Of_Lading);
  dbms_output.put_line('Packing_Slip 			    : ' ||
     rcv_trx.Packing_Slip);
  dbms_output.put_line('Shipped_Date 			    : ' ||
     TO_CHAR(rcv_trx.Shipped_Date));
  dbms_output.put_line('Expected_Receipt_Date 		    : ' ||
     TO_CHAR(rcv_trx.Expected_Receipt_Date));
  dbms_output.put_line('Actual_Cost 			    : ' ||
     TO_CHAR(rcv_trx.Actual_Cost));
  dbms_output.put_line('Transfer_Cost 			    : ' ||
     TO_CHAR(rcv_trx.Transfer_Cost));
  dbms_output.put_line('Transportation_Cost 		    : ' ||
     TO_CHAR(rcv_trx.Transportation_Cost));
  dbms_output.put_line('Transportation_Account_Id 	    : ' ||
     TO_CHAR(rcv_trx.Transportation_Account_Id));
  dbms_output.put_line('Num_Of_Containers 		    : ' ||
     TO_CHAR(rcv_trx.Num_Of_Containers));
  dbms_output.put_line('Waybill_Airbill_Num 		    : ' ||
     rcv_trx.Waybill_Airbill_Num);
  dbms_output.put_line('Vendor_Item_Num 		    : ' ||
     rcv_trx.Vendor_Item_Num);
  dbms_output.put_line('Vendor_Lot_Num 			    : ' ||
     rcv_trx.Vendor_Lot_Num);
  dbms_output.put_line('Rma_Reference 			    : ' ||
     rcv_trx.Rma_Reference);
  dbms_output.put_line('Comments 			    : ' ||
     rcv_trx.Comments);
  dbms_output.put_line('Attribute_Category 		    : ' ||
     rcv_trx.Attribute_Category);
  dbms_output.put_line('Attribute1 			    : ' ||
     rcv_trx.Attribute1);
  dbms_output.put_line('Attribute2 			    : ' ||
     rcv_trx.Attribute2);
  dbms_output.put_line('Attribute3 			    : ' ||
     rcv_trx.Attribute3);
  dbms_output.put_line('Attribute4 			    : ' ||
     rcv_trx.Attribute4);
  dbms_output.put_line('Attribute5 			    : ' ||
     rcv_trx.Attribute5);
  dbms_output.put_line('Attribute6 			    : ' ||
     rcv_trx.Attribute6);
  dbms_output.put_line('Attribute7 			    : ' ||
     rcv_trx.Attribute7);
  dbms_output.put_line('Attribute8 			    : ' ||
     rcv_trx.Attribute8);
  dbms_output.put_line('Attribute9 			    : ' ||
     rcv_trx.Attribute9);
  dbms_output.put_line('Attribute10 			    : ' ||
     rcv_trx.Attribute10);
  dbms_output.put_line('Attribute11 			    : ' ||
     rcv_trx.Attribute11);
  dbms_output.put_line('Attribute12 			    : ' ||
     rcv_trx.Attribute12);
  dbms_output.put_line('Attribute13 			    : ' ||
     rcv_trx.Attribute13);
  dbms_output.put_line('Attribute14 			    : ' ||
     rcv_trx.Attribute14);
  dbms_output.put_line('Attribute15 			    : ' ||
     rcv_trx.Attribute15);
  dbms_output.put_line('Ship_Head_Attribute_Category 	    : ' ||
     rcv_trx.Ship_Head_Attribute_Category);
  dbms_output.put_line('Ship_Head_Attribute1 		    : ' ||
     rcv_trx.Ship_Head_Attribute1);
  dbms_output.put_line('Ship_Head_Attribute2 		    : ' ||
     rcv_trx.Ship_Head_Attribute2);
  dbms_output.put_line('Ship_Head_Attribute3 		    : ' ||
     rcv_trx.Ship_Head_Attribute3);
  dbms_output.put_line('Ship_Head_Attribute4 		    : ' ||
     rcv_trx.Ship_Head_Attribute4);
  dbms_output.put_line('Ship_Head_Attribute5 		    : ' ||
     rcv_trx.Ship_Head_Attribute5);
  dbms_output.put_line('Ship_Head_Attribute6 		    : ' ||
     rcv_trx.Ship_Head_Attribute6);
  dbms_output.put_line('Ship_Head_Attribute7 		    : ' ||
     rcv_trx.Ship_Head_Attribute7);
  dbms_output.put_line('Ship_Head_Attribute8 		    : ' ||
     rcv_trx.Ship_Head_Attribute8);
  dbms_output.put_line('Ship_Head_Attribute9 		    : ' ||
     rcv_trx.Ship_Head_Attribute9);
  dbms_output.put_line('Ship_Head_Attribute10 		    : ' ||
     rcv_trx.Ship_Head_Attribute10);
  dbms_output.put_line('Ship_Head_Attribute11 		    : ' ||
     rcv_trx.Ship_Head_Attribute11);
  dbms_output.put_line('Ship_Head_Attribute12 		    : ' ||
     rcv_trx.Ship_Head_Attribute12);
  dbms_output.put_line('Ship_Head_Attribute13 		    : ' ||
     rcv_trx.Ship_Head_Attribute13);
  dbms_output.put_line('Ship_Head_Attribute14 		    : ' ||
     rcv_trx.Ship_Head_Attribute14);
  dbms_output.put_line('Ship_Head_Attribute15 		    : ' ||
     rcv_trx.Ship_Head_Attribute15);
  dbms_output.put_line('Ship_Line_Attribute_Category 	    : ' ||
     rcv_trx.Ship_Line_Attribute_Category);
  dbms_output.put_line('Ship_Line_Attribute1 		    : ' ||
     rcv_trx.Ship_Line_Attribute1);
  dbms_output.put_line('Ship_Line_Attribute2 		    : ' ||
     rcv_trx.Ship_Line_Attribute2);
  dbms_output.put_line('Ship_Line_Attribute3 		    : ' ||
     rcv_trx.Ship_Line_Attribute3);
  dbms_output.put_line('Ship_Line_Attribute4 		    : ' ||
     rcv_trx.Ship_Line_Attribute4);
  dbms_output.put_line('Ship_Line_Attribute5 		    : ' ||
     rcv_trx.Ship_Line_Attribute5);
  dbms_output.put_line('Ship_Line_Attribute6 		    : ' ||
     rcv_trx.Ship_Line_Attribute6);
  dbms_output.put_line('Ship_Line_Attribute7 		    : ' ||
     rcv_trx.Ship_Line_Attribute7);
  dbms_output.put_line('Ship_Line_Attribute8 		    : ' ||
     rcv_trx.Ship_Line_Attribute8);
  dbms_output.put_line('Ship_Line_Attribute9 		    : ' ||
     rcv_trx.Ship_Line_Attribute9);
  dbms_output.put_line('Ship_Line_Attribute10 		    : ' ||
     rcv_trx.Ship_Line_Attribute10);
  dbms_output.put_line('Ship_Line_Attribute11 		    : ' ||
     rcv_trx.Ship_Line_Attribute11);
  dbms_output.put_line('Ship_Line_Attribute12 		    : ' ||
     rcv_trx.Ship_Line_Attribute12);
  dbms_output.put_line('Ship_Line_Attribute13 		    : ' ||
     rcv_trx.Ship_Line_Attribute13);
  dbms_output.put_line('Ship_Line_Attribute14 		    : ' ||
     rcv_trx.Ship_Line_Attribute14);
  dbms_output.put_line('Ship_Line_Attribute15 		    : ' ||
     rcv_trx.Ship_Line_Attribute15);
  dbms_output.put_line('Ussgl_Transaction_Code 		    : ' ||
     rcv_trx.Ussgl_Transaction_Code);
  dbms_output.put_line('Government_Context 		    : ' ||
     rcv_trx.Government_Context);
  dbms_output.put_line('Reason_Id 			    : ' ||
     TO_CHAR(rcv_trx.Reason_Id));
  dbms_output.put_line('Destination_Context 		    : ' ||
     rcv_trx.Destination_Context);
  dbms_output.put_line('Source_Doc_Quantity 		    : ' ||
     TO_CHAR(rcv_trx.Source_Doc_Quantity));
  dbms_output.put_line('Source_Doc_Unit_Of_Measure) 	    : ' ||
     rcv_trx.Source_Doc_Unit_Of_Measure);
  dbms_output.put_line('---------------------------------' || ' END ' ||
     '---------------------------------');
END print_rcv_transaction;

END RCV_TRX_INTERFACE_PRINT_PKG;

/
