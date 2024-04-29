--------------------------------------------------------
--  DDL for Package Body GL_CODE_COMBINATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CODE_COMBINATIONS_PKG" AS
/* $Header: gliccidb.pls 120.9 2005/07/01 05:19:41 agovil ship $ */


  --
  -- PUBLIC FUNCTIONS
  --



PROCEDURE select_row( recinfo IN OUT NOCOPY gl_code_combinations%ROWTYPE ) IS
BEGIN
  SELECT *
  INTO   recinfo
  FROM   gl_code_combinations
  WHERE  code_combination_id = recinfo.code_combination_id;
END select_row;

-- **********************************************************************

PROCEDURE select_columns(
            X_code_combination_id                 NUMBER,
            X_account_type                IN OUT NOCOPY  VARCHAR2,
            X_template_id                 IN OUT NOCOPY  NUMBER ) IS
  recinfo gl_code_combinations%ROWTYPE;
BEGIN
  recinfo.code_combination_id := X_code_combination_id;
  select_row(recinfo);
  X_account_type := recinfo.account_type;
  X_template_id := recinfo.template_id;
END select_columns;

-- **********************************************************************

  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_ccid  NUMBER ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_code_combinations cc
      WHERE  cc.code_combination_id = x_ccid
      AND    ( x_rowid is NULL
               OR
               cc.rowid <> x_rowid );
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_CCID' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_CODE_COMBINATIONS_PKG.check_unique');
      RAISE;

  END check_unique;

-- **********************************************************************

PROCEDURE get_valid_sob_summary(
              x_ccid                        NUMBER,
              x_template_id         IN OUT NOCOPY  NUMBER,
              x_ledger_id                   NUMBER ) IS

   new_ledger_id NUMBER(15);

 BEGIN

   SELECT st.ledger_id,
          st.template_id
   INTO   new_ledger_id,
          x_template_id
   FROM  gl_code_combinations cc,
         gl_summary_templates st
   WHERE cc.code_combination_id = x_ccid
   AND   st.template_id(+) = cc.template_id;

   IF (new_ledger_id <> x_ledger_id) THEN
     fnd_message.set_name( 'SQLGL', 'GL_INVALID_SUMMARY_ACCOUNT' );
     app_exception.raise_exception;
   END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_CODE_COMBINATIONS_PKG.get_valid_sob_summary');
      RAISE;

  END get_valid_sob_summary;

-- **********************************************************************

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Alt_Code_Combination_Id             NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Chart_Of_Accounts_Id                NUMBER,
                     X_Detail_Posting_F                    VARCHAR2,
                     X_Detail_Budgeting_F                  VARCHAR2,
                     X_Balanced_budgetF                    VARCHAR2,
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
 ) IS
   CURSOR C IS SELECT rowid FROM gl_code_combinations

             WHERE code_combination_id = X_Code_Combination_Id;






