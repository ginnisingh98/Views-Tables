--------------------------------------------------------
--  DDL for Package Body IGS_UC_CYC_DEFAULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_CYC_DEFAULTS_PKG" AS
/* $Header: IGSXI53B.pls 120.0 2005/06/02 03:52:36 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_cyc_defaults%ROWTYPE;
  new_references igs_uc_cyc_defaults%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_cyc_defaults
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
    new_references.system_code                       := x_system_code;
    new_references.ucas_cycle                        := x_ucas_cycle;
    new_references.ucas_interface                    := x_ucas_interface;
    new_references.marvin_seq                        := x_marvin_seq;
    new_references.clearing_flag                     := x_clearing_flag;
    new_references.extra_flag                        := x_extra_flag;
    new_references.cvname_flag                       := x_cvname_flag;

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
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_cyc_defaults
      WHERE    system_code = x_system_code
      AND      ucas_cycle = x_ucas_cycle
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
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_system_code,
      x_ucas_cycle,
      x_ucas_interface,
      x_marvin_seq,
      x_clearing_flag,
      x_extra_flag,
      x_cvname_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.system_code,
             new_references.ucas_cycle
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.system_code,
             new_references.ucas_cycle
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
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_CYC_DEFAULTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_system_code                       => x_system_code,
      x_ucas_cycle                        => x_ucas_cycle,
      x_ucas_interface                    => x_ucas_interface,
      x_marvin_seq                        => x_marvin_seq,
      x_clearing_flag                     => x_clearing_flag,
      x_extra_flag                        => x_extra_flag,
      x_cvname_flag                       => x_cvname_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_cyc_defaults (
      system_code,
      ucas_cycle,
      ucas_interface,
      marvin_seq,
      clearing_flag,
      extra_flag,
      cvname_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.system_code,
      new_references.ucas_cycle,
      new_references.ucas_interface,
      new_references.marvin_seq,
      new_references.clearing_flag,
      new_references.extra_flag,
      new_references.cvname_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */
    CURSOR c1 IS
      SELECT
        ucas_interface,
        marvin_seq,
        clearing_flag,
        extra_flag,
        cvname_flag
      FROM  igs_uc_cyc_defaults
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

    IF ((tlinfo.ucas_interface = x_ucas_interface)
        AND ((tlinfo.marvin_seq = x_marvin_seq) OR ((tlinfo.marvin_seq IS NULL) AND (X_marvin_seq IS NULL)))
        AND (tlinfo.clearing_flag = x_clearing_flag)
        AND (tlinfo.extra_flag = x_extra_flag)
        AND (tlinfo.cvname_flag = x_cvname_flag)
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
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_CYC_DEFAULTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_system_code                       => x_system_code,
      x_ucas_cycle                        => x_ucas_cycle,
      x_ucas_interface                    => x_ucas_interface,
      x_marvin_seq                        => x_marvin_seq,
      x_clearing_flag                     => x_clearing_flag,
      x_extra_flag                        => x_extra_flag,
      x_cvname_flag                       => x_cvname_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_cyc_defaults
      SET
        ucas_interface                    = new_references.ucas_interface,
        marvin_seq                        = new_references.marvin_seq,
        clearing_flag                     = new_references.clearing_flag,
        extra_flag                        = new_references.extra_flag,
        cvname_flag                       = new_references.cvname_flag,
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
    x_system_code                       IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_ucas_interface                    IN     VARCHAR2,
    x_marvin_seq                        IN     NUMBER,
    x_clearing_flag                     IN     VARCHAR2,
    x_extra_flag                        IN     VARCHAR2,
    x_cvname_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_cyc_defaults
      WHERE    system_code                       = x_system_code
      AND      ucas_cycle                        = x_ucas_cycle;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_system_code,
        x_ucas_cycle,
        x_ucas_interface,
        x_marvin_seq,
        x_clearing_flag,
        x_extra_flag,
        x_cvname_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_system_code,
      x_ucas_cycle,
      x_ucas_interface,
      x_marvin_seq,
      x_clearing_flag,
      x_extra_flag,
      x_cvname_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 28-JUL-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  dsridhar        24-JUL-2003     Changed for CR in UCAS Application Calendar Mapping.
  ||                                  Bug# 3022067. Removed columns referring to calendars.
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_uc_cyc_defaults
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_cyc_defaults_pkg;

/