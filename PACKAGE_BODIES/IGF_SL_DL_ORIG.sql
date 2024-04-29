--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_ORIG" AS
/* $Header: IGFSL03B.pls 120.2 2006/04/17 04:59:46 akomurav noship $ */

PROCEDURE dl_originate(errbuf          OUT      NOCOPY    VARCHAR2,
                       retcode         OUT      NOCOPY    NUMBER,
                       p_award_year    VARCHAR2,
                       p_dl_loan_catg  igf_lookups_view.lookup_code%TYPE,
                       p_loan_number   igf_sl_loans_all.loan_number%TYPE,
                       p_org_id        IN   NUMBER,
                       school_type   IN   VARCHAR2,
                       p_school_code IN   VARCHAR2)
AS
--
-----------------------------------------------------------------------------------
--
--   Created By : venagara
--   Date Created On : 2000/11/13
--   Purpose :
--   Know limitations, enhancements or remarks
--   Change History:
--   Procedure dl_originate :
--   User inputs are
--   Award year (required) : Consists of Cal_type and sequence_number concatenated
--   DL_LOAN_TYPE          : Valid values are DL_STAFFORD/DL_PLUS.
--                           Lookup_type = 'IGF_SL_DL_LOAN_CATG' for the above
--   LOAN_NUMBER           : Can be a particular Loan_number or can be NULL, if the
--                           user wants to select all loan_numbers.
--
-----------------------------------------------------------------------------------
--   Who        When             What
-----------------------------------------------------------------------------------
--  akomurav    17-Apr-2006      Build FA161 and 162
--                               TBH Impact change in igf_sl_lor_loc_pkg.insert_row()
--                               and igf_sl_lor_pkg.update_row().
-------------------------------------------------------------------------------------
--  museshad    20-Feb-2005     Bug 5045452 - SQL Repository Issue.
--                              Modified the cursor c_loans for better performance
-------------------------------------------------------------------------------------
-- pssahni      22-Dec-2004    Bug# 4081177 This process runs only for phase_in_participant
-------------------------------------------------------------------------------------
-- svuppala     4-Nov-2004      #3416936 FA 134 TBH impacts for newly added columns

