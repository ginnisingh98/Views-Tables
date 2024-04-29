--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_POST_PKG" AS
/* $Header: jlcofgpb.pls 120.5 2008/01/26 04:50:30 vgadde ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_CO_FA_POST_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_CO_FA_POST_PKG.';

x_last_updated_by              NUMBER(15);
x_last_update_login            NUMBER(15);
x_request_id                   NUMBER(15);
x_program_application_id       NUMBER(15);
x_program_id                   NUMBER(15);
x_sysdate                      DATE;
x_statement                    VARCHAR2(20);

PROCEDURE find_who_columns;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_adjustment                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure for posting from jl_co_fa_adjustments table to    --
-- gl_interface table.                                                    --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
--    10/23/98     Sujit Dalai    Changed the messages                    --
----------------------------------------------------------------------------

PROCEDURE post(ERRBUF      OUT NOCOPY VARCHAR2,
               RETCODE     OUT NOCOPY VARCHAR2,
               p_book         VARCHAR2) IS

  x_set_of_book_id               fa_book_controls.set_of_books_id%TYPE;
  x_deprn_calendar               fa_book_controls.deprn_calendar%TYPE;
  x_gl_je_source                 xla_subledgers.je_source_name%TYPE;    -- Bug 5136047
  x_distribution_source_book     fa_book_controls.distribution_source_book%TYPE;
  x_period_counter               VARCHAR2(150);
  x_period_closed                VARCHAR2(150);
  x_user_je_source_name          gl_je_sources.user_je_source_name%TYPE;
  x_currency_code                gl_sets_of_books.currency_code%TYPE;
  x_period_name                  fa_deprn_periods.period_name%TYPE;
  x_end_date                     fa_calendar_periods.end_date%TYPE;
  x_status                       VARCHAR2(50) := 'NEW';
  x_actual_flag                  VARCHAR2(1)  := 'A';
  x_batch_name                   VARCHAR2(150);
  x_batch_description            VARCHAR2(150);
  x_journal_entry_name           VARCHAR2(150);
  x_journal_entry_description    VARCHAR2(150);
  x_entered_dr                   NUMBER;
  x_entered_cr                   NUMBER;
  call_status                    BOOLEAN;
  err_num                        NUMBER;
  err_msg                        VARCHAR2(200);
  SAME_AS_PERIOD_CLOSED          EXCEPTION;
  PERIOD_NOT_DEFINED             EXCEPTION;
  l_api_name            CONSTANT VARCHAR2(30) := 'POST';


  CURSOR c_category IS
   SELECT c.je_category_name,
         c.user_je_category_name
    FROM gl_je_categories c,
         fa_book_controls b
   WHERE b.book_type_code = p_book
    AND  c.je_category_name IN ( b.global_attribute6,
                                 b.global_attribute7,
                                 b.global_attribute8,
                                 b.global_attribute9,
                                 b.global_attribute10,
                                 b.global_attribute11,
                                 b.global_attribute12,
                                 b.global_attribute13,
                                 b.global_attribute14,
                                 b.global_attribute15,
                                 b.global_attribute16,
                                 b.global_attribute17,
                                 b.global_attribute18)
   UNION
   SELECT c.je_category_name,
         c.user_je_category_name
    FROM gl_je_categories c
   WHERE   c.je_category_name IN
       (SELECT b.je_category_name
         FROM xla_event_class_attrs b
         WHERE b.application_id = 140);

   CURSOR c_adjustment(p_counter  NUMBER,
                       p_je_category_name VARCHAR2) IS
   SELECT source_type_code,
          debit_credit_flag,
          code_combination_id,
          sum(adjustment_amount) x_amount
     FROM jl_co_fa_adjustments
    WHERE book_type_code = p_book
      AND period_counter_created = p_counter
      AND je_category_name = p_je_category_name
      AND NVL(posting_flag, 'E') <> 'C'
   GROUP BY source_type_code,
            debit_credit_flag,
            code_combination_id;



BEGIN

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
  END IF;

  fnd_message.set_name('JL', 'JL_CO_FA_PARAMETER');
  fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
  fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
  fnd_message.set_name('JL', 'JL_CO_FA_BOOK');
  fnd_message.set_token('BOOK', p_book);
  fnd_file.put_line( 1, fnd_message.get);
  fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');

              ---------------------------------------------------------
              --             Find who_columns values                 --
              ---------------------------------------------------------

        find_who_columns;

             ---------------------------------------------------------
             -- Get Depreciation  Book Parameter                 --
             ---------------------------------------------------------
  x_statement := 'BOOK_INFO';
/* Bug 5136047:
   In R12 due to SLA uptake, core FA no longer allows "GL journal entry source"
   to be entered using Book Controls window.
   "GL journal entry source" is set at the application level in SLA.
   Though, gl_je_source value is available in fa_book_controls
   for books upgraded from R11i, the source of truth is always as follows.
   The "GL journal entry source" will be derived from JE_SOURCE_NAME from
   XLA_SUBLEDGERS for application_id = 140.
   Hence, there is no need to look at fa_book_controls for books upgraded
   from R1i.

  SELECT bc.set_of_books_id,
         bc.deprn_calendar,
         bc.gl_je_source,
         bc.distribution_source_book,
         (bc.global_attribute19 +1), -- Period counter for which posting is to be performed.
         bc.global_attribute5,
         js.user_je_source_name
    INTO x_set_of_book_id,
         x_deprn_calendar,
         x_gl_je_source,
         x_distribution_source_book,
         x_period_counter,
         x_period_closed,
         x_user_je_source_name
    FROM fa_book_controls bc,
         gl_je_sources js
   WHERE book_type_code = p_book
     AND js.je_source_name = bc.gl_je_source;
*/

  SELECT bc.set_of_books_id,
         bc.deprn_calendar,
         bc.distribution_source_book,
         (bc.global_attribute19 +1), -- Period counter for which posting is to be performed.
         bc.global_attribute5
    INTO x_set_of_book_id,
         x_deprn_calendar,
         x_distribution_source_book,
         x_period_counter,
         x_period_closed
    FROM fa_book_controls bc
   WHERE book_type_code = p_book;

  SELECT xs.je_source_name,
         js.user_je_source_name
    INTO x_gl_je_source,
         x_user_je_source_name
    FROM gl_je_sources js,
         xla_subledgers xs
   WHERE js.je_source_name = xs.je_source_name
     AND xs.application_id = 140;


  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'Set of book id :'||to_char(x_set_of_book_id));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Set of book id :'||to_char(x_set_of_book_id));
    fnd_file.put_line( 1, 'Depreciation Calender :'||x_deprn_calendar);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Depreciation Calender :'||x_deprn_calendar);
    fnd_file.put_line( 1, 'Gl je source :'||x_gl_je_source);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Gl je source :'||x_gl_je_source);
    fnd_file.put_line( 1, 'Distribution source book :'||x_distribution_source_book);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Distribution source book :'||x_distribution_source_book);
    fnd_file.put_line( 1, 'Period counter :'||x_period_counter);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Period counter :'||x_period_counter);
    fnd_file.put_line( 1, 'Period closed :'||x_period_closed);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Period closed :'||x_period_closed);
    fnd_file.put_line( 1, 'User je source name :'||x_user_je_source_name );
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'User je source name :'||x_user_je_source_name );
   END IF;

             ---------------------------------------------------------
             -- Get Calendar parameters                             --
             ---------------------------------------------------------
  x_statement := 'CAL_INFO';
  SELECT period_name
    INTO x_period_name
    FROM fa_deprn_periods
   WHERE book_type_code = p_book
     AND period_counter = x_period_counter;

    -----------------------------------------------------------------------------
    --  Write close globalization period name on log file                      --
    -----------------------------------------------------------------------------

    fnd_message.set_name ('JL', 'JL_ZZ_FA_PERIOD_NAME');
    fnd_message.set_token ('PERIOD_NAME', x_period_name);
    fnd_file.put_line (1, fnd_message.get);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   fnd_file.put_line( 1, 'Period Name :'||x_period_name);
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Period Name :'||x_period_name);
  END IF;


  SELECT end_date
    INTO x_end_date
    FROM fa_calendar_periods
   WHERE calendar_type = x_deprn_calendar
     AND period_name = x_period_name;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'End Date :'||x_end_date);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'End Date :'||x_end_date);
  END IF;

             ---------------------------------------------------------
             -- If last period posted and period counters are not   --
             -- defined  then stop the program with error           --
             ---------------------------------------------------------

  IF ((x_period_counter IS NULL) OR (x_period_closed IS NULL)) THEN
    RAISE PERIOD_NOT_DEFINED;
  END IF;

  x_statement := 'CURR_INFO';
  SELECT currency_code
    INTO x_currency_code
    FROM gl_sets_of_books
   WHERE set_of_books_id = x_set_of_book_id;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'Currency Code :'||x_currency_code);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Currency Code :'||x_currency_code);
  END IF;

             ---------------------------------------------------------
             -- If last period posted is same as period closed by   --
             -- Globalization then stop the program with error      --
             ---------------------------------------------------------
  IF (NVL(x_period_counter, -998) -1) = NVL(x_period_closed, -999) THEN
     Raise SAME_AS_PERIOD_CLOSED;
  END IF;

             ---------------------------------------------------------
             -- Process following for each gl_category_name         --
             ---------------------------------------------------------

  FOR rec_category IN c_category LOOP

     fnd_message.set_name('JL', 'JL_CO_FA_JE_CATEGORY');
     fnd_message.set_token('JE_CATEGORY', rec_category.user_je_category_name);
     fnd_file.put_line( 1, fnd_message.get);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_file.put_line( 1, 'Je category name :'||rec_category.je_category_name);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Je category name :'||rec_category.je_category_name);
     END IF;

     x_batch_name := x_user_je_source_name||' '||rec_category.user_je_category_name||' '||
                     p_book||'/'||x_period_name;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_file.put_line( 1, 'Batch Name :'||x_batch_name);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Batch Name :'||x_batch_name);
     END IF;

     x_batch_description := p_book||'/'||x_period_name||' '||x_user_je_source_name||' '||
                            rec_category.user_je_category_name;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_file.put_line( 1, 'Batch description :'||x_batch_description);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Batch description :'||x_batch_description);
     END IF;

     x_journal_entry_name := x_batch_name;
     x_journal_entry_description := x_batch_description;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_file.put_line( 1, 'Journal Entry_name :'||x_journal_entry_name);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Journal Entry_name :'||x_journal_entry_name);
       fnd_file.put_line( 1, 'Journal Entry description :'||x_batch_description);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Journal Entry description :'||x_batch_description);
     END IF;


     FOR rec_adjustment IN c_adjustment(x_period_counter, rec_category.je_category_name) LOOP

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_file.put_line( 1, 'Book_type_code :'||rec_adjustment.source_type_code);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Book_type_code :'||rec_adjustment.source_type_code);
         fnd_file.put_line( 1, 'debit credit flag :'||rec_adjustment.debit_credit_flag);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'debit credit flag :'||rec_adjustment.debit_credit_flag);
         fnd_file.put_line( 1, 'code_combination_id :'||rec_adjustment.code_combination_id);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'code_combination_id :'||rec_adjustment.code_combination_id);
         fnd_file.put_line( 1, 'Amount :'||to_char(rec_adjustment.x_amount));
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Amount :'||to_char(rec_adjustment.x_amount));
      END IF;

      IF rec_adjustment.x_amount <> 0 THEN

        IF  (rec_adjustment.debit_credit_flag = 'DR') then
          x_entered_dr := rec_adjustment.x_amount;
          x_entered_cr := 0;
        ELSIF (rec_adjustment.debit_credit_flag = 'CR') then
          x_entered_dr := 0;
          x_entered_cr := rec_adjustment.x_amount;
        ELSE
          x_entered_dr := 0;
          x_entered_cr := 0;
        END IF;

        IF (x_entered_dr > 0 OR x_entered_cr >0 ) THEN


        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          fnd_file.put_line( 1, 'Inserting row into GL_INTERFACE');
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserting row into GL_INTERFACE');
        END IF;


        INSERT  INTO  gl_interface (status,
                                    set_of_books_id,
                                    accounting_date,
                                    currency_code,
                                    date_created,
                                    created_by,
                                    actual_flag,
                                    user_je_category_name,
                                    user_je_source_name,
                                    entered_dr,
                                    entered_cr,
                                    reference1,
                                    reference2,
                                    reference4,
                                    reference6,
                                    reference10,
                                    reference21,
                                    reference22,
                                    code_combination_id)
                            VALUES( x_status,
                                    x_set_of_book_id,
                                    x_end_date,
                                    x_currency_code,
                                    x_sysdate,
                                    x_last_updated_by,
                                    x_actual_flag,
                                    rec_category.user_je_category_name,
                                    x_user_je_source_name,
                                    x_entered_dr,
                                    x_entered_cr,
                                    x_batch_name,
                                    x_batch_description,
                                    x_journal_entry_name,
                                    p_book,
                                    x_batch_description,
                                    rec_category.je_category_name,
                                    jl_co_fa_adj_je_header_s.NEXTVAL,
                                    rec_adjustment.code_combination_id);


       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_file.put_line( 1, 'Inserted row into GL_INTERFACE');
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserted row into GL_INTERFACE');
       END IF;


             ---------------------------------------------------------
             -- Update jl_co_fa_adjustments                         --
             ---------------------------------------------------------

        UPDATE jl_co_fa_adjustments
           SET sequence_line = jl_co_fa_adj_je_header_s.CURRVAL,
               posting_flag = 'C',
               last_update_date = x_sysdate,
               last_updated_by = x_last_updated_by,
               last_update_login = x_last_update_login,
               program_update_date = x_sysdate
        WHERE  book_type_code = p_book
           AND je_category_name = rec_category.je_category_name
           AND NVL(posting_flag, 'E') <> 'C'
           AND period_counter_created = x_period_counter
           AND code_combination_id = rec_adjustment.code_combination_id
           AND debit_credit_flag = rec_adjustment.debit_credit_flag
           AND source_type_code = rec_adjustment.source_type_code;

      END IF;

      END IF;

    END LOOP;

  END LOOP;

  UPDATE fa_book_controls
     SET global_attribute19 = x_period_counter,
         last_update_date = x_sysdate,
         last_updated_by = x_last_updated_by
   WHERE book_type_code = p_book;

  COMMIT;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
  END IF;

