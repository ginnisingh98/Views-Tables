--------------------------------------------------------
--  DDL for Package Body FA_RX_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_GROUP" AS
/* $Header: farxgab.pls 120.15.12010000.6 2010/03/31 09:31:55 gigupta ship $ */

-- global variables
g_print_debug boolean := fa_cache_pkg.fa_print_debug;


PROCEDURE get_group_asset_info (
  p_book_type_code          IN  VARCHAR2,
  p_sob_id                  IN  VARCHAR2 default NULL,   -- MRC: Set of books id
  p_start_fiscal_year       IN  VARCHAR2,
  p_end_fiscal_year         IN  VARCHAR2,
  p_major_category_low      IN  VARCHAR2,
  p_major_category_high     IN  VARCHAR2,
  p_minor_category_low      IN  VARCHAR2,
  p_minor_category_high     IN  VARCHAR2,
  p_category_segment_name   IN  VARCHAR2,
  p_category_segment_low    IN  VARCHAR2,
  p_category_segment_high   IN  VARCHAR2,
  p_asset_number_low        IN  VARCHAR2,
  p_asset_number_high       IN  VARCHAR2,
  p_drill_down              IN  VARCHAR2,
  p_request_id              IN  NUMBER,
  p_user_id                 IN  NUMBER,
  x_retcode                 OUT NOCOPY NUMBER,
  x_errbuf                  OUT NOCOPY VARCHAR2)
IS
  l_info_rec                    info_rec_type;

  l_application_id              fa_system_controls.fa_application_id%TYPE;
  l_category_flex_structure     fa_system_controls.category_flex_structure%TYPE;

  l_param_where_stmt            VARCHAR2(1000);
  l_group_sql_stmt              VARCHAR2(5000);
  l_sql_stmt                    VARCHAR2(5000);

  l_group_adjustment_amount     NUMBER;
  l_second_half_add_rec_cost    NUMBER;
  l_second_half_grp_adjustment  NUMBER;
  l_second_half_mem_adjustment  NUMBER;
  l_group_reclass_in            NUMBER;
  l_group_reclass_cost_in_out   NUMBER; /*Bug# 9375920 */
  l_group_reclass_rsv_in_out    NUMBER; /*Bug# 9375920 */
  l_group_reclass_out           NUMBER;
  l_all_reduced_deprn_amount    NUMBER;
  l_non_cip_num                 NUMBER;

  l_message                     VARCHAR2(30);

   -- MRC
   h_sob_id                     NUMBER;
   h_mrcsobtype                 VARCHAR2(1);
   -- End MRC

  TYPE group_csrtype IS REF CURSOR;
  l_group_csr        group_csrtype;
  l_group_rec        group_rec_type;
  l_member_rec       group_rec_type;

  TYPE amount_csrtype IS REF CURSOR;
  l_amount_csr       amount_csrtype;

  main_err           EXCEPTION;

  CURSOR  ret_adj_cur IS
  SELECT  NVL(SUM(NVL(fad.adjustment_amount,0)),0) adj_amt,
          fad.adjustment_type adj_type
    FROM  fa_adjustments fad,
          fa_book_controls bc,
          fa_fiscal_year fy,
          fa_transaction_headers thg
   WHERE  fad.asset_id = l_group_rec.asset_id
     AND  fad.book_type_code =  p_book_type_code
     AND  fad.source_type_code = 'RETIREMENT'
     AND  fad.adjustment_type IN ('PROCEEDS CLR','REMOVALCOST CLR')
     AND  fad.transaction_header_id = thg.transaction_header_id
     AND  thg.member_transaction_header_id IS NULL
     AND  thg.book_type_code = bc.book_type_code
     AND  thg.transaction_date_entered  BETWEEN fy.start_date and fy.end_date
     AND  fy.fiscal_year = l_info_rec.fiscal_year
     AND  fy.fiscal_year_name = bc.fiscal_year_name
GROUP BY  fad.adjustment_type;

-- MRC
  CURSOR  mc_ret_adj_cur IS
  SELECT  NVL(SUM(NVL(fad.adjustment_amount,0)),0) adj_amt,
          fad.adjustment_type adj_type
    FROM  fa_mc_adjustments fad,
          fa_book_controls bc,
          fa_fiscal_year fy,
          fa_transaction_headers thg
   WHERE  fad.asset_id = l_group_rec.asset_id
     AND  fad.book_type_code =  p_book_type_code
     AND  fad.source_type_code = 'RETIREMENT'
     AND  fad.adjustment_type IN ('PROCEEDS CLR','REMOVALCOST CLR')
     AND  fad.transaction_header_id = thg.transaction_header_id
     AND  thg.member_transaction_header_id IS NULL
     AND  thg.book_type_code = bc.book_type_code
     AND  thg.transaction_date_entered  BETWEEN fy.start_date and fy.end_date
     AND  fy.fiscal_year = l_info_rec.fiscal_year
     AND  fy.fiscal_year_name = bc.fiscal_year_name
     AND  fad.set_of_books_id = l_info_rec.set_of_books_id
GROUP BY  fad.adjustment_type;
-- End MRC

   l_log_level_rec     FA_API_TYPES.log_level_rec_type;

