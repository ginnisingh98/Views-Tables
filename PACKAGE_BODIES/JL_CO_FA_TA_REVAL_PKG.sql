--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_TA_REVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_TA_REVAL_PKG" AS
/* $Header: jlcoftrb.pls 120.4.12010000.2 2009/08/04 21:36:24 pakumare ship $ */


/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_CO_FA_TA_REVAL_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_CO_FA_TA_REVAL_PKG.';

x_last_updated_by              NUMBER(15);
x_last_update_login            NUMBER(15);
x_request_id                   NUMBER(15);
x_program_application_id       NUMBER(15);
x_program_id                   NUMBER(15);
x_sysdate                      DATE;
x_statement                    VARCHAR2(20);

PROCEDURE track_asset( p_book_type_code     VARCHAR2,
                      p_appraisal_id       number);


PROCEDURE insert_row( p_adjustment_type     VARCHAR2,
                      p_debit_credit_flag   VARCHAR2,
                      p_code_combination_id NUMBER,
                      p_book_type_code      VARCHAR2,
                      p_asset_id            NUMBER,
                      p_adjustment_amount   NUMBER,
                      p_period_counter      NUMBER,
                      p_distribution_id     fa_distribution_history.distribution_id%TYPE,
                       p_je_category_name    VARCHAR2,
                      p_reference           VARCHAR2);

PROCEDURE find_who_columns;


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   revaluate                                                            --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to revaluate technical appraisals                 --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--            p_book                                                      --
--            p_appraisal_id                                              --
--                                                                        --
-- HISTORY:                                                               --
--    08/12/98     Sujit Dalai    Created                                 --
--    10/21/98     Sujit Dalai    Changed the messages.                   --
----------------------------------------------------------------------------

