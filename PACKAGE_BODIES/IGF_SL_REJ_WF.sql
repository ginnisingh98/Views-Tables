--------------------------------------------------------
--  DDL for Package Body IGF_SL_REJ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_REJ_WF" AS
/* $Header: IGFSL18B.pls 120.2 2006/08/08 06:59:36 veramach noship $ */

  /*************************************************************
  Created By : viramali
  Date Created On : 2001/05/15
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
-------------------------------------------------------------------------------------
-- akomurav     27-Jan-2006       Build FA161 and FA162.
--                                TBH Impact change done in manif_loan(), reprint_loan().
--------------------------------------------------------------------------------------
-- svuppala     4-Nov-2004      #3416936 FA 134 TBH impacts for newly added columns
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
--------------------------------------------------------------------------------------
  veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
  (reverse chronological order - newest change first)
  ***************************************************************/

  PROCEDURE send_notif(
                      itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2 )
  AS
  /*************************************************************
  Created By : viramali
  Date Created On : 2001/05/15
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk           21-Feb-2003      Bug # 2758823. Work flow event is triggered with proper lookupcode / meaning
  (reverse chronological order - newest change first)
  ***************************************************************/
  l_batchid       igf_sl_dl_batch.dbth_id%TYPE;
  l_loanid        igf_sl_loans_v.loan_id%TYPE;
  l_loannum       igf_sl_loans_v.loan_number%TYPE;
  l_name          igf_sl_loans_v.full_name%TYPE;
  l_ssn           igf_sl_loans_v.s_ssn%TYPE;
  l_pernum        igf_sl_loans_v.person_number%TYPE;
  l_reject_code   igf_sl_dl_lor_resp.orig_reject_reasons%TYPE;
  l_reject_text   VARCHAR2(2000);
  l_label         igf_lookups_view.meaning%TYPE;
  l_heading       VARCHAR2(500);
  l_role          VARCHAR2(30);
  l_n_incr        NUMBER;
  l_c_reject_code igf_sl_dl_lor_resp.orig_reject_reasons%TYPE;


  CURSOR c_loan_details IS
  SELECT loan_number,
         full_name,
         s_ssn,
         person_number
  FROM  igf_sl_loans_v
  WHERE loan_id = l_loanid ;

  CURSOR c_pnote_resp IS
  SELECT igf_sl_dl_pnote_resp.pnote_rej_codes
  FROM igf_sl_dl_pnote_resp
  WHERE dbth_id = l_batchid
  AND loan_number =   (SELECT loan_number
                      FROM igf_sl_loans
                      WHERE loan_id = l_loanid);


  CURSOR c_rej IS
  SELECT lookup_code, meaning
  FROM igf_lookups_view
  WHERE  lookup_type = 'IGF_SL_PNOTE_REJ_CODES'
  AND    lookup_code IN (LTRIM(RTRIM(SUBSTR(l_reject_code, 1,2))),
                         LTRIM(RTRIM(SUBSTR(l_reject_code, 3,2))),
                         LTRIM(RTRIM(SUBSTR(l_reject_code, 5,2))),
                         LTRIM(RTRIM(SUBSTR(l_reject_code, 7,2))),
                         LTRIM(RTRIM(SUBSTR(l_reject_code, 9,2))));


  BEGIN
  IF ( funcmode = 'RUN' ) THEN

  l_loanid := wf_engine.GetItemAttrNumber(itemtype,
                              itemkey,
                              'VLOANID');
  l_batchid := wf_engine.GetItemAttrNumber(itemtype,
                                 itemkey,
                                'VDBTHID');




  OPEN c_loan_details;
  FETCH c_loan_details INTO l_loannum,l_name,l_ssn,l_pernum;
  IF c_loan_details%NOTFOUND THEN
     CLOSE c_loan_details;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_loan_details;

  -- setting values to the attributes: loan number,fullname,ssn and person number,performer role
  l_role := fnd_global.user_name;
  wf_engine.setitemattrtext(itemtype,itemkey,
                            'VROLE',l_role);
  wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VLOANNUM',
                  l_loannum);

  wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VNAME',
                  l_name);

  wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VSSN',
                  l_ssn);
  wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VPERNUM',
                  l_pernum);


  -- populate reject codes and reasons

  OPEN c_pnote_resp;
  FETCH c_pnote_resp INTO l_reject_code;
  IF c_pnote_resp%NOTFOUND THEN
     CLOSE c_pnote_resp;
     RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c_pnote_resp;

  l_c_reject_code := l_reject_code;
  l_reject_code   := TRANSLATE (l_reject_code,'0',' ');
  l_reject_text   := '';

  l_n_incr := 1;

  FOR rej_rec in c_rej LOOP

     l_reject_text := l_reject_text                          ||
                      SUBSTR (l_c_reject_code,l_n_incr,2)    ||
                      '                                    ' ||
                      rej_rec.meaning                        ||
                      fnd_global.newline;

     l_n_incr := l_n_incr + 2;

  END LOOP;

  wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VREJ_REASONS',
                  l_reject_text);



   -- populating label attributes

   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'S_FULL_NAME');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VNAME_LABEL',
                  l_label);


   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'S_SSN');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VSSN_LABEL',
                  l_label);


   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'S_PER_NUM');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VPERNUM_LABEL',
                  l_label);

   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'LOAN_ID');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VLOAN_LABEL',
                  l_label);

   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'S_REJECT_NUM');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VREJ_LABEL',
                  l_label);

   l_label := igf_aw_gen.lookup_desc ('IGF_SL_LOAN_FIELDS', 'S_REJECT_DESC');

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VDESC_LABEL',
                  l_label);

  -- populate header attribute

  fnd_message.set_name('IGF','IGF_SL_WF_PNOTE_REJECT');
  l_heading := fnd_message.get;

   wf_engine.SetItemAttrText(itemtype,
                  itemkey,
                  'VHEADING',
                  l_heading);

   resultout := 'COMPLETE:';
   END IF;

   EXCEPTION

   WHEN OTHERS THEN
       WF_CORE.CONTEXT ('igf_sl_rej_wf', 'send_notif', itemtype, itemkey,
                    to_char(actid), funcmode);
       RAISE;

   END send_notif;

  PROCEDURE manif_loan(
                      itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2 )
  AS
  /*************************************************************
  Created By : viramali
  Date Created On : 2001/05/15
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
-------------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
--------------------------------------------------------------------------------------
  veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
  (reverse chronological order - newest change first)
  ***************************************************************/

   l_loanid        igf_sl_loans_v.loan_id%TYPE;
   l_tbh_rec       igf_sl_lor%ROWTYPE;

   CURSOR c_tbh_cur IS
   SELECT * FROM igf_sl_lor
   WHERE loan_id = l_loanid
   AND pnote_status = 'R'
   FOR UPDATE OF igf_sl_lor.pnote_status NOWAIT;


  BEGIN

  IF ( funcmode = 'RUN' ) THEN

   l_loanid := wf_engine.GetItemAttrNumber(itemtype,
                                 itemkey,
                                'VLOANID');


    OPEN c_tbh_cur ;
    FETCH c_tbh_cur INTO l_tbh_rec;
    IF c_tbh_cur%NOTFOUND THEN
      CLOSE c_tbh_cur;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_tbh_cur;


       igf_sl_lor_pkg.update_row(       x_mode                              => 'R',
                                        x_rowid                             => l_tbh_rec.row_id,
 					x_origination_id                    => l_tbh_rec.origination_id,
                                        x_loan_id                           => l_tbh_rec.loan_id,
 					x_sch_cert_date                     => l_tbh_rec.sch_cert_date,
					x_orig_status_flag                  => l_tbh_rec.orig_status_flag,
 					x_orig_batch_id                     => l_tbh_rec.orig_batch_id,
 					x_orig_batch_date                   => l_tbh_rec.orig_batch_date,
 					x_chg_batch_id                      => NULL,
 					x_orig_ack_date                     => l_tbh_rec.orig_ack_date,
	 				x_credit_override                   => l_tbh_rec.credit_override,
 					x_credit_decision_date              => l_tbh_rec.credit_decision_date,
 					x_req_serial_loan_code              => l_tbh_rec.req_serial_loan_code,
					x_act_serial_loan_code              => l_tbh_rec.act_serial_loan_code,
 					x_pnote_delivery_code               => l_tbh_rec.pnote_delivery_code,
 					x_pnote_status                      => 'S',
 					x_pnote_status_date                 => TRUNC(SYSDATE),
 					x_pnote_id                          => l_tbh_rec.pnote_id,
 					x_pnote_print_ind                   => l_tbh_rec.pnote_print_ind,
 					x_pnote_accept_amt                  => l_tbh_rec.pnote_accept_amt,
 					x_pnote_accept_date                 => l_tbh_rec.pnote_accept_date,
 					x_pnote_batch_id                    => l_tbh_rec.pnote_batch_id,
 					x_pnote_ack_date                    => l_tbh_rec.pnote_ack_date,
 					x_pnote_mpn_ind                     => l_tbh_rec.pnote_mpn_ind,
 					x_unsub_elig_for_heal               => l_tbh_rec.unsub_elig_for_heal,
 					x_disclosure_print_ind              => l_tbh_rec.disclosure_print_ind,
 					x_orig_fee_perct                    => l_tbh_rec.orig_fee_perct,
 					x_borw_confirm_ind                  => l_tbh_rec.borw_confirm_ind,
 					x_borw_interest_ind                 => l_tbh_rec.borw_interest_ind,
 					x_borw_outstd_loan_code             => l_tbh_rec.borw_outstd_loan_code,
 					x_unsub_elig_for_depnt              => l_tbh_rec.unsub_elig_for_depnt,
 					x_guarantee_amt                     => l_tbh_rec.guarantee_amt,
 					x_guarantee_date                    => l_tbh_rec.guarantee_date,
 					x_guarnt_amt_redn_code              => l_tbh_rec.guarnt_amt_redn_code,
 					x_guarnt_status_code                => l_tbh_rec.guarnt_status_code,
 					x_guarnt_status_date                => l_tbh_rec.guarnt_status_date,
 					x_lend_apprv_denied_code            => NULL,
 					x_lend_apprv_denied_date            => NULL,
 					x_lend_status_code                  => l_tbh_rec.lend_status_code,
 					x_lend_status_date                  => l_tbh_rec.lend_status_date,
 					x_guarnt_adj_ind                    => l_tbh_rec.guarnt_adj_ind,
					x_grade_level_code                  => l_tbh_rec.grade_level_code,
 					x_enrollment_code                   => l_tbh_rec.enrollment_code,
 					x_anticip_compl_date                => l_tbh_rec.anticip_compl_date,
 					x_borw_lender_id                    => NULL,
 					x_duns_borw_lender_id               => NULL,
 					x_guarantor_id                      => NULL,
 					x_duns_guarnt_id                    => NULL,
 					x_prc_type_code                     => l_tbh_rec.prc_type_code,
 					x_cl_seq_number                     => l_tbh_rec.cl_seq_number,
 					x_last_resort_lender                => l_tbh_rec.last_resort_lender,
 					x_lender_id                         => NULL,
 					x_duns_lender_id                    => NULL,
 					x_lend_non_ed_brc_id                => NULL,
 					x_recipient_id                      => NULL,
 					x_recipient_type                    => NULL,
 					x_duns_recip_id                     => NULL,
 					x_recip_non_ed_brc_id               => NULL,
	                                x_rec_type_ind                      => l_tbh_rec.rec_type_ind,
 					x_cl_loan_type                      => l_tbh_rec.cl_loan_type,
 					x_cl_rec_status                     => NULL,
 					x_cl_rec_status_last_update         => NULL,
 					x_alt_prog_type_code                => l_tbh_rec.alt_prog_type_code,
 					x_alt_appl_ver_code                 => l_tbh_rec.alt_appl_ver_code,
 					x_mpn_confirm_code                  => NULL,
 					x_resp_to_orig_code                 => l_tbh_rec.resp_to_orig_code,
 					x_appl_loan_phase_code              => NULL,
 					x_appl_loan_phase_code_chg          => NULL,
 					x_appl_send_error_codes             => NULL,
 					x_tot_outstd_stafford               => l_tbh_rec.tot_outstd_stafford,
 					x_tot_outstd_plus                   => l_tbh_rec.tot_outstd_plus,
 					x_alt_borw_tot_debt                 => l_tbh_rec.alt_borw_tot_debt,
 					x_act_interest_rate                 => l_tbh_rec.act_interest_rate,
 					x_service_type_code                 => l_tbh_rec.service_type_code,
 					x_rev_notice_of_guarnt              => l_tbh_rec.rev_notice_of_guarnt,
 					x_sch_refund_amt                    => l_tbh_rec.sch_refund_amt,
 					x_sch_refund_date                   => l_tbh_rec.sch_refund_date,
 					x_uniq_layout_vend_code             => l_tbh_rec.uniq_layout_vend_code,
 					x_uniq_layout_ident_code            => l_tbh_rec.uniq_layout_ident_code,
 					x_p_person_id                       => l_tbh_rec.p_person_id,
 					x_p_ssn_chg_date                    => NULL,
 					x_p_dob_chg_date                    => NULL,
					x_p_permt_addr_chg_date             => l_tbh_rec.p_permt_addr_chg_date,
 					x_p_default_status                  => l_tbh_rec.p_default_status,
 					x_p_signature_code                  => l_tbh_rec.p_signature_code,
 					x_p_signature_date                  => l_tbh_rec.p_signature_date,
 					x_s_ssn_chg_date                    => NULL,
 					x_s_dob_chg_date                    => NULL,
 					x_s_permt_addr_chg_date             => l_tbh_rec.s_permt_addr_chg_date,
 					x_s_local_addr_chg_date             => NULL,
 					x_s_default_status                  => l_tbh_rec.s_default_status,
 					x_s_signature_code                  => l_tbh_rec.s_signature_code,
					x_elec_mpn_ind	                    => l_tbh_rec.elec_mpn_ind,
				        x_borr_sign_ind	                    => l_tbh_rec.borr_sign_ind,
                                        x_stud_sign_ind	                    => l_tbh_rec.stud_sign_ind,
                                        x_borr_credit_auth_code             => l_tbh_rec.borr_credit_auth_code,
                                        x_relationship_cd                   => l_tbh_rec.relationship_cd,
                                        x_interest_rebate_percent_num       => l_tbh_rec.interest_rebate_percent_num,
                                        x_cps_trans_num                     => l_tbh_rec.cps_trans_num,
                                        x_atd_entity_id_txt              => l_tbh_rec.atd_entity_id_txt ,
                                        x_rep_entity_id_txt              => l_tbh_rec.rep_entity_id_txt,
                                        x_crdt_decision_status           => l_tbh_rec.crdt_decision_status,
                                        x_note_message                   => l_tbh_rec.note_message,
                                        x_book_loan_amt                  => l_tbh_rec.book_loan_amt ,
                                        x_book_loan_amt_date             => l_tbh_rec.book_loan_amt_date,
                                        x_pymt_servicer_amt              => l_tbh_rec.pymt_servicer_amt,
                                        x_pymt_servicer_date             => l_tbh_rec.pymt_servicer_date,
                                      x_requested_loan_amt                => l_tbh_rec.requested_loan_amt,
                                      x_eft_authorization_code            => l_tbh_rec.eft_authorization_code,
                                      x_external_loan_id_txt              => l_tbh_rec.external_loan_id_txt,
                                      x_deferment_request_code            => l_tbh_rec.deferment_request_code ,
                                      x_actual_record_type_code           => l_tbh_rec.actual_record_type_code,
                                      x_reinstatement_amt                 => l_tbh_rec.reinstatement_amt,
                                      x_school_use_txt                    => l_tbh_rec.school_use_txt,
                                      x_lender_use_txt                    => l_tbh_rec.lender_use_txt,
                                      x_guarantor_use_txt                 => l_tbh_rec.guarantor_use_txt,
                                      x_fls_approved_amt                  => l_tbh_rec.fls_approved_amt,
                                      x_flu_approved_amt                  => l_tbh_rec.flu_approved_amt,
                                      x_flp_approved_amt                  => l_tbh_rec.flp_approved_amt,
                                      x_alt_approved_amt                  => l_tbh_rec.alt_approved_amt,
                                      x_loan_app_form_code                => l_tbh_rec.loan_app_form_code,
                                      x_override_grade_level_code         => l_tbh_rec.override_grade_level_code,
				      x_b_alien_reg_num_txt               => l_tbh_rec.b_alien_reg_num_txt,
                                      x_esign_src_typ_cd                  => l_tbh_rec.esign_src_typ_cd,
                                      x_acad_begin_date                   => l_tbh_rec.acad_begin_date,
                                      x_acad_end_date                     => l_tbh_rec.acad_end_date

                              );
        resultout := 'COMPLETE:';
        END IF;

        EXCEPTION

        WHEN OTHERS THEN
           WF_CORE.CONTEXT ('igf_sl_rej_wf', 'send_notif', itemtype, itemkey,
                    to_char(actid), funcmode);
           RAISE;


        END manif_loan;


  PROCEDURE reprint_loan(
                      itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2 )
  AS
  /*************************************************************
  Created By : viramali
  Date Created On : 2001/05/15
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
-------------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
--------------------------------------------------------------------------------------
  veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
  (reverse chronological order - newest change first)
  ***************************************************************/
   l_loanid        igf_sl_loans_v.loan_id%TYPE;
   l_tbh_rec       igf_sl_lor%ROWTYPE;

   CURSOR c_tbh_cur IS
   SELECT * FROM igf_sl_lor
   WHERE loan_id = l_loanid
   AND pnote_status = 'R'
   FOR UPDATE OF igf_sl_lor.pnote_status NOWAIT;


  BEGIN

  IF ( funcmode = 'RUN' ) THEN

   l_loanid := wf_engine.GetItemAttrNumber(itemtype,
                                 itemkey,
                                'VLOANID');


    OPEN c_tbh_cur ;
    FETCH c_tbh_cur INTO l_tbh_rec;
    IF c_tbh_cur%NOTFOUND THEN
      CLOSE c_tbh_cur;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_tbh_cur;

       igf_sl_lor_pkg.update_row(
                                        x_mode                              => 'R',
                                        x_rowid                            => l_tbh_rec.row_id,
 					x_origination_id                    => l_tbh_rec.origination_id,
                                        x_loan_id                           => l_tbh_rec.loan_id,
 					x_sch_cert_date                     => l_tbh_rec.sch_cert_date,
					x_orig_status_flag                  => l_tbh_rec.orig_status_flag,
 					x_orig_batch_id                     => l_tbh_rec.orig_batch_id,
 					x_orig_batch_date                   => l_tbh_rec.orig_batch_date,
 					x_chg_batch_id                      => NULL,
 					x_orig_ack_date                     => l_tbh_rec.orig_ack_date,
	 				x_credit_override                   => l_tbh_rec.credit_override,
 					x_credit_decision_date              => l_tbh_rec.credit_decision_date,
 					x_req_serial_loan_code              => l_tbh_rec.req_serial_loan_code,
					x_act_serial_loan_code              => l_tbh_rec.act_serial_loan_code,
 					x_pnote_delivery_code               => l_tbh_rec.pnote_delivery_code,
 					x_pnote_status                      => 'G',
 					x_pnote_status_date                 => TRUNC(SYSDATE),
 					x_pnote_id                          => l_tbh_rec.pnote_id,
 					x_pnote_print_ind                   => l_tbh_rec.pnote_print_ind,
 					x_pnote_accept_amt                  => l_tbh_rec.pnote_accept_amt,
 					x_pnote_accept_date                 => l_tbh_rec.pnote_accept_date,
 					x_pnote_batch_id                    => l_tbh_rec.pnote_batch_id,
 					x_pnote_ack_date                    => l_tbh_rec.pnote_ack_date,
 					x_pnote_mpn_ind                     => l_tbh_rec.pnote_mpn_ind,
 					x_unsub_elig_for_heal               => l_tbh_rec.unsub_elig_for_heal,
 					x_disclosure_print_ind              => l_tbh_rec.disclosure_print_ind,
 					x_orig_fee_perct                    => l_tbh_rec.orig_fee_perct,
 					x_borw_confirm_ind                  => l_tbh_rec.borw_confirm_ind,
 					x_borw_interest_ind                 => l_tbh_rec.borw_interest_ind,
 					x_borw_outstd_loan_code             => l_tbh_rec.borw_outstd_loan_code,
 					x_unsub_elig_for_depnt              => l_tbh_rec.unsub_elig_for_depnt,
 					x_guarantee_amt                     => l_tbh_rec.guarantee_amt,
 					x_guarantee_date                    => l_tbh_rec.guarantee_date,
 					x_guarnt_amt_redn_code              => l_tbh_rec.guarnt_amt_redn_code,
 					x_guarnt_status_code                => l_tbh_rec.guarnt_status_code,
 					x_guarnt_status_date                => l_tbh_rec.guarnt_status_date,
 					x_lend_apprv_denied_code            => NULL,
 					x_lend_apprv_denied_date            => NULL,
 					x_lend_status_code                  => l_tbh_rec.lend_status_code,
 					x_lend_status_date                  => l_tbh_rec.lend_status_date,
 					x_guarnt_adj_ind                    => l_tbh_rec.guarnt_adj_ind,
					x_grade_level_code                  => l_tbh_rec.grade_level_code,
 					x_enrollment_code                   => l_tbh_rec.enrollment_code,
 					x_anticip_compl_date                => l_tbh_rec.anticip_compl_date,
 					x_borw_lender_id                    => NULL,
 					x_duns_borw_lender_id               => NULL,
 					x_guarantor_id                      => NULL,
 					x_duns_guarnt_id                    => NULL,
 					x_prc_type_code                     => l_tbh_rec.prc_type_code,
 					x_cl_seq_number                     => l_tbh_rec.cl_seq_number,
 					x_last_resort_lender                => l_tbh_rec.last_resort_lender,
 					x_lender_id                         => NULL,
 					x_duns_lender_id                    => NULL,
 					x_lend_non_ed_brc_id                => NULL,
 					x_recipient_id                      => NULL,
 					x_recipient_type                    => NULL,
 					x_duns_recip_id                     => NULL,
 					x_recip_non_ed_brc_id               => NULL,
                                        x_rec_type_ind                      => l_tbh_rec.rec_type_ind,
 					x_cl_loan_type                      => l_tbh_rec.cl_loan_type,
 					x_cl_rec_status                     => NULL,
 					x_cl_rec_status_last_update         => NULL,
 					x_alt_prog_type_code                => l_tbh_rec.alt_prog_type_code,
 					x_alt_appl_ver_code                 => l_tbh_rec.alt_appl_ver_code,
 					x_mpn_confirm_code                  => NULL,
 					x_resp_to_orig_code                 => l_tbh_rec.resp_to_orig_code,
 					x_appl_loan_phase_code              => NULL,
 					x_appl_loan_phase_code_chg          => NULL,
 					x_appl_send_error_codes             => NULL,
 					x_tot_outstd_stafford               => l_tbh_rec.tot_outstd_stafford,
 					x_tot_outstd_plus                   => l_tbh_rec.tot_outstd_plus,
 					x_alt_borw_tot_debt                 => l_tbh_rec.alt_borw_tot_debt,
 					x_act_interest_rate                 => l_tbh_rec.act_interest_rate,
 					x_service_type_code                 => l_tbh_rec.service_type_code,
 					x_rev_notice_of_guarnt              => l_tbh_rec.rev_notice_of_guarnt,
 					x_sch_refund_amt                    => l_tbh_rec.sch_refund_amt,
 					x_sch_refund_date                   => l_tbh_rec.sch_refund_date,
 					x_uniq_layout_vend_code             => l_tbh_rec.uniq_layout_vend_code,
 					x_uniq_layout_ident_code            => l_tbh_rec.uniq_layout_ident_code,
 					x_p_person_id                       => l_tbh_rec.p_person_id,
 					x_p_ssn_chg_date                    => NULL,
 					x_p_dob_chg_date                    => NULL,
					x_p_permt_addr_chg_date             => l_tbh_rec.p_permt_addr_chg_date,
 					x_p_default_status                  => l_tbh_rec.p_default_status,
 					x_p_signature_code                  => l_tbh_rec.p_signature_code,
 					x_p_signature_date                  => l_tbh_rec.p_signature_date,
 					x_s_ssn_chg_date                    => NULL,
 					x_s_dob_chg_date                    => NULL,
 					x_s_permt_addr_chg_date             => l_tbh_rec.s_permt_addr_chg_date,
 					x_s_local_addr_chg_date             => NULL,
 					x_s_default_status                  => l_tbh_rec.s_default_status,
 					x_s_signature_code                  => l_tbh_rec.s_signature_code,
					x_elec_mpn_ind	                    => l_tbh_rec.elec_mpn_ind,
                                        x_borr_sign_ind	                    => l_tbh_rec.borr_sign_ind,
                                        x_stud_sign_ind	                    => l_tbh_rec.stud_sign_ind,
                                        x_borr_credit_auth_code             => l_tbh_rec.borr_credit_auth_code,
                                        x_relationship_cd                   => l_tbh_rec.relationship_cd,
                                        x_interest_rebate_percent_num       => l_tbh_rec.interest_rebate_percent_num,
                                        x_cps_trans_num                     => l_tbh_rec.cps_trans_num,
                                        x_atd_entity_id_txt              => l_tbh_rec.atd_entity_id_txt ,
                                        x_rep_entity_id_txt              => l_tbh_rec.rep_entity_id_txt,
                                        x_crdt_decision_status           => l_tbh_rec.crdt_decision_status,
                                        x_note_message                   => l_tbh_rec.note_message,
                                        x_book_loan_amt                  => l_tbh_rec.book_loan_amt ,
                                        x_book_loan_amt_date             => l_tbh_rec.book_loan_amt_date,
                                        x_pymt_servicer_amt              => l_tbh_rec.pymt_servicer_amt,
                                        x_pymt_servicer_date             => l_tbh_rec.pymt_servicer_date,
                                      x_requested_loan_amt                => l_tbh_rec.requested_loan_amt,
                                      x_eft_authorization_code            => l_tbh_rec.eft_authorization_code,
                                      x_external_loan_id_txt              => l_tbh_rec.external_loan_id_txt,
                                      x_deferment_request_code            => l_tbh_rec.deferment_request_code ,
                                      x_actual_record_type_code           => l_tbh_rec.actual_record_type_code,
                                      x_reinstatement_amt                 => l_tbh_rec.reinstatement_amt,
                                      x_school_use_txt                    => l_tbh_rec.school_use_txt,
                                      x_lender_use_txt                    => l_tbh_rec.lender_use_txt,
                                      x_guarantor_use_txt                 => l_tbh_rec.guarantor_use_txt,
                                      x_fls_approved_amt                  => l_tbh_rec.fls_approved_amt,
                                      x_flu_approved_amt                  => l_tbh_rec.flu_approved_amt,
                                      x_flp_approved_amt                  => l_tbh_rec.flp_approved_amt,
                                      x_alt_approved_amt                  => l_tbh_rec.alt_approved_amt,
                                      x_loan_app_form_code                => l_tbh_rec.loan_app_form_code,
                                      x_override_grade_level_code         => l_tbh_rec.override_grade_level_code,
				      x_b_alien_reg_num_txt               => l_tbh_rec.b_alien_reg_num_txt,
                                      x_esign_src_typ_cd                  => l_tbh_rec.esign_src_typ_cd,
                                      x_acad_begin_date                   => l_tbh_rec.acad_begin_date,
                                      x_acad_end_date                     => l_tbh_rec.acad_end_date

                              );
        resultout := 'COMPLETE:';
        END IF;

        EXCEPTION

        WHEN OTHERS THEN
           WF_CORE.CONTEXT ('igf_sl_rej_wf', 'send_notif', itemtype, itemkey,
                    to_char(actid), funcmode);
           RAISE;


        END reprint_loan;

END igf_sl_rej_wf;

/
