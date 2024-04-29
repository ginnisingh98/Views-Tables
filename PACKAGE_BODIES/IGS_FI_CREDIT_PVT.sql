--------------------------------------------------------
--  DDL for Package Body IGS_FI_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CREDIT_PVT" AS
/* $Header: IGSFI83B.pls 120.11 2006/05/16 23:57:15 pathipat ship $ */

  /*----------------------------------------------------------------------------
  ||  Created By : vvutukur
  ||  Created On : 03-Apr-2003
  ||  Purpose : Private API for creating credit and deposit transactions.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat       17-May-2006      Bug 5104599 - Modified create_credit
  ||  sapanigr       03-May-2006      Enh#3924836 Precision Issue. Modified create_credit.
      uudayapr       8-Oct-2005       BUG 4660773 Commentted the Code LOgic introduced as part of Credit Card Enryption enhancement
  ||   gurprsin      26-Sep-2005      Bug 4607540, In create_credit, Credit Card Enryption enhancement, Modified the call to igs_fi_credits_pkg.insert_row method.
  ||   gurprsin      13-Sep-2005      Bug 3627209, After calling build accounts process, Added message on to the stack before adding it on to the fnd_message_pub.
  ||   pmarada       26-JUL-2005      Enh 3392095, modifed as per tution waiver build, passing p_api_version
  ||                                  parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  ||  svuppala         9-JUN-2005     Enh 4213629 - The automatic generation of the Receipt Number.
  ||                                  Added x_credit_number OUT parameter
  ||  bannamal        03-Jun-2005     Bug#3442712 Unit Level Fee Assessment Build. Modified the call
                                      to igs_fi_prc_acct_pkg.build_accounts to add new paramters.
  ||  pathipat        22-Apr-2004     Enh 3558549 - Comm Receivables Enhancements
  ||                                  Modified TBH call to igs_fi_credits_pkg in create_credit()
  ||  vvutukur        14-Sep-2003     Enh#3045007.Payment Plans Build. Modified create_credit.
  ||  pathipat        13-Aug-2003     Enh 3076768 - Automatic Release of Holds
  ||                                  Proc create_credit(): Added call to finp_auto_release_holds()
  ||  vvutukur        16-Jun-2003     Enh#2831582.Lockbox Build. Modified create_credit procedure.
  ||  schodava        11-Jun-2003     Enh# 2831587. Modified the create_credit procedure
  ||  shtatiko        30-APR-2003     Enh# 2831569, Modified create_credit
  ||  vchappid        19-May-2003     Build Bug# 2831572, Financial Accounting Enhancements
  ||                                  New Parameters - Attendance Type, Attendance Mode, Residency Status Code
  ||                                  added in procedure create_credit
  ----------------------------------------------------------------------------*/

  PROCEDURE create_credit(  p_api_version                 IN            NUMBER,
                            p_init_msg_list               IN            VARCHAR2,
                            p_commit                      IN            VARCHAR2,
                            p_validation_level            IN            NUMBER,
                            x_return_status               OUT NOCOPY    VARCHAR2,
                            x_msg_count                   OUT NOCOPY    NUMBER,
                            x_msg_data                    OUT NOCOPY    VARCHAR2,
                            p_credit_rec                  IN            credit_rec_type,
                            p_attribute_record            IN            igs_fi_credits_api_pub.attribute_rec_type,
                            x_credit_id                   OUT NOCOPY    igs_fi_credits_all.credit_id%TYPE,
                            x_credit_activity_id          OUT NOCOPY    igs_fi_cr_activities.credit_activity_id%TYPE,
                            x_credit_number               OUT NOCOPY    igs_fi_credits_all.credit_number%TYPE
                          ) AS
  /*----------------------------------------------------------------------------
  ||  Created By : vvutukur
  ||  Created On : 03-Apr-2003
  ||  Purpose : Private API for creating credit and deposit transactions.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pathipat       17-May-2006      Bug 5104599 - After call to igs_fi_prc_balances.update_balances, added condition to not raise
  ||                                  exception if the messages were regd exclusion of credit types or fee types
  ||  svuppala       05-May-2006      Enh#3924836 Precision Issue. Done the formatting of amount in the beginning itslef
  ||  sapanigr       03-May-2006      Enh#3924836 Precision Issue. Amount values being inserted to igs_fi_credits and
  ||                                  igs_fi_cr_activities_pkg are now rounded off to currency precision
      uudayapr       8-Oct-2005       BUG 4660773 Commentted the Code LOgic introduced as part of Credit Card Enryption enhancement
  ||  gurprsin      26-Sep-2005      Bug 4607540, Credit Card Enryption enhancement, Modified the call to igs_fi_credits_pkg.insert_row method.
  ||  pmarada       26-JUL-2005      Enh 3392095, modifed as per tution waiver build, passing p_api_version
  ||                                  parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  ||  svuppala         9-JUN-2005     Enh 4213629 - The automatic generation of the Receipt Number.
  ||                                  Added x_credit_number OUT parameter
  ||  pathipat        22-Apr-2004     Enh 3558549 - Comm Receivables Enhancements
  ||                                  Added param x_source_invoice_id in call to igs_fi_credits_pkg.insert_row()
  ||                                  Modified IF condition in validation of p_invoice_id.
  ||  vvutukur        14-Sep-2003     Enh#3045007.Payment Plans Build. Changes as specified in TD.
  ||  pathipat        13-Aug-2003     Enh 3076768 - Automatic Release of Holds
  ||                                  Added call to finp_auto_release_holds()
  ||  vvutukur        16-Jun-2003     Enh#2831582.Lockbox Build. Added 3 new paramters lockbox_interface_id,batch_name,deposit_date
  ||                                  in the TBH call igs_fi_credits_pkg.insert_row.
  ||  shtatiko        30-APR-2003     Enh# 2831569, Added check for Manage Accounts
  ||                                  System Option. If its value is NULL then this will
  ||                                  error out. If its value is OTHER then it tries
  ||                                  to create a credit but doesn't update Standard
  ||                                  or Holds Balance for the person in context.
  ||  vchappid        19-May-2003     Build Bug# 2831572, Financial Accounting Enhancements
  ||                                  New Parameters - Attendance Type, Attendance Mode, Residency Status Code
  ||                                  added in procedure create_credit
  ----------------------------------------------------------------------------*/

  --Cursors used in this procedure

    --Cursor to derive revenue account from the credit account of source charge transaction.
    CURSOR cur_override_dr(cp_invoice_id   igs_fi_invln_int_all.invoice_id%TYPE) IS
      SELECT rev_account_cd, rev_gl_ccid
      FROM   igs_fi_invln_int_all
      WHERE  invoice_id = cp_invoice_id;

    --Cursor to fetch the admission application number for an application id and person id.
    CURSOR cur_adm_app_num ( cp_application_id igs_ad_appl.application_id%TYPE,
                             cp_person_id      igs_ad_appl.person_id%TYPE
                            )IS
      SELECT admission_appl_number
      FROM   igs_ad_appl_all
      WHERE  person_id      = cp_person_id
      AND    application_id = cp_application_id;

    -- Cursor to get the waiver name, fee cal type for the passed waiver name
   CURSOR cur_waiver_pgms (cp_fee_cal_type igs_fi_waiver_pgms.fee_cal_type%TYPE,
                           cp_fee_ci_sequence_number igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
                           cp_waiver_name igs_fi_waiver_pgms.waiver_name%TYPE ) IS
   SELECT fwp.fee_cal_type, fwp.fee_ci_sequence_number, fwp.waiver_name
   FROM igs_fi_waiver_pgms fwp
   WHERE fwp.fee_cal_type = cp_fee_cal_type
   AND fwp.fee_ci_sequence_number = cp_fee_ci_sequence_number
   AND fwp.waiver_name = cp_waiver_name;

   l_waiver_pgms cur_waiver_pgms%ROWTYPE;
    --Local Variables declaration part.
    l_pkg_name                 CONSTANT  VARCHAR2(30) := 'IGS_FI_CREDIT_PVT';
    l_api_version              CONSTANT  NUMBER := 2.1;
    l_api_name                 CONSTANT  VARCHAR2(30) := 'create_credit';
    l_credit                   CONSTANT  VARCHAR2(10) := 'CREDIT';
    l_standard                 CONSTANT  igs_fi_balance_rules.balance_name%TYPE  := 'STANDARD';
    l_hold                     CONSTANT  igs_fi_balance_rules.balance_name%TYPE := 'HOLDS';
    l_v_action_active          CONSTANT  VARCHAR2(10) := 'ACTIVE';

    l_b_return_status            BOOLEAN;
    l_d_last_conversion_date     DATE;
    l_d_transaction_date         DATE;
    l_d_effective_date           DATE;

    l_n_cnv_prc                  igs_fi_control_all.conv_process_run_ind%TYPE := NULL;
    l_n_version_number           igs_fi_balance_rules.version_number%TYPE;
    l_n_balance_rule_id          igs_fi_balance_rules.balance_rule_id%TYPE;
    l_v_message_name             fnd_new_messages.message_name%TYPE := NULL;
    l_v_currency_cd              igs_fi_control_all.currency_cd%TYPE := NULL;
    l_n_amount                   igs_fi_credits_all.amount%TYPE;

    l_n_dr_gl_ccid               igs_fi_cr_activities.dr_gl_ccid%TYPE;
    l_n_cr_gl_ccid               igs_fi_cr_activities.cr_gl_ccid%TYPE;
    l_v_dr_account_cd            igs_fi_cr_activities.dr_account_cd%TYPE;
    l_v_cr_account_cd            igs_fi_cr_activities.cr_account_cd%TYPE;
    l_n_err_type                 NUMBER(2) := NULL;
    l_v_err_string               VARCHAR2(2000) := NULL;

    l_rec_cur_override_dr        cur_override_dr%ROWTYPE;
    l_v_credit_class             igs_fi_cr_types_all.credit_class%TYPE;
    l_v_acct_mthd                igs_fi_control_all.accounting_method%TYPE;
    l_var                        VARCHAR2(1);

    l_n_credit_id                igs_fi_credits.credit_id%TYPE := NULL;
    l_n_credit_activity_id       igs_fi_cr_activities.credit_activity_id%TYPE := NULL;
    l_v_rowid                    VARCHAR2(25) := NULL;

    l_adm_app_number             igs_ad_appl_all.admission_appl_number%TYPE;
    l_v_manage_accounts          igs_fi_control_all.manage_accounts%TYPE;

    l_v_credit_number            igs_fi_credits_all.credit_number%TYPE;
    l_v_cc_number                igs_fi_credits_all.credit_card_number%TYPE;

  BEGIN

    --Create a savepoint.
    SAVEPOINT create_credit_pvt;

    --Check if the user is having a compatible version.
    IF NOT fnd_api.compatible_api_call( p_current_version_number  =>  l_api_version,
                                        p_caller_version_number   =>  p_api_version,
                                        p_api_name                =>  l_api_name,
                                        p_pkg_name                =>  l_pkg_name) THEN
      --If not, then raise an error message.
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --If the calling program has passed the parameter for initializing the message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      --then call the Initialize program of the fnd_msg_pub package to initialize the message list.
      fnd_msg_pub.initialize;
    END IF;

    --Set the return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    -- Get the value of "Manage Accounts" System Option value.
    -- If this value is NULL then this process should error out.
    igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                  p_v_message_name => l_v_message_name );
    IF l_v_manage_accounts IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name ( 'IGS', l_v_message_name );
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_v_message_name := NULL;
    -- Check for Holds Balance Conversion Process and Existance of Balance Rule for Holds Balance
    -- are not required if Manage Accounts Option has value OTHER.
    IF l_v_manage_accounts <> 'OTHER' THEN
      --Check whether Holds Balance Conversion Process is running..
      igs_fi_gen_007.finp_get_conv_prc_run_ind( p_n_conv_process_run_ind => l_n_cnv_prc,
                                                p_v_message_name         => l_v_message_name
                                               );

      --If holds conversion process is running..error out of Private Credits API.
      IF l_n_cnv_prc = 1 AND l_v_message_name IS NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      IF l_v_message_name IS NOT NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS',l_v_message_name);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      --Get the latest active balance rule for 'HOLDS' balance type.
      igs_fi_gen_007.finp_get_balance_rule( p_v_balance_type         => l_hold,
                                            p_v_action               => l_v_action_active,
                                            p_n_balance_rule_id      => l_n_balance_rule_id,
                                            p_d_last_conversion_date => l_d_last_conversion_date,
                                            p_n_version_number       => l_n_version_number
                                           );

      --If no active balance rule exists for 'HOLDS', raise error.
      IF l_n_version_number = 0 THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS','IGS_FI_CANNOT_CRT_TXN');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    --Assign the parameter values of amount and currency code into local variables.
    -- Added call to format amount by rounding off to currency precision
    l_n_amount := igs_fi_gen_gl.get_formatted_amount(p_credit_rec.p_amount);
    l_v_currency_cd := p_credit_rec.p_currency_cd;

    --If this procedure is invoked with FULL validation level,
    IF p_validation_level = fnd_api.g_valid_level_full THEN
      --then, call the public procedure for all validations to happen.
      igs_fi_crdapi_util.validate_parameters( p_n_validation_level => fnd_api.g_valid_level_full,
                                              p_credit_rec         => p_credit_rec,
                                              p_attribute_rec      => p_attribute_record,
                                              p_b_return_status    => l_b_return_status);

      --if any error occurred during above validation, raise error.
      IF l_b_return_status = FALSE THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      l_v_message_name := NULL;

      --also, call the public procedure for currency code validation and translation into local currency(if required).
      igs_fi_crdapi_util.translate_local_currency( p_n_amount         => l_n_amount,
                                                   p_v_currency_cd    => l_v_currency_cd,
                                                   p_n_exchange_rate  => p_credit_rec.p_exchange_rate,
                                                   p_b_return_status  => l_b_return_status,
                                                   p_v_message_name   => l_v_message_name);
      --if any error occurred during above validation...
      IF l_b_return_status = FALSE THEN
        --raise the error and abort further processing.
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS',l_v_message_name);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;


    --Fetch the credit class.
    igs_fi_crdapi_util.validate_credit_type( p_n_credit_type_id  => p_credit_rec.p_credit_type_id,
                                             p_v_credit_class    => l_v_credit_class,
                                             p_b_return_stat     => l_b_return_status
                                            );

     -- Pmarada Added logic as per Tution Waivers enhancement
     IF (p_credit_rec.p_waiver_name IS NOT NULL) AND (l_v_credit_class = 'WAIVER') THEN
        OPEN cur_waiver_pgms (p_credit_rec.p_fee_cal_type, p_credit_rec.p_fee_ci_sequence_number, p_credit_rec.p_waiver_name );
        FETCH cur_waiver_pgms INTO l_waiver_pgms;
        IF cur_waiver_pgms%NOTFOUND THEN
          CLOSE cur_waiver_pgms;
          fnd_message.set_name('IGS', 'IGS_FI_WAV_PGM_NO_REC_FOUND');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE cur_waiver_pgms;
     END IF;

    --Assign the parameter values of trancation date and effective dates into local variables.
    l_d_transaction_date := p_credit_rec.p_transaction_date;
    l_d_effective_date   := p_credit_rec.p_effective_date;

    --If no value is provided for the transaction date parameter, set the System Date to this and use for further processing.
    IF p_credit_rec.p_transaction_date IS NULL THEN
      l_d_transaction_date := TRUNC(SYSDATE);
    END IF;

    --If no value is provided for the effective date parameter also, set effective date same as the transaction date.
    IF p_credit_rec.p_effective_date IS NULL THEN
      l_d_effective_date := l_d_transaction_date;
    END IF;

    --Invoke the Build Accounts Process for deriving the accounting information.
    igs_fi_prc_acct_pkg.build_accounts(
                                       p_fee_type               => NULL,
                                       p_fee_cal_type           => NULL,
                                       p_fee_ci_sequence_number => NULL,
                                       p_course_cd              => NULL,
                                       p_course_version_number  => NULL,
                                       p_org_unit_cd            => NULL,
                                       p_org_start_dt           => NULL,
                                       p_unit_cd                => NULL,
                                       p_unit_version_number    => NULL,
                                       p_uoo_id                 => NULL,
                                       p_location_cd            => NULL,
                                       p_transaction_type       => l_credit,
                                       p_credit_type_id         => p_credit_rec.p_credit_type_id,
                                       p_source_transaction_id  => NULL,
                                       x_dr_gl_ccid             => l_n_dr_gl_ccid,
                                       x_cr_gl_ccid             => l_n_cr_gl_ccid,
                                       x_dr_account_cd          => l_v_dr_account_cd,
                                       x_cr_account_cd          => l_v_cr_account_cd,
                                       x_err_type               => l_n_err_type,
                                       x_err_string             => l_v_err_string,
                                       x_ret_status             => l_b_return_status,
                                       p_v_attendance_type      => NULL,
                                       p_v_attendance_mode      => NULL,
                                       p_v_residency_status_cd  => NULL,
                                       p_n_unit_type_id         => NULL,
                                       p_v_unit_class           => NULL,
                                       p_v_unit_mode            => NULL,
                                       p_v_unit_level           => NULL,
                                       p_v_waiver_name          => NULL
                                       );

    --If any error occurred, raise the error.
    IF l_b_return_status = FALSE THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        --Bug 3627209, Added message on to the stack before adding it on to the fnd_message_pub
        fnd_message.set_name('IGS',l_v_err_string);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --If the user has provided a value for p_invoice_id parameter...
    IF (p_credit_rec.p_invoice_id IS NOT NULL) AND (l_v_credit_class = 'CHGADJ') THEN
      --Check if the accounting method setup in the System Options Form is ACCRUAL.
      --If accounting method is CASH, no changes are necessary for the accounting information derived earlier.
      l_v_acct_mthd := igs_fi_gen_005.finp_get_acct_meth;
      --If the accounting method is ACCRUAL...
      IF l_v_acct_mthd = 'ACCRUAL' THEN
         OPEN cur_override_dr(p_credit_rec.p_invoice_id);
         FETCH cur_override_dr INTO l_rec_cur_override_dr;
         IF cur_override_dr%FOUND THEN
            --Override the debit account with the revenue account checking if the receivables is installed or not.
            IF igs_fi_gen_005.finp_get_receivables_inst = 'Y' THEN
               l_n_dr_gl_ccid := l_rec_cur_override_dr.rev_gl_ccid;
               l_v_dr_account_cd := NULL;
            ELSE
               l_n_dr_gl_ccid := NULL;
               l_v_dr_account_cd := l_rec_cur_override_dr.rev_account_cd;
            END IF;
         END IF; --cur override IF
         CLOSE cur_override_dr;
      END IF; --acct mthd IF
    END IF;  --for p_invoice_id IF

    --Enh 4607540 , Calling iPayment API to get the encrypted value of Credit card number.
    --This Code logic is commented as the part of the Bug 4660773 Dont remove the commented Code
