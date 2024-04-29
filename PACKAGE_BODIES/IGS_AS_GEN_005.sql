--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_005" AS
/* $Header: IGSAS05B.pls 120.2 2006/08/16 11:35:29 sepalani noship $ */

/* Change History
 who       when         what
 smvk     09-Jul-2004   Bug # 3676145. Modified the cursors c_suaai, c_sua to select active (not closed) unit classes.
 shimitta 21-Feb-2006   Bug# 5042414.
 sepalani 16-Aug-2006   Bug# 5469461
 */

  FUNCTION assp_mnt_suaai_uap (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN OUT NOCOPY VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_mnt_suaai_uap;

  FUNCTION assp_mnt_uapi_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_mnt_uapi_suaai;

  FUNCTION assp_set_suao_trans (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_outcome_dt                   IN     DATE,
    p_grade                        IN     VARCHAR2,
    p_grading_schema_cd            IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_translated_grading_schema_cd IN OUT NOCOPY VARCHAR2,
    p_translated_version_number    IN OUT NOCOPY NUMBER,
    p_translated_grade             IN OUT NOCOPY VARCHAR2,
    p_translated_dt                IN OUT NOCOPY DATE,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_set_suao_trans
    -- This module is called when ever the IGS_AS_SU_STMPTOUT.grade is
    -- altered. It will check to see if a grade has had a translation performed
    -- (translated_dt set), if so, then determine the translation for the new
    -- grade. Where a grading schema has been recorded against the course
    -- offering pattern, this will be used to perform the translation.
    --
    -- NOTE: There is a batch routine (assp_upd_suao_trans) which is called to
    -- perform the original translations.  This module is called when a grade
    -- is updated and will check if a translation performed previously and set
    -- the translation fields as required.
    --
    -- Conditions where no translation occurs:
    --
    --        ? No IGS_PS_OFR_PAT grading schema specified.
    --        ? IGS_PS_UNIT_OFR_OPT.grading_schema_prcdnce_ind = 'Y'
    --        ? No grade mapping specified in IGS_AS_GRD_SCH_TRN.
    DECLARE
      v_suao_rec_exists         VARCHAR2 (1);
      v_to_grade                igs_as_grd_sch_trn.to_grade%TYPE;
      v_suao_exists             BOOLEAN                            DEFAULT FALSE;
      v_alt_cd                  VARCHAR2 (10);
      v_acad_cal_type           igs_ca_inst.cal_type%TYPE;
      v_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
      v_acad_ci_start_dt        DATE;
      v_acad_ci_end_dt          DATE;
      v_message_name            VARCHAR2 (30);
      CURSOR c_suao IS
        SELECT 'x'
        FROM   igs_as_su_stmptout suao
        WHERE  suao.person_id = p_person_id
        AND    suao.course_cd = p_course_cd
        AND    suao.uoo_id = p_uoo_id
        AND    suao.outcome_dt < p_outcome_dt
        AND    suao.translated_dt IS NOT NULL;
      CURSOR c_cop (
        cp_acad_cal_type                      igs_ps_ofr_pat.cal_type%TYPE,
        cp_acad_ci_seq_num                    igs_ps_ofr_pat.ci_sequence_number%TYPE
      ) IS
        SELECT cop.grading_schema_cd,
               cop.gs_version_number
        FROM   igs_en_su_attempt sua,
               igs_en_stdnt_ps_att sca,
               igs_ps_unit_ofr_opt uoo,
               igs_ps_ofr_pat cop
        WHERE  sua.person_id = p_person_id
        AND    sua.course_cd = p_course_cd
        AND    sua.uoo_id = p_uoo_id
        AND    uoo.uoo_id = sua.uoo_id
        AND    uoo.grading_schema_prcdnce_ind = 'N'
        AND    sca.person_id = sua.person_id
        AND    sca.course_cd = sua.course_cd
        AND    cop.coo_id = sca.coo_id
        AND    cop.cal_type = cp_acad_cal_type
        AND    cop.ci_sequence_number = cp_acad_ci_seq_num
        AND    cop.grading_schema_cd IS NOT NULL
        AND    cop.gs_version_number IS NOT NULL;
      v_cop_rec                 c_cop%ROWTYPE;
      CURSOR c_gsgt (
        cp_grading_schema_cd                  igs_ps_ofr_pat.grading_schema_cd%TYPE,
        cp_gs_ver_num                         igs_ps_ofr_pat.gs_version_number%TYPE
      ) IS
        SELECT gsgt.to_grade
        FROM   igs_as_grd_sch_trn gsgt
        WHERE  gsgt.grading_schema_cd = p_grading_schema_cd
        AND    gsgt.version_number = p_version_number
        AND    gsgt.grade = p_grade
        AND    gsgt.to_grading_schema_cd = cp_grading_schema_cd
        AND    gsgt.to_version_number = cp_gs_ver_num;
    BEGIN
      p_message_name := NULL;
      IF p_translated_dt IS NULL THEN
        -- If not translating, maybe a new record and field not yet
        -- set or record not even exiosting, check if a previous
        -- grade entry exists that has been translated.
        OPEN c_suao;
        FETCH c_suao INTO v_suao_rec_exists;
        IF c_suao%NOTFOUND THEN
          -- No translation required as outcome not yet
          -- translated.  Return from the module.
          CLOSE c_suao;
          p_translated_grading_schema_cd := NULL;
          p_translated_version_number := NULL;
          p_translated_grade := NULL;
          RETURN TRUE;
        ELSE
          -- Set the tranlation date to indicate
          -- translation attempt.
          CLOSE c_suao;
          v_suao_exists := TRUE;
          p_translated_dt := SYSDATE;
        END IF;
      END IF;
      -- Determine the academic period for the student
      v_alt_cd := igs_en_gen_002.enrp_get_acad_alt_cd (
                    p_cal_type,
                    p_ci_sequence_number,
                    v_acad_cal_type,
                    v_acad_ci_sequence_number,
                    v_acad_ci_start_dt,
                    v_acad_ci_end_dt,
                    v_message_name
                  );
      IF v_message_name IS NOT NULL THEN
        p_message_name := v_message_name;
        RETURN FALSE;
      END IF;
      -- Verify that the IGS_PS_UNIT_OFR_OPT.grading_schema_prcdnce_ind = 'N'
      -- and that IGS_PS_OFR_PAT.grading_schema_cd is not null for the
      -- student unit attempt and get the course offering pattern grading schema
      -- that will be used in the translation. Otherwise skip the student unit
      -- attempt as no translation possible.
      OPEN c_cop (v_acad_cal_type, v_acad_ci_sequence_number);
      FETCH c_cop INTO v_cop_rec;
      IF c_cop%FOUND THEN
        CLOSE c_cop;
        -- Validate that their exists a grade mapping.
        OPEN c_gsgt (v_cop_rec.grading_schema_cd, v_cop_rec.gs_version_number);
        FETCH c_gsgt INTO v_to_grade;
        IF c_gsgt%NOTFOUND THEN
          CLOSE c_gsgt;
          p_translated_grading_schema_cd := NULL;
          p_translated_version_number := NULL;
          p_translated_grade := NULL;
          RETURN TRUE;
        ELSE
          -- If record already translated and is the same,
          -- do not update.
          CLOSE c_gsgt;
          IF  v_suao_exists
              AND (NVL (p_translated_grading_schema_cd, 'NULL') = v_cop_rec.grading_schema_cd)
              AND (NVL (p_translated_version_number, 0) = v_cop_rec.gs_version_number)
              AND (NVL (p_translated_grade, 'NULL') = v_to_grade) THEN
            -- Leave parameter fields the same.
            RETURN TRUE;
          END IF;
        END IF;
        -- Set the fields to the new translation.
        p_translated_grading_schema_cd := v_cop_rec.grading_schema_cd;
        p_translated_version_number := v_cop_rec.gs_version_number;
        p_translated_grade := v_to_grade;
        RETURN TRUE;
      END IF;
      -- IF processing has reached this point, then no translation possible.
      p_translated_grading_schema_cd := NULL;
      p_translated_version_number := NULL;
      p_translated_grade := NULL;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_suao%ISOPEN THEN
          CLOSE c_suao;
        END IF;
        IF c_cop%ISOPEN THEN
          CLOSE c_cop;
        END IF;
        IF c_gsgt%ISOPEN THEN
          CLOSE c_gsgt;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_set_suao_trans');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_set_suao_trans;

  FUNCTION assp_upd_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_version_number               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN  NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_upd_suaai_dflt
    -- This routine will perform a routine that will check if assessment items
    -- still apply to the students new unit offering oprion or if they should
    -- be logically deleted and default items assigned for the new unit
    -- offering option.
    -- This routine will return false and rollback any alteration if a lock exists
    -- when attempting to logically delete an assessment item.
    DECLARE
      cst_yes CONSTANT CHAR                 := 'Y';
      v_message_name   VARCHAR2 (30);
      v_func_ret_flag  BOOLEAN;
      CURSOR cur_uoo_id IS
        SELECT uoo_id
        FROM   igs_ps_unit_ofr_opt
        WHERE  unit_cd = p_unit_cd
        AND    version_number = p_version_number
        AND    cal_type = p_cal_type
        AND    ci_sequence_number = p_ci_sequence_number
        AND    location_cd = p_location_cd
        AND    unit_class = p_unit_class;
      rec_uoo_id       cur_uoo_id%ROWTYPE;
      CURSOR c_suaai (
        cp_person_id                          igs_as_su_atmpt_itm.person_id%TYPE,
        cp_course_cd                          igs_as_su_atmpt_itm.course_cd%TYPE,
        cp_unit_cd                            igs_as_su_atmpt_itm.unit_cd%TYPE,
        cp_cal_type                           igs_as_su_atmpt_itm.cal_type%TYPE,
        cp_ci_sequence_number                 igs_as_su_atmpt_itm.ci_sequence_number%TYPE,
        cp_uoo_id                             igs_en_su_attempt.uoo_id%TYPE
      ) IS
        SELECT suaai.ass_id,
               suaai.unit_section_ass_item_id,
               suaai.unit_ass_item_id
        FROM   igs_as_su_atmpt_itm suaai,
               igs_en_su_attempt_all sua
        WHERE  suaai.person_id = cp_person_id
        AND    suaai.course_cd = cp_course_cd
        AND    suaai.uoo_id = cp_uoo_id
        AND    sua.person_id = suaai.person_id
        AND    sua.course_cd = suaai.course_cd
        AND    sua.uoo_id = suaai.uoo_id
        AND    sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED')
        AND    suaai.attempt_number = (SELECT MAX (attempt_number)
                                       FROM   igs_as_su_atmpt_itm suaai2
                                       WHERE  suaai2.person_id = cp_person_id
                                       AND    suaai2.course_cd = cp_course_cd
                                       AND    suaai2.uoo_id = cp_uoo_id
                                       AND    suaai2.ass_id = suaai.ass_id)
        AND    suaai.s_default_ind = cst_yes
        AND    suaai.logical_delete_dt IS NULL;
      CURSOR c_suv (
        cp_person_id                          igs_as_su_atmpt_itm.person_id%TYPE,
        cp_course_cd                          igs_as_su_atmpt_itm.course_cd%TYPE,
        cp_unit_cd                            igs_as_su_atmpt_itm.unit_cd%TYPE,
        cp_cal_type                           igs_as_su_atmpt_itm.cal_type%TYPE,
        cp_ci_sequence_number                 igs_as_su_atmpt_itm.ci_sequence_number%TYPE,
        cp_ass_id                             igs_as_su_atmpt_itm.ass_id%TYPE,
        cp_uoo_id                             igs_en_su_attempt.uoo_id%TYPE
      ) IS
        SELECT suv.ass_id
        FROM   igs_as_uai_sua_v suv
        WHERE  suv.person_id = cp_person_id
        AND    suv.course_cd = cp_course_cd
        AND    suv.uoo_id = cp_uoo_id
        AND    suv.ass_id = cp_ass_id
        AND    suv.uai_dflt_item_ind = cst_yes
        AND    suv.uai_logical_delete_dt IS NULL;
      CURSOR c_uai (
        cp_unit_cd                            igs_as_su_atmpt_itm.unit_cd%TYPE,
        cp_version_number                     igs_as_unitass_item.version_number%TYPE,
        cp_cal_type                           igs_as_su_atmpt_itm.cal_type%TYPE,
        cp_ci_sequence_number                 igs_as_su_atmpt_itm.ci_sequence_number%TYPE
      ) IS
        SELECT DISTINCT ass_id,
                        unit_ass_item_id,
                        unit_ass_item_group_id,
                        midterm_mandatory_type_code ,
                        midterm_weight_qty ,
                        final_mandatory_type_code ,
                        final_weight_qty ,
                        grading_schema_cd ,
                        gs_version_number
        FROM            igs_as_unitass_item
        WHERE           unit_cd = cp_unit_cd
        AND             version_number = cp_version_number
        AND             cal_type = cp_cal_type
        AND             ci_sequence_number = cp_ci_sequence_number
        AND             dflt_item_ind = cst_yes
	AND		logical_delete_dt IS NULL;
      v_suaai_rec      c_suaai%ROWTYPE;
      v_uai_rec        c_uai%ROWTYPE;
      v_suv_rec        c_suv%ROWTYPE;
      l_ass_id      igs_as_su_atmpt_itm.unit_ass_item_id%TYPE;
    BEGIN
      -- Set the default message number
      p_message_name := NULL;
      OPEN cur_uoo_id;
      FETCH cur_uoo_id INTO rec_uoo_id;
      CLOSE cur_uoo_id;
      SAVEPOINT sp_upd_suaai_dflt;
      FOR v_suaai_rec IN c_suaai (
                           p_person_id,
                           p_course_cd,
                           p_unit_cd,
                           p_cal_type,
                           p_ci_sequence_number,
                           rec_uoo_id.uoo_id
                         ) LOOP
        -- Validate if the item still applies to the new unit offering.
        -- If not, then logically delete it.
        -- Select from the IGS_AS_UAI_SUA_V as this provides the current assessment items
        -- that are applicable the the unit offering of the student unit attempt.
        -- If the assessment item is found in the view, this means that the item still
        -- applies to the student.
        OPEN c_suv (
          p_person_id,
          p_course_cd,
          p_unit_cd,
          p_cal_type,
          p_ci_sequence_number,
          v_suaai_rec.ass_id,
          rec_uoo_id.uoo_id
        );
        FETCH c_suv INTO v_suv_rec;
        IF c_suv%NOTFOUND THEN
          CLOSE c_suv;
          -- Delete the record as it is no longer valid.
          IF(v_suaai_rec.unit_section_ass_item_id IS NULL) THEN
            l_ass_id := v_suaai_rec.unit_ass_item_id ;
          ELSE
           l_ass_id := v_suaai_rec.unit_section_ass_item_id ;
          END IF;
          IF igs_as_gen_001.assp_del_suaai_dflt (
               p_person_id,
               p_cal_type,
               p_ci_sequence_number,
               p_course_cd,
               p_unit_cd,
               v_suaai_rec.ass_id,
               p_s_log_type,
               p_key,
               p_sle_key,
               p_error_count,
               p_warning_count,
               v_message_name,
               rec_uoo_id.uoo_id,
               l_ass_id
             ) = FALSE THEN
            -- If a logical delete has failed, then a lock must exist
            -- when attempting to update the logical_delete_dt
            -- Issue a rollback to the savepoint issued at the start of processing.
            ROLLBACK TO sp_upd_suaai_dflt;
            p_message_name := v_message_name;
            RETURN FALSE;
          END IF;
        ELSE
          CLOSE c_suv;
        END IF;
      END LOOP;
      -- Insert any default assessment items that do not already exist for the new
      -- unit offering.
      FOR v_uai_rec IN c_uai (p_unit_cd, p_version_number, p_cal_type, p_ci_sequence_number) LOOP
        v_func_ret_flag :=
            igs_as_gen_004.assp_ins_suaai_dflt (
              p_person_id,
              p_course_cd,
              p_unit_cd,
              p_version_number,
              p_cal_type,
              p_ci_sequence_number,
              p_location_cd,
              p_unit_class,
              v_uai_rec.ass_id,
              NULL,
              'UNIT', -- Added by DDEY as a part of enhancement Bug # 2162831
              NULL,
              p_s_log_type,
              p_key,
              p_sle_key,
              p_error_count,
              p_warning_count,
              v_message_name,
              v_uai_rec.unit_ass_item_id ,
              v_uai_rec.unit_ass_item_group_id,
              v_uai_rec.midterm_mandatory_type_code,
              v_uai_rec.midterm_weight_qty,
              v_uai_rec.final_mandatory_type_code,
              v_uai_rec.final_weight_qty,
              v_uai_rec.grading_schema_cd,
              v_uai_rec.gs_version_number,
              p_uoo_id
            );
      END LOOP;
      -- Return the default value
      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_upd_suaai_dflt');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_upd_suaai_dflt;

  FUNCTION assp_upd_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_version_number               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  )
    RETURN BOOLEAN IS
  BEGIN
    NULL;
  END assp_upd_suaap_dflt;

  FUNCTION assp_upd_uai_action (
    p_ass_id IN igs_as_unitass_item_all.ass_id%TYPE,
    p_message_name OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    e_resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_resource_busy,  -54);
    CURSOR c_uai (cp_ass_id igs_as_unitass_item.ass_id%TYPE) IS
      SELECT        uai.ass_id
      FROM          igs_ca_stat cs,
                    igs_ca_inst ci,
                    igs_ps_unit_stat ust,
                    igs_ps_unit_ver uv,
                    igs_as_unitass_item uai
      WHERE         cs.s_cal_status <> 'INACTIVE'
      AND           ci.cal_status = cs.cal_status
      AND           uai.ci_sequence_number = ci.sequence_number
      AND           uai.cal_type = ci.cal_type
      AND           ust.s_unit_status <> 'INACTIVE'
      AND           uv.unit_status = ust.unit_status
      AND           uai.version_number = uv.version_number
      AND           uai.unit_cd = uv.unit_cd
      AND           uai.ass_id = cp_ass_id
      AND           uai.logical_delete_dt IS NULL
      AND           uai.action_dt IS NULL
      FOR UPDATE OF uai.action_dt NOWAIT;
    v_sysdate       DATE;
    v_record_found  BOOLEAN;
    v_other_detail  VARCHAR2 (255);
  BEGIN
    -- This module updates the action date for all unit assessment items
    -- for a particular assessment item when the latter has had a course
    -- type (restriction) record added or deleted.
    -- If a lock is encountered at any time, then the transaction is
    -- rolled back.
    p_message_name := NULL;
    v_sysdate := SYSDATE;
    v_record_found := FALSE;
    FOR v_uai_rec IN c_uai (p_ass_id) LOOP
      v_record_found := TRUE;
      UPDATE igs_as_unitass_item uai
         SET uai.action_dt = v_sysdate
       WHERE  CURRENT OF c_uai;
    END LOOP;
    RETURN TRUE;
  EXCEPTION
    WHEN e_resource_busy THEN
      -- rollback any student_unit_attempts updated
      p_message_name := 'IGS_AS_UAI_ASSITEM_NOUPD';
      RETURN FALSE;
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_upd_uai_action');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_upd_uai_action;

  FUNCTION assp_upd_uap_uoo (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_call_by_db_trg               IN     VARCHAR2 DEFAULT 'N',
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_upd_uap_uoo;

  FUNCTION assp_val_sca_comm (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_val_sca_comm
    -- This module retrieves the latest year in the IGS_PE_PERSON has enrolment
    -- in the course.
    DECLARE
      v_min_year VARCHAR2 (10);
      CURSOR c_sca IS
         SELECT MIN
          (SUBSTR
                (igs_en_gen_014.enrs_get_acad_alt_cd (suav.cal_type,
                                                      suav.ci_sequence_number
                                                     ),
                 1,
                 10
                )
          )
  FROM igs_en_stdnt_ps_att sca,
       igs_en_su_attempt suav,
       igs_ps_ofr_pat cop,
       igs_ca_inst ci
 WHERE sca.person_id = p_person_id
   AND sca.course_cd = p_course_cd
   AND sca.person_id = suav.person_id
   AND sca.course_cd = suav.course_cd
   AND EXISTS (
          SELECT 'X'
            FROM igs_en_su_attempt sua
           WHERE sua.person_id = suav.person_id
             AND sua.course_cd = suav.course_cd
             AND sua.uoo_id = suav.uoo_id
             AND igs_as_gen_001.assp_val_sua_display
                                              (sua.person_id,
                                               sua.course_cd,
                                               sca.version_number,
                                               sua.unit_cd,
                                               sua.cal_type,
                                               sua.ci_sequence_number,
                                               sua.unit_attempt_status,
                                               sua.administrative_unit_status,
                                               'Y',
                                               p_include_fail_grade_ind,
                                               p_enrolled_units_ind,
                                               p_exclude_research_units_ind,
                                               p_exclude_unit_category,
                                               sua.uoo_id
                                              ) = 'Y')
   AND sca.coo_id = cop.coo_id
   AND sca.location_cd = cop.location_cd
   AND sca.attendance_mode = cop.attendance_mode
   AND sca.attendance_type = cop.attendance_type
   AND cop.cal_type = ci.cal_type
   AND cop.ci_sequence_number = ci.sequence_number
   AND igs_en_gen_014.enrs_get_within_ci (cop.cal_type,
                                          cop.ci_sequence_number,
                                          suav.cal_type,
                                          suav.ci_sequence_number,
                                          'Y'
                                         ) = 'Y';

    BEGIN
      -- Determine the latest year in which the IGS_PE_PERSON has active enrolment.
      v_min_year := NULL;
      OPEN c_sca;
      FETCH c_sca INTO v_min_year;
      IF c_sca%NOTFOUND THEN
        CLOSE c_sca;
      END IF;
      CLOSE c_sca;
      RETURN v_min_year;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sca%ISOPEN THEN
          CLOSE c_sca;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_val_sca_comm');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_val_sca_comm;

  FUNCTION assp_val_sca_final (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_include_related_crs_ind      IN     VARCHAR2 DEFAULT 'N'
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_val_sca_final
    -- This module retrieves the latest year in the IGS_PE_PERSON has enrolment
    -- in the course.
    DECLARE
      v_max_year VARCHAR2 (10);
      CURSOR c_sca IS
        SELECT MAX (SUBSTR (igs_en_gen_014.enrs_get_acad_alt_cd (suav.cal_type, suav.ci_sequence_number), 1, 10)) acad_alternate_code
        FROM   igs_en_stdnt_ps_att sca,
               igs_en_su_attempt suav,
               igs_ps_ofr_pat cop,
               igs_ca_inst ci
        WHERE  sca.person_id = p_person_id
        AND    sca.course_cd = p_course_cd
        AND    sca.person_id = suav.person_id
        AND    sca.course_cd = suav.course_cd
        AND    EXISTS ( SELECT 'X'
                        FROM   igs_en_su_attempt sua
                        WHERE  sua.person_id = suav.person_id
                        AND    sua.course_cd = suav.course_cd
                        AND    sua.uoo_id = suav.uoo_id
                        AND    igs_as_gen_001.assp_val_sua_display (
                                 sua.person_id,
                                 sua.course_cd,
                                 sca.version_number,
                                 sua.unit_cd,
                                 sua.cal_type,
                                 sua.ci_sequence_number,
                                 sua.unit_attempt_status,
                                 sua.administrative_unit_status,
                                 'Y',
                                 p_include_fail_grade_ind,
                                 p_enrolled_units_ind,
                                 p_exclude_research_units_ind,
                                 p_exclude_unit_category,
                                 sua.uoo_id
                               ) = 'Y')
        AND    sca.coo_id = cop.coo_id
        AND    sca.location_cd = cop.location_cd
        AND    sca.attendance_mode = cop.attendance_mode
        AND    sca.attendance_type = cop.attendance_type
        AND    cop.cal_type = ci.cal_type
        AND    cop.ci_sequence_number = ci.sequence_number
        AND    igs_en_gen_014.enrs_get_within_ci (
                 cop.cal_type,
                 cop.ci_sequence_number,
                 suav.cal_type,
                 suav.ci_sequence_number,
                 'Y'
               ) = 'Y';
    BEGIN
      -- Determine the latest year in which the IGS_PE_PERSON has active enrolment.
      v_max_year := NULL;
      OPEN c_sca;
      FETCH c_sca INTO v_max_year;
      IF c_sca%NOTFOUND THEN
        CLOSE c_sca;
      END IF;
      CLOSE c_sca;
      RETURN v_max_year;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sca%ISOPEN THEN
          CLOSE c_sca;
        END IF;
        RAISE;
    END;
  END assp_val_sca_final;

  FUNCTION assp_mnt_suaai_uai (
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN OUT NOCOPY VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_ass_id_usec_unit_ind         IN     VARCHAR2 DEFAULT 'UNIT',
    p_ass_item_id                  IN NUMBER ,
    p_group_id                     IN NUMBER,
    p_midterm_mandatory_type_code IN VARCHAR2,
    p_midterm_weight_qty IN NUMBER ,
    p_final_mandatory_type_code IN VARCHAR2,
    p_final_weight_qty IN NUMBER,
    p_grading_schema_cd IN VARCHAR2,
    p_gs_version_number  IN NUMBER ,
    p_uoo_id IN NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_mnt_suaai_uai
    -- This routine is called from the process that determines if changes have
    -- been made to unit_assessment_items and applies them to the
    -- stdnt_unit_atmpt_ass_items.
    -- This routine will determine if the IGS_AS_SU_ATMPT_ITM is
    -- still valid for the student. The IGS_AS_UNITASS_ITEM may have been
    -- updated and for example the location code may have been altered from
    -- GEELONG to BURWOOD, making the assessment item for the GEELONG student
    -- no longer valid. In such a case it will logically delete the assessment
    -- item.
    -- This routine will also insert items that may not already exist. To continue
    -- on with the above example of the location code being updated, the student
    -- who is studying the unit at BURWOOD, now will need to have the assessment
    -- item allocated to them.
    DECLARE
      cst_enrolled CONSTANT VARCHAR2 (8)           := 'ENROLLED';
      --
      -- Get the Unit Section Identifier
      --
      CURSOR cur_uoo_id IS
        SELECT uoo_id
        FROM   igs_ps_unit_ofr_opt
        WHERE  unit_cd = p_unit_cd
        AND    version_number = p_version_number
        AND    cal_type = p_cal_type
        AND    ci_sequence_number = p_ci_sequence_number;
      --
      --
      --
      CURSOR c_sua  IS
        SELECT sua.person_id,
               sua.course_cd,
               sua.location_cd,
               sua.unit_class,
               uc.unit_mode,
               sua.uoo_id
        FROM   igs_en_su_attempt_all sua,
               igs_as_unit_class uc
        WHERE  sua.uoo_id = NVL(p_uoo_id,sua.uoo_id) AND
               sua.unit_cd = p_unit_cd
        AND    sua.cal_type = p_cal_type
        AND    sua.ci_sequence_number = p_ci_sequence_number
        AND    sua.version_number = p_version_number
        AND    sua.unit_attempt_status = cst_enrolled
        AND    uc.unit_class = sua.unit_class
        AND    uc.closed_ind = 'N'
        AND    sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED');
      --
      --
      --
      CURSOR cur_suaai_usec_exists (
               cp_person_id NUMBER,
               cp_course_cd VARCHAR2,
               cp_uoo_id    NUMBER
             ) IS
        SELECT 'X'
        FROM   igs_as_su_atmpt_itm
        WHERE  person_id = cp_person_id
        AND    course_cd = cp_course_cd
        AND    uoo_id = cp_uoo_id
        AND    unit_section_ass_item_id IS NOT NULL
        AND    ROWNUM = 1;
      --
      rec_suaai_usec_exists cur_suaai_usec_exists%ROWTYPE;
      v_message_name        VARCHAR2 (30);
      v_valid_ass_item      BOOLEAN;
      CURSOR cur_as_prg_type (cp_ass_id IN NUMBER) IS
        SELECT 'X' record_exists
        FROM   igs_as_course_type_all
        WHERE  ass_id = cp_ass_id;
      rec_as_prg_type cur_as_prg_type%ROWTYPE;
    BEGIN
      -- For unit testing, it will be necessary to set p_s_log_type = 'ASS3213',
      -- other parameters can be whatever.
      -- Also, use IGS_GE_INS_SLE.genp_set_log_cntr to initialise the logging structure
      -- at the start of the module, otherwise you may get a value or numeric error
      -- when attempting to test this module.
      -- If wanting to view log entries, at the end of the module will need to call
      -- IGS_GE_INS_SLE.genp_ins_sle(SYSDATE) to insert into IGS_GE_S_LOG_ENTRY table any
      -- exceptions raised by the modules called. (NOTE: Not necessary to test for
      -- logged records as this will be tested in the unit test of the called
      -- module.)
      -- Set the default message number
      p_message_name := NULL;
      -- Issue a save point for the module so that if locks exist, a rollback can
      -- be performed.
      SAVEPOINT sp_suaai_uai;
      -- Select the students who have been allocated this assessment item
      -- and validate that it still applies to them.
      OPEN cur_as_prg_type (p_ass_id);
      FETCH cur_as_prg_type INTO rec_as_prg_type;
      IF (cur_as_prg_type%FOUND) THEN
        CLOSE cur_as_prg_type;
        --
        UPDATE igs_as_su_atmpt_itm suaai
        SET    suaai.logical_delete_dt = SYSDATE,
               suaai.last_update_date = SYSDATE,
               suaai.last_updated_by = fnd_global.user_id,
               suaai.last_update_login = fnd_global.login_id,
               suaai.request_id = fnd_global.conc_request_id,
               suaai.program_id = fnd_global.conc_program_id,
               suaai.program_application_id = fnd_global.prog_appl_id,
               suaai.program_update_date = SYSDATE
        WHERE  suaai.unit_cd = p_unit_cd
        AND    suaai.cal_type = p_cal_type
        AND    suaai.ci_sequence_number = p_ci_sequence_number
        AND    suaai.ass_id = p_ass_id
        AND    suaai.logical_delete_dt IS NULL
        AND    (suaai.unit_section_ass_item_id  = p_ass_item_id
        OR      suaai.unit_ass_item_id = p_ass_item_id)
        AND    suaai.attempt_number = (
                 SELECT MAX (suaai2.attempt_number)
                 FROM   igs_as_su_atmpt_itm suaai2
                 WHERE  suaai2.person_id = suaai.person_id
                 AND    suaai2.course_cd = suaai.course_cd
                 AND    suaai2.uoo_id = suaai.uoo_id
                 AND    suaai2.ass_id = suaai.ass_id
                 AND    (suaai2.unit_section_ass_item_id  = suaai.unit_section_ass_item_id
                 OR      suaai2.unit_ass_item_id = suaai.unit_ass_item_id))
        AND    EXISTS (
                 SELECT 'X'
                 FROM   igs_en_su_attempt_all sua,
                        igs_en_stdnt_ps_att sca,
                        igs_ps_ver crv
                 WHERE  suaai.person_id = sua.person_id
                 AND    suaai.course_cd = sua.course_cd
                 AND    suaai.uoo_id = sua.uoo_id
                 AND    sua.person_id = sca.person_id
                 AND    sua.course_cd = sca.course_cd
                 AND    sca.course_cd = crv.course_cd
                 AND    sca.version_number = crv.version_number
                 AND    sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED')
                 AND    EXISTS (
                          SELECT 'X'
                          FROM   igs_as_course_type_all act
                          WHERE  act.course_type <> crv.course_type
                          AND    act.ass_id = suaai.ass_id
                        ));
          p_warning_count := SQL%ROWCOUNT;
          IF (p_warning_count > 0) THEN
            igs_ge_ins_sle.genp_set_log_entry (
              p_s_log_type,
              p_key,
              p_sle_key,
              v_message_name,
              'WARNING|ITEM||' || TO_CHAR (p_ass_id)
            );
          END IF;
        ELSE
          CLOSE cur_as_prg_type;
        END IF;
        -- Select all students within the IGS_PS_UNIT, IGS_AD_LOCATION, IGS_AS_UNIT_MODE, IGS_AS_UNIT_CLASS and
        -- attempt to add the assessment item via the module call. Ignore any message
        -- if fails to insert, as it will mean the student already has the item or is
        -- not suppose to have it anyway.The student must be ENROLLED within the unit.
        FOR v_sua_rec IN c_sua LOOP
          p_sle_key :=    'ITEM|'
                       || TO_CHAR (p_ass_id)
                       || '|'
                       || TO_CHAR (v_sua_rec.person_id)
                       || '|'
                       || v_sua_rec.course_cd
                       || '|'
                       || p_unit_cd
                       || '|'
                       || TO_CHAR (p_version_number)
                       || '|'
                       || p_cal_type
                       || '|'
                       || TO_CHAR (p_ci_sequence_number);
          -- to check if the assessment item passed is setup at section level then
          -- associate teh assessment item with the student if not already associated
          -- added as a part of bug 2162831
          IF p_ass_id_usec_unit_ind = 'USEC' THEN
            IF NOT igs_as_gen_004.assp_ins_suaai_dflt (
                     v_sua_rec.person_id,
                     v_sua_rec.course_cd,
                     p_unit_cd,
                     p_version_number,
                     p_cal_type,
                     p_ci_sequence_number,
                     v_sua_rec.location_cd,
                     v_sua_rec.unit_class,
                     p_ass_id,
                     NULL,
                     p_ass_id_usec_unit_ind, -- Added by DDEY as a part of enhancement Bug # 2162831
                     NULL, -- No log creation date.
                     p_s_log_type,
                     p_key,
                     p_sle_key,
                     p_error_count,
                     p_warning_count,
                     v_message_name,
                     p_ass_item_id,
                     p_group_id,
                     p_midterm_mandatory_type_code,
                     p_midterm_weight_qty,
                     p_final_mandatory_type_code,
                     p_final_weight_qty,
                     p_grading_schema_cd,
                     p_gs_version_number,
                     v_sua_rec.uoo_id
                   ) THEN
              -- Do nothing as will have failed to create the default due
              -- to student having the item already or it may not be valid
              -- for the unit offering that the student is attempting.
              -- No locking will occur as not processing a pattern.
              NULL;
            END IF;
          ELSIF p_ass_id_usec_unit_ind = 'UNIT' THEN
            --IF the assessment item passed is present at unit offering level then check if the assessment
            --item st up is presetn at nit section level
            --IF yes then need not associate the item with the student.else call the procedure to associate
            -- the code has been added as a part of bug number 2162831
            --
            -- Skip this Unit Assessment Item as Student already has Assessment Items
            -- attached from Unit Section Level
            --
            OPEN cur_suaai_usec_exists (
                   v_sua_rec.person_id,
                   v_sua_rec.course_cd,
                   v_sua_rec.uoo_id
                 );
            FETCH cur_suaai_usec_exists INTO rec_suaai_usec_exists;
            IF (cur_suaai_usec_exists%NOTFOUND) THEN
              CLOSE cur_suaai_usec_exists;
              IF NOT igs_as_gen_004.assp_ins_suaai_dflt (
                     v_sua_rec.person_id,
                     v_sua_rec.course_cd,
                     p_unit_cd,
                     p_version_number,
                     p_cal_type,
                     p_ci_sequence_number,
                     v_sua_rec.location_cd,
                     v_sua_rec.unit_class,
                     p_ass_id,
                     NULL, -- No assessment pattern.
                     'UNIT', -- Added by DDEY as a part of enhancement Bug # 2162831
                     NULL, -- No log creation date.
                     p_s_log_type,
                     p_key,
                     p_sle_key,
                     p_error_count,
                     p_warning_count,
                     v_message_name ,
                     p_ass_item_id ,
                     p_group_id,
                     p_midterm_mandatory_type_code,
                     p_midterm_weight_qty,
                     p_final_mandatory_type_code,
                     p_final_weight_qty,
                     p_grading_schema_cd,
                     p_gs_version_number,
                     v_sua_rec.uoo_id
                   ) THEN
              -- Do nothing as will have failed to create the default due
              -- to student having the item already or it may not be valid
              -- for the unit offering that the student is attempting.
              -- No locking will occur as not processing a pattern.
              NULL;
              END IF;
            ELSE
              CLOSE cur_suaai_usec_exists;
            END IF;
          END IF;
        END LOOP;
      -- Return the default value
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF c_sua%ISOPEN THEN
          CLOSE c_sua;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_mnt_suaai_uai');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_mnt_suaai_uai;

  FUNCTION assp_upd_usec_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN IS
    /***********************************************************************************************
    Created By:         Deepankar Dey
    Date Created By:    15-01-2002
    Purpose:        This function will perform a routine that will check if assessment items still
                    apply to the students new unit offering option or if they should be logically
                    deleted and default items assigned for the new unit offering option. This
                    routine will return false and rollback any alteration if a lock exists when
                    attempting to logically delete an assessment item.
    Known limitations,enhancements,remarks:
    Change History
    Who        When        What
    DDEY as a part of enhancement Bug # 2162831
    ********************************************************************************************** */
    --
    cst_yes               VARCHAR2 (1);
    l_should_return_false BOOLEAN;
    l_message_name        VARCHAR2 (30);
    --
    -- Get the default Assessment Items setup at Unit Section level
    --
    CURSOR c_ass_setup IS
    SELECT suv.ass_id, unit_section_ass_item_id, us_ass_item_group_id,
           midterm_mandatory_type_code, midterm_weight_qty,
           final_mandatory_type_code, final_weight_qty, grading_schema_cd,
           gs_version_number
     FROM igs_ps_unitass_item suv
     WHERE suv.uoo_id = p_uoo_id
     AND suv.dflt_item_ind = cst_yes
     AND suv.logical_delete_dt IS NULL;

    --
  BEGIN
    --
    -- Initialise IN OUT parameters if NULL
    --
   cst_yes := 'Y';
    p_error_count := NVL (p_error_count, 0);
    p_warning_count := NVL (p_warning_count, 0);
    p_message_name := NULL;
    --
    -- Issue a save point for the module so that if locks exist, a rollback can
    -- be performed.
    --
    SAVEPOINT assp_upd_usec_suaai_dflt_sp;
    --
    l_should_return_false := FALSE;
    --
    FOR ass_setup_rec IN c_ass_setup LOOP
      --
      -- Allocate the Default Unit Section Assessment Item against the student.
      --
      IF igs_as_gen_004.assp_ins_suaai_dflt (
           p_person_id,
           p_course_cd,
           p_unit_cd,
           p_version_number,
           p_cal_type,
           p_ci_sequence_number,
           p_location_cd,
           p_unit_class,
           ass_setup_rec.ass_id,
           NULL,
           'USEC', -- Added by DDEY as a part of enhancement Bug # 2162831
           NULL,
           p_s_log_type,
           p_key,
           p_sle_key,
           p_error_count,
           p_warning_count,
           l_message_name,
           ass_setup_rec.unit_section_ass_item_id,
           ass_setup_rec.us_ass_item_group_id,
           ass_setup_rec.midterm_mandatory_type_code,
           ass_setup_rec.midterm_weight_qty,
           ass_setup_rec.final_mandatory_type_code,
           ass_setup_rec.final_weight_qty,
           ass_setup_rec.grading_schema_cd,
           ass_setup_rec.gs_version_number,
           p_uoo_id
         ) = FALSE THEN
        IF (l_message_name = 'IGS_AS_UNABLE_TOUPD_SUA') THEN
          --
          -- If locking error occurs, return false.
          --
          l_should_return_false := TRUE;
          --
          -- This message was changed as the message specified in the called
          -- function would not be appropriate. This is because, an assessment
          -- item cannot be attached to an assessment pattern at unit section level.
          --
          p_message_name := 'IGS_AS_UNABLE_TOUPD_SUS';
          EXIT;
        END IF;
      END IF;
    END LOOP;
    --
    IF l_should_return_false THEN
      RETURN FALSE;
    END IF;
    --
    RETURN TRUE;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF c_ass_setup%ISOPEN THEN
        CLOSE c_ass_setup;
      END IF;
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_005.assp_upd_usec_suaai_dflt');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_upd_usec_suaai_dflt;
END igs_as_gen_005;

/
