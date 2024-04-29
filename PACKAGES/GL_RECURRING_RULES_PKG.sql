--------------------------------------------------------
--  DDL for Package GL_RECURRING_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_RECURRING_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: glirecrs.pls 120.5 2005/05/05 01:20:32 kvora ship $ */
--
-- Package
--   GL_RECURRING_RULES_PKG
-- Purpose
--   To group all the procedures/functions for GL_RECURRING_RULES_PKG.
-- History
--   25-FEB-1994  ERumanan  Created.
--


  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Ensure new recurring formula step number is unique.
  -- History
  --   25-FEB-1994  ERumanan  Created.
  -- Arguments
  --   x_rowid    	The ID of the row to be checked
  --   x_rule_num	The recurring formula step number to be checked
  --   x_line_num	The recurring line number to be checked
  --   x_header_id	The recurring header id to be checked
  -- Example
  --   GL_RECURRING_RULES_PKG.check_unique( '12345', 1, 1, 123 );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid      VARCHAR2,
                          x_rule_num   NUMBER,
                          x_line_num   NUMBER,
                          x_header_id  NUMBER );

  --
  -- Procedure
  --   update_line_num
  -- Purpose
  --   Update line number of the corresponding rows.
  -- History
  --   15-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_new_line_num   The new line number
  --   x_line_num       The old line number to be replaced
  --   x_header_id      The recurring header id
  -- Example
  --   GL_RECURRING_RULES_PKG.update_line_num( 10, 9, 123 );
  -- Notes
  --
  PROCEDURE update_line_num( x_new_line_num  NUMBER,
                             x_old_line_num  NUMBER,
                             x_header_id     NUMBER );

--***************************************************************
  --
  -- Procedure
  --   get_ccid
  -- Purpose
  --   Get the code combination id of the account flexfield
  -- History
  --   30-MAY-2000  KChang  Created.
  -- Arguments
  --   x_ccid          The code combination id
  --   x_ledger_id        The ledger id
  --   x_templgrid     The ledger id of the summary template. If
  --                   not found, default to the current ledger id
  --   x_coa_id        The chart of accounts id
  --   x_segment1...30 The segment values
  -- Example
  --   GL_RECURRING_RULES_PKG.get_ccid(... );
  -- Notes
  --
  Function get_ccid( X_LEDGER_ID                         NUMBER,
                       X_COA_ID			        NUMBER,
                       X_CONC_SEG                       VARCHAR2,
                       X_ERR_MSG                   OUT NOCOPY  VARCHAR2,
                       X_CCID                      OUT NOCOPY  NUMBER,
                       X_TempLgrId                 OUT NOCOPY  NUMBER,
                       X_Acct_Type                 OUT NOCOPY  VARCHAR2,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2 )
                       RETURN BOOLEAN;

--*********************************************************

  --
  -- Procedure
  --   delete_rows
  -- Purpose
  --   Delete rows for all the detail blocks.
  -- History
  --   20-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_header_id  The recurring header id.
  --   x_line_num   The recurring line number.
  -- Example
  --   GL_RECURRING_RULES_PKG.delete_rows( 10, 1 );
  -- Notes
  --
  PROCEDURE delete_rows( x_header_id    NUMBER,
                         x_line_num     NUMBER );


