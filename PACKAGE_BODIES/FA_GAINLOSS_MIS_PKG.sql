--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_MIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_MIS_PKG" AS
/* $Header: fagmisb.pls 120.14.12010000.3 2009/07/19 13:56:02 glchen ship $*/

/*============================================================================
|  NAME         faggfy                                                       |
|                                                                            |
|  FUNCTION     It returns the fiscal year, prorate_calendar, prorate_periods|
|               per_year through the input parameter 'xdate"                 |
|                                                                            |
|  HISTORY      1/12/89         R Rumanang      Created                      |
|               08/09/90        M Chan          Modified for MPL 8           |
|               01/08/97        S Behura        Rewrote into PL/SQL          |
|===========================================================================*/

FUNCTION faggfy(xdate in date,
                p_cal in out nocopy varchar2,
                pro_month in out nocopy number,
                fiscalyr in out nocopy number,
                fiscal_year_name in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                        RETURN BOOLEAN IS

    faggfy_err          exception;

    dummy               number;
    jxdate              number;

    l_calling_fn        varchar2(40) := 'fa_gainloss_mis_pkg.faggfy';

    BEGIN <<FAGGFY>>

       jxdate := to_char(xdate, 'J');

       if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name, jxdate,
                                        pro_month,
                                        fiscalyr, dummy, p_log_level_rec => p_log_level_rec) then

          -- get retirement period number in fazccp
          fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_PROD_INCORRECT_DATE', p_log_level_rec => p_log_level_rec);

          raise faggfy_err;

       end if;

       return(TRUE);

       EXCEPTION

         when faggfy_err then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

         when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGGFY;


/*===========================================================================
|  NAME         fagpdi                                                      |
|                                                                           |
|  FUNCTION     Return period information based on the deprn_calendar and   |
|               prorate_calendar                                            |
|                                                                           |
|  HISTORY      01/12/89        R Rumanang      Created                     |
|               06/23/89        R Rumanang      Standarized                 |
|               08/21/90        M Chan          return p_pds_per_year       |
|               04/04/91        M Chan          restructure the function    |
|               01/09/97        S Behura        Rewrote in PL/SQL           |
|===========================================================================*/

