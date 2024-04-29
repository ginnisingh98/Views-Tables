--------------------------------------------------------
--  DDL for Package Body IGI_IGI_INT_BK_ID_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_INT_BK_ID_MAP_PKG" as
-- $Header: igiintcb.pls 120.7.12000000.1 2007/09/12 09:37:33 mbremkum ship $
--
l_debug_level   number;
l_state_level   number;
l_proc_level    number;
l_event_level   number;
l_excep_level   number;
l_error_level   number;
l_unexp_level   number;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Feeder_Book_Id                 VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM igi_int_bk_id_map
                 WHERE feeder_book_id = X_Feeder_Book_Id;

   BEGIN


       INSERT INTO igi_int_bk_id_map(

              feeder_book_id,
              set_of_books_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Feeder_Book_Id,
              X_Set_Of_Books_Id,
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
                     X_Feeder_Book_Id                   VARCHAR2,
                     X_Set_Of_Books_Id                  NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   igi_int_bk_id_map
        WHERE  rowid = X_Rowid
        FOR UPDATE of Feeder_Book_Id NOWAIT;
    Recinfo C%ROWTYPE;


  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_igi_int_bk_id_map_pkg.lock_row.Msg1',FALSE);
      END IF;
-- bug 3199481, end block
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.feeder_book_id =  X_Feeder_Book_Id)
           AND (Recinfo.set_of_books_id =  X_Set_Of_Books_Id)
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
-- bug 3199481, start block
      IF (l_unexp_level >= l_debug_level) THEN
         FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igi_igi_int_bk_id_map_pkg.lock_row.Msg2',FALSE);
      END IF;
-- bug 3199481, end block
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;



  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Feeder_Book_Id                 VARCHAR2,
                       X_Set_Of_Books_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN
    UPDATE igi_int_bk_id_map
    SET
       feeder_book_id                  =     X_Feeder_Book_Id,
       set_of_books_id                 =     X_Set_Of_Books_Id,
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
    DELETE FROM igi_int_bk_id_map
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;
BEGIN

l_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
l_state_level  := FND_LOG.LEVEL_STATEMENT ;
l_proc_level   := FND_LOG.LEVEL_PROCEDURE ;
l_event_level  := FND_LOG.LEVEL_EVENT ;
l_excep_level  := FND_LOG.LEVEL_EXCEPTION ;
l_error_level  := FND_LOG.LEVEL_ERROR ;
l_unexp_level  := FND_LOG.LEVEL_UNEXPECTED ;

END IGI_IGI_INT_BK_ID_MAP_PKG;

/
