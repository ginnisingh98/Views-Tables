--------------------------------------------------------
--  DDL for Package IGF_AW_FUND_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FUND_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI04S.pls 120.0 2005/06/02 15:53:43 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_fund_source                       IN     VARCHAR2,
    x_fed_fund_code                     IN     VARCHAR2,
    x_sys_fund_type                     IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_fcat_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_alt_loan_code                     IN     VARCHAR2,
    x_alt_rel_code                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fcat_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fund_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk1_for_validation (
    x_alt_loan_code                     IN     VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igf_aw_fund_type (
    x_fund_type                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igf_sl_cl_recipient (
            x_relationship_cd           IN     VARCHAR2
  );
  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_fund_type                         IN     VARCHAR2    DEFAULT NULL,
    x_fund_source                       IN     VARCHAR2    DEFAULT NULL,
    x_fed_fund_code                     IN     VARCHAR2    DEFAULT NULL,
    x_sys_fund_type                     IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_fcat_id                           IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    x_alt_loan_code                     IN     VARCHAR2    DEFAULT NULL,
    x_alt_rel_code                      IN     VARCHAR2    DEFAULT NULL
  );

END igf_aw_fund_cat_pkg;

 

/
