--------------------------------------------------------
--  DDL for Package FA_DISTRIBUTION_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DISTRIBUTION_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: faxidhs.pls 120.2.12010000.2 2009/07/19 13:09:32 glchen ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Distribution_Id                IN OUT NOCOPY NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Units_Assigned                 NUMBER,
                       X_Date_Effective                 DATE,
                       X_Code_Combination_Id            NUMBER,
                       X_Location_Id                    NUMBER,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Assigned_To                    NUMBER DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Transaction_Units              NUMBER DEFAULT NULL,
                       X_Retirement_Id                  NUMBER DEFAULT NULL,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Distribution_Id                  NUMBER,
                     X_Book_Type_Code                   VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Units_Assigned                   NUMBER,
                     X_Date_Effective                   DATE,
                     X_Code_Combination_Id              NUMBER,
                     X_Location_Id                      NUMBER,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Assigned_To                      NUMBER DEFAULT NULL,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Transaction_Units                NUMBER DEFAULT NULL,
                     X_Retirement_Id                    NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);



  PROCEDURE Update_Row(X_Rowid				VARCHAR2 DEFAULT NULL,
		       X_Distribution_Id                NUMBER,
                       X_Book_Type_Code                 VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Units_Assigned                 NUMBER,
                       X_Date_Effective                 DATE,
                       X_Code_Combination_Id            NUMBER,
                       X_Location_Id                    NUMBER,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Date_Ineffective               DATE,
                       X_Assigned_To                    NUMBER,
                       X_Transaction_Header_Id_Out      NUMBER,
                       X_Transaction_Units              NUMBER,
                       X_Retirement_Id                  NUMBER,
                       X_Last_Update_Login              NUMBER,
		         X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
			X_Asset_Id		NUMBER DEFAULT NULL,
			X_Book_Type_Code	VARCHAR2 DEFAULT NULL,
			X_Transaction_Header_Id	NUMBER DEFAULT NULL,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Reactivate_Row(X_Transaction_Header_Id_Out	NUMBER DEFAULT NULL,
			X_Asset_Id			NUMBER,
			X_Book_Type_Code		VARCHAR2,
		         X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_DISTRIBUTION_HISTORY_PKG;

/
