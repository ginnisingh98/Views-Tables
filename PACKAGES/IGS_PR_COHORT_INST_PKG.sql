--------------------------------------------------------
--  DDL for Package IGS_PR_COHORT_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_COHORT_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI42S.pls 115.2 2002/11/29 03:25:50 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_cohort_status                     IN     VARCHAR2,
    x_rank_status                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_cohort_status                     IN     VARCHAR2,
    x_rank_status                       IN     VARCHAR2,
    x_run_date                          IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_cohort_status                     IN     VARCHAR2,
    x_rank_status                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_cohort_status                     IN     VARCHAR2,
    x_rank_status                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_cohort_name                       IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_cohort (
    x_cohort_name                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cohort_name                       IN     VARCHAR2    DEFAULT NULL,
    x_load_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_load_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_cohort_status                     IN     VARCHAR2    DEFAULT NULL,
    x_rank_status                       IN     VARCHAR2    DEFAULT NULL,
    x_run_date                          IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_cohort_inst_pkg;

 

/
