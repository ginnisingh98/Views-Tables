--------------------------------------------------------
--  DDL for Package IGS_AS_SU_ATMPTOUT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SU_ATMPTOUT_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI05S.pls 115.6 2003/12/11 09:50:29 kdande ship $ */

  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE delete_row (x_rowid IN VARCHAR2);

  FUNCTION get_pk_for_validation (
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_uoo_id                       IN     NUMBER
  )
    RETURN BOOLEAN;

  PROCEDURE check_constraints (column_name IN VARCHAR2 DEFAULT NULL, column_value IN VARCHAR2 DEFAULT NULL);

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_org_id                       IN     NUMBER DEFAULT NULL,
    x_person_id                    IN     NUMBER DEFAULT NULL,
    x_course_cd                    IN     VARCHAR2 DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_outcome_dt                   IN     DATE DEFAULT NULL,
    x_hist_start_dt                IN     DATE DEFAULT NULL,
    x_hist_end_dt                  IN     DATE DEFAULT NULL,
    x_hist_who                     IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_version_number               IN     NUMBER DEFAULT NULL,
    x_grade                        IN     VARCHAR2 DEFAULT NULL,
    x_s_grade_creation_method_type IN     VARCHAR2 DEFAULT NULL,
    x_finalised_outcome_ind        IN     VARCHAR2 DEFAULT NULL,
    x_mark                         IN     NUMBER DEFAULT NULL,
    x_number_times_keyed           IN     NUMBER DEFAULT NULL,
    x_translated_grading_schema_cd IN     VARCHAR2 DEFAULT NULL,
    x_translated_version_number    IN     NUMBER DEFAULT NULL,
    x_translated_grade             IN     VARCHAR2 DEFAULT NULL,
    x_translated_dt                IN     DATE DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT NULL,
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT NULL
  );
END igs_as_su_atmptout_h_pkg;

 

/
