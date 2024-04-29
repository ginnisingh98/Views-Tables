--------------------------------------------------------
--  DDL for Package Body AP_AUTO_PAYMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AUTO_PAYMENT_PKG" AS
/* $Header: apautopb.pls 120.16.12010000.3 2009/07/28 10:54:19 mayyalas ship $ */

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_AUTO_PAYMENT_PKG.';

  --Bugfix 2124107 - Add one more parameter p_last_update_login

  PROCEDURE Replace_Check
    (P_Old_Check_Id         IN      NUMBER
    ,P_Replace_Check_Id     IN OUT NOCOPY  NUMBER
    ,P_Replace_Check_Date   IN  DATE
    ,P_Replace_Period_Name  IN      VARCHAR2
    ,P_Replace_Check_Num    IN  NUMBER
    ,P_Replace_Voucher_Num  IN  NUMBER
    ,P_Orig_Amount          IN  NUMBER
    ,P_Orig_payment_Date    IN  DATE
    ,P_Last_Updated_By      IN  NUMBER
    ,P_Future_Pay_Ccid  IN  NUMBER
    ,P_Quickcheck_Id        IN  VARCHAR2
    ,P_Calling_Sequence     IN  VARCHAR2
    ,P_Last_Update_Login    IN      NUMBER DEFAULT NULL
    ,P_Remit_to_supplier_name IN VARCHAR2 DEFAULT NULL -- Added for bug 8218410
    ,P_Remit_to_supplier_id   IN Number DEFAULT NULL
    ,P_Remit_To_Supplier_Site IN	VARCHAR2 DEFAULT NULL
    ,P_Remit_To_Supplier_Site_Id IN	NUMBER DEFAULT NULL
    ,P_Relationship_Id		IN	NUMBER DEFAULT NULL -- Bug 8218410 ends
    )

  IS
      -------------------------------------------------------------------
      -- Cursor to insert new invoice payments for replacement check
      --

      -- Bug#590200: The invoice and payment base amounts should get
      -- populated if either invoice or payment currency is different
      -- than the base currency. Since this has been implemented for
      -- creating the invoice payments, we can assume that the original
      -- check's invoice payments are correct. Therefore, all we need to do
      -- here is:
      --  If payment currency = base currency then
      --       copy from old invoice payment (will be NULL or populated
      --                                      based on invoice currency)
      --  else  calculate using exchange rate for new check.

      CURSOR c_new_payments IS
      SELECT ap_invoice_payments_s.nextval  new_invoice_payment_id
      ,      AIP.invoice_id     invoice_id
      ,      AIP.payment_num      payment_num
      ,      NVL(AIP.amount,0)      amount
      ,      AIP.set_of_books_id    set_of_books_id
      ,      AIP.accts_pay_code_combination_id  accts_pay_code_combination_id
      ,      NVL(AIP.discount_taken,0)    discount_taken
      ,     NVL(AIP.discount_lost,0)    discount_lost
      ,      AC.exchange_rate_type    exchange_rate_type
      ,      AC.exchange_rate     exchange_rate
      ,      AIP.invoice_base_amount    invoice_base_amount
      ,      AP_UTILITIES_PKG.AP_ROUND_CURRENCY(
      decode(AC.currency_code, ASP.base_currency_code,
                          AIP.payment_base_amount,
                          (AIP.amount * AC.exchange_rate)),
      ASP.base_currency_code)     payment_base_amount
      ,      AIP.gain_code_combination_id gain_code_combination_id
      ,      AIP.loss_code_combination_id loss_code_combination_id