BEGIN
  IF g_print_debug THEN
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'farx_ga.get_group_asset_info()+');
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'book: ' || p_book_type_code);
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'fiscal year from: ' || p_start_fiscal_year);
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'fiscal year to: ' || p_end_fiscal_year);
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'user_id: ' || p_user_id);
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'request_id: ' || p_request_id);
  END IF;
  l_message := 'get_group_asset_info start';


  ----------------------------------------------
  -- Initialization
  ----------------------------------------------
  l_info_rec.book_type_code := p_book_type_code;
  l_info_rec.request_id := p_request_id;
  l_info_rec.user_id := p_user_id;

  h_sob_id := to_number(p_sob_id);  -- MRC

  -- MRC
  if h_sob_id is not null then
    begin
       select 'P'
       into H_MRCSOBTYPE
       from fa_book_controls
       where book_type_code = p_book_type_code
       and set_of_books_id = h_sob_id;
    exception
       when no_data_found then
          H_MRCSOBTYPE := 'R';
    end;
  else
    H_MRCSOBTYPE := 'P';
  end if;
  -- End MRC

  -- Get organization name, functional currency and flex structure
    SELECT sc.fa_application_id,
         sc.category_flex_structure,
         sob.name,
         sob.currency_code,
         decode(H_MRCSOBTYPE, 'P', bc.set_of_books_id, h_sob_id),  -- MRC
         bc.deprn_calendar
    INTO l_application_id,
         l_category_flex_structure,
         l_info_rec.organization_name,
         l_info_rec.functional_currency_code,
         l_info_rec.set_of_books_id,
         l_info_rec.deprn_calendar
    FROM fa_system_controls sc,
         fa_book_controls bc,
         gl_sets_of_books sob,
         fnd_currencies cur
   WHERE bc.book_type_code = p_book_type_code
     AND sob.set_of_books_id = decode(H_MRCSOBTYPE, 'P', bc.set_of_books_id, h_sob_id)  -- MRC
     AND sob.currency_code = cur.currency_code;

  IF g_print_debug THEN
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'set_of_books_id: ' || l_info_rec.set_of_books_id);
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'deprn_calendar: ' || l_info_rec.deprn_calendar);
  END IF;
  l_message := 'initialization end';


  -- Create select and where clauses for categories paramters
  get_category_sql(l_application_id,
                   l_category_flex_structure,
                   'BASED_CATEGORY',
                   p_major_category_low,
                   p_major_category_high,
                   l_info_rec.major_cat_select_stmt,
                   l_param_where_stmt);

  get_category_sql(l_application_id,
                   l_category_flex_structure,
                   'MINOR_CATEGORY',
                   p_minor_category_low,
                   p_minor_category_high,
                   l_info_rec.minor_cat_select_stmt,
                   l_sql_stmt);
  l_param_where_stmt := l_param_where_stmt || l_sql_stmt;

  get_category_sql(l_application_id,
                   l_category_flex_structure,
                   p_category_segment_name,
                   p_category_segment_low,
                   p_category_segment_high,
                   l_info_rec.other_cat_select_stmt,
                   l_sql_stmt);
  l_param_where_stmt := l_param_where_stmt || l_sql_stmt;


  -- Add group asset number where clause
  IF p_asset_number_low = p_asset_number_high THEN
    l_param_where_stmt := l_param_where_stmt || ' AND ad.asset_number = '''
                          || p_asset_number_low || '''';

  ELSIF p_asset_number_low IS NOT NULL
    AND p_asset_number_high IS NOT NULL THEN
    l_param_where_stmt := l_param_where_stmt || ' AND ad.asset_number
                          BETWEEN ''' ||
                          p_asset_number_low || '''' || ' AND  ''' ||
                          p_asset_number_high || '''';

  ELSIF p_asset_number_low IS NOT NULL THEN
    l_param_where_stmt := l_param_where_stmt || ' AND ad.asset_number >= '''
                          || p_asset_number_low || '''';

  ELSIF p_asset_number_high IS NOT NULL THEN
    l_param_where_stmt := l_param_where_stmt || ' AND ad.asset_number <= '''
                          || p_asset_number_high || '''';
  END IF;

  IF g_print_debug THEN
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'l_param_where_stmt:' || l_param_where_stmt);
  END IF;
  l_message := 'category sql end';


  IF NOT fa_cache_pkg.fazcbc(p_book_type_code) THEN
    raise main_err;
  END IF;


  -----------------------------------------------------
  -- Main logic
  --   Fiscal Year Loop -> Group Loop -> Member Loop
  -----------------------------------------------------

  l_info_rec.fiscal_year := p_start_fiscal_year;

  LOOP
    EXIT WHEN l_info_rec.fiscal_year > p_end_fiscal_year;


    -- Get first and last depreciated period counter of the fiscal year
    -- Bug #2846317 - can report open period if it's depreciated
      SELECT MIN(period_counter),
             MAX(period_counter)
        INTO l_info_rec.min_period_counter,
             l_info_rec.max_period_counter
        FROM fa_deprn_periods
       WHERE book_type_code = p_book_type_code
         AND fiscal_year = l_info_rec.fiscal_year
         AND NVL(deprn_run, 'N') = 'Y';

    -- Exit if no period is depreciated in fiscal year
    EXIT WHEN l_info_rec.max_period_counter IS NULL;

    l_message := 'fiscal year loop (1)';


    --------------------------------------------------------------
    -- <Group Query Loop>
    -- Query group assets matching to the report parameter.
    --------------------------------------------------------------

    -- Create main query for group
    l_group_sql_stmt :=
      'SELECT
        ad.asset_number,
        ad.description,
        ad.asset_type, '
        || l_info_rec.major_cat_select_stmt || ','
        || l_info_rec.minor_cat_select_stmt || ','
        || l_info_rec.other_cat_select_stmt || ',
        bk.date_placed_in_service,
        bk.deprn_method_code,
        br.rule_name,
        bk.tracking_method,
        bk.adjusted_rate,
        NULL,
        NVL(bk.cost, 0) + NVL(bk.cip_cost, 0),
        NVL(bk.salvage_value, 0),
        NVL(bk.adjusted_recoverable_cost, 0),
        NVL(prev.cost, 0) + NVL(prev.cip_cost, 0) - NVL(prev.deprn_reserve, 0),
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        0,
        NVL(bk.terminal_gain_loss_amount, 0),
        NULL, NULL,
        NVL(ds.adjusted_cost, 0),
        NULL, NULL,
        NVL(ds.ytd_deprn, 0),
        NVL(ds.deprn_reserve, 0),
        NULL, NULL,
        ad.asset_id,
        NULL,
        DECODE(bk.life_in_months, NULL, NULL,
          TO_CHAR(FLOOR(bk.life_in_months / 12)) || ''.'' ||
          TO_CHAR(MOD(bk.life_in_months, 12))),
        met.deprn_basis_rule,
        met.exclude_salvage_value_flag,
        NVL(bk.reduction_rate, 0),
        bk.depreciation_option,
        bk.recognize_gain_loss,
        bk.exclude_proceeds_from_basis,
        NULL, NULL,
        ds.period_counter ';

    -- Add from clause
    get_from_sql_stmt(l_info_rec, NULL, h_mrcsobtype, l_sql_stmt); -- MRC
    l_group_sql_stmt := l_group_sql_stmt || l_sql_stmt;

    -- Add where clause
    get_where_sql_stmt(l_info_rec, NULL, h_mrcsobtype, l_sql_stmt); -- MRC
    l_group_sql_stmt := l_group_sql_stmt || l_sql_stmt || l_param_where_stmt;

    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_group_asset_info: '
                           || 'l_group_sql_stmt:' || l_group_sql_stmt);
    END IF;
    l_message := 'fiscal year loop (2)';



    -- Group query loop start
    OPEN l_group_csr FOR l_group_sql_stmt;
    LOOP
      FETCH l_group_csr INTO l_group_rec;
      EXIT WHEN l_group_csr%NOTFOUND;

      l_message := 'group loop (1)';

      IF g_print_debug THEN
        fa_rx_util_pkg.debug('get_group_asset_info: '
                          || 'group_asset: ' || l_group_rec.asset_number);
      END IF;

      ----------------------------------------------------------
      -- Query add/adj/retirement amount in the FY
      ----------------------------------------------------------

      -- Query fa_retirements
      -- (retiring member asset is allowed only in current period)
      if(H_MRCSOBTYPE <> 'R') then  -- MRC
        SELECT NVL(SUM(ret.proceeds_of_sale), 0),
               NVL(SUM(ret.cost_of_removal), 0),
               NVL(SUM(ret.nbv_retired), 0),
               NVL(SUM(ret.cost_retired), 0),
               NVL(SUM(ret.reserve_retired), 0),
               NVL(SUM(ret.recapture_amount), 0)
          INTO l_group_rec.proceeds_of_sale,
               l_group_rec.cost_of_removal,
               l_group_rec.net_proceeds,
               l_group_rec.cost_retired,
               l_group_rec.reserve_retired,
               l_group_rec.recapture_amount
          FROM fa_retirements ret,
               fa_book_controls bc,
               fa_fiscal_year fy,
               fa_transaction_headers thg,
               fa_transaction_headers thm
         WHERE bc.book_type_code = p_book_type_code
           AND fy.fiscal_year = l_info_rec.fiscal_year
           AND fy.fiscal_year_name = bc.fiscal_year_name
           AND thm.book_type_code = bc.book_type_code
           AND thm.transaction_date_entered
               BETWEEN fy.start_date and fy.end_date
           AND thg.book_type_code = bc.book_type_code
           AND thg.asset_id = l_group_rec.asset_id
           AND thg.member_transaction_header_id = thm.transaction_header_id
           AND ret.transaction_header_id_in = thm.transaction_header_id
           AND ret.status <> 'DELETED';
      -- MRC
      else
        SELECT NVL(SUM(ret.proceeds_of_sale), 0),
               NVL(SUM(ret.cost_of_removal), 0),
               NVL(SUM(ret.nbv_retired), 0),
               NVL(SUM(ret.cost_retired), 0),
               NVL(SUM(ret.reserve_retired), 0),
               NVL(SUM(ret.recapture_amount), 0)
          INTO l_group_rec.proceeds_of_sale,
               l_group_rec.cost_of_removal,
               l_group_rec.net_proceeds,
               l_group_rec.cost_retired,
               l_group_rec.reserve_retired,
               l_group_rec.recapture_amount
          FROM fa_mc_retirements ret,
               fa_book_controls bc,
               fa_fiscal_year fy,
               fa_transaction_headers thg,
               fa_transaction_headers thm
         WHERE bc.book_type_code = p_book_type_code
           AND fy.fiscal_year = l_info_rec.fiscal_year
           AND fy.fiscal_year_name = bc.fiscal_year_name
           AND thm.book_type_code = bc.book_type_code
           AND thm.transaction_date_entered
               BETWEEN fy.start_date and fy.end_date
           AND thg.book_type_code = bc.book_type_code
           AND thg.asset_id = l_group_rec.asset_id
           AND thg.member_transaction_header_id = thm.transaction_header_id
           AND ret.transaction_header_id_in = thm.transaction_header_id
           AND ret.status <> 'DELETED'
           AND ret.set_of_books_id = l_info_rec.set_of_books_id;
      end if;
      -- End MRC

      if(H_MRCSOBTYPE <> 'R') then  -- MRC
         FOR rec_ret_adj IN ret_adj_cur
         LOOP
            IF rec_ret_adj.adj_type = 'PROCEEDS CLR' THEN
                 l_group_rec.proceeds_of_sale := l_group_rec.proceeds_of_sale + rec_ret_adj.adj_amt;
            ELSE
                 l_group_rec.cost_of_removal  := l_group_rec.cost_of_removal  + rec_ret_adj.adj_amt;
            END IF;

         END LOOP;

      -- MRC
      else
         FOR mc_rec_ret_adj IN mc_ret_adj_cur
         LOOP
            IF mc_rec_ret_adj.adj_type = 'PROCEEDS CLR' THEN
                 l_group_rec.proceeds_of_sale := l_group_rec.proceeds_of_sale + mc_rec_ret_adj.adj_amt;
            ELSE
                 l_group_rec.cost_of_removal  := l_group_rec.cost_of_removal  + mc_rec_ret_adj.adj_amt;
            END IF;

         END LOOP;
      end if;
      -- End MRC


      l_message := 'group loop (2)';

      -- Get group level adjustments amount
      --   Query transactions that occurred during the fiscal year,
      --   includeing back dated transactions.
      --   But exclude transanctions that happened during the
      --   non-depreciated period, even if it's back dated one.

      if(H_MRCSOBTYPE <> 'R') then  -- MRC
         SELECT NVL(SUM(DECODE(adj.debit_credit_flag,
                               'DR', adj.adjustment_amount,
                               'CR', -adj.adjustment_amount, 0)), 0),
                NVL(SUM(DECODE(GREATEST(thg.transaction_date_entered,
                                        fy.mid_year_date),
                               thg.transaction_date_entered,
                               DECODE(adj.debit_credit_flag,
                                      'DR', adj.adjustment_amount,
                                      'CR', -adj.adjustment_amount, 0),
                               0)), 0)
           INTO l_group_adjustment_amount,
                l_second_half_grp_adjustment
           FROM fa_adjustments adj,
                fa_book_controls bc,
                fa_fiscal_year fy,
                fa_transaction_headers thg
          WHERE thg.asset_id = l_group_rec.asset_id
            AND thg.book_type_code = p_book_type_code
            AND thg.member_transaction_header_id IS NULL
            AND thg.transaction_header_id = adj.transaction_header_id
            AND adj.period_counter_created
                BETWEEN l_info_rec.min_period_counter
                    and l_info_rec.max_period_counter
            AND adj.adjustment_type = 'COST'
            AND fy.fiscal_year = l_info_rec.fiscal_year
            AND fy.fiscal_year_name = bc.fiscal_year_name
            AND bc.book_type_code = p_book_type_code;
      -- MRC
      else
         SELECT NVL(SUM(DECODE(adj.debit_credit_flag,
                               'DR', adj.adjustment_amount,
                               'CR', -adj.adjustment_amount, 0)), 0),
                NVL(SUM(DECODE(GREATEST(thg.transaction_date_entered,
                                        fy.mid_year_date),
                               thg.transaction_date_entered,
                               DECODE(adj.debit_credit_flag,
                                      'DR', adj.adjustment_amount,
                                      'CR', -adj.adjustment_amount, 0),
                               0)), 0)
           INTO l_group_adjustment_amount,
                l_second_half_grp_adjustment
           FROM fa_mc_adjustments adj,
                fa_book_controls bc,
                fa_fiscal_year fy,
                fa_transaction_headers thg
          WHERE thg.asset_id = l_group_rec.asset_id
            AND thg.book_type_code = p_book_type_code
            AND thg.member_transaction_header_id IS NULL
            AND thg.transaction_header_id = adj.transaction_header_id
            AND adj.period_counter_created
                BETWEEN l_info_rec.min_period_counter
                    and l_info_rec.max_period_counter
            AND adj.adjustment_type = 'COST'
            AND fy.fiscal_year = l_info_rec.fiscal_year
            AND fy.fiscal_year_name = bc.fiscal_year_name
            AND bc.book_type_code = p_book_type_code
            AND adj.set_of_books_id  = l_info_rec.set_of_books_id;
      end if;
      -- End MRC

      l_message := 'group loop (3)';


      -- Get member level addition, adjustment and retirement amount
      get_trx_amount_sql(l_group_rec, l_info_rec, NULL, h_mrcsobtype, l_sql_stmt);  -- MRC

       OPEN l_amount_csr FOR l_sql_stmt;
      FETCH l_amount_csr
       INTO l_second_half_add_rec_cost,
            l_second_half_mem_adjustment,
            l_group_rec.second_half_addition,
            l_group_rec.addition_amount,
            l_group_rec.adjustment_amount;
      CLOSE l_amount_csr;

      l_message := 'group loop (4)';


      -- Get group reclass amount
      if(H_MRCSOBTYPE <> 'R') then  -- MRC
        /*Bug#9375920 Modified the cursor to fetch change in cost because of member reclass in/out */
        SELECT NVL(SUM(bk.cost - bk_old.cost),0)
          INTO l_group_reclass_cost_in_out
          FROM fa_books bk,
               fa_books bk_old,
               fa_transaction_headers fth,
               fa_book_controls bc,
               fa_deprn_periods dp
         WHERE bk.transaction_header_id_in = fth.transaction_header_id
           AND bk_old.transaction_header_id_out = fth.transaction_header_id
           AND fth.ASSET_ID = l_group_rec.asset_id
           AND fth.TRANSACTION_KEY = 'GC'
           AND bc.book_type_code = p_book_type_code
           AND fth.book_type_code = p_book_type_code
           AND bk.book_type_code = p_book_type_code
           AND bk_old.book_type_code = p_book_type_code
           AND bk.asset_id = fth.ASSET_ID
           AND bk_old.asset_id = fth.ASSET_ID
           AND dp.fiscal_year = l_info_rec.fiscal_year
           AND dp.book_type_code = p_book_type_code
           AND fth.date_effective BETWEEN dp.period_open_date
                                      AND nvl(dp.period_close_date,sysdate);
        /*Bug#9375920- Added to fetch change in reserve because of memebr reclass in/out */
        SELECT NVL(SUM(DECODE(adj.adjustment_type || '-' || adj.debit_credit_flag,
                              'RESERVE-CR', adj.adjustment_amount,
                              'RESERVE-DR', -adj.adjustment_amount,0)), 0) reserve
          INTO l_group_reclass_rsv_in_out
          FROM fa_adjustments adj,
               fa_transaction_headers thg
         WHERE adj.asset_id = l_group_rec.asset_id
           AND adj.book_type_code = p_book_type_code
           AND thg.transaction_header_id = adj.transaction_header_id
           AND thg.asset_id = l_group_rec.asset_id
           AND thg.book_type_code = p_book_type_code
           AND adj.period_counter_created BETWEEN l_info_rec.min_period_counter
                                              AND l_info_rec.max_period_counter
           AND adj.source_type_code = 'ADJUSTMENT'
           AND thg.transaction_key = 'GC';
         -- MRC
      else
        SELECT SUM(bk.cost - bk_old.cost)
          INTO l_group_reclass_cost_in_out
          FROM fa_mc_books bk,
               fa_mc_books bk_old,
               fa_transaction_headers fth,
               fa_mc_book_controls bc,
               fa_book_controls bc1,
               fa_mc_deprn_periods dp
         WHERE bk.transaction_header_id_in = fth.transaction_header_id
           AND bk_old.transaction_header_id_out = fth.transaction_header_id
           AND fth.ASSET_ID = l_group_rec.asset_id
           AND fth.TRANSACTION_KEY = 'GC'
           AND bc1.book_type_code = p_book_type_code
           AND bc.book_type_code = bc1.book_type_code
           AND fth.book_type_code = p_book_type_code
           AND bk.book_type_code = p_book_type_code
           AND bk_old.book_type_code = p_book_type_code
           AND bk.asset_id = fth.ASSET_ID
           AND bk_old.asset_id = fth.ASSET_ID
           AND bk.set_of_books_id = l_info_rec.set_of_books_id
           AND bk_old.set_of_books_id = l_info_rec.set_of_books_id
           AND bc.set_of_books_id = l_info_rec.set_of_books_id
           AND dp.fiscal_year = l_info_rec.fiscal_year
           AND dp.book_type_code = p_book_type_code
           AND dp.set_of_books_id = l_info_rec.set_of_books_id
           AND fth.date_effective BETWEEN dp.period_open_date
                                      AND nvl(dp.period_close_date,sysdate);

        SELECT NVL(SUM(DECODE(adj.adjustment_type || '-' || adj.debit_credit_flag,
                              'RESERVE-CR', adj.adjustment_amount,
                              'RESERVE-DR', -adj.adjustment_amount,0)), 0) reserve
          INTO l_group_reclass_rsv_in_out
          FROM fa_mc_adjustments adj,
               fa_transaction_headers thg
         WHERE adj.asset_id = l_group_rec.asset_id
           AND adj.book_type_code = p_book_type_code
           AND thg.transaction_header_id = adj.transaction_header_id
           AND thg.asset_id = l_group_rec.asset_id
           AND thg.book_type_code = p_book_type_code
           AND adj.period_counter_created BETWEEN l_info_rec.min_period_counter
                                              AND l_info_rec.max_period_counter
           AND adj.source_type_code = 'ADJUSTMENT'
           AND adj.set_of_books_id = l_info_rec.set_of_books_id
           AND thg.transaction_key = 'GC';
      end if;
      -- End MRC

      l_message := 'group loop (4-2)';


      ----------------------------------------------------------
      -- Calculate and set each column
      ----------------------------------------------------------
      -- Convert life_year_month to number
      l_group_rec.life_year_month :=
        fnd_number.canonical_to_number(l_group_rec.life_year_month_string);

      -- Addition during first/second half of the fiscal year
      IF NVL(l_group_rec.rule_name, ' ') <> FA_RXGA_HALF_YEAR_RULE THEN
        l_group_rec.first_half_addition := NULL;
        l_group_rec.second_half_addition := NULL;
      ELSE
        l_group_rec.first_half_addition :=
            l_group_rec.addition_amount - l_group_rec.second_half_addition;
      END IF;

      -- Adjustment amount
      --  = group level COST trx + member level COST/CIP COST trx
      --    - (member addition + member retirement) + group reclass
      l_group_rec.adjustment_amount :=
            l_group_adjustment_amount + l_group_rec.adjustment_amount
            - (l_group_rec.addition_amount - l_group_rec.cost_retired)
            + l_group_reclass_cost_in_out; /*  Bug#9375920 */

      -- Net proceeds
      IF NVL(l_group_rec.exclude_proceeds_from_basis, 'N') = 'Y' THEN
        -- Set net proceeds = 0 for class 10.1
        l_group_rec.net_proceeds := 0;
      END IF;


      -- NBV before depreciation
      l_group_rec.nbv_before_deprn
          := l_group_rec.beginning_nbv + l_group_rec.addition_amount
           + l_group_rec.adjustment_amount - l_group_rec.net_proceeds
	   - l_group_reclass_rsv_in_out; /*  Bug#9375920 */


      -- Depreciable basis adjustment / Reduced NBV
      -- (only applicable for 50% rule)
      IF NOT (NVL(l_group_rec.rule_name, ' ')
          IN (FA_RXGA_POSITIVE_REDUCTION, FA_RXGA_HALF_YEAR_RULE)) THEN
        l_group_rec.deprn_basis_adjustment := NULL;
        l_group_rec.reduced_nbv := NULL;

      ELSIF l_group_rec.max_period_counter < l_info_rec.min_period_counter THEN

        -- Set zero if there was no depreciation during the fiscal year.
        l_group_rec.deprn_basis_adjustment := 0;
        l_group_rec.reduced_nbv := 0;

      ELSE
        -- for class 90 (CIP group)
        -- If all the member assets are CIP, adjusted_cost is alyways 0.
        IF l_group_rec.reduced_nbv = 0
          AND NVL(l_group_rec.rule_name, ' ') = FA_RXGA_POSITIVE_REDUCTION THEN

           SELECT COUNT(*)
            INTO l_non_cip_num
            FROM fa_books bk, fa_additions ad
           WHERE bk.book_type_code = p_book_type_code
             AND bk.group_asset_id = l_group_rec.asset_id
             AND ad.asset_type <> 'CIP'
             AND bk.asset_id = ad.asset_id;

          IF NVL(l_non_cip_num, 0) = 0 THEN
            l_group_rec.reduced_nbv := l_group_rec.nbv_before_deprn;
          END IF;
        END IF;

        -- Reduced NBV (adjusted cost has already been set)
        IF l_group_rec.deprn_basis_rule = fa_std_types.FAD_DBR_NBV
           AND NVL(l_group_rec.exclude_salvage_value_flag, 'NO') = 'YES' THEN
          l_group_rec.reduced_nbv :=
              l_group_rec.reduced_nbv + l_group_rec.salvage_value;
        END IF;

        -- Depreciable basis adjustment
        l_group_rec.deprn_basis_adjustment :=
            l_group_rec.nbv_before_deprn - l_group_rec.reduced_nbv;
      END IF;


      -- Reduced/Regular/Annual depreciation amount
      IF NVL(l_group_rec.rule_name, ' ') <> FA_RXGA_HALF_YEAR_RULE THEN

        -- Set NULL if depreciable basis rule is not
        -- Year End Balance with Half Year Rule.
        l_group_rec.regular_deprn_amount := NULL;
        l_group_rec.reduced_deprn_amount := NULL;

      ELSIF l_group_rec.max_period_counter < l_info_rec.min_period_counter THEN
        -- Set zero if there was no depreciation during the fiscal year.
        l_group_rec.reduced_deprn_amount := 0;
        l_group_rec.regular_deprn_amount := 0;
        l_group_rec.annual_deprn_amount := 0;

      ELSE
        -- calculate reduced deprn amount, which assumed reduction rate
        -- was applied to the entire NBV before deprn
        l_all_reduced_deprn_amount :=
           l_group_rec.nbv_before_deprn * (1 - l_group_rec.reduction_rate)
           * l_group_rec.adjusted_rate;
        IF NOT fa_utils_pkg.faxtru(
                   X_num             => l_all_reduced_deprn_amount,
                   X_book_type_code  => p_book_type_code,
                   X_set_of_books_id => l_info_rec.set_of_books_id,
                   p_log_level_rec   => l_log_level_rec
        ) THEN
          raise main_err;
        END IF;

        IF g_print_debug THEN
          fa_rx_util_pkg.debug('l_all_reduced_deprn_amount: '
                         || l_all_reduced_deprn_amount);
          fa_rx_util_pkg.debug('annual_deprn_amount: '
                         || l_group_rec.annual_deprn_amount);
        END IF;

        IF l_group_rec.annual_deprn_amount = l_all_reduced_deprn_amount THEN
          l_group_rec.reduced_deprn_amount := l_group_rec.annual_deprn_amount;
        ELSE
          l_group_rec.reduced_deprn_amount := (l_second_half_add_rec_cost
            + l_second_half_grp_adjustment + l_second_half_mem_adjustment)
            * l_group_rec.adjusted_rate * (1 - l_group_rec.reduction_rate);
          IF NOT fa_utils_pkg.faxtru(
                   X_num             => l_group_rec.reduced_deprn_amount,
                   X_book_type_code  => p_book_type_code,
                   X_set_of_books_id => l_info_rec.set_of_books_id,
                   p_log_level_rec   => l_log_level_rec
          ) THEN
            raise main_err;
          END IF;
        END IF;

        -- Regular depreciation amount
        l_group_rec.regular_deprn_amount :=
            l_group_rec.annual_deprn_amount - l_group_rec.reduced_deprn_amount;
      END IF;

      -- Ending NBV
      -- Bug #2873705
      l_group_rec.ending_nbv := l_group_rec.cost
                              - l_group_rec.deprn_reserve
                              + l_group_rec.terminal_gain_loss_amount;

      -- Terminal Loss
      -- Bug #2876230 - set terminal loss only
      IF l_group_rec.terminal_gain_loss_amount < 0 THEN
        l_group_rec.terminal_gain_loss_amount
            := l_group_rec.terminal_gain_loss_amount * -1;
      ELSE
        l_group_rec.terminal_gain_loss_amount := 0;
      END IF;

      l_message := 'group loop (5)';


      ----------------------------------------------------------
      -- Insert only group / Query member assets
      ----------------------------------------------------------
      IF NVL(p_drill_down, 'N') <> 'Y' THEN

        -- Insert only group info into interface table
        insert_data(l_info_rec, l_group_rec, l_member_rec);

        l_message := 'group loop (6)';

      ELSE
        -- Query member assets that belong to the group
        l_info_rec.member_query_mode := 'EXISTS';
        query_member_assets(l_info_rec, l_group_rec, h_mrcsobtype);  -- MRC

        -- Query member assets that no longer belong to the group
        l_info_rec.member_query_mode := 'NOT EXISTS';
        query_member_assets(l_info_rec, l_group_rec, h_mrcsobtype);  -- MRC

      END IF; -- drill down y/n

    END LOOP;  -- group query loop
    CLOSE l_group_csr;


    l_info_rec.fiscal_year := l_info_rec.fiscal_year + 1;
  END LOOP;  -- fiscal year loop

  IF g_print_debug THEN
    fa_rx_util_pkg.debug('get_group_asset_info: '
                         || 'farx_ga.get_group_asset_info()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.log(l_message);
    END IF;

    IF sqlcode <> 0 THEN
      fa_rx_conc_mesg_pkg.log(sqlerrm);
    END IF;

    IF l_group_csr%ISOPEN THEN
      CLOSE l_group_csr;
    END IF;
    IF l_amount_csr%ISOPEN THEN
      CLOSE l_amount_csr;
    END IF;

    x_retcode := 2;
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_group_asset_info: '
                           || 'farx_ga.get_group_asset_info(EXCEPTION)-');
    END IF;

END get_group_asset_info;


-------------------------------------------------------------------
--
-- Function: get_category_sql
--   This function returns select clause and where clause for each
--   category.
--
-------------------------------------------------------------------
PROCEDURE get_category_sql (
  p_application_id          IN  NUMBER,
  p_category_flex_structure IN  NUMBER,
  p_qualifier               IN  VARCHAR2,
  p_category_low            IN  VARCHAR2,
  p_category_high           IN  VARCHAR2,
  x_select_stmt             OUT NOCOPY VARCHAR2,
  x_where_stmt              OUT NOCOPY VARCHAR2)
IS
BEGIN
  IF g_print_debug THEN
    fa_rx_util_pkg.debug('get_category_sql: '
                         || 'p_application_id: ' || p_application_id);
    fa_rx_util_pkg.debug('get_category_sql: ' || 'p_category_flex_structure: '
                         || p_category_flex_structure);
    fa_rx_util_pkg.debug('get_category_sql: '
                         || 'p_qualifier: ' || p_qualifier);
    fa_rx_util_pkg.debug('get_category_sql: '
                         || 'p_category_low: ' || p_category_low);
    fa_rx_util_pkg.debug('get_category_sql: '
                         || 'p_category_high: ' || p_category_high);
  END IF;


  -- Create select clause for category
  IF p_qualifier IS NULL THEN
    x_select_stmt := 'null';
  ELSE
    BEGIN
      x_select_stmt :=
        fa_rx_flex_pkg.flex_sql(p_application_id, 'CAT#',
                                p_category_flex_structure, 'cat',
                                'SELECT', p_qualifier);
    EXCEPTION
      WHEN OTHERS THEN
        x_select_stmt := 'null';
    END;
  END IF;


  -- Create where clause
  IF p_category_low = p_category_high THEN
    x_where_stmt := ' AND ' ||
                    fa_rx_flex_pkg.flex_sql(
                      p_application_id,
                      'CAT#',
                      p_category_flex_structure,
                      'cat',
                      'WHERE',
                      p_qualifier,
                      '=',
                      p_category_low);

  ELSIF p_category_low IS NOT NULL AND p_category_high IS NOT NULL THEN
    x_where_stmt := ' AND ' ||
                    fa_rx_flex_pkg.flex_sql(
                      p_application_id,
                      'CAT#',
                      p_category_flex_structure,
                      'cat',
                      'WHERE',
                      p_qualifier,
                      'BETWEEN',
                      p_category_low,
                      p_category_high);

  ELSIF p_category_low IS NOT NULL THEN
    x_where_stmt := ' AND ' ||
                    fa_rx_flex_pkg.flex_sql(
                      p_application_id,
                      'CAT#',
                      p_category_flex_structure,
                      'cat',
                      'WHERE',
                      p_qualifier,
                      '>=',
                      p_category_low);

  ELSIF p_category_high IS NOT NULL THEN
    x_where_stmt := ' AND ' ||
                    fa_rx_flex_pkg.flex_sql(
                      p_application_id,
                      'CAT#',
                      p_category_flex_structure,
                      'cat',
                      'WHERE',
                      p_qualifier,
                      '<=',
                      p_category_high);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_category_sql: '
                           || 'farx_ga.get_category_sql(EXCEPTION)-');
    END IF;
    raise;
END get_category_sql;


-------------------------------------------------------------------
--
-- Function: get_from_sql_stmt
--   This function returns from clause for group query and member
--   query.
--
-------------------------------------------------------------------
PROCEDURE get_from_sql_stmt (
  p_info_rec           IN  info_rec_type,
  p_group_asset_id     IN  NUMBER,
  p_mrcsobtype         IN  VARCHAR2 default NULL, -- MRC: SOB Type
  x_sql_stmt           OUT NOCOPY VARCHAR2)
IS
BEGIN

  -- Subquery is to get fa_books and fa_deprn_summary,
  -- which are used to calculate beginning NBV.
  -- Subquery doesn't necessarily get the previous year info.
  -- If there was no depreciation calculation in the previous year,
  -- subquery gets the max period counter prior to the fiscal year.
  if(P_MRCSOBTYPE <> 'R') then  -- MRC
     x_sql_stmt := ' FROM
       fa_additions ad,
       fa_books bk,
       fa_categories_b cat,
       fa_deprn_basis_rules br,
       fa_methods met,
       fa_deprn_periods dp,
       fa_deprn_summary ds,
       ( SELECT bk_pre.asset_id,
                bk_pre.group_asset_id,
                bk_pre.cost,
                bk_pre.cip_cost,
                ds_pre.deprn_reserve
           FROM fa_books bk_pre,
                fa_deprn_summary ds_pre,
                fa_deprn_periods dp_pre,
                fa_additions ad_pre
          WHERE bk_pre.book_type_code = ''' || p_info_rec.book_type_code || '''
            AND dp_pre.book_type_code = bk_pre.book_type_code
            AND dp_pre.period_counter + 1 = ' || p_info_rec.min_period_counter || '
            AND dp_pre.period_close_date BETWEEN bk_pre.date_effective
                AND NVL(bk_pre.date_ineffective, dp_pre.period_close_date)
            AND ds_pre.book_type_code = bk_pre.book_type_code
            AND ds_pre.asset_id = bk_pre.asset_id
            AND ds_pre.period_counter = (
                SELECT MAX(ds3.period_counter)
                  FROM fa_deprn_summary ds3
                 WHERE ds_pre.book_type_code = ds3.book_type_code
                   AND ds_pre.asset_id = ds3.asset_id
                   AND ds3.period_counter < ' || p_info_rec.min_period_counter || '
            )
            AND ad_pre.asset_id = bk_pre.asset_id ';
  -- MRC
  else
     x_sql_stmt := ' FROM
       fa_additions ad,
       fa_mc_books bk,
       fa_categories_b cat,
       fa_deprn_basis_rules br,
       fa_methods met,
       fa_mc_deprn_periods dp,
       fa_mc_deprn_summary ds,
       ( SELECT bk_pre.asset_id,
                bk_pre.group_asset_id,
                bk_pre.cost,
                bk_pre.cip_cost,
                ds_pre.deprn_reserve
           FROM fa_mc_books bk_pre,
                fa_mc_deprn_summary ds_pre,
                fa_mc_deprn_periods dp_pre,
                fa_additions ad_pre
          WHERE bk_pre.book_type_code = ''' || p_info_rec.book_type_code || '''
            AND dp_pre.book_type_code = bk_pre.book_type_code
            AND dp_pre.period_counter + 1 = ' || p_info_rec.min_period_counter || '
            AND dp_pre.period_close_date BETWEEN bk_pre.date_effective
                AND NVL(bk_pre.date_ineffective, dp_pre.period_close_date)
            AND ds_pre.book_type_code = bk_pre.book_type_code
            AND ds_pre.asset_id = bk_pre.asset_id
            AND ds_pre.period_counter = (
                SELECT MAX(ds3.period_counter)
                  FROM fa_mc_deprn_summary ds3
                 WHERE ds_pre.book_type_code = ds3.book_type_code
                   AND ds_pre.asset_id = ds3.asset_id
                   AND ds3.set_of_books_id = ' || p_info_rec.set_of_books_id || '
                   AND ds3.period_counter < ' || p_info_rec.min_period_counter || '
            )
            AND ad_pre.asset_id = bk_pre.asset_id
            AND bk_pre.set_of_books_id = ' || p_info_rec.set_of_books_id || '
            AND ds_pre.set_of_books_id = ' || p_info_rec.set_of_books_id || '
            AND dp_pre.set_of_books_id = ' || p_info_rec.set_of_books_id ;
  end if;
  -- End MRC


  -- slightly different depends on whether it is for group or member
  IF p_group_asset_id IS NULL THEN
    x_sql_stmt := x_sql_stmt ||
      'AND ad_pre.asset_type = ''GROUP'') prev ';
  ELSE
    x_sql_stmt := x_sql_stmt ||
      'AND bk_pre.group_asset_id = ' || p_group_asset_id || ') prev ';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_from_sql_stmt: '
                           || 'farx_ga.get_from_sql_stmt(EXCEPTION)-');
    END IF;
    raise;
END get_from_sql_stmt;


-------------------------------------------------------------------
--
-- Function: get_where_sql_stmt
--   This function returns where clause for group query and member
--   query.
--
-------------------------------------------------------------------
PROCEDURE get_where_sql_stmt (
  p_info_rec           IN  info_rec_type,
  p_group_asset_id     IN  NUMBER,
  p_mrcsobtype         IN  VARCHAR2 default NULL, -- MRC: SOB Type
  x_sql_stmt           OUT NOCOPY VARCHAR2)
IS
BEGIN

  -- This where clause ges fa_books, which corresponds to
  -- the last depreciated period in the fiscal year.

  -- This also gets fa_deprn_summary no matter what.
  -- There is at least deprn_source_code = 'BOOKS' row for every asset.
  -- fa_deprn_summary.period_counter will be the max period
  -- including the current fiscal year.

  if(P_MRCSOBTYPE <> 'R') then  -- MRC
     x_sql_stmt :=
     'WHERE bk.book_type_code = ''' || p_info_rec.book_type_code || '''
        AND bk.asset_id = ad.asset_id
        AND ad.asset_category_id = cat.category_id
        AND met.deprn_basis_rule_id = br.deprn_basis_rule_id (+)
        AND bk.deprn_method_code = met.method_code
        AND NVL(bk.life_in_months, 0) = NVL(met.life_in_months, 0)
        AND dp.book_type_code = bk.book_type_code
        AND dp.period_counter = ' || p_info_rec.max_period_counter || '
        AND ((dp.period_close_date IS NULL
              AND bk.date_ineffective IS NULL)
         OR (dp.period_close_date BETWEEN bk.date_effective
              AND NVL(bk.date_ineffective, dp.period_close_date)))
        AND ds.book_type_code = bk.book_type_code
        AND ds.asset_id = bk.asset_id
        AND ds.period_counter = (
            SELECT MAX(ds2.period_counter)
              FROM fa_deprn_summary ds2
             WHERE ds2.book_type_code = ds.book_type_code
               AND ds2.asset_id = ds.asset_id
               AND ds2.period_counter <= ' || p_info_rec.max_period_counter || ' )
        AND bk.asset_id = prev.asset_id (+)';

  -- MRC
  else
     x_sql_stmt :=
     'WHERE bk.book_type_code = ''' || p_info_rec.book_type_code || '''
        AND bk.asset_id = ad.asset_id
        AND ad.asset_category_id = cat.category_id
        AND met.deprn_basis_rule_id = br.deprn_basis_rule_id (+)
        AND bk.deprn_method_code = met.method_code
        AND NVL(bk.life_in_months, 0) = NVL(met.life_in_months, 0)
        AND dp.book_type_code = bk.book_type_code
        AND dp.period_counter = ' || p_info_rec.max_period_counter || '
        AND ((dp.period_close_date IS NULL
              AND bk.date_ineffective IS NULL)
         OR (dp.period_close_date BETWEEN bk.date_effective
              AND NVL(bk.date_ineffective, dp.period_close_date)))
        AND ds.book_type_code = bk.book_type_code
        AND ds.asset_id = bk.asset_id
        AND ds.period_counter = (
            SELECT MAX(ds2.period_counter)
              FROM fa_mc_deprn_summary ds2
             WHERE ds2.book_type_code = ds.book_type_code
               AND ds2.asset_id = ds.asset_id
               AND ds2.set_of_books_id = ' || p_info_rec.set_of_books_id || '
               AND ds2.period_counter <= ' || p_info_rec.max_period_counter || ' )
        AND bk.asset_id = prev.asset_id (+)
        AND bk.set_of_books_id = ' || p_info_rec.set_of_books_id || '
        AND dp.set_of_books_id = ' || p_info_rec.set_of_books_id || '
        AND ds.set_of_books_id = ' || p_info_rec.set_of_books_id ;
  end if;
  -- End MRC


  -- slightly different depends on whether it is for group or member
  IF p_group_asset_id IS NULL THEN
    x_sql_stmt := x_sql_stmt ||
      ' AND ad.asset_type = ''GROUP''';
  ELSIF p_info_rec.member_query_mode = 'EXISTS' THEN
    x_sql_stmt := x_sql_stmt ||
      ' AND bk.group_asset_id = ' || p_group_asset_id ||
      ' AND bk.asset_id = amt.asset_id (+)
        AND bk.asset_id = ret.asset_id (+) ';
  ELSE
    x_sql_stmt := x_sql_stmt ||
      ' AND prev.group_asset_id = ' || p_group_asset_id ||
      ' AND NVL(bk.group_asset_id, -1) <> ' || p_group_asset_id ||
      ' AND bk.asset_id = amt.asset_id (+)
        AND bk.asset_id = ret.asset_id (+) ';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_where_sql_stmt: '
                           || 'farx_ga.get_where_sql_stmt(EXCEPTION)-');
    END IF;
    raise;
