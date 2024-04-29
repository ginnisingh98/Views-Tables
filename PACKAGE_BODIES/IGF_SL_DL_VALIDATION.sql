--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_VALIDATION" AS
/* $Header: IGFSL02B.pls 120.7 2006/04/26 06:59:16 rajagupt ship $ */
--------------------------------------------------------------------------
-- museshad     28-Nov-2005      Bug 4116399.
--                               Added Stafford loan limit validation check in
--                               cod_loan_validations() and dl_lar_validate()
--------------------------------------------------------------------------
-- veramach     04-May-2004     bug 3603289
--                              (a) Modified cursor cur_student_licence to select
--                              dependency_status from ISIR. other details are
--                              derived from igf_sl_gen.get_person_details.
--                              (b) Modified logic dl_lar_validate so that the loop
--                              executes whenever called from FORM.
--------------------------------------------------------------------------
-- sjadhav, Jan 26,2002
-- Bug 2154941
-- Modified usages of cur_disb to reflect the completion
-- status of a loan
--
-------------------------------------------------------------------------

p_dl_version     igf_lookups_view.lookup_code%TYPE;
g_loan_id        igf_sl_Loans_all.loan_id%TYPE;
student_dtl_rec  igf_sl_gen.person_dtl_rec;
parent_dtl_rec   igf_sl_gen.person_dtl_rec;

CURSOR  cur_disb(c_award_id  igf_aw_awd_disb.award_id%TYPE) IS
SELECT COUNT(*) disb_count FROM igf_aw_awd_disb_all
WHERE  award_id = c_award_id
AND    (   nvl(disb_gross_amt,0)  <= 0
        OR nvl(fee_1         ,0)  <= 0
        OR nvl(disb_net_amt  ,0)  <= 0);

CURSOR cur_isir(p_base_id igf_ap_fa_base_rec.base_id%TYPE) is
SELECT isr.dependency_status   s_depncy_status
  FROM igf_ap_isir_matched_all  isr
 WHERE isr.base_id            = p_base_id
   AND isr.payment_isir       = 'Y'
   AND isr.system_record_type = 'ORIGINAL';

-- Cursor to get number of disbursements. COD-XML build.
CURSOR cur_get_no_of_disbursements ( cp_award_id igf_aw_awd_disb.award_id%TYPE) IS
SELECT  COUNT(*) disb_count
  FROM  igf_aw_awd_disb_all disb
 WHERE  disb.award_id = cp_award_id;

CURSOR cur_special_school ( cp_cal_type   igf_ap_fa_base_rec.ci_cal_type%TYPE,
                            cp_seq_number igf_ap_fa_base_rec.ci_sequence_number%TYPE) IS
SELECT  dlsetup.special_school
  FROM  igf_sl_dl_setup_all dlsetup
 WHERE  dlsetup.ci_cal_type = cp_cal_type
   AND  dlsetup.ci_sequence_number = cp_seq_number;

CURSOR cur_isir_info (p_base_id NUMBER) IS
SELECT  payment_isir,transaction_num,dependency_status,
        date_of_birth,current_ssn,last_name
  FROM  igf_ap_isir_matched_all
  WHERE base_id      = p_base_id
  AND   payment_isir = 'Y'
  AND   system_record_type = 'ORIGINAL';

CURSOR  cur_loan_at_cod ( cp_loan_number  igf_sl_loans_all.loan_number%TYPE)  IS
  SELECT  'x'
    FROM  igf_sl_lor_loc_history
   WHERE  loan_number = cp_loan_number;

isir_info_rec cur_isir_info%ROWTYPE;


FUNCTION  check_for_reqd(p_loan_number   igf_sl_loans.loan_number%TYPE,
                         p_loan_catg     igf_sl_reqd_fields.loan_type%TYPE,
                         p_field_name    igf_sl_reqd_fields.field_name%TYPE,
                         p_field_value   VARCHAR2
) RETURN BOOLEAN
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  lv_complete    BOOLEAN := TRUE;
  lv_err_type    fnd_lookups.lookup_type%TYPE;
  lv_data_reqd   fnd_lookups.lookup_code%TYPE;
  lv_data_recomm fnd_lookups.lookup_code%TYPE;

  CURSOR cur_reqd IS
  SELECT status from igf_sl_reqd_fields lrf
  WHERE  lrf.spec_version = p_dl_version
  AND    lrf.loan_type    = p_loan_catg
  AND    lrf.field_name   = p_field_name;

BEGIN

  lv_err_type    := 'IGF_SL_ERR_CODES';
  lv_data_reqd   := 'DATA_REQD';
  lv_data_recomm := 'DATA_RECOMM';

  IF p_field_name LIKE '%ADDR%' THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.check_for_reqd.debug','p_field_name = ' ||p_field_name);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.check_for_reqd.debug','p_field_value = ' ||p_field_value);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.check_for_reqd.debug','p_dl_version = ' ||p_dl_version);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.check_for_reqd.debug','p_loan_catg = ' ||p_loan_catg);
    END IF;
  END IF;

  IF TRIM(p_field_value) IS NULL THEN

    FOR irec IN cur_reqd LOOP

      IF irec.status = 'R' THEN
         -- If the Data is required.
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_number, 'V', lv_err_type, lv_data_reqd, p_field_name, p_field_value);

      ELSIF irec.status = 'S' THEN
         -- If the Data is strongly recommended.
         igf_sl_edit.insert_edit(p_loan_number, 'V', lv_err_type, lv_data_recomm, p_field_name, p_field_value);

      END IF;

    END LOOP;

  END IF;

  RETURN lv_complete;

EXCEPTION
WHEN others THEN
   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_dl_validation.check_for_reqd');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END check_for_reqd;

FUNCTION get_system_grade_level(p_base_id             IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_loan_per_begin_date IN  DATE,
                                p_loan_per_end_date   IN  DATE
                               )
RETURN VARCHAR2
IS
  /*************************************************************
  Created By : Uday Kiran Reddy
  Date Created On : May 05, 2005
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who        When         What
  ugummall   05-MAY-2005  Bug 4346421. <STUDENTLEVELCODE> tag in DL Outbound XML showing wrong value.
                          Matching override_grade_level_code/grade_level_code with system value.

  (reverse chronological order - newest change first)
  ***************************************************************/

  CURSOR  cur_get_person_id(cp_base_id NUMBER) IS
    SELECT  person_id
      FROM  IGF_AP_FA_BASE_REC_ALL
     WHERE  base_id = cp_base_id;
  person_id_rec cur_get_person_id%ROWTYPE;

  l_person_id          NUMBER;
  l_class_standing     igs_pr_css_class_std_v.class_standing%TYPE := NULL;
  l_course_cd          VARCHAR2(10);
  l_ver_number         NUMBER;
  l_course_type        igs_ps_ver.course_type%TYPE;
  l_cutoff_date        DATE;
  l_pred_flag          VARCHAR2(1);
  l_dl_std_code        igf_ap_class_std_map.dl_std_code%TYPE;
  l_cl_std_code        igf_ap_class_std_map.cl_std_code%TYPE;

BEGIN

  l_class_standing := NULL;

  OPEN cur_get_person_id (p_base_id);
  FETCH cur_get_person_id INTO person_id_rec;
  CLOSE cur_get_person_id;
  l_person_id := person_id_rec.person_id;

  -- Call generic API get_key_program to get the cource code
  igf_ap_gen_001.get_key_program(p_base_id, l_course_cd, l_ver_number);
  --igs_en_gen_015.get_academic_cal( l_person_id,l_course_cd,l_acad_cal_type,l_acad_seq_num,l_message,NULL);

  l_cutoff_date := TRUNC(SYSDATE);

  --1.  If SYSDATE is before Loan Period Begin Date, then use Predictive Class Standing
  IF l_cutoff_date < p_loan_per_begin_date THEN
    l_pred_flag   := 'Y';
    l_cutoff_date := p_loan_per_begin_date;
  --2.  If SYSDATE is between Loan Period, then use Loan Period Begin Date as Effective Date to derive Grade Level
  ELSIF l_cutoff_date < p_loan_per_end_date THEN
    l_pred_flag   := 'N';
    l_cutoff_date := p_loan_per_begin_date;
  --3.  If SYSDATE is after Loan Period, then use Loan Period Begin Date as Effective Date to derive Grade Level
  ELSE
    l_pred_flag   := 'N';
    l_cutoff_date := p_loan_per_begin_date;
  END IF;

  l_class_standing := igs_pr_get_class_std.get_class_standing(
                                                                l_person_id,
                                                                l_course_cd,
                                                                l_pred_flag,
                                                                l_cutoff_date,
                                                                NULL,
                                                                NULL,'F');
  l_course_type := igf_ap_gen_001.get_enrl_program_type(p_base_id);
  igf_sl_lar_creation.get_dl_cl_std_code(p_base_id,
                                         l_class_standing,
                                         l_course_type,
                                         l_dl_std_code,
                                         l_cl_std_code);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.get_system_grade_level.debug','System Grade Level is : ' || l_dl_std_code || ' - ' || igf_aw_gen.lookup_desc('IGF_AP_GRADE_LEVEL',l_dl_std_code ));
  END IF;

  RETURN l_dl_std_code;

END get_system_grade_level;

PROCEDURE loan_limit_validation (
                                  p_base_id     IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_fund_type   IN          igf_aw_fund_cat.fed_fund_code%TYPE,
                                  p_award_id    IN          igf_aw_award_all.award_id%TYPE,
                                  p_msg_name    OUT NOCOPY  fnd_new_messages.message_name%TYPE
                                )
IS
  /***************************************************************
   Created By        :    museshad
   Date Created By   :    23-Nov-2005
   Purpose           :    Stafford loan limit validation
   Known Limitations,Enhancements or Remarks
   Change History    :
   Who               When      What
 ***************************************************************/
  l_aid   NUMBER;

  CURSOR c_get_dist_plan(cp_award_id  igf_aw_award_all.award_id%TYPE)
  IS
    SELECT adplans_id
    FROM igf_aw_award_all
    WHERE award_id = cp_award_id;

  l_dist_plan_rec c_get_dist_plan%ROWTYPE;

