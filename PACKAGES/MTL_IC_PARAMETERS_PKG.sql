--------------------------------------------------------
--  DDL for Package MTL_IC_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_IC_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: INVSDICS.pls 115.8 2003/10/13 11:47:48 viberry ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Ship_Organization_Id           NUMBER,
                       X_Sell_Organization_Id           NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Customer_Site_Id               NUMBER,
                       X_Cust_Trx_Type_Id               NUMBER,
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
                       X_Revalue_Average_Flag           VARCHAR2,
                       X_Freight_Code_Combination_Id    NUMBER,
		       X_Inv_Currency_Code              NUMBER,
		       X_Flow_Type                      NUMBER DEFAULT NULL, -- added as part of patchset-j development
		       X_Intercompany_COGS_Account_Id   NUMBER DEFAULT NULL,
		       X_Inventory_Accrual_Account_Id   NUMBER DEFAULT NULL,
		       X_Expense_Accrual_Account_Id     NUMBER DEFAULT NULL

                      );


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Ship_Organization_Id             NUMBER,
                     X_Sell_Organization_Id             NUMBER,
                     X_Vendor_Id                        NUMBER,
                     X_Vendor_Site_Id                   NUMBER,
                     X_Customer_Id                      NUMBER,
                     X_Address_Id                       NUMBER,
                     X_Customer_Site_Id                 NUMBER,
                     X_Cust_Trx_Type_Id                 NUMBER,
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
                     X_Attribute15                      VARCHAR2,
                     X_Revalue_Average_Flag             VARCHAR2,
                     X_Freight_Code_Combination_Id      NUMBER,
		     X_Inv_Currency_Code                NUMBER,
		     X_Flow_Type                      NUMBER DEFAULT NULL, -- added as part of patchset-j development
		     X_Intercompany_COGS_Account_Id   NUMBER DEFAULT NULL,
		     X_Inventory_Accrual_Account_Id   NUMBER DEFAULT NULL,
		     X_Expense_Accrual_Account_Id     NUMBER DEFAULT NULL

                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Ship_Organization_Id           NUMBER,
                       X_Sell_Organization_Id           NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Vendor_Id                      NUMBER,
                       X_Vendor_Site_Id                 NUMBER,
                       X_Customer_Id                    NUMBER,
                       X_Address_Id                     NUMBER,
                       X_Customer_Site_Id               NUMBER,
                       X_Cust_Trx_Type_Id               NUMBER,
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
                       X_Revalue_Average_Flag           VARCHAR2,
                       X_Freight_Code_Combination_Id    NUMBER,
		       X_Inv_Currency_Code              NUMBER,
		       X_Flow_Type                      NUMBER DEFAULT NULL, -- added as part of patchset-j development
		       X_Intercompany_COGS_Account_Id   NUMBER DEFAULT NULL,
		       X_Inventory_Accrual_Account_Id   NUMBER DEFAULT NULL,
		       X_Expense_Accrual_Account_Id     NUMBER DEFAULT NULL

                      );


  PROCEDURE Delete_Row(X_Ship_Organization_Id       NUMBER,
                       X_Sell_Organization_Id       NUMBER);

END MTL_IC_PARAMETERS_PKG;

 

/