END get_where_sql_stmt;


-------------------------------------------------------------------
--
-- Function: get_trx_amount_sql
--   This function returns sql statement for addition, adjustment
--   and retirement query.
--
-------------------------------------------------------------------
PROCEDURE get_trx_amount_sql (
  p_group_rec          IN  group_rec_type,
  p_info_rec           IN  info_rec_type,
  p_group_asset_id     IN  NUMBER,
  p_mrcsobtype         IN  VARCHAR2 default NULL, -- MRC: SOB Type
  x_sql_stmt           OUT NOCOPY VARCHAR2)
IS
BEGIN

  -- If it's group, need to query the following amount
  -- to calculate reduced/regular depreciation amount.
  --   1. recoverable cost of member asset added during the second
  --      half of the fiscal year
  --   2. adjustment amount occurred during the second half of the
  --      fiscal year

  IF p_group_asset_id IS NULL THEN
    x_sql_stmt := '
      SELECT NVL(SUM(DECODE(
        GREATEST(thm.transaction_date_entered, fy.mid_year_date),
        thm.transaction_date_entered,
        DECODE(adj.source_type_code || ''-'' || adj.adjustment_type
               || ''-'' || adj.debit_credit_flag,
               ''ADDITION-COST-DR'', ';

    IF p_group_rec.deprn_basis_rule = fa_std_types.FAD_DBR_NBV
       AND NVL(p_group_rec.exclude_salvage_value_flag, 'NO') = 'YES' THEN
      x_sql_stmt := x_sql_stmt || '
                    bkm.recoverable_cost + bkm.salvage_value,
                    0), 0)), 0) second_half_add_rec_cost, ';
    ELSE
      x_sql_stmt := x_sql_stmt || '
                    bkm.recoverable_cost,
                    0), 0)), 0) second_half_add_rec_cost, ';
    END IF;

    x_sql_stmt := x_sql_stmt || '
      NVL(SUM(DECODE(GREATEST(thm.transaction_date_entered, fy.mid_year_date),
          thm.transaction_date_entered, DECODE(adj.adjustment_type,
          ''COST'',
            DECODE(adj.source_type_code,
                   ''ADDITION'', 0,
                   ''RETIREMENT'', 0,
                   DECODE(adj.debit_credit_flag,
                          ''DR'', adj.adjustment_amount,
                          ''CR'', -adj.adjustment_amount,
                          0)),
          ''CIP COST'',
            DECODE(adj.source_type_code,
                   ''ADDITION'', 0,
                   ''RETIREMENT'', 0,
                   DECODE(adj.debit_credit_flag,
                          ''DR'', adj.adjustment_amount,
                          ''CR'', -adj.adjustment_amount,
                          0)), 0), 0)), 0)
      second_half_mem_adjustment, ';

  ELSE
    x_sql_stmt := '(SELECT adj.asset_id, ';
  END IF;


  -- Query transactions that occurred during the fiscal year.
  -- (includeing back dated transactions)
  -- but exclude transanctions that happened during the open period
  -- (even if it's back dated one.)
  -- Note: cip adjustment is treated as addition (class 90)

  if(P_MRCSOBTYPE <> 'R') then  -- MRC
     x_sql_stmt := x_sql_stmt || '
      NVL(SUM(DECODE(GREATEST(thm.transaction_date_entered, fy.mid_year_date),
      thm.transaction_date_entered,
        DECODE(adj.source_type_code || ''-'' || adj.adjustment_type || ''-''
                || adj.debit_credit_flag,
              ''ADDITION-COST-DR'', adj.adjustment_amount,
              ''ADDITION-COST-CR'', -adj.adjustment_amount,
              ''CIP ADDITION-COST-DR'', adj.adjustment_amount,
              ''CIP ADDITION-COST-CR'', -adj.adjustment_amount,
              ''CIP ADJUSTMENT-COST-DR'', adj.adjustment_amount,
              0), 0)), 0)
        second_half_addition,
      NVL(SUM(DECODE(adj.source_type_code || ''-'' || adj.adjustment_type
        || ''-'' || adj.debit_credit_flag,
        ''ADDITION-COST-DR'', adj.adjustment_amount,
        ''ADDITION-COST-CR'', -adj.adjustment_amount,
        ''CIP ADDITION-CIP COST-DR'', adj.adjustment_amount,
        ''CIP ADDITION-CIP COST-CR'', -adj.adjustment_amount,
        ''CIP ADJUSTMENT-CIP COST-DR'', adj.adjustment_amount,
        0)), 0)
        addition_amount,
      NVL(SUM(DECODE(adj.adjustment_type || ''-'' || adj.debit_credit_flag,
        ''COST-DR'', adj.adjustment_amount,
        ''COST-CR'', -adj.adjustment_amount,
        ''CIP COST-DR'', adj.adjustment_amount,
        ''CIP COST-CR'', -adj.adjustment_amount, 0)), 0)
        adjustment_amount
   FROM fa_adjustments adj,
        fa_book_controls bc,
        fa_fiscal_year fy,
        fa_transaction_headers thm,
        fa_books bkm
  WHERE bkm.group_asset_id = ' || p_group_rec.asset_id || '
    AND adj.asset_id = bkm.asset_id
    AND bkm.transaction_header_id_in = thm.transaction_header_id
    AND adj.book_type_code = ''' || p_info_rec.book_type_code || '''
    AND adj.period_counter_created
        BETWEEN ' || p_info_rec.min_period_counter ||
        ' and ' || p_info_rec.max_period_counter || '
    AND adj.transaction_header_id = thm.transaction_header_id
    AND fy.fiscal_year = ' || p_info_rec.fiscal_year || '
    AND fy.fiscal_year_name = bc.fiscal_year_name
    AND bc.book_type_code = adj.book_type_code ';
  -- MRC
  else
     x_sql_stmt := x_sql_stmt || '
     NVL(SUM(DECODE(GREATEST(thm.transaction_date_entered, fy.mid_year_date),
       thm.transaction_date_entered,
       DECODE(adj.source_type_code || ''-'' || adj.adjustment_type || ''-''
                 || adj.debit_credit_flag,
               ''ADDITION-COST-DR'', adj.adjustment_amount,
               ''ADDITION-COST-CR'', -adj.adjustment_amount,
               ''CIP ADDITION-COST-DR'', adj.adjustment_amount,
               ''CIP ADDITION-COST-CR'', -adj.adjustment_amount,
               ''CIP ADJUSTMENT-COST-DR'', adj.adjustment_amount,
               0), 0)), 0)
       second_half_addition,
     NVL(SUM(DECODE(adj.source_type_code || ''-'' || adj.adjustment_type
       || ''-'' || adj.debit_credit_flag,
       ''ADDITION-COST-DR'', adj.adjustment_amount,
       ''ADDITION-COST-CR'', -adj.adjustment_amount,
       ''CIP ADDITION-CIP COST-DR'', adj.adjustment_amount,
       ''CIP ADDITION-CIP COST-CR'', -adj.adjustment_amount,
       ''CIP ADJUSTMENT-CIP COST-DR'', adj.adjustment_amount,
       0)), 0)
       addition_amount,
     NVL(SUM(DECODE(adj.adjustment_type || ''-'' || adj.debit_credit_flag,
       ''COST-DR'', adj.adjustment_amount,
       ''COST-CR'', -adj.adjustment_amount,
       ''CIP COST-DR'', adj.adjustment_amount,
       ''CIP COST-CR'', -adj.adjustment_amount, 0)), 0)
       adjustment_amount
    FROM fa_mc_adjustments adj,
         fa_mc_book_controls bc,
         fa_book_controls bc1,
         fa_fiscal_year fy,
         fa_transaction_headers thm,
         fa_mc_books bkm
   WHERE bkm.group_asset_id = ' || p_group_rec.asset_id || '
     AND adj.asset_id = bkm.asset_id
     AND bkm.transaction_header_id_in = thm.transaction_header_id
     AND adj.book_type_code = ''' || p_info_rec.book_type_code || '''
     AND adj.period_counter_created
         BETWEEN ' || p_info_rec.min_period_counter ||
         ' and ' || p_info_rec.max_period_counter || '
     AND adj.transaction_header_id = thm.transaction_header_id
     AND fy.fiscal_year = ' || p_info_rec.fiscal_year || '
     AND fy.fiscal_year_name = bc1.fiscal_year_name
     AND bc.book_type_code = bc1.book_type_code
     AND bc.book_type_code = adj.book_type_code
     AND adj.set_of_books_id = ' || p_info_rec.set_of_books_id || '
     AND bc.set_of_books_id  = ' || p_info_rec.set_of_books_id || '
     AND bkm.set_of_books_id = ' || p_info_rec.set_of_books_id ;
   end if;
   -- End MRC

  IF p_group_asset_id IS NOT NULL THEN
    x_sql_stmt := x_sql_stmt || 'GROUP BY adj.asset_id) amt ';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_trx_amount_sql: '
                           || 'farx_ga.get_trx_amount_sql(EXCEPTION)-');
    END IF;
    raise;
