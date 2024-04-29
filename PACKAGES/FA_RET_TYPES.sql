--------------------------------------------------------
--  DDL for Package FA_RET_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RET_TYPES" AUTHID CURRENT_USER as
/* $Header: fartypes.pls 120.5.12010000.3 2009/07/19 10:53:47 glchen ship $*/

/*********  For RETIREMENT Processes ****************************/
FA_DPR_DETAIL_SIZE CONSTANT NUMBER := 10;

/***************************************************
Structures needed for gain/loss program
***************************************************/
TYPE ret_struct is RECORD(
  retirement_id          FA_RETIREMENTS.retirement_id%type,
  asset_id               FA_RETIREMENTS.asset_id%type,
  units_retired          FA_RETIREMENTS.units%type,
  stl_life               FA_RETIREMENTS.stl_life_in_months%type,
  itc_recapid            FA_RETIREMENTS.itc_recapture_id%type,
  th_id_in               FA_RETIREMENTS.transaction_header_id_in%type,
  stl_method_code        FA_RETIREMENTS.stl_method_code%type,
  status                 FA_RETIREMENTS.status%type,
  wip_asset              INTEGER,
  cost_retired           FA_RETIREMENTS.cost_retired%type,
  rsv_retired            NUMBER,
  reval_rsv_retired      FA_RETIREMENTS.reval_reserve_retired%type,
  proceeds_of_sale       FA_RETIREMENTS.proceeds_of_sale%type,
  cost_of_removal        FA_RETIREMENTS.cost_of_removal%type,
  asset_number           FA_ADDITIONS.asset_number%type,
  date_retired           FA_RETIREMENTS.date_retired%type,
  prorate_convention     FA_RETIREMENTS.retirement_prorate_convention%type,
  date_effective         FA_RETIREMENTS.date_effective%type,
  book                   FA_RETIREMENTS.book_type_code%type,
  dpr_evenly             NUMBER,
  retirement_type_code   fa_retirements.retirement_type_code%type,
  gain_loss_amount       number,
  bonus_rsv_retired      number,
  impair_rsv_retired     number,
  recognize_gain_loss    FA_RETIREMENTS.recognize_gain_loss%type,
  recapture_reserve_flag FA_RETIREMENTS.recapture_reserve_flag%type,
  limit_proceeds_flag    FA_RETIREMENTS.limit_proceeds_flag%type,
  terminal_gain_loss     FA_RETIREMENTS.terminal_gain_loss%type,
  reduction_rate         FA_RETIREMENTS.reduction_rate%type,
  eofy_reserve           FA_RETIREMENTS.eofy_reserve%type,
  recapture_amount       FA_RETIREMENTS.recapture_amount%type,
  reserve_retired        FA_RETIREMENTS.reserve_retired%type,
  mrc_sob_type_code      varchar2(1),
  set_of_books_id        FA_BOOK_CONTROLS.set_of_books_id%type
);

