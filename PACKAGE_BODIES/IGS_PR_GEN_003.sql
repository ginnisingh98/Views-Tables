--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_003" AS
/* $Header: IGSPR24B.pls 115.13 2004/01/08 14:05:53 kdande ship $ */
PROCEDURE IGS_PR_GET_CAL_PARM(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_level OUT NOCOPY VARCHAR2 ,
  p_org_unit_cd OUT NOCOPY VARCHAR2 ,
  p_ou_start_dt OUT NOCOPY DATE ,
  p_stream_number OUT NOCOPY NUMBER ,
  p_show_cause_length OUT NOCOPY NUMBER ,
  p_appeal_length OUT NOCOPY NUMBER )
IS
  gv_other_detail     VARCHAR2(255);
BEGIN   -- IGS_PR_GET_CAL_PARM
  -- Get the configuration parameters for a calendar type from the relevant
  -- level of the configuration structure. This routine also checks the level
  -- at which the parameters are defined by calling another routine.
DECLARE
  cst_course  CONSTANT  VARCHAR2(10) := 'COURSE';
  cst_ou    CONSTANT  VARCHAR2(10) := 'OU';
  v_basic_level     VARCHAR2(10);
  v_calendar_level      VARCHAR2(10);
  v_org_unit_cd     IGS_OR_UNIT.org_unit_cd%TYPE;
  v_ou_start_dt     IGS_OR_UNIT.start_dt%TYPE;
  v_stream_number     IGS_PR_S_PRG_CAL.stream_num%TYPE;
  v_show_cause_length   IGS_PR_S_PRG_CAL.show_cause_length%TYPE;
  v_appeal_length     IGS_PR_S_PRG_CAL.appeal_length%TYPE;
  CURSOR c_scpca IS
    SELECT  scpca.stream_num,
      scpca.show_cause_length,
      scpca.appeal_length
    FROM  IGS_PR_S_CRV_PRG_CAL    scpca
    WHERE scpca.course_cd   = p_course_cd AND
      scpca.version_number  = p_version_number AND
      scpca.prg_cal_type  = p_prg_cal_type;
  CURSOR c_sopca (
    cp_org_unit_cd      IGS_OR_UNIT.org_unit_cd%TYPE,
    cp_ou_start_dt      IGS_OR_UNIT.start_dt%TYPE) IS
    SELECT  sopca.stream_num,
      sopca.show_cause_length,
      sopca.appeal_length
    FROM  IGS_PR_S_OU_PRG_CAL     sopca
    WHERE sopca.org_unit_cd   = cp_org_unit_cd AND
      sopca.ou_start_dt   = cp_ou_start_dt AND
      sopca.prg_cal_type  = p_prg_cal_type;
  CURSOR c_spca IS
    SELECT  spca.stream_num,
      spca.show_cause_length,
      spca.appeal_length
    FROM  IGS_PR_S_PRG_CAL    spca
    WHERE spca.s_control_num  = 1 AND
      spca.prg_cal_type   = p_prg_cal_type;
BEGIN
  -- Call routine to determine configuration level
  IGS_PR_GET_CONFIG_LVL (
        p_course_cd,
        p_version_number,
        v_basic_level,
        v_calendar_level,
        v_org_unit_cd,
        v_ou_start_dt);
  p_level := v_calendar_level;
  p_org_unit_cd := v_org_unit_cd;
  p_ou_start_dt := v_ou_start_dt;
  IF v_calendar_level = cst_course THEN
    OPEN c_scpca;
    FETCH c_scpca INTO
        v_stream_number,
        v_show_cause_length,
        v_appeal_length;
    IF c_scpca%FOUND THEN
      CLOSE c_scpca;
      p_stream_number := v_stream_number;
      p_show_cause_length := v_show_cause_length;
      p_appeal_length := v_appeal_length;
      RETURN;
    END IF;
    CLOSE c_scpca;
    p_level := NULL;
    RETURN;
  ELSIF v_calendar_level = cst_ou THEN
    OPEN c_sopca (
        v_org_unit_cd,
        v_ou_start_dt);
    FETCH c_sopca INTO
        v_stream_number,
        v_show_cause_length,
        v_appeal_length;
    IF c_sopca%FOUND THEN
      CLOSE c_sopca;
      p_stream_number := v_stream_number;
      p_show_cause_length := v_show_cause_length;
      p_appeal_length := v_appeal_length;
      RETURN;
    END IF;
    CLOSE c_sopca;
    p_level := NULL;
    RETURN;
  ELSE
    OPEN c_spca;
    FETCH c_spca INTO
        v_stream_number,
        v_show_cause_length,
        v_appeal_length;
    IF c_spca%FOUND THEN
      CLOSE c_spca;
      p_stream_number := v_stream_number;
      p_show_cause_length := v_show_cause_length;
      p_appeal_length := v_appeal_length;
      RETURN;
    END IF;
    CLOSE c_spca;
    p_level := NULL;
    RETURN;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_scpca%ISOPEN THEN
      CLOSE c_scpca;
    END IF;
    IF c_sopca%ISOPEN THEN
      CLOSE c_sopca;
    END IF;
    IF c_spca%ISOPEN THEN
      CLOSE c_spca;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_GET_CAL_PARM;
PROCEDURE IGS_PR_GET_CONFIG_LVL(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_basic_level OUT NOCOPY VARCHAR2 ,
  p_calendar_level OUT NOCOPY VARCHAR2 ,
  p_org_unit_cd OUT NOCOPY VARCHAR2 ,
  p_ou_start_dt OUT NOCOPY DATE )
IS
  gv_other_detail     VARCHAR2(255);
BEGIN   -- IGS_PR_GET_CONFIG_LVL
  -- Get the system configuration level that applies to a nominated course
  -- version.
  -- Determines at what level the configuration parameters have been specified
  -- for a nominated course version. Looks for both base configuration
  -- parameters and calendar configuration parameters.
  -- If the level is organisational unit, then the org unit code is also
  -- returned in OUT NOCOPY parameters.