PROCEDURE revaluate( ERRBUF     OUT NOCOPY VARCHAR2,
                     RETCODE    OUT NOCOPY VARCHAR2,
                     p_book            VARCHAR2,
                     p_appraisal_id    NUMBER)    IS

   x_set_of_book_id               fa_book_controls.set_of_books_id%TYPE;
   x_deprn_calendar               fa_book_controls.deprn_calendar%TYPE;
   x_book_class                   fa_book_controls.book_class%TYPE;
   x_gl_posting_allowed_flag      fa_book_controls.gl_posting_allowed_flag%TYPE;
   x_current_fiscal_year          fa_book_controls.current_fiscal_year%TYPE;
   x_accounting_flex_structure    fa_book_controls.accounting_flex_structure%TYPE;
   x_gl_je_source                 xla_subledgers.je_source_name%TYPE;    -- Bug 5136047
   x_distribution_source_book     fa_book_controls.distribution_source_book%TYPE;
   x_deprn_status                 fa_book_controls.deprn_status%TYPE;
   x_je_category_name             fa_book_controls.global_attribute13%TYPE;
   x_currency_code                gl_sets_of_books.currency_code%TYPE;
   x_period_name                  fa_deprn_periods.period_name%TYPE;
   x_user_je_source_name          gl_je_sources.user_je_source_name%TYPE;
   x_period_counter               fa_book_controls.last_period_counter%TYPE;
   x_count1                       NUMBER;
   x_end_date                     fa_calendar_periods.end_date%TYPE;
   x_appr_revaluation             jl_co_fa_asset_apprs.appraisal_value%TYPE := 0;
   x_prev_revaluation             jl_co_fa_asset_apprs.appraisal_value%TYPE := 0;
   x_net_revaluation              jl_co_fa_asset_apprs.appraisal_value%TYPE := 0;
   x_category_id                  fa_additions.asset_category_id%TYPE := 0;
   x_revaluation_account          fa_category_books.global_attribute11%TYPE := 0;
   x_surplus_account              fa_category_books.global_attribute12%TYPE := 0;
   x_reserve_account              fa_category_books.global_attribute13%TYPE := 0;
   x_expense_account              fa_category_books.global_attribute14%TYPE := 0;
   x_recovery_account             fa_category_books.global_attribute15%TYPE := 0;
   x_asset_cost_account_ccid      fa_category_books.asset_cost_account_ccid%TYPE;
   x_book                         varchar2(15);
   x_actual_cost_acct_ccid        NUMBER(15);
   x_cost_account_code            VARCHAR2(30);
   x_rtn_value                    NUMBER;
   x_asset_cost_acct_segval       fa_category_books.asset_cost_acct%TYPE;
   x_ccid                         NUMBER(15);
   x_appl_id                      NUMBER := 101;
   x_apps_short_name              VARCHAR2(15) := 'SQLGL';
   x_key_flex_code                VARCHAR2(15) := 'GL#';
   x_account_qualifier            VARCHAR2(20) := 'GL_ACCOUNT';
   x_account_segment_no           NUMBER;
   x_account_segment              VARCHAR2(30);
   x_temporal                     BOOLEAN;
   x_delimiter                    VARCHAR2(30);
   x_error_ccid                   BOOLEAN;
   x_category                     VARCHAR2(210);
   x_precision                    NUMBER(15);
   x_ext_precision                NUMBER(15);
   x_min_acct_unit                NUMBER(15);
   err_num                        NUMBER;
   err_msg                        VARCHAR2(2000);
   call_status                    BOOLEAN;
   NOT_A_TAX_BOOK                 EXCEPTION;
   INVALID_CCID                   EXCEPTION;
   CCID_NOT_FOUND                 EXCEPTION;
   GL_POSTING_NOT_ALLOWED         EXCEPTION;
  -- DIFF_FISCAL_YEAR               EXCEPTION;
   DEPRN_STATUS_NOT_C             EXCEPTION;
 --  REVALUATION_RUN                EXCEPTION;
   INVALID_CURRENCY_CODE          EXCEPTION;
   JE_CAT_NOT_DEFINED             EXCEPTION;
   l_api_name            CONSTANT VARCHAR2(30) := 'REVALUATE';


   CURSOR c_appraisal IS
   SELECT appraisal_id,
          currency_code,
          appraisal_date,
          fiscal_year
   FROM   jl_co_fa_appraisals
   WHERE  appraisal_id = p_appraisal_id
   FOR UPDATE OF appraisal_status;

   CURSOR c_asset(p_appr_id NUMBER,
                  p_period_counter NUMBER )  IS

   SELECT ap.asset_number,
          ap.appraisal_value,
          ad.asset_category_id,
          ad.asset_id,
          ad.current_units,
          nvl(ab.cost,0) cost,
          fnd_number.canonical_to_number(nvl(ab.global_attribute2,0)) prev_revaluation,
          nvl(dr.deprn_reserve,0) deprn_reserve,
          ab.date_placed_in_service
   FROM   jl_co_fa_asset_apprs ap,
          fa_additions ad,
          fa_books ab,
          fa_deprn_summary dr
   WHERE  ap.asset_number = ad.asset_number
      AND ap.appraisal_id = p_appr_id
      AND ad.asset_id = ab.asset_id
      AND ab.book_type_code = p_book
      AND dr.book_type_code (+) = p_book
      AND dr.asset_id (+) = ad.asset_id
      AND dr.period_counter (+) = p_period_counter
      AND ab.transaction_header_id_out IS NULL
      AND ab.date_ineffective IS NULL
  ORDER BY ad.asset_category_id
  FOR UPDATE OF ap.status;

  CURSOR c_distribution(p_asset_id    fa_additions.asset_id%TYPE,
                        p_book_type   VARCHAR2) IS

  SELECT distribution_id,
         units_assigned,
         code_combination_id,
         transaction_units
    FROM fa_distribution_history
   WHERE book_type_code = p_book_type
     AND transaction_header_id_out IS NULL
     AND date_ineffective IS NULL
     AND asset_id = p_asset_id;


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
     fnd_message.set_name('JL', 'JL_CO_FA_APPR_NUMBER');
     fnd_message.set_token('APPRAISAL_NUMBER', p_appraisal_id);
     fnd_file.put_line( 1, fnd_message.get);
     fnd_file.put_line(FND_FILE.LOG, '----------------------------------------');
              ---------------------------------------------------------
              --             Find who_columns values                 --
              ---------------------------------------------------------


     find_who_columns;

             ---------------------------------------------------------
             -- get information regarding the book from             --
             -- fa_book_of_controls, gl_sets_of_books,              --
             -- gl_je_sources, fa_deprn_period and                  --
             -- fa_calender_periods                                 --
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
            bc.book_class,
            bc.gl_posting_allowed_flag,
            bc.current_fiscal_year,
            bc.accounting_flex_structure,
            bc.gl_je_source,
            bc.distribution_source_book,
            bc.last_period_counter,
            bc.deprn_status,
            bc.global_attribute13,
            sb.currency_code,
            js.user_je_source_name,
            dp.period_name,
            cp.end_date
     INTO   x_set_of_book_id,
            x_deprn_calendar,
            x_book_class,
            x_gl_posting_allowed_flag,
            x_current_fiscal_year,
            x_accounting_flex_structure,
            x_gl_je_source,
            x_distribution_source_book,
            x_period_counter,
            x_deprn_status,
            x_je_category_name,
            x_currency_code,
            x_user_je_source_name,
            x_period_name,
            x_end_date
     FROM   fa_book_controls    bc,
            gl_sets_of_books    sb,
            gl_je_sources       js,
            fa_deprn_periods    dp,
            fa_calendar_periods cp
     WHERE  bc.book_type_code = p_book
        AND sb.set_of_books_id = bc.set_of_books_id
        AND js.je_source_name = bc.gl_je_source
        AND dp.book_type_code = p_book
        AND dp.period_counter = bc.last_period_counter
        AND cp.calendar_type  = bc.deprn_calendar
        AND cp.period_name    = dp.period_name;
