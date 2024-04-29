--------------------------------------------------------
--  DDL for Package Body IGS_HE_UCAS_IMP_ERR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_UCAS_IMP_ERR_PKG" AS
/* $Header: IGSWI32B.pls 115.3 2003/03/05 08:47:15 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ucas_imp_err%ROWTYPE;
  new_references igs_he_ucas_imp_err%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_ucas_imp_err
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
    new_references.error_interface_id                := x_error_interface_id;
    new_references.interface_hesa_id                 := x_interface_hesa_id;
    new_references.batch_id                          := x_batch_id;
    new_references.error_code                        := x_error_code;
    new_references.error_text                        := x_error_text;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR check_parent IS
    SELECT rowid
    FROM igs_he_ucas_imp_int
    WHERE batch_id = new_references.batch_id AND
          interface_hesa_id =  new_references.interface_hesa_id ;
    lv_rowid check_parent%ROWTYPE;

  BEGIN

    IF (((old_references.interface_hesa_id = new_references.interface_hesa_id) AND
         (old_references.batch_id = new_references.batch_id)) OR
        ((new_references.interface_hesa_id IS NULL) OR
         (new_references.batch_id IS NULL))) THEN
      NULL;
    ELSE
	OPEN check_parent;
	FETCH check_parent INTO lv_rowid;
	IF (check_parent%NOTFOUND) THEN
		CLOSE check_parent;
		fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
		igs_ge_msg_stack.add;
		app_exception.raise_exception;
	ELSE
		CLOSE check_parent;
	END IF;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_error_interface_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ucas_imp_err
      WHERE    error_interface_id = x_error_interface_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
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
      x_error_interface_id,
      x_interface_hesa_id,
      x_batch_id,
      x_error_code,
      x_error_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.error_interface_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.error_interface_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_error_interface_id                IN OUT NOCOPY NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR  c_imp_err IS
    SELECT  igs_he_ucas_imp_err_s.NEXTVAL
    FROM    dual;

    x_last_update_date          DATE;
    x_last_updated_by           NUMBER;
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

     OPEN   c_imp_err;
     FETCH  c_imp_err INTO  x_error_interface_id;
     CLOSE  c_imp_err;



    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_error_interface_id                => x_error_interface_id,
      x_interface_hesa_id                 => x_interface_hesa_id,
      x_batch_id                          => x_batch_id,
      x_error_code                        => x_error_code,
      x_error_text                        => x_error_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_ucas_imp_err (
      error_interface_id,
      interface_hesa_id,
      batch_id,
      error_code,
      error_text,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.error_interface_id,
      new_references.interface_hesa_id,
      new_references.batch_id,
      new_references.error_code,
      new_references.error_text,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, error_interface_id INTO x_rowid, x_error_interface_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        interface_hesa_id,
        batch_id,
        error_code,
        error_text
      FROM  igs_he_ucas_imp_err
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
        (tlinfo.interface_hesa_id = x_interface_hesa_id)
        AND (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.error_code = x_error_code)
        AND ((tlinfo.error_text = x_error_text) OR ((tlinfo.error_text IS NULL) AND (X_error_text IS NULL)))
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
    x_error_interface_id                IN     NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
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
      x_error_interface_id                => x_error_interface_id,
      x_interface_hesa_id                 => x_interface_hesa_id,
      x_batch_id                          => x_batch_id,
      x_error_code                        => x_error_code,
      x_error_text                        => x_error_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_ucas_imp_err
      SET
        interface_hesa_id                 = new_references.interface_hesa_id,
        batch_id                          = new_references.batch_id,
        error_code                        = new_references.error_code,
        error_text                        = new_references.error_text,
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
    x_error_interface_id                IN OUT NOCOPY NUMBER,
    x_interface_hesa_id                 IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_error_code                        IN     VARCHAR2,
    x_error_text                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ucas_imp_err
      WHERE    error_interface_id                = x_error_interface_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_error_interface_id,
        x_interface_hesa_id,
        x_batch_id,
        x_error_code,
        x_error_text,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_error_interface_id,
      x_interface_hesa_id,
      x_batch_id,
      x_error_code,
      x_error_text,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 05-NOV-2002
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

    DELETE FROM igs_he_ucas_imp_err
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_ucas_imp_err_pkg;

/
