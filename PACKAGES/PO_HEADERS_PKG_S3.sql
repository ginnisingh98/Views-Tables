--------------------------------------------------------
--  DDL for Package PO_HEADERS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADERS_PKG_S3" AUTHID CURRENT_USER as
/* $Header: POXRFQHS.pls 120.0.12010000.1 2008/09/18 12:20:51 appldev noship $ */

/*===========================================================================
  PROCEDURE NAME:	Lock_row()


  DESCRIPTION:     Table Handler for Lock Row()



  PARAMETERS:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      dfong        05/96

===============================================================================*/


PROCEDURE   Lock_Row(X_Rowid                            VARCHAR2,
                     X_Po_Header_Id                     NUMBER,
                     X_Agent_Id                         NUMBER,
                     X_Type_Lookup_Code                 VARCHAR2,
                     X_Segment1                         VARCHAR2,
                     X_Summary_Flag                     VARCHAR2,
                     X_Enabled_Flag                     VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Vendor_Contact_Id                NUMBER,
                     X_Ship_To_Location_Id              NUMBER,
                     X_Bill_To_Location_Id              NUMBER,
                     X_Terms_Id                         NUMBER,
                     X_Ship_Via_Lookup_Code             VARCHAR2,
                     X_Fob_Lookup_Code                  VARCHAR2,
                     X_Freight_Terms_Lookup_Code        VARCHAR2,
                     X_Status_Lookup_Code               VARCHAR2,
                     X_Currency_Code                    VARCHAR2,
                     X_Rate_Type                        VARCHAR2,
                     X_Rate_Date                        DATE,
                     X_Rate                             NUMBER,
                     X_From_Header_Id                   NUMBER,
                     X_From_Type_Lookup_Code            VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Revision_Num                     NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                   X_Revised_Date                     VARCHAR2,
                     X_Revised_Date                     DATE,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_Printed_Date                     DATE,
                     X_Comments                         VARCHAR2,
                     X_Reply_Date                       DATE,
                     X_Reply_Method_Lookup_Code         VARCHAR2,
                     X_Rfq_Close_Date                   DATE,
                     X_Quote_Type_Lookup_Code           VARCHAR2,
                     X_Quotation_Class_Code             VARCHAR2,
                     X_Quote_Warning_Delay              NUMBER,
                     X_Quote_Vendor_Quote_Number        VARCHAR2,
                     X_Closed_Date                      DATE,
                     X_Approval_Required_Flag           VARCHAR2,
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
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
                    );


/*===========================================================================
  PROCEDURE NAME:	Update_row()


  DESCRIPTION:     Table Handler for Update Row()



  PARAMETERS:

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      dkfchan

===============================================================================*/

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       X_Agent_Id                       NUMBER,
                       X_Type_Lookup_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Summary_Flag                   VARCHAR2,
                       X_Enabled_Flag                   VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Bill_To_Location_Id            NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Fob_Lookup_Code                VARCHAR2,
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
                       X_Revision_Num                   NUMBER,
-- Bug 902976, zxzhang, 10/04/99
-- Change REVISED_DATE from VarChar(25) to Date.
--                     X_Revised_Date                   VARCHAR2,
                       X_Revised_Date                   DATE,
                       X_Note_To_Vendor                 VARCHAR2,
                       X_Printed_Date                   DATE,
                       X_Comments                       VARCHAR2,
                       X_Reply_Date                     DATE,
                       X_Reply_Method_Lookup_Code       VARCHAR2,
                       X_Rfq_Close_Date                 DATE,
                       X_Quote_Type_Lookup_Code         VARCHAR2,
                       X_Quotation_Class_Code           VARCHAR2,
                       X_Quote_Warning_Delay            NUMBER,
                       X_Quote_Vendor_Quote_Number      VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Approval_Required_Flag         VARCHAR2,
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
                       X_Attribute15                    VARCHAR2
                      );

END PO_HEADERS_PKG_S3;

/
