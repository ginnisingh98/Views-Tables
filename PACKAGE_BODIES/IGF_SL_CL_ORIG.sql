--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_ORIG" AS
/* $Header: IGFSL08B.pls 120.5 2006/08/08 06:27:29 akomurav noship $ */

/*
---------------------------------------------------------------------------------
--    Created By       :    mesriniv
--    Date Created By  :    2000/11/17
--    Purpose          :    To Create Output Files for Commom Line Loans
--    Known Limitations,Enhancements or Remarks
--    Change History   :
---------------------------------------------------------------------------------
-- bvisvana    10-Apr-2006      FA 161 - Bug # 5006583 - CL4 Addendum
--                              Two new columns (borrower alien reg number and e-signature source type code) +  TBH impact
-- upinjark    28-Mar-2005      Bug - 4117260
                                Removed condition applied while fixing bug -4103342
				and reverted back to the original condition
				"Req Serial Loan Code should be Blank for FLP/ALT -field 90"
-- mnade       07-Jan-2005      Bug - 4103342 Need to send Requested amount insted of accepted amount.
                                loan_amt_accepted -> requested_loan_amt.
                                For CL4 - Serial Code will populated for PLUS and ALT Loans.
                                Type 4 Records, Other Loan Amount for this period is populated.
                                   ZIP will go with 0 fill instead of 9 fill.
-- smadathi    16-Nov-2004      Bug 3416936. Added new business logic as part of
--                              CL4 changes
---------------------------------------------------------------------------------
  cdcruz      28-Oct-2004     FA152 Auto Re-pkg Build
                              Modified the call to igf_aw_packng_subfns.get_fed_efc()
                              as part of dependency.
---------------------------------------------------------------------------------
  brajendr    12-Oct-2004     FA138 ISIR Enhacements
                              Modified the reference of payment_isir_id

--    Who            When           What
---------------------------------------------------------------------------------
--    ridas         17-Sep-2004    Bug #3691146: Query optimized by using the table igf_sl_cl_recipient
--                                 instead of the view igf_sl_cl_recipient_v
---------------------------------------------------------------------------------
--    sjadhav       23-Jul-2004    Bug 3787350, corrected zip code format
---------------------------------------------------------------------------------
-- veramach     04-May-2004     bug 3603289
--                              Modified cursor cur_student_licence to select
--                              dependency_status from ISIR. other details are
--                              derived from igf_sl_gen.get_person_details.
-----------------------------------------------------------------------------------
--    ugummall        29-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                    1. Added 4 new parameters to cl_originate and 3 to sub_cl_originate
--                                    2. Changed the cursor cur_loan_dtls to include two extra parameters
--                                       namely p_base_id and p_school_id.
---------------------------------------------------------------------------------
--    sjadhav        7-Oct-2003     Bug  3104228 Fa 122 Build
--                                  Added media type and recipient id
--                                  and relationship cd parameters
--                                  Removed ref to obsolete columns
---------------------------------------------------------------------------------
--    veramach       25-SEP-2003     1. Corrected cursor cur_get_fin_aid to take award_status as parameter
--                                   2. Changed ' ' to '0' for fed_stafford_loan_debt,fed_sls_debt,heal_debt,perkins_debt,other_debt,borw_gross_annual_sal,
--                                   borw_other_income,stud_mth_housing_pymt,stud_mth_crdtcard_pymt,stud_mth_auto_pymt,stud_mth_ed_loan_pymt,stud_mth_other_pymt
--                                   in @4 records
--                                   3. borr_sign_ind and stud_sign_ind are now printed as ' ' instead of 'N'
--                                   4. Added debug log messages
-----------------------------------------------------------------------------------------------------------------------------
--  veramach   23-SEP-2003     Bug 3104228: 1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                          cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                          p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                          chg_batch_id,appl_send_error_codes from igf_sl_lor
--                                          2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                          cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                          p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                          chg_batch_id from igf_sl_lor_loc
--                                          3. Changed cur_recip_dts to take p_loan_status,p_active,p_lookup_type,p_enabled_flag
--                                          as parameters
--                                          4. Changed cursor cur_loan_dtls not to select student/borrower information. This is
--                                          derived using igf_sl_gen.get_person_dtls
------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--  gmuralid   03-07-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
--                           Added legacy record flag as parameter to
--                           igf_sl_loans_pkg
---------------------------------------------------------------------------------
--    sjadhav        30-Apr-2003     Bug 2922549.
--                                   Corrected condition to put Student SSN
--                                   Added code to strip zip code of special
--                                   characters
---------------------------------------------------------------------------------
--
--    sjadhav         27-Mar-2003    Bug 2863960
--                                   Changed Disb Gross Amt to Disb Accepted Amt
--                                   to insert into igf_sl_awd_disb table
---------------------------------------------------------------------------------
--    sjadhav         27-Feb-2003    Bug 2814813
--                                   1. @8 Record indicator should be set to Y
--                                   in @1 Record at position 225 only iff the
--                                   number of disb are more than 4
--                                   2. Added cursor cur_get_disb_num to fetch
--                                   disb count of disb records
--                                   3. Added igf_aw_gen_002 call to get fed efc
--                                   4. Credit Auth Ind  set based on loan
--                                   type
--                                   5. Cert Loan Amt should be sum of disb amts
--                                   reported
--                                   6. Amounts are truncated before puting in
--                                   file
---------------------------------------------------------------------------------
--    masehgal        08-Jan-2003    # 2593215  Removed redundant calls to acad
--                                   begin/end date fetching functions of SL11B.
---------------------------------------------------------------------------------
--    masehgal        02-Jan-2003    # 2477912  Made changes to resolve NCAT
--                                   reported issue.
---------------------------------------------------------------------------------
--    mesriniv        21-jun-2002    While inserting Student SSN/Parent SSN
--                                   included substr of 9 chars .
---------------------------------------------------------------------------------
--    mesriniv        8-jun-2002     2400487
--                                   1.Used  function to format SSN while
--                                   origination
--                                   2.Replaced Occurrences of DUNS ID with
--                                   spaces
---------------------------------------------------------------------------------
--    masehgal        17-Feb-2002    # 2216956  FACR007
--                                   Added Elec_mpn_ind , Borrow_sign_ind
--                                   Replaced duns_school_id
---------------------------------------------------------------------------------
--    mesriniv        18-05-2001      1.Specific checks has been
--                                    made for ALT or FLP Loans
--                                    in case of spooling @1 Records.
--                                    2.@4 Record Spooling has been done with
--                                    latest .pdf.
--                                    3.Some changes have been  made for
--                                    Fields which had only NVL () and
--                                    now they have been made as RPAD(NVL())
--                                    4.Code has been added to specify the
--                                    No.of @4 Records in File.
---------------------------------------------------------------------------------
*/

 SKIP_RECORD EXCEPTION;
 g_debug_runtime_level     NUMBER;

 lv_dependency_status         igf_ap_isir_matched_all.dependency_status%TYPE;
 lv_s_citizenship_status      igf_ap_isir_matched_all.citizenship_status%TYPE;
 lv_p_citizenship_status      igf_ap_isir_matched_all.citizenship_status%TYPE;
 lv_s_license_number          igf_ap_isir_matched_all.driver_license_number%TYPE;
 lv_s_license_state           igf_ap_isir_matched_all.driver_license_state%TYPE;
 lv_alien_reg_num             igf_sl_lor_loc_all.s_alien_reg_num%TYPE;          --pssahni 31-Jan-2005  changed %type from igf_ap_isir_matched_all to igf_sl_lor_loc_all
 lv_s_legal_res_state         igf_ap_isir_matched_all.s_state_legal_residence%TYPE;
 lv_s_legal_res_date          DATE;
 lv_s_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
 lv_s_foreign_postal_code     igf_sl_lor_loc_all.s_foreign_postal_code%TYPE;
 lv_p_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
 l_phone                      igf_sl_lor_loc_all.s_permt_phone%TYPE;
 lv_p_foreign_postal_code     igf_sl_lor_loc_all.s_foreign_postal_code%TYPE;

 x_return_status       VARCHAR2(1);
 x_msg_data            VARCHAR2(30);
 x_ope_cd              igs_or_org_alt_ids.org_alternate_id%TYPE;


 -- Query optimized by using the table igf_sl_cl_recipient instead of the view igf_sl_cl_recipient_v (bug #3691146)
 CURSOR cur_recip_desc( p_relationship_cd VARCHAR2)
 IS
   SELECT
      rcpt.recipient_id           recipient_id,
      rcpt.recipient_type         recipient_type,
      lnd.description             recip_description,
      rcpt.recip_non_ed_brc_id    recip_non_ed_brc_id
   FROM
      igf_sl_cl_recipient   rcpt,
      igf_sl_lender         lnd
   WHERE
      rcpt.recipient_id    = lnd.lender_id    AND
      rcpt.recipient_type  = 'LND'            AND
      rcpt.relationship_cd = p_relationship_cd
   UNION ALL
   SELECT
      rcpt.recipient_id           recipient_id,
      rcpt.recipient_type         recipient_type,
      guarn.description           recip_description,
      rcpt.recip_non_ed_brc_id    recip_non_ed_brc_id
   FROM
      igf_sl_cl_recipient   rcpt,
      igf_sl_guarantor      guarn
   WHERE
      rcpt.recipient_id    = guarn.guarantor_id AND
      rcpt.recipient_type  = 'GUARN'            AND
      rcpt.relationship_cd = p_relationship_cd
   UNION ALL
   SELECT
      rcpt.recipient_id           recipient_id,
      rcpt.recipient_type         recipient_type,
      srvc.description            recip_description,
      rcpt.recip_non_ed_brc_id    recip_non_ed_brc_id
   FROM
      igf_sl_cl_recipient   rcpt,
      igf_sl_servicer       srvc
   WHERE
      rcpt.recipient_id    = srvc.servicer_id    AND
      rcpt.recipient_type  = 'SRVC'              AND
      rcpt.relationship_cd = p_relationship_cd;


   recip_desc_rec cur_recip_desc%ROWTYPE;

-- To fetch the Loan Records based on the Recepient Information
CURSOR cur_loan_dtls(p_cal_type             igf_ap_fa_base_rec.ci_cal_type%TYPE,
                     p_seq_number           igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                     p_fed_fund_1           igf_aw_fund_cat.fed_fund_code%TYPE,
                     p_fed_fund_2           igf_aw_fund_cat.fed_fund_code%TYPE,
                     p_loan_number          igf_sl_loans.loan_number%TYPE,
                     p_loan_status          igf_sl_loans.loan_status%TYPE,
                     p_active               igf_sl_loans.active%TYPE,
                     p_relationship_cd      igf_sl_lor_all.relationship_cd%TYPE,
                     p_base_id              VARCHAR2,
                     p_school_id            VARCHAR2
                  ) IS
SELECT loans.ROWID row_id,
       loans.loan_id,
       loans.loan_number,
       loans.award_id,
       awd.offered_amt loan_amt_offered,
       awd.accepted_amt loan_amt_accepted,
       loans.loan_per_begin_date,
       loans.loan_per_end_date,
       loans.loan_status,
       loans.loan_status_date,
       loans.loan_chg_status,
       loans.loan_chg_status_date,
       loans.active,
       loans.active_date,
       lor.orig_fee_perct,
       lor.pnote_print_ind,
       lor.s_default_status,
       lor.p_default_status,
       lor.p_person_id,
       lor.sch_cert_date,
       lor.prc_type_code,
       lor.anticip_compl_date,
       lor.cl_loan_type,
       lor.borw_interest_ind,
       lor.grade_level_code,
       lor.enrollment_code,
       lor.req_serial_loan_code,
       lor.pnote_delivery_code,
       lor.s_signature_code,
       lor.p_signature_code,
       lor.borw_outstd_loan_code,
       lor.cl_seq_number,
       lor.rec_type_ind,
       lor.p_signature_date,
       lor.borr_sign_ind,
       lor.stud_sign_ind,
       lor.borr_credit_auth_code,
       lor.origination_id,
       lor.act_serial_loan_code,
       lor.orig_status_flag,
       lor.orig_batch_id,
       lor.orig_batch_date,
       lor.orig_ack_date,
       lor.credit_override,
       lor.credit_decision_date,
       lor.pnote_status,
       lor.pnote_status_date,
       lor.pnote_id,
       lor.pnote_accept_amt,
       lor.pnote_accept_date,
       lor.borw_confirm_ind,
       lor.unsub_elig_for_heal,
       lor.disclosure_print_ind,
       lor.unsub_elig_for_depnt,
       lor.guarantee_amt,
       lor.guarantee_date,
       lor.guarnt_adj_ind,
       lor.guarnt_amt_redn_code,
       lor.guarnt_status_code,
       lor.guarnt_status_date,
       lor.lend_status_code,
       lor.lend_status_date,
       lor.last_resort_lender,
       lor.alt_prog_type_code,
       lor.alt_appl_ver_code,
       lor.resp_to_orig_code,
       lor.tot_outstd_stafford,
       lor.tot_outstd_plus,
       lor.alt_borw_tot_debt,
       lor.act_interest_rate,
       lor.service_type_code,
       lor.rev_notice_of_guarnt,
       lor.sch_refund_amt,
       lor.sch_refund_date,
       lor.uniq_layout_vend_code,
       lor.uniq_layout_ident_code,
       lor.pnote_batch_id,
       lor.pnote_ack_date,
       lor.pnote_mpn_ind,
       recip.lender_id,
       recip.guarantor_id,
       recip.recipient_id,
       recip.lend_non_ed_brc_id,
       recip.recip_non_ed_brc_id,
       recip.recipient_type,
       fabase.base_id,
       fabase.person_id student_id,
       awd.accepted_amt,
       fcat.fed_fund_code,
       fabase.ci_cal_type,
       fabase.ci_sequence_number,
       fcat.alt_rel_code,
       fcat.alt_loan_code,
       lor.note_message,
       lor.book_loan_amt_date,
       lor.book_loan_amt,
       lor.pymt_servicer_date,
       lor.pymt_servicer_amt,
       lor.rep_entity_id_txt,
       lor.cps_trans_num,
       lor.atd_entity_id_txt,
       lor.s_dob_chg_date,
       lor.p_dob_chg_date,
       lor.crdt_decision_status,
       lor.interest_rebate_percent_num,
       lor.external_loan_id_txt,
       lor.deferment_request_code,
       lor.eft_authorization_code,
       lor.requested_loan_amt,
       lor.actual_record_type_code,
       lor.reinstatement_amt,
       lor.school_use_txt,
       lor.lender_use_txt,
       lor.guarantor_use_txt,
       lor.fls_approved_amt,
       lor.flu_approved_amt,
       lor.flp_approved_amt,
       lor.alt_approved_amt,
       lor.loan_app_form_code,
       lor.override_grade_level_code,
       recip.relationship_cd,
       lor.b_alien_reg_num_txt,                      -- fa 161 - bug # 5006583
       lor.esign_src_typ_cd
  FROM igf_sl_loans_all loans,
       igf_sl_lor_all lor,
       igf_aw_award_all awd,
       igf_aw_fund_mast_all fmast,
       igf_aw_fund_cat_all fcat,
       igf_ap_fa_base_rec_all fabase,
       igf_sl_cl_recipient recip
 WHERE fabase.ci_cal_type = p_cal_type
   AND fabase.ci_sequence_number = p_seq_number
   AND fabase.base_id = awd.base_id
   AND fabase.base_id = NVL (p_base_id, fabase.base_id)
   AND awd.fund_id = fmast.fund_id
   AND fmast.fund_code = fcat.fund_code
   AND (fcat.fed_fund_code       = p_fed_fund_1    or    fcat.fed_fund_code        =  p_fed_fund_2)
   AND loans.award_id = awd.award_id
   AND loans.loan_number = NVL (p_loan_number, loans.loan_number)
   AND loans.loan_id = lor.loan_id
   AND loans.loan_status = p_loan_status
   AND loans.active = p_active
   AND SUBSTR(loans.loan_number,1,6) = SUBSTR(p_school_id,1,6)
   AND lor.relationship_cd = recip.relationship_cd
   AND lor.relationship_cd = NVL (p_relationship_cd, lor.relationship_cd);

loan_rec                     cur_loan_dtls%ROWTYPE;
student_dtl_rec igf_sl_gen.person_dtl_rec;
parent_dtl_rec igf_sl_gen.person_dtl_rec;

-- Main Procedure starts here and is a Concurrent Program

PROCEDURE cl_originate(   errbuf                OUT NOCOPY      VARCHAR2,
                          retcode               OUT NOCOPY      NUMBER,
                          p_award_year          IN              VARCHAR2,
                          p_base_id             IN              VARCHAR2,
                          p_loan_catg           IN              igf_lookups_view.lookup_code%TYPE,
                          p_loan_number         IN              igf_sl_loans_all.loan_number%TYPE,
                          p_org_id              IN              NUMBER,
                          p_media_type          IN              VARCHAR2,
                          p_recipient_id        IN              VARCHAR2,
                          p_school_id           IN              VARCHAR2,
                          non_ed_branch         IN              VARCHAR2,
                          sch_non_ed_branch     IN              VARCHAR2
)
AS

/***************************************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    To Fetch Distinct Recipient Details and Compute Batch Id.
   Known Limitations,Enhancements or Remarks
   Change History   :
    Bug No:2332668 Desc:LOAN ORIGINATION PROCESS NOT RUNNING SUCCESSFULLY.
    Who             When            What
    ugummall        29-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                    1. Added 4 new parameters namely p_base_id,
                                       p_school_id, non_ed_branch and sch_non_ed_branch
                                    2. Changed the cursor cur_recip_dts to select only those
                                       records related to p_school_id, and only those related
                                       to p_base_id if it is not null.
    mesriniv        23-APR-2002     Added code to display the Parameters Passed
***************************************************************************************/

 lv_ci_cal_type             igs_ca_inst.cal_type%TYPE;
 lv_ci_sequence_number      igs_ca_inst.sequence_number%TYPE;
 lv_recipient_id_found      BOOLEAN;

 lv_request_id              NUMBER(10);
 lv_request_status          BOOLEAN;
 l_i                        NUMBER(1);
 l_alternate_code           igs_ca_inst.alternate_code%TYPE;
 l_lookup_type              igf_lookups_view.lookup_type%TYPE;

 TYPE l_parameters IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
 l_para_rec                 l_parameters;

 lv_complete                BOOLEAN;

 -- To fetch the Distinct Combinations of Recipient Details

 CURSOR cur_recip_dts(
                       p_loan_status       igf_sl_loans.loan_status%TYPE,
                       p_active            igf_sl_loans.active%TYPE,
                       p_lookup_type       igf_lookups_view.lookup_type%TYPE,
                       p_enabled_flag      igf_lookups_view.enabled_flag%TYPE,
                       p_recipient_id      VARCHAR2
                     ) IS
    SELECT DISTINCT lor.relationship_cd
    FROM   igf_ap_fa_base_rec fabase,
           igf_sl_loans lar,
           igf_sl_lor lor,
           igf_aw_award awd,
           igf_aw_fund_mast fund,
           igf_aw_fund_cat fcat,
           igf_sl_cl_recipient recip
    WHERE  lar.loan_id               = lor.loan_id
    AND    lar.award_id              = awd.award_id
    AND    awd.base_id               = fabase.base_id
    AND    awd.base_id               = NVL(p_base_id, awd.base_id)
    AND    awd.fund_id               = fund.fund_id
    AND    fund.fund_code            = fcat.fund_code
    AND    fabase.ci_cal_type        = lv_ci_cal_type
    AND    fabase.ci_sequence_number = lv_ci_sequence_number
    AND    lar.loan_status           = p_loan_status
    AND    lar.active                = p_active
    AND    recip.recipient_id        = NVL(p_recipient_id,recip.recipient_id)
    AND    lor.relationship_cd       = recip.relationship_cd
    AND    lar.loan_number           LIKE DECODE(p_loan_number,NULL,'%',p_loan_number)
    AND    substr(lar.loan_number, 1, 6) = substr(p_school_id,1,6)
    AND    fcat.fed_fund_code IN  (  SELECT DISTINCT lookup_code
                                     FROM   igf_lookups_view
                                     WHERE  lookup_type  = p_lookup_type
                                     AND    enabled_flag = p_enabled_flag)
    ORDER BY
    lor.relationship_cd;

--Cursor to fetch the Meaning for displaying parameters passed
--Used UNION ALL here since individual select clauses
--have the same cost
--Bug No:2332668

CURSOR cur_get_parameters
   IS
   SELECT meaning
   FROM   igf_lookups_view
   WHERE  lookup_type   = 'IGF_SL_CL_LOAN_CATG'
   AND    lookup_code   = p_loan_catg
   AND    enabled_flag  = 'Y'
   UNION ALL
   SELECT  meaning
   FROM    igf_lookups_view
   WHERE   lookup_type  =  'IGF_GE_PARAMETERS'
   AND     lookup_code  IN ('AWARD_YEAR','LOAN_CATG','LOAN_ID','PARAMETER_PASS')
   AND     enabled_flag =  'Y';

--Cursor to get the alternate code for the calendar instance
--Bug No:2332668
CURSOR cur_alternate_code
   IS
   SELECT ca.alternate_code
   FROM   igs_ca_inst ca
   WHERE  ca.cal_type        = lv_ci_cal_type
   AND    ca.sequence_number = lv_ci_sequence_number;


BEGIN

    g_debug_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    lv_recipient_id_found := FALSE;
    retcode:=0;
    igf_aw_gen.set_org_id(p_org_id);

    -- Assigning the Parameters to global variables

    lv_ci_cal_type        := RTRIM(SUBSTR(p_award_year,1,10));
    lv_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));


    --Get the alternate code
    OPEN cur_alternate_code;
    FETCH cur_alternate_code INTO l_alternate_code;
    IF cur_alternate_code%NOTFOUND THEN
         CLOSE cur_alternate_code;
         fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
         igs_ge_msg_stack.add;
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         app_exception.raise_exception;
    END IF;
    CLOSE cur_alternate_code;

   --Write the details of Parameters Passed into LOG File.
   --Bug No:2332668
    l_i := 0;
    OPEN cur_get_parameters;
     LOOP
      l_i := l_i+1;
     FETCH cur_get_parameters INTO l_para_rec(l_i);
     EXIT WHEN cur_get_parameters%NOTFOUND;
     END LOOP;
     CLOSE cur_get_parameters;

        --Show the parameters passed
     fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(5),50,' '));
     fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(2),50,' ')||':'||RPAD(' ',4,' ')||l_alternate_code);
     fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(3),50,' ')||':'||RPAD(' ',4,' ')||l_para_rec(1));
     fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(4),50,' ')||':'||RPAD(' ',4,' ')||p_loan_number);

     fnd_file.put_line(fnd_file.log,' ');

     -- Fetch the Distinct set of Recipient details
     IF p_loan_catg = 'CL_STAFFORD' THEN
          l_lookup_type :='IGF_SL_CL_STAFFORD';
     ELSIF p_loan_catg = 'CL_PLUS' THEN
          l_lookup_type := 'IGF_SL_CL_PLUS';
     ELSIF p_loan_catg = 'CL_ALT' THEN
          l_lookup_type := 'IGF_SL_CL_ALT';
     ELSIF p_loan_catg = 'CL_GPLUSFL' THEN
 	  l_lookup_type := 'IGF_SL_CL_GPLUS';
     END IF;

    -- Need to call the CL Validation Process before output of Data
    IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','lv_ci_cal_type:'||lv_ci_cal_type);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','lv_ci_sequence_number:'||lv_ci_sequence_number);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','p_loan_number:'||p_loan_number);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','p_loan_catg:'||p_loan_catg);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','Calling cl_lar_validate');
    END IF;
    lv_complete := igf_sl_cl_validation.cl_lar_validate(lv_ci_cal_type,
                                                        lv_ci_sequence_number,
                                                        p_loan_number,
                                                        p_loan_catg,
                                                        'JOB',
                                                        p_school_id,
                                                        p_base_id
                                                        );

    IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','Called cl_lar_validate');
      IF lv_complete THEN
         fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','cl_lar_validate returned true');
      ELSE
         fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.cl_originate.debug','cl_lar_validate returned false');
      END IF;
    END IF;

    FOR orec IN cur_recip_dts('V','Y',l_lookup_type,'Y',p_recipient_id) LOOP
       IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug', 'l_lookup_type:' || l_lookup_type);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug', 'l_alternate_code:' || l_alternate_code);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug', 'p_loan_number:' || p_loan_number);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug', 'l_para_rec(1):' || l_para_rec(1));
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug', 'relatioship code :' || orec.relationship_cd);
       END IF;


       -- Fetch the Recipient Description
       OPEN cur_recip_desc( orec.relationship_cd);
       FETCH cur_recip_desc INTO recip_desc_rec;
       IF cur_recip_desc%NOTFOUND THEN
           CLOSE cur_recip_desc;
           --The recipient information does not exist
           IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug','Recipient description not found');
           END IF;
           fnd_message.set_name('IGF','IGF_SL_RECIP_NOT_FOUND');
           fnd_message.set_token('REL_CODE',orec.relationship_cd);
           fnd_file.put_line(fnd_file.log,fnd_message.get);
       ELSE
         --The recipient information exists

         CLOSE cur_recip_desc;

         lv_recipient_id_found := TRUE;
         lv_request_status     := fnd_request.set_options;

         -- Concurrent Request is being made to output the data
         lv_request_id      := fnd_request.submit_request('IGF',
                                                           'IGFSLJ08',
                                                           '',
                                                           '',
                                                           FALSE,
                                                           lv_ci_cal_type,
                                                           TO_CHAR(lv_ci_sequence_number),
                                                           p_loan_number,
                                                           p_loan_catg,
                                                           TO_CHAR(p_org_id),
                                                           orec.relationship_cd,
                                                           p_media_type,
                                                           p_base_id,
                                                           p_school_id,
                                                           sch_non_ed_branch,
                                                           CHR(0),
                                                           '','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           '','','','','','','','','','',
                                                           ''--'','','',
                                                           );


        -- Check the Return Status of Request Id
        IF lv_request_id = 0 THEN
           -- On Failure of Concurrent Request
           fnd_message.set_name('IGF','IGF_SL_CL_ORIG_REQ_FAIL');
           fnd_message.set_token('NAME',TO_CHAR(lv_request_id));
           igs_ge_msg_stack.add;
           IF (fnd_log.level_exception >= g_debug_runtime_level) THEN
             fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig.cl_originate.debug','Concurrent request failed');
           END IF;
           app_exception.raise_exception;
         ELSE
           fnd_file.new_line(fnd_file.log,2);
           fnd_message.set_name('IGF','IGF_SL_CL_ORIG_CREATED');
           fnd_message.set_token('P_FILENAME',RPAD(TO_CHAR(lv_request_id),10));
           fnd_message.set_token('P_RECIP_ID',RPAD(recip_desc_rec.recipient_id,10));
           fnd_message.set_token('P_RECIP_NAME',recip_desc_rec.recip_description||'   ');
           fnd_message.set_token('P_RECIP_BRC_ID',RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),'10'));

           -- IGF.#P_FILENAME : #P_RECIP_ID  #P_RECIP_NAME   #P_RECIP_BRC_ID
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           fnd_file.new_line(fnd_file.log,2);
         END IF;
     END IF;
   END LOOP;

     -- In case No Recipient details have been fetched for any of the User Inputs then Need to display a Message in the LOG File
     IF lv_recipient_id_found = FALSE THEN
       IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.cl_originate.debug','Recipient Id not found');
       END IF;
        fnd_file.new_line(fnd_file.log,2);
        fnd_file.put_line(fnd_file.log, fnd_message.get_string('IGF','IGF_SL_NO_LOAN_ORIG_DATA'));
        fnd_file.new_line(fnd_file.log,2);
     END IF;

     COMMIT;

   EXCEPTION
    WHEN app_exception.record_lock_exception THEN
       ROLLBACK;
       IF cur_recip_dts%ISOPEN THEN
         CLOSE cur_recip_dts;
       END IF;
       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
         fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.cl_originate.exception',SQLERRM);
       END IF;

       igs_ge_msg_stack.conc_exception_hndl;

   WHEN OTHERS THEN
       ROLLBACK;
       IF cur_recip_dts%ISOPEN THEN
         CLOSE cur_recip_dts;
       END IF;
       retcode := 2;
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_SL_CL_ORIG.CL_ORIGINATE');
       errbuf := fnd_message.get;
       IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
         fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.cl_originate.exception',SQLERRM);
       END IF;
       igs_ge_msg_stack.conc_exception_hndl;

