--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_DEPRN_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_DEPRN_ADJ_PKG" AS
/* $Header: jlzzfdab.pls 120.8 2006/09/20 17:05:04 abuissa ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_ZZ_FA_DEPRN_ADJ_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_ZZ_FA_DEPRN_ADJ_PKG.';

/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    deprn_adj_ret_assets                                                 |
  |         p_book_type_code         Book Type Code                         |
  |                                                                         |
  |  NOTES                                                                  |
  |    Once the asset is retired, journal entries are posted to reverse the |
  |  accumulated depreciation. The inflation adjusted depreciation account  |
  |  remains unchanged until the end of the fiscal year, when it is used to |
  |  calculate the FY's result and then its balance is zeroed.  But that    |
  |  balance is not in constant units of money to the time of the FY's end, |
  |  so we must adjust it for inflation during that FY's periods.           |
  |                                                                         |
  +=========================================================================+*/
  PROCEDURE deprn_adj_ret_assets (errbuf OUT NOCOPY VARCHAR2
                                , retcode OUT NOCOPY VARCHAR2
                                , p_book_type_code IN VARCHAR2) IS

    ------------------------------------------------------------
    -- Procedure Global Variables                             --
    ------------------------------------------------------------
    g_current_period_to_date1  DATE;
    g_current_period_from_date1 DATE;
    g_current_period_to_date2  DATE;
    g_current_period_from_date2 DATE;
    g_previous_period_to_date  DATE;
    g_current_fiscal_year      NUMBER(4);
    g_current_month_number     NUMBER(3);
    g_previous_period_counter  NUMBER(15);
    g_set_of_books_id          NUMBER(15);
    g_chart_of_accounts_id     NUMBER(15);
    g_currency_code            VARCHAR2(15);
    g_curr_precision           NUMBER;
    g_step                     VARCHAR2(30);
    g_user_je_category_name    GL_INTERFACE.USER_JE_CATEGORY_NAME%TYPE;
    g_user_je_source_name      GL_INTERFACE.USER_JE_SOURCE_NAME%TYPE;
    g_calendar_type            FA_CALENDAR_TYPES.CALENDAR_TYPE%TYPE;
    g_je_retirement_category   FA_BOOK_CONTROLS.JE_RETIREMENT_CATEGORY%TYPE;
    g_last_period_counter      FA_BOOK_CONTROLS.LAST_PERIOD_COUNTER%TYPE;
    g_distribution_source_book FA_BOOK_CONTROLS.DISTRIBUTION_SOURCE_BOOK%TYPE;
    g_reserve_acct             NUMBER(15);
    g_ccid_deprn_exp_co        VARCHAR2(150);
    g_ccid_deprn_mon_co        VARCHAR2(150);
    g_gl_je_source             XLA_SUBLEDGERS.JE_SOURCE_NAME%TYPE;    -- Bug 5136047
    g_conc_segs                VARCHAR2(2000);
    g_period_name              FA_DEPRN_PERIODS.PERIOD_NAME%TYPE;
    g_precision                NUMBER;
    g_period_counter1          FA_DEPRN_PERIODS.PERIOD_COUNTER%TYPE;
    g_period_counter2          FA_DEPRN_PERIODS.PERIOD_COUNTER%TYPE;
    g_number_per_fy            NUMBER := 0;
    x_country_code             VARCHAR2(2);
    x_last_updated_by          NUMBER(15);
    x_created_by               NUMBER(15);
    x_last_update_login        NUMBER(15);
    x_request_id               NUMBER(15);
    x_program_application_id   NUMBER(15);
    x_program_id               NUMBER(15);
    g_period_num               NUMBER := 0;
    x_sysdate                  DATE;
    call_status                BOOLEAN;
    err_num                    NUMBER;
    err_msg                    VARCHAR2(200);
    x_char                     VARCHAR2 (200);


    ------------------------------------------------------------
    -- Procedure: get_who_columns                             --
    --                                                        --
    -- Get values for who columns                             --
    ------------------------------------------------------------
   PROCEDURE get_who_columns IS

     l_api_name           CONSTANT VARCHAR2(30) := 'GET_WHO_COLUMNS';

   BEGIN

     x_last_updated_by        := fnd_global.user_id;
     x_created_by             := fnd_global.user_id;
     x_last_update_login      := fnd_global.login_id;
     x_request_id             := fnd_global.conc_request_id;
     x_program_application_id := fnd_global.prog_appl_id;
     x_program_id             := fnd_global.conc_program_id;
     x_sysdate                := SYSDATE;

     -------------------------------------------------------------------------
     -- BUG 4650081. Profile for country is replaced by call to JG Shared pkg.
     -------------------------------------------------------------------------
     x_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY;
     FND_PROFILE.GET('JLZZ_INF_RATIO_PRECISION',g_precision);


      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Start Debugging';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Country :'||x_country_code;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Precision :'||g_precision;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

     IF g_precision IS NULL OR g_precision = 0  THEN
       g_precision := 38;
     END IF;

     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
     END IF;

   END get_who_columns;


    ------------------------------------------------------------
    -- Procedure: get_details                                 --
    --                                                        --
    -- Get all the book related information needed to         --
    -- calculate the revaluation rates.                       --
    ------------------------------------------------------------

  PROCEDURE get_details IS

    l_api_name           CONSTANT VARCHAR2(30) := 'GET_DETAILS';

  BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;


    g_step := 'BOOK INFO';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure get_details';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

    ------------------------------------------------------------
    -- Details for book given                                 --
    ------------------------------------------------------------

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

    SELECT a.set_of_books_id ,
           a.global_attribute6,
           a.gl_je_source,
           b.currency_code,
           b.chart_of_accounts_id,
           a.deprn_calendar,
           a.last_period_counter,
           a.distribution_source_book
      INTO g_set_of_books_id,
           g_je_retirement_category,
           g_gl_je_source,
           g_currency_code,
           g_chart_of_accounts_id,
           g_calendar_type,
           g_last_period_counter,
           g_distribution_source_book
      FROM fa_book_controls a,
           gl_sets_of_books b
      WHERE a.book_type_code  = p_book_type_code
        AND a.set_of_books_id = b.set_of_books_id;
