--------------------------------------------------------
--  DDL for Package Body IGS_FI_DEPOSITS_PRCSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_DEPOSITS_PRCSS" AS
/* $Header: IGSFI74B.pls 120.2 2005/07/08 04:37:51 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGS_FI_DEPOSITS_PRCSS                   |
 |                                                                       |
 | NOTES:                                                                |
 | Contains procedure for reversing a transaction, reverse_transaction(),|
 | forfeit_deposit for forfeiting, and transfer_Deposit for transfer     |
 |                                                                       |
 | HISTORY                                                               |
 | WHO            WHEN           WHAT                                    |
 | svuppala      9-JUN-2005      Enh 3442712 - Impact of automatic       |
 |                               generation of the Receipt Number.       |
 |                                Modified procedure transfer_deposit.    |
 | pmarada    26-May-2005        Enh#3020586- added tax year code column |
 |                               to as per 1098-t reporting build        |
 | pathipat       21-Apr-2004    Enh 3558549 - Comm Receivables Enh      |
 |                               Added param x_source_invoice_id in calls|
 |                               to igs_fi_credits_pkg.update_row()      |
 | schodava       06-Oct-2003    Bug # 3123405. Modified procedure       |
 |                               transfer_deposit.
 | vvutukur       22-Sep-2003    Enh#3045007.Payment Plans Build.Modified|
 |                               reverse_transaction.                    |
 | vvutukur       16-Jun-2003    Enh#2831582.Lockbox Build.Modified the  |
 |                               procedures forfeit_deposit,             |
 |                               reverse_transaction,transfer_deposit.   |
 | schodava       11-Jun-2003    Enh# 2831587. Credit Card Fund Transfer |
 |                               Modified forfeit_deposit,               |
 |                               reverse_transaction and transfer_deposit|
 |                               procedures                              |
 | vvutukur       09-Apr-2003    Enh#2831554.Internal Credits API Build. |
 |                               Modified procedure transfer_deposit.    |
 | pathipat       8-Dec-02       Enh # 2584741 Deposits build            |
 |                               Added forfeit_deposit and transfer_deposit
 | schodava       4-Dec-02       Enh # 2584741 Deposits Build            |
 |                               Added logic for reversal of Deposit     |
 |                               related transactions                    |
 *=======================================================================*/

g_cleared       CONSTANT igs_lookup_values.lookup_code%TYPE  := 'CLEARED';
g_forfeited     CONSTANT igs_lookup_values.lookup_code%TYPE  := 'FORFEITED';
g_transferred   CONSTANT igs_lookup_values.lookup_code%TYPE  := 'TRANSFERRED';
g_reversed      CONSTANT igs_lookup_values.lookup_code%TYPE  := 'REVERSED';
g_deposit       CONSTANT igs_lookup_values.lookup_code%TYPE  := 'DEPOSIT';


PROCEDURE forfeit_deposit( p_n_credit_id        IN         NUMBER,
                           p_d_gl_date          IN         DATE,
                           p_b_return_status    OUT NOCOPY BOOLEAN,
                           p_c_message_name     OUT NOCOPY VARCHAR2
                         ) AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 08-DEC-2002
  --
  --Purpose: For forfeiting a deposit
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat    21-Apr-2004     Enh 3558549 - Comm Receivables Enh
  --                            Added param x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  --vvutukur    16-Jun-2003     Enh#2831582.Lockbox Build.Modified update_row TBH call to credits table to add 3 new columns
  --                            lockbox_interface_id,batch_name,deposit_date.
  --schodava    11-Jun-03       Enh # 2831587. Modified the Credits table update_row call
  -------------------------------------------------------------------

  CURSOR cur_fi_credits (cp_credit_id NUMBER ) IS
    SELECT cre.rowid,cre.*
    FROM   igs_fi_credits cre
    WHERE  credit_id  = cp_credit_id
    AND    status = g_cleared;

  CURSOR cur_fi_cr_types (cp_credit_type_id NUMBER ) IS
    SELECT *
    FROM   igs_fi_cr_types
    WHERE  credit_type_id   = cp_credit_type_id;

  l_cur_fi_credits        cur_fi_credits%ROWTYPE;
  l_cur_fi_cr_types       cur_fi_cr_types%ROWTYPE;
  l_n_credit_activity_id  igs_fi_cr_activities.credit_activity_id%TYPE := NULL;
  l_rowid                 ROWID := NULL;
  l_n_cr_gl_ccid          igs_fi_cr_types.cr_gl_ccid%TYPE;
  l_n_dr_gl_ccid          igs_fi_cr_types.dr_gl_ccid%TYPE;
  l_v_cr_account_cd       igs_fi_cr_types.cr_account_cd%TYPE;
  l_v_dr_account_cd       igs_fi_cr_types.dr_account_cd%TYPE;

  BEGIN

    -- Check if mandatory parameters are specified
    IF (p_n_credit_id IS NULL) OR (p_d_gl_date IS NULL) THEN
       p_c_message_name := 'IGS_UC_NO_MANDATORY_PARAMS';
       p_b_return_status := FALSE;
       RETURN;
    END IF;

    -- Validate credit_id, if valid, then obtain the records
    OPEN cur_fi_credits(p_n_credit_id);
    FETCH cur_fi_credits INTO l_cur_fi_credits;
    IF cur_fi_credits%NOTFOUND THEN
       p_c_message_name := 'IGS_GE_INVALID_VALUE';
       p_b_return_status := FALSE;
       CLOSE cur_fi_credits;
       RETURN;
    END IF;
    CLOSE cur_fi_credits;

       -- Update the credits table - set status to Forfeited, the reversal data is null,
       -- unapplied amount is same as the amount.
       igs_fi_credits_pkg.update_row ( x_mode                              => 'R',
                                       x_rowid                             => l_cur_fi_credits.rowid,
                                       x_credit_id                         => l_cur_fi_credits.credit_id,
                                       x_credit_number                     => l_cur_fi_credits.credit_number ,
                                       x_status                            => g_forfeited ,
                                       x_credit_source                     => l_cur_fi_credits.credit_source,
                                       x_party_id                          => l_cur_fi_credits.party_id,
                                       x_credit_type_id                    => l_cur_fi_credits.credit_type_id,
                                       x_credit_instrument                 => l_cur_fi_credits.credit_instrument,
                                       x_description                       => l_cur_fi_credits.description,
                                       x_amount                            => l_cur_fi_credits.amount,
                                       x_currency_cd                       => l_cur_fi_credits.currency_cd,
                                       x_exchange_rate                     => l_cur_fi_credits.exchange_rate,
                                       x_transaction_date                  => l_cur_fi_credits.transaction_date,
                                       x_effective_date                    => l_cur_fi_credits.effective_date,
                                       x_reversal_date                     => NULL,
                                       x_reversal_reason_code              => NULL,
                                       x_reversal_comments                 => NULL,
                                       x_unapplied_amount                  => l_cur_fi_credits.unapplied_amount,
                                       x_source_transaction_id             => l_cur_fi_credits.source_transaction_id,
                                       x_receipt_lockbox_number            => l_cur_fi_credits.receipt_lockbox_number,
                                       x_merchant_id                       => l_cur_fi_credits.merchant_id,
                                       x_credit_card_code                  => l_cur_fi_credits.credit_card_code,
                                       x_credit_card_holder_name           => l_cur_fi_credits.credit_card_holder_name,
                                       x_credit_card_number                => l_cur_fi_credits.credit_card_number,
                                       x_credit_card_expiration_date       => l_cur_fi_credits.credit_card_expiration_date,
                                       x_credit_card_approval_code         => l_cur_fi_credits.credit_card_approval_code,
                                       x_awd_yr_cal_type                   => l_cur_fi_credits.awd_yr_cal_type,
                                       x_awd_yr_ci_sequence_number         => l_cur_fi_credits.awd_yr_ci_sequence_number,
                                       x_fee_cal_type                      => l_cur_fi_credits.fee_cal_type,
                                       x_fee_ci_sequence_number            => l_cur_fi_credits.fee_ci_sequence_number,
                                       x_attribute_category                => l_cur_fi_credits.attribute_category,
                                       x_attribute1                        => l_cur_fi_credits.attribute1,
                                       x_attribute2                        => l_cur_fi_credits.attribute2,
                                       x_attribute3                        => l_cur_fi_credits.attribute3,
                                       x_attribute4                        => l_cur_fi_credits.attribute4,
                                       x_attribute5                        => l_cur_fi_credits.attribute5,
                                       x_attribute6                        => l_cur_fi_credits.attribute6,
                                       x_attribute7                        => l_cur_fi_credits.attribute7,
                                       x_attribute8                        => l_cur_fi_credits.attribute8,
                                       x_attribute9                        => l_cur_fi_credits.attribute9,
                                       x_attribute10                       => l_cur_fi_credits.attribute10,
                                       x_attribute11                       => l_cur_fi_credits.attribute11,
                                       x_attribute12                       => l_cur_fi_credits.attribute12,
                                       x_attribute13                       => l_cur_fi_credits.attribute13,
                                       x_attribute14                       => l_cur_fi_credits.attribute14,
                                       x_attribute15                       => l_cur_fi_credits.attribute15,
                                       x_attribute16                       => l_cur_fi_credits.attribute16,
                                       x_attribute17                       => l_cur_fi_credits.attribute17,
                                       x_attribute18                       => l_cur_fi_credits.attribute18,
                                       x_attribute19                       => l_cur_fi_credits.attribute19,
                                       x_attribute20                       => l_cur_fi_credits.attribute20,
                                       x_gl_date                           => l_cur_fi_credits.gl_date,
                                       x_check_number                      => l_cur_fi_credits.check_number,
                                       x_source_transaction_type           => l_cur_fi_credits.source_transaction_type,
                                       x_source_transaction_ref            => l_cur_fi_credits.source_transaction_ref,
                                       x_credit_card_payee_cd              => l_cur_fi_credits.credit_card_payee_cd,
                                       x_credit_card_status_code           => l_cur_fi_credits.credit_card_status_code,
                                       x_credit_card_tangible_cd           => l_cur_fi_credits.credit_card_tangible_cd,
                                       x_lockbox_interface_id              => l_cur_fi_credits.lockbox_interface_id,
                                       x_batch_name                        => l_cur_fi_credits.batch_name,
                                       x_deposit_date                      => l_cur_fi_credits.deposit_date,
                                       x_source_invoice_id                 => l_cur_fi_credits.source_invoice_id,
                                       x_tax_year_code                     => l_cur_fi_credits.tax_year_code
                                     );


       -- Create a new activity record, with the debit account to be the credit account and
       -- the credit account to be the forfeiture account code/ccid.  The amount is the same
       -- as the amount for the base deposit record.  Status is set to 'Forfeited'.

       OPEN cur_fi_cr_types(l_cur_fi_credits.credit_type_id);
       FETCH cur_fi_cr_types INTO l_cur_fi_cr_types;
       CLOSE cur_fi_cr_types;

       IF igs_fi_gen_005.finp_get_receivables_inst ='Y' THEN
          l_n_cr_gl_ccid    := l_cur_fi_cr_types.forfeiture_gl_ccid;
          l_n_dr_gl_ccid    := l_cur_fi_cr_types.cr_gl_ccid;
          l_v_cr_account_cd := NULL;
          l_v_dr_account_cd := NULL;
       ELSE
          l_n_cr_gl_ccid    := NULL;
          l_n_dr_gl_ccid    := NULL;
          l_v_cr_account_cd := l_cur_fi_cr_types.forfeiture_account_cd;
          l_v_dr_account_cd := l_cur_fi_cr_types.cr_account_cd;
       END IF;

       igs_fi_cr_activities_pkg.insert_row ( x_mode                              => 'R',
                                             x_rowid                             => l_rowid,
                                             x_credit_activity_id                => l_n_credit_activity_id,
                                             x_credit_id                         => l_cur_fi_credits.credit_id,
                                             x_status                            => g_forfeited ,
                                             x_transaction_date                  => TRUNC(SYSDATE),
                                             x_amount                            => l_cur_fi_credits.amount,
                                             x_dr_account_cd                     => l_v_dr_account_cd,
                                             x_cr_account_cd                     => l_v_cr_account_cd,
                                             x_dr_gl_ccid                        => l_n_dr_gl_ccid,
                                             x_cr_gl_ccid                        => l_n_cr_gl_ccid,
                                             x_bill_id                           => NULL,
                                             x_bill_number                       => NULL,
                                             x_bill_date                         => NULL,
                                             x_gl_date                           => TRUNC(p_d_gl_date),
                                             x_gl_posted_date                    => NULL,
                                             x_posting_id                        => NULL
                                           );

       -- On successful forfeiture, return status as true and message conveying successful transaction
       p_c_message_name  := 'IGS_FI_DP_FORFEITED';
       p_b_return_status := TRUE;

 END forfeit_deposit;