EXCEPTION

  WHEN PERIOD_NOT_DEFINED THEN
    fnd_message.set_name('JL', 'JL_CO_FA_PERIOD_NOT_DEFINED');
    fnd_message.set_token('BOOK', p_book);
--  err_msg := fnd_message.get;
    fnd_file.put_line (fnd_file.log, fnd_message.get);
    call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
    app_exception.raise_exception (exception_type => 'APP',
       exception_code =>
       jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_PERIOD_NOT_DEFINED'),
       exception_text => err_msg);
*/

  WHEN SAME_AS_PERIOD_CLOSED THEN
    fnd_message.set_name('JL', 'JL_CO_FA_SAME_AS_PERIOD_CLOSED');
    fnd_message.set_token('BOOK', p_book);
    fnd_message.set_token('PERIOD', x_period_name);
--  err_msg := fnd_message.get;
    fnd_file.put_line (fnd_file.log, fnd_message.get);
    call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     app_exception.raise_exception (exception_type => 'APP',
       exception_code =>
       jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_SAME_AS_PERIOD_CLOSED'),
       exception_text => err_msg);
*/

  WHEN OTHERS THEN
      IF x_statement = 'BOOK_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '1');
--      err_msg := fnd_message.get;
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);
*/

      ELSIF x_statement = 'CURR_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '2');
