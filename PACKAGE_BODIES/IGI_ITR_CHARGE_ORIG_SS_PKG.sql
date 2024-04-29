--------------------------------------------------------
--  DDL for Package Body IGI_ITR_CHARGE_ORIG_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_CHARGE_ORIG_SS_PKG" as
-- $Header: igiitrjb.pls 120.5.12000000.1 2007/09/12 10:31:32 mbremkum ship $
--

  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid               IN OUT NOCOPY VARCHAR2,
                       X_Charge_Orig_Id             NUMBER,
                       X_Charge_Center_Id           NUMBER,
                       X_Originator_Id		    NUMBER,
		       X_Start_Date		    DATE,
		       X_End_Date		    DATE,
		       X_Creation_Date              DATE,
                       X_Created_By                 NUMBER,
                       X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Last_Update_Login          NUMBER,
       	               X_Code_Combination_Id        NUMBER,
		       X_Concatenated_Segments	    VARCHAR2,
	               X_Employee_Id		    NUMBER,
                       X_Segment1                   VARCHAR2,
                       X_Segment2                   VARCHAR2,
                       X_Segment3                   VARCHAR2,
                       X_Segment4                   VARCHAR2,
                       X_Segment5                   VARCHAR2,
                       X_Segment6                   VARCHAR2,
                       X_Segment7                   VARCHAR2,
                       X_Segment8                   VARCHAR2,
                       X_Segment9                   VARCHAR2,
                       X_Segment10                  VARCHAR2,
                       X_Segment11                  VARCHAR2,
                       X_Segment12                  VARCHAR2,
                       X_Segment13                  VARCHAR2,
                       X_Segment14                  VARCHAR2,
                       X_Segment15                  VARCHAR2,
                       X_Segment16                  VARCHAR2,
                       X_Segment17                  VARCHAR2,
                       X_Segment18                  VARCHAR2,
                       X_Segment19                  VARCHAR2,
                       X_Segment20                  VARCHAR2,
                       X_Segment21                  VARCHAR2,
                       X_Segment22                  VARCHAR2,
                       X_Segment23                  VARCHAR2,
                       X_Segment24                  VARCHAR2,
                       X_Segment25                  VARCHAR2,
                       X_Segment26                  VARCHAR2,
                       X_Segment27                  VARCHAR2,
                       X_Segment28                  VARCHAR2,
                       X_Segment29                  VARCHAR2,
                       X_Segment30                  VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_ITR_CHARGE_ORIG
                 WHERE  charge_orig_id = X_Charge_Orig_Id;
         BEGIN

       INSERT INTO IGI_ITR_CHARGE_ORIG(
              charge_orig_id,
              charge_center_id,
	      originator_id,
              start_date,
              end_date,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
	      code_combination_id,
	      concatenated_segments,
	      employee_id,
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
              segment30
             ) VALUES (
              X_Charge_Orig_Id,
              X_Charge_Center_Id,
              X_Originator_Id,
              X_Start_Date,
              X_End_Date,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Last_Update_Login,
              X_Code_Combination_Id,
	      X_Concatenated_Segments,
	      X_Employee_Id,
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
              X_Segment30
             );
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                      VARCHAR2,
                     X_Charge_Orig_Id             NUMBER,
                     X_Charge_Center_Id           NUMBER,
		     X_Originator_Id	 	  NUMBER,
	             X_Start_Date		  DATE,
	             X_End_Date			  DATE,
       	             X_Code_Combination_Id        NUMBER,
		     X_Concatenated_Segments	  VARCHAR2,
		     X_Employee_Id		  NUMBER,
                     X_Segment1                   VARCHAR2,
                     X_Segment2                   VARCHAR2,
                     X_Segment3                   VARCHAR2,
                     X_Segment4                   VARCHAR2,
                     X_Segment5                   VARCHAR2,
                     X_Segment6                   VARCHAR2,
                     X_Segment7                   VARCHAR2,
                     X_Segment8                   VARCHAR2,
                     X_Segment9                   VARCHAR2,
                     X_Segment10                  VARCHAR2,
                     X_Segment11                  VARCHAR2,
                     X_Segment12                  VARCHAR2,
                     X_Segment13                  VARCHAR2,
                     X_Segment14                  VARCHAR2,
                     X_Segment15                  VARCHAR2,
                     X_Segment16                  VARCHAR2,
                     X_Segment17                  VARCHAR2,
                     X_Segment18                  VARCHAR2,
                     X_Segment19                  VARCHAR2,
                     X_Segment20                  VARCHAR2,
                     X_Segment21                  VARCHAR2,
                     X_Segment22                  VARCHAR2,
                     X_Segment23                  VARCHAR2,
                     X_Segment24                  VARCHAR2,
                     X_Segment25                  VARCHAR2,
                     X_Segment26                  VARCHAR2,
                     X_Segment27                  VARCHAR2,
                     X_Segment28                  VARCHAR2,
                     X_Segment29                  VARCHAR2,
                     X_Segment30                  VARCHAR2
					   ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_ITR_CHARGE_ORIG
        WHERE  rowid = X_Rowid
        FOR UPDATE of Charge_Orig_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrjb.IGI_ITR_CHARGE_ORIG_SS_PKG .lock_row.msg1', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
           (Recinfo.charge_center_id =  X_Charge_Center_Id)
       AND (Recinfo.originator_id = X_Originator_Id)
       AND (Recinfo.charge_orig_id = X_Charge_Orig_Id)
       AND (   (Recinfo.concatenated_segments = X_Concatenated_Segments)
            OR (    (Recinfo.concatenated_segments IS NULL)
                AND (X_Concatenated_Segments IS NULL)))
       AND (   (Recinfo.employee_id = X_Employee_Id)
            OR (    (Recinfo.employee_id IS NULL)
                AND (X_Employee_Id IS NULL)))
           AND (    (Recinfo.segment1 = X_Segment1)
                OR  (    (Recinfo.segment1 IS NULL)
                    AND  (X_Segment1 IS NULL)))
           AND (    (Recinfo.segment2 = X_Segment2)
                OR  (    (Recinfo.segment2 IS NULL)
                    AND  (X_Segment2 IS NULL)))
           AND (    (Recinfo.segment3 = X_Segment3)
                OR  (    (Recinfo.segment3 IS NULL)
                    AND  (X_Segment3 IS NULL)))
           AND (    (Recinfo.segment4 = X_Segment4)
                OR  (    (Recinfo.segment4 IS NULL)
                    AND  (X_Segment4 IS NULL)))
           AND (    (Recinfo.segment5 = X_Segment5)
                OR  (    (Recinfo.segment5 IS NULL)
                    AND  (X_Segment5 IS NULL)))
           AND (    (Recinfo.segment6 = X_Segment6)
                OR  (    (Recinfo.segment6 IS NULL)
                    AND  (X_Segment6 IS NULL)))
           AND (    (Recinfo.segment7 = X_Segment7)
                OR  (    (Recinfo.segment7 IS NULL)
                    AND  (X_Segment7 IS NULL)))
           AND (    (Recinfo.segment8 = X_Segment8)
                OR  (    (Recinfo.segment8 IS NULL)
                    AND  (X_Segment8 IS NULL)))
           AND (    (Recinfo.segment9 = X_Segment9)
                OR  (    (Recinfo.segment9 IS NULL)
                    AND  (X_Segment9 IS NULL)))
           AND (    (Recinfo.segment10 = X_Segment10)
                OR  (    (Recinfo.segment10 IS NULL)
                    AND  (X_Segment10 IS NULL)))
           AND (    (Recinfo.segment11 = X_Segment11)
                OR  (    (Recinfo.segment11 IS NULL)
                    AND  (X_Segment11 IS NULL)))
           AND (    (Recinfo.segment12 = X_Segment12)
                OR  (    (Recinfo.segment12 IS NULL)
                    AND  (X_Segment12 IS NULL)))
           AND (    (Recinfo.segment13 = X_Segment13)
                OR  (    (Recinfo.segment13 IS NULL)
                    AND  (X_Segment13 IS NULL)))
           AND (    (Recinfo.segment14 = X_Segment14)
                OR  (    (Recinfo.segment14 IS NULL)
                    AND  (X_Segment14 IS NULL)))
           AND (    (Recinfo.segment15 = X_Segment15)
                OR  (    (Recinfo.segment15 IS NULL)
                    AND  (X_Segment15 IS NULL)))
           AND (    (Recinfo.segment16 = X_Segment16)
                OR  (    (Recinfo.segment16 IS NULL)
                    AND  (X_Segment16 IS NULL)))
           AND (    (Recinfo.segment17 = X_Segment17)
                OR  (    (Recinfo.segment17 IS NULL)
                    AND  (X_Segment17 IS NULL)))
           AND (    (Recinfo.segment18 = X_Segment18)
                OR  (    (Recinfo.segment18 IS NULL)
                    AND  (X_Segment18 IS NULL)))
           AND (    (Recinfo.segment19 = X_Segment19)
                OR  (    (Recinfo.segment19 IS NULL)
                    AND  (X_Segment19 IS NULL)))
           AND (    (Recinfo.segment20 = X_Segment20)
                OR  (    (Recinfo.segment20 IS NULL)
                    AND  (X_Segment20 IS NULL)))
           AND (    (Recinfo.segment21 = X_Segment21)
                OR  (    (Recinfo.segment21 IS NULL)
                    AND  (X_Segment21 IS NULL)))
           AND (    (Recinfo.segment22 = X_Segment22)
                OR  (    (Recinfo.segment22 IS NULL)
                    AND  (X_Segment22 IS NULL)))
           AND (    (Recinfo.segment23 = X_Segment23)
                OR  (    (Recinfo.segment23 IS NULL)
                    AND  (X_Segment23 IS NULL)))
           AND (    (Recinfo.segment24 = X_Segment24)
                OR  (    (Recinfo.segment24 IS NULL)
                    AND  (X_Segment24 IS NULL)))
           AND (    (Recinfo.segment25 = X_Segment25)
                OR  (    (Recinfo.segment25 IS NULL)
                    AND  (X_Segment25 IS NULL)))
           AND (    (Recinfo.segment26 = X_Segment26)
                OR  (    (Recinfo.segment26 IS NULL)
                    AND  (X_Segment26 IS NULL)))
           AND (    (Recinfo.segment27 = X_Segment27)
                OR  (    (Recinfo.segment27 IS NULL)
                    AND  (X_Segment27 IS NULL)))
           AND (    (Recinfo.segment28 = X_Segment28)
                OR  (    (Recinfo.segment28 IS NULL)
                    AND  (X_Segment28 IS NULL)))
           AND (    (Recinfo.segment29 = X_Segment29)
                OR  (    (Recinfo.segment29 IS NULL)
                    AND  (X_Segment29 IS NULL)))
           AND (    (Recinfo.segment30 = X_Segment30)
                OR  (    (Recinfo.segment30 IS NULL)
                    AND  (X_Segment30 IS NULL)))
        ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrjb.IGI_ITR_CHARGE_ORIG_SS_PKG .lock_row.msg2', FALSE);
	END IF;

      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                      VARCHAR2,
                       X_Charge_Orig_Id             NUMBER,
                       X_Charge_Center_Id           NUMBER,
                       X_Originator_Id		    NUMBER,
                       X_Start_Date		    DATE,
		       X_End_Date		    DATE,
	               X_Last_Update_Date           DATE,
                       X_Last_Updated_By            NUMBER,
                       X_Last_Update_Login          NUMBER,
       	               X_Code_Combination_Id        NUMBER,
		       X_Concatenated_Segments	    VARCHAR2,
		       X_Employee_Id		    NUMBER,
                       X_Segment1                   VARCHAR2,
                       X_Segment2                   VARCHAR2,
                       X_Segment3                   VARCHAR2,
                       X_Segment4                   VARCHAR2,
                       X_Segment5                   VARCHAR2,
                       X_Segment6                   VARCHAR2,
                       X_Segment7                   VARCHAR2,
                       X_Segment8                   VARCHAR2,
                       X_Segment9                   VARCHAR2,
                       X_Segment10                  VARCHAR2,
                       X_Segment11                  VARCHAR2,
                       X_Segment12                  VARCHAR2,
                       X_Segment13                  VARCHAR2,
                       X_Segment14                  VARCHAR2,
                       X_Segment15                  VARCHAR2,
                       X_Segment16                  VARCHAR2,
                       X_Segment17                  VARCHAR2,
                       X_Segment18                  VARCHAR2,
                       X_Segment19                  VARCHAR2,
                       X_Segment20                  VARCHAR2,
                       X_Segment21                  VARCHAR2,
                       X_Segment22                  VARCHAR2,
                       X_Segment23                  VARCHAR2,
                       X_Segment24                  VARCHAR2,
                       X_Segment25                  VARCHAR2,
                       X_Segment26                  VARCHAR2,
                       X_Segment27                  VARCHAR2,
                       X_Segment28                  VARCHAR2,
                       X_Segment29                  VARCHAR2,
                       X_Segment30                  VARCHAR2
  ) IS
  BEGIN
    UPDATE IGI_ITR_CHARGE_ORIG
    SET
       charge_orig_id              =     X_Charge_Orig_Id,
       charge_center_id            =     X_Charge_Center_Id,
       originator_id               =     X_Originator_Id,
       start_date                  =     X_Start_Date,
       end_date                    =     X_End_Date,
       last_update_date            =     X_Last_Update_Date,
       last_updated_by             =     X_Last_Updated_By,
       last_update_login           =     X_Last_Update_Login,
       concatenated_segments       =     X_Concatenated_Segments,
       employee_id                 =     X_Employee_Id,
       segment1                    =     X_Segment1,
       segment2                    =     X_Segment2,
       segment3                    =     X_Segment3,
       segment4                    =     X_Segment4,
       segment5                    =     X_Segment5,
       segment6                    =     X_Segment6,
       segment7                    =     X_Segment7,
       segment8                    =     X_Segment8,
       segment9                    =     X_Segment9,
       segment10                   =     X_Segment10,
       segment11                   =     X_Segment11,
       segment12                   =     X_Segment12,
       segment13                   =     X_Segment13,
       segment14                   =     X_Segment14,
       segment15                   =     X_Segment15,
       segment16                   =     X_Segment16,
       segment17                   =     X_Segment17,
       segment18                   =     X_Segment18,
       segment19                   =     X_Segment19,
       segment20                   =     X_Segment20,
       segment21                   =     X_Segment21,
       segment22                   =     X_Segment22,
       segment23                   =     X_Segment23,
       segment24                   =     X_Segment24,
       segment25                   =     X_Segment25,
       segment26                   =     X_Segment26,
       segment27                   =     X_Segment27,
       segment28                   =     X_Segment28,
       segment29                   =     X_Segment29,
       segment30                   =     X_Segment30

    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_ITR_CHARGE_ORIG
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

END IGI_ITR_CHARGE_ORIG_SS_PKG;

/