*/

     SELECT bc.set_of_books_id,
            bc.deprn_calendar,
            bc.book_class,
            bc.gl_posting_allowed_flag,
            bc.current_fiscal_year,
            bc.accounting_flex_structure,
            bc.distribution_source_book,
            bc.last_period_counter,
            bc.deprn_status,
            bc.global_attribute13,
            sb.currency_code,
            dp.period_name,
            cp.end_date
     INTO   x_set_of_book_id,
            x_deprn_calendar,
            x_book_class,
            x_gl_posting_allowed_flag,
            x_current_fiscal_year,
            x_accounting_flex_structure,
            x_distribution_source_book,
            x_period_counter,
            x_deprn_status,
            x_je_category_name,
            x_currency_code,
            x_period_name,
            x_end_date
     FROM   fa_book_controls    bc,
            gl_sets_of_books    sb,
            fa_deprn_periods    dp,
            fa_calendar_periods cp
     WHERE  bc.book_type_code = p_book
        AND sb.set_of_books_id = bc.set_of_books_id
        AND dp.book_type_code = p_book
        AND dp.period_counter = bc.last_period_counter
        AND cp.calendar_type  = bc.deprn_calendar
        AND cp.period_name    = dp.period_name;

    SELECT xs.je_source_name,
           js.user_je_source_name
      INTO x_gl_je_source,
           x_user_je_source_name
      FROM gl_je_sources js,
           xla_subledgers xs
     WHERE js.je_source_name = xs.je_source_name
       AND xs.application_id = 140;


     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

       fnd_file.put_line( 1, 'set_of_book_id :'||to_char(x_set_of_book_id) );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'set_of_book_id :'||to_char(x_set_of_book_id) );
       fnd_file.put_line( 1, 'deprn_calendar:'||x_deprn_calendar);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'deprn_calendar:'||x_deprn_calendar);
       fnd_file.put_line( 1, 'x_book_class :'||x_book_class);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_book_class :'||x_book_class);
       fnd_file.put_line( 1, 'x_gl_posting_allowed_flag :'||x_gl_posting_allowed_flag);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_gl_posting_allowed_flag :'||x_gl_posting_allowed_flag);
       fnd_file.put_line( 1, 'x_current_fiscal_year :'||to_char(x_current_fiscal_year) );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_current_fiscal_year :'||to_char(x_current_fiscal_year) );
       fnd_file.put_line( 1, 'x_accounting_flex_structure :'||to_char(x_accounting_flex_structure) );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_accounting_flex_structure :'||to_char(x_accounting_flex_structure) );
       fnd_file.put_line( 1, 'x_gl_je_source :'||x_gl_je_source);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_gl_je_source :'||x_gl_je_source);
       fnd_file.put_line( 1, 'x_distribution_source_book :'||x_distribution_source_book);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_distribution_source_book :'||x_distribution_source_book);
       fnd_file.put_line( 1, 'x_period_counter :'||to_char(x_period_counter) );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_period_counter :'||to_char(x_period_counter) );
       fnd_file.put_line( 1, 'x_deprn_status :'||x_deprn_status) ;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_deprn_status :'||x_deprn_status) ;
       fnd_file.put_line( 1, 'x_je_category_name :'||x_je_category_name) ;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_je_category_name :'||x_je_category_name) ;
       fnd_file.put_line( 1, 'x_currency_code :'||x_currency_code);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_currency_code :'||x_currency_code);
       fnd_file.put_line( 1, 'x_user_je_source_name :'||x_user_je_source_name) ;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_user_je_source_name :'||x_user_je_source_name);
       fnd_file.put_line( 1, 'x_period_name :'||x_period_name);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_period_name :'||x_period_name);
       fnd_file.put_line( 1, 'x_end_date :'||to_char(x_end_date));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_end_date :'||to_char(x_end_date));


     END IF;


             ---------------------------------------------------------
             -- Show the error conditions and  finish the procedure --
             -- if any of the following conditions not satisfied    --
             ---------------------------------------------------------


    /* IF (x_gl_posting_allowed_flag <> 'YES') THEN
       RAISE GL_POSTING_NOT_ALLOWED;
     END IF; */


     IF (x_deprn_status <> 'C') THEN
       RAISE DEPRN_STATUS_NOT_C;
     END IF;

     IF (x_je_category_name IS NULL) THEN
       RAISE JE_CAT_NOT_DEFINED;
     END IF;

             ---------------------------------------------------------
             -- Get ccid segment information                        --
             ---------------------------------------------------------
     x_statement := 'FLEX_INFO';
     x_delimiter := fnd_flex_ext.get_delimiter (x_apps_short_name,
                                               x_key_flex_code,
                                               x_accounting_flex_structure
                                              );

     x_temporal := fnd_flex_apis.get_qualifier_segnum
                        (x_appl_id,
                         x_key_flex_code,
                         x_accounting_flex_structure,
                         x_account_qualifier,
                         x_account_segment_no);


    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

       fnd_file.put_line( 1, 'Balancing Qualifier :'||x_account_qualifier );
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Balancing Qualifier :'||x_account_qualifier);
       fnd_file.put_line( 1, 'Balancing segment no :'||to_char(x_account_segment_no));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Balancing segment no :'||to_char(x_account_segment_no));
    END IF;

             ---------------------------------------------------------
             -- Get Currency Information                            --
             ---------------------------------------------------------
    x_statement := 'CURR_INFO';
    fnd_currency.get_info( currency_code => x_currency_code,
                          precision => x_precision,
                          ext_precision => x_ext_precision,
                          min_acct_unit => x_min_acct_unit);
             ---------------------------------------------------------
             -- Start processing appraisals                         --
             ---------------------------------------------------------

    <<appraisals>>

    FOR rec_appraisal IN c_appraisal LOOP

      fnd_message.set_name('JL', 'JL_CO_FA_APPR_MESG');
      fnd_message.set_token('APPRAISAL_NUMBER', rec_appraisal.appraisal_id);
      fnd_file.put_line( 1, fnd_message.get);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line( 1, 'Currency code in appraisal :'||rec_appraisal.currency_code);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Currency code in appraisal :'||rec_appraisal.currency_code);
        fnd_file.put_line( 1, 'Appraisal Date :'||rec_appraisal.appraisal_date);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Appraisal Date :'||rec_appraisal.appraisal_date);
      END IF;

   /*   IF (x_current_fiscal_year <> rec_appraisal.fiscal_year) THEN
         RAISE DIFF_FISCAL_YEAR;
      END IF;

      SELECT count(*)
        INTO x_count1
        FROM jl_co_fa_adjustments
       WHERE book_type_code = p_book
         AND reference   = rec_appraisal.appraisal_id
         AND rownum < 2; */


             ---------------------------------------------------------
             -- Discard the appraisals in case of following         --
             -- conditions ie. revaluation is done for the appraisal--
             -- and currency_code is different                      --
             ---------------------------------------------------------

      /*IF (x_count1 > 0) THEN

        RAISE REVALUATION_RUN;  */

      IF (rec_appraisal.currency_code <> x_currency_code) THEN

        RAISE INVALID_CURRENCY_CODE;

      ELSE

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line( 1, 'appraisal_id : '||to_char(rec_appraisal.appraisal_id));
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'appraisal_id : '||to_char(rec_appraisal.appraisal_id));
        fnd_file.put_line( 1, 'End_date : '||x_end_date);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'End_date : '||x_end_date);
      END IF;

             ---------------------------------------------------------
             -- Get the assets for the appraisals. select the assets--
             -- those are open for the depreciation book and not    --
             -- retired.                                            --
             ---------------------------------------------------------

      <<assets>>

      FOR rec_asset IN c_asset(rec_appraisal.appraisal_id, x_period_counter) LOOP

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

          fnd_file.put_line( 1, 'Asset_Number :'||rec_asset.asset_number);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Asset_Number :'||rec_asset.asset_number);
          fnd_file.put_line( 1, 'Appraisal value :'||to_char(rec_asset.appraisal_value));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Appraisal value :'||to_char(rec_asset.appraisal_value));
          fnd_file.put_line( 1, 'Asset Category Id :'||to_char(rec_asset.asset_category_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Asset Category Id :'||to_char(rec_asset.asset_category_id));
          fnd_file.put_line( 1, 'Asset Id :'||to_char(rec_asset.asset_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Asset Id :'||to_char(rec_asset.asset_id));
          fnd_file.put_line( 1, 'Asset Cost :'||to_char(rec_asset.cost));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Asset Cost :'||to_char(rec_asset.cost));
          fnd_file.put_line( 1, 'Previous revaluation :'||rec_asset.prev_revaluation);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Previous revaluation :'||rec_asset.prev_revaluation);
          fnd_file.put_line( 1, 'Depreciation reserve :'||to_char(rec_asset.deprn_reserve));
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Depreciation reserve :'||to_char(rec_asset.deprn_reserve));
        END IF;

             ---------------------------------------------------------
             -- If asset cost is zero or has a future date placed in--
             -- service then do not process it                      --

             ---------------------------------------------------------

        IF (NVL(rec_asset.cost, 0) = 0) THEN

          fnd_message.set_name('JL', 'JL_ZZ_FA_ASSET_RETIRED');
          fnd_message.set_token('ASSET_NUMBER', rec_asset.asset_number);
          fnd_message.set_token('BOOK', p_book);
          fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
          x_temporal := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');
          null;
     /*   ELSIF (rec_asset.date_placed_in_service > x_end_date) THEN

          fnd_message.set_name('JL', 'JL_ZZ_FA_FUTURE_DATE');
          fnd_message.set_token('ASSET_NUMBER', rec_asset.asset_number);
          fnd_message.set_token('BOOK', p_book);
          fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
          x_temporal := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');*/
        ELSE

             ---------------------------------------------------------
             -- Calculate Appraisal Revaluation, previous           --
             -- revaluation, net revaluation  for the asset         --
             ---------------------------------------------------------

            x_appr_revaluation:= rec_asset.appraisal_value - (rec_asset.cost - rec_asset.deprn_reserve);
            x_prev_revaluation := rec_asset.prev_revaluation;
            x_net_revaluation  := x_appr_revaluation - x_prev_revaluation;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

              fnd_file.put_line( 1, 'Appraisal Revaluation :'||to_char(x_appr_revaluation));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Appraisal Revaluation :'||to_char(x_appr_revaluation));
              fnd_file.put_line( 1, 'Previous Revaluation :'||to_char(x_prev_revaluation));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Previous Revaluation :'||to_char(x_prev_revaluation));
              fnd_file.put_line( 1, 'Net Revaluation :'||to_char(x_net_revaluation));
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Net Revaluation :'||to_char(x_net_revaluation));

            END IF;

             ---------------------------------------------------------
             -- Find accounts and natural account segment values    --
             -- from FA_CATEGORY_BOOKS                              --
             ---------------------------------------------------------

            IF (x_category_id <> rec_asset.asset_category_id) THEN
              x_category_id  :=  rec_asset.asset_category_id;
              x_statement := 'ACCT_INFO';
              SELECT asset_cost_account_ccid,
                     asset_cost_acct,
                     NVL(global_attribute11, 0),
                     NVL(global_attribute12, 0),
                     NVL(global_attribute13, 0),
                     NVL(global_attribute14, 0),
                     NVL(global_attribute15, 0)
              INTO   x_asset_cost_account_ccid,
                     x_asset_cost_acct_segval,
                     x_revaluation_account,
                     x_surplus_account,
                     x_reserve_account,
                     x_expense_account,
                     x_recovery_account
              FROM   fa_category_books
              WHERE  category_id = x_category_id
                     AND book_type_code = p_book;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             fnd_file.put_line( 1, 'For Category ID '||to_char(x_category_id)||' and book '||p_book||' :');
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'For Category ID '||to_char(x_category_id)||' and book '||p_book||' :');
             fnd_file.put_line( 1, 'CCID of revaluation account :'||x_revaluation_account);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID of revaluation account :'||x_revaluation_account);
             fnd_file.put_line( 1, 'CCID of surplus account account :'||x_surplus_account);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID of surplus account account :'||x_surplus_account);
             fnd_file.put_line( 1, 'CCID of reserve account :'||x_reserve_account);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID of reserve account :'||x_reserve_account);
             fnd_file.put_line( 1, 'CCID of expense account :'||x_expense_account);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID of expense account :'||x_expense_account);
             fnd_file.put_line( 1, 'CCID of recovery account :'||x_recovery_account);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID of recovery account :'||x_recovery_account);
             fnd_file.put_line( 1, 'Default cost account ccid :'||to_char(x_asset_cost_account_ccid));
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Default cost account ccid :'||to_char(x_asset_cost_account_ccid));
             fnd_file.put_line( 1, 'Account segment Value of cost acct :'||x_asset_cost_acct_segval);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Account segment Value of cost acct :'||x_asset_cost_acct_segval);
           END IF;

             ---------------------------------------------------------
             -- Finish the procedure with error if CCID is less than--
             -- equal zero                                          --
             ---------------------------------------------------------

              IF ( x_revaluation_account <= 0  OR
                   x_surplus_account     <= 0  OR
                   x_reserve_account     <= 0  OR
                   x_expense_account     <= 0  OR
                   x_recovery_account    <= 0 )    THEN

                RAISE INVALID_CCID;
              END IF;
            END IF;
             ---------------------------------------------------------
             -- Calculate accounts for each distribution of asset   --
             ---------------------------------------------------------

           IF (x_book_class = 'TAX') THEN
             x_book := x_distribution_source_book;
           ELSE
             x_book := p_book;
           END IF;

           << distribution>>

           FOR rec_dist IN c_distribution(rec_asset.asset_id, x_book) LOOP


             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_file.put_line( 1, 'Distribution ID :'||to_char(rec_dist.distribution_id));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Distribution ID :'||to_char(rec_dist.distribution_id));
               fnd_file.put_line( 1, 'Assigned Unit :'||to_char(rec_dist.units_assigned));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Assigned Unit :'||to_char(rec_dist.units_assigned));
               fnd_file.put_line( 1, 'CCID :'||to_char(rec_dist.code_combination_id));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'CCID :'||to_char(rec_dist.code_combination_id));
             END IF;

             ---------------------------------------------------------
             -- Get value of actual cost_account_ccid               --
             ---------------------------------------------------------
             x_statement := 'COST_ACCT_INFO';
             FA_GCCID_PKG.fafbgcc_proc (X_book_type_code => p_book,
                           X_fn_trx_code  => 'ASSET_COST_ACCT',
                           X_dist_ccid => rec_dist.code_combination_id,
                           X_acct_segval => x_asset_cost_acct_segval,
                           X_account_ccid => x_asset_cost_account_ccid,
                           X_distribution_id => rec_dist.distribution_id,
                           X_rtn_ccid => x_actual_cost_acct_ccid,
                           X_concat_segs => x_cost_account_code,
                           X_return_value => x_rtn_value);

             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_file.put_line( 1, 'actual cost acct ccid :'||to_char(x_actual_cost_acct_ccid));
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'actual cost acct ccid :'||to_char(x_actual_cost_acct_ccid));
             END IF;


             ---------------------------------------------------------
             -- Account for different cases in Technical Appraisals --
             ---------------------------------------------------------
             x_statement := 'INSERT_ADJ';
             IF    (x_appr_revaluation >= 0 AND
                   x_prev_revaluation >= 0 AND
                   x_net_revaluation  >= 0) THEN





                jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_revaluation_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                 fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
               END IF;

              insert_row( p_adjustment_type     => 'APPR_REVAL',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));



              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_surplus_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;


              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_SURPL',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation * (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


            ELSIF (x_appr_revaluation >= 0 AND
                   x_prev_revaluation >= 0 AND
                   x_net_revaluation  <  0) THEN


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_surplus_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_SURPL',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_revaluation_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_REVAL',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


            ELSIF (x_appr_revaluation >= 0 AND
                   x_prev_revaluation <  0 ) THEN


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_reserve_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;


              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_prev_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));

              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_recovery_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV_REC',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_prev_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));

              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_revaluation_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_REVAL',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_appr_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_surplus_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;



             insert_row( p_adjustment_type     => 'APPR_SURPL',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_appr_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));



            ELSIF (x_appr_revaluation <  0 AND
                   x_prev_revaluation >= 0) THEN


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_surplus_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;


              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_SURPL',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_prev_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));

              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_revaluation_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_REVAL',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_prev_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_expense_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV_EXP',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_appr_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));

              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_reserve_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_appr_revaluation * (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


            ELSIF (x_appr_revaluation < 0 AND
                   x_prev_revaluation < 0 AND
                   x_net_revaluation  >= 0) THEN


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_reserve_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_recovery_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV_REC',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


            ELSIF (x_appr_revaluation <  0 AND
                   x_prev_revaluation <  0 AND
                   x_net_revaluation  <  0) THEN


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_expense_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV_EXP',
                          p_debit_credit_flag   => 'DR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));


              jl_co_fa_accounting_pkg.change_account(
                             p_chart_of_accounts_id => x_accounting_flex_structure,
                             p_apps_short_name      => x_apps_short_name,
                             p_key_flex_code        => x_key_flex_code,
                             p_num_segment          => x_account_segment_no,
                             p_account_ccid         => x_actual_cost_acct_ccid,
                             p_account_segment      => x_reserve_account,
                             p_delimiter            => x_delimiter,
                             p_returned_ccid        => x_ccid,
                             p_error_ccid           => x_error_ccid);

               IF NOT (x_error_ccid)  THEN
                 RAISE CCID_NOT_FOUND;
               END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'New CCID:'||to_char(x_ccid));
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'New CCID:'||to_char(x_ccid));
              END IF;


              insert_row( p_adjustment_type     => 'APPR_RESRV',
                          p_debit_credit_flag   => 'CR',
                          p_code_combination_id => x_ccid,
                          p_book_type_code      => p_book,
                          p_asset_id            => rec_asset.asset_id,
                          p_adjustment_amount   => ROUND((x_net_revaluation *
                          (rec_dist.units_assigned/rec_asset.current_units)), x_precision),
                          p_period_counter      => x_period_counter,
                          p_distribution_id     => rec_dist.distribution_id,
                          p_je_category_name       => x_je_category_name,
                          p_reference           => to_char(rec_appraisal.appraisal_id));

            END IF;

          END LOOP distribution;

         /*    ---------------------------------------------------------
             -- Update jl_co_fa_appr_assts. For each asset set      --
             -- status = 'P' ie. processed                          --
             ---------------------------------------------------------
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Updating JL_CO_FA_ASSET_APPRS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating JL_CO_FA_ASSET_APPRS');
              END IF;

           UPDATE jl_co_fa_asset_apprs SET status = 'P',
                                           last_update_date = x_sysdate,
                                           last_updated_by  = x_last_updated_by,
                                           last_update_login = x_last_update_login
           WHERE CURRENT OF c_asset;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Updated JL_CO_FA_ASSET_APPRS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated JL_CO_FA_ASSET_APPRS');
           END IF;*/
             ---------------------------------------------------------
             -- Update fa_book for each asset                       --
             ---------------------------------------------------------

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Updating FA_BOOKS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating FA_BOOKS');
           END IF;

           UPDATE fa_books SET
           global_attribute2 = fnd_number.number_to_canonical(x_appr_revaluation),
           global_attribute3 = fnd_number.number_to_canonical(x_prev_revaluation),
           global_attribute4 = rec_appraisal.appraisal_id,
           global_attribute5 = fnd_date.date_to_canonical(rec_appraisal.appraisal_date),
           global_attribute6 = fnd_number.number_to_canonical(rec_asset.appraisal_value),
           last_update_date = x_sysdate,
           last_updated_by  = x_last_updated_by,
           last_update_login = x_last_update_login
           WHERE book_type_code = p_book
             AND asset_id = rec_asset.asset_id
             AND transaction_header_id_out IS NULL
             AND date_ineffective IS NULL ;

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Updated FA_BOOKS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated FA_BOOKS');
              END IF;

             ---------------------------------------------------------
             -- Initialize parameters to zero                       --
             ---------------------------------------------------------

           x_revaluation_account := 0;
           x_surplus_account := 0;
           x_reserve_account  := 0;
           x_expense_account := 0;
           x_recovery_account := 0;
           x_appr_revaluation  := 0;
           x_prev_revaluation  := 0 ;
           x_net_revaluation   := 0;
           x_category_id  := 0;

         END IF;
       END LOOP assets;
             ---------------------------------------------------------
             -- Update jl_co_fa_appraisals table                    --
             ---------------------------------------------------------

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Updating JL_CO_FA_APPRAISALS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updating JL_CO_FA_APPRAISALS');
       END IF;

       UPDATE jl_co_fa_appraisals SET appraisal_status = 'P',
                                      last_update_date = x_sysdate,
                                      last_updated_by  = x_last_updated_by,
                                      last_update_login = x_last_update_login

       WHERE CURRENT OF c_appraisal;

       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_file.put_line( 1, 'Updated JL_CO_FA_APPRAISALS');
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Updated JL_CO_FA_APPRAISALS');
       END IF;

             ---------------------------------------------------------
             -- Insert a row into table JL_CO_FA_APPRAISAL_BOOKS    --
             ---------------------------------------------------------

       INSERT INTO jl_co_fa_appraisal_books (appraisal_id,
                                             book_type_code,
                                             last_update_date,
                                             last_updated_by,
                                             creation_date,
                                             created_by,
                                             last_update_login,
                                             request_id,
                                             program_application_id,
                                             program_id,
                                             program_update_date)
                                     VALUES (rec_appraisal.appraisal_id,
                                             p_book,
                                             x_sysdate,
                                             x_last_updated_by,
                                             x_sysdate,
                                             x_last_updated_by,
                                             x_last_update_login,
                                             x_request_id,
                                             x_program_application_id,
                                             x_program_id,
                                             x_sysdate);

             ---------------------------------------------------------
             -- Report all assets not revalued for the appraisal_id --
             ---------------------------------------------------------
         track_asset(p_book,
                     rec_appraisal.appraisal_id);

       END IF;
     END LOOP appraisals;
     COMMIT;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
     END IF;

