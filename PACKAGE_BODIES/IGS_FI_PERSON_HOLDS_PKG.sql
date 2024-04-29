--------------------------------------------------------
--  DDL for Package Body IGS_FI_PERSON_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PERSON_HOLDS_PKG" AS
/* $Header: IGSSIB2B.pls 115.14 2003/09/19 12:31:18 smadathi ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_person_holds%ROWTYPE;
  new_references igs_fi_person_holds%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2 ,
    x_person_id                         IN     NUMBER   ,
    x_hold_plan_name                    IN     VARCHAR2 ,
    x_hold_type                         IN     VARCHAR2 ,
    x_hold_start_dt                     IN     DATE     ,
    x_process_start_dt                  IN     DATE     ,
    x_process_end_dt                    IN     DATE     ,
    x_offset_days                       IN     NUMBER   ,
    x_past_due_amount                   IN     NUMBER   ,
    x_fee_cal_type                      IN     VARCHAR2 ,
    x_fee_ci_sequence_number            IN     NUMBER   ,
    x_fee_type_invoice_amount           IN     NUMBER   ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_release_credit_id                 IN     NUMBER   ,
    x_student_plan_id                   IN     NUMBER   ,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_person_holds
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
    -- Removed balance_amount, Enh Bug: 2562745
    new_references.person_id                         := x_person_id;
    new_references.hold_plan_name                    := x_hold_plan_name;
    new_references.hold_type                         := x_hold_type;
    new_references.hold_start_dt                     := x_hold_start_dt;
    new_references.process_start_dt                  := x_process_start_dt;
    new_references.process_end_dt                    := x_process_end_dt;
    new_references.offset_days                       := x_offset_days;
    new_references.past_due_amount                   := x_past_due_amount;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.fee_type_invoice_amount           := x_fee_type_invoice_amount;
    new_references.release_credit_id                 := x_release_credit_id;
    new_references.student_plan_id                   := x_student_plan_id;
    new_references.last_instlmnt_due_date            := x_last_instlmnt_due_date;

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
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        11-Aug-2003     Enh 3076768 - Auto Release of Holds
  ||                                  Added check for release_credit_id
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
   ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.hold_plan_name = new_references.hold_plan_name)) OR
        ((new_references.hold_plan_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_hold_plan_pkg.get_pk_for_validation (
                new_references.hold_plan_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.hold_type = new_references.hold_type)) OR
        ((new_references.hold_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_encmb_type_pkg.get_pk_for_validation (
                new_references.hold_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.release_credit_id = new_references.release_credit_id)) OR
        ((new_references.release_credit_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_credits_pkg.get_pk_for_validation (
                  new_references.release_credit_id
          ) THEN
      fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE    person_id = x_person_id
      AND      hold_type = x_hold_type
      AND      hold_start_dt = x_hold_start_dt
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

  PROCEDURE get_fk_igs_fi_hold_plan (
    x_hold_plan_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE   ((hold_plan_name = x_hold_plan_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FPHL_FIHP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_hold_plan;


  PROCEDURE get_fk_igs_fi_encmb_type (
    x_encumbrance_type                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE   ((hold_type = x_encumbrance_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FPHL_ET_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_encmb_type;


  PROCEDURE get_fk_igs_fi_credits_all (
     x_release_credit_id                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 11-Aug-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE    credit_id = x_release_credit_id;

    lv_rowid   cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FPHL_CRDT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_credits_all;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE   ((fee_cal_type = x_cal_type) AND
               (fee_ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FPHL_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;

 PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  BEGIN
   IF ( p_inserting = TRUE OR (p_updating = TRUE AND new_references.hold_type <> old_references.hold_type) ) THEN
     IF  NOT igs_en_val_etde.enrp_val_et_closed(new_references.hold_type,p_message_name) THEN
        Fnd_Message.Set_Name('IGS', p_message_name);
    	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeInsertUpdate;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER  ,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE    ,
    x_process_start_dt                  IN     DATE    ,
    x_process_end_dt                    IN     DATE    ,
    x_offset_days                       IN     NUMBER  ,
    x_past_due_amount                   IN     NUMBER  ,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
    x_fee_type_invoice_amount           IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_release_credit_id                 IN     NUMBER  ,
    x_student_plan_id                   IN     NUMBER   ,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur      17-May-2002     Removed calls to check_constraints procedure
  ||                                as this procedure is removed from body and
  ||                                spec.also. BUG#2344826.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_person_id,
      x_hold_plan_name,
      x_hold_type,
      x_hold_start_dt,
      x_process_start_dt,
      x_process_end_dt,
      x_offset_days,
      x_past_due_amount,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type_invoice_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_release_credit_id,
      x_student_plan_id,
      x_last_instlmnt_due_date
    );

    IF (p_action = 'INSERT') THEN
       BeforeInsertUpdate(TRUE,FALSE);
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.hold_type,
             new_references.hold_start_dt
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
       BeforeInsertUpdate(FALSE,TRUE);
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id,
             new_references.hold_type,
             new_references.hold_start_dt
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
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE    person_id                         = x_person_id
      AND      hold_type                         = x_hold_type
      AND      hold_start_dt                     = x_hold_start_dt;

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
      x_person_id                         => x_person_id,
      x_hold_plan_name                    => x_hold_plan_name,
      x_hold_type                         => x_hold_type,
      x_hold_start_dt                     => x_hold_start_dt,
      x_process_start_dt                  => x_process_start_dt,
      x_process_end_dt                    => x_process_end_dt,
      x_offset_days                       => x_offset_days,
      x_past_due_amount                   => x_past_due_amount,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_type_invoice_amount           => x_fee_type_invoice_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_release_credit_id                 => x_release_credit_id,
      x_student_plan_id                   => x_student_plan_id,
      x_last_instlmnt_due_date            => x_last_instlmnt_due_date
    );

    INSERT INTO igs_fi_person_holds (
      person_id,
      hold_plan_name,
      hold_type,
      hold_start_dt,
      process_start_dt,
      process_end_dt,
      offset_days,
      past_due_amount,
      fee_cal_type,
      fee_ci_sequence_number,
      fee_type_invoice_amount,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      release_credit_id,
      student_plan_id        ,
      last_instlmnt_due_date
    ) VALUES (
      new_references.person_id,
      new_references.hold_plan_name,
      new_references.hold_type,
      new_references.hold_start_dt,
      new_references.process_start_dt,
      new_references.process_end_dt,
      new_references.offset_days,
      new_references.past_due_amount,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.fee_type_invoice_amount,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.release_credit_id,
      new_references.student_plan_id   ,
      new_references.last_instlmnt_due_date
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
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        hold_plan_name,
        process_start_dt,
        process_end_dt,
        offset_days,
        past_due_amount,
        fee_cal_type,
        fee_ci_sequence_number,
        fee_type_invoice_amount,
        release_credit_id,
        student_plan_id        ,
        last_instlmnt_due_date
      FROM  igs_fi_person_holds
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
        (tlinfo.hold_plan_name = x_hold_plan_name)
        AND (tlinfo.process_start_dt = x_process_start_dt)
        AND (tlinfo.process_end_dt = x_process_end_dt)
        AND ((tlinfo.offset_days = x_offset_days) OR ((tlinfo.offset_days IS NULL) AND (X_offset_days IS NULL)))
        AND (tlinfo.past_due_amount = x_past_due_amount)
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
        AND ((tlinfo.fee_type_invoice_amount = x_fee_type_invoice_amount) OR ((tlinfo.fee_type_invoice_amount IS NULL) AND (X_fee_type_invoice_amount IS NULL)))
        AND ((tlinfo.release_credit_id = x_release_credit_id) OR ((tlinfo.release_credit_id IS NULL) AND (x_release_credit_id IS NULL)))
        AND ((tlinfo.student_plan_id = x_student_plan_id) OR ((tlinfo.student_plan_id IS NULL) AND (x_student_plan_id IS NULL)))
        AND ((tlinfo.last_instlmnt_due_date = x_last_instlmnt_due_date) OR ((tlinfo.last_instlmnt_due_date IS NULL) AND (x_last_instlmnt_due_date IS NULL)))
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
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
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
      x_person_id                         => x_person_id,
      x_hold_plan_name                    => x_hold_plan_name,
      x_hold_type                         => x_hold_type,
      x_hold_start_dt                     => x_hold_start_dt,
      x_process_start_dt                  => x_process_start_dt,
      x_process_end_dt                    => x_process_end_dt,
      x_offset_days                       => x_offset_days,
      x_past_due_amount                   => x_past_due_amount,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_fee_type_invoice_amount           => x_fee_type_invoice_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_release_credit_id                 => x_release_credit_id,
      x_student_plan_id                   => x_student_plan_id,
      x_last_instlmnt_due_date            => x_last_instlmnt_due_date
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

    UPDATE igs_fi_person_holds
      SET
        hold_plan_name                    = new_references.hold_plan_name,
        process_start_dt                  = new_references.process_start_dt,
        process_end_dt                    = new_references.process_end_dt,
        offset_days                       = new_references.offset_days,
        past_due_amount                   = new_references.past_due_amount,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        fee_type_invoice_amount           = new_references.fee_type_invoice_amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        release_credit_id                 = new_references.release_credit_id,
        student_plan_id                   = new_references.student_plan_id,
        last_instlmnt_due_date            = new_references.last_instlmnt_due_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_hold_start_dt                     IN     DATE,
    x_process_start_dt                  IN     DATE,
    x_process_end_dt                    IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_past_due_amount                   IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_type_invoice_amount           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_release_credit_id                 IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_last_instlmnt_due_date            IN     DATE
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_person_holds
      WHERE    person_id                         = x_person_id
      AND      hold_type                         = x_hold_type
      AND      hold_start_dt                     = x_hold_start_dt;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_hold_plan_name,
        x_hold_type,
        x_hold_start_dt,
        x_process_start_dt,
        x_process_end_dt,
        x_offset_days,
        x_past_due_amount,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_fee_type_invoice_amount,
        x_mode,
        x_release_credit_id,
        x_student_plan_id        ,
        x_last_instlmnt_due_date
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_hold_plan_name,
      x_hold_type,
      x_hold_start_dt,
      x_process_start_dt,
      x_process_end_dt,
      x_offset_days,
      x_past_due_amount,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type_invoice_amount,
      x_mode,
      x_release_credit_id,
      x_student_plan_id        ,
      x_last_instlmnt_due_date
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 29-NOV-2001
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

    DELETE FROM igs_fi_person_holds
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_person_holds_pkg;

/
