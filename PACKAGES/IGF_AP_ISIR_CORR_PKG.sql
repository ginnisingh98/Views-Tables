--------------------------------------------------------
--  DDL for Package IGF_AP_ISIR_CORR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ISIR_CORR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI21S.pls 115.8 2002/11/28 13:56:43 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_isirc_id                          IN OUT NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_isirc_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_isirc_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_isirc_id                          IN OUT NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_sar_field_number                  IN     NUMBER,
    x_original_value                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_corrected_value                   IN     VARCHAR2,
    x_correction_status                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_isirc_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_isir_id                           IN     NUMBER,
    x_sar_field_number                  IN     NUMBER,
    x_correction_status                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_isir_matched (
    x_isir_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst_all (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_isirc_id                          IN     NUMBER      DEFAULT NULL,
    x_isir_id                           IN     NUMBER      DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_sar_field_number                  IN     NUMBER      DEFAULT NULL,
    x_original_value                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_corrected_value                   IN     VARCHAR2    DEFAULT NULL,
    x_correction_status                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_isir_corr_pkg;

 

/