--Bug 2631799 Added Attributes for Payments Information and Invoices DFF
      ,      ASP.awt_include_discount_amt awt_include_discount_amt --bug 3309344
      ,      AC.attribute1
      ,      AC.attribute2
      ,      AC.attribute3
      ,      AC.attribute4
      ,      AC.attribute5
      ,      AC.attribute6
      ,      AC.attribute7
      ,      AC.attribute8
      ,      AC.attribute9
      ,      AC.attribute10
      ,      AC.attribute11
      ,      AC.attribute12
      ,      AC.attribute13
      ,      AC.attribute14
      ,      AC.attribute15
      ,      AC.attribute_category
      ,      AC.global_attribute1
      ,      AC.global_attribute2
      ,      AC.global_attribute3
      ,      AC.global_attribute4
      ,      AC.global_attribute5
      ,      AC.global_attribute6
      ,      AC.global_attribute7
      ,      AC.global_attribute8
      ,      AC.global_attribute9
      ,      AC.global_attribute10
      ,      AC.global_attribute11
      ,      AC.global_attribute12
      ,      AC.global_attribute13
      ,      AC.global_attribute14
      ,      AC.global_attribute15
      ,      AC.global_attribute16
      ,      AC.global_attribute17
      ,      AC.global_attribute18
      ,      AC.global_attribute19
      ,      AC.global_attribute20
      ,      AC.global_attribute_category
      ,      AC.org_id  /* Bug 4759178. Added org_id */
      FROM   ap_checks            AC
      ,      ap_invoice_payments  AIP
      ,      ap_payment_schedules   APS
      ,      ap_system_parameters       ASP
      WHERE  AC.check_id  = P_Old_Check_Id
      AND    AIP.check_id   = AC.check_id
      AND    AIP.invoice_id   = APS.invoice_id
      AND    AIP.payment_num  = APS.payment_num
      AND    AIP.reversal_inv_pmt_id is NULL;

      rec_new_payments            c_new_payments%ROWTYPE;
      l_debug_info      VARCHAR2(240);
      l_curr_calling_sequence   VARCHAR2(2000);
      l_doc_sequence_name         fnd_document_sequences.name%TYPE;
      l_doc_sequence_id           ap_checks.doc_sequence_id%TYPE;
      l_doc_sequence_value        ap_checks.doc_sequence_value%TYPE;
      l_doc_category_code         ap_checks.doc_category_code%TYPE;
      l_set_of_books_id           ap_system_parameters.set_of_books_id%TYPE;
      l_awt_success     VARCHAR2(2000);
      l_awt_gross_amount    NUMBER;
      l_accounting_event_id       NUMBER; --Events Project 1
      l_prev_withheld_amt         NUMBER;   --bug3309344
      l_prev_amt_paid             NUMBER;   --bug3309344
      l_payment_type_flag         AP_CHECKS.payment_type_flag%TYPE; -- Bug3343314
      l_amount                    AP_CHECKS.amount%TYPE; -- Bug3343314
      l_currency_code             AP_CHECKS.currency_code%TYPE; -- Bug3343314
      l_exchange_rate_type        AP_CHECKS.exchange_rate_type%TYPE; -- Bug3343314
      l_exchange_date             AP_CHECKS.exchange_date%TYPE; -- Bug3343314
      l_exchange_rate             AP_CHECKS.exchange_rate%TYPE; -- Bug3343314
      l_base_amount               AP_CHECKS.exchange_rate%TYPE; -- Bug3343314
      l_creation_date             AP_CHECKS.creation_date%TYPE; -- Bug3343314
      l_created_by                AP_CHECKS.created_by%TYPE; -- Bug3343314
      l_last_update_date          AP_CHECKS.last_update_date%TYPE; -- Bug3343314
      l_last_updated_by           AP_CHECKS.last_updated_by%TYPE; -- Bug3343314
      l_last_update_login         AP_CHECKS.last_update_login%TYPE; -- Bug3343314
      l_org_id                    NUMBER;
      l_transaction_type          AP_PAYMENT_HISTORY_ALL.transaction_type%TYPE;

  BEGIN

      l_curr_calling_sequence := 'AP_AUTO_PAYMENT_PKG.REPLACE_CHECK<-'||
         P_Calling_Sequence;

     -- Added call to get new voucher number Bug #510855

      l_debug_info := 'Selecting Category Code and SOB';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


     -- Fix for bug 547662
     -- We need to handle exception when no_data_found
      BEGIN


      SELECT ac.doc_category_code, aip.set_of_books_id
      INTO   l_doc_category_code, l_set_of_books_id
      FROM   ap_checks ac, ap_invoice_payments aip
      WHERE  AC.check_id =  P_old_check_id
      AND    AC.check_id = AIP.check_id
      AND    AC.doc_sequence_value IS NOT NULL
      AND    rownum = 1;

      EXCEPTION WHEN NO_DATA_FOUND Then
         -- If doc_sequence_value is null
         -- we should handle the exception
         l_doc_category_code := null;
      END;



      IF l_doc_category_code IS NOT NULL THEN
         l_doc_sequence_value :=   FND_SEQNUM.GET_NEXT_SEQUENCE(
           APPID    =>'200',
           CAT_CODE => l_doc_category_code,
           SOBID    => l_set_of_books_id,
           MET_CODE => 'M',
                       TRX_DATE => SYSDATE,
                       DBSEQNM  => l_doc_sequence_name,
           DBSEQID  => l_doc_sequence_id );
      END IF;
      --
      -------------------------------------------------------------------
      l_debug_info := 'Get replace_check_id';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


      SELECT ap_checks_s.nextval
      INTO   P_Replace_Check_Id
      FROM   dual;

      -------------------------------------------------------------------
      l_debug_info := 'Insert into ap_checks for replace_check_id';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;

      /* Bug 4759178. Added Org_id */
      INSERT INTO AP_CHECKS
  (CHECK_ID, CE_BANK_ACCT_USE_ID, BANK_ACCOUNT_NAME,
         AMOUNT, CHECK_NUMBER, CHECK_DATE, CURRENCY_CODE,
         LAST_UPDATE_DATE, LAST_UPDATED_BY, VENDOR_ID, VENDOR_NAME,
         VENDOR_SITE_ID, VENDOR_SITE_CODE, EXCHANGE_RATE, EXCHANGE_DATE,
   EXCHANGE_RATE_TYPE, BASE_AMOUNT, CHECK_FORMAT_ID, CLEARED_DATE,
   CLEARED_AMOUNT, VOID_DATE, STATUS_LOOKUP_CODE, CHECK_STOCK_ID,
   CHECKRUN_NAME, ADDRESS_LINE1, ADDRESS_LINE2, ADDRESS_LINE3,
   ADDRESS_LINE4, COUNTY, CITY, STATE, ZIP, PROVINCE, COUNTRY,
         WITHHOLDING_STATUS_LOOKUP_CODE, PAYMENT_TYPE_FLAG,
         CHECK_VOUCHER_NUM, PAYMENT_METHOD_CODE, --4552701
         DOC_SEQUENCE_VALUE,DOC_CATEGORY_CODE,DOC_SEQUENCE_ID,
         CREATION_DATE, CREATED_BY,
--Bug2631799 Added Attributes
         ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,
         ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,
         ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,GLOBAL_ATTRIBUTE2,GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,GLOBAL_ATTRIBUTE5,GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,GLOBAL_ATTRIBUTE8,GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,GLOBAL_ATTRIBUTE11,GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,GLOBAL_ATTRIBUTE14,GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,GLOBAL_ATTRIBUTE17,GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,GLOBAL_ATTRIBUTE20,GLOBAL_ATTRIBUTE_CATEGORY, ORG_ID,
         BANK_CHARGE_BEARER, SETTLEMENT_PRIORITY, PAYMENT_PROFILE_ID, /* Bug 4759178 */
         PAYMENT_DOCUMENT_ID, PARTY_ID, PARTY_SITE_ID, LEGAL_ENTITY_ID,
	 REMIT_TO_SUPPLIER_NAME, --Added for bug 8218410
	 REMIT_TO_SUPPLIER_ID,
	 REMIT_TO_SUPPLIER_SITE,
	 REMIT_TO_SUPPLIER_SITE_ID,
	 RELATIONSHIP_ID) -- Bug 8218410 ends
      SELECT P_Replace_Check_Id, AC.ce_bank_acct_use_id, AC.bank_account_name,
             AC.amount, P_Replace_Check_Num, P_Replace_Check_Date,
             AC.currency_code, sysdate, P_Last_Updated_By, AC.vendor_id,
             AC.vendor_name, AC.vendor_site_id, AC.vendor_site_code,
       AC.exchange_rate, AC.exchange_date, AC.exchange_rate_type,
       AC.base_amount, AC.check_format_id, NULL, NULL, NULL,
             AC.status_lookup_code, AC.check_stock_id,
             substr(P_Quickcheck_Id,1,30-length(to_char(P_Replace_Check_Id)))||
             to_char(P_Replace_Check_Id),
       AC.address_line1, AC.address_line2, AC.address_line3,
       AC.address_line4, AC.county, AC.city, AC.state, AC.zip,
       AC.province, AC.country, AC.withholding_status_lookup_code, 'Q',
       P_Replace_Voucher_Num, AC.payment_method_code,
             l_doc_sequence_value, AC.doc_category_code, AC.doc_sequence_id,
       sysdate, P_Last_Updated_By,
