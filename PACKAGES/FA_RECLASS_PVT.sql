--------------------------------------------------------
--  DDL for Package FA_RECLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RECLASS_PVT" AUTHID CURRENT_USER as
/* $Header: FAVRECS.pls 120.2.12010000.2 2009/07/19 11:16:45 glchen ship $   */

/* ---------------------------------------------------------------
 * Name            : Do_reclass
 * Type            : Function
 * Returns         : Boolean
 * Purpose         : Perform reclass transaction for an asset
 * Calling Details : This function expects the following parameters with
 *                   valid data for it to perform the Reclass transaction
 *                   successfully
 *                   px_api_hdr_rec
 *                   px_msg_rec
 *                   px_trans_rec.amortization_start_date
 *                   px_asset_desc_rec.asset_number
 *                   px_asset_cat_rec_new.category_id
 * ---------------------------------------------------------------- */

 FUNCTION do_reclass(
           px_trans_rec          IN OUT NOCOPY  FA_API_TYPES.trans_rec_type,
           px_asset_desc_rec     IN OUT NOCOPY  FA_API_TYPES.asset_desc_rec_type,
           px_asset_hdr_rec      IN OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
           px_asset_type_rec     IN OUT NOCOPY  FA_API_TYPES.asset_type_rec_type,
           px_asset_cat_rec_old  IN OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
           px_asset_cat_rec_new  IN OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
           p_recl_opt_rec        IN      FA_API_TYPES.reclass_options_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

/* ---------------------------------------------------------------
 * Name            : validate_reclass
 * Type            : Function
 * Returns         : Boolean
 * Purpose         : validates reclass transaction for an asset
 * Calling Details : This function expects the following parameters
 *                   to perform validations successfully
 *                   px_api_hdr_rec
 *                   px_msg_rec
 *                   px_trans_rec
 *                   px_asset_desc_rec
 *                   px_asset_hdr_rec
 * ---------------------------------------------------------------- */

FUNCTION validate_reclass (
         p_trans_rec           IN   FA_API_TYPES.trans_rec_type,
         p_asset_desc_rec      IN   FA_API_TYPES.asset_desc_rec_type,
         p_asset_hdr_rec       IN   FA_API_TYPES.asset_hdr_rec_type,
         p_asset_type_rec      IN   FA_API_TYPES.asset_type_rec_type,
         p_asset_cat_rec_old   IN   FA_API_TYPES.asset_cat_rec_type,
         p_asset_cat_rec_new   IN   FA_API_TYPES.asset_cat_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

-- --------------------------------

-- -------------------------------

FUNCTION validate_redefault(
         px_trans_rec            IN   OUT NOCOPY  FA_API_TYPES.trans_rec_type,
         px_asset_desc_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_desc_rec_type,
         px_asset_hdr_rec        IN   OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
         px_asset_type_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_type_rec_type,
         px_asset_cat_rec_old    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         p_mass_request_id       IN        NUMBER DEFAULT null , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

/* -------------------------------------------------------------------


* ------------------------------------------------------------------- */

FUNCTION do_redefault(
         px_trans_rec            IN   OUT NOCOPY  FA_API_TYPES.trans_rec_type,
         px_asset_desc_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_desc_rec_type,
         px_asset_hdr_rec        IN   OUT NOCOPY  FA_API_TYPES.asset_hdr_rec_type,
         px_asset_type_rec       IN   OUT NOCOPY  FA_API_TYPES.asset_type_rec_type,
         px_asset_cat_rec_old    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new    IN   OUT NOCOPY  FA_API_TYPES.asset_cat_rec_type,
         p_mass_request_id       IN        NUMBER DEFAULT null , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


/* ------------------------------------------------------------
*
*
* ------------------------------------------------------------- */
FUNCTION populate_adjust_info (
               px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
               px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
               px_asset_desc_rec         IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type,
               px_asset_type_rec         IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
               px_asset_cat_rec          IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
               px_asset_fin_rec          IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
               px_asset_fin_rec_adj      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
               px_asset_deprn_rec        IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
               px_asset_deprn_rec_adj    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
               p_old_rules               IN     FA_LOAD_TBL_PKG.asset_deprn_info,
               p_new_rules               IN     FA_LOAD_TBL_PKG.asset_deprn_info
               , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;


END FA_RECLASS_PVT;

/
