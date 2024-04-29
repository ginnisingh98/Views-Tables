--------------------------------------------------------
--  DDL for Package Body FA_GROUP_DEPRN_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GROUP_DEPRN_SUMMARY_PKG" as
/* $Header: faxigdsb.pls 115.7 2003/08/22 15:35:17 bridgway noship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Group_Asset_Id                 NUMBER,
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
                       X_prior_fy_expense               NUMBER DEFAULT 0,
                       X_deprn_rate                     NUMBER DEFAULT 0,
                       X_Bonus_Deprn_Amount             NUMBER DEFAULT NULL,
                       X_Bonus_Ytd_Deprn                NUMBER DEFAULT NULL,
                       X_Bonus_Deprn_Reserve            NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_Calling_Fn                     VARCHAR2
  ) IS

  BEGIN

     NULL;

  END Insert_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
                       X_Group_Asset_Id                 NUMBER   DEFAULT NULL,
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
                       X_prior_fy_expense               NUMBER   DEFAULT NULL,
                       X_deprn_rate                     NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_Calling_Fn                     VARCHAR2
  ) IS

  BEGIN

     NULL;

  END Update_Row;



  PROCEDURE Delete_Row(X_Rowid             VARCHAR2 DEFAULT NULL,
                       X_Group_Asset_Id    NUMBER DEFAULT NULL,
                       X_mrc_sob_type_code VARCHAR2 DEFAULT 'P',
                       X_Calling_Fn        VARCHAR2) IS

  BEGIN

     NULL;

  END Delete_Row;

END FA_GROUP_DEPRN_SUMMARY_PKG;

/
