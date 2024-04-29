--------------------------------------------------------
--  DDL for Package Body IGS_DA_FTR_VAL_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_FTR_VAL_MAP_PKG" AS
/* $Header: IGSKI48B.pls 115.0 2003/04/15 09:23:48 ddey noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_ftr_val_map%ROWTYPE;
  new_references igs_da_ftr_val_map%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
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
      FROM     igs_da_ftr_val_map
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
    new_references.feature_code                      := x_feature_code;
    new_references.feature_val_type                  := x_feature_val_type;
    new_references.configure_checked                 := x_configure_checked;
    new_references.third_party_ftr_code              := x_third_party_ftr_code;
    new_references.allow_disp_chk_flag               := x_allow_disp_chk_flag;
    new_references.single_allowed                    := x_single_allowed;
    new_references.batch_allowed                     := x_batch_allowed;
    new_references.transfer_evaluation_ind           := x_transfer_evaluation_ind;

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


  PROCEDURE check_child_existance AS
  /*
  ||  Created By :
  ||  Created On : 19-MAR-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_da_cnfg_ftr_pkg.get_fk_igs_da_ftr_val_map (
      old_references.feature_code
    );

   igs_da_req_ftrs_pkg.get_fk_igs_da_ftr_val_map (
     x_feature_code   =>  old_references.feature_code);

  END check_child_existance;


  FUNCTION get_pk_for_validation (
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
      FROM     igs_da_ftr_val_map
      WHERE    feature_code = x_feature_code
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
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
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
      x_feature_code,
      x_feature_val_type,
      x_configure_checked,
      x_third_party_ftr_code,
      x_allow_disp_chk_flag,
      x_single_allowed,
      x_batch_allowed,
      x_transfer_evaluation_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.feature_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.feature_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_feature_code                      IN OUT NOCOPY VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_FTR_VAL_MAP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--    x_feature_code := NULL;  -- Commented by Deep

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_feature_code                      => x_feature_code,
      x_feature_val_type                  => x_feature_val_type,
      x_configure_checked                 => x_configure_checked,
      x_third_party_ftr_code              => x_third_party_ftr_code,
      x_allow_disp_chk_flag               => x_allow_disp_chk_flag,
      x_single_allowed                    => x_single_allowed,
      x_batch_allowed                     => x_batch_allowed,
      x_transfer_evaluation_ind           => x_transfer_evaluation_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_da_ftr_val_map (
      feature_code,
      feature_val_type,
      configure_checked,
      third_party_ftr_code,
      allow_disp_chk_flag,
      single_allowed,
      batch_allowed,
      transfer_evaluation_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.feature_code,  -- There was sequence here
      new_references.feature_val_type,
      new_references.configure_checked,
      new_references.third_party_ftr_code,
      new_references.allow_disp_chk_flag,
      new_references.single_allowed,
      new_references.batch_allowed,
      new_references.transfer_evaluation_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, feature_code INTO x_rowid, x_feature_code;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2
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
        feature_val_type,
        configure_checked,
        third_party_ftr_code,
        allow_disp_chk_flag,
        single_allowed,
        batch_allowed,
        transfer_evaluation_ind
      FROM  igs_da_ftr_val_map
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED1');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.feature_val_type = x_feature_val_type)
        AND (tlinfo.configure_checked = x_configure_checked)
        AND (tlinfo.third_party_ftr_code = x_third_party_ftr_code)
        AND (tlinfo.allow_disp_chk_flag = x_allow_disp_chk_flag)
        AND (tlinfo.single_allowed = x_single_allowed)
        AND (tlinfo.batch_allowed = x_batch_allowed)
        AND (tlinfo.transfer_evaluation_ind = x_transfer_evaluation_ind)
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_FTR_VAL_MAP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--    x_feature_code := NULL;  -- Commented by Deep

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_feature_code                      => x_feature_code,
      x_feature_val_type                  => x_feature_val_type,
      x_configure_checked                 => x_configure_checked,
      x_third_party_ftr_code              => x_third_party_ftr_code,
      x_allow_disp_chk_flag               => x_allow_disp_chk_flag,
      x_single_allowed                    => x_single_allowed,
      x_batch_allowed                     => x_batch_allowed,
      x_transfer_evaluation_ind           => x_transfer_evaluation_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_da_ftr_val_map
      SET
        feature_val_type                  = new_references.feature_val_type,
        configure_checked                 = new_references.configure_checked,
        third_party_ftr_code              = new_references.third_party_ftr_code,
        allow_disp_chk_flag               = new_references.allow_disp_chk_flag,
        single_allowed                    = new_references.single_allowed,
        batch_allowed                     = new_references.batch_allowed,
        transfer_evaluation_ind           = new_references.transfer_evaluation_ind,
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
    x_feature_code                      IN OUT NOCOPY VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
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
      FROM     igs_da_ftr_val_map
      WHERE    feature_code                      = x_feature_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_feature_code,
        x_feature_val_type,
        x_configure_checked,
        x_third_party_ftr_code,
        x_allow_disp_chk_flag,
        x_single_allowed,
        x_batch_allowed,
        x_transfer_evaluation_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_feature_code,
      x_feature_val_type,
      x_configure_checked,
      x_third_party_ftr_code,
      x_allow_disp_chk_flag,
      x_single_allowed,
      x_batch_allowed,
      x_transfer_evaluation_ind,
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

    DELETE FROM igs_da_ftr_val_map
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_da_ftr_val_map_pkg;

/
