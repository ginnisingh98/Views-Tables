--------------------------------------------------------
--  DDL for Package Body IGS_FI_SUB_ER_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_SUB_ER_RT_PKG" AS
/* $Header: IGSSIF2B.pls 120.0 2005/09/09 20:08:31 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_sub_er_rt%ROWTYPE;
  new_references igs_fi_sub_er_rt%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_sub_er_rt
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
    new_references.sub_err_id                        := x_sub_err_id;
    new_references.sub_er_id                         := x_sub_er_id;
    new_references.far_id                            := x_far_id;
    new_references.create_date                       := x_create_date;
    new_references.logical_delete_date               := x_logical_delete_date;

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
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.sub_er_id,
           new_references.far_id,
           new_references.create_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.sub_er_id = new_references.sub_er_id)) OR
        ((new_references.sub_er_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_sub_elm_rng_pkg.get_pk_for_validation (
                new_references.sub_er_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.far_id = new_references.far_id)) OR
        ((new_references.far_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_fee_as_rate_pkg.get_pk_For_validation (
                new_references.far_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sub_err_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_sub_er_rt
      WHERE    sub_err_id = x_sub_err_id
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
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_sub_er_rt
      WHERE    sub_er_id = x_sub_er_id
      AND      far_id = x_far_id
      AND      create_date = x_create_date
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

  PROCEDURE get_fk_igs_fi_fee_as_rate (
    x_far_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_sub_er_rt
      WHERE   ((far_id = x_far_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FSERT_FAR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_fee_as_rate;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
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
      x_sub_err_id,
      x_sub_er_id,
      x_far_id,
      x_create_date,
      x_logical_delete_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sub_err_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.sub_err_id
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
    x_sub_err_id                        IN OUT NOCOPY NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SUB_ER_RT_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_sub_err_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sub_err_id                        => x_sub_err_id,
      x_sub_er_id                         => x_sub_er_id,
      x_far_id                            => x_far_id,
      x_create_date                       => x_create_date,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_sub_er_rt (
      sub_err_id,
      sub_er_id,
      far_id,
      create_date,
      logical_delete_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_fi_sub_er_rt_s.NEXTVAL,
      new_references.sub_er_id,
      new_references.far_id,
      new_references.create_date,
      new_references.logical_delete_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, sub_err_id INTO x_rowid, x_sub_err_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        sub_er_id,
        far_id,
        create_date,
        logical_delete_date
      FROM  igs_fi_sub_er_rt
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
        (tlinfo.sub_er_id = x_sub_er_id)
        AND (tlinfo.far_id = x_far_id)
        AND (tlinfo.create_date = x_create_date)
        AND ((tlinfo.logical_delete_date = x_logical_delete_date) OR ((tlinfo.logical_delete_date IS NULL) AND (X_logical_delete_date IS NULL)))
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
    x_sub_err_id                        IN     NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SUB_ER_RT_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sub_err_id                        => x_sub_err_id,
      x_sub_er_id                         => x_sub_er_id,
      x_far_id                            => x_far_id,
      x_create_date                       => x_create_date,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_sub_er_rt
      SET
        sub_er_id                         = new_references.sub_er_id,
        far_id                            = new_references.far_id,
        create_date                       = new_references.create_date,
        logical_delete_date               = new_references.logical_delete_date,
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
    x_sub_err_id                        IN OUT NOCOPY NUMBER,
    x_sub_er_id                         IN     NUMBER,
    x_far_id                            IN     NUMBER,
    x_create_date                       IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sunil.vuppala@oracle.com
  ||  Created On : 25-JUN-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_sub_er_rt
      WHERE    sub_err_id                        = x_sub_err_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sub_err_id,
        x_sub_er_id,
        x_far_id,
        x_create_date,
        x_logical_delete_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sub_err_id,
      x_sub_er_id,
      x_far_id,
      x_create_date,
      x_logical_delete_date,
      x_mode
    );

  END add_row;

END igs_fi_sub_er_rt_pkg;

/