--Bug 2631799 Added attributes
             AC.ATTRIBUTE1,AC.ATTRIBUTE2,AC.ATTRIBUTE3,AC.ATTRIBUTE4,
             AC.ATTRIBUTE5,AC.ATTRIBUTE6,AC.ATTRIBUTE7,AC.ATTRIBUTE8,
             AC.ATTRIBUTE9,AC.ATTRIBUTE10,AC.ATTRIBUTE11,AC.ATTRIBUTE12,
             AC.ATTRIBUTE13,AC.ATTRIBUTE14,AC.ATTRIBUTE15,
             AC.ATTRIBUTE_CATEGORY,
             AC.GLOBAL_ATTRIBUTE1,AC.GLOBAL_ATTRIBUTE2,AC.GLOBAL_ATTRIBUTE3,
             AC.GLOBAL_ATTRIBUTE4,AC.GLOBAL_ATTRIBUTE5,AC.GLOBAL_ATTRIBUTE6,
             AC.GLOBAL_ATTRIBUTE7,AC.GLOBAL_ATTRIBUTE8,AC.GLOBAL_ATTRIBUTE9,
             AC.GLOBAL_ATTRIBUTE10,AC.GLOBAL_ATTRIBUTE11,AC.GLOBAL_ATTRIBUTE12,
             AC.GLOBAL_ATTRIBUTE13,AC.GLOBAL_ATTRIBUTE14,AC.GLOBAL_ATTRIBUTE15,
             AC.GLOBAL_ATTRIBUTE16,AC.GLOBAL_ATTRIBUTE17,AC.GLOBAL_ATTRIBUTE18,
             AC.GLOBAL_ATTRIBUTE19,AC.GLOBAL_ATTRIBUTE20,
             AC.GLOBAL_ATTRIBUTE_CATEGORY, AC.ORG_ID,
             AC.bank_charge_bearer, AC.settlement_priority, AC.payment_profile_id,
             AC.payment_document_id, AC.party_id, AC.party_site_id, AC.legal_entity_id,
	     AC.REMIT_TO_SUPPLIER_NAME,AC.REMIT_TO_SUPPLIER_ID,AC.REMIT_TO_SUPPLIER_SITE, --Added for bug 8218410
	     AC.REMIT_TO_SUPPLIER_SITE_ID,AC.RELATIONSHIP_ID -- bug 8218410 ends
      FROM   ap_checks AC
      WHERE  AC.check_id = P_old_check_id;

    -- Bug3343314
    SELECT payment_type_flag,
           amount,
           currency_code,
           exchange_rate_type,
           exchange_date,
           exchange_rate,
           base_amount,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           org_id
    INTO   l_payment_type_flag,
           l_amount,
           l_currency_code,
           l_exchange_rate_type,
           l_exchange_date,
           l_exchange_rate,
           l_base_amount,
           l_creation_date,
           l_created_by,
           l_last_update_date,
           l_last_updated_by,
           l_last_update_login,
           l_org_id
    FROM   ap_checks
    WHERE  check_id = p_replace_check_id;

    AP_ACCOUNTING_EVENTS_PKG.create_events
    (
      p_event_type          => 'PAYMENT',
      p_doc_type            => l_payment_type_flag, -- Bug3343314
      p_doc_id              => p_replace_check_id,
      p_accounting_date     => p_replace_check_date,
      p_accounting_event_id => l_accounting_event_id, -- OUT
      p_checkrun_name       => NULL,
      p_calling_sequence    => l_curr_calling_sequence
    );

    IF ( l_payment_type_flag = 'R' ) THEN
      l_transaction_type := 'REFUND RECORDED';
    ELSE
      l_transaction_type := 'PAYMENT CREATED';
    END IF;

    -- Bug3343314
     AP_RECONCILIATION_PKG.insert_payment_history
     (
      x_check_id                => p_replace_check_id,
      x_transaction_type        => l_transaction_type,
      x_accounting_date         => p_replace_check_date,
      x_trx_bank_amount         => NULL,
      x_errors_bank_amount      => NULL,
      x_charges_bank_amount     => NULL,
      x_bank_currency_code      => NULL,
      x_bank_to_base_xrate_type => NULL,
      x_bank_to_base_xrate_date => NULL,
      x_bank_to_base_xrate      => NULL,
      x_trx_pmt_amount          => l_amount,
      x_errors_pmt_amount       => NULL,
      x_charges_pmt_amount      => NULL,
      x_pmt_currency_code       => l_currency_code,
      x_pmt_to_base_xrate_type  => l_exchange_rate_type,
      x_pmt_to_base_xrate_date  => l_exchange_date,
      x_pmt_to_base_xrate       => l_exchange_rate,
      x_trx_base_amount         => l_base_amount,
      x_errors_base_amount      => NULL,
      x_charges_base_amount     => NULL,
      x_matched_flag            => NULL,
      x_rev_pmt_hist_id         => NULL,
      x_org_id                  => l_org_id,
      x_creation_date           => l_creation_date,
      x_created_by              => l_created_by,
      x_last_update_date        => l_last_update_date,
      x_last_updated_by         => l_last_updated_by,
      x_last_update_login       => l_last_update_login,
      x_program_update_date     => NULL,
      x_program_application_id  => NULL,
      x_program_id              => NULL,
      x_request_id              => NULL,
      x_calling_sequence        => l_curr_calling_sequence,
      x_accounting_event_id     => l_accounting_event_id
      );

      -------------------------------------------------------------------
      l_debug_info := 'Update ap_check_stocks';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;

      UPDATE ap_check_stocks
      SET    last_document_num = P_Replace_Check_Num,
             last_update_date  = sysdate,
             last_updated_by   = P_Last_Updated_By
      WHERE  check_stock_id =
    (SELECT check_stock_id
     FROM   ap_checks
     WHERE  check_id = P_Replace_Check_Id);

      -------------------------------------------------------------------
      l_debug_info := 'Open c_new_payments cursor';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;

      OPEN c_new_payments;

      LOOP
          ---------------------------------------------------------------
    l_debug_info := 'Fetch from c_new_payments cursor';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;

          FETCH c_new_payments INTO rec_new_payments;
    EXIT WHEN c_new_payments%NOTFOUND;

    ---------------------------------------------------------------
    -- Bug 1492588 : Process Withholding
          --
    IF  OK_To_Call_Withholding (rec_new_payments.invoice_id)
    THEN

