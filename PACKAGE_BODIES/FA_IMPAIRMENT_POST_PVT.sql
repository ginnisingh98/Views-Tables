--------------------------------------------------------
--  DDL for Package Body FA_IMPAIRMENT_POST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_IMPAIRMENT_POST_PVT" AS
/* $Header: FAVIMPTB.pls 120.9.12010000.13 2010/06/15 10:40:05 deemitta noship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;
g_release                  number  := fa_cache_pkg.fazarel_release;

  --
  -- Datatypes for pl/sql tables below
  --
  TYPE tab_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  g_temp_number   number;
  g_temp_integer  binary_integer;
  g_temp_boolean  boolean;
  g_temp_varchar2 varchar2(100);


--*********************** Private functions ******************************--
FUNCTION call_deprn_basis(
              p_asset_hdr_rec     IN fa_api_types.asset_hdr_rec_type
            , p_trans_rec         IN fa_api_types.trans_rec_type
            , p_period_rec        IN fa_api_types.period_rec_type
            , p_asset_type_rec    IN fa_api_types.asset_type_rec_type
            , p_asset_fin_rec     IN fa_api_types.asset_fin_rec_type
            , p_asset_deprn_rec   IN fa_api_types.asset_deprn_rec_type
            , p_asset_desc_rec    IN fa_api_types.asset_desc_rec_type
            , x_new_raf              OUT NOCOPY NUMBER
            , x_new_formula_factor   OUT NOCOPY NUMBER
            , x_new_adjusted_cost    OUT NOCOPY NUMBER
            , p_mrc_sob_type_code IN VARCHAR2
            , p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


FUNCTION create_cost_entries(
              p_asset_hdr_rec      IN fa_api_types.asset_hdr_rec_type
            , p_trans_rec          IN fa_api_types.trans_rec_type
            , p_period_rec         IN fa_api_types.period_rec_type
            , p_asset_type_rec     IN fa_api_types.asset_type_rec_type
            , p_cost               IN NUMBER
            , p_current_units      IN NUMBER
            , p_mrc_sob_type_code  IN VARCHAR2
            , p_calling_fn         IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


--*********************** Public functions ******************************--
FUNCTION process_post(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_worker_id         IN NUMBER,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'FA_IMPAIRMENT_POST_PVT.process_post';
   l_mode         varchar2(20) := 'RUNNING POST';

   CURSOR c_get_itf is
      select ITF.REQUEST_ID
           , ITF.IMPAIRMENT_ID
           , ITF.BOOK_TYPE_CODE
           , ITF.ASSET_ID
           , ITF.CASH_GENERATING_UNIT_ID
           , ITF.NET_BOOK_VALUE
           , ITF.NET_SELLING_PRICE
           , ITF.VALUE_IN_USE
           , ITF.IMPAIRMENT_AMOUNT
           , ITF.YTD_IMPAIRMENT
           , ITF.impairment_reserve
           , ITF.GOODWILL_ASSET_FLAG
           , NVL(ITF.DEPRN_RUN_DATE,sysdate) -- bug #6658765
           , NVL(ITF.DEPRN_AMOUNT,0) -- bug #6658765
           , NVL(ITF.YTD_DEPRN,0) -- bug #6658765
           , NVL(ITF.DEPRN_RESERVE,0) -- bug #6658765
           , ITF.ADJUSTED_COST
           , ITF.BONUS_RATE
           , ITF.LTD_PRODUCTION
           , ITF.PERIOD_COUNTER
           , ITF.PRODUCTION
           , ITF.REVAL_AMORTIZATION
           , ITF.REVAL_AMORTIZATION_BASIS
           , ITF.REVAL_DEPRN_EXPENSE
           , NVL(ITF.REVAL_RESERVE,0)
           , ITF.YTD_PRODUCTION
           , ITF.YTD_REVAL_DEPRN_EXPENSE
           , ITF.PRIOR_FY_EXPENSE
           , ITF.BONUS_DEPRN_AMOUNT
           , ITF.BONUS_YTD_DEPRN
           , ITF.BONUS_DEPRN_RESERVE
           , ITF.PRIOR_FY_BONUS_EXPENSE
           , ITF.DEPRN_OVERRIDE_FLAG
           , ITF.SYSTEM_DEPRN_AMOUNT
           , ITF.SYSTEM_BONUS_DEPRN_AMOUNT
           , nvl(ITF.DEPRN_ADJUSTMENT_AMOUNT, 0)
           , nvl(ITF.BONUS_DEPRN_ADJUSTMENT_AMOUNT, 0)
           , ITF.COST
           , ITF.CREATION_DATE
           , ITF.CREATED_BY
           , ITF.CURRENT_UNITS
           , ITF.CATEGORY_ID
           , ITF.IMPAIRMENT_DATE
           , ITF.PERIOD_OF_ADDITION_FLAG
           , nvl(ITF.REVAL_RESERVE_ADJ_AMOUNT, 0)
           , ITF.RATE_ADJUSTMENT_FACTOR
           , ITF.FORMULA_FACTOR
           , ITF.EOFY_RESERVE
           , ITF.CAPITAL_ADJUSTMENT -- Start of Bug 6666666
           , ITF.GENERAL_FUND
           , ITF.IMPAIR_CLASS
           , ITF.IMPAIR_LOSS_ACCT
           , ITF.SPLIT_IMPAIR_FLAG
           , ITF.SPLIT1_IMPAIR_CLASS
           , ITF.SPLIT1_LOSS_AMOUNT
           , ITF.SPLIT1_REVAL_RESERVE
           , ITF.SPLIT1_PERCENT
           , ITF.SPLIT1_LOSS_ACCT
           , ITF.SPLIT2_IMPAIR_CLASS
           , ITF.SPLIT2_LOSS_AMOUNT
           , ITF.SPLIT2_REVAL_RESERVE
           , ITF.SPLIT2_PERCENT
           , ITF.SPLIT2_LOSS_ACCT
           , ITF.SPLIT3_IMPAIR_CLASS
           , ITF.SPLIT3_LOSS_AMOUNT
           , ITF.SPLIT3_REVAL_RESERVE
           , ITF.SPLIT3_PERCENT
           , ITF.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
           , nvl(ITF.ALLOWED_DEPRN_LIMIT_AMOUNT,0)
      from   FA_ITF_IMPAIRMENTS ITF
           , FA_IMPAIRMENTS IMP
      where  ITF.WORKER_ID = p_worker_id
      and    ITF.BOOK_TYPE_CODE = p_book_type_code
      and    IMP.REQUEST_ID = p_request_id
      and    IMP.BOOK_TYPE_CODE = p_book_type_code
      and    IMP.IMPAIRMENT_ID = ITF.IMPAIRMENT_ID
      and    IMP.STATUS = l_mode
      and    (IMP.IMPAIRMENT_AMOUNT <> 0 AND IMP.NET_BOOK_VALUE <> 0) -- Bug# 7000391
--      and    ITF.PERIOD_COUNTER = p_period_rec.period_counter
      ;

   CURSOR c_mc_get_itf is
      select ITF.REQUEST_ID
           , ITF.IMPAIRMENT_ID
           , ITF.BOOK_TYPE_CODE
           , ITF.ASSET_ID
           , ITF.CASH_GENERATING_UNIT_ID
           , ITF.NET_BOOK_VALUE
           , ITF.NET_SELLING_PRICE
           , ITF.VALUE_IN_USE
           , ITF.IMPAIRMENT_AMOUNT
           , ITF.YTD_IMPAIRMENT
           , ITF.impairment_reserve
           , ITF.GOODWILL_ASSET_FLAG
           , NVL(ITF.DEPRN_RUN_DATE,sysdate) -- Bug #6658765
           , NVL(ITF.DEPRN_AMOUNT,0) -- Bug #6658765
           , NVL(ITF.YTD_DEPRN,0) -- Bug #6658765
           , NVL(ITF.DEPRN_RESERVE,0) -- Bug #6658765
           , ITF.ADJUSTED_COST
           , ITF.BONUS_RATE
           , ITF.LTD_PRODUCTION
           , ITF.PERIOD_COUNTER
           , ITF.PRODUCTION
           , ITF.REVAL_AMORTIZATION
           , ITF.REVAL_AMORTIZATION_BASIS
           , ITF.REVAL_DEPRN_EXPENSE
           , NVL(ITF.REVAL_RESERVE,0)
           , ITF.YTD_PRODUCTION
           , ITF.YTD_REVAL_DEPRN_EXPENSE
           , ITF.PRIOR_FY_EXPENSE
           , ITF.BONUS_DEPRN_AMOUNT
           , ITF.BONUS_YTD_DEPRN
           , ITF.BONUS_DEPRN_RESERVE
           , ITF.PRIOR_FY_BONUS_EXPENSE
           , ITF.DEPRN_OVERRIDE_FLAG
           , ITF.SYSTEM_DEPRN_AMOUNT
           , ITF.SYSTEM_BONUS_DEPRN_AMOUNT
           , nvl(ITF.DEPRN_ADJUSTMENT_AMOUNT, 0)
           , nvl(ITF.BONUS_DEPRN_ADJUSTMENT_AMOUNT, 0)
           , ITF.COST
           , ITF.CREATION_DATE
           , ITF.CREATED_BY
           , ITF.CURRENT_UNITS
           , ITF.CATEGORY_ID
           , ITF.IMPAIRMENT_DATE
           , ITF.PERIOD_OF_ADDITION_FLAG
           , nvl(ITF.REVAL_RESERVE_ADJ_AMOUNT, 0)
           , ITF.RATE_ADJUSTMENT_FACTOR
           , ITF.FORMULA_FACTOR
           , ITF.EOFY_RESERVE
           , ITF.CAPITAL_ADJUSTMENT -- Start of Bug 6666666
           , ITF.GENERAL_FUND
           , ITF.IMPAIR_CLASS
           , ITF.IMPAIR_LOSS_ACCT
           , ITF.SPLIT_IMPAIR_FLAG
           , ITF.SPLIT1_IMPAIR_CLASS
           , ITF.SPLIT1_LOSS_AMOUNT
           , ITF.SPLIT1_REVAL_RESERVE
           , ITF.SPLIT1_PERCENT
           , ITF.SPLIT1_LOSS_ACCT
           , ITF.SPLIT2_IMPAIR_CLASS
           , ITF.SPLIT2_LOSS_AMOUNT
           , ITF.SPLIT2_REVAL_RESERVE
           , ITF.SPLIT2_PERCENT
           , ITF.SPLIT2_LOSS_ACCT
           , ITF.SPLIT3_IMPAIR_CLASS
           , ITF.SPLIT3_LOSS_AMOUNT
           , ITF.SPLIT3_REVAL_RESERVE
           , ITF.SPLIT3_PERCENT
           , ITF.SPLIT3_LOSS_ACCT       -- End of Bug 6666666
           , nvl(ITF.ALLOWED_DEPRN_LIMIT_AMOUNT,0)
      from   FA_MC_ITF_IMPAIRMENTS ITF
           , FA_MC_IMPAIRMENTS IMP
      where  ITF.WORKER_ID = p_worker_id
      and    ITF.BOOK_TYPE_CODE = p_book_type_code
      and    ITF.SET_OF_BOOKS_ID = p_set_of_books_id
      and    IMP.REQUEST_ID = p_request_id
      and    IMP.BOOK_TYPE_CODE = p_book_type_code
      and    IMP.IMPAIRMENT_ID = ITF.IMPAIRMENT_ID
      and    IMP.STATUS = l_mode
      and    IMP.SET_OF_BOOKS_ID = p_set_of_books_id
      and    (IMP.IMPAIRMENT_AMOUNT <> 0 AND IMP.NET_BOOK_VALUE <> 0) -- Bug# 7000391
--      and    ITF.PERIOD_COUNTER = p_period_rec.period_counter
      ;


   l_asset_hdr_rec   fa_api_types.asset_hdr_rec_type;

   CURSOR c_get_dists IS
      select th.transaction_header_id
           , th.transaction_date_entered
           , th.date_effective
           , th.last_update_date
           , th.last_updated_by
           , th.transaction_subtype
           , th.transaction_key
           , th.amortization_start_date
           , th.calling_interface
           , decode(dt.transaction_header_id_out, null, null, dt.distribution_id)
           , dt.code_combination_id
           , dt.location_id
           , dt.assigned_to
           , dt.transaction_units
        FROM    fa_transaction_headers th
              , fa_distribution_history dt
        WHERE   th.book_type_code = p_book_type_code
        AND     th.asset_id = l_asset_hdr_rec.asset_id
        AND     dt.asset_id = l_asset_hdr_rec.asset_id
        AND     dt.book_type_code = p_book_type_code
        AND     (dt.transaction_header_id_in = th.transaction_header_id or
                 dt.transaction_header_id_out = th.transaction_header_id)
        AND     th.transaction_type_code = 'TRANSFER'
        AND     th.transaction_date_entered <
                        p_period_rec.calendar_period_open_date
        AND     th.date_effective >= p_period_rec.period_open_date;



   t_request_id                    tab_num15_type;
   t_impairment_id                 tab_num15_type;
   t_book_type_code                tab_char15_type;
   t_asset_id                      tab_num15_type;
   t_cash_generating_unit_id       tab_num15_type;
   t_net_book_value                tab_num_type;
   t_net_selling_price             tab_num_type;
   t_value_in_use                  tab_num_type;
   t_impairment_amount             tab_num_type;
   t_ytd_impairment                tab_num_type;
   t_impairment_reserve                tab_num_type;
   t_goodwill_asset_flag           tab_char1_type;
   t_deprn_run_date                tab_date_type;
   t_deprn_amount                  tab_num_type;
   t_ytd_deprn                     tab_num_type;
   t_deprn_reserve                 tab_num_type;
   t_adjusted_cost                 tab_num_type;
   t_bonus_rate                    tab_num_type;
   t_ltd_production                tab_num_type;
   t_period_counter                tab_num15_type;
   t_production                    tab_num_type;
   t_reval_amortization            tab_num_type;
   t_reval_amortization_basis      tab_num_type;
   t_reval_deprn_expense           tab_num_type;
   t_reval_reserve                 tab_num_type;
   t_ytd_production                tab_num_type;
   t_ytd_reval_deprn_expense       tab_num_type;
   t_prior_fy_expense              tab_num_type;
   t_bonus_deprn_amount            tab_num_type;
   t_bonus_ytd_deprn               tab_num_type;
   t_bonus_deprn_reserve           tab_num_type;
   t_prior_fy_bonus_expense        tab_num_type;
   t_deprn_override_flag           tab_char1_type;
   t_system_deprn_amount           tab_num_type;
   t_system_bonus_deprn_amount     tab_num_type;
   t_deprn_adjustment_amount       tab_num_type;
   t_bonus_deprn_adj_amount        tab_num_type;
   t_cost                          tab_num_type;
   t_creation_date                 tab_date_type;
   t_created_by                    tab_num15_type;
   t_current_units                 tab_num_type;
   t_category_id                   tab_num15_type;
   t_impairment_date               tab_date_type;
   t_new_adj_cost                  tab_num_type;
   t_period_of_addition_flag       tab_char1_type;
   t_reval_reserve_adj_amount      tab_num_type;
   t_capital_adjustment            tab_num_type;  -- Start of Bug 6666666
   t_general_fund                  tab_num_type;
   t_impair_class                  tab_char3_type;
   t_impair_loss_acct              tab_char30_type;
   t_split_impair_flag             tab_char1_type;
   t_split1_impair_class           tab_char3_type;
   t_split1_loss_amount            tab_num_type;
   t_split1_reval_reserve          tab_num_type;
   t_split1_percent                tab_num_type;
   t_split1_loss_acct              tab_char30_type;
   t_split2_impair_class           tab_char3_type;
   t_split2_loss_amount            tab_num_type;
   t_split2_reval_reserve          tab_num_type;
   t_split2_percent                tab_num_type;
   t_split2_loss_acct              tab_char30_type;
   t_split3_impair_class           tab_char3_type;
   t_split3_loss_amount            tab_num_type;
   t_split3_reval_reserve          tab_num_type;
   t_split3_percent                tab_num_type;
   t_split3_loss_acct              tab_char30_type; -- End of Bug 6666666
   t_allowed_deprn_limit_amount    tab_num_type;


   t_thid                          FA_IMPAIRMENT_DELETE_PVT.tab_num15_type; /* 8394781 */
   t_old_thid                      tab_num15_type;
   t_new_raf                       tab_num_type;
   t_new_formula_factor            tab_num_type;
   t_raf                           tab_num_type;
   t_formula_factor                tab_num_type;
   t_eofy_reserve                  tab_num_type;

   t_dist_thid                tab_num15_type;
   t_transaction_date_entered tab_date_type;
   t_date_effective           tab_date_type;
   t_last_update_date         tab_date_type;
   t_last_updated_by          tab_num15_type;
   t_transaction_subtype      tab_char15_type;
   t_transaction_key          tab_char3_type;
   t_amortization_start_date  tab_date_type;
   t_calling_interface        tab_char30_type;
   t_dist_id                  tab_num15_type;
   t_ccid                     tab_num15_type;
   t_loc_id                   tab_num15_type;
   t_assign_to                tab_num15_type;
   t_trx_units                tab_num_type;

   t_rate_in_use              tab_num_type; --9781938 /*changed these variable to table type*/
   t_nbv_at_switch            tab_num_type; --9781938 /*changed these variable to table type*/

   t_period_counter_fully_rsv     tab_num_type; --9781938 /*changed these variable to table type*/
   t_period_counter_life_complete tab_num_type; --9781938 /*changed these variable to table type*/
   t_period_counter_fully_ext     tab_num_type;  --9786860
   l_adj             FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

   l_trans_rec       fa_api_types.trans_rec_type;
   l_asset_type_rec  fa_api_types.asset_type_rec_type;
   l_asset_fin_rec   fa_api_types.asset_fin_rec_type;
   l_asset_deprn_rec fa_api_types.asset_deprn_rec_type;
   l_asset_desc_rec  fa_api_types.asset_desc_rec_type;
   l_asset_cat_rec   fa_api_types.asset_cat_rec_type;
   l_asset_dist_tbl  fa_api_types.asset_dist_tbl_type;

   l_period_counter  number(15); -- store period counter impaired

   l_limit           binary_integer := 200;  -- limit constant for C1 cursor


   pos_err           exception;
   x_return_status number := 0;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Process Post', 'BEGIN', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'worker id', p_worker_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'book type code', p_book_type_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'period counter', p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'request_id', p_request_id, p_log_level_rec => p_log_level_rec);
   end if;

   -- Initializing common variables
   l_adj.book_type_code          := p_book_type_code;
   l_adj.period_counter_created  := p_period_rec.period_counter;
   l_adj.period_counter_adjusted := p_period_rec.period_counter;
   l_adj.selection_mode          := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_retid         := 0;
   l_adj.leveling_flag           := TRUE;
   l_adj.flush_adj_flag          := TRUE; --FALSE;
   l_adj.gen_ccid_flag           := TRUE;
   l_adj.track_member_flag       := null;
   l_adj.set_of_books_id         := p_set_of_books_id; -- RER12 MRC changes
   l_adj.mrc_sob_type_code       := p_mrc_sob_type_code; --8666930
   l_asset_hdr_rec.book_type_code    := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id   := p_set_of_books_id;

   /*Bug#9182681 - to update request_id,for asset impairment report */
   if (p_mrc_sob_type_code = 'R') then
      UPDATE FA_MC_ITF_IMPAIRMENTS
        set  REQUEST_ID = p_request_id
      WHERE  WORKER_ID = p_worker_id
      AND    BOOK_TYPE_CODE = p_book_type_code
      AND    SET_OF_BOOKS_ID = p_set_of_books_id
      AND    IMPAIRMENT_ID in
             (SELECT IMPAIRMENT_ID
              FROM   FA_MC_IMPAIRMENTS IMP
              WHERE  IMP.BOOK_TYPE_CODE = p_book_type_code
              AND    IMP.STATUS = l_mode
              AND    IMP.SET_OF_BOOKS_ID = p_set_of_books_id
              AND    (IMP.IMPAIRMENT_AMOUNT <> 0 AND IMP.NET_BOOK_VALUE <> 0));
   else
      UPDATE FA_ITF_IMPAIRMENTS
        set  REQUEST_ID = p_request_id
      WHERE  WORKER_ID = p_worker_id
      AND    BOOK_TYPE_CODE = p_book_type_code
      AND    IMPAIRMENT_ID in
             (SELECT IMPAIRMENT_ID
              FROM   FA_IMPAIRMENTS IMP
              WHERE  IMP.BOOK_TYPE_CODE = p_book_type_code
              AND    IMP.STATUS = l_mode
              AND    (IMP.IMPAIRMENT_AMOUNT <> 0 AND IMP.NET_BOOK_VALUE <> 0));
   end if;

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_mc_get_itf;
   else
      OPEN c_get_itf;
   end if;
   --
   -- Outer Loop
   LOOP
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Inside of ', 'Outer Loop', p_log_level_rec => p_log_level_rec);
      end if;

      t_thid.delete;
      t_old_thid.delete;

      if (p_mrc_sob_type_code = 'R') then
         FETCH c_mc_get_itf BULK COLLECT INTO t_request_id
                                            , t_impairment_id
                                            , t_book_type_code
                                            , t_asset_id
                                            , t_cash_generating_unit_id
                                            , t_net_book_value
                                            , t_net_selling_price
                                            , t_value_in_use
                                            , t_impairment_amount
                                            , t_ytd_impairment
                                            , t_impairment_reserve
                                            , t_goodwill_asset_flag
                                            , t_deprn_run_date
                                            , t_deprn_amount
                                            , t_ytd_deprn
                                            , t_deprn_reserve
                                            , t_adjusted_cost
                                            , t_bonus_rate
                                            , t_ltd_production
                                            , t_period_counter
                                            , t_production
                                            , t_reval_amortization
                                            , t_reval_amortization_basis
                                            , t_reval_deprn_expense
                                            , t_reval_reserve
                                            , t_ytd_production
                                            , t_ytd_reval_deprn_expense
                                            , t_prior_fy_expense
                                            , t_bonus_deprn_amount
                                            , t_bonus_ytd_deprn
                                            , t_bonus_deprn_reserve
                                            , t_prior_fy_bonus_expense
                                            , t_deprn_override_flag
                                            , t_system_deprn_amount
                                            , t_system_bonus_deprn_amount
                                            , t_deprn_adjustment_amount
                                            , t_bonus_deprn_adj_amount
                                            , t_cost
                                            , t_creation_date
                                            , t_created_by
                                            , t_current_units
                                            , t_category_id
                                            , t_impairment_date
                                            , t_period_of_addition_flag
                                            , t_reval_reserve_adj_amount
                                            , t_raf
                                            , t_formula_factor
                                            , t_eofy_reserve
                                            , t_capital_adjustment -- Start of Bug 6666666
                                            , t_general_fund
                                            , t_impair_class
                                            , t_impair_loss_acct
                                            , t_split_impair_flag
                                            , t_split1_impair_class
                                            , t_split1_loss_amount
                                            , t_split1_reval_reserve
                                            , t_split1_percent
                                            , t_split1_loss_acct
                                            , t_split2_impair_class
                                            , t_split2_loss_amount
                                            , t_split2_reval_reserve
                                            , t_split2_percent
                                            , t_split2_loss_acct
                                            , t_split3_impair_class
                                            , t_split3_loss_amount
                                            , t_split3_reval_reserve
                                            , t_split3_percent
                                            , t_split3_loss_acct -- End of Bug 6666666
                                            , t_allowed_deprn_limit_amount
                                            LIMIT l_limit;


      else
         FETCH c_get_itf BULK COLLECT INTO t_request_id
                                         , t_impairment_id
                                         , t_book_type_code
                                         , t_asset_id
                                         , t_cash_generating_unit_id
                                         , t_net_book_value
                                         , t_net_selling_price
                                         , t_value_in_use
                                         , t_impairment_amount
                                         , t_ytd_impairment
                                         , t_impairment_reserve
                                         , t_goodwill_asset_flag
                                         , t_deprn_run_date
                                         , t_deprn_amount
                                         , t_ytd_deprn
                                         , t_deprn_reserve
                                         , t_adjusted_cost
                                         , t_bonus_rate
                                         , t_ltd_production
                                         , t_period_counter
                                         , t_production
                                         , t_reval_amortization
                                         , t_reval_amortization_basis
                                         , t_reval_deprn_expense
                                         , t_reval_reserve
                                         , t_ytd_production
                                         , t_ytd_reval_deprn_expense
                                         , t_prior_fy_expense
                                         , t_bonus_deprn_amount
                                         , t_bonus_ytd_deprn
                                         , t_bonus_deprn_reserve
                                         , t_prior_fy_bonus_expense
                                         , t_deprn_override_flag
                                         , t_system_deprn_amount
                                         , t_system_bonus_deprn_amount
                                         , t_deprn_adjustment_amount
                                         , t_bonus_deprn_adj_amount
                                         , t_cost
                                         , t_creation_date
                                         , t_created_by
                                         , t_current_units
                                         , t_category_id
                                         , t_impairment_date
                                         , t_period_of_addition_flag
                                         , t_reval_reserve_adj_amount
                                         , t_raf
                                         , t_formula_factor
                                         , t_eofy_reserve
                                         , t_capital_adjustment -- Start of Bug 6666666
                                         , t_general_fund
                                         , t_impair_class
                                         , t_impair_loss_acct
                                         , t_split_impair_flag
                                         , t_split1_impair_class
                                         , t_split1_loss_amount
                                         , t_split1_reval_reserve
                                         , t_split1_percent
                                         , t_split1_loss_acct
                                         , t_split2_impair_class
                                         , t_split2_loss_amount
                                         , t_split2_reval_reserve
                                         , t_split2_percent
                                         , t_split2_loss_acct
                                         , t_split3_impair_class
                                         , t_split3_loss_amount
                                         , t_split3_reval_reserve
                                         , t_split3_percent
                                         , t_split3_loss_acct -- End of Bug 6666666
                                         , t_allowed_deprn_limit_amount
                                         LIMIT l_limit;

         end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'t_request_id.count', t_request_id.count, p_log_level_rec => p_log_level_rec);

         for i in 1..t_request_id.count loop
            fa_debug_pkg.add(l_calling_fn,'t_impairment_id', t_impairment_id(i));
            fa_debug_pkg.add(l_calling_fn,'t_asset_id', t_asset_id(i));
         end loop;
      end if;

      if (t_request_id.count = 0) then
         if (p_mrc_sob_type_code = 'R') then
            CLOSE c_mc_get_itf;
         else
            CLOSE c_get_itf;
         end if;
         EXIT;
      end if;

      l_period_counter := t_period_counter(1);

      -- Insert th
      if (p_mrc_sob_type_code = 'R') then
         -- select impairment thid of primary book
         -- Following update is to get thid from primary book
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Getting Records from  ', 'FA_TRANSACTION_HEADERS', p_log_level_rec => p_log_level_rec);
         end if;

         FORALL i in 1..t_request_id.count
            UPDATE FA_TRANSACTION_HEADERS
            SET    ATTRIBUTE15 = ATTRIBUTE15
            WHERE  ASSET_ID = t_asset_id(i)
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_TYPE_CODE = decode(G_release,'11',decode(t_period_of_addition_flag(i), 'Y', 'ADDITION', 'ADJUSTMENT'),'ADJUSTMENT')
            AND    TRANSACTION_DATE_ENTERED = t_impairment_date(i)
            AND    TRANSACTION_SUBTYPE = 'AMORTIZED'
            AND    TRANSACTION_KEY = 'IM'
            AND    CALLING_INTERFACE = 'FAPIMP'
            AND    DATE_EFFECTIVE = t_creation_date(i)
            RETURNING TRANSACTION_HEADER_ID BULK COLLECT INTO t_thid;


      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Insert into ', 'FA_TRANSACTION_HEADERS', p_log_level_rec => p_log_level_rec);
         end if;

         if G_release = 11 then
            FORALL i in 1..t_request_id.count
               UPDATE FA_TRANSACTION_HEADERS
               SET    TRANSACTION_TYPE_CODE = 'ADDITION/VOID'
               WHERE  t_period_of_addition_flag(i) = 'Y'
               AND    asset_id = t_asset_id(i)
               AND    book_type_code = p_book_type_code
               AND    transaction_type_code = 'ADDITION';
         end if;

         FORALL i in 1..t_request_id.count
            INSERT INTO FA_TRANSACTION_HEADERS(
                            TRANSACTION_HEADER_ID
                          , BOOK_TYPE_CODE
                          , ASSET_ID
                          , TRANSACTION_TYPE_CODE
                          , TRANSACTION_DATE_ENTERED
                          , DATE_EFFECTIVE
                          , LAST_UPDATE_DATE
                          , LAST_UPDATED_BY
                          , TRANSACTION_SUBTYPE
                          , TRANSACTION_KEY
                          , AMORTIZATION_START_DATE
                          , CALLING_INTERFACE
                          , MASS_TRANSACTION_ID
            ) VALUES (
                            FA_TRANSACTION_HEADERS_S.NEXTVAL
                          , p_book_type_code
                          , t_asset_id(i)
                          , decode(G_release,'11',decode(t_period_of_addition_flag(i), 'Y', 'ADDITION', 'ADJUSTMENT'),'ADJUSTMENT')
                          , t_impairment_date(i)
                          , t_creation_date(i)
                          , t_creation_date(i)
                          , t_created_by(i)
                          , 'AMORTIZED'
                          , 'IM'
                          , t_impairment_date(i)
                          , 'FAPIMP'
                          , t_impairment_id(i)
            ) RETURNING transaction_header_id BULK COLLECT INTO t_thid;
      end if;

      /*8394781 - To create event */
      if G_release <> 11 and p_mrc_sob_type_code = 'P' then
         if not FA_IMPAIRMENT_DELETE_PVT.process_impair_event(
              p_book_type_code    => p_book_type_code,
              p_mrc_sob_type_code => p_mrc_sob_type_code,
              p_set_of_books_id   => p_set_of_books_id,
              p_calling_fn        => l_calling_fn ,
              p_thid              => t_thid,
              p_log_level_rec     => p_log_level_rec      ) then

             raise pos_err;
         end if;
      end if;

      -- Insert DS only if this is cur per imp
      if (p_period_rec.period_counter = l_period_counter) then

         if (p_mrc_sob_type_code = 'R') then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Insert into ', 'FA_DEPRN_SUMMARY_MRC_V', p_log_level_rec => p_log_level_rec);
            end if;

            -- Bug 6666666 : If SORP is enabled, insert values for capital adj
            --               and general fund
            if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
                FORALL i in 1..t_request_id.count
                   INSERT INTO FA_MC_DEPRN_SUMMARY( SET_OF_BOOKS_ID
                                                     , BOOK_TYPE_CODE
                                                     , ASSET_ID
                                                     , PERIOD_COUNTER
                                                     , DEPRN_RUN_DATE
                                                     , DEPRN_AMOUNT
                                                     , YTD_DEPRN
                                                     , DEPRN_RESERVE
                                                     , DEPRN_SOURCE_CODE
                                                     , ADJUSTED_COST
                                                     , BONUS_RATE
                                                     , REVAL_AMORTIZATION
                                                     , REVAL_DEPRN_EXPENSE
                                                     , REVAL_RESERVE
                                                     , YTD_REVAL_DEPRN_EXPENSE
                                                     , PRODUCTION
                                                     , YTD_PRODUCTION
                                                     , LTD_PRODUCTION
                                                     , REVAL_AMORTIZATION_BASIS
                                                     , PRIOR_FY_EXPENSE
                                                     , BONUS_DEPRN_AMOUNT
                                                     , BONUS_YTD_DEPRN
                                                     , BONUS_DEPRN_RESERVE
                                                     , BONUS_DEPRN_ADJUSTMENT_AMOUNT
                                                     , PRIOR_FY_BONUS_EXPENSE
                                                     , DEPRN_OVERRIDE_FLAG
                                                     , SYSTEM_DEPRN_AMOUNT
                                                     , SYSTEM_BONUS_DEPRN_AMOUNT
                                                     , IMPAIRMENT_AMOUNT
                                                     , YTD_IMPAIRMENT
                                                     , IMPAIRMENT_RESERVE
                                                     , CAPITAL_ADJUSTMENT  -- Bug 6666666
                                                     , GENERAL_FUND        -- Bug 6666666
                                                     , DEPRN_ADJUSTMENT_AMOUNT
                   ) VALUES ( p_set_of_books_id
                            , p_book_type_code               -- BOOK_TYPE_CODE
                            , t_asset_id(i)                  -- ASSET_ID
                            , p_period_rec.period_counter    -- PERIOD_COUNTER
                            , t_creation_date(i)             -- DEPRN_RUN_DATE
                            , t_deprn_amount(i)              -- DEPRN_AMOUNT
                            , t_ytd_deprn(i)                 -- YTD_DEPRN
                            , t_deprn_reserve(i)             -- DEPRN_RESERVE
                            , 'DEPRN'                        -- DEPRN_SOURCE_CODE
                            , t_adjusted_cost(i)             -- ADJUSTED_COST
                            , t_bonus_rate(i)                -- BONUS_RATE
                            , t_reval_amortization(i)        -- REVAL_AMORTIZATION
                            , t_reval_deprn_expense(i)       -- REVAL_DEPRN_EXPENSE
                            , t_reval_reserve(i)             -- REVAL_RESERVE
                            , t_ytd_reval_deprn_expense(i)   -- YTD_REVAL_DEPRN_EXPENSE
                            , t_production(i)                -- PRODUCTION
                            , t_ytd_production(i)            -- YTD_PRODUCTION
                            , t_ltd_production(i)            -- LTD_PRODUCTION
                            , t_reval_amortization_basis(i)  -- REVAL_AMORTIZATION_BASIS
                            , t_prior_fy_expense(i)          -- PRIOR_FY_EXPENSE
                            , t_bonus_deprn_amount(i)        -- BONUS_DEPRN_AMOUNT
                            , t_bonus_ytd_deprn(i)           -- BONUS_YTD_DEPRN
                            , t_bonus_deprn_reserve(i)       -- BONUS_DEPRN_RESERVE
                            , t_bonus_deprn_adj_amount(i)    -- BONUS_DEPRN_ADJUSTMENT_AMOUNT
                            , t_prior_fy_bonus_expense(i)    -- PRIOR_FY_BONUS_EXPENSE
                            , t_deprn_override_flag(i)       -- DEPRN_OVERRIDE_FLAG
                            , t_system_deprn_amount(i)       -- SYSTEM_DEPRN_AMOUNT
                            , t_system_bonus_deprn_amount(i) -- SYSTEM_BONUS_DEPRN_AMOUNT
                            , t_impairment_amount(i)         -- IMPAIRMENT_AMOUNT
                            , t_ytd_impairment(i)            -- YTD_IMPAIRMENT
                            , t_impairment_reserve(i)        -- impairment_reserve
                            , t_capital_adjustment(i)
                              - nvl(t_reval_amortization(i),0)
                              + nvl(t_deprn_amount(i),0)     -- Capital Adjustment  -- Bug 6666666
                            , t_general_fund(i)
                              + nvl(t_deprn_amount(i),0)     -- General Fund        -- Bug 6666666
                            , t_deprn_adjustment_amount(i)
                   );
               else -- If SORP is not enabled
                FORALL i in 1..t_request_id.count
                   INSERT INTO FA_MC_DEPRN_SUMMARY( SET_OF_BOOKS_ID
                                                     , BOOK_TYPE_CODE
                                                     , ASSET_ID
                                                     , PERIOD_COUNTER
                                                     , DEPRN_RUN_DATE
                                                     , DEPRN_AMOUNT
                                                     , YTD_DEPRN
                                                     , DEPRN_RESERVE
                                                     , DEPRN_SOURCE_CODE
                                                     , ADJUSTED_COST
                                                     , BONUS_RATE
                                                     , REVAL_AMORTIZATION
                                                     , REVAL_DEPRN_EXPENSE
                                                     , REVAL_RESERVE
                                                     , YTD_REVAL_DEPRN_EXPENSE
                                                     , PRODUCTION
                                                     , YTD_PRODUCTION
                                                     , LTD_PRODUCTION
                                                     , REVAL_AMORTIZATION_BASIS
                                                     , PRIOR_FY_EXPENSE
                                                     , BONUS_DEPRN_AMOUNT
                                                     , BONUS_YTD_DEPRN
                                                     , BONUS_DEPRN_RESERVE
                                                     , BONUS_DEPRN_ADJUSTMENT_AMOUNT
                                                     , PRIOR_FY_BONUS_EXPENSE
                                                     , DEPRN_OVERRIDE_FLAG
                                                     , SYSTEM_DEPRN_AMOUNT
                                                     , SYSTEM_BONUS_DEPRN_AMOUNT
                                                     , IMPAIRMENT_AMOUNT
                                                     , YTD_IMPAIRMENT
                                                     , IMPAIRMENT_RESERVE
                                                     , CAPITAL_ADJUSTMENT  -- Bug 6666666
                                                     , GENERAL_FUND        -- Bug 6666666
                                                     , DEPRN_ADJUSTMENT_AMOUNT
                   ) VALUES ( p_set_of_books_id
                            , p_book_type_code               -- BOOK_TYPE_CODE
                            , t_asset_id(i)                  -- ASSET_ID
                            , p_period_rec.period_counter    -- PERIOD_COUNTER
                            , t_creation_date(i)             -- DEPRN_RUN_DATE
                            , t_deprn_amount(i)              -- DEPRN_AMOUNT
                            , t_ytd_deprn(i)                 -- YTD_DEPRN
                            , t_deprn_reserve(i)             -- DEPRN_RESERVE
                            , 'DEPRN'                        -- DEPRN_SOURCE_CODE
                            , t_adjusted_cost(i)             -- ADJUSTED_COST
                            , t_bonus_rate(i)                -- BONUS_RATE
                            , t_reval_amortization(i)        -- REVAL_AMORTIZATION
                            , t_reval_deprn_expense(i)       -- REVAL_DEPRN_EXPENSE
                            , t_reval_reserve(i)             -- REVAL_RESERVE
                            , t_ytd_reval_deprn_expense(i)   -- YTD_REVAL_DEPRN_EXPENSE
                            , t_production(i)                -- PRODUCTION
                            , t_ytd_production(i)            -- YTD_PRODUCTION
                            , t_ltd_production(i)            -- LTD_PRODUCTION
                            , t_reval_amortization_basis(i)  -- REVAL_AMORTIZATION_BASIS
                            , t_prior_fy_expense(i)          -- PRIOR_FY_EXPENSE
                            , t_bonus_deprn_amount(i)        -- BONUS_DEPRN_AMOUNT
                            , t_bonus_ytd_deprn(i)           -- BONUS_YTD_DEPRN
                            , t_bonus_deprn_reserve(i)       -- BONUS_DEPRN_RESERVE
                            , t_bonus_deprn_adj_amount(i)    -- BONUS_DEPRN_ADJUSTMENT_AMOUNT
                            , t_prior_fy_bonus_expense(i)    -- PRIOR_FY_BONUS_EXPENSE
                            , t_deprn_override_flag(i)       -- DEPRN_OVERRIDE_FLAG
                            , t_system_deprn_amount(i)       -- SYSTEM_DEPRN_AMOUNT
                            , t_system_bonus_deprn_amount(i) -- SYSTEM_BONUS_DEPRN_AMOUNT
                            , t_impairment_amount(i)         -- IMPAIRMENT_AMOUNT
                            , t_ytd_impairment(i)            -- YTD_IMPAIRMENT
                            , t_impairment_reserve(i)        -- impairment_reserve
                            , NULL                           -- Capital Adjustment  -- Bug 6666666
                            , NULL                           -- General Fund        -- Bug 6666666
                            , t_deprn_adjustment_amount(i)
                   );
               end if; -- End IF SORP is enabled



         else

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Insert into ', 'FA_DEPRN_SUMMARY', p_log_level_rec => p_log_level_rec);
            end if;

            -- Bug 6666666 : If SORP is enabled, insert values for capital adj
            --               and general fund
            if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
                FORALL i in 1..t_request_id.count
                   INSERT INTO FA_DEPRN_SUMMARY( BOOK_TYPE_CODE
                                               , ASSET_ID
                                               , PERIOD_COUNTER
                                               , DEPRN_RUN_DATE
                                               , DEPRN_AMOUNT
                                               , YTD_DEPRN
                                               , DEPRN_RESERVE
                                               , DEPRN_SOURCE_CODE
                                               , ADJUSTED_COST
                                               , BONUS_RATE
                                               , REVAL_AMORTIZATION
                                               , REVAL_DEPRN_EXPENSE
                                               , REVAL_RESERVE
                                               , YTD_REVAL_DEPRN_EXPENSE
                                               , PRODUCTION
                                               , YTD_PRODUCTION
                                               , LTD_PRODUCTION
                                               , REVAL_AMORTIZATION_BASIS
                                               , PRIOR_FY_EXPENSE
                                               , BONUS_DEPRN_AMOUNT
                                               , BONUS_YTD_DEPRN
                                               , BONUS_DEPRN_RESERVE
                                               , BONUS_DEPRN_ADJUSTMENT_AMOUNT
                                               , PRIOR_FY_BONUS_EXPENSE
                                               , DEPRN_OVERRIDE_FLAG
                                               , SYSTEM_DEPRN_AMOUNT
                                               , SYSTEM_BONUS_DEPRN_AMOUNT
                                               , IMPAIRMENT_AMOUNT
                                               , YTD_IMPAIRMENT
                                               , IMPAIRMENT_RESERVE
                                               , CAPITAL_ADJUSTMENT  -- Bug 6666666
                                               , GENERAL_FUND        -- Bug 6666666
                                               , DEPRN_ADJUSTMENT_AMOUNT
                   ) VALUES ( p_book_type_code               -- BOOK_TYPE_CODE
                            , t_asset_id(i)                  -- ASSET_ID
                            , p_period_rec.period_counter    -- PERIOD_COUNTER
                            , t_creation_date(i)             -- DEPRN_RUN_DATE
                            , t_deprn_amount(i)              -- DEPRN_AMOUNT
                            , t_ytd_deprn(i)                 -- YTD_DEPRN
                            , t_deprn_reserve(i)             -- DEPRN_RESERVE
                            , 'DEPRN'                        -- DEPRN_SOURCE_CODE
                            , t_adjusted_cost(i)             -- ADJUSTED_COST
                            , t_bonus_rate(i)                -- BONUS_RATE
                            , t_reval_amortization(i)        -- REVAL_AMORTIZATION
                            , t_reval_deprn_expense(i)       -- REVAL_DEPRN_EXPENSE
                            , t_reval_reserve(i)             -- REVAL_RESERVE
                            , t_ytd_reval_deprn_expense(i)   -- YTD_REVAL_DEPRN_EXPENSE
                            , t_production(i)                -- PRODUCTION
                            , t_ytd_production(i)            -- YTD_PRODUCTION
                            , t_ltd_production(i)            -- LTD_PRODUCTION
                            , t_reval_amortization_basis(i)  -- REVAL_AMORTIZATION_BASIS
                            , t_prior_fy_expense(i)          -- PRIOR_FY_EXPENSE
                            , t_bonus_deprn_amount(i)        -- BONUS_DEPRN_AMOUNT
                            , t_bonus_ytd_deprn(i)           -- BONUS_YTD_DEPRN
                            , t_bonus_deprn_reserve(i)       -- BONUS_DEPRN_RESERVE
                            , t_bonus_deprn_adj_amount(i)    -- BONUS_DEPRN_ADJUSTMENT_AMOUNT
                            , t_prior_fy_bonus_expense(i)    -- PRIOR_FY_BONUS_EXPENSE
                            , t_deprn_override_flag(i)       -- DEPRN_OVERRIDE_FLAG
                            , t_system_deprn_amount(i)       -- SYSTEM_DEPRN_AMOUNT
                            , t_system_bonus_deprn_amount(i) -- SYSTEM_BONUS_DEPRN_AMOUNT
                            , t_impairment_amount(i)         -- IMPAIRMENT_AMOUNT
                            , t_ytd_impairment(i)            -- YTD_IMPAIRMENT
                            , t_impairment_reserve(i)            -- impairment_reserve
                            , t_capital_adjustment(i)
                              - nvl(t_reval_amortization(i),0)
                              + nvl(t_deprn_amount(i),0)     -- Capital Adjustment  -- Bug 6666666
                            , t_general_fund(i)
                              + nvl(t_deprn_amount(i),0)     -- General Fund        -- Bug 6666666
                            , t_deprn_adjustment_amount(i)
                   );
                   else -- If SORP is not enabled
                   FORALL i in 1..t_request_id.count
                   INSERT INTO FA_DEPRN_SUMMARY( BOOK_TYPE_CODE
                                               , ASSET_ID
                                               , PERIOD_COUNTER
                                               , DEPRN_RUN_DATE
                                               , DEPRN_AMOUNT
                                               , YTD_DEPRN
                                               , DEPRN_RESERVE
                                               , DEPRN_SOURCE_CODE
                                               , ADJUSTED_COST
                                               , BONUS_RATE
                                               , REVAL_AMORTIZATION
                                               , REVAL_DEPRN_EXPENSE
                                               , REVAL_RESERVE
                                               , YTD_REVAL_DEPRN_EXPENSE
                                               , PRODUCTION
                                               , YTD_PRODUCTION
                                               , LTD_PRODUCTION
                                               , REVAL_AMORTIZATION_BASIS
                                               , PRIOR_FY_EXPENSE
                                               , BONUS_DEPRN_AMOUNT
                                               , BONUS_YTD_DEPRN
                                               , BONUS_DEPRN_RESERVE
                                               , BONUS_DEPRN_ADJUSTMENT_AMOUNT
                                               , PRIOR_FY_BONUS_EXPENSE
                                               , DEPRN_OVERRIDE_FLAG
                                               , SYSTEM_DEPRN_AMOUNT
                                               , SYSTEM_BONUS_DEPRN_AMOUNT
                                               , IMPAIRMENT_AMOUNT
                                               , YTD_IMPAIRMENT
                                               , IMPAIRMENT_RESERVE
                                               , CAPITAL_ADJUSTMENT  -- Bug 6666666
                                               , GENERAL_FUND        -- Bug 6666666
                                               , DEPRN_ADJUSTMENT_AMOUNT
                   ) VALUES ( p_book_type_code               -- BOOK_TYPE_CODE
                            , t_asset_id(i)                  -- ASSET_ID
                            , p_period_rec.period_counter    -- PERIOD_COUNTER
                            , t_creation_date(i)             -- DEPRN_RUN_DATE
                            , t_deprn_amount(i)              -- DEPRN_AMOUNT
                            , t_ytd_deprn(i)                 -- YTD_DEPRN
                            , t_deprn_reserve(i)             -- DEPRN_RESERVE
                            , 'DEPRN'                        -- DEPRN_SOURCE_CODE
                            , t_adjusted_cost(i)             -- ADJUSTED_COST
                            , t_bonus_rate(i)                -- BONUS_RATE
                            , t_reval_amortization(i)        -- REVAL_AMORTIZATION
                            , t_reval_deprn_expense(i)       -- REVAL_DEPRN_EXPENSE
                            , t_reval_reserve(i)             -- REVAL_RESERVE
                            , t_ytd_reval_deprn_expense(i)   -- YTD_REVAL_DEPRN_EXPENSE
                            , t_production(i)                -- PRODUCTION
                            , t_ytd_production(i)            -- YTD_PRODUCTION
                            , t_ltd_production(i)            -- LTD_PRODUCTION
                            , t_reval_amortization_basis(i)  -- REVAL_AMORTIZATION_BASIS
                            , t_prior_fy_expense(i)          -- PRIOR_FY_EXPENSE
                            , t_bonus_deprn_amount(i)        -- BONUS_DEPRN_AMOUNT
                            , t_bonus_ytd_deprn(i)           -- BONUS_YTD_DEPRN
                            , t_bonus_deprn_reserve(i)       -- BONUS_DEPRN_RESERVE
                            , t_bonus_deprn_adj_amount(i)    -- BONUS_DEPRN_ADJUSTMENT_AMOUNT
                            , t_prior_fy_bonus_expense(i)    -- PRIOR_FY_BONUS_EXPENSE
                            , t_deprn_override_flag(i)       -- DEPRN_OVERRIDE_FLAG
                            , t_system_deprn_amount(i)       -- SYSTEM_DEPRN_AMOUNT
                            , t_system_bonus_deprn_amount(i) -- SYSTEM_BONUS_DEPRN_AMOUNT
                            , t_impairment_amount(i)         -- IMPAIRMENT_AMOUNT
                            , t_ytd_impairment(i)            -- YTD_IMPAIRMENT
                            , t_impairment_reserve(i)        -- impairment_reserve
                            , NULL                           -- Capital Adjustment  -- Bug 6666666
                            , NULL                           -- General Fund        -- Bug 6666666
                            , t_deprn_adjustment_amount(i)
                   );
               end if; -- End If SORP is enabled
         end if;

      end if; -- (p_period_rec.period_counter = t_period_counter(i))
      --

      FOR i in 1..t_request_id.count LOOP

         l_asset_hdr_rec.asset_id           := t_asset_id(i);
         l_asset_hdr_rec.period_of_addition := t_period_of_addition_flag(i);

         l_adj.asset_id                := l_asset_hdr_rec.asset_id;
         l_adj.transaction_header_id   := t_thid(i);
         l_adj.current_units           := t_current_units(i);
         l_adj.adjustment_amount       := t_impairment_amount(i) + t_reval_reserve_adj_amount(i);
         l_adj.last_update_date        := t_creation_date(i);

         -- Need to skip followings if this is backdated imp
         if (p_period_rec.period_counter = l_period_counter) then

            -- Populate fin rec
            if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_asset_hdr_rec,
                  px_asset_fin_rec        => l_asset_fin_rec,
                  p_transaction_header_id => NULL,
                  p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
               raise pos_err;
            end if;

            if not FA_UTIL_PVT.get_asset_desc_rec(
                           p_asset_hdr_rec   => l_asset_hdr_rec,
                           px_asset_desc_rec => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
               raise pos_err;
            end if;


            if (l_asset_fin_rec.adjustment_required_status = 'TFR') then
               -- ************************************
               -- Process Prior Period Transfer if any
               -- ************************************
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,'Start processing ', 'Prior Period Transfer', p_log_level_rec => p_log_level_rec);
               end if;

               l_asset_cat_rec.category_id := t_category_id(i);

               l_asset_dist_tbl.delete;

               OPEN c_get_dists;
               FETCH c_get_dists BULK COLLECT INTO t_dist_thid
                                                 , t_transaction_date_entered
                                                 , t_date_effective
                                                 , t_last_update_date
                                                 , t_last_updated_by
                                                 , t_transaction_subtype
                                                 , t_transaction_key
                                                 , t_amortization_start_date
                                                 , t_calling_interface
                                                 , t_dist_id
                                                 , t_ccid
                                                 , t_loc_id
                                                 , t_assign_to
                                                 , t_trx_units;
               CLOSE c_get_dists;

               for j in 1..t_dist_thid.count loop
                  l_asset_dist_tbl(j).distribution_id := t_dist_id(j);
                  l_asset_dist_tbl(j).transaction_units := t_trx_units(j);
                  l_asset_dist_tbl(j).assigned_to := t_assign_to(j);
                  l_asset_dist_tbl(j).expense_ccid := t_ccid(j);
                  l_asset_dist_tbl(j).location_ccid := t_loc_id(j);
               end loop;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,'l_asset_dist_tbl has been populated ', t_dist_thid.count, p_log_level_rec => p_log_level_rec);
               end if;

               if not FA_TRANSFER_PVT.fadppt
                      (p_trans_rec       => l_trans_rec,
                       p_asset_hdr_rec   => l_asset_hdr_rec,
                       p_asset_desc_rec  => l_asset_desc_rec,
                       p_asset_cat_rec   => l_asset_cat_rec,
                       p_asset_dist_tbl  => l_asset_dist_tbl, p_log_level_rec => p_log_level_rec) then
                  raise pos_err;
               end if;
            end if;


            l_trans_rec.transaction_header_id          := t_thid(i);
            l_trans_rec.transaction_date_entered       := t_impairment_date(i);
            l_trans_rec.amortization_start_date        := l_trans_rec.transaction_date_entered;

            l_trans_rec.transaction_type_code          := 'ADJUSTMENT';
            l_trans_rec.transaction_subtype            := 'AMORTIZED';
            l_trans_rec.transaction_key                := 'IM';
            l_trans_rec.who_info.last_update_date      := t_creation_date(i);
            l_trans_rec.who_info.last_updated_by       := t_created_by(i);
            l_trans_rec.who_info.created_by            := t_created_by(i);
            l_trans_rec.who_info.creation_date         := t_creation_date(i);

            -- popualte type rec
            if not FA_UTIL_PVT.get_asset_type_rec
                   (p_asset_hdr_rec         => l_asset_hdr_rec,
                    px_asset_type_rec       => l_asset_type_rec,
                    p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
               raise pos_err;
            end if;

            if not fa_cache_pkg.fazccb(p_book_type_code,
                                       t_category_id(i),
                                       p_log_level_rec) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise pos_err;
            end if;

            if (t_period_of_addition_flag(i) = 'Y') and G_release = 11 then
               -- *****************************************
               --  Process (Cip_)cost entries for addition
               -- *****************************************
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn,'Calling function ', 'create_cost_entries', p_log_level_rec => p_log_level_rec);
               end if;

               if not create_cost_entries(p_asset_hdr_rec     => l_asset_hdr_rec
                                        , p_trans_rec         => l_trans_rec
                                        , p_period_rec        => p_period_rec
                                        , p_asset_type_rec    => l_asset_type_rec
                                        , p_cost              => t_cost(i)
                                        , p_current_units     => t_current_units(i)
                                        , p_mrc_sob_type_code => p_mrc_sob_type_code
                                        , p_calling_fn        => l_calling_fn
                                        , p_log_level_rec     => p_log_level_rec
                   ) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  raise pos_err;
               end if;


               if (l_asset_fin_rec.adjustment_required_status = 'ADD') and
                  (t_deprn_adjustment_amount(i) <> 0) then
                  -- *****************************************
                  -- Process Prior Period Addition if any
                  -- *****************************************
                  /*Bug#7685879 - replaced t_impairment_amount with t_deprn_adjustment_amount */
                  l_adj.adjustment_amount := t_deprn_adjustment_amount(i);
                  l_adj.source_type_code  := 'DEPRECIATION';
                  l_adj.adjustment_type   := 'EXPENSE';
                  l_adj.account           := fa_cache_pkg.fazccb_record.deprn_expense_acct;
                  l_adj.account_type      := 'DEPRN_EXPENSE_ACCT';
                  l_adj.debit_credit_flag := 'DR';

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'ppa Catch-up Expense', p_log_level_rec => p_log_level_rec);
                  end if;

                  if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                                    t_creation_date(i),
                                                    t_created_by(i),
                                                    -1,
                                                    p_log_level_rec) then
                     raise pos_err;
                  end if;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn,'Calling function ', 'Prior Period Addition', p_log_level_rec => p_log_level_rec);
                  end if;

               end if;

            end if;

            l_asset_deprn_rec.set_of_books_id          := l_asset_hdr_rec.set_of_books_id;
            l_asset_deprn_rec.deprn_amount             := t_deprn_amount(i);
            l_asset_deprn_rec.ytd_deprn                := t_ytd_deprn(i);
            l_asset_deprn_rec.deprn_reserve            := t_deprn_reserve(i);
            l_asset_deprn_rec.prior_fy_expense         := t_prior_fy_expense(i);
            l_asset_deprn_rec.bonus_deprn_amount       := t_bonus_deprn_amount(i);
            l_asset_deprn_rec.bonus_ytd_deprn          := t_bonus_ytd_deprn(i);
            l_asset_deprn_rec.bonus_deprn_reserve      := t_bonus_deprn_reserve(i);
            l_asset_deprn_rec.prior_fy_bonus_expense   := t_prior_fy_bonus_expense(i);
            l_asset_deprn_rec.reval_amortization       := t_reval_amortization(i);
            l_asset_deprn_rec.reval_amortization_basis := t_reval_amortization_basis(i);
            l_asset_deprn_rec.reval_deprn_expense      := t_reval_deprn_expense(i);
            l_asset_deprn_rec.reval_ytd_deprn          := t_ytd_reval_deprn_expense(i);
            l_asset_deprn_rec.reval_deprn_reserve      := t_reval_reserve(i);
            l_asset_deprn_rec.production               := t_production(i);
            l_asset_deprn_rec.ytd_production           := t_ytd_production(i);
            l_asset_deprn_rec.ltd_production           := t_ltd_production(i);
            l_asset_deprn_rec.impairment_amount        := t_impairment_amount(i);
            l_asset_deprn_rec.ytd_impairment           := t_ytd_impairment(i);
            l_asset_deprn_rec.impairment_reserve       := t_impairment_reserve(i);


            -- Calculate New deprn basis
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Calling function ', 'Deprn Basis', p_log_level_rec => p_log_level_rec);
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'deprn_method_code', l_asset_fin_rec.deprn_method_code, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'life_in_months', l_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec);
            end if;

            if (not fa_cache_pkg.fazccmt(l_asset_fin_rec.deprn_method_code,
                                         l_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
               end if;

               raise pos_err;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'rate_source_rule', fa_cache_pkg.fazccmt_record.rate_source_rule, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'deprn_basis_rule', fa_cache_pkg.fazccmt_record.deprn_basis_rule, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'use_rsv_after_imp_flag', fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, p_log_level_rec => p_log_level_rec);
            end if;

	    /*phase5 Initializing the cache*/

 	    if (not FA_CACHE_PKG.fazccmt
                (l_asset_fin_rec.deprn_method_code,
                 l_asset_fin_rec.life_in_months, p_log_level_rec => p_log_level_rec)) then
                 FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_IMPAIRMENT_POST_PVT.process_post',  p_log_level_rec => p_log_level_rec);
                 return FALSE;
            end if;

            if (fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT) and
                 (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST) and
               (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'Y') = 'Y') and
	       NVL(fa_cache_pkg.fazccmt_record.JP_IMP_CALC_BASIS_FLAG, 'XX') <> 'YES' then
               l_asset_deprn_rec.impairment_reserve       := l_asset_deprn_rec.deprn_reserve +
                                                             l_asset_deprn_rec.impairment_reserve;
            elsif (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'N') = 'Y') and
                   (fa_cache_pkg.fazcdbr_record.rule_name = 'FLAT RATE EXTENSION') then
               l_asset_fin_rec.eofy_reserve               := l_asset_deprn_rec.deprn_reserve;
            end if;

            /*phase5 need to set transaction key = 'JI' for deprn methods using JP NBV based calculations for impairment*/
            if (NVL(fa_cache_pkg.fazccmt_record.JP_IMP_CALC_BASIS_FLAG, 'NO') = 'YES') then
  	       l_trans_rec.transaction_key := 'JI';
  	    end if;
              if not call_deprn_basis(p_asset_hdr_rec      => l_asset_hdr_rec
                                  , p_trans_rec          => l_trans_rec
                                  , p_period_rec         => p_period_rec
                                  , p_asset_type_rec     => l_asset_type_rec
                                  , p_asset_fin_rec      => l_asset_fin_rec
                                  , p_asset_deprn_rec    => l_asset_deprn_rec
                                  , p_asset_desc_rec     => l_asset_desc_rec
                                  , x_new_raf            => t_new_raf(i)
                                  , x_new_formula_factor => t_new_formula_factor(i)
                                  , x_new_adjusted_cost  => t_new_adj_cost(i)
                                  , p_mrc_sob_type_code  => p_mrc_sob_type_code
                                  , p_calling_fn         => l_calling_fn
                                  , p_log_level_rec      => p_log_level_rec) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise pos_err;
            end if;
         else
            t_new_adj_cost(i) := t_adjusted_cost(i);
            t_new_raf(i) := t_raf(i);
            t_new_formula_factor(i) := t_formula_factor(i);
         end if; -- (p_period_rec.period_counter = t_period_counter(i))
         /* Bug 9577878 need to set period counter fully reserved correctly*/
	  if (NVL(fa_cache_pkg.fazccmt_record.EXCLUDE_SALVAGE_VALUE_FLAG, 'NO') = 'YES') then
	    if ((t_new_adj_cost(i) + l_asset_fin_rec.salvage_value) <= t_allowed_deprn_limit_amount(i)) then
	       t_period_counter_fully_rsv(i) := p_period_rec.period_counter;
	       t_period_counter_life_complete(i) := p_period_rec.period_counter;
	    else
	       t_period_counter_fully_rsv(i) := null;
	       t_period_counter_life_complete(i) := null;
	    end if;
	 else
	    if (t_new_adj_cost(i)  <= t_allowed_deprn_limit_amount(i)) then
	       t_period_counter_fully_rsv(i) := p_period_rec.period_counter;
	       t_period_counter_life_complete(i) := p_period_rec.period_counter;
	    else
	       t_period_counter_fully_rsv(i) := null;
	       t_period_counter_life_complete(i) := null;
	    end if;
	 end if;
	 t_period_counter_fully_ext(i) := null;
         /*Bug 9574021 need to keep original value of period counter fully reserve and period counter life complete for extended asset*/
	 IF (l_asset_fin_rec.deprn_method_code = 'JP-STL-EXTND') then
	    SELECT PERIOD_COUNTER_LIFE_COMPLETE,PERIOD_COUNTER_FULLY_RESERVED
	    INTO   t_period_counter_life_complete(i),t_period_counter_fully_rsv(i)
	    FROM   FA_BOOKS
	    WHERE  BOOK_TYPE_CODE = p_book_type_code
	    AND    ASSET_ID       = l_asset_hdr_rec.asset_id
	    AND    TRANSACTION_HEADER_ID_OUT is NULL;
	    /*BUG 9786860 */
	    IF (t_new_adj_cost(i) <= 0) THEN
	       t_period_counter_fully_ext(i) :=  p_period_rec.period_counter;
	    END IF;
	    if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'INSIDE EXTENDED LOGIC  FOR', ' PC FULLY RESRVE and LIFE COMPLETE and EXTENDED', p_log_level_rec => p_log_level_rec);
	       fa_debug_pkg.add(l_calling_fn,'PERIOD_COUNTER_LIFE_COMPLETE', t_period_counter_life_complete(i), p_log_level_rec => p_log_level_rec);
	       fa_debug_pkg.add(l_calling_fn,'PERIOD_COUNTER_FULLY_RESERVED', t_period_counter_fully_rsv(i), p_log_level_rec => p_log_level_rec);
	       fa_debug_pkg.add(l_calling_fn,'PERIOD_COUNTER_FULLY_EXTENDED', t_period_counter_fully_ext(i), p_log_level_rec => p_log_level_rec);
            end if;
          END IF;
	 /*Bug 9818289  Initialized below variables so that they have values in case of Non-Japanese methods*/
	 t_rate_in_use(i) := null;
  	 t_nbv_at_switch(i) := null;
	 /*Phase5 Calculations around switching and rate in use for assets using JP-250DB methods*/
         if (NVL(fa_cache_pkg.fazccmt_record.JP_IMP_CALC_BASIS_FLAG, 'NO') = 'YES') then
	    t_rate_in_use(i) := l_asset_fin_rec.rate_in_use;
  	    t_nbv_at_switch(i) := l_asset_fin_rec.nbv_at_switch;

	    if ((fa_cache_pkg.fazcct_record.number_per_fiscal_year = p_period_rec.period_num) and
  	        (nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES') and
  		(l_asset_fin_rec.rate_in_use = fa_cache_pkg.fazcfor_record.original_rate ))then

		if (((t_new_adj_cost(i) + l_asset_fin_rec.salvage_value) * fa_cache_pkg.fazcfor_record.original_rate) <= (t_cost(i) * fa_cache_pkg.fazcfor_record.guarantee_rate )) then
  		    t_rate_in_use(i) := fa_cache_pkg.fazcfor_record.revised_rate;
  		    t_nbv_at_switch(i) := t_new_adj_cost(i) + l_asset_fin_rec.salvage_value;

		    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add(l_calling_fn,'ASSET WILL SWITCH AFTER', 'CURRENT IMPAIRMENT', p_log_level_rec => p_log_level_rec);
	               fa_debug_pkg.add(l_calling_fn,'t_rate_in_use(i)', t_rate_in_use(i), p_log_level_rec => p_log_level_rec);
	               fa_debug_pkg.add(l_calling_fn,'t_nbv_at_switch(i)', t_nbv_at_switch(i), p_log_level_rec => p_log_level_rec);
                    end if;
  		else
  		    t_rate_in_use(i) := fa_cache_pkg.fazcfor_record.original_rate;
  		    t_nbv_at_switch(i) := NULL;
  		end if;
    	    end if;
	    if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'INSIDE JAPAN LOGIC', 'NBV CALCULATIONS FOR NBV', p_log_level_rec => p_log_level_rec);
	       fa_debug_pkg.add(l_calling_fn,'t_rate_in_use(i)', t_rate_in_use(i), p_log_level_rec => p_log_level_rec);
	       fa_debug_pkg.add(l_calling_fn,'t_nbv_at_switch(i)', t_nbv_at_switch(i), p_log_level_rec => p_log_level_rec);
            end if;
         end if;
         -- Insert Adj
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Preparing variables for ', 'faxinaj', p_log_level_rec => p_log_level_rec);
         end if;

         l_adj.source_type_code        := 'ADJUSTMENT';

        if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'fa_cache_pkg.fazcbc_record.sorp_enabled_flag', fa_cache_pkg.fazcbc_record.sorp_enabled_flag, p_log_level_rec => p_log_level_rec);
        end if;

        -- Bug 6666666 : Added for the SORP Compliance Project
        -- The following code snippet is used to create the impairment accounting
        -- entries. This functionality is documented in
        -- section 16.2 in the SORP Functional Design Document
        if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then

            if not FA_SORP_IMPAIRMENT_PVT.create_sorp_imp_acct (
                         px_adj => l_adj
                       , p_impairment_amount => t_impairment_amount(i)
                       , p_reval_reserve_adj => t_reval_reserve_adj_amount(i)
                       , p_impair_class => t_impair_class(i)
                       , p_impair_loss_acct => t_impair_loss_acct(i)
                       , p_split_impair_flag => t_split_impair_flag(i)
                       , p_split1_impair_class => t_split1_impair_class(i)
                       , p_split1_loss_amount => t_split1_loss_amount(i)
                       , p_split1_reval_reserve => t_split1_reval_reserve(i)
                       , p_split1_loss_acct => t_split1_loss_acct(i)
                       , p_split2_impair_class => t_split2_impair_class(i)
                       , p_split2_loss_amount => t_split2_loss_amount(i)
                       , p_split2_reval_reserve => t_split2_reval_reserve(i)
                       , p_split2_loss_acct => t_split2_loss_acct(i)
                       , p_split3_impair_class => t_split3_impair_class(i)
                       , p_split3_loss_amount => t_split3_loss_amount(i)
                       , p_split3_reval_reserve => t_split3_reval_reserve(i)
                       , p_split3_loss_acct => t_split3_loss_acct(i)
                       , p_created_by => t_created_by(i)
                       , p_creation_date => t_creation_date(i)
                       , p_log_level_rec => p_log_level_rec
                    ) then
                        fa_debug_pkg.add(l_calling_fn,'Error creating SORP Impair
                                                       entries', 'True', p_log_level_rec => p_log_level_rec);
                        raise pos_err;
            end if;

            if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,'Processing of create_sorp_imp_acct', 'successful', p_log_level_rec => p_log_level_rec);
            end if;

             -- ******************************************************
             -- Need to create catchup entry for BD SORP IMP
             -- ******************************************************
             if (p_period_rec.period_counter > t_period_counter(i)) and
                (nvl(l_asset_fin_rec.adjustment_required_status, 'NONE') <> 'ADD') and
                (t_deprn_adjustment_amount(i) <> 0) and
                (G_release = 11 ) then

                l_adj.adjustment_amount := t_deprn_adjustment_amount(i);
                l_adj.source_type_code  := 'DEPRECIATION';
                l_adj.adjustment_type   := 'EXPENSE';
                l_adj.account           := fa_cache_pkg.fazccb_record.deprn_expense_acct;
                l_adj.account_type      := 'DEPRN_EXPENSE_ACCT';
                l_adj.debit_credit_flag := 'DR';

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Catch-up Expense', p_log_level_rec => p_log_level_rec);
                end if;

                if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                                  t_creation_date(i),
                                                  t_created_by(i),
                                                  -1,
                                                  p_log_level_rec) then
                   raise pos_err;
                end if;

             end if; -- End p_period_rec.period_counter > t_period_counter(i)

             -- Create neutralizing entry for adjustment catchup entry
             if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                        t_deprn_adjustment_amount(i)
                       , 'N'
                       , l_adj
                       , t_created_by(i)
                       , t_creation_date(i)
                       , p_log_level_rec
                       ) then
                 fa_debug_pkg.add(l_calling_fn,'Error at create_sorp_neutral_acct',
                                             'for Catch-up Expense', p_log_level_rec => p_log_level_rec);
                 return false;
             end if;


        else -- If SORP is not enabled then perform the regular accounting

             --******************************************************
             --       Accumulated Impairment
             --******************************************************
             l_adj.adjustment_amount := t_impairment_amount(i) + t_reval_reserve_adj_amount(i); /*Bug#  8602103*/
             l_adj.adjustment_type   := 'IMPAIR RESERVE';
             l_adj.account_type      := 'IMPAIR_RESERVE_ACCT';
             l_adj.account           := fa_cache_pkg.fazccb_record.impair_reserve_acct;

             l_adj.debit_credit_flag := 'CR';

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Accumulated Impairments', p_log_level_rec => p_log_level_rec);
             end if;

             if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                               t_creation_date(i),
                                               t_created_by(i),
                                               -1,
                                               p_log_level_rec) then
                raise pos_err;
             end if;

             --******************************************************
             --       Impairment Expense
             --******************************************************
             l_adj.adjustment_amount := t_impairment_amount(i);
             l_adj.adjustment_type   := 'IMPAIR EXPENSE';
             l_adj.account_type      := 'IMPAIR_EXPENSE_ACCT';
             l_adj.account           := fa_cache_pkg.fazccb_record.impair_expense_acct;
             l_adj.debit_credit_flag := 'DR';

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Impairments Expense', p_log_level_rec => p_log_level_rec);
             end if;

             if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                               t_creation_date(i),
                                               t_created_by(i),
                                                  -1,
                                               p_log_level_rec) then
                raise pos_err;
             end if;


             -- ******************************************************
             -- Need to create catchup entry for BD IMP
             -- ******************************************************
             if (p_period_rec.period_counter > t_period_counter(i)) and
                (nvl(l_asset_fin_rec.adjustment_required_status, 'NONE') <> 'ADD') and
                (t_deprn_adjustment_amount(i) <> 0) then

                l_adj.adjustment_amount := t_deprn_adjustment_amount(i);
                l_adj.source_type_code  := 'DEPRECIATION';
                l_adj.adjustment_type   := 'EXPENSE';
                l_adj.account           := fa_cache_pkg.fazccb_record.deprn_expense_acct;
                l_adj.account_type      := 'DEPRN_EXPENSE_ACCT';
                l_adj.debit_credit_flag := 'DR';

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Catch-up Expense', p_log_level_rec => p_log_level_rec);
                end if;

                if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                                  t_creation_date(i),
                                                  t_created_by(i),
                                                  -1,
                                                  p_log_level_rec) then
                   raise pos_err;
                end if;

             end if;

             if (t_reval_reserve_adj_amount(i) <> 0) then
                --******************************************************
                --       Revaluation Reserve
                --******************************************************
                --Bug7036770
                --made changes to the adjustment amount passed to get the
                --correct reval reserve after impairment.

                l_adj.adjustment_amount := t_reval_reserve_adj_amount(i) -  t_reval_reserve(i);
                l_adj.adjustment_type   := 'REVAL RESERVE';
                l_adj.account_type      := 'REVAL_RESERVE_ACCT';
                l_adj.account           := fa_cache_pkg.fazccb_record.reval_reserve_acct;
                l_adj.debit_credit_flag := 'DR';

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Reval Reserve', p_log_level_rec => p_log_level_rec);
                end if;

                if not FA_INS_ADJUST_PKG.faxinaj (l_adj,
                                                  t_creation_date(i),
                                                  t_created_by(i),
                                                  -1,
                                                  p_log_level_rec) then
                   raise pos_err;
                end if;
             end if;

         end if; -- End If SORP/Non SORP check

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Finish calling', 'faxinaj', p_log_level_rec => p_log_level_rec);
         end if;

         if (p_period_rec.period_counter = l_period_counter) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Calling FAXINDD for ', 'FA_DEPRN_DETAIL', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,'p_period_rec.period_counter', p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn,'t_cost('||to_char(i)||')', t_cost(i));
               fa_debug_pkg.add(l_calling_fn,'t_deprn_reserve('||to_char(i)||')', t_deprn_reserve(i));
               fa_debug_pkg.add(l_calling_fn,'t_reval_reserve('||to_char(i)||')', t_reval_reserve(i));
               fa_debug_pkg.add(l_calling_fn,'t_ytd_deprn('||to_char(i)||')', t_ytd_deprn(i));
               fa_debug_pkg.add(l_calling_fn,'t_ytd_reval_deprn_expense('||to_char(i)||')', t_ytd_reval_deprn_expense(i));
               fa_debug_pkg.add(l_calling_fn,'t_new_adj_cost('||to_char(i)||')', t_new_adj_cost(i));
               fa_debug_pkg.add(l_calling_fn,'t_net_book_value'||to_char(i)||')',t_net_book_value(i));
            end if;

            -- Insert DD


           -- Bug 6666666 : Added for the SORP Compliance Project
           --               If SORP is enabled the value of general fund and
           --               capital adjustment are set.
           if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
               if not FA_INS_DETAIL_PKG.FAXINDD
                         (X_book_type_code           => p_book_type_code,
                          X_asset_id                 => t_asset_id(i),
                          X_period_counter           => p_period_rec.period_counter,
                          X_cost                     => t_cost(i),
                          X_deprn_reserve            => nvl(t_deprn_reserve(i), 0),
                          X_deprn_adjustment_amount  => nvl(t_deprn_adjustment_amount(i), 0),
                          X_reval_reserve            => nvl(t_reval_reserve(i), 0),
                          X_ytd                      => nvl(t_ytd_deprn(i), 0),
                          X_ytd_reval_dep_exp        => nvl(t_ytd_reval_deprn_expense(i), 0),
                          X_bonus_ytd                => nvl(t_bonus_ytd_deprn(i), 0),
                          X_bonus_deprn_reserve      => nvl(t_bonus_deprn_reserve(i), 0),
                          X_init_message_flag        => 'NO',
                          X_bonus_deprn_adj_amount   => t_bonus_deprn_adj_amount(i),
                          X_bonus_deprn_amount       => t_bonus_deprn_amount(i),
                          X_deprn_amount             => t_deprn_amount(i),
                          X_reval_amortization       => t_reval_amortization(i),
                          X_reval_deprn_expense      => t_reval_deprn_expense(i),
                          X_impairment_amount        => t_impairment_amount(i),
                          X_ytd_impairment           => t_ytd_impairment(i),
                          X_impairment_reserve           => t_impairment_reserve(i),
                          X_capital_adjustment       => t_capital_adjustment(i)
                                                        - nvl(t_reval_amortization(i),0)
                                                        + nvl(t_deprn_amount(i),0), --Bug 6666666
                          X_general_fund             => t_general_fund(i)
                                                        + nvl(t_deprn_amount(i),0),       --Bug 6666666
                          X_b_row                    => FALSE,
                          X_mrc_sob_type_code        => p_mrc_sob_type_code,
                          X_set_of_books_id          => p_set_of_books_id,
                          p_log_level_rec => p_log_level_rec
                         ) then raise
                  pos_err;
               end if;
            else -- If SORP is not enabled capital adjustment and general fund
                 -- should be null
               if not FA_INS_DETAIL_PKG.FAXINDD
                         (X_book_type_code           => p_book_type_code,
                          X_asset_id                 => t_asset_id(i),
                          X_period_counter           => p_period_rec.period_counter,
                          X_cost                     => t_cost(i),
                          X_deprn_reserve            => nvl(t_deprn_reserve(i), 0),
                          X_deprn_adjustment_amount  => nvl(t_deprn_adjustment_amount(i), 0),
                          X_reval_reserve            => nvl(t_reval_reserve(i), 0),
                          X_ytd                      => nvl(t_ytd_deprn(i), 0),
                          X_ytd_reval_dep_exp        => nvl(t_ytd_reval_deprn_expense(i), 0),
                          X_bonus_ytd                => nvl(t_bonus_ytd_deprn(i), 0),
                          X_bonus_deprn_reserve      => nvl(t_bonus_deprn_reserve(i), 0),
                          X_init_message_flag        => 'NO',
                          X_bonus_deprn_adj_amount   => t_bonus_deprn_adj_amount(i),
                          X_bonus_deprn_amount       => t_bonus_deprn_amount(i),
                          X_deprn_amount             => t_deprn_amount(i),
                          X_reval_amortization       => t_reval_amortization(i),
                          X_reval_deprn_expense      => t_reval_deprn_expense(i),
                          X_impairment_amount        => t_impairment_amount(i),
                          X_ytd_impairment           => t_ytd_impairment(i),
                          X_impairment_reserve           => t_impairment_reserve(i),
                          X_capital_adjustment       => NULL, --Bug 6666666
                          X_general_fund             => NULL, --Bug 6666666
                          X_b_row                    => FALSE,
                          X_mrc_sob_type_code        => p_mrc_sob_type_code,
                          X_set_of_books_id          => p_set_of_books_id,
                          p_log_level_rec => p_log_level_rec
                         ) then raise
                  pos_err;
               end if;
            end if;

        end if; -- (p_period_rec.period_counter = t_period_counter(i))

      END LOOP; -- i in 1..t_request_id.count

      -- Deactivate Books
      if (p_mrc_sob_type_code = 'R') then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Deactivating ', 'FA_BOOKS_MRC_V', p_log_level_rec => p_log_level_rec);
         end if;

         FORALL i in 1..t_request_id.count
            UPDATE FA_MC_BOOKS
            SET    DATE_INEFFECTIVE = t_creation_date(i)
                 , TRANSACTION_HEADER_ID_OUT = t_thid(i)
            WHERE  ASSET_ID = t_asset_id(i)
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_HEADER_ID_OUT is null
            AND    SET_OF_BOOKS_ID = p_set_of_books_id
            RETURNING transaction_header_id_in BULK COLLECT INTO t_old_thid;

      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Deactivating ', 'FA_BOOKS', p_log_level_rec => p_log_level_rec);
         end if;

         FORALL i in 1..t_request_id.count
            UPDATE FA_BOOKS
            SET    DATE_INEFFECTIVE = t_creation_date(i)
                 , TRANSACTION_HEADER_ID_OUT = t_thid(i)
            WHERE  ASSET_ID = t_asset_id(i)
            AND    BOOK_TYPE_CODE = p_book_type_code
            AND    TRANSACTION_HEADER_ID_OUT is null
            RETURNING transaction_header_id_in BULK COLLECT INTO t_old_thid;
      end if;
      -- Insert books

      if (p_mrc_sob_type_code = 'R') then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Inserting record into ', 'FA_BOOKS_MRC_V', p_log_level_rec => p_log_level_rec);
         end if;

         FORALL i in 1..t_request_id.count
            INSERT INTO FA_MC_BOOKS( SET_OF_BOOKS_ID
                                      , BOOK_TYPE_CODE
                                      , ASSET_ID
                                      , DATE_PLACED_IN_SERVICE
                                      , DATE_EFFECTIVE
                                      , DEPRN_START_DATE
                                      , DEPRN_METHOD_CODE
                                      , LIFE_IN_MONTHS
                                      , RATE_ADJUSTMENT_FACTOR
                                      , ADJUSTED_COST
                                      , COST
                                      , ORIGINAL_COST
                                      , SALVAGE_VALUE
                                      , PRORATE_CONVENTION_CODE
                                      , PRORATE_DATE
                                      , COST_CHANGE_FLAG
                                      , ADJUSTMENT_REQUIRED_STATUS
                                      , CAPITALIZE_FLAG
                                      , RETIREMENT_PENDING_FLAG
                                      , DEPRECIATE_FLAG
                                      , LAST_UPDATE_DATE
                                      , LAST_UPDATED_BY
                                      , TRANSACTION_HEADER_ID_IN
                                      , ITC_AMOUNT_ID
                                      , ITC_AMOUNT
                                      , RETIREMENT_ID
                                      , TAX_REQUEST_ID
                                      , ITC_BASIS
                                      , BASIC_RATE
                                      , ADJUSTED_RATE
                                      , BONUS_RULE
                                      , CEILING_NAME
                                      , RECOVERABLE_COST
                                      , ADJUSTED_CAPACITY
                                      , FULLY_RSVD_REVALS_COUNTER
                                      , IDLED_FLAG
                                      , PERIOD_COUNTER_CAPITALIZED
                                      , PERIOD_COUNTER_FULLY_RESERVED
                                      , PERIOD_COUNTER_FULLY_RETIRED
                                      , PRODUCTION_CAPACITY
                                      , REVAL_AMORTIZATION_BASIS
                                      , REVAL_CEILING
                                      , UNIT_OF_MEASURE
                                      , UNREVALUED_COST
                                      , ANNUAL_DEPRN_ROUNDING_FLAG
                                      , PERCENT_SALVAGE_VALUE
                                      , ALLOWED_DEPRN_LIMIT
                                      , ALLOWED_DEPRN_LIMIT_AMOUNT
                                      , PERIOD_COUNTER_LIFE_COMPLETE
                                      , ADJUSTED_RECOVERABLE_COST
                                      , ANNUAL_ROUNDING_FLAG
                                      , GLOBAL_ATTRIBUTE1
                                      , GLOBAL_ATTRIBUTE2
                                      , GLOBAL_ATTRIBUTE3
                                      , GLOBAL_ATTRIBUTE4
                                      , GLOBAL_ATTRIBUTE5
                                      , GLOBAL_ATTRIBUTE6
                                      , GLOBAL_ATTRIBUTE7
                                      , GLOBAL_ATTRIBUTE8
                                      , GLOBAL_ATTRIBUTE9
                                      , GLOBAL_ATTRIBUTE10
                                      , GLOBAL_ATTRIBUTE11
                                      , GLOBAL_ATTRIBUTE12
                                      , GLOBAL_ATTRIBUTE13
                                      , GLOBAL_ATTRIBUTE14
                                      , GLOBAL_ATTRIBUTE15
                                      , GLOBAL_ATTRIBUTE16
                                      , GLOBAL_ATTRIBUTE17
                                      , GLOBAL_ATTRIBUTE18
                                      , GLOBAL_ATTRIBUTE19
                                      , GLOBAL_ATTRIBUTE20
                                      , GLOBAL_ATTRIBUTE_CATEGORY
                                      , EOFY_ADJ_COST
                                      , EOFY_FORMULA_FACTOR
                                      , SHORT_FISCAL_YEAR_FLAG
                                      , CONVERSION_DATE
                                      , ORIGINAL_DEPRN_START_DATE
                                      , REMAINING_LIFE1
                                      , REMAINING_LIFE2
                                      , OLD_ADJUSTED_COST
                                      , FORMULA_FACTOR
                                      , GROUP_ASSET_ID
                                      , SALVAGE_TYPE
                                      , DEPRN_LIMIT_TYPE
                                      , REDUCTION_RATE
                                      , REDUCE_ADDITION_FLAG
                                      , REDUCE_ADJUSTMENT_FLAG
                                      , REDUCE_RETIREMENT_FLAG
                                      , RECOGNIZE_GAIN_LOSS
                                      , RECAPTURE_RESERVE_FLAG
                                      , LIMIT_PROCEEDS_FLAG
                                      , TERMINAL_GAIN_LOSS
                                      , TRACKING_METHOD
                                      , EXCLUDE_FULLY_RSV_FLAG
                                      , EXCESS_ALLOCATION_OPTION
                                      , DEPRECIATION_OPTION
                                      , MEMBER_ROLLUP_FLAG
                                      , ALLOCATE_TO_FULLY_RSV_FLAG
                                      , ALLOCATE_TO_FULLY_RET_FLAG
                                      , TERMINAL_GAIN_LOSS_AMOUNT
                                      , CIP_COST
                                      , YTD_PROCEEDS
                                      , LTD_PROCEEDS
                                      , LTD_COST_OF_REMOVAL
                                      , EOFY_RESERVE
                                      , PRIOR_EOFY_RESERVE
                                      , EOP_ADJ_COST
                                      , EOP_FORMULA_FACTOR
                                      , EXCLUDE_PROCEEDS_FROM_BASIS
                                      , RETIREMENT_DEPRN_OPTION
                                      , TERMINAL_GAIN_LOSS_FLAG
                                      , SUPER_GROUP_ID
                                      , OVER_DEPRECIATE_OPTION
                                      , DISABLED_FLAG
                                      , CASH_GENERATING_UNIT_ID
	    ) SELECT SET_OF_BOOKS_ID
                   , BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , t_creation_date(i) -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , t_new_raf(i) --RATE_ADJUSTMENT_FACTOR
                   , t_new_adj_cost(i) -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , t_creation_date(i) -- LAST_UPDATE_DATE
                   , t_created_by(i) -- LAST_UPDATED_BY
                   , t_thid(i) -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , t_period_counter_fully_rsv(i) -- phase5 decode(sign(t_new_adj_cost(i) - t_allowed_deprn_limit_amount(i)), 1, null, p_period_rec.period_counter) --PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , t_reval_reserve(i)
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , 'ADJ'
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , t_period_counter_life_complete(i) -- phase5 decode(sign(t_new_adj_cost(i) - t_allowed_deprn_limit_amount(i)), 1, null, p_period_rec.period_counter) --PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , t_new_formula_factor(i) --FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , t_eofy_reserve(i) --EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
                   , CASH_GENERATING_UNIT_ID
              FROM  FA_MC_BOOKS
              WHERE TRANSACTION_HEADER_ID_IN = t_old_thid(i)
              and   SET_OF_BOOKS_ID = p_set_of_books_id ;

      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Inserting record into ', 'FA_BOOKS', p_log_level_rec => p_log_level_rec);
         end if;

         FORALL i in 1..t_request_id.count
            INSERT INTO FA_BOOKS( BOOK_TYPE_CODE
                                , ASSET_ID
                                , DATE_PLACED_IN_SERVICE
                                , DATE_EFFECTIVE
                                , DEPRN_START_DATE
                                , DEPRN_METHOD_CODE
                                , LIFE_IN_MONTHS
                                , RATE_ADJUSTMENT_FACTOR
                                , ADJUSTED_COST
                                , COST
                                , ORIGINAL_COST
                                , SALVAGE_VALUE
                                , PRORATE_CONVENTION_CODE
                                , PRORATE_DATE
                                , COST_CHANGE_FLAG
                                , ADJUSTMENT_REQUIRED_STATUS
                                , CAPITALIZE_FLAG
                                , RETIREMENT_PENDING_FLAG
                                , DEPRECIATE_FLAG
                                , LAST_UPDATE_DATE
                                , LAST_UPDATED_BY
                                , TRANSACTION_HEADER_ID_IN
                                , ITC_AMOUNT_ID
                                , ITC_AMOUNT
                                , RETIREMENT_ID
                                , TAX_REQUEST_ID
                                , ITC_BASIS
                                , BASIC_RATE
                                , ADJUSTED_RATE
                                , BONUS_RULE
                                , CEILING_NAME
                                , RECOVERABLE_COST
                                , ADJUSTED_CAPACITY
                                , FULLY_RSVD_REVALS_COUNTER
                                , IDLED_FLAG
                                , PERIOD_COUNTER_CAPITALIZED
                                , PERIOD_COUNTER_FULLY_RESERVED
                                , PERIOD_COUNTER_FULLY_RETIRED
                                , PRODUCTION_CAPACITY
                                , REVAL_AMORTIZATION_BASIS
                                , REVAL_CEILING
                                , UNIT_OF_MEASURE
                                , UNREVALUED_COST
                                , ANNUAL_DEPRN_ROUNDING_FLAG
                                , PERCENT_SALVAGE_VALUE
                                , ALLOWED_DEPRN_LIMIT
                                , ALLOWED_DEPRN_LIMIT_AMOUNT
                                , PERIOD_COUNTER_LIFE_COMPLETE
                                , ADJUSTED_RECOVERABLE_COST
                                , ANNUAL_ROUNDING_FLAG
                                , GLOBAL_ATTRIBUTE1
                                , GLOBAL_ATTRIBUTE2
                                , GLOBAL_ATTRIBUTE3
                                , GLOBAL_ATTRIBUTE4
                                , GLOBAL_ATTRIBUTE5
                                , GLOBAL_ATTRIBUTE6
                                , GLOBAL_ATTRIBUTE7
                                , GLOBAL_ATTRIBUTE8
                                , GLOBAL_ATTRIBUTE9
                                , GLOBAL_ATTRIBUTE10
                                , GLOBAL_ATTRIBUTE11
                                , GLOBAL_ATTRIBUTE12
                                , GLOBAL_ATTRIBUTE13
                                , GLOBAL_ATTRIBUTE14
                                , GLOBAL_ATTRIBUTE15
                                , GLOBAL_ATTRIBUTE16
                                , GLOBAL_ATTRIBUTE17
                                , GLOBAL_ATTRIBUTE18
                                , GLOBAL_ATTRIBUTE19
                                , GLOBAL_ATTRIBUTE20
                                , GLOBAL_ATTRIBUTE_CATEGORY
                                , EOFY_ADJ_COST
                                , EOFY_FORMULA_FACTOR
                                , SHORT_FISCAL_YEAR_FLAG
                                , CONVERSION_DATE
                                , ORIGINAL_DEPRN_START_DATE
                                , REMAINING_LIFE1
                                , REMAINING_LIFE2
                                , OLD_ADJUSTED_COST
                                , FORMULA_FACTOR
                                , GROUP_ASSET_ID
                                , SALVAGE_TYPE
                                , DEPRN_LIMIT_TYPE
                                , REDUCTION_RATE
                                , REDUCE_ADDITION_FLAG
                                , REDUCE_ADJUSTMENT_FLAG
                                , REDUCE_RETIREMENT_FLAG
                                , RECOGNIZE_GAIN_LOSS
                                , RECAPTURE_RESERVE_FLAG
                                , LIMIT_PROCEEDS_FLAG
                                , TERMINAL_GAIN_LOSS
                                , TRACKING_METHOD
                                , EXCLUDE_FULLY_RSV_FLAG
                                , EXCESS_ALLOCATION_OPTION
                                , DEPRECIATION_OPTION
                                , MEMBER_ROLLUP_FLAG
                                , ALLOCATE_TO_FULLY_RSV_FLAG
                                , ALLOCATE_TO_FULLY_RET_FLAG
                                , TERMINAL_GAIN_LOSS_AMOUNT
                                , CIP_COST
                                , YTD_PROCEEDS
                                , LTD_PROCEEDS
                                , LTD_COST_OF_REMOVAL
                                , EOFY_RESERVE
                                , PRIOR_EOFY_RESERVE
                                , EOP_ADJ_COST
                                , EOP_FORMULA_FACTOR
                                , EXCLUDE_PROCEEDS_FROM_BASIS
                                , RETIREMENT_DEPRN_OPTION
                                , TERMINAL_GAIN_LOSS_FLAG
                                , SUPER_GROUP_ID
                                , OVER_DEPRECIATE_OPTION
                                , DISABLED_FLAG
                                , CASH_GENERATING_UNIT_ID
				, RATE_IN_USE
 				, NBV_AT_SWITCH
                                , PRIOR_ADJUSTED_RATE
				, PRIOR_BASIC_RATE
				, PRIOR_LIFE_IN_MONTHS
				, PRIOR_DEPRN_METHOD
				, PRIOR_DEPRN_LIMIT
				, PRIOR_DEPRN_LIMIT_AMOUNT
				, PRIOR_DEPRN_LIMIT_TYPE
				, EXTENDED_DEPRECIATION_PERIOD
				, EXTENDED_DEPRN_FLAG
				, PERIOD_COUNTER_FULLY_EXTENDED
            ) SELECT BOOK_TYPE_CODE
                   , ASSET_ID
                   , DATE_PLACED_IN_SERVICE
                   , t_creation_date(i) -- DATE_EFFECTIVE
                   , DEPRN_START_DATE
                   , DEPRN_METHOD_CODE
                   , LIFE_IN_MONTHS
                   , t_new_raf(i) --RATE_ADJUSTMENT_FACTOR
                   , t_new_adj_cost(i) -- ADJUSTED_COST
                   , COST
                   , ORIGINAL_COST
                   , SALVAGE_VALUE
                   , PRORATE_CONVENTION_CODE
                   , PRORATE_DATE
                   , COST_CHANGE_FLAG
                   , ADJUSTMENT_REQUIRED_STATUS
                   , CAPITALIZE_FLAG
                   , RETIREMENT_PENDING_FLAG
                   , DEPRECIATE_FLAG
                   , t_creation_date(i) -- LAST_UPDATE_DATE
                   , t_created_by(i) -- LAST_UPDATED_BY
                   , t_thid(i) -- TRANSACTION_HEADER_ID_IN
                   , ITC_AMOUNT_ID
                   , ITC_AMOUNT
                   , RETIREMENT_ID
                   , TAX_REQUEST_ID
                   , ITC_BASIS
                   , BASIC_RATE
                   , ADJUSTED_RATE
                   , BONUS_RULE
                   , CEILING_NAME
                   , RECOVERABLE_COST
                   , ADJUSTED_CAPACITY
                   , FULLY_RSVD_REVALS_COUNTER
                   , IDLED_FLAG
                   , PERIOD_COUNTER_CAPITALIZED
                   , t_period_counter_fully_rsv(i) -- phase5 decode(sign(t_new_adj_cost(i)-t_allowed_deprn_limit_amount(i)), 1, null, p_period_rec.period_counter) --PERIOD_COUNTER_FULLY_RESERVED
                   , PERIOD_COUNTER_FULLY_RETIRED
                   , PRODUCTION_CAPACITY
                   , t_reval_reserve(i)
                   , REVAL_CEILING
                   , UNIT_OF_MEASURE
                   , UNREVALUED_COST
                   , 'ADJ'
                   , PERCENT_SALVAGE_VALUE
                   , ALLOWED_DEPRN_LIMIT
                   , ALLOWED_DEPRN_LIMIT_AMOUNT
                   , t_period_counter_life_complete(i) -- phase5 decode(sign(t_new_adj_cost(i) - t_allowed_deprn_limit_amount(i)), 1, null, p_period_rec.period_counter) --PERIOD_COUNTER_LIFE_COMPLETE
                   , ADJUSTED_RECOVERABLE_COST
                   , ANNUAL_ROUNDING_FLAG
                   , GLOBAL_ATTRIBUTE1
                   , GLOBAL_ATTRIBUTE2
                   , GLOBAL_ATTRIBUTE3
                   , GLOBAL_ATTRIBUTE4
                   , GLOBAL_ATTRIBUTE5
                   , GLOBAL_ATTRIBUTE6
                   , GLOBAL_ATTRIBUTE7
                   , GLOBAL_ATTRIBUTE8
                   , GLOBAL_ATTRIBUTE9
                   , GLOBAL_ATTRIBUTE10
                   , GLOBAL_ATTRIBUTE11
                   , GLOBAL_ATTRIBUTE12
                   , GLOBAL_ATTRIBUTE13
                   , GLOBAL_ATTRIBUTE14
                   , GLOBAL_ATTRIBUTE15
                   , GLOBAL_ATTRIBUTE16
                   , GLOBAL_ATTRIBUTE17
                   , GLOBAL_ATTRIBUTE18
                   , GLOBAL_ATTRIBUTE19
                   , GLOBAL_ATTRIBUTE20
                   , GLOBAL_ATTRIBUTE_CATEGORY
                   , EOFY_ADJ_COST
                   , EOFY_FORMULA_FACTOR
                   , SHORT_FISCAL_YEAR_FLAG
                   , CONVERSION_DATE
                   , ORIGINAL_DEPRN_START_DATE
                   , REMAINING_LIFE1
                   , REMAINING_LIFE2
                   , OLD_ADJUSTED_COST
                   , t_new_formula_factor(i) --FORMULA_FACTOR
                   , GROUP_ASSET_ID
                   , SALVAGE_TYPE
                   , DEPRN_LIMIT_TYPE
                   , REDUCTION_RATE
                   , REDUCE_ADDITION_FLAG
                   , REDUCE_ADJUSTMENT_FLAG
                   , REDUCE_RETIREMENT_FLAG
                   , RECOGNIZE_GAIN_LOSS
                   , RECAPTURE_RESERVE_FLAG
                   , LIMIT_PROCEEDS_FLAG
                   , TERMINAL_GAIN_LOSS
                   , TRACKING_METHOD
                   , EXCLUDE_FULLY_RSV_FLAG
                   , EXCESS_ALLOCATION_OPTION
                   , DEPRECIATION_OPTION
                   , MEMBER_ROLLUP_FLAG
                   , ALLOCATE_TO_FULLY_RSV_FLAG
                   , ALLOCATE_TO_FULLY_RET_FLAG
                   , TERMINAL_GAIN_LOSS_AMOUNT
                   , CIP_COST
                   , YTD_PROCEEDS
                   , LTD_PROCEEDS
                   , LTD_COST_OF_REMOVAL
                   , t_eofy_reserve(i) --EOFY_RESERVE
                   , PRIOR_EOFY_RESERVE
                   , EOP_ADJ_COST
                   , EOP_FORMULA_FACTOR
                   , EXCLUDE_PROCEEDS_FROM_BASIS
                   , RETIREMENT_DEPRN_OPTION
                   , TERMINAL_GAIN_LOSS_FLAG
                   , SUPER_GROUP_ID
                   , OVER_DEPRECIATE_OPTION
                   , DISABLED_FLAG
                   , CASH_GENERATING_UNIT_ID
		   , t_rate_in_use(i)
 		   , t_nbv_at_switch(i) --phase5
                   , PRIOR_ADJUSTED_RATE
		   , PRIOR_BASIC_RATE
		   , PRIOR_LIFE_IN_MONTHS
		   , PRIOR_DEPRN_METHOD
		   , PRIOR_DEPRN_LIMIT
		   , PRIOR_DEPRN_LIMIT_AMOUNT
		   , PRIOR_DEPRN_LIMIT_TYPE
		   , EXTENDED_DEPRECIATION_PERIOD
		   , EXTENDED_DEPRN_FLAG
		   , t_period_counter_fully_ext(i) --bug 9786860
              FROM  FA_BOOKS
              WHERE TRANSACTION_HEADER_ID_IN = t_old_thid(i);
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Reached Commit ', ' ', p_log_level_rec => p_log_level_rec);
      end if;

      COMMIT;


   END LOOP; -- Outer Loop

   --
   --

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Process Posting', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN pos_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'pos_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END process_post;

