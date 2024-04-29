--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNITASS_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNITASS_ITEM_PKG" AS
/* $Header: IGSPI0KB.pls 120.1 2006/09/20 07:27:13 sepalani noship $ */
  -- Bug# 1956374 , procedure assp_val_ai_exists,assp_val_uai_uapi,assp_val_uai_uniqref reference is changed
  l_rowid               VARCHAR2 (25);
  old_references        igs_ps_unitass_item%ROWTYPE;
  new_references        igs_ps_unitass_item%ROWTYPE;
  lv_cal_type           VARCHAR2 (10);
  lv_unit_cd            VARCHAR2 (10);
  lv_version_number     NUMBER;
  lv_ci_sequence_number NUMBER;
  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_unit_section_ass_item_id     IN     NUMBER DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_ass_id                       IN     NUMBER DEFAULT NULL,
    x_sequence_number              IN     NUMBER DEFAULT NULL,
    x_ci_start_dt                  IN     DATE DEFAULT NULL,
    x_ci_end_dt                    IN     DATE DEFAULT NULL,
    x_due_dt                       IN     DATE DEFAULT NULL,
    x_reference                    IN     VARCHAR2 DEFAULT NULL,
    x_dflt_item_ind                IN     VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt            IN     DATE DEFAULT NULL,
    x_action_dt                    IN     DATE DEFAULT NULL,
    x_exam_cal_type                IN     VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number      IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_gs_version_number            IN     NUMBER DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_ps_unitass_item
      WHERE  ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF  (cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.unit_section_ass_item_id := x_unit_section_ass_item_id;
    new_references.uoo_id := x_uoo_id;
    new_references.ass_id := x_ass_id;
    new_references.sequence_number := x_sequence_number;
    new_references.ci_start_dt := x_ci_start_dt;
    new_references.ci_end_dt := x_ci_end_dt;
    new_references.due_dt := x_due_dt;
    new_references.REFERENCE := x_reference;
    new_references.dflt_item_ind := x_dflt_item_ind;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.action_dt := x_action_dt;
    new_references.exam_cal_type := x_exam_cal_type;
    new_references.exam_ci_sequence_number := x_exam_ci_sequence_number;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
    new_references.release_date := x_release_date;
    new_references.description := x_description;
    new_references.us_ass_item_group_id := x_us_ass_item_group_id;
    new_references.midterm_mandatory_type_code := x_midterm_mandatory_type_code;
    new_references.midterm_weight_qty := x_midterm_weight_qty;
    new_references.final_mandatory_type_code := x_final_mandatory_type_code;
    new_references.final_weight_qty := x_final_weight_qty;
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
  ) AS
    v_message_name VARCHAR2 (30);
  BEGIN
    -- Validate that inserts/updates are allowed
    IF p_inserting
       OR p_updating THEN
      --<Start uai1>
      -- Validate assessment item exists
      -- w.r.t Bug  # 1956374 procedure assp_val_ai_exists reference is changed
      IF igs_as_val_uai.assp_val_ai_exists (new_references.ass_id, v_message_name) = FALSE THEN
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      --<<End uai1>>
      --<Start uai2>
      -- Validate IGS_AD_LOCATION closed indicator
      -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UAI.crsp_val_loc_cd
      IF igs_ps_val_uoo.crsp_val_loc_cd (new_references.location_cd, v_message_name) = FALSE THEN
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      --<<End uai2>>
      --<Start uai3>
      -- Validate IGS_PS_UNIT mode closed indicator
      -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UAI.crsp_val_um_closed
      --<<End uai4>>
      --<Start uai10>
      -- If the IGS_PS_UNIT version status is inactive then prevent inserts, updates and
      -- deletes. As deletes are logical, they are equiv to updates and delete
      -- trigger is not required.
      IF igs_ps_val_unit.crsp_val_iud_uv_dtl (lv_unit_cd, lv_version_number, v_message_name) = FALSE THEN
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      --<<End uai10>>
      --<Start uai11>
      -- If calendar instance is inactive, then prevent inserts, updates and
      -- deletes. As deletes are logical, they are equiv to updates and delete
      -- trigger is not required.
      IF igs_ps_val_uai.crsp_val_crs_ci (lv_cal_type, lv_ci_sequence_number, v_message_name) = FALSE THEN
        fnd_message.set_name ('IGS', v_message_name);
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      --<<End uai11>>
      --<Start uai15>
      -- If item is examinable then validate that reference is set.
      -- w.r.t Bug  # 1956374 procedure assp_val_ai_exmnbl reference is changed
      IF  NVL (new_references.REFERENCE, 'NULL666') = 'NULL666'
          AND (igs_as_val_aiem.assp_val_ai_exmnbl (new_references.ass_id, v_message_name)
               OR igs_as_gen_002.assp_get_ai_s_type (new_references.ass_id) = 'ASSIGNMENT'
              ) THEN
        fnd_message.set_name ('IGS', 'IGS_AS_REF_ASSITEM_EXAM');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      --<<End uai15>>
      --<Start uai16>
      -- Validate the examination calendar type/sequence number if they have
      -- been specified.
      IF new_references.exam_cal_type IS NOT NULL THEN
        IF igs_as_val_uai.assp_val_uai_cal (
             new_references.exam_cal_type,
             new_references.exam_ci_sequence_number,
             lv_cal_type,
             lv_ci_sequence_number,
             v_message_name
           ) = FALSE THEN
          fnd_message.set_name ('IGS', v_message_name);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
        END IF;
      END IF;
      --<<End uai16>>
      IF p_inserting THEN
          --<Start uai12>
        -- If calendar type is closed, then prevent inserts.
        -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UAI.crsp_val_uo_cal_type
        IF igs_as_val_uai.crsp_val_uo_cal_type (lv_cal_type, v_message_name) = FALSE THEN
          fnd_message.set_name ('IGS', v_message_name);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
        END IF;
      --<<End uai12>>
      END IF;
      -- Commented out NOCOPY  by DDEY as a part of Bug # 2162831
