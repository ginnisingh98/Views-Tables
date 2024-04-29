--------------------------------------------------------
--  DDL for Package Body PO_LINES_PKG_SL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_PKG_SL" as
/* $Header: POXPIL2B.pls 120.2.12010000.11 2014/04/11 03:51:34 linlilin ship $ */
-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

c_log_head    CONSTANT VARCHAR2(35) := 'po.plsql.PO_LINES_PKG_SL.';

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Line_Id                       NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Line_Type_Id                     NUMBER,
                     X_Line_Num                         NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Item_Revision                    VARCHAR2,
                     X_Category_Id                      NUMBER,
                     X_Item_Description                 VARCHAR2,
                     X_Unit_Meas_Lookup_Code            VARCHAR2,
                     X_Quantity_Committed               NUMBER,
                     X_Committed_Amount                 NUMBER,
                     X_Allow_Price_Override_Flag        VARCHAR2,
                     X_Not_To_Exceed_Price              NUMBER,
                     X_List_Price_Per_Unit              NUMBER,
                     X_Unit_Price                       NUMBER,
                     X_Quantity                         NUMBER,
                     X_Un_Number_Id                     NUMBER,
                     X_Hazard_Class_Id                  NUMBER,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_From_Header_Id                   NUMBER,
                     X_From_Line_Id                     NUMBER,
                     X_From_Line_Location_Id            NUMBER,  -- <SERVICES FPJ>
                     X_Min_Order_Quantity               NUMBER,
                     X_Max_Order_Quantity               NUMBER,
                     X_Qty_Rcv_Tolerance                NUMBER,
                     X_Over_Tolerance_Error_Flag        VARCHAR2,
                     X_Market_Price                     NUMBER,
                     X_Unordered_Flag                   VARCHAR2,
                     X_Closed_Flag                      VARCHAR2,
                     X_User_Hold_Flag                   VARCHAR2,
                     X_Cancel_Flag                      VARCHAR2,
                     X_Cancelled_By                     NUMBER,
                     X_Cancel_Date                      DATE,
                     X_Cancel_Reason                    VARCHAR2,
                     X_Firm_Status_Lookup_Code          VARCHAR2,
                     X_Firm_Date                        DATE,
                     X_Vendor_Product_Num               VARCHAR2,
                     X_Contract_Num                     VARCHAR2,
                     X_Tax_Code_Id                      NUMBER,
                     X_Type_1099                        VARCHAR2,
                     X_Capital_Expense_Flag             VARCHAR2,
                     X_Negotiated_By_Preparer_Flag      VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Reference_Num                    VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Min_Release_Amount               NUMBER,
                     X_Price_Type_Lookup_Code           VARCHAR2,
                     X_Closed_Code                      VARCHAR2,
                     X_Price_Break_Lookup_Code          VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Government_Context               VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Closed_Reason                    VARCHAR2,
                     X_Closed_By                        NUMBER,
                     X_Transaction_Reason_Code          VARCHAR2,
                     X_Expiration_Date                  DATE,
                     X_Global_Attribute_Category          VARCHAR2,
                     X_Global_Attribute1                  VARCHAR2,
                     X_Global_Attribute2                  VARCHAR2,
                     X_Global_Attribute3                  VARCHAR2,
                     X_Global_Attribute4                  VARCHAR2,
                     X_Global_Attribute5                  VARCHAR2,
                     X_Global_Attribute6                  VARCHAR2,
                     X_Global_Attribute7                  VARCHAR2,
                     X_Global_Attribute8                  VARCHAR2,
                     X_Global_Attribute9                  VARCHAR2,
                     X_Global_Attribute10                 VARCHAR2,
                     X_Global_Attribute11                 VARCHAR2,
                     X_Global_Attribute12                 VARCHAR2,
                     X_Global_Attribute13                 VARCHAR2,
                     X_Global_Attribute14                 VARCHAR2,
                     X_Global_Attribute15                 VARCHAR2,
                     X_Global_Attribute16                 VARCHAR2,
                     X_Global_Attribute17                 VARCHAR2,
                     X_Global_Attribute18                 VARCHAR2,
                     X_Global_Attribute19                 VARCHAR2,
                     X_Global_Attribute20                 VARCHAR2,
-- Bug# 1056597
-- Mahesh Chandak(GML-OPM).Use 3 new fields secondary_unit_of_measure,secondary_quantity,preferred_grade.Ignore the old fields added by bug# 1056597..
--Preetam Bamb (GML)     21-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
-- start of 1548597
                     X_Base_Uom                           VARCHAR2,
                     X_Base_Qty                           NUMBER,
                     X_Secondary_Uom                    VARCHAR2,
                     X_Secondary_Qty                    NUMBER,
                     X_Qc_Grade                         VARCHAR2,
                     X_Secondary_Unit_of_measure          VARCHAR2 default null ,
                     X_Secondary_Quantity                 NUMBER default null,
                     X_preferred_Grade                    VARCHAR2 default null,
