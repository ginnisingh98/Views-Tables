--------------------------------------------------------
--  DDL for Package IGF_GR_ATTEND_PELL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_ATTEND_PELL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI21S.pls 120.0 2005/06/01 13:37:21 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acampus_id                        IN OUT NOCOPY NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_acampus_id                        IN     NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acampus_id                        IN OUT NOCOPY NUMBER,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_acampus_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_gr_report_pell (
    x_rcampus_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_acampus_id                        IN     NUMBER      DEFAULT NULL,
    x_rcampus_id                        IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_attending_pell_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_ope_cd                            IN     VARCHAR2    DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE check_uniqueness;

  FUNCTION get_uk1_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_attending_pell_cd                 IN     VARCHAR2
  ) RETURN BOOLEAN;

    FUNCTION get_uk2_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL
  ) RETURN BOOLEAN;
END igf_gr_attend_pell_pkg;

 

/
