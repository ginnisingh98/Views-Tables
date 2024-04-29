--------------------------------------------------------
--  DDL for Package MTL_MFG_PART_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_MFG_PART_NUMBERS_PKG" AUTHID CURRENT_USER as
/* $Header: INVIDMPS.pls 120.2 2005/07/01 06:38:05 appldev ship $ */


  PROCEDURE Insert_Row(X_Rowid          IN OUT NOCOPY   VARCHAR2,
                       X_Manufacturer_Id                NUMBER,
                       X_Mfg_Part_Num                   VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Description                    VARCHAR2,
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

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Manufacturer_Id                  NUMBER,
                     X_Mfg_Part_Num                     VARCHAR2,
                     X_Inventory_Item_Id                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Description                      VARCHAR2,
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



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Manufacturer_Id                NUMBER,
                       X_Mfg_Part_Num                   VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Description                    VARCHAR2,
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
  PROCEDURE  Call_Sync_Index;

END MTL_MFG_PART_NUMBERS_PKG;

 

/
