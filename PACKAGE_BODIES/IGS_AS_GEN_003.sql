--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_003" AS
/* $Header: IGSAS03B.pls 120.1 2006/01/31 01:50:14 smaddali noship $ */

/* Change History
 who       when         what
 smvk      09-Jul-2004  Bug # 3676145. Modified cursors c_usa to use Active (not closed) unit classes.
 lkaki     20-Aug-2004  Bug # 3842511. Added additional parameter for including the grade and mark
                                       for the students whose outcomes are released.
  smaddali 20-dec-2005  Bug#4666657 : modified procedure assp_get_sua_outcome to loop thru chain transfers
 */
  --
  FUNCTION assp_get_sua_exam_tp(
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_unit_cd IN VARCHAR2 ,
    p_cal_type IN VARCHAR2 ,
    p_ci_sequence_number IN NUMBER ,
    p_unit_attempt_status IN VARCHAR2 ,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id IN NUMBER )
  RETURN VARCHAR2 IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_get_sua_exam_tp
    -- Get the examination type for a student unit attempt attempt assessment item.
    -- This routine will ascertain if the student is sitting a NORMAL exam,
    -- or whether they are doing a SUPPLEMENTARY or SPECIAL examination.
    -- The supp/special attribute is ascertained from the students grade.
    -- The grading schema grade table has a field indicating whether the grade
    -- signifies the granting of a supp/special examination.
          --ijeddy, Bug 3201661, Grade Book.
  DECLARE
    CURSOR c_gsg IS
      SELECT  gsg.s_special_grade_type
      FROM  IGS_AS_SU_STMPTOUT  suao,
        IGS_AS_GRD_SCH_GRADE  gsg
      WHERE suao.person_id    = p_person_id  AND
        suao.course_cd    = p_course_cd  AND
                          -- anilk, 22-Apr-2003, Bug# 2829262
        suao.uoo_id             = p_uoo_id     AND
        suao.finalised_outcome_ind = 'Y' AND
        suao.grading_schema_cd  = gsg.grading_schema_cd AND
        suao.version_number   = gsg.version_number AND
        suao.grade    = gsg.grade AND
        suao.outcome_dt IN (SELECT  MAX(outcome_dt)
                 FROM IGS_AS_SU_STMPTOUT
                 WHERE  person_id = suao.person_id AND
                        course_cd = suao.course_cd AND
                                                            -- anilk, 22-Apr-2003, Bug# 2829262
                        uoo_id    = suao.uoo_id);

    cst_normal  CONSTANT VARCHAR2(15) := 'NORMAL';
    cst_special CONSTANT VARCHAR2(15) := 'SPECIAL';
    cst_supp    CONSTANT VARCHAR2(15) := 'SUPP';
    v_s_special_grade_type    IGS_AS_GRD_SCH_GRADE.s_special_grade_type%TYPE;
  BEGIN
    -- If the IGS_PS_UNIT attempt status is not completed then it must be a normal
    -- examination.
    IF p_unit_attempt_status <> 'COMPLETED' THEN
      RETURN cst_normal;
    END IF;
    -- Select the latest grade from the view
    OPEN c_gsg;
    FETCH c_gsg INTO v_s_special_grade_type;
    IF c_gsg%NOTFOUND THEN
      CLOSE c_gsg;
      RETURN cst_normal;
    END IF;
    CLOSE c_gsg;
    IF v_s_special_grade_type = 'SUPP-EXAM' THEN
      RETURN cst_supp;
    ELSIF v_s_special_grade_type = 'SPECIAL-EXAM' THEN
      RETURN cst_special;
    ELSE
      RETURN cst_normal;
    END IF;
  END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END assp_get_sua_exam_tp;
  FUNCTION assp_get_sua_exloc(
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_unit_cd IN VARCHAR2 ,
    p_cal_type IN VARCHAR2 ,
    p_ci_sequence_number IN NUMBER ,
    p_ass_id IN NUMBER ,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id IN NUMBER )
  RETURN VARCHAR2 IS
  BEGIN
    -- assp_get_sua_exloc
    -- Get the applicable examination IGS_AD_LOCATION for a nominated student
    -- IGS_PS_UNIT attempt record.
    -- The routine will search for (in order of preference):
    -- 0. Non-central examination (see below)
    -- 1. A IGS_EN_SU_ATTEMPT.exam_location_cd value
    -- 2. A IGS_EN_STDNT_PS_ATT.exam_location_cd value
    -- 3. The default exam IGS_AD_LOCATION for the enrolled IGS_PS_UNIT attempt
    -- If the assessment id is passed as a parameter, the routine will determine
    -- whether the examination is a non-central examination, in which case all
    -- students are grouped under a single examination IGS_AD_LOCATION. This IGS_AD_LOCATION
    -- is defined in the IGS_AS_SASSESS_TYPE table.
    DECLARE
      v_nonc_exam_loc_cd  IGS_AS_SASSESS_TYPE.non_cntrl_exam_loc_cd%TYPE;
      v_sua_location    IGS_AD_LOCATION.location_cd%TYPE;
      v_sca_location    IGS_AD_LOCATION.location_cd%TYPE;
      CURSOR c_sat IS
        SELECT  sat.non_cntrl_exam_loc_cd
        FROM  IGS_AS_ASSESSMNT_ITM    ai,
          IGS_AS_ASSESSMNT_TYP    atyp,
          IGS_AS_SASSESS_TYPE sat
        WHERE ai.ass_id   = p_ass_id    AND
          atyp.assessment_type  = ai.assessment_type  AND
          atyp.s_assessment_type  = 'NONCENTRAL'    AND
          sat.s_assessment_type= atyp.s_assessment_type;
      CURSOR c_sua IS
        SELECT  sua.location_cd,
          sua.exam_location_cd,
          um.s_unit_mode
        FROM  IGS_EN_SU_ATTEMPT sua,
          IGS_AS_UNIT_CLASS ucl,
          IGS_AS_UNIT_MODE um
        WHERE sua.person_id = p_person_id   AND
          sua.course_cd = p_course_cd   AND
                            -- anilk, 22-Apr-2003, Bug# 2829262
          sua.uoo_id      = p_uoo_id        AND
          ucl.unit_class  = sua.unit_class  AND
          um.unit_mode  = ucl.unit_mode   AND
          ucl.closed_ind  = 'N';
      v_sua_rec c_sua%ROWTYPE;
      CURSOR c_sca IS
        SELECT  exam_location_cd,
          location_cd
        FROM  IGS_EN_STDNT_PS_ATT
        WHERE person_id = p_person_id AND
          course_cd = p_course_cd;
      v_sca_rec c_sca%ROWTYPE;
    BEGIN
      -- 0. If assessment ID is set, then check for non-central examination IGS_AD_LOCATION.
      IF (p_ass_id IS NOT NULL) THEN
        OPEN c_sat;
        FETCH c_sat INTO v_nonc_exam_loc_cd;
        IF (c_sat%FOUND AND
            v_nonc_exam_loc_cd IS NOT NULL) THEN
          CLOSE c_sat;
          RETURN v_nonc_exam_loc_cd;
        END IF;
        CLOSE c_sat;
      END IF;
      -- 1. If any of the parameters are null return null
      IF (
        p_person_id IS NULL OR
        p_course_cd IS NULL OR
        p_unit_cd IS NULL OR
        p_cal_type  IS NULL OR
        p_ci_sequence_number IS NULL OR
        p_uoo_id        IS NULL ) THEN
        RETURN NULL;
      END IF;
      -- 2. Get details from the student IGS_PS_UNIT attempt record
      OPEN c_sua;
      FETCH c_sua INTO v_sua_rec;
      IF (c_sua%NOTFOUND) THEN
        CLOSE c_sua;
        RETURN NULL;
      END IF;
      CLOSE c_sua;
      -- 3. If the sua exam IGS_AD_LOCATION is set then return it
      IF (V_sua_rec.exam_location_cd IS NOT NULL) THEN
        RETURN v_sua_rec.exam_location_cd;
      END IF;
      -- 3.1 If On-Campus IGS_PS_UNIT use the default IGS_AD_LOCATION.
      IF (v_sua_rec.s_unit_mode = 'ON') THEN
        v_sua_location :=  IGS_AS_GEN_002.ASSP_GET_DFLT_EXLOC(v_sua_rec.location_cd);
        IF (v_sua_location IS NOT NULL) THEN
          RETURN v_sua_location;
        END IF;
      END IF;
      -- 4. Search for exam IGS_AD_LOCATION code in the student IGS_PS_COURSE attempt record
      OPEN c_sca;
      FETCH c_sca INTO v_sca_rec;
      CLOSE c_sca;
      IF (v_sca_rec.exam_location_cd IS NOT NULL) THEN
        RETURN v_sca_rec.exam_location_cd;
      END IF;
      --  5. Search for the default exam IGS_AD_LOCATION for the enrolled IGS_PS_UNIT campus
      v_sua_location :=  IGS_AS_GEN_002.ASSP_GET_DFLT_EXLOC(v_sua_rec.location_cd);
      IF (v_sua_location IS NOT NULL) THEN
        RETURN v_sua_location;
      END IF;
      -- 6. Search for the default exam IGS_AD_LOCATION for the enrolled IGS_PS_COURSE
      v_sca_location := IGS_AS_GEN_002.ASSP_GET_DFLT_EXLOC(v_sca_rec.location_cd);
      IF (v_sca_location IS NOT NULL) THEN
        RETURN v_sca_location;
      END IF;
      RETURN NULL;
    END;
  END assp_get_sua_exloc;
  FUNCTION assp_get_sua_grade(
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_unit_cd IN VARCHAR2 ,
    p_cal_type IN VARCHAR2 ,
    p_ci_sequence_number IN NUMBER ,
    p_unit_attempt_status IN VARCHAR2 ,
    p_finalised_ind IN VARCHAR2 ,
    p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
    p_gs_version_number OUT NOCOPY NUMBER ,
    p_grade OUT NOCOPY VARCHAR2 ,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id IN  NUMBER )
  RETURN VARCHAR2 IS
      gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_get_sua_grade
    -- This is an enrolments module.
    -- It gets the grade of a student IGS_PS_UNIT attempt within a IGS_PS_COURSE code.
    -- This routine will determine the appropriate grade (and its matching
    -- result type) and return them. If no grade is found NULL will be
    -- returned (and output parameters will be NULL).
    -- IGS_GE_NOTE: This routine handles DUPLICATE IGS_PS_UNIT attempts by searching for
    -- the 'source' IGS_PS_UNIT attempt and retrieving its grade.
    -- Note2: If the p_finalised_ind is set then only finalised grades will
    -- be returned.
    DECLARE
      cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
      cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
      cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
      cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
      v_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
      v_finalised_ind     VARCHAR2(1);
      v_sua_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
      v_gsg_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
      v_gsg_version_number    IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
      v_gsg_grade     IGS_AS_GRD_SCH_GRADE.grade%TYPE;
      v_gsg_s_result_type   IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
      v_suao_trans_grading_schema_cd
              IGS_AS_SU_STMPTOUT.translated_grading_schema_cd%TYPE;
      v_suao_trans_version_number
              IGS_AS_SU_STMPTOUT.translated_version_number%TYPE;
      v_suao_trans_grade    IGS_AS_SU_STMPTOUT.translated_grade%TYPE;
      v_gsg2_s_result_type    IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
      CURSOR c_sua (
        cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
        cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
        cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
        cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
                    -- anilk, 22-Apr-2003, Bug# 2829262
        cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
        ) IS
        SELECT  sut.transfer_course_cd
        FROM  IGS_PS_STDNT_UNT_TRN  sut,
          IGS_EN_SU_ATTEMPT sua
        WHERE sut.person_id     = cp_person_id AND
          sua.person_id     = sut.person_id AND
                            -- anilk, 22-Apr-2003, Bug# 2829262
          sut.uoo_id    = cp_uoo_id AND
          sua.uoo_id    = sut.uoo_id AND
          sua.course_cd = sut.transfer_course_cd AND
          sua.unit_attempt_status IN (cst_completed, cst_discontin)
          ORDER BY sua.unit_attempt_status;
      CURSOR c_suao_gsg (
        cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
        c_v_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE,
        cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
        cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
        cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
        c_v_finalised_ind VARCHAR2,
                    -- anilk, 22-Apr-2003, Bug# 2829262
        cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
        ) IS
        SELECT    gsg.grading_schema_cd,
            gsg.version_number,
            gsg.grade,
            gsg.s_result_type,
            suao.translated_grading_schema_cd,
            suao.translated_version_number,
            suao.translated_grade
        FROM    IGS_AS_SU_STMPTOUT  suao,
            IGS_AS_GRD_SCH_GRADE  gsg
        WHERE   suao.person_id      = cp_person_id AND
            suao.course_cd      = c_v_course_cd AND
                                    -- anilk, 22-Apr-2003, Bug# 2829262
            suao.uoo_id                     = cp_uoo_id AND
            suao.finalised_outcome_ind
                    LIKE DECODE(c_v_finalised_ind, 'Y', 'Y', '%') AND
            suao.grading_schema_cd    = gsg.grading_schema_cd AND
            suao.version_number     = gsg.version_number AND
            suao.grade      = gsg.grade
        ORDER BY  outcome_dt DESC;    -- will put the newest date first.
      CURSOR c_gsg2 IS
        SELECT  gsg2.s_result_type
        FROM  IGS_AS_GRD_SCH_GRADE gsg2
        WHERE gsg2.grading_schema_cd  = v_suao_trans_grading_schema_cd AND
          gsg2.version_number = v_suao_trans_version_number AND
          gsg2.grade    = v_suao_trans_grade;
    BEGIN
      p_grading_schema_cd := NULL;
      p_gs_version_number := NULL;
      p_grade := NULL;
      -- Depending on the status of the IGS_PS_UNIT attempt, set the grade search criteria.
      IF (p_unit_attempt_status = cst_duplicate) THEN
        -- Locate the original IGS_PS_UNIT attempt from which the grade was sourced.
        -- This will use IGS_PS_STDNT_UNT_TRN details created as a result of
        -- a IGS_PS_COURSE transfer
        OPEN  c_sua(
            p_person_id,
            p_unit_cd,
            p_cal_type,
            p_ci_sequence_number,
                                    -- anilk, 22-Apr-2003, Bug# 2829262
            p_uoo_id );
        FETCH c_sua INTO  v_sua_course_cd;
        IF (c_sua%NOTFOUND) THEN
          CLOSE c_sua;
          RETURN NULL;
        ELSE
          v_course_cd := v_sua_course_cd;
        END IF;
        CLOSE c_sua;
      ELSIF (p_unit_attempt_status = cst_completed OR
          p_unit_attempt_status = cst_discontin OR
          (p_finalised_ind = 'N' and p_unit_attempt_status = cst_enrolled)) THEN
        -- Use the parameter IGS_PS_COURSE code
        v_course_cd := p_course_cd;
      ELSE
        -- Only COMPLETED or DUPLICATED statuses have grades, so return NULL
        RETURN NULL;
      END IF;
      -- Search for the latest grade against the student IGS_PS_UNIT attempt
      OPEN  c_suao_gsg(
          p_person_id,
          v_course_cd,
          p_unit_cd,
          p_cal_type,
          p_ci_sequence_number,
          p_finalised_ind,
                            -- anilk, 22-Apr-2003, Bug# 2829262
                            p_uoo_id );
      FETCH c_suao_gsg  INTO  v_gsg_grading_schema_cd,
              v_gsg_version_number,
              v_gsg_grade,
              v_gsg_s_result_type,
              v_suao_trans_grading_schema_cd,
              v_suao_trans_version_number,
              v_suao_trans_grade;
      IF (c_suao_gsg%NOTFOUND) THEN
        CLOSE c_suao_gsg;
        RETURN NULL;
      ELSE
        -- Determine if the translated grade exists and is to be returned.
        IF v_suao_trans_grading_schema_cd IS NULL OR
            v_suao_trans_version_number IS NULL OR
            v_suao_trans_grade IS NULL THEN
          p_grading_schema_cd := v_gsg_grading_schema_cd;
          p_gs_version_number := v_gsg_version_number;
          p_grade := v_gsg_grade;
          CLOSE c_suao_gsg;
          RETURN  v_gsg_s_result_type;
        ELSE
          OPEN c_gsg2;
          FETCH c_gsg2 INTO v_gsg2_s_result_type;
          IF c_gsg2%NOTFOUND THEN
            p_grading_schema_cd := NULL;
            p_gs_version_number := NULL;
            p_grade := NULL;
            CLOSE c_suao_gsg;
            CLOSE c_gsg2;
            RETURN NULL;
          ELSE
            p_grading_schema_cd := v_suao_trans_grading_schema_cd;
            p_gs_version_number := v_suao_trans_version_number;
            p_grade := v_suao_trans_grade;
            CLOSE c_suao_gsg;
            CLOSE c_gsg2;
            RETURN v_gsg2_s_result_type;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF (c_sua%ISOPEN) THEN
          CLOSE c_sua;
        END IF;
        IF (c_suao_gsg%ISOPEN) THEN
          CLOSE c_suao_gsg;
        END IF;
        IF (c_gsg2%ISOPEN) THEN
          CLOSE c_gsg2;
        END IF;
        RAISE;
    END;
  END assp_get_sua_grade;
  FUNCTION assp_get_sua_gs(
    p_person_id IN NUMBER ,
    p_course_cd IN VARCHAR2 ,
    p_unit_cd IN VARCHAR2 ,
    p_version_number IN NUMBER ,
    p_cal_type IN VARCHAR2 ,
    p_ci_sequence_number IN NUMBER ,
    p_location_cd IN VARCHAR2 ,
    p_unit_class IN VARCHAR2 ,
    p_grading_schema OUT NOCOPY VARCHAR2 ,
    p_gs_version_number OUT NOCOPY NUMBER
   ) RETURN boolean IS
  gv_other_detail   VARCHAR2(255);
    BEGIN -- assp_get_sua_gs
  -- Get the applicable grading schema for a
  -- nominated student IGS_PS_UNIT attempt
    -- Bug 2064285. The fix returns the default grading schema set at Unit Section level if defined or
    --  returns the default grading schema set at Unit level. -- Kalyan Dande
    DECLARE
      CURSOR c_usec_gs IS
        SELECT   gs.grading_schema_code grading_schema_code,
                 gs.grd_schm_version_number grd_schm_version_number
        FROM     igs_ps_usec_grd_schm_v gs,
                 igs_ps_unit_ofr_opt uoo
        WHERE    uoo.unit_cd = p_unit_cd
        AND      uoo.version_number = p_version_number
        AND      uoo.cal_type = p_cal_type
        AND      uoo.ci_sequence_number = p_ci_sequence_number
        AND      uoo.location_cd = p_location_cd
        AND      uoo.unit_class = p_unit_class
        AND      uoo.uoo_id = gs.uoo_id
        AND      gs.default_flag = 'Y';
      CURSOR c_unit_gs IS
        SELECT   gs.grading_schema_code grading_schema_code,
                 gs.grd_schm_version_number grd_schm_version_number
        FROM     igs_ps_unit_grd_schm_v gs
        WHERE    gs.unit_code = p_unit_cd
        AND      gs.unit_version_number = p_version_number
        AND      gs.default_flag = 'Y';
      v_grading_schema igs_as_grd_schema.grading_schema_cd%TYPE;
      v_gs_version_number igs_as_grd_schema.version_number%TYPE;
      v_ret BOOLEAN  DEFAULT FALSE;
    BEGIN
      --
      -- This cursor used in this code was earlier referring to igs_ps_unit_ofr_opt
      -- which is now changed to igs_ps_usec_grd_schm_v since the concept of having
      -- multiple grading schemas was introduced by some enhancements.
      --
      -- This routine is built to select the grading schema from the link
      -- to the igs_ps_usec_grd_schm_v table, however in future there will
      -- also be links to igs_ps_ofr_pat and igs_en_stdnt_ps_att
      --
      OPEN c_usec_gs;
      FETCH c_usec_gs INTO v_grading_schema, v_gs_version_number;
      IF (c_usec_gs%FOUND) THEN
        p_grading_schema := v_grading_schema;
        p_gs_version_number := v_gs_version_number;
        v_ret := TRUE;
      ELSE
        OPEN c_unit_gs;
        FETCH c_unit_gs INTO v_grading_schema, v_gs_version_number;
        IF (c_unit_gs%FOUND) THEN
          p_grading_schema := v_grading_schema;
          p_gs_version_number := v_gs_version_number;
          v_ret := TRUE;
        END IF;
        CLOSE c_unit_gs;
      END IF;
      CLOSE c_usec_gs;
      RETURN v_ret;
    END;
  EXCEPTION
  WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_003.assp_get_sua_gs');
     -- IGS_GE_MSG_STACK.ADD;
       -- App_Exception.Raise_Exception;
  END assp_get_sua_gs;

 FUNCTION assp_get_sua_outcome(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_outcome_dt OUT NOCOPY DATE ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_mark OUT NOCOPY NUMBER ,
  p_origin_course_cd OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER,
  p_use_released_ind IN VARCHAR2)
