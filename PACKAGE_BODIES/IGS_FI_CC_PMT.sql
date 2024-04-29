--------------------------------------------------------
--  DDL for Package Body IGS_FI_CC_PMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CC_PMT" AS
/* $Header: IGSFI86B.pls 120.2 2006/05/04 08:07:37 abshriva ship $ */

CURSOR c_credits(cp_cc      IN VARCHAR2,
                 cp_pending IN VARCHAR2)
IS
SELECT fc.rowid, fc.*
FROM   igs_fi_credits_all fc
WHERE  credit_instrument       = cp_cc
AND    credit_card_status_code = cp_pending
AND    credit_card_tangible_cd IS NOT NULL
FOR UPDATE NOWAIT;

CURSOR c_app_req(cp_pending IN VARCHAR2)
IS
SELECT aar.rowid, aar.*
FROM   igs_ad_app_req aar
WHERE  credit_card_number IS NOT NULL
AND    credit_card_status_code = cp_pending
AND    credit_card_tangible_cd IS NOT NULL
FOR UPDATE NOWAIT;

l_b_records BOOLEAN := FALSE;

PROCEDURE local_upd(p_r_crd_row    IN c_credits%ROWTYPE,
                    p_r_ad_app_row IN c_app_req%ROWTYPE
                   ) AS
  ------------------------------------------------------------------
  --Created by  : schodava, Oracle IDC
  --Date created: 09-Jun-2003
  --
  --Purpose: Local Procedure, to query the IBY table, and update the
  --         Credits and AD Applications Request table.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --agairola    29-Aug-2005     Tuition Waiver build: 3392095: Changes done for this build
  --pathipat    21-Apr-2004     Enh 3558549 - Comm Receivables Enh
  --                            Added param x_source_invoice_id in call to igs_fi_credits_pkg.update_row()
  --vvutukur    09-Oct-2003    Bug#3160036.Replaced the call to igs_ad_app_req.update_row with
  --                           call to igs_ad_gen_015.update_igs_ad_app_req.
  -------------------------------------------------------------------

  -- Get the payment status
  CURSOR c_iby_trans(cp_tangible_id IN iby_trans_all_v.tangibleid%TYPE,
                     cp_payee_id    IN iby_trans_all_v.payeeid%TYPE,
                     cp_capture     IN VARCHAR2) IS
  SELECT status
  FROM   iby_trans_all_v
  WHERE  tangibleid = cp_tangible_id AND
         payeeid    = cp_payee_id    AND
         reqtype    = cp_capture
  ORDER BY reqdate DESC;

  -- Get the person number of the person
  CURSOR c_pers(cp_person_id IN hz_parties.party_id%TYPE
               ) IS
  SELECT party_number
  FROM   hz_parties
  WHERE  party_id = cp_person_id;

  e_skip EXCEPTION;

  l_n_status         iby_trans_all_v.status%TYPE;
  l_c_cc_status      igs_fi_credits_all.credit_card_status_code%TYPE := 'PENDING';
  l_c_tangible_cd    igs_fi_credits_all.credit_card_tangible_cd%TYPE;
  l_c_payee_cd       igs_fi_credits_all.credit_card_payee_cd%TYPE;
  l_flag             BOOLEAN := FALSE;
  l_c_pnum           hz_parties.party_number%TYPE;
  l_b_exception_flag BOOLEAN := FALSE;

  g_c_capture CONSTANT VARCHAR2(13):= 'ORAPMTCAPTURE';
  g_c_failure CONSTANT VARCHAR2(7) := 'FAILURE';
  g_c_success CONSTANT VARCHAR2(7) := 'SUCCESS';

