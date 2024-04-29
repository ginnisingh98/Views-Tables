--------------------------------------------------------
--  DDL for Package GL_SUMMARY_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SUMMARY_TEMPLATES_PKG" AUTHID CURRENT_USER AS
/*  $Header: gliactps.pls 120.5 2005/07/11 05:21:59 agovil ship $ */
--
-- Package
--   GL_SUMMARY_TEMPLATES_PKG
-- Purpose
--   To implement validation unique checking and sequence id
--   generation for the GL_SUMMARY_TEMPLATES table
-- History
--   12.01.93   E. Rumanang   Created
--

  --
  -- Procedure
  --   is_funds_check_not_none
  -- Purpose
  --   Find the existence of funds_check_level_code not equals
  --   to none.  If it find one, return TRUE, else return FALSE.
  -- History
  --   12.01.93   E. Rumanang   Created
  -- Arguments
  --   x_ledger_id	Ledger id to be checked.
  -- Example
  --   GL_SUMMARY_TEMPLATES_PKG.is_funds_check_not_none( 123 );
  -- Notes
  --
  FUNCTION is_funds_check_not_none (
    x_ledger_id NUMBER ) RETURN BOOLEAN;

  --
  -- Procedure
  --  check_unique_name
  -- Purpose
  --  Ensure unicity of template name
  -- History
  --  04.27.94	S Leotin	Created
  -- Example
  --  GL_SUMMARY_TEMPLATES_PKG.check_unique_name;


PROCEDURE check_unique_name(
  	X_rowid			    VARCHAR2,
  	X_ledger_id	        NUMBER,
	X_template_name		VARCHAR2);

  --
  -- Procedure
  --  check_unique_template
  -- Purpose
  --  Ensure unicity of template
  -- History
  --  04.27.94	S Leotin	Created
  -- Example
  --  GL_SUMMARY_TEMPLATES_PKG.check_unique_template;

FUNCTION check_unique_template
  	(X_rowid            VARCHAR2,
  	X_ledger_id         NUMBER,
   	X_segment1_type		VARCHAR2,
   	X_segment2_type		VARCHAR2,
   	X_segment3_type		VARCHAR2,
   	X_segment4_type		VARCHAR2,
   	X_segment5_type		VARCHAR2,
   	X_segment6_type		VARCHAR2,
   	X_segment7_type		VARCHAR2,
   	X_segment8_type		VARCHAR2,
   	X_segment9_type		VARCHAR2,
   	X_segment10_type	VARCHAR2,
   	X_segment11_type	VARCHAR2,
   	X_segment12_type	VARCHAR2,
   	X_segment13_type	VARCHAR2,
   	X_segment14_type	VARCHAR2,
   	X_segment15_type	VARCHAR2,
   	X_segment16_type	VARCHAR2,
   	X_segment17_type	VARCHAR2,
   	X_segment18_type	VARCHAR2,
   	X_segment19_type	VARCHAR2,
   	X_segment20_type	VARCHAR2,
   	X_segment21_type	VARCHAR2,
   	X_segment22_type	VARCHAR2,
   	X_segment23_type	VARCHAR2,
   	X_segment24_type	VARCHAR2,
   	X_segment25_type	VARCHAR2,
   	X_segment26_type	VARCHAR2,
   	X_segment27_type	VARCHAR2,
   	X_segment28_type	VARCHAR2,
   	X_segment29_type	VARCHAR2,
   	X_segment30_type	VARCHAR2) RETURN BOOLEAN;

 -- Procedure
 --  get_unique_id
 -- Purpose
 --  retrieves unique id from sequence
 -- Arguments
 --   *none
 -- Example
 --  template_id := gl_summary_templates_pkg.get_unique_id;

 FUNCTION get_unique_id RETURN NUMBER;

 -- Procedure
 --  Insert_Row
 -- Purpose
 --  Insert a new row into GL_SUMMARY_TEMPLATES
 -- History
 --  01/30/02	C Ma	Created
 -- Example
 --  GL_SUMMARY_TEMPLATES_PKG.Insert_Row;
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Template_Name                       VARCHAR2,
                     X_Start_Actuals_Period_Name           VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Account_Category_Code               VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Concatenated_Description            VARCHAR2,
                     X_Max_Code_Combination_Id             NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Segment1_Type                       VARCHAR2,
                     X_Segment2_Type                       VARCHAR2,
                     X_Segment3_Type                       VARCHAR2,
                     X_Segment4_Type                       VARCHAR2,
                     X_Segment5_Type                       VARCHAR2,
                     X_Segment6_Type                       VARCHAR2,
                     X_Segment7_Type                       VARCHAR2,
                     X_Segment8_Type                       VARCHAR2,
                     X_Segment9_Type                       VARCHAR2,
                     X_Segment10_Type                      VARCHAR2,
                     X_Segment11_Type                      VARCHAR2,
                     X_Segment12_Type                      VARCHAR2,
                     X_Segment13_Type                      VARCHAR2,
                     X_Segment14_Type                      VARCHAR2,
                     X_Segment15_Type                      VARCHAR2,
                     X_Segment16_Type                      VARCHAR2,
                     X_Segment17_Type                      VARCHAR2,
                     X_Segment18_Type                      VARCHAR2,
                     X_Segment19_Type                      VARCHAR2,
                     X_Segment20_Type                      VARCHAR2,
                     X_Segment21_Type                      VARCHAR2,
                     X_Segment22_Type                      VARCHAR2,
                     X_Segment23_Type                      VARCHAR2,
                     X_Segment24_Type                      VARCHAR2,
                     X_Segment25_Type                      VARCHAR2,
                     X_Segment26_Type                      VARCHAR2,
                     X_Segment27_Type                      VARCHAR2,
                     X_Segment28_Type                      VARCHAR2,
                     X_Segment29_Type                      VARCHAR2,
                     X_Segment30_Type                      VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2
                     );

 -- Procedure
 --  Lock_Row
 -- Purpose
 --  Lock a row in GL_SUMMARY_TEMPLATES
 -- History
 --  01/30/02	C Ma	Created
 -- Example
 --  GL_SUMMARY_TEMPLATES_PKG.Lock_Row;
