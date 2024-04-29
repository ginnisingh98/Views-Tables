--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_RET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_RET_PKG" AS
/* $Header: fagretb.pls 120.13.12010000.3 2009/07/19 13:57:59 glchen ship $*/


-- Bug 5525968: Added following function
function faggin(ret in out nocopy FA_RET_TYPES.ret_struct,
                    bk in out nocopy FA_RET_TYPES.book_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

      faggin_err          exception;
      h_depreciate_lastyr integer;
      h_lifemonths        number(4);
      h_capitalize        integer;
      h_depreciate        integer;
      h_fully_reserved    integer;
      h_itc_used          number;
      h_period_num        integer;
      h_rate_source_rule  integer;
      h_deprn_basis_rule  integer;
      h_book_class        integer;
      h_wip_asset         integer;
      h_depr_first_year_ret       integer;
      h_cur_units         number(15);
      h_asset_id          number(15);
      h_retirement_id     number(15);
      h_cpd_fiscal_year   number(4);
      h_ret_fiscalyr      number(15);
      h_method_code       varchar2(12);
      h_jdis              number;
      h_prorate_jdate     number;
      h_deprn_start_jdate number;
      h_raf               number;
      h_adj_rate          number;
      h_adjusted_cost     number;
      h_current_cost      number;
      h_recoverable_cost  number;
      h_salvage_value     number;
      h_itc_amount        number;
      h_ret_p_conv        varchar2(15);
      h_book              varchar2(30);
      h_dis_book          varchar2(30);
      h_prorate_date      date;
      h_deprn_start_date  date;
      h_date_in_srv       date;
      h_p_cal             varchar2(15);
      h_deprn_cal         varchar2(15);
      h_ret_prorate_date  date;
      h_initial_date      date;
      h_date_retired      date;
      h_ceiling_name      varchar2(30);
      h_bonus_rule        varchar2(30);
      h_dwacq             integer;
      h_same_fy           integer;
      h_reval_amort_basis number;
      h_unrevalued_cost   number;
      h_adj_capacity      number;
      h_capacity          number;
      h_fiscal_year_name  varchar2(30);
      h_deprn_reserve     number;
      h_adj_rec_cost      number;
      h_annual_deprn_rounding_flag integer; -- NULL->0, 'ADD'->1, 'ADJ'->2
                                            -- 'RET'->3, 'REV'->4, 'TRF'->5
                                            -- 'RES' ->6, Others->-1
      h_short_fiscal_year_flag varchar2(3);
      h_conversion_date        date;
      h_orig_deprn_start_date  date;
      h_old_adj_cost           number;
      h_formula_factor         number;
      h_allowed_deprn_limit_amount number;
      -- +++++ Group Asset related information +++++
      h_group_asset_id              FA_BOOKS.group_asset_id%type;
      h_recognize_gain_loss         FA_BOOKS.RECOGNIZE_GAIN_LOSS%TYPE;
      h_recapture_reserve_flag      FA_BOOKS.RECAPTURE_RESERVE_FLAG%TYPE;
      h_limit_proceeds_flag         FA_BOOKS.LIMIT_PROCEEDS_FLAG%TYPE;
      h_terminal_gain_loss          FA_BOOKS.TERMINAL_GAIN_LOSS%TYPE;
      h_tracking_method             FA_BOOKS.TRACKING_METHOD%TYPE;
      h_exclude_fully_rsv_flag      FA_BOOKS.EXCLUDE_FULLY_RSV_FLAG%TYPE;
      h_excess_allocation_option    FA_BOOKS.EXCESS_ALLOCATION_OPTION%TYPE;
      h_depreciation_option         FA_BOOKS.DEPRECIATION_OPTION%TYPE;
      h_member_rollup_flag          FA_BOOKS.MEMBER_ROLLUP_FLAG%TYPE;
      h_ltd_proceeds                FA_BOOKS.LTD_PROCEEDS%TYPE;
      h_allocate_to_fully_rsv_flag  FA_BOOKS.ALLOCATE_TO_FULLY_RSV_FLAG%TYPE;
      h_allocate_to_fully_ret_flag  FA_BOOKS.ALLOCATE_TO_FULLY_RET_FLAG%TYPE;
      h_eofy_reserve                FA_BOOKS.EOFY_RESERVE%TYPE;
      h_cip_cost                    FA_BOOKS.CIP_COST%TYPE;
      h_ltd_cost_of_removal         FA_BOOKS.LTD_COST_OF_REMOVAL%TYPE;
      h_prior_eofy_reserve          FA_BOOKS.PRIOR_EOFY_RESERVE%TYPE;
      h_eop_adj_cost                FA_BOOKS.EOP_ADJ_COST%TYPE;
      h_eop_formula_factor          FA_BOOKS.EOP_FORMULA_FACTOR%TYPE;
      h_exclude_proceeds_from_basis FA_BOOKS.EXCLUDE_PROCEEDS_FROM_BASIS%TYPE;
      h_retirement_deprn_option     FA_BOOKS.RETIREMENT_DEPRN_OPTION%TYPE;
      h_terminal_gain_loss_amount   FA_BOOKS.terminal_gain_loss_amount%type;
      h_pc_fully_reserved           number;
      --Bug#6920756
      --h_fully_extended              FA_BOOKS.EXTENDED_DEPRN_FLAG%Type; -- bug 6913897
      --h_extended_deprn_flag         NUMBER(1); -- bug 6913897
      h_fully_extended              integer;
      h_pc_fully_extended           number;
      h_extended_flag               integer;

      l_calling_fn        varchar2(40) := 'fa_gainloss_ret_pkg.faggin';

      BEGIN <<FAGGIN>>

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 1', '', p_log_level_rec => p_log_level_rec); end if;
       h_adj_capacity := 0;
       h_capacity := 0;
       h_unrevalued_cost := 0;
       h_reval_amort_basis := 0;
       h_raf := 0;
       h_adj_rate := 0;
       h_adjusted_cost := 0;
       h_current_cost := 0;
       h_recoverable_cost := 0;
       h_salvage_value := 0;
       h_itc_amount := 0;
       h_adj_rec_cost := 0;
       h_old_adj_cost := 0;
       h_formula_factor := 0;

       h_asset_id := ret.asset_id;
       h_retirement_id := ret.retirement_id;

       h_date_retired := ret.date_retired;
       h_book := ret.book;
       h_ret_p_conv := ret.prorate_convention;
       h_dwacq := 0;


       if (ret.mrc_sob_type_code <> 'R') then

          SELECT
                decode(m.depreciate_lastyear_flag,'YES',1,0),
                nvl(book_grp.life_in_months,0),
                decode(book_grp.capitalize_flag, 'YES', 1, 0),
                decode(book_grp.depreciate_flag, 'YES', 1, 0),
                decode(book_grp.period_counter_fully_reserved, null, 0, 1),
                nvl(book_grp.itc_amount_id, 0),
                ah.units,
                bc.current_fiscal_year,
                bc.distribution_source_book,
                book_grp.rate_adjustment_factor,
                nvl(book_grp.adjusted_rate,0),
                book_grp.adjusted_cost,
                book_grp.cost,
                book_grp.recoverable_cost,
                book_grp.itc_amount,
                nvl(book_grp.salvage_value,0),
                trunc(book_grp.prorate_date),
                to_number(to_char(book_grp.prorate_date, 'J')),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                      trunc(book_grp.deprn_start_date), trunc(book_grp.prorate_date)),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                       to_number(to_char(book_grp.deprn_start_date, 'J')),
                       to_number(to_char(book_grp.prorate_date, 'J'))),
                trunc(book_grp.date_placed_in_service),
                to_number(to_char(book_grp.date_placed_in_service, 'J')),
                bc.prorate_calendar,
                m.method_code,
                decode(bc.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                conv.prorate_date,
                trunc(bc.initial_date),
                bc.deprn_calendar,
                nvl(book_grp.ceiling_name, null),
                nvl(book_grp.bonus_rule, null),
                decode(m.rate_source_rule, 'CALCULATED', 1, 'TABLE', 2,
                       'FLAT', 3),
                decode(m.deprn_basis_rule, 'COST', 1, 'NBV', 2),
                decode(bc.book_class, 'TAX', 1, 0),
                decode(ah.asset_type, 'CIP', 1, 0),
                decode(ctype.depr_when_acquired_flag,'YES',1,0),
                nvl(book_grp.reval_amortization_basis,0),
                book_grp.unrevalued_cost,
                nvl(book_grp.adjusted_capacity,0),
                nvl(book_grp.production_capacity,0),
                bc.fiscal_year_name,
                nvl (book_grp.adjusted_recoverable_cost, book_grp.recoverable_cost),
                decode(book_grp.annual_deprn_rounding_flag, NULL, 0, 'ADD', 1,
                       'ADJ', 2, 'RET', 3, 'REV', 4, 'TFR', 5,'RES', 6, 'OVE', 7, -1),
                nvl(book_grp.short_fiscal_year_flag, 'NO'),
                book_grp.conversion_date,
                book_grp.original_deprn_start_date,
                nvl(book_grp.old_adjusted_cost, 1),
                nvl(book_grp.formula_factor, 1),
                book_grp.allowed_deprn_limit_amount,
                book_grp.group_asset_id,
                book_grp.recognize_gain_loss,
                book_grp.recapture_reserve_flag,
                book_grp.limit_proceeds_flag,
                book_grp.terminal_gain_loss,
                book_grp.tracking_method,
                book_grp.exclude_fully_rsv_flag,
                book_grp.excess_allocation_option,
                book_grp.depreciation_option,
                book_grp.member_rollup_flag,
                book_grp.ltd_proceeds,
                book_grp.allocate_to_fully_rsv_flag,
                book_grp.allocate_to_fully_ret_flag,
                book_grp.eofy_reserve,
                book_grp.cip_cost,
                book_grp.ltd_cost_of_removal,
                book_grp.prior_eofy_reserve,
                book_grp.eop_adj_cost,
                book_grp.eop_formula_factor,
                book_grp.exclude_proceeds_from_basis,
                book_grp.retirement_deprn_option,
                book_grp.terminal_gain_loss_amount,
                book_grp.period_counter_fully_reserved,
                --Bug# 6920756
                --book_grp.EXTENDED_DEPRN_FLAG,  -- bug 6913897
                --decode(book_grp.PERIOD_COUNTER_FULLY_EXTENDED, null, 0, 1) -- bug 6913897
                decode(book_grp.period_counter_fully_extended, null, 0, 1),
                book_grp.period_counter_fully_extended,
                decode(book_grp.extended_deprn_flag,'Y', 1, 0)
          INTO
                h_depreciate_lastyr,
                h_lifemonths,
                h_capitalize,
                h_depreciate,
                h_fully_reserved,
                h_itc_used,
                h_cur_units,
                h_cpd_fiscal_year,
                h_dis_book,
                h_raf,
                h_adj_rate,
                h_adjusted_cost,
                h_current_cost,
                h_recoverable_cost,
                h_itc_amount,
                h_salvage_value,
                h_prorate_date,
                h_prorate_jdate,
                h_deprn_start_date,
                h_deprn_start_jdate,
                h_date_in_srv,
                h_jdis,
                h_p_cal,
                h_method_code,
                h_depr_first_year_ret,
                h_ret_prorate_date,
                h_initial_date,
                h_deprn_cal,
                h_ceiling_name,
                h_bonus_rule,
                h_rate_source_rule,
                h_deprn_basis_rule,
                h_book_class,
                h_wip_asset,
                h_dwacq,
                h_reval_amort_basis,
                h_unrevalued_cost,
                h_adj_capacity,
                h_capacity,
                h_fiscal_year_name,
                h_adj_rec_cost,
                h_annual_deprn_rounding_flag,
                h_short_fiscal_year_flag,
                h_conversion_date,
                h_orig_deprn_start_date,
                h_old_adj_cost,
                h_formula_factor,
                h_allowed_deprn_limit_amount,
                h_group_asset_id,
                h_recognize_gain_loss,
                h_recapture_reserve_flag,
                h_limit_proceeds_flag,
                h_terminal_gain_loss,
                h_tracking_method,
                h_exclude_fully_rsv_flag,
                h_excess_allocation_option,
                h_depreciation_option,
                h_member_rollup_flag,
                h_ltd_proceeds,
                h_allocate_to_fully_rsv_flag,
                h_allocate_to_fully_ret_flag,
                h_eofy_reserve,
                h_cip_cost,
                h_ltd_cost_of_removal,
                h_prior_eofy_reserve,
                h_eop_adj_cost,
                h_eop_formula_factor,
                h_exclude_proceeds_from_basis,
                h_retirement_deprn_option,
                h_terminal_gain_loss_amount,
                h_pc_fully_reserved,
                --Bug# 6920756
                --h_extended_deprn_flag,
                h_fully_extended,
                h_pc_fully_extended,
                h_extended_flag
          FROM
                fa_books                book,
                fa_books                book_grp,
                fa_methods              m,
                fa_conventions          conv,
                fa_convention_types     ctype,
                fa_book_controls        bc,
                fa_asset_history        ah
          WHERE
                book.retirement_id = h_retirement_id
          AND   book.asset_id = h_asset_id
          AND   book.book_type_code = h_book
          AND   book_grp.transaction_header_id_out is null
          AND   book_grp.asset_id = book.group_asset_id
          AND   book_grp.book_type_code = h_book
          AND   book_grp.deprn_method_code = m.method_code
          AND   nvl(book_grp.life_in_months,1) = nvl(m.life_in_months,1)
          AND
                bc.book_type_code = h_book
          AND
                ah.asset_id = book_grp.asset_id
          AND   ah.transaction_header_id_out is null
          AND   trunc(h_date_retired) between
                conv.start_date and conv.end_date
          AND   h_ret_p_conv = conv.prorate_convention_code
          AND   ctype.prorate_convention_code = h_ret_p_conv;

       else

          SELECT
                decode(m.depreciate_lastyear_flag,'YES',1,0),
                nvl(book_grp.life_in_months,0),
                decode(book_grp.capitalize_flag, 'YES', 1, 0),
                decode(book_grp.depreciate_flag, 'YES', 1, 0),
                decode(book_grp.period_counter_fully_reserved, null, 0, 1),
                nvl(book_grp.itc_amount_id, 0),
                ah.units,
                bc.current_fiscal_year,
                bc_primary.distribution_source_book,
                book_grp.rate_adjustment_factor,
                nvl(book_grp.adjusted_rate,0),
                book_grp.adjusted_cost,
                book_grp.cost,
                book_grp.recoverable_cost,
                book_grp.itc_amount,
                nvl(book_grp.salvage_value,0),
                trunc(book_grp.prorate_date),
                to_number(to_char(book_grp.prorate_date, 'J')),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                      trunc(book_grp.deprn_start_date), trunc(book_grp.prorate_date)),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                       to_number(to_char(book_grp.deprn_start_date, 'J')),
                       to_number(to_char(book_grp.prorate_date, 'J'))),
                trunc(book_grp.date_placed_in_service),
                to_number(to_char(book_grp.date_placed_in_service, 'J')),
                bc_primary.prorate_calendar,
                m.method_code,
                decode(bc_primary.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                conv.prorate_date,
                trunc(bc_primary.initial_date),
                bc_primary.deprn_calendar,
                nvl(book_grp.ceiling_name, null),
                nvl(book_grp.bonus_rule, null),
                decode(m.rate_source_rule, 'CALCULATED', 1, 'TABLE', 2,
                       'FLAT', 3),
                decode(m.deprn_basis_rule, 'COST', 1, 'NBV', 2),
                decode(bc_primary.book_class, 'TAX', 1, 0),
                decode(ah.asset_type, 'CIP', 1, 0),
                decode(ctype.depr_when_acquired_flag,'YES',1,0),
                nvl(book_grp.reval_amortization_basis,0),
                book_grp.unrevalued_cost,
                nvl(book_grp.adjusted_capacity,0),
                nvl(book_grp.production_capacity,0),
                bc_primary.fiscal_year_name,
                nvl (book_grp.adjusted_recoverable_cost, book_grp.recoverable_cost),
                decode(book_grp.annual_deprn_rounding_flag, NULL, 0, 'ADD', 1,
                       'ADJ', 2, 'RET', 3, 'REV', 4, 'TFR', 5,'RES', 6, 'OVE', 7, -1),
                nvl(book_grp.short_fiscal_year_flag, 'NO'),
                book_grp.conversion_date,
                book_grp.original_deprn_start_date,
                nvl(book_grp.old_adjusted_cost, 1),
                nvl(book_grp.formula_factor, 1),
                book_grp.allowed_deprn_limit_amount,
                book_grp.group_asset_id,
                book_grp.recognize_gain_loss,
                book_grp.recapture_reserve_flag,
                book_grp.limit_proceeds_flag,
                book_grp.terminal_gain_loss,
                book_grp.tracking_method,
                book_grp.exclude_fully_rsv_flag,
                book_grp.excess_allocation_option,
                book_grp.depreciation_option,
                book_grp.member_rollup_flag,
                book_grp.ltd_proceeds,
                book_grp.allocate_to_fully_rsv_flag,
                book_grp.allocate_to_fully_ret_flag,
                book_grp.eofy_reserve,
                book_grp.cip_cost,
                book_grp.ltd_cost_of_removal,
                book_grp.prior_eofy_reserve,
                book_grp.eop_adj_cost,
                book_grp.eop_formula_factor,
                book_grp.exclude_proceeds_from_basis,
                book_grp.retirement_deprn_option,
                book_grp.terminal_gain_loss_amount,
                book_grp.period_counter_fully_reserved
          INTO
                h_depreciate_lastyr,
                h_lifemonths,
                h_capitalize,
                h_depreciate,
                h_fully_reserved,
                h_itc_used,
                h_cur_units,
                h_cpd_fiscal_year,
                h_dis_book,
                h_raf,
                h_adj_rate,
                h_adjusted_cost,
                h_current_cost,
                h_recoverable_cost,
                h_itc_amount,
                h_salvage_value,
                h_prorate_date,
                h_prorate_jdate,
                h_deprn_start_date,
                h_deprn_start_jdate,
                h_date_in_srv,
                h_jdis,
                h_p_cal,
                h_method_code,
                h_depr_first_year_ret,
                h_ret_prorate_date,
                h_initial_date,
                h_deprn_cal,
                h_ceiling_name,
                h_bonus_rule,
                h_rate_source_rule,
                h_deprn_basis_rule,
                h_book_class,
                h_wip_asset,
                h_dwacq,
                h_reval_amort_basis,
                h_unrevalued_cost,
                h_adj_capacity,
                h_capacity,
                h_fiscal_year_name,
                h_adj_rec_cost,
                h_annual_deprn_rounding_flag,
                h_short_fiscal_year_flag,
                h_conversion_date,
                h_orig_deprn_start_date,
                h_old_adj_cost,
                h_formula_factor,
                h_allowed_deprn_limit_amount,
                h_group_asset_id,
                h_recognize_gain_loss,
                h_recapture_reserve_flag,
                h_limit_proceeds_flag,
                h_terminal_gain_loss,
                h_tracking_method,
                h_exclude_fully_rsv_flag,
                h_excess_allocation_option,
                h_depreciation_option,
                h_member_rollup_flag,
                h_ltd_proceeds,
                h_allocate_to_fully_rsv_flag,
                h_allocate_to_fully_ret_flag,
                h_eofy_reserve,
                h_cip_cost,
                h_ltd_cost_of_removal,
                h_prior_eofy_reserve,
                h_eop_adj_cost,
                h_eop_formula_factor,
                h_exclude_proceeds_from_basis,
                h_retirement_deprn_option,
                h_terminal_gain_loss_amount,
                h_pc_fully_reserved
          FROM
                fa_mc_books             book,
                fa_mc_books             book_grp,
                fa_methods              m,
                fa_conventions          conv,
                fa_convention_types     ctype,
                fa_mc_book_controls     bc,
                fa_book_controls        bc_primary, -- added this to get fiscal year name
                fa_asset_history        ah
          WHERE
                book.retirement_id = h_retirement_id
          AND   book.asset_id = h_asset_id
          AND   book.book_type_code = h_book
          AND   book_grp.transaction_header_id_out is null
          AND   book_grp.asset_id = book.group_asset_id
          AND   book_grp.book_type_code = h_book
          AND   book_grp.deprn_method_code = m.method_code
          AND   nvl(book_grp.life_in_months,1) = nvl(m.life_in_months,1)
          AND
                bc.book_type_code = h_book
          AND
                ah.asset_id = book_grp.asset_id
          AND   ah.transaction_header_id_out is null
          AND   trunc(h_date_retired) between
                conv.start_date and conv.end_date
          AND   h_ret_p_conv = conv.prorate_convention_code
          AND   book.set_of_books_id = ret.set_of_books_id
          AND   book_grp.set_of_books_id = ret.set_of_books_id
          AND   bc.set_of_books_id = ret.set_of_books_id
          AND   bc_primary.book_type_code = bc.book_type_code
          AND   ctype.prorate_convention_code = h_ret_p_conv;

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 2', '', p_log_level_rec => p_log_level_rec); end if;

       h_same_fy := 0;

       select   decode(fy1.fiscal_year, fy2.fiscal_year,1,0)
       INTO     h_same_fy
       FROM     FA_FISCAL_YEAR FY1, FA_FISCAL_YEAR FY2
       WHERE    trunc(h_date_retired) between fy1.start_date and fy1.end_date
       AND      trunc(h_deprn_start_date)
                                between fy2.start_date and fy2.end_date
       AND      fy1.fiscal_year_name = h_fiscal_year_name
       AND      fy2.fiscal_year_name = h_fiscal_year_name;

       if (h_same_fy > 0) and (h_depr_first_year_ret is null or
                               h_depr_first_year_ret <= 0) then

          h_ret_prorate_date := h_prorate_date;

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 3', '', p_log_level_rec => p_log_level_rec); end if;


       SELECT   FISCAL.FISCAL_YEAR
       INTO     h_ret_fiscalyr
       FROM     FA_FISCAL_YEAR FISCAL
       WHERE    trunc(h_ret_prorate_date)
                between START_DATE and END_DATE
       AND      fiscal_year_name = h_fiscal_year_name;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 4', '', p_log_level_rec => p_log_level_rec); end if;

       if (h_ret_fiscalyr <> h_cpd_fiscal_year) then

          if h_ret_fiscalyr < h_cpd_fiscal_year then
             h_period_num := 1;
          else h_period_num := 0;
          end if;

          if h_ret_fiscalyr > h_cpd_fiscal_year then

             select     trunc(start_date)
             into       h_ret_prorate_date
             from       fa_fiscal_year
             where      fiscal_year = h_ret_fiscalyr
             and        fiscal_year_name = h_fiscal_year_name;
          else
             SELECT     start_date
             INTO       h_ret_prorate_date
             FROM       fa_fiscal_year
             where      fiscal_year = h_cpd_fiscal_year
             and        fiscal_year_name = h_fiscal_year_name;
          end if;

       end if; -- end of - if (h_ret_fiscalyr

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 5', '', p_log_level_rec => p_log_level_rec); end if;


       if h_rate_source_rule <> 1 then  -- rate_source_rule <> 'CALCULATED'

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 6', '', p_log_level_rec => p_log_level_rec); end if;
          if (h_same_fy > 0) and
             (h_depr_first_year_ret is null or h_depr_first_year_ret <= 0) and
             (h_dwacq > 0) then

            begin
             SELECT     h_deprn_start_date
             INTO       h_ret_prorate_date
             FROM       dual;
            exception
                when no_data_found then
                     null;
           end;
          else
            begin
             SELECT     h_deprn_start_date
             INTO       h_ret_prorate_date
             FROM       dual
             where      trunc(h_ret_prorate_date) < trunc(h_deprn_start_date);
            exception
                when no_data_found then
                     null;
            end;
          end if;
       else
         if p_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'in faggin 7', '', p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, to_char(trunc(h_ret_prorate_date)), '');
            fa_debug_pkg.add(l_calling_fn, to_char(trunc(h_prorate_date)), '');
         end if;

          begin
             SELECT     h_prorate_date
             INTO       h_ret_prorate_date
             FROM       dual
             WHERE      trunc(h_ret_prorate_date) < trunc(h_prorate_date);
          exception
                when no_data_found then
                     null;
          end;

       end if;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add(l_calling_fn, 'Final h_ret_prorate_date', to_char(h_ret_prorate_date));
          fa_debug_pkg.add(l_calling_fn, 'in faggin 8', '', p_log_level_rec => p_log_level_rec);
       end if;
       bk.prorate_date := h_prorate_date;
       bk.deprn_start_date := h_deprn_start_date;
       bk.ret_prorate_date := h_ret_prorate_date;
       bk.date_in_srv := h_date_in_srv;
       bk.p_cal := h_p_cal;
       bk.d_cal := h_deprn_cal;
       bk.ceiling_name := h_ceiling_name;
       bk.bonus_rule := h_bonus_rule;
       bk.dis_book := h_dis_book;
       bk.lifemonths := h_lifemonths;
       bk.depr_first_year_ret := h_depr_first_year_ret;

       if h_capitalize > 0 then
          bk.capitalize := TRUE;
       else
          bk.capitalize := FALSE;
       end if;

       if h_depreciate > 0 then
          bk.depreciate := TRUE;
       else
          bk.depreciate := FALSE;
       end if;
 -- bug#6913897,Added the filter condition, when asset is fully reserved but not fully extended, need to calculate the catch-up amount.
 -- Bug#6920756,Added code to judge if the asset is fully extended or fully reserved.
      /* if ((h_fully_extended > 0) and nvl(h_extended_deprn_flag,'N') = 'Y' ) OR
          (h_fully_reserved > 0 and nvl(h_extended_deprn_flag,'N') <> 'Y' ) then
          bk.fully_reserved := TRUE;
       else
          bk.fully_reserved := FALSE;
       end if; */

       if h_fully_reserved > 0 then
          bk.fully_reserved := TRUE;
       else
          bk.fully_reserved := FALSE;
       end if;

       if h_extended_flag > 0 then
          bk.extended_flag := TRUE;
       else
          bk.extended_flag := FALSE;
       end if;

       if h_fully_extended > 0 then
          bk.fully_extended := TRUE;
       else
          bk.fully_extended := FALSE;
       end if;
       bk.pc_fully_extended := h_pc_fully_extended;
 -- End of fix Bug#6920756
       if h_depreciate_lastyr > 0 then
          bk.depreciate_lastyr := TRUE;
       else
          bk.depreciate_lastyr := FALSE;
       end if;

       if h_book_class > 0 then
          bk.book_class := TRUE;
       else
          bk.book_class := FALSE;
       end if;

       bk.itc_used := h_itc_used;
       bk.rate_source_rule := h_rate_source_rule;
       bk.deprn_basis_rule := h_deprn_basis_rule;
       bk.cur_units := h_cur_units;
       bk.method_code := h_method_code;
       bk.cpd_fiscal_year := h_cpd_fiscal_year;
       bk.jdis := h_jdis;
       bk.prorate_jdate := h_prorate_jdate;
       bk.deprn_start_jdate := h_deprn_start_jdate;
       bk.ret_fiscal_year := h_ret_fiscalyr;
       bk.raf := h_raf;
       bk.adjusted_cost := h_adjusted_cost;
       bk.adj_rate := h_adj_rate;
       bk.current_cost := h_current_cost;
       bk.recoverable_cost := h_recoverable_cost;
       bk.itc_amount := h_itc_amount;
       bk.salvage_value := h_salvage_value;
       bk.reval_amort_basis := h_reval_amort_basis;
       bk.unrevalued_cost := h_unrevalued_cost;
       bk.adj_capacity := h_adj_capacity;
       bk.capacity := h_capacity;
       bk.fiscal_year_name := h_fiscal_year_name;
       bk.adj_rec_cost := h_adj_rec_cost;
       -- +++++ Copy h_annual_deprn_rounding_flag to book_struct. +++++
       bk.deprn_rounding_flag := h_annual_deprn_rounding_flag;
       bk.short_fiscal_year_flag := h_short_fiscal_year_flag;
       bk.conversion_date := h_conversion_date;
       bk.orig_deprn_start_date := h_orig_deprn_start_date;
       bk.old_adj_cost := h_old_adj_cost;
       bk.formula_factor := h_formula_factor;
       -- +++++ Added for Group Asset +++++
       bk.group_asset_id              := h_group_asset_id;
       bk.recognize_gain_loss         := h_recognize_gain_loss;
       bk.recapture_reserve_flag      := h_recapture_reserve_flag;
       bk.limit_proceeds_flag         := h_limit_proceeds_flag;
       bk.terminal_gain_loss          := h_terminal_gain_loss;
       bk.tracking_method             := h_tracking_method;
       bk.exclude_fully_rsv_flag      := h_exclude_fully_rsv_flag;
       bk.excess_allocation_option    := h_excess_allocation_option;
       bk.depreciation_option         := h_depreciation_option;
       bk.member_rollup_flag          := h_member_rollup_flag;
       bk.ltd_proceeds                := h_ltd_proceeds;
       bk.allocate_to_fully_rsv_flag  := h_allocate_to_fully_rsv_flag;
       bk.allocate_to_fully_ret_flag  := h_allocate_to_fully_ret_flag;
       bk.eofy_reserve                := h_eofy_reserve;
       bk.cip_cost                    := h_cip_cost;
       bk.ltd_cost_of_removal         := h_ltd_cost_of_removal;
       bk.prior_eofy_reserve          := h_prior_eofy_reserve;
       bk.eop_adj_cost                := h_eop_adj_cost;
       bk.eop_formula_factor          := h_eop_formula_factor;
       bk.exclude_proceeds_from_basis := h_exclude_proceeds_from_basis;
       bk.retirement_deprn_option     := h_retirement_deprn_option;
       bk.terminal_gain_loss_amount   := h_terminal_gain_loss_amount;
       ret.wip_asset := h_wip_asset;
       bk.pc_fully_reserved := h_pc_fully_reserved;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggin 100', '', p_log_level_rec => p_log_level_rec); end if;

       return(TRUE);

       EXCEPTION

         when faggin_err then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

         when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGGIN;

/*===========================================================================
| NAME          fagfpc                                                      |
|                                                                           |
| FUNCTION      Determines the number of periods need to be catchup.        |
|               A negative number corresponds to the case where the period  |
|               number of the DATE EFFECTIVE of the retirement is less than |
|               the current period number. A positive number corresponds to |
|               teh reverse case. If retirement prorate date is in current  |
|               period, then # of periods catchup is zero.                  |
|                                                                           |
| HISTORY       1/12/89         R Rumanang      Created                     |
|               8/22/90         R Rumanang      add prorate_calendar        |
|               04/12/91        M Chan          Modified for MPL 9          |
|               01/08/97        S Behura        Rewrote in PL/SQL           |
|===========================================================================*/

FUNCTION fagfpc(book in varchar2, ret_p_date in date,
                cpdnum number, cpd_fiscal_year number,
                p_cal in out nocopy varchar2, d_cal in out nocopy varchar2,
                pdspyr number, pds_catchup in out nocopy number,
                startdp in out nocopy number, enddp in out nocopy number,
                startpp in out nocopy number, endpp in out nocopy number,
                fiscal_year_name in out nocopy varchar2,
                cpdnum_set varchar2 /*Bug#8620551 */
                , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    fagfpc_err          exception;

    dummy               number;
    ret_pro_mth         number;
    ret_pro_fy          number;
    fiscal_year         number;
    ret_p_period_num    number;
    ret_p_jdate         number;
    p_pds_per_yr        integer;


    h_startpp           integer;
    h_endpp             integer;
    h_ret_p_jstartdate  integer;
    h_p_cal             varchar2(21);
    h_d_cal             varchar2(21);
    h_fiscal_year_name  varchar2(31);
    h_ret_p_date        date;
    h_cpp_jstartdate    number;
    h_cpdnum            number;
    h_book              varchar2(30);
    h_cpd_fy            number;

    l_calling_fn        varchar2(80) := 'fa_gainloss_ret_pkg.fagfpc';

    BEGIN <<FAGFPC>>

       h_d_cal := d_cal;
       h_p_cal := p_cal;
       h_fiscal_year_name := fiscal_year_name;
       h_ret_p_date := ret_p_date;
       h_book := book;
       h_cpdnum := cpdnum;
       h_cpd_fy := cpd_fiscal_year;

       ret_p_jdate := to_char(ret_p_date, 'J');

       if not fa_cache_pkg.fazccp(d_cal, fiscal_year_name, ret_p_jdate,
                         ret_p_period_num, fiscal_year, dummy, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagfpc_err;
       end if;

       if not fa_GAINLOSS_MIS_PKG.faggfy(ret_p_date, p_cal,
                                                ret_pro_mth, ret_pro_fy,
                                                fiscal_year_name, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_ret_pkg.fagfpc',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGGFY',
             token2     => 'INFO',
             value2     => 'Retirement Prorate Date',
             token3     => 'ASSET',
             value3     => NULL,  p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       -- Get the number of periods per year in the rate calendar
       if not fa_cache_pkg.fazcct(p_cal, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_ret_pkg.fagfpc',  p_log_level_rec => p_log_level_rec);
          raise fagfpc_err;
       end if;

       p_pds_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;


       begin
          -- Bug8620551
          -- Added the condition to check for daily prorate assets
          if cpdnum_set = 'N' then
                SELECT  to_number (to_char (cp.start_date, 'J'))
                INTO    h_cpp_jstartdate
                FROM    fa_deprn_periods dp,
                        fa_calendar_periods cp,
                        fa_fiscal_year fy
                WHERE   cp.calendar_type = h_d_cal
                AND     fy.fiscal_year_name = h_fiscal_year_name
                AND     fy.fiscal_year = h_cpd_fy
                AND     dp.fiscal_year = fy.fiscal_year
                AND     dp.book_type_code = h_book
                AND     dp.period_num = h_cpdnum
                AND     dp.period_name = cp.period_name
                AND     dp.period_num = cp.period_num;
          end if;
          EXCEPTION
             when no_data_found then
                raise fagfpc_err;
          end;


       -- getting start prorate period num

       begin
          -- Bug8620551
          -- Added the condition to check for daily prorate assets
          if cpdnum_set = 'N' then
             SELECT  period_num
             INTO    h_startpp
             FROM    fa_calendar_periods
             WHERE   calendar_type = h_p_cal
             AND     to_date (h_cpp_jstartdate,'J')
                           between start_date and end_date;
          end if;
          EXCEPTION
             when no_data_found then
                raise fagfpc_err;
       end;


      --  getting end prorate period num

       begin
          SELECT  period_num
          INTO    h_endpp
          FROM    fa_calendar_periods
          WHERE   calendar_type = h_p_cal
          AND     trunc(h_ret_p_date)
                        between start_date and end_date;
          EXCEPTION
             when no_data_found then
                raise fagfpc_err;
       end;

       startpp := h_startpp;
       endpp := h_endpp;

    /* Retirement cannot accross fiscal year, thus it always happen in current
       fiscal year. However, retirement_prorate_convention may cause the
       prorate_date  in the next year (ie: FOLLOWING-MONTH.)
    */

       pds_catchup :=  (((ret_pro_fy * p_pds_per_yr) +  h_endpp) -
                         ((cpd_fiscal_year * p_pds_per_yr) + h_startpp));

       -- Bug8620551
       if cpdnum_set = 'N' then
          startdp := cpdnum;
          enddp :=  cpdnum;
       end if;
       return(TRUE);

       EXCEPTION

          when others then
             fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;

    END FAGFPC;

/*==========================================================================
|  NAME         faggrv                                                     |
|                                                                          |
|  FUNCTION     Gets current depreciation reserve after adjsuted with      |
|               total adjustments so far for this period. For TAX          |
|               retirement, we need to look for if there is any tax        |
|               adjustment or not.                                         |
|                                                                          |
|  HISTORY      9/9/89     R Rumanang     Created                          |
|               9/5/90     R Rumanang     Updated for Tax Reserve          |
|                                         Adjustment                       |
|               04/11/91   M Chan         Rewrite for MPL 9 to speed up the|
|                                         retirement program.              |
|               01/08/97   S Behura       Rewrote into PL/SQL              |
|               08/11/97   S Behura       Rewrote into PL/SQL(10.7)        |
|==========================================================================*/

FUNCTION faggrv(asset_id number, book in varchar2, cpd_ctr number,
                adj_rsv in out nocopy number, reval_adj_rsv in out nocopy number,
                prior_fy_exp in out nocopy number, ytd_deprn in out nocopy number,
                bonus_rsv in out nocopy number,
                bonus_ytd_deprn in out nocopy number,
                prior_fy_bonus_exp in out nocopy number,
                impairment_rsv in out nocopy number,
                ytd_impairment in out nocopy number,
                mrc_sob_type_code in varchar2,
                set_of_books_id in number,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    faggrv_err          exception;

    dpr_row             fa_STD_TYPES.fa_deprn_row_struct;
    h_success           boolean;

    l_calling_fn        varchar2(80) := 'fa_gainloss_ret_pkg.faggrv';

    BEGIN <<FAGGRV>>

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'IN FAGGRV', '', p_log_level_rec => p_log_level_rec); end if;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Getting depreciation reserve adjustments',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       /*  we need to take into account about the CREDIT, because Reinstatement
       of a retirement will put up a CR of reserve. h_tot_adjustment holds
       the value of adjustment to reserve + expense for this period */

       dpr_row.asset_id := asset_id;
       dpr_row.book := book;
       dpr_row.dist_id := 0;
       dpr_row.period_ctr := cpd_ctr;
       dpr_row.mrc_sob_type_code := mrc_sob_type_code;
       dpr_row.set_of_books_id := set_of_books_id;

       FA_QUERY_BALANCES_PKG.query_balances_int (
                  X_DPR_ROW => dpr_row,
                  X_RUN_MODE => 'STANDARD',
                  X_DEBUG => FALSE,
                  X_SUCCESS => H_SUCCESS,
                  X_CALLING_FN => l_calling_fn,
                  X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

       if dpr_row.period_ctr <> 0 then
             adj_rsv := dpr_row.deprn_rsv;
             reval_adj_rsv := dpr_row.reval_rsv;
             bonus_rsv := dpr_row.bonus_deprn_rsv;
             bonus_ytd_deprn := dpr_row.bonus_ytd_deprn;
             impairment_rsv := dpr_row.impairment_rsv;
             ytd_impairment := dpr_row.ytd_impairment;

             /*** Copy dpr_row.prior_fy_exp to prior_fy_exp. ***/
             prior_fy_exp := dpr_row.prior_fy_exp;
             prior_fy_bonus_exp := dpr_row.prior_fy_bonus_exp;
             ytd_deprn := dpr_row.ytd_deprn;
       else
             -- faggrv: no values found in query fin info function
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise faggrv_err;
        end if;

        return(TRUE);

       EXCEPTION

          when faggrv_err then
             fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;

          when others then
             fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;


    END FAGGRV;

/*=============================================================================
|                                                                             |
|  NAME         fagret                                                        |
|                                                                             |
|  FUNCTION     This function does the retirement process based on the        |
|               retirement structure and book information.                    |
|               Briefly, it determines the number of periods need to be       |
|               catchup based on the DATE_EFFECTIVE of the retirement and the |
|               current period START_DATE. The number of periods catchup is   |
|               determined by substracting the current period number from     |
|               the period number of DATE_EFFECTIVE. If the number is         |
|               positive, then we need to calculate the depreciation amount   |
|               needs to be taken each period; otherwise, we don't need to    |
|               determine the depreciation rate since we can obtain the       |
|               deprn_amount need to be taken from the previous records in    |
|               deprn_summary and deprn_detail.                               |
|                                                                             |
|  HISTORY      1/12/89   R Rumanang    Created                               |
|               6/23/89   R Rumanang    Standarized                           |
|               8/30/89   R Rumanang    Add calls to fagprv, etc as part      |
|                                       of the GL interface project.          |
|               9/08/89   R Rumanang    When capitalize_flag is NO, just set  |
|                                       the retirment to PROCESSED.           |
|               04/08/91  M Chan        Rewrite the module so that it will    |
|                                       handle the retirement process in a    |
|                                       better way.                           |
|               01/08/97  S Behura      Rewrote into PL/SQL                   |
|               08/11/97  S Behura      Rewrote into PL/SQL(10.7)             |
|============================================================================*/

FUNCTION fagret(ret in out nocopy fa_RET_TYPES.ret_struct,
                bk in out nocopy fa_RET_TYPES.book_struct,
                dpr in out nocopy fa_STD_TYPES.dpr_struct, today in date,
                cpd_ctr number, cpdnum number, retpdnum in out nocopy number,
                user_id number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS
    fagret_err          exception;

    -- Cursors and variables added for bug4343087
    CURSOR c_get_new_bk(c_asset_id number) is
       select adjusted_cost
            , salvage_value
            , recoverable_cost
            , adjusted_recoverable_cost
            , reval_amortization_basis
            , old_adjusted_cost
       from   fa_books
       where  asset_id = c_asset_id
       and    book_type_code = ret.book
       and    transaction_header_id_out is null;

    CURSOR c_get_new_mc_bk(c_asset_id number) is
       select adjusted_cost
            , salvage_value
            , recoverable_cost
            , adjusted_recoverable_cost
            , reval_amortization_basis
            , old_adjusted_cost
       from   fa_mc_books
       where  asset_id = c_asset_id
       and    book_type_code = ret.book
       and    set_of_books_id = ret.set_of_books_id
       and    transaction_header_id_out is null;

    l_temp_deprn_amt       number;
    l_temp_bonus_deprn_amt number;
    l_temp_impairment_amt  number;
    l_temp_reval_deprn_amt number;
    l_temp_reval_amort     number;
    -- End of Cursors and variables added for bug4343087

    periods_catchup     number;
    start_pd            number;
    end_pd              number;
    start_ppd           number;
    end_ppd             number;
    deprn_amt           number;
    bonus_deprn_amt     number;
    bonus_deprn_reserve number;
    bonus_ytd_deprn     number;
    impairment_amt      number;
    impairment_reserve  number;
    ytd_impairment      number;
    deprn_reserve       number;
    reval_deprn_amt     number;
    reval_amort         number;
    reval_reserve       number;
    prior_fy_exp        number;
    prior_fy_bonus_exp  number;
    ytd_deprn           number;
    jdate_retired       number;
    ret_prorate_jdate   number;
    cost_frac           number;

    d_cost_retired      number;
    d_current_cost      number;
    d_cost_frac         number;

    h_date_retired      date;
    h_ret_prorate_date  date;
    h_jdate_retired     number;
    h_ret_prorate_jdate number;

    l_asset_hdr_rec         FA_API_TYPES.asset_hdr_rec_type;
    l_asset_deprn_rec_old   FA_API_TYPES.asset_deprn_rec_type;

    -- Bug 5525968: start
    bk_group            fa_ret_types.book_struct;
    dpr_group           fa_STD_TYPES.dpr_struct;
    ret_group           fa_ret_types.ret_struct;
    pds_per_year        number;
    p_pds_per_year      number;
    cpd_num             number;
    cpd_name            varchar2(15);
    ret_pdnum           number;
    pro_mth             number;
    dsd_mth             number;
    pro_fy              number;
    dsd_fy              number;
    deprn_amt_group     number;
    bonus_deprn_amt_group number;
    impairment_amt_group number;
    impairment_reserve_group number;
    reval_deprn_amt_group number;
    reval_amort_group   number;
    reval_reserve_group number;
    -- Bug 5525968: end

    -- Bug 4639408
    l_temp_deprn_reserve number;
    l_decision_flag     BOOLEAN;    -- Bug#6920756
    l_calling_fn        varchar2(80) := 'fa_gainloss_ret_pkg.fagret';
    --Bug8620551
    --Added new cursor and variable to check for retirement in period of addition
    h_cpdnum     number; --Bug6187408
    prd_flag varchar2(1);
    cpdnum_set varchar2(1);
    cursor c_prd_flag is
    select 'Y'
     from fa_calendar_periods fcp1,
          fa_calendar_periods  fcp2,
          fa_book_controls fbc
     where to_date (dpr.prorate_jdate,'J') BETWEEN fcp1.start_date and fcp1.end_date
                and fbc.book_type_code = dpr.book
                and fcp1.calendar_type = fbc.deprn_calendar
                and to_date (decode( dpr.jdate_retired,0,null,dpr.jdate_retired),'J') BETWEEN fcp2.start_date and fcp2.end_date
                and fcp2.calendar_type=fcp1.calendar_type
                and fcp1.period_name=fcp2.period_name;

    BEGIN <<FAGRET>>


       deprn_amt := 0;
       deprn_reserve := 0;
       bonus_deprn_amt := 0;
       bonus_deprn_reserve := 0;
       impairment_amt := 0;
       impairment_reserve := 0;
       reval_deprn_amt := 0;
       reval_amort := 0;
       reval_reserve := 0;
       prior_fy_exp := 0;
       prior_fy_bonus_exp := 0;
       ytd_deprn := 0;
       cost_frac := 0;
       bonus_ytd_deprn := 0;
       ytd_impairment := 0;

       if (bk.current_cost is null or bk.current_cost = 0) then
          cost_frac := 0;
       else
          cost_frac := ret.cost_retired / bk.current_cost;
       end if;

       --Commented out the following to avoid rounding of
       --Cost_Frac. Bug no 1050284

       -- CHECK: SNARAYAN. may need to round cost frac to 8 digits

       /* if not EFA_utilities.faxrnd(cost_frac, ret.book, cost_frac) then
                               'Call faxrnd to round cost_frac in fagret');
       end if;*/


       if (bk.group_asset_id is not null) then
          l_asset_hdr_rec.asset_id := bk.group_asset_id;
          l_asset_hdr_rec.book_type_code := ret.book;
          -- l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
          l_asset_hdr_rec.set_of_books_id := ret.set_of_books_id;

          if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec_old,
                   p_mrc_sob_type_code     => ret.mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(
                calling_fn => l_calling_fn,
                name       => 'FA_RET_GENERIC_ERROR',
                token1     => 'MODULE',
                value1     => 'get_asset_deprn_rec',
                token2     => 'INFO',
                value2     => 'old deprn',
                token3     => 'ASSET',
                value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

             return false;
          end if;
       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret1 ', '', p_log_level_rec => p_log_level_rec); end if;

       if not faggrv(ret.asset_id, ret.book, cpd_ctr, deprn_reserve,
                     reval_reserve, prior_fy_exp, ytd_deprn,
                     bonus_deprn_reserve, bonus_ytd_deprn,
                     prior_fy_bonus_exp,
                     impairment_reserve, ytd_impairment,
                     ret.mrc_sob_type_code,
                     ret.set_of_books_id,
                     p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGGRV',
             token2     => 'INFO',
             value2     => 'reserve',
             token3     => 'ASSET',
             value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret2', '', p_log_level_rec => p_log_level_rec); end if;

       dpr.deprn_rsv := deprn_reserve;
       dpr.reval_rsv := reval_reserve;
       dpr.prior_fy_exp := prior_fy_exp;
       dpr.ytd_deprn := ytd_deprn;
       dpr.bonus_deprn_rsv := bonus_deprn_reserve;
       dpr.bonus_ytd_deprn := bonus_ytd_deprn;
       dpr.prior_fy_bonus_exp := prior_fy_bonus_exp;
       dpr.impairment_rsv := impairment_reserve;
       dpr.ytd_impairment := ytd_impairment;

       dpr.rsv_known_flag := TRUE;

       --Bug8620551
       -- Get the number of periods per year in the rate calendar
       if not fa_cache_pkg.fazcct(bk.p_cal) then
          fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_ret_pkg.fagret'
                    ,p_log_level_rec => p_log_level_rec);
          raise fagret_err;
       end if;
       h_cpdnum := cpdnum;
       open c_prd_flag;
       fetch c_prd_flag into prd_flag;
       if c_prd_flag%NOTFOUND then
          prd_flag := 'N';
       end if;
       close c_prd_flag;

       if fa_cache_pkg.fazcct_record.number_per_fiscal_year = 365 and prd_flag = 'Y' then

                start_pd := cpdnum;
                end_pd := cpdnum;
                cpdnum_set := 'Y';

               SELECT  facp.period_num
               INTO    h_cpdnum
               FROM    fa_calendar_periods facp
               WHERE   facp.calendar_type = bk.p_cal
               AND    ( facp.start_date = bk.prorate_date
               OR      facp.end_date = bk.prorate_date );
         else
            cpdnum_set := 'N';
         end if;
       --Bug8620551
       --Passing h_cpdnum instead of cpdnum and added cpdnum_set flag

       if not fagfpc(ret.book, bk.ret_prorate_date, h_cpdnum,
                     bk.cpd_fiscal_year, bk.p_cal, bk.d_cal,
                     bk.pers_per_yr, periods_catchup,
                     start_pd, end_pd, start_ppd, end_ppd,
                     bk.fiscal_year_name,
                     cpdnum_set,
                     p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => l_calling_fn,
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGFPC',
             token2     => 'INFO',
             value2     => 'catchup period',
             token3     => 'ASSET',
             value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret3', '', p_log_level_rec => p_log_level_rec); end if;

    /* If it's capitalize and also depreciate, we will calculate
       depreciation; otherwise, we will skip it
    */

       jdate_retired := to_char(ret.date_retired, 'J');
       h_jdate_retired := to_char(ret.date_retired, 'J');
       ret_prorate_jdate := to_char(bk.ret_prorate_date, 'J');
       h_ret_prorate_jdate := to_char(bk.ret_prorate_date, 'J');

       dpr.jdate_retired := jdate_retired;
       dpr.ret_prorate_jdate := ret_prorate_jdate;

       if start_pd = 0 then /* If start is zero, calculate the whole deprn*/
          dpr.p_cl_begin := 1;
        /* It is O.K. to assign 1 to dpr->p_cl_begin, because the deprn
       engine is smart enough to skip over periods before the deprn
       start period */

       else
          dpr.p_cl_begin := start_pd;
       end if;

       dpr.p_cl_end := end_pd;

       deprn_amt := 0;

       -- Bug 5525968: start: calulate bk and dpr info for group
       if(bk.group_asset_id is not null) then
          ret_group := ret;
          ret_group.asset_id := bk.group_asset_id;

          select asset_number
          into ret_group.asset_number
          from fa_additions_b
          where asset_id = ret_group.asset_id;

          if not faggin(ret, bk_group, p_log_level_rec) then

             fa_srvr_msg.add_message(
                     calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
                     name       => 'FA_RET_GENERIC_ERROR',
                     token1     => 'MODULE',
                     value1     => 'FAGGBI',
                     token2     => 'INFO',
                     value2     => 'FA_BOOKS',
                     token3     => 'ASSET',
                     value3     => ret_group.asset_number ,  p_log_level_rec => p_log_level_rec);

             return(FALSE);
          end if;


          bk_group.pers_per_yr := bk.pers_per_yr;

          if not FA_GAINLOSS_MIS_PKG.faggfy(bk_group.prorate_date, bk_group.p_cal,
                                        pro_mth, pro_fy,
                                        bk_group.fiscal_year_name, p_log_level_rec => p_log_level_rec) then

              fa_srvr_msg.add_message(
                     calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
                     name       => 'FA_RET_GENERIC_ERROR',
                     token1     => 'MODULE',
                     value1     => 'FAGGFY',
                     token2     => 'INFO',
                     value2     => 'Retirement Prorate Date',
                     token3     => 'ASSET',
                     value3     => ret_group.asset_number ,  p_log_level_rec => p_log_level_rec);

              return(FALSE);

          end if;

          dpr_group.prorate_jdate := bk_group.prorate_jdate;
          dpr_group.deprn_start_jdate := bk_group.deprn_start_jdate;
          bk_group.prorate_mth := pro_mth;
          bk_group.prorate_fy := pro_fy;

          if not FA_GAINLOSS_MIS_PKG.faggfy(bk_group.deprn_start_date, bk_group.p_cal,
                                        dsd_mth, dsd_fy,
                                        bk_group.fiscal_year_name, p_log_level_rec => p_log_level_rec) then

               fa_srvr_msg.add_message(
                     calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
                     name       => 'FA_RET_GENERIC_ERROR',
                     token1     => 'MODULE',
                     value1     => 'FAGGFY',
                     token2     => 'INFO',
                     value2     => 'Deprn Prorate Date',
                     token3     => 'ASSET',
                     value3     => ret_group.asset_number ,  p_log_level_rec => p_log_level_rec);

               return(FALSE);

           end if;

           bk_group.dsd_mth := dsd_mth;
           bk_group.dsd_fy := dsd_fy;

           dpr_group.asset_id := ret_group.asset_id;
           dpr_group.book := ret_group.book;
           dpr_group.asset_type := 'GROUP';
           dpr_group.adj_cost := bk_group.adjusted_cost;
           dpr_group.rec_cost := bk_group.recoverable_cost;
           dpr_group.adj_rate := bk_group.adj_rate;
           dpr_group.rate_adj_factor := bk_group.raf;
           dpr_group.reval_amo_basis := bk_group.reval_amort_basis;
           dpr_group.adj_capacity := bk_group.adj_capacity;
           dpr_group.capacity := bk_group.adj_capacity;
           dpr_group.ltd_prod := 0;

           dpr_group.adj_rec_cost := bk_group.adj_rec_cost;
           dpr_group.salvage_value := bk_group.salvage_value;
           dpr_group.old_adj_cost := bk_group.old_adj_cost;
           dpr_group.formula_factor := bk_group.formula_factor;
           dpr_group.set_of_books_id := dpr.set_of_books_id; --Bug 8497696

           if (bk_group.deprn_rounding_flag is null
               or bk_group.deprn_rounding_flag=0) then
              dpr_group.deprn_rounding_flag := NULL;
           elsif bk_group.deprn_rounding_flag=1 then
              dpr_group.deprn_rounding_flag := 'ADD';
           elsif bk_group.deprn_rounding_flag=2 then
              dpr_group.deprn_rounding_flag := 'ADJ';
           elsif bk_group.deprn_rounding_flag=3 then
              dpr_group.deprn_rounding_flag := 'RET';
           elsif bk_group.deprn_rounding_flag=4 then
              dpr_group.deprn_rounding_flag := 'REV';
           elsif bk_group.deprn_rounding_flag=5 then
              dpr_group.deprn_rounding_flag := 'TFR';
           elsif bk_group.deprn_rounding_flag=6 then
              dpr_group.deprn_rounding_flag := 'RES';
           elsif bk_group.deprn_rounding_flag=7 then
              dpr_group.deprn_rounding_flag := 'OVE';
           else
              dpr_group.deprn_rounding_flag := NULL;
           end if;

           dpr_group.asset_num := ret_group.asset_number;
           dpr_group.calendar_type := bk_group.d_cal;
           dpr_group.ceil_name := bk_group.ceiling_name;
           dpr_group.bonus_rule := bk_group.bonus_rule;
           dpr_group.method_code := bk_group.method_code;
           dpr_group.jdate_in_service := bk_group.jdis;
           dpr_group.life := bk_group.lifemonths;
           dpr_group.y_begin := bk_group.cpd_fiscal_year;
           dpr_group.y_end := bk_group.cpd_fiscal_year;

           dpr_group.short_fiscal_year_flag := bk_group.short_fiscal_year_flag;
           dpr_group.conversion_date := bk_group.conversion_date;
           dpr_group.prorate_date := bk_group.prorate_date;
           dpr_group.orig_deprn_start_date := bk_group.orig_deprn_start_date;

           if not faggrv(ret_group.asset_id, ret_group.book, cpd_ctr, dpr_group.deprn_rsv,
                     dpr_group.reval_rsv, dpr_group.prior_fy_exp, dpr_group.ytd_deprn,
                     dpr_group.bonus_deprn_rsv, dpr_group.bonus_ytd_deprn,
                     dpr_group.prior_fy_bonus_exp,
                     dpr_group.impairment_rsv, dpr_group.ytd_impairment,
                     ret.mrc_sob_type_code,
                     ret.set_of_books_id,
                     p_log_level_rec) then

                  fa_srvr_msg.add_message(
                     calling_fn => l_calling_fn,
                     name       => 'FA_RET_GENERIC_ERROR',
                     token1     => 'MODULE',
                     value1     => 'FAGGRV',
                     token2     => 'INFO',
                     value2     => 'reserve',
                     token3     => 'ASSET',
                     value3     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

                  return(FALSE);

           end if;

           dpr_group.rsv_known_flag := TRUE;

           dpr_group.jdate_retired := jdate_retired;
           dpr_group.ret_prorate_jdate := ret_prorate_jdate;

           dpr_group.p_cl_begin := dpr.p_cl_begin;
           dpr_group.p_cl_end := dpr.p_cl_end;
           deprn_amt_group := 0;

       end if;
       -- Bug 5525968: end

       -- condition modified for Bug 3849510. bk.depreciate moved from first if to
       -- to inner if. Call fagcdp to calculate catchup only if depreciate flag is
       -- is Yes. If depreciate flag is no, still let logic go through to call
       -- fagdpdp/farboe to calculate backout expense if prorate date falls in the
       -- past.

       if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, 'bk.depr_first_year_ret BEFORE if', bk.depr_first_year_ret, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, 'periods_catchup', periods_catchup, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, 'bk.depr_first_year_ret', bk.depr_first_year_ret, p_log_level_rec => p_log_level_rec);
           if (bk.fully_reserved = null) then
             fa_debug_pkg.add (l_calling_fn, 'bk.fully_reserved', 'NULL !!');
           elsif (bk.fully_reserved) then
             fa_debug_pkg.add (l_calling_fn, 'bk.fully_reserved', 'TRUE', p_log_level_rec => p_log_level_rec);
           else
             fa_debug_pkg.add (l_calling_fn, 'bk.fully_reserved', 'FALSE', p_log_level_rec => p_log_level_rec);
           end if;
       end if;
       --Bug#6920756, Using l_decision_flag to judge if the asset is fully reserved/fully extended.
       -- Bug 8211842 : Check if asset has started extended depreciation
       if bk.extended_flag and bk.start_extended then
         l_decision_flag := bk.fully_extended;
       else
         l_decision_flag := bk.fully_reserved;
       end if;


       if bk.capitalize and (ret.wip_asset is null or
                                               ret.wip_asset <= 0) then
          -- Bug#4867806: if (periods_catchup > 0) and bk.depreciate
          -- Note: bk.depr_first_year_ret=> 0:1=No:Yes; Need to back out expense when bk.depr_first_year_ret=0 (No)
          if (periods_catchup > 0 or bk.depr_first_year_ret = 0) and bk.depreciate
             --and (not bk.fully_reserved) then
             and (not l_decision_flag) then --Bug#6920756, Using l_decision_flag instead of fully_reserved.

             if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret3.1', '', p_log_level_rec => p_log_level_rec); end if;

             if not FA_GAINLOSS_DPR_PKG.fagcdp(dpr, deprn_amt,
                                bonus_deprn_amt,
                                impairment_amt,
                                reval_deprn_amt,
                                reval_amort, bk.deprn_start_date,
                                bk.d_cal, bk.p_cal, start_pd, end_pd,
                                bk.prorate_fy, bk.dsd_fy, bk.prorate_jdate,
                                bk.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

                fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_GENERIC_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGCDP',
                  token2     => 'INFO',
                  value2     => 'depreciation number',
                  token3     => 'ASSET',
                  value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

                return(FALSE);

             end if;

             if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret3.2', '', p_log_level_rec => p_log_level_rec); end if;

             -- Bug4343087:
             -- In order to find correct catchup amount without rounding
             -- error we need to find expense before retirement(before) and
             -- after retirement(after) and then subtract after amount from before.
             -- Following portion of code finds after amounts and then subtract
             -- before amount that is found in previous fagcdp call.
             if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'before deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'before bonus_deprn_amt', bonus_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'before reval_deprn_amt', reval_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'before reval_amort', reval_amort, p_log_level_rec => p_log_level_rec);
             end if;

             -- Store before amount
             l_temp_deprn_amt       := deprn_amt;
             l_temp_bonus_deprn_amt := bonus_deprn_amt;
             l_temp_impairment_amt  := impairment_amt;
             l_temp_reval_deprn_amt := reval_deprn_amt;
             l_temp_reval_amort     := reval_amort;

             -- Get after fin ncial info for calling fagcdp
             if (ret.mrc_sob_type_code = 'R') then
                open c_get_new_mc_bk(ret.asset_id);
                fetch c_get_new_mc_bk into dpr.adj_cost
                                         , dpr.salvage_value
                                         , dpr.rec_cost
                                         , dpr.adj_rec_cost
                                         , dpr.reval_amo_basis
                                         , dpr.old_adj_cost;
                close c_get_new_mc_bk;
             else
                open c_get_new_bk(ret.asset_id);
                fetch c_get_new_bk into dpr.adj_cost
                                         , dpr.salvage_value
                                         , dpr.rec_cost
                                         , dpr.adj_rec_cost
                                         , dpr.reval_amo_basis
                                         , dpr.old_adj_cost;
                close c_get_new_bk;
             end if;

             -- fix for 4639408
             dpr.deprn_rsv := cost_frac * deprn_reserve;
             if not FA_UTILS_PKG.faxrnd(dpr.deprn_rsv, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return FALSE;
             end if;
             dpr.deprn_rsv := deprn_reserve - dpr.deprn_rsv;
             -- end fix for 4639408

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'calling function', 'FA_GAINLOSS_DPR_PKG.fagcdp', p_log_level_rec => p_log_level_rec);
             end if;

             -- Find new expense using after amounts
             if not FA_GAINLOSS_DPR_PKG.fagcdp(dpr, deprn_amt,
                                bonus_deprn_amt,
                                impairment_amt,
                                reval_deprn_amt,
                                reval_amort, bk.deprn_start_date,
                                bk.d_cal, bk.p_cal, start_pd, end_pd,
                                bk.prorate_fy, bk.dsd_fy, bk.prorate_jdate,
                                bk.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

                if p_log_level_rec.statement_level then
                   fa_debug_pkg.add (l_calling_fn, 'calling FA_GAINLOSS_DPR_PKG.fagcdp', 'FAILED', p_log_level_rec => p_log_level_rec);
                end if;

                fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_GENERIC_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGCDP',
                  token2     => 'INFO',
                  value2     => 'depreciation number',
                  token3     => 'ASSET',
                  value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

                return(FALSE);

             end if;

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'after deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'after bonus_deprn_amt', bonus_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'after reval_deprn_amt', reval_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, 'after reval_amort', reval_amort, p_log_level_rec => p_log_level_rec);
             end if;

             -- Find catchup amount by subtracting before from after amounts.
             deprn_amt       := l_temp_deprn_amt - deprn_amt;
             bonus_deprn_amt := l_temp_bonus_deprn_amt - bonus_deprn_amt;
             impairment_amt  := l_temp_impairment_amt - impairment_amt;
             reval_deprn_amt := l_temp_reval_deprn_amt - reval_deprn_amt;
             reval_amort     := l_temp_reval_amort - reval_amort;

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, '+ final deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, '+ final bonus_deprn_amt', bonus_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, '+ final reval_deprn_amt', reval_deprn_amt, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add (l_calling_fn, '+ final reval_amort', reval_amort, p_log_level_rec => p_log_level_rec);
             end if;

             -- Set original value back in case subsequent calls
             -- are expecting before amounts
             dpr.adj_cost := bk.adjusted_cost;
             dpr.rec_cost := bk.recoverable_cost;
             dpr.reval_amo_basis := bk.reval_amort_basis;
             dpr.adj_rec_cost := bk.adj_rec_cost;
             dpr.salvage_value := bk.salvage_value;
             dpr.old_adj_cost := bk.old_adj_cost;

             -- Bug4343087: Commenting out following four lines due to rounding issue
             -- deprn_amt := deprn_amt * cost_frac;
             -- bonus_deprn_amt := bonus_deprn_amt * cost_frac;
             -- reval_deprn_amt := reval_deprn_amt * cost_frac;
             -- reval_amort := reval_amort * cost_frac;

             -- End of fix for bug4343087

             /* BUG# 2482031: rounding issue - YYOON */
             if not FA_UTILS_PKG.faxrnd(x_amount => deprn_amt
                                       ,x_book   => ret.book
                                       ,x_set_of_books_id => ret.set_of_books_id
                                       , p_log_level_rec => p_log_level_rec) then
                                           return FALSE;
             end if;


             if not FA_UTILS_PKG.faxrnd(x_amount => bonus_deprn_amt
                                       ,x_book   => ret.book
                                       ,x_set_of_books_id => ret.set_of_books_id
                                       , p_log_level_rec => p_log_level_rec) then
                                           return FALSE;
             end if;

             if not FA_UTILS_PKG.faxrnd(x_amount => impairment_amt
                                       ,x_book   => ret.book
                                       ,x_set_of_books_id => ret.set_of_books_id
                                       , p_log_level_rec => p_log_level_rec) then
                                           return FALSE;
             end if;


             if not FA_UTILS_PKG.faxrnd(x_amount => reval_deprn_amt
                                       ,x_book   => ret.book
                                       ,x_set_of_books_id => ret.set_of_books_id
                                       , p_log_level_rec => p_log_level_rec) then
                                           return FALSE;
             end if;

             if not FA_UTILS_PKG.faxrnd(x_amount => reval_amort
                                       ,x_book   => ret.book
                                       ,x_set_of_books_id => ret.set_of_books_id
                                       , p_log_level_rec => p_log_level_rec) then
                                           return FALSE;
             end if;

             --bug 5525968

          end if; -- if (periods_catchup

          if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'before calling fagpdp', '', p_log_level_rec => p_log_level_rec);
          end if;

          -- Bug 5525968: called fagpdp only in case where expense row need to inserted for
          -- member with member info.
          if bk.group_asset_id is null or
            (bk.group_asset_id is not null and bk.tracking_method = 'CALCULATE') then

              if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'calling fagpdp 1', '', p_log_level_rec => p_log_level_rec);
              end if;
              if not FA_GAINLOSS_UPD_PKG.fagpdp(ret, bk, dpr, today,
                                        periods_catchup, cpd_ctr,
                                        cpdnum, cost_frac, deprn_amt,
                                        bonus_deprn_amt,
                                        impairment_amt, impairment_reserve,
                                        reval_deprn_amt, reval_amort,
                                        reval_reserve, user_id, p_log_level_rec => p_log_level_rec) then

                fa_srvr_msg.add_message(
                          calling_fn => l_calling_fn,
                          name       => 'FA_RET_INSERT_ERROR',
                          token1     => 'MODULE',
                          value1     => 'FAGPDP',
                          token2     => 'ACTION',
                          value2     => 'insert',
                          token3     => 'TYPE',
                          value3     => 'Depreciation',
                          token4     => 'ASSET',
                          value4     => ret.asset_number , p_log_level_rec => p_log_level_rec);

                return(FALSE);

              end if;

          end if; -- if (bk.group_asset_id

          if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'after calling fagpdp', '', p_log_level_rec => p_log_level_rec);
          end if;

       end if; -- end of - if bk.capitalize

       if (ret.wip_asset is NULL or ret.wip_asset <= 0) then

          if not FA_GAINLOSS_UPD_PKG.fagprv(ret, bk, cpd_ctr,
                        cost_frac, today, user_id,
                        deprn_amt, reval_deprn_amt, reval_amort,
                        deprn_reserve, reval_reserve,
                        bonus_deprn_amt, bonus_deprn_reserve,
                        impairment_amt, impairment_reserve, p_log_level_rec => p_log_level_rec) then

             fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_INSERT_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGPRV',
                  token2     => 'ACTION',
                  value2     => 'insert',
                  token3     => 'TYPE',
                  value3     => 'Depreciation Reserve',
                  token4     => 'ASSET',
                  value4     => ret.asset_number , p_log_level_rec => p_log_level_rec);

             return(FALSE);

          end if; -- end of - if not rupd.fagprv

       end if; -- end of - if (ret.wip_asset

       if not FA_GAINLOSS_UPD_PKG.fagpct(ret, bk, cpd_ctr, today,
                                                user_id, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_INSERT_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGPCT',
                  token2     => 'ACTION',
                  value2     => 'insert',
                  token3     => 'TYPE',
                  value3     => 'Cost',
                  token4     => 'ASSET',
                  value4     => ret.asset_number , p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       dpr.y_begin := bk.prorate_fy;
       dpr.y_end := bk.cpd_fiscal_year;

       if retpdnum = 1 then

          dpr.y_end := bk.cpd_fiscal_year - 1;
          retpdnum := bk.pers_per_yr;

       else

          retpdnum := retpdnum - 1;

       end if;

       if dpr.y_end < bk.prorate_fy then

          retpdnum := 0;                        /* Special value assigned */

       end if;

       if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, 'before calling fagurt', '', p_log_level_rec => p_log_level_rec);
       end if;

       if not FA_GAINLOSS_UPD_PKG.fagurt(ret, bk, cpd_ctr, dpr,
                                cost_frac, retpdnum,
                                today, user_id, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_INSERT_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGURT',
                  token2     => 'ACTION',
                  value2     => 'make',
                  token3     => 'TYPE',
                  value3     => 'table',
                  token4     => 'ASSET',
                  value4     => ret.asset_number , p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if; -- end of - if not rupd.fagurt

       if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, 'after calling fagurt', '', p_log_level_rec => p_log_level_rec);
       end if;


       if (bk.group_asset_id is not null) then
          -- +++++ Process Group Asse +++++
          if not FA_RETIREMENT_PVT.Do_Retirement_in_CGL(
                  p_ret                 => ret,
                  p_bk                  => bk,
                  p_dpr                 => dpr,
                  p_asset_deprn_rec_old => l_asset_deprn_rec_old,
                  p_mrc_sob_type_code   => ret.mrc_sob_type_code,
                  p_calling_fn          => l_calling_fn, p_log_level_rec => p_log_level_rec) then

             fa_srvr_msg.add_message(calling_fn => l_calling_fn,
                                  name       => 'FA_RET_INSERT_ERROR',
                                  token1     => 'MODULE',
                                  value1     => 'FA_RETIREMENT_PVT.Do_Retirement_in_CGL',
                                  token2     => 'ACTION',
                                  value2     => 'make',
                                  token3     => 'TYPE',
                                  value3     => 'table',
                                  token4     => 'ASSET',
                                  value4     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);
             return false;
          end if;
          -- Bug 5525968: start
          -- calculate group info
          if not FA_GAINLOSS_DPR_PKG.fagcdp(dpr_group, deprn_amt_group,
                             bonus_deprn_amt_group,
                             impairment_amt_group,
                             reval_deprn_amt_group,
                             reval_amort_group, bk_group.deprn_start_date,
                             bk_group.d_cal, bk_group.p_cal, start_pd, end_pd,
                             bk_group.prorate_fy, bk_group.dsd_fy, bk_group.prorate_jdate,
                             bk_group.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

             fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_RET_GENERIC_ERROR',
               token1     => 'MODULE',
               value1     => 'FAGCDP',
               token2     => 'INFO',
               value2     => 'depreciation number',
               token3     => 'ASSET',
               value3     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

             return(FALSE);

          end if;

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagret3.2.2', '', p_log_level_rec => p_log_level_rec); end if;

          -- Bug4343087:
          -- In order to find correct catchup amount without rounding
          -- error we need to find expense before retirement(before) and
          -- after retirement(after) and then subtract after amount from before.
          -- Following portion of code finds after amounts and then subtract
          -- before amount that is found in previous fagcdp call.
          if p_log_level_rec.statement_level then
             fa_debug_pkg.add (l_calling_fn, 'before group_deprn_amt', deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'before group_bonus_deprn_amt', bonus_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'before group_reval_deprn_amt', reval_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'before group_reval_amort', reval_amort_group, p_log_level_rec => p_log_level_rec);
          end if;

          -- Store before amount
          l_temp_deprn_amt       := deprn_amt_group;
          l_temp_bonus_deprn_amt := bonus_deprn_amt_group;
          l_temp_impairment_amt  := impairment_amt_group;
          l_temp_reval_deprn_amt := reval_deprn_amt_group;
          l_temp_reval_amort     := reval_amort_group;

          -- Get after fin ncial info for calling fagcdp
          if (ret.mrc_sob_type_code = 'R') then
             open c_get_new_mc_bk(ret_group.asset_id);
             fetch c_get_new_mc_bk into dpr_group.adj_cost
                                      , dpr_group.salvage_value
                                      , dpr_group.rec_cost
                                      , dpr_group.adj_rec_cost
                                      , dpr_group.reval_amo_basis
                                      , dpr_group.old_adj_cost;
             close c_get_new_mc_bk;
          else
             open c_get_new_bk(ret_group.asset_id);
             fetch c_get_new_bk into dpr_group.adj_cost
                                      , dpr_group.salvage_value
                                      , dpr_group.rec_cost
                                      , dpr_group.adj_rec_cost
                                      , dpr_group.reval_amo_basis
                                      , dpr_group.old_adj_cost;
             close c_get_new_bk;
          end if;

          -- fix for 4639408
          dpr_group.deprn_rsv := cost_frac * deprn_reserve;
          if not FA_UTILS_PKG.faxrnd(dpr_group.deprn_rsv
                                    ,ret_group.book
                                    ,ret.set_of_books_id
                                    ,p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;
          end if;
          dpr_group.deprn_rsv := deprn_reserve - dpr_group.deprn_rsv;
          -- end fix for 4639408

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add (l_calling_fn, 'calling function', 'FA_GAINLOSS_DPR_PKG.fagcdp', p_log_level_rec => p_log_level_rec);
          end if;

          -- Find new expense using after amounts
          if not FA_GAINLOSS_DPR_PKG.fagcdp(dpr_group, deprn_amt_group,
                             bonus_deprn_amt_group,
                             impairment_amt_group,
                             reval_deprn_amt_group,
                             reval_amort_group, bk_group.deprn_start_date,
                             bk_group.d_cal, bk_group.p_cal, start_pd, end_pd,
                             bk_group.prorate_fy, bk_group.dsd_fy, bk_group.prorate_jdate,
                             bk_group.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add (l_calling_fn, 'calling FA_GAINLOSS_DPR_PKG.fagcdp', 'FAILED', p_log_level_rec => p_log_level_rec);
             end if;

             fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_RET_GENERIC_ERROR',
               token1     => 'MODULE',
               value1     => 'FAGCDP',
               token2     => 'INFO',
               value2     => 'depreciation number',
               token3     => 'ASSET',
               value3     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

             return(FALSE);

          end if;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add (l_calling_fn, 'after group_deprn_amt', deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'after group_bonus_deprn_amt', bonus_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'after group_reval_deprn_amt', reval_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, 'after group_reval_amort', reval_amort_group, p_log_level_rec => p_log_level_rec);
          end if;

          -- Find catchup amount by subtracting before from after amounts.
          deprn_amt_group := l_temp_deprn_amt - deprn_amt_group;
          bonus_deprn_amt_group := l_temp_bonus_deprn_amt - bonus_deprn_amt_group;
          impairment_amt_group  := l_temp_impairment_amt - impairment_amt_group;
          reval_deprn_amt_group := l_temp_reval_deprn_amt - reval_deprn_amt_group;
          reval_amort_group     := l_temp_reval_amort - reval_amort_group;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add (l_calling_fn, '+ final group_deprn_amt', deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, '+ final group_bonus_deprn_amt', bonus_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, '+ final group_reval_deprn_amt', reval_deprn_amt_group, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add (l_calling_fn, '+ final group_reval_amort', reval_amort_group, p_log_level_rec => p_log_level_rec);
          end if;

          -- Set original value back in case subsequent calls
          -- are expecting before amounts
          dpr_group.adj_cost := bk_group.adjusted_cost;
          dpr_group.rec_cost := bk_group.recoverable_cost;
          dpr_group.reval_amo_basis := bk_group.reval_amort_basis;
          dpr_group.adj_rec_cost := bk_group.adj_rec_cost;
          dpr_group.salvage_value := bk_group.salvage_value;
          dpr_group.old_adj_cost := bk_group.old_adj_cost;

          if not FA_UTILS_PKG.faxrnd(x_amount => deprn_amt_group
                                    ,x_book   => ret.book
                                    ,x_set_of_books_id => ret.set_of_books_id
                                    , p_log_level_rec => p_log_level_rec) then
                                        return FALSE;
          end if;


          if not FA_UTILS_PKG.faxrnd(x_amount => bonus_deprn_amt_group
                                    ,x_book   => ret.book
                                    ,x_set_of_books_id => ret.set_of_books_id
                                    , p_log_level_rec => p_log_level_rec) then
                                        return FALSE;
          end if;

          if not FA_UTILS_PKG.faxrnd(x_amount => impairment_amt_group
                                    ,x_book   => ret.book
                                    ,x_set_of_books_id => ret.set_of_books_id
                                    , p_log_level_rec => p_log_level_rec) then
                                        return FALSE;
          end if;


          if not FA_UTILS_PKG.faxrnd(x_amount => reval_deprn_amt_group
                                    ,x_book   => ret.book
                                    ,x_set_of_books_id => ret.set_of_books_id
                                    , p_log_level_rec => p_log_level_rec) then
                                        return FALSE;
          end if;

          if not FA_UTILS_PKG.faxrnd(x_amount => reval_amort_group
                                    ,x_book   => ret.book
                                    ,x_set_of_books_id => ret.set_of_books_id
                                    , p_log_level_rec => p_log_level_rec) then
                                        return FALSE;
          end if;

          if bk.tracking_method is null then
              if p_log_level_rec.statement_level then
                   fa_debug_pkg.add (l_calling_fn, 'calling fagpdp 2', '', p_log_level_rec => p_log_level_rec);
              end if;
              if not FA_GAINLOSS_UPD_PKG.fagpdp(ret_group, bk_group, dpr_group, today,
                                    periods_catchup, cpd_ctr,
                                    cpdnum, cost_frac, deprn_amt_group,
                                    bonus_deprn_amt_group,
                                    impairment_amt_group, impairment_reserve_group,
                                    reval_deprn_amt_group, reval_amort_group,
                                    reval_reserve_group, user_id, p_log_level_rec => p_log_level_rec) then

                 fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_RET_INSERT_ERROR',
                      token1     => 'MODULE',
                      value1     => 'FAGPDP',
                      token2     => 'ACTION',
                      value2     => 'insert',
                      token3     => 'TYPE',
                      value3     => 'Depreciation',
                      token4     => 'ASSET',
                      value4     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

                 return(FALSE);

              end if;
          elsif bk.tracking_method = 'ALLOCATE' then
              if p_log_level_rec.statement_level then
                   fa_debug_pkg.add (l_calling_fn, 'calling fagpdp 3', '', p_log_level_rec => p_log_level_rec);
              end if;
              if not FA_GAINLOSS_UPD_PKG.fagpdp(ret_group, bk_group, dpr_group, today,
                                    periods_catchup, cpd_ctr,
                                    cpdnum, cost_frac, deprn_amt_group,
                                    bonus_deprn_amt_group,
                                    impairment_amt_group, impairment_reserve_group,
                                    reval_deprn_amt_group, reval_amort_group,
                                    reval_reserve_group, user_id, p_log_level_rec => p_log_level_rec) then

                 fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_RET_INSERT_ERROR',
                      token1     => 'MODULE',
                      value1     => 'FAGPDP',
                      token2     => 'ACTION',
                      value2     => 'insert',
                      token3     => 'TYPE',
                      value3     => 'Depreciation',
                      token4     => 'ASSET',
                      value4     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

                 return(FALSE);
              end if;

              if p_log_level_rec.statement_level then
                   fa_debug_pkg.add (l_calling_fn, 'calling fagpdp 4', '', p_log_level_rec => p_log_level_rec);
              end if;
              if not FA_GAINLOSS_UPD_PKG.fagpdp(ret, bk, dpr_group, today,
                                    periods_catchup, cpd_ctr,
                                    cpdnum, cost_frac, deprn_amt_group,
                                    bonus_deprn_amt_group,
                                    impairment_amt_group, impairment_reserve_group,
                                    reval_deprn_amt_group, reval_amort_group,
                                    reval_reserve_group, user_id, p_log_level_rec => p_log_level_rec) then

                 fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_RET_INSERT_ERROR',
                      token1     => 'MODULE',
                      value1     => 'FAGPDP',
                      token2     => 'ACTION',
                      value2     => 'insert',
                      token3     => 'TYPE',
                      value3     => 'Depreciation',
                      token4     => 'ASSET',
                      value4     => ret.asset_number , p_log_level_rec => p_log_level_rec);

                 return(FALSE);
              end if;

          elsif bk.tracking_method = 'CALCULATE' and bk.member_rollup_flag = 'N' then

              if p_log_level_rec.statement_level then
                   fa_debug_pkg.add (l_calling_fn, 'calling fagpdp 6', '', p_log_level_rec => p_log_level_rec);
              end if;
              if not FA_GAINLOSS_UPD_PKG.fagpdp(ret_group, bk_group, dpr_group, today,
                                    periods_catchup, cpd_ctr,
                                    cpdnum, cost_frac, deprn_amt_group,
                                    bonus_deprn_amt_group,
                                    impairment_amt_group, impairment_reserve_group,
                                    reval_deprn_amt_group, reval_amort_group,
                                    reval_reserve_group, user_id, p_log_level_rec => p_log_level_rec) then

                 fa_srvr_msg.add_message(
                      calling_fn => l_calling_fn,
                      name       => 'FA_RET_INSERT_ERROR',
                      token1     => 'MODULE',
                      value1     => 'FAGPDP',
                      token2     => 'ACTION',
                      value2     => 'insert',
                      token3     => 'TYPE',
                      value3     => 'Depreciation',
                      token4     => 'ASSET',
                      value4     => ret_group.asset_number , p_log_level_rec => p_log_level_rec);

                 return(FALSE);
              end if;

          end if; --if (bk.tracking_method */
          -- Bug 5525968: end
       end if; -- (bk.group_asset_id is not null)

       return(TRUE);

    EXCEPTION

          when others then
             fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;


    END FAGRET;





END FA_GAINLOSS_RET_PKG;    -- End of Package EFA_RRET

/