DECLARE
  cst_course  CONSTANT  VARCHAR2(10) := 'COURSE';
  cst_system  CONSTANT  VARCHAR2(10) := 'SYSTEM';
  cst_ou    CONSTANT  VARCHAR2(10) := 'OU';
  v_org_unit_cd     IGS_PR_S_OU_PRG_CONF.org_unit_cd%TYPE;
  v_ou_start_dt     IGS_PR_S_OU_PRG_CONF.ou_start_dt%TYPE;
  v_dummy       VARCHAR2(1);
  CURSOR c_scpc IS
    SELECT  'X'
    FROM  IGS_PR_S_CRV_PRG_CON      scpc
    WHERE scpc.course_cd      = p_course_cd AND
      scpc.version_number     = p_version_number;
  CURSOR c_scpca IS
    SELECT  'X'
    FROM  IGS_PR_S_CRV_PRG_CAL      scpca
    WHERE scpca.course_cd     = p_course_cd AND
      scpca.version_number    = p_version_number;
  CURSOR c_sopc IS
    SELECT  sopc.org_unit_cd,
      sopc.ou_start_dt
    FROM  IGS_PR_S_OU_PRG_CONF      sopc
    WHERE IGS_PR_GEN_001.PRGP_GET_CRV_CMT (
        p_course_cd,
        p_version_number,
        sopc.org_unit_cd,
        sopc.ou_start_dt)   = 'Y';
  CURSOR c_sopca IS
    SELECT  sopca.org_unit_cd,
      sopca.ou_start_dt
    FROM  IGS_PR_S_OU_PRG_CAL       sopca
    WHERE IGS_PR_GEN_001.PRGP_GET_CRV_CMT (
        p_course_cd,
        p_version_number,
        sopca.org_unit_cd,
        sopca.ou_start_dt)  = 'Y';
BEGIN
  p_basic_level := NULL;
  p_calendar_level := NULL;
  -- Select from within course override structure
  OPEN c_scpc;
  FETCH c_scpc INTO v_dummy;
  IF c_scpc%FOUND THEN
    CLOSE c_scpc;
    p_basic_level := cst_course;
    v_dummy := NULL;
    OPEN c_scpca;
    FETCH c_scpca INTO v_dummy;
    IF c_scpca%FOUND THEN
      CLOSE c_scpca;
      p_calendar_level := cst_course;
      RETURN;
    END IF;
    CLOSE c_scpca;
  ELSE
    CLOSE c_scpc;
  END IF;
  -- Select from within organisation unit structure
  OPEN c_sopc;
  FETCH c_sopc INTO
      v_org_unit_cd,
      v_ou_start_dt;
  IF c_sopc%FOUND THEN
    CLOSE c_sopc;
    IF p_basic_level IS NULL THEN
      p_basic_level := cst_ou;
      p_org_unit_cd := v_org_unit_cd;
      p_ou_start_dt := v_ou_start_dt;
    END IF;
    v_org_unit_cd := NULL;
    v_ou_start_dt := NULL;
    OPEN c_sopca;
    FETCH c_sopca INTO
        v_org_unit_cd,
        v_ou_start_dt;
    IF c_sopca%FOUND THEN
      CLOSE c_sopca;
      p_calendar_level := cst_ou;
      p_org_unit_cd := v_org_unit_cd;
      p_ou_start_dt := v_ou_start_dt;
      RETURN;
    END IF;
    CLOSE c_sopca;
  ELSE
    CLOSE c_sopc;
  END IF;
  IF p_basic_level IS NULL THEN
    p_basic_level := cst_system;
  END IF;
  p_calendar_level := cst_system;
EXCEPTION
  WHEN OTHERS THEN
    IF c_scpc%ISOPEN THEN
      CLOSE c_scpc;
    END IF;
    IF c_scpca%ISOPEN THEN
      CLOSE c_scpca;
    END IF;
    IF c_sopc%ISOPEN THEN
      CLOSE c_sopc;
    END IF;
    IF c_sopca%ISOPEN THEN
      CLOSE c_sopca;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_GET_CONFIG_LVL;
PROCEDURE IGS_PR_GET_CONFIG_PARM(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_apply_start_dt_alias OUT NOCOPY VARCHAR2 ,
  p_apply_end_dt_alias OUT NOCOPY VARCHAR2 ,
  p_end_benefit_dt_alias OUT NOCOPY VARCHAR2 ,
  p_end_penalty_dt_alias OUT NOCOPY VARCHAR2 ,
  p_show_cause_cutoff_dt_alias OUT NOCOPY VARCHAR2 ,
  p_appeal_cutoff_dt_alias OUT NOCOPY VARCHAR2 ,
  p_show_cause_ind OUT NOCOPY VARCHAR2 ,
  p_apply_before_show_ind OUT NOCOPY VARCHAR2 ,
  p_appeal_ind OUT NOCOPY VARCHAR2 ,
  p_apply_before_appeal_ind OUT NOCOPY VARCHAR2 ,
  p_count_sus_in_time_ind OUT NOCOPY VARCHAR2 ,
  p_count_exc_in_time_ind OUT NOCOPY VARCHAR2 ,
  p_calculate_wam_ind OUT NOCOPY VARCHAR2 ,
  p_calculate_gpa_ind OUT NOCOPY VARCHAR2 ,
  p_outcome_check_type OUT NOCOPY VARCHAR2 )
IS
  gv_other_detail     VARCHAR2(255);
BEGIN   -- IGS_PR_GET_CONFIG_PARM
  -- Get the configuration parameters applicable to a course version.
DECLARE
  cst_course    CONSTANT  VARCHAR2(10) := 'COURSE';
  cst_system    CONSTANT  VARCHAR2(10) := 'SYSTEM';
  cst_ou      CONSTANT  VARCHAR2(10) := 'OU';
  v_basic_level       VARCHAR2(10);
  v_calendar_level      VARCHAR2(10);
  v_org_unit_cd       IGS_OR_UNIT.org_unit_cd%TYPE;
  v_ou_start_dt       IGS_OR_UNIT.start_dt%TYPE;
  CURSOR c_sprgc IS
    SELECT  sprgc.apply_start_dt_alias,
      sprgc.apply_end_dt_alias,
      sprgc.end_benefit_dt_alias,
      sprgc.end_penalty_dt_alias,
      sprgc.show_cause_cutoff_dt_alias,
      sprgc.appeal_cutoff_dt_alias,
      sprgc.show_cause_ind,
      sprgc.apply_before_show_ind,
      sprgc.appeal_ind,
      sprgc.apply_before_appeal_ind,
      sprgc.count_sus_in_time_ind,
      sprgc.count_exc_in_time_ind,
      sprgc.calculate_wam_ind,
      sprgc.calculate_gpa_ind,
      sprgc.outcome_check_type
    FROM  IGS_PR_S_PRG_CONF     sprgc
    WHERE sprgc.s_control_num     = 1;
  CURSOR c_sopc (
    cp_org_unit_cd        IGS_PR_S_OU_PRG_CONF.org_unit_cd%TYPE,
    cp_ou_start_dt        IGS_PR_S_OU_PRG_CONF.ou_start_dt%TYPE) IS
    SELECT  sopc.apply_start_dt_alias,
      sopc.apply_end_dt_alias,
      sopc.end_benefit_dt_alias,
      sopc.end_penalty_dt_alias,
      sopc.show_cause_cutoff_dt_alias,
      sopc.appeal_cutoff_dt_alias,
      sopc.show_cause_ind,
      sopc.apply_before_show_ind,
      sopc.appeal_ind,
      sopc.apply_before_appeal_ind,
      sopc.count_sus_in_time_ind,
      sopc.count_exc_in_time_ind,
      sopc.calculate_wam_ind,
      sopc.calculate_gpa_ind,
      sopc.outcome_check_type
    FROM  IGS_PR_S_OU_PRG_CONF      sopc
    WHERE sopc.org_unit_cd    = cp_org_unit_cd AND
      sopc.ou_start_dt    = cp_ou_start_dt;
  CURSOR c_scpc IS
    SELECT  scpc.apply_start_dt_alias,
      scpc.apply_end_dt_alias,
      scpc.end_benefit_dt_alias,
      scpc.end_penalty_dt_alias,
      scpc.show_cause_cutoff_dt_alias,
      scpc.appeal_cutoff_dt_alias,
      scpc.show_cause_ind,
      scpc.apply_before_show_ind,
      scpc.appeal_ind,
      scpc.apply_before_appeal_ind,
      scpc.count_sus_in_time_ind,
      scpc.count_exc_in_time_ind,
      scpc.calculate_wam_ind,
      scpc.calculate_gpa_ind,
      scpc.outcome_check_type
    FROM  IGS_PR_S_CRV_PRG_CON      scpc
    WHERE scpc.course_cd      = p_course_cd AND
      scpc.version_number     = p_version_number;