/*  IF p_credit_rec.p_credit_card_number IS NOT NULL THEN
      l_v_cc_number := IBY_CC_SECURITY_PUB.SECURE_CARD_NUMBER(p_commit => FND_API.G_FALSE, p_card_number => p_credit_rec.p_credit_card_number);
    ELSE
      l_v_cc_number := p_credit_rec.p_credit_card_number;
    END IF;

    */
    l_v_cc_number := p_credit_rec.p_credit_card_number; -- This piece of code has to be removed when the above commented code is uncommented.


    --Call the table handler for the credits table for creating a record in the credits table.
    --passed l_v_credit_number for x_credit_number (svuppala - Enh# 4213629)
    igs_fi_credits_pkg.insert_row(    x_rowid                        => l_v_rowid,
                                      x_credit_id                    => l_n_credit_id,
                                      x_credit_number                => l_v_credit_number,
                                      x_status                       => p_credit_rec.p_credit_status,
                                      x_credit_source                => p_credit_rec.p_credit_source,
                                      x_party_id                     => p_credit_rec.p_party_id,
                                      x_credit_type_id               => p_credit_rec.p_credit_type_id,
                                      x_credit_instrument            => p_credit_rec.p_credit_instrument,
                                      x_description                  => p_credit_rec.p_description,
                                      x_amount                       => l_n_amount,
                                      x_currency_cd                  => l_v_currency_cd,
                                      x_exchange_rate                => 1,
                                      x_transaction_date             => TRUNC(l_d_transaction_date),
                                      x_effective_date               => TRUNC(l_d_effective_date),
                                      x_reversal_date                => NULL,
                                      x_reversal_reason_code         => NULL,
                                      x_reversal_comments            => NULL,
                                      x_unapplied_amount             => l_n_amount,
                                      x_source_transaction_id        => p_credit_rec.p_source_transaction_id,
                                      x_merchant_id                  => NULL,
                                      x_receipt_lockbox_number       => p_credit_rec.p_receipt_lockbox_number,
                                      x_credit_card_code             => p_credit_rec.p_credit_card_code,
                                      x_credit_card_holder_name      => p_credit_rec.p_credit_card_holder_name,
                                      --Bug 4607540, Credit Card Enryption enhancement
                                      x_credit_card_number           => l_v_cc_number,
                                      x_credit_card_expiration_date  => TRUNC(p_credit_rec.p_credit_card_expiration_date),
                                      x_credit_card_approval_code    => p_credit_rec.p_credit_card_approval_code,
                                      x_awd_yr_cal_type              => p_credit_rec.p_awd_yr_cal_type,
                                      x_awd_yr_ci_sequence_number    => p_credit_rec.p_awd_yr_ci_sequence_number,
                                      x_fee_cal_type                 => p_credit_rec.p_fee_cal_type,
                                      x_fee_ci_sequence_number       => p_credit_rec.p_fee_ci_sequence_number,
                                      x_attribute_category           => p_attribute_record.p_attribute_category,
                                      x_attribute1                   => p_attribute_record.p_attribute1,
                                      x_attribute2                   => p_attribute_record.p_attribute2,
                                      x_attribute3                   => p_attribute_record.p_attribute3,
                                      x_attribute4                   => p_attribute_record.p_attribute4,
                                      x_attribute5                   => p_attribute_record.p_attribute5,
                                      x_attribute6                   => p_attribute_record.p_attribute6,
                                      x_attribute7                   => p_attribute_record.p_attribute7,
                                      x_attribute8                   => p_attribute_record.p_attribute8,
                                      x_attribute9                   => p_attribute_record.p_attribute9,
                                      x_attribute10                  => p_attribute_record.p_attribute10,
                                      x_attribute11                  => p_attribute_record.p_attribute11,
                                      x_attribute12                  => p_attribute_record.p_attribute12,
                                      x_attribute13                  => p_attribute_record.p_attribute13,
                                      x_attribute14                  => p_attribute_record.p_attribute14,
                                      x_attribute15                  => p_attribute_record.p_attribute15,
                                      x_attribute16                  => p_attribute_record.p_attribute16,
                                      x_attribute17                  => p_attribute_record.p_attribute17,
                                      x_attribute18                  => p_attribute_record.p_attribute18,
                                      x_attribute19                  => p_attribute_record.p_attribute19,
                                      x_attribute20                  => p_attribute_record.p_attribute20,
                                      x_gl_date                      => p_credit_rec.p_gl_date,
                                      x_check_number                 => p_credit_rec.p_check_number,
                                      x_source_transaction_type      => p_credit_rec.p_source_tran_type,
                                      x_source_transaction_ref       => p_credit_rec.p_source_tran_ref_number,
                                      x_credit_card_payee_cd         => p_credit_rec.p_v_credit_card_payee_cd,
                                      x_credit_card_status_code      => p_credit_rec.p_v_credit_card_status_code,
                                      x_credit_card_tangible_cd      => p_credit_rec.p_v_credit_card_tangible_cd,
                                      x_lockbox_interface_id         => p_credit_rec.p_lockbox_interface_id,
                                      x_batch_name                   => p_credit_rec.p_batch_name,
                                      x_deposit_date                 => p_credit_rec.p_deposit_date,
                                      x_source_invoice_id            => p_credit_rec.p_invoice_id,
                                      x_tax_year_code                => NULL,
                                      x_waiver_name                  => p_credit_rec.p_waiver_name
                                      );

    --Initilialize local variable of rowid to null values, as this value would be populated thru tbh call.
    l_v_rowid := NULL;

    --Call the table handler insert row procedure for creating the records in the credit activities table.
    igs_fi_cr_activities_pkg.insert_row(x_rowid                      => l_v_rowid,
                                        x_credit_activity_id         => l_n_credit_activity_id,
                                        x_credit_id                  => l_n_credit_id,
                                        x_status                     => p_credit_rec.p_credit_status,
                                        x_transaction_date           => TRUNC(l_d_transaction_date),
                                        x_amount                     => l_n_amount,
                                        x_dr_account_cd              => l_v_dr_account_cd,
                                        x_cr_account_cd              => l_v_cr_account_cd,
                                        x_dr_gl_ccid                 => l_n_dr_gl_ccid,
                                        x_cr_gl_ccid                 => l_n_cr_gl_ccid,
                                        x_bill_id                    => NULL,
                                        x_bill_number                => NULL,
                                        x_bill_date                  => NULL,
                                        x_posting_id                 => NULL,
                                        x_gl_date                    => p_credit_rec.p_gl_date,
                                        x_gl_posted_date             => NULL,
                                        x_posting_control_id         => NULL
                                        );

    --If the credit class is Installment Payments then, apply the transaction amount to the person's
    --installment payments such that the new installment balance is reflected.
    IF l_v_credit_class = 'INSTALLMENT_PAYMENTS' THEN
      igs_fi_crdapi_util.apply_installments(p_n_person_id      => p_credit_rec.p_party_id,
                                            p_n_amount         => l_n_amount,
                                            p_n_credit_id      => l_n_credit_id,
                                            p_n_cr_activity_id => l_n_credit_activity_id);
    END IF;

    --In case of a deposit transaction, with 'Enrollment Deposit' Credit Class, the successfully recorded
    --transaction information in Student Finance Subsystem has to be updated in the Admission Subsystem also.
    IF l_v_credit_class = 'ENRDEPOSIT' THEN
      --Fetch the appliation number for the source transaction reference number(application_id).
      OPEN cur_adm_app_num(TO_NUMBER(p_credit_rec.p_source_tran_ref_number),p_credit_rec.p_party_id);
      FETCH cur_adm_app_num INTO l_adm_app_number;
      CLOSE cur_adm_app_num;

      --passed l_v_credit_number for p_reference_number  (svuppala - Enh# 4213629)
      igs_ad_gen_015.create_enrollment_deposit( p_person_id                 => p_credit_rec.p_party_id,
                                                p_admission_appl_number     => l_adm_app_number,
                                                p_enrollment_deposit_amount => l_n_amount,
                                                p_payment_date              => TRUNC(SYSDATE),
                                                p_fee_payment_method        => p_credit_rec.p_credit_instrument,
                                                p_reference_number          => l_v_credit_number
                                               );
    END IF;

    -- After the records have been created in the credits and the credit activities table, then
    -- the update balances process should be called for picking up the balances records in the credits
    -- table for Holds and Standard Balance.

    --Firstly, Standard Balance updation.

    l_v_message_name :=NULL;

    --Updation of balances table SHOULD NOT happen for Deposit Transactions.
    -- And also if Manage Accounts is OTHER
    IF (l_v_credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT'))
       AND l_v_manage_accounts <> 'OTHER' THEN
      igs_fi_prc_balances.update_balances(  p_party_id             => p_credit_rec.p_party_id,
                                            p_balance_type         => l_standard,
                                            p_balance_date         => TRUNC(l_d_transaction_date),
                                            p_amount               => ((-1)*l_n_amount),
                                            p_source               => l_credit,
                                            p_source_id            => l_n_credit_id,
                                            p_message_name         => l_v_message_name
                                          );

      IF l_v_message_name IS NOT NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS', l_v_message_name);
          fnd_msg_pub.add;
          -- Do not raise error for information messages regd credit type or fee type being excluded.
          IF l_v_message_name NOT IN ('IGS_FI_CTYP_EXCLDED','IGS_FI_FTYP_EXCLDED') THEN
             RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF;

    --Secondly, Holds Balance updation.

    l_v_message_name   := NULL;

    --Updation of balances table SHOULD NOT happen for Deposit Transactions.
    -- And also if Manage Accounts is OTHER
    IF (l_v_credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT'))
       AND l_v_manage_accounts <> 'OTHER' THEN
      igs_fi_prc_balances.update_balances(  p_party_id             => p_credit_rec.p_party_id,
                                            p_balance_type         => l_hold,
                                            p_balance_date         => TRUNC(l_d_transaction_date),
                                            p_amount               => ((-1)*l_n_amount),
                                            p_source               => l_credit,
                                            p_source_id            => l_n_credit_id,
                                            p_message_name         => l_v_message_name
                                          );

      IF l_v_message_name IS NOT NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          fnd_message.set_name('IGS', l_v_message_name);
          fnd_msg_pub.add;
          -- Do not raise error for information messages regd credit type or fee type being excluded.
          IF l_v_message_name NOT IN ('IGS_FI_CTYP_EXCLDED','IGS_FI_FTYP_EXCLDED') THEN
             RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
    END IF;

    -- Call procedure to Validate the holds and release holds if applicable
    -- The holds table, IGS_FI_PERSON_HOLDS, will contain the credit id of the
    -- transaction as the release_credit_id
    l_v_message_name := NULL;
    IF (l_v_credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT')) AND l_v_manage_accounts <> 'OTHER' THEN
           igs_fi_prc_holds.finp_auto_release_holds( p_person_id          => p_credit_rec.p_party_id,
                                                     p_hold_plan_level    => 'S',
                                                     p_release_credit_id  => l_n_credit_id,
                                                     p_run_application    => 'N',
                                                     p_message_name       => l_v_message_name
                                                    );
           -- If p_message_name has been returned with a value, add message to stack
           IF l_v_message_name IS NOT NULL THEN
              fnd_message.set_name('IGS',l_v_message_name);
              fnd_msg_pub.add;
           END IF;
    END IF;

    --If the calling program has passed the parameter for committing the data and there
    --have been no errors in calling the balances process, then commit the work
    IF (fnd_api.to_boolean(p_commit)) THEN
      COMMIT WORK;
    END IF;

    --Assign the values to the out parameters
    x_credit_id          := l_n_credit_id;
    x_credit_activity_id := l_n_credit_activity_id;
    x_credit_number      := l_v_credit_number;

    fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                               p_data           => x_msg_data);

    EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_credit_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_credit_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_credit_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(l_pkg_name,
                                l_api_name);
      END IF;
      fnd_msg_pub.count_and_get( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

  END create_credit;
END igs_fi_credit_pvt;

/
