--------------------------------------------------------
--  DDL for Package GL_BUDGET_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUDGET_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: glubdmss.pls 120.7 2005/05/05 01:35:43 kvora ship $ */
--
-- Package
--   gl_budget_utils_pkg
-- Purpose
--   To contain various budget utilities
-- History
--   10-18-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   get_current_budget
  -- Purpose
  --   Returns the Name and ID of the current budget as well as if
  --   it required budget journals.
  -- History
  --   10-25-93  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id		Ledger id
  --   x_budget_version_id      Budget version ID of the current budget
  --   x_budget_name		Name of the current budget
  --   x_bj_required		Whether or not budget journals are required
  -- Example
  --   gl_budget_utils_pkg.get_current_budget(2, bv_id, bname, bj_required)
  -- Notes
  --
  PROCEDURE get_current_budget(
			x_ledger_id 		NUMBER,
			x_budget_version_id	IN OUT NOCOPY NUMBER,
			x_budget_name		IN OUT NOCOPY VARCHAR2,
                        x_bj_required           IN OUT NOCOPY VARCHAR2);

  --
  -- Procedure
  --   is_funding_budget
  -- Purpose
  --   Returns TRUE if the budget is being used as a funding budget, or
  --   FALSE otherwise.
  -- History
  --   10-25-93  D. J. Ogg    Created
  -- Arguments
  --   x_ledger_id			Ledger to be checked.
  --   x_funct_curr			Functional currency of SOB.
  --   budget_version_id		ID of budget to be checked.
  -- Example
  --   gl_budget_utils_pkg.is_funding_budget(2, 'USD', 1000)
  -- Notes
  --
  FUNCTION is_funding_budget(
			x_ledger_id		NUMBER,
			x_funct_curr		VARCHAR2,
			x_budget_version_id	NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   is_master_budget
  -- Purpose
  --   Returns TRUE if the budget is being used as master budget, or
  --   FALSE otherwise.
  -- History
  --   10-25-93  D. J. Ogg    Created
  -- Arguments
  --   budget_id		ID of budget to be checked.
  -- Example
  --   gl_budget_utils_pkg.is_master_budget(1000)
  -- Notes
  --
  FUNCTION is_master_budget(
			budget_id	NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   frozen_budget
  -- Purpose
  --   Returns TRUE if the budget is frozen, or
  --   FALSE otherwise.
  -- History
  --   05-05-94  D. J. Ogg    Created
  -- Arguments
  --   budget_version_id		ID of budget to be checked.
  -- Example
  --   gl_budget_utils_pkg.frozen_budget(1000)
  -- Notes
  --
  FUNCTION frozen_budget(budget_version_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   frozen_budget_entity
  -- Purpose
  --   Returns TRUE if the budget entity is frozen for a particular
  --   budget, or FALSE otherwise.
  -- History
  --   05-05-94  D. J. Ogg    Created
  -- Arguments
  --   budget_version_id		ID of budget to be checked.
  --   budget_entity_id			ID of budget entity to be checked.
  -- Example
  --   gl_budget_utils_pkg.frozen_budget_entity(1000, 999)
  -- Notes
  --
  FUNCTION frozen_budget_entity(budget_version_id NUMBER,
				budget_entity_id  NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   frozen_account
  -- Purpose
  --   Returns TRUE if the code combination is frozen for a given budget
  --   and budget entity, or FALSE otherwise.
  -- History
  --   05-05-94  D. J. Ogg    Created
  -- Arguments
  --   coa_id				Chart of Accounts ID
  --   budget_version_id		ID of budget to be checked.
  --   budget_entity_id			ID of budget entity to be checked.
  --   code_combination_id		ID of code combination to be checked.
  -- Example
  --   gl_budget_utils_pkg.frozen_account(1000, 999, 2343)
  -- Notes
  --
  FUNCTION frozen_account(coa_id	      NUMBER,
			  budget_version_id   NUMBER,
		          budget_entity_id    NUMBER,
		          code_combination_id NUMBER,
                          ledger_id           NUMBER,
                          currency_code       VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   validate_budget_account
  -- Purpose
  --   Returns 'A' if the account is not assigned to a budget
  --   organization with the given currency, 'O' if the
  --   budget organization is frozen, 'F' if the account is frozen,
  --   and 'Z' if none of the above is true
  -- History
  --   05-06-94  D. J. Ogg    Created
  -- Arguments
  --   lgr_id				Ledger Id
  --   coa_id				Chart of Accounts ID
  --   budget_version_id		ID of budget to be examined
  --   code_combination_id		ID of code combination to be checked.
  --   currency_code			ID of currency of the assignment
  --   return_code			The returned value
  --   budget_entity_id			ID of budget organization that
  --				        the code combination is assigned to
  --   					for the given currency
  --   budget_entity			The name of the above organization
  --   password_flag			A flag indicating whether or not
  --					the above organization requires a
  --					password.
  --   encrypted_password		The encrypted password of the
  --					above organization
  --   status_code			The status of the budget organization
  -- Example
  --   gl_budget_utils_pkg.validate_budget_account(100, 999, 2343, 'USD',
  --						   rcode, beid, bename,
  --						   pwdflag, encpwd, xstatus);
  -- Notes
  --
  PROCEDURE validate_budget_account(lgr_id	                 NUMBER,
				    coa_id	                 NUMBER,
			            budget_version_id            NUMBER,
 		                    code_combination_id          NUMBER,
                                    currency_code                VARCHAR2,
				    return_code		 IN OUT NOCOPY  VARCHAR2,
                                    budget_entity_id      IN OUT NOCOPY NUMBER,
				    budget_entity         IN OUT NOCOPY VARCHAR2,
				    password_flag         IN OUT NOCOPY VARCHAR2,
				    encrypted_password    IN OUT NOCOPY VARCHAR2,
				    status_code 	  IN OUT NOCOPY VARCHAR2);


  -- Procedure
  --  get_unique_id
  -- Purpose
  --  retrieves the unique range id from sequence gl_budget_frozen_ranges_s
  -- Arguments
  --  none
  -- Example
  --  range_id := gl_budget_utils_pkg.get_unique_id;

  FUNCTION get_unique_id RETURN number;

  -- Function
  --   get_opyr_per_range
  -- Purpose
  --   Return the first period year, name and num; and the last period year,
  --   name and num in the open fiscal year(s).
  -- Arguments
  --   budget_version_id		ID of budget to be examined
  -- Example
  --   get_opyr_per_range (999, start_per_year, start_per_name, start_per_num,
  --				end_per_year, end_per_name, end_per_num);
  --
  -- Notes
  --
  FUNCTION get_opyr_per_range ( x_budget_version_id  	IN NUMBER,
				x_start_period_year	IN OUT NOCOPY NUMBER,
				x_start_period_name	IN OUT NOCOPY VARCHAR2,
				x_start_period_num	IN OUT NOCOPY NUMBER,
				x_end_period_year	IN OUT NOCOPY NUMBER,
				x_end_period_name	IN OUT NOCOPY VARCHAR2,
				x_end_period_num	IN OUT NOCOPY NUMBER)
							RETURN BOOLEAN;

  -- Procedure
  --  validate_budget
  -- Purpose
  --  validate attributes Require_Budget_Journals_Flag,
  --                      First_Valid_Period_Name, and
  --                      Last_Valid_Period_Name.
  --  raise exceptions if validation fails
  --

  PROCEDURE validate_budget(
                     X_Rowid                           IN OUT NOCOPY VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_Ledger_Id                       NUMBER,
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
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL);

END gl_budget_utils_pkg;

 

/
