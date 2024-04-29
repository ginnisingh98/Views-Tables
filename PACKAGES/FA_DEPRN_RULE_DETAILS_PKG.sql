--------------------------------------------------------
--  DDL for Package FA_DEPRN_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_RULE_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: faxtdrds.pls 120.4.12010000.2 2009/07/19 13:08:07 glchen ship $ */

  PROCEDURE Insert_Row(
			p_deprn_rule_detail_id		IN OUT NOCOPY NUMBER,
			p_deprn_basis_rule_id		IN OUT NOCOPY NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_created_by			NUMBER,
			p_creation_date			DATE,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Lock_Row (
			p_deprn_rule_detail_id		NUMBER,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Update_Row(
			p_deprn_rule_detail_id		NUMBER,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(p_deprn_rule_detail_id 	NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE LOAD_ROW (  p_deprn_rule_detail_id		NUMBER,
			p_owner				VARCHAR2,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  /*Bug 8355119 overloading function for release specific signatures*/
  PROCEDURE LOAD_ROW (
             p_custom_mode               IN VARCHAR2,
             p_deprn_rule_detail_id      IN NUMBER,
             p_owner                     IN VARCHAR2,
             p_last_update_date          IN DATE,
             p_deprn_basis_rule_id       IN NUMBER,
             p_rule_name                 IN VARCHAR2,
             p_rate_source_rule          IN VARCHAR2,
             p_deprn_basis_rule          IN VARCHAR2,
             p_asset_type                IN VARCHAR2,
             p_period_update_flag        IN VARCHAR2,
             p_subtract_ytd_flag         IN VARCHAR2,
             p_allow_reduction_rate_flag IN VARCHAR2,
             p_use_eofy_reserve_flag     IN VARCHAR2,
	     p_use_rsv_after_imp_flag    IN VARCHAR2 DEFAULT NULL,
             p_log_level_rec             IN FA_API_TYPES.log_level_rec_type default null );
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
PROCEDURE LOAD_SEED_ROW (
               p_upload_mode                IN VARCHAR2,
               p_custom_mode                IN VARCHAR2,
               p_deprn_rule_detail_id       IN NUMBER,
               p_owner                      IN VARCHAR2,
               p_last_update_date           IN DATE,
               p_deprn_basis_rule_id        IN NUMBER,
               p_rule_name                  IN VARCHAR2,
               p_rate_source_rule           IN VARCHAR2,
               p_deprn_basis_rule           IN VARCHAR2,
               p_asset_type                 IN VARCHAR2,
               p_period_update_flag         IN VARCHAR2,
               p_subtract_ytd_flag          IN VARCHAR2,
               p_allow_reduction_rate_flag  IN VARCHAR2,
               p_use_eofy_reserve_flag      IN VARCHAR2,
	       p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL);

END FA_DEPRN_RULE_DETAILS_PKG;

/