-- bug3309344 added the following 2 selects

-- BUG 4121323 : selecting payment_base_amount
            select sum(nvl(payment_base_amount,amount)+decode(rec_new_payments.awt_include_discount_amt,
                                                'Y',nvl(discount_taken,0),0))
            into   l_prev_amt_paid
            from   ap_invoice_payments aip
            where  aip.reversal_inv_pmt_id is null
            and    aip.invoice_id = rec_new_payments.invoice_id
            and    aip.check_id=    p_old_check_id;

    l_debug_info := 'l_prev_amt_paid -- '||to_char(l_prev_amt_paid);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


-- BUG 4121323 : selecting base_amount
            select sum(nvl(aid.base_amount,aid.amount))
            into   l_prev_withheld_amt
            from   ap_invoice_distributions aid
            where  aid.invoice_id=rec_new_payments.invoice_id
            and    aid.awt_invoice_payment_id
                           in (select invoice_payment_id
                           from   ap_invoice_payments aip
                           where  aip.check_id=p_old_check_id
                           and    aip.reversal_inv_pmt_id is null
                           and    aip.invoice_id=rec_new_payments.invoice_id);

    l_debug_info := 'l_prev_withheld_amt -- '||to_char(l_prev_withheld_amt);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


             l_awt_gross_amount:=l_prev_amt_paid-l_prev_withheld_amt;

    l_debug_info := 'l_awt_gross_amount -- '||to_char(l_awt_gross_amount);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