Function fagpdi(book_type in varchar2, pds_per_year_ptr in out nocopy number,
                period_type in out nocopy varchar2, cpdname in varchar2,
                cpdnum in out nocopy number, ret_p_date in out date,
                ret_pd in out nocopy number, p_pds_per_year_ptr in out number,
                fiscal_year_name in out nocopy varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS

    fagpdi_err          exception;

    dummy               number;
    ret_p_jdate         number;
    fiscal_year         number;

    h_book_type         varchar2(30);
    h_period_type       varchar2(15);
    h_cpdnum            number;
    h_cpdname           varchar2(16);
    h_pds_per_year      integer;
    h_p_pds_per_year    integer;

    l_calling_fn        varchar2(40) := 'fa_gainloss_mis_pkg.fagpdi';

    BEGIN <<FAGPDI>>

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagpdi 1', '', p_log_level_rec => p_log_level_rec); end if;

       h_book_type := book_type;
       h_cpdname := cpdname;

       -- Get number of periods per year

       SELECT
                d_cal.number_per_fiscal_year,
                p_cal.number_per_fiscal_year,
                bc.deprn_calendar
       INTO
                h_pds_per_year,
                h_p_pds_per_year,
                h_period_type
       FROM
                fa_calendar_types d_cal,
                fa_calendar_types p_cal,
                fa_book_controls  bc
       WHERE
                bc.deprn_calendar = d_cal.calendar_type
       AND
                bc.prorate_calendar = p_cal.calendar_type
       AND
                bc.book_type_code = h_book_type;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagpdi 2', '', p_log_level_rec => p_log_level_rec); end if;

       period_type := h_period_type;

       -- Get current period number

       SELECT  fadp.period_num
       INTO    h_cpdnum
       FROM    fa_deprn_periods fadp
       WHERE   fadp.book_type_Code = h_book_type
       AND     fadp.period_name = h_cpdname;

       ret_p_jdate := to_char(ret_p_date, 'J');

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagpdi 3', '', p_log_level_rec => p_log_level_rec); end if;

       if not fa_cache_pkg.fazccp(period_type, fiscal_year_name,
                                ret_p_jdate,
                                   ret_pd, fiscal_year, dummy, p_log_level_rec => p_log_level_rec) then

          -- get retirement period number in fazccp
          fa_srvr_msg.add_message(
               calling_fn => l_calling_fn,
               name       => 'FA_PROD_INCORRECT_DATE', p_log_level_rec => p_log_level_rec);

          raise fagpdi_err;

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagpdi 4', '', p_log_level_rec => p_log_level_rec); end if;

       pds_per_year_ptr := h_pds_per_year;
       p_pds_per_year_ptr := h_p_pds_per_year;
       cpdnum := h_cpdnum;

       return(TRUE);

       EXCEPTION

         when fagpdi_err then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

         when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGPDI;


/*===========================================================================
|  NAME         faggbi                                                      |
|                                                                           |
|  FUNCTION     Returns book information based on a retirement-id           |
|                                                                           |
|  HISTORY      1/12/89         R Rumanang      Created                     |
|               6/23/89         R Rumanang      Standarized                 |
|               7/11/89         R Rumanang      Fixed a bug in getting      |
|                                               prorate date. There maybe   |
|                                               possible to have 2 rows     |
|                                               for calendar type year.     |
|               8/8/90          M Chan          Add prorate calendar        |
|               04/02/91        M Chan          Rewrite the routine         |
|               01/09/97        S Behura        Rewrote in PL/SQL           |
|               08/09/97        S Behura        Converted to 10.7 PL/SQL    |
|===========================================================================*/

FUNCTION faggbi(bk in out nocopy fa_ret_types.book_struct,
                ret in out nocopy fa_ret_types.ret_struct, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS

    faggbi_err          exception;

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
    -- Bug 6660490 Japan Phase3 bug
    h_fully_extended              integer;
    h_pc_fully_extended           number;
    h_extended_flag               integer;

    -- Bug 8211842
    h_pc_extended                 number;
    h_current_pc                  number;

    l_calling_fn        varchar2(40) := 'fa_gainloss_mis_pkg.faggbi';

    BEGIN <<FAGGBI>>

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 1', '', p_log_level_rec => p_log_level_rec); end if;
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


    /* To calculate the prorate date based on the date_retired, you need to
       run the date_retired through the prorate convention logic */

       /*
       if p_log_level_rec.statement_level then
       end if;
       */

       if (ret.mrc_sob_type_code <> 'R') then

          SELECT
                decode(m.depreciate_lastyear_flag,'YES',1,0),
                nvl(book.life_in_months,0),
                decode(book.capitalize_flag, 'YES', 1, 0),
                decode(book.depreciate_flag, 'YES', 1, 0),
                decode(book.period_counter_fully_reserved, null, 0, 1),
                nvl(book.itc_amount_id, 0),
                ah.units,
                bc.current_fiscal_year,
                bc.distribution_source_book,
                book.rate_adjustment_factor,
                nvl(book.adjusted_rate,0),
                book.adjusted_cost,
                book.cost,
                book.recoverable_cost,
                book.itc_amount,
                nvl(book.salvage_value,0),
                trunc(book.prorate_date),
                to_number(to_char(book.prorate_date, 'J')),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                      trunc(book.deprn_start_date), trunc(book.prorate_date)),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                       to_number(to_char(book.deprn_start_date, 'J')),
                       to_number(to_char(book.prorate_date, 'J'))),
                trunc(book.date_placed_in_service),
                to_number(to_char(book.date_placed_in_service, 'J')),
                bc.prorate_calendar,
                m.method_code,
                decode(bc.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                conv.prorate_date,
                trunc(bc.initial_date),
                bc.deprn_calendar,
                nvl(book.ceiling_name, null),
                nvl(book.bonus_rule, null),
                decode(m.rate_source_rule, 'CALCULATED', 1, 'TABLE', 2,
                       'FLAT', 3),
                decode(m.deprn_basis_rule, 'COST', 1, 'NBV', 2),
                decode(bc.book_class, 'TAX', 1, 0),
                decode(ah.asset_type, 'CIP', 1, 0),
                decode(ctype.depr_when_acquired_flag,'YES',1,0),
                nvl(book.reval_amortization_basis,0),
                book.unrevalued_cost,
                nvl(book.adjusted_capacity,0),
                nvl(book.production_capacity,0),
                bc.fiscal_year_name,
                nvl (book.adjusted_recoverable_cost, book.recoverable_cost),
                decode(book.annual_deprn_rounding_flag, NULL, 0, 'ADD', 1,
                       'ADJ', 2, 'RET', 3, 'REV', 4, 'TFR', 5,'RES', 6, 'OVE', 7, -1),
                nvl(book.short_fiscal_year_flag, 'NO'),
                book.conversion_date,
                book.original_deprn_start_date,
                nvl(book.old_adjusted_cost, 1),
                nvl(book.formula_factor, 1),
                book.allowed_deprn_limit_amount,
                book.group_asset_id,
                book.recognize_gain_loss,
                book.recapture_reserve_flag,
                book.limit_proceeds_flag,
                book.terminal_gain_loss,
                book.tracking_method,
                book.exclude_fully_rsv_flag,
                book.excess_allocation_option,
                book.depreciation_option,
                book.member_rollup_flag,
                book.ltd_proceeds,
                book.allocate_to_fully_rsv_flag,
                book.allocate_to_fully_ret_flag,
                book.eofy_reserve,
                book.cip_cost,
                book.ltd_cost_of_removal,
                book.prior_eofy_reserve,
                book.eop_adj_cost,
                book.eop_formula_factor,
                book.exclude_proceeds_from_basis,
                book.retirement_deprn_option,
                book.terminal_gain_loss_amount,
                book.period_counter_fully_reserved,
                decode(book.period_counter_fully_extended, null, 0, 1),
                book.period_counter_fully_extended,
                decode(book.extended_deprn_flag,'Y', 1, 0),
                book.extended_depreciation_period,
                bc.last_period_counter + 1
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
                h_fully_extended,    -- Bug 6660490
                h_pc_fully_extended, -- Bug 6660490
                h_extended_flag,     -- Bug 6660490
                h_pc_extended,       -- Bug 8211842
                h_current_pc         -- Bug 8211842
          FROM
                fa_books                book,
                fa_methods              m,
                fa_conventions          conv,
                fa_convention_types     ctype,
                fa_book_controls        bc,
                fa_asset_history        ah
          WHERE
                book.retirement_id = h_retirement_id
          AND   book.asset_id = h_asset_id
          AND   book.book_type_code = h_book
          AND   book.deprn_method_code = m.method_code
          AND   nvl(book.life_in_months,1) = nvl(m.life_in_months,1)
          AND
                bc.book_type_code = h_book
          AND
                ah.asset_id = h_asset_id
          AND
                book.transaction_header_id_out <=
                nvl(ah.transaction_header_id_out,
                book.transaction_header_id_out)
          AND
                book.transaction_header_id_out >
                ah.transaction_header_id_in
          AND   trunc(h_date_retired) between
                conv.start_date and conv.end_date
          AND   h_ret_p_conv = conv.prorate_convention_code
          AND   ctype.prorate_convention_code = h_ret_p_conv;

       else

          SELECT
                decode(m.depreciate_lastyear_flag,'YES',1,0),
                nvl(book.life_in_months,0),
                decode(book.capitalize_flag, 'YES', 1, 0),
                decode(book.depreciate_flag, 'YES', 1, 0),
                decode(book.period_counter_fully_reserved, null, 0, 1),
                nvl(book.itc_amount_id, 0),
                ah.units,
                bc.current_fiscal_year,
                bc_primary.distribution_source_book,
                book.rate_adjustment_factor,
                nvl(book.adjusted_rate,0),
                book.adjusted_cost,
                book.cost,
                book.recoverable_cost,
                book.itc_amount,
                nvl(book.salvage_value,0),
                trunc(book.prorate_date),
                to_number(to_char(book.prorate_date, 'J')),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                      trunc(book.deprn_start_date), trunc(book.prorate_date)),
                decode(instr(m.rate_source_rule, 'CALCULATED'), 0,
                       to_number(to_char(book.deprn_start_date, 'J')),
                       to_number(to_char(book.prorate_date, 'J'))),
                trunc(book.date_placed_in_service),
                to_number(to_char(book.date_placed_in_service, 'J')),
                bc_primary.prorate_calendar,
                m.method_code,
                decode(bc_primary.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                conv.prorate_date,
                trunc(bc_primary.initial_date),
                bc_primary.deprn_calendar,
                nvl(book.ceiling_name, null),
                nvl(book.bonus_rule, null),
                decode(m.rate_source_rule, 'CALCULATED', 1, 'TABLE', 2,
                       'FLAT', 3),
                decode(m.deprn_basis_rule, 'COST', 1, 'NBV', 2),
                decode(bc_primary.book_class, 'TAX', 1, 0),
                decode(ah.asset_type, 'CIP', 1, 0),
                decode(ctype.depr_when_acquired_flag,'YES',1,0),
                nvl(book.reval_amortization_basis,0),
                book.unrevalued_cost,
                nvl(book.adjusted_capacity,0),
                nvl(book.production_capacity,0),
                bc_primary.fiscal_year_name,
                nvl (book.adjusted_recoverable_cost, book.recoverable_cost),
                decode(book.annual_deprn_rounding_flag, NULL, 0, 'ADD', 1,
                       'ADJ', 2, 'RET', 3, 'REV', 4, 'TFR', 5,'RES', 6, 'OVE', 7, -1),
                nvl(book.short_fiscal_year_flag, 'NO'),
                book.conversion_date,
                book.original_deprn_start_date,
                nvl(book.old_adjusted_cost, 1),
                nvl(book.formula_factor, 1),
                book.allowed_deprn_limit_amount,
                book.group_asset_id,
                book.recognize_gain_loss,
                book.recapture_reserve_flag,
                book.limit_proceeds_flag,
                book.terminal_gain_loss,
                book.tracking_method,
                book.exclude_fully_rsv_flag,
                book.excess_allocation_option,
                book.depreciation_option,
                book.member_rollup_flag,
                book.ltd_proceeds,
                book.allocate_to_fully_rsv_flag,
                book.allocate_to_fully_ret_flag,
                book.eofy_reserve,
                book.cip_cost,
                book.ltd_cost_of_removal,
                book.prior_eofy_reserve,
                book.eop_adj_cost,
                book.eop_formula_factor,
                book.exclude_proceeds_from_basis,
                book.retirement_deprn_option,
                book.terminal_gain_loss_amount,
                book.period_counter_fully_reserved
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
                fa_methods              m,
                fa_conventions          conv,
                fa_convention_types     ctype,
                fa_mc_book_controls     bc,
                fa_book_controls        bc_primary,
                fa_asset_history        ah
          WHERE
                book.retirement_id = h_retirement_id
          AND   book.asset_id = h_asset_id
          AND   book.book_type_code = h_book
          AND   book.deprn_method_code = m.method_code
          AND   nvl(book.life_in_months,1) = nvl(m.life_in_months,1)
          AND
                bc.book_type_code = h_book
          AND
                ah.asset_id = h_asset_id
          AND
                book.transaction_header_id_out <=
                nvl(ah.transaction_header_id_out,
                book.transaction_header_id_out)
          AND
                book.transaction_header_id_out >
                ah.transaction_header_id_in
          AND   trunc(h_date_retired) between
                conv.start_date and conv.end_date
          AND   h_ret_p_conv = conv.prorate_convention_code
          AND   book.set_of_books_id = ret.set_of_books_id
          AND   bc.set_of_books_id = ret.set_of_books_id
          AND   bc_primary.book_type_code = bc.book_type_code
          AND   ctype.prorate_convention_code = h_ret_p_conv;

       end if;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 2', '', p_log_level_rec => p_log_level_rec); end if;

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

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 3', '', p_log_level_rec => p_log_level_rec); end if;


    /* For asset with convention code that the */
    /* "DEPRECIATE_WHEN_ACQUIRED_FLAG = 'YES' and in its first fiscal year,
       and the method is not STL, then use the use the date retired and
       not the retirement prorate date  ; Changed made after the discussion
       with Dave and Gregg - 9/10/91 */
    /* Removed after discussion with Dave, no longer works with the */
    /* current model. -Steve */

--    if(h_same_fy and h_dwacq and (h_rate_source_rule <> 1)) {
--        DISCARD NLSSCPY((text *) h_ret_prorate_date.arr,
--                       (text *) h_date_retired.arr);
--        h_ret_prorate_date.len = h_date_retired.len;
--    }

    /* Note 2 : If the deprn method is flat rate, just make sure the join to */
    /* life_in_months always return TRUE */

       /*
       if p_log_level_rec.statement_level then
             -- Retirement Fiscal Year
       end if;
       */

       SELECT   FISCAL.FISCAL_YEAR
       INTO     h_ret_fiscalyr
       FROM     FA_FISCAL_YEAR FISCAL
       WHERE    trunc(h_ret_prorate_date)
                between START_DATE and END_DATE
       AND      fiscal_year_name = h_fiscal_year_name;

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 4', '', p_log_level_rec => p_log_level_rec); end if;

       if (h_ret_fiscalyr <> h_cpd_fiscal_year) then

          if h_ret_fiscalyr < h_cpd_fiscal_year then
             h_period_num := 1;
          else h_period_num := 0;
          end if;

          /*
          if p_log_level_rec.statement_level then
               -- Retirement Prorate Date
          end if;
          */

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

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 5', '', p_log_level_rec => p_log_level_rec); end if;

    /* Note 1 :
        If the retirement prorate-date is less than the prorate date
        we need to calculate GL adjusment based on the prorate date. Thus, the
        retirement prorate date is the prorate date

    */

       if h_rate_source_rule <> 1 then  -- rate_source_rule <> 'CALCULATED'
       /* Need the following condition for fix to bug 712568. Not all
          periods deprecition expense was getting backed out nocopy because
          retirement prorate date was not getting set correctly when the
          asset was retired in first year and Depreciate When Retired in
          First Year was set to No in Book Controls. To back out all the
          periods we have to get the period in which we started to allocate
          depreciation
       */

      if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 6', '', p_log_level_rec => p_log_level_rec); end if;
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
            fa_debug_pkg.add(l_calling_fn, 'in faggbi 7', '', p_log_level_rec => p_log_level_rec);
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

       --Bug7414920
       --Bug8288367. The previous bug take care of only previous month convention dates.
       --I added code for following month convention also.
       if ( h_group_asset_id is  not null ) then

            begin
             SELECT     h_date_retired
             INTO       h_ret_prorate_date
             from       fa_deprn_periods
             where      book_type_code = h_book
             and        period_close_date is null
             and        (h_ret_prorate_date < calendar_period_open_date or h_ret_prorate_date > calendar_period_close_date);
            exception
                when no_data_found then
                     null;
            end;
       end if;
         --End of changes for bug7414920

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add(l_calling_fn, 'Final h_ret_prorate_date', to_char(h_ret_prorate_date));
          fa_debug_pkg.add(l_calling_fn, 'in faggbi 8', '', p_log_level_rec => p_log_level_rec);
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

       if h_fully_reserved > 0 then
          bk.fully_reserved := TRUE;
       else
          bk.fully_reserved := FALSE;
       end if;

       -- Bug 6660490 new variables for
       -- extended deprn
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
       -- Bug 6660490 end

       -- Bug 8211842 : Check if asset has started extended depreciation
       if h_current_pc >= h_pc_extended  then
          bk.start_extended := TRUE;
       else
          bk.start_extended := FALSE;
       end if;
       bk.pc_extended := h_pc_extended ;
       -- Bug 8211842

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

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in faggbi 100', '', p_log_level_rec => p_log_level_rec); end if;

       return(TRUE);

       EXCEPTION

         when faggbi_err then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

         when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGGBI;

END FA_GAINLOSS_MIS_PKG;    -- End of Package EFA_RMIS

/
