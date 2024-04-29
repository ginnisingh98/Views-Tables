--------------------------------------------------------
--  DDL for Package WSH_PACKED_CONTAINERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PACKED_CONTAINERS_PKG" AUTHID CURRENT_USER as
/* $Header: WSHPCKHS.pls 115.1 99/07/16 08:19:26 porting ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Container_Id                   IN OUT NUMBER,
                       X_Delivery_Id                    NUMBER,
                       X_Container_Inventory_Item_Id    NUMBER,
                       X_Master_Container_Id            NUMBER,
                       X_Parent_Container_Id            NUMBER,
                       X_Quantity                       NUMBER,
                       X_Sequence_Number                NUMBER,
                       X_Parent_Sequence_Number         NUMBER,
                       X_Gross_Weight                   NUMBER,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Volume_Uom_Code                VARCHAR2,
                       X_Volume                         NUMBER,
                       X_Fill_Percent                   NUMBER,
                       X_Net_Weight                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Inventory_Location_Id          NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Master_Serial_Number           VARCHAR2,
                       X_Inventory_Status               VARCHAR2,
                       X_Ra_Interface_Status            VARCHAR2,
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
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Container_Id                     NUMBER,
                     X_Delivery_Id                      NUMBER,
                     X_Container_Inventory_Item_Id      NUMBER,
                     X_Master_Container_Id              NUMBER,
                     X_Parent_Container_Id              NUMBER,
                     X_Quantity                         NUMBER,
                     X_Sequence_Number                  NUMBER,
                     X_Parent_Sequence_Number           NUMBER,
                     X_Gross_Weight                     NUMBER,
                     X_Weight_Uom_Code                  VARCHAR2,
                     X_Volume_Uom_Code                  VARCHAR2,
                     X_Volume                           NUMBER,
                     X_Fill_Percent                     NUMBER,
                     X_Net_Weight                       NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Subinventory                     VARCHAR2,
                     X_Inventory_Location_Id            NUMBER,
                     X_Revision                         VARCHAR2,
                     X_Lot_Number                       VARCHAR2,
                     X_Serial_Number                    VARCHAR2,
                     X_Master_Serial_Number             VARCHAR2,
                     X_Inventory_Status                 VARCHAR2,
                     X_Ra_Interface_Status              VARCHAR2,
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
                       X_Container_Id                   NUMBER,
                       X_Delivery_Id                    NUMBER,
                       X_Container_Inventory_Item_Id    NUMBER,
                       X_Master_Container_Id            NUMBER,
                       X_Parent_Container_Id            NUMBER,
                       X_Quantity                       NUMBER,
                       X_Sequence_Number                NUMBER,
                       X_Parent_Sequence_Number         NUMBER,
                       X_Gross_Weight                   NUMBER,
                       X_Weight_Uom_Code                VARCHAR2,
                       X_Volume_Uom_Code                VARCHAR2,
                       X_Volume                         NUMBER,
                       X_Fill_Percent                   NUMBER,
                       X_Net_Weight                     NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Subinventory                   VARCHAR2,
                       X_Inventory_Location_Id          NUMBER,
                       X_Revision                       VARCHAR2,
                       X_Lot_Number                     VARCHAR2,
                       X_Serial_Number                  VARCHAR2,
                       X_Master_Serial_Number           VARCHAR2,
                       X_Inventory_Status               VARCHAR2,
                       X_Ra_Interface_Status            VARCHAR2,
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
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
                      );
  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END WSH_PACKED_CONTAINERS_PKG;

 

/