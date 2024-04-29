--------------------------------------------------------
--  DDL for Package PO_LINES_PKG_SUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_PKG_SUD" AUTHID CURRENT_USER as
/* $Header: POXPIL4S.pls 120.0.12010000.2 2008/12/18 07:43:10 mugoel ship $ */

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
-- Mahesh Chandak(GML-OPM).Remove all the fields added by Bug 1056597.Instead use secondary_unit_of_measure,secondary_quantity,preferred_grade.
--Preetam Bamb (GML)     21-feb-2000  Added 5 columns to the update_row procedure
--Bug# 1056597
                     X_Base_Uom                           VARCHAR2,
                     X_Base_Qty                           NUMBER,
                     X_Secondary_Uom                      VARCHAR2,
                     X_Secondary_Qty                      NUMBER,
                     X_Qc_Grade                           VARCHAR2,
		     --togeorge 10/03/2000
		     --added oke columns
		     X_oke_contract_header_id   	  NUMBER default null,
		     X_oke_contract_version_id   	  NUMBER default null,
-- 1548597 add 3 new process fields..
                     X_Secondary_Unit_of_measure        VARCHAR2 default null,
                     X_Secondary_Quantity               NUMBER default null,
                     X_preferred_Grade                  VARCHAR2 default null,
                     p_contract_id                 IN   NUMBER DEFAULT NULL,    -- <GC FPJ>
                       X_job_id                         NUMBER,                 -- <SERVICES FPJ>
                       X_contractor_first_name          VARCHAR2,               -- <SERVICES FPJ>
                       X_contractor_last_name           VARCHAR2,               -- <SERVICES FPJ>
                       X_assignment_start_date          DATE,                   -- <SERVICES FPJ>
                       X_amount_db                      NUMBER,                  -- <SERVICES FPJ>
                       p_manual_price_change_flag       VARCHAR2,               -- <Manual Price Override FPJ>
                       p_ip_category_id                 NUMBER                  -- Bug 7577670
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PO_LINES_PKG_SUD;

/