FUNCTION call_deprn_basis(
              p_asset_hdr_rec     IN fa_api_types.asset_hdr_rec_type
            , p_trans_rec         IN fa_api_types.trans_rec_type
            , p_period_rec        IN fa_api_types.period_rec_type
            , p_asset_type_rec    IN fa_api_types.asset_type_rec_type
            , p_asset_fin_rec     IN fa_api_types.asset_fin_rec_type
            , p_asset_deprn_rec   IN fa_api_types.asset_deprn_rec_type
            , p_asset_desc_rec    IN fa_api_types.asset_desc_rec_type
            , x_new_raf              OUT NOCOPY NUMBER
            , x_new_formula_factor   OUT NOCOPY NUMBER
            , x_new_adjusted_cost    OUT NOCOPY NUMBER
            , p_mrc_sob_type_code IN VARCHAR2
            , p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'fa_process_impairment_pvt.call_deprn_basis';

   CURSOR c_get_next_period is
       SELECT cp.start_date
            , cp.end_date
            , cp.period_name
            , cp.period_num
            , fy.fiscal_year
            , fy.start_date
            , fy.end_date
       FROM   fa_calendar_periods cp,
              fa_deprn_periods dp,
              fa_fiscal_year fy
       WHERE  dp.book_type_code = p_asset_hdr_rec.book_type_code
       AND    dp.period_counter = p_period_rec.period_counter
       AND    cp.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
       AND    cp.start_date = dp.calendar_period_close_date + 1
       AND    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
       AND    cp.start_date between fy.start_date and fy.end_date;


   l_asset_fin_rec_new        fa_api_types.asset_fin_rec_type;
   l_period_rec               fa_api_types.period_rec_type; -- This holds info about next period

   --++++++++ variables for manual override ++++++++
   l_rate_source_rule             VARCHAR2(25);
   l_deprn_basis_rule             VARCHAR2(25);

   --+++++++++++++++ For calling faxcde +++++++++++++++
   l_dpr_in                       FA_STD_TYPES.dpr_struct;
   l_dpr_out                      FA_STD_TYPES.dpr_out_struct;
   l_dpr_arr                      FA_STD_TYPES.dpr_arr_type;
   l_running_mode                 NUMBER;

   l_deprn_reserve                NUMBER;
   l_temp_integer                 BINARY_INTEGER;
   l_temp_number                  number;

   l_eofy_rec_cost            number;
   l_eofy_sal_val             number;
   l_eop_rec_cost             number;
   l_eop_sal_val              number;

   db_err   exception;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, 'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   l_period_rec.period_counter := p_period_rec.period_counter + 1;

   OPEN c_get_next_period;
   FETCH c_get_next_period INTO l_period_rec.calendar_period_open_date
                              , l_period_rec.calendar_period_close_date
                              , l_period_rec.period_name
                              , l_period_rec.period_num
                              , l_period_rec.fiscal_year
                              , l_period_rec.fy_start_date
                              , l_period_rec.fy_end_date;
   CLOSE c_get_next_period;

   l_period_rec.period_open_date := sysdate;

   -- Setting 0s to avoid calling FA_CALC_DEPRN_BASIS1_PKG.GET_EOFY_EOP
   -- This should not be necessary for specific deprn basis rules which
   -- should be used only with some type of group assets
   l_eofy_rec_cost := 0;
   l_eofy_sal_val := 0;
   l_eop_rec_cost := 0;
   l_eop_sal_val := 0;

   -- Populate fin rec
   l_asset_fin_rec_new := p_asset_fin_rec;

   -- populate period rec for next period

   if (not FA_CACHE_PKG.fazccmt
             (l_asset_fin_rec_new.deprn_method_code,
              l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

   if (not fa_cache_pkg.fazccmt
             (l_asset_fin_rec_new.deprn_method_code,
              l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN => 'FA_AMORT_PKG.faxraf',  p_log_level_rec => p_log_level_rec);
      return FALSE;
   end if;

  -- Skipping call to faxcde because it is unnecessary for flat-cost with period end balance,
  -- use recoverable cost, period average, and beginning balance basis rules
  -- There are more cases which calling this function unnecessary but not include for this time.
  if (not(((fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT) and
           (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_COST) and
           (fa_cache_pkg.fazcdbr_record.rule_name  in ('PERIOD END BALANCE', 'PERIOD END AVERAGE',
                                                      'USE RECOVERABLE COST', 'BEGINNING PERIOD')) or
          fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_PROD))) then

      l_dpr_in.asset_num := p_asset_desc_rec.asset_number;
      l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
      l_dpr_in.book := p_asset_hdr_rec.book_type_code;
      l_dpr_in.asset_id := p_asset_hdr_rec.asset_id;
      l_dpr_in.adj_cost := l_asset_fin_rec_new.recoverable_cost;
      l_dpr_in.rec_cost := l_asset_fin_rec_new.recoverable_cost;
      l_dpr_in.reval_amo_basis := l_asset_fin_rec_new.reval_amortization_basis;
      l_dpr_in.deprn_rsv := 0;
      l_dpr_in.reval_rsv := p_asset_deprn_rec.reval_deprn_reserve;
      l_dpr_in.adj_rate := l_asset_fin_rec_new.adjusted_rate;
      l_dpr_in.rate_adj_factor := l_asset_fin_rec_new.rate_adjustment_factor;
      l_dpr_in.capacity := l_asset_fin_rec_new.production_capacity;
      l_dpr_in.adj_capacity := l_asset_fin_rec_new.adjusted_capacity;
      l_dpr_in.ltd_prod := 0;

      l_dpr_in.ceil_name := l_asset_fin_rec_new.ceiling_name;
      l_dpr_in.bonus_rule := l_asset_fin_rec_new.bonus_rule;
      l_dpr_in.method_code := l_asset_fin_rec_new.deprn_method_code;
      l_dpr_in.jdate_in_service :=
                    to_number(to_char(l_asset_fin_rec_new.date_placed_in_service, 'J'));
      l_dpr_in.prorate_jdate := to_number(to_char(l_asset_fin_rec_new.prorate_date, 'J'));
      l_dpr_in.deprn_start_jdate := to_number(to_char(l_asset_fin_rec_new.deprn_start_date, 'J'));
      l_dpr_in.jdate_retired := 0; -- don't know this is correct or not
      l_dpr_in.ret_prorate_jdate := 0; -- don't know this is correct or not
      l_dpr_in.life := l_asset_fin_rec_new.life_in_months;

      l_dpr_in.rsv_known_flag := TRUE;
      l_dpr_in.salvage_value := l_asset_fin_rec_new.salvage_value;
      l_dpr_in.pc_life_end := l_asset_fin_rec_new.period_counter_life_complete;
      l_dpr_in.adj_rec_cost := l_asset_fin_rec_new.adjusted_recoverable_cost;
      l_dpr_in.prior_fy_exp := p_asset_deprn_rec.prior_fy_expense;
      l_dpr_in.deprn_rounding_flag := l_asset_fin_rec_new.annual_deprn_rounding_flag;
      l_dpr_in.deprn_override_flag := p_trans_rec.deprn_override_flag;
      l_dpr_in.used_by_adjustment := TRUE;
      l_dpr_in.ytd_deprn := p_asset_deprn_rec.ytd_deprn;
      l_dpr_in.short_fiscal_year_flag := l_asset_fin_rec_new.short_fiscal_year_flag;
      l_dpr_in.conversion_date := l_asset_fin_rec_new.conversion_date;
      l_dpr_in.prorate_date := l_asset_fin_rec_new.prorate_date;
      l_dpr_in.orig_deprn_start_date := l_asset_fin_rec_new.orig_deprn_start_date;
      l_dpr_in.old_adj_cost := l_asset_fin_rec_new.old_adjusted_cost;
      l_dpr_in.formula_factor := l_asset_fin_rec_new.formula_factor;
      l_dpr_in.bonus_deprn_exp := p_asset_deprn_rec.bonus_deprn_amount;
      l_dpr_in.bonus_ytd_deprn := p_asset_deprn_rec.bonus_ytd_deprn;
      l_dpr_in.bonus_deprn_rsv := p_asset_deprn_rec.bonus_deprn_reserve;
      l_dpr_in.prior_fy_bonus_exp := p_asset_deprn_rec.prior_fy_bonus_expense;

      l_dpr_in.tracking_method := l_asset_fin_rec_new.tracking_method;
      l_dpr_in.allocate_to_fully_ret_flag := l_asset_fin_rec_new.allocate_to_fully_ret_flag;
      l_dpr_in.allocate_to_fully_rsv_flag := l_asset_fin_rec_new.allocate_to_fully_rsv_flag;
      l_dpr_in.excess_allocation_option := l_asset_fin_rec_new.excess_allocation_option;
      l_dpr_in.depreciation_option := l_asset_fin_rec_new.depreciation_option;
      l_dpr_in.member_rollup_flag := l_asset_fin_rec_new.member_rollup_flag;
      l_dpr_in.over_depreciate_option := l_asset_fin_rec_new.over_depreciate_option;
      l_dpr_in.mrc_sob_type_code := p_mrc_sob_type_code;
      l_dpr_in.set_of_books_id := p_asset_hdr_rec.set_of_books_id;

      --
      -- Not for what-if yet
      --
      l_running_mode := fa_std_types.FA_DPR_NORMAL;

      if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazcct', p_log_level_rec => p_log_level_rec);
         end if;

         raise db_err;
      end if;

      if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                 fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                 l_dpr_in.prorate_jdate,
                                 l_temp_number,
                                 l_dpr_in.y_begin,
                                 l_temp_integer, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                             fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                             fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);
         end if;

         raise db_err;
      end if;

      l_dpr_in.p_cl_begin := 1;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'number_per_fiscal_year',
                          fa_cache_pkg.fazcct_record.number_per_fiscal_year, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'l_period_rec.period_num', l_period_rec.period_num, p_log_level_rec => p_log_level_rec);
      end if;

      if (l_period_rec.period_num = 1) then
         l_dpr_in.y_end := l_period_rec.fiscal_year - 1;
         l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
      else
         l_dpr_in.y_end := l_period_rec.fiscal_year;
         l_dpr_in.p_cl_end := l_period_rec.period_num - 1;
      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'l_dpr_in.p_cl_end', l_dpr_in.p_cl_end, p_log_level_rec => p_log_level_rec);
      end if;

      l_dpr_in.rate_adj_factor := 1;

      -- manual override
      if fa_cache_pkg.fa_deprn_override_enabled then
         if (not fa_cache_pkg.fazccmt(
                     l_asset_fin_rec_new.deprn_method_code,
                     l_asset_fin_rec_new.life_in_months, p_log_level_rec => p_log_level_rec)) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            raise db_err;
         end if;

         l_rate_source_rule := fa_cache_pkg.fazccmt_record.rate_source_rule;
         l_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

         -- update override status only if satisfies condintion,
         -- otherwise do not update status when calculating RAF
         -- 1. formula; or
         -- 2. (calc or table) and cost

         l_dpr_in.update_override_status :=
               ((l_rate_source_rule = fa_std_types.FAD_RSR_FORMULA)
               OR (((l_rate_source_rule = fa_std_types.FAD_RSR_CALC)
               OR (l_rate_source_rule = fa_std_types.FAD_RSR_TABLE))
               AND (l_deprn_basis_rule = fa_std_types.FAD_DBR_COST)));
      end if;

      --+++++++ Call Depreciation engine for rate adjustment factor +++++++
      if not FA_CDE_PKG.faxcde(l_dpr_in,
                               l_dpr_arr,
                               l_dpr_out,
                               l_running_mode, p_log_level_rec => p_log_level_rec) then
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
         end if;

         raise db_err;
      end if;

      -- Bug 4129984.

      if ((fa_cache_pkg.fazcbc_record.AMORTIZE_REVAL_RESERVE_FLAG='YES') and
          (l_asset_fin_rec_new.Reval_Amortization_Basis is not null) and
          (p_asset_type_rec.asset_type = 'CAPITALIZED') and
          (l_asset_fin_rec_new.group_asset_id is null)) then

         l_asset_fin_rec_new.reval_amortization_basis := p_asset_deprn_rec.reval_deprn_reserve;
      end if;

   else -- in the case of skipping faxcde call
     l_dpr_out.new_adj_cost := l_asset_fin_rec_new.recoverable_cost;
     l_dpr_out.new_deprn_rsv := p_asset_deprn_rec.deprn_reserve;
     l_dpr_out.new_bonus_deprn_rsv := p_asset_deprn_rec.bonus_deprn_reserve;
   end if;



   -- code fix for bug no.3630495. added the following line to calculate the adjusted capacity
   if (nvl(l_asset_fin_rec_new.tracking_method, 'NO TRACK') = 'ALLOCATE') and    -- ENERGY
      (fa_cache_pkg.fazcdrd_record.rule_name = 'ENERGY PERIOD END BALANCE') then  -- ENERGY
      null;
   else
      l_asset_fin_rec_new.adjusted_capacity:=l_asset_fin_rec_new.production_capacity- nvl(l_dpr_out.new_ltd_prod, 0);
   end if;

   if (p_asset_hdr_rec.period_of_addition = 'Y') and
      (p_asset_type_rec.asset_type = 'GROUP') then
      l_asset_fin_rec_new.eofy_reserve := nvl(l_asset_fin_rec_new.eofy_reserve,
                                               p_asset_deprn_rec.deprn_reserve -
                                               p_asset_deprn_rec.ytd_deprn);
   else

      -- Fix for Bug#4541399: We have to activate this code
      -- only when l_asset_fin_rec_new.eofy_reserve is NULL
      if (l_asset_fin_rec_new.eofy_reserve is null) then
         l_asset_fin_rec_new.eofy_reserve := p_asset_deprn_rec.deprn_reserve -
                                              p_asset_deprn_rec.ytd_deprn;
      end if;

   end if;

   if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                       (p_event_type             => 'AMORT_ADJ',
                        p_asset_fin_rec_new      => l_asset_fin_rec_new,
                        p_asset_fin_rec_old      => p_asset_fin_rec,
                        p_asset_hdr_rec          => p_asset_hdr_rec,
                        p_asset_type_rec         => p_asset_type_rec,
                        p_asset_deprn_rec        => p_asset_deprn_rec,
                        p_trans_rec              => p_trans_rec,
                        p_trans_rec_adj          => p_trans_rec,
                        p_period_rec             => l_period_rec,
                        p_current_total_rsv      => p_asset_deprn_rec.deprn_reserve,
                        p_current_rsv            => p_asset_deprn_rec.deprn_reserve  -
                                                    p_asset_deprn_rec.bonus_deprn_reserve,
                        p_current_total_ytd      => p_asset_deprn_rec.ytd_deprn,
                        p_hyp_basis              => l_dpr_out.new_adj_cost,
                        p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                        p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                                    l_dpr_out.new_bonus_deprn_rsv,
                        p_eofy_recoverable_cost  => l_eofy_rec_cost,
                        p_eop_recoverable_cost   => l_eop_rec_cost,
                        p_eofy_salvage_value     => l_eofy_sal_val,
                        p_eop_salvage_value      => l_eop_sal_val,
                        p_mrc_sob_type_code      => p_mrc_sob_type_code,
                        p_used_by_adjustment     => 'ADJUSTMENT',
                        px_new_adjusted_cost     => x_new_adjusted_cost,
                        px_new_raf               => x_new_raf,
                        px_new_formula_factor    => x_new_formula_factor, p_log_level_rec => p_log_level_rec)) then
      raise db_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'call_deprn_basis', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN db_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'pos_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;