EXCEPTION

   WHEN NOT_A_TAX_BOOK THEN
     fnd_message.set_name('JL', 'JL_CO_FA_INVALID_TAX_BOOK');
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/
   WHEN JE_CAT_NOT_DEFINED THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_JE_CAT_NOT_DEFINED');
        fnd_message.set_token('BOOK', p_book);
        err_msg := fnd_message.get;
        ROLLBACK;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/
   WHEN GL_POSTING_NOT_ALLOWED THEN
     fnd_message.set_name('JL', 'JL_CO_FA_POSTING_NOT_ALLOWED');
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/
  /* WHEN DIFF_FISCAL_YEAR THEN
     fnd_message.set_name('JL', 'JL_CO_FA_INVALID_FISCAL_YEAR');
     err_msg := fnd_message.get;
     app_exception.raise_exception (exception_type => 'APP',
       exception_code =>
       jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_INVALID_FISCAL_YEAR'),
       exception_text => err_msg);
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
   WHEN INVALID_CCID THEN
     SELECT LTRIM(RTRIM(segment1))||LTRIM(RTRIM(segment2))||
            LTRIM(RTRIM(segment3))||LTRIM(RTRIM(segment4))||
            LTRIM(RTRIM(segment5))||LTRIM(RTRIM(segment6))||
            LTRIM(RTRIM(segment7))
     INTO   x_category
     FROM   fa_categories
     WHERE  category_id = x_category_id;
     ROLLBACK;
     fnd_message.set_name('JL', 'JL_CO_FA_CCID_NOT_DEFINED');
     fnd_message.set_token('CATEGORY', x_category);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

   WHEN CCID_NOT_FOUND THEN
          SELECT LTRIM(RTRIM(segment1))||LTRIM(RTRIM(segment2))||
            LTRIM(RTRIM(segment3))||LTRIM(RTRIM(segment4))||
            LTRIM(RTRIM(segment5))||LTRIM(RTRIM(segment6))||
            LTRIM(RTRIM(segment7))
     INTO   x_category
     FROM   fa_categories
     WHERE  category_id = x_category_id;
     ROLLBACK;
     fnd_message.set_name('JL', 'JL_CO_FA_CCID_NOT_DEFINED');
     fnd_message.set_token('CATEGORY', x_category);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

  /* WHEN REVALUATION_RUN THEN
     fnd_message.set_name('JL', 'JL_CO_FA_REVALUATION_RUN');
     fnd_message.set_token('APPRAISAL_NUMBER', to_char(p_appraisal_id));
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     app_exception.raise_exception (exception_type => 'APP',
       exception_code =>
       jl_zz_fa_utilities_pkg.get_app_errnum('JL', 'JL_CO_FA_REVALUATION_RUN'),
       exception_text => err_msg);
       */
   WHEN INVALID_CURRENCY_CODE THEN
     fnd_message.set_name('JL', 'JL_CO_FA_DIFFERENT_CURRENCY');
     fnd_message.set_token('APPRAISAL_NUMBER', to_char(p_appraisal_id));
     fnd_message.set_token('BOOK', p_book);
     err_msg := fnd_message.get;
     fnd_file.put_line(fnd_file.log, err_msg);
     call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
     fnd_message.raise_error;