TYPE book_struct is RECORD(
    lifemonths               FA_BOOKS.life_in_months%type,
    prorate_mth              NUMBER,
    prorate_fy               NUMBER,
    dsd_mth                  NUMBER,
    dsd_fy                   NUMBER,
    itc_used                 FA_BOOKS.itc_basis%type,
    rate_source_rule         INTEGER,
    deprn_basis_rule         INTEGER,
    cur_units                FA_ADDITIONS.current_units%type,
    jdis                     NUMBER,
    prorate_jdate            NUMBER,
    deprn_start_jdate        NUMBER,
    pers_per_yr              NUMBER,
    cpd_fiscal_year          FA_BOOK_CONTROLS.current_fiscal_year%type,
    ret_fiscal_year          NUMBER,
    method_code              FA_METHODS.method_code%type,
    raf                      FA_BOOKS.rate_adjustment_factor%type,
    adj_rate                 FA_BOOKS.adjusted_rate%type,
    adjusted_cost            FA_BOOKS.adjusted_cost%type,
    current_cost             FA_BOOKS.cost%type,
    recoverable_cost         FA_BOOKS.recoverable_cost%type,
    salvage_value            FA_BOOKS.salvage_value%type,
    itc_amount               FA_BOOKS.itc_amount%type,
    capitalize               BOOLEAN,
    depreciate               BOOLEAN,
    fully_reserved           BOOLEAN,
    depreciate_lastyr        BOOLEAN,
    book_class               BOOLEAN,
    prorate_date             FA_BOOKS.prorate_date%type,
    deprn_start_date         FA_BOOKS.deprn_start_date%type,
    date_in_srv              FA_BOOKS.date_placed_in_service%type,
    p_cal                    FA_BOOK_CONTROLS.prorate_calendar%type,
    d_cal                    FA_BOOK_CONTROLS.deprn_calendar%type,
    ret_prorate_date         FA_CONVENTIONS.prorate_date%type,
    dis_book                 FA_BOOK_CONTROLS.distribution_source_book%type,
    ceiling_name             FA_BOOKS.ceiling_name%type,
    bonus_rule               FA_BOOKS.bonus_rule%type,
    reval_amort_basis        FA_BOOKS.reval_amortization_basis%type,
    unrevalued_cost          FA_BOOKS.unrevalued_cost%type,
    adj_capacity             FA_BOOKS.adjusted_capacity%type,
    capacity                 FA_BOOKS.production_capacity%type,
    fiscal_year_name         FA_BOOK_CONTROLS.fiscal_year_name%type,
    adj_rec_cost             number,
    deprn_rounding_flag      integer,
                                        /* FA_BOOKS.ANNUAL_DEPRN_ROUNDING_FLAG */
                                        /* NULL->0, 'ADD'->1, 'ADJ'->2  */
                                        /* 'RET'->3, 'REV'->4, 'TRF'->5 */
                                        /* Others->-1                   */
    short_fiscal_year_flag    FA_BOOKS.short_fiscal_year_flag%type,
    conversion_date           FA_BOOKS.conversion_date%type,
    orig_deprn_start_date     FA_BOOKS.original_deprn_start_date%type,
    formula_factor            FA_BOOKS.formula_factor%type,
    old_adj_cost              FA_BOOKS.old_adjusted_cost%type,
    allowed_deprn_limit_amount FA_BOOKS.allowed_deprn_limit_amount%type,
    group_asset_id            FA_BOOKS.group_asset_id%type,
    recognize_gain_loss       FA_BOOKS.RECOGNIZE_GAIN_LOSS%TYPE,
    recapture_reserve_flag    FA_BOOKS.RECAPTURE_RESERVE_FLAG%TYPE,
    limit_proceeds_flag       FA_BOOKS.LIMIT_PROCEEDS_FLAG%TYPE,
    terminal_gain_loss        FA_BOOKS.TERMINAL_GAIN_LOSS%TYPE,
    tracking_method           FA_BOOKS.TRACKING_METHOD%TYPE,
    exclude_fully_rsv_flag    FA_BOOKS.EXCLUDE_FULLY_RSV_FLAG%TYPE,
    excess_allocation_option  FA_BOOKS.EXCESS_ALLOCATION_OPTION%TYPE,
    depreciation_option       FA_BOOKS.DEPRECIATION_OPTION%TYPE,
    member_rollup_flag        FA_BOOKS.MEMBER_ROLLUP_FLAG%TYPE,
    ltd_proceeds                FA_BOOKS.LTD_PROCEEDS%TYPE,
    allocate_to_fully_rsv_flag  FA_BOOKS.ALLOCATE_TO_FULLY_RSV_FLAG%TYPE,
    allocate_to_fully_ret_flag  FA_BOOKS.ALLOCATE_TO_FULLY_RET_FLAG%TYPE,
    eofy_reserve                FA_BOOKS.EOFY_RESERVE%TYPE,
    cip_cost                    FA_BOOKS.CIP_COST%TYPE,
    ltd_cost_of_removal         FA_BOOKS.LTD_COST_OF_REMOVAL%TYPE,
    prior_eofy_reserve          FA_BOOKS.PRIOR_EOFY_RESERVE%TYPE,
    eop_adj_cost                FA_BOOKS.EOP_ADJ_COST%TYPE,
    eop_formula_factor          FA_BOOKS.EOP_FORMULA_FACTOR%TYPE,
    exclude_proceeds_from_basis FA_BOOKS.EXCLUDE_PROCEEDS_FROM_BASIS%TYPE,
    retirement_deprn_option     FA_BOOKS.RETIREMENT_DEPRN_OPTION%TYPE,
    terminal_gain_loss_amount   FA_BOOKS.terminal_gain_loss_amount%type,
    adjusted_recoverable_cost	NUMBER,
    pc_fully_reserved           NUMBER,
    depr_first_year_ret         NUMBER,
    fully_extended              BOOLEAN,  -- Bug 6660490
    pc_fully_extended           NUMBER,   -- Bug 6660490
    extended_flag               BOOLEAN,  -- Bug 6660490
    pc_extended                 NUMBER,   -- Bug 8211842
    start_extended              BOOLEAN   -- Bug 8211842
);

TYPE dpr_detail_struct IS RECORD(
    dist_id             fa_std_types.number_tbl_type,
    ccid                fa_std_types.number_tbl_type,
    deprn_amount        fa_std_types.number_tbl_type,
    adj_amount          fa_std_types.number_tbl_type,
    annualized_adj      fa_std_types.number_tbl_type
);

END FA_RET_TYPES;

/