END cl_originate;


 PROCEDURE insert_lor_loc_rec (
   p_v_school_id          IN  VARCHAR2,
   p_n_coa                IN  igf_ap_fa_base_rec_all.coa_f%TYPE,
   p_n_efc                IN  igf_ap_fa_base_rec_all.efc_f%TYPE,
   p_n_est_fin            IN  igf_aw_award_all.accepted_amt%TYPE,
   p_c_alt_borr_ind_flag  IN  VARCHAR2
 ) AS


  /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    To insert transaction records into the igf_sl_lor_loc table
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
   veramach   23-SEP-2003     Bug 3104228:
                                        1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
                                        2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id from igf_sl_lor_loc
   ***************************************************************/

 lv_row_id                         ROWID;
 --   masehgal  08-Jan-2003  # 2593215  Removed redundant calls to acad
 --                          begin/end date fetching functions of SL11B.

 BEGIN

  -- Fetch License State and Num into Variables

    --These Variables values vary for every Student Id
    lv_row_id                := NULL;
    lv_s_license_number      := NULL;
    lv_s_license_state       := NULL;
    lv_s_citizenship_status  := NULL;
    lv_alien_reg_num         := NULL;
    lv_dependency_status     := NULL;
    lv_s_permt_phone         := NULL;
    lv_p_permt_phone         := NULL;
    l_phone                  := NULL;
    lv_s_foreign_postal_code := NULL;
    lv_p_foreign_postal_code := NULL;

    --   masehgal  08-Jan-2003  # 2593215  Removed redundant calls to acad
    --                          begin/end date fetching functions of SL11B.

    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.insert_lor_loc_rec.debug', 'Before inserting into igf_sl_lor_loc' );
    END IF;

    igf_sl_lor_loc_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_row_id,
      x_loan_id                           => loan_rec.loan_id,
      x_origination_id                    => loan_rec.origination_id,
      x_loan_number                       => loan_rec.loan_number,
      x_loan_type                         => loan_rec.cl_loan_type,
      x_loan_amt_offered                  => loan_rec.loan_amt_offered,
      x_loan_amt_accepted                 => loan_rec.loan_amt_accepted,
      x_loan_per_begin_date               => loan_rec.loan_per_begin_date,
      x_loan_per_end_date                 => loan_rec.loan_per_end_date,
      x_acad_yr_begin_date                => NULL , --ld_acad_yr_begin_date,
      x_acad_yr_end_date                  => NULL , --ld_acad_yr_end_date,
      x_loan_status                       => loan_rec.loan_status,
      x_loan_status_date                  => loan_rec.loan_status_date,
      x_loan_chg_status                   => loan_rec.loan_chg_status,
      x_loan_chg_status_date              => loan_rec.loan_chg_status_date,
      x_req_serial_loan_code              => loan_rec.req_serial_loan_code,
      x_act_serial_loan_code              => loan_rec.act_serial_loan_code,
      x_active                            => loan_rec.active,
      x_active_date                       => loan_rec.active_date,
      x_sch_cert_date                     => loan_rec.sch_cert_date,
      x_orig_status_flag                  => loan_rec.orig_status_flag,
      x_orig_batch_id                     => loan_rec.orig_batch_id,
      x_orig_batch_date                   => loan_rec.orig_batch_date,
      x_chg_batch_id                      => NULL,
      x_orig_ack_date                     => loan_rec.orig_ack_date,
      x_credit_override                   => loan_rec.credit_override,
      x_credit_decision_date              => loan_rec.credit_decision_date,
      x_pnote_delivery_code               => loan_rec.pnote_delivery_code,
      x_pnote_status                      => loan_rec.pnote_status ,
      x_pnote_status_date                 => loan_rec.pnote_status_date,
      x_pnote_id                          => loan_rec.pnote_id,
      x_pnote_print_ind                   => loan_rec.pnote_print_ind,
      x_pnote_accept_amt                  => loan_rec.pnote_accept_amt,
      x_pnote_accept_date                 => loan_rec.pnote_accept_date,
      x_p_signature_code                  => loan_rec.p_signature_code,
      x_p_signature_date                  => loan_rec.p_signature_date,
      x_s_signature_code                  => loan_rec.s_signature_code,
      x_unsub_elig_for_heal               => loan_rec.unsub_elig_for_heal,
      x_disclosure_print_ind              => loan_rec.disclosure_print_ind,
      x_orig_fee_perct                    => loan_rec.orig_fee_perct,
      x_borw_confirm_ind                  => loan_rec.borw_confirm_ind,
      x_borw_interest_ind                 => loan_rec.borw_interest_ind,
      x_unsub_elig_for_depnt              => loan_rec.unsub_elig_for_depnt,
      x_guarantee_amt                     => loan_rec.guarantee_amt,
      x_guarantee_date                    => loan_rec.guarantee_date,
      x_guarnt_adj_ind                    => loan_rec.guarnt_adj_ind,
      x_guarnt_amt_redn_code              => loan_rec.guarnt_amt_redn_code,
      x_guarnt_status_code                => loan_rec.guarnt_status_code,
      x_guarnt_status_date                => loan_rec.guarnt_status_date,
      x_lend_apprv_denied_code            => NULL,
      x_lend_apprv_denied_date            => NULL,
      x_lend_status_code                  => loan_rec.lend_status_code,
      x_lend_status_date                  => loan_rec.lend_status_date,
      x_grade_level_code                  => loan_rec.grade_level_code,
      x_enrollment_code                   => loan_rec.enrollment_code,
      x_anticip_compl_date                => loan_rec.anticip_compl_date,
      x_borw_lender_id                    => loan_rec.lender_id,
      x_duns_borw_lender_id               => NULL,
      x_guarantor_id                      => loan_rec.guarantor_id,
      x_duns_guarnt_id                    => NULL,
      x_prc_type_code                     => loan_rec.prc_type_code,
      x_rec_type_ind                      => loan_rec.rec_type_ind,
      x_cl_loan_type                      => loan_rec.cl_loan_type,
      x_cl_seq_number                     => loan_rec.cl_seq_number,
      x_last_resort_lender                => loan_rec.last_resort_lender,
      x_lender_id                         => loan_rec.lender_id,
      x_duns_lender_id                    => NULL,
      x_lend_non_ed_brc_id                => loan_rec.lend_non_ed_brc_id,
      x_recipient_id                      => loan_rec.recipient_id,
      x_recipient_type                    => loan_rec.recipient_type,
      x_duns_recip_id                     => NULL,
      x_recip_non_ed_brc_id               => loan_rec.recip_non_ed_brc_id,
      x_cl_rec_status                     => NULL,
      x_cl_rec_status_last_update         => NULL,
      x_alt_prog_type_code                => loan_rec.alt_prog_type_code,
      x_alt_appl_ver_code                 => loan_rec.alt_appl_ver_code,
      x_borw_outstd_loan_code             => loan_rec.borw_outstd_loan_code,
      x_mpn_confirm_code                  => NULL,
      x_resp_to_orig_code                 => loan_rec.resp_to_orig_code,
      x_appl_loan_phase_code              => NULL,
      x_appl_loan_phase_code_chg          => NULL,
      x_tot_outstd_stafford               => loan_rec.tot_outstd_stafford,
      x_tot_outstd_plus                   => loan_rec.tot_outstd_plus,
      x_alt_borw_tot_debt                 => loan_rec.alt_borw_tot_debt,
      x_act_interest_rate                 => loan_rec.act_interest_rate,
      x_service_type_code                 => loan_rec.service_type_code,
      x_rev_notice_of_guarnt              => loan_rec.rev_notice_of_guarnt,
      x_sch_refund_amt                    => loan_rec.sch_refund_amt,
      x_sch_refund_date                   => loan_rec.sch_refund_date,
      x_uniq_layout_vend_code             => loan_rec.uniq_layout_vend_code,
      x_uniq_layout_ident_code            => loan_rec.uniq_layout_ident_code,
      x_p_person_id                       => loan_rec.p_person_id,
      x_p_ssn                             => SUBSTR(parent_dtl_rec.p_ssn,1,9),
      x_p_ssn_chg_date                    => NULL,
      x_p_last_name                       => parent_dtl_rec.p_last_name,
      x_p_first_name                      => parent_dtl_rec.p_first_name,
      x_p_middle_name                     => parent_dtl_rec.p_middle_name,
      x_p_permt_addr1                     => parent_dtl_rec.p_permt_addr1,
      x_p_permt_addr2                     => parent_dtl_rec.p_permt_addr2,
      x_p_permt_city                      => parent_dtl_rec.p_permt_city,
      x_p_permt_state                     => parent_dtl_rec.p_permt_state,
      x_p_permt_zip                       => parent_dtl_rec.p_permt_zip,
      x_p_permt_addr_chg_date             => NULL,
      x_p_permt_phone                     => lv_p_permt_phone,
      x_p_email_addr                      => parent_dtl_rec.p_email_addr,
      x_p_date_of_birth                   => parent_dtl_rec.p_date_of_birth,
      x_p_dob_chg_date                    => NULL,
      x_p_license_num                     => parent_dtl_rec.p_license_num,
      x_p_license_state                   => parent_dtl_rec.p_license_state,
      x_p_citizenship_status              => lv_p_citizenship_status,
      x_p_alien_reg_num                   => parent_dtl_rec.p_alien_reg_num,
      x_p_default_status                  => loan_rec.p_default_status,
      x_p_foreign_postal_code             => lv_p_foreign_postal_code,
      x_p_state_of_legal_res              => parent_dtl_rec.p_state_of_legal_res,
      x_p_legal_res_date                  => parent_dtl_rec.p_legal_res_date,
      x_s_ssn                             => SUBSTR(student_dtl_rec.p_ssn,1,9),
      x_s_ssn_chg_date                    => NULL,
      x_s_last_name                       => student_dtl_rec.p_last_name,
      x_s_first_name                      => student_dtl_rec.p_first_name,
      x_s_middle_name                     => student_dtl_rec.p_middle_name,
      x_s_permt_addr1                     => student_dtl_rec.p_permt_addr1,
      x_s_permt_addr2                     => student_dtl_rec.p_permt_addr2,
      x_s_permt_city                      => student_dtl_rec.p_permt_city,
      x_s_permt_state                     => student_dtl_rec.p_permt_state,
      x_s_permt_zip                       => student_dtl_rec.p_permt_zip,
      x_s_permt_addr_chg_date             => NULL,
      x_s_permt_phone                     => lv_s_permt_phone,
      x_s_local_addr1                     => student_dtl_rec.p_local_addr1,
      x_s_local_addr2                     => student_dtl_rec.p_local_addr2,
      x_s_local_city                      => student_dtl_rec.p_local_city,
      x_s_local_state                     => student_dtl_rec.p_local_state,
      x_s_local_zip                       => student_dtl_rec.p_local_zip,
      x_s_local_addr_chg_date             => NULL,
      x_s_email_addr                      => student_dtl_rec.p_email_addr,
      x_s_date_of_birth                   => student_dtl_rec.p_date_of_birth,
      x_s_dob_chg_date                    => NULL,
      x_s_license_num                     => lv_s_license_number,
      x_s_license_state                   => lv_s_license_state,
      x_s_depncy_status                   => lv_dependency_status,
      x_s_default_status                  => loan_rec.s_default_status,
      x_s_citizenship_status              => lv_s_citizenship_status,
      x_s_alien_reg_num                   => lv_alien_reg_num,
      x_s_foreign_postal_code             => lv_s_foreign_postal_code,
      x_pnote_batch_id                    => loan_rec.pnote_batch_id,
      x_pnote_ack_date                    => loan_rec.pnote_ack_date,
      x_pnote_mpn_ind                     => loan_rec.pnote_mpn_ind,
      x_award_id                          => loan_rec.award_id                     ,
      x_base_id                           => loan_rec.base_id                      ,
      x_document_id_txt                   => NULL                                  ,
      x_loan_key_num                      => NULL                                  ,
      x_interest_rebate_percent_num       => loan_rec.interest_rebate_percent_num  ,
      x_fin_award_year                    => NULL                                  ,
      x_cps_trans_num                     => loan_rec.cps_trans_num                ,
      x_atd_entity_id_txt                 => loan_rec.atd_entity_id_txt            ,
      x_rep_entity_id_txt                 => loan_rec.rep_entity_id_txt            ,
      x_source_entity_id_txt              => NULL                                  ,
      x_pymt_servicer_amt                 => loan_rec.pymt_servicer_amt            ,
      x_pymt_servicer_date                => loan_rec.pymt_servicer_date           ,
      x_book_loan_amt                     => loan_rec.book_loan_amt                ,
      x_book_loan_amt_date                => loan_rec.book_loan_amt_date           ,
      x_s_chg_birth_date                  => loan_rec.s_dob_chg_date               ,
      x_s_chg_ssn                         => NULL                                  ,
      x_s_chg_last_name                   => NULL                                  ,
      x_b_chg_birth_date                  => loan_rec.p_dob_chg_date               ,
      x_b_chg_ssn                         => NULL                                  ,
      x_b_chg_last_name                   => NULL                                  ,
      x_note_message                      => loan_rec.note_message                 ,
      x_full_resp_code                    => NULL                                  ,
      x_s_permt_county                    => student_dtl_rec.p_county              ,
      x_b_permt_county                    => parent_dtl_rec.p_county               ,
      x_s_permt_country                   => student_dtl_rec.p_country             ,
      x_b_permt_country                   => parent_dtl_rec.p_country              ,
      x_crdt_decision_status              => loan_rec.crdt_decision_status         ,
      x_external_loan_id_txt              => loan_rec.external_loan_id_txt         ,
      x_deferment_request_code            => loan_rec.deferment_request_code       ,
      x_eft_authorization_code            => loan_rec.eft_authorization_code       ,
      x_requested_loan_amt                => loan_rec.requested_loan_amt           ,
      x_actual_record_type_code           => loan_rec.actual_record_type_code      ,
      x_reinstatement_amt                 => loan_rec.reinstatement_amt            ,
      x_school_use_txt                    => loan_rec.school_use_txt               ,
      x_lender_use_txt                    => loan_rec.lender_use_txt               ,
      x_guarantor_use_txt                 => loan_rec.guarantor_use_txt            ,
      x_fls_approved_amt                  => loan_rec.fls_approved_amt             ,
      x_flu_approved_amt                  => loan_rec.flu_approved_amt             ,
      x_flp_approved_amt                  => loan_rec.flp_approved_amt             ,
      x_alt_approved_amt                  => loan_rec.alt_approved_amt             ,
      x_loan_app_form_code                => loan_rec.loan_app_form_code           ,
      x_alt_borrower_ind_flag             => p_c_alt_borr_ind_flag                 ,
      x_school_id_txt                     => p_v_school_id                         ,
      x_cost_of_attendance_amt            => p_n_coa                               ,
      x_expect_family_contribute_amt      => p_n_efc                               ,
      x_established_fin_aid_amount        => p_n_est_fin                           ,
      x_borower_electronic_sign_flag      => loan_rec.borr_sign_ind                ,
      x_student_electronic_sign_flag      => loan_rec.stud_sign_ind                ,
      x_borower_credit_authoriz_flag      => loan_rec.borr_credit_auth_code        ,
      x_mpn_type_flag                     => NULL                                  ,
      x_esign_src_typ_cd                  => loan_rec.esign_src_typ_cd

    );

    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.insert_lor_loc_rec.debug', 'Insertion into igf_sl_lor_loc succeeded' );
    END IF;

 EXCEPTION

 WHEN app_exception.record_lock_exception THEN
    IF (fnd_log.level_exception >= g_debug_runtime_level) THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig.insert_lor_loc_rec.exception', 'Lock row failed' );
    END IF;
    RAISE;

 WHEN OTHERS THEN

    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_CL_ORIG.INSERT_LOR_LOC_REC');
    IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.insert_lor_loc_rec.exception',SQLERRM);
    END IF;
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END insert_lor_loc_rec;


