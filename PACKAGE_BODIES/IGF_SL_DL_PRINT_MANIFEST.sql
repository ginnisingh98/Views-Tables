--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_PRINT_MANIFEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_PRINT_MANIFEST" AS
/* $Header: IGFSL17B.pls 120.1 2006/04/18 04:21:46 akomurav noship $ */
/*****************************************************************
  Created By :      rboddu
  Date Created On : 2001/05/14
-------------------------------------------------------------------------------------
-- akomurav     28-Jan-2006    Build FA161 and FA162.
                               TBH Impact change done in process_manifest().
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
  Purpose : Bug :- 2426609 SSN Format Incorrect in Output File
  Who             When            What
  mesriniv        21-jun-2002     While inserting Student SSN/Parent SSN
                                  formatting and substr of 9 chars is done.
  Know limitations, enhancements or remarks
  Change History:
  Who             When            What
  adhawan         20-nov-2002     gscc fix removing the default
  2669341
  adhawan         20-feb-2002     added elec_mpn_ind,
  2216956                         borr_sign_ind,stud_sign_ind,
                                  borr_credit_auth_code in the call to update row of igf_sl_lor tbh
                                  changed the parameter in the process_manifest to receive base_id instead of student id and then
                                  deriving the student id value
   (reverse chronological order - newest change first)
  *****************************************************************/

  PROCEDURE  process_manifest(
                                        ERRBUF          OUT NOCOPY    VARCHAR2,
                                        RETCODE         OUT NOCOPY    NUMBER,
                                        p_award_year    IN     VARCHAR2,
                                        p_loan_catg     IN     igf_lookups_view.lookup_code%TYPE,
                                        p_base_id       IN     igf_aw_award.base_id%TYPE,  -- modified to receive base_id instead of student id
                                        p_loan_number   IN     igf_sl_loans_v.loan_number%TYPE,
                                        p_org_id        IN     NUMBER
                             )
  AS
  /*****************************************************************
  Created By :      rboddu
  Date Created On : 2001/05/14
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who        When            What
  akomurav   28-Feb-2006     Build FA161 and FA162.
                             TBH Impact change done in igf_sl_lor_pkg.update_row().

  veramach   23-SEP-2003     Bug 3104228: Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
   (reverse chronological order - newest change first)
  *****************************************************************/

 /* Local Variable Declaration */

  l_ci_cal_type          igf_sl_dl_setup.ci_cal_type%TYPE;
  l_ci_sequence_number   igf_sl_dl_setup.ci_sequence_number%TYPE;
  l_print_option         igf_sl_dl_setup_v.pnote_print_ind%TYPE;
  l_batch_seq_num        NUMBER;
  l_id                   igf_sl_dl_manifest.pnmn_id%TYPE;
  l_row_id               igf_sl_dl_manifest.row_id%TYPE;
  l_log_mesg             VARCHAR2(2000);
  l_total_pnote          NUMBER := 0;
  l_awd_year             igf_sl_dl_setup_v.ci_alternate_code%TYPE;
  l_person_num           igf_aw_award_v.person_number%TYPE;
  l_alternate_code       igs_ca_inst.alternate_code%TYPE;
  l_heading              VARCHAR2(2000);

  /* get the print configuration status of the school for the given award year */
  CURSOR c_prnt_ind(l_cal igf_sl_dl_setup.ci_cal_type%TYPE, l_seq igf_sl_dl_setup.ci_sequence_number%TYPE) IS
  SELECT pnote_print_ind, ci_alternate_code
  FROM   igf_sl_dl_setup_v
  WHERE  ci_cal_type        = l_cal
  AND    ci_sequence_number = l_seq;

  /* get all the records which have the pnote_status set as 'Signed' for the given award year,loan_category etc */
  CURSOR c_lor_signed(l_cal igf_sl_dl_setup.ci_cal_type%TYPE,
                      l_seq igf_sl_dl_setup.ci_sequence_number%TYPE,
                      cp_person_id igf_ap_fa_base_rec.person_id%TYPE) IS
  SELECT  lor.student_id,
          lor.p_person_id,
          lor.loan_id,
          lor.loan_number,
          per.api_person_id,
          per.given_names,
          per.surname,
          per.middle_name
  FROM  igf_sl_lor_v     lor,
        igf_ap_person_v  per
  WHERE lor.pnote_status = 'S' /* Check for pnote_status  'Signed' */
  AND  lor.fed_fund_code IN   (SELECT DISTINCT lookup_code
                               FROM igf_lookups_view
                               WHERE lookup_type = DECODE(p_loan_catg,'DL_STAFFORD','IGF_SL_DL_STAFFORD','DL_PLUS','IGF_SL_DL_PLUS')
                               )
  AND  lor.ci_cal_type        =  l_cal  /* Check for given Award Year */
  AND  lor.ci_sequence_number =  l_seq
  AND  lor.student_id          = NVL(cp_person_id, lor.student_id)
  AND  lor.loan_number        =  NVL(p_loan_number, lor.loan_number)
  AND  per.person_id          =  DECODE(p_loan_catg,'DL_STAFFORD',lor.student_id,lor.p_person_id);

  /* get all records from igf_sl_lor for the given loan_id */
  CURSOR c_lor_rec(lor_loan_id igf_sl_lor.loan_id%TYPE) IS
  SELECT igf_sl_lor.*
  FROM   igf_sl_lor
  WHERE  loan_id = lor_loan_id FOR UPDATE OF igf_sl_lor.pnote_status NOWAIT;



  r_lor_signed           c_lor_signed%ROWTYPE;
  r_dl_lor_rec           c_lor_rec%ROWTYPE;

  TYPE get_student_ref IS REF CURSOR;
    get_student_rec  get_student_ref;
    l_person_id      igf_ap_fa_base_rec.person_id%TYPE;

  BEGIN

   RETCODE := 0;
   igf_aw_gen.set_org_id(p_org_id);


    l_ci_cal_type         := ltrim(rtrim(SUBSTR(p_award_year,1,10)));
    l_ci_sequence_number  := ltrim(rtrim(SUBSTR(p_award_year,11)));

    l_alternate_code :=igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number);
    l_heading :=igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER');

    l_log_mesg :=igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS');
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_mesg);

    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','CI_ALTERNATE_CODE'),80,' ') ||':'||RPAD(' ',4,' ')||l_alternate_code ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_mesg);

    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_CATG'),80,' ')||':'||RPAD(' ',4,' ')||
                                                              igf_aw_gen.lookup_desc('IGF_SL_DL_LOAN_CATG',p_loan_catg) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_mesg);

    --Display the Person Number for the Base ID
    l_person_num :=NULL;
    IF l_person_id IS NOT NULL  THEN
       l_person_num:=igf_gr_gen.get_per_num_oss(l_person_id);
    END IF;
     l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),80,' ')||':'||RPAD(' ',4,' ')||l_person_num ;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_mesg);

    l_log_mesg := RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER'),80)||':'||p_loan_number;
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_log_mesg);

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

   OPEN get_student_rec FOR
              select person_id  from igf_ap_fa_base_rec
              where base_id = p_base_id and  person_id  IS NOT NULL;
   FETCH get_student_rec INTO l_person_id ;
   CLOSE get_student_rec;


   OPEN c_prnt_ind(l_ci_cal_type,l_ci_sequence_number);
       FETCH c_prnt_ind INTO l_print_option,l_awd_year;
       IF c_prnt_ind%NOTFOUND THEN
           CLOSE c_prnt_ind;
           FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_NO_DL_SETUP');
           FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
           RAISE NO_DATA_FOUND;
       END IF;
    CLOSE c_prnt_ind;


      /* Check whether the School is configured to Print and Process Promissory Note or not. If not then display valid message in log file */

      IF ( l_print_option <> 'F' ) THEN
          FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_PNOTE_SCH_NOPRNT');
          FND_MESSAGE.SET_TOKEN('AWD_YR', l_awd_year );
          FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
          RETURN;
      END IF;


     /* For each 'Signed' Loan record in the current Batch, insert corresponding Student or Parent information into Manifest table
       Depending on whetner the Loan type is 'STAFFORD' or 'PLUS', respectively. This set of records is identified by a single Batch Sequence Number.*/


       /* insert the student(parent) details into igf_sl_manifest table with status as N (Not manifested) */
  FOR r_lor_signed IN c_lor_signed(l_ci_cal_type, l_ci_sequence_number,l_person_id)
   LOOP
   BEGIN

           IF l_batch_seq_num IS NULL THEN

         /* Get the unique sequence number to be assigned to the entire batch of records */
           SELECT igf_sl_dl_pnote_bth_s.nextval  INTO l_batch_seq_num     FROM DUAL;

           END IF;

            SAVEPOINT sp_prom_manifest;

            igf_sl_dl_manifest_pkg.insert_row(
               x_rowid                             => l_row_id,
               x_pnmn_id                           => l_id,
               x_batch_seq_num                     => l_batch_seq_num,
               x_loan_id                           => r_lor_signed.loan_id,
               x_loan_number                       => r_lor_signed.loan_number,
               x_b_ssn                             => SUBSTR(igf_ap_matching_process_pkg.remove_spl_chr(r_lor_signed.api_person_id),1,9),
               x_b_first_name                      => r_lor_signed.given_names,
               x_b_last_name                       => r_lor_signed.surname,
               x_b_middle_name                     => r_lor_signed.middle_name,
               x_status                            => 'N',
               x_mode                              => 'R'
                                              );


     /* Set the PNote Status for this loan ID as 'Printed' in igf_sl_lor table */
      FOR r_dl_lor_rec IN c_lor_rec( r_lor_signed.loan_id )

      LOOP
          igf_sl_lor_pkg.update_row (
            X_mode                              => 'R',
            x_rowid                             => r_dl_lor_rec.row_id,
            x_origination_id                    => r_dl_lor_rec.origination_id,
            x_loan_id                           => r_dl_lor_rec.loan_id,
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
            x_pnote_status_date                 => TRUNC(SYSDATE),
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
            x_pnote_mpn_ind                     => r_dl_lor_rec.pnote_mpn_ind ,
            x_elec_mpn_ind	                => r_dl_lor_rec.elec_mpn_ind,         -- added as part of 2216956
            x_borr_sign_ind	                => r_dl_lor_rec.borr_sign_ind,
            x_stud_sign_ind	                => r_dl_lor_rec.stud_sign_ind,
            x_borr_credit_auth_code             => r_dl_lor_rec.borr_credit_auth_code, -- added as part of 2216956
            x_relationship_cd                   => r_dl_lor_rec.relationship_cd,
            x_interest_rebate_percent_num       => r_dl_lor_rec.interest_rebate_percent_num,
            x_cps_trans_num                     => r_dl_lor_rec.cps_trans_num,
            x_atd_entity_id_txt                 => r_dl_lor_rec.atd_entity_id_txt ,
            x_rep_entity_id_txt                 => r_dl_lor_rec.rep_entity_id_txt,
            x_crdt_decision_status              => r_dl_lor_rec.crdt_decision_status,
            x_note_message                      => r_dl_lor_rec.note_message,
              x_book_loan_amt                     => r_dl_lor_rec.book_loan_amt ,
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

        END LOOP;  -- End of r_dl_lor_rec loop (i.e) end of update lor rec loop

        -- Number of promissory notes processed currently
       l_total_pnote := l_total_pnote+1;


     EXCEPTION
      WHEN app_exception.record_lock_exception THEN

      fnd_file.put_line(fnd_file.log,' ');
      fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,l_heading||':    '||r_lor_signed.loan_number);
      fnd_message.set_name('IGF','IGF_SL_SKIPPING');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.put_line(fnd_file.log,' ');
      ROLLBACK TO sp_prom_manifest;

      END;

      END LOOP;   -- End of r_lor_signed loop (i.e) main loop

     /* Display the details in the Log file */
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');


    FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_NO_OF_PNOTES');
    FND_MESSAGE.SET_TOKEN('NO_OF_PNOTES', l_total_pnote );
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

    IF l_total_pnote = 0 THEN
       --There are no Signed Promissory Notes.Promissory Note Manifest has not been created.
       fnd_message.set_name('IGF','IGF_SL_NO_SIGN_PROMNOTE');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    IF l_batch_seq_num IS NOT NULL THEN

    FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_PNOTE_BATCH_SEQNO');
    FND_MESSAGE.SET_TOKEN('PNOTE_BATCH_SEQNO', NVL( l_batch_seq_num, NULL) );
    FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);

    END IF;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL;
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK;
      RETCODE := 2;
      ERRBUF := FND_MESSAGE.GET_STRING('IGF','IGF_GE_LOCK_ERROR');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE :=2;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igf_sl_dl_print_manifest.process_manifest');
      ERRBUF := FND_MESSAGE.GET;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END process_manifest;

END igf_sl_dl_print_manifest;

/
