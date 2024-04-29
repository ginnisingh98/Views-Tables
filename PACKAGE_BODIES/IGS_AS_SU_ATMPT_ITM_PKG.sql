--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_ATMPT_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_ATMPT_ITM_PKG" AS
/* $Header: IGSDI08B.pls 120.0 2005/07/05 13:08:56 appldev noship $ */
  -- Bug No. 1956374 Procedure assp_val_suaai_ins reference is changed
  l_rowid        VARCHAR2 (25);
  l_altered_creation_dt DATE;
  old_references igs_as_su_atmpt_itm%ROWTYPE;
  new_references igs_as_su_atmpt_itm%ROWTYPE;
  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_person_id                    IN     NUMBER DEFAULT NULL,
    x_course_cd                    IN     VARCHAR2 DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_ass_id                       IN     NUMBER DEFAULT NULL,
    x_creation_dt                  IN     DATE DEFAULT NULL,
    x_attempt_number               IN     NUMBER DEFAULT NULL,
    x_outcome_dt                   IN     DATE DEFAULT NULL,
    x_override_due_dt              IN     DATE DEFAULT NULL,
    x_tracking_id                  IN     NUMBER DEFAULT NULL,
    x_logical_delete_dt            IN     DATE DEFAULT NULL,
    x_s_default_ind                IN     VARCHAR2 DEFAULT NULL,
    x_ass_pattern_id               IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_gs_version_number            IN     NUMBER DEFAULT NULL,
    x_grade                        IN     VARCHAR2 DEFAULT NULL,
    x_outcome_comment_code         IN     VARCHAR2 DEFAULT NULL,
    x_mark                         IN     NUMBER DEFAULT NULL,
    x_attribute_category           IN     VARCHAR2 DEFAULT NULL,
    x_attribute1                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute2                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute3                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute4                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute5                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute6                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute7                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute8                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute9                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute10                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute11                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute12                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute13                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute14                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute15                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute16                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute17                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute18                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute19                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute20                  IN     VARCHAR2 DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_unit_section_ass_item_id     IN     NUMBER DEFAULT NULL,
    x_unit_ass_item_id             IN     NUMBER DEFAULT NULL,
    x_sua_ass_item_group_id        IN     NUMBER DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL,
    x_submitted_date               IN     DATE DEFAULT NULL,
    x_waived_flag                  IN     VARCHAR2 DEFAULT NULL,
    x_penalty_applied_flag         IN     VARCHAR2 DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_as_su_atmpt_itm
      WHERE  ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF  (cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE cur_old_ref_values;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.ass_id := x_ass_id;
    new_references.creation_dt := x_creation_dt;
    new_references.attempt_number := x_attempt_number;
    new_references.outcome_dt := x_outcome_dt;
    new_references.override_due_dt := x_override_due_dt;
    new_references.tracking_id := x_tracking_id;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.s_default_ind := x_s_default_ind;
    new_references.ass_pattern_id := x_ass_pattern_id;
    new_references.grade := x_grade;
    new_references.outcome_comment_code := x_outcome_comment_code;
    new_references.mark := x_mark;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.uoo_id := x_uoo_id;
    new_references.unit_section_ass_item_id := x_unit_section_ass_item_id;
    new_references.unit_ass_item_id := x_unit_ass_item_id;
    new_references.sua_ass_item_group_id := x_sua_ass_item_group_id;
    new_references.midterm_mandatory_type_code := x_midterm_mandatory_type_code;
    new_references.midterm_weight_qty := x_midterm_weight_qty;
    new_references.final_mandatory_type_code := x_final_mandatory_type_code;
    new_references.final_weight_qty := x_final_weight_qty;
    new_references.submitted_date := x_submitted_date;
    new_references.waived_flag := x_waived_flag;
    new_references.penalty_applied_flag := x_penalty_applied_flag;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END set_column_values;

  PROCEDURE beforerowinsertupdate1 (
    p_inserting                    IN     BOOLEAN DEFAULT FALSE,
    p_updating                     IN     BOOLEAN DEFAULT FALSE,
    p_deleting                     IN     BOOLEAN DEFAULT FALSE
  ) /***********************************************************************************************************
    |Change  History :
    |Who             When                        What
    |
    |Aiyer         19-Apr-2002                   Modified for the bug #2323692
    |                                            Check that the Outcome comments field should have a comment when grqde or marks field
    |                                            is changed.
    *=======================================================================*************************************/
    AS
    v_message_name              VARCHAR2 (30);
    v_s_tracking_type           igs_tr_type.s_tracking_type%TYPE;
    v_s_tracking_status         igs_tr_status.s_tracking_status%TYPE;
    CURSOR cp_tri (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
      SELECT tt.s_tracking_type,
             trs.s_tracking_status
      FROM   igs_tr_item tri,
             igs_tr_type tt,
             igs_tr_status trs
      WHERE  tri.tracking_id = cp_tracking_id
      AND    tri.tracking_type = tt.tracking_type
      AND    tri.tracking_status = trs.tracking_status;
    cst_assignment     CONSTANT VARCHAR2 (10)                          := 'ASSIGNMENT';
    cst_assignment_due CONSTANT VARCHAR2 (10)                          := 'ASSIGN-DUE';
  BEGIN
    -- If p_inserting, validate that the assessment item is applicable to the
    -- student IGS_PS_UNIT attempt and that the IGS_PS_UNIT attempt status is ENROLLED or
    -- UNCONFIRMED.
    IF p_inserting THEN
      IF igs_as_val_scap.assp_val_suaai_ins (
           new_references.person_id,
           new_references.course_cd,
           new_references.unit_cd,
           new_references.cal_type,
           new_references.ci_sequence_number,
           new_references.ass_id,
           v_message_name,
           new_references.uoo_id
         ) = FALSE THEN
        -- Check message number and return the more appropriate message
        -- when status is completed.
        IF v_message_name = 'IGS_CA_AA_CIR_FK' THEN
          NULL;
        END IF;
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    -- If p_updating the override_due_dt, check if a tracking item exists and update
    -- the item. Validate that the tracking item is for an assignment.
    IF  p_updating
        AND (NVL (new_references.override_due_dt, igs_ge_date.igsdate ('1900/01/01')) <>
             NVL (old_references.override_due_dt, igs_ge_date.igsdate ('1900/01/01'))
            )
        AND new_references.tracking_id IS NOT NULL THEN
      OPEN cp_tri (new_references.tracking_id);
      FETCH cp_tri INTO v_s_tracking_type,
                        v_s_tracking_status;
      CLOSE cp_tri;
      IF v_s_tracking_type = cst_assignment THEN
        IF v_s_tracking_status <> 'ACTIVE' THEN
          -- Tracking item is no longer active
          fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
        ELSIF igs_tr_gen_002.trkp_upd_trst (
                new_references.tracking_id,
                NULL,
                cst_assignment_due,
                new_references.override_due_dt,
                NULL,
                NULL,
                NULL,
                NULL,
                v_message_name
              ) = FALSE THEN
          -- Reset the message to be in context of p_updating the override due dt.
          IF v_message_name = 'IGS_GE_RECORD_ALREADY_EXISTS' THEN
            fnd_message.set_name ('IGS', 'IGS_AD_TE_TELOC_FK');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
          ELSE
            fnd_message.set_name ('IGS', 'IGS_AD_TE_TELOC_FK');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
          END IF;
        END IF;
      END IF;
    END IF;
    -- This code has been added by aiyer for the bug #2323692
    -- If the user inserts a record or updates a record with a mark or grade for the first time then he does not need to insert a
    -- Outcome Comment however every subsequent change to any of these two fields require a outcome comment to be provided thereafter
    IF p_updating THEN
      IF old_references.grade IS NOT NULL
         OR old_references.mark IS NOT NULL THEN
        IF NVL (new_references.grade, 0) <> old_references.grade
           OR NVL (new_references.mark, 0) <> old_references.mark THEN
          IF new_references.outcome_comment_code IS NULL THEN
            fnd_message.set_name ('IGS', 'IGS_AS_OUT_COM_MANDATORY');
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
          END IF;
        END IF;
      END IF;
    END IF;
  END beforerowinsertupdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_suaai_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON igs_as_su_atmpt_itm
  -- FOR EACH ROW
  PROCEDURE assp_ins_suaai_out_hist AS
    -- This is the local procedure which inserts a record into history table.
    l_rowid VARCHAR2 (25);
    a       VARCHAR2 (2000);
  BEGIN
    -- begin
    IF (NVL (new_references.grade, 'NULL') <> NVL (old_references.grade, 'NULL')
        OR NVL (new_references.grading_schema_cd, 'NULL') <> NVL (old_references.grading_schema_cd, 'NULL')
        OR NVL (new_references.gs_version_number, 999) <> NVL (old_references.gs_version_number, 999)
        OR NVL (new_references.mark, 99999) <> NVL (old_references.mark, 99999)
        OR NVL (new_references.outcome_dt, igs_ge_date.igsdate ('1900/01/01')) <>
           NVL (old_references.outcome_dt, igs_ge_date.igsdate ('1900/01/01'))
        OR NVL (new_references.outcome_comment_code, 'NULL') <> NVL (old_references.outcome_comment_code, 'NULL')
       ) THEN
      igs_as_suaai_ouhist_pkg.insert_row (
        x_rowid                        => l_rowid,
        x_person_id                    => old_references.person_id,
        x_course_cd                    => old_references.course_cd,
        x_unit_cd                      => old_references.unit_cd,
        x_cal_type                     => old_references.cal_type,
        x_ci_sequence_number           => old_references.ci_sequence_number,
        x_ass_id                       => old_references.ass_id,
        x_creation_dt                  => old_references.creation_dt,
        x_grading_schema_cd            => old_references.grading_schema_cd,
        x_gs_version_number            => old_references.gs_version_number,
        x_grade                        => old_references.grade,
        x_outcome_dt                   => old_references.outcome_dt,
        x_mark                         => old_references.mark,
        x_outcome_comment_code         => old_references.outcome_comment_code,
        x_hist_start_dt                => old_references.last_update_date,
        x_hist_end_dt                  => new_references.last_update_date,
        x_hist_who                     => old_references.last_updated_by,
        x_mode                         => 'R',
        x_uoo_id                       => old_references.uoo_id,
        x_sua_ass_item_group_id        => old_references.sua_ass_item_group_id,
        x_midterm_mandatory_type_code  => old_references.midterm_mandatory_type_code,
        x_midterm_weight_qty           => old_references.midterm_weight_qty,
        x_final_mandatory_type_code    => old_references.final_mandatory_type_code,
        x_final_weight_qty             => old_references.final_weight_qty,
        x_submitted_date               => old_references.submitted_date,
        x_waived_flag                  => old_references.waived_flag,
        x_penalty_applied_flag         => old_references.penalty_applied_flag
      );
    END IF;
  END assp_ins_suaai_out_hist;
  PROCEDURE afterrowinsertupdate2 (
    p_inserting                    IN     BOOLEAN DEFAULT FALSE,
    p_updating                     IN     BOOLEAN DEFAULT FALSE,
    p_deleting                     IN     BOOLEAN DEFAULT FALSE
  ) AS
    v_message_name VARCHAR2 (30);
  BEGIN
    IF p_inserting
       OR (p_updating
           AND new_references.attempt_number <> old_references.attempt_number
          ) THEN
      IF igs_as_val_suaai.assp_val_suaai_atmpt (
           new_references.person_id,
           new_references.course_cd,
           new_references.unit_cd,
           new_references.cal_type,
           new_references.ci_sequence_number,
           new_references.ass_id,
           new_references.creation_dt,
           new_references.attempt_number,
           v_message_name,
           new_references.uoo_id
         ) = FALSE THEN
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      -- Validate the attempt number is unique within the student's assessment item.
      -- Cannot call assp_val_suaai_atmpt because trigger will be mutating.
      -- Save the rowid of the current row.
      -- In case of updation it should save a history record in outcome History Record.
    END IF;
    IF p_updating THEN
      assp_ins_suaai_out_hist;
    END IF;
  END afterrowinsertupdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_suaai_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON igs_as_su_atmpt_itm
  PROCEDURE check_parent_existance AS
  BEGIN
    IF (((old_references.ass_id = new_references.ass_id))
        OR ((new_references.ass_id IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_as_assessmnt_itm_pkg.get_pk_for_validation (new_references.ass_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.person_id = new_references.sua_ass_item_group_id))
        OR ((new_references.sua_ass_item_group_id IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_as_sua_ai_group_pkg.get_pk_for_validation (
                new_references.sua_ass_item_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    IF (((old_references.tracking_id = new_references.tracking_id))
        OR ((new_references.tracking_id IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_tr_item_pkg.get_pk_for_validation (new_references.tracking_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;

  PROCEDURE check_child_existance AS
    CURSOR cur_igs_as_spl_cons_appl IS
      SELECT ROWID
      FROM   igs_as_spl_cons_appl
      WHERE  course_cd = old_references.course_cd
      AND    person_id = old_references.person_id
      AND    ass_id = old_references.ass_id
      AND    creation_dt = old_references.creation_dt
      AND    uoo_id = old_references.uoo_id;
  BEGIN
    FOR igs_as_spl_cons_appl_rec IN cur_igs_as_spl_cons_appl LOOP
      igs_as_spl_cons_appl_pkg.delete_row (x_rowid => igs_as_spl_cons_appl_rec.ROWID);
    END LOOP;
    igs_as_std_exm_instn_pkg.get_fk_igs_as_su_atmpt_itm (
      old_references.course_cd,
      old_references.person_id,
      old_references.ass_id,
      old_references.creation_dt,
      old_references.uoo_id
    );
  END check_child_existance;

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION get_pk_for_validation (
    x_course_cd                    IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_creation_dt                  IN     DATE,
    x_uoo_id                       IN     NUMBER
  )
    RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_as_su_atmpt_itm
      WHERE      course_cd = x_course_cd
      AND        person_id = x_person_id
      AND        ass_id = x_ass_id
      AND        creation_dt = x_creation_dt
      AND        uoo_id = x_uoo_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
  END get_pk_for_validation;

  PROCEDURE get_fk_igs_as_assessmnt_itm (x_ass_id IN NUMBER) IS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  ass_id = x_ass_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAAI_AI_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_assessmnt_itm;

  --
  -- Obsoleted
  --
  PROCEDURE get_fk_igs_en_su_attempt (x_person_id IN NUMBER, x_course_cd IN VARCHAR2, x_uoo_id IN NUMBER) AS
  BEGIN
      RETURN;
  END get_fk_igs_en_su_attempt;

  PROCEDURE get_fk_igs_as_sua_ai_group (x_sua_ass_item_group_id IN NUMBER) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  sua_ass_item_group_id = x_sua_ass_item_group_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAAI_SUAIG_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_sua_ai_group;

  PROCEDURE get_fk_igs_tr_item (x_tracking_id IN NUMBER) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  tracking_id = x_tracking_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAAI_TRI_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_tr_item;

  -- Added by DDEY as a part of enhancement bug # 2162831
  PROCEDURE get_fk_igs_as_grd_sch_grade (
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_grade                        IN     VARCHAR2
  ) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  grading_schema_cd = x_grading_schema_cd
      AND    gs_version_number = x_gs_version_number
      AND    grade = x_grade;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAAI_GSG_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_grd_sch_grade;

  -- Added by DDEY as a part of enhancement bug # 2162831
  PROCEDURE get_fk_igs_lookups_view (x_outcome_comment_code IN VARCHAR2) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  outcome_comment_code = x_outcome_comment_code;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_SUAAI_LOV_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_lookups_view;

  PROCEDURE get_ufk_igs_as_untas_pattern (x_ass_pattern_id IN NUMBER) AS
  BEGIN
    RETURN;
  END get_ufk_igs_as_untas_pattern;

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_person_id                    IN     NUMBER DEFAULT NULL,
    x_course_cd                    IN     VARCHAR2 DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_ass_id                       IN     NUMBER DEFAULT NULL,
    x_creation_dt                  IN     DATE DEFAULT NULL,
    x_attempt_number               IN     NUMBER DEFAULT NULL,
    x_outcome_dt                   IN     DATE DEFAULT NULL,
    x_override_due_dt              IN     DATE DEFAULT NULL,
    x_tracking_id                  IN     NUMBER DEFAULT NULL,
    x_logical_delete_dt            IN     DATE DEFAULT NULL,
    x_s_default_ind                IN     VARCHAR2 DEFAULT NULL,
    x_ass_pattern_id               IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_gs_version_number            IN     NUMBER DEFAULT NULL,
    x_grade                        IN     VARCHAR2 DEFAULT NULL,
    x_outcome_comment_code         IN     VARCHAR2 DEFAULT NULL,
    x_mark                         IN     NUMBER DEFAULT NULL,
    x_attribute_category           IN     VARCHAR2 DEFAULT NULL,
    x_attribute1                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute2                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute3                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute4                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute5                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute6                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute7                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute8                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute9                   IN     VARCHAR2 DEFAULT NULL,
    x_attribute10                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute11                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute12                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute13                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute14                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute15                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute16                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute17                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute18                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute19                  IN     VARCHAR2 DEFAULT NULL,
    x_attribute20                  IN     VARCHAR2 DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_unit_section_ass_item_id     IN     NUMBER DEFAULT NULL,
    x_unit_ass_item_id             IN     NUMBER DEFAULT NULL,
    x_sua_ass_item_group_id        IN     NUMBER DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL,
    x_submitted_date               IN     DATE DEFAULT NULL,
    x_waived_flag                  IN     VARCHAR2 DEFAULT NULL,
    x_penalty_applied_flag         IN     VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_id,
      x_creation_dt,
      x_attempt_number,
      x_outcome_dt,
      x_override_due_dt,
      x_tracking_id,
      x_logical_delete_dt,
      x_s_default_ind,
      x_ass_pattern_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_outcome_comment_code,
      x_mark,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_uoo_id,
      x_unit_section_ass_item_id,
      x_unit_ass_item_id,
      x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty,
      x_submitted_date,
      x_waived_flag,
      x_penalty_applied_flag
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforerowinsertupdate1 (p_inserting => TRUE);
      IF get_pk_for_validation (
           new_references.course_cd,
           new_references.person_id,
           new_references.ass_id,
           new_references.creation_dt,
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdate1 (p_updating => TRUE);
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      NULL;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation (
           new_references.course_cd,
           new_references.person_id,
           new_references.ass_id,
           new_references.creation_dt,
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;
  END before_dml;

  PROCEDURE after_dml (p_action IN VARCHAR2, x_rowid IN VARCHAR2) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      afterrowinsertupdate2 (p_inserting => TRUE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      afterrowinsertupdate2 (p_updating => TRUE);
    END IF;
  END after_dml;

  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_creation_dt                  IN     DATE,
    x_attempt_number               IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_override_due_dt              IN     DATE,
    x_tracking_id                  IN     NUMBER,
    x_logical_delete_dt            IN     DATE,
    x_s_default_ind                IN     VARCHAR2,
    x_ass_pattern_id               IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_outcome_comment_code         IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_unit_section_ass_item_id     IN     NUMBER,
    x_unit_ass_item_id             IN     NUMBER,
    x_sua_ass_item_group_id        IN     NUMBER,
    x_midterm_mandatory_type_code  IN     VARCHAR2,
    x_midterm_weight_qty           IN     NUMBER,
    x_final_mandatory_type_code    IN     VARCHAR2,
    x_final_weight_qty             IN     NUMBER,
    x_submitted_date               IN     DATE,
    x_waived_flag                  IN     VARCHAR2,
    x_penalty_applied_flag         IN     VARCHAR2
  ) AS
    CURSOR c IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    ass_id = x_ass_id
      AND    creation_dt = l_altered_creation_dt
      AND    uoo_id = x_uoo_id;
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    IF (((SYSDATE - l_altered_creation_dt) * (24 * 60 * 60)) > 1) THEN
      l_altered_creation_dt := SYSDATE;
    ELSE
      l_altered_creation_dt := NVL (l_altered_creation_dt, SYSDATE) + 1 / (24 * 60 * 60);
    END IF;
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := NULL;
        x_program_id := NULL;
        x_program_application_id := NULL;
        x_program_update_date := NULL;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_ass_id                       => x_ass_id,
      x_ass_pattern_id               => x_ass_pattern_id,
      x_attempt_number               => NVL (x_attempt_number, 1),
      x_cal_type                     => x_cal_type,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_course_cd                    => x_course_cd,
      x_creation_dt                  => l_altered_creation_dt,
      x_logical_delete_dt            => x_logical_delete_dt,
      x_outcome_dt                   => x_outcome_dt,
      x_override_due_dt              => x_override_due_dt,
      x_person_id                    => x_person_id,
      x_s_default_ind                => NVL (x_s_default_ind, 'N'),
      x_tracking_id                  => x_tracking_id,
      x_unit_cd                      => x_unit_cd,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_gs_version_number            => x_gs_version_number,
      x_grade                        => x_grade,
      x_outcome_comment_code         => x_outcome_comment_code,
      x_mark                         => x_mark,
      x_attribute_category           => x_attribute_category,
      x_attribute1                   => x_attribute1,
      x_attribute2                   => x_attribute2,
      x_attribute3                   => x_attribute3,
      x_attribute4                   => x_attribute4,
      x_attribute5                   => x_attribute5,
      x_attribute6                   => x_attribute6,
      x_attribute7                   => x_attribute7,
      x_attribute8                   => x_attribute8,
      x_attribute9                   => x_attribute9,
      x_attribute10                  => x_attribute10,
      x_attribute11                  => x_attribute11,
      x_attribute12                  => x_attribute12,
      x_attribute13                  => x_attribute13,
      x_attribute14                  => x_attribute14,
      x_attribute15                  => x_attribute15,
      x_attribute16                  => x_attribute16,
      x_attribute17                  => x_attribute17,
      x_attribute18                  => x_attribute18,
      x_attribute19                  => x_attribute19,
      x_attribute20                  => x_attribute20,
      x_uoo_id                       => x_uoo_id,
      x_unit_section_ass_item_id     => x_unit_section_ass_item_id,
      x_unit_ass_item_id             => x_unit_ass_item_id,
      x_sua_ass_item_group_id        => x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code  => x_midterm_mandatory_type_code,
      x_midterm_weight_qty           => x_midterm_weight_qty,
      x_final_mandatory_type_code    => x_final_mandatory_type_code,
      x_final_weight_qty             => x_final_weight_qty,
      x_submitted_date               => x_submitted_date,
      x_waived_flag                  => x_waived_flag,
      x_penalty_applied_flag         => x_penalty_applied_flag
    );

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO igs_as_su_atmpt_itm
                (person_id, course_cd, unit_cd, cal_type,
                 ci_sequence_number, ass_id, creation_dt,
                 attempt_number, outcome_dt, override_due_dt,
                 tracking_id, logical_delete_dt, s_default_ind,
                 ass_pattern_id, creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, request_id, program_id, program_application_id,
                 program_update_date, grading_schema_cd, gs_version_number,
                 grade, outcome_comment_code, mark,
                 attribute_category, attribute1, attribute2,
                 attribute3, attribute4, attribute5,
                 attribute6, attribute7, attribute8,
                 attribute9, attribute10, attribute11,
                 attribute12, attribute13, attribute14,
                 attribute15, attribute16, attribute17,
                 attribute18, attribute19, attribute20,
                 uoo_id, unit_section_ass_item_id, unit_ass_item_id,
                 sua_ass_item_group_id, midterm_mandatory_type_code,
                 midterm_weight_qty, final_mandatory_type_code,
                 final_weight_qty, submitted_date, waived_flag,
                 penalty_applied_flag)
         VALUES (new_references.person_id, new_references.course_cd, new_references.unit_cd, new_references.cal_type,
                 new_references.ci_sequence_number, new_references.ass_id, new_references.creation_dt,
                 new_references.attempt_number, new_references.outcome_dt, new_references.override_due_dt,
                 new_references.tracking_id, new_references.logical_delete_dt, new_references.s_default_ind,
                 new_references.ass_pattern_id, x_last_update_date, x_last_updated_by, x_last_update_date,
                 x_last_updated_by, x_last_update_login, x_request_id, x_program_id, x_program_application_id,
                 x_program_update_date, new_references.grading_schema_cd, new_references.gs_version_number,
                 new_references.grade, new_references.outcome_comment_code, new_references.mark,
                 new_references.attribute_category, new_references.attribute1, new_references.attribute2,
                 new_references.attribute3, new_references.attribute4, new_references.attribute5,
                 new_references.attribute6, new_references.attribute7, new_references.attribute8,
                 new_references.attribute9, new_references.attribute10, new_references.attribute11,
                 new_references.attribute12, new_references.attribute13, new_references.attribute14,
                 new_references.attribute15, new_references.attribute16, new_references.attribute17,
                 new_references.attribute18, new_references.attribute19, new_references.attribute20,
                 new_references.uoo_id, new_references.unit_section_ass_item_id, new_references.unit_ass_item_id,
                 new_references.sua_ass_item_group_id, new_references.midterm_mandatory_type_code,
                 new_references.midterm_weight_qty, new_references.final_mandatory_type_code,
                 new_references.final_weight_qty, new_references.submitted_date, new_references.waived_flag,
                 new_references.penalty_applied_flag);
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml (p_action => 'INSERT', x_rowid => x_rowid);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_creation_dt                  IN     DATE,
    x_attempt_number               IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_override_due_dt              IN     DATE,
    x_tracking_id                  IN     NUMBER,
    x_logical_delete_dt            IN     DATE,
    x_s_default_ind                IN     VARCHAR2,
    x_ass_pattern_id               IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_outcome_comment_code         IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_unit_section_ass_item_id     IN     NUMBER,
    x_unit_ass_item_id             IN     NUMBER,
    x_sua_ass_item_group_id        IN     NUMBER,
    x_midterm_mandatory_type_code  IN     VARCHAR2,
    x_midterm_weight_qty           IN     NUMBER,
    x_final_mandatory_type_code    IN     VARCHAR2,
    x_final_weight_qty             IN     NUMBER,
    x_submitted_date               IN     DATE,
    x_waived_flag                  IN     VARCHAR2,
    x_penalty_applied_flag         IN     VARCHAR2
  ) AS
    CURSOR c1 IS
      SELECT     attempt_number,
                 outcome_dt,
                 override_due_dt,
                 tracking_id,
                 logical_delete_dt,
                 s_default_ind,
                 ass_pattern_id,
                 grading_schema_cd,
                 gs_version_number,
                 grade,
                 outcome_comment_code,
                 mark,
                 attribute_category,
                 attribute1,
                 attribute2,
                 attribute3,
                 attribute4,
                 attribute5,
                 attribute6,
                 attribute7,
                 attribute8,
                 attribute9,
                 attribute10,
                 attribute11,
                 attribute12,
                 attribute13,
                 attribute14,
                 attribute15,
                 attribute16,
                 attribute17,
                 attribute18,
                 attribute19,
                 attribute20,
                 uoo_id,
                 unit_section_ass_item_id,
                 unit_ass_item_id,
                 sua_ass_item_group_id,
                 midterm_mandatory_type_code,
                 midterm_weight_qty,
                 final_mandatory_type_code,
                 final_weight_qty,
                 submitted_date,
                 waived_flag,
                 penalty_applied_flag
      FROM       igs_as_su_atmpt_itm
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      CLOSE c1;
      RETURN;
    END IF;
    CLOSE c1;
    IF ((tlinfo.attempt_number = x_attempt_number)
        AND ((TRUNC (tlinfo.outcome_dt) = TRUNC (x_outcome_dt))
             OR ((tlinfo.outcome_dt IS NULL)
                 AND (x_outcome_dt IS NULL)
                )
            )
        AND ((TRUNC (tlinfo.override_due_dt) = TRUNC (x_override_due_dt))
             OR ((tlinfo.override_due_dt IS NULL)
                 AND (x_override_due_dt IS NULL)
                )
            )
        AND ((tlinfo.tracking_id = x_tracking_id)
             OR ((tlinfo.tracking_id IS NULL)
                 AND (x_tracking_id IS NULL)
                )
            )
        AND ((TRUNC (tlinfo.logical_delete_dt) = TRUNC (x_logical_delete_dt))
             OR ((tlinfo.logical_delete_dt IS NULL)
                 AND (x_logical_delete_dt IS NULL)
                )
            )
        AND (tlinfo.s_default_ind = x_s_default_ind)
        AND ((tlinfo.ass_pattern_id = x_ass_pattern_id)
             OR ((tlinfo.ass_pattern_id IS NULL)
                 AND (x_ass_pattern_id IS NULL)
                )
            )
        AND ((tlinfo.grading_schema_cd = x_grading_schema_cd)
             OR ((tlinfo.grading_schema_cd IS NULL)
                 AND (x_grading_schema_cd IS NULL)
                )
            )
        AND ((tlinfo.gs_version_number = x_gs_version_number)
             OR ((tlinfo.gs_version_number IS NULL)
                 AND (x_gs_version_number IS NULL)
                )
            )
        AND ((tlinfo.grade = x_grade)
             OR ((tlinfo.grade IS NULL)
                 AND (x_grade IS NULL)
                )
            )
        AND ((tlinfo.outcome_comment_code = x_outcome_comment_code)
             OR ((tlinfo.outcome_comment_code IS NULL)
                 AND (x_outcome_comment_code IS NULL)
                )
            )
        AND ((tlinfo.mark = x_mark)
             OR ((tlinfo.mark IS NULL)
                 AND (x_mark IS NULL)
                )
            )
        AND ((tlinfo.attribute_category = x_attribute_category)
             OR ((tlinfo.attribute_category IS NULL)
                 AND (x_attribute_category IS NULL)
                )
            )
        AND ((tlinfo.attribute1 = x_attribute1)
             OR ((tlinfo.attribute1 IS NULL)
                 AND (x_attribute1 IS NULL)
                )
            )
        AND ((tlinfo.attribute2 = x_attribute2)
             OR ((tlinfo.attribute2 IS NULL)
                 AND (x_attribute2 IS NULL)
                )
            )
        AND ((tlinfo.attribute3 = x_attribute3)
             OR ((tlinfo.attribute3 IS NULL)
                 AND (x_attribute3 IS NULL)
                )
            )
        AND ((tlinfo.attribute4 = x_attribute4)
             OR ((tlinfo.attribute4 IS NULL)
                 AND (x_attribute4 IS NULL)
                )
            )
        AND ((tlinfo.attribute5 = x_attribute5)
             OR ((tlinfo.attribute5 IS NULL)
                 AND (x_attribute5 IS NULL)
                )
            )
        AND ((tlinfo.attribute6 = x_attribute6)
             OR ((tlinfo.attribute6 IS NULL)
                 AND (x_attribute6 IS NULL)
                )
            )
        AND ((tlinfo.attribute7 = x_attribute7)
             OR ((tlinfo.attribute7 IS NULL)
                 AND (x_attribute7 IS NULL)
                )
            )
        AND ((tlinfo.attribute8 = x_attribute8)
             OR ((tlinfo.attribute8 IS NULL)
                 AND (x_attribute8 IS NULL)
                )
            )
        AND ((tlinfo.attribute9 = x_attribute9)
             OR ((tlinfo.attribute9 IS NULL)
                 AND (x_attribute9 IS NULL)
                )
            )
        AND ((tlinfo.attribute10 = x_attribute10)
             OR ((tlinfo.attribute10 IS NULL)
                 AND (x_attribute10 IS NULL)
                )
            )
        AND ((tlinfo.attribute11 = x_attribute11)
             OR ((tlinfo.attribute11 IS NULL)
                 AND (x_attribute11 IS NULL)
                )
            )
        AND ((tlinfo.attribute12 = x_attribute12)
             OR ((tlinfo.attribute12 IS NULL)
                 AND (x_attribute12 IS NULL)
                )
            )
        AND ((tlinfo.attribute13 = x_attribute13)
             OR ((tlinfo.attribute13 IS NULL)
                 AND (x_attribute13 IS NULL)
                )
            )
        AND ((tlinfo.attribute14 = x_attribute14)
             OR ((tlinfo.attribute14 IS NULL)
                 AND (x_attribute14 IS NULL)
                )
            )
        AND ((tlinfo.attribute15 = x_attribute15)
             OR ((tlinfo.attribute15 IS NULL)
                 AND (x_attribute15 IS NULL)
                )
            )
        AND ((tlinfo.attribute16 = x_attribute16)
             OR ((tlinfo.attribute16 IS NULL)
                 AND (x_attribute16 IS NULL)
                )
            )
        AND ((tlinfo.attribute17 = x_attribute17)
             OR ((tlinfo.attribute17 IS NULL)
                 AND (x_attribute17 IS NULL)
                )
            )
        AND ((tlinfo.attribute18 = x_attribute18)
             OR ((tlinfo.attribute18 IS NULL)
                 AND (x_attribute18 IS NULL)
                )
            )
        AND ((tlinfo.attribute19 = x_attribute19)
             OR ((tlinfo.attribute19 IS NULL)
                 AND (x_attribute19 IS NULL)
                )
            )
        AND ((tlinfo.attribute20 = x_attribute20)
             OR ((tlinfo.attribute20 IS NULL)
                 AND (x_attribute20 IS NULL)
                )
            )
        AND ((tlinfo.attribute19 = x_attribute19)
             OR ((tlinfo.attribute19 IS NULL)
                 AND (x_attribute19 IS NULL)
                )
            )
        AND ((tlinfo.unit_section_ass_item_id = x_unit_section_ass_item_id)
             OR ((tlinfo.unit_section_ass_item_id IS NULL)
                 AND (x_unit_section_ass_item_id IS NULL)
                )
            )
        AND ((tlinfo.unit_ass_item_id = x_unit_ass_item_id)
             OR ((tlinfo.unit_ass_item_id IS NULL)
                 AND (x_unit_ass_item_id IS NULL)
                )
            )
        AND ((tlinfo.sua_ass_item_group_id = x_sua_ass_item_group_id)
             OR ((tlinfo.sua_ass_item_group_id IS NULL)
                 AND (x_sua_ass_item_group_id IS NULL)
                )
            )
        AND ((tlinfo.midterm_mandatory_type_code = x_midterm_mandatory_type_code)
             OR ((tlinfo.midterm_mandatory_type_code IS NULL)
                 AND (x_midterm_mandatory_type_code IS NULL)
                )
            )
        AND ((tlinfo.midterm_weight_qty = x_midterm_weight_qty)
             OR ((tlinfo.midterm_weight_qty IS NULL)
                 AND (x_midterm_weight_qty IS NULL)
                )
            )
        AND ((tlinfo.final_mandatory_type_code = x_final_mandatory_type_code)
             OR ((tlinfo.final_mandatory_type_code IS NULL)
                 AND (x_final_mandatory_type_code IS NULL)
                )
            )
        AND ((tlinfo.final_weight_qty = x_final_weight_qty)
             OR ((tlinfo.final_weight_qty IS NULL)
                 AND (x_final_weight_qty IS NULL)
                )
            )
        AND ((tlinfo.submitted_date = x_submitted_date)
             OR ((tlinfo.submitted_date IS NULL)
                 AND (x_submitted_date IS NULL)
                )
            )
        AND ((tlinfo.waived_flag = x_waived_flag)
             OR ((tlinfo.waived_flag IS NULL)
                 AND (x_waived_flag IS NULL)
                )
            )
        AND ((tlinfo.penalty_applied_flag = x_penalty_applied_flag)
             OR ((tlinfo.penalty_applied_flag IS NULL)
                 AND (x_penalty_applied_flag IS NULL)
                )
            )
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_creation_dt                  IN     DATE,
    x_attempt_number               IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_override_due_dt              IN     DATE,
    x_tracking_id                  IN     NUMBER,
    x_logical_delete_dt            IN     DATE,
    x_s_default_ind                IN     VARCHAR2,
    x_ass_pattern_id               IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_outcome_comment_code         IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_unit_section_ass_item_id     IN     NUMBER,
    x_unit_ass_item_id             IN     NUMBER,
    x_sua_ass_item_group_id        IN     NUMBER,
    x_midterm_mandatory_type_code  IN     VARCHAR2,
    x_midterm_weight_qty           IN     NUMBER,
    x_final_mandatory_type_code    IN     VARCHAR2,
    x_final_weight_qty             IN     NUMBER,
    x_submitted_date               IN     DATE,
    x_waived_flag                  IN     VARCHAR2,
    x_penalty_applied_flag         IN     VARCHAR2
  ) AS
    x_last_update_date       DATE;
    x_last_updated_by        NUMBER;
    x_last_update_login      NUMBER;
    x_request_id             NUMBER;
    x_program_id             NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date    DATE;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml (
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_ass_id                       => x_ass_id,
      x_ass_pattern_id               => x_ass_pattern_id,
      x_attempt_number               => x_attempt_number,
      x_cal_type                     => x_cal_type,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_course_cd                    => x_course_cd,
      x_creation_dt                  => x_creation_dt,
      x_logical_delete_dt            => x_logical_delete_dt,
      x_outcome_dt                   => x_outcome_dt,
      x_override_due_dt              => x_override_due_dt,
      x_person_id                    => x_person_id,
      x_s_default_ind                => x_s_default_ind,
      x_tracking_id                  => x_tracking_id,
      x_unit_cd                      => x_unit_cd,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_gs_version_number            => x_gs_version_number,
      x_grade                        => x_grade,
      x_outcome_comment_code         => x_outcome_comment_code,
      x_mark                         => x_mark,
      x_attribute_category           => x_attribute_category,
      x_attribute1                   => x_attribute1,
      x_attribute2                   => x_attribute2,
      x_attribute3                   => x_attribute3,
      x_attribute4                   => x_attribute4,
      x_attribute5                   => x_attribute5,
      x_attribute6                   => x_attribute6,
      x_attribute7                   => x_attribute7,
      x_attribute8                   => x_attribute8,
      x_attribute9                   => x_attribute9,
      x_attribute10                  => x_attribute10,
      x_attribute11                  => x_attribute11,
      x_attribute12                  => x_attribute12,
      x_attribute13                  => x_attribute13,
      x_attribute14                  => x_attribute14,
      x_attribute15                  => x_attribute15,
      x_attribute16                  => x_attribute16,
      x_attribute17                  => x_attribute17,
      x_attribute18                  => x_attribute18,
      x_attribute19                  => x_attribute19,
      x_attribute20                  => x_attribute20,
      x_uoo_id                       => x_uoo_id,
      x_unit_section_ass_item_id     => x_unit_section_ass_item_id,
      x_unit_ass_item_id             => x_unit_ass_item_id,
      x_sua_ass_item_group_id        => x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code  => x_midterm_mandatory_type_code,
      x_midterm_weight_qty           => x_midterm_weight_qty,
      x_final_mandatory_type_code    => x_final_mandatory_type_code,
      x_final_weight_qty             => x_final_weight_qty,
      x_submitted_date               => x_submitted_date,
      x_waived_flag                  => x_waived_flag,
      x_penalty_applied_flag         => x_penalty_applied_flag
    );
    IF (X_MODE IN ('R', 'S')) THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id = -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE igs_as_su_atmpt_itm
       SET attempt_number = new_references.attempt_number,
           outcome_dt = new_references.outcome_dt,
           override_due_dt = new_references.override_due_dt,
           tracking_id = new_references.tracking_id,
           logical_delete_dt = new_references.logical_delete_dt,
           s_default_ind = new_references.s_default_ind,
           ass_pattern_id = new_references.ass_pattern_id,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           request_id = x_request_id,
           program_id = x_program_id,
           program_application_id = x_program_application_id,
           program_update_date = x_program_update_date,
           grading_schema_cd = new_references.grading_schema_cd,
           gs_version_number = new_references.gs_version_number,
           grade = new_references.grade,
           outcome_comment_code = new_references.outcome_comment_code,
           mark = new_references.mark,
           attribute_category = new_references.attribute_category,
           attribute1 = new_references.attribute1,
           attribute2 = new_references.attribute2,
           attribute3 = new_references.attribute3,
           attribute4 = new_references.attribute4,
           attribute5 = new_references.attribute5,
           attribute6 = new_references.attribute6,
           attribute7 = new_references.attribute7,
           attribute8 = new_references.attribute8,
           attribute9 = new_references.attribute9,
           attribute10 = new_references.attribute10,
           attribute11 = new_references.attribute11,
           attribute12 = new_references.attribute12,
           attribute13 = new_references.attribute13,
           attribute14 = new_references.attribute14,
           attribute15 = new_references.attribute15,
           attribute16 = new_references.attribute16,
           attribute17 = new_references.attribute17,
           attribute18 = new_references.attribute18,
           attribute19 = new_references.attribute19,
           attribute20 = new_references.attribute20,
           unit_section_ass_item_id = new_references.unit_section_ass_item_id,
           unit_ass_item_id = new_references.unit_ass_item_id,
           sua_ass_item_group_id = new_references.sua_ass_item_group_id,
           midterm_mandatory_type_code = new_references.midterm_mandatory_type_code,
           midterm_weight_qty = new_references.midterm_weight_qty,
           final_mandatory_type_code = new_references.final_mandatory_type_code,
           final_weight_qty = new_references.final_weight_qty,
           submitted_date = new_references.submitted_date,
           waived_flag = new_references.waived_flag,
           penalty_applied_flag = new_references.penalty_applied_flag
     WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    after_dml (p_action => 'UPDATE', x_rowid => x_rowid);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_creation_dt                  IN     DATE,
    x_attempt_number               IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_override_due_dt              IN     DATE,
    x_tracking_id                  IN     NUMBER,
    x_logical_delete_dt            IN     DATE,
    x_s_default_ind                IN     VARCHAR2,
    x_ass_pattern_id               IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_outcome_comment_code         IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_attribute_category           IN     VARCHAR2,
    x_attribute1                   IN     VARCHAR2,
    x_attribute2                   IN     VARCHAR2,
    x_attribute3                   IN     VARCHAR2,
    x_attribute4                   IN     VARCHAR2,
    x_attribute5                   IN     VARCHAR2,
    x_attribute6                   IN     VARCHAR2,
    x_attribute7                   IN     VARCHAR2,
    x_attribute8                   IN     VARCHAR2,
    x_attribute9                   IN     VARCHAR2,
    x_attribute10                  IN     VARCHAR2,
    x_attribute11                  IN     VARCHAR2,
    x_attribute12                  IN     VARCHAR2,
    x_attribute13                  IN     VARCHAR2,
    x_attribute14                  IN     VARCHAR2,
    x_attribute15                  IN     VARCHAR2,
    x_attribute16                  IN     VARCHAR2,
    x_attribute17                  IN     VARCHAR2,
    x_attribute18                  IN     VARCHAR2,
    x_attribute19                  IN     VARCHAR2,
    x_attribute20                  IN     VARCHAR2,
    x_uoo_id                       IN     NUMBER,
    x_unit_section_ass_item_id     IN     NUMBER,
    x_unit_ass_item_id             IN     NUMBER,
    x_sua_ass_item_group_id        IN     NUMBER,
    x_midterm_mandatory_type_code  IN     VARCHAR2,
    x_midterm_weight_qty           IN     NUMBER,
    x_final_mandatory_type_code    IN     VARCHAR2,
    x_final_weight_qty             IN     NUMBER,
    x_submitted_date               IN     DATE,
    x_waived_flag                  IN     VARCHAR2,
    x_penalty_applied_flag         IN     VARCHAR2
  ) AS
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_as_su_atmpt_itm
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    ass_id = x_ass_id
      AND    creation_dt = x_creation_dt
      AND    uoo_id = x_uoo_id;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_unit_cd,
        x_cal_type,
        x_ci_sequence_number,
        x_ass_id,
        x_creation_dt,
        x_attempt_number,
        x_outcome_dt,
        x_override_due_dt,
        x_tracking_id,
        x_logical_delete_dt,
        x_s_default_ind,
        x_ass_pattern_id,
        x_mode,
        x_grading_schema_cd,
        x_gs_version_number,
        x_grade,
        x_outcome_comment_code,
        x_mark,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_uoo_id,
        x_unit_section_ass_item_id,
        x_unit_ass_item_id,
        x_sua_ass_item_group_id,
        x_midterm_mandatory_type_code,
        x_midterm_weight_qty,
        x_final_mandatory_type_code,
        x_final_weight_qty,
        x_submitted_date,
        x_waived_flag,
        x_penalty_applied_flag
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_id,
      x_creation_dt,
      x_attempt_number,
      x_outcome_dt,
      x_override_due_dt,
      x_tracking_id,
      x_logical_delete_dt,
      x_s_default_ind,
      x_ass_pattern_id,
      x_mode,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_outcome_comment_code,
      x_mark,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_uoo_id,
      x_unit_section_ass_item_id,
      x_unit_ass_item_id,
      x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty,
      x_submitted_date,
      x_waived_flag,
      x_penalty_applied_flag
    );
  END add_row;

  PROCEDURE delete_row (x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2) AS
  BEGIN
    before_dml (p_action => 'DELETE', x_rowid => x_rowid);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  DELETE FROM igs_as_su_atmpt_itm
          WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

    after_dml (p_action => 'DELETE', x_rowid => x_rowid);
  END delete_row;

  PROCEDURE check_constraints (column_name IN VARCHAR2 DEFAULT NULL, column_value IN VARCHAR2 DEFAULT NULL) AS
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER (column_name) = 'CAL_TYPE' THEN
      new_references.cal_type := column_value;
    ELSIF UPPER (column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
    ELSIF UPPER (column_name) = 'UNIT_CD' THEN
      new_references.unit_cd := column_value;
    ELSIF UPPER (column_name) = 'S_DEFAULT_IND' THEN
      new_references.s_default_ind := column_value;
    END IF;
    IF UPPER (column_name) = 'CAL_TYPE'
       OR column_name IS NULL THEN
      IF new_references.cal_type <> UPPER (new_references.cal_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'COURSE_CD'
       OR column_name IS NULL THEN
      IF new_references.course_cd <> UPPER (new_references.course_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'UNIT_CD'
       OR column_name IS NULL THEN
      IF new_references.unit_cd <> UPPER (new_references.unit_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER (column_name) = 'S_DEFAULT_IND'
       OR column_name IS NULL THEN
      IF new_references.s_default_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_constraints;
END igs_as_su_atmpt_itm_pkg;

/