PROCEDURE  update_orig_batch_id(p_origination_id  igf_sl_lor.origination_id%TYPE,
                                p_batch_id        igf_sl_lor.orig_batch_id%TYPE)
IS
 /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    To update igf_sl_lor table with origination batch id
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
   veramach   23-SEP-2003     Bug 3104228:
                                        1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
                                        2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
                                        chg_batch_id from igf_sl_lor_loc
   masehgal             17-Feb-2002     # 2216956 , FACR007
                                        Added Elec_mpn_indicator , Borrow_sign_ind
   ***************************************************************/

lv_row_id  ROWID;
l_sch_date DATE;

CURSOR c_tbh_cur  IS
   SELECT igf_sl_lor.*
   FROM igf_sl_lor
   WHERE origination_id = p_origination_id FOR UPDATE OF sch_cert_date NOWAIT;

CURSOR  c_sl_loans (cp_n_loan_id igf_sl_loans_all.loan_id%TYPE) IS
SELECT  external_loan_id_txt
FROM    igf_sl_loans_all
WHERE   loan_id = cp_n_loan_id;

l_v_ext_loan_id_txt  igf_sl_loans_all.external_loan_id_txt%TYPE;

BEGIN

   FOR tbh_rec in c_tbh_cur LOOP

     -- To Update the "Record Type Ind" to "Corrections" in the Origination Record Type Indicator
     -- based on if its a Reprint or New Application
