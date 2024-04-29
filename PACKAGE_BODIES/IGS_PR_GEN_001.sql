--------------------------------------------------------
--  DDL for Package Body IGS_PR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_GEN_001" AS
/* $Header: IGSPR01B.pls 115.7 2003/05/30 07:19:17 kdande ship $ */
FUNCTION PRGP_GET_CAL_STREAM(
  P_COURSE_CD IN VARCHAR2 ,
  P_VERSION_NUMBER IN NUMBER ,
  P_PRG_CAL_TYPE IN VARCHAR2 ,
  p_comparison_prg_cal_type IN VARCHAR2 )
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_cal_stream
  -- Get whether a progression calendar instance is within the same stream as
  -- another. This refers to the stream concepts held within the progression
  -- configuration structure.
DECLARE
  v_stream_num          IGS_PR_S_CRV_PRG_CAL.stream_num%TYPE;
  v_dummy           VARCHAR2(1);
  CURSOR c_scpc1 IS
    SELECT  scpc.stream_num
    FROM  IGS_PR_S_CRV_PRG_CAL      scpc
    WHERE scpc.course_cd      = p_course_cd AND
      scpc.version_number     = p_version_number AND
      scpc.prg_cal_type     = p_prg_cal_type;
  CURSOR c_scpc2 (
    cp_stream_num       IGS_PR_S_CRV_PRG_CAL.stream_num%TYPE) IS
    SELECT  'X'
    FROM  IGS_PR_S_CRV_PRG_CAL      scpc
    WHERE scpc.course_cd      = p_course_cd AND
      scpc.version_number     = p_version_number AND
      scpc.prg_cal_type     = p_comparison_prg_cal_type AND
      scpc.stream_num     = cp_stream_num;
  CURSOR c_sopc1 IS
    SELECT  sopc.org_unit_cd,
      sopc.ou_start_dt,
      sopc.stream_num
    FROM  IGS_PR_S_OU_PRG_CAL       sopc
    WHERE prgp_get_crv_cmt(
        p_course_cd,
        p_version_number,
        sopc.org_unit_cd,
        sopc.ou_start_dt)   = 'Y' AND
      sopc.prg_cal_type     = p_prg_cal_type;
  v_sopc_rec          c_sopc1%ROWTYPE;
  CURSOR c_sopc2 (
    cp_org_unit_cd        IGS_PR_S_OU_PRG_CAL.org_unit_cd%TYPE,
    cp_ou_start_dt        IGS_PR_S_OU_PRG_CAL.ou_start_dt%TYPE,
    cp_stream_num       IGS_PR_S_OU_PRG_CAL.stream_num%TYPE) IS
    SELECT  'X'
    FROM  IGS_PR_S_OU_PRG_CAL       sopc
    WHERE sopc.org_unit_cd    = cp_org_unit_cd AND
      sopc.ou_start_dt    = cp_ou_start_dt AND
      sopc.prg_cal_type     = p_comparison_prg_cal_type AND
      sopc.stream_num     = cp_stream_num;
  CURSOR c_spc1 IS
    SELECT  spc.stream_num
    FROM  IGS_PR_S_PRG_CAL      spc
    WHERE spc.s_control_num     = 1 AND
      spc.prg_cal_type    = p_prg_cal_type;
  CURSOR c_spc2 (
    cp_stream_num       IGS_PR_S_PRG_CAL.stream_num%TYPE) IS
    SELECT  'X'
    FROM  IGS_PR_S_PRG_CAL      spc
    WHERE spc.s_control_num     = 1 AND
      spc.prg_cal_type    = p_comparison_prg_cal_type AND
      spc.stream_num      = cp_stream_num;
