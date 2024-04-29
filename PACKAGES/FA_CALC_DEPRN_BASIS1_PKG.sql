--------------------------------------------------------
--  DDL for Package FA_CALC_DEPRN_BASIS1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CALC_DEPRN_BASIS1_PKG" AUTHID CURRENT_USER as
/* $Header: faxcdb1s.pls 120.16.12010000.3 2009/11/26 13:28:01 gigupta ship $ */

  ----------------------------------------------------
  -- Input Variables
  ----------------------------------------------------

        g_rule_in     fa_std_types.fa_deprn_rule_in_struct default null;

--	event_type			VARCHAR2(20);
--	asset_id			NUMBER(15);
--	group_asset_id			NUMBER;
--	book_type_code			VARCHAR2(15);
--	asset_type			VARCHAR2(11);
--	depreciate_flag			VARCHAR2(3);
--	method_code			VARCHAR2(12);
--	life_in_months			NUMBER(4);
--	method_id			NUMBER(15);
--	method_type			VARCHAR2(10);
--	calc_basis			VARCHAR2(4);
--	adjustment_amount		NUMBER;
--	transaction_flag		VARCHAR2(3);
--	cost				NUMBER;
--	salvage_value			NUMBER;
--	recoverable_cost		NUMBER;
--	adjusted_cost			NUMBER;
--	current_total_rsv		NUMBER;
--	current_rsv			NUMBER;
--	current_total_ytd		NUMBER;
--	current_ytd			NUMBER;
--	hyp_basis			NUMBER;
--	hyp_total_rsv			NUMBER;
--	hyp_rsv				NUMBER;
--	hyp_total_ytd			NUMBER;
--	hyp_ytd				NUMBER;
--	old_adjusted_cost		NUMBER;
--	old_raf				NUMBER;
--	old_formula_factor		NUMBER;

	-- Add new variable
--	amortization_start_date		DATE;

	-- Add new variables for Group Depreciation
--	transaction_header_id           NUMBER(15);
--      member_transaction_header_id    NUMBER(15);
--      member_transaction_type_code    VARCHAR2(30);
--      member_proceeds                 NUMBER;
--	transaction_date_entered        DATE;
--	adj_transaction_header_id       NUMBER(15);
--      adj_mem_transaction_header_id NUMBER(15);
--      adj_transaction_date_entered    DATE;
--	period_counter                  NUMBER(15);
--	fiscal_year                     NUMBER(15);
--      period_num                      NUMBER(15);
--	proceeds_of_sale                NUMBER;
--	cost_of_removal                 NUMBER;
--	reduction_rate                  NUMBER;
--      eofy_reserve                    NUMBER;
--      adj_reserve                     NUMBER;
--      reserve_retired                 NUMBER;
--      recognize_gain_loss             VARCHAR2(30);
--	tracking_method                 VARCHAR2(30);
--	allocate_to_fully_rsv_flag      VARCHAR2(1);
--	allocate_to_fully_ret_flag      VARCHAR2(1);
--	excess_allocation_option        VARCHAR2(30);
--	depreciation_option             VARCHAR2(30);
--	member_rollup_flag              VARCHAR2(1);
--      unplanned_amount                NUMBER;
--	eofy_recoverable_cost           NUMBER;
--	eop_recoverable_cost            NUMBER;
--	eofy_salvage_value              NUMBER;
--	eop_salvage_value               NUMBER;
--	used_by_adjustment              VARCHAR2(15);
--      eofy_flag                       VARCHAR2(1);
--	apply_reduction_flag            VARCHAR2(1);
--      mrc_sob_type_code               VARCHAR2(1);

--	reduction_amount                NUMBER;
--      use_old_adj_cost_flag           VARCHAR2(1);

  ----------------------------------------------------
  -- Output Variables
  ----------------------------------------------------

        g_rule_out    fa_std_types.fa_deprn_rule_out_struct default null;

--	new_adjusted_cost		NUMBER;
--	new_raf				NUMBER;
--	new_formula_factor		NUMBER;

