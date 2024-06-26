--------------------------------------------------------
--  DDL for Package FA_GROUP_DEPRN_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GROUP_DEPRN_DETAIL_PKG" AUTHID CURRENT_USER as
/* $Header: faxigdds.pls 115.4 2002/11/12 08:31:55 glchen noship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Group_Asset_Id                 NUMBER,
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
                       X_Bonus_Deprn_Amount             NUMBER,
                       X_Bonus_Ytd_Deprn                NUMBER,
                       X_Bonus_Deprn_Reserve            NUMBER,
                       X_mrc_sob_type_code              VARCHAR2 DEFAULT 'P',
                       X_Calling_Fn                     VARCHAR2
                      );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Book_Type_Code                 VARCHAR2 DEFAULT NULL,
                       X_Group_Asset_Id                 NUMBER   DEFAULT NULL,
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
                       X_Calling_Fn                     VARCHAR2
                      );

  PROCEDURE Delete_Row(X_Rowid             VARCHAR2 DEFAULT NULL,
                       X_Group_Asset_Id    NUMBER   DEFAULT NULL,
                       X_mrc_sob_type_code VARCHAR2 DEFAULT 'P',
                       X_Calling_Fn        VARCHAR2);

END FA_GROUP_DEPRN_DETAIL_PKG;

 

/
