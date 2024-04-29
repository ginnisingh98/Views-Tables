--------------------------------------------------------
--  DDL for Package FA_DEPRN_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: faxidss.pls 120.3.12010000.2 2009/07/19 10:32:37 glchen ship $ */


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
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

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
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



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
                       X_impairment_reserve             NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
                       X_Calling_Fn                     VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(X_Rowid                 VARCHAR2 DEFAULT NULL,
                       X_Asset_Id              NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code     VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id       NUMBER ,
                       X_Calling_Fn            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Lock_B_Row(X_Book_Type_Code        VARCHAR2 DEFAULT NULL,
                       X_Asset_Id              NUMBER,
                       X_Calling_Fn            VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE UnLock_B_Row(X_Calling_Fn          VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_DEPRN_SUMMARY_PKG;

/
