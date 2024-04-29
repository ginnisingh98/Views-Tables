--------------------------------------------------------
--  DDL for Package Body MTL_IC_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_IC_PARAMETERS_PKG" as
/* $Header: INVSDICB.pls 115.9 2003/11/24 19:23:42 sthamman ship $ */

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
  ) IS

CURSOR C IS
    SELECT rowid FROM MTL_INTERCOMPANY_PARAMETERS
    WHERE ship_organization_id = X_Ship_Organization_Id
    AND   sell_organization_id = X_Sell_Organization_Id
    AND  ( (inv_control.get_current_release_level < inv_release.GET_J_RELEASE_LEVEL)
           OR
	 (inv_control.get_current_release_level >= inv_release.GET_J_RELEASE_LEVEL AND flow_type = X_Flow_Type)
	 );

l_Flow_Type                      NUMBER;
l_Intercompany_COGS_Account_Id   NUMBER;
l_Inventory_Accrual_Account_Id   NUMBER;
l_Expense_Accrual_Account_Id     NUMBER;

   BEGIN

   IF inv_control.get_current_release_level >= inv_release.GET_J_RELEASE_LEVEL THEN
       l_Flow_Type  := X_Flow_Type;
       l_Intercompany_COGS_Account_Id := X_Intercompany_COGS_Account_Id;
       l_Inventory_Accrual_Account_Id := X_Inventory_Accrual_Account_Id ;
       l_Expense_Accrual_Account_Id   := X_Expense_Accrual_Account_Id;
   ELSE
      l_Flow_Type  := 1; -- Should be always 1 (Shipping) if INV-J is not installed. Bug# 3271622
      l_Intercompany_COGS_Account_Id := NULL;
      l_Inventory_Accrual_Account_Id := NULL;
      l_Expense_Accrual_Account_Id   := NULL;
   END IF;

       INSERT INTO MTL_INTERCOMPANY_PARAMETERS(
              ship_organization_id,
              sell_organization_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              vendor_id,
              vendor_site_id,
              customer_id,
              address_id,
              customer_site_id,
              cust_trx_type_id,
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
              attribute15,
              revalue_average_flag,
              freight_code_combination_id,
	      inv_currency_code,
	      Flow_Type,
	      Intercompany_COGS_Account_Id,
              Inventory_Accrual_Account_Id,
              Expense_Accrual_Account_Id

             ) VALUES (
              X_Ship_Organization_Id,
              X_Sell_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Vendor_Id,
              X_Vendor_Site_Id,
              X_Customer_Id,
              X_Address_Id,
              X_Customer_Site_Id,
              X_Cust_Trx_Type_Id,
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
              X_Attribute15,
              X_Revalue_Average_Flag,
              X_Freight_Code_Combination_Id,
	      X_Inv_Currency_Code,
	      l_Flow_Type,
	      l_Intercompany_COGS_Account_Id,
              l_Inventory_Accrual_Account_Id,
              l_Expense_Accrual_Account_Id
             );



OPEN C;
   FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

  END Insert_Row;



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
		     X_Inv_Currency_Code              NUMBER,
		     X_Flow_Type                      NUMBER DEFAULT NULL, -- added as part of patchset-j development
		     X_Intercompany_COGS_Account_Id   NUMBER DEFAULT NULL,
		     X_Inventory_Accrual_Account_Id   NUMBER DEFAULT NULL,
		     X_Expense_Accrual_Account_Id     NUMBER DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   MTL_INTERCOMPANY_PARAMETERS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Ship_Organization_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.ship_organization_id =  X_Ship_Organization_Id)
           AND (Recinfo.sell_organization_id =  X_Sell_Organization_Id)
           AND (   (Recinfo.vendor_id =  X_Vendor_Id)
                OR (    (Recinfo.vendor_id IS NULL)
                    AND (X_Vendor_Id IS NULL)))
           AND (   (Recinfo.vendor_site_id =  X_Vendor_Site_Id)
                OR (    (Recinfo.vendor_site_id IS NULL)
                    AND (X_Vendor_Site_Id IS NULL)))
           AND (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.address_id =  X_Address_Id)
           AND (Recinfo.customer_site_id =  X_Customer_Site_Id)
           AND (Recinfo.cust_trx_type_id =  X_Cust_Trx_Type_Id)
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
           --Bug 2945914:since the revalue average flag is not supported thro this form
          /* AND (   (Recinfo.revalue_average_flag =  X_Revalue_Average_Flag)
                OR (    (Recinfo.revalue_average_flag IS NULL)
                    AND (X_Revalue_Average_Flag IS NULL)))*/
           AND (   (Recinfo.freight_code_combination_id =  X_Freight_Code_Combination_Id)
                OR (    (Recinfo.freight_code_combination_id IS NULL)
                    AND (X_Freight_Code_Combination_Id IS NULL)))
	   AND (   (Recinfo.inv_currency_code =  X_Inv_Currency_Code)
                OR (    (Recinfo.inv_currency_code IS NULL)
                    AND (X_Inv_Currency_Code IS NULL)))

      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

