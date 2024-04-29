--------------------------------------------------------
--  DDL for Package IGI_BUD_GL_CODE_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD_GL_CODE_CCID_PKG" AUTHID CURRENT_USER AS
-- $Header: igibudbs.pls 120.3.12000000.2 2007/08/01 08:58:53 pshivara ship $

 --
  -- Procedure
  --   select_row
  -- Purpose
  --   select a row
  -- History
  --   14-APR-94  ERumanan  Created.
  -- Arguments
  --   recinfo    record information
  -- Example
  --   select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row(recinfo IN OUT NOCOPY gl_code_combinations%ROWTYPE);



  --
  -- Procedure
  --   select_columns
  -- Purpose
  --   Get values of some columns.
  -- History
  --   14-APR-94  ERumanan  Created.
  -- Arguments
  --   code_combination_id
  --   account_type
  -- Example
  --   select_columns( :block.code_combination_id,
  --                   :block.account_type );
  -- Notes
  --
PROCEDURE select_columns(
            X_code_combination_id                 NUMBER,
            X_account_type                IN OUT NOCOPY  VARCHAR2,
            X_template_id                 IN OUT NOCOPY  NUMBER );



  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Check the uniqueness of the ccid.
  -- History
  --   27-NOV-1993  ERumanan  Created.
  -- Arguments
  --   x_rowid    The ID of the row to be checked
  --   x_ccid     The code combination id to be checked
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.check_unique( '12345', 1010 );
  -- Notes
  --
  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_ccid  NUMBER );



  --
  -- Procedure
  --   get_valid_sob_summary
  -- Purpose
  --   Retrieve the summary account id and template id that match
  --   with the given set of books and also match with all the segment
  --   values of the given ccid.
  --   books
  -- History
  --   08-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_ccid                   The code combination id to be checked.
  --   x_template_id            The valid template_id
  --   x_sobid                  The set of books id to be checked.
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.get_valid_sob_summary(
  --                   123, x_template_id, 1);
  -- Notes
  --
  PROCEDURE get_valid_sob_summary(
    x_ccid                      NUMBER,
    x_template_id       IN OUT NOCOPY  NUMBER,
    x_sobid                     NUMBER );


