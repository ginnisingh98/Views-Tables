--------------------------------------------------------
--  DDL for Package FA_BASIS_OVERRIDE_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_BASIS_OVERRIDE_INIT_PKG" AUTHID CURRENT_USER as
/* $Header: FADBOIS.pls 120.5.12010000.3 2009/07/19 12:13:05 glchen ship $ */


/*
 --------------------------------------------------------------------------
 *
 * Name
 *              facodda()
 *
 * Description
 *              Override the Default Depreciation Amounts - cover from Pro*C
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              True on successful completion. Otherwise False.
 *
 * Notes
 *
 * History
 *              FEB 15, 2002  astakaha created
 *              OCT 02, 2002  ynatsui  added p_mrc_sob_type_code
 *              DEC 05, 2002  ynatsui  added ytd parameteres
 *--------------------------------------------------------------------------
*/
FUNCTION facodda(Book IN VARCHAR2,
                Used_By_Adjustment IN number,
                Asset_ID IN NUMBER,
                Bonus_Rule IN VARCHAR2,
                Fyctr IN NUMBER,
                Perd_Ctr IN NUMBER,
                Prod_Rate_Src_Flag IN number,
                Deprn_Projecting_Flag IN number,
                p_ytd_deprn         IN NUMBER,
                p_bonus_ytd_deprn   IN NUMBER,
                Override_Depr_Amt OUT NOCOPY NUMBER,
                Override_Bonus_Amt OUT NOCOPY NUMBER,
                Deprn_Override_Flag OUT NOCOPY VARCHAR2,
                Return_Code OUT NOCOPY NUMBER,
                p_mrc_sob_type_code IN VARCHAR2 DEFAULT NULL,
                p_set_of_books_id IN NUMBER,
		p_over_depreciate_option IN NUMBER DEFAULT NULL,
		p_asset_type             IN VARCHAR2 DEFAULT NULL,
		p_deprn_rsv          IN NUMBER DEFAULT NULL,
		p_cur_adj_cost       IN NUMBER DEFAULT NULL
               ) return number;

----------------------------------------------------------------------------
--
-- Name
--              faxccdb()
--
-- Description
--              Depreciable Basis Formula feature - cover from Pro*C
-- Parameters
--
-- Modifies
--
-- Returns
--              True on successful completion. Otherwise False.
--
-- Notes
--
-- History
--              FEB 15, 2002  hsugimot   Created
--              OCT 09, 2002  hsugimot   Added new parameters
--                                       for group depreciation
----------------------------------------------------------------------------


FUNCTION faxccdb(event_type in varchar2,
                 asset_id in number default 0,
                 group_asset_id in number default 0,
                 book_type_code in varchar2 default null,
                 asset_type in varchar2 default null,
                 depreciate_flag in varchar2 default null,
                 method_code in varchar2 default null,
                 life_in_months in number default 0,
                 method_id in number default 0,
                 method_type in varchar2 default null,
                 calc_basis in varchar2 default null,
                 adjustment_amount in number default 0,
                 transaction_flag in varchar2 default null,
                 cost in number default 0,
                 salvage_value in number default 0,
                 recoverable_cost in number default 0,
                 adjusted_cost in number default 0,
                 current_total_rsv in number default 0,
                 current_rsv in number default 0,
                 current_total_ytd in number default 0,
                 current_ytd in number default 0,
                 hyp_basis in number default 0,
                 hyp_total_rsv in number default 0,
                 hyp_rsv in number default 0,
                 hyp_total_ytd in number default 0,
                 hyp_ytd in number default 0,
                 old_adjusted_cost in number default 0,
                 old_raf in number default 0,
                 old_formula_factor in number default 0,
                 new_adjusted_cost out NOCOPY number,
                 new_raf out NOCOPY number,
                 new_formula_factor out NOCOPY number,
                 -- new parameter for group depreciation
                 p_period_counter in number default null,
                 p_fiscal_year in number default null,
                 p_eofy_reserve in number default null,
                 p_tracking_method in varchar2 default null,
                 p_allocate_to_fully_rsv_flag in varchar2 default null,
                 p_allocate_to_fully_ret_flag in varchar2 default null,
                 p_depreciation_option in varchar2 default null,
                 p_member_rollup_flag in varchar2 default null,
                 p_eofy_recoverable_cost in number default null,
                 p_eop_recoverable_cost in number default null,
                 p_eofy_salvage_value in number default null,
                 p_eop_salvage_value in number default null,
                 p_used_by_adjustment in number default null,
                 p_eofy_flag in varchar2  default null,
                 -- new parameter for polish enhancement
                 p_polish_rule in number default
                    FA_STD_TYPES.FAD_DBR_POLISH_NONE,
                 p_deprn_factor in number default null,
                 p_alternate_deprn_factor in number default null,
                 p_impairment_reserve number default 0, -- P2IAS36
                 p_mrc_sob_type_code in varchar2 default 'N',
                 p_set_of_books_id in number
                 --
                 ) return number;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faoddat()
 *
 * Description
 *              Update the deprn_override_trigger_enabled global variable
 * Parameters
 *
 * Modifies
 *
 * Returns
 *              True on successful completion. Otherwise False.
 *
 * Notes
 *
 * History
 *              MAR 5, 2002  astakaha created
 *--------------------------------------------------------------------------
*/
FUNCTION faoddat(deprn_override_trigger in number) Return number;

END FA_BASIS_OVERRIDE_INIT_PKG;

/
