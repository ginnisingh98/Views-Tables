--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GL_INFL_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GL_INFL_ADJ_PKG" AS
/* $Header: jlzzgaxb.pls 120.9 2006/03/24 21:26:46 appradha ship $ */
----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   inflation_adjustment                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this process to perform the Inflation Adjustment for Argentina   --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.0                                         --
--   Product : Oracle General Ledger - Latin America                      --
--                                                                        --
-- PARAMETERS:                                                            --
--   Inflation Run Id : Execution id                                      --
--   From period      : First period to be adjusted                       --
--   To Period        : Last period to be adjusted                        --
--   Set of Books Id  : Set of books to be adjusted                       --
--   Index Id         : used to adjust the accounts                       --
--   Error Message    : Returned to the report                            --
--   Error Message Number : Idem                                          --
--   Error Message Code : Idem                                            --
--                                                                        --
-- HISTORY:                                                               --
--   19/03/97   German Bertot                                             --
--   20/08/97   German Bertot  Changed the procedure definition to call   --
--                            it from the Infl. Adj. Report instead of    --
--                            submiting it as a concurrent request.       --
--   22/10/98  Deepak Khanna 1. Major change in Adj.calculation method.   --
--                           2. Extending Infl. Adj. procedure for 'CL'.  --
--                           3. Enhancement in segment selection criteria --
--                           4. Introduction of rate precision .          --
----------------------------------------------------------------------------
  FUNCTION INFLATION_ADJUSTMENT (p_inflation_adj_run_id IN NUMBER
                               , p_adjust_from_period   IN VARCHAR2
                               , p_adjust_to_period     IN VARCHAR2
                               , p_set_of_books_id      IN NUMBER
                               , p_infl_adj_index_id    IN NUMBER
                               , p_group_id             IN OUT NOCOPY NUMBER
                               , p_err_msg_name         IN OUT NOCOPY VARCHAR2
                               , p_err_msg_num          IN OUT NOCOPY NUMBER
                               , p_err_msg_code         IN OUT NOCOPY VARCHAR2)
   RETURN NUMBER IS

    GL_APPS_ID                   CONSTANT NUMBER (15) := 101;

    set_of_books_name            VARCHAR2 (30);
    set_of_books_currency_code   VARCHAR2 (15);
    currency_precision           NUMBER (1);
    chart_of_accounts_id         NUMBER;
    period_set_name              VARCHAR2 (15);
    balancing_segment            VARCHAR2 (30);
    balancing_segment_idx	 NUMBER (3);

    num_enabled_segments         INTEGER;
    number_records               NUMBER (15);
    user_je_category_name        VARCHAR2 (25);
    user_je_source_name          VARCHAR2 (25);

    infl_adjust_gain_loss_ccid   NUMBER (15);

    main_cursor                  INTEGER;

    infl_adjustment_rate         NUMBER;

    infl_adj_gla                 NUMBER (15); -- Infl. Adj. Gain/Loss Account

    balancing_segment_tot_amount NUMBER := 0;
    acct_total_adj_amount        NUMBER := 0;
    acct_period_adj_amount       NUMBER := 0;

    fv_flag                      VARCHAR2 (1) := 'N';
    fv_adjustment_amount         NUMBER;
    fv_period_amount             NUMBER := 0;

    c_code_combination_id        NUMBER (15);
    c_balancing_segment          VARCHAR2 (25);
    c_ytd_balance                NUMBER;
    c_ptd_balance                NUMBER;
    c_period_name                VARCHAR2 (15);
    previous_code_combination_id NUMBER (15);
    previous_balancing_segment   VARCHAR2 (25);
    accounting_date              DATE;

    consider_YTD_amount          VARCHAR2 (1) := 'N';
    acct_begin_YTD_adj_amount    NUMBER;
    YTD_prev_period_name         VARCHAR2 (25);
    zero_main_records            VARCHAR2(3) := 'YES';

    --profile_country_code         VARCHAR2(10) := fnd_profile.value('JGZZ_COUNTRY_CODE');
    profile_country_code         VARCHAR2(10) := jg_zz_shared_pkg.get_country(null,null);

    program_abort                EXCEPTION;

    ------------------------------------------------------------
    -- Record Type Decalartion To Store 'Main Cursor' Values  --
    ------------------------------------------------------------
    TYPE main_cursor_record IS RECORD (
      r_ccid NUMBER(15),
      r_bal_segment VARCHAR2(25),
      r_ytd_balance NUMBER,
      r_ptd_balance NUMBER,
      r_period_name VARCHAR2(15));

    prevrec main_cursor_record;

     ------------------------------------------------------------
    -- Get the corresponding functional currency amount for   --
    -- account's Non functional currency amount .             --
    ------------------------------------------------------------

   FUNCTION get_non_func_amt (p_set_of_books_id IN NUMBER
                            , p_code_combination_id IN NUMBER
                            , p_ytd IN OUT NOCOPY NUMBER
                            , p_ptd IN OUT NOCOPY NUMBER
                            , p_period_name  IN VARCHAR2)
   RETURN BOOLEAN IS

  BEGIN

      SELECT nvl(sum(nvl(gb.begin_balance_dr_beq, 0) - nvl (gb.begin_balance_cr_beq, 0)),0) YTD_AMOUNT,
      nvl(sum(nvl (gb.period_net_dr_beq, 0) - nvl (gb.period_net_cr_beq, 0)),0) PTD_AMOUNT
      into p_ytd,p_ptd
      FROM  gl_balances gb
      WHERE gb.ledger_id = p_set_of_books_id
      AND gb.code_combination_id = p_code_combination_id
      AND gb.currency_code <> set_of_books_currency_code
      AND gb.Period_name = p_period_name
      AND gb.actual_flag = 'A'
      AND gb.translated_flag is not null
      AND gb.template_id is null;

      RETURN TRUE;

     EXCEPTION
     WHEN OTHERS THEN
       p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

     END get_non_func_amt;


    ------------------------------------------------------------
    -- Get the previous period name.                          --
    ------------------------------------------------------------

   FUNCTION get_previous_period ( p_period_set_name  IN VARCHAR2
                                , p_period_name      IN VARCHAR2
                                , p_prev_period_name IN OUT NOCOPY VARCHAR2)
   RETURN BOOLEAN IS

    curr_period_num           NUMBER(15);
    curr_period_Year          NUMBER(15);
    curr_period_type          VARCHAR2(15);

   BEGIN
          SELECT  a.period_num,
                  a.period_year,
                  a.period_type
            INTO  curr_period_num ,
                 curr_period_year,
                 curr_period_type
            FROM  gl_periods a
           WHERE a.period_set_name = p_period_set_name
             AND a.period_name =     p_period_name;


      IF curr_period_num > 1 THEN

          SELECT period_name
            INTO p_prev_period_name
            FROM gl_periods
            WHERE period_set_name = p_period_set_name
              AND period_year = curr_period_year
              AND period_type = curr_period_type
              AND period_num = (SELECT max(period_num)
                                  FROM gl_periods
                                  WHERE period_set_name = p_period_set_name
                                    AND period_year = curr_period_year
                                    AND period_num <  curr_period_num
                                    AND period_type = curr_period_type
                                    AND adjustment_period_flag <> 'Y');


      ELSE
          SELECT period_name
            INTO p_prev_period_name
            FROM gl_periods
            WHERE period_set_name = p_period_set_name
              AND period_year = curr_period_year - 1
              AND period_type = curr_period_type
              AND period_num = (SELECT max(period_num)
                                  FROM gl_periods
                                  WHERE period_set_name = p_period_set_name
                                    AND period_year = curr_period_year - 1
                                    AND period_type = curr_period_type
                                    AND adjustment_period_flag <> 'Y');
      END IF;
     RETURN TRUE;

     EXCEPTION

    WHEN NO_DATA_FOUND THEN
        p_err_msg_name := 'JL_ZZ_GL_PERIOD_DETL_NOT_DEF';
        p_err_msg_num  := 62022;
        p_err_msg_code := 'APP';
        RETURN FALSE;

     WHEN OTHERS THEN
       p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

     END get_previous_period;





    ------------------------------------------------------------
    -- Get the adjustment rate precision from the profile    --
    -----------------------------------------------------------

    FUNCTION  get_adj_rate_precision ( adj_rate_precision  OUT NOCOPY NUMBER)
     RETURN BOOLEAN IS

     profile_in_char  VARCHAR2(3);

     BEGIN

    -----------------------------------------------------------
    -- Pick profile value --
    -----------------------------------------------------------

     profile_in_char := fnd_profile.value('JLZZ_INF_RATIO_PRECISION');

     IF profile_in_char is NULL then

      adj_rate_precision := 0;

      RETURN FALSE;

     END IF;

      adj_rate_precision  := to_number(profile_in_char);

      RETURN TRUE;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
     RETURN FALSE;
     WHEN OTHERS THEN
     RETURN  FALSE;
    END get_adj_rate_precision;

    ------------------------------------------------------------
    --  Retrieves the information related to the set of books --
    ------------------------------------------------------------
    FUNCTION get_set_of_books_info (p_set_of_books_id   IN NUMBER
                                  , p_set_of_books_name IN OUT NOCOPY VARCHAR2
                                  , p_sob_currency_code IN OUT NOCOPY VARCHAR2
                                  , p_chart_of_accounts_id IN OUT NOCOPY NUMBER
                                  , p_balancing_segment IN OUT NOCOPY VARCHAR2
                                  , p_period_set_name   IN OUT NOCOPY VARCHAR2
                                  , p_curr_precision IN OUT NOCOPY NUMBER
                                  , p_num_enabled_segments IN OUT NOCOPY INTEGER)
      RETURN BOOLEAN IS

      acct_flexfield fnd_flex_key_api.flexfield_type;
      acct_structure fnd_flex_key_api.structure_type;
      acct_segments  fnd_flex_key_api.segment_list;
      statement      VARCHAR2 (20);

      cannot_find_balancing_segment  EXCEPTION;

    BEGIN

    ------------------------------------------------------------
    -- Get book name, currency code, AFF structure and        --
    -- calendar name.                                         --
    ------------------------------------------------------------
      SELECT name, currency_code, chart_of_accounts_id, period_set_name
        INTO p_set_of_books_name, p_sob_currency_code, p_chart_of_accounts_id,
             p_period_set_name
        FROM gl_sets_of_books
        WHERE set_of_books_id = p_set_of_books_id;

    ------------------------------------------------------------
    -- Get currency precision.                                --
    ------------------------------------------------------------
      statement := 'CURR PREC';

      SELECT precision
        INTO p_curr_precision
        FROM fnd_currencies_vl
        WHERE currency_code = p_sob_currency_code;

    ------------------------------------------------------------
    -- Get flexfield information                              --
    ------------------------------------------------------------
      statement := 'FND FLEX';
      fnd_flex_key_api.set_session_mode('customer_data');

      acct_flexfield := fnd_flex_key_api.find_flexfield
                                           (appl_short_name => 'SQLGL'
                                          , flex_code =>'GL#');

      acct_structure := fnd_flex_key_api.find_structure
                                   (flexfield => acct_flexfield
                                 , structure_number => p_chart_of_accounts_id);

    ------------------------------------------------------------
    -- Get number of segments enabled and the segments names. --
    ------------------------------------------------------------
      fnd_flex_key_api.get_segments (flexfield => acct_flexfield
                                   , structure => acct_structure
                                   , enabled_only => TRUE
                                   , nsegments => p_num_enabled_segments
                                   , segments => acct_segments);

    ------------------------------------------------------------
    -- Get the balancing segment name (for example 'SEGMENT1')--
    ------------------------------------------------------------
      IF NOT fnd_flex_apis.get_segment_column (101
                                    ,'GL#'
                                    , p_chart_of_accounts_id
                                    ,'GL_BALANCING'
                                    ,p_balancing_segment) THEN

        RAISE cannot_find_balancing_segment;
      END IF;

      RETURN TRUE;

    EXCEPTION
      WHEN cannot_find_balancing_segment THEN
        p_err_msg_name := 'JL_ZZ_GL_BALANCING_SEG_ERROR';
        p_err_msg_num  := 62014;
        p_err_msg_code := 'APP';
        RETURN FALSE;

      WHEN OTHERS THEN
        IF statement = 'CURR PREC' THEN
          p_err_msg_name := 'JL_ZZ_GL_CURR_PREC_NA';
          p_err_msg_num  := 62246;
          p_err_msg_code := 'APP';

        ELSE
          p_err_msg_name := 'JL_ZZ_GL_BOOK_INFO_NA';
          p_err_msg_num  := 62016;
          p_err_msg_code := 'APP';
        END IF;

        RETURN FALSE;

    END get_set_of_books_info;


    ------------------------------------------------------------
    -- Gets the price index value for a certain period.       --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION get_inflation_index_value (p_index_id        IN NUMBER
                                      , p_period_set_name IN VARCHAR2
                                      , p_period_name     IN VARCHAR2
                                      , p_index_value     IN OUT NOCOPY NUMBER)
      RETURN BOOLEAN IS

        ix_period_name VARCHAR2(15);
        period_error         EXCEPTION;

    BEGIN

        ix_period_name := p_period_name;

    ---------------------------------------------------------------
    -- Check for the country profile.                            --
    -- If Country is  'Chile', then introduce one period lag.    --                                                      --
    ---------------------------------------------------------------

      IF fnd_profile.value('JGZZ_COUNTRY_CODE') = 'CL' THEN

       IF NOT get_previous_period( p_period_set_name
                                  ,p_period_name
                                 ,ix_period_name) THEN
           RAISE period_error;
       END IF;


      END IF;

      SELECT price_index_value
        INTO p_index_value
        FROM fa_price_index_values fpiv
           , gl_periods gp
        WHERE fpiv.price_index_id = p_index_id
          AND gp.period_name = ix_period_name
          ANd gp.period_set_name = p_period_set_name
          AND gp.end_date BETWEEN fpiv.from_date
                              AND nvl (fpiv.to_date, gp.end_date);

      RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_err_msg_name := 'JL_AR_FA_CURR_INDX_VAL_NOT_DEF';
        p_err_msg_num  := 62001;
        p_err_msg_code := 'APP';
        RETURN FALSE;

      WHEN period_error THEN
        RETURN FALSE;

      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_inflation_index_value;


    ------------------------------------------------------------
    -- Get group Id for the Journal Entries to be inserted in --
    -- GL_INTERFACE.                                          --
    -- It also returns the inflation adjustment gain and loss --
    -- account template and the index value for the particular--
    -- period (the 'to' period).                              --
    ------------------------------------------------------------
    FUNCTION init_process (p_group_id              IN OUT NOCOPY NUMBER
                         , p_set_of_books_id       IN NUMBER
                         , p_REI_ccid              IN OUT NOCOPY NUMBER
                         , p_axi_run_id            IN NUMBER
                         , p_to_period_name        IN VARCHAR2
                         , p_accounting_date       IN OUT NOCOPY DATE
                         , p_user_je_category_name IN OUT NOCOPY VARCHAR2
                         , p_user_je_source_name   IN OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN IS

    statement VARCHAR2 (20);

    BEGIN
      statement := 'GROUP ID';
      SELECT gl_interface_control_s.nextval
        INTO p_group_id
        FROM sys.dual;

      statement := 'REI ACCOUNT';
      SELECT code_combination_id
        INTO p_REI_ccid
        FROM jl_zz_gl_axi
        WHERE set_of_books_id = p_set_of_books_id;

      statement := 'DELETE';
      DELETE FROM jl_zz_gl_axi_tmp
        WHERE axi_run_id = p_axi_run_id;

      statement := 'SOURCE';
      SELECT user_je_source_name
        INTO p_user_je_source_name
        FROM gl_je_sources
        WHERE je_source_name = 'Inflation';


      statement := 'CATEGORY';
      SELECT user_je_category_name
        INTO p_user_je_category_name
        FROM gl_je_categories
        WHERE je_category_name = 'Adjustment';

      statement := 'ACCOUNTING DATE';
      SELECT end_date
        INTO p_accounting_date
        FROM gl_period_statuses
        WHERE application_id  = GL_APPS_ID
          AND set_of_books_id = p_set_of_books_id
          AND period_name     = p_to_period_name;


      RETURN TRUE;


    EXCEPTION
      WHEN OTHERS THEN
        IF statement = 'REI ACCOUNT' THEN
          p_err_msg_name := 'JL_ZZ_GL_INFL_ADJ_ACCOUNT';
          p_err_msg_num  := 62018;
          p_err_msg_code := 'APP';
          RETURN FALSE;

        ELSIF statement = 'CATEGORY' THEN
          p_err_msg_name := 'JL_ZZ_GL_CATEGORY_NAME';
          p_err_msg_num  := 62243;
          p_err_msg_code := 'APP';
          RETURN FALSE;

        ELSIF statement = 'SOURCE' THEN
          p_err_msg_name := 'JL_ZZ_GL_SOURCE_NAME';
          p_err_msg_num  := 62242;
          p_err_msg_code := 'APP';
          RETURN FALSE;

        ELSE
          p_err_msg_name := substr (SQLERRM, 1, 100);
          p_err_msg_code := 'ORA';
          RETURN FALSE;

        END IF;

    END init_process;


    ------------------------------------------------------------
    -- Given a price index and a period, returns the inflation--
    -- adjustment rate to be applied to the account balance   --
    -- in order to get the adjusted value.                    --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION get_adjustment_rate (p_index_id        IN NUMBER
                                , p_set_of_books_id IN NUMBER
                                , p_period_set_name IN VARCHAR2
                                , p_period_name     IN VARCHAR2
                                , p_infl_rate       OUT NOCOPY NUMBER)
      RETURN BOOLEAN IS



      current_period_idx_value  NUMBER;
      to_period_idx_value       NUMBER;


      adj_rate_precision        NUMBER(3);


      statement                 VARCHAR2 (30);
      INDEX_EQUAL_TO_ZERO       EXCEPTION;
      index_error               EXCEPTION;


    BEGIN


      statement := 'CURRENT_PERIOD_INDEX';



      IF NOT get_inflation_index_value (p_index_id
                                      , p_period_set_name
                                      , p_period_name
                                      , current_period_idx_value) THEN
        RAISE index_error;
      END IF;

      IF current_period_idx_value = 0 then
        RAISE INDEX_EQUAL_TO_ZERO;
      END IF;

      statement := 'TO_PERIOD_INDEX';


      IF NOT get_inflation_index_value (p_index_id
                                   , p_period_set_name
                                   , p_adjust_to_period
                                   , to_period_idx_value) THEN
        RAISE index_error;
      END IF;

     IF NOT get_adj_rate_precision(adj_rate_precision) then

         p_infl_rate := (to_period_idx_value / current_period_idx_value) - 1;
      ELSE
        p_infl_rate := round(((to_period_idx_value / current_period_idx_value)-1),
                           adj_rate_precision);

      END IF;


      RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF statement = 'PREVIOUS PERIOD' THEN
          p_err_msg_name := 'JL_ZZ_GL_PRICE_INDEX_VALUE_NA';
          p_err_msg_num  := 62023;
          p_err_msg_code := 'APP';
          RETURN FALSE;

        END IF;

      WHEN INDEX_EQUAL_TO_ZERO THEN
        p_err_msg_name := 'JL_ZZ_GL_PRICE_INDEX_VALUE_NA';
        p_err_msg_num  := 62023;
        p_err_msg_code := 'APP';
        RETURN FALSE;

      WHEN index_error THEN
        RETURN FALSE;

      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_adjustment_rate;


    ------------------------------------------------------------
    -- Given a period name and a calendar, returns the period --
    -- year and period num.                                   --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION get_period_counter (p_period_set_name IN VARCHAR2
                                , p_period_name IN VARCHAR2
                                , p_period_year IN OUT NOCOPY NUMBER
                                , p_period_num  IN OUT NOCOPY NUMBER)
       RETURN BOOLEAN IS

    BEGIN

       SELECT period_year, period_num
         INTO p_period_year, p_period_num
         FROM gl_periods
        WHERE period_name = p_period_name
          AND period_set_name = p_period_set_name;

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_period_counter;


    ------------------------------------------------------------
    -- Procedure: build_main_cursor                           --
    --                                                        --
    -- Dynamically defines the main cursor, considering the   --
    -- number of segments enabled.                            --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION build_main_cursor (p_set_of_books_id IN NUMBER
                               , p_period_set_name IN VARCHAR2
                               , p_period_from IN VARCHAR2
                               , p_period_to   IN VARCHAR2
                               , p_balancing_segment IN VARCHAR2
                               , p_enabled_segments IN INTEGER
                               , p_axi_run_id  IN NUMBER
                               , p_main_cursor IN OUT NOCOPY INTEGER)
      RETURN BOOLEAN IS

      cursor_string        VARCHAR2 (3000);
      idx                  INTEGER;
      code_combination_id  NUMBER (15);
      balance              NUMBER;
      period_name          VARCHAR2 (15);
      segment              VARCHAR2 (25);
      period_year_from     NUMBER (15);
      period_num_from      NUMBER (15);
      period_year_to       NUMBER (15);
      period_num_to        NUMBER (15);

      CURSOR SEG_list IS
        SELECT application_column_name name
        FROM fnd_id_flex_segments
        WHERE application_id = 101 AND
              id_flex_code = 'GL#' AND
              id_flex_num = chart_of_accounts_id AND
              enabled_flag = 'Y'
        ORDER by segment_num;


      period_error         EXCEPTION;

    BEGIN
      ------------------------------------------------------------
      -- Gets the period year and period number for the first   --
      -- period to be adjusted.                                 --
      ------------------------------------------------------------
      IF NOT get_period_counter (p_period_set_name
                               , p_period_from
                               , period_year_from
                               , period_num_from) THEN
        RAISE period_error;
      END IF;

      ------------------------------------------------------------
      -- Gets the period year and period number for the last    --
      -- period to be adjusted.                                 --
      ------------------------------------------------------------
      IF NOT get_period_counter (p_period_set_name
                               , p_period_to
                               , period_year_to
                               , period_num_to) THEN
        RAISE period_error;
      END IF;

      ------------------------------------------------------------
      -- Store the cursor's select statement in cursor_string.  --
      -- Note: Balancing segment, period year and period num    --
      --       columns are not required by the program logic.   --
      --       However they were included to avoid compilation  --
      --       errors due to the coexistence of both DISTINCT   --
      --       and ORDER BY clauses.                            --
      ------------------------------------------------------------
      /*Bug 2939830 - SQL Bind compliance project
      cursor_string :=
         'SELECT gcc.code_combination_id'
      || ', gcc.' || p_balancing_segment || ' balancing_sement'
      || ', nvl (gb.begin_balance_dr, 0) - nvl (gb.begin_balance_cr, 0) '
      || ' ytd_balance'
      || ', nvl (gb.period_net_dr, 0) - nvl (gb.period_net_cr, 0) ptd_balance'
      || ', gb.period_name'
      || ', gb.period_year'
      || ', gb.period_num'
      || ' FROM gl_code_combinations gcc'
      || '    , gl_balances gb'
      || '    , jl_zz_gl_axi_accounts jagaa'
      || ' WHERE gcc.code_combination_id = gb.code_combination_id'
      || ' AND gb.ledger_id = ' || p_set_of_books_id
      || ' AND gb.currency_code = ''' || set_of_books_currency_code||''''
      || ' AND gb.actual_flag = ''A'''
      || ' AND gb.translated_flag is null'
      || ' AND gb.template_id is null'
      || ' AND gb.period_year BETWEEN ' || period_year_from
      || ' AND ' || period_year_to
      || ' AND gb.period_num BETWEEN ' || period_num_from
      || ' AND ' || period_num_to
      || ' AND jagaa.axi_run_id = ' || p_axi_run_id;
      */

      cursor_string :=
         'SELECT gcc.code_combination_id'
      || ', gcc.' || p_balancing_segment || ' balancing_sement'
      || ', nvl (gb.begin_balance_dr, 0) - nvl (gb.begin_balance_cr, 0) '
      || ' ytd_balance'
      || ', nvl (gb.period_net_dr, 0) - nvl (gb.period_net_cr, 0) ptd_balance'
      || ', gb.period_name'
      || ', gb.period_year'
      || ', gb.period_num'
      || ' FROM gl_code_combinations gcc'
      || '    , gl_balances gb'
      || '    , jl_zz_gl_axi_accounts jagaa'
      || ' WHERE gcc.code_combination_id = gb.code_combination_id'
      || ' AND gb.ledger_id = :1'
      --|| ' AND gb.currency_code = ''' || ':2' ||'''' --Bug 3183432
      || ' AND gb.currency_code = :2'
      || ' AND gb.actual_flag = ''A'''
      || ' AND gb.translated_flag is null'
      || ' AND gb.template_id is null'
      || ' AND gb.period_year BETWEEN :3' || ' AND :4 '
      || ' AND gb.period_num BETWEEN :5'  || ' AND :6 '
      || ' AND jagaa.axi_run_id = :7';

      ------------------------------------------------------------
      -- Depending on the number of segments enabled adds       --
      -- as many conditions as necessary to the select statement--
      ------------------------------------------------------------
      idx := 0;

      FOR seg_rec IN SEG_list LOOP

      idx := idx + 1;

        cursor_string := cursor_string ||
          ' AND gcc.' || seg_rec.name || ' BETWEEN jagaa.' || seg_rec.name ||
          '_low AND jagaa.' || seg_rec.name || '_high';

      IF upper(seg_rec.name) = upper(balancing_segment) THEN

      balancing_segment_idx := idx;

      END IF;

      END LOOP;

      ------------------------------------------------------------
      -- Ordering criteria for the cursor.                      --
      ------------------------------------------------------------
      cursor_string := cursor_string || ' ORDER BY gcc.' ||
        p_balancing_segment ||
        ', gcc.code_combination_id, gb.period_year, gb.period_num';

      ------------------------------------------------------------
      -- Dynamic sql operations to parse the select statement   --
      -- and to define columns datatypes.                       --
      ------------------------------------------------------------
      dbms_sql.parse (p_main_cursor, rtrim (cursor_string), dbms_sql.NATIVE);
      dbms_sql.bind_variable (p_main_cursor, ':1', p_set_of_books_id);
      dbms_sql.bind_variable (p_main_cursor, ':2', set_of_books_currency_code);
      dbms_sql.bind_variable (p_main_cursor, ':3', period_year_from);
      dbms_sql.bind_variable (p_main_cursor, ':4', period_year_to);
      dbms_sql.bind_variable (p_main_cursor, ':5', period_num_from);
      dbms_sql.bind_variable (p_main_cursor, ':6', period_num_to);
      dbms_sql.bind_variable (p_main_cursor, ':7', p_axi_run_id);

      dbms_sql.define_column (p_main_cursor, 1, code_combination_id);
      dbms_sql.define_column (p_main_cursor, 2, segment, 25);
      dbms_sql.define_column (p_main_cursor, 3, balance);
      dbms_sql.define_column (p_main_cursor, 4, balance);
      dbms_sql.define_column (p_main_cursor, 5, period_name, 15);
      dbms_sql.define_column (p_main_cursor, 6, period_year_to);
      dbms_sql.define_column (p_main_cursor, 7, period_num_to);

      RETURN TRUE;

    EXCEPTION
      WHEN period_error THEN
        RETURN FALSE;

      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END build_main_cursor;


    ------------------------------------------------------------
    -- Calls the procedures to retrieve the information       --
    -- returned by the dynamic cursor.                        --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION get_cursor_values (p_main_cursor IN INTEGER
                             , p_code_combination_id IN OUT NOCOPY NUMBER
                             , p_balancing_segment IN OUT NOCOPY VARCHAR2
                             , p_ytd_balance IN OUT NOCOPY NUMBER
                             , p_ptd_balance IN OUT NOCOPY NUMBER
                             , p_period_name IN OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN IS

    non_func_ytd                 NUMBER;
    non_func_ptd                 NUMBER;

    BEGIN
      dbms_sql.column_value (p_main_cursor, 1,  p_code_combination_id);
      dbms_sql.column_value (p_main_cursor, 2,  p_balancing_segment);
      dbms_sql.column_value (p_main_cursor, 3,  p_ytd_balance);
      dbms_sql.column_value (p_main_cursor, 4,  p_ptd_balance);
      dbms_sql.column_value (p_main_cursor, 5,  p_period_name);
     /*
      IF profile_country_code = 'CL' THEN
         IF NOT get_non_func_amt(p_set_of_books_id
                            , p_code_combination_id
                            , non_func_ytd
                            , non_func_ptd
                            , p_period_name) THEN
           RETURN FALSE;
         END IF;
      ELSE
         non_func_ytd := 0;
         non_func_ptd := 0;
      END IF;

      p_ytd_balance := p_ytd_balance - non_func_ytd;
      p_ptd_balance := p_ptd_balance - non_func_ptd;

      */

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_cursor_values;


    ------------------------------------------------------------
    -- Inserts in GL_INTERFACE the lines passed as parameters.--
    -- If the amount is 0 then do not insert any row.         --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION insert_gl_interface (p_set_of_books_id IN NUMBER
                                , p_code_combination_id IN NUMBER
                                , p_accounting_date IN DATE
                                , p_currency_code IN VARCHAR2
                                , p_amount        IN NUMBER
                                , p_group_id IN NUMBER
                                , p_user_je_category_name IN VARCHAR2
                                , p_user_je_source_name IN VARCHAR2)
      RETURN BOOLEAN IS

      insert_failed EXCEPTION;

    BEGIN
      ------------------------------------------------------------
      -- If there's nothing to adjust, then do nothing...       --
      ------------------------------------------------------------
      IF p_amount <> 0 THEN
        INSERT INTO gl_interface (status
                                , set_of_books_id
                                , accounting_date
                                , currency_code
                                , date_created
                                , created_by
                                , actual_flag
                                , user_je_category_name
                                , user_je_source_name
                                , entered_dr
                                , entered_cr
                                , reference1
                                , code_combination_id
                                , group_id)
        VALUES ('NEW'
              , p_set_of_books_id
              , p_accounting_date
              , p_currency_code
              , sysdate
              , fnd_global.user_id
              , 'A'
              , p_user_je_category_name
              , p_user_je_source_name
              , decode (sign (p_amount), -1, 0, p_amount)
              , decode (sign (p_amount), -1, p_amount * (-1), 0)
              , 'JL'
              , p_code_combination_id
              , p_group_id );

        IF SQL%NOTFOUND THEN
          RAISE insert_failed;
        END IF;

      END IF;

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END insert_gl_interface;


    ------------------------------------------------------------
    -- Gets the inflation adjustment gain and loss account    --
    -- for a particular balancing segment based on the REI    --
    -- template.                                              --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION get_infl_adj_gla (p_default_REI_ccid    IN NUMBER
                         , p_balancing_segment       IN VARCHAR2
                         , p_balancing_segment_value IN VARCHAR2
                         , p_new_REI_ccid            OUT NOCOPY NUMBER)
      RETURN BOOLEAN IS

      nsegs         NUMBER;
      new_REI_ccid  NUMBER;
      segments      fnd_flex_ext.segmentArray;

      account_error EXCEPTION;

    BEGIN

      ------------------------------------------------------------
      -- Get the segments values for the template account and   --
      -- the number of enabled segments.                        --
      ------------------------------------------------------------
      IF fnd_flex_ext.get_segments ('SQLGL'
                                  , 'GL#'
                                  , chart_of_accounts_id
                                  , p_default_REI_ccid
                                  , nsegs
                                  , segments) THEN

      ------------------------------------------------------------
      -- Change the template balancing segment for the new one. --
      ------------------------------------------------------------
        segments (balancing_segment_idx) := p_balancing_segment_value;

      ------------------------------------------------------------
      -- Get the new ccid.  If the account exists then returns  --
      -- the id, otherwise if dynamic insertion is allowed      --
      -- then creates a new account.                            --
      ------------------------------------------------------------
        IF NOT fnd_flex_ext.get_combination_id ('SQLGL'
                                              , 'GL#'
                                              , chart_of_accounts_id
                                              , sysdate
                                              , nsegs
                                              , segments
                                              , new_REI_ccid) THEN
          RAISE account_error;
        END IF;

      ELSE
          RAISE account_error;
      END IF;

      p_new_REI_ccid := new_REI_ccid;

      RETURN TRUE;

    EXCEPTION
      WHEN account_error THEN
        p_err_msg_name := 'JL_ZZ_GL_INFL_ADJ_GLA';
        p_err_msg_num  := 62019;
        p_err_msg_code := 'APP';
        RETURN FALSE;

      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_infl_adj_gla;


    ------------------------------------------------------------
    -- Compares to string and returns TRUE if they are equal  --
    -- and FALSE otherwise.                                   --
    ------------------------------------------------------------
    FUNCTION same_value (p_new_value      IN VARCHAR2
                       , p_original_value IN OUT NOCOPY VARCHAR2)
    RETURN BOOLEAN IS

    BEGIN
      IF p_original_value IS NULL THEN
        p_original_value := p_new_value;
      ELSIF p_original_value <> p_new_value THEN
        RETURN FALSE;
      END IF;

      RETURN TRUE;

    END same_value;


    ------------------------------------------------------------
    -- Returns the adjusted amount corresponding to those     --
    -- journal entries entered in this period but whose       --
    -- adjustment has to start in a different period          --
    -- ('Fecha Valor (FV)').                                  --
    ------------------------------------------------------------
    FUNCTION get_FV_adjustment (p_set_of_books_id     IN NUMBER
                              , p_price_index_id      IN NUMBER
                              , p_period_set_name     IN VARCHAR2
                              , p_code_combination_id IN NUMBER
                              , p_period_name         IN VARCHAR2
                              , p_adjustment_amount   IN OUT NOCOPY NUMBER
                              , p_period_fv_amount    IN OUT NOCOPY NUMBER)

      RETURN BOOLEAN IS

      period_name          VARCHAR2(15);
      profile_value        VARCHAR2(10);


      adj_rate_precision   NUMBER(3);

      adjustment_rate          NUMBER;
      adjustment_amount        NUMBER;
      FV_index_value           NUMBER;
      to_period_idx_value      NUMBER;

      INDEX_EQUAL_TO_ZERO  EXCEPTION;
      index_error          EXCEPTION;


      CURSOR FV_jes IS
        SELECT sum (nvl (accounted_dr, 0)) -
               sum (nvl (accounted_cr, 0)) FV_total
             , gps.period_name
          FROM gl_je_lines gjl
             , gl_je_headers gjh
             , gl_period_statuses gps
          WHERE gjh.status = 'P'
            AND gjh.ledger_id = p_set_of_books_id
            AND gjl.je_header_id = gjh.je_header_id
            AND gjl.code_combination_id = p_code_combination_id
            AND gjl.period_name = p_period_name
            AND gjh.actual_flag = 'A'
            AND gjh.currency_conversion_date is not null
            AND gjh.currency_conversion_date < gjl.effective_date
            AND gps.application_id = GL_APPS_ID
            AND nvl (gps.adjustment_period_flag, 'N') = 'N'
            AND gjh.currency_conversion_date
                BETWEEN gps.start_date AND gps.end_date
            AND gps.set_of_books_id = p_set_of_books_id
            AND gps.period_name <> p_period_name
            AND decode(profile_country_code,'CL',set_of_books_currency_code,gjh.currency_code) = gjh.currency_code
          GROUP BY gps.period_name;

    BEGIN
      adjustment_amount := 0;
      p_period_fv_amount := 0;

      period_name :=  p_adjust_to_period;

      IF NOT get_inflation_index_value (p_price_index_id
                                      , p_period_set_name
                                      , period_name
                                      , to_period_idx_value) THEN
        RAISE index_error;
      END IF;

      FOR FV_jes_rec IN FV_jes LOOP

        period_name := FV_jes_rec.period_name;

        IF NOT get_inflation_index_value (p_price_index_id
                                        , p_period_set_name
                                        , period_name
                                        , FV_index_value) THEN
          RAISE index_error;
        END IF;

        IF FV_index_value = 0 then
          RAISE INDEX_EQUAL_TO_ZERO;
        END IF;

        IF NOT get_adj_rate_precision(adj_rate_precision) then

        adjustment_rate := (to_period_idx_value / FV_index_value) - 1;

        ELSE

        adjustment_rate := round(((to_period_idx_value /
                              FV_index_value)- 1), adj_rate_precision);

        END IF;


        p_period_fv_amount := p_period_fv_amount + FV_jes_rec.FV_total;
        adjustment_amount := adjustment_amount +
                             FV_jes_rec.FV_total * adjustment_rate;

      END LOOP;

      p_adjustment_amount := adjustment_amount;

      RETURN TRUE;

    EXCEPTION
      WHEN INDEX_EQUAL_TO_ZERO THEN
        p_err_msg_name := 'JL_ZZ_GL_PRICE_INDEX_VALUE_NA';
        p_err_msg_num  := 62023;
        p_err_msg_code := 'APP';
        RETURN FALSE;

      WHEN index_error THEN
        RETURN FALSE;

      WHEN OTHERS THEN
        p_err_msg_name := substr (SQLERRM, 1, 100);
        p_err_msg_code := 'ORA';
        RETURN FALSE;

    END get_FV_adjustment;

    ------------------------------------------------------------
    -- Inserts into JL_ZZ_GL_AXI_TMP data that the infl. adj. --
    -- report will read later.                                --
    --                                                        --
    ------------------------------------------------------------
    FUNCTION insert_axi_tmp (p_code_combination_id  IN NUMBER
                           , p_inflation_adj_run_id IN NUMBER
                           , p_group_id             IN NUMBER
                           , p_from_period          IN VARCHAR2
                           , p_to_period            IN VARCHAR2
                           , p_ytd_balance          IN NUMBER
                           , p_ptd_balance          IN NUMBER
                           , p_acct_total_adj_amount IN NUMBER
                           , p_fv_flag              IN VARCHAR2)
      RETURN BOOLEAN IS

    BEGIN
      INSERT INTO jl_zz_gl_axi_tmp (code_combination_id
                                  , axi_run_id
                                  , group_id
                                  , period_from
                                  , period_to
                                  , ytd_balance
                                  , ptd_balance
                                  , adjustment_amount
                                  , fv_flag)
      VALUES (p_code_combination_id
            , p_inflation_adj_run_id
            , p_group_id
            , p_from_period
            , p_to_period
            , p_ytd_balance
            , p_ptd_balance
            , p_acct_total_adj_amount
            , p_fv_flag);

       RETURN TRUE;

     EXCEPTION
       WHEN OTHERS THEN
         p_err_msg_name := substr (SQLERRM, 1, 100);
         p_err_msg_code := 'ORA';
         RETURN FALSE;

     END insert_axi_tmp;


  ------------------------------------------------------------
  --                                                        --
  -- Inflation Adjustment Process.  Main program.           --
  --                                                        --
  ------------------------------------------------------------

  BEGIN
    ------------------------------------------------------------
    -- Get information related to the parameters' set of books--
    ------------------------------------------------------------
    IF NOT get_set_of_books_info (p_set_of_books_id
                                , set_of_books_name
                                , set_of_books_currency_code
                                , chart_of_accounts_id
                                , balancing_segment
                                , period_set_name
                                , currency_precision
                                , num_enabled_segments) THEN
      RAISE program_abort;
    END IF;

    ------------------------------------------------------------
    -- Get group id for the JEs to be created by this process.--
    ------------------------------------------------------------
    IF NOT init_process (p_group_id
                       , p_set_of_books_id
                       , infl_adjust_gain_loss_ccid
                       , p_inflation_adj_run_id
                       , p_adjust_to_period
                       , accounting_date
                       , user_je_category_name
                       , user_je_source_name) THEN

      RAISE program_abort;
    END IF;

    ------------------------------------------------------------
    -- Open accounts cursor using dynamic SQL statements.     --
    ------------------------------------------------------------
    main_cursor := dbms_sql.open_cursor;

    ------------------------------------------------------------
    -- Creates the accounts cursor ordering the rows by       --
    -- balancing segment (i.e. the order for fetching the     --
    -- rows is decided in runtime)                            --
    ------------------------------------------------------------
    IF NOT build_main_cursor (p_set_of_books_id
                            , period_set_name
                            , p_adjust_from_period
                            , p_adjust_to_period
                            , balancing_segment
                            , num_enabled_segments
                            , p_inflation_adj_run_id
                            , main_cursor) THEN

      RAISE program_abort;
    END IF;

    number_records := dbms_sql.execute (main_cursor);
    ------------------------------------------------------------
    -- Set Flag to Yes before While loop.     --
    ------------------------------------------------------------

    zero_main_records  := 'YES';

    consider_YTD_amount := 'Y';

    WHILE dbms_sql.fetch_rows (main_cursor) > 0 LOOP

      zero_main_records  := 'NO';
      ------------------------------------------------------------
      -- Read the values from the cursor's columns              --
      ------------------------------------------------------------
      IF NOT get_cursor_values (main_cursor
                              , c_code_combination_id
                              , c_balancing_segment
                              , c_ytd_balance
                              , c_ptd_balance
                              , c_period_name) THEN

        RAISE program_abort;
      END IF;

      ------------------------------------------------------------
      -- If the account changes then it is required to insert a --
      -- journal entry line for this account.                   --
      ------------------------------------------------------------
      IF NOT same_value (to_char (c_code_combination_id)
                       , previous_code_combination_id) THEN

      ------------------------------------------------------------
      -- Rounding before inserting in GL_INTERFACE and before   --
      -- adding to the balancing segment total avoids unbalanced--
      -- journal entries.                                       --
      ------------------------------------------------------------
        acct_total_adj_amount := round ((acct_total_adj_amount +
                                         acct_begin_YTD_adj_amount)
                                      , currency_precision);

        IF NOT insert_gl_interface (p_set_of_books_id
                                  , previous_code_combination_id
                                  , accounting_date
                                  , set_of_books_currency_code
                                  , acct_total_adj_amount
                                  , p_group_id
                                  , user_je_category_name
                                  , user_je_source_name) THEN

          RAISE program_abort;
        END IF;

      ------------------------------------------------------------
      -- Record the end period YTD and PTD amount with total    --
      -- adjustment till the end period.The Infl.Adj.Report will--
      -- read this data.                                        --
      ------------------------------------------------------------

      IF NOT insert_axi_tmp (prevrec.r_ccid
                           , p_inflation_adj_run_id
                           , p_group_id
                           , prevrec.r_period_name
                           , prevrec.r_period_name
                           , prevrec.r_ytd_balance
                           , prevrec.r_ptd_balance
                           , acct_total_adj_amount
                           , fv_flag) THEN

        RAISE program_abort;
      END IF;

        ------------------------------------------------------------
        -- Add the current account adjusted amount to the REI     --
        -- total.                                                 --
        ------------------------------------------------------------
        balancing_segment_tot_amount := balancing_segment_tot_amount +
                                        acct_total_adj_amount * (-1);

        ------------------------------------------------------------
        -- Reset account totals.                                  --
        ------------------------------------------------------------
        acct_period_adj_amount := 0;
        acct_total_adj_amount := 0;

        previous_code_combination_id := c_code_combination_id;
        fv_flag := 'N';


        consider_YTD_amount := 'Y';
        acct_begin_YTD_adj_amount := 0;

      END IF;

      ------------------------------------------------------------
      -- If the balancing segment changes then the inflation    --
      -- adjustment gain/loss account should also change.       --
      ------------------------------------------------------------
      IF NOT same_value (c_balancing_segment
                        ,previous_balancing_segment) THEN

        ------------------------------------------------------------
        -- Complete the journal entry.                            --
        ------------------------------------------------------------
        IF NOT get_infl_adj_gla (infl_adjust_gain_loss_ccid
                               , balancing_segment
                               , previous_balancing_segment
                               , infl_adj_gla) THEN

          RAISE program_abort;
        END IF;

        IF NOT insert_gl_interface (p_set_of_books_id
                           , infl_adj_gla
                           , accounting_date
                           , set_of_books_currency_code
                           , balancing_segment_tot_amount
                           , p_group_id
                           , user_je_category_name
                           , user_je_source_name) THEN

          RAISE program_abort;
        END IF;

        ------------------------------------------------------------
        -- Reset balancing segment totals.                        --
        ------------------------------------------------------------
        balancing_segment_tot_amount := 0;
        previous_balancing_segment := c_balancing_segment;

      END IF;

        ------------------------------------------------------------
        -- Calculate inflation adj. amt.on Ytd balance of begining--
        -- period.  --
        ------------------------------------------------------------
      IF consider_YTD_amount = 'Y' THEN
             IF NOT get_previous_period( period_set_name
                                        ,p_adjust_from_period
                                        ,YTD_prev_period_name) THEN

                RAISE program_abort;

             END IF;
             IF NOT get_adjustment_rate (p_infl_adj_index_id
                                , p_set_of_books_id
                                , period_set_name
                                , YTD_prev_period_name
                                , infl_adjustment_rate ) THEN
                RAISE program_abort;

            END IF;

            acct_begin_YTD_adj_amount := c_ytd_balance
                                        * infl_adjustment_rate;

      END IF;


       consider_YTD_amount := 'N';


      ------------------------------------------------------------
      -- Compute FV adjusted amount for those JE entered in the --
      -- current account period.                                --
      ------------------------------------------------------------
      IF NOT get_FV_adjustment (p_set_of_books_id
                              , p_infl_adj_index_id
                              , period_set_name
                              , c_code_combination_id
                              , c_period_name
                              , fv_adjustment_amount
                              , fv_period_amount) THEN

        RAISE program_abort;
      END IF;

      IF fv_adjustment_amount <> 0 THEN
        fv_flag := 'Y';
      END IF;

      ------------------------------------------------------------
      -- Get the rate to perform the adjustment.                --
      ------------------------------------------------------------
      IF NOT get_adjustment_rate (p_infl_adj_index_id
                                , p_set_of_books_id
                                , period_set_name
                                , c_period_name
                                , infl_adjustment_rate ) THEN
        RAISE program_abort;

      END IF;

      ------------------------------------------------------------
      -- Compute the adjustment amount.                         --
      ------------------------------------------------------------
      acct_period_adj_amount := ((c_ptd_balance - fv_period_amount) *
                              infl_adjustment_rate)
                              + fv_adjustment_amount;
      acct_total_adj_amount  := acct_total_adj_amount
                                + acct_period_adj_amount;

      fv_adjustment_amount :=0;
      fv_period_amount :=0;
    ------------------------------------------------------------
    -- Store previous 'Main Cursor' values  in 'prevrec' record-
    ------------------------------------------------------------

      prevrec.r_ccid :=c_code_combination_id;
      prevrec.r_bal_segment :=c_balancing_segment;
      prevrec.r_ytd_balance :=c_ytd_balance;
      prevrec.r_ptd_balance :=c_ptd_balance;
      prevrec.r_period_name :=c_period_name;

    END LOOP;

    ------------------------------------------------------------
    -- If no record to adjust then return from procedure.     --
    ------------------------------------------------------------

    IF zero_main_records  = 'YES' THEN
       dbms_sql.close_cursor (main_cursor);
       COMMIT;
       RETURN 0;
    END IF;


    ------------------------------------------------------------
    -- Insert the last JE's last account.                     --
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Rounding before inserting in GL_INTERFACE and before   --
    -- adding to the balancing segment total avoids unbalanced--
    -- journal entries.                                       --
    ------------------------------------------------------------
    acct_total_adj_amount := round ((acct_total_adj_amount
                                   + acct_begin_YTD_adj_amount)
                                   , currency_precision);

    IF NOT insert_gl_interface (p_set_of_books_id
                       , previous_code_combination_id
                       , accounting_date
                       , set_of_books_currency_code
                       , acct_total_adj_amount
                       , p_group_id
                       , user_je_category_name
                       , user_je_source_name) THEN

      RAISE program_abort;
    END IF;

    IF NOT insert_axi_tmp (prevrec.r_ccid
                           , p_inflation_adj_run_id
                           , p_group_id
                           , prevrec.r_period_name
                           , prevrec.r_period_name
                           , prevrec.r_ytd_balance
                           , prevrec.r_ptd_balance
                           , acct_total_adj_amount
                           , fv_flag) THEN

        RAISE program_abort;
      END IF;


    ------------------------------------------------------------
    -- Add the current account adjusted amount to the REI     --
    -- total.                                                 --
    ------------------------------------------------------------
    balancing_segment_tot_amount := balancing_segment_tot_amount +
                                    acct_total_adj_amount * (-1);

    ------------------------------------------------------------
    -- Insert the REI account for the last balancing segment  --
    ------------------------------------------------------------
    IF NOT get_infl_adj_gla (infl_adjust_gain_loss_ccid
                           , balancing_segment
                           , previous_balancing_segment
                           , infl_adj_gla) THEN

      RAISE program_abort;

    END IF;

    IF NOT insert_gl_interface (p_set_of_books_id
                       , infl_adj_gla
                       , accounting_date
                       , set_of_books_currency_code
                       , balancing_segment_tot_amount
                       , p_group_id
                       , user_je_category_name
                       , user_je_source_name) THEN

      RAISE program_abort;
    END IF;

    dbms_sql.close_cursor (main_cursor);

    COMMIT;

    RETURN 0;


EXCEPTION
  WHEN program_abort THEN
      ROLLBACK;
      RETURN 1;

  END inflation_adjustment;

END jl_zz_gl_infl_adj_pkg;

/
