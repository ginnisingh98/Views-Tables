--------------------------------------------------------
--  DDL for Package AP_FIX_ACCTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_FIX_ACCTG_PKG" AUTHID CURRENT_USER as
/* $Header: apfixacs.pls 115.2 2002/03/13 18:15:23 pkm ship      $ */


  PROCEDURE Update_Row(
                   X_Rowid                 IN VARCHAR2,
                   X_Code_Combination_Id   IN NUMBER,
                   X_Description           IN VARCHAR2,
                   X_Last_Update_Date      IN DATE,
                   X_Last_Updated_By       IN NUMBER,
                   X_Last_Update_Login     IN NUMBER,
                   X_Calling_Sequence      IN VARCHAR2,
                   X_Accounting_Error_Code IN VARCHAR2 --  < Bug1361925
                      );


  PROCEDURE Lock_Row(
                 X_Rowid               IN VARCHAR2,
                 X_Code_Combination_Id IN NUMBER,
                 X_Description         IN VARCHAR2,
                 X_Calling_Sequence    IN VARCHAR2
                    );


END AP_FIX_ACCTG_PKG;

 

/
