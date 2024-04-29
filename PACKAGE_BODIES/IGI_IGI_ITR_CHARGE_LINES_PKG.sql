--------------------------------------------------------
--  DDL for Package Body IGI_IGI_ITR_CHARGE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_ITR_CHARGE_LINES_PKG" as
-- $Header: igiitrcb.pls 120.5.12000000.1 2007/09/12 10:30:34 mbremkum ship $
--

  l_debug_level number  :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number  :=      FND_LOG.LEVEL_STATEMENT;
  l_proc_level number   :=      FND_LOG.LEVEL_PROCEDURE;
  l_event_level number  :=      FND_LOG.LEVEL_EVENT;
  l_excep_level number  :=      FND_LOG.LEVEL_EXCEPTION;
  l_error_level number  :=      FND_LOG.LEVEL_ERROR;
  l_unexp_level number  :=      FND_LOG.LEVEL_UNEXPECTED;


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_It_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Effective_Date                 DATE,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Posting_Flag                   VARCHAR2,
                       X_Submit_Date                    DATE,
                       X_Suggested_Amount               NUMBER,
                       X_Rejection_Note                 VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_ITR_CHARGE_LINES
                 WHERE it_header_id = X_It_Header_Id
                 AND   it_line_num = X_It_Line_Num
                 AND   set_of_books_id = X_Set_Of_Books_Id;

   BEGIN


       INSERT INTO IGI_ITR_CHARGE_LINES(
              it_header_id,
              it_line_num,
              set_of_books_id,
              code_combination_id,
              charge_center_id,
              effective_date,
              entered_dr,
              entered_cr,
              description,
              status_flag,
              posting_flag,
              submit_date,
              suggested_amount,
              rejection_note,
              creation_date,
              created_by,
              last_update_login,
              last_update_date,
              last_updated_by
             ) VALUES (
              X_It_Header_Id,
              X_It_Line_Num,
              X_Set_Of_Books_Id,
              X_Code_Combination_Id,
              X_Charge_Center_Id,
              X_Effective_Date,
              X_Entered_Dr,
              X_Entered_Cr,
              X_Description,
              X_Status_Flag,
              X_Posting_Flag,
              X_Submit_Date,
              X_Suggested_Amount,
              X_Rejection_Note,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Last_Update_Date,
              X_Last_Updated_By
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_It_Header_Id                     NUMBER,
                     X_It_Line_Num                      NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Charge_Center_Id                 NUMBER,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Description                      VARCHAR2,
                     X_Status_Flag                      VARCHAR2,
                     X_Posting_Flag                     VARCHAR2,
                     X_Suggested_Amount                 NUMBER,
                     X_Rejection_Note                   VARCHAR2
  ) IS

    CURSOR C IS
        SELECT *
        FROM   IGI_ITR_CHARGE_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of It_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');

	IF ( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrcb.IGI_IGI_ITR_CHARGE_LINES_PKG.lock_row.msg1', FALSE);
	END IF;



      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.it_header_id =  X_It_Header_Id)
           AND (Recinfo.it_line_num =  X_It_Line_Num)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (Recinfo.charge_center_id =  X_Charge_Center_Id)
           AND (   (Recinfo.entered_dr =  X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr =  X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.status_flag =  X_Status_Flag)
                OR (    (Recinfo.status_flag IS NULL)
                    AND (X_Status_Flag IS NULL)))
           AND (   (Recinfo.posting_flag =  X_Posting_Flag)
                OR (    (Recinfo.posting_flag IS NULL)
                    AND (X_Posting_Flag IS NULL)))
           AND (   (Recinfo.suggested_amount =  X_Suggested_Amount)
                OR (    (Recinfo.suggested_amount IS NULL)
                    AND (X_Suggested_Amount IS NULL)))
           AND (   (Recinfo.rejection_note =  X_Rejection_Note)
                OR (    (Recinfo.rejection_note IS NULL)
                    AND (X_Rejection_Note IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');

	IF ( l_excep_level >=  l_debug_level) THEN
  	      FND_LOG.MESSAGE(l_excep_level,'igi.plsql.igiitrcb.IGI_IGI_ITR_CHARGE_LINES_PKG.lock_row.msg2', FALSE);
	END IF;



      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_It_Header_Id                   NUMBER,
                       X_It_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Charge_Center_Id               NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Description                    VARCHAR2,
                       X_Status_Flag                    VARCHAR2,
                       X_Posting_Flag                   VARCHAR2,
                       X_Suggested_Amount               NUMBER,
                       X_Rejection_Note                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER

  ) IS
  BEGIN
    UPDATE IGI_ITR_CHARGE_LINES
    SET
       it_header_id                    =     X_It_Header_Id,
       it_line_num                     =     X_It_Line_Num,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       code_combination_id             =     X_Code_Combination_Id,
       charge_center_id                =     X_Charge_Center_Id,
       entered_dr                      =     X_Entered_Dr,
       entered_cr                      =     X_Entered_Cr,
       description                     =     X_Description,
       status_flag                     =     X_Status_Flag,
       posting_flag                    =     X_Posting_Flag,
       suggested_amount                =     X_Suggested_Amount,
       rejection_note                  =     X_Rejection_Note,
       last_update_login               =     X_Last_Update_Login,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM IGI_ITR_CHARGE_LINES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_IGI_ITR_CHARGE_LINES_PKG;

/
