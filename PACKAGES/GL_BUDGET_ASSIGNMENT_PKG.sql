--------------------------------------------------------
--  DDL for Package GL_BUDGET_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_ASSIGNMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdass.pls 120.6 2005/08/25 22:55:34 djogg ship $ */
--
-- Package
--   gl_budget_assignment_pkg
-- Purpose
--   To contain validation and insertion routines for gl_alloc_batches
-- History
--   12-03-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the code_combination_id/currency code
  --   /range_id combo is unique within that ledger
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   lgr_id           The ID of the ledger
  --   ccid             Code Combination ID
  --   curr_code        Currency code
  --   rng_id           Range Id
  --   row_id		The current rowid
  -- Example
  --   gl_budget_assignment_pkg.check_unique(2, 1012, 'USD', 501, 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(lgr_id NUMBER, ccid NUMBER, curr_code VARCHAR2,
			 rng_id NUMBER, row_id VARCHAR2);

  --
  -- Procedure
  --   delete_range_assignments
  -- Purpose
  --   Deletes all of the assignments assigned by a given range
  -- History
  --   12-10-93  D. J. Ogg    Created
  -- Arguments
  --   range_id         The ID of the Accounting Flexfield Ranges
  -- Example
  --   gl_budget_assignment_pkg.delete_range_assignment(1012);
  -- Notes
  --
  PROCEDURE delete_range_assignments(xrange_id NUMBER);

  --
  -- Procedure
  --   delete_assignment
  -- Purpose
  --   Deletes a given assignment
  -- History
  --   12-17-93  D. J. Ogg    Created
  -- Arguments
  --   lgr_id		The ledger containing the assignment
  --   ccid		The code combination id of the assignment
  --   curr_code	The currency code of the assignment
  --   rng_id           The range id
  -- Example
  --   gl_budget_assignment_pkg.delete_assignment(2, 1023, 'USD', 501);
  -- Notes
  --
  PROCEDURE delete_assignment(lgr_id NUMBER, ccid NUMBER,
                              curr_code VARCHAR2, rng_id NUMBER);


  --
  -- Procedure
  --   is_budget_calculated
  -- Purpose
  --   Find out whether the budget type is calculated or entered.
  --   Return TRUE for calculated type, FALSE for entered type.
  -- History
  --   13-MAR-94	ERumanan    Created
  -- Arguments
  --   xlgr_id           The ledger containing the assignment
  --   xccid             The code combination id of the assignment
  --   xcurr_code        The currency code of the assignment
  -- Example
  --   gl_budget_assignment_pkg.is_budget_calculated(2, 1023, 'USD');
  -- Notes
  --
  FUNCTION is_budget_calculated( xlgr_id	NUMBER,
                                 xccid 		NUMBER,
                                 xcurr_code	VARCHAR2 ) RETURN BOOLEAN;

  --
  -- Procedure
  --   is_acct_stat_enterable
  -- Purpose
  --   Determine whether you can budget stat amounts to a particular account.
  --   Return TRUE if so, FALSE otherwise.
  -- History
  --   23-AUG-94	R Ng    Created
  -- Arguments
  --   xsob_id           Ledger ID
  --   xccid             Code Combination ID
  -- Example
  --   gl_budget_assignment_pkg.is_acct_stat_enterable(2, 1023);
  -- Notes
  --
  FUNCTION is_acct_stat_enterable( xlgr_id	NUMBER,
                                   xccid 	NUMBER ) RETURN BOOLEAN;


  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the budget_entity_id, budget_entity_name,
  --   and entry_code.
  -- History
  --   21-MAR-94	DJOGG    Created
  -- Arguments
  --   xlgr_id           The ledger containing the assignment
  --   xccid             The code combination id of the assignment
  --   xcurr_code        The currency code of the assignment
  --   xentity_id	 The ID of the budget entity the code combination is
  --			 assigned to
  --   xentry_code	 The entry method for the assignment
  -- Example
  --   gl_budget_assignment_pkg.select_columns(2, 1023, 'USD', eid, ename,
  --                                           ecode);
  -- Notes
  --
  PROCEDURE select_columns( xlgr_id		NUMBER,
                            xccid 		NUMBER,
                            xcurr_code		VARCHAR2,
			    xentity_id		IN OUT NOCOPY NUMBER,
			    xentry_code		IN OUT NOCOPY VARCHAR2);


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,

                     X_Ledger_Id                            NUMBER,
                     X_Budget_Entity_Id                     NUMBER,
                     X_Code_Combination_Id                  NUMBER,
                     X_Currency_Code                        VARCHAR2,
                     X_Entry_Code                           VARCHAR2,
                     X_Ordering_Value                       VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Range_Id                             NUMBER
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Ledger_Id                              NUMBER,
                   X_Budget_Entity_Id                       NUMBER,
                   X_Code_Combination_Id                    NUMBER,
                   X_Currency_Code                          VARCHAR2,
                   X_Entry_Code                             VARCHAR2,
                   X_Ordering_Value                         VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Range_Id                               NUMBER
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Ordering_Value                      VARCHAR2,
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
                     X_Context                             VARCHAR2,
                     X_Range_Id                            NUMBER
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END gl_budget_assignment_pkg;

 

/