BEGIN






  INSERT INTO gl_code_combinations(
          code_combination_id,
          alternate_code_combination_id,
          last_update_date,
          last_updated_by,
          chart_of_accounts_id,
          detail_posting_allowed_flag,
          detail_budgeting_allowed_flag,
          igi_balanced_budget_flag,
          account_type,
          enabled_flag,
          summary_flag,
          segment1,
          segment2,
          segment3,
          segment4,
          segment5,
          segment6,
          segment7,
          segment8,
          segment9,
          segment10,
          segment11,
          segment12,
          segment13,
          segment14,
          segment15,
          segment16,
          segment17,
          segment18,
          segment19,
          segment20,
          segment21,
          segment22,
          segment23,
          segment24,
          segment25,
          segment26,
          segment27,
          segment28,
          segment29,
          segment30,
          description,
          template_id,
          start_date_active,
          end_date_active,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          context,
          segment_attribute1,
          segment_attribute2,
          segment_attribute3,
          segment_attribute4,
          segment_attribute5,
          segment_attribute6,
          segment_attribute7,
          segment_attribute8,
          segment_attribute9,
          segment_attribute10,
          segment_attribute11,
          segment_attribute12,
          segment_attribute13,
          segment_attribute14,
          segment_attribute15,
          segment_attribute16,
          segment_attribute17,
          segment_attribute18,
          segment_attribute19,
          segment_attribute20,
          segment_attribute21,
          segment_attribute22,
          segment_attribute23,
          segment_attribute24,
          segment_attribute25,
          segment_attribute26,
          segment_attribute27,
          segment_attribute28,
          segment_attribute29,
          segment_attribute30,
          segment_attribute31,
          segment_attribute32,
          segment_attribute33,
          segment_attribute34,
          segment_attribute35,
          segment_attribute36,
          segment_attribute37,
          segment_attribute38,
          segment_attribute39,
          segment_attribute40,
          segment_attribute41,
          segment_attribute42,
          jgzz_recon_context,
          jgzz_recon_flag,
          reference1,
          reference2,
          reference3,
          reference4,
          reference5,
          preserve_flag,
          refresh_flag
         ) VALUES (
          X_Code_Combination_Id,
          X_Alt_Code_Combination_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Chart_Of_Accounts_Id,
          X_Detail_Posting_F,
          X_Detail_Budgeting_F,
          X_Balanced_budgetF,
          X_Account_Type,
          X_Enabled_Flag,
          X_Summary_Flag,
          X_Segment1,
          X_Segment2,
          X_Segment3,
          X_Segment4,
          X_Segment5,
          X_Segment6,
          X_Segment7,
          X_Segment8,
          X_Segment9,
          X_Segment10,
          X_Segment11,
          X_Segment12,
          X_Segment13,
          X_Segment14,
          X_Segment15,
          X_Segment16,
          X_Segment17,
          X_Segment18,
          X_Segment19,
          X_Segment20,
          X_Segment21,
          X_Segment22,
          X_Segment23,
          X_Segment24,
          X_Segment25,
          X_Segment26,
          X_Segment27,
          X_Segment28,
          X_Segment29,
          X_Segment30,
          X_Description,
          X_Template_Id,
          X_Start_Date_Active,
          X_End_Date_Active,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Context,
          X_Segment_Attribute1,
          X_Segment_Attribute2,
          X_Segment_Attribute3,
          X_Segment_Attribute4,
          X_Segment_Attribute5,
          X_Segment_Attribute6,
          X_Segment_Attribute7,
          X_Segment_Attribute8,
          X_Segment_Attribute9,
          X_Segment_Attribute10,
          X_Segment_Attribute11,
          X_Segment_Attribute12,
          X_Segment_Attribute13,
          X_Segment_Attribute14,
          X_Segment_Attribute15,
          X_Segment_Attribute16,
          X_Segment_Attribute17,
          X_Segment_Attribute18,
          X_Segment_Attribute19,
          X_Segment_Attribute20,
          X_Segment_Attribute21,
          X_Segment_Attribute22,
          X_Segment_Attribute23,
          X_Segment_Attribute24,
          X_Segment_Attribute25,
          X_Segment_Attribute26,
          X_Segment_Attribute27,
          X_Segment_Attribute28,
          X_Segment_Attribute29,
          X_Segment_Attribute30,
          X_Segment_Attribute31,
          X_Segment_Attribute32,
          X_Segment_Attribute33,
          X_Segment_Attribute34,
          X_Segment_Attribute35,
          X_Segment_Attribute36,
          X_Segment_Attribute37,
          X_Segment_Attribute38,
          X_Segment_Attribute39,
          X_Segment_Attribute40,
          X_Segment_Attribute41,
          X_Segment_Attribute42,
          X_Jgzz_Recon_Context,
          X_Jgzz_Recon_Flag,
          X_reference1,
          X_reference2,
          X_reference3,
          X_reference4,
          X_reference5,
          X_preserve_flag,
          X_refresh_flag
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

-- **********************************************************************

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Code_Combination_Id                   NUMBER,
                   X_Alt_Code_Combination_Id               NUMBER,
                   X_Chart_Of_Accounts_Id                  NUMBER,
                   X_Detail_Posting_F                      VARCHAR2,
                   X_Detail_Budgeting_F                    VARCHAR2,
                   X_Balanced_BudgetF                      VARCHAR2,
                   X_Account_Type                          VARCHAR2,
                   X_Enabled_Flag                          VARCHAR2,
                   X_Summary_Flag                          VARCHAR2,
                   X_Segment1                              VARCHAR2,
                   X_Segment2                              VARCHAR2,
                   X_Segment3                              VARCHAR2,
                   X_Segment4                              VARCHAR2,
                   X_Segment5                              VARCHAR2,
                   X_Segment6                              VARCHAR2,
                   X_Segment7                              VARCHAR2,
                   X_Segment8                              VARCHAR2,
                   X_Segment9                              VARCHAR2,
                   X_Segment10                             VARCHAR2,
                   X_Segment11                             VARCHAR2,
                   X_Segment12                             VARCHAR2,
                   X_Segment13                             VARCHAR2,
                   X_Segment14                             VARCHAR2,
                   X_Segment15                             VARCHAR2,
                   X_Segment16                             VARCHAR2,
                   X_Segment17                             VARCHAR2,
                   X_Segment18                             VARCHAR2,
                   X_Segment19                             VARCHAR2,
                   X_Segment20                             VARCHAR2,
                   X_Segment21                             VARCHAR2,
                   X_Segment22                             VARCHAR2,
                   X_Segment23                             VARCHAR2,
                   X_Segment24                             VARCHAR2,
                   X_Segment25                             VARCHAR2,
                   X_Segment26                             VARCHAR2,
                   X_Segment27                             VARCHAR2,
                   X_Segment28                             VARCHAR2,
                   X_Segment29                             VARCHAR2,
                   X_Segment30                             VARCHAR2,
                   X_Description                           VARCHAR2,
                   X_Template_Id                           NUMBER,
                   X_Start_Date_Active                     DATE,
                   X_End_Date_Active                       DATE,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Segment_Attribute1                    VARCHAR2,
                   X_Segment_Attribute2                    VARCHAR2,
                   X_Segment_Attribute3                    VARCHAR2,
                   X_Segment_Attribute4                    VARCHAR2,
                   X_Segment_Attribute5                    VARCHAR2,
                   X_Segment_Attribute6                    VARCHAR2,
                   X_Segment_Attribute7                    VARCHAR2,
                   X_Segment_Attribute8                    VARCHAR2,
                   X_Segment_Attribute9                    VARCHAR2,
                   X_Segment_Attribute10                   VARCHAR2,
                   X_Segment_Attribute11                   VARCHAR2,
                   X_Segment_Attribute12                   VARCHAR2,
                   X_Segment_Attribute13                   VARCHAR2,
                   X_Segment_Attribute14                   VARCHAR2,
                   X_Segment_Attribute15                   VARCHAR2,
                   X_Segment_Attribute16                   VARCHAR2,
                   X_Segment_Attribute17                   VARCHAR2,
                   X_Segment_Attribute18                   VARCHAR2,
                   X_Segment_Attribute19                   VARCHAR2,
                   X_Segment_Attribute20                   VARCHAR2,
                   X_Segment_Attribute21                   VARCHAR2,
                   X_Segment_Attribute22                   VARCHAR2,
                   X_Segment_Attribute23                   VARCHAR2,
                   X_Segment_Attribute24                   VARCHAR2,
                   X_Segment_Attribute25                   VARCHAR2,
                   X_Segment_Attribute26                   VARCHAR2,
                   X_Segment_Attribute27                   VARCHAR2,
                   X_Segment_Attribute28                   VARCHAR2,
                   X_Segment_Attribute29                   VARCHAR2,
                   X_Segment_Attribute30                   VARCHAR2,
                   X_Segment_Attribute31                   VARCHAR2,
                   X_Segment_Attribute32                   VARCHAR2,
                   X_Segment_Attribute33                   VARCHAR2,
                   X_Segment_Attribute34                   VARCHAR2,
                   X_Segment_Attribute35                   VARCHAR2,
                   X_Segment_Attribute36                   VARCHAR2,
                   X_Segment_Attribute37                   VARCHAR2,
                   X_Segment_Attribute38                   VARCHAR2,
                   X_Segment_Attribute39                   VARCHAR2,
                   X_Segment_Attribute40                   VARCHAR2,
                   X_Segment_Attribute41                   VARCHAR2,
                   X_Segment_Attribute42                   VARCHAR2,
                   X_Jgzz_Recon_Context                    VARCHAR2,
                   X_Jgzz_Recon_Flag                       VARCHAR2,
                   X_reference1                            VARCHAR2,
                   X_reference2                            VARCHAR2,
                   X_reference3                            VARCHAR2,
                   X_reference4                            VARCHAR2,
                   X_reference5                            VARCHAR2,
                   X_preserve_flag                         VARCHAR2,
                   X_refresh_flag                          VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_code_combinations
      WHERE  rowid = X_Rowid
      FOR UPDATE of Code_Combination_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.alternate_code_combination_id = X_Alt_Code_Combination_Id)
           OR (    (Recinfo.alternate_code_combination_id IS NULL)
               AND (X_Alt_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.chart_of_accounts_id = X_Chart_Of_Accounts_Id)
           OR (    (Recinfo.chart_of_accounts_id IS NULL)
               AND (X_Chart_Of_Accounts_Id IS NULL)))
      AND (   (Recinfo.detail_posting_allowed_flag = X_Detail_Posting_F)
           OR (    (Recinfo.detail_posting_allowed_flag IS NULL)
               AND (X_Detail_Posting_F IS NULL)))
      AND (   (Recinfo.detail_budgeting_allowed_flag = X_Detail_Budgeting_F)
           OR (    (Recinfo.detail_budgeting_allowed_flag IS NULL)
               AND (X_Detail_Budgeting_F IS NULL)))
      AND (   (Recinfo.igi_balanced_budget_flag = X_Balanced_BudgetF)
           OR (    (Recinfo.igi_balanced_budget_flag IS NULL)
               AND (X_Balanced_BudgetF IS NULL)))
      AND (   (Recinfo.account_type = X_Account_Type)
           OR (    (Recinfo.account_type IS NULL)
               AND (X_Account_Type IS NULL)))
      AND (   (Recinfo.enabled_flag = X_Enabled_Flag)
           OR (    (Recinfo.enabled_flag IS NULL)
               AND (X_Enabled_Flag IS NULL)))
      AND (   (Recinfo.summary_flag = X_Summary_Flag)
           OR (    (Recinfo.summary_flag IS NULL)
               AND (X_Summary_Flag IS NULL)))
      AND (   (Recinfo.segment1 = X_Segment1)
           OR (    (Recinfo.segment1 IS NULL)
               AND (X_Segment1 IS NULL)))
      AND (   (Recinfo.segment2 = X_Segment2)
           OR (    (Recinfo.segment2 IS NULL)
               AND (X_Segment2 IS NULL)))
      AND (   (Recinfo.segment3 = X_Segment3)
           OR (    (Recinfo.segment3 IS NULL)
               AND (X_Segment3 IS NULL)))
      AND (   (Recinfo.segment4 = X_Segment4)
           OR (    (Recinfo.segment4 IS NULL)
               AND (X_Segment4 IS NULL)))
      AND (   (Recinfo.segment5 = X_Segment5)
           OR (    (Recinfo.segment5 IS NULL)
               AND (X_Segment5 IS NULL)))
      AND (   (Recinfo.segment6 = X_Segment6)
           OR (    (Recinfo.segment6 IS NULL)
               AND (X_Segment6 IS NULL)))
      AND (   (Recinfo.segment7 = X_Segment7)
           OR (    (Recinfo.segment7 IS NULL)
               AND (X_Segment7 IS NULL)))
      AND (   (Recinfo.segment8 = X_Segment8)
           OR (    (Recinfo.segment8 IS NULL)
               AND (X_Segment8 IS NULL)))
      AND (   (Recinfo.segment9 = X_Segment9)
           OR (    (Recinfo.segment9 IS NULL)
               AND (X_Segment9 IS NULL)))
      AND (   (Recinfo.segment10 = X_Segment10)
           OR (    (Recinfo.segment10 IS NULL)
               AND (X_Segment10 IS NULL)))
      AND (   (Recinfo.segment11 = X_Segment11)
           OR (    (Recinfo.segment11 IS NULL)
               AND (X_Segment11 IS NULL)))
      AND (   (Recinfo.segment12 = X_Segment12)
           OR (    (Recinfo.segment12 IS NULL)
               AND (X_Segment12 IS NULL)))
      AND (   (Recinfo.segment13 = X_Segment13)
           OR (    (Recinfo.segment13 IS NULL)
               AND (X_Segment13 IS NULL)))
      AND (   (Recinfo.segment14 = X_Segment14)
           OR (    (Recinfo.segment14 IS NULL)
               AND (X_Segment14 IS NULL)))
      AND (   (Recinfo.segment15 = X_Segment15)
           OR (    (Recinfo.segment15 IS NULL)
               AND (X_Segment15 IS NULL)))
      AND (   (Recinfo.segment16 = X_Segment16)
           OR (    (Recinfo.segment16 IS NULL)
               AND (X_Segment16 IS NULL)))
      AND (   (Recinfo.segment17 = X_Segment17)
           OR (    (Recinfo.segment17 IS NULL)
               AND (X_Segment17 IS NULL)))
      AND (   (Recinfo.segment18 = X_Segment18)
           OR (    (Recinfo.segment18 IS NULL)
               AND (X_Segment18 IS NULL)))
      AND (   (Recinfo.segment19 = X_Segment19)
           OR (    (Recinfo.segment19 IS NULL)
               AND (X_Segment19 IS NULL)))
      AND (   (Recinfo.segment20 = X_Segment20)
           OR (    (Recinfo.segment20 IS NULL)
               AND (X_Segment20 IS NULL)))
      AND (   (Recinfo.segment21 = X_Segment21)
           OR (    (Recinfo.segment21 IS NULL)
               AND (X_Segment21 IS NULL)))
      AND (   (Recinfo.segment22 = X_Segment22)
           OR (    (Recinfo.segment22 IS NULL)
               AND (X_Segment22 IS NULL)))
      AND (   (Recinfo.segment23 = X_Segment23)
           OR (    (Recinfo.segment23 IS NULL)
               AND (X_Segment23 IS NULL)))
      AND (   (Recinfo.segment24 = X_Segment24)
           OR (    (Recinfo.segment24 IS NULL)
               AND (X_Segment24 IS NULL)))
      AND (   (Recinfo.segment25 = X_Segment25)
           OR (    (Recinfo.segment25 IS NULL)
               AND (X_Segment25 IS NULL)))
      AND (   (Recinfo.segment26 = X_Segment26)
           OR (    (Recinfo.segment26 IS NULL)
               AND (X_Segment26 IS NULL)))) THEN

   if (
      (   (Recinfo.segment27 = X_Segment27)
           OR (    (Recinfo.segment27 IS NULL)
               AND (X_Segment27 IS NULL)))
      AND (   (Recinfo.segment28 = X_Segment28)
           OR (    (Recinfo.segment28 IS NULL)
               AND (X_Segment28 IS NULL)))
      AND (   (Recinfo.segment29 = X_Segment29)
           OR (    (Recinfo.segment29 IS NULL)
               AND (X_Segment29 IS NULL)))
      AND (   (Recinfo.segment30 = X_Segment30)
           OR (    (Recinfo.segment30 IS NULL)
               AND (X_Segment30 IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.template_id = X_Template_Id)
           OR (    (Recinfo.template_id IS NULL)
               AND (X_Template_Id IS NULL)))
      AND (   (Recinfo.start_date_active = X_Start_Date_Active)
           OR (    (Recinfo.start_date_active IS NULL)
               AND (X_Start_Date_Active IS NULL)))
      AND (   (Recinfo.end_date_active = X_End_Date_Active)
           OR (    (Recinfo.end_date_active IS NULL)
               AND (X_End_Date_Active IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.segment_attribute1 = X_Segment_Attribute1)
           OR (    (Recinfo.segment_attribute1 IS NULL)
               AND (X_Segment_Attribute1 IS NULL)))
      AND (   (Recinfo.segment_attribute2 = X_Segment_Attribute2)
           OR (    (Recinfo.segment_attribute2 IS NULL)
               AND (X_Segment_Attribute2 IS NULL)))
      AND (   (Recinfo.segment_attribute3 = X_Segment_Attribute3)
           OR (    (Recinfo.segment_attribute3 IS NULL)
               AND (X_Segment_Attribute3 IS NULL)))
      AND (   (Recinfo.segment_attribute4 = X_Segment_Attribute4)
           OR (    (Recinfo.segment_attribute4 IS NULL)
               AND (X_Segment_Attribute4 IS NULL)))
      AND (   (Recinfo.segment_attribute5 = X_Segment_Attribute5)
           OR (    (Recinfo.segment_attribute5 IS NULL)
               AND (X_Segment_Attribute5 IS NULL)))
      AND (   (Recinfo.segment_attribute6 = X_Segment_Attribute6)
           OR (    (Recinfo.segment_attribute6 IS NULL)
               AND (X_Segment_Attribute6 IS NULL)))
      AND (   (Recinfo.segment_attribute7 = X_Segment_Attribute7)
           OR (    (Recinfo.segment_attribute7 IS NULL)
               AND (X_Segment_Attribute7 IS NULL)))
      AND (   (Recinfo.segment_attribute8 = X_Segment_Attribute8)
           OR (    (Recinfo.segment_attribute8 IS NULL)
               AND (X_Segment_Attribute8 IS NULL)))
      AND (   (Recinfo.segment_attribute9 = X_Segment_Attribute9)
           OR (    (Recinfo.segment_attribute9 IS NULL)
               AND (X_Segment_Attribute9 IS NULL)))
      AND (   (Recinfo.segment_attribute10 = X_Segment_Attribute10)
           OR (    (Recinfo.segment_attribute10 IS NULL)
               AND (X_Segment_Attribute10 IS NULL)))
      AND (   (Recinfo.segment_attribute11 = X_Segment_Attribute11)
           OR (    (Recinfo.segment_attribute11 IS NULL)
               AND (X_Segment_Attribute11 IS NULL)))
      AND (   (Recinfo.segment_attribute12 = X_Segment_Attribute12)
           OR (    (Recinfo.segment_attribute12 IS NULL)
               AND (X_Segment_Attribute12 IS NULL)))
      AND (   (Recinfo.segment_attribute13 = X_Segment_Attribute13)
           OR (    (Recinfo.segment_attribute13 IS NULL)
               AND (X_Segment_Attribute13 IS NULL)))) THEN

     if (
      (   (Recinfo.segment_attribute14 = X_Segment_Attribute14)
           OR (    (Recinfo.segment_attribute14 IS NULL)
               AND (X_Segment_Attribute14 IS NULL)))
      AND (   (Recinfo.segment_attribute15 = X_Segment_Attribute15)
           OR (    (Recinfo.segment_attribute15 IS NULL)
               AND (X_Segment_Attribute15 IS NULL)))
      AND (   (Recinfo.segment_attribute16 = X_Segment_Attribute16)
           OR (    (Recinfo.segment_attribute16 IS NULL)
               AND (X_Segment_Attribute16 IS NULL)))
      AND (   (Recinfo.segment_attribute17 = X_Segment_Attribute17)
           OR (    (Recinfo.segment_attribute17 IS NULL)
               AND (X_Segment_Attribute17 IS NULL)))
      AND (   (Recinfo.segment_attribute18 = X_Segment_Attribute18)
           OR (    (Recinfo.segment_attribute18 IS NULL)
               AND (X_Segment_Attribute18 IS NULL)))
      AND (   (Recinfo.segment_attribute19 = X_Segment_Attribute19)
           OR (    (Recinfo.segment_attribute19 IS NULL)
               AND (X_Segment_Attribute19 IS NULL)))
      AND (   (Recinfo.segment_attribute20 = X_Segment_Attribute20)
           OR (    (Recinfo.segment_attribute20 IS NULL)
               AND (X_Segment_Attribute20 IS NULL)))
      AND (   (Recinfo.segment_attribute21 = X_Segment_Attribute21)
           OR (    (Recinfo.segment_attribute21 IS NULL)
               AND (X_Segment_Attribute21 IS NULL)))
      AND (   (Recinfo.segment_attribute22 = X_Segment_Attribute22)
           OR (    (Recinfo.segment_attribute22 IS NULL)
               AND (X_Segment_Attribute22 IS NULL)))
      AND (   (Recinfo.segment_attribute23 = X_Segment_Attribute23)
           OR (    (Recinfo.segment_attribute23 IS NULL)
               AND (X_Segment_Attribute23 IS NULL)))
      AND (   (Recinfo.segment_attribute24 = X_Segment_Attribute24)
           OR (    (Recinfo.segment_attribute24 IS NULL)
               AND (X_Segment_Attribute24 IS NULL)))
      AND (   (Recinfo.segment_attribute25 = X_Segment_Attribute25)
           OR (    (Recinfo.segment_attribute25 IS NULL)
               AND (X_Segment_Attribute25 IS NULL)))
      AND (   (Recinfo.segment_attribute26 = X_Segment_Attribute26)
           OR (    (Recinfo.segment_attribute26 IS NULL)
               AND (X_Segment_Attribute26 IS NULL)))
      AND (   (Recinfo.segment_attribute27 = X_Segment_Attribute27)
           OR (    (Recinfo.segment_attribute27 IS NULL)
               AND (X_Segment_Attribute27 IS NULL)))
      AND (   (Recinfo.segment_attribute28 = X_Segment_Attribute28)
           OR (    (Recinfo.segment_attribute28 IS NULL)
               AND (X_Segment_Attribute28 IS NULL)))
      AND (   (Recinfo.segment_attribute29 = X_Segment_Attribute29)
           OR (    (Recinfo.segment_attribute29 IS NULL)
               AND (X_Segment_Attribute29 IS NULL)))
      AND (   (Recinfo.segment_attribute30 = X_Segment_Attribute30)
           OR (    (Recinfo.segment_attribute30 IS NULL)
               AND (X_Segment_Attribute30 IS NULL)))
      AND (   (Recinfo.segment_attribute31 = X_Segment_Attribute31)
           OR (    (Recinfo.segment_attribute31 IS NULL)
               AND (X_Segment_Attribute31 IS NULL)))
      AND (   (Recinfo.segment_attribute32 = X_Segment_Attribute32)
           OR (    (Recinfo.segment_attribute32 IS NULL)
               AND (X_Segment_Attribute32 IS NULL)))
      AND (   (Recinfo.segment_attribute33 = X_Segment_Attribute33)
           OR (    (Recinfo.segment_attribute33 IS NULL)
               AND (X_Segment_Attribute33 IS NULL)))
      AND (   (Recinfo.segment_attribute34 = X_Segment_Attribute34)
           OR (    (Recinfo.segment_attribute34 IS NULL)
               AND (X_Segment_Attribute34 IS NULL)))
      AND (   (Recinfo.segment_attribute35 = X_Segment_Attribute35)
           OR (    (Recinfo.segment_attribute35 IS NULL)
               AND (X_Segment_Attribute35 IS NULL)))
      AND (   (Recinfo.segment_attribute36 = X_Segment_Attribute36)
           OR (    (Recinfo.segment_attribute36 IS NULL)
               AND (X_Segment_Attribute36 IS NULL)))
      AND (   (Recinfo.segment_attribute37 = X_Segment_Attribute37)
           OR (    (Recinfo.segment_attribute37 IS NULL)
               AND (X_Segment_Attribute37 IS NULL)))
      AND (   (Recinfo.segment_attribute38 = X_Segment_Attribute38)
           OR (    (Recinfo.segment_attribute38 IS NULL)
               AND (X_Segment_Attribute38 IS NULL)))
      AND (   (Recinfo.segment_attribute39 = X_Segment_Attribute39)
           OR (    (Recinfo.segment_attribute39 IS NULL)
               AND (X_Segment_Attribute39 IS NULL)))
      AND (   (Recinfo.segment_attribute40 = X_Segment_Attribute40)
           OR (    (Recinfo.segment_attribute40 IS NULL)
               AND (X_Segment_Attribute40 IS NULL)))
      AND (   (Recinfo.segment_attribute41 = X_Segment_Attribute41)
           OR (    (Recinfo.segment_attribute41 IS NULL)
               AND (X_Segment_Attribute41 IS NULL)))
      AND (   (Recinfo.segment_attribute42 = X_Segment_Attribute42)
           OR (    (Recinfo.segment_attribute42 IS NULL)
               AND (X_Segment_Attribute42 IS NULL)))
      AND (   (Recinfo.jgzz_recon_context = X_Jgzz_Recon_Context)
           OR (    (Recinfo.jgzz_recon_context IS NULL)
               AND (X_Jgzz_Recon_Context IS NULL)))
      AND (   (Recinfo.jgzz_recon_flag = X_Jgzz_Recon_Flag)
           OR (    (Recinfo.jgzz_recon_flag IS NULL)
               AND (X_Jgzz_Recon_Flag IS NULL)))
      AND (   (Recinfo.reference1 = X_reference1)
           OR (    (Recinfo.reference1 IS NULL)
               AND (X_reference1 IS NULL)))
      AND (   (Recinfo.reference2 = X_reference2)
           OR (    (Recinfo.reference2 IS NULL)
               AND (X_reference2 IS NULL)))
      AND (   (Recinfo.reference3 = X_reference3)
           OR (    (Recinfo.reference3 IS NULL)
               AND (X_reference3 IS NULL)))
      AND (   (Recinfo.reference4 = X_reference4)
           OR (    (Recinfo.reference4 IS NULL)
               AND (X_reference4 IS NULL)))
      AND (   (Recinfo.reference5 = X_reference5)
           OR (    (Recinfo.reference5 IS NULL)
               AND (X_reference5 IS NULL)))
      AND (   (Recinfo.preserve_flag = X_preserve_flag)
           OR (    (Recinfo.preserve_flag IS NULL)
               AND (X_preserve_flag IS NULL)))
      AND (   (Recinfo.refresh_flag = X_refresh_flag)
           OR (    (Recinfo.refresh_flag IS NULL)
               AND (X_refresh_flag IS NULL)))
           ) THEN
        -- Record has not changed.
        return;
      end if;
    end if;
  end if;

  -- Record has been changed.
  FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
  APP_EXCEPTION.RAISE_EXCEPTION;

END Lock_Row;

-- **********************************************************************

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
 ) IS
  old_enabled_flag VARCHAR2(1);
  ekey             VARCHAR2(100);
  edata            VARCHAR2(200);
  edataclob        CLOB;
BEGIN
  /* Check to see if account has been disabled */
  IF (X_enabled_flag = 'N') THEN
    SELECT enabled_flag
    INTO old_enabled_flag
    FROM gl_code_combinations
    WHERE rowid = X_rowid;

    IF (old_enabled_flag = 'Y') THEN
      /*
       + Account has been disabled, so raise event
       */

      /* Get event key */
      SELECT to_char(x_chart_of_accounts_id)||':'||
             to_char(sysdate, 'RRDDDSSSSS')||':'||
             to_char(x_code_combination_id)
      INTO ekey
      FROM dual;

      /* Raise the disabled account event */
      IF (gl_business_events.test(
            'oracle.apps.gl.Maintenance.account.disable') = 'MESSAGE') THEN

        edata := '<?xml version="1.0"?> '||
                 '<DisabledAccounts> ' ||
                 '<CODE_COMBINATION_ID> '||
                 to_char(x_code_combination_id) ||
                 '</CODE_COMBINATION_ID> ' ||
                 '</DisabledAccounts> ';

        dbms_lob.createtemporary(edataclob, FALSE, DBMS_LOB.CALL);
        dbms_lob.write(edataclob, length(edata), 1, edata);

        gl_business_events.raise(
          p_event_name => 'oracle.apps.gl.Maintenance.account.disable',
          p_event_key => ekey,
          p_event_data => edataclob);
      ELSE
        gl_business_events.raise(
          p_event_name => 'oracle.apps.gl.Maintenance.account.disable',
          p_event_key => ekey);
      END IF;
    END IF;
  END IF;


  UPDATE gl_code_combinations
  SET

    code_combination_id                       =    X_Code_Combination_Id,
    alternate_code_combination_id             =    X_Alt_Code_Combination_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    chart_of_accounts_id                      =    X_Chart_Of_Accounts_Id,
    detail_posting_allowed_flag               =    X_Detail_Posting_F,
    detail_budgeting_allowed_flag             =    X_Detail_Budgeting_F,
    igi_balanced_budget_flag                  =    X_Balanced_BudgetF,
    account_type                              =    X_Account_Type,
    enabled_flag                              =    X_Enabled_Flag,
    summary_flag                              =    X_Summary_Flag,
    segment1                                  =    X_Segment1,
    segment2                                  =    X_Segment2,
    segment3                                  =    X_Segment3,
    segment4                                  =    X_Segment4,
    segment5                                  =    X_Segment5,
    segment6                                  =    X_Segment6,
    segment7                                  =    X_Segment7,
    segment8                                  =    X_Segment8,
    segment9                                  =    X_Segment9,
    segment10                                 =    X_Segment10,
    segment11                                 =    X_Segment11,
    segment12                                 =    X_Segment12,
    segment13                                 =    X_Segment13,
    segment14                                 =    X_Segment14,
    segment15                                 =    X_Segment15,
    segment16                                 =    X_Segment16,
    segment17                                 =    X_Segment17,
    segment18                                 =    X_Segment18,
    segment19                                 =    X_Segment19,
    segment20                                 =    X_Segment20,
    segment21                                 =    X_Segment21,
    segment22                                 =    X_Segment22,
    segment23                                 =    X_Segment23,
    segment24                                 =    X_Segment24,
    segment25                                 =    X_Segment25,
    segment26                                 =    X_Segment26,
    segment27                                 =    X_Segment27,
    segment28                                 =    X_Segment28,
    segment29                                 =    X_Segment29,
    segment30                                 =    X_Segment30,
    description                               =    X_Description,
    template_id                               =    X_Template_Id,
    start_date_active                         =    X_Start_Date_Active,
    end_date_active                           =    X_End_Date_Active,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    context                                   =    X_Context,
    segment_attribute1                        =    X_Segment_Attribute1,
    segment_attribute2                        =    X_Segment_Attribute2,
    segment_attribute3                        =    X_Segment_Attribute3,
    segment_attribute4                        =    X_Segment_Attribute4,
    segment_attribute5                        =    X_Segment_Attribute5,
    segment_attribute6                        =    X_Segment_Attribute6,
    segment_attribute7                        =    X_Segment_Attribute7,
    segment_attribute8                        =    X_Segment_Attribute8,
    segment_attribute9                        =    X_Segment_Attribute9,
    segment_attribute10                       =    X_Segment_Attribute10,
    segment_attribute11                       =    X_Segment_Attribute11,
    segment_attribute12                       =    X_Segment_Attribute12,
    segment_attribute13                       =    X_Segment_Attribute13,
    segment_attribute14                       =    X_Segment_Attribute14,
    segment_attribute15                       =    X_Segment_Attribute15,
    segment_attribute16                       =    X_Segment_Attribute16,
    segment_attribute17                       =    X_Segment_Attribute17,
    segment_attribute18                       =    X_Segment_Attribute18,
    segment_attribute19                       =    X_Segment_Attribute19,
    segment_attribute20                       =    X_Segment_Attribute20,
    segment_attribute21                       =    X_Segment_Attribute21,
    segment_attribute22                       =    X_Segment_Attribute22,
    segment_attribute23                       =    X_Segment_Attribute23,
    segment_attribute24                       =    X_Segment_Attribute24,
    segment_attribute25                       =    X_Segment_Attribute25,
    segment_attribute26                       =    X_Segment_Attribute26,
    segment_attribute27                       =    X_Segment_Attribute27,
    segment_attribute28                       =    X_Segment_Attribute28,
    segment_attribute29                       =    X_Segment_Attribute29,
    segment_attribute30                       =    X_Segment_Attribute30,
    segment_attribute31                       =    X_Segment_Attribute31,
    segment_attribute32                       =    X_Segment_Attribute32,
    segment_attribute33                       =    X_Segment_Attribute33,
    segment_attribute34                       =    X_Segment_Attribute34,
    segment_attribute35                       =    X_Segment_Attribute35,
    segment_attribute36                       =    X_Segment_Attribute36,
    segment_attribute37                       =    X_Segment_Attribute37,
    segment_attribute38                       =    X_Segment_Attribute38,
    segment_attribute39                       =    X_Segment_Attribute39,
    segment_attribute40                       =    X_Segment_Attribute40,
    segment_attribute41                       =    X_Segment_Attribute41,
    segment_attribute42                       =    X_Segment_Attribute42,
    jgzz_recon_context                        =    X_Jgzz_Recon_Context,
    jgzz_recon_flag                           =    X_Jgzz_Recon_Flag,
    reference1                                =    X_reference1,
    reference2                                =    X_reference2,
    reference3                                =    X_reference3,
    reference4                                =    X_reference4,
    reference5                                =    X_reference5,
    preserve_flag                             =    X_preserve_flag,
    refresh_flag                              =    X_refresh_flag

  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_code_combinations
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

-- **********************************************************************

FUNCTION check_net_income_account(X_CCID NUMBER) RETURN BOOLEAN IS

 	CURSOR check_net_income_account IS
	  SELECT 'ccid exists'
	  FROM DUAL
	  WHERE EXISTS
              (SELECT 'X'
	       FROM GL_NET_INCOME_ACCOUNTS
	       WHERE code_combination_id = X_CCID);
dummy VARCHAR2(100);

BEGIN
OPEN check_net_income_account;
FETCH check_net_income_account INTO dummy;

IF check_net_income_account%FOUND THEN
   CLOSE check_net_income_account;
   RETURN ( TRUE );
ELSE
   CLOSE check_net_income_account;
   RETURN ( FALSE );
END IF;


END check_net_income_account;

-- **********************************************************************

PROCEDURE Get_Acct_Info(X_CCID 			IN	NUMBER,
			X_NET_INCOME_ACCT_FLAG	IN OUT NOCOPY	NUMBER,
			X_TEMPLATE_ID		IN OUT NOCOPY	NUMBER,
			X_ACCT_TYPE		IN OUT NOCOPY	VARCHAR2,
			X_SUMMARY_FLAG		IN OUT NOCOPY	VARCHAR2,
			X_REFRESH_FLAG		IN OUT NOCOPY	VARCHAR2,
			X_PRESERVE_FLAG		IN OUT NOCOPY	VARCHAR2,
                        X_ENABLED_FLAG          IN OUT NOCOPY   VARCHAR2) IS

  CURSOR get_acct_info IS
    SELECT NVL(account_type, 'XXX'), NVL(summary_flag, 'XXX'),
	   NVL(template_id, -1), NVL(refresh_flag, 'N'),
	   NVL(preserve_flag, 'N'), enabled_flag
    FROM GL_CODE_COMBINATIONS
    WHERE code_combination_id = X_CCID;

  ret_val		BOOLEAN := FALSE;

BEGIN
  ret_val := check_net_income_account(X_CCID);

  IF (ret_val = TRUE) THEN
    X_NET_INCOME_ACCT_FLAG := 1;
  ELSE
    X_NET_INCOME_ACCT_FLAG := 0;
  END IF;

  OPEN get_acct_info;
  FETCH get_acct_info INTO X_ACCT_TYPE, X_SUMMARY_FLAG, X_TEMPLATE_ID,
			   X_REFRESH_FLAG, X_PRESERVE_FLAG, X_ENABLED_FLAG;
  CLOSE get_acct_info;

END Get_Acct_Info;

-- **********************************************************************

FUNCTION Get_Ccid(X_COA_ID          	    	IN  NUMBER,
		  X_VALIDATION_DATE		IN  VARCHAR2,
		  X_CONCAT_SEGS          	IN  VARCHAR2) RETURN NUMBER IS

  return_value    BOOLEAN;
  rule            VARCHAR2(1000);
  where_clause    VARCHAR2(30);

BEGIN
   where_clause := 'SUMMARY_FLAG!=''Y''';

   rule := '\nSUMMARY_FLAG\nI\n' ||
           'APPL=SQLGL;NAME=GL_NO_PARENT_SEGMENT_ALLOWED\nN\0';

   return_value := fnd_flex_keyval.validate_segs('CREATE_COMBINATION','SQLGL',
                      'GL#', X_COA_ID, X_CONCAT_SEGS,
                      'V', sysdate, 'ALL', NULL, rule, where_clause,
                      NULL, FALSE, FALSE,
                      NULL, NULL, NULL, NULL, NULL, NULL);

   IF (return_value) THEN
      return (fnd_flex_keyval.combination_id);
   ELSE
      return (0);
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    fnd_message.set_token('PROCEDURE', 'GL_CODE_COMBINAITONS_PKG.Get_CCID');
    RAISE;
END Get_Ccid;

-- **********************************************************************

PROCEDURE Raise_Bus_Event(X_COA_ID              IN NUMBER,
                          X_CCID                IN  NUMBER) IS

  ekey             VARCHAR2(100);
  edata            VARCHAR2(200);
  edataclob        CLOB;
BEGIN

   /* Get event key */
   SELECT to_char(x_coa_id)||':'||
          to_char(sysdate, 'RRDDDSSSSS')||':'||
          to_char(x_ccid)
   INTO ekey
   FROM dual;

   /* Raise the disabled account event */
   IF (gl_business_events.test(
          'oracle.apps.gl.Maintenance.account.disable') = 'MESSAGE') THEN

       edata := '<?xml version="1.0"?> '||
                '<DisabledAccounts> ' ||
                '<CODE_COMBINATION_ID> '||
                to_char(x_ccid) ||
                 '</CODE_COMBINATION_ID> ' ||
                 '</DisabledAccounts> ';

        dbms_lob.createtemporary(edataclob, FALSE, DBMS_LOB.CALL);
        dbms_lob.write(edataclob, length(edata), 1, edata);

        gl_business_events.raise(
          p_event_name => 'oracle.apps.gl.Maintenance.account.disable',
          p_event_key => ekey,
          p_event_data => edataclob);
   ELSE
        gl_business_events.raise(
          p_event_name => 'oracle.apps.gl.Maintenance.account.disable',
          p_event_key => ekey);
   END IF;

END Raise_Bus_Event;


-- **********************************************************************

END GL_CODE_COMBINATIONS_PKG;

/