RETURN VARCHAR2 IS
    gv_other_detail   VARCHAR2(255);
BEGIN -- assp_get_sua_outcome
  -- This is an enrolments module.
  -- It gets the grade of a student IGS_PS_UNIT attempt within a IGS_PS_COURSE code.
  -- This routine will determine the appropriate grade (and its matching
  -- result type) and return them. If no grade is found NULL will be
  -- returned (and output parameters will be NULL).
  -- IGS_GE_NOTE: This routine handles DUPLICATE IGS_PS_UNIT attempts by searching for
  -- the 'source' IGS_PS_UNIT attempt and retrieving its grade.
  -- Note2: If the p_finalised_ind is set then only finalised grades will
  -- be returned.
DECLARE
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  v_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_finalised_ind     VARCHAR2(1);
  v_sua_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_outcome_dt      IGS_AS_SU_STMPTOUT.outcome_dt%TYPE;
  v_gsg_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gsg_version_number    IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_gsg_grade     IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_gsg_s_result_type   IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_mark        IGS_AS_SU_STMPTOUT.mark%TYPE;
  v_suao_trans_grading_schema_cd
          IGS_AS_SU_STMPTOUT.translated_grading_schema_cd%TYPE;
  v_suao_trans_version_number
          IGS_AS_SU_STMPTOUT.translated_version_number%TYPE;
  v_suao_trans_grade    IGS_AS_SU_STMPTOUT.translated_grade%TYPE;
  v_gsg2_s_result_type    IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
        v_released_date                 IGS_AS_SU_STMPTOUT.release_date%TYPE;
   l_course_cd  igs_en_su_attempt_all.course_cd%TYPE;

   -- smaddali modified cursor for bug#4666657
   CURSOR c_sua (cp_course_cd igs_en_su_attempt_all.course_Cd%TYPE ) IS
    SELECT  sut.transfer_course_cd , sua.unit_attempt_status
    FROM  IGS_PS_STDNT_UNT_TRN  sut,
      IGS_EN_SU_ATTEMPT sua
    WHERE sut.person_id     = p_person_id   AND
      sua.person_id     = sut.person_id AND
      -- anilk, 22-Apr-2003, Bug# 2829262
      sut.uoo_id          = p_uoo_id      AND
      sua.uoo_id              = sut.uoo_id    AND
      sua.course_cd = sut.transfer_course_cd AND
      sut.course_cd = cp_course_cd;
     c_sua_rec c_sua%ROWTYPE;

  CURSOR c_suao_gsg (
    cp_course_cd    IGS_EN_SU_ATTEMPT.course_cd%TYPE,
    cp_finalised_ind  VARCHAR2) IS
    SELECT    suao.outcome_dt,
        suao.mark,
        gsg.grading_schema_cd,
        gsg.version_number,
        gsg.grade,
        gsg.s_result_type,
        suao.translated_grading_schema_cd,
        suao.translated_version_number,
        suao.translated_grade,
        suao.release_date
    FROM    IGS_AS_SU_STMPTOUT  suao,
        IGS_AS_GRD_SCH_GRADE    gsg
    WHERE   suao.person_id      = p_person_id AND
        suao.course_cd      = cp_course_cd AND
                                -- anilk, 22-Apr-2003, Bug# 2829262
        suao.uoo_id                     = p_uoo_id AND
        suao.finalised_outcome_ind  LIKE cp_finalised_ind AND
        suao.grading_schema_cd    = gsg.grading_schema_cd AND
        suao.version_number     = gsg.version_number AND
        suao.grade      = gsg.grade
    ORDER BY  suao.outcome_dt DESC;     -- will put the newest date first.
  CURSOR c_gsg2 IS
    SELECT  gsg2.s_result_type
    FROM  IGS_AS_GRD_SCH_GRADE gsg2
    WHERE gsg2.grading_schema_cd  = v_suao_trans_grading_schema_cd AND
      gsg2.version_number = v_suao_trans_version_number AND
      gsg2.grade    = v_suao_trans_grade;
