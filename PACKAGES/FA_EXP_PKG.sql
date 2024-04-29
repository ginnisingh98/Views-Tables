--------------------------------------------------------
--  DDL for Package FA_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_EXP_PKG" AUTHID CURRENT_USER as
/* $Header: FAEXADJS.pls 120.2.12010000.2 2009/07/19 14:42:52 glchen ship $ */


/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxbds
 *
 * Description
 *              Builds the depreciation structure
 *
 * Parameters
 *		fin_info_ptr - fin_info structure IN OUT
 *		dpr_ptr - depreciation structure OUT
 *		dist_book - distribution book OUT
 *		deprn_rsv - depreciation reserve OUT
 *		amortized_flag - amortization flag
 *
 * Modifies
 *		X_fin_info_ptr
 *		X_dpr_ptr
 *		X_dist_book
 *		X_deprn_rsv
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *		Shared by other Expense user exits
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
Function faxbds
	(
	X_fin_info_ptr in out nocopy fa_std_types.fin_info_struct
	,X_dpr_ptr out nocopy fa_std_types.dpr_struct
	,X_dist_book out nocopy varchar2
	,X_deprn_rsv out nocopy number
	,X_amortized_flag boolean
        ,X_mrc_sob_type_code varchar2
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;

/*
 --------------------------------------------------------------------------
 *
 * Name
 *              faxexp
 *
 * Description
 *
 *
 * Parameters
 *              X_fin_info_ptr - fin_info structure IN OUT
 *		X_new_adj_cost - new adjusted cost OUT
 *		X_ccid - GL code combination id
 *		X_sysdate_val - system date
 *		X_last_updated_by - user id
 *		X_last_update_login - login id
 *		X_ins_adj_flag - insert adjustment flag
 *		X_deprn_exp - depreciation expense OUT
 *
 * Modifies
 *              X_fin_info_ptr
 *		X_new_adj_cost
 *		X_deprn_exp
 *
 * Returns
 *              True on successful retrieval. Otherwise False.
 *
 * Notes
 *              Used by any program that needs to expense a
 *		financial information change
 *
 * History
 *
 *--------------------------------------------------------------------------
*/
Function faxexp
	(
	X_fin_info_ptr in out nocopy fa_std_types.fin_info_struct
	,X_new_adj_cost out nocopy number
	,X_ccid integer
	,X_sysdate_val date
	,X_last_updated_by number
	,X_last_update_login number
	,X_ins_adj_flag boolean
        ,X_mrc_sob_type_code varchar2
	,X_deprn_exp out nocopy number
	,X_bonus_deprn_exp out nocopy number
	,X_new_formula_factor in out nocopy number
	, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
return boolean;


END FA_EXP_PKG;

/
