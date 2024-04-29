--------------------------------------------------------
--  DDL for Package Body GL_AUTOREVERSE_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTOREVERSE_OPTIONS_PKG" as
/* $Header: glistarb.pls 120.7 2004/10/14 23:08:09 spala ship $ */

  --
  -- PRIVATE FUNCTIONS
  --
  --


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_criteria_set_Id                        NUMBER,
                     X_Je_Category_Name                 VARCHAR2,
                     X_Method_Code                      VARCHAR2,
                     X_Reversal_Period_Code             VARCHAR2,
                     X_Reversal_Date_Code               VARCHAR2,
                     X_Autoreverse_Flag                 VARCHAR2,
                     X_Autopost_Reversal_Flag           VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Context                          VARCHAR2
  ) IS

      CURSOR C IS
        SELECT *
        FROM   gl_autoreverse_options
        WHERE  rowid = X_Rowid
        FOR UPDATE of criteria_set_Id NOWAIT;

    Recinfo C%ROWTYPE;

  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.criteria_set_id =  X_criteria_set_Id)
           AND (Recinfo.je_category_name =  X_Je_Category_Name)
           AND (Recinfo.method_code =  X_Method_Code)
           AND (Recinfo.reversal_period_code =  X_Reversal_Period_Code)
           AND (Recinfo.reversal_date_code =  X_Reversal_Date_Code
                OR (    (Recinfo.reversal_date_code IS NULL)
                    AND (X_Reversal_Date_Code IS NULL)))
           AND (Recinfo.autoreverse_flag =  X_Autoreverse_Flag)
           AND (Recinfo.autopost_reversal_flag =  X_Autopost_Reversal_Flag)
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
      APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_criteria_set_Id                      NUMBER,
                       X_Je_Category_Name               VARCHAR2,
                       X_Method_Code                    VARCHAR2,
                       X_Reversal_Period_Code           VARCHAR2,
                       X_Reversal_Date_Code             VARCHAR2,
                       X_Autoreverse_Flag               VARCHAR2,
                       X_Autopost_Reversal_Flag         VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Context                        VARCHAR2

  ) IS
  BEGIN
    UPDATE gl_autoreverse_options
    SET
       criteria_set_id                 =     X_criteria_set_Id,
       je_category_name                =     X_Je_Category_Name,
       method_code                     =     X_Method_Code,
       reversal_period_code            =     X_Reversal_Period_Code,
       reversal_date_code              =     X_Reversal_Date_Code,
       autoreverse_flag                =     X_Autoreverse_Flag,
       autopost_reversal_flag          =     X_Autopost_Reversal_Flag,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15,
       context                         =     X_Context
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;

-- ************************************************************************
--   Called by Journal Category form
-- ************************************************************************
  PROCEDURE insert_reversal_cat( x_je_category_name       VARCHAR2,
                                 x_created_by             NUMBER,
                                 x_last_updated_by        NUMBER,
                                 x_last_update_login      NUMBER )  IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_autoreverse_options
      WHERE  je_category_name = x_je_category_name ;
    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%NOTFOUND THEN
      INSERT INTO gl_autoreverse_options (
             criteria_set_id,
             je_category_name,
             method_code,
             reversal_period_code,
             autoreverse_flag,
             autopost_reversal_flag,
             last_update_date, last_updated_by,
             created_by, creation_date,
             last_update_login)
      SELECT DISTINCT criteria_set_id,
             x_je_category_name,
             'S',
             'NO_DEFAULT',
             'N',
             'N',
             sysdate, x_last_updated_by,
             x_created_by, sysdate,
             x_last_update_login
      FROM   GL_AUTOREVERSE_OPTIONS;

    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_JE_CATEGORIES_PKG.insert_reversal_cat');
      RAISE;

  END insert_reversal_cat;

-- ************************************************************************
--   Called from Ledger form
-- ************************************************************************

  PROCEDURE insert_criteria_reversal_cat(
                                        x_criteria_set_id              NUMBER,
                                        x_created_by             NUMBER,
                                        x_last_updated_by        NUMBER,
                                        x_last_update_login      NUMBER )  IS
  BEGIN
      INSERT INTO gl_autoreverse_options (
             criteria_set_id,
             je_category_name,
             method_code,
             reversal_period_code,
             reversal_date_code,
             autoreverse_flag,
             autopost_reversal_flag,
             last_update_date, last_updated_by,
             created_by, creation_date,
             last_update_login)
      SELECT x_criteria_set_id,
             jc.je_category_name,
             decode(jc.je_category_name,
                    'Revalue Profit/Loss', 'C',
                    'MRC Open Balances','C',
                    'Income Statement Close','C',
                    'Income Offset','C',
                    'S'),
             decode(jc.je_category_name,
                    'Income Statement Close', 'SAME_PERIOD',
                    'Income Offset', 'SAME_PERIOD',
                    'Balance Sheet Close','NEXT_PERIOD',
                    'NO_DEFAULT'),
               decode(jc.je_category_name,
                    'Income Statement Close', 'LAST_DAY',
                    'Income Offset', 'LAST_DAY',
                    'Balance Sheet Close','FIRST_DAY',
                    NULL) ,

             'N',
             'N',
             sysdate, x_last_updated_by,
             x_created_by, sysdate,
             x_last_update_login
      FROM  GL_JE_CATEGORIES jc;



  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_AUTOREVERSE_OPTIONS_PKG.insert_ledger_reversal_cat');
      RAISE;

  END insert_criteria_reversal_cat;

END GL_AUTOREVERSE_OPTIONS_PKG;

/