--MN 16-Dec-2004 15:51 This change might not required. The loan will remain in A state even after file creation
-- And the user will change that to C to send Corrections.
/*
          IF tbh_rec.rec_type_ind IN ('A','R') THEN
             tbh_rec.rec_type_ind:='C';
          END IF;
*/
          --If the School Certification Date is NOT NULL Then leave it
          --Else it is the File Transmission Date which is SYSDATE
          --Bug 2477912
          l_sch_date:=NULL;
          IF tbh_rec.sch_cert_date IS NOT NULL THEN
             l_sch_date:= tbh_rec.sch_cert_date;
          ELSE
             l_sch_date:=TRUNC(SYSDATE);
          END IF;

          IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.update_batch_orig_id.debug', 'Before inserting into igf_sl_lor, loan_id:'||tbh_rec.loan_id);
          END IF;
          OPEN  c_sl_loans (cp_n_loan_id => tbh_rec.loan_id);
          FETCH c_sl_loans INTO l_v_ext_loan_id_txt  ;
          CLOSE c_sl_loans ;

          igf_sl_lor_pkg.update_row (
            x_Mode                              => 'R',
            x_rowid                             => tbh_rec.row_id,
            x_origination_id                    => tbh_rec.origination_id,
            x_loan_id                           => tbh_rec.loan_id,
            x_sch_cert_date                     => l_sch_date,
            x_orig_status_flag                  => tbh_rec.orig_status_flag,
            x_orig_batch_id                     => p_batch_id,
            x_orig_batch_date                   => TRUNC(SYSDATE),
            x_chg_batch_id                      => NULL,
            x_orig_ack_date                     => tbh_rec.orig_ack_date,
            x_credit_override                   => tbh_rec.credit_override,
            x_credit_decision_date              => tbh_rec.credit_decision_date,
            x_req_serial_loan_code              => tbh_rec.req_serial_loan_code,
            x_act_serial_loan_code              => tbh_rec.act_serial_loan_code,
            x_pnote_delivery_code               => tbh_rec.pnote_delivery_code,
            x_pnote_status                      => tbh_rec.pnote_status,
            x_pnote_status_date                 => tbh_rec.pnote_status_date,
            x_pnote_id                          => tbh_rec.pnote_id,
            x_pnote_print_ind                   => tbh_rec.pnote_print_ind,
            x_pnote_accept_amt                  => tbh_rec.pnote_accept_amt,
            x_pnote_accept_date                 => tbh_rec.pnote_accept_date,
            x_unsub_elig_for_heal               => tbh_rec.unsub_elig_for_heal,
            x_disclosure_print_ind              => tbh_rec.disclosure_print_ind,
            x_orig_fee_perct                    => tbh_rec.orig_fee_perct,
            x_borw_confirm_ind                  => tbh_rec.borw_confirm_ind,
            x_borw_interest_ind                 => tbh_rec.borw_interest_ind,
            x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code,
            x_unsub_elig_for_depnt              => tbh_rec.unsub_elig_for_depnt,
            x_guarantee_amt                     => tbh_rec.guarantee_amt,
            x_guarantee_date                    => tbh_rec.guarantee_date,
            x_guarnt_amt_redn_code              => tbh_rec.guarnt_amt_redn_code,
            x_guarnt_status_code                => tbh_rec.guarnt_status_code,
            x_guarnt_status_date                => tbh_rec.guarnt_status_date,
            x_lend_apprv_denied_code            => NULL,
            x_lend_apprv_denied_date            => NULL,
            x_lend_status_code                  => tbh_rec.lend_status_code,
            x_lend_status_date                  => tbh_rec.lend_status_date,
            x_guarnt_adj_ind                    => tbh_rec.guarnt_adj_ind,
            x_grade_level_code                  => tbh_rec.grade_level_code,
            x_enrollment_code                   => tbh_rec.enrollment_code,
            x_anticip_compl_date                => tbh_rec.anticip_compl_date,
            x_borw_lender_id                    => NULL,
            x_duns_borw_lender_id               => NULL,
            x_guarantor_id                      => NULL,
            x_duns_guarnt_id                    => NULL,
            x_prc_type_code                     => tbh_rec.prc_type_code,
            x_cl_seq_number                     => tbh_rec.cl_seq_number,
            x_last_resort_lender                => tbh_rec.last_resort_lender,
            x_lender_id                         => NULL,
            x_duns_lender_id                    => NULL,
            x_lend_non_ed_brc_id                => tbh_rec.lend_non_ed_brc_id,
            x_recipient_id                      => NULL,
            x_recipient_type                    => NULL,
            x_duns_recip_id                     => NULL,
            x_recip_non_ed_brc_id               => NULL,
            x_rec_type_ind                      => tbh_rec.rec_type_ind,
            x_cl_loan_type                      => tbh_rec.cl_loan_type,
            x_cl_rec_status                     => NULL,
            x_cl_rec_status_last_update         => NULL,
            x_alt_prog_type_code                => tbh_rec.alt_prog_type_code,
            x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code,
            x_mpn_confirm_code                  => NULL,
            x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code,
            x_appl_loan_phase_code              => NULL,
            x_appl_loan_phase_code_chg          => NULL,
            x_appl_send_error_codes             => NULL,
            x_tot_outstd_stafford               => tbh_rec.tot_outstd_stafford,
            x_tot_outstd_plus                   => tbh_rec.tot_outstd_plus,
            x_alt_borw_tot_debt                 => tbh_rec.alt_borw_tot_debt,
            x_act_interest_rate                 => tbh_rec.act_interest_rate,
            x_service_type_code                 => tbh_rec.service_type_code,
            x_rev_notice_of_guarnt              => tbh_rec.rev_notice_of_guarnt,
            x_sch_refund_amt                    => tbh_rec.sch_refund_amt,
            x_sch_refund_date                   => tbh_rec.sch_refund_date,
            x_uniq_layout_vend_code             => tbh_rec.uniq_layout_vend_code,
            x_uniq_layout_ident_code            => tbh_rec.uniq_layout_ident_code,
            x_p_person_id                       => tbh_rec.p_person_id,
            x_p_ssn_chg_date                    => NULL,
            x_p_dob_chg_date                    => NULL,
            x_p_permt_addr_chg_date             => NULL,
            x_p_default_status                  => tbh_rec.p_default_status,
            x_p_signature_code                  => tbh_rec.p_signature_code,
            x_p_signature_date                  => tbh_rec.p_signature_date,
            x_s_ssn_chg_date                    => NULL,
            x_s_dob_chg_date                    => NULL,
            x_s_permt_addr_chg_date             => NULL,
            x_s_local_addr_chg_date             => NULL,
            x_s_default_status                  => tbh_rec.s_default_status,
            x_s_signature_code                  => tbh_rec.s_signature_code,
            x_pnote_batch_id                    => tbh_rec.pnote_batch_id,
            x_pnote_ack_date                    => tbh_rec.pnote_ack_date,
            x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind,
            x_elec_mpn_ind                      => tbh_rec.elec_mpn_ind,
            x_borr_sign_ind                     => tbh_rec.borr_sign_ind,
            x_stud_sign_ind                     => tbh_rec.stud_sign_ind,
            x_borr_credit_auth_code             => tbh_rec.borr_credit_auth_code,
            x_relationship_cd                   => tbh_rec.relationship_cd                  ,
            x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num      ,
            x_cps_trans_num                     => tbh_rec.cps_trans_num                    ,
            x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt                ,
            x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt                ,
            x_crdt_decision_status              => tbh_rec.crdt_decision_status             ,
            x_note_message                      => tbh_rec.note_message                     ,
            x_book_loan_amt                     => tbh_rec.book_loan_amt                    ,
            x_book_loan_amt_date                => tbh_rec.book_loan_amt_date               ,
            x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt                ,
            x_pymt_servicer_date                => tbh_rec.pymt_servicer_date               ,
            x_external_loan_id_txt              => l_v_ext_loan_id_txt              ,
            x_deferment_request_code            => tbh_rec.deferment_request_code   ,
            x_eft_authorization_code            => tbh_rec.eft_authorization_code   ,
            x_requested_loan_amt                => tbh_rec.requested_loan_amt       ,
            x_actual_record_type_code           => tbh_rec.actual_record_type_code  ,
            x_reinstatement_amt                 => tbh_rec.reinstatement_amt        ,
            x_school_use_txt                    => tbh_rec.school_use_txt           ,
            x_lender_use_txt                    => tbh_rec.lender_use_txt           ,
            x_guarantor_use_txt                 => tbh_rec.guarantor_use_txt        ,
            x_fls_approved_amt                  => tbh_rec.fls_approved_amt         ,
            x_flu_approved_amt                  => tbh_rec.flu_approved_amt         ,
            x_flp_approved_amt                  => tbh_rec.flp_approved_amt         ,
            x_alt_approved_amt                  => tbh_rec.alt_approved_amt         ,
            x_loan_app_form_code                => tbh_rec.loan_app_form_code       ,
            x_override_grade_level_code         => tbh_rec.override_grade_level_code ,
            x_b_alien_reg_num_txt               => tbh_rec.b_alien_reg_num_txt      ,
            x_esign_src_typ_cd                  => tbh_rec.esign_src_typ_cd         ,
	    x_acad_begin_date                   => tbh_rec.acad_begin_date          ,
	    x_acad_end_date                     => tbh_rec.acad_end_date

                );

          IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.update_orig_batch_id.debug', 'Insertion into igf_sl_lor succeeded, loan_id:'||tbh_rec.loan_id);
          END IF;

  END LOOP;

  EXCEPTION

    WHEN app_exception.record_lock_exception THEN
     IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.update_orig_batch_id.exception','Record Lock Exception');
     END IF;
     RAISE;

    WHEN OTHERS THEN
     IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.update_orig_batch_id.exception',SQLERRM);
     END IF;
     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_ORIG.UPDATE_ORIG_BATCH_ID');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

 END update_orig_batch_id;

 -- This Procedure writes the Records into the output file and is Concurrent Procedure
 -- It returns the Request id and Based on the value data is committed

 PROCEDURE sub_cl_originate(   errbuf                OUT NOCOPY      VARCHAR2,
                               retcode               OUT NOCOPY      NUMBER,
                               p_ci_cal_type         IN              igs_ca_inst.cal_type%TYPE,
                               p_ci_sequence_number  IN              igs_ca_inst.sequence_number%TYPE,
                               p_loan_number         IN              igf_sl_loans_all.loan_number%TYPE,
                               p_loan_catg           IN              igf_lookups_view.lookup_code%TYPE,
                               p_org_id              IN              NUMBER,
                               p_relationship_cd     IN              VARCHAR2,
                               p_media_type          IN              VARCHAR2,
                               p_base_id             IN              VARCHAR2,
                               p_school_id           IN              VARCHAR2,
                               sch_non_ed_branch     IN              VARCHAR2
                            )
 AS
  /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    Concurrent Program to fetch transaction records and
                    output the data to a file.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Bug Id           : 1720677 Desc : Mapping of school id in the CommonLine Setup
                          to ope_id of  FinancialAid Office Setup.
   Who              When            What
   museshad         05-May-2005     Bug# 4346258
                                    Added the parameter 'base_id' in the call to the
                                    function get_cl_version(). The signature of
                                    this function has been changed so that it takes
                                    into account any overriding CL version for a
                                    specific Organization Unit in FFELP Setup override.
   mnade            7-Feb-2005      Bug 4133414 - Alt loan rec was required to be reseted before fetching data
                                    for next loan to avoid copying data of earlier loan to next one which does not have the same.
   smadathi         01-12-2004      Bug 4039480. Moved the logic to obtain the borrower and student
                                    details inside the cursor cur_loan_dtls for loop
   veramach         15-Apr-2004     bug 3054469
                                    Impact of obsoleting igf_aw_gen_002.get_fed_efc and replacing the call
                                    with igf_aw_packng_subfns.get_fed_efc
   bkkumar          04-Apr-04       Bug 3409969 Added the alt_rel_code as the impact to the pick_setup routine.
                                    Added the code to populate the alt_rel_code field in the output file.
   ugummall         29-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                    1. Added 3 new parameters namely p_base_id, p_school_id, sch_non_ed_branch.
                                    2. Removed the cursors cur_ope_id and cur_school_id as we can use
                                       p_school_id passed in parameter and also sch_non_ed_branch.
                                    3. Added new cursor cur_get_school_name to get the school name.

   agairola             15-Mar-2002     Modified the Update Row call of the IGF_SL_LOANS_PKG
                                        to include the Borrower Determination as part of Refunds
                                        DLD - 2144600
   mesriniv         05-APR-2001    Changed the occurrences of field fao_id
                         to ope_id
   ***************************************************************/

     no_loan_data               EXCEPTION;

     lv_batch_id                igf_sl_cl_batch.batch_id%TYPE;
     lv_cbth_id                 igf_sl_cl_batch.cbth_id%TYPE;
     lv_file_ident_code         igf_sl_cl_file_type.file_ident_code%TYPE;
     lv_file_ident_name         igf_sl_cl_file_type.file_ident_name%TYPE;
     lv_recipient_type          igf_sl_cl_recipient.recipient_type%TYPE;
     lv_recipient_id            igf_sl_cl_recipient.recipient_id%TYPE;
     lv_recip_non_ed_brc_id     igf_sl_cl_recipient.recip_non_ed_brc_id%TYPE;
     l_coa                      igf_ap_fa_base_rec_all.coa_f%TYPE;
     l_efc                      igf_ap_fa_base_rec_all.efc_f%TYPE;
     lv_fed_fund_code           igf_aw_fund_cat.fed_fund_code%TYPE;
     lv_eft_authorization       igf_sl_cl_setup.eft_authorization%TYPE;
     l_dummy_pell_efc           NUMBER;

     lv_source_name             igf_lookups_view.meaning%TYPE;

     lv_cl_version              VARCHAR2(30);

     lv_s_foreign_postal_code   igf_sl_lor_loc.s_foreign_postal_code%TYPE;
     lv_p_foreign_postal_code   igf_sl_lor_loc.p_foreign_postal_code%TYPE;
     l_est_fin                  igf_aw_award_all.accepted_amt%TYPE;
     l_plus_cert_amt            igf_aw_award_all.accepted_amt%TYPE;
     l_alt_cert_amt             igf_aw_award_all.accepted_amt%TYPE;
     l_tot_alt_debt             igf_sl_alt_borw.fed_sls_debt%TYPE;
     alter_rec                  igf_sl_alt_borw%ROWTYPE;

     l_count_4                  NUMBER;
     lv_header_rec              VARCHAR2(1000);
     lv_trailer_rec             VARCHAR2(1000);
     lv_trans_count             NUMBER(6);
     lv_8_disb_count            NUMBER(6);
     lv_first_part_trans_rec    VARCHAR2(2000);
     lv_third_part_trans_rec    VARCHAR2(1000);
     lv_fifth_part_trans_rec    VARCHAR2(1000);
     lv_seventh_part_trans_rec  VARCHAR2(1000);
     lv_1_final_disb_date       VARCHAR2(1000);
     lv_1_final_gross_amt       VARCHAR2(1000);
     lv_1_final_hold_rel_ind    VARCHAR2(1000);
     lv_8_final_disb_date       VARCHAR2(1000);
     lv_8_final_gross_amt       VARCHAR2(1000);
     lv_8_final_hold_rel_ind    VARCHAR2(1000);
     lv_8_direct_to_borr_flag   VARCHAR2(20);
     lv_l_direct_to_borr_flag   VARCHAR2(20);
     lv_counter                 NUMBER;
     lv_row_id                  ROWID;
     lv_software_code           VARCHAR2(4);
     lv_software_version        VARCHAR2(4);
     lv_process_year            VARCHAR2(2);
     l_borw_ind_code            VARCHAR2(1);
     l_fed_appl_code            VARCHAR2(1);
     l_s_ssn                    VARCHAR2(9);
     l_trailer_datetime         VARCHAR2(14);
     ln_num_of_disb             NUMBER;
     lv_indi                    VARCHAR2(1);
     p_fed_fund_1               igf_aw_fund_cat.fed_fund_code%TYPE;
     p_fed_fund_2               igf_aw_fund_cat.fed_fund_code%TYPE;
     lv_stud_sign_ind           igf_sl_lor.stud_sign_ind%TYPE;
     lv_borw_interest_ind       igf_sl_lor.borw_interest_ind%TYPE;
     lv_borr_sign_ind           igf_sl_lor.borr_sign_ind%TYPE;
     lv_rel_code                VARCHAR2(30);
     lv_person_id               NUMBER;
     lv_party_id                NUMBER;
     l_n_send2_rec_cnt          NUMBER;
     l_n_send5_rec_cnt          NUMBER;
     l_n_send7_rec_cnt          NUMBER;
     l_v_trailer_date           VARCHAR2(8);
     l_v_trailer_time           VARCHAR2(6);
     l_v_owner_code             VARCHAR2(30);
     l_at4Record                VARCHAR2(1000) := '';
     -- To get the School Id
  -- Get the details of
  /*
  CURSOR cur_get_setup(p_cal_type   igf_sl_cl_setup_all.ci_cal_type%TYPE,
                       p_seq_number igf_sl_cl_setup_all.ci_sequence_number%TYPE,
                       p_rel_code   igf_sl_cl_setup_all.relationship_cd%TYPE,
                       p_party_id   igf_sl_cl_setup_all.party_id%TYPE
            ) IS
    SELECT  eft_authorization
      FROM  igf_sl_cl_setup
     WHERE  ci_cal_type        = p_cal_type
       AND  ci_sequence_number = p_seq_number
       AND  relationship_cd    = p_rel_code
       AND  NVL(party_id,-100) = NVL(p_party_id,-100);
*/
  -- Removed the cursor cur_school_id as p_school_id is now used instead of fetching School ID.



   -- Get OPE_ID for the School
   -- The cursor here cur_ope_id is removed as we can use parameter p_school_id

   student_dtl_cur igf_sl_gen.person_dtl_cur;
   parent_dtl_cur  igf_sl_gen.person_dtl_cur;

  -- Cursor to fetch Student License No.,State and Citizenship Status

  CURSOR cur_isir_depend_status
  IS
     SELECT  isir.dependency_status
     FROM    igf_ap_fa_base_rec fabase, igf_ap_isir_matched isir
     WHERE   isir.base_id     =   fabase.base_id
     AND     fabase.person_id =   loan_rec.student_id
     AND     isir.payment_isir = 'Y'
     AND     isir.system_record_type = 'ORIGINAL';

  -- Cursor to fetch school name

  CURSOR cur_get_school_name
  IS
    SELECT  meaning
      FROM  igf_lookups_view
     WHERE  lookup_type = 'IGF_AP_SCHOOL_OPEID'
       AND  lookup_code = p_school_id;

  -- To fetch the all the Disbursement dates,Amounts and Hold Rel Indicator

  CURSOR cur_disb_details
  IS
     SELECT  disb_date,
             NVL(disb_accepted_amt,0)  disb_accepted_amt,
             hold_rel_ind, direct_to_borr_flag
     FROM    igf_aw_awd_disb
     WHERE   award_id = loan_rec.award_id
     ORDER
     BY      disb_num;


  --Cursor to fetch the data from the FA Base Record for the student baseid
  CURSOR cur_get_fabase
  IS
     SELECT TRUNC(coa_f)
     FROM   igf_ap_fa_base_rec
     WHERE  base_id = loan_rec.base_id;

  --Fetch the Estimated Financial Aid
  CURSOR cur_get_fin_aid(
                          p_award_status_1 igf_aw_award.award_status%TYPE,
                          p_award_status_2 igf_aw_award.award_status%TYPE
                        )
  IS
     SELECT  TRUNC(SUM(NVL(NVL(accepted_amt,offered_amt),0))) etsimated_fin
     FROM    igf_aw_award
     WHERE   base_id  =  loan_rec.base_id
     AND     award_id <> loan_rec.award_id
     AND     (award_status = p_award_status_1 OR award_status = p_award_status_2);


  --Cursor to fetch the Total ALt Loan debt
  CURSOR  cur_get_alt_debt
  IS
     SELECT  LPAD(SUM(NVL(fed_stafford_loan_debt,0) + NVL(fed_sls_debt,0) +
                      NVL(heal_debt,0)              + NVL(perkins_debt,0) +
                      NVL(other_debt,0)),7,0) alt_loan_debt
     FROM    igf_sl_alt_borw,
             igf_sl_loans_v loanv
     WHERE   igf_sl_alt_borw.loan_id  = loanv.loan_id
     AND     loanv.student_id         =  loan_rec.student_id
     AND     loanv.ci_cal_type        <> loan_rec.ci_cal_type
     AND     loanv.ci_sequence_number <> loan_rec.ci_sequence_number;


  -- Cursor to fetch the Alternate Borrower Details if any for the Loan ID
  CURSOR cur_get_alternate
  IS
     SELECT alt.*
     FROM   igf_sl_alt_borw alt
     WHERE  loan_id=loan_rec.loan_id;

  --
  -- Cursor to fetch number of disb recs for loan
  --
  CURSOR cur_get_disb_num  (p_award_id igf_aw_award_all.award_id%TYPE)
  IS
     SELECT COUNT(disb_num)
     FROM   igf_aw_awd_disb
     WHERE  award_id = p_award_id;


  CURSOR c_sl_lor (cp_n_loan_id  igf_sl_loans_all.loan_id%TYPE) IS
  SELECT lor.*
  FROM   igf_sl_lor_all lor
  WHERE  loan_id = cp_n_loan_id;

  rec_c_sl_lor  c_sl_lor%ROWTYPE;

  -- FA 161 - rajagupt - Bug # 5006583
  CURSOR citizenship_dtl_cur (cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE) IS
  SELECT
         pct.restatus_code restatus_code
  FROM  igs_lookup_values      lkup,
        igs_pe_eit_restatus_v  pct
  WHERE lkup.lookup_type = 'PE_CITI_STATUS'
  AND   trim(lkup.lookup_code) = trim(pct.restatus_code)
  AND   pct.person_id    = cp_person_id
  AND   SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);
  citizenship_dtl_rec citizenship_dtl_cur%ROWTYPE;

  CURSOR cur_fa_mapping ( cp_citizenship_status igf_sl_pe_citi_map.pe_citi_stat_code%TYPE,
                          cp_cal_type igf_sl_pe_citi_map.ci_cal_type%TYPE,
                          cp_sequence_number igf_sl_pe_citi_map.ci_sequence_number%TYPE) IS
  SELECT trim(fa_citi_stat_code) fa_citi_stat_code FROM igf_sl_pe_citi_map
    WHERE pe_citi_stat_code  = cp_citizenship_status
      AND ci_sequence_number = cp_sequence_number
      AND ci_cal_type = cp_cal_type;
  cur_fa_mapping_rec cur_fa_mapping%ROWTYPE;


   --Get the Software Code
   -- masehgal    2477912   Made "IGS " to resolve NCAT reported errors
  FUNCTION get_software_code
  RETURN VARCHAR2 IS
  BEGIN
      RETURN 'IGS ';
  END get_software_code;

    --Get the Software Version
    -- masehgal    2477912   Made "1157" to resolve NCAT reported errors
  FUNCTION get_software_version
  RETURN VARCHAR2 IS
  BEGIN
      RETURN '1157';
  END get_software_version;

    --Get the Process Year
  FUNCTION get_process_year
  RETURN VARCHAR2 IS
  BEGIN
      RETURN  NVL(TO_CHAR(SYSDATE,'YY'),'01');
  END get_process_year;


  PROCEDURE cosigner_name_validation
           ( fName IN OUT NOCOPY VARCHAR2,
             lName IN OUT NOCOPY VARCHAR2
            )
  IS
  BEGIN
             fName := NVL(fName,' ');
             lName := NVL(lName,' ');

             IF(fName <> ' ' and lName = ' ') THEN
                lName := 'NLN';
             END IF;

             IF(lName <> ' ' and fName = ' ') THEN
                fName := 'NFN';
             END IF;
  END cosigner_name_validation;

-- To fetch the Contact Information of the Borrower

 PROCEDURE get_contact_info(p_student_id             NUMBER,
                            lv_s_foreign_postal_code OUT NOCOPY VARCHAR2 ,
                            lv_p_foreign_postal_code OUT NOCOPY VARCHAR2)
 IS
 BEGIN

  -- ##################################################
    -- Get the Phone and Foreign Postal Code Details
     NULL;
 END get_contact_info;

