--------------------------------------------------------
--  DDL for Package FA_AMORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_AMORT_PVT" AUTHID CURRENT_USER as
/* $Header: FAVAMRTS.pls 120.7.12010000.2 2009/07/19 11:37:29 glchen ship $ */

  --
  -- Datatypes for pl/sql tables below
  --
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  --
  -- PL/SQL tables used in package body as well as FA_CDE_PKG.faxcde
  --
  t_period_counter              tab_num15_type;
  t_fiscal_year                 tab_num15_type;
  t_period_num                  tab_num15_type;
  t_calendar_period_open_date   tab_date_type;
  t_calendar_period_close_date  tab_date_type;
  t_reset_adjusted_cost_flag    tab_char1_type;
  t_change_in_cost              tab_num_type;
  t_change_in_cip_cost          tab_num_type;
  t_cost                        tab_num_type;
  t_cip_cost                    tab_num_type;
  t_salvage_type                tab_char30_type;
  t_percent_salvage_value       tab_num_type;
  t_salvage_value               tab_num_type;
  t_member_salvage_value        tab_num_type;
  t_recoverable_cost            tab_num_type;
  t_deprn_limit_type            tab_char30_type;
  t_allowed_deprn_limit         tab_num_type;
  t_allowed_deprn_limit_amount  tab_num_type;
  t_member_deprn_limit_amount   tab_num_type;
  t_adjusted_recoverable_cost   tab_num_type;
  t_adjusted_cost               tab_num_type;
  t_depreciate_flag             tab_char3_type;
  t_date_placed_in_Service      tab_date_type;
  t_deprn_method_code           tab_char15_type;
  t_life_in_months              tab_num_type;
  t_rate_adjustment_factor      tab_num_type;
  t_adjusted_rate               tab_num_type;
  t_bonus_rule                  tab_char30_type;
  t_adjusted_capacity           tab_num_type;
  t_production_capacity         tab_num_type;
  t_unit_of_measure             tab_char30_type;
  t_remaining_life1             tab_num15_type;
  t_remaining_life2             tab_num15_type;
  t_old_adjusted_cost           tab_num_type;
  t_formula_factor              tab_num_type;
  t_unrevalued_cost             tab_num_type;
  t_reval_amortization_basis    tab_num_type;
  t_reval_ceiling               tab_num_type;
  t_ceiling_name                tab_char30_type;
  t_eofy_adj_cost               tab_num_type;
  t_eofy_formula_factor         tab_num_type;
  t_eofy_reserve                tab_num_type;
  t_prior_eofy_reserve          tab_num_type;
  t_eop_adj_cost                tab_num_type;
  t_eop_formula_factor          tab_num_type;
  t_short_fiscal_year_flag      tab_char3_type;
  t_group_asset_id              tab_num15_type;
  t_super_group_id              tab_num15_type;
  t_over_depreciate_option      tab_char30_type;

  t_deprn_amount                tab_num_type;
  t_ytd_deprn                   tab_num_type;
  t_deprn_reserve               tab_num_type;
  t_bonus_deprn_amount          tab_num_type;
  t_bonus_ytd_deprn             tab_num_type;
  t_bonus_deprn_reserve         tab_num_type;
  t_bonus_rate                  tab_num_type;
  t_impairment_amount           tab_num_type;
  t_ytd_impairment              tab_num_type;
  t_impairment_reserve          tab_num_type;
  t_ltd_production              tab_num_type;
  t_ytd_production              tab_num_type;
  t_production                  tab_num_type;
  t_reval_amortization          tab_num_type;
  t_reval_deprn_expense         tab_num_type;
  t_reval_reserve               tab_num_type;
  t_ytd_reval_deprn_expense     tab_num_type;
  t_prior_fy_expense            tab_num_type;
  t_prior_fy_bonus_expense      tab_num_type;
  t_deprn_override_flag         tab_char1_type;
  t_system_deprn_amount         tab_num_type;
  t_system_bonus_deprn_amount   tab_num_type;
  t_ytd_proceeds_of_sale        tab_num_type;
  t_ltd_proceeds_of_sale        tab_num_type;
  t_ytd_cost_of_removal         tab_num_type;
  t_ltd_cost_of_removal         tab_num_type;
  t_deprn_adjustment_amount     tab_num_type;
  t_expense_adjustment_amount   tab_num_type;
  t_reserve_adjustment_amount   tab_num_type;
  t_change_in_eofy_reserve      tab_num_type;
  t_capitalized_flag            tab_char1_type;
  t_unplanned_amount            tab_num_type;
  t_fully_reserved_flag         tab_char1_type;
  t_fully_retired_flag          tab_char1_type;
  t_life_complete_flag          tab_char1_type;

  tmd_period_counter            tab_num15_type;
  tmd_cost                      tab_num_type;
  tm_cost                       tab_num_type;
  tmd_cip_cost                  tab_num_type;
  tm_cip_cost                   tab_num_type;
  tmd_salvage_value             tab_num_type;
  tm_salvage_value              tab_num_type;
  tmd_deprn_limit_amount        tab_num_type;
  tm_deprn_limit_amount         tab_num_type;

