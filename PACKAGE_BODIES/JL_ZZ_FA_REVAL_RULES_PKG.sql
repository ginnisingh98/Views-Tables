--------------------------------------------------------
--  DDL for Package Body JL_ZZ_FA_REVAL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_FA_REVAL_RULES_PKG" AS
/* $Header: jlzzfrrb.pls 120.16 2006/12/22 18:59:54 abuissa ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_ZZ_FA_REVAL_RULES_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_ZZ_FA_REVAL_RULES_PKG.';


/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    reval_rules_generator                                                |
  |      p_book_type_code         Book Type Code                            |
  |      p_mass_reval_id          Mass Revaluation Id                       |
  |                                                                         |
  |  NOTES                                                                  |
  |  This procedure calculates the rates that have to be provided to the    |
  |  revaluation process in order to calculate the inflation adjustment.    |
  |  The rate is calculated in different ways depending on the type of book.|
  |  For CIP assets, the rate must consider the fact that current period    |
  |  modifications to the asset cost must not be inflation adjusted.        |
  |                                                                         |
  |  MODIFICATION HISTORY                                                   |
  |  12-SEP-97 G. Bertot Created                                            |
  |  21-DEC-98 G. Leyva    Major changes to include Chile.                  |
  |                        Added logic for date_placed_in_service and       |
  |                        reinstatements.                                  |
  |  27-JAN-99 G. Leyva    Changes in decimal numbers truncated to fix bug  |
  |                        808404.                                          |
  +=========================================================================+*/
  PROCEDURE reval_rules_generator (errbuf OUT NOCOPY VARCHAR2
                                 , retcode OUT NOCOPY VARCHAR2
                                 , p_book_type_code   IN  VARCHAR2
                                 , p_mass_reval_id    IN  NUMBER) IS

    ------------------------------------------------------------
    -- Procedure Global Variables                             --
    ------------------------------------------------------------
    g_step                     VARCHAR2(30);
    g_current_period_counter1  NUMBER (15);
    g_current_period_from_date1 DATE;
    g_current_period_from_date2 DATE;
    g_current_period_to_date1   DATE;
    g_current_period_to_date2   DATE;
    g_current_fiscal_year      NUMBER(4);
    g_previous_period_counter  NUMBER(15);
    g_previous_period_to_date  DATE;
    g_use_middle_month_table   VARCHAR2(3);
    g_calendar_type            FA_CALENDAR_TYPES.CALENDAR_TYPE%TYPE;
    g_price_index              NUMBER;
    g_country_code             VARCHAR2(2);
    g_precision                NUMBER;
    g_total_records            NUMBER := 0;
    g_period_num               NUMBER := 0;
    g_number_per_fy            NUMBER := 0;
    g_char                     VARCHAR2 (200);
    g_revalue_cip_assets_flag  VARCHAR2(1);
--Bug3466346
--  g_reval_fully_rsvd_flag    VARCHAR2(1);
    g_reval_fully_rsvd_flag    FA_MASS_REVALUATIONS.DEFAULT_REVAL_FULLY_RSVD_FLAG%TYPE;
    g_life_extension_factor    FA_MASS_REVALUATIONS.DEFAULT_LIFE_EXTENSION_FACTOR%TYPE;
    g_life_extension_ceiling   FA_MASS_REVALUATIONS.DEFAULT_LIFE_EXTENSION_CEILING%TYPE;

    g_period_open_date         DATE;
    TOO_MANY_COSTS             EXCEPTION;


    call_status                    BOOLEAN;

    ------------------------------------------------------------
    -- Local Variables                                        --
    ------------------------------------------------------------
    l_date_placed_in_service   DATE;
    l_current_category         NUMBER(15);
    l_revaluation_rate         NUMBER;
    l_err_msg                  VARCHAR2(1000);
    l_last_request_id          NUMBER;

    ------------------------------------------------------------
    -- Cursors                                                --
    ------------------------------------------------------------

    ------------------------------------------------------------
    -- Cursor: adjustable_assets                              --
    --                                                        --
    -- Fetch all the assets which can be inflation adjusted,  --
    -- those with fa_books.global_attribute1 = 'Y'.           --
    --                                                        --
    -- fa_additions.global_attribute1 stores the date when the--
    -- asset has to start to be adjusted.                     --
    ------------------------------------------------------------

    CURSOR adjustable_assets(l_country_code IN VARCHAR2) IS