BEGIN
    g_debug_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_count_4   := 0;
    lv_trans_count  := 0;
    lv_8_disb_count := 0;
    retcode:=0;
    igf_aw_gen.set_org_id(p_org_id);

     l_n_send2_rec_cnt   := 0;
     l_n_send5_rec_cnt   := 0;
     l_n_send7_rec_cnt   := 0;

    -- Fetch the Recipient Description
    OPEN  cur_recip_desc(p_relationship_cd);
    FETCH cur_recip_desc INTO recip_desc_rec;
    IF cur_recip_desc%NOTFOUND THEN
         CLOSE cur_recip_desc;

         --The recipient information does not exist
         IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','Recipient description not found');
         END IF;
         fnd_message.set_name('IGF','IGF_SL_RECIP_NOT_FOUND');
         fnd_message.set_token('REL_CODE',p_relationship_cd);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         RETURN;
    END IF;
    CLOSE cur_recip_desc;

    -- Check whether there are loan records to be originated after Validation.
    IF p_loan_catg = 'CL_STAFFORD' THEN
      p_fed_fund_1 := 'FLS';
      p_fed_fund_2 := 'FLU';
    END IF;

    IF p_loan_catg = 'CL_PLUS' THEN
      p_fed_fund_1 := 'FLP';
      p_fed_fund_2 := 'FLP';
    END IF;

    IF p_loan_catg = 'CL_ALT' THEN
      p_fed_fund_1 := 'ALT';
      p_fed_fund_2 := 'ALT';
    END IF;

    IF p_loan_catg = 'CL_GPLUSFL' THEN
      p_fed_fund_1 := 'GPLUSFL';
      p_fed_fund_2 := 'GPLUSFL';
    END IF;

    IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','p_ci_cal_type:'||p_ci_cal_type);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','p_ci_sequence_number:'||p_ci_sequence_number);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','p_fed_fund_1:'||p_fed_fund_1);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','p_fed_fund_2:'||p_fed_fund_2);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','p_loan_number:'||NVL(p_loan_number,'NULL'));
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','recipient_type:'||NVL(recip_desc_rec.recipient_type,'NULL'));
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','recipient_id:'||recip_desc_rec.recipient_id);
    END IF;

    OPEN  cur_loan_dtls(p_ci_cal_type,
                        p_ci_sequence_number,
                        p_fed_fund_1,
                        p_fed_fund_2,
                        p_loan_number,
                        'V',
                        'Y',
                        p_relationship_cd,
                        p_base_id,
                        p_school_id
                       );
       FETCH cur_loan_dtls INTO loan_rec;
       IF cur_loan_dtls%NOTFOUND THEN
          CLOSE cur_loan_dtls;
          IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
            fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','No loan data found');
          END IF;
          RAISE no_loan_data;
       END IF;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Processing Loan Number:' || loan_rec.loan_number);
      END IF;

      CLOSE cur_loan_dtls;


     --Fetch School Id  for the Recipient Details fetched
     -- Removed the cursor cur_school_id as p_school_id is now used instead of fetching School ID.

     IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_eft_authorization:' || lv_eft_authorization);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'p_media_type:' || p_media_type);
     END IF;


     -- code which fetches ope_id code using cur_ope_id into lv_ope_id is removed.
     -- as lv_ope_id is being replaced by new parameter p_school_id w.r.t. FA 126.


     -- Fetch Data For concatenating values for Header Record to get value for Processing Year for concatenation

     lv_process_year := get_process_year;

     IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_process_year:' || lv_process_year);
     END IF;

     -- Compute Batch ID.
     -- Note : Though Batch ID is computed, not sending this batch id to commonline, as our computed
     -- Batch ID is more than the field size given by CL. Further, it is optional for CL.

     lv_batch_id := NULL;
     lv_batch_id := '@A'
                    ||RPAD(NVL(recip_desc_rec.recipient_id,' '),6)
                    ||RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),2)
                    ||RPAD(NVL(lv_process_year,' '),2)
                    ||RPAD(NVL(p_school_id,' '),8)
                    ||RPAD(NVL(sch_non_ed_branch,' '),4)
                    ||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');

      -- Get the Software Details
     lv_software_code    := get_software_code;
     lv_software_version := get_software_version;

     IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_software_code:' || lv_software_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_software_version:' || lv_software_version);
     END IF;

     -- museshad(Bug# 4346258) -  Added the parameter p_base_id due to change in the
     --                           signature of the function 'get_cl_version()'
     lv_cl_version      := igf_sl_gen.get_cl_version(p_ci_cal_type, p_ci_sequence_number,loan_rec.relationship_cd,p_base_id);
     lv_file_ident_code := igf_sl_gen.get_cl_file_type(lv_cl_version, 'CL_ORIG_SEND', 'FILE-IDENT-CODE');
     lv_file_ident_name := igf_sl_gen.get_cl_file_type(lv_cl_version, 'CL_ORIG_SEND', 'FILE-IDENT-NAME');

     IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_file_ident_code:' || lv_file_ident_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_file_ident_name:' || lv_file_ident_name);
     END IF;

    -- Get School name for p_school_id
    OPEN cur_get_school_name;
    FETCH cur_get_school_name INTO lv_source_name;
    CLOSE cur_get_school_name;

    -- To create a Header Record for each of the files
    l_trailer_datetime :=TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS');  --This is printed in Header.Same should be printed in trailer also.
                                                               --Even if there is one sec diff CL Tool gives error.
    l_v_trailer_date   := TO_CHAR(SYSDATE,'YYYYMMDD');
    l_v_trailer_time   := TO_CHAR(SYSDATE,'HH24MISS');

    lv_header_rec:=NULL;
    -- masehgal    2477912   Made record "upper" to resolve NCAT reported errors
   IF lv_cl_version = 'RELEASE-5' THEN
    lv_header_rec:=UPPER('@H'||RPAD(NVL(lv_software_code,' '),4,' ')
                             ||RPAD(NVL(lv_software_version,' '),4,' ')
                             ||RPAD(' ',12,' ')
                             ||l_v_trailer_date
                             ||l_v_trailer_time
                             ||l_v_trailer_date
                             ||l_v_trailer_time
                             ||RPAD(lv_file_ident_name,19)
                             ||RPAD(lv_file_ident_code,5)
                             ||RPAD(NVL(lv_source_name,' '),32,' ')
                             ||RPAD(NVL(p_school_id,' '),8,' ')
                             ||RPAD(' ',2,' ')
                             ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                             ||'S'
                             ||RPAD(NVL(recip_desc_rec.recip_description,' '),32,' ')
                             ||RPAD(NVL(recip_desc_rec.recipient_id,' '),8,' ')
                             ||'  '
                             ||RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),4,' ')
                             ||NVL(p_media_type,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||LPAD(' ',773,' ')
                             ||'*');
   ELSIF lv_cl_version = 'RELEASE-4' THEN
    lv_header_rec:=UPPER('@H'||RPAD(NVL(lv_software_code,' '),4,' ')
                             ||RPAD(NVL(lv_software_version,' '),4,' ')
                             ||RPAD(' ',12,' ')
                             ||l_v_trailer_date
                             ||l_v_trailer_time
                             ||l_v_trailer_date
                             ||l_v_trailer_time
                             ||RPAD(lv_file_ident_name,19)
                             ||RPAD(lv_file_ident_code,5)
                             ||RPAD(NVL(lv_source_name,' '),32,' ')
                             ||RPAD(NVL(p_school_id,' '),8,' ')
                             ||RPAD(' ',2,' ')
                             ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                             ||'S'
                             ||RPAD(NVL(recip_desc_rec.recip_description,' '),32,' ')
                             ||RPAD(NVL(recip_desc_rec.recipient_id,' '),8,' ')
                             ||'  '
                             ||RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),4,' ')
                             ||NVL(p_media_type,' ')
                             ||RPAD(' ',9,' ')
                             ||RPAD(' ',9,' ')
                             ||LPAD(' ',693,' ')
                             ||'*');
   END IF;

    -- To output the Header Record into every file that would be created for the distinct Recipient details


    fnd_file.put_line(fnd_file.output,UPPER(lv_header_rec));

    -- To insert the Computed Batch Number into CL Batch Table
    lv_row_id  := NULL;
    igf_sl_cl_batch_pkg.insert_row (
                     x_mode                              => 'R',
                     x_rowid                             => lv_row_id,
                     x_cbth_id                           => lv_cbth_id,
                     x_batch_id                          => lv_batch_id,
                     x_file_creation_date                => TRUNC(SYSDATE),
                     x_file_trans_date                   => TRUNC(SYSDATE),
                     x_file_ident_code                   => RPAD(lv_file_ident_code,5),
                     x_recipient_id                      => recip_desc_rec.recipient_id,
                     x_recip_non_ed_brc_id               => recip_desc_rec.recip_non_ed_brc_id,
                     x_source_id                         => p_school_id,
                     x_source_non_ed_brc_id              => sch_non_ed_branch,
                     x_send_resp                         =>  'S',
                     x_record_count_num                  =>  NULL                          ,
                     x_total_net_disb_amt                =>  NULL                          ,
                     x_total_net_eft_amt                 =>  NULL                          ,
                     x_total_net_non_eft_amt             =>  NULL                          ,
                     x_total_reissue_amt                 =>  NULL                          ,
                     x_total_cancel_amt                  =>  NULL                          ,
                     x_total_deficit_amt                 =>  NULL                          ,
                     x_total_net_cancel_amt              =>  NULL                          ,
                     x_total_net_out_cancel_amt          =>  NULL
                      );

   FOR loan_rec_temp IN cur_loan_dtls(p_ci_cal_type,
                                      p_ci_sequence_number,
                                      p_fed_fund_1,
                                      p_fed_fund_2,
                                      p_loan_number,
                                      'V',
                                      'Y',
                                      p_relationship_cd,
                                      p_base_id,
                                      p_school_id
                                     ) LOOP
      -- Initialise the Cursor Record variable to NULL.

      BEGIN

       loan_rec := loan_rec_temp;
       igf_sl_award.pick_setup(loan_rec.base_id,p_ci_cal_type,p_ci_sequence_number,lv_rel_code,lv_person_id,lv_party_id,loan_rec_temp.alt_rel_code);
       -- FACR116 Check if the alt_loan_code is not null and the set up record is present or not
       IF loan_rec_temp.fed_fund_code = 'ALT' THEN
          IF loan_rec_temp.alt_loan_code IS NULL THEN
             fnd_message.set_name('IGF','IGF_AW_NO_ALT_LOAN_CODE');
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             RAISE SKIP_RECORD;
          ELSIF lv_rel_code IS NULL AND lv_person_id IS NULL THEN
             fnd_message.set_name('IGF','IGF_SL_NO_ALT_SETUP');
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             RAISE SKIP_RECORD;
          END IF;
       END IF;
      /*
       OPEN   cur_get_setup(p_ci_cal_type,p_ci_sequence_number,lv_rel_code,lv_party_id);
       FETCH  cur_get_setup INTO lv_eft_authorization;
       CLOSE  cur_get_setup;
*/

      -- Call Get Information procedure to fetch values for Contact Information
      get_contact_info(loan_rec.student_id,lv_s_foreign_postal_code,lv_p_foreign_postal_code);

      -- Get Few student Details from ISIR.
      OPEN  cur_isir_depend_status;
      FETCH cur_isir_depend_status INTO lv_dependency_status;
      IF cur_isir_depend_status%NOTFOUND THEN
         CLOSE cur_isir_depend_status;
         fnd_message.set_name('IGF','IGF_GE_REC_NO_DATA_FOUND');
         fnd_message.set_token('P_RECORD','igf_ap_fa_base_rec');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
           fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','Record Data not found');
         END IF;
         RAISE SKIP_RECORD;
      ELSE
         CLOSE cur_isir_depend_status;
      END IF;

      --Fetch details of student and parent
      igf_sl_gen.get_person_details(loan_rec.student_id,student_dtl_cur);
      FETCH student_dtl_cur INTO student_dtl_rec;
      CLOSE student_dtl_cur;
      igf_sl_gen.get_person_details(loan_rec.p_person_id,parent_dtl_cur);
      FETCH parent_dtl_cur INTO parent_dtl_rec;
      CLOSE parent_dtl_cur;

        --FA 161 - Due to the introduction of a new mapping form, we don't use the lookup tag but rather require the lookup_code itself to
      -- determine the mapping values...and hence the below blocks of citizenship_dtl_cur
      -- Determine the Student's citizenhsip with the help of new mapping
      -- parent_dtl_rec.p_citizenship_status and student_dtl_rec.p_citizenship_status refer to the FA citizenship mapped code instead
      -- of OSS lookup tag value
      OPEN citizenship_dtl_cur(loan_rec.student_id);
      FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
      OPEN cur_fa_mapping (cp_citizenship_status => citizenship_dtl_rec.restatus_code,
                           cp_cal_type           => p_ci_cal_type,
                           cp_sequence_number    => p_ci_sequence_number);
      FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
      student_dtl_rec.p_citizenship_status := cur_fa_mapping_rec.fa_citi_stat_code;
      CLOSE cur_fa_mapping;
      CLOSE citizenship_dtl_cur;

      -- Determine the Parent's citizenhsip with the help of new mapping
      OPEN citizenship_dtl_cur(loan_rec.p_person_id);
      FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
      OPEN cur_fa_mapping (cp_citizenship_status => citizenship_dtl_rec.restatus_code,
                           cp_cal_type           => p_ci_cal_type,
                           cp_sequence_number    => p_ci_sequence_number);
      FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
      parent_dtl_rec.p_citizenship_status := cur_fa_mapping_rec.fa_citi_stat_code;
      CLOSE cur_fa_mapping;
      CLOSE citizenship_dtl_cur;

       -- logging details of student and parent

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student Full Name       :' ||student_dtl_rec.p_full_name );
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student First Name      :' ||student_dtl_rec.p_first_name);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student Birth date      :' ||student_dtl_rec.p_date_of_birth);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student address1        :' ||student_dtl_rec.p_permt_addr1);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student address2        :' ||student_dtl_rec.p_permt_addr2);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student License Num     :' ||student_dtl_rec.p_license_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student License State   :' ||student_dtl_rec.p_license_state);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Student SSN             :' ||student_dtl_rec.p_ssn);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower Full Name      :' ||parent_dtl_rec.p_full_name );
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower First Name     :' ||parent_dtl_rec.p_first_name);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower Birth date     :' ||parent_dtl_rec.p_date_of_birth);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower address1       :' ||parent_dtl_rec.p_permt_addr1);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower address2       :' ||parent_dtl_rec.p_permt_addr2);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower License Num    :' ||parent_dtl_rec.p_license_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower License State  :' ||parent_dtl_rec.p_license_state);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Borrower SSN            :' ||parent_dtl_rec.p_ssn);
      END IF;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_license_number:' ||lv_s_license_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_license_state:' ||lv_s_license_state);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_citizenship_status:' ||lv_s_citizenship_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_alien_reg_num:' ||lv_alien_reg_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_dependency_status:' ||lv_dependency_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_legal_res_date:' ||lv_s_legal_res_date);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_legal_res_state:' ||lv_s_legal_res_state);
      END IF;

      --Code added for bug 3603289 start
      lv_s_license_number     := student_dtl_rec.p_license_num;
      lv_s_license_state      := student_dtl_rec.p_license_state;
      lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
      lv_alien_reg_num        := student_dtl_rec.p_alien_reg_num;
      lv_s_legal_res_date     := student_dtl_rec.p_legal_res_date;
      lv_s_legal_res_state    := student_dtl_rec.p_state_of_legal_res;
      --Code added for bug 3603289 end

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_license_number:' ||lv_s_license_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_license_state:' ||lv_s_license_state);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_citizenship_status:' ||lv_s_citizenship_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_alien_reg_num:' ||lv_alien_reg_num);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_dependency_status:' ||lv_dependency_status);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_legal_res_date:' ||lv_s_legal_res_date);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_s_legal_res_state:' ||lv_s_legal_res_state);
      END IF;

      lv_s_permt_phone  := NULL;
      lv_p_permt_phone  := NULL;
      l_phone           := NULL;

      --Whether Student or Parent get the Phone Number
      lv_s_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.student_id);
      lv_p_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.p_person_id);

      l_coa             := NULL;
      l_efc             := NULL;
      l_est_fin         := NULL;

      --Fetch the COA and EFC with respective to the new DLD
      OPEN  cur_get_fabase;
      FETCH cur_get_fabase INTO l_coa;
      CLOSE cur_get_fabase;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'l_coa:' ||l_coa);
      END IF;

      -- Get the EFC months for the for the Award Yr
      igf_aw_packng_subfns.get_fed_efc(
                                       l_base_id      => loan_rec.base_id,
                                       l_awd_prd_code => NULL,
                                       l_efc_f        => l_dummy_pell_efc,
                                       l_pell_efc     => l_dummy_pell_efc,
                                       l_efc_ay     => l_efc
                                       );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','l_efc:'||l_efc);
      END IF;

      l_efc := TRUNC(l_efc);

      --Fetch the Estimated Financial Aid
      OPEN  cur_get_fin_aid('OFFERED','ACCEPTED');
      FETCH cur_get_fin_aid INTO l_est_fin;
      CLOSE cur_get_fin_aid;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'l_est_fin:' ||l_est_fin);
      END IF;

      OPEN  cur_get_disb_num(loan_rec.award_id);
      FETCH cur_get_disb_num INTO ln_num_of_disb;
      CLOSE cur_get_disb_num;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'ln_num_of_disb:' ||ln_num_of_disb);
      END IF;


      IF lv_cl_version = 'RELEASE-5' THEN
        IF ln_num_of_disb > 4 THEN
                lv_indi := 'Y';
        ELSE
              lv_indi := ' ';
        END IF;
        IF loan_rec.borr_sign_ind = 'Y' THEN
           lv_borr_sign_ind := 'Y';
        ELSE
           lv_borr_sign_ind := ' ';
        END IF;
      IF loan_rec.stud_sign_ind = 'Y' THEN
         lv_stud_sign_ind := 'Y';
      ELSE
         lv_stud_sign_ind := ' ';
      END IF;

        IF loan_rec.borw_interest_ind = 'Y' THEN
           lv_borw_interest_ind := 'Y';
        ELSE
           lv_borw_interest_ind := ' ';
        END IF;

      END IF;

      IF lv_cl_version = 'RELEASE-4' THEN
        lv_borr_sign_ind := ' ';
        lv_indi          := ' ';
        lv_stud_sign_ind := ' ';
      END IF;

      IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_indi:' ||lv_indi);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_borr_sign_ind:' ||lv_borr_sign_ind);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'lv_stud_sign_ind:' ||lv_stud_sign_ind);
      END IF;

     OPEN   c_sl_lor (cp_n_loan_id     => loan_rec.loan_id);
     FETCH  c_sl_lor  INTO rec_c_sl_lor;
     CLOSE  c_sl_lor  ;
     IF NVL(rec_c_sl_lor.loan_app_form_code,'M') = 'M' THEN
        rec_c_sl_lor.deferment_request_code  := ' ';
         rec_c_sl_lor.borr_credit_auth_code  := ' ';
     END IF;
     lv_eft_authorization  := rec_c_sl_lor.eft_authorization_code;


      IF p_loan_catg = 'CL_STAFFORD' THEN