---------------------------------------------------------------------
--
-- Procedure Name: initMemberTable
--
--
-- Description
--
--------------------------------------------------------------------
PROCEDURE initMemberTable;


 ---------------------------------------------------------------------
 --
 -- Function Name:    faxama
 --
 --
 -- Description
 --
 --------------------------------------------------------------------

FUNCTION faxama
         (px_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec                      FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec                     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec                      FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec                     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old                  FA_API_TYPES.asset_fin_rec_type,
          p_asset_fin_rec_adj                  FA_API_TYPES.asset_fin_rec_type default null,
          px_asset_fin_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec                    FA_API_TYPES.asset_deprn_rec_type,
          p_asset_deprn_rec_adj                FA_API_TYPES.asset_deprn_rec_type default null,
          p_period_rec                         FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code                  VARCHAR2,
          p_running_mode                       NUMBER,
          p_used_by_revaluation                NUMBER,
          p_reclassed_asset_id                 NUMBER default null,
          p_reclass_src_dest                   VARCHAR2 default null,
          p_reclassed_asset_dpis               DATE default null,
          p_update_books_summary               BOOLEAN default FALSE,
          p_proceeds_of_sale                   NUMBER default 0,
          p_cost_of_removal                    NUMBER default 0,
          x_deprn_exp               OUT NOCOPY NUMBER,
          x_bonus_deprn_exp         OUT NOCOPY NUMBER,
          x_impairment_exp          OUT NOCOPY NUMBER,
          x_deprn_rsv               OUT NOCOPY NUMBER
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

--
-- Relocated from FAVCALB.pls
--
FUNCTION calc_raf_adj_cost
   (p_trans_rec           IN            FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec       IN            FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec      IN            FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec      IN            FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old   IN            FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_adj IN            FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new IN            FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec          IN            FA_API_TYPES.period_rec_type,
    p_group_reclass_options_rec IN      FA_API_TYPES.group_reclass_options_rec_type default null,
    p_mrc_sob_type_code   IN            VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

--
-- Functioins from original FA_AMORT_PVT
--

/*
 ---------------------------------------------------------------------
 *
 * Name         faxraf
 *
 *
 * Description
 *      This function calculates the new rate adjustment factor and the
 *      new adjusted cost.
 *
 * Parameters
 *               X_fin_info_ptr         FA_STD_TYPES.fin_info_struct
 *               X_new_raf              number
 *               X_adj_cost             number
 *               X_adj_capacity         number
 *               X_new_reval_amo_basis  number
 *               X_new_salvage_value    number
 *               X_reval_deprn_rsv_adj  number
 *
 * Modifies
 *              X_new_raf,X_new_reval_amo_basis,X_new_salvage_value
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  03/24/97    tpershad        Created
 *--------------------------------------------------------------------
*/

FUNCTION faxraf
         (px_trans_rec           IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec       IN     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec        IN     FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec       IN     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old    IN     FA_API_TYPES.asset_fin_rec_type,
          px_asset_fin_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec      IN     FA_API_TYPES.asset_deprn_rec_type,
          p_period_rec           IN     FA_API_TYPES.period_rec_type,
          px_deprn_exp           IN OUT NOCOPY number,
          px_bonus_deprn_exp     IN OUT NOCOPY number,
          px_impairment_exp      IN OUT NOCOPY number,
          px_reval_deprn_rsv_adj IN out NOCOPY number,
          p_mrc_sob_type_code    IN     VARCHAR2,
          p_running_mode         IN     NUMBER,
          p_used_by_revaluation  IN     NUMBER
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name         faxama
 *
 *
 * Description
 *      Calls faxraf to calculate the new raf. This is the main
 *      routine for Amortized user exit function.
 *      This function calls faxraf to calculate the new rate adjustment
 *      factor and the new adjusted cost.
 *
 * Parameters
 *               X_fin_info_ptr         FA_STD_TYPES.fin_info_struct
 *               X_new_raf              number
 *               X_adj_cost             number
 *               X_adj_capacity         number
 *               X_new_reval_amo_basis  number
 *               X_new_salvage_value    number
 *               X_ccid                 number
 *               X_ins_adjust_flag      boolean  - This is to indicate
 *                                                 whether to call faxiat
 *                                                 or not. If called from
 *                                                 whatif deprn then it is
 *                                                 FALSE and we do not insert
 *                                                 rows in fa_adjustments.
 *               X_deprn_exp            number - deprn expense inserted into
 *                                               fa_adjustment
 *
 * Modifies
 *              X_new_raf,X_new_reval_amo_basis,X_new_salvage_value
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *
 * History
 *  03/24/97    tpershad        Created
 *--------------------------------------------------------------------
*/

FUNCTION faxama
         (px_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec       IN     FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec      IN     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec       IN     FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec      IN     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old   IN     FA_API_TYPES.asset_fin_rec_type,
          p_asset_fin_rec_adj   IN     FA_API_TYPES.asset_fin_rec_type default null,
          px_asset_fin_rec_new  IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec     IN     FA_API_TYPES.asset_deprn_rec_type,
          p_asset_deprn_rec_adj IN     FA_API_TYPES.asset_deprn_rec_type default null,
          p_period_rec          IN     FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code   IN     VARCHAR2,
          p_running_mode        IN     NUMBER,
          p_used_by_revaluation IN     NUMBER,
          p_reclassed_asset_id         NUMBER default null,
          p_reclass_src_dest           VARCHAR2 default null,
          p_reclassed_asset_dpis       DATE default null,
          x_deprn_exp              OUT NOCOPY number,
          x_bonus_deprn_exp        OUT NOCOPY number,
          x_impairment_exp         OUT NOCOPY number
         , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

/*
 ---------------------------------------------------------------------
 *
 * Name         get_reserve
 *
 *
 * Description
 *              This function is called when user tries to do amoritization
 *              and specified amortization start date is eariler than the
 *              addition for those assets that are added with reserve
 *              or added with prior period dpis.
 *              It will return reserve accumulated for up to the period right before the
 *              amortization period.
 *
 * Parameters
 *              X_fin_info_ptr     in out fa_std_types.fin_info_struct,
 *              x_add_txn_id       in number  -- transaction id of addition txn
 *              x_amortize_fy      in integer
 *              x_amortize_per_num in integer
 *              x_pers_per_yr      in integer
 *              x_deprn_rsv        out number -- reserve upto the period prior to amort period
 *              x_bonus_deprn_rsv  out number
 *
 *
 * Modifies
 *              X_deprn_rsv, X_bonus_deprn_rsv
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 * History
 *  06/23/00    lson        Created
 *--------------------------------------------------------------------
*/


FUNCTION get_reserve(px_trans_rec        in out nocopy FA_API_TYPES.trans_rec_type,
                     p_asset_hdr_rec     in     FA_API_TYPES.asset_hdr_rec_type,
                     p_asset_desc_rec    in     FA_API_TYPES.asset_desc_rec_type,
                     px_asset_fin_rec    in out nocopy FA_API_TYPES.asset_fin_rec_type,
                     p_add_txn_id        in     number,
                     p_amortize_fy       in     integer,
                     p_amortize_per_num  in     integer,
                     p_pers_per_yr       in     integer,
                     p_mrc_sob_type_code in     varchar2,
                     x_deprn_rsv            out nocopy number,
                     x_bonus_deprn_rsv      out nocopy number,
                     x_impairment_rsv       out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


/*
 ---------------------------------------------------------------------
 *
 * Name         faxnac
 *
 *
 * Description
 *      Calls faxnac to check if the calculation method of depreciation
 *      is "Strict Calculation Basis".   If so, it will either return the
 *      recoverable cost(for cost based methods), or return the NBV as of
 *      the beginning of the fiscal year
 *
 * Parameters
 *               X_method_code         FA_STD_TYPES.fin_info_struct
 *               X_life                FA_STD_TYPES.fin_info_struct
 *               X_rec_cost            FA_STD_TYPES.dpr_struct
 *               X_prior_fy_exp        FA_STD_TYPES.dprn_out_struct
 *               X_deprn_rsv           null
 *               X_ytd_deprn           null
 *               X_new_adj_cost        new adjusted cost  -- in out
 *
 * Modifies
 *              X_new_adj_cost
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 * History
 *  05/11/00    astakaha        Created
 *--------------------------------------------------------------------
*/

FUNCTION faxnac(p_method_code          in varchar2,
                p_life                 in number,
                p_rec_cost             in number,
                p_prior_fy_exp         in number,
                p_deprn_rsv            in number,
                p_ytd_deprn            in number,
                px_adj_cost            in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

END FA_AMORT_PVT;

/
