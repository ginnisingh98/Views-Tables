--------------------------------------------------------
--  DDL for Package GL_AUTHORIZATION_LIMITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTHORIZATION_LIMITS_PKG" AUTHID CURRENT_USER as
/* $Header: gliemals.pls 120.5 2005/05/05 01:07:19 kvora ship $ */
--
-- Package
--   GL_AUTHORIZATION_LIMITS_PKG
-- Purpose
--   To contain validation and insertion routines for gl_authorization_limits
-- History
--   08-07-97    R Goyal    Created.
  --
  -- Procedure
  --  Insert_Row
  -- Purpose
  --   Inserts a row into gl_authorization_limits
  -- History
  --   08-07-97  R Goyal    Created.
  -- Arguments
  --   all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   gl_authorization_limits_pkg.Insert_Row(....);
  -- Notes
  --
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Authorization_Limit                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2);
  --
  -- Procedure
  --  Lock_Row
  -- Purpose
  --   Locks a row into gl_authorization_limits
  -- History
  --   08-07-97   R Goyal     Created.
  -- Arguments
  --   all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   gl_authorization_limits.Lock_Row(....;
  -- Notes
  --
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Employee_Id                           NUMBER,
                   X_Authorization_Limit                   NUMBER,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Context                               VARCHAR2 );
  --
  -- Procedure
  --  Update_Row
  -- Purpose
  --   Updates a row into gl_authorization_limits
  -- History
  --   08-07-97     R Goyal     Created.
  -- Arguments
  --   all the columns of the table GL_AUTHORIZATION_LIMITS
  -- Example
  --   gl_authorization_limits_pkg.Update_Row(....;
  -- Notes
  --
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Employee_Id                         NUMBER,
                     X_Authorization_Limit                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2 );
  --
  -- Procedure
  --  Delete_Row
  -- Purpose
  --   Deletes a row from gl_authorization_limits
  -- History
  --   08-07-97    R Goyal     Created.
  -- Arguments
  --    x_rowid         Rowid of a row
  -- Example
  --   gl_authorization_limits_pkg.delete_row('ajfdshj');
  -- Notes
  --
PROCEDURE Delete_Row(X_Rowid 	VARCHAR2);

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that employee_name is unique.
  -- History
  --   08-08-97    R Goyal    Created.
  -- Arguments
  --   X_row_id                         The row ID
  --   x_ledger_id                      Ledger Id
  --   x_employee_id                    Employee ID
  -- Example
  --   gl_authorization_limits_pkg.check_unique(...
  -- Notes
  --
FUNCTION Check_Unique(X_Rowid                  VARCHAR2,
                      X_ledger_id              NUMBER,
                      X_employee_id            NUMBER,
                      X_employee_name          VARCHAR2 ) RETURN BOOLEAN;

END GL_AUTHORIZATION_LIMITS_PKG;

 

/