/* Bug 3309344 commenting this select statement
    SELECT  MAX(AID.awt_gross_amount)
    INTO  l_awt_gross_amount
    FROM  AP_INVOICE_PAYMENTS  AIP,
      AP_INVOICE_DISTRIBUTIONS AID
    WHERE AIP.invoice_id      =   rec_new_payments.invoice_id
    AND AIP.check_id      =   p_old_check_id
    AND AIP.reversal_inv_pmt_id     IS  NULL
    AND AID.awt_invoice_payment_id  =   AIP.invoice_payment_id;
*/
                -- Bugfix 2124107 - Pass p_last_update_login instead of null to procedure

    l_debug_info := 'calling AP_DO_WITHHOLDING';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;


    AP_WITHHOLDING_PKG.AP_Do_Withholding(
           P_Invoice_Id     =>  rec_new_payments.invoice_id ,
           P_AWT_Date       =>  P_Replace_Check_Date    ,
           P_Calling_Module   =>  'QUICKCHECK'      ,
           P_Amount     =>  l_awt_gross_amount    ,
           P_Payment_Num    =>  rec_new_payments.payment_num  ,
           P_Checkrun_Name    =>  null        ,
           P_Last_Updated_By  =>  p_last_updated_by   ,
           P_Last_Update_Login  =>  p_last_update_login             ,
        -- P_Last_Update_Login  =>  null                            ,
           P_Program_Application_id =>  null        ,
           P_Program_Id     =>  null        ,
           P_Request_Id     =>  null        ,
           P_Awt_Success    =>  l_awt_success     ,
           P_Invoice_Payment_Id   =>  rec_new_payments.new_invoice_payment_id,
	   P_Check_Id    =>  P_Replace_Check_Id);  --bug 8735998
    END IF;

          ---------------------------------------------------------------
          -- Create new invoice payment for replacement check
          --
          AP_PAY_INVOICE_PKG.AP_PAY_INVOICE
    (rec_new_payments.invoice_id
    ,P_Replace_Check_Id
    ,rec_new_payments.payment_num
    ,rec_new_payments.new_invoice_payment_id
    ,NULL
    ,P_Replace_Period_Name
    ,NULL
    ,P_Replace_Check_Date
    ,rec_new_payments.amount
    ,rec_new_payments.discount_taken
    ,rec_new_payments.discount_lost
    ,rec_new_payments.invoice_base_amount
    ,rec_new_payments.payment_base_amount
    ,'N'
    ,'N'
    ,'N'
    ,rec_new_payments.set_of_books_id
    ,P_Last_Updated_By
    ,NULL
    ,NULL
    ,NULL
    ,rec_new_payments.exchange_rate
    ,rec_new_payments.exchange_rate_type
    ,P_Replace_Check_Date
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,'N'
    ,NULL
    ,rec_new_payments.accts_pay_code_combination_id
    ,rec_new_payments.gain_code_combination_id
    ,rec_new_payments.loss_code_combination_id
    ,P_Future_Pay_Ccid
    ,NULL
    ,'N'
    ,'PAY'
    ,'Y'
--Bug 2631799 Added attributes for payment information and invoices DFF
    ,rec_new_payments.attribute1
    ,rec_new_payments.attribute2
    ,rec_new_payments.attribute3
    ,rec_new_payments.attribute4
    ,rec_new_payments.attribute5
    ,rec_new_payments.attribute6
    ,rec_new_payments.attribute7
    ,rec_new_payments.attribute8
    ,rec_new_payments.attribute9
    ,rec_new_payments.attribute10
    ,rec_new_payments.attribute11
    ,rec_new_payments.attribute12
    ,rec_new_payments.attribute13
    ,rec_new_payments.attribute14
    ,rec_new_payments.attribute15
    ,rec_new_payments.attribute_category
    ,rec_new_payments.global_attribute1
    ,rec_new_payments.global_attribute2
    ,rec_new_payments.global_attribute3
    ,rec_new_payments.global_attribute4
    ,rec_new_payments.global_attribute5
    ,rec_new_payments.global_attribute6
    ,rec_new_payments.global_attribute7
    ,rec_new_payments.global_attribute8
    ,rec_new_payments.global_attribute9
    ,rec_new_payments.global_attribute10
    ,rec_new_payments.global_attribute11
    ,rec_new_payments.global_attribute12
    ,rec_new_payments.global_attribute13
    ,rec_new_payments.global_attribute14
    ,rec_new_payments.global_attribute15
    ,rec_new_payments.global_attribute16
    ,rec_new_payments.global_attribute17
    ,rec_new_payments.global_attribute18
    ,rec_new_payments.global_attribute19
    ,rec_new_payments.global_attribute20
    ,rec_new_payments.global_attribute_category
    ,l_curr_calling_sequence
    ,l_accounting_event_id -- Events Project - 4
    ,rec_new_payments.org_id); /* Bug 4759178. Added org_id */
      END LOOP;

      -------------------------------------------------------------------
      l_debug_info := 'Close c_new_payments cursor';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||'AP_AUTO_PAYMENT_PKG',l_debug_info);
      END IF;

      CLOSE c_new_payments;

      -------------------------------------------------------------------

      -- Events Project 5 -----------------------------------------------
      --
      -- For the Payment Issue case, we will create new invoice payments
      -- for the new check (based upon existing invoice payments for the
      -- check that we are replacing).
      --
      -- The Interest Invoice Distributions are not re-created as we are not
      -- changing the invoices that the check pays. The Witholding
      -- distributions are recreated.
      --
      -- The parameter replace_check_flag in the call
      -- to AP_ACCOUNTING_EVENTS_PKG.Update_AWT_Int_Dists has been removed
      -- in the changes for the Events Project in Family Pack D.
      -- ----------------------------------------------------------------

        AP_ACCOUNTING_EVENTS_PKG.UPDATE_AWT_INT_DISTS
        (
          p_event_type => 'PAYMENT CREATED',
          p_check_id => p_replace_check_id,
          p_event_id => l_accounting_event_id,
          p_calling_sequence => l_curr_calling_sequence
        );

      -------------------------------------------------------------------

      -- Update old check amount if date changed
      --
      IF (P_Replace_Check_Date <> P_Orig_Payment_Date) THEN
          l_debug_info := 'Update check amount';

          UPDATE ap_checks
    SET    amount = P_orig_amount
    WHERE  check_id = P_Old_Check_Id;
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
      ' OLD_CHECK_ID = '        ||TO_CHAR(P_Old_Check_Id)
    ||', REPLACE_CHECK_DATE = '  ||TO_CHAR(P_Replace_Check_Date)
    ||', REPLACE_PERIOD_NAME = ' ||P_Replace_Period_Name
    ||', REPLACE_CHECK_NUM = '   ||TO_CHAR(P_Replace_Check_Num)
    ||', REPLACE_VOUCHER_NUM = ' ||TO_CHAR(P_Replace_Voucher_Num)
    ||', ORIG_AMOUNT = '         ||TO_CHAR(P_Orig_Amount)
    ||', ORIG_PAYMENT_DATE = '   ||TO_CHAR(P_Orig_Payment_Date)
    ||', LAST_UPDATED_BY = '     ||TO_CHAR(P_Last_Updated_By)
    ||', FUTURE_PAY_CCID = '     ||TO_CHAR(P_Future_Pay_Ccid));
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Replace_Check;

