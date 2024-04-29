--------------------------------------------------------
--  DDL for Package FA_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADJUSTMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: faxiajs.pls 120.2.12010000.2 2009/07/19 13:29:07 glchen ship $ */


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
                       X_mrc_sob_type_code             VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
		       X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

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
		     X_Calling_Fn			VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



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
                       X_mrc_sob_type_code             VARCHAR2 DEFAULT 'P',
                       X_set_of_books_id                NUMBER ,
		       X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Delete_Row(X_Rowid 		VARCHAR2 DEFAULT NULL,
			X_Asset_Id	NUMBER DEFAULT NULL,
                        X_mrc_sob_type_code            VARCHAR2 DEFAULT 'P',
                        X_set_of_books_id                NUMBER ,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_ADJUSTMENTS_PKG;

/
