--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_RANGES_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_RANGES_SS_PKG" as
-- $Header: igiitrib.pls 120.5.12000000.1 2007/09/12 10:31:25 mbremkum ship $

  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Charge_Range_Id                NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Authoriser_Id                  NUMBER,
                       X_Employee_Id                    NUMBER,
                       X_Active_Flag                    VARCHAR2,
                       X_Segment1_Low                   VARCHAR2,
                       X_Segment2_Low                   VARCHAR2,
                       X_Segment3_Low                   VARCHAR2,
                       X_Segment4_Low                   VARCHAR2,
                       X_Segment5_Low                   VARCHAR2,
                       X_Segment6_Low                   VARCHAR2,
                       X_Segment7_Low                   VARCHAR2,
                       X_Segment8_Low                   VARCHAR2,
                       X_Segment9_Low                   VARCHAR2,
                       X_Segment10_Low                  VARCHAR2,
                       X_Segment11_Low                  VARCHAR2,
                       X_Segment12_Low                  VARCHAR2,
                       X_Segment13_Low                  VARCHAR2,
                       X_Segment14_Low                  VARCHAR2,
                       X_Segment15_Low                  VARCHAR2,
                       X_Segment16_Low                  VARCHAR2,
                       X_Segment17_Low                  VARCHAR2,
                       X_Segment18_Low                  VARCHAR2,
                       X_Segment19_Low                  VARCHAR2,
                       X_Segment20_Low                  VARCHAR2,
                       X_Segment21_Low                  VARCHAR2,
                       X_Segment22_Low                  VARCHAR2,
                       X_Segment23_Low                  VARCHAR2,
                       X_Segment24_Low                  VARCHAR2,
                       X_Segment25_Low                  VARCHAR2,
                       X_Segment26_Low                  VARCHAR2,
                       X_Segment27_Low                  VARCHAR2,
                       X_Segment28_Low                  VARCHAR2,
                       X_Segment29_Low                  VARCHAR2,
                       X_Segment30_Low                  VARCHAR2,
                       X_Segment1_High                  VARCHAR2,
                       X_Segment2_High                  VARCHAR2,
                       X_Segment3_High                  VARCHAR2,
                       X_Segment4_High                  VARCHAR2,
                       X_Segment5_High                  VARCHAR2,
                       X_Segment6_High                  VARCHAR2,
                       X_Segment7_High                  VARCHAR2,
                       X_Segment8_High                  VARCHAR2,
                       X_Segment9_High                  VARCHAR2,
                       X_Segment10_High                  VARCHAR2,
                       X_Segment11_High                  VARCHAR2,
                       X_Segment12_High                  VARCHAR2,
                       X_Segment13_High                  VARCHAR2,
                       X_Segment14_High                  VARCHAR2,
                       X_Segment15_High                  VARCHAR2,
                       X_Segment16_High                  VARCHAR2,
                       X_Segment17_High                  VARCHAR2,
                       X_Segment18_High                  VARCHAR2,
                       X_Segment19_High                  VARCHAR2,
                       X_Segment20_High                  VARCHAR2,
                       X_Segment21_High                  VARCHAR2,
                       X_Segment22_High                  VARCHAR2,
                       X_Segment23_High                  VARCHAR2,
                       X_Segment24_High                  VARCHAR2,
                       X_Segment25_High                  VARCHAR2,
                       X_Segment26_High                  VARCHAR2,
                       X_Segment27_High                  VARCHAR2,
                       X_Segment28_High                  VARCHAR2,
                       X_Segment29_High                  VARCHAR2,
                       X_Segment30_High                  VARCHAR2,
	               X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_ITR_CHARGE_RANGES
                 WHERE charge_range_id = X_Charge_Range_Id
                 AND   charge_center_id = X_Charge_Center_Id;
   BEGIN
       INSERT INTO IGI_ITR_CHARGE_RANGES(
              charge_range_id,
              charge_center_id,
              authoriser_id,
              employee_id,
              active_flag,
	      segment1_low,
	      segment2_low,
              segment3_low,
              segment4_low,
              segment5_low,
              segment6_low,
              segment7_low,
              segment8_low,
              segment9_low,
              segment10_low,
              segment11_low,
              segment12_low,
              segment13_low,
              segment14_low,
              segment15_low,
              segment16_low,
              segment17_low,
              segment18_low,
              segment19_low,
              segment20_low,
              segment21_low,
              segment22_low,
              segment23_low,
              segment24_low,
              segment25_low,
              segment26_low,
              segment27_low,
              segment28_low,
              segment29_low,
              segment30_low,
              segment1_high,
	      segment2_high,
	      segment3_high,
	      segment4_high,
	      segment5_high,
	      segment6_high,
              segment7_high,
	      segment8_high,
	      segment9_high,
	      segment10_high,
	      segment11_high,
	      segment12_high,
   	      segment13_high,
	      segment14_high,
  	      segment15_high,
	      segment16_high,
	      segment17_high,
	      segment18_high,
	      segment19_high,
              segment20_high,
 	      segment21_high,
      	      segment22_high,
  	      segment23_high,
	      segment24_high,
  	      segment25_high,
	      segment26_high,
	      segment27_high,
	      segment28_high,
 	      segment29_high,
	      segment30_high,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Charge_Range_Id,
              X_Charge_Center_Id,
              X_Authoriser_Id,
              X_Employee_Id,
              X_Active_Flag,
              X_Segment1_Low,
              X_Segment2_Low,
              X_Segment3_Low,
              X_Segment4_Low,
              X_Segment5_Low,
              X_Segment6_Low,
              X_Segment7_Low,
              X_Segment8_Low,
              X_Segment9_Low,
              X_Segment10_Low,
              X_Segment11_Low,
              X_Segment12_Low,
              X_Segment13_Low,
              X_Segment14_Low,
              X_Segment15_Low,
              X_Segment16_Low,
              X_Segment17_Low,
              X_Segment18_Low,
              X_Segment19_Low,
              X_Segment20_Low,
              X_Segment21_Low,
              X_Segment22_Low,
              X_Segment23_Low,
              X_Segment24_Low,
              X_Segment25_Low,
              X_Segment26_Low,
              X_Segment27_Low,
              X_Segment28_Low,
              X_Segment29_Low,
              X_Segment30_Low,
              X_Segment1_High,
              X_Segment2_High,
              X_Segment3_High,
              X_Segment4_High,
              X_Segment5_High,
              X_Segment6_High,
              X_Segment7_High,
              X_Segment8_High,
              X_Segment9_High,
              X_Segment10_High,
              X_Segment11_High,
              X_Segment12_High,
              X_Segment13_High,
              X_Segment14_High,
              X_Segment15_High,
              X_Segment16_High,
              X_Segment17_High,
              X_Segment18_High,
              X_Segment19_High,
              X_Segment20_High,
              X_Segment21_High,
              X_Segment22_High,
              X_Segment23_High,
              X_Segment24_High,
              X_Segment25_High,
              X_Segment26_High,
              X_Segment27_High,
              X_Segment28_High,
              X_Segment29_High,
              X_Segment30_High,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login
             );
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;

  PROCEDURE Lock_Row(  X_Rowid                          VARCHAR2,
                       X_Charge_Range_Id                NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Authoriser_Id                  NUMBER,
                       X_Employee_id                    NUMBER,
                       X_Active_Flag                    VARCHAR2,
                       X_Segment1_Low                   VARCHAR2,
                       X_Segment2_Low                   VARCHAR2,
                       X_Segment3_Low                   VARCHAR2,
                       X_Segment4_Low                   VARCHAR2,
                       X_Segment5_Low                   VARCHAR2,
                       X_Segment6_Low                   VARCHAR2,
                       X_Segment7_Low                   VARCHAR2,
                       X_Segment8_Low                   VARCHAR2,
                       X_Segment9_Low                   VARCHAR2,
                       X_Segment10_Low                  VARCHAR2,
                       X_Segment11_Low                  VARCHAR2,
                       X_Segment12_Low                  VARCHAR2,
                       X_Segment13_Low                  VARCHAR2,
                       X_Segment14_Low                  VARCHAR2,
                       X_Segment15_Low                  VARCHAR2,
                       X_Segment16_Low                  VARCHAR2,
                       X_Segment17_Low                  VARCHAR2,
                       X_Segment18_Low                  VARCHAR2,
                       X_Segment19_Low                  VARCHAR2,
                       X_Segment20_Low                  VARCHAR2,
                       X_Segment21_Low                  VARCHAR2,
                       X_Segment22_Low                  VARCHAR2,
                       X_Segment23_Low                  VARCHAR2,
                       X_Segment24_Low                  VARCHAR2,
                       X_Segment25_Low                  VARCHAR2,
                       X_Segment26_Low                  VARCHAR2,
                       X_Segment27_Low                  VARCHAR2,
                       X_Segment28_Low                  VARCHAR2,
                       X_Segment29_Low                  VARCHAR2,
                       X_Segment30_Low                  VARCHAR2,
                       X_Segment1_High                  VARCHAR2,
                       X_Segment2_High                  VARCHAR2,
                       X_Segment3_High                  VARCHAR2,
                       X_Segment4_High                  VARCHAR2,
                       X_Segment5_High                  VARCHAR2,
                       X_Segment6_High                  VARCHAR2,
                       X_Segment7_High                  VARCHAR2,
                       X_Segment8_High                  VARCHAR2,
                       X_Segment9_High                  VARCHAR2,
                       X_Segment10_High                  VARCHAR2,
                       X_Segment11_High                  VARCHAR2,
                       X_Segment12_High                  VARCHAR2,
                       X_Segment13_High                  VARCHAR2,
                       X_Segment14_High                  VARCHAR2,
                       X_Segment15_High                  VARCHAR2,
                       X_Segment16_High                  VARCHAR2,
                       X_Segment17_High                  VARCHAR2,
                       X_Segment18_High                  VARCHAR2,
                       X_Segment19_High                  VARCHAR2,
                       X_Segment20_High                  VARCHAR2,
                       X_Segment21_High                  VARCHAR2,
                       X_Segment22_High                  VARCHAR2,
                       X_Segment23_High                  VARCHAR2,
                       X_Segment24_High                  VARCHAR2,
                       X_Segment25_High                  VARCHAR2,
                       X_Segment26_High                  VARCHAR2,
                       X_Segment27_High                  VARCHAR2,
                       X_Segment28_High                  VARCHAR2,
                       X_Segment29_High                  VARCHAR2,
                       X_Segment30_High                  VARCHAR2
 ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_ITR_CHARGE_RANGES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Charge_Range_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrib.IGI_ITR_CHARGE_RANGES_SS_PKG.lock_row.msg1', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.charge_range_id =  X_Charge_Range_Id)
           AND (Recinfo.charge_center_id =  X_Charge_Center_Id)
           AND (Recinfo.authoriser_id  = X_Authoriser_Id)
           AND (Recinfo.employee_id    = X_Employee_id)
           AND (Recinfo.Active_Flag    = X_Active_Flag)
           AND (  NVL(Recinfo.segment1_low,'x') = nvl(X_Segment1_Low,'x'))
           AND (nvl(Recinfo.segment1_high,'x') = nvl(X_Segment1_High,'x'))
           AND (nvl(Recinfo.segment2_low,'x') =  nvl(X_Segment2_Low,'x'))
           AND (nvl(Recinfo.segment2_high,'x') = nvl(X_Segment2_High,'x'))
           AND (nvl(Recinfo.segment3_low,'x') =  nvl(X_Segment3_Low,'x'))
           AND (nvl(Recinfo.segment3_high,'x') = nvl(X_Segment3_High,'x'))
           AND (nvl(Recinfo.segment4_low,'x') = nvl(X_Segment4_Low,'x'))
           AND (nvl(Recinfo.segment4_high,'x') = nvl(X_Segment4_High,'x'))
           AND (nvl(Recinfo.segment5_low,'x') =  nvl(X_Segment5_Low,'x'))
           AND (nvl(Recinfo.segment5_high,'x') =  nvl(X_Segment5_High,'x'))
           AND (nvl(Recinfo.segment6_low,'x') =  nvl(X_Segment6_Low,'x'))
           AND (nvl(Recinfo.segment6_high,'x') =  nvl(X_Segment6_High,'x'))
           AND (nvl(Recinfo.segment7_low,'x') =  nvl(X_Segment7_Low,'x'))
           AND (nvl(Recinfo.segment7_high,'x') =  nvl(X_Segment7_High,'x'))
           AND (nvl(Recinfo.segment8_low,'x') =  nvl(X_Segment8_Low,'x'))
           AND (nvl(Recinfo.segment8_high,'x') =  nvl(X_Segment8_High,'x'))
           AND (nvl(Recinfo.segment9_low,'x') =  nvl(X_Segment9_Low,'x'))
           AND (nvl(Recinfo.segment9_high,'x') =  nvl(X_Segment9_High,'x'))
           AND (nvl(Recinfo.segment10_low,'x') =  nvl(X_Segment10_Low,'x'))
           AND (nvl(Recinfo.segment10_high,'x') =  nvl(X_Segment10_High,'x'))
           AND (nvl(Recinfo.segment11_low,'x') =  nvl(X_Segment11_Low,'x'))
           AND (nvl(Recinfo.segment11_high,'x') =  nvl(X_Segment11_High,'x'))
           AND (nvl(Recinfo.segment12_low,'x') =  nvl(X_Segment12_Low,'x'))
           AND (nvl(Recinfo.segment12_high,'x') =  nvl(X_Segment12_High,'x'))
           AND (nvl(Recinfo.segment13_low,'x') =  nvl(X_Segment13_Low,'x'))
           AND (nvl(Recinfo.segment13_high,'x') =  nvl(X_Segment13_High,'x'))
           AND (nvl(Recinfo.segment14_low,'x') =  nvl(X_Segment14_Low,'x'))
           AND (nvl(Recinfo.segment14_high,'x') =  nvl(X_Segment14_High,'x'))
           AND (nvl(Recinfo.segment15_low,'x') =  nvl(X_Segment15_Low,'x'))
           AND (nvl(Recinfo.segment15_high,'x') =  nvl(X_Segment15_High,'x'))
           AND (nvl(Recinfo.segment16_low,'x') =  nvl(X_Segment16_Low,'x'))
           AND (nvl(Recinfo.segment16_high,'x') =  nvl(X_Segment16_High,'x'))
           AND (nvl(Recinfo.segment17_low,'x') =  nvl(X_Segment17_Low,'x'))
           AND (nvl(Recinfo.segment17_high,'x') =  nvl(X_Segment17_High,'x'))
           AND (nvl(Recinfo.segment18_low,'x') =  nvl(X_Segment18_Low,'x'))
           AND (nvl(Recinfo.segment18_high,'x') =  nvl(X_Segment18_High,'x'))
           AND (nvl(Recinfo.segment19_low,'x') =  nvl(X_Segment19_Low,'x'))
           AND (nvl(Recinfo.segment19_high,'x') =  nvl(X_Segment19_High,'x'))
           AND (nvl(Recinfo.segment20_low,'x') =  nvl(X_Segment20_Low,'x'))
           AND (nvl(Recinfo.segment20_high,'x') =  nvl(X_Segment20_High,'x'))
           AND (nvl(Recinfo.segment21_low,'x') =  nvl(X_Segment21_Low,'x'))
           AND (nvl(Recinfo.segment21_high,'x') =  nvl(X_Segment21_High,'x'))
           AND (nvl(Recinfo.segment22_low,'x') =  nvl(X_Segment22_Low,'x'))
           AND (nvl(Recinfo.segment22_high,'x') =  nvl(X_Segment22_High,'x'))
           AND (nvl(Recinfo.segment23_low,'x') =  nvl(X_Segment23_Low,'x'))
           AND (nvl(Recinfo.segment23_high,'x') =  nvl(X_Segment23_High,'x'))
           AND (nvl(Recinfo.segment24_low,'x') =  nvl(X_Segment24_Low,'x'))
           AND (nvl(Recinfo.segment24_high,'x') =  nvl(X_Segment24_High,'x'))
           AND (nvl(Recinfo.segment25_low,'x') =  nvl(X_Segment25_Low,'x'))
           AND (nvl(Recinfo.segment25_high,'x') =  nvl(X_Segment25_High,'x'))
           AND (nvl(Recinfo.segment26_low,'x') =  nvl(X_Segment26_Low,'x'))
           AND (nvl(Recinfo.segment26_high,'x') =  nvl(X_Segment26_High,'x'))
           AND (nvl(Recinfo.segment27_low,'x') =  nvl(X_Segment27_Low,'x'))
           AND (nvl(Recinfo.segment27_high,'x') =  nvl(X_Segment27_High,'x'))
           AND (nvl(Recinfo.segment28_low,'x') =  nvl(X_Segment28_Low,'x'))
           AND (nvl(Recinfo.segment28_high,'x') =  nvl(X_Segment28_High,'x'))
           AND (nvl(Recinfo.segment29_low,'x') =  nvl(X_Segment29_Low,'x'))
           AND (nvl(Recinfo.segment29_high,'x') =  nvl(X_Segment29_High,'x'))
) then
if(
            (nvl(Recinfo.segment30_low,'x') =  nvl(X_Segment30_Low,'x'))
           AND (nvl(Recinfo.segment30_high,'x') =  nvl(X_Segment30_High,'x'))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrib.IGI_ITR_CHARGE_RANGES_SS_PKG.lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Charge_Range_Id                NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Authoriser_Id                  NUMBER,
                       X_Employee_Id                    NUMBER,
                       X_Active_Flag                    VARCHAR2,
                       X_Segment1_Low                   VARCHAR2,
                       X_Segment2_Low                   VARCHAR2,
                       X_Segment3_Low                   VARCHAR2,
                       X_Segment4_Low                   VARCHAR2,
                       X_Segment5_Low                   VARCHAR2,
                       X_Segment6_Low                   VARCHAR2,
                       X_Segment7_Low                   VARCHAR2,
                       X_Segment8_Low                   VARCHAR2,
                       X_Segment9_Low                   VARCHAR2,
                       X_Segment10_Low                  VARCHAR2,
                       X_Segment11_Low                  VARCHAR2,
                       X_Segment12_Low                  VARCHAR2,
                       X_Segment13_Low                  VARCHAR2,
                       X_Segment14_Low                  VARCHAR2,
                       X_Segment15_Low                  VARCHAR2,
                       X_Segment16_Low                  VARCHAR2,
                       X_Segment17_Low                  VARCHAR2,
                       X_Segment18_Low                  VARCHAR2,
                       X_Segment19_Low                  VARCHAR2,
                       X_Segment20_Low                  VARCHAR2,
                       X_Segment21_Low                  VARCHAR2,
                       X_Segment22_Low                  VARCHAR2,
                       X_Segment23_Low                  VARCHAR2,
                       X_Segment24_Low                  VARCHAR2,
                       X_Segment25_Low                  VARCHAR2,
                       X_Segment26_Low                  VARCHAR2,
                       X_Segment27_Low                  VARCHAR2,
                       X_Segment28_Low                  VARCHAR2,
                       X_Segment29_Low                  VARCHAR2,
                       X_Segment30_Low                  VARCHAR2,
                       X_Segment1_High                  VARCHAR2,
                       X_Segment2_High                  VARCHAR2,
                       X_Segment3_High                  VARCHAR2,
                       X_Segment4_High                  VARCHAR2,
                       X_Segment5_High                  VARCHAR2,
                       X_Segment6_High                  VARCHAR2,
                       X_Segment7_High                  VARCHAR2,
                       X_Segment8_High                  VARCHAR2,
                       X_Segment9_High                  VARCHAR2,
                       X_Segment10_High                  VARCHAR2,
                       X_Segment11_High                  VARCHAR2,
                       X_Segment12_High                  VARCHAR2,
                       X_Segment13_High                  VARCHAR2,
                       X_Segment14_High                  VARCHAR2,
                       X_Segment15_High                  VARCHAR2,
                       X_Segment16_High                  VARCHAR2,
                       X_Segment17_High                  VARCHAR2,
                       X_Segment18_High                  VARCHAR2,
                       X_Segment19_High                  VARCHAR2,
                       X_Segment20_High                  VARCHAR2,
                       X_Segment21_High                  VARCHAR2,
                       X_Segment22_High                  VARCHAR2,
                       X_Segment23_High                  VARCHAR2,
                       X_Segment24_High                  VARCHAR2,
                       X_Segment25_High                  VARCHAR2,
                       X_Segment26_High                  VARCHAR2,
                       X_Segment27_High                  VARCHAR2,
                       X_Segment28_High                  VARCHAR2,
                       X_Segment29_High                  VARCHAR2,
                       X_Segment30_High                  VARCHAR2,
                       X_Last_Update_Date                DATE,
                       X_Last_Updated_By                 NUMBER,
                       X_Last_Update_Login               NUMBER
  ) IS
  BEGIN
    UPDATE IGI_ITR_CHARGE_RANGES
    SET
       charge_range_id                 =     X_Charge_Range_Id,
       charge_center_id                =     X_Charge_Center_Id,
       authoriser_id                   =     X_Authoriser_Id,
       employee_id                     =     X_Employee_Id,
       active_flag                     =     X_Active_Flag,
       segment1_low                    =     X_Segment1_Low,
       segment2_low                    =     X_Segment2_Low,
       segment3_low                    =     X_Segment3_Low,
       segment4_low                    =     X_Segment4_Low,
       segment5_low                    =     X_Segment5_Low,
       segment6_low                    =     X_Segment6_Low,
       segment7_low                    =     X_Segment7_Low,
       segment8_low                    =     X_Segment8_Low,
       segment9_low                    =     X_Segment9_Low,
       segment10_low                   =     X_Segment10_Low,
       segment11_low                   =     X_Segment11_Low,
       segment12_low                   =     X_Segment12_Low,
       segment13_low                   =     X_Segment13_Low,
       segment14_low                   =     X_Segment14_Low,
       segment15_low                   =     X_Segment15_Low,
       segment16_low                   =     X_Segment16_Low,
       segment17_low                   =     X_Segment17_Low,
       segment18_low                   =     X_Segment18_Low,
       segment19_low                   =     X_Segment19_Low,
       segment20_low                   =     X_Segment20_Low,
       segment21_low                   =     X_Segment21_Low,
       segment22_low                   =     X_Segment22_Low,
       segment23_low                   =     X_Segment23_Low,
       segment24_low                   =     X_Segment24_Low,
       segment25_low                   =     X_Segment25_Low,
       segment26_low                   =     X_Segment26_Low,
       segment27_low                   =     X_Segment27_Low,
       segment28_low                   =     X_Segment28_Low,
       segment29_low                   =     X_Segment29_Low,
       segment30_low                   =     X_Segment30_Low,
       segment1_high                   =     X_Segment1_High,
       segment2_high                   =     X_Segment2_High,
       segment3_high                   =     X_Segment3_High,
       segment4_high                   =     X_Segment4_High,
       segment5_high                   =     X_Segment5_High,
       segment6_high                   =     X_Segment6_High,
       segment7_high                   =     X_Segment7_High,
       segment8_high                   =     X_Segment8_High,
       segment9_high                   =     X_Segment9_High,
       segment10_high                  =     X_Segment10_High,
       segment11_high                  =     X_Segment11_High,
       segment12_high                  =     X_Segment12_High,
       segment13_high                  =     X_Segment13_High,
       segment14_high                  =     X_Segment14_High,
       segment15_high                  =     X_Segment15_High,
       segment16_high                  =     X_Segment16_High,
       segment17_high                  =     X_Segment17_High,
       segment18_high                  =     X_Segment18_High,
       segment19_high                  =     X_Segment19_High,
       segment20_high                  =     X_Segment20_High,
       segment21_high                  =     X_Segment21_High,
       segment22_high                  =     X_Segment22_High,
       segment23_high                  =     X_Segment23_High,
       segment24_high                  =     X_Segment24_High,
       segment25_high                  =     X_Segment25_High,
       segment26_high                  =     X_Segment26_High,
       segment27_high                  =     X_Segment27_High,
       segment28_high                  =     X_Segment28_High,
       segment29_high                  =     X_Segment29_High,
       segment30_high                  =     X_Segment30_High,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_ITR_CHARGE_RANGES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END IGI_ITR_CHARGE_RANGES_SS_PKG;

/
