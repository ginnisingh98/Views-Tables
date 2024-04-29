--------------------------------------------------------
--  DDL for Package Body GL_JE_LINES_RECON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_LINES_RECON_PKG" as
/* $Header: glirclnb.pls 120.9.12010000.3 2009/10/09 11:21:42 dthakker ship $ */

  PROCEDURE insert_rows_for_batch(X_Je_Batch_Id         NUMBER,
                                  X_Last_Updated_By     NUMBER,
                                  X_Last_Update_Login   NUMBER) IS
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT jeh.je_header_id, jel.je_line_num, jeh.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_batches jeb, gl_je_headers jeh, gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc
    WHERE jeb.je_batch_id = X_Je_Batch_Id
    AND   jeb.average_journal_flag = 'N'
    AND   jeh.je_batch_id = X_Je_Batch_Id
    AND   jeh.actual_flag = 'A'
    AND   jeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   lgr.ledger_id = jeh.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   jel.je_header_id = jeh.je_header_id
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';
  END insert_rows_for_batch;

-- **********************************************************************

  PROCEDURE insert_rows_for_journal(X_Je_Header_Id      NUMBER,
                                    X_Last_Updated_By   NUMBER,
                                    X_Last_Update_Login NUMBER) IS
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT jel.je_header_id, jel.je_line_num, jel.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc
    WHERE jeh.je_header_id = X_Je_Header_Id
    AND   jeh.actual_flag = 'A'
    AND   jeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   jeb.je_batch_id = jeh.je_batch_id
    AND   jeb.average_journal_flag = 'N'
    AND   jel.je_header_id = X_Je_Header_Id
    AND   lgr.ledger_id = jel.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';
  END insert_rows_for_journal;

-- **********************************************************************

  PROCEDURE insert_rows_for_line(X_Je_Header_Id         NUMBER,
                                 X_Je_Line_Num          NUMBER,
                                 X_Last_Updated_By      NUMBER,
                                 X_Last_Update_Login    NUMBER) IS
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT jel.je_header_id, jel.je_line_num, jel.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc
    WHERE jeh.je_header_id = X_Je_Header_Id
    AND   jeh.actual_flag = 'A'
    AND   jeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   jeb.je_batch_id = jeh.je_batch_id
    AND   jeb.average_journal_flag = 'N'
    AND   jel.je_header_id = X_Je_Header_Id
    AND   jel.je_line_num = X_Je_Line_Num
    AND   lgr.ledger_id = jel.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';
  END insert_rows_for_line;

-- **********************************************************************

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Jgzz_Recon_Status              VARCHAR2,
                       X_Jgzz_Recon_Date                DATE,
                       X_Jgzz_Recon_Id                  NUMBER,
                       X_Jgzz_Recon_Ref                 VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
   ) IS
     CURSOR C IS SELECT rowid FROM GL_JE_LINES_RECON
                 WHERE je_header_id = X_Je_Header_Id
                 AND   je_line_num = X_Je_Line_Num;

    BEGIN

      INSERT INTO GL_JE_LINES_RECON (
               je_header_id,
               je_line_num,
               ledger_id,
               jgzz_recon_status,
               jgzz_recon_date,
               jgzz_recon_id,
               jgzz_recon_ref,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login
             ) VALUES (
               X_Je_Header_Id,
               X_Je_Line_Num,
               X_Ledger_id,
               X_Jgzz_Recon_Status,
               X_Jgzz_Recon_Date,
               X_Jgzz_Recon_Id,
               X_Jgzz_Recon_Ref,
               X_Last_Update_Date,
               X_Last_Updated_By,
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

-- **********************************************************************

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Je_Header_Id                     NUMBER,
                     X_Je_Line_Num                      NUMBER,
                     X_Ledger_Id                        NUMBER,
                     X_Jgzz_Recon_Status                VARCHAR2,
                     X_Jgzz_Recon_Date                  DATE,
                     X_Jgzz_Recon_Id                    NUMBER,
                     X_Jgzz_Recon_Ref                   VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_JE_LINES_RECON
        WHERE  rowid = X_Rowid
        FOR UPDATE of Je_Header_Id NOWAIT;
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
               (Recinfo.je_header_id = X_Je_Header_Id)
           AND (Recinfo.je_line_num = X_Je_Line_Num)
           AND (Recinfo.ledger_id = X_Ledger_id)
           AND (   (Recinfo.jgzz_recon_status = X_Jgzz_Recon_Status)
                OR (    (rtrim(Recinfo.jgzz_recon_status,' ') IS NULL)
                    AND (X_Jgzz_Recon_Status IS NULL)))
           AND (   (Recinfo.jgzz_recon_date = X_Jgzz_Recon_Date)
                OR (    (rtrim(Recinfo.jgzz_recon_date,' ') IS NULL)
                    AND (X_Jgzz_Recon_Date IS NULL)))
           AND (   (Recinfo.jgzz_recon_id = X_Jgzz_Recon_Id)
                OR (    (rtrim(Recinfo.jgzz_recon_id,' ') IS NULL)
                    AND (X_Jgzz_Recon_Id IS NULL)))
           AND (   (Recinfo.jgzz_recon_ref = X_Jgzz_Recon_Ref)
                OR (    (rtrim(Recinfo.jgzz_recon_ref,' ') IS NULL)
                    AND (X_Jgzz_Recon_Ref IS NULL)))
         ) then

      RETURN;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

