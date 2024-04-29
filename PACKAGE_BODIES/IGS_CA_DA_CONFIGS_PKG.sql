--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_CONFIGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_CONFIGS_PKG" AS
/* $Header: IGSCI18B.pls 120.1 2005/08/11 05:47:10 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ca_da_configs%ROWTYPE;
  new_references igs_ca_da_configs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ca_da_configs
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
    new_references.sys_date_type                     := x_sys_date_type;
    new_references.description                       := x_description;
    new_references.owner_module_code                 := x_owner_module_code;
    new_references.validation_proc                   := x_validation_proc;
    new_references.one_per_cal_flag                  := x_one_per_cal_flag;
    new_references.res_cal_cat1                      := x_res_cal_cat1;
    new_references.res_cal_cat2                      := x_res_cal_cat2;
    new_references.date_alias                        := x_date_alias;

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
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_ca_da_ovd_vals_pkg.get_fk_igs_ca_da_configs (
      old_references.sys_date_type
    );

    igs_ca_da_ovd_rules_pkg.get_fk_igs_ca_da_configs (
      old_references.sys_date_type
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_sys_date_type                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ca_da_configs
      WHERE    sys_date_type = x_sys_date_type
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
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
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
      x_sys_date_type,
      x_description,
      x_owner_module_code,
      x_validation_proc,
      x_one_per_cal_flag,
      x_res_cal_cat1,
      x_res_cal_cat2,
      x_date_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sys_date_type
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
             new_references.sys_date_type
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
    x_sys_date_type                     IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_CA_DA_CONFIGS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sys_date_type                     => x_sys_date_type,
      x_description                       => x_description,
      x_owner_module_code                 => x_owner_module_code,
      x_validation_proc                   => x_validation_proc,
      x_one_per_cal_flag                  => x_one_per_cal_flag,
      x_res_cal_cat1                      => x_res_cal_cat1,
      x_res_cal_cat2                      => x_res_cal_cat2,
      x_date_alias                        => x_date_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ca_da_configs (
      sys_date_type,
      description,
      owner_module_code,
      validation_proc,
      one_per_cal_flag,
      res_cal_cat1,
      res_cal_cat2,
      date_alias,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sys_date_type,
      new_references.description,
      new_references.owner_module_code,
      new_references.validation_proc,
      new_references.one_per_cal_flag,
      new_references.res_cal_cat1,
      new_references.res_cal_cat2,
      new_references.date_alias,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, sys_date_type INTO x_rowid, x_sys_date_type;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        description,
        owner_module_code,
        validation_proc,
        one_per_cal_flag,
        res_cal_cat1,
        res_cal_cat2,
        date_alias
      FROM  igs_ca_da_configs
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
        (tlinfo.description = x_description)
        AND (tlinfo.owner_module_code = x_owner_module_code)
        AND ((tlinfo.validation_proc = x_validation_proc) OR ((tlinfo.validation_proc IS NULL) AND (X_validation_proc IS NULL)))
        AND (tlinfo.one_per_cal_flag = x_one_per_cal_flag)
        AND (tlinfo.res_cal_cat1 = x_res_cal_cat1)
        AND ((tlinfo.res_cal_cat2 = x_res_cal_cat2) OR ((tlinfo.res_cal_cat2 IS NULL) AND (X_res_cal_cat2 IS NULL)))
        AND ((tlinfo.date_alias = x_date_alias) OR ((tlinfo.date_alias IS NULL) AND (x_date_alias IS NULL)))
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
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_CA_DA_CONFIGS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sys_date_type                     => x_sys_date_type,
      x_description                       => x_description,
      x_owner_module_code                 => x_owner_module_code,
      x_validation_proc                   => x_validation_proc,
      x_one_per_cal_flag                  => x_one_per_cal_flag,
      x_res_cal_cat1                      => x_res_cal_cat1,
      x_res_cal_cat2                      => x_res_cal_cat2,
      x_date_alias                        => x_date_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ca_da_configs
      SET
        description                       = new_references.description,
        owner_module_code                 = new_references.owner_module_code,
        validation_proc                   = new_references.validation_proc,
        one_per_cal_flag                  = new_references.one_per_cal_flag,
        res_cal_cat1                      = new_references.res_cal_cat1,
        res_cal_cat2                      = new_references.res_cal_cat2,
        date_alias                        = new_references.date_alias,
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
    x_sys_date_type                     IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : nsidana@oracle.com
  ||  Created On : 05-OCT-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ca_da_configs
      WHERE    sys_date_type                     = x_sys_date_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sys_date_type,
        x_description,
        x_owner_module_code,
        x_validation_proc,
        x_one_per_cal_flag,
        x_res_cal_cat1,
        x_res_cal_cat2,
        x_date_alias,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sys_date_type,
      x_description,
      x_owner_module_code,
      x_validation_proc,
      x_one_per_cal_flag,
      x_res_cal_cat1,
      x_res_cal_cat2,
      x_date_alias,
      x_mode
    );

  END add_row;


END igs_ca_da_configs_pkg;

/
