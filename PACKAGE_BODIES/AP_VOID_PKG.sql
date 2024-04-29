--------------------------------------------------------
--  DDL for Package Body AP_VOID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_VOID_PKG" AS
/* $Header: apvoidpb.pls 120.36.12010000.5 2010/06/07 23:51:47 gagrawal ship $ */

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_VOID_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_VOID_PKG.';

 /* bug 5169128 */
  TYPE r_hold_info IS RECORD
    (invoice_id         AP_HOLDS_ALL.invoice_id%TYPE,
     org_id             AP_HOLDS_ALL.org_id%TYPE,
     hold_id            AP_HOLDS_ALL.hold_id%TYPE);

  TYPE hold_tab_type IS TABLE OF r_hold_info INDEX BY BINARY_INTEGER;

  PROCEDURE Ap_Reverse_Check(
          P_Check_Id                    IN         NUMBER,
          P_Replace_Flag                IN         VARCHAR2,
          P_Reversal_Date               IN         DATE,
          P_Reversal_Period_Name        IN         VARCHAR2,
          P_Checkrun_Name               IN         VARCHAR2,
          P_Invoice_Action              IN         VARCHAR2,
          P_Hold_Code                   IN         VARCHAR2,
          P_Hold_Reason                 IN         VARCHAR2,
          P_Sys_Auto_Calc_Int_Flag      IN         VARCHAR2,
          P_Vendor_Auto_Calc_Int_Flag   IN         VARCHAR2,
          P_Last_Updated_By             IN         NUMBER,
          P_Last_Update_Login           IN         NUMBER,
          P_Num_Cancelled               OUT NOCOPY NUMBER,
          P_Num_Not_Cancelled           OUT NOCOPY NUMBER,
          P_Calling_Module              IN         VARCHAR2 Default 'SQLAP',
          P_Calling_Sequence            IN         VARCHAR2,
          X_return_status               OUT NOCOPY VARCHAR2,
          X_msg_count                   OUT NOCOPY NUMBER,
          X_msg_data                    OUT NOCOPY VARCHAR2)
  IS
  -- Cursor to insert reversing invoice payments.  We swap gain and
  -- loss ccids.  This tricks posting into making the reversal to
  -- the gain/loss account used for the original payment.

  CURSOR c_new_payments IS
  SELECT AIP.invoice_payment_id         invoice_payment_id,
         ap_invoice_payments_s.nextval  new_invoice_payment_id,
         AIP.invoice_id                 invoice_id,
         AIP.payment_num                payment_num,
         AIP.check_id                   check_id,
         0-NVL(AIP.amount,0)            amount,
         AIP.set_of_books_id            set_of_books_id,
         DECODE(AIP.discount_taken
          ,'','',
          0-NVL(AIP.discount_taken,0))  discount_taken,
         DECODE(AIP.discount_lost
          ,'','',
          0-NVL(AIP.discount_lost,0))   discount_lost,
         AIP.exchange_rate_type         exchange_rate_type,
         AIP.exchange_rate              exchange_rate,
         AIP.exchange_date              exchange_date,
         DECODE(AIP.invoice_base_amount
          ,'','',0-NVL(AIP.invoice_base_amount,0))
                                        invoice_base_amount,
         DECODE(AIP.payment_base_amount
          ,'','',
          0-NVL(AIP.payment_base_amount,0))
                                        payment_base_amount,
         AIP.gain_code_combination_id           gain_code_combination_id,
         AIP.loss_code_combination_id           loss_code_combination_id,
         AIP.accts_pay_code_combination_id      accts_pay_code_combination_id,
         AIP.future_pay_code_combination_id     future_pay_code_combination_id,
         AI.vendor_id                           vendor_id,
         AIP.assets_addition_flag               assets_addition_flag,
         AIP.attribute1,
         AIP.attribute2,
         AIP.attribute3,
         AIP.attribute4,
         AIP.attribute5,
         AIP.attribute6,
         AIP.attribute7,
         AIP.attribute8,
         AIP.attribute9,
         AIP.attribute10,
         AIP.attribute11,
         AIP.attribute12,
         AIP.attribute13,
         AIP.attribute14,
         AIP.attribute15,
         AIP.attribute_category,
         AIP.global_attribute1,
         AIP.global_attribute2,
         AIP.global_attribute3,
         AIP.global_attribute4,
         AIP.global_attribute5,
         AIP.global_attribute6,
         AIP.global_attribute7,
         AIP.global_attribute8,
         AIP.global_attribute9,
         AIP.global_attribute10,
         AIP.global_attribute11,
         AIP.global_attribute12,
         AIP.global_attribute13,
         AIP.global_attribute14,
         AIP.global_attribute15,
         AIP.global_attribute16,
         AIP.global_attribute17,
         AIP.global_attribute18,
         AIP.global_attribute19,
         AIP.global_attribute20,
         AIP.global_attribute_category,
         AIP.org_id /* Bug 4759178, added org_id */
    FROM ap_invoice_payments AIP,
         ap_invoices AI
   WHERE AIP.check_id    = P_Check_Id
     AND AIP.invoice_id  = AI.invoice_id
     AND nvl(AIP.reversal_flag, 'N') <> 'Y';

  -------------------------------------------------------------------
  -- Cursor finds all invoices paid by P_Check_Id
  -------------------------------------------------------------------

  CURSOR  c_invoices IS
  SELECT  invoice_id
    FROM  ap_invoice_payments
   WHERE  check_id = P_Check_Id
     AND  nvl(reversal_flag, 'N') <> 'Y'
   GROUP BY invoice_id;

  -------------------------------------------------------------------
  -- Cursor finds all payment schedules paid by P_Check_Id
  -------------------------------------------------------------------

  CURSOR c_payment_schedules IS
  SELECT invoice_id,
         payment_num
   FROM  ap_invoice_payments
  WHERE  check_id = P_Check_Id
    AND  nvl(reversal_flag, 'N') <> 'Y'
  GROUP BY invoice_id, payment_num;


  CURSOR C_Interest_Inv_Cur IS
  SELECT aid.invoice_id                            invoice_id,
         aid.dist_code_combination_id              dist_code_combination_id,
         ap_invoice_distributions_s.NEXTVAL        invoice_distribution_id,
         aid.invoice_line_number                   invoice_line_number, /* bug 5169128 */
         aid.invoice_distribution_id               parent_reversal_id,     -- 2806074
         aid.set_of_books_id                       set_of_books_id,
         aid.amount * -1                           amount,
         aid.line_type_lookup_code                 line_type_lookup_code,
         aid.base_amount * -1                      base_amount,
         alc.displayed_field || ' '|| aid.description  description,
         DECODE(gl.account_type, 'A', 'Y', 'N')    assets_tracking_flag,
         aid.accts_pay_code_combination_id         accts_pay_code_combination_id,
      -- Bug 4277744 - Removed references to USSGL
      -- aid.ussgl_transaction_code                ussgl_transaction_code,
         aid.org_id                                org_id,
         aid.type_1099                             type_1099,
         aid.income_tax_region                     income_tax_region
    FROM ap_invoice_distributions aid,
         gl_code_combinations gl,
         ap_invoice_payments aip,
         ap_invoice_relationships air,
         ap_lookup_codes alc
   WHERE air.related_invoice_id       = aid.invoice_id
     AND gl.code_combination_id       = aid.dist_code_combination_id
     AND aid.invoice_id               = aip.invoice_id
     AND aip.check_id                 = P_Check_Id
     AND aip.amount                   > 0
     AND alc.lookup_type              = 'NLS TRANSLATION'
     AND alc.lookup_code              = 'VOID'
     AND NVL(aip.reversal_flag, 'N') <> 'Y';

  Interest_Inv_Cur              C_Interest_Inv_Cur%ROWTYPE;

  /* bug 5169128 */
  Cursor C_Hold_Cur IS
  SELECT DISTINCT AIP.invoice_id
      ,      AIP.org_id /* Bug 3700128. MOAC PRoject */
      FROM   ap_invoice_payments AIP
      WHERE  AIP.check_id = P_check_id
      AND    nvl(AIP.reversal_flag, 'N') <> 'Y'
      AND NOT EXISTS
    (SELECT 'Invoice already has this hold'
     FROM   ap_holds AH
     WHERE  AH.invoice_id = AIP.invoice_id
     AND    AH.hold_lookup_code = P_Hold_Code
     AND    AH.release_lookup_code IS NULL)
     AND NOT EXISTS (SELECT 'Invoice is an Interest Invoice' -- 3240962
                        FROM ap_invoices AI
                       WHERE AI.invoice_id = AIP.invoice_id
                         AND AI.invoice_type_lookup_code = 'INTEREST');

  -- bug9441420
  CURSOR Prepay_Appl IS
  SELECT DISTINCT aid.invoice_id
    FROM ap_invoice_payments_all aip,
         ap_invoice_distributions_all aid_prepay,
         ap_invoices_all ai_prepay,
	 ap_invoice_distributions_all aid
   WHERE aip.check_id = P_Check_ID
     AND aip.invoice_id = aid_prepay.invoice_id
     AND aid_prepay.invoice_id = ai_prepay.invoice_id
     AND ai_prepay.invoice_type_lookup_code = 'PREPAYMENT'
     AND aid_prepay.invoice_distribution_id = aid.prepay_distribution_id;


  l_hold_tab                    hold_tab_type;
  l_invoice_id_hold             NUMBER;
  l_org_id_hold                 NUMBER;
  i                             NUMBER;
  l_user_releaseable_flag       VARCHAR2(1);
  l_initiate_workflow_flag      VARCHAR2(1);
  /* bug 5169128 End */

  l_max_dist_line_num           NUMBER;

  l_set_of_books_id             NUMBER;
  l_invoice_id                  NUMBER;
  l_payment_num                 NUMBER;
  l_success                     VARCHAR2(240);
  INTERRUPT_VOID                EXCEPTION;
  l_debug_info                  VARCHAR2(240);
  l_curr_calling_sequence       VARCHAR2(2000);
  rec_new_payments              C_new_payments%ROWTYPE;
  l_invoice_distribution_id     NUMBER;

  l_key_value_list1             gl_ca_utility_pkg.r_key_value_arr;
  l_key_value_list2             gl_ca_utility_pkg.r_key_value_arr;

  l_accounting_event_id         NUMBER(38);
  l_unaccounted_row_count       NUMBER;
  l_old_accounting_event_id     NUMBER(38);
  l_postable_flag               VARCHAR2(1);

  l_payment_type_flag         ap_checks.payment_type_flag%TYPE; -- Bug3343314
  l_amount                    ap_checks.amount%TYPE; -- Bug3343314
  l_currency_code             ap_checks.currency_code%TYPE; -- Bug3343314
  l_exchange_rate_type        ap_checks.exchange_rate_type%TYPE; -- Bug3343314
  l_exchange_date             ap_checks.exchange_date%TYPE; -- Bug3343314
  l_exchange_rate             ap_checks.exchange_rate%TYPE; -- Bug3343314
  l_base_amount               ap_checks.base_amount%TYPE;   -- Bug3343314

  --Bug 2840203 DBI logging
  l_dbi_key_value_list1        ap_dbi_pkg.r_dbi_key_value_arr;
  l_dbi_key_value_list2        ap_dbi_pkg.r_dbi_key_value_arr;
  l_dbi_key_value_list3        ap_dbi_pkg.r_dbi_key_value_arr;

  l_payment_id                NUMBER;
  l_return_status             VARCHAR2(10);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_api_name                  CONSTANT VARCHAR2(30)   := 'Ap_Reversal_Check';
  l_error_count               NUMBER;
  l_error_msg                 VARCHAR2(2000);

  l_org_id                    NUMBER;

  l_netting_type              VARCHAR2(30);
  l_rev_pmt_hist_id           NUMBER; -- Bug 5015973
  l_transaction_type          AP_PAYMENT_HISTORY_ALL.transaction_type%TYPE;

  BEGIN

    l_curr_calling_sequence := 'AP_VOID_PKG.AP_REVERSE_CHECK<-'||
             P_Calling_Sequence;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_info := 'Get accounting method system options';

    l_debug_info := 'Get set of books id';

    SELECT  set_of_books_id
      INTO  l_set_of_books_id
      FROM  ap_invoice_payments
     WHERE  check_id = P_check_id
       AND  ROWNUM < 2;

    l_debug_info := 'Get Payment Type information';

    SELECT  payment_type_flag
    INTO    l_netting_type
    FROM    ap_checks
    WHERE   check_id = p_check_id;

    ---------------------------------------------------------------------
    -- Fix for bug 893626:
    -- Problem: After voiding a payment, the form field inv_curr_amount_paid
    -- was incorrectly showing the invoice amount instead of the amount paid
    -- for that invoice.
    -- Cause: The payment_status_flag in ap_invoices table was not being
    -- set to 'N' after voiding the payment for an invoice.
    -- Fix: By executing the ap_pay_update_payment_schedule procedure call
    -- before the ap_pay_update_ap_invoices, the payment_status_flag that was
    -- set in ap_payment_schedule is populated in ap_invoices.
    ---------------------------------------------------------------------

    l_debug_info := 'Open c_payment_schedules cursor';

    OPEN c_payment_schedules;

    LOOP

      l_debug_info := 'Fetch from c_payment_schedules cursor';

      FETCH c_payment_schedules INTO l_invoice_id, l_payment_num;
      EXIT WHEN c_payment_schedules%NOTFOUND;

      -----------------------------------------------------------------
      -- Update AP_PAYMENT_SCHEDULES paid by P_Check_Id
      -----------------------------------------------------------------

      AP_PAY_INVOICE_PKG.AP_PAY_UPDATE_PAYMENT_SCHEDULE(
          l_invoice_id,
          l_payment_num,
          P_Check_Id,
          NULL,
          NULL,
          'Y',
          'REV',
          P_Replace_Flag,
          P_Last_Updated_By,
          SYSDATE,
          l_curr_calling_sequence);
    END LOOP;

    l_debug_info := 'Close c_payment_schedules cursor';

    CLOSE c_payment_schedules;

    l_debug_info := 'Open c_invoices cursor';

    OPEN c_invoices;

    LOOP

      l_debug_info := 'Fetch from c_invoices cursor';

      FETCH c_invoices INTO l_invoice_id;
      EXIT WHEN c_invoices%NOTFOUND;

      -----------------------------------------------------------------
      -- Update AP_INVOICES paid by P_Check_Id
      -----------------------------------------------------------------

      AP_PAY_INVOICE_PKG.AP_PAY_UPDATE_AP_INVOICES (
          l_invoice_id,
          P_Check_Id,
          NULL,
          NULL,
          'Y',
          'REV',
          P_Replace_Flag,
          SYSDATE,
          P_Last_Updated_By,
          l_curr_calling_sequence);

    END LOOP;

    l_debug_info := 'Close c_invoices cursor';

    CLOSE c_invoices;

    -------------------------------------------------------------------
    -- Reverse the interest invoice for the selected invoice
    -- We should always reverse the interest invoices
    -- related to original invoice if we are not replacing
    -- the check i.e. we are voiding the check.
    -- Also we need to update the payment schedules for the interest invoice
    -------------------------------------------------------------------

    BEGIN

      IF  (P_replace_flag = 'N') AND (l_netting_type <> 'N') THEN

        l_debug_info := 'Update ap_payment_schedules';

        UPDATE ap_payment_schedules_all aps
           SET aps.last_updated_by = P_Last_Updated_By,
               aps.gross_amount = 0,
               aps.last_update_date = SYSDATE,
               aps.amount_remaining = 0
         WHERE aps.invoice_id IN (SELECT related_invoice_id
                                    FROM ap_invoice_relationships air,
                                         ap_invoice_payments_all aip
                                   WHERE aip.check_id = P_Check_Id
                                     AND air.related_invoice_id = aip.invoice_id
                                     AND nvl(aip.reversal_flag, 'N') <> 'Y')
      RETURNING aps.invoice_id
        BULK COLLECT INTO l_dbi_key_value_list2;

        IF (SQL%NOTFOUND) THEN
          RAISE INTERRUPT_VOID;
        END IF;

      --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value_list => l_dbi_key_value_list2,
                p_calling_sequence => l_curr_calling_sequence);

        l_debug_info := 'Update ap_invoices for Interest invoice';

        UPDATE ap_invoices_all AI
           SET AI.description                = 'VOID '||AI.description,
               AI.invoice_amount             = 0,
               AI.amount_paid                = 0,
               AI.invoice_distribution_total = 0,
               AI.cancelled_date             = sysdate,    --bug5631957
               AI.pay_curr_invoice_amount    = 0           --bug5631957
         WHERE AI.invoice_id IN
           (SELECT  AIR.related_invoice_id
              FROM  ap_invoice_relationships AIR,
                    ap_invoice_payments_all AIP
             WHERE  AIP.invoice_id               = AIR.related_invoice_id
               AND  AIP.check_id                 = P_Check_Id
             AND  NVL(aip.reversal_flag, 'N') <> 'Y')
         RETURNING invoice_id
         BULK COLLECT INTO l_dbi_key_value_list1;

        IF (SQL%NOTFOUND) THEN
          RAISE INTERRUPT_VOID;
        END IF;

        --Bug 4539462 DBI logging
        AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICES',
               p_operation => 'U',
               p_key_value_list => l_dbi_key_value_list1,
                p_calling_sequence => l_curr_calling_sequence);

        l_debug_info := 'Update ap_invoice_lines for Interest invoice';

        UPDATE ap_invoice_lines_all AIL
           SET AIL.description     = 'VOID '||AIL.description,
               AIL.amount          = 0,
               AIL.base_amount     = 0
         WHERE AIL.invoice_id IN
           (SELECT AIR.related_invoice_id
              FROM  ap_invoice_relationships AIR,
                    ap_invoice_payments_all AIP
             WHERE  AIP.invoice_id               = AIR.related_invoice_id
               AND  AIP.check_id                 = P_Check_Id
               AND  NVL(aip.reversal_flag, 'N') <> 'Y');

        l_debug_info := 'INSERT ap_invoice_distributions for Interest Invoice';

        SELECT   MAX(aid.distribution_line_number)
          INTO   l_max_dist_line_num
          FROM   ap_invoice_distributions aid,
                 gl_code_combinations gl,
                 ap_invoice_payments aip,
                 ap_invoice_relationships air,
                 ap_lookup_codes alc
         WHERE   air.related_invoice_id       = aid.invoice_id
           AND   gl.code_combination_id       = aid.dist_code_combination_id
           AND   aid.invoice_id               = aip.invoice_id
           AND   aip.check_id                 = P_Check_Id
           AND   aip.amount                   > 0
           AND   alc.lookup_type              = 'NLS TRANSLATION'
           AND   alc.lookup_code              = 'VOID'
           AND   NVL(aip.reversal_flag, 'N') <> 'Y';

      OPEN C_Interest_Inv_Cur;

        LOOP
          FETCH C_Interest_Inv_Cur INTO Interest_Inv_Cur;

          EXIT WHEN C_Interest_Inv_Cur%NOTFOUND;

          l_max_dist_line_num := l_max_dist_line_num + 1;


          INSERT INTO ap_invoice_distributions_all
                (INVOICE_ID,
                 DIST_CODE_COMBINATION_ID,
                 INVOICE_DISTRIBUTION_ID,
                 INVOICE_LINE_NUMBER, /* bug 5169128 */
                 LAST_UPDATED_BY,
                 ASSETS_ADDITION_FLAG,
                 ACCOUNTING_DATE,
                 PERIOD_NAME,
                 SET_OF_BOOKS_ID,
                 AMOUNT,
                 POSTED_FLAG,
                 CASH_POSTED_FLAG,
                 ACCRUAL_POSTED_FLAG,
                 MATCH_STATUS_FLAG,
                 DISTRIBUTION_LINE_NUMBER,
                 LINE_TYPE_LOOKUP_CODE,
                 BASE_AMOUNT,
                 LAST_UPDATE_DATE,
                 DESCRIPTION,
                 PA_ADDITION_FLAG,
                 CREATED_BY,
                 CREATION_DATE,
                 ASSETS_TRACKING_FLAG,
                 ACCTS_PAY_CODE_COMBINATION_ID,
              -- USSGL_TRANSACTION_CODE, - Bug 4277744
                 ORG_ID,
                 DIST_MATCH_TYPE,
                 DISTRIBUTION_CLASS,
                 AMOUNT_TO_POST,
                 BASE_AMOUNT_TO_POST,
                 POSTED_AMOUNT,
                 POSTED_BASE_AMOUNT,
                 UPGRADE_POSTED_AMT,
                 UPGRADE_BASE_POSTED_AMT,
                 ROUNDING_AMT,
                 ACCOUNTING_EVENT_ID,
                 ENCUMBERED_FLAG,
                 PACKET_ID,
              -- USSGL_TRX_CODE_CONTEXT, - Bug 4277744
                 REVERSAL_FLAG,
                 PARENT_REVERSAL_ID,
                 CANCELLATION_FLAG,
                 ASSET_BOOK_TYPE_CODE,
                 ASSET_CATEGORY_ID,
                 LAST_UPDATE_LOGIN,
		 --Freight and Special Charges
		 RCV_CHARGE_ADDITION_FLAG,
                 TYPE_1099,
                 INCOME_TAX_REGION)
          VALUES
                (Interest_Inv_Cur.invoice_id,
                 Interest_Inv_Cur.dist_code_combination_id,
                 Interest_Inv_Cur.invoice_distribution_id,
                 Interest_Inv_Cur.invoice_line_number,  /* bug 5169128 */
                 P_Last_Updated_By,
                 'U',
                 P_reversal_Date,
                 P_reversal_Period_Name,
                 Interest_Inv_Cur.set_of_books_id,
                 Interest_Inv_Cur.amount,
                 'N',
                 'N',
                 'N',
                 'A',
                 l_max_dist_line_num,
                 Interest_Inv_Cur.line_type_lookup_code,
                 Interest_Inv_Cur.base_amount,
                 SYSDATE,
                 Interest_Inv_Cur.description,
                 'E',
                 P_Last_Updated_By,
                 SYSDATE,
                 Interest_Inv_Cur.assets_tracking_flag,
                 Interest_Inv_Cur.accts_pay_code_combination_id,
              -- Interest_Inv_Cur.ussgl_transaction_code,  - Bug 4277744
                 Interest_Inv_Cur.org_id,
                 'MATCH_STATUS',
                 'PERMANENT',
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 NULL,
                 'N',
                 NULL,
              -- NULL,  - Bug 4277744
                 NULL,
                 Interest_Inv_Cur.parent_reversal_id,    --2806074
                 NULL,
                 NULL,
                 NULL,
                 P_last_update_login,
		 'N',
                 Interest_Inv_Cur.type_1099,
                 Interest_Inv_Cur.income_tax_region);

	     --Bug 4539462 DBI logging
       	     AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => Interest_Inv_Cur.invoice_id,
               p_key_value2 => Interest_Inv_Cur.invoice_distribution_id,
                p_calling_sequence => l_curr_calling_sequence);


        END LOOP;

      END IF;

    EXCEPTION
      WHEN INTERRUPT_VOID THEN
        l_debug_info := 'INTERRUPT_VOID';

    END;

    -- -----------------------------------------------------------------
    -- Events Project - 2 ----------------------------------------------
    -- Added select to help determine whether event should be created
    -- -----------------------------------------------------------------

    -- Bug3343314
    SELECT
      payment_type_flag,
      amount,
      currency_code,
      exchange_rate_type,
      exchange_date,
      exchange_rate,
      base_amount,
      org_id
    INTO
      l_payment_type_flag,
      l_amount,
      l_currency_code,
      l_exchange_rate_type,
      l_exchange_date,
      l_exchange_rate,
      l_base_amount,
      l_org_id
    FROM
      ap_checks
    WHERE
      check_id = p_check_id;

   --------------------------------------------------------------------
   l_debug_info := 'Unclear the payment if the payment type is netting';

   if l_netting_type = 'N' then --4945922

     AP_RECONCILIATION_PKG.Recon_Payment_History
          (NULL,
           P_Check_Id,
           P_Reversal_Date,
           P_Reversal_Date,
           l_amount,
           'PAYMENT UNCLEARING',
           NULL,
           NULL,
           l_currency_code,
           l_exchange_rate_type,
           l_exchange_date,
           l_exchange_rate,
           'N',
           NULL,
           SYSDATE,
           P_Last_Updated_By,
           P_Last_Update_Login,
           P_Last_Updated_By,
           SYSDATE,
           NULL,
           NULL,
           NULL,
           NULL,
           l_curr_calling_sequence);
   end if;

    -- Events Project - 4 -----------------------------------------------
    -- For the case where we reissue an unaccounted check that has a
    -- Payment Event, we do not want to create a Payment Cancellation Event.
    -- Instead, we will stamp the accounting_event_id of the Payment Event
    -- on the rows in AP_INVOICE_PAYMENTS pertaining to the Payment void.
    -- This will happen after the new rows are inserted into
    -- AP_INVOICE_PAYMENTS below.
    -- -----------------------------------------------------------

         BEGIN

           SELECT max(accounting_event_id)
           INTO l_old_accounting_event_id
           FROM AP_INVOICE_PAYMENTS AIP
           WHERE check_id = P_check_id
           AND posted_flag = 'N';

         EXCEPTION when no_data_found then
           l_old_accounting_event_id := NULL;
         END;
      -- Commenting for bug 8236138
      /*
       If ( P_Replace_flag <> 'Y') OR
         ( l_old_accounting_event_id IS NULL ) then*/
         -- Bug 4759178,  event is PAYMENT CANCELLATION
         AP_ACCOUNTING_EVENTS_PKG.Create_Events ('PAYMENT CANCELLATION'
                                                 ,l_payment_type_flag -- Bug3343314
                                                 ,P_check_id
                                                 ,P_Reversal_date
                                                 ,l_accounting_event_id
                                                 ,P_checkrun_name
                                                 ,l_curr_calling_sequence);

        IF ( l_payment_type_flag = 'R' ) THEN
          l_transaction_type := 'REFUND CANCELLED';
        ELSE
          l_transaction_type := 'PAYMENT CANCELLED';
        END IF;

        -- Bug 5015973. Getting the reversal payment history id
      -- Commented for Bug 6953346
	/*
	 SELECT MAX(Payment_History_ID)
        INTO   l_rev_pmt_hist_id
        FROM   AP_Payment_History APH
        WHERE  APH.Check_ID = P_Check_ID
        AND    APH.Transaction_Type = 'PAYMENT CREATED';
	*/

	-- Added for Bug 6953346

	IF(l_transaction_type = 'PAYMENT CANCELLED') THEN
	SELECT MAX(Payment_History_ID)
        INTO   l_rev_pmt_hist_id
        FROM   AP_Payment_History APH
        WHERE  APH.Check_ID = P_Check_ID
        AND    APH.Transaction_Type = 'PAYMENT CREATED';

	ELSE
	SELECT MAX(Payment_History_ID)
        INTO   l_rev_pmt_hist_id
        FROM   AP_Payment_History APH
        WHERE  APH.Check_ID = P_Check_ID
        AND    APH.Transaction_Type = 'REFUND RECORDED';

	END IF;

	-- End of Bug 6953346

        -- Bug3343314
        AP_RECONCILIATION_PKG.insert_payment_history
       (
          x_check_id                => p_check_id,
          x_transaction_type        => l_transaction_type,
          x_accounting_date         => p_reversal_date,
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
          x_rev_pmt_hist_id         => l_rev_pmt_hist_id,
          x_org_id                  => l_org_id,    -- 4578865
          x_creation_date           => SYSDATE,
          x_created_by              => p_last_updated_by,
          x_last_update_date        => SYSDATE,
          x_last_updated_by         => p_last_updated_by,
          x_last_update_login       => p_last_update_login,
          x_program_update_date     => NULL,
          x_program_application_id  => NULL,
          x_program_id              => NULL,
          x_request_id              => NULL,
          x_calling_sequence        => l_curr_calling_sequence,
          x_accounting_event_id     => l_accounting_event_id
        );
      -- Commenting for bug 8236138
      /*
      Else

        l_accounting_event_id := l_old_accounting_event_id;
      End If; */

    -- Events Project - end -------------------------------------------

    -------------------------------------------------------------------
    -- Hold invoices if necessary
    --
    IF (P_Invoice_Action = 'HOLD') THEN
      l_debug_info := 'Hold invoices';

      --Bug 4539462 collecting invoice_ids first
      SELECT DISTINCT AIP.invoice_id
      BULK COLLECT INTO l_dbi_key_value_list3
      FROM   ap_invoice_payments AIP
      WHERE  AIP.check_id = P_check_id
      AND    nvl(AIP.reversal_flag, 'N') <> 'Y'
      AND NOT EXISTS
                (SELECT 'Invoice already has this hold'
                 FROM   ap_holds AH
                 WHERE  AH.invoice_id = AIP.invoice_id
                 AND    AH.hold_lookup_code = P_Hold_Code
                 AND    AH.release_lookup_code IS NULL)
      AND NOT EXISTS (SELECT 'Invoice is an Interest Invoice'
                        FROM ap_invoices AI
                       WHERE AI.invoice_id = AIP.invoice_id
                         AND AI.invoice_type_lookup_code = 'INTEREST');

      /* Bug 5169128 */
      OPEN C_Hold_Cur;
      LOOP

        FETCH C_hold_Cur INTO l_invoice_id_hold,
                              l_org_id_hold;

        EXIT WHEN C_Hold_Cur%NOTFOUND;

        l_hold_tab(l_invoice_id_hold).invoice_id := l_invoice_id_hold;
        l_hold_tab(l_invoice_id_hold).org_id     := l_org_id_hold;
        Select AP_HOLDS_S.nextval
        INTO l_hold_tab(l_invoice_id_hold).hold_id
        From DUAL;

      END LOOP;
      CLOSE C_Hold_Cur;

      FOR i in nvl(l_hold_tab.FIRST, 0) .. nvl(l_hold_tab.LAST, 0) LOOP

      IF (l_hold_tab.exists(i)) THEN

        INSERT INTO ap_holds_all
        (invoice_id
        ,hold_lookup_code
        ,last_update_date
        ,last_updated_by
        ,held_by
        ,hold_date
        ,hold_reason
        ,created_by
        ,creation_date
	,org_id  /* Bug 3700128. MOAC Project */
        ,hold_id)
        Values
        (l_hold_tab(i).invoice_id
        ,P_Hold_Code
        ,sysdate
        ,P_Last_Updated_By
        ,P_Last_Updated_By
        ,sysdate
        ,P_Hold_Reason
        ,P_Last_Updated_By
        ,sysdate
        ,l_hold_tab(i).org_id /* Bug 3700128. MOAC PRoject */
        ,l_hold_tab(i).hold_id);

      END IF;

      END LOOP;

      /* bug 5169128 */
     --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_HOLDS',
               p_operation => 'I',
               p_key_value_list => l_dbi_key_value_list3,
                p_calling_sequence => l_curr_calling_sequence);


      -- Events Project - 5 -------------------------------------------------
      -- Added call to AP_ACCOUNTING_EVENTS_PKG.Update_Events_Status
      -- so that if a posting_hold is placed on an invoice during payment
      -- void, and the invoice has not been accounted, the status of the
      -- invoice related event will change from 'CREATED' to 'INCOMPLETE'.
      -- --------------------------------------------------------------------

      SELECT postable_flag,
           user_releaseable_flag,  /* bug 5143826 */
           initiate_workflow_flag
      INTO l_postable_flag,
         l_user_releaseable_flag,
         l_initiate_workflow_flag
      FROM AP_HOLD_CODES AHC
      WHERE AHC.hold_lookup_code = P_Hold_code;

      IF (nvl(l_postable_flag , 'N') = 'N') THEN

        AP_ACCOUNTING_EVENTS_PKG.UPDATE_PAYMENT_EVENTS_STATUS -- Bug3343314
        (
        p_check_id => p_check_id,
        p_calling_sequence => l_curr_calling_sequence -- Bug3343314
        );
      End if;

      /* bug 5143826 */
      IF (NVL(l_user_releaseable_flag, 'N') = 'Y' AND
          NVL(l_initiate_workflow_flag, 'N') = 'Y') THEN

        FOR i in nvl(l_hold_tab.FIRST, 0) .. nvl(l_hold_tab.LAST, 0) LOOP

          IF (l_hold_tab.exists(i)) THEN

            AP_WORKFLOW_PKG.create_hold_wf_process(l_hold_tab(i).hold_id);

          END IF;

        END LOOP;

      END IF;


    -------------------------------------------------------------------
    -- Or cancel invoices
    --
    -------------------------------------------------------------------
    -- Bug 8257752.
    -- Cancel invoice is now called after undo withholding.
    -------------------------------------------------------------------
    /*
    ELSIF (P_Invoice_Action = 'CANCEL') THEN

      -----------------------------------------------------------------
      l_debug_info := 'Commit changes before cancelling invoices';
     -- 1828366, commenting out NOCOPY the commit because if the form fails
     -- the record will still get commited.  Removing the commit
     -- below was not part of 1372660 (1828366 is a forward port of 1372660)
     -- COMMIT;

      AP_CANCEL_PKG.AP_CANCEL_INVOICES(P_Check_Id,
               P_Last_Updated_By,
               P_Last_Update_Login,
-- Base Line ARU
    --           l_set_of_books_id,
               P_Reversal_Date,
-- Base Line ARU
    --           P_Reversal_Period_Name,
               P_Num_Cancelled,
               P_Num_Not_Cancelled,
               l_curr_calling_sequence);
    */
    END IF;


    l_debug_info := 'Open c_new_payments cursor';

    -- -----------------------------------------------------------

    OPEN c_new_payments;

    LOOP
        -----------------------------------------------------------------
  l_debug_info := 'Fetch from c_new_payments cursor';

        FETCH c_new_payments INTO rec_new_payments;
  EXIT WHEN c_new_payments%NOTFOUND;

        -----------------------------------------------------------------
        -- Create reversing invoice payment
        --
        AP_PAY_INVOICE_PKG.AP_PAY_INVOICE
    (rec_new_payments.invoice_id
    ,P_Check_Id
    ,rec_new_payments.payment_num
    ,rec_new_payments.new_invoice_payment_id
    ,rec_new_payments.invoice_payment_id
    ,P_Reversal_Period_Name
    ,NULL
    ,P_Reversal_Date
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
    ,P_Last_Update_Login
    ,NULL
    ,NULL
    ,rec_new_payments.exchange_rate
    ,rec_new_payments.exchange_rate_type
    ,rec_new_payments.exchange_date
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,'N'
    ,NULL
    ,rec_new_payments.accts_pay_code_combination_id
    ,rec_new_payments.gain_code_combination_id
    ,rec_new_payments.loss_code_combination_id
    ,rec_new_payments.future_pay_code_combination_id
    ,NULL
    ,'Y'
    ,'REV'
    ,P_Replace_Flag
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
                ,l_accounting_event_id -- Events Project - 6
    ,rec_new_payments.org_id  /* Bug 4759178, passed org_id */
    );

               --Bug695340: Update the assets flag based on the old assets
               --           flag value.
               --           If the old was: U, N, or Y then set the new to U.
               --           Otherwise keep it as NULL.
               if rec_new_payments.assets_addition_flag is not null then
                    UPDATE ap_invoice_payments
                    SET    assets_addition_flag = 'U'
                    WHERE  invoice_payment_id =
                           rec_new_payments.new_invoice_payment_id;
               end if;

        -----------------------------------------------------------------
  -- Undo any withholding taken at payment time
        --

    IF l_netting_type <> 'N' THEN
        AP_WITHHOLDING_PKG.Ap_Undo_Withholding
           (rec_new_payments.invoice_payment_id
            ,'VOID PAYMENT'
            ,P_Reversal_Date
            ,rec_new_payments.new_invoice_payment_id
            ,P_Last_Updated_By
            ,P_Last_Update_Login
            ,NULL
            ,NULL
            ,NULL
           ,l_success
           );
    END IF;

    END LOOP;

    -- bug9441420, added the below code for marking
    -- any prepayment application and unapplication
    -- event reversal pair to N/U status
    --

    l_debug_info := 'Beginning to mark the Prepayment Application/Unapplication '||
                    'events to N/U status';
    OPEN prepay_appl;
    LOOP
      FETCH prepay_appl INTO l_invoice_id;
      EXIT WHEN prepay_appl%NOTFOUND;

      l_debug_info := 'before calling Set_Prepay_Event_Noaction api for invoice '||
                     ' id : '||l_invoice_id;

      AP_ACCOUNTING_EVENTS_PKG.Set_Prepay_Event_Noaction
            (p_invoice_id            => l_invoice_id,
             p_calling_sequence      => l_curr_calling_sequence);

    END LOOP;

    -------------------------------------------------------------------
    -- Bug 8257752.
    -- Cancel invoice is now called after undo withholding.
    -------------------------------------------------------------------

    IF (P_Invoice_Action = 'CANCEL') THEN

      -----------------------------------------------------------------
      l_debug_info := 'Commit changes before cancelling invoices';
      -- 1828366, commenting out NOCOPY the commit because if the form fails
      -- the record will still get commited.  Removing the commit
      -- below was not part of 1372660 (1828366 is a forward port of 1372660)
      -- COMMIT;

      AP_CANCEL_PKG.AP_CANCEL_INVOICES(P_Check_Id,
               P_Last_Updated_By,
               P_Last_Update_Login,
/* Base Line ARU */
    --           l_set_of_books_id,
               P_Reversal_Date,
/* Base Line ARU */
    --           P_Reversal_Period_Name,
               P_Num_Cancelled,
               P_Num_Not_Cancelled,
               l_curr_calling_sequence);
    END IF;

    -- Events Project - 7 ---------------------------------------------
    -- Now that interest invoices and AWT distributions have been
    -- created, we want to stamp the accounting_event_id of the Payment
    -- event on the AWT and interest invoice distributions.
    -- ----------------------------------------------------------------

    IF l_netting_type <> 'N' THEN
      AP_ACCOUNTING_EVENTS_PKG.UPDATE_AWT_INT_DISTS
      (
        p_event_type => 'PAYMENT CANCELLED',
        p_check_id => p_check_id,
        p_event_id => l_accounting_event_id,
        p_calling_sequence => l_curr_calling_sequence
      );
    END IF;

    ---------------------------------------------------------------------

    l_debug_info := 'Close c_new_payments cursor';

    CLOSE c_new_payments;

    -------------------------------------------------------------------
    -- Delete any temporary records in AP_SELECTED_INVOICES
    -- if this is a Quickcheck as the
    -- format program could have bombed and the user just decided
    -- to void it all
    --
    l_debug_info := 'Delete from ap_selected_invoices';

    IF l_netting_type <> 'N' THEN

      BEGIN

        DELETE FROM ap_selected_invoices
        WHERE checkrun_name = P_Checkrun_Name;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
      END;
    END IF;

    -----------------------------------------------------------------------
    -- In case the procedure has been called to Reverse a Netting Request
    -- then the check status should also be updated to 'VOIDED', and the
    -- Void Date should be populated as the sysdate
    -- This is not Required in the case of Quick Checks or Manual Checks as
    -- because the form takes care of populating these fields.
    -- bug6634891

    IF l_netting_type = 'N' THEN

          UPDATE ap_checks_all
	  SET status_lookup_code = 'VOIDED',
	      void_date = P_reversal_date
	  WHERE check_id = p_check_id;

   END IF;


    IF (p_calling_module <> 'IBY') AND (l_payment_type_flag NOT IN ('R','N'))
      THEN

      l_debug_info := 'Selecting the IBY payment id from ap_checks_all';

      BEGIN
        SELECT payment_id
        INTO   l_payment_id
        FROM   AP_CHECKS_ALL
        WHERE check_id = p_check_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
      END ;

      IF l_payment_id IS NOT NULL THEN

        l_debug_info := 'Calling IBY API to synchronize IBY Data';

        IBY_DISBURSE_UI_API_PUB_PKG.Void_Payment
        (p_api_version    =>    1.0,
         p_init_msg_list  =>    FND_API.G_FALSE,
         p_pmt_id         =>    l_payment_id,
         p_voided_by      =>    p_last_updated_by,
         p_void_date      =>    p_reversal_date,
         p_void_reason    =>    'Oracle Payables',
         x_return_status  =>    l_return_status,
         x_msg_count      =>    l_msg_count,
         x_msg_data       =>    l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FOR I IN 1..l_msg_count
          LOOP
            l_error_msg := FND_MSG_PUB.Get(p_msg_index => I
                                          ,p_encoded   => 'T');
            FND_MESSAGE.SET_ENCODED(l_error_msg);
          END LOOP;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

      END IF;

    END IF;
    -------------------------------------------------------------------
    --1372660/1828366 removing the commit because if the form fails, the
    --record will still get commited possibly.
    --l_debug_info := 'Commit changes to database';
    --COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        IF p_calling_module <> 'IBY' THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
      ', CHECK_ID = '          || TO_CHAR(P_Check_Id)
    ||', REPLACE_FLAG = '      || P_Replace_Flag
    ||', REVERSAL_DATE = '     || TO_CHAR(P_Reversal_Date)
    ||', PERIOD_NAME = '       || P_Reversal_Period_Name
    ||', CHECKRUN_NAME = '     || P_Checkrun_Name
    ||', INVOICE_ACTION = '    || P_Invoice_Action
    ||', HOLD_CODE = '     || P_Hold_Code
    ||', HOLD_REASON = '       || P_Hold_Reason
    ||', LAST_UPDATED_BY = '   || TO_CHAR(P_Last_Updated_By)
    ||', LAST_UPDATED_LOGIN = '|| TO_CHAR(P_Last_Update_Login));
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_Debug_Info);
        ELSE
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
            (p_count    =>      x_msg_count,
             p_data     =>      x_msg_data
            );
        END IF;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Ap_Reverse_Check;

  /* New procedure to be used by Oracle Payments
    during voiding of payments from their UI */

  PROCEDURE Iby_Void_Check
            (p_api_version                 IN  NUMBER,
             p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE,
             p_commit                      IN  VARCHAR2 := FND_API.G_FALSE,
             p_payment_id                  IN  NUMBER,
             p_void_date                   IN  DATE,
             x_return_status               OUT NOCOPY VARCHAR2,
             x_msg_count                   OUT NOCOPY VARCHAR2,
             x_msg_data                    OUT NOCOPY VARCHAR2)
  IS
    l_api_name                  CONSTANT VARCHAR2(30)   := 'Iby_Void_Check';
    l_api_version               CONSTANT NUMBER         := 1.0;

    l_return_status             VARCHAR2(10);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_user_id                   NUMBER;
    l_login_id                  NUMBER;
    l_reversal_date             DATE;
    l_reversal_period_name      VARCHAR2(240);
    l_num_cancelled             NUMBER;
    l_num_not_cancelled         NUMBER;
    l_gl_date                   DATE;
    l_check_id                  NUMBER;
    -- bug# 6643035 l_checkrun_name is changed to database column type
    l_checkrun_name             ap_checks_all.checkrun_name%type;
    l_org_id                    NUMBER;
    l_debug_info                VARCHAR2(2000);

  BEGIN

    l_debug_info := 'Checking API Compatibility';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FND_MSG_PUB.initialize;

    l_debug_info := 'Payment_id from IBY API: '||p_payment_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    l_user_id       := FND_GLOBAL.USER_ID;
    l_login_id      := FND_GLOBAL.LOGIN_ID;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_debug_info := 'Deriving check_id, org_id';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    BEGIN
      SELECT check_id,
             checkrun_id,
             org_id
      INTO   l_check_id,
             l_checkrun_name,
             l_org_id
      FROM   AP_CHECKS_ALL
      WHERE  payment_id = p_payment_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_check_id := NULL;
        l_checkrun_name := NULL;
        l_org_id := NULL;
    END;

    l_debug_info := 'Derived Check_Id: '||l_check_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF l_org_id IS NOT NULL THEN
      AP_UTILITIES_PKG.Get_Only_Open_Gl_Date
       (p_date     =>  p_void_date,
        p_period_name => l_reversal_period_name,
        p_gl_date  =>  l_gl_date,
        p_org_id   =>  l_org_id);
    END IF;

    l_debug_info := 'l_reversal_period_name: '||l_reversal_period_name;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF l_reversal_period_name IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.Set_Name('SQLAP','AP_NO_OPEN_PERIOD');
      FND_MSG_PUB.Count_And_Get(
        p_count                 =>      x_msg_count,
        p_data                  =>      x_msg_data
        );
    ELSE
      IF l_gl_date > p_void_date THEN
        l_reversal_date := l_gl_date;
      ELSE
        l_reversal_date := p_void_date;
      END IF;

      l_debug_info := 'Calling Ap_Reverse_Check';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      Ap_Reverse_Check
       (p_check_id             => l_check_id,
        p_replace_flag         => 'N',
        p_reversal_date        => l_reversal_date,
        p_reversal_period_name => l_reversal_period_name,
        p_checkrun_name        => l_checkrun_name,
        p_invoice_action       => NULL,
        p_hold_code            => NULL,
        p_hold_reason          => NULL,
        P_Sys_Auto_Calc_Int_Flag => NULL,
        P_Vendor_Auto_Calc_Int_Flag => NULL,
        P_Last_Updated_By      => l_user_id,
        P_Last_Update_Login    => l_login_id,
        P_Num_Cancelled        => l_num_cancelled,
        P_Num_Not_Cancelled    => l_num_not_cancelled,
        P_Calling_Module       => 'IBY',
        P_Calling_Sequence     => 'AP_VOID_PKG.Iby_Void_Check',
        x_return_status        => x_return_status,
        X_msg_count            => X_msg_count,
        X_msg_data             => X_msg_data);

      l_debug_info := 'Return Status from Ap_Reverse_Check: '||x_return_status;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      /* Bug 5407058 */
      IF (x_return_status =  FND_API.G_RET_STS_SUCCESS) THEN
        UPDATE AP_CHECKS_ALL
        SET status_lookup_code = 'VOIDED'
           ,void_date = l_reversal_date
        WHERE check_id = l_check_id;
      END IF;

    END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
                        (       G_PKG_NAME,
                                l_api_name
                        );
      END IF;
      FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count,
                        p_data                  =>      x_msg_data
                );

  END Iby_Void_Check;

END AP_VOID_PKG;

/
