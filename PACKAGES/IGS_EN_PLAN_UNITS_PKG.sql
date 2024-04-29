--------------------------------------------------------
--  DDL for Package IGS_EN_PLAN_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_PLAN_UNITS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI79S.pls 120.0 2005/09/13 09:43:51 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_no_assessment_ind                 IN     VARCHAR2,
    x_sup_uoo_id                        IN     NUMBER,
    x_override_enrolled_cp              IN     NUMBER,
    x_grading_schema_code               IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_alternative_title                 IN     VARCHAR2,
    x_cart_error_flag                   IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_cart_error_flag                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_spa_terms (
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_term_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_term_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_no_assessment_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_sup_uoo_id                        IN     NUMBER      DEFAULT NULL,
    x_override_enrolled_cp              IN     NUMBER      DEFAULT NULL,
    x_grading_schema_code               IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_core_indicator_code               IN     VARCHAR2    DEFAULT NULL,
    x_alternative_title                 IN     VARCHAR2    DEFAULT NULL,
    x_cart_error_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_session_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

PROCEDURE before_insert_update (p_action IN VARCHAR2);
END igs_en_plan_units_pkg;

 

/
