--------------------------------------------------------
--  DDL for Package IGS_PR_STU_ACAD_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STU_ACAD_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI39S.pls 115.2 2003/07/31 05:47:11 nalkumar noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
    x_timeframe                         IN     VARCHAR2,
    x_source_type                       IN     VARCHAR2,
    x_source_reference                  IN     VARCHAR2,
    x_attempted_credit_points           IN     NUMBER,
    x_earned_credit_points              IN     NUMBER,
    x_gpa                               IN     NUMBER,
    x_gpa_credit_points                 IN     NUMBER,
    x_gpa_quality_points                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_stat_type                         IN     VARCHAR2,
		x_timeframe                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_stdnt_ps_att(
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst(
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  );

   PROCEDURE get_fk_igs_pr_stat_type (
    x_stat_type                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_timeframe                         IN     VARCHAR2    DEFAULT NULL,
    x_source_type                       IN     VARCHAR2    DEFAULT NULL,
    x_source_reference                  IN     VARCHAR2    DEFAULT NULL,
    x_attempted_credit_points           IN     NUMBER      DEFAULT NULL,
    x_earned_credit_points              IN     NUMBER      DEFAULT NULL,
    x_gpa                               IN     NUMBER      DEFAULT NULL,
    x_gpa_credit_points                 IN     NUMBER      DEFAULT NULL,
    x_gpa_quality_points                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_stu_acad_stat_pkg;


 

/
