--------------------------------------------------------
--  DDL for Package Body IGI_BUD_JOURNAL_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_JOURNAL_BATCHES_PKG" as
-- $Header: igibudgb.pls 120.5 2007/09/12 10:34:12 pshivara ship $

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
                       X_Be_Batch_Id             IN OUT NOCOPY NUMBER,
                       X_Fiscal_Year             NUMBER,
                       X_Name                    VARCHAR2,
                       X_Set_Of_Books_Id         NUMBER,
                       X_Record_Type             VARCHAR2,
                       X_Complete_Flag           VARCHAR2,
                       X_Control_Total           NUMBER,
                       X_Running_Total_Dr        NUMBER,
                       X_Running_Total_Cr        NUMBER,
                       X_Date_Completed          DATE,
                       X_Creation_Date           DATE,
                       X_Created_By              NUMBER,
                       X_Last_Update_Date        DATE,
                       X_Last_Updated_By         NUMBER,
                       X_Last_Update_Login       NUMBER
  ) IS

    CURSOR C IS SELECT rowid FROM IGI_BUD_JOURNAL_BATCHES
                 WHERE be_batch_id = X_Be_Batch_Id;
    CURSOR C2 IS SELECT gl_interface_control_s.nextval FROM sys.dual;

   BEGIN
      if (X_Be_Batch_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Be_Batch_Id;
        CLOSE C2;
      end if;

       INSERT INTO IGI_BUD_JOURNAL_BATCHES(
              be_batch_id,
              fiscal_year,
              name,
              set_of_books_id,
              record_type,
              complete_flag,
              control_total,
              running_total_dr,
              running_total_cr,
              date_completed,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Be_Batch_Id,
              X_Fiscal_Year,
              X_Name,
              X_Set_Of_Books_Id,
              X_Record_Type,
              X_Complete_Flag,
              X_Control_Total,
              X_Running_Total_Dr,
              X_Running_Total_Cr,
              X_Date_Completed,
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
                     X_Fiscal_Year                      NUMBER,
                     X_Name                             VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Record_Type                      VARCHAR2,
                     X_Complete_Flag                    VARCHAR2,
                     X_Control_Total                    NUMBER,
                     X_Running_Total_Dr                 NUMBER,
                     X_Running_Total_Cr                 NUMBER,
                     X_Date_Completed                   DATE
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_BUD_JOURNAL_BATCHES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Be_Batch_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journal_headers_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
               (Recinfo.be_batch_id =  X_Be_Batch_Id)
           AND (Recinfo.fiscal_year =  X_Fiscal_Year)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.record_type =  X_Record_Type)
           AND (Recinfo.complete_flag =  X_Complete_Flag)
           AND (   (Recinfo.control_total =  X_Control_Total)
                OR (    (Recinfo.control_total IS NULL)
                    AND (X_Control_Total IS NULL)))
           AND (   (Recinfo.running_total_dr =  X_Running_Total_Dr)
                OR (    (Recinfo.running_total_dr IS NULL)
                    AND (X_Running_Total_Dr IS NULL)))
           AND (   (Recinfo.running_total_cr =  X_Running_Total_Cr)
                OR (    (Recinfo.running_total_cr IS NULL)
                    AND (X_Running_Total_Cr IS NULL)))
           AND (   (Recinfo.date_completed =  X_Date_Completed)
                OR (    (Recinfo.date_completed IS NULL)
                    AND (X_Date_Completed IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      --Bug 3199481 (start)
      If (l_unexp_level >= l_debug_level) then
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journal_headers_pkg.lock_row.Msg2',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;

  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Be_Batch_Id                    NUMBER,
                       X_Fiscal_Year                    NUMBER,
                       X_Name                           VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Record_Type                    VARCHAR2,
                       X_Complete_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Date_Completed                 DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_REQUEST_ID                     NUMBER  -- bug 5982297
  ) IS
  BEGIN
    UPDATE IGI_BUD_JOURNAL_BATCHES
    SET
       be_batch_id                     =     X_Be_Batch_Id,
       fiscal_year                     =     X_Fiscal_Year,
       name                            =     X_Name,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       record_type                     =     X_Record_Type,
       complete_flag                   =     X_Complete_Flag,
       control_total                   =     X_Control_Total,
       running_total_dr                =     X_Running_Total_Dr,
       running_total_cr                =     X_Running_Total_Cr,
       date_completed                  =     X_Date_Completed,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       request_id                      =     X_REQUEST_ID              -- bug 5982297
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid       VARCHAR2,
                       X_Be_Batch_Id NUMBER) IS

    cursor related_headers is
      select h.rowid row_id, h.be_header_id
      from   igi_bud_journal_headers h
      where  h.be_batch_id = X_Be_Batch_Id;

  BEGIN
    DELETE FROM IGI_BUD_JOURNAL_BATCHES
    WHERE rowid = X_Rowid;

    for header in related_headers loop
      igi_bud_journal_headers_pkg.delete_row(header.row_id,
                                             header.be_header_id);
    end loop;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_BUD_JOURNAL_BATCHES_PKG;

/
