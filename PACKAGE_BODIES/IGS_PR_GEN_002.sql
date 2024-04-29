--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_002" AS
/* $Header: IGSPR02B.pls 120.2 2006/04/28 01:54:11 sepalani ship $ */

/************************************************************************
  Know limitations, enhancements or remarks
  Change History
  Who            When            What
  sepalani     28-Apr-2006     Bug # 5076203
***************************************************************/

FUNCTION PRGP_GET_SCA_WAM(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_course_stage_type IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_abort_when_missing_ind IN VARCHAR2 )
RETURN NUMBER AS
BEGIN
DECLARE
  v_wam_value NUMBER;
BEGIN
  v_wam_value := TO_NUMBER( IGS_RU_GEN_004.rulp_val_wam (
      p_person_id,
      p_course_cd,
      p_course_version,
      p_prg_cal_type,
      p_prg_sequence_number,
      p_use_recommended_ind,
      p_abort_when_missing_ind) );
  RETURN v_wam_value;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN 0;
END;
END prgp_get_sca_wam;

FUNCTION PRGP_GET_STG_COMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_course_stage_type IN VARCHAR2 )
RETURN VARCHAR2 AS
 v_message_text VARCHAR2(2000);

BEGIN
        IF igs_ru_gen_005.rulp_val_stg_comp (
                 p_person_id               => p_person_id,
                 p_sca_course_cd           => p_course_cd,
                 p_sca_course_version      => p_crv_version_number,
                 p_course_cd               => p_course_cd,
                 p_course_version          => p_crv_version_number,
                 p_cst_sequence_number     => p_course_stage_type,
                 p_predicted_ind           => 'N',
                 p_message_text            => v_message_text
             ) THEN
		RETURN 'Y';
        ELSE
                RETURN 'N';
        END IF;
  RETURN 'N';
END;

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_gpa_val
--
FUNCTION prgp_get_sua_gpa_val(
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_best_worst IN VARCHAR2 ,
  p_recommended_ind IN VARCHAR2,
  p_uoo_id IN NUMBER)
RETURN IGS_AS_GRD_SCH_GRADE.gpa_val%TYPE AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_sua_gpa_val
  -- Get the GPA value for a nominated IGS_PS_UNIT attempt
  -- Contains the options to search for:
  --  Best/Worst possible grade - given the grading schema of the IGS_PS_UNIT attempt
  --  Allow recommended - whether to consider recommended grades.
