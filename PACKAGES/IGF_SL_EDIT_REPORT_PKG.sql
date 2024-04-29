--------------------------------------------------------
--  DDL for Package IGF_SL_EDIT_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_EDIT_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI20S.pls 115.3 2002/11/28 14:26:08 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_edtr_id                           IN OUT NOCOPY NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_orig_chg_code                     IN     VARCHAR2,
    x_sl_error_type                     IN     VARCHAR2,
    x_sl_error_code                     IN     VARCHAR2,
    x_field_name                        IN     VARCHAR2,
    x_field_value                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_edtr_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_orig_chg_code                     IN     VARCHAR2,
    x_sl_error_type                     IN     VARCHAR2,
    x_sl_error_code                     IN     VARCHAR2,
    x_field_name                        IN     VARCHAR2,
    x_field_value                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_edtr_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_orig_chg_code                     IN     VARCHAR2,
    x_sl_error_type                     IN     VARCHAR2,
    x_sl_error_code                     IN     VARCHAR2,
    x_field_name                        IN     VARCHAR2,
    x_field_value                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_edtr_id                           IN OUT NOCOPY NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_orig_chg_code                     IN     VARCHAR2,
    x_sl_error_type                     IN     VARCHAR2,
    x_sl_error_code                     IN     VARCHAR2,
    x_field_name                        IN     VARCHAR2,
    x_field_value                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_edtr_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_edtr_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_orig_chg_code                     IN     VARCHAR2    DEFAULT NULL,
    x_sl_error_type                     IN     VARCHAR2    DEFAULT NULL,
    x_sl_error_code                     IN     VARCHAR2    DEFAULT NULL,
    x_field_name                        IN     VARCHAR2    DEFAULT NULL,
    x_field_value                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_edit_report_pkg;

 

/
