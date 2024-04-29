--------------------------------------------------------
--  DDL for Package FA_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADJUSTMENT_PVT" AUTHID CURRENT_USER as
/* $Header: FAVADJS.pls 120.7.12010000.3 2009/07/19 11:51:04 glchen ship $   */

FUNCTION validate_adjustment
   (p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
    ) RETURN BOOLEAN;

FUNCTION do_adjustment
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new          OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_inv_trans_rec           IN     FA_API_TYPES.inv_trans_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new        OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_reclassed_asset_id      IN     NUMBER default null,
    p_reclass_src_dest        IN     VARCHAR2 default null,
    p_reclassed_asset_dpis    IN     DATE default null,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_calling_fn              IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


END FA_ADJUSTMENT_PVT;

/
