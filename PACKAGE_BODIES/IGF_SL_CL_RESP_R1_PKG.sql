--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_RESP_R1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_RESP_R1_PKG" AS
/* $Header: IGFLI22B.pls 120.1 2006/04/19 08:25:43 bvisvana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_cl_resp_r1_all%ROWTYPE;
  new_references igf_sl_cl_resp_r1_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_cbth_id                           IN     NUMBER      DEFAULT NULL,
    x_rec_code                          IN     VARCHAR2    DEFAULT NULL,
    x_rec_type_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_b_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_b_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_b_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_b_ssn                             IN     NUMBER      DEFAULT NULL,
    x_b_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_zip                       IN     NUMBER      DEFAULT NULL,
    x_b_permt_zip_suffix                IN     NUMBER      DEFAULT NULL,
    x_b_permt_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_b_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_cl_loan_type                      IN     VARCHAR2    DEFAULT NULL,
    x_req_loan_amt                      IN     NUMBER      DEFAULT NULL,
    x_defer_req_code                    IN     VARCHAR2    DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_eft_auth_code                     IN     VARCHAR2    DEFAULT NULL,
    x_b_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_b_signature_date                  IN     DATE        DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_cl_seq_number                     IN     NUMBER      DEFAULT NULL,
    x_b_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_b_state_of_legal_res              IN     VARCHAR2    DEFAULT NULL,
    x_b_legal_res_date                  IN     DATE        DEFAULT NULL,
    x_b_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_b_outstd_loan_code                IN     VARCHAR2    DEFAULT NULL,
    x_b_indicator_code                  IN     VARCHAR2    DEFAULT NULL,
    x_s_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_s_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_s_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_s_ssn                             IN     NUMBER      DEFAULT NULL,
    x_s_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_s_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_s_default_code                    IN     VARCHAR2    DEFAULT NULL,
    x_s_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_school_id                         IN     NUMBER      DEFAULT NULL,
    x_loan_per_begin_date               IN     DATE        DEFAULT NULL,
    x_loan_per_end_date                 IN     DATE        DEFAULT NULL,
    x_grade_level_code                  IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_code                   IN     VARCHAR2    DEFAULT NULL,
    x_anticip_compl_date                IN     DATE        DEFAULT NULL,
    x_coa_amt                           IN     NUMBER      DEFAULT NULL,
    x_efc_amt                           IN     NUMBER      DEFAULT NULL,
    x_est_fa_amt                        IN     NUMBER      DEFAULT NULL,
    x_fls_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_flu_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_flp_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_sch_cert_date                     IN     DATE        DEFAULT NULL,
    x_alt_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_alt_appl_ver_code                 IN     NUMBER      DEFAULT NULL,
    x_duns_school_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_fls_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_flu_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_flp_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_alt_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_fed_appl_form_code                IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2    DEFAULT NULL,
    x_lend_blkt_guarnt_appr_date        IN     DATE        DEFAULT NULL,
    x_guarnt_adj_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantee_date                    IN     DATE        DEFAULT NULL,
    x_guarantee_amt                     IN     NUMBER      DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_borw_confirm_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_b_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_b_license_number                  IN     VARCHAR2    DEFAULT NULL,
    x_b_ref_code                        IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_b_foreign_postal_code             IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_last_resort_lender                IN     VARCHAR2    DEFAULT NULL,
    x_resp_to_orig_code                 IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_1                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_2                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_3                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_4                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_5                        IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_amt_redn_code              IN     VARCHAR2    DEFAULT NULL,
    x_tot_outstd_stafford               IN     NUMBER      DEFAULT NULL,
    x_tot_outstd_plus                   IN     NUMBER      DEFAULT NULL,
    x_b_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_alt_prog_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_alt_borw_tot_debt                 IN     NUMBER      DEFAULT NULL,
    x_act_interest_rate                 IN     NUMBER      DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_service_type_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rev_notice_of_guarnt              IN     VARCHAR2    DEFAULT NULL,
    x_sch_refund_amt                    IN     NUMBER      DEFAULT NULL,
    x_sch_refund_date                   IN     DATE        DEFAULT NULL,
    x_guarnt_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_lender_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status_code                 IN     VARCHAR2    DEFAULT NULL,
    x_credit_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_date                IN     DATE        DEFAULT NULL,
    x_lender_status_date                IN     DATE        DEFAULT NULL,
    x_pnote_status_date                 IN     DATE        DEFAULT NULL,
    x_credit_status_date                IN     DATE        DEFAULT NULL,
    x_act_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_amt_avail_for_reinst              IN     NUMBER      DEFAULT NULL,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_vend_code             IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_ident_code            IN     VARCHAR2    DEFAULT NULL,
    x_resp_record_status                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_borr_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_stud_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_borr_credit_auth_code             IN     VARCHAR2    DEFAULT NULL,
    x_mpn_confirm_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_lender_use_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_use_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code              IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code_chg          IN     DATE        DEFAULT NULL,
    x_cl_rec_status                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status_last_update         IN     DATE        DEFAULT NULL,
    x_lend_apprv_denied_code            IN     VARCHAR2    DEFAULT NULL,
    x_lend_apprv_denied_date            IN     DATE        DEFAULT NULL,
    x_cl_version_code                   IN     VARCHAR2    DEFAULT NULL,
    x_school_use_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_b_alien_reg_num_txt               IN     VARCHAR2    DEFAULT NULL,
    x_esign_src_typ_cd                  IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_cl_resp_r1_all
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
    new_references.clrp1_id                          := x_clrp1_id;
    new_references.cbth_id                           := x_cbth_id;
    new_references.rec_code                          := x_rec_code;
    new_references.rec_type_ind                      := x_rec_type_ind;
    new_references.b_last_name                       := x_b_last_name;
    new_references.b_first_name                      := x_b_first_name;
    new_references.b_middle_name                     := x_b_middle_name;
    new_references.b_ssn                             := x_b_ssn;
    new_references.b_permt_addr1                     := x_b_permt_addr1;
    new_references.b_permt_addr2                     := x_b_permt_addr2;
    new_references.b_permt_city                      := x_b_permt_city;
    new_references.b_permt_state                     := x_b_permt_state;
    new_references.b_permt_zip                       := x_b_permt_zip;
    new_references.b_permt_zip_suffix                := x_b_permt_zip_suffix;
    new_references.b_permt_phone                     := x_b_permt_phone;
    new_references.b_date_of_birth                   := x_b_date_of_birth;
    new_references.cl_loan_type                      := x_cl_loan_type;
    new_references.req_loan_amt                      := x_req_loan_amt;
    new_references.defer_req_code                    := x_defer_req_code;
    new_references.borw_interest_ind                 := x_borw_interest_ind;
    new_references.eft_auth_code                     := x_eft_auth_code;
    new_references.b_signature_code                  := x_b_signature_code;
    new_references.b_signature_date                  := x_b_signature_date;
    new_references.loan_number                       := x_loan_number;
    new_references.cl_seq_number                     := x_cl_seq_number;
    new_references.b_citizenship_status              := x_b_citizenship_status;
    new_references.b_state_of_legal_res              := x_b_state_of_legal_res;
    new_references.b_legal_res_date                  := x_b_legal_res_date;
    new_references.b_default_status                  := x_b_default_status;
    new_references.b_outstd_loan_code                := x_b_outstd_loan_code;
    new_references.b_indicator_code                  := x_b_indicator_code;
    new_references.s_last_name                       := x_s_last_name;
    new_references.s_first_name                      := x_s_first_name;
    new_references.s_middle_name                     := x_s_middle_name;
    new_references.s_ssn                             := x_s_ssn;
    new_references.s_date_of_birth                   := x_s_date_of_birth;
    new_references.s_citizenship_status              := x_s_citizenship_status;
    new_references.s_default_code                    := x_s_default_code;
    new_references.s_signature_code                  := x_s_signature_code;
    new_references.school_id                         := x_school_id;
    new_references.loan_per_begin_date               := x_loan_per_begin_date;
    new_references.loan_per_end_date                 := x_loan_per_end_date;
    new_references.grade_level_code                  := x_grade_level_code;
    new_references.enrollment_code                   := x_enrollment_code;
    new_references.anticip_compl_date                := x_anticip_compl_date;
    new_references.coa_amt                           := x_coa_amt;
    new_references.efc_amt                           := x_efc_amt;
    new_references.est_fa_amt                        := x_est_fa_amt;
    new_references.fls_cert_amt                      := x_fls_cert_amt;
    new_references.flu_cert_amt                      := x_flu_cert_amt;
    new_references.flp_cert_amt                      := x_flp_cert_amt;
    new_references.sch_cert_date                     := x_sch_cert_date;
    new_references.alt_cert_amt                      := x_alt_cert_amt;
    new_references.alt_appl_ver_code                 := x_alt_appl_ver_code;
    new_references.duns_school_id                    := x_duns_school_id;
    new_references.lender_id                         := x_lender_id;
    new_references.fls_approved_amt                  := x_fls_approved_amt;
    new_references.flu_approved_amt                  := x_flu_approved_amt;
    new_references.flp_approved_amt                  := x_flp_approved_amt;
    new_references.alt_approved_amt                  := x_alt_approved_amt;
    new_references.duns_lender_id                    := x_duns_lender_id;
    new_references.guarantor_id                      := x_guarantor_id;
    new_references.fed_appl_form_code                := x_fed_appl_form_code;
    new_references.duns_guarnt_id                    := x_duns_guarnt_id;
    new_references.lend_blkt_guarnt_ind              := x_lend_blkt_guarnt_ind;
    new_references.lend_blkt_guarnt_appr_date        := x_lend_blkt_guarnt_appr_date;
    new_references.guarnt_adj_ind                    := x_guarnt_adj_ind;
    new_references.guarantee_date                    := x_guarantee_date;
    new_references.guarantee_amt                     := x_guarantee_amt;
    new_references.req_serial_loan_code              := x_req_serial_loan_code;
    new_references.borw_confirm_ind                  := x_borw_confirm_ind;
    new_references.b_license_state                   := x_b_license_state;
    new_references.b_license_number                  := x_b_license_number;
    new_references.b_ref_code                        := x_b_ref_code;
    new_references.pnote_delivery_code               := x_pnote_delivery_code;
    new_references.b_foreign_postal_code             := x_b_foreign_postal_code;
    new_references.lend_non_ed_brc_id                := x_lend_non_ed_brc_id;
    new_references.last_resort_lender                := x_last_resort_lender;
    new_references.resp_to_orig_code                 := x_resp_to_orig_code;
    new_references.err_mesg_1                        := x_err_mesg_1;
    new_references.err_mesg_2                        := x_err_mesg_2;
    new_references.err_mesg_3                        := x_err_mesg_3;
    new_references.err_mesg_4                        := x_err_mesg_4;
    new_references.err_mesg_5                        := x_err_mesg_5;
    new_references.guarnt_amt_redn_code              := x_guarnt_amt_redn_code;
    new_references.tot_outstd_stafford               := x_tot_outstd_stafford;
    new_references.tot_outstd_plus                   := x_tot_outstd_plus;
    new_references.b_permt_addr_chg_date             := x_b_permt_addr_chg_date;
    new_references.alt_prog_type_code                := x_alt_prog_type_code;
    new_references.alt_borw_tot_debt                 := x_alt_borw_tot_debt;
    new_references.act_interest_rate                 := x_act_interest_rate;
    new_references.prc_type_code                     := x_prc_type_code;
    new_references.service_type_code                 := x_service_type_code;
    new_references.rev_notice_of_guarnt              := x_rev_notice_of_guarnt;
    new_references.sch_refund_amt                    := x_sch_refund_amt;
    new_references.sch_refund_date                   := x_sch_refund_date;
    new_references.guarnt_status_code                := x_guarnt_status_code;
    new_references.lender_status_code                := x_lender_status_code;
    new_references.pnote_status_code                 := x_pnote_status_code;
    new_references.credit_status_code                := x_credit_status_code;
    new_references.guarnt_status_date                := x_guarnt_status_date;
    new_references.lender_status_date                := x_lender_status_date;
    new_references.pnote_status_date                 := x_pnote_status_date;
    new_references.credit_status_date                := x_credit_status_date;
    new_references.act_serial_loan_code              := x_act_serial_loan_code;
    new_references.amt_avail_for_reinst              := x_amt_avail_for_reinst;
    new_references.sch_non_ed_brc_id                 := x_sch_non_ed_brc_id;
    new_references.uniq_layout_vend_code             := x_uniq_layout_vend_code;
    new_references.uniq_layout_ident_code            := x_uniq_layout_ident_code;
    new_references.resp_record_status                := x_resp_record_status;

    new_references.mpn_confirm_ind                   := x_mpn_confirm_ind;
    new_references.lender_use_txt                    := x_lender_use_txt;
    new_references.guarantor_use_txt                 := x_guarantor_use_txt;
    new_references.appl_loan_phase_code              := x_appl_loan_phase_code;
    new_references.appl_loan_phase_code_chg          := x_appl_loan_phase_code_chg;
    new_references.cl_rec_status                     := x_cl_rec_status;
    new_references.cl_rec_status_last_update         := x_cl_rec_status_last_update;
    new_references.lend_apprv_denied_code            := x_lend_apprv_denied_code;
    new_references.lend_apprv_denied_date            := x_lend_apprv_denied_date;
    new_references.cl_version_code                   := x_cl_version_code;
    new_references.school_use_txt                    := x_school_use_txt;

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
    new_references.borr_sign_ind                     := x_borr_sign_ind;
    new_references.stud_sign_ind                     := x_stud_sign_ind;
    new_references.b_alien_reg_num_txt               := x_b_alien_reg_num_txt;
    new_references.esign_src_typ_cd                  := x_esign_src_typ_cd;
  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.cbth_id = new_references.cbth_id)) OR
        ((new_references.cbth_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_batch_pkg.get_pk_for_validation (
                new_references.cbth_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_sl_cl_resp_r4_pkg.get_fk_igf_sl_cl_resp_r1 (
      old_references.clrp1_id
    );

    igf_sl_cl_resp_r8_pkg.get_fk_igf_sl_cl_resp_r1 (
      old_references.clrp1_id
    );

    igf_sl_cl_resp_r2_dtls_pkg.get_fk_igf_sl_cl_resp_r1 (
      old_references.clrp1_id
    );

    igf_sl_cl_resp_r3_dtls_pkg.get_fk_igf_sl_cl_resp_r1 (
      old_references.clrp1_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_clrp1_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r1_all
      WHERE    clrp1_id = x_clrp1_id
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


  PROCEDURE get_fk_igf_sl_cl_batch (
    x_cbth_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r1_all
      WHERE   ((cbth_id = x_cbth_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLRP1_CBTH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_batch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_cbth_id                           IN     NUMBER      DEFAULT NULL,
    x_rec_code                          IN     VARCHAR2    DEFAULT NULL,
    x_rec_type_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_b_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_b_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_b_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_b_ssn                             IN     NUMBER      DEFAULT NULL,
    x_b_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_b_permt_zip                       IN     NUMBER      DEFAULT NULL,
    x_b_permt_zip_suffix                IN     NUMBER      DEFAULT NULL,
    x_b_permt_phone                     IN     VARCHAR2    DEFAULT NULL,
    x_b_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_cl_loan_type                      IN     VARCHAR2    DEFAULT NULL,
    x_req_loan_amt                      IN     NUMBER      DEFAULT NULL,
    x_defer_req_code                    IN     VARCHAR2    DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_eft_auth_code                     IN     VARCHAR2    DEFAULT NULL,
    x_b_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_b_signature_date                  IN     DATE        DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_cl_seq_number                     IN     NUMBER      DEFAULT NULL,
    x_b_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_b_state_of_legal_res              IN     VARCHAR2    DEFAULT NULL,
    x_b_legal_res_date                  IN     DATE        DEFAULT NULL,
    x_b_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_b_outstd_loan_code                IN     VARCHAR2    DEFAULT NULL,
    x_b_indicator_code                  IN     VARCHAR2    DEFAULT NULL,
    x_s_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_s_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_s_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_s_ssn                             IN     NUMBER      DEFAULT NULL,
    x_s_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_s_citizenship_status              IN     VARCHAR2    DEFAULT NULL,
    x_s_default_code                    IN     VARCHAR2    DEFAULT NULL,
    x_s_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_school_id                         IN     NUMBER      DEFAULT NULL,
    x_loan_per_begin_date               IN     DATE        DEFAULT NULL,
    x_loan_per_end_date                 IN     DATE        DEFAULT NULL,
    x_grade_level_code                  IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_code                   IN     VARCHAR2    DEFAULT NULL,
    x_anticip_compl_date                IN     DATE        DEFAULT NULL,
    x_coa_amt                           IN     NUMBER      DEFAULT NULL,
    x_efc_amt                           IN     NUMBER      DEFAULT NULL,
    x_est_fa_amt                        IN     NUMBER      DEFAULT NULL,
    x_fls_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_flu_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_flp_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_sch_cert_date                     IN     DATE        DEFAULT NULL,
    x_alt_cert_amt                      IN     NUMBER      DEFAULT NULL,
    x_alt_appl_ver_code                 IN     NUMBER      DEFAULT NULL,
    x_duns_school_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_fls_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_flu_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_flp_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_alt_approved_amt                  IN     NUMBER      DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_fed_appl_form_code                IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2    DEFAULT NULL,
    x_lend_blkt_guarnt_appr_date        IN     DATE        DEFAULT NULL,
    x_guarnt_adj_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantee_date                    IN     DATE        DEFAULT NULL,
    x_guarantee_amt                     IN     NUMBER      DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_borw_confirm_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_b_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_b_license_number                  IN     VARCHAR2    DEFAULT NULL,
    x_b_ref_code                        IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_b_foreign_postal_code             IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_last_resort_lender                IN     VARCHAR2    DEFAULT NULL,
    x_resp_to_orig_code                 IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_1                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_2                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_3                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_4                        IN     VARCHAR2    DEFAULT NULL,
    x_err_mesg_5                        IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_amt_redn_code              IN     VARCHAR2    DEFAULT NULL,
    x_tot_outstd_stafford               IN     NUMBER      DEFAULT NULL,
    x_tot_outstd_plus                   IN     NUMBER      DEFAULT NULL,
    x_b_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_alt_prog_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_alt_borw_tot_debt                 IN     NUMBER      DEFAULT NULL,
    x_act_interest_rate                 IN     NUMBER      DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_service_type_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rev_notice_of_guarnt              IN     VARCHAR2    DEFAULT NULL,
    x_sch_refund_amt                    IN     NUMBER      DEFAULT NULL,
    x_sch_refund_date                   IN     DATE        DEFAULT NULL,
    x_guarnt_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_lender_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status_code                 IN     VARCHAR2    DEFAULT NULL,
    x_credit_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_date                IN     DATE        DEFAULT NULL,
    x_lender_status_date                IN     DATE        DEFAULT NULL,
    x_pnote_status_date                 IN     DATE        DEFAULT NULL,
    x_credit_status_date                IN     DATE        DEFAULT NULL,
    x_act_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_amt_avail_for_reinst              IN     NUMBER      DEFAULT NULL,
    x_sch_non_ed_brc_id                 IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_vend_code             IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_ident_code            IN     VARCHAR2    DEFAULT NULL,
    x_resp_record_status                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_borr_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_stud_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_borr_credit_auth_code             IN     VARCHAR2    DEFAULT NULL,
    x_mpn_confirm_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_lender_use_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_use_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code              IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code_chg          IN     DATE        DEFAULT NULL,
    x_cl_rec_status                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status_last_update         IN     DATE        DEFAULT NULL,
    x_lend_apprv_denied_code            IN     VARCHAR2    DEFAULT NULL,
    x_lend_apprv_denied_date            IN     DATE        DEFAULT NULL,
    x_cl_version_code                   IN     VARCHAR2    DEFAULT NULL,
    x_school_use_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_b_alien_reg_num_txt               IN     VARCHAR2    DEFAULT NULL,
    x_esign_src_typ_cd                  IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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
      x_clrp1_id,
      x_cbth_id,
      x_rec_code,
      x_rec_type_ind,
      x_b_last_name,
      x_b_first_name,
      x_b_middle_name,
      x_b_ssn,
      x_b_permt_addr1,
      x_b_permt_addr2,
      x_b_permt_city,
      x_b_permt_state,
      x_b_permt_zip,
      x_b_permt_zip_suffix,
      x_b_permt_phone,
      x_b_date_of_birth,
      x_cl_loan_type,
      x_req_loan_amt,
      x_defer_req_code,
      x_borw_interest_ind,
      x_eft_auth_code,
      x_b_signature_code,
      x_b_signature_date,
      x_loan_number,
      x_cl_seq_number,
      x_b_citizenship_status,
      x_b_state_of_legal_res,
      x_b_legal_res_date,
      x_b_default_status,
      x_b_outstd_loan_code,
      x_b_indicator_code,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_name,
      x_s_ssn,
      x_s_date_of_birth,
      x_s_citizenship_status,
      x_s_default_code,
      x_s_signature_code,
      x_school_id,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_coa_amt,
      x_efc_amt,
      x_est_fa_amt,
      x_fls_cert_amt,
      x_flu_cert_amt,
      x_flp_cert_amt,
      x_sch_cert_date,
      x_alt_cert_amt,
      x_alt_appl_ver_code,
      x_duns_school_id,
      x_lender_id,
      x_fls_approved_amt,
      x_flu_approved_amt,
      x_flp_approved_amt,
      x_alt_approved_amt,
      x_duns_lender_id,
      x_guarantor_id,
      x_fed_appl_form_code,
      x_duns_guarnt_id,
      x_lend_blkt_guarnt_ind,
      x_lend_blkt_guarnt_appr_date,
      x_guarnt_adj_ind,
      x_guarantee_date,
      x_guarantee_amt,
      x_req_serial_loan_code,
      x_borw_confirm_ind,
      x_b_license_state,
      x_b_license_number,
      x_b_ref_code,
      x_pnote_delivery_code,
      x_b_foreign_postal_code,
      x_lend_non_ed_brc_id,
      x_last_resort_lender,
      x_resp_to_orig_code,
      x_err_mesg_1,
      x_err_mesg_2,
      x_err_mesg_3,
      x_err_mesg_4,
      x_err_mesg_5,
      x_guarnt_amt_redn_code,
      x_tot_outstd_stafford,
      x_tot_outstd_plus,
      x_b_permt_addr_chg_date,
      x_alt_prog_type_code,
      x_alt_borw_tot_debt,
      x_act_interest_rate,
      x_prc_type_code,
      x_service_type_code,
      x_rev_notice_of_guarnt,
      x_sch_refund_amt,
      x_sch_refund_date,
      x_guarnt_status_code,
      x_lender_status_code,
      x_pnote_status_code,
      x_credit_status_code,
      x_guarnt_status_date,
      x_lender_status_date,
      x_pnote_status_date,
      x_credit_status_date,
      x_act_serial_loan_code,
      x_amt_avail_for_reinst,
      x_sch_non_ed_brc_id,
      x_uniq_layout_vend_code,
      x_uniq_layout_ident_code,
      x_resp_record_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_borr_sign_ind,
      x_stud_sign_ind,
      x_borr_credit_auth_code,
      x_mpn_confirm_ind,
      x_lender_use_txt,
      x_guarantor_use_txt,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_cl_rec_status,
      x_cl_rec_status_last_update,
      x_lend_apprv_denied_code,
      x_lend_apprv_denied_date,
      x_cl_version_code,
      x_school_use_txt,
      x_b_alien_reg_num_txt,
      x_esign_src_typ_cd
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clrp1_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.clrp1_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN OUT NOCOPY NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_rec_code                          IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     NUMBER,
    x_b_permt_addr1                     IN     VARCHAR2,
    x_b_permt_addr2                     IN     VARCHAR2,
    x_b_permt_city                      IN     VARCHAR2,
    x_b_permt_state                     IN     VARCHAR2,
    x_b_permt_zip                       IN     NUMBER,
    x_b_permt_zip_suffix                IN     NUMBER,
    x_b_permt_phone                     IN     VARCHAR2,
    x_b_date_of_birth                   IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_req_loan_amt                      IN     NUMBER,
    x_defer_req_code                    IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_eft_auth_code                     IN     VARCHAR2,
    x_b_signature_code                  IN     VARCHAR2,
    x_b_signature_date                  IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_citizenship_status              IN     VARCHAR2,
    x_b_state_of_legal_res              IN     VARCHAR2,
    x_b_legal_res_date                  IN     DATE,
    x_b_default_status                  IN     VARCHAR2,
    x_b_outstd_loan_code                IN     VARCHAR2,
    x_b_indicator_code                  IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_ssn                             IN     NUMBER,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_default_code                    IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_coa_amt                           IN     NUMBER,
    x_efc_amt                           IN     NUMBER,
    x_est_fa_amt                        IN     NUMBER,
    x_fls_cert_amt                      IN     NUMBER,
    x_flu_cert_amt                      IN     NUMBER,
    x_flp_cert_amt                      IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_alt_cert_amt                      IN     NUMBER,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_duns_school_id                    IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_fed_appl_form_code                IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2,
    x_lend_blkt_guarnt_appr_date        IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_b_license_state                   IN     VARCHAR2,
    x_b_license_number                  IN     VARCHAR2,
    x_b_ref_code                        IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_b_foreign_postal_code             IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_last_resort_lender                IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_err_mesg_1                        IN     VARCHAR2,
    x_err_mesg_2                        IN     VARCHAR2,
    x_err_mesg_3                        IN     VARCHAR2,
    x_err_mesg_4                        IN     VARCHAR2,
    x_err_mesg_5                        IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_b_permt_addr_chg_date             IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_prc_type_code                     IN     VARCHAR2,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_guarnt_status_code                IN     VARCHAR2,
    x_lender_status_code                IN     VARCHAR2,
    x_pnote_status_code                 IN     VARCHAR2,
    x_credit_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lender_status_date                IN     DATE,
    x_pnote_status_date                 IN     DATE,
    x_credit_status_date                IN     DATE,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_amt_avail_for_reinst              IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_resp_record_status                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_mpn_confirm_ind                   IN     VARCHAR2 ,
    x_lender_use_txt                    IN     VARCHAR2 ,
    x_guarantor_use_txt                 IN     VARCHAR2 ,
    x_appl_loan_phase_code              IN     VARCHAR2 ,
    x_appl_loan_phase_code_chg          IN     DATE     ,
    x_cl_rec_status                     IN     VARCHAR2 ,
    x_cl_rec_status_last_update         IN     DATE     ,
    x_lend_apprv_denied_code            IN     VARCHAR2 ,
    x_lend_apprv_denied_date            IN     DATE     ,
    x_cl_version_code                   IN     VARCHAR2 ,
    x_school_use_txt                    IN     VARCHAR2 ,
    x_b_alien_reg_num_txt               IN     VARCHAR2 ,
    x_esign_src_typ_cd                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r1_all
      WHERE    clrp1_id                          = x_clrp1_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_sl_cl_resp_r1_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_sl_cl_resp_r1_s.nextval
      INTO x_clrp1_id
      FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clrp1_id                          => x_clrp1_id,
      x_cbth_id                           => x_cbth_id,
      x_rec_code                          => x_rec_code,
      x_rec_type_ind                      => x_rec_type_ind,
      x_b_last_name                       => x_b_last_name,
      x_b_first_name                      => x_b_first_name,
      x_b_middle_name                     => x_b_middle_name,
      x_b_ssn                             => x_b_ssn,
      x_b_permt_addr1                     => x_b_permt_addr1,
      x_b_permt_addr2                     => x_b_permt_addr2,
      x_b_permt_city                      => x_b_permt_city,
      x_b_permt_state                     => x_b_permt_state,
      x_b_permt_zip                       => x_b_permt_zip,
      x_b_permt_zip_suffix                => x_b_permt_zip_suffix,
      x_b_permt_phone                     => x_b_permt_phone,
      x_b_date_of_birth                   => x_b_date_of_birth,
      x_cl_loan_type                      => x_cl_loan_type,
      x_req_loan_amt                      => x_req_loan_amt,
      x_defer_req_code                    => x_defer_req_code,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_eft_auth_code                     => x_eft_auth_code,
      x_b_signature_code                  => x_b_signature_code,
      x_b_signature_date                  => x_b_signature_date,
      x_loan_number                       => x_loan_number,
      x_cl_seq_number                     => x_cl_seq_number,
      x_b_citizenship_status              => x_b_citizenship_status,
      x_b_state_of_legal_res              => x_b_state_of_legal_res,
      x_b_legal_res_date                  => x_b_legal_res_date,
      x_b_default_status                  => x_b_default_status,
      x_b_outstd_loan_code                => x_b_outstd_loan_code,
      x_b_indicator_code                  => x_b_indicator_code,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_ssn                             => x_s_ssn,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_default_code                    => x_s_default_code,
      x_s_signature_code                  => x_s_signature_code,
      x_school_id                         => x_school_id,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_coa_amt                           => x_coa_amt,
      x_efc_amt                           => x_efc_amt,
      x_est_fa_amt                        => x_est_fa_amt,
      x_fls_cert_amt                      => x_fls_cert_amt,
      x_flu_cert_amt                      => x_flu_cert_amt,
      x_flp_cert_amt                      => x_flp_cert_amt,
      x_sch_cert_date                     => x_sch_cert_date,
      x_alt_cert_amt                      => x_alt_cert_amt,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_duns_school_id                    => x_duns_school_id,
      x_lender_id                         => x_lender_id,
      x_fls_approved_amt                  => x_fls_approved_amt,
      x_flu_approved_amt                  => x_flu_approved_amt,
      x_flp_approved_amt                  => x_flp_approved_amt,
      x_alt_approved_amt                  => x_alt_approved_amt,
      x_duns_lender_id                    => x_duns_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_fed_appl_form_code                => x_fed_appl_form_code,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_lend_blkt_guarnt_ind              => x_lend_blkt_guarnt_ind,
      x_lend_blkt_guarnt_appr_date        => x_lend_blkt_guarnt_appr_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_guarantee_date                    => x_guarantee_date,
      x_guarantee_amt                     => x_guarantee_amt,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_b_license_state                   => x_b_license_state,
      x_b_license_number                  => x_b_license_number,
      x_b_ref_code                        => x_b_ref_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_b_foreign_postal_code             => x_b_foreign_postal_code,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_last_resort_lender                => x_last_resort_lender,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_err_mesg_1                        => x_err_mesg_1,
      x_err_mesg_2                        => x_err_mesg_2,
      x_err_mesg_3                        => x_err_mesg_3,
      x_err_mesg_4                        => x_err_mesg_4,
      x_err_mesg_5                        => x_err_mesg_5,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_tot_outstd_stafford               => x_tot_outstd_stafford,
      x_tot_outstd_plus                   => x_tot_outstd_plus,
      x_b_permt_addr_chg_date             => x_b_permt_addr_chg_date,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_borw_tot_debt                 => x_alt_borw_tot_debt,
      x_act_interest_rate                 => x_act_interest_rate,
      x_prc_type_code                     => x_prc_type_code,
      x_service_type_code                 => x_service_type_code,
      x_rev_notice_of_guarnt              => x_rev_notice_of_guarnt,
      x_sch_refund_amt                    => x_sch_refund_amt,
      x_sch_refund_date                   => x_sch_refund_date,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_lender_status_code                => x_lender_status_code,
      x_pnote_status_code                 => x_pnote_status_code,
      x_credit_status_code                => x_credit_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lender_status_date                => x_lender_status_date,
      x_pnote_status_date                 => x_pnote_status_date,
      x_credit_status_date                => x_credit_status_date,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_amt_avail_for_reinst              => x_amt_avail_for_reinst,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_uniq_layout_vend_code             => x_uniq_layout_vend_code,
      x_uniq_layout_ident_code            => x_uniq_layout_ident_code,
      x_resp_record_status                => x_resp_record_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_borr_sign_ind                     => x_borr_sign_ind,
      x_stud_sign_ind                     => x_stud_sign_ind,
      x_borr_credit_auth_code             => x_borr_credit_auth_code,
      x_mpn_confirm_ind                   => x_mpn_confirm_ind,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_cl_version_code                   => x_cl_version_code,
      x_school_use_txt                    => x_school_use_txt,
      x_b_alien_reg_num_txt               => x_b_alien_reg_num_txt,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd
    );

    INSERT INTO igf_sl_cl_resp_r1_all (
      clrp1_id,
      cbth_id,
      rec_code,
      rec_type_ind,
      b_last_name,
      b_first_name,
      b_middle_name,
      b_ssn,
      b_permt_addr1,
      b_permt_addr2,
      b_permt_city,
      b_permt_state,
      b_permt_zip,
      b_permt_zip_suffix,
      b_permt_phone,
      b_date_of_birth,
      cl_loan_type,
      req_loan_amt,
      defer_req_code,
      borw_interest_ind,
      eft_auth_code,
      b_signature_code,
      b_signature_date,
      loan_number,
      cl_seq_number,
      b_citizenship_status,
      b_state_of_legal_res,
      b_legal_res_date,
      b_default_status,
      b_outstd_loan_code,
      b_indicator_code,
      s_last_name,
      s_first_name,
      s_middle_name,
      s_ssn,
      s_date_of_birth,
      s_citizenship_status,
      s_default_code,
      s_signature_code,
      school_id,
      loan_per_begin_date,
      loan_per_end_date,
      grade_level_code,
      enrollment_code,
      anticip_compl_date,
      coa_amt,
      efc_amt,
      est_fa_amt,
      fls_cert_amt,
      flu_cert_amt,
      flp_cert_amt,
      sch_cert_date,
      alt_cert_amt,
      alt_appl_ver_code,
      duns_school_id,
      lender_id,
      fls_approved_amt,
      flu_approved_amt,
      flp_approved_amt,
      alt_approved_amt,
      duns_lender_id,
      guarantor_id,
      fed_appl_form_code,
      duns_guarnt_id,
      lend_blkt_guarnt_ind,
      lend_blkt_guarnt_appr_date,
      guarnt_adj_ind,
      guarantee_date,
      guarantee_amt,
      req_serial_loan_code,
      borw_confirm_ind,
      b_license_state,
      b_license_number,
      b_ref_code,
      pnote_delivery_code,
      b_foreign_postal_code,
      lend_non_ed_brc_id,
      last_resort_lender,
      resp_to_orig_code,
      err_mesg_1,
      err_mesg_2,
      err_mesg_3,
      err_mesg_4,
      err_mesg_5,
      guarnt_amt_redn_code,
      tot_outstd_stafford,
      tot_outstd_plus,
      b_permt_addr_chg_date,
      alt_prog_type_code,
      alt_borw_tot_debt,
      act_interest_rate,
      prc_type_code,
      service_type_code,
      rev_notice_of_guarnt,
      sch_refund_amt,
      sch_refund_date,
      guarnt_status_code,
      lender_status_code,
      pnote_status_code,
      credit_status_code,
      guarnt_status_date,
      lender_status_date,
      pnote_status_date,
      credit_status_date,
      act_serial_loan_code,
      amt_avail_for_reinst,
      sch_non_ed_brc_id,
      uniq_layout_vend_code,
      uniq_layout_ident_code,
      resp_record_status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      borr_sign_ind,
      stud_sign_ind,
      borr_credit_auth_code,
      mpn_confirm_ind,
      lender_use_txt ,
      guarantor_use_txt,
      appl_loan_phase_code,
      appl_loan_phase_code_chg,
      cl_rec_status ,
      cl_rec_status_last_update,
      lend_apprv_denied_code ,
      lend_apprv_denied_date ,
      cl_version_code ,
      school_use_txt,
      b_alien_reg_num_txt,
      esign_src_typ_cd

    ) VALUES (
      new_references.clrp1_id,
      new_references.cbth_id,
      new_references.rec_code,
      new_references.rec_type_ind,
      new_references.b_last_name,
      new_references.b_first_name,
      new_references.b_middle_name,
      new_references.b_ssn,
      new_references.b_permt_addr1,
      new_references.b_permt_addr2,
      new_references.b_permt_city,
      new_references.b_permt_state,
      new_references.b_permt_zip,
      new_references.b_permt_zip_suffix,
      new_references.b_permt_phone,
      new_references.b_date_of_birth,
      new_references.cl_loan_type,
      new_references.req_loan_amt,
      new_references.defer_req_code,
      new_references.borw_interest_ind,
      new_references.eft_auth_code,
      new_references.b_signature_code,
      new_references.b_signature_date,
      new_references.loan_number,
      new_references.cl_seq_number,
      new_references.b_citizenship_status,
      new_references.b_state_of_legal_res,
      new_references.b_legal_res_date,
      new_references.b_default_status,
      new_references.b_outstd_loan_code,
      new_references.b_indicator_code,
      new_references.s_last_name,
      new_references.s_first_name,
      new_references.s_middle_name,
      new_references.s_ssn,
      new_references.s_date_of_birth,
      new_references.s_citizenship_status,
      new_references.s_default_code,
      new_references.s_signature_code,
      new_references.school_id,
      new_references.loan_per_begin_date,
      new_references.loan_per_end_date,
      new_references.grade_level_code,
      new_references.enrollment_code,
      new_references.anticip_compl_date,
      new_references.coa_amt,
      new_references.efc_amt,
      new_references.est_fa_amt,
      new_references.fls_cert_amt,
      new_references.flu_cert_amt,
      new_references.flp_cert_amt,
      new_references.sch_cert_date,
      new_references.alt_cert_amt,
      new_references.alt_appl_ver_code,
      new_references.duns_school_id,
      new_references.lender_id,
      new_references.fls_approved_amt,
      new_references.flu_approved_amt,
      new_references.flp_approved_amt,
      new_references.alt_approved_amt,
      new_references.duns_lender_id,
      new_references.guarantor_id,
      new_references.fed_appl_form_code,
      new_references.duns_guarnt_id,
      new_references.lend_blkt_guarnt_ind,
      new_references.lend_blkt_guarnt_appr_date,
      new_references.guarnt_adj_ind,
      new_references.guarantee_date,
      new_references.guarantee_amt,
      new_references.req_serial_loan_code,
      new_references.borw_confirm_ind,
      new_references.b_license_state,
      new_references.b_license_number,
      new_references.b_ref_code,
      new_references.pnote_delivery_code,
      new_references.b_foreign_postal_code,
      new_references.lend_non_ed_brc_id,
      new_references.last_resort_lender,
      new_references.resp_to_orig_code,
      new_references.err_mesg_1,
      new_references.err_mesg_2,
      new_references.err_mesg_3,
      new_references.err_mesg_4,
      new_references.err_mesg_5,
      new_references.guarnt_amt_redn_code,
      new_references.tot_outstd_stafford,
      new_references.tot_outstd_plus,
      new_references.b_permt_addr_chg_date,
      new_references.alt_prog_type_code,
      new_references.alt_borw_tot_debt,
      new_references.act_interest_rate,
      new_references.prc_type_code,
      new_references.service_type_code,
      new_references.rev_notice_of_guarnt,
      new_references.sch_refund_amt,
      new_references.sch_refund_date,
      new_references.guarnt_status_code,
      new_references.lender_status_code,
      new_references.pnote_status_code,
      new_references.credit_status_code,
      new_references.guarnt_status_date,
      new_references.lender_status_date,
      new_references.pnote_status_date,
      new_references.credit_status_date,
      new_references.act_serial_loan_code,
      new_references.amt_avail_for_reinst,
      new_references.sch_non_ed_brc_id,
      new_references.uniq_layout_vend_code,
      new_references.uniq_layout_ident_code,
      new_references.resp_record_status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
      new_references.borr_sign_ind,
      new_references.stud_sign_ind,
      new_references.borr_credit_auth_code,
      new_references.mpn_confirm_ind,
      new_references.lender_use_txt ,
      new_references.guarantor_use_txt,
      new_references.appl_loan_phase_code,
      new_references.appl_loan_phase_code_chg,
      new_references.cl_rec_status ,
      new_references.cl_rec_status_last_update,
      new_references.lend_apprv_denied_code ,
      new_references.lend_apprv_denied_date ,
      new_references.cl_version_code ,
      new_references.school_use_txt ,
      new_references.b_alien_reg_num_txt ,
      new_references.esign_src_typ_cd
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_rec_code                          IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     NUMBER,
    x_b_permt_addr1                     IN     VARCHAR2,
    x_b_permt_addr2                     IN     VARCHAR2,
    x_b_permt_city                      IN     VARCHAR2,
    x_b_permt_state                     IN     VARCHAR2,
    x_b_permt_zip                       IN     NUMBER,
    x_b_permt_zip_suffix                IN     NUMBER,
    x_b_permt_phone                     IN     VARCHAR2,
    x_b_date_of_birth                   IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_req_loan_amt                      IN     NUMBER,
    x_defer_req_code                    IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_eft_auth_code                     IN     VARCHAR2,
    x_b_signature_code                  IN     VARCHAR2,
    x_b_signature_date                  IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_citizenship_status              IN     VARCHAR2,
    x_b_state_of_legal_res              IN     VARCHAR2,
    x_b_legal_res_date                  IN     DATE,
    x_b_default_status                  IN     VARCHAR2,
    x_b_outstd_loan_code                IN     VARCHAR2,
    x_b_indicator_code                  IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_ssn                             IN     NUMBER,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_default_code                    IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_coa_amt                           IN     NUMBER,
    x_efc_amt                           IN     NUMBER,
    x_est_fa_amt                        IN     NUMBER,
    x_fls_cert_amt                      IN     NUMBER,
    x_flu_cert_amt                      IN     NUMBER,
    x_flp_cert_amt                      IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_alt_cert_amt                      IN     NUMBER,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_duns_school_id                    IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_fed_appl_form_code                IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2,
    x_lend_blkt_guarnt_appr_date        IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_b_license_state                   IN     VARCHAR2,
    x_b_license_number                  IN     VARCHAR2,
    x_b_ref_code                        IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_b_foreign_postal_code             IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_last_resort_lender                IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_err_mesg_1                        IN     VARCHAR2,
    x_err_mesg_2                        IN     VARCHAR2,
    x_err_mesg_3                        IN     VARCHAR2,
    x_err_mesg_4                        IN     VARCHAR2,
    x_err_mesg_5                        IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_b_permt_addr_chg_date             IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_prc_type_code                     IN     VARCHAR2,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_guarnt_status_code                IN     VARCHAR2,
    x_lender_status_code                IN     VARCHAR2,
    x_pnote_status_code                 IN     VARCHAR2,
    x_credit_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lender_status_date                IN     DATE,
    x_pnote_status_date                 IN     DATE,
    x_credit_status_date                IN     DATE,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_amt_avail_for_reinst              IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_resp_record_status                IN     VARCHAR2,
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_mpn_confirm_ind                   IN     VARCHAR2 ,
    x_lender_use_txt                    IN     VARCHAR2 ,
    x_guarantor_use_txt                 IN     VARCHAR2 ,
    x_appl_loan_phase_code              IN     VARCHAR2 ,
    x_appl_loan_phase_code_chg          IN     DATE     ,
    x_cl_rec_status                     IN     VARCHAR2 ,
    x_cl_rec_status_last_update         IN     DATE     ,
    x_lend_apprv_denied_code            IN     VARCHAR2 ,
    x_lend_apprv_denied_date            IN     DATE     ,
    x_cl_version_code                   IN     VARCHAR2 ,
    x_school_use_txt                    IN     VARCHAR2 ,
    x_b_alien_reg_num_txt               IN     VARCHAR2 ,
    x_esign_src_typ_cd                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        cbth_id,
        rec_code,
        rec_type_ind,
        b_last_name,
        b_first_name,
        b_middle_name,
        b_ssn,
        b_permt_addr1,
        b_permt_addr2,
        b_permt_city,
        b_permt_state,
        b_permt_zip,
        b_permt_zip_suffix,
        b_permt_phone,
        b_date_of_birth,
        cl_loan_type,
        req_loan_amt,
        defer_req_code,
        borw_interest_ind,
        eft_auth_code,
        b_signature_code,
        b_signature_date,
        loan_number,
        cl_seq_number,
        b_citizenship_status,
        b_state_of_legal_res,
        b_legal_res_date,
        b_default_status,
        b_outstd_loan_code,
        b_indicator_code,
        s_last_name,
        s_first_name,
        s_middle_name,
        s_ssn,
        s_date_of_birth,
        s_citizenship_status,
        s_default_code,
        s_signature_code,
        school_id,
        loan_per_begin_date,
        loan_per_end_date,
        grade_level_code,
        enrollment_code,
        anticip_compl_date,
        coa_amt,
        efc_amt,
        est_fa_amt,
        fls_cert_amt,
        flu_cert_amt,
        flp_cert_amt,
        sch_cert_date,
        alt_cert_amt,
        alt_appl_ver_code,
        duns_school_id,
        lender_id,
        fls_approved_amt,
        flu_approved_amt,
        flp_approved_amt,
        alt_approved_amt,
        duns_lender_id,
        guarantor_id,
        fed_appl_form_code,
        duns_guarnt_id,
        lend_blkt_guarnt_ind,
        lend_blkt_guarnt_appr_date,
        guarnt_adj_ind,
        guarantee_date,
        guarantee_amt,
        req_serial_loan_code,
        borw_confirm_ind,
        b_license_state,
        b_license_number,
        b_ref_code,
        pnote_delivery_code,
        b_foreign_postal_code,
        lend_non_ed_brc_id,
        last_resort_lender,
        resp_to_orig_code,
        err_mesg_1,
        err_mesg_2,
        err_mesg_3,
        err_mesg_4,
        err_mesg_5,
        guarnt_amt_redn_code,
        tot_outstd_stafford,
        tot_outstd_plus,
        b_permt_addr_chg_date,
        alt_prog_type_code,
        alt_borw_tot_debt,
        act_interest_rate,
        prc_type_code,
        service_type_code,
        rev_notice_of_guarnt,
        sch_refund_amt,
        sch_refund_date,
        guarnt_status_code,
        lender_status_code,
        pnote_status_code,
        credit_status_code,
        guarnt_status_date,
        lender_status_date,
        pnote_status_date,
        credit_status_date,
        act_serial_loan_code,
        amt_avail_for_reinst,
        sch_non_ed_brc_id,
        uniq_layout_vend_code,
        uniq_layout_ident_code,
        resp_record_status,
        org_id,
        borr_sign_ind,
        stud_sign_ind,
        borr_credit_auth_code,
        mpn_confirm_ind,
        lender_use_txt,
        guarantor_use_txt,
        appl_loan_phase_code,
        appl_loan_phase_code_chg,
        cl_rec_status,
        cl_rec_status_last_update,
        lend_apprv_denied_code ,
        lend_apprv_denied_date ,
        cl_version_code,
        school_use_txt,
        b_alien_reg_num_txt,
        esign_src_typ_cd

      FROM  igf_sl_cl_resp_r1_all
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
        (tlinfo.cbth_id = x_cbth_id)
        AND (tlinfo.rec_code = x_rec_code)
        AND (tlinfo.rec_type_ind = x_rec_type_ind)
        AND ((tlinfo.b_last_name = x_b_last_name) OR ((tlinfo.b_last_name IS NULL) AND (X_b_last_name IS NULL)))
        AND ((tlinfo.b_first_name = x_b_first_name) OR ((tlinfo.b_first_name IS NULL) AND (X_b_first_name IS NULL)))
        AND ((tlinfo.b_middle_name = x_b_middle_name) OR ((tlinfo.b_middle_name IS NULL) AND (X_b_middle_name IS NULL)))
        AND ((tlinfo.b_ssn = x_b_ssn) OR ((tlinfo.b_ssn IS NULL) AND (X_b_ssn IS NULL)))
        AND ((tlinfo.b_permt_addr1 = x_b_permt_addr1) OR ((tlinfo.b_permt_addr1 IS NULL) AND (X_b_permt_addr1 IS NULL)))
        AND ((tlinfo.b_permt_addr2 = x_b_permt_addr2) OR ((tlinfo.b_permt_addr2 IS NULL) AND (X_b_permt_addr2 IS NULL)))
        AND ((tlinfo.b_permt_city = x_b_permt_city) OR ((tlinfo.b_permt_city IS NULL) AND (X_b_permt_city IS NULL)))
        AND ((tlinfo.b_permt_state = x_b_permt_state) OR ((tlinfo.b_permt_state IS NULL) AND (X_b_permt_state IS NULL)))
        AND ((tlinfo.b_permt_zip = x_b_permt_zip) OR ((tlinfo.b_permt_zip IS NULL) AND (X_b_permt_zip IS NULL)))
        AND ((tlinfo.b_permt_zip_suffix = x_b_permt_zip_suffix) OR ((tlinfo.b_permt_zip_suffix IS NULL) AND (X_b_permt_zip_suffix IS NULL)))
        AND ((tlinfo.b_permt_phone = x_b_permt_phone) OR ((tlinfo.b_permt_phone IS NULL) AND (X_b_permt_phone IS NULL)))
        AND ((tlinfo.b_date_of_birth = x_b_date_of_birth) OR ((tlinfo.b_date_of_birth IS NULL) AND (X_b_date_of_birth IS NULL)))
        AND ((tlinfo.cl_loan_type = x_cl_loan_type) OR ((tlinfo.cl_loan_type IS NULL) AND (X_cl_loan_type IS NULL)))
        AND ((tlinfo.req_loan_amt = x_req_loan_amt) OR ((tlinfo.req_loan_amt IS NULL) AND (X_req_loan_amt IS NULL)))
        AND ((tlinfo.defer_req_code = x_defer_req_code) OR ((tlinfo.defer_req_code IS NULL) AND (X_defer_req_code IS NULL)))
        AND ((tlinfo.borw_interest_ind = x_borw_interest_ind) OR ((tlinfo.borw_interest_ind IS NULL) AND (X_borw_interest_ind IS NULL)))
        AND ((tlinfo.eft_auth_code = x_eft_auth_code) OR ((tlinfo.eft_auth_code IS NULL) AND (X_eft_auth_code IS NULL)))
        AND ((tlinfo.b_signature_code = x_b_signature_code) OR ((tlinfo.b_signature_code IS NULL) AND (X_b_signature_code IS NULL)))
        AND ((tlinfo.b_signature_date = x_b_signature_date) OR ((tlinfo.b_signature_date IS NULL) AND (X_b_signature_date IS NULL)))
        AND ((tlinfo.loan_number = x_loan_number) OR ((tlinfo.loan_number IS NULL) AND (X_loan_number IS NULL)))
        AND ((tlinfo.cl_seq_number = x_cl_seq_number) OR ((tlinfo.cl_seq_number IS NULL) AND (X_cl_seq_number IS NULL)))
        AND ((tlinfo.b_citizenship_status = x_b_citizenship_status) OR ((tlinfo.b_citizenship_status IS NULL) AND (X_b_citizenship_status IS NULL)))
        AND ((tlinfo.b_state_of_legal_res = x_b_state_of_legal_res) OR ((tlinfo.b_state_of_legal_res IS NULL) AND (X_b_state_of_legal_res IS NULL)))
        AND ((tlinfo.b_legal_res_date = x_b_legal_res_date) OR ((tlinfo.b_legal_res_date IS NULL) AND (X_b_legal_res_date IS NULL)))
        AND ((tlinfo.b_default_status = x_b_default_status) OR ((tlinfo.b_default_status IS NULL) AND (X_b_default_status IS NULL)))
        AND ((tlinfo.b_outstd_loan_code = x_b_outstd_loan_code) OR ((tlinfo.b_outstd_loan_code IS NULL) AND (X_b_outstd_loan_code IS NULL)))
        AND ((tlinfo.b_indicator_code = x_b_indicator_code) OR ((tlinfo.b_indicator_code IS NULL) AND (X_b_indicator_code IS NULL)))
        AND ((tlinfo.s_last_name = x_s_last_name) OR ((tlinfo.s_last_name IS NULL) AND (X_s_last_name IS NULL)))
        AND ((tlinfo.s_first_name = x_s_first_name) OR ((tlinfo.s_first_name IS NULL) AND (X_s_first_name IS NULL)))
        AND ((tlinfo.s_middle_name = x_s_middle_name) OR ((tlinfo.s_middle_name IS NULL) AND (X_s_middle_name IS NULL)))
        AND ((tlinfo.s_ssn = x_s_ssn) OR ((tlinfo.s_ssn IS NULL) AND (X_s_ssn IS NULL)))
        AND ((tlinfo.s_date_of_birth = x_s_date_of_birth) OR ((tlinfo.s_date_of_birth IS NULL) AND (X_s_date_of_birth IS NULL)))
        AND ((tlinfo.s_citizenship_status = x_s_citizenship_status) OR ((tlinfo.s_citizenship_status IS NULL) AND (X_s_citizenship_status IS NULL)))
        AND ((tlinfo.s_default_code = x_s_default_code) OR ((tlinfo.s_default_code IS NULL) AND (X_s_default_code IS NULL)))
        AND ((tlinfo.s_signature_code = x_s_signature_code) OR ((tlinfo.s_signature_code IS NULL) AND (X_s_signature_code IS NULL)))
        AND ((tlinfo.school_id = x_school_id) OR ((tlinfo.school_id IS NULL) AND (X_school_id IS NULL)))
        AND ((tlinfo.loan_per_begin_date = x_loan_per_begin_date) OR ((tlinfo.loan_per_begin_date IS NULL) AND (X_loan_per_begin_date IS NULL)))
        AND ((tlinfo.loan_per_end_date = x_loan_per_end_date) OR ((tlinfo.loan_per_end_date IS NULL) AND (X_loan_per_end_date IS NULL)))
        AND ((tlinfo.grade_level_code = x_grade_level_code) OR ((tlinfo.grade_level_code IS NULL) AND (X_grade_level_code IS NULL)))
        AND ((tlinfo.enrollment_code = x_enrollment_code) OR ((tlinfo.enrollment_code IS NULL) AND (X_enrollment_code IS NULL)))
        AND ((tlinfo.anticip_compl_date = x_anticip_compl_date) OR ((tlinfo.anticip_compl_date IS NULL) AND (X_anticip_compl_date IS NULL)))
        AND ((tlinfo.coa_amt = x_coa_amt) OR ((tlinfo.coa_amt IS NULL) AND (X_coa_amt IS NULL)))
        AND ((tlinfo.efc_amt = x_efc_amt) OR ((tlinfo.efc_amt IS NULL) AND (X_efc_amt IS NULL)))
        AND ((tlinfo.est_fa_amt = x_est_fa_amt) OR ((tlinfo.est_fa_amt IS NULL) AND (X_est_fa_amt IS NULL)))
        AND ((tlinfo.fls_cert_amt = x_fls_cert_amt) OR ((tlinfo.fls_cert_amt IS NULL) AND (X_fls_cert_amt IS NULL)))
        AND ((tlinfo.flu_cert_amt = x_flu_cert_amt) OR ((tlinfo.flu_cert_amt IS NULL) AND (X_flu_cert_amt IS NULL)))
        AND ((tlinfo.flp_cert_amt = x_flp_cert_amt) OR ((tlinfo.flp_cert_amt IS NULL) AND (X_flp_cert_amt IS NULL)))
        AND ((tlinfo.sch_cert_date = x_sch_cert_date) OR ((tlinfo.sch_cert_date IS NULL) AND (X_sch_cert_date IS NULL)))
        AND ((tlinfo.alt_cert_amt = x_alt_cert_amt) OR ((tlinfo.alt_cert_amt IS NULL) AND (X_alt_cert_amt IS NULL)))
        AND ((tlinfo.alt_appl_ver_code = x_alt_appl_ver_code) OR ((tlinfo.alt_appl_ver_code IS NULL) AND (X_alt_appl_ver_code IS NULL)))
        AND ((tlinfo.duns_school_id = x_duns_school_id) OR ((tlinfo.duns_school_id IS NULL) AND (X_duns_school_id IS NULL)))
        AND ((tlinfo.lender_id = x_lender_id) OR ((tlinfo.lender_id IS NULL) AND (X_lender_id IS NULL)))
        AND ((tlinfo.fls_approved_amt = x_fls_approved_amt) OR ((tlinfo.fls_approved_amt IS NULL) AND (X_fls_approved_amt IS NULL)))
        AND ((tlinfo.flu_approved_amt = x_flu_approved_amt) OR ((tlinfo.flu_approved_amt IS NULL) AND (X_flu_approved_amt IS NULL)))
        AND ((tlinfo.flp_approved_amt = x_flp_approved_amt) OR ((tlinfo.flp_approved_amt IS NULL) AND (X_flp_approved_amt IS NULL)))
        AND ((tlinfo.alt_approved_amt = x_alt_approved_amt) OR ((tlinfo.alt_approved_amt IS NULL) AND (X_alt_approved_amt IS NULL)))
        AND ((tlinfo.duns_lender_id = x_duns_lender_id) OR ((tlinfo.duns_lender_id IS NULL) AND (X_duns_lender_id IS NULL)))
        AND ((tlinfo.guarantor_id = x_guarantor_id) OR ((tlinfo.guarantor_id IS NULL) AND (X_guarantor_id IS NULL)))
        AND ((tlinfo.fed_appl_form_code = x_fed_appl_form_code) OR ((tlinfo.fed_appl_form_code IS NULL) AND (X_fed_appl_form_code IS NULL)))
        AND ((tlinfo.duns_guarnt_id = x_duns_guarnt_id) OR ((tlinfo.duns_guarnt_id IS NULL) AND (X_duns_guarnt_id IS NULL)))
        AND ((tlinfo.lend_blkt_guarnt_ind = x_lend_blkt_guarnt_ind) OR ((tlinfo.lend_blkt_guarnt_ind IS NULL) AND (X_lend_blkt_guarnt_ind IS NULL)))
        AND ((tlinfo.lend_blkt_guarnt_appr_date = x_lend_blkt_guarnt_appr_date) OR ((tlinfo.lend_blkt_guarnt_appr_date IS NULL) AND (X_lend_blkt_guarnt_appr_date IS NULL)))
        AND ((tlinfo.guarnt_adj_ind = x_guarnt_adj_ind) OR ((tlinfo.guarnt_adj_ind IS NULL) AND (X_guarnt_adj_ind IS NULL)))
        AND ((tlinfo.guarantee_date = x_guarantee_date) OR ((tlinfo.guarantee_date IS NULL) AND (X_guarantee_date IS NULL)))
        AND ((tlinfo.guarantee_amt = x_guarantee_amt) OR ((tlinfo.guarantee_amt IS NULL) AND (X_guarantee_amt IS NULL)))
        AND ((tlinfo.req_serial_loan_code = x_req_serial_loan_code) OR ((tlinfo.req_serial_loan_code IS NULL) AND (X_req_serial_loan_code IS NULL)))
        AND ((tlinfo.borw_confirm_ind = x_borw_confirm_ind) OR ((tlinfo.borw_confirm_ind IS NULL) AND (X_borw_confirm_ind IS NULL)))
        AND ((tlinfo.b_license_state = x_b_license_state) OR ((tlinfo.b_license_state IS NULL) AND (X_b_license_state IS NULL)))
        AND ((tlinfo.b_license_number = x_b_license_number) OR ((tlinfo.b_license_number IS NULL) AND (X_b_license_number IS NULL)))
        AND ((tlinfo.b_ref_code = x_b_ref_code) OR ((tlinfo.b_ref_code IS NULL) AND (X_b_ref_code IS NULL)))
        AND ((tlinfo.pnote_delivery_code = x_pnote_delivery_code) OR ((tlinfo.pnote_delivery_code IS NULL) AND (X_pnote_delivery_code IS NULL)))
        AND ((tlinfo.b_foreign_postal_code = x_b_foreign_postal_code) OR ((tlinfo.b_foreign_postal_code IS NULL) AND (X_b_foreign_postal_code IS NULL)))
        AND ((tlinfo.lend_non_ed_brc_id = x_lend_non_ed_brc_id) OR ((tlinfo.lend_non_ed_brc_id IS NULL) AND (X_lend_non_ed_brc_id IS NULL)))
        AND ((tlinfo.last_resort_lender = x_last_resort_lender) OR ((tlinfo.last_resort_lender IS NULL) AND (X_last_resort_lender IS NULL)))
        AND ((tlinfo.resp_to_orig_code = x_resp_to_orig_code) OR ((tlinfo.resp_to_orig_code IS NULL) AND (X_resp_to_orig_code IS NULL)))
        AND ((tlinfo.err_mesg_1 = x_err_mesg_1) OR ((tlinfo.err_mesg_1 IS NULL) AND (X_err_mesg_1 IS NULL)))
        AND ((tlinfo.err_mesg_2 = x_err_mesg_2) OR ((tlinfo.err_mesg_2 IS NULL) AND (X_err_mesg_2 IS NULL)))
        AND ((tlinfo.err_mesg_3 = x_err_mesg_3) OR ((tlinfo.err_mesg_3 IS NULL) AND (X_err_mesg_3 IS NULL)))
        AND ((tlinfo.err_mesg_4 = x_err_mesg_4) OR ((tlinfo.err_mesg_4 IS NULL) AND (X_err_mesg_4 IS NULL)))
        AND ((tlinfo.err_mesg_5 = x_err_mesg_5) OR ((tlinfo.err_mesg_5 IS NULL) AND (X_err_mesg_5 IS NULL)))
        AND ((tlinfo.guarnt_amt_redn_code = x_guarnt_amt_redn_code) OR ((tlinfo.guarnt_amt_redn_code IS NULL) AND (X_guarnt_amt_redn_code IS NULL)))
        AND ((tlinfo.tot_outstd_stafford = x_tot_outstd_stafford) OR ((tlinfo.tot_outstd_stafford IS NULL) AND (X_tot_outstd_stafford IS NULL)))
        AND ((tlinfo.tot_outstd_plus = x_tot_outstd_plus) OR ((tlinfo.tot_outstd_plus IS NULL) AND (X_tot_outstd_plus IS NULL)))
        AND ((tlinfo.b_permt_addr_chg_date = x_b_permt_addr_chg_date) OR ((tlinfo.b_permt_addr_chg_date IS NULL) AND (X_b_permt_addr_chg_date IS NULL)))
        AND ((tlinfo.alt_prog_type_code = x_alt_prog_type_code) OR ((tlinfo.alt_prog_type_code IS NULL) AND (X_alt_prog_type_code IS NULL)))
        AND ((tlinfo.alt_borw_tot_debt = x_alt_borw_tot_debt) OR ((tlinfo.alt_borw_tot_debt IS NULL) AND (X_alt_borw_tot_debt IS NULL)))
        AND ((tlinfo.act_interest_rate = x_act_interest_rate) OR ((tlinfo.act_interest_rate IS NULL) AND (X_act_interest_rate IS NULL)))
        AND (tlinfo.prc_type_code = x_prc_type_code)
        AND ((tlinfo.service_type_code = x_service_type_code) OR ((tlinfo.service_type_code IS NULL) AND (X_service_type_code IS NULL)))
        AND ((tlinfo.rev_notice_of_guarnt = x_rev_notice_of_guarnt) OR ((tlinfo.rev_notice_of_guarnt IS NULL) AND (X_rev_notice_of_guarnt IS NULL)))
        AND ((tlinfo.sch_refund_amt = x_sch_refund_amt) OR ((tlinfo.sch_refund_amt IS NULL) AND (X_sch_refund_amt IS NULL)))
        AND ((tlinfo.sch_refund_date = x_sch_refund_date) OR ((tlinfo.sch_refund_date IS NULL) AND (X_sch_refund_date IS NULL)))
        AND ((tlinfo.guarnt_status_code = x_guarnt_status_code) OR ((tlinfo.guarnt_status_code IS NULL) AND (X_guarnt_status_code IS NULL)))
        AND ((tlinfo.lender_status_code = x_lender_status_code) OR ((tlinfo.lender_status_code IS NULL) AND (X_lender_status_code IS NULL)))
        AND ((tlinfo.pnote_status_code = x_pnote_status_code) OR ((tlinfo.pnote_status_code IS NULL) AND (X_pnote_status_code IS NULL)))
        AND ((tlinfo.credit_status_code = x_credit_status_code) OR ((tlinfo.credit_status_code IS NULL) AND (X_credit_status_code IS NULL)))
        AND ((tlinfo.guarnt_status_date = x_guarnt_status_date) OR ((tlinfo.guarnt_status_date IS NULL) AND (X_guarnt_status_date IS NULL)))
        AND ((tlinfo.lender_status_date = x_lender_status_date) OR ((tlinfo.lender_status_date IS NULL) AND (X_lender_status_date IS NULL)))
        AND ((tlinfo.pnote_status_date = x_pnote_status_date) OR ((tlinfo.pnote_status_date IS NULL) AND (X_pnote_status_date IS NULL)))
        AND ((tlinfo.credit_status_date = x_credit_status_date) OR ((tlinfo.credit_status_date IS NULL) AND (X_credit_status_date IS NULL)))
        AND ((tlinfo.act_serial_loan_code = x_act_serial_loan_code) OR ((tlinfo.act_serial_loan_code IS NULL) AND (X_act_serial_loan_code IS NULL)))
        AND ((tlinfo.amt_avail_for_reinst = x_amt_avail_for_reinst) OR ((tlinfo.amt_avail_for_reinst IS NULL) AND (X_amt_avail_for_reinst IS NULL)))
        AND ((tlinfo.sch_non_ed_brc_id = x_sch_non_ed_brc_id) OR ((tlinfo.sch_non_ed_brc_id IS NULL) AND (X_sch_non_ed_brc_id IS NULL)))
        AND ((tlinfo.uniq_layout_vend_code = x_uniq_layout_vend_code) OR ((tlinfo.uniq_layout_vend_code IS NULL) AND (X_uniq_layout_vend_code IS NULL)))
        AND ((tlinfo.uniq_layout_ident_code = x_uniq_layout_ident_code) OR ((tlinfo.uniq_layout_ident_code IS NULL) AND (X_uniq_layout_ident_code IS NULL)))
        AND ((tlinfo.resp_record_status = x_resp_record_status) OR ((tlinfo.resp_record_status IS NULL) AND (X_resp_record_status IS NULL)))
        AND ((tlinfo.borr_sign_ind = x_borr_sign_ind) OR ((tlinfo.borr_sign_ind IS NULL) AND (X_borr_sign_ind IS NULL)))
        AND ((tlinfo.stud_sign_ind = x_stud_sign_ind) OR ((tlinfo.stud_sign_ind IS NULL) AND (X_stud_sign_ind IS NULL)))
        AND ((tlinfo.borr_credit_auth_code = x_borr_credit_auth_code) OR ((tlinfo.borr_credit_auth_code IS NULL) AND (X_borr_credit_auth_code IS NULL)))
        AND ((tlinfo.mpn_confirm_ind = x_mpn_confirm_ind) OR ((tlinfo.mpn_confirm_ind IS NULL) AND (X_mpn_confirm_ind IS NULL)))
        AND ((tlinfo.lender_use_txt = x_lender_use_txt) OR ((tlinfo.lender_use_txt IS NULL) AND (X_lender_use_txt IS NULL)))
        AND ((tlinfo.guarantor_use_txt = x_guarantor_use_txt) OR ((tlinfo.guarantor_use_txt IS NULL) AND (X_guarantor_use_txt IS NULL)))
        AND ((tlinfo.appl_loan_phase_code = x_appl_loan_phase_code) OR ((tlinfo.appl_loan_phase_code IS NULL) AND (X_appl_loan_phase_code IS NULL)))
        AND ((tlinfo.appl_loan_phase_code_chg = x_appl_loan_phase_code_chg) OR ((tlinfo.appl_loan_phase_code_chg IS NULL) AND (X_appl_loan_phase_code_chg IS NULL)))
        AND ((tlinfo.cl_rec_status = x_cl_rec_status) OR ((tlinfo.cl_rec_status IS NULL) AND (X_cl_rec_status IS NULL)))
        AND ((tlinfo.cl_rec_status_last_update = x_cl_rec_status_last_update) OR ((tlinfo.cl_rec_status_last_update IS NULL) AND (X_cl_rec_status_last_update IS NULL)))
        AND ((tlinfo.lend_apprv_denied_code = x_lend_apprv_denied_code) OR ((tlinfo.lend_apprv_denied_code IS NULL) AND (X_lend_apprv_denied_code IS NULL)))
        AND ((tlinfo.lend_apprv_denied_date = x_lend_apprv_denied_date) OR ((tlinfo.lend_apprv_denied_date IS NULL) AND (X_lend_apprv_denied_date IS NULL)))
        AND ((tlinfo.cl_version_code = x_cl_version_code) OR ((tlinfo.cl_version_code IS NULL) AND (X_cl_version_code IS NULL)))
        AND ((tlinfo.school_use_txt = x_school_use_txt) OR ((tlinfo.school_use_txt IS NULL) AND (X_school_use_txt IS NULL)))
        AND ((tlinfo.b_alien_reg_num_txt = x_b_alien_reg_num_txt) OR ((tlinfo.b_alien_reg_num_txt IS NULL) AND (X_b_alien_reg_num_txt IS NULL)))
        AND ((tlinfo.esign_src_typ_cd = x_esign_src_typ_cd) OR ((tlinfo.esign_src_typ_cd IS NULL) AND (X_esign_src_typ_cd IS NULL)))
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
    x_clrp1_id                          IN     NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_rec_code                          IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     NUMBER,
    x_b_permt_addr1                     IN     VARCHAR2,
    x_b_permt_addr2                     IN     VARCHAR2,
    x_b_permt_city                      IN     VARCHAR2,
    x_b_permt_state                     IN     VARCHAR2,
    x_b_permt_zip                       IN     NUMBER,
    x_b_permt_zip_suffix                IN     NUMBER,
    x_b_permt_phone                     IN     VARCHAR2,
    x_b_date_of_birth                   IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_req_loan_amt                      IN     NUMBER,
    x_defer_req_code                    IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_eft_auth_code                     IN     VARCHAR2,
    x_b_signature_code                  IN     VARCHAR2,
    x_b_signature_date                  IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_citizenship_status              IN     VARCHAR2,
    x_b_state_of_legal_res              IN     VARCHAR2,
    x_b_legal_res_date                  IN     DATE,
    x_b_default_status                  IN     VARCHAR2,
    x_b_outstd_loan_code                IN     VARCHAR2,
    x_b_indicator_code                  IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_ssn                             IN     NUMBER,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_default_code                    IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_coa_amt                           IN     NUMBER,
    x_efc_amt                           IN     NUMBER,
    x_est_fa_amt                        IN     NUMBER,
    x_fls_cert_amt                      IN     NUMBER,
    x_flu_cert_amt                      IN     NUMBER,
    x_flp_cert_amt                      IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_alt_cert_amt                      IN     NUMBER,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_duns_school_id                    IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_fed_appl_form_code                IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2,
    x_lend_blkt_guarnt_appr_date        IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_b_license_state                   IN     VARCHAR2,
    x_b_license_number                  IN     VARCHAR2,
    x_b_ref_code                        IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_b_foreign_postal_code             IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_last_resort_lender                IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_err_mesg_1                        IN     VARCHAR2,
    x_err_mesg_2                        IN     VARCHAR2,
    x_err_mesg_3                        IN     VARCHAR2,
    x_err_mesg_4                        IN     VARCHAR2,
    x_err_mesg_5                        IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_b_permt_addr_chg_date             IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_prc_type_code                     IN     VARCHAR2,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_guarnt_status_code                IN     VARCHAR2,
    x_lender_status_code                IN     VARCHAR2,
    x_pnote_status_code                 IN     VARCHAR2,
    x_credit_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lender_status_date                IN     DATE,
    x_pnote_status_date                 IN     DATE,
    x_credit_status_date                IN     DATE,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_amt_avail_for_reinst              IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_resp_record_status                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_mpn_confirm_ind                   IN     VARCHAR2 ,
    x_lender_use_txt                    IN     VARCHAR2 ,
    x_guarantor_use_txt                 IN     VARCHAR2 ,
    x_appl_loan_phase_code              IN     VARCHAR2 ,
    x_appl_loan_phase_code_chg          IN     DATE     ,
    x_cl_rec_status                     IN     VARCHAR2 ,
    x_cl_rec_status_last_update         IN     DATE     ,
    x_lend_apprv_denied_code            IN     VARCHAR2 ,
    x_lend_apprv_denied_date            IN     DATE     ,
    x_cl_version_code                   IN     VARCHAR2 ,
    x_school_use_txt                    IN     VARCHAR2 ,
    x_b_alien_reg_num_txt               IN     VARCHAR2 ,
    x_esign_src_typ_cd                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_clrp1_id                          => x_clrp1_id,
      x_cbth_id                           => x_cbth_id,
      x_rec_code                          => x_rec_code,
      x_rec_type_ind                      => x_rec_type_ind,
      x_b_last_name                       => x_b_last_name,
      x_b_first_name                      => x_b_first_name,
      x_b_middle_name                     => x_b_middle_name,
      x_b_ssn                             => x_b_ssn,
      x_b_permt_addr1                     => x_b_permt_addr1,
      x_b_permt_addr2                     => x_b_permt_addr2,
      x_b_permt_city                      => x_b_permt_city,
      x_b_permt_state                     => x_b_permt_state,
      x_b_permt_zip                       => x_b_permt_zip,
      x_b_permt_zip_suffix                => x_b_permt_zip_suffix,
      x_b_permt_phone                     => x_b_permt_phone,
      x_b_date_of_birth                   => x_b_date_of_birth,
      x_cl_loan_type                      => x_cl_loan_type,
      x_req_loan_amt                      => x_req_loan_amt,
      x_defer_req_code                    => x_defer_req_code,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_eft_auth_code                     => x_eft_auth_code,
      x_b_signature_code                  => x_b_signature_code,
      x_b_signature_date                  => x_b_signature_date,
      x_loan_number                       => x_loan_number,
      x_cl_seq_number                     => x_cl_seq_number,
      x_b_citizenship_status              => x_b_citizenship_status,
      x_b_state_of_legal_res              => x_b_state_of_legal_res,
      x_b_legal_res_date                  => x_b_legal_res_date,
      x_b_default_status                  => x_b_default_status,
      x_b_outstd_loan_code                => x_b_outstd_loan_code,
      x_b_indicator_code                  => x_b_indicator_code,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_name                     => x_s_middle_name,
      x_s_ssn                             => x_s_ssn,
      x_s_date_of_birth                   => x_s_date_of_birth,
      x_s_citizenship_status              => x_s_citizenship_status,
      x_s_default_code                    => x_s_default_code,
      x_s_signature_code                  => x_s_signature_code,
      x_school_id                         => x_school_id,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_coa_amt                           => x_coa_amt,
      x_efc_amt                           => x_efc_amt,
      x_est_fa_amt                        => x_est_fa_amt,
      x_fls_cert_amt                      => x_fls_cert_amt,
      x_flu_cert_amt                      => x_flu_cert_amt,
      x_flp_cert_amt                      => x_flp_cert_amt,
      x_sch_cert_date                     => x_sch_cert_date,
      x_alt_cert_amt                      => x_alt_cert_amt,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_duns_school_id                    => x_duns_school_id,
      x_lender_id                         => x_lender_id,
      x_fls_approved_amt                  => x_fls_approved_amt,
      x_flu_approved_amt                  => x_flu_approved_amt,
      x_flp_approved_amt                  => x_flp_approved_amt,
      x_alt_approved_amt                  => x_alt_approved_amt,
      x_duns_lender_id                    => x_duns_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_fed_appl_form_code                => x_fed_appl_form_code,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_lend_blkt_guarnt_ind              => x_lend_blkt_guarnt_ind,
      x_lend_blkt_guarnt_appr_date        => x_lend_blkt_guarnt_appr_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_guarantee_date                    => x_guarantee_date,
      x_guarantee_amt                     => x_guarantee_amt,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_b_license_state                   => x_b_license_state,
      x_b_license_number                  => x_b_license_number,
      x_b_ref_code                        => x_b_ref_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_b_foreign_postal_code             => x_b_foreign_postal_code,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_last_resort_lender                => x_last_resort_lender,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_err_mesg_1                        => x_err_mesg_1,
      x_err_mesg_2                        => x_err_mesg_2,
      x_err_mesg_3                        => x_err_mesg_3,
      x_err_mesg_4                        => x_err_mesg_4,
      x_err_mesg_5                        => x_err_mesg_5,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_tot_outstd_stafford               => x_tot_outstd_stafford,
      x_tot_outstd_plus                   => x_tot_outstd_plus,
      x_b_permt_addr_chg_date             => x_b_permt_addr_chg_date,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_borw_tot_debt                 => x_alt_borw_tot_debt,
      x_act_interest_rate                 => x_act_interest_rate,
      x_prc_type_code                     => x_prc_type_code,
      x_service_type_code                 => x_service_type_code,
      x_rev_notice_of_guarnt              => x_rev_notice_of_guarnt,
      x_sch_refund_amt                    => x_sch_refund_amt,
      x_sch_refund_date                   => x_sch_refund_date,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_lender_status_code                => x_lender_status_code,
      x_pnote_status_code                 => x_pnote_status_code,
      x_credit_status_code                => x_credit_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lender_status_date                => x_lender_status_date,
      x_pnote_status_date                 => x_pnote_status_date,
      x_credit_status_date                => x_credit_status_date,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_amt_avail_for_reinst              => x_amt_avail_for_reinst,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_uniq_layout_vend_code             => x_uniq_layout_vend_code,
      x_uniq_layout_ident_code            => x_uniq_layout_ident_code,
      x_resp_record_status                => x_resp_record_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_borr_sign_ind                     => x_borr_sign_ind,
      x_stud_sign_ind                     => x_stud_sign_ind,
      x_borr_credit_auth_code             => x_borr_credit_auth_code,
      x_mpn_confirm_ind                   => x_mpn_confirm_ind,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_cl_version_code                   => x_cl_version_code,
      x_school_use_txt                    => x_school_use_txt,
      x_b_alien_reg_num_txt               => x_b_alien_reg_num_txt,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd
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

    UPDATE igf_sl_cl_resp_r1_all
      SET
        cbth_id                           = new_references.cbth_id,
        rec_code                          = new_references.rec_code,
        rec_type_ind                      = new_references.rec_type_ind,
        b_last_name                       = new_references.b_last_name,
        b_first_name                      = new_references.b_first_name,
        b_middle_name                     = new_references.b_middle_name,
        b_ssn                             = new_references.b_ssn,
        b_permt_addr1                     = new_references.b_permt_addr1,
        b_permt_addr2                     = new_references.b_permt_addr2,
        b_permt_city                      = new_references.b_permt_city,
        b_permt_state                     = new_references.b_permt_state,
        b_permt_zip                       = new_references.b_permt_zip,
        b_permt_zip_suffix                = new_references.b_permt_zip_suffix,
        b_permt_phone                     = new_references.b_permt_phone,
        b_date_of_birth                   = new_references.b_date_of_birth,
        cl_loan_type                      = new_references.cl_loan_type,
        req_loan_amt                      = new_references.req_loan_amt,
        defer_req_code                    = new_references.defer_req_code,
        borw_interest_ind                 = new_references.borw_interest_ind,
        eft_auth_code                     = new_references.eft_auth_code,
        b_signature_code                  = new_references.b_signature_code,
        b_signature_date                  = new_references.b_signature_date,
        loan_number                       = new_references.loan_number,
        cl_seq_number                     = new_references.cl_seq_number,
        b_citizenship_status              = new_references.b_citizenship_status,
        b_state_of_legal_res              = new_references.b_state_of_legal_res,
        b_legal_res_date                  = new_references.b_legal_res_date,
        b_default_status                  = new_references.b_default_status,
        b_outstd_loan_code                = new_references.b_outstd_loan_code,
        b_indicator_code                  = new_references.b_indicator_code,
        s_last_name                       = new_references.s_last_name,
        s_first_name                      = new_references.s_first_name,
        s_middle_name                     = new_references.s_middle_name,
        s_ssn                             = new_references.s_ssn,
        s_date_of_birth                   = new_references.s_date_of_birth,
        s_citizenship_status              = new_references.s_citizenship_status,
        s_default_code                    = new_references.s_default_code,
        s_signature_code                  = new_references.s_signature_code,
        school_id                         = new_references.school_id,
        loan_per_begin_date               = new_references.loan_per_begin_date,
        loan_per_end_date                 = new_references.loan_per_end_date,
        grade_level_code                  = new_references.grade_level_code,
        enrollment_code                   = new_references.enrollment_code,
        anticip_compl_date                = new_references.anticip_compl_date,
        coa_amt                           = new_references.coa_amt,
        efc_amt                           = new_references.efc_amt,
        est_fa_amt                        = new_references.est_fa_amt,
        fls_cert_amt                      = new_references.fls_cert_amt,
        flu_cert_amt                      = new_references.flu_cert_amt,
        flp_cert_amt                      = new_references.flp_cert_amt,
        sch_cert_date                     = new_references.sch_cert_date,
        alt_cert_amt                      = new_references.alt_cert_amt,
        alt_appl_ver_code                 = new_references.alt_appl_ver_code,
        duns_school_id                    = new_references.duns_school_id,
        lender_id                         = new_references.lender_id,
        fls_approved_amt                  = new_references.fls_approved_amt,
        flu_approved_amt                  = new_references.flu_approved_amt,
        flp_approved_amt                  = new_references.flp_approved_amt,
        alt_approved_amt                  = new_references.alt_approved_amt,
        duns_lender_id                    = new_references.duns_lender_id,
        guarantor_id                      = new_references.guarantor_id,
        fed_appl_form_code                = new_references.fed_appl_form_code,
        duns_guarnt_id                    = new_references.duns_guarnt_id,
        lend_blkt_guarnt_ind              = new_references.lend_blkt_guarnt_ind,
        lend_blkt_guarnt_appr_date        = new_references.lend_blkt_guarnt_appr_date,
        guarnt_adj_ind                    = new_references.guarnt_adj_ind,
        guarantee_date                    = new_references.guarantee_date,
        guarantee_amt                     = new_references.guarantee_amt,
        req_serial_loan_code              = new_references.req_serial_loan_code,
        borw_confirm_ind                  = new_references.borw_confirm_ind,
        b_license_state                   = new_references.b_license_state,
        b_license_number                  = new_references.b_license_number,
        b_ref_code                        = new_references.b_ref_code,
        pnote_delivery_code               = new_references.pnote_delivery_code,
        b_foreign_postal_code             = new_references.b_foreign_postal_code,
        lend_non_ed_brc_id                = new_references.lend_non_ed_brc_id,
        last_resort_lender                = new_references.last_resort_lender,
        resp_to_orig_code                 = new_references.resp_to_orig_code,
        err_mesg_1                        = new_references.err_mesg_1,
        err_mesg_2                        = new_references.err_mesg_2,
        err_mesg_3                        = new_references.err_mesg_3,
        err_mesg_4                        = new_references.err_mesg_4,
        err_mesg_5                        = new_references.err_mesg_5,
        guarnt_amt_redn_code              = new_references.guarnt_amt_redn_code,
        tot_outstd_stafford               = new_references.tot_outstd_stafford,
        tot_outstd_plus                   = new_references.tot_outstd_plus,
        b_permt_addr_chg_date             = new_references.b_permt_addr_chg_date,
        alt_prog_type_code                = new_references.alt_prog_type_code,
        alt_borw_tot_debt                 = new_references.alt_borw_tot_debt,
        act_interest_rate                 = new_references.act_interest_rate,
        prc_type_code                     = new_references.prc_type_code,
        service_type_code                 = new_references.service_type_code,
        rev_notice_of_guarnt              = new_references.rev_notice_of_guarnt,
        sch_refund_amt                    = new_references.sch_refund_amt,
        sch_refund_date                   = new_references.sch_refund_date,
        guarnt_status_code                = new_references.guarnt_status_code,
        lender_status_code                = new_references.lender_status_code,
        pnote_status_code                 = new_references.pnote_status_code,
        credit_status_code                = new_references.credit_status_code,
        guarnt_status_date                = new_references.guarnt_status_date,
        lender_status_date                = new_references.lender_status_date,
        pnote_status_date                 = new_references.pnote_status_date,
        credit_status_date                = new_references.credit_status_date,
        act_serial_loan_code              = new_references.act_serial_loan_code,
        amt_avail_for_reinst              = new_references.amt_avail_for_reinst,
        sch_non_ed_brc_id                 = new_references.sch_non_ed_brc_id,
        uniq_layout_vend_code             = new_references.uniq_layout_vend_code,
        uniq_layout_ident_code            = new_references.uniq_layout_ident_code,
        resp_record_status                = new_references.resp_record_status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        borr_sign_ind                     = new_references.borr_sign_ind,
        stud_sign_ind                     = new_references.stud_sign_ind,
        borr_credit_auth_code             = new_references.borr_credit_auth_code,
        mpn_confirm_ind                   = new_references.mpn_confirm_ind,
        lender_use_txt                    = new_references.lender_use_txt,
        guarantor_use_txt                 = new_references.guarantor_use_txt,
        appl_loan_phase_code              = new_references.appl_loan_phase_code,
        appl_loan_phase_code_chg          = new_references.appl_loan_phase_code_chg,
        cl_rec_status                     = new_references.cl_rec_status ,
        cl_rec_status_last_update         = new_references.cl_rec_status_last_update,
        lend_apprv_denied_code            = new_references.lend_apprv_denied_code,
        lend_apprv_denied_date            = new_references.lend_apprv_denied_date,
        cl_version_code                   = new_references.cl_version_code,
        school_use_txt                    = new_references.school_use_txt,
        b_alien_reg_num_txt               = new_references.b_alien_reg_num_txt,
        esign_src_typ_cd                  = new_references.esign_src_typ_cd
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN OUT NOCOPY NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_rec_code                          IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     NUMBER,
    x_b_permt_addr1                     IN     VARCHAR2,
    x_b_permt_addr2                     IN     VARCHAR2,
    x_b_permt_city                      IN     VARCHAR2,
    x_b_permt_state                     IN     VARCHAR2,
    x_b_permt_zip                       IN     NUMBER,
    x_b_permt_zip_suffix                IN     NUMBER,
    x_b_permt_phone                     IN     VARCHAR2,
    x_b_date_of_birth                   IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_req_loan_amt                      IN     NUMBER,
    x_defer_req_code                    IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_eft_auth_code                     IN     VARCHAR2,
    x_b_signature_code                  IN     VARCHAR2,
    x_b_signature_date                  IN     DATE,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_citizenship_status              IN     VARCHAR2,
    x_b_state_of_legal_res              IN     VARCHAR2,
    x_b_legal_res_date                  IN     DATE,
    x_b_default_status                  IN     VARCHAR2,
    x_b_outstd_loan_code                IN     VARCHAR2,
    x_b_indicator_code                  IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_ssn                             IN     NUMBER,
    x_s_date_of_birth                   IN     DATE,
    x_s_citizenship_status              IN     VARCHAR2,
    x_s_default_code                    IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_coa_amt                           IN     NUMBER,
    x_efc_amt                           IN     NUMBER,
    x_est_fa_amt                        IN     NUMBER,
    x_fls_cert_amt                      IN     NUMBER,
    x_flu_cert_amt                      IN     NUMBER,
    x_flp_cert_amt                      IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_alt_cert_amt                      IN     NUMBER,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_duns_school_id                    IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_fls_approved_amt                  IN     NUMBER,
    x_flu_approved_amt                  IN     NUMBER,
    x_flp_approved_amt                  IN     NUMBER,
    x_alt_approved_amt                  IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_fed_appl_form_code                IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_lend_blkt_guarnt_ind              IN     VARCHAR2,
    x_lend_blkt_guarnt_appr_date        IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_b_license_state                   IN     VARCHAR2,
    x_b_license_number                  IN     VARCHAR2,
    x_b_ref_code                        IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_b_foreign_postal_code             IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_last_resort_lender                IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_err_mesg_1                        IN     VARCHAR2,
    x_err_mesg_2                        IN     VARCHAR2,
    x_err_mesg_3                        IN     VARCHAR2,
    x_err_mesg_4                        IN     VARCHAR2,
    x_err_mesg_5                        IN     VARCHAR2,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_tot_outstd_stafford               IN     NUMBER,
    x_tot_outstd_plus                   IN     NUMBER,
    x_b_permt_addr_chg_date             IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_borw_tot_debt                 IN     NUMBER,
    x_act_interest_rate                 IN     NUMBER,
    x_prc_type_code                     IN     VARCHAR2,
    x_service_type_code                 IN     VARCHAR2,
    x_rev_notice_of_guarnt              IN     VARCHAR2,
    x_sch_refund_amt                    IN     NUMBER,
    x_sch_refund_date                   IN     DATE,
    x_guarnt_status_code                IN     VARCHAR2,
    x_lender_status_code                IN     VARCHAR2,
    x_pnote_status_code                 IN     VARCHAR2,
    x_credit_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lender_status_date                IN     DATE,
    x_pnote_status_date                 IN     DATE,
    x_credit_status_date                IN     DATE,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_amt_avail_for_reinst              IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_uniq_layout_vend_code             IN     VARCHAR2,
    x_uniq_layout_ident_code            IN     VARCHAR2,
    x_resp_record_status                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2 ,
    x_mpn_confirm_ind                   IN     VARCHAR2 ,
    x_lender_use_txt                    IN     VARCHAR2 ,
    x_guarantor_use_txt                 IN     VARCHAR2 ,
    x_appl_loan_phase_code              IN     VARCHAR2 ,
    x_appl_loan_phase_code_chg          IN     DATE     ,
    x_cl_rec_status                     IN     VARCHAR2 ,
    x_cl_rec_status_last_update         IN     DATE     ,
    x_lend_apprv_denied_code            IN     VARCHAR2 ,
    x_lend_apprv_denied_date            IN     DATE     ,
    x_cl_version_code                   IN     VARCHAR2 ,
    x_school_use_txt                    IN     VARCHAR2 ,
    x_b_alien_reg_num_txt               IN     VARCHAR2 ,
    x_esign_src_typ_cd                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_cl_resp_r1_all
      WHERE    clrp1_id                          = x_clrp1_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clrp1_id,
        x_cbth_id,
        x_rec_code,
        x_rec_type_ind,
        x_b_last_name,
        x_b_first_name,
        x_b_middle_name,
        x_b_ssn,
        x_b_permt_addr1,
        x_b_permt_addr2,
        x_b_permt_city,
        x_b_permt_state,
        x_b_permt_zip,
        x_b_permt_zip_suffix,
        x_b_permt_phone,
        x_b_date_of_birth,
        x_cl_loan_type,
        x_req_loan_amt,
        x_defer_req_code,
        x_borw_interest_ind,
        x_eft_auth_code,
        x_b_signature_code,
        x_b_signature_date,
        x_loan_number,
        x_cl_seq_number,
        x_b_citizenship_status,
        x_b_state_of_legal_res,
        x_b_legal_res_date,
        x_b_default_status,
        x_b_outstd_loan_code,
        x_b_indicator_code,
        x_s_last_name,
        x_s_first_name,
        x_s_middle_name,
        x_s_ssn,
        x_s_date_of_birth,
        x_s_citizenship_status,
        x_s_default_code,
        x_s_signature_code,
        x_school_id,
        x_loan_per_begin_date,
        x_loan_per_end_date,
        x_grade_level_code,
        x_enrollment_code,
        x_anticip_compl_date,
        x_coa_amt,
        x_efc_amt,
        x_est_fa_amt,
        x_fls_cert_amt,
        x_flu_cert_amt,
        x_flp_cert_amt,
        x_sch_cert_date,
        x_alt_cert_amt,
        x_alt_appl_ver_code,
        x_duns_school_id,
        x_lender_id,
        x_fls_approved_amt,
        x_flu_approved_amt,
        x_flp_approved_amt,
        x_alt_approved_amt,
        x_duns_lender_id,
        x_guarantor_id,
        x_fed_appl_form_code,
        x_duns_guarnt_id,
        x_lend_blkt_guarnt_ind,
        x_lend_blkt_guarnt_appr_date,
        x_guarnt_adj_ind,
        x_guarantee_date,
        x_guarantee_amt,
        x_req_serial_loan_code,
        x_borw_confirm_ind,
        x_b_license_state,
        x_b_license_number,
        x_b_ref_code,
        x_pnote_delivery_code,
        x_b_foreign_postal_code,
        x_lend_non_ed_brc_id,
        x_last_resort_lender,
        x_resp_to_orig_code,
        x_err_mesg_1,
        x_err_mesg_2,
        x_err_mesg_3,
        x_err_mesg_4,
        x_err_mesg_5,
        x_guarnt_amt_redn_code,
        x_tot_outstd_stafford,
        x_tot_outstd_plus,
        x_b_permt_addr_chg_date,
        x_alt_prog_type_code,
        x_alt_borw_tot_debt,
        x_act_interest_rate,
        x_prc_type_code,
        x_service_type_code,
        x_rev_notice_of_guarnt,
        x_sch_refund_amt,
        x_sch_refund_date,
        x_guarnt_status_code,
        x_lender_status_code,
        x_pnote_status_code,
        x_credit_status_code,
        x_guarnt_status_date,
        x_lender_status_date,
        x_pnote_status_date,
        x_credit_status_date,
        x_act_serial_loan_code,
        x_amt_avail_for_reinst,
        x_sch_non_ed_brc_id,
        x_uniq_layout_vend_code,
        x_uniq_layout_ident_code,
        x_resp_record_status,
        x_mode,
        x_borr_sign_ind,
        x_stud_sign_ind,
        x_borr_credit_auth_code,
        x_mpn_confirm_ind,
        x_lender_use_txt,
        x_guarantor_use_txt ,
        x_appl_loan_phase_code,
        x_appl_loan_phase_code_chg,
        x_cl_rec_status ,
        x_cl_rec_status_last_update,
        x_lend_apprv_denied_code ,
        x_lend_apprv_denied_date ,
        x_cl_version_code,
        x_school_use_txt,
        x_b_alien_reg_num_txt,
        x_esign_src_typ_cd
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clrp1_id,
      x_cbth_id,
      x_rec_code,
      x_rec_type_ind,
      x_b_last_name,
      x_b_first_name,
      x_b_middle_name,
      x_b_ssn,
      x_b_permt_addr1,
      x_b_permt_addr2,
      x_b_permt_city,
      x_b_permt_state,
      x_b_permt_zip,
      x_b_permt_zip_suffix,
      x_b_permt_phone,
      x_b_date_of_birth,
      x_cl_loan_type,
      x_req_loan_amt,
      x_defer_req_code,
      x_borw_interest_ind,
      x_eft_auth_code,
      x_b_signature_code,
      x_b_signature_date,
      x_loan_number,
      x_cl_seq_number,
      x_b_citizenship_status,
      x_b_state_of_legal_res,
      x_b_legal_res_date,
      x_b_default_status,
      x_b_outstd_loan_code,
      x_b_indicator_code,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_name,
      x_s_ssn,
      x_s_date_of_birth,
      x_s_citizenship_status,
      x_s_default_code,
      x_s_signature_code,
      x_school_id,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_coa_amt,
      x_efc_amt,
      x_est_fa_amt,
      x_fls_cert_amt,
      x_flu_cert_amt,
      x_flp_cert_amt,
      x_sch_cert_date,
      x_alt_cert_amt,
      x_alt_appl_ver_code,
      x_duns_school_id,
      x_lender_id,
      x_fls_approved_amt,
      x_flu_approved_amt,
      x_flp_approved_amt,
      x_alt_approved_amt,
      x_duns_lender_id,
      x_guarantor_id,
      x_fed_appl_form_code,
      x_duns_guarnt_id,
      x_lend_blkt_guarnt_ind,
      x_lend_blkt_guarnt_appr_date,
      x_guarnt_adj_ind,
      x_guarantee_date,
      x_guarantee_amt,
      x_req_serial_loan_code,
      x_borw_confirm_ind,
      x_b_license_state,
      x_b_license_number,
      x_b_ref_code,
      x_pnote_delivery_code,
      x_b_foreign_postal_code,
      x_lend_non_ed_brc_id,
      x_last_resort_lender,
      x_resp_to_orig_code,
      x_err_mesg_1,
      x_err_mesg_2,
      x_err_mesg_3,
      x_err_mesg_4,
      x_err_mesg_5,
      x_guarnt_amt_redn_code,
      x_tot_outstd_stafford,
      x_tot_outstd_plus,
      x_b_permt_addr_chg_date,
      x_alt_prog_type_code,
      x_alt_borw_tot_debt,
      x_act_interest_rate,
      x_prc_type_code,
      x_service_type_code,
      x_rev_notice_of_guarnt,
      x_sch_refund_amt,
      x_sch_refund_date,
      x_guarnt_status_code,
      x_lender_status_code,
      x_pnote_status_code,
      x_credit_status_code,
      x_guarnt_status_date,
      x_lender_status_date,
      x_pnote_status_date,
      x_credit_status_date,
      x_act_serial_loan_code,
      x_amt_avail_for_reinst,
      x_sch_non_ed_brc_id,
      x_uniq_layout_vend_code,
      x_uniq_layout_ident_code,
      x_resp_record_status,
      x_mode,
      x_borr_sign_ind,
      x_stud_sign_ind,
      x_borr_credit_auth_code,
      x_mpn_confirm_ind,
      x_lender_use_txt,
      x_guarantor_use_txt ,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_cl_rec_status ,
      x_cl_rec_status_last_update,
      x_lend_apprv_denied_code ,
      x_lend_apprv_denied_date ,
      x_cl_version_code,
      x_school_use_txt,
      x_b_alien_reg_num_txt,
      x_esign_src_typ_cd
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 02-NOV-2000
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

    DELETE FROM igf_sl_cl_resp_r1_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_cl_resp_r1_pkg;

/
