--------------------------------------------------------
--  DDL for Package Body GL_SUSPENSE_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SUSPENSE_ACCOUNTS_PKG" as
/* $Header: gliacsab.pls 120.5 2005/05/05 00:58:41 kvora ship $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_SUSPENSE_ACCOUNTS

             WHERE ledger_id = X_Ledger_Id

             AND   je_source_name = X_Je_Source_Name

             AND   je_category_name = X_Je_Category_Name

             AND   code_combination_id = X_Code_Combination_Id;


BEGIN

  INSERT INTO GL_SUSPENSE_ACCOUNTS(
          ledger_id,
          je_source_name,
          je_category_name,
          code_combination_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          context
         ) VALUES (
          X_Ledger_Id,
          X_Je_Source_Name,
          X_Je_Category_Name,
          X_Code_Combination_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Context
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Ledger_Id                       NUMBER,
                   X_Je_Source_Name                        VARCHAR2,
                   X_Je_Category_Name                      VARCHAR2,
                   X_Code_Combination_Id                   NUMBER,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Context                               VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_SUSPENSE_ACCOUNTS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Ledger_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.je_source_name = X_Je_Source_Name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_Je_Source_Name IS NULL)))
      AND (   (Recinfo.je_category_name = X_Je_Category_Name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_Category_Name IS NULL)))
      AND (   (Recinfo.code_combination_id = X_Code_Combination_Id)
           OR (    (Recinfo.code_combination_id IS NULL)
               AND (X_Code_Combination_Id IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (Recinfo.context IS NULL)
               AND (X_Context IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Code_Combination_Id                 NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Context                             VARCHAR2
) IS
BEGIN
  UPDATE GL_SUSPENSE_ACCOUNTS
  SET

    ledger_id                                 =    X_Ledger_Id,
    je_source_name                            =    X_Je_Source_Name,
    je_category_name                          =    X_Je_Category_Name,
    code_combination_id                       =    X_Code_Combination_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_SUSPENSE_ACCOUNTS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

PROCEDURE Check_Unique(X_Ledger_Id                         NUMBER,
                       X_Je_Source_Name                    VARCHAR2,
                       X_Je_Category_Name                  VARCHAR2,
                       X_Rowid                             VARCHAR2
) IS
CURSOR check_dups IS
  SELECT  1
    FROM  GL_SUSPENSE_ACCOUNTS sa
   WHERE  sa.je_source_name   = X_Je_Source_Name
     AND  sa.je_category_name = X_Je_Category_Name
     AND  sa.ledger_id  = X_Ledger_Id
     AND  ( X_Rowid is NULL
           OR  sa.rowid <> X_Rowid);

dummy  NUMBER;

BEGIN
  OPEN check_dups;
  FETCH check_dups INTO dummy;

  IF check_dups%FOUND THEN
    CLOSE check_dups;
    fnd_message.set_name('SQLGL', 'GL_SUS_ACCT_ALREADY_DEFINED');
    app_exception.raise_exception;
  END IF;

  CLOSE check_dups;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'Unhandled Exception');
    fnd_message.set_token('PROCEDURE',
      'GL_SUSPENSE_ACCOUNTS.Check_Unique');
    RAISE;
END Check_Unique;

-- **********************************************************************

  FUNCTION is_ledger_suspense_exist( x_ledger_id NUMBER ) RETURN BOOLEAN IS

    CURSOR c_other IS
      SELECT 'found'
      FROM   GL_SUSPENSE_ACCOUNTS sa
      WHERE  sa.LEDGER_ID         = x_ledger_id
      AND    sa.JE_SOURCE_NAME          = 'Other'
      AND    sa.JE_CATEGORY_NAME        = 'Other';

    dummy VARCHAR2( 100 );

  BEGIN

    OPEN  c_other;
    FETCH c_other INTO dummy;

    IF c_other%FOUND THEN
       CLOSE c_other;
       RETURN( TRUE );
    ELSE
       CLOSE c_other;
       RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_SUSPENSE_ACCOUNTS_PKG.is_ledger_suspense_exist');
      RAISE;

  END is_ledger_suspense_exist;

-- **********************************************************************

  PROCEDURE insert_ledger_suspense( x_ledger_id     NUMBER,
                                 x_code_combination_id NUMBER,
                                 x_last_update_date    DATE,
                                 x_last_updated_by     NUMBER ) IS
  BEGIN

    LOCK TABLE GL_SUSPENSE_ACCOUNTS IN SHARE UPDATE MODE;

    INSERT INTO gl_suspense_accounts
    ( ledger_id,
      je_source_name,
      je_category_name,
      code_combination_id,
      last_update_date,
      last_updated_by )
    VALUES
    ( x_ledger_id,
      'Other',
      'Other',
      x_code_combination_id,
      sysdate,
      x_last_updated_by );

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_SUSPENSE_ACCOUNTS_PKG.insert_ledger_suspense');
      RAISE;

  END insert_ledger_suspense;

-- **********************************************************************

  PROCEDURE update_ledger_suspense( x_ledger_id     NUMBER,
                                 x_code_combination_id NUMBER,
                                 x_last_update_date    DATE,
                                 x_last_updated_by     NUMBER ) IS
  BEGIN

    LOCK TABLE GL_SUSPENSE_ACCOUNTS IN SHARE UPDATE MODE;

    IF (x_code_combination_id IS NULL) THEN
	DELETE FROM gl_suspense_accounts
	WHERE  	ledger_id        = x_ledger_id
    	AND    	je_source_name   = 'Other'
    	AND    	je_category_name = 'Other';
    ELSE
    	UPDATE gl_suspense_accounts
    	SET    	code_combination_id = x_code_combination_id,
           	last_update_date    = x_last_update_date,
           	last_updated_by     = x_last_updated_by
    	WHERE  	ledger_id        = x_ledger_id
    	AND    	je_source_name   = 'Other'
    	AND    	je_category_name = 'Other';
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_SUSPENSE_ACCOUNTS_PKG.update_ledger_suspense');
      RAISE;

  END update_ledger_suspense;



END GL_SUSPENSE_ACCOUNTS_PKG;

/
