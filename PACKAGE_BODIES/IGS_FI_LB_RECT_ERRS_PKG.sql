--------------------------------------------------------
--  DDL for Package Body IGS_FI_LB_RECT_ERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_LB_RECT_ERRS_PKG" AS
/* $Header: IGSSID5B.pls 115.0 2003/06/19 06:32:36 agairola noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_lb_rect_errs%ROWTYPE;
  new_references igs_fi_lb_rect_errs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_lockbox_interface_id              IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_lockbox_name                      IN     VARCHAR2,
    x_receipt_amt                       IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_party_number                      IN     VARCHAR2,
    x_payer_name                        IN     VARCHAR2,
    x_check_cd                          IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_credit_type_cd                    IN     VARCHAR2,
    x_fee_cal_instance_cd               IN     VARCHAR2,
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
    x_adm_application_id                IN     NUMBER,
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
      FROM     igs_fi_lb_rect_errs
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
    new_references.lockbox_receipt_error_id          := x_lockbox_receipt_error_id;
    new_references.lockbox_interface_id              := x_lockbox_interface_id;
    new_references.item_number                       := x_item_number;
    new_references.lockbox_name                      := x_lockbox_name;
    new_references.receipt_amt                       := x_receipt_amt;
    new_references.batch_name                        := x_batch_name;
    new_references.party_number                      := x_party_number;
    new_references.payer_name                        := x_payer_name;
    new_references.check_cd                          := x_check_cd;
    new_references.deposit_date                      := x_deposit_date;
    new_references.credit_type_cd                    := x_credit_type_cd;
    new_references.fee_cal_instance_cd               := x_fee_cal_instance_cd;
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
    new_references.adm_application_id                := x_adm_application_id;
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

    IF (((old_references.lockbox_name = new_references.lockbox_name)) OR
        ((new_references.lockbox_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_lockboxes_pkg.get_pk_for_validation (
                new_references.lockbox_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 05-JUN-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_lb_ovfl_errs_pkg.get_fk_igs_fi_lb_rect_errs (
      old_references.lockbox_receipt_error_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_lockbox_receipt_error_id          IN     NUMBER
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
      FROM     igs_fi_lb_rect_errs
      WHERE    lockbox_receipt_error_id = x_lockbox_receipt_error_id
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
    x_rowid                             IN     VARCHAR2,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_lockbox_interface_id              IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_lockbox_name                      IN     VARCHAR2,
    x_receipt_amt                       IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_party_number                      IN     VARCHAR2,
    x_payer_name                        IN     VARCHAR2,
    x_check_cd                          IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_credit_type_cd                    IN     VARCHAR2,
    x_fee_cal_instance_cd               IN     VARCHAR2,
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
    x_adm_application_id                IN     NUMBER,
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
      x_lockbox_receipt_error_id,
      x_lockbox_interface_id,
      x_item_number,
      x_lockbox_name,
      x_receipt_amt,
      x_batch_name,
      x_party_number,
      x_payer_name,
      x_check_cd,
      x_deposit_date,
      x_credit_type_cd,
      x_fee_cal_instance_cd,
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
      x_adm_application_id,
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
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.lockbox_receipt_error_id
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
             new_references.lockbox_receipt_error_id
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
    x_lockbox_receipt_error_id          IN OUT NOCOPY NUMBER,
    x_lockbox_interface_id              IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_lockbox_name                      IN     VARCHAR2,
    x_receipt_amt                       IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_party_number                      IN     VARCHAR2,
    x_payer_name                        IN     VARCHAR2,
    x_check_cd                          IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_credit_type_cd                    IN     VARCHAR2,
    x_fee_cal_instance_cd               IN     VARCHAR2,
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
    x_adm_application_id                IN     NUMBER,
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_LB_RECT_ERRS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igs_fi_lb_rect_errs_s.NEXTVAL
    INTO x_lockbox_receipt_error_id
    FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_lockbox_receipt_error_id          => x_lockbox_receipt_error_id,
      x_lockbox_interface_id              => x_lockbox_interface_id,
      x_item_number                       => x_item_number,
      x_lockbox_name                      => x_lockbox_name,
      x_receipt_amt                       => x_receipt_amt,
      x_batch_name                        => x_batch_name,
      x_party_number                      => x_party_number,
      x_payer_name                        => x_payer_name,
      x_check_cd                          => x_check_cd,
      x_deposit_date                      => x_deposit_date,
      x_credit_type_cd                    => x_credit_type_cd,
      x_fee_cal_instance_cd               => x_fee_cal_instance_cd,
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
      x_adm_application_id                => x_adm_application_id,
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
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_lb_rect_errs (
      lockbox_receipt_error_id,
      lockbox_interface_id,
      item_number,
      lockbox_name,
      receipt_amt,
      batch_name,
      party_number,
      payer_name,
      check_cd,
      deposit_date,
      credit_type_cd,
      fee_cal_instance_cd,
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
      adm_application_id,
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
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.lockbox_receipt_error_id,
      new_references.lockbox_interface_id,
      new_references.item_number,
      new_references.lockbox_name,
      new_references.receipt_amt,
      new_references.batch_name,
      new_references.party_number,
      new_references.payer_name,
      new_references.check_cd,
      new_references.deposit_date,
      new_references.credit_type_cd,
      new_references.fee_cal_instance_cd,
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
      new_references.adm_application_id,
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
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_lockbox_interface_id              IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_lockbox_name                      IN     VARCHAR2,
    x_receipt_amt                       IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_party_number                      IN     VARCHAR2,
    x_payer_name                        IN     VARCHAR2,
    x_check_cd                          IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_credit_type_cd                    IN     VARCHAR2,
    x_fee_cal_instance_cd               IN     VARCHAR2,
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
    x_adm_application_id                IN     NUMBER,
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
    x_attribute20                       IN     VARCHAR2
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
        lockbox_interface_id,
        item_number,
        lockbox_name,
        receipt_amt,
        batch_name,
        party_number,
        payer_name,
        check_cd,
        deposit_date,
        credit_type_cd,
        fee_cal_instance_cd,
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
        adm_application_id,
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
        attribute20
      FROM  igs_fi_lb_rect_errs
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
        (tlinfo.lockbox_interface_id = x_lockbox_interface_id)
        AND (tlinfo.item_number = x_item_number)
        AND (tlinfo.lockbox_name = x_lockbox_name)
        AND (tlinfo.receipt_amt = x_receipt_amt)
        AND ((tlinfo.batch_name = x_batch_name) OR ((tlinfo.batch_name IS NULL) AND (X_batch_name IS NULL)))
        AND ((tlinfo.party_number = x_party_number) OR ((tlinfo.party_number IS NULL) AND (X_party_number IS NULL)))
        AND ((tlinfo.payer_name = x_payer_name) OR ((tlinfo.payer_name IS NULL) AND (X_payer_name IS NULL)))
        AND ((tlinfo.check_cd = x_check_cd) OR ((tlinfo.check_cd IS NULL) AND (X_check_cd IS NULL)))
        AND ((tlinfo.deposit_date = x_deposit_date) OR ((tlinfo.deposit_date IS NULL) AND (X_deposit_date IS NULL)))
        AND ((tlinfo.credit_type_cd = x_credit_type_cd) OR ((tlinfo.credit_type_cd IS NULL) AND (X_credit_type_cd IS NULL)))
        AND ((tlinfo.fee_cal_instance_cd = x_fee_cal_instance_cd) OR ((tlinfo.fee_cal_instance_cd IS NULL) AND (X_fee_cal_instance_cd IS NULL)))
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
        AND ((tlinfo.adm_application_id = x_adm_application_id) OR ((tlinfo.adm_application_id IS NULL) AND (X_adm_application_id IS NULL)))
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
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_lockbox_interface_id              IN     NUMBER,
    x_item_number                       IN     NUMBER,
    x_lockbox_name                      IN     VARCHAR2,
    x_receipt_amt                       IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_party_number                      IN     VARCHAR2,
    x_payer_name                        IN     VARCHAR2,
    x_check_cd                          IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_credit_type_cd                    IN     VARCHAR2,
    x_fee_cal_instance_cd               IN     VARCHAR2,
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
    x_adm_application_id                IN     NUMBER,
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_LB_RECT_ERRS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_lockbox_receipt_error_id          => x_lockbox_receipt_error_id,
      x_lockbox_interface_id              => x_lockbox_interface_id,
      x_item_number                       => x_item_number,
      x_lockbox_name                      => x_lockbox_name,
      x_receipt_amt                       => x_receipt_amt,
      x_batch_name                        => x_batch_name,
      x_party_number                      => x_party_number,
      x_payer_name                        => x_payer_name,
      x_check_cd                          => x_check_cd,
      x_deposit_date                      => x_deposit_date,
      x_credit_type_cd                    => x_credit_type_cd,
      x_fee_cal_instance_cd               => x_fee_cal_instance_cd,
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
      x_adm_application_id                => x_adm_application_id,
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

    UPDATE igs_fi_lb_rect_errs
      SET
        lockbox_interface_id              = new_references.lockbox_interface_id,
        item_number                       = new_references.item_number,
        lockbox_name                      = new_references.lockbox_name,
        receipt_amt                       = new_references.receipt_amt,
        batch_name                        = new_references.batch_name,
        party_number                      = new_references.party_number,
        payer_name                        = new_references.payer_name,
        check_cd                          = new_references.check_cd,
        deposit_date                      = new_references.deposit_date,
        credit_type_cd                    = new_references.credit_type_cd,
        fee_cal_instance_cd               = new_references.fee_cal_instance_cd,
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
        adm_application_id                = new_references.adm_application_id,
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

    DELETE FROM igs_fi_lb_rect_errs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

END igs_fi_lb_rect_errs_pkg;

/
