--------------------------------------------------------
--  DDL for Package Body IGS_FI_CREDITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CREDITS_PKG" AS
/* $Header: IGSSI86B.pls 120.2 2005/08/08 01:20:45 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_credits_all%ROWTYPE;
  new_references igs_fi_credits_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_id                         IN     NUMBER  ,
    x_credit_number                     IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER  ,
    x_credit_type_id                    IN     NUMBER  ,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER  ,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER  ,
    x_transaction_date                  IN     DATE    ,
    x_effective_date                    IN     DATE    ,
    x_reversal_date                     IN     DATE    ,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER  ,
    x_source_transaction_id             IN     NUMBER  ,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE    ,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER  ,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
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
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER  ,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When             What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  ||  schodava        11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE
  ||  vvutukur       17-Sep-2002       Enh#2564643.Removed references to subaccount_id.Also removed
  ||                                   DEFAULT clause from procedure parameter list.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_CREDITS_ALL
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
    new_references.credit_id                         := x_credit_id;
    new_references.credit_number                     := x_credit_number;
    new_references.status                            := x_status;
    new_references.credit_source                     := x_credit_source;
    new_references.party_id                          := x_party_id;
    new_references.credit_type_id                    := x_credit_type_id;
    new_references.credit_instrument                 := x_credit_instrument;
    new_references.description                       := x_description;
    new_references.amount                            := x_amount;
    new_references.currency_cd                       := x_currency_cd;
    new_references.exchange_rate                     := x_exchange_rate;
    new_references.transaction_date                  := x_transaction_date;
    new_references.effective_date                    := x_effective_date;
    new_references.reversal_date                     := x_reversal_date;
    new_references.reversal_reason_code              := x_reversal_reason_code;
    new_references.reversal_comments                 := x_reversal_comments;
    new_references.unapplied_amount                  := x_unapplied_amount;
    new_references.source_transaction_id             := x_source_transaction_id;
    new_references.receipt_lockbox_number            := x_receipt_lockbox_number;
    new_references.merchant_id                       := x_merchant_id;
    new_references.credit_card_code                  := x_credit_card_code;
    new_references.credit_card_holder_name           := x_credit_card_holder_name;
    new_references.credit_card_number                := x_credit_card_number;
    new_references.credit_card_expiration_date       := x_credit_card_expiration_date;
    new_references.credit_card_approval_code         := x_credit_card_approval_code;
    new_references.awd_yr_cal_type                   := x_awd_yr_cal_type;
    new_references.awd_yr_ci_sequence_number         := x_awd_yr_ci_sequence_number;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
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
    new_references.check_number                      := x_check_number;
    new_references.source_transaction_type           := x_source_transaction_type;
    new_references.source_transaction_ref            := x_source_transaction_ref;
    new_references.credit_card_status_code           := x_credit_card_status_code;
    new_references.credit_card_payee_cd              := x_credit_card_payee_cd;
    new_references.credit_card_tangible_cd           := x_credit_card_tangible_cd;
    new_references.lockbox_interface_id              := x_lockbox_interface_id;
    new_references.batch_name                        := x_batch_name;
    new_references.deposit_date                      := TRUNC(x_deposit_date);
    new_references.source_invoice_id                 := x_source_invoice_id;
    new_references.waiver_name                       := x_waiver_name;

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
    new_references.tax_year_code                     := x_tax_year_code;

  END set_column_values;

  PROCEDURE BeforeRowInsertUpdate AS
  /*
  ||  Created By : VVUTUKUR
  ||  Created On : 14-MAY-2002
  ||  Purpose : For validating reversal date with payment date.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

--If reversal date specified in reversal form is less than payment date of a credit,
    IF TRUNC(new_references.reversal_date) IS NOT NULL THEN
      IF (TRUNC(new_references.reversal_date) < TRUNC(new_references.transaction_date)) THEN
     --Throw error message
        fnd_message.set_name('IGS','IGS_FI_REV_DT_LESS_RECT_DT');
        fnd_message.set_token('REVDATE',TRUNC(new_references.reversal_date));
        fnd_message.set_token('PMTDATE',TRUNC(new_references.transaction_date));
        fnd_message.set_token('CREDIT',new_references.credit_number);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END BeforeRowInsertUpdate;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shtatiko        09-APR-2003     Enh# 2831554, Changed the message to IGS_FI_CREDIT_DUPLICATE
  ||                                  from IGS_GE_RECORD_ALREADY_EXISTS
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.credit_number,
           new_references.party_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_CREDIT_DUPLICATE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build  Added the IGS_FI_WAV_REVERSAL_REASON
  ||                                   lookup code validation
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id - FK with igs_fi_inv_int_all
  ||  vvutukur        16-Jun-2003   Enh#2831582.Lockbox Build. Added check for the column receipt_lockbox_number in parent table.
  ||  shtatiko        09-DEC-2002   Added condition for source_transaction_type.
  ||  vvutukur        17-Aug-2002   Removed call to igs_fi_subaccts_pkg.get_pk_for_validation and
  ||                               related code as part of subaccount.
  ||  smadathi       10-Jun-2002       Bug 2404523. The row share table lock on the table hz_parties
  ||                                   and igf_lookups_view removed.
  ||  sykrishn        8-FEB-2002       Removed get pk for validation
  ||                                   with igs_lookups_view for credit source
  ||                                    and introdiced linek with IGF_LOOKUPS_VIEW - 2191470
                                       SFCR020
  ||  SMVK           04-Feb-2002       Checking included for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_rowid IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = new_references.party_id;


    lv_rowid cur_rowid%RowType;


   CURSOR cur_igf_lookup IS
      SELECT   rowid
      FROM     igf_lookups_view
      WHERE    lookup_type = 'IGF_AW_FED_FUND'
      AND      lookup_code = new_references.credit_source;


    lv_igf_rowid cur_igf_lookup%RowType;

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

    IF (((old_references.status = new_references.status)) OR
        ((new_references.status IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_CREDIT_STATUS',
          new_references.status
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.credit_source = new_references.credit_source)) OR
        ((new_references.credit_source IS NULL))) THEN
             NULL;
    ELSE
     OPEN cur_igf_lookup;
      FETCH cur_igf_lookup INTO lv_igf_rowid;
      IF (cur_igf_lookup%FOUND) THEN
        CLOSE cur_igf_lookup;
      ELSE
        CLOSE cur_igf_lookup;
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.credit_instrument = new_references.credit_instrument)) OR
        ((new_references.credit_instrument IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_CREDIT_INSTRUMENT',
          new_references.credit_instrument
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;
    --Added the IGS_FI_WAV_REVERSAL_REASON lookup code validation as a part of Tution Waiver Build.
    IF (((old_references.reversal_reason_code = new_references.reversal_reason_code)) OR
        ((new_references.reversal_reason_code IS NULL))) THEN
             NULL;
    ELSIF NOT ( IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation('IGS_FI_REVERSAL_REASON',new_references.reversal_reason_code)
                OR IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation('IGS_FI_WAV_REVERSAL_REASON',new_references.reversal_reason_code)
              )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.credit_type_id = new_references.credit_type_id)) OR
        ((new_references.credit_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_cr_types_pkg.get_pk_for_validation (
                new_references.credit_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--removed call to igs_fi_subaccts_pkg.get_pk_for_validation and related code as part of subaccount
--removal build.Enh#2564643.

    IF (
        ((old_references.awd_yr_cal_type = new_references.awd_yr_cal_type) AND
         (old_references.awd_yr_ci_sequence_number = new_references.awd_yr_ci_sequence_number))  OR

        ((new_references.awd_yr_cal_type IS NULL) OR
        (new_references.awd_yr_ci_sequence_number IS NULL))
        ) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.awd_yr_cal_type , new_references.awd_yr_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

   IF (
        ((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number))  OR

        ((new_references.fee_cal_type IS NULL) OR
        (new_references.fee_ci_sequence_number IS NULL))
        ) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_cal_type , new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- Following check of foreign key has been added as part of Deposits Build, Bug# 2584741
    IF (((old_references.source_transaction_type = new_references.source_transaction_type)) OR
        ((new_references.source_transaction_type IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_SOURCE_TRANSACTION_REF',
          new_references.source_transaction_type
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    -- Following check of foreign key has been added as part of Lockbox Build, Enh#2831582.
    IF ((old_references.receipt_lockbox_number = new_references.receipt_lockbox_number) OR
        (new_references.receipt_lockbox_number IS NULL)
        ) THEN
      NULL;
    ELSIF NOT igs_fi_lockboxes_pkg.get_pk_for_validation(new_references.receipt_lockbox_number)THEN
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- Source Invoice Id as a FK with igs_fi_inv_int_all
    IF ((old_references.source_invoice_id = new_references.source_invoice_id) OR
        (new_references.source_invoice_id IS NULL)
        ) THEN
      NULL;
    ELSIF NOT igs_fi_inv_int_pkg.get_pk_for_validation(new_references.source_invoice_id) THEN
      fnd_message.set_name('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance IS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat        11-Aug-2003     Enh 3076768 - Auto Release of Holds
  ||                                  Added call to igs_fi_person_holds_pkg.get_fk_igs_fi_credits_all
  */
  BEGIN

    igs_fi_applications_pkg.get_fk_igs_fi_credits_all (
      old_references.credit_id
    );

    igs_fi_cr_activities_pkg.get_fk_igs_fi_credits_all (
      old_references.credit_id
    );

    igs_fi_otc_charges_pkg.get_fk_igs_fi_credits_all (
      old_references.credit_id
    );

    igs_fi_person_holds_pkg.get_fk_igs_fi_credits_all (
      old_references.credit_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_credit_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pathipat        13-Aug-2003     Enh 3067678 - Auto Release of holds
  ||                                  Removed FOR UPDATE NOWAIT clause in cur_rowid
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE    credit_id = x_credit_id;

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
    x_credit_number                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE    credit_number = x_credit_number
      AND      party_id = x_party_id
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


  PROCEDURE get_fk_igs_fi_cr_types_all (
    x_credit_type_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE   ((credit_type_id = x_credit_type_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_CRDT_CRTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_cr_types_all;

--removed procedure get_fk_igs_fi_subaccts_all as part of subaccount removal build.Enh#2564643.

  PROCEDURE get_fk_igs_ca_inst_1 (
     x_awd_yr_cal_type IN VARCHAR2,
     x_awd_yr_ci_sequence_number IN NUMBER
  ) AS
  /*
  ||  Created By : SMVK
  ||  Created On : 04-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE   (( (awd_yr_cal_type = x_awd_yr_cal_type ) AND ( awd_yr_ci_sequence_number = x_awd_yr_ci_sequence_number) ));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_CRD_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_1;


  PROCEDURE get_fk_igs_ca_inst_2 (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
  ) AS
  /*
  ||  Created By : SMVK
  ||  Created On : 04-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE   (( (fee_cal_type = x_fee_cal_type ) AND ( fee_ci_sequence_number = x_fee_ci_sequence_number) ));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FTCI_CI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_2;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_credit_id                         IN     NUMBER  ,
    x_credit_number                     IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER  ,
    x_credit_type_id                    IN     NUMBER  ,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER  ,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER  ,
    x_transaction_date                  IN     DATE    ,
    x_effective_date                    IN     DATE    ,
    x_reversal_date                     IN     DATE    ,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER  ,
    x_source_transaction_id             IN     NUMBER  ,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE    ,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER  ,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER  ,
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
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER  ,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  ||  schodava        11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref. Removed calls to
  ||                                   check_constraints.
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE. Also added call to
  ||                                   check constraints procedure
  ||  vvutukur    17-Sep-2002   Enh#2564643.Removed references to subaccount_id. Also removed DEFAULT
  ||                            clause from procedure parameter list to avoid gscc warnings.
  ||  vvutukur    14-May-2002   Called newly created private procedure BeforeRowInsertUpdate
  ||                                        which validates reversal date with transaction date.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_credit_id,
      x_credit_number,
      x_status,
      x_credit_source,
      x_party_id,
      x_credit_type_id,
      x_credit_instrument,
      x_description,
      x_amount,
      x_currency_cd,
      x_exchange_rate,
      x_transaction_date,
      x_effective_date,
      x_reversal_date,
      x_reversal_reason_code,
      x_reversal_comments,
      x_unapplied_amount,
      x_source_transaction_id,
      x_receipt_lockbox_number,
      x_merchant_id,
      x_credit_card_code,
      x_credit_card_holder_name,
      x_credit_card_number,
      x_credit_card_expiration_date,
      x_credit_card_approval_code,
      x_awd_yr_cal_type,
      x_awd_yr_ci_sequence_number,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
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
      x_check_number,
      x_source_transaction_type,
      x_source_transaction_ref,
      x_credit_card_status_code,
      x_credit_card_payee_cd,
      x_credit_card_tangible_cd,
      x_lockbox_interface_id,
      x_batch_name,
      x_deposit_date,
      x_source_invoice_id,
      x_tax_year_code,
      x_waiver_name
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.credit_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      BeforeRowInsertUpdate;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.credit_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      BeforeRowInsertUpdate;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      BeforeRowInsertUpdate;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_id                         IN OUT NOCOPY NUMBER,
    x_credit_number                     IN OUT NOCOPY VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_reversal_date                     IN     DATE,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
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
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER  ,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column
  ||  svuppala        9-JUN-2005      Enh 4213629 - The automatic generation of the Receipt Number.
  ||                                  Changed x_credit_number parameter  as IN OUT in Insert row
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  ||  schodava        11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE
  ||  vvutukur       17-Sep-2002   Enh#2564643.Removed references to subaccount_id column as this has been
  ||                               obsoleted.Also removed DEFAULT clause from procedure parameter list
  ||                               to avoid gscc warnings.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE    credit_id                         = x_credit_id;

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

    SELECT    igs_fi_credits_s.NEXTVAL
    INTO      x_credit_id
    FROM      dual;

    SELECT    igs_fi_credit_num_s.NEXTVAL
    INTO      x_credit_number
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_credit_id                         => x_credit_id,
      x_credit_number                     => x_credit_number,
      x_status                            => x_status,
      x_credit_source                     => x_credit_source,
      x_party_id                          => x_party_id,
      x_credit_type_id                    => x_credit_type_id,
      x_credit_instrument                 => x_credit_instrument,
      x_description                       => x_description,
      x_amount                            => x_amount,
      x_currency_cd                       => x_currency_cd,
      x_exchange_rate                     => x_exchange_rate,
      x_transaction_date                  => x_transaction_date,
      x_effective_date                    => x_effective_date,
      x_reversal_date                     => x_reversal_date,
      x_reversal_reason_code              => x_reversal_reason_code,
      x_reversal_comments                 => x_reversal_comments,
      x_unapplied_amount                  => x_unapplied_amount,
      x_source_transaction_id             => x_source_transaction_id,
      x_receipt_lockbox_number            => x_receipt_lockbox_number,
      x_merchant_id                       => x_merchant_id,
      x_credit_card_code                  => x_credit_card_code,
      x_credit_card_holder_name           => x_credit_card_holder_name,
      x_credit_card_number                => x_credit_card_number,
      x_credit_card_expiration_date       => x_credit_card_expiration_date,
      x_credit_card_approval_code         => x_credit_card_approval_code,
      x_awd_yr_cal_type                   => x_awd_yr_cal_type,
      x_awd_yr_ci_sequence_number         => x_awd_yr_ci_sequence_number,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
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
      x_check_number                      => x_check_number,
      x_source_transaction_type           => x_source_transaction_type,
      x_source_transaction_ref            => x_source_transaction_ref,
      x_credit_card_status_code           => x_credit_card_status_code,
      x_credit_card_payee_cd              => x_credit_card_payee_cd,
      x_credit_card_tangible_cd           => x_credit_card_tangible_cd,
      x_lockbox_interface_id              => x_lockbox_interface_id,
      x_batch_name                        => x_batch_name,
      x_deposit_date                      => x_deposit_date,
      x_source_invoice_id                 => x_source_invoice_id,
      x_tax_year_code                     => x_tax_year_code,
      x_waiver_name                       => x_waiver_name
    );

    INSERT INTO igs_fi_credits_all (
      credit_id,
      credit_number,
      status,
      credit_source,
      party_id,
      credit_type_id,
      credit_instrument,
      description,
      amount,
      currency_cd,
      exchange_rate,
      transaction_date,
      effective_date,
      reversal_date,
      reversal_reason_code,
      reversal_comments,
      org_id,
      unapplied_amount,
      source_transaction_id,
      receipt_lockbox_number,
      merchant_id,
      credit_card_code,
      credit_card_holder_name,
      credit_card_number,
      credit_card_expiration_date,
      credit_card_approval_code,
      awd_yr_cal_type,
      awd_yr_ci_sequence_number,
      fee_cal_type,
      fee_ci_sequence_number,
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
      check_number,
      source_transaction_type,
      source_transaction_ref,
      credit_card_status_code,
      credit_card_payee_cd,
      credit_card_tangible_cd,
      lockbox_interface_id,
      batch_name,
      deposit_date,
      source_invoice_id,
      tax_year_code,
      waiver_name
      ) VALUES (
      new_references.credit_id,
      new_references.credit_number,
      new_references.status,
      new_references.credit_source,
      new_references.party_id,
      new_references.credit_type_id,
      new_references.credit_instrument,
      new_references.description,
      new_references.amount,
      new_references.currency_cd,
      new_references.exchange_rate,
      new_references.transaction_date,
      new_references.effective_date,
      new_references.reversal_date,
      new_references.reversal_reason_code,
      new_references.reversal_comments,
      new_references.org_id,
      new_references.unapplied_amount,
      new_references.source_transaction_id,
      new_references.receipt_lockbox_number,
      new_references.merchant_id,
      new_references.credit_card_code,
      new_references.credit_card_holder_name,
      new_references.credit_card_number,
      new_references.credit_card_expiration_date,
      new_references.credit_card_approval_code,
      new_references.awd_yr_cal_type,
      new_references.awd_yr_ci_sequence_number,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
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
      new_references.check_number,
      new_references.source_transaction_type,
      new_references.source_transaction_ref,
      new_references.credit_card_status_code,
      new_references.credit_card_payee_cd,
      new_references.credit_card_tangible_cd,
      new_references.lockbox_interface_id,
      new_references.batch_name,
      new_references.deposit_date,
      new_references.source_invoice_id,
      new_references.tax_year_code,
      new_references.waiver_name
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
    x_credit_id                         IN     NUMBER,
    x_credit_number                     IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_reversal_date                     IN     DATE,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
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
    x_gl_date                           IN     DATE    ,
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column and added the column related changes
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  || schodava         11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE
  ||  vvutukur    17-Sep-2002   Enh#2564643.Removed references to subaccount_id column as this has been
  ||                            obsoleted.Also removed DEFAULT clause from procedure parameter list
  ||                            to avoid gscc warnings.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        credit_number,
        status,
        credit_source,
        party_id,
        credit_type_id,
        credit_instrument,
        description,
        amount,
        currency_cd,
        exchange_rate,
        transaction_date,
        effective_date,
        reversal_date,
        reversal_reason_code,
        reversal_comments,
        unapplied_amount,
        source_transaction_id,
        receipt_lockbox_number,
        merchant_id,
        credit_card_code,
        credit_card_holder_name,
        credit_card_number,
        credit_card_expiration_date,
        credit_card_approval_code,
        awd_yr_cal_type,
        awd_yr_ci_sequence_number,
        fee_cal_type,
        fee_ci_sequence_number,
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
        check_number,
        source_transaction_type,
        source_transaction_ref,
        credit_card_status_code,
        credit_card_payee_cd,
        credit_card_tangible_cd,
        lockbox_interface_id,
        batch_name,
        deposit_date,
        source_invoice_id,
	      tax_year_code,
        waiver_name
      FROM  igs_fi_credits_all
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
        (tlinfo.credit_number = x_credit_number)
        AND (tlinfo.status = x_status)
        AND ((tlinfo.credit_source = x_credit_source) OR ((tlinfo.credit_source IS NULL) AND (X_credit_source IS NULL)))
        AND (tlinfo.party_id = x_party_id)
        AND (tlinfo.credit_type_id = x_credit_type_id)
        AND (tlinfo.credit_instrument = x_credit_instrument)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND (tlinfo.amount = x_amount)
        AND (tlinfo.currency_cd = x_currency_cd)
        AND ((tlinfo.exchange_rate = x_exchange_rate) OR ((tlinfo.exchange_rate IS NULL) AND (X_exchange_rate IS NULL)))
        AND (tlinfo.transaction_date = x_transaction_date)
        AND (tlinfo.effective_date = x_effective_date)
        AND ((tlinfo.reversal_date = x_reversal_date) OR ((tlinfo.reversal_date IS NULL) AND (X_reversal_date IS NULL)))
        AND ((tlinfo.reversal_reason_code = x_reversal_reason_code) OR ((tlinfo.reversal_reason_code IS NULL) AND (X_reversal_reason_code IS NULL)))
        AND ((tlinfo.reversal_comments = x_reversal_comments) OR ((tlinfo.reversal_comments IS NULL) AND (X_reversal_comments IS NULL)))
        AND ((tlinfo.unapplied_amount = x_unapplied_amount) OR ((tlinfo.unapplied_amount IS NULL) AND (X_unapplied_amount IS NULL)))
        AND ((tlinfo.source_transaction_id = x_source_transaction_id) OR ((tlinfo.source_transaction_id IS NULL) AND (X_source_transaction_id IS NULL)))
        AND ((tlinfo.receipt_lockbox_number = x_receipt_lockbox_number) OR ((tlinfo.receipt_lockbox_number IS NULL) AND (X_receipt_lockbox_number IS NULL)))
        AND ((tlinfo.merchant_id = x_merchant_id) OR ((tlinfo.merchant_id IS NULL) AND (X_merchant_id IS NULL)))
        AND ((tlinfo.credit_card_code = x_credit_card_code) OR ((tlinfo.credit_card_code IS NULL) AND (X_credit_card_code IS NULL)))
        AND ((tlinfo.credit_card_holder_name = x_credit_card_holder_name) OR ((tlinfo.credit_card_holder_name IS NULL) AND (X_credit_card_holder_name IS NULL)))
        AND ((tlinfo.credit_card_number = x_credit_card_number) OR ((tlinfo.credit_card_number IS NULL) AND (X_credit_card_number IS NULL)))
        AND ((tlinfo.credit_card_expiration_date = x_credit_card_expiration_date) OR ((tlinfo.credit_card_expiration_date IS NULL) AND (X_credit_card_expiration_date IS NULL)))
        AND ((tlinfo.credit_card_approval_code = x_credit_card_approval_code) OR ((tlinfo.credit_card_approval_code IS NULL) AND (X_credit_card_approval_code IS NULL)))
        AND ((tlinfo.awd_yr_cal_type = x_awd_yr_cal_type) OR ((tlinfo.awd_yr_cal_type IS NULL) AND (X_awd_yr_cal_type IS NULL)))
        AND ((tlinfo.awd_yr_ci_sequence_number = x_awd_yr_ci_sequence_number) OR ((tlinfo.awd_yr_ci_sequence_number IS NULL) AND (X_awd_yr_ci_sequence_number IS NULL)))
        AND ((tlinfo.fee_cal_type = x_fee_cal_type) OR ((tlinfo.fee_cal_type IS NULL) AND (X_fee_cal_type IS NULL)))
        AND ((tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number) OR ((tlinfo.fee_ci_sequence_number IS NULL) AND (X_fee_ci_sequence_number IS NULL)))
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
        AND ((tlinfo.check_number = x_check_number) OR ((tlinfo.check_number IS NULL) AND (x_check_number IS NULL)))
        AND ((tlinfo.source_transaction_type = x_source_transaction_type) OR ((tlinfo.source_transaction_type IS NULL) AND (x_source_transaction_type IS NULL)))
        AND ((tlinfo.source_transaction_ref = x_source_transaction_ref) OR ((tlinfo.source_transaction_ref IS NULL) AND (x_source_transaction_ref IS NULL)))
        AND ((tlinfo.credit_card_status_code = x_credit_card_status_code) OR ((tlinfo.credit_card_status_code IS NULL) AND (x_credit_card_status_code IS NULL)))
        AND ((tlinfo.credit_card_payee_cd = x_credit_card_payee_cd) OR ((tlinfo.credit_card_payee_cd IS NULL) AND (x_credit_card_payee_cd IS NULL)))
        AND ((tlinfo.credit_card_tangible_cd = x_credit_card_tangible_cd) OR ((tlinfo.credit_card_tangible_cd IS NULL) AND (x_credit_card_tangible_cd IS NULL)))
        AND ((tlinfo.lockbox_interface_id = x_lockbox_interface_id) OR ((tlinfo.lockbox_interface_id IS NULL) AND (x_lockbox_interface_id IS NULL)))
        AND ((tlinfo.batch_name = x_batch_name) OR ((tlinfo.batch_name IS NULL) AND (x_batch_name IS NULL)))
        AND ((TRUNC(tlinfo.deposit_date) = TRUNC(x_deposit_date)) OR ((tlinfo.deposit_date IS NULL) AND (x_deposit_date IS NULL)))
        AND ((tlinfo.source_invoice_id = x_source_invoice_id) OR ((tlinfo.source_invoice_id IS NULL) AND (x_source_invoice_id IS NULL)))
        AND ((TRUNC(tlinfo.tax_year_code) = TRUNC(x_tax_year_code)) OR ((tlinfo.tax_year_code IS NULL) AND (x_tax_year_code IS NULL)))
        AND ((tlinfo.waiver_name = x_waiver_name) OR ((tlinfo.waiver_name IS NULL) AND (x_waiver_name IS NULL)))
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
    x_credit_id                         IN     NUMBER,
    x_credit_number                     IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_reversal_date                     IN     DATE,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
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
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER  ,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  ||  schodava        11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE
  ||  vvutukur   17-Sep-2002   Enh#2564643.Removed references to subaccount_id column as this has been
  ||                           obsoleted.Also removed DEFAULT clause from procedure parameter list
  ||                           to avoid gscc warnings.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
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
      x_credit_id                         => x_credit_id,
      x_credit_number                     => x_credit_number,
      x_status                            => x_status,
      x_credit_source                     => x_credit_source,
      x_party_id                          => x_party_id,
      x_credit_type_id                    => x_credit_type_id,
      x_credit_instrument                 => x_credit_instrument,
      x_description                       => x_description,
      x_amount                            => x_amount,
      x_currency_cd                       => x_currency_cd,
      x_exchange_rate                     => x_exchange_rate,
      x_transaction_date                  => x_transaction_date,
      x_effective_date                    => x_effective_date,
      x_reversal_date                     => x_reversal_date,
      x_reversal_reason_code              => x_reversal_reason_code,
      x_reversal_comments                 => x_reversal_comments,
      x_unapplied_amount                  => x_unapplied_amount,
      x_source_transaction_id             => x_source_transaction_id,
      x_receipt_lockbox_number            => x_receipt_lockbox_number,
      x_merchant_id                       => x_merchant_id,
      x_credit_card_code                  => x_credit_card_code,
      x_credit_card_holder_name           => x_credit_card_holder_name,
      x_credit_card_number                => x_credit_card_number,
      x_credit_card_expiration_date       => x_credit_card_expiration_date,
      x_credit_card_approval_code         => x_credit_card_approval_code,
      x_awd_yr_cal_type                   => x_awd_yr_cal_type,
      x_awd_yr_ci_sequence_number         => x_awd_yr_ci_sequence_number,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
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
      x_check_number                      => x_check_number,
      x_source_transaction_type           => x_source_transaction_type,
      x_source_transaction_ref            => x_source_transaction_ref,
      x_credit_card_status_code           => x_credit_card_status_code,
      x_credit_card_payee_cd              => x_credit_card_payee_cd,
      x_credit_card_tangible_cd           => x_credit_card_tangible_cd,
      x_lockbox_interface_id              => x_lockbox_interface_id,
      x_batch_name                        => x_batch_name,
      x_deposit_date                      => x_deposit_date,
      x_source_invoice_id                 => x_source_invoice_id,
      x_tax_year_code                     => x_tax_year_code,
      x_waiver_name                       => x_waiver_name
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

    UPDATE igs_fi_credits_all
      SET
        credit_number                     = new_references.credit_number,
        status                            = new_references.status,
        credit_source                     = new_references.credit_source,
        party_id                          = new_references.party_id,
        credit_type_id                    = new_references.credit_type_id,
        credit_instrument                 = new_references.credit_instrument,
        description                       = new_references.description,
        amount                            = new_references.amount,
        currency_cd                       = new_references.currency_cd,
        exchange_rate                     = new_references.exchange_rate,
        transaction_date                  = new_references.transaction_date,
        effective_date                    = new_references.effective_date,
        reversal_date                     = new_references.reversal_date,
        reversal_reason_code              = new_references.reversal_reason_code,
        reversal_comments                 = new_references.reversal_comments,
        unapplied_amount                  = new_references.unapplied_amount,
        source_transaction_id             = new_references.source_transaction_id,
        receipt_lockbox_number            = new_references.receipt_lockbox_number,
        merchant_id                       = new_references.merchant_id,
        credit_card_code                  = new_references.credit_card_code,
        credit_card_holder_name           = new_references.credit_card_holder_name,
        credit_card_number                = new_references.credit_card_number,
        credit_card_expiration_date       = new_references.credit_card_expiration_date,
        credit_card_approval_code         = new_references.credit_card_approval_code,
        awd_yr_cal_type                   = new_references.awd_yr_cal_type,
        awd_yr_ci_sequence_number         = new_references.awd_yr_ci_sequence_number,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
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
        program_update_date               = x_program_update_date,
        gl_date                           = x_gl_date,
        check_number                      = x_check_number,
        source_transaction_type           = x_source_transaction_type,
        source_transaction_ref            = x_source_transaction_ref,
        credit_card_status_code           = x_credit_card_status_code,
        credit_card_payee_cd              = x_credit_card_payee_cd,
        credit_card_tangible_cd           = x_credit_card_tangible_cd,
        lockbox_interface_id              = x_lockbox_interface_id,
        batch_name                        = x_batch_name,
        deposit_date                      = x_deposit_date,
        source_invoice_id                 = x_source_invoice_id,
	      tax_year_code                     = x_tax_year_code,
        waiver_name                       = x_waiver_name
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_id                         IN OUT NOCOPY NUMBER,
    x_credit_number                     IN OUT NOCOPY VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_credit_source                     IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_credit_instrument                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_currency_cd                       IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_effective_date                    IN     DATE,
    x_reversal_date                     IN     DATE,
    x_reversal_reason_code              IN     VARCHAR2,
    x_reversal_comments                 IN     VARCHAR2,
    x_unapplied_amount                  IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_receipt_lockbox_number            IN     VARCHAR2,
    x_merchant_id                       IN     VARCHAR2,
    x_credit_card_code                  IN     VARCHAR2,
    x_credit_card_holder_name           IN     VARCHAR2,
    x_credit_card_number                IN     VARCHAR2,
    x_credit_card_expiration_date       IN     DATE,
    x_credit_card_approval_code         IN     VARCHAR2,
    x_awd_yr_cal_type                   IN     VARCHAR2,
    x_awd_yr_ci_sequence_number         IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
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
    x_check_number                      IN     VARCHAR2,
    x_source_transaction_type           IN     VARCHAR2,
    x_source_transaction_ref            IN     VARCHAR2,
    x_credit_card_status_code           IN     VARCHAR2,
    x_credit_card_payee_cd              IN     VARCHAR2,
    x_credit_card_tangible_cd           IN     VARCHAR2,
    x_lockbox_interface_id              IN     NUMBER  ,
    x_batch_name                        IN     VARCHAR2,
    x_deposit_date                      IN     DATE,
    x_source_invoice_id                 IN     NUMBER,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : BDEVARAK
  ||  Created On : 26-APR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || uudayapr    8-Aug2005             Enh 3392095 Tution waiver Build
  ||                                   Added the Waiver name column
  ||  svuppala        9-JUN-2005      Enh 4213629 - The automatic generation of the Receipt Number.
  ||                                  Changed x_credit_number parameter  as IN OUT in Add row
  ||  pathipat        20-Apr-2004      Enh 3558549 - Comm Rec Enhancements
  ||                                   Added new column source_invoice_id
  ||  vvutukur        16-Jun-2003      Enh#2831582.Lockbox Build. Added 3 new columns lockbox_interface_id,batch_name,deposit_date.
  ||  schodava        11-Jun-2003      Enh# 2831587, Added three new columns
  ||  shtatiko        03-DEC-2002      Enh Bug 2584741, Added three new columns, check_number,
  ||                                   source_transaction_type and source_transaction_ref
  ||  smadathi        01-Nov-2002      Enh Bug 2584986. Added new column GL_DATE
  ||  vvutukur   17-Sep-2002   Enh#2564643.Removed references to subaccount_id column as this has been
  ||                           obsoleted.Also removed DEFAULT clause from procedure parameter list
  ||                           to avoid gscc warnings.
  ||  SMVK           04-Feb-2002       Updated existing procedure for
  ||                                   Four parameters awd_yr_cal_type
  ||                                   awd_yr_ci_sequence_number
  ||                                   fee_cal_type, fee_ci_sequence_number
  ||                                   Enhancement Bug No.2191470
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_credits_all
      WHERE    credit_id                         = x_credit_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_credit_id,
        x_credit_number,
        x_status,
        x_credit_source,
        x_party_id,
        x_credit_type_id,
        x_credit_instrument,
        x_description,
        x_amount,
        x_currency_cd,
        x_exchange_rate,
        x_transaction_date,
        x_effective_date,
        x_reversal_date,
        x_reversal_reason_code,
        x_reversal_comments,
        x_unapplied_amount,
        x_source_transaction_id,
        x_receipt_lockbox_number,
        x_merchant_id,
        x_credit_card_code,
        x_credit_card_holder_name,
        x_credit_card_number,
        x_credit_card_expiration_date,
        x_credit_card_approval_code,
        x_awd_yr_cal_type,
        x_awd_yr_ci_sequence_number,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
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
        x_check_number,
        x_source_transaction_type,
        x_source_transaction_ref,
        x_credit_card_status_code,
        x_credit_card_payee_cd,
        x_credit_card_tangible_cd,
        x_lockbox_interface_id,
        x_batch_name,
        x_deposit_date,
        x_source_invoice_id,
	      x_tax_year_code,
        x_waiver_name
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_credit_id,
      x_credit_number,
      x_status,
      x_credit_source,
      x_party_id,
      x_credit_type_id,
      x_credit_instrument,
      x_description,
      x_amount,
      x_currency_cd,
      x_exchange_rate,
      x_transaction_date,
      x_effective_date,
      x_reversal_date,
      x_reversal_reason_code,
      x_reversal_comments,
      x_unapplied_amount,
      x_source_transaction_id,
      x_receipt_lockbox_number,
      x_merchant_id,
      x_credit_card_code,
      x_credit_card_holder_name,
      x_credit_card_number,
      x_credit_card_expiration_date,
      x_credit_card_approval_code,
      x_awd_yr_cal_type,
      x_awd_yr_ci_sequence_number,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
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
      x_check_number,
      x_source_transaction_type,
      x_source_transaction_ref,
      x_credit_card_status_code,
      x_credit_card_payee_cd,
      x_credit_card_tangible_cd,
      x_lockbox_interface_id,
      x_batch_name,
      x_deposit_date,
      x_source_invoice_id,
      x_tax_year_code,
      x_waiver_name
    );

  END add_row;

END igs_fi_credits_pkg;

/
