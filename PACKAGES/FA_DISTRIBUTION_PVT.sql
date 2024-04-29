--------------------------------------------------------
--  DDL for Package FA_DISTRIBUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DISTRIBUTION_PVT" AUTHID CURRENT_USER as
/* $Header: FAVDISTS.pls 120.2.12010000.3 2009/07/19 11:40:50 glchen ship $   */


FUNCTION do_distribution(px_trans_rec          IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                        px_asset_hdr_rec       IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                        px_asset_cat_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
                        px_asset_dist_tbl      IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
                        p_validation_level     IN NUMBER :=
FND_API.G_VALID_LEVEL_FULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
                RETURN BOOLEAN;


FUNCTION do_validation(p_trans_rec             IN     FA_API_TYPES.trans_rec_type,
                       p_asset_hdr_rec         IN     FA_API_TYPES.asset_hdr_rec_type,
		       p_asset_cat_rec_new     IN     FA_API_TYPES.asset_cat_rec_type,
                       px_asset_dist_tbl       IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
		       p_old_units             IN     NUMBER,
		       x_total_txn_units       OUT NOCOPY    NUMBER,
                       p_validation_level      IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;


FUNCTION valid_dist_data(p_trans_rec         IN      FA_API_TYPES.trans_rec_type,
                         p_asset_hdr_rec     IN      FA_API_TYPES.asset_hdr_rec_type,
                         p_asset_dist_tbl   IN OUT NOCOPY   FA_API_TYPES.asset_dist_tbl_type,
                         p_curr_index     IN   NUMBER,
                         p_validation_level     IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

/*
FUNCTION get_total_txn_units(p_trans_rec       IN  FA_API_TYPES.trans_rec_type,
			     p_asset_dist_tbl  IN  FA_API_TYPES.asset_dist_tbl_type,
                             x_total_units     IN OUT NOCOPY number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN; */

FUNCTION units_in_sync(p_asset_hdr_rec IN FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

FUNCTION insert_txn_headers(px_trans_rec     IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec IN     FA_API_TYPES.asset_hdr_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

FUNCTION update_asset_history(p_trans_rec           IN   FA_API_TYPES.trans_rec_type,
                               p_asset_hdr_rec      IN   FA_API_TYPES.asset_hdr_rec_type,
                               p_asset_cat_rec_new  IN   FA_API_TYPES.asset_cat_rec_type,
                               p_asset_desc_rec_new IN   FA_API_TYPES.asset_desc_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

FUNCTION update_additions( p_trans_rec         IN   FA_API_TYPES.trans_rec_type,
                          p_asset_hdr_rec      IN   FA_API_TYPES.asset_hdr_rec_type,
                          p_asset_cat_rec_new  IN   FA_API_TYPES.asset_cat_rec_type,
                          p_asset_desc_rec_new IN   FA_API_TYPES.asset_desc_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

FUNCTION update_books(p_trans_rec      IN   FA_API_TYPES.trans_rec_type,
                      p_asset_hdr_rec  IN   FA_API_TYPES.asset_hdr_rec_type,
                      p_period_rec     IN   FA_API_TYPES.period_rec_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;

FUNCTION update_dist_history(p_trans_rec       IN     FA_API_TYPES.trans_rec_type,
                             p_asset_hdr_rec   IN   FA_API_TYPES.asset_hdr_rec_type,
                             p_asset_dist_tbl  IN   FA_API_TYPES.asset_dist_tbl_type, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
		RETURN BOOLEAN;


END FA_DISTRIBUTION_PVT;

/