--  veramach   04-May-2004     bug 3603289
--                             modified cursor c_fabase to select only dependency_status from ISIR.Other details
--                             are derived from igf_sl_gen.get_person_details
-----------------------------------------------------------------------------------
--  ugummall   23-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                             Modified the cursor cur_loan_details to include the clause which
--                             filter only the loans having the school id matched with parameter p_school_code.
-----------------------------------------------------------------------------------
--  ugummall   17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
--                             1. Added two new parameters to dl_originate process.
--                             2. Passed the parameter p_school_code to DLHeader_cur
--                                as extra parameter
--                             3. Processed only those students whose associated org unit
--                                has an alternate identifier of Direct Loan School Code and it
--                                is matching with the supplied p_school_code parameter.
-----------------------------------------------------------------------------------
--  sjadhav    7-Oct-2003      Bug 3104228 FA 122 Added cur loan details loop
--                             Removed ref to obsolete columns
-----------------------------------------------------------------------------------
--  bkkumar    06-oct-2003     Bug 3104228 FA 122 Loans Enhancements
--                             a) Impact of adding the relationship_cd
--                             in igf_sl_lor_all table and obsoleting
--                             BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                             GUARANTOR_ID, DUNS_GUARNT_ID,
--                             LENDER_ID, DUNS_LENDER_ID
--                             LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                             RECIPIENT_TYPE,DUNS_RECIP_ID
--                             RECIP_NON_ED_BRC_ID columns.
--                             b) Also the DUNS_BORW_LENDER_ID
--                             DUNS_GUARNT_ID
--                             DUNS_LENDER_ID
--                             DUNS_RECIP_ID columns are osboleted from the
--                             igf_sl_lor_loc_all table.
-----------------------------------------------------------------------------------
--  bkkumar    30-sep-2003     Bug 3104228 FA 122 Loans Enhancements
--                             Changed the cursor c_tbh_cur
--                             containing igf_sl_lor_dtls_v with simple
--                             joins and got the details of student and parent
--                             from igf_sl_gen.get_person_details.
--                             Added the debugging log messages.
--                             OBSOLETED FIELDS ::
--                             A) Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                             cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                             p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                             chg_batch_id,appl_send_error_codes from igf_sl_lor
--                             B) Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                             cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                             p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                             chg_batch_id from igf_sl_lor_loc
--------------------------------------------------------------------------------------------------
--   gmuralid   03-07-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
--                            Added legacy record flag as parameter to
--                            igf_sl_loans_pkg
-----------------------------------------------------------------------------------
--   sjadhav    26-Mar-2003      Bug 2863960
--                               Modified routine to populate disb gross
--                               amount in the igf_sl_awd_disb_loc table with
--                               disb accepted amount
-----------------------------------------------------------------------------------
--   masehgal   # 2593215        removed begin/end dates fetching functions
--                               used procedure get_acad_cal_dtls instead
-----------------------------------------------------------------------------------
--   mesriniv   1-jul-2002       Added code for inserting Student Phone/Parent Phone.
-----------------------------------------------------------------------------------
--   mesriniv   21-jun-2002      Bug :- 2426609 SSN Format  Incorrect in Output File
--                               While inserting Student SSN/Parent SSN
--                               formatting and substr of 9 chars is done.
-----------------------------------------------------------------------------------
--   mesriniv   23-APR-2002      Bug No:2332668 Desc:LOAN ORIGINATION PROCESS NOT
--                               RUNNING SUCCESSFULLY.
--                               Added code to display the Parameters Passed
-----------------------------------------------------------------------------------
--   agairola   15-Mar-2002      Modified the Update Row call of the IGF_SL_LOANS_PKG
--                               to include Borrower Determination as part of
--                               Refunds 2144600
-----------------------------------------------------------------------------------
--   adhawan    19th feb 2002    Bug:2216956
--                               added elec_mpn_ind , borr_sign_ind ,
--                               stud_sign_ind, borr_credit_auth_code
--                               in the call to igf_sl_lor tbh
-----------------------------------------------------------------------------------
--
   lv_cal_type       igs_ca_inst.cal_type%TYPE;
   lv_cal_seq_num    igs_ca_inst.sequence_number%TYPE;
   lv_dl_version     igf_lookups_view.lookup_code%TYPE;
   lv_dbth_id        igf_sl_dl_batch.dbth_id%TYPE;
   lv_batch_id       igf_sl_dl_batch.batch_id%TYPE;
   lv_mesg_class     igf_sl_dl_batch.message_class%TYPE;

   lv_data_record    VARCHAR2(4000);
   lv_data_header_record VARCHAR2(4000);

   lv_orig_award_id  igf_aw_award.award_id%TYPE;
   lv_orig_loan_id   igf_sl_loans.loan_id%TYPE;
   lv_orig_loan_num  igf_sl_loans.loan_number%TYPE;
   lv_num_of_rec     NUMBER := 0;
   lv_acad_begin_dt  igs_ca_inst.start_dt%TYPE := NULL;
   lv_acad_end_dt    igs_ca_inst.end_dt%TYPE := NULL;
   l_i               NUMBER(1);
   l_alternate_code  igs_ca_inst.alternate_code%TYPE;
   l_display         VARCHAR2(1) := 'N';

   -- masehgal     # 2593215   added variables to retrieve values
   lv_acad_cal_type  igs_ps_ofr_inst.cal_type%TYPE := NULL;
   lv_acad_seq_num   igs_ps_ofr_inst.ci_sequence_number%TYPE := NULL;
   lv_message        VARCHAR2(100) := NULL ;

   TYPE l_parameters IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
   l_para_rec l_parameters;


   -- REF Cursor Record Types.
   Header_Rec        igf_sl_dl_record.DLHeaderType;
   Orig_Rec          igf_sl_dl_record.DLOrigType;
   Trailer_Rec       igf_sl_dl_record.DLTrailerType;


   lv_loan_id        igf_sl_loans.loan_id%TYPE;
   lv_bool           BOOLEAN;
   no_loan_data      EXCEPTION;
   yr_full_participant  EXCEPTION;

   CURSOR cur_loan_details (
                cp_cal_type         igs_ca_inst.cal_type%TYPE,
                cp_seq_number       igs_ca_inst.sequence_number%TYPE,
                cp_fed_fund_1       igf_aw_fund_cat.fed_fund_code%TYPE,
                cp_fed_fund_2       igf_aw_fund_cat.fed_fund_code%TYPE,
                cp_loan_status      igf_sl_loans.loan_status%TYPE,
                cp_active           igf_sl_loans.active%TYPE,
                cp_dl_loan_number   igf_sl_loans.loan_number%TYPE
                )
   IS
   SELECT
    loans.loan_number,
    fabase.base_id
   FROM
    igf_sl_loans       loans,
    igf_sl_lor         lor,
    igf_aw_award       awd,
    igf_aw_fund_mast   fmast,
    igf_aw_fund_cat    fcat,
    igf_ap_fa_base_rec fabase,
    igf_ap_isir_matched isr
   WHERE
    fabase.ci_cal_type        = cp_cal_type     AND
    fabase.ci_sequence_number = cp_seq_number   AND
    fabase.base_id            = awd.base_id     AND
    awd.fund_id               = fmast.fund_id   AND
    fabase.base_id            = isr.base_id     AND
--    fabase.payment_isir_id    = isr.isir_id     AND
    isr.payment_isir          = 'Y'             AND
    isr.system_record_type    = 'ORIGINAL'      AND
    fmast.fund_code           = fcat.fund_code  AND
    (fcat.fed_fund_code       = cp_fed_fund_1   OR    fcat.fed_fund_code =  cp_fed_fund_2) AND
    loans.award_id            = awd.award_id    AND
    loans.loan_number         LIKE NVL(cp_dl_loan_number,loans.loan_number) AND
    loans.loan_id             = lor.loan_id     AND
    loans.loan_status         = cp_loan_status  AND
    loans.active              = cp_active       AND
    substr(loans.loan_number, 13, 6) = p_school_code;

    loan_details_rec cur_loan_details%ROWTYPE;

   l_fed_fund_1 igf_aw_fund_cat.fed_fund_code%TYPE;
   l_fed_fund_2 igf_aw_fund_cat.fed_fund_code%TYPE;


   CURSOR c_loans IS
    SELECT  loan.loan_id
    FROM    igf_sl_loans_all loan,
            igf_aw_award_all awd,
            igf_aw_fund_mast_all fmast,
            igf_aw_fund_cat_all fcat
    WHERE
            loan.award_id = awd.award_id AND
            awd.fund_id = fmast.fund_id AND
            fcat.fund_code = fmast.fund_code AND
            fmast.ci_cal_type = lv_cal_type AND
            fmast.ci_sequence_number = lv_cal_seq_num AND
            loan.loan_number LIKE DECODE(p_loan_number, NULL, '%', p_loan_number) AND
            fcat.fed_fund_code in
            (SELECT lookup_code FROM igf_lookups_view
             WHERE lookup_type = decode(p_dl_loan_catg,
                                        'DL_STAFFORD', 'IGF_SL_DL_STAFFORD',
                                         'DL_PLUS', 'IGF_SL_DL_PLUS') AND
                   enabled_flag = 'Y') AND
            loan.loan_status = 'V' AND     -- "Valid and Ready to Send"
            loan.active = 'Y';

