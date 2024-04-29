--------------------------------------------------------
--  DDL for Package IGS_LOOKUPS_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_LOOKUPS_VIEW_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI14S.pls 115.6 2003/05/09 05:06:13 pkpatel ship $ */

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

FUNCTION Get_PK_For_Validation (
    X_LOOKUP_TYPE in VARCHAR2,
    X_LOOKUP_CODE in VARCHAR2
   )RETURN BOOLEAN ;

end IGS_LOOKUPS_VIEW_PKG;

 

/
