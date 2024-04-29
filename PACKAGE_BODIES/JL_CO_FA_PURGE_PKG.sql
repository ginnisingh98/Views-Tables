--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_PURGE_PKG" AS
/* $Header: jlcoftpb.pls 120.7 2006/09/20 17:04:30 abuissa ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_CO_FA_PURGE_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_CO_FA_PURGE_PKG.';

TYPE varchar2s is table of VARCHAR2(256) INDEX BY BINARY_INTEGER;
x_last_updated_by              NUMBER(15);
x_last_update_login            NUMBER(15);
x_request_id                   NUMBER(15);
x_program_application_id       NUMBER(15);
x_program_id                   NUMBER(15);
x_sysdate                      DATE;

PROCEDURE find_who_columns;
FUNCTION do_sql( p_string VARCHAR2) RETURN BOOLEAN;
FUNCTION STORAGE_FACTOR( p_table_name  IN       VARCHAR2,
                         p_rows_to_archive IN   NUMBER,
                         p_storage_factor  OUT NOCOPY  NUMBER)   RETURN BOOLEAN;
PROCEDURE create_output_headings( p_fiscal_year IN NUMBER);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_adjustment                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to purge jl_co_fa_adjustments table               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--            p_fiscal_year                                               --
--            p_option                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
--    10/23/98     Sujit dalai    Changed Messages                        --
--   10/26/98   Sujit Dalai   Changed. Excluded purging of                --
--                            jl_co_fa_retirements table                  --
--   05/26/00      Sujit dalai    Changed to include storage clause for   --
--                                backup table. Changed not process if    --
--                                are not posted to GL.                   --
--    06/30/99     Santosh Vaze   Fixed the bug with the function storage --
--                               factor.                                  --
----------------------------------------------------------------------------

PROCEDURE purge_adjustment( ERRBUF     OUT NOCOPY VARCHAR2,
                            RETCODE    OUT NOCOPY VARCHAR2,
                            p_book         VARCHAR2,
                            p_fiscal_year  number,
                            p_option       varchar2) IS

  x_deprn_calendar               fa_book_controls.deprn_calendar%TYPE;
  x_initial_period_counter       fa_book_controls.initial_period_counter%TYPE;
  x_current_fiscal_year          fa_book_controls.current_fiscal_year%TYPE;
  x_deprn_status                 fa_book_controls.deprn_status%TYPE;
  x_book_class                   fa_book_controls.book_class%TYPE;
  x_initial_fiscal_year          fa_deprn_periods.fiscal_year%TYPE;
  x_count                        NUMBER;
  x_index                        NUMBER(7);
  x_period_number                fa_calendar_types.number_per_fiscal_year%TYPE;
  x_start_period_counter         fa_deprn_periods.period_counter%TYPE;
  x_end_period_counter           fa_deprn_periods.period_counter%TYPE;
  x_adjustments_rows             NUMBER(15);
  x_adj_table                    VARCHAR2(30);
  x_oracle_username              VARCHAR2(30);
  x_adjustments_amount           NUMBER;
  x_storage_factor               NUMBER;
  x_string                       VARCHAR2(250);
  x_cursor                       INTEGER;
  x_row_processed                INTEGER;
  err_num                        NUMBER;
  err_msg                        VARCHAR2(2000);
  call_status                    BOOLEAN;
  NOT_POSTED_TO_GL               EXCEPTION;
  INVALID_FISCAL_YEAR            EXCEPTION;
  NOT_A_TAX_BOOK                 EXCEPTION;
  DEPRN_STATUS_NOT_C             EXCEPTION;
  STATUS_NOT_NEW_OR_ARCHIVE      EXCEPTION;
  NOT_PROCESSED_FOR_LAST_YEAR    EXCEPTION;
  STATUS_NOT_ARCHVD_OR_RSTORE    EXCEPTION;
  STATUS_NOT_PURGED_LAST_YEAR    EXCEPTION;
  STATUS_NOT_PURGED              EXCEPTION;
  STATUS_PURGED                  EXCEPTION;
  INCORRECT_SET_OF_ROWS          EXCEPTION;
  UNABLE_TO_DO_SQL               EXCEPTION;
  l_api_name            CONSTANT VARCHAR2(30) := 'PURGE_ADJUSTMENT';


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
     fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR');
     fnd_message.set_token('FISCAL_YEAR', p_fiscal_year);
     fnd_file.put_line( 1, fnd_message.get);
     fnd_message.set_name('JL', 'JL_CO_FA_PURGE_OPTION');
     fnd_message.set_token('OPTION', p_option);
     fnd_file.put_line( 1, fnd_message.get);
     fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
              ---------------------------------------------------------
              --             Find who_columns values                 --
              ---------------------------------------------------------

     find_who_columns;

             ---------------------------------------------------------
             --       get informaton from fa_book_controls          --
             ---------------------------------------------------------

   SELECT deprn_calendar,
          initial_period_counter,
          current_fiscal_year,
          deprn_status,
          book_class
     INTO x_deprn_calendar,
          x_initial_period_counter,
          x_current_fiscal_year,
          x_deprn_status,
          x_book_class
     FROM fa_book_controls
    WHERE book_type_code = p_book;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Deprn calendar :'||x_deprn_calendar);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deprn calendar :'||x_deprn_calendar);
      fnd_file.put_line( 1, 'Initial period Counter :'||to_char(x_initial_period_counter));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Initial period Counter :'||to_char(x_initial_period_counter));
      fnd_file.put_line( 1, 'Current fiscal year :'||x_current_fiscal_year);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Current fiscal year :'||x_current_fiscal_year);
      fnd_file.put_line( 1, 'Deprn Status :'||x_deprn_status);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deprn Status :'||x_deprn_status);
      fnd_file.put_line( 1, 'book class :'||x_book_class);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'book class :'||x_book_class);

    END IF;


             ---------------------------------------------------------
             -- Stop the program if input parameter p_fiscal_year   --
             -- is greater than equal to current_fiscal_year in     --
             -- fa_book_controls                                    --
             ---------------------------------------------------------

   IF p_fiscal_year >= x_current_fiscal_year THEN
     RAISE INVALID_FISCAL_YEAR;
   END IF;

             ---------------------------------------------------------
             -- Get intial fiscal year                              --
             ---------------------------------------------------------

   SELECT fiscal_year
     INTO x_initial_fiscal_year
     FROM fa_deprn_periods
    WHERE book_type_code = p_book
      AND period_counter = x_initial_period_counter;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_file.put_line( 1, 'Initial Fiscal year :'||x_initial_fiscal_year);
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Initial Fiscal year :'||x_initial_fiscal_year);
   END IF;

             ---------------------------------------------------------
             -- Show the error conditions and  finish the procedure --
             -- if any of the following conditions not satisfied    --
             ---------------------------------------------------------

             ---------------------------------------------------------
/*             -- Stop the program if book_class is not TAX           --
             ---------------------------------------------------------



    IF (x_book_class <> 'TAX') THEN
       RAISE NOT_A_TAX_BOOK;
    END IF; */

             ---------------------------------------------------------
             -- Stop the program if deprn_status for the book       --
             -- is not C.                                           --
             ---------------------------------------------------------

    IF (x_deprn_status <> 'C') THEN
      RAISE DEPRN_STATUS_NOT_C;
    END IF;

             ---------------------------------------------------------
             -- Check the conditions when option is ARCHAIVE        --
             ---------------------------------------------------------

     IF p_option = 'ARCHIVE' THEN

             ---------------------------------------------------------
             -- Stop the program if row exists for the couple       --
             -- book-year in jl_co_fa_purge and their status is     --
             -- 'RESTORED' or 'PURGED'                              --
             ---------------------------------------------------------

       SELECT count(*)
         INTO x_count
         FROM jl_co_fa_purge
        WHERE book_type_code = p_book
          AND fiscal_year = p_fiscal_year
          AND status IN ( 'RESTORED', 'PURGED');
       IF x_count <> 0 then
         RAISE STATUS_NOT_NEW_OR_ARCHIVE;
       END IF;

             ---------------------------------------------------------
             -- Stop the program if any of the processes archive,   --
             -- purge or restore are not done for previous fiscal   --
             -- year.                                               --
             ---------------------------------------------------------

       IF (p_fiscal_year > x_initial_fiscal_year) THEN
         SELECT count(*)
           INTO x_count
           FROM jl_co_fa_purge
          WHERE book_type_code = p_book
            AND fiscal_year = (p_fiscal_year -1)
            AND status  IN ('PURGED', 'ARCHIVED', 'RESTORE');
         IF (x_count = 0) THEN
           RAISE NOT_PROCESSED_FOR_LAST_YEAR;

         END IF;

       END IF;

     END IF;

             ---------------------------------------------------------
             -- Check the conditions when option is DELETE          --
             ---------------------------------------------------------

     IF (p_option = 'DELETE') THEN

             ---------------------------------------------------------
             -- Stop the program if row exists for the couple       --
             -- book-year in jl_co_fa_purge and their status is     --
             -- different from 'RESTORED' or 'ARCHAIVED'            --
             ---------------------------------------------------------

       SELECT count(*)
         INTO x_count
         FROM jl_co_fa_purge
        WHERE book_type_code = p_book
          AND fiscal_year = p_fiscal_year
          AND status  IN ('ARCHIVED', 'RESTORED');


       IF  (x_count = 0) THEN
         RAISE STATUS_NOT_ARCHVD_OR_RSTORE;
         null;
       END IF;

             ---------------------------------------------------------
             -- Stop the program if purge is not processed          --
             -- for previous fiscal year                            --
             ---------------------------------------------------------

       IF (p_fiscal_year > x_initial_fiscal_year) THEN
         SELECT count(*)
           INTO x_count
           FROM jl_co_fa_purge
          WHERE book_type_code = p_book
            AND fiscal_year = (p_fiscal_year -1)
            AND status  IN ('PURGED');
         IF (x_count = 0) THEN
           RAISE STATUS_NOT_PURGED_LAST_YEAR;

         END IF;

       END IF;

     END IF;

             ---------------------------------------------------------
             -- Check the conditions when option is RESTORE         --
             ---------------------------------------------------------

     IF (p_option = 'RESTORE') THEN

             ---------------------------------------------------------
             -- Stop the program if row exists for the couple       --
             -- book-year in jl_co_fa_purge and their status is     --
             -- different from 'PURGED'                             --
             ---------------------------------------------------------

       SELECT count(*)
         INTO x_count
         FROM jl_co_fa_purge
        WHERE book_type_code = p_book
          AND fiscal_year = p_fiscal_year
          AND status = 'PURGED';
       IF (x_count = 0) THEN
         RAISE STATUS_NOT_PURGED;

       END IF;

            ---------------------------------------------------------
            -- Stop the program if status for next fiscal year     --
            -- is 'PURGED'                                         --
            ---------------------------------------------------------

       IF (p_fiscal_year < x_current_fiscal_year) THEN

         SELECT count(*)
           INTO x_count
           FROM jl_co_fa_purge
          WHERE book_type_code = p_book
            AND fiscal_year = (p_fiscal_year +1)
            ANd status = 'PURGED';
         IF (x_count <> 0) THEN
           RAISE STATUS_PURGED;

         END IF;

       END IF;
    END IF;

             ---------------------------------------------------------
             -- find the row from jl_co_fa_purge                    --
             ---------------------------------------------------------

   SELECT  count(*)
     INTO  x_count
     FROM jl_co_fa_purge
    WHERE book_type_code = p_book
      AND fiscal_year = p_fiscal_year;

             ---------------------------------------------------------
             -- Insert a row if row is not available in             --
             -- jl_co_fa_purge                                      --
             ---------------------------------------------------------

   IF x_count = 0 THEN
     INSERT INTO jl_co_fa_purge(
                 purge_id,
                 book_type_code,
                 fiscal_year,
                 status,
                 appraisals_rows_archived,
                 appraisals_check_sum,
                 asset_apprs_rows_archived,
                 asset_apprs_check_sum,
                 adjustments_rows_archived,
                 adjustments_check_sum,
                 appraisal_books_rows_archived,
                 appraisal_books_check_sum,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_LOGIN,
                 request_id,
                 program_application_id,
                 program_id,
                 program_update_date)
         VALUES (jl_co_fa_purge_s.NEXTVAL,
                 p_book,
                 p_fiscal_year,
                 'NEW',
                 0,
                 0,
                 0,
                 0,
                 0,
                 0,
                 0,
                 0,
                 x_sysdate,
                 x_last_updated_by,
                 x_sysdate,
                 x_last_updated_by,
                 x_last_update_login,
                 x_request_id,
                 x_program_application_id,
                 x_program_id,
                 x_sysdate);

   END IF;

             ---------------------------------------------------------
             -- Store the purge_id for future use                   --
             ---------------------------------------------------------

   SELECT  purge_id
     INTO  x_index
     FROM jl_co_fa_purge
    WHERE book_type_code = p_book
      AND fiscal_year = p_fiscal_year;

   x_adj_table := 'JL_CO_FA_ADJUSTMENTS'||TO_CHAR(x_index);


             ---------------------------------------------------------
             -- Get Oracle username                                 --
             ---------------------------------------------------------

      SELECT u.oracle_username
        INTO x_oracle_username
        FROM fnd_oracle_userid u,
             fnd_product_installations p,
             fnd_application a
       WHERE a.application_short_name = 'JL'
         AND p.application_id = a.application_id
         AND  p.oracle_id = u.oracle_id;



             ---------------------------------------------------------
             -- Process for the options 'ARCHIVE' or 'PURGE'        --
             ---------------------------------------------------------


   IF (p_option IN ('ARCHIVE', 'DELETE')) THEN

             ---------------------------------------------------------
             -- Get the value of start period counter and end period--
             -- counter for the fiscal year                         --
             ---------------------------------------------------------

    /* SELECT number_per_fiscal_year
       INTO x_period_number
       FROM fa_calendar_types
      WHERE calendar_type = x_deprn_calendar;

     SELECT period_counter
       INTO x_start_period_counter
       FROM fa_deprn_periods
      WHERE book_type_code = p_book
        AND fiscal_year    = p_fiscal_year
        AND period_num     = 1;

    x_end_period_counter := x_start_period_counter + x_period_number; */

      SELECT MIN(period_counter),
             MAX(period_counter)
        INTO x_start_period_counter,
             x_end_period_counter
        FROM fa_deprn_periods
       WHERE book_type_code = p_book
        AND fiscal_year    = p_fiscal_year;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Start period Counter :' || to_char(x_start_period_counter));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Start period Counter :' || to_char(x_start_period_counter));
            fnd_file.put_line( 1, 'Start end Counter :' || to_char(x_end_period_counter));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Start end Counter :' || to_char(x_end_period_counter));
           END IF;


            ---------------------------------------------------------
            --Complete the process with error if any of the record --
            --in to be processed is not posted to GL               --
            ---------------------------------------------------------

    SELECT count(*)
     INTO x_count
     FROM jl_co_fa_adjustments
    WHERE book_type_code = p_book
      AND posting_flag <> 'C'
      AND period_counter_created >= x_start_period_counter
      AND period_counter_created <= x_end_period_counter;

   IF x_count <> 0 THEN
     RAISE NOT_POSTED_TO_GL;
   END IF;


            ---------------------------------------------------------
            -- Get no of row to be processed and sum of amount for --
            -- future check                                        --
            ---------------------------------------------------------

    SELECT count(*),
           NVL(SUM(adjustment_amount), 0)
     INTO x_adjustments_rows,
          x_adjustments_amount
     FROM jl_co_fa_adjustments
    WHERE book_type_code = p_book
      AND period_counter_adjusted >= x_start_period_counter
      AND period_counter_adjusted <= x_end_period_counter;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'adjustment rows :' || to_char(x_adjustments_rows));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'adjustment rows :' || to_char(x_adjustments_rows));
            fnd_file.put_line( 1, 'adjustment amount :' || to_char(x_adjustments_amount));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'adjustment amount :' || to_char(x_adjustments_amount));
           END IF;




             ---------------------------------------------------------
             -- If the option is 'ARCHIVED' then make following     --
             -- process                                             --
             ---------------------------------------------------------

    IF (p_option = 'ARCHIVE') THEN

      fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
      fnd_message.set_token('OPTION', p_option);
      fnd_file.put_line( 1, fnd_message.get);

             ---------------------------------------------------------
             -- Check weather backup table for adjustments is       --
             -- exists. Its name is jl_co_fa_adjustment with        --
             -- extension purge_id                                  --
             ---------------------------------------------------------

      SELECT count(*)
        INTO x_count
        FROM all_tables
       WHERE table_name = x_adj_table
         AND owner = x_oracle_username;

             ---------------------------------------------------------
             -- If backup table does exists then drop it            --
             ---------------------------------------------------------

       IF x_count <> 0 THEN

         x_string := 'drop table '||x_oracle_username||'.'||ltrim(rtrim(x_adj_table));

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQl statement to be processed :'||x_string);
           END IF;

         IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
         END IF;
       END IF;



             ---------------------------------------------------------
             -- create tables and insert the rows to be archived     --
             ---------------------------------------------------------

     IF NOT (storage_factor('JL_CO_FA_ADJUSTMENTS',
                            x_adjustments_rows,
                            x_storage_factor))        THEN

       RAISE UNABLE_TO_DO_SQL;

    END IF;

        x_string := 'create table '||x_oracle_username||'.'||ltrim(rtrim(x_adj_table))||
                    ' STORAGE( INITIAL '||TO_CHAR(ceil(x_storage_factor))||'K '||
                    'NEXT '||TO_CHAR(ceil(x_storage_factor/2))||'K '||
                    'MINEXTENTS 1 MAXEXTENTS 20 PCTINCREASE 100) '||
                    ' as select * from jl_co_fa_adjustments'||
                    ' where book_type_code ='||''''||p_book||''''||
                    ' and period_counter_adjusted >= '||to_char(x_start_period_counter)||
                    ' and period_counter_adjusted <= '||to_char(x_end_period_counter);

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQl statement to be processed :'||x_string);
           END IF;

        IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;



             ---------------------------------------------------------
             -- change the status in jl_co_fa_purge to 'ARCHIVE'    --
             ---------------------------------------------------------
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating  JL_CO_FA_PURGE');
           END IF;


      UPDATE jl_co_fa_purge SET
              adjustments_rows_archived = x_adjustments_rows,
              adjustments_check_sum = x_adjustments_amount,
              status = 'ARCHIVED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated  JL_CO_FA_PURGE');
           END IF;


   ELSE

     fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
     fnd_message.set_token('OPTION', p_option);
     fnd_file.put_line( 1, fnd_message.get);

             ---------------------------------------------------------
             -- If the option is purge then check for correct set   --
             -- of rows to be purged. Stop the program if anything  --
             -- is wrong                                            --
             ---------------------------------------------------------

     SELECT COUNT(*)
       INTO x_count
       FROM jl_co_fa_purge
      WHERE purge_id = x_index
        AND adjustments_rows_archived = x_adjustments_rows
        AND adjustments_check_sum = x_adjustments_amount;
     IF x_count = 0 THEN
       RAISE INCORRECT_SET_OF_ROWS;

     ELSE

             ---------------------------------------------------------
             -- Delete the rows from jl_co_fa_adjustments and       --

             -- change the status in jl_co_fa_purge to 'PURGED'     --
             ---------------------------------------------------------
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleting  JL_CO_FA_ADJUSTMENTS');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleting  JL_CO_FA_ADJUSTMENTS');
           END IF;

       DELETE FROM jl_co_fa_adjustments
             WHERE book_type_code = p_book
               AND period_counter_adjusted >= x_start_period_counter
               AND period_counter_adjusted <= x_end_period_counter;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleted  JL_CO_FA_ADJUSTMENTS');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleted  JL_CO_FA_ADJUSTMENTS');
           END IF;


           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating  JL_CO_FA_PURGE');
           END IF;


       UPDATE jl_co_fa_purge
          SET status = 'PURGED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated  JL_CO_FA_PURGE');
           END IF;

     END IF;
   END IF;
 ELSE

   fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
   fnd_message.set_token('OPTION', p_option);
   fnd_file.put_line( 1, fnd_message.get);

             ---------------------------------------------------------
             -- Process for the option 'RESTORE'                    --
             ---------------------------------------------------------

   x_string := 'insert into jl_co_fa_adjustments select * from  '||x_oracle_username||'.'||ltrim(rtrim(x_adj_table));
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQl statement to be processed :'||x_string);
            END IF;

  IF NOT (do_sql(x_string)) THEN
    RAISE UNABLE_TO_DO_SQL;
  END IF;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating  JL_CO_FA_PURGE');
           END IF;


  UPDATE jl_co_fa_purge
          SET status = 'RESTORED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated  JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated  JL_CO_FA_PURGE');
           END IF;

  END IF;
  commit;

  IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
  END IF;

