--------------------------------------------------------
--  DDL for Package Body IGS_FI_SPECIAL_FEES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_SPECIAL_FEES_PKG" AS
/* $Header: IGSSIE5B.pls 115.2 2003/11/06 14:23:00 pathipat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_special_fees%ROWTYPE;
  new_references igs_fi_special_fees%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_special_fees
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
    new_references.special_fee_id                    := x_special_fee_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.fee_type                          := x_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.fee_amt                           := x_fee_amt;
    new_references.transaction_date                  := x_transaction_date;
    new_references.s_transaction_type_code           := x_s_transaction_type_code;
    new_references.invoice_id                        := x_invoice_id;

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
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_person IS
    SELECT rowid
    FROM hz_parties
    WHERE party_id = new_references.person_id;

  l_rowid     cur_person%ROWTYPE;

  BEGIN

    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_type,
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.uoo_id IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_usec_sp_fees_pkg.get_uk_for_validation (
                new_references.uoo_id,
                new_references.fee_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ((old_references.person_id = new_references.person_id) OR
        (new_references.person_id IS NULL)) THEN
      NULL;
    ELSE
      OPEN cur_person;
      FETCH cur_person INTO l_rowid;
      IF cur_person%FOUND THEN
         CLOSE cur_person;
      ELSE
         CLOSE cur_person;
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF ((old_references.invoice_id = new_references.invoice_id) OR
        (new_references.invoice_id IS NULL)) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_special_fee_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_special_fees
      WHERE    special_fee_id = x_special_fee_id
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


  PROCEDURE get_fk_igs_ps_usec_sp_fees (
    x_uoo_id      IN  NUMBER,
    x_fee_type    IN  VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_special_fees
      WHERE    uoo_id = x_uoo_id
      AND      fee_type = x_fee_type;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FSP_USEC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_usec_sp_fees;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
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
      x_special_fee_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_amt,
      x_transaction_date,
      x_s_transaction_type_code,
      x_invoice_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.special_fee_id
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
             new_references.special_fee_id
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
    x_special_fee_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SPECIAL_FEES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_special_fee_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_special_fee_id                    => x_special_fee_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_amt                           => x_fee_amt,
      x_transaction_date                  => x_transaction_date,
      x_s_transaction_type_code           => x_s_transaction_type_code,
      x_invoice_id                        => x_invoice_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_special_fees (
      special_fee_id,
      person_id,
      course_cd,
      uoo_id,
      fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      fee_amt,
      transaction_date,
      s_transaction_type_code,
      invoice_id,
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
      igs_fi_special_fees_s.NEXTVAL,
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.fee_amt,
      new_references.transaction_date,
      new_references.s_transaction_type_code,
      new_references.invoice_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, special_fee_id INTO x_rowid, x_special_fee_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        uoo_id,
        fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        fee_amt,
        transaction_date,
        s_transaction_type_code,
        invoice_id
      FROM  igs_fi_special_fees
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND (tlinfo.fee_amt = x_fee_amt)
        AND (tlinfo.transaction_date = x_transaction_date)
        AND (tlinfo.s_transaction_type_code = x_s_transaction_type_code)
        AND (tlinfo.invoice_id = x_invoice_id)
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
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_SPECIAL_FEES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_special_fee_id                    => x_special_fee_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_amt                           => x_fee_amt,
      x_transaction_date                  => x_transaction_date,
      x_s_transaction_type_code           => x_s_transaction_type_code,
      x_invoice_id                        => x_invoice_id,
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

    UPDATE igs_fi_special_fees
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        uoo_id                            = new_references.uoo_id,
        fee_type                          = new_references.fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        fee_amt                           = new_references.fee_amt,
        transaction_date                  = new_references.transaction_date,
        s_transaction_type_code           = new_references.s_transaction_type_code,
        invoice_id                        = new_references.invoice_id,
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
    x_special_fee_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_special_fees
      WHERE    special_fee_id                    = x_special_fee_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_special_fee_id,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_fee_amt,
        x_transaction_date,
        x_s_transaction_type_code,
        x_invoice_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_special_fee_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_amt,
      x_transaction_date,
      x_s_transaction_type_code,
      x_invoice_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : priya.athipatla@oracle.com
  ||  Created On : 16-OCT-2003
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

    DELETE FROM igs_fi_special_fees
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_special_fees_pkg;

/
