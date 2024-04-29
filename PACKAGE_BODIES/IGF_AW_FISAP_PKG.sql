--------------------------------------------------------
--  DDL for Package Body IGF_AW_FISAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FISAP_PKG" AS
/* $Header: IGFAW22B.pls 120.9 2006/05/05 00:55:17 veramach noship $ */

  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

FUNCTION get_lookup_meaning ( p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
RETURN VARCHAR2 IS

  CURSOR  cur_igf_lookup ( cp_lookup_type IN VARCHAR2, cp_lookup_code IN VARCHAR2) IS
    SELECT  lkup.meaning
      FROM  IGF_LOOKUPS_VIEW lkup
     WHERE  lkup.lookup_type = cp_lookup_type
      AND   lkup.lookup_code = cp_lookup_code
      AND   lkup.enabled_flag = 'Y';

  CURSOR  cur_igs_lookup ( cp_lookup_type IN VARCHAR2, cp_lookup_code IN VARCHAR2) IS
    SELECT  lkup.meaning
      FROM  IGS_LOOKUPS_VIEW lkup
     WHERE  lkup.lookup_type = cp_lookup_type
      AND   lkup.lookup_code = cp_lookup_code
      AND   lkup.enabled_flag = 'Y';

  lv_meaning  VARCHAR2(80);

BEGIN
  IF p_lookup_type IS NULL OR p_lookup_code IS NULL THEN
    RETURN NULL;
  END IF;

  OPEN cur_igf_lookup(p_lookup_type, p_lookup_code);
  FETCH cur_igf_lookup INTO lv_meaning;
  IF cur_igf_lookup%NOTFOUND THEN
    CLOSE cur_igf_lookup;

    OPEN cur_igs_lookup(p_lookup_type, p_lookup_code);
    FETCH cur_igs_lookup INTO lv_meaning;
    CLOSE cur_igs_lookup;
  ELSE
    CLOSE cur_igf_lookup;
  END IF;

  RETURN lv_meaning;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.GET_LOOKUP_MEANING');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_lookup_meaning;

PROCEDURE log_input_parameters  ( lv_cal_type IN VARCHAR2,
                                  ln_seq_number IN NUMBER,
                                  p_retain_prev_batches IN VARCHAR2,
                                  p_descrption IN VARCHAR2
                                )
IS
  l_msg_str VARCHAR2(256);
BEGIN

  -- show heading
  l_msg_str :=  TRIM(get_lookup_meaning('IGF_GE_PARAMETERS', 'PARAMETER_PASS'));

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, l_msg_str); --------------Parameters Passed--------------
  fnd_file.new_line(fnd_file.log,1);

  -- show award year
  l_msg_str :=  RPAD(get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YEAR'),30) ||
                RPAD(igf_gr_gen.get_alt_code(lv_cal_type,ln_seq_number),20);
  fnd_file.put_line(fnd_file.log,l_msg_str);

  -- show retain previous batches
  IF (p_retain_prev_batches IS NOT NULL) THEN
    l_msg_str :=  RPAD(get_lookup_meaning('IGF_GE_PARAMETERS', 'RETAIN_PREV_BATCHES'),30) ||
                  RPAD(get_lookup_meaning('IGF_AP_YES_NO', p_retain_prev_batches),20);
    fnd_file.put_line(fnd_file.log,l_msg_str);
  END IF;

  -- show description
  IF (p_descrption IS NOT NULL) THEN
    l_msg_str :=  RPAD(get_lookup_meaning('IGF_GE_PARAMETERS', 'DESCRPTION'),30) || p_descrption;
    fnd_file.put_line(fnd_file.log,l_msg_str);
  END IF;

  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
  fnd_file.new_line(fnd_file.log,1);

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.LOG_INPUT_PARAMETERS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END log_input_parameters;

FUNCTION  is_eligible_aid_applicant (p_base_id  IN  NUMBER)
RETURN BOOLEAN IS

  CURSOR  cur_fa_program(cp_course_cd IN VARCHAR2, cp_version_number IN NUMBER) IS
    SELECT  federal_financial_aid
      FROM  IGS_PS_VER_V
     WHERE  course_cd = cp_course_cd
      AND   version_number =  cp_version_number;
  rec_fa_program  cur_fa_program%ROWTYPE;

  CURSOR  cur_citizenship_requirement(cp_base_id IN NUMBER) IS
    SELECT  DECODE(ins_match_flag, 'Y', 'Y', 'N') primary_dhs,
		        DECODE(sec_ins_match_flag, 'Y', 'Y', 'N') sec_dhs
      FROM  IGF_AP_ISIR_MATCHED
     WHERE  base_id = cp_base_id
      AND   active_isir = 'Y';
  rec_citizenship_requirement cur_citizenship_requirement%ROWTYPE;

  lv_course_cd        VARCHAR2(30);
  ln_version_number   NUMBER(12);

BEGIN
  -- 1st Condition
  -- Was enrolled in an academic or training program eligible for the campus-based program
  -- get student's key program and its version
  igf_ap_gen_001.get_key_program(p_base_id, lv_course_cd, ln_version_number);

  -- Check whether this program is FA Program with Federal Indicator Checked or not
  OPEN cur_fa_program(lv_course_cd, ln_version_number);
  FETCH cur_fa_program INTO rec_fa_program;
  CLOSE cur_fa_program;

  IF (rec_fa_program.federal_financial_aid IS NULL OR rec_fa_program.federal_financial_aid = 'N') THEN
    RETURN FALSE;
  END IF;

  -- 3rd Condition
  -- Applied for Financial Aid for award year.
  OPEN cur_citizenship_requirement(p_base_id);
  FETCH cur_citizenship_requirement INTO rec_citizenship_requirement;
  IF cur_citizenship_requirement%NOTFOUND THEN
    -- No active isir record found
    CLOSE cur_citizenship_requirement;
    RETURN FALSE;
  ELSE
    -- 3rd condition passed.
    -- Now, 2nd condition. Met citizenship or residency requirements for award year?
    IF NVL(rec_citizenship_requirement.primary_dhs, 'N') = 'N' AND NVL(rec_citizenship_requirement.sec_dhs, 'N') = 'N' THEN
      -- Neither primary nor secondary DHS Verification flag on the official ISIR is 'Y'
      CLOSE cur_citizenship_requirement;
      RETURN FALSE;
    END IF;
    CLOSE cur_citizenship_requirement;
  END IF;

  -- All conditions satisfied. He/she is eligible aid applicant
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.IS_ELIGIBLE_AID_APPLICANT');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END is_eligible_aid_applicant;

FUNCTION  get_student_career_level  (p_base_id  IN  NUMBER)
RETURN VARCHAR2 IS

  CURSOR  cur_fa_prog_type(cp_course_cd IN VARCHAR2, cp_version_number IN NUMBER) IS
    SELECT  cty.fin_aid_program_type
      FROM  IGS_PS_TYPE_ALL cty,
            IGS_PS_VER crv
     WHERE  crv.course_type = cty.course_type
      AND   crv.course_cd = cp_course_cd
      AND   crv.version_number = cp_version_number;
  rec_fa_prog_type  cur_fa_prog_type%ROWTYPE;

  CURSOR  cur_earned_degrees(cp_person_id NUMBER, cp_fa_program_type VARCHAR2) IS
    SELECT  ptype.fin_aid_program_type
      FROM  IGS_AD_ACAD_HISTORY_V acadhist,
            IGS_PS_DEGREES degree,
            IGS_PS_TYPE_ALL ptype
     WHERE  acadhist.degree_earned = degree.degree_cd
      AND   degree.program_type = ptype.course_type
      AND   acadhist.person_id = cp_person_id
      AND   ptype.fin_aid_program_type = cp_fa_program_type;
  rec_earned_degrees  cur_earned_degrees%ROWTYPE;

  CURSOR  cur_completed_prog(cp_person_id IN NUMBER) IS
    SELECT  course_cd
      FROM  IGS_EN_STDNT_PS_ATT_ALL
     WHERE  course_attempt_status = 'COMPLETED'
      AND   person_id  = cp_person_id;
  rec_completed_prog  cur_completed_prog%ROWTYPE;

  CURSOR  cur_completed_ugprog(cp_person_id NUMBER, cp_fa_program_type VARCHAR2) IS
    SELECT  cty.fin_aid_program_type
      FROM  IGS_EN_STDNT_PS_ATT_ALL statt,
            IGS_PS_TYPE_ALL cty,
            IGS_PS_VER crv
     WHERE  crv.course_cd = statt.course_cd
      AND   crv.version_number = statt.version_number
      AND   crv.course_type = cty.course_type
      AND   statt.course_attempt_status = 'COMPLETED'
      AND   statt.person_id  = cp_person_id
      AND   cty.fin_aid_program_type = cp_fa_program_type;
  rec_completed_ugprog  cur_completed_ugprog%ROWTYPE;

  CURSOR cur_get_personid(cp_base_id IN NUMBER) IS
    SELECT  person_id
      FROM  IGF_AP_FA_CON_V
     WHERE  base_id = cp_base_id;

  lv_course_cd        VARCHAR2(30);
  ln_version_number   NUMBER(12);
  lv_career_level     VARCHAR2(30);
  ln_person_id        NUMBER(12);

BEGIN

  lv_career_level := NULL;

  OPEN cur_get_personid(p_base_id);
  FETCH cur_get_personid INTO ln_person_id;
  CLOSE cur_get_personid;

  igf_ap_gen_001.get_key_program(p_base_id, lv_course_cd, ln_version_number);

  OPEN cur_fa_prog_type(lv_course_cd, ln_version_number);
  FETCH cur_fa_prog_type INTO rec_fa_prog_type;
  CLOSE cur_fa_prog_type;

  -- if student's key-program's FA program Type is Professional
  IF rec_fa_prog_type.fin_aid_program_type = 'PROFESSIONAL' THEN
    -- career level = "Grad/Prof"
    lv_career_level := 'GRAD_PROF';
  ELSE
    -- key-program's FA program type is Bachelors or Pre-bachelors

    -- if any of earned degrees is Graduate/Professional in acad history.
    rec_earned_degrees := NULL;
    OPEN cur_earned_degrees(ln_person_id, 'PROFESSIONAL');
    FETCH cur_earned_degrees INTO rec_earned_degrees;
    CLOSE cur_earned_degrees;
    IF rec_earned_degrees.fin_aid_program_type IS NOT NULL THEN
      -- career level = "Graduate or Professional"
      lv_career_level := 'GRAD_PROF';
    ELSE -- if any of earned degrees is Bachelors in acad history.
      rec_earned_degrees := NULL;
      OPEN cur_earned_degrees(ln_person_id, 'BACHELORS');
      FETCH cur_earned_degrees INTO rec_earned_degrees;
      CLOSE cur_earned_degrees;
      IF rec_earned_degrees.fin_aid_program_type IS NOT NULL THEN
        -- career level = "UG with degree"
        lv_career_level := 'UG_WITH';
      ELSE -- all earned degrees are Pre-bachelors in acad history.
        -- if there are no COMPLETED programs (in Student Attempt Programs).
        OPEN cur_completed_prog(ln_person_id);
        FETCH cur_completed_prog INTO rec_completed_prog;
        IF cur_completed_prog%NOTFOUND THEN
          -- career level = "UG without degree"
          CLOSE cur_completed_prog;
          lv_career_level := 'UG_WOUT';
        ELSE
          CLOSE cur_completed_prog;

          -- if any COMPLETED program is Graduate/Professional
          OPEN cur_completed_ugprog(ln_person_id, 'PROFESSIONAL');
          FETCH cur_completed_ugprog INTO rec_completed_ugprog;
          IF cur_completed_ugprog%NOTFOUND THEN
            -- No Graduate/Professional programs.
            CLOSE cur_completed_ugprog;
            -- Check for Bachelors
            OPEN cur_completed_ugprog(ln_person_id, 'BACHELORS');
            FETCH cur_completed_ugprog INTO rec_completed_ugprog;
            IF cur_completed_ugprog%NOTFOUND THEN
              -- means there are COMPLETED programs but all are pre-bachelors
              -- career level = "UG without degree"
              CLOSE cur_completed_ugprog;
              lv_career_level := 'UG_WOUT';
            ELSE
              -- career level = "UG with degree"
              CLOSE cur_completed_ugprog;
              lv_career_level := 'UG_WITH';
            END IF;
          ELSE
            -- career level = "Graduate or Professional"
            CLOSE cur_completed_ugprog;
            lv_career_level := 'GRAD_PROF';
          END IF;
        END IF;
      END IF;
    END IF;
  END IF;

  RETURN lv_career_level;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.GET_STUDENT_CAREER_LEVEL');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_student_career_level;

FUNCTION  get_student_enrollment_status (p_base_id  IN  NUMBER)
RETURN VARCHAR2 IS

  CURSOR cur_get_personid(cp_base_id IN NUMBER) IS
    SELECT  person_id
      FROM  IGF_AP_FA_CON_V
     WHERE  base_id = cp_base_id;

  term_enr_dtl_rec  igs_en_spa_terms%ROWTYPE;
  attendance_type   VARCHAR2(100);
  ln_person_id      NUMBER(15);
BEGIN
  -- get person id for the base id
  OPEN cur_get_personid(p_base_id);
  FETCH cur_get_personid INTO ln_person_id;
  CLOSE cur_get_personid;

  -- Get term enrollment details record
  -- Get course code and term calendar type and its sequence number
  igf_ap_gen_001.get_term_enrlmnt_dtl(p_base_id, term_enr_dtl_rec);

  -- Pass on these-three to get attendance type
  attendance_type := igs_en_prc_load.enrp_get_prg_att_type  ( ln_person_id,
                                                              term_enr_dtl_rec.program_cd,
                                                              term_enr_dtl_rec.term_cal_type,
                                                              term_enr_dtl_rec.term_sequence_number
                                                             );
  RETURN attendance_type;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.GET_STUDENT_ENROLLMENT_STATUS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_student_enrollment_status;

PROCEDURE submit_fisap_event  ( p_cal_type IN VARCHAR2, p_seq_number IN NUMBER, p_batch_id IN NUMBER)
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  l_parameter_list    wf_parameter_list_t;
  l_event_name        VARCHAR2(255);
  l_event_key         NUMBER;
  l_c_user_name       fnd_user.user_name%TYPE;
  l_batch_id          NUMBER;

  CURSOR cur_sequence IS SELECT IGF_GR_PELL_GEN_XML_S.NEXTVAL FROM DUAL;

BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap.submit_fisap_event','p_batch_id : ' || p_batch_id);
  END IF;

  l_parameter_list  :=  wf_parameter_list_t();
  l_event_name      :=  'oracle.apps.igf.aw.fisap';
  l_c_user_name     :=  fnd_global.user_name;
  l_batch_id        :=  p_batch_id;

  OPEN  cur_sequence;
  FETCH cur_sequence INTO l_event_key;
  CLOSE cur_sequence;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap.submit_fisap_event','l_event_key : '||l_event_key);
  END IF;

  -- Now add the parameters to the list to be passed to the workflow

  wf_event.addparametertolist(
     p_name          => 'USER_NAME',
     p_value         => l_c_user_name,
     p_parameterlist => l_parameter_list
     );
  wf_event.addparametertolist(
     p_name          => 'FISAP_DATA',
     p_value         => p_cal_type || ':' || p_seq_number,
     p_parameterlist => l_parameter_list
     );
  wf_event.addparametertolist(
     p_name          => 'BATCH_ID_PARAMETER',
     p_value         => l_batch_id,
     p_parameterlist => l_parameter_list
     );

  wf_event.RAISE (
    p_event_name      => l_event_name,
    p_event_key       => l_event_key,
    p_parameters      => l_parameter_list);

  fnd_message.set_name('IGF','IGF_AW_FISAP_RAISE_EVENT');
  fnd_message.set_token('EVENT_KEY_VALUE',l_event_key);
  fnd_file.new_line(fnd_file.log,1);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  fnd_file.new_line(fnd_file.log,1);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap.submit_fisap_event','raised event ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_fisap.submit_fisap_event.exception', 'Exception: ' || SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_AW_FISAP.SUBMIT_FISAP_EVENT');
    igs_ge_msg_stack.add;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap.submit_fisap_event.debug', 'SQLERRM: ' || SQLERRM);
    END IF;
    app_exception.raise_exception;
