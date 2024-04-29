--------------------------------------------------------
--  DDL for Package FA_ASSET_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_CALC_PVT" AUTHID CURRENT_USER as
/* $Header: FAVCALS.pls 120.12.12010000.2 2009/07/19 11:37:56 glchen ship $   */

FUNCTION calc_fin_info
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_reclassed_asset_id      IN     NUMBER default null,
    p_reclass_src_dest        IN     VARCHAR2 default null,
    p_reclassed_asset_dpis    IN     DATE default null,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_calling_fn              IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_new_amounts
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_derived_amounts
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_prorate_date
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_deprn_start_date
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_rec_cost
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_deprn_limit_adj_rec_cost
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_called_from_faxama      IN     BOOLEAN DEFAULT FALSE, -- Bug 6604235
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_itc_info
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_salvage_value
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_subcomp_life
  (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
   p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
   p_period_rec               IN     FA_API_TYPES.period_rec_type,
   px_asset_fin_rec           IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
   p_calling_fn               IN     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_flags
  (p_trans_rec                IN     FA_API_TYPES.trans_rec_type,
   p_asset_hdr_rec            IN     FA_API_TYPES.asset_hdr_rec_type,
   p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
   p_asset_fin_rec_old        IN     FA_API_TYPES.asset_fin_rec_type,
   px_asset_fin_rec_new       IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
   p_asset_deprn_rec          IN     FA_API_TYPES.asset_deprn_rec_type,
   p_period_rec               IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_deprn_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_group_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION calc_member_info
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

/* Functioin calc_raf_adj_cost has been relocated to FAVAAMRTB.pls */

FUNCTION calc_standalone_info
   (p_asset_hdr_rec           IN     FA_API_TYPES.asset_Hdr_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

END FA_ASSET_CALC_PVT;

/
