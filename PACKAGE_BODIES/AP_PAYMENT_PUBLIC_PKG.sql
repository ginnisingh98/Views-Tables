--------------------------------------------------------
--  DDL for Package Body AP_PAYMENT_PUBLIC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAYMENT_PUBLIC_PKG" AS
/* $Header: appaypkb.pls 120.2.12010000.4 2009/04/15 08:22:17 njakkula ship $ */

-- =====================================================================
--                   P U B L I C    O B J E C T S
-- =====================================================================

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(35) := 'AP.PLSQL.AP_PAYMENT_PUBLIC_PKG.';

  PROCEDURE Create_Netting_Payment(
            P_Check_Rec                 IN
            AP_CHECKS_ALL%ROWTYPE,
            P_Invoice_Payment_Info_Tab  IN
            AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Tab,
            P_Check_ID                  OUT NOCOPY   NUMBER,
            P_Curr_Calling_Sequence     IN VARCHAR2,
            p_gl_date                   IN  DATE DEFAULT NULL/* p_gl_date Added for bug#7663371 */) IS

    l_debug_info               VARCHAR2(1000);
    l_curr_calling_sequence    VARCHAR2(2000);

    -- Check Record Related Variables
    l_rowid                    VARCHAR2(18);
    l_seq_num_profile          VARCHAR2(100);
    l_dbseqnm                  FND_DOCUMENT_SEQUENCES.DB_SEQUENCE_NAME%TYPE;
    l_dbseqid                  FND_DOCUMENT_SEQUENCES.DOC_SEQUENCE_ID%TYPE;
    l_set_of_books_id          NUMBER(15);
    l_return_code              NUMBER;
    l_doc_category_code        VARCHAR2(100);
    l_doc_sequence_value       NUMBER;
    l_check_id                 NUMBER;
    l_payment_method_code      VARCHAR2(100);
    l_payment_type             VARCHAR2(1);
    l_payment_status           VARCHAR2(30);
    l_base_currency_code       VARCHAR2(15);

    l_accounting_event_id      NUMBER;
    l_period_name              gl_period_statuses.period_name%TYPE;

    -- Package Related Variables
    Netting_Exception EXCEPTION;
    l_gl_date       DATE; /* Added for bug#7663371 */

  BEGIN

    ---------------------------------------------------------------------------
    l_debug_info := 'Begin Create_Netting_Payment';
    l_curr_calling_sequence := 'AP_PAYMENT_PUBLIC_PKG.Create_Netting_Payment'||
                               ' <-- '||P_Curr_Calling_Sequence;


    ---------------------------------------------------------------------------
    l_debug_info := 'Initialize Variables';

    l_doc_category_code := 'NETTING';
    l_payment_method_code := 'NETTING';
    l_payment_Type        := 'N';
    l_payment_status      := 'NEGOTIABLE';

    /* Added for bug#7663371 Start */
    IF p_gl_date IS NULL OR p_gl_date = ''
    THEN
      l_gl_date  := p_check_rec.check_date;
    ELSE
      l_gl_date  := p_gl_date;
    END IF;
    /* Added for bug#7663371 End */

    ---------------------------------------------------------------------------
    l_debug_info := 'Get Set of Books/Currency Information';
    BEGIN
       SELECT set_of_books_id,
              base_currency_code
       INTO   l_set_of_books_id,
              l_base_currency_code
       FROM   ap_system_parameters
       WHERE  org_id = p_check_rec.org_id;
    EXCEPTION
    WHEN OTHERS THEN
       RAISE Netting_Exception;
    END;

    ---------------------------------------------------------------------------
    l_debug_info := 'Get Period Name';

    l_period_name := ap_utilities_pkg.Get_current_gl_date
                     (/*p_check_rec.check_date, Commented for bug#7663371 */
                      l_gl_date, /* Added for bug#7663371*/
                      p_check_rec.org_id);


    ---------------------------------------------------------------------------
    l_debug_info := 'Get Document Sequencing Information';

    FND_PROFILE.GET('UNIQUE:SEQ_NUMBERS',l_seq_num_profile);
    IF (l_seq_num_profile IN ('A','P')) Then
          BEGIN
            SELECT SEQ.DB_SEQUENCE_NAME,
                   SEQ.DOC_SEQUENCE_ID
            INTO   l_dbseqnm, l_dbseqid
            FROM   FND_DOCUMENT_SEQUENCES SEQ,
                   FND_DOC_SEQUENCE_ASSIGNMENTS SA
            WHERE  SEQ.DOC_SEQUENCE_ID        = SA.DOC_SEQUENCE_ID
            AND    SA.APPLICATION_ID          = 200
            AND    SA.CATEGORY_CODE           = 'NETTING'
            AND    NVL(SA.METHOD_CODE,'A') = 'A'
            AND    SA.SET_OF_BOOKS_ID = l_set_of_books_id
            AND    nvl(p_check_rec.check_date, sysdate) BETWEEN SA.START_DATE
                   AND nvl(SA.END_DATE, TO_DATE('31/12/4712','DD/MM/YYYY'));
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
  		  FND_Message.set_name('SQLAP', 'AP_SEQ_DOC_CAT_NO_FOUND');
              APP_EXCEPTION.RAISE_EXCEPTION;
          END;

      -------------------------------------------------------------------------
      l_debug_info := 'Get Doc Sequence Next Val';
      l_return_code := FND_SEQNUM.GET_SEQ_VAL(
                             200,
                             'NETTING',
                             l_set_of_books_id,
                             'A',
                             nvl(trunc(p_check_rec.check_date), trunc(sysdate)),
                             l_doc_sequence_value,
                             l_dbseqid,
                             'N',
                             'N');
          IF ((l_doc_sequence_value IS NULL) OR (l_return_code <> 0)) THEN
             FND_MESSAGE.SET_NAME('SQLAP', 'AP_SEQ_CREATE_ERROR');
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;
      END IF;

    ---------------------------------------------------------------------------
    l_debug_info := 'Get Check ID';
    BEGIN
       SELECT ap_checks_s.nextval
       INTO   l_check_id
       FROM   DUAL;
    EXCEPTION
    WHEN OTHERS THEN
       RAISE Netting_Exception;
    END;

    ---------------------------------------------------------------------------
    l_debug_info := 'Create AP_CHECKS_ALL Record';
    AP_AC_TABLE_HANDLER_PKG.Insert_Row(
              l_rowid,
              p_check_rec.amount,
              p_check_rec.ce_bank_acct_use_id,
              p_check_rec.bank_account_name,
              p_check_rec.check_date,
              l_check_id,
              p_check_rec.check_number,
              p_check_rec.currency_code,
              p_check_rec.last_updated_by,
              p_check_rec.last_update_date,
              l_payment_type,
              p_check_rec.address_line1,
              p_check_rec.address_line2,
              p_check_rec.address_line3,
              p_check_rec.checkrun_name,
              p_check_rec.check_format_id,
              p_check_rec.check_stock_id,
              p_check_rec.city,
              p_check_rec.country,
              p_check_rec.created_by,
              p_check_rec.creation_date,
              p_check_rec.last_update_login,
              l_payment_status,
              p_check_rec.vendor_name,
              p_check_rec.vendor_site_code,
              p_check_rec.external_bank_account_id,
              p_check_rec.zip,
              p_check_rec.bank_account_num,
              p_check_rec.bank_account_type,
              p_check_rec.bank_num,
              p_check_rec.check_voucher_num,
              p_check_rec.cleared_amount,
              p_check_rec.cleared_date,
              l_doc_category_code,
              l_dbseqid,
              l_doc_sequence_value,
              p_check_rec.province,
              p_check_rec.released_date,
              p_check_rec.released_by,
              p_check_rec.state,
              p_check_rec.stopped_date,
              p_check_rec.stopped_by,
              p_check_rec.void_date,
              p_check_rec.attribute1,
              p_check_rec.attribute10,
              p_check_rec.attribute11,
              p_check_rec.attribute12,
              p_check_rec.attribute13,
              p_check_rec.attribute14,
              p_check_rec.attribute15,
              p_check_rec.attribute2,
              p_check_rec.attribute3,
              p_check_rec.attribute4,
              p_check_rec.attribute5,
              p_check_rec.attribute6,
              p_check_rec.attribute7,
              p_check_rec.attribute8,
              p_check_rec.attribute9,
              p_check_rec.attribute_category,
              p_check_rec.future_pay_due_date,
              p_check_rec.treasury_pay_date,
              p_check_rec.treasury_pay_number,
              p_check_rec.withholding_status_lookup_code,
              p_check_rec.reconciliation_batch_id,
              p_check_rec.cleared_base_amount,
              p_check_rec.cleared_exchange_rate,
              p_check_rec.cleared_exchange_date,
              p_check_rec.cleared_exchange_rate_type,
              p_check_rec.address_line4,
              p_check_rec.county,
              p_check_rec.address_style,
              p_check_rec.org_id,
              p_check_rec.vendor_id,
              p_check_rec.vendor_site_id,
              p_check_rec.exchange_rate,
              p_check_rec.exchange_date,
              p_check_rec.exchange_rate_type,
              p_check_rec.base_amount,
              p_check_rec.checkrun_id,
              p_check_rec.global_attribute_category,
              p_check_rec.global_attribute1,
              p_check_rec.global_attribute2,
              p_check_rec.global_attribute3,
              p_check_rec.global_attribute4,
              p_check_rec.global_attribute5,
              p_check_rec.global_attribute6,
              p_check_rec.global_attribute7,
              p_check_rec.global_attribute8,
              p_check_rec.global_attribute9,
              p_check_rec.global_attribute10,
              p_check_rec.global_attribute11,
              p_check_rec.global_attribute12,
              p_check_rec.global_attribute13,
              p_check_rec.global_attribute14,
              p_check_rec.global_attribute15,
              p_check_rec.global_attribute16,
              p_check_rec.global_attribute17,
              p_check_rec.global_attribute18,
              p_check_rec.global_attribute19,
              p_check_rec.global_attribute20,
              p_check_rec.transfer_priority,
              p_check_rec.maturity_exchange_rate_type,
              p_check_rec.maturity_exchange_date,
              p_check_rec.maturity_exchange_rate,
              p_check_rec.description,
              p_check_rec.anticipated_value_date,
              p_check_rec.actual_value_date,
              l_payment_method_code,
              p_check_rec.payment_profile_id,
              p_check_rec.bank_charge_bearer,
              p_check_rec.settlement_priority,
              p_check_rec.payment_document_id,
              p_check_rec.party_id,
              p_check_rec.party_site_id,
              p_check_rec.legal_entity_id,
              p_check_rec.payment_id,
              l_curr_calling_sequence);

    ---------------------------------------------------------------------------
    l_debug_info := 'Create Accounting Events';
    AP_ACCOUNTING_EVENTS_PKG.CREATE_EVENTS
      (
        p_event_type          => 'PAYMENT',
        p_doc_type            => l_payment_type,
        p_doc_id              => l_check_id,
        p_accounting_date     => l_gl_date,          /* SYSDATE, Changed Sysdate to l_gl_date for bug#7663371 */
        p_accounting_event_id => l_accounting_event_id,
        p_checkrun_name       => NULL,
        p_calling_sequence    => 'l_curr_calling_sequence'
      );

    ---------------------------------------------------------------------------
    l_debug_info := 'Create Payment History for Payment Creation';
    AP_RECONCILIATION_PKG.insert_payment_history
     (
      x_check_id                => l_check_id,
      x_transaction_type        => 'PAYMENT CREATED',
      x_accounting_date         => l_gl_date,          /* SYSDATE, Changed Sysdate to l_gl_date for bug#7663371 */
      x_trx_bank_amount         => NULL,
      x_errors_bank_amount      => NULL,
      x_charges_bank_amount     => NULL,
      x_bank_currency_code      => NULL,
      x_bank_to_base_xrate_type => NULL,
      x_bank_to_base_xrate_date => NULL,
      x_bank_to_base_xrate      => NULL,
      x_trx_pmt_amount          => p_check_rec.amount,
      x_errors_pmt_amount       => NULL,
      x_charges_pmt_amount      => NULL,
      x_pmt_currency_code       => p_check_rec.currency_code,
      x_pmt_to_base_xrate_type  => p_check_rec.exchange_rate_type,
      x_pmt_to_base_xrate_date  => p_check_Rec.exchange_date,
      x_pmt_to_base_xrate       => p_check_Rec.exchange_rate,
      x_trx_base_amount         => p_check_rec.base_amount,
      x_errors_base_amount      => NULL,
      x_charges_base_amount     => NULL,
      x_matched_flag            => NULL,
      x_rev_pmt_hist_id         => NULL,
      x_org_id                  => p_check_rec.org_id,
      x_creation_date           => p_check_rec.creation_date,
      x_created_by              => p_check_rec.created_by,
      x_last_update_date        => p_check_rec.last_update_date,
      x_last_updated_by         => p_check_rec.last_updated_by,
      x_last_update_login       => p_check_rec.last_update_login,
      x_program_update_date     => NULL,
      x_program_application_id  => NULL,
      x_program_id              => NULL,
      x_request_id              => NULL,
      x_calling_sequence        => l_curr_calling_sequence,
      x_accounting_event_id     => l_accounting_event_id
      );


    ---------------------------------------------------------------------------
    l_debug_info := 'Create Invoice Payments';
    AP_PAYMENT_PUBLIC_PKG.Create_Netting_Inv_Payment
            (P_Invoice_Payment_Info_Tab  =>  P_Invoice_Payment_Info_Tab,
             P_check_id                  =>  l_check_id,
             P_payment_type_flag         =>  l_payment_type,
             P_payment_method            =>  l_payment_method_code,
             P_ce_bank_acct_use_id       =>  p_check_rec.ce_bank_acct_use_id,
             P_bank_account_num          =>  p_check_rec.bank_account_num,
             P_bank_account_type         =>  p_check_rec.bank_account_type,
             P_bank_num                  =>  p_check_rec.bank_num,
             P_check_date                =>  l_gl_date,               /* p_check_rec.check_date,    Added l_gl_date for bug#7663371 */
             P_period_name               =>  l_period_name,
             P_currency_code             =>  p_check_rec.currency_code,
             P_base_currency_code        =>  l_base_currency_code,
             P_checkrun_id               =>  p_check_rec.checkrun_id,
             P_exchange_rate             =>  p_check_rec.exchange_rate,
             P_exchange_rate_type        =>  p_check_rec.exchange_rate_type,
             P_exchange_date             =>  p_check_rec.exchange_date,
             P_set_of_books_id           =>  l_set_of_books_id,
             P_last_updated_by           =>  p_check_Rec.last_updated_by,
             P_last_update_login         =>  p_check_Rec.last_update_login,
             P_accounting_event_id       =>  l_accounting_event_id,
             P_org_id                    =>  p_check_rec.org_id,
             P_calling_sequence          =>  l_curr_calling_sequence
             );

    ---------------------------------------------------------------------------
    l_debug_info := 'Insert Clearing Records';
    AP_RECONCILIATION_PKG.Recon_Payment_History
            (X_CHECKRUN_ID             =>  NULL,
             X_CHECK_ID                =>  l_check_id,
             X_ACCOUNTING_DATE         =>  l_gl_date,          /* SYSDATE, Changed Sysdate to p_gl_date for bug#7663371 */
             X_CLEARED_DATE            =>  SYSDATE,
             X_TRANSACTION_AMOUNT      =>  p_check_rec.amount,
             X_TRANSACTION_TYPE        =>  'PAYMENT CLEARING',
             X_ERROR_AMOUNT            =>  NULL,
             X_CHARGE_AMOUNT           =>  NULL,
             X_CURRENCY_CODE           =>  p_check_rec.currency_code,
             X_EXCHANGE_RATE_TYPE      =>  p_check_rec.exchange_rate_type,
             X_EXCHANGE_RATE_DATE      =>  p_check_Rec.exchange_date,
             X_EXCHANGE_RATE           =>  p_check_Rec.exchange_rate,
             X_MATCHED_FLAG            =>  'N',
             X_ACTUAL_VALUE_DATE       =>  NULL,
             X_LAST_UPDATE_DATE        =>  SYSDATE,
             X_LAST_UPDATED_BY         =>  p_check_rec.created_by,
             X_LAST_UPDATE_LOGIN       =>  p_check_rec.last_update_login,
             X_CREATED_BY              =>  p_check_rec.created_by,
             X_CREATION_DATE           =>  SYSDATE,
             X_PROGRAM_UPDATE_DATE     =>  NULL,
             X_PROGRAM_APPLICATION_ID  =>  NULL,
             X_PROGRAM_ID              =>  NULL,
             X_REQUEST_ID              =>  NULL,
             X_CALLING_SEQUENCE        =>  l_curr_calling_sequence);


    ---------------------------------------------------------------------------
    l_debug_info := 'Assign the OUT Variable';
    P_Check_ID := l_check_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Create_Netting_Payment;

  --
  PROCEDURE Create_Netting_Inv_Payment
            (P_Invoice_Payment_Info_Tab  IN
             AP_PAYMENT_PUBLIC_PKG.Invoice_Payment_Info_Tab,
             P_check_id                  IN  NUMBER,
             P_payment_type_flag         IN  VARCHAR2,
             P_payment_method            IN  VARCHAR2,
             P_ce_bank_acct_use_id       IN  NUMBER,
             P_bank_account_num          IN  VARCHAR2,
             P_bank_account_type         IN  VARCHAR2,
             P_bank_num                  IN  VARCHAR2,
             P_check_date                IN  DATE,
             P_period_name               IN  VARCHAR2,
             P_currency_code             IN  VARCHAR2,
             P_base_currency_code        IN  VARCHAR2,
             P_checkrun_id               IN  NUMBER,
             P_exchange_rate             IN  NUMBER,
             P_exchange_rate_type        IN  VARCHAR2,
             P_exchange_date             IN  DATE,
             P_set_of_books_id           IN  NUMBER,
             P_last_updated_by           IN  NUMBER,
             P_last_update_login         IN  NUMBER,
             P_accounting_event_id       IN  NUMBER,
             P_org_id                    IN  NUMBER,
             P_calling_sequence          IN  VARCHAR2
            )
  IS
    l_debug_info    VARCHAR2(240);
    l_curr_calling_sequence VARCHAR2(2000);

    l_invoice_payment_id  NUMBER;
    l_payment_num   NUMBER;
    l_invoice_type    VARCHAR2(25);
    l_invoice_num   VARCHAR2(50);
    l_vendor_id     NUMBER;
    l_vendor_site_id    NUMBER;
    l_exclusive_payment_flag  VARCHAR2(1);
    l_future_pay_posted_flag  VARCHAR2(1);
    l_accts_pay_ccid    NUMBER;
    l_amount      NUMBER;
    l_amount_remaining    NUMBER;
    l_discount_available  NUMBER;
    l_discount_taken    NUMBER;
    l_interest_invoice_id NUMBER;
    l_interest_invoice_pay_id   NUMBER;
    l_interest_amount   NUMBER;
    l_payment_amount            NUMBER;
    l_due_date      DATE;
    l_interest_invoice_num  VARCHAR2(50);
    l_invoice_description       VARCHAR2(240);
    l_attribute1    VARCHAR2(150);
    l_attribute2    VARCHAR2(150);
    l_attribute3    VARCHAR2(150);
    l_attribute4    VARCHAR2(150);
    l_attribute5    VARCHAR2(150);
    l_attribute6    VARCHAR2(150);
    l_attribute7    VARCHAR2(150);
    l_attribute8    VARCHAR2(150);
    l_attribute9    VARCHAR2(150);
    l_attribute10   VARCHAR2(150);
    l_attribute11   VARCHAR2(150);
    l_attribute12   VARCHAR2(150);
    l_attribute13   VARCHAR2(150);
    l_attribute14   VARCHAR2(150);
    l_attribute15   VARCHAR2(150);
    l_attribute_category  VARCHAR2(150);

  BEGIN
    l_curr_calling_sequence :=
             'AP_PAYMENT_PUBLIC_PKG.Create_Netting_Inv_Payment<-' ||
             P_calling_sequence;

   --
   -- Create Invoice Payments Start
   --
   l_debug_info := 'Create Invoice Payments Start';


    FOR i IN
          P_Invoice_Payment_Info_Tab.FIRST ..
          P_Invoice_Payment_Info_Tab.LAST
    LOOP

     --
     -- Get Payment Schedules information
     --
     l_debug_info := 'Get Payment Schedules Information';

     SELECT APS.payment_num,
       AIRP.invoice_type_lookup_code,
       AIRP.invoice_num,
       AIRP.vendor_id,
       AIRP.vendor_site_id,
       AIRP.exclusive_payment_flag,
       AIRP.accts_pay_code_combination_id,
       APS.amount_remaining,
       APS.attribute1,
       APS.attribute2,
       APS.attribute3,
       APS.attribute4,
       APS.attribute5,
       APS.attribute6,
       APS.attribute7,
       APS.attribute8,
       APS.attribute9,
       APS.attribute10,
       APS.attribute11,
       APS.attribute12,
       APS.attribute13,
       APS.attribute14,
       APS.attribute15,
       APS.attribute_category
     INTO
      l_payment_num,
      l_invoice_type,
      l_invoice_num,
      l_vendor_id,
      l_vendor_site_id,
      l_exclusive_payment_flag,
      l_accts_pay_ccid,
      l_amount_remaining,
      l_attribute1,
      l_attribute2,
      l_attribute3,
      l_attribute4,
      l_attribute5,
      l_attribute6,
      l_attribute7,
      l_attribute8,
      l_attribute9,
      l_attribute10,
      l_attribute11,
      l_attribute12,
      l_attribute13,
      l_attribute14,
      l_attribute15,
      l_attribute_category
     FROM   ap_invoices AIRP,
            ap_payment_schedules       APS
     WHERE  AIRP.invoice_id = P_Invoice_Payment_Info_Tab(i).invoice_id
     AND    APS.payment_num = P_Invoice_Payment_Info_Tab(i).payment_schedule_num
     AND    APS.checkrun_id = P_checkrun_id
     AND    APS.invoice_id = AIRP.invoice_id;

     l_amount := P_Invoice_Payment_Info_Tab(i).amount_to_pay;
     l_payment_amount := l_amount;

     --
     -- Get next invoice_payment_id
     --
     l_debug_info := 'Get next invoice_payment_id';

     SELECT ap_invoice_payments_s.nextval
     INTO   l_invoice_payment_id
     FROM   sys.dual;

    l_debug_info := 'Create invoice payment for invoice_id:' ||
        to_char(P_Invoice_Payment_Info_Tab(i).invoice_id) || ' payment_num:' ||
        to_char(P_Invoice_Payment_Info_Tab(i).Payment_Schedule_num);

      --Bug# 8305713: Passing P_Invoice_Payment_Info_Tab(i).Discount_Taken
      AP_PAY_INVOICE_PKG.AP_PAY_INVOICE(
          P_invoice_id              =>    P_Invoice_Payment_Info_Tab(i).invoice_id,
          P_check_id                =>    P_check_id,
          P_payment_num             =>    P_Invoice_Payment_Info_Tab(i).Payment_Schedule_num,
          P_invoice_payment_id      =>    l_invoice_payment_id,
          P_old_invoice_payment_id  =>    NULL,
          P_period_name             =>    P_period_name,
          P_invoice_type            =>    l_invoice_type,
          P_accounting_date         =>    P_check_date,
          P_amount                  =>    l_amount,
          P_discount_taken          =>    P_Invoice_Payment_Info_Tab(i).Discount_Taken,
          P_discount_lost           =>    NULL,
          P_invoice_base_amount     =>    NULL,
          P_payment_base_amount     =>    NULL,
          P_accrual_posted_flag     =>    'N',
          P_cash_posted_flag        =>    'N',
          P_posted_flag             =>    'N',
          P_set_of_books_id         =>    P_set_of_books_id,
          P_last_updated_by         =>    P_last_updated_by,
          P_last_update_login       =>    P_last_update_login,
          P_currency_code           =>    P_currency_code,
          P_base_currency_code      =>    P_base_currency_code,
          P_exchange_rate           =>    P_exchange_rate,
          P_exchange_rate_type      =>    P_exchange_rate_type,
          P_exchange_date           =>    P_exchange_date,
          P_ce_bank_acct_use_id     =>    P_ce_bank_acct_use_id,
          P_bank_account_num        =>    P_bank_account_num,
          P_bank_account_type       =>    P_bank_account_type,
          P_bank_num                =>    P_bank_num,
          P_future_pay_posted_flag  =>    l_future_pay_posted_flag,
          P_exclusive_payment_flag  =>    l_exclusive_payment_flag,
          P_accts_pay_ccid          =>    l_accts_pay_ccid,
          P_gain_ccid               =>    NULL,
          P_loss_ccid               =>    NULL,
          P_future_pay_ccid         =>    NULL,
          P_asset_ccid              =>    NULL,
          P_payment_dists_flag      =>    'N',
          P_payment_mode            =>    'PAY',
          P_replace_flag            =>    'N',
          P_attribute1              =>    l_attribute1,
          P_attribute2              =>    l_attribute2,
          P_attribute3              =>    l_attribute3,
          P_attribute4              =>    l_attribute4,
          P_attribute5              =>    l_attribute5,
          P_attribute6              =>    l_attribute6,
          P_attribute7              =>    l_attribute7,
          P_attribute8              =>    l_attribute8,
          P_attribute9              =>    l_attribute9,
          P_attribute10             =>    l_attribute10,
          P_attribute11             =>    l_attribute11,
          P_attribute12             =>    l_attribute12,
          P_attribute13             =>    l_attribute13,
          P_attribute14             =>    l_attribute14,
          P_attribute15             =>    l_attribute15,
          P_attribute_category      =>    l_attribute_category,
          P_calling_sequence        =>    l_curr_calling_sequence,
          P_accounting_event_id     =>    P_accounting_event_id,
          P_org_id                  =>    P_org_id);

    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
    ' P_check_id = '                || P_check_id        ||
    ' P_payment_type_flag = '   || P_payment_type_flag     ||
    ' P_payment_method = '    || P_payment_method    ||
    ' P_bank_account_id = '   || P_ce_bank_acct_use_id   ||
    ' P_bank_account_num = '  || P_bank_account_num      ||
    ' P_bank_account_type = '   || P_bank_account_type     ||
    ' P_bank_num = '    || P_bank_num      ||
    ' P_check_date = '    || P_check_date      ||
    ' P_period_name = '     || P_period_name     ||
    ' P_currency_code = '     || P_currency_code       ||
    ' P_base_currency_code = '  || P_base_currency_code    ||
    ' P_checkrun_id = '     || P_checkrun_id     ||
    ' P_exchange_rate = '     || P_exchange_rate     ||
    ' P_exchange_rate_type = '  || P_exchange_rate_type    ||
    ' P_exchange_date = '     || P_exchange_date     ||
    ' P_set_of_books_id = '   || P_set_of_books_id     ||
    ' P_last_updated_by = '   || P_last_updated_by     ||
    ' P_last_update_login = '   || P_last_update_login
    );
  FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Create_Netting_Inv_Payment;


