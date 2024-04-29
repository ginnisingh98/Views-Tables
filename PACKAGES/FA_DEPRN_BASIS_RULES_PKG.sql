--------------------------------------------------------
--  DDL for Package FA_DEPRN_BASIS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_BASIS_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: faxtdbrs.pls 120.6.12010000.2 2009/07/19 13:07:09 glchen ship $ */

  PROCEDURE Insert_Row(	X_deprn_basis_rule_id		IN OUT NOCOPY NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2 DEFAULT NULL,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_created_by			NUMBER,
			X_creation_date			DATE,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2 DEFAULT NULL,
			X_calculation_basis		VARCHAR2 DEFAULT NULL,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Lock_Row (	X_deprn_basis_rule_id	NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2 DEFAULT NULL,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2 DEFAULT NULL,
			X_calculation_basis		VARCHAR2 DEFAULT NULL,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Update_Row( X_deprn_basis_rule_id		NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2 DEFAULT NULL,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2 DEFAULT NULL,
			X_calculation_basis		VARCHAR2 DEFAULT NULL,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE Delete_Row(X_deprn_basis_rule_id 	NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE LOAD_ROW (  X_deprn_basis_rule_id		NUMBER,
			X_owner				VARCHAR2,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2 DEFAULT NULL,
			X_rate_source			VARCHAR2 DEFAULT NULL,
			X_calculation_basis		VARCHAR2 DEFAULT NULL,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

   /*Bug 8355119 overloading function for release specific signatures*/
   PROCEDURE LOAD_ROW (X_custom_mode         IN VARCHAR2,
                      X_deprn_basis_rule_id IN NUMBER,
                      X_owner               IN VARCHAR2,
                      X_last_update_date    IN DATE,
                      X_rule_name           IN VARCHAR2,
                      X_user_rule_name      IN VARCHAR2 DEFAULT NULL,
                      X_rate_source         IN VARCHAR2 DEFAULT NULL,
                      X_calculation_basis   IN VARCHAR2 DEFAULT NULL,
                      X_enabled_flag        IN VARCHAR2,
                      X_program_name        IN VARCHAR2,
                      X_description         IN VARCHAR2 DEFAULT NULL,
                      p_log_level_rec       IN FA_API_TYPES.log_level_rec_type
                                                        DEFAULT NULL);

  procedure TRANSLATE_ROW (
		X_DEPRN_BASIS_RULE_ID in NUMBER,
		X_OWNER	in VARCHAR2,
		X_USER_RULE_NAME in VARCHAR2 DEFAULT NULL,
		X_RULE_NAME      in VARCHAR2 DEFAULT NULL,
                X_DESCRIPTION    in VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);
  /*Bug 8355119 overloading function for release specific signatures*/
  procedure TRANSLATE_ROW (
      X_CUSTOM_MODE         in VARCHAR2,
      X_DEPRN_BASIS_RULE_ID in NUMBER,
      X_OWNER	            in VARCHAR2,
      X_LAST_UPDATE_DATE    in DATE,
      X_USER_RULE_NAME      in VARCHAR2 DEFAULT NULL,
      X_RULE_NAME           in VARCHAR2 DEFAULT NULL,
      X_DESCRIPTION         in VARCHAR2 DEFAULT NULL,
      p_log_level_rec       IN FA_API_TYPES.log_level_rec_type default null );
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
                X_upload_mode                   IN VARCHAR2,
                X_custom_mode                   IN VARCHAR2,
                X_deprn_basis_rule_id           IN NUMBER,
                X_owner                         IN VARCHAR2,
                X_last_update_date              IN DATE,
                X_rule_name                     IN VARCHAR2,
                X_user_rule_name                IN VARCHAR2,
                X_description                   IN VARCHAR2,
                X_enabled_flag                  IN VARCHAR2,
                X_program_name                  IN VARCHAR2);

END FA_DEPRN_BASIS_RULES_PKG;

/
