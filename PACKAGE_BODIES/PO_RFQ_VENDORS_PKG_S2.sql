--------------------------------------------------------
--  DDL for Package Body PO_RFQ_VENDORS_PKG_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQ_VENDORS_PKG_S2" as
/* $Header: POXPIR3B.pls 120.0.12010000.1 2008/09/18 12:20:57 appldev noship $ */

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

 ) IS
 BEGIN
   UPDATE PO_RFQ_VENDORS
   SET
     po_header_id                      =     X_Po_Header_Id,
     sequence_num                      =     X_Sequence_Num,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login,
     vendor_id                         =     X_Vendor_Id,
     vendor_site_id                    =     X_Vendor_Site_Id,
     vendor_contact_id                 =     X_Vendor_Contact_Id,
     print_flag                        =     X_Print_Flag,
     print_count                       =     X_Print_Count,
     printed_date                      =     X_Printed_Date,
     attribute_category                =     X_Attribute_Category,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PO_RFQ_VENDORS
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE Delete_All_Vendors(X_po_header_id NUMBER) IS
  BEGIN
    DELETE FROM PO_RFQ_VENDORS
    WHERE  po_header_id = X_po_header_id;

  exception
    when NO_DATA_FOUND then null;
    when OTHERS        then raise;
  END Delete_All_Vendors;

END PO_RFQ_VENDORS_PKG_S2;

/