BEGIN
  -- Log IN parameters
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.loan_limit_validation.debug','IN Param p_base_id= ' ||p_base_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.loan_limit_validation.debug','IN Param p_fund_type= ' ||p_fund_type);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.loan_limit_validation.debug','IN Param p_award_id= ' ||p_award_id);
  END IF;

  l_aid := 0;
  p_msg_name := NULL;

  OPEN c_get_dist_plan(p_award_id);
  FETCH c_get_dist_plan INTO l_dist_plan_rec;
  CLOSE c_get_dist_plan;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,
                  'igf.plsql.igf_sl_dl_validation.loan_limit_validation.debug',
                  'Calling check_loan_limits() with parameters l_base_id/fund_type/l_award_id/l_adplans_id/ ' ||p_base_id|| '/' ||p_fund_type|| '/' ||p_award_id|| '/' ||l_dist_plan_rec.adplans_id);
  END IF;

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

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.loan_limit_validation.debug','check_loan_limits() returned with message ' ||p_msg_name);
  END IF;
END loan_limit_validation;

/* MAIN PROCEDURE */
FUNCTION  dl_lar_validate(p_ci_cal_type          igs_ca_inst_all.cal_type%TYPE,
                          p_ci_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                          p_loan_catg            fnd_lookups.lookup_code%TYPE,
                          p_loan_number          igf_sl_loans_all.loan_number%TYPE,
                          p_call_mode            VARCHAR2,
                          p_school_code          VARCHAR2 )
RETURN BOOLEAN
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who        When        What
  museshad   28-Nov-2005  Bug 4116399.
                          Added Stafford loan limit validation check.
  ugummall   22-OCT-2003  Bug 3102439. FA 126 - Multiple FA Offices.
                          added one parameter p_school_code to this function.
  bkkumar    30-sep-2003  Bug 3104228 Changed the cursor cur_loans
                          containing igf_sl_lor_dtls_v with simple
                          joins and got the details of student and parent
                          from igf_sl_gen.get_person_details.
                          Added the debugging log messages.

  gmuralid     3-July-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
                              Added legacy record flag as parameter to
                              igf_sl_loans_pkg

  masehgal   # 2593215   removed begin/end dates fetching functions
                         used procedure get_acad_cal_dtls instead
                         added another validation to report acad cal not found
  agairola        15-Mar-2002     Modified the IGF_SL_LOANS_PKG.UPDATE_ROW call
                                  to include borrower determination as part of
                                  Refunds DLD  2144600

  (reverse chronological order - newest change first)
  ***************************************************************/

    lv_loan_catg            igf_sl_reqd_fields.loan_type%TYPE;
    lv_loan_status          igf_sl_loans_all.loan_status%TYPE;
    lv_s_depncy_status      igf_ap_isir_matched_all.dependency_status%TYPE;
    lv_s_citizenship_status igf_ap_isir_matched_all.citizenship_status%TYPE;
    lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE ;
    lv_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE ;
    lv_acad_begin_date      igs_ca_inst_all.start_dt%TYPE;
    lv_acad_end_date        igs_ca_inst_all.end_dt%TYPE;
    l_status_1              igf_sl_loans_all.loan_status%TYPE;
    l_status_2              igf_sl_loans_all.loan_status%TYPE;
    l_status_3              igf_sl_loans_all.loan_status%TYPE;
    l_fed_fund_1            igf_aw_fund_cat_all.fed_fund_code%TYPE;
    l_fed_fund_2            igf_aw_fund_cat_all.fed_fund_code%TYPE;
    student_dtl_cur         igf_sl_gen.person_dtl_cur;
    parent_dtl_cur          igf_sl_gen.person_dtl_cur;
    lv_message              VARCHAR2(100);
    lv_complete             BOOLEAN;
    lv_disb_count           NUMBER;
    lv_special_school       VARCHAR2(30);
    l_dl_std_code           igf_ap_class_std_map.dl_std_code%TYPE;
    lv_dummy                varchar2(1);
    lv_fed_fund_code        igf_aw_fund_cat_all.fed_fund_code%TYPE;
    lv_msg_name             fnd_new_messages.message_name%TYPE;
    lv_lookup_code          igf_lookups_view.lookup_code%TYPE;

    /***********************************************************************************
     P_LOAN_CATG   : Valid values are DL_STAFFORD, DL_PLUS
     P_LOAN_NUMBER : Possible values are "A particular Loan#" or NULL
                     A valid Loan# will be passed from the Origination form and
                     NULL will be passed as a default value from the concurrent job prog
     P_CALL_MODE   : Valid values are JOB, FORM
                     If invoked from FORM, then only a specific LOAN_NUMBER can be passed.
    ***********************************************************************************/

    -- If p_call_mode = "JOB", then records with Loan Status with Ready To Send ('G')
    -- ELSE, if "FORM", then we need to validate for "Ready to Send", "Not Ready", "Rejected"

     -- G : Ready to Send
     -- R : Rejected
     -- N : Not Ready

    -- FA 122 Loan Enhancements changed the cursor to obsolete the view igf_sl_lor_dtls_v
    CURSOR cur_loans(
                     cp_cal_type   igf_ap_fa_base_rec.ci_cal_type%TYPE,
                     cp_seq_number igf_ap_fa_base_rec.ci_sequence_number%TYPE,
                     cp_fed_fund_1 igf_aw_fund_cat.fed_fund_code%TYPE,
                     cp_fed_fund_2 igf_aw_fund_cat.fed_fund_code%TYPE,
                     cp_status_1   igf_sl_loans.loan_status%TYPE,
                     cp_status_2   igf_sl_loans.loan_status%TYPE,
                     cp_status_3   igf_sl_loans.loan_status%TYPE,
                     cp_loan_number igf_sl_loans.loan_number%TYPE,
                     cp_active      igf_sl_loans.active%TYPE,
                     cp_school_code  VARCHAR2
                    )
    IS
    SELECT
    loans.rowid row_id,
    loans.loan_id,
    loans.loan_number,
    loans.award_id,
    loans.loan_per_begin_date,
    loans.loan_per_end_date,
    lor.orig_fee_perct,
    lor.pnote_print_ind,
    lor.s_default_status,
    lor.p_default_status,
    lor.p_person_id,
    fabase.person_id student_id,
    fabase.base_id,
    awd.accepted_amt,
    lor.grade_level_code,
    lor.override_grade_level_code
    FROM
    igf_sl_loans_all  loans,
    igf_sl_lor_all    lor,
    igf_aw_award_all  awd,
    igf_aw_fund_mast_all   fmast,
    igf_aw_fund_cat_all    fcat,
    igf_ap_fa_base_rec_all fabase
    WHERE fabase.ci_cal_type = cp_cal_type
    AND fabase.ci_sequence_number = cp_seq_number
    AND fabase.base_id = awd.base_id
    AND awd.fund_id = fmast.fund_id
    AND fmast.fund_code = fcat.fund_code
    AND (fcat.fed_fund_code = cp_fed_fund_1 OR    fcat.fed_fund_code  =  cp_fed_fund_2)
    AND loans.award_id  = awd.award_id
    AND loans.loan_number  = NVL(cp_loan_number,loans.loan_number)
    AND loans.loan_id  = lor.loan_id
    AND (loans.loan_status = cp_status_1 OR  loans.loan_status = cp_status_2 OR loans.loan_status = cp_status_3)
    AND loans.active = cp_active
    AND SUBSTR(loans.loan_number,13,6) = NVL(cp_school_code, SUBSTR(loans.loan_number,13,6));

    orec cur_loans%ROWTYPE;

    -- museshad (Bug 4116399)
    CURSOR cur_get_fed_fund_code(cp_loan_number igf_sl_loans.loan_number%TYPE)
    IS
      SELECT fcat.fed_fund_code
      FROM  igf_sl_loans_all loans,
            igf_aw_award_all awd,
            igf_aw_fund_mast_all fmast,
            igf_aw_fund_cat_all fcat
      WHERE
            loans.award_id    =   awd.award_id      AND
            awd.fund_id       =   fmast.fund_id     AND
            fmast.fund_code   =   fcat.fund_code    AND
            loans.loan_number =   cp_loan_number;
    -- museshad (Bug 4116399)

  PROCEDURE set_complete_status(p_complete BOOLEAN)
    AS
    BEGIN
      IF p_complete = FALSE THEN
         lv_complete := FALSE;
      END IF;
    END set_complete_status;

BEGIN

 lv_complete := TRUE;
 BEGIN
  p_dl_version := igf_sl_gen.get_dl_version(p_ci_cal_type, p_ci_sequence_number);
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 fnd_message.set_name('IGF','IGF_SL_NO_DL_SETUP');
 fnd_file.put_line(fnd_file.log,fnd_message.get);
 RAISE NO_DATA_FOUND;
 END;


 --Initialise the Global Loan ID
  g_loan_id := NULL;

 -- FA 122 populate the l_status_1,l_status_2,l_status_3 fields
 IF p_call_mode = 'FORM' THEN
   l_status_1 := 'G';
   l_status_2 := 'N';
   l_status_3 := 'R';
 ELSIF p_call_mode = 'JOB' THEN
   l_status_1 := 'G';
   l_status_2 := 'G';
   l_status_3 := 'G';
 END IF;

-- FA 122 populate the l_fed_fund_1,l_fed_fund_2
 IF p_loan_catg = 'DL_STAFFORD' THEN
   l_fed_fund_1 := 'DLS';
   l_fed_fund_2 := 'DLU';
 ELSIF p_loan_catg = 'DL_PLUS' THEN
   l_fed_fund_1 := 'DLP';
   l_fed_fund_2 := 'DLP';
 END IF;

