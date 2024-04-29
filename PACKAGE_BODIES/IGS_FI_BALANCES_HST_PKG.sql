--------------------------------------------------------
--  DDL for Package Body IGS_FI_BALANCES_HST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BALANCES_HST_PKG" AS
/* $Header: IGSSIC6B.pls 115.5 2003/03/04 10:00:48 shtatiko noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_balances_hst%ROWTYPE;
  new_references igs_fi_balances_hst%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_balance_hist_id                   IN     NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_balances_hst
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
    new_references.balance_hist_id                   := x_balance_hist_id;
    new_references.balance_id                        := x_balance_id;
    new_references.balance_type                      := x_balance_type;
    new_references.balance_amount                    := x_balance_amount;
    new_references.balance_rule_id                   := x_balance_rule_id;

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
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.balance_id = new_references.balance_id)) OR
        ((new_references.balance_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_balances_pkg.get_pk_for_validation (
                new_references.balance_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_balance_hist_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_balances_hst
      WHERE    balance_hist_id = x_balance_hist_id
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


  PROCEDURE get_fk_igs_fi_balances (
    x_balance_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_balances_hst
      WHERE   ((balance_id = x_balance_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIBH_FIB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_balances;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_balance_hist_id                   IN     NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
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
      x_balance_hist_id,
      x_balance_id,
      x_balance_type,
      x_balance_amount,
      x_balance_rule_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.balance_hist_id
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
             new_references.balance_hist_id
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
    x_balance_hist_id                   IN OUT NOCOPY NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shtatiko        27-FEB-2003     Bug# 2815373, Next value of the sequence (igs_fi_balances_hst_s.NEXTVAL)
  ||                                  is fetched before the call to before_dml. Previously, this was done in the
  ||                                  insert statement itself.
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- Added this as part of Bug fix 2815373.
    -- Sequence's NEXTVAL should be fetched before calling before_dml.

    SELECT igs_fi_balances_hst_s.NEXTVAL INTO x_balance_hist_id
    FROM dual;

    -- Fetched value is passed to before_dml so that check for existence of id is done for the
    -- newly generated Id.

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_balance_hist_id                   => x_balance_hist_id,
      x_balance_id                        => x_balance_id,
      x_balance_type                      => x_balance_type,
      x_balance_amount                    => x_balance_amount,
      x_balance_rule_id                   => x_balance_rule_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    -- Bug# 2815373, Removed x_balance_hist_id from RETURNING clause as it is determined above.
    INSERT INTO igs_fi_balances_hst (
      balance_hist_id,
      balance_id,
      balance_type,
      balance_amount,
      balance_rule_id,
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
      new_references.balance_hist_id,
      new_references.balance_id,
      new_references.balance_type,
      new_references.balance_amount,
      new_references.balance_rule_id,
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
    x_balance_hist_id                   IN     NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        balance_id,
        balance_type,
        balance_amount,
        balance_rule_id
      FROM  igs_fi_balances_hst
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
        (tlinfo.balance_id = x_balance_id)
        AND ((tlinfo.balance_type = x_balance_type) OR ((tlinfo.balance_type IS NULL) AND (X_balance_type IS NULL)))
        AND ((tlinfo.balance_amount = x_balance_amount) OR ((tlinfo.balance_amount IS NULL) AND (X_balance_amount IS NULL)))
        AND ((tlinfo.balance_rule_id = x_balance_rule_id) OR ((tlinfo.balance_rule_id IS NULL) AND (X_balance_rule_id IS NULL)))
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
    x_balance_hist_id                   IN     NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
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
      x_balance_hist_id                   => x_balance_hist_id,
      x_balance_id                        => x_balance_id,
      x_balance_type                      => x_balance_type,
      x_balance_amount                    => x_balance_amount,
      x_balance_rule_id                   => x_balance_rule_id,
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

    UPDATE igs_fi_balances_hst
      SET
        balance_id                        = new_references.balance_id,
        balance_type                      = new_references.balance_type,
        balance_amount                    = new_references.balance_amount,
        balance_rule_id                   = new_references.balance_rule_id,
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
    x_balance_hist_id                   IN OUT NOCOPY NUMBER,
    x_balance_id                        IN     NUMBER,
    x_balance_type                      IN     VARCHAR2,
    x_balance_amount                    IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_balances_hst
      WHERE    balance_hist_id                   = x_balance_hist_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_balance_hist_id,
        x_balance_id,
        x_balance_type,
        x_balance_amount,
        x_balance_rule_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_balance_hist_id,
      x_balance_id,
      x_balance_type,
      x_balance_amount,
      x_balance_rule_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Priya Athipatla
  ||  Created On : 18-OCT-2002
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

    DELETE FROM igs_fi_balances_hst
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_balances_hst_pkg;

/