DECLARE
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  v_result_type     IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_finalised_ind     VARCHAR2(1);
  v_outcome_dt      IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  v_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gs_version_number   IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_grade       IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_mark        IGS_AS_SU_STMPTOUT.mark%TYPE;
  v_origin_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_gpa_val     IGS_AS_GRD_SCH_GRADE.gpa_val%TYPE DEFAULT NULL;
  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the WHERE clause of cursor c_sua.
  --
  CURSOR c_sua IS
    SELECT  version_number,
      location_cd,
      unit_class,
      unit_attempt_status
    FROM  IGS_EN_SU_ATTEMPT   sua
    WHERE sua.person_id     = p_person_id AND
      sua.course_cd     = p_course_cd AND
      sua.uoo_id = p_uoo_id;
  v_sua_rec     c_sua%ROWTYPE;
  CURSOR c_gsg (
      cp_grading_schema_cd    IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE,
      cp_version_number   IGS_AS_GRD_SCH_GRADE.version_number%TYPE,
      cp_grade      IGS_AS_GRD_SCH_GRADE.grade%TYPE) IS
    SELECT  gsg.gpa_val
    FROM  IGS_AS_GRD_SCH_GRADE    gsg
    WHERE gsg.grading_schema_cd   = cp_grading_schema_cd AND
      gsg.version_number    = cp_version_number AND
      gsg.grade     = cp_grade;
  FUNCTION prgp_get_best_worst (
    p_person_id   IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE,
    p_course_cd   IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE,
    p_unit_cd   IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE,
    p_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE,
    p_cal_type    IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE,
    p_ci_sequence_number  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE,
    p_location_cd   IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE,
    p_unit_class    IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE,
    p_best_worst    VARCHAR2)
  RETURN NUMBER
  AS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- prgp_get_best_worst
  DECLARE
    v_returned      BOOLEAN;
    v_grading_schema    IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
    v_gs_version_number   IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
    v_max_gpa_val     IGS_AS_GRD_SCH_GRADE.gpa_val%TYPE DEFAULT NULL;
    v_min_gpa_val     IGS_AS_GRD_SCH_GRADE.gpa_val%TYPE DEFAULT NULL;
    CURSOR c_gsg (
        cp_grading_schema_cd  IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE,
        cp_version_number IGS_AS_GRD_SCH_GRADE.version_number%TYPE) IS
      SELECT  MAX(gsg.gpa_val),
        MIN(gsg.gpa_val)
      FROM  IGS_AS_GRD_SCH_GRADE  gsg
      WHERE gsg.grading_schema_cd = cp_grading_schema_cd AND
        gsg.version_number  = cp_version_number AND
        gsg.gpa_val   IS NOT NULL;
  BEGIN
    v_returned := IGS_AS_GEN_003.assp_get_sua_gs (
            p_person_id,
            p_course_cd,
            p_unit_cd,
            p_version_number,
            p_cal_type,
            p_ci_sequence_number,
            p_location_cd,
            p_unit_class,
            v_grading_schema,
            v_gs_version_number);
    OPEN c_gsg (
        v_grading_schema,
        v_gs_version_number);
    FETCH c_gsg INTO
        v_max_gpa_val,
        v_min_gpa_val;
    CLOSE c_gsg;
    IF NVL(p_best_worst,'X') = 'B' THEN
      RETURN v_max_gpa_val;
    ELSE
      RETURN v_min_gpa_val;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_gsg%ISOPEN THEN
        CLOSE c_gsg;
      END IF;
      RAISE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                        FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_002.PRGP_GET_BEST_WORST');
                  --IGS_GE_MSG_STACK.ADD;

  END prgp_get_best_worst;
BEGIN
  OPEN c_sua;
  FETCH c_sua INTO v_sua_rec;
  IF c_sua%NOTFOUND THEN
    CLOSE c_sua;
    RETURN NULL;
  END IF;
  CLOSE c_sua;
  IF v_sua_rec.unit_attempt_status NOT IN (
          cst_completed,
          cst_duplicate,
          cst_discontin,
          cst_enrolled) THEN
    RETURN NULL;
  ELSE
    IF p_recommended_ind = 'N' THEN
      v_finalised_ind := 'Y';
    ELSE
      v_finalised_ind := 'N';
    END IF;
    --
    -- kdande; 22-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the IGS_AS_GEN_003.assp_get_sua_outcome
    -- FUNCTION call.
    --
    IF IGS_AS_GEN_003.assp_get_sua_outcome (
          p_person_id,
          p_course_cd,
          p_unit_cd,
          p_cal_type,
          p_ci_sequence_number,
          v_sua_rec.unit_attempt_status,
          v_finalised_ind,
          v_outcome_dt,
          v_grading_schema_cd,
          v_gs_version_number,
          v_grade,
          v_mark,
          v_origin_course_cd,
          p_uoo_id,
--added by LKAKI----
	  'N') IS NULL THEN
      IF NVL(p_best_worst,'X') NOT IN (
            'B',
            'W') THEN
        RETURN NULL;
      ELSE
        v_gpa_val := prgp_get_best_worst(
              p_person_id,
              p_course_cd,
              p_unit_cd,
              v_sua_rec.version_number,
              p_cal_type,
              p_ci_sequence_number,
              v_sua_rec.location_cd,
              v_sua_rec.unit_class,
              p_best_worst);
        RETURN v_gpa_val;
      END IF;
    ELSE
      OPEN c_gsg (
        v_grading_schema_cd,
        v_gs_version_number,
        v_grade);
      FETCH c_gsg INTO v_gpa_val;
      IF c_gsg%NOTFOUND THEN
        CLOSE c_gsg;
        RETURN NULL;
      END IF;
      CLOSE c_gsg;
      RETURN v_gpa_val;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_gsg%ISOPEN THEN
      CLOSE c_gsg;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_002.PRGP_GET_SUA_GPA_VAL');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_sua_gpa_val;