--Cursor to fetch the Meaning for displaying parameters passed
--Used UNION ALL here since individual select clauses
--have the same cost
--Bug 2332668

CURSOR cur_get_parameters IS
SELECT meaning FROM igf_lookups_view
WHERE  lookup_type='IGF_SL_DL_LOAN_CATG' AND lookup_code=p_dl_loan_catg AND enabled_flag = 'Y'

UNION ALL

SELECT  meaning FROM igf_lookups_view
WHERE  lookup_type='IGF_GE_PARAMETERS' AND lookup_code IN ('AWARD_YEAR','LOAN_CATG','LOAN_ID','PARAMETER_PASS') AND enabled_flag = 'Y';

--Cursor to get the alternate code for the calendar instance
--Bug 2332668
CURSOR cur_alternate_code IS
SELECT ca.alternate_code FROM igs_ca_inst ca
WHERE  ca.cal_type =lv_cal_type
AND    ca.sequence_number = lv_cal_seq_num;

-- Get the details of school meaning from lookups to print in the log file
CURSOR c_get_sch_code IS
  SELECT meaning
    FROM igs_lookups_view
   WHERE lookup_type = 'OR_SYSTEM_ID_TYPE'
     AND lookup_code = 'DL_SCH_CD'
     AND enabled_flag = 'Y';
  c_get_sch_code_rec c_get_sch_code%ROWTYPE;

BEGIN

  retcode := 0;
  igf_aw_gen.set_org_id(p_org_id);
  lv_cal_type    := rtrim(substr(p_award_year,1,10));
  lv_cal_seq_num := rtrim(substr(p_award_year,11));

 -- Check whether the award year is full participant
   IF  (igf_sl_dl_validation.check_full_participant (lv_cal_type, lv_cal_seq_num,'DL') ) THEN
     -- Log an error message
      fnd_message.set_name('IGF','IGF_SL_COD_NO_ORIG');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
        raise yr_full_participant;
    END IF;


  --Get the alternate code
  OPEN cur_alternate_code;
  FETCH cur_alternate_code INTO l_alternate_code;
  IF cur_alternate_code%NOTFOUND THEN
     CLOSE cur_alternate_code;
     fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
     IGS_GE_MSG_STACK.ADD;
     fnd_file.put_line(fnd_file.log,fnd_message.get);

     app_exception.raise_exception;
   END IF;
     CLOSE cur_alternate_code;

  --Write the details of Parameters Passed into LOG File.
  --Bug 2332668
    l_i:=0;
    OPEN cur_get_parameters;
     LOOP
      l_i:=l_i+1;
     FETCH cur_get_parameters INTO l_para_rec(l_i);
     EXIT WHEN cur_get_parameters%NOTFOUND;
     END LOOP;
     CLOSE cur_get_parameters;

     OPEN c_get_sch_code; FETCH c_get_sch_code INTO c_get_sch_code_rec; CLOSE c_get_sch_code;

        --Show the parameters passed
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(5),50,' '));
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(2),50,' ')||':'||RPAD(' ',4,' ')||l_alternate_code);
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(3),50,' ')||':'||RPAD(' ',4,' ')||l_para_rec(1));
        IF (p_loan_number IS NOT NULL) THEN
          fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(4),50,' ')||':'||RPAD(' ',4,' ')||p_loan_number);
        END IF;
        fnd_file.put_line(fnd_file.log,RPAD(c_get_sch_code_rec.meaning,50,' ')||':'||RPAD(' ',4,' ')||p_school_code);

  -- Get the Direct Loan File Spec Version
  --Bug :-2490289 DL Header and Trailer Formatting Error.
  --Handled the NO_DATA_FOUND exception if the DL Setup record
  --is not available
  BEGIN

          lv_dl_version := igf_sl_gen.get_dl_version(lv_cal_type, lv_cal_seq_num);

          EXCEPTION
          WHEN NO_DATA_FOUND THEN

          fnd_message.set_name('IGF','IGF_DB_DL_VERSION_FALSE');
          fnd_file.put_line(fnd_file.log,fnd_message.get);

          RAISE NO_DATA_FOUND;
 END;


  -- Validate the Loans, with Status "Ready to Send" before origination.
  -- If the Loan is Valid, then dl_lar_validate procedure will set the Loan to
  -- an intermediate status "Valid and Ready to Send". These records only be
  -- Originated. Further, if any exception occurs while processing, then
  -- this intermadiate status needs to be rolledback.

  lv_bool := igf_sl_dl_validation.dl_lar_validate(lv_cal_type, lv_cal_seq_num,
                                                  p_dl_loan_catg, p_loan_number, 'JOB', p_school_code);


  -- Create an origination File only if there are ACTIVE loan records
  -- with Status="Valid and Ready to Send".
  OPEN c_loans;
  FETCH c_loans INTO lv_loan_id;
  IF c_loans%NOTFOUND THEN
      CLOSE c_loans;
      RAISE no_loan_data;
  END IF;
  CLOSE c_loans;


  -- Initialise the Data Record field
  lv_data_record := NULL;
  lv_data_header_record := NULL;


  -- Using REF CURSORS.
  -- Header Record specifications, for each Direct Loan Version
  -- is specified in the igf_sl_dl_record.DLHeader_cur procedure.
  -- By calling this procedure, the following are done
  --   1. Computes Batch ID
  --   2. Inserts the Batch ID details in igf_sl_dl_batch
  --   3. For the specified version, Opens a REF CURSOR, having
  --      header file Specs.
  igf_sl_dl_record.DLHeader_cur(lv_dl_version, p_dl_loan_catg,
                                lv_cal_type, lv_cal_seq_num, 'DL_ORIG_SEND', p_school_code,
                                lv_dbth_id, lv_batch_id, lv_mesg_class, Header_Rec);
  FETCH Header_Rec into lv_data_header_record;
  IF Header_Rec%NOTFOUND THEN
     fnd_message.set_name ('IGF', 'IGF_GE_HDR_CREATE_ERROR');
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END IF;

