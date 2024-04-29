--------------------------------------------------------
--  DDL for Package IGI_IAC_PROJ_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_PROJ_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: igiiapds.pls 120.4.12000000.1 2007/08/01 16:15:51 npandya ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_projection_id                     IN     NUMBER,
    x_period_counter                    IN     NUMBER,
    x_fiscal_year                       IN     NUMBER,
    x_company                           IN     VARCHAR2,
    x_cost_center                       IN     VARCHAR2,
    x_account                           IN     VARCHAR2,
    x_asset_id                          IN     NUMBER,
    x_latest_reval_cost                 IN     NUMBER,
    x_deprn_period                      IN     NUMBER,
    x_deprn_ytd                         IN     NUMBER,
    x_deprn_reserve                     IN     NUMBER,
    x_asset_exception                   IN     VARCHAR2,
    x_revaluation_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_projection_id                     IN     NUMBER,
    x_asset_id                          IN     NUMBER,
    x_period_counter                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_iac_projections (
    x_projection_id                     IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_projection_id                     IN     NUMBER      DEFAULT NULL,
    x_period_counter                    IN     NUMBER      DEFAULT NULL,
    x_fiscal_year                       IN     NUMBER      DEFAULT NULL,
    x_company                           IN     VARCHAR2    DEFAULT NULL,
    x_cost_center                       IN     VARCHAR2    DEFAULT NULL,
    x_account                           IN     VARCHAR2    DEFAULT NULL,
    x_asset_id                          IN     NUMBER      DEFAULT NULL,
    x_latest_reval_cost                 IN     NUMBER      DEFAULT NULL,
    x_deprn_period                      IN     NUMBER      DEFAULT NULL,
    x_deprn_ytd                         IN     NUMBER      DEFAULT NULL,
    x_deprn_reserve                     IN     NUMBER      DEFAULT NULL,
    x_asset_exception                   IN     VARCHAR2    DEFAULT NULL,
    x_revaluation_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_iac_proj_details_pkg;

 

/
