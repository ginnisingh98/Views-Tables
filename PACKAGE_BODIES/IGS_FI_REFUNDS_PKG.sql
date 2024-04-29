--------------------------------------------------------
--  DDL for Package Body IGS_FI_REFUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_REFUNDS_PKG" AS
/* $Header: IGSSIB4B.pls 120.3 2006/06/27 14:18:40 skharida ship $ */

  /*
  ||  Created By : Vinay
  ||  Created On : 26-FEB-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  agairola  29-Aug-2005    Enh 3392095: Tuition Waiver Build, impact of waiver_name in charges table
  ||  svuppala  04-AUG-2005     Enh 3392095 - Tution Waivers build
  ||                            Impact of Charges API version Number change
  ||                            Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  ||  pmarada    26-May-2005 Enh#3020586- added tax year code column as per 1098-t reporting build
  ||  agairola        06-JUN-2002     for bug 2392776 - added update_invoice and modified beforerowinsert
  ||  agairola        14-May-2002     Changed the procedure beforerowinsert for bug 2365356
  ||  agairola        14-May-2002     Changed the call to the Charges API for bugs 2372163,2372122
  ||  (reverse chronological order - newest change first)
  */
--   Bug:  2144600
--   What: Created TBH
--   Who:  vchappid
--   When: 25-Feb-2002

  l_rowid VARCHAR2(25);
  old_references igs_fi_refunds%ROWTYPE;
  new_references igs_fi_refunds%ROWTYPE;

  -- Initial Declaration of the procedure
  PROCEDURE beforerowinsert;

  PROCEDURE update_invoice(p_invoice_id         igs_fi_inv_int.invoice_id%TYPE) AS
    /*
  ||  Created By : Amit.Gairola
  ||  Created On : 06-JUN-2002
  ||  Purpose : Updates the Charge record in case of reversal. Updates the Reversal Flag and the reversal reason
  ||            for bug 2392776
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida    26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL and IGS_FI_REFUNDS
  ||  smadathi    01-Nov-2002     Enh. Bug 2584986. Modified igs_fi_inv_int_pkg.update_row
  ||                              to add new column REVERSAL_GL_DATE
  ||  vvutukur    18-Sep-2002     Enh#2564643.Removed references to subaccount_id.ie., from the call to
  ||                              igs_fi_inv_int_pkg.update_row.
  */

	CURSOR cur_inv(cp_invoice_id     igs_fi_inv_int.invoice_id%TYPE) IS
	  SELECT inv.*
	  FROM   igs_fi_inv_int inv
	  WHERE  inv.invoice_id = cp_invoice_id;

  BEGIN
    IF new_references.source_refund_id IS NOT NULL THEN
	  FOR recinv IN cur_inv(p_invoice_id) LOOP
        igs_fi_inv_int_pkg.update_row (
	              x_rowid                                 => recinv.row_id,
                      x_invoice_id                   	      => recinv.invoice_id,
                      x_person_id                    	      => recinv.person_id,
                      x_fee_type                     	      => recinv.fee_type,
                      x_fee_cat                      	      => recinv.fee_cat,
                      x_fee_cal_type                 	      => recinv.fee_cal_type,
                      x_fee_ci_sequence_number       	      => recinv.fee_ci_sequence_number,
                      x_course_cd                    	      => recinv.course_cd,
                      x_attendance_mode              	      => recinv.attendance_mode,
                      x_attendance_type              	      => recinv.attendance_type,
                      x_invoice_amount_due           	      => recinv.invoice_amount_due,
                      x_invoice_creation_date        	      => recinv.invoice_creation_date,
                      x_invoice_desc                 	      => recinv.invoice_desc,
                      x_transaction_type             	      => recinv.transaction_type,
                      x_currency_cd                  	      => recinv.currency_cd,
                      x_status                       	      => recinv.status,
                      x_attribute_category           	      => recinv.attribute_category,
                      x_attribute1                   	      => recinv.attribute1,
                      x_attribute2                   	      => recinv.attribute2,
                      x_attribute3                   	      => recinv.attribute3,
                      x_attribute4                   	      => recinv.attribute4,
                      x_attribute5                   	      => recinv.attribute5,
                      x_attribute6                   	      => recinv.attribute6,
                      x_attribute7                   	      => recinv.attribute7,
                      x_attribute8                   	      => recinv.attribute8,
                      x_attribute9                   	      => recinv.attribute9,
                      x_attribute10                  	      => recinv.attribute10,
                      x_invoice_amount               	      => recinv.invoice_amount,
                      x_bill_id                      	      => recinv.bill_id,
                      x_bill_number                  	      => recinv.bill_number,
                      x_bill_date                    	      => recinv.bill_date,
                      x_waiver_flag                  	      => 'Y',
                      x_waiver_reason                	      => 'MANUAL_REFUND',
                      x_effective_date               	      => recinv.effective_date,
                      x_invoice_number               	      => recinv.invoice_number,
                      x_exchange_rate                	      => recinv.exchange_rate,
                      x_bill_payment_due_date        	      => recinv.bill_payment_due_date,
                      x_optional_fee_flag                     => recinv.optional_fee_flag,
                      x_mode                         	      => 'R',
		      x_reversal_gl_date                      =>  new_references.gl_date,
                      x_tax_year_code                         =>  recinv.tax_year_code,
		      x_waiver_name                           =>  recinv.waiver_name
                    );

      END LOOP;
    END IF;
  END update_invoice;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_refund_id                         IN     NUMBER  ,
    x_voucher_date                      IN     DATE    ,
    x_person_id                         IN     NUMBER  ,
    x_pay_person_id                     IN     NUMBER  ,
    x_dr_gl_ccid                        IN     NUMBER  ,
    x_cr_gl_ccid                        IN     NUMBER  ,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER  ,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
    x_source_refund_id                  IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_gl_date                           IN     DATE    ,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*******************************
   who          when               what
   smadathi     06-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
   Bug:  2144600
   What: Created TBH
   Who:  vchappid
   When: 25-Feb-2002
   skharida 26-Jun-2006  Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
   vvutukur 23-Sep-2002  removed default clause from parameters as gscc fix.
   **********************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_refunds
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
    new_references.transfer_status                   := x_transfer_status;
    new_references.reversal_ind                      := x_reversal_ind;
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
    new_references.reversal_gl_date                  := TRUNC(x_reversal_gl_date);

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
  ||  Created By :
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.pay_person_id,
           new_references.fee_type,
           new_references.fee_cal_type,
           new_references.fee_ci_sequence_number,
           new_references.reversal_ind,
           new_references.invoice_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
      CURSOR cur_rowid (cp_party_id hz_parties.party_id%TYPE) IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = cp_party_id
      FOR UPDATE NOWAIT;

      lv_rowid cur_rowid%RowType;

  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_rowid(new_references.person_id);
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

    IF (((old_references.pay_person_id = new_references.pay_person_id)) OR
        ((new_references.pay_person_id IS NULL))) THEN
      NULL;
    ELSE
      OPEN cur_rowid(new_references.pay_person_id);
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

    IF (((old_references.transfer_status = new_references.transfer_status)) OR
        ((new_references.transfer_status IS NULL))) THEN
             NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation('REFUND_TRANSFER_STATUS',
                                                         new_references.transfer_status)THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
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

    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation ( new_references.fee_type,
                                                               new_references.fee_cal_type,
                                                               new_references.fee_ci_sequence_number ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.source_refund_id = new_references.source_refund_id)) OR
        ((new_references.source_refund_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_refunds_pkg.get_pk_for_validation (
                new_references.source_refund_id
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

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By :
  ||  Created On : 26-FEB-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_fi_refunds_pkg.get_fk_igs_fi_refunds (
      old_references.refund_id
    );

    igs_fi_refund_int_pkg.get_fk_igs_fi_refunds (
      old_references.refund_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_refund_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : 2144600
  ||  Created On : 26-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refunds
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


  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_reversal_ind                      IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refunds
      WHERE    person_id = x_person_id
      AND      pay_person_id = x_pay_person_id
      AND      fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      ((invoice_id = x_invoice_id) OR (invoice_id IS NULL AND x_invoice_id IS NULL))
      AND      ((reversal_ind = x_reversal_ind) OR (reversal_ind IS NULL AND x_reversal_ind IS NULL))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_fi_refunds (
    x_refund_id                         IN     NUMBER
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refunds
      WHERE   ((source_refund_id = x_refund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_RFND_RFND_FK');
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
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || skharida    26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_refunds
      WHERE   ((invoice_id = x_invoice_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_INV_RFND_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_inv_int;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_refund_id                         IN     NUMBER  ,
    x_voucher_date                      IN     DATE    ,
    x_person_id                         IN     NUMBER  ,
    x_pay_person_id                     IN     NUMBER  ,
    x_dr_gl_ccid                        IN     NUMBER  ,
    x_cr_gl_ccid                        IN     NUMBER  ,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER  ,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
    x_source_refund_id                  IN     NUMBER  ,
    x_invoice_id                        IN     NUMBER  ,
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_gl_date                           IN     DATE    ,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida  26-Jun-2006   Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  ||   smadathi 06-Nov-2002   Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
  ||  vvutukur  23-Sep-2002   Enh#2564643.Removed default clause as gscc fix.
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
      x_transfer_status,
      x_reversal_ind,
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
      x_gl_date,
      x_reversal_gl_date
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
      check_uniqueness;
      check_parent_existance;
      beforerowinsert;
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
             new_references.refund_id
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
    x_refund_id                         IN OUT NOCOPY NUMBER,
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
    x_invoice_id                        IN OUT NOCOPY NUMBER,
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_gl_date                           IN     DATE    ,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida   26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  ||  smadathi   06-Nov-2002    Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
  ||  vvutukur   23-Sep-2002    Enh#2564643.Removed default clause from parameters as gscc fix.
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_refunds
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

    SELECT    igs_fi_refunds_s.NEXTVAL
    INTO      x_refund_id
    FROM      dual;

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
      x_transfer_status                   => x_transfer_status,
      x_reversal_ind                      => x_reversal_ind,
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
      x_gl_date                           => x_gl_date,
      x_reversal_gl_date                  => x_reversal_gl_date
    );

    INSERT INTO igs_fi_refunds (
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
      transfer_status,
      reversal_ind,
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
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      gl_date,
      reversal_gl_date
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
      new_references.transfer_status,
      new_references.reversal_ind,
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
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.gl_date,
      new_references.reversal_gl_date
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    x_invoice_id := new_references.invoice_id;
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
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_gl_date                           IN     DATE,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  skharida   26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  ||  smadathi   06-Nov-2002    Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
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
        transfer_status,
        reversal_ind,
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
	gl_date,
	reversal_gl_date
      FROM  igs_fi_refunds
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
        AND ((tlinfo.transfer_status = x_transfer_status) OR ((tlinfo.transfer_status IS NULL) AND (X_transfer_status IS NULL)))
        AND ((tlinfo.reversal_ind = x_reversal_ind) OR ((tlinfo.reversal_ind IS NULL) AND (X_reversal_ind IS NULL)))
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
        AND ((TRUNC(tlinfo.reversal_gl_date) = TRUNC(x_reversal_gl_date)) OR ((tlinfo.reversal_gl_date IS NULL) AND (X_reversal_gl_date IS NULL)))
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
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_gl_date                           IN     DATE,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*
  ||  Created By :
  ||  Created On : 26-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida   26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  ||  smadathi   06-Nov-2002    Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
  ||  vvutukur   23-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
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
      x_transfer_status                   => x_transfer_status,
      x_reversal_ind                      => x_reversal_ind,
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
      x_gl_date                           => x_gl_date,
      x_reversal_gl_date                  => x_reversal_gl_date
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

    UPDATE igs_fi_refunds
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
        transfer_status                   = new_references.transfer_status,
        reversal_ind                      = new_references.reversal_ind,
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
	gl_date                           = new_references.gl_date,
	reversal_gl_date                  = new_references.reversal_gl_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_id                         IN OUT NOCOPY NUMBER,
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
    x_invoice_id                        IN OUT NOCOPY NUMBER,
    x_transfer_status                   IN     VARCHAR2,
    x_reversal_ind                      IN     VARCHAR2,
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
    x_gl_date                           IN     DATE,
    x_reversal_gl_date                  IN     DATE
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida   26-Jun-2006    Bug# 5208136 - Removed the obsoleted columns of the table IGS_FI_REFUNDS
  ||  smadathi   06-Nov-2002    Enh. Bug 2584986. Added new column GL_DATE,REVERSAL_GL_DATE
  ||  vvutukur   23-Sep-2002   Enh#2564643.Removed DEFAULT clause from parameters as gscc fix.
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_refunds
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
        x_transfer_status,
        x_reversal_ind,
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
	x_gl_date,
	x_reversal_gl_date
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
      x_transfer_status,
      x_reversal_ind,
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
      x_gl_date,
      x_reversal_gl_date
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
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

    DELETE FROM igs_fi_refunds
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

PROCEDURE beforerowinsert
AS
  /*
  ||  Created By : vchappid
  ||  Created On : 26-FEB-2002
  ||  Purpose : Before a record is created in the igs_fi_refunds table, a charge record has to be created
  ||            call to charges api is made.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || svuppala        04-AUG-2005    Enh 3392095 - Tution Waivers build
  ||                                Impact of Charges API version Number change
  ||                                Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  ||  vvutukur        24-Dec-2002   Bug#2713315.Used FND_MESSAGE.SET_ENCODED to encode the token value, if charges api
  ||                                returned some error message.
  ||  smadathi        06-Nov-2002   Enh. Bug 2584986. Modified charges API call to Add new parameter GL_DATE
  ||                                Cursor CUR_CURRENCY  declaration and its usage removed and replaced by
  ||                                call to igs_fi_gen_gl.finp_get_cur
  ||  vvutukur        18-Sep-2002   Enh#2564643.Removed references to subaccount_id from cur_subaccount
  ||                                cursor,p_header_rec record type parameter of call to charges api.
  ||                                Renamed the cursor cur_subaccount to cur_ft_desc as this cursor
  ||                                no longer refers to subaccount_id.Modified at its usage also.
  ||  agairola        06-Jun-2002     for bug 2392776 - added the call to the Updateinvoice procedure
  ||  agairola        14-May-2002     For bug 2365356, if the Invoice Id is null, then copy the new_references.invoiceid
  ||  agairola        14-May-2002     Following modifications were done for the bugs 2372163,2372122
  ||                                  1. Modified the cursor cur_subaccount to fetch the Fee Type Description
  ||                                  2. The Fee Type description is passed to Charges API
  ||                                  3. The Effective Date is passed as the Voucher Date
  ||  (reverse chronological order - newest change first)
  */
  -- Variables added for the Charges API call
    l_header_rec                       igs_fi_charges_api_pvt.header_rec_type;
    l_line_tbl                         igs_fi_charges_api_pvt.line_tbl_type;
    l_line_id_tbl                      igs_fi_charges_api_pvt.line_id_tbl_type;
    l_invoice_id                       igs_fi_inv_int.invoice_id%TYPE;
    l_description                      igs_fi_fee_type.description%TYPE;
    l_return_status                    VARCHAR2(1);
    l_msg_count                        NUMBER(3);
    l_msg_data                         VARCHAR2(2000);
    l_msg                              VARCHAR2(2000);
    l_currency_cd                      igs_fi_control_all.currency_cd%TYPE;
    l_currency_desc                    fnd_currencies_tl.name%TYPE;

    -- Cursor for Fetching the description of the Fee Type in context
    CURSOR cur_ft_desc(cp_fee_type igs_fi_fee_type.fee_type%TYPE) IS
      SELECT description
      FROM   igs_fi_fee_type
      WHERE  fee_type = cp_fee_type;

    -- Getting the Charge Method and GL Code/ CCID's associated for a fee type
    CURSOR cur_chg_mthd(cp_fee_type                igs_fi_f_typ_ca_inst.fee_type%TYPE,
                        cp_fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) IS
    SELECT s_chg_method_type,
           rec_gl_ccid,
           rec_account_cd
    FROM  igs_fi_f_typ_ca_inst
    WHERE fee_type = cp_fee_type
    AND   fee_cal_type = cp_fee_cal_type
    AND   fee_ci_sequence_number = cp_fee_ci_sequence_number;

    l_cur_chg_mthd cur_chg_mthd%ROWTYPE;

    l_override_dr_rec_ccid           igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE;
    l_override_dr_account_cd         igs_fi_f_typ_ca_inst.rec_account_cd%TYPE;
    l_override_cr_rev_ccid           igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE;
    l_override_cr_account_cd         igs_fi_f_typ_ca_inst.rec_account_cd%TYPE;

    l_rec_installed                  igs_fi_control_all.rec_installed%TYPE;
    l_message_name                   fnd_new_messages.message_name%TYPE;

    l_n_waiver_amount                NUMBER;

BEGIN

  -- The  procedure igs_fi_gen_gl.finp_get_cur returns Currency code and currency description
  -- If no set up has been done in the System Options form, the procedure returns error message

  igs_fi_gen_gl.finp_get_cur( p_v_currency_cd    =>  l_currency_cd   ,
                              p_v_curr_desc      =>  l_currency_desc ,
                              p_v_message_name   =>  l_message_name
			    );

  IF l_currency_cd IS NULL AND l_message_name IS NOT NULL
  THEN
     fnd_message.set_name('IGS',l_message_name);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
  END IF;

  -- Fetch the Fee Type description
  OPEN cur_ft_desc(new_references.fee_type);
  FETCH cur_ft_desc INTO l_description;
  CLOSE cur_ft_desc;

  OPEN cur_chg_mthd(new_references.fee_type,new_references.fee_cal_type,new_references.fee_ci_sequence_number);
  FETCH cur_chg_mthd INTO l_cur_chg_mthd;
  CLOSE cur_chg_mthd;

   -- Checking which Account Receivables is installed at the client side and insert into corresponding columns accordingly
   l_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;

   IF (NVL(l_rec_installed,'N') ='Y') THEN
     l_override_dr_rec_ccid    := l_cur_chg_mthd.rec_gl_ccid;
     l_override_dr_account_cd  := NULL;
     l_override_cr_rev_ccid    := new_references.dr_gl_ccid;
     l_override_cr_account_cd  := NULL;
   ELSE
     l_override_dr_rec_ccid    :=  NULL;
     l_override_dr_account_cd  :=  l_cur_chg_mthd.rec_account_cd;
     l_override_cr_rev_ccid    :=  NULL;
     l_override_cr_account_cd  :=  new_references.dr_account_cd;
   END IF;

   -- assign the relevant parameters to the charges API Header Record
   l_header_rec.p_person_id                     := new_references.person_id;
   l_header_rec.p_fee_type                      := new_references.fee_type;
   l_header_rec.p_fee_cat                       := NULL;
   l_header_rec.p_fee_cal_type                  := new_references.fee_cal_type;
   l_header_rec.p_fee_ci_sequence_number        := new_references.fee_ci_sequence_number;
   l_header_rec.p_course_cd                     := NULL;
   l_header_rec.p_attendance_type               := NULL;
   l_header_rec.p_attendance_mode               := NULL;
   l_header_rec.p_invoice_amount                := new_references.refund_amount;
   l_header_rec.p_invoice_creation_date         := new_references.voucher_date;
   l_header_rec.p_effective_date                := new_references.voucher_date;
   l_header_rec.p_invoice_desc                  := l_description;
   l_header_rec.p_transaction_type              := 'REFUND';
   l_header_rec.p_currency_cd                   := l_currency_cd;
   l_header_rec.p_exchange_rate                 := 1;
   l_header_rec.p_waiver_flag                   := NULL;
   l_header_rec.p_waiver_reason                 := NULL;
   l_header_rec.p_source_transaction_id         := new_references.invoice_id;

   -- assign the relevant parameters to the charges API Detail Record
   l_line_tbl(1).p_description                  := l_description;
   l_line_tbl(1).p_amount                       := new_references.refund_amount;
   l_line_tbl(1).p_chg_elements                 := 1;
   l_line_tbl(1).p_uoo_id                       := NULL;
   l_line_tbl(1).p_eftsu                        := NULL;
   l_line_tbl(1).p_credit_points                := 1;
   l_line_tbl(1).p_org_unit_cd                  := NULL;
   l_line_tbl(1).p_attribute_category           := NULL;
   l_line_tbl(1).p_override_dr_rec_ccid         := l_override_dr_rec_ccid;
   l_line_tbl(1).p_override_cr_rev_ccid         := l_override_cr_rev_ccid;
   l_line_tbl(1).p_override_dr_rec_account_cd   := l_override_dr_account_cd;
   l_line_tbl(1).p_override_cr_rev_account_cd   := l_override_cr_account_cd;
   l_line_tbl(1).p_attribute1                   := NULL;
   l_line_tbl(1).p_attribute2                   := NULL;
   l_line_tbl(1).p_attribute3                   := NULL;
   l_line_tbl(1).p_attribute4                   := NULL;
   l_line_tbl(1).p_attribute5                   := NULL;
   l_line_tbl(1).p_attribute6                   := NULL;
   l_line_tbl(1).p_attribute7                   := NULL;
   l_line_tbl(1).p_attribute8                   := NULL;
   l_line_tbl(1).p_attribute9                   := NULL;
   l_line_tbl(1).p_attribute10                  := NULL;
   l_line_tbl(1).p_attribute11                  := NULL;
   l_line_tbl(1).p_attribute12                  := NULL;
   l_line_tbl(1).p_attribute13                  := NULL;
   l_line_tbl(1).p_attribute14                  := NULL;
   l_line_tbl(1).p_attribute15                  := NULL;
   l_line_tbl(1).p_attribute16                  := NULL;
   l_line_tbl(1).p_attribute17                  := NULL;
   l_line_tbl(1).p_attribute18                  := NULL;
   l_line_tbl(1).p_attribute19                  := NULL;
   l_line_tbl(1).p_attribute20                  := NULL;
   l_line_tbl(1).p_d_gl_date                    := new_references.gl_date;

   igs_fi_charges_api_pvt.create_charge(p_api_version               => 2.0,
                                        p_init_msg_list             => 'F',
                                        p_commit                    => 'F',
                                        p_header_rec                => l_header_rec,
                                        p_line_tbl                  => l_line_tbl,
                                        x_line_id_tbl               => l_line_id_tbl,
                                        x_invoice_id                => l_invoice_id,
                                        x_return_status             => l_return_status,
                                        x_msg_count                 => l_msg_count,
                                        x_msg_data                  => l_msg_data,
                                        x_waiver_amount             => l_n_waiver_amount);

    IF l_return_status <> 'S' THEN
     IF l_msg_count = 1 THEN
       FND_MESSAGE.SET_ENCODED(l_msg_data);
       l_msg := fnd_message.get;
       FND_MESSAGE.Set_Name('IGS',
                            'IGS_FI_ERR_TXT');
       FND_MESSAGE.Set_Token('TEXT',
                             l_msg);
       IGS_GE_MSG_STACK.Add;
       APP_EXCEPTION.RAISE_EXCEPTION;
     ELSE
       FOR l_count IN 1 .. l_msg_count LOOP
         l_msg := l_msg||FND_MSG_PUB.GET (p_msg_index => l_count, p_encoded => 'T');
       END LOOP;
       FND_MESSAGE.Set_Name('IGS',
                            'IGS_FI_ERR_TXT');
       FND_MESSAGE.Set_Token('TEXT',
                              l_msg);
       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
   ELSE
       new_references.invoice_id := NVL(l_invoice_id,new_references.invoice_id);

	   -- Update the Invoice Record by calling the Update Invoice procedure
	   update_invoice(new_references.invoice_id);
   END IF;
END beforerowinsert;
END igs_fi_refunds_pkg;

/
