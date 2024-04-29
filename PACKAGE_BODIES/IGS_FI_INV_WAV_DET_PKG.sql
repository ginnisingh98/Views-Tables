--------------------------------------------------------
--  DDL for Package Body IGS_FI_INV_WAV_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_INV_WAV_DET_PKG" AS
/* $Header: IGSSIB9B.pls 115.4 2002/11/29 04:05:58 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_inv_wav_det%ROWTYPE;
  new_references igs_fi_inv_wav_det%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_balance_type                      IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_INV_WAV_DET
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
    new_references.invoice_id                        := x_invoice_id;
    new_references.balance_type                      := x_balance_type;
    new_references.start_dt                          := x_start_dt;
    new_references.end_dt                            := x_end_dt;

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


  FUNCTION validate_overlapping(p_invoice_id   IGS_FI_INV_WAV_DET.invoice_id%TYPE ,
                                p_balance_type IGS_FI_INV_WAV_DET.balance_type%TYPE,
                                p_start_dt     IGS_FI_INV_WAV_DET.start_dt%TYPE,
                                p_end_dt       IGS_FI_INV_WAV_DET.end_dt%TYPE,
                                p_row_id       VARCHAR2)
  RETURN BOOLEAN AS
  /*
  ||  Created By : sarakshi
  ||  Created On : 03-DEC-2001
  ||  Purpose : Validates the overlapping of the effective dates.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_overlapping_u(cp_invoice_id IGS_FI_INV_WAV_DET.invoice_id%TYPE ,
                 cp_balance_type IGS_FI_INV_WAV_DET.balance_type%TYPE,
                 cp_start_dt   IGS_FI_INV_WAV_DET.start_dt%TYPE,
                 cp_row_id  VARCHAR2 ) IS
  SELECT 'X'
  FROM   igs_fi_inv_wav_det
  WHERE  invoice_id   = cp_invoice_id
  AND    balance_type = cp_balance_type
  AND    cp_start_dt >= start_dt AND cp_start_dt <= NVL(end_dt,cp_start_dt)
  AND    (rowid <> cp_row_id  OR (cp_row_id IS NULL));

  CURSOR cur_overlapping_u1(cp_invoice_id IGS_FI_INV_WAV_DET.invoice_id%TYPE ,
                 cp_balance_type IGS_FI_INV_WAV_DET.balance_type%TYPE,
                 cp_start_dt   IGS_FI_INV_WAV_DET.start_dt%TYPE,
                 cp_end_dt     IGS_FI_INV_WAV_DET.end_dt%TYPE,
                 cp_row_id  VARCHAR2 ) IS
  SELECT 'X'
  FROM   igs_fi_inv_wav_det
  WHERE  invoice_id   = cp_invoice_id
  AND    balance_type = cp_balance_type
  AND    (cp_end_dt >= start_dt OR (cp_end_dt IS NULL)) AND cp_start_dt <= start_dt
  AND    (rowid <> cp_row_id OR (cp_row_id IS NULL));

  l_temp  VARCHAR2(1);

  BEGIN
    --Validating if effective dates  are not overlapping

    -- start date overlapping
    OPEN cur_overlapping_u(p_invoice_id,p_balance_type,p_start_dt,p_row_id);
    FETCH cur_overlapping_u INTO l_temp;
    IF cur_overlapping_u%FOUND THEN
      CLOSE cur_overlapping_u;
      RETURN FALSE;
    END IF;
    CLOSE cur_overlapping_u;

    --end date overlapping
    OPEN cur_overlapping_u1(p_invoice_id,p_balance_type,p_start_dt,p_end_dt,p_row_id);
    FETCH cur_overlapping_u1 INTO l_temp;
    IF cur_overlapping_u1%FOUND THEN
      CLOSE cur_overlapping_u1;
      RETURN FALSE;
    END IF;
    CLOSE cur_overlapping_u1;

    RETURN TRUE;

  END validate_overlapping;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.invoice_id = new_references.invoice_id)) OR
        ((new_references.invoice_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.balance_type = new_references.balance_type)) OR
        ((new_references.balance_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
               'IGS_FI_BALANCE_TYPE',
                new_references.balance_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_inv_wav_det
      WHERE    invoice_id = x_invoice_id
      AND      balance_type = x_balance_type
      AND      start_dt = x_start_dt
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


  PROCEDURE get_fk_igs_fi_inv_int_all (
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_inv_wav_det
      WHERE   ((invoice_id = x_invoice_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIW_INVI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_inv_int_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_balance_type                      IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
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
      x_invoice_id,
      x_balance_type,
      x_start_dt,
      x_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    --Added by sarakshi, to validate the logic of dates overlap
    IF p_action IN ( 'INSERT', 'VALIDATE_INSERT','UPDATE','VALIDATE_UPDATE') THEN
      IF NOT validate_overlapping(x_invoice_id , x_balance_type ,
                                 x_start_dt  , x_end_dt,x_rowid  )   THEN
        fnd_message.set_name('IGS','IGS_FI_WVR_OVERLAP');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.invoice_id,
             new_references.balance_type,
             new_references.start_dt
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
             new_references.invoice_id,
             new_references.balance_type,
             new_references.start_dt
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
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_inv_wav_det
      WHERE    invoice_id                        = x_invoice_id
      AND      balance_type                      = x_balance_type
      AND      start_dt                          = x_start_dt;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_invoice_id                        => x_invoice_id,
      x_balance_type                      => x_balance_type,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_inv_wav_det (
      invoice_id,
      balance_type,
      start_dt,
      end_dt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.invoice_id,
      new_references.balance_type,
      new_references.start_dt,
      new_references.end_dt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
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
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        end_dt
      FROM  igs_fi_inv_wav_det
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
        ((tlinfo.end_dt = x_end_dt) OR ((tlinfo.end_dt IS NULL) AND (X_end_dt IS NULL)))
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
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
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
      x_invoice_id                        => x_invoice_id,
      x_balance_type                      => x_balance_type,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
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

    UPDATE igs_fi_inv_wav_det
      SET
        end_dt                            = new_references.end_dt,
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
    x_invoice_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_inv_wav_det
      WHERE    invoice_id                        = x_invoice_id
      AND      balance_type                      = x_balance_type
      AND      start_dt                          = x_start_dt;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_invoice_id,
        x_balance_type,
        x_start_dt,
        x_end_dt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_invoice_id,
      x_balance_type,
      x_start_dt,
      x_end_dt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
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

    DELETE FROM igs_fi_inv_wav_det
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_inv_wav_det_pkg;

/
