--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_RANGE_INTERIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_RANGE_INTERIM_PKG" as
/* $Header: glibdrib.pls 120.4 2005/05/05 01:02:03 kvora ship $ */

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Period_Year                         NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Start_Period_Name                   VARCHAR2,
                     X_Start_Period_Num                    NUMBER,
                     X_Dr_Flag                             VARCHAR2,
                     X_Status_Number                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Period1_Amount                      NUMBER,
                     X_Period2_Amount                      NUMBER,
                     X_Period3_Amount                      NUMBER,
                     X_Period4_Amount                      NUMBER,
                     X_Period5_Amount                      NUMBER,
                     X_Period6_Amount                      NUMBER,
                     X_Period7_Amount                      NUMBER,
                     X_Period8_Amount                      NUMBER,
                     X_Period9_Amount                      NUMBER,
                     X_Period10_Amount                     NUMBER,
                     X_Period11_Amount                     NUMBER,
                     X_Period12_Amount                     NUMBER,
                     X_Period13_Amount                     NUMBER,
                     X_Old_Period1_Amount                  NUMBER,
                     X_Old_Period2_Amount                  NUMBER,
                     X_Old_Period3_Amount                  NUMBER,
                     X_Old_Period4_Amount                  NUMBER,
                     X_Old_Period5_Amount                  NUMBER,
                     X_Old_Period6_Amount                  NUMBER,
                     X_Old_Period7_Amount                  NUMBER,
                     X_Old_Period8_Amount                  NUMBER,
                     X_Old_Period9_Amount                  NUMBER,
                     X_Old_Period10_Amount                 NUMBER,
                     X_Old_Period11_Amount                 NUMBER,
                     X_Old_Period12_Amount                 NUMBER,
                     X_Old_Period13_Amount                 NUMBER,
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
                     X_Account_Type                        VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
		     X_Je_Drcr_Sign_Reference		   VARCHAR2,
		     X_Je_Line_Description1		   VARCHAR2,
		     X_Je_Line_Description2		   VARCHAR2,
		     X_Je_Line_Description3		   VARCHAR2,
		     X_Je_Line_Description4		   VARCHAR2,
		     X_Je_Line_Description5		   VARCHAR2,
		     X_Je_Line_Description6		   VARCHAR2,
		     X_Je_Line_Description7		   VARCHAR2,
		     X_Je_Line_Description8		   VARCHAR2,
		     X_Je_Line_Description9		   VARCHAR2,
		     X_Je_Line_Description10		   VARCHAR2,
		     X_Je_Line_Description11		   VARCHAR2,
		     X_Je_Line_Description12		   VARCHAR2,
		     X_Je_Line_Description13		   VARCHAR2,
		     X_Stat_Amount1			   NUMBER,
		     X_Stat_Amount2			   NUMBER,
		     X_Stat_Amount3			   NUMBER,
		     X_Stat_Amount4			   NUMBER,
		     X_Stat_Amount5			   NUMBER,
		     X_Stat_Amount6			   NUMBER,
		     X_Stat_Amount7			   NUMBER,
		     X_Stat_Amount8			   NUMBER,
		     X_Stat_Amount9			   NUMBER,
		     X_Stat_Amount10			   NUMBER,
		     X_Stat_Amount11			   NUMBER,
		     X_Stat_Amount12			   NUMBER,
		     X_Stat_Amount13			   NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM gl_budget_range_interim
             WHERE ledger_id = X_Ledger_Id
             AND   code_combination_id = X_Code_Combination_Id
             AND   currency_code = X_Currency_Code
             AND   budget_version_id = X_Budget_Version_Id
             AND   period_year = X_Period_Year
             AND   period_type = X_Period_Type
             AND   start_period_num = X_Start_Period_Num
	     AND   status_number = X_Status_Number;

