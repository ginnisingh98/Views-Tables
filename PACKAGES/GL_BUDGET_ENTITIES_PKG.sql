--------------------------------------------------------
--  DDL for Package GL_BUDGET_ENTITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_ENTITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: glibdors.pls 120.7.12010000.2 2009/03/20 06:01:09 skotakar ship $ */
--
-- Package
--   gl_budget_entities_pkg
-- Purpose
--   To contain validation and insertion routines for gl_budget_entities
-- History
--   12-03-93  	D. J. Ogg	Created
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the budget organization
  --   is unique in this set of books.
  -- History
  --   12-03-93  D. J. Ogg    Created
  --   05-22-96  U. Thimmappa Added code to detect duplicate bud org
  --                          with status code = 'D'.
  -- Arguments
  --   lgr_id		The ledger id.
  --   org_name 	The name of the budget organization
  --   row_id		The current rowid
  -- Example
  --   gl_budget_entities_pkg.check_unique(2, 'Test1', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(lgr_id NUMBER, org_name VARCHAR2, row_id VARCHAR2);

  --
  -- Procedure
  --   check_for_all
  -- Purpose
  --   Determines if there exists a budget organization
  --   in this set of books named ALL (when the name is
  --   converted to all caps) other than the one with rowid, row_id.
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   lgr_id 		The ledger ID
  --   row_id           The row to ignore in the search
  -- Example
  --   i := gl_budget_entities_pkg.check_for_all(2, 'ABD02334');
  -- Notes
  --
  FUNCTION check_for_all(lgr_id NUMBER, row_id VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   has_ranges
  -- Purpose
  --   Determines if the budget organization has been assigned any
  --   ranges.
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   org_id		The ID of the budget organization
  -- Example
  --   i := gl_budget_entities_pkg.has_ranges(1000);
  -- Notes
  --
  FUNCTION has_ranges(org_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique budget entity id
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   abid := gl_budget_entities_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   lock_organization
  -- Purpose
  --   Locks the given budget organization
  -- History
  --   12-16-93  D. J. Ogg    Created
  -- Arguments
  --   org_id			The budget entity id
  -- Example
  --   lock_organization(1000);
  -- Notes
  --
  PROCEDURE lock_organization(org_id NUMBER);

  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Used to select the name, password required flag, and
  --   encrypted password.
  -- History
  --   21-MAR-94	DJOGG    Created
  -- Arguments
  --   entity_id	 	The ID of the budget entity.
  --   entity_name       	The Name of the budget entity.
  --   password_required_flag	A flag indicating whether or not the budget
  --				password is required.
  --   encrypted_password	The encrypted password
  --   status			The budget entity status
  -- Example
  --   gl_budget_assignment_pkg.select_columns(2, ename);
  -- Notes
  --
  PROCEDURE select_columns( entity_id			NUMBER,
			    entity_name			IN OUT NOCOPY VARCHAR2,
			    password_required_flag	IN OUT NOCOPY VARCHAR2,
			    encrypted_password		IN OUT NOCOPY VARCHAR2,
			    status_code			IN OUT NOCOPY VARCHAR2,
			    security_flag               IN OUT NOCOPY VARCHAR2
			    );


  --
  -- Procedure
  --   budget_and_account_seg_info
  -- Purpose
  --   Used to get current_budgetname and id, and the account segment name
  -- History
  --   5-MAR-95		K. Nigam    Created
  -- Arguments
  --      lgr_id               ledger id
  --      coa_id               chart of accounts id
  --      x_budget_version_id  budget_version_id
  --      x_budget_name        budget name
  --      x_bj_required        budget journals required
  --      x_segment_name       account segment name
  --
  PROCEDURE budget_and_account_seg_info(
                               lgr_id            NUMBER,
                               coa_id               NUMBER,
                               x_budget_version_id  IN OUT NOCOPY NUMBER,
                               x_budget_name        IN OUT NOCOPY VARCHAR2,
                               x_bj_required        IN OUT NOCOPY VARCHAR2,
                               x_segment_name       OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Used to do the insert processing for a row
  -- History
  --   6-Mar-95	 K. Nigam    Created
  --   7-Aug-03  P  Sahay    Added X_Security_Flag
  --
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Budget_Entity_Id        IN OUT NOCOPY NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_All_Name                       BOOLEAN,
                       X_Chart_Of_Accounts_Id           NUMBER,
                       X_Security_Flag			VARCHAR2
);

  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Used to do the update processing for a row
  -- History
  --   6-Mar-95	 K. Nigam    Created
  --   7-Aug-03  P  Sahay    Added X_Security_Flag
  --
  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Budget_Entity_Id               NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_All_Name                       BOOLEAN,
                       X_Security_Flag                  VARCHAR2);

  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Locks a row in GL_BUDGET_ENTITIES table.
  -- History
  --   08-07-03  P Sahay      Created
  --
  PROCEDURE Lock_Row  (X_Rowid                IN OUT NOCOPY    VARCHAR2,
                       X_Budget_Entity_Id     IN OUT NOCOPY    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Security_Flag			VARCHAR2);

  --
  -- Procedure
  --   Insert_Org
  -- Purpose
  --   Inserts a row in GL_BUDGET_ENTITIES table.
  --   Called by an iSpeed API.
  -- History
  --   11-07-00  K Vora       Created
  --
  PROCEDURE Insert_Org(X_Rowid               IN OUT NOCOPY     VARCHAR2,
                       X_Budget_Entity_Id    IN OUT NOCOPY     NUMBER,
                       X_Name                           VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Budget_Password_Required       VARCHAR2,
                       X_Status_Code                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Encrypted_Budget_Password      VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Segment1_Type                  NUMBER,
                       X_Segment2_Type                  NUMBER,
                       X_Segment3_Type                  NUMBER,
                       X_Segment4_Type                  NUMBER,
                       X_Segment5_Type                  NUMBER,
                       X_Segment6_Type                  NUMBER,
                       X_Segment7_Type                  NUMBER,
                       X_Segment8_Type                  NUMBER,
                       X_Segment9_Type                  NUMBER,
                       X_Segment10_Type                 NUMBER,
                       X_Segment11_Type                 NUMBER,
                       X_Segment12_Type                 NUMBER,
                       X_Segment13_Type                 NUMBER,
                       X_Segment14_Type                 NUMBER,
                       X_Segment15_Type                 NUMBER,
                       X_Segment16_Type                 NUMBER,
                       X_Segment17_Type                 NUMBER,
                       X_Segment18_Type                 NUMBER,
                       X_Segment19_Type                 NUMBER,
                       X_Segment20_Type                 NUMBER,
                       X_Segment21_Type                 NUMBER,
                       X_Segment22_Type                 NUMBER,
                       X_Segment23_Type                 NUMBER,
                       X_Segment24_Type                 NUMBER,
                       X_Segment25_Type                 NUMBER,
                       X_Segment26_Type                 NUMBER,
                       X_Segment27_Type                 NUMBER,
                       X_Segment28_Type                 NUMBER,
                       X_Segment29_Type                 NUMBER,
                       X_Segment30_Type                 NUMBER,
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
                       X_Context                        VARCHAR2);

  --
  -- Function
  --   Submit_Assign_Ranges_Request
  -- Purpose
  --   Submits the Assign Account Ranges concurrent program.
  --   Called by an iSpeed API.
  -- History
  --   11-07-00  K Vora       Created
  -- Argument
  --   sobid - Ledger id
  --   orgid - Budget entity id
  -- Returns
  --   The request id if the concurrent program was submitted successfully,
  --   else returns 0.
  --
  FUNCTION Submit_Assign_Ranges_Request(
			  X_Ledger_id   IN VARCHAR2,
			  X_Orgid       IN VARCHAR2)
			  return NUMBER;
  --
  -- Procedure
  --   Set_BC_Timestamp
  -- Purpose
  --   Sets the event timestamp used by budgetary control.
  --   Called by an iSpeed API.
  -- History
  --   11-07-00  K Vora       Created
  --
  PROCEDURE Set_BC_Timestamp(X_Ledger_Id       NUMBER);


END gl_budget_entities_pkg;

/
