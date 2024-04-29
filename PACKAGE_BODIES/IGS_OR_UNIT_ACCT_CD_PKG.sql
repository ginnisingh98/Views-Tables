--------------------------------------------------------
--  DDL for Package Body IGS_OR_UNIT_ACCT_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_UNIT_ACCT_CD_PKG" AS
/* $Header: IGSOI31B.pls 115.6 2003/02/17 05:43:40 pathipat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_or_unit_acct_cd_all%ROWTYPE;
  new_references igs_or_unit_acct_cd_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_account_cd_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_rev_account_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_UNIT_ACCT_CD_ALL
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
    new_references.org_account_cd_id                 := x_org_account_cd_id;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.start_dt                          := x_start_dt;
    new_references.rev_account_cd                    := x_rev_account_cd;

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

  PROCEDURE Check_Parent_Existance AS
  BEGIN

      IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION get_pk_for_validation (
    x_org_account_cd_id                 IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_unit_acct_cd_all
      WHERE    org_account_cd_id = x_org_account_cd_id
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
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_account_cd_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_rev_account_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
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
      x_org_account_cd_id,
      x_org_unit_cd,
      x_start_dt,
      x_rev_account_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.org_account_cd_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.org_account_cd_id
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
    x_org_account_cd_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_or_unit_acct_cd_all
      WHERE    org_account_cd_id                 = x_org_account_cd_id;

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

    SELECT    igs_or_unit_acct_cd_s.NEXTVAL
    INTO      x_org_account_cd_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_org_account_cd_id                 => x_org_account_cd_id,
      x_org_unit_cd                       => x_org_unit_cd,
      x_start_dt                          => x_start_dt,
      x_rev_account_cd                    => x_rev_account_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_or_unit_acct_cd_all (
      org_account_cd_id,
      org_unit_cd,
      start_dt,
      rev_account_cd,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.org_account_cd_id,
      new_references.org_unit_cd,
      new_references.start_dt,
      new_references.rev_account_cd,
      new_references.org_id,
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
    x_org_account_cd_id                 IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        org_unit_cd,
        start_dt,
        rev_account_cd
      FROM  igs_or_unit_acct_cd_all
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
        (tlinfo.org_unit_cd = x_org_unit_cd)
        AND (tlinfo.start_dt = x_start_dt)
        AND (tlinfo.rev_account_cd = x_rev_account_cd)
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
    x_org_account_cd_id                 IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
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
      x_org_account_cd_id                 => x_org_account_cd_id,
      x_org_unit_cd                       => x_org_unit_cd,
      x_start_dt                          => x_start_dt,
      x_rev_account_cd                    => x_rev_account_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_or_unit_acct_cd_all
      SET
        org_unit_cd                       = new_references.org_unit_cd,
        start_dt                          = new_references.start_dt,
        rev_account_cd                    = new_references.rev_account_cd,
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
    x_org_account_cd_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_or_unit_acct_cd_all
      WHERE    org_account_cd_id                 = x_org_account_cd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_org_account_cd_id,
        x_org_unit_cd,
        x_start_dt,
        x_rev_account_cd,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_org_account_cd_id,
      x_org_unit_cd,
      x_start_dt,
      x_rev_account_cd,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kkillams
  ||  Created On : 19-JUL-2001
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

    DELETE FROM igs_or_unit_acct_cd_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_or_unit_acct_cd_pkg;

/
