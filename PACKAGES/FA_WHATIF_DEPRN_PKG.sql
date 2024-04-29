--------------------------------------------------------
--  DDL for Package FA_WHATIF_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_WHATIF_DEPRN_PKG" AUTHID CURRENT_USER as
/* $Header: FAWDPRS.pls 120.8.12010000.2 2009/07/19 14:19:48 glchen ship $ */


-- store deprn expense values for each period in these globally-declared
-- arrays temporarily.  insert into interface table once deprn is
-- completed for an asset.

  TYPE whatif_itf_table_rec is RECORD (
	new_deprn	number,
	deprn		number,
	new_bonus_deprn	number,
	bonus_deprn	number,
	fiscal_year	number,
	period_name	varchar2(15),
	new_rsv 	number,
	period_num	number
	);

  TYPE whatif_itf_table is TABLE of whatif_itf_table_rec
	index by binary_integer;

  G_deprn     whatif_itf_table;

  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  TYPE tab_char35_type IS TABLE OF VARCHAR2(35) INDEX BY BINARY_INTEGER;
  TYPE tab_char80_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  TYPE tab_char240_type IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE tab_char500_type IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  tb_period_name tab_char30_type;
  tb_period_num  tab_num15_type;
  tb_fiscal_year tab_num15_type;

  t_request_id             tab_num15_type;
  t_book_type_code         tab_char15_type;
  t_asset_id               tab_num15_type;
  t_asset_number           tab_char15_type;
  t_description            tab_char80_type;
  t_tag_number             tab_char15_type;
  t_serial_number          tab_char35_type;
  t_period_name            tab_char15_type;
  t_fiscal_year            tab_num15_type;
  t_expense_acct           tab_char500_type;
  t_location               tab_char500_type;
  t_units                  tab_num_type;
  t_employee_name          tab_char240_type;
  t_employee_number        tab_char30_type;
  t_asset_key              tab_char500_type;
  t_current_cost           tab_num_type;
  t_current_prorate_conv   tab_char15_type;
  t_current_method         tab_char15_type;
  t_current_life           tab_num15_type;
  t_current_basic_rate     tab_num_type;
  t_current_adjusted_rate  tab_num_type;
  t_current_salvage_value  tab_num_type;
  t_depreciation           tab_num_type;
  t_new_depreciation       tab_num_type;
  t_created_by             tab_num15_type;
  t_creation_date          tab_date_type;
  t_last_update_date       tab_date_type;
  t_last_updated_by        tab_num15_type;
  t_last_update_login      tab_num15_type;
  t_date_placed_in_service tab_date_type;
  t_category               tab_char500_type;
  t_accumulated_deprn      tab_num_type;
  t_bonus_depreciation     tab_num_type;
  t_new_bonus_depreciation tab_num_type;
  t_current_bonus_rule     tab_char30_type;
  t_period_num             tab_num15_type;
  t_currency_code          tab_char15_type;

  t_ind BINARY_INTEGER := 0;

-- function whatif_deprn_asset:
--
-- Perform depreciation on an asset using the given properties.
-- Includes effects of adjusting the asset first.
-- Places deprn expense for each period in global arrays (to be committed
-- to interface table later, in whatif_insert_itf).
--   Arguments to this function include all parameters needed to fully
--   load a dpr_in structure (remaining dpr_in elements can be either
--   deduced or selected given these parameters).
--   Deprn runs beginning in X_start_per and continuing for X_num_per
--   periods.
--
-- X_mode contains one of several values that determine how this
-- procedure executes:
-- 'E'...  Asset exists, but some of the input parameters differ
--  from the asset's current state.  Hypothetically perform the
--  expensed adjustment, then run deprn for the given periods,
--  storing expense in G_new_deprn.
-- 'A'... Asset exists, but some of the input parameters differ
--  from the asset's current state.  Hypothetically perform the
--  amortized adjustment, then run deprn for the given periods,
--  storing expense in G_new_deprn.
-- 'N'... Asset exists, and we've already run this procedure in 'E'
--  or 'A' mode.  Now run deprn for given periods again, this time
--  given asset's current state, storing expense in G_deprn.
--  Select asset's current state from DB, ignoring parameters.
-- 'H'... Hypothetical asset which doesn't exist.  Just run deprn
--  for the indicated periods given the hypothetical parameters,
--  storing expense in G_new_deprn.
--  Also runs whatif_insert_itf when done.  Should be called only from form.
--
-- This procedure can be called by whatif_deprn (E,A,N modes)
-- or from a R11 form (H mode).  Could also be called by new Projections
-- code (N mode).

function whatif_deprn_asset (
	X_asset_id	in number,
	X_mode		in varchar2,
	X_book		in varchar2,
	X_start_per	in varchar2,
	X_num_pers	in number,
	X_dpis		in date default null,
	X_prorate_date  in date default null,
	X_prorate_conv  in varchar2 default null,
	X_deprn_start_date  in date default null,
	X_ceiling_name	in varchar2 default null,
	X_bonus_rule	in varchar2 default null,
	X_method_code	in varchar2 default null,
	X_cost		in number default null,
	X_old_cost	in number default null,
	X_adj_cost	in number default null,
	X_rec_cost	in number default null,
	X_raf		in number default null,
	X_adj_rate	in number default null,
	X_reval_amo_basis  in number default null,
	X_capacity	in number default null,
	X_adj_capacity	in number default null,
	X_life		in number default null,
	X_adj_rec_cost	in number default null,
	X_salvage_value	in number default null,
	X_salvage_pct   in number default null,
	X_category_id	in number default null,
	X_deprn_rnd_flag  in varchar2 default null,
	X_calendar_type in varchar2 default null,
	X_prior_fy_exp	in number default null,
	X_deprn_rsv	in number default null,
	X_reval_rsv	in number default null,
	X_ytd_deprn	in number default null,
	X_ltd_prod	in number default null,
	x_return_status	 out nocopy number)
return boolean;

-- function whatif_insert_itf

-- Commit rows into whatif_commit_itf,
-- using deprn stored in global arrays G_new_deprn and G_deprn.
-- X_request_id is 0 if not called from within a concurrent req.

function whatif_insert_itf (
	X_asset_id	in number,
	X_book		in varchar2,
	X_request_id	in number,
	X_num_pers	in number,
	X_acct_struct   in number,
	X_key_struct	in number,
	X_cat_struct	in number,
	X_loc_struct	in number,
	X_precision	in number,
	X_user_id	in number,
	X_login_id	in number,
        X_last_asset    in boolean default false,
	x_return_status out nocopy number)
return boolean;

END FA_WHATIF_DEPRN_PKG;

/
