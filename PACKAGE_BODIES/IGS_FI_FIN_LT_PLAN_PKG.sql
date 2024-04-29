--------------------------------------------------------
--  DDL for Package Body IGS_FI_FIN_LT_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FIN_LT_PLAN_PKG" AS
/* $Header: IGSSIB5B.pls 115.16 2003/09/16 10:22:14 vvutukur ship $ */
/* Change History
   Who              When                              What
   vvutukur         07-Sep-2003                       Enh#3045007.Payment Plans Build.Addition of 7 columns related to
                                                      payment plans.
   pathipat         11-Feb-2003                       Enh 2747325 - Locking Issues build
                                                      Removed proc get_fk_igs_fi_fee_type()
   jbegum           4-dec-2001                        As part of enh bug # 2124001
                                                      Added a local procedure check_charge_existence for the validations in form IGSFI067.fmb
                                                      Also added the call to this procedure from before_dml
   jbegum           11-dec-2001                       Added the check_constraints procedure and call to it in Before_dml procedure .
                                                      */


  l_rowid VARCHAR2(25);
  old_references igs_fi_fin_lt_plan%ROWTYPE;
  new_references igs_fi_fin_lt_plan%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_plan_name                         IN     VARCHAR2    ,
    x_plan_type                         IN     VARCHAR2    ,
    x_description                       IN     VARCHAR2    ,
    x_closed_ind                        IN     VARCHAR2    ,
    x_balance_type                      IN     VARCHAR2    ,
    x_fee_type                          IN     VARCHAR2    ,
    x_accrual_type                      IN     VARCHAR2    ,
    x_offset_days                       IN     NUMBER      ,
    x_chg_rate                          IN     NUMBER      ,
    x_flat_amount                       IN     NUMBER      ,
    x_max_charge_amount                 IN     NUMBER      ,
    x_min_charge_amount                 IN     NUMBER      ,
    x_min_charge_amount_no_charge       IN     NUMBER      ,
    x_min_balance_amount                IN     NUMBER      ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_payment_plan_accrl_type_code      IN     VARCHAR2    ,
    x_payment_plan_chg_rate             IN     NUMBER      ,
    x_payment_plan_flat_amt             IN     NUMBER      ,
    x_payment_plan_max_charge_amt       IN     NUMBER      ,
    x_payment_plan_min_charge_amt       IN     NUMBER      ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER      ,
    x_payment_plan_min_balance_amt      IN     NUMBER) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FIN_LT_PLAN
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
    new_references.plan_name                         := x_plan_name;
    new_references.plan_type                         := x_plan_type;
    new_references.description                       := x_description;
    new_references.closed_ind                        := x_closed_ind;
    new_references.balance_type                      := x_balance_type;
    new_references.fee_type                          := x_fee_type;
    new_references.accrual_type                      := x_accrual_type;
    new_references.offset_days                       := x_offset_days;
    new_references.chg_rate                          := x_chg_rate;
    new_references.flat_amount                       := x_flat_amount;
    new_references.max_charge_amount                 := x_max_charge_amount;
    new_references.min_charge_amount                 := x_min_charge_amount;
    new_references.min_charge_amount_no_charge       := x_min_charge_amount_no_charge;
    new_references.min_balance_amount                := x_min_balance_amount;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.payment_plan_accrl_type_code      := x_payment_plan_accrl_type_code;
    new_references.payment_plan_chg_rate             := x_payment_plan_chg_rate;
    new_references.payment_plan_flat_amt             := x_payment_plan_flat_amt;
    new_references.payment_plan_max_charge_amt       := x_payment_plan_max_charge_amt;
    new_references.payment_plan_min_charge_amt       := x_payment_plan_min_charge_amt;
    new_references.payment_plan_minchgamt_nochg      := x_payment_plan_minchgamt_nochg;
    new_references.payment_plan_min_balance_amt      := x_payment_plan_min_balance_amt;

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
                 column_name  IN VARCHAR2  ,
                 column_value IN VARCHAR2  ) AS
  /*************************************************************
  Created By      : jbegum
  Date Created By : 11-dec_01
  Purpose : To check whether the plan_name has been entered in upper case and closed_ind value in Y,N
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
        new_references.closed_ind := column_value;
      END IF;

      IF UPPER(column_name) = 'CLOSED_IND' OR
        column_name IS NULL THEN
        IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END check_constraints;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    16-Sep-2003     Enh#3045007.Payment Plans Build.Added call to
  ||                              igs_lookups_view_pkg.get_pk_for_validation for the newly
  ||                              added column payment_plan_accrl_type_code.
  */
  BEGIN

    IF (((old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation (
                new_references.fee_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.plan_type = new_references.plan_type)) OR
        ((new_references.plan_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'IGS_FI_PLAN_TYPE',
                new_references.plan_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.accrual_type = new_references.accrual_type)) OR
        ((new_references.accrual_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'IGS_FI_ACCRUAL_TYPE',
                new_references.accrual_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.balance_type = new_references.balance_type)) OR
        ((new_references.balance_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'IGS_FI_BALANCE_TYPE',
                new_references.balance_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.payment_plan_accrl_type_code = new_references.payment_plan_accrl_type_code)) OR
        ((new_references.payment_plan_accrl_type_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                'IGS_FI_ACCRUAL_TYPE',
                new_references.payment_plan_accrl_type_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_charge_existance (
                                     p_action                 IN     VARCHAR2,
                                     x_fee_type               IN     VARCHAR2
   ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 04-dec-2001
  ||  Purpose : Checks for the existance of Charge records for the given fee type in the Charges table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur   07-Sep-2003  Enh#3045007.Payment Plans Build.Added check for the payment plan attributes
  ||                          not to get updated if a charge is created using the fee type on which the plan is based.
  */
   CURSOR cur_chg IS
      SELECT   rowid
      FROM     igs_fi_inv_int
      WHERE    fee_type = x_fee_type
      AND      transaction_type IN ('INTEREST','LATE')
      FOR UPDATE NOWAIT;

   lv_chg cur_chg%RowType;

  BEGIN
    IF (
        p_action = 'VALIDATE_UPDATE' AND
        (new_references.plan_type = old_references.plan_type) AND
        ((new_references.description = old_references.description) OR ((old_references.description IS NULL) AND (new_references.description IS NULL))) AND
        (new_references.balance_type = old_references.balance_type) AND
        (new_references.fee_type = old_references.fee_type) AND
        (new_references.accrual_type = old_references.accrual_type) AND
        ((new_references.offset_days = old_references.offset_days) OR ((old_references.offset_days IS NULL) AND (new_references.offset_days IS NULL))) AND
        ((new_references.chg_rate = old_references.chg_rate) OR ((old_references.chg_rate IS NULL) AND (new_references.chg_rate IS NULL))) AND
        ((new_references.flat_amount = old_references.flat_amount) OR ((old_references.flat_amount IS NULL) AND (new_references.flat_amount IS NULL))) AND
        ((new_references.min_balance_amount = old_references.min_balance_amount) OR ((old_references.min_balance_amount IS NULL) AND (new_references.min_balance_amount IS NULL))) AND
        ((new_references.min_charge_amount = old_references.min_charge_amount) OR ((old_references.min_charge_amount IS NULL) AND (new_references.min_charge_amount IS NULL))) AND
        ((new_references.max_charge_amount = old_references.max_charge_amount) OR ((old_references.max_charge_amount IS NULL) AND (new_references.max_charge_amount IS NULL))) AND
        ((new_references.min_charge_amount_no_charge = old_references.min_charge_amount_no_charge) OR ((old_references.min_charge_amount_no_charge IS NULL) AND (new_references.min_charge_amount_no_charge IS NULL))) AND
        ((new_references.payment_plan_accrl_type_code = old_references.payment_plan_accrl_type_code) OR ((old_references.payment_plan_accrl_type_code IS NULL) AND (new_references.payment_plan_accrl_type_code IS NULL))) AND
        ((new_references.payment_plan_chg_rate = old_references.payment_plan_chg_rate) OR ((old_references.payment_plan_chg_rate IS NULL) AND (new_references.payment_plan_chg_rate IS NULL))) AND
        ((new_references.payment_plan_flat_amt = old_references.payment_plan_flat_amt) OR ((old_references.payment_plan_flat_amt IS NULL) AND (new_references.payment_plan_flat_amt IS NULL))) AND
        ((new_references.payment_plan_min_balance_amt = old_references.payment_plan_min_balance_amt) OR ((old_references.payment_plan_min_balance_amt IS NULL) AND (new_references.payment_plan_min_balance_amt IS NULL))) AND
        ((new_references.payment_plan_min_charge_amt = old_references.payment_plan_min_charge_amt) OR ((old_references.payment_plan_min_charge_amt IS NULL) AND (new_references.payment_plan_min_charge_amt IS NULL))) AND
        ((new_references.payment_plan_max_charge_amt = old_references.payment_plan_max_charge_amt) OR ((old_references.payment_plan_max_charge_amt IS NULL) AND (new_references.payment_plan_max_charge_amt IS NULL))) AND
        ((new_references.payment_plan_minchgamt_nochg = old_references.payment_plan_minchgamt_nochg) OR ((old_references.payment_plan_minchgamt_nochg IS NULL) AND (new_references.payment_plan_minchgamt_nochg IS NULL)))
       ) THEN
      NULL;
    ELSE
     OPEN cur_chg;
     FETCH cur_chg INTO lv_chg;
     IF (cur_chg%FOUND) THEN
        CLOSE cur_chg;
        fnd_message.set_name ('IGS', 'IGS_FI_MOD_PLAN');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
      END IF;
      CLOSE cur_chg;
    END IF;

  END check_charge_existance;

  FUNCTION get_pk_for_validation (
    x_plan_name                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_fin_lt_plan
      WHERE    plan_name = x_plan_name
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
    x_plan_name                         IN     VARCHAR2    ,
    x_plan_type                         IN     VARCHAR2    ,
    x_description                       IN     VARCHAR2    ,
    x_closed_ind                        IN     VARCHAR2    ,
    x_balance_type                      IN     VARCHAR2    ,
    x_fee_type                          IN     VARCHAR2    ,
    x_accrual_type                      IN     VARCHAR2    ,
    x_offset_days                       IN     NUMBER      ,
    x_chg_rate                          IN     NUMBER      ,
    x_flat_amount                       IN     NUMBER      ,
    x_max_charge_amount                 IN     NUMBER      ,
    x_min_charge_amount                 IN     NUMBER      ,
    x_min_charge_amount_no_charge       IN     NUMBER      ,
    x_min_balance_amount                IN     NUMBER      ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_payment_plan_accrl_type_code      IN     VARCHAR2    ,
    x_payment_plan_chg_rate             IN     NUMBER      ,
    x_payment_plan_flat_amt             IN     NUMBER      ,
    x_payment_plan_max_charge_amt       IN     NUMBER      ,
    x_payment_plan_min_charge_amt       IN     NUMBER      ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER      ,
    x_payment_plan_min_balance_amt      IN     NUMBER    ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_plan_name,
      x_plan_type,
      x_description,
      x_closed_ind,
      x_balance_type,
      x_fee_type,
      x_accrual_type,
      x_offset_days,
      x_chg_rate,
      x_flat_amount,
      x_max_charge_amount,
      x_min_charge_amount,
      x_min_charge_amount_no_charge,
      x_min_balance_amount,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_payment_plan_accrl_type_code,
      x_payment_plan_chg_rate,
      x_payment_plan_flat_amt,
      x_payment_plan_max_charge_amt,
      x_payment_plan_min_charge_amt,
      x_payment_plan_minchgamt_nochg,
      x_payment_plan_min_balance_amt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.plan_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.plan_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
      check_charge_existance(p_action,
                             old_references.fee_type);
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_charge_existance(p_action,
                             old_references.fee_type);
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_name                         IN     VARCHAR2,
    x_plan_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_balance_type                      IN     VARCHAR2,
    x_fee_type                          IN     VARCHAR2,
    x_accrual_type                      IN     VARCHAR2,
    x_offset_days                       IN     NUMBER,
    x_chg_rate                          IN     NUMBER,
    x_flat_amount                       IN     NUMBER,
    x_max_charge_amount                 IN     NUMBER,
    x_min_charge_amount                 IN     NUMBER,
    x_min_charge_amount_no_charge       IN     NUMBER,
    x_min_balance_amount                IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_plan_accrl_type_code      IN     VARCHAR2,
    x_payment_plan_chg_rate             IN     NUMBER  ,
    x_payment_plan_flat_amt             IN     NUMBER  ,
    x_payment_plan_max_charge_amt       IN     NUMBER  ,
    x_payment_plan_min_charge_amt       IN     NUMBER  ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER  ,
    x_payment_plan_min_balance_amt      IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_fin_lt_plan
      WHERE    plan_name                         = x_plan_name;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_plan_name                         => x_plan_name,
      x_plan_type                         => x_plan_type,
      x_description                       => x_description,
      x_closed_ind                        => x_closed_ind,
      x_balance_type                      => x_balance_type,
      x_fee_type                          => x_fee_type,
      x_accrual_type                      => x_accrual_type,
      x_offset_days                       => x_offset_days,
      x_chg_rate                          => x_chg_rate,
      x_flat_amount                       => x_flat_amount,
      x_max_charge_amount                 => x_max_charge_amount,
      x_min_charge_amount                 => x_min_charge_amount,
      x_min_charge_amount_no_charge       => x_min_charge_amount_no_charge,
      x_min_balance_amount                => x_min_balance_amount,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_plan_accrl_type_code      => x_payment_plan_accrl_type_code,
      x_payment_plan_chg_rate             => x_payment_plan_chg_rate,
      x_payment_plan_flat_amt             => x_payment_plan_flat_amt,
      x_payment_plan_max_charge_amt       => x_payment_plan_max_charge_amt,
      x_payment_plan_min_charge_amt       => x_payment_plan_min_charge_amt,
      x_payment_plan_minchgamt_nochg      => x_payment_plan_minchgamt_nochg,
      x_payment_plan_min_balance_amt      => x_payment_plan_min_balance_amt
    );

    INSERT INTO igs_fi_fin_lt_plan (
      plan_name,
      plan_type,
      description,
      closed_ind,
      balance_type,
      fee_type,
      accrual_type,
      offset_days,
      chg_rate,
      flat_amount,
      max_charge_amount,
      min_charge_amount,
      min_charge_amount_no_charge,
      min_balance_amount,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      payment_plan_accrl_type_code,
      payment_plan_chg_rate,
      payment_plan_flat_amt,
      payment_plan_max_charge_amt,
      payment_plan_min_charge_amt,
      payment_plan_minchgamt_nochg,
      payment_plan_min_balance_amt
      ) VALUES (
      new_references.plan_name,
      new_references.plan_type,
      new_references.description,
      new_references.closed_ind,
      new_references.balance_type,
      new_references.fee_type,
      new_references.accrual_type,
      new_references.offset_days,
      new_references.chg_rate,
      new_references.flat_amount,
      new_references.max_charge_amount,
      new_references.min_charge_amount,
      new_references.min_charge_amount_no_charge,
      new_references.min_balance_amount,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.payment_plan_accrl_type_code,
      new_references.payment_plan_chg_rate,
      new_references.payment_plan_flat_amt,
      new_references.payment_plan_max_charge_amt,
      new_references.payment_plan_min_charge_amt,
      new_references.payment_plan_minchgamt_nochg,
      new_references.payment_plan_min_balance_amt
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
    x_plan_name                         IN     VARCHAR2,
    x_plan_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_balance_type                      IN     VARCHAR2,
    x_fee_type                          IN     VARCHAR2,
    x_accrual_type                      IN     VARCHAR2,
    x_offset_days                       IN     NUMBER,
    x_chg_rate                          IN     NUMBER,
    x_flat_amount                       IN     NUMBER,
    x_max_charge_amount                 IN     NUMBER,
    x_min_charge_amount                 IN     NUMBER,
    x_min_charge_amount_no_charge       IN     NUMBER,
    x_min_balance_amount                IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_payment_plan_accrl_type_code      IN     VARCHAR2,
    x_payment_plan_chg_rate             IN     NUMBER  ,
    x_payment_plan_flat_amt             IN     NUMBER  ,
    x_payment_plan_max_charge_amt       IN     NUMBER  ,
    x_payment_plan_min_charge_amt       IN     NUMBER  ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER  ,
    x_payment_plan_min_balance_amt      IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
  */
    CURSOR c1 IS
      SELECT
        plan_type,
        description,
        closed_ind,
        balance_type,
        fee_type,
        accrual_type,
        offset_days,
        chg_rate,
        flat_amount,
        max_charge_amount,
        min_charge_amount,
        min_charge_amount_no_charge,
        min_balance_amount,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        payment_plan_accrl_type_code,
        payment_plan_chg_rate,
        payment_plan_flat_amt,
        payment_plan_max_charge_amt,
        payment_plan_min_charge_amt,
        payment_plan_minchgamt_nochg,
        payment_plan_min_balance_amt
      FROM  igs_fi_fin_lt_plan
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
        (tlinfo.plan_type = x_plan_type)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.closed_ind = x_closed_ind)
        AND (tlinfo.balance_type = x_balance_type)
        AND (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.accrual_type = x_accrual_type)
        AND ((tlinfo.offset_days = x_offset_days) OR ((tlinfo.offset_days IS NULL) AND (X_offset_days IS NULL)))
        AND ((tlinfo.chg_rate = x_chg_rate) OR ((tlinfo.chg_rate IS NULL) AND (X_chg_rate IS NULL)))
        AND ((tlinfo.flat_amount = x_flat_amount) OR ((tlinfo.flat_amount IS NULL) AND (X_flat_amount IS NULL)))
        AND ((tlinfo.max_charge_amount = x_max_charge_amount) OR ((tlinfo.max_charge_amount IS NULL) AND (X_max_charge_amount IS NULL)))
        AND ((tlinfo.min_charge_amount = x_min_charge_amount) OR ((tlinfo.min_charge_amount IS NULL) AND (X_min_charge_amount IS NULL)))
        AND ((tlinfo.min_charge_amount_no_charge = x_min_charge_amount_no_charge) OR ((tlinfo.min_charge_amount_no_charge IS NULL) AND (X_min_charge_amount_no_charge IS NULL)))
        AND ((tlinfo.min_balance_amount = x_min_balance_amount) OR ((tlinfo.min_balance_amount IS NULL) AND (X_min_balance_amount IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.payment_plan_accrl_type_code = x_payment_plan_accrl_type_code) OR ((tlinfo.payment_plan_accrl_type_code IS NULL) AND (x_payment_plan_accrl_type_code IS NULL)))
        AND ((tlinfo.payment_plan_chg_rate = x_payment_plan_chg_rate) OR ((tlinfo.payment_plan_chg_rate IS NULL) AND (x_payment_plan_chg_rate IS NULL)))
        AND ((tlinfo.payment_plan_flat_amt = x_payment_plan_flat_amt) OR ((tlinfo.payment_plan_flat_amt IS NULL) AND (x_payment_plan_flat_amt IS NULL)))
        AND ((tlinfo.payment_plan_max_charge_amt = x_payment_plan_max_charge_amt) OR ((tlinfo.payment_plan_max_charge_amt IS NULL) AND (x_payment_plan_max_charge_amt IS NULL)))
        AND ((tlinfo.payment_plan_min_charge_amt = x_payment_plan_min_charge_amt) OR ((tlinfo.payment_plan_min_charge_amt IS NULL) AND (x_payment_plan_min_charge_amt IS NULL)))
        AND ((tlinfo.payment_plan_minchgamt_nochg = x_payment_plan_minchgamt_nochg) OR ((tlinfo.payment_plan_minchgamt_nochg IS NULL) AND (x_payment_plan_minchgamt_nochg IS NULL)))
        AND ((tlinfo.payment_plan_min_balance_amt = x_payment_plan_min_balance_amt) OR ((tlinfo.payment_plan_min_balance_amt IS NULL) AND (x_payment_plan_min_balance_amt IS NULL)))
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
    x_plan_name                         IN     VARCHAR2,
    x_plan_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_balance_type                      IN     VARCHAR2,
    x_fee_type                          IN     VARCHAR2,
    x_accrual_type                      IN     VARCHAR2,
    x_offset_days                       IN     NUMBER,
    x_chg_rate                          IN     NUMBER,
    x_flat_amount                       IN     NUMBER,
    x_max_charge_amount                 IN     NUMBER,
    x_min_charge_amount                 IN     NUMBER,
    x_min_charge_amount_no_charge       IN     NUMBER,
    x_min_balance_amount                IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_plan_accrl_type_code      IN     VARCHAR2,
    x_payment_plan_chg_rate             IN     NUMBER  ,
    x_payment_plan_flat_amt             IN     NUMBER  ,
    x_payment_plan_max_charge_amt       IN     NUMBER  ,
    x_payment_plan_min_charge_amt       IN     NUMBER  ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER  ,
    x_payment_plan_min_balance_amt      IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
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
      x_plan_name                         => x_plan_name,
      x_plan_type                         => x_plan_type,
      x_description                       => x_description,
      x_closed_ind                        => x_closed_ind,
      x_balance_type                      => x_balance_type,
      x_fee_type                          => x_fee_type,
      x_accrual_type                      => x_accrual_type,
      x_offset_days                       => x_offset_days,
      x_chg_rate                          => x_chg_rate,
      x_flat_amount                       => x_flat_amount,
      x_max_charge_amount                 => x_max_charge_amount,
      x_min_charge_amount                 => x_min_charge_amount,
      x_min_charge_amount_no_charge       => x_min_charge_amount_no_charge,
      x_min_balance_amount                => x_min_balance_amount,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_payment_plan_accrl_type_code      => x_payment_plan_accrl_type_code,
      x_payment_plan_chg_rate             => x_payment_plan_chg_rate,
      x_payment_plan_flat_amt             => x_payment_plan_flat_amt,
      x_payment_plan_max_charge_amt       => x_payment_plan_max_charge_amt,
      x_payment_plan_min_charge_amt       => x_payment_plan_min_charge_amt,
      x_payment_plan_minchgamt_nochg      => x_payment_plan_minchgamt_nochg,
      x_payment_plan_min_balance_amt      => x_payment_plan_min_balance_amt
    );

    UPDATE igs_fi_fin_lt_plan
      SET
        plan_type                         = new_references.plan_type,
        description                       = new_references.description,
        closed_ind                        = new_references.closed_ind,
        balance_type                      = new_references.balance_type,
        fee_type                          = new_references.fee_type,
        accrual_type                      = new_references.accrual_type,
        offset_days                       = new_references.offset_days,
        chg_rate                          = new_references.chg_rate,
        flat_amount                       = new_references.flat_amount,
        max_charge_amount                 = new_references.max_charge_amount,
        min_charge_amount                 = new_references.min_charge_amount,
        min_charge_amount_no_charge       = new_references.min_charge_amount_no_charge,
        min_balance_amount                = new_references.min_balance_amount,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        payment_plan_accrl_type_code      = new_references.payment_plan_accrl_type_code,
        payment_plan_chg_rate             = new_references.payment_plan_chg_rate,
        payment_plan_flat_amt             = new_references.payment_plan_flat_amt,
        payment_plan_max_charge_amt       = new_references.payment_plan_max_charge_amt,
        payment_plan_min_charge_amt       = new_references.payment_plan_min_charge_amt,
        payment_plan_minchgamt_nochg      = new_references.payment_plan_minchgamt_nochg,
        payment_plan_min_balance_amt      = new_references.payment_plan_min_balance_amt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_name                         IN     VARCHAR2,
    x_plan_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_balance_type                      IN     VARCHAR2,
    x_fee_type                          IN     VARCHAR2,
    x_accrual_type                      IN     VARCHAR2,
    x_offset_days                       IN     NUMBER,
    x_chg_rate                          IN     NUMBER,
    x_flat_amount                       IN     NUMBER,
    x_max_charge_amount                 IN     NUMBER,
    x_min_charge_amount                 IN     NUMBER,
    x_min_charge_amount_no_charge       IN     NUMBER,
    x_min_balance_amount                IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_payment_plan_accrl_type_code      IN     VARCHAR2,
    x_payment_plan_chg_rate             IN     NUMBER  ,
    x_payment_plan_flat_amt             IN     NUMBER  ,
    x_payment_plan_max_charge_amt       IN     NUMBER  ,
    x_payment_plan_min_charge_amt       IN     NUMBER  ,
    x_payment_plan_minchgamt_nochg      IN     NUMBER  ,
    x_payment_plan_min_balance_amt      IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     07-Sep-2003    Enh#3045007.Payment Plans Build.Addition of 7 columns related to
  ||                              payment plans.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_fin_lt_plan
      WHERE    plan_name                         = x_plan_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_plan_name,
        x_plan_type,
        x_description,
        x_closed_ind,
        x_balance_type,
        x_fee_type,
        x_accrual_type,
        x_offset_days,
        x_chg_rate,
        x_flat_amount,
        x_max_charge_amount,
        x_min_charge_amount,
        x_min_charge_amount_no_charge,
        x_min_balance_amount,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_mode,
        x_payment_plan_accrl_type_code,
        x_payment_plan_chg_rate,
        x_payment_plan_flat_amt,
        x_payment_plan_max_charge_amt,
        x_payment_plan_min_charge_amt,
        x_payment_plan_minchgamt_nochg,
        x_payment_plan_min_balance_amt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_plan_name,
      x_plan_type,
      x_description,
      x_closed_ind,
      x_balance_type,
      x_fee_type,
      x_accrual_type,
      x_offset_days,
      x_chg_rate,
      x_flat_amount,
      x_max_charge_amount,
      x_min_charge_amount,
      x_min_charge_amount_no_charge,
      x_min_balance_amount,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_mode,
      x_payment_plan_accrl_type_code,
      x_payment_plan_chg_rate,
      x_payment_plan_flat_amt,
      x_payment_plan_max_charge_amt,
      x_payment_plan_min_charge_amt,
      x_payment_plan_minchgamt_nochg,
      x_payment_plan_min_balance_amt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 28-NOV-2001
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

    DELETE FROM igs_fi_fin_lt_plan
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_fin_lt_plan_pkg;

/