-- FA 122 pass all the derived paramters to the cur_loans to get the necessary details
  FOR orec IN cur_loans(p_ci_cal_type,
                        p_ci_sequence_number ,
                        l_fed_fund_1,
                        l_fed_fund_2,
                        l_status_1,
                        l_status_2,
                        l_status_3,
                        p_loan_number,
                        'Y',
                        p_school_code)
  LOOP
  --Need not perform the validations if the Loan ID is same.
  IF NVL(g_loan_id,0) <> orec.loan_id OR p_call_mode = 'FORM' THEN

 -- FA 122 Loan Enhancements Use the igf_sl_gen.get_person_details for getting the student as
 -- well as parent details.
   igf_sl_gen.get_person_details(orec.student_id,student_dtl_cur);
   FETCH student_dtl_cur INTO student_dtl_rec;

   -- this will fetch the parent details
   igf_sl_gen.get_person_details(orec.p_person_id,parent_dtl_cur);
   FETCH parent_dtl_cur INTO parent_dtl_rec;

   CLOSE student_dtl_cur;
   CLOSE parent_dtl_cur;

   -- PUT THE DEBUGGING LOG MESSAGES

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','loan_number passed to igf_sl_dl_record.get_acad_cal_dtls:'|| orec.loan_number);
    END IF;

  -- Get the Academic Year Start and End Dates for this Award Year
  -- masehgal   # 2593215   removed begin/end dates fetching functions
  -- used procedure get_acad_cal_dtls instead
     igf_sl_dl_record.get_acad_cal_dtls ( orec.loan_number,
                                          lv_acad_cal_type,
                                          lv_acad_seq_num,
                                          lv_acad_begin_date,
                                          lv_acad_end_date,
                                          lv_message );

  -- This has p_loan_number as IN and begin and cal_type, sequence_number and dates as OUT parametes.
  -- If lv_message is null then it implies that acad year was found ....
  -- We will log that as an error code in processing below where we chk if acad_dates are null and
  -- report appropriate error code.

    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','lv_message got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_message);
    END IF;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','lv_acad_begin_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_begin_date);
    END IF;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','lv_acad_end_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_end_date);
    END IF;
    lv_complete  := TRUE;

    -- Delete records from Edit Report table, with type="V" (VALIDATION) for this Loan#
    igf_sl_edit.delete_edit(orec.loan_number, 'V');

    lv_s_depncy_status      := NULL;
    lv_s_citizenship_status := NULL;
    FOR isir_rec IN cur_isir(orec.base_id) LOOP
       lv_s_depncy_status      := isir_rec.s_depncy_status;
    END LOOP;
    lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;

    IF p_loan_catg = 'DL_STAFFORD' THEN

      lv_loan_catg := p_loan_catg;

      -- Following are the checks for Direct Loan Stafford.
      --FA 122 get the student details from the student_dtl_rec
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_SSN',           student_dtl_rec.p_ssn));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_FIRST_NAME',    student_dtl_rec.p_first_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_LAST_NAME',     student_dtl_rec.p_last_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_PERMT_ADDR1',   student_dtl_rec.p_permt_addr1));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_PERMT_CITY',    student_dtl_rec.p_permt_city));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_PERMT_STATE',   student_dtl_rec.p_permt_state));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_PERMT_ZIP',     student_dtl_rec.p_permt_zip));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'PNOTE_PRINT_IND', orec.pnote_print_ind));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'ORIG_FEE_PERCT',  to_char(orec.orig_fee_perct)));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_DEPNCY_STATUS', lv_s_depncy_status));

      -- If the Student is in Default, then do not originate
      IF orec.s_default_status = 'Y' THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'S_DEFAULT_STATUS', NULL);
      END IF;

    ELSIF p_loan_catg = 'DL_PLUS' THEN
      lv_loan_catg := p_loan_catg;

      -- Following are the checks for Direct Loan PLUS.
       --FA 122 get the parent details from the parent_dtl_rec
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_SSN'   ,        parent_dtl_rec.p_ssn));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_FIRST_NAME'   , parent_dtl_rec.p_first_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_LAST_NAME'   ,  parent_dtl_rec.p_last_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_PERMT_ADDR1',   parent_dtl_rec.p_permt_addr1));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_PERMT_CITY',    parent_dtl_rec.p_permt_city));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_PERMT_STATE',   parent_dtl_rec.p_permt_state));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_PERMT_ZIP',     parent_dtl_rec.p_permt_zip));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_DATE_OF_BIRTH', to_char(parent_dtl_rec.p_date_of_birth)));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_CITIZENSHIP_STATUS',parent_dtl_rec.p_citizenship_status));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'P_DEFAULT_STATUS', orec.p_default_status));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'PNOTE_PRINT_IND',  orec.pnote_print_ind));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_SSN',            student_dtl_rec.p_ssn ));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_FIRST_NAME',     student_dtl_rec.p_first_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_LAST_NAME',      student_dtl_rec.p_last_name));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_CITIZENSHIP_STATUS',lv_s_citizenship_status));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_DATE_OF_BIRTH', to_char(student_dtl_rec.p_date_of_birth)));
      set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'S_DEPNCY_STATUS',  lv_s_depncy_status));

      -- For PLUS, If the Student/Parent is in Default, then do not originate
      IF orec.s_default_status = 'Y' THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'S_DEFAULT_STATUS', NULL);
      END IF;
      IF orec.p_default_status = 'Y' THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'P_DEFAULT_STATUS', NULL);
      END IF;

    END IF;   -- End of "p_loan_catg" check.

    set_complete_status(check_for_reqd(orec.loan_number,lv_loan_catg,'GRADE_LEVEL_CODE', orec.grade_level_code));

    -- The following validation introduced in as part of IGS.L.6R bug 4346421.
    -- But due to Cust bug 4568942, this validation is removed. (Reverting back 4346421)
/*
    -- Validate grade level (bug 4346421)
    -- get System Grade Level, compare with NVL(override_grade_level_code, grade_level_code). If not matching, then log mesg.
    l_dl_std_code := get_system_grade_level(orec.base_id, orec.loan_per_begin_date, orec.loan_per_end_date);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','l_dl_std_code got from get_system_grade_level function :'|| l_dl_std_code);
    END IF;

    IF (orec.override_grade_level_code IS NOT NULL) THEN
      IF (orec.override_grade_level_code <> l_dl_std_code) THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'OVER_GRD_LVL_MISMATCH', 'OVERRIDE_GRADE_LEVEL_CODE', NULL);
      END IF;
    ELSIF orec.grade_level_code IS NOT NULL THEN
      IF (orec.grade_level_code <> l_dl_std_code) THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'GRD_LVL_MISMATCH', 'GRADE_LEVEL_CODE', NULL);
      END IF;
    END IF;
*/


    -- Check if number of disbursements is one or not. If one, it must be Special School. FA 149.
    -- get number of disbursements

    lv_disb_count := -1;
    OPEN cur_get_no_of_disbursements(orec.award_id);
    FETCH cur_get_no_of_disbursements INTO lv_disb_count;
    IF (lv_disb_count = 1) THEN
      -- Check if it is Special School or not.
      OPEN cur_special_school(p_ci_cal_type, p_ci_sequence_number);
      FETCH cur_special_school INTO lv_special_school;
      IF (lv_special_school IS NOT NULL AND lv_special_school <> 'Y') THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INVALID_DISB_INFO', NULL, NULL);
      END IF;
      CLOSE cur_special_school;
    END IF;
    CLOSE cur_get_no_of_disbursements;

    -- Below are some of the checks which are to be done for both STAFFORD and PLUS

    -- For any disbursement, if disb-gross-amount, origination-fees or the disbursement net amount,
    -- should be more than ZERO. This is for both Stafford and PLUS

    -- COD Specific. If amounts are zero still we need to sent if it had already been with COD.
    -- Check wether the record is at LOR or not.
    -- If yes, omit the following check. Bug 4368529
    lv_dummy := NULL;
    OPEN cur_loan_at_cod(orec.loan_number);
    FETCH cur_loan_at_cod INTO lv_dummy;
    CLOSE cur_loan_at_cod;

    IF lv_dummy IS NULL THEN
      FOR irec in cur_disb(orec.award_id) LOOP
         IF NVL(irec.disb_count,0) > 0 THEN
           set_complete_status(FALSE);
           igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DISB_MORE_THAN_ZERO', NULL, NULL);
         END IF;
      END LOOP;

      -- Loan Amount should be greater than zero. Applicable to Stafford and PLUS
      IF nvl(orec.accepted_amt,0) <= 0 THEN
         set_complete_status(FALSE);
         igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LESS_THAN_ZERO', 'LOAN_AMT_ACCEPTED', NULL);
      END IF;
    END IF;

    -- Origination Fee should be greater than zero. Applicable to Stafford and PLUS
    IF nvl(orec.orig_fee_perct,0) <= 0 THEN
       set_complete_status(FALSE);
       igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LESS_THAN_ZERO', 'ORIG_FEE_PERCT', NULL);
    END IF;

    -- Check if the Loan Begin and End Dates fall within the Academic Begin and End Dates.

    -- masehgal    # 2593215   added this check - acad year not found.
    IF (lv_acad_begin_date IS NULL OR lv_acad_end_date IS NULL) THEN
       -- irrespective if it is called from form or job, insert a record in edit report with a new error code
       set_complete_status(FALSE);
       igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'ACAD_YEAR_REQD', NULL, NULL);
    END IF ;

    IF orec.loan_per_begin_date < lv_acad_begin_date THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LOAN_BEGDT_LT_ACAD_BEGDT', NULL, NULL);
    END IF;
    IF orec.loan_per_end_date > lv_acad_end_date THEN

      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LOAN_ENDDT_GT_ACAD_ENDDT', NULL, NULL);
    END IF;

    -- Check whether the EFC Information is available for the Student, using the ISIR's Dependency Status
    -- If ISIR's Depncy-status is X,Y, then NO EFC is Calculated.
    -- If ISIR's Depncy-status is I,D, then alculated EFC info has been provided.
    IF nvl(lv_s_depncy_status,'*') NOT IN ('I','D') THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DEPNCY_NO_EFC_CALC', 'S_DEPNCY_STATUS', lv_s_depncy_status);
    END IF;

    -- museshad (Bug 4116399) - Stafford loan limit validation for DLS, DLU
    IF p_loan_catg = 'DL_STAFFORD' THEN
      lv_msg_name     := NULL;
      lv_lookup_code  := NULL;

      OPEN cur_get_fed_fund_code(cp_loan_number => orec.loan_number);
      FETCH cur_get_fed_fund_code INTO lv_fed_fund_code;
      CLOSE cur_get_fed_fund_code;

      loan_limit_validation (
                              p_base_id     =>    orec.base_id,
                              p_fund_type   =>    lv_fed_fund_code,
                              p_award_id    =>    orec.award_id,
                              p_msg_name    =>    lv_msg_name
                            );

      IF lv_msg_name IS NOT NULL THEN
        -- Stafford loan limit validation FAILED
        set_complete_status(FALSE);

        IF lv_msg_name = 'IGF_AW_AGGR_LMT_ERR' THEN
          lv_lookup_code := 'AGGR_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_ANNUAL_LMT_ERR' THEN
          lv_lookup_code := 'ANNUAL_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_SUB_AGGR_LMT_ERR' THEN
          lv_lookup_code := 'SUB_AGGR_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_SUB_LMT_ERR' THEN
          lv_lookup_code := 'SUB_LMT_CHK';
        ELSIF lv_msg_name = 'IGF_AW_LOAN_LMT_NOT_FND' THEN
          lv_lookup_code := 'LOAN_LMT_SETUP_CHK';
        END IF;

        igf_sl_edit.insert_edit(orec.loan_number, 'V', 'IGF_SL_ERR_CODES', lv_lookup_code, NULL, NULL);

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','Stafford loan limit validation for award_id ' ||orec.award_id|| ' FAILED with message: ' ||lv_msg_name);
        END IF;
      ELSE
        -- Stafford loan limit validation PASSED
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.dl_lar_validate.debug','Stafford loan limit validation PASSED for award_id ' ||orec.award_id);
        END IF;
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

          DECLARE
              lv_row_id  VARCHAR2(25);
              CURSOR c_tbh_cur IS
              SELECT igf_sl_loans.* FROM igf_sl_loans
              WHERE rowid = orec.row_id FOR UPDATE OF igf_sl_loans.loan_status NOWAIT;
          BEGIN
            FOR tbh_rec in c_tbh_cur LOOP

