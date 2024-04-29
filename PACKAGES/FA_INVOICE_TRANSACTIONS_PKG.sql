--------------------------------------------------------
--  DDL for Package FA_INVOICE_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INVOICE_TRANSACTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: faxitss.pls 120.2.12010000.2 2009/07/19 10:21:45 glchen ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Invoice_Transaction_Id         IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Transaction_Type               VARCHAR2,
                       X_Date_Effective                 DATE,
			X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Invoice_Transaction_Id           NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Transaction_Type                 VARCHAR2,
                     X_Date_Effective                   DATE,
			X_Calling_Fn			VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Invoice_Transaction_Id         NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Transaction_Type               VARCHAR2,
                       X_Date_Effective                 DATE,
			X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			X_Calling_Fn	VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_INVOICE_TRANSACTIONS_PKG;

/
