--------------------------------------------------------
--  DDL for Package PO_RFQ_VENDORS_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RFQ_VENDORS_PKG_S2" AUTHID CURRENT_USER as
/* $Header: POXPIR3S.pls 120.0.12010000.1 2008/09/18 12:20:59 appldev noship $ */

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Po_Header_Id                   NUMBER,
                       X_Sequence_Num                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
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


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE Delete_All_Vendors(X_po_header_id NUMBER);

END PO_RFQ_VENDORS_PKG_S2;

/
