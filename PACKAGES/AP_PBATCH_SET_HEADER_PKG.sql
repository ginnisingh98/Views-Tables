--------------------------------------------------------
--  DDL for Package AP_PBATCH_SET_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PBATCH_SET_HEADER_PKG" AUTHID CURRENT_USER as
/* $Header: apbseths.pls 120.2 2004/10/27 01:28:57 pjena noship $ */

PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY   VARCHAR2,
                     X_Batch_Set_Name                   VARCHAR2,
                     X_Batch_Set_Id            IN OUT NOCOPY   NUMBER,
                     X_Last_Update_Date                 DATE,
                     X_Last_Updated_By                  NUMBER,
                     X_Last_Update_Login                NUMBER DEFAULT NULL,
                     X_Creation_Date                    DATE DEFAULT NULL,
                     X_Created_By                       NUMBER DEFAULT NULL,
                     X_Inactive_Date                    DATE DEFAULT NULL,
		     X_calling_sequence	      IN	VARCHAR2
  );

    PROCEDURE Lock_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Set_Name                 VARCHAR2,
                       X_Batch_Set_Id                   NUMBER,
                       X_Inactive_Date                    DATE DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2

  ) ;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Batch_Set_Name                 VARCHAR2,
                       X_Batch_Set_Id                   NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER DEFAULT NULL,
                       X_Creation_Date                  DATE DEFAULT NULL,
                       X_Created_By                     NUMBER DEFAULT NULL,
                       X_Inactive_Date                    DATE DEFAULT NULL,
		       X_calling_sequence	IN	VARCHAR2

  ) ;

/*
   PROCEDURE Delete_Row(X_Rowid 				VARCHAR2,
		       X_calling_sequence	IN	VARCHAR2) ;
*/



END AP_PBATCH_SET_HEADER_PKG;

 

/
