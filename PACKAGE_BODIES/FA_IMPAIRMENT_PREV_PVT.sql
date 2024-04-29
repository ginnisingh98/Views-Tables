--------------------------------------------------------
--  DDL for Package Body FA_IMPAIRMENT_PREV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_IMPAIRMENT_PREV_PVT" AS
/* $Header: FAVIMPWB.pls 120.8.12010000.9 2010/05/27 12:42:31 deemitta noship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

 --
  -- Datatypes for pl/sql tables below
  --
  TYPE tab_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  g_temp_number   number;
  g_temp_integer  binary_integer;
  g_temp_boolean  boolean;
  g_temp_varchar2 varchar2(100);
  g_error_flag tab_num15_type; --Bug#8614268


--*********************** Private functions ******************************--
-- private declaration for books (mrc) wrapper
FUNCTION process_depreciation(
              p_request_id        IN NUMBER,
              p_book_type_code    IN VARCHAR2,
              p_worker_id         IN NUMBER,
              p_period_rec        IN FA_API_TYPES.period_rec_type,
              p_imp_period_rec    IN FA_API_TYPES.period_rec_type,
              p_mrc_sob_type_code IN VARCHAR2,
              p_set_of_books_id   IN NUMBER,
              p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'FA_IMPAIRMENT_PREV_PVT.process_depreciation';

   CURSOR c_deprn is
       SELECT  bk.asset_id                          asset_id
             , ad.asset_category_id                 category_id
             , bk.deprn_method_code                 deprn_method_code
             , nvl(bk.life_in_months, 0)            life_in_months
             , bk.rate_adjustment_factor            rate_adjustment_factor
             , ad.current_units                     current_units
             , bk.adjustment_required_status        adjustment_required_status
             , bk.cost_change_flag                  cost_change_flag
             , bk.retirement_pending_flag           retirement_pending_flag
             , bk.period_counter_fully_retired      period_counter_fully_retired
             , ad.asset_number                      asset_number
             , bk.adjusted_cost                     adjusted_cost
             , nvl(bk.adjusted_rate, 0)             adjusted_rate
             , bk.recoverable_cost                  recoverable_cost
             , nvl(bk.reval_amortization_basis, 0)  reval_amortization_basis
             , bk.ceiling_name                      ceiling_name
             , bk.bonus_rule                        bonus_rule
             , bk.deprn_start_date                  deprn_start_date
             , bk.date_placed_in_service            date_placed_in_service
             , bk.prorate_date                      prorate_date
             , bk.cost                              cost
             , bk.production_capacity               production_capacity
             , bk.adjusted_capacity                 adjusted_capacity
             , bk.annual_deprn_rounding_flag        annual_deprn_rounding_flag
             , bk.salvage_value                     salvage_value
             , bk.period_counter_life_complete      period_counter_life_complete
             , bk.adjusted_recoverable_cost         adjusted_recoverable_cost
             , nvl(bk.short_fiscal_year_flag, 'NO') short_fiscal_year_flag
             , bk.conversion_date                   conversion_date
             , bk.original_deprn_start_date         original_deprn_start_date
             , nvl(bk.formula_factor, 1)            formula_factor
             , nvl(bk.old_adjusted_cost, 1)         old_adjusted_cost
             , bk.tracking_method                   tracking_method
             , bk.allocate_to_fully_ret_flag        allocate_to_fully_ret_flag
             , bk.allocate_to_fully_rsv_flag        allocate_to_fully_rsv_flag
             , bk.excess_allocation_option          excess_allocation_option
             , bk.depreciation_option               depreciation_option
             , bk.member_rollup_flag                member_rollup_flag
             , ad.asset_type                        asset_type
             , bk.group_asset_id                    group_asset_id
             , nvl(bk.eofy_reserve, 0)              eofy_reserve
             , bk.exclude_fully_rsv_flag            exclude_fully_rsv_flag
             , 0  over_depreciate_option       -- over_depreciate_option
             , 0  terminal_gain_loss --terminal gain loss
             , 0  terminal_gain_loss_flag --terminal gain loss flag
             , 0  super_group_id               -- super_group_id
             , 0  super_group_pct_sal_value --super grp pct salvage value
             , 0 net_book_value -- net_book_value
             , 0 net_selling_price -- net_selling_price
             , 0 value_in_use -- value_in_use
             , imp.ytd_impairment -- ytd_impairment
             , imp.impairment_reserve -- impairment_reserve
             , sysdate deprn_run_date -- deprn_run_date
             , 0 deprn_amount -- deprn_amount
             , 0 ytd_deprn -- ytd_deprn
             , 0 deprn_reserve -- deprn_reserve
             , 'DEPRN' deprn_source_code -- deprn_source_code
             , 0 bonus_rate -- bonus_rate
             , 0 ltd_production -- ltd_production
             , 0 production -- production
             , 0 reval_amortization -- reval_amortization
             , 0 reval_deprn_expense -- reval_deprn_expense
             , 0 reval_reserve -- reval_reserve
             , 0 ytd_production -- ytd_production
             , 0 ytd_reval_deprn_expense -- ytd_reval_deprn_expense
             , 0 prior_fy_expense -- prior_fy_expense
             , 0 bonus_deprn_amount -- bonus_deprn_amount
             , 0 bonus_ytd_deprn -- bonus_ytd_deprn
             , 0 bonus_deprn_reserve -- bonus_deprn_reserve
             , 0 prior_fy_bonus_expense -- prior_fy_bonus_expense
             , 0 deprn_override_flag -- deprn_override_flag
             , 0 system_deprn_amount -- system_deprn_amount
             , 0 system_bonus_deprn_amount -- system_bonus_deprn_amount
             , 0 deprn_adjustment_amount -- deprn_adjustment_amount
             , 0 bonus_deprn_adjustment_amount -- bonus_deprn_adjustment_amount
             , imp.rowid imp_rowid
             , 'N' Period_of_addition_flag  -- Period_of_addition_flag
             , imp.impairment_id -- impairment_id
             , 0 capital_adjustment -- Bug 6666666 : Capital Adjustment amount
             , 0 general_fund -- Bug 6666666 : General Fund Balance Amount
             , bk.ALLOWED_DEPRN_LIMIT_AMOUNT
	     , bk.depreciate_flag --phase5
	     , bk.period_counter_fully_reserved --phase5
       FROM    fa_additions_b ad,
               fa_methods mt,
               fa_books bk,
               fa_itf_impairments imp
       WHERE   bk.book_type_code = p_book_type_code
       AND     (bk.period_counter_fully_retired is null OR
                    bk.adjustment_required_status <> 'NONE')
       --phase5 AND     bk.depreciate_flag = 'YES'
       AND     bk.date_effective <= nvl(p_period_rec.period_close_date, sysdate)
       AND     bk.transaction_header_id_out is null
       AND     AD.ASSET_ID=BK.ASSET_ID
       AND     ad.asset_type = 'CAPITALIZED'
       AND     bk.group_asset_id is null
       AND     MT.METHOD_CODE = BK.DEPRN_METHOD_CODE
       AND     nvl(mt.life_in_months, -99) = nvl(bk.life_in_months, -99)
       AND     bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       AND     bk.asset_id = imp.asset_id
       AND     imp.book_type_code = p_book_type_code
       AND     imp.request_id = p_request_id
       AND     imp.period_counter <= p_period_rec.period_counter
       AND     imp.worker_id = p_worker_id;

   CURSOR c_mc_deprn is
       SELECT  bk.asset_id                          asset_id
             , ad.asset_category_id                 category_id
             , bk.deprn_method_code                 deprn_method_code
             , nvl(bk.life_in_months, 0)            life_in_months
             , bk.rate_adjustment_factor            rate_adjustment_factor
             , ad.current_units                     current_units
             , bk.adjustment_required_status        adjustment_required_status
             , bk.cost_change_flag                  cost_change_flag
             , bk.retirement_pending_flag           retirement_pending_flag
             , bk.period_counter_fully_retired      period_counter_fully_retired
             , ad.asset_number                      asset_number
             , bk.adjusted_cost                     adjusted_cost
             , nvl(bk.adjusted_rate, 0)             adjusted_rate
             , bk.recoverable_cost                  recoverable_cost
             , nvl(bk.reval_amortization_basis, 0)  reval_amortization_basis
             , bk.ceiling_name                      ceiling_name
             , bk.bonus_rule                        bonus_rule
             , bk.deprn_start_date                  deprn_start_date
             , bk.date_placed_in_service            date_placed_in_service
             , bk.prorate_date                      prorate_date
             , bk.cost                              cost
             , bk.production_capacity               production_capacity
             , bk.adjusted_capacity                 adjusted_capacity
             , bk.annual_deprn_rounding_flag        annual_deprn_rounding_flag
             , bk.salvage_value                     salvage_value
             , bk.period_counter_life_complete      period_counter_life_complete
             , bk.adjusted_recoverable_cost         adjusted_recoverable_cost
             , nvl(bk.short_fiscal_year_flag, 'NO') short_fiscal_year_flag
             , bk.conversion_date                   conversion_date
             , bk.original_deprn_start_date         original_deprn_start_date
             , nvl(bk.formula_factor, 1)            formula_factor
             , nvl(bk.old_adjusted_cost, 1)         old_adjusted_cost
             , bk.tracking_method                   tracking_method
             , bk.allocate_to_fully_ret_flag        allocate_to_fully_ret_flag
             , bk.allocate_to_fully_rsv_flag        allocate_to_fully_rsv_flag
             , bk.excess_allocation_option          excess_allocation_option
             , bk.depreciation_option               depreciation_option
             , bk.member_rollup_flag                member_rollup_flag
             , ad.asset_type                        asset_type
             , bk.group_asset_id                    group_asset_id
             , nvl(bk.eofy_reserve, 0)              eofy_reserve
             , bk.exclude_fully_rsv_flag            exclude_fully_rsv_flag
             , 0  over_depreciate_option       -- over_depreciate_option
             , 0  terminal_gain_loss --terminal gain loss
             , 0  terminal_gain_loss_flag --terminal gain loss flag
             , 0  super_group_id               -- super_group_id
             , 0  super_group_pct_sal_value --super grp pct salvage value
             , 0 net_book_value -- net_book_value
             , 0 net_selling_price -- net_selling_price
             , 0 value_in_use -- value_in_use
             , imp.ytd_impairment -- ytd_impairment
             , imp.impairment_reserve -- impairment_reserve
             , sysdate deprn_run_date -- deprn_run_date
             , 0 deprn_amount -- deprn_amount
             , 0 ytd_deprn -- ytd_deprn
             , 0 deprn_reserve -- deprn_reserve
             , 'DEPRN' deprn_source_code -- deprn_source_code
             , 0 bonus_rate -- bonus_rate
             , 0 ltd_production -- ltd_production
             , 0 production -- production
             , 0 reval_amortization -- reval_amortization
             , 0 reval_deprn_expense -- reval_deprn_expense
             , 0 reval_reserve -- reval_reserve
             , 0 ytd_production -- ytd_production
             , 0 ytd_reval_deprn_expense -- ytd_reval_deprn_expense
             , 0 prior_fy_expense -- prior_fy_expense
             , 0 bonus_deprn_amount -- bonus_deprn_amount
             , 0 bonus_ytd_deprn -- bonus_ytd_deprn
             , 0 bonus_deprn_reserve -- bonus_deprn_reserve
             , 0 prior_fy_bonus_expense -- prior_fy_bonus_expense
             , 0 deprn_override_flag -- deprn_override_flag
             , 0 system_deprn_amount -- system_deprn_amount
             , 0 system_bonus_deprn_amount -- system_bonus_deprn_amount
             , 0 deprn_adjustment_amount -- deprn_adjustment_amount
             , 0 bonus_deprn_adjustment_amount -- bonus_deprn_adjustment_amount
             , imp.rowid imp_rowid
             , 'N' Period_of_addition_flag  -- Period_of_addition_flag
             , imp.impairment_id -- impairment_id
             , 0 capital_adjustment -- Bug 6666666 : Capital Adjustment amount
             , 0 general_fund -- Bug 6666666 : General Fund Balance Amount
             , bk.ALLOWED_DEPRN_LIMIT_AMOUNT
	     , bk.depreciate_flag --phase5
	     , bk.period_counter_fully_reserved --phase5
       FROM    fa_additions_b ad,
               fa_methods mt,
               fa_mc_books bk,
               fa_mc_itf_impairments imp
       WHERE   bk.book_type_code = p_book_type_code
       AND     bk.set_of_books_id = p_set_of_books_id
       AND     (bk.period_counter_fully_retired is null OR
                    bk.adjustment_required_status <> 'NONE')
       --phase5 AND     bk.depreciate_flag = 'YES'
       AND     bk.date_effective <= nvl(p_period_rec.period_close_date, sysdate)
       AND     bk.transaction_header_id_out is null
       AND     AD.ASSET_ID=BK.ASSET_ID
       AND     ad.asset_type = 'CAPITALIZED'
       AND     bk.group_asset_id is null
       AND     MT.METHOD_CODE = BK.DEPRN_METHOD_CODE
       AND     nvl(mt.life_in_months, -99) = nvl(bk.life_in_months, -99)
       AND     bk.deprn_start_date <= p_period_rec.calendar_period_close_date
       AND     bk.asset_id = imp.asset_id
       AND     imp.book_type_code = p_book_type_code
       AND     imp.request_id = p_request_id
       AND     imp.period_counter <= p_period_rec.period_counter
       AND     imp.worker_id = p_worker_id
       AND     imp.set_of_books_id = p_set_of_books_id;




   CURSOR c_get_period_rec (c_start_date  date) IS
     select cp.period_num
          , fy.fiscal_year
     from   fa_fiscal_year fy
          , fa_calendar_periods cp
     where  cp.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
     and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and    cp.start_date between fy.start_date and fy.end_date
     and    c_start_date between cp.start_date and cp.end_date;



   t_asset_id                      tab_num15_type;
   t_category_id                   tab_num15_type;
   t_deprn_method_code             tab_char30_type;
   t_life_in_months                tab_num15_type;
   t_rate_adjustment_factor        tab_num_type;
   t_current_units                 tab_num_type;
   t_adjustment_required_status    tab_char30_type;
   t_cost_change_flag              tab_char3_type;
   t_retirement_pending_flag       tab_char3_type;
   t_period_counter_fully_retired  tab_num15_type;
   t_asset_number                  tab_char30_type;
   t_adjusted_cost                 tab_num_type;
   t_adjusted_rate                 tab_num_type;
   t_recoverable_cost              tab_num_type;
   t_reval_amortization_basis      tab_num_type;
   t_ceiling_name                  tab_char30_type;
   t_bonus_rule                    tab_char30_type;
   t_deprn_start_date              tab_date_type;
   t_date_placed_in_service        tab_date_type;
   t_prorate_date                  tab_date_type;
   t_cost                          tab_num_type;
   t_production_capacity           tab_num_type;
   t_adjusted_capacity             tab_num_type;
   t_annual_deprn_rounding_flag    tab_char3_type;
   t_salvage_value                 tab_num_type;
   t_period_counter_life_complete  tab_num15_type;
   t_adjusted_recoverable_cost     tab_num_type;
   t_short_fiscal_year_flag        tab_char3_type;
   t_conversion_date               tab_date_type;
   t_original_deprn_start_date     tab_date_type;
   t_formula_factor                tab_num_type;
   t_old_adjusted_cost             tab_num_type;
   t_tracking_method               tab_char30_type;
   t_allocate_to_fully_ret_flag    tab_char1_type;
   t_allocate_to_fully_rsv_flag    tab_char1_type;
   t_excess_allocation_option      tab_char30_type;
   t_depreciation_option           tab_char30_type;
   t_member_rollup_flag            tab_char1_type;
   t_asset_type                    tab_char30_type;
   t_group_asset_id                tab_num15_type;
   t_eofy_reserve                  tab_num_type;
   t_exclude_fully_rsv_flag        tab_char1_type;
   t_over_depreciate_option        tab_char30_type;
   t_terminal_gain_loss            tab_char30_type;
   t_terminal_gain_loss_flag       tab_char1_type;
   t_super_group_id                tab_num15_type;
   t_super_group_pct_sal_value     tab_num_type;
   t_net_book_value                tab_num_type;
   t_net_selling_price             tab_num_type;
   t_value_in_use                  tab_num_type;
   t_ytd_impairment                tab_num_type;
   t_impairment_reserve                tab_num_type;
   t_deprn_run_date                tab_date_type;
   t_deprn_amount                  tab_num_type;
   t_ytd_deprn                     tab_num_type;
   t_deprn_reserve                 tab_num_type;
   t_deprn_source_code             tab_char30_type;
   t_bonus_rate                    tab_num_type;
   t_ltd_production                tab_num_type;
   t_production                    tab_num_type;
   t_reval_amortization            tab_num_type;
   t_reval_deprn_expense           tab_num_type;
   t_reval_reserve                 tab_num_type;
   t_ytd_production                tab_num_type;
   t_ytd_reval_deprn_expense       tab_num_type;
   t_prior_fy_expense              tab_num_type;
   t_bonus_deprn_amount            tab_num_type;
   t_bonus_ytd_deprn               tab_num_type;
   t_bonus_deprn_reserve           tab_num_type;
   t_prior_fy_bonus_expense        tab_num_type;
   t_deprn_override_flag           tab_char30_type;
   t_system_deprn_amount           tab_num_type;
   t_system_bonus_deprn_amount     tab_num_type;
   t_deprn_adjustment_amount       tab_num_type;
   t_bonus_deprn_adj_amount        tab_num_type;
   t_imp_rowid                     tab_rowid_type;
   t_period_of_addition_flag       tab_char1_type;
   t_impairment_id                 tab_num15_type;
   t_capital_adjustment            tab_num_type; -- Bug 6666666
   t_general_fund                  tab_num_type; -- Bug 6666666
   t_allowed_deprn_limit_amount    tab_num_type;
   t_depreciate_flag               tab_char1_type; --phase5
   t_period_fully_reserve          tab_num_type;--phase5
   l_dpr_row         FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
   l_status          boolean;
   l_dpr_in          fa_std_types.dpr_struct;
   l_dpr_out         fa_std_types.dpr_out_struct;
   l_dpr_arr         fa_std_types.dpr_arr_type;
   l_pa_dpr_in       fa_std_types.dpr_struct;
   l_pa_dpr_out      fa_std_types.dpr_out_struct;
   l_pa_dpr_arr      fa_std_types.dpr_arr_type;

   l_running_mode    VARCHAR2(20);
   l_asset_hdr_rec   fa_api_types.asset_hdr_rec_type;

   l_limit           binary_integer := 200;  -- limit constant for c_deprn cursor
   dpr_err           exception;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Process Depreciation', 'BEGIN', p_log_level_rec => p_log_level_rec);
   end if;

   g_error_flag.DELETE ; --Bug#8614268
   --
   -- Outer Loop
   if (p_mrc_sob_type_code = 'R') then
      OPEN c_mc_deprn;
   else
      OPEN c_deprn;
   end if;

   LOOP

      if (p_mrc_sob_type_code = 'R') then
         FETCH c_mc_deprn BULK COLLECT INTO t_asset_id
                                          , t_category_id
                                          , t_deprn_method_code
                                          , t_life_in_months
                                          , t_rate_adjustment_factor
                                          , t_current_units
                                          , t_adjustment_required_status
                                          , t_cost_change_flag
                                          , t_retirement_pending_flag
                                          , t_period_counter_fully_retired
                                          , t_asset_number
                                          , t_adjusted_cost
                                          , t_adjusted_rate
                                          , t_recoverable_cost
                                          , t_reval_amortization_basis
                                          , t_ceiling_name
                                          , t_bonus_rule
                                          , t_deprn_start_date
                                          , t_date_placed_in_service
                                          , t_prorate_date
                                          , t_cost
                                          , t_production_capacity
                                          , t_adjusted_capacity
                                          , t_annual_deprn_rounding_flag
                                          , t_salvage_value
                                          , t_period_counter_life_complete
                                          , t_adjusted_recoverable_cost
                                          , t_short_fiscal_year_flag
                                          , t_conversion_date
                                          , t_original_deprn_start_date
                                          , t_formula_factor
                                          , t_old_adjusted_cost
                                          , t_tracking_method
                                          , t_allocate_to_fully_ret_flag
                                          , t_allocate_to_fully_rsv_flag
                                          , t_excess_allocation_option
                                          , t_depreciation_option
                                          , t_member_rollup_flag
                                          , t_asset_type
                                          , t_group_asset_id
                                          , t_eofy_reserve
                                          , t_exclude_fully_rsv_flag
                                          , t_over_depreciate_option
                                          , t_terminal_gain_loss
                                          , t_terminal_gain_loss_flag
                                          , t_super_group_id
                                          , t_super_group_pct_sal_value
                                          , t_net_book_value
                                          , t_net_selling_price
                                          , t_value_in_use
                                          , t_ytd_impairment
                                          , t_impairment_reserve
                                          , t_deprn_run_date
                                          , t_deprn_amount
                                          , t_ytd_deprn
                                          , t_deprn_reserve
                                          , t_deprn_source_code
                                          , t_bonus_rate
                                          , t_ltd_production
                                          , t_production
                                          , t_reval_amortization
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
                                          , t_imp_rowid
                                          , t_period_of_addition_flag
                                          , t_impairment_id
                                          , t_capital_adjustment -- Bug 6666666
                                          , t_general_fund       -- Bug 6666666
                                          , t_allowed_deprn_limit_amount
					  , t_depreciate_flag --phase5
					  , t_period_fully_reserve --phase5
                                          LIMIT l_limit;

      else
         FETCH c_deprn BULK COLLECT INTO t_asset_id
                                       , t_category_id
                                       , t_deprn_method_code
                                       , t_life_in_months
                                       , t_rate_adjustment_factor
                                       , t_current_units
                                       , t_adjustment_required_status
                                       , t_cost_change_flag
                                       , t_retirement_pending_flag
                                       , t_period_counter_fully_retired
                                       , t_asset_number
                                       , t_adjusted_cost
                                       , t_adjusted_rate
                                       , t_recoverable_cost
                                       , t_reval_amortization_basis
                                       , t_ceiling_name
                                       , t_bonus_rule
                                       , t_deprn_start_date
                                       , t_date_placed_in_service
                                       , t_prorate_date
                                       , t_cost
                                       , t_production_capacity
                                       , t_adjusted_capacity
                                       , t_annual_deprn_rounding_flag
                                       , t_salvage_value
                                       , t_period_counter_life_complete
                                       , t_adjusted_recoverable_cost
                                       , t_short_fiscal_year_flag
                                       , t_conversion_date
                                       , t_original_deprn_start_date
                                       , t_formula_factor
                                       , t_old_adjusted_cost
                                       , t_tracking_method
                                       , t_allocate_to_fully_ret_flag
                                       , t_allocate_to_fully_rsv_flag
                                       , t_excess_allocation_option
                                       , t_depreciation_option
                                       , t_member_rollup_flag
                                       , t_asset_type
                                       , t_group_asset_id
                                       , t_eofy_reserve
                                       , t_exclude_fully_rsv_flag
                                       , t_over_depreciate_option
                                       , t_terminal_gain_loss
                                       , t_terminal_gain_loss_flag
                                       , t_super_group_id
                                       , t_super_group_pct_sal_value
                                       , t_net_book_value
                                       , t_net_selling_price
                                       , t_value_in_use
                                       , t_ytd_impairment
                                       , t_impairment_reserve
                                       , t_deprn_run_date
                                       , t_deprn_amount
                                       , t_ytd_deprn
                                       , t_deprn_reserve
                                       , t_deprn_source_code
                                       , t_bonus_rate
                                       , t_ltd_production
                                       , t_production
                                       , t_reval_amortization
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
                                       , t_imp_rowid
                                       , t_period_of_addition_flag
                                       , t_impairment_id
                                       , t_capital_adjustment -- Bug 6666666
                                       , t_general_fund       -- Bug 6666666
                                       , t_allowed_deprn_limit_amount
				       , t_depreciate_flag --phase5
				       , t_period_fully_reserve --phase5
                                       LIMIT l_limit;

      end if;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'fetch count', t_asset_id.count, p_log_level_rec => p_log_level_rec);
      end if;

      if (t_asset_id.count = 0) then

         if (p_mrc_sob_type_code = 'R') then
            CLOSE c_mc_deprn;
         else
            CLOSE c_deprn;
         end if;

         EXIT;

      end if;

      FOR i in 1..t_asset_id.count LOOP

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Processing', t_asset_id(i));
            fa_debug_pkg.add(l_calling_fn, 'current period', p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'impaired period', p_imp_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
         end if;

	 /*Phase5 Restrict Impairment posted on Asset added without reserve and depreciation flag as NO*/
         IF t_depreciate_flag(i) = 'NO' then
	    IF NOT FA_ASSET_VAL_PVT.check_non_depreciating_asset (
	                           p_asset_id          => t_asset_id(i)
                                 , p_book_type_code    => p_book_type_code
                                 , p_log_level_rec     => p_log_level_rec) then
               IF (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling FA_ASSET_VAL_PVT.check_non_depreciating_asset',
                                   t_asset_id(i), p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'You can not Post an impairment for this asset',
                                   'As this asset is added with depreciate flag as NO and without reserve', p_log_level_rec => p_log_level_rec);
               END IF;
	       fa_srvr_msg.add_message(
                         calling_fn => null,
                         name       => 'FA_NO_IMP_NON_DEPR_ASSET',
                         token1     => 'FA_ASSET_NUM',
                         value1     =>  '' || t_asset_number(i),
                         p_log_level_rec => p_log_level_rec);

               raise dpr_err;
            END IF;
	 END IF;
	 /*end phase5*/

         --
         -- If this impairment is back dated then call function to calculate reserve
         -- as of impairment period
         --
         if (p_period_rec.period_counter > p_imp_period_rec.period_counter) then
            if not process_history(p_request_id        => p_request_id
                                 , p_impairment_id     => t_impairment_id(i)
                                 , p_asset_id          => t_asset_id(i)
                                 , p_book_type_code    => p_book_type_code
                                 , p_period_rec        => p_period_rec
                                 , p_imp_period_rec    => p_imp_period_rec
                                 , p_date_placed_in_service => t_date_placed_in_service(i)
                                 , x_dpr_out           => l_dpr_out
                                 , x_dpr_in            => l_dpr_in
                                 , p_mrc_sob_type_code => p_mrc_sob_type_code
                                 , p_calling_fn        => l_calling_fn
                                 , p_log_level_rec     => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                   fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);

               end if;

               raise dpr_err;


            end if;

            l_dpr_row.impairment_rsv := nvl(l_dpr_out.new_impairment_rsv, 0);
         else

            -- Terminal Gain loss in impairment should not be necessary because
            -- group will have no cost and no impairment should allowed


            -- Process periodic depreciation

            --+++++++ Populating l_dpr_in to call faxcde ++++++++++
            l_dpr_in.asset_num             := t_asset_number(i);
            l_dpr_in.calendar_type         := fa_cache_pkg.fazcbc_record.deprn_calendar;
            l_dpr_in.book                  := p_book_type_code;
            l_dpr_in.asset_id              := t_asset_id(i);

            l_dpr_row.asset_id             := t_asset_id(i);
            l_dpr_row.book                 := p_book_type_code;
            l_dpr_row.period_ctr           := p_period_rec.period_counter;
            l_dpr_row.dist_id              := 0;
            l_dpr_row.mrc_sob_type_code    := p_mrc_sob_type_code;
            l_dpr_row.set_of_books_id      := p_set_of_books_id; --8666930

            l_running_mode                 := 'STANDARD';

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Calling', 'query_balances_int', p_log_level_rec => p_log_level_rec);
            end if;

            fa_query_balances_pkg.query_balances_int(
                                   X_DPR_ROW               => l_dpr_row,
                                   X_RUN_MODE              => l_running_mode,
                                   X_DEBUG                 => FALSE,
                                   X_SUCCESS               => l_status,
                                   X_CALLING_FN            => l_calling_fn,
                                   X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

            if (NOT l_status) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'ERROR',
                                   'Calling fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
               end if;

               raise dpr_err;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_adjust_exp', l_dpr_row.deprn_adjust_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_exp', l_dpr_row.deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_rsv', l_dpr_row.deprn_rsv, p_log_level_rec => p_log_level_rec);
            end if;

            -- Bug5768359: Need to refrect exp into deprn adj amount in DD.
            l_dpr_row.deprn_adjust_exp := nvl(l_dpr_row.deprn_exp, 0);
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Query balance returned', 'following', p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_exp', l_dpr_row.deprn_exp, p_log_level_rec => p_log_level_rec);
            end if;


            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Start populating', 'l_dpr_in', p_log_level_rec => p_log_level_rec);
            end if;

	    /*Phase5 Restrict call to deprn engine faxcde for assets having depreciation flag equal to  NO*/
            /*Bug 9574021 Added condition for Extended Assets*/
            IF ((t_depreciate_flag(i) = 'NO') OR (t_period_fully_reserve(i) is not null AND t_deprn_method_code(i) <> 'JP-STL-EXTND')) then
	       IF (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, '======================================',
                                   'NON DEPRECIATING/FULLY RESERVED ASSET', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'Skipping the call to FAXCDE for asset',
                                   t_asset_id(i), p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, '======================================',
                                   'NON DEPRECIATING/FULLY RESERVED ASSET', p_log_level_rec => p_log_level_rec);
               END IF;
            ELSE --Deprn flag = YES

               l_dpr_in.rec_cost                   := t_recoverable_cost(i);
               l_dpr_in.salvage_value              := t_salvage_value(i);
               l_dpr_in.adj_rec_cost               := t_adjusted_recoverable_cost(i);
               l_dpr_in.adj_cost                   := t_adjusted_cost(i);
               l_dpr_in.old_adj_cost               := t_old_adjusted_cost(i);
               l_dpr_in.formula_factor             := t_formula_factor(i);
               l_dpr_in.rate_adj_factor            := t_rate_adjustment_factor(i);
               l_dpr_in.eofy_reserve               := t_eofy_reserve(i);
               l_dpr_in.method_code                := t_deprn_method_code(i);
               l_dpr_in.life                       := t_life_in_months(i);
               l_dpr_in.adj_rate                   := t_adjusted_rate(i);
               l_dpr_in.capacity                   := t_production_capacity(i);
               l_dpr_in.adj_capacity               := t_adjusted_capacity(i);
               l_dpr_in.bonus_rule                 := t_bonus_rule(i);
               l_dpr_in.ceil_name                  := t_ceiling_name(i);
               l_dpr_in.reval_amo_basis            := t_reval_amortization_basis(i);
               l_dpr_in.jdate_in_service           := to_number(to_char(t_date_placed_in_service(i), 'J'));
               l_dpr_in.prorate_jdate              := to_number(to_char(t_prorate_date(i), 'J'));
               l_dpr_in.deprn_start_jdate          := to_number(to_char(t_deprn_start_date(i), 'J'));
               l_dpr_in.prorate_date               := t_prorate_date(i);
               l_dpr_in.orig_deprn_start_date      := t_original_deprn_start_date(i);
               l_dpr_in.jdate_retired              := 0;
               l_dpr_in.ret_prorate_jdate          := 0;
               l_dpr_in.ltd_prod                   := l_dpr_row.ltd_prod;
               l_dpr_in.ytd_deprn                  := l_dpr_row.ytd_deprn;
               l_dpr_in.deprn_rsv                  := l_dpr_row.deprn_rsv;
               l_dpr_in.reval_rsv                  := l_dpr_row.reval_rsv;
               l_dpr_in.bonus_deprn_exp            := 0;
               l_dpr_in.bonus_ytd_deprn            := l_dpr_row.bonus_ytd_deprn;
               l_dpr_in.bonus_deprn_rsv            := l_dpr_row.bonus_deprn_rsv;
               l_dpr_in.prior_fy_exp               := l_dpr_row.prior_fy_exp;
               l_dpr_in.prior_fy_bonus_exp         := l_dpr_row.prior_fy_bonus_exp;
               l_dpr_in.impairment_exp             := 0;
               l_dpr_in.ytd_impairment             := l_dpr_row.ytd_impairment;
               l_dpr_in.impairment_rsv             := l_dpr_row.impairment_rsv;
               l_dpr_in.short_fiscal_year_flag     := t_short_fiscal_year_flag(i);
               l_dpr_in.conversion_date            := t_conversion_date(i);
               l_dpr_in.super_group_id             := t_super_group_id(i);
               l_dpr_in.over_depreciate_option     := t_over_depreciate_option(i);
               l_dpr_in.tracking_method            := t_tracking_method(i);
               l_dpr_in.allocate_to_fully_ret_flag := t_allocate_to_fully_ret_flag(i);
               l_dpr_in.allocate_to_fully_rsv_flag := t_allocate_to_fully_rsv_flag(i);
               l_dpr_in.excess_allocation_option   := t_excess_allocation_option(i);
               l_dpr_in.depreciation_option        := t_depreciation_option(i);
               l_dpr_in.member_rollup_flag         := t_member_rollup_flag(i);
               l_dpr_in.pc_life_end                := t_period_counter_life_complete(i);
               l_dpr_in.deprn_override_flag        := fa_std_types.FA_NO_OVERRIDE;
               l_dpr_in.rsv_known_flag             := TRUE;
               l_dpr_in.deprn_rounding_flag        := 'ADJ';
               l_dpr_in.used_by_adjustment         := FALSE;
               l_dpr_in.capital_adjustment         := l_dpr_row.capital_adjustment; -- Bug 6666666
               l_dpr_in.general_fund               := l_dpr_row.general_fund;             -- Bug 6666666
               l_dpr_in.set_of_books_id            := p_set_of_books_id;
               l_dpr_in.mrc_sob_type_code          := p_mrc_sob_type_code;   -- Bug 9700559
               l_running_mode                      := fa_std_types.FA_DPR_NORMAL;

               -- manual override
               if fa_cache_pkg.fa_deprn_override_enabled then
                  l_dpr_in.update_override_status := TRUE;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
               end if;

               if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                             fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                             l_dpr_in.prorate_jdate,
                                             g_temp_number,
                                             l_dpr_in.y_begin,
                                             g_temp_integer, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                      fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                      fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);
                  end if;

                  raise dpr_err;
               end if;

               if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar, p_log_level_rec => p_log_level_rec) then
                  raise dpr_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 't_adjustment_required_status',
                                   t_adjustment_required_status(i));
                  fa_debug_pkg.add(l_calling_fn, 'l_dpr_in.deprn_rsv', l_dpr_in.deprn_rsv, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 't_deprn_start_date', t_deprn_start_date(i));
               end if;

               l_pa_dpr_out := null; --Bug#8744490
               ---        *****************************      ---
               ---        Prior period addition process      ---
               ---        *****************************      ---
               if (t_adjustment_required_status(i) = 'ADD') and
                  (l_dpr_in.deprn_rsv = 0) and
                  (t_deprn_start_date(i) < p_period_rec.calendar_period_open_date ) then

                  l_pa_dpr_in  := null;
                  l_pa_dpr_arr.delete;
                  l_pa_dpr_in := l_dpr_in;
                  OPEN c_get_period_rec(t_date_placed_in_service(i));
                  FETCH c_get_period_rec INTO l_pa_dpr_in.p_cl_begin
                                            , l_pa_dpr_in.y_begin;
                  CLOSE c_get_period_rec;

                  if (p_period_rec.period_num = 1) then
                     l_pa_dpr_in.y_end := p_period_rec.fiscal_year - 1;
                     l_pa_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;
                  else
                     l_pa_dpr_in.y_end := p_period_rec.fiscal_year;
                     l_pa_dpr_in.p_cl_end := p_period_rec.period_num - 1;
                  end if;

                  --+++++++ Call Depreciation engine to calculate periodic depreciation +++++++
                  if not FA_CDE_PKG.faxcde(l_pa_dpr_in,
                                           l_pa_dpr_arr,
                                           l_pa_dpr_out,
                                           l_running_mode, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                     end if;

                     raise dpr_err;
                  end if;

                  l_dpr_in.adj_rec_cost        := l_pa_dpr_out.new_adj_cost;
                  l_dpr_in.reval_amo_basis     := l_pa_dpr_out.new_reval_amo_basis;
                  l_dpr_in.ytd_deprn           := l_pa_dpr_out.new_ytd_deprn;
                  l_dpr_in.deprn_rsv           := l_pa_dpr_out.new_deprn_rsv;
                  l_dpr_in.reval_rsv           := l_pa_dpr_out.new_reval_rsv;
                  l_dpr_in.adj_capacity        := l_pa_dpr_out.new_adj_capacity;
                  l_dpr_in.ltd_prod            := l_pa_dpr_out.new_ltd_prod;
                  l_dpr_in.eofy_reserve        := l_pa_dpr_out.new_eofy_reserve;
                  l_dpr_row.ltd_prod           := l_pa_dpr_out.new_ltd_prod;
                  l_dpr_row.ytd_prod           := l_dpr_row.ytd_prod + l_pa_dpr_out.prod;
                  l_dpr_row.deprn_rsv          := l_pa_dpr_out.new_deprn_rsv;
                  l_dpr_row.reval_rsv          := l_pa_dpr_out.new_reval_rsv;
                  l_dpr_row.bonus_ytd_deprn    := l_dpr_row.bonus_ytd_deprn + l_pa_dpr_out.bonus_deprn_exp;
                  l_dpr_row.bonus_deprn_rsv    := l_pa_dpr_out.new_bonus_deprn_rsv;
                  l_dpr_row.prior_fy_exp       := l_pa_dpr_out.new_prior_fy_exp;
                  l_dpr_row.prior_fy_bonus_exp := l_pa_dpr_out.new_prior_fy_bonus_exp;
                  l_dpr_row.capital_adjustment := l_pa_dpr_out.new_capital_adjustment; -- Bug 6666666
                  l_dpr_row.general_fund       := l_pa_dpr_out.new_general_fund; -- Bug 6666666
               end if;
               ---   ************************************   ---
               ---   End of Prior period addition process   ---
               ---   ************************************   ---


               --
               -- Prepare Running Depreciation
               --
               l_dpr_in.y_begin := p_period_rec.fiscal_year;
               l_dpr_in.p_cl_begin := p_period_rec.period_num;
               l_dpr_in.y_end := p_period_rec.fiscal_year;
               l_dpr_in.p_cl_end := p_period_rec.period_num;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               --+++++++ Call Depreciation engine to calculate periodic depreciation +++++++
               if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise dpr_err;
               end if;
	    END IF; --depreciate falg = 'NO' phase5
         end if; -- (p_period_rec.period_counter > p_imp_period_rec.period_counter)

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Storing values in local pl/sql tables', 'process deprn', p_log_level_rec => p_log_level_rec);
         end if;
         /*Bug 9574021 Added condition for Extended Assets*/
         IF t_depreciate_flag(i) = 'YES' AND (t_period_fully_reserve(i) is null OR t_deprn_method_code(i) = 'JP-STL-EXTND')then
	    --Bug5768359: adding l_dpr_row.deprn_exp to refrect cur per catchup.
            t_deprn_amount(i)              := l_dpr_out.deprn_exp + nvl(l_pa_dpr_out.new_deprn_rsv, 0) + nvl(l_dpr_row.deprn_exp, 0);
            t_ytd_deprn(i)                 := l_dpr_out.new_ytd_deprn;--l_dpr_row.ytd_deprn + l_dpr_out.deprn_exp + nvl(l_pa_dpr_out.new_deprn_rsv, 0);
            t_deprn_reserve(i)             := l_dpr_out.new_deprn_rsv;
            t_adjusted_cost(i)             := l_dpr_out.new_adj_cost;
            t_bonus_deprn_amount(i)        := l_dpr_out.bonus_deprn_exp;
            t_bonus_ytd_deprn(i)           := l_dpr_row.bonus_ytd_deprn + l_dpr_out.bonus_deprn_exp;
            t_bonus_deprn_reserve(i)       := l_dpr_out.new_bonus_deprn_rsv;
            t_bonus_rate(i)                := l_dpr_out.bonus_rate_used;
            t_production(i)                := l_dpr_out.prod;
            t_ytd_production(i)            := l_dpr_row.ytd_prod + l_dpr_out.prod;
            t_ltd_production(i)            := l_dpr_out.new_ltd_prod;
            t_reval_amortization(i)        := l_dpr_out.reval_amo;
            t_reval_amortization_basis(i)  := l_dpr_out.new_reval_amo_basis;
            t_reval_deprn_expense(i)       := l_dpr_out.reval_exp;
            t_ytd_reval_deprn_expense(i)   := l_dpr_row.ytd_reval_deprn_exp + l_dpr_out.reval_exp;
            t_reval_reserve(i)             := l_dpr_out.new_reval_rsv;
            t_prior_fy_expense(i)          := l_dpr_out.new_prior_fy_exp;
            t_prior_fy_bonus_expense(i)    := l_dpr_out.new_prior_fy_bonus_exp;
            t_deprn_override_flag(i)       := l_dpr_out.deprn_override_flag;
            t_system_deprn_amount(i)       := l_dpr_out.deprn_exp;
            t_system_bonus_deprn_amount(i) := l_dpr_out.bonus_deprn_exp;
            t_deprn_adjustment_amount(i)   := nvl(l_dpr_row.deprn_adjust_exp, 0) + nvl(l_pa_dpr_out.new_deprn_rsv, 0);
            t_bonus_deprn_adj_amount(i)    := 0;--l_dpr_row.bonus_deprn_adjust_exp;
            t_capital_adjustment(i)        := l_dpr_out.new_capital_adjustment; -- Bug 6666666
            t_general_fund(i)              := l_dpr_out.new_general_fund;       -- Bug 6666666
	    if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'getting values from l_dpr_out struct', 'deprn run yes', p_log_level_rec => p_log_level_rec);
            end if;
         ELSE --t_depreciate_flag(i) = 'NO' /*override the values from l_dpr_row o/p of query balance*/
	    t_deprn_amount(i)              := 0;
            t_ytd_deprn(i)                 := l_dpr_row.ytd_deprn;
            t_deprn_reserve(i)             := l_dpr_row.deprn_rsv;
            t_adjusted_cost(i)             := l_dpr_row.adj_cost;
            t_bonus_deprn_amount(i)        := 0;
            t_bonus_ytd_deprn(i)           := l_dpr_row.bonus_ytd_deprn ;
            t_bonus_deprn_reserve(i)       := l_dpr_row.bonus_deprn_rsv;
            t_bonus_rate(i)                := l_dpr_row.bonus_rate;
            t_production(i)                := l_dpr_row.ltd_prod;
            t_ytd_production(i)            := l_dpr_row.ytd_prod ;
            t_ltd_production(i)            := l_dpr_row.ltd_prod;
            t_reval_amortization(i)        := l_dpr_row.reval_amo;
            t_reval_amortization_basis(i)  := l_dpr_row.reval_amo_basis;
            t_reval_deprn_expense(i)       := l_dpr_row.reval_deprn_exp;
            t_ytd_reval_deprn_expense(i)   := l_dpr_row.reval_deprn_exp;
            t_reval_reserve(i)             := l_dpr_row.reval_rsv;
            t_prior_fy_expense(i)          := l_dpr_row.prior_fy_exp;
            t_prior_fy_bonus_expense(i)    := l_dpr_row.prior_fy_bonus_exp;
            t_deprn_override_flag(i)       := l_dpr_row.deprn_override_flag;
            t_system_deprn_amount(i)       := 0;
            t_system_bonus_deprn_amount(i) := 0;
            t_deprn_adjustment_amount(i)   := nvl(l_dpr_row.deprn_adjust_exp, 0);
            t_bonus_deprn_adj_amount(i)    := 0;--l_dpr_row.bonus_deprn_adjust_exp;
            t_capital_adjustment(i)        := l_dpr_row.capital_adjustment; -- Bug 6666666
            t_general_fund(i)              := l_dpr_row.general_fund;       -- Bug 6666666
	    if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'getting values from l_dpr_row struct', 'deprn run NO', p_log_level_rec => p_log_level_rec);
            end if;
	 END IF; --deprn flag = YES phase5

	 if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_adjust_exp', l_dpr_row.deprn_adjust_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 't_deprn_adjustment_amount('||to_char(i)||')', t_deprn_adjustment_amount(i));
         end if;

         --
         -- Store appropriate amount in eofy_reserve
         --
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'deprn_method_code', t_deprn_method_code(i));
            fa_debug_pkg.add(l_calling_fn, 'life_in_months', t_life_in_months(i));
         end if;

         if (not fa_cache_pkg.fazccmt(
                    t_deprn_method_code(i),
                    t_life_in_months(i),
                    p_log_level_rec)) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            raise dpr_err;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'rate_source_rule', fa_cache_pkg.fazccmt_record.rate_source_rule, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'deprn_basis_rule', fa_cache_pkg.fazccmt_record.deprn_basis_rule, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'use_rsv_after_imp_flag', fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, p_log_level_rec => p_log_level_rec);
         end if;

         if (fa_cache_pkg.fazccmt_record.rate_source_rule = fa_std_types.FAD_RSR_FLAT) and
            (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_NBV) and
            (fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag = 'Y') then
            t_eofy_reserve(i) := nvl(l_dpr_out.new_deprn_rsv, 0);
         else
            t_eofy_reserve(i) := nvl(l_dpr_out.new_eofy_reserve, 0);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'eofy reserve', t_eofy_reserve(i));
            fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.impairment_rsv', l_dpr_row.impairment_rsv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_dpr_in.rec_cost', l_dpr_in.rec_cost, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.new_deprn_rsv', l_dpr_out.new_deprn_rsv, p_log_level_rec => p_log_level_rec);
         end if;

         /* Phase5 excluding savage value when asset is using JP Logic for NBV calculation for Impairment*/
	 /*Bug 9576003  changed the variables to cal net_book_value in case of ELSE part*/
	 if (NVL(fa_cache_pkg.fazccmt_record.JP_IMP_CALC_BASIS_FLAG, 'NO') = 'YES') then
	    t_net_book_value(i) := t_cost(i) - t_deprn_reserve(i) - nvl(l_dpr_row.impairment_rsv, 0);
	 else
	    t_net_book_value(i) := t_recoverable_cost(i) - t_deprn_reserve(i) - nvl(l_dpr_row.impairment_rsv, 0);
         end if;

         t_ytd_impairment(i) := t_ytd_impairment(i) + nvl(l_dpr_row.ytd_impairment, 0);
         t_impairment_reserve(i) := t_impairment_reserve(i) + nvl(l_dpr_row.impairment_rsv, 0);


         -- Check if this is the period of addition
         l_asset_hdr_rec.asset_id          := t_asset_id(i);
         l_asset_hdr_rec.book_type_code    := p_book_type_code;
         l_asset_hdr_rec.set_of_books_id   := p_set_of_books_id;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Calling function ', 'FA_ASSET_VAL_PVT.validate_period_of_addition',  p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'l_asset_hdr_rec.asset_id', l_asset_hdr_rec.asset_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
         end if;

         if not FA_ASSET_VAL_PVT.validate_period_of_addition
                              (p_asset_id            => l_asset_hdr_rec.asset_id,
                               p_book                => p_book_type_code,
                               p_mode                => 'ABSOLUTE',
                               px_period_of_addition => t_period_of_addition_flag(i),
                               p_log_level_rec     => p_log_level_rec) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Error Calling', 'FA_ASSET_VAL_PVT.validate_period_of_addition',  p_log_level_rec => p_log_level_rec);
            end if;

            raise dpr_err;
         end if;

         -- Create (cip_)cost entries if this is asset's period of addition
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Is this period of addition? ', t_period_of_addition_flag(i));
         end if;
         --Bug#8614268 start
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Before checking impairments accts for category id',t_category_id(i), p_log_level_rec => p_log_level_rec);
         end if;
         if not (fa_cache_pkg.fazccb (X_Book    => p_book_type_code,
                                      X_Cat_Id  => t_category_id(i),
                                      p_log_level_rec => p_log_level_rec)) then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'Error Calling','fa_cache_pkg.fazccb', p_log_level_rec => p_log_level_rec);
            end if;
            raise dpr_err;
         end if;
         if ((fa_cache_pkg.fazccb_record.IMPAIR_EXPENSE_ACCT is null) OR
             (fa_cache_pkg.fazccb_record.IMPAIR_RESERVE_ACCT is null)) then
            g_error_flag(i) := 1;
         else
            g_error_flag(i) := 0;
         end if;
         --Bug# 8614268 end
      END LOOP;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'t_net_book_value(1)', t_net_book_value(1));
      end if;


      if (p_mrc_sob_type_code = 'R') then
         FORALL i in 1..t_asset_id.count
            UPDATE FA_MC_ITF_IMPAIRMENTS
            SET    NET_BOOK_VALUE                = t_net_book_value(i)
                 , YTD_IMPAIRMENT                = t_ytd_impairment(i)
                 , impairment_reserve                = t_impairment_reserve(i)
                 , DEPRN_RUN_DATE                = t_deprn_run_date(i)
                 , DEPRN_AMOUNT                  = t_deprn_amount(i)
                 , YTD_DEPRN                     = t_ytd_deprn(i)
                 , DEPRN_RESERVE                 = t_deprn_reserve(i)
                 , ADJUSTED_COST                 = t_adjusted_cost(i)
                 , BONUS_RATE                    = t_bonus_rate(i)
                 , LTD_PRODUCTION                = t_ltd_production(i)
                 , PRODUCTION                    = t_production(i)
                 , REVAL_AMORTIZATION            = t_reval_amortization(i)
                 , REVAL_AMORTIZATION_BASIS      = t_reval_amortization_basis(i)
                 , REVAL_DEPRN_EXPENSE           = t_reval_deprn_expense(i)
                 , REVAL_RESERVE                 = t_reval_reserve(i)
                 , YTD_PRODUCTION                = t_ytd_production(i)
                 , YTD_REVAL_DEPRN_EXPENSE       = t_ytd_reval_deprn_expense(i)
                 , PRIOR_FY_EXPENSE              = t_prior_fy_expense(i)
                 , BONUS_DEPRN_AMOUNT            = t_bonus_deprn_amount(i)
                 , BONUS_YTD_DEPRN               = t_bonus_ytd_deprn(i)
                 , BONUS_DEPRN_RESERVE           = t_bonus_deprn_reserve(i)
                 , PRIOR_FY_BONUS_EXPENSE        = t_prior_fy_bonus_expense(i)
                 , DEPRN_OVERRIDE_FLAG           = t_deprn_override_flag(i)
                 , SYSTEM_DEPRN_AMOUNT           = t_system_deprn_amount(i)
                 , SYSTEM_BONUS_DEPRN_AMOUNT     = t_system_bonus_deprn_amount(i)
                 , DEPRN_ADJUSTMENT_AMOUNT       = t_deprn_adjustment_amount(i)
                 , BONUS_DEPRN_ADJUSTMENT_AMOUNT = t_bonus_deprn_adj_amount(i)
                 , CURRENT_UNITS                 = t_current_units(i)
                 , CATEGORY_ID                   = t_category_id(i)
                 , PERIOD_OF_ADDITION_FLAG       = t_period_of_addition_flag(i)
                 , EOFY_RESERVE                  = t_eofy_reserve(i)
                 , CAPITAL_ADJUSTMENT            = t_capital_adjustment(i) -- Bug 6666666
                 , GENERAL_FUND                  = t_general_fund(i)       -- Bug 6666666
                 , ALLOWED_DEPRN_LIMIT_AMOUNT    = t_allowed_deprn_limit_amount(i)
            WHERE  ROWID                         = t_imp_rowid(i);
      else
         FORALL i in 1..t_asset_id.count
            UPDATE FA_ITF_IMPAIRMENTS
            SET    NET_BOOK_VALUE                = t_net_book_value(i)
                 , YTD_IMPAIRMENT                = t_ytd_impairment(i)
                 , impairment_reserve                = t_impairment_reserve(i)
                 , DEPRN_RUN_DATE                = t_deprn_run_date(i)
                 , DEPRN_AMOUNT                  = t_deprn_amount(i)
                 , YTD_DEPRN                     = t_ytd_deprn(i)
                 , DEPRN_RESERVE                 = t_deprn_reserve(i)
                 , ADJUSTED_COST                 = t_adjusted_cost(i)
                 , BONUS_RATE                    = t_bonus_rate(i)
                 , LTD_PRODUCTION                = t_ltd_production(i)
                 , PRODUCTION                    = t_production(i)
                 , REVAL_AMORTIZATION            = t_reval_amortization(i)
                 , REVAL_AMORTIZATION_BASIS      = t_reval_amortization_basis(i)
                 , REVAL_DEPRN_EXPENSE           = t_reval_deprn_expense(i)
                 , REVAL_RESERVE                 = t_reval_reserve(i)
                 , YTD_PRODUCTION                = t_ytd_production(i)
                 , YTD_REVAL_DEPRN_EXPENSE       = t_ytd_reval_deprn_expense(i)
                 , PRIOR_FY_EXPENSE              = t_prior_fy_expense(i)
                 , BONUS_DEPRN_AMOUNT            = t_bonus_deprn_amount(i)
                 , BONUS_YTD_DEPRN               = t_bonus_ytd_deprn(i)
                 , BONUS_DEPRN_RESERVE           = t_bonus_deprn_reserve(i)
                 , PRIOR_FY_BONUS_EXPENSE        = t_prior_fy_bonus_expense(i)
                 , DEPRN_OVERRIDE_FLAG           = t_deprn_override_flag(i)
                 , SYSTEM_DEPRN_AMOUNT           = t_system_deprn_amount(i)
                 , SYSTEM_BONUS_DEPRN_AMOUNT     = t_system_bonus_deprn_amount(i)
                 , DEPRN_ADJUSTMENT_AMOUNT       = t_deprn_adjustment_amount(i)
                 , BONUS_DEPRN_ADJUSTMENT_AMOUNT = t_bonus_deprn_adj_amount(i)
                 , CURRENT_UNITS                 = t_current_units(i)
                 , CATEGORY_ID                   = t_category_id(i)
                 , PERIOD_OF_ADDITION_FLAG       = t_period_of_addition_flag(i)
                 , EOFY_RESERVE                  = t_eofy_reserve(i)
                 , CAPITAL_ADJUSTMENT            = t_capital_adjustment(i) -- Bug 6666666
                 , GENERAL_FUND                  = t_general_fund(i)       -- Bug 6666666
                 , ALLOWED_DEPRN_LIMIT_AMOUNT    = t_allowed_deprn_limit_amount(i)
            WHERE  ROWID                         = t_imp_rowid(i);
      end if;


   END LOOP;
   --
   --

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Process Depreciation', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN dpr_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'prv_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END process_depreciation;


