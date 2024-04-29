--------------------------------------------------------
--  DDL for Package FA_INVOICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_INVOICE_PVT" AUTHID CURRENT_USER as
/* $Header: FAVINVS.pls 120.3.12010000.2 2009/07/19 11:35:56 glchen ship $   */

FUNCTION invoice_engine
   (px_trans_rec               IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec           IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec           IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec           IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec            IN     FA_API_TYPES.asset_cat_rec_type,
    p_asset_fin_rec_adj        IN     FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_rec_new           OUT NOCOPY FA_API_TYPES.asset_fin_rec_type,
    x_asset_fin_mrc_tbl_new       OUT NOCOPY FA_API_TYPES.asset_fin_tbl_type,
    px_inv_trans_rec           IN OUT NOCOPY FA_API_TYPES.inv_trans_rec_type,
    px_inv_tbl                 IN OUT NOCOPY FA_API_TYPES.inv_tbl_type,
    x_asset_deprn_rec_new         OUT NOCOPY FA_API_TYPES.asset_deprn_rec_type,
    x_asset_deprn_mrc_tbl_new     OUT NOCOPY FA_API_TYPES.asset_deprn_tbl_type,
    p_calling_fn               IN     VARCHAR2,
    p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_INVOICE_PVT;

/
