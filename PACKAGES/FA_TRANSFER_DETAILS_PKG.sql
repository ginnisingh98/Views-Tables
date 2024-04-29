--------------------------------------------------------
--  DDL for Package FA_TRANSFER_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANSFER_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: faxitds.pls 120.2.12010000.2 2009/07/19 10:17:59 glchen ship $ */


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Transfer_Header_Id             NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Book_Header_Id                 NUMBER,
			X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Transfer_Header_Id               NUMBER,
                     X_Distribution_Id                  NUMBER,
                     X_Book_Header_Id                   NUMBER,
			X_Calling_Fn			VARCHAR2
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Transfer_Header_Id             NUMBER,
                       X_Distribution_Id                NUMBER,
                       X_Book_Header_Id                 NUMBER,
			X_Calling_Fn			VARCHAR2
                      , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  PROCEDURE Delete_Row(X_Rowid 			VARCHAR2 DEFAULT NULL,
			X_Transfer_Header_Id 	NUMBER DEFAULT NULL,
			X_Calling_Fn			VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_TRANSFER_DETAILS_PKG;

/
