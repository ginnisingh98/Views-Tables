--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_VALIDATION" AS
/* $Header: IGFSL07B.pls 120.10 2006/08/08 06:27:07 akomurav ship $ */

/*
--
-----------------------------------------------------------------------------------
--  Who        When           What
----------------------------------------------------------------------------------
  rajagupt    02-Mar-2006     FA 161 - Bug # 5006587 - CL4 Addendum
                              Two new columns (borrower alien reg number and e-signature source type code) +
                              Validations based on fed appl form code
  museshad    05-Oct-2005     Bug 4116399.
                              Added Stafford loan limit validation
  bvisvana    12-Sep-2005     SBCC Bug # 4575843 -  Check for requested loan amount. It should be in whole number.
  museshad    11-Aug-2005     Bug 4103922.
                              Disbursement Hold/Release indicator validation was
                              incorrect. Fixed this.
  mnade       10-Jan-2005     Bug - 4103342
                              Validate the Requested Amount and Accepted Amount.
  smadathi    29-oct-2004     Bug 3416936. Added new business logic as part of
                              CL4 changes
  brajendr    12-Oct-2004     FA138 ISIR Enhacements
                              Modified the reference of payment_isir_id

-- veramach     04-May-2004     bug 3603289
--                              Modified cursor cur_student_licence to select
--                              dependency_status from ISIR. other details are
--                              derived from igf_sl_gen.get_person_details.
-----------------------------------------------------------------------------------
--  ugummall   29-OCT-2003    Bug 3102439. FA 126 - Multiple FA Offices.
--                            1. Added two new parameters p_school_id and p_base_id to cl_lar_validate function.
--                            2. Changed the cursor cur_lor_details_recs to select only those records related to
--                               School ID(OPE ID) and Base ID if they are not null.
--                               Otherwise(if they are null) select all.
--                            3. Changed the cursor cur_school_id to fetch only one attribute eft_authorization.
--                            4. p_school_id is used instead of lv_school_id(fetched from cur_school_id)
--  veramach   19-SEP-2003    FA 122 Loan Enhancements Build
--                            1. changed cursor cur_lor_details_recs not to select student/borrower information.
--                               This is derived from igf_sl_gen.get_person_details
----------------------------------------------------------------------------------
--  gmuralid   03-07-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
--                           Added legacy record flag as parameter to
--                           igf_sl_loans_pkg
-----------------------------------------------------------------------------------
--  sjadhav    26-Mar-2003    Bug 2863960
--                            Modified cursor cur_count_disb_amount to replace
--                            disb gross amount with disb accepted amount
-----------------------------------------------------------------------------------
--  masehgal   08-Jan-2003    # 2593215  Removed redundant calls to
--                            begin/end date fetching functions of SL11B.
-----------------------------------------------------------------------------------
*/
-- Bug 2415041, sjadhav
-- Following fields are deemed as optional henceforth
--
-- S_PERMT_ADDR2
-- P_PERMT_ADDR2
-- S_MIDDLE_NAME
-- P_MIDDLE_NAME
-- S_PERMT_PHONE
-- P_PERMT_PHONE
--
-- set_complete_status for these fields is taken out
-- fill in spaces for addr2/middle initial/
-- phone number is take care of in igfsl12bpls package
-- all these fields if null are filled with spaces
-- while sending origination record [ see igfsl08bpls ]
--
--
-----------------------------------------------------------------------------------
--
--   Created By          :    mesriniv
--   Date Created By     :    2000/11/17
--   Purpose        :    To validate the Commom Line Loans
--                       from Loans Origination and set the
--                       Loan Status accordingly
--   Known Limitations,Enhancements or Remarks
--
-----------------------------------------------------------------------------------
--
 p_cl_version     VARCHAR2(30);
 g_loan_id        igf_sl_Loans_all.loan_id%TYPE;
 g_debug_runtime_level     NUMBER;
 g_update_mode_required    BOOLEAN  := FALSE;

PROCEDURE log_to_fnd ( p_v_module       IN VARCHAR2,
                       p_v_log_category IN VARCHAR2,
                       p_v_string       IN VARCHAR2 ) AS
------------------------------------------------------------------
--Created by  : bvisvana, Oracle IDC
--Date created: 10 Apr 2005
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
BEGIN
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_sl_cl_validation.'||p_v_module||'.'||p_v_log_category, p_v_string);
  END IF;
END log_to_fnd;

 FUNCTION  check_for_reqd(
 p_loan_number      igf_sl_loans.loan_number%TYPE,
 p_loan_catg        igf_sl_reqd_fields.loan_type%TYPE,
 p_field_name       igf_sl_reqd_fields.field_name%TYPE,
 p_field_value      VARCHAR2,
 p_prc_type_code    igf_sl_reqd_fields.prc_type_code%TYPE
 ) RETURN BOOLEAN
 AS

 /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    To Check if the Column value is NULL and then insert a record
                    into the Edit Report Table specifying that the Column Value
                    is Recommended or Strongly Recommended.
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
 ***************************************************************/
  lv_complete    BOOLEAN := TRUE;
  lv_err_type    fnd_lookups.lookup_type%TYPE;
  lv_data_reqd   fnd_lookups.lookup_code%TYPE;
  lv_data_recomm fnd_lookups.lookup_code%TYPE;

  -- Value of Spec Version in Table is same as Loan Type sent as Parameter

  CURSOR cur_reqd IS
  SELECT DISTINCT status from igf_sl_reqd_fields lrf
  WHERE  lrf.loan_type    = p_loan_catg
  AND    lrf.field_name   = p_field_name
  AND    lrf.spec_version = p_cl_version
--  AND    lrf.transaction_type = '@1'
  AND    lrf.transaction_type IN ('@1','@4') -- To Include @4 Record for borrower and Cosigner details
  AND    lrf.prc_type_code  = p_prc_type_code;

BEGIN

  lv_err_type    :=  'IGF_SL_ERR_CODES';
  lv_data_reqd   :=  'DATA_REQD';
  lv_data_recomm :=  'DATA_RECOMM';

  IF p_field_value IS NULL THEN
   FOR irec in cur_reqd LOOP
     IF irec.status = 'R' THEN
        -- If the Data is required.
        lv_complete := FALSE;
        igf_sl_edit.insert_edit(p_loan_number, 'V', lv_err_type, lv_data_reqd, p_field_name, p_field_value);
        log_to_fnd('check_for_reqd','debug','irec.status:R');
     ELSIF irec.status = 'S' THEN
        -- If the Data is strongly recommended.
        igf_sl_edit.insert_edit(p_loan_number, 'V', lv_err_type, lv_data_recomm, p_field_name, p_field_value);
        log_to_fnd('check_for_reqd','debug','irec.status:S');
     END IF;
   END LOOP;
  END IF;
  RETURN lv_complete;

EXCEPTION
WHEN OTHERS THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_VALIDATION.CHECK_FOR_REQD');
   fnd_file.put_line(fnd_file.log,SQLERRM);
   igs_ge_msg_stack.add;
   IF (fnd_log.level_exception >= g_debug_runtime_level) THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_validation.check_for_reqd.exception', 'Unhandled excepion in check_for_reqd');
   END IF;
   app_exception.raise_exception;

END check_for_reqd;


FUNCTION cl_lar_validate(
  p_ci_cal_type                   IN              igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
  p_ci_sequence_number            IN              igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
  p_loan_number                   IN              igf_sl_loans_all.loan_number%TYPE,
  p_loan_catg                     IN              igf_lookups_view.lookup_code%TYPE,
  p_call_mode                     IN              VARCHAR2,
  p_school_id                     IN              VARCHAR2,
  p_base_id                       IN              VARCHAR2
  )
