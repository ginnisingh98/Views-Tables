--------------------------------------------------------
--  DDL for Package BOM_CONFIG_EXPLOSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CONFIG_EXPLOSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: OEXCBCES.pls 115.1 99/07/16 08:11:45 porting ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT VARCHAR2,
                       X_Top_Bill_Sequence_Id           NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Effectivity_Date               DATE,
                       X_Header_Id                      NUMBER,
                       X_Line_Id                        NUMBER,
                       X_Sort_Order                     VARCHAR2,
                       X_Select_Flag                    VARCHAR2,
                       X_Select_Quantity                NUMBER,
                       X_Price_List_Id                  NUMBER,
                       X_List_Price                     NUMBER,
                       X_Selling_Price                  NUMBER,
		       X_Required_For_Revenue		NUMBER,
                       X_Session_Id                     NUMBER,
                       X_Context                        VARCHAR2,
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
                       X_Pricing_context                VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute1             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute2             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute3             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute4             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute5             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute6             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute7             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute8             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute9             VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute10            VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute11            VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute12            VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute13            VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute14            VARCHAR2 DEFAULT NULL,
                       X_Pricing_attribute15            VARCHAR2 DEFAULT NULL
                      );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Select_Flag                    VARCHAR2,
                       X_Select_Quantity                NUMBER
                      );

END BOM_CONFIG_EXPLOSIONS_PKG;

 

/
