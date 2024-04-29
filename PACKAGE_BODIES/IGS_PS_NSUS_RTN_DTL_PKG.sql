--------------------------------------------------------
--  DDL for Package Body IGS_PS_NSUS_RTN_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_NSUS_RTN_DTL_PKG" AS
/* $Header: IGSPI3OB.pls 120.0 2005/06/01 22:32:34 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_nsus_rtn_dtl%ROWTYPE;
  new_references igs_ps_nsus_rtn_dtl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_nsus_rtn_dtl
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
    new_references.non_std_usec_rtn_dtl_id           := x_non_std_usec_rtn_dtl_id;
    new_references.non_std_usec_rtn_id               := x_non_std_usec_rtn_id;
    new_references.offset_value                      := x_offset_value;
    new_references.retention_percent                 := x_retention_percent;
    new_references.retention_amount                  := x_retention_amount;
    new_references.offset_date                       := x_offset_date;
    new_references.override_date_flag                := x_override_date_flag;

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

  PROCEDURE check_constraints(
                                Column_Name     IN      VARCHAR2        ,
                                Column_Value    IN      VARCHAR2        )
  AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the column Constraints logic.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
   l_c_column_value VARCHAR2(30) ;
  BEGIN
    l_c_column_value := UPPER(Column_Name);

    IF Column_Name IS NULL THEN
           NULL;
    ELSIF l_c_column_value ='OFFSET_VALUE' THEN
           New_References.offset_value := Column_Value;
    ELSIF l_c_column_value ='RETENTION_PERCENT' THEN
           New_References.retention_percent := Column_Value;
    ELSIF l_c_column_value ='RETENTION_AMOUNT' THEN
           New_References.retention_amount := Column_Value;
    END IF;

    IF l_c_column_value ='OFFSET_VALUE' OR Column_Name IS NULL THEN
       IF New_References.offset_value < 0 OR  New_References.offset_value > 999 THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF l_c_column_value ='RETENTION_PERCENT' OR Column_Name IS NULL THEN
       IF New_References.retention_percent < 0 OR New_References.retention_percent > 100 THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF l_c_column_value ='RETENTION_AMOUNT' OR Column_Name IS NULL THEN
       IF New_References.retention_amount < 0  OR New_References.retention_amount > 999999.99 THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

  END check_constraints ;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.non_std_usec_rtn_id,
           new_references.offset_value
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.non_std_usec_rtn_id = new_references.non_std_usec_rtn_id)) OR
        ((new_references.non_std_usec_rtn_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_nsus_rtn_pkg.get_pk_for_validation (
                new_references.non_std_usec_rtn_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_non_std_usec_rtn_dtl_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn_dtl
      WHERE    non_std_usec_rtn_dtl_id = x_non_std_usec_rtn_dtl_id
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
    x_non_std_usec_rtn_id                IN     NUMBER,
    x_offset_value                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn_dtl
      WHERE    non_std_usec_rtn_id = x_non_std_usec_rtn_id
      AND      offset_value = x_offset_value
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

  PROCEDURE get_fk_igs_ps_nsus_rtn (
    x_non_std_usec_rtn_id               IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn_dtl
      WHERE   ((non_std_usec_rtn_id = x_non_std_usec_rtn_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_NRD_NR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_nsus_rtn;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      x_non_std_usec_rtn_dtl_id,
      x_non_std_usec_rtn_id,
      x_offset_value,
      x_retention_percent,
      x_retention_amount,
      x_offset_date,
      x_override_date_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.non_std_usec_rtn_dtl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.non_std_usec_rtn_dtl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    END IF;

    l_rowid := null;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN OUT NOCOPY NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_NSUS_RTN_DTL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_non_std_usec_rtn_dtl_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_non_std_usec_rtn_dtl_id           => x_non_std_usec_rtn_dtl_id,
      x_non_std_usec_rtn_id               => x_non_std_usec_rtn_id,
      x_offset_value                      => x_offset_value,
      x_retention_percent                 => x_retention_percent,
      x_retention_amount                  => x_retention_amount,
      x_offset_date                       => x_offset_date,
      x_override_date_flag                => x_override_date_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_nsus_rtn_dtl (
      non_std_usec_rtn_dtl_id,
      non_std_usec_rtn_id,
      offset_value,
      retention_percent,
      retention_amount,
      offset_date,
      override_date_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ps_nsus_rtn_dtl_s.NEXTVAL,
      new_references.non_std_usec_rtn_id,
      new_references.offset_value,
      new_references.retention_percent,
      new_references.retention_amount,
      new_references.offset_date,
      new_references.override_date_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, non_std_usec_rtn_dtl_id INTO x_rowid, x_non_std_usec_rtn_dtl_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        non_std_usec_rtn_id,
        offset_value,
        retention_percent,
        retention_amount,
        offset_date,
        override_date_flag
      FROM  igs_ps_nsus_rtn_dtl
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
        (tlinfo.non_std_usec_rtn_id = x_non_std_usec_rtn_id)
        AND (tlinfo.offset_value = x_offset_value)
        AND ((tlinfo.retention_percent = x_retention_percent) OR ((tlinfo.retention_percent IS NULL) AND (X_retention_percent IS NULL)))
        AND ((tlinfo.retention_amount = x_retention_amount) OR ((tlinfo.retention_amount IS NULL) AND (X_retention_amount IS NULL)))
        AND ((tlinfo.offset_date = x_offset_date) OR ((tlinfo.offset_date IS NULL) AND (X_offset_date IS NULL)))
        AND (tlinfo.override_date_flag = x_override_date_flag)
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
    x_non_std_usec_rtn_dtl_id           IN     NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_NSUS_RTN_DTL_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_non_std_usec_rtn_dtl_id           => x_non_std_usec_rtn_dtl_id,
      x_non_std_usec_rtn_id               => x_non_std_usec_rtn_id,
      x_offset_value                      => x_offset_value,
      x_retention_percent                 => x_retention_percent,
      x_retention_amount                  => x_retention_amount,
      x_offset_date                       => x_offset_date,
      x_override_date_flag                => x_override_date_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_nsus_rtn_dtl
      SET
        non_std_usec_rtn_id               = new_references.non_std_usec_rtn_id,
        offset_value                      = new_references.offset_value,
        retention_percent                 = new_references.retention_percent,
        retention_amount                  = new_references.retention_amount,
        offset_date                       = new_references.offset_date,
        override_date_flag                = new_references.override_date_flag,
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
    x_non_std_usec_rtn_dtl_id           IN OUT NOCOPY NUMBER,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_offset_value                      IN     NUMBER,
    x_retention_percent                 IN     NUMBER,
    x_retention_amount                  IN     NUMBER,
    x_offset_date                       IN     DATE,
    x_override_date_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn_dtl
      WHERE    non_std_usec_rtn_dtl_id           = x_non_std_usec_rtn_dtl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_non_std_usec_rtn_dtl_id,
        x_non_std_usec_rtn_id,
        x_offset_value,
        x_retention_percent,
        x_retention_amount,
        x_offset_date,
        x_override_date_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_non_std_usec_rtn_dtl_id,
      x_non_std_usec_rtn_id,
      x_offset_value,
      x_retention_percent,
      x_retention_amount,
      x_offset_date,
      x_override_date_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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

    DELETE FROM igs_ps_nsus_rtn_dtl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_nsus_rtn_dtl_pkg;

/
