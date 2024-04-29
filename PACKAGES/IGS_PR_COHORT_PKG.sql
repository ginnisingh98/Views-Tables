--------------------------------------------------------
--  DDL for Package IGS_PR_COHORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_COHORT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI41S.pls 115.3 2002/11/29 03:25:33 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cohort_name                       IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_dflt_display_type                 IN     VARCHAR2,
    x_dense_rank_ind                    IN     VARCHAR2,
    x_incl_on_transcript_ind            IN     VARCHAR2,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2,
    x_rule_sequence_number              IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_cohort_name                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ru_rule (
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cohort_name                       IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_timeframe                         IN     VARCHAR2    DEFAULT NULL,
    x_dflt_display_type                 IN     VARCHAR2    DEFAULT NULL,
    x_dense_rank_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_incl_on_transcript_ind            IN     VARCHAR2    DEFAULT NULL,
    x_incl_on_stud_acad_hist_ind        IN     VARCHAR2    DEFAULT NULL,
    x_rule_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_cohort_pkg;

 

/