-- Modified the call for IGF_SL_LOANS_PKG.UPDATE_ROW to include the Borrower Determination
-- as part of Refunds DLD - 2144600
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
            END LOOP;
          END;

         IF lv_complete = FALSE THEN
            -- Display reject details on the Concurrent Manager Log File.
            DECLARE
               lv_log_mesg VARCHAR2(1000);
               CURSOR c_reject IS
               SELECT rpad(field_desc,50)||sl_error_desc reject_desc FROM igf_sl_edit_report_v
               WHERE  loan_number = orec.loan_number
               AND    orig_chg_code = 'V';
            BEGIN


               FND_FILE.PUT_LINE(FND_FILE.LOG, '');
               FND_FILE.PUT_LINE(FND_FILE.LOG, '');
               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER')||' : '||orec.loan_number;
               FND_FILE.PUT_LINE(FND_FILE.LOG, lv_log_mesg);
               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SSN')      ||' : '||student_dtl_rec.p_ssn;
               FND_FILE.PUT_LINE(FND_FILE.LOG, lv_log_mesg);
               lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_FULL_NAME')||' : '
                                                                 ||student_dtl_rec.p_first_name||' '||student_dtl_rec.p_last_name;
               FND_FILE.PUT_LINE(FND_FILE.LOG, lv_log_mesg);
               FOR rej_rec IN c_reject LOOP
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'    '||rej_rec.reject_desc);
               END LOOP;

           END;
         END IF;

    ELSE
       -- If the validation routinue is called from FORM, then just return the Status of TRUE/FALSE.
       NULL;

    END IF;

g_loan_id:=orec.loan_id;  --Keep changing Global Loan ID everytime it is different.

END IF; --Check for Global Loan ID not being same.


  END LOOP;

  IF p_call_mode = 'JOB' THEN
     RETURN TRUE;
  ELSE
     RETURN lv_complete;
  END IF;

EXCEPTION
--Added this for Handling the exception when DL Setup is not found
WHEN NO_DATA_FOUND THEN
NULL;

WHEN app_exception.record_lock_exception THEN
   RAISE;
WHEN OTHERS THEN

--Removed the fnd_message.setname with Package.Procedure name.
--This is because this procedure in turn calls igf_sl_dl_record package academic year functions
--which return valid exceptions.only if we just propogate this exception
--we will be able to trap both in form and in dl orig process.
--hence removed code.
--Bug :-2415041 Loan Orig with incorrect error messages.

   app_exception.raise_exception;

END dl_lar_validate;

