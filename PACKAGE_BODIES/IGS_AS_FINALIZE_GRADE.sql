--------------------------------------------------------
--  DDL for Package Body IGS_AS_FINALIZE_GRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_FINALIZE_GRADE" AS
/* $Header: IGSAS47B.pls 120.2 2006/01/31 03:10:24 swaghmar ship $ */


  PROCEDURE finalize_process_no_commit (
    p_uoo_id                       IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_ci_sequence_number     IN     NUMBER
  ) IS
  BEGIN -- finalize_process
    -- This process completes three main functions namely,
    -- Repeat processing, Translation and Finalization.
    -- This procedure will be called as part of Workflow by Business Events
    -- such as Grade Submission, Change of Grade Approval and by
    -- Grade Finalization through the Student Unit Attempt Outcome Form.
    -------------------------------------------------------------------------------
    -- This procedure can be called in the context of Unit Section using only the
    -- p_uoo_id parameter or in the context of a single Student Unit attempt by
    -- leaving the uoo_id NULL and providing the other parameters.
    -------------------------------------------------------------------------------
    DECLARE
      gv_other_detail                VARCHAR2 (255);
      v_repeatable_ind               igs_ps_unit_ver_all.repeatable_ind%TYPE;
      v_use_most_recent_unit_attempt igs_en_rep_process.use_most_recent_unit_attempt%TYPE;
      v_use_best_grade_attempt       igs_en_rep_process.use_best_grade_attempt%TYPE;
      v_external_formula             igs_en_rep_process.external_formula%TYPE;
      v_new_outcome_dt               DATE;
      v_translated_grading_schema_cd igs_as_grd_sch_trn_all.to_grading_schema_cd%TYPE;
      v_translated_version_number    igs_as_grd_sch_trn_all.to_version_number%TYPE;
      v_translated_grade             igs_as_grd_sch_trn_all.to_grade%TYPE;
      v_translated_dt                DATE;
      v_rowid                        VARCHAR2 (25);
      v_best_prev_rank               igs_as_grd_sch_grade.RANK%TYPE;
      v_best_prev_ci_end_dt          igs_as_su_stmptout_all.ci_end_dt%TYPE;

      CURSOR c_rp IS
        SELECT uv.repeatable_ind,
               rp_org.use_most_recent_unit_attempt,
               rp_org.use_best_grade_attempt,
               rp_org.external_formula
        FROM   igs_ps_unit_ofr_opt_all uoo,
               igs_ps_unit_ver_all uv,
               igs_en_rep_process rp_org,
               igs_or_inst_org_base_v hp
        WHERE  uoo.uoo_id = p_uoo_id
        AND    uoo.unit_cd = uv.unit_cd
        AND    uoo.version_number = uv.version_number
        AND    uv.owner_org_unit_cd = hp.party_number
        AND    hp.party_id = rp_org.org_unit_id
        AND    hp.inst_org_ind = 'O'
       UNION ALL
        SELECT uv1.repeatable_ind,
               rp_inst.use_most_recent_unit_attempt,
               rp_inst.use_best_grade_attempt,
               rp_inst.external_formula
        FROM   igs_ps_unit_ofr_opt_all uoo1,
               igs_ps_unit_ver_all uv1,
               igs_en_rep_process rp_inst
        WHERE  uoo1.uoo_id = p_uoo_id
        AND    uoo1.unit_cd = uv1.unit_cd
        AND    uoo1.version_number = uv1.version_number
        AND    rp_inst.org_unit_id IS NULL
        AND    NOT EXISTS ( SELECT 'X'
        FROM   igs_ps_unit_ofr_opt_all uoo2,
               igs_en_rep_process rp_org,
               igs_or_inst_org_base_v hp
        WHERE  uoo1.uoo_id = uoo2.uoo_id
        AND    uoo2.owner_org_unit_cd = hp.party_number
        AND    hp.party_id = rp_org.org_unit_id
        AND    hp.inst_org_ind = 'O');

      CURSOR c_suao_with_uoo IS
      SELECT suao.person_id,
             suao.course_cd,
             suao.unit_cd,
             suao.cal_type,
             suao.ci_sequence_number,
             suao.uoo_id,
             suao.ROWID,
             suao.outcome_dt,
             suao.ci_start_dt,
             suao.ci_end_dt,
             suao.grading_schema_cd,
             suao.version_number,
             suao.grade,
             suao.s_grade_creation_method_type,
             suao.mark,
             suao.comments,
             gsg.repeat_grade,
             gsg.RANK,
             suao.incomp_deadline_date,
             suao.incomp_grading_schema_cd,
             suao.incomp_version_number,
             suao.incomp_default_grade,
             suao.incomp_default_mark,
             suao.attribute_category,
             suao.attribute1,
             suao.attribute2,
             suao.attribute3,
             suao.attribute4,
             suao.attribute5,
             suao.attribute6,
             suao.attribute7,
             suao.attribute8,
             suao.attribute9,
             suao.attribute10,
             suao.attribute11,
             suao.attribute12,
             suao.attribute13,
             suao.attribute14,
             suao.attribute15,
             suao.attribute16,
             suao.attribute17,
             suao.attribute18,
             suao.attribute19,
             suao.attribute20,
             suao.mark_capped_flag,
             suao.release_date,
             suao.manual_override_flag,
             suao.show_on_academic_histry_flag
      FROM   igs_as_su_stmptout_all suao,
             igs_as_grd_sch_grade gsg
      WHERE  suao.uoo_id = p_uoo_id
      AND    suao.finalised_outcome_ind = 'N'
      AND    suao.grading_period_cd = 'FINAL'
      AND    suao.grading_schema_cd = gsg.grading_schema_cd
      AND    suao.version_number = gsg.version_number
      AND    suao.grade = gsg.grade
      AND    NVL(gsg.closed_ind,'N') = 'N'
      AND    suao.outcome_dt = (SELECT MAX (suao1.outcome_dt)
                                FROM   igs_as_su_stmptout_all suao1
                                WHERE  suao1.person_id = suao.person_id
                                AND    suao1.course_cd = suao.course_cd
                                AND    suao1.uoo_id = suao.uoo_id
                                AND    suao1.grading_period_cd = suao.grading_period_cd);

      CURSOR c_suao_with_sua IS
      SELECT suao.person_id,
             suao.course_cd,
             suao.unit_cd,
             suao.cal_type,
             suao.ci_sequence_number,
             suao.uoo_id,
             suao.ROWID,
             suao.outcome_dt,
             suao.ci_start_dt,
             suao.ci_end_dt,
             suao.grading_schema_cd,
             suao.version_number,
             suao.grade,
             suao.s_grade_creation_method_type,
             suao.mark,
             suao.comments,
             gsg.repeat_grade,
             gsg.RANK,
             suao.incomp_deadline_date,
             suao.incomp_grading_schema_cd,
             suao.incomp_version_number,
             suao.incomp_default_grade,
             suao.incomp_default_mark,
             suao.attribute_category,
             suao.attribute1,
             suao.attribute2,
             suao.attribute3,
             suao.attribute4,
             suao.attribute5,
             suao.attribute6,
             suao.attribute7,
             suao.attribute8,
             suao.attribute9,
             suao.attribute10,
             suao.attribute11,
             suao.attribute12,
             suao.attribute13,
             suao.attribute14,
             suao.attribute15,
             suao.attribute16,
             suao.attribute17,
             suao.attribute18,
             suao.attribute19,
             suao.attribute20,
             suao.mark_capped_flag,
             suao.release_date,
             suao.manual_override_flag,
             suao.show_on_academic_histry_flag
      FROM   igs_as_su_stmptout_all suao,
             igs_as_grd_sch_grade gsg
      WHERE  suao.person_id = p_person_id
      AND    suao.course_cd = p_course_cd
      AND    suao.uoo_id = p_uoo_id
      AND    suao.finalised_outcome_ind = 'N'
      AND    suao.grading_period_cd = 'FINAL'
      AND    suao.grading_schema_cd = gsg.grading_schema_cd
      AND    suao.version_number = gsg.version_number
      AND    suao.grade = gsg.grade
      AND    NVL(gsg.closed_ind,'N') = 'N'
      AND    suao.outcome_dt = (SELECT MAX (suao1.outcome_dt)
                                FROM   igs_as_su_stmptout_all suao1
                                WHERE  suao1.person_id = suao.person_id
                                AND    suao1.course_cd = suao.course_cd
                                AND    suao1.uoo_id = suao.uoo_id
                                AND    suao1.grading_period_cd = suao.grading_period_cd);

      CURSOR c_prev_suao (
        cp_person_id                          igs_as_su_stmptout_all.person_id%TYPE,
        cp_unit_cd                            igs_as_su_stmptout_all.unit_cd%TYPE,
        cp_course_cd                          igs_as_su_stmptout_all.course_cd%TYPE,
        cp_cal_type                           igs_as_su_stmptout_all.cal_type%TYPE,
        cp_ci_sequence_number                 igs_as_su_stmptout_all.ci_sequence_number%TYPE
      ) IS
        SELECT   sua.person_id,
                 sua.course_cd,
                 sua.unit_cd,
                 sua.cal_type,
                 sua.ci_sequence_number,
                 -- anilk, 22-Apr-2003, Bug# 2829262
                 sua.uoo_id,
                 suao.outcome_dt,
                 suao.ci_start_dt,
                 suao.ci_end_dt,
                 suao.grading_schema_cd,
                 suao.version_number,
                 suao.grade,
                 suao.mark,
                 suao.incomp_deadline_date,
                 suao.incomp_grading_schema_cd,
                 suao.incomp_version_number,
                 suao.incomp_default_grade,
                 suao.incomp_default_mark,
                 suao.comments,
                 gsg.repeat_grade,
                 gsg.RANK,
                 --ijeddy, bug #3027047.
                 suao.attribute_category,
                 suao.attribute1,
                 suao.attribute2,
                 suao.attribute3,
                 suao.attribute4,
                 suao.attribute5,
                 suao.attribute6,
                 suao.attribute7,
                 suao.attribute8,
                 suao.attribute9,
                 suao.attribute10,
                 suao.attribute11,
                 suao.attribute12,
                 suao.attribute13,
                 suao.attribute14,
                 suao.attribute15,
                 suao.attribute16,
                 suao.attribute17,
                 suao.attribute18,
                 suao.attribute19,
                 suao.attribute20,
                 suao.mark_capped_flag,
                 suao.release_date,
                 suao.manual_override_flag,
                 suao.show_on_academic_histry_flag
        FROM     igs_en_su_attempt sua,
                 igs_as_su_stmptout_all suao,
                 igs_as_grd_sch_grade gsg
        WHERE    sua.person_id = cp_person_id
        AND      sua.unit_cd = cp_unit_cd
        AND      (sua.course_cd <> cp_course_cd
                  OR sua.cal_type <> cp_cal_type
                  OR sua.ci_sequence_number <> cp_ci_sequence_number
                 )
        AND      suao.person_id = sua.person_id
        AND      suao.course_cd = sua.course_cd
        AND      suao.uoo_id = sua.uoo_id
        AND      suao.incomp_deadline_date IS NULL
        AND      suao.finalised_outcome_ind = 'Y'
        AND      suao.grading_period_cd = 'FINAL'
        AND      suao.grading_schema_cd = gsg.grading_schema_cd
        AND      suao.version_number = gsg.version_number
        AND      suao.grade = gsg.grade
        AND      gsg.incl_in_repeat_process_ind = 'Y'
        AND      NVL(gsg.closed_ind,'N') = 'N'
        AND      suao.outcome_dt IN (SELECT MAX (outcome_dt)
                                     FROM   igs_as_su_stmptout
                                     WHERE  person_id = suao.person_id
                                     AND    course_cd = suao.course_cd
                                     AND    uoo_id = suao.uoo_id
                                     AND    grading_period_cd = suao.grading_period_cd)
        ORDER BY gsg.RANK ASC,
                 suao.ci_end_dt DESC;
    BEGIN -- Main
      SAVEPOINT s_before_finalize;
      --
      -- Get repeat configuration
      --
      OPEN c_rp;
      FETCH c_rp INTO v_repeatable_ind,
                      v_use_most_recent_unit_attempt,
                      v_use_best_grade_attempt,
                      v_external_formula;
      CLOSE c_rp;
    IF p_person_id IS NOT NULL THEN
      FOR v_suao_rec IN c_suao_with_sua LOOP
        v_new_outcome_dt := NULL;
        --
        -- Repeat Processing
        -- If External Formula is set call Repeat Processing User Hook and exit
        --
        IF  v_external_formula = 'Y'
            AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
          igs_as_user_repeat.user_repeat_process (
            v_suao_rec.person_id,
            v_suao_rec.course_cd,
            v_suao_rec.unit_cd,
            v_suao_rec.cal_type,
            v_suao_rec.ci_sequence_number,
            v_suao_rec.outcome_dt,
            v_suao_rec.grading_schema_cd,
            v_suao_rec.version_number,
            v_suao_rec.grade,
            -- anilk, 22-Apr-2003, Bug# 2829262
            v_suao_rec.uoo_id
          );
        ELSE
          IF  v_use_most_recent_unit_attempt = 'Y'
              AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
            --
            -- The current outcome is considered to be the most recent outcome so
            -- any other outcomes with valid repeat grades should be set to that
            -- repeat grade.
            --
            FOR v_prev_suao_rec IN c_prev_suao (
                                     v_suao_rec.person_id,
                                     v_suao_rec.unit_cd,
                                     v_suao_rec.course_cd,
                                     v_suao_rec.cal_type,
                                     v_suao_rec.ci_sequence_number
                                   ) LOOP
              IF v_prev_suao_rec.repeat_grade IS NOT NULL THEN
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_prev_suao_rec.person_id,
                  v_prev_suao_rec.course_cd,
                  v_prev_suao_rec.unit_cd,
                  v_prev_suao_rec.cal_type,
                  v_prev_suao_rec.ci_sequence_number,
                  v_prev_suao_rec.grading_schema_cd,
                  v_prev_suao_rec.version_number,
                  v_prev_suao_rec.repeat_grade,
                  v_prev_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  -- anilk, 22-Apr-2003, Bug# 2829262
                  v_prev_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_prev_suao_rec.person_id,
                  x_course_cd                    => v_prev_suao_rec.course_cd,
                  x_unit_cd                      => v_prev_suao_rec.unit_cd,
                  x_cal_type                     => v_prev_suao_rec.cal_type,
                  x_ci_sequence_number           => v_prev_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => SYSDATE,
                  x_ci_start_dt                  => v_prev_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_prev_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_prev_suao_rec.grading_schema_cd,
                  x_version_number               => v_prev_suao_rec.version_number,
                  x_grade                        => v_prev_suao_rec.repeat_grade,
                  x_attribute_category           => v_prev_suao_rec.attribute_category,
                  x_attribute1                   => v_prev_suao_rec.attribute1,
                  x_attribute2                   => v_prev_suao_rec.attribute2,
                  x_attribute3                   => v_prev_suao_rec.attribute3,
                  x_attribute4                   => v_prev_suao_rec.attribute4,
                  x_attribute5                   => v_prev_suao_rec.attribute5,
                  x_attribute6                   => v_prev_suao_rec.attribute6,
                  x_attribute7                   => v_prev_suao_rec.attribute7,
                  x_attribute8                   => v_prev_suao_rec.attribute8,
                  x_attribute9                   => v_prev_suao_rec.attribute9,
                  x_attribute10                  => v_prev_suao_rec.attribute10,
                  x_attribute11                  => v_prev_suao_rec.attribute11,
                  x_attribute12                  => v_prev_suao_rec.attribute12,
                  x_attribute13                  => v_prev_suao_rec.attribute13,
                  x_attribute14                  => v_prev_suao_rec.attribute14,
                  x_attribute15                  => v_prev_suao_rec.attribute15,
                  x_attribute16                  => v_prev_suao_rec.attribute16,
                  x_attribute17                  => v_prev_suao_rec.attribute17,
                  x_attribute18                  => v_prev_suao_rec.attribute18,
                  x_attribute19                  => v_prev_suao_rec.attribute19,
                  x_attribute20                  => v_prev_suao_rec.attribute20,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_mark                         => v_prev_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_prev_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_prev_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_prev_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_prev_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_prev_suao_rec.incomp_default_mark,
                  x_comments                     => v_prev_suao_rec.comments,
                  x_uoo_id                       => v_prev_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_prev_suao_rec.mark_capped_flag,
                  x_release_date                 => v_prev_suao_rec.release_date,
                  x_manual_override_flag         => v_prev_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_prev_suao_rec.show_on_academic_histry_flag
                );
              END IF;
            END LOOP;
          ELSIF  v_use_best_grade_attempt = 'Y'
                 AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
            --
            -- The best outcome is considered to be the outcome with the
            -- any other outcomes with valid repeat grades should be set to that
            -- repeat grade.
            --
            FOR v_prev_suao_rec IN c_prev_suao (
                                     v_suao_rec.person_id,
                                     v_suao_rec.unit_cd,
                                     v_suao_rec.course_cd,
                                     v_suao_rec.cal_type,
                                     v_suao_rec.ci_sequence_number
                                   ) LOOP
              -- Determine the best rank for a previous outcome
              IF NVL (v_best_prev_rank, 9999) < v_prev_suao_rec.RANK THEN
                v_best_prev_rank := v_prev_suao_rec.RANK;
                v_best_prev_ci_end_dt := v_prev_suao_rec.ci_end_dt;
              END IF;
              IF  v_prev_suao_rec.repeat_grade IS NOT NULL
                  AND (v_prev_suao_rec.RANK >= v_suao_rec.RANK
                       OR (v_prev_suao_rec.RANK >= v_best_prev_rank
                           AND v_prev_suao_rec.ci_end_dt < v_best_prev_ci_end_dt
                          )
                      ) THEN
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_prev_suao_rec.person_id,
                  v_prev_suao_rec.course_cd,
                  v_prev_suao_rec.unit_cd,
                  v_prev_suao_rec.cal_type,
                  v_prev_suao_rec.ci_sequence_number,
                  v_prev_suao_rec.grading_schema_cd,
                  v_prev_suao_rec.version_number,
                  v_prev_suao_rec.repeat_grade,
                  v_prev_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  v_prev_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_prev_suao_rec.person_id,
                  x_course_cd                    => v_prev_suao_rec.course_cd,
                  x_unit_cd                      => v_prev_suao_rec.unit_cd,
                  x_cal_type                     => v_prev_suao_rec.cal_type,
                  x_ci_sequence_number           => v_prev_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => SYSDATE,
                  x_ci_start_dt                  => v_prev_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_prev_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_prev_suao_rec.grading_schema_cd,
                  x_version_number               => v_prev_suao_rec.version_number,
                  x_grade                        => v_prev_suao_rec.repeat_grade,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_attribute_category           => v_prev_suao_rec.attribute_category,
                  x_attribute1                   => v_prev_suao_rec.attribute1,
                  x_attribute2                   => v_prev_suao_rec.attribute2,
                  x_attribute3                   => v_prev_suao_rec.attribute3,
                  x_attribute4                   => v_prev_suao_rec.attribute4,
                  x_attribute5                   => v_prev_suao_rec.attribute5,
                  x_attribute6                   => v_prev_suao_rec.attribute6,
                  x_attribute7                   => v_prev_suao_rec.attribute7,
                  x_attribute8                   => v_prev_suao_rec.attribute8,
                  x_attribute9                   => v_prev_suao_rec.attribute9,
                  x_attribute10                  => v_prev_suao_rec.attribute10,
                  x_attribute11                  => v_prev_suao_rec.attribute11,
                  x_attribute12                  => v_prev_suao_rec.attribute12,
                  x_attribute13                  => v_prev_suao_rec.attribute13,
                  x_attribute14                  => v_prev_suao_rec.attribute14,
                  x_attribute15                  => v_prev_suao_rec.attribute15,
                  x_attribute16                  => v_prev_suao_rec.attribute16,
                  x_attribute17                  => v_prev_suao_rec.attribute17,
                  x_attribute18                  => v_prev_suao_rec.attribute18,
                  x_attribute19                  => v_prev_suao_rec.attribute19,
                  x_attribute20                  => v_prev_suao_rec.attribute20,
                  x_mark                         => v_prev_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_prev_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_prev_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_prev_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_prev_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_prev_suao_rec.incomp_default_mark,
                  x_comments                     => v_prev_suao_rec.comments,
                  x_uoo_id                       => v_prev_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_prev_suao_rec.mark_capped_flag,
                  x_release_date                 => v_prev_suao_rec.release_date,
                  x_manual_override_flag         => v_prev_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_prev_suao_rec.show_on_academic_histry_flag
                );
              ELSIF v_suao_rec.repeat_grade IS NOT NULL THEN
                v_new_outcome_dt := SYSDATE;
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_suao_rec.person_id,
                  v_suao_rec.course_cd,
                  v_suao_rec.unit_cd,
                  v_suao_rec.cal_type,
                  v_suao_rec.ci_sequence_number,
                  v_suao_rec.grading_schema_cd,
                  v_suao_rec.version_number,
                  v_suao_rec.repeat_grade,
                  v_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  v_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_suao_rec.person_id,
                  x_course_cd                    => v_suao_rec.course_cd,
                  x_unit_cd                      => v_suao_rec.unit_cd,
                  x_cal_type                     => v_suao_rec.cal_type,
                  x_ci_sequence_number           => v_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => v_new_outcome_dt,
                  x_ci_start_dt                  => v_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_suao_rec.grading_schema_cd,
                  x_version_number               => v_suao_rec.version_number,
                  x_grade                        => v_suao_rec.repeat_grade,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_attribute_category           => v_suao_rec.attribute_category,
                  x_attribute1                   => v_suao_rec.attribute1,
                  x_attribute2                   => v_suao_rec.attribute2,
                  x_attribute3                   => v_suao_rec.attribute3,
                  x_attribute4                   => v_suao_rec.attribute4,
                  x_attribute5                   => v_suao_rec.attribute5,
                  x_attribute6                   => v_suao_rec.attribute6,
                  x_attribute7                   => v_suao_rec.attribute7,
                  x_attribute8                   => v_suao_rec.attribute8,
                  x_attribute9                   => v_suao_rec.attribute9,
                  x_attribute10                  => v_suao_rec.attribute10,
                  x_attribute11                  => v_suao_rec.attribute11,
                  x_attribute12                  => v_suao_rec.attribute12,
                  x_attribute13                  => v_suao_rec.attribute13,
                  x_attribute14                  => v_suao_rec.attribute14,
                  x_attribute15                  => v_suao_rec.attribute15,
                  x_attribute16                  => v_suao_rec.attribute16,
                  x_attribute17                  => v_suao_rec.attribute17,
                  x_attribute18                  => v_suao_rec.attribute18,
                  x_attribute19                  => v_suao_rec.attribute19,
                  x_attribute20                  => v_suao_rec.attribute20,
                  x_mark                         => v_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_suao_rec.incomp_default_mark,
                  x_comments                     => v_suao_rec.comments,
                  x_uoo_id                       => v_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_suao_rec.mark_capped_flag,
                  x_release_date                 => v_suao_rec.release_date,
                  x_manual_override_flag         => v_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_suao_rec.show_on_academic_histry_flag
                );
              END IF;
            END LOOP;
          END IF;
        END IF;
        --
        -- Translation and Finalisation
        -- If a new outcome has not been inserted translate and finalise the
        -- current outcome.
        --
        IF v_new_outcome_dt IS NULL THEN
          --
          -- Perform grade translation before updating
          --
          get_translated_grade (
            v_suao_rec.person_id,
            v_suao_rec.course_cd,
            v_suao_rec.unit_cd,
            v_suao_rec.cal_type,
            v_suao_rec.ci_sequence_number,
            v_suao_rec.grading_schema_cd,
            v_suao_rec.version_number,
            v_suao_rec.grade,
            v_suao_rec.mark,
            v_translated_grading_schema_cd,
            v_translated_version_number,
            v_translated_grade,
            v_translated_dt,
            v_suao_rec.uoo_id
          );
          --
          -- Update the current outcome to finlise and set translated grade
          --
          igs_as_su_stmptout_pkg.update_row (
            x_rowid                        => v_suao_rec.ROWID,
            x_person_id                    => v_suao_rec.person_id,
            x_course_cd                    => v_suao_rec.course_cd,
            x_unit_cd                      => v_suao_rec.unit_cd,
            x_cal_type                     => v_suao_rec.cal_type,
            x_ci_sequence_number           => v_suao_rec.ci_sequence_number,
            x_outcome_dt                   => v_new_outcome_dt,
            x_ci_start_dt                  => v_suao_rec.ci_start_dt,
            x_ci_end_dt                    => v_suao_rec.ci_end_dt,
            x_grading_schema_cd            => v_suao_rec.grading_schema_cd,
            x_version_number               => v_suao_rec.version_number,
            x_grade                        => v_suao_rec.grade,
            x_s_grade_creation_method_type => v_suao_rec.s_grade_creation_method_type,
            x_finalised_outcome_ind        => 'Y',
            x_mark                         => v_suao_rec.mark,
            x_number_times_keyed           => NULL,
            x_translated_grading_schema_cd => v_translated_grading_schema_cd,
            x_translated_version_number    => v_translated_version_number,
            x_translated_grade             => v_translated_grade,
            x_translated_dt                => v_translated_dt,
            x_mode                         => 'R',
            x_grading_period_cd            => 'FINAL',
            x_attribute_category           => v_suao_rec.attribute_category,
            x_attribute1                   => v_suao_rec.attribute1,
            x_attribute2                   => v_suao_rec.attribute2,
            x_attribute3                   => v_suao_rec.attribute3,
            x_attribute4                   => v_suao_rec.attribute4,
            x_attribute5                   => v_suao_rec.attribute5,
            x_attribute6                   => v_suao_rec.attribute6,
            x_attribute7                   => v_suao_rec.attribute7,
            x_attribute8                   => v_suao_rec.attribute8,
            x_attribute9                   => v_suao_rec.attribute9,
            x_attribute10                  => v_suao_rec.attribute10,
            x_attribute11                  => v_suao_rec.attribute11,
            x_attribute12                  => v_suao_rec.attribute12,
            x_attribute13                  => v_suao_rec.attribute13,
            x_attribute14                  => v_suao_rec.attribute14,
            x_attribute15                  => v_suao_rec.attribute15,
            x_attribute16                  => v_suao_rec.attribute16,
            x_attribute17                  => v_suao_rec.attribute17,
            x_attribute18                  => v_suao_rec.attribute18,
            x_attribute19                  => v_suao_rec.attribute19,
            x_attribute20                  => v_suao_rec.attribute20,
            x_incomp_deadline_date         => v_suao_rec.incomp_deadline_date,
            x_incomp_grading_schema_cd     => v_suao_rec.incomp_grading_schema_cd,
            x_incomp_version_number        => v_suao_rec.incomp_version_number,
            x_incomp_default_grade         => v_suao_rec.incomp_default_grade,
            x_incomp_default_mark          => v_suao_rec.incomp_default_mark,
            x_comments                     => v_suao_rec.comments,
            x_uoo_id                       => v_suao_rec.uoo_id,
            x_mark_capped_flag             => v_suao_rec.mark_capped_flag,
            x_release_date                 => v_suao_rec.release_date,
            x_manual_override_flag         => v_suao_rec.manual_override_flag,
            x_show_on_academic_histry_flag => v_suao_rec.show_on_academic_histry_flag
          );
        END IF;
      END LOOP;
    ELSE -- IF p_person_id IS NOT NULL THEN
      FOR v_suao_rec IN c_suao_with_uoo LOOP
        v_new_outcome_dt := NULL;
        --
        -- Repeat Processing
        -- If External Formula is set call Repeat Processing User Hook and exit
        --
        IF  v_external_formula = 'Y'
            AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
          igs_as_user_repeat.user_repeat_process (
            v_suao_rec.person_id,
            v_suao_rec.course_cd,
            v_suao_rec.unit_cd,
            v_suao_rec.cal_type,
            v_suao_rec.ci_sequence_number,
            v_suao_rec.outcome_dt,
            v_suao_rec.grading_schema_cd,
            v_suao_rec.version_number,
            v_suao_rec.grade,
            -- anilk, 22-Apr-2003, Bug# 2829262
            v_suao_rec.uoo_id
          );
        ELSE
          IF  v_use_most_recent_unit_attempt = 'Y'
              AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
            --
            -- The current outcome is considered to be the most recent outcome so
            -- any other outcomes with valid repeat grades should be set to that
            -- repeat grade.
            --
            FOR v_prev_suao_rec IN c_prev_suao (
                                     v_suao_rec.person_id,
                                     v_suao_rec.unit_cd,
                                     v_suao_rec.course_cd,
                                     v_suao_rec.cal_type,
                                     v_suao_rec.ci_sequence_number
                                   ) LOOP
              IF v_prev_suao_rec.repeat_grade IS NOT NULL THEN
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_prev_suao_rec.person_id,
                  v_prev_suao_rec.course_cd,
                  v_prev_suao_rec.unit_cd,
                  v_prev_suao_rec.cal_type,
                  v_prev_suao_rec.ci_sequence_number,
                  v_prev_suao_rec.grading_schema_cd,
                  v_prev_suao_rec.version_number,
                  v_prev_suao_rec.repeat_grade,
                  v_prev_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  -- anilk, 22-Apr-2003, Bug# 2829262
                  v_prev_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_prev_suao_rec.person_id,
                  x_course_cd                    => v_prev_suao_rec.course_cd,
                  x_unit_cd                      => v_prev_suao_rec.unit_cd,
                  x_cal_type                     => v_prev_suao_rec.cal_type,
                  x_ci_sequence_number           => v_prev_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => SYSDATE,
                  x_ci_start_dt                  => v_prev_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_prev_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_prev_suao_rec.grading_schema_cd,
                  x_version_number               => v_prev_suao_rec.version_number,
                  x_grade                        => v_prev_suao_rec.repeat_grade,
                  x_attribute_category           => v_prev_suao_rec.attribute_category,
                  x_attribute1                   => v_prev_suao_rec.attribute1,
                  x_attribute2                   => v_prev_suao_rec.attribute2,
                  x_attribute3                   => v_prev_suao_rec.attribute3,
                  x_attribute4                   => v_prev_suao_rec.attribute4,
                  x_attribute5                   => v_prev_suao_rec.attribute5,
                  x_attribute6                   => v_prev_suao_rec.attribute6,
                  x_attribute7                   => v_prev_suao_rec.attribute7,
                  x_attribute8                   => v_prev_suao_rec.attribute8,
                  x_attribute9                   => v_prev_suao_rec.attribute9,
                  x_attribute10                  => v_prev_suao_rec.attribute10,
                  x_attribute11                  => v_prev_suao_rec.attribute11,
                  x_attribute12                  => v_prev_suao_rec.attribute12,
                  x_attribute13                  => v_prev_suao_rec.attribute13,
                  x_attribute14                  => v_prev_suao_rec.attribute14,
                  x_attribute15                  => v_prev_suao_rec.attribute15,
                  x_attribute16                  => v_prev_suao_rec.attribute16,
                  x_attribute17                  => v_prev_suao_rec.attribute17,
                  x_attribute18                  => v_prev_suao_rec.attribute18,
                  x_attribute19                  => v_prev_suao_rec.attribute19,
                  x_attribute20                  => v_prev_suao_rec.attribute20,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_mark                         => v_prev_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_prev_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_prev_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_prev_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_prev_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_prev_suao_rec.incomp_default_mark,
                  x_comments                     => v_prev_suao_rec.comments,
                  x_uoo_id                       => v_prev_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_prev_suao_rec.mark_capped_flag,
                  x_release_date                 => v_prev_suao_rec.release_date,
                  x_manual_override_flag         => v_prev_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_prev_suao_rec.show_on_academic_histry_flag
                );
              END IF;
            END LOOP;
          ELSIF  v_use_best_grade_attempt = 'Y'
                 AND NVL (v_repeatable_ind, 'Y') = 'N' THEN
            --
            -- The best outcome is considered to be the outcome with the
            -- any other outcomes with valid repeat grades should be set to that
            -- repeat grade.
            --
            FOR v_prev_suao_rec IN c_prev_suao (
                                     v_suao_rec.person_id,
                                     v_suao_rec.unit_cd,
                                     v_suao_rec.course_cd,
                                     v_suao_rec.cal_type,
                                     v_suao_rec.ci_sequence_number
                                   ) LOOP
              -- Determine the best rank for a previous outcome
              IF NVL (v_best_prev_rank, 9999) < v_prev_suao_rec.RANK THEN
                v_best_prev_rank := v_prev_suao_rec.RANK;
                v_best_prev_ci_end_dt := v_prev_suao_rec.ci_end_dt;
              END IF;
              IF  v_prev_suao_rec.repeat_grade IS NOT NULL
                  AND (v_prev_suao_rec.RANK >= v_suao_rec.RANK
                       OR (v_prev_suao_rec.RANK >= v_best_prev_rank
                           AND v_prev_suao_rec.ci_end_dt < v_best_prev_ci_end_dt
                          )
                      ) THEN
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_prev_suao_rec.person_id,
                  v_prev_suao_rec.course_cd,
                  v_prev_suao_rec.unit_cd,
                  v_prev_suao_rec.cal_type,
                  v_prev_suao_rec.ci_sequence_number,
                  v_prev_suao_rec.grading_schema_cd,
                  v_prev_suao_rec.version_number,
                  v_prev_suao_rec.repeat_grade,
                  v_prev_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  v_prev_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_prev_suao_rec.person_id,
                  x_course_cd                    => v_prev_suao_rec.course_cd,
                  x_unit_cd                      => v_prev_suao_rec.unit_cd,
                  x_cal_type                     => v_prev_suao_rec.cal_type,
                  x_ci_sequence_number           => v_prev_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => SYSDATE,
                  x_ci_start_dt                  => v_prev_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_prev_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_prev_suao_rec.grading_schema_cd,
                  x_version_number               => v_prev_suao_rec.version_number,
                  x_grade                        => v_prev_suao_rec.repeat_grade,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_attribute_category           => v_prev_suao_rec.attribute_category,
                  x_attribute1                   => v_prev_suao_rec.attribute1,
                  x_attribute2                   => v_prev_suao_rec.attribute2,
                  x_attribute3                   => v_prev_suao_rec.attribute3,
                  x_attribute4                   => v_prev_suao_rec.attribute4,
                  x_attribute5                   => v_prev_suao_rec.attribute5,
                  x_attribute6                   => v_prev_suao_rec.attribute6,
                  x_attribute7                   => v_prev_suao_rec.attribute7,
                  x_attribute8                   => v_prev_suao_rec.attribute8,
                  x_attribute9                   => v_prev_suao_rec.attribute9,
                  x_attribute10                  => v_prev_suao_rec.attribute10,
                  x_attribute11                  => v_prev_suao_rec.attribute11,
                  x_attribute12                  => v_prev_suao_rec.attribute12,
                  x_attribute13                  => v_prev_suao_rec.attribute13,
                  x_attribute14                  => v_prev_suao_rec.attribute14,
                  x_attribute15                  => v_prev_suao_rec.attribute15,
                  x_attribute16                  => v_prev_suao_rec.attribute16,
                  x_attribute17                  => v_prev_suao_rec.attribute17,
                  x_attribute18                  => v_prev_suao_rec.attribute18,
                  x_attribute19                  => v_prev_suao_rec.attribute19,
                  x_attribute20                  => v_prev_suao_rec.attribute20,
                  x_mark                         => v_prev_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_prev_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_prev_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_prev_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_prev_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_prev_suao_rec.incomp_default_mark,
                  x_comments                     => v_prev_suao_rec.comments,
                  x_uoo_id                       => v_prev_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_prev_suao_rec.mark_capped_flag,
                  x_release_date                 => v_prev_suao_rec.release_date,
                  x_manual_override_flag         => v_prev_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_prev_suao_rec.show_on_academic_histry_flag
                );
              ELSIF v_suao_rec.repeat_grade IS NOT NULL THEN
                v_new_outcome_dt := SYSDATE;
                --
                -- Perform grade translation before inserting
                --
                get_translated_grade (
                  v_suao_rec.person_id,
                  v_suao_rec.course_cd,
                  v_suao_rec.unit_cd,
                  v_suao_rec.cal_type,
                  v_suao_rec.ci_sequence_number,
                  v_suao_rec.grading_schema_cd,
                  v_suao_rec.version_number,
                  v_suao_rec.repeat_grade,
                  v_suao_rec.mark,
                  v_translated_grading_schema_cd,
                  v_translated_version_number,
                  v_translated_grade,
                  v_translated_dt,
                  v_suao_rec.uoo_id
                );
                --
                -- Insert new outcome with repeat grade
                --
                igs_as_su_stmptout_pkg.insert_row (
                  x_rowid                        => v_rowid,
                  x_org_id                       => NULL,
                  x_person_id                    => v_suao_rec.person_id,
                  x_course_cd                    => v_suao_rec.course_cd,
                  x_unit_cd                      => v_suao_rec.unit_cd,
                  x_cal_type                     => v_suao_rec.cal_type,
                  x_ci_sequence_number           => v_suao_rec.ci_sequence_number,
                  x_outcome_dt                   => v_new_outcome_dt,
                  x_ci_start_dt                  => v_suao_rec.ci_start_dt,
                  x_ci_end_dt                    => v_suao_rec.ci_end_dt,
                  x_grading_schema_cd            => v_suao_rec.grading_schema_cd,
                  x_version_number               => v_suao_rec.version_number,
                  x_grade                        => v_suao_rec.repeat_grade,
                  x_s_grade_creation_method_type => 'SYSTEM',
                  x_finalised_outcome_ind        => 'Y',
                  x_attribute_category           => v_suao_rec.attribute_category,
                  x_attribute1                   => v_suao_rec.attribute1,
                  x_attribute2                   => v_suao_rec.attribute2,
                  x_attribute3                   => v_suao_rec.attribute3,
                  x_attribute4                   => v_suao_rec.attribute4,
                  x_attribute5                   => v_suao_rec.attribute5,
                  x_attribute6                   => v_suao_rec.attribute6,
                  x_attribute7                   => v_suao_rec.attribute7,
                  x_attribute8                   => v_suao_rec.attribute8,
                  x_attribute9                   => v_suao_rec.attribute9,
                  x_attribute10                  => v_suao_rec.attribute10,
                  x_attribute11                  => v_suao_rec.attribute11,
                  x_attribute12                  => v_suao_rec.attribute12,
                  x_attribute13                  => v_suao_rec.attribute13,
                  x_attribute14                  => v_suao_rec.attribute14,
                  x_attribute15                  => v_suao_rec.attribute15,
                  x_attribute16                  => v_suao_rec.attribute16,
                  x_attribute17                  => v_suao_rec.attribute17,
                  x_attribute18                  => v_suao_rec.attribute18,
                  x_attribute19                  => v_suao_rec.attribute19,
                  x_attribute20                  => v_suao_rec.attribute20,
                  x_mark                         => v_suao_rec.mark,
                  x_number_times_keyed           => NULL,
                  x_translated_grading_schema_cd => v_translated_grading_schema_cd,
                  x_translated_version_number    => v_translated_version_number,
                  x_translated_grade             => v_translated_grade,
                  x_translated_dt                => v_translated_dt,
                  x_mode                         => 'R',
                  x_grading_period_cd            => 'FINAL',
                  x_incomp_deadline_date         => v_suao_rec.incomp_deadline_date,
                  x_incomp_grading_schema_cd     => v_suao_rec.incomp_grading_schema_cd,
                  x_incomp_version_number        => v_suao_rec.incomp_version_number,
                  x_incomp_default_grade         => v_suao_rec.incomp_default_grade,
                  x_incomp_default_mark          => v_suao_rec.incomp_default_mark,
                  x_comments                     => v_suao_rec.comments,
                  x_uoo_id                       => v_suao_rec.uoo_id,
                  x_mark_capped_flag             => v_suao_rec.mark_capped_flag,
                  x_release_date                 => v_suao_rec.release_date,
                  x_manual_override_flag         => v_suao_rec.manual_override_flag,
                  x_show_on_academic_histry_flag => v_suao_rec.show_on_academic_histry_flag
                );
              END IF;
            END LOOP;
          END IF;
        END IF;
        --
        -- Translation and Finalisation
        -- If a new outcome has not been inserted translate and finalise the
        -- current outcome.
        --
        IF v_new_outcome_dt IS NULL THEN
          --
          -- Perform grade translation before updating
          --
          get_translated_grade (
            v_suao_rec.person_id,
            v_suao_rec.course_cd,
            v_suao_rec.unit_cd,
            v_suao_rec.cal_type,
            v_suao_rec.ci_sequence_number,
            v_suao_rec.grading_schema_cd,
            v_suao_rec.version_number,
            v_suao_rec.grade,
            v_suao_rec.mark,
            v_translated_grading_schema_cd,
            v_translated_version_number,
            v_translated_grade,
            v_translated_dt,
            v_suao_rec.uoo_id
          );
          --
          -- Update the current outcome to finlise and set translated grade
          --
          igs_as_su_stmptout_pkg.update_row (
            x_rowid                        => v_suao_rec.ROWID,
            x_person_id                    => v_suao_rec.person_id,
            x_course_cd                    => v_suao_rec.course_cd,
            x_unit_cd                      => v_suao_rec.unit_cd,
            x_cal_type                     => v_suao_rec.cal_type,
            x_ci_sequence_number           => v_suao_rec.ci_sequence_number,
            x_outcome_dt                   => v_new_outcome_dt,
            x_ci_start_dt                  => v_suao_rec.ci_start_dt,
            x_ci_end_dt                    => v_suao_rec.ci_end_dt,
            x_grading_schema_cd            => v_suao_rec.grading_schema_cd,
            x_version_number               => v_suao_rec.version_number,
            x_grade                        => v_suao_rec.grade,
            x_s_grade_creation_method_type => v_suao_rec.s_grade_creation_method_type,
            x_finalised_outcome_ind        => 'Y',
            x_mark                         => v_suao_rec.mark,
            x_number_times_keyed           => NULL,
            x_translated_grading_schema_cd => v_translated_grading_schema_cd,
            x_translated_version_number    => v_translated_version_number,
            x_translated_grade             => v_translated_grade,
            x_translated_dt                => v_translated_dt,
            x_mode                         => 'R',
            x_grading_period_cd            => 'FINAL',
            x_attribute_category           => v_suao_rec.attribute_category,
            x_attribute1                   => v_suao_rec.attribute1,
            x_attribute2                   => v_suao_rec.attribute2,
            x_attribute3                   => v_suao_rec.attribute3,
            x_attribute4                   => v_suao_rec.attribute4,
            x_attribute5                   => v_suao_rec.attribute5,
            x_attribute6                   => v_suao_rec.attribute6,
            x_attribute7                   => v_suao_rec.attribute7,
            x_attribute8                   => v_suao_rec.attribute8,
            x_attribute9                   => v_suao_rec.attribute9,
            x_attribute10                  => v_suao_rec.attribute10,
            x_attribute11                  => v_suao_rec.attribute11,
            x_attribute12                  => v_suao_rec.attribute12,
            x_attribute13                  => v_suao_rec.attribute13,
            x_attribute14                  => v_suao_rec.attribute14,
            x_attribute15                  => v_suao_rec.attribute15,
            x_attribute16                  => v_suao_rec.attribute16,
            x_attribute17                  => v_suao_rec.attribute17,
            x_attribute18                  => v_suao_rec.attribute18,
            x_attribute19                  => v_suao_rec.attribute19,
            x_attribute20                  => v_suao_rec.attribute20,
            x_incomp_deadline_date         => v_suao_rec.incomp_deadline_date,
            x_incomp_grading_schema_cd     => v_suao_rec.incomp_grading_schema_cd,
            x_incomp_version_number        => v_suao_rec.incomp_version_number,
            x_incomp_default_grade         => v_suao_rec.incomp_default_grade,
            x_incomp_default_mark          => v_suao_rec.incomp_default_mark,
            x_comments                     => v_suao_rec.comments,
            x_uoo_id                       => v_suao_rec.uoo_id,
            x_mark_capped_flag             => v_suao_rec.mark_capped_flag,
            x_release_date                 => v_suao_rec.release_date,
            x_manual_override_flag         => v_suao_rec.manual_override_flag,
            x_show_on_academic_histry_flag => v_suao_rec.show_on_academic_histry_flag
          );
        END IF;
      END LOOP;
    END IF;-- IF p_person_id IS NOT NULL THEN
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO s_before_finalize;
        app_exception.raise_exception;
    END;
  END finalize_process_no_commit;


  PROCEDURE finalize_process (
    p_uoo_id                       IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_ci_sequence_number     IN     NUMBER
  ) IS
  BEGIN
	finalize_process_no_commit (
	    p_uoo_id                   => p_uoo_id                  ,
	    p_person_id                => p_person_id               ,
	    p_course_cd                => p_course_cd               ,
	    p_unit_cd                  => p_unit_cd                 ,
	    p_teach_cal_type           => p_teach_cal_type          ,
	    p_teach_ci_sequence_number => p_teach_ci_sequence_number
	  ) ;
	  commit;

  END finalize_process;


  --
  --
  --
  PROCEDURE get_translated_grade (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_cal_type               IN     VARCHAR2,
    p_teach_ci_sequence_number     IN     NUMBER,
    p_grading_schema_cd            IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_grade                        IN     VARCHAR2,
    p_mark                         IN     NUMBER,
    p_translated_grading_schema_cd OUT NOCOPY VARCHAR2,
    p_translated_version_number    OUT NOCOPY NUMBER,
    p_translated_grade             OUT NOCOPY VARCHAR2,
    p_translated_dt                OUT NOCOPY DATE,
    -- anilk, 22-Apr-2003, Bug# 2829262
    p_uoo_id                       IN     NUMBER
  ) IS
  BEGIN -- get_translated_grade
    --
    -- Process to determines the translated grade, if any,
    -- for a given Student Unit Attempt Outcome
    --
    DECLARE
      v_message_name            VARCHAR2 (30)                                  DEFAULT NULL;
      v_acad_cal_type           igs_ca_inst.cal_type%TYPE;
      v_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
      v_acad_ci_start_dt        igs_ca_inst.start_dt%TYPE;
      v_acad_ci_end_dt          igs_ca_inst.end_dt%TYPE;
      v_alt_cd                  igs_ca_inst.alternate_code%TYPE;
      v_pop_grading_schema_cd   igs_ps_ofr_pat.grading_schema_cd%TYPE;
      v_pop_gs_version_number   igs_ps_ofr_pat.gs_version_number%TYPE;
      v_gsgt_to_grade           igs_as_grd_sch_trn.to_grade%TYPE;
      v_key_allow_invalid_ind   igs_as_entry_conf.key_allow_invalid_ind%TYPE;
      CURSOR c_sua_sca_uoo_pop (
        cp_acad_cal_type                      igs_ca_inst.cal_type%TYPE,
        cp_acad_ci_sequence_number            igs_ca_inst.sequence_number%TYPE
      ) IS
        SELECT gs.grading_schema_cd,
               gs.version_number,
               ec.key_allow_invalid_ind
        FROM   igs_en_su_attempt sua,
               igs_en_stdnt_ps_att spa,
               igs_ps_unit_ofr_opt uoo,
               igs_as_grd_schema gs,
               igs_as_entry_conf ec
        WHERE  sua.person_id = p_person_id
        AND    sua.course_cd = p_course_cd
        AND    sua.unit_cd = p_unit_cd
        AND    sua.cal_type = p_teach_cal_type
        AND    sua.ci_sequence_number = p_teach_ci_sequence_number
        AND    uoo.uoo_id = sua.uoo_id
        -- anilk, 22-Apr-2003, Bug# 2829262
        AND    sua.uoo_id = p_uoo_id
        AND    spa.person_id = sua.person_id
        AND    spa.course_cd = sua.course_cd
        AND    (EXISTS ( SELECT 'X'
                         FROM   igs_ps_ofr_pat pop
                         WHERE  pop.coo_id = spa.coo_id
                         AND    pop.cal_type = cp_acad_cal_type
                         AND    pop.ci_sequence_number = cp_acad_ci_sequence_number
                         AND    uoo.grading_schema_prcdnce_ind = 'N'
                         AND    pop.grading_schema_cd IS NOT NULL
                         AND    pop.gs_version_number IS NOT NULL
                         AND    sua.grading_schema_code IS NULL
                         AND    sua.gs_version_number IS NULL
                         AND    pop.grading_schema_cd = gs.grading_schema_cd
                         AND    pop.gs_version_number = gs.version_number)
                OR (sua.grading_schema_code = gs.grading_schema_cd
                    AND sua.gs_version_number = gs.version_number
                   )
               )
        AND    ec.s_control_num = 1;
      --
      --
      --
      CURSOR c_gsgt (
        cp_pop_grading_schema_cd              igs_ps_ofr_pat.grading_schema_cd%TYPE,
        cp_pop_gs_version_number              igs_ps_ofr_pat.gs_version_number%TYPE
      ) IS
        SELECT gsgt.to_grade
        FROM   igs_as_grd_sch_trn gsgt
        WHERE  gsgt.grading_schema_cd = p_grading_schema_cd
        AND    gsgt.version_number = p_version_number
        AND    gsgt.grade = p_grade
        AND    gsgt.to_grading_schema_cd = cp_pop_grading_schema_cd
        AND    gsgt.to_version_number = cp_pop_gs_version_number;
    BEGIN
      --
      -- Translation
      -- Verify that the IGS_PS_UNIT_OFR_OPT.grading_schema_prcdnce_ind = 'N' and
      -- that IGS_PS_OFR_PAT.grading_schema_cd is not null for the student
      -- unit attempt and get the IGS_PS_COURSE offering pattern grading schema that will
      -- be used in the translation. Otherwise return NULL as no translation possible.
      --
      p_translated_dt := SYSDATE;
      --
      -- Determine the academic period for the student.
      --
      v_alt_cd := igs_en_gen_002.enrp_get_acad_alt_cd (
                    p_teach_cal_type,
                    p_teach_ci_sequence_number,
                    v_acad_cal_type,
                    v_acad_ci_sequence_number,
                    v_acad_ci_start_dt,
                    v_acad_ci_end_dt,
                    v_message_name
                  );
      IF v_message_name IS NOT NULL THEN
      --
      -- Unable to determine the academic period.
      --
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
        RETURN;
      END IF;
      OPEN c_sua_sca_uoo_pop (v_acad_cal_type, v_acad_ci_sequence_number);
      FETCH c_sua_sca_uoo_pop INTO v_pop_grading_schema_cd,
                                   v_pop_gs_version_number,
                                   v_key_allow_invalid_ind;
      IF c_sua_sca_uoo_pop%FOUND THEN
        CLOSE c_sua_sca_uoo_pop;
        OPEN c_gsgt (v_pop_grading_schema_cd, v_pop_gs_version_number);
        FETCH c_gsgt INTO v_gsgt_to_grade;
        IF c_gsgt%FOUND THEN
          CLOSE c_gsgt;
          --
          -- Validate the mark and grade combination are valid.
          --
          IF v_key_allow_invalid_ind = 'Y'
             OR igs_as_val_suao.assp_val_mark_grade (
                  p_mark,
                  p_grade,
                  p_grading_schema_cd,
                  p_version_number,
                  v_message_name
                ) THEN
            p_translated_grading_schema_cd := v_pop_grading_schema_cd;
            p_translated_version_number := v_pop_gs_version_number;
            p_translated_grade := v_gsgt_to_grade;
          END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AS_FINALIZE_GRADE.get_translated_grade');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END get_translated_grade;
END igs_as_finalize_grade;

/