*/

    SELECT a.set_of_books_id ,
           a.global_attribute6,
           b.currency_code,
           b.chart_of_accounts_id,
           a.deprn_calendar,
           a.last_period_counter,
           a.distribution_source_book
      INTO g_set_of_books_id,
           g_je_retirement_category,
           g_currency_code,
           g_chart_of_accounts_id,
           g_calendar_type,
           g_last_period_counter,
           g_distribution_source_book
      FROM fa_book_controls a,
           gl_sets_of_books b
      WHERE a.book_type_code  = p_book_type_code
        AND a.set_of_books_id = b.set_of_books_id;

     SELECT xs.je_source_name,
            js.user_je_source_name
       INTO g_gl_je_source,
            g_user_je_source_name
       FROM gl_je_sources js,
            xla_subledgers xs
      WHERE js.je_source_name = xs.je_source_name
        AND xs.application_id = 140;

    -- Get currency precision

       SELECT precision
       INTO g_curr_precision
       FROM fnd_currencies_vl
         WHERE UPPER(currency_code) = UPPER(g_currency_code);


    ------------------------------------------------------------
    -- Next two selects bring category y source name to be    --
    -- inserted in gl_interface  table.                       --
    ------------------------------------------------------------


    SELECT user_je_category_name
      INTO g_user_je_category_name
      FROM gl_je_categories
      WHERE je_category_name = g_je_retirement_category;

      ------------------------------------------------------------
      -- Fetches the depreciation parameters for the current    --
      -- period.                                                --
      ------------------------------------------------------------
    g_step := 'CURR DPRN INFO';


    SELECT a.calendar_period_open_date,
           a.calendar_period_close_date,
           a.fiscal_year,
           a.period_num,
           a.period_counter,
           a.period_name
      INTO
           g_current_period_from_date1,
           g_current_period_to_date1,
           g_current_fiscal_year,
           g_current_month_number,
           g_period_counter1,
           g_period_name
      FROM fa_deprn_periods a
      WHERE a.book_type_code = p_book_type_code
        AND a.period_counter = g_last_period_counter;



       SELECT number_per_fiscal_year
         INTO g_number_per_fy
         FROM fa_calendar_types
         WHERE calendar_type = g_calendar_type;


      ------------------------------------------------------------
      -- If country is not Chili then variables g_period_counter2--
      -- and g_period_counter1 should contain the same value.    --
      ------------------------------------------------------------


      g_period_counter2           := g_period_counter1;
      g_current_period_to_date2   := g_current_period_to_date1;
      g_current_period_from_date2 := g_current_period_from_date1;

      ------------------------------------------------------------
      -- If country_code = 'CL' (Chili) then the current period --
      -- becomes the previous one and so on for previous period --
      -- information.                                           --
      ------------------------------------------------------------

     IF x_country_code = 'CL' THEN


            g_period_counter2 := g_period_counter1 - 1;

            SELECT  period_num
              INTO g_period_num
              FROM fa_calendar_periods
              WHERE calendar_type = g_calendar_type
                AND start_date    = g_current_period_from_date1;

            SELECT start_date,end_date
              INTO g_current_period_from_date2,
                   g_current_period_to_date2
              FROM fa_calendar_periods
              WHERE calendar_type = g_calendar_type
                AND period_num    = decode(g_period_num,1,g_number_per_fy,g_period_num-1)
                AND end_date      = g_current_period_from_date1 - 1;


     END IF;


            g_previous_period_counter := g_period_counter1 - 1;
            g_previous_period_to_date := g_current_period_from_date2 - 1;

    ------------------------------------------------------------
    -- Following commands will write the ouput report heading.--
    ------------------------------------------------------------

    fnd_file.put(FND_FILE.OUTPUT,LPAD('-',132,'-'));
    fnd_file.new_line(FND_FILE.OUTPUT,1);
    fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_HEAD');
    fnd_file.put_line( FND_FILE.OUTPUT,LPAD(' ',27,' ')||RPAD(fnd_message.get,87,' ')||to_char(SYSDATE,'DD-MM-YYYY HH:MI'));
    fnd_message.set_name('JL', 'JL_CO_FA_BOOK');
    fnd_message.set_token('BOOK', p_book_type_code);
    fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get);
    fnd_message.set_name('JL', 'JL_ZZ_FA_PERIOD_NAME');
    fnd_message.set_token('PERIOD_NAME', g_period_name);
    fnd_file.put_line( FND_FILE.OUTPUT, fnd_message.get);
    fnd_file.put(FND_FILE.OUTPUT,LPAD('-',132,'-'));
    fnd_file.new_line(FND_FILE.OUTPUT,1);


    ------------------------------------------------------------
    --                End of report heading                   --
    ------------------------------------------------------------

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

        x_char := 'Period counter :'||TO_CHAR(g_period_counter1);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Period Name :'||g_period_name;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);

       IF x_country_code = 'CL' THEN
        x_char := 'Period counter to get indexes :'||TO_CHAR(g_period_counter2);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
       END IF;

        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of procedure get_details';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END get_details;

    ------------------------------------------------------------
    -- Procedure: format_amount_out                           --
    -- Formats the amount given acording to the precision to  --
    -- be shown in the output report.                         --
    ------------------------------------------------------------

  PROCEDURE format_amount_out ( num_amount  IN NUMBER,
                                char_amount OUT NOCOPY VARCHAR2) IS

   tmp_amnt  varchar(20);
   result varchar2(100);
  BEGIN
    if g_curr_precision <= 0 then
      SELECT TO_CHAR(round(num_amount,g_curr_precision))
      INTO char_amount
      FROM DUAL;
    else
      SELECT TO_CHAR(ROUND(num_amount,g_curr_precision))
      INTO tmp_amnt
      FROM DUAL;

      select rpad(tmp_amnt,
          decode(sign(length(tmp_amnt)+g_curr_precision-(length(tmp_amnt) -  instr(tmp_amnt,'.')))
                     ,-1,length(tmp_amnt)
                     ,0 ,length(tmp_amnt)
                     ,length(tmp_amnt) + g_curr_precision - (length(tmp_amnt) -
                      decode(instr(tmp_amnt,'.'),0,1,instr(tmp_amnt,'.')))),'0')
      into char_amount
      from dual;
    end if;


  END format_amount_out;

    ------------------------------------------------------------
    -- Procedure: get_segs                                    --
    -- Gets the concatenated segment values for the key flex  --
    -- field combination.                                     --
    ------------------------------------------------------------
  PROCEDURE get_segs ( p_dist_ccid in NUMBER) IS
  BEGIN

     g_conc_segs :=  FND_FLEX_EXT.GET_SEGS ('SQLGL',
                                  'GL#',
                                  g_chart_of_accounts_id,
                                  p_dist_ccid);
     SELECT rpad(g_conc_segs,45,' ')
       INTO g_conc_segs
       FROM DUAL;

  END get_segs;


    ------------------------------------------------------------
    -- Procedure: get_price_index_rate                        --
    --                                                        --
    -- Gets the index value for a certain price index and a   --
    -- particular date.                                       --
    ------------------------------------------------------------
  PROCEDURE get_price_index_rate (p_index_id    IN NUMBER
                                  , p_period_date IN DATE
                                  , p_index_value IN OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT price_index_value
      INTO p_index_value
      FROM fa_price_index_values
      WHERE price_index_id = p_index_id
        AND p_period_date BETWEEN from_date AND to_date;

  END get_price_index_rate;


    ------------------------------------------------------------
    -- Procedure: get_index_rate                              --
    --                                                        --
    -- Gets the price index associated to the category        --
    -- Bug 1420414 : Changed the query in the procedure       --
    -- "get_index_rate" to cater for the situation            --
    -- where different price indexes are defined for          --
    -- different ranges of date placed in service.            --
    -- Bug 1488156 : Changed the query in the procedure       --
    -- "get_index_rate" to deal with Items with               --
    --  date_place_of_service is ahead of system time         --
    ------------------------------------------------------------
  PROCEDURE get_index_rate(p_current_category IN VARCHAR2,
                           p_date_placed_in_service IN DATE,
                           p_adjustment_rate IN OUT NOCOPY NUMBER) IS

    l_price_index fa_price_indexes.price_index_id%TYPE;
    l_current_index_value  NUMBER := 0;
    l_previous_index_value NUMBER:= 0;
    l_api_name           CONSTANT VARCHAR2(30) := 'GET_INDEX_RATE';

    --
  BEGIN
      ------------------------------------------------------------
      --  Fetch the index for the book type and category        --
      ------------------------------------------------------------
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure get_index_rate';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Getting index for  Category :'||p_current_category;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


    SELECT b.price_index_id
      INTO l_price_index
      FROM fa_category_book_defaults a, fa_price_indexes b
     WHERE a.book_type_code = p_book_type_code
       AND a.category_id    = p_current_category
       AND p_date_placed_in_service >= a.start_dpis
       AND p_date_placed_in_service <= NVL(a.end_dpis,p_date_placed_in_service)
       AND a.price_index_name = b.price_index_name;



      get_price_index_rate(l_price_index,g_current_period_to_date2,
                           l_current_index_value);
      get_price_index_rate(l_price_index,g_previous_period_to_date,
                           l_previous_index_value);


      p_adjustment_rate := trunc((l_current_index_value / l_previous_index_value),g_precision);


    g_step := '';
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of procedure get_index_rate';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END get_index_rate;

    ------------------------------------------------------------
    -- Procedure: current_period_retirements                  --
    --                                                        --
    ------------------------------------------------------------
  PROCEDURE current_period_retirements IS


    CURSOR fa_ret IS
      SELECT a.retirement_id,a.asset_id asset_id,
             b.transaction_header_id transaction_header_id,
             rpad(c.asset_number||'-'||substr(c.description,1,30),45,' ') asset_desc
        FROM fa_books d,
             fa_additions c,
             fa_transaction_headers b,
             fa_retirements a
        WHERE a.book_type_code = p_book_type_code
          AND a.transaction_header_id_in = b.transaction_header_id
          AND b.transaction_date_entered BETWEEN g_current_period_from_date1
                                             AND g_current_period_to_date1
          AND b.transaction_type_code = 'FULL RETIREMENT'
          AND c.asset_id = a.asset_id
          AND c.asset_type <> 'CIP'
          AND d.book_type_code = a.book_type_code
          AND d.asset_id       = a.asset_id
          AND d.date_ineffective IS NULL
          AND NVL(d.global_attribute1,'N') = 'Y'
        ORDER BY c.asset_number;

    CURSOR fa_cat(l_asset_id in number) IS
      SELECT distribution_id,code_combination_id
        FROM fa_distribution_history
        WHERE book_type_code = g_distribution_source_book
          AND asset_id       = l_asset_id
          AND transaction_header_id_out is null;


    l_accum_deprn     fa_deprn_summary.deprn_reserve%TYPE := 0;
    l_dist_ccid       fa_distribution_history.code_combination_id%TYPE;
    l_deprn_amount    fa_deprn_summary.deprn_amount%TYPE := 0;
    l_amount_out      VARCHAR2(20);
    l_api_name        CONSTANT VARCHAR2(30) := 'CURRENT_PERIOD_RETIREMENTS';


  BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure Current_period_retirements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


    FOR fa_ret_rec IN fa_ret
    LOOP
    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------
      IF fa_ret%ROWCOUNT = 1 THEN
        fnd_file.new_line(FND_FILE.OUTPUT,2);
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_TIT3');
        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(fnd_message.get,50,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1A');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(RTRIM(fnd_message.get),47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1B');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(RTRIM(fnd_message.get),47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1C');
        fnd_file.put( FND_FILE.OUTPUT, LPAD(fnd_message.get,32,' '));
        fnd_file.put_line( FND_FILE.OUTPUT,'');
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',32,'-'));
        fnd_file.put_line(FND_FILE.OUTPUT,'');
      END IF;
    ------------------------------------------------------------
    -- End Report output                                      --
    ------------------------------------------------------------


    g_step := 'DIST HIST';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Processing asset retired :'||TO_CHAR(fa_ret_rec.asset_id);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


      FOR fa_cat_rec IN fa_cat(fa_ret_rec.asset_id)
      LOOP


        g_step := 'CURR DPRN INFO';

    ------------------------------------------------------------
    -- Next select gets the amount for the period and the     --
    -- accumulated depreciation.                              --
    ------------------------------------------------------------


        SELECT sum(ytd_deprn),sum(deprn_amount)
        INTO  l_accum_deprn,l_deprn_amount
        FROM fa_deprn_detail
        WHERE book_type_code   = p_book_type_code
          AND asset_id         = fa_ret_rec.asset_id
          AND period_counter   = g_period_counter1
          AND distribution_id  = fa_cat_rec.distribution_id;

        g_step := '';

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'YTD Depreciation and Current Period Depreciation are:'||TO_CHAR(l_accum_deprn)||','||TO_CHAR(l_deprn_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;


        INSERT INTO jl_zz_fa_retiremnt_adjs
                (retirement_id,
                 period_counter,
                 distribution_id,
                 book_type_code,
                 asset_id,
                 transaction_header_id,
                 je_line_id,
                 original_ytd_depreciation,
                 total_adjustment_amount,
                 period_adjustment_amount,
                 status,
                 retire_reinst_flag,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login)

        VALUES
                (fa_ret_rec.retirement_id,
                 g_period_counter1,
                 fa_cat_rec.distribution_id,
                 p_book_type_code,
                 fa_ret_rec.asset_id,
                 fa_ret_rec.transaction_header_id,
                 null,
                 round(l_accum_deprn,g_curr_precision),
                 round(l_accum_deprn,g_curr_precision),
                 0,
                 'Y',
                 'RET',
                 x_sysdate,
                 x_last_updated_by,
                 x_sysdate,
                 x_created_by,
                 x_last_update_login);


    ------------------------------------------------------------
    -- Get account concatenated segments                      --
    ------------------------------------------------------------
          get_segs(fa_cat_rec.code_combination_id);

    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------

       format_amount_out(l_deprn_amount,l_amount_out);

        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(LTRIM(fa_ret_rec.asset_desc),47,' ')||
                                          RPAD(LTRIM(g_conc_segs),47,' ')||
                                          LPAD(l_amount_out,32,' ') );
      END LOOP;
    END LOOP;
    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of Procedure current_period_retirements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END current_period_retirements;


    ------------------------------------------------------------
    -- Procedure: current_period_reinstatements               --
    --                                                        --
    -- Gets the reistatements for current period              --
    -- and inserts a new record with the summary of           --
    -- inflation adjustments applied in previous periods      --
    ------------------------------------------------------------
  PROCEDURE current_period_reinstatements IS


    CURSOR fa_ret IS
      SELECT a.retirement_id retirement_id,a.asset_id asset_id,
             b.transaction_header_id transaction_header_id,
             rpad(c.asset_number||'-'||substr(c.description,1,30),45,' ') asset_desc
        FROM fa_books d,
             fa_additions c,
             fa_transaction_headers b,
             fa_retirements a
        WHERE a.book_type_code = p_book_type_code
          AND a.transaction_header_id_out = b.transaction_header_id
          AND b.transaction_type_code = 'REINSTATEMENT'
          AND b.transaction_date_entered BETWEEN g_current_period_from_date1
                                           AND g_current_period_to_date1
          AND c.asset_id  = a.asset_id
          AND d.book_type_code = a.book_type_code
          AND d.asset_id       = a.asset_id
          AND d.date_ineffective IS NULL
          AND NVL(d.global_attribute1,'N') = 'Y'
        ORDER BY c.asset_number;

    CURSOR fa_cat(l_asset_id in number) IS
      SELECT b.distribution_id,b.code_combination_id
        FROM fa_distribution_history b, fa_distribution_history a
        WHERE a.book_type_code = g_distribution_source_book
          AND a.asset_id       = l_asset_id
          AND a.transaction_header_id_out is null
          AND b.book_type_code = a.book_type_code
          AND b.asset_id       = a.asset_id
          AND b.transaction_header_id_out = a.transaction_header_id_in;

    l_accum_deprn     fa_deprn_summary.deprn_reserve%TYPE;
    l_dist_ccid       fa_distribution_history.code_combination_id%TYPE;
    l_deprn_amount    fa_deprn_summary.deprn_amount%TYPE;
    l_ytd_deprn       fa_deprn_summary.deprn_amount%TYPE;
    l_total_amount    fa_deprn_summary.deprn_amount%TYPE;
    l_amount_out      VARCHAR2(20);
    l_api_name        CONSTANT VARCHAR2(30) := 'CURRENT_PERIOD_REINSTATEMENTS';

    --
  BEGIN

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
    END IF;

    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure Current_period_reinstatements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

    FOR fa_ret_rec IN fa_ret
    LOOP

    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------
      IF fa_ret%ROWCOUNT = 1 THEN
        fnd_file.new_line(FND_FILE.OUTPUT,2);
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_TIT2');
        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(fnd_message.get,50,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1A');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(fnd_message.get,47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1B');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(fnd_message.get,47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1C');
        fnd_file.put( FND_FILE.OUTPUT, LPAD(fnd_message.get,32,' '));
        fnd_file.put_line( FND_FILE.OUTPUT,'');
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',32,'-'));
        fnd_file.put_line(FND_FILE.OUTPUT,'');
      END IF;
    ------------------------------------------------------------
    -- End Report output                                      --
    ------------------------------------------------------------

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Processing asset reinstated :'||TO_CHAR(fa_ret_rec.asset_id);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


      FOR fa_cat_rec IN fa_cat(fa_ret_rec.asset_id)
      LOOP


        SELECT nvl(sum(period_adjustment_amount) * -1,0),
               max(original_ytd_depreciation) ,
               max(total_adjustment_amount) - sum(period_adjustment_amount)
          INTO   l_deprn_amount,l_ytd_deprn,l_total_amount
          FROM jl_zz_fa_retiremnt_adjs
          WHERE retirement_id  = fa_ret_rec.retirement_id
          AND   distribution_id = fa_cat_rec.distribution_id;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Amount accumulated for this asset :'||TO_CHAR(l_deprn_amount);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


        INSERT INTO jl_zz_fa_retiremnt_adjs
                (retirement_id,            period_counter,            distribution_id,
                 book_type_code,           asset_id,                  transaction_header_id,
                 je_line_id,               original_ytd_depreciation, total_adjustment_amount,
                 period_adjustment_amount, status,                    retire_reinst_flag,
                 last_update_date,         last_updated_by,           creation_date,
                 created_by,               last_update_login)

        VALUES
                (fa_ret_rec.retirement_id,
                 g_period_counter1,
                 fa_cat_rec.distribution_id,
                 p_book_type_code,
                 fa_ret_rec.asset_id,
                 fa_ret_rec.transaction_header_id,
                 null,
                 round(l_ytd_deprn,g_curr_precision),
                 round(l_total_amount,g_curr_precision),
                 round(l_deprn_amount,g_curr_precision),
                 'N',
                 'REI',
                 x_sysdate,
                 x_last_updated_by,
                 x_sysdate,
                 x_created_by,
                 x_last_update_login);


    ------------------------------------------------------------
    -- Get account concatenated segments                      --
    ------------------------------------------------------------
        get_segs(fa_cat_rec.code_combination_id);

    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------

       format_amount_out(l_deprn_amount,l_amount_out);

        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(LTRIM(fa_ret_rec.asset_desc),47,' ')||
                                          RPAD(LTRIM(g_conc_segs),47,' ')||
                                          LPAD(l_amount_out,32,' ') );

      END LOOP;
    END LOOP;
    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of Procedure current_period_reistatements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END current_period_reinstatements;


    ------------------------------------------------------------
    -- Procedure: adjust_previous_retirements                 --
    --                                                        --
    ------------------------------------------------------------
  PROCEDURE adjust_previous_retirements IS

    l_current_category       NUMBER(15)  :=0;
    l_date_placed_in_service DATE        :=NULL;
    l_period_adj_amount      NUMBER      :=0;
    l_adj_accum_deprn        NUMBER      :=0;
    l_deprn_ccid             NUMBER(15);
    l_adjustment_rate        NUMBER      :=0;
    l_dist_ccid       fa_distribution_history.code_combination_id%TYPE;
    l_amount_out             VARCHAR2(20);
    l_api_name      CONSTANT VARCHAR2(30) := 'ADJUST_PREVIOUS_RETIREMENTS';


    cur_date_placed_in_service DATE;

    CURSOR fa_adjst IS
      SELECT a.retirement_id retirement_id, a.asset_id asset_id,
             a.distribution_id distribution_id,
             a.transaction_header_id transaction_header_id,
             a.original_ytd_depreciation orig_deprn,
             a.total_adjustment_amount  accum_deprn,
             a.period_adjustment_amount adjst_amount,
             b.asset_category_id asset_category,
             rpad(b.asset_number||'-'||substr(b.description,1,30),45,' ') asset_desc
        FROM jl_zz_fa_retiremnt_adjs a,
             fa_additions b
        WHERE a.book_type_code = p_book_type_code
          AND a.period_counter = g_previous_period_counter
          AND a.asset_id = b.asset_id
          AND NOT EXISTS (SELECT 1
                            FROM jl_zz_fa_retiremnt_adjs c
                            WHERE c.retirement_id  = a.retirement_id
                              AND c.period_counter = g_period_counter1
                              AND c.retire_reinst_flag = 'REI')

        GROUP BY b.asset_category_id,
                 rpad(b.asset_number||'-'||substr(b.description,1,30),45,' '),
                 a.retirement_id,
                 a.asset_id , a.distribution_id,
                 a.transaction_header_id,
                 a.original_ytd_depreciation,
                 a.total_adjustment_amount,
                 a.period_adjustment_amount;

  BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

    g_step := 'CURR DPRN INFO';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure Adjust_previous_retirements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


    FOR fa_adjst_rec IN fa_adjst
    LOOP

    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------
      IF fa_adjst%ROWCOUNT = 1 THEN
        fnd_file.new_line(FND_FILE.OUTPUT,2);
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_TIT4');
        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(fnd_message.get,50,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1A');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(fnd_message.get,47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1B');
        fnd_file.put( FND_FILE.OUTPUT, RPAD(fnd_message.get,47,' '));
        fnd_message.set_name('JL', 'JL_ZZ_FA_INF_ADJ_DEP_EXP_T1C');
        fnd_file.put( FND_FILE.OUTPUT, LPAD(fnd_message.get,32,' '));
        fnd_file.put_line( FND_FILE.OUTPUT,'');
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',45,'-'));
        fnd_file.put(FND_FILE.OUTPUT,LPAD(' ',2,' '));
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',32,'-'));
        fnd_file.put_line(FND_FILE.OUTPUT,'');
      END IF;
    ------------------------------------------------------------
    -- End Report output                                      --
    ------------------------------------------------------------
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Before finding the DPIS : asset_id = '||TO_CHAR(fa_adjst_rec.asset_id);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'retirement_id = '||TO_CHAR(fa_adjst_rec.retirement_id);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'book_type_code = '||p_book_type_code;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      SELECT b.date_placed_in_service
      INTO   cur_date_placed_in_service
      FROM   fa_books b
      WHERE  b.book_type_code = p_book_type_code
      AND    b.asset_id       = fa_adjst_rec.asset_id
      AND    b.retirement_id  = fa_adjst_rec.retirement_id;

      IF (l_current_category <> fa_adjst_rec.asset_category) OR
         (cur_date_placed_in_service <> l_date_placed_in_service) THEN

         l_current_category := fa_adjst_rec.asset_category;
         l_date_placed_in_service := cur_date_placed_in_service;

         g_step := 'CURR INDX';

         get_index_rate(fa_adjst_rec.asset_category,
                        cur_date_placed_in_service,
                        l_adjustment_rate);


         g_step := '';


      END IF;


      l_adj_accum_deprn := fa_adjst_rec.accum_deprn * l_adjustment_rate;

      l_period_adj_amount := l_adj_accum_deprn - fa_adjst_rec.accum_deprn;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Processing asset :'||TO_CHAR(fa_adjst_rec.asset_id);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Accumulated depreciation for this asset :'||TO_CHAR(l_adj_accum_deprn);
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


        INSERT INTO jl_zz_fa_retiremnt_adjs
                (retirement_id,
                 period_counter,
                 distribution_id,
                 book_type_code,
                 asset_id,
                 transaction_header_id,
                 je_line_id,
                 original_ytd_depreciation,
                 total_adjustment_amount,
                 period_adjustment_amount,
                 status,
                 retire_reinst_flag,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login)

        VALUES
                (fa_adjst_rec.retirement_id,
                 g_period_counter1,
                 fa_adjst_rec.distribution_id,
                 p_book_type_code,
                 fa_adjst_rec.asset_id,
                 fa_adjst_rec.transaction_header_id,
                 null,
                 round(fa_adjst_rec.orig_deprn,g_curr_precision),
                 round(l_adj_accum_deprn,g_curr_precision),
                 round(l_period_adj_amount,g_curr_precision),
                 'N',
                 'INF',
                 x_sysdate,
                 x_last_updated_by,
                 x_sysdate,
                 x_created_by,
                 x_last_update_login);



    ------------------------------------------------------------
    -- Get account concatenated segments                      --
    ------------------------------------------------------------
       SELECT code_combination_id
         INTO l_dist_ccid
         FROM fa_distribution_history
         WHERE distribution_id = fa_adjst_rec.distribution_id;

      get_segs(l_dist_ccid);

    ------------------------------------------------------------
    -- Report output                                          --
    ------------------------------------------------------------

       format_amount_out(l_period_adj_amount,l_amount_out);

        fnd_file.put_line( FND_FILE.OUTPUT, RPAD(LTRIM(fa_adjst_rec.asset_desc),47,' ')||
                                          RPAD(LTRIM(g_conc_segs),47,' ')||
                                          LPAD(l_amount_out,32,' ') );
    END LOOP;

    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of Procedure adjust_previous_retirements';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END adjust_previous_retirements;

    ------------------------------------------------------------
    -- Procedure: insert_retiremnt_jes                        --
    --                                                        --
    ------------------------------------------------------------
  PROCEDURE insert_retiremnt_jes IS

    CURSOR fa_adjst IS
      SELECT nvl(sum(a.period_adjustment_amount),0) adjst_amount,
             b.code_combination_id ccid, 1 ident
        FROM fa_distribution_history b,
             jl_zz_fa_retiremnt_adjs a
        WHERE a.book_type_code  = p_book_type_code
          AND a.period_counter  = g_period_counter1
          AND a.status          = 'N'
          AND a.distribution_id = b.distribution_id
        GROUP BY b.code_combination_id,1
    UNION
      SELECT nvl(sum(a.period_adjustment_amount),0) adjst_amount,
             c.reval_reserve_account_ccid ccid, 2  ident
        FROM fa_category_books c,
             fa_additions b,
             jl_zz_fa_retiremnt_adjs a
        WHERE a.book_type_code  = p_book_type_code
          AND a.period_counter  = g_period_counter1
          AND a.status          = 'N'
          AND b.asset_id        = a.asset_id
          AND c.book_type_code  = p_book_type_code
          AND c.category_id     = b.asset_category_id
        GROUP BY c.reval_reserve_account_ccid,2;


  l_current_category       NUMBER(15):=0;
  l_deprn_ccid             NUMBER(15):=0;
  l_api_name      CONSTANT VARCHAR2(30) := 'INSERT_RETIREMENT_JES';


  BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure Insert_retiremnt_jes';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

    FOR fa_adjst_rec IN fa_adjst
    LOOP

          INSERT INTO jl_zz_fa_retiremnt_jes
                (je_line_id,            book_type_code,      period_counter,
                 code_combination_id,   set_of_books_id,     request_id,
                 currency_code,         adjustment_amount,   debit_credit_flag,
                 posting_flag,          last_update_date,    last_updated_by,
                 creation_date,         created_by,          last_update_login)

          VALUES (
                 jl_zz_fa_retiremnt_jes_s.nextval,
                 p_book_type_code,
                 g_period_counter1,
                 fa_adjst_rec.ccid,
                 g_set_of_books_id,
                 x_request_id,
                 g_currency_code,
                 ABS(fa_adjst_rec.adjst_amount),
                 decode (fa_adjst_rec.ident,1,decode(sign(fa_adjst_rec.adjst_amount),-1,'CR','DR'),
                                            2,decode(sign(fa_adjst_rec.adjst_amount),-1,'DR','CR')),
                 null,
                 x_sysdate,
                 x_last_updated_by,
                 x_sysdate,
                 x_last_updated_by,
                 x_last_update_login);

          UPDATE   jl_zz_fa_retiremnt_adjs
          SET    je_line_id = jl_zz_fa_retiremnt_jes_s.currval,
                 status     = 'Y'
          WHERE rowid in (
                     SELECT  a.rowid
                       FROM fa_distribution_history b,
                            jl_zz_fa_retiremnt_adjs a
                       WHERE a.book_type_code  = p_book_type_code
                         AND a.period_counter  = g_period_counter1
                         AND a.status          = 'N'
                         AND a.distribution_id = b.distribution_id
                         AND b.code_combination_id = fa_adjst_rec.ccid);

    END LOOP; --Cursor
      g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of Procedure insert_retiremnt_jes';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END insert_retiremnt_jes;


    ------------------------------------------------------------
    -- Procedure: insert_gl_interface                         --
    --                                                        --
    ------------------------------------------------------------
  PROCEDURE insert_gl_interface IS
    --
    CURSOR jes_lines IS
      SELECT set_of_books_id,currency_code,adjustment_amount,
             code_combination_id,je_line_id,debit_credit_flag flag
        FROM jl_zz_fa_retiremnt_jes
        WHERE request_id = x_request_id
        FOR UPDATE OF posting_flag;

    l_group_id                 GL_INTERFACE.GROUP_ID%TYPE;
    l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_GL_INTERFACE';

  BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'Procedure insert_gl_interface';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;


    SELECT gl_interface_control_s.nextval
      INTO l_group_id
      FROM sys.dual;


    FOR jes_lin_rec IN jes_lines
    LOOP
      INSERT INTO gl_interface (
           status,
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
           period_name,
           code_combination_id,
           reference25,
           group_id)

      VALUES (
           'NEW',
           jes_lin_rec.set_of_books_id,
           g_current_period_to_date1,
           jes_lin_rec.currency_code,
           x_sysdate,
           x_last_updated_by,
           'A',
           g_user_je_category_name,
           g_user_je_source_name,
           decode (jes_lin_rec.flag,'DR',jes_lin_rec.adjustment_amount,'0'),
           decode (jes_lin_rec.flag,'CR',jes_lin_rec.adjustment_amount,'0'),
           G_PERIOD_name,
           jes_lin_rec.code_combination_id,
           jes_lin_rec.je_line_id,
           l_group_id);

    END LOOP;

      UPDATE jl_zz_fa_retiremnt_jes
        SET    posting_flag = 'Y'
        WHERE request_id = x_request_id;

    g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        x_char := 'End of procedure insert_gl_interface';
        fnd_file.put_line (FND_FILE.LOG, x_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

  END insert_gl_interface;

    ------------------------------------------------------------
    --                                                        --
    -- Main Procedure -  Code                                 --
    --                                                        --
    ------------------------------------------------------------

  BEGIN
    get_who_columns;
    get_details;
    current_period_reinstatements;
    current_period_retirements;
    adjust_previous_retirements;
    insert_retiremnt_jes;
    insert_gl_interface;
    COMMIT;
    retcode := '0';

    ------------------------------------------------------------
    --                Report output                           --
    ------------------------------------------------------------
        fnd_file.put(FND_FILE.OUTPUT,LPAD('-',132,'-'));
        fnd_file.new_line(FND_FILE.OUTPUT,1);
        fnd_file.new_line(FND_FILE.OUTPUT,2);
        fnd_message.set_name('JL','JL_ZZ_END_OF_REPORT');
        fnd_file.put_line( FND_FILE.OUTPUT,LPAD(' ',60,' ')||'***** '||fnd_message.get||' *****');


    EXCEPTION
      WHEN OTHERS THEN

        rollback;

        IF g_step = 'BOOK INFO' THEN
          fnd_message.set_name ('JL', 'JL_AR_FA_BOOK_INFO_NOT_DEFINED');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
          jl_zz_fa_utilities_pkg.raise_error ('JL',
                                           'JL_AR_FA_BOOK_INFO_NOT_DEFINED','APPS');
*/
        ELSIF g_step = 'DIST HIST' THEN
          fnd_message.set_name ('JL', 'JL_ZZ_FA_NO_DISTRIBUTION_INFO');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
          jl_zz_fa_utilities_pkg.raise_error ('JL',
                                           'JL_ZZ_FA_NO_DISTRIBUTION_INFO','APPS');
*/
        ELSIF g_step = 'CURR INDX' THEN
          fnd_message.set_name ('JL', 'JL_AR_FA_CURR_INDX_VAL_NOT_DEF');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
          jl_zz_fa_utilities_pkg.raise_error ('JL',
                                           'JL_AR_FA_CURR_INDX_VAL_NOT_DEF','APPS');
*/
        ELSIF g_step = 'CURR DPRN INFO' THEN
          fnd_message.set_name ('JL', 'JL_AR_FA_CUR_FY_DEP_PER_NOTDEF');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
          jl_zz_fa_utilities_pkg.raise_error ('JL',
                                           'JL_AR_FA_CUR_FY_DEP_PER_NOTDEF','APPS');
*/
        ELSIF g_step = 'PREV DPRN INFO' THEN
          fnd_message.set_name ('JL', 'JL_AR_FA_PRV_FY_DEP_PER_NOTDEF');
          fnd_file.put_line (fnd_file.log, fnd_message.get);
          call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
          jl_zz_fa_utilities_pkg.raise_error ('JL',
                                           'JL_AR_FA_PRV_FY_DEP_PER_NOTDEF','APPS');
*/
        ELSE
          jl_zz_fa_utilities_pkg.raise_ora_error;



        END IF;

  END deprn_adj_ret_assets;

END jl_zz_fa_deprn_adj_pkg;

/
