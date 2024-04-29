--------------------------------------------------------
--  DDL for Package Body GL_AUTOPOST_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOPOST_OPTIONS_PKG" AS
/* $Header: glistapb.pls 120.4 2005/05/05 01:22:14 kvora ship $ */

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique(x_autopost_set_id  NUMBER,
                         x_ledger_id        NUMBER,
			 x_actual_flag      VARCHAR2,
			 x_period_name      VARCHAR2,
			 x_source_name      VARCHAR2,
			 x_category_name    VARCHAR2,
			 row_id             VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_AUTOMATIC_POSTING_OPTIONS apo
      WHERE  apo.autopost_set_id = x_autopost_set_id
      AND    apo.ledger_id = x_ledger_id
      AND    apo.actual_flag = x_actual_flag
      AND    apo.period_name = x_period_name
      AND    apo.je_source_name = x_source_name
      AND    apo.je_category_name = x_category_name
      AND    (   row_id is null
              OR apo.rowid <> row_id);
    dummy VARCHAR2(10);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_AUTOPOST_COMBO');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_autopost_options_pkg.check_unique');
      RAISE;
  END check_unique;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Autopost_Set_Id                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Actual_Flag                         VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Posting_Priority                    NUMBER,
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
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM GL_AUTOMATIC_POSTING_OPTIONS
             WHERE autopost_set_id = X_autopost_set_id
             AND   ledger_id = X_ledger_Id
             AND   actual_flag = X_Actual_Flag
             AND   period_name = X_Period_Name
             AND   je_source_name = X_Je_Source_Name
             AND   je_category_name = X_Je_Category_Name;

BEGIN

  INSERT INTO GL_AUTOMATIC_POSTING_OPTIONS(
	  autopost_set_id,
          ledger_id,
	  actual_flag,
	  period_name,
	  je_source_name,
	  je_category_name,
          posting_priority,
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
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          context
         ) VALUES (
          X_Autopost_Set_Id,
          X_Ledger_Id,
          X_Actual_Flag,
          X_Period_Name,
          X_Je_Source_Name,
          X_Je_Category_Name,
          X_Posting_Priority,
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
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
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
                   X_Autopost_Set_Id                       NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Actual_Flag                           VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Je_Source_Name                        VARCHAR2,
                   X_Je_Category_Name                      VARCHAR2,
                   X_Posting_Priority                      NUMBER,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Context                               VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_AUTOMATIC_POSTING_OPTIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of autopost_set_id NOWAIT;
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
          (   (Recinfo.autopost_set_id = X_autopost_set_id)
           OR (    (Recinfo.autopost_set_id IS NULL)
               AND (X_autopost_set_id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.je_source_name = X_Je_Source_Name)
           OR (    (Recinfo.je_source_name IS NULL)
               AND (X_Je_Source_Name IS NULL)))
      AND (   (Recinfo.je_category_name = X_je_category_name)
           OR (    (Recinfo.je_category_name IS NULL)
               AND (X_Je_category_name IS NULL)))
      AND (   (Recinfo.posting_priority = X_posting_priority)
           OR (    (Recinfo.posting_priority IS NULL)
               AND (X_posting_priority IS NULL)))
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
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
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
                     X_Autopost_Set_ID                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Actual_Flag                         VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Je_Source_Name                      VARCHAR2,
                     X_Je_Category_Name                    VARCHAR2,
                     X_Posting_Priority                    NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Context                             VARCHAR2
) IS
BEGIN
  UPDATE GL_AUTOMATIC_POSTING_OPTIONS
  SET

    autopost_set_id                           =    X_Autopost_Set_Id,
    ledger_id                                 =    X_Ledger_Id,
    actual_flag                               =    X_Actual_Flag,
    period_name                               =    X_Period_Name,
    je_source_name                            =    X_Je_Source_Name,
    je_category_name                          =    X_Je_Category_Name,
    posting_priority                          =    X_Posting_Priority,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    context                                   =    X_Context
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;


PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM GL_AUTOMATIC_POSTING_OPTIONS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;

END gl_autopost_options_pkg;

/