--     common for RELEASE- 4 AND RELEASE-5. No Change for stafford loans


         student_dtl_rec.p_permt_zip := TRANSLATE (UPPER(LTRIM(RTRIM(student_dtl_rec.p_permt_zip))),'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');
         lv_first_part_trans_rec:='@1'
                            ||NVL(loan_rec.rec_type_ind,' ')
                            ||RPAD(NVL(student_dtl_rec.p_last_name,' '),35,' ')
                            ||RPAD(NVL(student_dtl_rec.p_first_name,' '),12,' ')
                            ||RPAD(NVL(student_dtl_rec.p_middle_name,' '),1,' ')
                            ||LPAD(NVL(student_dtl_rec.p_ssn,' '),9,' ')                       -- For SSN#, Padding with Spaces.
                            ||RPAD(NVL(student_dtl_rec.p_permt_addr1,' '),30,' ')
                            ||RPAD(NVL(student_dtl_rec.p_permt_addr2,' '),30,' ')
                            ||RPAD(NVL(student_dtl_rec.p_permt_city,' '),24,' ')
                            ||RPAD(' ',6,' ')
                            ||RPAD(NVL(student_dtl_rec.p_permt_state,' '),2,' ')
                            ||LPAD(NVL(student_dtl_rec.p_permt_zip,' '),5,'0') ||'0000' -- zip code suffix hard coded
                            ||RPAD(NVL(lv_s_permt_phone,' '),10,' ')
                            ||RPAD(NVL(loan_rec.lender_id,' '),6,' ')
                            ||LPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),'0'),8,'0')
                            ||RPAD(NVL(loan_rec.cl_loan_type,' '),2,' ')
                            ||LPAD(TO_CHAR(NVL(loan_rec.requested_loan_amt,'0')),6,'0') --MN 7-Jan-2005
                            ||RPAD(NVL(rec_c_sl_lor.deferment_request_code,' '),1,' ')
                            ||LPAD(NVL(lv_borw_interest_ind,' '),1,' ')
                            ||LPAD(NVL(lv_eft_authorization,' '),1,' ')
                            ||LPAD(NVL(loan_rec.s_signature_code,' '),1,' ')
                            ||LPAD(NVL(TO_CHAR(loan_rec.p_signature_date,'YYYYMMDD'),'0'),8,'0')
                            ||RPAD(NVL(loan_rec.external_loan_id_txt,loan_rec.loan_number),17,' ')
                            ||LPAD(NVL(TO_CHAR(loan_rec.cl_seq_number),'0'),2,'0')
                            ||lv_indi               -- Bug 2814813, this field is Y  if no of disb > 4 or RELEASE-4
                            ||RPAD(' ',3,' ')
                            ||RPAD('0',6,'0')
                            ||RPAD(' ',3,' ')
                            ||RPAD(' ',9,' ')
                            ||RPAD(' ',10,' ')  -- Field 33 - Borrower Alien reg number - FA 161 - Bug # 5006583 - Not required for Stafford
                            ||RPAD(' ',35,' ')  -- last name removed
                            ||RPAD(' ',12,' ')  -- first name removed
                            ||RPAD(' ',1,' ')   -- middle name removed
                            ||LPAD('0',9,'0')   -- SSN made zero.
                            ||LPAD('0',8,'0')   -- DOB made zero
                            ||RPAD(' ',1,' ')   -- Removed Citizenship status
                            ||RPAD(' ',1,' ')   -- Removed Default Status Code
                            ||RPAD(' ',1,' ')   -- Removed Student Sign Code
                            ||RPAD(' ',20,' ')
                            ||LPAD(NVL(p_school_id,' '),8,'0')
                            ||RPAD(' ',2,' ')
                            ||LPAD(NVL(TO_CHAR(loan_rec.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')
                            ||LPAD(NVL(TO_CHAR(loan_rec.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')
                            ||RPAD(NVL(NVL(loan_rec.override_grade_level_code,loan_rec.grade_level_code),' '),1,' ')
                            ||RPAD(NVL(lv_borr_sign_ind,' '),1,' ')
                            ||RPAD(NVL(loan_rec.enrollment_code,' '),1,' ')
                            ||LPAD(NVL(TO_CHAR(loan_rec.anticip_compl_date,'YYYYMMDD'),'0'),8,'0')
                            ||LPAD(NVL(l_coa,0),5,'0')
                            ||LPAD(NVL(l_efc,0),5,'0')
                            ||LPAD(NVL(l_est_fin,0),5,'0');


                 -- Fed Fund Code has been hard coded here as we need to implement the lowest level
                  -- check here.
                  --     common for RELEASE- 4 AND RELEASE-5. No Change for stafford loans
                  IF loan_rec.fed_fund_code = 'FLS' THEN
                        lv_first_part_trans_rec := lv_first_part_trans_rec
                                                 ||LPAD(NVL(loan_rec.loan_amt_accepted,0),5,'0')
                                                 ||LPAD('0',5,'0')
                                                 ||LPAD('0',5,'0');

                  ELSIF loan_rec.fed_fund_code = 'FLU' THEN
                    --     common for RELEASE- 4 AND RELEASE-5. No Change for stafford loans
                        lv_first_part_trans_rec := lv_first_part_trans_rec
                                                 ||LPAD('0',5,'0')
                                                 ||LPAD(NVL(loan_rec.loan_amt_accepted,0),5,'0')
                                                 ||LPAD('0',5,'0');

                  END IF;


     -- Second Part of the Transaction Record has Concatenated Disbursement dates
     -- common for RELEASE- 4 AND RELEASE-5. No Change for stafford loans
     lv_third_part_trans_rec:=   LPAD(NVL(TO_CHAR(loan_rec.sch_cert_date,'YYYYMMDD'),'0'),8,'0')
                               ||RPAD(' ',16,' ')
                               ||LPAD('0',9,'0')
                               ||'  '
                               ||RPAD(NVL(loan_rec.esign_src_typ_cd,' '),9,' ') -- Field 67 - FA 161 - E-sgignature Source type code
                               ||RPAD(NVL(loan_rec.lender_id,' '),6,' ')
                               ||RPAD('0',5,'0')
                               ||RPAD('0',5,'0')
                               ||RPAD('0',5,'0')
                               ||RPAD('0',5,'0')
                               ||RPAD(' ',9,' ')        --Duns Lender ID has been replaced by ' ' Bug 2400487
                               ||RPAD(' ',6,' ')
                               ||RPAD(NVL(loan_rec.guarantor_id,' '),3,' ')
                               ||NVL(rec_c_sl_lor.loan_app_form_code,' ')  -- field 76 - fed form appl code
                               ||RPAD(' ',9,' ')      -- Duns Guarant ID has been replaced by ' ' Bug 2400487
                               ||RPAD(' ',3,' ')
                               ||LPAD('0',8,'0')
                               ||RPAD(NVL(lv_s_license_state,' '),2,' ')
                               ||RPAD(NVL(lv_s_license_number,' '),20,' ')
                               ||'N'
                               ||RPAD(NVL(rec_c_sl_lor.school_use_txt,' '),23,' ');

     -- Fourth Part of the Transaction Record has Concatenated Disbursement Release Indicators

     IF lv_cl_version = 'RELEASE-5' THEN

     lv_fifth_part_trans_rec :=   RPAD(' ',14,' ')
                                ||RPAD(NVL(loan_rec.req_serial_loan_code,' '),1,' ')
                                ||rec_c_sl_lor.borr_credit_auth_code    -- this should be space if field 76 is 'M'
                                ||RPAD(NVL(loan_rec.lend_non_ed_brc_id,' '),4,' ')
                                ||RPAD(' ',20,' ')
                                ||RPAD(NVL(lv_stud_sign_ind,' '),1,' ')
                                ||RPAD(NVL(loan_rec.prc_type_code,' '),2,' ')
                                ||RPAD(NVL(rec_c_sl_lor.guarantor_use_txt,' '),23,' ')
                                ||RPAD(NVL(loan_rec.pnote_delivery_code,'P'),1,' ')
                                ||'   '
                                ||LPAD('0',7,'0');
     ELSIF lv_cl_version = 'RELEASE-4' THEN
     lv_fifth_part_trans_rec :=   RPAD(' ',14,' ')
                                ||RPAD(NVL(loan_rec.req_serial_loan_code,' '),1,' ')
                                ||' '                                                  -- this should be space as field 76 is 'M'
                                ||RPAD(NVL(loan_rec.lend_non_ed_brc_id,' '),4,' ')
                                ||RPAD(' ',20,' ')
                                ||' '
                                ||RPAD(NVL(loan_rec.prc_type_code,' '),2,' ')
                                ||RPAD(NVL(rec_c_sl_lor.guarantor_use_txt,' '),23,' ')
                                ||RPAD(NVL(loan_rec.pnote_delivery_code,'P'),1,' ')
                                ||'   '
                                ||LPAD('0',7,'0');
     END IF;
     -- Sixth Part of the Transaction Record has Concatenated Disbursement Amounts
     IF lv_cl_version = 'RELEASE-5' THEN
     lv_seventh_part_trans_rec :=  LPAD(NVL(TO_CHAR(NULL,'YYYYMMDD'),'0'),8,'0')
                                 ||RPAD(' ',92,' ')
                                 ||RPAD('0',9,'0')
                                 ||RPAD(' ',10,' ')
                                 ||RPAD(NVL(lv_s_foreign_postal_code,' '),14,' ')
                                 ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                                 ||RPAD(' ',123,' ')
                                 ||'*';
     ELSIF lv_cl_version = 'RELEASE-4' THEN
     lv_seventh_part_trans_rec :=  LPAD(NVL(TO_CHAR(NULL,'YYYYMMDD'),'0'),8,'0')
                                 ||RPAD(' ',92,' ')
                                 ||RPAD('0',9,'0')
                                 ||RPAD(' ',71,' ')
                                 ||'*';
     END IF;

     --Since Alternate Loan Origination is Similar to PLUS Loan Origination only the
     --feilds that could be different are checked

      ELSIF p_loan_catg IN  ('CL_PLUS','CL_ALT','CL_GPLUSFL') THEN
           -- Checking if Parent Status is Defaulted
           IF loan_rec.p_default_status IN ('N','Z') THEN
              loan_rec.p_default_status:='N';
           END IF;

           -- Checking if Student Status is Defaulted
           IF loan_rec.s_default_status IN ('N','Z') THEN
              loan_rec.s_default_status:='N';
           END IF;

           --Based on Federal fund Code Need to Send the information
           -- as per the Send File

           --Check if its FLP
           IF  igf_sl_gen.chk_cl_plus(loan_rec.fed_fund_code)='TRUE' OR igf_sl_gen.chk_cl_gplus(loan_rec.fed_fund_code)='TRUE'  THEN

               IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Current loan is a plus loan');
               END IF;

               l_phone              := lv_p_permt_phone;
               l_plus_cert_amt      := loan_rec.loan_amt_accepted;
               l_alt_cert_amt       := NULL;
               l_tot_alt_debt       := NULL;
               l_borw_ind_code      := ' ';
               lv_borw_interest_ind := NULL;

           ELSIF igf_sl_gen.chk_cl_alt(loan_rec.fed_fund_code)='TRUE' THEN

               IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Current loan is a alternate loan');
               END IF;

               l_plus_cert_amt      := NULL;
               l_alt_cert_amt       := loan_rec.loan_amt_accepted;  -- should be sum of all disb for this loan
               l_tot_alt_debt       := NULL;

               --Need to check if Alt Loan is Borrowed by Student or Parent
               IF loan_rec.student_id = NVL(loan_rec.p_person_id,'0') THEN
                 --Borrrower is Student
                 parent_dtl_rec.p_citizenship_status :=lv_s_citizenship_status;
                 parent_dtl_rec.p_state_of_legal_res :=lv_s_legal_res_state;
                 parent_dtl_rec.p_legal_res_date     :=lv_s_legal_res_date;
                 loan_rec.p_default_status           :=loan_rec.s_default_status;
                 l_borw_ind_code                     :='Y';
                 parent_dtl_rec.p_license_num        :=lv_s_license_number;
                 parent_dtl_rec.p_license_state      :=lv_s_license_state;
                 l_phone                             :=lv_s_permt_phone;
               ELSIF loan_rec.student_id <> NVL(loan_rec.p_person_id,'0') THEN
                 --Borrower is not Student then send the values available and fetched as it is.
                 l_borw_ind_code               :='N'; --- Alter Borrw Indicator Code  N.
                 l_phone                       :=lv_p_permt_phone;
               END IF;

               --Fetch the Total ALternate Debt for this Person Number minus the Current
               --Award Year
               OPEN  cur_get_alt_debt;
               FETCH cur_get_alt_debt INTO l_tot_alt_debt;
               CLOSE cur_get_alt_debt;

           END IF;  -- Check for ALT or FLP

           --
           -- If the Alternative Bor Indicator Code is N then we need to
           -- send the PLUS/ALT Student SSN, Otherwise send 0
           --

           IF  l_borw_ind_code = 'N' OR          -- 'N' for Alt Loans
               l_borw_ind_code = ' ' THEN        -- ' ' for FLP Loans
               l_s_ssn :=LPAD(NVL(student_dtl_rec.p_ssn,' '),9,' ');
           ELSE
               l_s_ssn :=LPAD('0',9,'0');
           END IF;

           --     common for RELEASE- 4 AND RELEASE-5. No Change for stafford loans
           parent_dtl_rec.p_permt_zip := TRANSLATE (UPPER(LTRIM(RTRIM(parent_dtl_rec.p_permt_zip))),'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');

           lv_first_part_trans_rec:='@1'
                              ||RPAD(NVL(loan_rec.rec_type_ind,' '),1,' ')--field 2
                              ||RPAD(NVL(parent_dtl_rec.p_last_name,' '),35,' ')--field 3
                              ||RPAD(NVL(parent_dtl_rec.p_first_name,' '),12,' ') -- field 4
                              ||RPAD(NVL(parent_dtl_rec.p_middle_name,' '),1,' ') --field 5
                              ||RPAD(NVL(parent_dtl_rec.p_ssn,' '),9,' ')--field 6
                              -- For SSN#, padding with Spaces.
                              ||RPAD(NVL(parent_dtl_rec.p_permt_addr1,' '),30,' ')--field 7
                              ||RPAD(NVL(parent_dtl_rec.p_permt_addr2,' '),30,' ')--field 8
                              ||RPAD(NVL(parent_dtl_rec.p_permt_city,' '),24,' ')--field 9
                              ||RPAD(' ',6,' ')--filler field 10
                              ||RPAD(NVL(parent_dtl_rec.p_permt_state,' '),2,' ')--field 11
                              ||LPAD(NVL(parent_dtl_rec.p_permt_zip,' '),5,'0') ||'0000' -- zip code suffix hard coded
                              ||RPAD(NVL(l_phone,' '),10,' ')--field 14
                              ||RPAD(NVL(loan_rec.lender_id,' '),6,' ')--field 15
                              ||LPAD(NVL(TO_CHAR(parent_dtl_rec.p_date_of_birth,'YYYYMMDD'),'0'),8,'0')--field 16
                              ||RPAD(NVL(loan_rec.cl_loan_type,'  '),2,'  ') -- field 17
                              ||LPAD(TO_CHAR(NVL(loan_rec.requested_loan_amt,0)),6,'0')--field 18 MN 7-Jan-2005
                              ||RPAD(NVL(rec_c_sl_lor.deferment_request_code,' '),1,' ')
                              ||RPAD(NVL(lv_borw_interest_ind,' '),1,' ')--field 20
                              ||RPAD(NVL(lv_eft_authorization,' '),1,' ')--field 21
                              ||RPAD(NVL(loan_rec.p_signature_code,' '),1,' ')--field 22
                              ||LPAD(NVL(TO_CHAR(loan_rec.p_signature_date,'YYYYMMDD'),'0'),8,'0')--field 23
                              ||RPAD(NVL(loan_rec.external_loan_id_txt,loan_rec.loan_number),17,' ')
                              ||LPAD('0',2,'0') --'00'--field 25 CommonLine Loan Sequence Number
                              ||lv_indi -- this field is Y  if no of disb > 4 or RELEASE-4
                              ||RPAD(NVL(parent_dtl_rec.p_citizenship_status,' '),1,' ')--field 27
                              ||RPAD(NVL(parent_dtl_rec.p_state_of_legal_res,' '),2,' ')--field 28
                              ||LPAD(NVL(TO_CHAR(parent_dtl_rec.p_legal_res_date,'YYYYMM'),'0'),6,'0')--field 29
                              ||RPAD(NVL(loan_rec.p_default_status,' '),1,' ')--field 30
                              ||RPAD(NVL(loan_rec.borw_outstd_loan_code,' '),1,' ')--field 31
                              ||l_borw_ind_code--field 32
                              ||RPAD(' ',9,' ')--filler field 33
                              -- DUNS Borrow Lender ID has been replaced by ' ' Bug 2400487
                              ||RPAD(NVL(loan_rec.b_alien_reg_num_txt,' '),10,' ')-- FA 161 - Bug # 5006583 - Filler replaced by borw alien reg num
                              ||RPAD(NVL(student_dtl_rec.p_last_name,' '),35,' ')--field 35
                              ||RPAD(NVL(student_dtl_rec.p_first_name,' '),12,' ')--field 36
                              ||RPAD(NVL(student_dtl_rec.p_middle_name,' '),1,' ')--field 37
                              ||l_s_ssn--field 38
                              ||LPAD(NVL(TO_CHAR(student_dtl_rec.p_date_of_birth,'YYYYMMDD'),'0'),8,'0')--field 39
                              ||LPAD(NVL(lv_s_citizenship_status,' '),1,' ')--field 40
                              ||LPAD(NVL(loan_rec.s_default_status,' '),1,' ')--field 41
                              ||LPAD(NVL(loan_rec.s_signature_code,' '),1,' ')--field 42
                              ||LPAD(' ',20,' ')--filler field 43
                              ||LPAD(NVL(p_school_id,' '),8,'0')--field 44
                              ||'  '--filler field 45
                              ||LPAD(NVL(TO_CHAR(loan_rec.loan_per_begin_date,'YYYYMMDD'),'0'),8,'0')--field 46
                              ||LPAD(NVL(TO_CHAR(loan_rec.loan_per_end_date,'YYYYMMDD'),'0'),8,'0')--field 47
                              ||RPAD(NVL(NVL(loan_rec.override_grade_level_code,loan_rec.grade_level_code),' '),1,' ')
                              ||RPAD(NVL(lv_borr_sign_ind,' '),1,' ')--field 49
                              ||NVL(loan_rec.enrollment_code,'F')--field 50
                              ||LPAD(NVL(TO_CHAR(loan_rec.anticip_compl_date,'YYYYMMDD'),'0'),8,'0')--field 51
                              ||LPAD(NVL(l_coa,0),5,'0')--field 52
                              ||LPAD(NVL(l_efc,0),5,'0')--field 53
                              ||LPAD(NVL(l_est_fin,0),5,'0')--field 54
                              ||LPAD('0',5,'0')--field 55 Subsidized Federal Stafford Certified Amount
                              ||LPAD('0',5,'0')--field 56 Unsubsidized Federal Stafford Certified Amount
                              ||LPAD(TO_CHAR(NVL(l_plus_cert_amt,0)),5,'0');--field 57

             -- Second Part of the Transaction Record has Concatenated Disbursement dates

                 lv_third_part_trans_rec := LPAD(NVL(TO_CHAR(loan_rec.sch_cert_date,'YYYYMMDD'),'0'),8,'0')--field 62 School Certification Date
                                          ||LPAD(' ',16,' ')--filler field 63
                                          ||LPAD(NVL(l_alt_cert_amt,0),5,0)--field 64
                                          ||RPAD('0',4,'0')--field 65 Alternative Loan Application Version Code
                                          ||RPAD(' ',2,' ')--filler field 66
                                          ||RPAD(NVL(loan_rec.esign_src_typ_cd,' '),9,' ')--filler field 67 -- FA 161 - Bug # 5006587 - E-signature Source type code
                                          ||RPAD(NVL(loan_rec.lender_id,' '),6,' ')--field 68
                                          ||RPAD('0',5,'0')--field 69 Subsidized Federal Stafford Approved Amount
                                          ||RPAD('0',5,'0')--field 70 Unsubsidized Federal Stafford Approved Amount
                                          ||RPAD('0',5,'0')--field 71 Federal PLUS Approved Amount
                                          ||RPAD('0',5,'0')--field 72 Alternative Loan Approved Amount
                                          ||RPAD(' ',9,' ') --filler field 73 DUNS LENDER ID has been replaced by ' ' Bug 2400487
                                          ||RPAD(' ',6,' ') --filler field 74
                                          ||RPAD(NVL(loan_rec.guarantor_id,' '),3,' ') --field 75
                                          ||NVL(rec_c_sl_lor.loan_app_form_code,' ') --field 76
                                          ||RPAD(' ',9,' ')  -- DUNS GUARNT ID has been replaced by ' ' Bug 2400487(field 77)
                                          ||RPAD(' ',3,' ') --Filler(field 78) and Lender blanket guarantee indicator code(field 79)
                                          ||LPAD('0',8,'0') --field 80 Lender Blanket Guarantee Approval Date
                                          ||RPAD(NVL(parent_dtl_rec.p_license_state,' '),2,' ')--field 81
                                          ||RPAD(NVL(parent_dtl_rec.p_license_num,' '),20,' ') --field 82
                                          ||'N' --field 83 -borrower references code
                                          ||RPAD(NVL(rec_c_sl_lor.school_use_txt,' '),23,' ');--field 84 (School Use only)


            -- Fourth Part of the Transaction Record has Concatenated Disbursement Indicators




     IF lv_cl_version = 'RELEASE-5' THEN

    lv_fifth_part_trans_rec :=  RPAD(' ',14,' ') --field 89 (foreign postal code)
                                      ||RPAD(NVL(loan_rec.req_serial_loan_code,' '),1,' ') -- bvisvana - FA 161 - Bug # 5006583 - It is a req field
                                      --Req Serial Loan Code should be Blank for FLP/ALT -field 90
                                      ||RPAD(NVL(rec_c_sl_lor.borr_credit_auth_code,' '),1,' ') --field 91
                                      ||RPAD(NVL(loan_rec.lend_non_ed_brc_id,' '),4,' ') --field 92
                                      ||RPAD(' ',20,' ') --field 93 (lender use only)
                                      ||RPAD(NVL(lv_stud_sign_ind,' '),1,' ')
                                      ||RPAD(NVL(loan_rec.prc_type_code,' '),2,' ')
                                      ||RPAD(' ',23,' ')--field 96 guarantor use only
                                      ||NVL(loan_rec.pnote_delivery_code,'P')
                                      ||RPAD(NVL(loan_rec.alt_loan_code,' '),3,' ')--field 98 Alternative Loan Program Type Code FACR116
                                      ||LPAD(NVL(l_tot_alt_debt,0),7,0);--field 99


     ELSIF lv_cl_version = 'RELEASE-4' THEN

     lv_fifth_part_trans_rec :=   RPAD(' ',14,' ')
                                ||RPAD(NVL(loan_rec.req_serial_loan_code,' '),1,' ') -- bvisvana - FA 161 - Bug # 5006583 - It is a req field
                                -- Req Serial Loan Code should be Blank for FLP/ALT -field 90
				                  -- Bug fix - 4117260, - removed the condition introduced by 4103342
						  -- and reverted back to the original condition-   field 88 - Req Serial Loan Code should be Blank for FLP/ALT
                                ||' '  -- this should be space for 'RELEASE-4'
                                ||RPAD(NVL(loan_rec.lend_non_ed_brc_id,' '),4,' ')
                                ||RPAD(' ',20,' ')
                                ||' '
                                ||RPAD(NVL(loan_rec.prc_type_code,' '),2,' ')
                                ||RPAD(NVL(rec_c_sl_lor.guarantor_use_txt,' '),23,' ')
                                ||RPAD(NVL(loan_rec.pnote_delivery_code,'P'),1,' ')
                                      ||RPAD(NVL(loan_rec.alt_loan_code,' '),3,' ')--field 98 Alternative Loan Program Type Code FACR116
                                      ||LPAD(NVL(l_tot_alt_debt,0),7,0);--field 99
     END IF;


            -- Sixth part of the Transaction Record has concatenated Disbursement Amounts

     IF lv_cl_version = 'RELEASE-5' THEN
     lv_seventh_part_trans_rec :=  LPAD(NVL(TO_CHAR(NULL,'YYYYMMDD'),'0'),8,'0')
                                 ||RPAD(' ',92,' ')
                                 ||RPAD('0',9,'0')
                                 ||RPAD(' ',10,' ')
                                 ||RPAD(NVL(lv_s_foreign_postal_code,' '),14,' ')
                                 ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                                 ||RPAD(' ',123,' ')
                                 ||'*';
     ELSIF lv_cl_version = 'RELEASE-4' THEN
     lv_seventh_part_trans_rec :=  LPAD(NVL(TO_CHAR(NULL,'YYYYMMDD'),'0'),8,'0')
                                 ||RPAD(' ',92,' ')
                                 ||RPAD('0',9,'0')
                                 ||RPAD(' ',71,' ')
                                 ||'*';
     END IF;


         END IF; --End of Check for Loan Category

             -- Form the Disbursement Data to be sent.
             lv_counter              := 0;
             lv_1_final_disb_date    := NULL;
             lv_1_final_gross_amt    := NULL;
             lv_1_final_hold_rel_ind := NULL;
             lv_8_final_disb_date    := NULL;
             lv_8_final_gross_amt    := NULL;
             lv_8_final_hold_rel_ind := NULL;
	     lv_l_direct_to_borr_flag :=NULL;
             lv_8_direct_to_borr_flag :=NULL;

             -- Open Cursor for fetching the Disbursement Dates ,Amounts and Rel Hold Indicators
             -- bvisvana - Bug # 5078644 - lv_8_final_gross_amt and lv_1_final_gross_amt are applicable / recommended only for Alternative loans
             FOR drec IN cur_disb_details LOOP

                lv_counter := lv_counter + 1;

                   --Disbursement Hold Indicators can take values only as H - Hold / R-Rlease Hold
                   --NVL(drec.hold_rel_ind,'N') should be replaced by NVL(drec.hold_rel_ind,'R')
                   --Bug 2477912

                IF lv_counter > 4 THEN
                   lv_8_final_disb_date    := lv_8_final_disb_date    || LPAD(NVL(TO_CHAR(drec.disb_date, 'YYYYMMDD'),'0'),8,'0');
                   IF p_loan_catg = 'CL_ALT' THEN -- Bug 5078644
                     lv_8_final_gross_amt    := lv_8_final_gross_amt    || LPAD(TO_CHAR(NVL(drec.disb_accepted_amt,'0')),5,'0');
                   END IF;
                   lv_8_final_hold_rel_ind := lv_8_final_hold_rel_ind || NVL(drec.hold_rel_ind,'R');
		   lv_8_direct_to_borr_flag := lv_8_direct_to_borr_flag || NVL(drec.direct_to_borr_flag,' ');
                ELSE
                   lv_1_final_disb_date    := lv_1_final_disb_date    || LPAD(NVL(TO_CHAR(drec.disb_date, 'YYYYMMDD'),'0'),8,'0');
                   IF p_loan_catg = 'CL_ALT' THEN -- Bug 5078644
                     lv_1_final_gross_amt    := lv_1_final_gross_amt    || LPAD(TO_CHAR(NVL(drec.disb_accepted_amt,'0')),5,'0');
                   END IF;
                   lv_1_final_hold_rel_ind := lv_1_final_hold_rel_ind || NVL(drec.hold_rel_ind,'R');
		   lv_l_direct_to_borr_flag := lv_l_direct_to_borr_flag || NVL(drec.direct_to_borr_flag,' ');
                END IF;

             END LOOP;  -- End of Disbursement Cursor Loop;

	     lv_third_part_trans_rec  := substr(lv_third_part_trans_rec,1,8) || RPAD(lv_l_direct_to_borr_flag,4,' ') || substr(lv_third_part_trans_rec,13);


             -- Spool @1 Record
             -- masehgal    2477912   Made record "upper" to resolve NCAT reported errors
             fnd_file.put_line(fnd_file.output, UPPER(lv_first_part_trans_rec
                                                     ||RPAD(lv_1_final_disb_date,32,'0')
                                                     ||lv_third_part_trans_rec
                                                     ||RPAD(lv_1_final_hold_rel_ind,4,' ')--fields 85 to 88(disbursement hold/release indicator)
                                                     ||lv_fifth_part_trans_rec
                                                     ||RPAD(NVL(lv_1_final_gross_amt,'0'),20,'0')
                                                     ||lv_seventh_part_trans_rec));
             -- Increment the counter for the Number of @1 records in this file
             lv_trans_count := lv_trans_count+1;

            IF igf_sl_gen.chk_cl_alt(loan_rec.fed_fund_code) = 'TRUE' THEN
               alter_rec := NULL;                    --   mnade 7-Feb-2005 Bug 4133414
               OPEN  cur_get_alternate;
               FETCH cur_get_alternate INTO alter_rec;
               CLOSE cur_get_alternate;

               -- Need to spool the @4 Record after the @1 Record if it exists for this loan id
               -- masehgal    2477912   Made record "upper" to resolve NCAT reported errors

               --veramach   Changed ' ' to '0' for fed_stafford_loan_debt,fed_sls_debt,heal_debt,perkins_debt,other_debt,borw_gross_annual_sal,
               --           borw_other_income,stud_mth_housing_pymt,stud_mth_crdtcard_pymt,stud_mth_auto_pymt,stud_mth_ed_loan_pymt,stud_mth_other_pymt

            -- bvisvana - Validation for Cosigner Data
            cosigner_name_validation (fName => alter_rec.cs1_fname,
                                      lName => alter_rec.cs1_lname
                                      );
            cosigner_name_validation (fName => alter_rec.cs2_fname,
                                      lName => alter_rec.cs2_lname
                                      );
            IF lv_cl_version = 'RELEASE-5' THEN
             l_v_owner_code := 'NCLP05';

              l_at4Record := '@4' ||l_v_owner_code
                            ||LPAD(NVL(TO_CHAR(alter_rec.fed_stafford_loan_debt),'0'),5,'0') -- Federal Stafford Loan Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.fed_sls_debt),'0'),5,'0') -- Federal SLS Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.heal_debt),'0'),6,'0') -- HEAL Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.perkins_debt),'0'),5,'0') -- Perkins Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.other_debt),'0'),6,'0') -- Other Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.other_loan_amt),'0'),7,'0') -- Other Loans this Period
                            ||NVL(alter_rec.crdt_undr_difft_name,'N') -- Credit Under Different Name Code
                            ||RPAD(alter_rec.cs1_lname,35,' ')  -- Cosigner1 Lname
                            ||RPAD(alter_rec.cs1_fname,12,' ')  -- Cosigner1 Fname
                            ||NVL(alter_rec.cs1_mi_txt,' ') --Cosigner1 Mname
                            ||LPAD(NVL(alter_rec.cs1_ssn_txt,'0'),9,'0')   -- Cosigner 1 SSN
                            ||NVL(alter_rec.cs1_citizenship_status,' ') -- Cosigner 1 U.S. Citizenship Status Code
                            ||RPAD(NVL(alter_rec.cs1_address_line_1_txt,' '),30,' ') -- Cosigner 1 Address (line 1)
                            ||RPAD(NVL(alter_rec.cs1_address_line_2_txt,' '),30,' ') --Cosigner 1 Address (line 2)
                            ||RPAD(NVL(alter_rec.cs1_city_txt,' '),24,' ') -- Cosigner 1 City
                            ||LPAD(' ',6,' ') -- Filler
                            ||LPAD(NVL(alter_rec.cs1_state_txt,' '),2,' ') -- Cosigner 1 State
                            ||LPAD(NVL(alter_rec.cs1_zip_txt,'0'),5,'0') -- Cosigner 1 Zip Code
                            ||LPAD(NVL(alter_rec.cs1_zip_suffix_txt,'0'),4,'0'); -- Cosigner 1 Zip Code Suffix

              IF (alter_rec.cs1_telephone_number_txt IS NOT NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_telephone_number_txt,' '),10,'0'); -- Cosigner 1 Telephone Number
              ELSIF (alter_rec.cs1_telephone_number_txt IS NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_telephone_number_txt,' '),10,' ');
              END IF;

              --Append cs1_signature_code_txt only if Y, if NULL or 'N' then append ' '
              IF (alter_rec.cs1_signature_code_txt IS NULL OR alter_rec.cs1_signature_code_txt = 'N') THEN
                l_at4Record  := l_at4Record||' '; -- Cosigner 1 Signature Code
              ELSIF (alter_rec.cs1_signature_code_txt = 'Y') THEN
                l_at4Record  := l_at4Record||alter_rec.cs1_signature_code_txt;
              END IF;

              l_at4Record := l_at4Record
                            ||RPAD(alter_rec.cs2_lname,35,' ')  --Cosigner2 Lname
                            ||RPAD(alter_rec.cs2_fname,12,' ')  --Cosigner2 Fname
                            ||NVL(alter_rec.cs2_mi_txt,' ') --Cosigner2 Mname
                            ||LPAD(NVL(alter_rec.cs2_ssn_txt,'0'),9,'0')   --Cosigner2 SSN sbould be 9 '0'
                            ||NVL(alter_rec.cs2_citizenship_status,' ') -- Cosigner 2 U.S. Citizenship Status Code
                            ||RPAD(NVL(alter_rec.cs2_address_line_1_txt,' '),30,' ')  -- Cosigner 2 Address (line 1)
                            ||RPAD(NVL(alter_rec.cs2_address_line_2_txt,' '),30,' ')  -- Cosigner 2 Address (line 2)
                            ||RPAD(NVL(alter_rec.cs2_city_txt,' '),24,' ') -- Cosigner 2 City
                            ||LPAD(' ',6,' ') -- Filler
                            ||LPAD(NVL(alter_rec.cs2_state_txt,' '),2,' ')  -- Cosigner 2 State
                            ||LPAD(NVL(alter_rec.cs2_zip_txt,'0'),5,'0')   -- Cosigner 2 Zip Code
                            ||LPAD(NVL(alter_rec.cs2_zip_suffix_txt,'0'),4,'0');  -- Cosigner 2 Zip Code Suffix

              IF (alter_rec.cs2_telephone_number_txt IS NOT NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_telephone_number_txt,' '),10,'0'); -- Cosigner 2 Telephone Number
              ELSIF (alter_rec.cs2_telephone_number_txt IS NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_telephone_number_txt,' '),10,' ');
              END IF;

              --Append cs2_signature_code_txt only if Y, if NULL or 'N' then append ' '
              IF (alter_rec.cs2_signature_code_txt IS NULL OR alter_rec.cs2_signature_code_txt = 'N') THEN
                l_at4Record  := l_at4Record||' '; -- Cosigner 2 Signature Code
              ELSIF (alter_rec.cs2_signature_code_txt = 'Y') THEN
                l_at4Record  := l_at4Record||alter_rec.cs2_signature_code_txt;
              END IF;

              l_at4Record := l_at4Record
                            ||LPAD(NVL(TO_CHAR(alter_rec.borw_gross_annual_sal),'0'),7,'0') -- Borrower Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.borw_other_income),'0'),7,'0') -- Borrower Other Income
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_gross_annual_sal_num),'0'),7,'0') -- Cosigner 1 Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_other_income_amt),'0'),7,'0') -- Cosigner 1 Other Income
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_gross_annual_sal_num),'0'),7,'0') -- Cosigner 2 Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_other_income_amt),'0'),7,'0') -- Cosigner 2 Other Income
                            ||LPAD(NVL(alter_rec.cs1_frgn_postal_code_txt,' '),14,' ') -- Cosigner 1 Foreign Postal Code
                            ||LPAD(NVL(alter_rec.cs2_frgn_postal_code_txt,' '),14,' ') -- Cosigner 2 Foreign Postal Code
                            ||LPAD(NVL(alter_rec.student_major,' '),15,' ') -- Student Major
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_birth_date,'YYYYMMDD'),'0') ,8,'0')  --Cosign 1 DOB
                            ||LPAD(NVL(alter_rec.cs1_drv_license_state_txt,' '),2,' ') -- Cosigner 1 Driver's License State
                            ||LPAD(NVL(alter_rec.cs1_drv_license_num_txt,' '),20,' ') -- Cosigner 1 Driver's License Number
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_birth_date,'YYYYMMDD'),'0') ,8,'0')  --Cosign 2 DOB
                            ||LPAD(NVL(alter_rec.cs2_drv_license_state_txt,' '),2,' ') -- Cosigner 2 Driver's License State
                            ||LPAD(NVL(alter_rec.cs2_drv_license_num_txt,' '),20,' ') -- Cosigner 2 Driver's License Number
                            ||LPAD(' ',20,' ') -- Filler
                            ||LPAD(' ',10,' ') -- Student Phone Number
                            ||LPAD(NVL(alter_rec.cs1_rel_to_student_flag,' '),1,' ') -- Cosigner 1 Relationship to Student
                            ||LPAD(' ',3,' ') -- Filler
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_years_at_address_txt),'0'),2,'0') -- Cosigner 1 Years at Address
                            ||LPAD(NVL(alter_rec.cs2_rel_to_student_flag,' '),1,' ') -- Cosigner 2 Relationship to Student
                            ||LPAD(' ',3,' ') -- Filler
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_years_at_address_txt),'0'),2,'0') -- Cosigner 2 Years at Address
                            ||NVL(alter_rec.int_rate_opt,' ') -- Interest Rate Option
                            ||NVL(alter_rec.repayment_opt_code,' ') -- Repayment Option Code
                            ||LPAD(NVL(alter_rec.cs1_frgn_tel_num_prefix_txt,' '),10,' ') -- Cosigner 1 Foreign Telephone Number Prefix
                            ||LPAD(NVL(alter_rec.cs2_frgn_tel_num_prefix_txt,' '),10,' '); -- Cosigner 2 Foreign Telephone Number Prefix

                            IF (alter_rec.stud_mth_housing_pymt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_housing_pymt),'0'),5,'0'); -- Student Monthly Housing Payment
                            ELSIF (alter_rec.stud_mth_housing_pymt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_housing_pymt),' '),5,' '); -- Student Monthly Housing Payment
                            END IF;

                            IF (alter_rec.stud_mth_crdtcard_pymt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_crdtcard_pymt),'0'),5,'0'); -- Student Monthly Credit Card Payment
                            ELSIF (alter_rec.stud_mth_crdtcard_pymt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_crdtcard_pymt),' '),5,' '); -- Student Monthly Credit Card Payment
                            END IF;

                            IF (alter_rec.stud_mth_auto_pymt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_auto_pymt),'0'),5,'0'); -- Student Monthly Auto Payment
                            ELSIF (alter_rec.stud_mth_auto_pymt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_auto_pymt),' '),5,' '); -- Student Monthly Auto Payment
                            END IF;

                            IF (alter_rec.stud_mth_ed_loan_pymt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_ed_loan_pymt),'0'),5,'0'); -- Student Monthly Educational Loan Payment
                            ELSIF (alter_rec.stud_mth_ed_loan_pymt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_ed_loan_pymt),' '),5,' '); -- Student Monthly Educational Loan Payment
                            END IF;

                            IF (alter_rec.stud_mth_other_pymt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_other_pymt),'0'),5,'0'); -- Student Monthly Other Payment
                            ELSIF (alter_rec.stud_mth_ed_loan_pymt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(TO_CHAR(alter_rec.stud_mth_other_pymt),' '),5,' '); -- Student Monthly Other Payment
                            END IF;

                            IF (alter_rec.cs1_mthl_housing_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_housing_pay_txt,'0'),5,'0'); -- Cosigner 1 Monthly Housing Payment
                            ELSIF (alter_rec.cs1_mthl_housing_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_housing_pay_txt,' '),5,' '); -- Cosigner 1 Monthly Housing Payment
                            END IF;

                            IF (alter_rec.cs1_mthl_cc_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_cc_pay_txt,'0'),5,'0');      -- Cosigner 1 Monthly Credit Card Payment
                            ELSIF (alter_rec.cs1_mthl_cc_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_cc_pay_txt,' '),5,' ');      -- Cosigner 1 Monthly Credit Card Payment
                            END IF;

                            IF (alter_rec.cs1_mthl_auto_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_auto_pay_txt,'0'),5,'0');    -- Cosigner 1 Monthly Auto Payment
                            ELSIF (alter_rec.cs1_mthl_auto_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_auto_pay_txt,' '),5,' ');    -- Cosigner 1 Monthly Auto Payment
                            END IF;

                            IF (alter_rec.cs1_mthl_edu_loan_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_edu_loan_pay_txt,'0'),5,'0'); -- Cosigner 1 Monthly Educational Loan Payment
                            ELSIF (alter_rec.cs1_mthl_edu_loan_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_edu_loan_pay_txt,' '),5,' '); -- Cosigner 1 Monthly Educational Loan Payment
                            END IF;

                            IF (alter_rec.cs1_mthl_other_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_other_pay_txt,'0'),5,'0');   -- Cosigner 1 Monthly Other Payment
                            ELSIF (alter_rec.cs1_mthl_other_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_mthl_other_pay_txt,' '),5,' ');   -- Cosigner 1 Monthly Other Payment
                            END IF;

                            IF (alter_rec.cs2_mthl_housing_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_housing_pay_txt,'0'),5,'0'); -- Cosigner 2 Monthly Housing Payment
                            ELSIF (alter_rec.cs2_mthl_housing_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_housing_pay_txt,' '),5,' '); -- Cosigner 2 Monthly Housing Payment
                            END IF;

                            IF (alter_rec.cs2_mthl_cc_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_cc_pay_txt,'0'),5,'0');      -- Cosigner 2 Monthly Credit Card Payment
                            ELSIF (alter_rec.cs2_mthl_cc_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_cc_pay_txt,' '),5,' ');      -- Cosigner 2 Monthly Credit Card Payment
                            END IF;

                            IF (alter_rec.cs2_mthl_auto_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_auto_pay_txt,'0'),5,'0');    -- Cosigner 2 Monthly Auto Payment
                            ELSIF (alter_rec.cs2_mthl_auto_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_auto_pay_txt,' '),5,' ');    -- Cosigner 2 Monthly Auto Payment
                            END IF;

                            IF (alter_rec.cs2_mthl_edu_loan_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_edu_loan_pay_txt,'0'),5,'0'); -- Cosigner 2 Monthly Educational Loan Payment
                            ELSIF (alter_rec.cs2_mthl_edu_loan_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_edu_loan_pay_txt,' '),5,' '); -- Cosigner 2 Monthly Educational Loan Payment
                            END IF;

                            IF (alter_rec.cs2_mthl_other_pay_txt IS NOT NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_other_pay_txt,'0'),5,'0');   -- Cosigner 2 Monthly Other Payment
                            ELSIF (alter_rec.cs2_mthl_other_pay_txt IS NULL) THEN
                              l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_mthl_other_pay_txt,' '),5,' ');   -- Cosigner 2 Monthly Other Payment
                            END IF;

                            l_at4Record  := l_at4Record||NVL(alter_rec.cs1_credit_auth_code_txt,' ') -- Cosigner 1 Credit Authorization Code
                                                       ||NVL(alter_rec.cs2_credit_auth_code_txt,' '); -- Cosigner 2 Credit Authorization Code;

                            --Append cs1_signature_code_txt only if Y, if NULL or 'N' then append ' '
                            IF (alter_rec.cs1_elect_sig_ind_code_txt IS NULL OR alter_rec.cs1_elect_sig_ind_code_txt = 'N') THEN
                              l_at4Record  := l_at4Record||' '; -- -- Cosigner 1 Electronic Signature Indicator Code
                            ELSIF (alter_rec.cs1_elect_sig_ind_code_txt = 'Y') THEN
                              l_at4Record  := l_at4Record||alter_rec.cs1_elect_sig_ind_code_txt;
                            END IF;


                            --Append cs2_signature_code_txt only if Y, if NULL or 'N' then append ' '
                            IF (alter_rec.cs2_elect_sig_ind_code_txt IS NULL OR alter_rec.cs2_elect_sig_ind_code_txt = 'N') THEN
                              l_at4Record  := l_at4Record||' '; -- -- Cosigner 2 Electronic Signature Indicator Code
                            ELSIF (alter_rec.cs2_elect_sig_ind_code_txt = 'Y') THEN
                              l_at4Record  := l_at4Record||alter_rec.cs2_elect_sig_ind_code_txt;
                            END IF;


               l_at4Record  := l_at4Record ||LPAD(' ',288,' ') --Filler
                                           ||'*';

               fnd_file.put_line(fnd_file.output,UPPER(l_at4Record));

            ELSIF lv_cl_version = 'RELEASE-4' THEN
              l_v_owner_code := 'NCLP03';
              l_at4Record := '@4' ||l_v_owner_code
                            ||LPAD(NVL(TO_CHAR(alter_rec.fed_stafford_loan_debt),'0'),5,'0') -- Federal Stafford Loan Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.fed_sls_debt),'0'),5,'0') -- Federal SLS Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.heal_debt),'0'),6,'0') -- HEAL Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.perkins_debt),'0'),5,'0') -- Perkins Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.other_debt),'0'),6,'0') -- Other Debt
                            ||LPAD(NVL(TO_CHAR(alter_rec.other_loan_amt),'0'),7,'0') -- Other Loans this Period
                            ||NVL(alter_rec.crdt_undr_difft_name,'N') -- Credit Under Different Name Code
                            ||RPAD(alter_rec.cs1_lname,35,' ')  -- Cosigner1 Lname
                            ||RPAD(alter_rec.cs1_fname,12,' ')  -- Cosigner1 Fname
                            ||NVL(alter_rec.cs1_mi_txt,' ') --Cosigner1 Mname
                            ||LPAD(NVL(alter_rec.cs1_ssn_txt,'0'),9,'0')   -- Cosigner 1 SSN
                            ||NVL(alter_rec.cs1_citizenship_status,' ') -- Cosigner 1 U.S. Citizenship Status Code
                            ||RPAD(NVL(alter_rec.cs1_address_line_1_txt,' '),30,' ') -- Cosigner 1 Address (line 1)
                            ||RPAD(NVL(alter_rec.cs1_address_line_2_txt,' '),30,' ') --Cosigner 1 Address (line 2)
                            ||RPAD(NVL(alter_rec.cs1_city_txt,' '),24,' ') -- Cosigner 1 City
                            ||LPAD(' ',6,' ') -- Filler
                            ||LPAD(NVL(alter_rec.cs1_state_txt,' '),2,' ') -- Cosigner 1 State
                            ||LPAD(NVL(alter_rec.cs1_zip_txt,'0'),5,'0') -- Cosigner 1 Zip Code
                            ||LPAD(NVL(alter_rec.cs1_zip_suffix_txt,'0'),4,'0'); -- Cosigner 1 Zip Code Suffix

              IF (alter_rec.cs1_telephone_number_txt IS NOT NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_telephone_number_txt,' '),10,'0'); -- Cosigner 1 Telephone Number
              ELSIF (alter_rec.cs1_telephone_number_txt IS NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs1_telephone_number_txt,' '),10,' ');
              END IF;


              --Append cs1_signature_code_txt only if Y, if NULL or 'N' then append ' '
              IF (alter_rec.cs1_signature_code_txt IS NULL OR alter_rec.cs1_signature_code_txt = 'N') THEN
                l_at4Record  := l_at4Record||' '; -- Cosigner 1 Signature Code
              ELSIF (alter_rec.cs1_signature_code_txt = 'Y') THEN
                l_at4Record  := l_at4Record||alter_rec.cs1_signature_code_txt;
              END IF;

              l_at4Record := l_at4Record
                            ||RPAD(alter_rec.cs2_lname,35,' ')  --Cosigner2 Lname
                            ||RPAD(alter_rec.cs2_fname,12,' ')  --Cosigner2 Fname
                            ||NVL(alter_rec.cs2_mi_txt,' ') --Cosigner2 Mname
                            ||LPAD(NVL(alter_rec.cs2_ssn_txt,'0'),9,'0')   --Cosigner2 SSN sbould be 9 '0'
                            ||NVL(alter_rec.cs2_citizenship_status,' ') -- Cosigner 2 U.S. Citizenship Status Code
                            ||RPAD(NVL(alter_rec.cs2_address_line_1_txt,' '),30,' ')  -- Cosigner 2 Address (line 1)
                            ||RPAD(NVL(alter_rec.cs2_address_line_2_txt,' '),30,' ')  -- Cosigner 2 Address (line 2)
                            ||RPAD(NVL(alter_rec.cs2_city_txt,' '),24,' ') -- Cosigner 2 City
                            ||LPAD(' ',6,' ') -- Filler
                            ||LPAD(NVL(alter_rec.cs2_state_txt,' '),2,' ')  -- Cosigner 2 State
                            ||LPAD(NVL(alter_rec.cs2_zip_txt,'0'),5,'0')   -- Cosigner 2 Zip Code
                            ||LPAD(NVL(alter_rec.cs2_zip_suffix_txt,'0'),4,'0');  -- Cosigner 2 Zip Code Suffix

              IF (alter_rec.cs2_telephone_number_txt IS NOT NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_telephone_number_txt,' '),10,'0'); -- Cosigner 2 Telephone Number
              ELSIF (alter_rec.cs2_telephone_number_txt IS NULL) THEN
                l_at4Record  := l_at4Record||LPAD(NVL(alter_rec.cs2_telephone_number_txt,' '),10,' ');
              END IF;


              --Append cs2_signature_code_txt only if Y, if NULL or 'N' then append ' '
              IF (alter_rec.cs2_signature_code_txt IS NULL OR alter_rec.cs2_signature_code_txt = 'N') THEN
                l_at4Record  := l_at4Record||' '; -- Cosigner 2 Signature Code
              ELSIF (alter_rec.cs2_signature_code_txt = 'Y') THEN
                l_at4Record  := l_at4Record||alter_rec.cs2_signature_code_txt;
              END IF;



              l_at4Record := l_at4Record
                            ||LPAD(NVL(TO_CHAR(alter_rec.borw_gross_annual_sal),'0'),7,'0') -- Borrower Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.borw_other_income),'0'),7,'0') -- Borrower Other Income
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_gross_annual_sal_num),'0'),7,'0') -- Cosigner 1 Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_other_income_amt),'0'),7,'0') -- Cosigner 1 Other Income
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_gross_annual_sal_num),'0'),7,'0') -- Cosigner 2 Gross Annual Salary
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_other_income_amt),'0'),7,'0') -- Cosigner 2 Other Income
                            ||LPAD(NVL(alter_rec.cs1_frgn_postal_code_txt,' '),14,' ') -- Cosigner 1 Foreign Postal Code
                            ||LPAD(NVL(alter_rec.cs2_frgn_postal_code_txt,' '),14,' ') -- Cosigner 2 Foreign Postal Code
                            ||RPAD(NVL(alter_rec.student_major,' '),15,' ');-- Student Major



              l_at4Record := l_at4Record
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_birth_date,'YYYYMMDD'),'0') ,8,'0')  --Cosign 1 DOB
                            ||LPAD(NVL(alter_rec.cs1_drv_license_state_txt,' '),2,' ') -- Cosigner 1 Driver's License State
                            ||RPAD(NVL(alter_rec.cs1_drv_license_num_txt,' '),20,' ') -- Cosigner 1 Driver's License Number
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_birth_date,'YYYYMMDD'),'0') ,8,'0')  --Cosign 2 DOB
                            ||LPAD(NVL(alter_rec.cs2_drv_license_state_txt,' '),2,' ') -- Cosigner 2 Driver's License State
                            ||RPAD(NVL(alter_rec.cs2_drv_license_num_txt,' '),20,' ') -- Cosigner 2 Driver's License Number
                            ||LPAD(' ',20,' ') -- Filler
                            ||LPAD(' ',10,' '); -- Student Phone Number

              l_at4Record := l_at4Record
                            ||LPAD(NVL(alter_rec.cs1_rel_to_student_flag,' '),1,' ') -- Cosigner 1 Relationship to Student
                            ||LPAD(NVL(alter_rec.cs1_suffix_txt ,' '),3,' ') -- Cosigner 1 Suffix
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs1_years_at_address_txt),'0'),2,'0') -- Cosigner 1 Years at Address
                            ||LPAD(NVL(alter_rec.cs2_rel_to_student_flag,' '),1,' ') -- Cosigner 2 Relationship to Student
                            ||LPAD(NVL(alter_rec.cs2_suffix_txt ,' '),3,' ') -- Cosigner 2 Suffix
                            ||LPAD(NVL(TO_CHAR(alter_rec.cs2_years_at_address_txt),'0'),2,'0') -- Cosigner 2 Years at Address
                            ||NVL(alter_rec.int_rate_opt,' ') -- Interest Rate Option
                            ||NVL(alter_rec.repayment_opt_code,' ') -- Repayment Option Code
                            ||LPAD(' ',307,' ')  -- Filler
                            ||'*';

               fnd_file.put_line(fnd_file.output,UPPER (l_at4Record));
            END IF;

                -- Count the @4 Records being sent.
                l_count_4 := l_count_4 +1;

             END IF;


             -- If Number of Disbursements are more than 4, then need to send the remaining
             -- disbursement details in the @8 Send record.
             -- masehgal    2477912   Made record "upper" to resolve NCAT reported errors

             IF lv_counter > 4 THEN
                fnd_file.put_line(fnd_file.output,UPPER ( '@8NCLP05'
                                                          ||RPAD(lv_8_final_disb_date,128,'0')
                                                          ||RPAD(lv_8_final_hold_rel_ind,16,' ')
                                                          ||RPAD(NVL(lv_8_final_gross_amt,'0'),80,'0')
                                                          ||RPAD(lv_8_direct_to_borr_flag,16,' ')
 	                                                  ||RPAD(' ',711,' ')
                                                          ||'*'));
                -- Increment the counter for the Number of @8 records in this file
                lv_8_disb_count := lv_8_disb_count + 1;
             END IF;

             -- Corresponding Loan Id in IGF_SL_LOR_LOC table should be deleted
             DECLARE
             lv_row_id  ROWID;
               CURSOR c_tbh_cur IS
                SELECT row_id row_id
                  FROM   igf_sl_lor_loc
                  WHERE  loan_id = loan_rec.loan_id FOR UPDATE OF loan_status NOWAIT;
                 BEGIN
                 FOR tbh_rec in c_tbh_cur LOOP
                         igf_sl_lor_loc_pkg.delete_row (tbh_rec.row_id);
                 END LOOP;
             END;

             -- Insert the same loan record into IGF_SL_LOR_LOC to keep track of Data Sent to External Processor

             insert_lor_loc_rec (
               p_v_school_id          => p_school_id ,
               p_n_coa                => l_coa,
               p_n_efc                => l_efc,
               p_n_est_fin            => l_est_fin,
               p_c_alt_borr_ind_flag  => l_borw_ind_code
             );

             -- Corresponding Award_id should be Deleted from IGF_SL_AWD_DISB_LOC
             DECLARE
              lv_row_id  ROWID;
                CURSOR c_tbh_cur IS
                   SELECT row_id row_id
                   FROM   igf_sl_awd_disb_loc
                   WHERE  award_id = loan_rec.award_id;
             BEGIN
                FOR tbh_rec in c_tbh_cur LOOP
                    igf_sl_awd_disb_loc_pkg.delete_row (tbh_rec.row_id);
                END LOOP;
             END;


            -- Insert the Disbursement Data into IGF_SL_AWD_DISB_LOC
           DECLARE
               lv_row_id  ROWID;
               CURSOR c_tbh_cur IS
                  SELECT *
                  FROM   igf_aw_awd_disb
                  WHERE  award_id = loan_rec.award_id;
           BEGIN
             FOR tbh_rec IN c_tbh_cur LOOP
               lv_row_id  := NULL;

               IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Calling igf_sl_awd_disb_loc_pkg.insert_row');
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.award_id            ' || tbh_rec.award_id           );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.disb_num	      ' || tbh_rec.disb_num           );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.disb_accepted_amt   ' || tbh_rec.disb_accepted_amt  );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.fee_1		      ' || tbh_rec.fee_1              );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.fee_2		      ' || tbh_rec.fee_2              );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.disb_net_amt	      ' || tbh_rec.disb_net_amt       );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.disb_date	      ' || tbh_rec.disb_date          );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.hold_rel_ind	      ' || tbh_rec.hold_rel_ind       );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.fee_paid_1	      ' || tbh_rec.fee_paid_1         );
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', ' tbh_rec.fee_paid_2	      ' || tbh_rec.fee_paid_2         );
               END IF;

               igf_sl_awd_disb_loc_pkg.insert_row (
                 x_Mode                              => 'R',
                 x_rowid                             => lv_row_id,
                 x_award_id                          => tbh_rec.award_id,
                 x_disb_num                          => tbh_rec.disb_num,
                 x_disb_gross_amt                    => tbh_rec.disb_accepted_amt,
                 x_fee_1                             => tbh_rec.fee_1,
                 x_fee_2                             => tbh_rec.fee_2,
                 x_disb_net_amt                      => tbh_rec.disb_net_amt,
                 x_disb_date                         => tbh_rec.disb_date,
                 x_hold_rel_ind                      => tbh_rec.hold_rel_ind,
                 x_fee_paid_1                        => tbh_rec.fee_paid_1,
                 x_fee_paid_2                        => tbh_rec.fee_paid_2
               );
             END LOOP;
           END;

           IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'igf_sl_awd_disb_loc_pkg.insert_row succeeded');
           END IF;


      -- Update the Loan Status to Sent and Loan Status Date to SYSDATE
      DECLARE
          lv_row_id  ROWID;
       CURSOR c_tbh_cur  IS
           SELECT igf_sl_loans.*
           FROM   igf_sl_loans
           WHERE  loan_id = loan_rec.loan_id FOR UPDATE OF igf_sl_loans.loan_status NOWAIT;
      BEGIN
         FOR tbh_rec in c_tbh_cur LOOP

               -- Modified the Update Row call of the IGF_SL_LOANS_PKG, as part of Refunds DLD 2144600 for Borrower
               -- determination

                IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'Calling igf_sl_loans_pkg.update_row');
                END IF;

                igf_sl_loans_pkg.update_row (
                     x_Mode                              => 'R',
                     x_rowid                             => tbh_rec.row_id,
                     x_loan_id                           => tbh_rec.loan_id,
                     x_award_id                          => tbh_rec.award_id,
                     x_seq_num                           => tbh_rec.seq_num,
                     x_loan_number                       => tbh_rec.loan_number,
                     x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
                     x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
                     x_loan_status                       => 'S',
                     x_loan_status_date                  => TRUNC(SYSDATE),
                     x_loan_chg_status                   => tbh_rec.loan_chg_status,
                     x_loan_chg_status_date              => tbh_rec.loan_chg_status_date,
                     x_active                            => tbh_rec.active,
                     x_active_date                       => tbh_rec.active_date,
                     x_borw_detrm_code                   => tbh_rec.borw_detrm_code,
                     x_legacy_record_flag                => NULL,
                     x_external_loan_id_txt              => tbh_rec.external_loan_id_txt
                     );
                IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug', 'igf_sl_loans_pkg.update_row succeeded');
                END IF;

           END LOOP;
      END;

      -- Update the Origination Batch Id with Computed Batch Id and Origination Batch Date to SYSDATE

      Update_orig_batch_id(loan_rec.origination_id, lv_batch_id);

     EXCEPTION
     WHEN SKIP_RECORD THEN
          fnd_message.set_name('IGF','IGF_SL_SKIPPING');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);
     END;