-- end of 1548597
                     p_contract_id                    IN  NUMBER DEFAULT NULL,  -- <GC FPJ>
                     X_job_id                           NUMBER,                 -- <SERVICES FPJ>
                     X_contractor_first_name            VARCHAR2,               -- <SERVICES FPJ>
                     X_contractor_last_name             VARCHAR2,               -- <SERVICES FPJ>
                     X_assignment_start_date            DATE,                   -- <SERVICES FPJ>
                     X_amount_db                        NUMBER,                  -- <SERVICES FPJ>
                     -- <FPJ Advanced Price START>
                     X_Base_Unit_Price                  NUMBER DEFAULT NULL
                     -- <FPJ Advanced Price END>
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PO_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Po_Line_Id  NOWAIT;
    Recinfo C%ROWTYPE;
	--Bug18146696
	l_item_desc po_lines.item_description%type;
     -- For debug purposes
    l_api_name CONSTANT VARCHAR2(30) := 'Lock_Row';
  BEGIN
    IF (g_fnd_debug = 'Y') THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name || '.begin','lock rows');
    END IF;

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
	--Bug 18146696 <Start>
	if X_Item_Id is not null then
 	   begin
 	      select decode(msi.allow_item_desc_update_flag,'Y',Recinfo.item_description,msit.description)
 	        into l_item_desc
 	        from mtl_system_items msi,
 	             mtl_system_items_tl msit,
 	             FINANCIALS_SYSTEM_PARAMETERS FSP
 	       where msi.INVENTORY_ITEM_ID  = X_Item_Id
 	         AND msi.inventory_item_id = msit.inventory_item_id
 	         AND msi.organization_id = msit.organization_id
 	         AND NVL(MSI.ORGANIZATION_ID,FSP.INVENTORY_ORGANIZATION_ID) = FSP.INVENTORY_ORGANIZATION_ID
 	         AND userenv('LANG') = msit.LANGUAGE ;

 	   exception
 	      when others then
 	        l_item_desc := '';
	   end;
	else
	   l_item_desc := Recinfo.item_description; --bug18554880

 	end if;
 	--Bug 18146696 <End>
 	--Bug 18146696 modified the condition Recinfo.item_description with l_item_desc in the following if clause condition.
    if (
          (Recinfo.po_line_id = X_Po_Line_Id)
           AND (Recinfo.po_header_id = X_Po_Header_Id)
           AND (Recinfo.line_type_id = X_Line_Type_Id)
           AND (Recinfo.line_num = X_Line_Num)
           AND (   (Recinfo.item_id = X_Item_Id)
                OR (    (Recinfo.item_id IS NULL)
                    AND (X_Item_Id IS NULL)))
           AND (   (TRIM(Recinfo.item_revision) = TRIM(X_Item_Revision))
                OR (    (TRIM(Recinfo.item_revision) IS NULL)
                    AND (TRIM(X_Item_Revision) IS NULL)))
           AND (   (Recinfo.category_id = X_Category_Id)
                OR (    (Recinfo.category_id IS NULL)
                    AND (X_Category_Id IS NULL)))
           AND (   (TRIM(l_item_desc) = TRIM(X_Item_Description)) --Bug 18146696
                OR (    (TRIM(l_item_desc) IS NULL) --Bug 18146696
                    AND (TRIM(X_Item_Description) IS NULL)))
           AND (   (TRIM(Recinfo.unit_meas_lookup_code) = TRIM(X_Unit_Meas_Lookup_Code))
                OR (    (TRIM(Recinfo.unit_meas_lookup_code) IS NULL)
                    AND (TRIM(X_Unit_Meas_Lookup_Code) IS NULL)))
           AND (   (Recinfo.quantity_committed = X_Quantity_Committed)
                OR (    (Recinfo.quantity_committed IS NULL)
                    AND (X_Quantity_Committed IS NULL)))
           AND (   (Recinfo.committed_amount = X_Committed_Amount)
                OR (    (Recinfo.committed_amount IS NULL)
                    AND (X_Committed_Amount IS NULL)))
           AND (   (TRIM(Recinfo.allow_price_override_flag) = TRIM(X_Allow_Price_Override_Flag))
                OR (    (TRIM(Recinfo.allow_price_override_flag) IS NULL)
                    AND (TRIM(X_Allow_Price_Override_Flag) IS NULL)))
           AND (   (Recinfo.not_to_exceed_price = X_Not_To_Exceed_Price)
                OR (    (Recinfo.not_to_exceed_price IS NULL)
                    AND (X_Not_To_Exceed_Price IS NULL)))
           AND (   (Recinfo.list_price_per_unit = X_List_Price_Per_Unit)
                OR (    (Recinfo.list_price_per_unit IS NULL)
                    AND (X_List_Price_Per_Unit IS NULL)))
           -- <FPJ Advanced Price START>
           AND (   (Recinfo.base_unit_price = X_Base_Unit_Price)
                OR (X_Base_Unit_Price IS NULL))
           -- <FPJ Advanced Price START>
           AND (   (Recinfo.unit_price = X_Unit_Price)
                OR (    (Recinfo.unit_price IS NULL)
                    AND (X_Unit_Price IS NULL)))
           AND (   (Recinfo.quantity = X_Quantity)
                OR (    (Recinfo.quantity IS NULL)
                    AND (X_Quantity IS NULL)))
           AND (   (Recinfo.un_number_id = X_Un_Number_Id)
                OR (    (Recinfo.un_number_id IS NULL)
                    AND (X_Un_Number_Id IS NULL)))
           AND (   (Recinfo.hazard_class_id = X_Hazard_Class_Id)
                OR (    (Recinfo.hazard_class_id IS NULL)
                    AND (X_Hazard_Class_Id IS NULL)))
           AND (   (TRIM(Recinfo.note_to_vendor) = TRIM(X_Note_To_Vendor)) -- bug 10192815
                OR (    (TRIM(Recinfo.note_to_vendor) IS NULL)
                    AND (TRIM(X_Note_To_Vendor) IS NULL)))
           AND (   (Recinfo.from_header_id = X_From_Header_Id)
                OR (    (Recinfo.from_header_id IS NULL)
                    AND (X_From_Header_Id IS NULL)))
           AND (   (Recinfo.from_line_id = X_From_Line_Id)
                OR (    (Recinfo.from_line_id IS NULL)
                    AND (X_From_Line_Id IS NULL)))
           -- <SERVICES FPJ START>
           AND (   (Recinfo.from_line_location_id = X_From_Line_Location_Id)
                OR (    (Recinfo.from_line_location_id IS NULL)
                    AND (X_From_Line_Location_Id IS NULL)))
           -- <SERVICES FPJ END>
           AND (   (Recinfo.min_order_quantity = X_Min_Order_Quantity)
                OR (    (Recinfo.min_order_quantity IS NULL)
                    AND (X_Min_Order_Quantity IS NULL)))
           AND (   (Recinfo.max_order_quantity = X_Max_Order_Quantity)
                OR (    (Recinfo.max_order_quantity IS NULL)
                    AND (X_Max_Order_Quantity IS NULL)))
           AND (   (Recinfo.qty_rcv_tolerance = X_Qty_Rcv_Tolerance)
                OR (    (Recinfo.qty_rcv_tolerance IS NULL)
                    AND (X_Qty_Rcv_Tolerance IS NULL)))
           AND (   (TRIM(Recinfo.over_tolerance_error_flag) = TRIM(X_Over_Tolerance_Error_Flag))
                OR (    (TRIM(Recinfo.over_tolerance_error_flag) IS NULL)
                    AND (TRIM(X_Over_Tolerance_Error_Flag) IS NULL)))
           AND (   (Recinfo.market_price = X_Market_Price)
                OR (    (Recinfo.market_price IS NULL)
                    AND (X_Market_Price IS NULL)))
           AND (   (TRIM(Recinfo.unordered_flag) = TRIM(X_Unordered_Flag))
                OR (    (TRIM(Recinfo.unordered_flag) IS NULL)
                    AND (TRIM(X_Unordered_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.closed_flag) = TRIM(X_Closed_Flag))
                OR (    (TRIM(Recinfo.closed_flag) IS NULL)
                    AND (TRIM(X_Closed_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.user_hold_flag) = TRIM(X_User_Hold_Flag))
                OR (    (TRIM(Recinfo.user_hold_flag) IS NULL)
                    AND (TRIM(X_User_Hold_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.cancel_flag) = TRIM(X_Cancel_Flag))
                OR (    (TRIM(Recinfo.cancel_flag) IS NULL)
                    AND (TRIM(X_Cancel_Flag) IS NULL)))
           AND (   (Recinfo.cancelled_by = X_Cancelled_By)
                OR (    (Recinfo.cancelled_by IS NULL)
                    AND (X_Cancelled_By IS NULL)))
           AND (   (Recinfo.cancel_date = X_Cancel_Date)
                OR (    (Recinfo.cancel_date IS NULL)
                    AND (X_Cancel_Date IS NULL)))
           AND (   (TRIM(Recinfo.cancel_reason) = TRIM(X_Cancel_Reason))
                OR (    (TRIM(Recinfo.cancel_reason) IS NULL)
                    AND (TRIM(X_Cancel_Reason) IS NULL)))
           AND (   (TRIM(Recinfo.firm_status_lookup_code) = TRIM(X_Firm_Status_Lookup_Code))
                OR (    (TRIM(Recinfo.firm_status_lookup_code) IS NULL)
                    AND (TRIM(X_Firm_Status_Lookup_Code) IS NULL)))
           AND (   (Recinfo.firm_date = X_Firm_Date)
                OR (    (Recinfo.firm_date IS NULL)
                    AND (X_Firm_Date IS NULL)))
           AND (   (TRIM(Recinfo.vendor_product_num) = TRIM(X_Vendor_Product_Num))
                OR (    (TRIM(Recinfo.vendor_product_num) IS NULL)
                    AND (TRIM(X_Vendor_Product_Num) IS NULL)))
        )  then

	   if  (-- <GC FPJ START>
               -- Check Contract_id instead of Contract_num
          (  (Recinfo.contract_id  = p_contract_id)
                OR (    (Recinfo.contract_id IS NULL)
                    AND (p_contract_id IS NULL)))
               -- <GC FPJ END>
           AND (   (TRIM(Recinfo.type_1099) = TRIM(X_Type_1099))
                OR (    (TRIM(Recinfo.type_1099) IS NULL)
                    AND (TRIM(X_Type_1099) IS NULL)))
           AND (   (TRIM(Recinfo.capital_expense_flag) = TRIM(X_Capital_Expense_Flag))
                OR (    (TRIM(Recinfo.capital_expense_flag) IS NULL)
                    AND (TRIM(X_Capital_Expense_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.negotiated_by_preparer_flag) = TRIM(X_Negotiated_By_Preparer_Flag))
                OR (    (TRIM(Recinfo.negotiated_by_preparer_flag) IS NULL)
                    AND (TRIM(X_Negotiated_By_Preparer_Flag) IS NULL)))
           AND (   (TRIM(Recinfo.attribute_category) = TRIM(X_Attribute_Category))
                OR (    (TRIM(Recinfo.attribute_category) IS NULL)
                    AND (TRIM(X_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.attribute1) = TRIM(X_Attribute1))
                OR (    (TRIM(Recinfo.attribute1) IS NULL)
                    AND (TRIM(X_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.attribute2) = TRIM(X_Attribute2))
                OR (    (TRIM(Recinfo.attribute2) IS NULL)
                    AND (TRIM(X_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.attribute3) = TRIM(X_Attribute3))
                OR (    (TRIM(Recinfo.attribute3) IS NULL)
                    AND (TRIM(X_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.attribute4) = TRIM(X_Attribute4))
                OR (    (TRIM(Recinfo.attribute4) IS NULL)
                    AND (TRIM(X_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.attribute5) = TRIM(X_Attribute5))
                OR (    (TRIM(Recinfo.attribute5) IS NULL)
                    AND (TRIM(X_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.attribute6) = TRIM(X_Attribute6))
                OR (    (TRIM(Recinfo.attribute6) IS NULL)
                    AND (TRIM(X_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.attribute7) = TRIM(X_Attribute7))
                OR (    (TRIM(Recinfo.attribute7) IS NULL)
                    AND (TRIM(X_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.attribute8) = TRIM(X_Attribute8))
                OR (    (TRIM(Recinfo.attribute8) IS NULL)
                    AND (TRIM(X_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.attribute9) = TRIM(X_Attribute9))
                OR (    (TRIM(Recinfo.attribute9) IS NULL)
                    AND (TRIM(X_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.attribute10) = TRIM(X_Attribute10))
                OR (    (TRIM(Recinfo.attribute10) IS NULL)
                    AND (TRIM(X_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.reference_num) = TRIM(X_Reference_Num))
                OR (    (TRIM(Recinfo.reference_num) IS NULL)
                    AND (TRIM(X_Reference_Num) IS NULL)))
           AND (   (TRIM(Recinfo.attribute11) = TRIM(X_Attribute11))
                OR (    (TRIM(Recinfo.attribute11) IS NULL)
                    AND (TRIM(X_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.attribute12) = TRIM(X_Attribute12))
                OR (    (TRIM(Recinfo.attribute12) IS NULL)
                    AND (TRIM(X_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.attribute13) = TRIM(X_Attribute13))
                OR (    (TRIM(Recinfo.attribute13) IS NULL)
                    AND (TRIM(X_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.attribute14) = TRIM(X_Attribute14))
                OR (    (TRIM(Recinfo.attribute14) IS NULL)
                    AND (TRIM(X_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.attribute15) = TRIM(X_Attribute15))
                OR (    (TRIM(Recinfo.attribute15) IS NULL)
                    AND (TRIM(X_Attribute15) IS NULL)))
           AND (   (Recinfo.min_release_amount = X_Min_Release_Amount)
                OR (    (Recinfo.min_release_amount IS NULL)
                    AND (X_Min_Release_Amount IS NULL)))
           AND (   (TRIM(Recinfo.price_type_lookup_code) = TRIM(X_Price_Type_Lookup_Code))
                OR (    (TRIM(Recinfo.price_type_lookup_code) IS NULL)
                    AND (TRIM(X_Price_Type_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.closed_code) = TRIM(X_Closed_Code))
                OR (    (TRIM(Recinfo.closed_code) IS NULL)
                    AND (TRIM(X_Closed_Code) IS NULL)))
           AND (   (TRIM(Recinfo.price_break_lookup_code) = TRIM(X_Price_Break_Lookup_Code))
                OR (    (TRIM(Recinfo.price_break_lookup_code) IS NULL)
                    AND (TRIM(X_Price_Break_Lookup_Code) IS NULL)))
           AND (   (TRIM(Recinfo.government_context) = TRIM(X_Government_Context))
                OR (    (TRIM(Recinfo.government_context) IS NULL)
                    AND (TRIM(X_Government_Context) IS NULL)))
           AND (   (Recinfo.closed_date = X_Closed_Date)
                OR (    (Recinfo.closed_date IS NULL)
                    AND (X_Closed_Date IS NULL)))
           AND (   (TRIM(Recinfo.closed_reason) = TRIM(X_Closed_Reason))
                OR (    (TRIM(Recinfo.closed_reason) IS NULL)
                    AND (TRIM(X_Closed_Reason) IS NULL)))
           AND (   (Recinfo.closed_by = X_Closed_By)
                OR (    (Recinfo.closed_by IS NULL)
                    AND (X_Closed_By IS NULL)))
           AND (   (TRIM(Recinfo.transaction_reason_code) = TRIM(X_Transaction_Reason_Code))
                OR (    (TRIM(Recinfo.transaction_reason_code) IS NULL)
                    AND (TRIM(X_Transaction_Reason_Code) IS NULL)))
           AND (   (Recinfo.Expiration_Date = X_Expiration_Date)
                OR (    (Recinfo.Expiration_Date IS NULL)
                    AND (X_Expiration_Date IS NULL)))
--Bug# 1056597 Preetam Bamb (GML)     21-feb-2000  Added 5 columns to the insert_row procedure
-- start of 1548597 comment code added by bug 1056597 and add code to include secondary_unit_of_measure,secondary_quantity and preferred_grade fields
/**
           AND (   (TRIM(Recinfo.Base_uom) = TRIM(X_Base_uom))
                OR (    (TRIM(Recinfo.Base_uom) IS NULL)
                    AND (TRIM(X_Base_uom) IS NULL)))
           AND (   (TRIM(Recinfo.Base_qty) = TRIM(X_Base_qty))
                OR (    (TRIM(Recinfo.Base_qty) IS NULL)
                    AND (TRIM(X_Base_qty) IS NULL)))
           AND (   (TRIM(Recinfo.Secondary_uom) = TRIM(X_Secondary_uom))
                OR (    (TRIM(Recinfo.Secondary_uom) IS NULL)
                    AND (TRIM(X_Secondary_uom) IS NULL)))
           AND (   (Recinfo.Secondary_qty = X_Secondary_qty)
                OR (    (Recinfo.Secondary_qty IS NULL)
                    AND (X_Secondary_qty IS NULL)))
           AND (   (TRIM(Recinfo.qc_grade) = TRIM(X_qc_grade))
                OR (    (TRIM(Recinfo.qc_grade) IS NULL)
                    AND (TRIM(X_qc_grade) IS NULL)))
**/
--End Bug# 1056597
           AND (   (TRIM(Recinfo.Secondary_unit_of_measure) = TRIM(X_Secondary_Unit_Of_Measure))
                OR (    (TRIM(Recinfo.Secondary_unit_of_measure) IS NULL)
                    AND (TRIM(X_Secondary_Unit_Of_Measure) IS NULL)))
           AND (   (Recinfo.Secondary_quantity = X_Secondary_Quantity)
                OR (    (Recinfo.Secondary_quantity IS NULL)
                    AND (X_Secondary_Quantity IS NULL)))
           AND (   (TRIM(Recinfo.preferred_grade) = TRIM(X_preferred_grade))
                OR (    (TRIM(Recinfo.preferred_grade) IS NULL)
                    AND (TRIM(X_preferred_grade) IS NULL)))
--End Bug# 1548597
           AND (   (TRIM(Recinfo.global_attribute_category) = TRIM(X_Global_Attribute_Category))
                OR (    (TRIM(Recinfo.global_attribute_category) IS NULL)
                    AND (TRIM(X_Global_Attribute_Category) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute1) = TRIM(X_Global_Attribute1))
                OR (    (TRIM(Recinfo.global_attribute1) IS NULL)
                    AND (TRIM(X_Global_Attribute1) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute2) = TRIM(X_Global_Attribute2))
                OR (    (TRIM(Recinfo.global_attribute2) IS NULL)
                    AND (TRIM(X_Global_Attribute2) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute3) = TRIM(X_Global_Attribute3))
                OR (    (TRIM(Recinfo.global_attribute3) IS NULL)
                    AND (TRIM(X_Global_Attribute3) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute4) = TRIM(X_Global_Attribute4))
                OR (    (TRIM(Recinfo.global_attribute4) IS NULL)
                    AND (TRIM(X_Global_Attribute4) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute5) = TRIM(X_Global_Attribute5))
                OR (    (TRIM(Recinfo.global_attribute5) IS NULL)
                    AND (TRIM(X_Global_Attribute5) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute6) = TRIM(X_Global_Attribute6))
                OR (    (TRIM(Recinfo.global_attribute6) IS NULL)
                    AND (TRIM(X_Global_Attribute6) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute7) = TRIM(X_Global_Attribute7))
                OR (    (TRIM(Recinfo.global_attribute7) IS NULL)
                    AND (TRIM(X_Global_Attribute7) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute8) = TRIM(X_Global_Attribute8))
                OR (    (TRIM(Recinfo.global_attribute8) IS NULL)
                    AND (TRIM(X_Global_Attribute8) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute9) = TRIM(X_Global_Attribute9))
                OR (    (TRIM(Recinfo.global_attribute9) IS NULL)
                    AND (TRIM(X_Global_Attribute9) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute10) = TRIM(X_Global_Attribute10))
                OR (    (TRIM(Recinfo.global_attribute10) IS NULL)
                    AND (TRIM(X_Global_Attribute10) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute11) = TRIM(X_Global_Attribute11))
                OR (    (TRIM(Recinfo.global_attribute11) IS NULL)
                    AND (TRIM(X_Global_Attribute11) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute12) = TRIM(X_Global_Attribute12))
                OR (    (TRIM(Recinfo.global_attribute12) IS NULL)
                    AND (TRIM(X_Global_Attribute12) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute13) = TRIM(X_Global_Attribute13))
                OR (    (TRIM(Recinfo.global_attribute13) IS NULL)
                    AND (TRIM(X_Global_Attribute13) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute14) = TRIM(X_Global_Attribute14))
                OR (    (TRIM(Recinfo.global_attribute14) IS NULL)
                    AND (TRIM(X_Global_Attribute14) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute15) = TRIM(X_Global_Attribute15))
                OR (    (TRIM(Recinfo.global_attribute15) IS NULL)
                    AND (TRIM(X_Global_Attribute15) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute16) = TRIM(X_Global_Attribute16))
                OR (    (TRIM(Recinfo.global_attribute16) IS NULL)
                    AND (TRIM(X_Global_Attribute16) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute17) = TRIM(X_Global_Attribute17))
                OR (    (TRIM(Recinfo.global_attribute17) IS NULL)
                    AND (TRIM(X_Global_Attribute17) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute18) = TRIM(X_Global_Attribute18))
                OR (    (TRIM(Recinfo.global_attribute18) IS NULL)
                    AND (TRIM(X_Global_Attribute18) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute19) = TRIM(X_Global_Attribute19))
                OR (    (TRIM(Recinfo.global_attribute19) IS NULL)
                    AND (TRIM(X_Global_Attribute19) IS NULL)))
           AND (   (TRIM(Recinfo.global_attribute20) = TRIM(X_Global_Attribute20))
                OR (    (TRIM(Recinfo.global_attribute20) IS NULL)
                    AND (TRIM(X_Global_Attribute20) IS NULL)))
           -- <SERVICES FPJ START>
           AND (   (Recinfo.job_id = X_job_id)
                OR (    (Recinfo.job_id IS NULL)
                    AND (X_job_id IS NULL)))
           AND (   (TRIM(Recinfo.contractor_first_name) = TRIM(X_contractor_first_name))
                OR (    (TRIM(Recinfo.contractor_first_name) IS NULL)
                    AND (TRIM(X_contractor_first_name) IS NULL)))
           AND (   (TRIM(Recinfo.contractor_last_name) = TRIM(X_contractor_last_name))
                OR (    (TRIM(Recinfo.contractor_last_name) IS NULL)
                    AND (TRIM(X_contractor_last_name) IS NULL)))
           AND (   (Recinfo.start_date = X_assignment_start_date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_assignment_start_date IS NULL)))
           AND (   (Recinfo.amount = X_amount_db)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_amount_db IS NULL)))
           -- <SERVICES FPJ END>
            ) then

        IF (g_fnd_debug = 'Y') THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head ||l_api_name ||'.end','no lock error');
        END IF;

        return;
    else
      IF (g_fnd_debug = 'Y') THEN
        IF (NVL(X_Po_Line_Id,-999) <> NVL(Recinfo.po_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_line_id'||X_Po_Line_Id ||' Database  po_line_id '|| Recinfo.po_line_id);
        END IF;
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Line_Type_Id,-999) <> NVL(Recinfo.line_type_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_type_id'||X_Line_Type_Id ||' Database  line_type_id '|| Recinfo.line_type_id);
        END IF;
        IF (NVL(X_Line_Num,-999) <> NVL(Recinfo.line_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_num'||X_Line_Num ||' Database  line_num '|| Recinfo.line_num);
        END IF;
        IF (NVL(X_Item_Id,-999) <> NVL(Recinfo.item_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_id'||X_Item_Id ||' Database  item_id '|| Recinfo.item_id);
        END IF;
        IF (NVL(TRIM(X_Item_Revision),'-999') <> NVL( TRIM(Recinfo.item_revision),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_revision '||X_Item_Revision ||' Database  item_revision '||Recinfo.item_revision);
        END IF;
        IF (NVL(X_Category_Id,-999) <> NVL(Recinfo.category_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form category_id'||X_Category_Id ||' Database  category_id '|| Recinfo.category_id);
        END IF;
        IF (NVL(TRIM(X_Item_Description),'-999') <> NVL( TRIM(Recinfo.item_description),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_description '||X_Item_Description ||' Database  item_description '||Recinfo.item_description);
        END IF;
        IF (NVL(TRIM(X_Unit_Meas_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||X_Unit_Meas_Lookup_Code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(X_Quantity_Committed,-999) <> NVL(Recinfo.quantity_committed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_committed'||X_Quantity_Committed ||' Database  quantity_committed '|| Recinfo.quantity_committed);
        END IF;
        IF (NVL(X_Committed_Amount,-999) <> NVL(Recinfo.committed_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form committed_amount'||X_Committed_Amount ||' Database  committed_amount '|| Recinfo.committed_amount);
        END IF;
        IF (NVL(TRIM(X_Allow_Price_Override_Flag),'-999') <> NVL( TRIM(Recinfo.allow_price_override_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form allow_price_override_flag '||X_Allow_Price_Override_Flag ||' Database  allow_price_override_flag '||Recinfo.allow_price_override_flag);
        END IF;
        IF (NVL(X_Not_To_Exceed_Price,-999) <> NVL(Recinfo.not_to_exceed_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form not_to_exceed_price'||X_Not_To_Exceed_Price ||' Database  not_to_exceed_price '|| Recinfo.not_to_exceed_price);
        END IF;
        IF (NVL(X_List_Price_Per_Unit,-999) <> NVL(Recinfo.list_price_per_unit,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form list_price_per_unit'||X_List_Price_Per_Unit ||' Database  list_price_per_unit '|| Recinfo.list_price_per_unit);
        END IF;
        IF (NVL(X_Unit_Price,-999) <> NVL(Recinfo.unit_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_price'||X_Unit_Price ||' Database  unit_price '|| Recinfo.unit_price);
        END IF;
        IF (NVL(X_Quantity,-999) <> NVL(Recinfo.quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity'||X_Quantity ||' Database  quantity '|| Recinfo.quantity);
        END IF;
        IF (NVL(X_Un_Number_Id,-999) <> NVL(Recinfo.un_number_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form un_number_id'||X_Un_Number_Id ||' Database  un_number_id '|| Recinfo.un_number_id);
        END IF;
        IF (NVL(X_Hazard_Class_Id,-999) <> NVL(Recinfo.hazard_class_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form hazard_class_id'||X_Hazard_Class_Id ||' Database  hazard_class_id '|| Recinfo.hazard_class_id);
        END IF;
        IF (NVL(TRIM(X_Note_To_Vendor),'-999') <> NVL( TRIM(Recinfo.note_to_vendor),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form note_to_vendor '||X_Note_To_Vendor ||' Database  note_to_vendor '||Recinfo.note_to_vendor);
        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(X_From_Line_Id,-999) <> NVL(Recinfo.from_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_id'||X_From_Line_Id ||' Database  from_line_id '|| Recinfo.from_line_id);
        END IF;
        IF (NVL(X_From_Line_Location_Id,-999) <> NVL(Recinfo.from_line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_location_id'||X_From_Line_Location_Id ||' Database  from_line_location_id '|| Recinfo.from_line_location_id);
        END IF;
        IF (NVL(X_Min_Order_Quantity,-999) <> NVL(Recinfo.min_order_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form min_order_quantity'||X_Min_Order_Quantity ||' Database  min_order_quantity '|| Recinfo.min_order_quantity);
        END IF;
        IF (NVL(X_Max_Order_Quantity,-999) <> NVL(Recinfo.max_order_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form maorder_quantity'||X_Max_Order_Quantity ||' Database  maorder_quantity '|| Recinfo.max_order_quantity);
        END IF;
        IF (NVL(X_Qty_Rcv_Tolerance,-999) <> NVL(Recinfo.qty_rcv_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_tolerance'||X_Qty_Rcv_Tolerance ||' Database  qty_rcv_tolerance '|| Recinfo.qty_rcv_tolerance);
        END IF;
        IF (NVL(TRIM(X_Over_Tolerance_Error_Flag),'-999') <> NVL( TRIM(Recinfo.over_tolerance_error_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form over_tolerance_error_flag '||X_Over_Tolerance_Error_Flag ||' Database  over_tolerance_error_flag '||Recinfo.over_tolerance_error_flag);
        END IF;
        IF (NVL(X_Market_Price,-999) <> NVL(Recinfo.market_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form market_price'||X_Market_Price ||' Database  market_price '|| Recinfo.market_price);
        END IF;
        IF (NVL(TRIM(X_Unordered_Flag),'-999') <> NVL( TRIM(Recinfo.unordered_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unordered_flag '||X_Unordered_Flag ||' Database  unordered_flag '||Recinfo.unordered_flag);
        END IF;
        IF (NVL(TRIM(X_Closed_Flag),'-999') <> NVL( TRIM(Recinfo.closed_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_flag '||X_Closed_Flag ||' Database  closed_flag '||Recinfo.closed_flag);
        END IF;
        IF (NVL(TRIM(X_User_Hold_Flag),'-999') <> NVL( TRIM(Recinfo.user_hold_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form user_hold_flag '||X_User_Hold_Flag ||' Database  user_hold_flag '||Recinfo.user_hold_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(X_Cancelled_By,-999) <> NVL(Recinfo.cancelled_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancelled_by'||X_Cancelled_By ||' Database  cancelled_by '|| Recinfo.cancelled_by);
        END IF;
        IF (X_Cancel_Date <> Recinfo.cancel_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_date '||X_Cancel_Date ||' Database  cancel_date '||Recinfo.cancel_date);
        END IF;
        IF (NVL(TRIM(X_Cancel_Reason),'-999') <> NVL( TRIM(Recinfo.cancel_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_reason '||X_Cancel_Reason ||' Database  cancel_reason '||Recinfo.cancel_reason);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (X_Firm_Date <> Recinfo.firm_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_date '||X_Firm_Date ||' Database  firm_date '||Recinfo.firm_date);
        END IF;
        IF (NVL(TRIM(X_Vendor_Product_Num),'-999') <> NVL( TRIM(Recinfo.vendor_product_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_product_num '||X_Vendor_Product_Num ||' Database  vendor_product_num '||Recinfo.vendor_product_num);
        END IF;
        IF (NVL(TRIM(X_Contract_Num),'-999') <> NVL( TRIM(Recinfo.contract_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contract_num '||X_Contract_Num ||' Database  contract_num '||Recinfo.contract_num);
        END IF;

        IF (NVL(TRIM(X_Type_1099),'-999') <> NVL( TRIM(Recinfo.type_1099),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form type_1099 '||X_Type_1099 ||' Database  type_1099 '||Recinfo.type_1099);
        END IF;
        IF (NVL(TRIM(X_Capital_Expense_Flag),'-999') <> NVL( TRIM(Recinfo.capital_expense_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form capital_expense_flag '||X_Capital_Expense_Flag ||' Database  capital_expense_flag '||Recinfo.capital_expense_flag);
        END IF;
        IF (NVL(TRIM(X_Negotiated_By_Preparer_Flag),'-999') <> NVL( TRIM(Recinfo.negotiated_by_preparer_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form negotiated_by_preparer_flag '||X_Negotiated_By_Preparer_Flag ||' Database  negotiated_by_preparer_flag '||Recinfo.negotiated_by_preparer_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Reference_Num),'-999') <> NVL( TRIM(Recinfo.reference_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form reference_num '||X_Reference_Num ||' Database  reference_num '||Recinfo.reference_num);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(X_Min_Release_Amount,-999) <> NVL(Recinfo.min_release_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form min_release_amount'||X_Min_Release_Amount ||' Database  min_release_amount '|| Recinfo.min_release_amount);
        END IF;
        IF (NVL(TRIM(X_Price_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.price_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_type_lookup_code '||X_Price_Type_Lookup_Code ||' Database  price_type_lookup_code '||Recinfo.price_type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Price_Break_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.price_break_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_break_lookup_code '||X_Price_Break_Lookup_Code ||' Database  price_break_lookup_code '||Recinfo.price_break_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Ussgl_Transaction_Code),'-999') <> NVL( TRIM(Recinfo.ussgl_transaction_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ussgl_transaction_code '||X_Ussgl_Transaction_Code ||' Database  ussgl_transaction_code '||Recinfo.ussgl_transaction_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(TRIM(X_Closed_Reason),'-999') <> NVL( TRIM(Recinfo.closed_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_reason '||X_Closed_Reason ||' Database  closed_reason '||Recinfo.closed_reason);
        END IF;
        IF (NVL(X_Closed_By,-999) <> NVL(Recinfo.closed_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_by'||X_Closed_By ||' Database  closed_by '|| Recinfo.closed_by);
        END IF;
        IF (NVL(TRIM(X_Transaction_Reason_Code),'-999') <> NVL( TRIM(Recinfo.transaction_reason_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form transaction_reason_code '||X_Transaction_Reason_Code ||' Database  transaction_reason_code '||Recinfo.transaction_reason_code);
        END IF;
        IF (X_Expiration_Date <> Recinfo.expiration_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form expiration_date '||X_Expiration_Date ||' Database  expiration_date '||Recinfo.expiration_date);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(X_Base_Uom),'-999') <> NVL( TRIM(Recinfo.base_uom),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form base_uom '||X_Base_Uom ||' Database  base_uom '||Recinfo.base_uom);
        END IF;
        IF (NVL(X_Base_Qty,-999) <> NVL(Recinfo.base_qty,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form base_qty'||X_Base_Qty ||' Database  base_qty '|| Recinfo.base_qty);
        END IF;
        IF (NVL(TRIM(X_Secondary_Uom),'-999') <> NVL( TRIM(Recinfo.secondary_uom),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_uom '||X_Secondary_Uom ||' Database  secondary_uom '||Recinfo.secondary_uom);
        END IF;
        IF (NVL(X_Secondary_Qty,-999) <> NVL(Recinfo.secondary_qty,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_qty'||X_Secondary_Qty ||' Database  secondary_qty '|| Recinfo.secondary_qty);
        END IF;
        IF (NVL(TRIM(X_Qc_Grade),'-999') <> NVL( TRIM(Recinfo.qc_grade),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qc_grade '||X_Qc_Grade ||' Database  qc_grade '||Recinfo.qc_grade);
        END IF;
        IF (NVL(TRIM(X_Secondary_Unit_Of_Measure),'-999') <> NVL( TRIM(Recinfo.Secondary_unit_of_measure),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_nit_measure '||X_Secondary_Unit_Of_Measure ||' Database  secondary_nit_measure '||Recinfo.Secondary_unit_of_measure);
        END IF;
        IF (NVL(TRIM(X_Secondary_Quantity),'-999') <> NVL( TRIM(Recinfo.Secondary_quantity),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Secondary_quantity '||X_Secondary_Quantity ||' Database  Secondary_quantity '||Recinfo.Secondary_quantity);
        END IF;
         IF (NVL(TRIM(X_preferred_grade),'-999') <> NVL( TRIM(Recinfo.preferred_grade),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preferred_grade '||X_preferred_grade ||' Database  preferred_grade '||Recinfo.preferred_grade);
        END IF;
        IF (NVL(X_job_id,'-999') <> NVL( Recinfo.job_id,'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form job_id '||X_job_id ||' Database  job_id '||Recinfo.job_id);
        END IF;
         IF (NVL(TRIM(X_contractor_first_name),'-999') <> NVL( TRIM(Recinfo.contractor_first_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contractor_first_name '||X_contractor_first_name ||' Database  contractor_first_name '||Recinfo.contractor_first_name);
        END IF;
        IF (NVL(TRIM(X_contractor_last_name),'-999') <> NVL( TRIM(Recinfo.contractor_last_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contractor_last_name '||X_contractor_last_name ||' Database  contractor_last_name '||Recinfo.contractor_last_name);
        END IF;
        IF (X_assignment_start_date <> Recinfo.start_date) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form start_date '||X_assignment_start_date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (NVL(X_amount_db,'-999') <> NVL( Recinfo.amount,'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount '||X_amount_db ||' Database  amount '||Recinfo.amount);
        END IF;

        FND_LOG.string(FND_LOG.level_error, c_log_head||'lock_row.010',
                         'Failed second if statement when comparing fields');
      END IF;  --g_fnd_debug

      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;  --inner if
  else
      IF (g_fnd_debug = 'Y') THEN

        IF (NVL(X_Po_Line_Id,-999) <> NVL(Recinfo.po_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_line_id'||X_Po_Line_Id ||' Database  po_line_id '|| Recinfo.po_line_id);
        END IF;
        IF (NVL(X_Po_Header_Id,-999) <> NVL(Recinfo.po_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form po_header_id'||X_Po_Header_Id ||' Database  po_header_id '|| Recinfo.po_header_id);
        END IF;
        IF (NVL(X_Line_Type_Id,-999) <> NVL(Recinfo.line_type_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_type_id'||X_Line_Type_Id ||' Database  line_type_id '|| Recinfo.line_type_id);
        END IF;
        IF (NVL(X_Line_Num,-999) <> NVL(Recinfo.line_num,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form line_num'||X_Line_Num ||' Database  line_num '|| Recinfo.line_num);
        END IF;
        IF (NVL(X_Item_Id,-999) <> NVL(Recinfo.item_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_id'||X_Item_Id ||' Database  item_id '|| Recinfo.item_id);
        END IF;
        IF (NVL(TRIM(X_Item_Revision),'-999') <> NVL( TRIM(Recinfo.item_revision),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_revision '||X_Item_Revision ||' Database  item_revision '||Recinfo.item_revision);
        END IF;
        IF (NVL(X_Category_Id,-999) <> NVL(Recinfo.category_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form category_id'||X_Category_Id ||' Database  category_id '|| Recinfo.category_id);
        END IF;
        IF (NVL(TRIM(X_Item_Description),'-999') <> NVL( TRIM(Recinfo.item_description),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form item_description '||X_Item_Description ||' Database  item_description '||Recinfo.item_description);
        END IF;
        IF (NVL(TRIM(X_Unit_Meas_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.unit_meas_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_meas_lookup_code '||X_Unit_Meas_Lookup_Code ||' Database  unit_meas_lookup_code '||Recinfo.unit_meas_lookup_code);
        END IF;
        IF (NVL(X_Quantity_Committed,-999) <> NVL(Recinfo.quantity_committed,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity_committed'||X_Quantity_Committed ||' Database  quantity_committed '|| Recinfo.quantity_committed);
        END IF;
        IF (NVL(X_Committed_Amount,-999) <> NVL(Recinfo.committed_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form committed_amount'||X_Committed_Amount ||' Database  committed_amount '|| Recinfo.committed_amount);
        END IF;
        IF (NVL(TRIM(X_Allow_Price_Override_Flag),'-999') <> NVL( TRIM(Recinfo.allow_price_override_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form allow_price_override_flag '||X_Allow_Price_Override_Flag ||' Database  allow_price_override_flag '||Recinfo.allow_price_override_flag);
        END IF;
        IF (NVL(X_Not_To_Exceed_Price,-999) <> NVL(Recinfo.not_to_exceed_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form not_to_exceed_price'||X_Not_To_Exceed_Price ||' Database  not_to_exceed_price '|| Recinfo.not_to_exceed_price);
        END IF;
        IF (NVL(X_List_Price_Per_Unit,-999) <> NVL(Recinfo.list_price_per_unit,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form list_price_per_unit'||X_List_Price_Per_Unit ||' Database  list_price_per_unit '|| Recinfo.list_price_per_unit);
        END IF;
        IF (NVL(X_Unit_Price,-999) <> NVL(Recinfo.unit_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unit_price'||X_Unit_Price ||' Database  unit_price '|| Recinfo.unit_price);
        END IF;
        IF (NVL(X_Quantity,-999) <> NVL(Recinfo.quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form quantity'||X_Quantity ||' Database  quantity '|| Recinfo.quantity);
        END IF;
        IF (NVL(X_Un_Number_Id,-999) <> NVL(Recinfo.un_number_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form un_number_id'||X_Un_Number_Id ||' Database  un_number_id '|| Recinfo.un_number_id);
        END IF;
        IF (NVL(X_Hazard_Class_Id,-999) <> NVL(Recinfo.hazard_class_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form hazard_class_id'||X_Hazard_Class_Id ||' Database  hazard_class_id '|| Recinfo.hazard_class_id);
        END IF;
        IF (NVL(TRIM(X_Note_To_Vendor),'-999') <> NVL( TRIM(Recinfo.note_to_vendor),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form note_to_vendor '||X_Note_To_Vendor ||' Database  note_to_vendor '||Recinfo.note_to_vendor);
        END IF;
        IF (NVL(X_From_Header_Id,-999) <> NVL(Recinfo.from_header_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_header_id'||X_From_Header_Id ||' Database  from_header_id '|| Recinfo.from_header_id);
        END IF;
        IF (NVL(X_From_Line_Id,-999) <> NVL(Recinfo.from_line_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_id'||X_From_Line_Id ||' Database  from_line_id '|| Recinfo.from_line_id);
        END IF;
        IF (NVL(X_From_Line_Location_Id,-999) <> NVL(Recinfo.from_line_location_id,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form from_line_location_id'||X_From_Line_Location_Id ||' Database  from_line_location_id '|| Recinfo.from_line_location_id);
        END IF;
        IF (NVL(X_Min_Order_Quantity,-999) <> NVL(Recinfo.min_order_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form min_order_quantity'||X_Min_Order_Quantity ||' Database  min_order_quantity '|| Recinfo.min_order_quantity);
        END IF;
        IF (NVL(X_Max_Order_Quantity,-999) <> NVL(Recinfo.max_order_quantity,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form maorder_quantity'||X_Max_Order_Quantity ||' Database  maorder_quantity '|| Recinfo.max_order_quantity);
        END IF;
        IF (NVL(X_Qty_Rcv_Tolerance,-999) <> NVL(Recinfo.qty_rcv_tolerance,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qty_rcv_tolerance'||X_Qty_Rcv_Tolerance ||' Database  qty_rcv_tolerance '|| Recinfo.qty_rcv_tolerance);
        END IF;
        IF (NVL(TRIM(X_Over_Tolerance_Error_Flag),'-999') <> NVL( TRIM(Recinfo.over_tolerance_error_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form over_tolerance_error_flag '||X_Over_Tolerance_Error_Flag ||' Database  over_tolerance_error_flag '||Recinfo.over_tolerance_error_flag);
        END IF;
        IF (NVL(X_Market_Price,-999) <> NVL(Recinfo.market_price,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form market_price'||X_Market_Price ||' Database  market_price '|| Recinfo.market_price);
        END IF;
        IF (NVL(TRIM(X_Unordered_Flag),'-999') <> NVL( TRIM(Recinfo.unordered_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form unordered_flag '||X_Unordered_Flag ||' Database  unordered_flag '||Recinfo.unordered_flag);
        END IF;
        IF (NVL(TRIM(X_Closed_Flag),'-999') <> NVL( TRIM(Recinfo.closed_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_flag '||X_Closed_Flag ||' Database  closed_flag '||Recinfo.closed_flag);
        END IF;
        IF (NVL(TRIM(X_User_Hold_Flag),'-999') <> NVL( TRIM(Recinfo.user_hold_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form user_hold_flag '||X_User_Hold_Flag ||' Database  user_hold_flag '||Recinfo.user_hold_flag);
        END IF;
        IF (NVL(TRIM(X_Cancel_Flag),'-999') <> NVL( TRIM(Recinfo.cancel_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_flag '||X_Cancel_Flag ||' Database  cancel_flag '||Recinfo.cancel_flag);
        END IF;
        IF (NVL(X_Cancelled_By,-999) <> NVL(Recinfo.cancelled_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancelled_by'||X_Cancelled_By ||' Database  cancelled_by '|| Recinfo.cancelled_by);
        END IF;
        IF (X_Cancel_Date <> Recinfo.cancel_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_date '||X_Cancel_Date ||' Database  cancel_date '||Recinfo.cancel_date);
        END IF;
        IF (NVL(TRIM(X_Cancel_Reason),'-999') <> NVL( TRIM(Recinfo.cancel_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form cancel_reason '||X_Cancel_Reason ||' Database  cancel_reason '||Recinfo.cancel_reason);
        END IF;
        IF (NVL(TRIM(X_Firm_Status_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.firm_status_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_status_lookup_code '||X_Firm_Status_Lookup_Code ||' Database  firm_status_lookup_code '||Recinfo.firm_status_lookup_code);
        END IF;
        IF (X_Firm_Date <> Recinfo.firm_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form firm_date '||X_Firm_Date ||' Database  firm_date '||Recinfo.firm_date);
        END IF;
        IF (NVL(TRIM(X_Vendor_Product_Num),'-999') <> NVL( TRIM(Recinfo.vendor_product_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form vendor_product_num '||X_Vendor_Product_Num ||' Database  vendor_product_num '||Recinfo.vendor_product_num);
        END IF;
        IF (NVL(TRIM(X_Contract_Num),'-999') <> NVL( TRIM(Recinfo.contract_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contract_num '||X_Contract_Num ||' Database  contract_num '||Recinfo.contract_num);
        END IF;

        IF (NVL(TRIM(X_Type_1099),'-999') <> NVL( TRIM(Recinfo.type_1099),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form type_1099 '||X_Type_1099 ||' Database  type_1099 '||Recinfo.type_1099);
        END IF;
        IF (NVL(TRIM(X_Capital_Expense_Flag),'-999') <> NVL( TRIM(Recinfo.capital_expense_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form capital_expense_flag '||X_Capital_Expense_Flag ||' Database  capital_expense_flag '||Recinfo.capital_expense_flag);
        END IF;
        IF (NVL(TRIM(X_Negotiated_By_Preparer_Flag),'-999') <> NVL( TRIM(Recinfo.negotiated_by_preparer_flag),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form negotiated_by_preparer_flag '||X_Negotiated_By_Preparer_Flag ||' Database  negotiated_by_preparer_flag '||Recinfo.negotiated_by_preparer_flag);
        END IF;
        IF (NVL(TRIM(X_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute_category '||X_Attribute_Category ||' Database  attribute_category '||Recinfo.attribute_category);
        END IF;
        IF (NVL(TRIM(X_Attribute1),'-999') <> NVL( TRIM(Recinfo.attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute1 '||X_Attribute1 ||' Database  attribute1 '||Recinfo.attribute1);
        END IF;
        IF (NVL(TRIM(X_Attribute2),'-999') <> NVL( TRIM(Recinfo.attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute2 '||X_Attribute2 ||' Database  attribute2 '||Recinfo.attribute2);
        END IF;
        IF (NVL(TRIM(X_Attribute3),'-999') <> NVL( TRIM(Recinfo.attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute3 '||X_Attribute3 ||' Database  attribute3 '||Recinfo.attribute3);
        END IF;
        IF (NVL(TRIM(X_Attribute4),'-999') <> NVL( TRIM(Recinfo.attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute4 '||X_Attribute4 ||' Database  attribute4 '||Recinfo.attribute4);
        END IF;
        IF (NVL(TRIM(X_Attribute5),'-999') <> NVL( TRIM(Recinfo.attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute5 '||X_Attribute5 ||' Database  attribute5 '||Recinfo.attribute5);
        END IF;
        IF (NVL(TRIM(X_Attribute6),'-999') <> NVL( TRIM(Recinfo.attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute6 '||X_Attribute6 ||' Database  attribute6 '||Recinfo.attribute6);
        END IF;
        IF (NVL(TRIM(X_Attribute7),'-999') <> NVL( TRIM(Recinfo.attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute7 '||X_Attribute7 ||' Database  attribute7 '||Recinfo.attribute7);
        END IF;
        IF (NVL(TRIM(X_Attribute8),'-999') <> NVL( TRIM(Recinfo.attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute8 '||X_Attribute8 ||' Database  attribute8 '||Recinfo.attribute8);
        END IF;
        IF (NVL(TRIM(X_Attribute9),'-999') <> NVL( TRIM(Recinfo.attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute9 '||X_Attribute9 ||' Database  attribute9 '||Recinfo.attribute9);
        END IF;
        IF (NVL(TRIM(X_Attribute10),'-999') <> NVL( TRIM(Recinfo.attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute10 '||X_Attribute10 ||' Database  attribute10 '||Recinfo.attribute10);
        END IF;
        IF (NVL(TRIM(X_Reference_Num),'-999') <> NVL( TRIM(Recinfo.reference_num),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form reference_num '||X_Reference_Num ||' Database  reference_num '||Recinfo.reference_num);
        END IF;
        IF (NVL(TRIM(X_Attribute11),'-999') <> NVL( TRIM(Recinfo.attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute11 '||X_Attribute11 ||' Database  attribute11 '||Recinfo.attribute11);
        END IF;
        IF (NVL(TRIM(X_Attribute12),'-999') <> NVL( TRIM(Recinfo.attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute12 '||X_Attribute12 ||' Database  attribute12 '||Recinfo.attribute12);
        END IF;
        IF (NVL(TRIM(X_Attribute13),'-999') <> NVL( TRIM(Recinfo.attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute13 '||X_Attribute13 ||' Database  attribute13 '||Recinfo.attribute13);
        END IF;
        IF (NVL(TRIM(X_Attribute14),'-999') <> NVL( TRIM(Recinfo.attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute14 '||X_Attribute14 ||' Database  attribute14 '||Recinfo.attribute14);
        END IF;
        IF (NVL(TRIM(X_Attribute15),'-999') <> NVL( TRIM(Recinfo.attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form attribute15 '||X_Attribute15 ||' Database  attribute15 '||Recinfo.attribute15);
        END IF;
        IF (NVL(X_Min_Release_Amount,-999) <> NVL(Recinfo.min_release_amount,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form min_release_amount'||X_Min_Release_Amount ||' Database  min_release_amount '|| Recinfo.min_release_amount);
        END IF;
        IF (NVL(TRIM(X_Price_Type_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.price_type_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_type_lookup_code '||X_Price_Type_Lookup_Code ||' Database  price_type_lookup_code '||Recinfo.price_type_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Closed_Code),'-999') <> NVL( TRIM(Recinfo.closed_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_code '||X_Closed_Code ||' Database  closed_code '||Recinfo.closed_code);
        END IF;
        IF (NVL(TRIM(X_Price_Break_Lookup_Code),'-999') <> NVL( TRIM(Recinfo.price_break_lookup_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form price_break_lookup_code '||X_Price_Break_Lookup_Code ||' Database  price_break_lookup_code '||Recinfo.price_break_lookup_code);
        END IF;
        IF (NVL(TRIM(X_Ussgl_Transaction_Code),'-999') <> NVL( TRIM(Recinfo.ussgl_transaction_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form ussgl_transaction_code '||X_Ussgl_Transaction_Code ||' Database  ussgl_transaction_code '||Recinfo.ussgl_transaction_code);
        END IF;
        IF (NVL(TRIM(X_Government_Context),'-999') <> NVL( TRIM(Recinfo.government_context),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form government_context '||X_Government_Context ||' Database  government_context '||Recinfo.government_context);
        END IF;
        IF (X_Closed_Date <> Recinfo.closed_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_date '||X_Closed_Date ||' Database  closed_date '||Recinfo.closed_date);
        END IF;
        IF (NVL(TRIM(X_Closed_Reason),'-999') <> NVL( TRIM(Recinfo.closed_reason),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_reason '||X_Closed_Reason ||' Database  closed_reason '||Recinfo.closed_reason);
        END IF;
        IF (NVL(X_Closed_By,-999) <> NVL(Recinfo.closed_by,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form closed_by'||X_Closed_By ||' Database  closed_by '|| Recinfo.closed_by);
        END IF;
        IF (NVL(TRIM(X_Transaction_Reason_Code),'-999') <> NVL( TRIM(Recinfo.transaction_reason_code),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form transaction_reason_code '||X_Transaction_Reason_Code ||' Database  transaction_reason_code '||Recinfo.transaction_reason_code);
        END IF;
        IF (X_Expiration_Date <> Recinfo.expiration_date ) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form expiration_date '||X_Expiration_Date ||' Database  expiration_date '||Recinfo.expiration_date);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute_Category),'-999') <> NVL( TRIM(Recinfo.global_attribute_category),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute_category '||X_Global_Attribute_Category ||' Database  global_attribute_category '||Recinfo.global_attribute_category);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute1),'-999') <> NVL( TRIM(Recinfo.global_attribute1),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute1 '||X_Global_Attribute1 ||' Database  global_attribute1 '||Recinfo.global_attribute1);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute2),'-999') <> NVL( TRIM(Recinfo.global_attribute2),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute2 '||X_Global_Attribute2 ||' Database  global_attribute2 '||Recinfo.global_attribute2);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute3),'-999') <> NVL( TRIM(Recinfo.global_attribute3),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute3 '||X_Global_Attribute3 ||' Database  global_attribute3 '||Recinfo.global_attribute3);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute4),'-999') <> NVL( TRIM(Recinfo.global_attribute4),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute4 '||X_Global_Attribute4 ||' Database  global_attribute4 '||Recinfo.global_attribute4);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute5),'-999') <> NVL( TRIM(Recinfo.global_attribute5),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute5 '||X_Global_Attribute5 ||' Database  global_attribute5 '||Recinfo.global_attribute5);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute6),'-999') <> NVL( TRIM(Recinfo.global_attribute6),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute6 '||X_Global_Attribute6 ||' Database  global_attribute6 '||Recinfo.global_attribute6);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute7),'-999') <> NVL( TRIM(Recinfo.global_attribute7),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute7 '||X_Global_Attribute7 ||' Database  global_attribute7 '||Recinfo.global_attribute7);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute8),'-999') <> NVL( TRIM(Recinfo.global_attribute8),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute8 '||X_Global_Attribute8 ||' Database  global_attribute8 '||Recinfo.global_attribute8);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute9),'-999') <> NVL( TRIM(Recinfo.global_attribute9),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute9 '||X_Global_Attribute9 ||' Database  global_attribute9 '||Recinfo.global_attribute9);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute10),'-999') <> NVL( TRIM(Recinfo.global_attribute10),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute10 '||X_Global_Attribute10 ||' Database  global_attribute10 '||Recinfo.global_attribute10);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute11),'-999') <> NVL( TRIM(Recinfo.global_attribute11),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute11 '||X_Global_Attribute11 ||' Database  global_attribute11 '||Recinfo.global_attribute11);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute12),'-999') <> NVL( TRIM(Recinfo.global_attribute12),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute12 '||X_Global_Attribute12 ||' Database  global_attribute12 '||Recinfo.global_attribute12);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute13),'-999') <> NVL( TRIM(Recinfo.global_attribute13),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute13 '||X_Global_Attribute13 ||' Database  global_attribute13 '||Recinfo.global_attribute13);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute14),'-999') <> NVL( TRIM(Recinfo.global_attribute14),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute14 '||X_Global_Attribute14 ||' Database  global_attribute14 '||Recinfo.global_attribute14);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute15),'-999') <> NVL( TRIM(Recinfo.global_attribute15),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute15 '||X_Global_Attribute15 ||' Database  global_attribute15 '||Recinfo.global_attribute15);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute16),'-999') <> NVL( TRIM(Recinfo.global_attribute16),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute16 '||X_Global_Attribute16 ||' Database  global_attribute16 '||Recinfo.global_attribute16);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute17),'-999') <> NVL( TRIM(Recinfo.global_attribute17),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute17 '||X_Global_Attribute17 ||' Database  global_attribute17 '||Recinfo.global_attribute17);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute18),'-999') <> NVL( TRIM(Recinfo.global_attribute18),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute18 '||X_Global_Attribute18 ||' Database  global_attribute18 '||Recinfo.global_attribute18);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute19),'-999') <> NVL( TRIM(Recinfo.global_attribute19),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute19 '||X_Global_Attribute19 ||' Database  global_attribute19 '||Recinfo.global_attribute19);
        END IF;
        IF (NVL(TRIM(X_Global_Attribute20),'-999') <> NVL( TRIM(Recinfo.global_attribute20),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form global_attribute20 '||X_Global_Attribute20 ||' Database  global_attribute20 '||Recinfo.global_attribute20);
        END IF;
        IF (NVL(TRIM(X_Base_Uom),'-999') <> NVL( TRIM(Recinfo.base_uom),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form base_uom '||X_Base_Uom ||' Database  base_uom '||Recinfo.base_uom);
        END IF;
        IF (NVL(X_Base_Qty,-999) <> NVL(Recinfo.base_qty,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form base_qty'||X_Base_Qty ||' Database  base_qty '|| Recinfo.base_qty);
        END IF;
        IF (NVL(TRIM(X_Secondary_Uom),'-999') <> NVL( TRIM(Recinfo.secondary_uom),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_uom '||X_Secondary_Uom ||' Database  secondary_uom '||Recinfo.secondary_uom);
        END IF;
        IF (NVL(X_Secondary_Qty,-999) <> NVL(Recinfo.secondary_qty,-999)) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_qty'||X_Secondary_Qty ||' Database  secondary_qty '|| Recinfo.secondary_qty);
        END IF;
        IF (NVL(TRIM(X_Qc_Grade),'-999') <> NVL( TRIM(Recinfo.qc_grade),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form qc_grade '||X_Qc_Grade ||' Database  qc_grade '||Recinfo.qc_grade);
        END IF;
        IF (NVL(TRIM(X_Secondary_Unit_Of_Measure),'-999') <> NVL( TRIM(Recinfo.Secondary_unit_of_measure),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form secondary_nit_measure '||X_Secondary_Unit_Of_Measure ||' Database  secondary_nit_measure '||Recinfo.Secondary_unit_of_measure);
        END IF;
        IF (NVL(TRIM(X_Secondary_Quantity),'-999') <> NVL( TRIM(Recinfo.Secondary_quantity),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form Secondary_quantity '||X_Secondary_Quantity ||' Database  Secondary_quantity '||Recinfo.Secondary_quantity);
        END IF;
         IF (NVL(TRIM(X_preferred_grade),'-999') <> NVL( TRIM(Recinfo.preferred_grade),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form preferred_grade '||X_preferred_grade ||' Database  preferred_grade '||Recinfo.preferred_grade);
        END IF;
        IF (NVL(X_job_id,'-999') <> NVL( Recinfo.job_id,'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form job_id '||X_job_id ||' Database  job_id '||Recinfo.job_id);
        END IF;
         IF (NVL(TRIM(X_contractor_first_name),'-999') <> NVL( TRIM(Recinfo.contractor_first_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contractor_first_name '||X_contractor_first_name ||' Database  contractor_first_name '||Recinfo.contractor_first_name);
        END IF;
        IF (NVL(TRIM(X_contractor_last_name),'-999') <> NVL( TRIM(Recinfo.contractor_last_name),'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form contractor_last_name '||X_contractor_last_name ||' Database  contractor_last_name '||Recinfo.contractor_last_name);
        END IF;
        IF (X_assignment_start_date <> Recinfo.start_date) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form start_date '||X_assignment_start_date ||' Database  start_date '||Recinfo.start_date);
        END IF;
        IF (NVL(X_amount_db,'-999') <> NVL( Recinfo.amount,'-999')) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,c_log_head || l_api_name,' Form amount '||X_amount_db ||' Database  amount '||Recinfo.amount);
        END IF;

      FND_LOG.string(FND_LOG.level_error, c_log_head||'lock_row.020',
                         'Failed first if statement when comparing fields');
    END IF;  --g_fnd_debug

    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;  --outter if

END Lock_Row;
END PO_LINES_PKG_SL;

/
