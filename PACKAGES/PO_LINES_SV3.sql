--------------------------------------------------------
--  DDL for Package PO_LINES_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV3" AUTHID CURRENT_USER as
/* $Header: POXPOL3S.pls 120.0 2005/06/01 20:57:13 appldev noship $ */


/*===========================================================================
  PACKAGE NAME:		PO_LINES_SV3

  DESCRIPTION:		This package contains the server side Line level
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:		Sudha Iyer

  FUNCTION/PROCEDURE:	insert_line()

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	insert_line()

  DESCRIPTION:		This procedure will be inserting a po line.
                        After inserting this line, it checks to see if the
                        document's revision has to be incremented, the doc
                        has to be unapproved. If possible it autocreates
                        a shipment and a distribution.


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	26-Jul-95      SIYER

  			Added 5 fields  08-feb-00	PBAMB
  			Preetam Bamb (GML-OPM)
  			Added the following fields to replace PO_LINES flexfield
			Bug# 1056597 X_Base_Uom,X_Base_qty,X_Secondary_Uom,
			X_Secondary_Qty,X_Qc_Grade
                        Mahesh Chandak(GML)bug# 1548597 base_uom and base_qty
                        won't be used in the  future.we are keeping secondary_
                        uom,secondary_qty and qc_grade for supporting Common
                        Purchasing. we will have 3 new fields secondary_unit_of
                        _measure ,secondary_quantity and preferred_grade column
                        in the  table.

===========================================================================*/

 procedure insert_line(X_Rowid                   IN OUT NOCOPY VARCHAR2,
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
                       X_Unit_Price                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Un_Number_Id                   NUMBER,
                       X_Hazard_Class_Id                NUMBER,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       x_from_line_location_id          NUMBER,  -- <SERVICES FPJ>
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
		       X_Tax_Code_Id			NUMBER,
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
                       X_revise_header                  BOOLEAN,
                       X_revision_num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_revised_date                   VARCHAR2,
                       X_revised_date                   DATE,
                       X_approved_flag                  VARCHAR2,
                       X_header_row_id                  VARCHAR2,
                       X_type_lookup_code               VARCHAR2,
                       X_ship_to_location_id            NUMBER,
                       X_ship_org_id                    NUMBER,
                       X_need_by_date                   DATE,
                       X_promised_date                  DATE,
                       X_receipt_required_flag          VARCHAR2,
                       X_invoice_close_tolerance        NUMBER,
                       X_receive_close_tolerance        NUMBER,
                       X_planned_item_flag              VARCHAR2,
                       X_outside_operation_flag         VARCHAR2,
                       X_destination_type_code          VARCHAR2,
                       X_expense_accrual_code           VARCHAR2,
                       X_dist_blk_status                VARCHAR2,
                       X_accrue_on_receipt_flag IN OUT NOCOPY  VARCHAR2,
                       X_ok_to_autocreate_ship          VARCHAR2,
                       X_autocreated_ship       IN OUT NOCOPY  BOOLEAN,
                       X_line_location_id       IN OUT NOCOPY  NUMBER,
                       X_vendor_id                      NUMBER,
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
-- Preetam Bamb (GML-OPM) Added the following fields to replace PO_LINES flexfield
-- Bug# 1056597
-- Mahesh Chandak(GML-OPM).Add secondary_unit_of_measure,secondary_quantity,preferred_grade.
                       X_Base_Uom                           VARCHAR2,
                       X_Base_Qty                           NUMBER,
                       X_Secondary_Uom                    VARCHAR2,
                       X_Secondary_Qty                    NUMBER,
                       X_Qc_Grade                         VARCHAR2,
		       --togeorge 10/03/2000
		       --added oke columns
		       X_oke_contract_header_id   	    NUMBER default null,
		       X_oke_contract_version_id   	    NUMBER default null,
 -- mchandak 1548597
                     X_Secondary_Unit_Of_Measure          VARCHAR2 default null,
                     X_Secondary_Quantity                 NUMBER default null,
                     X_Preferred_Grade                    VARCHAR2 default null,
                     p_contract_id                     IN NUMBER DEFAULT NULL,  -- <GC FPJ>
                       X_job_id                  IN     NUMBER   default null,  -- <SERVICES FPJ>
                       X_contractor_first_name   IN     VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_contractor_last_name    IN     VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_assignment_start_date   IN     DATE     default null,  -- <SERVICES FPJ>
                       X_amount_db               IN     NUMBER   default null,  -- <SERVICES FPJ>
                       X_order_type_lookup_code  IN     VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_purchase_basis          IN     VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_matching_basis          IN     VARCHAR2 default null,   -- <SERVICES FPJ>
                       -- <FPJ Advanced Price START>
                       X_Base_Unit_Price                NUMBER DEFAULT NULL,
                       -- <FPJ Advanced Price END>
                       p_manual_price_change_flag  IN        VARCHAR2 default null,  -- <Manual Price Override FPJ>
                       p_consigned_from_supplier_flag IN        VARCHAR2 default null,  --bug 3523348
                       p_org_id                     IN     NUMBER   default null     -- <R12 MOAC>
                      );


END PO_LINES_SV3;

 

/
