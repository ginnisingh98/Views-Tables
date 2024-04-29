--------------------------------------------------------
--  DDL for Package FA_TRANS_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TRANS_API_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVTAPIS.pls 120.3.12010000.2 2009/07/19 11:20:50 glchen ship $ */

FUNCTION set_asset_fin_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_fin_rec         IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new        OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN;

FUNCTION set_asset_deprn_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_deprn_rec       IN     FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_rec_new      OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN;

FUNCTION set_asset_desc_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec        IN     FA_API_TYPES.asset_desc_rec_type,
    x_asset_desc_rec_new       OUT NOCOPY FA_API_TYPES.asset_desc_rec_type
) RETURN BOOLEAN;

FUNCTION set_asset_cat_rec (
    p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
    p_asset_cat_rec         IN     FA_API_TYPES.asset_cat_rec_type,
    x_asset_cat_rec_new        OUT NOCOPY FA_API_TYPES.asset_cat_rec_type
) RETURN BOOLEAN;

FUNCTION set_asset_retire_rec (
    p_asset_retire_rec      IN     FA_API_TYPES.asset_retire_rec_type,
    x_asset_retire_rec_new     OUT NOCOPY FA_API_TYPES.asset_retire_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) return BOOLEAN;

FUNCTION set_inv_rec (
    p_inv_rec               IN     FA_API_TYPES.inv_rec_type,
    x_inv_rec_new              OUT NOCOPY FA_API_TYPES.inv_rec_type,
    p_mrc_sob_type_code     IN     VARCHAR2
) RETURN BOOLEAN;

END FA_TRANS_API_PVT;

/