RETURN BOOLEAN
AS
 /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/17
   Purpose          :    To Validate the Common Line Loans.
   Known Limitations,Enhancements or Remarks

   Change History   :
   FA 122 Loan Enhancements Build
   changed cursor cur_lor_details_recs not to select student/borrower information.
   This is derived from igf_sl_gen.get_person_details

   Bug  No: 2400487 Desc : FFELP Validation and Origination Issues.
   Who       When        What
   rajagupt  10-Apr-2006 Bug 5006587 . Removed validations (set_complete_status()) for the following field names
                         For PLUS -> S_DEFAULT_STATUS,BORW_INTEREST_IND,P_STATE_OF_LEGAL_RES,S_SIGNATURE_CODE,BORW_OUTSTD_LOAN_CODE
   museshad  05-Oct-2005 Bug 4116399.
                         Added Stafford loan limit validation.
   bvisvana  25-Aug-2005 Bug 4127532. Removed the Validation of checking default status of borrower and student.
                         For ALT loans, the loan should be sent irrespective of the default status of the borrower or the student.
   museshad  11-Aug-2005 Bug 4103922.
                         Disbursement Hold/Release indicator validation was incorrect.
                         The variable 'ln_disb_amt_count' was used in the place of
                         'ln_disb_ind_count'. Corrected this.
   smadathi  29-oct-2004 Bug 3416936. Added new business logic as part of
                         CL4 changes
   ridas     17-SEP-04   Bug #3691137: Query optimized by using the table igf_sl_cl_recipient
                         instead of the view igf_sl_cl_recipient_v

   bkkumar   10-apr-04   FACR116 - Added the validation for ALT_LOAN_CODE
   mesriniv  8-jun-2002  Commented Check for P_SIGNATURE_CODE for CL_STAFFORD
                         Commented Check for LOAN_SEQ_NUMBER for all types of Loans
                         Added Check for S_SIGNATURE_CODE for CL_STAFFORD.

    Bug Id : 1769051 -   Developement for Nov 2001 release
    Who             When      What
    avenkatr             09-MAY-2001     1. Added validations for 'Alternate' Loans

    Bug Id         : 1720677 Desc : Mapping of school id in the CommonLine Setup
                               to ope_id of  FinancialAid Office Setup.
    Who              When      What
    mesriniv         05-APR-2001    Changed the occurrences of field fao_id
                         to ope_id
 ***************************************************************/

    lv_loan_status           igf_sl_loans_all.loan_status%TYPE;
    lv_s_citizenship_status  igf_ap_isir_matched.citizenship_status%TYPE;
    lv_s_license_number      igf_ap_isir_matched.driver_license_number%TYPE;
    lv_s_license_state       igf_ap_isir_matched.driver_license_state%TYPE;
    lv_dependency_status     igf_ap_isir_matched.dependency_status%TYPE;
    ln_disb_amt_count        NUMBER(2);
    ln_disb_ind_count        NUMBER(2);
    ln_disb_dates_count      NUMBER(2);
    l_phone                  VARCHAR2(100);

    student_dtl_rec igf_sl_gen.person_dtl_rec;
    student_dtl_cur igf_sl_gen.person_dtl_cur;

    parent_dtl_rec igf_sl_gen.person_dtl_rec;
    parent_dtl_cur igf_sl_gen.person_dtl_cur;

    l_n_coa                 igf_ap_fa_base_rec_all.coa_f%TYPE;
    l_n_efc                 igf_ap_fa_base_rec_all.efc_f%TYPE;
    l_n_pell_efc            NUMBER;
    l_n_efc_f               NUMBER;
    lvc_check_loan          VARCHAR2(3);
    lv_complete             BOOLEAN := TRUE;
    lv_msg_name             fnd_new_messages.message_name%TYPE;
    lv_lookup_code          igf_lookups_view.LOOKUP_CODE%TYPE;
    lv_warning              BOOLEAN := FALSE;
    p_fed_fund_1             igf_aw_fund_cat.fed_fund_code%TYPE;
    p_fed_fund_2             igf_aw_fund_cat.fed_fund_code%TYPE;
    p_status_1               igf_sl_loans.loan_status%TYPE;
    p_status_2               igf_sl_loans.loan_status%TYPE;
    p_status_3               igf_sl_loans.loan_status%TYPE;
    p_cal_type               igf_ap_fa_base_rec.ci_cal_type%TYPE;
    p_seq_number             igf_ap_fa_base_rec.ci_sequence_number%TYPE;

    -- Query optimized by using the table igf_sl_cl_recipient instead of the view igf_sl_cl_recipient_v (bug #3691137)

    -- masehgal  # 2593215  there was a call to begin/end date fetching functions of SL11B.
    -- However, these are not getting used anywhere .. therefore removing them ...

    -- Take data from LOR View satisfying the Input Parameters
    -- If p_call_mode = "JOB", then records with Loan Status with Ready To Send ('G')
    -- ELSE, if "FORM", then we need to validate for "Ready to Send", "Not Ready", "Rejected"


    CURSOR cur_lor_details_recs(
                                p_fed_fund_1 igf_aw_fund_cat.fed_fund_code%TYPE,
                                p_fed_fund_2 igf_aw_fund_cat.fed_fund_code%TYPE,
                                p_status_1   igf_sl_loans.loan_status%TYPE,
                                p_status_2   igf_sl_loans.loan_status%TYPE,
                                p_status_3   igf_sl_loans.loan_status%TYPE,
                                p_cal_type   igf_ap_fa_base_rec.ci_cal_type%TYPE,
                                p_seq_number igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                                p_active     igf_sl_loans.active%TYPE,
                                p_school_id  VARCHAR2,
                                p_base_id    VARCHAR2
                               )IS
    SELECT loans.row_id,
           loans.loan_id,
           loans.loan_number,
           loans.award_id,
           awd.accepted_amt loan_amt_accepted,
           lor.requested_loan_amt,
           loans.loan_per_begin_date,
           loans.loan_per_end_date,
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
           lor.relationship_cd,
           lor.eft_authorization_code,
           lor.b_alien_reg_num_txt, -- FA 161 - Bug # 5006583
           lor.deferment_request_code,
           lor.loan_app_form_code,
           recip.lender_id,
           recip.guarantor_id,
           recip.lend_non_ed_brc_id,
           recip.lender_id borw_lender_id,
           fabase.base_id,
           fabase.person_id student_id,
           awd.accepted_amt,
           fcat.fed_fund_code,
           fcat.alt_loan_code,
           TRUNC(fabase.coa_f) coa_f,
           loans.external_loan_id_txt
    FROM   igf_sl_loans          loans,
           igf_sl_lor            lor,
           igf_aw_award          awd,
           igf_aw_fund_mast      fmast,
           igf_aw_fund_cat       fcat,
           igf_ap_fa_base_rec    fabase,
           igf_sl_cl_recipient   recip
    WHERE  fabase.ci_cal_type        = p_cal_type
    AND    fabase.ci_sequence_number = p_seq_number
    AND    fabase.base_id            = awd.base_id
    AND    fabase.base_id            = NVL(p_base_id, fabase.base_id)
    AND    awd.fund_id               = fmast.fund_id
    AND    fmast.fund_code           = fcat.fund_code
    AND    (fcat.fed_fund_code       = p_fed_fund_1 OR  fcat.fed_fund_code =  p_fed_fund_2)
    AND    loans.award_id            = awd.award_id
    AND    loans.loan_number         = NVL(p_loan_number,loans.loan_number)
    AND    loans.loan_id             = lor.loan_id
    AND    (loans.loan_status        = p_status_1 OR loans.loan_status =  p_status_2 OR loans.loan_status = p_status_3)
    AND    loans.active              = p_active
    AND    lor.relationship_cd       = recip.relationship_cd
    AND    substr(loans.loan_number, 1, 6) = NVL(substr(p_school_id, 1, 6), substr(loans.loan_number, 1, 6));


    lor_rec_temp             cur_lor_details_recs%ROWTYPE;
    -- Cursor to fetch Student License No.,State and Citizenship Status

    CURSOR cur_isir_depend_status  IS
       SELECT isir.dependency_status
       FROM   igf_ap_isir_matched isir
       WHERE  isir.payment_isir = 'Y'
       AND    isir.system_record_type = 'ORIGINAL'
       AND    isir.base_id=lor_rec_temp.base_id;

    -- Cursor to find whether any of the disbursment amounts is zero or less than zero

    CURSOR cur_count_disb_amount
       IS
       SELECT COUNT(award_id)
       FROM   igf_aw_awd_disb awdb
       WHERE  award_id              = lor_rec_temp.award_id
       AND    disb_accepted_amt    <= 0;

    -- Cursor to find whether any of the disbursment indicators is NULL

    CURSOR cur_count_disb_ind  IS
       SELECT COUNT(award_id)
       FROM   igf_aw_awd_disb awdb
       WHERE  award_id=lor_rec_temp.award_id
       AND    hold_rel_ind IS NULL;

    -- Cursor to find whether any of the disbursment dates is NULL

    CURSOR cur_count_disb_dates  IS
       SELECT COUNT(award_id)
       FROM   igf_aw_awd_disb awdb
       WHERE  award_id=lor_rec_temp.award_id
       AND    disb_date IS NULL;


    -- Cursor to fetch the School Id and Non Ed Branch Id for CL Loan
    -- FA 126 - Multiple FA Offices.
      -- This cursor is modified to fetch only one attribute eft_authorization.
      -- School Id is now available as passed in parameter p_school_id.
      -- Non Ed Branch is not used.

    CURSOR c_nof_awd_disb (cp_n_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT COUNT(awd.disb_num) tot_disb
    FROM   igf_aw_awd_disb_all awd
    WHERE  awd.award_id = cp_n_award_id
    GROUP BY awd.award_id
    HAVING COUNT(awd.disb_num) > 4;

    -- FA 161 - Bug # 5006583
    CURSOR citizenship_dtl_cur (cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE) IS
    SELECT
           pct.restatus_code
    FROM   igs_pe_eit_restatus_v  pct
    WHERE  pct.person_id    = cp_person_id AND
           SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);
    citizenship_dtl_rec citizenship_dtl_cur%ROWTYPE;

    CURSOR cur_fa_mapping ( cp_citizenship_status igf_sl_pe_citi_map.pe_citi_stat_code%TYPE,
                            cp_cal_type igf_sl_pe_citi_map.ci_cal_type%TYPE,
                            cp_sequence_number igf_sl_pe_citi_map.ci_sequence_number%TYPE) IS
    SELECT trim(fa_citi_stat_code) fa_citi_stat_code FROM igf_sl_pe_citi_map
      WHERE pe_citi_stat_code  = cp_citizenship_status
        AND ci_sequence_number = cp_sequence_number
        AND ci_cal_type = cp_cal_type;
    cur_fa_mapping_rec cur_fa_mapping%ROWTYPE;

    l_n_disb_cnt  NUMBER;


    -- Procedure to Set the Status of Record
    PROCEDURE set_complete_status(p_complete BOOLEAN)
    AS
    /***************************************************************
       Created By        :    mesriniv
       Date Created By   :    2000/11/17
       Purpose      :    To Set the Completeness of Record
       Known Limitations,Enhancements or Remarks
       Change History    :
       Who               When      What
       agairola                 15-Mar-2002     Modified the IGF_SL_LOANS_PKG update row call
                                                as part of Refunds DLD

       museshad         05-May-2005             Bug# 4346258
                                                Added the parameter 'base_id' in the call to the
                                                function get_cl_version(). The signature of
                                                this function has been changed so that it takes
                                                into account any overriding CL version for a
                                                specific Organization Unit in FFELP Setup override.
     ***************************************************************/
    BEGIN
        IF p_complete = FALSE THEN
          lv_complete := FALSE;
          log_to_fnd('set_complete_status','debug','status=FALSE');
        END IF;
    END set_complete_status;

	  FUNCTION unmetneed(
 	                      p_base_id IN NUMBER
 	                    ) RETURN NUMBER AS
 	  ------------------------------------------------------------------
 	  --Created by  : veramach, Oracle India
 	  --Date created: 24/June/2005
 	  --
 	  --Purpose: Bug 4440482 - Find unmet need of student
 	  --
 	  --
 	  --Known limitations/enhancements and/or remarks:
 	  --
 	  --Change History:
 	  --Who         When            What
 	  -------------------------------------------------------------------
 	    p_resource_f    NUMBER;
 	    p_resource_i    NUMBER;
 	    p_unmet_need_f  NUMBER;
 	    p_unmet_need_i  NUMBER;
 	    p_resource_f_fc NUMBER;
 	    p_resource_i_fc NUMBER;

 	    CURSOR resource_cur IS
 	      SELECT NVL (SUM (NVL (disb.disb_gross_amt, 0)), 0) resource_f,
 	             NVL (SUM (DECODE (fm.replace_fc,
 	                               'Y', NVL (disb.disb_gross_amt, 0),
 	                               0
 	                              )),
 	                  0) resource_fm_f
 	        FROM igf_aw_awd_disb_all disb,
 	             igf_aw_award_all awd,
 	             igf_aw_fund_mast_all fm,
 	             (SELECT   base_id,
 	                       ld_cal_type,
 	                       ld_sequence_number
 	                  FROM igf_aw_coa_itm_terms
 	                 WHERE base_id = p_base_id
 	              GROUP BY base_id, ld_cal_type, ld_sequence_number) coa
 	       WHERE awd.fund_id = fm.fund_id
 	         AND awd.award_id = disb.award_id
 	         AND awd.base_id = p_base_id
 	         AND disb.ld_cal_type = coa.ld_cal_type
 	         AND disb.ld_sequence_number = coa.ld_sequence_number
 	         AND awd.base_id = coa.base_id
 	         AND disb.trans_type <> 'C'
 	         AND awd.award_status IN ('OFFERED', 'ACCEPTED');

 	    resource_rec                  resource_cur%ROWTYPE;
 	    ln_coa                        NUMBER;
 	    ln_efc                        NUMBER;
 	  BEGIN
 	    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'p_base_id:' || p_base_id);
 	    END IF;

 	    OPEN resource_cur;
 	    FETCH resource_cur INTO resource_rec;
 	    CLOSE resource_cur;

 	    ln_coa          := NVL (igf_aw_coa_gen.coa_amount (p_base_id), 0);
 	    ln_efc          := NVL (igf_aw_gen_004.efc_f (p_base_id), 0);
 	    p_resource_f    := resource_rec.resource_f;
 	    p_resource_f_fc := resource_rec.resource_fm_f;
 	    IF NVL (resource_rec.resource_fm_f, 0) > ln_efc THEN
 	       p_resource_f_fc := ln_efc;
 	    ELSE
 	       p_resource_f_fc := resource_rec.resource_fm_f;
 	    END IF;

 	    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'ln_coa:' || ln_coa);
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'ln_efc:' || ln_efc);
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'p_resource_f:' || p_resource_f);
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'p_resource_f_fc:' || p_resource_f_fc);
 	    END IF;

 	    IF ln_coa > ln_efc THEN
 	       p_unmet_need_f := ln_coa - ln_efc - NVL (p_resource_f, 0) + NVL (p_resource_f_fc, 0);
 	    ELSE
 	       p_unmet_need_f := ln_coa - p_resource_f_fc;
 	    END IF;

 	    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
 	      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.unmetneed.debug', 'p_unmet_need_f:' || p_unmet_need_f);
 	    END IF;

 	    RETURN p_unmet_need_f;
 	  END unmetneed;

  PROCEDURE cl_alt_borr_cosig_validation (p_loan_number igf_sl_loans.loan_number%TYPE,
                                             p_loan_catg VARCHAR2,
                                             p_prc_type_code igf_sl_lor.prc_type_code%TYPE)
  AS
      /***************************************************************
       Created By        :    bvisvana
       Date Created By   :    02-June-2005
       Purpose           :    To Validate borrower and cosigner details in the @4 Record
                              in case of FFELP ALT Loans i.e CL_ALT
       Known Limitations,Enhancements or Remarks
       Change History    :
       Who               When      What
     ***************************************************************/

      -- Cursor to fetch the Borrower and Cosigner details for CL_ALT loans (@4 Record)
      CURSOR c_alt_borr_details IS
      SELECT
      borw.borw_gross_annual_sal borw_gross_annual_sal,
      borw.borw_other_income borw_other_income,
      borw.cs1_gross_annual_sal_num csgnr1_gross_annual_sal,
      borw.cs1_other_income_amt csgnr1_other_income,
      borw.cs2_gross_annual_sal_num csgnr2_gross_annual_sal,
      borw.cs2_other_income_amt csgnr2_other_income,
      borw.student_major student_major,
      lor.prc_type_code prc_type_code,
      loans.loan_number loan_number
      FROM
      igf_sl_loans loans,
      igf_sl_lor lor,
      igf_sl_alt_borw borw
      WHERE
      loans.loan_number =  p_loan_number AND
      lor.prc_type_code = p_prc_type_code AND
      loans.loan_id = lor.loan_id AND
      lor.loan_id = borw.loan_id;
  BEGIN
        FOR borr_rec IN c_alt_borr_details LOOP
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'BORW_GROSS_ANNUAL_SAL',
                                               borr_rec.borw_gross_annual_sal,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'BORW_OTHER_INCOME',
                                               borr_rec.borw_other_income,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'CSGNR1_GROSS_ANNUAL_SAL',
                                               borr_rec.csgnr1_gross_annual_sal,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'CSGNR1_OTHER_INCOME',
                                               borr_rec.csgnr1_other_income,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'CSGNR2_GROSS_ANNUAL_SAL',
                                               borr_rec.csgnr2_gross_annual_sal,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'CSGNR2_OTHER_INCOME',
                                               borr_rec.csgnr2_other_income,borr_rec.prc_type_code));
          set_complete_status(check_for_reqd(borr_rec.loan_number,p_loan_catg,'STUDENT_MAJOR',
                                               borr_rec.student_major,borr_rec.prc_type_code));
        END LOOP;
  END cl_alt_borr_cosig_validation;

  PROCEDURE loan_limit_validation (
                                    p_base_id     IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                                    p_fund_type   IN          igf_aw_fund_cat.fed_fund_code%TYPE,
                                    p_award_id    IN          igf_aw_award_all.award_id%TYPE,
                                    p_msg_name    OUT NOCOPY  fnd_new_messages.message_name%TYPE
                                  )
  IS
    /***************************************************************
     Created By        :    museshad
     Date Created By   :    05-Oct-2005
     Purpose           :    Stafford loan limit validation
     Known Limitations,Enhancements or Remarks
     Change History    :
     Who               When           What
     bvisvana          10-Apr-2006    Removed the check for defalut status of parent and student as part of Bug # 4127532
   ***************************************************************/
    l_aid   NUMBER;

    CURSOR c_get_dist_plan(cp_award_id  igf_aw_award_all.award_id%TYPE)
    IS
      SELECT adplans_id
      FROM igf_aw_award_all
      WHERE award_id = cp_award_id;

    l_dist_plan_rec c_get_dist_plan%ROWTYPE;

  BEGIN

    l_aid := 0;
    p_msg_name := NULL;

    OPEN c_get_dist_plan(p_award_id);
    FETCH c_get_dist_plan INTO l_dist_plan_rec;
    CLOSE c_get_dist_plan;

    igf_aw_packng_subfns.check_loan_limits (
                                            l_base_id       =>  p_base_id,
                                            fund_type       =>  p_fund_type,
                                            l_award_id      =>  p_award_id,
                                            l_adplans_id    =>  l_dist_plan_rec.adplans_id,
                                            l_aid           =>  l_aid,
                                            l_std_loan_tab  =>  NULL,
                                            p_msg_name      =>  p_msg_name,
                                            l_awd_period    =>  NULL,
                                            l_called_from   =>  'NON-PACKAGING'
                                           );
  END loan_limit_validation;

