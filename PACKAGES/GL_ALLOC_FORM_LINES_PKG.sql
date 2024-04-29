--------------------------------------------------------
--  DDL for Package GL_ALLOC_FORM_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ALLOC_FORM_LINES_PKG" AUTHID CURRENT_USER AS
/* $Header: glimafls.pls 120.5 2003/07/03 01:43:20 ticheng ship $ */
--
-- Package
--   gl_alloc_formula_lines_pkg
-- Purpose
--   To contain validation and insertion routines for gl_alloc_formula_lines
-- History
--   11-11-93  	D. J. Ogg	Created

  --
  -- Procedure
  --   complete_formula
  -- Purpose
  --   Checks to make sure that the formula contains all necessary lines.
  -- History
  --   11-12-93  D. J. Ogg    Created
  -- Arguments
  --   formula_id 	The ID of the formula
  --   actual_flag	The balance type of the formula
  -- Example
  --   gl_alloc_form_lines_pkg.complete_formula(123, 'A');
  -- Notes
  --
  FUNCTION complete_formula(formula_id  NUMBER,
                            actual_flag VARCHAR2) RETURN BOOLEAN;

  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Deletes all of the lines in a formula
  -- History
  --   09-JUN-94  D. J. Ogg    Created
  -- Arguments
  --   formula_id	The ID of the formula to delete
  -- Example
  --   gl_alloc_form_lines_pkg.delete_rows(5);
  -- Notes
  --
  PROCEDURE delete_rows(formula_id NUMBER);

  --
  -- Procedure
  --   delete_batch
  -- Purpose
  --   Deletes all of the lines in a batch
  -- History
  --   09-JUN-94  D. J. Ogg    Created
  -- Arguments
  --   formula_id	The ID of the batch to delete
  -- Example
  --   gl_alloc_form_lines_pkg.delete_batch(5);
  -- Notes
  --
  PROCEDURE delete_batch(batch_id NUMBER);

  -- Procedure
  --   validate_ledger_action
  -- Purpose
  --   Make sure that the action code is Constant for a ledger, and
  --   Looping (default) or Summing for a ledger set.
  -- History
  --   04-APR-02  T Cheng	Created
  -- Arguments
  --   x_object_type_code	The object type of the ledger selected
  --   x_segment_types_key_full The first element of it is the ledger action
  -- Example
  --   gl_alloc_form_lines_pkg.validate_ledger_action('L', 'C-C-L-C');
  -- Notes
  --
  PROCEDURE validate_ledger_action(x_object_type_code	      VARCHAR2,
                                   x_segment_types_key_full   VARCHAR2);

  --
  -- Procedure
  --   check_target_ledger
  -- Purpose
  --   For MassBudget and MassEncumbrance: if the transaction currency has
  --   changed, use this procedure to check target/offset line ledger.
  -- History
  --   24-MAR-03  T Cheng	Created
  -- Arguments
  --   x_allocation_formula_id	The allocation formula id
  -- Example
  --   gl_alloc_form_lines_pkg.check_target_ledger(1234);
  -- Notes
  --
  PROCEDURE check_target_ledger(x_allocation_formula_id NUMBER);

  --
  -- Procedure
  --   check_target_ledger_currency
  -- Purpose
  --   Called when balance type is Budget or Encumbrance. Check if the primary
  --   currency of the ledger or common primary currency of the ledger set
  --   is the same as the selected ledger currency.
  -- History
  --   18-APR-02  T Cheng	Created
  -- Arguments
  --   x_ledger_id		The ledger id. Can be a ledger or a ledger set.
  --   x_ledger_currency	The selected ledger currency
  -- Example
  --   gl_alloc_form_lines_pkg.check_target_ledger_currency(10, 'USD', 'E');
  -- Notes
  --   Also called by the form directly.
  --
  PROCEDURE check_target_ledger_currency(x_ledger_id NUMBER,
                                         x_ledger_currency VARCHAR2,
                                         x_actual_flag VARCHAR2);

  --
  -- Procedure
  --   update_currency
  -- Purpose
  --   Updates the currency and transaction currency of all of the
  --   lines in a formula.
  -- History
  --   16-JUN-94  D. J. Ogg    Created
  -- Arguments
  --   formula_id		The ID of the formula to update
  --   transaction_currency 	The new transaction currency
  --   conversion_method	The conversion method
  -- Example
  --   gl_alloc_form_lines_pkg.update_currency(5, 'USD', 'CA');
  -- Notes
  --
  PROCEDURE update_currency(formula_id 		 NUMBER,
			    transaction_currency VARCHAR2,
			    conversion_method 	 VARCHAR2);

  --
  -- Procedure
  --   currency_changed
  -- Purpose
  --   Returns TRUE if the formula currency differs from the
  --   currency provided.  Returns FALSE otherwise.
  -- History
  --   17-JUN-94  D. J. Ogg    Created
  -- Arguments
  --   formula_id		The ID of the formula to check
  --   transaction_currency 	The transaction currency to verify against
  -- Example
  --   IF(gl_alloc_form_lines_pkg.currency_changed(5, 'CND')) THEN
  -- Notes
  --
  FUNCTION currency_changed(formula_id    	   NUMBER,
			    transaction_currency  VARCHAR2) RETURN BOOLEAN;

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Allocation_Formula_Id         IN OUT NOCOPY NUMBER,
                     X_Line_Number                          NUMBER,
                     X_Line_Type                            VARCHAR2,
                     X_Operator                             VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Amount                               NUMBER,
                     X_Relative_Period                      VARCHAR2,
                     X_Period_Name                          VARCHAR2,
                     X_Transaction_Currency                 VARCHAR2,
                     X_Ledger_Currency                      VARCHAR2,
                     X_Currency_Type                        VARCHAR2,
                     X_Entered_Currency                     VARCHAR2,
                     X_Actual_Flag                          VARCHAR2,
                     X_Budget_Version_Id                    NUMBER,
                     X_Encumbrance_Type_Id                  NUMBER,
                     X_Amount_Type                          VARCHAR2,
                     X_Ledger_Id                            NUMBER,
                     X_Segment_Types_Key_Full               VARCHAR2,
                     X_Segment_Break_Key                    VARCHAR2,
                     X_Segment1                             VARCHAR2,
                     X_Segment2                             VARCHAR2,
                     X_Segment3                             VARCHAR2,
                     X_Segment4                             VARCHAR2,
                     X_Segment5                             VARCHAR2,
                     X_Segment6                             VARCHAR2,
                     X_Segment7                             VARCHAR2,
                     X_Segment8                             VARCHAR2,
                     X_Segment9                             VARCHAR2,
                     X_Segment10                            VARCHAR2,
                     X_Segment11                            VARCHAR2,
                     X_Segment12                            VARCHAR2,
                     X_Segment13                            VARCHAR2,
                     X_Segment14                            VARCHAR2,
                     X_Segment15                            VARCHAR2,
                     X_Segment16                            VARCHAR2,
                     X_Segment17                            VARCHAR2,
                     X_Segment18                            VARCHAR2,
                     X_Segment19                            VARCHAR2,
                     X_Segment20                            VARCHAR2,
                     X_Segment21                            VARCHAR2,
                     X_Segment22                            VARCHAR2,
                     X_Segment23                            VARCHAR2,
                     X_Segment24                            VARCHAR2,
                     X_Segment25                            VARCHAR2,
                     X_Segment26                            VARCHAR2,
                     X_Segment27                            VARCHAR2,
                     X_Segment28                            VARCHAR2,
                     X_Segment29                            VARCHAR2,
                     X_Segment30                            VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Allocation_Formula_Id                  NUMBER,
                   X_Line_Number                            NUMBER,
                   X_Line_Type                              VARCHAR2,
                   X_Operator                               VARCHAR2,
                   X_Amount                                 NUMBER,
                   X_Relative_Period                        VARCHAR2,
                   X_Period_Name                            VARCHAR2,
                   X_Transaction_Currency                   VARCHAR2,
                   X_Ledger_Currency                        VARCHAR2,
                   X_Currency_Type                          VARCHAR2,
                   X_Entered_Currency                       VARCHAR2,
                   X_Actual_Flag                            VARCHAR2,
                   X_Budget_Version_Id                      NUMBER,
                   X_Encumbrance_Type_Id                    NUMBER,
                   X_Amount_Type                            VARCHAR2,
                   X_Ledger_Id                              NUMBER,
                   X_Segment_Types_Key_Full                 VARCHAR2,
                   X_Segment_Break_Key                      VARCHAR2,
                   X_Segment1                               VARCHAR2,
                   X_Segment2                               VARCHAR2,
                   X_Segment3                               VARCHAR2,
                   X_Segment4                               VARCHAR2,
                   X_Segment5                               VARCHAR2,
                   X_Segment6                               VARCHAR2,
                   X_Segment7                               VARCHAR2,
                   X_Segment8                               VARCHAR2,
                   X_Segment9                               VARCHAR2,
                   X_Segment10                              VARCHAR2,
                   X_Segment11                              VARCHAR2,
                   X_Segment12                              VARCHAR2,
                   X_Segment13                              VARCHAR2,
                   X_Segment14                              VARCHAR2,
                   X_Segment15                              VARCHAR2,
                   X_Segment16                              VARCHAR2,
                   X_Segment17                              VARCHAR2,
                   X_Segment18                              VARCHAR2,
                   X_Segment19                              VARCHAR2,
                   X_Segment20                              VARCHAR2,
                   X_Segment21                              VARCHAR2,
                   X_Segment22                              VARCHAR2,
                   X_Segment23                              VARCHAR2,
                   X_Segment24                              VARCHAR2,
                   X_Segment25                              VARCHAR2,
                   X_Segment26                              VARCHAR2,
                   X_Segment27                              VARCHAR2,
                   X_Segment28                              VARCHAR2,
                   X_Segment29                              VARCHAR2,
                   X_Segment30                              VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Allocation_Formula_Id               NUMBER,
                     X_Line_Number                         NUMBER,
                     X_Line_Type                           VARCHAR2,
                     X_Operator                            VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Amount                              NUMBER,
                     X_Relative_Period                     VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Transaction_Currency                VARCHAR2,
                     X_Ledger_Currency                     VARCHAR2,
                     X_Currency_Type                       VARCHAR2,
                     X_Entered_Currency                    VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Amount_Type                         VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Segment_Types_Key_Full              VARCHAR2,
                     X_Segment_Break_Key                   VARCHAR2,
                     X_Segment1                            VARCHAR2,
                     X_Segment2                            VARCHAR2,
                     X_Segment3                            VARCHAR2,
                     X_Segment4                            VARCHAR2,
                     X_Segment5                            VARCHAR2,
                     X_Segment6                            VARCHAR2,
                     X_Segment7                            VARCHAR2,
                     X_Segment8                            VARCHAR2,
                     X_Segment9                            VARCHAR2,
                     X_Segment10                           VARCHAR2,
                     X_Segment11                           VARCHAR2,
                     X_Segment12                           VARCHAR2,
                     X_Segment13                           VARCHAR2,
                     X_Segment14                           VARCHAR2,
                     X_Segment15                           VARCHAR2,
                     X_Segment16                           VARCHAR2,
                     X_Segment17                           VARCHAR2,
                     X_Segment18                           VARCHAR2,
                     X_Segment19                           VARCHAR2,
                     X_Segment20                           VARCHAR2,
                     X_Segment21                           VARCHAR2,
                     X_Segment22                           VARCHAR2,
                     X_Segment23                           VARCHAR2,
                     X_Segment24                           VARCHAR2,
                     X_Segment25                           VARCHAR2,
                     X_Segment26                           VARCHAR2,
                     X_Segment27                           VARCHAR2,
                     X_Segment28                           VARCHAR2,
                     X_Segment29                           VARCHAR2,
                     X_Segment30                           VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END GL_ALLOC_FORM_LINES_PKG;

 

/