BEGIN
  -- Select from within IGS_PS_COURSE override structure
  OPEN c_scpc1;
  FETCH c_scpc1 INTO v_stream_num;
  IF c_scpc1%FOUND THEN
    CLOSE c_scpc1;
    OPEN c_scpc2 (
        v_stream_num);
    FETCH c_scpc2 INTO v_dummy;
    IF c_scpc2%FOUND THEN
      CLOSE c_scpc2;
      RETURN 'Y';
    ELSE
      CLOSE c_scpc2;
      RETURN 'N';
    END IF;
  END IF;
  CLOSE c_scpc1;
  -- Select from within organisation IGS_PS_UNIT structure
  OPEN c_sopc1;
  FETCH c_sopc1 INTO v_sopc_rec;
  IF c_sopc1%FOUND THEN
    CLOSE c_sopc1;
    OPEN c_sopc2 (
        v_sopc_rec.org_unit_cd,
        v_sopc_rec.ou_start_dt,
        v_sopc_rec.stream_num);
    FETCH c_sopc2 INTO v_dummy;
    IF c_sopc2%FOUND THEN
      CLOSE c_sopc2;
      RETURN 'Y';
    ELSE
      CLOSE c_sopc2;
      RETURN 'N';
    END IF;
  END IF;
  CLOSE c_sopc1;
  -- Select from within system default structure
  OPEN c_spc1;
  FETCH c_spc1 INTO v_stream_num;
  IF c_spc1%FOUND THEN
    CLOSE c_spc1;
    OPEN c_spc2 (
        v_stream_num);
    FETCH c_spc2 INTO v_dummy;
    IF c_spc2%FOUND THEN
      CLOSE c_spc2;
      RETURN 'Y';
    ELSE
      CLOSE c_spc2;
      RETURN 'N';
    END IF;
  END IF;
  CLOSE c_spc1;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    IF c_scpc1%ISOPEN THEN
      CLOSE c_scpc1;
    END IF;
    IF c_scpc2%ISOPEN THEN
      CLOSE c_scpc2;
    END IF;
    IF c_sopc1%ISOPEN THEN
      CLOSE c_sopc1;
    END IF;
    IF c_sopc2%ISOPEN THEN
      CLOSE c_sopc2;
    END IF;
    IF c_spc1%ISOPEN THEN
      CLOSE c_spc1;
    END IF;
    IF c_spc2%ISOPEN THEN
      CLOSE c_spc2;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_001.PRGP_GET_CAL_STREAM');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_cal_stream;

FUNCTION PRGP_GET_CRV_CMT(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE )
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_crv_cmt
  -- Get whether IGS_PS_COURSE version is covered by the nominated committee structure
DECLARE
  v_ou_rel_found    BOOLEAN DEFAULT FALSE;
  v_dummy     VARCHAR2(1);
  CURSOR c_crv_cow IS
    SELECT  crv.course_type,
      cow.org_unit_cd,
      cow.ou_start_dt
    FROM  IGS_PS_VER    crv,
      IGS_PS_OWN  cow
    WHERE crv.course_cd   = p_course_cd AND
      crv.version_number  = p_version_number AND
      crv.course_cd   = cow.course_cd AND
      crv.version_number  = cow.version_number;
  CURSOR c_our (
    cp_cow_org_unit_cd  IGS_OR_UNIT.org_unit_cd%TYPE,
    cp_cow_ou_start_dt  IGS_OR_UNIT.start_dt%TYPE,
    cp_course_type    IGS_PS_VER.course_type%TYPE) IS
    SELECT  'X'
    FROM  IGS_OR_UNIT_REL our
    WHERE our.parent_org_unit_cd  = p_org_unit_cd AND
      our.parent_start_dt = p_ou_start_dt AND
      our.child_org_unit_cd = cp_cow_org_unit_cd AND
      our.child_start_dt  = cp_cow_ou_start_dt AND
      our.logical_delete_dt IS NULL AND
      EXISTS  (
      SELECT  'X'
      FROM  IGS_OR_REL_PS_TYPE  ourct
      WHERE our.parent_org_unit_cd  = ourct.parent_org_unit_cd AND
        our.parent_start_dt = ourct.parent_start_dt AND
        our.child_org_unit_cd = ourct.child_org_unit_cd AND
        our.child_start_dt  = ourct.child_start_dt AND
        our.create_dt   = ourct.our_create_dt AND
        ourct.course_type = cp_course_type);
BEGIN
  FOR v_crv_cow_rec IN c_crv_cow LOOP

