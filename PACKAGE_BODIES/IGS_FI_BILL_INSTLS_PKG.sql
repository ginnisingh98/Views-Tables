--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_INSTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_INSTLS_PKG" AS
/* $Header: IGSSIE4B.pls 115.0 2003/08/26 07:22:23 smvk noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_bill_instls%ROWTYPE;
  new_references igs_fi_bill_instls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_bill_instls
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
    new_references.student_plan_id                   := x_student_plan_id;
    new_references.bill_id                           := x_bill_id;
    new_references.installment_id                    := x_installment_id;
    new_references.installment_line_num              := x_installment_line_num;
    new_references.installment_due_date              := x_installment_due_date;
    new_references.installment_amt                   := x_installment_amt;
    new_references.due_amt                           := x_due_amt;

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
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.student_plan_id = new_references.student_plan_id)) OR
        ((new_references.student_plan_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_pp_std_attrs_pkg.get_pk_for_validation (
                new_references.student_plan_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.student_plan_id = new_references.student_plan_id) AND
         (old_references.bill_id = new_references.bill_id)) OR
        ((new_references.student_plan_id IS NULL) OR
         (new_references.bill_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_bill_p_plans_pkg.get_pk_for_validation (
                new_references.student_plan_id,
                new_references.bill_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.installment_id = new_references.installment_id)) OR
        ((new_references.installment_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_pp_instlmnts_pkg.get_pk_for_validation (
                new_references.installment_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_instls
      WHERE    student_plan_id = x_student_plan_id
      AND      bill_id = x_bill_id
      AND      installment_id = x_installment_id;

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
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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
      x_student_plan_id,
      x_bill_id,
      x_installment_id,
      x_installment_line_num,
      x_installment_due_date,
      x_installment_amt,
      x_due_amt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.student_plan_id,
             new_references.bill_id,
             new_references.installment_id
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
             new_references.student_plan_id,
             new_references.bill_id,
             new_references.installment_id
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
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_BILL_INSTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_student_plan_id                   => x_student_plan_id,
      x_bill_id                           => x_bill_id,
      x_installment_id                    => x_installment_id,
      x_installment_line_num              => x_installment_line_num,
      x_installment_due_date              => x_installment_due_date,
      x_installment_amt                   => x_installment_amt,
      x_due_amt                           => x_due_amt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_bill_instls (
      student_plan_id,
      bill_id,
      installment_id,
      installment_line_num,
      installment_due_date,
      installment_amt,
      due_amt,
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
      new_references.student_plan_id,
      new_references.bill_id,
      new_references.installment_id,
      new_references.installment_line_num,
      new_references.installment_due_date,
      new_references.installment_amt,
      new_references.due_amt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        installment_line_num,
        installment_due_date,
        installment_amt,
        due_amt
      FROM  igs_fi_bill_instls
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
        (tlinfo.installment_line_num = x_installment_line_num)
        AND (tlinfo.installment_due_date = x_installment_due_date)
        AND (tlinfo.installment_amt = x_installment_amt)
        AND (tlinfo.due_amt = x_due_amt)
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
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_BILL_INSTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_student_plan_id                   => x_student_plan_id,
      x_bill_id                           => x_bill_id,
      x_installment_id                    => x_installment_id,
      x_installment_line_num              => x_installment_line_num,
      x_installment_due_date              => x_installment_due_date,
      x_installment_amt                   => x_installment_amt,
      x_due_amt                           => x_due_amt,
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

    UPDATE igs_fi_bill_instls
      SET
        installment_line_num              = new_references.installment_line_num,
        installment_due_date              = new_references.installment_due_date,
        installment_amt                   = new_references.installment_amt,
        due_amt                           = new_references.due_amt,
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
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_installment_id                    IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_installment_due_date              IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_bill_instls
      WHERE    student_plan_id                   = x_student_plan_id
      AND      bill_id                           = x_bill_id
      AND      installment_id                    = x_installment_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_student_plan_id,
        x_bill_id,
        x_installment_id,
        x_installment_line_num,
        x_installment_due_date,
        x_installment_amt,
        x_due_amt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_student_plan_id,
      x_bill_id,
      x_installment_id,
      x_installment_line_num,
      x_installment_due_date,
      x_installment_amt,
      x_due_amt,
      x_mode
    );

  END add_row;

END igs_fi_bill_instls_pkg;

/
