--------------------------------------------------------
--  DDL for Package Body IGF_SL_LOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_LOR_PKG" AS
/* $Header: IGFLI10B.pls 120.2 2006/08/03 12:49:51 tsailaja noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_lor_all%ROWTYPE;
  new_references igf_sl_lor_all%ROWTYPE;
  g_v_called_from VARCHAR2(30);

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_origination_id                    IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_sch_cert_date                     IN     DATE        DEFAULT NULL,
    x_orig_status_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_orig_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_orig_batch_date                   IN     DATE        DEFAULT NULL,
    x_chg_batch_id                      IN     VARCHAR2    DEFAULT NULL,
    x_orig_ack_date                     IN     DATE        DEFAULT NULL,
    x_credit_override                   IN     VARCHAR2    DEFAULT NULL,
    x_credit_decision_date              IN     DATE        DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_act_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status                      IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status_date                 IN     DATE        DEFAULT NULL,
    x_pnote_id                          IN     VARCHAR2    DEFAULT NULL,
    x_pnote_print_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_pnote_accept_amt                  IN     NUMBER      DEFAULT NULL,
    x_pnote_accept_date                 IN     DATE        DEFAULT NULL,
    x_unsub_elig_for_heal               IN     VARCHAR2    DEFAULT NULL,
    x_disclosure_print_ind              IN     VARCHAR2    DEFAULT NULL,
    x_orig_fee_perct                    IN     NUMBER      DEFAULT NULL,
    x_borw_confirm_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_borw_outstd_loan_code             IN     VARCHAR2    DEFAULT NULL,
    x_unsub_elig_for_depnt              IN     VARCHAR2    DEFAULT NULL,
    x_guarantee_amt                     IN     NUMBER      DEFAULT NULL,
    x_guarantee_date                    IN     DATE        DEFAULT NULL,
    x_guarnt_amt_redn_code              IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_date                IN     DATE        DEFAULT NULL,
    x_lend_apprv_denied_code            IN     VARCHAR2    DEFAULT NULL,
    x_lend_apprv_denied_date            IN     DATE        DEFAULT NULL,
    x_lend_status_code                  IN     VARCHAR2    DEFAULT NULL,
    x_lend_status_date                  IN     DATE        DEFAULT NULL,
    x_guarnt_adj_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_grade_level_code                  IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_code                   IN     VARCHAR2    DEFAULT NULL,
    x_anticip_compl_date                IN     DATE        DEFAULT NULL,
    x_borw_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_borw_lender_id               IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_seq_number                     IN     NUMBER      DEFAULT NULL,
    x_last_resort_lender                IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_recip_id                     IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_rec_type_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_cl_loan_type                      IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status_last_update         IN     DATE        DEFAULT NULL,
    x_alt_prog_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_alt_appl_ver_code                 IN     NUMBER      DEFAULT NULL,
    x_mpn_confirm_code                  IN     VARCHAR2    DEFAULT NULL,
    x_resp_to_orig_code                 IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code              IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code_chg          IN     DATE        DEFAULT NULL,
    x_appl_send_error_codes             IN     VARCHAR2    DEFAULT NULL,
    x_tot_outstd_stafford               IN     NUMBER      DEFAULT NULL,
    x_tot_outstd_plus                   IN     NUMBER      DEFAULT NULL,
    x_alt_borw_tot_debt                 IN     NUMBER      DEFAULT NULL,
    x_act_interest_rate                 IN     NUMBER      DEFAULT NULL,
    x_service_type_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rev_notice_of_guarnt              IN     VARCHAR2    DEFAULT NULL,
    x_sch_refund_amt                    IN     NUMBER      DEFAULT NULL,
    x_sch_refund_date                   IN     DATE        DEFAULT NULL,
    x_uniq_layout_vend_code             IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_ident_code            IN     VARCHAR2    DEFAULT NULL,
    x_p_person_id                       IN     NUMBER      DEFAULT NULL,
    x_p_ssn_chg_date                    IN     DATE        DEFAULT NULL,
    x_p_dob_chg_date                    IN     DATE        DEFAULT NULL,
    x_p_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_p_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_p_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_p_signature_date                  IN     DATE        DEFAULT NULL,
    x_s_ssn_chg_date                    IN     DATE        DEFAULT NULL,
    x_s_dob_chg_date                    IN     DATE        DEFAULT NULL,
    x_s_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_s_local_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_s_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_s_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_pnote_batch_id                    IN     VARCHAR2    DEFAULT NULL,
    x_pnote_ack_date                    IN     DATE        DEFAULT NULL,
    x_pnote_mpn_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_elec_mpn_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_borr_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_stud_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_borr_credit_auth_code             IN     VARCHAR2    DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_interest_rebate_percent_num       IN     NUMBER      DEFAULT NULL,
    x_cps_trans_num                     IN     NUMBER      DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_crdt_decision_status              IN     VARCHAR2    DEFAULT NULL,
    x_note_message                      IN     VARCHAR2    DEFAULT NULL,
    x_book_loan_amt                     IN     NUMBER      DEFAULT NULL,
    x_book_loan_amt_date                IN     DATE        DEFAULT NULL,
    x_pymt_servicer_amt                 IN     NUMBER      DEFAULT NULL,
    x_pymt_servicer_date                IN     DATE        DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2   ,
    x_deferment_request_code            IN     VARCHAR2   ,
    x_eft_authorization_code            IN     VARCHAR2   ,
    x_requested_loan_amt                IN     NUMBER     ,
    x_actual_record_type_code           IN     VARCHAR2   ,
    x_reinstatement_amt                 IN     NUMBER     ,
    x_school_use_txt                    IN     VARCHAR2   ,
    x_lender_use_txt                    IN     VARCHAR2   ,
    x_guarantor_use_txt                 IN     VARCHAR2   ,
    x_fls_approved_amt                  IN     NUMBER     ,
    x_flu_approved_amt                  IN     NUMBER     ,
    x_flp_approved_amt                  IN     NUMBER     ,
    x_alt_approved_amt                  IN     NUMBER     ,
    x_loan_app_form_code                IN     VARCHAR2   ,
    x_override_grade_level_code         IN     VARCHAR2   ,
    x_b_alien_reg_num_txt               IN     VARCHAR2   ,
    x_esign_src_typ_cd                  IN     VARCHAR2   ,
    x_acad_begin_date                   IN     DATE       ,
    x_acad_end_date                     IN     DATE
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_LOR_ALL
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
    new_references.origination_id                    := x_origination_id;
    new_references.loan_id                           := x_loan_id;
    new_references.sch_cert_date                     := x_sch_cert_date;
    new_references.orig_status_flag                  := x_orig_status_flag;
    new_references.orig_batch_id                     := x_orig_batch_id;
    new_references.orig_batch_date                   := x_orig_batch_date;
    new_references.orig_ack_date                     := x_orig_ack_date;
    new_references.credit_override                   := x_credit_override;
    new_references.credit_decision_date              := x_credit_decision_date;
    new_references.req_serial_loan_code              := x_req_serial_loan_code;
    new_references.act_serial_loan_code              := x_act_serial_loan_code;
    new_references.pnote_delivery_code               := x_pnote_delivery_code;
    new_references.pnote_status                      := x_pnote_status;
    new_references.pnote_status_date                 := x_pnote_status_date;
    new_references.pnote_id                          := x_pnote_id;
    new_references.pnote_print_ind                   := x_pnote_print_ind;
    new_references.pnote_accept_amt                  := x_pnote_accept_amt;
    new_references.pnote_accept_date                 := x_pnote_accept_date;
    new_references.unsub_elig_for_heal               := x_unsub_elig_for_heal;
    new_references.disclosure_print_ind              := x_disclosure_print_ind;
    new_references.orig_fee_perct                    := x_orig_fee_perct;
    new_references.borw_confirm_ind                  := x_borw_confirm_ind;
    new_references.borw_interest_ind                 := x_borw_interest_ind;
    new_references.borw_outstd_loan_code             := x_borw_outstd_loan_code;
    new_references.unsub_elig_for_depnt              := x_unsub_elig_for_depnt;
    new_references.guarantee_amt                     := x_guarantee_amt;
    new_references.guarantee_date                    := x_guarantee_date;
    new_references.guarnt_amt_redn_code              := x_guarnt_amt_redn_code;
    new_references.guarnt_status_code                := x_guarnt_status_code;
    new_references.guarnt_status_date                := x_guarnt_status_date;
    new_references.lend_status_code                  := x_lend_status_code;
    new_references.lend_status_date                  := x_lend_status_date;
    new_references.guarnt_adj_ind                    := x_guarnt_adj_ind;
    new_references.grade_level_code                  := x_grade_level_code;
    new_references.enrollment_code                   := x_enrollment_code;
    new_references.anticip_compl_date                := x_anticip_compl_date;
    new_references.prc_type_code                     := x_prc_type_code;
    new_references.cl_seq_number                     := x_cl_seq_number;
    new_references.last_resort_lender                := x_last_resort_lender;
    new_references.rec_type_ind                      := x_rec_type_ind;
    new_references.cl_loan_type                      := x_cl_loan_type;
    new_references.alt_prog_type_code                := x_alt_prog_type_code;
    new_references.alt_appl_ver_code                 := x_alt_appl_ver_code;
    new_references.resp_to_orig_code                 := x_resp_to_orig_code;
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
    new_references.p_permt_addr_chg_date             := x_p_permt_addr_chg_date;
    new_references.p_default_status                  := x_p_default_status;
    new_references.p_signature_code                  := x_p_signature_code;
    new_references.p_signature_date                  := x_p_signature_date;
    new_references.s_permt_addr_chg_date             := x_s_permt_addr_chg_date;
    new_references.s_default_status                  := x_s_default_status;
    new_references.s_signature_code                  := x_s_signature_code;

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

    new_references.pnote_batch_id                    := x_pnote_batch_id;
    new_references.pnote_ack_date                    := x_pnote_ack_date;
    new_references.pnote_mpn_ind                     := x_pnote_mpn_ind;

    new_references.elec_mpn_ind                      := x_elec_mpn_ind;
    new_references.borr_sign_ind                     := x_borr_sign_ind;
    new_references.stud_sign_ind                     := x_stud_sign_ind;
    new_references.borr_credit_auth_code             := x_borr_credit_auth_code;
    new_references.relationship_cd                   := x_relationship_cd;

    new_references.interest_rebate_percent_num       := x_interest_rebate_percent_num;
    new_references.cps_trans_num                     := x_cps_trans_num;
    new_references.atd_entity_id_txt                 := x_atd_entity_id_txt;
    new_references.rep_entity_id_txt                 := x_rep_entity_id_txt;
    new_references.crdt_decision_status              := x_crdt_decision_status;
    new_references.note_message                      := x_note_message;
    new_references.book_loan_amt                     := x_book_loan_amt;
    new_references.book_loan_amt_date                := x_book_loan_amt_date;


    new_references.appl_loan_phase_code       :=  x_appl_loan_phase_code         ;
    new_references.appl_loan_phase_code_chg   :=  x_appl_loan_phase_code_chg     ;
    new_references.cl_rec_status              :=  x_cl_rec_status                ;
    new_references.cl_rec_status_last_update  :=  x_cl_rec_status_last_update    ;
    new_references.mpn_confirm_code           :=  x_mpn_confirm_code             ;
    new_references.lend_apprv_denied_code     :=  x_lend_apprv_denied_code       ;
    new_references.lend_apprv_denied_date     :=  x_lend_apprv_denied_date       ;
    new_references.external_loan_id_txt       :=  x_external_loan_id_txt      ;
    new_references.deferment_request_code     :=  x_deferment_request_code    ;
    new_references.eft_authorization_code     :=  x_eft_authorization_code    ;
    new_references.requested_loan_amt         :=  x_requested_loan_amt        ;
    new_references.actual_record_type_code    :=  x_actual_record_type_code   ;
    new_references.reinstatement_amt          :=  x_reinstatement_amt         ;
    new_references.school_use_txt             :=  x_school_use_txt            ;
    new_references.lender_use_txt             :=  x_lender_use_txt            ;
    new_references.guarantor_use_txt          :=  x_guarantor_use_txt         ;
    new_references.fls_approved_amt           :=  x_fls_approved_amt          ;
    new_references.flu_approved_amt           :=  x_flu_approved_amt          ;
    new_references.flp_approved_amt           :=  x_flp_approved_amt          ;
    new_references.alt_approved_amt           :=  x_alt_approved_amt          ;
    new_references.loan_app_form_code         :=  x_loan_app_form_code        ;
    new_references.override_grade_level_code  :=  x_override_grade_level_code ;
    new_references.b_alien_reg_num_txt        :=  x_b_alien_reg_num_txt       ;
    new_references.esign_src_typ_cd           :=  x_esign_src_typ_cd          ;
    new_references.acad_begin_date            :=  x_acad_begin_date           ;
    new_references.acad_end_date              :=  x_acad_end_date             ;
  END set_column_values;

  PROCEDURE AfterRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Sanil Madathil
  ||  Created On : 13-Oct-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  bvisvana        02-Mar-2006    Bug# 5006583, FA161 CL4. modified condition for g_v_called_from in ('IGFSL007',' UPDATE_MODE')
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
    CURSOR  c_igf_sl_loans(cp_n_loan_id igf_sl_loans.loan_id%TYPE) IS
    SELECT  award_id
    FROM    igf_sl_loans_all
    WHERE   loan_id = cp_n_loan_id;

    l_n_award_id       igf_aw_award_all.award_id%TYPE;
    l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;
    l_v_message_name   fnd_new_messages.message_name%TYPE;
    l_b_return_status  BOOLEAN;
    l_null_date_check  DATE;
  BEGIN
    IF p_updating THEN
      OPEN   c_igf_sl_loans (cp_n_loan_id => new_references.loan_id);
      FETCH  c_igf_sl_loans INTO l_n_award_id;
      CLOSE  c_igf_sl_loans ;
      l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => l_n_award_id,
                                                         p_v_message_name => l_v_message_name
                                                         );
      IF l_v_message_name IS NOT NULL THEN
        fnd_message.set_name ('IGS',l_v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      l_null_date_check := TO_DATE('01-01-1900','DD-MM-YYYY');
	  -- tsailaja -FA 163  -Bug 5337555
      IF l_v_fed_fund_code IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
        IF g_v_called_from IN ('IGFSL007','UPDATE_MODE') THEN
        --bvisvana bug# 5091388
          IF ((NVL(new_references.anticip_compl_date,l_null_date_check) <> NVL(old_references.anticip_compl_date,l_null_date_check)) OR
              (NVL(new_references.override_grade_level_code,'*') <> NVL(old_references.override_grade_level_code,'*')) OR
              ((NVL(new_references.grade_level_code,'*') <> NVL(old_references.grade_level_code,'*')) AND g_v_called_from = 'UPDATE_MODE')
             ) THEN
            -- invoke the procedure to create of change record in igf_sl_clchsn_dtls table
            igf_sl_cl_create_chg.create_lor_chg_rec
            (
               p_new_lor_rec       => new_references,
               p_b_return_status   => l_b_return_status,
               p_v_message_name    => l_v_message_name
            );
            -- if the above call out returns false and error message is returned,
            -- add the message to the error stack and error message text should be displayed
            -- in the calling form
            IF (NOT (l_b_return_status) AND l_v_message_name IS NOT NULL )
            THEN
              -- substring of the out bound parameter l_v_message_name is carried
              -- out since it can expect either IGS OR IGF message
              fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
              igf_sl_cl_chg_prc.parse_tokens(
                p_t_message_tokens => igf_sl_cl_chg_prc.g_message_tokens);
/*
              FOR token_counter IN igf_sl_cl_chg_prc.g_message_tokens.FIRST..igf_sl_cl_chg_prc.g_message_tokens.LAST LOOP
                 fnd_message.set_token(igf_sl_cl_chg_prc.g_message_tokens(token_counter).token_name, igf_sl_cl_chg_prc.g_message_tokens(token_counter).token_value);
              END LOOP;
*/
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  END AfterRowInsertUpdateDelete1;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.loan_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    IF (((old_references.loan_id = new_references.loan_id)) OR
        ((new_references.loan_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_loans_pkg.get_pk_for_validation (
                new_references.loan_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  -- add code for relationship code
  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_sl_lor_loc_pkg.get_fk_igf_sl_lor (
      old_references.origination_id
    );

    igf_sl_pnote_stat_h_pkg.get_ufk_igf_sl_lor (
      old_references.loan_id
    );

  END check_child_existance;


  PROCEDURE check_uk_child_existance IS
  /*
  ||  Created By :
  ||  Created On : 11-MAY-2001
  ||  Purpose : Checks for the existance of Child records based on Unique Keys of this table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.loan_id = new_references.loan_id)) OR
        ((old_references.loan_id IS NULL))) THEN
      NULL;
    ELSE igf_sl_pnote_stat_h_pkg.get_ufk_igf_sl_lor (
           old_references.loan_id
         );
    END IF;

  END check_uk_child_existance;


  FUNCTION get_pk_for_validation (
    x_origination_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE    origination_id = x_origination_id
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


  FUNCTION get_uk_for_validation (
    x_loan_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE    loan_id = x_loan_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE   ((p_person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE get_fk_igf_sl_loans (
    x_loan_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE   ((loan_id = x_loan_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_LOR_LAR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_loans;


  PROCEDURE get_fk_igf_sl_cl_recipient (
    x_relationship_cd                           IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE   ((relationship_cd = x_relationship_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_LOR_RECIP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_recipient;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_origination_id                    IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_sch_cert_date                     IN     DATE        DEFAULT NULL,
    x_orig_status_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_orig_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_orig_batch_date                   IN     DATE        DEFAULT NULL,
    x_chg_batch_id                      IN     VARCHAR2    DEFAULT NULL,
    x_orig_ack_date                     IN     DATE        DEFAULT NULL,
    x_credit_override                   IN     VARCHAR2    DEFAULT NULL,
    x_credit_decision_date              IN     DATE        DEFAULT NULL,
    x_req_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_act_serial_loan_code              IN     VARCHAR2    DEFAULT NULL,
    x_pnote_delivery_code               IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status                      IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status_date                 IN     DATE        DEFAULT NULL,
    x_pnote_id                          IN     VARCHAR2    DEFAULT NULL,
    x_pnote_print_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_pnote_accept_amt                  IN     NUMBER      DEFAULT NULL,
    x_pnote_accept_date                 IN     DATE        DEFAULT NULL,
    x_unsub_elig_for_heal               IN     VARCHAR2    DEFAULT NULL,
    x_disclosure_print_ind              IN     VARCHAR2    DEFAULT NULL,
    x_orig_fee_perct                    IN     NUMBER      DEFAULT NULL,
    x_borw_confirm_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_borw_interest_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_borw_outstd_loan_code             IN     VARCHAR2    DEFAULT NULL,
    x_unsub_elig_for_depnt              IN     VARCHAR2    DEFAULT NULL,
    x_guarantee_amt                     IN     NUMBER      DEFAULT NULL,
    x_guarantee_date                    IN     DATE        DEFAULT NULL,
    x_guarnt_amt_redn_code              IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_code                IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_status_date                IN     DATE        DEFAULT NULL,
    x_lend_apprv_denied_code            IN     VARCHAR2    DEFAULT NULL,
    x_lend_apprv_denied_date            IN     DATE        DEFAULT NULL,
    x_lend_status_code                  IN     VARCHAR2    DEFAULT NULL,
    x_lend_status_date                  IN     DATE        DEFAULT NULL,
    x_guarnt_adj_ind                    IN     VARCHAR2    DEFAULT NULL,
    x_grade_level_code                  IN     VARCHAR2    DEFAULT NULL,
    x_enrollment_code                   IN     VARCHAR2    DEFAULT NULL,
    x_anticip_compl_date                IN     DATE        DEFAULT NULL,
    x_borw_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_borw_lender_id               IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_prc_type_code                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_seq_number                     IN     NUMBER      DEFAULT NULL,
    x_last_resort_lender                IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_duns_recip_id                     IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_rec_type_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_cl_loan_type                      IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status                     IN     VARCHAR2    DEFAULT NULL,
    x_cl_rec_status_last_update         IN     DATE        DEFAULT NULL,
    x_alt_prog_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_alt_appl_ver_code                 IN     NUMBER      DEFAULT NULL,
    x_mpn_confirm_code                  IN     VARCHAR2    DEFAULT NULL,
    x_resp_to_orig_code                 IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code              IN     VARCHAR2    DEFAULT NULL,
    x_appl_loan_phase_code_chg          IN     DATE        DEFAULT NULL,
    x_appl_send_error_codes             IN     VARCHAR2    DEFAULT NULL,
    x_tot_outstd_stafford               IN     NUMBER      DEFAULT NULL,
    x_tot_outstd_plus                   IN     NUMBER      DEFAULT NULL,
    x_alt_borw_tot_debt                 IN     NUMBER      DEFAULT NULL,
    x_act_interest_rate                 IN     NUMBER      DEFAULT NULL,
    x_service_type_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rev_notice_of_guarnt              IN     VARCHAR2    DEFAULT NULL,
    x_sch_refund_amt                    IN     NUMBER      DEFAULT NULL,
    x_sch_refund_date                   IN     DATE        DEFAULT NULL,
    x_uniq_layout_vend_code             IN     VARCHAR2    DEFAULT NULL,
    x_uniq_layout_ident_code            IN     VARCHAR2    DEFAULT NULL,
    x_p_person_id                       IN     NUMBER      DEFAULT NULL,
    x_p_ssn_chg_date                    IN     DATE        DEFAULT NULL,
    x_p_dob_chg_date                    IN     DATE        DEFAULT NULL,
    x_p_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_p_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_p_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_p_signature_date                  IN     DATE        DEFAULT NULL,
    x_s_ssn_chg_date                    IN     DATE        DEFAULT NULL,
    x_s_dob_chg_date                    IN     DATE        DEFAULT NULL,
    x_s_permt_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_s_local_addr_chg_date             IN     DATE        DEFAULT NULL,
    x_s_default_status                  IN     VARCHAR2    DEFAULT NULL,
    x_s_signature_code                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_pnote_batch_id                    IN     VARCHAR2    DEFAULT NULL,
    x_pnote_ack_date                    IN     DATE        DEFAULT NULL,
    x_pnote_mpn_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_elec_mpn_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_borr_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_stud_sign_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_borr_credit_auth_code             IN     VARCHAR2    DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_interest_rebate_percent_num       IN     NUMBER      DEFAULT NULL,
    x_cps_trans_num                     IN     NUMBER      DEFAULT NULL,
    x_atd_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_crdt_decision_status              IN     VARCHAR2    DEFAULT NULL,
    x_note_message                      IN     VARCHAR2    DEFAULT NULL,
    x_book_loan_amt                     IN     NUMBER      DEFAULT NULL,
    x_book_loan_amt_date                IN     DATE        DEFAULT NULL,
    x_pymt_servicer_amt                 IN     NUMBER      DEFAULT NULL,
    x_pymt_servicer_date                IN     DATE        DEFAULT NULL,
    x_external_loan_id_txt              IN     VARCHAR2  ,
    x_deferment_request_code            IN     VARCHAR2  ,
    x_eft_authorization_code            IN     VARCHAR2  ,
    x_requested_loan_amt                IN     NUMBER    ,
    x_actual_record_type_code           IN     VARCHAR2  ,
    x_reinstatement_amt                 IN     NUMBER    ,
    x_school_use_txt                    IN     VARCHAR2  ,
    x_lender_use_txt                    IN     VARCHAR2  ,
    x_guarantor_use_txt                 IN     VARCHAR2  ,
    x_fls_approved_amt                  IN     NUMBER    ,
    x_flu_approved_amt                  IN     NUMBER    ,
    x_flp_approved_amt                  IN     NUMBER    ,
    x_alt_approved_amt                  IN     NUMBER    ,
    x_loan_app_form_code                IN     VARCHAR2  ,
    x_override_grade_level_code         IN     VARCHAR2  ,
    x_b_alien_reg_num_txt               IN     VARCHAR2  ,
    x_esign_src_typ_cd                  IN     VARCHAR2  ,
    x_acad_begin_date                   IN     DATE      ,
    x_acad_end_date                     IN     DATE

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_origination_id,
      x_loan_id,
      x_sch_cert_date,
      x_orig_status_flag,
      x_orig_batch_id,
      x_orig_batch_date,
      x_chg_batch_id,
      x_orig_ack_date,
      x_credit_override,
      x_credit_decision_date,
      x_req_serial_loan_code,
      x_act_serial_loan_code,
      x_pnote_delivery_code,
      x_pnote_status,
      x_pnote_status_date,
      x_pnote_id,
      x_pnote_print_ind,
      x_pnote_accept_amt,
      x_pnote_accept_date,
      x_unsub_elig_for_heal,
      x_disclosure_print_ind,
      x_orig_fee_perct,
      x_borw_confirm_ind,
      x_borw_interest_ind,
      x_borw_outstd_loan_code,
      x_unsub_elig_for_depnt,
      x_guarantee_amt,
      x_guarantee_date,
      x_guarnt_amt_redn_code,
      x_guarnt_status_code,
      x_guarnt_status_date,
      x_lend_apprv_denied_code,
      x_lend_apprv_denied_date,
      x_lend_status_code,
      x_lend_status_date,
      x_guarnt_adj_ind,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_borw_lender_id,
      x_duns_borw_lender_id,
      x_guarantor_id,
      x_duns_guarnt_id,
      x_prc_type_code,
      x_cl_seq_number,
      x_last_resort_lender,
      x_lender_id,
      x_duns_lender_id,
      x_lend_non_ed_brc_id,
      x_recipient_id,
      x_recipient_type,
      x_duns_recip_id,
      x_recip_non_ed_brc_id,
      x_rec_type_ind,
      x_cl_loan_type,
      x_cl_rec_status,
      x_cl_rec_status_last_update,
      x_alt_prog_type_code,
      x_alt_appl_ver_code,
      x_mpn_confirm_code,
      x_resp_to_orig_code,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_appl_send_error_codes,
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
      x_p_ssn_chg_date,
      x_p_dob_chg_date,
      x_p_permt_addr_chg_date,
      x_p_default_status,
      x_p_signature_code,
      x_p_signature_date,
      x_s_ssn_chg_date,
      x_s_dob_chg_date,
      x_s_permt_addr_chg_date,
      x_s_local_addr_chg_date,
      x_s_default_status,
      x_s_signature_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_pnote_batch_id,
      x_pnote_ack_date,
      x_pnote_mpn_ind,
      x_elec_mpn_ind,
      x_borr_sign_ind,
      x_stud_sign_ind,
      x_borr_credit_auth_code,
      x_relationship_cd,
      x_interest_rebate_percent_num,
      x_cps_trans_num,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_crdt_decision_status,
      x_note_message,
      x_book_loan_amt,
      x_book_loan_amt_date,
      x_pymt_servicer_amt,
      x_pymt_servicer_date,
      x_external_loan_id_txt        ,
      x_deferment_request_code      ,
      x_eft_authorization_code      ,
      x_requested_loan_amt          ,
      x_actual_record_type_code     ,
      x_reinstatement_amt           ,
      x_school_use_txt              ,
      x_lender_use_txt              ,
      x_guarantor_use_txt           ,
      x_fls_approved_amt            ,
      x_flu_approved_amt            ,
      x_flp_approved_amt            ,
      x_alt_approved_amt            ,
      x_loan_app_form_code          ,
      x_override_grade_level_code   ,
      x_b_alien_reg_num_txt           ,
      x_esign_src_typ_cd              ,
      x_acad_begin_date               ,
      x_acad_end_date

    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.origination_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      check_uk_child_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.origination_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_uk_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


PROCEDURE after_dml(
    p_action IN VARCHAR2,
    x_rowid  IN VARCHAR2
   ) AS
  /*
  ||  Created By : viramali
  ||  Created On : 12-MAY-2001
  ||  Purpose : to call the table handler for igf_sl_pnote_stat_h
  ||  to insert records
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  (reverse chronological order - newest change first)
  */

   l_pnote_stat_h_rowid     VARCHAR2(30) := NULL;
   l_dlpnh_id               igf_sl_pnote_stat_h.dlpnh_id%TYPE := NULL;

BEGIN
  l_rowid := x_rowid;
  IF (p_action = 'UPDATE') THEN
   -- Call all the procedures related to After Update.
    AfterRowInsertUpdateDelete1
    (
      p_inserting => FALSE,
      p_updating  => TRUE ,
      p_deleting  => FALSE
    );
  END IF;
  l_rowid := NULL;
  -- Incase of update, if the promissory note status is not changed, return
  IF (p_action = 'UPDATE') AND ( new_references.pnote_status = old_references.pnote_status ) THEN

   null;
  ELSE
   igf_sl_pnote_stat_h_pkg.insert_row (
      x_mode              =>        'R',
      x_rowid             =>        l_pnote_stat_h_rowid,
      x_dlpnh_id          =>        l_dlpnh_id,
      x_loan_id           =>        new_references.loan_id,
      x_pnote_status      =>        new_references.pnote_status,
      x_pnote_status_date =>        SYSDATE
     );
  END IF;
END after_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_chg_batch_id                      IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_duns_borw_lender_id               IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_appl_send_error_codes             IN     VARCHAR2,
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
    x_p_ssn_chg_date                    IN     DATE,
    x_p_dob_chg_date                    IN     DATE,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_default_status                  IN     VARCHAR2,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_ssn_chg_date                    IN     DATE,
    x_s_dob_chg_date                    IN     DATE,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_local_addr_chg_date             IN     DATE,
    x_s_default_status                  IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2,
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_cps_trans_num                     IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE  ,
    x_external_loan_id_txt              IN     VARCHAR2  ,
    x_deferment_request_code            IN     VARCHAR2  ,
    x_eft_authorization_code            IN     VARCHAR2  ,
    x_requested_loan_amt                IN     NUMBER    ,
    x_actual_record_type_code           IN     VARCHAR2  ,
    x_reinstatement_amt                 IN     NUMBER    ,
    x_school_use_txt                    IN     VARCHAR2  ,
    x_lender_use_txt                    IN     VARCHAR2  ,
    x_guarantor_use_txt                 IN     VARCHAR2  ,
    x_fls_approved_amt                  IN     NUMBER    ,
    x_flu_approved_amt                  IN     NUMBER    ,
    x_flp_approved_amt                  IN     NUMBER    ,
    x_alt_approved_amt                  IN     NUMBER    ,
    x_loan_app_form_code                IN     VARCHAR2  ,
    x_override_grade_level_code         IN     VARCHAR2  ,
    x_b_alien_reg_num_txt               IN     VARCHAR2  ,
    x_esign_src_typ_cd                  IN     VARCHAR2  ,
    x_acad_begin_date                   IN     DATE      ,
    x_acad_end_date                     IN     DATE
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||   viramali      12-MAY-01        added call to after_dml
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE    origination_id                    = x_origination_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_sl_lor_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    SELECT igf_sl_lor_s.nextval INTO x_origination_id FROM DUAL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_origination_id                    => x_origination_id,
      x_loan_id                           => x_loan_id,
      x_sch_cert_date                     => x_sch_cert_date,
      x_orig_status_flag                  => x_orig_status_flag,
      x_orig_batch_id                     => x_orig_batch_id,
      x_orig_batch_date                   => x_orig_batch_date,
      x_chg_batch_id                      => x_chg_batch_id,
      x_orig_ack_date                     => x_orig_ack_date,
      x_credit_override                   => x_credit_override,
      x_credit_decision_date              => x_credit_decision_date,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_pnote_status                      => x_pnote_status,
      x_pnote_status_date                 => x_pnote_status_date,
      x_pnote_id                          => x_pnote_id,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_accept_amt                  => x_pnote_accept_amt,
      x_pnote_accept_date                 => x_pnote_accept_date,
      x_unsub_elig_for_heal               => x_unsub_elig_for_heal,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_orig_fee_perct                    => x_orig_fee_perct,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_borw_outstd_loan_code             => x_borw_outstd_loan_code,
      x_unsub_elig_for_depnt              => x_unsub_elig_for_depnt,
      x_guarantee_amt                     => x_guarantee_amt,
      x_guarantee_date                    => x_guarantee_date,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_lend_status_code                  => x_lend_status_code,
      x_lend_status_date                  => x_lend_status_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_borw_lender_id                    => x_borw_lender_id,
      x_duns_borw_lender_id               => x_duns_borw_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_prc_type_code                     => x_prc_type_code,
      x_cl_seq_number                     => x_cl_seq_number,
      x_last_resort_lender                => x_last_resort_lender,
      x_lender_id                         => x_lender_id,
      x_duns_lender_id                    => x_duns_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_duns_recip_id                     => x_duns_recip_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_rec_type_ind                      => x_rec_type_ind,
      x_cl_loan_type                      => x_cl_loan_type,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_mpn_confirm_code                  => x_mpn_confirm_code,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_appl_send_error_codes             => x_appl_send_error_codes,
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
      x_p_ssn_chg_date                    => x_p_ssn_chg_date,
      x_p_dob_chg_date                    => x_p_dob_chg_date,
      x_p_permt_addr_chg_date             => x_p_permt_addr_chg_date,
      x_p_default_status                  => x_p_default_status,
      x_p_signature_code                  => x_p_signature_code,
      x_p_signature_date                  => x_p_signature_date,
      x_s_ssn_chg_date                    => x_s_ssn_chg_date,
      x_s_dob_chg_date                    => x_s_dob_chg_date,
      x_s_permt_addr_chg_date             => x_s_permt_addr_chg_date,
      x_s_local_addr_chg_date             => x_s_local_addr_chg_date,
      x_s_default_status                  => x_s_default_status,
      x_s_signature_code                  => x_s_signature_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_pnote_batch_id                    => x_pnote_batch_id,
      x_pnote_ack_date                    => x_pnote_ack_date,
      x_pnote_mpn_ind                     => x_pnote_mpn_ind,
      x_elec_mpn_ind                      => x_elec_mpn_ind,
      x_borr_sign_ind                     => x_borr_sign_ind,
      x_stud_sign_ind                     => x_stud_sign_ind,
      x_borr_credit_auth_code             => x_borr_credit_auth_code,
      x_relationship_cd                   => x_relationship_cd,
      x_interest_rebate_percent_num       => x_interest_rebate_percent_num,
      x_cps_trans_num                     => x_cps_trans_num,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_crdt_decision_status              => x_crdt_decision_status,
      x_note_message                      => x_note_message,
      x_book_loan_amt                     => x_book_loan_amt,
      x_book_loan_amt_date                => x_book_loan_amt_date,
      x_pymt_servicer_amt                 => x_pymt_servicer_amt,
      x_pymt_servicer_date                => x_pymt_servicer_date,
      x_external_loan_id_txt              => x_external_loan_id_txt        ,
      x_deferment_request_code            => x_deferment_request_code      ,
      x_eft_authorization_code            => x_eft_authorization_code      ,
      x_requested_loan_amt                => x_requested_loan_amt          ,
      x_actual_record_type_code           => x_actual_record_type_code     ,
      x_reinstatement_amt                 => x_reinstatement_amt           ,
      x_school_use_txt                    => x_school_use_txt              ,
      x_lender_use_txt                    => x_lender_use_txt              ,
      x_guarantor_use_txt                 => x_guarantor_use_txt           ,
      x_fls_approved_amt                  => x_fls_approved_amt            ,
      x_flu_approved_amt                  => x_flu_approved_amt            ,
      x_flp_approved_amt                  => x_flp_approved_amt            ,
      x_alt_approved_amt                  => x_alt_approved_amt            ,
      x_loan_app_form_code                => x_loan_app_form_code          ,
      x_override_grade_level_code         => x_override_grade_level_code   ,
      x_b_alien_reg_num_txt               => x_b_alien_reg_num_txt         ,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd            ,
      x_acad_begin_date                   => x_acad_begin_date             ,
      x_acad_end_date                     => x_acad_end_date

    );

    INSERT INTO igf_sl_lor_all(
      origination_id,
      loan_id,
      sch_cert_date,
      orig_status_flag,
      orig_batch_id,
      orig_batch_date,
      orig_ack_date,
      credit_override,
      credit_decision_date,
      req_serial_loan_code,
      act_serial_loan_code,
      pnote_delivery_code,
      pnote_status,
      pnote_status_date,
      pnote_id,
      pnote_print_ind,
      pnote_accept_amt,
      pnote_accept_date,
      unsub_elig_for_heal,
      disclosure_print_ind,
      orig_fee_perct,
      borw_confirm_ind,
      borw_interest_ind,
      borw_outstd_loan_code,
      unsub_elig_for_depnt,
      guarantee_amt,
      guarantee_date,
      guarnt_amt_redn_code,
      guarnt_status_code,
      guarnt_status_date,
      lend_status_code,
      lend_status_date,
      guarnt_adj_ind,
      grade_level_code,
      enrollment_code,
      anticip_compl_date,
      prc_type_code,
      cl_seq_number,
      last_resort_lender,
      rec_type_ind,
      cl_loan_type,
      alt_prog_type_code,
      alt_appl_ver_code,
      resp_to_orig_code,
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
      p_permt_addr_chg_date,
      p_default_status,
      p_signature_code,
      p_signature_date,
      s_permt_addr_chg_date,
      s_default_status,
      s_signature_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      org_id,
      pnote_batch_id,
      pnote_ack_date,
      pnote_mpn_ind,
      elec_mpn_ind,
      borr_sign_ind,
      stud_sign_ind,
      borr_credit_auth_code,
      relationship_cd,
      interest_rebate_percent_num,
      cps_trans_num,
      atd_entity_id_txt,
      rep_entity_id_txt,
      crdt_decision_status,
      note_message,
      book_loan_amt,
      book_loan_amt_date,
      pymt_servicer_amt,
      pymt_servicer_date,
      external_loan_id_txt        ,
      deferment_request_code      ,
      eft_authorization_code      ,
      requested_loan_amt          ,
      actual_record_type_code     ,
      reinstatement_amt           ,
      school_use_txt              ,
      lender_use_txt              ,
      guarantor_use_txt           ,
      fls_approved_amt            ,
      flu_approved_amt            ,
      flp_approved_amt            ,
      alt_approved_amt            ,
      loan_app_form_code          ,
      override_grade_level_code   ,
      appl_loan_phase_code        ,
      appl_loan_phase_code_chg    ,
      cl_rec_status               ,
      cl_rec_status_last_update   ,
      mpn_confirm_code            ,
      lend_apprv_denied_code      ,
      lend_apprv_denied_date      ,
      b_alien_reg_num_txt         ,
      esign_src_typ_cd            ,
      acad_begin_date             ,
      acad_end_date

    ) VALUES (
      new_references.origination_id,
      new_references.loan_id,
      new_references.sch_cert_date,
      new_references.orig_status_flag,
      new_references.orig_batch_id,
      new_references.orig_batch_date,
      new_references.orig_ack_date,
      new_references.credit_override,
      new_references.credit_decision_date,
      new_references.req_serial_loan_code,
      new_references.act_serial_loan_code,
      new_references.pnote_delivery_code,
      new_references.pnote_status,
      new_references.pnote_status_date,
      new_references.pnote_id,
      new_references.pnote_print_ind,
      new_references.pnote_accept_amt,
      new_references.pnote_accept_date,
      new_references.unsub_elig_for_heal,
      new_references.disclosure_print_ind,
      new_references.orig_fee_perct,
      new_references.borw_confirm_ind,
      new_references.borw_interest_ind,
      new_references.borw_outstd_loan_code,
      new_references.unsub_elig_for_depnt,
      new_references.guarantee_amt,
      new_references.guarantee_date,
      new_references.guarnt_amt_redn_code,
      new_references.guarnt_status_code,
      new_references.guarnt_status_date,
      new_references.lend_status_code,
      new_references.lend_status_date,
      new_references.guarnt_adj_ind,
      new_references.grade_level_code,
      new_references.enrollment_code,
      new_references.anticip_compl_date,
      new_references.prc_type_code,
      new_references.cl_seq_number,
      new_references.last_resort_lender,
      new_references.rec_type_ind,
      new_references.cl_loan_type,
      new_references.alt_prog_type_code,
      new_references.alt_appl_ver_code,
      new_references.resp_to_orig_code,
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
      new_references.p_permt_addr_chg_date,
      new_references.p_default_status,
      new_references.p_signature_code,
      new_references.p_signature_date,
      new_references.s_permt_addr_chg_date,
      new_references.s_default_status,
      new_references.s_signature_code,
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
      new_references.pnote_batch_id,
      new_references.pnote_ack_date,
      new_references.pnote_mpn_ind,
      new_references.elec_mpn_ind,
      new_references.borr_sign_ind,
      new_references.stud_sign_ind,
      new_references.borr_credit_auth_code,
      new_references.relationship_cd,
      new_references.interest_rebate_percent_num,
      new_references.cps_trans_num,
      new_references.atd_entity_id_txt,
      new_references.rep_entity_id_txt,
      new_references.crdt_decision_status,
      new_references.note_message,
      new_references.book_loan_amt,
      new_references.book_loan_amt_date,
      new_references.pymt_servicer_amt,
      new_references.pymt_servicer_date,
      new_references.external_loan_id_txt     ,
      new_references.deferment_request_code   ,
      new_references.eft_authorization_code   ,
      new_references.requested_loan_amt       ,
      new_references.actual_record_type_code  ,
      new_references.reinstatement_amt        ,
      new_references.school_use_txt           ,
      new_references.lender_use_txt           ,
      new_references.guarantor_use_txt        ,
      new_references.fls_approved_amt         ,
      new_references.flu_approved_amt         ,
      new_references.flp_approved_amt         ,
      new_references.alt_approved_amt         ,
      new_references.loan_app_form_code       ,
      new_references.override_grade_level_code,
      new_references.appl_loan_phase_code     ,
      new_references.appl_loan_phase_code_chg ,
      new_references.cl_rec_status            ,
      new_references.cl_rec_status_last_update,
      new_references.mpn_confirm_code         ,
      new_references.lend_apprv_denied_code   ,
      new_references.lend_apprv_denied_date   ,
      new_references.b_alien_reg_num_txt      ,
      new_references.esign_src_typ_cd         ,
      new_references.acad_begin_date          ,
      new_references.acad_end_date
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml(
      p_action   =>  'INSERT',
      x_rowid    => x_rowid
     );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_origination_id                    IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_chg_batch_id                      IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_duns_borw_lender_id               IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_appl_send_error_codes             IN     VARCHAR2,
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
    x_p_ssn_chg_date                    IN     DATE,
    x_p_dob_chg_date                    IN     DATE,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_default_status                  IN     VARCHAR2,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_ssn_chg_date                    IN     DATE,
    x_s_dob_chg_date                    IN     DATE,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_local_addr_chg_date             IN     DATE,
    x_s_default_status                  IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2,
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_cps_trans_num                     IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE ,
    x_external_loan_id_txt              IN     VARCHAR2  ,
    x_deferment_request_code            IN     VARCHAR2  ,
    x_eft_authorization_code            IN     VARCHAR2  ,
    x_requested_loan_amt                IN     NUMBER    ,
    x_actual_record_type_code           IN     VARCHAR2  ,
    x_reinstatement_amt                 IN     NUMBER    ,
    x_school_use_txt                    IN     VARCHAR2  ,
    x_lender_use_txt                    IN     VARCHAR2  ,
    x_guarantor_use_txt                 IN     VARCHAR2  ,
    x_fls_approved_amt                  IN     NUMBER    ,
    x_flu_approved_amt                  IN     NUMBER    ,
    x_flp_approved_amt                  IN     NUMBER    ,
    x_alt_approved_amt                  IN     NUMBER    ,
    x_loan_app_form_code                IN     VARCHAR2  ,
    x_override_grade_level_code         IN     VARCHAR2  ,
    x_b_alien_reg_num_txt               IN     VARCHAR2  ,
    x_esign_src_typ_cd                  IN     VARCHAR2  ,
    x_acad_begin_date                   IN     DATE     ,
    x_acad_end_date                     IN     DATE
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||veramach        23-SEP-2003     Bug 3104228: Removed checks for lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
  ||                                     cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
  ||                                     p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
  ||                                     chg_batch_id,appl_send_error_codes from lock_row
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        loan_id,
        sch_cert_date,
        orig_status_flag,
        orig_batch_id,
        orig_batch_date,
        orig_ack_date,
        credit_override,
        credit_decision_date,
        req_serial_loan_code,
        act_serial_loan_code,
        pnote_delivery_code,
        pnote_status,
        pnote_status_date,
        pnote_id,
        pnote_print_ind,
        pnote_accept_amt,
        pnote_accept_date,
        unsub_elig_for_heal,
        disclosure_print_ind,
        orig_fee_perct,
        borw_confirm_ind,
        borw_interest_ind,
        borw_outstd_loan_code,
        unsub_elig_for_depnt,
        guarantee_amt,
        guarantee_date,
        guarnt_amt_redn_code,
        guarnt_status_code,
        guarnt_status_date,
        lend_status_code,
        lend_status_date,
        guarnt_adj_ind,
        grade_level_code,
        enrollment_code,
        anticip_compl_date,
        prc_type_code,
        cl_seq_number,
        last_resort_lender,
        rec_type_ind,
        cl_loan_type,
        alt_prog_type_code,
        alt_appl_ver_code,
        resp_to_orig_code,
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
        p_permt_addr_chg_date,
        p_default_status,
        p_signature_code,
        p_signature_date,
        s_permt_addr_chg_date,
        s_default_status,
        s_signature_code,
        org_id,
        pnote_batch_id,
        pnote_ack_date,
        pnote_mpn_ind,
        elec_mpn_ind,
        borr_sign_ind,
        stud_sign_ind,
        borr_credit_auth_code,
        relationship_cd,
        interest_rebate_percent_num,
        cps_trans_num,
        atd_entity_id_txt,
        rep_entity_id_txt,
        crdt_decision_status,
        note_message,
        book_loan_amt,
        book_loan_amt_date,
        pymt_servicer_amt,
        pymt_servicer_date,
        external_loan_id_txt        ,
        deferment_request_code      ,
        eft_authorization_code      ,
        requested_loan_amt          ,
        actual_record_type_code     ,
        reinstatement_amt           ,
        school_use_txt              ,
        lender_use_txt              ,
        guarantor_use_txt           ,
        fls_approved_amt            ,
        flu_approved_amt            ,
        flp_approved_amt            ,
        alt_approved_amt            ,
        loan_app_form_code          ,
        override_grade_level_code   ,
        appl_loan_phase_code        ,
        appl_loan_phase_code_chg    ,
        cl_rec_status               ,
        cl_rec_status_last_update   ,
        mpn_confirm_code            ,
        lend_apprv_denied_code      ,
        lend_apprv_denied_date      ,
        b_alien_reg_num_txt         ,
        esign_src_typ_cd            ,
	acad_begin_date             ,
	acad_end_date
      FROM  igf_sl_lor_all
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
        AND ((tlinfo.sch_cert_date = x_sch_cert_date) OR ((tlinfo.sch_cert_date IS NULL) AND (X_sch_cert_date IS NULL)))
        AND ((tlinfo.orig_status_flag = x_orig_status_flag) OR ((tlinfo.orig_status_flag IS NULL) AND (X_orig_status_flag IS NULL)))
        AND ((tlinfo.orig_batch_id = x_orig_batch_id) OR ((tlinfo.orig_batch_id IS NULL) AND (X_orig_batch_id IS NULL)))
        AND ((TRUNC(tlinfo.orig_batch_date) = TRUNC(x_orig_batch_date)) OR ((tlinfo.orig_batch_date IS NULL) AND (X_orig_batch_date IS NULL)))
        AND ((TRUNC(tlinfo.orig_ack_date) = TRUNC(x_orig_ack_date)) OR ((tlinfo.orig_ack_date IS NULL) AND (X_orig_ack_date IS NULL)))
        AND ((tlinfo.credit_override = x_credit_override) OR ((tlinfo.credit_override IS NULL) AND (X_credit_override IS NULL)))
        AND ((TRUNC(tlinfo.credit_decision_date) = TRUNC(x_credit_decision_date)) OR ((tlinfo.credit_decision_date IS NULL) AND (X_credit_decision_date IS NULL)))
        AND ((tlinfo.req_serial_loan_code = x_req_serial_loan_code) OR ((tlinfo.req_serial_loan_code IS NULL) AND (X_req_serial_loan_code IS NULL)))
        AND ((tlinfo.act_serial_loan_code = x_act_serial_loan_code) OR ((tlinfo.act_serial_loan_code IS NULL) AND (X_act_serial_loan_code IS NULL)))
        AND ((tlinfo.pnote_delivery_code = x_pnote_delivery_code) OR ((tlinfo.pnote_delivery_code IS NULL) AND (X_pnote_delivery_code IS NULL)))
        AND ((tlinfo.pnote_status = x_pnote_status) OR ((tlinfo.pnote_status IS NULL) AND (X_pnote_status IS NULL)))
        AND ((TRUNC(tlinfo.pnote_status_date) = TRUNC(x_pnote_status_date)) OR ((tlinfo.pnote_status_date IS NULL) AND (X_pnote_status_date IS NULL)))
        AND ((tlinfo.pnote_id = x_pnote_id) OR ((tlinfo.pnote_id IS NULL) AND (X_pnote_id IS NULL)))
        AND ((tlinfo.pnote_print_ind = x_pnote_print_ind) OR ((tlinfo.pnote_print_ind IS NULL) AND (X_pnote_print_ind IS NULL)))
        AND ((tlinfo.pnote_accept_amt = x_pnote_accept_amt) OR ((tlinfo.pnote_accept_amt IS NULL) AND (X_pnote_accept_amt IS NULL)))
        AND ((TRUNC(tlinfo.pnote_accept_date) = TRUNC(x_pnote_accept_date)) OR ((tlinfo.pnote_accept_date IS NULL) AND (X_pnote_accept_date IS NULL)))
        AND ((tlinfo.unsub_elig_for_heal = x_unsub_elig_for_heal) OR ((tlinfo.unsub_elig_for_heal IS NULL) AND (X_unsub_elig_for_heal IS NULL)))
        AND ((tlinfo.disclosure_print_ind = x_disclosure_print_ind) OR ((tlinfo.disclosure_print_ind IS NULL) AND (X_disclosure_print_ind IS NULL)))
        AND ((tlinfo.orig_fee_perct = x_orig_fee_perct) OR ((tlinfo.orig_fee_perct IS NULL) AND (X_orig_fee_perct IS NULL)))
        AND ((tlinfo.borw_confirm_ind = x_borw_confirm_ind) OR ((tlinfo.borw_confirm_ind IS NULL) AND (X_borw_confirm_ind IS NULL)))
        AND ((tlinfo.borw_interest_ind = x_borw_interest_ind) OR ((tlinfo.borw_interest_ind IS NULL) AND (X_borw_interest_ind IS NULL)))
        AND ((tlinfo.borw_outstd_loan_code = x_borw_outstd_loan_code) OR ((tlinfo.borw_outstd_loan_code IS NULL) AND (X_borw_outstd_loan_code IS NULL)))
        AND ((tlinfo.unsub_elig_for_depnt = x_unsub_elig_for_depnt) OR ((tlinfo.unsub_elig_for_depnt IS NULL) AND (X_unsub_elig_for_depnt IS NULL)))
        AND ((tlinfo.guarantee_amt = x_guarantee_amt) OR ((tlinfo.guarantee_amt IS NULL) AND (X_guarantee_amt IS NULL)))
        AND ((TRUNC(tlinfo.guarantee_date) = TRUNC(x_guarantee_date)) OR ((tlinfo.guarantee_date IS NULL) AND (X_guarantee_date IS NULL)))
        AND ((tlinfo.guarnt_amt_redn_code = x_guarnt_amt_redn_code) OR ((tlinfo.guarnt_amt_redn_code IS NULL) AND (X_guarnt_amt_redn_code IS NULL)))
        AND ((tlinfo.guarnt_status_code = x_guarnt_status_code) OR ((tlinfo.guarnt_status_code IS NULL) AND (X_guarnt_status_code IS NULL)))
        AND ((TRUNC(tlinfo.guarnt_status_date) = TRUNC(x_guarnt_status_date)) OR ((tlinfo.guarnt_status_date IS NULL) AND (X_guarnt_status_date IS NULL)))
        AND ((tlinfo.lend_status_code = x_lend_status_code) OR ((tlinfo.lend_status_code IS NULL) AND (X_lend_status_code IS NULL)))
        AND ((TRUNC(tlinfo.lend_status_date) = TRUNC(x_lend_status_date)) OR ((tlinfo.lend_status_date IS NULL) AND (X_lend_status_date IS NULL)))
        AND ((tlinfo.guarnt_adj_ind = x_guarnt_adj_ind) OR ((tlinfo.guarnt_adj_ind IS NULL) AND (X_guarnt_adj_ind IS NULL)))
        AND ((tlinfo.grade_level_code = x_grade_level_code) OR ((tlinfo.grade_level_code IS NULL) AND (X_grade_level_code IS NULL)))
        AND ((tlinfo.enrollment_code = x_enrollment_code) OR ((tlinfo.enrollment_code IS NULL) AND (X_enrollment_code IS NULL)))
        AND ((tlinfo.anticip_compl_date = x_anticip_compl_date) OR ((tlinfo.anticip_compl_date IS NULL) AND (X_anticip_compl_date IS NULL)))
        AND ((tlinfo.prc_type_code = x_prc_type_code) OR ((tlinfo.prc_type_code IS NULL) AND (X_prc_type_code IS NULL)))
        AND ((tlinfo.cl_seq_number = x_cl_seq_number) OR ((tlinfo.cl_seq_number IS NULL) AND (X_cl_seq_number IS NULL)))
        AND ((tlinfo.last_resort_lender = x_last_resort_lender) OR ((tlinfo.last_resort_lender IS NULL) AND (X_last_resort_lender IS NULL)))
        AND ((tlinfo.rec_type_ind = x_rec_type_ind) OR ((tlinfo.rec_type_ind IS NULL) AND (X_rec_type_ind IS NULL)))
        AND ((tlinfo.cl_loan_type = x_cl_loan_type) OR ((tlinfo.cl_loan_type IS NULL) AND (X_cl_loan_type IS NULL)))
        AND ((tlinfo.alt_prog_type_code = x_alt_prog_type_code) OR ((tlinfo.alt_prog_type_code IS NULL) AND (X_alt_prog_type_code IS NULL)))
        AND ((tlinfo.alt_appl_ver_code = x_alt_appl_ver_code) OR ((tlinfo.alt_appl_ver_code IS NULL) AND (X_alt_appl_ver_code IS NULL)))
        AND ((tlinfo.resp_to_orig_code = x_resp_to_orig_code) OR ((tlinfo.resp_to_orig_code IS NULL) AND (X_resp_to_orig_code IS NULL)))
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
        AND ((TRUNC(tlinfo.p_permt_addr_chg_date) = TRUNC(x_p_permt_addr_chg_date)) OR ((tlinfo.p_permt_addr_chg_date IS NULL) AND (X_p_permt_addr_chg_date IS NULL)))
        AND ((tlinfo.p_default_status = x_p_default_status) OR ((tlinfo.p_default_status IS NULL) AND (X_p_default_status IS NULL)))
        AND ((tlinfo.p_signature_code = x_p_signature_code) OR ((tlinfo.p_signature_code IS NULL) AND (X_p_signature_code IS NULL)))
        AND ((TRUNC(tlinfo.p_signature_date) = TRUNC(x_p_signature_date)) OR ((tlinfo.p_signature_date IS NULL) AND (X_p_signature_date IS NULL)))
        AND ((TRUNC(tlinfo.s_permt_addr_chg_date) = TRUNC(x_s_permt_addr_chg_date)) OR ((tlinfo.s_permt_addr_chg_date IS NULL) AND (X_s_permt_addr_chg_date IS NULL)))
        AND ((tlinfo.s_default_status = x_s_default_status) OR ((tlinfo.s_default_status IS NULL) AND (X_s_default_status IS NULL)))
        AND ((tlinfo.s_signature_code = x_s_signature_code) OR ((tlinfo.s_signature_code IS NULL) AND (X_s_signature_code IS NULL)))
        AND ((tlinfo.pnote_batch_id = x_pnote_batch_id) OR ((tlinfo.pnote_batch_id IS NULL) AND (X_pnote_batch_id IS NULL)))
        AND ((TRUNC(tlinfo.pnote_ack_date) = TRUNC(x_pnote_ack_date)) OR ((tlinfo.pnote_ack_date IS NULL) AND (X_pnote_ack_date IS NULL)))
        AND ((tlinfo.pnote_mpn_ind = x_pnote_mpn_ind) OR ((tlinfo.pnote_mpn_ind IS NULL) AND (X_pnote_mpn_ind IS NULL)))
        AND ((tlinfo.elec_mpn_ind = x_elec_mpn_ind) OR ((tlinfo.elec_mpn_ind IS NULL) AND (X_elec_mpn_ind IS NULL)))
        AND ((tlinfo.borr_sign_ind = x_borr_sign_ind) OR ((tlinfo.borr_sign_ind IS NULL) AND (X_borr_sign_ind IS NULL)))
        AND ((tlinfo.stud_sign_ind = x_stud_sign_ind) OR ((tlinfo.stud_sign_ind IS NULL) AND (X_stud_sign_ind IS NULL)))
        AND ((tlinfo.borr_credit_auth_code = x_borr_credit_auth_code) OR ((tlinfo.borr_credit_auth_code IS NULL) AND (X_borr_credit_auth_code IS NULL)))
        AND ((tlinfo.relationship_cd = x_relationship_cd) OR ((tlinfo.relationship_cd IS NULL) AND (X_relationship_cd IS NULL)))
        AND ((tlinfo.interest_rebate_percent_num = x_interest_rebate_percent_num) OR ((tlinfo.interest_rebate_percent_num IS NULL) AND (X_interest_rebate_percent_num IS NULL)))
        AND ((tlinfo.cps_trans_num = x_cps_trans_num) OR ((tlinfo.cps_trans_num IS NULL) AND (x_cps_trans_num IS NULL)))
        AND ((tlinfo.atd_entity_id_txt = x_atd_entity_id_txt) OR ((tlinfo.atd_entity_id_txt IS NULL) AND (X_atd_entity_id_txt IS NULL)))
        AND ((tlinfo.rep_entity_id_txt = x_rep_entity_id_txt) OR ((tlinfo.rep_entity_id_txt IS NULL) AND (X_rep_entity_id_txt IS NULL)))
        AND ((tlinfo.crdt_decision_status = x_crdt_decision_status) OR ((tlinfo.crdt_decision_status IS NULL) AND (X_crdt_decision_status IS NULL)))
        AND ((tlinfo.note_message = x_note_message) OR ((tlinfo.note_message IS NULL) AND (X_note_message IS NULL)))
        AND ((tlinfo.book_loan_amt = x_book_loan_amt) OR ((tlinfo.book_loan_amt IS NULL) AND (X_book_loan_amt IS NULL)))
        AND ((tlinfo.book_loan_amt_date = x_book_loan_amt_date) OR ((tlinfo.book_loan_amt_date IS NULL) AND (X_book_loan_amt_date IS NULL)))
        AND ((tlinfo.pymt_servicer_amt = x_pymt_servicer_amt) OR ((tlinfo.pymt_servicer_amt IS NULL) AND (X_pymt_servicer_amt IS NULL)))
        AND ((TRUNC(tlinfo.pymt_servicer_date) = TRUNC(x_pymt_servicer_date)) OR ((tlinfo.pymt_servicer_date IS NULL) AND (X_pymt_servicer_date IS NULL)))
        AND ((tlinfo.external_loan_id_txt = x_external_loan_id_txt) OR ((tlinfo.external_loan_id_txt IS NULL) AND (x_external_loan_id_txt IS NULL)))
        AND ((tlinfo.deferment_request_code = x_deferment_request_code) OR ((tlinfo.deferment_request_code IS NULL) AND (x_deferment_request_code IS NULL)))
        AND ((tlinfo.eft_authorization_code = x_eft_authorization_code) OR ((tlinfo.eft_authorization_code IS NULL) AND (x_eft_authorization_code IS NULL)))
        AND ((tlinfo.requested_loan_amt = x_requested_loan_amt) OR ((tlinfo.requested_loan_amt IS NULL) AND (x_requested_loan_amt IS NULL)))
        AND ((tlinfo.actual_record_type_code = x_actual_record_type_code) OR ((tlinfo.actual_record_type_code IS NULL) AND (x_actual_record_type_code IS NULL)))
        AND ((tlinfo.reinstatement_amt = x_reinstatement_amt) OR ((tlinfo.reinstatement_amt IS NULL) AND (x_reinstatement_amt IS NULL)))
        AND ((tlinfo.school_use_txt = x_school_use_txt) OR ((tlinfo.school_use_txt IS NULL) AND (x_school_use_txt IS NULL)))
        AND ((tlinfo.lender_use_txt = x_lender_use_txt) OR ((tlinfo.lender_use_txt IS NULL) AND (x_lender_use_txt IS NULL)))
        AND ((tlinfo.guarantor_use_txt = x_guarantor_use_txt) OR ((tlinfo.guarantor_use_txt IS NULL) AND (x_guarantor_use_txt IS NULL)))
        AND ((tlinfo.fls_approved_amt = x_fls_approved_amt) OR ((tlinfo.fls_approved_amt IS NULL) AND (x_fls_approved_amt IS NULL)))
        AND ((tlinfo.flu_approved_amt = x_flu_approved_amt) OR ((tlinfo.flu_approved_amt IS NULL) AND (x_flu_approved_amt IS NULL)))
        AND ((tlinfo.flp_approved_amt = x_flp_approved_amt) OR ((tlinfo.flp_approved_amt IS NULL) AND (x_flp_approved_amt IS NULL)))
        AND ((tlinfo.alt_approved_amt = x_alt_approved_amt) OR ((tlinfo.alt_approved_amt IS NULL) AND (x_alt_approved_amt IS NULL)))
        AND ((tlinfo.loan_app_form_code = x_loan_app_form_code) OR ((tlinfo.loan_app_form_code IS NULL) AND (x_loan_app_form_code IS NULL)))
        AND ((tlinfo.override_grade_level_code = x_override_grade_level_code) OR ((tlinfo.override_grade_level_code IS NULL) AND (x_override_grade_level_code IS NULL)))
        AND ((tlinfo.appl_loan_phase_code = x_appl_loan_phase_code) OR ((tlinfo.appl_loan_phase_code IS NULL) AND (x_appl_loan_phase_code IS NULL)))
        AND ((tlinfo.appl_loan_phase_code_chg = x_appl_loan_phase_code_chg) OR ((tlinfo.appl_loan_phase_code_chg IS NULL) AND (x_appl_loan_phase_code_chg IS NULL)))
        AND ((tlinfo.cl_rec_status = x_cl_rec_status) OR ((tlinfo.cl_rec_status IS NULL) AND (x_cl_rec_status IS NULL)))
        AND ((tlinfo.cl_rec_status_last_update = x_cl_rec_status_last_update) OR ((tlinfo.cl_rec_status_last_update IS NULL) AND (x_cl_rec_status_last_update IS NULL)))
        AND ((tlinfo.mpn_confirm_code = x_mpn_confirm_code) OR ((tlinfo.mpn_confirm_code IS NULL) AND (x_mpn_confirm_code IS NULL)))
        AND ((tlinfo.lend_apprv_denied_code = x_lend_apprv_denied_code) OR ((tlinfo.lend_apprv_denied_code IS NULL) AND (x_lend_apprv_denied_code IS NULL)))
        AND ((TRUNC(tlinfo.lend_apprv_denied_date) = TRUNC(x_lend_apprv_denied_date)) OR ((tlinfo.lend_apprv_denied_date IS NULL) AND (x_lend_apprv_denied_date IS NULL)))
       AND ((tlinfo.b_alien_reg_num_txt = x_b_alien_reg_num_txt) OR ((tlinfo.b_alien_reg_num_txt IS NULL) AND (x_b_alien_reg_num_txt IS NULL)))
        AND ((tlinfo.esign_src_typ_cd = x_esign_src_typ_cd) OR ((tlinfo.esign_src_typ_cd IS NULL) AND (x_esign_src_typ_cd IS NULL)))
	AND ((TRUNC(tlinfo.acad_begin_date) = TRUNC(x_acad_begin_date)) OR ((tlinfo.acad_begin_date IS NULL) AND (x_acad_begin_date IS NULL)))
	AND ((TRUNC(tlinfo.acad_end_date) = TRUNC(x_acad_end_date)) OR ((tlinfo.acad_end_date IS NULL) AND (x_acad_end_date IS NULL)))
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
    x_origination_id                    IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_chg_batch_id                      IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_duns_borw_lender_id               IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_appl_send_error_codes             IN     VARCHAR2,
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
    x_p_ssn_chg_date                    IN     DATE,
    x_p_dob_chg_date                    IN     DATE,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_default_status                  IN     VARCHAR2,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_ssn_chg_date                    IN     DATE,
    x_s_dob_chg_date                    IN     DATE,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_local_addr_chg_date             IN     DATE,
    x_s_default_status                  IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2,
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_cps_trans_num                     IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE ,
    x_external_loan_id_txt              IN     VARCHAR2  ,
    x_deferment_request_code            IN     VARCHAR2  ,
    x_eft_authorization_code            IN     VARCHAR2  ,
    x_requested_loan_amt                IN     NUMBER    ,
    x_actual_record_type_code           IN     VARCHAR2  ,
    x_reinstatement_amt                 IN     NUMBER    ,
    x_school_use_txt                    IN     VARCHAR2  ,
    x_lender_use_txt                    IN     VARCHAR2  ,
    x_guarantor_use_txt                 IN     VARCHAR2  ,
    x_fls_approved_amt                  IN     NUMBER    ,
    x_flu_approved_amt                  IN     NUMBER    ,
    x_flp_approved_amt                  IN     NUMBER    ,
    x_alt_approved_amt                  IN     NUMBER    ,
    x_loan_app_form_code                IN     VARCHAR2  ,
    x_override_grade_level_code         IN     VARCHAR2  ,
    x_called_from                       IN     VARCHAR2  ,
    x_b_alien_reg_num_txt               IN     VARCHAR2  ,
    x_esign_src_typ_cd                  IN     VARCHAR2  ,
    x_acad_begin_date                   IN     DATE,
    x_acad_end_date                     IN     DATE

  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||   viramali      12-MAY-01        added call to after_dml
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
      x_origination_id                    => x_origination_id,
      x_loan_id                           => x_loan_id,
      x_sch_cert_date                     => x_sch_cert_date,
      x_orig_status_flag                  => x_orig_status_flag,
      x_orig_batch_id                     => x_orig_batch_id,
      x_orig_batch_date                   => x_orig_batch_date,
      x_chg_batch_id                      => x_chg_batch_id,
      x_orig_ack_date                     => x_orig_ack_date,
      x_credit_override                   => x_credit_override,
      x_credit_decision_date              => x_credit_decision_date,
      x_req_serial_loan_code              => x_req_serial_loan_code,
      x_act_serial_loan_code              => x_act_serial_loan_code,
      x_pnote_delivery_code               => x_pnote_delivery_code,
      x_pnote_status                      => x_pnote_status,
      x_pnote_status_date                 => x_pnote_status_date,
      x_pnote_id                          => x_pnote_id,
      x_pnote_print_ind                   => x_pnote_print_ind,
      x_pnote_accept_amt                  => x_pnote_accept_amt,
      x_pnote_accept_date                 => x_pnote_accept_date,
      x_unsub_elig_for_heal               => x_unsub_elig_for_heal,
      x_disclosure_print_ind              => x_disclosure_print_ind,
      x_orig_fee_perct                    => x_orig_fee_perct,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_borw_interest_ind                 => x_borw_interest_ind,
      x_borw_outstd_loan_code             => x_borw_outstd_loan_code,
      x_unsub_elig_for_depnt              => x_unsub_elig_for_depnt,
      x_guarantee_amt                     => x_guarantee_amt,
      x_guarantee_date                    => x_guarantee_date,
      x_guarnt_amt_redn_code              => x_guarnt_amt_redn_code,
      x_guarnt_status_code                => x_guarnt_status_code,
      x_guarnt_status_date                => x_guarnt_status_date,
      x_lend_apprv_denied_code            => x_lend_apprv_denied_code,
      x_lend_apprv_denied_date            => x_lend_apprv_denied_date,
      x_lend_status_code                  => x_lend_status_code,
      x_lend_status_date                  => x_lend_status_date,
      x_guarnt_adj_ind                    => x_guarnt_adj_ind,
      x_grade_level_code                  => x_grade_level_code,
      x_enrollment_code                   => x_enrollment_code,
      x_anticip_compl_date                => x_anticip_compl_date,
      x_borw_lender_id                    => x_borw_lender_id,
      x_duns_borw_lender_id               => x_duns_borw_lender_id,
      x_guarantor_id                      => x_guarantor_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_prc_type_code                     => x_prc_type_code,
      x_cl_seq_number                     => x_cl_seq_number,
      x_last_resort_lender                => x_last_resort_lender,
      x_lender_id                         => x_lender_id,
      x_duns_lender_id                    => x_duns_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_recipient_id                      => x_recipient_id,
      x_recipient_type                    => x_recipient_type,
      x_duns_recip_id                     => x_duns_recip_id,
      x_recip_non_ed_brc_id               => x_recip_non_ed_brc_id,
      x_rec_type_ind                      => x_rec_type_ind,
      x_cl_loan_type                      => x_cl_loan_type,
      x_cl_rec_status                     => x_cl_rec_status,
      x_cl_rec_status_last_update         => x_cl_rec_status_last_update,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_alt_appl_ver_code                 => x_alt_appl_ver_code,
      x_mpn_confirm_code                  => x_mpn_confirm_code,
      x_resp_to_orig_code                 => x_resp_to_orig_code,
      x_appl_loan_phase_code              => x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg          => x_appl_loan_phase_code_chg,
      x_appl_send_error_codes             => x_appl_send_error_codes,
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
      x_p_ssn_chg_date                    => x_p_ssn_chg_date,
      x_p_dob_chg_date                    => x_p_dob_chg_date,
      x_p_permt_addr_chg_date             => x_p_permt_addr_chg_date,
      x_p_default_status                  => x_p_default_status,
      x_p_signature_code                  => x_p_signature_code,
      x_p_signature_date                  => x_p_signature_date,
      x_s_ssn_chg_date                    => x_s_ssn_chg_date,
      x_s_dob_chg_date                    => x_s_dob_chg_date,
      x_s_permt_addr_chg_date             => x_s_permt_addr_chg_date,
      x_s_local_addr_chg_date             => x_s_local_addr_chg_date,
      x_s_default_status                  => x_s_default_status,
      x_s_signature_code                  => x_s_signature_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_pnote_batch_id                    => x_pnote_batch_id,
      x_pnote_ack_date                    => x_pnote_ack_date,
      x_pnote_mpn_ind                     => x_pnote_mpn_ind,
      x_elec_mpn_ind                      => x_elec_mpn_ind,
      x_borr_sign_ind                     => x_borr_sign_ind,
      x_stud_sign_ind                     => x_stud_sign_ind,
      x_borr_credit_auth_code             => x_borr_credit_auth_code,
      x_relationship_cd                   => x_relationship_cd,
      x_interest_rebate_percent_num       => x_interest_rebate_percent_num,
      x_cps_trans_num                     => x_cps_trans_num,
      x_atd_entity_id_txt                 => x_atd_entity_id_txt,
      x_rep_entity_id_txt                 => x_rep_entity_id_txt,
      x_crdt_decision_status              => x_crdt_decision_status,
      x_note_message                      => x_note_message,
      x_book_loan_amt                     => x_book_loan_amt,
      x_book_loan_amt_date                => x_book_loan_amt_date,
      x_pymt_servicer_amt                 => x_pymt_servicer_amt,
      x_pymt_servicer_date                => x_pymt_servicer_date,
      x_external_loan_id_txt              => x_external_loan_id_txt        ,
      x_deferment_request_code            => x_deferment_request_code      ,
      x_eft_authorization_code            => x_eft_authorization_code      ,
      x_requested_loan_amt                => x_requested_loan_amt          ,
      x_actual_record_type_code           => x_actual_record_type_code     ,
      x_reinstatement_amt                 => x_reinstatement_amt           ,
      x_school_use_txt                    => x_school_use_txt              ,
      x_lender_use_txt                    => x_lender_use_txt              ,
      x_guarantor_use_txt                 => x_guarantor_use_txt           ,
      x_fls_approved_amt                  => x_fls_approved_amt            ,
      x_flu_approved_amt                  => x_flu_approved_amt            ,
      x_flp_approved_amt                  => x_flp_approved_amt            ,
      x_alt_approved_amt                  => x_alt_approved_amt            ,
      x_loan_app_form_code                => x_loan_app_form_code          ,
      x_override_grade_level_code         => x_override_grade_level_code   ,
      x_b_alien_reg_num_txt               => x_b_alien_reg_num_txt         ,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd            ,
      x_acad_begin_date                   => x_acad_begin_date             ,
      x_acad_end_date                     => x_acad_end_date

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

    UPDATE igf_sl_lor_all
      SET
        loan_id                           = new_references.loan_id,
        sch_cert_date                     = new_references.sch_cert_date,
        orig_status_flag                  = new_references.orig_status_flag,
        orig_batch_id                     = new_references.orig_batch_id,
        orig_batch_date                   = new_references.orig_batch_date,
        orig_ack_date                     = new_references.orig_ack_date,
        credit_override                   = new_references.credit_override,
        credit_decision_date              = new_references.credit_decision_date,
        req_serial_loan_code              = new_references.req_serial_loan_code,
        act_serial_loan_code              = new_references.act_serial_loan_code,
        pnote_delivery_code               = new_references.pnote_delivery_code,
        pnote_status                      = new_references.pnote_status,
        pnote_status_date                 = new_references.pnote_status_date,
        pnote_id                          = new_references.pnote_id,
        pnote_print_ind                   = new_references.pnote_print_ind,
        pnote_accept_amt                  = new_references.pnote_accept_amt,
        pnote_accept_date                 = new_references.pnote_accept_date,
        unsub_elig_for_heal               = new_references.unsub_elig_for_heal,
        disclosure_print_ind              = new_references.disclosure_print_ind,
        orig_fee_perct                    = new_references.orig_fee_perct,
        borw_confirm_ind                  = new_references.borw_confirm_ind,
        borw_interest_ind                 = new_references.borw_interest_ind,
        borw_outstd_loan_code             = new_references.borw_outstd_loan_code,
        unsub_elig_for_depnt              = new_references.unsub_elig_for_depnt,
        guarantee_amt                     = new_references.guarantee_amt,
        guarantee_date                    = new_references.guarantee_date,
        guarnt_amt_redn_code              = new_references.guarnt_amt_redn_code,
        guarnt_status_code                = new_references.guarnt_status_code,
        guarnt_status_date                = new_references.guarnt_status_date,
        lend_status_code                  = new_references.lend_status_code,
        lend_status_date                  = new_references.lend_status_date,
        guarnt_adj_ind                    = new_references.guarnt_adj_ind,
        grade_level_code                  = new_references.grade_level_code,
        enrollment_code                   = new_references.enrollment_code,
        anticip_compl_date                = new_references.anticip_compl_date,
        prc_type_code                     = new_references.prc_type_code,
        cl_seq_number                     = new_references.cl_seq_number,
        last_resort_lender                = new_references.last_resort_lender,
        rec_type_ind                      = new_references.rec_type_ind,
        cl_loan_type                      = new_references.cl_loan_type,
        alt_prog_type_code                = new_references.alt_prog_type_code,
        alt_appl_ver_code                 = new_references.alt_appl_ver_code,
        resp_to_orig_code                 = new_references.resp_to_orig_code,
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
        p_permt_addr_chg_date             = new_references.p_permt_addr_chg_date,
        p_default_status                  = new_references.p_default_status,
        p_signature_code                  = new_references.p_signature_code,
        p_signature_date                  = new_references.p_signature_date,
        s_permt_addr_chg_date             = new_references.s_permt_addr_chg_date,
        s_default_status                  = new_references.s_default_status,
        s_signature_code                  = new_references.s_signature_code,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        pnote_batch_id                    = new_references.pnote_batch_id,
        pnote_ack_date                    = new_references.pnote_ack_date,
        pnote_mpn_ind                     = new_references.pnote_mpn_ind,
        elec_mpn_ind                      = new_references.elec_mpn_ind,
        borr_sign_ind                     = new_references.borr_sign_ind,
        stud_sign_ind                     = new_references.stud_sign_ind,
        borr_credit_auth_code             = new_references.borr_credit_auth_code,
        relationship_cd                   = new_references.relationship_cd,
        interest_rebate_percent_num       = new_references.interest_rebate_percent_num,
        cps_trans_num                     = new_references.cps_trans_num,
        atd_entity_id_txt                 = new_references.atd_entity_id_txt,
        rep_entity_id_txt                 = new_references.rep_entity_id_txt,
        crdt_decision_status              = new_references.crdt_decision_status,
        note_message                      = new_references.note_message,
        book_loan_amt                     = new_references.book_loan_amt,
        book_loan_amt_date                = new_references.book_loan_amt_date,
        pymt_servicer_amt                 = new_references.pymt_servicer_amt,
        pymt_servicer_date                = new_references.pymt_servicer_date,
        external_loan_id_txt              = new_references.external_loan_id_txt     ,
        deferment_request_code            = new_references.deferment_request_code   ,
        eft_authorization_code            = new_references.eft_authorization_code   ,
        requested_loan_amt                = new_references.requested_loan_amt       ,
        actual_record_type_code           = new_references.actual_record_type_code  ,
        reinstatement_amt                 = new_references.reinstatement_amt        ,
        school_use_txt                    = new_references.school_use_txt           ,
        lender_use_txt                    = new_references.lender_use_txt           ,
        guarantor_use_txt                 = new_references.guarantor_use_txt        ,
        fls_approved_amt                  = new_references.fls_approved_amt         ,
        flu_approved_amt                  = new_references.flu_approved_amt         ,
        flp_approved_amt                  = new_references.flp_approved_amt         ,
        alt_approved_amt                  = new_references.alt_approved_amt         ,
        loan_app_form_code                = new_references.loan_app_form_code       ,
        override_grade_level_code         = new_references.override_grade_level_code ,
        appl_loan_phase_code              = new_references.appl_loan_phase_code        ,
        appl_loan_phase_code_chg          = new_references.appl_loan_phase_code_chg    ,
        cl_rec_status                     = new_references.cl_rec_status               ,
        cl_rec_status_last_update         = new_references.cl_rec_status_last_update   ,
        mpn_confirm_code                  = new_references.mpn_confirm_code            ,
        lend_apprv_denied_code            = new_references.lend_apprv_denied_code      ,
        lend_apprv_denied_date            = new_references.lend_apprv_denied_date      ,
        b_alien_reg_num_txt               = new_references.b_alien_reg_num_txt         ,
        esign_src_typ_cd                  = new_references.esign_src_typ_cd            ,
	acad_begin_date                   = new_references.acad_begin_date             ,
	acad_end_date                     = new_references.acad_end_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    g_v_called_from := x_called_from;
    after_dml(
      p_action =>'UPDATE',
      x_rowid => x_rowid
     );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_origination_id                    IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
    x_sch_cert_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_batch_id                     IN     VARCHAR2,
    x_orig_batch_date                   IN     DATE,
    x_chg_batch_id                      IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_req_serial_loan_code              IN     VARCHAR2,
    x_act_serial_loan_code              IN     VARCHAR2,
    x_pnote_delivery_code               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_print_ind                   IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_pnote_accept_date                 IN     DATE,
    x_unsub_elig_for_heal               IN     VARCHAR2,
    x_disclosure_print_ind              IN     VARCHAR2,
    x_orig_fee_perct                    IN     NUMBER,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_borw_interest_ind                 IN     VARCHAR2,
    x_borw_outstd_loan_code             IN     VARCHAR2,
    x_unsub_elig_for_depnt              IN     VARCHAR2,
    x_guarantee_amt                     IN     NUMBER,
    x_guarantee_date                    IN     DATE,
    x_guarnt_amt_redn_code              IN     VARCHAR2,
    x_guarnt_status_code                IN     VARCHAR2,
    x_guarnt_status_date                IN     DATE,
    x_lend_apprv_denied_code            IN     VARCHAR2,
    x_lend_apprv_denied_date            IN     DATE,
    x_lend_status_code                  IN     VARCHAR2,
    x_lend_status_date                  IN     DATE,
    x_guarnt_adj_ind                    IN     VARCHAR2,
    x_grade_level_code                  IN     VARCHAR2,
    x_enrollment_code                   IN     VARCHAR2,
    x_anticip_compl_date                IN     DATE,
    x_borw_lender_id                    IN     VARCHAR2,
    x_duns_borw_lender_id               IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_prc_type_code                     IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_last_resort_lender                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_duns_recip_id                     IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_rec_type_ind                      IN     VARCHAR2,
    x_cl_loan_type                      IN     VARCHAR2,
    x_cl_rec_status                     IN     VARCHAR2,
    x_cl_rec_status_last_update         IN     DATE,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_alt_appl_ver_code                 IN     NUMBER,
    x_mpn_confirm_code                  IN     VARCHAR2,
    x_resp_to_orig_code                 IN     VARCHAR2,
    x_appl_loan_phase_code              IN     VARCHAR2,
    x_appl_loan_phase_code_chg          IN     DATE,
    x_appl_send_error_codes             IN     VARCHAR2,
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
    x_p_ssn_chg_date                    IN     DATE,
    x_p_dob_chg_date                    IN     DATE,
    x_p_permt_addr_chg_date             IN     DATE,
    x_p_default_status                  IN     VARCHAR2,
    x_p_signature_code                  IN     VARCHAR2,
    x_p_signature_date                  IN     DATE,
    x_s_ssn_chg_date                    IN     DATE,
    x_s_dob_chg_date                    IN     DATE,
    x_s_permt_addr_chg_date             IN     DATE,
    x_s_local_addr_chg_date             IN     DATE,
    x_s_default_status                  IN     VARCHAR2,
    x_s_signature_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_pnote_batch_id                    IN     VARCHAR2,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_mpn_ind                     IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2,
    x_borr_sign_ind                     IN     VARCHAR2,
    x_stud_sign_ind                     IN     VARCHAR2,
    x_borr_credit_auth_code             IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_interest_rebate_percent_num       IN     NUMBER,
    x_cps_trans_num                     IN     NUMBER,
    x_atd_entity_id_txt                 IN     VARCHAR2,
    x_rep_entity_id_txt                 IN     VARCHAR2,
    x_crdt_decision_status              IN     VARCHAR2,
    x_note_message                      IN     VARCHAR2,
    x_book_loan_amt                     IN     NUMBER,
    x_book_loan_amt_date                IN     DATE,
    x_pymt_servicer_amt                 IN     NUMBER,
    x_pymt_servicer_date                IN     DATE ,
    x_external_loan_id_txt              IN     VARCHAR2  ,
    x_deferment_request_code            IN     VARCHAR2  ,
    x_eft_authorization_code            IN     VARCHAR2  ,
    x_requested_loan_amt                IN     NUMBER    ,
    x_actual_record_type_code           IN     VARCHAR2  ,
    x_reinstatement_amt                 IN     NUMBER    ,
    x_school_use_txt                    IN     VARCHAR2  ,
    x_lender_use_txt                    IN     VARCHAR2  ,
    x_guarantor_use_txt                 IN     VARCHAR2  ,
    x_fls_approved_amt                  IN     NUMBER    ,
    x_flu_approved_amt                  IN     NUMBER    ,
    x_flp_approved_amt                  IN     NUMBER    ,
    x_alt_approved_amt                  IN     NUMBER    ,
    x_loan_app_form_code                IN     VARCHAR2  ,
    x_override_grade_level_code         IN     VARCHAR2  ,
    x_b_alien_reg_num_txt               IN     VARCHAR2  ,
    x_esign_src_typ_cd                  IN     VARCHAR2  ,
    x_acad_begin_date                   IN     DATE      ,
    x_acad_end_date                     IN     DATE
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_lor_all
      WHERE    origination_id                    = x_origination_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_origination_id,
        x_loan_id,
        x_sch_cert_date,
        x_orig_status_flag,
        x_orig_batch_id,
        x_orig_batch_date,
        x_chg_batch_id,
        x_orig_ack_date,
        x_credit_override,
        x_credit_decision_date,
        x_req_serial_loan_code,
        x_act_serial_loan_code,
        x_pnote_delivery_code,
        x_pnote_status,
        x_pnote_status_date,
        x_pnote_id,
        x_pnote_print_ind,
        x_pnote_accept_amt,
        x_pnote_accept_date,
        x_unsub_elig_for_heal,
        x_disclosure_print_ind,
        x_orig_fee_perct,
        x_borw_confirm_ind,
        x_borw_interest_ind,
        x_borw_outstd_loan_code,
        x_unsub_elig_for_depnt,
        x_guarantee_amt,
        x_guarantee_date,
        x_guarnt_amt_redn_code,
        x_guarnt_status_code,
        x_guarnt_status_date,
        x_lend_apprv_denied_code,
        x_lend_apprv_denied_date,
        x_lend_status_code,
        x_lend_status_date,
        x_guarnt_adj_ind,
        x_grade_level_code,
        x_enrollment_code,
        x_anticip_compl_date,
        x_borw_lender_id,
        x_duns_borw_lender_id,
        x_guarantor_id,
        x_duns_guarnt_id,
        x_prc_type_code,
        x_cl_seq_number,
        x_last_resort_lender,
        x_lender_id,
        x_duns_lender_id,
        x_lend_non_ed_brc_id,
        x_recipient_id,
        x_recipient_type,
        x_duns_recip_id,
        x_recip_non_ed_brc_id,
        x_rec_type_ind,
        x_cl_loan_type,
        x_cl_rec_status,
        x_cl_rec_status_last_update,
        x_alt_prog_type_code,
        x_alt_appl_ver_code,
        x_mpn_confirm_code,
        x_resp_to_orig_code,
        x_appl_loan_phase_code,
        x_appl_loan_phase_code_chg,
        x_appl_send_error_codes,
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
        x_p_ssn_chg_date,
        x_p_dob_chg_date,
        x_p_permt_addr_chg_date,
        x_p_default_status,
        x_p_signature_code,
        x_p_signature_date,
        x_s_ssn_chg_date,
        x_s_dob_chg_date,
        x_s_permt_addr_chg_date,
        x_s_local_addr_chg_date,
        x_s_default_status,
        x_s_signature_code,
        x_mode,
        x_pnote_batch_id,
        x_pnote_ack_date,
        x_pnote_mpn_ind,
        x_elec_mpn_ind,
        x_borr_sign_ind,
        x_stud_sign_ind,
        x_borr_credit_auth_code,
        x_relationship_cd,
        x_interest_rebate_percent_num,
        x_cps_trans_num,
        x_atd_entity_id_txt,
        x_rep_entity_id_txt,
        x_crdt_decision_status,
        x_note_message,
        x_book_loan_amt,
        x_book_loan_amt_date,
        x_pymt_servicer_amt,
        x_pymt_servicer_date,
        x_external_loan_id_txt            ,
        x_deferment_request_code          ,
        x_eft_authorization_code          ,
        x_requested_loan_amt              ,
        x_actual_record_type_code         ,
        x_reinstatement_amt               ,
        x_school_use_txt                  ,
        x_lender_use_txt                  ,
        x_guarantor_use_txt               ,
        x_fls_approved_amt                ,
        x_flu_approved_amt                ,
        x_flp_approved_amt                ,
        x_alt_approved_amt                ,
        x_loan_app_form_code              ,
        x_override_grade_level_code       ,
        x_b_alien_reg_num_txt             ,
        x_esign_src_typ_cd                ,
        x_acad_begin_date                 ,
        x_acad_end_date


      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_origination_id,
      x_loan_id,
      x_sch_cert_date,
      x_orig_status_flag,
      x_orig_batch_id,
      x_orig_batch_date,
      x_chg_batch_id,
      x_orig_ack_date,
      x_credit_override,
      x_credit_decision_date,
      x_req_serial_loan_code,
      x_act_serial_loan_code,
      x_pnote_delivery_code,
      x_pnote_status,
      x_pnote_status_date,
      x_pnote_id,
      x_pnote_print_ind,
      x_pnote_accept_amt,
      x_pnote_accept_date,
      x_unsub_elig_for_heal,
      x_disclosure_print_ind,
      x_orig_fee_perct,
      x_borw_confirm_ind,
      x_borw_interest_ind,
      x_borw_outstd_loan_code,
      x_unsub_elig_for_depnt,
      x_guarantee_amt,
      x_guarantee_date,
      x_guarnt_amt_redn_code,
      x_guarnt_status_code,
      x_guarnt_status_date,
      x_lend_apprv_denied_code,
      x_lend_apprv_denied_date,
      x_lend_status_code,
      x_lend_status_date,
      x_guarnt_adj_ind,
      x_grade_level_code,
      x_enrollment_code,
      x_anticip_compl_date,
      x_borw_lender_id,
      x_duns_borw_lender_id,
      x_guarantor_id,
      x_duns_guarnt_id,
      x_prc_type_code,
      x_cl_seq_number,
      x_last_resort_lender,
      x_lender_id,
      x_duns_lender_id,
      x_lend_non_ed_brc_id,
      x_recipient_id,
      x_recipient_type,
      x_duns_recip_id,
      x_recip_non_ed_brc_id,
      x_rec_type_ind,
      x_cl_loan_type,
      x_cl_rec_status,
      x_cl_rec_status_last_update,
      x_alt_prog_type_code,
      x_alt_appl_ver_code,
      x_mpn_confirm_code,
      x_resp_to_orig_code,
      x_appl_loan_phase_code,
      x_appl_loan_phase_code_chg,
      x_appl_send_error_codes,
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
      x_p_ssn_chg_date,
      x_p_dob_chg_date,
      x_p_permt_addr_chg_date,
      x_p_default_status,
      x_p_signature_code,
      x_p_signature_date,
      x_s_ssn_chg_date,
      x_s_dob_chg_date,
      x_s_permt_addr_chg_date,
      x_s_local_addr_chg_date,
      x_s_default_status,
      x_s_signature_code,
      x_mode,
      x_pnote_batch_id,
      x_pnote_ack_date,
      x_pnote_mpn_ind,
      x_elec_mpn_ind,
      x_borr_sign_ind,
      x_stud_sign_ind,
      x_borr_credit_auth_code,
      x_relationship_cd,
      x_interest_rebate_percent_num,
      x_cps_trans_num,
      x_atd_entity_id_txt,
      x_rep_entity_id_txt,
      x_crdt_decision_status,
      x_note_message,
      x_book_loan_amt,
      x_book_loan_amt_date,
      x_pymt_servicer_amt,
      x_pymt_servicer_date,
      x_external_loan_id_txt            ,
      x_deferment_request_code          ,
      x_eft_authorization_code          ,
      x_requested_loan_amt              ,
      x_actual_record_type_code         ,
      x_reinstatement_amt               ,
      x_school_use_txt                  ,
      x_lender_use_txt                  ,
      x_guarantor_use_txt               ,
      x_fls_approved_amt                ,
      x_flu_approved_amt                ,
      x_flp_approved_amt                ,
      x_alt_approved_amt                ,
      x_loan_app_form_code              ,
      x_override_grade_level_code       ,
      x_b_alien_reg_num_txt             ,
      x_esign_src_typ_cd                ,
      x_acad_begin_date                 ,
      x_acad_end_date

    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
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

    DELETE FROM igf_sl_lor_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_lor_pkg;

/