EXCEPTION

   WHEN NOT_POSTED_TO_GL THEN
     fnd_message.set_name('JL', 'JL_CO_FA_NOT_POSTED_TO_GL');
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

   WHEN INVALID_FISCAL_YEAR THEN
     fnd_message.set_name('JL', 'JL_CO_FA_INVALID_FISCAL_YEAR');
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

   WHEN NOT_A_TAX_BOOK THEN
     fnd_message.set_name('JL', 'JL_CO_FA_INVALID_TAX_BOOK');
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN DEPRN_STATUS_NOT_C THEN
     fnd_message.set_name('JL', 'JL_CO_FA_DEPRECIATION_STATUS');
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN STATUS_NOT_NEW_OR_ARCHIVE THEN
    fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN NOT_PROCESSED_FOR_LAST_YEAR THEN
     fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR_NOT_PROC');
     fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year - 1));
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN STATUS_NOT_ARCHVD_OR_RSTORE THEN
     fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN STATUS_NOT_PURGED_LAST_YEAR THEN
     fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR_NOT_PROC');
     fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year - 1));
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN STATUS_NOT_PURGED THEN
     fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/


  WHEN STATUS_PURGED THEN
     fnd_message.set_name('JL', 'JL_CO_FA_PURGED');
     fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year +1));
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN INCORRECT_SET_OF_ROWS THEN
     fnd_message.set_name('JL', 'JL_CO_FA_INVALID_SET_OF_ROWS');
     fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year));
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  WHEN UNABLE_TO_DO_SQL THEN
    fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
    fnd_file.put_line( fnd_file.log, fnd_message.get);
    err_num := SQLCODE;
    err_msg := substr(SQLERRM, 1, 200);
    ROLLBACK;
    RAISE_APPLICATION_ERROR( err_num, err_msg);


  WHEN OTHERS THEN
      fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      err_num := SQLCODE;
      err_msg := substr(SQLERRM, 1, 200);
      ROLLBACK;
      RAISE_APPLICATION_ERROR( err_num, err_msg);