BEGIN
  IGS_PR_GET_CONFIG_LVL (
        p_course_cd,
        p_version_number,
        v_basic_level,
        v_calendar_level,
        v_org_unit_cd,
        v_ou_start_dt);
  IF v_basic_level = cst_system THEN
    OPEN c_sprgc;
    FETCH c_sprgc INTO
        p_apply_start_dt_alias,
        p_apply_end_dt_alias,
        p_end_benefit_dt_alias,
        p_end_penalty_dt_alias,
        p_show_cause_cutoff_dt_alias,
        p_appeal_cutoff_dt_alias,
        p_show_cause_ind,
        p_apply_before_show_ind,
        p_appeal_ind,
        p_apply_before_appeal_ind,
        p_count_sus_in_time_ind,
        p_count_exc_in_time_ind,
        p_calculate_wam_ind,
        p_calculate_gpa_ind,
        p_outcome_check_type;
    CLOSE c_sprgc;
  ELSIF v_basic_level = cst_ou THEN
    OPEN c_sopc (
        v_org_unit_cd,
        v_ou_start_dt);
    FETCH c_sopc INTO
        p_apply_start_dt_alias,
        p_apply_end_dt_alias,
        p_end_benefit_dt_alias,
        p_end_penalty_dt_alias,
        p_show_cause_cutoff_dt_alias,
        p_appeal_cutoff_dt_alias,
        p_show_cause_ind,
        p_apply_before_show_ind,
        p_appeal_ind,
        p_apply_before_appeal_ind,
        p_count_sus_in_time_ind,
        p_count_exc_in_time_ind,
        p_calculate_wam_ind,
        p_calculate_gpa_ind,
        p_outcome_check_type;
    CLOSE c_sopc;
  ELSIF v_basic_level = cst_course THEN
    OPEN c_scpc;
    FETCH c_scpc INTO
        p_apply_start_dt_alias,
        p_apply_end_dt_alias,
        p_end_benefit_dt_alias,
        p_end_penalty_dt_alias,
        p_show_cause_cutoff_dt_alias,
        p_appeal_cutoff_dt_alias,
        p_show_cause_ind,
        p_apply_before_show_ind,
        p_appeal_ind,
        p_apply_before_appeal_ind,
        p_count_sus_in_time_ind,
        p_count_exc_in_time_ind,
        p_calculate_wam_ind,
        p_calculate_gpa_ind,
        p_outcome_check_type;
    CLOSE c_scpc;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_sprgc%ISOPEN THEN
      CLOSE c_sprgc;
    END IF;
    IF c_sopc%ISOPEN THEN
      CLOSE c_sopc;
    END IF;
    IF c_scpc%ISOPEN THEN
      CLOSE c_scpc;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_GET_CONFIG_PARM;
PROCEDURE IGS_PR_INS_ADV_TODO(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_old_adv_stnd_type IN VARCHAR2 ,
  p_new_adv_stnd_type IN VARCHAR2 ,
  p_old_s_adv_stnd_grant_status IN VARCHAR2 ,
  p_new_s_adv_stnd_grant_status IN VARCHAR2 ,
  p_old_credit_points IN NUMBER ,
  p_new_credit_points IN NUMBER ,
  p_old_credit_percentage IN NUMBER ,
  p_new_credit_percentage IN NUMBER )
IS
  gv_other_detail     VARCHAR2(255);