--gjha Added the following missing code. This will return true if the direct match is found.
    IF v_crv_cow_rec.org_unit_cd = p_org_unit_cd  AND
        v_crv_cow_rec.ou_start_dt = p_ou_start_dt THEN
      RETURN 'Y';
    END IF;

                OPEN c_our (
      v_crv_cow_rec.org_unit_cd,
      v_crv_cow_rec.ou_start_dt,
      v_crv_cow_rec.course_type);
    FETCH c_our INTO v_dummy;
    IF c_our%FOUND THEN
      CLOSE c_our;
      v_ou_rel_found := TRUE;
      EXIT;
    ELSE
      CLOSE c_our;
      IF IGS_OR_GEN_001.orgp_get_within_ou (
            p_org_unit_cd,
            p_ou_start_dt,
            v_crv_cow_rec.org_unit_cd,
            v_crv_cow_rec.ou_start_dt,
            'N') = 'Y' THEN
        v_ou_rel_found := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;
  IF v_ou_rel_found THEN
    RETURN 'Y';
  END IF;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    IF c_crv_cow%ISOPEN THEN
      CLOSE c_crv_cow;
    END IF;
    IF c_our%ISOPEN THEN
      CLOSE c_our;
    END IF;
                RETURN 'N';
          /* RAISE replaced by return 'N' if any error occurs in the main code block
                   Outer exception will not return N or Y if any error occurs in
                   declaration section
                */
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_001.PRGP_GET_CRV_CMT');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_crv_cmt;

