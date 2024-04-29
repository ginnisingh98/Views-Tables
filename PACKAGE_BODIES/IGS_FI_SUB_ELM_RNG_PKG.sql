--------------------------------------------------------
--  DDL for Package Body IGS_FI_SUB_ELM_RNG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_SUB_ELM_RNG_PKG" AS
/* $Header: IGSSIF1B.pls 120.0 2005/09/09 18:47:06 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_sub_elm_rng%ROWTYPE;
  new_references igs_fi_sub_elm_rng%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_er_id                         IN     NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
      FROM     igs_fi_sub_elm_rng
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
    new_references.sub_er_id                         := x_sub_er_id;
    new_references.er_id                             := x_er_id;
    new_references.sub_range_num                     := x_sub_range_num;
    new_references.sub_lower_range                   := x_sub_lower_range;
    new_references.sub_upper_range                   := x_sub_upper_range;
    new_references.sub_chg_method_code               := x_sub_chg_method_code;
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
           new_references.er_id,
           new_references.sub_range_num
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

    IF (((old_references.er_id = new_references.er_id)) OR
        ((new_references.er_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_el_rng_pkg.get_pk_For_validation (
                new_references.er_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sub_er_id                         IN     NUMBER
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
      FROM     igs_fi_sub_elm_rng
      WHERE    sub_er_id = x_sub_er_id
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
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER
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
      FROM     igs_fi_sub_elm_rng
      WHERE    er_id = x_er_id
      AND      sub_range_num = x_sub_range_num
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sub_er_id                         IN     NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
      x_sub_er_id,
      x_er_id,
      x_sub_range_num,
      x_sub_lower_range,
      x_sub_upper_range,
      x_sub_chg_method_code,
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
             new_references.sub_er_id
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
             new_references.sub_er_id
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
    x_sub_er_id                         IN OUT NOCOPY NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SUB_ELM_RNG_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_sub_er_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sub_er_id                         => x_sub_er_id,
      x_er_id                             => x_er_id,
      x_sub_range_num                     => x_sub_range_num,
      x_sub_lower_range                   => x_sub_lower_range,
      x_sub_upper_range                   => x_sub_upper_range,
      x_sub_chg_method_code               => x_sub_chg_method_code,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_sub_elm_rng (
      sub_er_id,
      er_id,
      sub_range_num,
      sub_lower_range,
      sub_upper_range,
      sub_chg_method_code,
      logical_delete_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_fi_sub_elm_rng_s.NEXTVAL,
      new_references.er_id,
      new_references.sub_range_num,
      new_references.sub_lower_range,
      new_references.sub_upper_range,
      new_references.sub_chg_method_code,
      new_references.logical_delete_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, sub_er_id INTO x_rowid, x_sub_er_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sub_er_id                         IN     NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
        er_id,
        sub_range_num,
        sub_lower_range,
        sub_upper_range,
        sub_chg_method_code,
        logical_delete_date
      FROM  igs_fi_sub_elm_rng
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
        (tlinfo.er_id = x_er_id)
        AND (tlinfo.sub_range_num = x_sub_range_num)
        AND ((tlinfo.sub_lower_range = x_sub_lower_range) OR ((tlinfo.sub_lower_range IS NULL) AND (X_sub_lower_range IS NULL)))
        AND ((tlinfo.sub_upper_range = x_sub_upper_range) OR ((tlinfo.sub_upper_range IS NULL) AND (X_sub_upper_range IS NULL)))
        AND ((tlinfo.sub_chg_method_code = x_sub_chg_method_code) OR ((tlinfo.sub_chg_method_code IS NULL) AND (X_sub_chg_method_code IS NULL)))
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
    x_sub_er_id                         IN     NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SUB_ELM_RNG_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sub_er_id                         => x_sub_er_id,
      x_er_id                             => x_er_id,
      x_sub_range_num                     => x_sub_range_num,
      x_sub_lower_range                   => x_sub_lower_range,
      x_sub_upper_range                   => x_sub_upper_range,
      x_sub_chg_method_code               => x_sub_chg_method_code,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_sub_elm_rng
      SET
        er_id                             = new_references.er_id,
        sub_range_num                     = new_references.sub_range_num,
        sub_lower_range                   = new_references.sub_lower_range,
        sub_upper_range                   = new_references.sub_upper_range,
        sub_chg_method_code               = new_references.sub_chg_method_code,
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
    x_sub_er_id                         IN OUT NOCOPY NUMBER,
    x_er_id                             IN     NUMBER,
    x_sub_range_num                     IN     NUMBER,
    x_sub_lower_range                   IN     NUMBER,
    x_sub_upper_range                   IN     NUMBER,
    x_sub_chg_method_code               IN     VARCHAR2,
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
      FROM     igs_fi_sub_elm_rng
      WHERE    sub_er_id                         = x_sub_er_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sub_er_id,
        x_er_id,
        x_sub_range_num,
        x_sub_lower_range,
        x_sub_upper_range,
        x_sub_chg_method_code,
        x_logical_delete_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sub_er_id,
      x_er_id,
      x_sub_range_num,
      x_sub_lower_range,
      x_sub_upper_range,
      x_sub_chg_method_code,
      x_logical_delete_date,
      x_mode
    );

  END add_row;

  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By : svuppala , Oracle IDC
  ||  Created On : 23-JUN-2005
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
   ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'SUB_RANGE_NUM') THEN
      new_references.SUB_RANGE_NUM := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'SUB_UPPER_RANGE') THEN
      new_references.SUB_UPPER_RANGE := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'SUB_CHG_METHOD_CODE') THEN
      new_references.sub_chg_method_code := column_value;
    ELSIF (UPPER (column_name) = 'SUB_LOWER_RANGE') THEN
      new_references.SUB_LOWER_RANGE := igs_ge_number.To_Num (column_value);
    END IF;

    IF ((UPPER (column_name) = 'SUB_RANGE_NUM') OR (column_name IS NULL)) THEN
      IF ((new_references.SUB_RANGE_NUM < 1) OR (new_references.SUB_RANGE_NUM > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SUB_UPPER_RANGE') OR (column_name IS NULL)) THEN
      IF ((new_references.SUB_UPPER_RANGE < 0) OR (new_references.SUB_UPPER_RANGE > 9999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SUB_CHG_METHOD_CODE') OR (column_name IS NULL)) THEN
      IF (new_references.sub_chg_method_code NOT IN ('FLATRATE')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'SUB_LOWER_RANGE') OR (column_name IS NULL)) THEN
      IF ((new_references.SUB_LOWER_RANGE < 0) OR (new_references.SUB_LOWER_RANGE > 9999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;

END igs_fi_sub_elm_rng_pkg;

/
