--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_002" AS
/* $Header: IGSAS02B.pls 115.10 2003/12/12 15:48:33 kdande ship $ */

  FUNCTION assp_get_atyp_exmnbl (
    p_assessment_type IN igs_as_assessmnt_itm_all.assessment_type%TYPE
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_atyp_exmnbl
    -- This module fetches the value for the examinable_ind
    -- for an assessment type from the IGS_AS_ASSESSMNT_TYP table.
    DECLARE
      CURSOR c_atyp IS
        SELECT examinable_ind
        FROM   igs_as_assessmnt_typ
        WHERE  assessment_type = p_assessment_type;
      v_atyp_rec c_atyp%ROWTYPE;
    BEGIN
      -- Fetch the examinable indicator
      OPEN c_atyp;
      FETCH c_atyp INTO v_atyp_rec;
      IF c_atyp%NOTFOUND THEN
        CLOSE c_atyp;
        RETURN NULL;
      END IF;
      CLOSE c_atyp;
      RETURN v_atyp_rec.examinable_ind;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_atyp%ISOPEN THEN
          CLOSE c_atyp;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_atyp_exmnbl');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_atyp_exmnbl;

  FUNCTION assp_get_dflt_exloc (p_location_cd IN VARCHAR2)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_dflt_exloc
    -- This routine returns the default examination IGS_AD_LOCATION
    -- for a nominated campus.
    -- The default IGS_AD_LOCATION is signified by the dflt_ind being set in the
    -- IGS_AD_LOCATION_REL table between the specified campus and an exam
    -- IGS_AD_LOCATION.
    DECLARE
      CURSOR c_lr IS
        SELECT lr.sub_location_cd
        FROM   igs_ad_location_rel lr,
               igs_ad_location loc,
               igs_ad_location_type lt
        WHERE  lr.location_cd = p_location_cd
        AND    NVL (lr.dflt_ind, 'N') = 'Y'
        AND    NVL (loc.closed_ind, 'N') = 'N'
        AND    lt.s_location_type = 'EXAM_CTR'
        AND    loc.location_cd = lr.location_cd
        AND    loc.location_type = lt.location_type;
      v_sub_location_cd igs_ad_location_rel.location_cd%TYPE   DEFAULT NULL;
    BEGIN
      -- Search for the default exam IGS_AD_LOCATION
      OPEN c_lr;
      FETCH c_lr INTO v_sub_location_cd;
      IF c_lr%NOTFOUND THEN
        CLOSE c_lr;
        RETURN NULL;
      END IF;
      CLOSE c_lr;
      RETURN v_sub_location_cd;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END assp_get_dflt_exloc;

  FUNCTION assp_get_dflt_finls (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  )
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN
    -- assp_get_dflt_finls
    -- Get the default finalised outcome indicator for a IGS_PE_PERSON.
    -- The default is based on the last outcome against the SUA:
    -- if finalised, the default is finalised; if no finalised,
    -- or there is no prior outcome, the default is unfinalised.
    DECLARE
      v_finalised_outcome_ind igs_as_su_stmptout_all.finalised_outcome_ind%TYPE;
      CURSOR c_suao IS
        SELECT   suao.finalised_outcome_ind
        FROM     igs_as_su_stmptout suao
        WHERE    suao.person_id = p_person_id
        AND      suao.course_cd = p_course_cd
        AND      suao.uoo_id = p_uoo_id
        ORDER BY suao.outcome_dt DESC;
    BEGIN
      OPEN c_suao;
      FETCH c_suao INTO v_finalised_outcome_ind;
      IF (c_suao%NOTFOUND) THEN
        v_finalised_outcome_ind := NULL;
      END IF;
      CLOSE c_suao;
      RETURN v_finalised_outcome_ind;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_dflt_finls');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_dflt_finls;

  FUNCTION assp_get_dflt_grade (p_mark IN NUMBER, p_grading_schema_cd IN VARCHAR2, p_gs_version_number IN NUMBER)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_dflt_grade
    -- Routine to get the default grade within a nominated grading schema
    -- which applies to a nominated mark.
    DECLARE
      v_rec_found BOOLEAN                           DEFAULT FALSE;
      v_ret_val   igs_as_grd_sch_grade.grade%TYPE   DEFAULT NULL;

      CURSOR c_gsg IS
        SELECT grade
        FROM   igs_as_grd_sch_grade
        WHERE  grading_schema_cd = p_grading_schema_cd
        AND    version_number = p_gs_version_number
        AND    (lower_mark_range IS NOT NULL
                OR upper_mark_range IS NOT NULL
               )
        AND    NVL (lower_mark_range, 0) <= FLOOR (p_mark)
        AND    NVL (upper_mark_range, 1000) >= FLOOR (p_mark)
        AND    NVL (closed_ind, 'N') = 'N';
    BEGIN
      -- If parameters are null then return null grade
      IF (p_mark IS NULL
          OR p_grading_schema_cd IS NULL
          OR p_gs_version_number IS NULL
         ) THEN
        RETURN NULL;
      END IF;
      FOR v_gsg_rec IN c_gsg LOOP
        IF (v_rec_found = TRUE) THEN
          -- multiple records found;
          v_ret_val := NULL;
          EXIT;
        END IF;
        v_rec_found := TRUE;
        v_ret_val := v_gsg_rec.grade;
      END LOOP;
      RETURN v_ret_val;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_dflt_grade');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_dflt_grade;

  FUNCTION assp_get_exam_view (
    p_uai_exam_cal_type                   igs_as_unitass_item_all.exam_cal_type%TYPE,
    p_uai_exam_ci_seq                     igs_as_unitass_item_all.exam_ci_sequence_number%TYPE,
    p_ueciv_exam_cal_type                 igs_as_unitass_item_all.exam_cal_type%TYPE,
    p_ueciv_exam_ci_seq                   igs_as_unitass_item_all.exam_ci_sequence_number%TYPE,
    p_sua_person_id                       igs_en_su_attempt_all.person_id%TYPE,
    p_sua_course_cd                       igs_en_su_attempt_all.course_cd%TYPE,
    p_sua_unit_cd                         igs_en_su_attempt_all.unit_cd%TYPE,
    p_sua_version_number                  igs_en_su_attempt_all.version_number%TYPE,
    p_sua_cal_type                        igs_en_su_attempt_all.cal_type%TYPE,
    p_sua_ci_seq                          igs_en_su_attempt_all.ci_sequence_number%TYPE,
    p_sua_unit_attempt_status             igs_en_su_attempt_all.unit_attempt_status%TYPE,
    p_sua_location_cd                     igs_en_su_attempt_all.location_cd%TYPE,
    p_ucl_unit_mode                       igs_as_unit_class_all.unit_mode%TYPE,
    p_sua_unit_class                      igs_en_su_attempt_all.unit_class%TYPE,
    p_ueciv_ass_id                        igs_as_unitass_item_all.ass_id%TYPE
  )
    RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      v_return_val VARCHAR2 (10);
    BEGIN
      v_return_val := igs_as_gen_003.assp_get_supp_cal (
                        p_ueciv_exam_cal_type,
                        p_ueciv_exam_ci_seq,
                        p_sua_person_id,
                        p_sua_course_cd,
                        p_sua_unit_cd,
                        p_sua_version_number,
                        p_sua_cal_type,
                        p_sua_ci_seq,
                        p_sua_unit_attempt_status,
                        p_sua_location_cd,
                        p_ucl_unit_mode,
                        p_sua_unit_class,
                        p_ueciv_ass_id
                      );
      IF v_return_val = 'Y'
         OR v_return_val = 'N' THEN
        RETURN v_return_val;
      ELSE
        IF ((p_uai_exam_cal_type IS NULL
             OR p_ueciv_exam_cal_type = p_uai_exam_cal_type
            )
            AND (p_uai_exam_ci_seq IS NULL
                 OR p_ueciv_exam_ci_seq = p_uai_exam_ci_seq
                )
           ) THEN
          RETURN 'Y';
        ELSE
          RETURN 'N';
        END IF;
      END IF;
    END;
  END assp_get_exam_view;

  FUNCTION assp_get_gsg_cncd (p_grading_schema_cd IN VARCHAR2, p_version_number IN NUMBER, p_grade IN VARCHAR2)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_gsg_cncd
    -- Get whether a nominated grade is a 'conceded' pass grade, as indicated
    -- by the value in the special grade type in the IGS_AS_GRD_SCH_GRADE table.
    DECLARE
      cst_conceded_pass CONSTANT VARCHAR2 (15)                                    := 'CONCEDED-PASS';
      v_s_special_grade_type     igs_as_grd_sch_grade.s_special_grade_type%TYPE;
      CURSOR c_gsg IS
        SELECT gsg.s_special_grade_type
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = p_grading_schema_cd
        AND    gsg.version_number = p_version_number
        AND    gsg.grade = p_grade;
    BEGIN
      OPEN c_gsg;
      FETCH c_gsg INTO v_s_special_grade_type;
      IF c_gsg%NOTFOUND THEN
        CLOSE c_gsg;
        RETURN 'N';
      ELSE
        CLOSE c_gsg;
        IF v_s_special_grade_type = cst_conceded_pass THEN
          RETURN 'Y';
        ELSE
          RETURN 'N';
        END IF;
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
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_gsg_cncd');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_gsg_cncd;

  FUNCTION assp_get_gsg_rank (p_grading_schema_cd IN VARCHAR2, p_version_number IN NUMBER, p_grade IN VARCHAR2)
    RETURN NUMBER IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_gsg_rank
    -- This module fetches the value for the rank for a grade within
    -- a grading schema from the IGS_AS_GRD_SCH_GRADE table.
    DECLARE
      v_gsg_rank igs_as_grd_sch_grade.RANK%TYPE;
      CURSOR c_gsg IS
        SELECT gsg.RANK
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = p_grading_schema_cd
        AND    gsg.version_number = p_version_number
        AND    gsg.grade = p_grade;
    BEGIN
      -- Fetch the rank
      OPEN c_gsg;
      FETCH c_gsg INTO v_gsg_rank;
      IF c_gsg%NOTFOUND THEN
        CLOSE c_gsg;
        RETURN NULL;
      END IF;
      CLOSE c_gsg;
      RETURN v_gsg_rank;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_gsg%ISOPEN THEN
          CLOSE c_gsg;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_gsg_rank');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_gsg_rank;

  FUNCTION assp_get_gsg_result (p_grading_schema_cd IN VARCHAR2, p_version_number IN NUMBER, p_grade IN VARCHAR2)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_gsg_result
    DECLARE
      v_gsg_s_result_type igs_as_grd_sch_grade.s_result_type%TYPE;
      CURSOR c_gsg IS
        SELECT gsg.s_result_type
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = p_grading_schema_cd
        AND    gsg.version_number = p_version_number
        AND    gsg.grade = p_grade;
    BEGIN
      OPEN c_gsg;
      FETCH c_gsg INTO v_gsg_s_result_type;
      IF c_gsg%FOUND THEN
        CLOSE c_gsg;
        RETURN v_gsg_s_result_type;
      ELSE
        CLOSE c_gsg;
        RETURN NULL;
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
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_gsg_result');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_gsg_result;

  FUNCTION assp_get_mark_mndtry (p_grading_schema_cd IN VARCHAR2, p_version_number IN NUMBER, p_grade IN VARCHAR2)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (200);
  BEGIN
    DECLARE
      CURSOR c_gsg IS
        SELECT lower_mark_range,
               upper_mark_range
        FROM   igs_as_grd_sch_grade
        WHERE  grading_schema_cd = p_grading_schema_cd
        AND    version_number = p_version_number
        AND    grade = p_grade;
      v_gsg_rec c_gsg%ROWTYPE;
    BEGIN
      OPEN c_gsg;
      FETCH c_gsg INTO v_gsg_rec;
      IF c_gsg%NOTFOUND THEN
        CLOSE c_gsg;
        RETURN 'N';
      ELSE
        IF (v_gsg_rec.lower_mark_range IS NOT NULL
            AND v_gsg_rec.lower_mark_range <> 0
           )
           OR (v_gsg_rec.upper_mark_range IS NOT NULL
               AND v_gsg_rec.upper_mark_range <> 0
              ) THEN
          CLOSE c_gsg;
          RETURN 'Y';
        ELSE
          CLOSE c_gsg;
          RETURN 'N';
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_002.assp_get_mark_mndtry');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_get_mark_mndtry;

  FUNCTION assp_get_ai_s_type (p_ass_id IN NUMBER)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_ai_s_type
    -- Return the system type of an assessment item.
    DECLARE
      CURSOR c_atyp (cp_ass_id igs_as_assessmnt_itm.ass_id%TYPE) IS
        SELECT s_assessment_type
        FROM   igs_as_assessmnt_typ atyp,
               igs_as_assessmnt_itm ai
        WHERE  ai.ass_id = cp_ass_id
        AND    ai.assessment_type = atyp.assessment_type;
      v_atyp_rec c_atyp%ROWTYPE;
    BEGIN
      OPEN c_atyp (p_ass_id);
      FETCH c_atyp INTO v_atyp_rec;
      IF c_atyp%NOTFOUND THEN
        CLOSE c_atyp;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_atyp;
      RETURN v_atyp_rec.s_assessment_type;
    EXCEPTION
      WHEN OTHERS THEN
        gv_other_detail := 'Parm: p_ass_id - ' || TO_CHAR (p_ass_id);
        RAISE;
    END;
  END assp_get_ai_s_type;
END igs_as_gen_002;

/