*/

   WHEN OTHERS THEN
      IF x_statement = 'BOOK_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '1');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'FLEX_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '2');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'CURR_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '3');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'ACCT_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '4');
        err_msg := fnd_message.get;
        ROLLBACK;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'COST_ACCT_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '5');
        err_msg := fnd_message.get;
        ROLLBACK;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'INSERT_ADJ' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '6');
        err_msg := fnd_message.get;
        ROLLBACK;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSIF x_statement = 'PERIOD_INFO' THEN
        fnd_message.set_name('JL', 'JL_ZZ_FA_EXEC_FAILURE');
        fnd_message.set_token('NUMBER', '7');
        err_msg := fnd_message.get;
        ROLLBACK;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        fnd_message.raise_error;
*/

      ELSE
        fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line( fnd_file.log, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        ROLLBACK;
        RAISE_APPLICATION_ERROR( err_num, err_msg);
      END IF;
END revaluate;

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   insert_row                                                           --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to insert row into JL_CO_FA_ADJUSTMENTS.          --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--        p_adjustment_type                                               --
--        p_debit_credit_flag                                             --
--        p_code_combination_id                                           --
--        p_book_type_code                                                --
--        p_asset_id                                                      --
--        p_adjustment_amount                                             --
--        p_period_counter                                                --
--        p_distribution_id                                               --
-- HISTORY:                                                               --
--    08/12/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE insert_row(
                      p_adjustment_type     VARCHAR2,
                      p_debit_credit_flag   VARCHAR2,
                      p_code_combination_id NUMBER,
                      p_book_type_code      VARCHAR2,
                      p_asset_id            NUMBER,
                      p_adjustment_amount   NUMBER,
                      p_period_counter      NUMBER,
                      p_distribution_id     fa_distribution_history.distribution_id%TYPE,
                      P_je_category_name    VARCHAR2,
                      p_reference           VARCHAR2)    IS

x_period_counter     NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_ROW';


BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;


   x_statement := 'PERIOD_INFO';
   SELECT period_counter
     INTO x_period_counter
     FROM fa_deprn_periods
    WHERE book_type_code = p_book_type_code
      AND period_close_date IS NULL;


            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_file.put_line( 1, 'Inserting Row into JL_CO_FA_ADJUSTMENTS');
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserting Row into JL_CO_FA_ADJUSTMENTS');
            END IF;


            IF (p_adjustment_amount <> 0) THEN
              INSERT INTO jl_co_fa_adjustments(
                          source_type_code,
                          je_category_name,
                          adjustment_type,
                          debit_credit_flag,
                          code_combination_id,
                          book_type_code,
                          asset_id,
                          adjustment_amount,
                          distribution_id,
                          period_counter_adjusted,
                          period_counter_created,
                          reference,
                          last_update_date,
                          last_updated_by,
                          creation_date,
                          created_by,
                          last_update_login,
                          request_id,
                          program_application_id,
                          program_id,
                          program_update_date)
                  VALUES(
                         'TECH_APPR_REVAL',
                          p_je_category_name,
                          p_adjustment_type,
                          p_debit_credit_flag,
                          p_code_combination_id,
                          p_book_type_code,
                          p_asset_id,
                          ABS(p_adjustment_amount),
                          p_distribution_id,
                          x_period_counter,
                          x_period_counter,
                          p_reference,
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

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                fnd_file.put_line( 1, 'Inseted Row into JL_CO_FA_ADJUSTMENTS');
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Inserted Row into JL_CO_FA_ADJUSTMENTS');
              END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

END insert_row;

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


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   track_asset                                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to get assets not revaluated.                     --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--        p_appraisal_id                                                  --
--        p_book_type_code                                                --
-- HISTORY:                                                               --
--    11/10/98     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------

PROCEDURE track_asset( p_book_type_code     VARCHAR2,
                      p_appraisal_id       number)  IS

   x_count   number := 0;
   x_status  boolean;
   CURSOR  c_asset IS
   SELECT asset_number
     FROM jl_co_fa_asset_apprs
    WHERE appraisal_id = p_appraisal_id
      AND asset_number NOT IN (SELECT ap.asset_number
     FROM jl_co_fa_asset_apprs ap,
          fa_additions ad,
          fa_books ab
    WHERE ap.asset_number = ad.asset_number
      AND ap.appraisal_id = p_appraisal_id
      AND ad.asset_id = ab.asset_id
      AND ab.book_type_code = p_book_type_code
      AND ab.transaction_header_id_out IS NULL
      AND ab.date_ineffective IS NULL );

BEGIN

  FOR rec_asset IN c_asset LOOP
      fnd_message.set_name('JL', 'JL_CO_FA_ASSET_NOT_REVALUED');
--    fnd_message.set_token('BOOK', P_book_type_code);
      fnd_message.set_token('ASSET_NUMBER', rec_asset.asset_number);
      fnd_file.put_line(FND_FILE.LOG, fnd_message.get);

      x_count := x_count + 1;
  END LOOP;

  IF x_count <> 0 THEN
    x_status := fnd_concurrent.set_completion_status( status => 'WARNING',
                                          message => '');
  END IF;
END track_asset;

END jl_co_fa_ta_reval_pkg;

/
