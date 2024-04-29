--------------------------------------------------------
--  DDL for Package Body IGS_FI_POSTING_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_POSTING_INT_PKG" AS
/* $Header: IGSSIA1B.pls 115.13 2003/02/17 09:14:52 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_posting_int_all%ROWTYPE;
  new_references igs_fi_posting_int_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_posting_id                        IN     NUMBER      ,
    x_batch_name                        IN     VARCHAR2    ,
    x_accounting_date                   IN     DATE        ,
    x_transaction_date                  IN     DATE        ,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_POSTING_INT_ALL
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
    new_references.posting_id                        := x_posting_id;
    new_references.batch_name                        := x_batch_name;
    new_references.accounting_date                   := x_accounting_date;
    new_references.transaction_date                  := x_transaction_date;
    new_references.currency_cd                       := x_currency_cd;
    new_references.dr_account_cd                     := x_dr_account_cd;
    new_references.cr_account_cd                     := x_cr_account_cd;
    new_references.dr_gl_code_ccid                   := x_dr_gl_code_ccid;
    new_references.cr_gl_code_ccid                   := x_cr_gl_code_ccid;
    new_references.amount                            := x_amount;
    new_references.source_transaction_id             := x_source_transaction_id;
    new_references.source_transaction_type           := x_source_transaction_type;
    new_references.status                            := x_status;
    new_references.orig_appl_fee_ref                 := x_orig_appl_fee_ref;
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

    IF (((old_references.source_transaction_type = new_references.source_transaction_type)) OR
        ((new_references.source_transaction_type IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_SOURCE_TRANSACTION_TYPE',
          new_references.source_transaction_type
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

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

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_applications_pkg.get_fk_igs_fi_posting_int_all (
      old_references.posting_id
    );

    igs_fi_cr_activities_pkg.get_fk_igs_fi_posting_int_all (
      old_references.posting_id
    );

    igs_fi_invln_int_pkg.get_fk_igs_fi_posting_int_all (
      old_references.posting_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_posting_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_posting_int_all
      WHERE    posting_id = x_posting_id
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
    x_rowid                             IN     VARCHAR2    ,
    x_posting_id                        IN     NUMBER      ,
    x_batch_name                        IN     VARCHAR2    ,
    x_accounting_date                   IN     DATE        ,
    x_transaction_date                  IN     DATE        ,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_posting_id,
      x_batch_name,
      x_accounting_date,
      x_transaction_date,
      x_currency_cd,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_code_ccid,
      x_cr_gl_code_ccid,
      x_amount,
      x_source_transaction_id,
      x_source_transaction_type,
      x_status,
      x_orig_appl_fee_ref,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_posting_control_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.posting_id
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
             new_references.posting_id
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
    x_posting_id                        IN OUT NOCOPY NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_mode                              IN     VARCHAR2    ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_posting_int_all
      WHERE    posting_id                        = x_posting_id;

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

    SELECT    igs_fi_posting_int_s.NEXTVAL
    INTO      x_posting_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_posting_id                        => x_posting_id,
      x_batch_name                        => x_batch_name,
      x_accounting_date                   => x_accounting_date,
      x_transaction_date                  => x_transaction_date,
      x_currency_cd                       => x_currency_cd,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_code_ccid                   => x_dr_gl_code_ccid,
      x_cr_gl_code_ccid                   => x_cr_gl_code_ccid,
      x_amount                            => x_amount,
      x_source_transaction_id             => x_source_transaction_id,
      x_source_transaction_type           => x_source_transaction_type,
      x_status                            => x_status,
      x_orig_appl_fee_ref                 => x_orig_appl_fee_ref,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_posting_control_id                => x_posting_control_id
    );

    INSERT INTO igs_fi_posting_int_all (
      posting_id,
      batch_name,
      accounting_date,
      transaction_date,
      currency_cd,
      dr_account_cd,
      cr_account_cd,
      dr_gl_code_ccid,
      cr_gl_code_ccid,
      amount,
      source_transaction_id,
      source_transaction_type,
      status,
      orig_appl_fee_ref,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      posting_control_id
    ) VALUES (
      new_references.posting_id,
      new_references.batch_name,
      new_references.accounting_date,
      new_references.transaction_date,
      new_references.currency_cd,
      new_references.dr_account_cd,
      new_references.cr_account_cd,
      new_references.dr_gl_code_ccid,
      new_references.cr_gl_code_ccid,
      new_references.amount,
      new_references.source_transaction_id,
      new_references.source_transaction_type,
      new_references.status,
      new_references.orig_appl_fee_ref,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
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
    x_posting_id                        IN     NUMBER      ,
    x_batch_name                        IN     VARCHAR2    ,
    x_accounting_date                   IN     DATE        ,
    x_transaction_date                  IN     DATE        ,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_name,
        accounting_date,
        transaction_date,
        currency_cd,
        dr_account_cd,
        cr_account_cd,
        dr_gl_code_ccid,
        cr_gl_code_ccid,
        amount,
        source_transaction_id,
        source_transaction_type,
        status,
	orig_appl_fee_ref,
	posting_control_id
      FROM  igs_fi_posting_int_all
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
        (tlinfo.batch_name = x_batch_name)
        AND (tlinfo.accounting_date = x_accounting_date)
        AND (tlinfo.transaction_date = x_transaction_date)
        AND (tlinfo.currency_cd = x_currency_cd)
        AND ((tlinfo.dr_account_cd = x_dr_account_cd) OR ((tlinfo.dr_account_cd IS NULL) AND (X_dr_account_cd IS NULL)))
        AND ((tlinfo.cr_account_cd = x_cr_account_cd) OR ((tlinfo.cr_account_cd IS NULL) AND (X_cr_account_cd IS NULL)))
        AND ((tlinfo.dr_gl_code_ccid = x_dr_gl_code_ccid) OR ((tlinfo.dr_gl_code_ccid IS NULL) AND (X_dr_gl_code_ccid IS NULL)))
        AND ((tlinfo.cr_gl_code_ccid = x_cr_gl_code_ccid) OR ((tlinfo.cr_gl_code_ccid IS NULL) AND (X_cr_gl_code_ccid IS NULL)))
        AND ((tlinfo.amount = x_amount) OR ((tlinfo.amount IS NULL) AND (X_amount IS NULL)))
        AND ((tlinfo.source_transaction_id = x_source_transaction_id) OR ((tlinfo.source_transaction_id IS NULL) AND (X_source_transaction_id IS NULL)))
        AND ((tlinfo.source_transaction_type = x_source_transaction_type) OR ((tlinfo.source_transaction_type IS NULL) AND (X_source_transaction_type IS NULL)))
        AND ((tlinfo.status = x_status) OR ((tlinfo.status IS NULL) AND (X_status IS NULL)))
	AND ((tlinfo.orig_appl_fee_ref = x_orig_appl_fee_ref) OR ((tlinfo.orig_appl_fee_ref IS NULL) AND (x_orig_appl_fee_ref IS NULL)))
	AND ((tlinfo.posting_control_id = x_posting_control_id) OR ((tlinfo.posting_control_id IS NULL) AND (x_posting_control_id IS NULL)))
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
    x_posting_id                        IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_mode                              IN     VARCHAR2    ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
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
      x_posting_id                        => x_posting_id,
      x_batch_name                        => x_batch_name,
      x_accounting_date                   => x_accounting_date,
      x_transaction_date                  => x_transaction_date,
      x_currency_cd                       => x_currency_cd,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_dr_gl_code_ccid                   => x_dr_gl_code_ccid,
      x_cr_gl_code_ccid                   => x_cr_gl_code_ccid,
      x_amount                            => x_amount,
      x_source_transaction_id             => x_source_transaction_id,
      x_source_transaction_type           => x_source_transaction_type,
      x_status                            => x_status,
      x_orig_appl_fee_ref                 => x_orig_appl_fee_ref,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
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

    UPDATE igs_fi_posting_int_all
      SET
        batch_name                        = new_references.batch_name,
        accounting_date                   = new_references.accounting_date,
        transaction_date                  = new_references.transaction_date,
        currency_cd                       = new_references.currency_cd,
        dr_account_cd                     = new_references.dr_account_cd,
        cr_account_cd                     = new_references.cr_account_cd,
        dr_gl_code_ccid                   = new_references.dr_gl_code_ccid,
        cr_gl_code_ccid                   = new_references.cr_gl_code_ccid,
        amount                            = new_references.amount,
        source_transaction_id             = new_references.source_transaction_id,
        source_transaction_type           = new_references.source_transaction_type,
        status                            = new_references.status,
	orig_appl_fee_ref                 = new_references.orig_appl_fee_ref,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
	posting_control_id                = x_posting_control_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_posting_id                        IN OUT NOCOPY NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE        ,
    x_currency_cd                       IN     VARCHAR2    ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_dr_gl_code_ccid                   IN     NUMBER      ,
    x_cr_gl_code_ccid                   IN     NUMBER      ,
    x_amount                            IN     NUMBER      ,
    x_source_transaction_id             IN     NUMBER      ,
    x_source_transaction_type           IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_orig_appl_fee_ref                 IN     VARCHAR2    ,
    x_mode                              IN     VARCHAR2    ,
    x_posting_control_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column POSTING_CONTROL_ID. Also
  ||                                  removed DEFAULT  clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_posting_int_all
      WHERE    posting_id                        = x_posting_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_posting_id,
        x_batch_name,
        x_accounting_date,
        x_transaction_date,
        x_currency_cd,
        x_dr_account_cd,
        x_cr_account_cd,
        x_dr_gl_code_ccid,
        x_cr_gl_code_ccid,
        x_amount,
        x_source_transaction_id,
        x_source_transaction_type,
        x_status,
	x_orig_appl_fee_ref,
        x_mode ,
	x_posting_control_id
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_posting_id,
      x_batch_name,
      x_accounting_date,
      x_transaction_date,
      x_currency_cd,
      x_dr_account_cd,
      x_cr_account_cd,
      x_dr_gl_code_ccid,
      x_cr_gl_code_ccid,
      x_amount,
      x_source_transaction_id,
      x_source_transaction_type,
      x_status,
      x_orig_appl_fee_ref,
      x_mode ,
      x_posting_control_id
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 02-MAY-2001
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

    DELETE FROM igs_fi_posting_int_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_posting_int_pkg;

/