END purge_adjustment;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   purge_appraisal                                                      --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to purge the tables jl_co-fa_appraisals and       --
--   jl_co_fa_asset_apprs                                                 --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_fiscal_year                                               --
--            p_option                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
--    05/28/99      Sujit Dalai   Changed to provide storage criteria     --
--                                for backup tables and purge table       --
--                                JL_CO_FA_APPRAISAL_BOOKS. Also changed  --
--                                give message if any of appraisal infor  --
--                                mation to be purged has not been        --
--                                revalued.                               --
----------------------------------------------------------------------------
PROCEDURE purge_appraisal( ERRBUF    OUT NOCOPY VARCHAR2,
                           RETCODE   OUT NOCOPY VARCHAR2,
                           p_fiscal_year NUMBER,
                           p_option      VARCHAR2,
                           p_del_unproc_app VARCHAR2) IS

x_count                        NUMBER;
x_index                        NUMBER(7);
x_appr_table                   VARCHAR2(30);
x_asset_table		       VARCHAR2(30);
x_book_table                   VARCHAR2(30);
x_appraisal_rows               NUMBER;
x_appraisal_amount             NUMBER;
x_asset_rows                   NUMBER;
x_asset_amount                 NUMBER;
x_book_rows                    NUMBER;
x_book_amount                  NUMBER;
x_oracle_username              VARCHAR2(30);
x_string                       VARCHAR2(250);
x_cursor                       INTEGER;
x_row_processed                INTEGER;
x_storage_factor               NUMBER;
err_num                        NUMBER;
err_msg                        VARCHAR2(2000);
call_status                    BOOLEAN;
x_del_unproc_app               VARCHAR2(1);
STATUS_NOT_NEW_OR_ARCHIVE      EXCEPTION;
NOTHING_TO_ARCHIVE             EXCEPTION;
NOT_PROCESSED_FOR_LAST_YEAR    EXCEPTION;
STATUS_NOT_ARCHVD_OR_RSTORE    EXCEPTION;
STATUS_NOT_PURGED_LAST_YEAR    EXCEPTION;
STATUS_NOT_PURGED              EXCEPTION;
STATUS_PURGED                  EXCEPTION;
INCORRECT_SET_OF_ROWS          EXCEPTION;
UNABLE_TO_DO_SQL               EXCEPTION;
APPRAISAL_NOT_PROCESSED        EXCEPTION;
l_api_name            CONSTANT VARCHAR2(30) := 'PURGE_APPRAISAL';


