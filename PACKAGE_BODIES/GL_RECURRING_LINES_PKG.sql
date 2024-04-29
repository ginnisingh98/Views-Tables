--------------------------------------------------------
--  DDL for Package Body GL_RECURRING_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RECURRING_LINES_PKG" as
/* $Header: glireclb.pls 120.3 2005/05/05 01:20:10 kvora ship $ */


  --
  -- PUBLIC FUNCTIONS
  --


  PROCEDURE check_unique( x_rowid VARCHAR2,
                          x_line_num  NUMBER,
                          x_header_id NUMBER ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   gl_recurring_lines l
      WHERE  l.recurring_line_num = x_line_num
      AND    l.recurring_header_id = x_header_id
      AND    ( x_rowid is NULL
               OR
               l.rowid <> x_rowid );

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_REC_LINE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_LINES_PKG.check_unique');
      RAISE;

  END check_unique;

  PROCEDURE check_dup_budget_acct( x_rowid VARCHAR2,
                                   x_ccid  NUMBER,
                                   x_batch_id NUMBER ) IS
    CURSOR c_dup IS
      SELECT 'Duplicate'
      FROM   dual
      WHERE  exists
              ( SELECT 'x'
                FROM gl_recurring_lines rl,
                     gl_recurring_headers rh,
                     gl_recurring_batches rb
                WHERE
                     rb.recurring_batch_id = x_batch_id
                AND  rb.recurring_batch_id = rh.recurring_batch_id
                AND  rh.recurring_header_id = rl.recurring_header_id
                AND  rl.code_combination_id = x_ccid
                AND  (   x_rowid is NULL
                      OR
                         rl.rowid <> x_rowid ));

    dummy VARCHAR2(100);

  BEGIN
    OPEN  c_dup;
    FETCH c_dup INTO dummy;

    IF c_dup%FOUND THEN
      CLOSE c_dup;
      fnd_message.set_name( 'SQLGL', 'GL_DUPLICATE_BUD_LINE' );
      app_exception.raise_exception;
    END IF;

    CLOSE c_dup;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_LINES_PKG.check_dup_budget_acct');
      RAISE;

  END check_dup_budget_acct;

-- **********************************************************************

  PROCEDURE delete_rows( x_header_id    NUMBER ) IS

  BEGIN

    DELETE
    FROM   GL_RECURRING_LINE_CALC_RULES
    WHERE  RECURRING_HEADER_ID = x_header_id;

    DELETE
    FROM   GL_RECURRING_LINES
    WHERE  RECURRING_HEADER_ID = x_header_id;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'GL_RECURRING_LINES_PKG.delete_rows');
      RAISE;

  END delete_rows;

-- **********************************************************************


  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Entered_Currency_Code          VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER
  ) IS
    CURSOR C IS SELECT rowid FROM GL_RECURRING_LINES
                 WHERE recurring_header_id = X_Recurring_Header_Id
                 and recurring_line_num = X_Recurring_Line_Num;

   BEGIN

-- Check for line uniqueness
check_unique(X_rowid, X_Recurring_Line_Num, X_Recurring_Header_Id );

   IF (X_Budget_Flag = 'Y') THEN
      check_dup_budget_acct( X_Rowid, X_Code_Combination_Id, X_Batch_Id);
   END IF;

       INSERT INTO GL_RECURRING_LINES(
              recurring_header_id,
              recurring_line_num,
              last_update_date,
              last_updated_by,
              code_combination_id,
              entered_currency_code,
              creation_date,
              created_by,
              last_update_login,
              description,
              entered_dr,
              entered_cr,
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
              context
             ) VALUES (

              X_Recurring_Header_Id,
              X_Recurring_Line_Num,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Code_Combination_Id,
              X_Entered_Currency_Code,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Description,
              X_Entered_Dr,
              X_Entered_Cr,
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
              X_Context

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
                     X_Recurring_Header_Id              NUMBER,
                     X_Recurring_Line_Num               NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Entered_Currency_Code            VARCHAR2,
                     X_Description                      VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
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
                     X_Context                          VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_RECURRING_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Recurring_Header_Id NOWAIT;
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

               (Recinfo.recurring_header_id =  X_Recurring_Header_Id)
           AND (Recinfo.recurring_line_num =  X_Recurring_Line_Num)
           AND (Recinfo.code_combination_id =  X_Code_Combination_Id)
           AND (   (Recinfo.entered_currency_code =  X_Entered_Currency_Code)
                OR (    (Recinfo.entered_currency_code IS NULL)
                    AND (X_Entered_Currency_Code IS NULL)))
           AND (   (Recinfo.description =  X_Description)
                OR (    (Recinfo.description IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.entered_dr =  X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr =  X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.context =  X_Context)
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
                       X_Recurring_Header_Id            NUMBER,
                       X_Recurring_Line_Num             NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Entered_Currency_Code          VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Description                    VARCHAR2,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
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
                       X_Context                        VARCHAR2,
                       X_Budget_Flag                    VARCHAR2,
                       X_Batch_Id                       NUMBER
  ) IS
  BEGIN
   -- Check for line uniqueness
   check_unique(X_rowid, X_Recurring_Line_Num, X_Recurring_Header_Id );

   IF (X_Budget_Flag = 'Y') THEN
      check_dup_budget_acct( X_Rowid, X_Code_Combination_Id, X_Batch_Id);
   END IF;

    UPDATE GL_RECURRING_LINES
    SET
       recurring_header_id             =     X_Recurring_Header_Id,
       recurring_line_num              =     X_Recurring_Line_Num,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       code_combination_id             =     X_Code_Combination_Id,
       entered_currency_code           =     X_Entered_Currency_Code,
       last_update_login               =     X_Last_Update_Login,
       description                     =     X_Description,
       entered_dr                      =     X_Entered_Dr,
       entered_cr                      =     X_Entered_Cr,
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
       context                         =     X_Context
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM GL_RECURRING_LINES
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;



-- **********************************************************************


END GL_RECURRING_LINES_PKG;

/