BEGIN

  -- There exists at least on credit or admission record to process
  l_b_records := TRUE;
  -- Fetch the tangible code and payee code depending
  -- on whether a credit or admission appln. record is passed
  IF p_r_crd_row.party_id IS NOT NULL THEN
    l_c_tangible_cd := p_r_crd_row.credit_card_tangible_cd;
    l_c_payee_cd    := p_r_crd_row.credit_card_payee_cd;
  ELSIF p_r_ad_app_row.person_id IS NOT NULL THEN
    l_c_tangible_cd := p_r_ad_app_row.credit_card_tangible_cd;
    l_c_payee_cd    := p_r_ad_app_row.credit_card_payee_cd;
  END IF;

  -- Fetch the status number from the IBY table
  OPEN c_iby_trans(cp_tangible_id => l_c_tangible_cd,
                   cp_payee_id    => l_c_payee_cd,
                   cp_capture     => g_c_capture);
  FETCH c_iby_trans INTO l_n_status;
  CLOSE c_iby_trans;

  IF (l_n_status = 114) OR (l_n_status < 99 AND l_n_status > 0) THEN
    -- the transaction is a failure
    l_c_cc_status := g_c_failure;
  ELSIF l_n_status = 0 THEN
    -- the transaction is a success
    l_c_cc_status := g_c_success;
  END IF;

  -- Fetch the person number
  OPEN c_pers(NVL(p_r_crd_row.party_id,p_r_ad_app_row.person_id));
  FETCH c_pers INTO l_c_pnum;
  CLOSE c_pers;

  -- Log the person number
  fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||l_c_pnum);

  -- Update the OSS Tables (Credits, Admissions Applications Request)
  -- only if the credit card status is changed to failure or success
  -- from 'Pending'
  IF l_c_cc_status in (g_c_failure,g_c_success) THEN
    l_flag := TRUE;
  END IF;

  IF p_r_crd_row.party_id IS NOT NULL THEN

    -- Log the Receipt Number
    fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','RECEIPT_NUMBER')||': '||p_r_crd_row.credit_number);

    IF l_flag THEN
      -- Update the credit card status in the Credits Table
      SAVEPOINT sp_crd;
      BEGIN
        igs_fi_credits_pkg.update_row(
         x_rowid                       => p_r_crd_row.rowid,
         x_credit_id                   => p_r_crd_row.credit_id,
         x_credit_number               => p_r_crd_row.credit_number,
         x_status                      => p_r_crd_row.status,
         x_credit_source               => p_r_crd_row.credit_source,
         x_party_id                    => p_r_crd_row.party_id,
         x_credit_type_id              => p_r_crd_row.credit_type_id,
         x_credit_instrument           => p_r_crd_row.credit_instrument,
         x_description                 => p_r_crd_row.description,
         x_amount                      => p_r_crd_row.amount,
         x_currency_cd                 => p_r_crd_row.currency_cd,
         x_exchange_rate               => p_r_crd_row.exchange_rate,
         x_transaction_date            => p_r_crd_row.transaction_date,
         x_effective_date              => p_r_crd_row.effective_date,
         x_reversal_date               => p_r_crd_row.reversal_date,
         x_reversal_reason_code        => p_r_crd_row.reversal_reason_code,
         x_reversal_comments           => p_r_crd_row.reversal_comments,
         x_unapplied_amount            => p_r_crd_row.unapplied_amount,
         x_source_transaction_id       => p_r_crd_row.source_transaction_id,
         x_receipt_lockbox_number      => p_r_crd_row.receipt_lockbox_number,
         x_merchant_id                 => p_r_crd_row.merchant_id,
         x_credit_card_code            => p_r_crd_row.credit_card_code,
         x_credit_card_holder_name     => p_r_crd_row.credit_card_holder_name,
         x_credit_card_number          => p_r_crd_row.credit_card_number,
         x_credit_card_expiration_date => p_r_crd_row.credit_card_expiration_date,
         x_credit_card_approval_code   => p_r_crd_row.credit_card_approval_code,
         x_awd_yr_cal_type             => p_r_crd_row.awd_yr_cal_type,
         x_awd_yr_ci_sequence_number   => p_r_crd_row.awd_yr_ci_sequence_number,
         x_fee_cal_type                => p_r_crd_row.fee_cal_type,
         x_fee_ci_sequence_number      => p_r_crd_row.fee_ci_sequence_number,
         x_attribute_category          => p_r_crd_row.attribute_category,
         x_attribute1                  => p_r_crd_row.attribute1,
         x_attribute2                  => p_r_crd_row.attribute2,
         x_attribute3                  => p_r_crd_row.attribute3,
         x_attribute4                  => p_r_crd_row.attribute4,
         x_attribute5                  => p_r_crd_row.attribute5,
         x_attribute6                  => p_r_crd_row.attribute6,
         x_attribute7                  => p_r_crd_row.attribute7,
         x_attribute8                  => p_r_crd_row.attribute8,
         x_attribute9                  => p_r_crd_row.attribute9,
         x_attribute10                 => p_r_crd_row.attribute10,
         x_attribute11                 => p_r_crd_row.attribute11,
         x_attribute12                 => p_r_crd_row.attribute12,
         x_attribute13                 => p_r_crd_row.attribute13,
         x_attribute14                 => p_r_crd_row.attribute14,
         x_attribute15                 => p_r_crd_row.attribute15,
         x_attribute16                 => p_r_crd_row.attribute16,
         x_attribute17                 => p_r_crd_row.attribute17,
         x_attribute18                 => p_r_crd_row.attribute18,
         x_attribute19                 => p_r_crd_row.attribute19,
         x_attribute20                 => p_r_crd_row.attribute20,
         x_gl_date                     => p_r_crd_row.gl_date,
         x_check_number                => p_r_crd_row.check_number,
         x_source_transaction_type     => p_r_crd_row.source_transaction_type,
         x_source_transaction_ref      => p_r_crd_row.source_transaction_ref,
         x_credit_card_status_code     => l_c_cc_status,
         x_credit_card_payee_cd        => p_r_crd_row.credit_card_payee_cd,
         x_credit_card_tangible_cd     => p_r_crd_row.credit_card_tangible_cd,
         x_source_invoice_id           => p_r_crd_row.source_invoice_id,
         x_tax_year_code               => p_r_crd_row.tax_year_code,
	 x_waiver_name                 => p_r_crd_row.waiver_name
        );
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO sp_crd;
          l_b_exception_flag := TRUE;
          fnd_file.put_line(fnd_file.log,sqlerrm);
          fnd_file.new_line(fnd_file.log);
      END;
    END IF;  -- For l_flag

  ELSIF p_r_ad_app_row.person_id IS NOT NULL THEN

    -- Log the Admission Application Id
    fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','ADM_APPL_ID')||': '||p_r_ad_app_row.app_req_id);

    IF l_flag THEN
      SAVEPOINT sp_adm;
      BEGIN
        -- Update the credit card status in the Admissions Applications Request Table
        igs_ad_gen_015.update_igs_ad_app_req(
          p_rowid                         => p_r_ad_app_row.rowid,
          p_app_req_id                    => p_r_ad_app_row.app_req_id,
          p_person_id                     => p_r_ad_app_row.person_id,
          p_admission_appl_number         => p_r_ad_app_row.admission_appl_number,
          p_applicant_fee_type            => p_r_ad_app_row.applicant_fee_type,
          p_applicant_fee_status          => p_r_ad_app_row.applicant_fee_status,
          p_fee_date                      => p_r_ad_app_row.fee_date,
          p_fee_payment_method            => p_r_ad_app_row.fee_payment_method,
          p_fee_amount                    => p_r_ad_app_row.fee_amount,
          p_reference_num                 => p_r_ad_app_row.reference_num,
          p_credit_card_code              => p_r_ad_app_row.credit_card_code,
          p_credit_card_holder_name       => p_r_ad_app_row.credit_card_holder_name,
          p_credit_card_number            => p_r_ad_app_row.credit_card_number,
          p_credit_card_expiration_date   => p_r_ad_app_row.credit_card_expiration_date,
          p_rev_gl_ccid                   => p_r_ad_app_row.rev_gl_ccid,
          p_cash_gl_ccid                  => p_r_ad_app_row.cash_gl_ccid,
          p_rev_account_cd                => p_r_ad_app_row.rev_account_cd,
          p_cash_account_cd               => p_r_ad_app_row.cash_account_cd,
          p_posting_control_id            => p_r_ad_app_row.posting_control_id,
          p_gl_date                       => p_r_ad_app_row.gl_date,
          p_gl_posted_date                => p_r_ad_app_row.gl_posted_date,
          p_credit_card_tangible_cd       => p_r_ad_app_row.credit_card_tangible_cd,
          p_credit_card_payee_cd          => p_r_ad_app_row.credit_card_payee_cd,
          p_credit_card_status_code       => l_c_cc_status,
          p_mode                          => 'R'
          );
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO sp_adm;
          l_b_exception_flag := TRUE;
          fnd_file.put_line(fnd_file.log,sqlerrm);
          fnd_file.new_line(fnd_file.log);
      END;
    END IF;
  END IF;

  IF NOT l_b_exception_flag THEN
    -- Log the Credit Card Status of the person
    fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CC_STATUS')||': '||
                    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CARD_STATUS',l_c_cc_status));
    fnd_file.new_line(fnd_file.log);
  END IF;

