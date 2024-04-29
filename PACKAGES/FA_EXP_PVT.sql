--------------------------------------------------------
--  DDL for Package FA_EXP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_EXP_PVT" AUTHID CURRENT_USER as
/* $Header: FAVEXAJS.pls 120.4.12010000.2 2009/07/19 11:42:49 glchen ship $ */


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
     p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
     px_asset_fin_rec_new IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
     p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
     p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
     X_dpr_ptr               out NOCOPY fa_std_types.dpr_struct,
     X_deprn_rsv             out NOCOPY number,
     X_bonus_deprn_rsv       out NOCOPY number,
     X_impairment_rsv        out NOCOPY number,
     p_amortized_flag                   boolean,
     p_extended_flag                    boolean default FALSE, -- Japan Tax Phase3 Bug 6624784
     p_mrc_sob_type_code  IN     VARCHAR2
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

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
         (px_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
          p_asset_hdr_rec      IN     FA_API_TYPES.asset_hdr_rec_type,
          p_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
          p_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
          p_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
          p_asset_fin_rec_old  IN     FA_API_TYPES.asset_fin_rec_type,
          px_asset_fin_rec_new IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
          p_asset_deprn_rec    IN     FA_API_TYPES.asset_deprn_rec_type,
          p_period_rec         IN     FA_API_TYPES.period_rec_type,
          p_mrc_sob_type_code  IN     VARCHAR2,
          p_running_mode         IN     NUMBER,
          p_used_by_revaluation  IN     NUMBER,
          x_deprn_exp             out NOCOPY number,
          x_bonus_deprn_exp       out NOCOPY number,
          x_impairment_exp        out NOCOPY number,
          x_ann_adj_deprn_exp     out NOCOPY number,
          x_ann_adj_bonus_deprn_exp   out NOCOPY number,
          p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


END FA_EXP_PVT;

/
