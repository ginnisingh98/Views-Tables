--------------------------------------------------------
--  DDL for Package FA_RECLASS_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RECLASS_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: FAVRCUTS.pls 120.3.12010000.2 2009/07/19 11:29:59 glchen ship $   */


FUNCTION validate_CIP_accounts(
         p_transaction_type_code  IN  VARCHAR2,
         p_book_type_code         IN  VARCHAR2,
         p_asset_type             IN  VARCHAR2,
         p_category_id            IN  VARCHAR2,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION check_cat_book_setup(
         p_transaction_type_code  IN  VARCHAR2,
         p_new_category_id        IN  NUMBER,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_cat_types(
         p_transaction_type_code  IN  VARCHAR2,
         p_old_cat_id             IN  NUMBER,
         p_new_cat_id             IN  NUMBER,
         p_lease_id               IN  NUMBER,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_units(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_pending_retire(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_fully_retired(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_prior_per_add (
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
         p_book                   IN  VARCHAR2,
         p_calling_fn             IN  VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION validate_transaction_date(
         p_trans_rec       IN     FA_API_TYPES.trans_rec_type,
         p_asset_id        IN     NUMBER,
         p_book            IN     VARCHAR2,
         p_calling_fn      IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION Validate_Adjustment(
         p_transaction_type_code  IN  VARCHAR2,
         p_asset_id               IN  NUMBER,
	      p_book_type_code	       IN  VARCHAR2,
	      p_amortize_flag		    IN  VARCHAR2,
	      p_mr_req_id		          IN  NUMBER := -1 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION get_new_ccid(
         p_trans_rec          IN      FA_API_TYPES.trans_rec_type,
         p_asset_hdr_rec      IN      FA_API_TYPES.asset_hdr_rec_type,
         p_asset_cat_rec_new  IN      FA_API_TYPES.asset_cat_rec_type,
         p_dist_rec_old       IN      FA_API_TYPES.asset_dist_rec_type,
         px_dist_rec_new      IN OUT NOCOPY  FA_API_TYPES.asset_dist_rec_type , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION get_asset_distribution(
         p_trans_rec            IN     FA_API_TYPES.trans_rec_type,
         p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
         p_asset_cat_rec_old    IN     FA_API_TYPES.asset_cat_rec_type,
         p_asset_cat_rec_new    IN     FA_API_TYPES.asset_cat_rec_type,
         px_asset_dist_tbl      IN OUT NOCOPY FA_API_TYPES.asset_dist_tbl_type,
         p_calling_fn           IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION get_cat_desc_flex(
         p_asset_hdr_rec        IN     FA_API_TYPES.asset_hdr_rec_type,
         px_asset_desc_rec      IN OUT NOCOPY FA_API_TYPES.asset_desc_rec_type,
         p_asset_cat_rec_old    IN     FA_API_TYPES.asset_cat_rec_type,
         px_asset_cat_rec_new   IN OUT NOCOPY FA_API_TYPES.asset_cat_rec_type,
         p_recl_opt_rec         IN     FA_API_TYPES.reclass_options_rec_type,
         p_calling_fn           IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

FUNCTION check_bal_seg_equal(
         p_old_category_id   IN NUMBER,
         p_new_category_id   IN NUMBER,
         p_calling_fn        IN VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;

END FA_RECLASS_UTIL_PVT;

/