--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_num.
--
FUNCTION prgp_get_sua_prg_num(
  p_prg_cal_type IN VARCHAR ,
  p_prg_sequence_number IN NUMBER ,
  p_number_of_periods IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER,
  p_uoo_id IN NUMBER)
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_sua_prg_num
  -- Determine whether student IGS_PS_UNIT attempt is effective in the progression
  -- period and a previous number of periods. This routine calls the
  -- prgp_get_sua_prg_prd routine where appropriate.
DECLARE
  cst_progress    CONSTANT  VARCHAR2(10) := 'PROGRESS';
  cst_active    CONSTANT  VARCHAR2(10) := 'ACTIVE';
  v_version_number      IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  v_number_processed      NUMBER DEFAULT 0;
  v_enrolled_in_prg_period    BOOLEAN DEFAULT FALSE;
  v_contributes_to_period     BOOLEAN DEFAULT FALSE;
  CURSOR c_sca IS
    SELECT  sca.version_number
    FROM  IGS_EN_STDNT_PS_ATT sca
    WHERE sca.person_id   = p_person_id AND
      sca.course_cd   = p_course_cd;
  CURSOR c_cat_ci (
    cp_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
    SELECT  ci1.cal_type,
      ci1.sequence_number
    FROM  IGS_CA_TYPE     cat,
      IGS_CA_STAT   cs,
      IGS_CA_INST     ci1
    WHERE cat.cal_type    = ci1.cal_type AND
      cat.s_cal_cat   = cst_progress AND
      cs.cal_status   = ci1.cal_status AND
      cs.s_cal_status   = cst_active AND
      IGS_PR_GEN_001.prgp_get_cal_stream (
            p_course_cd,
            cp_version_number,
            p_prg_cal_type,
            ci1.cal_type)
            = 'Y' AND
      ci1.start_dt    <
      (SELECT ci2.start_dt
      FROM  IGS_CA_INST   ci2
      WHERE ci2.cal_type    = p_prg_cal_type AND
        ci2.sequence_number = p_prg_sequence_number)
    ORDER BY ci1.start_dt DESC;
BEGIN
  -- If effective in parameter period then no further processing required
  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_prd.
  --
  IF prgp_get_sua_prg_prd (
        p_prg_cal_type,
        p_prg_sequence_number,
        p_person_id,
        p_course_cd,
        p_unit_cd,
        p_cal_type,
        p_ci_sequence_number,
        'N',
        NULL,
        NULL,
        p_uoo_id) = 'Y' THEN
    RETURN 'Y';
  END IF;
  -- If only 1 period then don't go back into past periods
  IF p_number_of_periods = 1 THEN
    RETURN 'N';
  END IF;
  v_number_processed := 1;
  -- Get the version number for student IGS_PS_COURSE attempt
  OPEN c_sca;
  FETCH c_sca INTO v_version_number;
  CLOSE c_sca;
  -- Loop through the specified number of past periods
  FOR v_cat_ci_rec IN c_cat_ci (
          v_version_number) LOOP
    v_enrolled_in_prg_period := TRUE;
    -- Determine if the student is effectively enrolled in the progression period
    IF IGS_PR_GEN_001.prgp_get_msr_efctv (
          v_cat_ci_rec.cal_type,
          v_cat_ci_rec.sequence_number,
          p_person_id,
          p_course_cd) = 'N' THEN
      -- The period is not counted as effective
      v_enrolled_in_prg_period := FALSE;
    END IF;
    IF v_enrolled_in_prg_period THEN
      -- Determine if the IGS_PS_UNIT attempt contributes to the period
      --
      -- kdande; 22-Apr-2003; Bug# 2829262
      -- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_prd.
      --
      IF prgp_get_sua_prg_prd (
            v_cat_ci_rec.cal_type,
            v_cat_ci_rec.sequence_number,
            p_person_id,
            p_course_cd,
            p_unit_cd,
            p_cal_type,
            p_ci_sequence_number,
            'N',
            NULL,
            NULL,
            p_uoo_id) = 'Y' THEN
        v_contributes_to_period := TRUE;
        EXIT;
      END IF;
      v_number_processed := v_number_processed + 1;
      IF v_number_processed = p_number_of_periods THEN
        EXIT;
      END IF;
    END IF;
  END LOOP;
  IF v_contributes_to_period THEN
    RETURN 'Y';
  END IF;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    IF c_sca%ISOPEN THEN
      CLOSE c_sca;
    END IF;
    IF c_cat_ci%ISOPEN THEN
      CLOSE c_cat_ci;
    END IF;
  RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_002.PRGP_GET_SUA_PRG_NUM');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_sua_prg_num;

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_prd
--
FUNCTION prgp_get_sua_prg_prd(
  p_prg_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_prg_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_details_ind IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE,
  p_uoo_id IN NUMBER)
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_sua_prg_prd
  -- Return whether student IGS_PS_UNIT attempt contributes to a nominated progression
  -- period. Will take into consideration early exit from units due to
  -- discontinuation of early results in self-paced units.
  -- IGS_GE_NOTE: Discontinuation date is optional and if not passed will be loaded
  -- from the student IGS_PS_UNIT attempt. This has been included as the rules engine
  -- often
DECLARE
  cst_progress  CONSTANT  VARCHAR2(10) := 'PROGRESS';
  cst_active  CONSTANT  VARCHAR2(10) := 'ACTIVE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  v_discontinued_dt   IGS_EN_SU_ATTEMPT.discontinued_dt%TYPE;
  v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  v_result_type     IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_outcome_dt      IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  v_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gs_version_number   IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_grade       IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_mark        IGS_AS_SU_STMPTOUT.mark%TYPE;
  v_origin_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_prev_prg_cal_type   IGS_CA_INST.cal_type%TYPE;
  v_prev_prg_ci_sequence_number IGS_CA_INST.sequence_number%TYPE;
  v_previous_cutoff_dt    IGS_CA_DA_INST.absolute_val%TYPE;
  v_cutoff_dt     IGS_CA_DA_INST.absolute_val%TYPE;
  v_sca_version_number    IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  v_dummy       VARCHAR2(1);
  CURSOR c_cir IS
    SELECT  'X'
    FROM  IGS_CA_INST_REL cir
    WHERE cir.sub_cal_type    = p_cal_type AND
      cir.sub_ci_sequence_number  = p_ci_sequence_number AND
      cir.sup_cal_type    = p_prg_cal_type AND
      cir.sup_ci_sequence_number  = p_prg_ci_sequence_number;
  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the SELECT clause of cursor c_sua.
  --
  CURSOR c_sua IS
    SELECT  sua.discontinued_dt,
      sua.unit_attempt_status
    FROM  IGS_EN_SU_ATTEMPT   sua
    WHERE sua.person_id     = p_person_id AND
      sua.course_cd     = p_course_cd AND
      sua.uoo_id = p_uoo_id;
  CURSOR c_sca IS
    SELECT  sca.version_number
    FROM  IGS_EN_STDNT_PS_ATT     sca
    WHERE sca.person_id     = p_person_id AND
      sca.course_cd     = p_course_cd;
  CURSOR c_ci_cir_ct_cs1 (
    cp_sca_version_number     IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
    SELECT  cir.sup_cal_type,
      cir.sup_ci_sequence_number
    FROM  IGS_CA_INST     ci1,
      IGS_CA_INST_REL   cir,
      IGS_CA_TYPE       ct,
      IGS_CA_STAT     cs
    WHERE cir.sub_cal_type      = p_cal_type AND
      cir.sub_ci_sequence_number  = p_ci_sequence_number AND
      ct.cal_type     = cir.sup_cal_type AND
      ct.s_cal_cat      = cst_progress AND
      ci1.cal_type      = cir.sup_cal_type AND
      ci1.sequence_number   = cir.sup_ci_sequence_number AND
      cs.cal_status     = ci1.cal_status AND
      cs.s_cal_status     = cst_active AND
      IGS_PR_GEN_001.prgp_get_cal_stream (
        p_course_cd,
        cp_sca_version_number,
        p_prg_cal_type,
        cir.sup_cal_type)   = 'Y' AND
      ci1.start_dt      <
      (SELECT ci2.start_dt
      FROM  IGS_CA_INST     ci2
      WHERE ci2.cal_type      = p_prg_cal_type AND
        ci2.sequence_number   = p_prg_ci_sequence_number)
    ORDER BY ci1.start_dt DESC;
  CURSOR c_ci_cir_ct_cs2 (
    cp_sca_version_number     IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
    SELECT  'X'
    FROM  IGS_CA_INST     ci1,
      IGS_CA_INST_REL   cir,
      IGS_CA_TYPE       ct,
      IGS_CA_STAT     cs
    WHERE cir.sub_cal_type      = p_cal_type AND
      cir.sub_ci_sequence_number  = p_ci_sequence_number AND
      ct.cal_type     = cir.sup_cal_type AND
      ct.s_cal_cat      = cst_progress AND
      ci1.cal_type      = cir.sup_cal_type AND
      ci1.sequence_number   = cir.sup_ci_sequence_number AND
      cs.cal_status     = ci1.cal_status AND
      cs.s_cal_status     = cst_active AND
      IGS_PR_GEN_001.prgp_get_cal_stream (
        p_course_cd,
        cp_sca_version_number,
        p_prg_cal_type,
        cir.sup_cal_type)   = 'Y' AND
      ci1.start_dt      >
      (SELECT ci2.start_dt
      FROM  IGS_CA_INST     ci2
      WHERE ci2.cal_type      = p_prg_cal_type AND
        ci2.sequence_number   = p_prg_ci_sequence_number);
BEGIN
  -- Check calendar relationship between progression and teaching calendar
  OPEN c_cir;
  FETCH c_cir INTO v_dummy;
  IF c_cir%NOTFOUND THEN
    CLOSE c_cir;
    RETURN 'N';
  ELSE
    CLOSE c_cir;
  END IF;
  -- Check whether details have been passed
  IF p_details_ind = 'N' THEN
    OPEN c_sua;
    FETCH c_sua INTO
        v_discontinued_dt,
        v_unit_attempt_status;
    IF c_sua%NOTFOUND THEN
      CLOSE c_sua;
      RETURN 'N';
    END IF;
    CLOSE c_sua;
  ELSE
    v_discontinued_dt := p_discontinued_dt;
    v_unit_attempt_status := p_unit_attempt_status;
  END IF;
  -- Get the IGS_EN_STDNT_PS_ATT version_number from student IGS_PS_COURSE attempt
  OPEN c_sca;
  FETCH c_sca INTO v_sca_version_number;
  CLOSE c_sca;
  -- Eliminate status which don't apply
  IF v_unit_attempt_status NOT IN (
          cst_enrolled,
          cst_discontin,
          cst_completed,
          cst_duplicate) THEN
    RETURN 'N';
  END IF;
  -- Get the outcome if applicable
  IF v_unit_attempt_status IN (
          cst_completed,
          cst_duplicate,
          cst_enrolled) THEN
    --
    -- kdande; 22-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the IGS_AS_GEN_003.assp_get_sua_outcome
    -- FUNCTION call.
    --
    v_result_type := IGS_AS_GEN_003.assp_get_sua_outcome(
              p_person_id,
              p_course_cd,
              p_unit_cd,
              p_cal_type,
              p_ci_sequence_number,
              v_unit_attempt_status,
              'N',
              v_outcome_dt,
              v_grading_schema_cd,
              v_gs_version_number,
              v_grade,
              v_mark,
              v_origin_course_cd,
              p_uoo_id,
--added by LKAKI----
	      'N');
    IF v_result_type IS NULL THEN
      v_outcome_dt := NULL;
    END IF;
  ELSE
    v_outcome_dt := NULL;
  END IF;
  -- Get the cutoff date from the previous period
  OPEN c_ci_cir_ct_cs1 (
        v_sca_version_number);
  FETCH c_ci_cir_ct_cs1 INTO
        v_prev_prg_cal_type,
        v_prev_prg_ci_sequence_number;
  IF c_ci_cir_ct_cs1%FOUND THEN
    CLOSE c_ci_cir_ct_cs1;
    v_previous_cutoff_dt := IGS_PR_GEN_001.prgp_get_prg_efctv(
              v_prev_prg_cal_type,
              v_prev_prg_ci_sequence_number);
  ELSE
    CLOSE c_ci_cir_ct_cs1;
  END IF;
  -- Check for contribution to a previous period
  IF v_unit_attempt_status = cst_discontin THEN
    IF TRUNC(v_discontinued_dt) <= v_previous_cutoff_dt THEN
      RETURN 'N';
    END IF;
  ELSIF v_unit_attempt_status IN (
          cst_completed,
          cst_duplicate) OR
            (v_unit_attempt_status = 'ENROLLED' AND
           v_outcome_dt IS NOT NULL) THEN
    IF v_outcome_dt <= v_previous_cutoff_dt THEN
      RETURN 'N';
    END IF;
  END IF;
  -- Check which progression period
  OPEN c_ci_cir_ct_cs2 (
        v_sca_version_number);
  FETCH c_ci_cir_ct_cs2 INTO v_dummy;
  IF c_ci_cir_ct_cs2%FOUND THEN
    CLOSE c_ci_cir_ct_cs2;
    v_cutoff_dt := IGS_PR_GEN_001.prgp_get_prg_efctv(
            p_prg_cal_type,
            p_prg_ci_sequence_number);
    IF v_discontinued_dt IS NULL THEN
      IF v_unit_attempt_status = cst_enrolled AND
          v_outcome_dt IS NULL THEN
        RETURN 'N';
      ELSE
        IF v_outcome_dt <= v_cutoff_dt THEN
          RETURN 'Y';
        END IF;
      END IF;
    ELSE
      IF TRUNC(v_discontinued_dt) <= v_cutoff_dt THEN
        RETURN 'Y';
      END IF;
    END IF;
  ELSE
    CLOSE c_ci_cir_ct_cs2;
    RETURN 'Y';
  END IF;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    IF c_cir%ISOPEN THEN
      CLOSE c_cir;
    END IF;
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    IF c_sca%ISOPEN THEN
      CLOSE c_sca;
    END IF;
    IF c_ci_cir_ct_cs1%ISOPEN THEN
      CLOSE c_ci_cir_ct_cs1;
    END IF;
    IF c_ci_cir_ct_cs2%ISOPEN THEN
      CLOSE c_ci_cir_ct_cs2;
    END IF;
    RAISE;
END;

EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_002.PRGP_GET_SUA_PRG_PRD');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_sua_prg_prd;
--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_wam
--
FUNCTION prgp_get_sua_wam (
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_abort_when_missing_ind IN VARCHAR2,
  p_wam_type IN VARCHAR2 DEFAULT 'COURSE',
  p_uoo_id IN NUMBER)
RETURN NUMBER AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_sua_wam
  -- Get the mark value applicable to WAM for a nominated student IGS_PS_UNIT attempt,
  -- considering the options that are available to the WAM calculation.
  -- A return of -1000000 means that the overall WAM check should be aborted
  -- due to a missing grade.
DECLARE
  cst_discontin   CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_enrolled    CONSTANT  VARCHAR2(10) := 'ENROLLED';
  cst_abort_WAM   CONSTANT  NUMBER := -1000000;
  v_unit_attempt_status     IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
  v_s_result_type       IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_outcome_dt        IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  v_grading_schema_cd       IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gs_version_number       IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_grade         IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_mark          IGS_AS_SU_STMPTOUT.mark%TYPE;
  v_origin_course_cd      IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_finalised_ind       VARCHAR2(1);
  v_administrative_unit_status            IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE;
  v_effective_progression_ind   IGS_AD_ADM_UNIT_STAT.effective_progression_ind%TYPE;

  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the SELECT clause of cursor c_sua.
  --
  CURSOR c_sua IS
    SELECT  sua.unit_attempt_status,sua.administrative_unit_status
    FROM  IGS_EN_SU_ATTEMPT sua
    WHERE sua.person_id   = p_person_id AND
      sua.course_cd   = p_course_cd AND
      sua.uoo_id = p_uoo_id;
  CURSOR c_aus (
    cp_administrative_unit_status IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE) IS
    SELECT effective_progression_ind
    FROM   IGS_AD_ADM_UNIT_STAT
    WHERE  administrative_unit_status=cp_administrative_unit_status;
BEGIN
  OPEN c_sua;
  FETCH c_sua INTO v_unit_attempt_status,v_administrative_unit_status;
  IF c_sua%NOTFOUND THEN
    CLOSE c_sua;
    RETURN NULL;
  END IF;
  CLOSE c_sua;
  -- Discontinued outcomes get a mark of zero
  IF v_unit_attempt_status = cst_discontin THEN

  --  RETURN 0;
  OPEN c_aus(v_administrative_unit_status);
  FETCH c_aus INTO v_effective_progression_ind;
  CLOSE c_aus;
  -- If the admin unit status is not effective for progression then ignore

  IF v_effective_progression_ind = 'N' THEN
    RETURN NULL;
  ELSE
    RETURN 0;
  END IF;

  END IF;
  IF v_unit_attempt_status = cst_enrolled AND p_use_recommended_ind = 'N' THEN
    -- If enrolled return value appropriate to parameter

    IF p_wam_type = 'PERIOD' AND p_abort_when_missing_ind = 'Y' THEN
      RETURN cst_abort_WAM;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    -- Retrieve the latest outcome
    IF p_use_recommended_ind = 'N' THEN
      v_finalised_ind := 'Y';
    ELSE
      v_finalised_ind := 'N';
    END IF;
    --
    -- kdande; 22-Apr-2003; Bug# 2829262
    -- Added uoo_id parameter to the IGS_AS_GEN_003.assp_get_sua_outcome
    -- FUNCTION call.
    --
    v_s_result_type := IGS_AS_GEN_003.assp_get_sua_outcome (
              p_person_id,
              p_course_cd,
              p_unit_cd,
              p_cal_type,
              p_ci_sequence_number,
              v_unit_attempt_status,
              v_finalised_ind,
              v_outcome_dt,
              v_grading_schema_cd,
              v_gs_version_number,
              v_grade,
              v_mark,
              v_origin_course_cd,
              p_uoo_id,
--added by LKAKI---
	      'N');
    IF v_s_result_type IS NULL OR
        v_mark IS NULL THEN
      IF p_wam_type = 'COURSE' THEN
      IF v_s_result_type IS NOT NULL AND
         v_mark IS NOT NULL AND
         p_abort_when_missing_ind = 'Y' THEN
        RETURN cst_abort_WAM;
      ELSE
        RETURN NULL;
      END IF;
      ELSE
      -- Handle missing mark according to parameter
      IF p_abort_when_missing_ind = 'Y' THEN
        RETURN cst_abort_WAM;
      ELSE
        RETURN NULL;
      END IF;
      END IF;

    ELSE
      -- Return the mark retrieved
      RETURN v_mark;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_sua%ISOPEN THEN
      CLOSE c_sua;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_002.PRGP_GET_SUA_WAM');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_sua_wam;

END IGS_PR_GEN_002;

/