IF(inv_control.get_current_release_level >= inv_release.GET_J_RELEASE_LEVEL) Then

if (
         (Recinfo.flow_type =  X_Flow_Type) --added as part of patchset-j development
                OR (    (Recinfo.flow_type IS NULL)
                    AND (X_Flow_Type IS NULL))
	   AND (   (Recinfo.intercompany_cogs_account_id =  X_Intercompany_COGS_Account_id)
                OR (    (Recinfo.intercompany_cogs_account_id IS NULL)
                    AND (X_Intercompany_COGS_Account_id IS NULL)))
           AND (   (Recinfo.inventory_Accrual_account_id =  X_Inventory_Accrual_Account_id)
                OR (    (Recinfo.inventory_Accrual_account_id IS NULL)
                    AND (X_Inventory_Accrual_Account_id IS NULL)))
           AND (   (Recinfo.expense_Accrual_account_id =  X_Expense_Accrual_Account_id)
                OR (    (Recinfo.expense_Accrual_account_id IS NULL)
                    AND (X_Expense_Accrual_Account_id IS NULL)))

 ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
END IF;
END Lock_Row;



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
  ) IS


  BEGIN
    UPDATE MTL_INTERCOMPANY_PARAMETERS
    SET
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       vendor_id                       =     X_Vendor_Id,
       vendor_site_id                  =     X_Vendor_Site_Id,
       customer_id                     =     X_Customer_Id,
       address_id                      =     X_Address_Id,
       customer_site_id                =     X_Customer_Site_Id,
       cust_trx_type_id                =     X_Cust_Trx_Type_Id,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       --revalue_average_flag          =     X_Revalue_Average_Flag,   Bug 2745914
       freight_code_combination_id     =     X_Freight_Code_Combination_Id,
       inv_currency_code               =     X_Inv_Currency_Code
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

   IF(inv_control.get_current_release_level >= inv_release.GET_J_RELEASE_LEVEL) Then
    UPDATE MTL_INTERCOMPANY_PARAMETERS
      SET
       flow_type	               =     X_Flow_Type,
       intercompany_cogs_account_id    =     X_Intercompany_COGS_Account_Id,
       inventory_Accrual_account_id    =     X_Inventory_Accrual_Account_Id,
       expense_Accrual_account_id      =     X_Expense_Accrual_Account_Id
    WHERE rowid = X_Rowid;
   ELSE
    UPDATE MTL_INTERCOMPANY_PARAMETERS
      SET
       flow_type	               =    1, -- Should be always 1 (Shipping) if INV-J is not installed. Bug# 3271622
       intercompany_cogs_account_id    =    NULL,
       inventory_Accrual_account_id    =    NULL,
       expense_Accrual_account_id      =    NULL
    WHERE rowid = X_Rowid;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
   END IF;
  END Update_Row;



  PROCEDURE Delete_Row(X_Ship_Organization_Id       NUMBER,
                       X_Sell_Organization_Id       NUMBER) IS
  BEGIN
    DELETE FROM MTL_INTERCOMPANY_PARAMETERS
    WHERE ship_organization_id=X_Ship_Organization_Id
    AND sell_organization_id=X_Sell_Organization_Id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END MTL_IC_PARAMETERS_PKG;

/