BEGIN   -- IGS_PR_INS_ADV_TODO
  -- Insert todo records for progression checks where advanced standing detail
  -- (either adv_stnd_unit_level or adv_stnd_unithas changed in the following
  -- scenarios:
  -- * s_adv_stnd_type is CREDIT and  s_adv_stnd_granting_status has changed
  --   old or new s_adv_stnd_granting_status is/was GRANTED
  -- * s_adv_stnd_granting_status is GRANTED and s_adv_stnd_type is CREDIT and
  --   credit_points has changed
  -- * s_adv_stnd_granting_status is GRANTED and s_adv_stnd_type is CREDIT and
  --   credit_percentage has changed and either new or old value is/was 100
  -- If any progression periods are open then records are stored for these.
  -- ijeddy, 4 Dec 2003, Bug 3258610. removed ref to Credit_percentage
DECLARE
  cst_credit  CONSTANT  VARCHAR2(10) := 'CREDIT';
  cst_granted CONSTANT  VARCHAR2(10) := 'GRANTED';
  cst_todo    CONSTANT  VARCHAR2(10) := 'TODO';
  cst_prg_check CONSTANT  VARCHAR2(10) := 'PRG_CHECK';
  v_version_number      IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  v_sequence_number   NUMBER;
  v_insert_todo     BOOLEAN DEFAULT FALSE;
  v_start_dt      DATE;
  v_cutoff_dt     DATE;
  CURSOR c_sca IS
    SELECT  sca.version_number
    FROM  IGS_EN_STDNT_PS_ATT     sca
    WHERE sca.person_id     = p_person_id AND
      sca.course_cd       = p_course_cd;
  CURSOR c_spc IS
    SELECT  spc.prg_cal_type,
      spc.prg_ci_sequence_number
    FROM  IGS_PR_STDNT_PR_CK  spc
    WHERE spc.person_id     = p_person_id AND
      spc.course_cd     = p_course_cd;
BEGIN

  IF (NVL(p_old_s_adv_stnd_grant_status,  ' ') <>
      NVL(p_new_s_adv_stnd_grant_status, ' ') AND
      ((NVL(p_old_s_adv_stnd_grant_status, ' ') = cst_granted OR
      NVL(p_new_s_adv_stnd_grant_status, ' ') = cst_granted) AND
      (NVL(p_old_adv_stnd_type,  ' ') = cst_credit OR
      NVL(p_new_adv_stnd_type, ' ') = cst_credit))) OR
      (((NVL(p_old_s_adv_stnd_grant_status, ' ') = cst_granted OR
      NVL(p_new_s_adv_stnd_grant_status, ' ') = cst_granted) AND
      (NVL(p_old_adv_stnd_type,  ' ') = cst_credit OR
      NVL(p_new_adv_stnd_type, ' ') = cst_credit)) OR
      (NVL(p_old_credit_points, 0) <> NVL(p_new_credit_points, 0)
      )) THEN
    -- If version number not passed then load it from IGS_EN_STDNT_PS_ATT
    -- record

    IF p_version_number IS NULL THEN
      OPEN c_sca;
      FETCH c_sca INTO v_version_number;
                        IF c_sca%NOTFOUND THEN

        CLOSE c_sca;
        RETURN;
      END IF;
      CLOSE c_sca;
    ELSE
      v_version_number := p_version_number;
    END IF;
    FOR v_spc_rec IN c_spc LOOP
      IF IGS_PR_GEN_006.IGS_PR_GET_WITHIN_APPL (
          v_spc_rec.prg_cal_type,
          v_spc_rec.prg_ci_sequence_number,
          p_course_cd,
          v_version_number,
          cst_todo,
          v_start_dt,
          v_cutoff_dt) = 'Y' THEN
        v_insert_todo := TRUE;
        EXIT;
      END IF;
    END LOOP;


    IF v_insert_todo THEN
      -- Insert todo entry
      v_sequence_number := IGS_GE_GEN_003.GENP_INS_STDNT_TODO (
                p_person_id,
                cst_prg_check,
                NULL,
                'Y');
    IGS_GE_GEN_003.GENP_INS_TODO_REF (
          p_person_id,
          cst_prg_check,
          v_sequence_number,
          NULL,
          NULL,
          p_course_cd,
          NULL,
          NULL,
  --
  -- kdande; 23-Apr-2003; Bug# 2829262
  -- Passing uoo_id parameter as NULL to igs_ge_gen_003.genp_ins_todo_ref
  --
          NULL);
    END IF;
  END IF;

  RETURN;
EXCEPTION
  WHEN OTHERS THEN
    IF c_sca%ISOPEN THEN
      CLOSE c_sca;
    END IF;
    IF c_spc%ISOPEN THEN
      CLOSE c_spc;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_INS_ADV_TODO;

PROCEDURE IGS_PR_INS_PRG_MSR(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER )
IS
/*------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- Prajeesh    21-apr-2002   When the course_gpa,period_gpa,course_wam,period_wam
  --                         is null then nvl to 0
  --svanukur     30-jul-2003  replaced the call to the fnction IGS_PR_GEN_006.IGS_PR_GET_STD_GPA
  --                          to calcualate period_gpa and course_gpa with igs_pr_cp_gpa.get_all_stats
  --                          as partof bug 3031749
  --svanukur    07-aug-03     undoing the above mentioned changes to revert back to the original file
                              since this file is not being modified as part of the bug#3031749
  -------------------------------------------------------------------*/

 gv_other_detail   VARCHAR2(255);
BEGIN -- IGS_PR_GEN_001.IGS_PR_INS_PRG_MSR
  -- Insert the appropriate progression measures for a nominated
  -- student course attempt within a nominated progression period.
  --
  --The routine checks the system parameters applying to the students
  -- course version and inserts the appropriate GPA/WAM values accordingly.
DECLARE
  v_apply_start_dt_alias    IGS_PR_S_PRG_CONF.apply_start_dt_alias%TYPE;
  v_apply_end_dt_alias    IGS_PR_S_PRG_CONF.apply_end_dt_alias%TYPE;
  v_end_benefit_dt_alias    IGS_PR_S_PRG_CONF.end_benefit_dt_alias%TYPE;
  v_end_penalty_dt_alias    IGS_PR_S_PRG_CONF.end_penalty_dt_alias%TYPE;
  v_show_cause_cutoff_dt    IGS_PR_S_PRG_CONF.show_cause_cutoff_dt_alias%TYPE;
  v_appeal_cutoff_dt      IGS_PR_S_PRG_CONF.appeal_cutoff_dt_alias%TYPE;
  v_show_cause_ind      IGS_PR_S_PRG_CONF.show_cause_ind%TYPE;
  v_apply_before_show_ind   IGS_PR_S_PRG_CONF.apply_before_show_ind%TYPE;
  v_appeal_ind      IGS_PR_S_PRG_CONF.appeal_ind%TYPE;
  v_apply_before_appeal_ind   IGS_PR_S_PRG_CONF.apply_before_appeal_ind%TYPE;
  v_count_sus_in_time_ind   IGS_PR_S_PRG_CONF.count_sus_in_time_ind%TYPE;
  v_count_exc_in_time_ind   IGS_PR_S_PRG_CONF.count_exc_in_time_ind%TYPE;
  v_calculate_wam_ind   IGS_PR_S_PRG_CONF.calculate_wam_ind%TYPE;
  v_calculate_gpa_ind   IGS_PR_S_PRG_CONF.calculate_gpa_ind%TYPE;
  v_outcome_check_type    IGS_PR_S_PRG_CONF.outcome_check_type%TYPE;
  v_course_gpa      NUMBER;
  v_period_gpa      NUMBER;
  v_course_wam      NUMBER;
  v_period_wam      NUMBER;
  v_value           NUMBER;
  CURSOR c_scpm (cp_prg_measure_type
        IGS_PR_SDT_PS_PR_MSR.s_prg_measure_type%TYPE) IS
    SELECT  scpm.value
    FROM  IGS_PR_SDT_PS_PR_MSR    scpm
    WHERE scpm.person_id      = p_person_id AND
      scpm.course_cd      = p_course_cd AND
      scpm.prg_cal_type   = p_prg_cal_type AND
      scpm.prg_ci_sequence_number = p_prg_sequence_number AND
      scpm.s_prg_measure_type   = cp_prg_measure_type
    ORDER BY scpm.calculation_dt DESC;

  --
  -- Start of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
  CURSOR c_cir (cp_prg_cal_type        igs_ca_inst.cal_type%TYPE,
                  cp_prg_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT cir.sub_cal_type cal_type, cir.sub_ci_sequence_number ci_sequence_number
    FROM   IGS_CA_INST     ci ,
           IGS_CA_INST_REL cir,
           IGS_CA_TYPE     cat,
           IGS_CA_STAT     cs
    WHERE  cir.sup_cal_type           = cp_prg_cal_type
    AND    cir.sup_ci_sequence_number = cp_prg_sequence_number
    AND    ci.cal_type                = cir.sub_cal_type
    AND    ci.sequence_number         = cir.sub_ci_sequence_number
    AND    cat.cal_type               = ci.cal_type
    AND    cat.s_cal_cat              = 'LOAD'
    AND    cs.CAL_STATUS              = ci.CAL_STATUS
    AND    cs.s_CAL_STATUS            = 'ACTIVE';
    rec_cir c_cir%ROWTYPE;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    v_gpa_value NUMBER;
    v_gpa_cp NUMBER;
    v_gpa_quality_points NUMBER;
  -- End of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
  --

BEGIN
  -- Call routine to get parameters applicable to course version.
  IGS_PR_GET_CONFIG_PARM(
      p_course_cd,
      p_version_number,
      v_apply_start_dt_alias,
      v_apply_end_dt_alias,
      v_end_benefit_dt_alias,
      v_end_penalty_dt_alias,
      v_show_cause_cutoff_dt,
      v_appeal_cutoff_dt,
      v_show_cause_ind,
      v_apply_before_show_ind,
      v_appeal_ind,
      v_apply_before_appeal_ind,
      v_count_sus_in_time_ind,
      v_count_exc_in_time_ind,
      v_calculate_wam_ind,
      v_calculate_gpa_ind,
      v_outcome_check_type);
  -- Get GPA
  --
  -- Start of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
  OPEN c_cir(p_prg_cal_type, p_prg_sequence_number);
  FETCH c_cir INTO rec_cir;
  CLOSE c_cir;
  -- End of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
  IF v_calculate_gpa_ind = 'Y' THEN
    --
    -- Start of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
    IGS_PR_CP_GPA.get_gpa_stats(
      p_person_id                 =>  p_person_id,
      p_course_cd                 => p_course_cd ,
      p_stat_type                 => NULL,
      p_load_cal_type             => rec_cir.cal_type,
      p_load_ci_sequence_number   => rec_cir.ci_sequence_number,
      p_system_stat               => NULL,
      p_cumulative_ind            => 'Y',
      p_gpa_value                 => v_course_gpa,
      p_gpa_cp                    => v_gpa_cp,
      p_gpa_quality_points        => v_gpa_quality_points,
      p_return_status             => l_return_status,
      p_msg_count                 => l_msg_count,
      p_msg_data                  => l_msg_data);
    -- End of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
    --

/*    v_course_gpa := IGS_PR_GEN_006.IGS_PR_GET_STD_GPA(
          p_person_id,
          p_course_cd,
          NULL,
          NULL);
*/
    v_value := NULL;
    OPEN c_scpm('COURSE-GPA');
    FETCH c_scpm INTO v_value;
    CLOSE c_scpm;
    IF v_course_gpa IS NOT NULL OR v_value IS NOT NULL THEN
      IF NVL(v_course_gpa,-1) <> NVL(v_value,-1) THEN
        v_course_gpa:=nvl(v_course_gpa,0);
        DECLARE
          lv_rowid VARCHAR2(25);
        BEGIN
          IGS_PR_SDT_PS_PR_MSR_PKG .INSERT_ROW (
           X_ROWID => lv_rowid,
            X_PERSON_ID => p_person_id,
            X_COURSE_CD => p_course_cd,
            X_PRG_CAL_TYPE => p_prg_cal_type,
            X_PRG_CI_SEQUENCE_NUMBER => p_prg_sequence_number,
            X_S_PRG_MEASURE_TYPE => 'COURSE-GPA',
            X_CALCULATION_DT => SYSDATE,
            X_VALUE =>v_course_gpa,
            X_MODE => 'R' );
        END;
      END IF;
    END IF;
/*  v_period_gpa := IGS_PR_GEN_006.IGS_PR_GET_STD_GPA(
          p_person_id,
          p_course_cd,
          p_prg_cal_type,
          p_prg_sequence_number);
*/
    --
    -- Start of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
   IGS_PR_CP_GPA.get_gpa_stats(
      p_person_id   =>  p_person_id,
      p_course_cd   => p_course_cd ,
      p_stat_type   => NULL,
      p_load_cal_type  => rec_cir.cal_type,
      p_load_ci_sequence_number   => rec_cir.ci_sequence_number,
      p_system_stat               => NULL,
      p_cumulative_ind            => 'N',
      p_gpa_value                 => v_period_gpa,
      p_gpa_cp                    => v_gpa_cp,
      p_gpa_quality_points        => v_gpa_quality_points,
      p_return_status             => l_return_status,
      p_msg_count                 => l_msg_count,
      p_msg_data                  => l_msg_data);
    -- End of new code added to fix Bug# 3103892; nalkumar; 22-Aug-2003
    --
    -- NULLIFY v_value else there is a problem that PERIOD-GPA will come same as COURSE-GPA
    --
    v_value := NULL;
    OPEN c_scpm('PERIOD-GPA');
    FETCH c_scpm INTO v_value;
    CLOSE c_scpm;
    IF v_period_gpa IS NOT NULL OR v_value IS NOT NULL THEN
      IF NVL(v_period_gpa,-1) <> NVL(v_value,-1) THEN
        v_period_gpa:=nvl(v_period_gpa,0);
        DECLARE
          lv_rowid VARCHAR2(25);
        BEGIN
          IGS_PR_SDT_PS_PR_MSR_PKG.INSERT_ROW (
           X_ROWID => lv_rowid,
            X_PERSON_ID => p_person_id,
            X_COURSE_CD => p_course_cd,
            X_PRG_CAL_TYPE => p_prg_cal_type,
            X_PRG_CI_SEQUENCE_NUMBER => p_prg_sequence_number,
            X_S_PRG_MEASURE_TYPE => 'PERIOD-GPA',
            X_CALCULATION_DT => SYSDATE,
            X_VALUE =>v_period_gpa,
            X_MODE => 'R' );
        END;
      END IF;
    END IF;
  END IF;
  -- Get WAM
  IF v_calculate_wam_ind = 'Y' THEN
        v_course_wam := IGS_PR_GEN_006.IGS_PR_GET_STD_WAM(
        p_person_id ,
      p_course_cd  ,
        p_version_number  ,
      NULL,
      NULL)  ;
    v_value := NULL;
    OPEN c_scpm('COURSE-WAM');
    FETCH c_scpm INTO v_value;
    CLOSE c_scpm;
    IF v_course_wam IS NOT NULL OR v_value IS NOT NULL THEN
      IF NVL(v_course_wam,-1) <> NVL(v_value,-1) THEN
      /*  INSERT INTO IGS_PR_SDT_PS_PR_MSR(
              person_id,
              course_cd,
              prg_cal_type,
              prg_ci_sequence_number,
              s_prg_measure_type,
              calculation_dt,
              value)
        VALUES(
          p_person_id,
          p_course_cd,
          p_prg_cal_type,
          p_prg_sequence_number,
          'COURSE-WAM',
          SYSDATE,
          v_course_wam);    */
                       v_course_wam:=nvl(v_course_wam,0);
           DECLARE
              lv_rowid VARCHAR2(25);
           BEGIN
               IGS_PR_SDT_PS_PR_MSR_PKG .INSERT_ROW (
           X_ROWID => lv_rowid,
            X_PERSON_ID => p_person_id,
            X_COURSE_CD => p_course_cd,
            X_PRG_CAL_TYPE => p_prg_cal_type,
            X_PRG_CI_SEQUENCE_NUMBER => p_prg_sequence_number,
            X_S_PRG_MEASURE_TYPE => 'COURSE-WAM',
            X_CALCULATION_DT => SYSDATE,
            X_VALUE =>v_course_wam,
            X_MODE => 'R' );
                        END;
      END IF;
    END IF;
    v_period_wam := IGS_PR_GEN_006.IGS_PR_GET_STD_WAM(
          p_person_id,
          p_course_cd,
          p_version_number,
          p_prg_cal_type,
          p_prg_sequence_number);
    v_value := NULL;
    OPEN c_scpm('PERIOD-WAM');
    FETCH c_scpm INTO v_value;
    CLOSE c_scpm;
    IF v_period_wam IS NOT NULL OR v_value IS NOT NULL THEN
      IF NVL(v_period_wam,1) <> NVL(v_value,-1) THEN
                            /*
        INSERT INTO IGS_PR_SDT_PS_PR_MSR(
              person_id,
              course_cd,
              prg_cal_type,
              prg_ci_sequence_number,
              s_prg_measure_type,
              calculation_dt,
              value)
        VALUES(
          p_person_id,
          p_course_cd,
          p_prg_cal_type,
          p_prg_sequence_number,
          'PERIOD-WAM',
          SYSDATE,
          v_period_wam);   */
                                v_period_wam:=nvl(v_period_wam,0);
        DECLARE
                lv_rowid VARCHAR2(25);
             BEGIN
        IGS_PR_SDT_PS_PR_MSR_PKG .INSERT_ROW (
           X_ROWID => lv_rowid,
            X_PERSON_ID => p_person_id,
            X_COURSE_CD => p_course_cd,
            X_PRG_CAL_TYPE => p_prg_cal_type,
            X_PRG_CI_SEQUENCE_NUMBER => p_prg_sequence_number,
            X_S_PRG_MEASURE_TYPE => 'PERIOD-WAM',
            X_CALCULATION_DT => SYSDATE,
            X_VALUE =>v_period_wam,
            X_MODE => 'R' );
             END;
      END IF;
    END IF;
  END IF;
END;
EXCEPTION
  WHEN OTHERS THEN

    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_INS_PRG_MSR;

PROCEDURE IGS_PR_INS_SPO_HIST(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_new_prg_cal_type IN VARCHAR2 ,
  p_old_prg_cal_type IN VARCHAR2 ,
  p_new_prg_ci_sequence_number IN NUMBER ,
  p_old_prg_ci_sequence_number IN NUMBER ,
  p_new_rule_check_dt IN DATE ,
  p_old_rule_check_dt IN DATE ,
  p_new_progression_rule_cat IN VARCHAR2 ,
  p_old_progression_rule_cat IN VARCHAR2 ,
  p_new_pra_sequence_number IN NUMBER ,
  p_old_pra_sequence_number IN NUMBER ,
  p_new_pro_pra_sequence_number IN NUMBER ,
  p_old_pro_pra_sequence_number IN NUMBER ,
  p_new_pro_sequence_number IN NUMBER ,
  p_old_pro_sequence_number IN NUMBER ,
  p_new_progression_outcome_type IN VARCHAR2 ,
  p_old_progression_outcome_type IN VARCHAR2 ,
  p_new_duration IN NUMBER ,
  p_old_duration IN NUMBER ,
  p_new_duration_type IN VARCHAR2 ,
  p_old_duration_type IN VARCHAR2 ,
  p_new_decision_status IN VARCHAR2 ,
  p_old_decision_status IN VARCHAR2 ,
  p_new_decision_dt IN DATE ,
  p_old_decision_dt IN DATE ,
  p_new_decision_org_unit_cd IN VARCHAR2 ,
  p_old_decision_org_unit_cd IN VARCHAR2 ,
  p_new_decision_ou_start_dt IN DATE ,
  p_old_decision_ou_start_dt IN DATE ,
  p_new_applied_dt IN DATE ,
  p_old_applied_dt IN DATE ,
  p_new_expiry_dt IN DATE ,
  p_old_expiry_dt IN DATE ,
  p_new_show_cause_expiry_dt IN DATE ,
  p_old_show_cause_expiry_dt IN DATE ,
  p_new_show_cause_dt IN DATE ,
  p_old_show_cause_dt IN DATE ,
  p_new_show_cause_outcome_dt IN DATE ,
  p_old_show_cause_outcome_dt IN DATE ,
  p_new_show_cause_outcome_type IN VARCHAR2 ,
  p_old_show_cause_outcome_type IN VARCHAR2 ,
  p_new_appeal_expiry_dt IN DATE ,
  p_old_appeal_expiry_dt IN DATE ,
  p_new_appeal_dt IN DATE ,
  p_old_appeal_dt IN DATE ,
  p_new_appeal_outcome_dt IN DATE ,
  p_old_appeal_outcome_dt IN DATE ,
  p_new_appeal_outcome_type IN VARCHAR2 ,
  p_old_appeal_outcome_type IN VARCHAR2 ,
  p_new_encmb_course_group_cd IN VARCHAR2 ,
  p_old_encmb_course_group_cd IN VARCHAR2 ,
  p_new_restricted_enrolment_cp IN NUMBER ,
  p_old_restricted_enrolment_cp IN NUMBER ,
  p_new_restricted_att_type IN VARCHAR2 ,
  p_old_restricted_att_type IN VARCHAR2 ,
  p_new_LAST_UPDATED_BY IN VARCHAR2 ,
  p_old_LAST_UPDATED_BY IN VARCHAR2 ,
  p_new_LAST_UPDATE_DATE IN DATE ,
  p_old_LAST_UPDATE_DATE IN DATE ,
  p_new_comments IN VARCHAR2 ,
  p_old_comments IN VARCHAR2 ,
  p_new_show_cause_comments IN VARCHAR2 ,
  p_old_show_cause_comments IN VARCHAR2 ,
  p_new_appeal_comments IN VARCHAR2 ,
  p_old_appeal_comments IN VARCHAR2 )
IS
  gv_other_detail     VARCHAR2(255);
BEGIN   -- IGS_PR_INS_SPO_HIST
DECLARE
  r_spoh        IGS_PR_STU_OU_HIST%ROWTYPE;
  v_create_history    BOOLEAN DEFAULT FALSE;
BEGIN
  -- check if a history record is required
  IF NVL(p_new_prg_cal_type, 'NULL') <> NVL(p_old_prg_cal_type, 'NULL') THEN
    r_spoh.prg_cal_type := p_old_prg_cal_type;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_prg_ci_sequence_number, 0) <>
      NVL(p_old_prg_ci_sequence_number, 0) THEN
    r_spoh.prg_ci_sequence_number := p_old_prg_ci_sequence_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_rule_check_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_rule_check_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.rule_check_dt := p_old_rule_check_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_progression_rule_cat, 'NULL') <>
      NVL(p_old_progression_rule_cat, 'NULL') THEN
    r_spoh.progression_rule_cat := p_old_progression_rule_cat;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_pra_sequence_number, 0) <> NVL(p_old_pra_sequence_number, 0) THEN
    r_spoh.pra_sequence_number := p_old_pra_sequence_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_pro_pra_sequence_number, 0) <>
      NVL(p_old_pro_pra_sequence_number, 0) THEN
    r_spoh.pro_pra_sequence_number := p_old_pro_pra_sequence_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_pro_sequence_number, 0) <> NVL(p_old_pro_sequence_number, 0) THEN
    r_spoh.pro_sequence_number := p_old_pro_sequence_number;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_progression_outcome_type, 'NULL') <>
      NVL(p_old_progression_outcome_type, 'NULL') THEN
    r_spoh.progression_outcome_type := p_old_progression_outcome_type;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_duration, 0) <> NVL(p_old_duration, 0) THEN
    r_spoh.duration := p_old_duration;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_duration_type, 'NULL') <> NVL(p_old_duration_type, 'NULL') THEN
    r_spoh.duration_type := p_old_duration_type;
    v_create_history := TRUE;
  END IF;
  IF p_new_decision_status <> p_old_decision_status THEN
    r_spoh.decision_status := p_old_decision_status;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_decision_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_decision_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.decision_dt := p_old_decision_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_decision_org_unit_cd, 'NULL') <>
      NVL(p_old_decision_org_unit_cd, 'NULL') THEN
    r_spoh.decision_org_unit_cd := p_old_decision_org_unit_cd;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_decision_ou_start_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_decision_ou_start_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.decision_ou_start_dt := p_old_decision_ou_start_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_applied_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_applied_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.applied_dt := p_old_applied_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.expiry_dt := p_old_expiry_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_show_cause_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_show_cause_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.show_cause_expiry_dt := p_old_show_cause_expiry_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_show_cause_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_show_cause_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.show_cause_dt := p_old_show_cause_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_show_cause_outcome_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_show_cause_outcome_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.show_cause_outcome_dt := p_old_show_cause_outcome_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_show_cause_outcome_type, 'NULL') <>
      NVL(p_old_show_cause_outcome_type, 'NULL') THEN
    r_spoh.show_cause_outcome_type := p_old_show_cause_outcome_type;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_appeal_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_appeal_expiry_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.appeal_expiry_dt := p_old_appeal_expiry_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_appeal_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_appeal_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.appeal_dt := p_old_appeal_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_appeal_outcome_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) <>
      NVL(p_old_appeal_outcome_dt, TO_DATE('01/01/0001', 'DD/MM/YYYY')) THEN
    r_spoh.appeal_outcome_dt := p_old_appeal_outcome_dt;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_appeal_outcome_type, 'NULL') <>
      NVL(p_old_appeal_outcome_type, 'NULL') THEN
    r_spoh.appeal_outcome_type := p_old_appeal_outcome_type;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_encmb_course_group_cd, 'NULL') <>
      NVL(p_old_encmb_course_group_cd, 'NULL') THEN
    r_spoh.encmb_course_group_cd := p_old_encmb_course_group_cd;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_restricted_enrolment_cp, 0) <>
      NVL(p_old_restricted_enrolment_cp, 0) THEN
    r_spoh.restricted_enrolment_cp := p_old_restricted_enrolment_cp;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_restricted_att_type, 'NULL') <>
      NVL(p_old_restricted_att_type, 'NULL') THEN
    r_spoh.restricted_attendance_type := p_old_restricted_att_type;
    v_create_history := TRUE;
  END IF;
  IF p_new_LAST_UPDATED_BY <> p_old_LAST_UPDATED_BY THEN
    r_spoh.LAST_UPDATED_BY := p_old_LAST_UPDATED_BY;
    v_create_history := TRUE;
  END IF;
  IF p_new_LAST_UPDATE_DATE <> p_old_LAST_UPDATE_DATE THEN
    r_spoh.LAST_UPDATE_DATE := p_old_LAST_UPDATE_DATE;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_comments, 'NULL') <> NVL(p_old_comments, 'NULL') THEN
    r_spoh.comments := p_old_comments;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_show_cause_comments, 'NULL') <>
      NVL(p_old_show_cause_comments, 'NULL') THEN
    r_spoh.show_cause_comments := p_old_show_cause_comments;
    v_create_history := TRUE;
  END IF;
  IF NVL(p_new_appeal_comments, 'NULL') <>
      NVL(p_old_appeal_comments, 'NULL') THEN
    r_spoh.appeal_comments := p_old_appeal_comments;
    v_create_history := TRUE;
  END IF;
  -- create a history record if a column has changed value
  IF v_create_history = TRUE THEN
    r_spoh.person_id := p_person_id;
    r_spoh.course_cd := p_course_cd;
    r_spoh.sequence_number := p_sequence_number;
    r_spoh.hist_start_dt := p_old_LAST_UPDATE_DATE;
    r_spoh.hist_end_dt := p_new_LAST_UPDATE_DATE;
    r_spoh.hist_who := p_old_LAST_UPDATED_BY;
    -- remove one second from the hist_start_dt value when the hist_start_dt
    -- and hist_end_dt are the same to avoid a primary key constraint from
    -- occurring when saving the record
    IF r_spoh.hist_start_dt = r_spoh.hist_end_dt THEN
      r_spoh.hist_start_dt := r_spoh.hist_start_dt - 1 / (60*24*60);
    END IF;
 /*
    INSERT INTO IGS_PR_STU_OU_HIST (
      person_id,
      course_cd,
      sequence_number,
      hist_start_dt,
      hist_end_dt,
      hist_who,
      prg_cal_type,
      prg_ci_sequence_number,
      rule_check_dt,
      progression_rule_cat,
      pra_sequence_number,
      pro_pra_sequence_number,
      pro_sequence_number,
      progression_outcome_type,
      duration,
      duration_type,
      decision_status,
      decision_dt,
      decision_org_unit_cd,
      decision_ou_start_dt,
      applied_dt,
      expiry_dt,
      show_cause_expiry_dt,
      show_cause_dt,
      show_cause_outcome_dt,
      show_cause_outcome_type,
      appeal_expiry_dt,
      appeal_dt,
      appeal_outcome_dt,
      appeal_outcome_type,
      encmb_course_group_cd,
      restricted_enrolment_cp,
      restricted_attendance_type,
      comments,
      show_cause_comments,
      appeal_comments)
    VALUES (
      r_spoh.person_id,
      r_spoh.course_cd,
      r_spoh.sequence_number,
      r_spoh.hist_start_dt,
      r_spoh.hist_end_dt,
      r_spoh.hist_who,
      r_spoh.prg_cal_type,
      r_spoh.prg_ci_sequence_number,
      r_spoh.rule_check_dt,
      r_spoh.progression_rule_cat,
      r_spoh.pra_sequence_number,
      r_spoh.pro_pra_sequence_number,
      r_spoh.pro_sequence_number,
      r_spoh.progression_outcome_type,
      r_spoh.duration,
      r_spoh.duration_type,
      r_spoh.decision_status,
      r_spoh.decision_dt,
      r_spoh.decision_org_unit_cd,
      r_spoh.decision_ou_start_dt,
      r_spoh.applied_dt,
      r_spoh.expiry_dt,
      r_spoh.show_cause_expiry_dt,
      r_spoh.show_cause_dt,
      r_spoh.show_cause_outcome_dt,
      r_spoh.show_cause_outcome_type,
      r_spoh.appeal_expiry_dt,
      r_spoh.appeal_dt,
      r_spoh.appeal_outcome_dt,
      r_spoh.appeal_outcome_type,
      r_spoh.encmb_course_group_cd,
      r_spoh.restricted_enrolment_cp,
      r_spoh.restricted_attendance_type,
      r_spoh.comments,
      r_spoh.show_cause_comments,
      r_spoh.appeal_comments);
      */
  DECLARE
  lv_rowid VARCHAR2(25);
        l_org_id NUMBER(15);
  BEGIN
        l_org_id := igs_ge_gen_003.get_org_id;
  IGS_PR_STU_OU_HIST_PKG.INSERT_ROW (
      X_ROWID => lv_rowid,
       x_PERSON_ID => r_spoh.person_id,
       x_COURSE_CD => r_spoh.course_cd,
       x_SEQUENCE_NUMBER => r_spoh.sequence_number,
       x_HIST_START_DT => r_spoh.hist_start_dt,
       x_APPEAL_COMMENTS => r_spoh.appeal_comments,
       x_APPEAL_DT  => r_spoh.appeal_dt,
       x_APPEAL_EXPIRY_DT => r_spoh.appeal_expiry_dt,
       x_APPEAL_OUTCOME_DT => r_spoh.appeal_outcome_dt,
       x_APPEAL_OUTCOME_TYPE => r_spoh.appeal_outcome_type,
       x_APPLIED_DT  => r_spoh.applied_dt,
       x_COMMENTS  => r_spoh.comments,
       x_DECISION_DT => r_spoh.decision_dt,
       x_DECISION_ORG_UNIT_CD => r_spoh.decision_org_unit_cd,
       x_DECISION_OU_START_DT =>r_spoh.decision_ou_start_dt,
       x_DECISION_STATUS => r_spoh.decision_status,
       x_DURATION => r_spoh.duration,
       x_DURATION_TYPE => r_spoh.duration_type,
       x_ENCMB_COURSE_GROUP_CD => r_spoh.encmb_course_group_cd,
       x_EXPIRY_DT => r_spoh.expiry_dt,
       x_HIST_END_DT => r_spoh.hist_end_dt,
       x_HIST_WHO => r_spoh.hist_who,
       x_PRA_SEQUENCE_NUMBER => r_spoh.pra_sequence_number,
       x_PRG_CAL_TYPE => r_spoh.prg_cal_type,
       x_PRG_CI_SEQUENCE_NUMBER => r_spoh.prg_ci_sequence_number,
       x_PROGRESSION_OUTCOME_TYPE => r_spoh.progression_outcome_type,
       x_PROGRESSION_RULE_CAT => r_spoh.progression_rule_cat,
       x_PRO_PRA_SEQUENCE_NUMBER => r_spoh.pro_pra_sequence_number,
       x_PRO_SEQUENCE_NUMBER => r_spoh.pro_sequence_number,
       x_RESTRICTED_ATTENDANCE_TYPE => r_spoh.restricted_attendance_type,
       x_RESTRICTED_ENROLMENT_CP => r_spoh.restricted_enrolment_cp,
       x_RULE_CHECK_DT => r_spoh.rule_check_dt,
       x_SHOW_CAUSE_COMMENTS => r_spoh.show_cause_comments,
       x_SHOW_CAUSE_DT => r_spoh.show_cause_dt,
       x_SHOW_CAUSE_EXPIRY_DT => r_spoh.show_cause_expiry_dt,
       x_SHOW_CAUSE_OUTCOME_DT => r_spoh.show_cause_outcome_dt,
       x_SHOW_CAUSE_OUTCOME_TYPE =>r_spoh.show_cause_outcome_type,
       X_MODE => 'R',
       X_ORG_ID => l_org_id  );
       END;
  END IF;
  RETURN;
