--------------------------------------------------------
--  DDL for Package Body IGS_UC_JNT_ADM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_JNT_ADM_INST_PKG" AS
/* $Header: IGSXI40B.pls 115.3 2003/02/28 07:51:23 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_jnt_adm_inst%ROWTYPE;
  new_references igs_uc_jnt_adm_inst%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_jnt_adm_inst
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
    new_references.child_inst                        := x_child_inst;
    new_references.parent_inst1                      := x_parent_inst1;
    new_references.parent_inst2                      := x_parent_inst2;
    new_references.parent_inst3                      := x_parent_inst3;
    new_references.parent_inst4                      := x_parent_inst4;
    new_references.parent_inst5                      := x_parent_inst5;

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


  FUNCTION get_pk_for_validation (
    x_child_inst                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_jnt_adm_inst
      WHERE    child_inst = x_child_inst ;

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
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_child_inst,
      x_parent_inst1,
      x_parent_inst2,
      x_parent_inst3,
      x_parent_inst4,
      x_parent_inst5,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.child_inst
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.child_inst
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
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_child_inst                        => x_child_inst,
      x_parent_inst1                      => x_parent_inst1,
      x_parent_inst2                      => x_parent_inst2,
      x_parent_inst3                      => x_parent_inst3,
      x_parent_inst4                      => x_parent_inst4,
      x_parent_inst5                      => x_parent_inst5,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_jnt_adm_inst (
      child_inst,
      parent_inst1,
      parent_inst2,
      parent_inst3,
      parent_inst4,
      parent_inst5,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.child_inst,
      new_references.parent_inst1,
      new_references.parent_inst2,
      new_references.parent_inst3,
      new_references.parent_inst4,
      new_references.parent_inst5,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        parent_inst1,
        parent_inst2,
        parent_inst3,
        parent_inst4,
        parent_inst5
      FROM  igs_uc_jnt_adm_inst
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
        (tlinfo.parent_inst1 = x_parent_inst1)
        AND ((tlinfo.parent_inst2 = x_parent_inst2) OR ((tlinfo.parent_inst2 IS NULL) AND (X_parent_inst2 IS NULL)))
        AND ((tlinfo.parent_inst3 = x_parent_inst3) OR ((tlinfo.parent_inst3 IS NULL) AND (X_parent_inst3 IS NULL)))
        AND ((tlinfo.parent_inst4 = x_parent_inst4) OR ((tlinfo.parent_inst4 IS NULL) AND (X_parent_inst4 IS NULL)))
        AND ((tlinfo.parent_inst5 = x_parent_inst5) OR ((tlinfo.parent_inst5 IS NULL) AND (X_parent_inst5 IS NULL)))
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
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_child_inst                        => x_child_inst,
      x_parent_inst1                      => x_parent_inst1,
      x_parent_inst2                      => x_parent_inst2,
      x_parent_inst3                      => x_parent_inst3,
      x_parent_inst4                      => x_parent_inst4,
      x_parent_inst5                      => x_parent_inst5,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_jnt_adm_inst
      SET
        parent_inst1                      = new_references.parent_inst1,
        parent_inst2                      = new_references.parent_inst2,
        parent_inst3                      = new_references.parent_inst3,
        parent_inst4                      = new_references.parent_inst4,
        parent_inst5                      = new_references.parent_inst5,
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
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_jnt_adm_inst
      WHERE    child_inst                        = x_child_inst;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_child_inst,
        x_parent_inst1,
        x_parent_inst2,
        x_parent_inst3,
        x_parent_inst4,
        x_parent_inst5,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_child_inst,
      x_parent_inst1,
      x_parent_inst2,
      x_parent_inst3,
      x_parent_inst4,
      x_parent_inst5,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nishikanta.Behera@oracle.com
  ||  Created On : 17-SEP-2002
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

    DELETE FROM igs_uc_jnt_adm_inst
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_jnt_adm_inst_pkg;

/
