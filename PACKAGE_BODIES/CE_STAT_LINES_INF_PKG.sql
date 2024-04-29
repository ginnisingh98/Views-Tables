--------------------------------------------------------
--  DDL for Package Body CE_STAT_LINES_INF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_STAT_LINES_INF_PKG" as
/* $Header: cestalib.pls 120.1 2002/11/12 21:25:24 bhchung ship $ */
  FUNCTION body_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN '$Revision: 120.1 $';

  END body_revision;

  FUNCTION spec_revision RETURN VARCHAR2 IS
  BEGIN

    RETURN G_spec_revision;

  END spec_revision;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Line_Number                    NUMBER,
                       X_Trx_Date                       DATE,
                       X_Trx_Code                       VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Trx_Text                       VARCHAR2,
                       X_Invoice_Text                   VARCHAR2,
		       X_Bank_Account_Text		VARCHAR2,
                       X_Amount                         NUMBER,
                       X_Charges_Amount                 NUMBER,
		       X_Currency_Code                  VARCHAR2,
                       X_Exchange_Rate                  NUMBER,
                       X_user_exchange_rate_type        VARCHAR2,
                       X_exchange_rate_date		DATE,
		       X_original_amount		NUMBER,
                       X_Bank_Trx_Number                VARCHAR2,
                       X_Customer_Text                  VARCHAR2,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM CE_STATEMENT_LINES_INTERFACE
                 WHERE statement_number = X_Statement_Number
                 AND   bank_account_num = X_Bank_Account_Num
                 AND   line_number = X_Line_Number;

   BEGIN


       INSERT INTO CE_STATEMENT_LINES_INTERFACE(
              bank_account_num,
              statement_number,
              line_number,
              trx_date,
              trx_code,
              effective_date,
              trx_text,
              invoice_text,
	      bank_account_text,
              amount,
	      charges_amount,
              currency_code,
              exchange_rate,
   	      user_exchange_rate_type,
	      exchange_rate_date,
              original_amount,
              bank_trx_number,
              customer_text,
              created_by,
              creation_date,
              last_updated_by,
              last_update_date,
              attribute_category,
              attribute1,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9

             ) VALUES (

              X_Bank_Account_Num,
              X_Statement_Number,
              X_Line_Number,
              X_Trx_Date,
              X_Trx_Code,
              X_Effective_Date,
              X_Trx_Text,
              X_Invoice_Text,
	      X_Bank_Account_Text,
              X_Amount,
	      X_Charges_Amount,
              X_Currency_Code,
              X_Exchange_Rate,
   	      X_user_exchange_rate_type,
	      X_exchange_rate_date,
	      X_original_amount,
              X_Bank_Trx_Number,
              X_Customer_Text,
              X_Created_By,
              X_Creation_Date,
              X_Last_Updated_By,
              X_Last_Update_Date,
              X_Attribute_Category,
              X_Attribute1,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9
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
                     X_Bank_Account_Num                 VARCHAR2,
                     X_Statement_Number                 VARCHAR2,
                     X_Line_Number                      NUMBER,
                     X_Trx_Date                         DATE,
                     X_Trx_Code                         VARCHAR2,
                     X_Effective_Date                   DATE,
                     X_Trx_Text                         VARCHAR2,
                     X_Invoice_Text                     VARCHAR2,
		     X_Bank_Account_Text		VARCHAR2,
                     X_Amount                           NUMBER,
                     X_Charges_Amount                   NUMBER,
		     X_Currency_Code                    VARCHAR2,
                     X_Exchange_Rate                    NUMBER,
                     X_user_exchange_rate_type		VARCHAR2,
		     X_exchange_rate_date		DATE,
		     X_original_amount			NUMBER,
                     X_Bank_Trx_Number                  VARCHAR2,
                     X_Customer_Text                    VARCHAR2,
                     X_Attribute_Category               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   CE_STATEMENT_LINES_INTERFACE
        WHERE  rowid = X_Rowid
        FOR UPDATE of Statement_Number NOWAIT;
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

               (Recinfo.bank_account_num =  X_Bank_Account_Num)
           AND (Recinfo.statement_number =  X_Statement_Number)
           AND (Recinfo.line_number =  X_Line_Number)
           AND (Recinfo.trx_date =  X_Trx_Date)
           AND (   (Recinfo.trx_code =  X_Trx_Code)
                OR (    (Recinfo.trx_code IS NULL)
                    AND (X_Trx_Code IS NULL)))
           AND (   (Recinfo.effective_date =  X_Effective_Date)
                OR (    (Recinfo.effective_date IS NULL)
                    AND (X_Effective_Date IS NULL)))
           AND (   (Recinfo.trx_text =  X_Trx_Text)
                OR (    (Recinfo.trx_text IS NULL)
                    AND (X_Trx_Text IS NULL)))
           AND (   (Recinfo.invoice_text =  X_Invoice_Text)
                OR (    (Recinfo.invoice_text IS NULL)
                    AND (X_Invoice_Text IS NULL)))
           AND (   (Recinfo.bank_account_text =  X_Bank_Account_Text)
                OR (    (Recinfo.Bank_Account_text IS NULL)
                    AND (X_Bank_Account_Text IS NULL)))
           AND (   (Recinfo.amount =  X_Amount)
                OR (    (Recinfo.amount IS NULL)
                    AND (X_Amount IS NULL)))
           AND (   (Recinfo.charges_amount =  X_Charges_Amount)
                OR (    (Recinfo.charges_amount IS NULL)
                    AND (X_Charges_Amount IS NULL)))
	   AND (   (Recinfo.currency_code =  X_Currency_Code)
                OR (    (Recinfo.currency_code IS NULL)
                    AND (X_Currency_Code IS NULL)))
           AND (   (Recinfo.exchange_rate =  X_Exchange_Rate)
                OR (    (Recinfo.exchange_rate IS NULL)
                    AND (X_Exchange_Rate IS NULL)))
           AND (   (Recinfo.user_exchange_rate_type = X_user_exchange_rate_type)
                OR (    (Recinfo.user_exchange_rate_type IS NULL)
                    AND (X_user_exchange_rate_type IS NULL)))
           AND (   (Recinfo.exchange_rate_date = X_exchange_rate_date)
                OR (    (Recinfo.exchange_rate_date IS NULL)
                    AND (X_exchange_rate_date IS NULL)))
           AND (   (Recinfo.original_amount = X_original_amount )
                OR (    (Recinfo.original_amount IS NULL)
                    AND (X_original_amount IS NULL)))
           AND (   (Recinfo.bank_trx_number =  X_Bank_Trx_Number)
                OR (    (Recinfo.bank_trx_number IS NULL)
                    AND (X_Bank_Trx_Number IS NULL)))
           AND (   (Recinfo.customer_text =  X_Customer_Text)
                OR (    (Recinfo.customer_text IS NULL)
                    AND (X_Customer_Text IS NULL)))
           AND (   (Recinfo.attribute_category =  X_Attribute_Category)
                OR (    (Recinfo.attribute_category IS NULL)
                    AND (X_Attribute_Category IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
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
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Bank_Account_Num               VARCHAR2,
                       X_Statement_Number               VARCHAR2,
                       X_Line_Number                    NUMBER,
                       X_Trx_Date                       DATE,
                       X_Trx_Code                       VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Trx_Text                       VARCHAR2,
                       X_Invoice_Text                   VARCHAR2,
		       X_Bank_Account_Text		VARCHAR2,
                       X_Amount                         NUMBER,
                       X_Charges_Amount                         NUMBER,
		       X_Currency_Code                  VARCHAR2,
                       X_Exchange_Rate                  NUMBER,
                       X_user_exchange_rate_type        VARCHAR2,
                       X_exchange_rate_date		DATE,
		       X_original_amount		NUMBER,
                       X_Bank_Trx_Number                VARCHAR2,
                       X_Customer_Text                  VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2

  ) IS
  BEGIN
    UPDATE CE_STATEMENT_LINES_INTERFACE
    SET
       bank_account_num                =     X_Bank_Account_Num,
       statement_number                =     X_Statement_Number,
       line_number                     =     X_Line_Number,
       trx_date                        =     X_Trx_Date,
       trx_code                        =     X_Trx_Code,
       effective_date                  =     X_Effective_Date,
       trx_text                        =     X_Trx_Text,
       invoice_text                    =     X_Invoice_Text,
       bank_account_text	       =     X_Bank_Account_Text,
       amount                          =     X_Amount,
       charges_amount                  =     X_Charges_Amount,
       currency_code                   =     X_Currency_Code,
       exchange_rate                   =     X_Exchange_Rate,
       user_exchange_rate_type	       =     X_user_exchange_rate_type,
       exchange_rate_date	       =     X_exchange_rate_date,
       original_amount		       =     X_original_amount,
       bank_trx_number                 =     X_Bank_Trx_Number,
       customer_text                   =     X_Customer_Text,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_date                =     X_Last_Update_Date,
       attribute_category              =     X_Attribute_Category,
       attribute1                      =     X_Attribute1,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM CE_STATEMENT_LINES_INTERFACE
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

  PROCEDURE check_unique(X_statement_number     VARCHAR2,
                         X_bank_account_num     VARCHAR2,
 			 X_line_number          NUMBER,
                         X_row_id               VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   CE_STATEMENT_LINES_INTERFACE csr
      WHERE  csr.statement_number       = X_statement_number
      AND    csr.bank_account_num       = X_bank_account_num
      AND    csr.line_number            = X_line_number
      AND    (   X_row_id is null
              OR csr.rowid <> chartorowid(X_row_id));
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('CE', 'CE_DUPLICATE_STAT_LINES_INF');
      app_exception.raise_exception;
    END IF;
    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('CE', 'CE_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'ce_stat_lines_inf_pkg.check_unique'
);
      RAISE;
  END check_unique;

END CE_STAT_LINES_INF_PKG;

/
