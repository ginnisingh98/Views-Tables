--------------------------------------------------------
--  DDL for Package Body IGS_FI_LB_OVFL_ERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_LB_OVFL_ERRS_PKG" AS
/* $Header: IGSSID6B.pls 115.1 2003/06/23 05:03:16 agairola noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_lb_ovfl_errs%ROWTYPE;
  new_references igs_fi_lb_ovfl_errs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_lb_ovfl_errs
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
    new_references.receipt_overflow_error_id         := x_receipt_overflow_error_id;
    new_references.lockbox_receipt_error_id          := x_lockbox_receipt_error_id;
    new_references.charge_cd1                        := x_charge_cd1;
    new_references.charge_cd2                        := x_charge_cd2;
    new_references.charge_cd3                        := x_charge_cd3;
    new_references.charge_cd4                        := x_charge_cd4;
    new_references.charge_cd5                        := x_charge_cd5;
    new_references.charge_cd6                        := x_charge_cd6;
    new_references.charge_cd7                        := x_charge_cd7;
    new_references.charge_cd8                        := x_charge_cd8;
    new_references.applied_amt1                      := x_applied_amt1;
    new_references.applied_amt2                      := x_applied_amt2;
    new_references.applied_amt3                      := x_applied_amt3;
    new_references.applied_amt4                      := x_applied_amt4;
    new_references.applied_amt5                      := x_applied_amt5;
    new_references.applied_amt6                      := x_applied_amt6;
    new_references.applied_amt7                      := x_applied_amt7;
    new_references.applied_amt8                      := x_applied_amt8;

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
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.lockbox_receipt_error_id = new_references.lockbox_receipt_error_id)) OR
        ((new_references.lockbox_receipt_error_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_lb_rect_errs_pkg.get_pk_for_validation (
                new_references.lockbox_receipt_error_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_receipt_overflow_error_id         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_lb_ovfl_errs
      WHERE    receipt_overflow_error_id = x_receipt_overflow_error_id
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


  PROCEDURE get_fk_igs_fi_lb_rect_errs (
    x_lockbox_receipt_error_id          IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_lb_ovfl_errs
      WHERE   ((lockbox_receipt_error_id = x_lockbox_receipt_error_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_LBOE_LBER_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_lb_rect_errs;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
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
      x_receipt_overflow_error_id,
      x_lockbox_receipt_error_id,
      x_charge_cd1,
      x_charge_cd2,
      x_charge_cd3,
      x_charge_cd4,
      x_charge_cd5,
      x_charge_cd6,
      x_charge_cd7,
      x_charge_cd8,
      x_applied_amt1,
      x_applied_amt2,
      x_applied_amt3,
      x_applied_amt4,
      x_applied_amt5,
      x_applied_amt6,
      x_applied_amt7,
      x_applied_amt8,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.receipt_overflow_error_id
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
             new_references.receipt_overflow_error_id
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
    x_receipt_overflow_error_id         IN OUT NOCOPY NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_LB_OVFL_ERRS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_receipt_overflow_error_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_receipt_overflow_error_id         => x_receipt_overflow_error_id,
      x_lockbox_receipt_error_id          => x_lockbox_receipt_error_id,
      x_charge_cd1                        => x_charge_cd1,
      x_charge_cd2                        => x_charge_cd2,
      x_charge_cd3                        => x_charge_cd3,
      x_charge_cd4                        => x_charge_cd4,
      x_charge_cd5                        => x_charge_cd5,
      x_charge_cd6                        => x_charge_cd6,
      x_charge_cd7                        => x_charge_cd7,
      x_charge_cd8                        => x_charge_cd8,
      x_applied_amt1                      => x_applied_amt1,
      x_applied_amt2                      => x_applied_amt2,
      x_applied_amt3                      => x_applied_amt3,
      x_applied_amt4                      => x_applied_amt4,
      x_applied_amt5                      => x_applied_amt5,
      x_applied_amt6                      => x_applied_amt6,
      x_applied_amt7                      => x_applied_amt7,
      x_applied_amt8                      => x_applied_amt8,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_lb_ovfl_errs (
      receipt_overflow_error_id,
      lockbox_receipt_error_id,
      charge_cd1,
      charge_cd2,
      charge_cd3,
      charge_cd4,
      charge_cd5,
      charge_cd6,
      charge_cd7,
      charge_cd8,
      applied_amt1,
      applied_amt2,
      applied_amt3,
      applied_amt4,
      applied_amt5,
      applied_amt6,
      applied_amt7,
      applied_amt8,
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
      igs_fi_lb_ovfl_errs_s.NEXTVAL,
      new_references.lockbox_receipt_error_id,
      new_references.charge_cd1,
      new_references.charge_cd2,
      new_references.charge_cd3,
      new_references.charge_cd4,
      new_references.charge_cd5,
      new_references.charge_cd6,
      new_references.charge_cd7,
      new_references.charge_cd8,
      new_references.applied_amt1,
      new_references.applied_amt2,
      new_references.applied_amt3,
      new_references.applied_amt4,
      new_references.applied_amt5,
      new_references.applied_amt6,
      new_references.applied_amt7,
      new_references.applied_amt8,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, receipt_overflow_error_id INTO x_rowid, x_receipt_overflow_error_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        lockbox_receipt_error_id,
        charge_cd1,
        charge_cd2,
        charge_cd3,
        charge_cd4,
        charge_cd5,
        charge_cd6,
        charge_cd7,
        charge_cd8,
        applied_amt1,
        applied_amt2,
        applied_amt3,
        applied_amt4,
        applied_amt5,
        applied_amt6,
        applied_amt7,
        applied_amt8
      FROM  igs_fi_lb_ovfl_errs
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
        (tlinfo.lockbox_receipt_error_id = x_lockbox_receipt_error_id)
        AND ((tlinfo.charge_cd1 = x_charge_cd1) OR ((tlinfo.charge_cd1 IS NULL) AND (X_charge_cd1 IS NULL)))
        AND ((tlinfo.charge_cd2 = x_charge_cd2) OR ((tlinfo.charge_cd2 IS NULL) AND (X_charge_cd2 IS NULL)))
        AND ((tlinfo.charge_cd3 = x_charge_cd3) OR ((tlinfo.charge_cd3 IS NULL) AND (X_charge_cd3 IS NULL)))
        AND ((tlinfo.charge_cd4 = x_charge_cd4) OR ((tlinfo.charge_cd4 IS NULL) AND (X_charge_cd4 IS NULL)))
        AND ((tlinfo.charge_cd5 = x_charge_cd5) OR ((tlinfo.charge_cd5 IS NULL) AND (X_charge_cd5 IS NULL)))
        AND ((tlinfo.charge_cd6 = x_charge_cd6) OR ((tlinfo.charge_cd6 IS NULL) AND (X_charge_cd6 IS NULL)))
        AND ((tlinfo.charge_cd7 = x_charge_cd7) OR ((tlinfo.charge_cd7 IS NULL) AND (X_charge_cd7 IS NULL)))
        AND ((tlinfo.charge_cd8 = x_charge_cd8) OR ((tlinfo.charge_cd8 IS NULL) AND (X_charge_cd8 IS NULL)))
        AND ((tlinfo.applied_amt1 = x_applied_amt1) OR ((tlinfo.applied_amt1 IS NULL) AND (X_applied_amt1 IS NULL)))
        AND ((tlinfo.applied_amt2 = x_applied_amt2) OR ((tlinfo.applied_amt2 IS NULL) AND (X_applied_amt2 IS NULL)))
        AND ((tlinfo.applied_amt3 = x_applied_amt3) OR ((tlinfo.applied_amt3 IS NULL) AND (X_applied_amt3 IS NULL)))
        AND ((tlinfo.applied_amt4 = x_applied_amt4) OR ((tlinfo.applied_amt4 IS NULL) AND (X_applied_amt4 IS NULL)))
        AND ((tlinfo.applied_amt5 = x_applied_amt5) OR ((tlinfo.applied_amt5 IS NULL) AND (X_applied_amt5 IS NULL)))
        AND ((tlinfo.applied_amt6 = x_applied_amt6) OR ((tlinfo.applied_amt6 IS NULL) AND (X_applied_amt6 IS NULL)))
        AND ((tlinfo.applied_amt7 = x_applied_amt7) OR ((tlinfo.applied_amt7 IS NULL) AND (X_applied_amt7 IS NULL)))
        AND ((tlinfo.applied_amt8 = x_applied_amt8) OR ((tlinfo.applied_amt8 IS NULL) AND (X_applied_amt8 IS NULL)))
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
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_LB_OVFL_ERRS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_receipt_overflow_error_id         => x_receipt_overflow_error_id,
      x_lockbox_receipt_error_id          => x_lockbox_receipt_error_id,
      x_charge_cd1                        => x_charge_cd1,
      x_charge_cd2                        => x_charge_cd2,
      x_charge_cd3                        => x_charge_cd3,
      x_charge_cd4                        => x_charge_cd4,
      x_charge_cd5                        => x_charge_cd5,
      x_charge_cd6                        => x_charge_cd6,
      x_charge_cd7                        => x_charge_cd7,
      x_charge_cd8                        => x_charge_cd8,
      x_applied_amt1                      => x_applied_amt1,
      x_applied_amt2                      => x_applied_amt2,
      x_applied_amt3                      => x_applied_amt3,
      x_applied_amt4                      => x_applied_amt4,
      x_applied_amt5                      => x_applied_amt5,
      x_applied_amt6                      => x_applied_amt6,
      x_applied_amt7                      => x_applied_amt7,
      x_applied_amt8                      => x_applied_amt8,
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

    UPDATE igs_fi_lb_ovfl_errs
      SET
        lockbox_receipt_error_id          = new_references.lockbox_receipt_error_id,
        charge_cd1                        = new_references.charge_cd1,
        charge_cd2                        = new_references.charge_cd2,
        charge_cd3                        = new_references.charge_cd3,
        charge_cd4                        = new_references.charge_cd4,
        charge_cd5                        = new_references.charge_cd5,
        charge_cd6                        = new_references.charge_cd6,
        charge_cd7                        = new_references.charge_cd7,
        charge_cd8                        = new_references.charge_cd8,
        applied_amt1                      = new_references.applied_amt1,
        applied_amt2                      = new_references.applied_amt2,
        applied_amt3                      = new_references.applied_amt3,
        applied_amt4                      = new_references.applied_amt4,
        applied_amt5                      = new_references.applied_amt5,
        applied_amt6                      = new_references.applied_amt6,
        applied_amt7                      = new_references.applied_amt7,
        applied_amt8                      = new_references.applied_amt8,
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

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
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

    DELETE FROM igs_fi_lb_ovfl_errs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_lb_ovfl_errs_pkg;

/