--===========================================================================
-- Get_Discount_For_Schedule: Function that returns the
--               discount amount available for given invoice id and date
-- Parameters:
--             P_Invoice_Id: Invoice on which discount should be calculated
--             P_Payment_Num: Payment number used to pay the invoice.
--             P_Date: Date on which discount needs to be calculated
-- Returns:    Discount Amount
--===========================================================================
FUNCTION Get_Disc_For_Pmt_Schedule(P_Invoice_Id      IN NUMBER,
                                   P_Payment_Num     IN NUMBER,
				   P_Date            IN DATE)
RETURN NUMBER IS

   CURSOR discount_amt_cursor(c_invoice_id NUMBER,c_payment_num number,c_date DATE) is
   SELECT
   DECODE(ai.invoice_type_lookup_code,'PAYMENT REQUEST',
         0,
         DECODE(PS.GROSS_AMOUNT,
               0, 0,
               DECODE(asi.ALWAYS_TAKE_DISC_FLAG,
                      'Y', NVL(PS.DISCOUNT_AMOUNT_AVAILABLE,0),
                      GREATEST(DECODE(SIGN(c_date
                                           - NVL(PS.DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                      1, 0,
                                      NVL(ABS(PS.DISCOUNT_AMOUNT_AVAILABLE),0)),
                               DECODE(SIGN(c_date
                                           - NVL(PS.SECOND_DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                       1, 0,
                                       NVL(ABS(PS.SECOND_DISC_AMT_AVAILABLE),0)),
                               DECODE(SIGN(c_date
                                           - NVL(PS.THIRD_DISCOUNT_DATE,
                                                 TO_DATE('01/01/1901',
                                                         'MM/DD/YYYY'))),
                                       1, 0,
                                       NVL(ABS(PS.THIRD_DISC_AMT_AVAILABLE),0)),
                                0)   * DECODE(SIGN(ps.gross_amount),-1,-1,1))
                      * (PS.AMOUNT_REMAINING / DECODE(PS.GROSS_AMOUNT,
                                                      0, 1,
                                                      PS.GROSS_AMOUNT))))
	 FROM ap_payment_schedules_all PS,
          ap_invoices_all ai,
          ap_supplier_sites_all asi
    WHERE ai.invoice_id = ps.invoice_id
      AND ai.vendor_id = asi.vendor_id
      AND ai.vendor_site_id = asi.vendor_site_id
      AND ai.invoice_id = c_invoice_id
	  AND ps.payment_num = c_payment_num;

   l_discount_amount ap_payment_schedules_all.discount_amount_available%type;
   Netting_Exception EXCEPTION;
   l_debug_info      FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   DBG_Loc           VARCHAR2(50)  := 'Get_Discount_For_Payment_Schedule';

BEGIN
   l_debug_info := 'Begin: Invoice id: '||P_Invoice_Id||' Payment Num: '||P_Payment_Num
                   || 'P_Date:' || P_Date;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;

    OPEN discount_amt_cursor(P_Invoice_Id,P_Payment_Num,P_Date);
   FETCH discount_amt_cursor INTO l_discount_amount;
   CLOSE discount_amt_cursor;

   l_debug_info := 'l_discount_amount: '||l_discount_amount;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;

   RETURN nvl(l_discount_amount,0);

EXCEPTION
   WHEN OTHERS THEN
   l_debug_info := 'Error: '||SQLCODE|| '-'||SQLERRM;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;
   RAISE Netting_Exception;
END Get_Disc_For_Pmt_Schedule;

--===========================================================================
-- Get_Disc_On_Netted_Amt: Function that returns the
--               discount amount taken on the netted amount
-- Parameters:
--             P_Invoice_Id: Invoice on which discount should be calculated
--             P_Payment_Num: Payment number used to pay the invoice.
--             P_Date: Date on which discount needs to be calculated
--             P_Netted_Amt: Nettend amount on  which discount taken should be calculated
-- Returns:    Discount Amount taken on netted amount

--Following will be the algorithm to be followed
--  a. Determine/Calculate Remaining amount, discount,
--     total netted amount for the given schedule.
--  b. From the step a values, determine discount for one unit of netted amount.
--  c. Calculate discount for the netted amount passed as input.
--===========================================================================

FUNCTION Get_Disc_For_Netted_Amt(P_Invoice_Id    IN NUMBER,
                                 P_Payment_Num   IN NUMBER,
                                 P_Date          IN DATE,
				 P_Netted_Amt    IN NUMBER)
RETURN NUMBER IS
   l_amount_remaining       ap_payment_schedules_all.amount_remaining%type;
   l_discount_amount        ap_payment_schedules_all.discount_amount_available%type;
   l_discount_on_netted_amt ap_payment_schedules_all.discount_amount_available%type;
   l_inv_curr               ap_invoices_all.invoice_currency_code%type;
   l_debug_info             FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   DBG_Loc                  VARCHAR2(50)  := 'Get_Discount_For_Netted_Amt';
   Netting_Exception        EXCEPTION;
BEGIN
   l_debug_info := 'Begin: Invoice id: '||P_Invoice_Id||' Payment Num: '||P_Payment_Num ;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;

   l_debug_info := 'P_Date '||P_Date||' P_Netted_Amt: '||P_Netted_Amt;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;

   --Get Amount Remaining to be paid for the given Invoice and Payment Number
   SELECT amount_remaining
     INTO l_amount_remaining
     FROM ap_payment_schedules_all
    WHERE invoice_id = P_Invoice_Id
      AND payment_num = P_Payment_Num;

   --Get the Discount Amount available on the payment
   l_discount_amount := AP_PAYMENT_PUBLIC_PKG.Get_Disc_For_Pmt_Schedule(P_Invoice_Id,P_Payment_Num,P_Date);

   --Get the Discount on Netted Amount
   l_discount_on_netted_amt := (l_discount_amount / (l_amount_remaining-l_discount_amount))*p_netted_amt;

   l_debug_info := 'Amount Remaining: '||l_amount_remaining || 'l_discount_amount:' ||l_discount_amount
                    || 'l_discount_on_netted_amt:'||l_discount_on_netted_amt;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;

   SELECT invoice_currency_code
     INTO l_inv_curr
     FROM ap_invoices_all
    WHERE invoice_id = P_Invoice_Id;

   l_discount_on_netted_amt := AP_UTILITIES_PKG.Ap_Round_Currency(l_discount_on_netted_amt,l_inv_curr);

   l_debug_info := 'After rounding: '||l_discount_on_netted_amt;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;


   RETURN nvl(l_discount_on_netted_amt,0);

EXCEPTION
   WHEN OTHERS THEN
   l_debug_info := 'Error: '||SQLCODE|| '-'||SQLERRM;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,l_debug_info);
   END IF;
   RAISE Netting_Exception;
END Get_Disc_For_Netted_Amt;


END AP_PAYMENT_PUBLIC_PKG;

/
