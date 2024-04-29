--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_DETAIL_PKG" as
/* $Header: faxiddb.pls 120.3.12010000.2 2009/07/19 13:22:20 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Period_Counter                 NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Deprn_Source_Code              VARCHAR2,
                       X_Deprn_Run_Date                 DATE,
                       X_Deprn_Amount                   NUMBER,
                       X_Ytd_Deprn                      NUMBER,
                       X_Deprn_Reserve                  NUMBER,
                       X_Addition_Cost_To_Clear         NUMBER DEFAULT NULL,
                       X_Cost                           NUMBER DEFAULT NULL,
                       X_Deprn_Adjustment_Amount        NUMBER DEFAULT NULL,
                       X_Deprn_Expense_Je_Line_Num      NUMBER DEFAULT NULL,
                       X_Deprn_Reserve_Je_Line_Num      NUMBER DEFAULT NULL,
                       X_Reval_Amort_Je_Line_Num        NUMBER DEFAULT NULL,
                       X_Reval_Reserve_Je_Line_Num      NUMBER DEFAULT NULL,
                       X_Je_Header_Id                   NUMBER DEFAULT NULL,
                       X_Reval_Amortization             NUMBER DEFAULT NULL,
                       X_Reval_Deprn_Expense            NUMBER DEFAULT NULL,
                       X_Reval_Reserve                  NUMBER DEFAULT NULL,
                       X_Ytd_Reval_Deprn_Expense        NUMBER DEFAULT NULL,
                       X_Bonus_Deprn_Amount             NUMBER DEFAULT NULL,
                       X_Bonus_Ytd_Deprn                NUMBER DEFAULT NULL,
                       X_Bonus_Deprn_Reserve            NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    CURSOR C_dd IS SELECT rowid FROM fa_deprn_detail
                 WHERE distribution_id = X_Distribution_Id
                 AND   book_type_code = X_Book_Type_Code
                 AND   period_counter = X_Period_Counter;
    CURSOR C_dd_mc IS SELECT rowid FROM fa_mc_deprn_detail
                 WHERE distribution_id = X_Distribution_Id
                 AND   book_type_code = X_Book_Type_Code
                 AND   period_counter = X_Period_Counter
                 AND   set_of_books_id = X_set_of_books_id;

   BEGIN

       if (X_mrc_sob_type_code = 'R') then

          INSERT INTO fa_mc_deprn_detail(
              set_of_books_id,
              book_type_code,
              asset_id,
              period_counter,
              distribution_id,
              deprn_source_code,
              deprn_run_date,
              deprn_amount,
              ytd_deprn,
              deprn_reserve,
              addition_cost_to_clear,
              cost,
              deprn_adjustment_amount,
              deprn_expense_je_line_num,
              deprn_reserve_je_line_num,
              reval_amort_je_line_num,
              reval_reserve_je_line_num,
              je_header_id,
              reval_amortization,
              reval_deprn_expense,
              reval_reserve,
              ytd_reval_deprn_expense,
              bonus_deprn_amount,
              bonus_ytd_deprn,
              bonus_deprn_reserve
             ) VALUES (
              X_set_of_books_id,
              X_Book_Type_Code,
              X_Asset_Id,
              X_Period_Counter,
              X_Distribution_Id,
              X_Deprn_Source_Code,
              X_Deprn_Run_Date,
              X_Deprn_Amount,
              X_Ytd_Deprn,
              X_Deprn_Reserve,
              X_Addition_Cost_To_Clear,
              X_Cost,
              X_Deprn_Adjustment_Amount,
              X_Deprn_Expense_Je_Line_Num,
              X_Deprn_Reserve_Je_Line_Num,
              X_Reval_Amort_Je_Line_Num,
              X_Reval_Reserve_Je_Line_Num,
              X_Je_Header_Id,
              X_Reval_Amortization,
              X_Reval_Deprn_Expense,
              X_Reval_Reserve,
              X_Ytd_Reval_Deprn_Expense,
              X_Bonus_Deprn_Amount,
              X_Bonus_Ytd_Deprn,
              X_Bonus_Deprn_Reserve
             );

          OPEN C_dd_mc;
          FETCH C_dd_mc INTO X_Rowid;
          if (C_dd_mc%NOTFOUND) then
             CLOSE C_dd_mc;
             Raise NO_DATA_FOUND;
          end if;
          CLOSE C_dd_mc;
       else

          INSERT INTO fa_deprn_detail(
              book_type_code,
              asset_id,
              period_counter,
              distribution_id,
              deprn_source_code,
              deprn_run_date,
              deprn_amount,
              ytd_deprn,
              deprn_reserve,
              addition_cost_to_clear,
              cost,
              deprn_adjustment_amount,
              deprn_expense_je_line_num,
              deprn_reserve_je_line_num,
              reval_amort_je_line_num,
              reval_reserve_je_line_num,
              je_header_id,
              reval_amortization,
              reval_deprn_expense,
              reval_reserve,
              ytd_reval_deprn_expense,
              bonus_deprn_amount,
              bonus_ytd_deprn,
              bonus_deprn_reserve
             ) VALUES (
              X_Book_Type_Code,
              X_Asset_Id,
              X_Period_Counter,
              X_Distribution_Id,
              X_Deprn_Source_Code,
              X_Deprn_Run_Date,
              X_Deprn_Amount,
              X_Ytd_Deprn,
              X_Deprn_Reserve,
              X_Addition_Cost_To_Clear,
              X_Cost,
              X_Deprn_Adjustment_Amount,
              X_Deprn_Expense_Je_Line_Num,
              X_Deprn_Reserve_Je_Line_Num,
              X_Reval_Amort_Je_Line_Num,
              X_Reval_Reserve_Je_Line_Num,
              X_Je_Header_Id,
              X_Reval_Amortization,
              X_Reval_Deprn_Expense,
              X_Reval_Reserve,
              X_Ytd_Reval_Deprn_Expense,
              X_Bonus_Deprn_Amount,
              X_Bonus_Ytd_Deprn,
              X_Bonus_Deprn_Reserve
             );

          OPEN C_dd;
          FETCH C_dd INTO X_Rowid;
          if (C_dd%NOTFOUND) then
             CLOSE C_dd;
             Raise NO_DATA_FOUND;
          end if;
          CLOSE C_dd;

       end if;


  EXCEPTION
     WHEN Others THEN
          FA_STANDARD_PKG.RAISE_ERROR
               (Called_Fn     => 'FA_DEPRN_DETAIL_PKG.Insert_Row',
               Calling_Fn     => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Period_Counter                   NUMBER,
                     X_Distribution_Id                  NUMBER,
                     X_Deprn_Source_Code                VARCHAR2,
                     X_Deprn_Run_Date                   DATE,
                     X_Deprn_Amount                     NUMBER,
                     X_Ytd_Deprn                        NUMBER,
                     X_Deprn_Reserve                    NUMBER,
                     X_Addition_Cost_To_Clear           NUMBER DEFAULT NULL,
                     X_Cost                             NUMBER DEFAULT NULL,
                     X_Deprn_Adjustment_Amount          NUMBER DEFAULT NULL,
                     X_Deprn_Expense_Je_Line_Num        NUMBER DEFAULT NULL,
                     X_Deprn_Reserve_Je_Line_Num        NUMBER DEFAULT NULL,
                     X_Reval_Amort_Je_Line_Num          NUMBER DEFAULT NULL,
                     X_Reval_Reserve_Je_Line_Num        NUMBER DEFAULT NULL,
                     X_Je_Header_Id                     NUMBER DEFAULT NULL,
                     X_Reval_Amortization               NUMBER DEFAULT NULL,
                     X_Reval_Deprn_Expense              NUMBER DEFAULT NULL,
                     X_Reval_Reserve                    NUMBER DEFAULT NULL,
                     X_Ytd_Reval_Deprn_Expense          NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
    CURSOR C IS
        SELECT      book_type_code,
          asset_id,
          period_counter,
          distribution_id,
          deprn_source_code,
          deprn_run_date,
          deprn_amount,
          ytd_deprn,
          deprn_reserve,
          addition_cost_to_clear,
          cost,
          deprn_adjustment_amount,
          deprn_expense_je_line_num,
          deprn_reserve_je_line_num,
          reval_amort_je_line_num,
          reval_reserve_je_line_num,
          je_header_id,
          reval_amortization,
          reval_deprn_expense,
          reval_reserve,
          ytd_reval_deprn_expense
        FROM   fa_deprn_detail
        WHERE  rowid = X_Rowid
        FOR UPDATE of Distribution_Id NOWAIT;
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
           AND (Recinfo.period_counter =  X_Period_Counter)
           AND (Recinfo.distribution_id =  X_Distribution_Id)
           AND (Recinfo.deprn_source_code =  X_Deprn_Source_Code)
           AND (Recinfo.deprn_run_date =  X_Deprn_Run_Date)
           AND (Recinfo.deprn_amount =  X_Deprn_Amount)
           AND (Recinfo.ytd_deprn =  X_Ytd_Deprn)
           AND (Recinfo.deprn_reserve =  X_Deprn_Reserve)
           AND (   (Recinfo.addition_cost_to_clear =  X_Addition_Cost_To_Clear)
                OR (    (Recinfo.addition_cost_to_clear IS NULL)
                    AND (X_Addition_Cost_To_Clear IS NULL)))
           AND (   (Recinfo.cost =  X_Cost)
                OR (    (Recinfo.cost IS NULL)
                    AND (X_Cost IS NULL)))
           AND (   (Recinfo.deprn_adjustment_amount =X_Deprn_Adjustment_Amount)
                OR (    (Recinfo.deprn_adjustment_amount IS NULL)
                    AND (X_Deprn_Adjustment_Amount IS NULL)))
           AND (   (Recinfo.deprn_expense_je_line_num =
                    X_Deprn_Expense_Je_Line_Num)
                OR (    (Recinfo.deprn_expense_je_line_num IS NULL)
                    AND (X_Deprn_Expense_Je_Line_Num IS NULL)))
           AND (   (Recinfo.deprn_reserve_je_line_num =
                    X_Deprn_Reserve_Je_Line_Num)
                OR (    (Recinfo.deprn_reserve_je_line_num IS NULL)
                    AND (X_Deprn_Reserve_Je_Line_Num IS NULL)))
           AND (   (Recinfo.reval_amort_je_line_num =X_Reval_Amort_Je_Line_Num)
                OR (    (Recinfo.reval_amort_je_line_num IS NULL)
                    AND (X_Reval_Amort_Je_Line_Num IS NULL)))
           AND (   (Recinfo.reval_reserve_je_line_num =
                    X_Reval_Reserve_Je_Line_Num)
                OR (    (Recinfo.reval_reserve_je_line_num IS NULL)
                    AND (X_Reval_Reserve_Je_Line_Num IS NULL)))
           AND (   (Recinfo.je_header_id =  X_Je_Header_Id)
                OR (    (Recinfo.je_header_id IS NULL)
                    AND (X_Je_Header_Id IS NULL)))
           AND (   (Recinfo.reval_amortization =  X_Reval_Amortization)
                OR (    (Recinfo.reval_amortization IS NULL)
                    AND (X_Reval_Amortization IS NULL)))
           AND (   (Recinfo.reval_deprn_expense =  X_Reval_Deprn_Expense)
                OR (    (Recinfo.reval_deprn_expense IS NULL)
                    AND (X_Reval_Deprn_Expense IS NULL)))
           AND (   (Recinfo.reval_reserve =  X_Reval_Reserve)
                OR (    (Recinfo.reval_reserve IS NULL)
                    AND (X_Reval_Reserve IS NULL)))
           AND (   (Recinfo.ytd_reval_deprn_expense =X_Ytd_Reval_Deprn_Expense)
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
                       X_Period_Counter                 NUMBER   DEFAULT NULL,
                       X_Distribution_Id                NUMBER   DEFAULT NULL,
                       X_Deprn_Source_Code              VARCHAR2 DEFAULT NULL,
                       X_Deprn_Run_Date                 DATE     DEFAULT NULL,
                       X_Deprn_Amount                   NUMBER   DEFAULT NULL,
                       X_Ytd_Deprn                      NUMBER   DEFAULT NULL,
                       X_Deprn_Reserve                  NUMBER   DEFAULT NULL,
                       X_Addition_Cost_To_Clear         NUMBER   DEFAULT NULL,
                       X_Cost                           NUMBER   DEFAULT NULL,
                       X_Deprn_Adjustment_Amount        NUMBER   DEFAULT NULL,
                       X_Deprn_Expense_Je_Line_Num      NUMBER   DEFAULT NULL,
                       X_Deprn_Reserve_Je_Line_Num      NUMBER   DEFAULT NULL,
                       X_Reval_Amort_Je_Line_Num        NUMBER   DEFAULT NULL,
                       X_Reval_Reserve_Je_Line_Num      NUMBER   DEFAULT NULL,
                       X_Je_Header_Id                   NUMBER   DEFAULT NULL,
                       X_Reval_Amortization             NUMBER   DEFAULT NULL,
                       X_Reval_Deprn_Expense            NUMBER   DEFAULT NULL,
                       X_Reval_Reserve                  NUMBER   DEFAULT NULL,
                       X_Ytd_Reval_Deprn_Expense        NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   BEGIN

       if (X_rowid is not null) then

          if (X_mrc_sob_type_code = 'R') then
             UPDATE fa_mc_deprn_detail
             SET
             book_type_code                  =      decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
             asset_id                        =      decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
             period_counter                  =      decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
             distribution_id                 =      decode(X_Distribution_Id,
                                                    NULL, distribution_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Distribution_Id),
             deprn_source_code               =      decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
             deprn_run_date                  =      decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
             deprn_amount                    =      decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
             ytd_deprn                       =      decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
             deprn_reserve                   =      decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
             addition_cost_to_clear          =      decode(X_Addition_Cost_To_Clear,
                                                    NULL, addition_cost_to_clear,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Addition_Cost_To_Clear),
             cost                            =      decode(X_Cost,
                                                    NULL, cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Cost),
             deprn_adjustment_amount         =      decode(X_Deprn_Adjustment_Amount,
                                                    NULL, deprn_adjustment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Adjustment_Amount),
             deprn_expense_je_line_num       =      decode(X_Deprn_Expense_Je_Line_Num,
                                                    NULL, deprn_expense_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Expense_Je_Line_Num),
             deprn_reserve_je_line_num       =      decode(X_Deprn_Reserve_Je_Line_Num,
                                                    NULL, deprn_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve_Je_Line_Num),
             reval_amort_je_line_num         =      decode(X_Reval_Amort_Je_Line_Num,
                                                    NULL, reval_amort_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amort_Je_Line_Num),
             reval_reserve_je_line_num       =      decode(X_Reval_Reserve_Je_Line_Num,
                                                    NULL, reval_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve_Je_Line_Num),
             je_header_id                    =      decode(X_Je_Header_Id,
                                                    NULL, je_header_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Je_Header_Id),
             reval_amortization              =      decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
             reval_deprn_expense             =      decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
             reval_reserve                   =      decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
             ytd_reval_deprn_expense         =      decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense)
          WHERE rowid = X_Rowid;

       else
          UPDATE fa_deprn_detail
          SET
             book_type_code                  =      decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
             asset_id                        =      decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
             period_counter                  =      decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
             distribution_id                 =      decode(X_Distribution_Id,
                                                    NULL, distribution_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Distribution_Id),
             deprn_source_code               =      decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
             deprn_run_date                  =      decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
             deprn_amount                    =      decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
             ytd_deprn                       =      decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
             deprn_reserve                   =      decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
             addition_cost_to_clear          =      decode(X_Addition_Cost_To_Clear,
                                                    NULL, addition_cost_to_clear,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Addition_Cost_To_Clear),
             cost                            =      decode(X_Cost,
                                                    NULL, cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Cost),
             deprn_adjustment_amount         =      decode(X_Deprn_Adjustment_Amount,
                                                    NULL, deprn_adjustment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Adjustment_Amount),
             deprn_expense_je_line_num       =      decode(X_Deprn_Expense_Je_Line_Num,
                                                    NULL, deprn_expense_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Expense_Je_Line_Num),
             deprn_reserve_je_line_num       =      decode(X_Deprn_Reserve_Je_Line_Num,
                                                    NULL, deprn_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve_Je_Line_Num),
             reval_amort_je_line_num         =      decode(X_Reval_Amort_Je_Line_Num,
                                                    NULL, reval_amort_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amort_Je_Line_Num),
             reval_reserve_je_line_num       =      decode(X_Reval_Reserve_Je_Line_Num,
                                                    NULL, reval_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve_Je_Line_Num),
             je_header_id                    =      decode(X_Je_Header_Id,
                                                    NULL, je_header_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Je_Header_Id),
             reval_amortization              =      decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
             reval_deprn_expense             =      decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
             reval_reserve                   =      decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
             ytd_reval_deprn_expense         =      decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense)
          WHERE rowid = X_Rowid;
       end if;
    else
          if (X_mrc_sob_type_code = 'R') then
             UPDATE fa_mc_deprn_detail
             SET
             book_type_code                  =      decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
             asset_id                        =      decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
             period_counter                  =      decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
             distribution_id                 =      decode(X_Distribution_Id,
                                                    NULL, distribution_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Distribution_Id),
             deprn_source_code               =      decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
             deprn_run_date                  =      decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
             deprn_amount                    =      decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
             ytd_deprn                       =      decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
             deprn_reserve                   =      decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
             addition_cost_to_clear          =      decode(X_Addition_Cost_To_Clear,
                                                    NULL, addition_cost_to_clear,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Addition_Cost_To_Clear),
             cost                            =      decode(X_Cost,
                                                    NULL, cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Cost),
             deprn_adjustment_amount         =      decode(X_Deprn_Adjustment_Amount,
                                                    NULL, deprn_adjustment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Adjustment_Amount),
             deprn_expense_je_line_num       =      decode(X_Deprn_Expense_Je_Line_Num,
                                                    NULL, deprn_expense_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Expense_Je_Line_Num),
             deprn_reserve_je_line_num       =      decode(X_Deprn_Reserve_Je_Line_Num,
                                                    NULL, deprn_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve_Je_Line_Num),
             reval_amort_je_line_num         =      decode(X_Reval_Amort_Je_Line_Num,
                                                    NULL, reval_amort_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amort_Je_Line_Num),
             reval_reserve_je_line_num       =      decode(X_Reval_Reserve_Je_Line_Num,
                                                    NULL, reval_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve_Je_Line_Num),
             je_header_id                    =      decode(X_Je_Header_Id,
                                                    NULL, je_header_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Je_Header_Id),
             reval_amortization              =      decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
             reval_deprn_expense             =      decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
             reval_reserve                   =      decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
             ytd_reval_deprn_expense         =      decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense)
          WHERE book_type_code  = X_Book_Type_Code
          and   asset_id        = X_Asset_Id
          and   period_counter  = X_Period_Counter
          and   distribution_id = decode(X_Distribution_Id,
                                         NULL, distribution_id,
                                         X_Distribution_Id)
          and   set_of_books_id = X_set_of_books_id;

       else
          UPDATE fa_deprn_detail
          SET
             book_type_code                  =      decode(X_Book_Type_Code,
                                                    NULL, book_type_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Book_Type_Code),
             asset_id                        =      decode(X_Asset_Id,
                                                    NULL, asset_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Asset_Id),
             period_counter                  =      decode(X_Period_Counter,
                                                    NULL, period_counter,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Period_Counter),
             distribution_id                 =      decode(X_Distribution_Id,
                                                    NULL, distribution_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Distribution_Id),
             deprn_source_code               =      decode(X_Deprn_Source_Code,
                                                    NULL, deprn_source_code,
                                                    FND_API.G_MISS_CHAR, null,
                                                    X_Deprn_Source_Code),
             deprn_run_date                  =      decode(X_Deprn_Run_Date,
                                                    NULL, deprn_run_date,
                                                    X_Deprn_Run_Date),
             deprn_amount                    =      decode(X_Deprn_Amount,
                                                    NULL,  deprn_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Amount),
             ytd_deprn                       =      decode(X_Ytd_Deprn,
                                                    NULL, ytd_deprn,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Deprn),
             deprn_reserve                   =      decode(X_Deprn_Reserve,
                                                    NULL, deprn_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve),
             addition_cost_to_clear          =      decode(X_Addition_Cost_To_Clear,
                                                    NULL, addition_cost_to_clear,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Addition_Cost_To_Clear),
             cost                            =      decode(X_Cost,
                                                    NULL, cost,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Cost),
             deprn_adjustment_amount         =      decode(X_Deprn_Adjustment_Amount,
                                                    NULL, deprn_adjustment_amount,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Adjustment_Amount),
             deprn_expense_je_line_num       =      decode(X_Deprn_Expense_Je_Line_Num,
                                                    NULL, deprn_expense_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Expense_Je_Line_Num),
             deprn_reserve_je_line_num       =      decode(X_Deprn_Reserve_Je_Line_Num,
                                                    NULL, deprn_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Deprn_Reserve_Je_Line_Num),
             reval_amort_je_line_num         =      decode(X_Reval_Amort_Je_Line_Num,
                                                    NULL, reval_amort_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amort_Je_Line_Num),
             reval_reserve_je_line_num       =      decode(X_Reval_Reserve_Je_Line_Num,
                                                    NULL, reval_reserve_je_line_num,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve_Je_Line_Num),
             je_header_id                    =      decode(X_Je_Header_Id,
                                                    NULL, je_header_id,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Je_Header_Id),
             reval_amortization              =      decode(X_Reval_Amortization,
                                                    NULL, reval_amortization,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Amortization),
             reval_deprn_expense             =      decode(X_Reval_Deprn_Expense,
                                                    NULL, reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Deprn_Expense),
             reval_reserve                   =      decode(X_Reval_Reserve,
                                                    NULL, reval_reserve,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Reval_Reserve),
             ytd_reval_deprn_expense         =      decode(X_Ytd_Reval_Deprn_Expense,
                                                    NULL, ytd_reval_deprn_expense,
                                                    FND_API.G_MISS_NUM, null,
                                                    X_Ytd_Reval_Deprn_Expense)
          WHERE book_type_code  = X_Book_Type_Code
          and   asset_id        = X_Asset_Id
          and   period_counter  = X_Period_Counter
          and   distribution_id = decode(X_Distribution_Id,
                                         NULL, distribution_id,
                                         X_Distribution_Id);


       end if;
    end if; -- rowid is null

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
     WHEN Others THEN
          FA_STANDARD_PKG.RAISE_ERROR
               (Called_Fn     => 'FA_DEPRN_DETAIL_PKG.Update_Row',
               Calling_Fn     => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Update_Row;


  PROCEDURE Delete_Row(X_Rowid           VARCHAR2 DEFAULT NULL,
                       X_Asset_Id        NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code       VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id         NUMBER ,
                       X_Calling_Fn      VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

   BEGIN

       if (X_mrc_sob_type_code = 'R') then
          if X_Rowid is not null then
             DELETE FROM fa_mc_deprn_detail
             WHERE rowid = X_Rowid;
          elsif X_Asset_Id is not null then
             DELETE FROM fa_mc_deprn_detail
             WHERE asset_id = X_Asset_Id
             AND set_of_books_id = X_set_of_books_id;
          else
             -- error message
             null;
          end if;
       else
          if X_Rowid is not null then
             DELETE FROM fa_deprn_detail
             WHERE rowid = X_Rowid;
          elsif X_Asset_Id is not null then
             DELETE FROM fa_deprn_detail
             WHERE asset_id = X_Asset_Id;
          else
             -- error message
             null;
          end if;
       end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
     WHEN Others THEN
          FA_STANDARD_PKG.RAISE_ERROR
               (Called_Fn     => 'FA_DEPRN_DETAIL_PKG.Delete_Row',
               Calling_Fn     => X_Calling_Fn, p_log_level_rec => p_log_level_rec);
  END Delete_Row;


END FA_DEPRN_DETAIL_PKG;

/
