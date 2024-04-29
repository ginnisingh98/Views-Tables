--------------------------------------------------------
--  DDL for Package FA_ASSET_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: faxiahs.pls 120.3.12010000.2 2009/07/19 13:27:10 glchen ship $ */
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Asset_Id                       NUMBER,
                       X_Category_Id                    NUMBER,
                       X_Asset_Type                     VARCHAR2,
                       X_Units                          NUMBER,
                       X_Date_Effective                 DATE,
                       X_Date_Ineffective               DATE DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER,
                       X_Transaction_Header_Id_Out      NUMBER DEFAULT NULL,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Asset_Id                         NUMBER,
                     X_Category_Id                      NUMBER,
                     X_Asset_Type                       VARCHAR2,
                     X_Units                            NUMBER,
                     X_Date_Effective                   DATE,
                     X_Date_Ineffective                 DATE DEFAULT NULL,
                     X_Transaction_Header_Id_In         NUMBER,
                     X_Transaction_Header_Id_Out        NUMBER DEFAULT NULL,
                     X_Calling_Fn                       VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                       NUMBER   DEFAULT NULL,
                       X_Category_Id                    NUMBER   DEFAULT NULL,
                       X_Asset_Type                     VARCHAR2 DEFAULT NULL,
                       X_Units                          NUMBER   DEFAULT NULL,
                       X_Date_Effective                 DATE     DEFAULT NULL,
                       X_Date_Ineffective               DATE     DEFAULT NULL,
                       X_Transaction_Header_Id_In       NUMBER   DEFAULT NULL,
                       X_Transaction_Header_Id_Out      NUMBER   DEFAULT NULL,
                       X_Last_Update_Date               DATE     DEFAULT NULL,
                       X_Last_Updated_By                NUMBER   DEFAULT NULL,
                       X_Last_Update_Login              NUMBER   DEFAULT NULL,
                       X_Return_Status              OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(X_Rowid                        VARCHAR2 DEFAULT NULL,
                       X_Asset_Id                     NUMBER DEFAULT NULL,
                       X_Transaction_Header_Id_In     NUMBER DEFAULT NULL,
                       X_Calling_Fn                   VARCHAR2
               , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Reactivate_Row(X_Transaction_Header_Id_Out     NUMBER,
                           X_asset_id                      NUMBER,
                           X_Calling_Fn                    VARCHAR2
               , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_ASSET_HISTORY_PKG;

/
