--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_PRINT_PNOTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_PRINT_PNOTE" AS
/* $Header: IGFSL16B.pls 120.1 2006/04/18 23:19:15 akomurav noship $ */
/***************************************************************
   Created By           :       avenkatr
   Date Created By      :       2001/05/08
   Purpose              :       To Print and process the Promissory note
   Known Limitations,Enhancements or Remarks
   Change History       :
   Who             When            What
-------------------------------------------------------------------------------------
-- akomurav        17-Apr-2006     Build FA161 and 162.
--                                 TBH Impact change done in update_pnote_status().
-------------------------------------------------------------------------------------
-- svuppala     4-Nov-2004      #3416936 FA 134 TBH impacts for newly added columns
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
   veramach        16-SEP-2003     FA 122 loan enhancements build
                                   1.Added update_pnote_status method
                                   2.Changed cursors c_stafford_det and c_plus_det to remove references of igf_sl_plus_borw.
                                   3.the borrower info is now derived using igf_sl_gen.get_person_details procedure
   Bug :- 2426609 SSN Format Incorrect in Output File
   mesriniv        25-jun-2002     Code has been added inorder to handle the if No Data is fetched by the
                                   Parent Details and Student Details Cursors and skip the records.
   Change History       :
   Bug :- 2426609 SSN Format Incorrect in Output File
  Who             When            What
  mesriniv        21-jun-2002     While inserting Student SSN/Parent SSN
                                  formatting and substr of 9 chars is done.
                                  Code added to display the Parameters passed.
   Who                  When            What
   masehgal             19-Feb-2002     # 2216956   FACR007
                                        Added Elec_mpn_ind , Borr_sign_ind in igf_sl_lor_pkg
***************************************************************/

  g_debug_runtime_level     NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  -- Main Procedure starts here and is a Concurrent Program

  PROCEDURE process_pnote(
  ERRBUF                        OUT NOCOPY              VARCHAR2,
  RETCODE                       OUT NOCOPY              NUMBER,
  p_award_year                  IN              VARCHAR2,
  p_loan_catg                   IN              igf_lookups_view.lookup_code%TYPE,
  p_base_id                     IN              igf_ap_fa_base_rec_all.base_id%TYPE,
  p_loan_number                 IN              igf_sl_loans_v.loan_number%TYPE,
  p_org_id                      IN              NUMBER
  )AS
  /***************************************************************
   Created By           :       avenkatr
   Date Created By      :       2001/08/05
   Purpose              :
   Known Limitations,Enhancements or Remarks
   Change History       :
   Who                  When            What
   veramach        16-SEP-2003     FA 122 loan enhancements build
                                   1.Changed cursors c_stafford_det and c_plus_det to remove references of igf_sl_plus_borw.
                                   2.the borrower info is now derived using igf_sl_gen.get_person_details procedure
                                   3.changed c_dl_orig_recs cursor -added 2 where clauses on ci_cal_type and ci_sequence_number and
                                     changed the signature to take lookup_type and pnote_status as arguments

   masehgal             19-Feb-2002     # 2216956   FACR007
                                        Added Elec_mpn_ind , Borr_sign_ind in igf_sl_lor_pkg
  ****************************************************************/

  student_dtl_rec igf_sl_gen.person_dtl_rec;
  student_dtl_cur igf_sl_gen.person_dtl_cur;

  parent_dtl_rec igf_sl_gen.person_dtl_rec;
  parent_dtl_cur igf_sl_gen.person_dtl_cur;

  l_debug_str     fnd_log_messages.message_text%TYPE;

  CURSOR c_pnote_check( x_ci_cal_type  igf_sl_dl_setup.ci_cal_type%TYPE,
                        x_ci_sequence_number igf_sl_dl_setup.ci_sequence_number%TYPE ) IS
    SELECT pnote_print_ind, ci_alternate_code
    FROM igf_sl_dl_setup_v
    WHERE ci_cal_type = x_ci_cal_type AND ci_sequence_number = x_ci_sequence_number;

  CURSOR c_lor_rec( x_loan_id    igf_sl_lor.loan_id%TYPE ) IS
    SELECT igf_sl_lor.*
    FROM igf_sl_lor
    WHERE loan_id = x_loan_id FOR UPDATE OF igf_sl_lor.pnote_status NOWAIT;

  CURSOR c_dl_orig_recs(   x_ci_cal_type        igf_sl_lor_v.ci_cal_type%TYPE,
                           x_ci_sequence_number igf_sl_lor_v.ci_sequence_number%TYPE,
                           x_loan_number        igf_sl_lor_v.loan_number%TYPE,
                           x_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                           x_pnote_status       igf_sl_lor_v.pnote_status%TYPE,
                           x_lookup_type        igf_lookups_view.lookup_type%TYPE
                       ) IS
    SELECT lor.loan_id
    FROM igf_sl_lor_v lor, igf_ap_fa_base_rec fa
    WHERE lor.pnote_status = x_pnote_status AND
           lor.student_id = fa.person_id AND
           fa.base_id = NVL(x_base_id,fa.base_id) AND
           lor.fed_fund_code IN  ( SELECT DISTINCT lookup_code
                                   FROM igf_lookups_view
                                   WHERE lookup_type = x_lookup_type ) AND
           lor.ci_cal_type = x_ci_cal_type AND
           lor.ci_sequence_number = x_ci_sequence_number AND
           lor.loan_number = NVL(x_loan_number, lor.loan_number) AND
           fa.ci_cal_type = x_ci_cal_type AND
           fa.ci_sequence_number = x_ci_sequence_number;

     CURSOR c_stafford_det(
                      x_loan_id    igf_sl_loans_all.LOAN_ID%TYPE
                     )  IS
     SELECT loans.loan_number,
            fa.person_id student_id,
            prsn.api_person_id s_ssn,
            prsn.given_names,
            prsn.surname,
            prsn.middle_name,
            prsn.birth_dt
     FROM   igf_sl_loans  loans,
            igf_aw_award  awd,
            igf_ap_fa_base_rec fa,
            igf_ap_person_v    prsn
     WHERE  loans.loan_id  = x_loan_id
     AND    loans.award_id = awd.award_id
     AND    awd.base_id    = fa.base_id
     AND    fa.person_id   = prsn.person_id;

    CURSOR c_plus_det(
                           x_loan_id igf_sl_loans.loan_id%TYPE
                         ) IS
    SELECT loans.loan_number,
           awd.offered_amt loan_amt_offered,
           awd.accepted_amt loan_amt_accepted,
           loans.loan_per_begin_date,
           loans.loan_per_end_date,
           fa.person_id student_id,
           prsn.api_person_id s_ssn,
           prsn.given_names,
           prsn.surname,
           prsn.middle_name,
           prsn.birth_dt,
           lor.p_person_id,
           parent.api_person_id,
           parent.given_names p_first_name,
           parent.surname     p_last_name,
           parent.middle_name p_middle_name,
           parent.birth_dt    p_date_of_birth
    FROM   igf_sl_lor         lor,
           igf_sl_loans       loans,
           igf_aw_award       awd,
           igf_ap_fa_base_rec fa,
           igf_ap_person_v    prsn,
           igs_pe_person_v    parent
    WHERE  lor.loan_id              = x_loan_id
    AND    lor.loan_id              = loans.loan_id
    AND    loans.award_id           = awd.award_id
    AND    awd.base_id              = fa.base_id
    AND    fa.person_id             = prsn.person_id
    AND    NVL( lor.p_person_id, 0) = parent.person_id (+);


  --Get the Student Person,Parent Person and Loan Number for the current Loan ID
  CURSOR cur_get_loans(p_ln_id igf_sl_loans_all.loan_id%TYPE) IS
    SELECT student_id,p_person_id,loan_number
    FROM   igf_sl_lor_v
    WHERE  loan_id=p_ln_id;

  l_loan_rec            cur_get_loans%ROWTYPE;
  l_loan_rec_det        cur_get_loans%ROWTYPE;

  l_ci_cal_type         igf_sl_dl_setup_v.ci_cal_type%TYPE;
  l_ci_sequence_number  igf_sl_dl_setup_v.ci_sequence_number%TYPE;
  l_alternate_code      igs_ca_inst.alternate_code%TYPE;
  l_batch_seq_num       NUMBER(15);
  l_no_of_pnotes        NUMBER;
  l_person_phone        igf_sl_dl_pnote_p_p.s_phone%TYPE;
  l_parent_phone        igf_sl_dl_pnote_p_p.p_phone%TYPE;
  l_rowid               VARCHAR2(30);
  l_log_mesg            VARCHAR2(2000);
  l_pnsp_id             igf_sl_dl_pnote_s_p.pnsp_id%TYPE;
  l_pnpp_id             igf_sl_dl_pnote_p_p.pnpp_id%TYPE;
  l_person_num          igf_aw_award_v.person_number%TYPE;
  l_heading             VARCHAR2(100);
  l_stud_number         igf_aw_award_v.person_number%TYPE;
  l_parent_number       igf_aw_award_v.person_number%TYPE;
  l_ret                 BOOLEAN DEFAULT FALSE;
  l_prnt_ln             igf_sl_loans_all.loan_number%TYPE;

  r_pnote               c_pnote_check%ROWTYPE;
  r_dl_orig_rec         c_dl_orig_recs%ROWTYPE;
  r_dl_lor_rec          c_lor_rec%ROWTYPE;
  r_stafford_det        c_stafford_det%ROWTYPE;
  r_plus_det            c_plus_det%ROWTYPE;

  l_lookup_type         igf_lookups_view.lookup_type%TYPE;
  l_pnote_status        igf_sl_lor_v.pnote_status%TYPE;

  l_current_per_num    igf_aw_award_v.person_number%TYPE;

  SKIP_LOAN_RECORD      EXCEPTION;

  --Internal Procedure to display LOG Message
  PROCEDURE log_message(p_stud_id igf_ap_fa_base_rec_all.person_id%TYPE,p_ln_number igf_sl_loans_all.loan_number%TYPE)  IS
  /***************************************************************
   Created By           :       mesriniv
   Date Created By      :       2002/06/25
   Purpose              :
   Known Limitations,Enhancements or Remarks
   Change History       :
   Who                  When            What
  **************************************************************/
  BEGIN
  --Display message Promissory Note Processed for Person Number:-
        l_ret:=igf_gr_gen.get_per_num(p_stud_id,l_current_per_num);

        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_SL_PROC_PROM');
        fnd_message.set_token('P_STUD',l_current_per_num);
        fnd_message.set_token('P_LOAN',p_ln_number);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
  END log_message;

  PROCEDURE update_pnote_status(
                                   p_loan_id igf_sl_loans_all.loan_id%TYPE
                               ) AS
   ------------------------------------------------------------------
    --Created by  : veramach, Oracle India
    --Date created: 22-SEP-2003
    --
    --Purpose:
    --   Update pnote status in igf_sl_lor table from G to P
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------
    --akomurav    28-FEB-2006     Build FA161 and FA162.
    --                            TBH Impact change done in igf_sl_lor_pkg.update_row().
    ----------------------------------------------------------------------------------
    --bkkumar    06-oct-2003  Bug 3104228 FA 122 Loans Enhancements
    --                        Impact of adding the relationship_cd
    --                        in igf_sl_lor_all table and obsoleting
    --                        BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
    --                        GUARANTOR_ID, DUNS_GUARNT_ID,
    --                        LENDER_ID, DUNS_LENDER_ID
    --                        LEND_NON_ED_BRC_ID, RECIPIENT_ID
    --                        RECIPIENT_TYPE,DUNS_RECIP_ID
    --                        RECIP_NON_ED_BRC_ID columns.