PROCEDURE Lock_Row(X_Rowid                               VARCHAR2,
                   X_Template_Name                       VARCHAR2,
                   X_Start_Actuals_Period_Name           VARCHAR2,
                   X_Description                         VARCHAR2,
                   X_Account_Category_Code               VARCHAR2,
                   X_Template_Id                         NUMBER,
                   X_Ledger_Id                           NUMBER,
                   X_Status                              VARCHAR2,
                   X_Last_Update_Date                    DATE,
                   X_Last_Updated_by                     NUMBER,
                   X_Concatenated_Description            VARCHAR2,
                   X_Max_Code_Combination_Id             NUMBER,
                   X_Created_By                          NUMBER,
                   X_Creation_Date                       DATE,
                   X_Last_Update_Login                   NUMBER,
                   X_Segment1_Type                       VARCHAR2,
                   X_Segment2_Type                       VARCHAR2,
                   X_Segment3_Type                       VARCHAR2,
                   X_Segment4_Type                       VARCHAR2,
                   X_Segment5_Type                       VARCHAR2,
                   X_Segment6_Type                       VARCHAR2,
                   X_Segment7_Type                       VARCHAR2,
                   X_Segment8_Type                       VARCHAR2,
                   X_Segment9_Type                       VARCHAR2,
                   X_Segment10_Type                      VARCHAR2,
                   X_Segment11_Type                      VARCHAR2,
                   X_Segment12_Type                      VARCHAR2,
                   X_Segment13_Type                      VARCHAR2,
                   X_Segment14_Type                      VARCHAR2,
                   X_Segment15_Type                      VARCHAR2,
                   X_Segment16_Type                      VARCHAR2,
                   X_Segment17_Type                      VARCHAR2,
                   X_Segment18_Type                      VARCHAR2,
                   X_Segment19_Type                      VARCHAR2,
                   X_Segment20_Type                      VARCHAR2,
                   X_Segment21_Type                      VARCHAR2,
                   X_Segment22_Type                      VARCHAR2,
                   X_Segment23_Type                      VARCHAR2,
                   X_Segment24_Type                      VARCHAR2,
                   X_Segment25_Type                      VARCHAR2,
                   X_Segment26_Type                      VARCHAR2,
                   X_Segment27_Type                      VARCHAR2,
                   X_Segment28_Type                      VARCHAR2,
                   X_Segment29_Type                      VARCHAR2,
                   X_Segment30_Type                      VARCHAR2,
                   X_Attribute1                          VARCHAR2,
                   X_Attribute2                          VARCHAR2,
                   X_Attribute3                          VARCHAR2,
                   X_Attribute4                          VARCHAR2,
                   X_Attribute5                          VARCHAR2,
                   X_Attribute6                          VARCHAR2,
                   X_Attribute7                          VARCHAR2,
                   X_Attribute8                          VARCHAR2,
                   X_Context                             VARCHAR2
                   );

 -- Procedure
 --  Update_Row
 -- Purpose
 --  Update a row in GL_SUMMARY_TEMPLATES
 -- History
 --  01/30/02	C Ma	Created
 -- Example
 --  GL_SUMMARY_TEMPLATES_PKG.Update_Row;
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Template_Name                       VARCHAR2,
                     X_Start_Actuals_Period_Name           VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Account_Category_Code               VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Status                              VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_by                     NUMBER,
                     X_Concatenated_Description            VARCHAR2,
                     X_Max_Code_Combination_Id             NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Segment1_Type                       VARCHAR2,
                     X_Segment2_Type                       VARCHAR2,
                     X_Segment3_Type                       VARCHAR2,
                     X_Segment4_Type                       VARCHAR2,
                     X_Segment5_Type                       VARCHAR2,
                     X_Segment6_Type                       VARCHAR2,
                     X_Segment7_Type                       VARCHAR2,
                     X_Segment8_Type                       VARCHAR2,
                     X_Segment9_Type                       VARCHAR2,
                     X_Segment10_Type                      VARCHAR2,
                     X_Segment11_Type                      VARCHAR2,
                     X_Segment12_Type                      VARCHAR2,
                     X_Segment13_Type                      VARCHAR2,
                     X_Segment14_Type                      VARCHAR2,
                     X_Segment15_Type                      VARCHAR2,
                     X_Segment16_Type                      VARCHAR2,
                     X_Segment17_Type                      VARCHAR2,
                     X_Segment18_Type                      VARCHAR2,
                     X_Segment19_Type                      VARCHAR2,
                     X_Segment20_Type                      VARCHAR2,
                     X_Segment21_Type                      VARCHAR2,
                     X_Segment22_Type                      VARCHAR2,
                     X_Segment23_Type                      VARCHAR2,
                     X_Segment24_Type                      VARCHAR2,
                     X_Segment25_Type                      VARCHAR2,
                     X_Segment26_Type                      VARCHAR2,
                     X_Segment27_Type                      VARCHAR2,
                     X_Segment28_Type                      VARCHAR2,
                     X_Segment29_Type                      VARCHAR2,
                     X_Segment30_Type                      VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Context                             VARCHAR2
                     );


END GL_SUMMARY_TEMPLATES_PKG;

 

/
