--------------------------------------------------------
--  DDL for Package PO_RFQ_VENDORS_PKG_S0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQ_VENDORS_PKG_S0" AUTHID CURRENT_USER as
/* $Header: POXPIR1S.pls 115.2 2002/11/23 02:53:09 sbull ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       X_Sequence_Num                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Vendor_Contact_Id              NUMBER,
                       X_Print_Flag                     VARCHAR2,
                       X_Print_Count                    NUMBER,
                       X_Printed_Date                   DATE,
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


END PO_RFQ_VENDORS_PKG_S0;

 

/