END;
EXCEPTION
  WHEN OTHERS THEN

  Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
  IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END IGS_PR_INS_SPO_HIST;
PROCEDURE IGS_PR_INS_SSP(
  p_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_s_message_name IN VARCHAR2 ,
  p_text IN VARCHAR2 ,
  p_ssp_sequence_number OUT NOCOPY NUMBER )
IS
BEGIN
DECLARE
  v_other_detail  VARCHAR2(350);
  CURSOR c_get_nxt_seq IS
      --SELECT IGS_PR_S_SCRATCH_PAD_S.nextval
SELECT IGS_PR_RU_APPL_SEQ_NUM_S.nextval
      FROM DUAL;
  v_ssp_sequence_number IGS_PR_S_SCRATCH_PAD.sequence_number%TYPE;
BEGIN
  -- this module inserts and entry into the
  -- system scratch pad table
  -- Get the next sequence number;
  OPEN c_get_nxt_seq;
  FETCH c_get_nxt_seq INTO v_ssp_sequence_number;
  CLOSE c_get_nxt_seq;
/*  INSERT INTO s_scratch_pad (
      sequence_number,
      creation_dt,
      key,
      message_number,
      text)
  VALUES  (
      v_ssp_sequence_number,
      p_creation_dt,
      p_key,
      p_s_message_num,
      p_text);                       */
                  DECLARE
                  lv_rowid VARCHAR2(25);
                        l_org_id NUMBER(15);
                  BEGIN
                        l_org_id := igs_ge_gen_003.get_org_id;
      IGS_PR_S_SCRATCH_PAD_PKG.INSERT_ROW (
      X_ROWID =>lv_rowid,
       x_SEQUENCE_NUMBER =>v_ssp_sequence_number,
       x_CREATION_DT =>p_creation_dt,
       x_KEY =>p_key,
       x_MESSAGE_NAME =>p_s_message_name,
       x_TEXT =>p_text,
      X_MODE  =>'R',
      X_ORG_ID => l_org_id );
      END;
  p_ssp_sequence_number := v_ssp_sequence_number;
EXCEPTION
  WHEN OTHERS THEN

                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
   App_Exception.Raise_Exception;
END ;
END IGS_PR_INS_SSP;
END IGS_PR_GEN_003;

/