PROCEDURE reverse_transaction( p_n_credit_id         IN  NUMBER,
                               p_c_reversal_reason   IN  VARCHAR2,
                               p_c_reversal_comments IN  VARCHAR2,
                               p_d_gl_date           IN  DATE,
                               p_b_return_status     OUT NOCOPY BOOLEAN,
                               p_c_message_name      OUT NOCOPY VARCHAR2
                             ) AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 26-OCT-2002
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --pathipat    21-Apr-2004     Enh 3558549 - Comm Receivables Enh
  --                            Added param x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  --vvutukur    22-Sep-2003     Enh#3045007.Payment Plans Build. Changes as specified in TD.
  --vvutukur    16-Jun-2003     Enh#2831582.Lockbox Build.Modified update_row TBH call to credits table to add 3 new columns
  --                            lockbox_interface_id,batch_name,deposit_date.
  --schodava    11-Jun-03       Enh # 2831587. Modified the Credits table update_row call
  --schodava    4-Dec-2002      Enh # 2584741 - Deposits Build
  -------------------------------------------------------------------

  CURSOR cur_lookup_code (cp_reversal_code IN igs_lookup_values.lookup_code%TYPE) IS
    SELECT 'X'
    FROM   igs_lookup_values
    WHERE  lookup_type = 'IGS_FI_REVERSAL_REASON'
    AND    lookup_code = cp_reversal_code
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE)) AND TRUNC(NVL(end_date_active, SYSDATE))
    AND    NVL(enabled_flag,'N') = 'Y';

  CURSOR cur_fi_credits (cp_credit_id IN igs_fi_credits.credit_id%TYPE) IS
    SELECT *
    FROM   igs_fi_credits
    WHERE  credit_id  = cp_credit_id;

  CURSOR c_deposit (cp_party_id IN igs_fi_credits.party_id%TYPE,
                    cp_receipt_number IN igs_fi_credits.credit_number%TYPE) IS
    SELECT *
    FROM   igs_fi_credits
    WHERE  party_id      = cp_party_id
    AND    credit_number = cp_receipt_number;

  CURSOR cur_fi_cr_types (cp_credit_type_id IN igs_fi_cr_types.credit_type_id%TYPE) IS
    SELECT *
    FROM   igs_fi_cr_types
    WHERE  credit_type_id   = cp_credit_type_id;

  --Cursor for identifying the Payment Plan installment application records.
  CURSOR cur_insts(cp_n_credit_id        igs_fi_credits.credit_id%TYPE,
                   cp_v_plan_status_cd   igs_fi_pp_std_attrs.plan_status_code%TYPE
                   ) IS
    SELECT app.rowid                      a_rowid,
           app.installment_application_id a_inst_app_id,
           app.application_type_code      a_appl_typ_cd,
           app.credit_id                  a_cr_id,
           app.credit_activity_id         a_cr_acty_id,
           app.applied_amt                a_app_amt,
           app.transaction_date           a_txn_dt,
           app.link_application_id        a_lnk_app_id,
           inst.rowid                     i_rowid,
           inst.installment_id            i_inst_id,
           inst.student_plan_id           i_std_pln_id,
           inst.installment_line_num      i_inst_ln_num,
           inst.due_day                   i_due_day,
           inst.due_month_code            i_due_mnth_cd,
           inst.due_year                  i_due_year,
           inst.due_date                  i_due_date,
           inst.installment_amt           i_inst_amt,
           inst.due_amt                   i_due_amt,
           inst.penalty_flag              i_pnlty_flg
    FROM   igs_fi_pp_ins_appls app,
           igs_fi_pp_instlmnts inst,
           igs_fi_pp_std_attrs std
    WHERE  std.plan_status_code = cp_v_plan_status_cd
    AND    std.student_plan_id  = inst.student_plan_id
    AND    inst.installment_id  = app.installment_id
    AND    app.credit_id = cp_n_credit_id;


  -- cursor rowtype variables
  l_cur_fi_credits        cur_fi_credits%ROWTYPE;
  rec_deposit             c_deposit%ROWTYPE;
  l_cur_fi_cr_types       cur_fi_cr_types%ROWTYPE;
  rec_dep_type            cur_fi_cr_types%ROWTYPE;

  l_v_dummy               VARCHAR2(1);
  l_n_conv_prc_val        igs_fi_control_all.conv_process_run_ind%TYPE;
  l_v_message_name        fnd_new_messages.message_name%TYPE;
  l_v_message_name1       fnd_new_messages.message_name%TYPE := NULL;
  l_v_credit_number       igs_fi_credits.credit_number%TYPE;
  l_n_credit_activity_id  igs_fi_cr_activities.credit_activity_id%TYPE := NULL;
  l_rowid                 ROWID := NULL;

  -- boolean variable for the update balances call
  l_b_upd_bal             BOOLEAN := FALSE;
  -- boolean variable for updating the deposit txn
  -- and inserting into the Credit Activities table.
  l_b_upd_dp_ins_cr       BOOLEAN := FALSE;

  l_dr_account_cd         igs_fi_cr_activities.dr_account_cd%TYPE;
  l_cr_account_cd         igs_fi_cr_activities.cr_account_cd%TYPE;
  l_dr_gl_ccid            igs_fi_cr_activities.dr_gl_ccid%TYPE;
  l_cr_gl_ccid            igs_fi_cr_activities.cr_gl_ccid%TYPE;
  l_c_status              igs_fi_credits.status%TYPE;
  l_n_unapp_amt           igs_fi_credits.unapplied_amount%TYPE;
  l_c_reversal_reason     igs_fi_credits.reversal_reason_code%TYPE;
  l_c_reversal_comments   igs_fi_credits.reversal_comments%TYPE;
  l_d_date                DATE;
  l_n_due_amt             igs_fi_pp_instlmnts.due_amt%TYPE;
  l_n_inst_appl_id        igs_fi_pp_ins_appls.installment_application_id%TYPE;

  BEGIN

    -- Check if mandatory parameters are specified
    IF (p_n_credit_id IS NULL) OR (p_d_gl_date IS NULL) THEN
       p_c_message_name := 'IGS_UC_NO_MANDATORY_PARAMS';
       p_b_return_status := FALSE;
       RETURN;
    END IF;

    -- If the Holds Balance Conversion Process is running then the generic function
    -- igs_fi_gen_007.finp_get_conv_prc_run_ind returns 1. Credit Reversal cannot be done
    -- when the Holds Balance Conversion Process is running. Hence error message is shown to the user

    igs_fi_gen_007.finp_get_conv_prc_run_ind(p_n_conv_process_run_ind => l_n_conv_prc_val,
                                             p_v_message_name         => l_v_message_name);

    --If there is no record in igs_fi_control table, error message should be displayed to the user.
    --User need to navigate to System Options Form and insert a record before performing this operation.
    IF l_v_message_name IS NOT NULL THEN
       p_c_message_name := l_v_message_name;
       p_b_return_status := FALSE;
       RETURN;
    END IF;

    IF l_n_conv_prc_val = 0 THEN

       -- Validate credit_id, if valid, then obtain the records
       OPEN cur_fi_credits(p_n_credit_id);
       FETCH cur_fi_credits INTO l_cur_fi_credits;
       IF cur_fi_credits%NOTFOUND THEN
          p_c_message_name := 'IGS_GE_INVALID_VALUE';
          p_b_return_status := FALSE;
          CLOSE cur_fi_credits;
          RETURN;
       END IF;
       CLOSE cur_fi_credits;

       -- Validate the reversal reason code to be a valid lookup
       IF p_c_reversal_reason IS NOT NULL THEN
         OPEN cur_lookup_code (p_c_reversal_reason);
         FETCH cur_lookup_code INTO l_v_dummy;
         IF cur_lookup_code%NOTFOUND THEN
            p_c_message_name := 'IGS_GE_INVALID_VALUE';
            p_b_return_status := FALSE;
            CLOSE cur_lookup_code;
            RETURN;
         END IF;
         CLOSE cur_lookup_code;
       END IF;

       -- Fetch the credit type record for the passed credit type id
       OPEN cur_fi_cr_types(l_cur_fi_credits.credit_type_id);
       FETCH cur_fi_cr_types INTO l_cur_fi_cr_types;
       CLOSE cur_fi_cr_types;

       -- Following Variable values are common for all except 1 (last) of the 4 conditions below
       l_c_status    := 'REVERSED';
       l_n_unapp_amt := 0;
       l_c_reversal_reason   := p_c_reversal_reason;
       l_c_reversal_comments := p_c_reversal_comments;
       l_d_date      := TRUNC(SYSDATE);

       -- Depending on the Credit Class, Status and Instrument the
       -- logic of the remaining part of this procedure is determined

       -- CASE 1 : Reversal of a Payment, created from the Receipts form/Self Service
       IF l_cur_fi_cr_types.credit_class IN ('PMT','ONLINE PAYMENT','INSTALLMENT_PAYMENTS')
         AND l_cur_fi_credits.credit_instrument <> 'DEPOSIT'
         AND l_cur_fi_credits.status = 'CLEARED' THEN
           l_dr_account_cd := l_cur_fi_cr_types.dr_account_cd;
           l_cr_account_cd := l_cur_fi_cr_types.cr_account_cd;
           l_dr_gl_ccid    := l_cur_fi_cr_types.dr_gl_ccid;
           l_cr_gl_ccid    := l_cur_fi_cr_types.cr_gl_ccid;
           l_b_upd_bal := TRUE;
       -- CASE 2 : Reversal of a Payment, created by a Transfer of a Deposit.
       ELSIF l_cur_fi_cr_types.credit_class = 'PMT'
         AND l_cur_fi_credits.credit_instrument = 'DEPOSIT'
         AND l_cur_fi_credits.status = 'CLEARED' THEN
           -- Fetch the corresponding deposit record for the passed credit id (payment) record
           OPEN c_deposit (cp_party_id       => l_cur_fi_credits.party_id,
                           cp_receipt_number => l_cur_fi_credits.source_transaction_ref);
           FETCH c_deposit INTO rec_deposit;
           CLOSE c_deposit;

           OPEN cur_fi_cr_types(rec_deposit.credit_type_id);
           FETCH cur_fi_cr_types INTO rec_dep_type;
           CLOSE cur_fi_cr_types;

           l_dr_account_cd := rec_dep_type.cr_account_cd;
           l_cr_account_cd := l_cur_fi_cr_types.cr_account_cd;
           l_dr_gl_ccid    := rec_dep_type.cr_gl_ccid;
           l_cr_gl_ccid    := l_cur_fi_cr_types.cr_gl_ccid;
           l_b_upd_bal := TRUE;
           l_b_upd_dp_ins_cr := TRUE;
       -- CASE 3 : Reversal of a deposit.
       ELSIF l_cur_fi_cr_types.credit_class IN ('ENRDEPOSIT','OTHDEPOSIT') THEN
         IF l_cur_fi_credits.status = 'CLEARED' THEN
           l_dr_account_cd := l_cur_fi_cr_types.dr_account_cd;
           l_cr_account_cd := l_cur_fi_cr_types.cr_account_cd;
           l_dr_gl_ccid    := l_cur_fi_cr_types.dr_gl_ccid;
           l_cr_gl_ccid    := l_cur_fi_cr_types.cr_gl_ccid;
           -- Note : both flags l_b_upd_bal and l_b_upd_dp_ins_cr are let to remain FALSE
         -- CASE 4 : Reversal of a Forfeited Deposit.
         ELSIF l_cur_fi_credits.status = 'FORFEITED' THEN
           l_dr_account_cd := l_cur_fi_cr_types.cr_account_cd;
           l_cr_account_cd := l_cur_fi_cr_types.forfeiture_account_cd;
           l_dr_gl_ccid    := l_cur_fi_cr_types.cr_gl_ccid;
           l_cr_gl_ccid    := l_cur_fi_cr_types.forfeiture_gl_ccid;
           -- Override the variables to 'CLEARED' and existing unapplied amount
           l_c_status      := 'CLEARED';
           l_n_unapp_amt   := l_cur_fi_credits.unapplied_amount;
           l_c_reversal_reason := NULL;
           l_c_reversal_comments := NULL;
           l_d_date        := NULL;
           -- Note : both flags l_b_upd_bal and l_b_upd_dp_ins_cr are let to remain FALSE
         END IF;
       END IF;

       -- If Oracle Financials is installed, then override the account code strings to NULL
       -- Else, override the flexfields to NULL
       IF igs_fi_gen_005.finp_get_receivables_inst = 'Y' THEN
         l_dr_account_cd := NULL;
         l_cr_account_cd := NULL;
       ELSE
         l_dr_gl_ccid    := NULL;
         l_cr_gl_ccid    := NULL;
       END IF;

       -- If all validations are passed (CASE 1,2,3 and 4)
       -- Update into igs_fi_credits, with appropriate status and unapplied_amount
       -- gl_date of the record is not updated

       igs_fi_credits_pkg.update_row( x_mode                              => 'R',
                                      x_rowid                             => l_cur_fi_credits.row_id,
                                      x_credit_id                         => l_cur_fi_credits.credit_id,
                                      x_credit_number                     => l_cur_fi_credits.credit_number,
                                      x_status                            => l_c_status, -- Set to 'REVERSED' for CASE 1,2,3. Set to 'CLEARED' for Case 4.
                                      x_credit_source                     => l_cur_fi_credits.credit_source,
                                      x_party_id                          => l_cur_fi_credits.party_id,
                                      x_credit_type_id                    => l_cur_fi_credits.credit_type_id,
                                      x_credit_instrument                 => l_cur_fi_credits.credit_instrument,
                                      x_description                       => l_cur_fi_credits.description,
                                      x_amount                            => l_cur_fi_credits.amount,
                                      x_currency_cd                       => l_cur_fi_credits.currency_cd,
                                      x_exchange_rate                     => l_cur_fi_credits.exchange_rate,
                                      x_transaction_date                  => l_cur_fi_credits.transaction_date,
                                      x_effective_date                    => l_cur_fi_credits.effective_date,
                                      x_reversal_date                     => l_d_date,
                                      x_reversal_reason_code              => l_c_reversal_reason,
                                      x_reversal_comments                 => l_c_reversal_comments,
                                      x_unapplied_amount                  => l_n_unapp_amt,   -- Set to '0' for CASE 1,2,3. Set to the existing value for Case 4.
                                      x_source_transaction_id             => l_cur_fi_credits.source_transaction_id,
                                      x_receipt_lockbox_number            => l_cur_fi_credits.receipt_lockbox_number,
                                      x_merchant_id                       => l_cur_fi_credits.merchant_id,
                                      x_credit_card_code                  => l_cur_fi_credits.credit_card_code,
                                      x_credit_card_holder_name           => l_cur_fi_credits.credit_card_holder_name,
                                      x_credit_card_number                => l_cur_fi_credits.credit_card_number,
                                      x_credit_card_expiration_date       => l_cur_fi_credits.credit_card_expiration_date,
                                      x_credit_card_approval_code         => l_cur_fi_credits.credit_card_approval_code,
                                      x_awd_yr_cal_type                   => l_cur_fi_credits.awd_yr_cal_type,
                                      x_awd_yr_ci_sequence_number         => l_cur_fi_credits.awd_yr_ci_sequence_number,
                                      x_fee_cal_type                      => l_cur_fi_credits.fee_cal_type,
                                      x_fee_ci_sequence_number            => l_cur_fi_credits.fee_ci_sequence_number,
                                      x_attribute_category                => l_cur_fi_credits.attribute_category,
                                      x_attribute1                        => l_cur_fi_credits.attribute1,
                                      x_attribute2                        => l_cur_fi_credits.attribute2,
                                      x_attribute3                        => l_cur_fi_credits.attribute3,
                                      x_attribute4                        => l_cur_fi_credits.attribute4,
                                      x_attribute5                        => l_cur_fi_credits.attribute5,
                                      x_attribute6                        => l_cur_fi_credits.attribute6,
                                      x_attribute7                        => l_cur_fi_credits.attribute7,
                                      x_attribute8                        => l_cur_fi_credits.attribute8,
                                      x_attribute9                        => l_cur_fi_credits.attribute9,
                                      x_attribute10                       => l_cur_fi_credits.attribute10,
                                      x_attribute11                       => l_cur_fi_credits.attribute11,
                                      x_attribute12                       => l_cur_fi_credits.attribute12,
                                      x_attribute13                       => l_cur_fi_credits.attribute13,
                                      x_attribute14                       => l_cur_fi_credits.attribute14,
                                      x_attribute15                       => l_cur_fi_credits.attribute15,
                                      x_attribute16                       => l_cur_fi_credits.attribute16,
                                      x_attribute17                       => l_cur_fi_credits.attribute17,
                                      x_attribute18                       => l_cur_fi_credits.attribute18,
                                      x_attribute19                       => l_cur_fi_credits.attribute19,
                                      x_attribute20                       => l_cur_fi_credits.attribute20,
                                      x_gl_date                           => l_cur_fi_credits.gl_date,
                                      x_check_number                      => l_cur_fi_credits.check_number,
                                      x_source_transaction_type           => l_cur_fi_credits.source_transaction_type,
                                      x_source_transaction_ref            => l_cur_fi_credits.source_transaction_ref,
                                      x_credit_card_payee_cd              => l_cur_fi_credits.credit_card_payee_cd,
                                      x_credit_card_status_code           => l_cur_fi_credits.credit_card_status_code,
                                      x_credit_card_tangible_cd           => l_cur_fi_credits.credit_card_tangible_cd,
                                      x_lockbox_interface_id              => l_cur_fi_credits.lockbox_interface_id,
                                      x_batch_name                        => l_cur_fi_credits.batch_name,
                                      x_deposit_date                      => l_cur_fi_credits.deposit_date,
                                      x_source_invoice_id                 => l_cur_fi_credits.source_invoice_id,
                                      x_tax_year_code                     => l_cur_fi_credits.tax_year_code
                                     );

       -- Insert into the activities table with gl_date as the gl_date used in the reversal
       -- and with appropriate status. Transaction date would be the system date.
       -- Amount field is negated.

       igs_fi_cr_activities_pkg.insert_row ( x_mode                              => 'R',
                                             x_rowid                             => l_rowid,
                                             x_credit_activity_id                => l_n_credit_activity_id,
                                             x_credit_id                         => l_cur_fi_credits.credit_id,
                                             x_status                            => l_c_status, -- Set to 'REVERSED' for CASE 1,2,3. Set to 'CLEARED' for Case 4.
                                             x_transaction_date                  => TRUNC(SYSDATE),
                                             x_amount                            => ((-1) * l_cur_fi_credits.amount),
                                             x_dr_account_cd                     => l_dr_account_cd,
                                             x_cr_account_cd                     => l_cr_account_cd,
                                             x_dr_gl_ccid                        => l_dr_gl_ccid,
                                             x_cr_gl_ccid                        => l_cr_gl_ccid,
                                             x_bill_id                           => NULL,
                                             x_bill_number                       => NULL,
                                             x_bill_date                         => NULL,
                                             x_gl_date                           => TRUNC(p_d_gl_date),
                                             x_gl_posted_date                    => NULL,
                                             x_posting_id                        => NULL
                                           );
      -- Call to update the holds and standard balance (CASE 1 and 2)
      -- only if the l_b_upd_bal flag is TRUE
      IF l_b_upd_bal THEN
      -- Update the holds and standard balance accordingly with the reversed amount
      -- Balance date is updated to sysdate

                -- Update balances of balance type 'STANDARD'
                igs_fi_prc_balances.update_balances ( p_party_id       => l_cur_fi_credits.party_id,
                                                      p_balance_type   => 'STANDARD',
                                                      p_balance_date   => TRUNC(SYSDATE),
                                                      p_amount         => ABS(NVL(l_cur_fi_credits.amount,0)),  --Amount always passed as +ve
                                                      p_source         => 'CREDIT',
                                                      p_source_id      => p_n_credit_id,
                                                      p_message_name   => l_v_message_name1
                                                    ) ;
                IF l_v_message_name1 IS NOT NULL THEN
                   p_c_message_name := l_v_message_name1;
                   p_b_return_status := FALSE;
                   RETURN;
                END IF;

                -- Update balances of balance type 'HOLDS'
                igs_fi_prc_balances.update_balances ( p_party_id       => l_cur_fi_credits.party_id,
                                                      p_balance_type   => 'HOLDS',
                                                      p_balance_date   => TRUNC(SYSDATE),
                                                      p_amount         => ABS(NVL(l_cur_fi_credits.amount,0)),  --Amount always passed as +ve
                                                      p_source         => 'CREDIT',
                                                      p_source_id      => p_n_credit_id,
                                                      p_message_name   => l_v_message_name1
                                                    ) ;

                IF l_v_message_name1 IS NOT NULL THEN
                   p_c_message_name := l_v_message_name1;
                   p_b_return_status := FALSE;
                   RETURN;
                END IF;
      END IF;  -- For l_b_upd_bal

      -- For a reversal of a credit, which is created due to the transfer of a deposit, (CASE 2 only)
      -- the corresponding deposit record of the credit in context should be updated.
      IF l_b_upd_dp_ins_cr THEN

        igs_fi_credits_pkg.update_row (
               x_mode                              => 'R',
               x_rowid                             => rec_deposit.row_id,
               x_credit_id                         => rec_deposit.credit_id,
               x_credit_number                     => rec_deposit.credit_number ,
               x_status                            => 'CLEARED',
               x_credit_source                     => rec_deposit.credit_source,
               x_party_id                          => rec_deposit.party_id,
               x_credit_type_id                    => rec_deposit.credit_type_id,
               x_credit_instrument                 => rec_deposit.credit_instrument,
               x_description                       => rec_deposit.description,
               x_amount                            => rec_deposit.amount,
               x_currency_cd                       => rec_deposit.currency_cd,
               x_exchange_rate                     => rec_deposit.exchange_rate,
               x_transaction_date                  => rec_deposit.transaction_date,
               x_effective_date                    => rec_deposit.effective_date,
               x_reversal_date                     => rec_deposit.reversal_date,
               x_reversal_reason_code              => rec_deposit.reversal_reason_code,
               x_reversal_comments                 => rec_deposit.reversal_comments,
               x_unapplied_amount                  => rec_deposit.unapplied_amount,
               x_source_transaction_id             => rec_deposit.source_transaction_id,
               x_receipt_lockbox_number            => rec_deposit.receipt_lockbox_number,
               x_merchant_id                       => rec_deposit.merchant_id,
               x_credit_card_code                  => rec_deposit.credit_card_code,
               x_credit_card_holder_name           => rec_deposit.credit_card_holder_name,
               x_credit_card_number                => rec_deposit.credit_card_number,
               x_credit_card_expiration_date       => rec_deposit.credit_card_expiration_date,
               x_credit_card_approval_code         => rec_deposit.credit_card_approval_code,
               x_awd_yr_cal_type                   => rec_deposit.awd_yr_cal_type,
               x_awd_yr_ci_sequence_number         => rec_deposit.awd_yr_ci_sequence_number,
               x_fee_cal_type                      => rec_deposit.fee_cal_type,
               x_fee_ci_sequence_number            => rec_deposit.fee_ci_sequence_number,
               x_attribute_category                => rec_deposit.attribute_category,
               x_attribute1                        => rec_deposit.attribute1,
               x_attribute2                        => rec_deposit.attribute2,
               x_attribute3                        => rec_deposit.attribute3,
               x_attribute4                        => rec_deposit.attribute4,
               x_attribute5                        => rec_deposit.attribute5,
               x_attribute6                        => rec_deposit.attribute6,
               x_attribute7                        => rec_deposit.attribute7,
               x_attribute8                        => rec_deposit.attribute8,
               x_attribute9                        => rec_deposit.attribute9,
               x_attribute10                       => rec_deposit.attribute10,
               x_attribute11                       => rec_deposit.attribute11,
               x_attribute12                       => rec_deposit.attribute12,
               x_attribute13                       => rec_deposit.attribute13,
               x_attribute14                       => rec_deposit.attribute14,
               x_attribute15                       => rec_deposit.attribute15,
               x_attribute16                       => rec_deposit.attribute16,
               x_attribute17                       => rec_deposit.attribute17,
               x_attribute18                       => rec_deposit.attribute18,
               x_attribute19                       => rec_deposit.attribute19,
               x_attribute20                       => rec_deposit.attribute20,
               x_gl_date                           => rec_deposit.gl_date,
               x_check_number                      => rec_deposit.check_number,
               x_source_transaction_type           => rec_deposit.source_transaction_type,
               x_source_transaction_ref            => rec_deposit.source_transaction_ref,
               x_credit_card_payee_cd              => rec_deposit.credit_card_payee_cd,
               x_credit_card_status_code           => rec_deposit.credit_card_status_code,
               x_credit_card_tangible_cd           => rec_deposit.credit_card_tangible_cd,
               x_lockbox_interface_id              => rec_deposit.lockbox_interface_id,
               x_batch_name                        => rec_deposit.batch_name,
               x_deposit_date                      => rec_deposit.deposit_date,
               x_source_invoice_id                 => rec_deposit.source_invoice_id,
               x_tax_year_code                     => rec_deposit.tax_year_code
             );

       l_rowid := NULL;
       l_n_credit_activity_id := NULL;
       igs_fi_cr_activities_pkg.insert_row ( x_mode                              => 'R',
                                             x_rowid                             => l_rowid,
                                             x_credit_activity_id                => l_n_credit_activity_id,
                                             x_credit_id                         => rec_deposit.credit_id,
                                             x_status                            => 'CLEARED',
                                             x_transaction_date                  => TRUNC(SYSDATE),
                                             x_amount                            => rec_deposit.amount,
                                             x_dr_account_cd                     => NULL,
                                             x_cr_account_cd                     => NULL,
                                             x_dr_gl_ccid                        => NULL,
                                             x_cr_gl_ccid                        => NULL,
                                             x_bill_id                           => NULL,
                                             x_bill_number                       => NULL,
                                             x_bill_date                         => NULL,
                                             x_gl_date                           => NULL,
                                             x_gl_posted_date                    => NULL,
                                             x_posting_id                        => NULL
                                           );
      END IF;


      --If the credit class is Installment Payments then...
      IF l_cur_fi_cr_types.credit_class = 'INSTALLMENT_PAYMENTS' THEN
        --Fetch the details of payment plan installments and corresponding application records and loop through them.
        --if no records are found, nothing needs to be done.
        FOR rec_cur_insts IN cur_insts(p_n_credit_id,'ACTIVE') LOOP
          --Calculate the due amount of each installment to be updated.
          --Due amount to be updated is the sum of the current due amount and already applied amount for that
          --installment.
          l_n_due_amt := rec_cur_insts.i_due_amt + rec_cur_insts.a_app_amt;

          --Update the due amt of payment plan installment with the value calculated as above. Because
          --of the unapplication of the installment, the installment balance for the person should be increased.
          igs_fi_pp_instlmnts_pkg.update_row(
                                              x_rowid                   => rec_cur_insts.i_rowid,
                                              x_installment_id          => rec_cur_insts.i_inst_id,
                                              x_student_plan_id         => rec_cur_insts.i_std_pln_id,
                                              x_installment_line_num    => rec_cur_insts.i_inst_ln_num,
                                              x_due_day                 => rec_cur_insts.i_due_day,
                                              x_due_month_code          => rec_cur_insts.i_due_mnth_cd,
                                              x_due_year                => rec_cur_insts.i_due_year,
                                              x_due_date                => rec_cur_insts.i_due_date,
                                              x_installment_amt         => rec_cur_insts.i_inst_amt,
                                              x_due_amt                 => l_n_due_amt,
                                              x_penalty_flag            => rec_cur_insts.i_pnlty_flg,
                                              x_mode                    => 'R'
                                             );

          --Create an Payment Plan unapplication record with the amount being negative value of the
          --amount previously applied and with application type code being 'UNAPP' and link application
          --id being the application id of the respective application record.
          l_rowid := NULL;
          l_n_inst_appl_id := NULL;

          igs_fi_pp_ins_appls_pkg.insert_row(
                                              x_rowid                        => l_rowid,
                                              x_installment_application_id   => l_n_inst_appl_id,
                                              x_application_type_code        => 'UNAPP',
                                              x_installment_id               => rec_cur_insts.i_inst_id,
                                              x_credit_id                    => p_n_credit_id,
                                              x_credit_activity_id           => l_n_credit_activity_id,
                                              x_applied_amt                  => -1 * rec_cur_insts.a_app_amt,
                                              x_transaction_date             => TRUNC(SYSDATE),
                                              x_link_application_id          => rec_cur_insts.a_inst_app_id,
                                              x_mode                         => 'R'
                                              );
        END LOOP;
      END IF;
    -- If the Holds Balance Conversion Process is running then the generic function
    -- igs_fi_gen_007.finp_get_conv_prc_run_ind returns 1. Credit Reversal cannot be done
    -- when the Holds Balance Conversion Process is running.Hence error message is shown
    -- user.
    ELSE   -- l_con_prc_val = 1
      p_c_message_name := 'IGS_FI_REASS_BAL_PRC_RUN';
      p_b_return_status := FALSE;
      RETURN;
    END IF;  -- end if for 'l_con_prc_val = 0'

    p_b_return_status := TRUE;
    p_c_message_name  := NULL;

