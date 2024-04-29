--------------------------------------------------------
--  DDL for Package Body PO_LINES_PKG_SUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_PKG_SUD" as
/* $Header: POXPIL4B.pls 120.3.12010000.2 2008/12/18 07:46:02 mugoel ship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Line_Id                     NUMBER,
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
                       X_Quantity_Committed             NUMBER,
                       X_Committed_Amount               NUMBER,
                       X_Allow_Price_Override_Flag      VARCHAR2,
                       X_Not_To_Exceed_Price            NUMBER,
                       X_List_Price_Per_Unit            NUMBER,
                       -- <FPJ Advanced Price START>
                       X_Base_Unit_Price                NUMBER,
                       -- <FPJ Advanced Price END>
                       X_Unit_Price                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Un_Number_Id                   NUMBER,
                       X_Hazard_Class_Id                NUMBER,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER, -- <SERVICES FPJ>
                       X_Min_Order_Quantity             NUMBER,
                       X_Max_Order_Quantity             NUMBER,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Over_Tolerance_Error_Flag      VARCHAR2,
                       X_Market_Price                   NUMBER,
                       X_Unordered_Flag                 VARCHAR2,
                       X_Closed_Flag                    VARCHAR2,
                       X_User_Hold_Flag                 VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Firm_Date                      DATE,
                       X_Vendor_Product_Num             VARCHAR2,
                       X_Contract_Num                   VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
                       X_Type_1099                      VARCHAR2,
                       X_Capital_Expense_Flag           VARCHAR2,
                       X_Negotiated_By_Preparer_Flag    VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Reference_Num                  VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Min_Release_Amount             NUMBER,
                       X_Price_Type_Lookup_Code         VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Price_Break_Lookup_Code        VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_By                      NUMBER,
                       X_Transaction_Reason_Code        VARCHAR2,
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
                       X_Expiration_Date                    DATE,
--Preetam Bamb (GML)     21-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
                       X_Base_Uom                           VARCHAR2,
                       X_Base_Qty                           NUMBER,
                       X_Secondary_Uom                      VARCHAR2,
                       X_Secondary_Qty                      NUMBER,
                       X_Qc_Grade                           VARCHAR2,
		     --togeorge 10/03/2000
		     --added oke columns
		     X_oke_contract_header_id   	    NUMBER default null,
		     X_oke_contract_version_id   	    NUMBER default null,
-- 1548597 add 3 new process fields..
                       X_Secondary_Unit_of_measure        VARCHAR2 default null,
                       X_Secondary_Quantity               NUMBER default null,
                       X_preferred_Grade                  VARCHAR2 default null,
                       p_contract_id                   IN NUMBER DEFAULT NULL,   -- <GC FPJ>
                       X_job_id                         NUMBER,                  -- <SERVICES FPJ>
                       X_contractor_first_name          VARCHAR2,                -- <SERVICES FPJ>
                       X_contractor_last_name           VARCHAR2,                -- <SERVICES FPJ>
                       X_assignment_start_date          DATE,                    -- <SERVICES FPJ>
                       X_amount_db                      NUMBER,                   -- <SERVICES FPJ>
                       p_manual_price_change_flag       VARCHAR2,                -- <Manual Price Override FPJ>
                       p_ip_category_id                 NUMBER                  -- Bug 7577670
 ) IS

    --<eTax Integration R12 Start>
    l_tax_attribute_update_code PO_LINES_ALL.tax_attribute_update_code%type;
    l_type_lookup_code          PO_HEADERS_ALL.type_lookup_code%type;
    --<eTax Integration R12 End>

 BEGIN

   --<eTax Integration R12 Start>
    SELECT poh.type_lookup_code
    INTO l_type_lookup_code
    FROM po_headers_all poh, po_lines_all pol
    WHERE pol.po_line_id = X_Po_Line_Id
      AND pol.po_header_id = poh.po_header_id;

     IF l_type_lookup_code IN ('STANDARD', 'PLANNED') AND
        PO_TAX_INTERFACE_PVT.any_tax_attributes_updated(
           p_doc_type=>'PO',
           p_doc_level => 'LINE',
           p_doc_level_id => X_Po_Line_Id,
        p_uom=>X_Unit_Meas_Lookup_Code,
        p_price=>X_Unit_Price
     ) THEN
        l_tax_attribute_update_code := 'UPDATE';
     END IF;
    --<eTax Integration R12 End>


   UPDATE PO_LINES
   SET
     po_line_id                        =     X_Po_Line_Id,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     po_header_id                      =     X_Po_Header_Id,
     line_type_id                      =     X_Line_Type_Id,
     line_num                          =     X_Line_Num,
     last_update_login                 =     X_Last_Update_Login,
     item_id                           =     X_Item_Id,
     item_revision                     =     X_Item_Revision,
     category_id                       =     X_Category_Id,
     item_description                  =     X_Item_Description,
     unit_meas_lookup_code             =     X_Unit_Meas_Lookup_Code,
     quantity_committed                =     X_Quantity_Committed,
     committed_amount                  =     X_Committed_Amount,
     allow_price_override_flag         =     X_Allow_Price_Override_Flag,
     not_to_exceed_price               =     X_Not_To_Exceed_Price,
     list_price_per_unit               =     X_List_Price_Per_Unit,
     -- <FPJ Advanced Price START>
     base_unit_price                   =     X_Base_Unit_Price,
     -- <FPJ Advanced Price END>
     unit_price                        =     X_Unit_Price,
     quantity                          =     X_Quantity,
     un_number_id                      =     X_Un_Number_Id,
     hazard_class_id                   =     X_Hazard_Class_Id,
     note_to_vendor                    =     X_Note_To_Vendor,
     from_header_id                    =     X_From_Header_Id,
     from_line_id                      =     X_From_Line_Id,
     from_line_location_id             =     X_From_Line_Location_Id, -- <SERVICES FPJ>
     min_order_quantity                =     X_Min_Order_Quantity,
     max_order_quantity                =     X_Max_Order_Quantity,
     qty_rcv_tolerance                 =     X_Qty_Rcv_Tolerance,
     over_tolerance_error_flag         =     X_Over_Tolerance_Error_Flag,
     market_price                      =     X_Market_Price,
     unordered_flag                    =     X_Unordered_Flag,
     closed_flag                       =     X_Closed_Flag,
     user_hold_flag                    =     X_User_Hold_Flag,
     cancel_flag                       =     X_Cancel_Flag,
     cancelled_by                      =     X_Cancelled_By,
     cancel_date                       =     X_Cancel_Date,
     cancel_reason                     =     X_Cancel_Reason,
     firm_status_lookup_code           =     X_Firm_Status_Lookup_Code,
     firm_date                         =     X_Firm_Date,
     vendor_product_num                =     X_Vendor_Product_Num,
     contract_num                      =     X_Contract_Num,
     type_1099                         =     X_Type_1099,
     capital_expense_flag              =     X_Capital_Expense_Flag,
     negotiated_by_preparer_flag       =     X_Negotiated_By_Preparer_Flag,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     reference_num                     =     X_Reference_Num,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     min_release_amount                =     X_Min_Release_Amount,
     price_type_lookup_code            =     X_Price_Type_Lookup_Code,
     closed_code                       =     X_Closed_Code,
     price_break_lookup_code           =     X_Price_Break_Lookup_Code,
     ussgl_transaction_code            =     X_Ussgl_Transaction_Code,
     government_context                =     X_Government_Context,
     closed_date                       =     X_Closed_Date,
     closed_reason                     =     X_Closed_Reason,
     closed_by                         =     X_Closed_By,
     transaction_reason_code           =     X_Transaction_Reason_Code,
     global_attribute_category         =     X_Global_Attribute_Category,
     global_attribute1                 =     X_Global_Attribute1,
     global_attribute2                 =     X_Global_Attribute2,
     global_attribute3                 =     X_Global_Attribute3,
     global_attribute4                 =     X_Global_Attribute4,
     global_attribute5                 =     X_Global_Attribute5,
     global_attribute6                 =     X_Global_Attribute6,
     global_attribute7                 =     X_Global_Attribute7,
     global_attribute8                 =     X_Global_Attribute8,
     global_attribute9                 =     X_Global_Attribute9,
     global_attribute10                =     X_Global_Attribute10,
     global_attribute11                =     X_Global_Attribute11,
     global_attribute12                =     X_Global_Attribute12,
     global_attribute13                =     X_Global_Attribute13,
     global_attribute14                =     X_Global_Attribute14,
     global_attribute15                =     X_Global_Attribute15,
     global_attribute16                =     X_Global_Attribute16,
     global_attribute17                =     X_Global_Attribute17,
     global_attribute18                =     X_Global_Attribute18,
     global_attribute19                =     X_Global_Attribute19,
     global_attribute20                =     X_Global_Attribute20,
     expiration_date                   =     X_Expiration_Date,
--Mahesh Chandak(GML) BUG# 1548597. update secondary_unit_of_measure,secondary_quantity and preferred_grade for secondary_uom,secondary_qty and qc_grade.base_uom and base_qty won't be used in the future..
-- start of 1548597
--Preetam Bamb (GML)     21-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
--INVCONV no need to update qc_grade,secondary_uom and secondary_qty.these columns no longer used
-- also update was failing since qc_grade is 25 and preferred_grade is 150
     --qc_grade				=    X_preferred_grade,
     --base_uom				=    X_Base_uom,
     --base_qty			 	=    X_Base_qty,
     --secondary_uom			=    X_Secondary_unit_of_measure,
     --secondary_qty			=    X_Secondary_quantity,
     secondary_unit_of_measure          =    X_secondary_unit_of_measure,
     secondary_quantity                 =    X_secondary_quantity,
     preferred_grade                    =    X_preferred_grade,
-- end of 1548597
     --togeorge 10/03/2000
     --added oke columns
     oke_contract_header_id		=    X_oke_contract_header_id,
     oke_contract_version_id		=    X_oke_contract_version_id,
     contract_id                        =    p_contract_id,   -- <GC FPJ>
     job_id                            =     X_job_id,                -- <SERVICES FPJ>
     contractor_first_name             =     X_contractor_first_name, -- <SERVICES FPJ>
     contractor_last_name              =     X_contractor_last_name,  -- <SERVICES FPJ>
     start_date                        =     X_assignment_start_date, -- <SERVICES FPJ>
     amount                            =     X_amount_db,             -- <SERVICES FPJ>
     manual_price_change_flag          =     p_manual_price_change_flag,   -- <Manual Price Override FPJ>
     -- <SVC_NOTIFICATIONS FPJ START>
     -- Reset the "Amount Billed notification sent" flag to NULL if there
     -- is an Amount change.
     svc_amount_notif_sent =
       decode ( x_amount_db, amount, svc_amount_notif_sent, NULL),
     -- Reset the "Assignment Completion notification sent" flag to NULL
     -- if there is an Assignment End Date change.
     svc_completion_notif_sent =
       decode ( x_expiration_date, expiration_date, svc_completion_notif_sent, NULL) , -- <SVC_NOTIFICATIONS FPJ END>
     tax_attribute_update_code = NVL(tax_attribute_update_code, l_tax_attribute_update_code), --<eTax Integration R12>
     ip_category_id = p_ip_category_id    -- Bug 7577670
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_LINES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END PO_LINES_PKG_SUD;

/
