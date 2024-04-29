--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_SUMMARY_PKG" as
/* $Header: faxidsb.pls 120.4.12010000.2 2009/07/19 10:32:08 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Deprn_Run_Date                 DATE,
                       X_Deprn_Amount                   NUMBER,
                       X_Ytd_Deprn                      NUMBER,
                       X_Deprn_Reserve                  NUMBER,
                       X_Deprn_Source_Code              VARCHAR2,
                       X_Adjusted_Cost                  NUMBER,
                       X_Bonus_Rate                     NUMBER DEFAULT NULL,
                       X_Ltd_Production                 NUMBER DEFAULT NULL,
                       X_Period_Counter                 NUMBER,
                       X_Production                     NUMBER DEFAULT NULL,
                       X_Reval_Amortization             NUMBER DEFAULT NULL,
                       X_Reval_Amortization_Basis       NUMBER DEFAULT NULL,
                       X_Reval_Deprn_Expense            NUMBER DEFAULT NULL,
                       X_Reval_Reserve                  NUMBER DEFAULT NULL,
                       X_Ytd_Production                 NUMBER DEFAULT NULL,
                       X_Ytd_Reval_Deprn_Expense        NUMBER DEFAULT NULL,
                       X_Bonus_Deprn_Amount             NUMBER DEFAULT NULL,
                       X_Bonus_Ytd_Deprn                NUMBER DEFAULT NULL,
                       X_Bonus_Deprn_Reserve            NUMBER DEFAULT NULL,
                       X_Impairment_Amount              NUMBER DEFAULT NULL,
                       X_Ytd_Impairment                 NUMBER DEFAULT NULL,
                       X_impairment_reserve                 NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    CURSOR C_ds IS SELECT rowid FROM fa_deprn_summary
                 WHERE asset_id = X_Asset_Id
                 AND   book_type_code = X_Book_Type_Code
                 AND   period_counter = X_Period_Counter;

    CURSOR C_ds_mc IS SELECT rowid FROM fa_mc_deprn_summary
                 WHERE asset_id = X_Asset_Id
                 AND   book_type_code = X_Book_Type_Code
                 AND   period_counter = X_Period_Counter
                 AND   set_of_books_id = X_set_of_books_id;


   BEGIN

       if (X_mrc_sob_type_code = 'R') then

          INSERT INTO fa_mc_deprn_summary(
              set_of_books_id,
              book_type_code,
              asset_id,
              deprn_run_date,
              deprn_amount,
              ytd_deprn,
              deprn_reserve,
              deprn_source_code,
              adjusted_cost,
              bonus_rate,
              ltd_production,
              period_counter,
              production,
              reval_amortization,
              reval_amortization_basis,
              reval_deprn_expense,
              reval_reserve,
              ytd_production,
              ytd_reval_deprn_expense,
              bonus_deprn_amount,
              bonus_ytd_deprn,
              bonus_deprn_reserve,
              impairment_amount,
              ytd_impairment,
              impairment_reserve
             ) VALUES (
              X_set_of_books_id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Deprn_Run_Date,
              X_Deprn_Amount,
              X_Ytd_Deprn,
              X_Deprn_Reserve,
              X_Deprn_Source_Code,
              X_Adjusted_Cost,
              X_Bonus_Rate,
              X_Ltd_Production,
              X_Period_Counter,
              X_Production,
              X_Reval_Amortization,
              X_Reval_Amortization_Basis,
              X_Reval_Deprn_Expense,
              X_Reval_Reserve,
              X_Ytd_Production,
              X_Ytd_Reval_Deprn_Expense,
              X_Bonus_Deprn_Amount,
              X_Bonus_Ytd_Deprn,
              X_Bonus_Deprn_Reserve,
              X_Impairment_Amount,
              X_Ytd_Impairment,
              X_impairment_reserve
             );

          OPEN C_ds_mc;
          FETCH C_ds_mc INTO X_Rowid;
          if (C_ds_mc%NOTFOUND) then
            CLOSE C_ds_mc;
            Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ds_mc;

       else
          INSERT INTO fa_deprn_summary(
              book_type_code,
              asset_id,
              deprn_run_date,
              deprn_amount,
              ytd_deprn,
              deprn_reserve,
              deprn_source_code,
              adjusted_cost,
              bonus_rate,
              ltd_production,
              period_counter,
              production,
              reval_amortization,
              reval_amortization_basis,
              reval_deprn_expense,
              reval_reserve,
              ytd_production,
              ytd_reval_deprn_expense,
              bonus_deprn_amount,
              bonus_ytd_deprn,
              bonus_deprn_reserve,
              impairment_amount,
              ytd_impairment,
              impairment_reserve
             ) VALUES (
              X_Book_Type_Code,
              X_Asset_Id,
              X_Deprn_Run_Date,
              X_Deprn_Amount,
              X_Ytd_Deprn,
              X_Deprn_Reserve,
              X_Deprn_Source_Code,
              X_Adjusted_Cost,
              X_Bonus_Rate,
              X_Ltd_Production,
              X_Period_Counter,
              X_Production,
              X_Reval_Amortization,
              X_Reval_Amortization_Basis,
              X_Reval_Deprn_Expense,
              X_Reval_Reserve,
              X_Ytd_Production,
              X_Ytd_Reval_Deprn_Expense,
              X_Bonus_Deprn_Amount,
              X_Bonus_Ytd_Deprn,
              X_Bonus_Deprn_Reserve,
              X_Impairment_Amount,
              X_Ytd_Impairment,
              X_impairment_reserve
             );

          OPEN C_ds;
          FETCH C_ds INTO X_Rowid;
          if (C_ds%NOTFOUND) then
            CLOSE C_ds;
            Raise NO_DATA_FOUND;
          end if;
          CLOSE C_ds;

       end if;


  exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
             CALLED_FN => 'fa_deprn_summary_pkg.insert_row',
             CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);

  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Deprn_Run_Date                   DATE,
                     X_Deprn_Amount                     NUMBER,
                     X_Ytd_Deprn                        NUMBER,
                     X_Deprn_Reserve                    NUMBER,
                     X_Deprn_Source_Code                VARCHAR2,
                     X_Adjusted_Cost                    NUMBER,
                     X_Bonus_Rate                       NUMBER DEFAULT NULL,
                     X_Ltd_Production                   NUMBER DEFAULT NULL,
                     X_Period_Counter                   NUMBER,
                     X_Production                       NUMBER DEFAULT NULL,
                     X_Reval_Amortization               NUMBER DEFAULT NULL,
                     X_Reval_Amortization_Basis         NUMBER DEFAULT NULL,
                     X_Reval_Deprn_Expense              NUMBER DEFAULT NULL,
                     X_Reval_Reserve                    NUMBER DEFAULT NULL,
                     X_Ytd_Production                   NUMBER DEFAULT NULL,
                     X_Ytd_Reval_Deprn_Expense          NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT      book_type_code,
          asset_id,
          deprn_run_date,
          deprn_amount,
          ytd_deprn,
          deprn_reserve,
          deprn_source_code,
          adjusted_cost,
          bonus_rate,
          ltd_production,
          period_counter,
          production,
          reval_amortization,
          reval_amortization_basis,
          reval_deprn_expense,
          reval_reserve,
          ytd_production,
          ytd_reval_deprn_expense,
          prior_fy_expense
        FROM   fa_deprn_summary
        WHERE  rowid = X_Rowid
        FOR UPDATE of Asset_Id NOWAIT;
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

               (Recinfo.book_type_code =  X_Book_Type_Code)
           AND (Recinfo.asset_id =  X_Asset_Id)
           AND (Recinfo.deprn_run_date =  X_Deprn_Run_Date)
           AND (Recinfo.deprn_amount =  X_Deprn_Amount)
           AND (Recinfo.ytd_deprn =  X_Ytd_Deprn)
           AND (Recinfo.deprn_reserve =  X_Deprn_Reserve)
           AND (Recinfo.deprn_source_code =  X_Deprn_Source_Code)
           AND (Recinfo.adjusted_cost =  X_Adjusted_Cost)
           AND (   (Recinfo.bonus_rate =  X_Bonus_Rate)
                OR (    (Recinfo.bonus_rate IS NULL)
                    AND (X_Bonus_Rate IS NULL)))
           AND (   (Recinfo.ltd_production =  X_Ltd_Production)
                OR (    (Recinfo.ltd_production IS NULL)
                    AND (X_Ltd_Production IS NULL)))
           AND (Recinfo.period_counter =  X_Period_Counter)
           AND (   (Recinfo.production =  X_Production)
                OR (    (Recinfo.production IS NULL)
                    AND (X_Production IS NULL)))
           AND (   (Recinfo.reval_amortization =  X_Reval_Amortization)
                OR (    (Recinfo.reval_amortization IS NULL)
                    AND (X_Reval_Amortization IS NULL)))
           AND (   (Recinfo.reval_amortization_basis =
                         X_Reval_Amortization_Basis)
                OR (    (Recinfo.reval_amortization_basis IS NULL)
                    AND (X_Reval_Amortization_Basis IS NULL)))
           AND (   (Recinfo.reval_deprn_expense =  X_Reval_Deprn_Expense)
                OR (    (Recinfo.reval_deprn_expense IS NULL)
                    AND (X_Reval_Deprn_Expense IS NULL)))
           AND (   (Recinfo.reval_reserve =  X_Reval_Reserve)
                OR (    (Recinfo.reval_reserve IS NULL)
                    AND (X_Reval_Reserve IS NULL)))
           AND (   (Recinfo.ytd_production =  X_Ytd_Production)
                OR (    (Recinfo.ytd_production IS NULL)
                    AND (X_Ytd_Production IS NULL)))
           AND (   (Recinfo.ytd_reval_deprn_expense =
                              X_Ytd_Reval_Deprn_Expense)
                OR (    (Recinfo.ytd_reval_deprn_expense IS NULL)
                    AND (X_Ytd_Reval_Deprn_Expense IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Deprn_Run_Date                 DATE     DEFAULT NULL,
                       X_Deprn_Amount                   NUMBER   DEFAULT NULL,
                       X_Ytd_Deprn                      NUMBER   DEFAULT NULL,
                       X_Deprn_Reserve                  NUMBER   DEFAULT NULL,
                       X_Deprn_Source_Code              VARCHAR2 DEFAULT NULL,
                       X_Adjusted_Cost                  NUMBER   DEFAULT NULL,
                       X_Bonus_Rate                     NUMBER   DEFAULT NULL,
                       X_Ltd_Production                 NUMBER   DEFAULT NULL,
                       X_Period_Counter                 NUMBER   DEFAULT NULL,
                       X_Production                     NUMBER   DEFAULT NULL,
                       X_Reval_Amortization             NUMBER   DEFAULT NULL,
                       X_Reval_Amortization_Basis       NUMBER   DEFAULT NULL,
                       X_Reval_Deprn_Expense            NUMBER   DEFAULT NULL,
                       X_Reval_Reserve                  NUMBER   DEFAULT NULL,
                       X_Ytd_Production                 NUMBER   DEFAULT NULL,
                       X_Ytd_Reval_Deprn_Expense        NUMBER   DEFAULT NULL,
                       X_Bonus_Deprn_Amount             NUMBER   DEFAULT NULL,
                       X_Bonus_Ytd_Deprn                NUMBER   DEFAULT NULL,
                       X_Bonus_Deprn_Reserve            NUMBER   DEFAULT NULL,
                       X_Impairment_Amount              NUMBER   DEFAULT NULL,
                       X_Ytd_Impairment                 NUMBER   DEFAULT NULL,
                       X_impairment_reserve                 NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2

  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    if (X_rowid is not null) then

       if (X_mrc_sob_type_code = 'R') then

          UPDATE fa_mc_deprn_summary
          SET
              book_type_code                  =     decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
              asset_id                        =     decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
              deprn_run_date                  =     decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
              deprn_amount                    =     decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
              ytd_deprn                       =     decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
              deprn_reserve                   =     decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
              deprn_source_code               =     decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
              adjusted_cost                   =     decode(X_Adjusted_Cost,
                                                    NULL, adjusted_cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Adjusted_Cost),
              bonus_rate                      =     decode(X_Bonus_Rate,
                                                    NULL, bonus_rate,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Rate),
              ltd_production                  =     decode(X_Ltd_Production,
                                                    NULL, ltd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ltd_Production),
              period_counter                  =     decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
              production                      =     decode(X_Production,
                                                    NULL, production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Production),
              reval_amortization              =     decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
              reval_amortization_basis        =     decode(X_Reval_Amortization_Basis,
                                                    NULL, reval_amortization_basis,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization_Basis),
              reval_deprn_expense             =     decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
              reval_reserve                   =     decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
              ytd_production                  =     decode(X_Ytd_Production,
                                                    NULL, ytd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Production),
              ytd_reval_deprn_expense         =     decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense),
              bonus_deprn_amount              =     decode(X_Bonus_Deprn_Amount,
                                                    NULL,  bonus_deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Amount),
              bonus_ytd_deprn                 =     decode(X_Bonus_Ytd_Deprn,
                                                    NULL, bonus_ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Ytd_Deprn),
              bonus_deprn_reserve             =     decode(X_Bonus_Deprn_Reserve,
                                                    NULL, bonus_deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Reserve),
              impairment_amount               =     decode(X_Impairment_Amount,
                                                    NULL,  impairment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Impairment_Amount),
              ytd_impairment                  =     decode(X_Ytd_Impairment,
                                                    NULL, ytd_impairment,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Impairment),
              impairment_reserve                  =     decode(X_impairment_reserve,
                                                    NULL, impairment_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_impairment_reserve)
          WHERE rowid = X_Rowid;

        else

          UPDATE fa_deprn_summary
          SET
              book_type_code                  =     decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
              asset_id                        =     decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
              deprn_run_date                  =     decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
              deprn_amount                    =     decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
              ytd_deprn                       =     decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
              deprn_reserve                   =     decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
              deprn_source_code               =     decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
              adjusted_cost                   =     decode(X_Adjusted_Cost,
                                                    NULL, adjusted_cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Adjusted_Cost),
              bonus_rate                      =     decode(X_Bonus_Rate,
                                                    NULL, bonus_rate,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Rate),
              ltd_production                  =     decode(X_Ltd_Production,
                                                    NULL, ltd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ltd_Production),
              period_counter                  =     decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
              production                      =     decode(X_Production,
                                                    NULL, production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Production),
              reval_amortization              =     decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
              reval_amortization_basis        =     decode(X_Reval_Amortization_Basis,
                                                    NULL, reval_amortization_basis,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization_Basis),
              reval_deprn_expense             =     decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
              reval_reserve                   =     decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
              ytd_production                  =     decode(X_Ytd_Production,
                                                    NULL, ytd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Production),
              ytd_reval_deprn_expense         =     decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense),
              bonus_deprn_amount              =     decode(X_Bonus_Deprn_Amount,
                                                    NULL,  bonus_deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Amount),
              bonus_ytd_deprn                 =     decode(X_Bonus_Ytd_Deprn,
                                                    NULL, bonus_ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Ytd_Deprn),
              bonus_deprn_reserve             =     decode(X_Bonus_Deprn_Reserve,
                                                    NULL, bonus_deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Reserve),
              impairment_amount               =     decode(X_Impairment_Amount,
                                                    NULL,  impairment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Impairment_Amount),
              ytd_impairment                  =     decode(X_Ytd_Impairment,
                                                    NULL, ytd_impairment,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Impairment),
              impairment_reserve                  =     decode(X_impairment_reserve,
                                                    NULL, impairment_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_impairment_reserve)
          WHERE rowid = X_Rowid;

       end if; -- mrc

    else       -- rowid is null (use asset,book,pc)

       if (X_mrc_sob_type_code = 'R') then
          UPDATE fa_mc_deprn_summary
          SET
              book_type_code                  =     decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
              asset_id                        =     decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
              deprn_run_date                  =     decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
              deprn_amount                    =     decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
              ytd_deprn                       =     decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
              deprn_reserve                   =     decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
              deprn_source_code               =     decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
              adjusted_cost                   =     decode(X_Adjusted_Cost,
                                                    NULL, adjusted_cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Adjusted_Cost),
              bonus_rate                      =     decode(X_Bonus_Rate,
                                                    NULL, bonus_rate,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Rate),
              ltd_production                  =     decode(X_Ltd_Production,
                                                    NULL, ltd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ltd_Production),
              period_counter                  =     decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
              production                      =     decode(X_Production,
                                                    NULL, production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Production),
              reval_amortization              =     decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
              reval_amortization_basis        =     decode(X_Reval_Amortization_Basis,
                                                    NULL, reval_amortization_basis,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization_Basis),
              reval_deprn_expense             =     decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
              reval_reserve                   =     decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
              ytd_production                  =     decode(X_Ytd_Production,
                                                    NULL, ytd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Production),
              ytd_reval_deprn_expense         =     decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense),
              bonus_deprn_amount              =     decode(X_Bonus_Deprn_Amount,
                                                    NULL,  bonus_deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Amount),
              bonus_ytd_deprn                 =     decode(X_Bonus_Ytd_Deprn,
                                                    NULL, bonus_ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Ytd_Deprn),
              bonus_deprn_reserve             =     decode(X_Bonus_Deprn_Reserve,
                                                    NULL, bonus_deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Reserve),
              impairment_amount               =     decode(X_Impairment_Amount,
                                                    NULL,  impairment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Impairment_Amount),
              ytd_impairment                  =     decode(X_Ytd_Impairment,
                                                    NULL, ytd_impairment,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Impairment),
              impairment_reserve                  =     decode(X_impairment_reserve,
                                                    NULL, impairment_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_impairment_reserve)
          WHERE book_type_code = X_Book_Type_Code
          and   asset_id       = X_Asset_Id
          and   period_counter = X_Period_Counter
          and   set_of_books_id = X_set_of_books_id;

        else

          UPDATE fa_deprn_summary
          SET
              book_type_code                  =     decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
              asset_id                        =     decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
              deprn_run_date                  =     decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
              deprn_amount                    =     decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
              ytd_deprn                       =     decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
              deprn_reserve                   =     decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
              deprn_source_code               =     decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
              adjusted_cost                   =     decode(X_Adjusted_Cost,
                                                    NULL, adjusted_cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Adjusted_Cost),
              bonus_rate                      =     decode(X_Bonus_Rate,
                                                    NULL, bonus_rate,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Rate),
              ltd_production                  =     decode(X_Ltd_Production,
                                                    NULL, ltd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ltd_Production),
              period_counter                  =     decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
              production                      =     decode(X_Production,
                                                    NULL, production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Production),
              reval_amortization              =     decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
              reval_amortization_basis        =     decode(X_Reval_Amortization_Basis,
                                                    NULL, reval_amortization_basis,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization_Basis),
              reval_deprn_expense             =     decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
              reval_reserve                   =     decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
              ytd_production                  =     decode(X_Ytd_Production,
                                                    NULL, ytd_production,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Production),
              ytd_reval_deprn_expense         =     decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense),
              bonus_deprn_amount              =     decode(X_Bonus_Deprn_Amount,
                                                    NULL,  bonus_deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Amount),
              bonus_ytd_deprn                 =     decode(X_Bonus_Ytd_Deprn,
                                                    NULL, bonus_ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Ytd_Deprn),
              bonus_deprn_reserve             =     decode(X_Bonus_Deprn_Reserve,
                                                    NULL, bonus_deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Bonus_Deprn_Reserve),
              impairment_amount               =     decode(X_Impairment_Amount,
                                                    NULL,  impairment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Impairment_Amount),
              ytd_impairment                  =     decode(X_Ytd_Impairment,
                                                    NULL, ytd_impairment,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Impairment),
              impairment_reserve                  =     decode(X_impairment_reserve,
                                                    NULL, impairment_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_impairment_reserve)
          WHERE book_type_code = X_Book_Type_Code
          and   asset_id       = X_Asset_Id
          and   period_counter = X_Period_Counter;

       end if; -- mrc

    end if;   -- rowid not null

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
         fa_srvr_msg.add_sql_error(
             calling_fn => 'fa_deprn_summary_pkg.update_row', p_log_level_rec => p_log_level_rec);
         raise;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid           VARCHAR2 DEFAULT NULL,
                       X_Asset_Id        NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code             VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn      VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    if (X_mrc_sob_type_code = 'R') then
       if X_Rowid is not null then
         DELETE FROM fa_mc_deprn_summary
         WHERE rowid = X_Rowid;
       elsif X_Asset_Id is not null then
         DELETE FROM fa_mc_deprn_summary
         WHERE asset_id = X_Asset_Id
         AND set_of_books_id = X_set_of_books_id;
       else
         -- print error message
         null;
       end if;
    else
       if X_Rowid is not null then
         DELETE FROM fa_deprn_summary
         WHERE rowid = X_Rowid;
       elsif X_Asset_Id is not null then
         DELETE FROM fa_deprn_summary
         WHERE asset_id = X_Asset_Id;
       else
         -- print error message
         null;
       end if;
    end if;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  exception
    when others then
         FA_STANDARD_PKG.RAISE_ERROR(
             CALLED_FN => 'fa_deprn_summary_pkg.delete_row',
             CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);

 END Delete_Row;


 PROCEDURE Lock_B_Row(X_Book_Type_Code         VARCHAR2 DEFAULT NULL,
                      X_Asset_Id               NUMBER,
                      X_Calling_Fn             VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
   CURSOR C_Books IS
        SELECT  book_type_code,
                asset_id,
                date_placed_in_service,
                date_effective,
                deprn_start_date,
                deprn_method_code,
                life_in_months,
                rate_adjustment_factor,
                adjusted_cost,
                cost,
                original_cost,
                salvage_value,
                prorate_convention_code,
                prorate_date,
                cost_change_flag,
                adjustment_required_status,
                capitalize_flag,
                retirement_pending_flag,
                depreciate_flag,
                last_update_date,
                last_updated_by,
                date_ineffective,
                transaction_header_id_in,
                transaction_header_id_out,
                itc_amount_id,
                itc_amount,
                retirement_id,
                tax_request_id,
                itc_basis,
                basic_rate,
                adjusted_rate,
                bonus_rule,
                ceiling_name,
                recoverable_cost,
                last_update_login,
                adjusted_capacity,
                fully_rsvd_revals_counter,
                idled_flag,
                period_counter_capitalized,
                period_counter_fully_reserved,
                period_counter_fully_retired,
                production_capacity,
                reval_amortization_basis,
                reval_ceiling,
                unit_of_measure,
                unrevalued_cost,
                annual_deprn_rounding_flag,
                percent_salvage_value,
                allowed_deprn_limit,
                allowed_deprn_limit_amount,
                period_counter_life_complete,
                adjusted_recoverable_cost,
                annual_rounding_flag,
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
                global_attribute_category,
                eofy_adj_cost,
                short_fiscal_year_flag,
                conversion_date,
                remaining_life1,
                remaining_life2,
                original_deprn_start_date,
                old_adjusted_cost,
                formula_factor,
                eofy_formula_factor,
                cash_generating_unit_id
         FROM   fa_books
         WHERE  Book_Type_Code = nvl(X_Book_Type_Code, Book_Type_Code)
         AND    Asset_Id = X_Asset_Id
         AND    Date_Ineffective is null
         FOR UPDATE of Asset_Id NOWAIT;
    Recinfo_Books C_Books%ROWTYPE;

   CURSOR C_AssetHistory IS
        SELECT     asset_id,
          category_id,
          asset_type,
          units,
          date_effective,
          date_ineffective,
          transaction_header_id_in,
          transaction_header_id_out,
          last_update_date,
          last_updated_by,
          last_update_login
        FROM   fa_asset_history
        WHERE  Asset_Id = X_Asset_Id
        AND    Date_Ineffective is null
        FOR UPDATE of Asset_Id NOWAIT;
    Recinfo_AssetHistory C_AssetHistory%ROWTYPE;

   CURSOR C_DistHistory IS
        SELECT     distribution_id,
          book_type_code,
          asset_id,
          units_assigned,
          date_effective,
          code_combination_id,
          location_id,
          transaction_header_id_in,
          last_update_date,
          last_updated_by,
          date_ineffective,
          assigned_to,
          transaction_header_id_out,
          transaction_units,
          retirement_id,
          last_update_login
        FROM   fa_distribution_history
        WHERE  Asset_Id = X_Asset_Id
        AND    Date_Ineffective is null
        FOR UPDATE of Asset_Id NOWAIT;
    Recinfo_DistHistory C_DistHistory%ROWTYPE;

   CURSOR C_DeprnSummary IS
        SELECT  book_type_code,
                asset_id,
                deprn_run_date,
                deprn_amount,
                ytd_deprn,
                deprn_reserve,
                deprn_source_code,
                adjusted_cost,
                bonus_rate,
                ltd_production,
                period_counter,
                production,
                reval_amortization,
                reval_amortization_basis,
                reval_deprn_expense,
                reval_reserve,
                ytd_production,
                ytd_reval_deprn_expense,
                prior_fy_expense,
                bonus_deprn_amount,
                bonus_ytd_deprn,
                bonus_deprn_reserve,
                prior_fy_bonus_expense,
                deprn_override_flag,
                system_deprn_amount,
                system_bonus_deprn_amount,
                impairment_amount,
                ytd_impairment,
                impairment_reserve
        FROM   fa_deprn_summary
        WHERE  Book_Type_Code = nvl(X_Book_Type_Code, Book_Type_Code)
        AND    Asset_Id = X_Asset_Id
        AND    Deprn_Source_Code = 'BOOKS'
        FOR UPDATE of Asset_Id NOWAIT;
    Recinfo_DeprnSummary C_DeprnSummary%ROWTYPE;

  BEGIN
    OPEN C_Books;
    FETCH C_Books INTO Recinfo_Books;
    if (C_Books%NOTFOUND) then
      CLOSE C_Books;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C_Books;

    OPEN C_AssetHistory;
    FETCH C_AssetHistory INTO Recinfo_AssetHistory;
    if (C_AssetHistory%NOTFOUND) then
      CLOSE C_AssetHistory;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C_AssetHistory;

    OPEN C_DistHistory;
    FETCH C_DistHistory INTO Recinfo_DistHistory;
    if (C_DistHistory%NOTFOUND) then
      CLOSE C_DistHistory;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C_DistHistory;

    OPEN C_DeprnSummary;
    FETCH C_DeprnSummary INTO Recinfo_DeprnSummary;
    if (C_DeprnSummary%NOTFOUND) then
      CLOSE C_DeprnSummary;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C_DeprnSummary;
  EXCEPTION
    when app_exception.record_lock_exception then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN  => 'fa_deprn_summary_pkg.lock_b_row',
          CALLING_FN => X_Calling_Fn,
          NAME       => 'FA_SHARED_ASSETS_LOCKED', p_log_level_rec => p_log_level_rec);
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN  => 'fa_deprn_summary_pkg.lock_b_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Lock_B_Row;


 PROCEDURE UnLock_B_Row(X_Calling_Fn               VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN

   rollback;

  EXCEPTION
    when others then
      FA_STANDARD_PKG.RAISE_ERROR(
          CALLED_FN  => 'fa_deprn_summary_pkg.unlock_b_row',
          CALLING_FN => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END UnLock_B_Row;

END FA_DEPRN_SUMMARY_PKG;

/