--      err_msg := fnd_message.get;
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);
*/

      ELSIF x_statement = 'CAL_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '3');
--      err_msg := fnd_message.get;
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        app_exception.raise_exception (exception_type => 'APP',
        exception_code =>
        jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_ZZ_FA_EXEC_FAILURE'),
        exception_text => err_msg);
*/

      ELSE
        fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line( fnd_file.log, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        ROLLBACK;
        RAISE_APPLICATION_ERROR( err_num, err_msg);
      END IF;
END post;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   find_who_columns                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to find the values for WHO columns.               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
-- HISTORY:                                                               --
--    08/12/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE find_who_columns IS

    l_api_name           CONSTANT VARCHAR2(30) := 'FIND_WHO_COLUMNS';

  BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    x_last_updated_by := fnd_global.user_id;
    x_last_update_login := fnd_global.login_id;
    x_request_id := fnd_global.conc_request_id;
    x_program_application_id := fnd_global.prog_appl_id;
    x_program_id  := fnd_global.conc_program_id;
    x_sysdate     := SYSDATE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'last_update_login:'||to_char(x_last_update_login));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'last_update_login:'||to_char(x_last_update_login));
      fnd_file.put_line( 1, 'last_updated_by:'||to_char(x_last_updated_by));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'last_updated_by:'||to_char(x_last_updated_by));
      fnd_file.put_line( 1, 'last_request_id:'||to_char(x_request_id));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'last_request_id:'||to_char(x_request_id));
      fnd_file.put_line( 1, 'x_program_application_id :'||to_char(x_program_application_id ));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_program_application_id :'||to_char(x_program_application_id ));
      fnd_file.put_line( 1, 'x_program_id :'||to_char(x_program_id ));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_program_id :'||to_char(x_program_id ));
      fnd_file.put_line( 1, 'x_sysdate :'||to_char(x_sysdate ));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_sysdate :'||to_char(x_sysdate ));
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
    END IF;

END find_who_columns;

END jl_co_fa_post_pkg;

/
