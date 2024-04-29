--------------------------------------------------------
--  DDL for Package FA_CIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CIP_PVT" AUTHID CURRENT_USER as
/* $Header: FAVCIPS.pls 120.2.12010000.2 2009/07/19 11:38:55 glchen ship $   */

FUNCTION do_cap_rev
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    p_asset_hdr_rec           IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_type_rec         IN OUT NOCOPY FA_API_TYPES.asset_type_rec_type,
    p_asset_fin_rec_old       IN     FA_API_TYPES.asset_fin_rec_type,
    px_asset_fin_rec          IN OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_period_rec              IN     FA_API_TYPES.period_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_CIP_PVT;

/
