--------------------------------------------------------
--  DDL for Package FA_ASSET_HIERARCHY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ASSET_HIERARCHY_PVT" AUTHID CURRENT_USER as
/* $Header: FAVAHRS.pls 120.1.12010000.2 2009/07/19 11:37:00 glchen ship $   */



FUNCTION validate_parent ( p_parent_hierarchy_id in number,
                           p_book_type_code      in varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION add_asset(
         p_asset_hdr_rec         IN   FA_API_TYPES.asset_hdr_rec_type,
         p_asset_hierarchy_rec   IN   FA_API_TYPES.asset_hierarchy_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION derive_asset_attribute(
                px_asset_hdr_rec            IN OUT NOCOPY  fa_api_types.asset_hdr_rec_type,
                px_asset_desc_rec           IN OUT NOCOPY  fa_api_types.asset_desc_rec_type,
                px_asset_cat_rec            IN OUT NOCOPY  fa_api_types.asset_cat_rec_type,
                px_asset_hierarchy_rec      IN OUT NOCOPY  fa_api_types.asset_hierarchy_rec_type,
                px_asset_fin_rec            IN OUT NOCOPY  fa_api_types.asset_fin_rec_type,
                px_asset_dist_tbl           IN OUT NOCOPY  fa_api_types.asset_dist_tbl_type,
                p_derivation_type           IN       varchar2  DEFAULT 'ALL',
                p_calling_function          IN       varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  return boolean;

FUNCTION load_distributions(
              p_hr_dist_set_id     IN     number,
              p_asset_units        IN     number,
              px_asset_dist_tbl    IN OUT NOCOPY fa_api_types.asset_dist_tbl_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION create_batch(
         p_asset_hdr_rec         IN   FA_API_TYPES.asset_hdr_rec_type,
         p_trans_rec             IN   FA_API_TYPES.trans_rec_type,
         p_asset_hr_opt_rec      IN   FA_API_TYPES.asset_hr_options_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

END FA_ASSET_HIERARCHY_PVT;

/
