--------------------------------------------------------
--  DDL for Package IGF_SL_DL_CHG_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_CHG_FLD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI16S.pls 115.5 2002/11/28 14:25:11 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dchg_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dchg_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dchg_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dchg_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dchg_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_dl_version                        IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_dl_version                        IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dchg_id                           IN     NUMBER      DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_loan_catg                         IN     VARCHAR2    DEFAULT NULL,
    x_fld_name                          IN     VARCHAR2    DEFAULT NULL,
    x_fld_length                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_dl_chg_fld_pkg;

 

/
