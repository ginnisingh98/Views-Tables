--------------------------------------------------------
--  DDL for Package Body IGS_UC_SYS_CALNDRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_SYS_CALNDRS_PKG" AS
/* $Header: IGSXI54B.pls 120.0 2005/06/01 13:36:51 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_sys_calndrs%ROWTYPE;
  new_references igs_uc_sys_calndrs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_sys_calndrs
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
    new_references.entry_year                        := x_entry_year;
    new_references.entry_month                       := x_entry_month;
    new_references.aca_cal_type                      := x_aca_cal_type;
    new_references.aca_cal_seq_no                    := x_aca_cal_seq_no;
    new_references.adm_cal_type                      := x_adm_cal_type;
    new_references.adm_cal_seq_no                    := x_adm_cal_seq_no;

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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_sys_calndrs
      WHERE    system_code = x_system_code
      AND      entry_year = x_entry_year
      AND      entry_month = x_entry_month
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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
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
      x_system_code,
      x_entry_year,
      x_entry_month,
      x_aca_cal_type,
      x_aca_cal_seq_no,
      x_adm_cal_type,
      x_adm_cal_seq_no,
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
             new_references.entry_year,
             new_references.entry_month
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
             new_references.entry_year,
             new_references.entry_month
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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_SYS_CALNDRS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_system_code                       => x_system_code,
      x_entry_year                        => x_entry_year,
      x_entry_month                       => x_entry_month,
      x_aca_cal_type                      => x_aca_cal_type,
      x_aca_cal_seq_no                    => x_aca_cal_seq_no,
      x_adm_cal_type                      => x_adm_cal_type,
      x_adm_cal_seq_no                    => x_adm_cal_seq_no,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_sys_calndrs (
      system_code,
      entry_year,
      entry_month,
      aca_cal_type,
      aca_cal_seq_no,
      adm_cal_type,
      adm_cal_seq_no,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.system_code,
      new_references.entry_year,
      new_references.entry_month,
      new_references.aca_cal_type,
      new_references.aca_cal_seq_no,
      new_references.adm_cal_type,
      new_references.adm_cal_seq_no,
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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        aca_cal_type,
        aca_cal_seq_no,
        adm_cal_type,
        adm_cal_seq_no
      FROM  igs_uc_sys_calndrs
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
        (tlinfo.aca_cal_type = x_aca_cal_type)
        AND (tlinfo.aca_cal_seq_no = x_aca_cal_seq_no)
        AND (tlinfo.adm_cal_type = x_adm_cal_type)
        AND (tlinfo.adm_cal_seq_no = x_adm_cal_seq_no)
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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_SYS_CALNDRS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_system_code                       => x_system_code,
      x_entry_year                        => x_entry_year,
      x_entry_month                       => x_entry_month,
      x_aca_cal_type                      => x_aca_cal_type,
      x_aca_cal_seq_no                    => x_aca_cal_seq_no,
      x_adm_cal_type                      => x_adm_cal_type,
      x_adm_cal_seq_no                    => x_adm_cal_seq_no,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_sys_calndrs
      SET
        aca_cal_type                      = new_references.aca_cal_type,
        aca_cal_seq_no                    = new_references.aca_cal_seq_no,
        adm_cal_type                      = new_references.adm_cal_type,
        adm_cal_seq_no                    = new_references.adm_cal_seq_no,
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
    x_entry_year                        IN     NUMBER,
    x_entry_month                       IN     NUMBER,
    x_aca_cal_type                      IN     VARCHAR2,
    x_aca_cal_seq_no                    IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_cal_seq_no                    IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_sys_calndrs
      WHERE    system_code                       = x_system_code
      AND      entry_year                        = x_entry_year
      AND      entry_month                       = x_entry_month;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_system_code,
        x_entry_year,
        x_entry_month,
        x_aca_cal_type,
        x_aca_cal_seq_no,
        x_adm_cal_type,
        x_adm_cal_seq_no,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_system_code,
      x_entry_year,
      x_entry_month,
      x_aca_cal_type,
      x_aca_cal_seq_no,
      x_adm_cal_type,
      x_adm_cal_seq_no,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : dilip.sridhar@oracle.com
  ||  Created On : 24-JUL-2003
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

    DELETE FROM igs_uc_sys_calndrs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_sys_calndrs_pkg;

/
