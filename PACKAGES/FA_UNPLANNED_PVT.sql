--------------------------------------------------------
--  DDL for Package FA_UNPLANNED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UNPLANNED_PVT" AUTHID CURRENT_USER as
/* $Header: FAVUNPLS.pls 120.2.12010000.2 2009/07/19 14:31:54 glchen ship $   */

FUNCTION do_unplanned
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec           IN     FA_API_TYPES.asset_fin_rec_type,
    p_asset_deprn_rec         IN     FA_API_TYPES.asset_deprn_rec_type,
    p_unplanned_deprn_rec     IN     FA_API_TYPES.unplanned_deprn_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

END FA_UNPLANNED_PVT;

/
