--------------------------------------------------------
--  DDL for Package Body IGI_BUD_JOURNAL_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_JOURNAL_LINES_PKG" as
-- $Header: igibudeb.pls 120.4 2005/10/30 05:51:41 appldev ship $

--Bug 3199481

l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
l_event_level   number := FND_LOG.LEVEL_EVENT ;
l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
l_error_level   number := FND_LOG.LEVEL_ERROR ;
l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

--Bug 3199481

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Description                    VARCHAR2,
                       X_Fye_Pye_Entry                  VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Start_Period                   VARCHAR2,
                       X_Reason_Code                    VARCHAR2,
                       X_Recurring_Entry                VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_BUD_JOURNAL_LINES
                 WHERE be_header_id = X_Be_Header_Id
                 AND   be_line_num = X_Be_Line_Num;

   BEGIN


       INSERT INTO IGI_BUD_JOURNAL_LINES(
              be_batch_id,
              be_header_id,
              be_line_num,
              set_of_books_id,
              code_combination_id,
              record_type,
              entered_dr,
              entered_cr,
              next_year_budget,
              description,
              fye_pye_entry,
              profile_code,
              start_period,
              reason_code,
              recurring_entry,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (

              X_Be_Batch_Id,
              X_Be_Header_Id,
              X_Be_Line_Num,
              X_Set_Of_Books_Id,
              X_Code_Combination_Id,
              X_Record_Type,
              X_Entered_Dr,
              X_Entered_Cr,
              X_Next_Year_Budget,
              X_Description,
              X_Fye_Pye_Entry,
              X_Profile_Code,
              X_Start_Period,
              X_Reason_Code,
              X_Recurring_Entry,
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


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Be_Batch_Id                      NUMBER,
                     X_Be_Header_Id                     NUMBER,
                     X_Be_Line_Num                      NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Next_Year_Budget                 NUMBER,
                     X_Description                      VARCHAR2,
                     X_Fye_Pye_Entry                    VARCHAR2,
                     X_Profile_Code                     VARCHAR2,
                     X_Start_Period                     VARCHAR2,
                     X_Reason_Code                      VARCHAR2,
                     X_Recurring_Entry                  VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_BUD_JOURNAL_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Be_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
       --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journal_lines_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.be_batch_id =  X_Be_Batch_Id)
           AND (Recinfo.be_header_id =  X_Be_Header_Id)
           AND (Recinfo.be_line_num =  X_Be_Line_Num)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (Recinfo.record_type =  X_Record_Type)
           AND (   (Recinfo.entered_dr =  X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr =  X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (   (Recinfo.next_year_budget =  X_Next_Year_Budget)
                OR (    (Recinfo.next_year_budget IS NULL)
                    AND (X_Next_Year_Budget IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.fye_pye_entry =  X_Fye_Pye_Entry)
                OR (    (Recinfo.fye_pye_entry IS NULL)
                    AND (X_Fye_Pye_Entry IS NULL)))
           AND (   (Recinfo.profile_code =  X_Profile_Code)
                OR (    (Recinfo.profile_code IS NULL)
                    AND (X_Profile_Code IS NULL)))
           AND (   (Recinfo.start_period =  X_Start_Period)
                OR (    (Recinfo.start_period IS NULL)
                    AND (X_Start_Period IS NULL)))
           AND (   (Recinfo.reason_code =  X_Reason_Code)
                OR (    (Recinfo.reason_code IS NULL)
                    AND (X_Reason_Code IS NULL)))
           AND (   (Recinfo.recurring_entry =  X_Recurring_Entry)
                OR (    (Recinfo.recurring_entry IS NULL)
                    AND (X_Recurring_Entry IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journals_periods_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Be_Header_Id                   NUMBER,
                       X_Be_Line_Num                    NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Description                    VARCHAR2,
                       X_Fye_Pye_Entry                  VARCHAR2,
                       X_Profile_Code                   VARCHAR2,
                       X_Start_Period                   VARCHAR2,
                       X_Reason_Code                    VARCHAR2,
                       X_Recurring_Entry                VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE IGI_BUD_JOURNAL_LINES
    SET
       be_batch_id                     =     X_Be_Batch_Id,
       be_header_id                    =     X_Be_Header_Id,
       be_line_num                     =     X_Be_Line_Num,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       code_combination_id             =     X_Code_Combination_Id,
       record_type                     =     X_Record_Type,
       entered_dr                      =     X_Entered_Dr,
       entered_cr                      =     X_Entered_Cr,
       next_year_budget                =     X_Next_Year_Budget,
       description                     =     X_Description,
       fye_pye_entry                   =     X_Fye_Pye_Entry,
       profile_code                    =     X_Profile_Code,
       start_period                    =     X_Start_Period,
       reason_code                     =     X_Reason_Code,
       recurring_entry                 =     X_Recurring_Entry,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid        VARCHAR2,
                       X_Be_Header_Id NUMBER,
                       X_Be_Line_Num  NUMBER) IS

    cursor related_periods is
      select p.rowid row_id
      from   igi_bud_journal_periods p
      where  p.be_header_id = X_Be_Header_Id
       and   p.be_line_num = X_Be_Line_Num;

  BEGIN
    DELETE FROM IGI_BUD_JOURNAL_LINES
    WHERE rowid = X_Rowid;

    for periods in related_periods loop
      igi_bud_journal_periods_pkg.delete_row(periods.row_id);
    end loop;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_BUD_JOURNAL_LINES_PKG;

/