--    SELECT /*+ leading(b) index(th  FA_TRANSACTION_HEADERS_U1) */ a.asset_id,
      SELECT a.asset_id,
             a.asset_category_id,
             a.asset_type,
             NVL(FND_DATE.CANONICAL_TO_DATE(a.global_attribute1),b.date_placed_in_service)  revaluation_start_date,
             b.date_placed_in_service,
             b.cost cost,
             rownum counter
        FROM
             fa_category_books c
             , fa_additions a
             , fa_books b
             , fa_transaction_headers th
       WHERE b.book_type_code = p_book_type_code
         AND b.cost <> 0
         AND b.global_attribute1 = 'Y'
         AND b.date_ineffective IS NULL
         AND b.transaction_header_id_out IS NULL
         AND a.asset_id = b.asset_id
         AND c.category_id = a.asset_category_id
         AND c.book_type_code = p_book_type_code
         AND c.global_attribute1 = 'Y'
         AND th.book_type_code = p_book_type_code
         AND th.asset_id = a.asset_id
--         AND th.transaction_type_code in ('ADDITION','CIP ADDITION')
         AND (th.transaction_type_code = 'ADDITION'
             OR (th.transaction_type_code = 'CIP ADDITION' AND a.asset_type <> 'CAPITALIZED'))
         AND th.date_effective < g_period_open_date
         AND th.transaction_header_id <= b.transaction_header_id_in
         AND ((g_revalue_cip_assets_flag is NULL AND a.asset_type = 'CAPITALIZED')
              OR (g_revalue_cip_assets_flag is NOT NULL))
         AND not exists (select 'X' from FA_TRANSACTION_HEADERS th_2
                         where th_2.book_type_code = p_book_type_code
                           AND th_2.asset_id       = a.asset_id
                           AND th_2.transaction_type_code = 'REVALUATION'
                           AND th_2.date_effective >= g_period_open_date)
         ORDER BY a.asset_category_id;

    ------------------------------------------------------------
    -- Procedure: initialize_process                          --
    --                                                        --
    -- Get Generic information for the package.               --
    -- Clean the rules table for the mass_reval_id given.     --
    -- Get all the book related information needed to         --
    -- calculate the revaluation rates.                       --
    ------------------------------------------------------------

    PROCEDURE initialize_process IS

    l_api_name           CONSTANT VARCHAR2(30) := 'INITIALIZE_PROCESS';

    BEGIN

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
       END IF;
      ------------------------------------------------------------
      -- Gets the country code where the program is executed.   --
      ------------------------------------------------------------
      -------------------------------------------------------------------------
      -- BUG 4650081. Profile for country is replaced by call to JG Shared pkg.
      -------------------------------------------------------------------------
      g_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY;
      FND_PROFILE.GET('JLZZ_INF_RATIO_PRECISION',g_precision);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         g_char := 'Start Debugging';
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);

         g_char := ' ';
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);

         g_char := 'Procedure initialize_process';
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);

         g_char := 'Country :'||g_country_code;
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);

         g_char := 'Precision :'||g_precision;
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;


      IF g_precision IS NULL THEN
         g_precision := 38;
      END IF;

      ------------------------------------------------------------
      -- Deletes rows that already exists for the mass reval id --
      -- to give way to the new rules                           --
      ------------------------------------------------------------
      g_step := 'DELETE_RULES';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Deleting fa_mass_revaluation_rules table';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      DELETE FROM fa_mass_revaluation_rules
        Where mass_reval_id = p_mass_reval_id;

      ------------------------------------------------------------
      -- Gives commit to delete transaction to release rollback --
      -- segment.                                               --
      ------------------------------------------------------------

        COMMIT;

      ------------------------------------------------------------
      -- Fetches the depreciation parameters for the current    --
      -- period.                                                --
      ------------------------------------------------------------
      g_step := '';

      SELECT calendar_period_open_date
           , calendar_period_close_date
           , fiscal_year
           , period_counter
           , period_open_date
        INTO g_current_period_from_date1
           , g_current_period_to_date1
           , g_current_fiscal_year
           , g_current_period_counter1
           , g_period_open_date
        FROM fa_deprn_periods
        WHERE book_type_code = p_book_type_code
         AND period_close_date IS NULL;


        SELECT deprn_calendar
          INTO g_calendar_type
          FROM fa_book_controls
          WHERE book_type_code = p_book_type_code;


       SELECT number_per_fiscal_year
         INTO g_number_per_fy
         FROM fa_calendar_types
         WHERE calendar_type = g_calendar_type;

       g_current_period_from_date2 := g_current_period_from_date1;
       g_current_period_to_date2 := g_current_period_to_date1;

