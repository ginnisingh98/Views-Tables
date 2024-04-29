--------------------------------------------------------
--  DDL for Package Body ARH_CPCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CPCA_PKG" as
/* $Header: ARHPCAB.pls 120.1 2005/06/16 21:13:17 jhuang ship $*/

PROCEDURE Insert_Negative_Class_Amt
(         X_Customer_Profile_Class_Id      NUMBER,
          X_Created_By                     NUMBER,
          X_Creation_Date                  DATE,
          X_Currency_Code                  VARCHAR2,
          X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Last_Updated_By                NUMBER,
          X_Last_Update_Date               DATE,
          X_Auto_Rec_Min_Receipt_Amount    NUMBER,
          X_Last_Update_Login              NUMBER,
          X_Max_Interest_Charge            NUMBER,
          X_Min_Dunning_Amount             NUMBER,
          X_Min_Statement_Amount           NUMBER,
          X_Overall_Credit_Limit           NUMBER,
          X_Trx_Credit_Limit               NUMBER,
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
          X_Interest_Rate                  NUMBER,
          X_Min_Fc_Balance_Amount          NUMBER,
          X_Min_Fc_Invoice_Amount          NUMBER,
          X_Min_Dunning_Invoice_Amount     NUMBER,
          X_Jgzz_attribute_Category             VARCHAR2,
          X_Jgzz_attribute1                     VARCHAR2,
          X_Jgzz_attribute2                     VARCHAR2,
          X_Jgzz_attribute3                     VARCHAR2,
          X_Jgzz_attribute4                     VARCHAR2,
          X_Jgzz_attribute5                     VARCHAR2,
          X_Jgzz_attribute6                     VARCHAR2,
          X_Jgzz_attribute7                     VARCHAR2,
          X_Jgzz_attribute8                     VARCHAR2,
          X_Jgzz_attribute9                     VARCHAR2,
          X_Jgzz_attribute10                    VARCHAR2,
          X_Jgzz_attribute11                    VARCHAR2,
          X_Jgzz_attribute12                    VARCHAR2,
          X_Jgzz_attribute13                    VARCHAR2,
          X_Jgzz_attribute14                    VARCHAR2,
          X_Jgzz_attribute15                    VARCHAR2
) IS

BEGIN
  INSERT INTO HZ_CUST_PROF_CLASS_AMTS
  (
         profile_class_id,
         created_by,
         creation_date,
         currency_code,
         profile_class_amount_id,
         last_updated_by,
         last_update_date,
         auto_rec_min_receipt_amount,
         last_update_login,
         max_interest_charge,
         min_dunning_amount,
         min_statement_amount,
         overall_credit_limit,
         trx_credit_limit,
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
         interest_rate,
         min_fc_balance_amount,
         min_fc_invoice_amount,
         min_dunning_invoice_amount,
         Jgzz_attribute_Category,
         Jgzz_attribute1,
         Jgzz_attribute2,
         Jgzz_attribute3,
         Jgzz_attribute4,
         Jgzz_attribute5,
         Jgzz_attribute6,
         Jgzz_attribute7,
         Jgzz_attribute8,
         Jgzz_attribute9,
         Jgzz_attribute10,
         Jgzz_attribute11,
         Jgzz_attribute12,
         Jgzz_attribute13,
         Jgzz_attribute14,
         Jgzz_attribute15
  )
  VALUES
  (
         X_Customer_Profile_Class_Id,
         X_Created_By,
         X_Creation_Date,
         X_Currency_Code,
         X_Cust_Prof_Class_Amount_Id,
         X_Last_Updated_By,
         X_Last_Update_Date,
         X_Auto_Rec_Min_Receipt_Amount,
         X_Last_Update_Login,
         X_Max_Interest_Charge,
         X_Min_Dunning_Amount,
         X_Min_Statement_Amount,
         X_Overall_Credit_Limit,
         X_Trx_Credit_Limit,
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
         X_Interest_Rate,
         X_Min_Fc_Balance_Amount,
         X_Min_Fc_Invoice_Amount,
         X_Min_Dunning_Invoice_Amount,
         X_Jgzz_attribute_Category,
         X_Jgzz_attribute1,
         X_Jgzz_attribute2,
         X_Jgzz_attribute3,
         X_Jgzz_attribute4,
         X_Jgzz_attribute5,
         X_Jgzz_attribute6,
         X_Jgzz_attribute7,
         X_Jgzz_attribute8,
         X_Jgzz_attribute9,
         X_Jgzz_attribute10,
         X_Jgzz_attribute11,
         X_Jgzz_attribute12,
         X_Jgzz_attribute13,
         X_Jgzz_attribute14,
         X_Jgzz_attribute15
  );

