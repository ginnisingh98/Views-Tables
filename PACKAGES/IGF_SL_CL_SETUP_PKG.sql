--------------------------------------------------------
--  DDL for Package IGF_SL_CL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI08S.pls 120.0 2005/06/01 14:54:26 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2   DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2   DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2   DEFAULT NULL,
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clset_id                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2   DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2   DEFAULT NULL,
    x_cl_version                        IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clset_id                          IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_sch_non_ed_brc_id                 IN     VARCHAR2   DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2   DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2   DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2   DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_est_orig_fee_perct                IN     NUMBER   DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER   DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_loan_award_method                 IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_media_type                        IN     VARCHAR2,
    x_eft_authorization                 IN     VARCHAR2,
    x_auto_late_disb_ind                IN     VARCHAR2,
    x_cl_version                        IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_est_alt_orig_fee_perct            IN     NUMBER   DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER   DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2     DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clset_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_relationship_cd                   IN     VARCHAR2,
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_sl_cl_recipient (
    x_relationship_cd                 IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clset_id                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_recip_id                     IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_est_orig_fee_perct                IN     NUMBER      DEFAULT NULL,
    x_est_guarnt_fee_perct              IN     NUMBER      DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_loan_award_method                 IN     VARCHAR2    DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_media_type                        IN     VARCHAR2    DEFAULT NULL,
    x_eft_authorization                 IN     VARCHAR2    DEFAULT NULL,
    x_auto_late_disb_ind                IN     VARCHAR2    DEFAULT NULL,
    x_cl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_est_alt_orig_fee_perct            IN     NUMBER      DEFAULT NULL,
    x_est_alt_guarnt_fee_perct          IN     NUMBER      DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_plus_processing_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_method_code           IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_cl_setup_pkg;

 

/
