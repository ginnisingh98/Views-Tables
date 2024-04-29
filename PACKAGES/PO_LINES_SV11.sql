--------------------------------------------------------
--  DDL for Package PO_LINES_SV11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_SV11" AUTHID CURRENT_USER as
/* $Header: POXPOL6S.pls 120.1.12000000.2 2007/10/03 07:43:42 lswamina ship $ */

/*===========================================================================
  PACKAGE NAME:		PO_LINES_SV11

  DESCRIPTION:		This package contains the server side Line level
			Application Program Interfaces (APIs).

  CLIENT/SERVER:	Server

  OWNER:

  FUNCTION/PROCEDURE:	update_line()
===========================================================================*/

/*===========================================================================
  PROCEDURE NAME:	update_line()

  DESCRIPTION:		This procedure will be updating a po line
                        and performing other update related activities.

  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Created 	21-Jul-95      SIYER

  Added the 5 OPM related clolumns 	10-Feb-00	PBAMB
===========================================================================*/

  PROCEDURE Update_line(X_Rowid                          VARCHAR2,
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
                       X_Unit_Price                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Un_Number_Id                   NUMBER,
                       X_Hazard_Class_Id                NUMBER,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER,   -- <SERVICES FPJ>
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
                       X_unapprove_doc           IN OUT NOCOPY BOOLEAN,
                       X_authorization_status    IN OUT NOCOPY VARCHAR2,
                       X_approved_flag           IN OUT NOCOPY VARCHAR2,
                       --< NBD TZ/Timestamp FPJ Start >
                       --X_combined_param          IN     VARCHAR2,
                       -- The following 5 parameters were being combined
                       -- into one due to the historic reasons. That is not
                       -- required now.
                       p_ship_window_open IN VARCHAR2,
                       p_type_lookup_code IN VARCHAR2,
                       p_change_date      IN VARCHAR2,
                       p_promised_date    IN DATE,
                       p_need_by_date     IN DATE,
                       --< NBD TZ/Timestamp FPJ End >
                       p_shipment_block_status   IN     VARCHAR2, -- bug 4042434
                       X_orig_unit_price         IN     NUMBER,
                       X_orig_quantity           IN     NUMBER,
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
--Preetam Bamb (GML)     10-feb-2000  Added 5 columns to the insert_row procedure
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
-- bug# 1548597.. add 3 fields for process item..
                       X_Secondary_Unit_of_measure       VARCHAR2 default null,
                       X_Secondary_Quantity              NUMBER default null,
                       X_preferred_Grade                 VARCHAR2 default null,
                       p_contract_id                    IN NUMBER DEFAULT NULL, -- <GC FPJ>
                       X_job_id                         NUMBER default null,    -- <SERVICES FPJ>
                       X_contractor_first_name          VARCHAR2 default null,  -- <SERVICES FPJ>
                       X_contractor_last_name           VARCHAR2 default null, -- <SERVICES FPJ>
                       X_assignment_start_date          DATE default null,      -- <SERVICES FPJ>
                       X_amount_db                      NUMBER default null,     -- <SERVICES FPJ>
                       -- <FPJ Advanced Price START>
                       X_Base_Unit_Price                NUMBER DEFAULT NULL,
                       -- <FPJ Advanced Price END>
                       p_manual_price_change_flag       VARCHAR2 default null, -- <Manual Price Override FPJ>
/*bug 5533266 this parameter is passed from PO_LINES_PKG3.update_row(POXPIPOL.pld)*/

                       p_planned_item_flag		VARCHAR2 default NULL --Bug 5533266
                       );

END PO_LINES_SV11;

 

/