END reverse_transaction;


PROCEDURE transfer_deposit( p_n_credit_id      IN NUMBER,
                            p_d_gl_date        IN DATE,
                            p_b_return_status  OUT NOCOPY BOOLEAN,
                            p_c_message_name   OUT NOCOPY VARCHAR2,
                            p_c_receipt_number OUT NOCOPY VARCHAR2
                          ) AS
  ------------------------------------------------------------------
  --Created by  : Priya Athipatla, Oracle IDC
  --Date created: 08-DEC-2002
  --
  --Purpose: To transfer a deposit - Deposit transferred and a credit
  --         created for the deposit amount
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --svuppala    9-JUN-2005      Enh 3442712 - Impact of automatic generation of the Receipt Number
  --                            Modified logic for credit_number.
  --pathipat    21-Apr-2004     Enh 3558549 - Comm Receivables Enh
  --                            Added param x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  --schodava    06-Oct-2003     Bug # 3123405. The call to update balances is modified.
  --vvutukur    16-Jun-2003     Enh#2831582.Lockbox Build.Modified update_row TBH call to credits table to add 3 new columns
  --                            lockbox_interface_id,batch_name,deposit_date.
  --schodava    11-Jun-03       Enh # 2831587. Modified the Credits table insert_row, update_row calls
  --vvutukur   09-Apr-2003   Enh#2831554.Internal Credits API Build. Removed cursor cur_pay_credit_type and its usage,instead called a generic
  --                         procedure igs_fi_crdapi_util.validate_dep_crtype,which serves the same purpose of validating the payment credit type.
  -------------------------------------------------------------------
  CURSOR cur_fi_credits (cp_credit_id NUMBER ) IS
    SELECT cre.rowid,cre.*
    FROM   igs_fi_credits cre
    WHERE  credit_id  = cp_credit_id
    AND    status = g_cleared;


  -- Cursor to obtain the debit account info for the new credit created
  CURSOR cur_account_info (cp_credit_type_id IN NUMBER) IS
    SELECT cr_account_cd, cr_gl_ccid
    FROM igs_fi_cr_types
    WHERE credit_type_id = cp_credit_type_id;

  l_cur_fi_credits            cur_fi_credits%ROWTYPE;
  l_cur_dr_account_info       cur_account_info%ROWTYPE;
  l_cur_cr_account_info       cur_account_info%ROWTYPE;
  l_rowid                     VARCHAR2(25) := NULL;
  l_n_credit_activity_id      igs_fi_cr_activities.credit_activity_id%TYPE := NULL;
  l_n_credit_id               igs_fi_credits_all.credit_id%TYPE;
  l_v_credit_number           igs_fi_credits_all.credit_number%TYPE;
  l_n_dr_gl_ccid              igs_fi_cr_types.dr_gl_ccid%TYPE;
  l_n_cr_gl_ccid              igs_fi_cr_types.cr_gl_ccid%TYPE;
  l_v_dr_account_cd           igs_fi_cr_types.dr_account_cd%TYPE;
  l_v_cr_account_cd           igs_fi_cr_types.cr_account_cd%TYPE;
  l_v_message_name            fnd_new_messages.message_name%TYPE := NULL;
  l_n_conv_prc_run_ind        igs_fi_control_all.conv_process_run_ind%TYPE;

  l_n_pay_credit_type_id      igs_fi_cr_types_all.credit_type_id%TYPE;
  l_b_return_status           BOOLEAN;

  BEGIN

    -- If the Holds Conversion process is running, Transfer cannot be performed as it updates
    -- balances after successful transfer. So error out in Holds Conversion is running
    igs_fi_gen_007.finp_get_conv_prc_run_ind( p_n_conv_process_run_ind  => l_n_conv_prc_run_ind,
                                              p_v_message_name          => l_v_message_name
                                             );
    IF l_n_conv_prc_run_ind = 1 THEN
       p_c_message_name := 'IGS_FI_REASS_BAL_PRC_RUN';
       p_b_return_status := FALSE;
       p_c_receipt_number := NULL;
       RETURN;
    ELSIF l_v_message_name IS NOT NULL THEN
       p_c_message_name := l_v_message_name;
       p_b_return_status := FALSE;
       p_c_receipt_number := NULL;
       RETURN;
    END IF;

    -- Check if mandatory parameters are specified
    IF (p_n_credit_id IS NULL) OR (p_d_gl_date IS NULL) THEN
       p_c_message_name := 'IGS_UC_NO_MANDATORY_PARAMS';
       p_b_return_status := FALSE;
       p_c_receipt_number := NULL;
       RETURN;
    END IF;

    -- Validate credit_id, if valid, then obtain the records
    OPEN cur_fi_credits(p_n_credit_id);
    FETCH cur_fi_credits INTO l_cur_fi_credits;
    IF cur_fi_credits%NOTFOUND THEN
       p_c_message_name := 'IGS_GE_INVALID_VALUE';
       p_b_return_status := FALSE;
       p_c_receipt_number := NULL;
       CLOSE cur_fi_credits;
       RETURN;
    END IF;
    CLOSE cur_fi_credits;

    --Validate the payment credit type.
    igs_fi_crdapi_util.validate_dep_crtype( p_n_credit_type_id      => l_cur_fi_credits.credit_type_id,
                                            p_n_pay_credit_type_id  => l_n_pay_credit_type_id,
                                            p_b_return_stat         => l_b_return_status
                                           );

    --If not valid, then error out.
    IF l_b_return_status = FALSE THEN
       p_c_message_name := 'IGS_FI_PCT_DCT_INVALID';
       p_b_return_status := FALSE;
       p_c_receipt_number := NULL;
       RETURN;
    END IF;

       -- Update the record in the credits table with a status of 'TRANSFERRED'
       igs_fi_credits_pkg.update_row ( x_mode                              => 'R',
                                       x_rowid                             => l_cur_fi_credits.rowid,
                                       x_credit_id                         => l_cur_fi_credits.credit_id,
                                       x_credit_number                     => l_cur_fi_credits.credit_number ,
                                       x_status                            => g_transferred,
                                       x_credit_source                     => l_cur_fi_credits.credit_source,
                                       x_party_id                          => l_cur_fi_credits.party_id,
                                       x_credit_type_id                    => l_cur_fi_credits.credit_type_id,
                                       x_credit_instrument                 => l_cur_fi_credits.credit_instrument,
                                       x_description                       => l_cur_fi_credits.description,
                                       x_amount                            => l_cur_fi_credits.amount,
                                       x_currency_cd                       => l_cur_fi_credits.currency_cd,
                                       x_exchange_rate                     => l_cur_fi_credits.exchange_rate,
                                       x_transaction_date                  => l_cur_fi_credits.transaction_date,
                                       x_effective_date                    => l_cur_fi_credits.effective_date,
                                       x_reversal_date                     => l_cur_fi_credits.reversal_date,
                                       x_reversal_reason_code              => l_cur_fi_credits.reversal_reason_code,
                                       x_reversal_comments                 => l_cur_fi_credits.reversal_comments,
                                       x_unapplied_amount                  => l_cur_fi_credits.unapplied_amount,
                                       x_source_transaction_id             => l_cur_fi_credits.source_transaction_id,
                                       x_receipt_lockbox_number            => l_cur_fi_credits.receipt_lockbox_number,
                                       x_merchant_id                       => l_cur_fi_credits.merchant_id,
                                       x_credit_card_code                  => l_cur_fi_credits.credit_card_code,
                                       x_credit_card_holder_name           => l_cur_fi_credits.credit_card_holder_name,
                                       x_credit_card_number                => l_cur_fi_credits.credit_card_number,
                                       x_credit_card_expiration_date       => l_cur_fi_credits.credit_card_expiration_date,
                                       x_credit_card_approval_code         => l_cur_fi_credits.credit_card_approval_code,
                                       x_awd_yr_cal_type                   => l_cur_fi_credits.awd_yr_cal_type,
                                       x_awd_yr_ci_sequence_number         => l_cur_fi_credits.awd_yr_ci_sequence_number,
                                       x_fee_cal_type                      => l_cur_fi_credits.fee_cal_type,
                                       x_fee_ci_sequence_number            => l_cur_fi_credits.fee_ci_sequence_number,
                                       x_attribute_category                => l_cur_fi_credits.attribute_category,
                                       x_attribute1                        => l_cur_fi_credits.attribute1,
                                       x_attribute2                        => l_cur_fi_credits.attribute2,
                                       x_attribute3                        => l_cur_fi_credits.attribute3,
                                       x_attribute4                        => l_cur_fi_credits.attribute4,
                                       x_attribute5                        => l_cur_fi_credits.attribute5,
                                       x_attribute6                        => l_cur_fi_credits.attribute6,
                                       x_attribute7                        => l_cur_fi_credits.attribute7,
                                       x_attribute8                        => l_cur_fi_credits.attribute8,
                                       x_attribute9                        => l_cur_fi_credits.attribute9,
                                       x_attribute10                       => l_cur_fi_credits.attribute10,
                                       x_attribute11                       => l_cur_fi_credits.attribute11,
                                       x_attribute12                       => l_cur_fi_credits.attribute12,
                                       x_attribute13                       => l_cur_fi_credits.attribute13,
                                       x_attribute14                       => l_cur_fi_credits.attribute14,
                                       x_attribute15                       => l_cur_fi_credits.attribute15,
                                       x_attribute16                       => l_cur_fi_credits.attribute16,
                                       x_attribute17                       => l_cur_fi_credits.attribute17,
                                       x_attribute18                       => l_cur_fi_credits.attribute18,
                                       x_attribute19                       => l_cur_fi_credits.attribute19,
                                       x_attribute20                       => l_cur_fi_credits.attribute20,
                                       x_gl_date                           => l_cur_fi_credits.gl_date,
                                       x_check_number                      => l_cur_fi_credits.check_number,
                                       x_source_transaction_type           => l_cur_fi_credits.source_transaction_type,
                                       x_source_transaction_ref            => l_cur_fi_credits.source_transaction_ref,
                                       x_credit_card_payee_cd              => l_cur_fi_credits.credit_card_payee_cd,
                                       x_credit_card_status_code           => l_cur_fi_credits.credit_card_status_code,
                                       x_credit_card_tangible_cd           => l_cur_fi_credits.credit_card_tangible_cd,
                                       x_lockbox_interface_id              => l_cur_fi_credits.lockbox_interface_id,
                                       x_batch_name                        => l_cur_fi_credits.batch_name,
                                       x_deposit_date                      => l_cur_fi_credits.deposit_date,
                                       x_source_invoice_id                 => l_cur_fi_credits.source_invoice_id,
                                       x_tax_year_code                     => l_cur_fi_credits.tax_year_code
                                     );

       -- Create a new activities record with status 'Transferred' and with
       -- NULL accounting information

       igs_fi_cr_activities_pkg.insert_row ( x_mode                              => 'R',
                                             x_rowid                             => l_rowid,
                                             x_credit_activity_id                => l_n_credit_activity_id,
                                             x_credit_id                         => l_cur_fi_credits.credit_id,
                                             x_status                            => g_transferred,
                                             x_transaction_date                  => TRUNC(SYSDATE),
                                             x_amount                            => l_cur_fi_credits.amount,
                                             x_dr_account_cd                     => NULL,
                                             x_cr_account_cd                     => NULL,
                                             x_dr_gl_ccid                        => NULL,
                                             x_cr_gl_ccid                        => NULL,
                                             x_bill_id                           => NULL,
                                             x_bill_number                       => NULL,
                                             x_bill_date                         => NULL,
                                             x_gl_date                           => NULL,
                                             x_gl_posted_date                    => NULL,
                                             x_posting_id                        => NULL
                                           );


    -- Create a payment record in igs_fi_Credits and an activity correspondingly in igs_fi_cr_activities
    -- Account details obtained
    l_rowid := NULL;
    l_n_credit_id := NULL;
    l_v_credit_number := NULL;

       igs_fi_credits_pkg.insert_row ( x_mode                              => 'R',
                                       x_rowid                             => l_rowid,
                                       x_credit_id                         => l_n_credit_id,
                                       x_credit_number                     => l_v_credit_number ,
                                       x_status                            => g_cleared,
                                       x_credit_source                     => NULL,
                                       x_party_id                          => l_cur_fi_credits.party_id,
                                       x_credit_type_id                    => l_n_pay_credit_type_id,
                                       x_credit_instrument                 => g_deposit,
                                       x_description                       => l_cur_fi_credits.description,
                                       x_amount                            => l_cur_fi_credits.amount,
                                       x_currency_cd                       => l_cur_fi_credits.currency_cd,
                                       x_exchange_rate                     => l_cur_fi_credits.exchange_rate,
                                       x_transaction_date                  => TRUNC(SYSDATE),
                                       x_effective_date                    => TRUNC(SYSDATE),
                                       x_reversal_date                     => NULL,
                                       x_reversal_reason_code              => NULL,
                                       x_reversal_comments                 => NULL,
                                       x_unapplied_amount                  => l_cur_fi_credits.unapplied_amount,
                                       x_source_transaction_id             => NULL,
                                       x_receipt_lockbox_number            => NULL,
                                       x_merchant_id                       => NULL,
                                       x_credit_card_code                  => NULL,
                                       x_credit_card_holder_name           => NULL,
                                       x_credit_card_number                => NULL,
                                       x_credit_card_expiration_date       => NULL,
                                       x_credit_card_approval_code         => NULL,
                                       x_awd_yr_cal_type                   => NULL,
                                       x_awd_yr_ci_sequence_number         => NULL,
                                       x_fee_cal_type                      => l_cur_fi_credits.fee_cal_type,
                                       x_fee_ci_sequence_number            => l_cur_fi_credits.fee_ci_sequence_number,
                                       x_attribute_category                => l_cur_fi_credits.attribute_category,
                                       x_attribute1                        => l_cur_fi_credits.attribute1,
                                       x_attribute2                        => l_cur_fi_credits.attribute2,
                                       x_attribute3                        => l_cur_fi_credits.attribute3,
                                       x_attribute4                        => l_cur_fi_credits.attribute4,
                                       x_attribute5                        => l_cur_fi_credits.attribute5,
                                       x_attribute6                        => l_cur_fi_credits.attribute6,
                                       x_attribute7                        => l_cur_fi_credits.attribute7,
                                       x_attribute8                        => l_cur_fi_credits.attribute8,
                                       x_attribute9                        => l_cur_fi_credits.attribute9,
                                       x_attribute10                       => l_cur_fi_credits.attribute10,
                                       x_attribute11                       => l_cur_fi_credits.attribute11,
                                       x_attribute12                       => l_cur_fi_credits.attribute12,
                                       x_attribute13                       => l_cur_fi_credits.attribute13,
                                       x_attribute14                       => l_cur_fi_credits.attribute14,
                                       x_attribute15                       => l_cur_fi_credits.attribute15,
                                       x_attribute16                       => l_cur_fi_credits.attribute16,
                                       x_attribute17                       => l_cur_fi_credits.attribute17,
                                       x_attribute18                       => l_cur_fi_credits.attribute18,
                                       x_attribute19                       => l_cur_fi_credits.attribute19,
                                       x_attribute20                       => l_cur_fi_credits.attribute20,
                                       x_gl_date                           => p_d_gl_date,
                                       x_check_number                      => NULL,
                                       x_source_transaction_type           => g_deposit,
                                       x_source_transaction_ref            => l_cur_fi_credits.credit_number,
                                       x_credit_card_payee_cd              => l_cur_fi_credits.credit_card_payee_cd,
                                       x_credit_card_status_code           => l_cur_fi_credits.credit_card_status_code,
                                       x_credit_card_tangible_cd           => l_cur_fi_credits.credit_card_tangible_cd,
                                       x_lockbox_interface_id              => l_cur_fi_credits.lockbox_interface_id,
                                       x_batch_name                        => l_cur_fi_credits.batch_name,
                                       x_deposit_date                      => l_cur_fi_credits.deposit_date,
                                       x_source_invoice_id                 => l_cur_fi_credits.source_invoice_id,
                                       x_tax_year_code                     => NULL
                                       );

         -- Derive the credit and debit accounting information
         -- The debit account will be the credit account of the base deposit record
         -- The credit account will be the credit account of the payment_credit_type_id
         -- attached to the base credit_type_id

         -- Using the credit_type_id of the base deposit, get the debit information
         OPEN cur_account_info(l_cur_fi_credits.credit_type_id);
         FETCH cur_account_info INTO l_cur_dr_account_info;
         CLOSE cur_account_info;

         -- For credit info, pass the payment_credit_type_id attached to the base credit_type_id
         OPEN cur_account_info(l_n_pay_credit_type_id);
         FETCH cur_account_info INTO l_cur_cr_account_info;
         CLOSE cur_account_info;

         -- Copy the ccid/account_cd depending on whether Financials is installed or not
         IF igs_fi_gen_005.finp_get_receivables_inst ='Y' THEN
            l_n_dr_gl_ccid    := l_cur_dr_account_info.cr_gl_ccid;
            l_n_cr_gl_ccid    := l_cur_cr_account_info.cr_gl_ccid;
            l_v_dr_account_cd := NULL;
            l_v_cr_account_cd := NULL;
         ELSE
            l_n_dr_gl_ccid     := NULL;
            l_n_cr_gl_ccid     := NULL;
            l_v_dr_account_cd  := l_cur_dr_account_info.cr_account_cd;
            l_v_cr_account_cd  := l_cur_cr_account_info.cr_account_cd;
         END IF;

       l_rowid := NULL;
       l_n_credit_activity_id := NULL;

       igs_fi_cr_activities_pkg.insert_row ( x_mode                              => 'R',
                                             x_rowid                             => l_rowid,
                                             x_credit_activity_id                => l_n_credit_activity_id,
                                             x_credit_id                         => l_n_credit_id,
                                             x_status                            => g_cleared,
                                             x_transaction_date                  => TRUNC(SYSDATE),
                                             x_amount                            => l_cur_fi_credits.amount,
                                             x_dr_account_cd                     => l_v_dr_account_cd,
                                             x_cr_account_cd                     => l_v_cr_account_cd,
                                             x_dr_gl_ccid                        => l_n_dr_gl_ccid,
                                             x_cr_gl_ccid                        => l_n_cr_gl_ccid,
                                             x_bill_id                           => NULL,
                                             x_bill_number                       => NULL,
                                             x_bill_date                         => NULL,
                                             x_gl_date                           => p_d_gl_date,
                                             x_gl_posted_date                    => NULL,
                                             x_posting_id                        => NULL
                                           );


         -- Call update balances to update holds and standard balances
         -- Update balances of balance type 'STANDARD'
         igs_fi_prc_balances.update_balances ( p_party_id       => l_cur_fi_credits.party_id,
                                               p_balance_type   => 'STANDARD',
                                               p_balance_date   => TRUNC(SYSDATE),
                                               p_amount         => NVL((-1)*l_cur_fi_credits.amount,0),  --Amount always passed as -ve
                                               p_source         => 'CREDIT',
                                               p_source_id      => l_n_credit_id,
                                               p_message_name   => l_v_message_name
                                             ) ;
         IF l_v_message_name IS NOT NULL THEN
            p_c_message_name := l_v_message_name;
            p_b_return_status := FALSE;
            p_c_receipt_number := NULL;
            RETURN;
         END IF;

         -- Update balances of balance type 'HOLDS'
         igs_fi_prc_balances.update_balances ( p_party_id       => l_cur_fi_credits.party_id,
                                               p_balance_type   => 'HOLDS',
                                               p_balance_date   => TRUNC(SYSDATE),
                                               p_amount         => NVL((-1)*l_cur_fi_credits.amount,0),  --Amount always passed as +ve
                                               p_source         => 'CREDIT',
                                               p_source_id      => l_n_credit_id,
                                               p_message_name   => l_v_message_name
                                              ) ;

         IF l_v_message_name IS NOT NULL THEN
            p_c_message_name := l_v_message_name;
            p_b_return_status := FALSE;
            p_c_receipt_number := NULL;
            RETURN;
         END IF;

     -- If payment creation was successful, return with success message and the
     -- credit number of the new receipt created.
     p_c_message_name := 'IGS_FI_DP_TRANSFERRED';
     p_b_return_status := TRUE;
     p_c_receipt_number := l_v_credit_number;

 END transfer_deposit;

END igs_fi_deposits_prcss;

/
