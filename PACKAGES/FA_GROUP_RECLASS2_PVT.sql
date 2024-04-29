--------------------------------------------------------
--  DDL for Package FA_GROUP_RECLASS2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GROUP_RECLASS2_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVGRECS.pls 120.4.12010000.2 2009/07/19 11:32:03 glchen ship $ */

FUNCTION do_group_reclass
   (p_trans_rec               IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_src_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_src_asset_hdr_rec      IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_src_asset_desc_rec      IN     FA_API_TYPES.asset_desc_rec_type,
    p_src_asset_type_rec      IN     FA_API_TYPES.asset_type_rec_type,
    p_src_asset_cat_rec       IN     FA_API_TYPES.asset_cat_rec_type,
    px_dest_trans_rec         IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_dest_asset_hdr_rec     IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_dest_asset_desc_rec     IN     FA_API_TYPES.asset_desc_rec_type,
    p_dest_asset_type_rec     IN     FA_API_TYPES.asset_type_rec_type,
    p_dest_asset_cat_rec      IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_adj       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_new       IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_adj     IN     FA_API_TYPES.asset_deprn_rec_type,
    p_asset_deprn_rec_new     IN     FA_API_TYPES.asset_deprn_rec_type,
    px_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_calling_fn              IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION do_adjustment
   (px_trans_rec                 IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec              IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec             IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec             IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec              IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_old          IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_fin_rec_new          IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec_old        IN     FA_API_TYPES.asset_deprn_rec_type,
    p_mem_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
    p_mem_asset_desc_rec         IN     FA_API_TYPES.asset_desc_rec_type,
    p_mem_asset_type_rec         IN     FA_API_TYPES.asset_type_rec_type,
    p_mem_asset_cat_rec          IN     FA_API_TYPES.asset_cat_rec_type,
    p_mem_asset_fin_rec_new      IN     FA_API_TYPES.asset_fin_rec_type,
    p_mem_asset_deprn_rec_new    IN     FA_API_TYPES.asset_deprn_rec_type,
    px_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec                 IN     fa_api_types.period_rec_type,
    p_mrc_sob_type_code          IN     VARCHAR2,
    p_src_dest                   IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

FUNCTION populate_member_amounts
   (p_trans_rec                  IN     FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec              IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec_new          IN     FA_API_TYPES.asset_fin_rec_type,
    p_mem_asset_hdr_rec          IN     FA_API_TYPES.asset_hdr_rec_type,
    p_mem_asset_fin_rec_new      IN     FA_API_TYPES.asset_fin_rec_type,
    px_group_reclass_options_rec IN OUT NOCOPY FA_API_TYPES.group_reclass_options_rec_type,
    p_period_rec                 IN     fa_api_types.period_rec_type,
    p_mrc_sob_type_code          IN     VARCHAR2,
    p_src_dest                   IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;


end FA_GROUP_RECLASS2_PVT;

/
