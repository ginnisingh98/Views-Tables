--------------------------------------------------------
--  DDL for Package Body IGS_TR_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_STATUS_PKG" AS
/* $Header: IGSTI02B.pls 115.8 2003/02/20 06:04:57 kpadiyar ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_status%ROWTYPE;
  new_references igs_tr_status%ROWTYPE;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_status
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
    new_references.tracking_status := x_tracking_status;
    new_references.description := x_description;
    new_references.s_tracking_status := x_s_tracking_status;
    new_references.closed_ind := x_closed_ind;
    new_references.default_ind := x_default_ind;

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

  FUNCTION get_pk_for_validation (
    x_tracking_status IN VARCHAR2)
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_status
      WHERE    tracking_status = x_tracking_status;

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

  -- procedure to check constraints
  PROCEDURE check_constraints(
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'S_TRACKING_STATUS' THEN
      new_references.s_tracking_status := column_value;
    ELSIF UPPER(column_name) = 'CLOSED_IND' THEN
      new_references.closed_ind := column_value;
    ELSIF UPPER(column_name) = 'TRACKING_STATUS' THEN
      new_references.tracking_status := column_value;
    ELSIF UPPER(column_name) = 'DEFAULT_IND' THEN
      new_references.default_ind := column_value;
    END IF;

    IF UPPER(column_name) = 'S_TRACKING_STATUS' OR column_name IS NULL THEN
      IF new_references.s_tracking_status NOT IN ('ACTIVE','CANCELLED','COMPLETE')THEN
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

    IF UPPER(column_name) = 'DEFAULT_IND' OR column_name IS NULL THEN
      IF new_references.default_ind NOT IN ('Y','N') THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'S_TRACKING_STATUS' OR column_name IS NULL THEN
      IF new_references.s_tracking_status <> UPPER(new_references.s_tracking_status) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name) = 'TRACKING_STATUS' OR column_name IS NULL THEN
      IF new_references.tracking_status <> UPPER(new_references.tracking_status) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_tracking_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  ) AS
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_tracking_status,
      x_description,
      x_s_tracking_status,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_default_ind
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      NULL;
      IF get_pk_for_validation( new_references.tracking_status )THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      NULL;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF get_pk_for_validation( new_references.tracking_status )THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
    END IF;

  END before_dml;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END after_dml;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE insert_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
    ) AS

    CURSOR c IS
      SELECT ROWID
      FROM   igs_tr_status
      WHERE  tracking_status = x_tracking_status;
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

    before_dml(p_action =>'INSERT',
      x_rowid =>x_rowid,
      x_tracking_status => x_tracking_status,
      x_description => x_description,
      x_s_tracking_status => x_s_tracking_status,
      x_closed_ind => NVL(x_closed_ind,'N'),
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login,
      x_default_ind  => NVL(x_default_ind,'N')
    );

    INSERT INTO igs_tr_status (
      tracking_status,
      description,
      s_tracking_status,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      default_ind
    ) VALUES (
      new_references.tracking_status,
      new_references.description,
      new_references.s_tracking_status,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.default_ind
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

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_default_ind IN VARCHAR2 DEFAULT 'N'
  ) AS
  CURSOR c1 IS
    SELECT   description,s_tracking_status,closed_ind
    FROM     igs_tr_status
    WHERE    ROWID = x_rowid
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
      AND (tlinfo.s_tracking_status = x_s_tracking_status)
      AND (tlinfo.closed_ind = x_closed_ind)) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    RETURN;

  END lock_row;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE update_row (
    x_rowid IN VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
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
      x_tracking_status => x_tracking_status,
      x_description => x_description,
      x_s_tracking_status => x_s_tracking_status,
      x_closed_ind => x_closed_ind,
      x_creation_date =>x_last_update_date,
      x_created_by =>x_last_updated_by,
      x_last_update_date =>x_last_update_date,
      x_last_updated_by =>x_last_updated_by,
      x_last_update_login =>x_last_update_login,
      x_default_ind => x_default_ind
    );

    UPDATE igs_tr_status SET
      description = new_references.description,
      s_tracking_status = new_references.s_tracking_status,
      closed_ind = new_references.closed_ind,
      last_update_date = x_last_update_date,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login,
      default_ind = new_references.default_ind
    WHERE tracking_status = x_tracking_status;
    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    after_dml(
      p_action =>'UPDATE',
      x_rowid => x_rowid
      );

  END update_row;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. Used for creation of tracking steps and associating them with
     system tracking types

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR003.fmb

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        9 Jul, 2001    Added the new column default_ind
  *******************************************************************************/
  PROCEDURE add_row (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_tracking_status IN VARCHAR2,
    x_description IN VARCHAR2,
    x_s_tracking_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_default_ind IN VARCHAR2 DEFAULT 'N'
    ) AS
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_tr_status
      WHERE    tracking_status = x_tracking_status;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;

    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_tracking_status,
        x_description,
        x_s_tracking_status,
        x_closed_ind,
        x_mode,
        x_default_ind);
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_tracking_status,
      x_description,
      x_s_tracking_status,
     x_closed_ind,
     x_mode,
     x_default_ind);

  END add_row;

END igs_tr_status_pkg;

/
