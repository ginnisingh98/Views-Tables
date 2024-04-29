--------------------------------------------------------
--  DDL for Package Body IGS_TR_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_GROUP_PKG" AS
/* $Header: IGSTI09B.pls 120.1 2005/09/08 15:41:58 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_group_all%ROWTYPE;
  new_references igs_tr_group_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_tracking_group_id IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_tr_group_all
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
    new_references.tracking_group_id := x_tracking_group_id;
    new_references.description := x_description;
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


  PROCEDURE check_constraints (
    column_name IN VARCHAR2 DEFAULT NULL,
    column_value  IN VARCHAR2 DEFAULT NULL
  )AS
  BEGIN

    IF column_name IS NULL THEN
      NULL;

    ELSIF UPPER(column_name) = 'TRACKING_GROUP_ID' THEN
      new_references.tracking_group_id:= igs_ge_number.to_num(column_value) ;
    END IF ;

    IF new_references.tracking_group_id < 1 OR new_references.tracking_group_id > 999999999 THEN
      fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception ;
    END IF;

  END check_constraints;

  PROCEDURE check_child_existance AS
  BEGIN

    igs_tr_group_member_pkg.get_fk_igs_tr_group (
      old_references.tracking_group_id
      );

    igs_tr_group_note_pkg.get_fk_igs_tr_group (
      old_references.tracking_group_id
      );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_tracking_group_id IN NUMBER
  ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_tr_group_all
      WHERE    tracking_group_id = x_tracking_group_id
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
    x_tracking_group_id IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
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
      x_tracking_group_id,
      x_description,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      IF  get_pk_for_validation ( new_references.tracking_group_id ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
      check_constraints;

    ELSIF (p_action = 'UPDATE') THEN
      check_constraints;

    ELSIF (p_action = 'DELETE') THEN
      check_child_existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  get_pk_for_validation ( new_references.tracking_group_id ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  x_tracking_group_id IN NUMBER,
  x_description IN VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R',
  x_org_id IN NUMBER
  ) AS

    CURSOR c IS
      SELECT ROWID
      FROM igs_tr_group_all
      WHERE tracking_group_id = x_tracking_group_id;

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
      x_tracking_group_id => x_tracking_group_id,
      x_description => x_description,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login,
      x_org_id => igs_ge_gen_003.get_org_id
    );

    INSERT INTO igs_tr_group_all (
      tracking_group_id,
      description,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.tracking_group_id,
      new_references.description,
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

    after_dml( p_action =>'INSERT', x_rowid => x_rowid);

  END insert_row;

  PROCEDURE lock_row (
    x_rowid IN VARCHAR2,
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2
  ) AS

    CURSOR c1 IS
      SELECT  description
      FROM    igs_tr_group_all
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
    x_tracking_group_id IN NUMBER,
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
      x_tracking_group_id => x_tracking_group_id,
      x_description => x_description,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login
    );

    UPDATE igs_tr_group_all SET
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
    x_tracking_group_id IN NUMBER,
    x_description IN VARCHAR2,
    x_mode IN VARCHAR2 DEFAULT 'R',
    x_org_id IN NUMBER
  ) AS

    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_tr_group_all
      WHERE  tracking_group_id = x_tracking_group_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_tracking_group_id,
        x_description,
        x_mode,
        x_org_id
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_tracking_group_id,
      x_description,
      x_mode);

  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    before_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
     );

    DELETE FROM igs_tr_group_all WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    after_dml(
      p_action =>'DELETE',
      x_rowid => x_rowid
    );
  END delete_row;

END igs_tr_group_pkg;

/