BEGIN

  INSERT INTO gl_budget_range_interim(
          ledger_id,
          code_combination_id,
          currency_code,
          budget_version_id,
          budget_entity_id,
          period_year,
          period_type,
          start_period_name,
          start_period_num,
          dr_flag,
          status_number,
          last_update_date,
          last_updated_by,
          period1_amount,
          period2_amount,
          period3_amount,
          period4_amount,
          period5_amount,
          period6_amount,
          period7_amount,
          period8_amount,
          period9_amount,
          period10_amount,
          period11_amount,
          period12_amount,
          period13_amount,
          old_period1_amount,
          old_period2_amount,
          old_period3_amount,
          old_period4_amount,
          old_period5_amount,
          old_period6_amount,
          old_period7_amount,
          old_period8_amount,
          old_period9_amount,
          old_period10_amount,
          old_period11_amount,
          old_period12_amount,
          old_period13_amount,
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
          account_type,
          creation_date,
          created_by,
          last_update_login,
	  je_drcr_sign_reference,
	  je_line_description1,
	  je_line_description2,
	  je_line_description3,
	  je_line_description4,
	  je_line_description5,
	  je_line_description6,
	  je_line_description7,
	  je_line_description8,
	  je_line_description9,
	  je_line_description10,
	  je_line_description11,
	  je_line_description12,
	  je_line_description13,
	  stat_amount1,
	  stat_amount2,
	  stat_amount3,
	  stat_amount4,
	  stat_amount5,
	  stat_amount6,
	  stat_amount7,
	  stat_amount8,
	  stat_amount9,
	  stat_amount10,
	  stat_amount11,
	  stat_amount12,
	  stat_amount13
         ) VALUES (
          X_Ledger_Id,
          X_Code_Combination_Id,
          X_Currency_Code,
          X_Budget_Version_Id,
          X_Budget_Entity_Id,
          X_Period_Year,
          X_Period_Type,
          X_Start_Period_Name,
          X_Start_Period_Num,
          X_Dr_Flag,
          X_Status_Number,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Period1_Amount,
          X_Period2_Amount,
          X_Period3_Amount,
          X_Period4_Amount,
          X_Period5_Amount,
          X_Period6_Amount,
          X_Period7_Amount,
          X_Period8_Amount,
          X_Period9_Amount,
          X_Period10_Amount,
          X_Period11_Amount,
          X_Period12_Amount,
          X_Period13_Amount,
          X_Old_Period1_Amount,
          X_Old_Period2_Amount,
          X_Old_Period3_Amount,
          X_Old_Period4_Amount,
          X_Old_Period5_Amount,
          X_Old_Period6_Amount,
          X_Old_Period7_Amount,
          X_Old_Period8_Amount,
          X_Old_Period9_Amount,
          X_Old_Period10_Amount,
          X_Old_Period11_Amount,
          X_Old_Period12_Amount,
          X_Old_Period13_Amount,
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
          X_Account_Type,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
	  X_Je_Drcr_Sign_Reference,
	  X_Je_Line_Description1,
	  X_Je_Line_Description2,
	  X_Je_Line_Description3,
	  X_Je_Line_Description4,
	  X_Je_Line_Description5,
	  X_Je_Line_Description6,
	  X_Je_Line_Description7,
	  X_Je_Line_Description8,
	  X_Je_Line_Description9,
	  X_Je_Line_Description10,
	  X_Je_Line_Description11,
	  X_Je_Line_Description12,
	  X_Je_Line_Description13,
	  X_Stat_Amount1,
	  X_Stat_Amount2,
	  X_Stat_Amount3,
	  X_Stat_Amount4,
	  X_Stat_Amount5,
	  X_Stat_Amount6,
	  X_Stat_Amount7,
	  X_Stat_Amount8,
	  X_Stat_Amount9,
	  X_Stat_Amount10,
	  X_Stat_Amount11,
	  X_Stat_Amount12,
	  X_Stat_Amount13);

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Ledger_Id                             NUMBER,
                   X_Code_Combination_Id                   NUMBER,
                   X_Currency_Code                         VARCHAR2,
                   X_Budget_Version_Id                     NUMBER,
                   X_Budget_Entity_Id                      NUMBER,
                   X_Period_Year                           NUMBER,
                   X_Period_Type                           VARCHAR2,
                   X_Start_Period_Name                     VARCHAR2,
                   X_Start_Period_Num                      NUMBER,
                   X_Dr_Flag                               VARCHAR2,
                   X_Status_Number                         NUMBER,
                   X_Period1_Amount                        NUMBER,
                   X_Period2_Amount                        NUMBER,
                   X_Period3_Amount                        NUMBER,
                   X_Period4_Amount                        NUMBER,
                   X_Period5_Amount                        NUMBER,
                   X_Period6_Amount                        NUMBER,
                   X_Period7_Amount                        NUMBER,
                   X_Period8_Amount                        NUMBER,
                   X_Period9_Amount                        NUMBER,
                   X_Period10_Amount                       NUMBER,
                   X_Period11_Amount                       NUMBER,
                   X_Period12_Amount                       NUMBER,
                   X_Period13_Amount                       NUMBER,
                   X_Old_Period1_Amount                    NUMBER,
                   X_Old_Period2_Amount                    NUMBER,
                   X_Old_Period3_Amount                    NUMBER,
                   X_Old_Period4_Amount                    NUMBER,
                   X_Old_Period5_Amount                    NUMBER,
                   X_Old_Period6_Amount                    NUMBER,
                   X_Old_Period7_Amount                    NUMBER,
                   X_Old_Period8_Amount                    NUMBER,
                   X_Old_Period9_Amount                    NUMBER,
                   X_Old_Period10_Amount                   NUMBER,
                   X_Old_Period11_Amount                   NUMBER,
                   X_Old_Period12_Amount                   NUMBER,
                   X_Old_Period13_Amount                   NUMBER,
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
                   X_Account_Type                          VARCHAR2,
		   X_Je_Drcr_Sign_Reference		   VARCHAR2,
		   X_Je_Line_Description1		   VARCHAR2,
		   X_Je_Line_Description2		   VARCHAR2,
		   X_Je_Line_Description3		   VARCHAR2,
		   X_Je_Line_Description4		   VARCHAR2,
		   X_Je_Line_Description5		   VARCHAR2,
		   X_Je_Line_Description6		   VARCHAR2,
		   X_Je_Line_Description7		   VARCHAR2,
		   X_Je_Line_Description8		   VARCHAR2,
		   X_Je_Line_Description9		   VARCHAR2,
		   X_Je_Line_Description10		   VARCHAR2,
		   X_Je_Line_Description11		   VARCHAR2,
		   X_Je_Line_Description12		   VARCHAR2,
		   X_Je_Line_Description13		   VARCHAR2,
		   X_Stat_Amount1			   NUMBER,
		   X_Stat_Amount2			   NUMBER,
		   X_Stat_Amount3			   NUMBER,
		   X_Stat_Amount4			   NUMBER,
		   X_Stat_Amount5			   NUMBER,
		   X_Stat_Amount6			   NUMBER,
		   X_Stat_Amount7			   NUMBER,
		   X_Stat_Amount8			   NUMBER,
		   X_Stat_Amount9			   NUMBER,
		   X_Stat_Amount10			   NUMBER,
		   X_Stat_Amount11			   NUMBER,
		   X_Stat_Amount12			   NUMBER,
		   X_Stat_Amount13			   NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   gl_budget_range_interim
      WHERE  rowid = X_Rowid
      FOR UPDATE of Ledger_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.budget_entity_id = X_Budget_Entity_Id)
           OR (    (Recinfo.budget_entity_id IS NULL)
               AND (X_Budget_Entity_Id IS NULL)))
      AND (   (Recinfo.period_year = X_Period_Year)
           OR (    (Recinfo.period_year IS NULL)
               AND (X_Period_Year IS NULL)))
      AND (   (Recinfo.period_type = X_Period_Type)
           OR (    (Recinfo.period_type IS NULL)
               AND (X_Period_Type IS NULL)))
      AND (   (Recinfo.start_period_name = X_Start_Period_Name)
           OR (    (Recinfo.start_period_name IS NULL)
               AND (X_Start_Period_Name IS NULL)))
      AND (   (Recinfo.start_period_num = X_Start_Period_Num)
           OR (    (Recinfo.start_period_num IS NULL)
               AND (X_Start_Period_Num IS NULL)))
      AND (   (Recinfo.dr_flag = X_Dr_Flag)
           OR (    (Recinfo.dr_flag IS NULL)
               AND (X_Dr_Flag IS NULL)))
      AND (   (Recinfo.status_number = X_Status_Number)
           OR (    (Recinfo.status_number IS NULL)
               AND (X_Status_Number IS NULL)))
      AND (   (nvl(Recinfo.period1_amount,0)
                   - nvl(Recinfo.old_period1_amount,0)
                 = nvl(X_Period1_Amount,0)
                   - nvl(X_old_period1_amount,0)))
      AND (   (nvl(Recinfo.period2_amount,0)
                   - nvl(Recinfo.old_period2_amount,0)
                 = nvl(X_Period2_Amount,0)
                   - nvl(X_old_period2_amount,0)))
      AND (   (nvl(Recinfo.period3_amount,0)
                   - nvl(Recinfo.old_period3_amount,0)
                 = nvl(X_Period3_Amount,0)
                   - nvl(X_old_period3_amount,0)))
      AND (   (nvl(Recinfo.period4_amount,0)
                   - nvl(Recinfo.old_period4_amount,0)
                 = nvl(X_Period4_Amount,0)
                   - nvl(X_old_period4_amount,0)))
      AND (   (nvl(Recinfo.period5_amount,0)
                   - nvl(Recinfo.old_period5_amount,0)
                 = nvl(X_Period5_Amount,0)
                   - nvl(X_old_period5_amount,0)))
      AND (   (nvl(Recinfo.period6_amount,0)
                   - nvl(Recinfo.old_period6_amount,0)
                 = nvl(X_Period6_Amount,0)
                   - nvl(X_old_period6_amount,0)))
      AND (   (nvl(Recinfo.period7_amount,0)
                   - nvl(Recinfo.old_period7_amount,0)
                 = nvl(X_Period7_Amount,0)
                   - nvl(X_old_period7_amount,0)))
      AND (   (nvl(Recinfo.period8_amount,0)
                   - nvl(Recinfo.old_period8_amount,0)
                 = nvl(X_Period8_Amount,0)
                   - nvl(X_old_period8_amount,0)))
      AND (   (nvl(Recinfo.period9_amount,0)
                   - nvl(Recinfo.old_period9_amount,0)
                 = nvl(X_Period9_Amount,0)
                   - nvl(X_old_period9_amount,0)))
      AND (   (nvl(Recinfo.period10_amount,0)
                   - nvl(Recinfo.old_period10_amount,0)
                 = nvl(X_Period10_Amount,0)
                   - nvl(X_old_period10_amount,0)))
      AND (   (nvl(Recinfo.period11_amount,0)
                   - nvl(Recinfo.old_period11_amount,0)
                 = nvl(X_Period11_Amount,0)
                   - nvl(X_old_period11_amount,0)))
      AND (   (nvl(Recinfo.period12_amount,0)
                   - nvl(Recinfo.old_period12_amount,0)
                 = nvl(X_Period12_Amount,0)
                   - nvl(X_old_period12_amount,0)))
      AND (   (nvl(Recinfo.period13_amount,0)
                   - nvl(Recinfo.old_period13_amount,0)
                 = nvl(X_Period13_Amount,0)
                   - nvl(X_old_period13_amount,0)))
          ) then
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  if (
          (   (Recinfo.segment1 = X_Segment1)
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
               AND (X_Segment26 IS NULL)))
      AND (   (Recinfo.segment27 = X_Segment27)
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
      AND (   (Recinfo.account_type = X_Account_Type)
           OR (    (Recinfo.account_type IS NULL)
               AND (X_Account_Type IS NULL)))
          ) then
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  if (
          (   (Recinfo.je_drcr_sign_reference = X_Je_Drcr_Sign_Reference)
           OR (    (Recinfo.je_drcr_sign_reference IS NULL)
               AND (X_Je_Drcr_Sign_Reference IS NULL)))
      AND (   (Recinfo.je_line_description1 = X_Je_Line_Description1)
           OR (    (Recinfo.je_line_description1 IS NULL)
               AND (X_Je_Line_Description1 IS NULL)))
      AND (   (Recinfo.je_line_description2 = X_Je_Line_Description2)
           OR (    (Recinfo.je_line_description2 IS NULL)
               AND (X_Je_Line_Description2 IS NULL)))
      AND (   (Recinfo.je_line_description3 = X_Je_Line_Description3)
           OR (    (Recinfo.je_line_description3 IS NULL)
               AND (X_Je_Line_Description3 IS NULL)))
      AND (   (Recinfo.je_line_description4 = X_Je_Line_Description4)
           OR (    (Recinfo.je_line_description4 IS NULL)
               AND (X_Je_Line_Description4 IS NULL)))
      AND (   (Recinfo.je_line_description5 = X_Je_Line_Description5)
           OR (    (Recinfo.je_line_description5 IS NULL)
               AND (X_Je_Line_Description5 IS NULL)))
      AND (   (Recinfo.je_line_description6 = X_Je_Line_Description6)
           OR (    (Recinfo.je_line_description6 IS NULL)
               AND (X_Je_Line_Description6 IS NULL)))
      AND (   (Recinfo.je_line_description7 = X_Je_Line_Description7)
           OR (    (Recinfo.je_line_description7 IS NULL)
               AND (X_Je_Line_Description7 IS NULL)))
      AND (   (Recinfo.je_line_description8 = X_Je_Line_Description8)
           OR (    (Recinfo.je_line_description8 IS NULL)
               AND (X_Je_Line_Description8 IS NULL)))
      AND (   (Recinfo.je_line_description9 = X_Je_Line_Description9)
           OR (    (Recinfo.je_line_description9 IS NULL)
               AND (X_Je_Line_Description9 IS NULL)))
      AND (   (Recinfo.je_line_description10 = X_Je_Line_Description10)
           OR (    (Recinfo.je_line_description10 IS NULL)
               AND (X_Je_Line_Description10 IS NULL)))
      AND (   (Recinfo.je_line_description11 = X_Je_Line_Description11)
           OR (    (Recinfo.je_line_description11 IS NULL)
               AND (X_Je_Line_Description11 IS NULL)))
      AND (   (Recinfo.je_line_description12 = X_Je_Line_Description12)
           OR (    (Recinfo.je_line_description12 IS NULL)
               AND (X_Je_Line_Description12 IS NULL)))
      AND (   (Recinfo.je_line_description13 = X_Je_Line_Description13)
           OR (    (Recinfo.je_line_description13 IS NULL)
               AND (X_Je_Line_Description13 IS NULL)))
      AND (   (Recinfo.stat_amount1 = X_Stat_Amount1)
           OR (    (Recinfo.stat_amount1 IS NULL)
               AND (X_Stat_Amount1 IS NULL)))
      AND (   (Recinfo.stat_amount2 = X_Stat_Amount2)
           OR (    (Recinfo.stat_amount2 IS NULL)
               AND (X_Stat_Amount2 IS NULL)))
      AND (   (Recinfo.stat_amount3 = X_Stat_Amount3)
           OR (    (Recinfo.stat_amount3 IS NULL)
               AND (X_Stat_Amount3 IS NULL)))
      AND (   (Recinfo.stat_amount4 = X_Stat_Amount4)
           OR (    (Recinfo.stat_amount4 IS NULL)
               AND (X_Stat_Amount4 IS NULL)))
      AND (   (Recinfo.stat_amount5 = X_Stat_Amount5)
           OR (    (Recinfo.stat_amount5 IS NULL)
               AND (X_Stat_Amount5 IS NULL)))
      AND (   (Recinfo.stat_amount6 = X_Stat_Amount6)
           OR (    (Recinfo.stat_amount6 IS NULL)
               AND (X_Stat_Amount6 IS NULL)))
      AND (   (Recinfo.stat_amount7 = X_Stat_Amount7)
           OR (    (Recinfo.stat_amount7 IS NULL)
               AND (X_Stat_Amount7 IS NULL)))
      AND (   (Recinfo.stat_amount8 = X_Stat_Amount8)
           OR (    (Recinfo.stat_amount8 IS NULL)
               AND (X_Stat_Amount8 IS NULL)))
      AND (   (Recinfo.stat_amount9 = X_Stat_Amount9)
           OR (    (Recinfo.stat_amount9 IS NULL)
               AND (X_Stat_Amount9 IS NULL)))
      AND (   (Recinfo.stat_amount10 = X_Stat_Amount10)
           OR (    (Recinfo.stat_amount10 IS NULL)
               AND (X_Stat_Amount10 IS NULL)))
      AND (   (Recinfo.stat_amount11 = X_Stat_Amount11)
           OR (    (Recinfo.stat_amount11 IS NULL)
               AND (X_Stat_Amount11 IS NULL)))
      AND (   (Recinfo.stat_amount12 = X_Stat_Amount12)
           OR (    (Recinfo.stat_amount12 IS NULL)
               AND (X_Stat_Amount12 IS NULL)))
      AND (   (Recinfo.stat_amount13 = X_Stat_Amount13)
           OR (    (Recinfo.stat_amount13 IS NULL)
               AND (X_Stat_Amount13 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Code_Combination_Id                 NUMBER,
                     X_Currency_Code                       VARCHAR2,
                     X_Budget_Version_Id                   NUMBER,
                     X_Budget_Entity_Id                    NUMBER,
                     X_Period_Year                         NUMBER,
                     X_Period_Type                         VARCHAR2,
                     X_Start_Period_Name                   VARCHAR2,
                     X_Start_Period_Num                    NUMBER,
                     X_Dr_Flag                             VARCHAR2,
                     X_Status_Number                       NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Period1_Amount                      NUMBER,
                     X_Period2_Amount                      NUMBER,
                     X_Period3_Amount                      NUMBER,
                     X_Period4_Amount                      NUMBER,
                     X_Period5_Amount                      NUMBER,
                     X_Period6_Amount                      NUMBER,
                     X_Period7_Amount                      NUMBER,
                     X_Period8_Amount                      NUMBER,
                     X_Period9_Amount                      NUMBER,
                     X_Period10_Amount                     NUMBER,
                     X_Period11_Amount                     NUMBER,
                     X_Period12_Amount                     NUMBER,
                     X_Period13_Amount                     NUMBER,
                     X_Old_Period1_Amount                  NUMBER,
                     X_Old_Period2_Amount                  NUMBER,
                     X_Old_Period3_Amount                  NUMBER,
                     X_Old_Period4_Amount                  NUMBER,
                     X_Old_Period5_Amount                  NUMBER,
                     X_Old_Period6_Amount                  NUMBER,
                     X_Old_Period7_Amount                  NUMBER,
                     X_Old_Period8_Amount                  NUMBER,
                     X_Old_Period9_Amount                  NUMBER,
                     X_Old_Period10_Amount                 NUMBER,
                     X_Old_Period11_Amount                 NUMBER,
                     X_Old_Period12_Amount                 NUMBER,
                     X_Old_Period13_Amount                 NUMBER,
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
                     X_Account_Type                        VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
		     X_Je_Drcr_Sign_Reference		   VARCHAR2,
		     X_Je_Line_Description1		   VARCHAR2,
		     X_Je_Line_Description2		   VARCHAR2,
		     X_Je_Line_Description3		   VARCHAR2,
		     X_Je_Line_Description4		   VARCHAR2,
		     X_Je_Line_Description5		   VARCHAR2,
		     X_Je_Line_Description6		   VARCHAR2,
		     X_Je_Line_Description7		   VARCHAR2,
		     X_Je_Line_Description8		   VARCHAR2,
		     X_Je_Line_Description9		   VARCHAR2,
		     X_Je_Line_Description10		   VARCHAR2,
		     X_Je_Line_Description11		   VARCHAR2,
		     X_Je_Line_Description12		   VARCHAR2,
		     X_Je_Line_Description13		   VARCHAR2,
		     X_Stat_Amount1			   NUMBER,
		     X_Stat_Amount2			   NUMBER,
		     X_Stat_Amount3			   NUMBER,
		     X_Stat_Amount4			   NUMBER,
		     X_Stat_Amount5			   NUMBER,
		     X_Stat_Amount6			   NUMBER,
		     X_Stat_Amount7			   NUMBER,
		     X_Stat_Amount8			   NUMBER,
		     X_Stat_Amount9			   NUMBER,
		     X_Stat_Amount10			   NUMBER,
		     X_Stat_Amount11			   NUMBER,
		     X_Stat_Amount12			   NUMBER,
		     X_Stat_Amount13			   NUMBER
) IS
BEGIN
  UPDATE gl_budget_range_interim
  SET
    ledger_id                                 =    X_Ledger_Id,
    code_combination_id                       =    X_Code_Combination_Id,
    currency_code                             =    X_Currency_Code,
    budget_version_id                         =    X_Budget_Version_Id,
    budget_entity_id                          =    X_Budget_Entity_Id,
    period_year                               =    X_Period_Year,
    period_type                               =    X_Period_Type,
    start_period_name                         =    X_Start_Period_Name,
    start_period_num                          =    X_Start_Period_Num,
    dr_flag                                   =    X_Dr_Flag,
    status_number                             =    X_Status_Number,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    period1_amount                            =    X_Period1_Amount,
    period2_amount                            =    X_Period2_Amount,
    period3_amount                            =    X_Period3_Amount,
    period4_amount                            =    X_Period4_Amount,
    period5_amount                            =    X_Period5_Amount,
    period6_amount                            =    X_Period6_Amount,
    period7_amount                            =    X_Period7_Amount,
    period8_amount                            =    X_Period8_Amount,
    period9_amount                            =    X_Period9_Amount,
    period10_amount                           =    X_Period10_Amount,
    period11_amount                           =    X_Period11_Amount,
    period12_amount                           =    X_Period12_Amount,
    period13_amount                           =    X_Period13_Amount,
    old_period1_amount                        =    X_Old_Period1_Amount,
    old_period2_amount                        =    X_Old_Period2_Amount,
    old_period3_amount                        =    X_Old_Period3_Amount,
    old_period4_amount                        =    X_Old_Period4_Amount,
    old_period5_amount                        =    X_Old_Period5_Amount,
    old_period6_amount                        =    X_Old_Period6_Amount,
    old_period7_amount                        =    X_Old_Period7_Amount,
    old_period8_amount                        =    X_Old_Period8_Amount,
    old_period9_amount                        =    X_Old_Period9_Amount,
    old_period10_amount                       =    X_Old_Period10_Amount,
    old_period11_amount                       =    X_Old_Period11_Amount,
    old_period12_amount                       =    X_Old_Period12_Amount,
    old_period13_amount                       =    X_Old_Period13_Amount,
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
    account_type                              =    X_Account_Type,
    last_update_login                         =    X_Last_Update_Login,
    je_drcr_sign_reference		      =    X_Je_Drcr_Sign_Reference,
    je_line_description1		      =    X_Je_Line_Description1,
    je_line_description2		      =    X_Je_Line_Description2,
    je_line_description3		      =    X_Je_Line_Description3,
    je_line_description4		      =    X_Je_Line_Description4,
    je_line_description5		      =    X_Je_Line_Description5,
    je_line_description6		      =    X_Je_Line_Description6,
    je_line_description7		      =    X_Je_Line_Description7,
    je_line_description8		      =    X_Je_Line_Description8,
    je_line_description9		      =    X_Je_Line_Description9,
    je_line_description10		      =    X_Je_Line_Description10,
    je_line_description11		      =    X_Je_Line_Description11,
    je_line_description12		      =    X_Je_Line_Description12,
    je_line_description13		      =    X_Je_Line_Description13,
    stat_amount1			      =    X_Stat_Amount1,
    stat_amount2			      =    X_Stat_Amount2,
    stat_amount3			      =    X_Stat_Amount3,
    stat_amount4			      =    X_Stat_Amount4,
    stat_amount5			      =    X_Stat_Amount5,
    stat_amount6			      =    X_Stat_Amount6,
    stat_amount7			      =    X_Stat_Amount7,
    stat_amount8			      =    X_Stat_Amount8,
    stat_amount9			      =    X_Stat_Amount9,
    stat_amount10			      =    X_Stat_Amount10,
    stat_amount11			      =    X_Stat_Amount11,
    stat_amount12			      =    X_Stat_Amount12,
    stat_amount13			      =    X_Stat_Amount13
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM gl_budget_range_interim
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END GL_BUDGET_RANGE_INTERIM_PKG;

/