BEGIN

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
     END IF;

     fnd_message.set_name('JL', 'JL_CO_FA_PARAMETER');
     fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
     fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
     fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR');
     fnd_message.set_token('FISCAL_YEAR', p_fiscal_year);
     fnd_file.put_line( 1, fnd_message.get);
     fnd_message.set_name('JL', 'JL_CO_FA_PURGE_OPTION');
     fnd_message.set_token('OPTION', p_option);
     fnd_file.put_line( 1, fnd_message.get);
     fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
             ---------------------------------------------------------
             -- Find who_columns values                             --
             ---------------------------------------------------------

find_who_columns;
             ---------------------------------------------------------
             -- Complete the process with error if any appraisal of --
             -- fiscal year is not processed                        --
             ---------------------------------------------------------
x_del_unproc_app := nvl(p_del_unproc_app, 'N');
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   fnd_file.put_line( 1, 'Delete erroneous appraisals PARAM:'||p_del_unproc_app);
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Delete erroneous appraisals PARAM:'||p_del_unproc_app);
   fnd_file.put_line( 1, 'Delete erroneous appraisals VAR  :'||x_del_unproc_app);
   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Delete erroneous appraisals VAR  :'||x_del_unproc_app);
END IF;

SELECT count(*)
  INTO x_count
  FROM jl_co_fa_appraisals
 WHERE fiscal_year = p_fiscal_year
   AND appraisal_status <> 'P';

IF x_count <> 0 THEN
   IF x_del_unproc_app = 'Y' THEN
       DELETE FROM jl_co_fa_asset_apprs
             WHERE appraisal_id IN (select appraisal_id
                                      from jl_co_fa_appraisals
                                     where fiscal_year = p_fiscal_year
                                       and appraisal_status <> 'P');
       DELETE FROM jl_co_fa_appraisal_books
             WHERE appraisal_id IN (select appraisal_id
                                      from jl_co_fa_appraisals
                                     where fiscal_year = p_fiscal_year
                                       and appraisal_status <> 'P');

       fnd_message.set_name('JL', 'JL_CO_FA_DELETED_APPRS');
       fnd_message.set_token('FISCAL_YEAR', p_fiscal_year);

       create_output_headings(p_fiscal_year);

       DELETE  FROM jl_co_fa_appraisals
        WHERE fiscal_year = p_fiscal_year
          AND appraisal_status <> 'P';
   ELSE
       fnd_message.set_name('JL', 'JL_CO_FA_DEL_UNPROC_APPRS');
       fnd_message.set_token('FISCAL_YEAR', p_fiscal_year);

       create_output_headings(p_fiscal_year);

       RAISE APPRAISAL_NOT_PROCESSED;
   END IF;
