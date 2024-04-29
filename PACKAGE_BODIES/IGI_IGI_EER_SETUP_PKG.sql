--------------------------------------------------------
--  DDL for Package Body IGI_IGI_EER_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGI_EER_SETUP_PKG" as
-- $Header: igihglab.pls 120.4.12000000.1 2007/09/12 10:11:39 mbremkum ship $
--following variables added for bug 3199481: fnd logging changes: sdixit
   l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   l_event_level number	:=	FND_LOG.LEVEL_EVENT;
   l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   l_error_level number	:=	FND_LOG.LEVEL_ERROR;
   l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Gl_Set_Of_Books_Id             NUMBER,
                       X_Level_1                        NUMBER,
                       X_Level_2                        NUMBER,
                       X_Level_3                        NUMBER,
                       X_Level_4                        NUMBER,
                       X_Level_5                        NUMBER,
                       X_Level_6                        NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM IGI_EER_SETUP
                 WHERE gl_set_of_books_id = X_Gl_Set_Of_Books_Id;
   BEGIN
       INSERT INTO IGI_EER_SETUP(
              gl_set_of_books_id,
              level_1,
              level_2,
              level_3,
              level_4,
              level_5,
              level_6,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login
             ) VALUES (
              X_Gl_Set_Of_Books_Id,
              X_Level_1,
              X_Level_2,
              X_Level_3,
              X_Level_4,
              X_Level_5,
              X_Level_6,
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
                     X_Gl_Set_Of_Books_Id               NUMBER,
                     X_Level_1                          NUMBER,
                     X_Level_2                          NUMBER,
                     X_Level_3                          NUMBER,
                     X_Level_4                          NUMBER,
                     X_Level_5                          NUMBER,
                     X_Level_6                          NUMBER
  ) IS
    CURSOR C IS
        SELECT *
        FROM   IGI_EER_SETUP
        WHERE  rowid = X_Rowid
        FOR UPDATE of Gl_Set_Of_Books_Id NOWAIT;
    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igihglab.IGI_IGI_ERR_SETUP_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.gl_set_of_books_id =  X_Gl_Set_Of_Books_Id)
           AND (Recinfo.level_1 =  X_Level_1)
           AND (Recinfo.level_2 =  X_Level_2)
           AND (Recinfo.level_3 =  X_Level_3)
           AND (Recinfo.level_4 =  X_Level_4)
           AND (   (Recinfo.level_5 =  X_Level_5)
                OR (    (Recinfo.level_5 IS NULL)
                    AND (X_Level_5 IS NULL)))
           AND (   (Recinfo.level_6 =  X_Level_6)
                OR (    (Recinfo.level_6 IS NULL)
                    AND (X_Level_6 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
   --bug 3199481 fnd logging changes: sdixit: start block
       IF (l_excep_level >=  l_debug_level ) THEN
          FND_LOG.MESSAGE (l_excep_level , 'igi.plsql.igihglab.IGI_IGI_ERR_SETUP_PKG.Lock_Row',FALSE);
       END IF;
   --bug 3199481 fnd logging changes: sdixit: end block
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Gl_Set_Of_Books_Id             NUMBER,
                       X_Level_1                        NUMBER,
                       X_Level_2                        NUMBER,
                       X_Level_3                        NUMBER,
                       X_Level_4                        NUMBER,
                       X_Level_5                        NUMBER,
                       X_Level_6                        NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
  ) IS
  BEGIN
    UPDATE IGI_EER_SETUP
    SET
       gl_set_of_books_id              =     X_Gl_Set_Of_Books_Id,
       level_1                         =     X_Level_1,
       level_2                         =     X_Level_2,
       level_3                         =     X_Level_3,
       level_4                         =     X_Level_4,
       level_5                         =     X_Level_5,
       level_6                         =     X_Level_6,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

END IGI_IGI_EER_SETUP_PKG;

/
