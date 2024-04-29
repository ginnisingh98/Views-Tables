--------------------------------------------------------
--  DDL for Package GL_AUTOREVERSE_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTOREVERSE_OPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: glistars.pls 120.6 2003/09/22 17:03:34 spala ship $ */

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Criteria_Set_Id                  NUMBER,
                     X_Je_Category_Name                 VARCHAR2,
                     X_Method_Code                      VARCHAR2,
                     X_Reversal_Period_Code             VARCHAR2,
                     X_Reversal_Date_Code               VARCHAR2,
                     X_Autoreverse_Flag                 VARCHAR2,
                     X_Autopost_Reversal_Flag           VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Context                          VARCHAR2
                    );


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Criteria_Set_Id                NUMBER,
                       X_Je_Category_Name               VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_Reversal_Period_Code           VARCHAR2,
                       X_Reversal_Date_Code             VARCHAR2,
                       X_Autoreverse_Flag               VARCHAR2,
                       X_Autopost_Reversal_Flag         VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Context                        VARCHAR2
                      );

  -- Procedure
  --   insert_reversal_cat
  -- Purpose
  --   insert a row for each new journal category created in the Journal
  --   Category form.
  -- Access
  --   Called from the Journal Category form API
  --      GL_JE_CATEGORIES_PKG.insert_other_cat

  PROCEDURE insert_reversal_cat( x_je_category_name       VARCHAR2,
                                 x_created_by             NUMBER,
                                 x_last_updated_by        NUMBER,
                                 x_last_update_login      NUMBER );

  -- Procedure
  --   insert_criteria_reversal_cat
  -- Purpose
  --   Insert a row for each journal category when a new ledger
  --   is created.
  -- Access
  --   Called from the Define Ledger form API
  --      GL_LEDGERS_PKG.Insert_Row

  PROCEDURE insert_criteria_reversal_cat(
					x_criteria_set_id              NUMBER,
                                        x_created_by             NUMBER,
                                        x_last_updated_by        NUMBER,
                                        x_last_update_login      NUMBER );


END GL_AUTOREVERSE_OPTIONS_PKG;

 

/