END get_trx_amount_sql;



-------------------------------------------------------------------
--
-- Function: get_retirement_sql
--   This function returns sql statement for retirement amount
--   for member assets.
--
-------------------------------------------------------------------
PROCEDURE get_retirement_sql (
  p_info_rec           IN  info_rec_type,
  p_group_asset_id     IN  NUMBER,
  p_mrcsobtype         IN  VARCHAR2 default NULL,    -- MRC: SOB Type
  x_sql_stmt           OUT NOCOPY VARCHAR2)
IS
BEGIN
  if(P_MRCSOBTYPE <> 'R') then  -- MRC
     x_sql_stmt := '(SELECT ret.asset_id,
     NVL(SUM(ret.proceeds_of_sale), 0) proceeds_of_sale,
     NVL(SUM(ret.cost_of_removal), 0) cost_of_removal,
     NVL(SUM(ret.cost_retired), 0) cost_retired,
     NVL(SUM(ret.reserve_retired), 0) reserve_retired
    FROM fa_retirements ret,
         fa_book_controls bc,
         fa_fiscal_year fy,
         fa_transaction_headers thm,
         fa_books bkm
    WHERE bkm.group_asset_id = ' || p_group_asset_id || '
     AND bc.book_type_code = ''' || p_info_rec.book_type_code || '''
     AND fy.fiscal_year = ' || p_info_rec.fiscal_year || '
     AND fy.fiscal_year_name = bc.fiscal_year_name
     AND thm.book_type_code = bc.book_type_code
     AND bkm.book_type_code = bc.book_type_code
     AND thm.transaction_date_entered
         BETWEEN fy.start_date and fy.end_date
     AND ret.asset_id = thm.asset_id
     AND bkm.asset_id = thm.asset_id
     AND bkm.transaction_header_id_in = thm.transaction_header_id
     AND ret.transaction_header_id_in = thm.transaction_header_id
     AND ret.status <> ''DELETED''
    GROUP BY ret.asset_id) ret ';

  -- MRC
  else
     x_sql_stmt := '(SELECT ret.asset_id,
     NVL(SUM(ret.proceeds_of_sale), 0) proceeds_of_sale,
     NVL(SUM(ret.cost_of_removal), 0) cost_of_removal,
     NVL(SUM(ret.cost_retired), 0) cost_retired,
     NVL(SUM(ret.reserve_retired), 0) reserve_retired
    FROM fa_mc_retirements ret,
         fa_mc_book_controls bc,
         fa_fiscal_year fy,
         fa_transaction_headers thm,
         fa_mc_books bkm
   WHERE bkm.group_asset_id = ' || p_group_asset_id || '
     AND bc.book_type_code = ''' || p_info_rec.book_type_code || '''
     AND fy.fiscal_year = ' || p_info_rec.fiscal_year || '
     AND fy.fiscal_year_name = bc.fiscal_year_name
     AND thm.book_type_code = bc.book_type_code
     AND bkm.book_type_code = bc.book_type_code
     AND thm.transaction_date_entered
         BETWEEN fy.start_date and fy.end_date
     AND ret.asset_id = thm.asset_id
     AND bkm.asset_id = thm.asset_id
     AND bkm.transaction_header_id_in = thm.transaction_header_id
     AND ret.transaction_header_id_in = thm.transaction_header_id
     AND ret.status <> ''DELETED''
     AND ret.set_of_books_id = ' || p_info_rec.set_of_books_id || '
     AND bc.set_of_books_id  = ' || p_info_rec.set_of_books_id || '
     AND bkm.set_of_books_id = ' || p_info_rec.set_of_books_id || '
   GROUP BY ret.asset_id) ret ';
  end if;
  -- End MRC

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('get_retirement_sql: '
                           || 'farx_ga.get_retirement_sql(EXCEPTION)-');
    END IF;
    raise;