END submit_fisap_event;

PROCEDURE main  ( errbuf                OUT   NOCOPY  VARCHAR2,
                  retcode               OUT   NOCOPY  NUMBER,
                  p_award_year          IN            VARCHAR2,
                  p_retain_prev_batches IN            VARCHAR2,
                  p_descrption          IN            VARCHAR2
                )
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR  cur_fisap_rep(cp_batch_id NUMBER) IS
    SELECT  rep.ROWID row_id
      FROM  IGF_AW_FISAP_REP rep
     WHERE  rep.batch_id = cp_batch_id;

  CURSOR  cur_fisap_batch(cp_cal_type VARCHAR2, cp_seq_number NUMBER) IS
    SELECT  batch.ROWID row_id, batch.batch_id
      FROM  IGF_AW_FISAP_BATCH batch
     WHERE  batch.ci_cal_type = cp_cal_type
      AND   batch.ci_sequence_number = cp_seq_number;

  CURSOR  cur_students(cp_cal_type VARCHAR2, cp_seq_number NUMBER)  IS
    SELECT  fabase.base_id
		  FROM  igf_ap_fa_base_rec fabase
     WHERE  fabase.ci_cal_type = cp_cal_type
      AND   fabase.ci_sequence_number = cp_seq_number;
  rec_student cur_students%ROWTYPE;

  CURSOR  cur_isir_dtls(cp_base_id NUMBER)  IS
    SELECT  isir.dependency_status,
            isir.isir_id,
            DECODE(isir.auto_zero_efc, 'Y', 'Y', 'N') auto_zero_efc,
            isir.total_income,
            isir.student_total_income
      FROM  IGF_AP_ISIR_MATCHED isir
     WHERE  isir.base_id = cp_base_id
      AND   isir.active_isir = 'Y';
  rec_isir_dtls cur_isir_dtls%ROWTYPE;

  CURSOR  cur_any_cbfunds(cp_cal_type VARCHAR2, cp_seq_number NUMBER, cp_base_id NUMBER) IS
    SELECT  'X'
      FROM  IGF_AP_FA_BASE_REC_ALL fabase,
            IGF_AW_AWARD_ALL awd,
            IGF_AW_FUND_MAST_ALL fmast,
            IGF_AW_FUND_CAT_ALL fcat,
            IGS_CA_INST_ALL ca
     WHERE  ca.cal_type = fabase.ci_cal_type
      AND   ca.sequence_number = fabase.ci_sequence_number
      AND   fabase.base_id = awd.base_id
      AND   fmast.fund_id = awd.fund_id
      AND   fcat.fund_code = fmast.fund_code
      AND   ca.cal_type = cp_cal_type
      AND   ca.sequence_number = cp_seq_number
      AND   fabase.base_id = cp_base_id
      AND   ( fcat.fed_fund_code in ('FSEOG', 'PRK')
              OR  ( fcat.fed_fund_code = 'FWS' AND fcat.fund_source = 'FEDERAL')
            );

  CURSOR  cur_fws_amount(cp_base_id IN NUMBER) IS
    SELECT  SUM(NVL(pay.paid_amount, 0)) paid_amount
      FROM  IGF_SE_PAYMENT pay,
            IGF_SE_AUTH auth,
            IGF_AW_AWARD_ALL awd,
            IGF_AW_FUND_MAST_ALL fmast,
            IGF_AW_FUND_CAT_ALL fcat,
            IGF_AP_FA_BASE_REC_ALL fa
     WHERE  fcat.fund_code=fmast.fund_code
      AND   fcat.fed_fund_code='FWS'
      AND   fcat.fund_source='FEDERAL'
      AND   fmast.fund_id=awd.fund_id
      AND   awd.base_id=fa.base_id
      AND   awd.award_id=auth.award_id
      AND   auth.flag='A'
      AND   auth.auth_id=pay.auth_id
      AND   fa.ci_cal_type=fmast.ci_cal_type
      AND   fa.ci_sequence_number=fmast.ci_sequence_number
      AND   fa.base_id = cp_base_id
    GROUP BY  fa.base_id;

  CURSOR cur_perkins_amount(cp_base_id IN NUMBER) IS
    SELECT  SUM(NVL(disb.disb_paid_amt, 0)) paid_amount
      FROM  IGF_AP_FA_BASE_REC_ALL fabase,
            IGF_AW_AWARD_ALL awd,
            IGF_AW_AWD_DISB_ALL disb,
            IGF_AW_FUND_MAST_ALL fmast,
            IGF_AW_FUND_CAT_ALL fcat
     WHERE  fabase.base_id = awd.base_id
      AND   awd.award_id = disb.award_id
      AND   fmast.fund_id = awd.fund_id
      AND   fcat.fund_code = fmast.fund_code
      AND   fcat.fed_fund_code = 'PRK'
      AND   fabase.base_id = cp_base_id
      AND   disb.trans_type = 'A'
    GROUP BY fabase.base_id;

  CURSOR cur_fseog_amount(cp_base_id IN NUMBER) IS
    SELECT  SUM(NVL(disb.disb_paid_amt, 0)) paid_amount
      FROM  IGF_AP_FA_BASE_REC_ALL fabase,
            IGF_AW_AWARD_ALL awd,
            IGF_AW_AWD_DISB_ALL disb,
            IGF_AW_FUND_MAST_ALL fmast,
            IGF_AW_FUND_CAT_ALL fcat
     WHERE  fabase.base_id = awd.base_id
      AND   awd.award_id = disb.award_id
      AND   fmast.fund_id = awd.fund_id
      AND   fcat.fund_code = fmast.fund_code
      AND   fcat.fed_fund_code = 'FSEOG'
      AND   fabase.base_id = cp_base_id
      AND   disb.trans_type = 'A'
    GROUP BY fabase.base_id;

  ln_fisap_dtls_id      NUMBER(15);
  lv_part_II_flag       VARCHAR2(1);
  lv_part_VI_flag       VARCHAR2(1);
  ln_isir_id            NUMBER(15);
  lv_dependency_status  VARCHAR2(1);
  lv_auto_zero_efc      VARCHAR2(1);
  ln_fisap_income       NUMBER(15);
  lv_career_level       VARCHAR2(30);
  lv_enrollment_status  VARCHAR2(30);
  ln_perkins_disb_amt   NUMBER(15);
  ln_fseog_disb_amt     NUMBER(15);
  ln_fws_disb_amt       NUMBER(15);

  ln_batch_id           NUMBER(15);
  lv_reported_time_txt  VARCHAR2(30);
  lv_cal_type           VARCHAR2(30);
  ln_seq_number         NUMBER(15);
  cbfunds_flag          VARCHAR2(1);

  lv_batch_rowid        ROWID;
  lv_rep_rowid          ROWID;