FUNCTION calc_total_nbv(
              p_request_id            IN NUMBER
            , p_book_type_code        IN VARCHAR2
            , p_transaction_date      IN DATE
            , p_period_rec            IN FA_API_TYPES.period_rec_type
            , p_mrc_sob_type_code     IN VARCHAR2
            , p_set_of_books_id       IN NUMBER
            , p_calling_fn            IN VARCHAR2
            , p_asset_id              OUT NOCOPY  tab_num_type
            , p_nbv              OUT NOCOPY  tab_num_type
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn   varchar2(60) := 'post_impairment';


   l_rbs_name       VARCHAR2(30);
   l_sql_stmt      varchar2(101);

   l_msg_count         NUMBER := 0;
   l_msg_data          VARCHAR2(2000) := NULL;

  CURSOR c_get_currency_info(c_set_of_books_id number) IS
      SELECT curr.precision
      FROM   fnd_currencies curr
           , gl_sets_of_books sob
      WHERE  sob.set_of_books_id = c_set_of_books_id
      AND    curr.currency_code  = sob.currency_code;

   CURSOR c_get_impairments IS
      select imp.rowid
           , imp.impairment_id
           , imp.cash_generating_unit_id
           , greatest(nvl(imp.net_selling_price, 0),nvl(imp.value_in_use, 0))
           , imp.impairment_amount
           , nvl(sum(itf.net_book_value),0)
           , imp.asset_id -- Bug# 7000391
           , nvl(books.sorp_enabled_flag, 'N')  -- Bug 6666666
           , imp.net_selling_price --Bug# 7511258
           , imp.value_in_use      --Bug# 7511258
      from   fa_impairments imp
           , fa_itf_impairments itf
           , fa_book_controls books
      where  imp.request_id = p_request_id
      and    imp.book_type_code = p_book_type_code
      and    imp.impairment_id = itf.impairment_id
      and    nvl(itf.goodwill_asset_flag, 'N') <> 'Y'
      and    imp.period_counter_impaired = p_period_rec.period_counter
      and    books.book_type_code = p_book_type_code
      group by imp.rowid
           , imp.impairment_id
           , imp.cash_generating_unit_id
           , greatest(nvl(imp.net_selling_price, 0),nvl(imp.value_in_use, 0))
           , imp.impairment_amount
           , imp.asset_id  -- Bug# 7000391
           , nvl(books.sorp_enabled_flag, 'N') -- Bug 6666666
           , imp.net_selling_price --Bug# 7511258
           , imp.value_in_use ;     --Bug# 7511258

   CURSOR c_mc_get_impairments IS
      select imp.rowid
           , imp.impairment_id
           , imp.cash_generating_unit_id
           , greatest(nvl(imp.net_selling_price, 0),nvl(imp.value_in_use, 0))
           , nvl(imp.impairment_amount, 0)
           , nvl(sum(itf.net_book_value),0)
           , imp.asset_id -- Bug# 7000391
           , nvl(books.sorp_enabled_flag, 'N')  -- Bug 6666666
           , imp.net_selling_price --Bug# 7511258
           , imp.value_in_use      --Bug# 7511258
      from   fa_mc_impairments imp
           , fa_mc_itf_impairments itf
           , fa_book_controls books
      where  imp.request_id = p_request_id
      and    imp.book_type_code = p_book_type_code
      and    imp.impairment_id = itf.impairment_id
      and    nvl(itf.goodwill_asset_flag, 'N') <> 'Y'
      and    imp.period_counter_impaired = p_period_rec.period_counter
      and    books.book_type_code = p_book_type_code --8666930
      and    imp.set_of_books_id = p_set_of_books_id
      and    itf.set_of_books_id = p_set_of_books_id
      group by imp.rowid
           , imp.impairment_id
           , imp.cash_generating_unit_id
           , greatest(nvl(imp.net_selling_price, 0),nvl(imp.value_in_use, 0))
           , imp.impairment_amount
           , imp.asset_id -- Bug# 7000391
           , nvl(books.sorp_enabled_flag, 'N')  -- Bug 6666666
           , imp.net_selling_price --Bug# 7511258
           , imp.value_in_use;      --Bug# 7511258

   CURSOR c_get_sum(c_impairment_id number) IS
      select sum(impairment_amount)
      from   fa_itf_impairments
      where  impairment_id = c_impairment_id
      and    nvl(goodwill_asset_flag, 'N') <> 'Y';

   CURSOR c_mc_get_sum(c_impairment_id number) IS
      select sum(impairment_amount)
      from   fa_mc_itf_impairments
      where  impairment_id = c_impairment_id
      and    nvl(goodwill_asset_flag, 'N') <> 'Y'
      and    set_of_books_id = p_set_of_books_id;

   CURSOR c_get_itfs(c_impairment_id number) IS
      select rowid
           , net_book_value
           , impairment_amount
           , ytd_impairment
           , impairment_reserve
      from   fa_itf_impairments
      where  impairment_id = c_impairment_id
      and    net_book_value <> 0
      and    nvl(goodwill_asset_flag, 'N') <> 'Y';

   CURSOR c_mc_get_itfs(c_impairment_id number) IS
      select rowid
           , net_book_value
           , impairment_amount
           , ytd_impairment
           , impairment_reserve
      from   fa_mc_itf_impairments
      where  impairment_id = c_impairment_id
      and    net_book_value <> 0
      and    nvl(goodwill_asset_flag, 'N') <> 'Y'
      and    set_of_books_id = p_set_of_books_id;

   --Bug# 7045739 start - to process only first row if more than one rows are uploaded for an asset
                        --in the same request.
   /*Bug#9182681 - Modified for CGU) */
   CURSOR c_get_itf(c_asset_id number,c_cgu_id number) is
        select impairment_id
        from   fa_itf_impairments
        where  request_id = p_request_id
        and    (asset_id   = c_asset_id or cash_generating_unit_id = c_cgu_id) order by impairment_id;

   CURSOR c_mc_get_itf(c_asset_id number,c_cgu_id number) is
        select impairment_id
        from   fa_mc_itf_impairments
        where  request_id = p_request_id
        and    (asset_id   = c_asset_id or cash_generating_unit_id = c_cgu_id)
        and    set_of_books_id = p_set_of_books_id
        order by impairment_id;

  --Bug# 7045739 end

   --Bug# 7594562 - To check if any impairment is already posted in current period for an asset
   CURSOR c_mc_check_imp(c_asset_id number,c_cgu_id number) is
        select 'POSTED'
        from   fa_mc_impairments
        where  status = 'POSTED'
        and    (asset_id   = c_asset_id or cash_generating_unit_id = c_cgu_id)
        and    book_type_code = p_book_type_code /*Bug# 8263733 - Added filter condition with book_type_code */
        AND PERIOD_COUNTER_IMPAIRED = p_period_rec.period_counter
        AND set_of_books_id = p_set_of_books_id;

   CURSOR c_check_imp(c_asset_id number,c_cgu_id number) is
        select 'POSTED'
        from   fa_impairments
        where  status = 'POSTED'
        and    (asset_id   = c_asset_id or cash_generating_unit_id = c_cgu_id)
        and    book_type_code = p_book_type_code /*Bug# 8263733 - Added filter condition with book_type_code */
        AND PERIOD_COUNTER_IMPAIRED = p_period_rec.period_counter;

   --Bug# 7594562 ends

   l_precision NUMBER(15);

   t_rowid             tab_rowid_type;
   t_impairment_id     tab_num15_type;
   t_cash_generating_unit_id tab_num15_type;
   t_fair_market_value tab_num_type;
   t_impairment_amount tab_num_type;
   t2_impairment_amount tab_num_type;
   t_net_book_value    tab_num_type;
   ti_rowid             tab_rowid_type;
   ti_net_book_value     tab_num_type;
   ti_ytd_impairment      tab_num_type;
   ti_impairment_reserve    tab_num_type;
   ti_impairment_amount tab_num_type;
   t_sorp_enabled_flag tab_char1_type; -- Bug 6666666

   --Bug# 7511258
   t_value_in_use tab_num_type;
   t_net_selling_price tab_num_type;

   l_sum_impairment_amount number;
   l_remainder             number;
   l_allocation_complete   boolean := FALSE;

   l_impairment_id number; --Bug# 7045739

   l_check_imp_flag varchar(15); --Bug# 7594562

   calc_err           exception;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'calc_total_nbv', 'BEGIN', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'period_counter', p_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
   end if;

   OPEN c_get_currency_info(p_set_of_books_id);
   FETCH c_get_currency_info INTO l_precision;
   CLOSE c_get_currency_info;



--
-- May need to create outer loop to limit records to fetch
--
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Fetching', 'from FA_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      OPEN c_mc_get_impairments;
      FETCH c_mc_get_impairments BULK COLLECT INTO t_rowid
                                                 , t_impairment_id
                                                 , t_cash_generating_unit_id
                                                 , t_fair_market_value
                                                 , t2_impairment_amount
                                                 , t_net_book_value
                                                 , p_asset_id -- Bug #7000391
                                                 , t_sorp_enabled_flag -- Bug 6666666
                                                 , t_net_selling_price --Bug# 7511258
                                                 , t_value_in_use; --Bug# 7511258
      CLOSE c_mc_get_impairments;
   else
      OPEN c_get_impairments;
      FETCH c_get_impairments BULK COLLECT INTO t_rowid
                                              , t_impairment_id
                                              , t_cash_generating_unit_id
                                              , t_fair_market_value
                                              , t2_impairment_amount
                                              , t_net_book_value
                                              , p_asset_id -- Bug #7000391
                                              , t_sorp_enabled_flag --Bug 6666666
                                              , t_net_selling_price --Bug# 7511258
                                              , t_value_in_use; --Bug# 7511258
      CLOSE c_get_impairments;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Fecthed impairments', t_impairment_id.count, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'fmv', t_fair_market_value(1));
      fa_debug_pkg.add(l_calling_fn,'nbv', t_net_book_value(1));
      fa_debug_pkg.add(l_calling_fn,'Updating', 'FA_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_IMPAIRMENTS IMP
         SET    NET_BOOK_VALUE = t_net_book_value(i)
              , IMPAIRMENT_AMOUNT = decode(nvl(t2_impairment_amount(i), 0), 0,
                                           t_net_book_value(i) - t_fair_market_value(i), t2_impairment_amount(i))
              , IMPAIRMENT_DATE = nvl(IMPAIRMENT_DATE, p_transaction_date)
         WHERE  ROWID = t_rowid(i)
         RETURNING IMPAIRMENT_AMOUNT BULK COLLECT INTO t_impairment_amount;
   else
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_IMPAIRMENTS IMP
         SET    NET_BOOK_VALUE = t_net_book_value(i)
              , IMPAIRMENT_AMOUNT = decode(nvl(t2_impairment_amount(i), 0), 0,
                                           t_net_book_value(i) - t_fair_market_value(i), t2_impairment_amount(i))
              , IMPAIRMENT_DATE = nvl(IMPAIRMENT_DATE, p_transaction_date)
         WHERE  ROWID = t_rowid(i)
         RETURNING IMPAIRMENT_AMOUNT BULK COLLECT INTO t_impairment_amount;
   end if;

   --
   -- Allocate
   --
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Updating', 'FA_ITF_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      FORALL i in 1..t_impairment_id.count
        UPDATE FA_MC_ITF_IMPAIRMENTS ITF
         SET    IMPAIRMENT_AMOUNT = least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , YTD_IMPAIRMENT = YTD_IMPAIRMENT + least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , impairment_reserve = impairment_reserve + least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , NET_SELLING_PRICE = least(round(t_net_selling_price(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE) --Bug# 7511258,9182681
              , VALUE_IN_USE = least(round(t_value_in_use(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE) --Bug# 7511258,9182681
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
         AND    t_net_book_value(i) <> 0
         AND    set_of_books_id = p_set_of_books_id;  -- Bug# 6920854

      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_ITF_IMPAIRMENTS ITF
         SET    NET_BOOK_VALUE = COST - DEPRN_RESERVE - impairment_reserve
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    GOODWILL_ASSET_FLAG = 'Y'
         AND    set_of_books_id = p_set_of_books_id;

   else
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_ITF_IMPAIRMENTS ITF
         SET    IMPAIRMENT_AMOUNT = least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , YTD_IMPAIRMENT = YTD_IMPAIRMENT + least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , impairment_reserve = impairment_reserve + least(round(t_impairment_amount(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE)
              , NET_SELLING_PRICE = least(round(t_net_selling_price(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE) --Bug# 7511258,9182681
              , VALUE_IN_USE = least(round(t_value_in_use(i) *
                                          (NET_BOOK_VALUE/t_net_book_value(i)), l_precision),
                                          NET_BOOK_VALUE) --Bug# 7511258,9182681
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
         AND    t_net_book_value(i) <> 0; -- Bug# 6920854
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_ITF_IMPAIRMENTS ITF
         SET    NET_BOOK_VALUE = COST - DEPRN_RESERVE - impairment_reserve
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    GOODWILL_ASSET_FLAG = 'Y';

   end if;
   p_nbv := t_net_book_value; -- Bug# 7000391
-- Get sum of impairments from itf
-- compare it against one in t_impairment_amount
-- if it is different, go reallocate
-- set period counter fully reserved if it is fully reserved

   FOR i in 1..t_impairment_id.count LOOP

      if (t_cash_generating_unit_id is not null) then
         --Bug#7594562 start - to check if an impairment is already posted in current open period for this asset.
         --Bug# 7632938 - Initialize value of l_check_imp_flag.
         l_check_imp_flag := null;
         if p_mrc_sob_type_code = 'R' then
            OPEN c_mc_check_imp(p_asset_id(i),t_cash_generating_unit_id(i));
            FETCH c_mc_check_imp INTO l_check_imp_flag;
            CLOSE c_mc_check_imp;
         else
            OPEN c_check_imp(p_asset_id(i),t_cash_generating_unit_id(i));
            FETCH c_check_imp INTO l_check_imp_flag;
            CLOSE c_check_imp;
         end if;
         if nvl(l_check_imp_flag,'NOTPOSTED') = 'POSTED' then
            p_nbv(i) := -2;
         else
         --Bug#7594562 end
                 --Bug# 7045739 start - to process only first row if more than one rows are uploaded for an asset
                                     -- in the same request.
                 if p_mrc_sob_type_code = 'R' then
                    OPEN c_mc_get_itf(p_asset_id(i),t_cash_generating_unit_id(i));
                    FETCH c_mc_get_itf INTO l_impairment_id;
                    CLOSE c_mc_get_itf;
                 else
                    OPEN c_get_itf(p_asset_id(i),t_cash_generating_unit_id(i));
                    FETCH c_get_itf INTO l_impairment_id;
                    CLOSE c_get_itf;
                 end if;

                 if  l_impairment_id <> t_impairment_id(i) then
                     --Not a first row if more than one rows are uploaded for an asset in the same request
                     --set flag to reject it.
                     p_nbv(i) := -1;
                 else
                     --first row if more than one rows are uploaded for an asset in the same request
                     if t_impairment_amount(i) > t_net_book_value(i) then
                         --Impairment loss is greater then NBV after considering current month depreciation
                         --set flag to show warning.
                         p_nbv(i) := 0;
                     elsif t_impairment_amount(i) <= 0 then /*Bug#8555199 - Negative or zero impairmnet loss is not allowed */
                         p_nbv(i) := -3;
                     else
                --Bug# 7045739 end
                         if p_mrc_sob_type_code = 'R' then
                            OPEN c_mc_get_sum(t_impairment_id(i));
                            FETCH c_mc_get_sum INTO l_sum_impairment_amount;
                            CLOSE c_mc_get_sum;
                         else
                            OPEN c_get_sum(t_impairment_id(i));
                            FETCH c_get_sum INTO l_sum_impairment_amount;
                            CLOSE c_get_sum;
                         end if;


                         if t_impairment_amount(i) <> l_sum_impairment_amount then
                            l_remainder := t_impairment_amount(i) - l_sum_impairment_amount;
                            if t_net_book_value(i) <> 0 then -- Bug# 7000391
                                    t_net_book_value(i) := t_net_book_value(i) - l_remainder;
                            end if;
                            if p_mrc_sob_type_code = 'R' then
                               OPEN c_mc_get_itfs(t_impairment_id(i));
                            else
                               OPEN c_get_itfs(t_impairment_id(i));
                            end if;

                            LOOP -- Outer Loop
                               ti_rowid.delete;
                               ti_net_book_value.delete;
                               ti_impairment_amount.delete;
                               ti_ytd_impairment.delete;
                               ti_impairment_reserve.delete;

                               if p_mrc_sob_type_code = 'R' then
                                  FETCH c_mc_get_itfs BULK COLLECT INTO ti_rowid
                                                                      , ti_net_book_value
                                                                      , ti_impairment_amount
                                                                      , ti_ytd_impairment
                                                                      , ti_impairment_reserve;
                               else
                                  FETCH c_get_itfs BULK COLLECT INTO ti_rowid
                                                                   , ti_net_book_value
                                                                   , ti_impairment_amount
                                                                   , ti_ytd_impairment
                                                                   , ti_impairment_reserve;
                               end if;

                               if (ti_rowid.count = 0) then
                                  if p_mrc_sob_type_code = 'R' then
                                     CLOSE c_mc_get_itfs;
                                  else
                                     CLOSE c_get_itfs;
                                  end if;

                                  EXIT;

                               end if;

                               FOR j in 1..ti_rowid.count LOOP

                                  if (ti_net_book_value(j) < l_remainder) then
                                     -- remaining nbv is smaller than remaining impairment amounts
                                     ti_impairment_amount(j) := ti_impairment_amount(j) + ti_net_book_value(j);
                                     ti_ytd_impairment(j) := ti_ytd_impairment(j) + ti_net_book_value(j);
                                     ti_impairment_reserve(j) := ti_impairment_reserve(j) + ti_net_book_value(j);
                                     l_remainder := l_remainder - ti_net_book_value(j);
                                     ti_net_book_value(j) := 0;
                                  else
                                     -- This line can take all of remainder
                                     ti_impairment_amount(j) := ti_impairment_amount(j) + l_remainder;
                                     ti_ytd_impairment(j) := ti_ytd_impairment(j) + l_remainder;
                                     ti_impairment_reserve(j) := ti_impairment_reserve(j) + l_remainder;
                                     ti_net_book_value(j) := ti_net_book_value(j) - l_remainder;
                                     l_allocation_complete := TRUE;
                                     EXIT;
                                  end if;

                               END LOOP; -- j in 1..ti_rowid.count

                               if p_mrc_sob_type_code = 'R' then
                                  FORALL j in 1..ti_rowid.count
                                     UPDATE FA_MC_ITF_IMPAIRMENTS
                                     SET    IMPAIRMENT_AMOUNT = ti_impairment_amount(j)
                                          , YTD_IMPAIRMENT = ti_ytd_impairment(j)
                                          , impairment_reserve = ti_impairment_reserve(j)
                                          , NET_BOOK_VALUE = ti_net_book_value(j)
                                     WHERE  ROWID = ti_rowid(j);
                               else
                                  FORALL j in 1..ti_rowid.count
                                     UPDATE FA_ITF_IMPAIRMENTS
                                     SET    IMPAIRMENT_AMOUNT = ti_impairment_amount(j)
                                          , YTD_IMPAIRMENT = ti_ytd_impairment(j)
                                          , impairment_reserve = ti_impairment_reserve(j)
                                          , NET_BOOK_VALUE = ti_net_book_value(j)
                                     WHERE  ROWID = ti_rowid(j);
                               end if;

                               if (l_allocation_complete) then
                                  if p_mrc_sob_type_code = 'R' then
                                     CLOSE c_mc_get_itfs;
                                  else
                                     CLOSE c_get_itfs;
                                  end if;

                                  EXIT;

                               end if;

                            END LOOP; -- Outer Loop

                         end if; -- t_impairment_amount(i) <> l_sum_impairment_amount

                     end if; -- t_impairment_amount(i) > t_net_book_value(i)

                 end if; -- l_impairment_id <> t_impairment_id(i)

         end if; --Bug#7594562 nvl(l_check_imp_flag,'N') = 'Y'

      end if; --(t_cash_generating_unit_id is not null)

   END LOOP; -- i in 1..t_impairment_id.count

   --
   -- Adjusting impairment amount and reval reserve
   --
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Updating impairment for reval', 'FA_ITF_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
   end if;

   if (p_mrc_sob_type_code = 'R') then
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_ITF_IMPAIRMENTS ITF
         SET    IMPAIRMENT_AMOUNT        = IMPAIRMENT_AMOUNT - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , YTD_IMPAIRMENT           = YTD_IMPAIRMENT - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , REVAL_RESERVE            = REVAL_RESERVE - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , REVAL_RESERVE_ADJ_AMOUNT = least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    nvl(REVAL_RESERVE, 0) <> 0
         AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
         AND    t_sorp_enabled_flag(i) <> 'Y'
         AND    set_of_books_id = p_set_of_books_id; -- Bug 6666666

   else
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_ITF_IMPAIRMENTS ITF
         SET    IMPAIRMENT_AMOUNT        = IMPAIRMENT_AMOUNT - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , YTD_IMPAIRMENT           = YTD_IMPAIRMENT - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , REVAL_RESERVE            = REVAL_RESERVE - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
              , REVAL_RESERVE_ADJ_AMOUNT = least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    nvl(REVAL_RESERVE, 0) <> 0
         AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
         AND    t_sorp_enabled_flag(i) <> 'Y'; -- Bug 6666666;

   end if;


   if p_mrc_sob_type_code = 'R' then
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_IMPAIRMENTS IMP
         SET    NET_BOOK_VALUE = t_net_book_value(i)
         WHERE  ROWID = t_rowid(i);
  else
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_IMPAIRMENTS IMP
         SET    NET_BOOK_VALUE = t_net_book_value(i)
         WHERE  ROWID = t_rowid(i);
   end if;
   --Bug#8614268
   FOR i in 1..g_error_flag.count LOOP
      if(g_error_flag(i) = 1) then
         p_nbv(i) := -4;
      end if;
   end loop;
   -- Bug# 7000391 start
   if p_mrc_sob_type_code = 'R' then
      --Bug# 7045739 start - when impairment_amount > NBV,basically to sync Asset Impairment report and Preview form.
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_ITF_IMPAIRMENTS ITF
         SET DEPRN_RESERVE = DEPRN_RESERVE + (nvl(impairment_reserve,0) - NET_BOOK_VALUE),
             IMPAIRMENT_AMOUNT = t_impairment_amount(i),
             impairment_reserve = t_impairment_amount(i),
             NET_BOOK_VALUE = t_net_book_value(i)
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    p_nbv(i) =0
         AND    set_of_books_id = p_set_of_books_id;

      --To set status to deprn failed when multiple rows are uploaded for an asset.
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_MC_ITF_IMPAIRMENTS ITF
         SET    PERIOD_OF_ADDITION_FLAG = 'F'
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    p_nbv(i) in (-1,-2,-3,-4)
         AND    set_of_books_id = p_set_of_books_id; --Bug#7594562 Added -2
      --Bug# 7045739 end
  else
      --Bug# 7045739 start - when impairment_amount > NBV,basically to sync Asset Impairment report and Preview form.
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_ITF_IMPAIRMENTS ITF
         SET DEPRN_RESERVE = DEPRN_RESERVE + (nvl(impairment_reserve,0) - NET_BOOK_VALUE),
             IMPAIRMENT_AMOUNT = t_impairment_amount(i),
             impairment_reserve = t_impairment_amount(i),
             NET_BOOK_VALUE = t_net_book_value(i)
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    p_nbv(i) =0;

      --To set status to deprn failed when multiple rows are uploaded for an asset.
      FORALL i in 1..t_impairment_id.count
         UPDATE FA_ITF_IMPAIRMENTS ITF
         SET    PERIOD_OF_ADDITION_FLAG = 'F'
         WHERE  IMPAIRMENT_ID = t_impairment_id(i)
         AND    p_nbv(i) in (-1,-2,-3,-4) ; --Bug#7594562 Added -2
      --Bug# 7045739 end
  end if;
  -- Bug# 7000391 end


   -- SORP specific logic for adjustment of revaluation reserve
   FOR i in t_impairment_id.FIRST..t_impairment_id.LAST LOOP
       IF t_sorp_enabled_flag(i) = 'Y' THEN
           IF NOT FA_SORP_IMPAIRMENT_PVT.sorp_processing(
                        p_request_id => p_request_id
                      , p_impairment_id => t_impairment_id(i)
                      , p_mrc_sob_type_code => p_mrc_sob_type_code
                      , p_set_of_books_id => p_set_of_books_id
                      , p_book_type_code => p_book_type_code
                      , p_precision => l_precision
                      , p_log_level_rec     => p_log_level_rec
           ) THEN
               fa_debug_pkg.add(l_calling_fn,'SORP Error - sorp_processing returned an error', 'OTHERS', p_log_level_rec => p_log_level_rec);
               RETURN FALSE;
           END IF;
       END IF;
   END LOOP;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'calc_total_nbv', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;

EXCEPTION
   WHEN calc_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'calc_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

END calc_total_nbv;

FUNCTION process_history(p_request_id        number
                       , p_impairment_id     number
                       , p_asset_id          number
                       , p_book_type_code    varchar2
                       , p_period_rec        FA_API_TYPES.period_rec_type
                       , p_imp_period_rec    FA_API_TYPES.period_rec_type
                       , p_date_placed_in_service date
                       , x_dpr_out           OUT NOCOPY fa_std_types.dpr_out_struct
                       , x_dpr_in            OUT NOCOPY fa_std_types.dpr_struct
                       , p_mrc_sob_type_code varchar2
                       , p_calling_fn        varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn VARCHAR2(30) := 'process_history';

   CURSOR c_get_member_trx IS
    select th.transaction_header_id
         , th.transaction_type_code
         , th.transaction_subtype
         , th.transaction_key
         , (fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM +
            decode(th.transaction_key, 'IM', 1, 0)) period_counter
         , (inbk.cost - nvl(outbk.cost, 0))
         , (nvl(inbk.cip_cost, 0) - nvl(outbk.cip_cost, 0))
--         , (decode(inbk.salvage_type,
--                          outbk.salvage_type,
--                             inbk.salvage_value - nvl(outbk.salvage_value, 0),
--                             inbk.salvage_value))
         , inbk.salvage_value - nvl(outbk.salvage_value, 0)
--         , (decode(inbk.deprn_limit_type,
--                       outbk.deprn_limit_type,
--                          nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
--                                                                    inbk.allowed_deprn_limit_amount), 0) -
--                          nvl(decode(outbk.deprn_limit_type, 'NONE', outbk.salvage_value,
--                                                                     outbk.allowed_deprn_limit_amount), 0),
--                          nvl(decode(inbk.deprn_limit_type, 'NONE', inbk.salvage_value,
--                                                                    inbk.allowed_deprn_limit_amount), 0)))
         , nvl(inbk.allowed_deprn_limit_amount, 0) - nvl(outbk.allowed_deprn_limit_amount, 0)
         , inbk.salvage_type
         , nvl(outbk.salvage_type, inbk.salvage_type)
         , inbk.percent_salvage_value
         , nvl(outbk.percent_salvage_value, 0)
         , inbk.deprn_limit_type
         , nvl(outbk.deprn_limit_type, inbk.deprn_limit_type)
         , inbk.allowed_deprn_limit
         , nvl(outbk.allowed_deprn_limit, null)
         , inbk.deprn_method_code
         , inbk.life_in_months
         , inbk.adjusted_rate
         , inbk.production_capacity
    from   fa_transaction_headers th
         , fa_books inbk
         , fa_books outbk
         , fa_calendar_types ct
         , fa_calendar_periods cp
         , fa_fiscal_year fy
    where  th.asset_id = p_asset_id
    and    th.book_type_code = p_book_type_code
    and    inbk.asset_id = th.asset_id
    and    inbk.asset_id = outbk.asset_id(+)
    and    inbk.book_type_code = outbk.book_type_code(+)
    and    inbk.transaction_header_id_in = th.transaction_header_id
    and    inbk.transaction_header_id_in = outbk.transaction_header_id_out(+)
    and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
    and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
    and    ct.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
    and    cp.calendar_type = ct.calendar_type
    and    cp.start_date between fy.start_date and fy.end_date
    and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >=
                                   fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
    and (
         (
           th.transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                            'TRANSFER', 'TRANSFER IN/VOID',
                                            'RECLASS', 'UNIT ADJUSTMENT',
                                            'REINSTATEMENT', 'ADDITION/VOID',
                                            'ADDITION', 'CIP ADDITION',
                                            'CIP ADJUSTMENT', 'CIP ADDITION/VOID')
           and decode(th.transaction_subtype,
                  'EXPENSED', p_date_placed_in_service,
                              greatest(nvl(th.amortization_start_date,
                                           th.transaction_date_entered), p_date_placed_in_service))
                                      between cp.start_date
                                          and cp.end_date
         )
         or
         (
           th.transaction_type_code = 'ADDITION'
            and (
                  (
                    exists (select 1 from fa_deprn_summary ds
                            where ds.deprn_reserve <> 0
                            and   ds.book_type_code = p_book_type_code
                            and   ds.asset_id = p_asset_id
                            and   ds.deprn_source_code = 'BOOKS')
                    and decode(th.transaction_subtype,
                                     'AMORTIZED', th.amortization_start_date,
                                                  (select dp.calendar_period_open_date
                                                   from fa_deprn_periods dp
                                                   where dp.book_type_code = p_book_type_code
                                                   and   th.date_effective
                                                       between period_open_date
                                                           and nvl(period_close_date, sysdate)))
                                                                                         between cp.start_date
                                                                                             and cp.end_date
                  )
                 or
                  (
                    greatest(nvl(th.amortization_start_date,
                                  th.transaction_date_entered), p_date_placed_in_service)
--to_date('01-JAN-1996', 'DD-MON-YYYY')
                                      between cp.start_date
                                          and cp.end_date
                    and exists (select 1 from fa_deprn_summary ds
                            where ds.deprn_reserve = 0
                            and   ds.book_type_code = p_book_type_code
                            and   ds.asset_id = p_asset_id
                            and   ds.deprn_source_code = 'BOOKS')
                     and not exists(select 1 from fa_transaction_headers th2
                                    where asset_id = p_asset_id
                                    and book_type_code = p_book_type_code
                                    and transaction_type_code not in ('TRANSFER OUT', 'TRANSFER IN',
                                                                      'TRANSFER', 'TRANSFER IN/VOID',
                                                                      'RECLASS', 'UNIT ADJUSTMENT',
                                                                      'REINSTATEMENT', 'ADDITION/VOID',
                                                                      'ADDITION', 'CIP ADDITION',
                                                                      'CIP ADJUSTMENT', 'CIP ADDITION/VOID')
                                    and nvl(th2.amortization_start_date, th2.transaction_date_entered) <
                                                  nvl(th.amortization_start_date, th.transaction_date_entered)
                                    )
                  )
                )
         )
        )
;

   --
   -- Get all possible period information that the asset needs
   --
   CURSOR c_get_period_rec IS
     select fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM period_counter
          , cp.start_date calendar_period_open_date
          , cp.end_date calendar_period_close_date
          , cp.period_num period_num
          , fy.fiscal_year fiscal_year
          , 0       cost
          , 0       recoverable_cost
          , 0       adjusted_recoverable_cost
          , 0       adjusted_cost
          , 0       reval_amortization_basis
          , null    ceiling_name
          , null    bonus_rule
          , null    allowed_deprn_limit
          , null       percent_salvage_value
          , null       salvage_value
          , 0       change_in_sal
          , null    allowed_deprn_limit_amount
          , 0       change_in_limit
          , 'YES'   depreciate_flag
          , p_date_placed_in_service date_placed_in_service
          , null    deprn_method_code
          , 0       life_in_months
          , 0       adjusted_rate
          , 0       production_capacity
          , 0       adjusted_capacity
          , 0       expense_adjustment_amount
          , 0       reserve_adjustment_amount
          , 0       ytd_proceeds_of_sale
          , 0       ltd_proceeds_of_sale
          , 0       ytd_cost_of_removal
          , 0       ltd_cost_of_removal
          , 0       change_in_cost
          , 0       change_in_cip_cost
          , 'N'     reset_adjusted_cost_flag
          , 0       transaction_header_id
          , 0       change_in_retirements_cost
          , 0       change_in_eofy_reserve
          , 0       reval_reserve
          , 0       bonus_deprn_amount
          , 0       bonus_ytd_deprn
          , 0       bonus_deprn_reserve
          , 0       impairment_amount
          , 0       ytd_impairment
          , 0       impairment_reserve
          , 1       rate_adjustment_factor
          , 1       formula_factor
          , null    salvage_type
          , null    deprn_limit_type
          , 0       deprn_amount
          , 0       ytd_deprn
          , 0       deprn_reserve
          , 0       ltd_production
          , 0       ytd_production
          , 0       production
          , 'Y'     capitalized_flag
          , 0       unplanned_amount
          , 0       eofy_adj_cost
          , 0       eofy_formula_factor
          , 0       eofy_reserve
          , 0       eop_adj_cost
          , 0       bonus_rate
     from   fa_fiscal_year fy
          , fa_calendar_types ct
          , fa_calendar_periods cp
     where  ct.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
     and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and    ct.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
     and    ct.calendar_type = cp.calendar_type
     and    cp.start_date between fy.start_date and fy.end_date
     and    fa_cache_pkg.fazcbc_record.last_period_counter + 1 >=
                  fy.fiscal_year * ct.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
     and    cp.end_date >= p_date_placed_in_service
     order by period_counter;

   --
   -- If this is slow, think about modifying c_get_member_trx to have
   -- period counter created as a paramater
   --
   CURSOR c_get_adj_amount (c_transaction_header_id number
                          , c_source_type_code varchar2
                          , c_adjustment_type  varchar2) IS
      SELECT sum(decode(debit_credit_flag, 'CR', -1, 1) * adjustment_amount)
      FROM   fa_adjustments
      WHERE  transaction_header_id = c_transaction_header_id
      AND    asset_id              = p_asset_id
      AND    book_type_code        = p_book_type_code
      AND    source_type_code      = c_source_type_code
      AND    adjustment_type       = c_adjustment_type;

   --
   -- This cursor to get initial reserve amount from b row
   --
   CURSOR c_get_init_rsv IS
      SELECT ytd_deprn
           , deprn_reserve
      FROM   fa_deprn_summary
      WHERE  asset_id = p_asset_id
      AND    book_type_code        = p_book_type_code
      AND    deprn_source_code = 'BOOKS';

   CURSOR c_get_ret_info (c_transaction_header_id number) IS
      select ret.cost_retired
      from   fa_retirements ret
      where  ret.transaction_header_id_in = c_transaction_header_id
      and    ret.transaction_header_id_out is null;


   l_cost_retired                number;


   tt_transaction_header_id      tab_num15_type;
   tt_transaction_type_code      tab_char30_type;
   tt_transaction_subtype        tab_char30_type;
   tt_transaction_key            tab_char3_type;
   tt_period_counter             tab_num15_type;
   tt_cost                       tab_num_type;
   tt_cip_cost                   tab_num_type;
   tt_salvage_value              tab_num_type;
   tt_allowed_deprn_limit_amount tab_num_type;
   tt_salvage_type_in            tab_char30_type;
   tt_salvage_type_out           tab_char30_type;
   tt_percent_salvage_value_in   tab_num_type;
   tt_percent_salvage_value_out  tab_num_type;
   tt_deprn_limit_type_in        tab_char30_type;
   tt_deprn_limit_type_out       tab_char30_type;
   tt_allowed_deprn_limit_in     tab_num_type;
   tt_allowed_deprn_limit_out    tab_num_type;
   tt_deprn_method_code          tab_char30_type;
   tt_life_in_months             tab_num15_type;
   tt_adjusted_rate              tab_num_type;
   tt_production_capacity        tab_num_type;

   tbs_transaction_header_id     tab_num15_type;
   tbs_change_in_sal             tab_num_type;
   tbs_change_in_limit           tab_num_type;
   tbs_change_in_retirements_cost tab_num_type;

   l_trans_rec                   FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec               FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_old           FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new           FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec             FA_API_TYPES.asset_deprn_rec_type;
   l_asset_type_rec              FA_API_TYPES.asset_type_rec_type;
   l_period_rec                  FA_API_TYPES.period_rec_type;

   l_dpr_in          fa_std_types.dpr_struct;
   l_dpr_out         fa_std_types.dpr_out_struct;
   l_dpr_arr         fa_std_types.dpr_arr_type;

   loc                           binary_integer;
   l_start_pc                    number(15);

   l_running_mode                number := fa_std_types.FA_DPR_NORMAL;

   l_temp_num                    number;

   l_eofy_rec_cost               number := 0;
   l_eop_rec_cost                number := 0;
   l_eofy_sal_val                number := 0;
   l_eop_sal_val                 number := 0;
   l_eofy_ind                    binary_integer;
   l_bs_ind                      binary_integer;
   l_adjusted_ind                binary_integer;

   l_fiscal_year                 number;
   l_period_num                  number;
   l_period_counter              number;

   l_source_type_code            varchar2(15);
   l_adjustment_type             varchar2(15);
   l_adj_amount                  number;
   l_ret_imp_amount              number;

   l_process_this_trx            boolean := TRUE;  -- Become FALSE in the loop if ret has reinstated
   l_dummy_bool                  boolean;

   l_db_event_type               varchar2(30); -- passed to deprn basis rule function
   l_asset_retire_rec            fa_api_types.asset_retire_rec_type; -- passed to deprn basis rule function
   l_recoverable_cost            number;  -- passed to deprn basis rule function
   l_salvage_value               number; -- passed to deprn basis rule function

   l_ytd_deprn                   number; -- used with c_get_init_rsv
   l_deprn_reserve               number; -- used with c_get_init_rsv

   l_skip                        boolean := TRUE;

   pro_err EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'BEGIN', p_asset_id, p_log_level_rec => p_log_level_rec);
   end if;

   OPEN c_get_period_rec;
   FETCH c_get_period_rec BULK COLLECT INTO fa_amort_pvt.t_period_counter
                                          , fa_amort_pvt.t_calendar_period_open_date
                                          , fa_amort_pvt.t_calendar_period_close_date
                                          , fa_amort_pvt.t_period_num
                                          , fa_amort_pvt.t_fiscal_year
                                          , fa_amort_pvt.t_cost
                                          , fa_amort_pvt.t_recoverable_cost
                                          , fa_amort_pvt.t_adjusted_recoverable_cost
                                          , fa_amort_pvt.t_adjusted_cost
                                          , fa_amort_pvt.t_reval_amortization_basis
                                          , fa_amort_pvt.t_ceiling_name
                                          , fa_amort_pvt.t_bonus_rule
                                          , fa_amort_pvt.t_allowed_deprn_limit
                                          , fa_amort_pvt.t_percent_salvage_value
                                          , fa_amort_pvt.t_salvage_value
                                          , tbs_change_in_sal
                                          , fa_amort_pvt.t_allowed_deprn_limit_amount
                                          , tbs_change_in_limit
                                          , fa_amort_pvt.t_depreciate_flag
                                          , fa_amort_pvt.t_date_placed_in_service
                                          , fa_amort_pvt.t_deprn_method_code
                                          , fa_amort_pvt.t_life_in_months
                                          , fa_amort_pvt.t_adjusted_rate
                                          , fa_amort_pvt.t_production_capacity
                                          , fa_amort_pvt.t_adjusted_capacity
                                          , fa_amort_pvt.t_expense_adjustment_amount
                                          , fa_amort_pvt.t_reserve_adjustment_amount
                                          , fa_amort_pvt.t_ytd_proceeds_of_sale
                                          , fa_amort_pvt.t_ltd_proceeds_of_sale
                                          , fa_amort_pvt.t_ytd_cost_of_removal
                                          , fa_amort_pvt.t_ltd_cost_of_removal
                                          , fa_amort_pvt.t_change_in_cost
                                          , fa_amort_pvt.t_change_in_cip_cost
                                          , fa_amort_pvt.t_reset_adjusted_cost_flag
                                          , tbs_transaction_header_id
                                          , tbs_change_in_retirements_cost
                                          , fa_amort_pvt.t_change_in_eofy_reserve
                                          , fa_amort_pvt.t_reval_reserve
                                          , fa_amort_pvt.t_bonus_deprn_amount
                                          , fa_amort_pvt.t_bonus_ytd_deprn
                                          , fa_amort_pvt.t_bonus_deprn_reserve
                                          , fa_amort_pvt.t_impairment_amount
                                          , fa_amort_pvt.t_ytd_impairment
                                          , fa_amort_pvt.t_impairment_reserve
                                          , fa_amort_pvt.t_rate_adjustment_factor
                                          , fa_amort_pvt.t_formula_factor
                                          , fa_amort_pvt.t_salvage_type
                                          , fa_amort_pvt.t_deprn_limit_type
                                          , fa_amort_pvt.t_deprn_amount
                                          , fa_amort_pvt.t_ytd_deprn
                                          , fa_amort_pvt.t_deprn_reserve
                                          , fa_amort_pvt.t_ltd_production
                                          , fa_amort_pvt.t_ytd_production
                                          , fa_amort_pvt.t_production
                                          , fa_amort_pvt.t_capitalized_flag
                                          , fa_amort_pvt.t_unplanned_amount
                                          , fa_amort_pvt.t_eofy_adj_cost
                                          , fa_amort_pvt.t_eofy_formula_factor
                                          , fa_amort_pvt.t_eofy_reserve
                                          , fa_amort_pvt.t_eop_adj_cost
                                          , fa_amort_pvt.t_bonus_rate
    ;
    CLOSE c_get_period_rec;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'c_get_period_rec returned', fa_amort_pvt.t_period_counter.count,  p_log_level_rec => p_log_level_rec);
   end if;


   OPEN c_get_member_trx;
   FETCH c_get_member_trx BULK COLLECT INTO tt_transaction_header_id
                                          , tt_transaction_type_code
                                          , tt_transaction_subtype
                                          , tt_transaction_key
                                          , tt_period_counter
                                          , tt_cost
                                          , tt_cip_cost
                                          , tt_salvage_value
                                          , tt_allowed_deprn_limit_amount
                                          , tt_salvage_type_in
                                          , tt_salvage_type_out
                                          , tt_percent_salvage_value_in
                                          , tt_percent_salvage_value_out
                                          , tt_deprn_limit_type_in
                                          , tt_deprn_limit_type_out
                                          , tt_allowed_deprn_limit_in
                                          , tt_allowed_deprn_limit_out
                                          , tt_deprn_method_code
                                          , tt_life_in_months
                                          , tt_adjusted_rate
                                          , tt_production_capacity

   ;
   CLOSE c_get_member_trx;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'c_get_member_trx returned', tt_transaction_header_id.count, p_log_level_rec => p_log_level_rec);
   end if;

   fa_amort_pvt.t_reset_adjusted_cost_flag(1)   :=  'Y';
   l_start_pc := fa_amort_pvt.t_period_counter(1);

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Before trx loop', l_start_pc, p_log_level_rec => p_log_level_rec);
   end if;

   FOR i in 1..tt_transaction_header_id.count LOOP

      l_process_this_trx := TRUE;
      loc := tt_period_counter(i) - l_start_pc + 1;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'trx type code('||to_char(i)||')', tt_transaction_type_code(i));
         fa_debug_pkg.add(l_calling_fn,'trx key('||to_char(i)||')', tt_transaction_key(i));
         fa_debug_pkg.add(l_calling_fn,'trx period counter('||to_char(i)||')', tt_period_counter(i));
      end if;

      -- If this trx is ret, then check to see if it's been reinstated or not
      -- Do not process if it's been reinstate.
      if (tt_transaction_type_code(i) like '%RETIREMENT') then
         l_cost_retired := 0;

         OPEN c_get_ret_info(tt_transaction_header_id(i));
         FETCH c_get_ret_info INTO l_cost_retired;

         -- Skip this trx if this ret has reinstated
         if c_get_ret_info%NOTFOUND then
            l_process_this_trx := FALSE;
         else
            tbs_change_in_retirements_cost(loc) := tbs_change_in_retirements_cost(loc) + tt_cost(i);
         end if;

         CLOSE c_get_ret_info;
      end if;

      if (l_process_this_trx) then

         fa_amort_pvt.t_reset_adjusted_cost_flag(loc) := 'Y';
         fa_amort_pvt.t_change_in_cost(loc) := fa_amort_pvt.t_change_in_cost(loc) + tt_cost(i);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'trx type code('||to_char(i)||')', tt_transaction_type_code(i));
         end if;

         if (tt_transaction_type_code(i) = 'ADDITION') then
            OPEN c_get_init_rsv;
            FETCH c_get_init_rsv INTO l_ytd_deprn, l_deprn_reserve;
            CLOSE c_get_init_rsv;

            if (l_deprn_reserve <> 0) then
               fa_amort_pvt.t_ytd_deprn(loc-1) := l_ytd_deprn;
               fa_amort_pvt.t_deprn_reserve(loc-1) := l_deprn_reserve;
            end if;
         end if;


         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'tt_salvage_value('||to_char(i)||')', tt_salvage_value(i));
            fa_debug_pkg.add(l_calling_fn,'tt_allowed_deprn_limit_amount('||to_char(i)||')', tt_allowed_deprn_limit_amount(i));
         end if;

         tbs_change_in_sal(loc) := tbs_change_in_sal(loc) + tt_salvage_value(i);
         tbs_change_in_limit(loc) := tbs_change_in_limit(loc) + tt_allowed_deprn_limit_amount(i);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'tbs_change_in_sal('||to_char(loc)||')', tbs_change_in_sal(loc));
            fa_debug_pkg.add(l_calling_fn,'tbs_change_in_limit('||to_char(loc)||')', tbs_change_in_limit(loc));
            fa_debug_pkg.add(l_calling_fn,'tbs_transaction_header_id('||to_char(loc)||')', tbs_transaction_header_id(loc));
         end if;

         if (tbs_transaction_header_id(loc) < tt_transaction_header_id(i)) then

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'tt_transaction_header_id('||to_char(i)||')', tt_transaction_header_id(i));
               fa_debug_pkg.add(l_calling_fn,'tt_salvage_type_in('||to_char(i)||')', tt_salvage_type_in(i));
            end if;

            tbs_transaction_header_id(loc)            := tt_transaction_header_id(i);
            fa_amort_pvt.t_deprn_method_code(loc)          := tt_deprn_method_code(i);
            fa_amort_pvt.t_salvage_type(loc)          := tt_salvage_type_in(i);
            fa_amort_pvt.t_percent_salvage_value(loc) := tt_percent_salvage_value_in(i);
            fa_amort_pvt.t_deprn_limit_type(loc)      := tt_deprn_limit_type_in(i);
            fa_amort_pvt.t_allowed_deprn_limit(loc)   := tt_allowed_deprn_limit_in(i);
            fa_amort_pvt.t_life_in_months(loc)        := tt_life_in_months(i);
            fa_amort_pvt.t_adjusted_rate(loc)         := tt_adjusted_rate(i);
            fa_amort_pvt.t_production_capacity(loc)   := tt_production_capacity(i);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Find Unplan and Impairment Amount', tt_transaction_key(i));
         end if;
         -- *********************
         -- Find unplanned amount and impairment
         -- *********************
         if (tt_transaction_key(i) in ('UE', 'UA', 'U', 'IM', 'R')) then
            if tt_transaction_key(i) = 'IM' then
               l_source_type_code := 'ADJUSTMENT';
               l_adjustment_type := 'IMPAIR EXPENSE';
            elsif (tt_transaction_type_code(i) like '%RETIREMENT') then
               l_source_type_code := 'RETIREMENT';
               l_adjustment_type := 'RESERVE';
            else
               l_source_type_code := 'DEPRECIATION';
               l_adjustment_type := 'EXPENSE';
            end if;

            OPEN c_get_adj_amount (tt_transaction_header_id(i)
                                 , l_source_type_code
                                 , l_adjustment_type);
            FETCH c_get_adj_amount INTO l_adj_amount;
            CLOSE c_get_adj_amount;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'l_adj_amount', l_adj_amount, p_log_level_rec => p_log_level_rec);
            end if;

            l_ret_imp_amount := 0;

            if tt_transaction_key(i) = 'R' then
               l_source_type_code := 'RETIREMENT';
               l_adjustment_type := 'IMPAIR RESERVE';

               OPEN c_get_adj_amount (tt_transaction_header_id(i)
                                    , l_source_type_code
                                    , l_adjustment_type);
               FETCH c_get_adj_amount INTO l_ret_imp_amount;
               CLOSE c_get_adj_amount;


            end if;

            if tt_transaction_key(i) = 'IM' then
               -- accumulation may not be necessary because we only allow a impairment per pereiod.
               fa_amort_pvt.t_impairment_amount(loc-1) := fa_amort_pvt.t_impairment_amount(loc-1) +
                                                        l_adj_amount;
            elsif (tt_transaction_key(i) in ('UE', 'UA', 'U')) then
               fa_amort_pvt.t_unplanned_amount(loc) := fa_amort_pvt.t_unplanned_amount(loc) +
                                                       l_adj_amount;
               fa_amort_pvt.t_expense_adjustment_amount(loc) := fa_amort_pvt.t_expense_adjustment_amount(loc) +
                                                                l_adj_amount;
            elsif (tt_transaction_type_code(i) like '%RETIREMENT') then
               fa_amort_pvt.t_reserve_adjustment_amount(i) :=  fa_amort_pvt.t_reserve_adjustment_amount(loc) -
                                                               l_adj_amount;
               fa_amort_pvt.t_impairment_amount(loc-1) := fa_amort_pvt.t_impairment_amount(loc-1) -
                                                          l_ret_imp_amount;
            end if;

         end if; -- (tt_transaction_key(i) in ('UE', 'UA', 'U', 'IM')

      end if; -- (l_process_this_trx)
   END LOOP; -- i in 1..tt_transaction_header_id.count

   --
   -- Get reserve entry from fa_adjustments and fa_deprn_summary(b row)
   --

   l_asset_hdr_rec.asset_id           := p_asset_id;
   l_asset_hdr_rec.period_of_addition := null;
   l_asset_hdr_rec.book_type_code     := p_book_type_code;
   l_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;

   l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
   l_dpr_in.book := l_asset_hdr_rec.book_type_code;
   l_dpr_in.asset_id := l_asset_hdr_rec.asset_id;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'calling', 'FA_UTIL_PVT.get_asset_fin_rec',  p_log_level_rec => p_log_level_rec);
   end if;

   -- Populate fin rec
   if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec_old,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
            raise pro_err;
   end if;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'period loop', 'Begin', p_log_level_rec => p_log_level_rec);
   end if;

   --
   -- Calculate periodic depreciation amounts
   --
   l_bs_ind := 1;

   l_asset_fin_rec_old.cost := 0;
   l_asset_fin_rec_old.recoverable_cost := 0;
   l_asset_fin_rec_old.adjusted_recoverable_cost := 0;
   l_asset_fin_rec_old.adjusted_cost := 0;
   l_asset_fin_rec_old.rate_adjustment_factor := 0;
   l_asset_fin_rec_old.formula_factor := 0;
   l_asset_fin_rec_old.eofy_reserve := 0;
   l_asset_fin_rec_old.reval_amortization_basis:= 0;
   l_asset_fin_rec_old.adjusted_capacity := 0;
   l_asset_fin_rec_new := l_asset_fin_rec_old;


   FOR i in 1..fa_amort_pvt.t_period_counter.count LOOP

      if (l_skip) and (tbs_transaction_header_id(i) = 0) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'Skip this period', fa_amort_pvt.t_period_counter(i));
         end if;

         l_bs_ind := l_bs_ind + 1;
      else
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'tbs_transaction_header_id('||to_char(i)||')', tbs_transaction_header_id(i));
         end if;

         l_skip := FALSE;


         if (i = 1) then
            fa_amort_pvt.t_cost(i) := fa_amort_pvt.t_cost(i) + fa_amort_pvt.t_change_in_cost(i);
         else
            fa_amort_pvt.t_cost(i) := fa_amort_pvt.t_cost(i-1) + fa_amort_pvt.t_change_in_cost(i);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'t_salvage_type('||to_char(i)||')', fa_amort_pvt.t_salvage_type(i));
         end if;

         if (fa_amort_pvt.t_salvage_type(i) is null) then
            fa_amort_pvt.t_salvage_type(i) := fa_amort_pvt.t_salvage_type(i-1);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'t_salvage_type('||to_char(i)||')', fa_amort_pvt.t_salvage_type(i));
         end if;

         if (fa_amort_pvt.t_salvage_type(i) = 'PCT') then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'t_percent_salvage_value('||to_char(i)||')', fa_amort_pvt.t_percent_salvage_value(i));
            end if;

            if (fa_amort_pvt.t_percent_salvage_value(i) is null) then
               if (i > 1) then
                  fa_amort_pvt.t_percent_salvage_value(i) := fa_amort_pvt.t_percent_salvage_value(i-1);
               else
                  fa_amort_pvt.t_percent_salvage_value(i) := 0;
               end if;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'t_percent_salvage_value('||to_char(i)||')', fa_amort_pvt.t_percent_salvage_value(i));
            end if;

            l_temp_num := fa_amort_pvt.t_cost(i) * fa_amort_pvt.t_percent_salvage_value(i);
            fa_round_pkg.fa_ceil(l_temp_num, p_book_type_code, p_log_level_rec => p_log_level_rec);
            fa_amort_pvt.t_salvage_value(i) := l_temp_num;
         else
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn,'tbs_change_in_sal('||to_char(i)||')', tbs_change_in_sal(i));
            end if;

            if (i > 1) then
               fa_amort_pvt.t_salvage_value(i) := fa_amort_pvt.t_salvage_value(i-1) + tbs_change_in_sal(i);
            else
               fa_amort_pvt.t_salvage_value(i) := tbs_change_in_sal(i);
            end if;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'t_salvage_value('||to_char(i)||')', fa_amort_pvt.t_salvage_value(i));
            fa_debug_pkg.add(l_calling_fn,'t_deprn_limit_type('||to_char(i)||')', fa_amort_pvt.t_deprn_limit_type(i));
         end if;

         if (fa_amort_pvt.t_deprn_limit_type(i) is null) then
            fa_amort_pvt.t_deprn_limit_type(i) := fa_amort_pvt.t_deprn_limit_type(i-1);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn,'t_deprn_limit_type('||to_char(i)||')', fa_amort_pvt.t_deprn_limit_type(i));
         end if;

         if (fa_amort_pvt.t_deprn_limit_type(i) = 'PCT') then
            if (fa_amort_pvt.t_allowed_deprn_limit(i) is null) then
               if (i > 1) then
                  fa_amort_pvt.t_allowed_deprn_limit(i) := fa_amort_pvt.t_allowed_deprn_limit(i-1);
               else
                  fa_amort_pvt.t_allowed_deprn_limit(i) := 0;
               end if;
            end if;

            l_temp_num := fa_amort_pvt.t_cost(i) * (1 -  fa_amort_pvt.t_allowed_deprn_limit(i));
            fa_round_pkg.fa_floor(l_temp_num, l_asset_hdr_rec.book_type_code, p_log_level_rec => p_log_level_rec);
            fa_amort_pvt.t_allowed_deprn_limit_amount(i) := l_temp_num;

         elsif(fa_amort_pvt.t_deprn_limit_type(i) = 'AMT') then
            if (i > 1) then
               fa_amort_pvt.t_allowed_deprn_limit_amount(i) := nvl(fa_amort_pvt.t_allowed_deprn_limit_amount(i-1), 0) +
                                                            tbs_change_in_limit(i);
            else
               fa_amort_pvt.t_allowed_deprn_limit_amount(i) := tbs_change_in_limit(i);
            end if;
         else  -- case of 'NONE'
            fa_amort_pvt.t_allowed_deprn_limit_amount(i) := null;
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'sal_val('||to_char(i)||')', fa_amort_pvt.t_salvage_value(i));
            fa_debug_pkg.add(l_calling_fn, 'limit('||to_char(i)||')', fa_amort_pvt.t_allowed_deprn_limit_amount(i));
         end if;

         fa_amort_pvt.t_recoverable_cost(i) := fa_amort_pvt.t_cost(i) - fa_amort_pvt.t_salvage_value(i);
         fa_amort_pvt.t_adjusted_recoverable_cost(i) := fa_amort_pvt.t_cost(i) -
                                                        nvl(fa_amort_pvt.t_allowed_deprn_limit_amount(i), 0);

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'rec cost('||to_char(i)||')', fa_amort_pvt.t_recoverable_cost(i));
            fa_debug_pkg.add(l_calling_fn, 'adj_rec_cost('||to_char(i)||')', fa_amort_pvt.t_adjusted_recoverable_cost(i));
         end if;

         if (fa_amort_pvt.t_deprn_method_code(i) is null) then
            fa_amort_pvt.t_deprn_method_code(i) := fa_amort_pvt.t_deprn_method_code(i-1);
            fa_amort_pvt.t_adjusted_rate(i) := fa_amort_pvt.t_adjusted_rate(i-1);
            fa_amort_pvt.t_life_in_months(i) := fa_amort_pvt.t_life_in_months(i-1);
         end if;

         if (fa_amort_pvt.t_depreciate_flag(i) is null) then
            fa_amort_pvt.t_depreciate_flag(i) := fa_amort_pvt.t_depreciate_flag(i-1);
         end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_period_counter', fa_amort_pvt.t_period_counter(i));
            fa_debug_pkg.add(l_calling_fn, 'p_imp_period_rec.period_counter', p_imp_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
         end if;

         --
         -- Want to populate fa_amort_pvt tables but not necessary to calculate deprn basis
         -- nor periodic depreciations because impairment amount has to be determined first
         -- for periods after impairment transactions
         --
         if fa_amort_pvt.t_period_counter(i) <=  p_imp_period_rec.period_counter and
            l_bs_ind <= i then

            fa_amort_pvt.t_deprn_amount(i)   := nvl(fa_amort_pvt.t_expense_adjustment_amount(i), 0);

            if (i = 1) then
               fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_deprn_amount(i);
               fa_amort_pvt.t_deprn_reserve(i)  := nvl(fa_amort_pvt.t_deprn_amount(i), 0) +
                                                             nvl(fa_amort_pvt.t_reserve_adjustment_amount(i), 0);
               fa_amort_pvt.t_eofy_reserve (i)  := nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
            else
               fa_amort_pvt.t_deprn_reserve(i)  := fa_amort_pvt.t_deprn_reserve(i-1) +
                                                   nvl(fa_amort_pvt.t_deprn_amount(i), 0) +
                                                   nvl(fa_amort_pvt.t_reserve_adjustment_amount(i), 0);
               if (i > 1) then
                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_deprn_amount(i);
                     fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_deprn_reserve(i - 1) +
                                                              nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  else
                     fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_ytd_deprn(i-1) +
                                                         fa_amort_pvt.t_deprn_amount(i);
                     fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_eofy_reserve(i - 1) +
                                                              nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  end if;
               else
                  --
                  -- If user entered reserve exists, code below may need to be modified
                  --
                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     fa_amort_pvt.t_eofy_reserve (i)       := 0;
                  else
                     fa_amort_pvt.t_eofy_reserve (i)       := 0;
                  end if;
               end if;

            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_reserve', fa_amort_pvt.t_deprn_reserve(i));
            end if;


            l_asset_fin_rec_old := l_asset_fin_rec_new;
            l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'rec cost('||to_char(i)||')', fa_amort_pvt.t_recoverable_cost(i));
               fa_debug_pkg.add(l_calling_fn, 'adj_rec_cost('||to_char(i)||')', fa_amort_pvt.t_adjusted_recoverable_cost(i));
            end if;

            l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_asset_fin_rec_new.adjusted_recoverable_cost := fa_amort_pvt.t_adjusted_recoverable_cost(i);
            l_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(i);
            l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);

             --
             -- If only trx happened in this period is ret then calculate deprn basis
             -- for ret mode, otherwise use amort_adj mode.
             --
             if (tbs_change_in_retirements_cost(i) <> 0) and
                (tbs_change_in_retirements_cost(i) = fa_amort_pvt.t_change_in_cost(i)) then
               l_db_event_type := 'RETIREMENT';
               l_recoverable_cost := l_asset_fin_rec_new.recoverable_cost;
               l_salvage_value := l_asset_fin_rec_new.cost - l_asset_fin_rec_new.recoverable_cost;
               l_asset_retire_rec.cost_retired := -1 * tbs_change_in_retirements_cost(i);
            else
               l_db_event_type := 'AMORT_ADJ';
               l_recoverable_cost := null;
               l_salvage_value := null;
               l_asset_retire_rec := null;
            end if;


            l_dpr_in.adj_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_dpr_in.salvage_value := fa_amort_pvt.t_salvage_value(i);
            l_dpr_in.rec_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_dpr_in.adj_rec_cost := fa_amort_pvt.t_adjusted_recoverable_cost(i);
            l_dpr_in.reval_amo_basis := fa_amort_pvt.t_reval_amortization_basis(i);
            l_dpr_in.adj_rate := fa_amort_pvt.t_adjusted_rate(i);
            l_dpr_in.rate_adj_factor := 1;
            l_dpr_in.capacity := fa_amort_pvt.t_production_capacity(i);
            l_dpr_in.adj_capacity := fa_amort_pvt.t_adjusted_capacity(i);
            l_dpr_in.ltd_prod := 0;
            l_dpr_in.ytd_deprn := 0;    -- This needs to be 0 for the 1st faxcde call
            l_dpr_in.prior_fy_exp := 0;
            l_dpr_in.deprn_rsv := 0;
            l_dpr_in.reval_rsv := fa_amort_pvt.t_reval_reserve(i);
            l_dpr_in.bonus_deprn_exp := fa_amort_pvt.t_bonus_deprn_amount(i);
            l_dpr_in.bonus_ytd_deprn := fa_amort_pvt.t_bonus_ytd_deprn(i);
            l_dpr_in.bonus_deprn_rsv := fa_amort_pvt.t_bonus_deprn_reserve(i);

            if (i = 1) then
               l_dpr_in.impairment_exp := fa_amort_pvt.t_impairment_amount(i);
               l_dpr_in.ytd_impairment := fa_amort_pvt.t_ytd_impairment(i);
               l_dpr_in.impairment_rsv := fa_amort_pvt.t_impairment_reserve(i);
            else
               l_dpr_in.impairment_exp := fa_amort_pvt.t_impairment_amount(i);
               l_dpr_in.ytd_impairment := fa_amort_pvt.t_ytd_impairment(i-1) + l_dpr_in.impairment_exp;
               l_dpr_in.impairment_rsv := fa_amort_pvt.t_impairment_reserve(i-1) + l_dpr_in.impairment_exp;
            end if;

            l_dpr_in.ceil_name := fa_amort_pvt.t_ceiling_name(i);
            l_dpr_in.bonus_rule := fa_amort_pvt.t_bonus_rule(i);
            l_dpr_in.method_code := fa_amort_pvt.t_deprn_method_code(i);
            l_dpr_in.life        := fa_amort_pvt.t_life_in_months(i); -- bug5894464
            l_dpr_in.jdate_in_service :=
                      to_number(to_char(fa_amort_pvt.t_date_placed_in_service(i), 'J'));
            l_dpr_in.deprn_start_jdate := to_number(to_char(l_asset_fin_rec_old.deprn_start_date, 'J'));
            l_dpr_in.prorate_jdate := to_number(to_char(l_asset_fin_rec_old.prorate_date, 'J'));

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            if (not fa_cache_pkg.fazccmt(
                       fa_amort_pvt.t_deprn_method_code(i),
                       fa_amort_pvt.t_life_in_months(i),
                       p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
               end if;

               raise pro_err;
            end if;

               if i = 1 then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  end if;

                  if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                             fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                             l_dpr_in.prorate_jdate,
                                             g_temp_number,
                                             l_dpr_in.y_begin,
                                             g_temp_integer, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                         'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                         fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                         fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'l_dpr_in.prorate_jdate',
                                         l_dpr_in.prorate_jdate, p_log_level_rec => p_log_level_rec);

                     end if;

                     raise pro_err;
                  end if;
               end if;


               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'faxcde for hype reserve', p_log_level_rec => p_log_level_rec);
               end if;

               -- Skip faxcde call to find hyp rsv if method type is not (FLAT or PROD) and basis is COST
               if (((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') not in(fa_std_types.FAD_RSR_FLAT,
                                                                                   fa_std_types.FAD_RSR_PROD)) and
                    (nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,' ') = fa_std_types.FAD_DBR_COST))) then

                  -- bug5894464
                  l_dpr_in.p_cl_begin := 1;

                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i) - 1;
                     l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                  else
                     l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i);
                     l_dpr_in.p_cl_end := fa_amort_pvt.t_period_num(i) - 1;
                  end if;
                  -- bug5894464

                  --+++++++ Call Depreciation engine for rate adjustment factor +++++++
                  if not FA_CDE_PKG.faxcde(l_dpr_in,
                                           l_dpr_arr,
                                           l_dpr_out,
                                           l_running_mode, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                     end if;

                     raise pro_err;
                  end if;
               end if; -- (((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') not in(fa_std_types.FAD_RSR_FLAT,

               l_period_rec.period_counter := fa_amort_pvt.t_period_counter(i);
               l_period_rec.period_num := fa_amort_pvt.t_period_num(i);
               l_period_rec.fiscal_year := fa_amort_pvt.t_fiscal_year(i);

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               end if;

               l_asset_deprn_rec.impairment_reserve := --fa_amort_pvt.t_impairment_amount(i) +
                                                          l_dpr_out.new_impairment_rsv;

               -- Manipulate eofy_reserve in if following conditioin is satisfied as
               -- depreciable basis will not use actual eofy_reserve

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_impairment_amount(i)', fa_amort_pvt.t_impairment_amount(i));
                  fa_debug_pkg.add(l_calling_fn, 'rule_name', fa_cache_pkg.fazcdbr_record.rule_name, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'deprn_basis_rule', fa_cache_pkg.fazccmt_record.deprn_basis_rule, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'use_rsv_after_imp_flag', fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, p_log_level_rec => p_log_level_rec);
               end if;

               if (i > 1) and (fa_amort_pvt.t_impairment_amount(i-1) <> 0) and
                  (fa_cache_pkg.fazcdbr_record.rule_name = 'FLAT RATE EXTENSION') and
                  (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_NBV) and
                  (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'N') = 'Y') then

                  l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_deprn_reserve(i-1) +
                                                      nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  fa_amort_pvt.t_eofy_reserve(i-1) := l_asset_fin_rec_new.eofy_reserve;

               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               end if;

               if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                                      (p_event_type             => l_db_event_type,
                                       p_asset_fin_rec_new      => l_asset_fin_rec_new,
                                       p_asset_fin_rec_old      => l_asset_fin_rec_old,
                                       p_asset_hdr_rec          => l_asset_hdr_rec,
                                       p_asset_type_rec         => l_asset_type_rec,
                                       p_asset_deprn_rec        => l_asset_deprn_rec,
                                       p_trans_rec              => l_trans_rec,
                                       p_trans_rec_adj          => l_trans_rec,
                                       p_period_rec             => l_period_rec,
                                       p_asset_retire_rec          => l_asset_retire_rec,
                                       p_recoverable_cost       => l_recoverable_cost,
                                       p_salvage_value          => l_salvage_value,
                                       p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
                                       p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                                                   nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                                                                   nvl(l_asset_deprn_rec.impairment_reserve, 0),
                                       p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
                                       p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
                                       p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                                       p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                                                   nvl(l_dpr_out.new_bonus_deprn_rsv, 0) -
                                                                   nvl(l_dpr_out.new_impairment_rsv,0),
                                       p_eofy_recoverable_cost  => l_eofy_rec_cost,
                                       p_eop_recoverable_cost   => l_eop_rec_cost,
                                       p_eofy_salvage_value     => l_eofy_sal_val,
                                       p_eop_salvage_value      => l_eop_sal_val,
                                       p_mrc_sob_type_code      => p_mrc_sob_type_code,
                                       p_used_by_adjustment     => 'ADJUSTMENT',
                                       px_new_adjusted_cost     => fa_amort_pvt.t_adjusted_cost(i),
                                       px_new_raf               => fa_amort_pvt.t_rate_adjustment_factor(i),
                                       px_new_formula_factor    => fa_amort_pvt.t_formula_factor(i),

                                       p_log_level_rec     => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise pro_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                   'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'adjusted_cost',
                                   fa_amort_pvt.t_adjusted_cost(i));
                  fa_debug_pkg.add(l_calling_fn, 'rate_adjustment_factor',
                                   fa_amort_pvt.t_rate_adjustment_factor(i));
                  fa_debug_pkg.add(l_calling_fn, 'formula_factor',
                                   fa_amort_pvt.t_formula_factor(i));
                  fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               l_adjusted_ind := 0;

               FOR j in (i + 1)..(fa_amort_pvt.t_period_counter.count) LOOP
                  l_adjusted_ind := l_adjusted_ind + 1;


                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 't_period_counter('||to_char(j)||') ', fa_amort_pvt.t_period_counter(j));
                     fa_debug_pkg.add(l_calling_fn, 'p_imp_period_rec.period_counter', p_imp_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
                  end if;

                  if ((fa_amort_pvt.t_reset_adjusted_cost_flag(j) = 'Y') or
                      (j = (fa_amort_pvt.t_period_counter.count))) or
                     ( fa_amort_pvt.t_period_counter(j) = p_imp_period_rec.period_counter + 1) then

                     l_fiscal_year := fa_amort_pvt.t_fiscal_year(j-1);
                     l_period_num := fa_amort_pvt.t_period_num(j-1);
                     l_period_counter := fa_amort_pvt.t_period_counter(j-1);
                     EXIT;
                  end if;

               END LOOP;

               --
               -- Prepare Running Depreciation
               --
               l_dpr_in.y_begin := fa_amort_pvt.t_fiscal_year(i);
               l_dpr_in.p_cl_begin := fa_amort_pvt.t_period_num(i);
               l_dpr_in.y_end := l_fiscal_year;
               l_dpr_in.p_cl_end := l_period_num;
               l_dpr_in.ytd_deprn := fa_amort_pvt.t_ytd_deprn(i);
               l_dpr_in.deprn_rsv := fa_amort_pvt.t_deprn_reserve(i);
               l_dpr_in.adj_cost := fa_amort_pvt.t_adjusted_cost(i);
               l_dpr_in.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
               l_dpr_in.rate_adj_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
               l_dpr_in.formula_factor := fa_amort_pvt.t_formula_factor(i);

               if (l_period_rec.period_num <> 1) then
                  l_dpr_in.deprn_rounding_flag := 'ADJ';
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'y_begin', l_dpr_in.y_begin, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'p_cl_begin', l_dpr_in.p_cl_begin, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'y_end', l_dpr_in.y_end, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'p_cl_end', l_dpr_in.p_cl_end, p_log_level_rec => p_log_level_rec);
               end if;


               --
               -- Calculate periodic depreciation
               --

               if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode,
                                        l_bs_ind, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise pro_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'After Calling', 'faxcde', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'l_dpr_out.impairment_rsv', l_dpr_out.new_impairment_rsv, p_log_level_rec => p_log_level_rec);
               end if;

               if (l_asset_fin_rec_new.adjusted_cost <> 0) or
                  (l_dpr_out.new_adj_cost <> 0) then

                  l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
                  l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
                  l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);
                  l_asset_fin_rec_new.salvage_value := fa_amort_pvt.t_salvage_value(i);
                  l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
                  l_asset_fin_rec_new.deprn_method_code := fa_amort_pvt.t_deprn_method_code(i);
                  l_asset_fin_rec_new.life_in_months := fa_amort_pvt.t_life_in_months(i);
                  l_asset_fin_rec_new.depreciate_flag := fa_amort_pvt.t_depreciate_flag(i);
                  l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
                  l_asset_fin_rec_new.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
                  l_asset_fin_rec_new.formula_factor := fa_amort_pvt.t_formula_factor(i);

                  l_asset_deprn_rec.deprn_reserve := l_dpr_out.new_deprn_rsv;
                  l_asset_deprn_rec.ytd_deprn := l_dpr_out.new_ytd_deprn;
                  l_asset_deprn_rec.reval_deprn_reserve := l_dpr_out.new_reval_rsv;
                  l_asset_deprn_rec.ltd_production := l_dpr_out.new_ltd_prod;
                  l_asset_fin_rec_new.eofy_reserve := l_dpr_out.new_eofy_reserve;
                  l_asset_deprn_rec.prior_fy_expense := l_dpr_out.new_prior_fy_exp;
                  l_asset_deprn_rec.bonus_deprn_amount := l_dpr_out.bonus_deprn_exp;
                  l_asset_deprn_rec.bonus_deprn_reserve := l_dpr_out.new_bonus_deprn_rsv;
                  l_asset_deprn_rec.prior_fy_bonus_expense := l_dpr_out.new_prior_fy_bonus_exp;
                  l_asset_deprn_rec.impairment_reserve := l_dpr_out.new_impairment_rsv;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'l_asset_deprn_rec.impairment_reserve', l_asset_deprn_rec.impairment_reserve, p_log_level_rec => p_log_level_rec);
                  end if;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Finish copying to ', 'fin_rec_new', p_log_level_rec => p_log_level_rec);
               end if;

               l_eop_rec_cost := fa_amort_pvt.t_recoverable_cost(i);
               l_eop_sal_val  := fa_amort_pvt.t_salvage_value(i);

               l_eofy_ind := i - fa_amort_pvt.t_period_num(i);

               if (l_eofy_ind > 0) then
                  l_eofy_rec_cost := fa_amort_pvt.t_recoverable_cost(l_eofy_ind);
                  l_eofy_sal_val  := fa_amort_pvt.t_salvage_value(l_eofy_ind);
               end if;

               l_bs_ind := l_bs_ind + l_adjusted_ind;

         end if; --fa_amort_pvt.t_period_counter(i) <=  p_imp_period_rec.period_counter)

      end if; -- (l_skip) and (tbs_transaction_header_id(i) = 0)

   END LOOP; -- i in 1..fa_amort_pvt.t_period_counter.count

   --
   -- Preserve rows in FA_BOOKS_SUMMARY_T table for later use
   --
   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Inserting into FA_BOOKS_SUMMARY_T',
                       fa_amort_pvt.t_period_counter.count,  p_log_level_rec => p_log_level_rec);
   end if;

   FORALL i in 1..fa_amort_pvt.t_period_counter.count
         INSERT INTO FA_BOOKS_SUMMARY_T(
                   REQUEST_ID
                 , IMPAIRMENT_ID
                 , ASSET_ID
                 , BOOK_TYPE_CODE
                 , PERIOD_COUNTER
                 , FISCAL_YEAR
                 , PERIOD_NUM
                 , CALENDAR_PERIOD_OPEN_DATE
                 , CALENDAR_PERIOD_CLOSE_DATE
                 , RESET_ADJUSTED_COST_FLAG
                 , CHANGE_IN_COST
--                 , CHANGE_IN_ADDITIONS_COST
--                 , CHANGE_IN_ADJUSTMENTS_COST
--                 , CHANGE_IN_RETIREMENTS_COST
--                 , CHANGE_IN_GROUP_REC_COST
                 , CHANGE_IN_CIP_COST
                 , COST
--                 , CIP_COST
                 , SALVAGE_TYPE
                 , PERCENT_SALVAGE_VALUE
                 , SALVAGE_VALUE
--                 , MEMBER_SALVAGE_VALUE
                 , RECOVERABLE_COST
                 , DEPRN_LIMIT_TYPE
                 , ALLOWED_DEPRN_LIMIT
                 , ALLOWED_DEPRN_LIMIT_AMOUNT
--                 , MEMBER_DEPRN_LIMIT_AMOUNT
                 , ADJUSTED_RECOVERABLE_COST
                 , ADJUSTED_COST
                 , DEPRECIATE_FLAG
--                 , DISABLED_FLAG
                 , DATE_PLACED_IN_SERVICE
                 , DEPRN_METHOD_CODE
                 , LIFE_IN_MONTHS
                 , RATE_ADJUSTMENT_FACTOR
                 , ADJUSTED_RATE
                 , BONUS_RULE
                 , ADJUSTED_CAPACITY
                 , PRODUCTION_CAPACITY
--                 , UNIT_OF_MEASURE
--                 , REMAINING_LIFE1
--                 , REMAINING_LIFE2
                 , FORMULA_FACTOR
--                 , UNREVALUED_COST
                 , REVAL_AMORTIZATION_BASIS
--                 , REVAL_CEILING
                 , CEILING_NAME
                 , EOFY_ADJ_COST
                 , EOFY_FORMULA_FACTOR
                 , EOFY_RESERVE
                 , EOP_ADJ_COST
--                 , EOP_FORMULA_FACTOR
--                 , SHORT_FISCAL_YEAR_FLAG
--                 , GROUP_ASSET_ID
--                 , SUPER_GROUP_ID
--                 , OVER_DEPRECIATE_OPTION
--                 , FULLY_RSVD_REVALS_COUNTER
                 , CAPITALIZED_FLAG
--                 , FULLY_RESERVED_FLAG
--                 , FULLY_RETIRED_FLAG
--                 , LIFE_COMPLETE_FLAG
--                 , TERMINAL_GAIN_LOSS_AMOUNT
--                 , TERMINAL_GAIN_LOSS_FLAG
                 , DEPRN_AMOUNT
                 , YTD_DEPRN
                 , DEPRN_RESERVE
                 , BONUS_DEPRN_AMOUNT
                 , BONUS_YTD_DEPRN
                 , BONUS_DEPRN_RESERVE
                 , BONUS_RATE
                 , LTD_PRODUCTION
                 , YTD_PRODUCTION
                 , PRODUCTION
--n                 , REVAL_AMORTIZATION
--n                 , REVAL_DEPRN_EXPENSE
                 , REVAL_RESERVE
--n                 , YTD_REVAL_DEPRN_EXPENSE
--n                 , DEPRN_OVERRIDE_FLAG
--n                 , SYSTEM_DEPRN_AMOUNT
--n                 , SYSTEM_BONUS_DEPRN_AMOUNT
                 , YTD_PROCEEDS_OF_SALE
                 , LTD_PROCEEDS_OF_SALE
                 , YTD_COST_OF_REMOVAL
                 , LTD_COST_OF_REMOVAL
--                 , DEPRN_ADJUSTMENT_AMOUNT
                 , EXPENSE_ADJUSTMENT_AMOUNT
                 , UNPLANNED_AMOUNT
                 , RESERVE_ADJUSTMENT_AMOUNT
                 , CREATION_DATE
                 , CREATED_BY
                 , LAST_UPDATE_DATE
                 , LAST_UPDATED_BY
--                 , LAST_UPDATE_LOGIN
                 , CHANGE_IN_EOFY_RESERVE
--                 , SWITCH_CODE
--                 , POLISH_DEPRN_BASIS
--                 , POLISH_ADJ_REC_COST
                 , IMPAIRMENT_AMOUNT
                 , YTD_IMPAIRMENT
                 , IMPAIRMENT_RESERVE
         ) VALUES(
                   p_request_id
                 , p_impairment_id
                 , p_asset_id
                 , p_book_type_code
                 , fa_amort_pvt.t_period_counter(i)
                 , fa_amort_pvt.t_fiscal_year(i)
                 , fa_amort_pvt.t_period_num(i)
                 , fa_amort_pvt.t_calendar_period_open_date(i)
                 , fa_amort_pvt.t_calendar_period_close_date(i)
                 , fa_amort_pvt.t_reset_adjusted_cost_flag(i)
                 , fa_amort_pvt.t_change_in_cost(i)
                 , fa_amort_pvt.t_change_in_cip_cost(i)
                 , fa_amort_pvt.t_cost(i)
                 , fa_amort_pvt.t_salvage_type(i)
                 , fa_amort_pvt.t_percent_salvage_value(i)
                 , fa_amort_pvt.t_salvage_value(i)
                 , fa_amort_pvt.t_recoverable_cost(i)
                 , fa_amort_pvt.t_deprn_limit_type(i)
                 , fa_amort_pvt.t_allowed_deprn_limit(i)
                 , fa_amort_pvt.t_allowed_deprn_limit_amount(i)
                 , fa_amort_pvt.t_adjusted_recoverable_cost(i)
                 , fa_amort_pvt.t_adjusted_cost(i)
                 , fa_amort_pvt.t_depreciate_flag(i)
                 , fa_amort_pvt.t_date_placed_in_service(i)
                 , fa_amort_pvt.t_deprn_method_code(i)
                 , fa_amort_pvt.t_life_in_months(i)
                 , fa_amort_pvt.t_rate_adjustment_factor(i)
                 , fa_amort_pvt.t_adjusted_rate(i)
                 , fa_amort_pvt.t_bonus_rule(i)
                 , fa_amort_pvt.t_adjusted_capacity(i)
                 , fa_amort_pvt.t_production_capacity(i)
                 , fa_amort_pvt.t_formula_factor(i)
                 , fa_amort_pvt.t_reval_amortization_basis(i)
                 , fa_amort_pvt.t_ceiling_name(i)
                 , fa_amort_pvt.t_eofy_adj_cost(i)
                 , fa_amort_pvt.t_eofy_formula_factor(i)
                 , fa_amort_pvt.t_eofy_reserve(i)
                 , fa_amort_pvt.t_eop_adj_cost(i)
                 , fa_amort_pvt.t_capitalized_flag(i)
                 , fa_amort_pvt.t_deprn_amount(i)
                 , fa_amort_pvt.t_ytd_deprn(i)
                 , fa_amort_pvt.t_deprn_reserve(i)
                 , fa_amort_pvt.t_bonus_deprn_amount(i)
                 , fa_amort_pvt.t_bonus_ytd_deprn(i)
                 , fa_amort_pvt.t_bonus_deprn_reserve(i)
                 , fa_amort_pvt.t_bonus_rate(i)
                 , fa_amort_pvt.t_ltd_production(i)
                 , fa_amort_pvt.t_ytd_production(i)
                 , fa_amort_pvt.t_production(i)
                 , fa_amort_pvt.t_reval_reserve(i)
                 , fa_amort_pvt.t_ytd_proceeds_of_sale(i)
                 , fa_amort_pvt.t_ltd_proceeds_of_sale(i)
                 , fa_amort_pvt.t_ytd_cost_of_removal(i)
                 , fa_amort_pvt.t_ltd_cost_of_removal(i)
                 , fa_amort_pvt.t_expense_adjustment_amount(i)
                 , fa_amort_pvt.t_unplanned_amount(i)
                 , fa_amort_pvt.t_reserve_adjustment_amount(i)
                 , sysdate
                 , FND_GLOBAL.USER_ID
                 , sysdate
                 , FND_GLOBAL.USER_ID
                 , fa_amort_pvt.t_change_in_eofy_reserve(i)
                 , fa_amort_pvt.t_impairment_amount(i)
                 , fa_amort_pvt.t_ytd_impairment(i)
                 , fa_amort_pvt.t_impairment_reserve(i)
         );

   --********************************************************
   -- This can be removed later if x_dpr_out is used directly
   --********************************************************
   x_dpr_out := l_dpr_out;
   x_dpr_in  := l_dpr_in;

   if (p_log_level_rec.statement_level) then
      l_dummy_bool := fa_cde_pkg.faprdos(l_dpr_out, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'period loop', 'End', p_log_level_rec => p_log_level_rec);
   end if;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'END', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;