END get_retirement_sql;


-------------------------------------------------------------------
--
-- Function: insert_data
--   This function inserts data into fa_group_rep_itf.
--
-------------------------------------------------------------------
PROCEDURE insert_data (
  p_info_rec                  IN  info_rec_type,
  p_group_rec                 IN  group_rec_type,
  p_member_rec                IN  group_rec_type)
IS
BEGIN
  INSERT INTO fa_group_rep_itf (
      request_id, created_by, creation_date,
      last_updated_by, last_update_date, last_update_login,
      organization_name, functional_currency_code,
      set_of_books_id, book_type_code, deprn_calendar, fiscal_year,
      grp_asset_number, grp_description, grp_asset_type,
      grp_major_category, grp_minor_category, grp_other_category,
      grp_date_placed_in_service, grp_deprn_method_code,
      grp_rule_name, grp_tracking_method,
      grp_adjusted_rate, grp_life_year_month,
      grp_cost, grp_salvage_value,
      grp_adjusted_recoverable_cost, grp_beginning_nbv,
      grp_first_half_addition, grp_second_half_addition,
      grp_addition_amount, grp_adjustment_amount,
      grp_net_proceeds, grp_proceeds_of_sale, grp_cost_of_removal,
      grp_cost_retired, grp_reserve_retired,
      grp_recapture_amount, grp_terminal_gain_loss_amount,
      grp_nbv_before_deprn, grp_deprn_basis_adjustment,
      grp_reduced_nbv,
      grp_regular_deprn_amount, grp_reduced_deprn_amount,
      grp_annual_deprn_amount, grp_deprn_reserve, grp_ending_nbv,
      mem_asset_number, mem_description, mem_asset_type,
      mem_major_category, mem_minor_category, mem_other_category,
      mem_date_placed_in_service, mem_deprn_method_code,
      mem_rule_name, mem_adjusted_rate, mem_life_year_month,
      mem_cost, mem_salvage_value,
      mem_adjusted_recoverable_cost, mem_beginning_nbv,
      mem_first_half_addition, mem_second_half_addition,
      mem_addition_amount, mem_adjustment_amount,
      mem_net_proceeds, mem_proceeds_of_sale, mem_cost_of_removal,
      mem_cost_retired, mem_reserve_retired,
      mem_nbv_before_deprn, mem_deprn_basis_adjustment,
      mem_reduced_nbv,
      mem_annual_deprn_amount, mem_deprn_reserve, mem_ending_nbv,
      mem_status
  ) VALUES (
      p_info_rec.request_id, p_info_rec.user_id, sysdate,
      p_info_rec.user_id, sysdate, p_info_rec.user_id,
      p_info_rec.organization_name, p_info_rec.functional_currency_code,
      p_info_rec.set_of_books_id, p_info_rec.book_type_code,
      p_info_rec.deprn_calendar, p_info_rec.fiscal_year,
      p_group_rec.asset_number,
      p_group_rec.description,
      p_group_rec.asset_type,
      p_group_rec.major_category,
      p_group_rec.minor_category,
      p_group_rec.other_category,
      p_group_rec.date_placed_in_service,
      p_group_rec.deprn_method_code,
      p_group_rec.rule_name,
      p_group_rec.tracking_method,
      p_group_rec.adjusted_rate,
      p_group_rec.life_year_month,
      p_group_rec.cost,
      p_group_rec.salvage_value,
      p_group_rec.adjusted_recoverable_cost,
      p_group_rec.beginning_nbv,
      p_group_rec.first_half_addition,
      p_group_rec.second_half_addition,
      p_group_rec.addition_amount,
      p_group_rec.adjustment_amount,
      p_group_rec.net_proceeds,
      p_group_rec.proceeds_of_sale,
      p_group_rec.cost_of_removal,
      p_group_rec.cost_retired,
      p_group_rec.reserve_retired,
      p_group_rec.recapture_amount,
      p_group_rec.terminal_gain_loss_amount,
      p_group_rec.nbv_before_deprn,
      p_group_rec.deprn_basis_adjustment,
      p_group_rec.reduced_nbv,
      p_group_rec.regular_deprn_amount,
      p_group_rec.reduced_deprn_amount,
      p_group_rec.annual_deprn_amount,
      p_group_rec.deprn_reserve,
      p_group_rec.ending_nbv,
      p_member_rec.asset_number,
      p_member_rec.description,
      p_member_rec.asset_type,
      p_member_rec.major_category,
      p_member_rec.minor_category,
      p_member_rec.other_category,
      p_member_rec.date_placed_in_service,
      p_member_rec.deprn_method_code,
      p_member_rec.rule_name,
      p_member_rec.adjusted_rate,
      p_member_rec.life_year_month,
      p_member_rec.cost,
      p_member_rec.salvage_value,
      p_member_rec.adjusted_recoverable_cost,
      p_member_rec.beginning_nbv,
      p_member_rec.first_half_addition,
      p_member_rec.second_half_addition,
      p_member_rec.addition_amount,
      p_member_rec.adjustment_amount,
      p_member_rec.net_proceeds,
      p_member_rec.proceeds_of_sale,
      p_member_rec.cost_of_removal,
      p_member_rec.cost_retired,
      p_member_rec.reserve_retired,
      p_member_rec.nbv_before_deprn,
      p_member_rec.deprn_basis_adjustment,
      p_member_rec.reduced_nbv,
      p_member_rec.annual_deprn_amount,
      p_member_rec.deprn_reserve,
      p_member_rec.ending_nbv,
      p_member_rec.status);

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.debug('insert_data: '
                           || 'farx_ga.insert_data(EXCEPTION)-');
    END IF;
    raise;
