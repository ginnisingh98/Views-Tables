--------------------------------------------------------
--  DDL for Package Body IGS_TR_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_STEP_PKG" AS
/* $Header: IGSTI03B.pls 115.10 2003/02/19 12:44:07 kpadiyar ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_tr_step%ROWTYPE;
  new_references igs_tr_step%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_tracking_step_id IN NUMBER DEFAULT NULL,
    x_tracking_step_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_completion_dt IN DATE DEFAULT NULL,
    x_action_days IN NUMBER DEFAULT NULL,
    x_step_completion_ind IN VARCHAR2 DEFAULT NULL,
    x_by_pass_ind IN VARCHAR2 DEFAULT NULL,
    x_recipient_id IN NUMBER DEFAULT NULL,
    x_s_tracking_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_step
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      CLOSE cur_old_ref_values;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    old_references.completion_dt            := TRUNC(old_references.completion_dt);

    -- Populate New Values.
    new_references.tracking_id := x_tracking_id;
    new_references.tracking_step_id := x_tracking_step_id;
    new_references.tracking_step_number := x_tracking_step_number;
    new_references.description := x_description;
    new_references.completion_dt := TRUNC(x_completion_dt);
    new_references.action_days := x_action_days;
    new_references.step_completion_ind := x_step_completion_ind;
    new_references.by_pass_ind := x_by_pass_ind;
    new_references.recipient_id := x_recipient_id;
    new_references.s_tracking_step_type := x_s_tracking_step_type;
    new_references.step_group_id := x_step_group_id;
    new_references.publish_ind :=x_publish_ind;
    new_references.step_catalog_cd := x_step_catalog_cd;

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

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE
    ) as
     v_message_name                  VARCHAR2(30);
  BEGIN
        IF (p_inserting OR (p_updating AND (old_references.step_catalog_cd <> new_references.step_catalog_cd))) THEN
	 IF NOT IGS_TR_VAL_TRI.val_tr_step_ctlg (new_references.step_catalog_cd,
	                                          v_message_name) THEN
             Fnd_Message.Set_Name('IGS', v_message_name);
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
	 END IF;
        END IF;
  END BeforeRowInsertUpdate;

  PROCEDURE beforerowinsertupdatedelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
  ) AS

    v_message_name   VARCHAR2(30);
    v_tracking_id igs_tr_step.tracking_id%TYPE;
    v_tracking_type igs_tr_item.tracking_type%TYPE;

    CURSOR c_tri (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
      SELECT  tracking_type
      FROM    igs_tr_item
      WHERE   tracking_id = cp_tracking_id;

  BEGIN

    -- Validate the completion date, step completion indicator and by pass
    -- indicator.
    IF (p_inserting OR
      (p_updating AND ((old_references.step_completion_ind <> new_references.step_completion_ind) OR
      (old_references.by_pass_ind <> new_references.by_pass_ind) OR
      (NVL(old_references.completion_dt, igs_ge_date.igsdate ('1900/01/01')) <>
      NVL(new_references.completion_dt, igs_ge_date.igsdate ('1900/01/01')))))) THEN

      IF igs_tr_val_trst.trkp_val_trst_sci_cd(
        new_references.step_completion_ind,
        new_references.completion_dt,
        new_references.by_pass_ind,
        v_message_name) = FALSE THEN

        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Validate the tracking step type.
    IF (p_inserting OR
      (p_updating AND (NVL(old_references.s_tracking_step_type, 'NULL') <>
      NVL(new_references.s_tracking_step_type, 'NULL')))) AND
      new_references.s_tracking_step_type IS NOT NULL THEN

      OPEN c_tri (new_references.tracking_id);
      FETCH c_tri
      INTO v_tracking_type;
      CLOSE c_tri;

      IF igs_tr_val_trst.trkp_val_stst_stt(
        new_references.s_tracking_step_type,
        v_tracking_type,
        v_message_name) = FALSE THEN

        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END beforerowinsertupdatedelete1;


  PROCEDURE check_parent_existance AS
  BEGIN

    IF (((old_references.recipient_id = new_references.recipient_id)) OR
      ((new_references.recipient_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_pe_person_pkg.get_pk_for_validation ( new_references.recipient_id )THEN
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.s_tracking_step_type = new_references.s_tracking_step_type)) OR
        ((new_references.s_tracking_step_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_lookups_view_pkg.get_pk_for_validation('TRACKING_STEP_TYPE',new_references.s_tracking_step_type)THEN
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.tracking_id = new_references.tracking_id)) OR ((new_references.tracking_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_tr_item_pkg.get_pk_for_validation ( new_references.tracking_id )THEN
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.step_catalog_cd = new_references.step_catalog_cd)) OR ((new_references.step_catalog_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_tr_step_ctlg_pkg.get_uk_for_validation ( new_references.step_catalog_cd )THEN
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_parent_existance;

  PROCEDURE check_child_existance AS
  BEGIN

    igs_tr_step_note_pkg.get_fk_igs_tr_step (
      old_references.tracking_id,
      old_references.tracking_step_id
    );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER)
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_step
      WHERE    tracking_id = x_tracking_id
      AND      tracking_step_id = x_tracking_step_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN TRUE;
    ELSE
      CLOSE cur_rowid;
      RETURN FALSE;
    END IF;

  END get_pk_for_validation;

  PROCEDURE get_fk_igs_pe_person (
    x_person_id IN NUMBER
  ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_step
      WHERE    recipient_id = x_person_id ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_TR_TRST_PE_RECIPIENT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;

  PROCEDURE get_fk_igs_tr_item (
    x_tracking_id IN NUMBER
  ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_step
      WHERE    tracking_id = x_tracking_id ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_TR_TRST_TRI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_tr_item;


  PROCEDURE get_fk_igs_lookups_view(
    x_s_tracking_step_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_step
      WHERE    s_tracking_step_type = x_s_tracking_step_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_TR_TRST_STST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_lookups_view;

-- procedure to check constraints
  PROCEDURE check_constraints(
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'BY_PASS_IND' THEN
      new_references.by_pass_ind := column_value;
    ELSIF UPPER(column_name) = 'STEP_COMPLETION_IND' THEN
      new_references.step_completion_ind := column_value;
    ELSIF UPPER(column_name) = 'S_TRACKING_STEP_TYPE' THEN
      new_references.s_tracking_step_type := column_value;
    ELSIF UPPER(column_name) = 'TRACKING_STEP_NUMBER' THEN
      new_references.tracking_step_number := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'ACTION_DAYS' THEN
      new_references.action_days := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'STEP_COMPLETION_IND' THEN
      new_references.step_completion_ind := column_value;
    ELSIF UPPER(column_name) = 'PUBLISH_IND' THEN
      new_references.publish_ind := column_value;
    END IF;

    IF UPPER(column_name) = 'TRACKING_STEP_NUMBER' OR column_name IS NULL THEN
      IF (new_references.tracking_step_number < 1 OR new_references.tracking_step_number > 99 )THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    --kumma, 2702342, increased the constant value from 999 to 9999
    IF UPPER(column_name) = 'ACTION_DAYS' OR column_name IS NULL THEN
      IF (new_references.action_days < 0 OR new_references.action_days > 9999 )THEN
         fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'STEP_COMPLETION_IND' OR column_name IS NULL THEN
      IF new_references.step_completion_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'BY_PASS_IND' OR column_name IS NULL THEN
      IF new_references.by_pass_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'BY_PASS_IND' OR column_name IS NULL THEN
      IF new_references.by_pass_ind <> UPPER(new_references.by_pass_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'STEP_COMPLETION_IND' OR column_name IS NULL THEN
      IF new_references.step_completion_ind <> UPPER(new_references.step_completion_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'S_TRACKING_STEP_TYPE' OR column_name IS NULL THEN
      IF new_references.s_tracking_step_type <> UPPER(new_references.s_tracking_step_type) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'PUBLISH_IND' OR column_name IS NULL THEN
      IF new_references.publish_ind <> UPPER(new_references.publish_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'PUBLISH_IND' OR column_name IS NULL THEN
      IF new_references.publish_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_tracking_step_id IN NUMBER DEFAULT NULL,
    x_tracking_step_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_completion_dt IN DATE DEFAULT NULL,
    x_action_days IN NUMBER DEFAULT NULL,
    x_step_completion_ind IN VARCHAR2 DEFAULT NULL,
    x_by_pass_ind IN VARCHAR2 DEFAULT NULL,
    x_recipient_id IN NUMBER DEFAULT NULL,
    x_s_tracking_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_tracking_id,
      x_tracking_step_id,
      x_tracking_step_number,
      x_description,
      x_completion_dt,
      x_action_days,
      x_step_completion_ind,
      x_by_pass_ind,
      x_recipient_id,
      x_s_tracking_step_type,
      x_step_group_id,
      x_publish_ind,
      x_step_catalog_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate ( p_inserting => TRUE );
      beforerowinsertupdatedelete1 ( p_inserting => TRUE );
      IF get_pk_for_validation(
        new_references.tracking_id,
        new_references.tracking_step_id
      )THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate ( p_updating => TRUE );
      beforerowinsertupdatedelete1 ( p_updating => TRUE );
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowinsertupdatedelete1 ( p_deleting => TRUE );
      check_child_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF get_pk_for_validation(
        new_references.tracking_id,
        new_references.tracking_step_id
      )THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_tracking_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_completion_dt IN DATE,
    x_action_days IN NUMBER,
    x_step_completion_ind IN VARCHAR2,
    x_by_pass_ind IN VARCHAR2,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS

    CURSOR c IS
      SELECT ROWID
      FROM   igs_tr_step
      WHERE  tracking_id = x_tracking_id AND tracking_step_id = x_tracking_step_id;

    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;

    ELSIF (x_mode = 'R') THEN

      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;

      x_last_update_login :=fnd_global.login_id;
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
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(p_action =>'INSERT',
      x_rowid =>x_rowid,
      x_tracking_id => x_tracking_id,
      x_tracking_step_id => x_tracking_step_id,
      x_tracking_step_number => x_tracking_step_number,
      x_description => x_description,
      x_completion_dt => x_completion_dt,
      x_action_days => x_action_days,
      x_step_completion_ind => x_step_completion_ind,
      x_by_pass_ind => NVL(x_by_pass_ind,'N'),
      x_recipient_id => x_recipient_id,
      x_s_tracking_step_type => x_s_tracking_step_type,
      x_step_group_id => x_step_group_id,
      x_publish_ind => NVL(x_publish_ind,'N'),
      x_step_catalog_cd => x_step_catalog_cd,
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login
    );

    INSERT INTO igs_tr_step (
      tracking_id,
      tracking_step_id,
      tracking_step_number,
      description,
      s_tracking_step_type,
      completion_dt,
      action_days,
      step_completion_ind,
      by_pass_ind,
      recipient_id,
      step_group_id,
      publish_ind,
      step_catalog_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.tracking_id,
      new_references.tracking_step_id,
      new_references.tracking_step_number,
      new_references.description,
      new_references.s_tracking_step_type,
      new_references.completion_dt,
      new_references.action_days,
      new_references.step_completion_ind,
      new_references.by_pass_ind,
      new_references.recipient_id,
      new_references.step_group_id,
      new_references.publish_ind,
      new_references.step_catalog_cd,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE no_data_found;
    END IF;
    CLOSE c;

  END insert_row;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_tracking_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_completion_dt IN DATE,
    x_action_days IN NUMBER,
    x_step_completion_ind IN VARCHAR2,
    x_by_pass_ind IN VARCHAR2,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR c1 IS
      SELECT    tracking_step_number, description,
                s_tracking_step_type, completion_dt,
		action_days, step_completion_ind,by_pass_ind, recipient_id,
		step_group_id, publish_ind, step_catalog_cd
      FROM      igs_tr_step
      WHERE     ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      CLOSE c1;
      RETURN;
    END IF;
    CLOSE c1;

    IF ( (tlinfo.tracking_step_number = x_tracking_step_number)
      AND (tlinfo.description = x_description)
      AND ((tlinfo.s_tracking_step_type = x_s_tracking_step_type)
        OR ((tlinfo.s_tracking_step_type IS NULL)
        AND (x_s_tracking_step_type IS NULL)))
      AND ((TRUNC(tlinfo.completion_dt) = TRUNC(x_completion_dt))
        OR ((tlinfo.completion_dt IS NULL)
        AND (x_completion_dt IS NULL)))
      AND (tlinfo.action_days = x_action_days)
      AND (tlinfo.step_completion_ind = x_step_completion_ind)
      AND (tlinfo.by_pass_ind = x_by_pass_ind)
      AND ((tlinfo.recipient_id = x_recipient_id)
        OR ((tlinfo.recipient_id IS NULL)
        AND (x_recipient_id IS NULL)))
      AND ((tlinfo.step_group_id = x_step_group_id)
        OR ((tlinfo.step_group_id IS NULL)
        AND (x_step_group_id IS NULL)))
      AND ((tlinfo.publish_ind = x_publish_ind)
        OR ((tlinfo.publish_ind IS NULL)
        AND (x_publish_ind IS NULL)))
      AND ((tlinfo.step_catalog_cd = x_step_catalog_cd)
        OR ((tlinfo.step_catalog_cd IS NULL)
        AND (x_step_catalog_cd IS NULL)))
    ) THEN
      NULL;

    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    RETURN;

  END lock_row;

  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_tracking_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_completion_dt IN DATE,
    x_action_days IN NUMBER,
    x_step_completion_ind IN VARCHAR2,
    x_by_pass_ind IN VARCHAR2,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;
    x_request_id NUMBER;
    x_program_id NUMBER;
    x_program_application_id NUMBER;
    x_program_update_date DATE;
  BEGIN
    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(p_action =>'UPDATE',
      x_rowid =>x_rowid,
      x_tracking_id => x_tracking_id,
      x_tracking_step_id => x_tracking_step_id,
      x_tracking_step_number => x_tracking_step_number,
      x_description => x_description,
      x_completion_dt => x_completion_dt,
      x_action_days => x_action_days,
      x_step_completion_ind => x_step_completion_ind,
      x_by_pass_ind => x_by_pass_ind,
      x_recipient_id => x_recipient_id,
      x_s_tracking_step_type => x_s_tracking_step_type,
      x_step_group_id => x_step_group_id,
      x_publish_ind => x_publish_ind,
      x_step_catalog_cd => x_step_catalog_cd,
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login
    );

    IF (x_mode = 'R') THEN
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

    UPDATE igs_tr_step SET
      tracking_step_number = new_references.tracking_step_number,
      description = new_references.description,
      s_tracking_step_type = new_references.s_tracking_step_type,
      completion_dt = new_references.completion_dt,
      action_days = new_references.action_days,
      step_completion_ind = new_references.step_completion_ind,
      by_pass_ind = new_references.by_pass_ind,
      recipient_id = new_references.recipient_id,
      step_group_id = new_references.step_group_id,
      publish_ind = new_references.publish_ind,
      step_catalog_cd = new_references.step_catalog_cd,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      request_id = x_request_id,
      program_id = x_program_id,
      program_application_id = x_program_application_id,
      program_update_date = x_program_update_date
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

  END update_row;

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_id IN NUMBER,
    x_tracking_step_id IN NUMBER,
    x_tracking_step_number IN NUMBER,
    x_description IN VARCHAR2,
    x_s_tracking_step_type IN VARCHAR2,
    x_completion_dt IN DATE,
    x_action_days IN NUMBER,
    x_step_completion_ind IN VARCHAR2,
    x_by_pass_ind IN VARCHAR2,
    x_recipient_id IN NUMBER,
    x_step_group_id IN NUMBER DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_step_catalog_cd IN VARCHAR2 DEFAULT NULL,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS
    CURSOR c1 IS
      SELECT  ROWID
      FROM    igs_tr_step
      WHERE   tracking_id = x_tracking_id
      AND     tracking_step_id = x_tracking_step_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_tracking_id,
        x_tracking_step_id,
        x_tracking_step_number,
        x_description,
        x_s_tracking_step_type,
        x_completion_dt,
        x_action_days,
        x_step_completion_ind,
        x_by_pass_ind,
        x_recipient_id,
        x_step_group_id,
        x_publish_ind,
        x_step_catalog_cd,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_tracking_id,
      x_tracking_step_id,
      x_tracking_step_number,
      x_description,
      x_s_tracking_step_type,
      x_completion_dt,
      x_action_days,
      x_step_completion_ind,
      x_by_pass_ind,
      x_recipient_id,
      x_step_group_id,
      x_publish_ind,
      x_step_catalog_cd,
      x_mode
    );

  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS

  BEGIN

    before_dml(p_action =>'DELETE',
      x_rowid =>x_rowid
    );

    DELETE FROM igs_tr_step
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

  END delete_row;

END igs_tr_step_pkg;

/
