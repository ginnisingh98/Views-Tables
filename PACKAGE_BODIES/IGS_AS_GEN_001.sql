--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_001" AS
/* $Header: IGSAS01B.pls 120.0 2005/07/05 11:41:04 appldev noship $ */
/*======================================================================+
 |                                                                      |
 | DESCRIPTION                                                          |
 |      PL/SQL boby for package: igs_as_gen_001                         |
 |                                                                      |
 | NOTES                                                                |
 |                                                                      |
 | CHANGE HISTORY                                                       |
 +======================================================================+
 | WHO         WHEN            WHAT                                     |
 +======================================================================+
 | Nalin Kumar 24-May-2003     Modified the call to the igs_as_su_atmpt_itm_pkg;
 |                             Added two new parameters x_unit_section_ass_item_id and x_unit_ass_item_id in the call;
 |                             This is as per 'Assessment Item description Build'; Bug# 2829291;
 +======================================================================+*/
  --
  --
  --
  FUNCTION assp_clc_esu_ese_num (
    p_person_id                    IN NUMBER,
    p_exam_cal_type                IN VARCHAR2,
    p_exam_ci_sequence_number      IN NUMBER
  ) RETURN NUMBER IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_clc_esu_ese_num
    -- Calculate the number of  distinct sessions for which a IGS_PE_PERSON has been a
    -- supervisor.
    -- If the exam period is specified (cal_type, ci_sequence_number), then
    -- determine the count for that period, otherwise count the number of
    -- sessions supervised prior to the current date.
    DECLARE
      v_sysdate         DATE;
      v_session_count   NUMBER                                              := 0;
      v_exam_cal_type   igs_as_exm_ins_spvsr.exam_cal_type%TYPE;
      v_exam_ci_seq_num igs_as_exm_ins_spvsr.exam_ci_sequence_number%TYPE;
      v_dt_alias        igs_as_exm_ins_spvsr.dt_alias%TYPE;
      v_dai_seq_num     igs_as_exm_ins_spvsr.dai_sequence_number%TYPE;
      v_start_time      igs_as_exm_ins_spvsr.start_time%TYPE;
      v_end_time        igs_as_exm_ins_spvsr.end_time%TYPE;
      --
      CURSOR c_ese IS
        SELECT DISTINCT eis.exam_cal_type,
                        eis.exam_ci_sequence_number,
                        eis.dt_alias,
                        eis.dai_sequence_number,
                        eis.start_time,
                        eis.end_time
        FROM            igs_as_exm_ins_spvsr eis,
                        igs_as_exam_session_v esev
        WHERE           eis.person_id = p_person_id
        AND             eis.exam_cal_type = esev.exam_cal_type
        AND             eis.exam_ci_sequence_number = esev.exam_ci_sequence_number
        AND             eis.dt_alias = esev.dt_alias
        AND             eis.dai_sequence_number = esev.dai_sequence_number
        AND             eis.start_time = esev.start_time
        AND             ((NVL (p_exam_cal_type, 'NULL') = 'NULL')
                         OR (eis.exam_cal_type = p_exam_cal_type)
                        )
        AND             ((NVL (p_exam_ci_sequence_number, 0) = 0)
                         OR (eis.exam_ci_sequence_number = p_exam_ci_sequence_number)
                        )
        AND             esev.alias_val < v_sysdate
        UNION
        SELECT DISTINCT esvs.exam_cal_type,
                        esvs.exam_ci_sequence_number,
                        esvs.dt_alias,
                        esvs.dai_sequence_number,
                        esvs.start_time,
                        esvs.end_time
        FROM            igs_as_exm_ses_vn_sp esvs,
                        igs_as_exam_session_v esev
        WHERE           esvs.person_id = p_person_id
        AND             esvs.exam_cal_type = esev.exam_cal_type
        AND             esvs.exam_ci_sequence_number = esev.exam_ci_sequence_number
        AND             esvs.dt_alias = esev.dt_alias
        AND             esvs.dai_sequence_number = esev.dai_sequence_number
        AND             esvs.start_time = esev.start_time
        AND             ((NVL (p_exam_cal_type, 'NULL') = 'NULL')
                         OR (esvs.exam_cal_type = p_exam_cal_type)
                        )
        AND             ((NVL (p_exam_ci_sequence_number, 0) = 0)
                         OR (esvs.exam_ci_sequence_number = p_exam_ci_sequence_number)
                        )
        AND             esev.alias_val < v_sysdate;
    BEGIN
      IF  p_exam_cal_type IS NULL
          AND p_exam_ci_sequence_number IS NULL THEN
        v_sysdate := SYSDATE;
      ELSE
        v_sysdate := igs_ge_date.igsdate ('3000/12/31');
      END IF;
      OPEN c_ese;
      LOOP
        FETCH c_ese INTO v_exam_cal_type,
                         v_exam_ci_seq_num,
                         v_dt_alias,
                         v_dai_seq_num,
                         v_start_time,
                         v_end_time;
        IF (c_ese%NOTFOUND) THEN
          EXIT;
        END IF;
        v_session_count := v_session_count + 1;
      END LOOP;
      CLOSE c_ese;
      RETURN v_session_count;
    END;
  END assp_clc_esu_ese_num;
  --
  --
  --
  FUNCTION assp_clc_suaai_valid (
    p_person_id                    IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_course_cd                    IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_logical_delete_dt            IN     DATE,
    p_uoo_id                       IN     NUMBER
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
    p_message_name  VARCHAR2 (30);
  BEGIN
    IF igs_as_val_suaai.assp_val_suaai_valid (
         p_person_id,
         p_unit_cd,
         p_course_cd,
         p_cal_type,
         p_ci_sequence_number,
         NULL,
         p_ass_id,
         p_logical_delete_dt,
         p_message_name,
         p_uoo_id
       ) = TRUE THEN
      RETURN NULL;
    ELSE
      RETURN 'INVALID';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END assp_clc_suaai_valid;
  --
  --
  --
  FUNCTION assp_clc_week_extnsn (p_week_ending_due_dt IN DATE, p_override_due_dt IN DATE, p_num_week_extnsn IN NUMBER)
    RETURN NUMBER IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_clc_week_extnsn
    -- This module will determine if the dates that are passed in indicate that
    -- there is the specified number of weeks different. It will return 0
    -- (zero) or 1 depending if an override due date matches the parameter
    -- indicating the number of weeks extension.
    -- This module is called from a view suaai_extension_v which is used in the
    -- report "Assignment Due Date Summary Report".
    DECLARE
      v_days_difference NUMBER (5);
    BEGIN
      -- Parameters validation
      IF p_week_ending_due_dt IS NULL
         OR p_override_due_dt IS NULL
         OR p_num_week_extnsn IS NULL THEN
        RETURN 0;
      END IF;
      IF (p_override_due_dt <= p_week_ending_due_dt) THEN
        RETURN 0;
      END IF;
      v_days_difference := TRUNC (p_override_due_dt) - TRUNC (p_week_ending_due_dt);
      IF  p_num_week_extnsn = 1
          AND v_days_difference <= 7 THEN
        RETURN 1;
      ELSIF  p_num_week_extnsn = 2
             AND v_days_difference > 7
             AND v_days_difference <= 14 THEN
        RETURN 1;
      ELSIF  p_num_week_extnsn = 3
             AND v_days_difference > 14 THEN
        -- Want to consider everything >= 3 weeks.
        RETURN 1;
      ELSE
        RETURN 0;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_001.assp_clc_week_extnsn');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_clc_week_extnsn;
  --
  --
  --
  FUNCTION assp_del_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_del_suaai
    -- Delete a student IGS_PS_UNIT attempt item records,
    -- Called when a student has withdrawn from a IGS_PS_UNIT and due to the early
    -- withdrawal, the student IGS_PS_UNIT attempt is deleted.
    DECLARE
      e_resource_busy EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_resource_busy,  -54);
      v_message_name  VARCHAR2 (30);

      CURSOR c_str IS
        SELECT s_student_todo_type,
               sequence_number,
               reference_number
        FROM   igs_pe_std_todo_ref
        WHERE  person_id = p_person_id
        AND    s_student_todo_type IN ('ASS_INSERT', 'ASS_STATUS', 'ASS_CHANGE')
        AND    logical_delete_dt IS NULL
        AND    course_cd = p_course_cd
        AND    uoo_id = p_uoo_id;
      ------------------------------------------------------------------------------
      -- Delete all assessment items assigned to the student.
      ------------------------------------------------------------------------------
      FUNCTION asspl_del_suaai
        RETURN BOOLEAN IS
      BEGIN
        DECLARE
          CURSOR c_del_suaai IS
            SELECT        ROWID,
                          tracking_id
            FROM          igs_as_su_atmpt_itm
            WHERE         person_id = p_person_id
            AND           course_cd = p_course_cd
            AND           uoo_id = p_uoo_id
            FOR UPDATE OF tracking_id NOWAIT;
          c_del_suaai_rec c_del_suaai%ROWTYPE;
        BEGIN
          igs_as_su_atmpt_itm_pkg.delete_row (c_del_suaai_rec.ROWID);
          FOR v_suaai_rec IN c_del_suaai LOOP
            IF (v_suaai_rec.tracking_id IS NOT NULL) THEN
              IF igs_tr_gen_002.trkp_del_tri (v_suaai_rec.tracking_id, v_message_name) = FALSE THEN
                p_message_name := v_message_name;
                EXIT;
              END IF;
            END IF;
          END LOOP;
          IF (v_message_name IS NOT NULL) THEN
            RETURN FALSE;
          END IF;
          RETURN TRUE;
        END;
      EXCEPTION
        WHEN e_resource_busy THEN
          p_message_name := 'IGS_AS_UNABLE_PERFORM_SUAA';
          RETURN FALSE;
        WHEN OTHERS THEN
          fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token ('NAME', 'IGS_AS_GEN_001.ASSPL_DEL_SUAAI');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
      END asspl_del_suaai;
    BEGIN
      p_message_name := NULL;
      SAVEPOINT sp_del_suaai;
      --
      -- Delete all assessment items assigned to the student.
      --
      IF (asspl_del_suaai = FALSE) THEN
        ROLLBACK TO sp_del_suaai;
        RETURN FALSE;
      END IF;
      --
      -- Remove any student todo records associated with the student and this IGS_PS_UNIT.
      --
      FOR v_str_rec IN c_str LOOP
        IF igs_ge_gen_003.genp_upd_str_lgc_del (
             p_person_id,
             v_str_rec.s_student_todo_type,
             v_str_rec.sequence_number,
             v_str_rec.reference_number,
             v_message_name
           ) = FALSE THEN
          --
          -- Do nothing, this is just a tidy up routine,
          -- if the todo record remains, it will never be activated.
          --
          NULL;
        END IF;
      END LOOP;
      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_001.assp_del_suaai');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_del_suaai;
  --
  --
  --
  FUNCTION assp_del_suaai_dflt (
    p_person_id                    IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER ,
    p_unit_ass_id                   IN NUMBER
  ) RETURN BOOLEAN IS
    gv_other_details VARCHAR2 (255);
  BEGIN --assp_del_suaai_dflt
    --
    -- This routine will logically delete stdnt_unit_atmpt_ass_items for the
    -- students IGS_PS_UNIT. If p_ass_id is NULL then logically delete all system
    -- maintained items, otherwise logically delete the student assessment item
    -- regardless of whether it is system assigned.
    --
    DECLARE
      e_resource_busy_exception EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_resource_busy_exception,  -54);
      CURSOR c_suaai IS
        SELECT        suaai.ROWID row_id,
                      suaai.*
        FROM          igs_as_su_atmpt_itm suaai,
                      igs_en_su_attempt_all sua
        WHERE         suaai.person_id = p_person_id
        AND           suaai.course_cd = p_course_cd
        AND           suaai.uoo_id = p_uoo_id
        AND           (((NVL (p_ass_id, 0) = 0)
                        AND suaai.s_default_ind = 'Y'
                       )
                       OR (suaai.ass_id = p_ass_id
		       AND (suaai.unit_section_ass_item_id = p_unit_ass_id
		       OR suaai.unit_ass_item_id = p_unit_ass_id))
                      )
        AND    suaai.logical_delete_dt IS NULL
        AND    sua.person_id = suaai.person_id
        AND    sua.course_cd = suaai.course_cd
        AND    sua.uoo_id = suaai.uoo_id
        AND    sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED');
      c_suaai_rec               c_suaai%ROWTYPE;
    BEGIN
      -- initialise IN OUT NOCOPY parameters if NULL
      p_error_count := NVL (p_error_count, 0);
      p_warning_count := NVL (p_warning_count, 0);
      -- Issue a save point for the module so that if locks
      -- exist, a rollback can be performed.
      SAVEPOINT sp_save_point;
      -- Perform a logical delete of the system defaulted items. If the p_ass_id is
      -- set then update only that item regardless of whether it is a default item,
      -- otherwise update all default items for the student's IGS_PS_UNIT.
      FOR c_suaai_rec IN c_suaai LOOP
        igs_as_su_atmpt_itm_pkg.update_row (
          x_mode                         => 'R',
          x_rowid                        => c_suaai_rec.row_id,
          x_person_id                    => c_suaai_rec.person_id,
          x_course_cd                    => c_suaai_rec.course_cd,
          x_unit_cd                      => c_suaai_rec.unit_cd,
          x_cal_type                     => c_suaai_rec.cal_type,
          x_ci_sequence_number           => c_suaai_rec.ci_sequence_number,
          x_ass_id                       => c_suaai_rec.ass_id,
          x_creation_dt                  => c_suaai_rec.creation_dt,
          x_attempt_number               => c_suaai_rec.attempt_number,
          x_outcome_dt                   => c_suaai_rec.outcome_dt,
          x_override_due_dt              => c_suaai_rec.override_due_dt,
          x_tracking_id                  => c_suaai_rec.tracking_id,
          x_logical_delete_dt            => SYSDATE,
          x_s_default_ind                => c_suaai_rec.s_default_ind,
          x_ass_pattern_id               => c_suaai_rec.ass_pattern_id,
          x_grading_schema_cd            => c_suaai_rec.grading_schema_cd,
          x_gs_version_number            => c_suaai_rec.gs_version_number,
          x_grade                        => c_suaai_rec.grade,
          x_outcome_comment_code         => c_suaai_rec.outcome_comment_code,
          x_mark                         => c_suaai_rec.mark,
          x_attribute_category           => c_suaai_rec.attribute_category,
          x_attribute1                   => c_suaai_rec.attribute1,
          x_attribute2                   => c_suaai_rec.attribute2,
          x_attribute3                   => c_suaai_rec.attribute3,
          x_attribute4                   => c_suaai_rec.attribute4,
          x_attribute5                   => c_suaai_rec.attribute5,
          x_attribute6                   => c_suaai_rec.attribute6,
          x_attribute7                   => c_suaai_rec.attribute7,
          x_attribute8                   => c_suaai_rec.attribute8,
          x_attribute9                   => c_suaai_rec.attribute9,
          x_attribute10                  => c_suaai_rec.attribute10,
          x_attribute11                  => c_suaai_rec.attribute11,
          x_attribute12                  => c_suaai_rec.attribute12,
          x_attribute13                  => c_suaai_rec.attribute13,
          x_attribute14                  => c_suaai_rec.attribute14,
          x_attribute15                  => c_suaai_rec.attribute15,
          x_attribute16                  => c_suaai_rec.attribute16,
          x_attribute17                  => c_suaai_rec.attribute17,
          x_attribute18                  => c_suaai_rec.attribute18,
          x_attribute19                  => c_suaai_rec.attribute19,
          x_attribute20                  => c_suaai_rec.attribute20,
          x_uoo_id                       => c_suaai_rec.uoo_id,
          x_unit_section_ass_item_id     => c_suaai_rec.unit_section_ass_item_id,
          x_unit_ass_item_id             => c_suaai_rec.unit_ass_item_id,
          x_sua_ass_item_group_id        => c_suaai_rec.sua_ass_item_group_id,
          x_midterm_mandatory_type_code  => c_suaai_rec.midterm_mandatory_type_code,
          x_midterm_weight_qty           => c_suaai_rec.midterm_weight_qty,
          x_final_mandatory_type_code    => c_suaai_rec.final_mandatory_type_code,
          x_final_weight_qty             => c_suaai_rec.final_weight_qty,
          x_submitted_date               => c_suaai_rec.submitted_date,
          x_waived_flag                  => c_suaai_rec.waived_flag,
          x_penalty_applied_flag         => c_suaai_rec.penalty_applied_flag
        );
        IF c_suaai_rec.grade IS NOT NULL THEN
          --
          -- Log warning that the item has an outcome recorded against it.
          --
          igs_ge_ins_sle.genp_set_log_entry (
            p_s_log_type,
            p_key,
            p_sle_key,
            'IGS_AS_ASSITEM_LOGICALLY_DEL', -- Warn that an outcome exist.
            'WARNING|ITEM||' || TO_CHAR (c_suaai_rec.ass_id)
          );
          p_warning_count := p_warning_count + 1;
        END IF;
      END LOOP;
      p_message_name := NULL;
      RETURN TRUE;
    EXCEPTION
      WHEN e_resource_busy_exception THEN
        IF (c_suaai%ISOPEN) THEN
          CLOSE c_suaai;
        END IF;
        ROLLBACK TO sp_save_point;
        p_message_name := 'IGS_AS_UNABLE_LOGICAL_DEL';
        p_error_count := p_error_count + 1;
        igs_ge_ins_sle.genp_set_log_entry (
          p_s_log_type,
          p_key,
          p_sle_key,
          'IGS_AS_UNABLE_LOGICAL_DEL', -- Error, record locked.
          'ERROR|ITEM||'
        );
        RETURN FALSE;
      WHEN OTHERS THEN
        IF (c_suaai%ISOPEN) THEN
          CLOSE c_suaai;
        END IF;
        RAISE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_001.assp_del_suaai_dflt');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_del_suaai_dflt;
  --
  --
  --
  FUNCTION assp_del_suaap_dflt (
    p_person_id                    IN     NUMBER,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_del_suaap_dflt;
  --
  --
  --
  FUNCTION assp_del_suaap_suaai (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  IN     DATE,
    p_ass_id                       IN     NUMBER,
    p_call_from_db_trg             IN     VARCHAR2 DEFAULT 'N',
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_sle_key                      IN     VARCHAR2,
    p_error_count                  IN OUT NOCOPY NUMBER,
    p_warning_count                IN OUT NOCOPY NUMBER,
    p_message_name                 OUT NOCOPY VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END assp_del_suaap_suaai;
  --
  --
  --
  FUNCTION assp_get_actn_msg (p_action_type IN VARCHAR2, p_s_student_todo_type IN VARCHAR2)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_actn_msg
    -- This function will be called from the report ASSR3212 which
    -- inturn calls a procedure that processes the student todo
    -- entries associated with automatically maintaining the
    -- default stdnt_unit_atmpt_ass_items.
    DECLARE
      e_unknown_action_type         EXCEPTION;
      e_unknown_s_student_todo_type EXCEPTION;
      cst_cutoff_lock      CONSTANT VARCHAR2 (30) := 'CUTOFF_LOCK';
      cst_after_cutoff     CONSTANT VARCHAR2 (30) := 'AFTER_CUTOFF';
      cst_status_lock      CONSTANT VARCHAR2 (30) := 'STATUS_LOCK';
      cst_change_lock      CONSTANT VARCHAR2 (30) := 'CHANGE_LOCK';
      cst_todo_lock        CONSTANT VARCHAR2 (30) := 'TODO_LOCK';
      cst_delete_lock      CONSTANT VARCHAR2 (30) := 'DELETE_LOCK';
      cst_maintain_lock    CONSTANT VARCHAR2 (30) := 'MAINTAIN_LOCK';
      cst_clear_actn_dt    CONSTANT VARCHAR2 (30) := 'CLEAR_ACTN_DT';
      cst_ass_insert       CONSTANT VARCHAR2 (30) := 'ASS_INSERT';
      cst_ass_status       CONSTANT VARCHAR2 (30) := 'ASS_STATUS';
      cst_ass_change       CONSTANT VARCHAR2 (30) := 'ASS_CHANGE';
    BEGIN
      -- Determine the message number to be returned based on the
      -- p_action_type and student todo type.
      IF (p_action_type = cst_after_cutoff) THEN
        IF (p_s_student_todo_type = cst_ass_insert) THEN
          RETURN ('IGS_AS_CREATE_DFLT_ASSITEMS');
        ELSIF (p_s_student_todo_type = cst_ass_status) THEN
          RETURN ('IGS_AS_LOGICAL_DEL_DFLT_ITEMS');
        ELSIF (p_s_student_todo_type = cst_ass_change) THEN
          RETURN ('IGS_AS_ADJUST_DFLT_ASSITEMS');
        ELSE
          RAISE e_unknown_s_student_todo_type;
        END IF;
      END IF;
      IF (p_action_type = cst_cutoff_lock) THEN
        RETURN ('IGS_AS_LOGICAL_DEL_STUD_TODO');
      END IF;
      IF (p_action_type = cst_status_lock) THEN
        RETURN ('IGS_AS_LOGICAL_DEL_DFLT_ITEMS');
      END IF;
      IF (p_action_type = cst_change_lock) THEN
        RETURN ('IGS_AS_ADJUST_DFLT_ASSITEMS');
      END IF;
      IF (p_action_type = cst_todo_lock) THEN
        IF (p_s_student_todo_type = cst_ass_insert) THEN
          RETURN ('IGS_AS_LOGDEL_STUD_TODO_ITEM');
        ELSIF (p_s_student_todo_type = cst_ass_status) THEN
          RETURN ('IGS_AS_LOGDEL_STUD_TODO_CHGST');
        ELSIF (p_s_student_todo_type = cst_ass_change) THEN
          RETURN ('IGS_AS_LOGDEL_STUD_TODO_ALT');
        ELSE
          RAISE e_unknown_s_student_todo_type;
        END IF;
      END IF;
      IF (p_action_type = cst_delete_lock) THEN
        RETURN ('IGS_AS_LOGDEL_SFLT_STUD_SUAI');
      END IF;
      IF (p_action_type = cst_maintain_lock) THEN
        RETURN ('IGS_AS_VALID_UAI_SUA');
      END IF;
      IF (p_action_type = cst_clear_actn_dt) THEN
        RETURN ('IGS_AS_CLEAR_ACTIONDT_UAI');
      END IF;
      -- If processing has reached this point then have not
      -- found a valid action type.
      RAISE e_unknown_action_type;
    EXCEPTION
      WHEN e_unknown_s_student_todo_type THEN
        RAISE;
      WHEN e_unknown_action_type THEN
        RAISE;
    END;
  END assp_get_actn_msg;
  --
  --
  --
  FUNCTION assp_get_ai_a_type (p_ass_id IN NUMBER)
    RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_get_ai_a_type
    -- Return the assessment type of an assessment item.
    DECLARE
      CURSOR c_ai (cp_ass_id igs_as_assessmnt_itm.ass_id%TYPE) IS
        SELECT assessment_type
        FROM   igs_as_assessmnt_itm ai
        WHERE  ai.ass_id = cp_ass_id;
      v_ai_rec c_ai%ROWTYPE;
    BEGIN
      OPEN c_ai (p_ass_id);
      FETCH c_ai INTO v_ai_rec;
      IF c_ai%NOTFOUND THEN
        CLOSE c_ai;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_ai;
      RETURN v_ai_rec.assessment_type;
    EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AS_GEN_001.assp_get_ai_a_type');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
    END;
  END assp_get_ai_a_type;
  --
  --
  --
  FUNCTION assp_val_sua_display (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_unit_attempt_status          IN     VARCHAR2,
    p_administrative_unit_status   IN     VARCHAR2,
    p_finalised_ind                IN     VARCHAR2 DEFAULT 'N',
    p_include_fail_grade_ind       IN     VARCHAR2 DEFAULT 'N',
    p_enrolled_units_ind           IN     VARCHAR2 DEFAULT 'C',
    p_exclude_research_units_ind   IN     VARCHAR2 DEFAULT 'N',
    p_exclude_unit_category        IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) RETURN VARCHAR2 IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_val_sua_display
    -- This module checks if the student IGS_PS_UNIT attempt is valid to be displayed on
    -- documentation such as the Academic Transcripts. It determines if failed
    -- grades are to be displayed and also if grades/IGS_PS_UNIT attempt status are to
    -- be displayed.
    DECLARE
      v_grading_schema_cd        igs_as_grd_sch_grade.grading_schema_cd%TYPE;
      v_gs_version_number        igs_as_grd_sch_grade.version_number%TYPE;
      v_grade                    igs_as_grd_sch_grade.grade%TYPE;
      v_dummy                    VARCHAR2 (1);
      v_result_type              igs_as_grd_sch_grade.s_result_type%TYPE;
      v_acad_cal_type            igs_ca_inst.cal_type%TYPE;
      v_acad_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
      v_acad_start_dt            igs_ca_inst.start_dt%TYPE;
      v_acad_end_dt              igs_ca_inst.end_dt%TYPE;
      v_effect_enr_strt_dt_alias igs_en_cal_conf.effect_enr_strt_dt_alias%TYPE;
      v_effective_dt             DATE;
      v_alt_code                 igs_ca_inst.alternate_code%TYPE;
      v_message_name             VARCHAR2 (30);
      cst_enrolled      CONSTANT VARCHAR2 (15)                                   := 'ENROLLED';
      cst_active        CONSTANT VARCHAR2 (15)                                   := 'ACTIVE';
      CURSOR c_aus IS
        SELECT 'x'
        FROM   igs_ad_adm_unit_stat aus
        WHERE  aus.administrative_unit_status = p_administrative_unit_status
        AND    aus.show_on_offic_ntfctn_ind = 'N';
      CURSOR c_gsg (
        cp_grading_schema_cd                  igs_as_grd_sch_grade.grading_schema_cd%TYPE,
        cp_version_number                     igs_as_grd_sch_grade.version_number%TYPE,
        cp_grade                              igs_as_grd_sch_grade.grade%TYPE
      ) IS
        SELECT 'x'
        FROM   igs_as_grd_sch_grade gsg
        WHERE  gsg.grading_schema_cd = cp_grading_schema_cd
        AND    gsg.version_number = cp_version_number
        AND    gsg.grade = cp_grade
        AND    gsg.show_on_official_ntfctn_ind = 'N';
      CURSOR c_crv IS
        SELECT 'x'
        FROM   igs_ps_ver crv,
               igs_ps_type ct
        WHERE  crv.course_cd = p_course_cd
        AND    crv.version_number = p_version_number
        AND    ct.course_type = crv.course_type
        AND    ct.research_type_ind = 'Y';
      CURSOR c_uv IS
        SELECT 'x'
        FROM   igs_ps_unit_ver uv
        WHERE  uv.unit_cd = p_unit_cd
        AND    uv.research_unit_ind = 'Y';
      CURSOR c_uc IS
        SELECT 'x'
        FROM   igs_ps_unit_category uc
        WHERE  uc.unit_cd = p_unit_cd
        AND    uc.unit_cat = p_exclude_unit_category;
      CURSOR c_ci (cp_acad_cal_type igs_ca_inst.cal_type%TYPE, cp_acad_ci_seq_no igs_ca_inst.sequence_number%TYPE) IS
        SELECT 'x'
        FROM   igs_ca_inst ci,
               igs_ca_stat cs
        WHERE  ci.cal_type = cp_acad_cal_type
        AND    ci.sequence_number = cp_acad_ci_seq_no
        AND    ci.cal_status = cs.cal_status
        AND    cs.s_cal_status = cst_active;
      CURSOR c_secc IS
        SELECT secc.effect_enr_strt_dt_alias
        FROM   igs_en_cal_conf secc
        WHERE  secc.s_control_num = 1;
      CURSOR c_daiv (
        cp_acad_cal_type                      igs_ca_inst.cal_type%TYPE,
        cp_acad_ci_seq_no                     igs_ca_inst.sequence_number%TYPE,
        cp_effect_dt_alias                    VARCHAR2
      ) IS
        SELECT igs_ca_gen_001.calp_set_alias_value (
                 absolute_val,
                 igs_ca_gen_002.cals_clc_dt_from_dai (ci_sequence_number, cal_type, dt_alias, sequence_number)
               ) alias_val
        FROM   igs_ca_da_inst daiv
        WHERE  daiv.cal_type = cp_acad_cal_type
        AND    daiv.ci_sequence_number = cp_acad_ci_seq_no
        AND    daiv.dt_alias = cp_effect_dt_alias;
    BEGIN
      -- Determine if the administrative IGS_PS_UNIT status indicates not to
      -- show on official notifications.
      IF p_administrative_unit_status IS NOT NULL THEN
        OPEN c_aus;
        FETCH c_aus INTO v_dummy;
        IF c_aus%FOUND THEN
          CLOSE c_aus;
          RETURN 'N';
        END IF;
        CLOSE c_aus;
      END IF;
      -- Determine the grade and schema used for the IGS_PS_UNIT.
      v_result_type := igs_as_gen_003.assp_get_sua_grade (
                         p_person_id,
                         p_course_cd,
                         p_unit_cd,
                         p_cal_type,
                         p_ci_sequence_number,
                         p_unit_attempt_status,
                         p_finalised_ind,
                         v_grading_schema_cd,
                         v_gs_version_number,
                         v_grade,
                         p_uoo_id
                       );
      -- Check if failed units allowed.
      IF  p_include_fail_grade_ind = 'N'
          AND NVL (v_result_type, 'NULL') = 'FAIL' THEN
        RETURN 'N';
      END IF;
      -- Check if the grade is allowed on official notification.
      IF  v_grading_schema_cd IS NOT NULL
          AND v_gs_version_number IS NOT NULL
          AND v_grade IS NOT NULL THEN
        OPEN c_gsg (v_grading_schema_cd, v_gs_version_number, v_grade);
        FETCH c_gsg INTO v_dummy;
        IF c_gsg%FOUND THEN
          CLOSE c_gsg;
          RETURN 'N';
        END IF;
        CLOSE c_gsg;
      END IF;
      -- Determine if research units are to be included.
      IF p_exclude_research_units_ind = 'Y' THEN
        OPEN c_crv;
        FETCH c_crv INTO v_dummy;
        IF c_crv%NOTFOUND THEN
          CLOSE c_crv;
        ELSE
          CLOSE c_crv;
          OPEN c_uv;
          FETCH c_uv INTO v_dummy;
          IF c_uv%FOUND THEN
            CLOSE c_uv;
            RETURN 'N';
          END IF;
          CLOSE c_uv;
        END IF;
      END IF;
      IF p_exclude_unit_category IS NOT NULL THEN
        OPEN c_uc;
        FETCH c_uc INTO v_dummy;
        IF c_uc%FOUND THEN
          CLOSE c_uc;
          RETURN 'N';
        END IF;
        CLOSE c_uc;
      END IF;
      -- Determine if current/future units are to be included
      v_acad_cal_type := NULL;
      v_acad_ci_sequence_number := NULL;
      v_acad_start_dt := NULL;
      v_acad_end_dt := NULL;
      v_alt_code := igs_en_gen_002.enrp_get_acad_alt_cd (
                      p_cal_type,
                      p_ci_sequence_number,
                      v_acad_cal_type,
                      v_acad_ci_sequence_number,
                      v_acad_start_dt,
                      v_acad_end_dt,
                      v_message_name
                    );
      OPEN c_ci (v_acad_cal_type, v_acad_ci_sequence_number);
      FETCH c_ci INTO v_dummy;
      IF c_ci%FOUND THEN
        CLOSE c_ci;
        IF v_acad_end_dt > SYSDATE THEN
          OPEN c_secc;
          FETCH c_secc INTO v_effect_enr_strt_dt_alias;
          IF c_secc%NOTFOUND THEN
            CLOSE c_secc;
            v_effective_dt := v_acad_start_dt;
          ELSE
            CLOSE c_secc;
            OPEN c_daiv (v_acad_cal_type, v_acad_ci_sequence_number, v_effect_enr_strt_dt_alias);
            FETCH c_daiv INTO v_effective_dt;
            IF c_daiv%NOTFOUND THEN
              CLOSE c_daiv;
              v_effective_dt := v_acad_start_dt;
            ELSE
              CLOSE c_daiv;
            END IF;
          END IF;
          IF p_enrolled_units_ind = 'C' THEN
            -- Current
            IF v_effective_dt > SYSDATE THEN
              RETURN 'N';
            END IF;
          ELSIF p_enrolled_units_ind = 'F' THEN
            -- Future
            IF  v_effective_dt > SYSDATE
                AND p_unit_attempt_status <> cst_enrolled THEN
              RETURN 'N';
            END IF;
          ELSIF p_enrolled_units_ind = 'E' THEN
            -- Exclude
            IF p_unit_attempt_status = cst_enrolled THEN
              RETURN 'N';
            END IF;
          END IF;
        END IF;
      ELSE
        CLOSE c_ci;
      END IF;
      -- If this point reached then IGS_PS_UNIT is valid to be displayed
      -- on official notification.
      RETURN 'Y';
    EXCEPTION
      WHEN OTHERS THEN
        IF c_aus%ISOPEN THEN
          CLOSE c_aus;
        END IF;
        IF c_gsg%ISOPEN THEN
          CLOSE c_gsg;
        END IF;
        IF c_crv%ISOPEN THEN
          CLOSE c_crv;
        END IF;
        IF c_uc%ISOPEN THEN
          CLOSE c_uc;
        END IF;
        IF c_uv%ISOPEN THEN
          CLOSE c_uv;
        END IF;
        IF c_ci%ISOPEN THEN
          CLOSE c_ci;
        END IF;
        IF c_secc%ISOPEN THEN
          CLOSE c_secc;
        END IF;
        IF c_daiv%ISOPEN THEN
          CLOSE c_daiv;
        END IF;
        RAISE;
    END;
  END assp_val_sua_display;
END igs_as_gen_001;

/
