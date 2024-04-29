--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENTS_PKG" as
/* $Header: PAINAGRB.pls 120.4 2007/02/07 10:46:05 rgandhi ship $ */

  PROCEDURE Insert_Row(
             X_Rowid                      IN OUT   NOCOPY VARCHAR2,/*file.sql.39*/
             X_Agreement_Id               IN OUT   NOCOPY NUMBER,/*file.sql.39*/
             X_Customer_Id                IN       NUMBER,
             X_Agreement_Num              IN       VARCHAR2,
             X_Agreement_Type             IN       VARCHAR2,
             X_Last_Update_Date           IN       DATE,
             X_Last_Updated_By            IN       NUMBER,
             X_Creation_Date              IN       DATE,
             X_Created_By                 IN       NUMBER,
             X_Last_Update_Login          IN       NUMBER,
             X_Owned_By_Person_Id         IN       NUMBER,
             X_Term_Id                    IN       NUMBER,
             X_Revenue_Limit_Flag         IN       VARCHAR2,
             X_Amount                     IN       NUMBER,
             X_Description                IN       VARCHAR2,
             X_Expiration_Date            IN       DATE,
             X_Attribute_Category         IN       VARCHAR2,
             X_Attribute1                 IN       VARCHAR2,
             X_Attribute2                 IN       VARCHAR2,
             X_Attribute3                 IN       VARCHAR2,
             X_Attribute4                 IN       VARCHAR2,
             X_Attribute5                 IN       VARCHAR2,
             X_Attribute6                 IN       VARCHAR2,
             X_Attribute7                 IN       VARCHAR2,
             X_Attribute8                 IN       VARCHAR2,
             X_Attribute9                 IN       VARCHAR2,
             X_Attribute10                IN       VARCHAR2,
             X_Template_Flag              IN       VARCHAR2,
             X_Pm_agreement_reference     IN       VARCHAR2,
             X_Pm_Product_Code            IN       VARCHAR2,
             X_owning_organization_id     IN       NUMBER,
             x_agreement_currency_code    IN       VARCHAR2,
             x_invoice_limit_flag         IN       VARCHAR2,
	     X_Org_id                     IN       NUMBER,
/*Federal*/
	     X_customer_order_number      IN       VARCHAR2 DEFAULT NULL,
	     X_ADVANCE_REQUIRED           IN       VARCHAR2 DEFAULT 'N',
	     X_start_date                 IN       DATE     DEFAULT NULL,
	     X_Billing_sequence           IN       NUMBER   DEFAULT NULL,
	     X_line_of_account            IN       VARCHAR2 DEFAULT NULL,
	     X_payment_set_id             IN       NUMBER   DEFAULT NULL,
	     X_advance_amount             IN       NUMBER   DEFAULT NULL,
	     X_attribute11                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute12                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute13                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute14                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute15                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute16                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute17                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute18                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute19                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute20                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute21                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute22                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute23                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute24                IN       VARCHAR2 DEFAULT NULL,
	     X_attribute25                IN       VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS SELECT rowid FROM PA_AGREEMENTS
                 WHERE agreement_id = X_Agreement_Id;
      CURSOR C2 IS SELECT pa_agreements_s.nextval FROM sys.dual;

      l_Agreement_Id  NUMBER := X_Agreement_Id; /*File.sql.39*/
   BEGIN
      if (X_Agreement_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Agreement_Id;
        CLOSE C2;
      end if;

       INSERT INTO PA_AGREEMENTS_ALL(
              agreement_id,
              customer_id,
              agreement_num,
              agreement_type,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              owned_by_person_id,
              term_id,
              revenue_limit_flag,
              amount,
              description,
              expiration_date,
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
	      template_flag,
              pm_agreement_reference,
              pm_product_code,
              owning_organization_id,
              agreement_currency_code,
              invoice_limit_flag,
	      org_id,
/*Federal*/
	      customer_order_number,
	      advance_required,
	      start_date,
	      billing_sequence,
	      line_of_account,
	      payment_set_id,
	      advance_amount,
	      attribute11,
	      attribute12,
	      attribute13,
	      attribute14,
	      attribute15,
	      attribute16,
	      attribute17,
	      attribute18,
	      attribute19,
	      attribute20,
	      attribute21,
	      attribute22,
	      attribute23,
	      attribute24,
	      attribute25
             ) VALUES (
              X_Agreement_Id,
              X_Customer_Id,
              X_Agreement_Num,
              X_Agreement_Type,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Owned_By_Person_Id,
              X_Term_Id,
              X_Revenue_Limit_Flag,
              X_Amount,
              X_Description,
              X_Expiration_Date,
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
	      X_Template_Flag,
              X_pm_agreement_reference,
              X_pm_product_code,
              x_owning_organization_id,
              x_agreement_currency_code,
              x_invoice_limit_flag,
	      x_org_id,
/*Federal*/
	      x_customer_order_number,
	      x_advance_required,
	      x_start_date,
	      x_billing_sequence,
	      x_line_of_account,
	      x_payment_set_id,
	      x_advance_amount,
	      x_attribute11,
	      x_attribute12,
	      x_attribute13,
	      x_attribute14,
	      x_attribute15,
	      x_attribute16,
	      x_attribute17,
	      x_attribute18,
	      x_attribute19,
	      x_attribute20,
	      x_attribute21,
	      x_attribute22,
	      x_attribute23,
	      x_attribute24,
	      x_attribute25
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
/*Added exception for File.sql.39*/

EXCEPTION
 WHEN OTHERS THEN
   x_rowid :=NULL;
   X_Agreement_Id := l_Agreement_Id;
   raise;
END Insert_Row;


  PROCEDURE Lock_Row(
             X_Rowid                      IN       VARCHAR2,
             X_Agreement_Id               IN       NUMBER,
             X_Customer_Id                IN       NUMBER,
             X_Agreement_Num              IN       VARCHAR2,
             X_Agreement_Type             IN       VARCHAR2,
             X_Owned_By_Person_Id         IN       NUMBER,
             X_Term_Id                    IN       NUMBER,
             X_Revenue_Limit_Flag         IN       VARCHAR2,
             X_Amount                     IN       NUMBER,
             X_Description                IN       VARCHAR2,
             X_Expiration_Date            IN       DATE,
             X_Attribute_Category         IN       VARCHAR2,
             X_Attribute1                 IN       VARCHAR2,
             X_Attribute2                 IN       VARCHAR2,
             X_Attribute3                 IN       VARCHAR2,
             X_Attribute4                 IN       VARCHAR2,
             X_Attribute5                 IN       VARCHAR2,
             X_Attribute6                 IN       VARCHAR2,
             X_Attribute7                 IN       VARCHAR2,
             X_Attribute8                 IN       VARCHAR2,
             X_Attribute9                 IN       VARCHAR2,
             X_Attribute10                IN       VARCHAR2,
             X_Template_Flag              IN       VARCHAR2,
             X_Pm_agreement_reference     IN       VARCHAR2,
             X_Pm_Product_Code            IN       VARCHAR2,
             X_owning_organization_id     IN       NUMBER,
             x_agreement_currency_code    IN       VARCHAR2,
             x_invoice_limit_flag         IN       VARCHAR2,
/*Federal*/
             X_customer_order_number      IN       VARCHAR2 DEFAULT NULL,
             X_ADVANCE_REQUIRED           IN       VARCHAR2 DEFAULT NULL,
             X_start_date                 IN       DATE     DEFAULT NULL,
             X_Billing_sequence           IN       NUMBER   DEFAULT NULL,
             X_line_of_account            IN       VARCHAR2 DEFAULT NULL,
             X_payment_set_id             IN       NUMBER   DEFAULT NULL,
             X_advance_amount             IN       NUMBER   DEFAULT NULL,
             X_attribute11                IN       VARCHAR2 DEFAULT NULL,
             X_attribute12                IN       VARCHAR2 DEFAULT NULL,
             X_attribute13                IN       VARCHAR2 DEFAULT NULL,
             X_attribute14                IN       VARCHAR2 DEFAULT NULL,
             X_attribute15                IN       VARCHAR2 DEFAULT NULL,
             X_attribute16                IN       VARCHAR2 DEFAULT NULL,
             X_attribute17                IN       VARCHAR2 DEFAULT NULL,
             X_attribute18                IN       VARCHAR2 DEFAULT NULL,
             X_attribute19                IN       VARCHAR2 DEFAULT NULL,
             X_attribute20                IN       VARCHAR2 DEFAULT NULL,
             X_attribute21                IN       VARCHAR2 DEFAULT NULL,
             X_attribute22                IN       VARCHAR2 DEFAULT NULL,
             X_attribute23                IN       VARCHAR2 DEFAULT NULL,
             X_attribute24                IN       VARCHAR2 DEFAULT NULL,
             X_attribute25                IN       VARCHAR2 DEFAULT NULL
  ) IS
    CURSOR C IS
        SELECT *
        FROM   PA_AGREEMENTS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Agreement_Id NOWAIT;
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

               (Recinfo.agreement_id =  X_Agreement_Id)
           AND (Recinfo.customer_id =  X_Customer_Id)
           AND (Recinfo.agreement_num =  X_Agreement_Num)
           AND (Recinfo.agreement_type =  X_Agreement_Type)
           AND (Recinfo.owned_by_person_id =  X_Owned_By_Person_Id)
           AND (Recinfo.term_id =  X_Term_Id)
           AND (Recinfo.revenue_limit_flag =  X_Revenue_Limit_Flag)
           AND (Recinfo.amount =  X_Amount)
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.expiration_date =  X_Expiration_Date)
                OR (    (Recinfo.expiration_date IS NULL)
                    AND (X_Expiration_Date IS NULL)))
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
           AND (   (Recinfo.template_flag =  X_Template_Flag)
                OR (    (Recinfo.template_flag IS NULL)
                    AND (X_Template_Flag IS NULL)))
           AND (   (Recinfo.pm_agreement_reference =  X_pm_agreement_reference)
                OR (    (Recinfo.pm_agreement_reference IS NULL)
                    AND (X_pm_agreement_reference IS NULL)))
           AND (   (Recinfo.pm_product_code =  X_pm_product_code)
                OR (    (Recinfo.pm_product_code IS NULL)
                    AND (X_pm_product_code IS NULL)))
           AND (   (Recinfo.owning_organization_id =  X_owning_organization_id)
                OR (    (Recinfo.owning_organization_id IS NULL)
                    AND (X_owning_organization_id IS NULL)))
           AND (   (Recinfo.agreement_currency_code =  X_agreement_currency_code)
                OR (    (Recinfo.agreement_currency_code IS NULL)
                    AND (X_agreement_currency_code IS NULL)))
           AND (Recinfo.invoice_limit_flag =  X_invoice_Limit_Flag)
/*Federal*/
           AND (   (Recinfo.customer_order_number =  X_customer_order_number)
                OR (    (Recinfo.customer_order_number IS NULL)
                    AND (X_customer_order_number IS NULL)))
           AND (   (Recinfo.advance_required =  X_advance_required)
                OR (    (Recinfo.advance_required IS NULL)
                    AND (X_advance_required IS NULL)))
           AND (   (Recinfo.start_date =  X_start_date)
                OR (    (Recinfo.start_date IS NULL)
                    AND (X_start_date IS NULL)))
           AND (   (Recinfo.billing_sequence =  X_billing_sequence)
                OR (    (Recinfo.billing_sequence IS NULL)
                    AND (X_billing_sequence IS NULL)))
           AND (   (Recinfo.line_of_account =  X_line_of_account)
                OR (    (Recinfo.line_of_account IS NULL)
                    AND (X_line_of_account IS NULL)))
           AND (   (Recinfo.payment_set_id =  X_payment_set_id)
                OR (    (Recinfo.payment_set_id IS NULL)
                    AND (X_payment_set_id IS NULL)))
           AND (   (Recinfo.advance_amount =  X_advance_amount)
                OR (    (Recinfo.advance_amount IS NULL)
                    AND (X_advance_amount IS NULL)))
           AND (   (Recinfo.attribute11 =  X_attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_attribute15 IS NULL)))
           AND (   (Recinfo.attribute16 =  X_attribute16)
                OR (    (Recinfo.attribute16 IS NULL)
                    AND (X_attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 =  X_attribute17)
                OR (    (Recinfo.attribute17 IS NULL)
                    AND (X_attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 =  X_attribute18)
                OR (    (Recinfo.attribute18 IS NULL)
                    AND (X_attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 =  X_attribute19)
                OR (    (Recinfo.attribute19 IS NULL)
                    AND (X_attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 =  X_attribute20)
                OR (    (Recinfo.attribute20 IS NULL)
                    AND (X_attribute20 IS NULL)))
           AND (   (Recinfo.attribute21 =  X_attribute21)
                OR (    (Recinfo.attribute21 IS NULL)
                    AND (X_attribute21 IS NULL)))
           AND (   (Recinfo.attribute22 =  X_attribute22)
                OR (    (Recinfo.attribute22 IS NULL)
                    AND (X_attribute22 IS NULL)))
           AND (   (Recinfo.attribute23 =  X_attribute23)
                OR (    (Recinfo.attribute23 IS NULL)
                    AND (X_attribute23 IS NULL)))
           AND (   (Recinfo.attribute24 =  X_attribute24)
                OR (    (Recinfo.attribute24 IS NULL)
                    AND (X_attribute24 IS NULL)))
           AND (   (Recinfo.attribute25 =  X_attribute25)
                OR (    (Recinfo.attribute25 IS NULL)
                    AND (X_attribute25 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(
X_Rowid                    IN       VARCHAR2,
X_Agreement_Id             IN       NUMBER,
X_Customer_Id              IN       NUMBER,
X_Agreement_Num            IN       VARCHAR2,
X_Agreement_Type           IN       VARCHAR2,
X_Last_Update_Date         IN       DATE,
X_Last_Updated_By          IN       NUMBER,
X_Last_Update_Login        IN       NUMBER,
X_Owned_By_Person_Id       IN       NUMBER,
X_Term_Id                  IN       NUMBER,
X_Revenue_Limit_Flag       IN       VARCHAR2,
X_Amount                   IN       NUMBER,
X_Description              IN       VARCHAR2,
X_Expiration_Date          IN       DATE,
X_Attribute_Category       IN       VARCHAR2,
X_Attribute1               IN       VARCHAR2,
X_Attribute2               IN       VARCHAR2,
X_Attribute3               IN       VARCHAR2,
X_Attribute4               IN       VARCHAR2,
X_Attribute5               IN       VARCHAR2,
X_Attribute6               IN       VARCHAR2,
X_Attribute7               IN       VARCHAR2,
X_Attribute8               IN       VARCHAR2,
X_Attribute9               IN       VARCHAR2,
X_Attribute10              IN       VARCHAR2,
X_Template_Flag            IN       VARCHAR2,
X_Pm_agreement_reference   IN       VARCHAR2,
X_Pm_Product_Code          IN       VARCHAR2,
X_owning_organization_id   IN       NUMBER,
x_agreement_currency_code  IN       VARCHAR2,
x_invoice_limit_flag       IN       VARCHAR2,
/*Federal*/
x_customer_order_number    IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_advance_required         IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_start_date               IN       DATE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
x_Billing_sequence         IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_line_of_account          IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_payment_set_id           IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_advance_amount           IN       NUMBER     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
x_attribute11              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute12              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute13              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute14              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute15              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute16              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute17              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute18              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute19              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute20              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute21              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute22              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute23              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute24              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
x_attribute25              IN       VARCHAR2   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
  ) IS

   l_num  Number       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM;
   l_char Varchar2(1)  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;
   l_date Date         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE;

  BEGIN
    UPDATE PA_AGREEMENTS_ALL
    SET
       agreement_id                    =     decode(X_Agreement_Id,l_num,agreement_id,X_Agreement_Id),
       customer_id                     =     decode(X_Customer_Id,l_num,customer_id,X_Customer_Id),
       agreement_num                   =     decode(X_Agreement_Num,l_char,agreement_num,X_Agreement_Num),
       agreement_type                  =     decode(X_Agreement_Type,l_char,agreement_type,X_Agreement_Type),
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       owned_by_person_id              =     X_Owned_By_Person_Id,
       term_id                         =     decode(X_Term_Id,l_num,term_id,X_Term_Id),
       revenue_limit_flag              =     decode(X_Revenue_Limit_Flag,l_char,revenue_limit_flag,X_Revenue_Limit_Flag),
       amount                          =     decode(X_Amount,l_num,amount,X_Amount),
       description                     =     decode(X_Description,l_char,description,X_Description),
       expiration_date                 =     decode(X_Expiration_Date,l_date,expiration_date,X_Expiration_Date),
       attribute_category              =     decode(X_Attribute_Category,l_char,attribute_category,X_Attribute_Category),
       attribute1                      =     decode(X_Attribute1,l_char,attribute1,X_Attribute1),
       attribute2                      =     decode(X_Attribute2,l_char,attribute2,X_Attribute2),
       attribute3                      =     decode(X_Attribute3,l_char,attribute3,X_Attribute3),
       attribute4                      =     decode(X_Attribute4,l_char,attribute4,X_Attribute4),
       attribute5                      =     decode(X_Attribute5,l_char,attribute5,X_Attribute5),
       attribute6                      =     decode(X_Attribute6,l_char,attribute6,X_Attribute6),
       attribute7                      =     decode(X_Attribute7,l_char,attribute7,X_Attribute7),
       attribute8                      =     decode(X_Attribute8,l_char,attribute8,X_Attribute8),
       attribute9                      =     decode(X_Attribute9,l_char,attribute9,X_Attribute9),
       attribute10                     =     decode(X_Attribute10,l_char,attribute10,X_Attribute10),
       template_flag		       =     decode(X_Template_Flag,l_char,template_flag,X_Template_Flag),
       pm_agreement_reference          =     decode(X_pm_agreement_reference,l_char,pm_agreement_reference,
                                                                                             X_pm_agreement_reference),
       pm_product_code                 =     decode(X_pm_product_code,l_char,pm_product_code,X_pm_product_code),
       owning_organization_id          =     decode(x_owning_organization_id,l_num,owning_organization_id,
                                                                                             x_owning_organization_id),
       agreement_currency_code         =     decode(x_agreement_currency_code,l_char,agreement_currency_code,
                                                                                            x_agreement_currency_code),
       invoice_limit_flag              =     decode(x_invoice_Limit_Flag,l_char,invoice_limit_flag,x_invoice_Limit_Flag),
/*Federal*/
       customer_order_number              =     decode(x_customer_order_number,l_char,customer_order_number,x_customer_order_number),
       advance_required              =     decode(x_advance_required,l_char,advance_required,x_advance_required),
       start_date              =     decode(x_start_date,l_date,start_date,x_start_date),
       billing_sequence              =     decode(x_billing_sequence,l_num,billing_sequence,x_billing_sequence),
       line_of_account              =     decode(x_line_of_account,l_char,line_of_account,x_line_of_account),
       payment_set_id              =     decode(x_payment_set_id,l_num,payment_set_id,x_payment_set_id),
       advance_amount              =     decode(x_advance_amount,l_num,advance_amount,x_advance_amount),
       attribute11              =     decode(x_attribute11,l_char,attribute11,x_attribute11),
       attribute12              =     decode(x_attribute12,l_char,attribute12,x_attribute12),
       attribute13              =     decode(x_attribute13,l_char,attribute13,x_attribute13),
       attribute14              =     decode(x_attribute14,l_char,attribute14,x_attribute14),
       attribute15              =     decode(x_attribute15,l_char,attribute15,x_attribute15),
       attribute16              =     decode(x_attribute16,l_char,attribute16,x_attribute16),
       attribute17              =     decode(x_attribute17,l_char,attribute17,x_attribute17),
       attribute18              =     decode(x_attribute18,l_char,attribute18,x_attribute18),
       attribute19              =     decode(x_attribute19,l_char,attribute19,x_attribute19),
       attribute20              =     decode(x_attribute20,l_char,attribute20,x_attribute20),
       attribute21              =     decode(x_attribute21,l_char,attribute21,x_attribute21),
       attribute22              =     decode(x_attribute22,l_char,attribute22,x_attribute22),
       attribute23              =     decode(x_attribute23,l_char,attribute23,x_attribute23),
       attribute24              =     decode(x_attribute24,l_char,attribute24,x_attribute24),
       attribute25              =     decode(x_attribute25,l_char,attribute25,x_attribute25)
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM PA_AGREEMENTS
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END PA_AGREEMENTS_PKG;

/