BEGIN

  --
  --  Steps
  --  1. print parameters
  --  2. delete previous batches based on p_retain_prev_batches param
  --  3. inserts all eligible students in IGF_AW_FISAP_REP table.
  --  4. raise business event to send notification mail
  --

  igf_aw_gen.set_org_id(NULL);
  retcode := 0;
  ln_batch_id := NULL;
  lv_reported_time_txt := TO_CHAR(TRUNC(SYSDATE), 'YYYY-MM-DD') || 'T' || TO_CHAR(SYSDATE, 'HH:MM:SS');
  lv_cal_type :=  RTRIM(SUBSTR(p_award_year,1,10));
  ln_seq_number :=  TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug', 'p_award_year: ' || p_award_year);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug', 'award cal_type : ' || lv_cal_type);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug', 'award ci_seq_num : ' || ln_seq_number);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug', 'p_retain_prev_batches: ' || p_retain_prev_batches);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug', 'p_descrption: ' || p_descrption);
  END IF;

  --  Step 1. Print parameters
  log_input_parameters(lv_cal_type, ln_seq_number, p_retain_prev_batches, p_descrption);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','after log parameters');
  END IF;

  --  Step 2. Delete previous batches
  IF (p_retain_prev_batches = 'N') THEN
    FOR rec_fisap_batch IN cur_fisap_batch(lv_cal_type, ln_seq_number)
    LOOP
      -- delete from the child(reporting) table
      FOR rec_fisap_rep IN cur_fisap_rep(rec_fisap_batch.batch_id)
      LOOP
        igf_aw_fisap_rep_pkg.delete_row(rec_fisap_rep.row_id);
      END LOOP;

      -- delete from the parent(batch) table
      igf_aw_fisap_batch_pkg.delete_row(rec_fisap_batch.row_id);
    END LOOP;
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','after deleting previous batches');
  END IF;

  --  Step 3. Insert eligible aid applicants into reporting table.
  FOR rec_student IN cur_students(lv_cal_type, ln_seq_number)
  LOOP
    -- First we will insert a record for Part II. If the same student is considered in Part VI
    -- also then we update(not insert) the record. If a student is not considered in Part II,
    -- but in Part VI then we insert him in Part VI.

    ln_fisap_dtls_id      := NULL;
    lv_part_II_flag       := NULL;
    lv_part_VI_flag       := NULL;
    ln_isir_id            := NULL;
    lv_dependency_status  := NULL;
    lv_auto_zero_efc      := NULL;
    ln_fisap_income       := NULL;
    lv_career_level       := NULL;
    lv_enrollment_status  := NULL;
    ln_perkins_disb_amt   := NULL;
    ln_fseog_disb_amt     := NULL;
    ln_fws_disb_amt       := NULL;
    lv_batch_rowid        := NULL;
    lv_rep_rowid          := NULL;

    -- determine common fields
    OPEN cur_isir_dtls(rec_student.base_id);
    FETCH cur_isir_dtls INTO rec_isir_dtls;
    IF cur_isir_dtls%NOTFOUND THEN
      -- log an error message. And skip this student
      fnd_message.set_name('IGF','IGF_AW_FISAP_SKIP_NO_ISIR');
      fnd_message.set_token('PERNUM',igf_gr_gen.get_per_num(rec_student.base_id));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      CLOSE cur_isir_dtls;
    ELSE
      ln_isir_id := rec_isir_dtls.isir_id;
      lv_dependency_status := rec_isir_dtls.dependency_status;
      lv_auto_zero_efc := rec_isir_dtls.auto_zero_efc;
      lv_career_level := get_student_career_level(rec_student.base_id);
      IF  lv_career_level = 'GRAD_PROF' THEN
        -- If the student's career level is "Graduate/Professional" then
        -- consider his dependency status as "Independent"
        -- irrespective of the column value in IGF_AP_ISIR_MATCHED table.

        -- Override student's dependency status to Independent
        lv_dependency_status := 'I';
      END IF;

      IF (lv_dependency_status = 'I') THEN
        -- FISAP Income for Independent Students should be the Total Income (TI) as given in the Awarding ISIR
        ln_fisap_income := NVL(rec_isir_dtls.student_total_income, 0);
      ELSE
        -- FISAP Income for Dependent Students should be the Total Income (TI) + Student Total Income(STI), as given in the Awarding ISIR
        ln_fisap_income := NVL(rec_isir_dtls.total_income, 0) + NVL(rec_isir_dtls.student_total_income, 0);
      END IF;

      CLOSE cur_isir_dtls;

      -- if the student is Eligible Aid Applicant then only consider him/her for Part II
      IF is_eligible_aid_applicant(rec_student.base_id) THEN
        lv_part_II_flag := 'Y';

        IF ln_batch_id IS NULL THEN
          -- Insert batch record into IGF_AW_FISAP_BATCH table
          -- ONLY ONCE in the entire process and collect the
          -- primary key batch_id into lv_batch_id.
          igf_aw_fisap_batch_pkg.insert_row (
            x_rowid               =>  lv_batch_rowid,
            x_batch_id            =>  ln_batch_id,
            x_ci_cal_type         =>  lv_cal_type,
            x_ci_sequence_number  =>  ln_seq_number,
            x_description         =>  p_descrption,
            x_reported_time_txt   =>  lv_reported_time_txt,
            x_mode                =>  'R'
          );
        END IF;

        -- INSERT this record into the IGF_AW_FISAP_REP table
        -- call table handler to insert the record with the above calculated
        -- attributes and collect the primary key fisap_dtls_id which may be
        -- used in Part VI for updating record with Part VI information.
        igf_aw_fisap_rep_pkg.insert_row (
          x_rowid                   =>  lv_rep_rowid,
          x_fisap_dtls_id           =>  ln_fisap_dtls_id,
          x_batch_id                =>  ln_batch_id,
          x_isir_id                 =>  ln_isir_id,
          x_dependency_status       =>  lv_dependency_status,
          x_career_level            =>  lv_career_level,
          x_auto_zero_efc_flag      =>  lv_auto_zero_efc,
          x_fisap_income_amt        =>  ln_fisap_income,
          x_enrollment_status       =>  lv_enrollment_status,
          x_perkins_disb_amt        =>  ln_perkins_disb_amt,
          x_fws_disb_amt            =>  ln_fws_disb_amt,
          x_fseog_disb_amt          =>  ln_fseog_disb_amt,
          x_part_ii_section_f_flag  =>  lv_part_II_flag,
          x_part_vi_section_a_flag  =>  lv_part_VI_flag,
          x_mode                    =>  'R'
        );
      END IF;

      -- If the student is having any campus based funds(FSEOG, FWS, Perkins)
      -- then only consider him for Part VI
      cbfunds_flag  :=  NULL;
      OPEN cur_any_cbfunds(lv_cal_type, ln_seq_number, rec_student.base_id);
      FETCH cur_any_cbfunds INTO cbfunds_flag;
      CLOSE cur_any_cbfunds;

      IF cbfunds_flag = 'X' THEN
        --  consider this person for part VI
        lv_part_VI_flag := 'Y';
        --  Following extra fields need to be determined for Part VI.
        --  lv_enrollment_status
        --  ln_perkins_disb_amt
        --  ln_fseog_disb_amt
        --  ln_fws_disb_amt
        lv_enrollment_status := get_student_enrollment_status(rec_student.base_id);
        OPEN cur_fws_amount(rec_student.base_id);
        FETCH cur_fws_amount INTO ln_fws_disb_amt;
        CLOSE cur_fws_amount;

        OPEN cur_perkins_amount(rec_student.base_id);
        FETCH cur_perkins_amount INTO ln_perkins_disb_amt;
        CLOSE cur_perkins_amount;

        OPEN cur_fseog_amount(rec_student.base_id);
        FETCH cur_fseog_amount INTO ln_fseog_disb_amt;
        CLOSE cur_fseog_amount;

        IF ln_batch_id IS NULL THEN
          -- Insert batch record into IGF_AW_FISAP_BATCH table
          -- ONLY ONCE in the entire process and collect the
          -- primary key batch_id into lv_batch_id.
          igf_aw_fisap_batch_pkg.insert_row (
            x_rowid               =>  lv_batch_rowid,
            x_batch_id            =>  ln_batch_id,
            x_ci_cal_type         =>  lv_cal_type,
            x_ci_sequence_number  =>  ln_seq_number,
            x_description         =>  p_descrption,
            x_reported_time_txt   =>  lv_reported_time_txt,
            x_mode                =>  'R'
          );
        END IF;

        -- UPDATE/INSERT this record into the IGF_AW_FISAP_REP table
        igf_aw_fisap_rep_pkg.add_row  (
          x_rowid                   =>  lv_rep_rowid,
          x_fisap_dtls_id           =>  ln_fisap_dtls_id,
          x_batch_id                =>  ln_batch_id,
          x_isir_id                 =>  ln_isir_id,
          x_dependency_status       =>  lv_dependency_status,
          x_career_level            =>  lv_career_level,
          x_auto_zero_efc_flag      =>  lv_auto_zero_efc,
          x_fisap_income_amt        =>  ln_fisap_income,
          x_enrollment_status       =>  lv_enrollment_status,
          x_perkins_disb_amt        =>  ln_perkins_disb_amt,
          x_fws_disb_amt            =>  ln_fws_disb_amt,
          x_fseog_disb_amt          =>  ln_fseog_disb_amt,
          x_part_ii_section_f_flag  =>  lv_part_II_flag,
          x_part_vi_section_a_flag  =>  lv_part_VI_flag,
          x_mode                    =>  'R'
        );
      END IF;
    END IF;
  END LOOP;

  --  Step 4. Raise Business event.
  IF ln_batch_id IS NOT NULL THEN
    submit_fisap_event(lv_cal_type, ln_seq_number, ln_batch_id);
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log, SQLERRM);
    igs_ge_msg_stack.conc_exception_hndl;
