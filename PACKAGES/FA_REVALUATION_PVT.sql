--------------------------------------------------------
--  DDL for Package FA_REVALUATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_REVALUATION_PVT" AUTHID CURRENT_USER as
/* $Header: FAVRVLS.pls 120.1.12010000.2 2009/07/19 11:19:50 glchen ship $   */

FUNCTION do_reval
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_reval_options_rec       IN     FA_API_TYPES.reval_options_rec_type,
    p_calling_fn              IN     VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
RETURN BOOLEAN ;

-----------------------------------------------------------------------------------

-- this function contains validation for reval on an asset

FUNCTION validate_reval
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_reval_options_rec       IN     FA_API_TYPES.reval_options_rec_type
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION fareven
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec_new      IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_asset_deprn_rec_new    IN OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_reval_options_rec       IN     FA_API_TYPES.reval_options_rec_type,
    x_reval_out               OUT NOCOPY fa_std_types.reval_out_struct
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                                   RETURN BOOLEAN;

END FA_REVALUATION_PVT;

/
