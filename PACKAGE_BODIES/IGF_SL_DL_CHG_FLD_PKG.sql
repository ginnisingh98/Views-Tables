--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_CHG_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_CHG_FLD_PKG" AS
/* $Header: IGFLI16B.pls 115.5 2002/11/28 14:25:04 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_dl_chg_fld%ROWTYPE;
  new_references igf_sl_dl_chg_fld%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dchg_id                           IN     NUMBER      DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_loan_catg                         IN     VARCHAR2    DEFAULT NULL,
    x_fld_name                          IN     VARCHAR2    DEFAULT NULL,
    x_fld_length                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_DL_CHG_FLD
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
    new_references.dchg_id                           := x_dchg_id;
    new_references.dl_version                        := x_dl_version;
    new_references.chg_code                          := x_chg_code;
    new_references.loan_catg                         := x_loan_catg;
    new_references.fld_name                          := x_fld_name;
    new_references.fld_length                        := x_fld_length;

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
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.dl_version,
           new_references.loan_catg,
           new_references.fld_name
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ( get_uk2_for_validation (
           new_references.dl_version,
           new_references.loan_catg,
           new_references.chg_code
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_dchg_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_fld
      WHERE    dchg_id = x_dchg_id
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
    x_dl_version                        IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_fld
      WHERE    dl_version = x_dl_version
      AND      loan_catg = x_loan_catg
      AND      fld_name = x_fld_name
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


  FUNCTION get_uk2_for_validation (
    x_dl_version                        IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_fld
      WHERE    dl_version = x_dl_version
      AND      loan_catg = x_loan_catg
      AND      chg_code = x_chg_code
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

  END get_uk2_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dchg_id                           IN     NUMBER      DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_loan_catg                         IN     VARCHAR2    DEFAULT NULL,
    x_fld_name                          IN     VARCHAR2    DEFAULT NULL,
    x_fld_length                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
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
      x_dchg_id,
      x_dl_version,
      x_chg_code,
      x_loan_catg,
      x_fld_name,
      x_fld_length,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.dchg_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.dchg_id
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
    x_dchg_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_fld
      WHERE    dchg_id                           = x_dchg_id;

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

    SELECT igf_sl_dl_chg_fld_s.NEXTVAL into x_dchg_id FROM DUAL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_dchg_id                           => x_dchg_id,
      x_dl_version                        => x_dl_version,
      x_chg_code                          => x_chg_code,
      x_loan_catg                         => x_loan_catg,
      x_fld_name                          => x_fld_name,
      x_fld_length                        => x_fld_length,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_dl_chg_fld (
      dchg_id,
      dl_version,
      chg_code,
      loan_catg,
      fld_name,
      fld_length,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.dchg_id,
      new_references.dl_version,
      new_references.chg_code,
      new_references.loan_catg,
      new_references.fld_name,
      new_references.fld_length,
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
    x_dchg_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        dl_version,
        chg_code,
        loan_catg,
        fld_name,
        fld_length
      FROM  igf_sl_dl_chg_fld
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
        (tlinfo.dl_version = x_dl_version)
        AND (tlinfo.chg_code = x_chg_code)
        AND (tlinfo.loan_catg = x_loan_catg)
        AND (tlinfo.fld_name = x_fld_name)
        AND ((tlinfo.fld_length = x_fld_length) OR ((tlinfo.fld_length IS NULL) AND (X_fld_length IS NULL)))
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
    x_dchg_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
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
      x_dchg_id                           => x_dchg_id,
      x_dl_version                        => x_dl_version,
      x_chg_code                          => x_chg_code,
      x_loan_catg                         => x_loan_catg,
      x_fld_name                          => x_fld_name,
      x_fld_length                        => x_fld_length,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_sl_dl_chg_fld
      SET
        dl_version                        = new_references.dl_version,
        chg_code                          = new_references.chg_code,
        loan_catg                         = new_references.loan_catg,
        fld_name                          = new_references.fld_name,
        fld_length                        = new_references.fld_length,
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
    x_dchg_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_loan_catg                         IN     VARCHAR2,
    x_fld_name                          IN     VARCHAR2,
    x_fld_length                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_fld
      WHERE    dchg_id                           = x_dchg_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_dchg_id,
        x_dl_version,
        x_chg_code,
        x_loan_catg,
        x_fld_name,
        x_fld_length,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_dchg_id,
      x_dl_version,
      x_chg_code,
      x_loan_catg,
      x_fld_name,
      x_fld_length,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 05-DEC-2000
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

    DELETE FROM igf_sl_dl_chg_fld
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_dl_chg_fld_pkg;

/