/*     BUG # 3211526
       Moved the logic of determining cip assets revaluation flag from the main
       cursor for performance reasons */

      BEGIN
      SELECT nvl(rr.revalue_cip_assets_flag,'N') revalue_cip_assets_flag,
             nvl(rr.default_reval_fully_rsvd_flag,'NO') reval_fully_rsvd_flag,
             rr.default_life_extension_factor life_extension_factor,
             rr.default_life_extension_ceiling life_extension_ceiling
      INTO
             g_revalue_cip_assets_flag,
             g_reval_fully_rsvd_flag,
             g_life_extension_factor,
             g_life_extension_ceiling
      FROM   fa_mass_revaluations rr
      WHERE  rr.mass_reval_id = p_mass_reval_id;
      EXCEPTION WHEN OTHERS THEN
          g_char := 'Error: Mass Revaluation Id : '||to_char(p_mass_reval_id)||SQLERRM;
          fnd_file.put_line (FND_FILE.LOG, g_char);
      END;


      -----------------------------------------------------------------
      -- If the country is 'CL'(Chile), Fetch the depreciation       --
      -- parameters for the previous period and make it current.     --
      -- Reason : The calculation for chilean rate is different      --
      -- from other countries.                                       --
      -- Eg. When the current period is october :                    --
      -- For countries other than chile, the rate calculation is     --
      --        october rate   / september rate                      --
      --   current period = october    previous period = september   --
      -- For chile, the rate calculation should be                   --
      --        september rate / august rate                         --
      --  current period should be changed from october to september,--
      --  which helps the subsequent SQL statement to use            --
      --  august as previous period                                  --
      -----------------------------------------------------------------
          IF g_country_code = 'CL' THEN

      g_step := 'PREVIOUS PERIOD';

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

      g_step := '';

          END IF;

      ------------------------------------------------------------
      -- Fetch Period_Counter and calendar open and close date  --
      --  For previous period                                   --
      ------------------------------------------------------------

            g_previous_period_counter := g_current_period_counter1 - 1;
            g_previous_period_to_date := g_current_period_from_date2 - 1;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN

        g_char := 'Period counter :'||TO_CHAR(g_current_period_counter1);
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);

        g_char := ' ';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
        g_char := 'End of procedure initialize_process';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

    END initialize_process;


    ------------------------------------------------------------
    -- Procedure: initialize_category                         --
    --                                                        --
    -- Gets the price index associated to the category        --
    -- Bug 1415119 : Changed the query in the procedure       --
    -- "initialize_category" to cater for the situation       --
    -- where different price indexes are defined for          --
    -- different ranges of date placed in service.            --
    -- Bug 1488156 : Changed the query in the procedure       --
    -- "initialize_category" to deal with Items with          --
    -- date placed in service ahead of system time.           --
    ------------------------------------------------------------
    PROCEDURE initialize_category (p_category_id IN NUMBER,
                                   p_date_placed_in_service IN DATE) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'INITIALIZE_CATEGORY';

    BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      ------------------------------------------------------------
      -- Fetch the index for the depreciation book and category --
      ------------------------------------------------------------

      g_step := 'PRICE INDEX ID';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Procedure initialize_category';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      SELECT price_index_id
        INTO g_price_index
        FROM fa_category_book_defaults a, fa_price_indexes b
       WHERE a.book_type_code = p_book_type_code
         AND a.category_id    = p_category_id
         AND p_date_placed_in_service >= a.start_dpis
         AND p_date_placed_in_service <= NVL(a.end_dpis,p_date_placed_in_service)
         AND a.price_index_name = b.price_index_name;

      g_step := '';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Price index :'||TO_CHAR(g_price_index);
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

    END initialize_category;

    ------------------------------------------------------------
    -- Procedure: get_close_date                              --
    --                                                        --
    -- Gets the period_close_date from fa_deprn_periods for   --
    -- the book_type_code and a given date. If country is     --
    -- Chile then gets the calendar_period_close_date for     --
    -- previous period at the retired or placed in service.   --
    -- Bug 1974991 : The algorithm of figuring out period     ---
    --               close date is replaced.
    ------------------------------------------------------------
    PROCEDURE get_close_date (p_date IN DATE
                                  , l_close_date IN OUT NOCOPY DATE) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'GET_CLOSE_DATE';

     BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      g_step := 'MISSING PERIOD';

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Procedure get_close_date parameter p_date is '||p_date||
                  ' and must be in canonical format YYYY/MM/DD HH24:MI:SS';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;


      SELECT decode(g_country_code, 'CL',(start_date-1), end_date)
        INTO l_close_date
        FROM fa_calendar_periods
       WHERE calendar_type  = g_calendar_type
         AND trunc(p_date) BETWEEN start_date AND end_date;


      g_step := '';

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

    END get_close_date;


    ------------------------------------------------------------
    -- Procedure: get_price_index_rate                        --
    --                                                        --
    -- Gets the index value for a certain price index and a   --
    -- particular date.                                       --
    ------------------------------------------------------------
    PROCEDURE get_price_index_rate (p_period_date IN DATE
                                  , p_index_value IN OUT NOCOPY NUMBER) IS
    BEGIN
      g_step := 'PRICE INDEX VALUE';

      SELECT price_index_value
        INTO p_index_value
        FROM fa_price_index_values
       WHERE price_index_id = g_price_index
         AND p_period_date BETWEEN from_date AND nvl(to_date,p_period_date);

      g_step := '';

    END get_price_index_rate;

    ------------------------------------------------------------
    -- Procedure: get_costs                                   --
    --                                                        --
    -- Will find the adjusted cost of previous period on which--
    -- inflation adjustment has to be applied. Will also find --
    -- change in cost between the current period and previous --
    -- period
    ------------------------------------------------------------
    PROCEDURE get_costs (p1_asset_id                IN NUMBER
                       , p1_previous_period_counter IN NUMBER
                       , p1_current_cost            IN NUMBER
                       , p1_previous_period_cost    IN OUT NOCOPY NUMBER
                       , p1_change_in_cost          IN OUT NOCOPY NUMBER) IS

    BEGIN

      IF jl_zz_fa_functions_pkg.asset_cost (p_book_type_code
                                          , p1_asset_id
                                          , p1_previous_period_counter
                                          , p1_previous_period_cost) <> 0 THEN
        RAISE TOO_MANY_COSTS;
      END IF;

      p1_change_in_cost := p1_current_cost - p1_previous_period_cost;

    END get_costs;

    ------------------------------------------------------------
    -- Function: first_deprn                                  --
    --                                                        --
    -- Returns TRUE if this will be the first depreciation for--
    -- the given asset. If TRUE then date_placed_in_service   --
    -- should be taken to obtain the "previous period index". --
    ------------------------------------------------------------
    FUNCTION first_deprn (p_asset_id IN NUMBER
                        , p_current_period_counter IN NUMBER) RETURN BOOLEAN IS

      dummy   NUMBER;
      l_api_name           CONSTANT VARCHAR2(30) := 'FIRST_DEPRN';

      BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Function first_deprn';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      --
      --BUGS 2808946/2872684. Logic to identify First Depreciation period
      --                      has been changed.
      --
      BEGIN
         SELECT min(dp.period_counter)
         INTO   dummy
         FROM   fa_deprn_periods       dp
              , fa_transaction_headers th
              , fa_asset_history       ah
         WHERE ah.asset_id = th.asset_id
         AND   dp.book_type_code = th.book_type_code
         AND   th.transaction_header_id >= ah.transaction_header_id_in
         AND   th.transaction_header_id < nvl(ah.transaction_header_id_out, th.transaction_header_id + 1)
         AND   th.date_effective between dp.period_open_date
                                 and nvl(dp.period_close_date, th.date_effective)
         AND   dp.book_type_code = p_book_type_code
         AND   ah.asset_id       = p_asset_id;
      EXCEPTION
        WHEN OTHERS THEN
         RETURN(FALSE);
      END;

      IF (dummy = p_current_period_counter - 1) THEN
        RETURN(TRUE);
      ELSE
        RETURN(FALSE);
      END IF;

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

    END first_deprn;


    ------------------------------------------------------------
    -- Function: eval_reinstatements                          --
    -- Evaluates if the asset has been reinstanted and if this--
    -- is true then returns the cost and date of retirement.  --
    ------------------------------------------------------------
    FUNCTION eval_reinstatements (p_asset_id IN NUMBER,
                                  p_date_ini IN DATE,
                                  p_date_end IN DATE,
                                  p_amount OUT NOCOPY NUMBER,
                                  p_date_retired OUT NOCOPY DATE) RETURN BOOLEAN IS

      BEGIN

        SELECT cost_retired,date_retired
          INTO p_amount,p_date_retired
          FROM fa_transaction_headers b,
               fa_retirements a
          WHERE a.book_type_code = p_book_type_code
            AND a.asset_id       = p_asset_id
            AND a.status         = 'DELETED'
            AND b.book_type_code = a.book_type_code
            AND b.asset_id       = a.asset_id
            AND b.transaction_header_id = a.transaction_header_id_out
            AND b.transaction_date_entered BETWEEN p_date_ini AND
                                                   p_date_end
            ------------------------------------------------------
			-- BUG 4345686. Added to filter out assets retired and
			-- reinstated in the same period. We will consider
			-- those assets as if they were not retired at all
			-- for the purposes of reval rules generator.
			------------------------------------------------------
            AND b.transaction_type_code = 'REINSTATEMENT'
            AND b.transaction_date_entered <> a.date_retired;


         RETURN(TRUE);
      EXCEPTION
        WHEN OTHERS THEN
         RETURN(FALSE);
      END;

    ------------------------------------------------------------
    -- Function: get_revaluation_rates                        --
    --                                                        --
    -- Will compute the inflation adjustment rate depending on--
    -- the start date of the asset. Will call get_costs       --
    -- procedure to get the change in cost and the previous   --
    -- period cost                                            --
    ------------------------------------------------------------
    FUNCTION get_revaluation_rates (p_asset_id         IN NUMBER
                                  , p_asset_type       IN VARCHAR2
                                  , p_current_cost     IN NUMBER
                                  , p_asset_start_date IN DATE) RETURN NUMBER IS

      p_cost_retired            NUMBER;
      p_date_retired            DATE;
      l_close_date              DATE;
      l_current_index_value     NUMBER;
      l_index_retired1          NUMBER;
      l_index_retired2          NUMBER;
      l_previous_index_value    NUMBER;
      l_previous_period_cost    NUMBER;
      l_rate                    NUMBER;
      l_rate1                   NUMBER;
      l_rate2                   NUMBER;
      l_change_in_cost          NUMBER;
      l_api_name           CONSTANT VARCHAR2(30) := 'GET_REVALUATION_RATES';


    BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Function get_revaluation_rates ';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
        g_char := 'Asset id :'||TO_CHAR(p_asset_id);
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
        g_char := 'Asset start date :'||TO_CHAR(p_asset_start_date);
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      ------------------------------------------------------------
      -- Inflation adjustment rate will be computed here        --
      -- depending on start date.                               --
      -- Those assets with start date in or after the current   --
      -- period do not have to be inflation adjusted.           --
      ------------------------------------------------------------

      IF p_asset_start_date > g_current_period_to_date1 OR
           p_asset_start_date BETWEEN g_current_period_from_date1 AND
                                    g_current_period_to_date1 THEN
        l_rate := 0;

      ELSE

      ------------------------------------------------------------
      -- Obtain current period price index value                --
      ------------------------------------------------------------
        get_price_index_rate (g_current_period_to_date2
                            , l_current_index_value);


      ------------------------------------------------------------
      -- Obtain previous period price index value               --
      -- If status = 'DELETED' that indicates that is a         --
      -- REINSTANTED ASSET and the rate should be obtained  from--
      -- both current_index and previous_index (previous means  --
      -- when the RETIREMENT occured).                          --
      -- Same case if the first depreciation for the asset.     --
      ------------------------------------------------------------

        IF eval_reinstatements  ( p_asset_id ,
                                  g_current_period_from_date1 ,
                                  g_current_period_to_date1 ,
                                  p_cost_retired ,
                                  p_date_retired )  THEN

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             g_char := 'In eval_reinstatements';
             fnd_file.put_line (FND_FILE.LOG, g_char);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
           END IF;

           get_close_date(p_date_retired,l_close_date);

           get_price_index_rate (l_close_date
                              , l_index_retired1);


           get_price_index_rate (g_previous_period_to_date
                              , l_index_retired2);

           l_rate1 := l_current_index_value/l_index_retired1 - 1;
           l_rate2 := l_current_index_value/l_index_retired2 - 1;


           l_rate :=  ((p_current_cost + p_cost_retired * l_rate1 +
                      (p_current_cost-p_cost_retired) *l_rate2 )/p_current_cost)-1;

        ELSIF  first_deprn(p_asset_id , g_current_period_counter1) THEN

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             g_char := 'In first_deprn';
             fnd_file.put_line (FND_FILE.LOG, g_char);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
           END IF;

          get_close_date(p_asset_start_date,l_close_date);

          get_price_index_rate (l_close_date
                              , l_previous_index_value);
          IF p_asset_type = 'CIP' THEN
             l_rate := TRUNC((l_current_index_value / l_previous_index_value) - 1,g_precision);
          ELSE
             l_rate := (l_current_index_value / l_previous_index_value) - 1;
          END IF;

        ELSE

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             g_char := 'Normal Indexes';
             fnd_file.put_line (FND_FILE.LOG, g_char);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
           END IF;

          get_price_index_rate (g_previous_period_to_date
                              , l_previous_index_value);


          IF p_asset_type = 'CIP' THEN
            l_rate := TRUNC((l_current_index_value / l_previous_index_value) - 1,g_precision);
          ELSE
            l_rate := (l_current_index_value / l_previous_index_value) - 1;
          END IF;

        END IF;

      END IF;



      IF p_asset_type = 'CIP' THEN


        get_costs (p_asset_id, g_previous_period_counter
                 , p_current_cost, l_previous_period_cost
                 , l_change_in_cost);

           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             g_char := 'Asset CIP, previous cost, current cost :'||TO_CHAR(l_previous_period_cost)||','||TO_CHAR(p_current_cost);
             fnd_file.put_line (FND_FILE.LOG, g_char);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
           END IF;

        l_rate := ((p_current_cost + l_previous_period_cost * l_rate)/p_current_cost)-1;

        l_rate := l_rate * 100;

      ELSE

        l_rate := TRUNC(l_rate,g_precision) * 100;

      END IF;


      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

      RETURN(l_rate);

  END get_revaluation_rates;

    ------------------------------------------------------------
    -- Procedure: create_revaluation_rule                     --
    --                                                        --
    -- Creates a row in FA_MASS_REVALUATION_RULES that later  --
    -- will be the input to the Mass Revaluation Process.     --
    ------------------------------------------------------------
    PROCEDURE create_revaluation_rule (p_mass_reval_id IN NUMBER
                                     , p_asset_id IN NUMBER
                                     , p_revaluation_rate IN NUMBER) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_REVALUATION_RULE';

    BEGIN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Procedure create_revaluation_rule(+)';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
        g_char := 'values inserted into fa_mass_revaluation_rules:';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
        g_char := 'asset id:'||to_char(p_asset_id)||
                  ' override_defaults_flag:'||'No'||
                  ' revalue_cip_assets_flag:'||g_revalue_cip_assets_flag||
                  ' reval_fully_rsvd_flag:'||g_reval_fully_rsvd_flag||
                  ' life_extension_factor:'||to_char(g_life_extension_factor);
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      --
      --Bug 3073126. As indicated by FA masethur.in we have put following
      --             conditions.
      IF p_revaluation_rate > 0 AND g_reval_fully_rsvd_flag = 'YES' THEN
        IF nvl(g_life_extension_ceiling,0) <= 0 THEN
          g_char := 'Error: Invalid life extension ceiling:'||to_char(g_life_extension_ceiling);
          fnd_file.put_line (FND_FILE.LOG, g_char);
        END IF;
      END IF;

      INSERT INTO fa_mass_revaluation_rules
        (mass_reval_id
       , category_id
       , asset_id
       , reval_percent
       , override_defaults_flag
       , revalue_cip_assets_flag
       , reval_fully_rsvd_flag
       , life_extension_factor
       , life_extension_ceiling
       , last_updated_by
       , last_update_date)
      VALUES(p_mass_reval_id
       , null
       , p_asset_id
       , p_revaluation_rate
       , 'NO'
       , g_revalue_cip_assets_flag
       , g_reval_fully_rsvd_flag
       , g_life_extension_factor
       , g_life_extension_ceiling
       , fnd_global.user_id
       , sysdate);


       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         g_char := 'Procedure create_revaluation_rule(-)';
         fnd_file.put_line (FND_FILE.LOG, g_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
       END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

    END create_revaluation_rule;

    ------------------------------------------------------------
    -- Procedure: update_control_tables                       --
    --                                                        --
    -- Update depreciation book to indicate that was revalued --
    -- in the current period.                                 --
    -- It also updates fa_mass_revaluations table to indicate --
    -- in wich period revaluation has been run.               --
    ------------------------------------------------------------
    PROCEDURE update_control_tables (p_mass_reval_id IN NUMBER) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'UPDATE_CONTROL_TABLES';

    BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Procedure update_control_tables';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;
      UPDATE fa_book_controls
        SET global_attribute2 = g_current_period_counter1,
            global_attribute3 = p_mass_reval_id
        WHERE book_type_code = p_book_type_code;

-- Update commented to fix bug 1013530
/*
      UPDATE fa_mass_revaluations
         SET global_attribute1 = g_current_period_counter1
         WHERE mass_reval_id = p_mass_reval_id;
*/

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
      END IF;

    END update_control_tables;

    ------------------------------------------------------------
    -- Procedure: preview_report                              --
    --                                                        --
    -- This procedure submits the Preview Report that was     --
    -- being called from the FA core form (now disabled by    --
    -- Style function in JL library with style "Overwrite")   --
    ------------------------------------------------------------
    PROCEDURE preview_report IS
    l_request_id   NUMBER(15);
    l_message_text VARCHAR2(1000);
    l_api_name           CONSTANT VARCHAR2(30) := 'PREVIEW_REPORT';


    BEGIN

      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        g_char := 'Submiting Preview Report.';
        fnd_file.put_line (FND_FILE.LOG, g_char);
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, g_char);
      END IF;

      	     l_request_id := FND_REQUEST.SUBMIT_REQUEST('OFA',
		  	'FASRVPVW','','', FALSE,
	               	'P_MASS_REVAL_ID='||to_char(p_mass_reval_id),
		     	fnd_global.local_chr(0),'','','','','','','','',
		      	'','','','','','','','','','',
	      		'','','','','','','','','','',
		      	'','','','','','','','','','',
		      	'','','','','','','','','','',
	      		'','','','','','','','','','',
		      	'','','','','','','','','','',
		      	'','','','','','','','','','',
	      		'','','','','','','','','','',
		      	'','','','','','','','','','');

             IF l_request_id = 0 THEN
               FND_FILE.PUT_LINE(FND_FILE.log,'CONC-REQUEST SUBMISSION FAILED');
             ELSE
               FND_MESSAGE.SET_NAME('SQLGL','GL_REQUEST_SUBMITTED');
               FND_MESSAGE.SET_TOKEN('REQUEST_ID',l_request_id,FALSE);
               l_message_text := FND_MESSAGE.GET;
               FND_FILE.PUT_LINE(FND_FILE.log, l_message_text);
             END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

    END preview_report;


  ------------------------------------------------------------
  -- Main Program                                           --
  ------------------------------------------------------------
  BEGIN
    initialize_process;

    l_current_category := 0;
    l_date_placed_in_service :=NULL;

    FOR adjustable_assets_rec IN adjustable_assets(g_country_code) LOOP

      IF g_total_records < adjustable_assets_rec.counter THEN
        g_total_records := adjustable_assets_rec.counter;
      END IF;

    ------------------------------------------------------------
    -- Initialize the category properly                       --
    ------------------------------------------------------------

      IF (adjustable_assets_rec.asset_category_id <> l_current_category) OR
         (adjustable_assets_rec.date_placed_in_service <> l_date_placed_in_service) THEN

        initialize_category (adjustable_assets_rec.asset_category_id,
                             adjustable_assets_rec.date_placed_in_service);

        l_current_category := adjustable_assets_rec.asset_category_id;
        l_date_placed_in_service := adjustable_assets_rec.date_placed_in_service;

      END IF;

      --------------------------------------------------------------
      -- Obtain the revaluation rate using the                    --
      -- get_revaluation_rates function                           --
      --------------------------------------------------------------

      l_revaluation_rate := get_revaluation_rates
                              (adjustable_assets_rec.asset_id
                             , adjustable_assets_rec.asset_type
                             , adjustable_assets_rec.cost
                             , adjustable_assets_rec.revaluation_start_date);

      --------------------------------------------------------------
      -- Insert a row in fa_mass_revaluation_rules for every asset--
      -- that can be inflation adjusted                           --
      --------------------------------------------------------------

      create_revaluation_rule (p_mass_reval_id
                             , adjustable_assets_rec.asset_id
                             , l_revaluation_rate);
    END LOOP;

    --------------------------------------------------------------
    -- If everything went fine, then commit :)                  --
    --------------------------------------------------------------
    update_control_tables (p_mass_reval_id);



    preview_report;

    COMMIT;
    --------------------------------------------------------------
    -- Will notify the user records processed                   --
    --------------------------------------------------------------
      fnd_file.put(FND_FILE.LOG,'+');
      fnd_file.put(FND_FILE.LOG,LPAD('-',75,'-'));
      fnd_file.put(FND_FILE.LOG,'+');
      fnd_file.put_line( FND_FILE.LOG, '');
    IF g_total_records > 0 THEN
      fnd_message.set_name('JL', 'JL_CO_FA_PURGE_MESG');
      fnd_message.set_token('OPTION', g_total_records);
      fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
      fnd_file.put_line( FND_FILE.LOG, '');
    ELSE
      fnd_message.set_name('JL', 'JL_CO_FA_NOTHING_TO_PROCESS');
      fnd_file.put_line( FND_FILE.LOG, fnd_message.get);
    END IF;
      fnd_file.put(FND_FILE.LOG,'+');
      fnd_file.put(FND_FILE.LOG,LPAD('-',75,'-'));
      fnd_file.put(FND_FILE.LOG,'+');
      fnd_file.put_line( FND_FILE.LOG, '');
    retcode := 0;  -- Return normal status


    EXCEPTION
      WHEN TOO_MANY_COSTS THEN
               retcode := '2';
               fnd_message.set_name ('JL', 'JL_AR_FA_PREV_ADJ_COST_NAVL');
               fnd_file.put_line (fnd_file.log, fnd_message.get);
               call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
               jl_zz_fa_utilities_pkg.raise_error ('JL'
                                    , 'JL_AR_FA_PREV_ADJ_COST_NAVL', 'APP');
