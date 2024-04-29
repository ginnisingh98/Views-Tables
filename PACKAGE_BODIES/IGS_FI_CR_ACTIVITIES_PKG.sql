--------------------------------------------------------
--  DDL for Package Body IGS_FI_CR_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CR_ACTIVITIES_PKG" AS
/* $Header: IGSSI87B.pls 115.15 2003/02/17 09:01:48 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_cr_activities%ROWTYPE;
  new_references igs_fi_cr_activities%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_CR_ACTIVITIES
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
    new_references.credit_activity_id                := x_credit_activity_id;
    new_references.credit_id                         := x_credit_id;
    new_references.status                            := x_status;
    new_references.transaction_date                  := x_transaction_date;
    new_references.amount                            := x_amount;
    new_references.dr_account_cd                     := x_dr_account_cd;
    new_references.cr_account_cd                     := x_cr_account_cd;
    new_references.dr_gl_ccid                        := x_dr_gl_ccid;
    new_references.cr_gl_ccid                        := x_cr_gl_ccid;
    new_references.bill_id                           := x_bill_id;
    new_references.bill_number                       := x_bill_number;
    new_references.bill_date                         := x_bill_date;
    new_references.posting_id                        := x_posting_id;
    new_references.gl_date                           := TRUNC(x_gl_date);
    new_references.gl_posted_date                    := x_gl_posted_date;
    new_references.posting_control_id                := x_posting_control_id;


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
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ((old_references.cr_account_cd = new_references.cr_account_cd) OR
         (new_references.cr_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.cr_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((old_references.dr_account_cd = new_references.dr_account_cd) OR
         (new_references.dr_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.dr_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.status = new_references.status)) OR
        ((new_references.status IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_CREDIT_STATUS',
          new_references.status
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
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

    IF (((old_references.credit_id = new_references.credit_id)) OR
        ((new_references.credit_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_credits_pkg.get_pk_for_validation (
                new_references.credit_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.posting_id = new_references.posting_id)) OR
        ((new_references.posting_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_posting_int_pkg.get_pk_for_validation (
                new_references.posting_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko        04-Dec-2002     Added call to igs_fi_bill_dpsts_pkg, Bug# 2584741
  */
  BEGIN

    igs_fi_applications_pkg.get_fk_igs_fi_cr_activities (
      old_references.credit_activity_id
    );

    igs_fi_bill_trnsctns_pkg.get_fk_igs_fi_cr_activities (
      old_references.credit_activity_id
    );

    igs_fi_bill_dpsts_pkg.get_fk_igs_fi_cr_activities (
      old_references.credit_activity_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_credit_activity_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_cr_activities
      WHERE    credit_activity_id = x_credit_activity_id
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
      fnd_message.set_name ('IGS', 'IGS_FI_CRAC_FBLLA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_bill;

  PROCEDURE get_fk_igs_fi_credits_all (
    x_credit_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_cr_activities
      WHERE   ((credit_id = x_credit_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_CRAC_CRTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_credits_all;


  PROCEDURE get_fk_igs_fi_posting_int_all (
    x_posting_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_cr_activities
      WHERE   ((posting_id = x_posting_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_CRAC_PINT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_posting_int_all;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER ,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_creation_date                     IN     DATE ,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE ,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER

  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_credit_activity_id,
      x_credit_id,
      x_status,
      x_transaction_date,
      x_amount,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_bill_id,
      x_bill_number,
      x_bill_date,
      x_posting_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_gl_date,
      x_gl_posted_date,
      x_posting_control_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.credit_activity_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.credit_activity_id
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
    x_credit_activity_id                IN OUT NOCOPY NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_cr_activities
      WHERE    credit_activity_id                = x_credit_activity_id;

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

    SELECT    igs_fi_cr_activities_s.NEXTVAL
    INTO      x_credit_activity_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_credit_activity_id                => x_credit_activity_id,
      x_credit_id                         => x_credit_id,
      x_status                            => x_status,
      x_transaction_date                  => x_transaction_date,
      x_amount                            => x_amount,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_bill_id                           => x_bill_id,
      x_bill_number                       => x_bill_number,
      x_bill_date                         => x_bill_date,
      x_posting_id                        => x_posting_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_gl_date                           => x_gl_date,
      x_gl_posted_date                    => x_gl_posted_date,
      x_posting_control_id                => x_posting_control_id
    );

    INSERT INTO igs_fi_cr_activities (
      credit_activity_id,
      credit_id,
      status,
      transaction_date,
      amount,
      dr_account_cd,
      cr_account_cd,
      dr_gl_ccid,
      cr_gl_ccid,
      bill_id,
      bill_number,
      bill_date,
      posting_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      gl_date,
      gl_posted_date,
      posting_control_id
    ) VALUES (
      new_references.credit_activity_id,
      new_references.credit_id,
      new_references.status,
      new_references.transaction_date,
      new_references.amount,
      new_references.dr_account_cd,
      new_references.cr_account_cd,
      new_references.dr_gl_ccid,
      new_references.cr_gl_ccid,
      new_references.bill_id,
      new_references.bill_number,
      new_references.bill_date,
      new_references.posting_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.gl_date,
      new_references.gl_posted_date,
      new_references.posting_control_id
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
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat     30-Dec-2002        Bug: 2728036 - Added TRUNC while comparing dates
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        credit_id,
        status,
        transaction_date,
        amount,
        dr_account_cd,
        cr_account_cd,
        dr_gl_ccid,
        cr_gl_ccid,
        bill_id,
        bill_number,
        bill_date,
        posting_id ,
        gl_date,
        gl_posted_date,
        posting_control_id
      FROM  igs_fi_cr_activities
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
        (tlinfo.credit_id = x_credit_id)
        AND (tlinfo.status = x_status)
        AND (TRUNC(tlinfo.transaction_date) = TRUNC(x_transaction_date))
        AND (tlinfo.amount = x_amount)
        AND ((tlinfo.dr_account_cd = x_dr_account_cd) OR ((tlinfo.dr_account_cd IS NULL) AND (X_dr_account_cd IS NULL)))
        AND ((tlinfo.cr_account_cd = x_cr_account_cd) OR ((tlinfo.cr_account_cd IS NULL) AND (X_cr_account_cd IS NULL)))
        AND ((tlinfo.dr_gl_ccid = x_dr_gl_ccid) OR ((tlinfo.dr_gl_ccid IS NULL) AND (X_dr_gl_ccid IS NULL)))
        AND ((tlinfo.cr_gl_ccid = x_cr_gl_ccid) OR ((tlinfo.cr_gl_ccid IS NULL) AND (X_cr_gl_ccid IS NULL)))
        AND ((tlinfo.bill_id = x_bill_id) OR ((tlinfo.bill_id IS NULL) AND (X_bill_id IS NULL)))
        AND ((tlinfo.bill_number = x_bill_number) OR ((tlinfo.bill_number IS NULL) AND (X_bill_number IS NULL)))
        AND ((TRUNC(tlinfo.bill_date) = TRUNC(x_bill_date)) OR ((tlinfo.bill_date IS NULL) AND (X_bill_date IS NULL)))
        AND ((tlinfo.posting_id = x_posting_id) OR ((tlinfo.posting_id IS NULL) AND (X_posting_id IS NULL)))
        AND ((TRUNC(tlinfo.gl_date) = TRUNC(x_gl_date)) OR ((tlinfo.gl_date IS NULL) AND (X_gl_date IS NULL)))
        AND ((TRUNC(tlinfo.gl_posted_date) = TRUNC(x_gl_posted_date)) OR ((tlinfo.gl_posted_date IS NULL) AND (X_gl_posted_date IS NULL)))
        AND ((tlinfo.posting_control_id = x_posting_control_id) OR ((tlinfo.posting_control_id IS NULL) AND (X_posting_control_id IS NULL)))
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
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
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
      x_credit_activity_id                => x_credit_activity_id,
      x_credit_id                         => x_credit_id,
      x_status                            => x_status,
      x_transaction_date                  => x_transaction_date,
      x_amount                            => x_amount,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_bill_id                           => x_bill_id,
      x_bill_number                       => x_bill_number,
      x_bill_date                         => x_bill_date,
      x_posting_id                        => x_posting_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_gl_date                           => x_gl_date,
      x_gl_posted_date                    => x_gl_posted_date,
      x_posting_control_id                => x_posting_control_id
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

    UPDATE igs_fi_cr_activities
      SET
        credit_id                         = new_references.credit_id,
        status                            = new_references.status,
        transaction_date                  = new_references.transaction_date,
        amount                            = new_references.amount,
        dr_account_cd                     = new_references.dr_account_cd,
        cr_account_cd                     = new_references.cr_account_cd,
        dr_gl_ccid                        = new_references.dr_gl_ccid,
        cr_gl_ccid                        = new_references.cr_gl_ccid,
        bill_id                           = new_references.bill_id,
        bill_number                       = new_references.bill_number,
        bill_date                         = new_references.bill_date,
        posting_id                        = new_references.posting_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
	gl_date                           = new_references.gl_date,
        gl_posted_date                    = new_references.gl_posted_date,
        posting_control_id                = new_references.posting_control_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_activity_id                IN OUT NOCOPY NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_gl_date                           IN     DATE,
    x_gl_posted_date                    IN     DATE ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
  ||                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_cr_activities
      WHERE    credit_activity_id                = x_credit_activity_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_credit_activity_id,
        x_credit_id,
        x_status,
        x_transaction_date,
        x_amount,
        x_dr_account_cd,
        x_cr_account_cd,
        x_dr_gl_ccid,
        x_cr_gl_ccid,
        x_bill_id,
        x_bill_number,
        x_bill_date,
        x_posting_id,
        x_mode,
	x_gl_date,
	x_gl_posted_date,
	x_posting_control_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_credit_activity_id,
      x_credit_id,
      x_status,
      x_transaction_date,
      x_amount,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_bill_id,
      x_bill_number,
      x_bill_date,
      x_posting_id,
      x_mode ,
      x_gl_date,
      x_gl_posted_date,
      x_posting_control_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
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

    DELETE FROM igs_fi_cr_activities
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_cr_activities_pkg;

/