EXCEPTION
   WHEN pro_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'pro_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;
END process_history;

FUNCTION calculate_catchup(p_request_id        number
                         , p_book_type_code    IN VARCHAR2
                         , p_worker_id         IN NUMBER
                         , p_period_rec        IN FA_API_TYPES.period_rec_type
                         , p_imp_period_rec    IN FA_API_TYPES.period_rec_type
                         , p_mrc_sob_type_code IN VARCHAR2
                         , p_calling_fn        IN VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn VARCHAR2(30) := 'calculate_catchup';

   CURSOR c_get_assets IS
SELECT
  imp.asset_id
, imp.impairment_amount
, imp.rowid
FROM   fa_itf_impairments imp
WHERE  imp.book_type_code = p_book_type_code
AND    imp.request_id = p_request_id
AND    imp.period_counter <= p_period_rec.period_counter
AND    imp.worker_id = p_worker_id;

   CURSOR c_get_bst (c_asset_id number) IS
      SELECT PERIOD_COUNTER
           , FISCAL_YEAR
           , PERIOD_NUM
           , CALENDAR_PERIOD_OPEN_DATE
           , CALENDAR_PERIOD_CLOSE_DATE
           , RESET_ADJUSTED_COST_FLAG
           , CHANGE_IN_COST
--           , CHANGE_IN_ADDITIONS_COST
--           , CHANGE_IN_ADJUSTMENTS_COST
--           , CHANGE_IN_RETIREMENTS_COST
--           , CHANGE_IN_GROUP_REC_COST
           , CHANGE_IN_CIP_COST
           , COST
--           , CIP_COST
           , SALVAGE_TYPE
           , PERCENT_SALVAGE_VALUE
           , SALVAGE_VALUE
--           , MEMBER_SALVAGE_VALUE
           , RECOVERABLE_COST
           , DEPRN_LIMIT_TYPE
           , ALLOWED_DEPRN_LIMIT
           , ALLOWED_DEPRN_LIMIT_AMOUNT
--           , MEMBER_DEPRN_LIMIT_AMOUNT
           , ADJUSTED_RECOVERABLE_COST
           , ADJUSTED_COST
           , DEPRECIATE_FLAG
--           , DISABLED_FLAG
           , DATE_PLACED_IN_SERVICE
           , DEPRN_METHOD_CODE
           , LIFE_IN_MONTHS
           , RATE_ADJUSTMENT_FACTOR
           , ADJUSTED_RATE
           , BONUS_RULE
           , ADJUSTED_CAPACITY
           , PRODUCTION_CAPACITY
--           , UNIT_OF_MEASURE
--           , REMAINING_LIFE1
--           , REMAINING_LIFE2
           , FORMULA_FACTOR
--           , UNREVALUED_COST
           , REVAL_AMORTIZATION_BASIS
--           , REVAL_CEILING
           , CEILING_NAME
           , EOFY_ADJ_COST
           , EOFY_FORMULA_FACTOR
           , EOFY_RESERVE
           , EOP_ADJ_COST
--           , EOP_FORMULA_FACTOR
--           , SHORT_FISCAL_YEAR_FLAG
--           , GROUP_ASSET_ID
--           , SUPER_GROUP_ID
--           , OVER_DEPRECIATE_OPTION
--           , FULLY_RSVD_REVALS_COUNTER
           , CAPITALIZED_FLAG
--           , FULLY_RESERVED_FLAG
--           , FULLY_RETIRED_FLAG
--           , LIFE_COMPLETE_FLAG
--           , TERMINAL_GAIN_LOSS_AMOUNT
--           , TERMINAL_GAIN_LOSS_FLAG
           , DEPRN_AMOUNT
           , YTD_DEPRN
           , DEPRN_RESERVE
           , BONUS_DEPRN_AMOUNT
           , BONUS_YTD_DEPRN
           , BONUS_DEPRN_RESERVE
           , BONUS_RATE
           , LTD_PRODUCTION
           , YTD_PRODUCTION
           , PRODUCTION
--n          , REVAL_AMORTIZATION
--n          , REVAL_DEPRN_EXPENSE
           , REVAL_RESERVE
--n          , YTD_REVAL_DEPRN_EXPENSE
--n          , DEPRN_OVERRIDE_FLAG
--n          , SYSTEM_DEPRN_AMOUNT
--n          , SYSTEM_BONUS_DEPRN_AMOUNT
           , YTD_PROCEEDS_OF_SALE
           , LTD_PROCEEDS_OF_SALE
           , YTD_COST_OF_REMOVAL
           , LTD_COST_OF_REMOVAL
--           , DEPRN_ADJUSTMENT_AMOUNT
           , EXPENSE_ADJUSTMENT_AMOUNT
           , UNPLANNED_AMOUNT
           , RESERVE_ADJUSTMENT_AMOUNT
--           , CREATION_DATE
--           , CREATED_BY
--           , LAST_UPDATE_DATE
--           , LAST_UPDATED_BY
--           , LAST_UPDATE_LOGIN
           , CHANGE_IN_EOFY_RESERVE
--           , SWITCH_CODE
--           , POLISH_DEPRN_BASIS
--           , POLISH_ADJ_REC_COST
           , IMPAIRMENT_AMOUNT
           , YTD_IMPAIRMENT
           , IMPAIRMENT_RESERVE
      FROM   fa_books_summary_t
      WHERE  asset_id = c_asset_id
      AND    book_type_code = p_book_type_code
      AND    period_counter >= p_imp_period_rec.period_counter
      AND    request_id = p_request_id
      ORDER BY period_counter;


   t_asset_id                    tab_num15_type;
   t_impairment_amount           tab_num_type;
   t_rowid                       tab_rowid_type;
   t_catchup                     tab_num_type;
   t_adjusted_cost               tab_num_type;
   t_raf                         tab_num_type;
   t_formula_factor              tab_num_type;
   t_eofy_reserve                tab_num_type;


   tbs_transaction_header_id     tab_num15_type;
   tbs_change_in_sal             tab_num_type;
   tbs_change_in_limit           tab_num_type;
   tbs_change_in_retirements_cost tab_num_type;

   l_trans_rec                   FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec               FA_API_TYPES.asset_hdr_rec_type;
   l_asset_fin_rec_old           FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new           FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec             FA_API_TYPES.asset_deprn_rec_type;
   l_asset_type_rec              FA_API_TYPES.asset_type_rec_type;
   l_period_rec                  FA_API_TYPES.period_rec_type;

   l_dpr_in          fa_std_types.dpr_struct;
   l_dpr_out         fa_std_types.dpr_out_struct;
   l_dpr_arr         fa_std_types.dpr_arr_type;

   loc                           binary_integer;
   l_start_pc                    number(15);

   l_running_mode                number := fa_std_types.FA_DPR_NORMAL;

   l_temp_num                    number;

   l_eofy_rec_cost               number := 0;
   l_eop_rec_cost                number := 0;
   l_eofy_sal_val                number := 0;
   l_eop_sal_val                 number := 0;
   l_eofy_ind                    binary_integer;
   l_bs_ind                      binary_integer;
   l_adjusted_ind                binary_integer;

   l_fiscal_year                 number;
   l_period_num                  number;
   l_period_counter              number;

   -- variables for query balance
   l_dpr_row                     FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
   l_qb_running_mode                varchar2(10) := 'STANDARD';
   l_status                      boolean;

   l_dummy_bool                  boolean;

   calc_err EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'BEGIN', to_char(p_request_id)||':'||to_char(p_worker_id));
   end if;

   OPEN c_get_assets;
   FETCH c_get_assets BULK COLLECT INTO t_asset_id
                                      , t_impairment_amount
                                      , t_rowid
   ;
   CLOSE c_get_assets;

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'Records returned from c_get_assets', t_asset_id.count, p_log_level_rec => p_log_level_rec);
   end if;

   FOR j in 1..t_asset_id.count LOOP

      OPEN c_get_bst(t_asset_id(j));
      FETCH c_get_bst BULK COLLECT INTO fa_amort_pvt.t_period_counter
                                      , fa_amort_pvt.t_fiscal_year
                                      , fa_amort_pvt.t_period_num
                                      , fa_amort_pvt.t_calendar_period_open_date
                                      , fa_amort_pvt.t_calendar_period_close_date
                                      , fa_amort_pvt.t_reset_adjusted_cost_flag
                                      , fa_amort_pvt.t_change_in_cost
                                      , fa_amort_pvt.t_change_in_cip_cost
                                      , fa_amort_pvt.t_cost
                                      , fa_amort_pvt.t_salvage_type
                                      , fa_amort_pvt.t_percent_salvage_value
                                      , fa_amort_pvt.t_salvage_value
                                      , fa_amort_pvt.t_recoverable_cost
                                      , fa_amort_pvt.t_deprn_limit_type
                                      , fa_amort_pvt.t_allowed_deprn_limit
                                      , fa_amort_pvt.t_allowed_deprn_limit_amount
                                      , fa_amort_pvt.t_adjusted_recoverable_cost
                                      , fa_amort_pvt.t_adjusted_cost
                                      , fa_amort_pvt.t_depreciate_flag
                                      , fa_amort_pvt.t_date_placed_in_service
                                      , fa_amort_pvt.t_deprn_method_code
                                      , fa_amort_pvt.t_life_in_months
                                      , fa_amort_pvt.t_rate_adjustment_factor
                                      , fa_amort_pvt.t_adjusted_rate
                                      , fa_amort_pvt.t_bonus_rule
                                      , fa_amort_pvt.t_adjusted_capacity
                                      , fa_amort_pvt.t_production_capacity
                                      , fa_amort_pvt.t_formula_factor
                                      , fa_amort_pvt.t_reval_amortization_basis
                                      , fa_amort_pvt.t_ceiling_name
                                      , fa_amort_pvt.t_eofy_adj_cost
                                      , fa_amort_pvt.t_eofy_formula_factor
                                      , fa_amort_pvt.t_eofy_reserve
                                      , fa_amort_pvt.t_eop_adj_cost
                                      , fa_amort_pvt.t_capitalized_flag
                                      , fa_amort_pvt.t_deprn_amount
                                      , fa_amort_pvt.t_ytd_deprn
                                      , fa_amort_pvt.t_deprn_reserve
                                      , fa_amort_pvt.t_bonus_deprn_amount
                                      , fa_amort_pvt.t_bonus_ytd_deprn
                                      , fa_amort_pvt.t_bonus_deprn_reserve
                                      , fa_amort_pvt.t_bonus_rate
                                      , fa_amort_pvt.t_ltd_production
                                      , fa_amort_pvt.t_ytd_production
                                      , fa_amort_pvt.t_production
                                      , fa_amort_pvt.t_reval_reserve
                                      , fa_amort_pvt.t_ytd_proceeds_of_sale
                                      , fa_amort_pvt.t_ltd_proceeds_of_sale
                                      , fa_amort_pvt.t_ytd_cost_of_removal
                                      , fa_amort_pvt.t_ltd_cost_of_removal
                                      , fa_amort_pvt.t_expense_adjustment_amount
                                      , fa_amort_pvt.t_unplanned_amount
                                      , fa_amort_pvt.t_reserve_adjustment_amount
                                      , fa_amort_pvt.t_change_in_eofy_reserve
                                      , fa_amort_pvt.t_impairment_amount
                                      , fa_amort_pvt.t_ytd_impairment
                                      , fa_amort_pvt.t_impairment_reserve
       ;
       CLOSE c_get_bst;


      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'Rec returned from c_get_bst', fa_amort_pvt.t_period_counter.count,  p_log_level_rec => p_log_level_rec);
      end if;

      --
      -- Get reserve entry from fa_adjustments and fa_deprn_summary(b row)
      --

      l_asset_hdr_rec.asset_id           := t_asset_id(j);
      l_asset_hdr_rec.period_of_addition := null;
      l_asset_hdr_rec.book_type_code     := p_book_type_code;
      l_asset_hdr_rec.set_of_books_id    := fa_cache_pkg.fazcbc_record.set_of_books_id;

      l_dpr_in.calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
      l_dpr_in.book := l_asset_hdr_rec.book_type_code;
      l_dpr_in.asset_id := l_asset_hdr_rec.asset_id;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'calling', 'FA_UTIL_PVT.get_asset_fin_rec',  p_log_level_rec => p_log_level_rec);
      end if;

      -- Populate fin rec
      if not FA_UTIL_PVT.get_asset_fin_rec
                 (p_asset_hdr_rec         => l_asset_hdr_rec,
                  px_asset_fin_rec        => l_asset_fin_rec_old,
                  p_transaction_header_id => NULL,
                  p_mrc_sob_type_code     => p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
               raise calc_err;
      end if;

      l_asset_fin_rec_old.cost := fa_amort_pvt.t_cost(1);
      l_asset_fin_rec_old.recoverable_cost := fa_amort_pvt.t_recoverable_cost(1);
      l_asset_fin_rec_old.adjusted_recoverable_cost := fa_amort_pvt.t_adjusted_recoverable_cost(1);
      l_asset_fin_rec_old.adjusted_cost := fa_amort_pvt.t_adjusted_cost(1);
      l_asset_fin_rec_old.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(1);
      l_asset_fin_rec_old.formula_factor := fa_amort_pvt.t_formula_factor(1);
      l_asset_fin_rec_old.eofy_reserve := fa_amort_pvt.t_eofy_reserve(1);
      l_asset_fin_rec_old.reval_amortization_basis:= fa_amort_pvt.t_reval_amortization_basis(1);
      l_asset_fin_rec_old.adjusted_capacity := fa_amort_pvt.t_adjusted_capacity(1);
      l_asset_fin_rec_new := l_asset_fin_rec_old;

      --
      -- Factor impairment amount in
      --
      fa_amort_pvt.t_impairment_amount(1) := fa_amort_pvt.t_impairment_amount(1) + t_impairment_amount(j);
      fa_amort_pvt.t_ytd_impairment(1) := fa_amort_pvt.t_ytd_impairment(1) + t_impairment_amount(j);
      fa_amort_pvt.t_impairment_reserve(1) := fa_amort_pvt.t_impairment_reserve(1) + t_impairment_amount(j);

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'period loop', 'Begin', p_log_level_rec => p_log_level_rec);
      end if;

      --
      -- Calculate periodic depreciation amounts
      --
      l_bs_ind := 2;

      FOR i in 2..fa_amort_pvt.t_period_counter.count LOOP

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 't_period_counter', fa_amort_pvt.t_period_counter(i));
            fa_debug_pkg.add(l_calling_fn, 'imp period_counter', p_imp_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
         end if;

         l_trans_rec.transaction_key := 'IM';

         if (l_bs_ind <= i) then
            fa_amort_pvt.t_ytd_impairment(i) := fa_amort_pvt.t_ytd_impairment(i-1) +
                                                fa_amort_pvt.t_impairment_amount(i);
            fa_amort_pvt.t_impairment_reserve(i) := fa_amort_pvt.t_impairment_reserve(i-1) +
                                                    fa_amort_pvt.t_impairment_amount(i);

            fa_amort_pvt.t_deprn_amount(i)   := nvl(fa_amort_pvt.t_expense_adjustment_amount(i), 0);

            if (i = 1) then
               fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_deprn_amount(i);
               fa_amort_pvt.t_deprn_reserve(i)  := nvl(fa_amort_pvt.t_deprn_amount(i), 0) +
                                                             nvl(fa_amort_pvt.t_reserve_adjustment_amount(i), 0);
               fa_amort_pvt.t_eofy_reserve (i)  := nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
            else
               fa_amort_pvt.t_deprn_reserve(i)  := fa_amort_pvt.t_deprn_reserve(i-1) +
                                                   nvl(fa_amort_pvt.t_deprn_amount(i), 0) +
                                                   nvl(fa_amort_pvt.t_reserve_adjustment_amount(i), 0);
               if (i > 1) then
                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_deprn_amount(i);
                     fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_deprn_reserve(i - 1) +
                                                              nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  else
                     fa_amort_pvt.t_ytd_deprn(i)      := fa_amort_pvt.t_ytd_deprn(i-1) +
                                                         fa_amort_pvt.t_deprn_amount(i);
                     fa_amort_pvt.t_eofy_reserve (i)       := fa_amort_pvt.t_eofy_reserve(i - 1) +
                                                              nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  end if;
               else
                  --
                  -- If user entered reserve exists, code below may need to be modified
                  --
                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     fa_amort_pvt.t_eofy_reserve (i)       := 0;
                  else
                     fa_amort_pvt.t_eofy_reserve (i)       := 0;
                  end if;
               end if;

            end if;

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_deprn_reserve', fa_amort_pvt.t_deprn_reserve(i));
         end if;


         --
         -- Want to populate fa_amort_pvt tables but not necessary to calculate deprn basis
         -- nor periodic depreciations because impairment amount has to be determined first
         -- for periods after impairment transactions
         --
            if (i = 1) then
               l_asset_fin_rec_old.cost := 0;
               l_asset_fin_rec_old.recoverable_cost := 0;
               l_asset_fin_rec_old.adjusted_recoverable_cost := 0;
               l_asset_fin_rec_old.adjusted_cost := 0;
               l_asset_fin_rec_old.rate_adjustment_factor := 0;
               l_asset_fin_rec_old.formula_factor := 0;
               l_asset_fin_rec_old.eofy_reserve := 0;
               l_asset_fin_rec_old.reval_amortization_basis:= 0;
               l_asset_fin_rec_old.adjusted_capacity := 0;
               l_asset_fin_rec_new := l_asset_fin_rec_old;
            end if;

            l_asset_fin_rec_old := l_asset_fin_rec_new;
            l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);
            l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_asset_fin_rec_new.adjusted_recoverable_cost := fa_amort_pvt.t_adjusted_recoverable_cost(i);
            l_asset_fin_rec_new.adjusted_cost := fa_amort_pvt.t_adjusted_cost(i);
            l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Start populating', 'l_dpr_in', p_log_level_rec => p_log_level_rec);
            end if;

            l_dpr_in.adj_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_dpr_in.salvage_value := fa_amort_pvt.t_salvage_value(i);
            l_dpr_in.rec_cost := fa_amort_pvt.t_recoverable_cost(i);
            l_dpr_in.adj_rec_cost := fa_amort_pvt.t_adjusted_recoverable_cost(i);
            l_dpr_in.reval_amo_basis := fa_amort_pvt.t_reval_amortization_basis(i);
            l_dpr_in.adj_rate := fa_amort_pvt.t_adjusted_rate(i);
            l_dpr_in.rate_adj_factor := 1;
            l_dpr_in.capacity := fa_amort_pvt.t_production_capacity(i);
            l_dpr_in.adj_capacity := fa_amort_pvt.t_adjusted_capacity(i);
            l_dpr_in.ltd_prod := 0;
            l_dpr_in.ytd_deprn := 0;    -- This needs to be 0 for the 1st faxcde call
            l_dpr_in.deprn_rsv := 0;
            l_dpr_in.reval_rsv := fa_amort_pvt.t_reval_reserve(i);
            l_dpr_in.bonus_deprn_exp := fa_amort_pvt.t_bonus_deprn_amount(i);
            l_dpr_in.bonus_ytd_deprn := fa_amort_pvt.t_bonus_ytd_deprn(i);
            l_dpr_in.bonus_deprn_rsv := fa_amort_pvt.t_bonus_deprn_reserve(i);
            l_dpr_in.impairment_exp := fa_amort_pvt.t_impairment_amount(i);
            l_dpr_in.ytd_impairment := fa_amort_pvt.t_ytd_impairment(i);
            l_dpr_in.impairment_rsv := fa_amort_pvt.t_impairment_reserve(i);
            l_dpr_in.ceil_name := fa_amort_pvt.t_ceiling_name(i);
            l_dpr_in.bonus_rule := fa_amort_pvt.t_bonus_rule(i);
            l_dpr_in.method_code := fa_amort_pvt.t_deprn_method_code(i);
            l_dpr_in.life := fa_amort_pvt.t_life_in_months(i);
            l_dpr_in.jdate_in_service :=
                      to_number(to_char(fa_amort_pvt.t_date_placed_in_service(i), 'J'));
            l_dpr_in.deprn_start_jdate := to_number(to_char(l_asset_fin_rec_old.deprn_start_date, 'J'));
            l_dpr_in.prorate_jdate := to_number(to_char(l_asset_fin_rec_old.prorate_date, 'J'));

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
            end if;

            if (not fa_cache_pkg.fazccmt(
                       fa_amort_pvt.t_deprn_method_code(i),
                       fa_amort_pvt.t_life_in_months(i),
                       p_log_level_rec)) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling', 'fa_cache_pkg.fazccmt', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_err;
            end if;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  end if;

                  -- bug5894464: removed if (i = 1) condition
                  if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                             fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                             l_dpr_in.prorate_jdate,
                                             g_temp_number,
                                             l_dpr_in.y_begin,
                                             g_temp_integer, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                         'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                         fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                         fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);
                        fa_debug_pkg.add(l_calling_fn, 'l_dpr_in.prorate_jdate',
                                         l_dpr_in.prorate_jdate, p_log_level_rec => p_log_level_rec);

                     end if;

                     raise calc_err;
                  end if;
                  -- bug5894464


               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Before Calling', 'faxcde for hype reserve', p_log_level_rec => p_log_level_rec);
               end if;

               -- Skip faxcde call to find hyp rsv if method type is not (FLAT or PROD) and basis is COST
               if (((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') not in(fa_std_types.FAD_RSR_FLAT,
                                                                                   fa_std_types.FAD_RSR_PROD)) and
                    (nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,' ') = fa_std_types.FAD_DBR_COST))) then

                  -- bug5894464
                  l_dpr_in.p_cl_begin := 1;

                  if (fa_amort_pvt.t_period_num(i) = 1) then
                     l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i) - 1;
                     l_dpr_in.p_cl_end := fa_cache_pkg.fazcct_record.number_per_fiscal_year;
                  else
                     l_dpr_in.y_end := fa_amort_pvt.t_fiscal_year(i);
                     l_dpr_in.p_cl_end := fa_amort_pvt.t_period_num(i) - 1;
                  end if;
                  -- bug5894464

                  --+++++++ Call Depreciation engine for rate adjustment factor +++++++
                  if not FA_CDE_PKG.faxcde(l_dpr_in,
                                           l_dpr_arr,
                                           l_dpr_out,
                                           l_running_mode, p_log_level_rec => p_log_level_rec) then
                     if (p_log_level_rec.statement_level) then
                        fa_debug_pkg.add(l_calling_fn, 'Error calling',
                             'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                     end if;

                     raise calc_err;
                  end if;
               end if; -- (((nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') not in(fa_std_types.FAD_RSR_FLAT,

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'setting', 'deprn_rec for basis rule', p_log_level_rec => p_log_level_rec);
               end if;

               l_asset_deprn_rec.set_of_books_id          := l_asset_hdr_rec.set_of_books_id;
               l_asset_deprn_rec.deprn_amount             := fa_amort_pvt.t_deprn_amount(i);
               l_asset_deprn_rec.ytd_deprn                := fa_amort_pvt.t_ytd_deprn(i);

               l_asset_deprn_rec.deprn_reserve            := fa_amort_pvt.t_deprn_reserve(i);

               l_asset_deprn_rec.prior_fy_expense         := 0;  -- setting 0 for now.  not sure when this is required
               l_asset_deprn_rec.bonus_deprn_amount       := fa_amort_pvt.t_bonus_deprn_amount(i);
               l_asset_deprn_rec.bonus_ytd_deprn          := fa_amort_pvt.t_bonus_ytd_deprn(i);
               l_asset_deprn_rec.bonus_deprn_reserve      := fa_amort_pvt.t_bonus_deprn_reserve(i);
               l_asset_deprn_rec.prior_fy_bonus_expense   := 0; -- setting 0 for now.  not sure when this is required
               l_asset_deprn_rec.reval_amortization       := 0; -- setting 0 for now.  not sure when this is required
               l_asset_deprn_rec.reval_amortization_basis := fa_amort_pvt.t_reval_amortization_basis(i);
               l_asset_deprn_rec.reval_deprn_expense      := 0; -- setting 0 for now.  not sure when this is required
               l_asset_deprn_rec.reval_ytd_deprn          := 0; -- setting 0 for now.  not sure when this is required
               l_asset_deprn_rec.reval_deprn_reserve      := fa_amort_pvt.t_reval_reserve(i);
               l_asset_deprn_rec.production               := fa_amort_pvt.t_production(i);
               l_asset_deprn_rec.ytd_production           := fa_amort_pvt.t_ytd_production(i);
               l_asset_deprn_rec.ltd_production           := fa_amort_pvt.t_ltd_production(i);
               l_asset_deprn_rec.impairment_amount        := fa_amort_pvt.t_impairment_amount(i);
               l_asset_deprn_rec.ytd_impairment           := fa_amort_pvt.t_ytd_impairment(i);

               l_asset_deprn_rec.impairment_reserve           := fa_amort_pvt.t_impairment_reserve(i);

               if (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'Y')  = 'Y') and
                  (nvl(fa_cache_pkg.fazccmt_record.rate_source_rule, ' ') = fa_std_types.FAD_RSR_FLAT) and
                  (nvl(fa_cache_pkg.fazccmt_record.deprn_basis_rule,' ') = fa_std_types.FAD_DBR_COST) then
                  l_asset_deprn_rec.impairment_reserve := fa_amort_pvt.t_impairment_reserve(i) + fa_amort_pvt.t_deprn_reserve(1);
               end if;



               l_period_rec.period_counter := fa_amort_pvt.t_period_counter(i);
               l_period_rec.period_num := fa_amort_pvt.t_period_num(i);
               l_period_rec.fiscal_year := fa_amort_pvt.t_fiscal_year(i);

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'fa_amort_pvt.t_impairment_amount(i)', fa_amort_pvt.t_impairment_amount(i));
                  fa_debug_pkg.add(l_calling_fn, 'rule_name', fa_cache_pkg.fazcdbr_record.rule_name, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'deprn_basis_rule', fa_cache_pkg.fazccmt_record.deprn_basis_rule, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'use_rsv_after_imp_flag', fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, p_log_level_rec => p_log_level_rec);
               end if;

               if (i > 1) and (fa_amort_pvt.t_impairment_amount(i-1) <> 0) and
                  (fa_cache_pkg.fazcdbr_record.rule_name = 'FLAT RATE EXTENSION') and
                  (fa_cache_pkg.fazccmt_record.deprn_basis_rule = fa_std_types.FAD_DBR_NBV) and
                  (nvl(fa_cache_pkg.fazcdrd_record.use_rsv_after_imp_flag, 'N') = 'Y') then

                  l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_deprn_reserve(i-1) +
                                                      nvl(fa_amort_pvt.t_change_in_eofy_reserve(i), 0);
                  fa_amort_pvt.t_eofy_reserve(i-1) := l_asset_fin_rec_new.eofy_reserve;

               end if;



               if (not FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS
                                      (p_event_type             => 'AMORT_ADJ',
                                       p_asset_fin_rec_new      => l_asset_fin_rec_new,
                                       p_asset_fin_rec_old      => l_asset_fin_rec_old,
                                       p_asset_hdr_rec          => l_asset_hdr_rec,
                                       p_asset_type_rec         => l_asset_type_rec,
                                       p_asset_deprn_rec        => l_asset_deprn_rec,
                                       p_trans_rec              => l_trans_rec,
                                       p_trans_rec_adj          => l_trans_rec,
                                       p_period_rec             => l_period_rec,
                                       p_current_total_rsv      => l_asset_deprn_rec.deprn_reserve,
                                       p_current_rsv            => l_asset_deprn_rec.deprn_reserve -
                                                                   nvl(l_asset_deprn_rec.bonus_deprn_reserve, 0) -
                                                                   nvl(l_asset_deprn_rec.impairment_reserve, 0),
                                       p_current_total_ytd      => l_asset_deprn_rec.ytd_deprn,
                                       p_hyp_basis              => l_asset_fin_rec_new.adjusted_cost,
                                       p_hyp_total_rsv          => l_dpr_out.new_deprn_rsv,
                                       p_hyp_rsv                => l_dpr_out.new_deprn_rsv -
                                                                   nvl(l_dpr_out.new_bonus_deprn_rsv, 0) -
                                                                   nvl(l_dpr_out.new_impairment_rsv,0),
                                       p_eofy_recoverable_cost  => l_eofy_rec_cost,
                                       p_eop_recoverable_cost   => l_eop_rec_cost,
                                       p_eofy_salvage_value     => l_eofy_sal_val,
                                       p_eop_salvage_value      => l_eop_sal_val,
                                       p_mrc_sob_type_code      => p_mrc_sob_type_code,
                                       p_used_by_adjustment     => 'ADJUSTMENT',
                                       px_new_adjusted_cost     => fa_amort_pvt.t_adjusted_cost(i),
                                       px_new_raf               => fa_amort_pvt.t_rate_adjustment_factor(i),
                                       px_new_formula_factor    => fa_amort_pvt.t_formula_factor(i),
                                       p_log_level_rec     => p_log_level_rec)) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                      'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Returned values from ',
                                   'FA_CALC_DEPRN_BASIS1_PKG.CALL_DEPRN_BASIS', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'adjusted_cost',
                                   fa_amort_pvt.t_adjusted_cost(i));
                  fa_debug_pkg.add(l_calling_fn, 'rate_adjustment_factor',
                                   fa_amort_pvt.t_rate_adjustment_factor(i));
                  fa_debug_pkg.add(l_calling_fn, 'formula_factor',
                                   fa_amort_pvt.t_formula_factor(i));
                  fa_debug_pkg.add(l_calling_fn, '====== ', '==============================', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'Calling', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               l_adjusted_ind := 0;


               if (fa_amort_pvt.t_period_counter(i) <> p_period_rec.period_counter) then




               FOR j in (i + 1)..(fa_amort_pvt.t_period_counter.count) LOOP
                  l_adjusted_ind := l_adjusted_ind + 1;

                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 't_reset_adjusted_cost_flag('||to_char(j)||')',
                                                    fa_amort_pvt.t_reset_adjusted_cost_flag(j));
                     fa_debug_pkg.add(l_calling_fn, 't_period_counter('||to_char(j)||')',
                                                    fa_amort_pvt.t_period_counter(j));
                     fa_debug_pkg.add(l_calling_fn, 'p_imp_period_rec.period_counter', p_imp_period_rec.period_counter, p_log_level_rec => p_log_level_rec);
                  end if;

                  if ((fa_amort_pvt.t_reset_adjusted_cost_flag(j) = 'Y') or
                      (j = (fa_amort_pvt.t_period_counter.count))) then

                     l_fiscal_year := fa_amort_pvt.t_fiscal_year(j-1);
                     l_period_num := fa_amort_pvt.t_period_num(j-1);
                     l_period_counter := fa_amort_pvt.t_period_counter(j-1);
                     EXIT;
                  end if;

               END LOOP;

               --
               -- Prepare Running Depreciation
               --
               l_dpr_in.y_begin := fa_amort_pvt.t_fiscal_year(i);
               l_dpr_in.p_cl_begin := fa_amort_pvt.t_period_num(i);
               l_dpr_in.y_end := l_fiscal_year;
               l_dpr_in.p_cl_end := l_period_num;
               l_dpr_in.ytd_deprn := fa_amort_pvt.t_ytd_deprn(i);
               l_dpr_in.deprn_rsv := fa_amort_pvt.t_deprn_reserve(i);
               l_dpr_in.adj_cost := fa_amort_pvt.t_adjusted_cost(i);
               l_dpr_in.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
               l_dpr_in.rate_adj_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
               l_dpr_in.formula_factor := fa_amort_pvt.t_formula_factor(i);


               --
               -- Calculate periodic depreciation
               --
               if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode,
                                        l_bs_ind, p_log_level_rec => p_log_level_rec) then
                  if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add(l_calling_fn, 'Error calling', 'FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
                  end if;

                  raise calc_err;
               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'After Calling', 'faxcde', p_log_level_rec => p_log_level_rec);
               end if;

               if (l_asset_fin_rec_new.adjusted_cost <> 0) or
                  (l_dpr_out.new_adj_cost <> 0) then

                  l_asset_fin_rec_new.reval_amortization_basis := l_dpr_out.new_reval_amo_basis;
                  l_asset_fin_rec_new.adjusted_cost := l_dpr_out.new_adj_cost;
                  l_asset_fin_rec_new.cost := fa_amort_pvt.t_cost(i);
                  l_asset_fin_rec_new.salvage_value := fa_amort_pvt.t_salvage_value(i);
                  l_asset_fin_rec_new.recoverable_cost := fa_amort_pvt.t_recoverable_cost(i);
                  l_asset_fin_rec_new.deprn_method_code := fa_amort_pvt.t_deprn_method_code(i);
                  l_asset_fin_rec_new.life_in_months := fa_amort_pvt.t_life_in_months(i);
                  l_asset_fin_rec_new.depreciate_flag := fa_amort_pvt.t_depreciate_flag(i);
                  l_asset_fin_rec_new.eofy_reserve := fa_amort_pvt.t_eofy_reserve(i);
                  l_asset_fin_rec_new.rate_adjustment_factor := fa_amort_pvt.t_rate_adjustment_factor(i);
                  l_asset_fin_rec_new.formula_factor := fa_amort_pvt.t_formula_factor(i);

               end if;

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Finish copying to ', 'fin_rec_new', p_log_level_rec => p_log_level_rec);
               end if;

               l_eop_rec_cost := fa_amort_pvt.t_recoverable_cost(i);
               l_eop_sal_val  := fa_amort_pvt.t_salvage_value(i);

               l_eofy_ind := i - fa_amort_pvt.t_period_num(i);

               if (l_eofy_ind > 0) then
                  l_eofy_rec_cost := fa_amort_pvt.t_recoverable_cost(l_eofy_ind);
                  l_eofy_sal_val  := fa_amort_pvt.t_salvage_value(l_eofy_ind);
               end if;

               l_bs_ind := l_bs_ind + l_adjusted_ind;

            else
               -- This is current period so just add up expense and reserve entries
               -- from this period to deprn reserve.

               fa_amort_pvt.t_deprn_amount(i)  := fa_amort_pvt.t_expense_adjustment_amount(i);

               if fa_amort_pvt.t_period_num(i) = 1 then
                  fa_amort_pvt.t_ytd_deprn(i) := fa_amort_pvt.t_deprn_amount(i);
               else
                  fa_amort_pvt.t_ytd_deprn(i) := fa_amort_pvt.t_ytd_deprn(i-1) +
                                                 fa_amort_pvt.t_deprn_amount(i);

               end if;

               fa_amort_pvt.t_deprn_reserve(i) := fa_amort_pvt.t_deprn_reserve(i-1) +
                                               fa_amort_pvt.t_deprn_amount(i) +
                                               fa_amort_pvt.t_reserve_adjustment_amount(i);

            end if; -- (fa_amort_pvt.t_period_counter <> p_period_rec.period_counter)

         end if; -- l_bs_ind <= i then

      END LOOP; -- i in 2..fa_amort_pvt.t_period_counter.count

      --
      -- Find current reserve
      --
      l_dpr_row := null;
      l_dpr_row.asset_id             := t_asset_id(j);
      l_dpr_row.book                 := p_book_type_code;
      l_dpr_row.period_ctr           := p_period_rec.period_counter;
      l_dpr_row.dist_id              := 0;
      l_dpr_row.mrc_sob_type_code    := p_mrc_sob_type_code;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'Calling', 'query_balances_int', p_log_level_rec => p_log_level_rec);
      end if;

      fa_query_balances_pkg.query_balances_int(
                                   X_DPR_ROW               => l_dpr_row,
                                   X_RUN_MODE              => l_qb_running_mode,
                                   X_DEBUG                 => FALSE,
                                   X_SUCCESS               => l_status,
                                   X_CALLING_FN            => l_calling_fn,
                                   X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

      if (NOT l_status) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'ERROR',
                                   'Calling fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
               end if;

               raise calc_err;
      end if;


      --
      -- Find catch up by current reserve - new reserve
      --
      t_catchup(j) := fa_amort_pvt.t_deprn_reserve(fa_amort_pvt.t_period_counter.count) - l_dpr_row.deprn_rsv;

      --
      -- Store adjusted_cost, rate_adjustment_factor, and formula_factor for later use
      --
      t_adjusted_cost(j) := fa_amort_pvt.t_adjusted_cost(fa_amort_pvt.t_period_counter.count);
      t_raf(j) := fa_amort_pvt.t_rate_adjustment_factor(fa_amort_pvt.t_period_counter.count);
      t_formula_factor(j) := fa_amort_pvt.t_formula_factor(fa_amort_pvt.t_period_counter.count);
      t_eofy_reserve(j) := fa_amort_pvt.t_eofy_reserve(fa_amort_pvt.t_period_counter.count);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'current reserve', l_dpr_row.deprn_rsv, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'catchup', t_catchup(j));
      end if;

   END LOOP; -- j in 1..t_asset_id.count

   --
   -- Store catchup amount
   --
   FORALL k in 1..t_asset_id.count
      UPDATE FA_ITF_IMPAIRMENTS
      SET    DEPRN_ADJUSTMENT_AMOUNT = t_catchup(k)
           , ADJUSTED_COST           = t_adjusted_cost(k)
           , RATE_ADJUSTMENT_FACTOR  = t_raf(k)
           , FORMULA_FACTOR          = t_formula_factor(k)
           , EOFY_RESERVE            = t_eofy_reserve(k)
      WHERE  ROWID                   = t_rowid(k);

   if (p_log_level_rec.statement_level) then
      l_dummy_bool := fa_cde_pkg.faprdos(l_dpr_out, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'period loop', 'End', p_log_level_rec => p_log_level_rec);
   end if;


   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,'END', 'END', p_log_level_rec => p_log_level_rec);
   end if;

   return true;
EXCEPTION
   WHEN calc_err THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'pro_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;

   WHEN OTHERS THEN

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn,'EXCEPTION', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      end if;

      return false;
END calculate_catchup;


END FA_IMPAIRMENT_PREV_PVT;

/