END call_deprn_basis;

FUNCTION create_cost_entries(
              p_asset_hdr_rec      IN fa_api_types.asset_hdr_rec_type
            , p_trans_rec          IN fa_api_types.trans_rec_type
            , p_period_rec         IN fa_api_types.period_rec_type
            , p_asset_type_rec     IN fa_api_types.asset_type_rec_type
            , p_cost               IN NUMBER
            , p_current_units      IN NUMBER
            , p_mrc_sob_type_code  IN VARCHAR2
            , p_calling_fn         IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'fa_impairment_post_pvt.create_cost_entries';

   l_adj             FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT;

   cre_err exception;
BEGIN
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Begin', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   -- Initializing common variables
   l_adj.transaction_header_id    := p_trans_rec.transaction_header_id;
   l_adj.asset_id                 := p_asset_hdr_rec.asset_id;
   l_adj.book_type_code           := p_asset_hdr_rec.book_type_code;
   l_adj.period_counter_created   := p_period_rec.period_counter;
   l_adj.period_counter_adjusted  := p_period_rec.period_counter;
   l_adj.current_units            := p_current_units;
   l_adj.selection_mode           := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
   l_adj.selection_retid          := 0;
   l_adj.leveling_flag            := TRUE;
   l_adj.flush_adj_flag           := TRUE; --FALSE;
   l_adj.gen_ccid_flag            := TRUE;
   l_adj.track_member_flag        := null;

   if p_asset_type_rec.asset_type = 'CIP' then
      l_adj.source_type_code := 'CIP ADDITION';
      l_adj.adjustment_type  := 'CIP COST';
      l_adj.account_type     := 'CIP_COST_ACCT';
      l_adj.account          := fa_cache_pkg.fazccb_record.CIP_COST_ACCT;
   else
      l_adj.source_type_code := 'ADDITION';
      l_adj.adjustment_type  := 'COST';
      l_adj.account_type     := 'ASSET_COST_ACCT';
      l_adj.account          := fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;
   end if;

   if p_cost > 0 then
      l_adj.debit_credit_flag   := 'DR';
      l_adj.adjustment_amount   := p_cost;
   else
      l_adj.debit_credit_flag   := 'CR';
      l_adj.adjustment_amount   := -p_cost;
   end if;

   l_adj.mrc_sob_type_code := p_mrc_sob_type_code;
   l_adj.set_of_books_id   := p_asset_hdr_rec.set_of_books_id;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'calling faxinaj ', 'COST', p_log_level_rec => p_log_level_rec);
   end if;


   if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              p_trans_rec.who_info.last_update_date,
              p_trans_rec.who_info.last_updated_by,
              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise cre_err;
   end if;

   l_adj.adjustment_type  := 'COST CLEARING';

   if p_asset_type_rec.asset_type = 'CIP' then
      l_adj.account_type     := 'CIP_CLEARING_ACCT';
      l_adj.account          := fa_cache_pkg.fazccb_record.CIP_CLEARING_ACCT;
   else
      l_adj.account_type     := 'ASSET_CLEARING_ACCT';
      l_adj.account          := fa_cache_pkg.fazccb_record.ASSET_CLEARING_ACCT;
   end if;

   if p_cost > 0 then
      l_adj.debit_credit_flag   := 'CR';
      l_adj.adjustment_amount   := p_cost;
   else
      l_adj.debit_credit_flag   := 'DR';
      l_adj.adjustment_amount   := -p_cost;
   end if;

   l_adj.mrc_sob_type_code := p_mrc_sob_type_code;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'calling faxinaj ', 'CLEARING', p_log_level_rec => p_log_level_rec);
   end if;

   if not FA_INS_ADJUST_PKG.faxinaj
             (l_adj,
              p_trans_rec.who_info.last_update_date,
              p_trans_rec.who_info.last_updated_by,
              p_trans_rec.who_info.last_update_login, p_log_level_rec => p_log_level_rec) then
      raise cre_err;
   end if;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'End', p_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN cre_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'cre_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END create_cost_entries;


END FA_IMPAIRMENT_POST_PVT;

/
