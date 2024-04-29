--------------------------------------------------------
--  DDL for Package Body IGS_FI_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BALANCES_PKG" AS
/* $Header: IGSSI99B.pls 115.12 2003/02/14 07:32:31 pathipat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_balances%ROWTYPE;
  new_references igs_fi_balances%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_balance_id                        IN     NUMBER      ,
    x_party_id                          IN     NUMBER      ,
    x_standard_balance                  IN     NUMBER      ,
    x_fee_balance                       IN     NUMBER      ,
    x_holds_balance                     IN     NUMBER      ,
    x_balance_date                      IN     DATE        ,
    x_fee_balance_rule_id               IN     NUMBER      ,
    x_holds_balance_rule_id             IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
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
  || pathipat        30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  || smvk            17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_BALANCES
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
    new_references.balance_id                        := x_balance_id;
    new_references.party_id                          := x_party_id;
    new_references.standard_balance                  := x_standard_balance;
    new_references.fee_balance                       := x_fee_balance;
    new_references.holds_balance                     := x_holds_balance;
    new_references.balance_date                      := x_balance_date;
    new_references.fee_balance_rule_id               := x_fee_balance_rule_id;
    new_references.holds_balance_rule_id             := x_holds_balance_rule_id;

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
  || pathipat        14-Feb-2003     Enh 2747325 - Removed FOR UPDATE NOWAIT clause
  ||                                 in cursor cur_rowid
  || pathipat        30-SEP-2002     Obsoleted columns other_balance_rule_id and
  ||                                 installment_balance_rule_id for Enh Bug # 2562745
  || smvk            17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
  */

   CURSOR cur_rowid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = new_references.party_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    IF (((old_references.party_id = new_references.party_id)) OR
        ((new_references.party_id IS NULL))) THEN
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

    IF (((old_references.fee_balance_rule_id = new_references.fee_balance_rule_id)) OR
        ((new_references.fee_balance_rule_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_balance_rules_pkg.get_pk_for_validation (
                new_references.fee_balance_rule_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.holds_balance_rule_id = new_references.holds_balance_rule_id)) OR
        ((new_references.holds_balance_rule_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_balance_rules_pkg.get_pk_for_validation (
                new_references.holds_balance_rule_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    /* IGS_FI_BALANCE_RULES_PKG.get_pk_for_validation calls for columns other_balance_rule_id and
       installment_balance_rule_id removed, part of Enh Bug 2562745  */

  END check_parent_existance;

  PROCEDURE check_child_existance AS
  /*
  ||  Created By : PATHIPAT
  ||  Created On : 21-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_balances_hst_pkg.get_fk_igs_fi_balances(
      old_references.balance_id
      );
  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_balance_id                        IN     NUMBER
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
      FROM     igs_fi_balances
      WHERE    balance_id = x_balance_id
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
    x_party_id       IN NUMBER,
    x_balance_date   IN DATE)
  RETURN BOOLEAN AS
    /*
  ||  Created By : SCHODAVA
  ||  Created On : 08-OCT-2001
  ||  Purpose : Validates the Unique Key for the table.
  ||  Known limitations, enhancements or remarks :  Added as a part of SFCR010 (Enh # 2030448)
  ||  Change History :
  ||  Who             When            What
  || smvk           17-Sep-2002       Removed the subaccount_id in parameter and its usage in the function
  ||                                  as a part of Bug # 2564643
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
    SELECT rowid
    FROM   IGS_FI_BALANCES
    WHERE  party_id = new_references.party_id
    AND    TRUNC(balance_date)  = TRUNC(new_references.balance_date)
    AND    ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
      RETURN (FALSE);
    END IF;

  END get_uk_for_validation;

 PROCEDURE check_uniqueness AS
   /*
  ||  Created By : SCHODAVA
  ||  Created On : 08-OCT-2001
  ||  Purpose : Validates the Unique Key for the table.
  ||  Known limitations, enhancements or remarks :  Added as a part of SFCR010 (Enh # 2030448)
  ||  Change History :
  ||  Who             When            What
  || smvk          17-Sep-2002       Removed the subaccount_id from the get_uk_for_validation function call
  ||                                 as a part of Bug # 2564643
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

      IF get_uk_for_validation (
        new_references.party_id,
        new_references.balance_date)
      THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

  END check_uniqueness ;

/*  Removed the procedure get_fk_igs_fi_subaccts_all as a part of Bug # 2564643 */

PROCEDURE afterrowupdate AS
/*
  ||  Created By : PATHIPAT
  ||  Created On : 30-SEP-2002
  ||  Purpose : Maintaining history for the balances table
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
l_v_balance_type      igs_fi_balances_hst.balance_type%TYPE;
l_v_balance_amount    igs_fi_balances_hst.balance_amount%TYPE;
l_v_balance_rule_id   igs_fi_balances_hst.balance_rule_id%TYPE;
l_record_changed      BOOLEAN := FALSE;
l_balance_hist_id     igs_fi_balances_hst.balance_hist_id%TYPE := NULL;

BEGIN

l_rowid := NULL;

    -- If the value has been updated, then insert into history table.
    IF (new_references.fee_balance <> old_references.fee_balance)  OR
       ((new_references.fee_balance IS NOT NULL) AND (old_references.fee_balance IS NULL)) OR
       ((new_references.fee_balance IS NULL) AND (old_references.fee_balance IS NOT NULL)) OR
       (new_references.fee_balance_rule_id <> old_references.fee_balance_rule_id) OR
       ((new_references.fee_balance_rule_id IS NOT NULL) AND (old_references.fee_balance_rule_id IS NULL)) OR
       ((new_references.fee_balance_rule_id IS NULL) AND (old_references.fee_balance_rule_id IS NOT NULL)) THEN

       l_record_changed := TRUE;
       l_v_balance_type  := 'FEE';
       l_v_balance_amount := old_references.fee_balance;
       l_v_balance_rule_id := old_references.fee_balance_rule_id;

    ELSIF (new_references.holds_balance <> old_references.holds_balance)  OR
          ((new_references.holds_balance IS NOT NULL) AND (old_references.holds_balance IS NULL)) OR
          ((new_references.holds_balance IS NULL) AND (old_references.holds_balance IS NOT NULL)) OR
          (new_references.holds_balance_rule_id <> old_references.holds_balance_rule_id) OR
          ((new_references.holds_balance_rule_id IS NOT NULL) AND (old_references.holds_balance_rule_id IS NULL)) OR
          ((new_references.holds_balance_rule_id IS NULL) AND (old_references.holds_balance_rule_id IS NOT NULL)) THEN

          l_record_changed := TRUE;
	  l_v_balance_type  := 'HOLDS';
          l_v_balance_amount := old_references.holds_balance;
          l_v_balance_rule_id := old_references.holds_balance_rule_id;

    END IF;

    IF l_record_changed THEN

       IGS_FI_BALANCES_HST_PKG.INSERT_ROW (  x_rowid           => l_rowid,
                                             x_balance_hist_id => l_balance_hist_id,
                                             x_balance_id      => old_references.balance_id,
                                             x_balance_type    => l_v_balance_type,
                                             x_balance_amount  => l_v_balance_amount,
                                             x_balance_rule_id => l_v_balance_rule_id,
	                                     x_mode            => 'R'
                                           );
    END IF;

 END afterrowupdate;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_balance_id                        IN     NUMBER      ,
    x_party_id                          IN     NUMBER      ,
    x_standard_balance                  IN     NUMBER      ,
    x_fee_balance                       IN     NUMBER      ,
    x_holds_balance                     IN     NUMBER      ,
    x_balance_date                      IN     DATE        ,
    x_fee_balance_rule_id               IN     NUMBER      ,
    x_holds_balance_rule_id             IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
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
  ||  (reverse chronological order - newest change first)
  ||  pathipat       21-OCT-2002     Bug:2562745 - Added check_child_existance() calls before
  ||                                 delete operation.
  ||  pathipat       30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  ||  smvk           17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
  ||                                 standard_balance_rule_id
  ||  SCHODAVA        8-OCT-2001      Enh # 2030448 (SFCR010)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_balance_id,
      x_party_id,
      x_standard_balance,
      x_fee_balance,
      x_holds_balance,
      x_balance_date,
      x_fee_balance_rule_id,
      x_holds_balance_rule_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    -- Calls to check_uniqueness are added by schodava as a part of Enh # 2030448 (SFCR010)
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.balance_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.balance_id
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
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE after_dml(
               p_action IN VARCHAR2 ,
	       x_rowid  IN VARCHAR2
	       )  AS
  /*
  ||  Created By : PATHIPAT
  ||  Created On : 30-SEP-2002
  ||  Purpose : Handles the AFTER DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||
  */
     l_rowid  VARCHAR2(25);
     BEGIN

     IF (p_action = 'UPDATE') THEN
       afterrowupdate;
     END IF;

   END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
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
  || pathipat        30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  || smvk            17-Sep-2002     Obsoleted column subaccount_id as a part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_balances
      WHERE    balance_id = x_balance_id;

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

    SELECT    igs_fi_balances_s.NEXTVAL
    INTO      x_balance_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_balance_id                        => x_balance_id,
      x_party_id                          => x_party_id,
      x_standard_balance                  => x_standard_balance,
      x_fee_balance                       => x_fee_balance,
      x_holds_balance                     => x_holds_balance,
      x_balance_date                      => x_balance_date,
      x_fee_balance_rule_id               => x_fee_balance_rule_id,
      x_holds_balance_rule_id             => x_holds_balance_rule_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_balances (
      balance_id,
      party_id,
      standard_balance,
      fee_balance,
      holds_balance,
      balance_date,
      fee_balance_rule_id,
      holds_balance_rule_id,
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
      new_references.balance_id,
      new_references.party_id,
      new_references.standard_balance,
      new_references.fee_balance,
      new_references.holds_balance,
      new_references.balance_date,
      new_references.fee_balance_rule_id,
      new_references.holds_balance_rule_id,
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
    x_balance_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || pathipat        30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  || smvk            17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
  */
    CURSOR c1 IS
      SELECT
        party_id,
        standard_balance,
        fee_balance,
        holds_balance,
        balance_date,
        fee_balance_rule_id,
        holds_balance_rule_id
      FROM  igs_fi_balances
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
        (tlinfo.party_id = x_party_id)
        AND ((tlinfo.standard_balance = x_standard_balance) OR ((tlinfo.standard_balance IS NULL) AND (X_standard_balance IS NULL)))
        AND ((tlinfo.fee_balance = x_fee_balance) OR ((tlinfo.fee_balance IS NULL) AND (X_fee_balance IS NULL)))
        AND ((tlinfo.holds_balance = x_holds_balance) OR ((tlinfo.holds_balance IS NULL) AND (X_holds_balance IS NULL)))
        AND (tlinfo.balance_date = x_balance_date)
        AND ((tlinfo.fee_balance_rule_id = x_fee_balance_rule_id) OR ((tlinfo.fee_balance_rule_id IS NULL) AND (X_fee_balance_rule_id IS NULL)))
        AND ((tlinfo.holds_balance_rule_id = x_holds_balance_rule_id) OR ((tlinfo.holds_balance_rule_id IS NULL) AND (X_holds_balance_rule_id IS NULL)))
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
    x_balance_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
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
  || pathipat        30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  || smvk            17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
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
      x_balance_id                        => x_balance_id,
      x_party_id                          => x_party_id,
      x_standard_balance                  => x_standard_balance,
      x_fee_balance                       => x_fee_balance,
      x_holds_balance                     => x_holds_balance,
      x_balance_date                      => x_balance_date,
      x_fee_balance_rule_id               => x_fee_balance_rule_id,
      x_holds_balance_rule_id             => x_holds_balance_rule_id,
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

    UPDATE igs_fi_balances
      SET
        party_id                          = new_references.party_id,
        standard_balance                  = new_references.standard_balance,
        fee_balance                       = new_references.fee_balance,
        holds_balance                     = new_references.holds_balance,
        balance_date                      = new_references.balance_date,
        fee_balance_rule_id               = new_references.fee_balance_rule_id,
        holds_balance_rule_id             = new_references.holds_balance_rule_id,
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

    -- Added as part of Enh Bug: 2562745
    -- When the balances table is updated, the initial version of the record is saved in
    -- the history table.

    after_dml(
         p_action => 'UPDATE',
         x_rowid  => x_rowid );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
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
  ||  pathipat        30-SEP-2002     Obsoleted columns other_balance_id, other_balance_rule_id,
  ||                                 installment_balance_id and installment_balance_rule_id for
  ||                                 Enh Bug # 2562745
  ||  smvk           17-Sep-2002     Obsoleted column subaccount_id, as part of Bug # 2564643
  || agairola        30-May-2002     For bug 2364505, obsoleted column
                                     standard_balance_rule_id
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_balances
      WHERE    balance_id = x_balance_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_balance_id,
        x_party_id,
        x_standard_balance,
        x_fee_balance,
        x_holds_balance,
        x_balance_date,
        x_fee_balance_rule_id,
        x_holds_balance_rule_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_balance_id,
      x_party_id,
      x_standard_balance,
      x_fee_balance,
      x_holds_balance,
      x_balance_date,
      x_fee_balance_rule_id,
      x_holds_balance_rule_id,
      x_mode
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

    DELETE FROM igs_fi_balances
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_balances_pkg;

/