END IF;


             ---------------------------------------------------------
             -- Show the error conditions and  finish the procedure --
             -- if any of the following conditions not satisfied    --
             ---------------------------------------------------------
             ---------------------------------------------------------
             -- Check the conditions when option is ARCHAIVE        --
             ---------------------------------------------------------

IF p_option = 'ARCHIVE' THEN

             ---------------------------------------------------------
             -- Stop the program if there is no row in appraisals   --
             -- table to archive                                    --
             ---------------------------------------------------------
  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_appraisals
   WHERE fiscal_year = p_fiscal_year;
  If x_count = 0 THEN
    RAISE NOTHING_TO_ARCHIVE;
  END IF;

             ---------------------------------------------------------
             -- Stop the program if row exists for the year         --
             -- in jl_co_fa_purge and their status is               --
             -- 'RESTORED' or 'PURGED'                              --
             ---------------------------------------------------------

  SELECT count(*)
    INTO x_counT
    FROM jl_co_fa_purge
   WHERE book_type_code IS NULL
     AND fiscal_year = p_fiscal_year
     AND status IN ( 'RESTORED', 'PURGED');
  IF x_count <> 0 then
     RAISE STATUS_NOT_NEW_OR_ARCHIVE;
  END IF;

             ---------------------------------------------------------
             -- Stop the program if any of the processes archive,   --
             -- purge or restore are not done for previous fiscal   --
             -- year                                                --
             ---------------------------------------------------------

  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_appraisals
   WHERE fiscal_year = (p_fiscal_year - 1);

  IF x_count <> 0  THEN

      SELECT count(*)
      INTO x_count
      FROM jl_co_fa_purge
     WHERE book_type_code IS NULL
       AND fiscal_year = (p_fiscal_year -1)
       AND status  IN ('PURGED', 'ARCHIVED', 'RESTORE');
    IF (x_count <> 0) THEN
       RAISE NOT_PROCESSED_FOR_LAST_YEAR;

    END IF;

  END IF;

END IF;

             ---------------------------------------------------------
             -- Check the conditions when option is DELETE         --
             ---------------------------------------------------------

IF (p_option = 'DELETE') THEN

             ---------------------------------------------------------
             -- Stop the program if row exists for the couple       --
             -- book-year in jl_co_fa_purge and their status is     --
             -- different from 'RESTORED' or 'ARCHAIVED'            --
             ---------------------------------------------------------

  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_purge
   WHERE book_type_code  IS NULL
     AND fiscal_year = p_fiscal_year
     AND status  IN ('ARCHIVED', 'RESTORED');
  IF  (x_count = 0) THEN
    RAISE STATUS_NOT_ARCHVD_OR_RSTORE;
  END IF;

             ---------------------------------------------------------
             -- Stop the program if purge is not processed          --
             -- for previous fiscal year                            --
             ---------------------------------------------------------
  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_appraisals
   WHERE fiscal_year = (p_fiscal_year - 1);
  IF x_count <> 0  THEN
    SELECT count(*)
      INTO x_count
      FROM jl_co_fa_purge
     WHERE book_type_code IS NULL
       AND fiscal_year = (p_fiscal_year -1)
       AND status  IN ('PURGED');
    IF (x_count = 0) THEN
      RAISE STATUS_NOT_PURGED_LAST_YEAR;

    END IF;

  END IF;

END IF;

             ---------------------------------------------------------
             -- Check the conditions when option is RESTORE         --
             ---------------------------------------------------------

IF (p_option = 'RESTORE') THEN

             ---------------------------------------------------------
             -- Stop the program if row exists for the couple       --
             -- book-year in jl_co_fa_purge and their status is     --
             -- different from 'PURGED'                             --
             ---------------------------------------------------------

  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_purge
   WHERE book_type_code IS NULL
     AND fiscal_year = p_fiscal_year
     AND status = 'PURGED';
  IF (x_count = 0) THEN
     RAISE STATUS_NOT_PURGED;

  END IF;

             ---------------------------------------------------------
             -- Stop the program if status for next fiscal year     --
             -- is 'PURGED'                                         --
             ---------------------------------------------------------



  SELECT count(*)
    INTO x_count
    FROM jl_co_fa_purge
   WHERE book_type_code IS NULL
     AND fiscal_year = (p_fiscal_year +1)
     ANd status = 'PURGED';
  IF (x_count <> 0) THEN
     RAISE STATUS_PURGED;

  END IF;

END IF;

             ---------------------------------------------------------
             -- find the row from jl_co_fa_purge                    --
             ---------------------------------------------------------

SELECT  count(*)
  INTO  x_count
  FROM jl_co_fa_purge
 WHERE book_type_code IS NULL
   AND fiscal_year = p_fiscal_year;

             ---------------------------------------------------------
             -- Insert a row if row is not available in             --
             -- jl_co_fa_purge                                      --
             ---------------------------------------------------------

IF x_count = 0 THEN

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'Inserting row into JL_CO_FA_PURGE');
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserting row into JL_CO_FA_PURGE');
   END IF;

  INSERT INTO jl_co_fa_purge(
              purge_id,
              fiscal_year,
              status,
              appraisals_rows_archived,
              appraisals_check_sum,
              asset_apprs_rows_archived,
              asset_apprs_check_sum,
              adjustments_rows_archived,
              adjustments_check_sum,
              appraisal_books_rows_archived,
              appraisal_books_check_sum,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_LOGIN,
              request_id,
              program_application_id,
              program_id,
              program_update_date)
      VALUES (jl_co_fa_purge_s.NEXTVAL,
              p_fiscal_year,
              'NEW',
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              0,
              x_sysdate,
              x_last_updated_by,
              x_sysdate,
              x_last_updated_by,
              x_last_update_login,
              x_request_id,
              x_program_application_id,
              x_program_id,
              x_sysdate);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'Inserted row into JL_CO_FA_PURGE');
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserted row into JL_CO_FA_PURGE');
   END IF;



END IF;

             ---------------------------------------------------------
             -- Store the purge_id for future use                   --
             ---------------------------------------------------------

SELECT  purge_id
  INTO  x_index
  FROM jl_co_fa_purge
 WHERE book_type_code IS NULL
   AND fiscal_year = p_fiscal_year;

