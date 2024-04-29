--------------------------------------------------------
--  DDL for Package Body FA_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADJUSTMENTS_PKG" as
/* $Header: faxiajb.pls 120.3.12010000.2 2009/07/19 13:28:39 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Transaction_Header_Id          NUMBER,
                       X_Source_Type_Code               VARCHAR2,
                       X_Adjustment_Type                VARCHAR2,
                       X_Debit_Credit_Flag              VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Adjustment_Amount              NUMBER,
                       X_Distribution_Id                NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE DEFAULT NULL,
                       X_Last_Updated_By                NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Annualized_Adjustment          NUMBER DEFAULT NULL,
                       X_Je_Header_Id                   NUMBER DEFAULT NULL,
                       X_Je_Line_Num                    NUMBER DEFAULT NULL,
                       X_Period_Counter_Adjusted        NUMBER,
                       X_Period_Counter_Created         NUMBER,
                       X_Asset_Invoice_Id               NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   BEGIN

       if (X_mrc_sob_type_code = 'R') then

          INSERT INTO fa_mc_adjustments(
              set_of_books_id,
              transaction_header_id,
              source_type_code,
              adjustment_type,
              debit_credit_flag,
              code_combination_id,
              book_type_code,
              asset_id,
              adjustment_amount,
              distribution_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              annualized_adjustment,
              je_header_id,
              je_line_num,
              period_counter_adjusted,
              period_counter_created,
              asset_invoice_id
             ) VALUES (
              X_set_of_books_id,
              X_Transaction_Header_Id,
              X_Source_Type_Code,
              X_Adjustment_Type,
              X_Debit_Credit_Flag,
              X_Code_Combination_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Adjustment_Amount,
              X_Distribution_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Annualized_Adjustment,
              X_Je_Header_Id,
              X_Je_Line_Num,
              X_Period_Counter_Adjusted,
              X_Period_Counter_Created,
              X_Asset_Invoice_Id
             );
       else
          INSERT INTO fa_adjustments(
              transaction_header_id,
              source_type_code,
              adjustment_type,
              debit_credit_flag,
              code_combination_id,
              book_type_code,
              asset_id,
              adjustment_amount,
              distribution_id,
              last_update_date,
              last_updated_by,
              last_update_login,
              annualized_adjustment,
              je_header_id,
              je_line_num,
              period_counter_adjusted,
              period_counter_created,
              asset_invoice_id
             ) VALUES (
              X_Transaction_Header_Id,
              X_Source_Type_Code,
              X_Adjustment_Type,
              X_Debit_Credit_Flag,
              X_Code_Combination_Id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Adjustment_Amount,
              X_Distribution_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Annualized_Adjustment,
              X_Je_Header_Id,
              X_Je_Line_Num,
              X_Period_Counter_Adjusted,
              X_Period_Counter_Created,
              X_Asset_Invoice_Id
             );
       end if;


  EXCEPTION
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_ADJUSTMENTS_PKG.Insert_Row', p_log_level_rec => p_log_level_rec);
        raise;

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Transaction_Header_Id            NUMBER,
                     X_Source_Type_Code                 VARCHAR2,
                     X_Adjustment_Type                  VARCHAR2,
                     X_Debit_Credit_Flag                VARCHAR2,
                     X_Code_Combination_Id              NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Adjustment_Amount                NUMBER,
                     X_Distribution_Id                  NUMBER DEFAULT NULL,
                     X_Annualized_Adjustment            NUMBER DEFAULT NULL,
                     X_Je_Header_Id                     NUMBER DEFAULT NULL,
                     X_Je_Line_Num                      NUMBER DEFAULT NULL,
                     X_Period_Counter_Adjusted          NUMBER,
                     X_Period_Counter_Created           NUMBER,
                     X_Asset_Invoice_Id                 NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT  transaction_header_id,
          source_type_code,
          adjustment_type,
          debit_credit_flag,
          code_combination_id,
          book_type_code,
          asset_id,
          adjustment_amount,
          distribution_id,
          last_update_date,
          last_updated_by,
          last_update_login,
          annualized_adjustment,
          je_header_id,
          je_line_num,
          period_counter_adjusted,
          period_counter_created,
          asset_invoice_id,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute11,
          global_attribute12,
          global_attribute13,
          global_attribute14,
          global_attribute15,
          global_attribute16,
          global_attribute17,
          global_attribute18,
          global_attribute19,
          global_attribute20,
          global_attribute_category
        FROM   fa_adjustments
        WHERE  rowid = X_Rowid
        FOR UPDATE of transaction_header_id NOWAIT;
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

               (Recinfo.transaction_header_id =  X_Transaction_Header_Id)
           AND (Recinfo.source_type_code =  X_Source_Type_Code)
           AND (Recinfo.adjustment_type =  X_Adjustment_Type)
           AND (Recinfo.debit_credit_flag =  X_Debit_Credit_Flag)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.adjustment_amount =  X_Adjustment_Amount)
           AND (   (Recinfo.distribution_id =  X_Distribution_Id)
                OR (    (Recinfo.distribution_id IS NULL)
                    AND (X_Distribution_Id IS NULL)))
           AND (   (Recinfo.annualized_adjustment =  X_Annualized_Adjustment)
                OR (    (Recinfo.annualized_adjustment IS NULL)
                    AND (X_Annualized_Adjustment IS NULL)))
           AND (   (Recinfo.je_header_id =  X_Je_Header_Id)
                OR (    (Recinfo.je_header_id IS NULL)
                    AND (X_Je_Header_Id IS NULL)))
           AND (   (Recinfo.je_line_num =  X_Je_Line_Num)
                OR (    (Recinfo.je_line_num IS NULL)
                    AND (X_Je_Line_Num IS NULL)))
           AND (Recinfo.period_counter_adjusted =  X_Period_Counter_Adjusted)
           AND (Recinfo.period_counter_created =  X_Period_Counter_Created)
           AND (   (Recinfo.asset_invoice_id =  X_Asset_Invoice_Id)
                OR (    (Recinfo.asset_invoice_id IS NULL)
                    AND (X_Asset_Invoice_Id IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Transaction_Header_Id          NUMBER,
                       X_Source_Type_Code               VARCHAR2,
                       X_Adjustment_Type                VARCHAR2,
                       X_Debit_Credit_Flag              VARCHAR2,
                       X_Code_Combination_Id            NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Adjustment_Amount              NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Annualized_Adjustment          NUMBER,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Period_Counter_Adjusted        NUMBER,
                       X_Period_Counter_Created         NUMBER,
                       X_Asset_Invoice_Id               NUMBER,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

     if (X_mrc_sob_type_code = 'R') then
       UPDATE fa_mc_adjustments
       SET
       transaction_header_id           =     X_Transaction_Header_Id,
       source_type_code                =     X_Source_Type_Code,
       adjustment_type                 =     X_Adjustment_Type,
       debit_credit_flag               =     X_Debit_Credit_Flag,
       code_combination_id             =     X_Code_Combination_Id,
       book_type_code                  =     X_Book_Type_Code,
       asset_id                        =     X_Asset_Id,
       adjustment_amount               =     X_Adjustment_Amount,
       distribution_id                 =     X_Distribution_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       annualized_adjustment           =     X_Annualized_Adjustment,
       je_header_id                    =     X_Je_Header_Id,
       je_line_num                     =     X_Je_Line_Num,
       period_counter_adjusted         =     X_Period_Counter_Adjusted,
       period_counter_created          =     X_Period_Counter_Created,
       asset_invoice_id                =     X_Asset_Invoice_Id
       WHERE rowid = X_Rowid;
    else
       UPDATE fa_adjustments
       SET
       transaction_header_id           =     X_Transaction_Header_Id,
       source_type_code                =     X_Source_Type_Code,
       adjustment_type                 =     X_Adjustment_Type,
       debit_credit_flag               =     X_Debit_Credit_Flag,
       code_combination_id             =     X_Code_Combination_Id,
       book_type_code                  =     X_Book_Type_Code,
       asset_id                        =     X_Asset_Id,
       adjustment_amount               =     X_Adjustment_Amount,
       distribution_id                 =     X_Distribution_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       annualized_adjustment           =     X_Annualized_Adjustment,
       je_header_id                    =     X_Je_Header_Id,
       je_line_num                     =     X_Je_Line_Num,
       period_counter_adjusted         =     X_Period_Counter_Adjusted,
       period_counter_created          =     X_Period_Counter_Created,
       asset_invoice_id                =     X_Asset_Invoice_Id
       WHERE rowid = X_Rowid;
    end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  EXCEPTION
    when others then
        fa_srvr_msg.add_sql_error(
                calling_fn => 'FA_ADJUSTMENTS_PKG.Update_Row', p_log_level_rec => p_log_level_rec);
        raise;

  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid        VARCHAR2 DEFAULT NULL,
                       X_Asset_Id     NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn   VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    if (X_mrc_sob_type_code = 'R') then
       if X_Rowid is not null then
            DELETE FROM fa_mc_adjustments
            WHERE rowid = X_Rowid;
       elsif X_Asset_Id is not null then
            DELETE FROM fa_mc_adjustments
            WHERE asset_id = X_Asset_id
            AND set_of_books_id = X_set_of_books_id;
       end if;
    else
       if X_Rowid is not null then
            DELETE FROM fa_adjustments
            WHERE rowid = X_Rowid;
       elsif X_Asset_Id is not null then
            DELETE FROM fa_adjustments
            WHERE asset_id = X_Asset_id;
       end if;
    end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  EXCEPTION
     when no_data_found then
          null;
     when others then
          fa_srvr_msg.add_sql_error(
                  calling_fn => 'FA_ADJUSTMENTS_PKG.Delete_Row', p_log_level_rec => p_log_level_rec);
          raise;

  END Delete_Row;

END FA_ADJUSTMENTS_PKG;

/
