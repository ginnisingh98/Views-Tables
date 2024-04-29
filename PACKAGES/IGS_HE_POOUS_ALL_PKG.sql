--------------------------------------------------------
--  DDL for Package IGS_HE_POOUS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_POOUS_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI17S.pls 120.1 2006/05/22 09:25:17 jchakrab noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_id                     IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_fte_calc_type                                 IN     VARCHAR2    DEFAULT NULL,
    x_teach_period_start_dt                     IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt                       IN     DATE        DEFAULT NULL,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_funding_source                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_poous_id                     IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
    x_fte_intensity                     IN     NUMBER      DEFAULT NULL,
    x_fte_calc_type                                 IN     VARCHAR2    DEFAULT NULL,
    x_teach_period_start_dt                     IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt                       IN     DATE        DEFAULT NULL,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_funding_source                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_poous_id                     IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
        x_fte_intensity                     IN     NUMBER          DEFAULT NULL,
    x_fte_calc_type                                 IN     VARCHAR2    DEFAULT NULL,
    x_teach_period_start_dt                     IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt                       IN     DATE        DEFAULT NULL,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_funding_source                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_poous_id                     IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_location_of_study                 IN     VARCHAR2,
    x_mode_of_study                     IN     VARCHAR2,
    x_ufi_place                         IN     VARCHAR2,
    x_franchising_activity              IN     VARCHAR2,
    x_type_of_year                      IN     VARCHAR2,
    x_leng_current_year                 IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_credit_value_yop1                 IN     NUMBER,
    x_level_credit1                     IN     VARCHAR2,
    x_credit_value_yop2                 IN     NUMBER,
    x_level_credit2                     IN     VARCHAR2,
    x_credit_value_yop3                 IN     NUMBER,
    x_level_credit3                     IN     VARCHAR2,
    x_credit_value_yop4                 IN     NUMBER,
    x_level_credit4                     IN     VARCHAR2,
        x_fte_intensity                     IN     NUMBER          DEFAULT NULL,
    x_fte_calc_type                                 IN     VARCHAR2    DEFAULT NULL,
    x_teach_period_start_dt                     IN     DATE        DEFAULT NULL,
    x_teach_period_end_dt                       IN     DATE        DEFAULT NULL,
    x_other_instit_teach1               IN     VARCHAR2,
    x_other_instit_teach2               IN     VARCHAR2,
    x_prop_not_taught                   IN     NUMBER,
    x_fundability_cd                    IN     VARCHAR2,
    x_fee_band                          IN     VARCHAR2,
    x_level_applicable_to_funding       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_funding_source                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hesa_poous_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_ofr_opt_all (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_unit_set_all (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_ofr_unit_set (
    x_course_cd                           IN     VARCHAR2,
    x_version_number                      IN     NUMBER,
    x_cal_type                            IN     VARCHAR2,
    x_unit_set_cd                         IN     VARCHAR2,
    x_us_version_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_poous_id                     IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_crv_version_number                IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_us_version_number                 IN     NUMBER      DEFAULT NULL,
    x_location_of_study                 IN     VARCHAR2    DEFAULT NULL,
    x_mode_of_study                     IN     VARCHAR2    DEFAULT NULL,
    x_ufi_place                         IN     VARCHAR2    DEFAULT NULL,
    x_franchising_activity              IN     VARCHAR2    DEFAULT NULL,
    x_type_of_year                      IN     VARCHAR2    DEFAULT NULL,
    x_leng_current_year                 IN     NUMBER      DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_credit_value_yop1                 IN     NUMBER      DEFAULT NULL,
    x_level_credit1                     IN     VARCHAR2    DEFAULT NULL,
    x_credit_value_yop2                 IN     NUMBER      DEFAULT NULL,
    x_level_credit2                     IN     VARCHAR2    DEFAULT NULL,
    x_credit_value_yop3                 IN     NUMBER      DEFAULT NULL,
    x_level_credit3                     IN     VARCHAR2    DEFAULT NULL,
    x_credit_value_yop4                 IN     NUMBER      DEFAULT NULL,
    x_level_credit4                     IN     VARCHAR2    DEFAULT NULL,
        x_fte_intensity                     IN     NUMBER          DEFAULT NULL,
    x_fte_calc_type                                 IN     VARCHAR2    DEFAULT NULL,
    x_teach_period_start_dt                     IN     DATE            DEFAULT NULL,
    x_teach_period_end_dt                       IN     DATE            DEFAULT NULL,
    x_other_instit_teach1               IN     VARCHAR2    DEFAULT NULL,
    x_other_instit_teach2               IN     VARCHAR2    DEFAULT NULL,
    x_prop_not_taught                   IN     NUMBER      DEFAULT NULL,
    x_fundability_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_fee_band                          IN     VARCHAR2    DEFAULT NULL,
    x_level_applicable_to_funding       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_funding_source                    IN     VARCHAR2    DEFAULT NULL
  );

END igs_he_poous_all_pkg;

 

/
