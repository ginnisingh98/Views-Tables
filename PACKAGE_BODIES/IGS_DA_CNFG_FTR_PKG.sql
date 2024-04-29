--------------------------------------------------------
--  DDL for Package Body IGS_DA_CNFG_FTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_CNFG_FTR_PKG" AS
/* $Header: IGSKI44B.pls 115.0 2003/04/15 09:21:21 ddey noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_cnfg_ftr%ROWTYPE;
  new_references igs_da_cnfg_ftr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_da_cnfg_ftr
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
    new_references.request_type_id                   := x_request_type_id;
    new_references.feature_code                      := x_feature_code;
    new_references.configure_flag                    := x_configure_flag;
    new_references.display_flag                      := x_display_flag;
    new_references.feature_value                     := x_feature_value;
    new_references.force_value_flag                  := x_force_value_flag;
    new_references.default_value_flag                := x_default_value_flag;

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
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.request_type_id = new_references.request_type_id)) OR
        ((new_references.request_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_da_cnfg_req_typ_pkg.get_pk_for_validation (
                new_references.request_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.feature_code = new_references.feature_code)) OR
        ((new_references.feature_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_da_ftr_val_map_pkg.get_pk_for_validation (
                new_references.feature_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_ftr
      WHERE    request_type_id = x_request_type_id
      AND      feature_code = x_feature_code
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


  PROCEDURE get_fk_igs_da_cnfg_req_typ (
    x_request_type_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_ftr
      WHERE   ((request_type_id = x_request_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_CNFG_REQTY');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_da_cnfg_req_typ;


  PROCEDURE get_fk_igs_da_ftr_val_map (
    x_feature_code                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_cnfg_ftr
      WHERE   ((feature_code = x_feature_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_CNFG_VAL_MAP');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_da_ftr_val_map;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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
      x_request_type_id,
      x_feature_code,
      x_configure_flag,
      x_display_flag,
      x_feature_value,
      x_force_value_flag,
      x_default_value_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.request_type_id,
             new_references.feature_code
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
             new_references.request_type_id,
             new_references.feature_code
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
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_CNFG_FTR_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_request_type_id                   => x_request_type_id,
      x_feature_code                      => x_feature_code,
      x_configure_flag                    => x_configure_flag,
      x_display_flag                      => x_display_flag,
      x_feature_value                     => x_feature_value,
      x_force_value_flag                  => x_force_value_flag,
      x_default_value_flag                => x_default_value_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_da_cnfg_ftr (
      request_type_id,
      feature_code,
      configure_flag,
      display_flag,
      feature_value,
      force_value_flag,
      default_value_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.request_type_id,
      new_references.feature_code,
      new_references.configure_flag,
      new_references.display_flag,
      new_references.feature_value,
      new_references.force_value_flag,
      new_references.default_value_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        configure_flag,
        display_flag,
        feature_value,
        force_value_flag,
        default_value_flag
      FROM  igs_da_cnfg_ftr
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
        ((tlinfo.configure_flag = x_configure_flag) OR ((tlinfo.configure_flag IS NULL) AND (X_configure_flag IS NULL)))
        AND (tlinfo.display_flag = x_display_flag)
        AND ((tlinfo.feature_value = x_feature_value) OR ((tlinfo.feature_value IS NULL) AND (X_feature_value IS NULL)))
        AND (tlinfo.force_value_flag = x_force_value_flag)
        AND ((tlinfo.default_value_flag = x_default_value_flag) OR ((tlinfo.default_value_flag IS NULL) AND (X_default_value_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED3');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_CNFG_FTR_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_request_type_id                   => x_request_type_id,
      x_feature_code                      => x_feature_code,
      x_configure_flag                    => x_configure_flag,
      x_display_flag                      => x_display_flag,
      x_feature_value                     => x_feature_value,
      x_force_value_flag                  => x_force_value_flag,
      x_default_value_flag                => x_default_value_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_da_cnfg_ftr
      SET
        configure_flag                    = new_references.configure_flag,
        display_flag                      = new_references.display_flag,
        feature_value                     = new_references.feature_value,
        force_value_flag                  = new_references.force_value_flag,
        default_value_flag                = new_references.default_value_flag,
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
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_da_cnfg_ftr
      WHERE    request_type_id                   = x_request_type_id
      AND      feature_code                      = x_feature_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_request_type_id,
        x_feature_code,
        x_configure_flag,
        x_display_flag,
        x_feature_value,
        x_force_value_flag,
        x_default_value_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_request_type_id,
      x_feature_code,
      x_configure_flag,
      x_display_flag,
      x_feature_value,
      x_force_value_flag,
      x_default_value_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
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

    DELETE FROM igs_da_cnfg_ftr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_da_cnfg_ftr_pkg;

/
