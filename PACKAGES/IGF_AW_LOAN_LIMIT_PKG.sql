--------------------------------------------------------
--  DDL for Package IGF_AW_LOAN_LIMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_LOAN_LIMIT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI35S.pls 115.5 2002/11/28 14:41:58 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_allt_id                           IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_depend_stat                       IN     VARCHAR2,
    x_ffelp_grade_level                 IN     VARCHAR2,
    x_dl_grade_level                    IN     VARCHAR2,
    x_subs_annual_lt                    IN     NUMBER,
    x_tot_annual_lt                     IN     NUMBER,
    x_subs_aggr_lt                      IN     NUMBER,
    x_tot_aggr_lt                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_allt_id                           IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_depend_stat                       IN     VARCHAR2,
    x_ffelp_grade_level                 IN     VARCHAR2,
    x_dl_grade_level                    IN     VARCHAR2,
    x_subs_annual_lt                    IN     NUMBER,
    x_tot_annual_lt                     IN     NUMBER,
    x_subs_aggr_lt                      IN     NUMBER,
    x_tot_aggr_lt                       IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_allt_id                           IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_depend_stat                       IN     VARCHAR2,
    x_ffelp_grade_level                 IN     VARCHAR2,
    x_dl_grade_level                    IN     VARCHAR2,
    x_subs_annual_lt                    IN     NUMBER,
    x_tot_annual_lt                     IN     NUMBER,
    x_subs_aggr_lt                      IN     NUMBER,
    x_tot_aggr_lt                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_allt_id                           IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_depend_stat                       IN     VARCHAR2,
    x_ffelp_grade_level                 IN     VARCHAR2,
    x_dl_grade_level                    IN     VARCHAR2,
    x_subs_annual_lt                    IN     NUMBER,
    x_tot_annual_lt                     IN     NUMBER,
    x_subs_aggr_lt                      IN     NUMBER,
    x_tot_aggr_lt                       IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_allt_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ffelp_grade_level                 IN     VARCHAR2,
    x_dl_grade_level                    IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_depend_stat                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_allt_id                           IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_depend_stat                       IN     VARCHAR2    DEFAULT NULL,
    x_ffelp_grade_level                 IN     VARCHAR2    DEFAULT NULL,
    x_dl_grade_level                    IN     VARCHAR2    DEFAULT NULL,
    x_subs_annual_lt                    IN     NUMBER      DEFAULT NULL,
    x_tot_annual_lt                     IN     NUMBER      DEFAULT NULL,
    x_subs_aggr_lt                      IN     NUMBER      DEFAULT NULL,
    x_tot_aggr_lt                       IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_loan_limit_pkg;

 

/
