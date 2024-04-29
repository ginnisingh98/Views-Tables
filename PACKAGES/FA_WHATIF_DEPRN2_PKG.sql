--------------------------------------------------------
--  DDL for Package FA_WHATIF_DEPRN2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_WHATIF_DEPRN2_PKG" AUTHID CURRENT_USER as
/* $Header: FAWDPR2S.pls 120.4.12010000.2 2009/07/19 14:18:49 glchen ship $ */



-- function whatif_deprn

-- Perform whatif deprn on a set of assets given hypothetical properties.
-- Commit results to FA_WHATIF_DEP.
-- This should be only called from within a concurrent request.
--
-- X_exp_amt is either 'E' or 'A'.
-- If 'E', then for each asset:
--	Run whatif_deprn_asset in 'E' mode.
--	Run whatif_deprn_asset in 'N' mode.
--	Run whatif_insert_itf, and commit.
-- If 'A', then for each asset:
--	Run whatif_deprn_asset in 'A' mode.
--	Run whatif_deprn_asset in 'N' mode.
--	Run whatif_insert_itf, and commit.


function whatif_deprn (
	X_assets	in out nocopy fa_std_types.number_tbl_type,
	X_num_assets	in number,
	X_method	in varchar2,
	X_life		in number,
	X_adjusted_rate in number,
	X_prorate_conv	in varchar2,
	X_salvage_pct	in number,
	X_exp_amt	in out nocopy varchar2,
	X_book		in varchar2,
	X_start_per	in varchar2,
	X_num_per	in number,
	X_request_id	in number,
	X_user_id	in number,
	X_hypo          in varchar2,
	X_dpis          in date,
	X_cost          in number,
	X_deprn_rsv     in number,
        X_cat_id        in number,
	X_bonus_rule	in varchar2,
	x_return_status out nocopy number,
	X_fullresv_flg in varchar2,			-- ERnos  6612615  what-if  start
	X_extnd_deprn_flg in varchar2,
	X_first_period in varchar2)			--ERnos  6612615  what-if  end
return boolean;


-- function whatif_get_assets

-- Get set of assets satisfying criteria:
--   Book
--   Asset number range
--   DPIS range
--   Description
--   Category
-- If any of these are null, this means it's not used as a criterion.
-- Also, assets not included if:
--   1. non-expense adjustment already occurred for this asset.
--   2. there exist transactions dated after sysdate.
--   3. non-production <=> production method changes aren't legal
--	(X_method param is needed to check this)
-- Put asset_id's satisfying criteria AND don't have conditions 1,2,3
-- in X_good_assets array.

function whatif_get_assets (
	X_book		in varchar2,
	X_begin_asset	in varchar2,
	X_end_asset	in varchar2,
	X_begin_dpis	in date,
	X_end_dpis	in date,
	X_description   in varchar2,
	X_category_id	in number,
	X_mode		in varchar2,
	X_rsv_flag      in varchar2,
	X_good_assets out nocopy fa_std_types.number_tbl_type,
	X_num_good out nocopy number,
	X_start_range   in number,
	X_end_range     in number,
	x_return_status	 out nocopy number)
return boolean;


END FA_WHATIF_DEPRN2_PKG;

/