BEGIN
  p_outcome_dt := NULL;
  p_grading_schema_cd := NULL;
  p_gs_version_number := NULL;
  p_grade := NULL;
  p_mark := NULL;
  p_origin_course_cd := NULL;
  -- Depending on the status of the IGS_PS_UNIT attempt, set the grade search criteria.
  IF (p_unit_attempt_status = cst_duplicate) THEN
    -- Locate the original IGS_PS_UNIT attempt from which the grade was sourced.
    -- This will use IGS_PS_STDNT_UNT_TRN details created as a result of
    -- a IGS_PS_COURSE transfer
    -- smaddali modified logic for bug#4666657, to loop thru chain transfers
    l_course_cd := p_course_cd;
    LOOP
        OPEN c_sua ( l_course_cd) ;
        FETCH c_sua INTO c_sua_rec ;
        IF (c_sua%NOTFOUND) THEN
          CLOSE c_sua;
          RETURN NULL;
        ELSE
           IF c_sua_rec.unit_attempt_status IN (cst_completed,cst_discontin) THEN
             v_course_cd := c_sua_rec.transfer_course_cd;
             EXIT;
           ELSE
             l_course_cd := c_sua_rec.transfer_course_cd;
           END IF;
        END IF;
        CLOSE c_sua;
     END LOOP;

  ELSIF (p_unit_attempt_status = cst_completed OR
      p_unit_attempt_status = cst_discontin OR
      (p_finalised_ind = 'N' and p_unit_attempt_status = cst_enrolled)) THEN
    -- Use the parameter IGS_PS_COURSE code
    v_course_cd := p_course_cd;
  ELSE
    -- Only COMPLETED or DUPLICATED statuses have grades, so return NULL
    RETURN NULL;
  END If;
  -- Search for the latest grade against the student IGS_PS_UNIT attempt
  IF p_finalised_ind = 'Y' THEN
    v_finalised_ind := 'Y';
  ELSE
    v_finalised_ind := '%';
  END IF;
  OPEN c_suao_gsg(
      v_course_cd,
      v_finalised_ind);
  FETCH c_suao_gsg INTO v_outcome_dt,
          v_mark,
          v_gsg_grading_schema_cd,
          v_gsg_version_number,
          v_gsg_grade,
          v_gsg_s_result_type,
          v_suao_trans_grading_schema_cd,
          v_suao_trans_version_number,
          v_suao_trans_grade,
          v_released_date;
  IF (c_suao_gsg%FOUND) THEN
    -- Determine if the translated grade exists and is to be returned.
    IF v_suao_trans_grading_schema_cd IS NULL OR
        v_suao_trans_version_number IS NULL OR
        v_suao_trans_grade IS NULL THEN
      p_outcome_dt := v_outcome_dt;
      p_origin_course_cd := v_course_cd;
      p_grading_schema_cd := v_gsg_grading_schema_cd;
      p_gs_version_number := v_gsg_version_number;
-- IF condition added by LKAKI for bug #3842511
                IF ((p_use_released_ind IS NULL OR p_use_released_ind = 'N') OR
                    (p_use_released_ind = 'Y' AND v_released_date <= SYSDATE)) THEN
          p_grade := v_gsg_grade;
      p_mark := v_mark;
      END IF;

      CLOSE c_suao_gsg;
      RETURN v_gsg_s_result_type;
    ELSE
      OPEN c_gsg2;
      FETCH c_gsg2 INTO v_gsg2_s_result_type;
      IF c_gsg2%NOTFOUND THEN
        p_outcome_dt := NULL;
        p_grading_schema_cd := NULL;
        p_gs_version_number := NULL;
        p_grade := NULL;
        p_mark := NULL;
        p_origin_course_cd := NULL;
        CLOSE c_suao_gsg;
        CLOSE c_gsg2;
        RETURN NULL;
      ELSE
        p_outcome_dt := v_outcome_dt;
        p_grading_schema_cd := v_suao_trans_grading_schema_cd;
        p_gs_version_number := v_suao_trans_version_number;
        p_origin_course_cd := v_course_cd;
--IF condition added by LKAKI for bug #3842511
                           IF ((p_use_released_ind IS NULL OR p_use_released_ind = 'N') OR
                               (p_use_released_ind = 'Y' AND v_released_date <= SYSDATE)) THEN
        p_grade := v_suao_trans_grade;
        p_mark := v_mark;
        END IF;
        CLOSE c_suao_gsg;
        CLOSE c_gsg2;
        RETURN v_gsg2_s_result_type;
      END IF;
    END IF;
  END IF;
  CLOSE c_suao_gsg;
  RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_sua%ISOPEN) THEN
      CLOSE c_sua;
    END IF;
    IF (c_suao_gsg%ISOPEN) THEN
      CLOSE c_suao_gsg;
    END IF;
    IF (c_gsg2%ISOPEN) THEN
      CLOSE c_gsg2;
    END IF;
    RAISE;
END;
END assp_get_sua_outcome;
 FUNCTION assp_get_supp_cal(
  p_exam_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_exam_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_version_number IN IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_cal_type IN IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_unit_attempt_status IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_location_cd IN IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_unit_mode IN IGS_AS_UNIT_CLASS_ALL.unit_mode%TYPE ,
  p_unit_class IN IGS_EN_SU_ATTEMPT_ALL.unit_class%TYPE ,
  p_ass_id IN IGS_AS_UNITASS_ITEM_ALL.ass_id%TYPE )