END insert_data;


-------------------------------------------------------------------
--
-- Function: query_member_assets
--   This function queries member assets.
--
-------------------------------------------------------------------
PROCEDURE query_member_assets (
  p_info_rec         IN  info_rec_type,
  p_group_rec        IN  group_rec_type,
  p_mrcsobtype       IN  VARCHAR2 default NULL) -- MRC: SOB Type
IS
  l_message          VARCHAR2(30);
  l_member_sql_stmt  VARCHAR2(10000);
  l_sql_stmt         VARCHAR2(5000);

  l_group_reclass_in  NUMBER;
  l_group_reclass_out NUMBER;

  TYPE group_csrtype IS REF CURSOR;
  l_member_csr       group_csrtype;
  l_member_rec       group_rec_type;
BEGIN
  ---------------------------------------------------
  -- <Member query loop>
  -- Query member assets belong to the group
  ---------------------------------------------------
  l_message := 'member loop (1)';

  -- Create query for member asset
  --   Don't use asset_type to identify cost or cip_cost because
  --   you cannot get right amount once the asset is capitalized

  l_member_sql_stmt :=
    'SELECT
      ad.asset_number,
      ad.description,
      ad.asset_type, '
      || p_info_rec.major_cat_select_stmt || ','
      || p_info_rec.minor_cat_select_stmt || ','
      || p_info_rec.other_cat_select_stmt || ',
      bk.date_placed_in_service,
      bk.deprn_method_code,
      br.rule_name,
      NULL,
      bk.adjusted_rate,
      NULL,
      NVL(bk.cost, 0) + NVL(bk.cip_cost, 0),
      NVL(bk.salvage_value, 0),
      NVL(bk.adjusted_recoverable_cost, 0),
      NVL(prev.cost, 0) + NVL(prev.cip_cost, 0) - NVL(prev.deprn_reserve, 0),
      NULL,
      NVL(amt.second_half_addition, 0),
      NVL(amt.addition_amount, 0),
      NVL(amt.adjustment_amount, 0),
      NULL,
      NVL(ret.proceeds_of_sale, 0),
      NVL(ret.cost_of_removal, 0),
      NVL(ret.cost_retired, 0),
      NVL(ret.reserve_retired, 0),
      NULL, NULL, NULL, NULL,
      NVL(ds.adjusted_cost, 0),
      NULL, NULL,
      NVL(ds.ytd_deprn, 0),
      NVL(ds.deprn_reserve,  0),
      NULL, NULL,
      ad.asset_id,
      prev.group_asset_id,
      DECODE(bk.life_in_months, NULL, NULL,
        TO_CHAR(FLOOR(bk.life_in_months / 12)) || ''.'' ||
        TO_CHAR(MOD(bk.life_in_months, 12))),
      met.deprn_basis_rule,
      met.exclude_salvage_value_flag,
      NULL, NULL, NULL, NULL,
      bk.period_counter_fully_retired,
      bk.period_counter_fully_reserved,
      ds.period_counter ';

  l_message := 'member loop (2)';

  -- Add from clause
  get_from_sql_stmt(p_info_rec, p_group_rec.asset_id, p_mrcsobtype, l_sql_stmt);  -- MRC
  l_member_sql_stmt := l_member_sql_stmt || l_sql_stmt || ', ';

  get_trx_amount_sql(p_group_rec, p_info_rec,
                     p_group_rec.asset_id,
                     p_mrcsobtype,             -- MRC
                     l_sql_stmt);
  l_member_sql_stmt := l_member_sql_stmt || l_sql_stmt || ', ';

  get_retirement_sql(p_info_rec, p_group_rec.asset_id, p_mrcsobtype, l_sql_stmt);  -- MRC
  l_member_sql_stmt := l_member_sql_stmt || l_sql_stmt;

  -- Add where clause
  get_where_sql_stmt(p_info_rec, p_group_rec.asset_id, p_mrcsobtype, l_sql_stmt);  -- MRC
  l_member_sql_stmt := l_member_sql_stmt || l_sql_stmt;

  -- Exclude assets which became fully retired before this FY
  -- (adjusted cost > 0 is for Canada's class 13)
  IF NVL(p_group_rec.recognize_gain_loss, 'NO') = 'YES' THEN
    l_member_sql_stmt := l_member_sql_stmt
        || ' AND NVL(bk.period_counter_fully_retired,'
        || p_info_rec.min_period_counter
        || ') >= ' || p_info_rec.min_period_counter
        || ' AND bk.adjusted_cost > 0 ';
  END IF;

  l_message := 'member loop (3)';


  -- Member query loop start
  OPEN l_member_csr FOR l_member_sql_stmt;
  LOOP
    FETCH l_member_csr INTO l_member_rec;
    EXIT WHEN l_member_csr%NOTFOUND;

    l_message := 'member loop (4)';

    ---------------------------------------------------
    -- query group reclass amounts
    ---------------------------------------------------
    l_group_reclass_in := 0;
    l_group_reclass_out := 0;

    -- Asset that no longer belongs to the group
    IF p_info_rec.member_query_mode = 'NOT EXISTS' THEN
      l_message := 'member loop (4-1)';

      BEGIN
         if(P_MRCSOBTYPE <> 'R') then  -- MRC
           SELECT NVL(bkm.cost, 0) - NVL(adj.adjustment_amount, 0)
            INTO l_group_reclass_out
            FROM fa_adjustments adj,
                 fa_transaction_headers thg,
                 fa_books bkm
           WHERE adj.asset_id = p_group_rec.asset_id
             AND adj.book_type_code = p_info_rec.book_type_code
             AND thg.transaction_header_id = adj.transaction_header_id
             AND adj.period_counter_created
                 BETWEEN p_info_rec.min_period_counter
                     and p_info_rec.max_period_counter
             AND adj.source_type_code = 'ADJUSTMENT'
             AND adj.adjustment_type = 'RESERVE'
             AND thg.member_transaction_header_id = bkm.transaction_header_id_in
             AND NVL(bkm.group_asset_id, -1) <> p_group_rec.asset_id
             AND bkm.asset_id = l_member_rec.asset_id;
         -- MRC
         else
           SELECT NVL(bkm.cost, 0) - NVL(adj.adjustment_amount, 0)
             INTO l_group_reclass_out
             FROM fa_mc_adjustments adj,
                  fa_transaction_headers thg,
                  fa_mc_books bkm
            WHERE adj.asset_id = p_group_rec.asset_id
              AND adj.book_type_code = p_info_rec.book_type_code
              AND thg.transaction_header_id = adj.transaction_header_id
              AND adj.period_counter_created
                  BETWEEN p_info_rec.min_period_counter
                      and p_info_rec.max_period_counter
              AND adj.source_type_code = 'ADJUSTMENT'
              AND adj.adjustment_type = 'RESERVE'
              AND thg.member_transaction_header_id = bkm.transaction_header_id_in
              AND NVL(bkm.group_asset_id, -1) <> p_group_rec.asset_id
              AND bkm.asset_id = l_member_rec.asset_id
              AND adj.set_of_books_id = p_info_rec.set_of_books_id
              AND bkm.set_of_books_id = p_info_rec.set_of_books_id;
         end if;
         -- End MRC

      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;
      l_message := 'member loop (4-2)';

      l_member_rec.cost := 0;
      l_member_rec.salvage_value := 0;
      l_member_rec.adjusted_recoverable_cost := 0;
      l_member_rec.reduced_nbv := 0;
      l_member_rec.annual_deprn_amount := 0;
      l_member_rec.deprn_reserve := 0;

    -- standalone/other group -> this group
    ELSIF l_member_rec.addition_amount = 0
      AND NVL(l_member_rec.pre_group_asset_id, -1) <> p_group_rec.asset_id THEN
      l_message := 'member loop (4-3)';

      BEGIN
         if(P_MRCSOBTYPE <> 'R') then  -- MRC
           SELECT NVL(bkm.cost, 0) - NVL(adj.adjustment_amount, 0)
             INTO l_group_reclass_in
             FROM fa_adjustments adj,
                  fa_transaction_headers thg,
                  fa_books bkm
            WHERE adj.asset_id = p_group_rec.asset_id
              AND adj.book_type_code = p_info_rec.book_type_code
              AND thg.transaction_header_id = adj.transaction_header_id
              AND adj.period_counter_created
                  BETWEEN p_info_rec.min_period_counter
                      and p_info_rec.max_period_counter
              AND adj.source_type_code = 'ADJUSTMENT'
              AND adj.adjustment_type = 'RESERVE'
              AND thg.member_transaction_header_id = bkm.transaction_header_id_in
              AND NVL(bkm.group_asset_id, -1) = p_group_rec.asset_id;
         -- MRC
         else
            SELECT NVL(bkm.cost, 0) - NVL(adj.adjustment_amount, 0)
             INTO l_group_reclass_in
             FROM fa_mc_adjustments adj,
                  fa_transaction_headers thg,
                  fa_mc_books bkm
            WHERE adj.asset_id = p_group_rec.asset_id
              AND adj.book_type_code = p_info_rec.book_type_code
              AND thg.transaction_header_id = adj.transaction_header_id
              AND adj.period_counter_created
                  BETWEEN p_info_rec.min_period_counter
                      and p_info_rec.max_period_counter
              AND adj.source_type_code = 'ADJUSTMENT'
              AND adj.adjustment_type = 'RESERVE'
              AND thg.member_transaction_header_id = bkm.transaction_header_id_in
              AND NVL(bkm.group_asset_id, -1) = p_group_rec.asset_id
              AND adj.set_of_books_id = p_info_rec.set_of_books_id
              AND bkm.set_of_books_id = p_info_rec.set_of_books_id;
         end if;
         -- End MRC

      EXCEPTION
        WHEN OTHERS THEN
          null;
      END;
      l_message := 'member loop (4-4)';
    END IF;


    ---------------------------------------------------
    -- Calculate and set each column
    ---------------------------------------------------
    -- Convert life_year_month to number
    l_member_rec.life_year_month :=
      fnd_number.canonical_to_number(l_member_rec.life_year_month_string);

    -- Addition during first/second half of the fiscal year
    -- Note: checking group's depreciable basis rule.
    IF NVL(p_group_rec.rule_name, ' ') <> FA_RXGA_HALF_YEAR_RULE THEN
      l_member_rec.first_half_addition := NULL;
      l_member_rec.second_half_addition := NULL;
    ELSE
      l_member_rec.first_half_addition :=
        l_member_rec.addition_amount - l_member_rec.second_half_addition;
    END IF;

    -- Adjustment amount
    --  = member level COST/CIP COST transactions
    --    - (member additions + member retirement)
    --    + group reclass amounts
    l_member_rec.adjustment_amount := l_member_rec.adjustment_amount
        - (l_member_rec.addition_amount - l_member_rec.cost_retired)
        + (l_group_reclass_in - l_group_reclass_out);

    -- Net proceeds
    IF NVL(p_group_rec.exclude_proceeds_from_basis, 'N') = 'Y' THEN
      -- Set proceeds = 0 for class 10.1
      l_member_rec.net_proceeds := 0;
    ELSE
      l_member_rec.net_proceeds :=
        l_member_rec.proceeds_of_sale - l_member_rec.cost_of_removal;
    END IF;


    IF p_group_rec.tracking_method IS NULL then

      -- Set NULL to depreciation amount related columns
      -- when member tracking is off
      l_member_rec.beginning_nbv := NULL;
      l_member_rec.nbv_before_deprn := NULL;
      l_member_rec.deprn_basis_adjustment := NULL;
      l_member_rec.reduced_nbv := NULL;
      l_member_rec.annual_deprn_amount := NULL;
      l_member_rec.deprn_reserve := NULL;
      l_member_rec.ending_nbv := NULL;
      l_member_rec.deprn_method_code := NULL;
      l_member_rec.rule_name := NULL;
      l_member_rec.adjusted_rate := NULL;
      l_member_rec.life_year_month := NULL;

    ELSE
      -- Set group's method if tracking is not calculated by member method
      IF NOT (NVL(p_group_rec.tracking_method, '') = 'CALCULATE'
        AND NVL(p_group_rec.depreciation_option, '') = 'MEMBER') THEN
        l_member_rec.deprn_method_code := p_group_rec.deprn_method_code;
        l_member_rec.rule_name := p_group_rec.rule_name;
        l_member_rec.adjusted_rate := p_group_rec.adjusted_rate;
        l_member_rec.life_year_month := p_group_rec.life_year_month;
        l_member_rec.deprn_basis_rule := p_group_rec.deprn_basis_rule;
        l_member_rec.exclude_salvage_value_flag := p_group_rec.exclude_salvage_value_flag;
      END IF;

      -- Group reclass is treated like an addition to the group
      IF NVL(l_member_rec.pre_group_asset_id, 0) <> p_group_rec.asset_id THEN
        l_member_rec.beginning_nbv := 0;
      END IF;

      -- NBV before depreciation
      l_member_rec.nbv_before_deprn
        := l_member_rec.beginning_nbv + l_member_rec.addition_amount
         + l_member_rec.adjustment_amount - l_member_rec.net_proceeds;

      -- Annual depreciation amount
      -- (Set zero if there was no depreciation during the fiscal year)
      IF l_member_rec.max_period_counter < p_info_rec.min_period_counter THEN
        l_member_rec.annual_deprn_amount := 0;
      END IF;


      -- Reduced NBV / Deprn basis adjustment
      -- (only applicable for 50% rule)
      IF NOT (NVL(p_group_rec.rule_name, ' ')
          IN (FA_RXGA_POSITIVE_REDUCTION, FA_RXGA_HALF_YEAR_RULE)) THEN
        l_member_rec.deprn_basis_adjustment := NULL;
        l_member_rec.reduced_nbv := NULL;

      ELSIF l_member_rec.max_period_counter < p_info_rec.min_period_counter THEN
        -- Set zero if there was no depreciation during the fiscal year
        l_member_rec.deprn_basis_adjustment := 0;
        l_member_rec.reduced_nbv := 0;

      ELSE
        -- Reduced NBV (adjusted cost has already been set)
        IF l_member_rec.deprn_basis_rule = fa_std_types.FAD_DBR_NBV
           AND NVL(l_member_rec.exclude_salvage_value_flag, 'NO') = 'YES' THEN
          l_member_rec.reduced_nbv :=
              l_member_rec.reduced_nbv + l_member_rec.salvage_value;
        END IF;

        -- Depreciable basis adjustment
        l_member_rec.deprn_basis_adjustment :=
          l_member_rec.nbv_before_deprn - l_member_rec.reduced_nbv;
      END IF;

      -- Endign NBV
      l_member_rec.ending_nbv := l_member_rec.cost - l_member_rec.deprn_reserve;

    END IF;

    -- status
    -- bug #2846290
    IF NVL(l_member_rec.period_counter_fully_retired,
           p_info_rec.max_period_counter + 1) <= p_info_rec.max_period_counter THEN
      l_member_rec.status := 'FULLY RETIRED';
    ELSIF NVL(l_member_rec.period_counter_fully_reserved,
              p_info_rec.max_period_counter + 1) <= p_info_rec.max_period_counter THEN
      l_member_rec.status := 'FULLY RESERVED';
    END IF;

    l_message := 'member loop (5)';


    -- Insert into interface table
    insert_data(p_info_rec, p_group_rec, l_member_rec);

    l_message := 'member loop (6)';

  END LOOP;  -- member query loop
  CLOSE l_member_csr;

EXCEPTION
  WHEN OTHERS THEN
    IF g_print_debug THEN
      fa_rx_util_pkg.log(sqlcode);
      fa_rx_util_pkg.log(sqlerrm);
      fa_rx_util_pkg.log(l_message);
      fa_rx_util_pkg.debug('query_member_assets: '
                           || 'farx_ga.query_member_assets(EXCEPTION)-');
    END IF;

    IF sqlcode <> 0 THEN
      fa_rx_conc_mesg_pkg.log(sqlerrm);
    END IF;

    fnd_message.set_name('OFA', l_message);
    IF l_message = 'FA_SHARED_INSERT_FAIL' THEN
      fnd_message.set_token('TABLE', 'FA_GROUP_REP_ITF');
    END IF;
    fa_rx_conc_mesg_pkg.log(fnd_message.get);

    IF l_member_csr%ISOPEN THEN
      CLOSE l_member_csr;
    END IF;

    raise;
END query_member_assets;


END FA_RX_GROUP;

/