END LOOP;


   -- Creating the Trailer Record for the Set of Records Fetched and Sent To File

   lv_trailer_rec := NULL;
   -- masehgal    2477912   Made record "upper" to resolve NCAT reported errors
  IF lv_cl_version = 'RELEASE-5' THEN
   lv_trailer_rec := UPPER('@T'
                           ||LPAD(TO_CHAR(NVL(lv_trans_count,0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_send2_rec_cnt,0)),6,'0')
                           ||l_v_trailer_date
                           ||l_v_trailer_time
                           ||RPAD(lv_file_ident_code,5)
                           ||RPAD(NVL(lv_source_name,' '),32,' ')
                           ||RPAD(NVL(p_school_id,' '),8,' ')
                           ||'  '
                           ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                           ||RPAD(NVL(recip_desc_rec.recip_description,' '),32,' ')
                           ||RPAD(NVL(recip_desc_rec.recipient_id,' '),8,' ')
                           ||'  '
                           ||RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),4,' ')
                           ||LPAD(NVL(l_count_4,0),6,0)
                           ||LPAD(TO_CHAR(NVL(l_n_send5_rec_cnt,0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_send7_rec_cnt,0)),6,'0')
                           ||LPAD(' ',9,' ')
                           ||LPAD(' ',9,' ')     --As per Prev Code we were sending the School DUNS ID,but CL Ref doc says it should be spaces
                           ||LPAD(TO_CHAR(lv_8_disb_count),6,'0')
                           ||LPAD(' ',792,' ')
                           ||'*');
  ELSIF lv_cl_version = 'RELEASE-4' THEN
   lv_trailer_rec := UPPER('@T'
                           ||LPAD(TO_CHAR(NVL(lv_trans_count,0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_send2_rec_cnt,0)),6,'0')
                           ||l_v_trailer_date
                           ||l_v_trailer_time
                           ||RPAD(lv_file_ident_code,5)
                           ||RPAD(NVL(lv_source_name,' '),32,' ')
                           ||RPAD(NVL(p_school_id,' '),8,' ')
                           ||'  '
                           ||RPAD(NVL(sch_non_ed_branch,' '),4,' ')
                           ||RPAD(NVL(recip_desc_rec.recip_description,' '),32,' ')
                           ||RPAD(NVL(recip_desc_rec.recipient_id,' '),8,' ')
                           ||'  '
                           ||RPAD(NVL(recip_desc_rec.recip_non_ed_brc_id,' '),4,' ')
                           ||LPAD(NVL(l_count_4,0),6,0)
                           ||LPAD(TO_CHAR(NVL(l_n_send5_rec_cnt,0)),6,'0')
                           ||LPAD(TO_CHAR(NVL(l_n_send7_rec_cnt,0)),6,'0')
                           ||LPAD(' ',9,' ')
                           ||LPAD(' ',9,' ')
                           ||LPAD(' ',718,' ')
                           ||'*');
  END IF;
   fnd_file.put_line(fnd_file.output,UPPER(lv_trailer_rec));

   COMMIT;

