--------------------------------------------------------
--  DDL for Package PO_HEADERS_SV11
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_SV11" AUTHID CURRENT_USER AS
/* $Header: POXPOH6S.pls 120.3 2008/01/04 12:31:50 ggandhi ship $ */

/*===========================================================================
  PROCEDURE NAME:	insert_po()

  DESCRIPTION:
          - call PO HEADERS table handler to insert the header
          - call notification API to create a notification
			[DEBUG;SEND_NOTIFICATION]
	  - This procedure is moved from po_headers_sv1 to po_headers_sv11
	    because of a problem when adding extra parameters.
	    No good explanation was found. But it is likely to be caused
	    by the maximun stack size for each package.

  PARAMETERS:

  DESIGN REFERENCES:	../POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
 PROCEDURE   insert_po(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Header_Id                   IN OUT NOCOPY NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                IN OUT NOCOPY VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Start_Date_Active              DATE,
                       X_End_Date_Active                DATE,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Pay_On_Code                    VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Status_Lookup_Code             VARCHAR2,
                       X_Currency_Code                  VARCHAR2,
                       X_Rate_Type                      VARCHAR2,
                       X_Rate_Date                      DATE,
                       X_Rate                           NUMBER,
                       X_From_Header_Id                 NUMBER,
                       X_From_Type_Lookup_Code          VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Blanket_Total_Amount           NUMBER,
                       X_Authorization_Status           VARCHAR2,
                       X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_Revised_Date                   VARCHAR2,
                       X_Revised_Date                   DATE,
                       X_Approved_Flag                  VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Amount_Limit                   NUMBER,
                       X_Min_Release_Amount             NUMBER,
                       X_Note_To_Authorizer             VARCHAR2,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_Note_To_Receiver               VARCHAR2,
                       X_Print_Count                    NUMBER,
                       X_Printed_Date                   DATE,
                       X_Vendor_Order_Num               VARCHAR2,
                       X_Confirming_Order_Flag          VARCHAR2,
                       X_Comments                       VARCHAR2,
                       X_Reply_Date                     DATE,
                       X_Reply_Method_Lookup_Code       VARCHAR2,
                       X_Rfq_Close_Date                 DATE,
                       X_Quote_Type_Lookup_Code         VARCHAR2,
                       X_Quotation_Class_Code           VARCHAR2,
                       X_Quote_Warning_Delay_Unit       VARCHAR2,
                       X_Quote_Warning_Delay            NUMBER,
                       X_Quote_Vendor_Quote_Number      VARCHAR2,
                       X_Acceptance_Required_Flag       VARCHAR2,
                       X_Acceptance_Due_Date            DATE,
                       X_Closed_Date                    DATE,
                       X_User_Hold_Flag                 VARCHAR2,
                       X_Approval_Required_Flag         VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Firm_Date                      DATE,
--                       X_Combined_Param                 VARCHAR2,
		       X_Frozen_Flag			VARCHAR2,
		       X_Supply_Agreement_Flag		VARCHAR2,
		       X_Global_Agreement_Flag		VARCHAR2,
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
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
	  	       X_Global_Attribute_Category	VARCHAR2,
	  	       X_Global_Attribute1		VARCHAR2,
	  	       X_Global_Attribute2		VARCHAR2,
	  	       X_Global_Attribute3		VARCHAR2,
	  	       X_Global_Attribute4		VARCHAR2,
	  	       X_Global_Attribute5		VARCHAR2,
	  	       X_Global_Attribute6		VARCHAR2,
	  	       X_Global_Attribute7		VARCHAR2,
	  	       X_Global_Attribute8		VARCHAR2,
	  	       X_Global_Attribute9		VARCHAR2,
	  	       X_Global_Attribute10		VARCHAR2,
	  	       X_Global_Attribute11		VARCHAR2,
	  	       X_Global_Attribute12		VARCHAR2,
	  	       X_Global_Attribute13    		VARCHAR2,
	  	       X_Global_Attribute14		VARCHAR2,
	  	       X_Global_Attribute15		VARCHAR2,
	  	       X_Global_Attribute16		VARCHAR2,
	  	       X_Global_Attribute17		VARCHAR2,
	  	       X_Global_Attribute18		VARCHAR2,
	  	       X_Global_Attribute19		VARCHAR2,
	  	       X_Global_Attribute20		VARCHAR2,
                       X_Manual                         BOOLEAN,
                       X_Price_Update_Tolerance         NUMBER,
                       p_shipping_control          IN   VARCHAR2 DEFAULT NULL,   -- <INBOUND LOGISTICS FPJ>
                       p_encumbrance_required_flag IN VARCHAR2 DEFAULT NULL,  --<ENCUMBRANCE FPJ>
                       p_org_id                     IN     NUMBER DEFAULT NULL ,     -- <R12 MOAC>
                       p_enable_all_sites IN varchar2 DEFAULT NULL  --<R12GCPA>
		       );

END PO_HEADERS_SV11;

/
