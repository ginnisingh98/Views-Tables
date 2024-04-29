--------------------------------------------------------
--  DDL for Package GL_CODE_COMBINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CODE_COMBINATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: gliccids.pls 120.9 2005/07/01 05:19:22 agovil ship $ */


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
  --   with the given ledger and also match with all the segment
  --   values of the given ccid.
  -- History
  --   08-MAR-1994  ERumanan  Created.
  -- Arguments
  --   x_ccid    		The code combination id to be checked.
  --   x_template_id 		The valid template_id
  --   x_ledger_id     		The ledger id to be checked.
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.get_valid_sob_summary(
  --                   123, x_template_id, 1);
  -- Notes
  --
  PROCEDURE get_valid_sob_summary(
    x_ccid  			NUMBER,
    x_template_id	IN OUT NOCOPY  NUMBER,
    x_ledger_id			NUMBER );



PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Code_Combination_Id                  NUMBER,
                     X_Alt_Code_Combination_Id              NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Chart_Of_Accounts_Id                 NUMBER,
                     X_Detail_Posting_F                     VARCHAR2,
                     X_Detail_Budgeting_F                   VARCHAR2,
                     X_Balanced_BudgetF                     VARCHAR2,
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
                     X_preserve_flag                        VARCHAR2,
                     X_refresh_flag                         VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Code_Combination_Id                    NUMBER,
                   X_Alt_Code_Combination_Id                NUMBER,
                   X_Chart_Of_Accounts_Id                   NUMBER,
                   X_Detail_Posting_F                       VARCHAR2,
                   X_Detail_Budgeting_F                     VARCHAR2,
                   X_Balanced_BudgetF                       VARCHAR2,
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
                   X_preserve_flag                          VARCHAR2,
                   X_refresh_flag                           VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Alt_Code_Combination_Id             NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Detail_Posting_F                    VARCHAR2,
                     X_Detail_Budgeting_F                  VARCHAR2,
                     X_Balanced_BudgetF                    VARCHAR2,
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
                     X_preserve_flag                       VARCHAR2,
                     X_refresh_flag                        VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

FUNCTION Check_Net_Income_Account(X_CCID NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   get_acct_info
  -- Purpose
  --   This procedure will return information about a particular code
  --   combination, such if it is a net income account, values for template_id,
  --   summary_flag and account_type.
  --
  -- History
  --   11-NOV-2000  S Kung    Created.
  -- Arguments
  --   x_id_flex_structure_code	unique VARCHAR2 code representing a chart
  --                            of accounts
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.get_coa_id('USA_COA1', mCoaId, segCount);
  -- Notes
  --
Procedure Get_Acct_Info(X_CCID			IN	NUMBER,
			X_NET_INCOME_ACCT_FLAG	IN OUT NOCOPY	NUMBER,
			X_TEMPLATE_ID		IN OUT NOCOPY	NUMBER,
			X_ACCT_TYPE		IN OUT NOCOPY	VARCHAR2,
			X_SUMMARY_FLAG		IN OUT NOCOPY	VARCHAR2,
			X_REFRESH_FLAG		IN OUT NOCOPY	VARCHAR2,
			X_PRESERVE_FLAG		IN OUT NOCOPY	VARCHAR2,
                        X_ENABLED_FLAG          IN OUT NOCOPY   VARCHAR2);

  --
  -- Procedure
  --   get_ccid
  -- Purpose
  --   This function will set up the neccessary validation rules needed
  --   to call the AOL routine and create/retreieve a particular
  --   detail code combination.
  --   It will return the CCID of the detail account.
  --
  -- History
  --   23-JAN-2001  S Kung    Created.
  -- Arguments
  --   X_APPS_SHORT_NAME    application short name of GL, i.e. SQLGL
  --   X_KEY_FLEX_CODE      id_flex_code of GL, i.e. GL#
  --   X_COA_ID		    chart of accounts ID
  --   X_VALIDATION_DATE    usually SYSDATE
  --   X_CONCAT_SEGS        the actual code combination concatenated with
  --			    the corresponding delimiter
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.get_ccid('SQLGL', 'GL#', mCoaId, sysdate,
  --                                     '01-000-1000');
  -- Notes
  --
FUNCTION Get_Ccid(X_COA_ID          	    	IN  NUMBER,
		  X_VALIDATION_DATE		IN  VARCHAR2,
		  X_CONCAT_SEGS          	IN  VARCHAR2) RETURN NUMBER;

  --
  -- Procedure
  --   raise_bus_event
  -- Purpose
  --   This function will raise a business event when a code combination
  --   is disabled via the iSetup CCID API.
  --
  -- History
  --   03-SEP-2003  K Vora       Created.
  -- Arguments
  --   X_CCID		    code combination ID
  -- Example
  --   GL_CODE_COMBINATIONS_PKG.raise_bus_event(1234);
  -- Notes
  --
PROCEDURE Raise_Bus_Event(X_COA_ID              IN  NUMBER,
                          X_CCID                IN  NUMBER);



END GL_CODE_COMBINATIONS_PKG;

 

/
