--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_PKG" AS
/* $Header: IGSSIB6B.pls 115.9 2002/12/05 06:18:55 shtatiko ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_bill_all%ROWTYPE;
  new_references igs_fi_bill_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_BILL_ALL
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
    new_references.bill_id                           := x_bill_id;
    IF (x_bill_number IS NULL) THEN
      new_references.bill_number := TO_CHAR (x_bill_id);
    ELSE
      new_references.bill_number := x_bill_number;
    END IF;
    new_references.bill_date                         := x_bill_date;
    new_references.due_date                          := x_due_date;
    new_references.person_id                         := x_person_id;
    new_references.bill_from_date                    := x_bill_from_date;
    new_references.opening_balance                   := x_opening_balance;
    new_references.cut_off_date                      := x_cut_off_date;
    new_references.closing_balance                   := x_closing_balance;
    new_references.printed_flag                      := x_printed_flag;
    new_references.print_date                        := x_print_date;
    new_references.to_pay_amount                     := x_to_pay_amount;

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
           new_references.cut_off_date,
           new_references.person_id
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
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = new_references.person_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_rowid;
      FETCH cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
      ELSE
        CLOSE cur_rowid;
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shtatiko        04-Dec-2002     Enh# 2584741, Added igs_fi_bill_dpsts_pkg call.
  ||  vchappid        02-Apr-2002     Enh# 2293676, added get_fk_igs_fi_bill
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_bill_addr_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

    igs_fi_bill_trnsctns_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

    igs_fi_cr_activities_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

    igs_fi_inv_int_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

    igs_fi_bill_pln_crd_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

    igs_fi_bill_dpsts_pkg.get_fk_igs_fi_bill (
      old_references.bill_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_bill_id                           IN     NUMBER
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
      FROM     igs_fi_bill_all
      WHERE    bill_id = x_bill_id
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
    x_cut_off_date                      IN     DATE,
    x_person_id                         IN     NUMBER
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
      FROM     igs_fi_bill_all
      WHERE    cut_off_date = x_cut_off_date
      AND      person_id = x_person_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
        RETURN (TRUE);
    ELSE
        CLOSE cur_rowid;
        RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;

 PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
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
      FROM     igs_fi_bill_all
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_BILL_HZPART_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
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
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_bill_id,
      x_bill_number,
      x_bill_date,
      x_due_date,
      x_person_id,
      x_bill_from_date,
      x_opening_balance,
      x_cut_off_date,
      x_closing_balance,
      x_printed_flag,
      x_print_date,
      x_to_pay_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.bill_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.bill_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN OUT NOCOPY NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_bill_all
      WHERE    bill_id                           = x_bill_id;

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

    SELECT    igs_fi_bill_s.NEXTVAL
    INTO      x_bill_id
    FROM      dual;
    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_bill_id                           => x_bill_id,
      x_bill_number                       => x_bill_number,
      x_bill_date                         => x_bill_date,
      x_due_date                          => x_due_date,
      x_person_id                         => x_person_id,
      x_bill_from_date                    => x_bill_from_date,
      x_opening_balance                   => x_opening_balance,
      x_cut_off_date                      => x_cut_off_date,
      x_closing_balance                   => x_closing_balance,
      x_printed_flag                      => x_printed_flag,
      x_print_date                        => x_print_date,
      x_to_pay_amount                     => x_to_pay_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_bill_all (
      bill_id,
      org_id,
      bill_number,
      bill_date,
      due_date,
      person_id,
      bill_from_date,
      opening_balance,
      cut_off_date,
      closing_balance,
      printed_flag,
      print_date,
      to_pay_amount,
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
      new_references.bill_id,
      new_references.org_id,
      new_references.bill_number,
      new_references.bill_date,
      new_references.due_date,
      new_references.person_id,
      new_references.bill_from_date,
      new_references.opening_balance,
      new_references.cut_off_date,
      new_references.closing_balance,
      new_references.printed_flag,
      new_references.print_date,
      new_references.to_pay_amount,
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
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
  */
      CURSOR c1 IS
      SELECT
        bill_number,
        bill_date,
        due_date,
        person_id,
        bill_from_date,
        opening_balance,
        cut_off_date,
        closing_balance,
        printed_flag,
        print_date,
        to_pay_amount
      FROM  igs_fi_bill_all
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
        (tlinfo.bill_number = x_bill_number)
        AND (tlinfo.bill_date = x_bill_date)
        AND (tlinfo.due_date = x_due_date)
        AND (tlinfo.person_id = x_person_id)
        AND ((tlinfo.bill_from_date = x_bill_from_date) OR ((tlinfo.bill_from_date IS NULL) AND (X_bill_from_date IS NULL)))
        AND (tlinfo.opening_balance = x_opening_balance)
        AND (tlinfo.cut_off_date = x_cut_off_date)
        AND (tlinfo.closing_balance = x_closing_balance)
        AND (tlinfo.printed_flag = x_printed_flag)
        AND ((tlinfo.print_date = x_print_date) OR ((tlinfo.print_date IS NULL) AND (X_print_date IS NULL)))
        AND ((tlinfo.to_pay_amount = x_to_pay_amount) OR ((tlinfo.to_pay_amount IS NULL) AND (x_to_pay_amount IS NULL)))
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
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
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
      x_bill_id                           => x_bill_id,
      x_bill_number                       => x_bill_number,
      x_bill_date                         => x_bill_date,
      x_due_date                          => x_due_date,
      x_person_id                         => x_person_id,
      x_bill_from_date                    => x_bill_from_date,
      x_opening_balance                   => x_opening_balance,
      x_cut_off_date                      => x_cut_off_date,
      x_closing_balance                   => x_closing_balance,
      x_printed_flag                      => x_printed_flag,
      x_print_date                        => x_print_date,
      x_to_pay_amount                     => x_to_pay_amount,
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

    UPDATE igs_fi_bill_all
      SET
        bill_number                       = new_references.bill_number,
        bill_date                         = new_references.bill_date,
        due_date                          = new_references.due_date,
        person_id                         = new_references.person_id,
        bill_from_date                    = new_references.bill_from_date,
        opening_balance                   = new_references.opening_balance,
        cut_off_date                      = new_references.cut_off_date,
        closing_balance                   = new_references.closing_balance,
        printed_flag                      = new_references.printed_flag,
        print_date                        = new_references.print_date,
        to_pay_amount                     = new_references.to_pay_amount,
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
    x_bill_id                           IN OUT NOCOPY NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_due_date                          IN     DATE,
    x_person_id                         IN     NUMBER,
    x_bill_from_date                    IN     DATE,
    x_opening_balance                   IN     NUMBER,
    x_cut_off_date                      IN     DATE,
    x_closing_balance                   IN     NUMBER,
    x_printed_flag                      IN     VARCHAR2,
    x_print_date                        IN     DATE,
    x_to_pay_amount                     IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vchappid        02-Apr-2002     Enh# bug2293676, added new column
  ||                                  to_pay_amount
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_bill_all
      WHERE    bill_id                           = x_bill_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_bill_id,
        x_bill_number,
        x_bill_date,
        x_due_date,
        x_person_id,
        x_bill_from_date,
        x_opening_balance,
        x_cut_off_date,
        x_closing_balance,
        x_printed_flag,
        x_print_date,
        x_to_pay_amount,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_bill_id,
      x_bill_number,
      x_bill_date,
      x_due_date,
      x_person_id,
      x_bill_from_date,
      x_opening_balance,
      x_cut_off_date,
      x_closing_balance,
      x_printed_flag,
      x_print_date,
      x_to_pay_amount,
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

    DELETE FROM igs_fi_bill_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_bill_pkg;

/