--*****************************************


  PROCEDURE Insert_Row(X_Rowid            IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Rule_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Operator                       VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Amount                         NUMBER,
                       X_Amount_Type	                VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_Ledger_Currency                VARCHAR2,
                       X_Currency_Type                  VARCHAR2,
                       X_Entered_Currency               VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Relative_Period_Code           VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Assigned_Code_Combination      NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2
                      );

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,

                     X_Recurring_Header_Id              NUMBER,
                     X_Recurring_Line_Num               NUMBER,
                     X_Rule_Num                         NUMBER,
                     X_Operator                         VARCHAR2,
                     X_Amount                           NUMBER,
                     X_Amount_Type                      VARCHAR2,
                     X_Actual_Flag                      VARCHAR2,
                     X_Ledger_Currency                  VARCHAR2,
                     X_Currency_Type                    VARCHAR2,
                     X_Entered_Currency                 VARCHAR2,
                     X_Ledger_Id                        NUMBER,
                     X_Relative_Period_Code             VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Assigned_Code_Combination        NUMBER,
                     X_Template_Id                      NUMBER,
                     X_Segment1                         VARCHAR2,
                     X_Segment2                         VARCHAR2,
                     X_Segment3                         VARCHAR2,
                     X_Segment4                         VARCHAR2,
                     X_Segment5                         VARCHAR2,
                     X_Segment6                         VARCHAR2,
                     X_Segment7                         VARCHAR2,
                     X_Segment8                         VARCHAR2,
                     X_Segment9                         VARCHAR2,
                     X_Segment10                        VARCHAR2,
                     X_Segment11                        VARCHAR2,
                     X_Segment12                        VARCHAR2,
                     X_Segment13                        VARCHAR2,
                     X_Segment14                        VARCHAR2,
                     X_Segment15                        VARCHAR2,
                     X_Segment16                        VARCHAR2,
                     X_Segment17                        VARCHAR2,
                     X_Segment18                        VARCHAR2,
                     X_Segment19                        VARCHAR2,
                     X_Segment20                        VARCHAR2,
                     X_Segment21                        VARCHAR2,
                     X_Segment22                        VARCHAR2,
                     X_Segment23                        VARCHAR2,
                     X_Segment24                        VARCHAR2,
                     X_Segment25                        VARCHAR2,
                     X_Segment26                        VARCHAR2,
                     X_Segment27                        VARCHAR2,
                     X_Segment28                        VARCHAR2,
                     X_Segment29                        VARCHAR2,
                     X_Segment30                        VARCHAR2
                    );



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,

                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Rule_Num                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Operator                       VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Amount                         NUMBER,
                       X_Amount_Type                    VARCHAR2,
                       X_Actual_Flag                    VARCHAR2,
                       X_Ledger_Currency                VARCHAR2,
                       X_Currency_Type                  VARCHAR2,
                       X_Entered_Currency               VARCHAR2,
                       X_Ledger_Id                      NUMBER,
                       X_Relative_Period_Code           VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Assigned_Code_Combination      NUMBER,
                       X_Template_Id                    NUMBER,
                       X_Segment1                       VARCHAR2,
                       X_Segment2                       VARCHAR2,
                       X_Segment3                       VARCHAR2,
                       X_Segment4                       VARCHAR2,
                       X_Segment5                       VARCHAR2,
                       X_Segment6                       VARCHAR2,
                       X_Segment7                       VARCHAR2,
                       X_Segment8                       VARCHAR2,
                       X_Segment9                       VARCHAR2,
                       X_Segment10                      VARCHAR2,
                       X_Segment11                      VARCHAR2,
                       X_Segment12                      VARCHAR2,
                       X_Segment13                      VARCHAR2,
                       X_Segment14                      VARCHAR2,
                       X_Segment15                      VARCHAR2,
                       X_Segment16                      VARCHAR2,
                       X_Segment17                      VARCHAR2,
                       X_Segment18                      VARCHAR2,
                       X_Segment19                      VARCHAR2,
                       X_Segment20                      VARCHAR2,
                       X_Segment21                      VARCHAR2,
                       X_Segment22                      VARCHAR2,
                       X_Segment23                      VARCHAR2,
                       X_Segment24                      VARCHAR2,
                       X_Segment25                      VARCHAR2,
                       X_Segment26                      VARCHAR2,
                       X_Segment27                      VARCHAR2,
                       X_Segment28                      VARCHAR2,
                       X_Segment29                      VARCHAR2,
                       X_Segment30                      VARCHAR2
                      );


  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

  PROCEDURE get_account_type( x_coa_id              NUMBER,
                              x_conc_seg            VARCHAR2,
                              x_account_type OUT NOCOPY VARCHAR2);

--****************************************************************




END GL_RECURRING_RULES_PKG;

 

/
