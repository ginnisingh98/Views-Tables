--------------------------------------------------------
--  DDL for Package Body IGF_SL_LOR_LOC_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_LOR_LOC_HISTORY_PKG" AS
/* $Header: IGFLI36B.pls 120.1 2006/04/19 08:30:23 bvisvana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_lor_loc_history%ROWTYPE;
  new_references igf_sl_lor_loc_history%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_lor_loc_history
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.loan_id                           := x_loan_id;
    new_references.origination_id                    := x_origination_id;
    new_references.loan_number                       := x_loan_number;
    new_references.loan_type                         := x_loan_type;
    new_references.loan_amt_offered                  := x_loan_amt_offered;
    new_references.loan_amt_accepted                 := x_loan_amt_accepted;
    new_references.loan_per_begin_date               := x_loan_per_begin_date;
    new_references.loan_per_end_date                 := x_loan_per_end_date;
    new_references.acad_yr_begin_date                := x_acad_yr_begin_date;
    new_references.acad_yr_end_date                  := x_acad_yr_end_date;
    new_references.loan_status                       := x_loan_status;
    new_references.loan_status_date                  := x_loan_status_date;
    new_references.loan_chg_status                   := x_loan_chg_status;
    new_references.loan_chg_status_date              := x_loan_chg_status_date;
    new_references.req_serial_loan_code              := x_req_serial_loan_code;
    new_references.act_serial_loan_code              := x_act_serial_loan_code;
    new_references.active                            := x_active;
    new_references.active_date                       := x_active_date;
    new_references.sch_cert_date                     := x_sch_cert_date;
    new_references.orig_status_flag                  := x_orig_status_flag;
    new_references.orig_batch_id                     := x_orig_batch_id;
    new_references.orig_batch_date                   := x_orig_batch_date;
    new_references.orig_ack_date                     := x_orig_ack_date;
    new_references.credit_override                   := x_credit_override;
    new_references.credit_decision_date              := x_credit_decision_date;
    new_references.pnote_delivery_code               := x_pnote_delivery_code;
    new_references.pnote_status                      := x_pnote_status;
    new_references.pnote_status_date                 := x_pnote_status_date;
    new_references.pnote_id                          := x_pnote_id;
    new_references.pnote_print_ind                   := x_pnote_print_ind;
    new_references.pnote_accept_amt                  := x_pnote_accept_amt;
    new_references.pnote_accept_date                 := x_pnote_accept_date;
    new_references.p_signature_code                  := x_p_signature_code;
    new_references.p_signature_date                  := x_p_signature_date;
    new_references.s_signature_code                  := x_s_signature_code;
    new_references.unsub_elig_for_heal               := x_unsub_elig_for_heal;
    new_references.disclosure_print_ind              := x_disclosure_print_ind;
    new_references.orig_fee_perct                    := x_orig_fee_perct;
    new_references.borw_confirm_ind                  := x_borw_confirm_ind;
    new_references.borw_interest_ind                 := x_borw_interest_ind;
    new_references.unsub_elig_for_depnt              := x_unsub_elig_for_depnt;
    new_references.guarantee_amt                     := x_guarantee_amt;
    new_references.guarantee_date                    := x_guarantee_date;
    new_references.guarnt_adj_ind                    := x_guarnt_adj_ind;
    new_references.guarnt_amt_redn_code              := x_guarnt_amt_redn_code;
    new_references.guarnt_status_code                := x_guarnt_status_code;
    new_references.guarnt_status_date                := x_guarnt_status_date;
    new_references.lend_apprv_denied_code            := x_lend_apprv_denied_code;
    new_references.lend_apprv_denied_date            := x_lend_apprv_denied_date;
    new_references.lend_status_code                  := x_lend_status_code;
    new_references.lend_status_date                  := x_lend_status_date;
    new_references.grade_level_code                  := x_grade_level_code;
    new_references.enrollment_code                   := x_enrollment_code;
    new_references.anticip_compl_date                := x_anticip_compl_date;
    new_references.borw_lender_id                    := x_borw_lender_id;
    new_references.guarantor_id                      := x_guarantor_id;
    new_references.prc_type_code                     := x_prc_type_code;
    new_references.rec_type_ind                      := x_rec_type_ind;
    new_references.cl_loan_type                      := x_cl_loan_type;
    new_references.cl_seq_number                     := x_cl_seq_number;
    new_references.last_resort_lender                := x_last_resort_lender;
    new_references.lender_id                         := x_lender_id;
    new_references.lend_non_ed_brc_id                := x_lend_non_ed_brc_id;
    new_references.recipient_id                      := x_recipient_id;
    new_references.recipient_type                    := x_recipient_type;
    new_references.recip_non_ed_brc_id               := x_recip_non_ed_brc_id;
    new_references.cl_rec_status                     := x_cl_rec_status;
    new_references.cl_rec_status_last_update         := x_cl_rec_status_last_update;
    new_references.alt_prog_type_code                := x_alt_prog_type_code;
    new_references.alt_appl_ver_code                 := x_alt_appl_ver_code;
    new_references.borw_outstd_loan_code             := x_borw_outstd_loan_code;
    new_references.mpn_confirm_code                  := x_mpn_confirm_code;
    new_references.resp_to_orig_code                 := x_resp_to_orig_code;
    new_references.appl_loan_phase_code              := x_appl_loan_phase_code;
    new_references.appl_loan_phase_code_chg          := x_appl_loan_phase_code_chg;
    new_references.tot_outstd_stafford               := x_tot_outstd_stafford;
    new_references.tot_outstd_plus                   := x_tot_outstd_plus;
    new_references.alt_borw_tot_debt                 := x_alt_borw_tot_debt;
    new_references.act_interest_rate                 := x_act_interest_rate;
    new_references.service_type_code                 := x_service_type_code;
    new_references.rev_notice_of_guarnt              := x_rev_notice_of_guarnt;
    new_references.sch_refund_amt                    := x_sch_refund_amt;
    new_references.sch_refund_date                   := x_sch_refund_date;
    new_references.uniq_layout_vend_code             := x_uniq_layout_vend_code;
    new_references.uniq_layout_ident_code            := x_uniq_layout_ident_code;
    new_references.p_person_id                       := x_p_person_id;
    new_references.p_ssn                             := x_p_ssn;
    new_references.p_last_name                       := x_p_last_name;
    new_references.p_first_name                      := x_p_first_name;
    new_references.p_middle_name                     := x_p_middle_name;
    new_references.p_permt_addr1                     := x_p_permt_addr1;
    new_references.p_permt_addr2                     := x_p_permt_addr2;
    new_references.p_permt_city                      := x_p_permt_city;
    new_references.p_permt_state                     := x_p_permt_state;
    new_references.p_permt_zip                       := x_p_permt_zip;
    new_references.p_permt_addr_chg_date             := x_p_permt_addr_chg_date;
    new_references.p_permt_phone                     := x_p_permt_phone;
    new_references.p_email_addr                      := x_p_email_addr;
    new_references.p_date_of_birth                   := x_p_date_of_birth;
    new_references.p_license_num                     := x_p_license_num;
    new_references.p_license_state                   := x_p_license_state;
    new_references.p_citizenship_status              := x_p_citizenship_status;
    new_references.p_alien_reg_num                   := x_p_alien_reg_num;
    new_references.p_default_status                  := x_p_default_status;
    new_references.p_foreign_postal_code             := x_p_foreign_postal_code;
    new_references.p_state_of_legal_res              := x_p_state_of_legal_res;
    new_references.p_legal_res_date                  := x_p_legal_res_date;
    new_references.s_ssn                             := x_s_ssn;
    new_references.s_last_name                       := x_s_last_name;
    new_references.s_first_name                      := x_s_first_name;
    new_references.s_middle_name                     := x_s_middle_name;
    new_references.s_permt_addr1                     := x_s_permt_addr1;
    new_references.s_permt_addr2                     := x_s_permt_addr2;
    new_references.s_permt_city                      := x_s_permt_city;
    new_references.s_permt_state                     := x_s_permt_state;
    new_references.s_permt_zip                       := x_s_permt_zip;
    new_references.s_permt_addr_chg_date             := x_s_permt_addr_chg_date;
    new_references.s_permt_phone                     := x_s_permt_phone;
    new_references.s_local_addr1                     := x_s_local_addr1;
    new_references.s_local_addr2                     := x_s_local_addr2;
    new_references.s_local_city                      := x_s_local_city;
    new_references.s_local_state                     := x_s_local_state;
    new_references.s_local_zip                       := x_s_local_zip;
    new_references.s_email_addr                      := x_s_email_addr;
    new_references.s_date_of_birth                   := x_s_date_of_birth;
    new_references.s_license_num                     := x_s_license_num;
    new_references.s_license_state                   := x_s_license_state;
    new_references.s_depncy_status                   := x_s_depncy_status;
    new_references.s_default_status                  := x_s_default_status;
    new_references.s_citizenship_status              := x_s_citizenship_status;
    new_references.s_alien_reg_num                   := x_s_alien_reg_num;
    new_references.s_foreign_postal_code             := x_s_foreign_postal_code;
    new_references.pnote_batch_id                    := x_pnote_batch_id;
    new_references.pnote_ack_date                    := x_pnote_ack_date;
    new_references.pnote_mpn_ind                     := x_pnote_mpn_ind;
    new_references.award_id                          := x_award_id;
    new_references.base_id                           := x_base_id;
    new_references.loan_key_num                      := x_loan_key_num;
    new_references.fin_award_year                    := x_fin_award_year;
    new_references.cps_trans_num                     := x_cps_trans_num;
    new_references.pymt_servicer_amt                 := x_pymt_servicer_amt;
    new_references.pymt_servicer_date                := x_pymt_servicer_date;
    new_references.book_loan_amt                     := x_book_loan_amt;
    new_references.book_loan_amt_date                := x_book_loan_amt_date;
    new_references.s_chg_ssn                         := x_s_chg_ssn;
    new_references.s_chg_last_name                   := x_s_chg_last_name;
    new_references.b_chg_ssn                         := x_b_chg_ssn;
    new_references.b_chg_last_name                   := x_b_chg_last_name;
    new_references.note_message                      := x_note_message;
    new_references.full_resp_code                    := x_full_resp_code;
    new_references.s_permt_county                    := x_s_permt_county;
    new_references.b_permt_county                    := x_b_permt_county;
    new_references.s_permt_country                   := x_s_permt_country;
    new_references.b_permt_country                   := x_b_permt_country;
    new_references.crdt_decision_status              := x_crdt_decision_status;
    new_references.b_chg_birth_date                  := x_b_chg_birth_date;
    new_references.s_chg_birth_date                  := x_s_chg_birth_date;
    new_references.external_loan_id_txt              := x_external_loan_id_txt;
    new_references.deferment_request_code            := x_deferment_request_code;
    new_references.eft_authorization_code            := x_eft_authorization_code;
    new_references.requested_loan_amt                := x_requested_loan_amt;
    new_references.actual_record_type_code           := x_actual_record_type_code;
    new_references.reinstatement_amt                 := x_reinstatement_amt;
    new_references.lender_use_txt                    := x_lender_use_txt;
    new_references.guarantor_use_txt                 := x_guarantor_use_txt;
    new_references.fls_approved_amt                  := x_fls_approved_amt;
    new_references.flu_approved_amt                  := x_flu_approved_amt;
    new_references.flp_approved_amt                  := x_flp_approved_amt;
    new_references.alt_approved_amt                  := x_alt_approved_amt;
    new_references.loan_app_form_code                := x_loan_app_form_code;
    new_references.alt_borrower_ind_flag             := x_alt_borrower_ind_flag;
    new_references.school_id_txt                     := x_school_id_txt;
    new_references.cost_of_attendance_amt            := x_cost_of_attendance_amt;
    new_references.EXPECT_FAMILY_CONTRIBUTE_AMT    := x_EXPECT_FAMILY_CONTRIBUTE_AMT;
    new_references.established_fin_aid_amount        := x_established_fin_aid_amount;
    new_references.BOROWER_ELECTRONIC_SIGN_FLAG     := x_BOROWER_ELECTRONIC_SIGN_FLAG;
    new_references.student_electronic_sign_flag      := x_student_electronic_sign_flag;
    new_references.BOROWER_CREDIT_AUTHORIZ_FLAG     := x_BOROWER_CREDIT_AUTHORIZ_FLAG;
    new_references.mpn_type_flag                     := x_mpn_type_flag;
    new_references.school_use_txt                    := x_school_use_txt;
    new_references.document_id_txt                   := x_document_id_txt;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.source_entity_id_txt              := x_source_entity_id_txt;
    new_references.interest_rebate_percent_num       := x_interest_rebate_percent_num;
    new_references.esign_src_typ_cd                  := x_esign_src_typ_cd;
    new_references.loansh_id                         := x_loansh_id;
    new_references.source_txt                        := x_source_txt;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_loan_id,
      x_origination_id,
      x_loan_number,
      x_loan_type,
      x_loan_amt_offered,
      x_loan_amt_accepted,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_acad_yr_begin_date,
      x_acad_yr_end_date,
      x_loan_status,
      x_loan_status_date,
      x_loan_chg_status,
      x_loan_chg_status_date,
      x_req_serial_loan_code,
      x_act_serial_loan_code,
      x_active,
      x_active_date,
      x_sch_cert_date,
      x_orig_status_flag,
      x_orig_batch_id,
      x_orig_batch_date,
      x_orig_ack_date,
      x_credit_override,
      x_credit_decision_date,
      x_pnote_delivery_code,
      x_pnote_status,
      x_pnote_status_date,
      x_pnote_id,
      x_pnote_print_ind,
      x_pnote_accept_amt,
      x_pnote_accept_date,
      x_p_signature_code,
      x_p_signature_date,
      x_s_signature_code,
      x_unsub_elig_for_heal,
      x_disclosure_print_ind,
      x_orig_fee_perct,
      x_borw_confirm_ind,
      x_borw_interest_ind,
      x_unsub_elig_for_depnt,
      x_guarantee_amt,
      x_guarantee_date,
      x_guarnt_adj_ind,
      x_guarnt_amt_redn_code,
      x_guarnt_status_code,
      x_guarnt_status_date,
      x_lend_apprv_denied_code,
      x_lend_apprv_denied_date,
      x_lend_status_code,
      x_lend_status_date,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_borw_lender_id,
      x_guarantor_id,
      x_prc_type_code,
      x_rec_type_ind,
      x_cl_loan_type,
      x_cl_seq_number,
      x_last_resort_lender,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_recipient_id,
      x_recipient_type,
      x_recip_non_ed_brc_id,
      x_cl_rec_status,
      x_cl_rec_status_last_update,
      x_alt_prog_type_code,
      x_alt_appl_ver_code,
      x_borw_outstd_loan_code,
      x_mpn_confirm_code,
      x_resp_to_orig_code,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_tot_outstd_stafford,
      x_tot_outstd_plus,
      x_alt_borw_tot_debt,
      x_act_interest_rate,
      x_service_type_code,
      x_rev_notice_of_guarnt,
      x_sch_refund_amt,
      x_sch_refund_date,
      x_uniq_layout_vend_code,
      x_uniq_layout_ident_code,
      x_p_person_id,
      x_p_ssn,
      x_p_last_name,
      x_p_first_name,
      x_p_middle_name,
      x_p_permt_addr1,
      x_p_permt_addr2,
      x_p_permt_city,
      x_p_permt_state,
      x_p_permt_zip,
      x_p_permt_addr_chg_date,
      x_p_permt_phone,
      x_p_email_addr,
      x_p_date_of_birth,
      x_p_license_num,
      x_p_license_state,
      x_p_citizenship_status,
      x_p_alien_reg_num,
      x_p_default_status,
      x_p_foreign_postal_code,
      x_p_state_of_legal_res,
      x_p_legal_res_date,
      x_s_ssn,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_name,
      x_s_permt_addr1,
      x_s_permt_addr2,
      x_s_permt_city,
      x_s_permt_state,
      x_s_permt_zip,
      x_s_permt_addr_chg_date,
      x_s_permt_phone,
      x_s_local_addr1,
      x_s_local_addr2,
      x_s_local_city,
      x_s_local_state,
      x_s_local_zip,
      x_s_email_addr,
      x_s_date_of_birth,
      x_s_license_num,
      x_s_license_state,
      x_s_depncy_status,
      x_s_default_status,
      x_s_citizenship_status,
      x_s_alien_reg_num,
      x_s_foreign_postal_code,
      x_pnote_batch_id,
      x_pnote_ack_date,
      x_pnote_mpn_ind,
      x_award_id,
      x_base_id,
      x_loan_key_num,
      x_fin_award_year,
      x_cps_trans_num,
      x_pymt_servicer_amt,
      x_pymt_servicer_date,
      x_book_loan_amt,
      x_book_loan_amt_date,
      x_s_chg_ssn,
      x_s_chg_last_name,
      x_b_chg_ssn,
      x_b_chg_last_name,
      x_note_message,
      x_full_resp_code,
      x_s_permt_county,
      x_b_permt_county,
      x_s_permt_country,
      x_b_permt_country,
      x_crdt_decision_status,
      x_b_chg_birth_date,
      x_s_chg_birth_date,
      x_external_loan_id_txt,
      x_deferment_request_code,
      x_eft_authorization_code,
      x_requested_loan_amt,
      x_actual_record_type_code,
      x_reinstatement_amt,
      x_lender_use_txt,
      x_guarantor_use_txt,
      x_fls_approved_amt,
      x_flu_approved_amt,
      x_flp_approved_amt,
      x_alt_approved_amt,
      x_loan_app_form_code,
      x_alt_borrower_ind_flag,
      x_school_id_txt,
      x_cost_of_attendance_amt,
      x_EXPECT_FAMILY_CONTRIBUTE_AMT,
      x_established_fin_aid_amount,
      x_BOROWER_ELECTRONIC_SIGN_FLAG,
      x_student_electronic_sign_flag,
      x_BOROWER_CREDIT_AUTHORIZ_FLAG,
      x_mpn_type_flag,
      x_school_use_txt,
      x_document_id_txt,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_source_entity_id_txt,
      x_interest_rebate_percent_num,
      x_esign_src_typ_cd,
      x_loansh_id,
      x_source_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.loansh_id

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.loansh_id

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

FUNCTION get_pk_for_validation (
    x_loansh_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 21-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_loc_history
      WHERE    loansh_id = x_loansh_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN OUT NOCOPY NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'igf_sl_lor_loc_history_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


    SELECT igf_sl_lor_loc_history_s.NEXTVAL INTO x_loansh_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_loan_id                           => x_loan_id,
      x_origination_id                    => x_origination_id,
      x_loan_number                       => x_loan_number,
      x_loan_type                         => x_loan_type,
      x_loan_amt_offered                  => x_loan_amt_offered,
      x_loan_amt_accepted                 => x_loan_amt_accepted,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_acad_yr_begin_date                => x_acad_yr_begin_date,
      x_acad_yr_end_date                  => x_acad_yr_end_date,
      x_loan_status                       => x_loan_status,
      x_loan_status_date                  => x_loan_status_date,
      x_loan_chg_status                   => x_loan_chg_status,
      x_loan_chg_status_date              => x_loan_chg_status_date,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_active                            => x_active,
      x_active_date                       => x_active_date,
      x_sch_cert_date                     => x_sch_cert_date,
      x_orig_status_flag                  => x_orig_status_flag,
      x_orig_batch_id                     => x_orig_batch_id,
      x_orig_batch_date                   => x_orig_batch_date,
      x_orig_ack_date                     => x_orig_ack_date,
      x_credit_override                   => x_credit_override,
      x_credit_decision_date              => x_credit_decision_date,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_pnote_status                      => x_pnote_status,
      x_pnote_status_date                 => x_pnote_status_date,
      x_pnote_id                          => x_pnote_id,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_accept_amt                  => x_pnote_accept_amt,
      x_pnote_accept_date                 => x_pnote_accept_date,
      x_p_signature_code                  => x_p_signature_code,
      x_p_signature_date                  => x_p_signature_date,
      x_s_signature_code                  => x_s_signature_code,
      x_unsub_elig_for_heal               => x_unsub_elig_for_heal,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_orig_fee_perct                    => x_orig_fee_perct,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_unsub_elig_for_depnt              => x_unsub_elig_for_depnt,
      x_guarantee_amt                     => x_guarantee_amt,
      x_guarantee_date                    => x_guarantee_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_lend_status_code                  => x_lend_status_code,
      x_lend_status_date                  => x_lend_status_date,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_borw_lender_id                    => x_borw_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_prc_type_code                     => x_prc_type_code,
      x_rec_type_ind                      => x_rec_type_ind,
      x_cl_loan_type                      => x_cl_loan_type,
      x_cl_seq_number                     => x_cl_seq_number,
      x_last_resort_lender                => x_last_resort_lender,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_borw_outstd_loan_code             => x_borw_outstd_loan_code,
      x_mpn_confirm_code                  => x_mpn_confirm_code,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_tot_outstd_stafford               => x_tot_outstd_stafford,
      x_tot_outstd_plus                   => x_tot_outstd_plus,
      x_alt_borw_tot_debt                 => x_alt_borw_tot_debt,
      x_act_interest_rate                 => x_act_interest_rate,
      x_service_type_code                 => x_service_type_code,
      x_rev_notice_of_guarnt              => x_rev_notice_of_guarnt,
      x_sch_refund_amt                    => x_sch_refund_amt,
      x_sch_refund_date                   => x_sch_refund_date,
      x_uniq_layout_vend_code             => x_uniq_layout_vend_code,
      x_uniq_layout_ident_code            => x_uniq_layout_ident_code,
      x_p_person_id                       => x_p_person_id,
      x_p_ssn                             => x_p_ssn,
      x_p_last_name                       => x_p_last_name,
      x_p_first_name                      => x_p_first_name,
      x_p_middle_name                     => x_p_middle_name,
      x_p_permt_addr1                     => x_p_permt_addr1,
      x_p_permt_addr2                     => x_p_permt_addr2,
      x_p_permt_city                      => x_p_permt_city,
      x_p_permt_state                     => x_p_permt_state,
      x_p_permt_zip                       => x_p_permt_zip,
      x_p_permt_addr_chg_date             => x_p_permt_addr_chg_date,
      x_p_permt_phone                     => x_p_permt_phone,
      x_p_email_addr                      => x_p_email_addr,
      x_p_date_of_birth                   => x_p_date_of_birth,
      x_p_license_num                     => x_p_license_num,
      x_p_license_state                   => x_p_license_state,
      x_p_citizenship_status              => x_p_citizenship_status,
      x_p_alien_reg_num                   => x_p_alien_reg_num,
      x_p_default_status                  => x_p_default_status,
      x_p_foreign_postal_code             => x_p_foreign_postal_code,
      x_p_state_of_legal_res              => x_p_state_of_legal_res,
      x_p_legal_res_date                  => x_p_legal_res_date,
      x_s_ssn                             => x_s_ssn,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_permt_addr1                     => x_s_permt_addr1,
      x_s_permt_addr2                     => x_s_permt_addr2,
      x_s_permt_city                      => x_s_permt_city,
      x_s_permt_state                     => x_s_permt_state,
      x_s_permt_zip                       => x_s_permt_zip,
      x_s_permt_addr_chg_date             => x_s_permt_addr_chg_date,
      x_s_permt_phone                     => x_s_permt_phone,
      x_s_local_addr1                     => x_s_local_addr1,
      x_s_local_addr2                     => x_s_local_addr2,
      x_s_local_city                      => x_s_local_city,
      x_s_local_state                     => x_s_local_state,
      x_s_local_zip                       => x_s_local_zip,
      x_s_email_addr                      => x_s_email_addr,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_license_num                     => x_s_license_num,
      x_s_license_state                   => x_s_license_state,
      x_s_depncy_status                   => x_s_depncy_status,
      x_s_default_status                  => x_s_default_status,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_alien_reg_num                   => x_s_alien_reg_num,
      x_s_foreign_postal_code             => x_s_foreign_postal_code,
      x_pnote_batch_id                    => x_pnote_batch_id,
      x_pnote_ack_date                    => x_pnote_ack_date,
      x_pnote_mpn_ind                     => x_pnote_mpn_ind,
      x_award_id                          => x_award_id,
      x_base_id                           => x_base_id,
      x_loan_key_num                      => x_loan_key_num,
      x_fin_award_year                    => x_fin_award_year,
      x_cps_trans_num                     => x_cps_trans_num,
      x_pymt_servicer_amt                 => x_pymt_servicer_amt,
      x_pymt_servicer_date                => x_pymt_servicer_date,
      x_book_loan_amt                     => x_book_loan_amt,
      x_book_loan_amt_date                => x_book_loan_amt_date,
      x_s_chg_ssn                         => x_s_chg_ssn,
      x_s_chg_last_name                   => x_s_chg_last_name,
      x_b_chg_ssn                         => x_b_chg_ssn,
      x_b_chg_last_name                   => x_b_chg_last_name,
      x_note_message                      => x_note_message,
      x_full_resp_code                    => x_full_resp_code,
      x_s_permt_county                    => x_s_permt_county,
      x_b_permt_county                    => x_b_permt_county,
      x_s_permt_country                   => x_s_permt_country,
      x_b_permt_country                   => x_b_permt_country,
      x_crdt_decision_status              => x_crdt_decision_status,
      x_b_chg_birth_date                  => x_b_chg_birth_date,
      x_s_chg_birth_date                  => x_s_chg_birth_date,
      x_external_loan_id_txt              => x_external_loan_id_txt,
      x_deferment_request_code            => x_deferment_request_code,
      x_eft_authorization_code            => x_eft_authorization_code,
      x_requested_loan_amt                => x_requested_loan_amt,
      x_actual_record_type_code           => x_actual_record_type_code,
      x_reinstatement_amt                 => x_reinstatement_amt,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_fls_approved_amt                  => x_fls_approved_amt,
      x_flu_approved_amt                  => x_flu_approved_amt,
      x_flp_approved_amt                  => x_flp_approved_amt,
      x_alt_approved_amt                  => x_alt_approved_amt,
      x_loan_app_form_code                => x_loan_app_form_code,
      x_alt_borrower_ind_flag             => x_alt_borrower_ind_flag,
      x_school_id_txt                     => x_school_id_txt,
      x_cost_of_attendance_amt            => x_cost_of_attendance_amt,
      x_EXPECT_FAMILY_CONTRIBUTE_AMT    => x_EXPECT_FAMILY_CONTRIBUTE_AMT,
      x_established_fin_aid_amount        => x_established_fin_aid_amount,
      x_BOROWER_ELECTRONIC_SIGN_FLAG     => x_BOROWER_ELECTRONIC_SIGN_FLAG,
      x_student_electronic_sign_flag      => x_student_electronic_sign_flag,
      x_BOROWER_CREDIT_AUTHORIZ_FLAG     => x_BOROWER_CREDIT_AUTHORIZ_FLAG,
      x_mpn_type_flag                     => x_mpn_type_flag,
      x_school_use_txt                    => x_school_use_txt,
      x_document_id_txt                   => x_document_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_source_entity_id_txt              => x_source_entity_id_txt,
      x_interest_rebate_percent_num       => x_interest_rebate_percent_num,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd,
      x_loansh_id                         => x_loansh_id,
      x_source_txt                        => x_source_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_lor_loc_history (
      loan_id,
      origination_id,
      loan_number,
      loan_type,
      loan_amt_offered,
      loan_amt_accepted,
      loan_per_begin_date,
      loan_per_end_date,
      acad_yr_begin_date,
      acad_yr_end_date,
      loan_status,
      loan_status_date,
      loan_chg_status,
      loan_chg_status_date,
      req_serial_loan_code,
      act_serial_loan_code,
      active,
      active_date,
      sch_cert_date,
      orig_status_flag,
      orig_batch_id,
      orig_batch_date,
      orig_ack_date,
      credit_override,
      credit_decision_date,
      pnote_delivery_code,
      pnote_status,
      pnote_status_date,
      pnote_id,
      pnote_print_ind,
      pnote_accept_amt,
      pnote_accept_date,
      p_signature_code,
      p_signature_date,
      s_signature_code,
      unsub_elig_for_heal,
      disclosure_print_ind,
      orig_fee_perct,
      borw_confirm_ind,
      borw_interest_ind,
      unsub_elig_for_depnt,
      guarantee_amt,
      guarantee_date,
      guarnt_adj_ind,
      guarnt_amt_redn_code,
      guarnt_status_code,
      guarnt_status_date,
      lend_apprv_denied_code,
      lend_apprv_denied_date,
      lend_status_code,
      lend_status_date,
      grade_level_code,
      enrollment_code,
      anticip_compl_date,
      borw_lender_id,
      guarantor_id,
      prc_type_code,
      rec_type_ind,
      cl_loan_type,
      cl_seq_number,
      last_resort_lender,
      lender_id,
      lend_non_ed_brc_id,
      recipient_id,
      recipient_type,
      recip_non_ed_brc_id,
      cl_rec_status,
      cl_rec_status_last_update,
      alt_prog_type_code,
      alt_appl_ver_code,
      borw_outstd_loan_code,
      mpn_confirm_code,
      resp_to_orig_code,
      appl_loan_phase_code,
      appl_loan_phase_code_chg,
      tot_outstd_stafford,
      tot_outstd_plus,
      alt_borw_tot_debt,
      act_interest_rate,
      service_type_code,
      rev_notice_of_guarnt,
      sch_refund_amt,
      sch_refund_date,
      uniq_layout_vend_code,
      uniq_layout_ident_code,
      p_person_id,
      p_ssn,
      p_last_name,
      p_first_name,
      p_middle_name,
      p_permt_addr1,
      p_permt_addr2,
      p_permt_city,
      p_permt_state,
      p_permt_zip,
      p_permt_addr_chg_date,
      p_permt_phone,
      p_email_addr,
      p_date_of_birth,
      p_license_num,
      p_license_state,
      p_citizenship_status,
      p_alien_reg_num,
      p_default_status,
      p_foreign_postal_code,
      p_state_of_legal_res,
      p_legal_res_date,
      s_ssn,
      s_last_name,
      s_first_name,
      s_middle_name,
      s_permt_addr1,
      s_permt_addr2,
      s_permt_city,
      s_permt_state,
      s_permt_zip,
      s_permt_addr_chg_date,
      s_permt_phone,
      s_local_addr1,
      s_local_addr2,
      s_local_city,
      s_local_state,
      s_local_zip,
      s_email_addr,
      s_date_of_birth,
      s_license_num,
      s_license_state,
      s_depncy_status,
      s_default_status,
      s_citizenship_status,
      s_alien_reg_num,
      s_foreign_postal_code,
      pnote_batch_id,
      pnote_ack_date,
      pnote_mpn_ind,
      award_id,
      base_id,
      loan_key_num,
      fin_award_year,
      cps_trans_num,
      pymt_servicer_amt,
      pymt_servicer_date,
      book_loan_amt,
      book_loan_amt_date,
      s_chg_ssn,
      s_chg_last_name,
      b_chg_ssn,
      b_chg_last_name,
      note_message,
      full_resp_code,
      s_permt_county,
      b_permt_county,
      s_permt_country,
      b_permt_country,
      crdt_decision_status,
      b_chg_birth_date,
      s_chg_birth_date,
      external_loan_id_txt,
      deferment_request_code,
      eft_authorization_code,
      requested_loan_amt,
      actual_record_type_code,
      reinstatement_amt,
      lender_use_txt,
      guarantor_use_txt,
      fls_approved_amt,
      flu_approved_amt,
      flp_approved_amt,
      alt_approved_amt,
      loan_app_form_code,
      alt_borrower_ind_flag,
      school_id_txt,
      cost_of_attendance_amt,
      EXPECT_FAMILY_CONTRIBUTE_AMT,
      established_fin_aid_amount,
      BOROWER_ELECTRONIC_SIGN_FLAG,
      student_electronic_sign_flag,
      BOROWER_CREDIT_AUTHORIZ_FLAG,
      mpn_type_flag,
      school_use_txt,
      document_id_txt,
      atd_entity_id_txt,
      rep_entity_id_txt,
      source_entity_id_txt,
      interest_rebate_percent_num,
      esign_src_typ_cd,
      loansh_id,
      source_txt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.loan_id,
      new_references.origination_id,
      new_references.loan_number,
      new_references.loan_type,
      new_references.loan_amt_offered,
      new_references.loan_amt_accepted,
      new_references.loan_per_begin_date,
      new_references.loan_per_end_date,
      new_references.acad_yr_begin_date,
      new_references.acad_yr_end_date,
      new_references.loan_status,
      new_references.loan_status_date,
      new_references.loan_chg_status,
      new_references.loan_chg_status_date,
      new_references.req_serial_loan_code,
      new_references.act_serial_loan_code,
      new_references.active,
      new_references.active_date,
      new_references.sch_cert_date,
      new_references.orig_status_flag,
      new_references.orig_batch_id,
      new_references.orig_batch_date,
      new_references.orig_ack_date,
      new_references.credit_override,
      new_references.credit_decision_date,
      new_references.pnote_delivery_code,
      new_references.pnote_status,
      new_references.pnote_status_date,
      new_references.pnote_id,
      new_references.pnote_print_ind,
      new_references.pnote_accept_amt,
      new_references.pnote_accept_date,
      new_references.p_signature_code,
      new_references.p_signature_date,
      new_references.s_signature_code,
      new_references.unsub_elig_for_heal,
      new_references.disclosure_print_ind,
      new_references.orig_fee_perct,
      new_references.borw_confirm_ind,
      new_references.borw_interest_ind,
      new_references.unsub_elig_for_depnt,
      new_references.guarantee_amt,
      new_references.guarantee_date,
      new_references.guarnt_adj_ind,
      new_references.guarnt_amt_redn_code,
      new_references.guarnt_status_code,
      new_references.guarnt_status_date,
      new_references.lend_apprv_denied_code,
      new_references.lend_apprv_denied_date,
      new_references.lend_status_code,
      new_references.lend_status_date,
      new_references.grade_level_code,
      new_references.enrollment_code,
      new_references.anticip_compl_date,
      new_references.borw_lender_id,
      new_references.guarantor_id,
      new_references.prc_type_code,
      new_references.rec_type_ind,
      new_references.cl_loan_type,
      new_references.cl_seq_number,
      new_references.last_resort_lender,
      new_references.lender_id,
      new_references.lend_non_ed_brc_id,
      new_references.recipient_id,
      new_references.recipient_type,
      new_references.recip_non_ed_brc_id,
      new_references.cl_rec_status,
      new_references.cl_rec_status_last_update,
      new_references.alt_prog_type_code,
      new_references.alt_appl_ver_code,
      new_references.borw_outstd_loan_code,
      new_references.mpn_confirm_code,
      new_references.resp_to_orig_code,
      new_references.appl_loan_phase_code,
      new_references.appl_loan_phase_code_chg,
      new_references.tot_outstd_stafford,
      new_references.tot_outstd_plus,
      new_references.alt_borw_tot_debt,
      new_references.act_interest_rate,
      new_references.service_type_code,
      new_references.rev_notice_of_guarnt,
      new_references.sch_refund_amt,
      new_references.sch_refund_date,
      new_references.uniq_layout_vend_code,
      new_references.uniq_layout_ident_code,
      new_references.p_person_id,
      new_references.p_ssn,
      new_references.p_last_name,
      new_references.p_first_name,
      new_references.p_middle_name,
      new_references.p_permt_addr1,
      new_references.p_permt_addr2,
      new_references.p_permt_city,
      new_references.p_permt_state,
      new_references.p_permt_zip,
      new_references.p_permt_addr_chg_date,
      new_references.p_permt_phone,
      new_references.p_email_addr,
      new_references.p_date_of_birth,
      new_references.p_license_num,
      new_references.p_license_state,
      new_references.p_citizenship_status,
      new_references.p_alien_reg_num,
      new_references.p_default_status,
      new_references.p_foreign_postal_code,
      new_references.p_state_of_legal_res,
      new_references.p_legal_res_date,
      new_references.s_ssn,
      new_references.s_last_name,
      new_references.s_first_name,
      new_references.s_middle_name,
      new_references.s_permt_addr1,
      new_references.s_permt_addr2,
      new_references.s_permt_city,
      new_references.s_permt_state,
      new_references.s_permt_zip,
      new_references.s_permt_addr_chg_date,
      new_references.s_permt_phone,
      new_references.s_local_addr1,
      new_references.s_local_addr2,
      new_references.s_local_city,
      new_references.s_local_state,
      new_references.s_local_zip,
      new_references.s_email_addr,
      new_references.s_date_of_birth,
      new_references.s_license_num,
      new_references.s_license_state,
      new_references.s_depncy_status,
      new_references.s_default_status,
      new_references.s_citizenship_status,
      new_references.s_alien_reg_num,
      new_references.s_foreign_postal_code,
      new_references.pnote_batch_id,
      new_references.pnote_ack_date,
      new_references.pnote_mpn_ind,
      new_references.award_id,
      new_references.base_id,
      new_references.loan_key_num,
      new_references.fin_award_year,
      new_references.cps_trans_num,
      new_references.pymt_servicer_amt,
      new_references.pymt_servicer_date,
      new_references.book_loan_amt,
      new_references.book_loan_amt_date,
      new_references.s_chg_ssn,
      new_references.s_chg_last_name,
      new_references.b_chg_ssn,
      new_references.b_chg_last_name,
      new_references.note_message,
      new_references.full_resp_code,
      new_references.s_permt_county,
      new_references.b_permt_county,
      new_references.s_permt_country,
      new_references.b_permt_country,
      new_references.crdt_decision_status,
      new_references.b_chg_birth_date,
      new_references.s_chg_birth_date,
      new_references.external_loan_id_txt,
      new_references.deferment_request_code,
      new_references.eft_authorization_code,
      new_references.requested_loan_amt,
      new_references.actual_record_type_code,
      new_references.reinstatement_amt,
      new_references.lender_use_txt,
      new_references.guarantor_use_txt,
      new_references.fls_approved_amt,
      new_references.flu_approved_amt,
      new_references.flp_approved_amt,
      new_references.alt_approved_amt,
      new_references.loan_app_form_code,
      new_references.alt_borrower_ind_flag,
      new_references.school_id_txt,
      new_references.cost_of_attendance_amt,
      new_references.EXPECT_FAMILY_CONTRIBUTE_AMT,
      new_references.established_fin_aid_amount,
      new_references.BOROWER_ELECTRONIC_SIGN_FLAG,
      new_references.student_electronic_sign_flag,
      new_references.BOROWER_CREDIT_AUTHORIZ_FLAG,
      new_references.mpn_type_flag,
      new_references.school_use_txt,
      new_references.document_id_txt,
      new_references.atd_entity_id_txt,
      new_references.rep_entity_id_txt,
      new_references.source_entity_id_txt,
      new_references.interest_rebate_percent_num,
      new_references.esign_src_typ_cd,
      igf_sl_lor_loc_history_s.NEXTVAL,
      new_references.source_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, loansh_id INTO x_rowid, x_loansh_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN     NUMBER,
    x_source_txt                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        loan_id,
        origination_id,
        loan_number,
        loan_type,
        loan_amt_offered,
        loan_amt_accepted,
        loan_per_begin_date,
        loan_per_end_date,
        acad_yr_begin_date,
        acad_yr_end_date,
        loan_status,
        loan_status_date,
        loan_chg_status,
        loan_chg_status_date,
        req_serial_loan_code,
        act_serial_loan_code,
        active,
        active_date,
        sch_cert_date,
        orig_status_flag,
        orig_batch_id,
        orig_batch_date,
        orig_ack_date,
        credit_override,
        credit_decision_date,
        pnote_delivery_code,
        pnote_status,
        pnote_status_date,
        pnote_id,
        pnote_print_ind,
        pnote_accept_amt,
        pnote_accept_date,
        p_signature_code,
        p_signature_date,
        s_signature_code,
        unsub_elig_for_heal,
        disclosure_print_ind,
        orig_fee_perct,
        borw_confirm_ind,
        borw_interest_ind,
        unsub_elig_for_depnt,
        guarantee_amt,
        guarantee_date,
        guarnt_adj_ind,
        guarnt_amt_redn_code,
        guarnt_status_code,
        guarnt_status_date,
        lend_apprv_denied_code,
        lend_apprv_denied_date,
        lend_status_code,
        lend_status_date,
        grade_level_code,
        enrollment_code,
        anticip_compl_date,
        borw_lender_id,
        guarantor_id,
        prc_type_code,
        rec_type_ind,
        cl_loan_type,
        cl_seq_number,
        last_resort_lender,
        lender_id,
        lend_non_ed_brc_id,
        recipient_id,
        recipient_type,
        recip_non_ed_brc_id,
        cl_rec_status,
        cl_rec_status_last_update,
        alt_prog_type_code,
        alt_appl_ver_code,
        borw_outstd_loan_code,
        mpn_confirm_code,
        resp_to_orig_code,
        appl_loan_phase_code,
        appl_loan_phase_code_chg,
        tot_outstd_stafford,
        tot_outstd_plus,
        alt_borw_tot_debt,
        act_interest_rate,
        service_type_code,
        rev_notice_of_guarnt,
        sch_refund_amt,
        sch_refund_date,
        uniq_layout_vend_code,
        uniq_layout_ident_code,
        p_person_id,
        p_ssn,
        p_last_name,
        p_first_name,
        p_middle_name,
        p_permt_addr1,
        p_permt_addr2,
        p_permt_city,
        p_permt_state,
        p_permt_zip,
        p_permt_addr_chg_date,
        p_permt_phone,
        p_email_addr,
        p_date_of_birth,
        p_license_num,
        p_license_state,
        p_citizenship_status,
        p_alien_reg_num,
        p_default_status,
        p_foreign_postal_code,
        p_state_of_legal_res,
        p_legal_res_date,
        s_ssn,
        s_last_name,
        s_first_name,
        s_middle_name,
        s_permt_addr1,
        s_permt_addr2,
        s_permt_city,
        s_permt_state,
        s_permt_zip,
        s_permt_addr_chg_date,
        s_permt_phone,
        s_local_addr1,
        s_local_addr2,
        s_local_city,
        s_local_state,
        s_local_zip,
        s_email_addr,
        s_date_of_birth,
        s_license_num,
        s_license_state,
        s_depncy_status,
        s_default_status,
        s_citizenship_status,
        s_alien_reg_num,
        s_foreign_postal_code,
        pnote_batch_id,
        pnote_ack_date,
        pnote_mpn_ind,
        award_id,
        base_id,
        loan_key_num,
        fin_award_year,
        cps_trans_num,
        pymt_servicer_amt,
        pymt_servicer_date,
        book_loan_amt,
        book_loan_amt_date,
        s_chg_ssn,
        s_chg_last_name,
        b_chg_ssn,
        b_chg_last_name,
        note_message,
        full_resp_code,
        s_permt_county,
        b_permt_county,
        s_permt_country,
        b_permt_country,
        crdt_decision_status,
        b_chg_birth_date,
        s_chg_birth_date,
        external_loan_id_txt,
        deferment_request_code,
        eft_authorization_code,
        requested_loan_amt,
        actual_record_type_code,
        reinstatement_amt,
        lender_use_txt,
        guarantor_use_txt,
        fls_approved_amt,
        flu_approved_amt,
        flp_approved_amt,
        alt_approved_amt,
        loan_app_form_code,
        alt_borrower_ind_flag,
        school_id_txt,
        cost_of_attendance_amt,
        EXPECT_FAMILY_CONTRIBUTE_AMT,
        established_fin_aid_amount,
        BOROWER_ELECTRONIC_SIGN_FLAG,
        student_electronic_sign_flag,
        BOROWER_CREDIT_AUTHORIZ_FLAG,
        mpn_type_flag,
        school_use_txt,
        document_id_txt,
        atd_entity_id_txt,
        rep_entity_id_txt,
        source_entity_id_txt,
        interest_rebate_percent_num,
        esign_src_typ_cd,
        loansh_id,
        source_txt
      FROM  igf_sl_lor_loc_history
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.loan_id = x_loan_id)
        AND (tlinfo.origination_id = x_origination_id)
        AND (tlinfo.loan_number = x_loan_number)
        AND (tlinfo.loan_type = x_loan_type)
        AND ((tlinfo.loan_amt_offered = x_loan_amt_offered) OR ((tlinfo.loan_amt_offered IS NULL) AND (X_loan_amt_offered IS NULL)))
        AND ((tlinfo.loan_amt_accepted = x_loan_amt_accepted) OR ((tlinfo.loan_amt_accepted IS NULL) AND (X_loan_amt_accepted IS NULL)))
        AND ((tlinfo.loan_per_begin_date = x_loan_per_begin_date) OR ((tlinfo.loan_per_begin_date IS NULL) AND (X_loan_per_begin_date IS NULL)))
        AND ((tlinfo.loan_per_end_date = x_loan_per_end_date) OR ((tlinfo.loan_per_end_date IS NULL) AND (X_loan_per_end_date IS NULL)))
        AND ((tlinfo.acad_yr_begin_date = x_acad_yr_begin_date) OR ((tlinfo.acad_yr_begin_date IS NULL) AND (X_acad_yr_begin_date IS NULL)))
        AND ((tlinfo.acad_yr_end_date = x_acad_yr_end_date) OR ((tlinfo.acad_yr_end_date IS NULL) AND (X_acad_yr_end_date IS NULL)))
        AND ((tlinfo.loan_status = x_loan_status) OR ((tlinfo.loan_status IS NULL) AND (X_loan_status IS NULL)))
        AND ((tlinfo.loan_status_date = x_loan_status_date) OR ((tlinfo.loan_status_date IS NULL) AND (X_loan_status_date IS NULL)))
        AND ((tlinfo.loan_chg_status = x_loan_chg_status) OR ((tlinfo.loan_chg_status IS NULL) AND (X_loan_chg_status IS NULL)))
        AND ((tlinfo.loan_chg_status_date = x_loan_chg_status_date) OR ((tlinfo.loan_chg_status_date IS NULL) AND (X_loan_chg_status_date IS NULL)))
        AND ((tlinfo.req_serial_loan_code = x_req_serial_loan_code) OR ((tlinfo.req_serial_loan_code IS NULL) AND (X_req_serial_loan_code IS NULL)))
        AND ((tlinfo.act_serial_loan_code = x_act_serial_loan_code) OR ((tlinfo.act_serial_loan_code IS NULL) AND (X_act_serial_loan_code IS NULL)))
        AND ((tlinfo.active = x_active) OR ((tlinfo.active IS NULL) AND (X_active IS NULL)))
        AND ((tlinfo.active_date = x_active_date) OR ((tlinfo.active_date IS NULL) AND (X_active_date IS NULL)))
        AND ((tlinfo.sch_cert_date = x_sch_cert_date) OR ((tlinfo.sch_cert_date IS NULL) AND (X_sch_cert_date IS NULL)))
        AND ((tlinfo.orig_status_flag = x_orig_status_flag) OR ((tlinfo.orig_status_flag IS NULL) AND (X_orig_status_flag IS NULL)))
        AND ((tlinfo.orig_batch_id = x_orig_batch_id) OR ((tlinfo.orig_batch_id IS NULL) AND (X_orig_batch_id IS NULL)))
        AND ((tlinfo.orig_batch_date = x_orig_batch_date) OR ((tlinfo.orig_batch_date IS NULL) AND (X_orig_batch_date IS NULL)))
        AND ((tlinfo.orig_ack_date = x_orig_ack_date) OR ((tlinfo.orig_ack_date IS NULL) AND (X_orig_ack_date IS NULL)))
        AND ((tlinfo.credit_override = x_credit_override) OR ((tlinfo.credit_override IS NULL) AND (X_credit_override IS NULL)))
        AND ((tlinfo.credit_decision_date = x_credit_decision_date) OR ((tlinfo.credit_decision_date IS NULL) AND (X_credit_decision_date IS NULL)))
        AND ((tlinfo.pnote_delivery_code = x_pnote_delivery_code) OR ((tlinfo.pnote_delivery_code IS NULL) AND (X_pnote_delivery_code IS NULL)))
        AND ((tlinfo.pnote_status = x_pnote_status) OR ((tlinfo.pnote_status IS NULL) AND (X_pnote_status IS NULL)))
        AND ((tlinfo.pnote_status_date = x_pnote_status_date) OR ((tlinfo.pnote_status_date IS NULL) AND (X_pnote_status_date IS NULL)))
        AND ((tlinfo.pnote_id = x_pnote_id) OR ((tlinfo.pnote_id IS NULL) AND (X_pnote_id IS NULL)))
        AND ((tlinfo.pnote_print_ind = x_pnote_print_ind) OR ((tlinfo.pnote_print_ind IS NULL) AND (X_pnote_print_ind IS NULL)))
        AND ((tlinfo.pnote_accept_amt = x_pnote_accept_amt) OR ((tlinfo.pnote_accept_amt IS NULL) AND (X_pnote_accept_amt IS NULL)))
        AND ((tlinfo.pnote_accept_date = x_pnote_accept_date) OR ((tlinfo.pnote_accept_date IS NULL) AND (X_pnote_accept_date IS NULL)))
        AND ((tlinfo.p_signature_code = x_p_signature_code) OR ((tlinfo.p_signature_code IS NULL) AND (X_p_signature_code IS NULL)))
        AND ((tlinfo.p_signature_date = x_p_signature_date) OR ((tlinfo.p_signature_date IS NULL) AND (X_p_signature_date IS NULL)))
        AND ((tlinfo.s_signature_code = x_s_signature_code) OR ((tlinfo.s_signature_code IS NULL) AND (X_s_signature_code IS NULL)))
        AND ((tlinfo.unsub_elig_for_heal = x_unsub_elig_for_heal) OR ((tlinfo.unsub_elig_for_heal IS NULL) AND (X_unsub_elig_for_heal IS NULL)))
        AND ((tlinfo.disclosure_print_ind = x_disclosure_print_ind) OR ((tlinfo.disclosure_print_ind IS NULL) AND (X_disclosure_print_ind IS NULL)))
        AND ((tlinfo.orig_fee_perct = x_orig_fee_perct) OR ((tlinfo.orig_fee_perct IS NULL) AND (X_orig_fee_perct IS NULL)))
        AND ((tlinfo.borw_confirm_ind = x_borw_confirm_ind) OR ((tlinfo.borw_confirm_ind IS NULL) AND (X_borw_confirm_ind IS NULL)))
        AND ((tlinfo.borw_interest_ind = x_borw_interest_ind) OR ((tlinfo.borw_interest_ind IS NULL) AND (X_borw_interest_ind IS NULL)))
        AND ((tlinfo.unsub_elig_for_depnt = x_unsub_elig_for_depnt) OR ((tlinfo.unsub_elig_for_depnt IS NULL) AND (X_unsub_elig_for_depnt IS NULL)))
        AND ((tlinfo.guarantee_amt = x_guarantee_amt) OR ((tlinfo.guarantee_amt IS NULL) AND (X_guarantee_amt IS NULL)))
        AND ((tlinfo.guarantee_date = x_guarantee_date) OR ((tlinfo.guarantee_date IS NULL) AND (X_guarantee_date IS NULL)))
        AND ((tlinfo.guarnt_adj_ind = x_guarnt_adj_ind) OR ((tlinfo.guarnt_adj_ind IS NULL) AND (X_guarnt_adj_ind IS NULL)))
        AND ((tlinfo.guarnt_amt_redn_code = x_guarnt_amt_redn_code) OR ((tlinfo.guarnt_amt_redn_code IS NULL) AND (X_guarnt_amt_redn_code IS NULL)))
        AND ((tlinfo.guarnt_status_code = x_guarnt_status_code) OR ((tlinfo.guarnt_status_code IS NULL) AND (X_guarnt_status_code IS NULL)))
        AND ((tlinfo.guarnt_status_date = x_guarnt_status_date) OR ((tlinfo.guarnt_status_date IS NULL) AND (X_guarnt_status_date IS NULL)))
        AND ((tlinfo.lend_apprv_denied_code = x_lend_apprv_denied_code) OR ((tlinfo.lend_apprv_denied_code IS NULL) AND (X_lend_apprv_denied_code IS NULL)))
        AND ((tlinfo.lend_apprv_denied_date = x_lend_apprv_denied_date) OR ((tlinfo.lend_apprv_denied_date IS NULL) AND (X_lend_apprv_denied_date IS NULL)))
        AND ((tlinfo.lend_status_code = x_lend_status_code) OR ((tlinfo.lend_status_code IS NULL) AND (X_lend_status_code IS NULL)))
        AND ((tlinfo.lend_status_date = x_lend_status_date) OR ((tlinfo.lend_status_date IS NULL) AND (X_lend_status_date IS NULL)))
        AND ((tlinfo.grade_level_code = x_grade_level_code) OR ((tlinfo.grade_level_code IS NULL) AND (X_grade_level_code IS NULL)))
        AND ((tlinfo.enrollment_code = x_enrollment_code) OR ((tlinfo.enrollment_code IS NULL) AND (X_enrollment_code IS NULL)))
        AND ((tlinfo.anticip_compl_date = x_anticip_compl_date) OR ((tlinfo.anticip_compl_date IS NULL) AND (X_anticip_compl_date IS NULL)))
        AND ((tlinfo.borw_lender_id = x_borw_lender_id) OR ((tlinfo.borw_lender_id IS NULL) AND (X_borw_lender_id IS NULL)))
        AND ((tlinfo.guarantor_id = x_guarantor_id) OR ((tlinfo.guarantor_id IS NULL) AND (X_guarantor_id IS NULL)))
        AND ((tlinfo.prc_type_code = x_prc_type_code) OR ((tlinfo.prc_type_code IS NULL) AND (X_prc_type_code IS NULL)))
        AND ((tlinfo.rec_type_ind = x_rec_type_ind) OR ((tlinfo.rec_type_ind IS NULL) AND (X_rec_type_ind IS NULL)))
        AND ((tlinfo.cl_loan_type = x_cl_loan_type) OR ((tlinfo.cl_loan_type IS NULL) AND (X_cl_loan_type IS NULL)))
        AND ((tlinfo.cl_seq_number = x_cl_seq_number) OR ((tlinfo.cl_seq_number IS NULL) AND (X_cl_seq_number IS NULL)))
        AND ((tlinfo.last_resort_lender = x_last_resort_lender) OR ((tlinfo.last_resort_lender IS NULL) AND (X_last_resort_lender IS NULL)))
        AND ((tlinfo.lender_id = x_lender_id) OR ((tlinfo.lender_id IS NULL) AND (X_lender_id IS NULL)))
        AND ((tlinfo.lend_non_ed_brc_id = x_lend_non_ed_brc_id) OR ((tlinfo.lend_non_ed_brc_id IS NULL) AND (X_lend_non_ed_brc_id IS NULL)))
        AND ((tlinfo.recipient_id = x_recipient_id) OR ((tlinfo.recipient_id IS NULL) AND (X_recipient_id IS NULL)))
        AND ((tlinfo.recipient_type = x_recipient_type) OR ((tlinfo.recipient_type IS NULL) AND (X_recipient_type IS NULL)))
        AND ((tlinfo.recip_non_ed_brc_id = x_recip_non_ed_brc_id) OR ((tlinfo.recip_non_ed_brc_id IS NULL) AND (X_recip_non_ed_brc_id IS NULL)))
        AND ((tlinfo.cl_rec_status = x_cl_rec_status) OR ((tlinfo.cl_rec_status IS NULL) AND (X_cl_rec_status IS NULL)))
        AND ((tlinfo.cl_rec_status_last_update = x_cl_rec_status_last_update) OR ((tlinfo.cl_rec_status_last_update IS NULL) AND (X_cl_rec_status_last_update IS NULL)))
        AND ((tlinfo.alt_prog_type_code = x_alt_prog_type_code) OR ((tlinfo.alt_prog_type_code IS NULL) AND (X_alt_prog_type_code IS NULL)))
        AND ((tlinfo.alt_appl_ver_code = x_alt_appl_ver_code) OR ((tlinfo.alt_appl_ver_code IS NULL) AND (X_alt_appl_ver_code IS NULL)))
        AND ((tlinfo.borw_outstd_loan_code = x_borw_outstd_loan_code) OR ((tlinfo.borw_outstd_loan_code IS NULL) AND (X_borw_outstd_loan_code IS NULL)))
        AND ((tlinfo.mpn_confirm_code = x_mpn_confirm_code) OR ((tlinfo.mpn_confirm_code IS NULL) AND (X_mpn_confirm_code IS NULL)))
        AND ((tlinfo.resp_to_orig_code = x_resp_to_orig_code) OR ((tlinfo.resp_to_orig_code IS NULL) AND (X_resp_to_orig_code IS NULL)))
        AND ((tlinfo.appl_loan_phase_code = x_appl_loan_phase_code) OR ((tlinfo.appl_loan_phase_code IS NULL) AND (X_appl_loan_phase_code IS NULL)))
        AND ((tlinfo.appl_loan_phase_code_chg = x_appl_loan_phase_code_chg) OR ((tlinfo.appl_loan_phase_code_chg IS NULL) AND (X_appl_loan_phase_code_chg IS NULL)))
        AND ((tlinfo.tot_outstd_stafford = x_tot_outstd_stafford) OR ((tlinfo.tot_outstd_stafford IS NULL) AND (X_tot_outstd_stafford IS NULL)))
        AND ((tlinfo.tot_outstd_plus = x_tot_outstd_plus) OR ((tlinfo.tot_outstd_plus IS NULL) AND (X_tot_outstd_plus IS NULL)))
        AND ((tlinfo.alt_borw_tot_debt = x_alt_borw_tot_debt) OR ((tlinfo.alt_borw_tot_debt IS NULL) AND (X_alt_borw_tot_debt IS NULL)))
        AND ((tlinfo.act_interest_rate = x_act_interest_rate) OR ((tlinfo.act_interest_rate IS NULL) AND (X_act_interest_rate IS NULL)))
        AND ((tlinfo.service_type_code = x_service_type_code) OR ((tlinfo.service_type_code IS NULL) AND (X_service_type_code IS NULL)))
        AND ((tlinfo.rev_notice_of_guarnt = x_rev_notice_of_guarnt) OR ((tlinfo.rev_notice_of_guarnt IS NULL) AND (X_rev_notice_of_guarnt IS NULL)))
        AND ((tlinfo.sch_refund_amt = x_sch_refund_amt) OR ((tlinfo.sch_refund_amt IS NULL) AND (X_sch_refund_amt IS NULL)))
        AND ((tlinfo.sch_refund_date = x_sch_refund_date) OR ((tlinfo.sch_refund_date IS NULL) AND (X_sch_refund_date IS NULL)))
        AND ((tlinfo.uniq_layout_vend_code = x_uniq_layout_vend_code) OR ((tlinfo.uniq_layout_vend_code IS NULL) AND (X_uniq_layout_vend_code IS NULL)))
        AND ((tlinfo.uniq_layout_ident_code = x_uniq_layout_ident_code) OR ((tlinfo.uniq_layout_ident_code IS NULL) AND (X_uniq_layout_ident_code IS NULL)))
        AND ((tlinfo.p_person_id = x_p_person_id) OR ((tlinfo.p_person_id IS NULL) AND (X_p_person_id IS NULL)))
        AND ((tlinfo.p_ssn = x_p_ssn) OR ((tlinfo.p_ssn IS NULL) AND (X_p_ssn IS NULL)))
        AND ((tlinfo.p_last_name = x_p_last_name) OR ((tlinfo.p_last_name IS NULL) AND (X_p_last_name IS NULL)))
        AND ((tlinfo.p_first_name = x_p_first_name) OR ((tlinfo.p_first_name IS NULL) AND (X_p_first_name IS NULL)))
        AND ((tlinfo.p_middle_name = x_p_middle_name) OR ((tlinfo.p_middle_name IS NULL) AND (X_p_middle_name IS NULL)))
        AND ((tlinfo.p_permt_addr1 = x_p_permt_addr1) OR ((tlinfo.p_permt_addr1 IS NULL) AND (X_p_permt_addr1 IS NULL)))
        AND ((tlinfo.p_permt_addr2 = x_p_permt_addr2) OR ((tlinfo.p_permt_addr2 IS NULL) AND (X_p_permt_addr2 IS NULL)))
        AND ((tlinfo.p_permt_city = x_p_permt_city) OR ((tlinfo.p_permt_city IS NULL) AND (X_p_permt_city IS NULL)))
        AND ((tlinfo.p_permt_state = x_p_permt_state) OR ((tlinfo.p_permt_state IS NULL) AND (X_p_permt_state IS NULL)))
        AND ((tlinfo.p_permt_zip = x_p_permt_zip) OR ((tlinfo.p_permt_zip IS NULL) AND (X_p_permt_zip IS NULL)))
        AND ((tlinfo.p_permt_addr_chg_date = x_p_permt_addr_chg_date) OR ((tlinfo.p_permt_addr_chg_date IS NULL) AND (X_p_permt_addr_chg_date IS NULL)))
        AND ((tlinfo.p_permt_phone = x_p_permt_phone) OR ((tlinfo.p_permt_phone IS NULL) AND (X_p_permt_phone IS NULL)))
        AND ((tlinfo.p_email_addr = x_p_email_addr) OR ((tlinfo.p_email_addr IS NULL) AND (X_p_email_addr IS NULL)))
        AND ((tlinfo.p_date_of_birth = x_p_date_of_birth) OR ((tlinfo.p_date_of_birth IS NULL) AND (X_p_date_of_birth IS NULL)))
        AND ((tlinfo.p_license_num = x_p_license_num) OR ((tlinfo.p_license_num IS NULL) AND (X_p_license_num IS NULL)))
        AND ((tlinfo.p_license_state = x_p_license_state) OR ((tlinfo.p_license_state IS NULL) AND (X_p_license_state IS NULL)))
        AND ((tlinfo.p_citizenship_status = x_p_citizenship_status) OR ((tlinfo.p_citizenship_status IS NULL) AND (X_p_citizenship_status IS NULL)))
        AND ((tlinfo.p_alien_reg_num = x_p_alien_reg_num) OR ((tlinfo.p_alien_reg_num IS NULL) AND (X_p_alien_reg_num IS NULL)))
        AND ((tlinfo.p_default_status = x_p_default_status) OR ((tlinfo.p_default_status IS NULL) AND (X_p_default_status IS NULL)))
        AND ((tlinfo.p_foreign_postal_code = x_p_foreign_postal_code) OR ((tlinfo.p_foreign_postal_code IS NULL) AND (X_p_foreign_postal_code IS NULL)))
        AND ((tlinfo.p_state_of_legal_res = x_p_state_of_legal_res) OR ((tlinfo.p_state_of_legal_res IS NULL) AND (X_p_state_of_legal_res IS NULL)))
        AND ((tlinfo.p_legal_res_date = x_p_legal_res_date) OR ((tlinfo.p_legal_res_date IS NULL) AND (X_p_legal_res_date IS NULL)))
        AND ((tlinfo.s_ssn = x_s_ssn) OR ((tlinfo.s_ssn IS NULL) AND (X_s_ssn IS NULL)))
        AND ((tlinfo.s_last_name = x_s_last_name) OR ((tlinfo.s_last_name IS NULL) AND (X_s_last_name IS NULL)))
        AND ((tlinfo.s_first_name = x_s_first_name) OR ((tlinfo.s_first_name IS NULL) AND (X_s_first_name IS NULL)))
        AND ((tlinfo.s_middle_name = x_s_middle_name) OR ((tlinfo.s_middle_name IS NULL) AND (X_s_middle_name IS NULL)))
        AND ((tlinfo.s_permt_addr1 = x_s_permt_addr1) OR ((tlinfo.s_permt_addr1 IS NULL) AND (X_s_permt_addr1 IS NULL)))
        AND ((tlinfo.s_permt_addr2 = x_s_permt_addr2) OR ((tlinfo.s_permt_addr2 IS NULL) AND (X_s_permt_addr2 IS NULL)))
        AND ((tlinfo.s_permt_city = x_s_permt_city) OR ((tlinfo.s_permt_city IS NULL) AND (X_s_permt_city IS NULL)))
        AND ((tlinfo.s_permt_state = x_s_permt_state) OR ((tlinfo.s_permt_state IS NULL) AND (X_s_permt_state IS NULL)))
        AND ((tlinfo.s_permt_zip = x_s_permt_zip) OR ((tlinfo.s_permt_zip IS NULL) AND (X_s_permt_zip IS NULL)))
        AND ((tlinfo.s_permt_addr_chg_date = x_s_permt_addr_chg_date) OR ((tlinfo.s_permt_addr_chg_date IS NULL) AND (X_s_permt_addr_chg_date IS NULL)))
        AND ((tlinfo.s_permt_phone = x_s_permt_phone) OR ((tlinfo.s_permt_phone IS NULL) AND (X_s_permt_phone IS NULL)))
        AND ((tlinfo.s_local_addr1 = x_s_local_addr1) OR ((tlinfo.s_local_addr1 IS NULL) AND (X_s_local_addr1 IS NULL)))
        AND ((tlinfo.s_local_addr2 = x_s_local_addr2) OR ((tlinfo.s_local_addr2 IS NULL) AND (X_s_local_addr2 IS NULL)))
        AND ((tlinfo.s_local_city = x_s_local_city) OR ((tlinfo.s_local_city IS NULL) AND (X_s_local_city IS NULL)))
        AND ((tlinfo.s_local_state = x_s_local_state) OR ((tlinfo.s_local_state IS NULL) AND (X_s_local_state IS NULL)))
        AND ((tlinfo.s_local_zip = x_s_local_zip) OR ((tlinfo.s_local_zip IS NULL) AND (X_s_local_zip IS NULL)))
        AND ((tlinfo.s_email_addr = x_s_email_addr) OR ((tlinfo.s_email_addr IS NULL) AND (X_s_email_addr IS NULL)))
        AND ((tlinfo.s_date_of_birth = x_s_date_of_birth) OR ((tlinfo.s_date_of_birth IS NULL) AND (X_s_date_of_birth IS NULL)))
        AND ((tlinfo.s_license_num = x_s_license_num) OR ((tlinfo.s_license_num IS NULL) AND (X_s_license_num IS NULL)))
        AND ((tlinfo.s_license_state = x_s_license_state) OR ((tlinfo.s_license_state IS NULL) AND (X_s_license_state IS NULL)))
        AND ((tlinfo.s_depncy_status = x_s_depncy_status) OR ((tlinfo.s_depncy_status IS NULL) AND (X_s_depncy_status IS NULL)))
        AND ((tlinfo.s_default_status = x_s_default_status) OR ((tlinfo.s_default_status IS NULL) AND (X_s_default_status IS NULL)))
        AND ((tlinfo.s_citizenship_status = x_s_citizenship_status) OR ((tlinfo.s_citizenship_status IS NULL) AND (X_s_citizenship_status IS NULL)))
        AND ((tlinfo.s_alien_reg_num = x_s_alien_reg_num) OR ((tlinfo.s_alien_reg_num IS NULL) AND (X_s_alien_reg_num IS NULL)))
        AND ((tlinfo.s_foreign_postal_code = x_s_foreign_postal_code) OR ((tlinfo.s_foreign_postal_code IS NULL) AND (X_s_foreign_postal_code IS NULL)))
        AND ((tlinfo.pnote_batch_id = x_pnote_batch_id) OR ((tlinfo.pnote_batch_id IS NULL) AND (X_pnote_batch_id IS NULL)))
        AND ((tlinfo.pnote_ack_date = x_pnote_ack_date) OR ((tlinfo.pnote_ack_date IS NULL) AND (X_pnote_ack_date IS NULL)))
        AND ((tlinfo.pnote_mpn_ind = x_pnote_mpn_ind) OR ((tlinfo.pnote_mpn_ind IS NULL) AND (X_pnote_mpn_ind IS NULL)))
        AND ((tlinfo.award_id = x_award_id) OR ((tlinfo.award_id IS NULL) AND (X_award_id IS NULL)))
        AND ((tlinfo.base_id = x_base_id) OR ((tlinfo.base_id IS NULL) AND (X_base_id IS NULL)))
        AND ((tlinfo.loan_key_num = x_loan_key_num) OR ((tlinfo.loan_key_num IS NULL) AND (X_loan_key_num IS NULL)))
        AND ((tlinfo.fin_award_year = x_fin_award_year) OR ((tlinfo.fin_award_year IS NULL) AND (X_fin_award_year IS NULL)))
        AND ((tlinfo.cps_trans_num = x_cps_trans_num) OR ((tlinfo.cps_trans_num IS NULL) AND (X_cps_trans_num IS NULL)))
        AND ((tlinfo.pymt_servicer_amt = x_pymt_servicer_amt) OR ((tlinfo.pymt_servicer_amt IS NULL) AND (X_pymt_servicer_amt IS NULL)))
        AND ((tlinfo.pymt_servicer_date = x_pymt_servicer_date) OR ((tlinfo.pymt_servicer_date IS NULL) AND (X_pymt_servicer_date IS NULL)))
        AND ((tlinfo.book_loan_amt = x_book_loan_amt) OR ((tlinfo.book_loan_amt IS NULL) AND (X_book_loan_amt IS NULL)))
        AND ((tlinfo.book_loan_amt_date = x_book_loan_amt_date) OR ((tlinfo.book_loan_amt_date IS NULL) AND (X_book_loan_amt_date IS NULL)))
        AND ((tlinfo.s_chg_ssn = x_s_chg_ssn) OR ((tlinfo.s_chg_ssn IS NULL) AND (X_s_chg_ssn IS NULL)))
        AND ((tlinfo.s_chg_last_name = x_s_chg_last_name) OR ((tlinfo.s_chg_last_name IS NULL) AND (X_s_chg_last_name IS NULL)))
        AND ((tlinfo.b_chg_ssn = x_b_chg_ssn) OR ((tlinfo.b_chg_ssn IS NULL) AND (X_b_chg_ssn IS NULL)))
        AND ((tlinfo.b_chg_last_name = x_b_chg_last_name) OR ((tlinfo.b_chg_last_name IS NULL) AND (X_b_chg_last_name IS NULL)))
        AND ((tlinfo.note_message = x_note_message) OR ((tlinfo.note_message IS NULL) AND (X_note_message IS NULL)))
        AND ((tlinfo.full_resp_code = x_full_resp_code) OR ((tlinfo.full_resp_code IS NULL) AND (X_full_resp_code IS NULL)))
        AND ((tlinfo.s_permt_county = x_s_permt_county) OR ((tlinfo.s_permt_county IS NULL) AND (X_s_permt_county IS NULL)))
        AND ((tlinfo.b_permt_county = x_b_permt_county) OR ((tlinfo.b_permt_county IS NULL) AND (X_b_permt_county IS NULL)))
        AND ((tlinfo.s_permt_country = x_s_permt_country) OR ((tlinfo.s_permt_country IS NULL) AND (X_s_permt_country IS NULL)))
        AND ((tlinfo.b_permt_country = x_b_permt_country) OR ((tlinfo.b_permt_country IS NULL) AND (X_b_permt_country IS NULL)))
        AND ((tlinfo.crdt_decision_status = x_crdt_decision_status) OR ((tlinfo.crdt_decision_status IS NULL) AND (X_crdt_decision_status IS NULL)))
        AND ((tlinfo.b_chg_birth_date = x_b_chg_birth_date) OR ((tlinfo.b_chg_birth_date IS NULL) AND (X_b_chg_birth_date IS NULL)))
        AND ((tlinfo.s_chg_birth_date = x_s_chg_birth_date) OR ((tlinfo.s_chg_birth_date IS NULL) AND (X_s_chg_birth_date IS NULL)))
        AND ((tlinfo.external_loan_id_txt = x_external_loan_id_txt) OR ((tlinfo.external_loan_id_txt IS NULL) AND (X_external_loan_id_txt IS NULL)))
        AND ((tlinfo.deferment_request_code = x_deferment_request_code) OR ((tlinfo.deferment_request_code IS NULL) AND (X_deferment_request_code IS NULL)))
        AND ((tlinfo.eft_authorization_code = x_eft_authorization_code) OR ((tlinfo.eft_authorization_code IS NULL) AND (X_eft_authorization_code IS NULL)))
        AND ((tlinfo.requested_loan_amt = x_requested_loan_amt) OR ((tlinfo.requested_loan_amt IS NULL) AND (X_requested_loan_amt IS NULL)))
        AND ((tlinfo.actual_record_type_code = x_actual_record_type_code) OR ((tlinfo.actual_record_type_code IS NULL) AND (X_actual_record_type_code IS NULL)))
        AND ((tlinfo.reinstatement_amt = x_reinstatement_amt) OR ((tlinfo.reinstatement_amt IS NULL) AND (X_reinstatement_amt IS NULL)))
        AND ((tlinfo.lender_use_txt = x_lender_use_txt) OR ((tlinfo.lender_use_txt IS NULL) AND (X_lender_use_txt IS NULL)))
        AND ((tlinfo.guarantor_use_txt = x_guarantor_use_txt) OR ((tlinfo.guarantor_use_txt IS NULL) AND (X_guarantor_use_txt IS NULL)))
        AND ((tlinfo.fls_approved_amt = x_fls_approved_amt) OR ((tlinfo.fls_approved_amt IS NULL) AND (X_fls_approved_amt IS NULL)))
        AND ((tlinfo.flu_approved_amt = x_flu_approved_amt) OR ((tlinfo.flu_approved_amt IS NULL) AND (X_flu_approved_amt IS NULL)))
        AND ((tlinfo.flp_approved_amt = x_flp_approved_amt) OR ((tlinfo.flp_approved_amt IS NULL) AND (X_flp_approved_amt IS NULL)))
        AND ((tlinfo.alt_approved_amt = x_alt_approved_amt) OR ((tlinfo.alt_approved_amt IS NULL) AND (X_alt_approved_amt IS NULL)))
        AND ((tlinfo.loan_app_form_code = x_loan_app_form_code) OR ((tlinfo.loan_app_form_code IS NULL) AND (X_loan_app_form_code IS NULL)))
        AND ((tlinfo.alt_borrower_ind_flag = x_alt_borrower_ind_flag) OR ((tlinfo.alt_borrower_ind_flag IS NULL) AND (X_alt_borrower_ind_flag IS NULL)))
        AND ((tlinfo.school_id_txt = x_school_id_txt) OR ((tlinfo.school_id_txt IS NULL) AND (X_school_id_txt IS NULL)))
        AND ((tlinfo.cost_of_attendance_amt = x_cost_of_attendance_amt) OR ((tlinfo.cost_of_attendance_amt IS NULL) AND (X_cost_of_attendance_amt IS NULL)))
        AND ((tlinfo.EXPECT_FAMILY_CONTRIBUTE_AMT = x_EXPECT_FAMILY_CONTRIBUTE_AMT) OR ((tlinfo.EXPECT_FAMILY_CONTRIBUTE_AMT IS NULL) AND (X_EXPECT_FAMILY_CONTRIBUTE_AMT IS NULL)))
        AND ((tlinfo.established_fin_aid_amount = x_established_fin_aid_amount) OR ((tlinfo.established_fin_aid_amount IS NULL) AND (X_established_fin_aid_amount IS NULL)))
        AND ((tlinfo.BOROWER_ELECTRONIC_SIGN_FLAG = x_BOROWER_ELECTRONIC_SIGN_FLAG) OR ((tlinfo.BOROWER_ELECTRONIC_SIGN_FLAG IS NULL) AND (X_BOROWER_ELECTRONIC_SIGN_FLAG IS NULL)))
        AND ((tlinfo.student_electronic_sign_flag = x_student_electronic_sign_flag) OR ((tlinfo.student_electronic_sign_flag IS NULL) AND (X_student_electronic_sign_flag IS NULL)))
        AND ((tlinfo.BOROWER_CREDIT_AUTHORIZ_FLAG = x_BOROWER_CREDIT_AUTHORIZ_FLAG) OR ((tlinfo.BOROWER_CREDIT_AUTHORIZ_FLAG IS NULL) AND (X_BOROWER_CREDIT_AUTHORIZ_FLAG IS NULL)))
        AND ((tlinfo.mpn_type_flag = x_mpn_type_flag) OR ((tlinfo.mpn_type_flag IS NULL) AND (X_mpn_type_flag IS NULL)))
        AND ((tlinfo.school_use_txt = x_school_use_txt) OR ((tlinfo.school_use_txt IS NULL) AND (X_school_use_txt IS NULL)))
        AND ((tlinfo.document_id_txt = x_document_id_txt) OR ((tlinfo.document_id_txt IS NULL) AND (X_document_id_txt IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (X_atd_entity_id_txt IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (X_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.source_entity_id_txt = x_source_entity_id_txt) OR ((tlinfo.source_entity_id_txt IS NULL) AND (X_source_entity_id_txt IS NULL)))
        AND ((tlinfo.interest_rebate_percent_num = x_interest_rebate_percent_num) OR ((tlinfo.interest_rebate_percent_num IS NULL) AND (X_interest_rebate_percent_num IS NULL)))
        AND ((tlinfo.esign_src_typ_cd = x_esign_src_typ_cd) OR ((tlinfo.esign_src_typ_cd IS NULL) AND (X_esign_src_typ_cd IS NULL)))
        AND (tlinfo.loansh_id = x_loansh_id)
        AND ((tlinfo.source_txt = x_source_txt) OR ((tlinfo.source_txt IS NULL) AND (X_source_txt IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'igf_sl_lor_loc_history_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_loan_id                           => x_loan_id,
      x_origination_id                    => x_origination_id,
      x_loan_number                       => x_loan_number,
      x_loan_type                         => x_loan_type,
      x_loan_amt_offered                  => x_loan_amt_offered,
      x_loan_amt_accepted                 => x_loan_amt_accepted,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_acad_yr_begin_date                => x_acad_yr_begin_date,
      x_acad_yr_end_date                  => x_acad_yr_end_date,
      x_loan_status                       => x_loan_status,
      x_loan_status_date                  => x_loan_status_date,
      x_loan_chg_status                   => x_loan_chg_status,
      x_loan_chg_status_date              => x_loan_chg_status_date,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_active                            => x_active,
      x_active_date                       => x_active_date,
      x_sch_cert_date                     => x_sch_cert_date,
      x_orig_status_flag                  => x_orig_status_flag,
      x_orig_batch_id                     => x_orig_batch_id,
      x_orig_batch_date                   => x_orig_batch_date,
      x_orig_ack_date                     => x_orig_ack_date,
      x_credit_override                   => x_credit_override,
      x_credit_decision_date              => x_credit_decision_date,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_pnote_status                      => x_pnote_status,
      x_pnote_status_date                 => x_pnote_status_date,
      x_pnote_id                          => x_pnote_id,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_accept_amt                  => x_pnote_accept_amt,
      x_pnote_accept_date                 => x_pnote_accept_date,
      x_p_signature_code                  => x_p_signature_code,
      x_p_signature_date                  => x_p_signature_date,
      x_s_signature_code                  => x_s_signature_code,
      x_unsub_elig_for_heal               => x_unsub_elig_for_heal,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_orig_fee_perct                    => x_orig_fee_perct,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_unsub_elig_for_depnt              => x_unsub_elig_for_depnt,
      x_guarantee_amt                     => x_guarantee_amt,
      x_guarantee_date                    => x_guarantee_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_lend_status_code                  => x_lend_status_code,
      x_lend_status_date                  => x_lend_status_date,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_borw_lender_id                    => x_borw_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_prc_type_code                     => x_prc_type_code,
      x_rec_type_ind                      => x_rec_type_ind,
      x_cl_loan_type                      => x_cl_loan_type,
      x_cl_seq_number                     => x_cl_seq_number,
      x_last_resort_lender                => x_last_resort_lender,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_borw_outstd_loan_code             => x_borw_outstd_loan_code,
      x_mpn_confirm_code                  => x_mpn_confirm_code,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_tot_outstd_stafford               => x_tot_outstd_stafford,
      x_tot_outstd_plus                   => x_tot_outstd_plus,
      x_alt_borw_tot_debt                 => x_alt_borw_tot_debt,
      x_act_interest_rate                 => x_act_interest_rate,
      x_service_type_code                 => x_service_type_code,
      x_rev_notice_of_guarnt              => x_rev_notice_of_guarnt,
      x_sch_refund_amt                    => x_sch_refund_amt,
      x_sch_refund_date                   => x_sch_refund_date,
      x_uniq_layout_vend_code             => x_uniq_layout_vend_code,
      x_uniq_layout_ident_code            => x_uniq_layout_ident_code,
      x_p_person_id                       => x_p_person_id,
      x_p_ssn                             => x_p_ssn,
      x_p_last_name                       => x_p_last_name,
      x_p_first_name                      => x_p_first_name,
      x_p_middle_name                     => x_p_middle_name,
      x_p_permt_addr1                     => x_p_permt_addr1,
      x_p_permt_addr2                     => x_p_permt_addr2,
      x_p_permt_city                      => x_p_permt_city,
      x_p_permt_state                     => x_p_permt_state,
      x_p_permt_zip                       => x_p_permt_zip,
      x_p_permt_addr_chg_date             => x_p_permt_addr_chg_date,
      x_p_permt_phone                     => x_p_permt_phone,
      x_p_email_addr                      => x_p_email_addr,
      x_p_date_of_birth                   => x_p_date_of_birth,
      x_p_license_num                     => x_p_license_num,
      x_p_license_state                   => x_p_license_state,
      x_p_citizenship_status              => x_p_citizenship_status,
      x_p_alien_reg_num                   => x_p_alien_reg_num,
      x_p_default_status                  => x_p_default_status,
      x_p_foreign_postal_code             => x_p_foreign_postal_code,
      x_p_state_of_legal_res              => x_p_state_of_legal_res,
      x_p_legal_res_date                  => x_p_legal_res_date,
      x_s_ssn                             => x_s_ssn,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_permt_addr1                     => x_s_permt_addr1,
      x_s_permt_addr2                     => x_s_permt_addr2,
      x_s_permt_city                      => x_s_permt_city,
      x_s_permt_state                     => x_s_permt_state,
      x_s_permt_zip                       => x_s_permt_zip,
      x_s_permt_addr_chg_date             => x_s_permt_addr_chg_date,
      x_s_permt_phone                     => x_s_permt_phone,
      x_s_local_addr1                     => x_s_local_addr1,
      x_s_local_addr2                     => x_s_local_addr2,
      x_s_local_city                      => x_s_local_city,
      x_s_local_state                     => x_s_local_state,
      x_s_local_zip                       => x_s_local_zip,
      x_s_email_addr                      => x_s_email_addr,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_license_num                     => x_s_license_num,
      x_s_license_state                   => x_s_license_state,
      x_s_depncy_status                   => x_s_depncy_status,
      x_s_default_status                  => x_s_default_status,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_alien_reg_num                   => x_s_alien_reg_num,
      x_s_foreign_postal_code             => x_s_foreign_postal_code,
      x_pnote_batch_id                    => x_pnote_batch_id,
      x_pnote_ack_date                    => x_pnote_ack_date,
      x_pnote_mpn_ind                     => x_pnote_mpn_ind,
      x_award_id                          => x_award_id,
      x_base_id                           => x_base_id,
      x_loan_key_num                      => x_loan_key_num,
      x_fin_award_year                    => x_fin_award_year,
      x_cps_trans_num                     => x_cps_trans_num,
      x_pymt_servicer_amt                 => x_pymt_servicer_amt,
      x_pymt_servicer_date                => x_pymt_servicer_date,
      x_book_loan_amt                     => x_book_loan_amt,
      x_book_loan_amt_date                => x_book_loan_amt_date,
      x_s_chg_ssn                         => x_s_chg_ssn,
      x_s_chg_last_name                   => x_s_chg_last_name,
      x_b_chg_ssn                         => x_b_chg_ssn,
      x_b_chg_last_name                   => x_b_chg_last_name,
      x_note_message                      => x_note_message,
      x_full_resp_code                    => x_full_resp_code,
      x_s_permt_county                    => x_s_permt_county,
      x_b_permt_county                    => x_b_permt_county,
      x_s_permt_country                   => x_s_permt_country,
      x_b_permt_country                   => x_b_permt_country,
      x_crdt_decision_status              => x_crdt_decision_status,
      x_b_chg_birth_date                  => x_b_chg_birth_date,
      x_s_chg_birth_date                  => x_s_chg_birth_date,
      x_external_loan_id_txt              => x_external_loan_id_txt,
      x_deferment_request_code            => x_deferment_request_code,
      x_eft_authorization_code            => x_eft_authorization_code,
      x_requested_loan_amt                => x_requested_loan_amt,
      x_actual_record_type_code           => x_actual_record_type_code,
      x_reinstatement_amt                 => x_reinstatement_amt,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_fls_approved_amt                  => x_fls_approved_amt,
      x_flu_approved_amt                  => x_flu_approved_amt,
      x_flp_approved_amt                  => x_flp_approved_amt,
      x_alt_approved_amt                  => x_alt_approved_amt,
      x_loan_app_form_code                => x_loan_app_form_code,
      x_alt_borrower_ind_flag             => x_alt_borrower_ind_flag,
      x_school_id_txt                     => x_school_id_txt,
      x_cost_of_attendance_amt            => x_cost_of_attendance_amt,
      x_EXPECT_FAMILY_CONTRIBUTE_AMT    => x_EXPECT_FAMILY_CONTRIBUTE_AMT,
      x_established_fin_aid_amount        => x_established_fin_aid_amount,
      x_BOROWER_ELECTRONIC_SIGN_FLAG     => x_BOROWER_ELECTRONIC_SIGN_FLAG,
      x_student_electronic_sign_flag      => x_student_electronic_sign_flag,
      x_BOROWER_CREDIT_AUTHORIZ_FLAG     => x_BOROWER_CREDIT_AUTHORIZ_FLAG,
      x_mpn_type_flag                     => x_mpn_type_flag,
      x_school_use_txt                    => x_school_use_txt,
      x_document_id_txt                   => x_document_id_txt,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_source_entity_id_txt              => x_source_entity_id_txt,
      x_interest_rebate_percent_num       => x_interest_rebate_percent_num,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd,
      x_loansh_id                         => x_loansh_id,
      x_source_txt                        => x_source_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_sl_lor_loc_history
      SET
        loan_id                           = new_references.loan_id,
        origination_id                    = new_references.origination_id,
        loan_number                       = new_references.loan_number,
        loan_type                         = new_references.loan_type,
        loan_amt_offered                  = new_references.loan_amt_offered,
        loan_amt_accepted                 = new_references.loan_amt_accepted,
        loan_per_begin_date               = new_references.loan_per_begin_date,
        loan_per_end_date                 = new_references.loan_per_end_date,
        acad_yr_begin_date                = new_references.acad_yr_begin_date,
        acad_yr_end_date                  = new_references.acad_yr_end_date,
        loan_status                       = new_references.loan_status,
        loan_status_date                  = new_references.loan_status_date,
        loan_chg_status                   = new_references.loan_chg_status,
        loan_chg_status_date              = new_references.loan_chg_status_date,
        req_serial_loan_code              = new_references.req_serial_loan_code,
        act_serial_loan_code              = new_references.act_serial_loan_code,
        active                            = new_references.active,
        active_date                       = new_references.active_date,
        sch_cert_date                     = new_references.sch_cert_date,
        orig_status_flag                  = new_references.orig_status_flag,
        orig_batch_id                     = new_references.orig_batch_id,
        orig_batch_date                   = new_references.orig_batch_date,
        orig_ack_date                     = new_references.orig_ack_date,
        credit_override                   = new_references.credit_override,
        credit_decision_date              = new_references.credit_decision_date,
        pnote_delivery_code               = new_references.pnote_delivery_code,
        pnote_status                      = new_references.pnote_status,
        pnote_status_date                 = new_references.pnote_status_date,
        pnote_id                          = new_references.pnote_id,
        pnote_print_ind                   = new_references.pnote_print_ind,
        pnote_accept_amt                  = new_references.pnote_accept_amt,
        pnote_accept_date                 = new_references.pnote_accept_date,
        p_signature_code                  = new_references.p_signature_code,
        p_signature_date                  = new_references.p_signature_date,
        s_signature_code                  = new_references.s_signature_code,
        unsub_elig_for_heal               = new_references.unsub_elig_for_heal,
        disclosure_print_ind              = new_references.disclosure_print_ind,
        orig_fee_perct                    = new_references.orig_fee_perct,
        borw_confirm_ind                  = new_references.borw_confirm_ind,
        borw_interest_ind                 = new_references.borw_interest_ind,
        unsub_elig_for_depnt              = new_references.unsub_elig_for_depnt,
        guarantee_amt                     = new_references.guarantee_amt,
        guarantee_date                    = new_references.guarantee_date,
        guarnt_adj_ind                    = new_references.guarnt_adj_ind,
        guarnt_amt_redn_code              = new_references.guarnt_amt_redn_code,
        guarnt_status_code                = new_references.guarnt_status_code,
        guarnt_status_date                = new_references.guarnt_status_date,
        lend_apprv_denied_code            = new_references.lend_apprv_denied_code,
        lend_apprv_denied_date            = new_references.lend_apprv_denied_date,
        lend_status_code                  = new_references.lend_status_code,
        lend_status_date                  = new_references.lend_status_date,
        grade_level_code                  = new_references.grade_level_code,
        enrollment_code                   = new_references.enrollment_code,
        anticip_compl_date                = new_references.anticip_compl_date,
        borw_lender_id                    = new_references.borw_lender_id,
        guarantor_id                      = new_references.guarantor_id,
        prc_type_code                     = new_references.prc_type_code,
        rec_type_ind                      = new_references.rec_type_ind,
        cl_loan_type                      = new_references.cl_loan_type,
        cl_seq_number                     = new_references.cl_seq_number,
        last_resort_lender                = new_references.last_resort_lender,
        lender_id                         = new_references.lender_id,
        lend_non_ed_brc_id                = new_references.lend_non_ed_brc_id,
        recipient_id                      = new_references.recipient_id,
        recipient_type                    = new_references.recipient_type,
        recip_non_ed_brc_id               = new_references.recip_non_ed_brc_id,
        cl_rec_status                     = new_references.cl_rec_status,
        cl_rec_status_last_update         = new_references.cl_rec_status_last_update,
        alt_prog_type_code                = new_references.alt_prog_type_code,
        alt_appl_ver_code                 = new_references.alt_appl_ver_code,
        borw_outstd_loan_code             = new_references.borw_outstd_loan_code,
        mpn_confirm_code                  = new_references.mpn_confirm_code,
        resp_to_orig_code                 = new_references.resp_to_orig_code,
        appl_loan_phase_code              = new_references.appl_loan_phase_code,
        appl_loan_phase_code_chg          = new_references.appl_loan_phase_code_chg,
        tot_outstd_stafford               = new_references.tot_outstd_stafford,
        tot_outstd_plus                   = new_references.tot_outstd_plus,
        alt_borw_tot_debt                 = new_references.alt_borw_tot_debt,
        act_interest_rate                 = new_references.act_interest_rate,
        service_type_code                 = new_references.service_type_code,
        rev_notice_of_guarnt              = new_references.rev_notice_of_guarnt,
        sch_refund_amt                    = new_references.sch_refund_amt,
        sch_refund_date                   = new_references.sch_refund_date,
        uniq_layout_vend_code             = new_references.uniq_layout_vend_code,
        uniq_layout_ident_code            = new_references.uniq_layout_ident_code,
        p_person_id                       = new_references.p_person_id,
        p_ssn                             = new_references.p_ssn,
        p_last_name                       = new_references.p_last_name,
        p_first_name                      = new_references.p_first_name,
        p_middle_name                     = new_references.p_middle_name,
        p_permt_addr1                     = new_references.p_permt_addr1,
        p_permt_addr2                     = new_references.p_permt_addr2,
        p_permt_city                      = new_references.p_permt_city,
        p_permt_state                     = new_references.p_permt_state,
        p_permt_zip                       = new_references.p_permt_zip,
        p_permt_addr_chg_date             = new_references.p_permt_addr_chg_date,
        p_permt_phone                     = new_references.p_permt_phone,
        p_email_addr                      = new_references.p_email_addr,
        p_date_of_birth                   = new_references.p_date_of_birth,
        p_license_num                     = new_references.p_license_num,
        p_license_state                   = new_references.p_license_state,
        p_citizenship_status              = new_references.p_citizenship_status,
        p_alien_reg_num                   = new_references.p_alien_reg_num,
        p_default_status                  = new_references.p_default_status,
        p_foreign_postal_code             = new_references.p_foreign_postal_code,
        p_state_of_legal_res              = new_references.p_state_of_legal_res,
        p_legal_res_date                  = new_references.p_legal_res_date,
        s_ssn                             = new_references.s_ssn,
        s_last_name                       = new_references.s_last_name,
        s_first_name                      = new_references.s_first_name,
        s_middle_name                     = new_references.s_middle_name,
        s_permt_addr1                     = new_references.s_permt_addr1,
        s_permt_addr2                     = new_references.s_permt_addr2,
        s_permt_city                      = new_references.s_permt_city,
        s_permt_state                     = new_references.s_permt_state,
        s_permt_zip                       = new_references.s_permt_zip,
        s_permt_addr_chg_date             = new_references.s_permt_addr_chg_date,
        s_permt_phone                     = new_references.s_permt_phone,
        s_local_addr1                     = new_references.s_local_addr1,
        s_local_addr2                     = new_references.s_local_addr2,
        s_local_city                      = new_references.s_local_city,
        s_local_state                     = new_references.s_local_state,
        s_local_zip                       = new_references.s_local_zip,
        s_email_addr                      = new_references.s_email_addr,
        s_date_of_birth                   = new_references.s_date_of_birth,
        s_license_num                     = new_references.s_license_num,
        s_license_state                   = new_references.s_license_state,
        s_depncy_status                   = new_references.s_depncy_status,
        s_default_status                  = new_references.s_default_status,
        s_citizenship_status              = new_references.s_citizenship_status,
        s_alien_reg_num                   = new_references.s_alien_reg_num,
        s_foreign_postal_code             = new_references.s_foreign_postal_code,
        pnote_batch_id                    = new_references.pnote_batch_id,
        pnote_ack_date                    = new_references.pnote_ack_date,
        pnote_mpn_ind                     = new_references.pnote_mpn_ind,
        award_id                          = new_references.award_id,
        base_id                           = new_references.base_id,
        loan_key_num                      = new_references.loan_key_num,
        fin_award_year                    = new_references.fin_award_year,
        cps_trans_num                     = new_references.cps_trans_num,
        pymt_servicer_amt                 = new_references.pymt_servicer_amt,
        pymt_servicer_date                = new_references.pymt_servicer_date,
        book_loan_amt                     = new_references.book_loan_amt,
        book_loan_amt_date                = new_references.book_loan_amt_date,
        s_chg_ssn                         = new_references.s_chg_ssn,
        s_chg_last_name                   = new_references.s_chg_last_name,
        b_chg_ssn                         = new_references.b_chg_ssn,
        b_chg_last_name                   = new_references.b_chg_last_name,
        note_message                      = new_references.note_message,
        full_resp_code                    = new_references.full_resp_code,
        s_permt_county                    = new_references.s_permt_county,
        b_permt_county                    = new_references.b_permt_county,
        s_permt_country                   = new_references.s_permt_country,
        b_permt_country                   = new_references.b_permt_country,
        crdt_decision_status              = new_references.crdt_decision_status,
        b_chg_birth_date                  = new_references.b_chg_birth_date,
        s_chg_birth_date                  = new_references.s_chg_birth_date,
        external_loan_id_txt              = new_references.external_loan_id_txt,
        deferment_request_code            = new_references.deferment_request_code,
        eft_authorization_code            = new_references.eft_authorization_code,
        requested_loan_amt                = new_references.requested_loan_amt,
        actual_record_type_code           = new_references.actual_record_type_code,
        reinstatement_amt                 = new_references.reinstatement_amt,
        lender_use_txt                    = new_references.lender_use_txt,
        guarantor_use_txt                 = new_references.guarantor_use_txt,
        fls_approved_amt                  = new_references.fls_approved_amt,
        flu_approved_amt                  = new_references.flu_approved_amt,
        flp_approved_amt                  = new_references.flp_approved_amt,
        alt_approved_amt                  = new_references.alt_approved_amt,
        loan_app_form_code                = new_references.loan_app_form_code,
        alt_borrower_ind_flag             = new_references.alt_borrower_ind_flag,
        school_id_txt                     = new_references.school_id_txt,
        cost_of_attendance_amt            = new_references.cost_of_attendance_amt,
        EXPECT_FAMILY_CONTRIBUTE_AMT    = new_references.EXPECT_FAMILY_CONTRIBUTE_AMT,
        established_fin_aid_amount        = new_references.established_fin_aid_amount,
        BOROWER_ELECTRONIC_SIGN_FLAG     = new_references.BOROWER_ELECTRONIC_SIGN_FLAG,
        student_electronic_sign_flag      = new_references.student_electronic_sign_flag,
        BOROWER_CREDIT_AUTHORIZ_FLAG     = new_references.BOROWER_CREDIT_AUTHORIZ_FLAG,
        mpn_type_flag                     = new_references.mpn_type_flag,
        school_use_txt                    = new_references.school_use_txt,
        document_id_txt                   = new_references.document_id_txt,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        source_entity_id_txt              = new_references.source_entity_id_txt,
        interest_rebate_percent_num       = new_references.interest_rebate_percent_num,
        esign_src_typ_cd                  = new_references.esign_src_typ_cd,
        loansh_id                         = new_references.loansh_id,
        source_txt                        = new_references.source_txt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_origination_id                    IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_type                         IN     VARCHAR2,
    x_loan_amt_offered                  IN     NUMBER,
    x_loan_amt_accepted                 IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_acad_yr_begin_date                IN     DATE,
    x_acad_yr_end_date                  IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_signature_code                  IN     VARCHAR2,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_p_person_id                       IN     NUMBER,
    x_p_ssn                             IN     VARCHAR2,
    x_p_last_name                       IN     VARCHAR2,
    x_p_first_name                      IN     VARCHAR2,
    x_p_middle_name                     IN     VARCHAR2,
    x_p_permt_addr1                     IN     VARCHAR2,
    x_p_permt_addr2                     IN     VARCHAR2,
    x_p_permt_city                      IN     VARCHAR2,
    x_p_permt_state                     IN     VARCHAR2,
    x_p_permt_zip                       IN     VARCHAR2,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_permt_phone                     IN     VARCHAR2,
    x_p_email_addr                      IN     VARCHAR2,
    x_p_date_of_birth                   IN     DATE,
    x_p_license_num                     IN     VARCHAR2,
    x_p_license_state                   IN     VARCHAR2,
    x_p_citizenship_status              IN     VARCHAR2,
    x_p_alien_reg_num                   IN     VARCHAR2,
    x_p_default_status                  IN     VARCHAR2,
    x_p_foreign_postal_code             IN     VARCHAR2,
    x_p_state_of_legal_res              IN     VARCHAR2,
    x_p_legal_res_date                  IN     DATE,
    x_s_ssn                             IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_permt_phone                     IN     VARCHAR2,
    x_s_local_addr1                     IN     VARCHAR2,
    x_s_local_addr2                     IN     VARCHAR2,
    x_s_local_city                      IN     VARCHAR2,
    x_s_local_state                     IN     VARCHAR2,
    x_s_local_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_depncy_status                   IN     VARCHAR2,
    x_s_default_status                  IN     VARCHAR2,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_alien_reg_num                   IN     VARCHAR2,
    x_s_foreign_postal_code             IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_loan_key_num                      IN     NUMBER,
    x_fin_award_year                    IN     VARCHAR2,
    x_cps_trans_num                     IN     NUMBER,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_s_chg_ssn                         IN     VARCHAR2,
    x_s_chg_last_name                   IN     VARCHAR2,
    x_b_chg_ssn                         IN     VARCHAR2,
    x_b_chg_last_name                   IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_full_resp_code                    IN     VARCHAR2,
    x_s_permt_county                    IN     VARCHAR2,
    x_b_permt_county                    IN     VARCHAR2,
    x_s_permt_country                   IN     VARCHAR2,
    x_b_permt_country                   IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_b_chg_birth_date                  IN     DATE,
    x_s_chg_birth_date                  IN     DATE,
    x_external_loan_id_txt              IN     VARCHAR2,
    x_deferment_request_code            IN     VARCHAR2,
    x_eft_authorization_code            IN     VARCHAR2,
    x_requested_loan_amt                IN     NUMBER,
    x_actual_record_type_code           IN     VARCHAR2,
    x_reinstatement_amt                 IN     NUMBER,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_loan_app_form_code                IN     VARCHAR2,
    x_alt_borrower_ind_flag             IN     VARCHAR2,
    x_school_id_txt                     IN     VARCHAR2,
    x_cost_of_attendance_amt            IN     NUMBER,
    x_EXPECT_FAMILY_CONTRIBUTE_AMT    IN     NUMBER,
    x_established_fin_aid_amount        IN     NUMBER,
    x_BOROWER_ELECTRONIC_SIGN_FLAG     IN     VARCHAR2,
    x_student_electronic_sign_flag      IN     VARCHAR2,
    x_BOROWER_CREDIT_AUTHORIZ_FLAG     IN     VARCHAR2,
    x_mpn_type_flag                     IN     VARCHAR2,
    x_school_use_txt                    IN     VARCHAR2,
    x_document_id_txt                   IN     VARCHAR2,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_source_entity_id_txt              IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_loansh_id                         IN OUT NOCOPY NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_lor_loc_history
      WHERE    loansh_id = x_loansh_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_loan_id,
        x_origination_id,
        x_loan_number,
        x_loan_type,
        x_loan_amt_offered,
        x_loan_amt_accepted,
        x_loan_per_begin_date,
        x_loan_per_end_date,
        x_acad_yr_begin_date,
        x_acad_yr_end_date,
        x_loan_status,
        x_loan_status_date,
        x_loan_chg_status,
        x_loan_chg_status_date,
        x_req_serial_loan_code,
        x_act_serial_loan_code,
        x_active,
        x_active_date,
        x_sch_cert_date,
        x_orig_status_flag,
        x_orig_batch_id,
        x_orig_batch_date,
        x_orig_ack_date,
        x_credit_override,
        x_credit_decision_date,
        x_pnote_delivery_code,
        x_pnote_status,
        x_pnote_status_date,
        x_pnote_id,
        x_pnote_print_ind,
        x_pnote_accept_amt,
        x_pnote_accept_date,
        x_p_signature_code,
        x_p_signature_date,
        x_s_signature_code,
        x_unsub_elig_for_heal,
        x_disclosure_print_ind,
        x_orig_fee_perct,
        x_borw_confirm_ind,
        x_borw_interest_ind,
        x_unsub_elig_for_depnt,
        x_guarantee_amt,
        x_guarantee_date,
        x_guarnt_adj_ind,
        x_guarnt_amt_redn_code,
        x_guarnt_status_code,
        x_guarnt_status_date,
        x_lend_apprv_denied_code,
        x_lend_apprv_denied_date,
        x_lend_status_code,
        x_lend_status_date,
        x_grade_level_code,
        x_enrollment_code,
        x_anticip_compl_date,
        x_borw_lender_id,
        x_guarantor_id,
        x_prc_type_code,
        x_rec_type_ind,
        x_cl_loan_type,
        x_cl_seq_number,
        x_last_resort_lender,
        x_lender_id,
        x_lend_non_ed_brc_id,
        x_recipient_id,
        x_recipient_type,
        x_recip_non_ed_brc_id,
        x_cl_rec_status,
        x_cl_rec_status_last_update,
        x_alt_prog_type_code,
        x_alt_appl_ver_code,
        x_borw_outstd_loan_code,
        x_mpn_confirm_code,
        x_resp_to_orig_code,
        x_appl_loan_phase_code,
        x_appl_loan_phase_code_chg,
        x_tot_outstd_stafford,
        x_tot_outstd_plus,
        x_alt_borw_tot_debt,
        x_act_interest_rate,
        x_service_type_code,
        x_rev_notice_of_guarnt,
        x_sch_refund_amt,
        x_sch_refund_date,
        x_uniq_layout_vend_code,
        x_uniq_layout_ident_code,
        x_p_person_id,
        x_p_ssn,
        x_p_last_name,
        x_p_first_name,
        x_p_middle_name,
        x_p_permt_addr1,
        x_p_permt_addr2,
        x_p_permt_city,
        x_p_permt_state,
        x_p_permt_zip,
        x_p_permt_addr_chg_date,
        x_p_permt_phone,
        x_p_email_addr,
        x_p_date_of_birth,
        x_p_license_num,
        x_p_license_state,
        x_p_citizenship_status,
        x_p_alien_reg_num,
        x_p_default_status,
        x_p_foreign_postal_code,
        x_p_state_of_legal_res,
        x_p_legal_res_date,
        x_s_ssn,
        x_s_last_name,
        x_s_first_name,
        x_s_middle_name,
        x_s_permt_addr1,
        x_s_permt_addr2,
        x_s_permt_city,
        x_s_permt_state,
        x_s_permt_zip,
        x_s_permt_addr_chg_date,
        x_s_permt_phone,
        x_s_local_addr1,
        x_s_local_addr2,
        x_s_local_city,
        x_s_local_state,
        x_s_local_zip,
        x_s_email_addr,
        x_s_date_of_birth,
        x_s_license_num,
        x_s_license_state,
        x_s_depncy_status,
        x_s_default_status,
        x_s_citizenship_status,
        x_s_alien_reg_num,
        x_s_foreign_postal_code,
        x_pnote_batch_id,
        x_pnote_ack_date,
        x_pnote_mpn_ind,
        x_award_id,
        x_base_id,
        x_loan_key_num,
        x_fin_award_year,
        x_cps_trans_num,
        x_pymt_servicer_amt,
        x_pymt_servicer_date,
        x_book_loan_amt,
        x_book_loan_amt_date,
        x_s_chg_ssn,
        x_s_chg_last_name,
        x_b_chg_ssn,
        x_b_chg_last_name,
        x_note_message,
        x_full_resp_code,
        x_s_permt_county,
        x_b_permt_county,
        x_s_permt_country,
        x_b_permt_country,
        x_crdt_decision_status,
        x_b_chg_birth_date,
        x_s_chg_birth_date,
        x_external_loan_id_txt,
        x_deferment_request_code,
        x_eft_authorization_code,
        x_requested_loan_amt,
        x_actual_record_type_code,
        x_reinstatement_amt,
        x_lender_use_txt,
        x_guarantor_use_txt,
        x_fls_approved_amt,
        x_flu_approved_amt,
        x_flp_approved_amt,
        x_alt_approved_amt,
        x_loan_app_form_code,
        x_alt_borrower_ind_flag,
        x_school_id_txt,
        x_cost_of_attendance_amt,
        x_EXPECT_FAMILY_CONTRIBUTE_AMT,
        x_established_fin_aid_amount,
        x_BOROWER_ELECTRONIC_SIGN_FLAG,
        x_student_electronic_sign_flag,
        x_BOROWER_CREDIT_AUTHORIZ_FLAG,
        x_mpn_type_flag,
        x_school_use_txt,
        x_document_id_txt,
        x_atd_entity_id_txt,
        x_rep_entity_id_txt,
        x_source_entity_id_txt,
        x_interest_rebate_percent_num,
        x_esign_src_typ_cd,
        x_loansh_id,
        x_source_txt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_loan_id,
      x_origination_id,
      x_loan_number,
      x_loan_type,
      x_loan_amt_offered,
      x_loan_amt_accepted,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_acad_yr_begin_date,
      x_acad_yr_end_date,
      x_loan_status,
      x_loan_status_date,
      x_loan_chg_status,
      x_loan_chg_status_date,
      x_req_serial_loan_code,
      x_act_serial_loan_code,
      x_active,
      x_active_date,
      x_sch_cert_date,
      x_orig_status_flag,
      x_orig_batch_id,
      x_orig_batch_date,
      x_orig_ack_date,
      x_credit_override,
      x_credit_decision_date,
      x_pnote_delivery_code,
      x_pnote_status,
      x_pnote_status_date,
      x_pnote_id,
      x_pnote_print_ind,
      x_pnote_accept_amt,
      x_pnote_accept_date,
      x_p_signature_code,
      x_p_signature_date,
      x_s_signature_code,
      x_unsub_elig_for_heal,
      x_disclosure_print_ind,
      x_orig_fee_perct,
      x_borw_confirm_ind,
      x_borw_interest_ind,
      x_unsub_elig_for_depnt,
      x_guarantee_amt,
      x_guarantee_date,
      x_guarnt_adj_ind,
      x_guarnt_amt_redn_code,
      x_guarnt_status_code,
      x_guarnt_status_date,
      x_lend_apprv_denied_code,
      x_lend_apprv_denied_date,
      x_lend_status_code,
      x_lend_status_date,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_borw_lender_id,
      x_guarantor_id,
      x_prc_type_code,
      x_rec_type_ind,
      x_cl_loan_type,
      x_cl_seq_number,
      x_last_resort_lender,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_recipient_id,
      x_recipient_type,
      x_recip_non_ed_brc_id,
      x_cl_rec_status,
      x_cl_rec_status_last_update,
      x_alt_prog_type_code,
      x_alt_appl_ver_code,
      x_borw_outstd_loan_code,
      x_mpn_confirm_code,
      x_resp_to_orig_code,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_tot_outstd_stafford,
      x_tot_outstd_plus,
      x_alt_borw_tot_debt,
      x_act_interest_rate,
      x_service_type_code,
      x_rev_notice_of_guarnt,
      x_sch_refund_amt,
      x_sch_refund_date,
      x_uniq_layout_vend_code,
      x_uniq_layout_ident_code,
      x_p_person_id,
      x_p_ssn,
      x_p_last_name,
      x_p_first_name,
      x_p_middle_name,
      x_p_permt_addr1,
      x_p_permt_addr2,
      x_p_permt_city,
      x_p_permt_state,
      x_p_permt_zip,
      x_p_permt_addr_chg_date,
      x_p_permt_phone,
      x_p_email_addr,
      x_p_date_of_birth,
      x_p_license_num,
      x_p_license_state,
      x_p_citizenship_status,
      x_p_alien_reg_num,
      x_p_default_status,
      x_p_foreign_postal_code,
      x_p_state_of_legal_res,
      x_p_legal_res_date,
      x_s_ssn,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_name,
      x_s_permt_addr1,
      x_s_permt_addr2,
      x_s_permt_city,
      x_s_permt_state,
      x_s_permt_zip,
      x_s_permt_addr_chg_date,
      x_s_permt_phone,
      x_s_local_addr1,
      x_s_local_addr2,
      x_s_local_city,
      x_s_local_state,
      x_s_local_zip,
      x_s_email_addr,
      x_s_date_of_birth,
      x_s_license_num,
      x_s_license_state,
      x_s_depncy_status,
      x_s_default_status,
      x_s_citizenship_status,
      x_s_alien_reg_num,
      x_s_foreign_postal_code,
      x_pnote_batch_id,
      x_pnote_ack_date,
      x_pnote_mpn_ind,
      x_award_id,
      x_base_id,
      x_loan_key_num,
      x_fin_award_year,
      x_cps_trans_num,
      x_pymt_servicer_amt,
      x_pymt_servicer_date,
      x_book_loan_amt,
      x_book_loan_amt_date,
      x_s_chg_ssn,
      x_s_chg_last_name,
      x_b_chg_ssn,
      x_b_chg_last_name,
      x_note_message,
      x_full_resp_code,
      x_s_permt_county,
      x_b_permt_county,
      x_s_permt_country,
      x_b_permt_country,
      x_crdt_decision_status,
      x_b_chg_birth_date,
      x_s_chg_birth_date,
      x_external_loan_id_txt,
      x_deferment_request_code,
      x_eft_authorization_code,
      x_requested_loan_amt,
      x_actual_record_type_code,
      x_reinstatement_amt,
      x_lender_use_txt,
      x_guarantor_use_txt,
      x_fls_approved_amt,
      x_flu_approved_amt,
      x_flp_approved_amt,
      x_alt_approved_amt,
      x_loan_app_form_code,
      x_alt_borrower_ind_flag,
      x_school_id_txt,
      x_cost_of_attendance_amt,
      x_EXPECT_FAMILY_CONTRIBUTE_AMT,
      x_established_fin_aid_amount,
      x_BOROWER_ELECTRONIC_SIGN_FLAG,
      x_student_electronic_sign_flag,
      x_BOROWER_CREDIT_AUTHORIZ_FLAG,
      x_mpn_type_flag,
      x_school_use_txt,
      x_document_id_txt,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_source_entity_id_txt,
      x_interest_rebate_percent_num,
      x_esign_src_typ_cd,
      x_loansh_id,
      x_source_txt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : puneet.sahni@oracle.com
  ||  Created On : 03-NOV-2004
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_sl_lor_loc_history
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_lor_loc_history_pkg;

/
