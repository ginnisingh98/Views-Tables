--------------------------------------------------------
--  DDL for Package Body PO_LINES_PKG_SI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_PKG_SI" as
/* $Header: POXPIL1B.pls 120.5 2005/09/20 02:39:59 sjadhav noship $ */

/*History
  Preetam Bamb (GML)    10-feb-2000  Added 5 columns to the insert_row procedure
          X_Base_Uom, X_Base_Qty  , X_Secondary_Uom, X_Secondary_Qty, X_Qc_Grade
*/

-- Mahesh Chandak(GML-OPM).bug# 1548597.Add secondary_unit_of_measure,secondary_quantity,preferred_grade for CR.base_uom and base_qty won't be used in future..

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Line_Id              IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Line_Type_Id                   NUMBER,
                       X_Line_Num                       NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
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
                       x_from_line_location_id          NUMBER,   -- <SERVICES FPJ>
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
-- Mahesh Chandak(GML-OPM).bug# 1548597.Add secondary_unit_of_measure,secondary_quantity,preferred_grade for CR.base_uom and base_qty won't be used in future..
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
                     X_Base_Uom                           VARCHAR2,
                     X_Base_Qty                           NUMBER,
         X_Secondary_Uom                VARCHAR2,
         X_Secondary_Qty              NUMBER,
         X_Qc_Grade               VARCHAR2,
         --togeorge 10/03/2000
         --added oke columns
         X_oke_contract_header_id         NUMBER default null,
         X_oke_contract_version_id        NUMBER default null,
                     --mchandak 1548597
         X_Secondary_Unit_Of_Measure      VARCHAR2 default null,
         X_Secondary_Quantity     NUMBER default null,
         X_Preferred_Grade        VARCHAR2 default null,
                     p_contract_id                     IN NUMBER DEFAULT NULL,  -- <GC FPJ>
                       X_job_id                  IN     NUMBER DEFAULT NULL,    -- <SERVICES FPJ>
                       X_contractor_first_name   IN     VARCHAR2 DEFAULT NULL,  -- <SERVICES FPJ>
                       X_contractor_last_name    IN     VARCHAR2 DEFAULT NULL,  -- <SERVICES FPJ>
                       X_assignment_start_date   IN     DATE DEFAULT NULL,      -- <SERVICES FPJ>
                       X_amount_db               IN     NUMBER DEFAULT NULL,    -- <SERVICES FPJ>
                       X_order_type_lookup_code  IN     VARCHAR2 DEFAULT NULL,  -- <SERVICES FPJ>
                       X_purchase_basis          IN     VARCHAR2 DEFAULT NULL,  -- <SERVICES FPJ>
                       X_matching_basis          IN     VARCHAR2 DEFAULT NULL,   -- <SERVICES FPJ>
                       p_manual_price_change_flag   IN     VARCHAR2 DEFAULT NULL,   -- <Manual Price Override FPJ>
                       p_org_id                     IN     NUMBER DEFAULT NULL,     -- <R12 MOAC>
                       p_ip_category_id             IN     NUMBER DEFAULT NULL      -- <Unified Catalog R12>
   ) IS
     CURSOR C IS SELECT rowid FROM PO_LINES
                 WHERE po_line_id = X_Po_Line_Id;

      CURSOR S IS SELECT po_lines_s.nextval FROM sys.dual;

      x_progress   VARCHAR2(3)  := '';
    --<eTax Integration R12 Start>
    l_tax_attribute_update_code PO_LINES_ALL.tax_attribute_update_code%type;
    l_type_lookup_code          PO_HEADERS_ALL.type_lookup_code%type;
    --<eTax Integration R12  End>


    BEGIN
      x_progress := '010';

      if (X_Po_Line_Id is NULL) then
        OPEN S;
        FETCH S INTO X_Po_Line_Id;
        CLOSE S;
      end if;

      x_progress := '020';

        --<eTax Integration  R12 Start>
        SELECT poh.type_lookup_code
        INTO l_type_lookup_code
        FROM po_headers_all poh
        WHERE poh.po_header_id = x_po_header_id;

        IF l_type_lookup_code IN ('STANDARD', 'PLANNED') THEN
            l_tax_attribute_update_code := 'CREATE';
        END IF;
        --<eTax Integration R12 End>

      x_progress := '030';

       INSERT INTO PO_LINES    (
               po_line_id,
               last_update_date,
               last_updated_by,
               po_header_id,
               line_type_id,
               line_num,
               last_update_login,
               creation_date,
               created_by,
               item_id,
               item_revision,
               category_id,
               item_description,
               unit_meas_lookup_code,
               quantity_committed,
               committed_amount,
               allow_price_override_flag,
               not_to_exceed_price,
               list_price_per_unit,
               -- <FPJ Advanced Price START>
               base_unit_price,
               -- <FPJ Advanced Price END>
               unit_price,
               quantity,
               un_number_id,
               hazard_class_id,
               note_to_vendor,
               from_header_id,
               from_line_id,
               from_line_location_id,                         -- <SERVICES FPJ>
               min_order_quantity,
               max_order_quantity,
               qty_rcv_tolerance,
               over_tolerance_error_flag,
               market_price,
               unordered_flag,
               closed_flag,
               user_hold_flag,
               cancel_flag,
               cancelled_by,
               cancel_date,
               cancel_reason,
               firm_status_lookup_code,
               firm_date,
               vendor_product_num,
               contract_num,
               taxable_flag,
               tax_code_id,
               type_1099,
               capital_expense_flag,
               negotiated_by_preparer_flag,
               attribute_category,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               reference_num,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               min_release_amount,
               price_type_lookup_code,
               closed_code,
               price_break_lookup_code,
               government_context,
               closed_date,
               closed_reason,
               closed_by,
               transaction_reason_code,
    global_attribute_category,
    global_attribute1,
    global_attribute2,
    global_attribute3,
    global_attribute4,
    global_attribute5,
    global_attribute6,
    global_attribute7,
    global_attribute8,
    global_attribute9,
    global_attribute10,
    global_attribute11,
    global_attribute12,
    global_attribute13,
    global_attribute14,
    global_attribute15,
    global_attribute16,
    global_attribute17,
    global_attribute18,
    global_attribute19,
    global_attribute20,
                expiration_date,
/** Mahesh Chandak(GML)bug# 1548597 base_uom and base_qty won't be used
 in the  future.we are keeping secondary_uom,secondary_qty and qc_grade for
 supporting Common Purchasing. we will have 3 new fields secondary_unit_of_measure, secondary_quantity and  preferred_grade columns in the table **/
-- start of 1548597
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
          --base_uom,
    --base_qty,
-- INVCONV no need to insert into secondary_uom,qty and qc_grade.no longer used.
-- also preferred_grade is 150 and qc_grade is 25 which makes it incompatible.
    --secondary_uom,
    --secondary_qty,
    --qc_grade,
    --togeorge 10/03/2000
    --added oke columns
    oke_contract_header_id,
    oke_contract_version_id,
                secondary_unit_of_measure,
                secondary_quantity,
                preferred_grade,
-- end of 1548597
                contract_id,             -- <GC FPJ>
                job_id,                  -- <SERVICES FPJ>
                contractor_first_name,   -- <SERVICES FPJ>
                contractor_last_name,    -- <SERVICES FPJ>
                start_date,              -- <SERVICES FPJ>
                amount,                  -- <SERVICES FPJ>
                order_type_lookup_code,  -- <SERVICES FPJ>
                purchase_basis,          -- <SERVICES FPJ>
                matching_basis,           -- <SERVICES FPJ>
                manual_price_change_flag,  -- <Manual Price Override FPJ>
                Org_Id,                    -- <R12 MOAC>
                ip_category_id,             -- <Unified Catalog R12>
                tax_attribute_update_code --<eTax Integration R12>
            ) VALUES (
               X_Po_Line_Id,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Po_Header_Id,
               X_Line_Type_Id,
               X_Line_Num,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Item_Id,
               X_Item_Revision,
               X_Category_Id,
               X_Item_Description,
               X_Unit_Meas_Lookup_Code,
               X_Quantity_Committed,
               X_Committed_Amount,
               X_Allow_Price_Override_Flag,
               X_Not_To_Exceed_Price,
               X_List_Price_Per_Unit,
               -- <FPJ Advanced Price START>
               X_Base_Unit_Price,
               -- <FPJ Advanced Price END>
               X_Unit_Price,
               X_Quantity,
               X_Un_Number_Id,
               X_Hazard_Class_Id,
               X_Note_To_Vendor,
               X_From_Header_Id,
               X_From_Line_Id,
               x_from_line_location_Id,                       -- <SERVICES FPJ>
               X_Min_Order_Quantity,
               X_Max_Order_Quantity,
               X_Qty_Rcv_Tolerance,
               X_Over_Tolerance_Error_Flag,
               X_Market_Price,
               X_Unordered_Flag,
               X_Closed_Flag,
               X_User_Hold_Flag,
               X_Cancel_Flag,
               X_Cancelled_By,
               X_Cancel_Date,
               X_Cancel_Reason,
               X_Firm_Status_Lookup_Code,
               X_Firm_Date,
               X_Vendor_Product_Num,
               X_Contract_Num,
               X_Taxable_Flag,
               X_Tax_Code_Id,
               X_Type_1099,
               X_Capital_Expense_Flag,
               X_Negotiated_By_Preparer_Flag,
               X_Attribute_Category,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Reference_Num,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Min_Release_Amount,
               X_Price_Type_Lookup_Code,
               X_Closed_Code,
               X_Price_Break_Lookup_Code,
               X_Government_Context,
               X_Closed_Date,
               X_Closed_Reason,
               X_Closed_By,
               X_Transaction_Reason_Code,
               X_Global_Attribute_Category,
               X_Global_Attribute1,
               X_Global_Attribute2,
               X_Global_Attribute3,
               X_Global_Attribute4,
               X_Global_Attribute5,
               X_Global_Attribute6,
               X_Global_Attribute7,
               X_Global_Attribute8,
               X_Global_Attribute9,
               X_Global_Attribute10,
               X_Global_Attribute11,
               X_Global_Attribute12,
               X_Global_Attribute13,
               X_Global_Attribute14,
               X_Global_Attribute15,
               X_Global_Attribute16,
               X_Global_Attribute17,
               X_Global_Attribute18,
               X_Global_Attribute19,
               X_Global_Attribute20,
               X_Expiration_Date,
--Mahesh Chandak(GML) BUG# 1548597. insert secondary_unit_of_measure,secondary_quantity and preferred_grade for secondary_uom,secondary_qty and qc_grade.
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
--Bug# 1056597
-- start of 1548597
         --X_Base_Uom,
         --X_Base_Qty,
-- INVCONV comment the 3 columns
               --X_Secondary_Unit_Of_Measure,
               --X_Secondary_Quantity,
               --X_Preferred_Grade,
-- end of 1548597
         --togeorge 10/03/2000
         --added oke columns
         X_oke_contract_header_id,
         X_oke_contract_version_id,
-- start of 1548597
               X_Secondary_Unit_Of_Measure,
               X_Secondary_Quantity,
               X_Preferred_Grade,
-- end of 1548597
               p_contract_id,               -- <GC FPJ>
               X_job_id,                    -- <SERVICES FPJ>
               X_contractor_first_name,     -- <SERVICES FPJ>
               X_contractor_last_name,      -- <SERVICES FPJ>
               X_assignment_start_date,     -- <SERVICES FPJ>
               X_amount_db,                 -- <SERVICES FPJ>
               X_order_type_lookup_code,    -- <SERVICES FPJ>
               X_purchase_basis,            -- <SERVICES FPJ>
               X_matching_basis,             -- <SERVICES FPJ>
               p_manual_price_change_flag,    -- <Manual Price Override FPJ>
               p_org_id,                      -- <R12 MOAC>
               p_ip_category_id,               -- <Unified Catalog R12>
               l_tax_attribute_update_code --<eTax Integration R12>
         );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;

END PO_LINES_PKG_SI;

/