FUNCTION prgp_get_drtn_efctv(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_drtn_efctv
  -- Get whether the student is effectively enrolled in a progression period
  -- for the purposes of calculating a duration figure ; this is different
  -- from 'effective for the purposes of IGS_GE_MEASUREMENT' as this only counts
  -- progression periods within which the student ends enrolment.
DECLARE
  cst_active  CONSTANT    VARCHAR2(10) := 'ACTIVE';
  cst_teaching  CONSTANT    VARCHAR2(10) := 'TEACHING';
  cst_progress  CONSTANT    VARCHAR2(10) := 'PROGRESS';
  cst_enrolled  CONSTANT    VARCHAR2(10) := 'ENROLLED';
  cst_completed CONSTANT    VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT    VARCHAR2(10) := 'DISCONTIN';
  v_sua_enrolled        BOOLEAN DEFAULT FALSE;
  v_cir2_rec_not_found      BOOLEAN DEFAULT FALSE;
  v_match_not_found     BOOLEAN DEFAULT FALSE;
  CURSOR c_cat_ci_cir_cs1 IS
    SELECT  cir.sub_cal_type,
      cir.sub_ci_sequence_number
    FROM  IGS_CA_TYPE       cat,
      IGS_CA_INST     ci,
      IGS_CA_INST_REL     cir,
      IGS_CA_STAT     cs
    WHERE cir.sup_cal_type      = p_prg_cal_type AND
      cir.sup_ci_sequence_number  = p_prg_sequence_number AND
      ci.cal_type     = cir.sub_cal_type AND
      ci.sequence_number    = cir.sub_ci_sequence_number AND
      cs.cal_status     = ci.cal_status AND
      cs.s_cal_status     = cst_active AND
      cat.cal_type      = ci.cal_type AND
      cat.s_cal_cat     = cst_teaching;
  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the SELECT clause of cursor c_sua_sca.
  --
  CURSOR c_sua_sca (
    cp_sub_cal_type     IGS_CA_INST_REL.sub_cal_type%TYPE,
    cp_sub_ci_sequence_number IGS_CA_INST_REL.sub_ci_sequence_number%TYPE) IS
    SELECT  sua.unit_cd,
      sua.cal_type,
      sua.ci_sequence_number,
      sua.unit_attempt_status,
      sua.discontinued_dt,
      sca.version_number,
      sua.uoo_id
    FROM  IGS_EN_SU_ATTEMPT     sua,
      IGS_EN_STDNT_PS_ATT   sca
    WHERE sua.person_id     = p_person_id AND
      sua.course_cd     = p_course_cd AND
      sca.person_id     = sua.person_id AND
      sca.course_cd     = sua.course_cd AND
      sua.cal_type      = cp_sub_cal_type AND
      sua.ci_sequence_number    = cp_sub_ci_sequence_number AND
      sua.unit_attempt_status IN (
              cst_enrolled,
              cst_completed,
              cst_discontin);
  CURSOR c_cat_ci_cir_cs2 (
    cp_sua_cal_type     IGS_EN_SU_ATTEMPT.cal_type%TYPE,
    cp_sua_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
    cp_sca_version_number   IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
    SELECT  cir.sup_cal_type,
      cir.sup_ci_sequence_number
    FROM  IGS_CA_TYPE       cat,
      IGS_CA_INST     ci1,
      IGS_CA_INST_REL     cir,
      IGS_CA_STAT     cs
    WHERE cir.sub_cal_type      = cp_sua_cal_type AND
      cir.sub_ci_sequence_number  = cp_sua_ci_sequence_number AND
      ci1.cal_type      = cir.sup_cal_type AND
      ci1.sequence_number   = cir.sup_ci_sequence_number AND
      cs.cal_status     = ci1.cal_status AND
      cs.s_cal_status     = cst_active AND
      cat.cal_type      = ci1.cal_type AND
      cat.s_cal_cat     = cst_progress AND
      prgp_get_cal_stream (
        p_course_cd,
        cp_sca_version_number,
        p_prg_cal_type,
        cir.sup_cal_type)   = 'Y' AND
      ci1.start_dt <
      (SELECT ci2.start_dt
      FROM  IGS_CA_INST   ci2
      WHERE ci2.cal_type    = p_prg_cal_type AND
        ci2.sequence_number = p_prg_sequence_number);
BEGIN
  FOR v_cir1_rec IN c_cat_ci_cir_cs1 LOOP
    FOR v_sua_rec IN c_sua_sca (
          v_cir1_rec.sub_cal_type,
          v_cir1_rec.sub_ci_sequence_number) LOOP
      IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
        v_sua_enrolled := TRUE;
        EXIT;
      END IF;
      -- Call routine to determine to which period it applies
      v_cir2_rec_not_found := TRUE;
      v_match_not_found := TRUE;
      FOR v_cir2_rec IN c_cat_ci_cir_cs2 (
              v_sua_rec.cal_type,
              v_sua_rec.ci_sequence_number,
              v_sua_rec.version_number) LOOP
        v_cir2_rec_not_found := FALSE;
        --
        -- kdande; 22-Apr-2003; Bug# 2829262
        -- Added uoo_id parameter to the IGS_PR_GEN_002.prgp_get_sua_prg_prd FUNCTION call.
        --
        IF IGS_PR_GEN_002.prgp_get_sua_prg_prd (
              v_cir2_rec.sup_cal_type,
              v_cir2_rec.sup_ci_sequence_number,
              p_person_id,
              p_course_cd,
              v_sua_rec.unit_cd,
              v_sua_rec.cal_type,
              v_sua_rec.ci_sequence_number,
              'Y',
              v_sua_rec.unit_attempt_status,
              v_sua_rec.discontinued_dt,
              v_sua_rec.uoo_id) = 'Y' THEN
          v_match_not_found := FALSE;
          EXIT;
        END IF;
      END LOOP;
      IF v_cir2_rec_not_found OR
          v_match_not_found THEN
        EXIT;
      END IF;
    END LOOP;
    IF v_sua_enrolled THEN
      EXIT;
    END IF;
    IF v_cir2_rec_not_found OR
        v_match_not_found THEN
      EXIT;
    END IF;
  END LOOP;
  IF v_sua_enrolled THEN
    RETURN 'Y';
  END IF;
  IF v_cir2_rec_not_found OR
      v_match_not_found THEN
    RETURN 'Y';
  END IF;
  RETURN 'N';
EXCEPTION
  WHEN OTHERS THEN
    IF c_cat_ci_cir_cs1%ISOPEN THEN
      CLOSE c_cat_ci_cir_cs1;
    END IF;
      IF c_sua_sca%ISOPEN THEN
      CLOSE c_sua_sca;
    END IF;
    IF c_cat_ci_cir_cs2%ISOPEN THEN
      CLOSE c_cat_ci_cir_cs2;
    END IF;
    RETURN 'N';
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_001.PRGP_GET_DRTN_EFCTV');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_drtn_efctv;



FUNCTION prgp_get_msr_efctv(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2 AS
  gv_other_detail   VARCHAR2(255);
BEGIN   -- prgp_get_msr_efctv
  -- Get whether the student is effectively enrolled in a progression period
  -- for the purposes of progression IGS_GE_MEASUREMENT.
  -- Routine returns 'Y', 'N' or 'P' - indicating that IGS_PS_UNIT is currently
  -- enrolled and is potentially contributing to the period.
DECLARE
  cst_active    CONSTANT  VARCHAR2(10) := 'ACTIVE';
  cst_teaching    CONSTANT  VARCHAR2(10) := 'TEACHING';
  cst_enrolled    CONSTANT  VARCHAR2(10) := 'ENROLLED';
  cst_completed   CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin   CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  v_potential       VARCHAR2(1) DEFAULT 'N';
  v_effective_dt        DATE;
  v_period_found        BOOLEAN DEFAULT FALSE;
  CURSOR c_cat_ci_cir_cs IS
    SELECT  cir.sub_cal_type,
      cir.sub_ci_sequence_number
    FROM  IGS_CA_TYPE       cat,
      IGS_CA_INST     ci,
      IGS_CA_INST_REL     cir,
      IGS_CA_STAT     cs
    WHERE cir.sup_cal_type      = p_prg_cal_type AND
      cir.sup_ci_sequence_number  = p_prg_sequence_number AND
      ci.cal_type     = cir.sub_cal_type AND
      ci.sequence_number    = cir.sub_ci_sequence_number AND
      ci.cal_status     = cs.cal_status AND
      cs.s_cal_status     = cst_active AND
      cat.cal_type      = ci.cal_type AND
      cat.s_cal_cat     = cst_teaching;
  --
  -- kdande; 22-Apr-2003; Bug# 2829262
  -- Added uoo_id field to the SELECT clause of the cursor c_sua_sca.
  --
  CURSOR c_sua_sca (
    cp_sub_cal_type     IGS_CA_INST_REL.sub_cal_type%TYPE,
    cp_sub_ci_sequence_number
            IGS_CA_INST_REL.sub_ci_sequence_number%TYPE) IS
    SELECT  sua.unit_cd,
      sua.cal_type,
      sua.ci_sequence_number,
      sua.unit_attempt_status,
      sua.discontinued_dt,
      sua.uoo_id
    FROM  IGS_EN_SU_ATTEMPT     sua
    WHERE sua.person_id     = p_person_id AND
      sua.course_cd     = p_course_cd AND
      sua.cal_type      = cp_sub_cal_type AND
      sua.ci_sequence_number    = cp_sub_ci_sequence_number AND
      sua.unit_attempt_status IN (
              cst_enrolled,
              cst_completed,
              cst_discontin);
BEGIN
  FOR v_cir_rec IN c_cat_ci_cir_cs LOOP
    FOR v_sua_rec IN c_sua_sca (
          v_cir_rec.sub_cal_type,
          v_cir_rec.sub_ci_sequence_number) LOOP
      IF v_sua_rec.unit_attempt_status = cst_enrolled THEN
        -- Determine if already beyond the period
        v_effective_dt := prgp_get_prg_efctv(
                p_prg_cal_type,
                p_prg_sequence_number);
        IF v_effective_dt IS NULL OR
            v_effective_dt > SYSDATE THEN
          v_potential := 'Y';
        END IF;
      ELSE
        -- Call routine to determine which period it applies
        v_period_found := FALSE;
        --
        -- kdande; 22-Apr-2003; Bug# 2829262
        -- Added uoo_id parameter to the IGS_PR_GEN_002.prgp_get_sua_prg_prd FUNCTION call.
        --
        IF IGS_PR_GEN_002.prgp_get_sua_prg_prd (
              p_prg_cal_type,
              p_prg_sequence_number,
              p_person_id,
              p_course_cd,
              v_sua_rec.unit_cd,
              v_sua_rec.cal_type,
              v_sua_rec.ci_sequence_number,
              'Y',
              v_sua_rec.unit_attempt_status,
              v_sua_rec.discontinued_dt,
              v_sua_rec.uoo_id) = 'Y' THEN
          v_period_found := TRUE;
          EXIT;
        END IF;
      END IF;
    END LOOP;
    IF v_period_found THEN
      EXIT;
    END IF;
  END LOOP;
  IF v_period_found THEN
    RETURN 'Y';
  END IF;
  IF v_potential = 'Y' THEN
    RETURN 'P';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_cat_ci_cir_cs%ISOPEN THEN
      CLOSE c_cat_ci_cir_cs;
    END IF;
    IF c_sua_sca%ISOPEN THEN
      CLOSE c_sua_sca;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_001.PRGP_GET_MSR_EFCTV');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_msr_efctv;

FUNCTION prgp_get_prg_efctv(
  p_prg_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_prg_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE )
RETURN DATE AS
BEGIN   -- prgp_get_prg_efctv
  -- Get the effective date of a nominated progression period.
  -- This is retrieved from the IGS_CA_DA_INST table matching the value
  -- stored in the progression configuration table. If no date alias is found,
  -- then the end date of the progression period is returned
DECLARE
  v_alias_val     IGS_CA_DA_INST.absolute_val%TYPE;
  CURSOR c_dai IS
    SELECT  IGS_CA_GEN_001.calp_get_alias_val(
          dai.dt_alias,
          dai.sequence_number,
          dai.cal_type,
          dai.ci_sequence_number)
    FROM  IGS_CA_DA_INST  dai
    WHERE dai.cal_type    = p_prg_cal_type AND
      dai.ci_sequence_number  = p_prg_sequence_number AND
      dt_alias    =
      (SELECT sprgcc.effective_end_dt_alias
      FROM  IGS_PR_S_PRG_CONF   sprgcc
      WHERE sprgcc.s_control_num  = 1)
    ORDER BY 1 DESC;  -- for latest if multiple dates exist
  CURSOR c_ci IS
    SELECT  ci.end_dt
    FROM  IGS_CA_INST   ci
    WHERE ci.cal_type   = p_prg_cal_type AND
      ci.sequence_number  = p_prg_sequence_number;
BEGIN
  -- Search for alias value within the calendar
  OPEN c_dai;
  FETCH c_dai INTO v_alias_val;
  IF c_dai%NOTFOUND THEN
    CLOSE c_dai;
    -- Search for the calendar instance end_dt
    OPEN c_ci;
    FETCH c_ci INTO v_alias_val;
    CLOSE c_ci;
  ELSE
    CLOSE c_dai;
  END IF;
  RETURN v_alias_val;
EXCEPTION
  WHEN OTHERS THEN
    IF c_dai%ISOPEN THEN
      CLOSE c_dai;
    END IF;
    IF c_ci%ISOPEN THEN
      CLOSE c_ci;
    END IF;
    RAISE;
END;
END prgp_get_prg_efctv;

FUNCTION prgp_get_sca_elps_tm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_commencement_dt IN DATE ,
  p_effective_dt IN DATE DEFAULT SYSDATE)
RETURN NUMBER AS
  gv_other_detail   VARCHAR2(255);
BEGIN
DECLARE
  v_commencement_dt IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  v_time_elapsed    NUMBER;
  v_yrs_elapsed   NUMBER;
  CURSOR c_sca IS
    SELECT  sca.commencement_dt
    FROM  IGS_EN_STDNT_PS_ATT sca
    WHERE sca.person_id = p_person_id AND
      sca.course_cd = p_course_cd;
BEGIN
  --Routine to calculate the elapsed time taken by a student for a
  -- student IGS_PS_COURSE attempt.  The routine will return the elapsed time
  -- as a number (in years or fractions of years).
  IF p_commencement_dt IS NULL THEN
    OPEN c_sca;
    FETCH c_sca INTO v_commencement_dt;
    IF ((c_sca%NOTFOUND) OR v_commencement_dt IS NULL) THEN
      CLOSE c_sca;
      RETURN 0;
    END IF;
    CLOSE c_sca;
  ELSE
    v_commencement_dt := p_commencement_dt;
  END IF;
  v_time_elapsed := MONTHS_BETWEEN(p_effective_dt, v_commencement_dt);
  v_yrs_elapsed := v_time_elapsed/12;
  RETURN ROUND(v_yrs_elapsed, 2);
END;
EXCEPTION
  WHEN OTHERS THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_PR_GEN_001.PRGP_GET_SCA_ELPS_TM');
                --IGS_GE_MSG_STACK.ADD;

END prgp_get_sca_elps_tm;

FUNCTION PRGP_GET_SCA_GPA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_course_stage_type IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_best_worst IN VARCHAR2 ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_use_first_attempt_ind IN VARCHAR2 ,
  p_use_entered_grade_ind IN VARCHAR2 )
RETURN NUMBER AS
BEGIN
DECLARE
  v_gpa_value NUMBER;
BEGIN
  v_gpa_value := TO_NUMBER( IGS_RU_GEN_004.rulp_val_gpa (
      p_person_id,
      p_course_cd,
      p_prg_cal_type,
      p_prg_sequence_number,
      p_best_worst,
      p_use_recommended_ind) );
  RETURN v_gpa_value;
EXCEPTION
  WHEN VALUE_ERROR THEN
    RETURN 0;
END;
END prgp_get_sca_gpa;
END IGS_PR_GEN_001;

/