*/
      WHEN OTHERS THEN
        retcode := '2';
        IF g_step = 'PRICE INDEX ID' THEN
           fnd_message.set_name ('JL', 'JL_AR_FA_INDX_NOT_DEF_FOR_CATG');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
           jl_zz_fa_utilities_pkg.raise_error ('JL'
                                    , 'JL_AR_FA_INDX_NOT_DEF_FOR_CATG', 'APP');
*/
        ELSIF g_step = 'PREVIOUS PERIOD' THEN
           fnd_message.set_name ('JL', 'JL_AR_FA_PERIODS_NOT_DEF_SEQUN');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
           jl_zz_fa_utilities_pkg.raise_error ('JL'
                                    , 'JL_AR_FA_PERIODS_NOT_DEF_SEQUN', 'APP');
*/
        ELSIF g_step = 'MISSING PERIOD' THEN
           fnd_message.set_name ('JL', 'JL_AR_FA_DEPRN_PERIOD_NOT_OPEN');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
           jl_zz_fa_utilities_pkg.raise_error ('JL'
                                    , 'JL_AR_FA_DEPRN_PERIOD_NOT_OPEN', 'APP');
*/
        ELSIF g_step = 'PRICE INDEX VALUE' THEN
           fnd_message.set_name ('JL', 'JL_AR_FA_CURR_INDX_VAL_NOT_DEF');
           fnd_file.put_line (fnd_file.log, fnd_message.get);
           call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
           jl_zz_fa_utilities_pkg.raise_error ('JL'
                                    , 'JL_AR_FA_CURR_INDX_VAL_NOT_DEF', 'APP');
*/
        ELSE
           jl_zz_fa_utilities_pkg.raise_ora_error;
        END IF;


  END reval_rules_generator;

END jl_zz_fa_reval_rules_pkg;

/
