--------------------------------------------------------
--  DDL for Package Body IGI_BUD_JOURNAL_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_JOURNAL_PERIODS_PKG" as
-- $Header: igibuddb.pls 120.4 2005/10/30 05:51:39 appldev ship $

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
                       X_Period_Name                    VARCHAR2,
                       X_Period_Number                  NUMBER,
                       X_Period_Year                    NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM igi_bud_journal_periods
                 WHERE be_header_id = X_Be_Header_Id
                 AND   be_line_num = X_Be_Line_Num
                 AND   period_name = X_Period_Name;

   BEGIN


       INSERT INTO igi_bud_journal_periods(
              be_batch_id,
              be_header_id,
              be_line_num,
              period_name,
              period_number,
              period_year,
              record_type,
              entered_dr,
              entered_cr,
              next_year_budget,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Be_Batch_Id,
              X_Be_Header_Id,
              X_Be_Line_Num,
              X_Period_Name,
              X_Period_Number,
              X_Period_Year,
              X_Record_Type,
              X_Entered_Dr,
              X_Entered_Cr,
              X_Next_Year_Budget,
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
                     X_Period_Name                      VARCHAR2,
                     X_Period_Number                    NUMBER,
                     X_Period_Year                      NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Next_Year_Budget                 NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   igi_bud_journal_periods
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
            FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journals_periods_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.be_batch_id =  X_Be_Batch_Id)
           AND (Recinfo.be_header_id =  X_Be_Header_Id)
           AND (Recinfo.be_line_num =  X_Be_Line_Num)
           AND (Recinfo.period_name =  X_Period_Name)
           AND (Recinfo.period_number =  X_Period_Number)
           AND (Recinfo.period_year =  X_Period_Year)
           AND (   (Recinfo.record_type =  X_Record_Type)
                OR (    (Recinfo.record_type IS NULL)
                    AND (X_Record_Type IS NULL)))
           AND (   (Recinfo.entered_dr =  X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr =  X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (   (Recinfo.next_year_budget =  X_Next_Year_Budget)
                OR (    (Recinfo.next_year_budget IS NULL)
                    AND (X_Next_Year_Budget IS NULL)))
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
                       X_Period_Name                    VARCHAR2,
                       X_Period_Number                  NUMBER,
                       X_Period_Year                    NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Next_Year_Budget               NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE igi_bud_journal_periods
    SET
       be_batch_id                     =     X_Be_Batch_Id,
       be_header_id                    =     X_Be_Header_Id,
       be_line_num                     =     X_Be_Line_Num,
       period_name                     =     X_Period_Name,
       period_number                   =     X_Period_Number,
       period_year                     =     X_Period_Year,
       record_type                     =     X_Record_Type,
       entered_dr                      =     X_Entered_Dr,
       entered_cr                      =     X_Entered_Cr,
       next_year_budget                =     X_Next_Year_Budget,
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
    DELETE FROM igi_bud_journal_periods
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_BUD_JOURNAL_PERIODS_PKG;

/