RETURN VARCHAR2 IS
  gv_other_detail VARCHAR2(1000);
  -- anilk, 22-Apr-2003, Bug# 2829262
  CURSOR cur_uoo_id IS
    SELECT   uoo_id
    FROM     igs_ps_unit_ofr_opt
    WHERE    unit_cd = p_unit_cd
    AND      version_number = p_version_number
    AND      cal_type = p_cal_type
    AND      ci_sequence_number = p_ci_sequence_number
    AND      location_cd = p_location_cd
    AND      unit_class = p_unit_class;

        CURSOR c_ci IS
  SELECT  uai.cal_type
  FROM  IGS_AS_UNITASS_ITEM UAI,
              IGS_AS_ASSESSMNT_ITM AI,
              IGS_AS_ASSESSMNT_TYP ATP,
              IGS_CA_INST CI,
              IGS_CA_TYPE CAT,
              IGS_CA_STAT CS
  WHERE uai.unit_cd = p_unit_cd AND
    uai.version_number = p_version_number AND
    uai.cal_type  = p_cal_type AND
    uai.ci_sequence_number = p_ci_sequence_number AND
    uai.ass_id = p_ass_id AND
    IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(
          p_exam_cal_type,p_exam_ci_sequence_number,
          ci.cal_type, ci.sequence_number,
          'N') = 'Y'
        and UAI.LOGICAL_DELETE_DT IS NULL AND
        AI.ASS_ID = UAI.ASS_ID AND
        AI.EXAM_SCHEDULED_IND = 'Y' AND
        ATP.ASSESSMENT_TYPE = AI.ASSESSMENT_TYPE AND
        ATP.EXAMINABLE_IND = 'Y' AND
        CAT.CAL_TYPE = CI.CAL_TYPE AND
        CAT.S_CAL_CAT = 'EXAM' AND
        CS.CAL_STATUS = CI.CAL_STATUS AND
        CS.S_CAL_STATUS = 'ACTIVE' AND
        (UAI.EXAM_CAL_TYPE IS NULL OR
         CI.CAL_TYPE = UAI.EXAM_CAL_TYPE) AND
        (UAI.EXAM_CI_SEQUENCE_NUMBER IS NULL OR
         CI.SEQUENCE_NUMBER = UAI.EXAM_CI_SEQUENCE_NUMBER) AND
        IGS_EN_GEN_014.ENRS_GET_WITHIN_CI(CI.CAL_TYPE,CI.SEQUENCE_NUMBER,
                UAI.CAL_TYPE, UAI.CI_SEQUENCE_NUMBER, 'N') = 'Y';
   v_unit_cd IGS_CA_INST_REL.sup_cal_type%TYPE;
  CURSOR  c_uv IS
  SELECT  supp_exam_permitted_ind
  FROM  IGS_PS_UNIT_VER
  WHERE unit_cd = p_unit_cd AND
    version_number = p_version_number;
  v_supp_exam_permitted_ind IGS_PS_UNIT_VER.supp_exam_permitted_ind%TYPE;
  rec_uoo_id cur_uoo_id%ROWTYPE;
BEGIN
  -- anilk, 22-Apr-2003, Bug# 2829262
  OPEN cur_uoo_id;
  FETCH cur_uoo_id INTO rec_uoo_id;
  CLOSE cur_uoo_id;
  -- Call routine to determine whether the student is eligible for a supp/special
  -- exam.
   IF ASSP_GET_SUA_EXAM_TP(p_person_id,
        p_course_cd,
        p_unit_cd,
        p_cal_type,
        p_ci_sequence_number,
        p_unit_attempt_status,
                    -- anilk, 22-Apr-2003, Bug# 2829262
        rec_uoo_id.uoo_id) NOT IN ('SUPP','SPECIAL') THEN
    RETURN 'NA';
  END IF;
  -- If supps are not permitted for the IGS_PS_UNIT version then return 'N', indicating
  -- the exam is not permitted.
  OPEN  c_uv;
  FETCH c_uv INTO v_supp_exam_permitted_ind;
  CLOSE c_uv;
  IF v_supp_exam_permitted_ind = 'N' THEN
    Return 'N';
  END IF;
  -- Determine if the exists a relationship between the exam calendar and the
  --  original calendar in which the item was examined.
  OPEN c_ci;
  FETCH c_ci INTO v_unit_cd;
  IF c_ci%NOTFOUND THEN
    CLOSE c_ci;
    RETURN 'N';
  ELSE
    CLOSE c_ci;
    RETURN 'Y';
  END IF;

