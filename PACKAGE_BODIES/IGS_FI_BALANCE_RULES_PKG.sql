--------------------------------------------------------
--  DDL for Package Body IGS_FI_BALANCE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BALANCE_RULES_PKG" AS
/* $Header: IGSSI95B.pls 115.9 2003/02/14 05:34:10 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_balance_rules%ROWTYPE;
  new_references igs_fi_balance_rules%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_balance_rule_id                   IN     NUMBER  ,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_last_conversion_date              IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_BALANCE_RULES
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
    new_references.balance_rule_id                   := x_balance_rule_id;
    new_references.balance_name                      := x_balance_name;
    new_references.version_number                    := x_version_number;
    new_references.last_conversion_date              := x_last_conversion_date;

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

  PROCEDURE check_constraints (
                               column_name  IN  VARCHAR2,
                               column_value IN	VARCHAR2
                              )AS
 /*----------------------------------------------------------------------------
  ||  Created By : vvutukur
  ||  Created On : 05/05/2002
  ||  Purpose : To prevent defining exclusion rules for Standard Balances for
  ||            bug:2329042
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smadathi    30-sep-2002   Bug 2562745. Included constraint conditions for
  ||                           OTHER and INSTALLMENT balance types
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF column_name is NULL THEN
      NULL;
    ELSIF upper(column_name) = 'BALANCE_NAME' THEN
      new_references.balance_name := column_value;
    END IF;

    IF (UPPER(column_name) = 'BALANCE_NAME' OR
        column_name is NULL) THEN
        IF new_references.balance_name  IN ('STANDARD','OTHER','INSTALLMENT') THEN
          fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
    END IF;

  END check_constraints;

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

    IF (((old_references.balance_name = new_references.balance_name)) OR
        ((new_references.balance_name IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_BALANCE_TYPE',
          new_references.balance_name
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_balance_rule_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who         When           What
  ||  pathipat    14-Feb-2003    Enh 2747325 - Locking Issues build
  ||                             Removed FOR UPDATE NOWAIT clause
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_balance_rules
      WHERE    balance_rule_id = x_balance_rule_id ;

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
    x_balance_rule_id                   IN     NUMBER  ,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER  ,
    x_last_conversion_date              IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat       14-Feb-2003      Enh 2747325 - Locking Issues Build
  ||                                  Removed code for p_action = DELETE and VALIDATE_DELETE
  ||  vvutukur       03-may-2002     called check_constrainsts for bug:2329042.
  ||  (reverse chronological order - newest change first)
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_balance_rule_id,
      x_balance_name,
      x_version_number,
      x_last_conversion_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.balance_rule_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.balance_rule_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_rule_id                   IN OUT NOCOPY NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_balance_rules
      WHERE    balance_rule_id                   = x_balance_rule_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_fi_balance_rules_s.NEXTVAL
    INTO      x_balance_rule_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_balance_rule_id                   => x_balance_rule_id,
      x_balance_name                      => x_balance_name,
      x_version_number                    => x_version_number,
      x_last_conversion_date              => x_last_conversion_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_balance_rules (
      balance_rule_id,
      balance_name,
      version_number,
      last_conversion_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.balance_rule_id,
      new_references.balance_name,
      new_references.version_number,
      new_references.last_conversion_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
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
    x_balance_rule_id                   IN     NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
            balance_name,
            version_number,
            last_conversion_date
      FROM  igs_fi_balance_rules
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
        (tlinfo.balance_name = x_balance_name)
        AND (tlinfo.version_number = x_version_number)
	AND ((tlinfo.last_conversion_date = x_last_conversion_date) OR ((tlinfo.last_conversion_date IS NULL) AND (X_last_conversion_date IS NULL)))
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
    x_balance_rule_id                   IN     NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
      x_balance_rule_id                   => x_balance_rule_id,
      x_balance_name                      => x_balance_name,
      x_version_number                    => x_version_number,
      x_last_conversion_date              => x_last_conversion_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_balance_rules
      SET
        balance_name                      = new_references.balance_name,
        version_number                    = new_references.version_number,
	last_conversion_date              = new_references.last_conversion_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_rule_id                   IN OUT NOCOPY NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi   30-sep-2002   Bug 2562745. All references to columns effective_start_date,effective_end_date,
  ||                           exclude_txn_date_low,exclude_txn_date_high,exclude_eff_date_low,exclude_eff_date_high
  ||                           removed. Column last_conversion_date added newly
  ||  vvutukur   24-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_balance_rules
      WHERE    balance_rule_id                   = x_balance_rule_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_balance_rule_id,
        x_balance_name,
        x_version_number,
	x_last_conversion_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_balance_rule_id,
      x_balance_name,
      x_version_number,
      x_last_conversion_date,
      x_mode
    );

  END add_row;

END igs_fi_balance_rules_pkg;

/
