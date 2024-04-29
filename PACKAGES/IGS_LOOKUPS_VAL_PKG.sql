--------------------------------------------------------
--  DDL for Package IGS_LOOKUPS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_LOOKUPS_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSMI17S.pls 115.4 2003/05/09 05:07:08 pkpatel noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lookup_type                       IN OUT NOCOPY VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lookup_type                       IN OUT NOCOPY VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lookup_type                       IN     VARCHAR2    DEFAULT NULL,
    x_lookup_code                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_security_allowed_ind              IN     VARCHAR2    DEFAULT NULL,
    x_step_type_restriction_num_in     IN     VARCHAR2    DEFAULT NULL,
    x_unit_outcome_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_display_name                      IN     VARCHAR2    DEFAULT NULL,
    x_display_order                     IN     NUMBER      DEFAULT NULL,
    x_step_order_applicable_ind         IN     VARCHAR2    DEFAULT NULL,
    x_academic_transcript_ind           IN     VARCHAR2    DEFAULT NULL,
    x_cmpltn_requirements_ind           IN     VARCHAR2    DEFAULT NULL,
    x_fee_ass_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_step_group_type                   IN     VARCHAR2    DEFAULT NULL,
    x_final_result_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_system_generated_ind              IN     VARCHAR2    DEFAULT NULL,
    x_transaction_cat                   IN     VARCHAR2    DEFAULT NULL,
    x_encumbrance_level                 IN     NUMBER      DEFAULT NULL,
    x_open_for_enrollments              IN     VARCHAR2    DEFAULT NULL,
    x_system_calculated                 IN     VARCHAR2    DEFAULT NULL,
    x_system_mandatory_ind              IN     VARCHAR2    DEFAULT NULL,
    x_default_display_seq               IN     NUMBER      DEFAULT NULL,
    x_av_transcript_disp_options        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_lookups_val_pkg;

 

/