-- **********************************************************************

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Ledger_Id                      NUMBER,
                       X_Jgzz_Recon_Status              VARCHAR2,
                       X_Jgzz_Recon_Date                DATE,
                       X_Jgzz_Recon_Id                  NUMBER,
                       X_Jgzz_Recon_Ref                 VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER
 ) IS
 BEGIN
   UPDATE GL_JE_LINES_RECON
   SET
     je_header_id                      =     X_Je_Header_Id,
     je_line_num                       =     X_Je_Line_Num,
     ledger_id                         =     X_Ledger_Id,
     jgzz_recon_status                 =     X_Jgzz_Recon_Status,
     jgzz_recon_date                   =     X_Jgzz_Recon_Date,
     jgzz_recon_id                     =     X_Jgzz_Recon_Id,
     jgzz_recon_ref                    =     X_Jgzz_Recon_Ref,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     last_update_login                 =     X_Last_Update_Login
   WHERE rowid = X_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

-- **********************************************************************

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2) IS
  BEGIN
    DELETE FROM GL_JE_LINES_RECON
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Delete_Row;

-- **********************************************************************

  FUNCTION insert_gen_line_recon_lines( X_Je_Header_Id       NUMBER,
                                        X_From_Je_Line_Num   NUMBER,
                                        X_Last_Updated_By    NUMBER,
                                        X_Last_Update_Login  NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT jel.je_header_id, jel.je_line_num, jel.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc
    WHERE jeh.je_header_id = X_Je_Header_Id
    AND   jeh.actual_flag = 'A'
    AND   jeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   jeh.display_alc_journal_flag IS NULL
    AND   jeb.je_batch_id = jeh.je_batch_id
    AND   jeb.average_journal_flag = 'N'
    AND   jel.je_header_id = X_Je_Header_Id
    AND   jel.je_line_num >= X_From_Je_Line_Num
    AND   lgr.ledger_id = jel.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';

    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_lines_recon_pkg.insert_gen_line_recon_lines');
      RAISE;
  END insert_gen_line_recon_lines;

-- **********************************************************************

  FUNCTION insert_alc_recon_lines( X_Prun_Id            NUMBER,
                                   X_Last_Updated_By    NUMBER,
                                   X_Last_Update_Login  NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT jel.je_header_id, jel.je_line_num, jel.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr, gl_je_lines jel,
         gl_code_combinations cc
    WHERE jeb.posting_run_id = X_Prun_Id
    AND   jeb.status = 'I'
    AND   jeb.average_journal_flag = 'N'
    AND   jeh.je_batch_id = jeb.je_batch_id
    AND   jeh.display_alc_journal_flag = 'N'
    AND   jeh.parent_je_header_id IS NOT NULL
    AND   jeh.actual_flag = 'A'
    AND   jeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   jel.je_header_id = jeh.je_header_id
    AND   lgr.ledger_id = jel.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   cc.code_combination_id = jel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';

    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_lines_recon_pkg.insert_alc_recon_lines');
      RAISE;
  END insert_alc_recon_lines;

-- **********************************************************************

  FUNCTION insert_sl_recon_lines( X_Prun_Id            NUMBER,
                                   X_Last_Updated_By    NUMBER,
                                   X_Last_Update_Login  NUMBER)
  RETURN NUMBER
  IS
    num_rows    NUMBER;
  BEGIN
    INSERT INTO gl_je_lines_recon
                (je_header_id, je_line_num, ledger_id,
                 creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, jgzz_recon_ref)
    SELECT sljel.je_header_id, sljel.je_line_num, sljel.ledger_id,
           sysdate, X_Last_Updated_By, sysdate,
           X_Last_Updated_By, X_Last_Update_Login, jeh.jgzz_recon_ref
    FROM gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr,
         gl_je_batches sljeb, gl_je_headers sljeh, gl_je_lines sljel,
         gl_code_combinations cc
    WHERE jeb.posting_run_id = X_Prun_Id
    AND   jeb.status = 'I'
    AND   jeh.je_batch_id = jeb.je_batch_id
    AND   jeh.reversed_je_header_id IS NULL -- added for bug8997202
    AND   sljeh.parent_je_header_id = jeh.je_header_id
    AND   sljeh.display_alc_journal_flag IS NULL
    AND   sljeh.actual_flag = 'A'
    AND   sljeh.je_source NOT IN ('Move/Merge', 'Move/Merge Reversal')
    AND   sljeb.je_batch_id = sljeh.je_batch_id
    AND   sljeb.average_journal_flag = 'N'
    AND   sljel.je_header_id = sljeh.je_header_id
    AND   lgr.ledger_id = sljel.ledger_id
    AND   lgr.enable_reconciliation_flag = 'Y'
    AND   cc.code_combination_id = sljel.code_combination_id
    AND   cc.jgzz_recon_flag = 'Y';

    num_rows := SQL%ROWCOUNT;
    RETURN (num_rows);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_je_lines_recon_pkg.insert_sl_recon_lines');
      RAISE;
  END insert_sl_recon_lines;

-- **********************************************************************

END GL_JE_LINES_RECON_PKG;

/
