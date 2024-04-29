--------------------------------------------------------
--  DDL for Package Body IGS_GE_CFG_NAV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_CFG_NAV_PKG" AS
/* $Header: IGSNIA2B.pls 115.2 2002/12/30 14:49:46 kumma noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ge_cfg_nav%ROWTYPE;
  new_references igs_ge_cfg_nav%ROWTYPE;
  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ge_cfg_nav
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.responsibility_id                 := x_responsibility_id;
    new_references.form_code                         := x_form_code;
    new_references.seq_number                        := x_seq_number;
    new_references.subform_code                      := x_subform_code;
    new_references.but_label                         := x_but_label;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;
    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;
  END set_column_values;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : kiran.padiyar@Oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma           20-DEC-2002     2675022, Changed the UK to include the but_label also
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.responsibility_id,
           new_references.form_code,
           new_references.seq_number,
	   new_references.but_label
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  FUNCTION get_pk_for_validation (
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_subform_code                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_cfg_nav
      WHERE    responsibility_id = x_responsibility_id
      AND      form_code = x_form_code
      AND      subform_code = x_subform_code
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_pk_for_validation;

  FUNCTION get_uk_for_validation (
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER ,
    x_but_label                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Validates the uniqueness for the combination of resp,form,seq.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma          20-DEC-2002      2675022, Chanegd the UK to check for the BUT_LABEL also
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_cfg_nav
      WHERE    responsibility_id = x_responsibility_id
      AND      form_code = x_form_code
      AND      (seq_number = x_seq_number OR but_label = x_but_label)
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));
    lv_rowid cur_rowid%RowType;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_uk_for_validation;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_responsibility_id,
      x_form_code,
      x_seq_number,
      x_subform_code,
      x_but_label,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.responsibility_id,
             new_references.form_code,
             new_references.subform_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.responsibility_id,
             new_references.form_code,
             new_references.subform_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;
  END before_dml;
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_responsibility_id                 => x_responsibility_id,
      x_form_code                         => x_form_code,
      x_seq_number                        => x_seq_number,
      x_subform_code                      => x_subform_code,
      x_but_label                         => x_but_label,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igs_ge_cfg_nav (
      responsibility_id,
      form_code,
      seq_number,
      subform_code,
      but_label,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.responsibility_id,
      new_references.form_code,
      new_references.seq_number,
      new_references.subform_code,
      new_references.but_label,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
  END insert_row;
  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        seq_number,
        subform_code,
        but_label
      FROM  igs_ge_cfg_nav
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF (
        (tlinfo.seq_number = x_seq_number)
        AND (tlinfo.subform_code = x_subform_code)
        AND (tlinfo.but_label = x_but_label)
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
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_responsibility_id                 => x_responsibility_id,
      x_form_code                         => x_form_code,
      x_seq_number                        => x_seq_number,
      x_subform_code                      => x_subform_code,
      x_but_label                         => x_but_label,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    UPDATE igs_ge_cfg_nav
      SET
        seq_number                        = new_references.seq_number,
        subform_code                      = new_references.subform_code,
        but_label                         = new_references.but_label,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;
  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_seq_number                        IN     NUMBER,
    x_subform_code                      IN     VARCHAR2,
    x_but_label                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ge_cfg_nav
      WHERE    responsibility_id                 = x_responsibility_id
      AND      form_code                         = x_form_code;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_responsibility_id,
        x_form_code,
        x_seq_number,
        x_subform_code,
        x_but_label,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_responsibility_id,
      x_form_code,
      x_seq_number,
      x_subform_code,
      x_but_label,
      x_mode
    );
  END add_row;
  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );
    DELETE FROM igs_ge_cfg_nav
    WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;
END igs_ge_cfg_nav_pkg;

/
