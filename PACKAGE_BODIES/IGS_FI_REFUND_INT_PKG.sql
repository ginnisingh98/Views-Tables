--------------------------------------------------------
--  DDL for Package Body IGS_FI_REFUND_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_REFUND_INT_PKG" AS
/* $Header: IGSSIC3B.pls 115.8 2003/02/19 08:05:43 pathipat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_refund_int_all%ROWTYPE;
  new_references igs_fi_refund_int_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_refund_id                         IN     NUMBER      ,
    x_voucher_date                      IN     DATE        ,
    x_person_id                         IN     NUMBER      ,
    x_pay_person_id                     IN     NUMBER      ,
    x_dr_gl_ccid                        IN     NUMBER      ,
    x_cr_gl_ccid                        IN     NUMBER      ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_refund_amount                     IN     NUMBER      ,
    x_fee_type                          IN     VARCHAR2    ,
    x_fee_cal_type                      IN     VARCHAR2    ,
    x_fee_ci_sequence_number            IN     NUMBER      ,
    x_source_refund_id                  IN     NUMBER      ,
    x_invoice_id                        IN     NUMBER      ,
    x_reason                            IN     VARCHAR2    ,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_refund_int_all
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
    new_references.refund_id                         := x_refund_id;
    new_references.voucher_date                      := x_voucher_date;
    new_references.person_id                         := x_person_id;
    new_references.pay_person_id                     := x_pay_person_id;
    new_references.dr_gl_ccid                        := x_dr_gl_ccid;
    new_references.cr_gl_ccid                        := x_cr_gl_ccid;
    new_references.dr_account_cd                     := x_dr_account_cd;
    new_references.cr_account_cd                     := x_cr_account_cd;
    new_references.refund_amount                     := x_refund_amount;
    new_references.fee_type                          := x_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.source_refund_id                  := x_source_refund_id;
    new_references.invoice_id                        := x_invoice_id;
    new_references.reason                            := x_reason;
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
    new_references.gl_date                           := TRUNC(x_gl_date);

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
  ||  Created On : 27-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_hzp(cp_party_id    NUMBER) IS
      SELECT 'x'
      FROM   hz_parties
      WHERE  party_id = cp_party_id;

    l_var    VARCHAR2(1);
  BEGIN

    IF (((old_references.refund_id = new_references.refund_id)) OR
        ((new_references.refund_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_refunds_pkg.get_pk_for_validation (
                new_references.refund_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_hzp(new_references.person_id);
      FETCH cur_hzp INTO l_var;
      IF cur_hzp%NOTFOUND THEN
        CLOSE cur_hzp;
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_hzp;
    END IF;

    IF (((old_references.pay_person_id = new_references.pay_person_id)) OR
        ((new_references.pay_person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_hzp(new_references.pay_person_id);
      FETCH cur_hzp INTO l_var;
      IF cur_hzp%NOTFOUND THEN
        CLOSE cur_hzp;
        fnd_message.set_name('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_hzp;
    END IF;

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_type,
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.dr_account_cd = new_references.dr_account_cd)) OR
        ((new_references.dr_account_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_acc_pkg.get_pk_for_validation (
                new_references.dr_account_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.cr_account_cd = new_references.cr_account_cd)) OR
        ((new_references.cr_account_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_acc_pkg.get_pk_for_validation (
                new_references.cr_account_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.invoice_id = new_references.invoice_id)) OR
        ((new_references.invoice_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation (
                new_references.invoice_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.source_refund_id = new_references.source_refund_id)) OR
        ((new_references.source_refund_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_refund_int_pkg.get_pk_for_validation (
                new_references.source_refund_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_refund_int_pkg.get_fk_igs_fi_refund_int (
      old_references.refund_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_refund_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE    refund_id = x_refund_id
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


  PROCEDURE get_fk_igs_fi_refunds (
    x_refund_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE   ((refund_id = x_refund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_RFND_RINT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_refunds;


  PROCEDURE get_fk_igs_fi_inv_int (
    x_invoice_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE   ((invoice_id = x_invoice_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_INV_RINT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_inv_int;


  PROCEDURE get_fk_igs_fi_refund_int (
    x_refund_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE   ((source_refund_id = x_refund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_RINT_RINT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_refund_int;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_refund_id                         IN     NUMBER      ,
    x_voucher_date                      IN     DATE        ,
    x_person_id                         IN     NUMBER      ,
    x_pay_person_id                     IN     NUMBER      ,
    x_dr_gl_ccid                        IN     NUMBER      ,
    x_cr_gl_ccid                        IN     NUMBER      ,
    x_dr_account_cd                     IN     VARCHAR2    ,
    x_cr_account_cd                     IN     VARCHAR2    ,
    x_refund_amount                     IN     NUMBER      ,
    x_fee_type                          IN     VARCHAR2    ,
    x_fee_cal_type                      IN     VARCHAR2    ,
    x_fee_ci_sequence_number            IN     NUMBER      ,
    x_source_refund_id                  IN     NUMBER      ,
    x_invoice_id                        IN     NUMBER      ,
    x_reason                            IN     VARCHAR2    ,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_refund_id,
      x_voucher_date,
      x_person_id,
      x_pay_person_id,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_dr_account_cd,
      x_cr_account_cd,
      x_refund_amount,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_source_refund_id,
      x_invoice_id,
      x_reason,
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
      x_last_update_login ,
      x_gl_date
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.refund_id
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
             new_references.refund_id
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
    x_refund_id                         IN NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat        18-Feb-2003     Enh 2747329 - Payables Intg build - Value of org_id set to NULL
  ||                                  instead of selecting ar_int_org_id from igs_Fi_control. (Removed cur_org)
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE    refund_id                         = x_refund_id;

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

    -- Org Id is set to NULL, instead of inserting the value of
    -- ar_int_org_id from igs_fi_control
    new_references.org_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_refund_id                         => x_refund_id,
      x_voucher_date                      => x_voucher_date,
      x_person_id                         => x_person_id,
      x_pay_person_id                     => x_pay_person_id,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_refund_amount                     => x_refund_amount,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_source_refund_id                  => x_source_refund_id,
      x_invoice_id                        => x_invoice_id,
      x_reason                            => x_reason,
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
      x_gl_date                           => x_gl_date
    );

    INSERT INTO igs_fi_refund_int_all (
      refund_id,
      voucher_date,
      person_id,
      pay_person_id,
      dr_gl_ccid,
      cr_gl_ccid,
      dr_account_cd,
      cr_account_cd,
      refund_amount,
      fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      source_refund_id,
      invoice_id,
      reason,
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
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      gl_date
    ) VALUES (
      new_references.refund_id,
      new_references.voucher_date,
      new_references.person_id,
      new_references.pay_person_id,
      new_references.dr_gl_ccid,
      new_references.cr_gl_ccid,
      new_references.dr_account_cd,
      new_references.cr_account_cd,
      new_references.refund_amount,
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.source_refund_id,
      new_references.invoice_id,
      new_references.reason,
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
      new_references.gl_date
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
    x_refund_id                         IN     NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        voucher_date,
        person_id,
        pay_person_id,
        dr_gl_ccid,
        cr_gl_ccid,
        dr_account_cd,
        cr_account_cd,
        refund_amount,
        fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        source_refund_id,
        invoice_id,
        reason,
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
	gl_date
      FROM  igs_fi_refund_int_all
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
        (tlinfo.voucher_date = x_voucher_date)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.pay_person_id = x_pay_person_id)
        AND ((tlinfo.dr_gl_ccid = x_dr_gl_ccid) OR ((tlinfo.dr_gl_ccid IS NULL) AND (X_dr_gl_ccid IS NULL)))
        AND ((tlinfo.cr_gl_ccid = x_cr_gl_ccid) OR ((tlinfo.cr_gl_ccid IS NULL) AND (X_cr_gl_ccid IS NULL)))
        AND ((tlinfo.dr_account_cd = x_dr_account_cd) OR ((tlinfo.dr_account_cd IS NULL) AND (X_dr_account_cd IS NULL)))
        AND ((tlinfo.cr_account_cd = x_cr_account_cd) OR ((tlinfo.cr_account_cd IS NULL) AND (X_cr_account_cd IS NULL)))
        AND (tlinfo.refund_amount = x_refund_amount)
        AND (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND ((tlinfo.source_refund_id = x_source_refund_id) OR ((tlinfo.source_refund_id IS NULL) AND (X_source_refund_id IS NULL)))
        AND ((tlinfo.invoice_id = x_invoice_id) OR ((tlinfo.invoice_id IS NULL) AND (X_invoice_id IS NULL)))
        AND ((tlinfo.reason = x_reason) OR ((tlinfo.reason IS NULL) AND (X_reason IS NULL)))
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
        AND ((TRUNC(tlinfo.gl_date) = TRUNC(x_gl_date)) OR ((tlinfo.gl_date IS NULL) AND (X_gl_date IS NULL)))
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
    x_refund_id                         IN     NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
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
      x_refund_id                         => x_refund_id,
      x_voucher_date                      => x_voucher_date,
      x_person_id                         => x_person_id,
      x_pay_person_id                     => x_pay_person_id,
      x_dr_gl_ccid                        => x_dr_gl_ccid,
      x_cr_gl_ccid                        => x_cr_gl_ccid,
      x_dr_account_cd                     => x_dr_account_cd,
      x_cr_account_cd                     => x_cr_account_cd,
      x_refund_amount                     => x_refund_amount,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_source_refund_id                  => x_source_refund_id,
      x_invoice_id                        => x_invoice_id,
      x_reason                            => x_reason,
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
      x_last_update_login                 => x_last_update_login ,
      x_gl_date                           => x_gl_date
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

    UPDATE igs_fi_refund_int_all
      SET
        voucher_date                      = new_references.voucher_date,
        person_id                         = new_references.person_id,
        pay_person_id                     = new_references.pay_person_id,
        dr_gl_ccid                        = new_references.dr_gl_ccid,
        cr_gl_ccid                        = new_references.cr_gl_ccid,
        dr_account_cd                     = new_references.dr_account_cd,
        cr_account_cd                     = new_references.cr_account_cd,
        refund_amount                     = new_references.refund_amount,
        fee_type                          = new_references.fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        source_refund_id                  = new_references.source_refund_id,
        invoice_id                        = new_references.invoice_id,
        reason                            = new_references.reason,
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
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date ,
	gl_date                           = new_references.gl_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_id                         IN NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
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
    x_gl_date                           IN     DATE
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column GL_DATE. removed DEFAULT clause
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_refund_int_all
      WHERE    refund_id                         = x_refund_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_refund_id,
        x_voucher_date,
        x_person_id,
        x_pay_person_id,
        x_dr_gl_ccid,
        x_cr_gl_ccid,
        x_dr_account_cd,
        x_cr_account_cd,
        x_refund_amount,
        x_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_source_refund_id,
        x_invoice_id,
        x_reason,
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
	x_gl_date
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_refund_id,
      x_voucher_date,
      x_person_id,
      x_pay_person_id,
      x_dr_gl_ccid,
      x_cr_gl_ccid,
      x_dr_account_cd,
      x_cr_account_cd,
      x_refund_amount,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_source_refund_id,
      x_invoice_id,
      x_reason,
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
      x_mode ,
      x_gl_date
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 27-FEB-2002
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

    DELETE FROM igs_fi_refund_int_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_refund_int_pkg;

/
