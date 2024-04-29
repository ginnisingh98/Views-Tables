--------------------------------------------------------
--  DDL for Package IGF_AW_DP_TEACH_PRDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_DP_TEACH_PRDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI61S.pls 120.0 2005/06/02 15:47:51 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adteach_id                        IN OUT NOCOPY NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_adteach_id                        IN     NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adteach_id                        IN OUT NOCOPY NUMBER,
    x_adterms_id                        IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_tp_perct_num                      IN     NUMBER,
    x_date_offset_cd                    IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
  x_cal_type                          IN     VARCHAR2,
  x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_adteach_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_dp_terms (
    x_adterms_id                        IN     NUMBER
  );

  FUNCTION get_uk_for_validation(
                                  x_adterms_id           IN NUMBER,
                                  x_tp_cal_type          IN VARCHAR2,
                                  x_tp_sequence_number   IN NUMBER,
                                  x_date_offset_cd       IN VARCHAR2
                                ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_adteach_id                        IN     NUMBER      DEFAULT NULL,
    x_adterms_id                        IN     NUMBER      DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_tp_perct_num                      IN     NUMBER      DEFAULT NULL,
    x_date_offset_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_credit_points_num                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_dp_teach_prds_pkg;

 

/
