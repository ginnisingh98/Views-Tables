--------------------------------------------------------
--  DDL for Package GL_INTERCOMPANY_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_INTERCOMPANY_ACCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: gliacics.pls 120.5 2005/05/05 00:58:34 kvora ship $ */
--
-- Package
--   GL_INTERCOMPANY_ACCTS_PKG
-- Purpose
--   To group all the procedures/functions for gl_intercompany_acc_sets.
-- History
--   19-Oct-98		S. Kung		Created
--


  --
  -- Procedure
  --   check_acc_set_unique
  -- Purpose
  --   Checks the uniqueness of the combination from the source name
  --   and category name.
  -- History
  --   19-Oct-98	S. Kung		Created
  -- Arguments
  --   x_rowid    		The ID of the row to be checked
  --   x_ledger_id       	The ledger to be checked
  --   x_je_source_name     	The source name to be checked
  --   x_je_category_name     	The category name to be checked
  -- Example
  --   GL_INTERCOMPANY_ACCTS_PKG.check_acc_set_unique(
  --     :block.rowid,
  --     123,
  --     'Manual',
  --     'Adjustment');
  -- Notes
  --
  PROCEDURE check_acc_set_unique( x_rowid  		VARCHAR2,
                          	  x_ledger_id	        NUMBER,
                          	  x_je_source_name	VARCHAR2,
                          	  x_je_category_name	VARCHAR2);


-- *********************************************************************

  --
  -- Procedure
  --   check_acct_unique
  -- Purpose
  --   Checks the uniqueness of the combination from the source name
  --   and category name and balancing segment value.
  -- History
  --   19-Oct-98	S. Kung		Created
  -- Arguments
  --   x_ledger_id             The ledger to be checked
  --   x_je_source_name        The source name to be checked
  --   x_je_category_name      The category name to be checked
  --   x_bal_seg_value         The balancing segment value to be checked
  -- Example
  --   GL_INTERCOMPANY_ACCTS_PKG.check_acct_unique(
  --     123,
  --     'Manual',
  --     'Adjustment',
  --	 '01');
  -- Notes
  --
  PROCEDURE check_acct_unique( x_rowid			VARCHAR2,
		  	       x_ledger_id	        NUMBER,
                               x_je_source_name		VARCHAR2,
                               x_je_category_name	VARCHAR2,
			       x_bal_seg_value		VARCHAR2 );

-- *********************************************************************
  --
  -- Procedure
  --   is_other_exist
  -- Purpose
  --   Check if intercompany with source and category "Other"
  --   exists.  If it exists, return TRUE, else return FALSE.
  -- History
  --   19-Oct-98	S. Kung		Created
  -- Arguments
  --   x_ledger_id             The ledger to be checked
  -- Example
  --   GL_INTERCOMPANY_ACCTS_PKG.is_other_exist( 123 );
  -- Notes
  --
  FUNCTION is_other_exist( x_ledger_id NUMBER ) RETURN BOOLEAN;

-- *********************************************************************

-- The following procedures are necessary to handle the base table since
-- the forms is based on the view.


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Je_Source_Name                       VARCHAR2,
                     X_Je_Category_Name                     VARCHAR2,
                     X_Ledger_Id                            NUMBER,
		     X_Balance_By_Code			    VARCHAR2,
		     X_Bal_Seg_Rule_Code		    VARCHAR2,
		     X_Always_Balance_Flag		    VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
		     X_Default_Bal_Seg_Value		    VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Context                              VARCHAR2);

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Source_Name                         VARCHAR2,
                   X_Je_Category_Name                       VARCHAR2,
                   X_Ledger_Id                              NUMBER,
		   X_Balance_By_Code			    VARCHAR2,
		   X_Bal_Seg_Rule_Code			    VARCHAR2,
		   X_Always_Balance_Flag		    VARCHAR2,
		   X_Default_Bal_Seg_Value		    VARCHAR2,
                   X_Attribute1	                            VARCHAR2,
                   X_Attribute2	                            VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Context                                VARCHAR2);

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Ledger_Id                     NUMBER,
		     X_Balance_By_Code			   VARCHAR2,
		     X_Bal_Seg_Rule_Code		   VARCHAR2,
		     X_Always_Balance_Flag		   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
		     X_Default_Bal_Seg_Value		   VARCHAR2,
                     X_Attribute1	                   VARCHAR2,
                     X_Attribute2	                   VARCHAR2,
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

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END GL_INTERCOMPANY_ACCTS_PKG;

 

/
