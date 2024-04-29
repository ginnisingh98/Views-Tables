--------------------------------------------------------
--  DDL for Package IGS_AS_SUAAI_OUHIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SUAAI_OUHIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI59S.pls 115.5 2003/12/03 09:01:38 ijeddy noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ass_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_creation_dt                       IN     DATE,
    x_hist_start_dt                     IN     DATE,
    x_person_id                         IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_su_atmpt_itm (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_as_sua_ai_group (
    x_sua_ass_item_group_id             IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ass_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_dt                       IN     DATE        DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_grade                             IN     VARCHAR2    DEFAULT NULL,
    x_outcome_dt                        IN     DATE        DEFAULT NULL,
    x_mark                              IN     NUMBER      DEFAULT NULL,
    x_outcome_comment_code              IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  );

END igs_as_suaai_ouhist_pkg;

 

/
