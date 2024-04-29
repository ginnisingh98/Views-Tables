--------------------------------------------------------
--  DDL for Package GL_LEDGER_SET_NORM_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_LEDGER_SET_NORM_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: glistlas.pls 120.6 2005/05/05 01:23:30 kvora ship $ */
--
-- Package
--   GL_LEDGER_SET_NORM_ASSIGN_PKG
-- Purpose
--   To create GL_LEDGER_SET_NORM_ASSIGN_PKG package.
-- History
--   02-MAR-2001 K Vora        Created
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure that ledger or ledger set has not already been assigned to
  --   the ledger set.
  -- History
  --   02-MAR-2001 K Vora        Created
  -- Arguments
  --   x_name     The ledger/ledger set name to be checked
  -- Example
  --   GL_LEDGER_SET_NORM_ASSIGN_PKG.check_unique( 'LSET 1' );
  -- Notes
  --
  PROCEDURE check_unique(X_Rowid                        VARCHAR2,
                         X_Ledger_Set_Id                NUMBER,
                         X_Ledger_Id                    NUMBER);

-- *********************************************************************

-- The following procedures are necessary to handle insert/delete operations
-- in the base table.

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Ledger_Set_Id                  NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Object_Type_Code               VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Request_Id                     NUMBER
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Ledger_Set_Id                    NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Context                          VARCHAR2,
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
                     X_Request_Id                       NUMBER
                    );

  /* This routine should be deleted if it is not required. The Ledger Sets
     form does not use this routine. */
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Ledger_Set_Id                  NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Context                        VARCHAR2,
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
                       X_Request_Id                     NUMBER
                      );

  PROCEDURE Delete_Row(X_Rowid           VARCHAR2);

  FUNCTION Check_Assignments_Exist(X_Ledger_Set_Id      NUMBER)
    RETURN BOOLEAN;

-- *********************************************************************
-- The following procedure is for the Ledger Set iSetup API.

  --
  -- Procedure
  --   validate_ledger_assignment
  -- Purpose
  --   For iSetup API: validate the ledger detail assignment
  -- History
  --   06-16-2004   T Cheng     Created
  -- Notes
  --
  PROCEDURE validate_ledger_assignment(X_Ls_Coa_Id              NUMBER,
                                       X_Ls_Period_Set_Name     VARCHAR2,
                                       X_Ls_Period_Type         VARCHAR2,
                                       X_Ledger_Id              NUMBER);

-- *********************************************************************

END GL_LEDGER_SET_NORM_ASSIGN_PKG;

 

/
