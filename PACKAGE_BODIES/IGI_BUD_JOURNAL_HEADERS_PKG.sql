--------------------------------------------------------
--  DDL for Package Body IGI_BUD_JOURNAL_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD_JOURNAL_HEADERS_PKG" as
-- $Header: igibudfb.pls 120.4 2005/10/30 05:51:44 appldev ship $

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
                       X_Be_Header_Id                   IN OUT NOCOPY NUMBER,
                       X_Budget_Entity_Id               NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Je_Category_Name               VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Autocopy_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Default_Reason_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_BUD_JOURNAL_HEADERS
                 WHERE be_header_id = X_Be_Header_Id;
      CURSOR C2 IS SELECT igi_bud_journal_headers_s.nextval FROM sys.dual;
   BEGIN
      if (X_Be_Header_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Be_Header_Id;
        CLOSE C2;
      end if;

       INSERT INTO IGI_BUD_JOURNAL_HEADERS(
              be_batch_id,
              be_header_id,
              budget_entity_id,
              budget_version_id,
              set_of_books_id,
              currency_code,
              je_category_name,
              name,
              running_total_dr,
              running_total_cr,
              autocopy_flag,
              control_total,
              default_reason_code,
              description,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Be_Batch_Id,
              X_Be_Header_Id,
              X_Budget_Entity_Id,
              X_Budget_Version_Id,
              X_Set_Of_Books_Id,
              X_Currency_Code,
              X_Je_Category_Name,
              X_Name,
              X_Running_Total_Dr,
              X_Running_Total_Cr,
              X_Autocopy_Flag,
              X_Control_Total,
              X_Default_Reason_Code,
              X_Description,
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
                     X_Budget_Entity_Id                 NUMBER,
                     X_Budget_Version_Id                NUMBER,
                     X_Set_Of_Books_Id                  NUMBER,
                     X_Currency_Code                    VARCHAR2,
                     X_Je_Category_Name                 VARCHAR2,
                     X_Name                             VARCHAR2,
                     X_Running_Total_Dr                 NUMBER,
                     X_Running_Total_Cr                 NUMBER,
                     X_Autocopy_Flag                    VARCHAR2,
                     X_Control_Total                    NUMBER,
                     X_Default_Reason_Code              VARCHAR2,
                     X_Description                      VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_BUD_JOURNAL_HEADERS
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
         FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igi_bud_journal_headers_pkg.lock_row.Msg1',FALSE);
      End if;
      --Bug 3199481 (End)
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.be_batch_id =  X_Be_Batch_Id)
           AND (Recinfo.be_header_id =  X_Be_Header_Id)
           AND (Recinfo.budget_entity_id =  X_Budget_Entity_Id)
           AND (Recinfo.budget_version_id =  X_Budget_Version_Id)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
           AND (Recinfo.currency_code =  X_Currency_Code)
           AND (Recinfo.je_category_name =  X_Je_Category_Name)
           AND (Recinfo.name =  X_Name)
           AND (Recinfo.running_total_dr =  X_Running_Total_Dr)
           AND (Recinfo.running_total_cr =  X_Running_Total_Cr)
           AND (Recinfo.autocopy_flag =  X_Autocopy_Flag)
           AND (   (Recinfo.control_total =  X_Control_Total)
                OR (    (Recinfo.control_total IS NULL)
                    AND (X_Control_Total IS NULL)))
           AND (   (Recinfo.default_reason_code =  X_Default_Reason_Code)
                OR (    (Recinfo.default_reason_code IS NULL)
                    AND (X_Default_Reason_Code IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
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
                       X_Be_Header_Id                   NUMBER,
                       X_Budget_Entity_Id               NUMBER,
                       X_Budget_Version_Id              NUMBER,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Currency_Code                  VARCHAR2,
                       X_Je_Category_Name               VARCHAR2,
                       X_Name                           VARCHAR2,
                       X_Running_Total_Dr               NUMBER,
                       X_Running_Total_Cr               NUMBER,
                       X_Autocopy_Flag                  VARCHAR2,
                       X_Control_Total                  NUMBER,
                       X_Default_Reason_Code            VARCHAR2,
                       X_Description                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE IGI_BUD_JOURNAL_HEADERS
    SET
       be_batch_id                     =     X_Be_Batch_Id,
       be_header_id                    =     X_Be_Header_Id,
       budget_entity_id                =     X_Budget_Entity_Id,
       budget_version_id               =     X_Budget_Version_Id,
       set_of_books_id                 =     X_Set_Of_Books_Id,
       currency_code                   =     X_Currency_Code,
       je_category_name                =     X_Je_Category_Name,
       name                            =     X_Name,
       running_total_dr                =     X_Running_Total_Dr,
       running_total_cr                =     X_Running_Total_Cr,
       autocopy_flag                   =     X_Autocopy_Flag,
       control_total                   =     X_Control_Total,
       default_reason_code             =     X_Default_Reason_Code,
       description                     =     X_Description,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid        VARCHAR2,
                       X_Be_Header_Id NUMBER) IS

    cursor related_lines is
      select l.rowid row_id, l.be_line_num
      from   igi_bud_journal_lines l
      where  l.be_header_id = X_Be_Header_Id;

  BEGIN
    DELETE FROM IGI_BUD_JOURNAL_HEADERS
    WHERE rowid = X_Rowid;

    for lines in related_lines loop
      igi_bud_journal_lines_pkg.delete_row(lines.row_id,
                                             X_Be_Header_Id,
                                             lines.be_line_num);
    end loop;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END IGI_BUD_JOURNAL_HEADERS_PKG;

/
