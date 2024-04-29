--------------------------------------------------------
--  DDL for Package GL_ELIMINATION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ELIMINATION_SETS_PKG" AUTHID CURRENT_USER As
/* $Header: gliesets.pls 120.6 2005/05/05 01:07:33 kvora ship $ */
 --
 -- Package
 --  gl_elimination_sets_pkg
 -- Purpose
 --  Server routines related to table gl_elimination_sets
 -- History
 --  11/11/1998   W Wong      Created


  --
  -- Function
  --   Get_Unique_Id
  -- Purpose
  --   Gets nextval from GL_ELIMINATION_SETS
  -- Parameters
  --   None
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_ERROR_GETTING_UNIQUE_ID on failure
  --
  FUNCTION get_unique_id Return NUMBER;

  --
  -- Procedure
  --   get_company_description
  -- Purpose
  --   Gets the description for the elimination company value
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_coa_id 		ID of the current chart of accounts
  --   x_company_val		Elimination company value
  -- Notes
  --   None
  --
  FUNCTION get_company_description(
	      x_coa_id					NUMBER,
	      x_company_val				VARCHAR2
	   ) RETURN VARCHAR2;

  --
  -- Procedure
  --   Check_unique_name
  -- Purpose
  --   Unique check for name
  -- History
  --   05-Nov-98  W Wong 	Created
  --   31-OCT-02  J Huang	sobid-->ledgerid
  -- Parameters
  --   x_rowid		Rowid
  --   x_ledgerid	LedgerId
  --   x_name  		Name of elimination set
  --
  -- Notes
  --   None
  --
  PROCEDURE check_unique_name( X_rowid VARCHAR2,
			       X_ledgerid NUMBER,
                               X_name  VARCHAR2);


  --
  -- FUNCTION
  --   Allow_delete_record
  -- Purpose
  --   Check if we can allow deletion of the record.
  --   Deletion is not allowed if an elimination set is marked for tracking
  --   and it has generated at least once.
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_setid          Elimination Set ID
  --
  -- Notes
  --   None
  --
  FUNCTION allow_delete_record( X_setid NUMBER ) RETURN boolean;

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Locks a row in GL_ELIMINATION_SETS table.
  -- History
  --   09-10-03  P Sahay      Created
  --
  PROCEDURE lock_row(X_Rowid                  IN OUT NOCOPY    VARCHAR2,
                     X_Elimination_Set_Id     IN OUT NOCOPY    NUMBER,
                     X_Name                                VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Track_Elimination_Status            VARCHAR2,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
                     X_Elimination_Company                 VARCHAR2,
                     X_Last_Executed_Period                VARCHAR2,
                     X_Description                         VARCHAR2,
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
                     X_Context                             VARCHAR2,
                     X_Security_Flag                       VARCHAR2);


End gl_elimination_sets_pkg;

 

/
