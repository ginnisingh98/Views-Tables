--------------------------------------------------------
--  DDL for Package FA_ADDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ADDITION_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVADDS.pls 120.3.12010000.2 2009/07/19 11:50:34 glchen ship $   */

function initialize (
   -- Transaction Object --
   px_trans_rec                IN OUT NOCOPY  fa_api_types.trans_rec_type,
   px_dist_trans_rec           IN OUT NOCOPY  fa_api_types.trans_rec_type,
   -- Asset Object --
   px_asset_hdr_rec            IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type,
   px_asset_desc_rec           IN OUT NOCOPY  fa_api_types.asset_desc_rec_type,
   px_asset_type_rec           IN OUT NOCOPY  fa_api_types.asset_type_rec_type,
   px_asset_cat_rec            IN OUT NOCOPY  fa_api_types.asset_cat_rec_type,
   px_asset_hierarchy_rec      IN OUT NOCOPY  fa_api_types.asset_hierarchy_rec_type,
   px_asset_fin_rec            IN OUT NOCOPY  fa_api_types.asset_fin_rec_type,
   px_asset_deprn_rec          IN OUT NOCOPY  fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl           IN OUT NOCOPY  fa_api_types.asset_dist_tbl_type,
   -- Invoice Object --
   px_inv_tbl                  IN OUT NOCOPY  fa_api_types.inv_tbl_type,
   x_return_status                OUT NOCOPY VARCHAR2,
   p_calling_fn                IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

function insert_asset (
   p_trans_rec              IN OUT NOCOPY fa_api_types.trans_rec_type,
   p_dist_trans_rec         IN     fa_api_types.trans_rec_type,
   p_asset_hdr_rec          IN     fa_api_types.asset_hdr_rec_type,
   p_asset_desc_rec         IN     fa_api_types.asset_desc_rec_type,
   p_asset_type_rec         IN     fa_api_types.asset_type_rec_type,
   p_asset_cat_rec          IN     fa_api_types.asset_cat_rec_type,
   p_asset_hierarchy_rec    IN     fa_api_types.asset_hierarchy_rec_type,
   p_asset_fin_rec          IN OUT NOCOPY fa_api_types.asset_fin_rec_type,
   p_asset_deprn_rec        IN     fa_api_types.asset_deprn_rec_type,
   px_asset_dist_tbl        IN OUT NOCOPY fa_api_types.asset_dist_tbl_type,
   p_inv_trans_rec          IN     fa_api_types.inv_trans_rec_type,
   p_primary_cost           IN     NUMBER,
   p_exchange_rate          IN     NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   p_mrc_sob_type_code      IN     VARCHAR2,
   p_period_rec             IN     fa_api_types.period_rec_type,
   p_calling_fn             IN     VARCHAR2
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return BOOLEAN;

END FA_ADDITION_PVT;

/
