--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI05S.pls 120.0 2005/06/01 13:01:06 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2 DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2   DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_note_message                      IN     VARCHAR2   DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2   DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2 DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount                    IN     NUMBER,
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2   DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_note_message                      IN     VARCHAR2   DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2   DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2   DEFAULT NULL

  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2 DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2   DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_note_message                      IN     VARCHAR2   DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2   DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2   DEFAULT NULL

  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_rfmb_id                           IN     NUMBER,
    x_sys_orig_ssn                      IN     VARCHAR2,
    x_sys_orig_name_cd                  IN     VARCHAR2,
    x_transaction_num                   IN     VARCHAR2,
    x_efc                               IN     NUMBER,
    x_ver_status_code                   IN     VARCHAR2,
    x_secondary_efc                     IN     NUMBER,
    x_secondary_efc_cd                  IN     VARCHAR2,
    x_pell_amount                       IN     NUMBER,
    x_pell_profile                      IN     VARCHAR2 DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2,
    x_enrollment_dt                     IN     DATE,
    x_coa_amount                        IN     NUMBER,
    x_academic_calendar                 IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_total_pymt_prds                   IN     NUMBER,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2,
    x_attending_campus_id               IN     VARCHAR2,
    x_est_disb_dt1                      IN     DATE,
    x_orig_action_code                  IN     VARCHAR2,
    x_orig_status_dt                    IN     DATE,
    x_orig_ed_use_flags                 IN     VARCHAR2,
    x_ft_pell_amount                    IN     NUMBER,
    x_prev_accpt_efc                    IN     NUMBER,
    x_prev_accpt_tran_no                IN     VARCHAR2,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2,
    x_prev_accpt_coa                    IN     NUMBER,
    x_orig_reject_code                  IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_inst_cross_ref_cd                 IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2,
    x_rec_source                        IN     VARCHAR2,
    x_pending_amount                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_birth_dt                          IN     DATE,
    x_last_name                         IN     VARCHAR2,
    x_first_name                        IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_current_ssn                       IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2   DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_note_message                      IN     VARCHAR2   DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2   DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2   DEFAULT NULL

  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_origination_id                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_gr_rfms_batch (
    x_rfmb_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_origination_id                    IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_rfmb_id                           IN     NUMBER      DEFAULT NULL,
    x_sys_orig_ssn                      IN     VARCHAR2    DEFAULT NULL,
    x_sys_orig_name_cd                  IN     VARCHAR2    DEFAULT NULL,
    x_transaction_num                   IN     VARCHAR2    DEFAULT NULL,
    x_efc                               IN     NUMBER      DEFAULT NULL,
    x_ver_status_code                   IN     VARCHAR2    DEFAULT NULL,
    x_secondary_efc                     IN     NUMBER      DEFAULT NULL,
    x_secondary_efc_cd                  IN     VARCHAR2    DEFAULT NULL,
    x_pell_amount                       IN     NUMBER      DEFAULT NULL,
    x_pell_profile                      IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_status                 IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_dt                     IN     DATE        DEFAULT NULL,
    x_coa_amount                        IN     NUMBER      DEFAULT NULL,
    x_academic_calendar                 IN     VARCHAR2    DEFAULT NULL,
    x_payment_method                    IN     VARCHAR2    DEFAULT NULL,
    x_total_pymt_prds                   IN     NUMBER      DEFAULT NULL,
    x_incrcd_fed_pell_rcp_cd            IN     VARCHAR2    DEFAULT NULL,
    x_attending_campus_id               IN     VARCHAR2    DEFAULT NULL,
    x_est_disb_dt1                      IN     DATE        DEFAULT NULL,
    x_orig_action_code                  IN     VARCHAR2    DEFAULT NULL,
    x_orig_status_dt                    IN     DATE        DEFAULT NULL,
    x_orig_ed_use_flags                 IN     VARCHAR2    DEFAULT NULL,
    x_ft_pell_amount                    IN     NUMBER      DEFAULT NULL,
    x_prev_accpt_efc                    IN     NUMBER      DEFAULT NULL,
    x_prev_accpt_tran_no                IN     VARCHAR2    DEFAULT NULL,
    x_prev_accpt_sec_efc_cd             IN     VARCHAR2    DEFAULT NULL,
    x_prev_accpt_coa                    IN     NUMBER      DEFAULT NULL,
    x_orig_reject_code                  IN     VARCHAR2    DEFAULT NULL,
    x_wk_inst_time_calc_pymt            IN     NUMBER      DEFAULT NULL,
    x_wk_int_time_prg_def_yr            IN     NUMBER      DEFAULT NULL,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER      DEFAULT NULL,
    x_cr_clk_hrs_acad_yr                IN     NUMBER      DEFAULT NULL,
    x_inst_cross_ref_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_low_tution_fee                    IN     VARCHAR2    DEFAULT NULL,
    x_rec_source                        IN     VARCHAR2    DEFAULT NULL,
    x_pending_amount                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_last_name                         IN     VARCHAR2    DEFAULT NULL,
    x_first_name                        IN     VARCHAR2    DEFAULT NULL,
    x_middle_name                       IN     VARCHAR2    DEFAULT NULL,
    x_current_ssn                       IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_reporting_pell_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_note_message                      IN     VARCHAR2    DEFAULT NULL,
    x_full_resp_code                    IN     VARCHAR2   DEFAULT NULL,
    x_document_id_txt                   IN     VARCHAR2   DEFAULT NULL

  );

END igf_gr_rfms_pkg;

 

/