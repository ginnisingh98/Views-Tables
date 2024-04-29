--------------------------------------------------------
--  DDL for Package FA_TAX_RSV_ADJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_TAX_RSV_ADJ_PVT" AUTHID CURRENT_USER as
/* $Header: FAVTRSVS.pls 120.2.12010000.2 2009/07/19 09:03:01 glchen ship $   */

/* Bug 4597471 -- added one more parameter p_mrc_sob_type_code for passing the type of reporting flag whether 'P' = Primary
   or 'R'= Reporting */

FUNCTION do_tax_rsv_adj
   (px_trans_rec              IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
    px_asset_hdr_rec          IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
    p_asset_desc_rec          IN     FA_API_TYPES.asset_desc_rec_type,
    p_asset_type_rec          IN     FA_API_TYPES.asset_type_rec_type,
    p_asset_cat_rec           IN     FA_API_TYPES.asset_cat_rec_type,
    px_asset_fin_rec          IN OUT NOCOPY  FA_API_TYPES.asset_fin_rec_type,
    p_asset_tax_rsv_adj_rec   IN     FA_API_TYPES.asset_tax_rsv_adj_rec_type,
    p_mrc_sob_type_code       IN     VARCHAR2,
    p_calling_fn              IN     VARCHAR2,
    p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type default null
   ) RETURN BOOLEAN;


END FA_TAX_RSV_ADJ_PVT;

/
