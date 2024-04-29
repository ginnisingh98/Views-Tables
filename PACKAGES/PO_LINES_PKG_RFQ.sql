--------------------------------------------------------
--  DDL for Package PO_LINES_PKG_RFQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_PKG_RFQ" AUTHID CURRENT_USER as
/* $Header: POXPIL3S.pls 120.0.12010000.1 2008/09/18 12:20:45 appldev noship $ */

  PROCEDURE Lock_Row_RFQ(X_Rowid                            VARCHAR2,
                     X_Po_Line_Id                       NUMBER,
                     X_Po_Header_Id                     NUMBER,
                     X_Line_Type_Id                     NUMBER,
                     X_Line_Num                         NUMBER,
                     X_Item_Id                          NUMBER,
                     X_Item_Revision                    VARCHAR2,
                     X_Category_Id                      NUMBER,
                     X_Item_Description                 VARCHAR2,
                     X_Unit_Meas_Lookup_Code            VARCHAR2,
                     X_Unit_Price                       NUMBER,
                     X_Quantity                         NUMBER,
                     X_Un_Number_Id                     NUMBER,
                     X_Hazard_Class_Id                  NUMBER,
                     X_Note_To_Vendor                   VARCHAR2,
                     X_From_Header_Id                   NUMBER,
                     X_From_Line_Id                     NUMBER,
                     X_Min_Order_Quantity               NUMBER,
                     X_Max_Order_Quantity               NUMBER,
                     X_Vendor_Product_Num               VARCHAR2,
                     X_Taxable_Flag                     VARCHAR2,
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
END PO_LINES_PKG_RFQ;

/