FUNCTION  cod_loan_validations ( p_loan_rec igf_sl_dl_gen_xml.cur_pick_loans%ROWTYPE,
                                 p_call_from    VARCHAR2,
                                 p_isir_ssn     OUT NOCOPY VARCHAR2,
                                 p_isir_dob     OUT NOCOPY DATE,
                                 p_isir_lname   OUT NOCOPY VARCHAR2,
                                 p_isir_dep     OUT NOCOPY VARCHAR2,
                                 p_isir_tnum    OUT NOCOPY NUMBER,
                                 p_acad_begin   OUT NOCOPY DATE,
                                 p_acad_end     OUT NOCOPY DATE,
                                 p_s_phone      OUT NOCOPY VARCHAR2,
                                 p_p_phone      OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
/*************************************************************
Created By : ugummall
Date Created On : 01-OCT-2004
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
museshad        28-Nov-2005     Bug 4116399.
                                Added Stafford loan limit validation check.
(reverse chronological order - newest change first)
akomurav   24-1-2006 FA162.The values of Acad begin date and end date are now directly populated fromIGF_SL_LOR_ALL table i.e p_loan_rec record.
***************************************************************/

CURSOR cur_disb_chg_dtls  ( cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
SELECT  db.award_id,
        db.disb_num,
        db.disb_seq_num,
        db.disb_accepted_amt,
        db.disb_date,
        db.orig_fee_amt,
        db.disb_net_amt,
        db.interest_rebate_amt
  FROM  igf_aw_db_chg_dtls db
 WHERE  db.award_id = cp_award_id;

rec_disb_chg_dtls  cur_disb_chg_dtls%ROWTYPE;
lv_s_depncy_status      igf_ap_isir_matched_all.dependency_status%TYPE;
lv_s_citizenship_status igf_ap_isir_matched_all.citizenship_status%TYPE;
lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE ;
lv_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;
lv_acad_begin_date      igs_ca_inst_all.start_dt%TYPE;
lv_acad_end_date        igs_ca_inst_all.end_dt%TYPE;
lv_message              VARCHAR2(100);
l_p_phone               VARCHAR2(80);
l_s_phone               VARCHAR2(80);
lv_special_school       VARCHAR2(30);
lv_complete             BOOLEAN;
lv_disb_count           NUMBER;
student_dtl_cur         igf_sl_gen.person_dtl_cur;
parent_dtl_cur          igf_sl_gen.person_dtl_cur;
l_dl_std_code           igf_ap_class_std_map.dl_std_code%TYPE;
lv_dummy                varchar2(1);
lv_lookup_code          igf_lookups_view.LOOKUP_CODE%TYPE;


PROCEDURE set_complete_status(p_complete BOOLEAN)
  AS
  BEGIN
    IF p_complete = FALSE THEN
       lv_complete := FALSE;
    END IF;
  END set_complete_status;

BEGIN

  BEGIN
     p_dl_version := igf_sl_gen.get_dl_version(p_loan_rec.ci_cal_type, p_loan_rec.ci_sequence_number);
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','p_dl_version  '|| p_dl_version );
     END IF;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_message.set_name('IGF','IGF_SL_NO_DL_SETUP');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Setup gone  ' );
     END IF;
     RAISE NO_DATA_FOUND;
  END;

  lv_complete  := TRUE;

  --
  -- Get ISIR Information
  --
  OPEN  cur_isir_info (p_loan_rec.base_id);
  FETCH cur_isir_info INTO isir_info_rec;
  CLOSE cur_isir_info;

  -- Delete records from Edit Report table, with type="V" (VALIDATION) for this Loan#
  igf_sl_edit.delete_edit(p_loan_rec.loan_number, 'V');
  --
  -- Get academic calendar details
  --
  --akomurav FA162 This code will pick the values from the lor_all table
  --The procedure  igf_sl_dl_record.get_acad_cal_dtls will be called only if the acad_begin_date and acad_end_date are NULL
  lv_acad_begin_date := p_loan_rec.acad_begin_date;
  lv_acad_end_date   := p_loan_rec.acad_end_date;

  IF lv_acad_begin_date IS NULL OR lv_acad_end_date IS NULL THEN
          igf_sl_dl_record.get_acad_cal_dtls ( p_loan_rec.loan_number,
                               lv_acad_cal_type,
                               lv_acad_seq_num,
                               lv_acad_begin_date,
                               lv_acad_end_date,
                               lv_message );
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_message got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_message);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_acad_begin_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_begin_date);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_acad_end_date got from igf_sl_dl_record.get_acad_cal_dtls:'|| lv_acad_end_date);
  END IF;

  igf_sl_gen.get_person_details(igf_gr_gen.get_person_id(p_loan_rec.base_id),student_dtl_cur);
  FETCH student_dtl_cur INTO student_dtl_rec;

  igf_sl_gen.get_person_details(p_loan_rec.p_person_id,parent_dtl_cur);
  FETCH parent_dtl_cur INTO parent_dtl_rec;

  CLOSE student_dtl_cur;
  CLOSE parent_dtl_cur;

  lv_s_depncy_status      := NULL;
  lv_s_citizenship_status := NULL;
  lv_s_depncy_status      := isir_info_rec.dependency_status;
  lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_s_citizenship_status  '|| lv_s_citizenship_status);
  END IF;

  p_isir_ssn   := isir_info_rec.current_ssn;
  p_isir_dob   := isir_info_rec.date_of_birth;
  p_isir_lname := isir_info_rec.last_name;
  p_isir_dep   := isir_info_rec.dependency_status;
  p_isir_tnum  := isir_info_rec.transaction_num;
  p_acad_begin := lv_acad_begin_date;
  p_acad_end   := lv_acad_end_date;

  IF p_loan_rec.fed_fund_code IN ('DLS','DLU') THEN
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_SSN',           student_dtl_rec.p_ssn));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_FIRST_NAME',    student_dtl_rec.p_first_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_LAST_NAME',     student_dtl_rec.p_last_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_PERMT_ADDR1',   student_dtl_rec.p_permt_addr1));
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','S_PERMT_ADDR1 = ' ||student_dtl_rec.p_permt_addr1);
    END IF;
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_PERMT_CITY',    student_dtl_rec.p_permt_city));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_PERMT_STATE',   student_dtl_rec.p_permt_state));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_PERMT_ZIP',     student_dtl_rec.p_permt_zip));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','PNOTE_PRINT_IND', p_loan_rec.pnote_print_ind));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','ORIG_FEE_PERCT',  TO_CHAR(p_loan_rec.orig_fee_perct)));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_DEPNCY_STATUS', lv_s_depncy_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','GRADE_LEVEL_CODE',p_loan_rec.grade_level_code));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','LOAN_AMT_ACCEPTED', p_loan_rec.accepted_amt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','LOAN_NUMBER', p_loan_rec.loan_number));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_DEFAULT_STATUS',p_loan_rec.s_default_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','ATD_ENTITY_ID_TXT',p_loan_rec.atd_entity_id_txt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','CPS_TRANS_NUM',p_loan_rec.cps_trans_num));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','LOAN_PER_BEGIN_DATE',p_loan_rec.loan_per_begin_date));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','LOAN_PER_END_DATE',p_loan_rec.loan_per_end_date));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','REP_ENTITY_ID_TXT',p_loan_rec.rep_entity_id_txt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_STAFFORD','S_CITIZENSHIP_STATUS',student_dtl_rec.p_citizenship_status));

    -- If the Student is in Default, then do not originate
    IF p_loan_rec.s_default_status = 'Y' THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'S_DEFAULT_STATUS', NULL);
    END IF;

  ELSIF p_loan_rec.fed_fund_code = 'DLP' THEN

    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_SSN'   ,        parent_dtl_rec.p_ssn));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_FIRST_NAME'   , parent_dtl_rec.p_first_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_LAST_NAME'   ,  parent_dtl_rec.p_last_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_PERMT_ADDR1',   parent_dtl_rec.p_permt_addr1));
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','P_PERMT_ADDR1 = ' ||parent_dtl_rec.p_permt_addr1);
    END IF;
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_PERMT_CITY',    parent_dtl_rec.p_permt_city));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_PERMT_STATE',   parent_dtl_rec.p_permt_state));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_PERMT_ZIP',     parent_dtl_rec.p_permt_zip));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_DATE_OF_BIRTH', TO_CHAR(parent_dtl_rec.p_date_of_birth)));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_CITIZENSHIP_STATUS',parent_dtl_rec.p_citizenship_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','P_DEFAULT_STATUS', p_loan_rec.p_default_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','PNOTE_PRINT_IND',  p_loan_rec.pnote_print_ind));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_SSN',           student_dtl_rec.p_ssn));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_FIRST_NAME',    student_dtl_rec.p_first_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_LAST_NAME',     student_dtl_rec.p_last_name));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_PERMT_ADDR1',   student_dtl_rec.p_permt_addr1));
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','S_PERMT_ADDR1 = ' ||student_dtl_rec.p_permt_addr1);
    END IF;
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_PERMT_CITY',    student_dtl_rec.p_permt_city));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_PERMT_STATE',   student_dtl_rec.p_permt_state));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_PERMT_ZIP',     student_dtl_rec.p_permt_zip));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','PNOTE_PRINT_IND', p_loan_rec.pnote_print_ind));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','ORIG_FEE_PERCT',  TO_CHAR(p_loan_rec.orig_fee_perct)));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_DEPNCY_STATUS', lv_s_depncy_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','GRADE_LEVEL_CODE',p_loan_rec.grade_level_code));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','LOAN_AMT_ACCEPTED', p_loan_rec.accepted_amt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','LOAN_NUMBER', p_loan_rec.loan_number));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_DEFAULT_STATUS',p_loan_rec.s_default_status));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','ATD_SCHL_ENTITY_ID',p_loan_rec.atd_entity_id_txt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','CPS_TRANS_NUM',p_loan_rec.cps_trans_num));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','LOAN_PER_BEGIN_DATE',p_loan_rec.loan_per_begin_date));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','LOAN_PER_END_DATE',p_loan_rec.loan_per_end_date));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','REP_SCHL_ENTITY_ID',p_loan_rec.rep_entity_id_txt));
    set_complete_status(check_for_reqd(p_loan_rec.loan_number,'DL_PLUS','S_CITIZENSHIP_STATUS',student_dtl_rec.p_citizenship_status));

    -- For PLUS, If the Student/Parent is in Default, then do not originate
    IF p_loan_rec.s_default_status = 'Y' THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'S_DEFAULT_STATUS', NULL);
    END IF;
    IF p_loan_rec.p_default_status = 'Y' THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'IS_DEFAULTER', 'P_DEFAULT_STATUS', NULL);
    END IF;
  END IF;   -- End of "p_loan_catg" check.

  -- Check if number of disbursements is one or not. If one, it must be Special School. FA 149.
  -- get number of disbursements
  lv_disb_count := -1;

  OPEN  cur_get_no_of_disbursements(p_loan_rec.award_id);
  FETCH cur_get_no_of_disbursements INTO lv_disb_count;
  CLOSE cur_get_no_of_disbursements;
  IF (lv_disb_count = 1) THEN
    -- Check if it is Special School or not.
    OPEN cur_special_school(p_loan_rec.ci_cal_type, p_loan_rec.ci_sequence_number);
    FETCH cur_special_school INTO lv_special_school;
    IF (lv_special_school IS NOT NULL AND lv_special_school <> 'Y') THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INVALID_DISB_INFO', NULL, NULL);
    END IF;
    CLOSE cur_special_school;
  END IF;

  -- Below are some of the checks which are to be done for both STAFFORD and PLUS
  -- For any disbursement, if disb-gross-amount, origination-fees or the disbursement net amount,
  -- should be more than ZERO. This is for both Stafford and PLUS

  -- COD Specific. If amounts are zero still we need to sent if it had already been with COD.
  -- Check wether the record is at LOR or not.
  -- If yes, omit the following check. Bug 4368529
  lv_dummy := NULL;
  OPEN cur_loan_at_cod(p_loan_rec.loan_number);
  FETCH cur_loan_at_cod INTO lv_dummy;
  CLOSE cur_loan_at_cod;

  IF lv_dummy IS NULL THEN
    FOR irec IN cur_disb(p_loan_rec.award_id) LOOP
      IF NVL(irec.disb_count,0) > 0 THEN
        set_complete_status(FALSE);
        igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DISB_MORE_THAN_ZERO', NULL, NULL);
      END IF;
    END LOOP;

    -- Loan Amount should be greater than zero. Applicable to Stafford and PLUS
    IF NVL(p_loan_rec.accepted_amt,0) <= 0 THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LESS_THAN_ZERO', 'LOAN_AMT_ACCEPTED', p_loan_rec.accepted_amt);
    END IF;
  END IF;

  -- Origination Fee should be greater than zero. Applicable to Stafford and PLUS
  IF NVL(p_loan_rec.orig_fee_perct,0) <= 0 THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LESS_THAN_ZERO', 'ORIG_FEE_PERCT', p_loan_rec.orig_fee_perct);
  END IF;

  -- Payment ISIR missing
  IF isir_info_rec.payment_isir IS NULL THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'NO_PYMNT_ISIR', NULL, NULL);
  END IF;

  -- Payment ISIR mismatch
  IF TO_NUMBER(isir_info_rec.transaction_num) <> TO_NUMBER(p_loan_rec.cps_trans_num) THEN
  --MN 11/29/2004 16:23 - As the Transaction Number is numeric data stored in VarChar2, added To_Number
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'PYMNT_ISIR_MISMATCH', NULL, NULL);
  END IF;

  IF (lv_acad_begin_date IS NULL OR lv_acad_end_date IS NULL) THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'ACAD_YEAR_REQD', NULL, NULL);
  END IF ;

  IF p_loan_rec.loan_per_begin_date < lv_acad_begin_date THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LOAN_BEGDT_LT_ACAD_BEGDT', NULL, NULL);
  END IF;

  IF p_loan_rec.loan_per_end_date > lv_acad_end_date THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'LOAN_ENDDT_GT_ACAD_ENDDT', NULL, NULL);
  END IF;

-- Check whether the EFC Information is available for the Student, using the ISIR's Dependency Status
-- If ISIR's Depncy-status is X,Y, then NO EFC is Calculated.
-- If ISIR's Depncy-status is I,D, then alculated EFC info has been provided.
  IF NVL(lv_s_depncy_status,'*') NOT IN ('I','D') THEN
    set_complete_status(FALSE);
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'DEPNCY_NO_EFC_CALC', 'S_DEPNCY_STATUS', lv_s_depncy_status);
  END IF;

    -- The following validation introduced in as part of IGS.L.6R bug 4346421.
    -- But due to Cust bug 4568942, this validation is removed. (Reverting back 4346421)
/*
  -- Validate grade level (bug 4346421)
  -- get System Grade Level, compare with NVL(override_grade_level_code, grade_level_code). If not matching, then log mesg.
  l_dl_std_code := get_system_grade_level(p_loan_rec.base_id, p_loan_rec.loan_per_begin_date, p_loan_rec.loan_per_end_date);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','l_dl_std_code got from get_system_grade_level function :'|| l_dl_std_code);
  END IF;

  IF (p_loan_rec.override_grade_level_code IS NOT NULL) THEN
    IF (p_loan_rec.override_grade_level_code <> l_dl_std_code) THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'OVER_GRD_LVL_MISMATCH', 'OVERRIDE_GRADE_LEVEL_CODE', NULL);
    END IF;
  ELSIF p_loan_rec.grade_level_code IS NOT NULL THEN
    IF (p_loan_rec.grade_level_code <> l_dl_std_code) THEN
      set_complete_status(FALSE);
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'GRD_LVL_MISMATCH', 'GRADE_LEVEL_CODE', NULL);
    END IF;
  END IF;
*/

  --
  -- COD Specific validations
  --

  -- Check if the isir information is same as sws information
  IF p_loan_rec.grade_level_code NOT IN ('0','1','2','3','4','5','6','7') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_GRD_LEVEL', 'GRADE_LEVEL_CODE',p_loan_rec.grade_level_code);
  END IF;
  IF p_loan_rec.disclosure_print_ind IS NULL OR p_loan_rec.disclosure_print_ind NOT IN ('S','R','Y') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISC_IND', 'DISC_PRINT_IND',p_loan_rec.disclosure_print_ind);
  END IF;
  IF p_loan_rec.pnote_print_ind IS NULL OR p_loan_rec.pnote_print_ind NOT IN ('S','R','Z','V','O') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_PNOTE_IND', 'PNOTE_PRINT_IND',p_loan_rec.pnote_print_ind);
  END IF;