END main;

PROCEDURE generate_aggregate_data ( itemtype        IN            VARCHAR2,
                                    itemkey         IN            VARCHAR2,
                                    actid           IN            NUMBER,
                                    funcmode        IN            VARCHAR2,
                                    resultout       OUT   NOCOPY  VARCHAR2
                                  )
AS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/
  ln_batch_id   NUMBER(15);
  ln_seq_number NUMBER(15);
  lv_cal_type   VARCHAR2(30);
  param         VARCHAR2(1000);
  loc           NUMBER(15);
BEGIN
  ln_batch_id := wf_engine.getitemattrtext ( itemtype, itemkey, 'BATCH_ID_PARAMETER');
  param := wf_engine.getitemattrtext ( itemtype, itemkey, 'FISAP_DATA');

  loc := instr(param, ':');
  lv_cal_type := substr(param, 1, loc - 1);
  param := substr(param, loc + 1);
  ln_seq_number := param;

  IF (funcmode  = 'RUN') THEN
    wf_engine.SetItemAttrText ( itemtype        => itemtype,
                                itemkey         => itemkey,
                                aname           => 'FISAP_DATA',
                                avalue          => 'PLSQLCLOB:igf_aw_fisap_pkg.generate_partII/'|| ln_batch_id || ':' || lv_cal_type || ':' || ln_seq_number);
    resultout:= 'COMPLETE:';
    RETURN;
  END IF;
