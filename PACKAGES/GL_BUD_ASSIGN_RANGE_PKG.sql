--------------------------------------------------------
--  DDL for Package GL_BUD_ASSIGN_RANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_BUD_ASSIGN_RANGE_PKG" AUTHID CURRENT_USER AS
/*  $Header: glibdars.pls 120.8.12010000.1 2008/07/28 13:23:08 appldev ship $ */
--
-- Package
--   gl_bud_assign_range_pkg
-- Purpose
--   To create GL_BUD_ASSIGN_RANGE_PKG package.
-- History
--   12.01.93   E. Rumanang   Created
--

  --
  -- Procedure
  --   is_funds_check_not_none
  -- Purpose
  --   Find the existence of funds_check_level_code not equals
  --   to none.  Return true if it found, or else return false.
  -- History
  --   12.01.93   E. Rumanang   Created
  -- Arguments
  --   x_set_of_books_id	Set of books id to be checked.
  -- Example
  --   gl_bud_assign_range_pkg.is_funds_check_not_none( 123 );
  -- Notes
  --
  FUNCTION is_funds_check_not_none(
    x_ledger_id NUMBER )  RETURN BOOLEAN;

  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the sequence number of the assignment range
  --   is unique within that organization.
  -- History
  --   12-03-93  D. J. Ogg    Created
  -- Arguments
  --   org_id		The ID of the budget organization
  --   seq_num		The sequence number
  --   row_id		The current rowid
  -- Example
  --   gl_bud_assign_range_pkg.check_unique(100, 10, 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(org_id NUMBER, seq_num NUMBER,
			 row_id VARCHAR2);

  --
  -- Procedure
  --   lock_range
  -- Purpose
  --   Locks the row with the given range_id
  -- History
  --   12-16-93  D. J. Ogg    Created
  -- Arguments
  --   range_id		The row to lock
  -- Example
  --   gl_bud_assign_range_pkg.lock_range(1000);
  -- Notes
  --
  PROCEDURE lock_range(x_range_id NUMBER);

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Budget_Entity_Id                     NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Currency_Code                        VARCHAR2,
                     X_Entry_Code                           VARCHAR2,
                     X_Range_Id                      IN OUT NOCOPY NUMBER,
                     X_Status                               VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Sequence_Number                      NUMBER,
                     X_Segment1_Low                         VARCHAR2,
                     X_Segment1_High                        VARCHAR2,
                     X_Segment2_Low                         VARCHAR2,
                     X_Segment2_High                        VARCHAR2,
                     X_Segment3_Low                         VARCHAR2,
                     X_Segment3_High                        VARCHAR2,
                     X_Segment4_Low                         VARCHAR2,
                     X_Segment4_High                        VARCHAR2,
                     X_Segment5_Low                         VARCHAR2,
                     X_Segment5_High                        VARCHAR2,
                     X_Segment6_Low                         VARCHAR2,
                     X_Segment6_High                        VARCHAR2,
                     X_Segment7_Low                         VARCHAR2,
                     X_Segment7_High                        VARCHAR2,
                     X_Segment8_Low                         VARCHAR2,
                     X_Segment8_High                        VARCHAR2,
                     X_Segment9_Low                         VARCHAR2,
                     X_Segment9_High                        VARCHAR2,
                     X_Segment10_Low                        VARCHAR2,
                     X_Segment10_High                       VARCHAR2,
                     X_Segment11_Low                        VARCHAR2,
                     X_Segment11_High                       VARCHAR2,
                     X_Segment12_Low                        VARCHAR2,
                     X_Segment12_High                       VARCHAR2,
                     X_Segment13_Low                        VARCHAR2,
                     X_Segment13_High                       VARCHAR2,
                     X_Segment14_Low                        VARCHAR2,
                     X_Segment14_High                       VARCHAR2,
                     X_Segment15_Low                        VARCHAR2,
                     X_Segment15_High                       VARCHAR2,
                     X_Segment16_Low                        VARCHAR2,
                     X_Segment16_High                       VARCHAR2,
                     X_Segment17_Low                        VARCHAR2,
                     X_Segment17_High                       VARCHAR2,
                     X_Segment18_Low                        VARCHAR2,
                     X_Segment18_High                       VARCHAR2,
                     X_Segment19_Low                        VARCHAR2,
                     X_Segment19_High                       VARCHAR2,
                     X_Segment20_Low                        VARCHAR2,
                     X_Segment20_High                       VARCHAR2,
                     X_Segment21_Low                        VARCHAR2,
                     X_Segment21_High                       VARCHAR2,
                     X_Segment22_Low                        VARCHAR2,
                     X_Segment22_High                       VARCHAR2,
                     X_Segment23_Low                        VARCHAR2,
                     X_Segment23_High                       VARCHAR2,
                     X_Segment24_Low                        VARCHAR2,
                     X_Segment24_High                       VARCHAR2,
                     X_Segment25_Low                        VARCHAR2,
                     X_Segment25_High                       VARCHAR2,
                     X_Segment26_Low                        VARCHAR2,
                     X_Segment26_High                       VARCHAR2,
                     X_Segment27_Low                        VARCHAR2,
                     X_Segment27_High                       VARCHAR2,
                     X_Segment28_Low                        VARCHAR2,
                     X_Segment28_High                       VARCHAR2,
                     X_Segment29_Low                        VARCHAR2,
                     X_Segment29_High                       VARCHAR2,
                     X_Segment30_Low                        VARCHAR2,
                     X_Segment30_High                       VARCHAR2,
                     X_Context                              VARCHAR2,
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
		     X_Chart_Of_Accounts_Id		    NUMBER
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Budget_Entity_Id                       NUMBER,
                   X_Ledger_Id                              NUMBER,
                   X_Currency_Code                          VARCHAR2,
                   X_Entry_Code                             VARCHAR2,
                   X_Range_Id                               NUMBER,
                   X_Status                                 VARCHAR2,
                   X_Sequence_Number                        NUMBER,
                   X_Segment1_Low                           VARCHAR2,
                   X_Segment1_High                          VARCHAR2,
                   X_Segment2_Low                           VARCHAR2,
                   X_Segment2_High                          VARCHAR2,
                   X_Segment3_Low                           VARCHAR2,
                   X_Segment3_High                          VARCHAR2,
                   X_Segment4_Low                           VARCHAR2,
                   X_Segment4_High                          VARCHAR2,
                   X_Segment5_Low                           VARCHAR2,
                   X_Segment5_High                          VARCHAR2,
                   X_Segment6_Low                           VARCHAR2,
                   X_Segment6_High                          VARCHAR2,
                   X_Segment7_Low                           VARCHAR2,
                   X_Segment7_High                          VARCHAR2,
                   X_Segment8_Low                           VARCHAR2,
                   X_Segment8_High                          VARCHAR2,
                   X_Segment9_Low                           VARCHAR2,
                   X_Segment9_High                          VARCHAR2,
                   X_Segment10_Low                          VARCHAR2,
                   X_Segment10_High                         VARCHAR2,
                   X_Segment11_Low                          VARCHAR2,
                   X_Segment11_High                         VARCHAR2,
                   X_Segment12_Low                          VARCHAR2,
                   X_Segment12_High                         VARCHAR2,
                   X_Segment13_Low                          VARCHAR2,
                   X_Segment13_High                         VARCHAR2,
                   X_Segment14_Low                          VARCHAR2,
                   X_Segment14_High                         VARCHAR2,
                   X_Segment15_Low                          VARCHAR2,
                   X_Segment15_High                         VARCHAR2,
                   X_Segment16_Low                          VARCHAR2,
                   X_Segment16_High                         VARCHAR2,
                   X_Segment17_Low                          VARCHAR2,
                   X_Segment17_High                         VARCHAR2,
                   X_Segment18_Low                          VARCHAR2,
                   X_Segment18_High                         VARCHAR2,
                   X_Segment19_Low                          VARCHAR2,
                   X_Segment19_High                         VARCHAR2,
                   X_Segment20_Low                          VARCHAR2,
                   X_Segment20_High                         VARCHAR2,
                   X_Segment21_Low                          VARCHAR2,
                   X_Segment21_High                         VARCHAR2,
                   X_Segment22_Low                          VARCHAR2,
                   X_Segment22_High                         VARCHAR2,
                   X_Segment23_Low                          VARCHAR2,
                   X_Segment23_High                         VARCHAR2,
                   X_Segment24_Low                          VARCHAR2,
                   X_Segment24_High                         VARCHAR2,
                   X_Segment25_Low                          VARCHAR2,
                   X_Segment25_High                         VARCHAR2,
                   X_Segment26_Low                          VARCHAR2,
                   X_Segment26_High                         VARCHAR2,
                   X_Segment27_Low                          VARCHAR2,
                   X_Segment27_High                         VARCHAR2,
                   X_Segment28_Low                          VARCHAR2,
                   X_Segment28_High                         VARCHAR2,
                   X_Segment29_Low                          VARCHAR2,
                   X_Segment29_High                         VARCHAR2,
                   X_Segment30_Low                          VARCHAR2,
                   X_Segment30_High                         VARCHAR2,
                   X_Context                                VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
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
                   X_Attribute15                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Entry_Code                          VARCHAR2,
                     X_Range_Id                            NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Sequence_Number                     NUMBER,
                     X_Segment1_Low                        VARCHAR2,
                     X_Segment1_High                       VARCHAR2,
                     X_Segment2_Low                        VARCHAR2,
                     X_Segment2_High                       VARCHAR2,
                     X_Segment3_Low                        VARCHAR2,
                     X_Segment3_High                       VARCHAR2,
                     X_Segment4_Low                        VARCHAR2,
                     X_Segment4_High                       VARCHAR2,
                     X_Segment5_Low                        VARCHAR2,
                     X_Segment5_High                       VARCHAR2,
                     X_Segment6_Low                        VARCHAR2,
                     X_Segment6_High                       VARCHAR2,
                     X_Segment7_Low                        VARCHAR2,
                     X_Segment7_High                       VARCHAR2,
                     X_Segment8_Low                        VARCHAR2,
                     X_Segment8_High                       VARCHAR2,
                     X_Segment9_Low                        VARCHAR2,
                     X_Segment9_High                       VARCHAR2,
                     X_Segment10_Low                       VARCHAR2,
                     X_Segment10_High                      VARCHAR2,
                     X_Segment11_Low                       VARCHAR2,
                     X_Segment11_High                      VARCHAR2,
                     X_Segment12_Low                       VARCHAR2,
                     X_Segment12_High                      VARCHAR2,
                     X_Segment13_Low                       VARCHAR2,
                     X_Segment13_High                      VARCHAR2,
                     X_Segment14_Low                       VARCHAR2,
                     X_Segment14_High                      VARCHAR2,
                     X_Segment15_Low                       VARCHAR2,
                     X_Segment15_High                      VARCHAR2,
                     X_Segment16_Low                       VARCHAR2,
                     X_Segment16_High                      VARCHAR2,
                     X_Segment17_Low                       VARCHAR2,
                     X_Segment17_High                      VARCHAR2,
                     X_Segment18_Low                       VARCHAR2,
                     X_Segment18_High                      VARCHAR2,
                     X_Segment19_Low                       VARCHAR2,
                     X_Segment19_High                      VARCHAR2,
                     X_Segment20_Low                       VARCHAR2,
                     X_Segment20_High                      VARCHAR2,
                     X_Segment21_Low                       VARCHAR2,
                     X_Segment21_High                      VARCHAR2,
                     X_Segment22_Low                       VARCHAR2,
                     X_Segment22_High                      VARCHAR2,
                     X_Segment23_Low                       VARCHAR2,
                     X_Segment23_High                      VARCHAR2,
                     X_Segment24_Low                       VARCHAR2,
                     X_Segment24_High                      VARCHAR2,
                     X_Segment25_Low                       VARCHAR2,
                     X_Segment25_High                      VARCHAR2,
                     X_Segment26_Low                       VARCHAR2,
                     X_Segment26_High                      VARCHAR2,
                     X_Segment27_Low                       VARCHAR2,
                     X_Segment27_High                      VARCHAR2,
                     X_Segment28_Low                       VARCHAR2,
                     X_Segment28_High                      VARCHAR2,
                     X_Segment29_Low                       VARCHAR2,
                     X_Segment29_High                      VARCHAR2,
                     X_Segment30_Low                       VARCHAR2,
                     X_Segment30_High                      VARCHAR2,
                     X_Context                             VARCHAR2,
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
                     X_Attribute15                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Range_Id NUMBER, X_Rowid VARCHAR2);

  --
  -- Procedure
  --   Insert_Range
  -- Purpose
  --   Inserts row into GL_BUDGET_ASSIGNMENT_RANGES.
  --   Called by an iSpeed API.
  -- History
  --   11-07-00  K Vora       Created
  --
