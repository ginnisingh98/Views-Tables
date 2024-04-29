--------------------------------------------------------
--  DDL for Package IGF_GR_REPORT_PELL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_REPORT_PELL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI20S.pls 120.0 2005/06/01 13:01:41 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcampus_id                        IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rcampus_id                        IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcampus_id                        IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_reporting_pell_cd                 IN     VARCHAR2,
    x_ope_cd                            IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rcampus_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rcampus_id                        IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_ope_cd                            IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );
    PROCEDURE check_uniqueness;

    FUNCTION get_uk1_for_validation (
      x_rep_pell             IN     VARCHAR2,
      x_ci_cal_type			     IN     VARCHAR2,
      x_ci_sequence_number   IN     NUMBER
  ) RETURN BOOLEAN ;

    FUNCTION get_uk2_for_validation (
      x_ci_cal_type			     IN     VARCHAR2,
      x_ci_sequence_number   IN     NUMBER,
      x_rep_entity_id_txt    IN     VARCHAR2    DEFAULT NULL
  ) RETURN BOOLEAN ;

END igf_gr_report_pell_pkg;

 

/
