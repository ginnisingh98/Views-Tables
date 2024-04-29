--------------------------------------------------------
--  DDL for Package IGF_SL_LOANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_LOANS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI09S.pls 120.0 2005/06/01 12:54:50 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2 DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2    DEFAULT NULL,
    x_called_from                       IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_loan_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_loan_number                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_award_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_seq_num                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_loan_per_begin_date               IN     DATE        DEFAULT NULL,
    x_loan_per_end_date                 IN     DATE        DEFAULT NULL,
    x_loan_status                       IN     VARCHAR2    DEFAULT NULL,
    x_loan_status_date                  IN     DATE        DEFAULT NULL,
    x_loan_chg_status                   IN     VARCHAR2    DEFAULT NULL,
    x_loan_chg_status_date              IN     DATE        DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_active_date                       IN     DATE        DEFAULT NULL,
    x_borw_detrm_code                   IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_loans_pkg;

 

/