----------------------------------------------------------------------------------
    --veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
    --                                    cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
    --                                    p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
    --                                    chg_batch_id,appl_send_error_codes from igf_sl_lor
    -------------------------------------------------------------------

  BEGIN
      /* If the loan id is processed,
         Set the PNote Status for this loan ID as 'Printed'
      */
      FOR r_dl_lor_rec IN c_lor_rec( p_loan_id )
      LOOP
      BEGIN
           IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
             l_debug_str := l_debug_str || ' Before updating igf_sl_lor : loan_id ' || p_loan_id;
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.update_pnote_status.debug', l_debug_str);
             l_debug_str := NULL;
           END IF;

          igf_sl_lor_pkg.update_row (
            X_mode                              => 'R',
            x_rowid                             => r_dl_lor_rec.row_id,
            x_origination_id                    => r_dl_lor_rec.origination_id,
            x_loan_id                           => p_loan_id,
            x_sch_cert_date                     => r_dl_lor_rec.sch_cert_date,
            x_orig_status_flag                  => r_dl_lor_rec.orig_status_flag,
            x_orig_batch_id                     => r_dl_lor_rec.orig_batch_id,
            x_orig_batch_date                   => r_dl_lor_rec.orig_batch_date,
            x_chg_batch_id                      => NULL,
            x_orig_ack_date                     => r_dl_lor_rec.orig_ack_date,
            x_credit_override                   => r_dl_lor_rec.credit_override,
            x_credit_decision_date              => r_dl_lor_rec.credit_decision_date,
            x_req_serial_loan_code              => r_dl_lor_rec.req_serial_loan_code,
            x_act_serial_loan_code              => r_dl_lor_rec.act_serial_loan_code,
            x_pnote_delivery_code               => r_dl_lor_rec.pnote_delivery_code,
            x_pnote_status                      => 'P',
            x_pnote_status_date                 => r_dl_lor_rec.pnote_status_date,
            x_pnote_id                          => r_dl_lor_rec.pnote_id,
            x_pnote_print_ind                   => r_dl_lor_rec.pnote_print_ind,
            x_pnote_accept_amt                  => r_dl_lor_rec.pnote_accept_amt,
            x_pnote_accept_date                 => r_dl_lor_rec.pnote_accept_date,
            x_unsub_elig_for_heal               => r_dl_lor_rec.unsub_elig_for_heal,
            x_disclosure_print_ind              => r_dl_lor_rec.disclosure_print_ind,
            x_orig_fee_perct                    => r_dl_lor_rec.orig_fee_perct,
            x_borw_confirm_ind                  => r_dl_lor_rec.borw_confirm_ind,
            x_borw_interest_ind                 => r_dl_lor_rec.borw_interest_ind,
            x_borw_outstd_loan_code             => r_dl_lor_rec.borw_outstd_loan_code,
            x_unsub_elig_for_depnt              => r_dl_lor_rec.unsub_elig_for_depnt,
            x_guarantee_amt                     => r_dl_lor_rec.guarantee_amt,
            x_guarantee_date                    => r_dl_lor_rec.guarantee_date,
            x_guarnt_amt_redn_code              => r_dl_lor_rec.guarnt_amt_redn_code,
            x_guarnt_status_code                => r_dl_lor_rec.guarnt_status_code,
            x_guarnt_status_date                => r_dl_lor_rec.guarnt_status_date,
            x_lend_apprv_denied_code            => NULL,
            x_lend_apprv_denied_date            => NULL,
            x_lend_status_code                  => r_dl_lor_rec.lend_status_code,
            x_lend_status_date                  => r_dl_lor_rec.lend_status_date,
            x_guarnt_adj_ind                    => r_dl_lor_rec.guarnt_adj_ind,
            x_grade_level_code                  => r_dl_lor_rec.grade_level_code,
            x_enrollment_code                   => r_dl_lor_rec.enrollment_code,
            x_anticip_compl_date                => r_dl_lor_rec.anticip_compl_date,
            x_borw_lender_id                    => NULL,
            x_duns_borw_lender_id               => NULL,
            x_guarantor_id                      => NULL,
            x_duns_guarnt_id                    => NULL,
            x_prc_type_code                     => r_dl_lor_rec.prc_type_code,
            x_cl_seq_number                     => r_dl_lor_rec.cl_seq_number,
            x_last_resort_lender                => r_dl_lor_rec.last_resort_lender,
            x_lender_id                         => NULL,
            x_duns_lender_id                    => NULL,
            x_lend_non_ed_brc_id                => NULL,
            x_recipient_id                      => NULL,
            x_recipient_type                    => NULL,
            x_duns_recip_id                     => NULL,
            x_recip_non_ed_brc_id               => NULL,
            x_rec_type_ind                      => r_dl_lor_rec.rec_type_ind,
            x_cl_loan_type                      => r_dl_lor_rec.cl_loan_type,
            x_cl_rec_status                     => NULL,
            x_cl_rec_status_last_update         => NULL,
            x_alt_prog_type_code                => r_dl_lor_rec.alt_prog_type_code,
            x_alt_appl_ver_code                 => r_dl_lor_rec.alt_appl_ver_code,
            x_mpn_confirm_code                  => NULL,
            x_resp_to_orig_code                 => r_dl_lor_rec.resp_to_orig_code,
            x_appl_loan_phase_code              => NULL,
            x_appl_loan_phase_code_chg          => NULL,
            x_appl_send_error_codes             => NULL,
            x_tot_outstd_stafford               => r_dl_lor_rec.tot_outstd_stafford,
            x_tot_outstd_plus                   => r_dl_lor_rec.tot_outstd_plus,
            x_alt_borw_tot_debt                 => r_dl_lor_rec.alt_borw_tot_debt,
            x_act_interest_rate                 => r_dl_lor_rec.act_interest_rate,
            x_service_type_code                 => r_dl_lor_rec.service_type_code,
            x_rev_notice_of_guarnt              => r_dl_lor_rec.rev_notice_of_guarnt,
            x_sch_refund_amt                    => r_dl_lor_rec.sch_refund_amt,
            x_sch_refund_date                   => r_dl_lor_rec.sch_refund_date,
            x_uniq_layout_vend_code             => r_dl_lor_rec.uniq_layout_vend_code,
            x_uniq_layout_ident_code            => r_dl_lor_rec.uniq_layout_ident_code,
            x_p_person_id                       => r_dl_lor_rec.p_person_id,
            x_p_ssn_chg_date                    => NULL,
            x_p_dob_chg_date                    => NULL,
            x_p_permt_addr_chg_date             => r_dl_lor_rec.p_permt_addr_chg_date,
            x_p_default_status                  => r_dl_lor_rec.p_default_status,
            x_p_signature_code                  => r_dl_lor_rec.p_signature_code,
            x_p_signature_date                  => r_dl_lor_rec.p_signature_date,
            x_s_ssn_chg_date                    => NULL,
            x_s_dob_chg_date                    => NULL,
            x_s_permt_addr_chg_date             => r_dl_lor_rec.s_permt_addr_chg_date,
            x_s_local_addr_chg_date             => NULL,
            x_s_default_status                  => r_dl_lor_rec.s_default_status,
            x_s_signature_code                  => r_dl_lor_rec.s_signature_code,
            x_pnote_batch_id                    => r_dl_lor_rec.pnote_batch_id,
            x_pnote_ack_date                    => r_dl_lor_rec.pnote_ack_date,
            x_pnote_mpn_ind                     => r_dl_lor_rec.pnote_mpn_ind,
            x_elec_mpn_ind                      => r_dl_lor_rec.elec_mpn_ind,
            x_borr_sign_ind                     => r_dl_lor_rec.borr_sign_ind,
            x_stud_sign_ind                     => r_dl_lor_rec.stud_sign_ind,
            x_borr_credit_auth_code             => r_dl_lor_rec.borr_credit_auth_code,
            x_relationship_cd                   => r_dl_lor_rec.relationship_cd,
            x_interest_rebate_percent_num       => r_dl_lor_rec.interest_rebate_percent_num,
            x_cps_trans_num                     => r_dl_lor_rec.cps_trans_num,
            x_atd_entity_id_txt                 => r_dl_lor_rec.atd_entity_id_txt ,
            x_rep_entity_id_txt                 => r_dl_lor_rec.rep_entity_id_txt,
            x_crdt_decision_status              => r_dl_lor_rec.crdt_decision_status,
            x_note_message                      => r_dl_lor_rec.note_message,
              x_book_loan_amt                   => r_dl_lor_rec.book_loan_amt ,
            x_book_loan_amt_date                => r_dl_lor_rec.book_loan_amt_date,
            x_pymt_servicer_amt                 => r_dl_lor_rec.pymt_servicer_amt,
            x_pymt_servicer_date                => r_dl_lor_rec.pymt_servicer_date,
            x_requested_loan_amt                => r_dl_lor_rec.requested_loan_amt,
            x_eft_authorization_code            => r_dl_lor_rec.eft_authorization_code,
            x_external_loan_id_txt              => r_dl_lor_rec.external_loan_id_txt,
            x_deferment_request_code            => r_dl_lor_rec.deferment_request_code ,
            x_actual_record_type_code           => r_dl_lor_rec.actual_record_type_code,
            x_reinstatement_amt                 => r_dl_lor_rec.reinstatement_amt,
            x_school_use_txt                    => r_dl_lor_rec.school_use_txt,
            x_lender_use_txt                    => r_dl_lor_rec.lender_use_txt,
            x_guarantor_use_txt                 => r_dl_lor_rec.guarantor_use_txt,
            x_fls_approved_amt                  => r_dl_lor_rec.fls_approved_amt,
            x_flu_approved_amt                  => r_dl_lor_rec.flu_approved_amt,
            x_flp_approved_amt                  => r_dl_lor_rec.flp_approved_amt,
            x_alt_approved_amt                  => r_dl_lor_rec.alt_approved_amt,
            x_loan_app_form_code                => r_dl_lor_rec.loan_app_form_code,
            x_override_grade_level_code         => r_dl_lor_rec.override_grade_level_code,
            x_b_alien_reg_num_txt               => r_dl_lor_rec.b_alien_reg_num_txt,
            x_esign_src_typ_cd                  => r_dl_lor_rec.esign_src_typ_cd,
            x_acad_begin_date                   => r_dl_lor_rec.acad_begin_date,
            x_acad_end_date                     => r_dl_lor_rec.acad_end_date
         );
           IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
             l_debug_str := l_debug_str || 'Updated igf_sl_lor : loan_id ' || p_loan_id;
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.update_pnote_status.debug', l_debug_str);
             l_debug_str := NULL;
           END IF;

      END;

    END LOOP;  /* End of r_dl_lor_rec loop (i.e) end of update lor rec loop */

  END update_pnote_status;


  BEGIN
    RETCODE:=0;

    igf_aw_gen.set_org_id(p_org_id);

    l_batch_seq_num := NULL;
    l_no_of_pnotes  := 0;

    l_ci_cal_type := LTRIM(RTRIM(SUBSTR( p_award_year,1,10)));
    l_ci_sequence_number := TO_NUMBER(SUBSTR( p_award_year,11));

    l_alternate_code :=igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);
    l_heading :=igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER');

    --Display all Headings


    l_log_mesg :=igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS');
    fnd_file.put_line(fnd_file.log, l_log_mesg);
    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','CI_ALTERNATE_CODE'),80,' ') ||':'||RPAD(' ',4,' ')||l_alternate_code ;
    fnd_file.put_line(fnd_file.log, l_log_mesg);

    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_CATG'),80,' ')||':'||RPAD(' ',4,' ')||
                                                              igf_aw_gen.lookup_desc('IGF_SL_DL_LOAN_CATG',p_loan_catg) ;
    fnd_file.put_line(fnd_file.log, l_log_mesg);

    --Display the Person Number for the Base ID
    l_person_num :=NULL;
    IF p_base_id IS NOT NULL  THEN
       l_person_num:=igf_gr_gen.get_per_num(p_base_id);
    END IF;


    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),80,' ')||':'||RPAD(' ',4,' ')||l_person_num ;
    fnd_file.put_line(fnd_file.log, l_log_mesg);

    l_log_mesg := RPAD(l_heading,80,' ')||':'||RPAD(' ',4,' ')|| NVL( p_loan_number , NULL );
    fnd_file.put_line(fnd_file.log, l_log_mesg);

    fnd_file.new_line(fnd_file.log, 1);

    /* Check if school is configured to print */
    OPEN c_pnote_check( l_ci_cal_type, l_ci_sequence_number );
    FETCH c_pnote_check INTO r_pnote;
    IF ( c_pnote_check%NOTFOUND ) THEN
      CLOSE c_pnote_check;
      fnd_message.set_name('IGF', 'IGF_SL_NO_DL_SETUP');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_pnote_check;

    /* The school is not configured to print, so exit after displaying a message */
    IF ( r_pnote.pnote_print_ind <> 'F' ) THEN
      fnd_message.set_name('IGF', 'IGF_SL_PNOTE_SCH_NOPRNT');
      fnd_message.set_token('AWD_YR', r_pnote.ci_alternate_code );
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;


    /* Get all DL orig recs with Pnote status as 'Ready to Print' */
    l_pnote_status := 'G'; /*Ready to print */

    IF p_loan_catg = 'DL_STAFFORD' THEN
       l_lookup_type := 'IGF_SL_DL_STAFFORD';
    END IF;

    IF p_loan_catg = 'DL_PLUS' THEN
       l_lookup_type := 'IGF_SL_DL_PLUS';
    END IF;

    FOR r_dl_orig_rec IN c_dl_orig_recs( l_ci_cal_type, l_ci_sequence_number , p_loan_number, p_base_id , l_pnote_status,l_lookup_type)
    LOOP
    BEGIN

      IF ( p_loan_catg = 'DL_STAFFORD' ) THEN

        /* Get person details for this loan id  */
        OPEN c_stafford_det( r_dl_orig_rec.loan_id );
        FETCH c_stafford_det INTO r_stafford_det;
        IF c_stafford_det%FOUND THEN
          CLOSE c_stafford_det;

          l_loan_rec:=NULL;
          OPEN cur_get_loans(r_dl_orig_rec.loan_id);
          FETCH cur_get_loans INTO l_loan_rec;
          CLOSE cur_get_loans;

          IF l_loan_rec.student_id IS NOT NULL THEN
             l_ret:=igf_gr_gen.get_per_num(l_loan_rec.student_id,l_stud_number);
          END IF;

          --Fetch details of student
          igf_sl_gen.get_person_details(r_stafford_det.student_id,student_dtl_cur);
          FETCH student_dtl_cur INTO student_dtl_rec;

          IF student_dtl_rec.p_permt_addr1 IS NULL THEN

            CLOSE student_dtl_cur;
            --Display message in Log File that "Home" address not available for Student and Skip record.
            fnd_file.new_line(fnd_file.log,1);
            fnd_file.put_line(fnd_file.log,l_heading||':    '||l_loan_rec.loan_number);
            fnd_message.set_name('IGF','IGF_SL_NO_S_HOME_ADDR');
            fnd_message.set_token('P_STUD',l_stud_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            RAISE SKIP_LOAN_RECORD;

          END IF;

          /* Get phone details */
          l_person_phone := igf_sl_gen.get_person_phone( r_stafford_det.student_id );

          IF l_batch_seq_num IS NULL THEN
            SELECT igf_sl_dl_pnote_bth_s.nextval INTO l_batch_seq_num FROM dual;
          END IF;

          --Inorder to rollback this Transaction whenever Lock Error happens
          SAVEPOINT sp_prom_note;
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || 'Before inserting into igf_sl_dl_pnote_s_p';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.process_pnote.debug', l_debug_str);
            l_debug_str := NULL;
          END IF;

          /* Insert into IGF_SL_DL_PNOTE_S_P */
          igf_sl_dl_pnote_s_p_pkg.insert_row(
               x_mode                           => 'R',
               x_rowid                          => l_rowid,
               x_pnsp_id                        =>  l_pnsp_id,
               x_batch_seq_num                  =>  l_batch_seq_num,
               x_loan_id                        =>  r_dl_orig_rec.loan_id,
               x_loan_number                    =>  r_stafford_det.loan_number,
               x_person_id                      =>  r_stafford_det.student_id,
               x_s_ssn                          =>  SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(r_stafford_det.s_ssn),1,9),
               x_s_first_name                   =>  r_stafford_det.given_names,
               x_s_last_name                    =>  r_stafford_det.surname,
               x_s_middle_name                  =>  r_stafford_det.middle_name,
               x_s_date_of_birth                =>  r_stafford_det.birth_dt,
               x_s_license_num                  =>  student_dtl_rec.p_license_num,
               x_s_license_state                =>  student_dtl_rec.p_license_state,
               x_s_permt_addr1                  =>  student_dtl_rec.p_permt_addr1,
               x_s_permt_addr2                  =>  student_dtl_rec.p_permt_addr2,
               x_s_permt_city                   =>  student_dtl_rec.p_permt_city,
               x_s_permt_state                  =>  student_dtl_rec.p_permt_state,
               x_s_permt_zip                    =>  student_dtl_rec.p_permt_zip,
               x_s_email_addr                   =>  student_dtl_rec.p_email_addr,
               x_s_phone                        =>  l_person_phone,
               x_status                         =>  'N'   /* not printed */
          );
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || 'Inserted into igf_sl_dl_pnote_s_p';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.process_pnote.debug', l_debug_str);
            l_debug_str := NULL;
          END IF;

          --Since the loan is processed, call update_pnote_status to update the pnote_status to 'printed'

          update_pnote_status(r_dl_orig_rec.loan_id);

          CLOSE student_dtl_cur;
        END IF;

        IF c_stafford_det%ISOPEN THEN
          CLOSE c_stafford_det;
        END IF;

      ELSIF ( p_loan_catg = 'DL_PLUS' ) THEN

        /* Insert into IGF_SL_DL_PNOTE_P_P */
        /* Get person details for this loan id  */
        OPEN c_plus_det( r_dl_orig_rec.loan_id );
        FETCH c_plus_det INTO r_plus_det;

        IF c_plus_det%FOUND THEN
          CLOSE c_plus_det;

          l_loan_rec:=NULL;
          OPEN cur_get_loans(r_dl_orig_rec.loan_id);
          FETCH cur_get_loans INTO l_loan_rec;
          CLOSE cur_get_loans;
          l_stud_number :=NULL;
          l_parent_number:=NULL;

          --Get Student Person Number
          IF l_loan_rec.student_id IS NOT NULL THEN
            l_ret:=igf_gr_gen.get_per_num(l_loan_rec.student_id,l_stud_number);
          END IF;

          --Get Parent Person Number
          IF l_loan_rec.p_person_id IS NOT NULL THEN
            l_ret:=igf_gr_gen.get_per_num(l_loan_rec.p_person_id,l_parent_number);
          END IF;

          --Fetch details of student and parent
          igf_sl_gen.get_person_details(r_plus_det.student_id,student_dtl_cur);
          FETCH student_dtl_cur INTO student_dtl_rec;

          igf_sl_gen.get_person_details(r_plus_det.p_person_id,parent_dtl_cur);
          FETCH parent_dtl_cur INTO parent_dtl_rec;


          IF student_dtl_rec.p_permt_addr1 IS NULL OR parent_dtl_rec.p_permt_addr1 IS NULL THEN
            --Display message in Log File that "Home" Address not present for Student and Parent and Skip record.
            fnd_file.new_line(fnd_file.log,1);
            fnd_file.put_line(fnd_file.log,l_heading||':    '||l_loan_rec.loan_number);
            fnd_message.set_name('IGF','IGF_SL_NO_SP_HOME_ADDR');
            fnd_message.set_token('P_STUD',l_stud_number);
            fnd_message.set_token('P_PAR',l_parent_number);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            fnd_file.new_line(fnd_file.log,1);
            RAISE SKIP_LOAN_RECORD;
          END IF;


          /* Get phone details */
          l_person_phone := igf_sl_gen.get_person_phone( r_plus_det.student_id ) ;
          l_parent_phone := igf_sl_gen.get_person_phone( r_plus_det.p_person_id );


          IF l_batch_seq_num IS NULL THEN
            SELECT igf_sl_dl_pnote_bth_s.nextval INTO l_batch_seq_num FROM dual;
          END IF;

          --Transaction to be rolled back whenever Lock Error
          SAVEPOINT sp_prom_note;
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || 'Before inserting into igf_sl_dl_pnote_p_p';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.process_pnote.debug', l_debug_str);
            l_debug_str := NULL;
          END IF;

          --insert into igf_sl_dl_pnote_p_p table
          igf_sl_dl_pnote_p_p_pkg.insert_row(
                   x_mode                           => 'R',
                   x_rowid                          => l_rowid,
                   x_pnpp_id                        => l_pnpp_id,
                   x_batch_seq_num                  => l_batch_seq_num,
                   x_loan_id                        => r_dl_orig_rec.loan_id,
                   x_loan_number                    => r_plus_det.loan_number,
                   x_loan_amt_offered               => r_plus_det.loan_amt_offered,
                   x_loan_amt_accepted              => r_plus_det.loan_amt_accepted,
                   x_loan_per_begin_date            => r_plus_det.loan_per_begin_date,
                   x_loan_per_end_date              => r_plus_det.loan_per_end_date,
                   x_person_id                      => r_plus_det.student_id,
                   x_s_ssn                          => SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(r_plus_det.s_ssn),1,9),
                   x_s_first_name                   => r_plus_det.given_names,
                   x_s_last_name                    => r_plus_det.surname,
                   x_s_middle_name                  => r_plus_det.middle_name,
                   x_s_date_of_birth                => r_plus_det.birth_dt,
                   x_s_citizenship_status           => student_dtl_rec.p_citizenship_status,
                   x_s_alien_reg_number             => student_dtl_rec.p_alien_reg_num,
                   x_s_license_num                  => student_dtl_rec.p_license_num,
                   x_s_license_state                => student_dtl_rec.p_license_state,
                   x_s_permt_addr1                  => student_dtl_rec.p_permt_addr1,
                   x_s_permt_addr2                  => student_dtl_rec.p_permt_addr2,
                   x_s_permt_city                   => student_dtl_rec.p_permt_city,
                   x_s_permt_state                  => student_dtl_rec.p_permt_state,
                   x_s_permt_province               => student_dtl_rec.p_province,
                   x_s_permt_county                 => student_dtl_rec.p_county,
                   x_s_permt_country                => student_dtl_rec.p_country,
                   x_s_permt_zip                    => student_dtl_rec.p_permt_zip,
                   x_s_email_addr                   => student_dtl_rec.p_email_addr,
                   x_s_phone                        => l_person_phone,
                   x_p_person_id                    => r_plus_det.p_person_id,
                   x_p_ssn                          => SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(r_plus_det.api_person_id),1,9),
                   x_p_last_name                    => parent_dtl_rec.p_last_name,
                   x_p_first_name                   => parent_dtl_rec.p_first_name,
                   x_p_middle_name                  => parent_dtl_rec.p_middle_name,
                   x_p_date_of_birth                => parent_dtl_rec.p_date_of_birth,
                   x_p_citizenship_status           => parent_dtl_rec.p_citizenship_status,
                   x_p_alien_reg_num                => parent_dtl_rec.p_alien_reg_num,
                   x_p_license_num                  => parent_dtl_rec.p_license_num,
                   x_p_license_state                => parent_dtl_rec.p_license_state,
                   x_p_permt_addr1                  => parent_dtl_rec.p_permt_addr1,
                   x_p_permt_addr2                  => parent_dtl_rec.p_permt_addr2,
                   x_p_permt_city                   => parent_dtl_rec.p_permt_city,
                   x_p_permt_state                  => parent_dtl_rec.p_permt_state,
                   x_p_permt_province               => parent_dtl_rec.p_province,
                   x_p_permt_county                 => parent_dtl_rec.p_county,
                   x_p_permt_country                => parent_dtl_rec.p_country,
                   x_p_permt_zip                    => parent_dtl_rec.p_permt_zip,
                   x_p_email_addr                   => parent_dtl_rec.p_email_addr,
                   x_p_phone                        => l_parent_phone,
                   x_status                         => 'N'  /* Not printed */
             );
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || 'Inserted into igf_sl_dl_pnote_s';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_print_pnote.process_pnote.debug', l_debug_str);
            l_debug_str := NULL;
          END IF;

          --Since the loan is processed, call update_pnote_status to update the pnote_status to 'printed'
          update_pnote_status(r_dl_orig_rec.loan_id);
          CLOSE student_dtl_cur;
          CLOSE parent_dtl_cur;
          IF c_plus_det%ISOPEN THEN
            CLOSE c_plus_det;
          END IF;

        END IF;

      END IF;   /* End of loan category IF check */

      --Call procedure to log message
      IF p_loan_catg='DL_PLUS' THEN
         log_message(r_plus_det.student_id,r_plus_det.loan_number);
      ELSIF p_loan_catg ='DL_STAFFORD' THEN
         log_message(r_stafford_det.student_id,r_stafford_det.loan_number);
      END IF;

      /* Increment the no of promissory notes processed correctly */
      l_no_of_pnotes := l_no_of_pnotes + 1;

      EXCEPTION
      WHEN app_exception.record_lock_exception THEN

        l_loan_rec_det:=NULL;
        OPEN cur_get_loans(r_dl_orig_rec.loan_id);
        FETCH cur_get_loans INTO l_loan_rec_det;

        CLOSE cur_get_loans;

        fnd_file.new_line(fnd_file.log,1);
        fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.put_line(fnd_file.log,l_heading||':    '||l_loan_rec_det.loan_number);
        fnd_file.new_line(fnd_file.log,1);
        ROLLBACK TO sp_prom_note;

      WHEN SKIP_LOAN_RECORD THEN
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log,fnd_message.get);

      END ;

    END LOOP;  /* End of r_dl_orig_rec loop  (i.e) end of the DL Orig recs loop */

    /* Display the details in the Log file */
    fnd_file.new_line(fnd_file.log, 2);

    fnd_message.set_name('IGF', 'IGF_SL_NO_OF_PNOTES');
    fnd_message.set_token('NO_OF_PNOTES', l_no_of_pnotes );
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    IF l_batch_seq_num IS NOT NULL THEN

      fnd_message.set_name('IGF', 'IGF_SL_PNOTE_BATCH_SEQNO');
      fnd_message.set_token('PNOTE_BATCH_SEQNO', NVL( l_batch_seq_num, NULL) );
      fnd_file.put_line(fnd_file.log, fnd_message.get);

   END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN app_exception.record_lock_exception THEN
      ROLLBACK;
      retcode := 2;
      errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE :=2;
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_sl_dl_print_pnote.process_pnote.exception', l_debug_str || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_sl_dl_print_pnote.process_pnote');

      ERRBUF := fnd_message.get;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END process_pnote;

END igf_sl_dl_print_pnote;

/