PROCEDURE Insert_Range(
                     X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Budget_Entity_Id                     NUMBER,
                     X_Ledger_Id                            NUMBER,
                     X_Currency_Code                        VARCHAR2,
                     X_Entry_Code                           VARCHAR2,
                     X_Range_Id                             NUMBER,
                     X_Status                               VARCHAR2,
                     X_Last_Update_Date                     DATE,
                     X_Created_By                           NUMBER,
                     X_Creation_Date                        DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Sequence_Number                      NUMBER,
                     X_Segment1_Low                         VARCHAR2,
                     X_Segment1_High                        VARCHAR2,
                     X_Segment2_Low                         VARCHAR2,
                     X_Segment2_High                        VARCHAR2,
                     X_Segment3_Low                         VARCHAR2,
                     X_Segment3_High                        VARCHAR2,
                     X_Segment4_Low                         VARCHAR2,
                     X_Segment4_High                        VARCHAR2,
                     X_Segment5_Low                         VARCHAR2,
                     X_Segment5_High                        VARCHAR2,
                     X_Segment6_Low                         VARCHAR2,
                     X_Segment6_High                        VARCHAR2,
                     X_Segment7_Low                         VARCHAR2,
                     X_Segment7_High                        VARCHAR2,
                     X_Segment8_Low                         VARCHAR2,
                     X_Segment8_High                        VARCHAR2,
                     X_Segment9_Low                         VARCHAR2,
                     X_Segment9_High                        VARCHAR2,
                     X_Segment10_Low                        VARCHAR2,
                     X_Segment10_High                       VARCHAR2,
                     X_Segment11_Low                        VARCHAR2,
                     X_Segment11_High                       VARCHAR2,
                     X_Segment12_Low                        VARCHAR2,
                     X_Segment12_High                       VARCHAR2,
                     X_Segment13_Low                        VARCHAR2,
                     X_Segment13_High                       VARCHAR2,
                     X_Segment14_Low                        VARCHAR2,
                     X_Segment14_High                       VARCHAR2,
                     X_Segment15_Low                        VARCHAR2,
                     X_Segment15_High                       VARCHAR2,
                     X_Segment16_Low                        VARCHAR2,
                     X_Segment16_High                       VARCHAR2,
                     X_Segment17_Low                        VARCHAR2,
                     X_Segment17_High                       VARCHAR2,
                     X_Segment18_Low                        VARCHAR2,
                     X_Segment18_High                       VARCHAR2,
                     X_Segment19_Low                        VARCHAR2,
                     X_Segment19_High                       VARCHAR2,
                     X_Segment20_Low                        VARCHAR2,
                     X_Segment20_High                       VARCHAR2,
                     X_Segment21_Low                        VARCHAR2,
                     X_Segment21_High                       VARCHAR2,
                     X_Segment22_Low                        VARCHAR2,
                     X_Segment22_High                       VARCHAR2,
                     X_Segment23_Low                        VARCHAR2,
                     X_Segment23_High                       VARCHAR2,
                     X_Segment24_Low                        VARCHAR2,
                     X_Segment24_High                       VARCHAR2,
                     X_Segment25_Low                        VARCHAR2,
                     X_Segment25_High                       VARCHAR2,
                     X_Segment26_Low                        VARCHAR2,
                     X_Segment26_High                       VARCHAR2,
                     X_Segment27_Low                        VARCHAR2,
                     X_Segment27_High                       VARCHAR2,
                     X_Segment28_Low                        VARCHAR2,
                     X_Segment28_High                       VARCHAR2,
                     X_Segment29_Low                        VARCHAR2,
                     X_Segment29_High                       VARCHAR2,
                     X_Segment30_Low                        VARCHAR2,
                     X_Segment30_High                       VARCHAR2,
                     X_Context                              VARCHAR2,
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
                     X_Attribute15                          VARCHAR2
                     );

END gl_bud_assign_range_pkg;

/
