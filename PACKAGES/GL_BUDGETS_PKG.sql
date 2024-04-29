--------------------------------------------------------
--  DDL for Package GL_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGETS_PKG" AUTHID CURRENT_USER AS
/* $Header: glibddfs.pls 120.4 2005/05/05 01:01:24 kvora ship $ */
--
-- Package
--   gl_budgets
-- Purpose
--   To implement various data checking needed for the
--   gl_budgets table
-- History
--   10-14-93  D. J. Ogg    Created
--

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure the given budget_name is
  --   unique within gl_budgets.
  -- History
  --   10-14-93  D. J. Ogg    Created
  -- Arguments
  --   name      	The budget name to be checked
  --   rowid		The ID of the row to be checked
  -- Example
  --   gl_budgets.check_unique('DBUDGET', 'ABD0123');
  -- Notes
  --
  PROCEDURE check_unique(name VARCHAR2,
	                 row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique budget version id for a new budget.
  -- History
  --   10-14-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_budgets_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;


  --
  -- Procedure
  --   is_budget_journals_not_req
  -- Purpose
  --   Find the existence of any budget which does not require budget
  --   journals.  If it is found return TRUE else return FALSE.
  -- History
  --   12.01.93   E. Rumanang   Created
  -- Arguments
  --   x_ledger_id              ledger_id       to be checked.
  -- Example
  --   gl_budgets_pkg.is_budget_journals_not_req( 123 );
  -- Notes
  --
  FUNCTION is_budget_journals_not_req(
    x_ledger_id        NUMBER )  RETURN BOOLEAN;


  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_budgets associated with
  --   the given budget.
  -- History
  --   09-SEP-94  E. Rumanang  Created.
  -- Arguments
  --   recinfo gl_budgets
  -- Example
  --   select_row.recinfo;
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_budgets%ROWTYPE );



  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Gets the values of some columns from gl_budgets associated with
  --   the given budget.
  -- History
  --   09-SEP-94  E. Rumanang  Created.
  -- Arguments
  --   x_ledger_id
  --   x_budget_name
  --   x_ledger_id
  --   x_budget_type
  --   x_status
  --   x_required_bj_flag
  --   x_latest_opened_year
  --   x_first_valid_period_name
  --   x_last_valid_period_name
  --
  PROCEDURE select_columns(
              x_budget_name                             VARCHAR2,
              x_ledger_id                               NUMBER,
              x_budget_type                     IN OUT NOCOPY  VARCHAR2,
              x_status                          IN OUT NOCOPY  VARCHAR2,
              x_required_bj_flag                IN OUT NOCOPY  VARCHAR2,
              x_latest_opened_year              IN OUT NOCOPY  NUMBER,
              x_first_valid_period_name         IN OUT NOCOPY  VARCHAR2,
              x_last_valid_period_name          IN OUT NOCOPY  VARCHAR2 );



  PROCEDURE Insert_Row(
		     X_Rowid                    IN OUT NOCOPY VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_Ledger_id                       NUMBER,
                     X_Status                          VARCHAR2,
                     X_Date_Created                    DATE,
                     X_Require_Budget_Journals_Flag    VARCHAR2,
                     X_Current_Version_Id              NUMBER DEFAULT NULL,
                     X_Latest_Opened_Year              NUMBER DEFAULT NULL,
                     X_First_Valid_Period_Name         VARCHAR2 DEFAULT NULL,
                     X_Last_Valid_Period_Name          VARCHAR2 DEFAULT NULL,
                     X_Description                     VARCHAR2 DEFAULT NULL,
                     X_Date_Closed                     DATE DEFAULT NULL,
                     X_Attribute1                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                      VARCHAR2 DEFAULT NULL,
                     X_Attribute3                      VARCHAR2 DEFAULT NULL,
                     X_Attribute4                      VARCHAR2 DEFAULT NULL,
                     X_Attribute5                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                      VARCHAR2 DEFAULT NULL,
                     X_Attribute7                      VARCHAR2 DEFAULT NULL,
                     X_Attribute8                      VARCHAR2 DEFAULT NULL,
                     X_Context                         VARCHAR2 DEFAULT NULL,
		     X_User_Id 			       NUMBER,
		     X_Login_Id			       NUMBER,
		     X_Date                            DATE,
		     X_Budget_Version_Id	       NUMBER,
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL
                     );

  PROCEDURE Lock_Row(
		   X_Rowid                             VARCHAR2,
                   X_Budget_Type                       VARCHAR2,
                   X_Budget_Name                       VARCHAR2,
                   X_Ledger_id                         NUMBER,
                   X_Last_Update_Date                  DATE,
                   X_Last_Updated_By                   NUMBER,
                   X_Status                            VARCHAR2,
                   X_Date_Created                      DATE,
                   X_Require_Budget_Journals_Flag      VARCHAR2,
                   X_Creation_Date                     DATE DEFAULT NULL,
                   X_Created_By                        NUMBER DEFAULT NULL,
                   X_Last_Update_Login                 NUMBER DEFAULT NULL,
                   X_Current_Version_Id                NUMBER DEFAULT NULL,
                   X_Latest_Opened_Year                NUMBER DEFAULT NULL,
                   X_First_Valid_Period_Name           VARCHAR2 DEFAULT NULL,
                   X_Last_Valid_Period_Name            VARCHAR2 DEFAULT NULL,
                   X_Description                       VARCHAR2 DEFAULT NULL,
                   X_Date_Closed                       DATE DEFAULT NULL,
                   X_Attribute1                        VARCHAR2 DEFAULT NULL,
                   X_Attribute2                        VARCHAR2 DEFAULT NULL,
                   X_Attribute3                        VARCHAR2 DEFAULT NULL,
                   X_Attribute4                        VARCHAR2 DEFAULT NULL,
                   X_Attribute5                        VARCHAR2 DEFAULT NULL,
                   X_Attribute6                        VARCHAR2 DEFAULT NULL,
                   X_Attribute7                        VARCHAR2 DEFAULT NULL,
                   X_Attribute8                        VARCHAR2 DEFAULT NULL,
                   X_Context                           VARCHAR2 DEFAULT NULL
                   );

  PROCEDURE Update_Row(
                     X_Rowid                           VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_Ledger_id                       NUMBER,
                     X_Status                          VARCHAR2,
                     X_Date_Created                    DATE,
                     X_Require_Budget_Journals_Flag    VARCHAR2,
                     X_Current_Version_Id              NUMBER DEFAULT NULL,
                     X_Latest_Opened_Year              NUMBER DEFAULT NULL,
                     X_First_Valid_Period_Name         VARCHAR2 DEFAULT NULL,
                     X_Last_Valid_Period_Name          VARCHAR2 DEFAULT NULL,
                     X_Description                     VARCHAR2 DEFAULT NULL,
                     X_Date_Closed                     DATE DEFAULT NULL,
                     X_Attribute1                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                      VARCHAR2 DEFAULT NULL,
                     X_Attribute3                      VARCHAR2 DEFAULT NULL,
                     X_Attribute4                      VARCHAR2 DEFAULT NULL,
                     X_Attribute5                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                      VARCHAR2 DEFAULT NULL,
                     X_Attribute7                      VARCHAR2 DEFAULT NULL,
                     X_Attribute8                      VARCHAR2 DEFAULT NULL,
                     X_Context                         VARCHAR2 DEFAULT NULL,
		     X_User_Id 			       NUMBER,
		     X_Login_Id			       NUMBER,
		     X_Date                            DATE,
		     X_Budget_Version_Id	       NUMBER,
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL
                     );

  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END gl_budgets_pkg;

 

/
