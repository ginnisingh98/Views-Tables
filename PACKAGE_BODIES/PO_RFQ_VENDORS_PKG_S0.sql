--------------------------------------------------------
--  DDL for Package Body PO_RFQ_VENDORS_PKG_S0
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQ_VENDORS_PKG_S0" as
/* $Header: POXPIR1B.pls 115.2 2002/11/23 02:53:20 sbull ship $ */


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

   ) IS

     CURSOR C IS SELECT rowid FROM PO_RFQ_VENDORS
                 WHERE sequence_num = X_Sequence_Num
                 AND   po_header_id = X_Po_Header_Id;

    BEGIN


       INSERT INTO PO_RFQ_VENDORS(
               po_header_id,
               sequence_num,
               last_update_date,
               last_updated_by,
               last_update_login,
               creation_date,
               created_by,
               vendor_id,
               vendor_site_id,
               vendor_contact_id,
               print_flag,
               print_count,
               printed_date,
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
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15
             ) VALUES (
               X_Po_Header_Id,
               X_Sequence_Num,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Last_Update_Login,
               X_Creation_Date,
               X_Created_By,
               X_Vendor_Id,
               X_Vendor_Site_Id,
               X_Vendor_Contact_Id,
               X_Print_Flag,
               X_Print_Count,
               X_Printed_Date,
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
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

END PO_RFQ_VENDORS_PKG_S0;

/
