--------------------------------------------------------
--  DDL for Package IGI_IAC_CAL_IDX_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_CAL_IDX_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: igiicpvs.pls 120.4.12000000.1 2007/08/01 16:20:51 npandya ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_price_index_link_id           IN     NUMBER,
    x_date_from                         IN     DATE,
    x_date_to                           IN     DATE,
    x_original_price_index_value        IN     NUMBER,
    x_current_price_index_value         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_price_index_link_id           IN     NUMBER,
    x_date_from                         IN     DATE,
    x_date_to                           IN     DATE,
    x_original_price_index_value        IN     NUMBER,
    x_current_price_index_value         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_price_index_link_id           IN     NUMBER,
    x_date_from                         IN     DATE,
    x_date_to                           IN     DATE,
    x_original_price_index_value        IN     NUMBER,
    x_current_price_index_value         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_price_index_link_id           IN     NUMBER,
    x_date_from                         IN     DATE,
    x_date_to                           IN     DATE,
    x_original_price_index_value        IN     NUMBER,
    x_current_price_index_value         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_cal_price_index_link_id           IN     NUMBER,
    x_date_from                         IN     DATE,
    x_date_to                           IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igi_iac_cal_price_idx (
    x_cal_price_index_link_id           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cal_price_index_link_id           IN     NUMBER      DEFAULT NULL,
    x_date_from                         IN     DATE        DEFAULT NULL,
    x_date_to                           IN     DATE        DEFAULT NULL,
    x_original_price_index_value        IN     NUMBER      DEFAULT NULL,
    x_current_price_index_value         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_iac_cal_idx_values_pkg;

 

/