END Insert_Negative_Class_Amt;

PROCEDURE compute_negative_id
(         X_Cust_Prof_Class_Amount_Id NUMBER,
          X_Negative_Id               IN OUT NOCOPY NUMBER,
          X_Notify_Flag               IN OUT NOCOPY VARCHAR2
) IS

  number_in_update number;

BEGIN

--IDENTIFY EXISTING ROW WITH NEGATIVE ID IN HZ_CUST_PROF_CLASS_AMTS
--RETRIEVE THE MIN id WHERE id BETWEEN -100*ID-99 AND -100*ID-2

  SELECT count(*), min(profile_class_amount_id) - 1
  INTO   number_in_update, X_Negative_Id
  FROM   HZ_CUST_PROF_CLASS_AMTS
  WHERE  profile_class_amount_id BETWEEN
         (X_Cust_Prof_Class_Amount_Id) * (-100) - 99 AND
         (X_Cust_Prof_Class_Amount_Id) * (-100) - 2;

 if number_in_update > 0 then
   X_Notify_Flag := 'W';
 end if;

END compute_negative_id;
--
--
PROCEDURE old_amount_insert
(         X_Cust_Prof_Class_Amount_Id      NUMBER,
          X_Negative_Id                    NUMBER,
          X_Customer_Profile_Class_Id      NUMBER
) IS

  CURSOR C is
  select *
  from   hz_cust_prof_class_amts
  where  profile_class_amount_id = X_Cust_Prof_Class_Amount_Id
  FOR UPDATE of profile_class_amount_id NOWAIT;
  Amountinfo C%ROWTYPE;

BEGIN
  OPEN C;
    FETCH C INTO Amountinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  CLOSE C;

  Insert_Negative_Class_Amt
  (
         X_Customer_Profile_Class_Id,
         Amountinfo.created_by,
         Amountinfo.creation_date,
         Amountinfo.currency_code,
         X_Negative_Id,
         Amountinfo.last_updated_by,
         Amountinfo.last_update_date,
         Amountinfo.auto_rec_min_receipt_amount,
         Amountinfo.last_update_login,
         Amountinfo.max_interest_charge,
         Amountinfo.min_dunning_amount,
         Amountinfo.min_statement_amount,
         Amountinfo.overall_credit_limit,
         Amountinfo.trx_credit_limit,
         Amountinfo.attribute_category,
         Amountinfo.attribute1,
         Amountinfo.attribute2,
         Amountinfo.attribute3,
         Amountinfo.attribute4,
         Amountinfo.attribute5,
         Amountinfo.attribute6,
         Amountinfo.attribute7,
         Amountinfo.attribute8,
         Amountinfo.attribute9,
         Amountinfo.attribute10,
         Amountinfo.attribute11,
         Amountinfo.attribute12,
         Amountinfo.attribute13,
         Amountinfo.attribute14,
         Amountinfo.attribute15,
         Amountinfo.interest_rate,
         Amountinfo.min_fc_balance_amount,
         Amountinfo.min_fc_invoice_amount,
         Amountinfo.min_dunning_invoice_amount,
         Amountinfo.jgzz_attribute_category,
         Amountinfo.jgzz_attribute1,
         Amountinfo.jgzz_attribute2,
         Amountinfo.jgzz_attribute3,
         Amountinfo.jgzz_attribute4,
         Amountinfo.jgzz_attribute5,
         Amountinfo.jgzz_attribute6,
         Amountinfo.jgzz_attribute7,
         Amountinfo.jgzz_attribute8,
         Amountinfo.jgzz_attribute9,
         Amountinfo.jgzz_attribute10,
         Amountinfo.jgzz_attribute11,
         Amountinfo.jgzz_attribute12,
         Amountinfo.jgzz_attribute13,
         Amountinfo.jgzz_attribute14,
         Amountinfo.jgzz_attribute15
    );

END old_amount_insert;
--
--
END ARH_CPCA_PKG;

/
