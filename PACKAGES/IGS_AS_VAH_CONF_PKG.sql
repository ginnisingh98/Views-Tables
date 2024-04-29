--------------------------------------------------------
--  DDL for Package IGS_AS_VAH_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAH_CONF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI77S.pls 115.2 2003/12/08 10:04:46 ijeddy noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_configuration_id                  IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_configuration_id                  IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_configuration_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_course_type                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_configuration_id                  IN     NUMBER      DEFAULT NULL,
    x_course_type                       IN     VARCHAR2    DEFAULT NULL,
    x_display_order_flag                IN     VARCHAR2    DEFAULT NULL,
    x_start_note_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_program_region_flag               IN     VARCHAR2    DEFAULT NULL,
    x_test_score_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_sum_adv_stnd_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_admission_note_flag               IN     VARCHAR2    DEFAULT NULL,
    x_term_region_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_unit_details_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_unit_note_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_adv_stnd_unit_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2    DEFAULT NULL,
    x_statistics_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_class_rank_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_intermission_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_special_req_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_period_note_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_awards_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_prog_completion_flag              IN     VARCHAR2    DEFAULT NULL,
    x_degree_note_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_end_note_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  );

END igs_as_vah_conf_pkg;

 

/