-- Start of Main Procedure

BEGIN

  g_debug_runtime_level     := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF p_call_mode = 'FORM' THEN
      p_status_1 := 'G';
      p_status_2 := 'N';
      p_status_3 := 'R';
    END IF;

    IF p_call_mode ='JOB' THEN
      p_status_1 := 'G';
      p_status_2 := 'G';
      p_status_3 := 'G';
    END IF;

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

    IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_call_mode:' || p_call_mode);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_status_1:' || p_status_1);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_status_2:' || p_status_2);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_status_3:' || p_status_3);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_loan_catg:' || p_loan_catg);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_fed_fund_1:' || p_fed_fund_1);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_fed_fund_2:' || p_fed_fund_2);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_ci_cal_type:' || p_ci_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_ci_seq_number:' || p_ci_sequence_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_loan_number:' || p_loan_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_school_id  :' || p_school_id  );
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'p_base_id    :' || p_base_id    );
    END IF;


    FOR lor_rec IN cur_lor_details_recs(p_fed_fund_1,
                                        p_fed_fund_2,
                                        p_status_1,
                                        p_status_2,
                                        p_status_3,
                                        p_ci_cal_type,
                                        p_ci_sequence_number,
                                        'Y',
                                        p_school_id,
                                        p_base_id
                                        ) LOOP


  --Need not perform the validations if the Loan ID is same.
  --Bug:-2415041 Loan Orig with incorrect error messages.
  IF NVL(g_loan_id,0) <> lor_rec.loan_id OR p_call_mode = 'FORM' THEN

   -- Initialize the Value of Completeness before checking

     lv_complete := TRUE;

     --No data found exception should be explicitly handled
     --this was noticed when process was run without award year setup.
     BEGIN
       -- Get CommonLine Version for this Award Year.
       -- museshad(Bug# 4346258) -  Added the parameter p_base_id due to change in the
       --                           signature of the function 'get_cl_version()'
       p_cl_version := igf_sl_gen.get_cl_version(p_ci_cal_type, p_ci_sequence_number,lor_rec.relationship_cd,p_base_id);

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('IGF','IGF_SL_NO_CL_SETUP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.set_complete_status.debug', 'No CL Setup found');
              END IF;
           RAISE NO_DATA_FOUND;
     END;


    -- Assign Current Record to Temp.Rec

    lor_rec_temp := lor_rec;

    --  Fetch License State and Num into Variables
    OPEN cur_isir_depend_status;
    FETCH cur_isir_depend_status INTO lv_dependency_status;
    IF cur_isir_depend_status%NOTFOUND THEN
        CLOSE cur_isir_depend_status;
        fnd_message.set_name('IGF','IGF_GE_REC_NO_DATA_FOUND');
        fnd_message.set_token('P_RECORD','IGF_AP_FA_BASE_REC');
        igs_ge_msg_stack.add;
        IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate', 'cur_isir_depend_status cursor failed');
        END IF;
        app_exception.raise_exception;
    END IF;
    CLOSE cur_isir_depend_status;


   --  Deletes the Record from the Edit Table with this Loan Number and Status as Valid

   igf_sl_edit.delete_edit(lor_rec.loan_number,'V');

    -- For School Certification Requests, use External Loan Number field. If the External
    -- Loan Number is not available, error out and do not process the loan record
    IF lor_rec.prc_type_code = 'CR' THEN
      IF lor_rec.external_loan_id_txt IS NULL THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number,'V','IGF_SL_ERR_CODES','EXT_LOAN_NUM_CHK',NULL,NULL);
      END IF;
    END IF;

   --Irrespective of Loan Type School Certification date cannot be after the Loan Period End Date
   --and the Processing Type should be GP for this validation
   --Bug 2477912 CL Formatting Errors.
     IF lor_rec.sch_cert_date IS NOT NULL AND lor_rec.prc_type_code IN ('GP','GO') THEN
         IF  lor_rec.sch_cert_date > lor_rec.loan_per_end_date THEN
             set_complete_status(FALSE);
             igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '078', 'SCH_CERT_DATE',
                                     lor_rec.sch_cert_date);
         END IF;

      END IF;

      --If the validation process is called from JOB then check if the Sysdate >Loan Per End Date.
      --If so then we should make the Loan Status as NOT READY.Otherwise we can originate.
      --Loan Origination Date cannot be after Loan Period End Date.
      --2477912  Added error code 457 for File Transfer Date
      --4089250  Error code 046 should be used. Not 457 -ugummall
      IF p_call_mode ='JOB' AND lor_rec.prc_type_code IN ('GO','GP') THEN
         IF  TRUNC(SYSDATE) > lor_rec.loan_per_end_date THEN
            set_complete_status(FALSE);
            igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '046', 'FILE_TRANS_DATE', NULL);
         END IF;

      END IF;

   --Irrespective of Loan Type Anticipated Completion date cannot be before the Loan Period End Date
   --and the Processing Type should be GP for this validation
   --Bug 2477912 CL Formatting Errors.

     IF lor_rec.anticip_compl_date IS NOT NULL AND lor_rec.prc_type_code IN ('GP','GO') THEN
         IF  lor_rec.anticip_compl_date < lor_rec.loan_per_end_date THEN
             set_complete_status(FALSE);
            igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '053', 'ANTICIP_COMPL_DATE',
                                    lor_rec.anticip_compl_date);
         END IF;

      END IF;

    igf_sl_gen.get_person_details(lor_rec.student_id,student_dtl_cur);
    FETCH student_dtl_cur INTO student_dtl_rec;
    igf_sl_gen.get_person_details(lor_rec.p_person_id,parent_dtl_cur);
    FETCH parent_dtl_cur INTO parent_dtl_rec;

    --FA 161 - Due to the introduction of a new mapping form, we don't use the lookup tag but rather require the lookup_code itself to
    --determine the mapping values...and hence the below blocks of citizenship_dtl_cur
    OPEN citizenship_dtl_cur(lor_rec.student_id);
    FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
    student_dtl_rec.p_citizenship_status := citizenship_dtl_rec.restatus_code;
    CLOSE citizenship_dtl_cur;
    citizenship_dtl_rec := NULL;
    OPEN citizenship_dtl_cur(lor_rec.p_person_id);
    FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
    parent_dtl_rec.p_citizenship_status := citizenship_dtl_rec.restatus_code;
    CLOSE citizenship_dtl_cur;

    --Code added for bug 3603289 start
    lv_s_license_number     := student_dtl_rec.p_license_num;
    lv_s_license_state      := student_dtl_rec.p_license_state;
    lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
    log_to_fnd('cl_lar_validate','debug','P_CITIZENSHIP_STATUS = '||parent_dtl_rec.p_citizenship_status);
    log_to_fnd('cl_lar_validate','debug','S_CITIZENSHIP_STATUS = '||student_dtl_rec.p_citizenship_status);
    --Code added for bug 3603289 end

    -- For each of the LOR records check if the Required Fields are not null

    IF p_loan_catg = 'CL_STAFFORD' THEN
      l_phone := igf_sl_gen.get_person_phone( lor_rec.student_id );

      -- Following are the checks for Common Line Loan Stafford.

      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_SSN',
                                         student_dtl_rec.p_ssn,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_FIRST_NAME',
                                         student_dtl_rec.p_first_name,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_PERMT_ADDR1',
                                         student_dtl_rec.p_permt_addr1,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_PERMT_CITY',
                                         student_dtl_rec.p_permt_city,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_PERMT_STATE',
                                         student_dtl_rec.p_permt_state,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_PERMT_ZIP',
                                         student_dtl_rec.p_permt_zip,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'BORW_LENDER_ID',
                                         lor_rec.borw_lender_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_DATE_OF_BIRTH',
                                         TO_CHAR(student_dtl_rec.p_date_of_birth),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'CL_LOAN_TYPE',
                                         lor_rec.cl_loan_type,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_AMT_ACCEPTED',
                                         TO_CHAR(lor_rec.loan_amt_accepted),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'BORW_INTEREST_IND',
                                         lor_rec.borw_interest_ind,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'EFT_AUTHORIZATION',
                                         lor_rec.eft_authorization_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_NUMBER',
                                         lor_rec.loan_number,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'SCHOOL_ID',
                                         p_school_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_BEGIN_DATE',
                                         TO_CHAR(lor_rec.loan_per_begin_date),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_END_DATE',
                                         TO_CHAR(lor_rec.loan_per_end_date),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GRADE_LEVEL_CODE',
                                         lor_rec.grade_level_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ENROLLMENT_CODE',
                                         lor_rec.enrollment_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ANTICIP_COMPL_DATE',
                                         lor_rec.anticip_compl_date,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_AMT_ACCEPTED',
                                         TO_CHAR(lor_rec.loan_amt_accepted),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LENDER_ID',
                                         lor_rec.lender_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GUARANTOR_ID',
                                         lor_rec.guarantor_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LICENSE_STATE',
                                         lv_s_license_state,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LICENSE_NUM',
                                         lv_s_license_number,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'REQ_SERIAL_LOAN_CODE',
                                         lor_rec.req_serial_loan_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LEND_NON_ED_BRC_ID',
                                         lor_rec.lend_non_ed_brc_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PRC_TYPE_CODE',
                                         lor_rec.prc_type_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PNOTE_DELIVERY_CODE',
                                         lor_rec.pnote_delivery_Code,lor_rec.prc_type_code));

      -- rajagupt - FA 161 - Bug # 5006583
      -- Check for Valid Federal application form code i.e Stafford = 'M'
      IF NVL(lor_rec.loan_app_form_code,'*') <> 'M' THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '405', 'FED_APPL_FORM_CODE', NULL);
      END IF;
      -- Deferement Request not required for 'M' appl form code
      IF NVL(lor_rec.loan_app_form_code,'*') = 'M' AND lor_rec.deferment_request_code IS NOT NULL THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'DEFER_REQ_CODE', NULL);
         g_update_mode_required := TRUE;
      END IF;

      --Added this Code as CL Ref doc this is Strongly Recommended for all types of Loans.Bug 2400487
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_SIGNATURE_CODE',
                                         lor_rec.s_signature_code,lor_rec.prc_type_code));

      -- For CL Stafford If the Student is in Default, then do not originate
      IF lor_rec.s_default_status = 'Y'  AND (lor_rec.prc_type_code IN ('GP','GO')) THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'S_DEFAULT_STATUS', NULL);
      END IF;

      --
      -- Check for Student SSN
      --
      IF (lor_rec.prc_type_code IN ('GP','GO')) THEN
        IF SUBSTR(student_dtl_rec.p_ssn,1,1) = '8' OR
           SUBSTR(student_dtl_rec.p_ssn,1,1) = '9' OR
           SUBSTR(student_dtl_rec.p_ssn,1,3) = '000'
        THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '034', 'S_SSN', NULL);
        END IF;
      END IF;


    ELSIF p_loan_catg IN ('CL_PLUS','CL_GPLUSFL') THEN
      l_phone := igf_sl_gen.get_person_phone( lor_rec.p_person_id );
      -- Following are the checks for Common Line Loan PLUS and Grad Plus Loan.

      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_SSN',
                                         parent_dtl_rec.p_ssn,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_FIRST_NAME',
                                         parent_dtl_rec.p_first_name,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LAST_NAME',
                                         parent_dtl_rec.p_last_name,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_FIRST_NAME',
                                         student_dtl_rec.p_first_name,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LAST_NAME',
                                         student_dtl_rec.p_last_name,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_SSN',
                                         student_dtl_rec.p_ssn,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_DATE_OF_BIRTH',
                                         student_dtl_rec.p_date_of_birth,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_CITIZENSHIP_STATUS',
                                         lv_s_citizenship_status,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_ADDR1',
                                         parent_dtl_rec.p_permt_addr1,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_CITY',
                                         parent_dtl_rec.p_permt_city,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_STATE',
                                         parent_dtl_rec.p_permt_state,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_ZIP',
                                         parent_dtl_rec.p_permt_zip,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'BORW_LENDER_ID',
                                         lor_rec.borw_lender_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_DATE_OF_BIRTH',
                                         TO_CHAR(parent_dtl_rec.p_date_of_birth),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'CL_LOAN_TYPE',
                                         lor_rec.cl_loan_type,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'EFT_AUTHORIZATION',
                                         lor_rec.eft_authorization_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_SIGNATURE_CODE',
                                         lor_rec.p_signature_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_NUMBER',
                                         lor_rec.loan_number,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_CITIZENSHIP_STATUS',
                                         parent_dtl_rec.p_citizenship_status,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_BEGIN_DATE',
                                         TO_CHAR(lor_rec.loan_per_begin_date),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_END_DATE',
                                         TO_CHAR(lor_rec.loan_per_end_date),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GRADE_LEVEL_CODE',
                                         lor_rec.grade_level_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ENROLLMENT_CODE',
                                         lor_rec.enrollment_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ANTICIP_COMPL_DATE',
                                         TO_CHAR(lor_rec.anticip_compl_date),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_AMT_ACCEPTED',
                                         TO_CHAR(lor_rec.loan_amt_accepted),lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LENDER_ID',
                                         lor_rec.lender_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GUARANTOR_ID',
                                         lor_rec.guarantor_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LICENSE_STATE',
                                         parent_dtl_rec.p_license_state,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LICENSE_NUM',
                                         parent_dtl_rec.p_license_num,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LEND_NON_ED_BRC_ID',
                                         lor_rec.lend_non_ed_brc_id,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PRC_TYPE_CODE',
                                         lor_rec.prc_type_code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PNOTE_DELIVERY_CODE',
                                         lor_rec.pnote_delivery_Code,lor_rec.prc_type_code));
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'REQ_SERIAL_LOAN_CODE',
                                         lor_rec.req_serial_loan_code,lor_rec.prc_type_code));

      -- For CL PLUS If the Student or Parent is in Default then do not originate
      -- Check for Valid Federal application form code i.e PLUS = 'Q'
      IF(NVL(lor_rec.loan_app_form_code,'*') <> 'Q'AND p_loan_catg IN ('CL_PLUS')) OR
 	(NVL(lor_rec.loan_app_form_code,'*') <> 'G' AND p_loan_catg IN ('CL_GPLUSFL')) THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '405', 'FED_APPL_FORM_CODE', NULL);
      END IF;
      -- Not required fields
      IF NVL(lor_rec.loan_app_form_code,'*') = 'Q' OR NVL(lor_rec.loan_app_form_code,'*') = 'G' THEN
        IF lor_rec.deferment_request_code IS NOT NULL THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'DEFER_REQ_CODE', NULL);
           g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.borw_interest_ind IS NOT NULL AND (lor_rec.borw_interest_ind = 'Y' OR lor_rec.borw_interest_ind = 'YES') THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'BORW_INTEREST_IND', NULL);
           g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.p_default_status IS NOT NULL THEN
          set_complete_status(FALSE);
          igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'P_DEFAULT_STATUS', NULL);
          g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.s_default_status IS NOT NULL THEN
          set_complete_status(FALSE);
          igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'S_DEFAULT_STATUS', NULL);
          g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.borw_outstd_loan_code IS NOT NULL THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'BORW_OUTSTD_LOAN_CODE', NULL);
           g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.s_signature_code IS NOT NULL THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'S_SIGNATURE_CODE', NULL);
           g_update_mode_required := TRUE;
        END IF;
        IF lor_rec.stud_sign_ind IS NOT NULL AND (lor_rec.stud_sign_ind = 'Y' OR lor_rec.stud_sign_ind = 'YES') THEN
          set_complete_status(FALSE);
          igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '502', 'S_ESIGN_IND_CODE', NULL);
          g_update_mode_required := TRUE;
        END IF;
      END IF;
      -- FA 161 - Bug 5006583 - Citizenship mapping code does not exists
      -- Student
      IF lv_s_citizenship_status IS NOT NULL THEN
        OPEN cur_fa_mapping( cp_citizenship_status => lv_s_citizenship_status,
                             cp_cal_type           => p_ci_cal_type,
                             cp_sequence_number    => p_ci_sequence_number);
        FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
        IF cur_fa_mapping%NOTFOUND THEN
            log_to_fnd('cl_lar_validate','debug','----S_CITIZENSHIP_STATUS----');
            set_complete_status(FALSE);
            igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'NO_FA_CITI_MAP_CD', 'S_CITIZENSHIP_STATUS', NULL);
        END IF;
        CLOSE cur_fa_mapping;
      END IF;
      -- Parent
      IF parent_dtl_rec.p_citizenship_status IS NOT NULL THEN
        OPEN cur_fa_mapping( cp_citizenship_status => parent_dtl_rec.p_citizenship_status,
                             cp_cal_type           => p_ci_cal_type,
                             cp_sequence_number    => p_ci_sequence_number);
        FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
        log_to_fnd('cl_lar_validate','debug','cur_fa_mapping_rec.fa_citi_stat_code ='||cur_fa_mapping_rec.fa_citi_stat_code||'=');
        log_to_fnd('cl_lar_validate','debug','lor_rec.b_alien_reg_num_txt ='||lor_rec.b_alien_reg_num_txt||'=');
        IF cur_fa_mapping%NOTFOUND THEN
            set_complete_status(FALSE);
            igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'NO_FA_CITI_MAP_CD', 'P_CITIZENSHIP_STATUS', NULL);
        -- Borw Alien registration Number is Strongly Recommended if FA Citizenship code maps to 2
        ELSIF (cur_fa_mapping_rec.fa_citi_stat_code = '2' AND lor_rec.b_alien_reg_num_txt IS NULL) THEN
            log_to_fnd('cl_lar_validate','debug','p_loan_catg ' || p_loan_catg);
            log_to_fnd('cl_lar_validate','debug','lor_rec.b_alien_reg_num_txt '||lor_rec.b_alien_reg_num_txt);
            log_to_fnd('cl_lar_validate','debug','lor_rec.prc_type_code '||lor_rec.prc_type_code);

            set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'B_ALIEN_REG_NUM',
                                               lor_rec.b_alien_reg_num_txt,lor_rec.prc_type_code));
        END IF;
        CLOSE cur_fa_mapping;

      END IF;

      --
      -- Check for Student and Borrower SSN
      --
      IF (lor_rec.prc_type_code IN ('GP','GO')) THEN
        IF SUBSTR(student_dtl_rec.p_ssn,1,1) = '8' OR
           SUBSTR(student_dtl_rec.p_ssn,1,1) = '9' OR
           SUBSTR(student_dtl_rec.p_ssn,1,3) = '000'
        THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '034', 'S_SSN', NULL);
        END IF;

        IF SUBSTR(parent_dtl_rec.p_ssn,1,1) = '8' OR
           SUBSTR(parent_dtl_rec.p_ssn,1,1) = '9' OR
           SUBSTR(parent_dtl_rec.p_ssn,1,3) = '000'
        THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '001', 'P_SSN', NULL);
        END IF;
      END IF;
    ELSIF p_loan_catg = 'CL_ALT' THEN
      l_phone := igf_sl_gen.get_person_phone( lor_rec.p_person_id );

      -- Following are the checks for Common Line Loan ALTERNATE.
      log_to_fnd('cl_lar_validate','debug','----P_LAST_NAME----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LAST_NAME',
                                         parent_dtl_rec.p_last_name,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_FIRST_NAME----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_FIRST_NAME',
                                         parent_dtl_rec.p_first_name,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_SSN----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_SSN',
                                         parent_dtl_rec.p_ssn,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_PERMT_ADDR1----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_ADDR1',
                                         parent_dtl_rec.p_permt_addr1,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_PERMT_CITY----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_CITY',
                                         parent_dtl_rec.p_permt_city,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_PERMT_STATE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_STATE',
                                         parent_dtl_rec.p_permt_state,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_PERMT_ZIP----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_PERMT_ZIP',
                                         parent_dtl_rec.p_permt_zip,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----BORW_LENDER_ID----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'BORW_LENDER_ID',
                                         lor_rec.borw_lender_id,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_DATE_OF_BIRTH----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_DATE_OF_BIRTH',
                                         TO_CHAR(parent_dtl_rec.p_date_of_birth),lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----CL_LOAN_TYPE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'CL_LOAN_TYPE',
                                         lor_rec.cl_loan_type,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----P_SIGNATURE_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_SIGNATURE_CODE',
                                         lor_rec.p_signature_code,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----LOAN_NUMBER----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_NUMBER',
                                         lor_rec.loan_number,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----BORW_OUTSTD_LOAN_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'BORW_OUTSTD_LOAN_CODE',
                                         lor_rec.borw_outstd_loan_code,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----S_LAST_NAME----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LAST_NAME',
                                         student_dtl_rec.p_last_name,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----S_FIRST_NAME----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_FIRST_NAME',
                                         student_dtl_rec.p_first_name,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----S_SSN----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_SSN',
                                         student_dtl_rec.p_ssn,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----S_DATE_OF_BIRTH----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_DATE_OF_BIRTH',
                                         student_dtl_rec.p_date_of_birth,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----S_DEFAULT_STATUS----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_DEFAULT_STATUS',
                                         lor_rec.s_default_status,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----SCHOOL_ID----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'SCHOOL_ID',
                                         p_school_id,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----LOAN_PER_BEGIN_DATE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_BEGIN_DATE',
                                         TO_CHAR(lor_rec.loan_per_begin_date),lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----LOAN_PER_END_DATE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LOAN_PER_END_DATE',
                                         TO_CHAR(lor_rec.loan_per_end_date),lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----GRADE_LEVEL_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GRADE_LEVEL_CODE',
                                         lor_rec.grade_level_code,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----ENROLLMENT_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ENROLLMENT_CODE',
                                         lor_rec.enrollment_code,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----ANTICIP_COMPL_DATE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ANTICIP_COMPL_DATE',
                                         TO_CHAR(lor_rec.anticip_compl_date),lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----LENDER_ID----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LENDER_ID',
                                         lor_rec.lender_id,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----GUARANTOR_ID----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'GUARANTOR_ID',
                                         lor_rec.guarantor_id,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----LEND_NON_ED_BRC_ID----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'LEND_NON_ED_BRC_ID',
                                         lor_rec.lend_non_ed_brc_id,lor_rec.prc_type_code));
      log_to_fnd('cl_lar_validate','debug','----PRC_TYPE_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PRC_TYPE_CODE',
                                         lor_rec.prc_type_code,lor_rec.prc_type_code));

      log_to_fnd('cl_lar_validate','debug','----PNOTE_DELIVERY_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'PNOTE_DELIVERY_CODE',
                                         lor_rec.pnote_delivery_Code,lor_rec.prc_type_code));

      --Added this Code as CL Ref doc this is Strongly Recommended for all types of Loans.Bug 2400487
      log_to_fnd('cl_lar_validate','debug','----S_SIGNATURE_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_SIGNATURE_CODE',
                                          lor_rec.s_signature_code,lor_rec.prc_type_code));
      --FACR116
      log_to_fnd('cl_lar_validate','debug','----ALT_LOAN_CODE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'ALT_LOAN_CODE',
                                          lor_rec.alt_loan_code,lor_rec.prc_type_code));

      /* Check if the student is the borrower */
      IF ( lor_rec.p_person_id = lor_rec.student_id ) THEN
          log_to_fnd('cl_lar_validate','debug','----S_LICENSE_STATE----');
          set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LICENSE_STATE',
                                             lv_s_license_state,lor_rec.prc_type_code));
          log_to_fnd('cl_lar_validate','debug','----S_LICENSE_NUM----');
          set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_LICENSE_NUM',
                                             lv_s_license_number,lor_rec.prc_type_code));
          log_to_fnd('cl_lar_validate','debug','----S_CITIZENSHIP_STATUS----');
          set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'S_CITIZENSHIP_STATUS',
                              lv_s_citizenship_status,lor_rec.prc_type_code));


          -- FA 161 - Bug 5006583 - Citizenship mapping code does not exists
          IF lv_s_citizenship_status IS NOT NULL THEN
            OPEN cur_fa_mapping( cp_citizenship_status => lv_s_citizenship_status,
                                 cp_cal_type           => p_ci_cal_type,
                                 cp_sequence_number    => p_ci_sequence_number);
            FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
            IF cur_fa_mapping%NOTFOUND THEN
                set_complete_status(FALSE);
                igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'NO_FA_CITI_MAP_CD', 'S_CITIZENSHIP_STATUS', NULL);
            ELSIF NOT (cur_fa_mapping_rec.fa_citi_stat_code IN ('1','2') AND (lor_rec.prc_type_code IN ('GP','GO'))) THEN
             set_complete_status(FALSE);
             igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '016', 'P_CITIZENSHIP_STATUS', NULL);

             log_to_fnd('cl_lar_validate','debug','--------------------');
             log_to_fnd('cl_lar_validate','debug','P_CITIZENSHIP_STATUS');
            ELSIF cur_fa_mapping_rec.fa_citi_stat_code = '2' AND lor_rec.b_alien_reg_num_txt IS NULL THEN
              log_to_fnd('cl_lar_validate','debug','----B_ALIEN_REG_NUM----');
              set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'B_ALIEN_REG_NUM',
                                                 lor_rec.b_alien_reg_num_txt,lor_rec.prc_type_code));
            END IF;
            CLOSE cur_fa_mapping;
          END IF;

      ELSE
        log_to_fnd('cl_lar_validate','debug','----P_CITIZENSHIP_STATUS----');
        set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_CITIZENSHIP_STATUS',
                                           parent_dtl_rec.p_citizenship_status,lor_rec.prc_type_code));
        IF parent_dtl_rec.p_citizenship_status IS NOT NULL THEN
          OPEN cur_fa_mapping( cp_citizenship_status => parent_dtl_rec.p_citizenship_status,
                               cp_cal_type           => p_ci_cal_type,
                               cp_sequence_number    => p_ci_sequence_number);
          FETCH cur_fa_mapping INTO cur_fa_mapping_rec;
          IF cur_fa_mapping%NOTFOUND  THEN
              log_to_fnd('cl_lar_validate','debug','----P_CITIZENSHIP_STATUS----');
              set_complete_status(FALSE);
              igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'NO_FA_CITI_MAP_CD', 'P_CITIZENSHIP_STATUS', NULL);
          ELSIF NOT (cur_fa_mapping_rec.fa_citi_stat_code IN ('1','2') AND (lor_rec.prc_type_code IN ('GP','GO'))) THEN
             set_complete_status(FALSE);
             igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '016', 'P_CITIZENSHIP_STATUS', NULL);

             log_to_fnd('cl_lar_validate','debug','--------------------');
             log_to_fnd('cl_lar_validate','debug','P_CITIZENSHIP_STATUS');

          ELSIF cur_fa_mapping_rec.fa_citi_stat_code = '2' AND lor_rec.b_alien_reg_num_txt IS NULL THEN
              log_to_fnd('cl_lar_validate','debug','----B_ALIEN_REG_NUM----');
              set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'B_ALIEN_REG_NUM',
                                                 lor_rec.b_alien_reg_num_txt,lor_rec.prc_type_code));
          END IF;
          CLOSE cur_fa_mapping;
        END IF;

        log_to_fnd('cl_lar_validate','debug','----P_LICENSE_STATE----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LICENSE_STATE',
                                           parent_dtl_rec.p_license_state,lor_rec.prc_type_code));
        log_to_fnd('cl_lar_validate','debug','----P_LICENSE_NUM----');
      set_complete_status(check_for_reqd(lor_rec.loan_number,p_loan_catg,'P_LICENSE_NUM',
                                           parent_dtl_rec.p_license_num,lor_rec.prc_type_code));
      END IF;

      -- rajagupt - FA 161 - Bug # 5006583 -- Check for Valid Federal application form code i.e for ALT = null
      IF lor_rec.loan_app_form_code IS NOT NULL THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '405', 'FED_APPL_FORM_CODE', NULL);
      END IF;

      --FA 157 - FFELP ALT Loan Validation - Includes Borrower and Cosigner details
      cl_alt_borr_cosig_validation(lor_rec.loan_number,p_loan_catg,lor_rec.prc_type_code);


      -- Commented for Bug 2477912 CL Formatting Errors

      -- For CL ALT If the Student is not the borrower then if either the student or the borrower are in default - do not originate
      --            If the student is the borrower then if the student is in Default then do not originate

      --
      -- Check for Student SSN
      --
    IF (lor_rec.prc_type_code IN ('GP','GO')) THEN
      IF SUBSTR(student_dtl_rec.p_ssn,1,1) = '8' OR
         SUBSTR(student_dtl_rec.p_ssn,1,1) = '9' OR
         SUBSTR(student_dtl_rec.p_ssn,1,3) = '000'
      THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '034', 'S_SSN', NULL);
         log_to_fnd('cl_lar_validate','debug','----S_SSN----');
      END IF;
    END IF;
      /* If student is not the borrower */

      IF ( lor_rec.p_person_id <> lor_rec.student_id ) THEN
        -- Removed the check for default status of parent as a part of Bug # 4127532

      -- Check for Borrower SSN
      --
      IF (lor_rec.prc_type_code IN ('GP','GO')) THEN
        IF SUBSTR(parent_dtl_rec.p_ssn,1,1) = '8' OR
           SUBSTR(parent_dtl_rec.p_ssn,1,1) = '9' OR
           SUBSTR(parent_dtl_rec.p_ssn,1,3) = '000'
        THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '001', 'P_SSN', NULL);
             log_to_fnd('cl_lar_validate','debug','----P_SSN----');
        END IF;
      END IF;
      END IF;

      -- Removed the check for default status of student as a part of Bug # 4127532
    END IF;  -- End of condition for p_loan_catg

    -- For Release 4 processing, only 4 disbursements are allowed. So do not originate a loan in case
    -- there are more than 4 disbursements.
    IF p_cl_version = 'RELEASE-4' THEN
      log_to_fnd('cl_lar_validate','debug','Verifying the no. of disbursements');
      OPEN  c_nof_awd_disb ( cp_n_award_id => lor_rec.award_id);
      FETCH c_nof_awd_disb INTO l_n_disb_cnt;
      IF  c_nof_awd_disb%FOUND THEN
        log_to_fnd('cl_lar_validate','debug','The no. of disbursements='||l_n_disb_cnt);
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number,'V','IGF_SL_ERR_CODES','FOUR_DISB_CHK',NULL,NULL);
      END IF;
      CLOSE c_nof_awd_disb;
    END IF;

    -- If the Loan Amount Accepted is greater than the COA - EFC for Stafford Loans,
    -- then do not originate the Loan Record
    IF ( p_loan_catg = 'CL_STAFFORD'          AND
         lor_rec.prc_type_code IN ('GP','GO') AND
         lor_rec.rec_type_ind <> 'T'
        ) THEN

      IF (NVL(unmetneed(lor_rec.base_id),0) < 0) THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number,'V','IGF_SL_ERR_CODES','COA_EFC_CHK',NULL,NULL);
        log_to_fnd('cl_lar_validate','debug','loan_amt_accepted:'||lor_rec.loan_amt_accepted);
      END IF;
    END IF;

    -- For Both Loan Types check the Dependency status for the Borrower

    IF NVL(lv_dependency_status,'*') NOT IN ('I','D') AND (lor_rec.prc_type_code IN ('GP','GO')) THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DEPNCY_NO_EFC_CALC', 'S_DEPNCY_STATUS', NULL);
      log_to_fnd('cl_lar_validate','debug','-----S_DEPNCY_STATUS-----');
    END IF;

    -- Loan Amount should be greater than zero for any Type of Loan. Else need to update the EditReport Table.
    IF NVL(lor_rec.loan_amt_accepted,0)<= 0 AND (lor_rec.prc_type_code IN ('GP','GO')) AND lor_rec.rec_type_ind <> 'T' THEN
       set_complete_status(FALSE);
       igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LESS_THAN_ZERO', 'LOAN_AMT_ACCEPTED', NULL);
       log_to_fnd('cl_lar_validate','debug','-----LOAN_AMT_ACCEPTED-----');
    END IF;

    -- For Both Stafford and PLUS Loans all Disbursement Amounts should be Greater than Zero.Even if One
    -- amount is Zero or Less Than Zero then Need to Specify its Invalid

    IF (lor_rec.prc_type_code IN ('GP','GO') AND lor_rec.rec_type_ind <> 'T' ) THEN
      -- For Release 4 processing, Disbursement Amount is needed only for Alternative Loans.
      -- It is not used in PLUS and Stafford Loans
      IF ((p_cl_version = 'RELEASE-4' AND p_loan_catg = 'CL_ALT') OR (p_cl_version = 'RELEASE-5')) THEN
        OPEN cur_count_disb_amount;
        FETCH cur_count_disb_amount INTO ln_disb_amt_count;
        IF ln_disb_amt_count <> 0 THEN
          set_complete_status(FALSE);
          igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DISB_MORE_THAN_ZERO', NULL, NULL);
          log_to_fnd('cl_lar_validate','debug','-----DISB_MORE_THAN_ZERO-----');
        END IF;
        CLOSE cur_count_disb_amount;
      END IF;
    END IF;

    --For Both Stafford and PLUS loans all Disbursement Indicators should be not null.Even if one
    --Indicator is null then Need to Specify its Invalid

    OPEN cur_count_disb_ind;
    FETCH cur_count_disb_ind  INTO ln_disb_ind_count;
    IF  ln_disb_ind_count <> 0 THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number,'V','IGF_SL_ERR_CODES','HOLD_REL_NOT_NULL',NULL,NULL);
        log_to_fnd('cl_lar_validate','debug','-----HOLD_REL_NOT_NULL-----');
     END IF;
     CLOSE cur_count_disb_ind;


    --For Both Stafford and PLUS loans all Disbursement Dates should be not null.Even if one
    --Date is null then Need to Specify its Invalid
  IF (lor_rec.prc_type_code IN ('GP','GO')) THEN
    OPEN cur_count_disb_dates;
    FETCH cur_count_disb_dates INTO ln_disb_dates_count;
    IF ln_disb_dates_count <> 0 THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(lor_rec.loan_number,'V','IGF_SL_ERR_CODES','DISB_DATE_NOT_NULL',NULL,NULL);
        log_to_fnd('cl_lar_validate','debug','-----DISB_DATE_NOT_NULL-----');
    END IF;
    CLOSE cur_count_disb_dates;
  END IF;
    --Check added for address usages for both loan types
    --Possible that if more than one address has same address usage then
    --LOR DTLS View will fetch more than one loan record for the same loan id.
    --To avoid this from originating 2 records having all details same except
    --for addresses,we can make the loan status as Not Ready and show in reject details.

    --MN 10-Jan-2005 Check for Certification amount and requested amount.
    -- bvisvana - Bug # 4575843 -  Check for requested loan amount. It should be in whole number.
      IF (lor_rec.requested_loan_amt < lor_rec.loan_amt_accepted)  OR
         ((lor_rec.requested_loan_amt - TRUNC(lor_rec.requested_loan_amt)) <> 0) THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_CL_ERROR', '014', 'REQUESTED_LOAN_AMT', NULL);
            log_to_fnd('cl_lar_validate','debug','-----REQUESTED_LOAN_AMT-----');
      END IF;

    -- museshad (Bug 4116399) Stafford loan limit validation
    IF lor_rec.fed_fund_code NOT IN ('PRK','DLP','FLP','ALT','GPLUSFL') THEN
      lv_msg_name     := NULL;
      lv_lookup_code  := NULL;
      loan_limit_validation (
                              p_base_id     =>    lor_rec.base_id,
                              p_fund_type   =>    lor_rec.fed_fund_code,
                              p_award_id    =>    lor_rec.award_id,
                              p_msg_name    =>    lv_msg_name
                            );

      IF lv_msg_name IS NOT NULL THEN
        -- Stafforf loan limit validation failed
        lv_warning := TRUE;

        IF lv_msg_name = 'IGF_AW_AGGR_LMT_ERR' THEN
          lv_lookup_code := 'AGGR_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_ANNUAL_LMT_ERR' THEN
          lv_lookup_code := 'ANNUAL_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_SUB_AGGR_LMT_ERR' THEN
          lv_lookup_code := 'SUB_AGGR_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_SUB_LMT_ERR' THEN
          lv_lookup_code := 'SUB_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_LOAN_LMT_NOT_FND' THEN
           set_complete_status(FALSE); -- For Bug # 5091652
          lv_lookup_code := 'LOAN_LMT_SETUP_CHK';
        END IF;

        igf_sl_edit.insert_edit(lor_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', lv_lookup_code, NULL, NULL);

        -- Log
        log_to_fnd('cl_lar_validate','debug','Stafford loan limit validation failed with message: ' ||lv_msg_name);

      END IF;
    END IF;
    -- museshad (Bug 4116399)

    IF p_call_mode = 'JOB' THEN

           -- If any validation fails or if any required data is missing, then set Loan Status=Not Ready.
           -- Else, set to "Valid and Ready to Send"
          IF lv_complete = FALSE THEN
             lv_loan_status := 'N';  -- NOT READY
          ELSE
             lv_loan_status := 'V';  -- VALID and READY TO SEND
          END IF;

          IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'lv_loan_status:' || lv_loan_status);
          END IF;

          DECLARE
          CURSOR c_tbh_cur IS
          SELECT igf_sl_loans.* FROM igf_sl_loans
          WHERE loan_id = lor_rec.loan_id FOR UPDATE OF igf_sl_loans.loan_status NOWAIT;
       BEGIN

          FOR tbh_rec in c_tbh_cur LOOP

            IF (fnd_log.level_statement >= g_debug_runtime_level) THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'Updating tbh_rec.loan_id:' || tbh_rec.loan_id);
            END IF;

              -- Modified the update row call for the Borrower Determination as part of Refunds DLD 2144600
              igf_sl_loans_pkg.update_row (
                X_Mode                              => 'R',
                x_rowid                             => tbh_rec.row_id,
                x_loan_id                           => tbh_rec.loan_id,
                x_award_id                          => tbh_rec.award_id,
                x_seq_num                           => tbh_rec.seq_num,
                x_loan_number                       => tbh_rec.loan_number,
                x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
                x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
                x_loan_status                       => lv_loan_status,
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
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_validation.cl_lar_validate.debug', 'Updated tbh_rec.loan_id:' || tbh_rec.loan_id);
            END IF;

           END LOOP;
      END;

      -- If the Completeness of Record is False then Log File should be updated with the details

       IF lv_complete = FALSE OR lv_warning = TRUE THEN
            -- Display reject details on the Concurrent Manager Log File.
            DECLARE
               lv_log_mesg VARCHAR2(1000);
               CURSOR c_reject IS
               SELECT RPAD(field_desc,70)||sl_error_desc reject_desc FROM igf_sl_edit_report_v
               WHERE  loan_number = lor_rec.loan_number
               AND    orig_chg_code = 'V';
            BEGIN
               fnd_file.put_line(fnd_file.log, '');
               fnd_file.put_line(fnd_file.log, '');

               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER')||' : '||igf_gr_gen.get_per_num(lor_rec.base_id);
               fnd_file.put_line(fnd_file.log, lv_log_mesg);

               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER')||' : '||lor_rec.loan_number;
               fnd_file.put_line(fnd_file.log, lv_log_mesg);

               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SSN')      ||' : '||student_dtl_rec.p_ssn;
               fnd_file.put_line(fnd_file.log, lv_log_mesg);

               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_FULL_NAME')||' : '
                                                                 ||student_dtl_rec.p_first_name||' '||student_dtl_rec.p_last_name;
               fnd_file.put_line(fnd_file.log, lv_log_mesg);

               FOR rej_rec IN c_reject LOOP
                 fnd_file.put_line(fnd_file.log,'    '||rej_rec.reject_desc);
               END LOOP;
               --FA 161 - Bug 5006583 - Give message to use the update mode
               IF g_update_mode_required THEN
                  fnd_file.new_line(fnd_file.log,2);
                  fnd_message.set_name('IGF','IGF_SL_CL_LOAN_UPD_CORR');
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
               END IF;
           END;
         END IF;

    ELSE
       -- If the validation routinue is called from FORM, then just return the Status of TRUE/FALSE.
       NULL;

    END IF;

g_loan_id:=lor_rec.loan_id;  --Keep changing Global Loan ID everytime it is different.

END IF; --Check for Global Loan ID not being same.


  END LOOP;


  IF p_call_mode = 'JOB' THEN
     RETURN TRUE;
  ELSE
     RETURN lv_complete;
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
WHEN OTHERS THEN
--Removed the fnd_message.setname with Package.Procedure name.
--This is because this procedure in turn calls igf_sl_dl_record package academic year functions
--which return valid exceptions.only if we just propogate this exception
--we will be able to trap both in form and in dl orig process.
--hence removed code.
--Bug :-2415041 Loan Orig with incorrect error messages.

  app_exception.raise_exception;

END cl_lar_validate;

END igf_sl_cl_validation;

/