x_appr_table := 'JL_CO_FA_APPRAISALS'||TO_CHAR(x_index);
x_asset_table := 'JL_CO_FA_ASSET_APPRS'||TO_CHAR(x_index);
x_book_table  := 'JL_CO_FA_APPRAISAL_BOOKS'||TO_CHAR(x_index);


  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'Backup table for JL_CO_FA_APPRAISALS :'||x_appr_table);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Backup table for JL_CO_FA_APPRAISALS :'||x_appr_table);
    fnd_file.put_line( 1, 'Backup table for JL_CO_FA_ASSET_APPRS :'||x_asset_table);
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Backup table for JL_CO_FA_ASSET_APPRS :'||x_asset_table);
   END IF;

             ---------------------------------------------------------
             -- Get Oracle username                                 --
             ---------------------------------------------------------

      SELECT u.oracle_username
        INTO x_oracle_username
        FROM fnd_oracle_userid u,
             fnd_product_installations p,
             fnd_application a
       WHERE a.application_short_name = 'JL'
         AND p.application_id = a.application_id
         AND  p.oracle_id = u.oracle_id;




              ---------------------------------------------------------
              -- Process for the options 'ARCHIVE' or 'PURGE'        --
              ---------------------------------------------------------


IF (p_option IN ('ARCHIVE', 'DELETE')) THEN

              ---------------------------------------------------------
              -- Get no of row to be processed and sum of amount for --
              -- future check                                        --
              ---------------------------------------------------------

  SELECT count(*),
         SUM(NVL(appraisal_id, 0))
    INTO x_appraisal_rows,
         x_appraisal_amount
    FROM jl_co_fa_appraisals
   WHERE fiscal_year = p_fiscal_year;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'No of appraisal rows :'||to_char(x_appraisal_rows));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'No of appraisal rows :'||to_char(x_appraisal_rows));
    fnd_file.put_line( 1, 'Appraisal Amount :'||to_char(x_appraisal_amount));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Appraisal Amount :'||to_char(x_appraisal_amount));
   END IF;


   SELECT count(*),
         SUM(NVL(appraisal_value, 0))
    INTO x_asset_rows,
         x_asset_amount
    FROM jl_co_fa_asset_apprs
   WHERE appraisal_id IN (select appraisal_id
                            from jl_co_fa_appraisals
                           where fiscal_year = p_fiscal_year);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'No of asset rows :'||to_char(x_asset_rows));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'No of asset rows :'||to_char(x_asset_rows));
    fnd_file.put_line( 1, 'Asset Amount :'||to_char(x_asset_amount));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Asset Amount :'||to_char(x_asset_amount));
   END IF;

   SELECT count(*),
         SUM(NVL(appraisal_id, 0))
    INTO x_book_rows,
         x_book_amount
    FROM jl_co_fa_appraisal_books
   WHERE appraisal_id IN (select appraisal_id
                            from jl_co_fa_appraisals
                           where fiscal_year = p_fiscal_year);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    fnd_file.put_line( 1, 'No of appraisal_book rows :'||to_char(x_book_rows));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'No of appraisal_book rows :'||to_char(x_book_rows));
    fnd_file.put_line( 1, 'Appraisal_book Amount :'||to_char(x_book_amount));
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Appraisal_book Amount :'||to_char(x_book_amount));
   END IF;



             ---------------------------------------------------------
             -- Process for the option 'ARCHIVE'                    --
             ---------------------------------------------------------

  IF (p_option = 'ARCHIVE') THEN

    fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
    fnd_message.set_token('OPTION', p_option);
    fnd_file.put_line( 1, fnd_message.get);

              ---------------------------------------------------------
              -- Check weather backup tables for appraisal is exists.--
              -- Its name is jl_co_fa_appraisals with extension      --
              -- purge_id.                                           --
              ---------------------------------------------------------

    SELECT count(*)
      INTO x_count
      FROM all_tables
     WHERE table_name = x_appr_table
       AND owner = x_oracle_username;

             ---------------------------------------------------------
             -- If backup table does  exists then drop the table.   --
             ---------------------------------------------------------

     IF x_count <> 0 THEN
         x_string := 'drop table '||x_oracle_username||'.'||ltrim(rtrim(x_appr_table));
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQL statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

         IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;
     END IF;

             ---------------------------------------------------------
             -- Check weather backup tables for assets is exists.   --
             -- Its name is jl_co_fa_asset_apprs with extension     --
             -- purge_id                                            --
             ---------------------------------------------------------

     SELECT count(*)
      INTO x_count
      FROM all_tables
     WHERE table_name = x_asset_table
       AND owner = x_oracle_username;

             ---------------------------------------------------------
             -- If backup table does  exists then drop the table    --
             ---------------------------------------------------------

     IF x_count <> 0 THEN
        x_string := 'Drop table '||x_oracle_username||'.'||ltrim(rtrim(x_asset_table));
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

        IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

     END IF;

             ---------------------------------------------------------
             -- Check weather backup tables for books  is exists.   --
             -- Its name is jl_co_fa_appraisal_books with extension --
             -- purge_id                                            --
             ---------------------------------------------------------
     SELECT count(*)
      INTO x_count
      FROM all_tables
     WHERE table_name = x_book_table
       AND owner = x_oracle_username;


             ---------------------------------------------------------
             -- If backup table does  exists then drop the table    --
             ---------------------------------------------------------

     IF x_count <> 0 THEN
        x_string := 'Drop table '||x_oracle_username||'.'||ltrim(rtrim(x_book_table));
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

        IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

     END IF;

             ---------------------------------------------------------
             -- Create and insert the rows to be archived into the  --
             -- backup tables                                       --
             ---------------------------------------------------------

     IF NOT (storage_factor('JL_CO_FA_APPRAISALS',
                            x_appraisal_rows,
                            x_storage_factor)) THEN

       RAISE UNABLE_TO_DO_SQL;

    END IF;



      x_string := 'create table '||x_oracle_username||'.'||ltrim(rtrim(x_appr_table))||
                  ' STORAGE( INITIAL '||TO_CHAR(ceil(x_storage_factor))||'K '||
                  'NEXT '||TO_CHAR(ceil(x_storage_factor/2))||'K '||
                  'MINEXTENTS 1 MAXEXTENTS 20 PCTINCREASE 100) '||
                  ' as select * from jl_co_fa_appraisals'||
                 ' where fiscal_year = '||p_fiscal_year;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

      IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

     IF NOT (storage_factor('JL_CO_FA_ASSET_APPRS',
                            x_asset_rows,
                            x_storage_factor))        THEN

       RAISE UNABLE_TO_DO_SQL;

    END IF;

      x_string := 'create table '||x_oracle_username||'.'||ltrim(rtrim(x_asset_table))||
                  ' STORAGE( INITIAL '||TO_CHAR(ceil(x_storage_factor))||'K '||
                  'NEXT '||TO_CHAR(ceil(x_storage_factor/2))||'K '||
                  'MINEXTENTS 1 MAXEXTENTS 20 PCTINCREASE 100) '||
                ' as select * from jl_co_fa_asset_apprs'||
                  ' where appraisal_id in (select appraisal_id from jl_co_fa_appraisals'||
                  ' where fiscal_year = '||p_fiscal_year||')';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

     IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

     IF NOT (storage_factor('JL_CO_FA_APPRAISAL_BOOKS',
                            x_book_rows,
                            x_storage_factor))        THEN

       RAISE UNABLE_TO_DO_SQL;

    END IF;

      x_string := 'create table '||x_oracle_username||'.'||ltrim(rtrim(x_book_table))||
                  ' STORAGE( INITIAL '||TO_CHAR(ceil(x_storage_factor))||'K '||
                  'NEXT '||TO_CHAR(ceil(x_storage_factor/2))||'K '||
                  'MINEXTENTS 1 MAXEXTENTS 20 PCTINCREASE 100) '||
                'as select * from jl_co_fa_appraisal_books'||
                  ' where appraisal_id in (select appraisal_id from jl_co_fa_appraisals'||
                  ' where fiscal_year='||p_fiscal_year||')';
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'SQl statement to be processed :'||x_string);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'SQL statement to be processed :'||x_string);
           END IF;

     IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;


             ---------------------------------------------------------
             -- change the status in jl_co_fa_purge to 'ARCHIVE'    --
             ---------------------------------------------------------
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating JL_CO_FA_PURGE');
           END IF;


      UPDATE jl_co_fa_purge SET
              appraisals_rows_archived = x_appraisal_rows,
              appraisals_check_sum = x_appraisal_amount,
              asset_apprs_rows_archived = x_asset_rows,
              asset_apprs_check_sum = x_asset_amount,
              appraisal_books_rows_archived = x_book_rows,
              appraisal_books_check_sum = x_book_amount,
              status = 'ARCHIVED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated JL_CO_FA_PURGE');
           END IF;

   ELSE

     fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
     fnd_message.set_token('OPTION', p_option);
     fnd_file.put_line( 1, fnd_message.get);

             ---------------------------------------------------------
             -- If the option is purge then check for correct set   --
             -- of rows to be purged. Stop the program if anything  --
             -- is wrong                                            --
             ---------------------------------------------------------

     SELECT COUNT(*)
       INTO x_count
       FROM jl_co_fa_purge
      WHERE purge_id = x_index
        AND appraisals_rows_archived = x_appraisal_rows
        AND appraisals_check_sum = x_appraisal_amount
        AND asset_apprs_rows_archived = x_asset_rows
        AND asset_apprs_check_sum = x_asset_amount
        AND appraisal_books_rows_archived = x_book_rows
        AND appraisal_books_check_sum = x_book_amount;
     IF x_count = 0 THEN
       RAISE INCORRECT_SET_OF_ROWS;

     ELSE

             ---------------------------------------------------------
             -- Delete the rows from jl_co_fa_adjustments,          --
             -- jl_co_fa_appraisals and jl_co_fa_appraisal_books    --
             -- and change the status in jl_co_fa_purge to 'PURGED' --
             ---------------------------------------------------------

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleting JL_CO_FA_APPRAISALS');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleting JL_CO_FA_ASSET_APPRS');
           END IF;

       DELETE FROM jl_co_fa_asset_apprs
             WHERE appraisal_id IN (select appraisal_id
                                      from jl_co_fa_appraisals
                                     where fiscal_year = p_fiscal_year);

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleted JL_CO_FA_APPRAISALS');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleted JL_CO_FA_ASSET_APPRS');
           END IF;

       DELETE FROM jl_co_fa_appraisal_books
             WHERE appraisal_id IN (select appraisal_id
                                      from jl_co_fa_appraisals
                                     where fiscal_year = p_fiscal_year);


           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleting JL_CO_FA_Appraisals');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleting JL_CO_FA_Appraisals');
           END IF;



       DELETE FROM jl_co_fa_appraisals
              WHERE fiscal_year = p_fiscal_year;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Deleted JL_CO_FA_Appraisals');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Deleted JL_CO_FA_Appraisals');
           END IF;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating JL_CO_FA_PURGE');
           END IF;


       UPDATE jl_co_fa_purge
          SET status = 'PURGED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated JL_CO_FA_PURGE');
           END IF;

     END IF;
  END IF;

