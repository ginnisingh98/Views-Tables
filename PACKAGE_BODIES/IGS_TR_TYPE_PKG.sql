--------------------------------------------------------
--  DDL for Package Body IGS_TR_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_TYPE_PKG" AS
/* $Header: IGSTI05B.pls 115.10 2003/02/19 10:29:45 kpadiyar ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_type_all%ROWTYPE;
  new_references igs_tr_type_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_target_days IN NUMBER DEFAULT NULL,
    x_sequence_ind IN VARCHAR2 DEFAULT NULL,
    x_business_days_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_type_all
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

    -- Populate New Values.
    new_references.tracking_type := x_tracking_type;
    new_references.description := x_description;
    new_references.s_tracking_type := x_s_tracking_type;
    new_references.target_days := x_target_days;
    new_references.sequence_ind := x_sequence_ind;
    new_references.business_days_ind := x_business_days_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.publish_ind := x_publish_ind;
    new_references.org_id := x_org_id;

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



  PROCEDURE check_parent_existance AS
  BEGIN

    IF (((old_references.s_tracking_type = new_references.s_tracking_type)) OR
        ((new_references.s_tracking_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_lookups_view_pkg.get_pk_for_validation('TRACKING_TYPE',new_references.s_tracking_type)THEN
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_tracking_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_type_all
      WHERE    tracking_type = x_tracking_type;

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

  PROCEDURE get_fk_igs_lookups_view(
    x_s_tracking_type IN VARCHAR2
  ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_type_all
      WHERE    s_tracking_type = x_s_tracking_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_TR_TRT_STT_FK');
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
    ELSIF UPPER(column_name) = 'TARGET_DAYS' THEN
      new_references.target_days := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'BUSINESS_DAYS_IND' THEN
      new_references.business_days_ind := column_value;
    ELSIF UPPER(column_name) = 'CLOSED_IND' THEN
      new_references.closed_ind := column_value;
    ELSIF UPPER(column_name) = 'SEQUENCE_IND' THEN
      new_references.sequence_ind := column_value;
    ELSIF UPPER(column_name) = 'S_TRACKING_TYPE' THEN
      new_references.s_tracking_type := column_value;
    ELSIF UPPER(column_name) = 'TRACKING_TYPE' THEN
      new_references.tracking_type := column_value;
    ELSIF UPPER(column_name) = 'PUBLISH_IND' THEN
      new_references.publish_ind := column_value;
    END IF;
    --kumma, 2702342, Increased the value of constant from 999 to 9999
    IF UPPER(column_name) = 'TARGET_DAYS' OR column_name IS NULL THEN
      IF (new_references.target_days < 0 OR new_references.target_days > 9999 )THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'BUSINESS_DAYS_IND' OR column_name IS NULL THEN
      IF new_references.business_days_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'CLOSED_IND' OR column_name IS NULL THEN
      IF new_references.closed_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'SEQUENCE_IND' OR column_name IS NULL THEN
      IF new_references.sequence_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'BUSINESS_DAYS_IND' OR column_name IS NULL THEN
      IF new_references.business_days_ind <> UPPER(new_references.business_days_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'CLOSED_IND' OR column_name IS NULL THEN
      IF new_references.closed_ind <> UPPER(new_references.closed_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'SEQUENCE_IND' OR column_name IS NULL THEN
      IF new_references.sequence_ind <> UPPER(new_references.sequence_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'S_TRACKING_TYPE' OR column_name IS NULL THEN
      IF new_references.s_tracking_type <> UPPER(new_references.s_tracking_type) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'TRACKING_TYPE' OR column_name IS NULL THEN
      IF new_references.tracking_type <> UPPER(new_references.tracking_type) THEN
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

    IF UPPER(column_name) = 'PUBLISH_IND' OR column_name IS NULL THEN
      IF new_references.publish_ind <> UPPER(new_references.publish_ind) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_constraints;


  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_target_days IN NUMBER DEFAULT NULL,
    x_sequence_ind IN VARCHAR2 DEFAULT NULL,
    x_business_days_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_publish_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_tracking_type,
      x_description,
      x_s_tracking_type,
      x_target_days,
      x_sequence_ind,
      x_business_days_ind,
      x_closed_ind,
      x_publish_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      NULL;

      IF get_pk_for_validation( new_references.tracking_type )THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      NULL;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF get_pk_for_validation( new_references.tracking_type)THEN
        fnd_message.set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;

    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
  END after_dml;


  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_type IN VARCHAR2,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  ) AS

    CURSOR c IS
      SELECT   ROWID
      FROM     igs_tr_type_all
      WHERE    tracking_type = x_tracking_type;

    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;

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
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action =>'INSERT',
      x_rowid =>x_rowid,
      x_tracking_type => x_tracking_type,
      x_description => x_description,
      x_s_tracking_type => x_s_tracking_type,
      x_target_days => x_target_days,
      x_sequence_ind => NVL(x_sequence_ind,'N'),
      x_business_days_ind => NVL(x_business_days_ind,'Y'),
      x_closed_ind => NVL(x_closed_ind,'N'),
      x_publish_ind => NVL(x_publish_ind,'N'),
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login,
      x_org_id => igs_ge_gen_003.get_org_id
    );

    INSERT INTO igs_tr_type_all (
      tracking_type,
      description,
      s_tracking_type,
      target_days,
      sequence_ind,
      business_days_ind,
      closed_ind,
      publish_ind,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.tracking_type,
      new_references.description,
      new_references.s_tracking_type,
      new_references.target_days,
      new_references.sequence_ind,
      new_references.business_days_ind,
      new_references.closed_ind,
      new_references.publish_ind,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE no_data_found;
    END IF;
    CLOSE c;

    after_dml(
      p_action =>'INSERT',
      x_rowid => x_rowid
    );

  END insert_row;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_type IN VARCHAR2,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_publish_ind IN VARCHAR2 DEFAULT 'N'
  ) AS

    CURSOR c1 IS
      SELECT  description,s_tracking_type,target_days,sequence_ind,business_days_ind,
      		closed_ind, publish_ind
      FROM    igs_tr_type_all
      WHERE   ROWID = x_rowid
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

    IF ( (tlinfo.description = x_description)
      AND (tlinfo.s_tracking_type = x_s_tracking_type)
      AND (tlinfo.target_days = x_target_days)
      AND (tlinfo.sequence_ind = x_sequence_ind)
      AND (tlinfo.business_days_ind = x_business_days_ind)
      AND (tlinfo.closed_ind = x_closed_ind)
      AND ((tlinfo.publish_ind = x_publish_ind)
        OR ((tlinfo.publish_ind IS NULL)
        AND (x_publish_ind IS NULL)))
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
    x_tracking_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_type IN VARCHAR2,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS

    x_last_update_date DATE;
    x_last_updated_by NUMBER;
    x_last_update_login NUMBER;

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
      x_tracking_type => x_tracking_type,
      x_description => x_description,
      x_s_tracking_type => x_s_tracking_type,
      x_target_days => x_target_days,
      x_sequence_ind => x_sequence_ind,
      x_business_days_ind => x_business_days_ind,
      x_closed_ind => x_closed_ind,
      x_publish_ind => x_publish_ind,
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login
    );

    UPDATE igs_tr_type_all SET
      description = new_references.description,
      s_tracking_type = new_references.s_tracking_type,
      target_days = new_references.target_days,
      sequence_ind = new_references.sequence_ind,
      business_days_ind = new_references.business_days_ind,
      closed_ind = new_references.closed_ind,
      publish_ind = new_references.publish_ind,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login
    WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    after_dml(
      p_action =>'UPDATE',
      x_rowid => x_rowid
    );

  END update_row;

  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_type IN VARCHAR2,
    x_target_days IN NUMBER,
    x_sequence_ind IN VARCHAR2,
    x_business_days_ind IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_publish_ind IN VARCHAR2 DEFAULT 'N',
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  ) AS

    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_tr_type_all
      WHERE  tracking_type = x_tracking_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;

    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_tracking_type,
        x_description,
        x_s_tracking_type,
        x_target_days,
        x_sequence_ind,
        x_business_days_ind,
        x_closed_ind,
        x_publish_ind,
        x_mode,
        x_org_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_tracking_type,
      x_description,
      x_s_tracking_type,
      x_target_days,
      x_sequence_ind,
      x_business_days_ind,
      x_closed_ind,
      x_publish_ind,
      x_mode);
  END add_row;

END igs_tr_type_pkg;

/
