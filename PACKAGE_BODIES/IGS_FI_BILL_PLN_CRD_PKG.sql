--------------------------------------------------------
--  DDL for Package Body IGS_FI_BILL_PLN_CRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_BILL_PLN_CRD_PKG" AS
/* $Header: IGSSIC4B.pls 115.3 2002/11/29 04:06:54 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_bill_pln_crd%ROWTYPE;
  new_references igs_fi_bill_pln_crd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_pln_credit_date                   IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_pln_credit_amount                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_bill_pln_crd
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
    new_references.award_id                          := x_award_id;
    new_references.disb_num                          := x_disb_num;
    new_references.pln_credit_date                   := x_pln_credit_date;
    new_references.fund_id                           := x_fund_id;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.pln_credit_amount                 := x_pln_credit_amount;
    new_references.bill_desc                         := x_bill_desc;

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
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

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

    IF (((old_references.fund_id = new_references.fund_id)) OR
        ((new_references.fund_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fund_mast_pkg.get_pk_for_validation (
                new_references.fund_id
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

    IF (((old_references.award_id = new_references.award_id) AND
         (old_references.disb_num = new_references.disb_num)) OR
        ((new_references.award_id IS NULL) OR
         (new_references.disb_num IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_disb_pkg.get_pk_for_validation (
                new_references.award_id,
                new_references.disb_num
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE    bill_id = x_bill_id
      AND      award_id = x_award_id
      AND      disb_num = x_disb_num
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
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE   ((bill_id = x_bill_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIPC_FBLLA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_bill;


  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE   ((fund_id = x_fund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIPC_FMAST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fund_mast;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE   ((fee_cal_type = x_cal_type) AND
               (fee_ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIPC_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE   ((award_id = x_award_id) AND
               (disb_num = x_disb_num));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FIPC_ADISB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_disb;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_pln_credit_date                   IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_pln_credit_amount                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_bill_id,
      x_award_id,
      x_disb_num,
      x_pln_credit_date,
      x_fund_id,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_pln_credit_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_bill_desc
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.bill_id,
             new_references.award_id,
             new_references.disb_num
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
             new_references.bill_id,
             new_references.award_id,
             new_references.disb_num
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
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE    bill_id                           = x_bill_id
      AND      award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

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
      x_bill_id                           => x_bill_id,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_pln_credit_date                   => x_pln_credit_date,
      x_fund_id                           => x_fund_id,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_pln_credit_amount                 => x_pln_credit_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_bill_desc                         => x_bill_desc
    );

    INSERT INTO igs_fi_bill_pln_crd (
      bill_id,
      award_id,
      disb_num,
      pln_credit_date,
      fund_id,
      fee_cal_type,
      fee_ci_sequence_number,
      pln_credit_amount,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      bill_desc
    ) VALUES (
      new_references.bill_id,
      new_references.award_id,
      new_references.disb_num,
      new_references.pln_credit_date,
      new_references.fund_id,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.pln_credit_amount,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.bill_desc
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        pln_credit_date,
        fund_id,
        fee_cal_type,
        fee_ci_sequence_number,
        pln_credit_amount,
	bill_desc
      FROM  igs_fi_bill_pln_crd
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
        (tlinfo.pln_credit_date = x_pln_credit_date)
        AND (tlinfo.fund_id = x_fund_id)
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
        AND (tlinfo.pln_credit_amount = x_pln_credit_amount)
        AND ((tlinfo.bill_desc = x_bill_desc) OR ((tlinfo.bill_desc IS NULL) AND (x_bill_desc IS NULL)))
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
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
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
      x_bill_id                           => x_bill_id,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_pln_credit_date                   => x_pln_credit_date,
      x_fund_id                           => x_fund_id,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_pln_credit_amount                 => x_pln_credit_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_bill_desc                         => x_bill_desc
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

    UPDATE igs_fi_bill_pln_crd
      SET
        pln_credit_date                   = new_references.pln_credit_date,
        fund_id                           = new_references.fund_id,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        pln_credit_amount                 = new_references.pln_credit_amount,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
        bill_desc                         = x_bill_desc
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smadathi        31-may-2002      Bug 2349394. Added new column Bill_desc
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_bill_pln_crd
      WHERE    bill_id                           = x_bill_id
      AND      award_id                          = x_award_id
      AND      disb_num                          = x_disb_num;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_bill_id,
        x_award_id,
        x_disb_num,
        x_pln_credit_date,
        x_fund_id,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_pln_credit_amount,
        x_mode,
	x_bill_desc
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_bill_id,
      x_award_id,
      x_disb_num,
      x_pln_credit_date,
      x_fund_id,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_pln_credit_amount,
      x_mode,
      x_bill_desc
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Vinay.Chappidi@oracle.com
  ||  Created On : 02-APR-2002
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

    DELETE FROM igs_fi_bill_pln_crd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_bill_pln_crd_pkg;

/