ELSE

  fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
  fnd_message.set_token('OPTION', p_option);
  fnd_file.put_line( 1, fnd_message.get);

             ---------------------------------------------------------
             -- Process for the option 'RESTORE'                    --
             ---------------------------------------------------------

  x_string := 'insert into jl_co_fa_appraisals  select * from '||x_oracle_username||'.'||ltrim(rtrim(x_appr_table));
  IF NOT (do_sql(x_string)) THEN
     RAISE UNABLE_TO_DO_SQL;
  END IF;
  x_string := 'insert into jl_co_fa_asset_apprs select * from '||x_oracle_username||'.'||ltrim(rtrim(x_asset_table));
  IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

  x_string := 'insert into jl_co_fa_appraisal_books select * from '||x_oracle_username||'.'||ltrim(rtrim(x_book_table));
  IF NOT (do_sql(x_string)) THEN
           RAISE UNABLE_TO_DO_SQL;
        END IF;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updating JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating JL_CO_FA_PURGE');
           END IF;

  UPDATE jl_co_fa_purge
          SET status = 'RESTORED',
              last_update_date = x_sysdate,
              last_updated_by  = x_last_updated_by,
              last_update_login = x_last_update_login,
              program_update_date = x_sysdate
      WHERE   purge_id = x_index;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Updated JL_CO_FA_PURGE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated JL_CO_FA_PURGE');
           END IF;

END IF;

commit;

IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
END IF;

EXCEPTION

WHEN APPRAISAL_NOT_PROCESSED THEN
  fnd_message.set_name('JL', 'JL_CO_FA_APPR_NOT_PROCESSED');
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN NOTHING_TO_ARCHIVE THEN
  fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
/*
  app_exception.raise_exception (exception_type => 'APP',
       exception_code =>
       jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_NOTHING_TO_PROCESS'),
       exception_text => err_msg);
*/

WHEN STATUS_NOT_NEW_OR_ARCHIVE THEN
  fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN NOT_PROCESSED_FOR_LAST_YEAR THEN
  fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR_NOT_PROC');
  fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year - 1));
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN STATUS_NOT_ARCHVD_OR_RSTORE THEN
  fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN STATUS_NOT_PURGED_LAST_YEAR THEN
  fnd_message.set_name('JL', 'JL_CO_FA_FISCAL_YEAR_NOT_PROC');
  fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year - 1));
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN STATUS_NOT_PURGED THEN
  fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN STATUS_PURGED THEN
  fnd_message.set_name('JL', 'JL_CO_FA_PURGED');
  fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year + 1));
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN INCORRECT_SET_OF_ROWS THEN
  fnd_message.set_name('JL', 'JL_CO_FA_INVALID_SET_OF_ROWS');
  fnd_message.set_token('FISCAL_YEAR', TO_CHAR(p_fiscal_year));
  err_msg := fnd_message.get;
  fnd_file.put_line(fnd_file.log, err_msg);
  call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
  fnd_message.raise_error;
