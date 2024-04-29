--------------------------------------------------------
--  DDL for Package Body IGS_AS_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_GEN_007" AS
/* $Header: IGSAS07B.pls 120.0 2005/07/05 11:46:56 appldev noship $ */
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
 |                             igs_as_unitass_item_pkg; igs_ps_unitass_item_pkg
 |                             Added the references of the newly added columns
 |                             in the base tables. This is as per 'Assessment
 |                             Item description Build'; Bug# 2829291;
 |  smvk       09-Jul-2004     Bug # 3676145. Modified the cursors c_suaai,
 |                             c_sua_uai_v, c_todo and c_uai to select
 |                             active (not closed) unit classes.
 +======================================================================+*/
  --
  g_module_head VARCHAR2(30) := 'igs_as_gen_007';
  --
  PROCEDURE assp_ins_suaai_tri (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_location_cd                  IN     VARCHAR2,
    p_unit_class                   IN     VARCHAR2,
    p_unit_mode                    IN     VARCHAR2,
    p_person_id                    IN     NUMBER,
    p_ass_id                       IN     NUMBER,
    p_tracking_type                IN     VARCHAR2,
    p_tracking_status              IN     VARCHAR2,
    p_tracking_start_dt            IN     DATE,
    p_tracking_item_originator     IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE
  ) IS
    gv_other_detail VARCHAR2 (255);
    gv_log_created  BOOLEAN        DEFAULT FALSE;
  BEGIN -- assp_ins_suaai_tri
    -- Create a tracking item for a IGS_AS_SU_ATMPT_ITM.
    DECLARE
      v_uai_due_dt            igs_as_unitass_item.due_dt%TYPE;
      v_uai_reference         igs_as_unitass_item.REFERENCE%TYPE;
      v_uai_location_cd       igs_en_su_attempt.location_cd%TYPE;
      v_uai_unit_class        igs_as_unitass_item.unit_class%TYPE;
      v_uai_unit_mode         igs_as_unitass_item.unit_mode%TYPE;
      v_create_item           BOOLEAN;
      v_record                VARCHAR2 (1024);
      v_log_dt                DATE                                  := NULL;
      v_check                 CHAR;
      v_message_name          VARCHAR2 (30);
      e_resource_busy         EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_resource_busy,  -54);
      v_tracking_id           igs_tr_item.tracking_id%TYPE;
      v_tri_start_dt          igs_tr_item.start_dt%TYPE;
      v_tri_business_days_ind igs_tr_item.business_days_ind%TYPE;
      v_tsdv_action_dt        igs_tr_step_v.action_dt%TYPE;
      v_target_days           NUMBER (3);
      v_other_detail          VARCHAR2 (255);
      cst_enrolled   CONSTANT VARCHAR2 (10)                       := 'ENROLLED';

      -- select all_stdnt_unit_atmpt_ass_item records that are to have
      -- a tracking item assigned to them
      CURSOR c_suaai IS
        SELECT suaai.person_id,
               suaai.course_cd,
               suaai.unit_cd,
               suaai.cal_type,
               suaai.ci_sequence_number,
               suaai.ass_id,
               suaai.creation_dt,
               suaai.override_due_dt,
               sua.version_number,
               sua.uoo_id
        FROM   igs_as_su_atmpt_itm suaai,
               igs_en_su_attempt sua,
               igs_as_assessmnt_itm ai,
               igs_as_unit_class ucl
        WHERE  suaai.person_id = NVL (p_person_id, suaai.person_id)
        AND    suaai.logical_delete_dt IS NULL
        AND    suaai.attempt_number = (SELECT MAX (attempt_number)
                                       FROM   igs_as_su_atmpt_itm suaai2
                                       WHERE  suaai2.person_id = suaai.person_id
                                       AND    suaai2.course_cd = suaai.course_cd
                                       AND    suaai2.uoo_id = suaai.uoo_id
                                       AND    suaai2.ass_id = suaai.ass_id)
        AND    suaai.tracking_id IS NULL
        AND    suaai.person_id = sua.person_id
        AND    suaai.course_cd = sua.course_cd
        AND    suaai.uoo_id = sua.uoo_id
        AND    sua.course_cd LIKE p_course_cd
        AND    sua.unit_cd LIKE p_unit_cd
        AND    sua.location_cd LIKE p_location_cd
        AND    sua.unit_class LIKE p_unit_class
        AND    sua.unit_class = ucl.unit_class
        AND    ucl.unit_mode LIKE p_unit_mode
        AND    ucl.closed_ind = 'N'
        AND    sua.unit_attempt_status = cst_enrolled
        AND    suaai.cal_type = NVL (p_teach_perd_cal_type, suaai.cal_type)
        AND    suaai.ass_id = NVL (p_ass_id, suaai.ass_id)
        AND    suaai.ci_sequence_number = NVL (p_teach_perd_sequence_number, suaai.ci_sequence_number)
        AND    igs_en_gen_014.enrs_get_within_ci (
                 p_acad_perd_cal_type,
                 p_acad_perd_sequence_number,
                 sua.cal_type,
                 sua.ci_sequence_number,
                 'Y'
               ) = 'Y'
        AND    suaai.ass_id = ai.ass_id
        AND    igs_as_gen_002.assp_get_ai_s_type (ai.ass_id) = 'ASSIGNMENT';
      --
      CURSOR c_sua_uai_v (
        cp_person_id                          igs_en_su_attempt.person_id%TYPE,
        cp_course_cd                          igs_en_su_attempt.course_cd%TYPE,
        cp_unit_cd                            igs_en_su_attempt.unit_cd%TYPE,
        cp_cal_type                           igs_en_su_attempt.cal_type%TYPE,
        cp_ci_sequence_number                 igs_en_su_attempt.ci_sequence_number%TYPE,
        cp_ass_id                             igs_as_su_atmpt_itm.ass_id%TYPE,
        cp_uoo_id                             igs_as_su_atmpt_itm.uoo_id%TYPE
      ) IS
        SELECT uai.due_dt,
               uai.REFERENCE,
               uai.location_cd,
               uai.unit_class,
               uai.unit_mode
        FROM   igs_en_su_attempt sua,
               igs_as_unitass_item uai,
               igs_as_unit_class uc
        WHERE  sua.person_id = cp_person_id
        AND    sua.course_cd = cp_course_cd
        AND    sua.uoo_id = cp_uoo_id
        AND    uai.ass_id = cp_ass_id
        AND    uai.logical_delete_dt IS NULL
        AND    sua.unit_cd = uai.unit_cd
        AND    sua.version_number = uai.version_number
        AND    sua.cal_type = uai.cal_type
        AND    sua.ci_sequence_number = uai.ci_sequence_number
        AND    sua.unit_class = uc.unit_class
        AND    uc.closed_ind = 'N'
        AND    igs_as_val_uai.assp_val_sua_ai_acot (uai.ass_id, sua.person_id, sua.course_cd) = 'TRUE';
      --
      CURSOR c_lock_suaai (
        cp_person_id                          igs_en_su_attempt.person_id%TYPE,
        cp_course_cd                          igs_en_su_attempt.course_cd%TYPE,
        cp_unit_cd                            igs_en_su_attempt.unit_cd%TYPE,
        cp_cal_type                           igs_en_su_attempt.cal_type%TYPE,
        cp_ci_sequence_number                 igs_en_su_attempt.ci_sequence_number%TYPE,
        cp_ass_id                             igs_as_su_atmpt_itm.ass_id%TYPE,
        cp_creation_dt                        DATE,
        cp_uoo_id                             igs_as_su_atmpt_itm.uoo_id%TYPE
      ) IS
        SELECT ROWID,
               igs_as_su_atmpt_itm.*
        FROM   igs_as_su_atmpt_itm
        WHERE  person_id = cp_person_id
        AND    course_cd = cp_course_cd
        AND    uoo_id = cp_uoo_id
        AND    ass_id = cp_ass_id
        AND    creation_dt = cp_creation_dt
        FOR UPDATE OF tracking_id NOWAIT;
      --
      CURSOR c_sle (
        cp_creation_dt                        igs_ge_s_log_entry.creation_dt%TYPE,
        cp_key                                igs_ge_s_log_entry.KEY%TYPE,
        cp_text                               igs_ge_s_log_entry.text%TYPE
      ) IS
        SELECT 'x'
        FROM   igs_ge_s_log_entry
        WHERE  s_log_type = 'ASS3610'
        AND    creation_dt = cp_creation_dt
        AND    KEY = cp_key
        AND    text = cp_text;
      --
      CURSOR c_tri (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT start_dt,
               business_days_ind
        FROM   igs_tr_item
        WHERE  tracking_id = cp_tracking_id;
      --
      CURSOR c_tsdv (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT MAX (action_dt)
        FROM   igs_tr_step_v
        WHERE  tracking_id = cp_tracking_id;
      --
      CURSOR c_tri_upd (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
        SELECT        ROWID,
                      igs_tr_item.*
        FROM          igs_tr_item
        WHERE         tracking_id = v_tracking_id
        FOR UPDATE OF business_days_ind NOWAIT;
      --
      v_tri_upd_rec           c_tri_upd%ROWTYPE;
      c_lock_suaai_rec        c_lock_suaai%ROWTYPE;
      --
    BEGIN
      p_creation_dt := NULL;
      -- Process each suaai record that is to have tracking item assigned.
      FOR v_suaai_rec IN c_suaai LOOP
        v_create_item := TRUE;
        SAVEPOINT sp_ins_suaai_tri;
        -- Determine the appropriate IGS_AS_UNITASS_ITEM for the
        -- location mode and class of the student and get the due date
        v_uai_reference := NULL;
        OPEN c_sua_uai_v (
          v_suaai_rec.person_id,
          v_suaai_rec.course_cd,
          v_suaai_rec.unit_cd,
          v_suaai_rec.cal_type,
          v_suaai_rec.ci_sequence_number,
          v_suaai_rec.ass_id,
          v_suaai_rec.uoo_id
        );
        FETCH c_sua_uai_v INTO v_uai_due_dt,
                               v_uai_reference,
                               v_uai_location_cd,
                               v_uai_unit_class,
                               v_uai_unit_mode;
        IF c_sua_uai_v%NOTFOUND THEN
          CLOSE c_sua_uai_v;
          v_create_item := FALSE;
        ELSIF (v_uai_due_dt IS NULL) THEN
          CLOSE c_sua_uai_v;
          -- Do not create a tracking item for this record.
          -- Log an exception
          v_create_item := FALSE;
          v_record :=    v_suaai_rec.unit_cd
                      || '|'
                      || TO_CHAR (v_suaai_rec.version_number)
                      || '|'
                      || v_suaai_rec.cal_type
                      || '|'
                      || TO_CHAR (v_suaai_rec.ci_sequence_number)
                      || '|'
                      || TO_CHAR (v_suaai_rec.ass_id)
                      || '|'
                      || v_uai_reference
                      || '|'
                      || v_uai_unit_class
                      || '|'
                      || v_uai_unit_mode
                      || '|'
                      || v_uai_location_cd;
          IF (gv_log_created = FALSE) THEN
            igs_ge_gen_003.genp_ins_log ('ASS3610', NULL, v_log_dt);
            gv_log_created := TRUE;
            -- Insert into the IGS_GE_S_LOG_ENTRY table
            igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'NO_DUE_DT', NULL, v_record);
          ELSE
            -- Only insert if a log entry not already exists.
            OPEN c_sle (v_log_dt, 'NO_DUE_DT', v_record);
            FETCH c_sle INTO v_check;
            IF (c_sle%NOTFOUND) THEN
              igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'NO_DUE_DT', NULL, v_record);
            END IF;
            CLOSE c_sle;
          END IF;
        ELSE
          CLOSE c_sua_uai_v;
          -- Determine if the override due date has been entered for the student
          -- unit attempt assessment item and whether it is later than the due
          -- date of the unit assessment item. If it is, then set it to be the
          -- due date for the assessment item, this date will be used to set the
          -- due date for the tracking item.
          IF v_uai_due_dt < NVL (v_suaai_rec.override_due_dt, igs_ge_date.igsdate ('1900/01/01 00:00:00')) THEN
            v_uai_due_dt := v_suaai_rec.override_due_dt;
          END IF;
          IF v_uai_due_dt < p_tracking_start_dt THEN
            -- Do not create a tracking item for this record.
            v_create_item := FALSE;
            -- Log an exception to indicate the unit assessment item due date
            -- was earlier than the tracking item start date.
            v_record :=    v_suaai_rec.unit_cd
                        || '|'
                        || TO_CHAR (v_suaai_rec.version_number)
                        || '|'
                        || v_suaai_rec.cal_type
                        || '|'
                        || TO_CHAR (v_suaai_rec.ci_sequence_number)
                        || '|'
                        || TO_CHAR (v_suaai_rec.ass_id)
                        || '|'
                        || v_uai_reference
                        || '|'
                        || v_uai_unit_class
                        || '|'
                        || v_uai_unit_mode
                        || '|'
                        || v_uai_location_cd;
            IF gv_log_created = FALSE THEN
              igs_ge_gen_003.genp_ins_log ('ASS3610', NULL, v_log_dt); -- out NOCOPY
              gv_log_created := TRUE;
              -- Insert into the IGS_GE_S_LOG_ENTRY table.
              igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'EARLY_DUE_DT', NULL, v_record);
            ELSE
              -- Check to see if a log entry already exists for this
              -- assessment item indicating that the due date is earlier
              -- than the tracking start date..
              OPEN c_sle (v_log_dt, 'EARLY_DUE_DT', v_record);
              FETCH c_sle INTO v_check;
              -- If no record found then insert the entry,
              -- otherwise do nothing.
              IF (c_sle%NOTFOUND) THEN
                CLOSE c_sle;
                igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'EARLY_DUE_DT', NULL, v_record);
              ELSE
                CLOSE c_sle;
              END IF;
            END IF;
          END IF;
        END IF;
        -- Assign a tracking item to the student unit assessment
        -- item if successful processing so far.
        IF (v_create_item = TRUE) THEN
          BEGIN -- sub block
            -- Lock suaai record (from the outter loop) for update
            OPEN c_lock_suaai (
              v_suaai_rec.person_id,
              v_suaai_rec.course_cd,
              v_suaai_rec.unit_cd,
              v_suaai_rec.cal_type,
              v_suaai_rec.ci_sequence_number,
              v_suaai_rec.ass_id,
              v_suaai_rec.creation_dt,
              v_suaai_rec.uoo_id
            );
            FETCH c_lock_suaai INTO c_lock_suaai_rec;
            -- Create the tracking item
            igs_tr_gen_002.trkp_ins_trk_item (
              p_tracking_status,
              p_tracking_type,
              v_suaai_rec.person_id,
              p_tracking_start_dt,
              NULL,
              NULL,
              NULL,
              p_tracking_item_originator,
              'Y',
              v_tracking_id,
              v_message_name
            );
            IF (v_message_name IS NOT NULL) THEN
              -- Error occured in creating tracking item
              ROLLBACK TO sp_ins_suaai_tri;
              -- Log an exception to indicate the tracking step could
              -- not be updated to the unit assessment item due date.
              v_record :=    v_suaai_rec.unit_cd
                          || '|'
                          || TO_CHAR (v_suaai_rec.version_number)
                          || '|'
                          || v_suaai_rec.cal_type
                          || '|'
                          || TO_CHAR (v_suaai_rec.ci_sequence_number)
                          || '|'
                          || TO_CHAR (v_suaai_rec.ass_id)
                          || '|'
                          || v_uai_reference
                          || '|'
                          || v_uai_unit_class
                          || '|'
                          || v_uai_unit_mode
                          || '|'
                          || v_uai_location_cd;
              IF gv_log_created = FALSE THEN
                igs_ge_gen_003.genp_ins_log ('ASS3610', NULL, v_log_dt); -- out NOCOPY
                gv_log_created := TRUE;
                -- Insert into the IGS_GE_S_LOG_ENTRY table.
                igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'TRI_ERROR', v_message_name, v_record);
              ELSE
                -- Check to see if a log entry already exists for
                -- this assessment item indicating that the due date
                -- is earlier than the tracking start date..
                OPEN c_sle (v_log_dt, 'TRI_ERROR', v_record);
                FETCH c_sle INTO v_check;
                -- If no record found then insert the entry,
                -- otherwise do nothing.
                IF (c_sle%NOTFOUND) THEN
                  igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'TRI_ERROR', v_message_name, v_record);
                  CLOSE c_sle;
                END IF;
                CLOSE c_sle;
              END IF;
            ELSE
              -- update suaai record that has been selected
              -- for update nowait with the ID of the tracking item
              igs_as_su_atmpt_itm_pkg.update_row (
                x_rowid                        => c_lock_suaai_rec.ROWID,
                x_person_id                    => c_lock_suaai_rec.person_id,
                x_course_cd                    => c_lock_suaai_rec.course_cd,
                x_unit_cd                      => c_lock_suaai_rec.unit_cd,
                x_cal_type                     => c_lock_suaai_rec.cal_type,
                x_ci_sequence_number           => c_lock_suaai_rec.ci_sequence_number,
                x_ass_id                       => c_lock_suaai_rec.ass_id,
                x_creation_dt                  => c_lock_suaai_rec.creation_dt,
                x_attempt_number               => c_lock_suaai_rec.attempt_number,
                x_outcome_dt                   => c_lock_suaai_rec.outcome_dt,
                x_override_due_dt              => c_lock_suaai_rec.override_due_dt,
                x_tracking_id                  => v_tracking_id,
                x_logical_delete_dt            => c_lock_suaai_rec.logical_delete_dt,
                x_s_default_ind                => c_lock_suaai_rec.s_default_ind,
                x_ass_pattern_id               => NULL,
                x_mode                         => 'R',
                x_grading_schema_cd            => c_lock_suaai_rec.grading_schema_cd,
                x_gs_version_number            => c_lock_suaai_rec.gs_version_number,
                x_grade                        => c_lock_suaai_rec.grade,
                x_outcome_comment_code         => c_lock_suaai_rec.outcome_comment_code,
                x_mark                         => c_lock_suaai_rec.mark,
                x_attribute_category           => c_lock_suaai_rec.attribute_category,
                x_attribute1                   => c_lock_suaai_rec.attribute1,
                x_attribute2                   => c_lock_suaai_rec.attribute2,
                x_attribute3                   => c_lock_suaai_rec.attribute3,
                x_attribute4                   => c_lock_suaai_rec.attribute4,
                x_attribute5                   => c_lock_suaai_rec.attribute5,
                x_attribute6                   => c_lock_suaai_rec.attribute6,
                x_attribute7                   => c_lock_suaai_rec.attribute7,
                x_attribute8                   => c_lock_suaai_rec.attribute8,
                x_attribute9                   => c_lock_suaai_rec.attribute9,
                x_attribute10                  => c_lock_suaai_rec.attribute10,
                x_attribute11                  => c_lock_suaai_rec.attribute11,
                x_attribute12                  => c_lock_suaai_rec.attribute12,
                x_attribute13                  => c_lock_suaai_rec.attribute13,
                x_attribute14                  => c_lock_suaai_rec.attribute14,
                x_attribute15                  => c_lock_suaai_rec.attribute15,
                x_attribute16                  => c_lock_suaai_rec.attribute16,
                x_attribute17                  => c_lock_suaai_rec.attribute17,
                x_attribute18                  => c_lock_suaai_rec.attribute18,
                x_attribute19                  => c_lock_suaai_rec.attribute19,
                x_attribute20                  => c_lock_suaai_rec.attribute20,
                x_uoo_id                       => c_lock_suaai_rec.uoo_id,
                x_unit_section_ass_item_id     => c_lock_suaai_rec.unit_section_ass_item_id,
                x_unit_ass_item_id             => c_lock_suaai_rec.unit_ass_item_id,
                x_sua_ass_item_group_id        => c_lock_suaai_rec.sua_ass_item_group_id,
                x_midterm_mandatory_type_code  => c_lock_suaai_rec.midterm_mandatory_type_code,
                x_midterm_weight_qty           => c_lock_suaai_rec.midterm_weight_qty,
                x_final_mandatory_type_code    => c_lock_suaai_rec.final_mandatory_type_code,
                x_final_weight_qty             => c_lock_suaai_rec.final_weight_qty,
                x_submitted_date               => c_lock_suaai_rec.submitted_date,
                x_waived_flag                  => c_lock_suaai_rec.waived_flag,
                x_penalty_applied_flag         => c_lock_suaai_rec.penalty_applied_flag
              );
            END IF;
            -- Update the step that is considered the due date of the assignment.
            -- This process should validate that the date is after the start date
            -- of the item and also after the previous step action date if it is
            -- sequential.
            IF igs_tr_gen_002.trkp_upd_trst (
                 v_tracking_id,
                 NULL,
                 'ASSIGN-DUE',
                 v_uai_due_dt,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 v_message_name
               ) = FALSE THEN
              -- Rollback creation of the tracking item.
              ROLLBACK TO sp_ins_suaai_tri;
              -- Log an exception to indicate the tracking step could
              -- not be updated to the unit assessment item due date.
              v_record :=    v_suaai_rec.unit_cd
                          || '|'
                          || TO_CHAR (v_suaai_rec.version_number)
                          || '|'
                          || v_suaai_rec.cal_type
                          || '|'
                          || TO_CHAR (v_suaai_rec.ci_sequence_number)
                          || '|'
                          || TO_CHAR (v_suaai_rec.ass_id)
                          || '|'
                          || v_uai_reference
                          || '|'
                          || v_uai_unit_class
                          || '|'
                          || v_uai_unit_mode
                          || '|'
                          || v_uai_location_cd;
              IF gv_log_created = FALSE THEN
                igs_ge_gen_003.genp_ins_log ('ASS3610', NULL, v_log_dt); -- out NOCOPY
                gv_log_created := TRUE;
                -- Insert into the IGS_GE_S_LOG_ENTRY table.
                igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'STEP_DUE_DT', v_message_name, v_record);
              ELSE
                -- Check to see if a log entry already exists for this
                -- assessment item indicating that the due date is
                -- earlier than the tracking start date..
                OPEN c_sle (v_log_dt, 'STEP_DUE_DT', v_record);
                FETCH c_sle INTO v_check;
                -- If no record found then insert the entry,
                -- otherwise do nothing.
                IF (c_sle%NOTFOUND) THEN
                  igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'STEP_DUE_DT', v_message_name, v_record);
                  CLOSE c_sle;
                END IF;
                CLOSE c_sle;
              END IF;
            END IF;
            -- Update the target days of the item to be the maximum action date
            -- of the item. Note: The required select statement have been placed
            -- into Two separate statements as the view does quite a bit of
            -- processing an this is considered to be the most efficient approach.
            OPEN c_tri (v_tracking_id);
            FETCH c_tri INTO v_tri_start_dt,
                             v_tri_business_days_ind;
            CLOSE c_tri;
            OPEN c_tsdv (v_tracking_id);
            FETCH c_tsdv INTO v_tsdv_action_dt;
            CLOSE c_tsdv;
            -- Call tracking function to calculate the number of days between
            -- the start date and the maximum action date (This function
            -- determines the number of days overdue for a completion.
            -- It?s functionality is the same as is required for the calculation
            -- needed here).
            v_target_days :=
                         igs_tr_gen_001.trkp_clc_days_ovrdue (v_tri_start_dt, v_tsdv_action_dt, v_tri_business_days_ind);
            OPEN c_tri_upd (v_tracking_id);
            FETCH c_tri_upd INTO v_tri_upd_rec;
            IF c_tri_upd%FOUND THEN
              igs_tr_item_pkg.update_row (
                x_rowid                        => v_tri_upd_rec.ROWID,
                x_tracking_id                  => v_tri_upd_rec.tracking_id,
                x_tracking_status              => v_tri_upd_rec.tracking_status,
                x_tracking_type                => v_tri_upd_rec.tracking_type,
                x_source_person_id             => v_tri_upd_rec.source_person_id,
                x_start_dt                     => v_tri_upd_rec.start_dt,
                x_target_days                  => v_target_days,
                x_sequence_ind                 => v_tri_upd_rec.sequence_ind,
                x_business_days_ind            => v_tri_upd_rec.business_days_ind,
                x_originator_person_id         => v_tri_upd_rec.originator_person_id,
                x_s_created_ind                => v_tri_upd_rec.s_created_ind,
                x_completion_due_dt            => v_tri_upd_rec.completion_due_dt,
                x_override_offset_clc_ind      => v_tri_upd_rec.override_offset_clc_ind,
                x_publish_ind                  => v_tri_upd_rec.publish_ind,
                x_mode                         => 'R' --v_tri_upd_rec.mode
              );
            END IF;
            -- Update the recipient of the step where the assignment is to be returned
            -- to the student. Set the recipient id to be the student.
            IF igs_tr_gen_002.trkp_upd_trst (
                 v_tracking_id,
                 NULL,
                 'ASSIGN-RTN',
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 v_suaai_rec.person_id,
                 v_message_name
               ) = FALSE THEN
              -- Ignore, exceptions should never occur.
              -- If so, then may need to be log in the exception report as a future
              -- enhancement.
              NULL;
            END IF;
            CLOSE c_tri_upd;
            CLOSE c_lock_suaai;
          EXCEPTION
            -- Can not lock suaai record for update,
            -- Do not create the tracking item
            WHEN e_resource_busy THEN
              -- Log the exception indicating a lock on the suaai record.
              v_uai_reference := NULL;
              SELECT uai.REFERENCE
              INTO   v_uai_reference
              FROM   igs_en_su_attempt sua,
                     igs_as_unitass_item uai,
                     igs_as_unit_class uc
              WHERE  sua.person_id = v_suaai_rec.person_id
              AND    sua.course_cd = v_suaai_rec.course_cd
              AND    sua.uoo_id = v_suaai_rec.uoo_id
              AND    uai.ass_id = v_suaai_rec.ass_id
              AND    uai.logical_delete_dt IS NULL
              AND    sua.unit_cd = uai.unit_cd
              AND    sua.version_number = uai.version_number
              AND    sua.cal_type = uai.cal_type
              AND    sua.ci_sequence_number = uai.ci_sequence_number
              AND    sua.unit_class = uc.unit_class
              AND    uc.closed_ind = 'N'
              AND    igs_as_val_uai.assp_val_sua_ai_acot (uai.ass_id, sua.person_id, sua.course_cd) = 'TRUE';
              v_record :=    TO_CHAR (v_suaai_rec.person_id)
                          || '|'
                          || v_suaai_rec.course_cd
                          || '|'
                          || v_suaai_rec.unit_cd
                          || '|'
                          || v_suaai_rec.cal_type
                          || '|'
                          || TO_CHAR (v_suaai_rec.ci_sequence_number)
                          || '|'
                          || TO_CHAR (v_suaai_rec.ass_id)
                          || '|'
                          || v_uai_reference
                          || '|'
                          || SUBSTR (igs_ge_date.igschardt (v_suaai_rec.creation_dt), 1, 18);
              IF gv_log_created = FALSE THEN
                igs_ge_gen_003.genp_ins_log ('ASS3610', NULL, v_log_dt); -- out NOCOPY
                gv_log_created := TRUE;
              END IF;
              -- Insert into the IGS_GE_S_LOG_ENTRY table.
              igs_ge_gen_003.genp_ins_log_entry ('ASS3610', v_log_dt, 'SUAAI_LOCK', NULL, v_record);
            WHEN OTHERS THEN
              RAISE;
          END; -- sub block
        END IF; -- IF create item
        -- Commit the processing of each student unit assessment item.
        COMMIT;
      END LOOP;
      IF (gv_log_created = TRUE) THEN
        p_creation_dt := v_log_dt;
      END IF;
    END;
  END assp_ins_suaai_tri;

  PROCEDURE assp_ins_suao_hist (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                     IN     VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_outcome_dt                   IN     DATE,
    p_new_grading_schema_cd        IN     VARCHAR2,
    p_new_version_number           IN     NUMBER,
    p_new_grade                    IN     VARCHAR2,
    p_new_s_grade_crtn_mthd_tp     IN     VARCHAR2,
    p_new_finalised_outcome_ind    IN     VARCHAR2,
    p_new_mark                     IN     NUMBER,
    p_new_number_times_keyed       IN     NUMBER,
    p_new_trnsltd_grdng_schema_cd  IN     VARCHAR2,
    p_new_trnsltd_version_number   IN     NUMBER,
    p_new_translated_grade         IN     VARCHAR2,
    p_new_translated_dt            IN     DATE,
    p_new_update_who               IN     VARCHAR2,
    p_new_update_on                IN     DATE,
    p_old_grading_schema_cd        IN     VARCHAR2,
    p_old_version_number           IN     NUMBER,
    p_old_grade                    IN     VARCHAR2,
    p_old_s_grade_crtn_mthd_tp     IN     VARCHAR2,
    p_old_finalised_outcome_ind    IN     VARCHAR2,
    p_old_mark                     IN     NUMBER,
    p_old_number_times_keyed       IN     NUMBER,
    p_old_trnsltd_grdng_schema_cd  IN     VARCHAR2,
    p_old_trnsltd_version_number   IN     NUMBER,
    p_old_translated_grade         IN     VARCHAR2,
    p_old_translated_dt            IN     DATE,
    p_old_update_who               IN     VARCHAR2,
    p_old_update_on                IN     DATE,
    p_uoo_id                       IN     NUMBER
  ) IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_ins_suao_hist
    DECLARE
      v_suaoh_rec      igs_as_su_atmptout_h%ROWTYPE;
      v_create_history BOOLEAN                        := FALSE;
    BEGIN
      -- Create a history for a IGS_AS_SU_STMPTOUT record.
      -- Check if any of the non-primary key fields have been changed
      -- and set the flag v_create_history to indicate so.
      IF p_new_grading_schema_cd <> p_old_grading_schema_cd THEN
        v_suaoh_rec.grading_schema_cd := p_old_grading_schema_cd;
        v_create_history := TRUE;
      END IF;
      IF p_new_version_number <> p_old_version_number THEN
        v_suaoh_rec.version_number := p_old_version_number;
        v_create_history := TRUE;
      END IF;
      IF p_new_grade <> p_old_grade THEN
        v_suaoh_rec.grade := p_old_grade;
        v_create_history := TRUE;
      END IF;
      IF p_new_s_grade_crtn_mthd_tp <> p_old_s_grade_crtn_mthd_tp THEN
        v_suaoh_rec.s_grade_creation_method_type := p_old_s_grade_crtn_mthd_tp;
        v_create_history := TRUE;
      END IF;
      IF p_new_finalised_outcome_ind <> p_old_finalised_outcome_ind THEN
        v_suaoh_rec.finalised_outcome_ind := p_old_finalised_outcome_ind;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_mark, 0) <> NVL (p_old_mark, 0) THEN
        v_suaoh_rec.mark := p_old_mark;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_number_times_keyed, 0) <> NVL (p_old_number_times_keyed, 0) THEN
        v_suaoh_rec.number_times_keyed := p_old_number_times_keyed;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_trnsltd_grdng_schema_cd, ' ') <> NVL (p_old_trnsltd_grdng_schema_cd, ' ') THEN
        v_suaoh_rec.translated_grading_schema_cd := p_old_trnsltd_grdng_schema_cd;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_trnsltd_version_number, 0) <> NVL (p_old_trnsltd_version_number, 0) THEN
        v_suaoh_rec.translated_version_number := p_old_trnsltd_version_number;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_translated_grade, ' ') <> NVL (p_old_translated_grade, ' ') THEN
        v_suaoh_rec.translated_grade := p_old_translated_grade;
        v_create_history := TRUE;
      END IF;
      IF NVL (p_new_translated_dt, igs_ge_date.igsdate ('1900/01/01')) <>
         NVL (p_old_translated_dt, igs_ge_date.igsdate ('1900/01/01')) THEN
        v_suaoh_rec.translated_dt := p_old_translated_dt;
        v_create_history := TRUE;
      END IF;
      -- Create a history record if a column has changed value
      IF v_create_history = TRUE THEN
        v_suaoh_rec.person_id := p_person_id;
        v_suaoh_rec.course_cd := p_course_cd;
        v_suaoh_rec.unit_cd := p_unit_cd;
        v_suaoh_rec.cal_type := p_cal_type;
        v_suaoh_rec.ci_sequence_number := p_ci_sequence_number;
        v_suaoh_rec.outcome_dt := p_outcome_dt;
        v_suaoh_rec.hist_start_dt := p_old_update_on;
        v_suaoh_rec.hist_end_dt := p_new_update_on;
        v_suaoh_rec.hist_who := p_old_update_who;
        v_suaoh_rec.mark_capped_flag := 'N';
        v_suaoh_rec.show_on_academic_histry_flag := 'Y';
        v_suaoh_rec.release_date := NULL;
        v_suaoh_rec.manual_override_flag := 'N';

        DECLARE
          x_rowid  VARCHAR2 (25);
          l_org_id NUMBER (15);
        BEGIN
          --get org id
          l_org_id := igs_ge_gen_003.get_org_id;
          -- This is Added by DDEY as a part of Bug # 2370562
          -- remove one second from the hist_start_dt value
          -- when the hist_start_dt and hist_end_dt are the same
          -- to avoid a primary key constraint from occurring
          -- when saving the record
          IF (v_suaoh_rec.hist_start_dt = v_suaoh_rec.hist_end_dt) THEN
            v_suaoh_rec.hist_start_dt := v_suaoh_rec.hist_start_dt - 1 / (60 * 24 * 60);
          END IF;
          igs_as_su_atmptout_h_pkg.insert_row (
            x_rowid                        => x_rowid,
            x_org_id                       => l_org_id,
            x_person_id                    => v_suaoh_rec.person_id,
            x_course_cd                    => v_suaoh_rec.course_cd,
            x_unit_cd                      => v_suaoh_rec.unit_cd,
            x_cal_type                     => v_suaoh_rec.cal_type,
            x_ci_sequence_number           => v_suaoh_rec.ci_sequence_number,
            x_outcome_dt                   => v_suaoh_rec.outcome_dt,
            x_hist_start_dt                => v_suaoh_rec.hist_start_dt,
            x_hist_end_dt                  => v_suaoh_rec.hist_end_dt,
            x_hist_who                     => v_suaoh_rec.hist_who,
            x_grading_schema_cd            => v_suaoh_rec.grading_schema_cd,
            x_version_number               => v_suaoh_rec.version_number,
            x_grade                        => v_suaoh_rec.grade,
            x_s_grade_creation_method_type => v_suaoh_rec.s_grade_creation_method_type,
            x_finalised_outcome_ind        => v_suaoh_rec.finalised_outcome_ind,
            x_mark                         => v_suaoh_rec.mark,
            x_number_times_keyed           => v_suaoh_rec.number_times_keyed,
            x_translated_grading_schema_cd => v_suaoh_rec.translated_grading_schema_cd,
            x_translated_version_number    => v_suaoh_rec.translated_version_number,
            x_translated_grade             => v_suaoh_rec.translated_grade,
            x_translated_dt                => v_suaoh_rec.translated_dt,
            x_mode                         => 'R',
            x_uoo_id                       => p_uoo_id,
            x_mark_capped_flag             => v_suaoh_rec.mark_capped_flag,
            x_show_on_academic_histry_flag => v_suaoh_rec.show_on_academic_histry_flag,
            x_release_date                 => v_suaoh_rec.release_date,
            x_manual_override_flag         => v_suaoh_rec.manual_override_flag
          );
        END;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_007.assp_ins_suao_hist');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_suao_hist;

  PROCEDURE assp_prc_suaai_todo (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_person_id                    IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE,
    p_uoo_id                       IN     NUMBER
  ) IS
    gv_other_detail VARCHAR2 (255);
    gv_log_created  BOOLEAN        := FALSE;
  BEGIN -- assp_prc_suaai_todo
    -- This routine will process all Person To Do records that are associated
    -- with automatically maintaining the Student Unit Attempt Assessment Items
    -- for the students.
    -- The following actions will be applied.
    -- Status becomes ENROLLED - To Do item created that is for 'ASS_INSERT'
    -- Will need to create default Student Unit Attempt Assessment Items for the unit.
    -- Status altered from ENROLLED to: DISCONTINUED, UNCONFIRMED, DELETED
    -- INVALID - To Do item created that is for 'ASS_STATUS'
    -- All Student Unit Attempt Assessment Item records for the student become logically
    -- deleted. (Note: Student todo creation routine (assp_ins_suaai_todo) has now
    -- been altered such that no todo item created when altered from enrolled.
    -- Hence, items are no longer logically deleted upon status change.)
    -- Student alters their location or CLASS. - Todo item created that is
    -- for 'ASS_CHANGE'
    DECLARE
      cst_ass_insert       CONSTANT VARCHAR2 (10)                    := 'ASS_INSERT';
      cst_ass_status       CONSTANT VARCHAR2 (10)                    := 'ASS_STATUS';
      cst_ass_change       CONSTANT VARCHAR2 (10)                    := 'ASS_CHANGE';
      cst_ass3212          CONSTANT VARCHAR2 (10)                    := 'ASS3212';
      cst_none             CONSTANT VARCHAR2 (4)                     := 'NONE';
      cst_key_label        CONSTANT VARCHAR2 (40)                    := 'MAINTAIN STUDENT UNIT ASSESSMENT ITEMS';
      -- Warning: Altering cst_key_label will result in ASSR3212 not being
      -- able to select exceptions. This key label was used to distinuish
      -- between layout version when altering layout and functionality
      -- within the report.
      cst_error_count      CONSTANT VARCHAR2 (12)                    := 'ERROR_COUNT|';
      cst_warning_count    CONSTANT VARCHAR2 (14)                    := 'WARNING_COUNT|';
      cst_unit_stdnt_count CONSTANT VARCHAR2 (17)                    := 'UNIT_STDNT_COUNT|';
      cst_information      CONSTANT VARCHAR2 (13)                    := 'INFORMATION||';
      cst_error_stdnt_todo CONSTANT VARCHAR2 (19)                    := 'ERROR|STUDENT_TODO|';
      v_error_count                 NUMBER                           := 0;
      v_warning_count               NUMBER                           := 0;
      v_delete_todo                 BOOLEAN;
      v_sle_key                     igs_ge_s_log_entry.KEY%TYPE;
      v_new_student                 BOOLEAN;
      v_previous_student            igs_pe_person.person_id%TYPE;
      v_previous_unit               igs_en_su_attempt.unit_cd%TYPE;
      v_key                         igs_ge_s_log.KEY%TYPE;
      v_message_name                VARCHAR2 (30);
      v_log_dt                      DATE                             DEFAULT NULL;
      v_record                      VARCHAR2 (255);
      v_total_count                 NUMBER;
      --
      CURSOR c_todo IS
        SELECT   st.person_id,
                 str.s_student_todo_type,
                 str.sequence_number,
                 str.reference_number,
                 str.course_cd,
                 str.unit_cd,
                 sua.version_number,
                 sua.cal_type,
                 sua.ci_sequence_number,
                 sua.location_cd,
                 sua.unit_class,
                 uc.unit_mode,
                 st.todo_dt,
                 sua.uoo_id
        FROM     igs_pe_std_todo st,
                 igs_pe_std_todo_ref str,
                 igs_en_su_attempt_all sua,
                 igs_as_unit_class uc,
                 igs_ca_inst_rel cir
        WHERE    ((NVL (p_person_id, 9999999999) = 9999999999)
                  OR (st.person_id = p_person_id)
                 )
        AND      st.logical_delete_dt IS NULL
        AND      st.todo_dt <= SYSDATE
        AND      st.s_student_todo_type IN (cst_ass_insert, cst_ass_status, cst_ass_change)
        AND      st.person_id = str.person_id
        AND      st.s_student_todo_type = str.s_student_todo_type
        AND      st.sequence_number = str.sequence_number
        AND      str.logical_delete_dt IS NULL
        AND      str.course_cd LIKE p_course_cd
        AND      str.unit_cd LIKE p_unit_cd
        AND      str.uoo_id = NVL (p_uoo_id, str.uoo_id)
        AND      ((NVL (p_teach_perd_cal_type, 'x') = 'x')
                  OR (str.cal_type = p_teach_perd_cal_type)
                 )
        AND      ((NVL (p_teach_perd_sequence_number, 0) = 0)
                  OR (str.ci_sequence_number = p_teach_perd_sequence_number)
                 )
        AND      sua.person_id = str.person_id
        AND      sua.course_cd = str.course_cd
        AND      sua.uoo_id = str.uoo_id
        AND      sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED')
        AND      cir.sup_cal_type            = p_acad_perd_cal_type
        AND      cir.sup_ci_sequence_number  = p_acad_perd_sequence_number
        AND      cir.sub_cal_type            = sua.cal_type
        AND      cir.sub_ci_sequence_number  = sua.ci_sequence_number
        AND      uc.unit_class = sua.unit_class
        AND      uc.closed_ind = 'N'
        ORDER BY st.person_id,
                 str.unit_cd,
                 st.todo_dt;
      --
      -- Get the Active Assessment Items attached to a Unit Section
      -- Added by ddey for the bug # 2162831
      --
      CURSOR c_usc_ass (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
        SELECT uai.ass_id
        FROM   igs_ps_unitass_item uai
        WHERE  uai.uoo_id = cp_uoo_id
        AND    uai.logical_delete_dt IS NULL;
      --
      usc_ass_rec                   c_usc_ass%ROWTYPE;
      --
    BEGIN
      --
      gv_log_created := FALSE;
      p_creation_dt := NULL;
      --
      -- Select all person_id's from todo table with logical delete date NULL
      -- and todo date < SYSDATE and todo type in
      -- ('ASS_INSERT', 'ASS_STATUS', 'ASS_CHANGE').
      -- Also items must be within the specified parameters with which this process
      -- has  been called.
      --
      v_key := cst_key_label;
      v_previous_student := 0;
      v_previous_unit := cst_none;
      FOR v_todo_rec IN c_todo LOOP
        --
        -- Issue a savepoint for the todo record processing.
        --
        SAVEPOINT sp_todo_ref;
        --
        -- Initialise the logging structure.
        --
        igs_ge_ins_sle.genp_set_log_cntr;
        v_error_count := 0;
        v_warning_count := 0;
        v_delete_todo := TRUE;
        v_sle_key :=    TO_CHAR (v_todo_rec.person_id)
                     || '|'
                     || v_todo_rec.course_cd
                     || '|'
                     || v_todo_rec.unit_cd
                     || '|'
                     || v_todo_rec.version_number
                     || '|'
                     || v_todo_rec.cal_type
                     || '|'
                     || v_todo_rec.ci_sequence_number
                     || '|'
                     || v_todo_rec.uoo_id;
        --
        -- Log the count of students processed per unit.
        --
        IF (v_previous_student <> v_todo_rec.person_id)
           OR (v_previous_unit <> v_todo_rec.unit_cd) THEN
          --
          -- Set the previous information
          --
          v_previous_student := v_todo_rec.person_id;
          v_previous_unit := v_todo_rec.unit_cd;
          v_new_student := TRUE;
        ELSE
          v_new_student := FALSE;
        END IF;
        --
        -- Items are no longer deleted when the status is altered from ENROLLED
        -- (ie. no IGS_PE_STD_TODO item created). (assp_ins_suaai_todo altered).
        -- Hence, need to perform the processing associated with a change
        -- as it is possible that if the student unit attempt was altered in status,
        -- then while in the altered status e.g., INVALID, the unit offering option
        -- was changed. Hence, when becoming enrolled, need to check if any
        -- items/patterns should be removed.
        --
        IF  v_todo_rec.s_student_todo_type IN (cst_ass_change, cst_ass_insert)
            AND v_delete_todo = TRUE THEN
          --
          -- Check if any active Assessment Items are setup at Unit Section level
          -- If Yes, then attach the Unit Section Assessment Item Groups and
          -- Unit Section Assessment Items to the student
          -- If No, then attach the Unit Assessment Item Groups and Unit
          -- Assessment Items to the student
          --
          OPEN c_usc_ass (v_todo_rec.uoo_id);
          FETCH c_usc_ass INTO usc_ass_rec;
          IF c_usc_ass%FOUND THEN
            CLOSE c_usc_ass;
            --
            -- Perform a routine that will check if assessment items still apply to
            -- the students new unit attempt or should they be logically deleted
            -- and default assessment items assigned for the new Unit Section.
            --
            IF (igs_as_gen_005.assp_upd_usec_suaai_dflt (
                  v_todo_rec.person_id,
                  v_todo_rec.course_cd,
                  v_todo_rec.unit_cd,
                  v_todo_rec.version_number,
                  v_todo_rec.cal_type,
                  v_todo_rec.ci_sequence_number,
                  v_todo_rec.location_cd,
                  v_todo_rec.unit_class,
                  v_todo_rec.uoo_id,
                  cst_ass3212,
                  v_key,
                  v_sle_key,
                  v_error_count,
                  v_warning_count,
                  v_message_name
                ) = FALSE
               ) THEN
              --
              -- A lock has occurred so the todo item has been rolled back to be
              -- processed at a later date. Do not delete the todo item.
              --
              v_delete_todo := FALSE;
            END IF;
          ELSE
            CLOSE c_usc_ass;
            --
            -- Perform a routine that will check if assessment items still apply
            -- to the student's new unit attempt or should they be logically
            -- deleted and default items assigned.
            --
            IF igs_as_gen_005.assp_upd_suaai_dflt (
                 v_todo_rec.person_id,
                 v_todo_rec.course_cd,
                 v_todo_rec.unit_cd,
                 v_todo_rec.cal_type,
                 v_todo_rec.ci_sequence_number,
                 v_todo_rec.version_number,
                 v_todo_rec.location_cd,
                 v_todo_rec.unit_class,
                 v_todo_rec.unit_mode,
                 cst_ass3212,
                 v_key,
                 v_sle_key,
                 v_error_count,
                 v_warning_count,
                 v_message_name,
                 v_todo_rec.uoo_id
               ) = FALSE THEN
              --
              -- A lock has occurred so the todo item has been rolled back to be
              -- processed at a later date. Do not delete the todo item.
              --
              v_delete_todo := FALSE;
            END IF;
          END IF;
        END IF;
        IF v_delete_todo = TRUE THEN
          --
          -- Logically delete the IGS_PE_STD_TODO_REF table and determine if it was the
          -- last IGS_PE_STD_TODO_REF item for the IGS_PE_STD_TODO entry. If so, then
          -- logically delete the IGS_PE_STD_TODO entry.
          -- If a lock occurs on the item, rollback the whole event for
          -- this todo item. (Will also need a commit so that it can be restartable.)
          --
          IF igs_ge_gen_003.genp_upd_str_lgc_del (
               v_todo_rec.person_id,
               v_todo_rec.s_student_todo_type,
               v_todo_rec.sequence_number,
               v_todo_rec.reference_number,
               v_message_name
             ) = FALSE THEN
            --
            -- Log the exception to the system log table.
            --
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3212,
              v_key,
              v_sle_key,
              'IGS_AS_UNABLE_LOGDEL_STUD_TOD', -- Error, unable to logically delele item.
              cst_error_stdnt_todo
            );
            v_error_count := v_error_count + 1;
            --
            -- Roll back any processing for this todo reference item.
            --
            ROLLBACK TO sp_todo_ref;
          END IF;
        ELSE
          --
          -- Error has occurred. Roll back any processing for this todo reference item.
          --
          ROLLBACK TO sp_todo_ref;
          igs_ge_ins_sle.genp_set_log_entry (
            cst_ass3212,
            v_key,
            v_sle_key,
            'IGS_AS_PROCESS_SUA_ROLLEDBACK', -- Processing rolled back due to error.
            cst_information
          );
        END IF;
        igs_ge_ins_sle.genp_ins_sle (v_log_dt);
        v_record := cst_error_count;
        --
        -- Increment the count of errors.
        --
        igs_ge_gen_003.genp_set_sle_count (
          cst_ass3212,
          v_key,
          v_record,
          'IGS_AS_TOTAL_ERRO_COUNT', -- message number - Total errors.
          v_error_count, -- count increment
          v_log_dt,
          v_total_count
        );
        v_record := cst_warning_count;
        --
        -- Increment the count of errors.
        --
        igs_ge_gen_003.genp_set_sle_count (
          cst_ass3212,
          v_key,
          v_record,
          'IGS_AS_TOTAL_WRNG_COUNT', -- message number - Total errors.
          v_warning_count, -- count increment
          v_log_dt,
          v_total_count
        );
        IF v_new_student = TRUE THEN
          v_record :=    cst_unit_stdnt_count
                      || v_todo_rec.unit_cd
                      || '|'
                      || TO_CHAR (v_todo_rec.version_number)
                      || '|'
                      || v_todo_rec.cal_type
                      || '|'
                      || TO_CHAR (v_todo_rec.ci_sequence_number)
                      || '|'
                      || TO_CHAR (v_todo_rec.uoo_id);
          --
          -- Increment the count of students per unit.
          --
          igs_ge_gen_003.genp_set_sle_count (
            cst_ass3212,
            v_key,
            v_record,
            'IGS_AS_TOTAL_STUD_PROCESSED', -- message number
            1, -- count increment
            v_log_dt,
            v_total_count
          );
        END IF;
        --
        -- Commit the processing of the associated todo reference item.
        --
        COMMIT;
      END LOOP;
      --
      p_creation_dt := v_log_dt;
      --
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO sp_todo_ref;
        IF (c_todo%ISOPEN) THEN
          CLOSE c_todo;
        END IF;
        RAISE;
    END;
  END assp_prc_suaai_todo;
  --
  --
  --
  PROCEDURE assp_prc_uai_actn_dt (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_assessment_type              IN     VARCHAR2,
    p_ass_id                       IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_creation_dt                  OUT NOCOPY DATE
  ) IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_prc_uai_actn_dt
    --
    -- This routine will process all Unit Assessment Item records that are
    -- associated with maintaining the stdnt_unit_atmpt_ass_items for the
    -- students within the unit.
    -- This process will insert or logically delete the assessment items that
    -- should apply to the Student Unit Attempt where the student is enrolled
    -- in the unit.
    -- All Unit Assessment Items where the action_dt is less than the run date
    -- will have the action applied to students within the unit.
    --
    DECLARE
      cst_error_item_count CONSTANT VARCHAR2 (30)                 := 'ERROR_ITEM_COUNT|';
      cst_warn_item_count  CONSTANT VARCHAR2 (30)                 := 'WARNING_ITEM_COUNT|';
      cst_unit_item_count  CONSTANT VARCHAR2 (30)                 := 'UNIT_ITEM_COUNT|';
      cst_ass3213          CONSTANT VARCHAR2 (10)                 := 'ASS3213';
      cst_error            CONSTANT VARCHAR2 (10)                 := 'ERROR';
      cst_item             CONSTANT VARCHAR2 (10)                 := 'ITEM';
      v_clear_action_dt             BOOLEAN;
      v_record                      VARCHAR2 (255)                DEFAULT NULL;
      v_session_id                  igs_ge_s_log.KEY%TYPE         DEFAULT NULL;
      v_message_name                VARCHAR2 (30);
      v_error_count                 NUMBER                        DEFAULT 0;
      v_warning_count               NUMBER                        DEFAULT 0;
      v_total_count                 NUMBER                        DEFAULT 0;
      v_creation_dt                 DATE                          DEFAULT NULL;
      v_key                         igs_ge_s_log_entry.KEY%TYPE   DEFAULT 'MAINTAIN STUDENT UNIT ASSESSMENT ITEMS';
      v_sle_key                     igs_ge_s_log_entry.KEY%TYPE   DEFAULT NULL;
      --
      -- Included one more select clause in the below cursor to select the
      -- assessment item set up at unit section level as a part of calculation
      -- of records -1 bug n0:2162831
      --
      CURSOR c_uai IS
        SELECT usai.rowid row_id,
               uai.unit_cd,
               uai.version_number,
               uai.cal_type,
               uai.ci_sequence_number,
               usai.uoo_id,
               usai.unit_section_ass_item_id ass_item_id,
               usai.us_ass_item_group_id group_id,
               usai.ass_id ass_id,
               usai.ass_id assessment_id,
               usai.sequence_number,
               uai.location_cd,
               uai.unit_class,
               uc.unit_mode,
               usai.logical_delete_dt,
               'USEC' record_ind,
               usai.midterm_mandatory_type_code,
               usai.midterm_weight_qty,
               usai.final_mandatory_type_code,
               usai.final_weight_qty,
               usai.grading_schema_cd,
               usai.gs_version_number
        FROM   igs_ps_unitass_item usai,
               igs_as_assessmnt_itm ai,
               igs_ps_unit_ofr_opt uai,
               igs_as_unit_class uc,
               igs_ca_inst_rel cir
        WHERE  usai.uoo_id = uai.uoo_id
        AND    uai.unit_class = uc.unit_class
        AND    uc.closed_ind = 'N'
        AND    usai.ass_id = ai.ass_id
        AND    (p_teach_perd_cal_type IS NULL
                OR uai.cal_type = p_teach_perd_cal_type
               )
        AND    (p_teach_perd_sequence_number IS NULL
                OR uai.ci_sequence_number = p_teach_perd_sequence_number
               )
        AND    uai.unit_cd LIKE p_unit_cd
        AND    cir.sup_cal_type            = p_acad_perd_cal_type
        AND    cir.sup_ci_sequence_number  = p_acad_perd_sequence_number
        AND    cir.sub_cal_type            = uai.cal_type
        AND    cir.sub_ci_sequence_number  = uai.ci_sequence_number
        AND    (p_version_number IS NULL
                OR uai.version_number = p_version_number
               )
        AND    (p_assessment_type IS NULL
                OR ai.assessment_type LIKE p_assessment_type
               )
        AND    (p_ass_id IS NULL
                OR usai.ass_id = p_ass_id
               )
        AND    usai.action_dt <= SYSDATE
        AND    EXISTS ( SELECT 'X'
                        FROM   igs_ps_unit_ver uv,
                               igs_ps_unit_stat us
                        WHERE  uv.unit_cd = uai.unit_cd
                        AND    uv.version_number = uai.version_number
                        AND    uv.unit_status = us.unit_status
                        AND    us.s_unit_status = 'ACTIVE')
        UNION ALL
        SELECT uai.rowid row_id,
               uai.unit_cd,
               uai.version_number,
               uai.cal_type,
               uai.ci_sequence_number,
               TO_NUMBER (NULL) uoo_id,
               uai.unit_ass_item_id ass_item_id,
               uai.unit_ass_item_group_id group_id,
               uai.ass_id,
               uai.ass_id assessment_id,
               uai.sequence_number,
               NULL,
               NULL,
               NULL,
               uai.logical_delete_dt,
               'UNIT' record_ind,
               uai.midterm_mandatory_type_code,
               uai.midterm_weight_qty,
               uai.final_mandatory_type_code,
               uai.final_weight_qty,
               uai.grading_schema_cd,
               uai.gs_version_number
        FROM   igs_as_unitass_item uai,
               igs_as_assessmnt_itm ai,
               igs_ca_inst_rel cir
        WHERE  uai.ass_id = ai.ass_id
        AND    (p_teach_perd_cal_type IS NULL
                OR uai.cal_type = p_teach_perd_cal_type
               )
        AND    (p_teach_perd_sequence_number IS NULL
                OR uai.ci_sequence_number = p_teach_perd_sequence_number
               )
        AND    uai.unit_cd LIKE p_unit_cd
        AND    cir.sup_cal_type            = p_acad_perd_cal_type
        AND    cir.sup_ci_sequence_number  = p_acad_perd_sequence_number
        AND    cir.sub_cal_type            = uai.cal_type
        AND    cir.sub_ci_sequence_number  = uai.ci_sequence_number
        AND    (p_version_number IS NULL
                OR uai.version_number = p_version_number
               )
        AND    (p_assessment_type IS NULL
                OR ai.assessment_type LIKE p_assessment_type
               )
        AND    (p_ass_id IS NULL
                OR uai.ass_id = p_ass_id
               )
        AND    uai.action_dt <= SYSDATE
        AND    EXISTS ( SELECT 'X'
                        FROM   igs_ps_unit_ver uv,
                               igs_ps_unit_stat us
                        WHERE  uv.unit_cd = uai.unit_cd
                        AND    uv.version_number = uai.version_number
                        AND    uv.unit_status = us.unit_status
                        AND    us.s_unit_status = 'ACTIVE')
       ORDER BY unit_cd,
                version_number,
                cal_type,
                ci_sequence_number,
                group_id,
                assessment_id;
      --
      --
      --
      PROCEDURE asspl_prc_update_uai (
        p_unit_cd                             igs_as_unitass_item.unit_cd%TYPE,
        p_version_number                      igs_as_unitass_item.version_number%TYPE,
        p_cal_type                            igs_as_unitass_item.cal_type%TYPE,
        p_ci_sequence_number                  igs_as_unitass_item.ci_sequence_number%TYPE,
        p_ass_id                              igs_as_unitass_item.ass_id%TYPE,
        p_sequence_number                     igs_as_unitass_item.sequence_number%TYPE,
        p_session_id                          igs_ge_s_log.KEY%TYPE,
        p_log_dt                       IN OUT NOCOPY DATE
      ) IS
        gv_other_detail VARCHAR2 (255);
      BEGIN -- asspl_prc_update_uai
        -- Select the IGS_AS_UNITASS_ITEM table for update NOWAIT and set
        -- the action date to null.
        -- If a lock occurs, then commit the processing anyway but report on
        -- the exception. No need to rollback as processing completed. If the
        -- item and action date is processed again then no changes will occur
        -- but there will be processing done for nothing.
        DECLARE
          e_resource_busy EXCEPTION;
          PRAGMA EXCEPTION_INIT (e_resource_busy,  -54);
          CURSOR c_uai_upd IS
            SELECT        ROWID,
                          uai.*
            FROM          igs_as_unitass_item uai
            WHERE         uai.unit_cd = p_unit_cd
            AND           uai.version_number = p_version_number
            AND           uai.cal_type = p_cal_type
            AND           uai.ci_sequence_number = p_ci_sequence_number
            AND           uai.ass_id = p_ass_id
            AND           uai.sequence_number = p_sequence_number
            FOR UPDATE OF action_dt NOWAIT;
          v_uai_upd_rec   c_uai_upd%ROWTYPE;
        BEGIN
          OPEN c_uai_upd;
          FETCH c_uai_upd INTO v_uai_upd_rec;
          IF c_uai_upd%NOTFOUND THEN
            CLOSE c_uai_upd;
            RAISE NO_DATA_FOUND;
          ELSE
            igs_as_unitass_item_pkg.update_row (
              x_rowid                        => v_uai_upd_rec.ROWID,
              x_unit_ass_item_id             => v_uai_upd_rec.unit_ass_item_id,
              x_unit_cd                      => v_uai_upd_rec.unit_cd,
              x_version_number               => v_uai_upd_rec.version_number,
              x_cal_type                     => v_uai_upd_rec.cal_type,
              x_ci_sequence_number           => v_uai_upd_rec.ci_sequence_number,
              x_ass_id                       => v_uai_upd_rec.ass_id,
              x_sequence_number              => v_uai_upd_rec.sequence_number,
              x_ci_start_dt                  => v_uai_upd_rec.ci_start_dt,
              x_ci_end_dt                    => v_uai_upd_rec.ci_end_dt,
              x_unit_class                   => v_uai_upd_rec.unit_class,
              x_unit_mode                    => v_uai_upd_rec.unit_mode,
              x_location_cd                  => v_uai_upd_rec.location_cd,
              x_due_dt                       => v_uai_upd_rec.due_dt,
              x_reference                    => v_uai_upd_rec.REFERENCE,
              x_dflt_item_ind                => v_uai_upd_rec.dflt_item_ind,
              x_logical_delete_dt            => v_uai_upd_rec.logical_delete_dt,
              x_action_dt                    => NULL,
              x_exam_cal_type                => v_uai_upd_rec.exam_cal_type,
              x_exam_ci_sequence_number      => v_uai_upd_rec.exam_ci_sequence_number,
              x_mode                         => 'R',
              x_grading_schema_cd            => v_uai_upd_rec.grading_schema_cd,
              x_gs_version_number            => v_uai_upd_rec.gs_version_number,
              x_release_date                 => v_uai_upd_rec.release_date,
              x_description                  => v_uai_upd_rec.description,
              x_unit_ass_item_group_id       => v_uai_upd_rec.unit_ass_item_group_id,
              x_midterm_mandatory_type_code  => v_uai_upd_rec.midterm_mandatory_type_code,
              x_midterm_weight_qty           => v_uai_upd_rec.midterm_weight_qty,
              x_final_mandatory_type_code    => v_uai_upd_rec.final_mandatory_type_code,
              x_final_weight_qty             => v_uai_upd_rec.final_weight_qty
            );
          END IF;
          IF c_uai_upd%ISOPEN THEN
            CLOSE c_uai_upd;
          END IF;
        EXCEPTION
          WHEN e_resource_busy THEN
            v_sle_key :=    cst_item
                         || '|'
                         || TO_CHAR (p_ass_id)
                         || '|'
                         || NULL
                         || '|'
                         || NULL
                         || '|'
                         || p_unit_cd
                         || '|'
                         || TO_CHAR (p_version_number)
                         || '|'
                         || p_cal_type
                         || '|'
                         || TO_CHAR (p_ci_sequence_number);
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3213,
              v_key,
              v_sle_key,
              'IGS_AS_UNABLE_CLEAR_ACTDT_UAI', -- Record locked..
              cst_error || '|' || cst_item || '|' || TO_CHAR (p_ass_id) || '|'
            );
            -- No need to rollback as processing completed.
            -- Commit the changes as all processing completed successfully except
            -- for the clearing of the action date. This will mean this item can
            -- be processed again but no changes will occur.
            v_error_count := v_error_count + 1;
          WHEN OTHERS THEN
            fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token ('NAME', 'IGS_AS_GEN_007.asspl_prc_update_uai');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
            RAISE;
        END;
      END asspl_prc_update_uai;
      --
      -- Included the below to update action date in IGS_PS_UNITASS_ITEM in case
      -- of assessment item setup is present at unit section level
      -- as a part of calculation of records -1 bug n0:2162831
      --
      PROCEDURE asspl_prc_upd_usec_uai (
        p_uoo_id                              igs_ps_unitass_item.uoo_id%TYPE,
        p_ass_id                              igs_ps_unitass_item.ass_id%TYPE,
        p_sequence_number                     igs_ps_unitass_item.sequence_number%TYPE,
        p_session_id                          igs_ge_s_log.KEY%TYPE,
        p_log_dt                       IN OUT NOCOPY DATE
      ) IS
        gv_other_detail VARCHAR2 (255);
      BEGIN -- asspl_prc_upd_usec_uai
        --
        -- Select the IGS_PS_UNITASS_ITEM table for update NOWAIT and set
        -- the action date to null.
        -- If a lock occurs, then commit the processing anyway but report on
        -- the exception. No need to rollback as processing completed. If the
        -- item and action date is processed again then no changes will occur
        -- but there will be processing done for nothing.
        --
        DECLARE
          e_resource_busy    EXCEPTION;
          PRAGMA EXCEPTION_INIT (e_resource_busy,  -54);
          CURSOR c_uai_upd_usec IS
            SELECT        ROWID,
                          pai.*
            FROM          igs_ps_unitass_item pai
            WHERE         pai.uoo_id = p_uoo_id
            AND           pai.ass_id = p_ass_id
            AND           pai.sequence_number = p_sequence_number
            FOR UPDATE OF action_dt NOWAIT;
          v_uai_upd_usec_rec c_uai_upd_usec%ROWTYPE;
        BEGIN
          OPEN c_uai_upd_usec;
          FETCH c_uai_upd_usec INTO v_uai_upd_usec_rec;
          IF c_uai_upd_usec%NOTFOUND THEN
            CLOSE c_uai_upd_usec;
            RAISE NO_DATA_FOUND;
          ELSE
            igs_ps_unitass_item_pkg.update_row (
              x_rowid                        => v_uai_upd_usec_rec.ROWID,
              x_unit_section_ass_item_id     => v_uai_upd_usec_rec.unit_section_ass_item_id,
              x_uoo_id                       => v_uai_upd_usec_rec.uoo_id,
              x_ass_id                       => v_uai_upd_usec_rec.ass_id,
              x_sequence_number              => v_uai_upd_usec_rec.sequence_number,
              x_ci_start_dt                  => v_uai_upd_usec_rec.ci_start_dt,
              x_ci_end_dt                    => v_uai_upd_usec_rec.ci_end_dt,
              x_due_dt                       => v_uai_upd_usec_rec.due_dt,
              x_reference                    => v_uai_upd_usec_rec.REFERENCE,
              x_dflt_item_ind                => v_uai_upd_usec_rec.dflt_item_ind,
              x_logical_delete_dt            => v_uai_upd_usec_rec.logical_delete_dt,
              x_action_dt                    => NULL,
              x_exam_cal_type                => v_uai_upd_usec_rec.exam_cal_type,
              x_exam_ci_sequence_number      => v_uai_upd_usec_rec.exam_ci_sequence_number,
              x_mode                         => 'R',
              x_grading_schema_cd            => v_uai_upd_usec_rec.grading_schema_cd,
              x_gs_version_number            => v_uai_upd_usec_rec.gs_version_number,
              x_release_date                 => v_uai_upd_usec_rec.release_date,
              x_description                  => v_uai_upd_usec_rec.description,
              x_us_ass_item_group_id         => v_uai_upd_usec_rec.us_ass_item_group_id,
              x_midterm_mandatory_type_code  => v_uai_upd_usec_rec.midterm_mandatory_type_code,
              x_midterm_weight_qty           => v_uai_upd_usec_rec.midterm_weight_qty,
              x_final_mandatory_type_code    => v_uai_upd_usec_rec.final_mandatory_type_code,
              x_final_weight_qty             => v_uai_upd_usec_rec.final_weight_qty
            );
          END IF;
          IF c_uai_upd_usec%ISOPEN THEN
            CLOSE c_uai_upd_usec;
          END IF;
        EXCEPTION
          WHEN e_resource_busy THEN
            v_sle_key :=    cst_item
                         || '|'
                         || TO_CHAR (p_ass_id)
                         || '|'
                         || NULL
                         || '|'
                         || NULL
                         || '|'
                         || p_uoo_id
                         || '|'
                         || NULL
                         || '|'
                         || NULL
                         || '|'
                         || TO_CHAR (p_sequence_number);
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3213,
              v_key,
              v_sle_key,
              'IGS_AS_UNABLE_CLEAR_ACTDT_UAI', -- Record locked..
              cst_error || '|' || cst_item || '|' || TO_CHAR (p_ass_id) || '|'
            );
            --
            -- No need to rollback as processing completed.
            -- Commit the changes as all processing completed successfully except
            -- for the clearing of the action date. This will mean this item can
            -- be processed again but no changes will occur.
            --
            v_error_count := v_error_count + 1;
          WHEN OTHERS THEN
            fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token ('NAME', 'IGS_AS_GEN_007.asspl_prc_upd_usec_uai');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
            RAISE;
        END;
      END asspl_prc_upd_usec_uai;
      --
    BEGIN
      --
      -- Select all assessment items within the specified parameters that have an
      -- action date less than or equal to the current date.
      --
      FOR v_uai_rec IN c_uai LOOP
        BEGIN
        SAVEPOINT sp_uai_actn;
        --
        -- Initialise the logging structure.
        --
        igs_ge_ins_sle.genp_set_log_cntr;
        v_error_count := 0;
        v_warning_count := 0;
        v_clear_action_dt := TRUE;
        --
        IF v_uai_rec.logical_delete_dt IS NOT NULL THEN
          --
          -- Perform processing to logically delete any assessment items for
          -- students in the unit. If locking error occurs then set a flag
          -- to roll back processing associated with the Unit Assessment Item
          -- record so that all can be processed again at a later date.
          -- Report on the exception.
          -- Logically delete the associated suaai record for the Unit Assessment Item.
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
          WHERE  suaai.uoo_id = NVL (v_uai_rec.uoo_id, suaai.uoo_id)
          AND    suaai.cal_type = v_uai_rec.cal_type
          AND    suaai.ci_sequence_number = v_uai_rec.ci_sequence_number
          AND    suaai.ass_id = v_uai_rec.ass_id
          AND    suaai.unit_cd = v_uai_rec.unit_cd
          AND    suaai.logical_delete_dt IS NULL
          AND    suaai.attempt_number = (SELECT MAX (suaai2.attempt_number)
                                         FROM   igs_as_su_atmpt_itm suaai2
                                         WHERE  suaai2.person_id = suaai.person_id
                                         AND    suaai2.course_cd = suaai.course_cd
                                         AND    suaai2.uoo_id = suaai.uoo_id
                                         AND    suaai2.ass_id = suaai.ass_id
                                         AND    (suaai2.unit_section_ass_item_id  = suaai.unit_section_ass_item_id
                                         OR      suaai2.unit_ass_item_id = suaai.unit_ass_item_id))
          AND    (suaai.unit_section_ass_item_id  = v_uai_rec.ass_item_id
          OR      suaai.unit_ass_item_id = v_uai_rec.ass_item_id)
          AND    EXISTS (
                   SELECT 'X'
                   FROM   igs_en_su_attempt_all sua
                   WHERE  sua.person_id = suaai.person_id
                   AND    sua.course_cd = suaai.course_cd
                   AND    sua.uoo_id = suaai.uoo_id
                   AND    sua.unit_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'WAITLISTED')
                 );
        ELSE -- uai.logical_delete_dt is NULL
          --
          -- Perform processing to insert/update the students assessment items.
          -- Will first need to verify if the assessment item exists for a student,
          -- that it is still valid. If not then logically delete it.
          -- Will need to attempt to insert the item as it may not have existed
          -- for the student in the first place.
          -- If locking error occurs then set a flag to roll back processing
          -- associated with the IGS_AS_UNITASS_ITEM record so that all can be
          -- processed again at a later date. Report on the exception.
          --
          IF NOT igs_as_gen_005.assp_mnt_suaai_uai (
                   v_uai_rec.unit_cd,
                   v_uai_rec.version_number,
                   v_uai_rec.cal_type,
                   v_uai_rec.ci_sequence_number,
                   v_uai_rec.ass_id,
                   v_uai_rec.location_cd,
                   v_uai_rec.unit_class,
                   v_uai_rec.unit_mode,
                   cst_ass3213,
                   v_key,
                   v_sle_key,
                   v_error_count,
                   v_warning_count,
                   v_message_name,
                   v_uai_rec.record_ind,
                   v_uai_rec.ass_item_id ,
                   v_uai_rec.group_id,
                   v_uai_rec.midterm_mandatory_type_code ,
                   v_uai_rec.midterm_weight_qty ,
                   v_uai_rec.final_mandatory_type_code ,
                   v_uai_rec.final_weight_qty ,
                   v_uai_rec.grading_schema_cd ,
                   v_uai_rec.gs_version_number,
                   v_uai_rec.uoo_id
                 ) THEN
            -- Locking error has occurred, initialise the logging
            -- structure so that the exception report does not
            -- report on processing that will be rolled back.
            -- Initialise the logging structure.
            igs_ge_ins_sle.genp_set_log_cntr;
            -- Reset the error and warning counts.
            v_error_count := 1;
            v_warning_count := 0;
            -- Report the error for the lock as re-initialising
            -- logging structure has also removed the locking
            -- error. Processing  for the unit assessment item
            -- is to be rolled back.
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3213,
              v_key,
              v_sle_key,
              v_message_name, -- Record locked..
              cst_error || '|' || cst_item || '|' || TO_CHAR (v_uai_rec.ass_id) || '|'
            );
            v_clear_action_dt := FALSE;
          END IF;
        END IF; --uai.logical_delete_dt is NOT NULL
        --
        -- Included code for checking the value of record_ind to set the value
        -- of action date at unit section level/unit offering level as a part
        -- of calculation of records -1 bug n0:2162831
        --
        IF v_uai_rec.record_ind = 'USEC' THEN
          IF v_clear_action_dt THEN
            UPDATE igs_ps_unitass_item
            SET    action_dt = NULL,
                   last_update_date = SYSDATE,
                   last_updated_by = fnd_global.user_id,
                   last_update_login = fnd_global.login_id,
                   request_id = fnd_global.conc_request_id,
                   program_id = fnd_global.conc_program_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_update_date = SYSDATE
            WHERE  rowid = v_uai_rec.row_id;
          ELSE
            -- Rollback all processing associated with this item and log
            -- the exception. Continue processing other items.
            ROLLBACK TO sp_uai_actn;
            -- v_sle_key gets set previously
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3213,
              v_key,
              v_sle_key,
              'IGS_AS_UAI_ROLLED_BACK', -- Error, processing will be rolled back.
              cst_error || '|' || cst_item || '|' || TO_CHAR (v_uai_rec.ass_id) || '|'
            );
          END IF;
        ELSIF v_uai_rec.record_ind = 'UNIT' THEN
          IF v_clear_action_dt THEN
            UPDATE igs_as_unitass_item
            SET    action_dt = NULL,
                   last_update_date = SYSDATE,
                   last_updated_by = fnd_global.user_id,
                   last_update_login = fnd_global.login_id,
                   request_id = fnd_global.conc_request_id,
                   program_id = fnd_global.conc_program_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_update_date = SYSDATE
            WHERE  rowid = v_uai_rec.row_id;
          ELSE
            -- Rollback all processing associated with this item and log
            -- the exception. Continue processing other items.
            ROLLBACK TO sp_uai_actn;
            -- v_sle_key gets set previously
            igs_ge_ins_sle.genp_set_log_entry (
              cst_ass3213,
              v_key,
              v_sle_key,
              'IGS_AS_UAI_ROLLED_BACK', -- Error, processing will be rolled back.
              cst_error || '|' || cst_item || '|' || TO_CHAR (v_uai_rec.ass_id) || '|'
            );
          END IF;
        END IF;
        -- Create any Exception records.
        igs_ge_ins_sle.genp_ins_sle (v_creation_dt);
        v_record := cst_error_item_count;
        -- Increment the count of errors.
        igs_ge_gen_003.genp_set_sle_count (
          cst_ass3213,
          v_key,
          v_record,
          'IGS_AS_TOTAL_ERRO_COUNT', -- message number - Total errors.
          v_error_count, -- count increment
          v_creation_dt,
          v_total_count
        );
        v_record := cst_warn_item_count;
        -- Increment the count of errors.
        igs_ge_gen_003.genp_set_sle_count (
          cst_ass3213,
          v_key,
          v_record,
          'IGS_AS_TOTAL_WRNG_COUNT', -- message number - Total errors.
          v_warning_count, -- count increment
          v_creation_dt,
          v_total_count
        );
        v_record := cst_unit_item_count;
        -- Increment the count of unit assessment items processed.
        igs_ge_gen_003.genp_set_sle_count (
          cst_ass3213,
          v_key,
          v_record,
          'IGS_AS_TOTAL_UNIT_ASSITEM', -- message number
          1, -- count increment
          v_creation_dt,
          v_total_count
        );
        -- Perform commit to save any exception logging or
        -- commit processing applied for each modified unit assessment item.
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO sp_uai_actn;
          fnd_file.put_line (
            fnd_file.log,
            substrb('Error for : uoo_id=>' || v_uai_rec.uoo_id || ';' ||
                    'ass_id=>' || v_uai_rec.ass_id || ';' ||
                    'record_ind=>' || v_uai_rec.record_ind || ';' ||
                    'ass_item_id=>' || v_uai_rec.ass_item_id || ';' ||
                    'group_id=>' || v_uai_rec.group_id || ';' ||
                    'SQL Error: ' || SQLERRM, 1, 255));
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string (
                fnd_log.level_exception, g_module_head || 'assp_prc_uai_actn_dt.c_uai_exception',
                  'Error for : uoo_id=>' || v_uai_rec.uoo_id || ';' ||
                  'ass_id=>' || v_uai_rec.ass_id || ';' ||
                  'record_ind=>' || v_uai_rec.record_ind || ';' ||
                  'ass_item_id=>' || v_uai_rec.ass_item_id || ';' ||
                  'group_id=>' || v_uai_rec.group_id || ';' ||
                  'SQL Error: ' || SQLERRM
                );
          END IF;
      END;
      END LOOP;
      p_creation_dt := v_creation_dt;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_007.assp_prc_uai_actn_dt');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_prc_uai_actn_dt;
  --
  --
  --
  PROCEDURE assp_prc_uap_actn_dt (
    p_acad_perd_cal_type           IN     VARCHAR2,
    p_acad_perd_sequence_number    IN     NUMBER,
    p_teach_perd_cal_type          IN     VARCHAR2,
    p_teach_perd_sequence_number   IN     NUMBER,
    p_unit_cd                      IN     VARCHAR2,
    p_version_number               IN     NUMBER,
    p_ass_pattern_id               IN     NUMBER,
    p_s_log_type                   IN     VARCHAR2,
    p_key                          IN     VARCHAR2,
    p_creation_dt                  IN OUT NOCOPY DATE
  ) IS
  BEGIN
    --
    -- This procedure is obsolete as the Grade Book Enhancement obsoleted the
    -- Assessment Patterns functionality
    --
    p_creation_dt := NULL;
  END assp_prc_uap_actn_dt;

  PROCEDURE assp_upd_finls_outcm (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_assess_calendar              IN     VARCHAR2,
    p_teaching_calendar            IN     VARCHAR2,
    p_crs_grp_cd                   IN     VARCHAR2,
    p_crs_cd                       IN     VARCHAR2,
    p_crs_org_unt_cd               IN     VARCHAR2,
    p_crs_lctn_cd                  IN     VARCHAR2,
    p_crs_attd_md                  IN     VARCHAR2,
    p_unt_cd                       IN     VARCHAR2,
    p_unt_org_unt_cd               IN     VARCHAR2,
    p_unt_lctn_cd                  IN     VARCHAR2,
    p_u_mode                       IN     VARCHAR2,
    p_u_class                      IN     VARCHAR2,
    p_allow_invalid_ind            IN     VARCHAR2,
    p_org_id                       IN     NUMBER
  ) IS
  BEGIN
    --
    retcode := 0;
    --
    -- As per 2239087, this concurrent program is obsolete and if the user
    -- tries to run this program then an error message should be logged into the log
    -- file that the concurrent program is obsolete and should not be run.
    --
    fnd_message.set_name ('IGS', 'IGS_GE_OBSOLETE_JOB');
    fnd_file.put_line (fnd_file.LOG, fnd_message.get);
    --
  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      igs_ge_msg_stack.conc_exception_hndl;
  END assp_upd_finls_outcm;

  PROCEDURE assp_ins_suaai_todo (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_unit_cd                      IN     VARCHAR2,
    p_cal_type                            VARCHAR2,
    p_ci_sequence_number           IN     NUMBER,
    p_old_unit_attempt_status      IN     VARCHAR2,
    p_new_unit_attempt_status      IN     VARCHAR2,
    p_old_location_cd              IN     VARCHAR2,
    p_new_location_cd              IN     VARCHAR2,
    p_old_unit_class               IN     VARCHAR2,
    p_new_unit_class               IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER
  ) IS
    gv_other_detail VARCHAR2 (255);
  BEGIN -- assp_ins_suaai_todo
    -- This routine will create a IGS_PE_STD_TODO entry for students who:
    -- 1. have just enrolled
    -- 2. had their location and class details changed
    DECLARE
      cst_enrolled   CONSTANT igs_en_su_attempt.unit_attempt_status%TYPE   := 'ENROLLED';
      cst_completed  CONSTANT igs_en_su_attempt.unit_attempt_status%TYPE   := 'COMPLETED';
      cst_ass_insert CONSTANT VARCHAR2 (15)                                := 'ASS_INSERT';
      cst_ass_change CONSTANT VARCHAR2 (15)                                := 'ASS_CHANGE';
      cst_yes        CONSTANT CHAR                                         := 'Y';
      v_return_val            NUMBER;
      v_s_student_todo_type   VARCHAR2 (15);
      v_todo_flag             BOOLEAN;
    BEGIN
      v_todo_flag := FALSE;
      -- Check to see if inserting or updating the record to an ENROLLED status.
      -- If so, then create a IGS_PE_STD_TODO record
      IF (p_new_unit_attempt_status = cst_enrolled
          AND NVL (p_old_unit_attempt_status, 'NULL') NOT IN (cst_enrolled, cst_completed)
         ) THEN
        v_s_student_todo_type := cst_ass_insert;
        v_todo_flag := TRUE;
      -- Check if an enrolled unit offering has altered location or class.
      ELSIF  (p_new_location_cd <> NVL (p_old_location_cd, p_new_location_cd)
              OR p_new_unit_class <> NVL (p_old_unit_class, p_new_unit_class)
             )
             AND (p_new_unit_attempt_status = cst_enrolled) THEN
        v_s_student_todo_type := cst_ass_change;
        v_todo_flag := TRUE;
      END IF;
      IF (v_todo_flag = TRUE) THEN
        v_return_val := igs_ge_gen_003.genp_ins_stdnt_todo (p_person_id, v_s_student_todo_type, SYSDATE, cst_yes);
        DECLARE
          l_val    NUMBER;
          lv_rowid VARCHAR2 (25);
        BEGIN
          SELECT igs_pe_std_todo_ref_rf_num_s.NEXTVAL
          INTO   l_val
          FROM   DUAL;
          igs_pe_std_todo_ref_pkg.insert_row (
            x_rowid                        => lv_rowid,
            x_person_id                    => p_person_id,
            x_s_student_todo_type          => v_s_student_todo_type,
            x_sequence_number              => v_return_val,
            x_reference_number             => l_val,
            x_cal_type                     => p_cal_type,
            x_ci_sequence_number           => p_ci_sequence_number,
            x_course_cd                    => p_course_cd,
            x_unit_cd                      => p_unit_cd,
            x_other_reference              => NULL,
            x_logical_delete_dt            => NULL,
            x_mode                         => 'R',
            x_uoo_id                       => p_uoo_id
          );
        END;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token ('NAME', 'IGS_AS_GEN_007.assp_ins_suaai_todo');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
  END assp_ins_suaai_todo;
END igs_as_gen_007;

/