/*  The table handling code has been commented out NOCOPY as PSAD no longer
modifies CORE tables.  The following procedures are called by GLXACCMB.fmb
but are no longer required due to the creation of IGIGBCCU.fmb

PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Code_Combination_Id                  NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Chart_Of_Accounts_Id                 NUMBER,
                     X_Detail_Posting_F                     VARCHAR2,
                     X_Detail_Budgeting_F                   VARCHAR2,
                     X_Account_Type                         VARCHAR2,
                     X_Enabled_Flag                         VARCHAR2,
                     X_Summary_Flag                         VARCHAR2,
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
                     X_Segment30                            VARCHAR2,
                     X_Description                          VARCHAR2,
                     X_Template_Id                          NUMBER,
                     X_Start_Date_Active                    DATE,
                     X_End_Date_Active                      DATE,
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
                     X_Context                              VARCHAR2,
                     X_Segment_Attribute1                   VARCHAR2,
                     X_Segment_Attribute2                   VARCHAR2,
                     X_Segment_Attribute3                   VARCHAR2,
                     X_Segment_Attribute4                   VARCHAR2,
                     X_Segment_Attribute5                   VARCHAR2,
                     X_Segment_Attribute6                   VARCHAR2,
                     X_Segment_Attribute7                   VARCHAR2,
                     X_Segment_Attribute8                   VARCHAR2,
                     X_Segment_Attribute9                   VARCHAR2,
                     X_Segment_Attribute10                  VARCHAR2,
                     X_Segment_Attribute11                  VARCHAR2,
                     X_Segment_Attribute12                  VARCHAR2,
                     X_Segment_Attribute13                  VARCHAR2,
                     X_Segment_Attribute14                  VARCHAR2,
                     X_Segment_Attribute15                  VARCHAR2,
                     X_Segment_Attribute16                  VARCHAR2,
                     X_Segment_Attribute17                  VARCHAR2,
                     X_Segment_Attribute18                  VARCHAR2,
                     X_Segment_Attribute19                  VARCHAR2,
                     X_Segment_Attribute20                  VARCHAR2,
                     X_Segment_Attribute21                  VARCHAR2,
                     X_Segment_Attribute22                  VARCHAR2,
                     X_Segment_Attribute23                  VARCHAR2,
                     X_Segment_Attribute24                  VARCHAR2,
                     X_Segment_Attribute25                  VARCHAR2,
                     X_Segment_Attribute26                  VARCHAR2,
                     X_Segment_Attribute27                  VARCHAR2,
                     X_Segment_Attribute28                  VARCHAR2,
                     X_Segment_Attribute29                  VARCHAR2,
                     X_Segment_Attribute30                  VARCHAR2,
                     X_Segment_Attribute31                  VARCHAR2,
                     X_Segment_Attribute32                  VARCHAR2,
                     X_Segment_Attribute33                  VARCHAR2,
                     X_Segment_Attribute34                  VARCHAR2,
                     X_Segment_Attribute35                  VARCHAR2,
                     X_Segment_Attribute36                  VARCHAR2,
                     X_Segment_Attribute37                  VARCHAR2,
                     X_Segment_Attribute38                  VARCHAR2,
                     X_Segment_Attribute39                  VARCHAR2,
                     X_Segment_Attribute40                  VARCHAR2,
                     X_Segment_Attribute41                  VARCHAR2,
                     X_Segment_Attribute42                  VARCHAR2,
                     X_Jgzz_Recon_Context                   VARCHAR2,
                     X_Jgzz_Recon_Flag                      VARCHAR2,
                     X_reference1                           VARCHAR2,
                     X_reference2                           VARCHAR2,
                     X_reference3                           VARCHAR2,
                     X_reference4                           VARCHAR2,
                     X_reference5                           VARCHAR2,
                                         -- OPSFI: BUD, mhazarik 13-Jan-00 Start 1
                                         X_igi_balanced_budget_flag           varchar2
                                         -- OPSFI: BUD, mhazarik 13-Jan-00 End 1
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Code_Combination_Id                    NUMBER,
                   X_Chart_Of_Accounts_Id                   NUMBER,
                   X_Detail_Posting_F                       VARCHAR2,
                   X_Detail_Budgeting_F                     VARCHAR2,
                   X_Account_Type                           VARCHAR2,
                   X_Enabled_Flag                           VARCHAR2,
                   X_Summary_Flag                           VARCHAR2,
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
                   X_Segment30                              VARCHAR2,
                   X_Description                            VARCHAR2,
                   X_Template_Id                            NUMBER,
                   X_Start_Date_Active                      DATE,
                   X_End_Date_Active                        DATE,
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
                   X_Context                                VARCHAR2,
                   X_Segment_Attribute1                     VARCHAR2,
                   X_Segment_Attribute2                     VARCHAR2,
                   X_Segment_Attribute3                     VARCHAR2,
                   X_Segment_Attribute4                     VARCHAR2,
                   X_Segment_Attribute5                     VARCHAR2,
                   X_Segment_Attribute6                     VARCHAR2,
                   X_Segment_Attribute7                     VARCHAR2,
                   X_Segment_Attribute8                     VARCHAR2,
                   X_Segment_Attribute9                     VARCHAR2,
                   X_Segment_Attribute10                    VARCHAR2,
                   X_Segment_Attribute11                    VARCHAR2,
                   X_Segment_Attribute12                    VARCHAR2,
                   X_Segment_Attribute13                    VARCHAR2,
                   X_Segment_Attribute14                    VARCHAR2,
                   X_Segment_Attribute15                    VARCHAR2,
                   X_Segment_Attribute16                    VARCHAR2,
                   X_Segment_Attribute17                    VARCHAR2,
                   X_Segment_Attribute18                    VARCHAR2,
                   X_Segment_Attribute19                    VARCHAR2,
                   X_Segment_Attribute20                    VARCHAR2,
                   X_Segment_Attribute21                    VARCHAR2,
                   X_Segment_Attribute22                    VARCHAR2,
                   X_Segment_Attribute23                    VARCHAR2,
                   X_Segment_Attribute24                    VARCHAR2,
                   X_Segment_Attribute25                    VARCHAR2,
                   X_Segment_Attribute26                    VARCHAR2,
                   X_Segment_Attribute27                    VARCHAR2,
                   X_Segment_Attribute28                    VARCHAR2,
                   X_Segment_Attribute29                    VARCHAR2,
                   X_Segment_Attribute30                    VARCHAR2,
                   X_Segment_Attribute31                    VARCHAR2,
                   X_Segment_Attribute32                    VARCHAR2,
                   X_Segment_Attribute33                    VARCHAR2,
                   X_Segment_Attribute34                    VARCHAR2,
                   X_Segment_Attribute35                    VARCHAR2,
                   X_Segment_Attribute36                    VARCHAR2,
                   X_Segment_Attribute37                    VARCHAR2,
                   X_Segment_Attribute38                    VARCHAR2,
                   X_Segment_Attribute39                    VARCHAR2,
                   X_Segment_Attribute40                    VARCHAR2,
                   X_Segment_Attribute41                    VARCHAR2,
                   X_Segment_Attribute42                    VARCHAR2,
                   X_Jgzz_Recon_Context                     VARCHAR2,
                   X_Jgzz_Recon_Flag                        VARCHAR2,
                   X_reference1                             VARCHAR2,
                   X_reference2                             VARCHAR2,
                   X_reference3                             VARCHAR2,
                   X_reference4                             VARCHAR2,
                   X_reference5                             VARCHAR2,
                                   -- OPSFI: BUD, mhazarik 13-Jan-00 Start 1
                                   X_igi_balanced_budget_flag           varchar2
                                   -- OPSFI: BUD, mhazarik 13-Jan-00 End 1
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Detail_Posting_F                    VARCHAR2,
                     X_Detail_Budgeting_F                  VARCHAR2,
                     X_Account_Type                        VARCHAR2,
                     X_Enabled_Flag                        VARCHAR2,
                     X_Summary_Flag                        VARCHAR2,
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
                     X_Segment30                           VARCHAR2,
                     X_Description                         VARCHAR2,
                     X_Template_Id                         NUMBER,
                     X_Start_Date_Active                   DATE,
                     X_End_Date_Active                     DATE,
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
                     X_Context                             VARCHAR2,
                     X_Segment_Attribute1                  VARCHAR2,
                     X_Segment_Attribute2                  VARCHAR2,
                     X_Segment_Attribute3                  VARCHAR2,
                     X_Segment_Attribute4                  VARCHAR2,
                     X_Segment_Attribute5                  VARCHAR2,
                     X_Segment_Attribute6                  VARCHAR2,
                     X_Segment_Attribute7                  VARCHAR2,
                     X_Segment_Attribute8                  VARCHAR2,
                     X_Segment_Attribute9                  VARCHAR2,
                     X_Segment_Attribute10                 VARCHAR2,
                     X_Segment_Attribute11                 VARCHAR2,
                     X_Segment_Attribute12                 VARCHAR2,
                     X_Segment_Attribute13                 VARCHAR2,
                     X_Segment_Attribute14                 VARCHAR2,
                     X_Segment_Attribute15                 VARCHAR2,
                     X_Segment_Attribute16                 VARCHAR2,
                     X_Segment_Attribute17                 VARCHAR2,
                     X_Segment_Attribute18                 VARCHAR2,
                     X_Segment_Attribute19                 VARCHAR2,
                     X_Segment_Attribute20                 VARCHAR2,
                     X_Segment_Attribute21                 VARCHAR2,
                     X_Segment_Attribute22                 VARCHAR2,
                     X_Segment_Attribute23                 VARCHAR2,
                     X_Segment_Attribute24                 VARCHAR2,
                     X_Segment_Attribute25                 VARCHAR2,
                     X_Segment_Attribute26                 VARCHAR2,
                     X_Segment_Attribute27                 VARCHAR2,
                     X_Segment_Attribute28                 VARCHAR2,
                     X_Segment_Attribute29                 VARCHAR2,
                     X_Segment_Attribute30                 VARCHAR2,
                     X_Segment_Attribute31                 VARCHAR2,
                     X_Segment_Attribute32                 VARCHAR2,
                     X_Segment_Attribute33                 VARCHAR2,
                     X_Segment_Attribute34                 VARCHAR2,
                     X_Segment_Attribute35                 VARCHAR2,
                     X_Segment_Attribute36                 VARCHAR2,
                     X_Segment_Attribute37                 VARCHAR2,
                     X_Segment_Attribute38                 VARCHAR2,
                     X_Segment_Attribute39                 VARCHAR2,
                     X_Segment_Attribute40                 VARCHAR2,
                     X_Segment_Attribute41                 VARCHAR2,
                     X_Segment_Attribute42                 VARCHAR2,
                     X_Jgzz_Recon_Context                  VARCHAR2,
                     X_Jgzz_Recon_Flag                     VARCHAR2,
                     X_reference1                          VARCHAR2,
                     X_reference2                          VARCHAR2,
                     X_reference3                          VARCHAR2,
                     X_reference4                          VARCHAR2,
                     X_reference5                          VARCHAR2,
                                         -- OPSFI: BUD, mhazarik 13-Jan-00 Start 1
                                         X_igi_balanced_budget_flag           varchar2
                                         -- OPSFI: BUD, mhazarik 13-Jan-00 End 1
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);
*/

FUNCTION Check_Net_Income_Account(X_CCID NUMBER) RETURN BOOLEAN;

END IGI_BUD_GL_CODE_CCID_PKG;

 

/