*/

WHEN UNABLE_TO_DO_SQL THEN
  fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
  fnd_file.put_line( fnd_file.log, fnd_message.get);
  err_num := SQLCODE;
  err_msg := substr(SQLERRM, 1, 200);
  ROLLBACK;
  RAISE_APPLICATION_ERROR( err_num, err_msg);



 WHEN OTHERS THEN
    fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
      fnd_file.put_line( fnd_file.log, fnd_message.get);
      err_num := SQLCODE;
      err_msg := substr(SQLERRM, 1, 200);
      ROLLBACK;
      RAISE_APPLICATION_ERROR( err_num, err_msg);

END purge_appraisal;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   find_who_columns                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to get the values of who columns.                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
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

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   do_sql                                                               --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to create table dynamically in JL schema and      --
--   register to AOL.                                                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_string                                                    --
--                                                                        --
-- HISTORY:                                                               --
--    08/21/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

FUNCTION do_sql( p_string VARCHAR2) RETURN BOOLEAN IS



x_cursor               INTEGER;
x_row_processed        INTEGER;

BEGIN

x_cursor := DBMS_SQL.OPEN_CURSOR;
DBMS_SQL.PARSE( x_cursor, p_string, DBMS_SQL.V7);
x_row_processed := DBMS_SQL.EXECUTE( x_cursor);
DBMS_SQL.CLOSE_CURSOR( x_cursor);
RETURN (TRUE);


EXCEPTION
WHEN OTHERS THEN

  IF DBMS_SQL.IS_OPEN(x_cursor) THEN
    DBMS_SQL.CLOSE_CURSOR(x_cursor);
  END IF;
    RETURN (FALSE);


END do_sql;


----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   storage_factor                                                       --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this function  to get storage clause for backup table            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--        p_table_name      IN  VARCHAR2                                  --
--        p_rows_to_archive IN  NUMBER                                    --
--        p_storage_factor  OUT NOCOPY NUMBER                                    --
-- HISTORY:                                                               --
--    24/05/99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
FUNCTION STORAGE_FACTOR( p_table_name  IN       VARCHAR2,
                         p_rows_to_archive IN   NUMBER,
                         p_storage_factor  OUT NOCOPY  NUMBER)   RETURN BOOLEAN IS


  x_cursor               INTEGER;
  x_row_processed        INTEGER;
  x_statement            DBMS_SQL.VARCHAR2S;
  x_count                NUMBER := 1;
  x_avg_size             NUMBER;


  CURSOR c_column  IS
       SELECT column_name
         FROM sys.all_tab_columns
        WHERE table_name = UPPER(p_table_name);

BEGIN

            ---------------------------------------------------------
             -- Construct select statement to get average row size  --
             ---------------------------------------------------------

  x_statement(1) := 'SELECT ';
  FOR rec_column IN c_column LOOP

    x_count := x_count +1;
    x_statement(x_count) := 'avg(nvl(vsize('||rec_column.column_name||'), 0)) +';

  END LOOP;

  x_statement(x_count) := RTRIM( x_statement(x_count), '+');
  x_statement(x_count +1) := ' FROM '||UPPER(p_table_name);

             ---------------------------------------------------------
             -- Execute select statement using Dynamic SQL and get  --
             -- storgae factor for  the table                       --
             ---------------------------------------------------------


  x_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE( x_cursor,
                  x_statement,
                  1,
                  x_count+1,
                  TRUE,
                  DBMS_SQL.NATIVE);
  DBMS_SQL.DEFINE_COLUMN( x_cursor, 1, x_avg_size);
  x_row_processed := DBMS_SQL.EXECUTE_AND_FETCH(x_cursor, TRUE);
  DBMS_SQL.COLUMN_VALUE(x_cursor, 1, x_avg_size);
  DBMS_SQL.CLOSE_CURSOR( x_cursor);
  p_storage_factor := (p_rows_to_archive * x_avg_size)/1000;

 RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN

  IF DBMS_SQL.IS_OPEN(x_cursor) THEN
    DBMS_SQL.CLOSE_CURSOR(x_cursor);
  END IF;
  RETURN (FALSE);

END storage_factor;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   create_output_headings                                               --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to create column headings in the output file      --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5.2                                       --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_fiscal_year                                               --
--                                                                        --
-- HISTORY:                                                               --
--    04/21/00     Santosh Vaze   Created                                 --
----------------------------------------------------------------------------

PROCEDURE create_output_headings(p_fiscal_year NUMBER) IS

  x_output_line                  VARCHAR2(180);
  CURSOR c_unproc_appraisals  IS
         SELECT apprs.appraisal_id appraisal_id,
                fl.meaning appraisal_status,
                apprs.appraiser_name appraiser_name,
                apprs.appraisal_date appraisal_date
           FROM jl_co_fa_appraisals apprs, fnd_lookups fl
          WHERE apprs.fiscal_year = p_fiscal_year
            AND apprs.appraisal_status <> 'P'
            AND apprs.appraisal_status = fl.lookup_code
            AND fl.lookup_type = 'JLCO_FA_ASSET_APPRAISAL_STATUS'
         ORDER BY apprs.appraisal_id;

BEGIN

  fnd_file.put_line(fnd_file.output, fnd_message.get);
  fnd_message.set_name('JL', 'JL_CO_FA_APPR_NUM_OUT');
  fnd_file.put(fnd_file.output, SUBSTR(RPAD(fnd_message.get,20,' '),1,20) || '     ');
  fnd_message.set_name('JL', 'JL_CO_FA_APPRAISAL_STATUS_OUT');
  fnd_file.put(fnd_file.output, SUBSTR(RPAD(fnd_message.get,80,' '),1,80) || '     ');
  fnd_message.set_name('JL', 'JL_CO_FA_APPRAISER_NAME_OUT');
  fnd_file.put(fnd_file.output, SUBSTR(fnd_message.get,1,60));
  fnd_file.new_line(fnd_file.output,1);
  FOR line_ctr IN 1..4 LOOP
      fnd_file.put(fnd_file.output, '----------------------------------------');
  END LOOP;
  fnd_file.new_line(fnd_file.output,1);
  FOR rec_unproc_appraisals IN c_unproc_appraisals LOOP
      x_output_line := SUBSTR(RPAD(to_char(rec_unproc_appraisals.appraisal_id),20,' '),1,20)||'     ';
      x_output_line := x_output_line || SUBSTR(RPAD(rec_unproc_appraisals.appraisal_status,80,' '),1,80)||'     ';
      x_output_line := x_output_line || SUBSTR(rec_unproc_appraisals.appraiser_name,1,60);
      fnd_file.put_line(fnd_file.output, x_output_line);
  END LOOP;
  FOR line_ctr IN 1..4 LOOP
      fnd_file.put(fnd_file.output, '----------------------------------------');
  END LOOP;

END create_output_headings;

END jl_co_fa_purge_pkg;

/