END generate_aggregate_data;

PROCEDURE generate_partII ( document_id   IN              VARCHAR2,
                            display_type  IN              VARCHAR2,
                            document      IN  OUT NOCOPY  CLOB,
                            document_type IN  OUT NOCOPY  VARCHAR2
                          )
IS
/*************************************************************
Created By : ugummall
Date Created On : 2004/10/04
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  CURSOR  cur_2f_depend_smry ( cp_cal_type IN VARCHAR2, cp_seq_number IN NUMBER, cp_batch_id IN NUMBER) IS
    SELECT  fs.start_range_amt,
            fs.end_range_amt,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WOUT', 1, 0)) AS ug_wout,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WITH', 1, 0)) AS ug_with
      FROM  IGF_AW_FISAP_REP fisap,
            IGF_AW_FISAP_RANGES fs,
            IGF_AP_BATCH_AW_MAP_ALL awmap
     WHERE  awmap.ci_cal_type = cp_cal_type
      AND   awmap.ci_sequence_number = cp_seq_number
      AND   fs.sys_awd_yr = awmap.sys_award_year
      AND   fs.part_section = '2F'
      AND   fs.dependency_status = 'D'
      AND   fisap.batch_id(+) = cp_batch_id
      AND   fisap.fisap_income_amt(+) >=  fs.start_range_amt
      AND   fisap.fisap_income_amt(+) <= NVL(fs.end_range_amt, fisap.fisap_income_amt(+))
      AND   fisap.dependency_status(+) = 'D'
      AND   fisap.auto_zero_efc_flag(+) = 'N'
      AND   fisap.part_ii_section_f_flag(+) = 'Y'
      GROUP BY  fs.start_range_amt, fs.end_range_amt
      ORDER BY  fs.start_range_amt;
  rec_2f_depend_smry cur_2f_depend_smry%ROWTYPE;

  CURSOR  cur_2f_independ_smry ( cp_cal_type IN VARCHAR2, cp_seq_number IN NUMBER, cp_batch_id IN NUMBER) IS
    SELECT  fs.start_range_amt,
            fs.end_range_amt,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WOUT', 1, 0)) AS ug_wout,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WITH', 1, 0)) AS ug_with,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'GRAD_PROF', 1, 0)) AS grad_prof
      FROM  IGF_AW_FISAP_REP fisap,
            IGF_AW_FISAP_RANGES fs,
            IGF_AP_BATCH_AW_MAP_ALL awmap
     WHERE  awmap.ci_cal_type = cp_cal_type
      AND   awmap.ci_sequence_number = cp_seq_number
      AND   fs.sys_awd_yr = awmap.sys_award_year
      AND   fs.part_section = '2F'
      AND   fs.dependency_status = 'I'
      AND   fisap.batch_id(+) = cp_batch_id
      AND   fisap.fisap_income_amt(+) >=  fs.start_range_amt
      AND   fisap.fisap_income_amt(+) <= NVL(fs.end_range_amt, fisap.fisap_income_amt(+))
      AND   fisap.dependency_status(+) = 'I'
      AND   fisap.auto_zero_efc_flag(+) = 'N'
      AND   fisap.part_ii_section_f_flag(+) = 'Y'
      GROUP BY  fs.start_range_amt, fs.end_range_amt
      ORDER BY  fs.start_range_amt;
  rec_2f_independ_smry cur_2f_independ_smry%ROWTYPE;

  CURSOR  cur_2f_depend_efc ( cp_batch_id IN NUMBER)  IS
    SELECT  SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WOUT', 1, 0)) AS ug_wout,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WITH', 1, 0)) AS ug_with
      FROM  IGF_AW_FISAP_REP fisap
     WHERE  fisap.batch_id = cp_batch_id
      AND   fisap.dependency_status = 'D'
      AND   fisap.auto_zero_efc_flag = 'Y'
      AND   fisap.part_ii_section_f_flag = 'Y'
      GROUP BY fisap.batch_id;
  rec_2f_depend_efc cur_2f_depend_efc%ROWTYPE;

  CURSOR  cur_2f_independ_efc ( cp_batch_id IN  NUMBER) IS
    SELECT  SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WOUT', 1, 0)) AS ug_wout,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'UG_WITH', 1, 0)) AS ug_with,
            SUM(DECODE(NVL(fisap.career_level, 'ZERO'), 'GRAD_PROF', 1, 0)) AS grad_prof
      FROM  IGF_AW_FISAP_REP fisap
     WHERE  fisap.batch_id = cp_batch_id
      AND   fisap.dependency_status = 'I'
      AND   fisap.auto_zero_efc_flag = 'Y'
      AND   fisap.part_ii_section_f_flag = 'Y'
      GROUP by  fisap.batch_id;
  rec_2f_independ_efc cur_2f_independ_efc%ROWTYPE;

  CURSOR  cur_6a_ugdepend ( cp_cal_type IN VARCHAR2, cp_seq_number IN NUMBER, cp_batch_id IN NUMBER) IS
    SELECT  fs.start_range_amt,
            fs.end_range_amt,
            SUM(DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1)) AS a,
            SUM(NVL(fisap.perkins_disb_amt, 0)) AS b,
            SUM(DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1)) AS c,
            SUM(NVL(fisap.fseog_disb_amt, 0)) AS d,
            SUM(DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1)) AS e,
            SUM(NVL(fisap.fws_disb_amt, 0)) AS f,
            SUM(DECODE( DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1) ,
                        0, 0, 1
                      )
                ) g
      FROM  IGF_AW_FISAP_REP FISAP,
            IGF_AW_FISAP_RANGES FS,
            IGF_AP_BATCH_AW_MAP_ALL AWMAP
     WHERE  awmap.ci_cal_type = cp_cal_type
      AND   awmap.ci_sequence_number = cp_seq_number
            AND fs.sys_awd_yr = awmap.sys_award_year
            AND fs.part_section = '6A'
            AND fs.dependency_status = 'D'
            AND fisap.batch_id(+) = cp_batch_id
            AND fisap.fisap_income_amt(+) >=  fs.start_range_amt
            AND fisap.fisap_income_amt(+) <= NVL(fs.end_range_amt, fisap.fisap_income_amt(+))
            AND fisap.dependency_status(+) = 'D'
            AND fisap.career_level(+) <> 'GRAD_PROF'
            AND fisap.part_vi_section_a_flag(+) = 'Y'
      GROUP BY  fs.start_range_amt,
                fs.end_range_amt
      ORDER BY  fs.start_range_amt;
  rec_6a_ugdepend cur_6a_ugdepend%ROWTYPE;

  CURSOR  cur_6a_ugindepend ( cp_cal_type IN VARCHAR2, cp_seq_number IN NUMBER, cp_batch_id IN NUMBER) IS
    SELECT  fs.start_range_amt,
            fs.end_range_amt,
            SUM(DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1)) AS a,
            SUM(NVL(fisap.perkins_disb_amt, 0)) AS b,
            SUM(DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1)) AS c,
            SUM(NVL(fisap.fseog_disb_amt, 0)) AS d,
            SUM(DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1)) AS e,
            SUM(NVL(fisap.fws_disb_amt, 0)) AS f,
            SUM(DECODE( DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1) ,
                        0, 0, 1
                      )
                ) g
      FROM  IGF_AW_FISAP_REP fisap,
            IGF_AW_FISAP_RANGES fs,
            IGF_AP_BATCH_AW_MAP_ALL awmap
     WHERE  awmap.ci_cal_type = cp_cal_type
            AND awmap.ci_sequence_number = cp_seq_number
            AND fs.sys_awd_yr = awmap.sys_award_year
            AND fs.part_section = '6A'
            AND fs.dependency_status = 'I'
            AND fisap.batch_id(+) = cp_batch_id
            AND fisap.fisap_income_amt(+) >=  fs.start_range_amt
            AND fisap.fisap_income_amt(+) <= NVL(fs.end_range_amt, fisap.fisap_income_amt(+))
            AND fisap.dependency_status(+) = 'I'
            AND fisap.career_level(+) <> 'GRAD_PROF'
            AND fisap.part_vi_section_a_flag(+) = 'Y'
      GROUP BY  fs.start_range_amt,
                fs.end_range_amt
      ORDER BY  fs.start_range_amt;
  rec_6a_ugindepend cur_6a_ugindepend%ROWTYPE;

  CURSOR  cur_gradprof  ( cp_batch_id IN NUMBER) IS
    SELECT  SUM(DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1)) AS a,
            SUM(NVL(fisap.perkins_disb_amt, 0)) AS b,
            SUM(DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1)) AS e,
            SUM(NVL(fisap.fws_disb_amt, 0)) AS f,
            SUM(DECODE( DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1) ,
                        0, 0, 1
                      )
                ) g
      FROM  IGF_AW_FISAP_REP FISAP
     WHERE  fisap.batch_id = cp_batch_id
      AND   fisap.dependency_status = 'I'
      AND   fisap.career_level = 'GRAD_PROF'
      AND fisap.part_vi_section_a_flag = 'Y';
  rec_gradprof  cur_gradprof%ROWTYPE;

  CURSOR  cur_ltfulltime  ( cp_batch_id IN NUMBER) IS
    SELECT  SUM(DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1)) AS a,
            SUM(NVL(fisap.perkins_disb_amt, 0)) AS b,
            SUM(DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1)) AS c,
            SUM(NVL(fisap.fseog_disb_amt, 0)) AS d,
            SUM(DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1)) AS e,
            SUM(NVL(fisap.fws_disb_amt, 0)) AS f,
            SUM(DECODE( DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1) ,
                        0, 0, 1
                      )
                ) g
      FROM  IGF_AW_FISAP_REP fisap
     WHERE  fisap.batch_id = cp_batch_id
      AND   fisap.enrollment_status = 'FT'
      AND fisap.part_vi_section_a_flag = 'Y';
  rec_ltfulltime  cur_ltfulltime%ROWTYPE;

  CURSOR  cur_6a_efc  ( cp_batch_id IN NUMBER)  IS
    SELECT  SUM(DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1)) AS a,
            SUM(NVL(fisap.perkins_disb_amt, 0)) AS b,
            SUM(DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1)) AS c,
            SUM(NVL(fisap.fseog_disb_amt, 0)) AS d,
            SUM(DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1)) AS e,
            SUM(NVL(fisap.fws_disb_amt, 0)) AS f,
            SUM(DECODE( DECODE(NVL(fisap.perkins_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fseog_disb_amt, -1), -1, 0, 1) +
                        DECODE(NVL(fisap.fws_disb_amt, -1), -1, 0, 1) ,
                        0, 0, 1
                      )
                ) g
      FROM  IGF_AW_FISAP_REP fisap
     WHERE  fisap.batch_id = cp_batch_id
      AND   fisap.auto_zero_efc_flag = 'Y'
      AND   fisap.part_vi_section_a_flag = 'Y';
  rec_6a_efc  cur_6a_efc%ROWTYPE;

  l_c_document              VARCHAR2(32000);
  param                     VARCHAR2(1000);
  ln_batch_id               NUMBER(15);
  ln_seq_number             NUMBER(15);
  lv_cal_type               VARCHAR2(100);
  lv_and_over_mesg          VARCHAR2(100);
  end_range_amt_txt         VARCHAR2(100);
  loc                       NUMBER(15);
  ln_depend_ugwout_total    NUMBER(15);
  ln_depend_ugwith_total    NUMBER(15);
  ln_independ_ugwout_total  NUMBER(15);
  ln_independ_ugwith_total  NUMBER(15);
  ln_independ_gp_total      NUMBER(15);
  ln_total_a                NUMBER(15);
  ln_total_b                NUMBER(15);
  ln_total_c                NUMBER(15);
  ln_total_d                NUMBER(15);
  ln_total_e                NUMBER(15);
  ln_total_f                NUMBER(15);
  ln_total_g                NUMBER(15);
  ln_line_num               NUMBER(15);

BEGIN

  ln_total_a := 0;
  ln_total_b := 0;
  ln_total_c := 0;
  ln_total_d := 0;
  ln_total_e := 0;
  ln_total_f := 0;
  ln_total_g := 0;
  ln_line_num := 0;

  ln_depend_ugwout_total := 0;
  ln_depend_ugwith_total := 0;
  ln_independ_ugwout_total := 0;
  ln_independ_ugwith_total := 0;
  ln_independ_gp_total := 0;

  -- Extract parameters from the document_id parameter.
  param := document_id;
  loc := instr(param, ':');
  ln_batch_id := substr(param, 1, loc - 1);
  param := substr(param, loc + 1);

  loc := instr(param, ':');
  lv_cal_type := substr(param, 1, loc - 1);
  param := substr(param, loc + 1);
  ln_seq_number := param;

  -- Part II Heading.
  l_c_document := '<p><B>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','2F_HEADING') || '</B><br><br>';

  -- Part II Column Headings.
  l_c_document := l_c_document || '<table BORDER COLS=7 WIDTH="90%"><tr bgcolor="#C0C0C0"><td colspan=3 width=30%><b>';
  l_c_document := l_c_document || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','D') || '</b></td><td colspan=4 width=40%><b>';
  l_c_document := l_c_document || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','I') || '</b></td></tr>';

  l_c_document := l_c_document||'<tr bgcolor="#C0C0C0"><td width=10%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TAXUNTAX');
  l_c_document := l_c_document||'</td><td width=10%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UGWOUT') || '</td>';

  l_c_document := l_c_document||'<td width=10%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UGWITH') || '</td><td width=10%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TAXUNTAX') || '</td><td width=10%>';

  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UGWOUT') || '</td>';

  l_c_document := l_c_document||'<td width=10%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UGWITH') || '</td><td width=10%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','GRAD_PROF') || '</td></tr>';

  -- Part II. Eligible Aid Grid data. Auto Zero EFC Row.
  OPEN cur_2f_depend_efc(ln_batch_id);
  FETCH cur_2f_depend_efc INTO rec_2f_depend_efc;
  CLOSE cur_2f_depend_efc;

  ln_depend_ugwout_total := NVL(rec_2f_depend_efc.ug_wout, 0);
  ln_depend_ugwith_total := NVL(rec_2f_depend_efc.ug_with, 0);

  OPEN cur_2f_independ_efc(ln_batch_id);
  FETCH cur_2f_independ_efc INTO rec_2f_independ_efc;
  CLOSE cur_2f_independ_efc;

  ln_independ_ugwout_total := NVL(rec_2f_independ_efc.ug_wout, 0);
  ln_independ_ugwith_total := NVL(rec_2f_independ_efc.ug_with, 0);
  ln_independ_gp_total := NVL(rec_2f_independ_efc.grad_prof, 0);

  l_c_document := l_c_document || '<tr><td width=10%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','WITH_AUTO_ZERO_EFC');
  l_c_document := l_c_document || '</td><td width=10%>' || NVL(rec_2f_depend_efc.ug_wout, 0) || '</td><td width=10%>' || NVL(rec_2f_depend_efc.ug_with, 0) || '</td><td width=10%>';
  l_c_document := l_c_document || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','WITH_AUTO_ZERO_EFC') || '</td>';
  l_c_document := l_c_document || '<td width=10%>' || NVL(rec_2f_independ_efc.ug_wout, 0) || '</td><td width=10%>';
  l_c_document := l_c_document || NVL(rec_2f_independ_efc.ug_with, 0) || '</td><td width=10%>' || NVL(rec_2f_independ_efc.grad_prof, 0) || '</td></tr>';

  -- Part II. Eligible Aid Grid data. 14 Rows.
  OPEN cur_2f_depend_smry(lv_cal_type, ln_seq_number, ln_batch_id);
  OPEN cur_2f_independ_smry(lv_cal_type, ln_seq_number, ln_batch_id);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'Part II 1-14 rows cursor parameter values(cal type, seq no, batch id): ' || lv_cal_type || ', ' || ln_seq_number || ', ' || ln_batch_id);
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'Before entering Part II 14 rows loop');
  END IF;

  lv_and_over_mesg :=  get_lookup_meaning('IGF_AW_FISAP_HTML_REP','AND_OVER');
  LOOP
    FETCH cur_2f_depend_smry INTO rec_2f_depend_smry;
    FETCH cur_2f_independ_smry INTO rec_2f_independ_smry;

    IF cur_2f_depend_smry%NOTFOUND AND cur_2f_independ_smry%NOTFOUND THEN
      EXIT;
    END IF;

    l_c_document := l_c_document || '<tr><td width=10%>$' || rec_2f_depend_smry.start_range_amt;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', '2F Depend Start range = ' || rec_2f_depend_smry.start_range_amt);
    END IF;

    IF rec_2f_depend_smry.end_range_amt IS NULL THEN
      end_range_amt_txt := ' ' || lv_and_over_mesg;
    ELSE
      end_range_amt_txt := ' - $' || rec_2f_depend_smry.end_range_amt;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', '2F Depend Start range = ' || end_range_amt_txt);
    END IF;

    l_c_document := l_c_document || end_range_amt_txt || '</td><td width=10%>';
    l_c_document := l_c_document || NVL(rec_2f_depend_smry.ug_wout, 0)|| '</td><td width=10%>';
    l_c_document := l_c_document || NVL(rec_2f_depend_smry.ug_with, 0);
    l_c_document := l_c_document || '</td><td width=10%>$' || rec_2f_independ_smry.start_range_amt;
    IF rec_2f_independ_smry.end_range_amt IS NULL THEN
      end_range_amt_txt := ' ' || lv_and_over_mesg;
    ELSE
      end_range_amt_txt := ' - $' || rec_2f_independ_smry.end_range_amt;
    END IF;
    l_c_document := l_c_document || end_range_amt_txt || '</td><td width=10%>';
    l_c_document := l_c_document || NVL(rec_2f_independ_smry.ug_wout, 0) || '</td><td width=10%>';
    l_c_document := l_c_document || NVL(rec_2f_independ_smry.ug_with, 0) || '</td><td width=10%>';
    l_c_document := l_c_document || NVL(rec_2f_independ_smry.grad_prof, 0) || '</td></tr>';
    ln_depend_ugwout_total := ln_depend_ugwout_total + NVL(rec_2f_depend_smry.ug_wout, 0);
    ln_depend_ugwith_total := ln_depend_ugwith_total + NVL(rec_2f_depend_smry.ug_with, 0);
    ln_independ_ugwout_total := ln_independ_ugwout_total + NVL(rec_2f_independ_smry.ug_wout, 0);
    ln_independ_ugwith_total := ln_independ_ugwith_total + NVL(rec_2f_independ_smry.ug_with, 0);
    ln_independ_gp_total := ln_independ_gp_total + NVL(rec_2f_independ_smry.grad_prof, 0);
  END LOOP;
  CLOSE cur_2f_depend_smry;
  CLOSE cur_2f_independ_smry;

  -- Part II. Totals.
  l_c_document := l_c_document || '<tr bgcolor="#C0C0C0"><td width=10%><b>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TOTAL');
  l_c_document := l_c_document || '</b></td><td width=10%>' || ln_depend_ugwout_total || '</td><td width=10%>' || ln_depend_ugwith_total || '</td><td width=10%><b>';
  l_c_document := l_c_document || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TOTAL') || '</b></td><td width=10%>';
  l_c_document := l_c_document || ln_independ_ugwout_total || '</td><td width=10%>' || ln_independ_ugwith_total || '</td><td width=10%>' || ln_independ_gp_total || '</a></td></tr>';

  l_c_document := l_c_document||'</table>';

  -- Part VI Heading.
  l_c_document := l_c_document||'<p><B>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','6A_HEADING') || '</B><br><br>';

  -- Part VI Column Headings.
  l_c_document := l_c_document||'<table BORDER COLS=9 WIDTH="90%"><tr bgcolor="#C0C0C0"><td colspan=2 rowspan=2 width=22%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TAXUNTAX_CAT') || '</td>';
  l_c_document := l_c_document||'<td colspan=2 width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','PERKINS') || '</td><td colspan=2 width=22%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','FSEOG') || '</td><td colspan=2 width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','FWS') ||'</td>';
  l_c_document := l_c_document||'<td colspan=1 rowspan=2 width=11%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UNDUPLICATED_REC_G') || '</td></tr>';

  l_c_document := l_c_document||'<tr bgcolor="#C0C0C0"><td width=11%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','REC_A');
  l_c_document := l_c_document||'</td><td width=11%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','FUNDS_B') || '</td><td width=11%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','REC_C') || '</td><td width=11%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','FUNDS_D') || '</td>';

  l_c_document := l_c_document||'<td width=11%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','REC_E') || '</td><td width=11%>';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','FUNDS_F') || '</td></tr>';

  l_c_document := l_c_document||'<tr bgcolor="#C0C0C0"><td colspan=9 width=22%><b>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UG_D') || '</b></td></tr>';

  -- Rows 1 to 7. Undergraduate Depedent.
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'Before entering Part VI 1-7 Ug Dependent loop');
  END IF;
  FOR rec IN cur_6a_ugdepend(lv_cal_type, ln_seq_number, ln_batch_id) LOOP
    ln_line_num :=  ln_line_num + 1;
    l_c_document := l_c_document || '<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>$';
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'preparing row# ' || ln_line_num || ' of Part VI 1-7 rows');
    END IF;

    IF rec.end_range_amt IS NULL THEN
      end_range_amt_txt := ' ' || lv_and_over_mesg;
    ELSE
      end_range_amt_txt := '- $' || rec.end_range_amt;
    END IF;
    l_c_document := l_c_document || rec.start_range_amt || end_range_amt_txt;

    l_c_document := l_c_document || '</td><td width=22%>' || rec.a || '</td><td width=22%>' || rec.b;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.c || '</td><td width=22%>' || rec.d;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.e || '</td><td width=22%>' || rec.f;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.g || '</td></tr>';

    ln_total_a := ln_total_a + rec.a;
    ln_total_b := ln_total_b + rec.b;
    ln_total_c := ln_total_c + rec.c;
    ln_total_d := ln_total_d + rec.d;
    ln_total_e := ln_total_e + rec.e;
    ln_total_f := ln_total_f + rec.f;
    ln_total_g := ln_total_g + rec.g;
  END LOOP;

  l_c_document := l_c_document || '<tr bgcolor="#C0C0C0"><td colspan=9 width=22%><b>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','UG_I') || '</b></td></tr>';

  -- Rows 8 to 14. Undergraduate Indepedent.
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'Before entering Part VI 8-14 Ug Independent loop');
  END IF;
  FOR rec IN cur_6a_ugindepend(lv_cal_type, ln_seq_number, ln_batch_id) LOOP
    ln_line_num :=  ln_line_num + 1;
    l_c_document := l_c_document || '<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>$';
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_fisap_pkg.generate_partII.debug', 'preparing row# ' || ln_line_num || ' of Part VI 8-14 rows');
    END IF;

    IF rec.end_range_amt IS NULL THEN
      end_range_amt_txt := ' ' || lv_and_over_mesg;
    ELSE
      end_range_amt_txt := '- $' || rec.end_range_amt;
    END IF;
    l_c_document := l_c_document || rec.start_range_amt || end_range_amt_txt;

    l_c_document := l_c_document || '</td><td width=22%>' || rec.a || '</td><td width=22%>' || rec.b;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.c || '</td><td width=22%>' || rec.d;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.e || '</td><td width=22%>' || rec.f;
    l_c_document := l_c_document || '</td><td width=22%>' || rec.g || '</td></tr>';

    ln_total_a := ln_total_a + rec.a;
    ln_total_b := ln_total_b + rec.b;
    ln_total_c := ln_total_c + rec.c;
    ln_total_d := ln_total_d + rec.d;
    ln_total_e := ln_total_e + rec.e;
    ln_total_f := ln_total_f + rec.f;
    ln_total_g := ln_total_g + rec.g;
  END LOOP;

  -- 15th Row. Graduate/Professional.
  OPEN cur_gradprof(ln_batch_id);
  FETCH cur_gradprof INTO rec_gradprof;
  CLOSE cur_gradprof;

  ln_line_num :=  ln_line_num + 1;

  l_c_document := l_c_document||'<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','GRAD_PROF');
  l_c_document := l_c_document||'</td><td width=22%>' || NVL(rec_gradprof.a, 0) || '</td><td width=22%>' || NVL(rec_gradprof.b, 0) || '</td><td width=22% bgcolor="#C0C0C0">';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','DOES_NOT_APPLY') || '</td><td width=22% bgcolor="#C0C0C0">';
  l_c_document := l_c_document||get_lookup_meaning('IGF_AW_FISAP_HTML_REP','DOES_NOT_APPLY') || '</td>';
  l_c_document := l_c_document||'<td width=22%>' || NVL(rec_gradprof.e, 0) || '</td><td width=22%>' || NVL(rec_gradprof.f, 0) || '</td><td width=22%>' || NVL(rec_gradprof.g, 0) || '</td></tr>';

  ln_total_a := ln_total_a + NVL(rec_gradprof.a, 0);
  ln_total_b := ln_total_b + NVL(rec_gradprof.b, 0);
  --ln_total_c := ln_total_c + NVL(rec_gradprof.c, 0); -- Does Not Apply
  --ln_total_d := ln_total_d + NVL(rec_gradprof.d, 0); -- Does Not Apply
  ln_total_e := ln_total_e + NVL(rec_gradprof.e, 0);
  ln_total_f := ln_total_f + NVL(rec_gradprof.f, 0);
  ln_total_g := ln_total_g + NVL(rec_gradprof.g, 0);

  -- 16th Row. Totals.
  ln_line_num :=  ln_line_num + 1;
  l_c_document := l_c_document || '<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TOTAL');
  l_c_document := l_c_document || '</td><td width=22%>' || ln_total_a || '</td><td width=22%>' || ln_total_b || '</td><td width=22%>' || ln_total_c;
  l_c_document := l_c_document || '</td><td width=22%>' || ln_total_d || '</td><td width=22%>' || ln_total_e || '</td><td width=22%>' || ln_total_f;
  l_c_document := l_c_document || '</td><td width=22%>' || ln_total_g || '</td></tr>';

  -- 17th Row. Total less than full time students.
  OPEN cur_ltfulltime(ln_batch_id);
  FETCH cur_ltfulltime INTO rec_ltfulltime;
  CLOSE cur_ltfulltime;

  ln_line_num :=  ln_line_num + 1;
  l_c_document := l_c_document || '<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TOTAL_LT_FT');
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_ltfulltime.a, 0) || '</td><td width=22%>' || NVL(rec_ltfulltime.b, 0) || '</td><td width=22%>' || NVL(rec_ltfulltime.c, 0);
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_ltfulltime.d, 0) || '</td><td width=22%>' || NVL(rec_ltfulltime.e, 0) || '</td><td width=22%>' || NVL(rec_ltfulltime.f, 0);
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_ltfulltime.g, 0) || '</td></tr>';

  -- 18th Row. Total "Automatic Zero EFC" students
  OPEN cur_6a_efc(ln_batch_id);
  FETCH cur_6a_efc INTO rec_6a_efc;
  CLOSE cur_6a_efc;

  ln_line_num :=  ln_line_num + 1;
  l_c_document := l_c_document || '<tr bgcolor="#ffffff"><td width=22%>' || ln_line_num || '</td><td width=22%>' || get_lookup_meaning('IGF_AW_FISAP_HTML_REP','TOTAL_AUTO_ZERO_EFC');
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_6a_efc.a, 0) || '</td><td width=22%>' || NVL(rec_6a_efc.b, 0) || '</td><td width=22%>' || NVL(rec_6a_efc.c, 0);
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_6a_efc.d, 0) || '</td><td width=22%>' || NVL(rec_6a_efc.e, 0) || '</td><td width=22%>' || NVL(rec_6a_efc.f, 0);
  l_c_document := l_c_document || '</td><td width=22%>' || NVL(rec_6a_efc.g, 0) || '</td></tr>';

  l_c_document := l_c_document||'</table>';

  WF_NOTIFICATION.WriteToClob(document, l_c_document);

END generate_partII;

END IGF_AW_FISAP_PKG;

/
