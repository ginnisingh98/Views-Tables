--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_SUAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_SUAO" AS
/* $Header: IGSAS32B.pls 115.10 2004/02/05 07:41:07 kdande ship $ */
  -- To validate update of IGS_AS_SU_STMPTOUT record
  FUNCTION ASSP_VAL_SUAO_UPD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_new_finalised_outcome_ind IN VARCHAR2 ,
  p_new_s_grade_creation_mthd_tp IN VARCHAR2 ,
  p_new_mark IN NUMBER ,
  p_new_grading_schema_cd IN VARCHAR2 ,
  p_new_version_number IN NUMBER ,
  p_new_grade IN VARCHAR2 ,
  p_old_finalised_outcome_ind IN VARCHAR2 ,
  p_old_s_grade_creation_mthd_tp IN VARCHAR2 ,
  p_old_mark IN NUMBER ,
  p_old_grading_schema_cd IN VARCHAR2 ,
  p_old_version_number IN NUMBER ,
  p_old_grade IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN boolean IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_val_suao_upd
    -- Validate the update of a IGS_AS_SU_STMPTOUT record. Routine checks:
    -- ? Cannot update a finalised outcome where
    --  s_grade_creation_method_type <> ?DISCONTIN?
    -- ? Cannot update s_grade_creation_method_type
    -- ? Cannot unfinalise an outcome where
    --  s_grade_creation_method_type = ?DISCONTIN?
    -- IGS_GE_NOTE: This routine is designed to be used through both forms and a database
    -- trigger.  This is achieved by passing the ?old? values as optional
    -- parameters.  The database trigger can pass the :old values, whereas forms
    -- can pass NULL,  in which case the routine will load the values from the
    -- database (since mutation is not a problem through forms).
  DECLARE
    cst_discontin   CONSTANT VARCHAR2(10) := 'DISCONTIN';
    cst_yes     CONSTANT VARCHAR2(1) := 'Y';
    cst_no      CONSTANT VARCHAR2(1) := 'N';
    cst_x     CONSTANT VARCHAR2(1) := 'x';
    v_finalised_outcome_ind   IGS_AS_SU_STMPTOUT.finalised_outcome_ind%TYPE;
    v_s_grade_creation_mthd_tp
        IGS_AS_SU_STMPTOUT.s_grade_creation_method_type%TYPE;
    v_mark        IGS_AS_SU_STMPTOUT.mark%TYPE;
    v_grading_schema_cd     IGS_AS_SU_STMPTOUT.grading_schema_cd%TYPE;
    v_version_number      IGS_AS_SU_STMPTOUT.version_number%TYPE;
    v_grade       IGS_AS_SU_STMPTOUT.grade%TYPE;
    CURSOR c_suao (
        cp_person_id    IGS_AS_SU_STMPTOUT.person_id%TYPE,
        cp_course_cd    IGS_AS_SU_STMPTOUT.course_cd%TYPE,
        cp_unit_cd              IGS_AS_SU_STMPTOUT.unit_cd%TYPE,
        cp_cal_type   IGS_AS_SU_STMPTOUT.cal_type%TYPE,
        cp_ci_sequence_number IGS_AS_SU_STMPTOUT.ci_sequence_number%TYPE,
        cp_outcome_dt   IGS_AS_SU_STMPTOUT.outcome_dt%TYPE,
      cp_uoo_id               IGS_AS_SU_STMPTOUT.uoo_id%TYPE) IS
      SELECT  mark,
        grading_schema_cd,
        version_number,
        grade,
        finalised_outcome_ind,
        s_grade_creation_method_type
      FROM  IGS_AS_SU_STMPTOUT
      WHERE person_id     = cp_person_id AND
        course_cd     = cp_course_cd AND
                        -- anilk, 22-Apr-2003, Bug# 2829262
        uoo_id    = cp_uoo_id AND
        outcome_dt  = cp_outcome_dt;
    v_suao_rec      c_suao%ROWTYPE;
  BEGIN
    -- Set the default message number
    p_message_name := NULL;
    -- initialise the variables to the old values
    v_finalised_outcome_ind := p_old_finalised_outcome_ind ;
    v_s_grade_creation_mthd_tp := p_old_s_grade_creation_mthd_tp ;
    v_mark := p_old_mark ;
    v_grading_schema_cd := p_old_grading_schema_cd ;
    v_version_number := p_old_version_number ;
    v_grade := p_old_grade ;
    -- If the ?old? parameters are not set then load from the database
    -- (assuming commit has not occurred).
    IF p_old_finalised_outcome_ind IS NULL OR
        p_old_s_grade_creation_mthd_tp IS NULL THEN
      OPEN c_suao(
          p_person_id,
          p_course_cd,
          p_unit_cd,
          p_cal_type,
          p_ci_sequence_number,
          p_outcome_dt,
                                -- anilk, 22-Apr-2003, Bug# 2829262
        p_uoo_id
        );
      FETCH c_suao INTO v_suao_rec;
      IF c_suao%NOTFOUND THEN
        CLOSE c_suao;
        -- Internal error, will come out NOCOPY in the db trigger
        RETURN TRUE;
      END IF;
      CLOSE c_suao;
      v_finalised_outcome_ind := v_suao_rec.finalised_outcome_ind ;
      v_s_grade_creation_mthd_tp := v_suao_rec.s_grade_creation_method_type ;
      v_mark := v_suao_rec.mark ;
      v_grading_schema_cd := v_suao_rec.grading_schema_cd ;
      v_version_number := v_suao_rec.version_number ;
      v_grade := v_suao_rec.grade ;
    END IF;
    IF NVL(v_s_grade_creation_mthd_tp, cst_x) <>
        NVL(p_new_s_grade_creation_mthd_tp, cst_x) THEN
      p_message_name := 'IGS_AS_CANNOT_CHG_GRD_CREATE';
      RETURN FALSE;
    END IF;
    IF NVL(v_s_grade_creation_mthd_tp, cst_x) = cst_discontin AND
        NVL(p_new_finalised_outcome_ind, cst_x) = cst_no THEN
      p_message_name := 'IGS_AS_CANNOT_UNFINALISE_SYS';
      RETURN FALSE;
    END IF;
    IF NVL(v_finalised_outcome_ind, cst_x) = cst_yes AND
        NVL(v_s_grade_creation_mthd_tp, cst_x) <> cst_discontin THEN
      IF NVL(v_mark, 0) <> NVL(p_new_mark, 0) OR
          NVL(v_grading_schema_cd, cst_x) <> NVL(p_new_grading_schema_cd, cst_x)  OR
          NVL(v_version_number, 0) <> NVL(p_new_version_number, 0)  OR
          NVL(v_grade, cst_x) <> NVL(p_new_grade, cst_x) THEN
        p_message_name := 'IGS_AS_CANNOT_ALTER_MARK_GRD';
        RETURN FALSE;
      END IF;
    END IF;
    -- Return the default value
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAO.ASSP_VAL_SUAO_UPD');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;


  END assp_val_suao_upd;
  --
  -- Validate the insert of a IGS_AS_SU_STMPTOUT record
  FUNCTION ASSP_VAL_SUAO_INS(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN boolean IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_val_suao_ins
    -- Validate the insert of a IGS_AS_SU_STMPTOUT record.
  DECLARE
    cst_unconfirm   CONSTANT VARCHAR2(255) := 'UNCOMFIRM';
    cst_enrolled    CONSTANT VARCHAR2(255) := 'ENROLLED';
    cst_complete    CONSTANT VARCHAR2(255) := 'COMPLETED';
    cst_discontin   CONSTANT VARCHAR2(255) := 'DISCONTIN';
    v_unit_attempt_status   IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
    v_check   CHAR;
    CURSOR  c_uas IS
      SELECT  unit_attempt_status
      FROM  IGS_EN_SU_ATTEMPT
      WHERE person_id = p_person_id AND
        course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
        uoo_id    = p_uoo_id;
    CURSOR c_chk_suao IS
      SELECT  'x'
      FROM  IGS_AS_SU_STMPTOUT
      WHERE person_id = p_person_id and
        course_cd = p_course_cd and
                -- anilk, 22-Apr-2003, Bug# 2829262
        uoo_id          = p_uoo_id    and
        outcome_dt  <> p_outcome_dt and
        s_grade_creation_method_type = cst_discontin;
  BEGIN
    p_message_name := NULL;
    -- 1. Validate the IGS_PS_UNIT attempt status
    IF (p_unit_attempt_status IS NULL) THEN
      -- Load IGS_PS_UNIT attempt status
      OPEN c_uas;
      FETCH c_uas INTO v_unit_attempt_status;
      IF (c_uas%NOTFOUND) THEN
        v_unit_attempt_status := cst_unconfirm;
      ELSE
        -- v_unit_attempt_status := selected value;
        NULL;
      END IF;
      CLOSE c_uas;
    ELSE
      v_unit_attempt_status := p_unit_attempt_status;
    END IF;
    IF (v_unit_attempt_status NOT IN (  cst_enrolled,
              cst_complete,
              cst_discontin)) THEN
      p_message_name  := 'IGS_AS_ONLY_ADD_AGAINST_ENR';
      RETURN FALSE;
    END IF;
    -- 2. Validate the grade creation method type against the IGS_PS_UNIT attempt status
    IF (  p_s_grade_creation_method_type <> cst_discontin AND
      v_unit_attempt_status = cst_discontin) THEN
      p_message_name := 'IGS_AS_GRD_ONLY_ADD_DISCONT';
      RETURN FALSE;
    END IF;
    IF (  p_s_grade_creation_method_type = cst_discontin AND
      v_unit_attempt_status <> cst_discontin) THEN
      p_message_name := 'IGS_AS_CANNOT_ADD_DISCONT_GRD';
      RETURN FALSE;
    END IF;
    -- 3. if not a discontinuation grade, then ensure than no discontinuation
    --      grade exists.
    IF (p_s_grade_creation_method_type <> cst_discontin) THEN
      OPEN c_chk_suao;
      FETCH c_chk_suao INTO v_check;
      IF (c_chk_suao%FOUND) THEN
        CLOSE c_chk_suao;
        p_message_name := 'IGS_AS_CANNOT_ADD_NONDISCONT';
        RETURN FALSE;
      END IF;
      CLOSE c_chk_suao;
    END IF;
    -- 4. Validate for closed grade creation method type
    IF (IGS_AS_VAL_SUAO.assp_val_sgcmt_clsd(
            p_s_grade_creation_method_type,
            p_message_name ) = FALSE) THEN
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END;
  EXCEPTION
    WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAO.ASSP_VAL_SUAO_INS');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;


  END assp_val_suao_ins;
  --
  -- Validate IGS_AS_SU_STMPTOUT outcome_dt field
  FUNCTION ASSP_VAL_SUAO_DT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd  VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_outcome_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
  RETURN boolean IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_val_suao_dt
    -- Validate the outcome date of a IGS_AS_SU_STMPTOUT record being
    -- inserted
  DECLARE
    v_check   CHAR;
    v_ret_val BOOLEAN DEFAULT TRUE;
    CURSOR c_suao IS
      SELECT 'x'
      FROM  IGS_AS_SU_STMPTOUT
      WHERE person_id = p_person_id AND
        course_cd = p_course_cd AND
                -- anilk, 22-Apr-2003, Bug# 2829262
        uoo_id          = p_uoo_id    AND
        outcome_dt  > p_outcome_dt;
  BEGIN
    p_message_name  := NULL;
    -- Date cannot be prior to any existing outcome record for the IGS_PS_UNIT attempt
    OPEN c_suao;
    FETCH c_suao INTO v_check;
    IF (c_suao%FOUND) THEN
      v_ret_val := FALSE;
      p_message_name := 'IGS_AS_OUTCOME_DT_NOT_PRIOR';
    END IF;
    CLOSE c_suao;
    RETURN v_ret_val;
  END;
  EXCEPTION
    WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAO.ASSP_VAL_SUAO_DT');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;


  END assp_val_suao_dt;
  --
  -- Validate s_grade_creation_method_type closed indicator
  FUNCTION ASSP_VAL_SGCMT_CLSD(
  p_s_grade_creation_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- assp_val_sgcmt_clsd
    -- Validate the System Grade Creation Method Type closed indicator.
  DECLARE
    v_closed_ind  IGS_LOOKUPS_VIEW.closed_ind%TYPE;
    v_ret_val BOOLEAN DEFAULT TRUE;
    CURSOR  c_sgcmt IS
      SELECT  closed_ind
      FROM  IGS_LOOKUPS_VIEW
      WHERE LOOKUP_TYPE  = p_s_grade_creation_method_type;
  BEGIN
    p_message_name  := NULL;
    OPEN c_sgcmt;
    FETCH c_sgcmt INTO v_closed_ind;
    IF (c_sgcmt%FOUND) THEN
      IF (v_closed_ind = 'Y') THEN
        p_message_name  := 'IGS_AS_CANNOT_ADD_OUTCOME';
        v_ret_val := FALSE;
      END IF;
    END IF;
    CLOSE c_sgcmt;
    RETURN v_ret_val;
  END;
  EXCEPTION
    WHEN OTHERS THEN
       Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
       Fnd_Message.Set_Token('NAME','IGS_AS_VAL_SUAO.ASSP_VAL_SGCMT_CLSD');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_sgcmt_clsd;
  --
  -- To validate an assessment mark against a grade
  -- Return TRUE if the validation passes; Else return FALSE
  --
  FUNCTION assp_val_mark_grade (
    p_mark                         IN     NUMBER,
    p_grade                        IN     VARCHAR2,
    p_grading_schema_cd            IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    --
    gv_other_detail VARCHAR2 (255);
    v_lower_mark_range igs_as_grd_sch_grade.lower_mark_range%TYPE;
    v_upper_mark_range igs_as_grd_sch_grade.upper_mark_range%TYPE;
    --
    -- Get the Lower and Upper Mark limits of the Grade as setup in the
    -- Grading Schema
    --
    CURSOR c_gsg IS
      SELECT gsg.lower_mark_range,
             gsg.upper_mark_range
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = p_grading_schema_cd
      AND    gsg.version_number = p_version_number
      AND    gsg.grade = p_grade;
    --
    -- Get the Minimum of the Lower and Maximum of the Upper Mark limits
    -- as setup in the Grading Schema
    --
    CURSOR c_gsg_min_max IS
      SELECT NVL (MIN (gsg.lower_mark_range), 0) min_lower_mark_range,
             NVL (MAX (gsg.upper_mark_range), 1000) max_upper_mark_range
      FROM   igs_as_grd_sch_grade gsg
      WHERE  gsg.grading_schema_cd = p_grading_schema_cd
      AND    gsg.version_number = p_version_number;
    rec_gsg_min_max c_gsg_min_max%ROWTYPE;
  BEGIN
    -- Validate a mark against a grade within a specified grading schema version
    p_message_name := NULL;
    --
    IF (p_mark IS NULL)
       OR (p_grade IS NULL) THEN
      p_message_name := NULL;
      RETURN TRUE;
    END IF;
    --
    OPEN c_gsg_min_max;
    FETCH c_gsg_min_max INTO rec_gsg_min_max;
    CLOSE c_gsg_min_max;
    IF ((p_mark < rec_gsg_min_max.min_lower_mark_range) OR
        (p_mark > rec_gsg_min_max.max_upper_mark_range)) THEN
      p_message_name := 'IGS_AS_MARK_INVALID';
      RETURN FALSE;
    END IF;
    --
    OPEN c_gsg;
    FETCH c_gsg INTO v_lower_mark_range,
                     v_upper_mark_range;
    --
    IF (c_gsg%NOTFOUND) THEN
      p_message_name := NULL;
      CLOSE c_gsg;
      RETURN TRUE;
    END IF;
    --
    CLOSE c_gsg;
    --
    IF  (v_lower_mark_range IS NOT NULL)
        AND (p_mark < v_lower_mark_range) THEN
      p_message_name := 'IGS_AS_MARK_BELOW_SPECF_RANGE';
      RETURN FALSE;
    END IF;
    --
    IF  (v_upper_mark_range IS NOT NULL)
        AND (p_mark > v_upper_mark_range) THEN
      p_message_name := 'IGS_AS_MARK_ABOVE_SPECF_RANGE';
      RETURN FALSE;
    END IF;
    --
    p_message_name := NULL;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_VAL_SUAO.ASSP_VAL_MARK_GRADE');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_val_mark_grade;
  --
  --
  --
  PROCEDURE assp_val_mark_grade_ss (
    p_mark                         IN     NUMBER,
    p_grade                        IN     VARCHAR2,
    p_grading_schema_cd            IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_boolean                      OUT NOCOPY VARCHAR2
  ) IS
    lv_message_name VARCHAR2 (2000);
  -- Validate a mark against a grade within a specified grading schema version
  -- This is a wrapper procedure on the assp_val_mark_grade function for SS Pages.
  -- Used in GradeAMImpl.java
  BEGIN
    IF igs_as_val_suao.assp_val_mark_grade (
         p_mark,
         p_grade,
         p_grading_schema_cd,
         p_version_number,
         lv_message_name) THEN
      p_boolean := 'TRUE';
      p_message_name := lv_message_name;
    ELSE
      p_boolean := 'FALSE';
      p_message_name := lv_message_name;
    END IF;
  END assp_val_mark_grade_ss;

END igs_as_val_suao;

/