END;
 FUNCTION assp_get_trn_sua_out(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_final_outcome IN VARCHAR2,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 IS
  gv_other_detail   VARCHAR2(255);
BEGIN -- assp_get_trn_sua_out
  -- Module which is primarily used by the local function inside
  -- assp_get_trn_sca_dtl.
DECLARE
  v_ret_val   VARCHAR2(10);
  v_outcome_dt    DATE;
  v_grading_schema_cd IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gs_version_number IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_grade     IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_mark      IGS_AS_GRD_SCH_GRADE.lower_mark_range%TYPE;
  v_origin_course_cd  IGS_PS_VER.course_cd%TYPE;
BEGIN
  v_ret_val := assp_get_sua_outcome(
      p_person_id,
      p_course_cd,
      p_unit_cd,
      p_cal_type,
      p_ci_sequence_number,
      p_unit_attempt_status,
      p_final_outcome,
      v_outcome_dt,  -- output
      v_grading_schema_cd, -- output
      v_gs_version_number, -- output
      v_grade, -- output
      v_mark, -- output
      v_origin_course_cd,
                        -- anilk, 22-Apr-2003, Bug# 2829262
      p_uoo_id,
      'N');
  RETURN v_ret_val;
END;
EXCEPTION
  WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_GEN_003.assp_get_trn_sua_out');
  IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
END assp_get_trn_sua_out;
FUNCTION assp_get_uai_due_dt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN DATE IS
        gv_other_detail   VARCHAR2(255);
BEGIN -- assp_get_uai_due_dt
        -- This function will return the due date of an assessment item.
        -- It will use a view that will contain the assessment items that
        -- apply to the student IGS_PS_UNIT attempt's IGS_AD_LOCATION, class and mode.
        --
        -- This function is modified by Nishikant - 08JAN2001 - Enh Bug#2162831.
        -- Its modified to return the due date for the assessment item if available at
        -- Unit section level first. If it does not find then it checks at unit offering level.
DECLARE
        v_uai_due_dt      IGS_AS_UNITASS_ITEM.due_dt%TYPE;

-- This cursor selects the due date of the assessment item at unit section level for
-- the student where logical date is null.
        CURSOR  c_sus  IS
        SELECT  usai.due_dt
        FROM    igs_en_su_attempt sua,
                igs_ps_unitass_item usai
        WHERE   sua.person_id = p_person_id AND
                sua.course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
                sua.uoo_id = p_uoo_id  AND
                usai.ass_id = p_ass_id AND
                usai.logical_delete_dt IS NULL AND
                sua.uoo_id = usai.uoo_id AND
                IGS_AS_VAL_UAI.assp_val_sua_ai_acot(usai.ass_id,
                                    sua.person_id,
                                    sua.course_cd) = 'TRUE';

-- This cursor selects the due date of the assessment item at unit section level for
-- the student where the item is logically deleted ,ie.,logical date is not null.
-- In this case it picks up the due date of the assessment item whose logical delete date is
-- maximum.
        CURSOR  c_sus_del IS
        SELECT  usai.due_dt
        FROM    igs_en_su_attempt sua,
                igs_ps_unitass_item usai
        WHERE   sua.person_id = p_person_id AND
                sua.course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
                sua.uoo_id = p_uoo_id  AND
                usai.ass_id = p_ass_id AND
                sua.uoo_id = usai.uoo_id AND
                usai.logical_delete_dt = (
                     SELECT  MAX(usai1.logical_delete_dt)
                     FROM    igs_ps_unitass_item usai1
                     WHERE   usai1.uoo_id = sua.uoo_id and
                             usai1.ass_id = usai.ass_id) AND
                IGS_AS_VAL_UAI.assp_val_sua_ai_acot(usai.ass_id,
                             sua.person_id,
                             sua.course_cd) = 'TRUE';

        CURSOR  c_suv IS
                SELECT  uai.due_dt
                FROM    IGS_EN_SU_ATTEMPT  sua,
                        IGS_AS_UNITASS_ITEM  uai
                WHERE   sua.person_id = p_person_id AND
                        sua.course_cd = p_course_cd AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
                        sua.uoo_id = p_uoo_id  AND
                        uai.ass_id = p_ass_id AND
                        uai.logical_delete_dt IS NULL AND
                        sua.unit_cd = uai.unit_cd AND
                                sua.version_number = uai.version_number AND
                                sua.cal_type = uai.cal_type AND
                                sua.ci_sequence_number = uai.ci_sequence_number AND
                                IGS_AS_VAL_UAI.assp_val_sua_ai_acot(uai.ass_id,
                                                 sua.person_id,
                                                 sua.course_cd) = 'TRUE';

  CURSOR  c_suv_del IS
    SELECT  uai.due_dt
    FROM  IGS_EN_SU_ATTEMPT  sua,
                        IGS_AS_UNITASS_ITEM  uai
    WHERE sua.person_id = p_person_id AND
      sua.course_cd = p_course_cd AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
                        sua.uoo_id = p_uoo_id  AND
      uai.ass_id = p_ass_id AND
      uai.logical_delete_dt = (
        SELECT  MAX(uai1.logical_delete_dt)
        FROM  IGS_EN_SU_ATTEMPT  sua1,
                                        IGS_AS_UNITASS_ITEM  uai1
        WHERE sua1.person_id = sua.person_id AND
          sua1.course_cd = sua.course_cd AND
                                        -- anilk, 22-Apr-2003, Bug# 2829262
                                        sua1.uoo_id = sua.uoo_id  AND
          uai1.ass_id = uai.ass_id AND
          sua.unit_cd = uai.unit_cd AND
          sua.version_number = uai.version_number AND
          sua.cal_type = uai.cal_type AND
          sua.ci_sequence_number = uai.ci_sequence_number AND
          IGS_AS_VAL_UAI.assp_val_sua_ai_acot(uai.ass_id,
                             sua.person_id,
                                   sua.course_cd) = 'TRUE'
          );
BEGIN
-- Here it returns the due date of the assessment item for the student which is not
-- logically deleted.
        OPEN c_sus;
        FETCH c_sus INTO v_uai_due_dt;
        IF c_sus%FOUND THEN
                CLOSE c_sus;
                RETURN v_uai_due_dt;
        END IF;
        CLOSE c_sus;

-- Here it returns the due date of the assessment item for the student which is logically
-- deleted but the most recently deleted one.
        OPEN c_sus_del;
        FETCH c_sus_del INTO v_uai_due_dt;
         IF c_sus_del%FOUND THEN
                CLOSE c_sus_del;
                RETURN v_uai_due_dt;
        END IF;
        CLOSE c_sus_del;

        OPEN c_suv ;
        FETCH c_suv INTO v_uai_due_dt;
        IF c_suv%FOUND THEN
                CLOSE c_suv;
                RETURN v_uai_due_dt;
        END IF;
        CLOSE c_suv;

        OPEN c_suv_del ;
        FETCH c_suv_del INTO v_uai_due_dt;
        IF c_suv_del%FOUND THEN
                CLOSE c_suv_del;
                RETURN v_uai_due_dt;
        END IF;
        CLOSE c_suv_del;

        RETURN NULL;
END;
END assp_get_uai_due_dt;

FUNCTION assp_get_uai_ref(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_id IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 IS
        gv_other_detail   VARCHAR2(255);
BEGIN
        -- assp_get_uai_ref
        -- This function will return the reference of an assessment item.
        -- It will use a view that will contain the assessment items that
        -- apply to the student IGS_PS_UNIT attempt's IGS_AD_LOCATION, class and mode.
        --
        -- This function is modified by Nishikant - 08JAN2001 - Enh Bug#2162831.
        -- Its modified to return the reference of the assessment item if available at
        -- Unit section level first. If it does not find then it checks at unit offering level.
DECLARE
        v_uai_reference       IGS_AS_UNITASS_ITEM.reference%TYPE;

-- This cursor selects the reference of the assessment item at unit section level for
-- the student where logical date is null.
        CURSOR  c_sus IS
        SELECT  usai.reference
        FROM    igs_en_su_attempt sua,
                igs_ps_unitass_item usai
        WHERE   sua.person_id = p_person_id AND
                sua.course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
                sua.uoo_id    = p_uoo_id    AND
                usai.ass_id = p_ass_id AND
                usai.logical_delete_dt IS NULL AND
                sua.uoo_id = usai.uoo_id  AND
                IGS_AS_VAL_UAI.assp_val_sua_ai_acot(usai.ass_id,
                                    sua.person_id,
                                    sua.course_cd) = 'TRUE';

-- This cursor selects the reference of the assessment item at unit section level for
-- the student where the item is logically deleted ,ie.,logical date is not null.
-- In this case it picks up the reference of the assessment item whose logical delete date is
-- maximum.
        CURSOR c_sus_del IS
        SELECT  usai.reference
        FROM    igs_en_su_attempt sua,
                igs_ps_unitass_item usai
        WHERE   sua.person_id = p_person_id AND
                sua.course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
                sua.uoo_id    = p_uoo_id    AND
                usai.ass_id = p_ass_id AND
                sua.uoo_id = usai.uoo_id AND
                usai.logical_delete_dt = (
                SELECT  MAX(usai1.logical_delete_dt)
                FROM    igs_ps_unitass_item usai1
                WHERE   usai1.uoo_id = sua.uoo_id and
                        usai1.ass_id = usai.ass_id) AND
                IGS_AS_VAL_UAI.assp_val_sua_ai_acot(usai.ass_id,
                                    sua.person_id,
                                    sua.course_cd) = 'TRUE';

  CURSOR  c_suv IS
          SELECT  uai.reference
            FROM    IGS_EN_SU_ATTEMPT  sua,
                                IGS_AS_UNITASS_ITEM  uai
      WHERE sua.person_id = p_person_id AND
        sua.course_cd = p_course_cd AND
                                -- anilk, 22-Apr-2003, Bug# 2829262
                                sua.uoo_id    = p_uoo_id    AND
        uai.ass_id = p_ass_id AND
              uai.logical_delete_dt IS NULL AND
        sua.unit_cd = uai.unit_cd AND
              sua.version_number = uai.version_number AND
          sua.cal_type = uai.cal_type AND
        sua.ci_sequence_number = uai.ci_sequence_number AND
        IGS_AS_VAL_UAI.assp_val_sua_ai_acot(uai.ass_id,
          sua.person_id,
          sua.course_cd) = 'TRUE';


  CURSOR  c_suv_del IS
    SELECT  uai.reference
    FROM  IGS_EN_SU_ATTEMPT  sua,
                IGS_AS_UNITASS_ITEM  uai
    WHERE sua.person_id = p_person_id AND
      sua.course_cd = p_course_cd AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
                        sua.uoo_id    = p_uoo_id      AND
      uai.ass_id = p_ass_id AND
      uai.logical_delete_dt = (
        SELECT  MAX(uai1.logical_delete_dt)
        FROM  IGS_EN_SU_ATTEMPT  sua1,
                                        IGS_AS_UNITASS_ITEM  uai1
        WHERE sua1.person_id = sua.person_id AND
          sua1.course_cd = sua.course_cd AND
                                        -- anilk, 22-Apr-2003, Bug# 2829262
                                        sua1.uoo_id    = sua.uoo_id      AND
          uai1.ass_id = uai.ass_id AND
          sua.unit_cd = uai.unit_cd AND
            sua.version_number = uai.version_number AND
              sua.cal_type = uai.cal_type AND
            sua.ci_sequence_number = uai.ci_sequence_number AND
            IGS_AS_VAL_UAI.assp_val_sua_ai_acot(uai.ass_id,
                    sua.person_id,
          sua.course_cd) = 'TRUE'
          );
BEGIN
-- Here it returns the reference of the assessment item for the student which is not
-- logically deleted.
        OPEN c_sus;
        FETCH c_sus INTO v_uai_reference;
        IF c_sus%FOUND THEN
                CLOSE c_sus;
                RETURN v_uai_reference;
        END IF;
        CLOSE c_sus;

-- Here it returns the reference of the assessment item for the student which is logically
-- deleted but the most recently deleted one.
        OPEN c_sus_del;
        FETCH c_sus_del INTO v_uai_reference;
        IF c_sus_del%FOUND THEN
                CLOSE c_sus_del;
                RETURN v_uai_reference;
        END IF;
        CLOSE c_sus_del;

  OPEN c_suv ;
  FETCH c_suv INTO v_uai_reference;
  IF c_suv%FOUND THEN
    CLOSE c_suv;
    RETURN v_uai_reference;
  END IF;
  CLOSE c_suv;
  OPEN c_suv_del ;
  FETCH c_suv_del INTO v_uai_reference;
  IF c_suv_del%FOUND THEN
    CLOSE c_suv_del;
    RETURN v_uai_reference;
  END IF;
  CLOSE c_suv_del;
  RETURN NULL;

END;
END assp_get_uai_ref;
 FUNCTION assp_get_spcl_needs(
  p_person_id IN NUMBER )
RETURN VARCHAR2 IS
  gv_other_detail   VARCHAR2(255);
  v_exists      VARCHAR2(1);
BEGIN -- ASSP_GET_SPCL_NEEDS
  -- Purpose: Get whether IGS_PE_PERSON is within the special needs group.
  -- The type of IGS_PE_PERSON ID group is currently passed in , although this
  -- may be replaced by a system table in the future.
DECLARE
  CURSOR c_pig_pigm IS
    SELECT  'x'
    FROM  IGS_PE_PERSID_GROUP   pig,
      IGS_PE_PRSID_GRP_MEM  pigm
    WHERE pig.group_cd = 'SPCL-NEEDS' AND
      pig.closed_ind  = 'N' AND
      pig.group_id = pigm.group_id AND
      pigm.person_id = p_person_id;
BEGIN
  -- Cursor handling
  OPEN c_pig_pigm;
  FETCH c_pig_pigm INTO v_exists;
  IF c_pig_pigm%FOUND THEN
    CLOSE c_pig_pigm;
    RETURN 'Y';
  ELSE
    CLOSE c_pig_pigm;
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF c_pig_pigm%ISOPEN THEN
      CLOSE c_pig_pigm;
    END IF;
    RAISE;
END;
EXCEPTION
  WHEN OTHERS THEN
         NULL;
END ASSP_GET_SPCL_NEEDS;

  PROCEDURE get_default_grds (
    x_unit_cd                      IN  VARCHAR2,
    x_version_number               IN  NUMBER,
    x_assessment_type              IN  VARCHAR2,
    x_grading_schema_cd      OUT NOCOPY VARCHAR2,
    x_gs_version_number      OUT NOCOPY NUMBER,
    x_description      OUT NOCOPY VARCHAR2,
    x_approved               OUT NOCOPY VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 31-Dec-2001
  ||  Purpose : To get the default Grading Schema for the given
  ||            Unit Code, Version Number and Assessment Type.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_get_def (p_unit_cd         VARCHAR2,
                        p_version_number  NUMBER,
                        p_assessment_type VARCHAR2)IS
      SELECT grading_schema_cd,
             gs_version_number
      FROM   igs_as_appr_grd_sch
      WHERE  unit_cd         = p_unit_cd AND
             version_number  = p_version_number AND
             assessment_type = p_assessment_type AND
             default_ind     =  'Y' AND
             closed_ind      =  'N' ;
    l_cur_get_def        cur_get_def%ROWTYPE;

    CURSOR cur_get_appr (p_unit_cd         VARCHAR2,
                         p_version_number  NUMBER,
                         p_assessment_type VARCHAR2)IS
      SELECT 'X'
      FROM   igs_as_appr_grd_sch
      WHERE  unit_cd         = p_unit_cd AND
             version_number  = p_version_number AND
             assessment_type = p_assessment_type AND
             closed_ind      =  'N';
    l_cur_get_appr        cur_get_appr%ROWTYPE;

    CURSOR cur_desc (p_grading_schema_cd  VARCHAR2,
                     p_gs_version_number  NUMBER )IS
    SELECT description
    FROM igs_as_grd_schema
    WHERE grading_schema_cd = p_grading_schema_cd AND
          version_number    = p_gs_version_number;
    l_cur_desc           cur_desc%ROWTYPE;


  BEGIN
    OPEN cur_get_def(x_unit_cd, x_version_number, x_assessment_type);
    FETCH cur_get_def INTO l_cur_get_def;
    IF cur_get_def%FOUND THEN
      x_grading_schema_cd := l_cur_get_def.grading_schema_cd;
      x_gs_version_number := l_cur_get_def.gs_version_number;
      OPEN cur_desc(x_grading_schema_cd, x_gs_version_number);
      FETCH cur_desc INTO l_cur_desc;
        IF cur_desc%FOUND THEN
          x_description := l_cur_desc.description;
        END IF;
      CLOSE cur_desc;
    END IF;
    CLOSE cur_get_def;

    OPEN cur_get_appr(x_unit_cd, x_version_number, x_assessment_type);
    FETCH cur_get_appr INTO l_cur_get_appr;
      x_approved := 'N';
      IF cur_get_appr%FOUND THEN
        x_approved := 'Y';
      END IF;
    CLOSE cur_get_appr;

  END get_default_grds;

  PROCEDURE assp_get_suaai_gs(
    p_person_id                 IN  NUMBER,
    p_course_cd                 IN  VARCHAR2,
    p_unit_cd                   IN  VARCHAR2,
    p_cal_type                  IN  VARCHAR2,
    p_ci_sequence_number        IN  NUMBER,
    p_ass_id                    IN  VARCHAR2,
    p_grading_schema_cd         OUT NOCOPY VARCHAR2,
    p_gs_version_number         OUT NOCOPY NUMBER,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                    IN  NUMBER ) IS
   /*
  ||  Created By : Nishikant
  ||  Created On : 25jan2002
  ||  Purpose : To get the Grading Schema and Version Number
  ||            for an Assessment Item available at unit
  ||            section level or unit offering level
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c_uoo_id IS
  SELECT uoo_id, version_number
  FROM   igs_en_su_attempt
  WHERE  person_id = p_person_id AND
         course_cd = p_course_cd AND
         -- anilk, 22-Apr-2003, Bug# 2829262
         uoo_id    = p_uoo_id;
  CURSOR c_us_grad_ver( l_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT grading_schema_cd, gs_version_number
  FROM   igs_ps_unitass_item
  WHERE  uoo_id = l_uoo_id AND
         ass_id = p_ass_id AND
         logical_delete_dt IS NULL;
  CURSOR c_u_grad_ver ( l_version_number igs_en_su_attempt.version_number%TYPE) IS
  SELECT grading_schema_cd, gs_version_number
  FROM   igs_as_unitass_item
  WHERE  unit_cd = p_unit_cd AND
         version_number = l_version_number AND
         cal_type = p_cal_type AND
         ci_sequence_number = p_ci_sequence_number AND
         ass_id = p_ass_id AND
         logical_delete_dt IS NULL;
  l_c_uoo_id   igs_en_su_attempt.uoo_id%TYPE;
  l_c_version_number  igs_en_su_attempt.version_number%TYPE;

  BEGIN

  OPEN c_uoo_id;
  FETCH c_uoo_id INTO l_c_uoo_id, l_c_version_number;
  CLOSE c_uoo_id;
  -- Here it checks whether grading schema code and version is avilable
  -- for the Assessment item at Unit Offering level.
  OPEN c_us_grad_ver(l_c_uoo_id);
  FETCH c_us_grad_ver INTO p_grading_schema_cd,p_gs_version_number;
  IF c_us_grad_ver%FOUND THEN
        CLOSE c_us_grad_ver;
        RETURN;
  ELSE
  -- Here it checks whether grading schema code and version is avilable
  -- for the Assessment item at Unit Offering level.
        OPEN c_u_grad_ver(l_c_version_number);
        FETCH c_u_grad_ver INTO p_grading_schema_cd,p_gs_version_number;
        IF c_u_grad_ver%FOUND THEN
           CLOSE c_u_grad_ver;
           RETURN;
        ELSE
           CLOSE c_us_grad_ver;
           CLOSE c_u_grad_ver;
           RETURN;
        END IF;
  END IF;
  END assp_get_suaai_gs;

FUNCTION getStdntCareerPrograms(
   P_PERSON_ID IN IGS_EN_STDNT_PS_ATT.person_id%TYPE ,
   P_PROGRAM_TYPE IN IGS_PS_VER_ALL.course_type%TYPE ) RETURN VARCHAR2 IS

  CURSOR c_stud_careers IS
   SELECT a.Course_cd, b.Title
   FROM   IGS_EN_STDNT_PS_ATT_ALL a, IGS_PS_VER_ALL b
   WHERE  a.course_cd     =  b.course_cd         AND
       a.version_number = b.version_number    AND
       a.course_attempt_status <> 'UNCONFIRM' AND
       b.COURSE_TYPE   =  P_program_type      AND
       a.person_id     =  P_PERSON_ID        /* AND
       trunc(a.CREATION_DATE) <= (
                            SELECT min(trunc(innerpsatt.CREATION_DATE))
                    FROM   IGS_EN_STDNT_PS_ATT_ALL innerpsatt, IGS_PS_VER_ALL innerpsver
                    WHERE  innerpsatt.course_cd     =  innerpsver.course_cd         AND
                     innerpsatt.version_number = innerpsver.version_number    AND
                     innerpsatt.person_id     =   P_PERSON_ID        AND
                             innerpsatt.course_attempt_status <> 'UNCONFIRM' AND
                             innerpsver.COURSE_TYPE   =  P_program_type
                            )  */
    ORDER BY COURSE_TYPE,primary_program_type ;
  v_stud_careers    c_stud_careers%ROWTYPE;
  v_programs VARCHAR2(3000) ;
  v_seperator VARCHAR2(3);
BEGIN
        FOR v_stud_careers IN  c_stud_careers
        LOOP
            IF v_seperator IS NULL THEN
              v_seperator:=' ';
            ELSE
              v_seperator:=', ';
            END IF;
            v_programs := v_programs || v_seperator || trim(v_stud_careers.title) ;
        end loop;
  return(v_programs);
END getStdntCareerPrograms;


FUNCTION getStdntCareerProgsBetween(
   P_PERSON_ID IN igs_en_stdnt_ps_att.person_id%TYPE ,
   P_COURSE_CD IN igs_en_stdnt_ps_att.course_cd%TYPE ,
   P_TERM_START_DATE IN DATE ,
   P_TERM_END_DATE IN DATE ) RETURN VARCHAR2 IS

CURSOR c_stud_careers IS
SELECT a.Course_cd, b.Title
FROM   IGS_EN_STDNT_PS_ATT_ALL a, IGS_PS_VER_ALL b
WHERE  a.course_cd     =  b.course_cd         AND
       a.version_number = b.version_number    AND
       a.course_attempt_status <> 'UNCONFIRM' AND
       a.COMMENCEMENT_DT <=  p_term_end_date   AND
       nvl(a.DISCONTINUED_DT , SYSDATE  + 100000 ) >= p_term_start_date AND
       b.COURSE_TYPE   =  (SELECT b.course_type
        FROM   IGS_EN_STDNT_PS_ATT_ALL innerpsatt, IGS_PS_VER_ALL innerpsver
        WHERE  innerpsatt.course_cd     =  innerpsver.course_cd         AND
         innerpsatt.version_number = innerpsver.version_number    AND
         innerpsatt.person_id     =   P_PERSON_ID        AND
         innerpsatt.course_cd     =   P_COURSE_CD)     AND
      a.person_id     =   P_PERSON_ID
      ORDER BY primary_program_type ;

v_stud_careers    c_stud_careers%rowtype;
v_programs varchar2(3000) ;
v_seperator varchar2(1);
BEGIN
        FOR v_stud_careers IN  c_stud_careers
        LOOP
            IF v_seperator IS NULL THEN
              v_seperator:=' ';
            ELSE
              v_seperator:=', ';
            END IF;
            v_programs := v_programs || v_seperator || v_stud_careers.title ;
        END LOOP;
  RETURN(v_programs);
END getStdntCareerProgsBetween;

FUNCTION getStdntPrograms(
   P_PERSON_ID IGS_EN_STDNT_PS_ATT.PERSON_ID%TYPE ,
   P_PROGRAM_CD IGS_PS_VER_ALL.COURSE_CD%TYPE ) RETURN VARCHAR2 IS

CURSOR c_stud_programs IS
SELECT a.person_id ,a.Course_cd, c.Title
FROM   IGS_PS_STDNT_TRN a, IGS_EN_STDNT_PS_ATT_ALL b , IGS_PS_VER c
WHERE  a.COURSE_CD     =  b.course_cd         AND
       a.person_id = b.person_id              AND
       b.course_cd =  c.course_cd             AND
       b.version_number = c.version_number    AND
       a.TRANSFER_COURSE_CD   =  P_program_cd        AND
       a.person_id     =    P_PERSON_ID;

v_stud_programs    c_stud_programs%rowtype;
v_programs varchar2(3000) ;
BEGIN
        FOR v_stud_programs IN  c_stud_programs
        LOOP
            v_programs :=  v_stud_programs.title ;
        END LOOP;
  return(v_programs);
END getStdntPrograms;



Function getStdntProgsBetween(
        P_PERSON_ID igs_en_stdnt_ps_att.person_id%type ,
        P_program_cd igs_ps_ver_all.course_type%type ,
        p_term_start_date DATE ,
        p_term_end_date DATE ) return VARCHAR2 is

CURSOR c_stud_programs IS
SELECT a.course_cd, b.title
  FROM igs_ps_stdnt_trn a, igs_ps_ver_all b , IGS_EN_STDNT_PS_ATT_ALL c
 WHERE a.TRANSFER_COURSE_CD = c.course_cd
   AND a.person_id = c.person_id
   AND c.course_cd = b.course_cd
   AND c.version_number = b.version_number
   AND a.transfer_dt < p_term_end_date
   AND a.transfer_dt > p_term_start_date
   AND a.course_cd = p_program_cd
   AND a.person_id = p_person_id;

v_stud_programs    c_stud_programs%rowtype;
v_programs varchar2(3000) ;
v_seperator varchar2(1);
begin
        for v_stud_programs in  c_stud_programs
        loop
            IF v_seperator IS NULL THEN
              v_seperator:=' ';
            ELSE
              v_seperator:=',';
            END IF;
            v_programs := v_programs || v_seperator || v_stud_programs.title ;
        end loop;
  return(v_programs);
end getStdntProgsBetween;


/******************************************************
* Procedure to be created
* For selecting the current valid term
* Jitendra Handa
* Term Based Location display for VAH
******************************************************/

PROCEDURE get_current_term (
   p_person_id   IN              NUMBER,
   p_course_cd   IN              VARCHAR2,
   p_cal_type    OUT NOCOPY      VARCHAR2,
   p_seq_num     OUT NOCOPY      NUMBER
)
AS
   CURSOR c_terms
   IS
      SELECT   ci.cal_type, ci.sequence_number, ci.start_dt, ci.end_dt,
               spa.person_id, spa.course_cd
          FROM igs_en_stdnt_ps_att_all spa, igs_ca_inst ci,
               igs_ps_ver_all pv
         WHERE spa.course_attempt_status <> 'UNCONFIRM'
           AND pv.course_cd = spa.course_cd
           AND ci.start_dt <= SYSDATE
           AND spa.person_id = p_person_id
           AND spa.course_cd = p_course_cd
           AND (   EXISTS (
                      SELECT 1
                        FROM igs_en_su_attempt_all sua,
                             igs_ca_teach_to_load_v ttl
                       WHERE sua.person_id = spa.person_id
                         AND sua.course_cd = spa.course_cd
                         AND sua.cal_type = ttl.teach_cal_type
                         AND sua.ci_sequence_number =
                                                  ttl.teach_ci_sequence_number
                         AND ttl.load_cal_type = ci.cal_type
                         AND ttl.load_ci_sequence_number = ci.sequence_number
                         AND sua.unit_attempt_status IN
                                ('ENROLLED',
                                 'COMPLETED',
                                 'DISCONTIN',
                                 'DUPLICATE'
                                ))
                OR EXISTS (
                      SELECT 1
                        FROM igs_av_stnd_unit asu
                       WHERE spa.person_id = asu.person_id
                         AND spa.course_cd = asu.as_course_cd
                         AND ci.cal_type = asu.cal_type
                         AND ci.sequence_number = asu.ci_sequence_number
                         AND asu.s_adv_stnd_granting_status = 'GRANTED')
                OR EXISTS (
                      SELECT 1
                        FROM igs_av_stnd_unit_lvl asul
                       WHERE spa.person_id = asul.person_id
                         AND spa.course_cd = asul.as_course_cd
                         AND ci.cal_type = asul.cal_type
                         AND ci.sequence_number = asul.ci_sequence_number
                         AND asul.s_adv_stnd_granting_status = 'GRANTED')
               )
      ORDER BY ci.start_dt DESC;

   v_terms   c_terms%ROWTYPE;
BEGIN
   OPEN c_terms;
   FETCH c_terms INTO v_terms;
   p_cal_type := v_terms.cal_type;
   p_seq_num := v_terms.sequence_number;
   CLOSE c_terms;
END get_current_term;

FUNCTION get_spat_att_type_desc (
            p_person_id IN NUMBER,
            p_program_cd IN VARCHAR2
      ) RETURN VARCHAR2 AS

v_term_cal_type IGS_EN_SU_ATTEMPT.cal_type%TYPE;
v_term_sequence_NUMBER IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
BEGIN
get_current_term(p_person_id,
     p_program_cd,
     v_term_cal_type,
    v_term_sequence_NUMBER);

return igs_en_spa_terms_api.get_spat_att_type_desc(p_person_id,p_program_cd,v_term_cal_type,v_term_sequence_NUMBER);
END get_spat_att_type_desc;

FUNCTION get_spat_att_mode_desc(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2
  ) RETURN VARCHAR2 AS

v_term_cal_type IGS_EN_SU_ATTEMPT.cal_type%TYPE;
v_term_sequence_NUMBER IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
BEGIN

get_current_term(p_person_id,
     p_program_cd,
     v_term_cal_type,
     v_term_sequence_NUMBER);

return igs_en_spa_terms_api.get_spat_att_mode_desc(p_person_id,p_program_cd,v_term_cal_type,v_term_sequence_NUMBER);
END get_spat_att_mode_desc;


FUNCTION get_spat_location_desc(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2
  ) RETURN VARCHAR2 AS
v_term_cal_type IGS_EN_SU_ATTEMPT.cal_type%TYPE;
v_term_sequence_NUMBER IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
BEGIN

get_current_term(p_person_id,
     p_program_cd,
     v_term_cal_type,
    v_term_sequence_NUMBER);

return igs_en_spa_terms_api.get_spat_location_desc(p_person_id,p_program_cd,v_term_cal_type,v_term_sequence_NUMBER);
END get_spat_location_desc;
FUNCTION assp_get_sua_rel_grade(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN  NUMBER )
RETURN VARCHAR2 IS
    gv_other_detail   VARCHAR2(255);
BEGIN -- assp_get_sua_grade
  -- This is an enrolments module.
  -- It gets the grade of a student IGS_PS_UNIT attempt within a IGS_PS_COURSE code.
  -- This routine will determine the appropriate grade (and its matching
  -- result type) and return them. If no grade is found NULL will be
  -- returned (and output parameters will be NULL).
  -- IGS_GE_NOTE: This routine handles DUPLICATE IGS_PS_UNIT attempts by searching for
  -- the 'source' IGS_PS_UNIT attempt and retrieving its grade.
  -- Note2: If the p_finalised_ind is set then only finalised grades will
  -- be returned.
DECLARE
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  v_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_finalised_ind     VARCHAR2(1);
  v_sua_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_gsg_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gsg_version_number    IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_gsg_grade     IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_gsg_s_result_type   IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_suao_trans_grading_schema_cd
          IGS_AS_SU_STMPTOUT.translated_grading_schema_cd%TYPE;
  v_suao_trans_version_number
          IGS_AS_SU_STMPTOUT.translated_version_number%TYPE;
  v_suao_trans_grade    IGS_AS_SU_STMPTOUT.translated_grade%TYPE;
  v_gsg2_s_result_type    IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  CURSOR c_sua (
    cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
    cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
    cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
    cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
    cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) IS
    SELECT  sut.transfer_course_cd
    FROM  IGS_PS_STDNT_UNT_TRN  sut,
      IGS_EN_SU_ATTEMPT sua
    WHERE sut.person_id     = cp_person_id AND
      sua.person_id     = sut.person_id AND
      sut.uoo_id    = cp_uoo_id AND
      sua.uoo_id    = sut.uoo_id AND
      sua.course_cd = sut.transfer_course_cd AND
      sua.unit_attempt_status IN (cst_completed, cst_discontin)
    ORDER BY sua.unit_attempt_status;
  CURSOR c_suao_gsg (
    cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
    c_v_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE,
    cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
    cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
    cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
    c_v_finalised_ind VARCHAR2,
    cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) IS
    SELECT    gsg.grading_schema_cd,
        gsg.version_number,
        gsg.grade,
        gsg.s_result_type,
        suao.translated_grading_schema_cd,
        suao.translated_version_number,
        suao.translated_grade
    FROM    IGS_AS_SU_STMPTOUT  suao,
        IGS_AS_GRD_SCH_GRADE  gsg
    WHERE suao.person_id      = cp_person_id AND
        suao.course_cd      = c_v_course_cd AND
        suao.uoo_id             = cp_uoo_id AND
        suao.finalised_outcome_ind
                LIKE DECODE(c_v_finalised_ind, 'Y', 'Y', '%') AND
        suao.grading_schema_cd    = gsg.grading_schema_cd AND
        suao.version_number     = gsg.version_number AND
        suao.grade      = gsg.grade AND
                nvl(suao.RELEASE_DATE ,sysdate+10) <=sysdate
    ORDER BY  outcome_dt DESC;    -- will put the newest date first.
  CURSOR c_gsg2 IS
    SELECT  gsg2.s_result_type
    FROM  IGS_AS_GRD_SCH_GRADE gsg2
    WHERE gsg2.grading_schema_cd  = v_suao_trans_grading_schema_cd AND
      gsg2.version_number = v_suao_trans_version_number AND
      gsg2.grade    = v_suao_trans_grade;
BEGIN
  p_grading_schema_cd := NULL;
  p_gs_version_number := NULL;
  p_grade := NULL;
  -- Depending on the status of the IGS_PS_UNIT attempt, set the grade search criteria.
  IF (p_unit_attempt_status = cst_duplicate) THEN
    -- Locate the original IGS_PS_UNIT attempt from which the grade was sourced.
    -- This will use IGS_PS_STDNT_UNT_TRN details created as a result of
    -- a IGS_PS_COURSE transfer
    OPEN  c_sua(
        p_person_id,
        p_unit_cd,
        p_cal_type,
        p_ci_sequence_number,
                                -- anilk, 22-Apr-2003, Bug# 2829262
        p_uoo_id );
    FETCH c_sua INTO  v_sua_course_cd;
    IF (c_sua%NOTFOUND) THEN
      CLOSE c_sua;
      RETURN NULL;
    ELSE
      v_course_cd := v_sua_course_cd;
    END IF;
    CLOSE c_sua;
  ELSIF (p_unit_attempt_status = cst_completed OR
      p_unit_attempt_status = cst_discontin OR
      (p_finalised_ind = 'N' and p_unit_attempt_status = cst_enrolled)) THEN
    -- Use the parameter IGS_PS_COURSE code
    v_course_cd := p_course_cd;
  ELSE
    -- Only COMPLETED or DUPLICATED statuses have grades, so return NULL
    RETURN NULL;
  END IF;
  -- Search for the latest grade against the student IGS_PS_UNIT attempt
  OPEN  c_suao_gsg(
      p_person_id,
      v_course_cd,
      p_unit_cd,
      p_cal_type,
      p_ci_sequence_number,
      p_finalised_ind,
                        -- anilk, 22-Apr-2003, Bug# 2829262
                        p_uoo_id );
  FETCH c_suao_gsg  INTO  v_gsg_grading_schema_cd,
          v_gsg_version_number,
          v_gsg_grade,
          v_gsg_s_result_type,
          v_suao_trans_grading_schema_cd,
          v_suao_trans_version_number,
          v_suao_trans_grade;
  IF (c_suao_gsg%NOTFOUND) THEN
    CLOSE c_suao_gsg;
    RETURN NULL;
  ELSE
    -- Determine if the translated grade exists and is to be returned.
    IF v_suao_trans_grading_schema_cd IS NULL OR
        v_suao_trans_version_number IS NULL OR
        v_suao_trans_grade IS NULL THEN
      p_grading_schema_cd := v_gsg_grading_schema_cd;
      p_gs_version_number := v_gsg_version_number;
      p_grade := v_gsg_grade;
      CLOSE c_suao_gsg;
      RETURN  v_gsg_s_result_type;
    ELSE
      OPEN c_gsg2;
      FETCH c_gsg2 INTO v_gsg2_s_result_type;
      IF c_gsg2%NOTFOUND THEN
        p_grading_schema_cd := NULL;
        p_gs_version_number := NULL;
        p_grade := NULL;
        CLOSE c_suao_gsg;
        CLOSE c_gsg2;
        RETURN NULL;
      ELSE
        p_grading_schema_cd := v_suao_trans_grading_schema_cd;
        p_gs_version_number := v_suao_trans_version_number;
        p_grade := v_suao_trans_grade;
        CLOSE c_suao_gsg;
        CLOSE c_gsg2;
        RETURN v_gsg2_s_result_type;
      END IF;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_sua%ISOPEN) THEN
      CLOSE c_sua;
    END IF;
    IF (c_suao_gsg%ISOPEN) THEN
      CLOSE c_suao_gsg;
    END IF;
    IF (c_gsg2%ISOPEN) THEN
      CLOSE c_gsg2;
    END IF;
    RAISE;
END;
END assp_get_sua_rel_grade;


FUNCTION assp_get_sua_rel_marks(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_finalised_ind IN VARCHAR2 ,
  p_grading_schema_cd OUT NOCOPY VARCHAR2 ,
  p_gs_version_number OUT NOCOPY NUMBER ,
  p_grade OUT NOCOPY VARCHAR2 ,
  p_uoo_id IN  NUMBER )
RETURN NUMBER IS
    gv_other_detail   VARCHAR2(255);
BEGIN -- assp_get_sua_grade
  -- This is an enrolments module.
  -- It gets the grade of a student IGS_PS_UNIT attempt within a IGS_PS_COURSE code.
  -- This routine will determine the appropriate grade (and its matching
  -- result type) and return them. If no grade is found NULL will be
  -- returned (and output parameters will be NULL).
  -- IGS_GE_NOTE: This routine handles DUPLICATE IGS_PS_UNIT attempts by searching for
  -- the 'source' IGS_PS_UNIT attempt and retrieving its grade.
  -- Note2: If the p_finalised_ind is set then only finalised grades will
  -- be returned.
DECLARE
  cst_completed CONSTANT  VARCHAR2(10) := 'COMPLETED';
  cst_discontin CONSTANT  VARCHAR2(10) := 'DISCONTIN';
  cst_duplicate CONSTANT  VARCHAR2(10) := 'DUPLICATE';
  cst_enrolled  CONSTANT  VARCHAR2(10) := 'ENROLLED';
  v_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_finalised_ind     VARCHAR2(1);
  v_sua_course_cd     IGS_EN_SU_ATTEMPT.course_cd%TYPE;
  v_gsg_grading_schema_cd   IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
  v_gsg_version_number    IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
  v_gsg_grade     IGS_AS_GRD_SCH_GRADE.grade%TYPE;
  v_gsg_s_result_type   IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_suao_trans_grading_schema_cd
          IGS_AS_SU_STMPTOUT.translated_grading_schema_cd%TYPE;
  v_suao_trans_version_number
          IGS_AS_SU_STMPTOUT.translated_version_number%TYPE;
  v_suao_trans_grade    IGS_AS_SU_STMPTOUT.translated_grade%TYPE;
  v_gsg2_s_result_type    IGS_AS_GRD_SCH_GRADE.s_result_type%TYPE;
  v_marks       IGS_AS_SU_STMPTOUT.mark%TYPE;
  CURSOR c_sua (
    cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
    cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
    cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
    cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
    cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) IS
    SELECT  sut.transfer_course_cd
    FROM  IGS_PS_STDNT_UNT_TRN  sut,
      IGS_EN_SU_ATTEMPT sua
    WHERE sut.person_id     = cp_person_id AND
      sua.person_id     = sut.person_id AND
      sut.uoo_id    = cp_uoo_id AND
      sua.uoo_id    = sut.uoo_id AND
      sua.course_cd = sut.transfer_course_cd AND
      sua.unit_attempt_status IN (cst_completed, cst_discontin)
    ORDER BY sua.unit_attempt_status;
  CURSOR c_suao_gsg (
    cp_person_id    IGS_EN_SU_ATTEMPT.person_id%TYPE,
    c_v_course_cd   IGS_EN_SU_ATTEMPT.course_cd%TYPE,
    cp_unit_cd    IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
    cp_cal_type   IGS_EN_SU_ATTEMPT.cal_type%TYPE,
    cp_ci_sequence_number IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
    c_v_finalised_ind VARCHAR2,
    cp_uoo_id               IGS_EN_SU_ATTEMPT.uoo_id%TYPE
    ) IS
    SELECT    gsg.grading_schema_cd,
        gsg.version_number,
        gsg.grade,
        gsg.s_result_type,
        suao.translated_grading_schema_cd,
        suao.translated_version_number,
        suao.translated_grade ,
        suao.mark
    FROM    IGS_AS_SU_STMPTOUT  suao,
        IGS_AS_GRD_SCH_GRADE  gsg
    WHERE suao.person_id      = cp_person_id AND
        suao.course_cd      = c_v_course_cd AND
        suao.uoo_id             = cp_uoo_id AND
        suao.finalised_outcome_ind
                LIKE DECODE(c_v_finalised_ind, 'Y', 'Y', '%') AND
        suao.grading_schema_cd    = gsg.grading_schema_cd AND
        suao.version_number     = gsg.version_number AND
        suao.grade      = gsg.grade AND
                nvl(suao.RELEASE_DATE ,sysdate+10) <=sysdate
    ORDER BY  outcome_dt DESC;    -- will put the newest date first.
  CURSOR c_gsg2 IS
    SELECT  gsg2.s_result_type
    FROM  IGS_AS_GRD_SCH_GRADE gsg2
    WHERE gsg2.grading_schema_cd  = v_suao_trans_grading_schema_cd AND
      gsg2.version_number = v_suao_trans_version_number AND
      gsg2.grade    = v_suao_trans_grade;
BEGIN
  p_grading_schema_cd := NULL;
  p_gs_version_number := NULL;
  p_grade := NULL;
  -- Depending on the status of the IGS_PS_UNIT attempt, set the grade search criteria.
  IF (p_unit_attempt_status = cst_duplicate) THEN
    -- Locate the original IGS_PS_UNIT attempt from which the grade was sourced.
    -- This will use IGS_PS_STDNT_UNT_TRN details created as a result of
    -- a IGS_PS_COURSE transfer
    OPEN  c_sua(
        p_person_id,
        p_unit_cd,
        p_cal_type,
        p_ci_sequence_number,
        p_uoo_id );
    FETCH c_sua INTO  v_sua_course_cd;
    IF (c_sua%NOTFOUND) THEN
      CLOSE c_sua;
      RETURN NULL;
    ELSE
      v_course_cd := v_sua_course_cd;
    END IF;
    CLOSE c_sua;
  ELSIF (p_unit_attempt_status = cst_completed OR
      p_unit_attempt_status = cst_discontin OR
      (p_finalised_ind = 'N' and p_unit_attempt_status = cst_enrolled)) THEN
    -- Use the parameter IGS_PS_COURSE code
    v_course_cd := p_course_cd;
  END IF;
  -- Search for the latest grade against the student IGS_PS_UNIT attempt
  OPEN  c_suao_gsg(
      p_person_id,
      v_course_cd,
      p_unit_cd,
      p_cal_type,
      p_ci_sequence_number,
      p_finalised_ind,
                        p_uoo_id );
  FETCH c_suao_gsg  INTO  v_gsg_grading_schema_cd,
          v_gsg_version_number,
          v_gsg_grade,
          v_gsg_s_result_type,
          v_suao_trans_grading_schema_cd,
          v_suao_trans_version_number,
          v_suao_trans_grade,
          v_marks;
  IF (c_suao_gsg%NOTFOUND) THEN
    CLOSE c_suao_gsg;
    RETURN NULL;
  ELSE
    RETURN v_marks;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_sua%ISOPEN) THEN
      CLOSE c_sua;
    END IF;
    IF (c_suao_gsg%ISOPEN) THEN
      CLOSE c_suao_gsg;
    END IF;
    IF (c_gsg2%ISOPEN) THEN
      CLOSE c_gsg2;
    END IF;
    RAISE;
END;
END assp_get_sua_rel_marks;

 FUNCTION assp_get_ai_ref(
            usaii in igs_ps_unitass_item.unit_section_ass_item_id%type,
            uaii in igs_as_unitass_item.unit_ass_item_id%type
 )
 RETURN VARCHAR2 IS
 BEGIN
     DECLARE
      CURSOR c_ref_ps (usaid igs_ps_unitass_item.unit_section_ass_item_id%TYPE)IS
      SELECT reference, release_date
      FROM   igs_ps_unitass_item
      WHERE  unit_section_ass_item_id = usaid;
      CURSOR c_ref_as (uaid igs_as_unitass_item.unit_ass_item_id%TYPE)IS
      SELECT reference, release_date
      FROM   igs_as_unitass_item
      WHERE  unit_ass_item_id = uaid;
      v_ref c_ref_as%ROWTYPE;

  BEGIN
    IF usaii IS NOT NULL  THEN
            OPEN c_ref_ps(usaii);
            FETCH c_ref_ps INTO v_ref;
            CLOSE c_ref_ps;
    ELSIF uaii IS NOT NULL THEN
            OPEN c_ref_as(uaii);
            FETCH c_ref_as INTO v_ref;
            CLOSE c_ref_as;
    END IF;
    RETURN v_ref.reference;
  END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END assp_get_ai_ref;

   FUNCTION assp_get_ai_reldate(
            usaii in igs_ps_unitass_item.unit_section_ass_item_id%type,
            uaii in igs_as_unitass_item.unit_ass_item_id%type
 )
 RETURN DATE IS
 BEGIN
     DECLARE
      CURSOR c_ref_ps (usaid igs_ps_unitass_item.unit_section_ass_item_id%TYPE)IS
      SELECT reference, release_date
      FROM   igs_ps_unitass_item
      WHERE  unit_section_ass_item_id = usaid;
      CURSOR c_ref_as (uaid igs_as_unitass_item.unit_ass_item_id%TYPE)IS
      SELECT reference, release_date
      FROM   igs_as_unitass_item
      WHERE  unit_ass_item_id = uaid;
      v_ref c_ref_as%ROWTYPE;

  BEGIN
    IF usaii IS NOT NULL  THEN
            OPEN c_ref_ps(usaii);
            FETCH c_ref_ps INTO v_ref;
            CLOSE c_ref_ps;
    ELSIF uaii IS NOT NULL THEN
            OPEN c_ref_as(uaii);
            FETCH c_ref_as INTO v_ref;
            CLOSE c_ref_as;
    END IF;
    RETURN v_ref.release_date;
  END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END assp_get_ai_reldate;

END IGS_AS_GEN_003 ;

/