/* Not inserting this edit ---
  IF isir_info_rec.date_of_birth <> student_dtl_rec.p_date_of_birth OR
     isir_info_rec.current_ssn <> student_dtl_rec.p_ssn OR
     isir_info_rec.last_name <> UPPER(student_dtl_rec.p_last_name) THEN



      --lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_ISIR_INFO_CHG', NULL,NULL);
  END IF;

*/

  IF p_dl_version = '2004-2005' THEN
    -- 1. validating student's date of birth
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011905', 'DDMMYYYY')) OR
         (student_dtl_rec.p_date_of_birth > TO_DATE('31121996', 'DDMMYYYY')) )
    THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INVALID_DOB0405', 'S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth);
    END IF;
  END IF;
  IF p_dl_version = '2005-2006' THEN
    -- 1. validating student's date of birth
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011906', 'DDMMYYYY')) OR
         (student_dtl_rec.p_date_of_birth > TO_DATE('31121997', 'DDMMYYYY')) )
    THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INVALID_DOB0506', 'S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth);
    END IF;
  END IF;
      IF p_dl_version = '2006-2007' THEN
    -- 1. validating student's date of birth
    IF ( (student_dtl_rec.p_date_of_birth < TO_DATE('01011907', 'DDMMYYYY')) OR
         (student_dtl_rec.p_date_of_birth > TO_DATE('31121998', 'DDMMYYYY')) )
    THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INVALID_DOB0607', 'S_DATE_OF_BIRTH', student_dtl_rec.p_date_of_birth);
    END IF;
  END IF;
    -- validating student's SSN
  IF ( (student_dtl_rec.p_ssn < '001010001') OR (student_dtl_rec.p_ssn > '999999998') ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INVALID_SSN', 'S_SSN', student_dtl_rec.p_ssn);
  END IF;

  -- validating student's first name
  IF ( LENGTH(student_dtl_rec.p_first_name) > 12) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_FIRST_NAME', 'S_FIRST_NAME', student_dtl_rec.p_first_name);
  END IF;

  -- validating student's last name
  IF ( LENGTH(student_dtl_rec.p_last_name) > 35) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_LAST_NAME', 'S_LAST_NAME', student_dtl_rec.p_last_name);
  END IF;

  -- validating student's address line 1
  IF ( (LENGTH(student_dtl_rec.p_permt_addr1) < 1) OR
       (LENGTH(student_dtl_rec.p_permt_addr1) > 40) ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_ADDR_LINE', 'S_PERMT_ADDR1', student_dtl_rec.p_permt_addr1);
  END IF;

  -- validating student's address line 2
  IF ( (LENGTH(student_dtl_rec.p_permt_addr2) < 1) OR (LENGTH(student_dtl_rec.p_permt_addr2) > 40) ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_ADDR_LINE', 'S_PERMT_ADDR2', student_dtl_rec.p_permt_addr2);
  END IF;

  -- validating student's city
  IF ( LENGTH(student_dtl_rec.p_permt_city) > 24) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_CITY', 'S_PERMT_CITY', student_dtl_rec.p_permt_city);
  END IF;

  -- validating student's E-MAIL
  IF ( LENGTH(student_dtl_rec.p_email_addr) > 128) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_EMAIL', 'S_EMAIL_ADDR', student_dtl_rec.p_email_addr);
  END IF;

  -- validating student's Phone Number sl03b.pls
  l_s_phone := igf_sl_gen.get_person_phone(igf_gr_gen.get_person_id(p_loan_rec.base_id));
  IF l_s_phone = 'N/A' THEN
     p_s_phone := NULL;--bug 4093556, When there is no phone number existing for a student then the phone number tag was populated using '000000000000' .
                       --This has being changed to NULL(akomurav)
  ELSE
    IF NOT validate_id(l_s_phone) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_PHONE_NUM_D', 'S_PERMT_PHONE', l_s_phone);
    ELSE
      p_s_phone := l_s_phone;
    END IF;
    IF LENGTH(l_s_phone) > 17 OR LENGTH(l_s_phone) < 10 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_PHONE_NUM', 'S_PERMT_PHONE', l_s_phone);
    END IF;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','l_s_phone  '|| l_s_phone);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','p_s_phone  '|| p_s_phone);
  END IF;

  -- validating student's Zip Code
  IF ( (LENGTH(student_dtl_rec.p_permt_zip) < 5) OR (LENGTH(student_dtl_rec.p_permt_zip) > 13) ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_ZIP_CODE', 'S_PERMT_ZIP', student_dtl_rec.p_permt_zip);
  END IF;

  -- validating student's State Code
  IF ( (LENGTH(student_dtl_rec.p_permt_state) < 2) OR (LENGTH(student_dtl_rec.p_permt_state) > 3) ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_STATE_CODE', 'S_PERMT_STATE', student_dtl_rec.p_permt_state);
  END IF;

  -- validating student's driver licencse number
  IF ( LENGTH(student_dtl_rec.p_license_num) > 20) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_DRIV_LIC_NUM', 'S_LICENSE_NUM', student_dtl_rec.p_license_num);
  END IF;

  IF student_dtl_rec.p_license_num IS NOT NULL AND  student_dtl_rec.p_license_state IS NULL THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_DRIV_LIC_NUM_STATE', 'P_LICENSE_NUM', NULL);
  END IF;

  IF student_dtl_rec.p_license_state IS NOT NULL AND  student_dtl_rec.p_license_num IS NULL THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_DRIV_LIC_STATE_NUM', 'P_LICENSE_ST', NULL);
  END IF;

  -- validating student's citizenship status code
  IF ( LENGTH(student_dtl_rec.p_citizenship_status) > 1) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'S_INV_CIT_STATUS', 'S_CITIZENSHIP_STATUS', student_dtl_rec.p_citizenship_status);
  END IF;

  -- validating transaction number
  IF ( (to_number(p_loan_rec.cps_trans_num) < 1) OR (to_number(p_loan_rec.cps_trans_num) > 99) ) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INVALID_TRANS_NUM', 'CPS_TRANS_NUM', p_loan_rec.cps_trans_num);
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','CPS Tran Number Check');
  END IF;

  -- validating loan_per_begin_date
  IF p_dl_version = '2004-2005' THEN
    IF p_loan_rec.loan_per_begin_date < TO_DATE('02072003', 'DDMMYYYY') OR
       p_loan_rec.loan_per_begin_date > TO_DATE('30062005', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_STARTDT0405', 'LOAN_PER_BEGIN', p_loan_rec.loan_per_begin_date );
    END IF;
  END IF;
  -- validating loan_per_end_date
  IF p_dl_version = '2004-2005' THEN
    IF p_loan_rec.loan_per_end_date < TO_DATE('01072004', 'DDMMYYYY') OR
       p_loan_rec.loan_per_end_date > TO_DATE('29062006', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_ENDDT0405', 'LOAN_PER_END_DATE', p_loan_rec.loan_per_end_date);
    END IF;
  END IF;
 -- validating loan_per_begin_date
  IF p_dl_version = '2005-2006' THEN
    IF p_loan_rec.loan_per_begin_date < TO_DATE('02072004', 'DDMMYYYY') OR
       p_loan_rec.loan_per_begin_date > TO_DATE('30062006', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_STARTDT0506', 'LOAN_PER_BEGIN', p_loan_rec.loan_per_begin_date );
    END IF;
  END IF;
  -- validating loan_per_end_date
  IF p_dl_version = '2005-2006' THEN
    IF p_loan_rec.loan_per_end_date < TO_DATE('01072005', 'DDMMYYYY') OR
       p_loan_rec.loan_per_end_date > TO_DATE('29062007', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_ENDDT0506', 'LOAN_PER_END_DATE', p_loan_rec.loan_per_end_date);
    END IF;
  END IF;
 -- validating loan_per_begin_date
  IF p_dl_version = '2006-2007' THEN
    IF p_loan_rec.loan_per_begin_date < TO_DATE('02072005', 'DDMMYYYY') OR
       p_loan_rec.loan_per_begin_date > TO_DATE('30062007', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_STARTDT0607', 'LOAN_PER_BEGIN', p_loan_rec.loan_per_begin_date );
    END IF;
  END IF;
  -- validating loan_per_end_date
  IF p_dl_version = '2006-2007' THEN
    IF p_loan_rec.loan_per_end_date < TO_DATE('01072006', 'DDMMYYYY') OR
       p_loan_rec.loan_per_end_date > TO_DATE('29062008', 'DDMMYYYY') THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_LOAN_PER_ENDDT0607', 'LOAN_PER_END_DATE', p_loan_rec.loan_per_end_date);
    END IF;
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Loan Per Dates Check over');
  END IF;

  -- validating academic begin and end dates
  IF (lv_message  IS NULL) THEN
    -- validating academic begin date
    IF p_dl_version = '2004-2005' THEN
      IF lv_acad_begin_date IS NULL OR
         lv_acad_begin_date < TO_DATE('02072003', 'DDMMYYYY') OR
         lv_acad_begin_date > TO_DATE('30062005', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_STARTDT0405', 'ACAD_PER_BEGIN_DATE', lv_acad_begin_date);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_acad_begin_date  '|| lv_acad_begin_date);
         END IF;

      END IF;
      -- validating academic end date
      IF lv_acad_end_date IS NULL OR
         lv_acad_end_date < TO_DATE('01072004', 'DDMMYYYY') OR
         lv_acad_end_date > TO_DATE('29062006', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_ENDDT0405', 'ACAD_PER_END_DATE', lv_acad_end_date);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','lv_acad_end_date  '|| lv_acad_end_date);
         END IF;

      END IF;
    END IF;
    IF p_dl_version = '2005-2006' THEN
      IF lv_acad_begin_date IS NULL OR
         lv_acad_begin_date < TO_DATE('02072004', 'DDMMYYYY') OR
         lv_acad_begin_date > TO_DATE('30062006', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_STARTDT0506', 'ACAD_PER_BEGIN_DATE', lv_acad_begin_date);
      END IF;
      -- validating academic end date
      IF lv_acad_end_date IS NULL OR
         lv_acad_end_date < TO_DATE('01072005', 'DDMMYYYY') OR
         lv_acad_end_date > TO_DATE('29062007', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_ENDDT0506', 'ACAD_PER_END_DATE', lv_acad_end_date);
      END IF;
    END IF;
    IF p_dl_version = '2006-2007' THEN
      IF lv_acad_begin_date IS NULL OR
         lv_acad_begin_date < TO_DATE('02072005', 'DDMMYYYY') OR
         lv_acad_begin_date > TO_DATE('30062007', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_STARTDT0607', 'ACAD_PER_BEGIN_DATE', lv_acad_begin_date);
      END IF;
      -- validating academic end date
      IF lv_acad_end_date IS NULL OR
         lv_acad_end_date < TO_DATE('01072006', 'DDMMYYYY') OR
         lv_acad_end_date > TO_DATE('29062008', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ACAD_PER_ENDDT0607', 'ACAD_PER_END_DATE', lv_acad_end_date);
      END IF;
    END IF;
  END IF;
  -- validating note message
  IF ( LENGTH(p_loan_rec.note_message) > 20) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_NOTE_MSG', 'NOTE_MESSAGE', p_loan_rec.note_message);
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Note Message Check Over');
  END IF;

  -- validating orig_fee_perct
  IF ( p_loan_rec.orig_fee_perct >= 100) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_ORIG_FEE_PCT', 'ORIG_FEE_PCT_NUM', p_loan_rec.orig_fee_perct);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' ORIG_FEE_PCT_NUM Check Over');
  END IF;

  -- validating int_reb_pct
  IF p_loan_rec.interest_rebate_percent_num >= 100 OR p_loan_rec.interest_rebate_percent_num < 0  THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_INT_REB_PCT', 'INT_REB_PCT_NUM', p_loan_rec.interest_rebate_percent_num);
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' INT_REB_PCT_NUM Check Over');
  END IF;

  IF  p_loan_rec.accepted_amt >= 999999999.99 OR p_loan_rec.accepted_amt < 0 THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_AWD_AMT', 'LOAN_AMT_ACCEPTED', p_loan_rec.accepted_amt);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' LOAN_AMT_ACCEPTED Check Over');
  END IF;

  -- validating disbursement data from the IGF_AW_DB_CHG_DTLS table
  FOR rec_disb_chg_dtls IN cur_disb_chg_dtls(p_loan_rec.award_id) LOOP
    -- validating disbursement gross amount
    IF rec_disb_chg_dtls.disb_accepted_amt >= 999999999.99 OR rec_disb_chg_dtls.disb_accepted_amt < 0 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_AMT', 'DISB_GROSS_AMT', rec_disb_chg_dtls.disb_accepted_amt);
    END IF;
    IF rec_disb_chg_dtls.disb_net_amt >= 999999999.99 OR rec_disb_chg_dtls.disb_net_amt < 0 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_AMT', 'DISB_NET_AMT', rec_disb_chg_dtls.disb_net_amt);
    END IF;
    IF rec_disb_chg_dtls.orig_fee_amt >= 999999999.99 OR rec_disb_chg_dtls.orig_fee_amt < 0 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_AMT', 'ORIG_FEE_AMT ', rec_disb_chg_dtls.orig_fee_amt);
    END IF;
    IF rec_disb_chg_dtls.disb_net_amt >= 999999999.99 OR rec_disb_chg_dtls.interest_rebate_amt < 0 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_AMT', 'INTEREST_REBATE_AMT', rec_disb_chg_dtls.interest_rebate_amt);
    END IF;

    -- validating disbursement number
    IF ( rec_disb_chg_dtls.disb_num >= 21) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_NUM', 'DISB_NUM', rec_disb_chg_dtls.disb_num);
    END IF;
    -- validating disbursement sequence number
    IF ( rec_disb_chg_dtls.disb_seq_num >= 66) THEN
        lv_complete := FALSE;
        igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_SEQ_NUM', 'DISB_SEQ_NUM', rec_disb_chg_dtls.disb_seq_num);
    END IF;
    -- validating disbursement date
    IF p_dl_version = '2004-2005' THEN
      IF rec_disb_chg_dtls.disb_date < TO_DATE('22062003', 'DDMMYYYY') OR
         rec_disb_chg_dtls.disb_date > TO_DATE('27102006', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_DATE0405', 'DISB_DATE', rec_disb_chg_dtls.disb_date);
      END IF;
    END IF;
    IF p_dl_version = '2005-2006' THEN
      IF rec_disb_chg_dtls.disb_date < TO_DATE('22062004', 'DDMMYYYY') OR
         rec_disb_chg_dtls.disb_date > TO_DATE('27102007', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_DATE0506', 'DISB_DATE', rec_disb_chg_dtls.disb_date);
      END IF;
    END IF;
     IF p_dl_version = '2006-2007' THEN
      IF rec_disb_chg_dtls.disb_date < TO_DATE('22062005', 'DDMMYYYY') OR
         rec_disb_chg_dtls.disb_date > TO_DATE('27102008', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'INV_DISB_DATE0607', 'DISB_DATE', rec_disb_chg_dtls.disb_date);
      END IF;
    END IF;
  END LOOP;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' Disb Check Over');
  END IF;
  --
  -- entity id validations
  --
  IF NOT validate_id(p_loan_rec.atd_entity_id_txt) THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'ATD_SCHL_ID_NUM', 'ATD_ENTITY_ID_TXT', p_loan_rec.atd_entity_id_txt);
  ELSE
    IF p_loan_rec.atd_entity_id_txt > 99999999 THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' p_loan_rec.atd_entity_id_txt ' ||p_loan_rec.atd_entity_id_txt );
      END IF;
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'ATD_SCHL_ID_MAX', 'ATD_ENTITY_ID_TXT', p_loan_rec.atd_entity_id_txt);
    END IF;
  END IF;

  IF NOT validate_id(p_loan_rec.rep_entity_id_txt)THEN
    lv_complete := FALSE;
    igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'REP_SCHL_ID_NUM', 'REP_ENTITY_ID_TXT', p_loan_rec.rep_entity_id_txt);
  ELSE
    IF p_loan_rec.rep_entity_id_txt > 99999999 THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'REP_SCHL_ID_MAX', 'REP_ENTITY_ID_TXT', p_loan_rec.rep_entity_id_txt);
    END IF;
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug',' Entity ID Check Over');
  END IF;

  IF p_loan_rec.fed_fund_code = 'DLP' THEN

    IF p_dl_version = '2004-2005' THEN
      -- validating borrower's date of birth
      IF parent_dtl_rec.p_date_of_birth < TO_DATE('01011905', 'DDMMYYYY') OR
         parent_dtl_rec.p_date_of_birth > TO_DATE('31121996', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INVALID_DOB0405', 'P_DATE_OF_BIRTH', parent_dtl_rec.p_date_of_birth);
      END IF;
    END IF;
    IF p_dl_version = '2005-2006' THEN
      -- validating borrower's date of birth
      IF parent_dtl_rec.p_date_of_birth < TO_DATE('01011906', 'DDMMYYYY') OR
         parent_dtl_rec.p_date_of_birth > TO_DATE('31121997', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INVALID_DOB0506', 'P_DATE_OF_BIRTH', parent_dtl_rec.p_date_of_birth);
      END IF;
    END IF;
    IF p_dl_version = '2006-2007' THEN
      -- validating borrower's date of birth
      IF parent_dtl_rec.p_date_of_birth < TO_DATE('01011907', 'DDMMYYYY') OR
         parent_dtl_rec.p_date_of_birth > TO_DATE('31121998', 'DDMMYYYY') THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INVALID_DOB0607', 'P_DATE_OF_BIRTH', parent_dtl_rec.p_date_of_birth);
      END IF;
    END IF;
    -- validating borrower's SSN
    IF ( (parent_dtl_rec.p_ssn < '001010001') OR (parent_dtl_rec.p_ssn > '999999998') ) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INVALID_SSN', 'P_SSN', parent_dtl_rec.p_ssn);
    END IF;

    -- validating borrower's first name
    IF ( LENGTH(parent_dtl_rec.p_first_name) > 12) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_FIRST_NAME', 'P_FIRST_NAME', parent_dtl_rec.p_first_name);
    END IF;

    -- validating borrower's last name
    IF ( LENGTH(parent_dtl_rec.p_last_name) > 35) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_LAST_NAME', 'P_LAST_NAME', parent_dtl_rec.p_last_name);
    END IF;

    -- validating borrower's address line 1
    IF ( (LENGTH(parent_dtl_rec.p_permt_addr1) < 1) OR (LENGTH(parent_dtl_rec.p_permt_addr1) > 40) ) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_ADDR_LINE', 'P_PERMT_ADDR1', parent_dtl_rec.p_permt_addr1);
    END IF;

  -- validating borrower's address line 2
    IF ( (LENGTH(parent_dtl_rec.p_permt_addr2) < 1) OR (LENGTH(parent_dtl_rec.p_permt_addr2) > 40) ) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_ADDR_LINE', 'P_PERMT_ADDR2', parent_dtl_rec.p_permt_addr2);
    END IF;

    -- validating borrower's city
    IF ( LENGTH(parent_dtl_rec.p_permt_city) > 24) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_CITY', 'P_PERMT_CITY', parent_dtl_rec.p_permt_city);
    END IF;

    -- validating borrower's E-MAIL
    IF ( LENGTH(parent_dtl_rec.p_email_addr) > 128) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_EMAIL', 'P_EMAIL_ADDR', parent_dtl_rec.p_email_addr);
    END IF;

    -- validating borrower's Phone Number
    l_p_phone := igf_sl_gen.get_person_phone(p_loan_rec.p_person_id);
    IF l_p_phone = 'N/A' THEN
       p_p_phone := NULL; --bug 4093556, When there is no phone number existing for a student then the phone number tag was populated using '000000000000' .
                          --This has being changed to NULL(akomurav)
    ELSE
      IF NOT validate_id(l_p_phone) THEN
        lv_complete := FALSE;
        igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_PHONE_NUM_D', 'P_PERMT_PHONE', l_p_phone);
      ELSE
        p_p_phone := l_p_phone;
      END IF;
      IF LENGTH(l_p_phone) > 17 OR LENGTH(l_p_phone) < 10 THEN
         lv_complete := FALSE;
         igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_PHONE_NUM', 'P_PERMT_PHONE', l_p_phone);
      END IF;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','l_p_phone  '|| l_p_phone);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','p_p_phone  '|| p_p_phone);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Before zip vali');
    END IF;

    -- validating borrower's Zip Code
    IF ( (LENGTH(parent_dtl_rec.p_permt_zip) < 5) OR (LENGTH(parent_dtl_rec.p_permt_zip) > 13) ) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_ZIP_CODE', 'P_PERMT_ZIP', parent_dtl_rec.p_permt_zip);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_permt_zip  '|| parent_dtl_rec.p_permt_zip);
    END IF;

    -- validating borrower's State Code
    IF ( (LENGTH(parent_dtl_rec.p_permt_state) < 2) OR (LENGTH(parent_dtl_rec.p_permt_state) > 3) ) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_STATE_CODE', 'P_PERMT_STATE', parent_dtl_rec.p_permt_state);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_permt_state  '|| parent_dtl_rec.p_permt_state);
    END IF;

    -- validating borrower's driver licencse number
    IF ( LENGTH(parent_dtl_rec.p_license_num) > 20) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_DRIV_LIC_NUM', 'P_LICENSE_NUM', parent_dtl_rec.p_license_num);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_license_num  '|| parent_dtl_rec.p_license_num);
    END IF;

    IF parent_dtl_rec.p_license_num IS NOT NULL AND  parent_dtl_rec.p_license_state IS NULL THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_DRIV_LIC_NUM_STATE', 'P_LICENSE_NUM', NULL);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_license_state  '|| parent_dtl_rec.p_license_state);
    END IF;

    IF parent_dtl_rec.p_license_state IS NOT NULL AND  parent_dtl_rec.p_license_num IS NULL THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_DRIV_LIC_STATE_NUM', 'P_LICENSE_ST', NULL);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_license_num  '|| parent_dtl_rec.p_license_num);
    END IF;

    -- validating borrower's citizenship status code
    IF ( LENGTH(parent_dtl_rec.p_citizenship_status) > 1) THEN
      lv_complete := FALSE;
      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', 'P_INV_CIT_STATUS', 'P_CITIZENSHIP_STATUS', parent_dtl_rec.p_citizenship_status);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','parent_dtl_rec.p_citizenship_status  '|| parent_dtl_rec.p_citizenship_status);
    END IF;

  END IF;

  -- museshad (Bug 4116399)  - Stafford loan limit validation
  IF p_loan_rec.fed_fund_code IN ('DLS', 'DLU') THEN
    lv_message     := NULL;
    lv_lookup_code  := NULL;

    loan_limit_validation (
                            p_base_id     =>    p_loan_rec.base_id,
                            p_fund_type   =>    p_loan_rec.fed_fund_code,
                            p_award_id    =>    p_loan_rec.award_id,
                            p_msg_name    =>    lv_message
                          );

    IF lv_message IS NOT NULL THEN
      -- Stafforf loan limit validation FAILED
      lv_complete := FALSE;

      IF lv_message = 'IGF_AW_AGGR_LMT_ERR' THEN
        lv_lookup_code := 'AGGR_LMT_CHK';
      ELSIF lv_message = 'IGF_AW_ANNUAL_LMT_ERR' THEN
        lv_lookup_code := 'ANNUAL_LMT_CHK';
      ELSIF lv_message = 'IGF_AW_SUB_AGGR_LMT_ERR' THEN
        lv_lookup_code := 'SUB_AGGR_LMT_CHK';
      ELSIF lv_message = 'IGF_AW_SUB_LMT_ERR' THEN
        lv_lookup_code := 'SUB_LMT_CHK';
      ELSIF lv_message = 'IGF_AW_LOAN_LMT_NOT_FND' THEN
        lv_lookup_code := 'LOAN_LMT_SETUP_CHK';
      END IF;

      igf_sl_edit.insert_edit(p_loan_rec.loan_number, 'V', 'IGF_SL_ERR_CODES', lv_lookup_code, NULL, NULL);

      -- Log
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Stafford loan limit validation for award_id ' ||p_loan_rec.award_id|| ' FAILED with message: ' ||lv_message);
      END IF;
    ELSE
      -- Stafforf loan limit validation PASSED
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.debug','Stafford loan limit validation PASSED for award_id ' ||p_loan_rec.award_id);
      END IF;
    END IF;
  END IF;
  -- museshad (Bug 4116399)

  IF lv_complete = FALSE AND p_call_from = 'JOB' THEN
    -- Display reject details on the Concurrent Manager Log File.
    DECLARE
    lv_log_mesg VARCHAR2(1000);
    CURSOR c_reject IS
      SELECT rpad(field_desc,50)||sl_error_desc reject_desc FROM igf_sl_edit_report_v
      WHERE  loan_number = p_loan_rec.loan_number
      AND    orig_chg_code = 'V';
    BEGIN
      fnd_file.put_line(fnd_file.log, '');
      fnd_file.put_line(fnd_file.log, '');
      lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_NUMBER')||' : '||p_loan_rec.loan_number;
      fnd_file.put_line(fnd_file.log, lv_log_mesg);
      lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_SSN')      ||' : '||student_dtl_rec.p_ssn;
      fnd_file.put_line(fnd_file.log, lv_log_mesg);
      lv_log_mesg := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','S_FULL_NAME')||' : '
                                                     ||student_dtl_rec.p_first_name||' '||student_dtl_rec.p_last_name;
      fnd_file.put_line(fnd_file.log, lv_log_mesg);
      FOR rej_rec IN c_reject LOOP
        fnd_file.put_line(fnd_file.log,'    '||rej_rec.reject_desc);
      END LOOP;
    END;
  END IF;

  RETURN lv_complete;

  EXCEPTION
  WHEN OTHERS THEN
  IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_validation.cod_loan_validations.exception','Exception:'||SQLERRM);
  END IF;
  fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
  fnd_message.set_token('NAME','IGF_SL_DL_VALIDATION.COD_LOAN_VALIDATIONS');
  igs_ge_msg_stack.add;
  app_exception.raise_exception;
END cod_loan_validations;


FUNCTION  cod_loan_validations ( p_cal_type   VARCHAR2, p_seq_number NUMBER,
                                 p_base_id    NUMBER,
                                 p_report_id  VARCHAR2,
                                 p_attend_id  VARCHAR2,
                                 p_fund_id    NUMBER,
                                 p_loan_id    NUMBER)
RETURN BOOLEAN
IS
  loan_rec       igf_sl_dl_gen_xml.cur_pick_loans_all_status%ROWTYPE;
  p_isir_ssn     VARCHAR2(30);
  p_isir_dob     DATE;
  p_isir_lname   VARCHAR2(100);
  p_isir_dep     VARCHAR2(1);
  p_isir_tnum    NUMBER;
  p_acad_begin   DATE;
  p_acad_end     DATE;
  p_s_phone      VARCHAR2(30);
  p_p_phone      VARCHAR2(30);

BEGIN
  OPEN igf_sl_dl_gen_xml.cur_pick_loans_all_status(p_cal_type, p_seq_number,
                                        p_base_id,
                                        p_report_id,
                                        p_attend_id,
                                        p_fund_id,
                                        p_loan_id);
  FETCH igf_sl_dl_gen_xml.cur_pick_loans_all_status INTO loan_rec;
  CLOSE igf_sl_dl_gen_xml.cur_pick_loans_all_status;

  loan_rec.grade_level_code := NVL(loan_rec.override_grade_level_code,loan_rec.grade_level_code);

  RETURN cod_loan_validations(loan_rec,'FORM',p_isir_ssn,
                              p_isir_dob,p_isir_lname,
                              p_isir_dep,p_isir_tnum,
                              p_acad_begin,p_acad_end,p_s_phone,p_p_phone);

END cod_loan_validations;

FUNCTION  check_full_participant  (
                                    p_ci_cal_type           IN igs_ca_inst_all.cal_type%TYPE,
                                    p_ci_sequence_number    IN igs_ca_inst_all.sequence_number%TYPE,
                                    p_fund_type             IN VARCHAR2
                                  )
RETURN BOOLEAN
AS
  /*************************************************************
  Created By : ugummall
  Date Created On : 01-OCT-2004
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  -- Cursor to get pell participant code and direct loan participant code
  CURSOR cur_get_participants_codes ( cp_cal_type         igs_ca_inst_all.cal_type%TYPE,
                                      cp_sequence_number  igs_ca_inst_all.sequence_number%TYPE) IS
    SELECT  bam.dl_participant_code, bam.pell_participant_code
      FROM  igf_ap_batch_aw_map_all bam
     WHERE  bam.ci_cal_type = cp_cal_type
      AND   bam.ci_sequence_number = cp_sequence_number
      AND   bam.award_year_status_code = 'O';

  rec_get_participants_codes  cur_get_participants_codes%ROWTYPE;

BEGIN

  IF (p_fund_type IS NULL OR p_ci_cal_type IS NULL OR p_ci_sequence_number IS NULL) THEN
    RETURN FALSE;
  END IF;

  -- open the cursor to get participant codes.
  OPEN cur_get_participants_codes(p_ci_cal_type, p_ci_sequence_number);
  FETCH cur_get_participants_codes INTO rec_get_participants_codes;
  IF cur_get_participants_codes%NOTFOUND THEN
    CLOSE cur_get_participants_codes;
    RETURN FALSE;
  ELSE
    CLOSE cur_get_participants_codes;
    IF (p_fund_type = 'PELL') THEN
      IF (rec_get_participants_codes.pell_participant_code = 'FULL_PARTICIPANT') THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSIF ( p_fund_type = 'DL') THEN
      IF (rec_get_participants_codes.dl_participant_code = 'FULL_PARTICIPANT') THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    ELSE
      RETURN FALSE;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_VALIDATION.CHECK_FULL_PARTICIPANT');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END check_full_participant;

FUNCTION validate_id (p_entity_id VARCHAR2)
RETURN BOOLEAN
IS
  lv_compare_str VARCHAR2(80);
  BEGIN
     lv_compare_str := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"[]{}`~!@#$%^&*_+=-,./?><():; ' ||'''';
     IF p_entity_id = TRANSLATE(UPPER(p_entity_id),lv_compare_str ,'1234567890') THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_validation.validate_id.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_VALIDATION.VALIDATE_ID');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

  END validate_id;

END igf_sl_dl_validation;

/