END local_upd;

PROCEDURE upd_status(errbuf                OUT NOCOPY VARCHAR2,
                     retcode               OUT NOCOPY NUMBER
                     ) AS
  ------------------------------------------------------------------
  --Created by  : schodava, Oracle IDC
  --Date created: 09-Jun-2003
  --
  --Purpose: Concurrent program to Update the Credit Card Status
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
  -------------------------------------------------------------------

  g_c_pending      CONSTANT VARCHAR2(7) := 'PENDING';
  g_c_cc           CONSTANT VARCHAR2(2) := 'CC';
  l_c_manage_acc   igs_fi_control_all.manage_accounts%TYPE;
  l_c_message_name fnd_new_messages.message_name%TYPE;
  l_org_id     VARCHAR2(15);
  e_resource_busy EXCEPTION;
  PRAGMA          EXCEPTION_INIT(e_resource_busy,-0054);

  BEGIN

    BEGIN
      l_org_id := NULL;
      igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
      WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        retcode:=2;
        RETURN;
    END;
    retcode := 0;
    errbuf  := NULL;

   -- Call the generic proc to obtain the Manage Accounts set up
   -- in the System Options form.
   igs_fi_com_rec_interface.chk_manage_account(p_v_manage_acc   => l_c_manage_acc,
                                               p_v_message_name => l_c_message_name);

   -- If Manage Accounts is 'Other' or Null, then this process is not available.
   IF (l_c_manage_acc = 'OTHER') OR (l_c_manage_acc IS NULL) THEN
      fnd_message.set_name('IGS',l_c_message_name);
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.new_line(fnd_file.log);
      retcode := 2;
      RETURN;
   END IF;

   -- For each credit record
   FOR rec_credits IN c_credits(cp_cc      => g_c_cc,
                                cp_pending => g_c_pending) LOOP
     -- call the local procedure for processing
     local_upd(p_r_crd_row      => rec_credits,
               p_r_ad_app_row   => NULL);
   END LOOP;

   -- For each admission application record
   FOR rec_app_req IN c_app_req(cp_pending => g_c_pending) LOOP
     -- call the local procedure for processing
     local_upd(p_r_crd_row    => NULL,
               p_r_ad_app_row => rec_app_req);
   END LOOP;

   -- Log a message if there are no records to process
   IF NOT l_b_records THEN
     fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
     fnd_file.put_line(fnd_file.log,fnd_message.get());
   END IF;


EXCEPTION
  WHEN e_resource_busy THEN
     ROLLBACK;
     fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
     fnd_file.put_line(fnd_file.log,fnd_message.get());
     fnd_file.new_line(fnd_file.log);
     retcode := 2;

  WHEN OTHERS THEN
     ROLLBACK;
     retcode := 2;
     errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||' - '||SUBSTR(SQLERRM,1,40);
     igs_ge_msg_stack.add;
     igs_ge_msg_stack.conc_exception_hndl;

END upd_status;

END igs_fi_cc_pmt;

/
