--------------------------------------------------------
--  DDL for Package IGF_AP_PERSON_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_PERSON_MATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI42S.pls 115.3 2002/11/28 14:01:42 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_apm_id                            IN OUT NOCOPY NUMBER,
    x_css_id                            IN     NUMBER,
    x_si_id                             IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_date_run                          IN     DATE,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_apm_id                            IN     NUMBER,
    x_css_id                            IN     NUMBER,
    x_si_id                             IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_date_run                          IN     DATE,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_record_status                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_apm_id                            IN     NUMBER,
    x_css_id                            IN     NUMBER,
    x_si_id                             IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_date_run                          IN     DATE,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_apm_id                            IN OUT NOCOPY NUMBER,
    x_css_id                            IN     NUMBER,
    x_si_id                             IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_date_run                          IN     DATE,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_record_status                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_apm_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst_all (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_apm_id                            IN     NUMBER      DEFAULT NULL,
    x_css_id                            IN     NUMBER      DEFAULT NULL,
    x_si_id                             IN     NUMBER      DEFAULT NULL,
    x_record_type                       IN     VARCHAR2    DEFAULT NULL,
    x_date_run                          IN     DATE        DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_record_status                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_person_match_pkg;

 

/
