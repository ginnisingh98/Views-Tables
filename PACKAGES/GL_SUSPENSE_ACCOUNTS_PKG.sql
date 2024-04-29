--------------------------------------------------------
--  DDL for Package GL_SUSPENSE_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SUSPENSE_ACCOUNTS_PKG" AUTHID CURRENT_USER as
/* $Header: gliacsas.pls 120.5 2005/05/05 00:58:49 kvora ship $ */

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                      NUMBER,
                     X_Je_Source_Name                       VARCHAR2,
                     X_Je_Category_Name                     VARCHAR2,
                     X_Code_Combination_Id                  NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Context                              VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Ledger_Id                        NUMBER,
                   X_Je_Source_Name                         VARCHAR2,
                   X_Je_Category_Name                       VARCHAR2,
                   X_Code_Combination_Id                    NUMBER,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Context                                VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                     NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

PROCEDURE Check_Unique(X_Ledger_Id                   NUMBER,
                       X_Je_Source_Name                    VARCHAR2,
                       X_Je_Category_Name                  VARCHAR2,
                       X_Rowid                             VARCHAR2
                       );


FUNCTION is_ledger_suspense_exist( x_ledger_id NUMBER ) RETURN BOOLEAN;

PROCEDURE insert_ledger_suspense( x_ledger_id     NUMBER,
                                  x_code_combination_id NUMBER,
                                  x_last_update_date    DATE,
                                  x_last_updated_by     NUMBER );

PROCEDURE update_ledger_suspense( x_ledger_id     NUMBER,
                                  x_code_combination_id NUMBER,
                                  x_last_update_date    DATE,
                                  x_last_updated_by     NUMBER );


END GL_SUSPENSE_ACCOUNTS_PKG;

 

/