/*      IF p_updating AND
         ((NVL(new_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
    NVL(old_references.logical_delete_dt, IGS_GE_DATE.IGSDATE('1900/01/01')))
          (NVL(new_references.location_cd, 'NULL') <> NVL(old_references.location_cd, 'NULL')) OR
          (NVL(new_references.unit_class, 'NULL') <> NVL(old_references.unit_class, 'NULL')) OR
          (NVL(new_references.unit_mode,'NULL') <> NVL(old_references.unit_mode, 'NULL')))
     THEN
    -- Only perform this validation if not in the process of performing a
    -- cascading update from altering the IGS_AS_UNTAS_PATTERN
    -- fields of IGS_AD_LOCATION, class and mode. (Refer to IGS_AS_GEN_005.ASSP_UPD_UAP_UOO)
    IF igs_as_val_suaap.genp_val_sdtt_sess('UNIT_ASSESSMENT_PATTERN_UPD') THEN
      IF IGS_AS_VAL_UAI.assp_val_uai_uapi(lv_unit_cd,
          lv_version_number,
          lv_cal_type,
          lv_ci_sequence_number,
          new_references.ass_id,
          new_references.sequence_number,
          old_references.location_cd,
          old_references.unit_class,
          old_references.unit_mode,
          old_references.logical_delete_dt,
          new_references.location_cd,
          new_references.unit_class,
          new_references.unit_mode,
          new_references.logical_delete_dt,
          v_message_name) = FALSE THEN
                     Fnd_Message.Set_Name('IGS', v_message_name);
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
      END IF;
    END IF;
      END IF;   */
    END IF;
  END beforerowinsertupdate1;
  -- Trigger description :-
  -- "OSS_TST".trg_uai_br_iu_upd
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AS_UNITASS_ITEM
  -- FOR EACH ROW
  PROCEDURE beforerowinsertupdate2 (
    p_inserting                    IN     BOOLEAN DEFAULT FALSE,
    p_updating                     IN     BOOLEAN DEFAULT FALSE,
    p_deleting                     IN     BOOLEAN DEFAULT FALSE
  ) AS
    CURSOR c_ci (cp_cal_type igs_ca_inst.cal_type%TYPE, cp_seq_number igs_ca_inst.sequence_number%TYPE) IS
      SELECT start_dt,
             end_dt
      FROM   igs_ca_inst
      WHERE  cal_type = cp_cal_type
      AND    sequence_number = cp_seq_number;
  BEGIN
    IF p_inserting THEN
      -- Temporary code to set the start/end date - to be replaced
      -- with a database routine rather than an embedded cursor
      -- Start and end date are carried down from UOP for sorting
      -- purposes.
      FOR v_ci_rec IN c_ci (lv_cal_type, lv_ci_sequence_number) LOOP
        new_references.ci_start_dt := v_ci_rec.start_dt;
        new_references.ci_end_dt := v_ci_rec.end_dt;
      END LOOP;
    END IF;
    IF p_inserting
       OR p_updating THEN
      -- Always update the action date when p_inserting/p_updating/p_deleting
      -- a UAI. This enable mechanism for knowing when an item needs to
      -- be added to a student.
      -- Updates only pertain to changes for locn, um and ucl.
      -- Please IGS_GE_NOTE that p_deleting a UAI is only a logical delete and
      -- therefore really an update.
      IF ( /* NVL(new_references.location_cd, 'x')   <> NVL(old_references.location_cd, 'x') OR
     NVL(new_references.unit_mode,'x') <> NVL(old_references.unit_mode,'x') OR
     NVL(new_references.unit_class,'x')  <> NVL(old_references.unit_class,'x') OR  */  -- Commented out NOCOPY  by DDEY as a part of Bug # 2162831
          NVL (new_references.dflt_item_ind, 'x') <> NVL (old_references.dflt_item_ind, 'x')
          OR NVL (new_references.logical_delete_dt, igs_ge_date.igsdate ('1900/01/01')) <>
             NVL (old_references.logical_delete_dt, igs_ge_date.igsdate ('1900/01/01'))
         ) THEN
        IF NVL (old_references.action_dt, igs_ge_date.igsdate ('1900/01/01')) = igs_ge_date.igsdate ('1900/01/01') THEN
          new_references.action_dt := TRUNC (SYSDATE);
        END IF;
      END IF;
    END IF;
  END beforerowinsertupdate2;
  -- Trigger description :-
  -- "OSS_TST".trg_uai_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_AS_UNITASS_ITEM
  -- FOR EACH ROW
  PROCEDURE afterrowinsertupdate3 (
    p_inserting                    IN     BOOLEAN DEFAULT FALSE,
    p_updating                     IN     BOOLEAN DEFAULT FALSE,
    p_deleting                     IN     BOOLEAN DEFAULT FALSE
  ) AS
    v_message_name VARCHAR2 (30);
  BEGIN
    IF p_inserting
       OR p_updating THEN
      -- w.r.t Bug  # 1956374 procedure assp_val_ai_exmnbl reference is changed
      IF igs_as_val_aiem.assp_val_ai_exmnbl (new_references.ass_id, v_message_name) = TRUE THEN
        --<uai13>
        -- Validate that the reference number id unique within a UOP
        IF igs_as_val_uai.assp_val_uai_uniqref (
             lv_unit_cd,
             lv_version_number,
             lv_cal_type,
             lv_ci_sequence_number,
             new_references.sequence_number,
             new_references.REFERENCE,
             new_references.ass_id,
             v_message_name
           ) = FALSE THEN
          fnd_message.set_name ('IGS', v_message_name);
          igs_ge_msg_stack.ADD;
          app_exception.raise_exception;
        END IF;
      ELSE
        --<uai14>
        -- if record has not been deleted
        IF NVL (new_references.logical_delete_dt, igs_ge_date.igsdate ('1900/01/01')) =
           igs_ge_date.igsdate ('1900/01/01') THEN
          -- Validate that the reference number id unique within a UOP
          IF igs_ps_val_uai.assp_val_uai_opt_ref (
               lv_unit_cd,
               lv_version_number,
               lv_cal_type,
               lv_ci_sequence_number,
               new_references.sequence_number,
               new_references.REFERENCE,
               new_references.ass_id,
               igs_as_gen_001.assp_get_ai_a_type (new_references.ass_id),
               v_message_name
             ) = FALSE THEN
            fnd_message.set_name ('IGS', v_message_name);
            igs_ge_msg_stack.ADD;
            app_exception.raise_exception;
          END IF;
        END IF;
      END IF;
    -- Save the rowid of the current row.
    END IF;
  END afterrowinsertupdate3;

  PROCEDURE check_constraints (column_name IN VARCHAR2 DEFAULT NULL, column_value IN VARCHAR2 DEFAULT NULL) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    NULL;
  END check_constraints;

  PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF get_uk_for_validation (new_references.ass_id, new_references.sequence_number, new_references.uoo_id) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF (((old_references.us_ass_item_group_id = new_references.us_ass_item_group_id))
        OR ((new_references.us_ass_item_group_id IS NULL))
       ) THEN
      NULL;
    ELSIF NOT igs_as_us_ai_group_pkg.get_pk_for_validation (
                new_references.us_ass_item_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;

  -- ADDED BY DDEY FOR BUG # 2162831
  PROCEDURE get_fk_igs_as_grd_schema (x_grading_schema_cd IN VARCHAR2, x_version_number IN NUMBER) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_ps_unitass_item
      WHERE  grading_schema_cd = x_grading_schema_cd
      AND    gs_version_number = x_version_number;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_UNAS_GS_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_grd_schema;

  PROCEDURE get_fk_igs_as_us_ai_group (x_us_ass_item_group_id IN NUMBER) AS
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_ps_unitass_item
      WHERE  us_ass_item_group_id = x_us_ass_item_group_id;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      fnd_message.set_name ('IGS', 'IGS_AS_UNAS_USAI_FK');
      igs_ge_msg_stack.ADD;
      CLOSE cur_rowid;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igs_as_us_ai_group;

  FUNCTION get_pk_for_validation (x_unit_section_ass_item_id IN NUMBER)
    RETURN BOOLEAN AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_ps_unitass_item
      WHERE      unit_section_ass_item_id = x_unit_section_ass_item_id
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

  FUNCTION get_uk_for_validation (x_ass_id IN NUMBER, x_sequence_number IN NUMBER, x_uoo_id IN NUMBER)
    RETURN BOOLEAN AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  DDEY          8-JAN-2002       The changes done as per DLD Calculation
                                 of Results Part 1.
  jdeekoll      27-MAR-2002      Removed the changes implemented by DDEY as
                                 a part of DLD calculation Results Part 1
                                 Confirmed with DDEY/PRGOYAL. Copied the
                                 original get_fk from 115.6 version
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_ps_unitass_item
      WHERE  ass_id = x_ass_id
      AND    sequence_number = x_sequence_number
      AND    uoo_id = x_uoo_id
      AND    ((l_rowid IS NULL)
              OR (ROWID <> l_rowid)
             );
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
  END get_uk_for_validation;

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_unit_section_ass_item_id     IN     NUMBER DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_ass_id                       IN     NUMBER DEFAULT NULL,
    x_sequence_number              IN     NUMBER DEFAULT NULL,
    x_ci_start_dt                  IN     DATE DEFAULT NULL,
    x_ci_end_dt                    IN     DATE DEFAULT NULL,
    x_due_dt                       IN     DATE DEFAULT NULL,
    x_reference                    IN     VARCHAR2 DEFAULT NULL,
    x_dflt_item_ind                IN     VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt            IN     DATE DEFAULT NULL,
    x_action_dt                    IN     DATE DEFAULT NULL,
    x_exam_cal_type                IN     VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number      IN     NUMBER DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_gs_version_number            IN     NUMBER DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c1 IS
      SELECT unit_cd,
             cal_type,
             version_number,
             ci_sequence_number
      FROM   igs_ps_unit_ofr_opt
      WHERE  uoo_id = new_references.uoo_id;
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_unit_section_ass_item_id,
      x_uoo_id,
      x_ass_id,
      x_sequence_number,
      x_ci_start_dt,
      x_ci_end_dt,
      x_due_dt,
      x_reference,
      x_dflt_item_ind,
      x_logical_delete_dt,
      x_action_dt,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_grading_schema_cd,
      x_gs_version_number,
      x_release_date,
      x_description,
      x_us_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty
    );
    /* Code written because cal_type and lv_unit_cd are not available in this field and being fetched from
       IGS_PS_UNIT_OFR_OPT table thru uoo_id */
    FOR i IN c1 LOOP
      lv_unit_cd := i.unit_cd;
      lv_cal_type := i.cal_type;
      lv_version_number := i.version_number;
      lv_ci_sequence_number := i.ci_sequence_number;
    END LOOP;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      -- BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      beforerowinsertupdate2 (p_inserting => TRUE);
      IF get_pk_for_validation (new_references.unit_section_ass_item_id) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      --BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      beforerowinsertupdate2 (p_inserting => TRUE);
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      NULL;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (new_references.unit_section_ass_item_id) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;
  END before_dml;

  PROCEDURE after_dml (p_action IN VARCHAR2, x_rowid IN VARCHAR2) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      --   AfterRowInsertUpdate3 ( p_inserting => TRUE );
      NULL;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      afterrowinsertupdate3 (p_inserting => TRUE);
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;
    l_rowid := NULL;
  END after_dml;

  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_unit_section_ass_item_id     IN OUT NOCOPY NUMBER,
    x_uoo_id                       IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN OUT NOCOPY NUMBER,
    x_ci_start_dt                  IN OUT NOCOPY DATE,
    x_ci_end_dt                    IN OUT NOCOPY DATE,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c IS
      SELECT ROWID
      FROM   igs_ps_unitass_item
      WHERE  unit_section_ass_item_id = x_unit_section_ass_item_id;
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
    ELSIF (x_mode = 'R') THEN
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
    SELECT igs_ps_unitass_item_s.NEXTVAL
    INTO   x_unit_section_ass_item_id
    FROM   DUAL;
    SELECT igs_ps_unitass_item_seq_num_s.NEXTVAL
    INTO   x_sequence_number
    FROM   DUAL;
    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_unit_section_ass_item_id     => x_unit_section_ass_item_id,
      x_uoo_id                       => x_uoo_id,
      x_ass_id                       => x_ass_id,
      x_sequence_number              => x_sequence_number,
      x_ci_start_dt                  => x_ci_start_dt,
      x_ci_end_dt                    => x_ci_end_dt,
      x_due_dt                       => x_due_dt,
      x_reference                    => x_reference,
      x_dflt_item_ind                => x_dflt_item_ind,
      x_logical_delete_dt            => x_logical_delete_dt,
      x_action_dt                    => x_action_dt,
      x_exam_cal_type                => x_exam_cal_type,
      x_exam_ci_sequence_number      => x_exam_ci_sequence_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_gs_version_number            => x_gs_version_number,
      x_release_date                 => x_release_date,
      x_description                  => x_description,
      x_us_ass_item_group_id         => x_us_ass_item_group_id,
      x_midterm_mandatory_type_code  => x_midterm_mandatory_type_code,
      x_midterm_weight_qty           => x_midterm_weight_qty,
      x_final_mandatory_type_code    => x_final_mandatory_type_code,
      x_final_weight_qty             => x_final_weight_qty
    );
    INSERT INTO igs_ps_unitass_item
                (unit_section_ass_item_id, uoo_id, ass_id,
                 sequence_number, ci_start_dt, ci_end_dt,
                 due_dt, REFERENCE, dflt_item_ind,
                 logical_delete_dt, action_dt, exam_cal_type,
                 exam_ci_sequence_number, grading_schema_cd,
                 gs_version_number, release_date, creation_date, created_by,
                 last_update_date, last_updated_by, last_update_login, request_id, program_id,
                 program_application_id, program_update_date, description,
                 us_ass_item_group_id,
                 midterm_mandatory_type_code,
                 midterm_weight_qty,
                 final_mandatory_type_code,
                 final_weight_qty)
         VALUES (new_references.unit_section_ass_item_id, new_references.uoo_id, new_references.ass_id,
                 new_references.sequence_number, new_references.ci_start_dt, new_references.ci_end_dt,
                 new_references.due_dt, new_references.REFERENCE, new_references.dflt_item_ind,
                 new_references.logical_delete_dt, new_references.action_dt, new_references.exam_cal_type,
                 new_references.exam_ci_sequence_number, new_references.grading_schema_cd,
                 new_references.gs_version_number, new_references.release_date, x_last_update_date, x_last_updated_by,
                 x_last_update_date, x_last_updated_by, x_last_update_login, x_request_id, x_program_id,
                 x_program_application_id, x_program_update_date, new_references.description,
                 new_references.us_ass_item_group_id,
                 new_references.midterm_mandatory_type_code,
                 new_references.midterm_weight_qty,
                 new_references.final_mandatory_type_code,
                 new_references.final_weight_qty);
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml (p_action => 'INSERT', x_rowid => x_rowid);
    x_ci_start_dt := new_references.ci_start_dt;
    x_ci_end_dt := new_references.ci_end_dt;
  END insert_row;

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_unit_section_ass_item_id     IN     NUMBER,
    x_uoo_id                       IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2 DEFAULT NULL,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c1 IS
      SELECT     uoo_id,
                 ass_id,
                 sequence_number,
                 ci_start_dt,
                 ci_end_dt,
                 due_dt,
                 REFERENCE,
                 dflt_item_ind,
                 logical_delete_dt,
                 action_dt,
                 exam_cal_type,
                 exam_ci_sequence_number,
                 grading_schema_cd,
                 gs_version_number,
                 release_date,
                 description,
                 us_ass_item_group_id,
                 midterm_mandatory_type_code,
                 midterm_weight_qty,
                 final_mandatory_type_code,
                 final_weight_qty
      FROM       igs_ps_unitass_item
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF ((tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.ass_id = x_ass_id)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.ci_start_dt = x_ci_start_dt)
        AND (tlinfo.ci_end_dt = x_ci_end_dt)
        AND ((tlinfo.due_dt = x_due_dt)
             OR ((tlinfo.due_dt IS NULL)
                 AND (x_due_dt IS NULL)
                )
            )
        AND ((RTRIM(tlinfo.REFERENCE) = RTRIM(x_reference))
             OR ((tlinfo.REFERENCE IS NULL)
                 AND (x_reference IS NULL)
                )
            )
        AND (tlinfo.dflt_item_ind = x_dflt_item_ind)
        AND ((tlinfo.logical_delete_dt = x_logical_delete_dt)
             OR ((tlinfo.logical_delete_dt IS NULL)
                 AND (x_logical_delete_dt IS NULL)
                )
            )
        AND ((tlinfo.action_dt = x_action_dt)
             OR ((tlinfo.action_dt IS NULL)
                 AND (x_action_dt IS NULL)
                )
            )
        AND ((tlinfo.exam_cal_type = x_exam_cal_type)
             OR ((tlinfo.exam_cal_type IS NULL)
                 AND (x_exam_cal_type IS NULL)
                )
            )
        AND ((tlinfo.exam_ci_sequence_number = x_exam_ci_sequence_number)
             OR ((tlinfo.exam_ci_sequence_number IS NULL)
                 AND (x_exam_ci_sequence_number IS NULL)
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
        AND ((tlinfo.description = x_description)
             OR ((tlinfo.description IS NULL)
                 AND (x_description IS NULL)
                )
            )
        AND ((tlinfo.release_date = x_release_date)
             OR ((tlinfo.release_date IS NULL)
                 AND (x_release_date IS NULL)
                )
            )
        AND ((tlinfo.us_ass_item_group_id = x_us_ass_item_group_id)
             OR ((tlinfo.us_ass_item_group_id IS NULL)
                 AND (x_us_ass_item_group_id IS NULL)
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
    x_unit_section_ass_item_id     IN     NUMBER,
    x_uoo_id                       IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN     NUMBER,
    x_ci_start_dt                  IN     DATE,
    x_ci_end_dt                    IN     DATE,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
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
    ELSIF (x_mode = 'R') THEN
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
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_unit_section_ass_item_id     => x_unit_section_ass_item_id,
      x_uoo_id                       => x_uoo_id,
      x_ass_id                       => x_ass_id,
      x_sequence_number              => x_sequence_number,
      x_ci_start_dt                  => x_ci_start_dt,
      x_ci_end_dt                    => x_ci_end_dt,
      x_due_dt                       => x_due_dt,
      x_reference                    => x_reference,
      x_dflt_item_ind                => x_dflt_item_ind,
      x_logical_delete_dt            => x_logical_delete_dt,
      x_action_dt                    => x_action_dt,
      x_exam_cal_type                => x_exam_cal_type,
      x_exam_ci_sequence_number      => x_exam_ci_sequence_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_gs_version_number            => x_gs_version_number,
      x_release_date                 => x_release_date,
      x_us_ass_item_group_id         => x_us_ass_item_group_id,
      x_midterm_mandatory_type_code  => x_midterm_mandatory_type_code,
      x_midterm_weight_qty           => x_midterm_weight_qty,
      x_final_mandatory_type_code    => x_final_mandatory_type_code,
      x_final_weight_qty             => x_final_weight_qty
    );
    UPDATE igs_ps_unitass_item
       SET uoo_id = new_references.uoo_id,
           ass_id = new_references.ass_id,
           sequence_number = new_references.sequence_number,
           ci_start_dt = new_references.ci_start_dt,
           ci_end_dt = new_references.ci_end_dt,
           due_dt = new_references.due_dt,
           REFERENCE = new_references.REFERENCE,
           dflt_item_ind = new_references.dflt_item_ind,
           logical_delete_dt = new_references.logical_delete_dt,
           action_dt = new_references.action_dt,
           exam_cal_type = new_references.exam_cal_type,
           exam_ci_sequence_number = new_references.exam_ci_sequence_number,
           grading_schema_cd = new_references.grading_schema_cd,
           gs_version_number = new_references.gs_version_number,
           release_date = new_references.release_date,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           request_id = x_request_id,
           program_id = x_program_id,
           program_application_id = x_program_application_id,
           program_update_date = x_program_update_date,
           description = x_description,
           us_ass_item_group_id = x_us_ass_item_group_id,
           midterm_mandatory_type_code = x_midterm_mandatory_type_code,
           midterm_weight_qty = x_midterm_weight_qty,
           final_mandatory_type_code = x_final_mandatory_type_code,
           final_weight_qty = x_final_weight_qty
     WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (p_action => 'UPDATE', x_rowid => x_rowid);
  END update_row;

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_unit_section_ass_item_id     IN OUT NOCOPY NUMBER,
    x_uoo_id                       IN     NUMBER,
    x_ass_id                       IN     NUMBER,
    x_sequence_number              IN OUT NOCOPY NUMBER,
    x_ci_start_dt                  IN OUT NOCOPY DATE,
    x_ci_end_dt                    IN OUT NOCOPY DATE,
    x_due_dt                       IN     DATE,
    x_reference                    IN     VARCHAR2,
    x_dflt_item_ind                IN     VARCHAR2,
    x_logical_delete_dt            IN     DATE,
    x_action_dt                    IN     DATE,
    x_exam_cal_type                IN     VARCHAR2,
    x_exam_ci_sequence_number      IN     NUMBER,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_grading_schema_cd            IN     VARCHAR2,
    x_gs_version_number            IN     NUMBER,
    x_release_date                 IN     DATE,
    x_description                  IN     VARCHAR2,
    x_us_ass_item_group_id         IN     VARCHAR2 DEFAULT NULL,
    x_midterm_mandatory_type_code  IN     VARCHAR2 DEFAULT NULL,
    x_midterm_weight_qty           IN     NUMBER DEFAULT NULL,
    x_final_mandatory_type_code    IN     VARCHAR2 DEFAULT NULL,
    x_final_weight_qty             IN     NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_ps_unitass_item
      WHERE  unit_section_ass_item_id = x_unit_section_ass_item_id;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_unit_section_ass_item_id,
        x_uoo_id,
        x_ass_id,
        x_sequence_number,
        x_ci_start_dt,
        x_ci_end_dt,
        x_due_dt,
        x_reference,
        x_dflt_item_ind,
        x_logical_delete_dt,
        x_action_dt,
        x_exam_cal_type,
        x_exam_ci_sequence_number,
        x_mode,
        x_grading_schema_cd,
        x_gs_version_number,
        x_release_date,
        x_description,
        x_us_ass_item_group_id,
        x_midterm_mandatory_type_code,
        x_midterm_weight_qty,
        x_final_mandatory_type_code,
        x_final_weight_qty
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_unit_section_ass_item_id,
      x_uoo_id,
      x_ass_id,
      x_sequence_number,
      x_ci_start_dt,
      x_ci_end_dt,
      x_due_dt,
      x_reference,
      x_dflt_item_ind,
      x_logical_delete_dt,
      x_action_dt,
      x_exam_cal_type,
      x_exam_ci_sequence_number,
      x_mode,
      x_grading_schema_cd,
      x_gs_version_number,
      x_release_date,
      x_description,
      x_us_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty
    );
  END add_row;

  PROCEDURE delete_row (x_rowid IN VARCHAR2) AS
  /*************************************************************
  Created By      : jdeekoll
  Date Created By : 11-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    before_dml (p_action => 'DELETE', x_rowid => x_rowid);
    DELETE FROM igs_ps_unitass_item
          WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml (p_action => 'DELETE', x_rowid => x_rowid);
  END delete_row;
END igs_ps_unitass_item_pkg;

/
