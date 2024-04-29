--------------------------------------------------------
--  DDL for Package Body IGS_HE_EX_RN_DAT_FD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EX_RN_DAT_FD_PKG" AS
/* $Header: IGSWI08B.pls 115.7 2002/12/20 08:47:56 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ex_rn_dat_fd%ROWTYPE;
  new_references igs_he_ex_rn_dat_fd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_rn_dat_fd_id                      IN     NUMBER       ,
    x_extract_run_id                    IN     NUMBER       ,
    x_line_number                       IN     NUMBER       ,
    x_field_number                      IN     NUMBER       ,
    x_value                             IN     VARCHAR2     ,
    x_override_value                    IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_EX_RN_DAT_FD
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
    new_references.rn_dat_fd_id                      := x_rn_dat_fd_id;
    new_references.extract_run_id                    := x_extract_run_id;
    new_references.line_number                       := x_line_number;
    new_references.field_number                      := x_field_number;
    new_references.value                             := x_value;
    new_references.override_value                    := x_override_value;

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
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.extract_run_id = new_references.extract_run_id) AND
         (old_references.line_number = new_references.line_number)) OR
        ((new_references.extract_run_id IS NULL) OR
         (new_references.line_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_ex_rn_dat_ln_pkg.get_pk_for_validation (
                new_references.extract_run_id,
                new_references.line_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ex_rn_dat_fd
      WHERE    extract_run_id = x_extract_run_id
      AND      line_number = x_line_number
      AND      field_number = x_field_number
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


  PROCEDURE get_fk_igs_he_ex_rn_dat_ln (
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ex_rn_dat_fd
      WHERE   ((extract_run_id = x_extract_run_id) AND
               (line_number = x_line_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HEERDAFD_HEERDALN_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_ex_rn_dat_ln;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_rn_dat_fd_id                      IN     NUMBER       ,
    x_extract_run_id                    IN     NUMBER       ,
    x_line_number                       IN     NUMBER       ,
    x_field_number                      IN     NUMBER       ,
    x_value                             IN     VARCHAR2     ,
    x_override_value                    IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_rn_dat_fd_id,
      x_extract_run_id,
      x_line_number,
      x_field_number,
      x_value,
      x_override_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.extract_run_id,
             new_references.line_number,
             new_references.field_number
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
             new_references.extract_run_id,
             new_references.line_number,
             new_references.field_number
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
    x_rn_dat_fd_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_ex_rn_dat_fd
      WHERE    extract_run_id                    = x_extract_run_id
      AND      line_number                       = x_line_number
      AND      field_number                      = x_field_number;

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

    select IGS_HE_EX_RN_DAT_FD_S.NEXTVAL INTO x_rn_dat_fd_id from dual ;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rn_dat_fd_id                      => x_rn_dat_fd_id,
      x_extract_run_id                    => x_extract_run_id,
      x_line_number                       => x_line_number,
      x_field_number                      => x_field_number,
      x_value                             => x_value,
      x_override_value                    => x_override_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_ex_rn_dat_fd (
      rn_dat_fd_id,
      extract_run_id,
      line_number,
      field_number,
      value,
      override_value,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.rn_dat_fd_id,
      new_references.extract_run_id,
      new_references.line_number,
      new_references.field_number,
      new_references.value,
      new_references.override_value,
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
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rn_dat_fd_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        rn_dat_fd_id,
        value,
        override_value
      FROM  igs_he_ex_rn_dat_fd
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
        (tlinfo.rn_dat_fd_id = x_rn_dat_fd_id)
        AND ((tlinfo.value = x_value) OR ((tlinfo.value IS NULL) AND (X_value IS NULL)))
        AND ((tlinfo.override_value = x_override_value) OR ((tlinfo.override_value IS NULL) AND (X_override_value IS NULL)))
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
    x_rn_dat_fd_id                      IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_rn_dat_fd_id                      => x_rn_dat_fd_id,
      x_extract_run_id                    => x_extract_run_id,
      x_line_number                       => x_line_number,
      x_field_number                      => x_field_number,
      x_value                             => x_value,
      x_override_value                    => x_override_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_ex_rn_dat_fd
      SET
        rn_dat_fd_id                      = new_references.rn_dat_fd_id,
        value                             = new_references.value,
        override_value                    = new_references.override_value,
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
    x_rn_dat_fd_id                      IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_override_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ex_rn_dat_fd
      WHERE    extract_run_id                    = x_extract_run_id
      AND      line_number                       = x_line_number
      AND      field_number                      = x_field_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rn_dat_fd_id,
        x_extract_run_id,
        x_line_number,
        x_field_number,
        x_value,
        x_override_value,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rn_dat_fd_id,
      x_extract_run_id,
      x_line_number,
      x_field_number,
      x_value,
      x_override_value,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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

    DELETE FROM igs_he_ex_rn_dat_fd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_ex_rn_dat_fd_pkg;

/