-----------------------------------------------------------------
-- Function: faxcdb
--
-- Calculate Adjusted cost, rate adjustment factor and
-- formula factor
-----------------------------------------------------------------

FUNCTION faxcdb(
  	        rule_in                    IN  fa_std_types.fa_deprn_rule_in_struct,
		rule_out                   OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct,
                p_amortization_start_date  IN  date default NULL
		, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

-----------------------------------------------------------------
-- FUNCTION: CALC_REDUCITON_AMOUNT
--
-- This function calculates the reduction rate's applying amounts
-----------------------------------------------------------------
FUNCTION CALC_REDUCTION_AMOUNT
  (
    p_asset_id                    IN  NUMBER,
    p_group_asset_id              IN  NUMBER,
    p_asset_type                  IN  VARCHAR2,
    p_book_type_code              IN  VARCHAR2,
    p_period_counter              IN  NUMBER,
    p_transaction_date            IN  DATE     default null,
    p_half_year_rule_flag         IN  VARCHAR2 default null,
    p_mrc_sob_type_code           IN  VARCHAR2 default 'N',
    p_set_of_books_id             IN  NUMBER,
    x_change_in_cost              OUT NOCOPY NUMBER,
    x_change_in_cost_to_reduce    OUT NOCOPY NUMBER,
    x_total_change_in_cost        OUT NOCOPY NUMBER,
    x_net_proceeds                OUT NOCOPY NUMBER,
    x_net_proceeds_to_reduce      OUT NOCOPY NUMBER,
    x_total_net_proceeds          OUT NOCOPY NUMBER,
    x_first_half_cost             OUT NOCOPY NUMBER,
    x_first_half_cost_to_reduce   OUT NOCOPY NUMBER,
    x_second_half_cost            OUT NOCOPY NUMBER,
    x_second_half_cost_to_reduce  OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

--------------------------------------------------------------
-- Function: GET_REC_COST
--
-- This function is to get recoverable cost and salvage value
-- at the period of parameter's period counter
-------------------------------------------------------------
FUNCTION GET_REC_COST
  (
    p_asset_id                 IN  NUMBER,
    p_book_type_code           IN  VARCHAR2,
    p_fiscal_year              IN  NUMBER,
    p_period_num               IN  NUMBER,
    p_asset_type               IN  VARCHAR2 default null,
    p_recoverable_cost         IN  NUMBER   default null,
    p_salvage_value            IN  NUMBER   default null,
    p_transaction_date_entered IN  DATE     default null,
    p_mrc_sob_type_code        IN  VARCHAR2 default 'N',
    p_set_of_books_id          IN  NUMBER,
    x_recoverable_cost         OUT NOCOPY NUMBER,
    x_salvage_value            OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

--------------------------------------------------------------
-- Function: GET_EOFY_EOP
--
-- This function is to get recoverable cost and salvage value
-- at the end of last fiscal year and last period
-------------------------------------------------------------

FUNCTION GET_EOFY_EOP
  (
    p_asset_id                 IN  NUMBER,
    p_book_type_code           IN  VARCHAR2,
    p_fiscal_year              IN  NUMBER,
    p_period_num               IN  NUMBER,
    p_asset_type               IN  VARCHAR2 default null,
    p_recoverable_cost         IN  NUMBER   default null,
    p_salvage_value            IN  NUMBER   default null,
    p_transaction_date_entered IN  DATE     default null,
    p_period_counter           IN  NUMBER   default null,
    p_mrc_sob_type_code        IN  VARCHAR2 default null,
    p_set_of_books_id          IN  NUMBER,
    x_eofy_recoverable_cost    OUT NOCOPY NUMBER,
    x_eofy_salvage_value       OUT NOCOPY NUMBER,
    x_eop_recoverable_cost     OUT NOCOPY NUMBER,
    x_eop_salvage_value        OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

--------------------------------------------------------
-- Function: CALL_DEPRN_BASIS
--
-- This function is the cover function to call faxcdb
-- from Transaction API and depreciation Engine
--------------------------------------------------------
FUNCTION CALL_DEPRN_BASIS(
     p_event_type             IN            varchar2,
     p_asset_fin_rec_new      IN            fa_api_types.asset_fin_rec_type default null,
     p_asset_fin_rec_old      IN            fa_api_types.asset_fin_rec_type default null,
     p_asset_hdr_rec          IN            fa_api_types.asset_hdr_rec_type default null,
     p_asset_type_rec         IN            fa_api_types.asset_type_rec_type default null,
     p_asset_deprn_rec        IN            fa_api_types.asset_deprn_rec_type default null,
     p_trans_rec              IN            fa_api_types.trans_rec_type default null,
     p_trans_rec_adj          IN            fa_api_types.trans_rec_type default null,
     p_period_rec             IN            fa_api_types.period_rec_type default null,
     p_asset_retire_rec       IN            fa_api_types.asset_retire_rec_type default null,
     p_unplanned_deprn_rec    IN            fa_api_types.unplanned_deprn_rec_type default null,
     p_dpr                    IN            fa_std_types.dpr_struct default null,
     p_fiscal_year            IN            number default 0,
     p_period_num             IN            number default null,
     p_period_counter         IN            number default 0,
     p_recoverable_cost       IN            number default 0,
     p_salvage_value          IN            number default 0,
     p_adjusted_cost          IN            number default 0,
     p_current_total_rsv      IN            number default 0,
     p_current_rsv            IN            number default 0,
     p_current_total_ytd      IN            number default 0,
     p_current_ytd            IN            number default 0,
     p_hyp_basis              IN            number default 0,
     p_hyp_total_rsv          IN            number default 0,
     p_hyp_rsv                IN            number default 0,
     p_hyp_total_ytd          IN            number default 0,
     p_hyp_ytd                IN            number default 0,
     p_eofy_recoverable_cost  IN            number default null,
     p_eop_recoverable_cost   IN            number default null,
     p_eofy_salvage_value     IN            number default null,
     p_eop_salvage_value      IN            number default null,
     p_eofy_reserve           IN            number default null,
     p_adj_reserve            IN            number default null,
     p_reserve_retired        IN            number default null,
     p_used_by_adjustment     IN            varchar2 default null,
     p_eofy_flag              IN            varchar2 default null,
     p_apply_reduction_flag   IN            varchar2 default null,
     p_mrc_sob_type_code      IN            varchar2 default 'N',
     px_new_adjusted_cost     IN OUT NOCOPY number,
     px_new_raf               IN OUT NOCOPY number,
     px_new_formula_factor    IN OUT NOCOPY number
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

--------------------------------------------------------
-- Function: CALL_DEPRN_BASIS
--
-- called from depreciation Engine(pl/sql)
-- This is same as CALL_DEPRN_BASIS above except additional
-- parameter x_annual_deprn_rounding_flag
-- This new output is necessary for flat rate extension
--------------------------------------------------------
FUNCTION CALL_DEPRN_BASIS(
     p_event_type             IN            varchar2,
     p_asset_fin_rec_new      IN            fa_api_types.asset_fin_rec_type default null,
     p_asset_fin_rec_old      IN            fa_api_types.asset_fin_rec_type default null,
     p_asset_hdr_rec          IN            fa_api_types.asset_hdr_rec_type default null,
     p_asset_type_rec         IN            fa_api_types.asset_type_rec_type default null,
     p_asset_deprn_rec        IN            fa_api_types.asset_deprn_rec_type default null,
     p_trans_rec              IN            fa_api_types.trans_rec_type default null,
     p_trans_rec_adj          IN            fa_api_types.trans_rec_type default null,
     p_period_rec             IN            fa_api_types.period_rec_type default null,
     p_asset_retire_rec       IN            fa_api_types.asset_retire_rec_type default null,
     p_unplanned_deprn_rec    IN            fa_api_types.unplanned_deprn_rec_type default null,
     p_dpr                    IN            fa_std_types.dpr_struct default null,
     p_fiscal_year            IN            number default 0,
     p_period_num             IN            number default null,
     p_period_counter         IN            number default 0,
     p_recoverable_cost       IN            number default 0,
     p_salvage_value          IN            number default 0,
     p_adjusted_cost          IN            number default 0,
     p_current_total_rsv      IN            number default 0,
     p_current_rsv            IN            number default 0,
     p_current_total_ytd      IN            number default 0,
     p_current_ytd            IN            number default 0,
     p_hyp_basis              IN            number default 0,
     p_hyp_total_rsv          IN            number default 0,
     p_hyp_rsv                IN            number default 0,
     p_hyp_total_ytd          IN            number default 0,
     p_hyp_ytd                IN            number default 0,
     p_eofy_recoverable_cost  IN            number default null,
     p_eop_recoverable_cost   IN            number default null,
     p_eofy_salvage_value     IN            number default null,
     p_eop_salvage_value      IN            number default null,
     p_eofy_reserve           IN            number default null,
     p_adj_reserve            IN            number default null,
     p_reserve_retired        IN            number default null,
     p_used_by_adjustment     IN            varchar2 default null,
     p_eofy_flag              IN            varchar2 default null,
     p_apply_reduction_flag   IN            varchar2 default null,
     p_mrc_sob_type_code      IN            varchar2 default 'N',
     px_new_adjusted_cost     IN OUT NOCOPY number,
     px_new_raf               IN OUT NOCOPY number,
     px_new_formula_factor    IN OUT NOCOPY number,
     x_annual_deprn_rounding_flag IN OUT NOCOPY varchar2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

------------------------------------------------------------
-- Function: CALC_PROCEEDS
--
-- This function is to calculate Year-to-Date Proceeds
-- and Life-to Date Proceeds of Do not Recognized Gain/Loss
------------------------------------------------------------

Function CALC_PROCEEDS (
    p_asset_id                    IN         NUMBER,
    p_asset_type                  IN         VARCHAR2,
    p_book_type_code              IN         VARCHAR2,
    p_period_counter              IN         NUMBER,
    p_mrc_sob_type_code           IN         VARCHAR2,
    p_set_of_books_id             IN  NUMBER,
    x_ltd_proceeds                OUT NOCOPY NUMBER,
    x_ytd_proceeds                OUT NOCOPY NUMBER
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

-----------------------------------------------------------------
-- Function: CALC_RETIRED_COST
--
-- This function calculate summary of retired cost.
-- This function is used by Rule 'POSITIVE_REDUCTION'.
-----------------------------------------------------------------

FUNCTION CALC_RETIRED_COST (
    p_event_type                  IN         VARCHAR2,
    p_asset_id                    IN         NUMBER,
    p_asset_type                  IN         VARCHAR2,
    p_book_type_code              IN         VARCHAR2,
    p_fiscal_year                 IN         NUMBER,
    p_period_num                  IN         NUMBER,
    p_adjustment_amount           IN         NUMBER,
    p_ltd_ytd_flag                IN         VARCHAR2,
    p_mrc_sob_type_code           IN         VARCHAR2,
    p_set_of_books_id             IN  NUMBER,
    x_retired_cost                OUT NOCOPY NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

-----------------------------------------------------------------
-- Function: GET_MEM_TRANS_INFO
--
-- This function is to get the transaction infomation of member
-----------------------------------------------------------------
Function GET_MEM_TRANS_INFO (
    p_member_transaction_header_id  IN         NUMBER,
    p_mrc_sob_type_code             IN         VARCHAR2,
    p_set_of_books_id             IN  NUMBER,
    x_member_transaction_type_code  OUT NOCOPY VARCHAR2,
    x_member_proceeds               OUT NOCOPY NUMBER,
    x_member_reduction_rate         OUT NOCOPY NUMBER,
    x_recognize_gain_loss           OUT NOCOPY VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

---------------------------------------------------------------------
-- Function: SERVER_VALIDATION
--
-- This function is to validate unexpected values
--
---------------------------------------------------------------------

Function SERVER_VALIDATION(
p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

END FA_CALC_DEPRN_BASIS1_PKG;

/
