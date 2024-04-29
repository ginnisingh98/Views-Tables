--------------------------------------------------------
--  DDL for Package Body IGS_TR_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_NOTE_TYPE_PKG" AS
/* $Header: IGSTI08B.pls 115.5 2002/11/29 04:15:54 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_note_type%ROWTYPE;
  new_references igs_tr_note_type%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_trk_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_note_type
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
            igs_ge_msg_stack.add;
      app_exception.raise_exception;
       RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.trk_note_type := x_trk_note_type;
    new_references.description := x_description;
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

  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
  )AS
  BEGIN

    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'TRK_NOTE_TYPE' THEN
      new_references.trk_note_type:= column_value ;
    END IF ;

    IF UPPER(column_name) = 'TRK_NOTE_TYPE' OR column_name IS NULL THEN
      IF new_references.trk_note_type<> UPPER(new_references.trk_note_type) THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception ;
      END IF;
    END IF ;

  END check_constraints;

  PROCEDURE check_child_existance AS
  BEGIN

    igs_tr_group_note_pkg.get_fk_igs_tr_note_type (
      old_references.trk_note_type
     );

    igs_tr_item_note_pkg.get_fk_igs_tr_note_type (
      old_references.trk_note_type
     );

    igs_tr_step_note_pkg.get_fk_igs_tr_note_type (
      old_references.trk_note_type
     );

    igs_tr_typ_step_note_pkg.get_fk_igs_tr_note_type (
      old_references.trk_note_type
     );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_trk_note_type IN VARCHAR2
  )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_note_type
      WHERE    trk_note_type = x_trk_note_type
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

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_trk_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_trk_note_type,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
     IF  get_pk_for_validation (
          new_references.trk_note_type
     ) THEN
       fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'UPDATE') THEN
      check_constraints;

    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  get_pk_for_validation ( new_references.trk_note_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;

    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
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
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS

    CURSOR c IS
      SELECT ROWID
      FROM   igs_tr_note_type
      WHERE  trk_note_type = x_trk_note_type;

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
      x_trk_note_type => x_trk_note_type,
      x_description => x_description,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login
    );

    INSERT INTO igs_tr_note_type (
      trk_note_type,
      description,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.trk_note_type,
      new_references.description,
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
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2
  ) AS

    CURSOR c1 IS
      SELECT  description
      FROM    igs_tr_note_type
      WHERE   ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF ( (tlinfo.description = x_description) ) THEN
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
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
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
      x_trk_note_type => x_trk_note_type,
      x_description => x_description,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login
    );

    UPDATE igs_tr_note_type SET
      description = new_references.description,
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
    x_trk_note_type IN VARCHAR2,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R'
  ) AS

    CURSOR c1 IS
      SELECT ROWID
      FROM igs_tr_note_type
     WHERE trk_note_type = x_trk_note_type;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row ( x_rowid, x_trk_note_type, x_description, x_mode);
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_trk_note_type,
      x_description,
      x_mode
    );

  END add_row;

  PROCEDURE delete_row (
   x_rowid IN VARCHAR2
  ) AS

  BEGIN

    before_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_tr_note_type WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
    after_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
    );

  END delete_row;

END igs_tr_note_type_pkg;

/