-- FA 122 Debug log messages
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_orig.dl_originate.debug','loan_number passed to igf_sl_dl_record.get_acad_cal_dtls:'|| p_loan_number);
    END IF;
  -- Get Academic Dates for the Award Year.
  -- masehgal   # 2593215   removed begin/end dates fetching functions
  --                       used procedure get_acad_cal_dtls instead
  igf_sl_dl_record.get_acad_cal_dtls ( p_loan_number,
                                       lv_acad_cal_type,
                                       lv_acad_seq_num,
                                       lv_acad_begin_dt,
                                       lv_acad_end_dt,
                                       lv_message ) ;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_orig.dl_originate.debug','lv_message got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_message);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_orig.dl_originate.debug','lv_acad_begin_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_begin_dt);
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_orig.dl_originate.debug','lv_acad_end_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_end_dt);
    END IF;

  -- Opening REF Cursor for Transaction Record specification

  IF p_dl_loan_catg = 'DL_STAFFORD' THEN
    l_fed_fund_1 := 'DLS';
    l_fed_fund_2 := 'DLU';
  ELSIF p_dl_loan_catg = 'DL_PLUS' THEN
    l_fed_fund_1 := 'DLP';
    l_fed_fund_2 := 'DLP';
  END IF;

  FOR  loan_details_rec IN  cur_loan_details(lv_cal_type,lv_cal_seq_num,l_fed_fund_1,l_fed_fund_2,'V','Y',p_loan_number)
  LOOP

    igf_sl_dl_record.DLOrig_cur(lv_dl_version,  p_dl_loan_catg,
                                lv_cal_type,    lv_cal_seq_num, loan_details_rec.loan_number,
                                lv_batch_id,    p_school_code,     Orig_Rec);
          LOOP
              -- Initialise the Data Record field
              lv_data_record := NULL;

              FETCH Orig_Rec INTO lv_orig_award_id, lv_orig_loan_id,
                              lv_orig_loan_num, lv_data_record;
              IF Orig_Rec%NOTFOUND THEN
                  -- If all the Transaction records are written to the File, then Exit.
                  EXIT;
              END IF;

              IF (substr(lv_data_record, 13, 6) = p_school_code) THEN
                lv_num_of_rec := lv_num_of_rec + 1;
                IF(lv_num_of_rec = 1)THEN
                  -- Write the Header Record into the Output file only there is atleast one record to process
                  -- write header only once.
                  fnd_file.put_line(FND_FILE.OUTPUT, lv_data_header_record);
                END IF;

                -- Write the Transaction Record into the Output File.
                fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);



                -- Delete this loan record in IGF_SL_LOR_LOC
                DECLARE
                    lv_row_id  VARCHAR2(25);
                    CURSOR c_tbh_cur IS
                    SELECT row_id row_id FROM igf_sl_lor_loc
                    WHERE loan_id = lv_orig_loan_id FOR UPDATE OF igf_sl_lor_loc.sch_cert_date NOWAIT;
                BEGIN
                    FOR tbh_rec in c_tbh_cur LOOP
                      igf_sl_lor_loc_pkg.delete_row (tbh_rec.row_id);
                    END LOOP;
                END;

                -- Delete this loan record in IGF_SL_AWD_DISB_LOC.
                DECLARE
                    lv_row_id  VARCHAR2(25);
                    CURSOR c_tbh_cur IS
                    SELECT row_id row_id FROM igf_sl_awd_disb_loc
                    WHERE award_id = lv_orig_award_id FOR UPDATE OF igf_sl_awd_disb_loc.disb_date NOWAIT;
                BEGIN
                    FOR tbh_rec in c_tbh_cur LOOP
                      igf_sl_awd_disb_loc_pkg.delete_row (tbh_rec.row_id);
                    END LOOP;
                END;


                -- Insert the Origination Data being sent to LOC, into "_LOC" tables
                DECLARE

                    lv_row_id  VARCHAR2(25);
                    lv_base_id igf_ap_fa_base_rec.base_id%TYPE;

                    student_dtl_cur igf_sl_gen.person_dtl_cur;
                    parent_dtl_cur  igf_sl_gen.person_dtl_cur;
                    student_dtl_rec  igf_sl_gen.person_dtl_rec;
                    parent_dtl_rec   igf_sl_gen.person_dtl_rec;

      -- FA 122 Loan Enhancements added this cursor to remove the cursor based on the obsolete view igf_sl_lor_dtls_v

                    CURSOR c_tbh_cur IS
                    SELECT loans.rowid row_id,
                     loans.loan_id,
                     loans.loan_number,
                     loans.award_id,
                     awd.offered_amt,
                     awd.accepted_amt,
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
                     lor.lend_non_ed_brc_id,
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
                     fabase.person_id student_id,
                     fabase.base_id,
                     fmast.fund_code loan_type,
                     lor.interest_rebate_percent_num,
                    lor.cps_trans_num,
                    lor.atd_entity_id_txt,
                    lor.rep_entity_id_txt,
                    lor.crdt_decision_status,
                    lor.note_message,
                    lor.book_loan_amt,
                    lor.book_loan_amt_date,
                    lor.pymt_servicer_amt,
                    lor.pymt_servicer_date,
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
		    lor.b_alien_reg_num_txt,
                    lor.esign_src_typ_cd,
                    lor.acad_begin_date,
                    lor.acad_end_date
                    FROM igf_sl_loans_all loans,
                    igf_sl_lor_all lor,
                    igf_aw_award_all  awd,
                    igf_ap_fa_base_rec_all fabase,
                    igf_aw_fund_mast_all fmast
                    WHERE loans.loan_id = lv_orig_loan_id
                    AND   loans.loan_id = lor.loan_id
                    AND   loans.award_id = awd.award_id
                    AND   awd.base_id = fabase.base_id
                    AND   fmast.fund_id = awd.fund_id;

                    CURSOR c_fabase IS
                    SELECT isr.dependency_status     dependency_status
                    FROM IGF_AP_FA_BASE_REC fabase,
                         IGF_AP_ISIR_MATCHED isr
                    WHERE
                        fabase.base_id   = isr.base_id
                        AND isr.payment_isir = 'Y'
                        AND isr.system_record_type = 'ORIGINAL'
                        AND fabase.base_id = lv_base_id;

                    -- Get the Student Phone
                    CURSOR cur_get_s_phone IS select
                    DECODE(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(lv_base_id)),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(lv_base_id)),10,0))
                    FROM DUAL;

                    -- Get the Parent Phone
                    CURSOR cur_get_p_phone(p_per_id igf_ap_fa_base_rec.person_id%TYPE) IS
                    SELECT DECODE(igf_sl_gen.get_person_phone(p_per_id),'N/A',LPAD(' ',10,' '),LPAD(igf_sl_gen.get_person_phone(p_per_id),10,0))
                    FROM DUAL;

                    l_p_phone VARCHAR2(80);
                    l_s_phone VARCHAR2(80);

                    c_fabase_rec     c_fabase%ROWTYPE;

                BEGIN
                  FOR tbh_rec in c_tbh_cur LOOP

                   -- FA 122 Loan Enhancements Use the igf_sl_gen.get_person_details for getting the student as
                   -- well as parent details.
                   -- get the student details
                   igf_sl_gen.get_person_details(tbh_rec.student_id,student_dtl_cur);
                   FETCH student_dtl_cur INTO student_dtl_rec;

                   -- get the parent details
                   igf_sl_gen.get_person_details(tbh_rec.p_person_id,parent_dtl_cur);
                   FETCH parent_dtl_cur INTO parent_dtl_rec;

                   CLOSE student_dtl_cur;
                   CLOSE parent_dtl_cur;

                    lv_base_id := tbh_rec.base_id;

                    --Removed the RAISE for NO_DATA_FOUND as it is not required .
                    --If there were no ISIR Matched then the DL Validation Process would make the Loan Status as
                    ---Not Ready
                    --Bug :-2490289 DL Header and Trailer Formatting Error.
                    -- Get Additional Information from FABASE Record.
                    OPEN c_fabase;
                    FETCH c_fabase INTO c_fabase_rec;
                    CLOSE c_fabase;


                    l_p_phone:=NULL;
                    l_s_phone:=NULL;
                    IF  p_dl_loan_catg='DL_STAFFORD' THEN
                        OPEN cur_get_s_phone;
                        FETCH cur_get_s_phone INTO l_s_phone;
                        CLOSE cur_get_s_phone;
                    ELSIF p_dl_loan_catg='DL_PLUS' THEN
                        OPEN cur_get_p_phone(tbh_rec.p_person_id);
                        FETCH cur_get_p_phone INTO l_p_phone;
                        CLOSE cur_get_p_phone;

                    END IF;

               -- FA 122 Loan Enhancemnets inserted the obsolted fields with NULL
               -- student details fetched from student_dtl_rec
               -- parent details fetched from parent_dtl_rec

                    igf_sl_lor_loc_pkg.insert_row (
                      X_Mode                              => 'R',
                      x_rowid                             => lv_row_id,
                      x_loan_id                           => tbh_rec.loan_id,
                      x_origination_id                    => tbh_rec.origination_id,
                      x_loan_number                       => tbh_rec.loan_number,
                      x_loan_type                         => tbh_rec.loan_type,
                      x_loan_amt_offered                  => tbh_rec.offered_amt ,
                      x_loan_amt_accepted                 => tbh_rec.accepted_amt ,
                      x_loan_per_begin_date               => tbh_rec.loan_per_begin_date,
                      x_loan_per_end_date                 => tbh_rec.loan_per_end_date,
                      x_acad_yr_begin_date                => lv_acad_begin_dt,
                      x_acad_yr_end_date                  => lv_acad_end_dt,
                      x_loan_status                       => tbh_rec.loan_status,
                      x_loan_status_date                  => tbh_rec.loan_status_date,
                      x_loan_chg_status                   => tbh_rec.loan_chg_status,
                      x_loan_chg_status_date              => tbh_rec.loan_chg_status_date,
                      x_req_serial_loan_code              => tbh_rec.req_serial_loan_code,
                      x_act_serial_loan_code              => tbh_rec.act_serial_loan_code,
                      x_active                            => tbh_rec.active,
                      x_active_date                       => tbh_rec.active_date,
                      x_sch_cert_date                     => tbh_rec.sch_cert_date,
                      x_orig_status_flag                  => tbh_rec.orig_status_flag,
                      x_orig_batch_id                     => tbh_rec.orig_batch_id,
                      x_orig_batch_date                   => tbh_rec.orig_batch_date,
                      x_chg_batch_id                      => NULL,
                      x_orig_ack_date                     => tbh_rec.orig_ack_date,
                      x_credit_override                   => tbh_rec.credit_override,
                      x_credit_decision_date              => tbh_rec.credit_decision_date,
                      x_pnote_delivery_code               => tbh_rec.pnote_delivery_code,
                      x_pnote_status                      => tbh_rec.pnote_status,
                      x_pnote_status_date                 => tbh_rec.pnote_status_date,
                      x_pnote_id                          => tbh_rec.pnote_id,
                      x_pnote_print_ind                   => tbh_rec.pnote_print_ind,
                      x_pnote_accept_amt                  => tbh_rec.pnote_accept_amt,
                      x_pnote_accept_date                 => tbh_rec.pnote_accept_date,
                      x_p_signature_code                  => tbh_rec.p_signature_code,
                      x_p_signature_date                  => tbh_rec.p_signature_date,
                      x_s_signature_code                  => tbh_rec.s_signature_code,
                      x_unsub_elig_for_heal               => tbh_rec.unsub_elig_for_heal,
                      x_disclosure_print_ind              => tbh_rec.disclosure_print_ind,
                      x_orig_fee_perct                    => tbh_rec.orig_fee_perct,
                      x_borw_confirm_ind                  => tbh_rec.borw_confirm_ind,
                      x_borw_interest_ind                 => tbh_rec.borw_interest_ind,
                      x_unsub_elig_for_depnt              => tbh_rec.unsub_elig_for_depnt,
                      x_guarantee_amt                     => tbh_rec.guarantee_amt,
                      x_guarantee_date                    => tbh_rec.guarantee_date,
                      x_guarnt_adj_ind                    => tbh_rec.guarnt_adj_ind,
                      x_guarnt_amt_redn_code              => tbh_rec.guarnt_amt_redn_code,
                      x_guarnt_status_code                => tbh_rec.guarnt_status_code,
                      x_guarnt_status_date                => tbh_rec.guarnt_status_date,
                      x_lend_apprv_denied_code            => NULL,
                      x_lend_apprv_denied_date            => NULL,
                      x_lend_status_code                  => tbh_rec.lend_status_code,
                      x_lend_status_date                  => tbh_rec.lend_status_date,
                      x_grade_level_code                  => tbh_rec.grade_level_code,
                      x_enrollment_code                   => tbh_rec.enrollment_code,
                      x_anticip_compl_date                => tbh_rec.anticip_compl_date,
                      x_borw_lender_id                    => NULL,
                      x_duns_borw_lender_id               => NULL,
                      x_guarantor_id                      => NULL,
                      x_duns_guarnt_id                    => NULL,
                      x_prc_type_code                     => tbh_rec.prc_type_code,
                      x_rec_type_ind                      => tbh_rec.rec_type_ind,
                      x_cl_loan_type                      => tbh_rec.cl_loan_type,
                      x_cl_seq_number                     => tbh_rec.cl_seq_number,
                      x_last_resort_lender                => tbh_rec.last_resort_lender,
                      x_lender_id                         => NULL,
                      x_duns_lender_id                    => NULL,
                      x_lend_non_ed_brc_id                => NULL,
                      x_recipient_id                      => NULL,
                      x_recipient_type                    => NULL,
                      x_duns_recip_id                     => NULL,
                      x_recip_non_ed_brc_id               => NULL,
                      x_cl_rec_status                     => NULL,
                      x_cl_rec_status_last_update         => NULL,
                      x_alt_prog_type_code                => tbh_rec.alt_prog_type_code,
                      x_alt_appl_ver_code                 => tbh_rec.alt_appl_ver_code,
                      x_borw_outstd_loan_code             => tbh_rec.borw_outstd_loan_code,
                      x_mpn_confirm_code                  => NULL,
                      x_resp_to_orig_code                 => tbh_rec.resp_to_orig_code,
                      x_appl_loan_phase_code              => NULL,
                      x_appl_loan_phase_code_chg          => NULL,
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
                      x_p_ssn                             => parent_dtl_rec.p_ssn,
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
                      x_p_permt_phone                     => l_p_phone,
                      x_p_email_addr                      => parent_dtl_rec.p_email_addr,
                      x_p_date_of_birth                   => parent_dtl_rec.p_date_of_birth,
                      x_p_dob_chg_date                    => NULL,
                      x_p_license_num                     => parent_dtl_rec.p_license_num,
                      x_p_license_state                   => parent_dtl_rec.p_license_state,
                      x_p_citizenship_status              => parent_dtl_rec.p_citizenship_status,
                      x_p_alien_reg_num                   => parent_dtl_rec.p_alien_reg_num,
                      x_p_default_status                  => tbh_rec.p_default_status,
                      x_p_foreign_postal_code             => NULL,
                      x_p_state_of_legal_res              => parent_dtl_rec.p_state_of_legal_res,
                      x_p_legal_res_date                  => parent_dtl_rec.p_legal_res_date,
                      x_s_ssn                             => student_dtl_rec.p_ssn,
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
                      x_s_permt_phone                     => l_s_phone,
                      x_s_local_addr1                     => student_dtl_rec.p_local_addr1,
                      x_s_local_addr2                     => student_dtl_rec.p_local_addr2,
                      x_s_local_city                      => student_dtl_rec.p_local_city,
                      x_s_local_state                     => student_dtl_rec.p_local_state,
                      x_s_local_zip                       => student_dtl_rec.p_local_zip,
                      x_s_local_addr_chg_date             => NULL,
                      x_s_email_addr                      => student_dtl_rec.p_email_addr,
                      x_s_date_of_birth                   => student_dtl_rec.p_date_of_birth,
                      x_s_dob_chg_date                    => NULL,
                      x_s_license_num                     => student_dtl_rec.p_license_num,
                      x_s_license_state                   => student_dtl_rec.p_license_state,
                      x_s_depncy_status                   => c_fabase_rec.dependency_status,
                      x_s_default_status                  => tbh_rec.s_default_status,
                      x_s_citizenship_status              => student_dtl_rec.p_citizenship_status,
                      x_s_alien_reg_num                   => student_dtl_rec.p_alien_reg_num,
                      x_s_foreign_postal_code             => NULL,
                      x_pnote_batch_id                    => tbh_rec.pnote_batch_id,
                      x_pnote_ack_date                    => tbh_rec.pnote_ack_date,
                      x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind,
   --Added fields
                      x_award_id                          => tbh_rec.award_id,
                      x_base_id                           => tbh_rec.base_id,
                      x_document_id_txt                   => NULL,
                      x_loan_key_num                      => NULL,
                      x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num,
                      x_fin_award_year                    => NULL,
                      x_cps_trans_num                     => tbh_rec.cps_trans_num,
                      x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt,
                      x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt,
                      x_source_entity_id_txt              => NULL,
                      x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt,
                      x_pymt_servicer_date                => tbh_rec.pymt_servicer_date,
                      x_book_loan_amt                     => tbh_rec.book_loan_amt,
                      x_book_loan_amt_date                => tbh_rec.book_loan_amt_date,
                      x_s_chg_birth_date                  => NULL,
                      x_s_chg_ssn                         => NULL,
                      x_s_chg_last_name                   => NULL,
                      x_b_chg_birth_date                  => NULL,
                      x_b_chg_ssn                         => NULL,
                      x_b_chg_last_name                   => NULL,
                      x_note_message                      => tbh_rec.note_message,
                      x_full_resp_code                    => NULL,
                      x_s_permt_county                    => NULL,
                      x_b_permt_county                    => NULL,
                      x_s_permt_country                   => NULL,
                      x_b_permt_country                   => NULL,
                      x_crdt_decision_status              => tbh_rec.crdt_decision_status,
                      x_external_loan_id_txt              => tbh_rec.external_loan_id_txt,
                      x_deferment_request_code            => tbh_rec.deferment_request_code,
                      x_eft_authorization_code            => tbh_rec.eft_authorization_code,
                      x_requested_loan_amt                => tbh_rec.requested_loan_amt,
                      x_actual_record_type_code           => tbh_rec.actual_record_type_code,
                      x_reinstatement_amt                 => tbh_rec.reinstatement_amt,
                      x_lender_use_txt                    => tbh_rec.lender_use_txt,
                      x_guarantor_use_txt                 => tbh_rec.guarantor_use_txt,
                      x_fls_approved_amt                  => tbh_rec.fls_approved_amt,
                      x_flu_approved_amt                  => tbh_rec.flu_approved_amt,
                      x_flp_approved_amt                  => tbh_rec.flp_approved_amt,
                      x_alt_approved_amt                  => tbh_rec.alt_approved_amt,
                      x_loan_app_form_code                => tbh_rec.loan_app_form_code,
                      x_alt_borrower_ind_flag             => NULL,
                      x_school_id_txt                     => NULL,
                      x_cost_of_attendance_amt            => NULL,
                      x_established_fin_aid_amount        => NULL,
                      x_student_electronic_sign_flag      => NULL,
                      x_mpn_type_flag                     => NULL,
                      x_school_use_txt                    => tbh_rec.school_use_txt,
                      x_expect_family_contribute_amt      => NULL,
                      x_borower_electronic_sign_flag      => NULL,
                      x_borower_credit_authoriz_flag      => NULL,
		      x_esign_src_typ_cd                  => NULL

                    );


                  END LOOP;
                END;


                -- Insert the Origination Data being sent to LOC, into "_LOC" tables
                DECLARE
                    lv_row_id  VARCHAR2(25);
                    CURSOR c_tbh_cur IS
                    SELECT * FROM igf_aw_awd_disb
                    WHERE award_id = lv_orig_award_id;
                BEGIN
                  FOR tbh_rec in c_tbh_cur LOOP
                    igf_sl_awd_disb_loc_pkg.insert_row (
                      X_Mode                              => 'R',
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

                IF l_display <> 'Y' THEN
                   --Display mesg in LOG File that Records have been originated and an Output file has been created.
                   fnd_file.new_line(fnd_file.log,2);
                   fnd_message.set_name('IGF','IGF_SL_LOAN_ORIGINATED');
                   fnd_message.set_token('LOAN_CATEG',l_para_rec(1));
                   fnd_message.set_token('FILE_VERSION',lv_dl_version);
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                   fnd_file.new_line(fnd_file.log,2);
                   l_display :='Y';
                END IF;


                -- Update LOAN_STATUS, LOAN_STATUS_DATE to SENT, Current Date
                DECLARE
                    lv_row_id  VARCHAR2(25);
                    CURSOR c_tbh_cur IS
                    SELECT igf_sl_loans.* FROM igf_sl_loans
                    WHERE loan_id = lv_orig_loan_id FOR UPDATE OF igf_sl_loans.loan_status NOWAIT;
                BEGIN
                  FOR tbh_rec in c_tbh_cur LOOP

          -- Modified the update row call to include the Borrower Determination as part of
          -- Refunds DLD 2144600
                    igf_sl_loans_pkg.update_row (
                      X_Mode                              => 'R',
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

                  END LOOP;
                END;

                -- Update the BATCH ID and BATCH_DATE
                DECLARE
                    lv_row_id  VARCHAR2(25);
                    CURSOR c_tbh_cur IS
                    SELECT igf_sl_lor.* FROM igf_sl_lor
                    WHERE loan_id = lv_orig_loan_id FOR UPDATE OF igf_sl_lor.sch_cert_date NOWAIT;
                BEGIN

                 -- FA 122 Loan Enhancemnets updated the obsolted fields with NULL

                  FOR tbh_rec in c_tbh_cur LOOP
                    igf_sl_lor_pkg.update_row (
                      X_Mode                              => 'R',
                      x_rowid                             => tbh_rec.row_id,
                      x_origination_id                    => tbh_rec.origination_id,
                      x_loan_id                           => tbh_rec.loan_id,
                      x_sch_cert_date                     => tbh_rec.sch_cert_date,
                      x_orig_status_flag                  => tbh_rec.orig_status_flag,
                      x_orig_batch_id                     => lv_batch_id,
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
                      x_lend_non_ed_brc_id                => NULL,
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
                      x_pnote_mpn_ind                     => tbh_rec.pnote_mpn_ind ,
                      x_elec_mpn_ind                      => tbh_rec.elec_mpn_ind         ,
                      x_borr_sign_ind                     => tbh_rec.borr_sign_ind        ,
                      x_stud_sign_ind                     => tbh_rec.stud_sign_ind        ,
                      x_borr_credit_auth_code             => tbh_rec.borr_credit_auth_code ,
                      x_relationship_cd                   => tbh_rec.relationship_cd,
                      x_interest_rebate_percent_num       => tbh_rec.interest_rebate_percent_num,
                      x_cps_trans_num                     => tbh_rec.cps_trans_num,
                      x_atd_entity_id_txt                 => tbh_rec.atd_entity_id_txt ,
                      x_rep_entity_id_txt                 => tbh_rec.rep_entity_id_txt,
                      x_crdt_decision_status              => tbh_rec.crdt_decision_status,
                      x_note_message                      => tbh_rec.note_message,
                      x_book_loan_amt                     => tbh_rec.book_loan_amt ,
                      x_book_loan_amt_date                => tbh_rec.book_loan_amt_date,
                      x_pymt_servicer_amt                 => tbh_rec.pymt_servicer_amt,
                      x_pymt_servicer_date                => tbh_rec.pymt_servicer_date,
                      x_requested_loan_amt                => tbh_rec.requested_loan_amt,
                      x_eft_authorization_code            => tbh_rec.eft_authorization_code,
                      x_external_loan_id_txt              => tbh_rec.external_loan_id_txt,
                      x_deferment_request_code            => tbh_rec.deferment_request_code ,
                      x_actual_record_type_code           => tbh_rec.actual_record_type_code,
                      x_reinstatement_amt                 => tbh_rec.reinstatement_amt,
                      x_school_use_txt                    => tbh_rec.school_use_txt,
                      x_lender_use_txt                    => tbh_rec.lender_use_txt,
                      x_guarantor_use_txt                 => tbh_rec.guarantor_use_txt,
                      x_fls_approved_amt                  => tbh_rec.fls_approved_amt,
                      x_flu_approved_amt                  => tbh_rec.flu_approved_amt,
                      x_flp_approved_amt                  => tbh_rec.flp_approved_amt,
                      x_alt_approved_amt                  => tbh_rec.alt_approved_amt,
                      x_loan_app_form_code                => tbh_rec.loan_app_form_code,
                      x_override_grade_level_code         => tbh_rec.override_grade_level_code,
		      x_b_alien_reg_num_txt               => tbh_rec.b_alien_reg_num_txt,
                      x_esign_src_typ_cd                  => tbh_rec.esign_src_typ_cd,
                      x_acad_begin_date                   => tbh_rec.acad_begin_date,
                      x_acad_end_date                     => tbh_rec.acad_end_date
                    );

                  END LOOP;
                END;
              END IF;
          END LOOP; -- loop for ref cursor records
 END LOOP; -- loop for loan details cursor
  -- Initialise the Data Record field
  lv_data_record := NULL;
  IF(lv_num_of_rec > 0)THEN
     -- Write the Trailer Record
     igf_sl_dl_record.DLTrailer_cur(lv_dl_version, lv_num_of_rec, Trailer_Rec);
     FETCH Trailer_Rec into lv_data_record;
     IF Header_Rec%NOTFOUND THEN
       fnd_message.set_name ('IGF', 'IGF_GE_TRL_CREATE_ERROR');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
     -- Write the Trailer Record into the Output file.
     fnd_file.put_line(FND_FILE.OUTPUT, lv_data_record);
  ELSE
    fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGF','IGF_SL_NO_LOAN_ORIG_DATA'));
--MN 27-Dec-2004  In case there are no records getting generated, the V state will be reverted back.
    ROLLBACK;
  END IF;

COMMIT;

EXCEPTION

    WHEN no_data_found THEN
    NULL;

    WHEN no_loan_data THEN
       -- Please Note that this is NOT an exception. It is a Valid and proper way of
       -- of exiting a process if there is not Data.
       COMMIT;  -- Commit is done here, so that the "Validation reject details" get committed.
       retcode := 0;
       errbuf  := NULL;
       fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGF','IGF_SL_NO_LOAN_ORIG_DATA'));

       WHEN yr_full_participant THEN
        NULL;


    WHEN app_exception.record_lock_exception THEN

       ROLLBACK;

       IF c_loans%ISOPEN THEN
         CLOSE c_loans;
       END IF;

       retcode := 2;
       errbuf  := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
       igs_ge_msg_stack.conc_exception_hndl;

    WHEN OTHERS THEN
       ROLLBACK;
       IF c_loans%ISOPEN THEN
         CLOSE c_loans;
       END IF;
       retcode := 2;
       errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
       fnd_file.put_line(fnd_file.log,SQLERRM);
       igs_ge_msg_stack.conc_exception_hndl;
END dl_originate;


END igf_sl_dl_orig;

/