EXCEPTION
WHEN app_exception.record_lock_exception THEN
      ROLLBACK;
      retcode := 2;
      errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
      IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_orig.sub_cl_originate.exception','Record Lock Exception');
      END IF;

      igs_ge_msg_stack.conc_exception_hndl;

WHEN no_loan_data THEN
      -- This will happen when either there were no loan records to originate
      -- OR all records which were valid and ready to Send, were not Valid.

      retcode := 2;
      errbuf  := fnd_message.get_string('IGF','IGF_SL_NO_LOAN_ORIG_DATA');
      fnd_file.put_line(fnd_file.log, '');
      fnd_file.put_line(fnd_file.log, errbuf);
      IF(fnd_log.level_statement >= g_debug_runtime_level)THEN
        fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.debug','No loan origination data found');
      END IF;
      errbuf  := NULL;

WHEN OTHERS THEN
       ROLLBACK;
       retcode := 2;
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_SL_CL_ORIG.SUB_CL_ORIGINATE');
       IF(fnd_log.level_exception >= g_debug_runtime_level)THEN
         fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_sl_cl_orig.sub_cl_originate.exception', SQLERRM );
       END IF;
       errbuf := fnd_message.get;

       igs_ge_msg_stack.conc_exception_hndl;
END sub_cl_originate;


END igf_sl_cl_orig;

/