-- Bug 5061811 - removed  obsoleted procedure INSERT_TEMP_RECORDS
  --------------------------------------------------------------------------
  -- Insert the records needed for the FORMAT program to work based on
  -- P_check_id in the following tables:
  --
  --   AP_INVOICE_SELECTION_CRITERIA  AISC
  --   AP_SELECTED_INVOICE_CHECKS     ASIC
  --   AP_SELECTED_INVOICES           ASI
  --
  -- NOTE: Records in ASIC and ASI will be deleted by the FORMAT program
  --
  --PROCEDURE Insert_Temp_Records(P_check_id         IN NUMBER,
  --      P_calling_sequence IN VARCHAR2)
  --IS
  --    l_debug_info    VARCHAR2(240);
  --    l_curr_calling_sequence VARCHAR2(2000);
  -- BEGIN
  --  bug 5061811 - removed all code in procedure
  -- END Insert_Temp_Records;


  --------------------------------------------------------------------------
  -- Return 'Y' if record exists in AP_INVOICE_SELECTION_CRITERIA
  --
  FUNCTION Selection_Criteria_Exists(P_check_id IN NUMBER)
    RETURN VARCHAR2
  IS
    l_num_records NUMBER;
    l_exists_flag VARCHAR2(1);
  BEGIN

    SELECT count(*)
      INTO l_num_records
      FROM ap_inv_selection_criteria_all AISC,
           ap_checks_all AC
     WHERE AC.check_id = P_check_id
       AND AC.checkrun_name = AISC.checkrun_name;

    IF (l_num_records > 0) THEN
      l_exists_flag := 'Y';
    ELSE
      l_exists_flag := 'N';
    END IF;

    RETURN l_exists_flag;

  END Selection_Criteria_Exists;


  -----------------------------------------------------------------------
  -- Function get_check_stock_in_use_by returns the name of a payment batch
  -- that uses the check_stock and do not have a status of
  -- 'CONFIRMED', 'CANCELED',  or 'QUICKCHECK'.
  --
  FUNCTION Get_Check_Stock_In_Use_By(p_check_stock_id IN NUMBER)
    RETURN VARCHAR2 IS
    l_checkrun_name   ap_invoice_selection_criteria.checkrun_name%TYPE;
  BEGIN

    SELECT checkrun_name
    INTO   l_checkrun_name
    FROM   ap_invoice_selection_criteria
    WHERE  check_stock_id = p_check_stock_id
    AND    status NOT IN ('CONFIRMED', 'CANCELED', 'QUICKCHECK');

    return(l_checkrun_name);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN return(NULL);

  END Get_Check_Stock_In_Use_By;


  -----------------------------------------------------------------------
  -- Bug 1492588 :
  -- Function Ok_To_Call_Withholding returns True if there is withholding
  -- to recreate for an invoice, during check reissual
  --
  FUNCTION OK_To_Call_Withholding ( P_Invoice_Id   IN   NUMBER)
    RETURN BOOLEAN IS
    l_call_withholding  VARCHAR2(1);

  BEGIN

   SELECT  'Y'
   INTO    l_call_withholding
   FROM    ap_invoices AI
   WHERE   AI.invoice_id  =   p_invoice_id
   AND     EXISTS ( SELECT  'At least 1 AWT line created automatically at payment time'
        FROM  ap_invoice_distributions AID
        WHERE aid.invoice_id      =   ai.invoice_id
        AND   aid.awt_invoice_payment_id  is  not null);

  RETURN(TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN   RETURN(FALSE);

  END Ok_To_Call_Withholding;

END AP_AUTO_PAYMENT_PKG;

/
