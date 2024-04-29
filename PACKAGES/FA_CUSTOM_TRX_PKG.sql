--------------------------------------------------------
--  DDL for Package FA_CUSTOM_TRX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CUSTOM_TRX_PKG" AUTHID CURRENT_USER as
/* $Header: factrxs.pls 120.0.12010000.1 2009/05/26 19:43:42 bridgway noship $   */

function override_values
            (p_asset_hdr_rec              IN            fa_api_types.asset_hdr_rec_type,
             px_trans_rec                 IN OUT NOCOPY fa_api_types.trans_rec_type,
             p_asset_desc_rec             IN            fa_api_types.asset_desc_rec_type,
             p_asset_type_rec             IN            fa_api_types.asset_type_rec_type,
             p_asset_cat_rec              IN            fa_api_types.asset_cat_rec_type,
             p_asset_fin_rec_old          IN            fa_api_types.asset_fin_rec_type,
             px_asset_fin_rec_adj         IN OUT NOCOPY fa_api_types.asset_fin_rec_type,
             px_asset_deprn_rec_adj       IN OUT NOCOPY fa_api_types.asset_deprn_rec_type,
             p_inv_trans_rec              IN            fa_api_types.inv_trans_rec_type,
             px_inv_tbl                   IN OUT NOCOPY fa_api_types.inv_tbl_type,
             px_group_reclass_options_rec IN OUT NOCOPY fa_api_types.group_reclass_options_rec_type,
             p_calling_fn                 IN            varchar2) return boolean;


end fa_custom_trx_pkg;

/
