--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_TRNSCTNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_TRNSCTNS_PKG" AS
/* $Header: IGSSIB7B.pls 115.4 2002/11/29 04:05:21 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_bill_trnsctns%ROWTYPE;
  new_references igs_fi_bill_trnsctns%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_invoice_creditact_id              IN     NUMBER      DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_transaction_number                IN     VARCHAR2    DEFAULT NULL,
    x_fee_credit_type                   IN     VARCHAR2    DEFAULT NULL,
    x_transaction_description           IN     VARCHAR2    DEFAULT NULL,
    x_transaction_amount                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_BILL_TRNSCTNS
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
    new_references.transaction_id                    := x_transaction_id;
    new_references.bill_id                           := x_bill_id;
    new_references.transaction_type                  := x_transaction_type;
    new_references.invoice_creditact_id              := x_invoice_creditact_id;
    new_references.transaction_date                  := x_transaction_date;
    new_references.transaction_number                := x_transaction_number;
    new_references.fee_credit_type                   := x_fee_credit_type;
    new_references.transaction_description           := x_transaction_description;
    new_references.transaction_amount                := x_transaction_amount;

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
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.transaction_type,
           new_references.invoice_creditact_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

   IF (new_references.transaction_type = 'D') THEN
    IF (((old_references.invoice_creditact_id = new_references.invoice_creditact_id)) OR
        ((new_references.invoice_creditact_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_creditact_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
   END IF;
    IF (((old_references.bill_id = new_references.bill_id)) OR
        ((new_references.bill_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_bill_pkg.get_pk_for_validation (
                new_references.bill_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

   IF (new_references.transaction_type = 'C') THEN
    IF (((old_references.invoice_creditact_id = new_references.invoice_creditact_id)) OR
        ((new_references.invoice_creditact_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_cr_activities_pkg.get_pk_for_validation (
                new_references.invoice_creditact_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
   END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_transaction_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE    transaction_id = x_transaction_id
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
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE    transaction_type = x_transaction_type
      AND      invoice_creditact_id = x_invoice_creditact_id
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


  PROCEDURE get_fk_igs_fi_inv_int (
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE   ((invoice_creditact_id = x_invoice_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_TRANS_INV_INT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_inv_int;


  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE   ((bill_id = x_bill_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_TRANS_BILL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_bill;


  PROCEDURE get_fk_igs_fi_cr_activities (
    x_credit_activity_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE   ((invoice_creditact_id = x_credit_activity_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_TRANS_CR_ACT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_cr_activities;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_invoice_creditact_id              IN     NUMBER      DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_transaction_number                IN     VARCHAR2    DEFAULT NULL,
    x_fee_credit_type                   IN     VARCHAR2    DEFAULT NULL,
    x_transaction_description           IN     VARCHAR2    DEFAULT NULL,
    x_transaction_amount                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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
      x_transaction_id,
      x_bill_id,
      x_transaction_type,
      x_invoice_creditact_id,
      x_transaction_date,
      x_transaction_number,
      x_fee_credit_type,
      x_transaction_description,
      x_transaction_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.transaction_id
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
             new_references.transaction_id
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
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE    transaction_id                    = x_transaction_id;

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

    SELECT    igs_fi_bill_trnsctns_s.NEXTVAL
    INTO      x_transaction_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_transaction_id                    => x_transaction_id,
      x_bill_id                           => x_bill_id,
      x_transaction_type                  => x_transaction_type,
      x_invoice_creditact_id              => x_invoice_creditact_id,
      x_transaction_date                  => x_transaction_date,
      x_transaction_number                => x_transaction_number,
      x_fee_credit_type                   => x_fee_credit_type,
      x_transaction_description           => x_transaction_description,
      x_transaction_amount                => x_transaction_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_bill_trnsctns (
      transaction_id,
      bill_id,
      transaction_type,
      invoice_creditact_id,
      transaction_date,
      transaction_number,
      fee_credit_type,
      transaction_description,
      transaction_amount,
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
      new_references.transaction_id,
      new_references.bill_id,
      new_references.transaction_type,
      new_references.invoice_creditact_id,
      new_references.transaction_date,
      new_references.transaction_number,
      new_references.fee_credit_type,
      new_references.transaction_description,
      new_references.transaction_amount,
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
    x_transaction_id                    IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        bill_id,
        transaction_type,
        invoice_creditact_id,
        transaction_date,
        transaction_number,
        fee_credit_type,
        transaction_description,
        transaction_amount
      FROM  igs_fi_bill_trnsctns
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
        (tlinfo.bill_id = x_bill_id)
        AND (tlinfo.transaction_type = x_transaction_type)
        AND (tlinfo.invoice_creditact_id = x_invoice_creditact_id)
        AND (tlinfo.transaction_date = x_transaction_date)
        AND ((tlinfo.transaction_number = x_transaction_number) OR ((tlinfo.transaction_number IS NULL) AND (X_transaction_number IS NULL)))
        AND (tlinfo.fee_credit_type = x_fee_credit_type)
        AND ((tlinfo.transaction_description = x_transaction_description) OR ((tlinfo.transaction_description IS NULL) AND (X_transaction_description IS NULL)))
        AND (tlinfo.transaction_amount = x_transaction_amount)
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
    x_transaction_id                    IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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
      x_transaction_id                    => x_transaction_id,
      x_bill_id                           => x_bill_id,
      x_transaction_type                  => x_transaction_type,
      x_invoice_creditact_id              => x_invoice_creditact_id,
      x_transaction_date                  => x_transaction_date,
      x_transaction_number                => x_transaction_number,
      x_fee_credit_type                   => x_fee_credit_type,
      x_transaction_description           => x_transaction_description,
      x_transaction_amount                => x_transaction_amount,
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

    UPDATE igs_fi_bill_trnsctns
      SET
        bill_id                           = new_references.bill_id,
        transaction_type                  = new_references.transaction_type,
        invoice_creditact_id              = new_references.invoice_creditact_id,
        transaction_date                  = new_references.transaction_date,
        transaction_number                = new_references.transaction_number,
        fee_credit_type                   = new_references.fee_credit_type,
        transaction_description           = new_references.transaction_description,
        transaction_amount                = new_references.transaction_amount,
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
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE    transaction_id                    = x_transaction_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_transaction_id,
        x_bill_id,
        x_transaction_type,
        x_invoice_creditact_id,
        x_transaction_date,
        x_transaction_number,
        x_fee_credit_type,
        x_transaction_description,
        x_transaction_amount,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_transaction_id,
      x_bill_id,
      x_transaction_type,
      x_invoice_creditact_id,
      x_transaction_date,
      x_transaction_number,
      x_fee_credit_type,
      x_transaction_description,
      x_transaction_amount,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
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

    DELETE FROM igs_fi_bill_trnsctns
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_bill_trnsctns_pkg;

/
