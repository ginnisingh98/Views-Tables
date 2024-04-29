--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_CHG_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_CHG_RESP_PKG" AS
/* $Header: IGFLI18B.pls 115.9 2002/11/28 14:25:33 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sl_dl_chg_resp_all%ROWTYPE;
  new_references igf_sl_dl_chg_resp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_resp_num                          IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_reject_code                       IN     VARCHAR2    DEFAULT NULL,
    x_new_value                         IN     VARCHAR2    DEFAULT NULL,
    x_loan_ident_err_code               IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_dl_chg_resp_all
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
    new_references.resp_num                          := x_resp_num;
    new_references.dbth_id                           := x_dbth_id;
    new_references.batch_id                          := x_batch_id;
    new_references.loan_number                       := x_loan_number;
    new_references.chg_code                          := x_chg_code;
    new_references.reject_code                       := x_reject_code;
    new_references.new_value                         := x_new_value;
    new_references.loan_ident_err_code               := x_loan_ident_err_code;
    new_references.status                            := x_status;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.dbth_id = new_references.dbth_id)) OR
        ((new_references.dbth_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_dl_batch_pkg.get_pk_for_validation (
                new_references.dbth_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_resp_num                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_resp_all
      WHERE    resp_num = x_resp_num
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


  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_resp_all
      WHERE   ((dbth_id = x_dbth_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_RCHG_DBTH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_dl_batch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_resp_num                          IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_reject_code                       IN     VARCHAR2    DEFAULT NULL,
    x_new_value                         IN     VARCHAR2    DEFAULT NULL,
    x_loan_ident_err_code               IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
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
      x_resp_num,
      x_dbth_id,
      x_batch_id,
      x_loan_number,
      x_chg_code,
      x_reject_code,
      x_new_value,
      x_loan_ident_err_code,
      x_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.resp_num
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.resp_num
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
    x_resp_num                          IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_reject_code                       IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_loan_ident_err_code               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_resp_all
      WHERE    resp_num                          = x_resp_num;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_sl_dl_chg_resp_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_sl_dl_chg_resp_s.nextval INTO
           x_resp_num FROM dual;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_resp_num                          => x_resp_num,
      x_dbth_id                           => x_dbth_id,
      x_batch_id                          => x_batch_id,
      x_loan_number                       => x_loan_number,
      x_chg_code                          => x_chg_code,
      x_reject_code                       => x_reject_code,
      x_new_value                         => x_new_value,
      x_loan_ident_err_code               => x_loan_ident_err_code,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_dl_chg_resp_all (
      resp_num,
      dbth_id,
      batch_id,
      loan_number,
      chg_code,
      reject_code,
      new_value,
      loan_ident_err_code,
      status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id
    ) VALUES (
      new_references.resp_num,
      new_references.dbth_id,
      new_references.batch_id,
      new_references.loan_number,
      new_references.chg_code,
      new_references.reject_code,
      new_references.new_value,
      new_references.loan_ident_err_code,
      new_references.status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id
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
    x_resp_num                          IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_reject_code                       IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_loan_ident_err_code               IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        dbth_id,
        batch_id,
        loan_number,
        chg_code,
        reject_code,
        new_value,
        loan_ident_err_code,
        status,
        org_id
      FROM  igf_sl_dl_chg_resp_all
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
        (tlinfo.dbth_id = x_dbth_id)
        AND (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.loan_number = x_loan_number)
        AND (tlinfo.chg_code = x_chg_code)
        AND ((tlinfo.reject_code = x_reject_code) OR ((tlinfo.reject_code IS NULL) AND (X_reject_code IS NULL)))
        AND ((tlinfo.new_value = x_new_value) OR ((tlinfo.new_value IS NULL) AND (X_new_value IS NULL)))
        AND ((tlinfo.loan_ident_err_code = x_loan_ident_err_code) OR ((tlinfo.loan_ident_err_code IS NULL) AND (X_loan_ident_err_code IS NULL)))
        AND (tlinfo.status = x_status)
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
    x_resp_num                          IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_reject_code                       IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_loan_ident_err_code               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_resp_num                          => x_resp_num,
      x_dbth_id                           => x_dbth_id,
      x_batch_id                          => x_batch_id,
      x_loan_number                       => x_loan_number,
      x_chg_code                          => x_chg_code,
      x_reject_code                       => x_reject_code,
      x_new_value                         => x_new_value,
      x_loan_ident_err_code               => x_loan_ident_err_code,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_sl_dl_chg_resp_all
      SET
        dbth_id                           = new_references.dbth_id,
        batch_id                          = new_references.batch_id,
        loan_number                       = new_references.loan_number,
        chg_code                          = new_references.chg_code,
        reject_code                       = new_references.reject_code,
        new_value                         = new_references.new_value,
        loan_ident_err_code               = new_references.loan_ident_err_code,
        status                            = new_references.status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_resp_num                          IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_reject_code                       IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_loan_ident_err_code               IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sl_dl_chg_resp_all
      WHERE    resp_num                          = x_resp_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_resp_num,
        x_dbth_id,
        x_batch_id,
        x_loan_number,
        x_chg_code,
        x_reject_code,
        x_new_value,
        x_loan_ident_err_code,
        x_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_resp_num,
      x_dbth_id,
      x_batch_id,
      x_loan_number,
      x_chg_code,
      x_reject_code,
      x_new_value,
      x_loan_ident_err_code,
      x_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sjadhav
  ||  Created On : 02-NOV-2000
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

    DELETE FROM igf_sl_dl_chg_resp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_dl_chg_resp_pkg;

/
