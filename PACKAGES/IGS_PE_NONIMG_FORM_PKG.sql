--------------------------------------------------------
--  DDL for Package IGS_PE_NONIMG_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_NONIMG_FORM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA7S.pls 120.1 2006/02/17 06:55:51 gmaheswa noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_form_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_last_session_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_adjudicated_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_sevis_school_id                   IN     NUMBER    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_last_session_flag                 IN     VARCHAR2,
    x_adjudicated_flag                  IN     VARCHAR2,
    x_sevis_school_id                   IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_nonimg_form_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_last_session_flag                 IN     VARCHAR2	   DEFAULT NULL,
    x_adjudicated_flag                  IN     VARCHAR2	   DEFAULT NULL,
    x_sevis_school_id                   IN     NUMBER    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_form_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_print_form                        IN     VARCHAR2,
    x_form_effective_date               IN     DATE,
    x_form_status                       IN     VARCHAR2,
    x_acad_term_length                  IN     VARCHAR2,
    x_tuition_amt                       IN     NUMBER,
    x_living_exp_amt                    IN     NUMBER,
    x_personal_funds_amt                IN     NUMBER,
    x_issue_reason                      IN     VARCHAR2,
    x_commuter_ind                      IN     VARCHAR2,
    x_english_reqd                      IN     VARCHAR2,
    x_length_of_study                   IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_primary_major                     IN     VARCHAR2,
    x_education_level                   IN     VARCHAR2,
    x_educ_lvl_remarks                  IN     VARCHAR2,
    x_depdnt_exp_amt                    IN     NUMBER,
    x_other_exp_amt                     IN     NUMBER,
    x_other_exp_desc                    IN     VARCHAR2,
    x_school_funds_amt                  IN     NUMBER,
    x_school_funds_desc                 IN     VARCHAR2,
    x_other_funds_amt                   IN     NUMBER,
    x_other_funds_desc                  IN     VARCHAR2,
    x_empl_funds_amt                    IN     NUMBER,
    x_remarks                           IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_curr_session_end_date             IN     DATE,
    x_next_session_start_date           IN     DATE,
    x_transfer_from_school              IN     VARCHAR2,
    x_other_reason                      IN     VARCHAR2,
    x_last_reprint_date                 IN     DATE,
    x_reprint_reason                    IN     VARCHAR2,
    x_reprint_remarks                   IN     VARCHAR2,
    x_secondary_major                   IN     VARCHAR2,
    x_minor                             IN     VARCHAR2,
    x_english_reqd_met                  IN     VARCHAR2,
    x_not_reqd_reason                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_last_session_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_adjudicated_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_sevis_school_id                   IN     NUMBER    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_nonimg_form_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_nonimg_form_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_print_form                        IN     VARCHAR2    DEFAULT NULL,
    x_form_effective_date               IN     DATE        DEFAULT NULL,
    x_form_status                       IN     VARCHAR2    DEFAULT NULL,
    x_acad_term_length                  IN     VARCHAR2    DEFAULT NULL,
    x_tuition_amt                       IN     NUMBER      DEFAULT NULL,
    x_living_exp_amt                    IN     NUMBER      DEFAULT NULL,
    x_personal_funds_amt                IN     NUMBER      DEFAULT NULL,
    x_issue_reason                      IN     VARCHAR2    DEFAULT NULL,
    x_commuter_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_english_reqd                      IN     VARCHAR2    DEFAULT NULL,
    x_length_of_study                   IN     VARCHAR2    DEFAULT NULL,
    x_prgm_start_date                   IN     DATE        DEFAULT NULL,
    x_prgm_end_date                     IN     DATE        DEFAULT NULL,
    x_primary_major                     IN     VARCHAR2    DEFAULT NULL,
    x_education_level                   IN     VARCHAR2    DEFAULT NULL,
    x_educ_lvl_remarks                  IN     VARCHAR2    DEFAULT NULL,
    x_depdnt_exp_amt                    IN     NUMBER      DEFAULT NULL,
    x_other_exp_amt                     IN     NUMBER      DEFAULT NULL,
    x_other_exp_desc                    IN     VARCHAR2    DEFAULT NULL,
    x_school_funds_amt                  IN     NUMBER      DEFAULT NULL,
    x_school_funds_desc                 IN     VARCHAR2    DEFAULT NULL,
    x_other_funds_amt                   IN     NUMBER      DEFAULT NULL,
    x_other_funds_desc                  IN     VARCHAR2    DEFAULT NULL,
    x_empl_funds_amt                    IN     NUMBER      DEFAULT NULL,
    x_remarks                           IN     VARCHAR2    DEFAULT NULL,
    x_visa_type                         IN     VARCHAR2    DEFAULT NULL,
    x_curr_session_end_date             IN     DATE        DEFAULT NULL,
    x_next_session_start_date           IN     DATE        DEFAULT NULL,
    x_transfer_from_school              IN     VARCHAR2    DEFAULT NULL,
    x_other_reason                      IN     VARCHAR2    DEFAULT NULL,
    x_last_reprint_date                 IN     DATE        DEFAULT NULL,
    x_reprint_reason                    IN     VARCHAR2    DEFAULT NULL,
    x_reprint_remarks                   IN     VARCHAR2    DEFAULT NULL,
    x_secondary_major                   IN     VARCHAR2    DEFAULT NULL,
    x_minor                             IN     VARCHAR2    DEFAULT NULL,
    x_english_reqd_met                  IN     VARCHAR2    DEFAULT NULL,
    x_not_reqd_reason                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_last_session_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_adjudicated_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_sevis_school_id                   IN     NUMBER    DEFAULT NULL
  );

END igs_pe_nonimg_form_pkg;

 

/