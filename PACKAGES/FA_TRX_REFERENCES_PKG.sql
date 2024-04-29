--------------------------------------------------------
--  DDL for Package FA_TRX_REFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRX_REFERENCES_PKG" AUTHID CURRENT_USER as
/* $Header: faxitrs.pls 120.3.12010000.2 2009/07/19 10:20:30 glchen ship $ */


  PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY VARCHAR2,
                       X_Trx_Reference_Id         IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                  VARCHAR2,
                       X_Src_Asset_Id                    NUMBER,
                       X_Src_Transaction_Header_Id       NUMBER,
                       X_Dest_Asset_Id                   NUMBER,
                       X_Dest_Transaction_Header_Id      NUMBER,
                       X_Member_Asset_Id                 NUMBER   DEFAULT NULL,
                       X_Member_Transaction_Header_Id    NUMBER   DEFAULT NULL,
                       X_Transaction_Type                VARCHAR2 DEFAULT NULL,
                       X_Src_Transaction_Subtype         VARCHAR2 DEFAULT NULL,
                       X_Dest_Transaction_Subtype        VARCHAR2 DEFAULT NULL,
                       X_Src_Amortization_Start_Date     DATE     DEFAULT NULL,
                       X_Dest_Amortization_Start_Date    DATE     DEFAULT NULL,
                       X_Reserve_Transfer_Amount         NUMBER   DEFAULT NULL,
                       X_Src_Expense_Amount              NUMBER   DEFAULT NULL,
                       X_Dest_Expense_Amount             NUMBER   DEFAULT NULL,
                       X_Src_Eofy_Reserve                NUMBER   DEFAULT NULL,
                       X_Dest_Eofy_Reserve               NUMBER   DEFAULT NULL,
                       X_Creation_Date                   DATE,
                       X_Created_By                      NUMBER,
                       X_Last_Update_Date                DATE,
                       X_Last_Updated_By                 NUMBER,
                       X_Last_Update_Login               NUMBER   DEFAULT NULL,
                       X_Invoice_Transaction_Id          NUMBER   DEFAULT NULL,
                       X_Event_Id                        NUMBER   DEFAULT NULL,
		       X_Return_Status               OUT NOCOPY BOOLEAN,
		       X_Calling_Fn                      VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/*
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

  PROCEDURE Update_Row(X_Rowid                            VARCHAR2,

  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
*/

END FA_TRX_REFERENCES_PKG;

/
