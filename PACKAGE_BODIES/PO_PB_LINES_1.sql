--------------------------------------------------------
--  DDL for Package Body PO_PB_LINES_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PB_LINES_1" as
/* $Header: POPBLINB.pls 120.0 2005/06/02 02:17:30 appldev noship $*/

 procedure insert_line(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Line_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Item_Id                        NUMBER,
                       X_Item_Revision                  VARCHAR2,
                       X_Category_Id                    NUMBER,
                       X_Item_Description               VARCHAR2,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Unit_Price                     NUMBER,
                       X_Vendor_Product_Num             VARCHAR2,
		       X_Org_Id				NUMBER,
		       X_Note_To_Vendor                 VARCHAR2
) IS

X_autocreated_ship       BOOLEAN;
X_accrue_on_receipt_flag VARCHAR2(25);
X_line_location_id   NUMBER;
X_List_Price_Per_Unit    NUMBER;
X_Market_Price           NUMBER;
X_UM_Number              NUMBER;
X_Hazard_Class           NUMBER;

-- <SERVICES FPJ START>
l_order_type_lookup_code PO_LINE_TYPES_B.order_type_lookup_code%TYPE;
l_purchase_basis PO_LINE_TYPES_B.purchase_basis%TYPE;
l_matching_basis PO_LINE_TYPES_B.matching_basis%TYPE;
l_category_id PO_LINE_TYPES_B.category_id%TYPE;
l_unit_meas_lookup_code PO_LINE_TYPES_B.unit_of_measure%TYPE;
l_unit_price PO_LINE_TYPES_B.unit_price%TYPE;
l_outside_operation_flag PO_LINE_TYPES_B.outside_operation_flag%TYPE;
l_receiving_flag PO_LINE_TYPES_B.receiving_flag%TYPE;
l_receive_close_tolerance PO_LINE_TYPES_B.receive_close_tolerance%TYPE;
-- <SERVICES FPJ END>

 begin
X_autocreated_ship:=false;

if(X_Org_Id is null) then
	X_List_Price_Per_Unit:=1;
	X_Market_Price:=1;
	X_UM_Number:=null;
	X_Hazard_Class:=null;
else
	select list_price_per_unit,
       		market_price,
	       	un_number_id,
       		hazard_class_id
	into   X_List_Price_Per_Unit,
	       X_Market_Price,
	       X_UM_Number,
	       X_Hazard_Class
	from mtl_system_items
	where inventory_item_id=X_Item_Id
	      and organization_id=X_Org_Id;
end if;

-- <SERVICES FPJ START>
-- Retrieve the values for order_type_lookup_code, purchase_basis
-- and matching_basis
PO_LINE_TYPES_SV.get_line_type_def(
                 X_Line_Type_Id,
                 l_order_type_lookup_code,
                 l_purchase_basis,
                 l_matching_basis,
                 l_category_id,
                 l_unit_meas_lookup_code,
                 l_unit_price,
                 l_outside_operation_flag,
                 l_receiving_flag,
                 l_receive_close_tolerance);
-- <SERVICES FPJ END>

PO_LINES_SV3.insert_line(X_Rowid                ,
                X_Po_Line_Id             ,
                X_Last_Update_Date       ,
                X_Last_Updated_By        ,
                X_Po_Header_Id           ,
                X_Line_Type_Id           ,
                X_Line_Num               ,
                X_Last_Update_Login      ,
                X_Last_Update_Date       ,--create_date
                X_Last_Updated_By        ,--create_by
                X_Item_Id                ,
                X_Item_Revision          ,
                X_Category_Id            ,
                X_Item_Description       ,
                X_Unit_Meas_Lookup_Code  ,
                null			,--Quantity_Committed
                null			, --X_Committed_Amount,
                'N'			,--X_Allow_Price_Override_Flag,
                null			, --X_Not_To_Exceed_Price
                X_List_Price_Per_Unit    ,
                X_Unit_Price             ,
		null			,--X_Quantity
		X_UM_Number		,--
		X_Hazard_Class		,--
		X_Note_To_Vendor	,--X_Note_To_Vendor
		null			,--X_From_Header_Id
		null			,--X_From_Line_Id
        NULL,            --X_From_Line_Location_Id            -- <SERVICES FPJ>
		null			,--X_Min_Order_Quantity
		null			,--X_Max_Order_Quantity
		null			,--X_Qty_Rcv_Tolerance
		null			,--X_Over_Tolerance_Error_Flag
                X_Market_Price		,--
		'N'			,--X_Unordered_Flag
		'N'			,--X_Closed_Flag
		null			,--X_User_Hold_Flag
		'N'			,--X_Cancel_Flag
		null			,--X_Cancelled_By
		null			,--X_Cancel_Date
		null			,--X_Cancel_Reason
		null			,--X_Firm_Status_Lookup_Code
		null			,--X_Firm_Date
                X_Vendor_Product_Num    ,--
		null			,-- X_Contract_Num
		null			,-- X_Taxable_Flag   previously 'N'
		null			,--X_Tax_Code_Id
		null			,--X_Type_1099
		null			,-- X_Capital_Expense_Flag  previously 'N'
		null			,--X_Negotiated_By_Preparer_Flag  previously 'N
		null			,-- X_Attribute_Category
		null			,--X_Attribute1
		null			,-- X_Attribute2
		null			,--
		null			,--
		null			,--
		null			,--
		null			,--
		null			,--
		null			,--
		null			,--
		null			,--X_Reference_Num
		null			,--Attribute11
		null			,--X_Attribute12
		null			,--X_Attribute13
		null			,--
		null			,--
		null			,--X_Min_Release_Amount
		'VARIABLE' 		,--X_Price_Type_Lookup_Code
		null			,--X_Closed_Code
		'CUMULATIVE'		,--X_Price_Break_Lookup_Code
		null			,--X_Ussgl_Transaction_Code
		null			,--X_Government_Context
		null			,--X_Closed_Date
		null			,--X_Closed_Reason
		null			,--X_Closed_By
		null			,--X_Transaction_Reason_Code
		false			,--X_revise_header
		null			,--X_revision_num
		null			,--X_revised_date
		null			,--X_approved_flag
		null			,--X_header_row_id
		null			,--X_type_lookup_code
		null			,--X_ship_to_location_id
		null			,--X_ship_org_id
		null			,--X_need_by_date
		null			,--X_promised_date
		null			,--X_receipt_required_flag
		null			,--X_invoice_close_tolerance
		null			,--X_receive_close_tolerance
		null			,--X_planned_item_flag
		null			,--X_outside_operation_flag
		null			,--X_destination_type_code
		null			,--X_expense_accrual_code
		null			,--X_dist_blk_status
                X_accrue_on_receipt_flag,--
		null			,--X_ok_to_autocreate_ship
                X_autocreated_ship      ,--
                X_line_location_id      ,--
null, null, null, null, null,null, null,
null, null, null, null, null,null, null,
null, null, null, null, null,null, null,
null, null, null, null, null,null, null,
                null, -- x_oke_contract_header_id
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                null, -- x_amount_db
                l_order_type_lookup_code,
                l_purchase_basis,
                l_matching_basis,
		null,
		null,
		null,
		X_Org_Id         -- <R12 MOAC>
);

 exception

       when others then
            po_message_s.sql_error('insert_line', '010', sqlcode);
            raise;

 end insert_line;

END PO_PB_LINES_1;

/
