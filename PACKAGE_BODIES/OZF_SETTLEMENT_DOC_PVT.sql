--------------------------------------------------------
--  DDL for Package Body OZF_SETTLEMENT_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SETTLEMENT_DOC_PVT" AS
/* $Header: ozfvcsdb.pls 120.24.12010000.10 2010/03/20 13:49:09 kpatro ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_Settlement_Doc_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvcsdb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

TYPE g_payment_method_tbl IS TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;


g_writeoff_threshold    VARCHAR2(15):= FND_PROFILE.value('OZF_CLAIM_WRITE_OFF_THRESHOLD');

/*=======================================================================*
 | FUNCTION
 |    Is_Tax_Inclusive
 |
 | NOTES
 |
 | HISTORY
 |    3-Aug-2005     Sahana       R12: Tax Enhancements
 *=======================================================================*/
FUNCTION Is_Tax_Inclusive(p_claim_class IN VARCHAR2, p_claim_org_id IN NUMBER)
RETURN BOOLEAN IS

CURSOR csr_tax_incl_flag(cv_org_id IN NUMBER) IS
  SELECT claim_tax_incl_flag
   FROM  ozf_sys_parameters_all
  WHERE  org_id = cv_org_id;
l_tax_incl_flag   VARCHAR2(1);

BEGIN

  OPEN   csr_tax_incl_flag( p_claim_org_id);
  FETCH  csr_tax_incl_flag INTO l_tax_incl_flag;
  CLOSE  csr_tax_incl_flag;

  IF p_claim_class  IN ( 'CLAIM', 'CHARGE') AND NVL(l_tax_incl_flag,'F') = 'F'  THEN
       RETURN FALSE;
  ELSE
       RETURN TRUE;
  END IF;

END Is_Tax_Inclusive;


/*=======================================================================*
 | PROCEDURE
 |    Update_Payment_Detail
 |
 | NOTES
 |
 | HISTORY
 |    20-Apr-2005 Sahana  Bug4308188: Overloaded Procedure
 *=======================================================================*/
PROCEDURE Update_Payment_Detail(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
   ,p_payment_method         IN    VARCHAR2
   ,p_deduction_type         IN    VARCHAR2
   ,p_cash_receipt_id        IN    NUMBER
   ,p_customer_trx_id        IN    NUMBER
   ,p_adjust_id              IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,p_settlement_mode        IN    VARCHAR2
) IS
BEGIN

   Update_Payment_Detail(
            p_api_version            => p_api_version
           ,p_init_msg_list          => p_init_msg_list
           ,p_commit                 => p_commit
           ,p_validation_level       => p_validation_level
           ,x_return_status          => x_return_status
           ,x_msg_data               => x_msg_data
           ,x_msg_count              => x_msg_count
           ,p_claim_id               => p_claim_id
           ,p_payment_method         => p_payment_method
           ,p_deduction_type         => p_deduction_type
           ,p_cash_receipt_id        => p_cash_receipt_id
           ,p_customer_trx_id        => p_customer_trx_id
           ,p_adjust_id              => p_adjust_id
           ,p_settlement_doc_id      => p_settlement_doc_id
           ,p_settlement_mode        => p_settlement_mode
           ,p_settlement_amount      => NULL);

END Update_Payment_Detail;


/*=======================================================================*
 | PROCEDURE
 |    Update_Payment_Detail
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Update_Payment_Detail(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
   ,p_payment_method         IN    VARCHAR2
   ,p_deduction_type         IN    VARCHAR2
   ,p_cash_receipt_id        IN    NUMBER
   ,p_customer_trx_id        IN    NUMBER
   ,p_adjust_id              IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,p_settlement_mode        IN    VARCHAR2
   ,p_settlement_amount      IN    NUMBER --Bug4308188
)
IS
   l_api_version          CONSTANT NUMBER       := 1.0;
   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Payment_Detail';
   l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status                 VARCHAR2(1);

   l_settlement_doc_tbl            OZF_SETTLEMENT_DOC_PVT.settlement_doc_tbl_type;
   l_counter                       NUMBER       := 1;
   l_settlement_doc_id             NUMBER;
   l_claim_obj_ver_num             NUMBER;
   l_upd_claim_status              BOOLEAN      := FALSE;
   l_dummy_number                  NUMBER;

   -- Credit Memo/Debit Memo applied to the receipt
   CURSOR csr_receipt_apply( cv_cash_receipt_id  IN NUMBER
                         , cv_customer_trx_id  IN NUMBER ) IS
      SELECT pay.customer_trx_id
      ,      pay.cust_trx_type_id
      ,      pay.trx_number
      ,      rec.apply_date
      ,      rec.amount_applied
      ,      pay.status
      FROM ar_receivable_applications rec
      ,    ar_payment_schedules pay
      WHERE rec.cash_receipt_id = cv_cash_receipt_id
      AND rec.applied_payment_schedule_id = pay.payment_schedule_id
      AND pay.customer_trx_id = cv_customer_trx_id
      AND rec.display = 'Y';

   -- Invoice Credit
   CURSOR csr_invoice_credit( cv_customer_trx_id  IN NUMBER ) IS
      SELECT pay.customer_trx_id
      ,      pay.cust_trx_type_id
      ,      pay.trx_number
      ,      pay.trx_date --?? verify
      ,      pay.amount_applied
      ,      pay.status
      FROM ar_payment_schedules pay
      WHERE pay.customer_trx_id = cv_customer_trx_id;

   -- Chargeback
   CURSOR csr_chargeback(cv_customer_trx_id IN NUMBER) IS
     SELECT cust.customer_trx_id            --"settlement_id"
     ,      cust.cust_trx_type_id           --"settlement_type_id"
     ,      cust.trx_number                 --"settlement_number"
     ,      cust.trx_date                   --"settlement_date"
     ,      sum(cust_lines.extended_amount) --"settlement_amount"
     ,      pay.status                      --"status_code"
     FROM ra_customer_trx cust
     ,   ra_customer_trx_lines cust_lines
     ,   ar_payment_schedules pay
     WHERE cust.customer_trx_id = cv_customer_trx_id
     AND cust.customer_trx_id = pay.customer_trx_id
     AND cust.customer_trx_id = cust_lines.customer_trx_id
     AND pay.customer_trx_id = cust_lines.customer_trx_id  -- fix for bug 4897546
     AND cust.complete_flag = 'Y'
    GROUP BY cust.customer_trx_id
           , cust.cust_trx_type_id
           , cust.trx_number
           , cust.trx_date
           , pay.status;


   -- For Overpayment, settled by On Account Credit
   CURSOR csr_on_account_credit( cv_cash_receipt_id  IN NUMBER ) IS
      SELECT pay.customer_trx_id
      ,      pay.payment_schedule_id
      ,      pay.trx_number
      ,      rec.apply_date
      ,      rec.amount_applied
      ,      pay.status
      FROM ar_receivable_applications rec
      ,    ar_payment_schedules pay
      WHERE rec.cash_receipt_id = cv_cash_receipt_id
      AND rec.applied_payment_schedule_id = pay.payment_schedule_id
      AND pay.payment_schedule_id = -1
      AND rec.display='Y'
      ORDER BY rec.receivable_application_id desc;

   -- For Overpayment, settled by Write-Off
   CURSOR csr_receipt_writeoff( cv_cash_receipt_id  IN NUMBER ) IS
      SELECT pay.customer_trx_id
      ,      pay.payment_schedule_id
      ,      pay.trx_number
      ,      rec.apply_date
      ,      rec.amount_applied
      ,      pay.status
      FROM ar_receivable_applications rec
      ,    ar_payment_schedules pay
      WHERE rec.cash_receipt_id = cv_cash_receipt_id
      AND rec.applied_payment_schedule_id = pay.payment_schedule_id
      AND pay.payment_schedule_id = -3
      AND rec.display='Y'
      ORDER BY rec.receivable_application_id desc;

   -- For Invoice Deduction, settled by Write-Off
   CURSOR csr_invoice_writeoff(cv_adjust_id  IN NUMBER) IS
      SELECT adj.adjustment_id        --"settlement_id"
      , adj.receivables_trx_id        --"settlement_type_id"
      , adj.adjustment_number         --"settlement_number"
      , adj.apply_date                --"settlement_date"
      , adj.amount                    --"settlement_amount"
      , pay.status                    --"status_code"
      FROM ar_adjustments adj
      , ar_payment_schedules pay
      WHERE adj.payment_schedule_id = pay.payment_schedule_id
      AND adj.adjustment_id = cv_adjust_id;

   -- Find out claim object version number
   CURSOR csr_claim_obj_ver_num(cv_claim_id IN NUMBER) IS
      SELECT object_version_number
      FROM ozf_claims
      WHERE claim_id = cv_claim_id;

   -- Find out claim object version number
   CURSOR csr_claim_credit_memo(cv_claim_id IN NUMBER) IS
      SELECT pay.customer_trx_id
      ,      pay.cust_trx_type_id
      ,      pay.trx_number
      ,      sysdate
      ,      (oc.amount_settled * -1)
      ,      pay.status
      FROM ar_payment_schedules pay
      ,    ozf_claims oc
      WHERE pay.customer_trx_id = oc.payment_reference_id
      AND oc.claim_id = cv_claim_id;

   CURSOR csr_settle_doc_obj_ver(cv_settlement_doc_id IN NUMBER) IS
      SELECT object_version_number
      FROM ozf_settlement_docs_all
      WHERE settlement_doc_id = cv_settlement_doc_id;

--R12.1 Enhancement
  CURSOR csr_on_acct_only(cv_claim_id IN NUMBER) IS
      SELECT payment_method,
      amount
      FROM ozf_claims
      WHERE claim_id = cv_claim_id;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   -- ---------------
   -- REG_CREDIT_MEMO
   -- ---------------
   IF p_payment_method = 'REG_CREDIT_MEMO' THEN
      IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED', 'CLAIM') THEN
         IF p_customer_trx_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_invoice_credit');
            END IF;
            OPEN csr_invoice_credit(p_customer_trx_id);
            LOOP
               FETCH csr_invoice_credit INTO l_settlement_doc_tbl(l_counter).settlement_id
                                           , l_settlement_doc_tbl(l_counter).settlement_type_id
                                           , l_settlement_doc_tbl(l_counter).settlement_number
                                           , l_settlement_doc_tbl(l_counter).settlement_date
                                           , l_settlement_doc_tbl(l_counter).settlement_amount
                                           , l_settlement_doc_tbl(l_counter).status_code;
               EXIT WHEN csr_invoice_credit%NOTFOUND;
               l_settlement_doc_tbl(l_counter).claim_id := p_claim_id;
               l_settlement_doc_tbl(l_counter).payment_method := 'REG_CREDIT_MEMO';
               l_settlement_doc_tbl(l_counter).settlement_date := SYSDATE;
               l_counter := l_counter + 1;
            END LOOP;
            CLOSE csr_invoice_credit;
         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_customer_trx_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   -- ------------
   -- CREDIT_MEMO
   -- ------------
   ELSIF p_payment_method in ( 'CREDIT_MEMO', 'PREV_OPEN_CREDIT') THEN
      IF p_deduction_type = 'CLAIM' THEN
         OPEN csr_claim_credit_memo(p_claim_id);
         FETCH csr_claim_credit_memo INTO l_settlement_doc_tbl(1).settlement_id
                                        , l_settlement_doc_tbl(1).settlement_type_id
                                        , l_settlement_doc_tbl(1).settlement_number
                                        , l_settlement_doc_tbl(1).settlement_date
                                        , l_settlement_doc_tbl(1).settlement_amount
                                        , l_settlement_doc_tbl(1).status_code;
         CLOSE csr_claim_credit_memo;
         l_settlement_doc_tbl(1).claim_id := p_claim_id;
         l_settlement_doc_tbl(1).payment_method := 'CREDIT_MEMO';
         l_settlement_doc_tbl(1).settlement_date := SYSDATE;

      ELSIF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
         IF p_cash_receipt_id IS NOT NULL AND
            p_customer_trx_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_receipt_apply');
            END IF;
            OPEN csr_receipt_apply(p_cash_receipt_id, p_customer_trx_id);
            FETCH csr_receipt_apply INTO l_settlement_doc_tbl(1).settlement_id
                                     , l_settlement_doc_tbl(1).settlement_type_id
                                     , l_settlement_doc_tbl(1).settlement_number
                                     , l_settlement_doc_tbl(1).settlement_date
                                     , l_settlement_doc_tbl(1).settlement_amount
                                     , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_receipt_apply;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            l_settlement_doc_tbl(1).payment_method := 'CREDIT_MEMO';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_customer_trx_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      -- Bug4308188: For deductions/overpayments amount is passed to accomodate
      -- cases where CM is reapplied on the receipt.
      IF p_settlement_amount IS NOT NULL THEN
         l_settlement_doc_tbl(1).settlement_amount := p_settlement_amount ;
      END IF;

   -- ---------------
   -- ON_ACCT_CREDIT
   -- ---------------
   ELSIF p_payment_method = 'ON_ACCT_CREDIT' THEN
      IF p_deduction_type = 'RECEIPT_OPM' THEN
         IF p_cash_receipt_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_on_account_credit');
            END IF;
            OPEN csr_on_account_credit(p_cash_receipt_id);
            FETCH csr_on_account_credit INTO l_settlement_doc_tbl(1).settlement_id
                                           , l_settlement_doc_tbl(1).settlement_type_id
                                           , l_settlement_doc_tbl(1).settlement_number
                                           , l_settlement_doc_tbl(1).settlement_date
                                           , l_settlement_doc_tbl(1).settlement_amount
                                           , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_on_account_credit;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            l_settlement_doc_tbl(1).payment_method := 'ON_ACCT_CREDIT';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_customer_trx_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

--R12.1 Enhancement : For Accounting Only
 -- ---------------
   -- ACCOUNTING_ONLY
   -- ---------------
   ELSIF p_payment_method = 'ACCOUNTING_ONLY' THEN
      IF p_deduction_type = 'CLAIM' THEN
         IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_on_acct_only');
         END IF;
         OPEN csr_on_acct_only(p_claim_id);
            FETCH csr_on_acct_only INTO l_settlement_doc_tbl(1).payment_method
                                        ,l_settlement_doc_tbl(1).settlement_amount;
            CLOSE csr_on_acct_only;

            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            --l_settlement_doc_tbl(1).payment_method := 'ACCOUNTING_ONLY';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;
            l_settlement_doc_tbl(1).status_code := 'CLOSED';
            --l_settlement_doc_tbl(1).settlement_amount := 10; --Need to pass the claim amount

      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   -- ---------------
   -- CHARGEBACK
   -- ---------------
   ELSIF p_payment_method = 'CHARGEBACK' THEN
      IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
         IF p_customer_trx_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_chargeback');
            END IF;
            OPEN csr_chargeback(p_customer_trx_id);
            FETCH csr_chargeback INTO  l_settlement_doc_tbl(1).settlement_id
                                     , l_settlement_doc_tbl(1).settlement_type_id
                                     , l_settlement_doc_tbl(1).settlement_number
                                     , l_settlement_doc_tbl(1).settlement_date
                                     , l_settlement_doc_tbl(1).settlement_amount
                                     , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_chargeback;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            l_settlement_doc_tbl(1).payment_method := 'CHARGEBACK';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_customer_trx_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   -- ---------------
   -- WRITE_OFF
   -- ---------------
   ELSIF p_payment_method = 'WRITE_OFF' THEN
      IF p_deduction_type = 'SOURCE_DED' THEN
         IF p_adjust_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_invoice_writeoff');
            END IF;
            OPEN csr_invoice_writeoff(p_adjust_id);
            FETCH csr_invoice_writeoff INTO l_settlement_doc_tbl(1).settlement_id
                                          , l_settlement_doc_tbl(1).settlement_type_id
                                          , l_settlement_doc_tbl(1).settlement_number
                                          , l_settlement_doc_tbl(1).settlement_date
                                          , l_settlement_doc_tbl(1).settlement_amount
                                          , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_invoice_writeoff;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            --l_settlement_doc_tbl(1).payment_method := 'WRITE_OFF';
            l_settlement_doc_tbl(1).payment_method := 'ADJUSTMENT';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_adjust_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSIF p_deduction_type IN ('RECEIPT_OPM', 'RECEIPT_DED') THEN
         IF p_cash_receipt_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_receipt_writeoff');
            END IF;
            OPEN csr_receipt_writeoff(p_cash_receipt_id);
            FETCH csr_receipt_writeoff INTO l_settlement_doc_tbl(1).settlement_id
                                          , l_settlement_doc_tbl(1).settlement_type_id
                                          , l_settlement_doc_tbl(1).settlement_number
                                          , l_settlement_doc_tbl(1).settlement_date
                                          , l_settlement_doc_tbl(1).settlement_amount
                                          , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_receipt_writeoff;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            l_settlement_doc_tbl(1).payment_method := 'WRITE_OFF';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_adjust_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   -- ---------------
   -- DEBIT_MEMO
   -- ---------------
   ELSIF p_payment_method in ( 'DEBIT_MEMO', 'PREV_OPEN_DEBIT') THEN
      IF p_deduction_type = 'CHARGE' THEN
         OPEN csr_claim_credit_memo(p_claim_id);
         FETCH csr_claim_credit_memo INTO l_settlement_doc_tbl(1).settlement_id
                                        , l_settlement_doc_tbl(1).settlement_type_id
                                        , l_settlement_doc_tbl(1).settlement_number
                                        , l_settlement_doc_tbl(1).settlement_date
                                        , l_settlement_doc_tbl(1).settlement_amount
                                        , l_settlement_doc_tbl(1).status_code;
         CLOSE csr_claim_credit_memo;
         l_settlement_doc_tbl(1).claim_id := p_claim_id;
         l_settlement_doc_tbl(1).payment_method := 'DEBIT_MEMO';
         l_settlement_doc_tbl(1).settlement_date := SYSDATE;

      ELSIF p_deduction_type = 'RECEIPT_OPM' THEN
         IF p_cash_receipt_id IS NOT NULL AND
            p_customer_trx_id IS NOT NULL THEN
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message(l_full_name||': open cursor::csr_receipt_apply');
            END IF;
            OPEN csr_receipt_apply(p_cash_receipt_id, p_customer_trx_id);
            FETCH csr_receipt_apply INTO l_settlement_doc_tbl(1).settlement_id
                                     , l_settlement_doc_tbl(1).settlement_type_id
                                     , l_settlement_doc_tbl(1).settlement_number
                                     , l_settlement_doc_tbl(1).settlement_date
                                     , l_settlement_doc_tbl(1).settlement_amount
                                     , l_settlement_doc_tbl(1).status_code;
            CLOSE csr_receipt_apply;
            l_settlement_doc_tbl(1).claim_id := p_claim_id;
            l_settlement_doc_tbl(1).payment_method := 'DEBIT_MEMO';
            l_settlement_doc_tbl(1).settlement_date := SYSDATE;

         ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_ID_MISSING');
               FND_MESSAGE.set_token('ID', 'p_customer_trx_id');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_UPDPAY_DETL_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      -- Bug4308188: For deductions/overpayments amount is passed to accomodate
      -- cases where CM is reapplied on the receipt.
      IF p_settlement_amount IS NOT NULL THEN
         l_settlement_doc_tbl(1).settlement_amount := p_settlement_amount ;
      END IF;

   -- ---------------
   -- RECEIPT
   -- ---------------
   ELSIF p_payment_method = 'RECEIPT' THEN
      l_settlement_doc_tbl(1).settlement_type_id := -4;
      l_settlement_doc_tbl(1).settlement_date := SYSDATE;
      l_settlement_doc_tbl(1).claim_id := p_claim_id;
   END IF;

   IF l_settlement_doc_tbl.count > 0 THEN
      IF p_settlement_mode IS NULL THEN
         FOR j IN l_settlement_doc_tbl.FIRST..l_settlement_doc_tbl.LAST LOOP
           IF ((l_settlement_doc_tbl(j).settlement_id IS NOT NULL AND
              l_settlement_doc_tbl(j).settlement_id <> FND_API.G_miss_num)
              OR (l_settlement_doc_tbl(1).payment_method = 'ACCOUNTING_ONLY'))  THEN
               OZF_SETTLEMENT_DOC_PVT.Create_Settlement_Doc(
                     p_api_version_number => l_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     p_commit             => p_commit,
                     p_validation_level   => p_validation_level,
                     x_return_status      => l_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_settlement_doc_rec => l_settlement_doc_tbl(j),
                     x_settlement_doc_id  => l_settlement_doc_id
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
               -- should we check amount_settled equals to total of settle doc amount before closing claim?
               --l_upd_claim_status := TRUE;
            END IF;
         END LOOP;

      ELSIF p_settlement_mode = 'MASS_SETTLEMENT' THEN
         FOR j IN l_settlement_doc_tbl.FIRST..l_settlement_doc_tbl.LAST LOOP
            IF l_settlement_doc_tbl(j).settlement_id IS NOT NULL AND
              l_settlement_doc_tbl(j).settlement_id <> FND_API.G_miss_num THEN
              l_settlement_doc_tbl(j).settlement_doc_id := p_settlement_doc_id;
              OPEN csr_settle_doc_obj_ver(l_settlement_doc_tbl(j).settlement_doc_id);
              FETCH csr_settle_doc_obj_ver INTO l_settlement_doc_tbl(j).object_version_number;
              CLOSE csr_settle_doc_obj_ver;
              l_settlement_doc_tbl(j).payment_status := 'PAID';
               OZF_SETTLEMENT_DOC_PVT.Update_Settlement_Doc(
                     p_api_version_number => l_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     p_commit             => p_commit,
                     p_validation_level   => p_validation_level,
                     x_return_status      => l_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     p_settlement_doc_rec => l_settlement_doc_tbl(j),
                     x_object_version_number  => l_dummy_number
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
               -- should we check amount_settled equals to total of settle doc amount before closing claim?
               --l_upd_claim_status := TRUE;
            END IF;
         END LOOP;

      END IF;
   END IF; -- end if l_settlement_doc_tbl.count > 0

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Update_Payment_Detail;


/*=======================================================================*
 | PROCEDURE
 |    Update_Claim_Tax_Amount
 |
 | NOTES
 |
 | HISTORY
 |    16-MAY-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Update_Claim_Tax_Amount(
      p_claim_rec         IN  OZF_CLAIM_PVT.claim_rec_type
     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_data          OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
)
IS
   l_api_version          CONSTANT NUMBER       := 1.0;
   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Claim_Tax_Amount';
   l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status                 VARCHAR2(1);

   l_acctd_amount_settled          NUMBER;
   l_exchange_rate                 NUMBER;
   l_amount_remaining              NUMBER;
   l_acctd_amount_remaining        NUMBER;
   l_acctd_tax_amount              NUMBER;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

l_function_currency  VARCHAR2(15);

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------

   OPEN  csr_function_currency;
   FETCH csr_function_currency INTO l_function_currency;
   CLOSE csr_function_currency;

   IF l_function_currency = p_claim_rec.currency_code THEN
      l_acctd_amount_settled := p_claim_rec.amount_settled;
   ELSE
      OZF_UTILITY_PVT.Convert_Currency(
              P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
              P_FROM_CURRENCY   => p_claim_rec.currency_code,
              P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
              P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
              P_CONVERSION_RATE => p_claim_rec.exchange_rate,
              P_AMOUNT          => p_claim_rec.amount_settled,
              X_RETURN_STATUS   => l_return_status,
              X_ACC_AMOUNT      => l_acctd_amount_settled,
              X_RATE            => l_exchange_rate
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

    --Fix for Bug 7296882
    -- Bug 7478816 - Fix for split claim is not creating with correct amount
    -- psomyaju - 04/11/08 : Removed below condition (added for bug 7296882) as amount_remaining is not reflecting correctly
    --                       after claim split. This check is no more required as its already handled before calling this
    --                       API.
/*
    if (p_claim_rec.amount <> p_claim_rec.amount_settled AND p_claim_rec.amount_adjusted IS NOT NULL ) then
        l_amount_remaining := p_claim_rec.amount
                       - NVL(p_claim_rec.amount_adjusted, 0)
                       - p_claim_rec.amount_settled;

    else
        l_amount_remaining := p_claim_rec.amount
                       - NVL(p_claim_rec.amount_adjusted, 0)
                       - p_claim_rec.amount_settled
                       - NVL(p_claim_rec.tax_amount,0);
    end if;
*/

    l_amount_remaining := p_claim_rec.amount
                       - NVL(p_claim_rec.amount_adjusted, 0)
                       - p_claim_rec.amount_settled
                       - NVL(p_claim_rec.tax_amount,0);

   IF l_function_currency = p_claim_rec.currency_code THEN
      l_acctd_amount_remaining := l_amount_remaining;
   ELSE
      OZF_UTILITY_PVT.Convert_Currency(
              P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
              P_FROM_CURRENCY   => p_claim_rec.currency_code,
              P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
              P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
              P_CONVERSION_RATE => p_claim_rec.exchange_rate,
              P_AMOUNT          => l_amount_remaining,
              X_RETURN_STATUS   => l_return_status,
              X_ACC_AMOUNT      => l_acctd_amount_remaining,
              X_RATE            => l_exchange_rate
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Bug3805485: Tax Accounted Amount Calculation
   IF l_function_currency = p_claim_rec.currency_code THEN
      l_acctd_tax_amount := NVL(p_claim_rec.tax_amount,0);
   ELSE
      OZF_UTILITY_PVT.Convert_Currency(
              P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
              P_FROM_CURRENCY   => p_claim_rec.currency_code,
              P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
              P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
              P_CONVERSION_RATE => p_claim_rec.exchange_rate,
              P_AMOUNT          => NVL(p_claim_rec.tax_amount,0),
              X_RETURN_STATUS   => l_return_status,
              X_ACC_AMOUNT      => l_acctd_tax_amount,
              X_RATE            => l_exchange_rate
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('claim.amount_remaining = '||l_amount_remaining);
      OZF_Utility_PVT.debug_message('claim.acctd_amount_remaining = '||l_acctd_amount_remaining);
      OZF_Utility_PVT.debug_message('claim.amount_settled = '||p_claim_rec.amount_settled);
      OZF_Utility_PVT.debug_message('claim.acctd_amount_settled = '||l_acctd_amount_settled);
      OZF_Utility_PVT.debug_message('claim.amount_adjusted = '||p_claim_rec.amount_adjusted);
      OZF_Utility_PVT.debug_message('claim.tax_amount = '||p_claim_rec.tax_amount);
   END IF;

   BEGIN
       UPDATE ozf_claims_all
       SET tax_amount = NVL(p_claim_rec.tax_amount,0)
       ,   acctd_tax_amount = NVL(l_acctd_tax_amount,0)
       ,   amount_settled = p_claim_rec.amount_settled
       ,   acctd_amount_settled = l_acctd_amount_settled
       ,   amount_remaining = l_amount_remaining
       ,   acctd_amount_remaining = l_acctd_amount_remaining
       WHERE claim_id = p_claim_rec.claim_id;
   EXCEPTION
       WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_UPD_CLAM_ERR');
            FND_MSG_PUB.add;
         END IF;
         IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',sqlerrm);
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
   END;


   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Update_Claim_Tax_Amount;


/*=======================================================================*
 | PROCEDURE
 |    Update_Claim_Line_Status
 |
 | NOTES
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Update_Claim_Line_Status(
      p_claim_line_id     IN  NUMBER

     ,x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_data          OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
)
IS
   l_api_version          CONSTANT NUMBER       := 1.0;
   l_api_name             CONSTANT VARCHAR2(30) := 'Update_Claim_Line_Status';
   l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status                 VARCHAR2(1);

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   BEGIN
       UPDATE ozf_claim_lines_all
       SET payment_status = 'PAID'
       WHERE claim_line_id = p_claim_line_id;
   EXCEPTION
       WHEN OTHERS THEN
         IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',sqlerrm);
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
   END;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Update_Claim_Line_Status;


/*=======================================================================*
| PROCEDURE
|    process_cancelled_setl_doc
|
| NOTES
|
| HISTORY
|    07-Jul-2005 Sahana  R12: Handle cancellation of settlement document.
|                        Called from RMA and Creditmemo settlement.
*=======================================================================*/
PROCEDURE process_cancelled_setl_doc(
   p_claim_id           IN  NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_data          OUT NOCOPY   VARCHAR2
  ,x_msg_count         OUT NOCOPY   NUMBER

)  IS

l_api_name    CONSTANT VARCHAR2(30) := 'process_cancelled_setl_doc';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_notif_subject  VARCHAR2(400);
l_notif_body     VARCHAR2(4000);

l_notif_id     NUMBER;
l_note_id      NUMBER;
l_sys_date     DATE := SYSDATE;

l_claim_rec    OZF_CLAIM_PVT.claim_Rec_Type;

CURSOR csr_customer_name(cv_cust_account_id IN NUMBER) IS
  SELECT  party_name
    FROM  hz_parties party,
          hz_cust_accounts_all cust
   WHERE  party.party_id = cust.party_id
     AND  cust.cust_account_id = cv_cust_account_id;
l_customer_name  hz_parties.party_name%TYPE;

l_need_to_create   VARCHAR2(1);
l_claim_history_id  NUMBER;

BEGIN

x_return_status := FND_API.g_ret_sts_success;

IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': start');
END IF;

-- 1. Change Claim Status to Open.
-- Note: payment_reference_number is not set to null since this information is used to build
-- the next invoice number for check settlement. When the claim status is Open, the payment
-- information is not displayed.

 UPDATE ozf_claims
        SET status_code      = 'OPEN',
            user_status_id   = ozf_utility_pvt.get_default_user_status( 'OZF_CLAIM_STATUS', 'OPEN'),
            amount_remaining = NVL(amount_remaining,0) + amount_settled,
            acctd_amount_remaining = NVL(acctd_amount_remaining,0)+acctd_amount_settled,
            amount_settled   = 0,
            acctd_amount_settled = 0,
            payment_status   = null,
            payment_reference_id = DECODE(payment_method,'RMA',null,payment_reference_id),
            payment_reference_date = null,
            payment_reference_number = DECODE(payment_method,'RMA',null,payment_reference_number),
            last_updated_by = NVL(FND_GLOBAL.user_id,-1),
            last_update_login = NVL(FND_GLOBAL.conc_login_id,-1),
            last_update_date  = l_sys_date,
            settled_date      = null,
            settled_by        = null
     WHERE  claim_id = p_claim_id;

OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_id
        ,x_claim_rec       => l_claim_rec
        ,x_return_status   => x_return_status
);
IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
END IF;


 -- Make a call to maintain history
OZF_CLAIM_PVT.Create_Claim_History (
           p_api_version    => 1.0
          ,p_init_msg_list  => FND_API.G_FALSE
          ,p_commit         => FND_API.G_FALSE
          ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status  => x_return_status
          ,x_msg_data       => x_msg_data
          ,x_msg_count      => x_msg_count
          ,p_claim          => l_claim_rec
          ,p_event          =>  'UPDATE'
          ,x_need_to_create => l_need_to_create
          ,x_claim_history_id => l_claim_history_id
    );
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;


-- 2. Update the settlement document status if required.
-- This is because a check can be created and cancelled
-- before canceling the invoice document.
-- Fix for bug 4897546
 IF l_claim_rec.payment_method in ( 'CHECK','EFT','WIRE','AP_DEFAULT') THEN
        UPDATE ozf_settlement_docs_all stlmnt_docs
           SET   payment_status  = (SELECT  SUBSTRB(lkp.displayed_field,1,30)
                      FROM ap_lookup_codes lkp
                      where lkp.lookup_type = 'CHECK STATE'
                      and lkp.lookup_code IN (select status_lookup_code
                                      FROM  ap_invoice_payments pay, ap_checks chk
                                      WHERE pay.check_id = chk.check_id
                                     AND   pay.invoice_payment_id  = stlmnt_docs.settlement_id)),
                 last_updated_by   = NVL(FND_GLOBAL.user_id,-1),
                 last_update_login = NVL(FND_GLOBAL.conc_login_id,-1),
                 last_update_date  = l_sys_date
                 WHERE   claim_id = p_claim_id;
 END IF;

-- 3. Build message subject and message body.
-- Then send notification to claim owner and insert notes for the claim.
 OPEN  csr_customer_name(l_claim_rec.cust_account_id);
 FETCH csr_customer_name INTO l_customer_name;
 CLOSE csr_customer_name;

 fnd_message.set_name('OZF', 'OZF_NTF_STLMNTDOC_CANCEL_SUB');
 fnd_message.set_token('DOCUMENT_NUMBER', l_claim_rec.payment_reference_number);
 fnd_message.set_token('CLAIM_NUMBER', l_claim_rec.claim_number);
 l_notif_subject := substrb(fnd_message.get, 1, 400);

 fnd_message.set_name('OZF', 'OZF_NTF_STLMNTDOC_CANCEL_BODY');
 fnd_message.set_token ('DOCUMENT_NUMBER', l_claim_rec.payment_reference_number);
 fnd_message.set_token('CLAIM_NUMBER',l_claim_rec.claim_number);
 fnd_message.set_token('CUSTOMER_NAME',l_customer_name);
 fnd_message.set_token('SETTLEMENT_METHOD_NAME',l_claim_rec.payment_method);
 l_notif_body := substrb(fnd_message.get, 1, 4000);


 ozf_utility_pvt.send_wf_standalone_message(
            p_subject  =>  l_notif_subject
          , p_body     =>  l_notif_body
          , p_send_to_res_id  =>  l_claim_rec.owner_id
          , x_notif_id        =>  l_notif_id
          , x_return_status   =>  x_return_status  );
IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
END IF;

JTF_NOTES_PUB.create_note(
           p_api_version      => 1.0
          ,x_return_status    => x_return_status
          ,x_msg_count        => x_msg_count
          ,x_msg_data         => x_msg_data
          ,p_source_object_id => p_claim_id
          ,p_source_object_code => 'AMS_CLAM'
          ,p_notes              => l_notif_body
          ,p_note_status        => NULL
          ,p_entered_by         => FND_GLOBAL.user_id
          ,p_entered_date       => SYSDATE
          ,p_last_updated_by    => FND_GLOBAL.user_id
          ,x_jtf_note_id        => l_note_id
          ,p_note_type          => 'AMS_JUSTIFICATION'
          ,p_last_update_date   => l_sys_date
          ,p_creation_date      => l_sys_date);
IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
END IF;

-- 4. Reverse Accruals for payables settlement if required
--ER#9382547    ChRM-SLA Uptake
-- Calling the Reversal API to trigger the SLA reversal event
-- and populate the claim extract header table only.
/*OZF_GL_INTERFACE_PVT.Revert_Gl_Entry (
    p_api_version         =>  1.0
   ,p_init_msg_list       => FND_API.G_FALSE
   ,p_commit              => FND_API.G_FALSE
   ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
   ,x_return_status       => x_return_status
   ,x_msg_data            => x_msg_data
   ,x_msg_count           => x_msg_count
   ,p_claim_id            => l_claim_rec.claim_id );
   */

   OZF_GL_INTERFACE_PVT.Post_Claim_To_GL (
    p_api_version         => 1.0
   ,p_init_msg_list       =>FND_API.G_FALSE
   ,p_commit              => FND_API.G_FALSE
   ,p_validation_level    =>FND_API.G_VALID_LEVEL_FULL
   ,x_return_status       =>x_return_status
   ,x_msg_data            =>x_msg_data
   ,x_msg_count           =>x_msg_count
   ,p_claim_id           => l_claim_rec.claim_id
   ,p_settlement_method  => 'CLAIM_SETTLEMENT_REVERSAL'
    );
   IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
   END IF;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Claim Number : ' || l_claim_rec.claim_number);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Reopened. ');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': end');
END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END  process_cancelled_setl_doc;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_AP_Rec
--
-- HISTORY
--                pnerella  Create.
--    09/10/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Get_AP_Rec(
   p_claim_id             IN  NUMBER,
   p_settlement_amount       IN  NUMBER,
   x_settlement_doc_tbl   OUT NOCOPY settlement_doc_tbl_type,
   x_invoice_amount       OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS

l_api_name             CONSTANT VARCHAR2(30) := 'Get_AP_Rec';
l_full_name            CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

CURSOR csr_get_claim_details(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_inv_settlement( cv_claim_id IN VARCHAR2)IS
  SELECT --pay.invoice_payment_id     --"settlement_id"
    chk.check_id                    --"settlement_id"
  , chk.payment_method_code         --"settlement_type"
  , chk.check_id                    --"settlement_type_id"
  , chk.check_number                --"settlement_number"
  , chk.check_date                  --"settlement_date"
  , sum(pay.amount)                      --"settlement_amount"
  , chk.status_lookup_code          --"status_code"
  , oc.payment_method               -- "payment_method"
  , sum(NVL(pay.discount_taken,0))
  , inv.invoice_amount
  FROM ap_invoice_payments_all pay
  ,    ap_checks_all chk
  ,    ap_invoices_all inv
  ,    ozf_claims_all  oc
  WHERE pay.check_id =  chk.check_id
  AND inv.invoice_id =  pay.invoice_id
  AND oc.claim_id     = cv_claim_id
  AND oc.payment_reference_number = inv.invoice_num
  AND oc.vendor_id    = inv.vendor_id
  AND oc.vendor_site_id = inv.vendor_site_id
  GROUP BY chk.check_id , chk.payment_method_code , chk.check_number
  , chk.check_date, chk.status_lookup_code, oc.payment_method, inv.invoice_amount
  ORDER BY chk.check_id;

  -- Fix for Bug 4897546
CURSOR csr_debit_settlement( cv_claim_id IN VARCHAR2)  IS
  SELECT inv.invoice_id     --"settlement_id"
  , inv.invoice_type_lookup_code  --"settlement_type"
  , null                            --"settlement_type_id"
  , inv.invoice_num                  --"settlement_number"
  , inv.invoice_date                --"settlement_date"
  , inv.invoice_amount               --"settlement_amount"
  , AP_INVOICES_PKG.GET_APPROVAL_STATUS( INV.INVOICE_ID, INV.INVOICE_AMOUNT, INV.PAYMENT_STATUS_FLAG, INV.INVOICE_TYPE_LOOKUP_CODE) --"status_code"
  , 'AP_DEBIT'                      --"payment_method"
  , NULL
  , inv.invoice_amount
  FROM ap_invoices_all inv
  ,    ozf_claims_all oc
  WHERE oc.claim_id     = cv_claim_id
  AND   oc.payment_reference_number = inv.invoice_num
  AND   oc.vendor_id    = inv.vendor_id
  AND   oc.vendor_site_id = inv.vendor_site_id;



l_counter            NUMBER := 1;
l_payment_method     VARCHAR2(30);
l_settlement_amount  NUMBER := p_settlement_amount;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  OPEN csr_get_claim_details(p_claim_id);
  FETCH csr_get_claim_details INTO l_payment_method;
  CLOSE csr_get_claim_details;

  IF l_payment_method IN ('CHECK','EFT','WIRE','AP_DEFAULT') THEN
     OPEN csr_inv_settlement(p_claim_id);
     LOOP
           FETCH csr_inv_settlement INTO x_settlement_doc_tbl(l_counter).settlement_id
                               , x_settlement_doc_tbl(l_counter).settlement_type
                               , x_settlement_doc_tbl(l_counter).settlement_type_id
                               , x_settlement_doc_tbl(l_counter).settlement_number
                               , x_settlement_doc_tbl(l_counter).settlement_date
                               , x_settlement_doc_tbl(l_counter).settlement_amount
                               , x_settlement_doc_tbl(l_counter).status_code
                               , x_settlement_doc_tbl(l_counter).payment_method
                               , x_settlement_doc_tbl(l_counter).discount_taken
                               , x_invoice_amount;
            EXIT WHEN csr_inv_settlement%NOTFOUND;
            x_settlement_doc_tbl(l_counter).claim_id := p_claim_id;
            IF l_settlement_amount <= x_settlement_doc_tbl(l_counter).settlement_amount THEN
                   x_settlement_doc_tbl(l_counter).settlement_amount
                           := l_settlement_amount - x_settlement_doc_tbl(l_counter).discount_taken;
                   RETURN;
            END IF;
            l_settlement_amount := l_settlement_amount - x_settlement_doc_tbl(l_counter).settlement_amount
                                   -  x_settlement_doc_tbl(l_counter).discount_taken;
            l_counter := l_counter + 1;
     END LOOP;
     CLOSE csr_inv_settlement;
     x_settlement_doc_tbl.DELETE(l_counter); -- Last Record has junk
 ELSE
     OPEN csr_debit_settlement(p_claim_id);
     LOOP
           FETCH csr_debit_settlement INTO x_settlement_doc_tbl(l_counter).settlement_id
                               , x_settlement_doc_tbl(l_counter).settlement_type
                               , x_settlement_doc_tbl(l_counter).settlement_type_id
                               , x_settlement_doc_tbl(l_counter).settlement_number
                               , x_settlement_doc_tbl(l_counter).settlement_date
                               , x_settlement_doc_tbl(l_counter).settlement_amount
                               , x_settlement_doc_tbl(l_counter).status_code
                               , x_settlement_doc_tbl(l_counter).payment_method
                               , x_settlement_doc_tbl(l_counter).discount_taken
                               , x_invoice_amount;
            EXIT WHEN csr_debit_settlement%NOTFOUND;
            x_settlement_doc_tbl(l_counter).claim_id := p_claim_id;
            l_counter := l_counter + 1;
     END LOOP;
     CLOSE csr_debit_settlement;
     x_settlement_doc_tbl.DELETE(l_counter); -- Last Record has junk
 END IF;

  IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF csr_get_claim_details%ISOPEN THEN
      CLOSE csr_get_claim_details;
    END IF;

    IF csr_inv_settlement%ISOPEN THEN
      CLOSE csr_inv_settlement;
    END IF;

    IF csr_debit_settlement%ISOPEN THEN
      CLOSE csr_debit_settlement;
    END IF;

    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;

END Get_AP_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_AR_Rec
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Get_AR_Rec(
   p_claim_id             IN  NUMBER,
   p_claim_number         IN  VARCHAR2,
   p_payment_method       IN  VARCHAR2,
   p_settlement_amount    IN  NUMBER,
   x_settlement_doc_tbl   OUT NOCOPY settlement_doc_tbl_type,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS

-- Fix for Bug 7293326
CURSOR csr_ar_settlement(cv_claim_id IN VARCHAR2, cv_claim_number IN VARCHAR2) IS
  SELECT cust.customer_trx_id       --"settlement_id"
  , cust.cust_trx_type_id           --"settlement_type_id"
  , cust.trx_number                 --"settlement_number"
  , cust.trx_date                   --"settlement_date"
  , pay.amount_due_original      --"settlement_amount"
  , pay.status                      --"status_code"
  FROM ra_customer_trx cust,
  ra_customer_trx_lines lines,
  ar_payment_schedules pay
  where cust.customer_trx_id = lines.customer_trx_id
  and cust.customer_trx_id = pay.customer_trx_id
  and cust.complete_flag = 'Y'
  AND lines.interface_line_attribute2 = cv_claim_id
  AND lines.interface_line_attribute1 = cv_claim_number;

-- Modified for 4953844
-- Modified for Bugfix 5199354
CURSOR csr_rma_settlement(cv_claim_id IN NUMBER) IS
 select pay.customer_trx_id                      --"settlement_id"
   , pay.cust_trx_type_id                          --"settlement_type_id"
   , pay.trx_number                                --"settlement_number"
   , pay.trx_date                                  --"settlement_date"
   , sum(pay.amount_due_original)                  --"settlement_amount"
 from  ar_payment_schedules pay ,  ( select  distinct customer_trx_id
         from  ozf_claim_lines ln ,    ra_customer_trx_lines cm_line
         where cm_line.line_type = 'LINE'
         and   cm_line.interface_line_context = 'ORDER ENTRY' --added filter for 4940650
         and   cm_line.interface_line_attribute6 = to_char(ln.payment_reference_id) -- order line id
         and   ln.claim_id = cv_claim_id) cla
  where pay.customer_trx_id = cla.customer_trx_id
  group by pay.customer_trx_id, pay.cust_trx_type_id,pay.trx_number, pay.trx_date;


l_counter            NUMBER := 1;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  IF p_payment_method = 'RMA' THEN
     OPEN csr_rma_settlement(p_claim_id);
     LOOP
       FETCH csr_rma_settlement INTO x_settlement_doc_tbl(l_counter).settlement_id
                                   , x_settlement_doc_tbl(l_counter).settlement_type_id
                                   , x_settlement_doc_tbl(l_counter).settlement_number
                                   , x_settlement_doc_tbl(l_counter).settlement_date
                                   , x_settlement_doc_tbl(l_counter).settlement_amount;
                                 --  , x_settlement_doc_tbl(l_counter).claim_line_id;
                                   --, x_settlement_doc_tbl(l_counter).status_code;
       EXIT WHEN csr_rma_settlement%NOTFOUND;
       x_settlement_doc_tbl(l_counter).claim_id := p_claim_id;
       x_settlement_doc_tbl(l_counter).payment_method := 'RMA';
       IF ABS(p_settlement_amount) < ABS(x_settlement_doc_tbl(l_counter).settlement_amount) THEN
          x_settlement_doc_tbl(l_counter).settlement_amount := p_settlement_amount * -1;
       END IF;
       l_counter := l_counter + 1;
     END LOOP;
     CLOSE csr_rma_settlement;
  ELSE
     OPEN csr_ar_settlement(TO_CHAR(p_claim_id), p_claim_number);
     LOOP
       FETCH csr_ar_settlement INTO x_settlement_doc_tbl(l_counter).settlement_id
                                  , x_settlement_doc_tbl(l_counter).settlement_type_id
                                  , x_settlement_doc_tbl(l_counter).settlement_number
                                  , x_settlement_doc_tbl(l_counter).settlement_date
                                  , x_settlement_doc_tbl(l_counter).settlement_amount
                                  , x_settlement_doc_tbl(l_counter).status_code;
       EXIT WHEN csr_ar_settlement%NOTFOUND;
       x_settlement_doc_tbl(l_counter).claim_id := p_claim_id;
       /*
       IF ABS(p_settlement_amount) < ABS(x_settlement_doc_tbl(l_counter).settlement_amount) THEN
          x_settlement_doc_tbl(l_counter).settlement_amount := p_settlement_amount * -1;
       END IF;
       */
       l_counter := l_counter + 1;
     END LOOP;
     CLOSE csr_ar_settlement;
  END IF;
--  x_settlement_doc_tbl.DELETE(l_counter); -- Last Record has junk

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF OZF_DEBUG_LOW_ON THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT','Get_AR_Rec : Error');
     FND_MSG_PUB.Add;
    END IF;

END Get_AR_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_RMA_Setl_Doc_Tbl
--
-- HISTORY
--    11/10/2002  mchang    Created.
---------------------------------------------------------------------
PROCEDURE Get_RMA_Setl_Doc_Tbl(
   p_claim_id             IN  NUMBER,
   x_settlement_doc_tbl   OUT NOCOPY settlement_doc_tbl_type,
   x_total_rma_cr_amount  OUT NOCOPY NUMBER,
   x_return_status        OUT NOCOPY VARCHAR2
)
IS
CURSOR csr_rma_setl_doc(cv_claim_id IN NUMBER) IS
  SELECT settlement_id
  ,      settlement_type_id
  ,      settlement_number
  ,      settlement_date
  ,      settlement_amount
  ,      claim_id
  ,      claim_line_id
  ,      payment_method
  FROM ozf_settlement_docs
  WHERE claim_id = cv_claim_id;

l_counter                     NUMBER := 1;
l_total_rma_cr_amount         NUMBER := 0;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_rma_setl_doc(p_claim_id);
   LOOP
      FETCH csr_rma_setl_doc INTO x_settlement_doc_tbl(l_counter).settlement_id
                                , x_settlement_doc_tbl(l_counter).settlement_type_id
                                , x_settlement_doc_tbl(l_counter).settlement_number
                                , x_settlement_doc_tbl(l_counter).settlement_date
                                , x_settlement_doc_tbl(l_counter).settlement_amount
                                , x_settlement_doc_tbl(l_counter).claim_id
                                , x_settlement_doc_tbl(l_counter).claim_line_id
                                , x_settlement_doc_tbl(l_counter).payment_method;
      EXIT WHEN csr_rma_setl_doc%NOTFOUND;
      IF x_settlement_doc_tbl(l_counter).settlement_id IS NOT NULL ANd
         x_settlement_doc_tbl(l_counter).settlement_id <> FND_API.g_miss_num THEN
         l_total_rma_cr_amount := l_total_rma_cr_amount + ABS(x_settlement_doc_tbl(l_counter).settlement_amount);
      END IF;
      l_counter := l_counter + 1;
   END LOOP;
   CLOSE csr_rma_setl_doc;
   x_settlement_doc_tbl.DELETE(l_counter); -- Last Record has junk

   x_total_rma_cr_amount := l_total_rma_cr_amount;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF OZF_DEBUG_LOW_ON THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT','Get_RMA_Setl_Doc_Tbl : Error');
     FND_MSG_PUB.Add;
    END IF;

END Get_RMA_Setl_Doc_Tbl;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_From_Settlement
--
-- HISTORY
--                 pnerella  Create.
--    30-MAY-2001  mchang    Modified.
--    09-AUG-2001  mchang    Update fund paid amount to sum of utilizations
--                           associated to a claim when claim status is 'CLOSEd.
--    26-Oct-2005  Sahana      Bug4638514: Update paid amount in
--                                           OZF_OBJECT_FUND_SUMMARY.
---------------------------------------------------------------------
PROCEDURE Update_Claim_From_Settlement(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_claim_id                   IN NUMBER,
    p_object_version_number      IN NUMBER,
    p_status_code                IN VARCHAR2,
    p_payment_status             IN VARCHAR2
)
IS
l_api_version_number    CONSTANT NUMBER   := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Update_Claim_From_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);

l_claim_rec                      OZF_CLAIM_PVT.claim_Rec_Type;
l_claim_new_obj_num              NUMBER;

l_fund_rec                       OZF_Funds_PVT.fund_rec_type;
l_function_currency              VARCHAR2(15);
l_counter                        NUMBER := 1;
l_adj_util_result_status         VARCHAR2(15);

l_fund_id                        NUMBER;
l_component_type                 VARCHAR2(30);
l_component_id                   NUMBER;
l_acctd_paid_amt                 NUMBER;
l_fund_curr_paid_amt             NUMBER;
l_plan_curr_paid_amt             NUMBER;
l_univ_curr_paid_amt             NUMBER;

--//Bugfix : 8428220
l_history_event_description      VARCHAR2(2000);
l_history_event                  VARCHAR2(30);
l_needed_to_create               VARCHAR2(1)  := 'N';
l_claim_history_id               NUMBER       := NULL;
l_payment_status                 VARCHAR2(30) := NULL;

CURSOR csr_claim_payment_stat(p_claim_id IN NUMBER) IS
SELECT payment_status
FROM   ozf_claims_all
where  claim_id= p_claim_id;

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  default_flag = 'Y'
  AND  system_status_code = cv_status_code;

CURSOR csr_get_paid_amt(cv_claim_id IN NUMBER) IS
  SELECT   fu.fund_id,
                 fu.component_type,
                 fu.component_id,
                 SUM(lu.acctd_amount),
                 SUM(lu.plan_curr_amount),
                 SUM(lu.univ_curr_amount),
                 SUM(lu.util_curr_amount) -- 8710054
  FROM      ozf_claim_lines_util_all lu
                ,ozf_claim_lines_all l
                ,ozf_funds_utilized_all_b fu
  WHERE  l.claim_line_id = lu.claim_line_id
  AND       fu.utilization_id = lu.utilization_id
  AND       l.claim_id = cv_claim_id
  GROUP BY fu.fund_id,fu.component_type,fu.component_id;

CURSOR csr_fund_rec(cv_fund_id IN NUMBER) IS
  SELECT object_version_number
  ,      paid_amt
  /* BEGIN OF BUG2740879 FIXING 01/21/2003 */
  --FROM ozf_funds
  FROM ozf_funds_all_b
  /* END OF BUG2740879 FIXING 01/21/2003 */
  WHERE fund_id = cv_fund_id;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_custom_status_id(p_claim_id IN NUMBER, p_status_code IN VARCHAR2) IS
  SELECT close_status_id
  FROM   ozf_claims_all oc,
         ams_user_statuses_vl us
  WHERE  oc.claim_id = p_claim_id
    AND  oc.close_status_id = us.user_status_id
    AND  us.system_status_type = 'OZF_CLAIM_STATUS'
    AND  us.system_status_code = p_status_code;

l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
l_dummy_id                        NUMBER;

--R12.1 Enhancement : Price Protection
CURSOR csr_claim_rec(p_claim_id IN NUMBER) IS
  SELECT source_object_class,
         created_by
  FROM   ozf_claims_all
  WHERE  claim_id = p_claim_id;

CURSOR csr_claim_lines(cv_claim_id IN NUMBER) IS
  SELECT ln.claim_line_id
  ,      ln.object_version_number
  ,      ln.last_update_date
  ,      ln.last_updated_by
  ,      ln.creation_date
  ,      ln.created_by
  ,      ln.last_update_login
  ,      ln.request_id
  ,      ln.program_application_id
  ,      ln.program_update_date
  ,      ln.program_id
  ,      ln.created_from
  ,      ln.claim_id
  ,      ln.line_number
  ,      ln.split_from_claim_line_id
  ,      ln.amount
  ,      ln.claim_currency_amount
  ,      ln.acctd_amount
  ,      ln.currency_code
  ,      ln.exchange_rate_type
  ,      ln.exchange_rate_date
  ,      ln.exchange_rate
  ,      ln.set_of_books_id
  ,      ln.valid_flag
  ,      ln.source_object_id
  ,      ln.source_object_class
  ,      ln.source_object_type_id
  ,      ln.source_object_line_id
  ,      ln.plan_id
  ,      ln.offer_id
  ,      ln.utilization_id
  ,      ln.payment_method
  ,      ln.payment_reference_id
  ,      ln.payment_reference_number
  ,      ln.payment_reference_date
  ,      ln.voucher_id
  ,      ln.voucher_number
  ,      ln.payment_status
  ,      ln.approved_flag
  ,      ln.approved_date
  ,      ln.approved_by
  ,      ln.settled_date
  ,      ln.settled_by
  ,      ln.performance_complete_flag
  ,      ln.performance_attached_flag
  ,      ln.item_id
  ,      ln.item_description
  ,      ln.quantity
  ,      ln.quantity_uom
  ,      ln.rate
  ,      ln.activity_type
  ,      ln.activity_id
  ,      ln.related_cust_account_id
  ,      ln.relationship_type
  ,      ln.earnings_associated_flag
  ,      ln.comments
  ,      ln.tax_code
  ,      ln.attribute_category
  ,      ln.attribute1
  ,      ln.attribute2
  ,      ln.attribute3
  ,      ln.attribute4
  ,      ln.attribute5
  ,      ln.attribute6
  ,      ln.attribute7
  ,      ln.attribute8
  ,      ln.attribute9
  ,      ln.attribute10
  ,      ln.attribute11
  ,      ln.attribute12
  ,      ln.attribute13
  ,      ln.attribute14
  ,      ln.attribute15
  ,      ln.org_id
  ,      ln.sale_date
  ,      ln.item_type
  ,      ln.tax_amount
  ,      ln.claim_curr_tax_amount
  ,      ln.activity_line_id
  ,      ln.offer_type
  ,      ln.prorate_earnings_flag
  ,      ln.earnings_end_date
  ,      ln.dpp_cust_account_id
  FROM ozf_claim_lines ln
  WHERE ln.claim_id = cv_claim_id;

l_line_detail_tbl       DPP_SLA_CLAIM_EXTRACT_PUB.claim_line_tbl_type;
l_line_counter        NUMBER := 1;
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(20000);

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Update_Claim_From_Settlement;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
            l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME
         ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --------------------- start -----------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;


  l_claim_rec.claim_id := p_claim_id;
  l_claim_rec.object_version_number := p_object_version_number;
  l_claim_rec.payment_status := p_payment_status;
  l_claim_rec.status_code := p_status_code;

  OPEN csr_custom_status_id(p_claim_id, p_status_code);
  FETCH csr_custom_status_id INTO l_claim_rec.user_status_id;
  CLOSE csr_custom_status_id;

  IF l_claim_rec.user_status_id IS NULL THEN
     OPEN csr_user_status_id(p_status_code);
     FETCH csr_user_status_id INTO l_claim_rec.user_status_id;
     CLOSE csr_user_status_id;
  END IF;

  --//Bugfix: 8428220
  OPEN csr_claim_payment_stat(p_claim_id);
  FETCH csr_claim_payment_stat INTO l_payment_status;
  CLOSE csr_claim_payment_stat;

  BEGIN
    UPDATE ozf_claims_all
    SET payment_status = p_payment_status
    ,   status_code = p_status_code
    ,   user_status_id = l_claim_rec.user_status_id
    WHERE claim_id = p_claim_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_UPD_CLAM_ERR');
         FND_MSG_PUB.add;
      END IF;
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
  END;


   IF p_status_code = 'CLOSED' THEN
      OZF_CLAIM_ACCRUAL_PVT.Adjust_Fund_Utilization(
            p_api_version       => l_api_version_number
           ,p_init_msg_list     => FND_API.g_false
           ,p_commit            => FND_API.g_false
           ,p_validation_level  => FND_API.g_valid_level_full
           ,x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           ,p_claim_id          => p_claim_id
           ,p_mode              => 'UPD_SCAN'
           ,x_next_status       => l_adj_util_result_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF l_adj_util_result_status = 'CLOSED' THEN
         -- Update fund paid amount to sum of utilizations associated to a claim
         OPEN csr_function_currency;
         FETCH csr_function_currency INTO l_function_currency;
         CLOSE csr_function_currency;

         OPEN csr_get_paid_amt(p_claim_id);
         LOOP
                   FETCH csr_get_paid_amt
                   INTO   l_fund_id, l_component_type, l_component_id,
                               l_acctd_paid_amt, l_plan_curr_paid_amt, l_univ_curr_paid_amt,l_fund_curr_paid_amt;
                   EXIT WHEN csr_get_paid_amt%NOTFOUND;

                  OZF_Funds_PVT.Init_Fund_Rec( x_fund_rec  => l_fund_rec);

                  l_fund_rec.fund_id := l_fund_id;

                  OPEN csr_fund_rec(l_fund_id);
                  FETCH csr_fund_rec INTO l_fund_rec.object_version_number  -- 8710054
                                         , l_fund_rec.paid_amt;
                  CLOSE csr_fund_rec;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('Original Fund Paid Amount = '||l_fund_rec.paid_amt);
                  END IF;



                  IF l_fund_curr_paid_amt IS NOT NULL THEN
                     l_fund_rec.paid_amt := NVL(l_fund_rec.paid_amt, 0) + l_fund_curr_paid_amt;
                  END IF;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('Updated Fund Paid Amount = '||l_fund_rec.paid_amt);
                  END IF;

                  -- Update Fund with paid_amt
                  OZF_Funds_PVT.Update_Fund(
                      p_api_version       => 1.0
                     ,p_init_msg_list     => FND_API.g_false
                     ,p_commit            => FND_API.g_false
                     ,p_validation_level  => FND_API.g_valid_level_full
                     ,x_return_status     => l_return_status
                     ,x_msg_count         => x_msg_count
                     ,x_msg_data          => x_msg_data
                     ,p_fund_rec          => l_fund_rec
                     ,p_mode              => 'ADJUST'
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  l_objfundsum_rec.fund_id := l_fund_id;
                  l_objfundsum_rec.object_type := l_component_type;
                  l_objfundsum_rec.object_id := l_component_id;
                  l_objfundsum_rec.paid_amt :=  l_fund_curr_paid_amt;
                  l_objfundsum_rec.plan_curr_paid_amt :=  l_plan_curr_paid_amt;
                  l_objfundsum_rec.univ_curr_paid_amt :=  l_univ_curr_paid_amt;

                   ozf_objfundsum_pvt.process_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data,
                       x_objfundsum_id              => l_dummy_id
                  );
                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                       RAISE fnd_api.g_exc_error;
                END IF;

         END LOOP;
         CLOSE csr_get_paid_amt;

      END IF; -- end of if adjst_over_utilization result = closed
   END IF; -- end of if p_status_code='CLOSED'


 --//Bugfix : 8428220 - Claim History Creation Check
 IF (p_status_code ='CLOSED'  AND l_payment_status ='INTERFACED') THEN

    OZF_claims_history_PVT.Check_Create_History(
       p_claim                     => l_claim_rec,
       p_event                     => 'UPDATE',
       x_history_event             => l_history_event,
       x_history_event_description => l_history_event_description,
       x_needed_to_create          => l_needed_to_create,
       x_return_status             => l_return_status
     );

       IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF (l_needed_to_create = 'Y') THEN
           -- CREATE history
           OZF_claims_history_PVT.Create_History(
              p_claim_id                   => p_claim_id,
              p_history_event              => l_history_event,
              p_history_event_description  => l_history_event_description,
              x_claim_history_id           => l_claim_history_id,
              x_return_status              => l_return_status
           );
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
       END IF;
   END IF;
--//End Bugfix : 8428220

   ------------------------------------------------
   -- Raise Business Event (when claim is paid.) --
   ------------------------------------------------
   OZF_CLAIM_SETTLEMENT_PVT.Raise_Business_Event(
       p_api_version            => l_api_version_number
      ,p_init_msg_list          => FND_API.g_false
      ,p_commit                 => FND_API.g_false
      ,p_validation_level       => FND_API.g_valid_level_full
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count

      ,p_claim_id               => p_claim_id
      ,p_old_status             => 'PENDING_CLOSE'
      ,p_new_status             => 'CLOSED'
      ,p_event_name             => 'oracle.apps.ozf.claim.paymentPaid'
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
--R12.1 Enhancement : Call Price Protection Extract API START
    OPEN csr_claim_rec(p_claim_id);
    FETCH csr_claim_rec INTO l_claim_rec.source_object_class
                           , l_claim_rec.created_by;

    CLOSE csr_claim_rec;
    -- Fix For Bug 7443072
    IF l_claim_rec.source_object_class IN ('PPCUSTOMER','PPVENDOR','PPINCVENDOR')
THEN
      OPEN  csr_claim_lines(p_claim_id);
        LOOP
                FETCH csr_claim_lines into
                l_line_detail_tbl(l_line_counter).claim_line_id
              , l_line_detail_tbl(l_line_counter).object_version_number
              , l_line_detail_tbl(l_line_counter).last_update_date
              , l_line_detail_tbl(l_line_counter).last_updated_by
              , l_line_detail_tbl(l_line_counter).creation_date
              , l_line_detail_tbl(l_line_counter).created_by
              , l_line_detail_tbl(l_line_counter).last_update_login
              , l_line_detail_tbl(l_line_counter).request_id
              , l_line_detail_tbl(l_line_counter).program_application_id
              , l_line_detail_tbl(l_line_counter).program_update_date
              , l_line_detail_tbl(l_line_counter).program_id
              , l_line_detail_tbl(l_line_counter).created_from
              , l_line_detail_tbl(l_line_counter).claim_id
              , l_line_detail_tbl(l_line_counter).line_number
              , l_line_detail_tbl(l_line_counter).split_from_claim_line_id
              , l_line_detail_tbl(l_line_counter).amount
              , l_line_detail_tbl(l_line_counter).claim_currency_amount
              , l_line_detail_tbl(l_line_counter).acctd_amount
              , l_line_detail_tbl(l_line_counter).currency_code
              , l_line_detail_tbl(l_line_counter).exchange_rate_type
              , l_line_detail_tbl(l_line_counter).exchange_rate_date
              , l_line_detail_tbl(l_line_counter).exchange_rate
              , l_line_detail_tbl(l_line_counter).set_of_books_id
              , l_line_detail_tbl(l_line_counter).valid_flag
              , l_line_detail_tbl(l_line_counter).source_object_id
              , l_line_detail_tbl(l_line_counter).source_object_class
              , l_line_detail_tbl(l_line_counter).source_object_type_id
              , l_line_detail_tbl(l_line_counter).source_object_line_id
              , l_line_detail_tbl(l_line_counter).plan_id
              , l_line_detail_tbl(l_line_counter).offer_id
              , l_line_detail_tbl(l_line_counter).utilization_id
              , l_line_detail_tbl(l_line_counter).payment_method
              , l_line_detail_tbl(l_line_counter).payment_reference_id
              , l_line_detail_tbl(l_line_counter).payment_reference_number
              , l_line_detail_tbl(l_line_counter).payment_reference_date
              , l_line_detail_tbl(l_line_counter).voucher_id
              , l_line_detail_tbl(l_line_counter).voucher_number
              , l_line_detail_tbl(l_line_counter).payment_status
              , l_line_detail_tbl(l_line_counter).approved_flag
              , l_line_detail_tbl(l_line_counter).approved_date
              , l_line_detail_tbl(l_line_counter).approved_by
              , l_line_detail_tbl(l_line_counter).settled_date
              , l_line_detail_tbl(l_line_counter).settled_by
              , l_line_detail_tbl(l_line_counter).performance_complete_flag
              , l_line_detail_tbl(l_line_counter).performance_attached_flag
              , l_line_detail_tbl(l_line_counter).item_id
              , l_line_detail_tbl(l_line_counter).item_description
              , l_line_detail_tbl(l_line_counter).quantity
              , l_line_detail_tbl(l_line_counter).quantity_uom
              , l_line_detail_tbl(l_line_counter).rate
              , l_line_detail_tbl(l_line_counter).activity_type
              , l_line_detail_tbl(l_line_counter).activity_id
              , l_line_detail_tbl(l_line_counter).related_cust_account_id
              , l_line_detail_tbl(l_line_counter).relationship_type
              , l_line_detail_tbl(l_line_counter).earnings_associated_flag
              , l_line_detail_tbl(l_line_counter).comments
              , l_line_detail_tbl(l_line_counter).tax_code
              , l_line_detail_tbl(l_line_counter).attribute_category
              , l_line_detail_tbl(l_line_counter).attribute1
              , l_line_detail_tbl(l_line_counter).attribute2
              , l_line_detail_tbl(l_line_counter).attribute3
              , l_line_detail_tbl(l_line_counter).attribute4
              , l_line_detail_tbl(l_line_counter).attribute5
              , l_line_detail_tbl(l_line_counter).attribute6
              , l_line_detail_tbl(l_line_counter).attribute7
              , l_line_detail_tbl(l_line_counter).attribute8
              , l_line_detail_tbl(l_line_counter).attribute9
              , l_line_detail_tbl(l_line_counter).attribute10
              , l_line_detail_tbl(l_line_counter).attribute11
              , l_line_detail_tbl(l_line_counter).attribute12
              , l_line_detail_tbl(l_line_counter).attribute13
              , l_line_detail_tbl(l_line_counter).attribute14
              , l_line_detail_tbl(l_line_counter).attribute15
              , l_line_detail_tbl(l_line_counter).org_id
              , l_line_detail_tbl(l_line_counter).sale_date
              , l_line_detail_tbl(l_line_counter).item_type
              , l_line_detail_tbl(l_line_counter).tax_amount
              , l_line_detail_tbl(l_line_counter).claim_curr_tax_amount
              , l_line_detail_tbl(l_line_counter).activity_line_id
              , l_line_detail_tbl(l_line_counter).offer_type
              , l_line_detail_tbl(l_line_counter).prorate_earnings_flag
              , l_line_detail_tbl(l_line_counter).earnings_end_date
              , l_line_detail_tbl(l_line_counter).dpp_cust_account_id;
             EXIT WHEN csr_claim_lines%NOTFOUND;
             l_line_counter := l_line_counter + 1;
           END LOOP;
           CLOSE csr_claim_lines;
           IF l_line_counter > 1 THEN
                                DPP_SLA_CLAIM_EXTRACT_PUB.Create_SLA_Extract(
                                                p_api_version_number=>1.0,
                                                x_return_status=>x_return_status,
                              x_msg_count=>x_msg_count,
                                            x_msg_data=>x_msg_data,
                                                p_claim_id=>p_claim_id,
                              p_claim_line_tbl=>l_line_detail_tbl,
                                            p_userid =>l_claim_rec.created_by
                                );


                  IF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                  ELSIF x_return_status =  FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;

            END IF;
 END IF;
--R12.1 Enhancement : Call Price Protection Extract API END
  --------------------- finish -----------------------
  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
  END IF;

  FND_MSG_PUB.Count_And_Get(
     p_count   =>   x_msg_count,
     p_data    =>   x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': end');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Claim_From_Settlement;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Claim_From_Settlement;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Claim_From_Settlement;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
END Update_Claim_From_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--    Split_Claim_Settlement
--
-- HISTORY
--    28-MAR-2002  mchang    Created.
---------------------------------------------------------------------
PROCEDURE Split_Claim_Settlement(
   p_claim_rec                  IN   OZF_CLAIM_PVT.claim_rec_type,
   p_difference_amount          IN   NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version           CONSTANT NUMBER   := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Split_Claim_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(1);

l_child_claim_tbl       OZF_SPLIT_CLAIM_PVT.Child_Claim_tbl_type;
l_claim_line_rec        OZF_Claim_Line_PVT.claim_line_rec_type;
l_claim_line_id         NUMBER;
l_root_claim_number     VARCHAR2(30);
l_claim_rec             OZF_CLAIM_PVT.claim_rec_type ;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   /*----------------------------*
   | Create Split
   *----------------------------*/
   IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message(l_full_name||' : Create Split Claim');
   END IF;

   l_child_claim_tbl(1).claim_type_id := p_claim_rec.claim_type_id;
   l_child_claim_tbl(1).amount := p_difference_amount;
   l_child_claim_tbl(1).line_amount_sum := 0;
   l_child_claim_tbl(1).reason_code_id := p_claim_rec.reason_code_id;
   l_child_claim_tbl(1).parent_claim_id := p_claim_rec.claim_id;
   l_child_claim_tbl(1).parent_object_ver_num := p_claim_rec.object_version_number;
   l_child_claim_tbl(1).line_table := NULL;
   OZF_SPLIT_CLAIM_PVT.create_child_claim_tbl (
           p_api_version           => l_api_version
          ,p_init_msg_list         => FND_API.g_false
          ,p_commit                => FND_API.g_false
          ,p_validation_level      => FND_API.g_valid_level_full
          ,x_return_status         => l_return_status
          ,x_msg_data              => x_msg_data
          ,x_msg_count             => x_msg_count
          ,p_child_claim_tbl       => l_child_claim_tbl
          ,p_mode                  => 'AUTO'
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;


   OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_rec.claim_id
        ,x_claim_rec       => l_claim_rec
        ,x_return_status   => l_return_status
      );
   IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   Update_Claim_Tax_Amount(
        p_claim_rec         => l_claim_rec
       ,x_return_status     => l_return_status
       ,x_msg_data          => x_msg_data
       ,x_msg_count         => x_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
      FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Split_Claim_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Write_Off
--
-- HISTORY
--    19-Jan-2005   Sahana Created for Bug4087329
---------------------------------------------------------------------
PROCEDURE Create_Write_Off(
   p_claim_rec                  IN   OZF_CLAIM_PVT.claim_rec_type,
   p_customer_trx_id            IN   NUMBER,
   p_deduction_type             IN   VARCHAR2,
   p_difference_amount          IN   NUMBER,

   x_claim_object_version       OUT NOCOPY  NUMBER,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version           CONSTANT NUMBER   := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Write_Off';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(1);

l_writeoff_threshold    VARCHAR2(15);
l_adj_rec               AR_ADJUSTMENTS%ROWTYPE;
l_x_new_adjust_number   VARCHAR2(20);
l_x_new_adjust_id       NUMBER;
l_payment_schedule_id   NUMBER;
l_receivables_trx_id    NUMBER;
l_reason_code           VARCHAR2(30);
l_claim_line_id         NUMBER;
l_settlement_doc_rec    settlement_doc_rec_type;
l_settlement_doc_id     NUMBER;
l_claim_object_version  NUMBER;
l_claim_rec             OZF_CLAIM_PVT.claim_rec_type ;
l_claim_line_rec        OZF_Claim_Line_PVT.claim_line_rec_type;

CURSOR csr_invoice_writeoff(cv_adjust_id  IN NUMBER) IS
   SELECT adj.adjustment_id        --"settlement_id"
   , adj.receivables_trx_id        --"settlement_type_id"
   , adj.adjustment_number         --"settlement_number"
   , adj.apply_date                --"settlement_date"
   , adj.amount                    --"settlement_amount"
   , pay.status                    --"status_code"
   FROM ar_adjustments adj
   , ar_payment_schedules pay
   WHERE adj.payment_schedule_id = pay.payment_schedule_id
   AND adj.adjustment_id = cv_adjust_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_rec.claim_id
        ,x_claim_rec       => l_claim_rec
        ,x_return_status   => l_return_status
      );
   IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   l_claim_object_version := l_claim_rec.object_version_number;

   /*----------------------------*
   | Create Claim Line with write_off amount
   *----------------------------*/
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : Create Claim Line :: claim_currency_amount='||p_difference_amount);
   END IF;
   l_claim_line_rec.claim_id := p_claim_rec.claim_id;
   l_claim_line_rec.claim_currency_amount := p_difference_amount;
   l_claim_line_rec.item_description := 'Write Off';
   l_claim_line_rec.comments := 'Write Off';
   l_claim_line_rec.update_from_tbl_flag := FND_API.g_true;

   OZF_Claim_Line_PVT.Create_Claim_Line(
         p_api_version      => l_api_version,
         p_init_msg_list    => FND_API.g_false,
         p_commit           => FND_API.g_false,
         p_validation_level => FND_API.g_valid_level_full,
         x_return_status    => l_return_status,
         x_msg_count        => x_msg_count,
         x_msg_data         => x_msg_data,
         p_claim_line_rec   => l_claim_line_rec,
         x_claim_line_id    => l_claim_line_id
    );
    IF l_return_status =  FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

    /*----------------------------*
    | 1. Create Write off
    | 2. Update Invoice Dispute Amount if source deduction
    *----------------------------*/
    IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message(l_full_name||' : Create AR Write Off');
    END IF;
    OZF_AR_PAYMENT_PVT.Create_AR_Write_Off(
           p_claim_rec              => p_claim_rec
          ,p_deduction_type         => p_deduction_type
          ,p_write_off_amount       => p_difference_amount
          ,x_wo_adjust_id           => l_x_new_adjust_id
          ,x_return_status          => l_return_status
          ,x_msg_data               => x_msg_data
          ,x_msg_count              => x_msg_count
    );
    IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

        /*----------------------*
        | Update Settled Amount|
        *----------------------*/
   l_claim_rec.amount_settled := l_claim_rec.amount_settled + p_difference_amount;


   Update_Claim_Tax_Amount(
        p_claim_rec         => l_claim_rec
       ,x_return_status     => l_return_status
       ,x_msg_data          => x_msg_data
       ,x_msg_count         => x_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   x_claim_object_version := l_claim_object_version;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
      FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Create_Write_Off;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_RMA_settlement
--
-- HISTORY
--    14-NOV-2002  mchang    Created.
---------------------------------------------------------------------
PROCEDURE Process_RMA_settlement(
    p_claim_setl_rec             IN   OZF_CLAIM_PVT.claim_rec_type,
    p_settlement_doc_tbl         IN   settlement_doc_tbl_type,
    p_total_rma_cr_amount        IN   NUMBER,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version           CONSTANT NUMBER   := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Process_RMA_settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);

i                                NUMBER;
l_claim_rec                      OZF_CLAIM_PVT.claim_rec_type;
l_upd_claim_rec                  OZF_CLAIM_PVT.claim_rec_type;
l_child_claim_tbl                OZF_SPLIT_CLAIM_PVT.Child_Claim_tbl_type;
l_settlement_doc_id              NUMBER;
l_unpaid_claim_line              NUMBER;
l_deduction_type                 VARCHAR2(30);
l_upd_claim_status               BOOLEAN      := FALSE;
l_difference_amount              NUMBER;
l_inv_bal_error                  BOOLEAN      := FALSE;

l_rma_cm_line_amount             NUMBER;
l_rma_cm_tax_amount              NUMBER;
l_rma_cm_freight_amount          NUMBER;
l_rma_cm_total_amount            NUMBER;
l_invoice_trx_id                 NUMBER;

l_dummy_number                   NUMBER;



-- Bug3951827: Cursor changed to consider header freight
-- Modified for Bugfix 5199354
CURSOR csr_rma_total_amount(cv_claim_id IN NUMBER) IS
 select  sum(nvl(amount_line_items_original, 0))
  ,      sum(nvl(tax_original,0))
  ,      sum(nvl(freight_original,0))
  ,      previous_customer_trx_id
 from ar_payment_schedules ps, ra_customer_trx trx , ( select  distinct customer_trx_id
         from ozf_claim_lines ln ,    ra_customer_trx_lines cm_line
         where cm_line.line_type = 'LINE'
         and   cm_line.interface_line_context = 'ORDER ENTRY' --added filter for 4953844
         and   cm_line.interface_line_attribute6 = to_char(ln.payment_reference_id)
         and ln.claim_id = cv_claim_id) cla
 where ps.customer_trx_id  = trx.customer_trx_id
 and ps.customer_trx_id = cla.customer_trx_id
 group by previous_customer_trx_id;



CURSOR csr_sum_line_amount(cv_claim_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

l_settlement_amount NUMBER := 0; --Bug3951827
l_write_off_flag  BOOLEAN;


BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_rma_total_amount(p_claim_setl_rec.claim_id);
   FETCH csr_rma_total_amount INTO l_rma_cm_line_amount
                                 , l_rma_cm_tax_amount
                                 , l_rma_cm_freight_amount
                                 , l_invoice_trx_id;
   CLOSE csr_rma_total_amount;

   l_rma_cm_total_amount := NVL(l_rma_cm_line_amount,0) + NVL(l_rma_cm_tax_amount,0) + NVL(l_rma_cm_freight_amount,0);

   l_difference_amount := p_claim_setl_rec.amount_settled + l_rma_cm_total_amount;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'claim amount settled            = '||p_claim_setl_rec.amount_settled);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'claim amount remaining          = '||p_claim_setl_rec.amount_remaining);

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'RMA Credit Memo total amount    = '||l_rma_cm_total_amount);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'RMA Credit Memo amount          = '||l_rma_cm_line_amount);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'RMA Credit Memo tax amount      = '||l_rma_cm_tax_amount);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'RMA Credit Memo freight amount  = '||l_rma_cm_freight_amount);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '                                 ----');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Difference Amount               = '||l_difference_amount);


   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Amount Settled : ' || p_claim_setl_rec.amount_settled);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Amount Remaining : ' || p_claim_setl_rec.amount_remaining);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    RMA Total Amount : ' || l_rma_cm_total_amount);



   -- OVERPAYMENT and CHARGE claim_class cannot be settled by RMA
   IF p_claim_setl_rec.claim_class = 'CLAIM' THEN
      l_deduction_type := 'CLAIM';
   ELSIF p_claim_setl_rec.source_object_id IS NOT NULL AND
      p_claim_setl_rec.claim_class = 'DEDUCTION' THEN
      l_deduction_type := 'SOURCE_DED';
   ELSIF p_claim_setl_rec.source_object_id IS NULL AND
         p_claim_setl_rec.claim_class = 'DEDUCTION' THEN
      l_deduction_type := 'RECEIPT_DED';
   END IF;


   OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_setl_rec.claim_id
        ,x_claim_rec       => l_upd_claim_rec
        ,x_return_status   => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;


     -- ---------------------------
   -- Update Claim Tax Amount --
   -- -------------------------

   -- Bug3805485: Tax Amount Calculation
   IF ABS(l_difference_amount) > 0 AND Is_Tax_Inclusive(l_deduction_type,l_upd_claim_rec.org_id) THEN

      -- Calculate other amount and update it in claim tax_amount
      -- Bug4094251: Changed other amount calculation
      -- Bug4953844: Changed for handling inclusive tax
      IF(ABS(NVL(l_rma_cm_line_amount,0) + NVL(l_rma_cm_tax_amount,0)) = p_claim_setl_rec.amount_settled) THEN
        -- This implies tax is inclusive
        l_upd_claim_rec.tax_amount := LEAST(NVL(l_upd_claim_rec.amount_remaining,0),
                                             (l_rma_cm_freight_amount * -1));
      ELSE
         -- This implies tax is exclusive
          l_upd_claim_rec.tax_amount := LEAST(NVL(l_upd_claim_rec.amount_remaining,0),
                                  ( l_rma_cm_tax_amount + l_rma_cm_freight_amount) * -1 );
      END IF;

      --Bug7478816
      IF Abs(l_rma_cm_line_amount) <>  p_claim_setl_rec.amount_settled THEN
           l_upd_claim_rec.amount_settled :=  ABS(l_rma_cm_line_amount);
      END IF;

      l_upd_claim_rec.amount_remaining := l_upd_claim_rec.amount - l_upd_claim_rec.amount_adjusted -
                                          l_upd_claim_rec.amount_settled -
                                          l_upd_claim_rec.tax_amount;

      fnd_file.put_line(fnd_file.log, 'Tax Amount '||l_upd_claim_rec.tax_amount);
      fnd_file.put_line(fnd_file.log, 'Amount Remaning '||l_upd_claim_rec.amount_remaining);
      Update_Claim_Tax_Amount(
          p_claim_rec         => l_upd_claim_rec
         ,x_return_status     => l_return_status
         ,x_msg_data          => x_msg_data
         ,x_msg_count         => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;

   /* Bug4087329: Write off for deductions and overpayments if within threshold */
   l_write_off_flag := FALSE;
   IF  NVL(TO_NUMBER(g_writeoff_threshold), 0) >= ABS(l_upd_claim_rec.amount_remaining) AND
        ( l_deduction_type in ( 'SOURCE_DED', 'RECEIPT_OPM') OR
        ( l_deduction_type = 'RECEIPT_DED'   AND
                         ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed ) )
   THEN
               l_write_off_flag := TRUE;
   END IF;


   -- -----------------------------------------------
   -- Split Claim : if there is difference amount  --
   -- -----------------------------------------------
   IF NOT l_write_off_flag AND l_upd_claim_rec.amount_remaining > 0 THEN
      OZF_AR_PAYMENT_PVT.Query_Claim(
          p_claim_id        => p_claim_setl_rec.claim_id
         ,x_claim_rec       => l_claim_rec
         ,x_return_status   => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      Split_Claim_Settlement(
         p_claim_rec             => l_claim_rec
        ,p_difference_amount     => l_claim_rec.amount_remaining
        ,x_return_status         => l_return_status
        ,x_msg_data              => x_msg_data
        ,x_msg_count             => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      fnd_file.put_line(fnd_file.log, 'Amount Remaning '||l_claim_rec.amount_remaining);
      fnd_file.put_line(fnd_file.log, ' Amount Remaining --> Split');

   END IF;

   -- re-query claim here because amount_remaining is changed
   OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_setl_rec.claim_id
        ,x_claim_rec       => l_claim_rec
        ,x_return_status   => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Bug3951827: Settlement Amount is recalculated.
   -- Bug4365819: Calculate settlement amount before write off
   l_settlement_amount :=( NVL(l_claim_rec.amount_settled, 0) +  NVL(l_claim_rec.tax_amount, 0)) ;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Recalculated Settlement Amount = '||l_settlement_amount);


   -- -----------------------------------------------
   -- Bug4087329: Write Off
   -- -----------------------------------------------
   IF l_write_off_flag AND l_claim_rec.amount_remaining > 0 THEN


      Create_Write_Off(
         p_claim_rec             => l_claim_rec
        ,p_customer_trx_id       => l_claim_rec.source_object_id
        ,p_deduction_type        => l_deduction_type
        ,p_difference_amount     => l_claim_rec.amount_remaining
        ,x_claim_object_version  => l_dummy_number
        ,x_return_status         => l_return_status
        ,x_msg_data              => x_msg_data
        ,x_msg_count             => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      fnd_file.put_line(fnd_file.log, ' Amount Remaining --> Write Off ');

      -- re-query claim here because amount_remaining is changed
      OZF_AR_PAYMENT_PVT.Query_Claim(
         p_claim_id        => p_claim_setl_rec.claim_id
        ,x_claim_rec       => l_claim_rec
        ,x_return_status   => l_return_status
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
        END IF;

   END IF;


   --------------- CLAIM ---------------
   IF p_claim_setl_rec.claim_class = 'CLAIM' THEN
      Update_Claim_From_Settlement(
            p_api_version_number    => l_api_version,
            p_init_msg_list         => FND_API.g_false,
            p_commit                => FND_API.g_false,
            p_validation_level      => FND_API.g_valid_level_full,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_claim_id              => p_claim_setl_rec.claim_id,
            p_object_version_number => p_claim_setl_rec.object_version_number,
            p_status_code           => 'CLOSED',
            p_payment_status        => 'PAID'
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


   --------------- DEDUCTION ---------------
   ELSIF p_claim_setl_rec.claim_class = 'DEDUCTION' AND l_invoice_trx_id IS NULL THEN
      /* Settlement by on account credit memo */


      IF l_deduction_type = 'SOURCE_DED' THEN
         OZF_CLAIM_SETTLEMENT_PVT.Check_Transaction_Balance(
             p_customer_trx_id        => l_claim_rec.source_object_id
            ,p_claim_amount           => l_settlement_amount
            ,p_claim_number           => l_claim_rec.claim_number
            ,x_return_status          => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            l_inv_bal_error := TRUE;
            OZF_UTILITY_PVT.write_conc_log;

            --Raise exception to allow for rollback of split
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;

      IF NOT l_inv_bal_error THEN
         OZF_AR_PAYMENT_PVT.Pay_by_Credit_Memo(
                p_claim_rec              => l_claim_rec
               ,p_deduction_type         => l_deduction_type
               ,p_payment_reference_id   => p_settlement_doc_tbl(1).settlement_id
               ,p_credit_memo_amount     => l_settlement_amount
               ,x_return_status          => l_return_status
               ,x_msg_data               => x_msg_data
               ,x_msg_count              => x_msg_count
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF; -- end of if not invoice balance error


   --------------- DEDUCTION ---------------
   ELSIF p_claim_setl_rec.claim_class = 'DEDUCTION' AND l_invoice_trx_id IS NOT NULL THEN
      /* Bug3951827: Settlement by invoice credit memo */

      OZF_AR_PAYMENT_PVT.Pay_by_RMA_Inv_CM(
                p_claim_rec              => l_claim_rec
               ,p_credit_memo_amount     => l_settlement_amount
               ,x_return_status          => l_return_status
               ,x_msg_data               => x_msg_data
               ,x_msg_count              => x_msg_count
         );
     IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
     END IF;

   END IF;


   FND_FILE.PUT_LINE(FND_FILE.LOG, p_claim_setl_rec.claim_number||' --> Success.');
   FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||p_claim_setl_rec.claim_number||' -------------*/');

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
      FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Process_RMA_settlement;


---------------------------------------------------------------------
-- FUNCTION
--    Get_claim_csr
--
-- PURPOSE
--    This procedure maps generates the sql statement based on the input parameters.
--
-- PARAMETERS
--    p_claim_class        : claim_class
--    p_payment_method     : settlement method
--    p_cust_account_id    : customer id
--    p_claim_type_id      : claim type id
--    p_reason_code_id     : reason code id
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_claim_csr(
--     p_payment_method_stmt    IN VARCHAR2
     p_payment_method_tbl     IN g_payment_method_tbl
    ,p_claim_class            IN VARCHAR2
    ,p_cust_account_id        IN NUMBER
    ,p_claim_type_id          IN NUMBER
    ,p_reason_code_id         IN NUMBER
    ,p_payment_status         IN VARCHAR2
)
IS
l_stmt       VARCHAR2(1000);
l_cursor_id  NUMBER;
i            NUMBER;
BEGIN

  FND_DSQL.init;

  FND_DSQL.add_text('SELECT claim_id, claim_number, object_version_number, claim_class, amount_remaining, amount_settled, source_object_id, payment_method ');
  FND_DSQL.add_text('FROM ozf_claims ');
  FND_DSQL.add_text('WHERE status_code = ''PENDING_CLOSE'' ');

  i := p_payment_method_tbl.FIRST;
  IF i IS NOT NULL THEN
     FND_DSQL.add_text(' AND ( ');
     LOOP
        FND_DSQL.add_text(' payment_method = ');
        FND_DSQL.add_bind(p_payment_method_tbl(i));
        EXIT WHEN i = p_payment_method_tbl.LAST;
        i:=p_payment_method_tbl.NEXT(i);
        FND_DSQL.add_text(' OR ');
     END LOOP;
    FND_DSQL.add_text(' ) ');
  END IF;

  IF p_payment_status IS NOT NULL THEN
     FND_DSQL.add_text(' AND payment_status = ');
     FND_DSQL.add_bind(p_payment_status);
  END IF;


  IF p_claim_class IS NOT NULL THEN
     FND_DSQL.add_text(' AND claim_class = ');
     FND_DSQL.add_bind(p_claim_class);
  END IF;

  IF p_cust_account_id IS NOT NULL THEN
     FND_DSQL.add_text(' AND cust_account_id = ');
     FND_DSQL.add_bind(p_cust_account_id);
  END IF;

  IF p_claim_type_id IS NOT NULL THEN
     FND_DSQL.add_text(' AND claim_type_id = ');
     FND_DSQL.add_bind(p_claim_type_id);
  END IF;

  IF p_reason_code_id IS NOT NULL THEN
     FND_DSQL.add_text(' AND reason_code_id = ');
     FND_DSQL.add_bind(p_reason_code_id);
  END IF;

END Get_claim_csr;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_RMA_Settlement
--
-- HISTORY
--    11/10/2002  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Get_RMA_Settlement(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_commit                     IN   VARCHAR2,
   p_validation_level           IN   NUMBER,

   p_claim_class                IN  VARCHAR2,
   p_payment_method             IN  VARCHAR2,
   p_cust_account_id            IN  NUMBER,
   p_claim_type_id              IN  NUMBER,
   p_reason_code_id             IN  NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Get_RMA_Settlement';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);
l_failed_claims        NUMBER := 0;
l_successful_claims    NUMBER := 0;
l_reopened_claims      NUMBER := 0;

CURSOR csr_total_claim_line(cv_claim_id IN NUMBER) IS
  SELECT COUNT(claim_line_id)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_paid_claim_line(cv_claim_id IN NUMBER) IS
  SELECT COUNT(claim_line_id)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
  AND payment_status = 'PAID';

CURSOR csr_claim_lock(cv_claim_id IN NUMBER) IS
   SELECT claim_id
   FROM ozf_claims_all
   WHERE claim_id = cv_claim_id
   FOR UPDATE NOWAIT;

l_claim_lock_rec        csr_claim_lock%ROWTYPE;

l_settlement_doc_tbl    settlement_doc_tbl_type;
l_settlement_doc_rec    settlement_doc_rec_type;
l_settlement_doc_id     NUMBER;
l_upd_claim_status      BOOLEAN := FALSE;
l_deduction_type        VARCHAR2(15);
l_claim_rec             OZF_CLAIM_PVT.claim_rec_type;
l_upd_claim_rec         OZF_CLAIM_PVT.claim_rec_type;
l_cm_dm_total_amount    NUMBER;
l_difference_amount     NUMBER;
l_claim_new_obj_num     NUMBER;

l_payment_method_stmt   VARCHAR2(100);
TYPE ClaimCsrType IS REF CURSOR;
c_get_claims_csr        ClaimCsrType;
--TYPE claim_id_ver_type IS TABLE OF c_get_claims_csr%ROWTYPE
--INDEX BY BINARY_INTEGER;
l_claim_rma_fetch       OZF_CLAIM_PVT.claim_tbl_type;
l_claim_rma_setl        OZF_CLAIM_PVT.claim_tbl_type;
l_claim_setl_rec        OZF_CLAIM_PVT.claim_rec_type;
l_counter               NUMBER := 1;
l_total_claim_line      NUMBER;
l_paid_claim_line       NUMBER;

l_inv_bal_error         BOOLEAN := FALSE;
l_total_rma_cr_amount   NUMBER;
i                       NUMBER;
j                       NUMBER;
l_payment_method_tbl    g_payment_method_tbl;
l_claim_csr_stmt        VARCHAR2(1000);
l_stmt_debug            VARCHAR2(1000);
l_claim_csr_id          NUMBER;
l_claim_num_rows        NUMBER;

LOCK_EXCEPTION          EXCEPTION;

CURSOR csr_rma_status(cv_claim_id IN NUMBER) IS
  SELECT flow_status_code
    FROM oe_order_headers_all,
         ozf_claims_all
   WHERE claim_id = cv_claim_id
     AND payment_reference_id = header_id;

l_rma_status  VARCHAR2(30);



BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Get_RMA_Settlement;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME
         ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --------------------- start -----------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': start');
  END IF;

  IF p_payment_method = 'RMA' OR
     p_payment_method IS NULL THEN

  --l_payment_method_stmt := ' = ''RMA'' ';
  l_payment_method_tbl(1) := 'RMA';

  -- -----------------
  -- 1. RMA Fetch  --
  -- -----------------
  Get_claim_csr(p_payment_method_tbl  => l_payment_method_tbl
               ,p_claim_class         => p_claim_class
               ,p_cust_account_id     => p_cust_account_id
               ,p_claim_type_id       => p_claim_type_id
               ,p_reason_code_id      => p_reason_code_id
               ,p_payment_status      => 'PENDING'
  );

  l_claim_csr_id := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_claim_csr_id);
  l_claim_csr_stmt := FND_DSQL.get_text(FALSE);

  l_stmt_debug := fnd_dsql.get_text(TRUE);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY CLAIM SQL :: ' || l_stmt_debug);

  DBMS_SQL.parse(l_claim_csr_id, l_claim_csr_stmt, DBMS_SQL.native);
  DBMS_SQL.define_column(l_claim_csr_id, 1, l_claim_rec.claim_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 2, l_claim_rec.claim_number, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 3, l_claim_rec.object_version_number);
  DBMS_SQL.define_column_char(l_claim_csr_id, 4, l_claim_rec.claim_class, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
  DBMS_SQL.define_column(l_claim_csr_id, 6, l_claim_rec.amount_settled);
  DBMS_SQL.define_column(l_claim_csr_id, 7, l_claim_rec.source_object_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 8, l_claim_rec.payment_method, 15);
  FND_DSQL.do_binds;
  l_claim_num_rows := DBMS_SQL.execute(l_claim_csr_id);

  l_counter := 1;
  LOOP
    IF DBMS_SQL.fetch_rows(l_claim_csr_id) > 0 THEN

       DBMS_SQL.column_value(l_claim_csr_id, 1, l_claim_rec.claim_id);
       DBMS_SQL.column_value_char(l_claim_csr_id, 2, l_claim_rec.claim_number);
       DBMS_SQL.column_value(l_claim_csr_id, 3, l_claim_rec.object_version_number);
       DBMS_SQL.column_value_char(l_claim_csr_id, 4, l_claim_rec.claim_class);
       DBMS_SQL.column_value(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
       DBMS_SQL.column_value(l_claim_csr_id, 6, l_claim_rec.amount_settled);
       DBMS_SQL.column_value(l_claim_csr_id, 7, l_claim_rec.source_object_id);
       DBMS_SQL.column_value_char(l_claim_csr_id, 8, l_claim_rec.payment_method);

       l_claim_rma_fetch(l_counter).claim_id := l_claim_rec.claim_id;
       l_claim_rma_fetch(l_counter).claim_number := RTRIM(l_claim_rec.claim_number, ' ');
       l_claim_rma_fetch(l_counter).object_version_number := l_claim_rec.object_version_number;
       l_claim_rma_fetch(l_counter).claim_class := RTRIM(l_claim_rec.claim_class, ' ');
       l_claim_rma_fetch(l_counter).amount_remaining := l_claim_rec.amount_remaining;
       l_claim_rma_fetch(l_counter).amount_settled := l_claim_rec.amount_settled;
       l_claim_rma_fetch(l_counter).source_object_id := l_claim_rec.source_object_id;
       l_claim_rma_fetch(l_counter).payment_method := RTRIM(l_claim_rec.payment_method, ' ');

    ELSE
       EXIT;
    END IF;
    l_counter := l_counter + 1;
  END LOOP;
  DBMS_SQL.close_cursor(l_claim_csr_id);

  IF l_claim_rma_fetch.count > 0 THEN
     FOR i IN 1..l_claim_rma_fetch.count LOOP
        FND_MSG_PUB.initialize;
        BEGIN
           SAVEPOINT RMA_CR_FETCH;

           BEGIN
              OPEN csr_claim_lock(l_claim_rma_fetch(i).claim_id);
              FETCH csr_claim_lock INTO l_claim_lock_rec;
              If (csr_claim_lock%NOTFOUND) then
                    CLOSE csr_claim_lock;
                    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                    APP_EXCEPTION.RAISE_EXCEPTION;
              END IF;
              CLOSE csr_claim_lock;
           EXCEPTION
                WHEN OTHERS THEN
                   RAISE LOCK_EXCEPTION;
            END;

            -- R12: Check for RMA status. If cancelled, reopen claim.
            OPEN  csr_rma_status(l_claim_rma_fetch(i).claim_id);
            FETCH csr_rma_status INTO l_rma_status;
            CLOSE csr_rma_status;

            IF l_rma_status = 'CANCELLED' THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_fetch(i).claim_number||' --------------*/');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Claim Status is Cancelled  ' );

                 Process_Cancelled_Setl_Doc(
                                 p_claim_id        => l_claim_rma_fetch(i).claim_id
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                 END IF;
                 l_reopened_claims := l_reopened_claims + 1;

            ELSE

                  Get_AR_Rec(
                      p_claim_id           => l_claim_rma_fetch(i).claim_id,
                      p_claim_number       => l_claim_rma_fetch(i).claim_number,
                      p_payment_method     => l_claim_rma_fetch(i).payment_method,
                      p_settlement_amount  => (l_claim_rma_fetch(i).amount_remaining + l_claim_rma_fetch(i).amount_settled),
                      x_settlement_doc_tbl => l_settlement_doc_tbl,
                      x_return_status      => l_return_status
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  j := l_settlement_doc_tbl.FIRST;
                  IF j IS NOT NULL THEN
                      LOOP
                         IF l_settlement_doc_tbl(j).settlement_id IS NOT NULL AND
                            l_settlement_doc_tbl(j).settlement_id <> FND_API.g_miss_num THEN
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'AR Transactinn# = ' || l_settlement_doc_tbl(j).settlement_number);
                            Create_Settlement_Doc(
                                p_api_version_number => l_api_version,
                                p_init_msg_list      => FND_API.g_false,
                                p_commit             => FND_API.g_false,
                                p_validation_level   => FND_API.g_valid_level_full,
                                x_return_status      => l_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_settlement_doc_rec => l_settlement_doc_tbl(j),
                                x_settlement_doc_id  => l_settlement_doc_id
                                );
                            IF l_return_status = FND_API.g_ret_sts_error THEN
                               RAISE FND_API.g_exc_error;
                            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                               RAISE FND_API.g_exc_unexpected_error;
                            END IF;

                        -- Commented for Bug4953844
                        /*Update_Claim_Line_Status(
                                  p_claim_line_id       => l_settlement_doc_tbl(j).claim_line_id
                                 ,x_return_status       => l_return_status
                                 ,x_msg_data            => x_msg_data
                                 ,x_msg_count           => x_msg_count
                        );
                        IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF; */
                     END IF;
                     EXIT WHEN j = l_settlement_doc_tbl.LAST;
                     j := l_settlement_doc_tbl.NEXT(j);
                  END LOOP;
               END IF;

               -- Commented for Bug4953844
               /*
               OPEN csr_total_claim_line(l_claim_rma_fetch(i).claim_id);
               FETCH csr_total_claim_line INTO l_total_claim_line;
               CLOSE csr_total_claim_line;

               OPEN csr_paid_claim_line(l_claim_rma_fetch(i).claim_id);
               FETCH csr_paid_claim_line INTO l_paid_claim_line;
               CLOSE csr_paid_claim_line;

               IF l_total_claim_line = NVL(l_paid_claim_line, 0) THEN
                  UPDATE ozf_claims_all
                  SET payment_status = 'INTERFACED'
                  WHERE claim_id = l_claim_rma_fetch(i).claim_id;
               END IF; */

               -- Added for Bug4953844
               IF l_settlement_doc_tbl.COUNT <> 0 THEN
               UPDATE ozf_claims_all
                  SET payment_status = 'INTERFACED'
                WHERE claim_id = l_claim_rma_fetch(i).claim_id;

               UPDATE ozf_claim_lines_all
                  SET payment_status = 'PAID'
                WHERE claim_id = l_claim_rma_fetch(i).claim_id;
               END IF;
           END IF; -- end if l_claim_rma_fetch.claim_id is not null and g_miss_num

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO RMA_CR_FETCH;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_fetch(i).claim_number||' --> Failed in Fetch.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_fetch(i).claim_number||' --------------*/');

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO RMA_CR_FETCH;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_fetch(i).claim_number||' --> Failed in Fetch.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_fetch(i).claim_number||' --------------*/');

           WHEN OTHERS THEN
              ROLLBACK TO RMA_CR_FETCH;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_fetch(i).claim_number||' --> Failed in Fetch.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_fetch(i).claim_number||' --------------*/');

        END;
     END LOOP;
  END IF; -- end if l_claim_rma_fetch.count > 0

  -- ---------------------
  -- 2. RMA Settlement --
  -- ---------------------
  Get_claim_csr(p_payment_method_tbl  => l_payment_method_tbl
               ,p_claim_class         => p_claim_class
               ,p_cust_account_id     => p_cust_account_id
               ,p_claim_type_id       => p_claim_type_id
               ,p_reason_code_id      => p_reason_code_id
               ,p_payment_status      => 'INTERFACED'
  );

  l_claim_csr_id := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_claim_csr_id);
  l_claim_csr_stmt := FND_DSQL.get_text(FALSE);

  l_stmt_debug := fnd_dsql.get_text(TRUE);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY CLAIM SQL :: ' || l_stmt_debug);

  DBMS_SQL.parse(l_claim_csr_id, l_claim_csr_stmt, DBMS_SQL.native);
  DBMS_SQL.define_column(l_claim_csr_id, 1, l_claim_rec.claim_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 2, l_claim_rec.claim_number, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 3, l_claim_rec.object_version_number);
  DBMS_SQL.define_column_char(l_claim_csr_id, 4, l_claim_rec.claim_class, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
  DBMS_SQL.define_column(l_claim_csr_id, 6, l_claim_rec.amount_settled);
  DBMS_SQL.define_column(l_claim_csr_id, 7, l_claim_rec.source_object_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 8, l_claim_rec.payment_method, 15);
  FND_DSQL.do_binds;
  l_claim_num_rows := DBMS_SQL.execute(l_claim_csr_id);

  l_counter := 1;
  LOOP
    IF DBMS_SQL.fetch_rows(l_claim_csr_id) > 0 THEN

       DBMS_SQL.column_value(l_claim_csr_id, 1, l_claim_rec.claim_id);
       DBMS_SQL.column_value_char(l_claim_csr_id, 2, l_claim_rec.claim_number);
       DBMS_SQL.column_value(l_claim_csr_id, 3, l_claim_rec.object_version_number);
       DBMS_SQL.column_value_char(l_claim_csr_id, 4, l_claim_rec.claim_class);
       DBMS_SQL.column_value(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
       DBMS_SQL.column_value(l_claim_csr_id, 6, l_claim_rec.amount_settled);
       DBMS_SQL.column_value(l_claim_csr_id, 7, l_claim_rec.source_object_id);
       DBMS_SQL.column_value_char(l_claim_csr_id, 8, l_claim_rec.payment_method);

       l_claim_rma_setl(l_counter).claim_id := l_claim_rec.claim_id;
       l_claim_rma_setl(l_counter).claim_number := RTRIM(l_claim_rec.claim_number, ' ');
       l_claim_rma_setl(l_counter).object_version_number := l_claim_rec.object_version_number;
       l_claim_rma_setl(l_counter).claim_class := RTRIM(l_claim_rec.claim_class, ' ');
       l_claim_rma_setl(l_counter).amount_remaining := l_claim_rec.amount_remaining;
       l_claim_rma_setl(l_counter).amount_settled := l_claim_rec.amount_settled;
       l_claim_rma_setl(l_counter).source_object_id := l_claim_rec.source_object_id;
       l_claim_rma_setl(l_counter).payment_method := RTRIM(l_claim_rec.payment_method, ' ');

    ELSE
       EXIT;
    END IF;
    l_counter := l_counter + 1;
  END LOOP;
  DBMS_SQL.close_cursor(l_claim_csr_id);

  IF l_claim_rma_setl.count > 0 THEN
     FOR i IN 1..l_claim_rma_setl.count LOOP
        FND_MSG_PUB.initialize;
        BEGIN
           SAVEPOINT RMA_SETL;

           IF l_claim_rma_setl(i).claim_id IS NOT NULL AND
              l_claim_rma_setl(i).claim_id <> FND_API.g_miss_num THEN

              BEGIN
                OPEN csr_claim_lock(l_claim_rma_setl(i).claim_id);
                FETCH csr_claim_lock INTO l_claim_lock_rec;
                If (csr_claim_lock%NOTFOUND) then
                    CLOSE csr_claim_lock;
                    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                    APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                CLOSE csr_claim_lock;
              EXCEPTION
                WHEN OTHERS THEN
                   RAISE LOCK_EXCEPTION;
              END;

              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_setl(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Claim Number : ' || l_claim_rma_setl(i).claim_number);

              Get_RMA_Setl_Doc_Tbl(
                  p_claim_id              => l_claim_rma_setl(i).claim_id,
                  x_settlement_doc_tbl    => l_settlement_doc_tbl,
                  x_total_rma_cr_amount   => l_total_rma_cr_amount,
                  x_return_status         => l_return_status
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
              END IF;

              OZF_AR_PAYMENT_PVT.Query_Claim(
                  p_claim_id        => l_claim_rma_setl(i).claim_id
                 ,x_claim_rec       => l_claim_setl_rec
                 ,x_return_status   => l_return_status
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;

              --------------- CLAIM / DEDUCTION :: RMA ---------------
              Process_RMA_settlement(
                   p_claim_setl_rec       => l_claim_rma_setl(i)
                  ,p_settlement_doc_tbl   => l_settlement_doc_tbl
                  ,p_total_rma_cr_amount  => l_total_rma_cr_amount
                  ,x_return_status        => l_return_status
                  ,x_msg_count            => x_msg_count
                  ,x_msg_data             => x_msg_data
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Success. ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_successful_claims := l_successful_claims + 1;
           END IF; -- end if l_claim_rma_setl.claim_id is not null and g_miss_num
        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO RMA_SETL;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_setl(i).claim_number||' --> Failed in Settlement.');
              --OZF_UTILITY_PVT.debug_message(l_claim_rma_setl(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_setl(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO RMA_SETL;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_setl(i).claim_number||' --> Failed in Settlement.');
              --OZF_UTILITY_PVT.debug_message(l_claim_rma_setl(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_setl(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;

           WHEN OTHERS THEN
              ROLLBACK TO RMA_SETL;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_rma_setl(i).claim_number||' --> Failed in Settlement.');
              --OZF_UTILITY_PVT.debug_message(l_claim_rma_setl(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_rma_setl(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || SQLCODE || ' : ' || SQLERRM);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;

        END;
     END LOOP;
  END IF; -- end if l_claim_rma_setl.count > 0

  END IF;

  --------------------- finish -----------------------
  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
  END IF;
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': end');
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims successfully fetched for RMA Settlement : ' || l_successful_claims);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims failed to be fetched for RMA Settlement : ' || l_failed_claims);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims reopened for RMA Settlement : ' || l_reopened_claims);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Get_RMA_Settlement;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for RMA Settlement Failed.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error  : ' || SQLCODE || ' : ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
End Get_RMA_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Receivable_Settlement
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Get_Receivable_Settlement(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_commit                     IN   VARCHAR2,
   p_validation_level           IN   NUMBER,

   p_claim_class                IN  VARCHAR2,
   p_payment_method             IN  VARCHAR2,
   p_cust_account_id            IN  NUMBER,
   p_claim_type_id              IN  NUMBER,
   p_reason_code_id             IN  NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Receivable_Settlement';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);
l_failed_claims        NUMBER := 0;
l_successful_claims        NUMBER := 0;

CURSOR csr_cm_dm_total_amount(cv_customer_trx_id IN NUMBER) IS
  SELECT NVL(SUM(amount_line_items_original), 0)
  ,      NVL(SUM(tax_original), 0)
  ,      NVL(SUM(freight_original), 0)
  FROM ar_payment_schedules
  WHERE customer_trx_id = cv_customer_trx_id;

CURSOR csr_sum_line_amount(cv_claim_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_claim_lock(cv_claim_id IN NUMBER) IS
   SELECT *
   FROM ozf_claims_all
   WHERE claim_id = cv_claim_id
   FOR UPDATE NOWAIT;

l_claim_lock_rec        csr_claim_lock%ROWTYPE;

l_settlement_doc_tbl    settlement_doc_tbl_type;
l_settlement_doc_rec    settlement_doc_rec_type;
l_settlement_doc_id     NUMBER;
l_upd_claim_status      BOOLEAN := FALSE;
l_deduction_type        VARCHAR2(15);
l_claim_rec             OZF_CLAIM_PVT.claim_rec_type;
l_upd_claim_rec         OZF_CLAIM_PVT.claim_rec_type;
l_cm_dm_total_amount    NUMBER;
l_cm_dm_amount          NUMBER;
l_cm_dm_tax_amount      NUMBER;
l_cm_dm_freight_amount  NUMBER;
l_difference_amount     NUMBER;
l_claim_new_obj_num     NUMBER;

l_payment_method_stmt   VARCHAR2(100);
TYPE ClaimCsrType IS REF CURSOR;
c_get_claims_csr        ClaimCsrType;
--TYPE claim_id_ver_type IS TABLE OF c_get_claims_csr%ROWTYPE
--INDEX BY BINARY_INTEGER;
l_claim_id_ver          OZF_CLAIM_PVT.claim_tbl_type;
l_counter               NUMBER := 1;

l_inv_bal_error         BOOLEAN := FALSE;
l_payment_method_tbl    g_payment_method_tbl;
l_claim_csr_stmt        VARCHAR2(1000);
l_stmt_debug            VARCHAR2(1000);
l_claim_csr_id          NUMBER;
l_claim_num_rows        NUMBER;
l_dummy_number          NUMBER;

LOCK_EXCEPTION          EXCEPTION;
l_write_off_flag        BOOLEAN;


BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Get_Receivable_Settlement;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME
         ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --------------------- start -----------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': start');
  END IF;

  IF p_payment_method IS NULL THEN
       l_payment_method_tbl(1) := 'CREDIT_MEMO';
       l_payment_method_tbl(2) := 'DEBIT_MEMO';
  ELSE
       l_payment_method_tbl(1) := p_payment_method;
  END IF;

  Get_claim_csr(p_payment_method_tbl     => l_payment_method_tbl
                  ,p_claim_class            => p_claim_class
                  ,p_cust_account_id        => p_cust_account_id
                  ,p_claim_type_id          => p_claim_type_id
                  ,p_reason_code_id         => p_reason_code_id
                  ,p_payment_status         => 'INTERFACED'
  );

  l_claim_csr_id := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_claim_csr_id);
  l_claim_csr_stmt := FND_DSQL.get_text(FALSE);

  l_stmt_debug := fnd_dsql.get_text(TRUE);

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY CLAIM SQL :: ' || l_stmt_debug);

  DBMS_SQL.parse(l_claim_csr_id, l_claim_csr_stmt, DBMS_SQL.native);
  DBMS_SQL.define_column(l_claim_csr_id, 1, l_claim_rec.claim_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 2, l_claim_rec.claim_number, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 3, l_claim_rec.object_version_number);
  DBMS_SQL.define_column_char(l_claim_csr_id, 4, l_claim_rec.claim_class, 30);
  DBMS_SQL.define_column(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
  DBMS_SQL.define_column(l_claim_csr_id, 6, l_claim_rec.amount_settled);
  DBMS_SQL.define_column(l_claim_csr_id, 7, l_claim_rec.source_object_id);
  DBMS_SQL.define_column_char(l_claim_csr_id, 8, l_claim_rec.payment_method, 15);

  FND_DSQL.do_binds;
  l_claim_num_rows := DBMS_SQL.execute(l_claim_csr_id);

  l_counter := 1;
  LOOP
       IF DBMS_SQL.fetch_rows(l_claim_csr_id) > 0 THEN

          DBMS_SQL.column_value(l_claim_csr_id, 1, l_claim_rec.claim_id);
          DBMS_SQL.column_value_char(l_claim_csr_id, 2, l_claim_rec.claim_number);
          DBMS_SQL.column_value(l_claim_csr_id, 3, l_claim_rec.object_version_number);
          DBMS_SQL.column_value_char(l_claim_csr_id, 4, l_claim_rec.claim_class);
          DBMS_SQL.column_value(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
          DBMS_SQL.column_value(l_claim_csr_id, 6, l_claim_rec.amount_settled);
          DBMS_SQL.column_value(l_claim_csr_id, 7, l_claim_rec.source_object_id);
          DBMS_SQL.column_value_char(l_claim_csr_id, 8, l_claim_rec.payment_method);

          l_claim_id_ver(l_counter).claim_id := l_claim_rec.claim_id;
          l_claim_id_ver(l_counter).claim_number := RTRIM(l_claim_rec.claim_number, ' ');
          l_claim_id_ver(l_counter).object_version_number := l_claim_rec.object_version_number;
          l_claim_id_ver(l_counter).claim_class := RTRIM(l_claim_rec.claim_class, ' ');
          l_claim_id_ver(l_counter).amount_remaining := l_claim_rec.amount_remaining;
          l_claim_id_ver(l_counter).amount_settled := l_claim_rec.amount_settled;
          l_claim_id_ver(l_counter).source_object_id := l_claim_rec.source_object_id;
          l_claim_id_ver(l_counter).payment_method := RTRIM(l_claim_rec.payment_method, ' ');

       ELSE
          EXIT;
       END IF;
       l_counter := l_counter + 1;
  END LOOP;
  DBMS_SQL.close_cursor(l_claim_csr_id);


  IF l_claim_id_ver.count > 0 THEN
     FOR i IN 1..l_claim_id_ver.count LOOP
        FND_MSG_PUB.initialize;
        l_inv_bal_error := FALSE;
        l_deduction_type := NULL;
        BEGIN
           SAVEPOINT AR_SETTLEMENT;

           IF l_claim_id_ver(i).claim_id IS NOT NULL AND
              l_claim_id_ver(i).claim_id <> FND_API.g_miss_num THEN
              BEGIN
                OPEN csr_claim_lock(l_claim_id_ver(i).claim_id);
                FETCH csr_claim_lock INTO l_claim_lock_rec;
                If (csr_claim_lock%NOTFOUND) then
                    CLOSE csr_claim_lock;
                    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
                    APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                CLOSE csr_claim_lock;
              EXCEPTION
                WHEN OTHERS THEN
                   RAISE LOCK_EXCEPTION;
              END;

              Get_AR_Rec(
                  p_claim_id           => l_claim_id_ver(i).claim_id,
                  p_claim_number       => l_claim_id_ver(i).claim_number,
                  p_payment_method     => l_claim_id_ver(i).payment_method,
                  p_settlement_amount  => (l_claim_id_ver(i).amount_remaining + l_claim_id_ver(i).amount_settled),
                  x_settlement_doc_tbl => l_settlement_doc_tbl,
                  x_return_status      => l_return_status
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
              END IF;

              IF l_settlement_doc_tbl.count > 0 THEN

                 FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- '||l_claim_id_ver(i).claim_number||' --------------');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Claim Number : ' || l_claim_id_ver(i).claim_number);

                 -- ----------------
                 -- 1. Query Claim
                 -- ----------------
                 OZF_AR_PAYMENT_PVT.Query_Claim(
                        p_claim_id        => l_claim_id_ver(i).claim_id
                       ,x_claim_rec       => l_claim_rec
                       ,x_return_status   => l_return_status
                 );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                       RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                 END IF;

                 -- ---------------------------
                 -- 2. Classify Deduction Type
                 -- ---------------------------
                 IF l_claim_rec.claim_class = 'CLAIM' THEN
                       l_deduction_type := 'CLAIM';
                 ELSIF l_claim_rec.claim_class = 'CHARGE' THEN
                       l_deduction_type := 'CHARGE';
                 ELSIF l_claim_rec.claim_class = 'DEDUCTION' THEN
                       IF l_claim_rec.source_object_class IS NULL AND
                          l_claim_rec.source_object_id IS NULL THEN
                          l_deduction_type := 'RECEIPT_DED';
                          IF OZF_DEBUG_HIGH_ON THEN
                             OZF_Utility_PVT.debug_message('Non-Invoice Deduction');
                          END IF;
                       ELSE
                          l_deduction_type := 'SOURCE_DED';
                          IF OZF_DEBUG_HIGH_ON THEN
                             OZF_Utility_PVT.debug_message('Invoice Deduction : invoice_id ='||l_claim_id_ver(i).source_object_id);
                          END IF;
                       END IF;
                 ELSIF l_claim_rec.claim_class = 'OVERPAYMENT' THEN
                       IF l_claim_rec.source_object_class IS NULL AND
                          l_claim_rec.source_object_id IS NULL THEN
                          l_deduction_type := 'RECEIPT_OPM';
                          IF OZF_DEBUG_HIGH_ON THEN
                             OZF_Utility_PVT.debug_message('Overpayment');
                          END IF;
                       ELSE
                          l_deduction_type := 'SOURCE_OPM';
                       END IF;
                 END IF;

                 -- -------------------------------
                 -- 3. Identify Credit Memo Amount
                 -- -------------------------------
                 OPEN csr_cm_dm_total_amount(l_settlement_doc_tbl(1).settlement_id);
                 FETCH csr_cm_dm_total_amount INTO l_cm_dm_amount, l_cm_dm_tax_amount, l_cm_dm_freight_amount;
                 CLOSE csr_cm_dm_total_amount;

                 l_cm_dm_total_amount := l_cm_dm_amount + l_cm_dm_tax_amount + l_cm_dm_freight_amount;

                 l_difference_amount := l_claim_rec.amount_settled + l_cm_dm_total_amount;

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'claim amount settled             = '||l_claim_rec.amount_settled);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'claim amount remaining           = '||l_claim_rec.amount_remaining);

                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit/Debit Memo total amount   = '||l_cm_dm_total_amount);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit/Debit Memo line amount    = '||l_cm_dm_amount);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit/Debit Memo tax amount     = '||l_cm_dm_tax_amount);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Credit/Debit Memo freight amount = '||l_cm_dm_freight_amount);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, '                                  ----');
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Difference Amount                = '||l_difference_amount);


                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Amount Settled : ' || l_claim_rec.amount_settled);
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Amount Remaining : ' || l_claim_rec.amount_remaining);
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Credit/Debit Amount : ' || l_cm_dm_total_amount);

                 -- Bug3805485: Tax Amount Calculation
                 IF ABS(l_difference_amount) > 0 AND Is_Tax_Inclusive(l_deduction_type,l_claim_rec.org_id)  THEN

                          -- Calculate other amount and update it in claim tax_amount
                          -- Bug4087329: Changed Tax Amount Calculation.
                          IF l_deduction_type IN ('RECEIPT_OPM', 'CHARGE') THEN
                             l_claim_rec.tax_amount := GREATEST(NVL(l_claim_rec.amount_remaining,0),
                                  ( l_cm_dm_tax_amount + l_cm_dm_freight_amount) * -1 );
                          ELSE
                              l_claim_rec.tax_amount := LEAST(NVL(l_claim_rec.amount_remaining,0),
                                   ( l_cm_dm_tax_amount + l_cm_dm_freight_amount) * -1 );
                          END IF;

                          --Fix for Bug 7296882
                          -- Added a check for Tax code for bug fix 9135813
                          if (l_upd_claim_rec.amount <> l_upd_claim_rec.amount_settled AND l_upd_claim_rec.amount_adjusted IS NOT NULL
                              AND l_upd_claim_rec.tax_code IS NULL) then
                                        -- Fix for Bug 7418326
                                        l_upd_claim_rec.tax_amount :=0;
                          end if;

                                l_upd_claim_rec.amount_remaining := l_upd_claim_rec.amount - l_upd_claim_rec.amount_adjusted -
                                                                    l_upd_claim_rec.amount_settled -  l_upd_claim_rec.tax_amount;


                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Amount                = '||l_claim_rec.tax_amount);
                          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Remaining Amount    = '||l_claim_rec.amount_remaining);

                          Update_Claim_Tax_Amount(
                               p_claim_rec         => l_claim_rec
                              ,x_return_status     => l_return_status
                              ,x_msg_data          => x_msg_data
                              ,x_msg_count         => x_msg_count
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                             RAISE FND_API.G_EXC_ERROR;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                          END IF;

                 END IF;

                     -- Bug4087329: Write off for deductions and overpayments if within
                     -- threshold
                 l_write_off_flag := FALSE;
                 IF  NVL(TO_NUMBER(g_writeoff_threshold), 0) >= ABS(l_claim_rec.amount_remaining) AND
                     ( l_deduction_type in ( 'SOURCE_DED', 'RECEIPT_OPM')  OR
                       ( l_deduction_type = 'RECEIPT_DED' AND
                                 ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed ) )
                 THEN
                                        l_write_off_flag := TRUE;
                 END IF;

                -- ---------------------------------
                -- 5. Split Claim Settlement if needed
                -- ---------------------------------
                IF NOT l_write_off_flag AND
                       ABS(l_claim_rec.amount_remaining) > 0 THEN

                           -- re-query claim here becasue amount_remaining is changed
                           OZF_AR_PAYMENT_PVT.Query_Claim(
                                          p_claim_id        => l_claim_id_ver(i).claim_id
                                         ,x_claim_rec       => l_claim_rec
                                         ,x_return_status   => l_return_status
                           );
                           IF l_return_status = FND_API.g_ret_sts_error THEN
                             RAISE FND_API.g_exc_error;
                           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.g_exc_unexpected_error;
                           END IF;

                          Split_Claim_Settlement(
                              p_claim_rec             => l_claim_rec
                             ,p_difference_amount     => l_claim_rec.amount_remaining
                             ,x_return_status         => l_return_status
                             ,x_msg_data              => x_msg_data
                             ,x_msg_count             => x_msg_count
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                             RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                          fnd_file.put_line(fnd_file.log, 'Amount Remaning '||l_claim_rec.amount_remaining);
                          fnd_file.put_line(fnd_file.log, ' Amount Remaining --> Split');

                 END IF;

                 -- re-query claim here becasue amount_remaining is changed
                 OZF_AR_PAYMENT_PVT.Query_Claim(
                           p_claim_id        => l_claim_id_ver(i).claim_id
                           ,x_claim_rec       => l_claim_rec
                           ,x_return_status   => l_return_status
                       );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                          RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                          RAISE FND_API.g_exc_unexpected_error;
                 END IF;


                 -- Bug4087329: Settlement Amount is recalculated.
                 -- Bug4365819: Calculate settlement amount before doing a write off
                 l_settlement_doc_tbl(1).settlement_amount :=( NVL(l_claim_rec.amount_settled, 0) +
                               NVL(l_claim_rec.tax_amount, 0)) * -1 ;
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Recalculated Settlement Amount = '||l_settlement_doc_tbl(1).settlement_amount);


                     -- -----------------------------------------------
                     -- Bug4087329: Write Off
                     -- -----------------------------------------------
                     IF l_write_off_flag AND ABS(l_claim_rec.amount_remaining) > 0 THEN

                             Create_Write_Off(
                                        p_claim_rec             => l_claim_rec
                                       ,p_customer_trx_id       => l_claim_rec.source_object_id
                                       ,p_deduction_type        => l_deduction_type
                                       ,p_difference_amount     => l_claim_rec.amount_remaining
                                       ,x_claim_object_version  => l_dummy_number
                                       ,x_return_status         => l_return_status
                                       ,x_msg_data              => x_msg_data
                                       ,x_msg_count             => x_msg_count
                                        );
                             IF l_return_status = FND_API.g_ret_sts_error THEN
                                  RAISE FND_API.g_exc_error;
                             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                  RAISE FND_API.g_exc_unexpected_error;
                             END IF;

                             fnd_file.put_line(fnd_file.log, ' Amount Remaining --> Write Off ');

                                 -- re-query claim here becasue amount_remaining is changed
                             OZF_AR_PAYMENT_PVT.Query_Claim(
                                           p_claim_id        => l_claim_id_ver(i).claim_id
                                          ,x_claim_rec       => l_claim_rec
                                          ,x_return_status   => l_return_status
                                              );
                             IF l_return_status = FND_API.g_ret_sts_error THEN
                                      RAISE FND_API.g_exc_error;
                             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                      RAISE FND_API.g_exc_unexpected_error;
                             END IF;

                 END IF;


                -- ---------------------------------
                -- 5. Create the Settlement Docs
                -- ---------------------------------
                 IF l_claim_id_ver(i).claim_class IN ('DEDUCTION', 'OVERPAYMENT') AND
                    l_settlement_doc_tbl(1).settlement_id IS NOT NULL AND
                    l_settlement_doc_tbl(1).settlement_id <> FND_API.G_miss_num THEN

                    fnd_file.put_line(fnd_file.log, 'l_deduction_type '||l_deduction_type);

                    IF l_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
                       IF l_deduction_type = 'SOURCE_DED' THEN
                          OZF_CLAIM_SETTLEMENT_PVT.Check_Transaction_Balance(
                               p_customer_trx_id        => l_claim_rec.source_object_id
                              ,p_claim_amount           => (l_settlement_doc_tbl(1).settlement_amount * -1)
                              ,p_claim_number           => l_claim_rec.claim_number
                              ,x_return_status          => l_return_status
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                             l_inv_bal_error := TRUE;
                             OZF_UTILITY_PVT.write_conc_log;
                                   --Raise exception to allow for rollback of split
                             RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.g_exc_error;
                          END IF;
                       END IF;

                       IF NOT l_inv_bal_error THEN

                          fnd_file.put_line(fnd_file.log, 'Before Pay_by_Credit_Memo');
                          OZF_AR_PAYMENT_PVT.Pay_by_Credit_Memo(
                               p_claim_rec              => l_claim_rec
                              ,p_deduction_type         => l_deduction_type
                              ,p_payment_reference_id   => l_settlement_doc_tbl(1).settlement_id
                              ,p_credit_memo_amount     => (l_settlement_doc_tbl(1).settlement_amount * -1)  -- positive amount
                              ,x_return_status          => l_return_status
                              ,x_msg_data               => x_msg_data
                              ,x_msg_count              => x_msg_count
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                             RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                       END IF;

                    ELSIF l_deduction_type = 'RECEIPT_OPM' THEN

                       fnd_file.put_line(fnd_file.log, 'Before Pay_by_Debit_Memo');
                       OZF_AR_PAYMENT_PVT.Pay_by_Debit_Memo(
                            p_claim_rec              => l_claim_rec
                           ,p_deduction_type         => l_deduction_type
                           ,p_payment_reference_id   => l_settlement_doc_tbl(1).settlement_id
                           ,p_debit_memo_amount      => (l_settlement_doc_tbl(1).settlement_amount * -1)
                           ,x_return_status          => l_return_status
                           ,x_msg_data               => x_msg_data
                           ,x_msg_count              => x_msg_count
                       );
                       IF l_return_status = FND_API.g_ret_sts_error THEN
                          RAISE FND_API.g_exc_error;
                       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                          RAISE FND_API.g_exc_unexpected_error;
                       END IF;

                    END IF;

                 -- -------------------------------------------------
                 --                 CLAIM / CHARGE                 --
                 -- -------------------------------------------------
                 ELSE
                    l_upd_claim_status := FALSE;

                    FOR j IN l_settlement_doc_tbl.FIRST..l_settlement_doc_tbl.LAST LOOP
                       IF l_settlement_doc_tbl(j).settlement_id is not null AND
                          l_settlement_doc_tbl(j).settlement_id <> FND_API.g_miss_num THEN
                          l_settlement_doc_tbl(j).settlement_date := SYSDATE;
                          l_settlement_doc_tbl(j).payment_method := l_claim_rec.payment_method;

                          fnd_file.put_line(fnd_file.log, 'Before Create_Settlement_Doc');
                          Create_Settlement_Doc(
                              p_api_version_number => l_api_version,
                              p_init_msg_list      => FND_API.g_false,
                              p_commit             => FND_API.g_false,
                              p_validation_level   => FND_API.g_valid_level_full,
                              x_return_status      => l_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_settlement_doc_rec => l_settlement_doc_tbl(j),
                              x_settlement_doc_id  => l_settlement_doc_id
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                             RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                             RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                          l_upd_claim_status := TRUE;
                       END IF;
                    END LOOP;

                    IF l_upd_claim_status THEN
                       Update_Claim_From_Settlement(
                           p_api_version_number    => l_api_version,
                           p_init_msg_list         => FND_API.g_false,
                           p_commit                => FND_API.g_false,
                           p_validation_level      => FND_API.g_valid_level_full,
                           x_return_status         => l_return_status,
                           x_msg_count             => x_msg_count,
                           x_msg_data              => x_msg_data,
                           p_claim_id              => l_claim_id_ver(i).claim_id,
                           p_object_version_number => l_claim_id_ver(i).object_version_number,
                           p_status_code           => 'CLOSED',
                           p_payment_status        => 'PAID'
                       );
                       IF l_return_status = FND_API.g_ret_sts_error THEN
                          RAISE FND_API.g_exc_error;
                       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                          RAISE FND_API.g_exc_unexpected_error;
                       END IF;

                    END IF; -- end if l_upd_claim_status
                 END IF; -- end if l_claim_id_ver(i).claim_class IN ('DEDUCTION', 'OVERPAYMENT')


                 FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Success.');

                 l_successful_claims := l_successful_claims + 1;

                 FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------- '||l_claim_id_ver(i).claim_number||' ----------------');
              END IF; -- end if l_settlement_doc_tbl.count > 0
           END IF; -- end if l_claim_id_ver.claim_id is not null and g_miss_num

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO AR_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------- '||l_claim_id_ver(i).claim_number||' ----------------');

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

              l_failed_claims := l_failed_claims + 1;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO AR_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------- '||l_claim_id_ver(i).claim_number||' ----------------');

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

              l_failed_claims := l_failed_claims + 1;

           WHEN LOCK_EXCEPTION THEN
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' cannot be proceed again.');
              FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------- '||l_claim_id_ver(i).claim_number||' ----------------');

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : Claim is locked and cannot be processed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

              l_failed_claims := l_failed_claims + 1;

           WHEN OTHERS THEN
              ROLLBACK TO AR_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------- '||l_claim_id_ver(i).claim_number||' ----------------');

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || SQLCODE || ' : ' || SQLERRM);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

              l_failed_claims := l_failed_claims + 1;
        END;

     END LOOP;
  END IF; -- end if l_claim_id_ver.count > 0

  --------------------- finish -----------------------
  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': end');
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims successfully fetched for AR Settlement : ' || l_successful_claims);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims failed to be fetched for AR Settlement : ' || l_failed_claims);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Get_Receivable_Settlement;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Receivable Settlement Failed.');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error  : ' || SQLCODE || ' : ' || SQLERRM);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
End Get_Receivable_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Payable_Settlement
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Get_Payable_Settlement(
   p_api_version_number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_commit                     IN   VARCHAR2,
   p_validation_level           IN   NUMBER,

   p_claim_class                IN  VARCHAR2,
   p_payment_method             IN  VARCHAR2,
   p_cust_account_id            IN  NUMBER,
   p_claim_type_id              IN  NUMBER,
   p_reason_code_id             IN  NUMBER,

   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version_number    CONSTANT NUMBER   := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Get_Payable_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(1);
l_failed_claims         NUMBER := 0;
l_successful_claims     NUMBER := 0;
l_reopened_claims       NUMBER := 0;

CURSOR csr_settle_doc_exist(cv_settlement_id IN NUMBER) IS
  SELECT settlement_doc_id
  ,      object_version_number
  ,      settlement_amount
  ,      status_code
  FROM  ozf_settlement_docs
  WHERE settlement_id = cv_settlement_id;

l_settlement_doc_tbl    settlement_doc_tbl_type;
l_settlement_doc_rec    settlement_doc_rec_type;
l_settlement_doc_id     NUMBER;
l_total_pay_amount      NUMBER := 0;
l_settle_obj_ver        NUMBER;
l_settle_doc_id         NUMBER;
l_settle_amount         NUMBER;
l_settle_status         varchar2(30);
l_pay_clear_flag        VARCHAR2(1) := NULL;

l_payment_method_stmt   VARCHAR2(100);
TYPE ClaimCsrType IS REF CURSOR;
c_get_claims_csr        ClaimCsrType;
--TYPE claim_id_ver_type IS TABLE OF c_get_claims_csr%ROWTYPE
--INDEX BY BINARY_INTEGER;
l_claim_id_ver          OZF_CLAIM_PVT.claim_tbl_type;
l_claim_rec             OZF_CLAIM_PVT.claim_rec_type;
l_counter               NUMBER := 1;
l_invoice_amount        NUMBER;

l_payment_method_tbl    g_payment_method_tbl;
l_claim_csr_stmt        VARCHAR2(1000);
l_stmt_debug            VARCHAR2(1000);
l_claim_csr_id          NUMBER;
l_claim_num_rows        NUMBER;

-- R12: Document Cancellation
CURSOR csr_inv_status(cv_claim_id IN NUMBER) IS
  SELECT invoice_id,
         cancelled_date
    FROM ap_invoices_all ap,
         ozf_claims_all oc
   WHERE claim_id = cv_claim_id
     AND invoice_num = oc.payment_reference_number
     AND ap.vendor_id = oc.vendor_id
     AND ap.vendor_site_id = oc.vendor_site_id;
l_cancelled_date  DATE;
l_invoice_id          NUMBER;

--R12: Tax Enhancements
CURSOR csr_inv_gross_amount(cv_invoice_id IN NUMBER) IS
    SELECT invoice_amount
       FROM  ap_invoices
       WHERE invoice_id = cv_invoice_id;
l_gross_amt           NUMBER;
l_difference_amount  NUMBER;
l_settlement_amount  NUMBER;
l_tax_included_flag  BOOLEAN := FALSE;

CURSOR csr_paid_amount(cv_invoice_id IN NUMBER)  IS
  SELECT sum(pay.amount + NVL(pay.discount_taken,0))
  FROM   ap_invoice_payments_all pay
  ,      ap_invoices_all inv
  WHERE  inv.invoice_id =  pay.invoice_id
  AND    inv.invoice_id = cv_invoice_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Get_Payable_Settlement;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
            l_api_version_number,
            p_api_version_number,
            l_api_name,
            G_PKG_NAME
         ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --------------------- start -----------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': start');
  END IF;

  IF p_payment_method IN ( 'CHECK','EFT','WIRE','AP_DEFAULT','AP_DEBIT') THEN
      l_payment_method_tbl(1) := p_payment_method;
  ELSIF p_payment_method IS NULL THEN
      l_payment_method_tbl(1) := 'CHECK';
      l_payment_method_tbl(2) := 'EFT';
      l_payment_method_tbl(3) := 'WIRE';
      l_payment_method_tbl(4) := 'AP_DEFAULT';
      l_payment_method_tbl(5) := 'AP_DEBIT';
  END IF;


  ---- Get the claims to be processed
   Get_claim_csr(
         p_payment_method_tbl     => l_payment_method_tbl
        ,p_claim_class            => p_claim_class
        ,p_cust_account_id        => p_cust_account_id
        ,p_claim_type_id          => p_claim_type_id
        ,p_reason_code_id         => p_reason_code_id
        ,p_payment_status         => 'INTERFACED'
     );

   l_claim_csr_id := DBMS_SQL.open_cursor;
   FND_DSQL.set_cursor(l_claim_csr_id);
   l_claim_csr_stmt := FND_DSQL.get_text(FALSE);

   l_stmt_debug := fnd_dsql.get_text(TRUE);

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'QUERY CLAIM SQL :: ' || l_stmt_debug);

   DBMS_SQL.parse(l_claim_csr_id, l_claim_csr_stmt, DBMS_SQL.native);
   DBMS_SQL.define_column(l_claim_csr_id, 1, l_claim_rec.claim_id);
   DBMS_SQL.define_column_char(l_claim_csr_id, 2, l_claim_rec.claim_number, 30);
   DBMS_SQL.define_column(l_claim_csr_id, 3, l_claim_rec.object_version_number);
   DBMS_SQL.define_column_char(l_claim_csr_id, 4, l_claim_rec.claim_class, 30);
   DBMS_SQL.define_column(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
   DBMS_SQL.define_column(l_claim_csr_id, 6, l_claim_rec.amount_settled);
   DBMS_SQL.define_column(l_claim_csr_id, 7, l_claim_rec.source_object_id);
   DBMS_SQL.define_column_char(l_claim_csr_id, 8, l_claim_rec.payment_method, 15);
   FND_DSQL.do_binds;
   l_claim_num_rows := DBMS_SQL.execute(l_claim_csr_id);

   l_counter := 1;
   LOOP
       IF DBMS_SQL.fetch_rows(l_claim_csr_id) > 0 THEN

          DBMS_SQL.column_value(l_claim_csr_id, 1, l_claim_rec.claim_id);
          DBMS_SQL.column_value_char(l_claim_csr_id, 2, l_claim_rec.claim_number);
          DBMS_SQL.column_value(l_claim_csr_id, 3, l_claim_rec.object_version_number);
          DBMS_SQL.column_value_char(l_claim_csr_id, 4, l_claim_rec.claim_class);
          DBMS_SQL.column_value(l_claim_csr_id, 5, l_claim_rec.amount_remaining);
          DBMS_SQL.column_value(l_claim_csr_id, 6, l_claim_rec.amount_settled);
          DBMS_SQL.column_value(l_claim_csr_id, 7, l_claim_rec.source_object_id);
          DBMS_SQL.column_value_char(l_claim_csr_id, 8, l_claim_rec.payment_method);

          l_claim_id_ver(l_counter).claim_id := l_claim_rec.claim_id;
          l_claim_id_ver(l_counter).claim_number := RTRIM(l_claim_rec.claim_number, ' ');
          l_claim_id_ver(l_counter).object_version_number := l_claim_rec.object_version_number;
          l_claim_id_ver(l_counter).claim_class := RTRIM(l_claim_rec.claim_class, ' ');
          l_claim_id_ver(l_counter).amount_remaining := l_claim_rec.amount_remaining;
          l_claim_id_ver(l_counter).amount_settled := l_claim_rec.amount_settled;
          l_claim_id_ver(l_counter).source_object_id := l_claim_rec.source_object_id;
          l_claim_id_ver(l_counter).payment_method := RTRIM(l_claim_rec.payment_method, ' ');

       ELSE
          EXIT;
       END IF;
       l_counter := l_counter + 1;
   END LOOP;
  DBMS_SQL.close_cursor(l_claim_csr_id);


 -- Process individuals Claims
   FOR i IN 1..l_claim_id_ver.count LOOP

      BEGIN
           SAVEPOINT AP_SETTLEMENT;
           FND_MSG_PUB.initialize;

           FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_id_ver(i).claim_number||' --------------*/');
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Claim Number : ' || l_claim_id_ver(i).claim_number);

           -- set to 0 for next claim in loop
           l_total_pay_amount := 0;
           l_pay_clear_flag := NULL;
           l_cancelled_date := NULL;

           -- Check for document status
           OPEN   csr_inv_status( l_claim_id_ver(i).claim_id);
           FETCH  csr_inv_status INTO l_invoice_id, l_cancelled_date;
           CLOSE  csr_inv_status;

           IF l_cancelled_date IS NOT NULL THEN

                FND_FILE.PUT_LINE(FND_FILE.LOG, '    AP Document is Cancelled  ' );

                -- R12: Handle Document Cancellation
                 Process_Cancelled_Setl_Doc(
                      p_claim_id            => l_claim_id_ver(i).claim_id
                     ,x_return_status      => l_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                 END IF;

                 IF l_claim_id_ver(i).payment_method IN ( 'CHECK','EFT','WIRE','AP_DEFAULT') THEN
                     FND_FILE.PUT_LINE(FND_FILE.LOG, '    Deleting settlement docs  ' );
                     DELETE FROM ozf_settlement_docs_all
                        WHERE claim_id = l_claim_id_ver(i).claim_id;
                 END IF;
                 l_reopened_claims := l_reopened_claims + 1;

           ELSE

                 OPEN   csr_inv_gross_amount(l_invoice_id);
                 FETCH  csr_inv_gross_amount INTO l_gross_amt;
                 CLOSE  csr_inv_gross_amount;

                 OPEN   csr_paid_amount(l_invoice_id);
                 FETCH  csr_paid_amount INTO l_total_pay_amount;
                 CLOSE  csr_paid_amount;

                 IF  l_claim_id_ver(i).payment_method = 'AP_DEBIT'  AND  l_claim_rec.claim_class = 'CLAIM'  THEN
                               l_gross_amt :=  l_gross_amt * -1;
                 END IF;

                 OZF_AR_PAYMENT_PVT.Query_Claim(
                                 p_claim_id       => l_claim_id_ver(i).claim_id
                                ,x_claim_rec      => l_claim_rec
                                ,x_return_status  => l_return_status
                 );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                         RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                         RAISE FND_API.g_exc_unexpected_error;
                 END IF;


                 l_difference_amount := l_gross_amt - l_claim_rec.amount_settled ;
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Amount Settled            = '||l_claim_rec.amount_settled);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Amount Remaining          = '||l_claim_rec.amount_remaining);
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'AP Document Gross amount    = '||l_gross_amt );
                 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Difference amount    = '||l_difference_amount);

                 l_settlement_amount := l_claim_rec.amount_settled;
                 l_tax_included_flag := FALSE;
                 IF  ABS(l_difference_amount) <> 0 AND Is_Tax_Inclusive(l_claim_rec.claim_class,l_claim_rec.org_id)
                                 AND ABS(l_claim_rec.amount_remaining) > 0
                 THEN
                      l_tax_included_flag := TRUE;
                      -- invoice amount is higher then settled amount due to tax/frieght
                      IF l_claim_rec.claim_class = 'CHARGE'  THEN
                           l_settlement_amount := l_settlement_amount + GREATEST(l_claim_rec.amount_remaining, l_difference_amount);
                      ELSE
                           l_settlement_amount := l_settlement_amount + LEAST(l_claim_rec.amount_remaining, l_difference_amount  );
                      END IF;
                  END IF;


                  Get_AP_Rec(
                         p_claim_id           => l_claim_id_ver(i).claim_id,
                         p_settlement_amount  => l_settlement_amount,
                         x_settlement_doc_tbl => l_settlement_doc_tbl,
                         x_invoice_amount     => l_invoice_amount,
                         x_return_status      => l_return_status
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                         RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                         RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  IF l_settlement_doc_tbl.count > 0    AND l_settlement_doc_tbl(1).settlement_id is not null
                  THEN

                      FOR j IN l_settlement_doc_tbl.FIRST..l_settlement_doc_tbl.LAST LOOP

                           l_settle_doc_id := NULL;

                           IF l_settlement_doc_tbl(j).status_code = 'RECONCILED' THEN
                                l_pay_clear_flag := FND_API.g_true;
                           ELSE
                                l_pay_clear_flag := FND_API.g_false;
                           END IF;

                           OPEN csr_settle_doc_exist(l_settlement_doc_tbl(j).settlement_id);
                           FETCH csr_settle_doc_exist INTO l_settle_doc_id, l_settle_obj_ver
                                                     , l_settle_amount, l_settle_status;
                           CLOSE csr_settle_doc_exist;

                           IF l_settle_doc_id IS NOT NULL
                           THEN
                                  l_settlement_doc_tbl(j).settlement_doc_id := l_settle_doc_id;
                                  l_settlement_doc_tbl(j).object_version_number := l_settle_obj_ver;

                                  IF l_settle_amount <> l_settlement_doc_tbl(j).settlement_amount OR
                                     l_settle_status <> l_settlement_doc_tbl(j).status_code
                                  THEN
                                          IF OZF_DEBUG_HIGH_ON THEN
                                               OZF_UTILITY_PVT.debug_message('New Status' || l_settlement_doc_tbl(j).status_code );
                                               OZF_UTILITY_PVT.debug_message('Old Status' || l_settle_status );
                                               OZF_UTILITY_PVT.debug_message('New Amount' || l_settlement_doc_tbl(j).settlement_amount );
                                               OZF_UTILITY_PVT.debug_message('Old Amount' || l_settle_amount );
                                               OZF_UTILITY_PVT.debug_message('Updating settlement doc ');
                                          END IF;
                                          Update_Settlement_Doc(
                                           p_api_version_number     => 1.0,
                                           p_init_msg_list          => FND_API.g_false,
                                           p_commit                 => p_commit,
                                           p_validation_level       => FND_API.g_valid_level_full,
                                           x_return_status          => l_return_status,
                                           x_msg_count              => x_msg_count,
                                           x_msg_data               => x_msg_data,
                                           p_settlement_doc_rec     => l_settlement_doc_tbl(j),
                                           x_object_version_number  => l_settlement_doc_tbl(j).object_version_number
                                         );
                                         IF l_return_status = FND_API.g_ret_sts_error THEN
                                                 RAISE FND_API.g_exc_error;
                                         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                                RAISE FND_API.g_exc_unexpected_error;
                                         END IF;

                                         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Update settlement doc :: settlement_doc_id='||l_settlement_doc_tbl(j).settlement_id);
                                  END IF;
                           ELSE
                                    Create_Settlement_Doc(
                                             p_api_version_number     => 1.0,
                                             p_init_msg_list          => FND_API.g_false,
                                             p_commit                 => p_commit,
                                             p_validation_level       => FND_API.g_valid_level_full,
                                             x_return_status          => l_return_status,
                                             x_msg_count              => x_msg_count,
                                             x_msg_data               => x_msg_data,
                                             p_settlement_doc_rec     => l_settlement_doc_tbl(j),
                                             x_settlement_doc_id      => l_settlement_doc_id
                                                  );
                                     IF l_return_status = FND_API.g_ret_sts_error THEN
                                             RAISE FND_API.g_exc_error;
                                     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                            RAISE FND_API.g_exc_unexpected_error;
                                     END IF;

                                     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Create settlement doc :: settlement_doc_id = '||l_settlement_doc_id);

                            END IF; -- l_settle_doc_id IS NOT NULL

                      END LOOP;

                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice amount ='||l_invoice_amount);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total payment ='||l_total_pay_amount);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Invoice Amount : ' || l_invoice_amount);
                    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Total Payment  : ' || l_total_pay_amount);

                     ------------------------------------------------
                     --   R12: Consider Tax and Split     ------
                     ------------------------------------------------
                    IF l_claim_id_ver(i).payment_method = 'AP_DEBIT' OR l_invoice_amount <= l_total_pay_amount
                    THEN

                        IF  l_tax_included_flag THEN

                                     -- invoice amount is higher then settled amount due to tax/frieght
                             IF l_claim_rec.claim_class = 'CHARGE'  THEN
                                     l_claim_rec.tax_amount := GREATEST(l_claim_rec.amount_remaining, l_difference_amount);
                             ELSE
                                     l_claim_rec.tax_amount := LEAST(l_claim_rec.amount_remaining, l_difference_amount  );
                             END IF;
                             l_claim_rec.amount_remaining := l_claim_rec.amount -  l_claim_rec.amount_settled - l_claim_rec.amount_adjusted -
                                                                  l_claim_rec.tax_amount;

                             fnd_file.put_line(fnd_file.log, 'Tax Amount '||l_claim_rec.tax_amount);
                             fnd_file.put_line(fnd_file.log, 'Amount Remaining '||l_claim_rec.amount_remaining);
                             Update_Claim_Tax_Amount(
                                  p_claim_rec         => l_claim_rec
                                 ,x_return_status     => l_return_status
                                 ,x_msg_data          => x_msg_data
                                 ,x_msg_count         => x_msg_count
                             );
                              IF l_return_status = FND_API.g_ret_sts_error THEN
                                         RAISE FND_API.G_EXC_ERROR;
                              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                              END IF;
                       END IF;

                       -- Split Claim : if there is difference amount  --
                       IF  ABS(l_claim_rec.amount_remaining)  <> 0 THEN
                          OZF_AR_PAYMENT_PVT.Query_Claim(
                                  p_claim_id        =>  l_claim_id_ver(i).claim_id
                                 ,x_claim_rec       => l_claim_rec
                                 ,x_return_status   => l_return_status
                              );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                                 RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                 RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                         Split_Claim_Settlement(
                                 p_claim_rec             => l_claim_rec
                                ,p_difference_amount     => l_claim_rec.amount_remaining
                                ,x_return_status         => l_return_status
                                ,x_msg_data              =>  x_msg_data
                                ,x_msg_count             => x_msg_count
                          );
                          IF l_return_status = FND_API.g_ret_sts_error THEN
                                RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                 RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                          fnd_file.put_line(fnd_file.log, 'Amount Remaning '||l_claim_rec.amount_remaining);
                          fnd_file.put_line(fnd_file.log, ' Amount Remaining --> Split');
                     END IF;

                     OZF_AR_PAYMENT_PVT.Query_Claim(
                                  p_claim_id        => l_claim_id_ver(i).claim_id
                                 ,x_claim_rec       => l_claim_rec
                                 ,x_return_status   => l_return_status
                              );
                     IF l_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                     END IF;

                     --- Close Claim
                     Update_Claim_From_Settlement(
                                p_api_version_number    => l_api_version_number,
                                 p_init_msg_list        => FND_API.g_false,
                                 p_commit               => FND_API.g_false,
                                 p_validation_level     => FND_API.g_valid_level_full,
                                 x_return_status        => l_return_status,
                                 x_msg_count            => x_msg_count,
                                 x_msg_data             => x_msg_data,
                                 p_claim_id             => l_claim_rec.claim_id,
                                 p_object_version_number => l_claim_rec.object_version_number,
                                 p_status_code           => 'CLOSED',
                                 p_payment_status        => 'PAID'
                             );
                    IF l_return_status = FND_API.g_ret_sts_error THEN
                       RAISE FND_API.g_exc_error;
                        FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
                    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                       FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
                    END IF;
                    FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Success.');

                  ELSE
                     FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> is not CLOSED because amount settled is not fully paid.');
                  END IF; -- Close Claim


                 FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_id_ver(i).claim_number||' --------------*/');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Success. ');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                 l_successful_claims := l_successful_claims + 1;

              END IF; -- l_settlement_doc_tbl.count > 0
         END IF; -- Camcelled;

       EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO AP_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_id_ver(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;

           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO AP_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.LOG, '/*-------------- '||l_claim_id_ver(i).claim_number||' --------------*/');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;

           WHEN OTHERS THEN
              ROLLBACK TO AP_SETTLEMENT;
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_claim_id_ver(i).claim_number||' --> Failed.');
              OZF_UTILITY_PVT.write_conc_log;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Status : Failed.');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Error  : ' || SQLCODE || ' : ' || SQLERRM);
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
              l_failed_claims := l_failed_claims + 1;
        END;

  END LOOP;


  --------------------- finish -----------------------
  IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
  END IF;

  FND_MSG_PUB.Count_And_Get(
     p_count   =>   x_msg_count,
     p_data    =>   x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(l_full_name ||': end');
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims successfully fetched for AP Settlement : ' || l_successful_claims);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims failed to be fetched for AP Settlement : ' || l_failed_claims);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' Claims reopened for AP Settlement : ' || l_reopened_claims);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_Payable_Settlement;
    x_return_status := FND_API.g_ret_sts_error;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Payable Settlement Failed.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Payable_Settlement;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Payable Settlement Failed.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error  : ' || FND_MSG_PUB.get(FND_MSG_PUB.Count_Msg, FND_API.g_false));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Get_Payable_Settlement;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Payable Settlement Failed.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error  : ' || SQLCODE || ' : ' || SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
End Get_Payable_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Settlement_Data
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Populate_Settlement_Data(
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY NUMBER,
    p_org_id           IN  NUMBER DEFAULT NULL,
    p_claim_class      IN  VARCHAR2,
    p_payment_method   IN  VARCHAR2,
    p_cust_account_id  IN  NUMBER,
    p_claim_type_id    IN  NUMBER,
    p_reason_code_id   IN  NUMBER
)
IS
l_retcode               NUMBER := 0;

l_return_status         VARCHAR2(1) ;
l_msg_count             NUMBER;
l_msg_Data              VARCHAR2(2000);
l_claim_class_name      VARCHAR2(80);
l_settlement_method_name          VARCHAR2(80);
l_customer_name                   VARCHAR2(80);
l_claim_type_name                 VARCHAR2(50);
l_reason_name                     VARCHAR2(80);


CURSOR csr_claim_class_name(p_lkup_code IN VARCHAR2) IS
SELECT MEANING
FROM OZF_LOOKUPS
WHERE lookup_type= 'OZF_CLAIM_CLASS'
AND lookup_code = p_lkup_code;

CURSOR csr_settlement_method_name(p_lkup_code IN VARCHAR2) IS
SELECT MEANING
FROM OZF_LOOKUPS
WHERE lookup_type= 'OZF_PAYMENT_METHOD'
AND lookup_code = p_lkup_code;

CURSOR csr_customer_name(p_cust_act_id IN NUMBER) IS
SELECT SUBSTRB(PARTY.PARTY_NAME,1,50) NAME
FROM HZ_CUST_ACCOUNTS CA, HZ_PARTIES PARTY
WHERE CA.party_id = party.party_id
AND CA.CUST_ACCOUNT_ID = p_cust_act_id;

CURSOR csr_claim_type_name(p_claim_type_id IN NUMBER) IS
SELECT NAME
FROM OZF_CLAIM_TYPES_VL
WHERE CLAIM_TYPE_ID = p_claim_type_id;

CURSOR csr_reason_name(p_reason_code_id IN NUMBER) IS
SELECT NAME
FROM OZF_REASON_CODES_VL
WHERE REASON_CODE_ID = p_reason_code_id;

--Multiorg Changes
CURSOR operating_unit_csr IS
    SELECT ou.organization_id   org_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';

m NUMBER := 0;
l_org_id     OZF_UTILITY_PVT.operating_units_tbl;

BEGIN
  SAVEPOINT  Populate_Settlement_Data;


        --Multiorg Changes
        MO_GLOBAL.init('OZF');

        IF p_org_id IS NULL THEN
                MO_GLOBAL.set_policy_context('M',null);
                OPEN operating_unit_csr;
                LOOP
                   FETCH operating_unit_csr into l_org_id(m);
                   m := m + 1;
                   EXIT WHEN operating_unit_csr%NOTFOUND;
                END LOOP;
                CLOSE operating_unit_csr;
        ELSE
                l_org_id(m) := p_org_id;
        END IF;

        --Multiorg Changes
        IF (l_org_id.COUNT > 0) THEN
                FOR m IN l_org_id.FIRST..l_org_id.LAST LOOP
                   MO_GLOBAL.set_policy_context('S',l_org_id(m));
           -- Write OU info to OUT file
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '-----------------------------------------------------');
           -- Write OU info to LOG file
           FND_FILE.PUT_LINE(FND_FILE.LOG,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
           FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------');

                        IF p_claim_class IS NOT NULL THEN
                           OPEN csr_claim_class_name(p_claim_class);
                           FETCH csr_claim_class_name INTO l_claim_class_name;
                           CLOSE csr_claim_class_name;
                        END IF;
                        IF p_payment_method IS NOT NULL THEN
                           OPEN csr_settlement_method_name(p_payment_method);
                           FETCH csr_settlement_method_name INTO l_settlement_method_name;
                           CLOSE csr_settlement_method_name;
                        END IF;
                        IF p_cust_account_id IS NOT NULL THEN
                           OPEN csr_customer_name(p_cust_account_id);
                           FETCH csr_customer_name INTO l_customer_name;
                           CLOSE csr_customer_name;
                        END IF;
                        IF p_claim_type_id IS NOT NULL THEN
                           OPEN csr_claim_type_name(p_claim_type_id);
                           FETCH csr_claim_type_name INTO l_claim_type_name;
                           CLOSE csr_claim_type_name;
                        END IF;
                        IF p_reason_code_id IS NOT NULL THEN
                           OPEN csr_reason_name(p_reason_code_id);
                           FETCH csr_reason_name INTO l_reason_name;
                           CLOSE csr_reason_name;
                        END IF;

                        FND_FILE.PUT_LINE(FND_FILE.LOG, '===== START: fetching AR settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =====');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------ Claims Settlement Fetcher Execution Report -------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Claim Class', 40, ' ') || ': ' || l_claim_class_name);
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Settlement Method', 40, ' ') || ': ' || l_settlement_method_name);
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Customer', 40, ' ') || ': ' || l_customer_name);
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Claim Type', 40, ' ') || ': ' || l_claim_type_name);
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Reason Code', 40, ' ') || ': ' || l_reason_name);
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Receivable Settlement : ');

           IF p_payment_method IS NULL OR p_payment_method IN ( 'CREDIT_MEMO', 'DEBIT_MEMO') THEN
                  Get_Receivable_Settlement(
                        p_api_version_number  => 1.0,
                        p_init_msg_list       => FND_API.g_false,
                        p_commit              => FND_API.g_false,
                        p_validation_level    => FND_API.g_valid_level_full,

                        p_claim_class         => p_claim_class,
                        p_payment_method      => p_payment_method,
                        p_cust_account_id     => p_cust_account_id,
                        p_claim_type_id       => p_claim_type_id,
                        p_reason_code_id      => p_reason_code_id,

                        x_return_status       => l_return_status,
                        x_msg_count           => l_msg_count,
                        x_msg_data            => l_msg_data
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                          FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_AR_FETCH_ERR');
                          FND_MSG_PUB.add;
                        END IF;
                        RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===== END: fetching AR settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =======');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for Account Payable Settlement : ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===== START: fetching AP settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =====');
                  --OZF_UTILITY_PVT.debug_message('== START: fetching AP settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
          END IF;

          IF p_payment_method IS NULL OR p_payment_method IN ( 'CHECK','EFT','WIRE','AP_DEFAULT','AP_DEBIT') THEN
                  Get_Payable_Settlement(
                        p_api_version_number  => 1.0,
                        p_init_msg_list       => FND_API.g_false,
                        p_commit              => FND_API.g_false,
                        p_validation_level    => FND_API.g_valid_level_full,

                        p_claim_class         => p_claim_class,
                        p_payment_method      => p_payment_method,
                        p_cust_account_id     => p_cust_account_id,
                        p_claim_type_id       => p_claim_type_id,
                        p_reason_code_id      => p_reason_code_id,

                        x_return_status       => l_return_status,
                        x_msg_count           => l_msg_count,
                        x_msg_data            => l_msg_data
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                          FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_AP_FETCH_ERR');
                          FND_MSG_PUB.add;
                        END IF;
                        RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===== END: fetching AP settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =======');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Fetching for RMA Settlement : ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===== START: fetching RMA settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =====');
                  END IF;

          IF p_payment_method IS NULL OR p_payment_method = 'RMA' THEN
                  Get_RMA_Settlement(
                        p_api_version_number  => 1.0,
                        p_init_msg_list       => FND_API.g_false,
                        p_commit              => FND_API.g_false,
                        p_validation_level    => FND_API.g_valid_level_full,

                        p_claim_class         => p_claim_class,
                        p_payment_method      => p_payment_method,
                        p_cust_account_id     => p_cust_account_id,
                        p_claim_type_id       => p_claim_type_id,
                        p_reason_code_id      => p_reason_code_id,

                        x_return_status       => l_return_status,
                        x_msg_count           => l_msg_count,
                        x_msg_data            => l_msg_data
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                          FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_AR_FETCH_ERR');
                          FND_MSG_PUB.add;
                        END IF;
                        RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  /*
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'OZF_RETURN_STATUS ');
                  END IF;
                  */

                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===== END: fetching RMA settlement -- time stamp :: '||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS')||' =======');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
         END IF;

                  --OZF_UTILITY_PVT.write_conc_log;
           END LOOP;
        END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Populate_Settlement_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || l_msg_data ||')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Populate_Settlement_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || l_msg_data ||')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

  WHEN OTHERS THEN
    ROLLBACK TO Populate_Settlement_Data;
    OZF_UTILITY_PVT.write_conc_log;
    ERRBUF  := substr(sqlerrm, 1, 80);
    RETCODE := 2;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

End Populate_Settlement_Data;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Settlement_Doc
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Create_Settlement_Doc(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_validation_level      IN   NUMBER,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_settlement_doc_rec    IN   settlement_doc_rec_type  := g_miss_settlement_doc_rec,
    x_settlement_doc_id     OUT NOCOPY  NUMBER
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Create_Settlement_Doc';
l_full_name     CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);

l_created_by             NUMBER;
l_updated_by             NUMBER;
l_last_update_login      NUMBER;
l_org_id                 NUMBER;

l_settlement_doc_rec     settlement_doc_rec_type := p_settlement_doc_rec;
l_id_count               NUMBER;

CURSOR c_settlement_doc_seq IS
  SELECT ozf_settlement_docs_all_s.NEXTVAL
  FROM DUAL;

CURSOR c_id_exists(cv_id IN NUMBER) IS
  SELECT  COUNT(settlement_doc_id)
  FROM  ozf_settlement_docs_all
  WHERE settlement_doc_id = cv_id;

CURSOR csr_claim_currency(cv_claim_id IN NUMBER) IS
  SELECT set_of_books_id,
         currency_code,
         exchange_rate_date,
         exchange_rate_type,
         exchange_rate,
         org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;
l_claim_rec csr_claim_currency%ROWTYPE;
l_exchange_rate NUMBER;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Settlement_Doc;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         G_PKG_NAME
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  l_created_by := NVL(FND_GLOBAL.user_id,-1);
  l_updated_by := NVL(FND_GLOBAL.user_id,-1);
  l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);
  l_settlement_doc_rec.object_version_number := 1;

  --------------------- validate -----------------------
  -- Validate Environment
  IF FND_GLOBAL.user_Id IS NULL THEN
    OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_USER_PROFILE_MISSING');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( P_validation_level >= FND_API.g_valid_level_full) THEN
    Validate_Settlement_Doc(
      p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_FALSE,
      p_validation_level    => p_validation_level,
      p_settlement_doc_rec  => p_settlement_doc_rec,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
    );
    IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  OPEN csr_claim_currency(l_settlement_doc_rec.claim_id);
  FETCH csr_claim_currency INTO l_claim_rec;
  CLOSE csr_claim_currency;

  -------------------- Amount Rounding -----------------------
  IF l_settlement_doc_rec.settlement_amount IS NOT NULL THEN
    l_settlement_doc_rec.settlement_amount := OZF_UTILITY_PVT.CurrRound(l_settlement_doc_rec.settlement_amount, l_claim_rec.currency_code);
    -- Calculate Accounted Amount
    OZF_UTILITY_PVT.Convert_Currency(
         P_SET_OF_BOOKS_ID => l_claim_rec.set_of_books_id,
         P_FROM_CURRENCY   => l_claim_rec.currency_code,
         P_CONVERSION_DATE => l_claim_rec.exchange_rate_date,
         P_CONVERSION_TYPE => l_claim_rec.exchange_rate_type,
         P_CONVERSION_RATE => l_claim_rec.exchange_rate,
         P_AMOUNT          => l_settlement_doc_rec.settlement_amount,
         X_RETURN_STATUS   => l_return_status,
         X_ACC_AMOUNT      => l_settlement_doc_rec.settlement_acctd_amount,
         X_RATE            => l_exchange_rate
     );

     IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  -------------------------- insert --------------------------
  IF p_settlement_doc_rec.settlement_doc_id IS NULL OR
     p_settlement_doc_rec.settlement_doc_id = FND_API.G_MISS_NUM THEN
    LOOP
      -- Get the identifier
      OPEN  c_settlement_doc_seq;
      FETCH c_settlement_doc_seq INTO l_settlement_doc_rec.settlement_doc_id;
      CLOSE c_settlement_doc_seq;
      -- Check the uniqueness of the identifier
      OPEN  c_id_exists(l_settlement_doc_rec.settlement_doc_id);
      FETCH c_id_exists INTO l_id_count;
      CLOSE c_id_exists;
      -- Exit when the identifier uniqueness is established
      EXIT WHEN l_id_count = 0;
   END LOOP;
  END IF;


  if l_settlement_doc_rec.claim_line_id = FND_API.G_MISS_NUM THEN
     l_settlement_doc_rec.claim_line_id := null;
  end if;



  BEGIN
    -- Invoke table handler(OZF_SETTLEMENT_DOCS_PKG.Insert_Row)
    OZF_SETTLEMENT_DOCS_PKG.Insert_Row(
          px_settlement_doc_id      => l_settlement_doc_rec.settlement_doc_id,
          px_object_version_number  => l_settlement_doc_rec.object_version_number,
          p_last_update_date        => SYSDATE,
          p_last_updated_by         => FND_GLOBAL.USER_ID,
          p_creation_date           => SYSDATE,
          p_created_by              => FND_GLOBAL.USER_ID,
          p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
          p_request_id              => FND_GLOBAL.CONC_REQUEST_ID,
          p_program_application_id  => FND_GLOBAL.PROG_APPL_ID,
          p_program_update_date     => SYSDATE,
          p_program_id              => FND_GLOBAL.CONC_PROGRAM_ID,
          p_created_from            => l_settlement_doc_rec.created_from,
          p_claim_id                => l_settlement_doc_rec.claim_id,
          p_claim_line_id           => l_settlement_doc_rec.claim_line_id,
          p_payment_method          => l_settlement_doc_rec.payment_method,
          p_settlement_id           => l_settlement_doc_rec.settlement_id,
          p_settlement_type         => l_settlement_doc_rec.settlement_type,
          p_settlement_type_id      => l_settlement_doc_rec.settlement_type_id,
          p_settlement_number       => l_settlement_doc_rec.settlement_number,
          p_settlement_date         => l_settlement_doc_rec.settlement_date,
          p_settlement_amount       => l_settlement_doc_rec.settlement_amount,
          p_settlement_acctd_amount => l_settlement_doc_rec.settlement_acctd_amount,
          p_status_code             => l_settlement_doc_rec.status_code,
          p_attribute_category      => l_settlement_doc_rec.attribute_category,
          p_attribute1              => l_settlement_doc_rec.attribute1,
          p_attribute2              => l_settlement_doc_rec.attribute2,
          p_attribute3              => l_settlement_doc_rec.attribute3,
          p_attribute4              => l_settlement_doc_rec.attribute4,
          p_attribute5              => l_settlement_doc_rec.attribute5,
          p_attribute6              => l_settlement_doc_rec.attribute6,
          p_attribute7              => l_settlement_doc_rec.attribute7,
          p_attribute8              => l_settlement_doc_rec.attribute8,
          p_attribute9              => l_settlement_doc_rec.attribute9,
          p_attribute10             => l_settlement_doc_rec.attribute10,
          p_attribute11             => l_settlement_doc_rec.attribute11,
          p_attribute12             => l_settlement_doc_rec.attribute12,
          p_attribute13             => l_settlement_doc_rec.attribute13,
          p_attribute14             => l_settlement_doc_rec.attribute14,
          p_attribute15             => l_settlement_doc_rec.attribute15,
          px_org_id                 => l_claim_rec.org_id,
          p_payment_reference_id    => l_settlement_doc_rec.payment_reference_id,
          p_payment_reference_number => l_settlement_doc_rec.payment_reference_number,
          p_payment_status           => l_settlement_doc_rec.payment_status,
          p_group_claim_id           => l_settlement_doc_rec.group_claim_id,
          p_gl_date                  => TRUNC(l_settlement_doc_rec.gl_date),
          p_wo_rec_trx_id            => l_settlement_doc_rec.wo_rec_trx_id
    );
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',SQLERRM);
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
  END;

  ------------------------- finish -------------------------------
  x_settlement_doc_id := l_settlement_doc_rec.settlement_doc_id;

  -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Create_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

End Create_Settlement_Doc;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Settlement_Doc
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Update_Settlement_Doc(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_validation_level       IN   NUMBER,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_settlement_doc_rec     IN   settlement_doc_rec_type,
    x_object_version_number  OUT NOCOPY  NUMBER
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Update_Settlement_Doc';
l_full_name     CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status          VARCHAR2(1);

l_complete_doc_rec       settlement_doc_rec_type;

l_object_version_number  NUMBER;
l_last_updated_by        NUMBER;
l_last_update_login      NUMBER;
l_org_id                 NUMBER;

CURSOR csr_settle_obj_ver(cv_settle_doc_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_settlement_docs_all
  WHERE settlement_doc_id = cv_settle_doc_id;

CURSOR csr_claim_currency(cv_claim_id IN NUMBER) IS
  SELECT set_of_books_id,
         currency_code,
         exchange_rate_date,
         exchange_rate_type,
         exchange_rate,
         org_id
  FROM ozf_claims_all
  WHERE claim_id = cv_claim_id;
l_claim_rec csr_claim_currency%ROWTYPE;
l_exchange_rate NUMBER;

BEGIN

  -------------------- initialize -------------------------
  SAVEPOINT Update_Settlement_Doc;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         G_PKG_NAME
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;


  l_last_updated_by := NVL(FND_GLOBAL.user_id,-1);
  l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);


  ----------------------- validate ----------------------
  -- Varify object_version_number
  IF p_settlement_doc_rec.object_version_number is NULL or
     p_settlement_doc_rec.object_version_number = FND_API.G_MISS_NUM THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN csr_settle_obj_ver(p_settlement_doc_rec.settlement_doc_id);
  FETCH csr_settle_obj_ver INTO l_object_version_number;
  CLOSE csr_settle_obj_ver;

  IF l_object_version_number <> p_settlement_doc_rec.object_version_number THEN
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_object_version_number := l_object_version_number + 1;

  -- replace g_miss_char/num/date with current column values
  Complete_Settle_Doc_Rec(
         p_settlement_doc_rec =>  p_settlement_doc_rec
        ,x_complete_rec       =>  l_complete_doc_rec
  );

  -- item level validation
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    Check_Settle_Doc_Items(
         P_settlement_doc_rec   => l_complete_doc_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  -- record level validation
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    Check_Settle_Doc_Record(
         P_settlement_doc_rec => p_settlement_doc_rec,
         p_complete_rec       => l_complete_doc_rec,
         x_return_status      => l_return_status
    );
    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  OPEN csr_claim_currency(l_complete_doc_rec.claim_id);
  FETCH csr_claim_currency INTO l_claim_rec;
  CLOSE csr_claim_currency;

  -------------------- Amount Rounding -----------------------
  IF l_complete_doc_rec.settlement_amount IS NOT NULL THEN
    l_complete_doc_rec.settlement_amount := OZF_UTILITY_PVT.CurrRound(l_complete_doc_rec.settlement_amount, l_claim_rec.currency_code);
    -- Calculate Accounted Amount
    OZF_UTILITY_PVT.Convert_Currency(
         P_SET_OF_BOOKS_ID => l_claim_rec.set_of_books_id,
         P_FROM_CURRENCY   => l_claim_rec.currency_code,
         P_CONVERSION_DATE => l_claim_rec.exchange_rate_date,
         P_CONVERSION_TYPE => l_claim_rec.exchange_rate_type,
         P_CONVERSION_RATE => l_claim_rec.exchange_rate,
         P_AMOUNT          => l_complete_doc_rec.settlement_amount,
         X_RETURN_STATUS   => l_return_status,
         X_ACC_AMOUNT      => l_complete_doc_rec.settlement_acctd_amount,
         X_RATE            => l_exchange_rate
     );

     IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  -------------------------- update --------------------
  BEGIN
    -- Invoke table handler(OZF_SETTLEMENT_DOCS_PKG.Update_Row)
    OZF_SETTLEMENT_DOCS_PKG.Update_Row(
          p_settlement_doc_id      => l_complete_doc_rec.settlement_doc_id,
          p_object_version_number  => l_object_version_number,
          p_last_update_date       => SYSDATE,
          p_last_updated_by        => FND_GLOBAL.USER_ID,
          p_last_update_login      => FND_GLOBAL.CONC_LOGIN_ID,
          p_request_id             => l_complete_doc_rec.request_id,
          p_program_application_id => l_complete_doc_rec.program_application_id,
          p_program_update_date    => l_complete_doc_rec.program_update_date,
          p_program_id             => l_complete_doc_rec.program_id,
          p_created_from           => l_complete_doc_rec.created_from,
          p_claim_id               => l_complete_doc_rec.claim_id,
          p_claim_line_id          => l_complete_doc_rec.claim_line_id,
          p_payment_method         => l_complete_doc_rec.payment_method,
          p_settlement_id          => l_complete_doc_rec.settlement_id,
          p_settlement_type        => l_complete_doc_rec.settlement_type,
          p_settlement_type_id     => l_complete_doc_rec.settlement_type_id,
          p_settlement_number      => l_complete_doc_rec.settlement_number,
          p_settlement_date        => l_complete_doc_rec.settlement_date,
          p_settlement_amount      => l_complete_doc_rec.settlement_amount,
          p_settlement_acctd_amount=> l_complete_doc_rec.settlement_acctd_amount,
          p_status_code            => l_complete_doc_rec.status_code,
          p_attribute_category     => l_complete_doc_rec.attribute_category,
          p_attribute1             => l_complete_doc_rec.attribute1,
          p_attribute2             => l_complete_doc_rec.attribute2,
          p_attribute3             => l_complete_doc_rec.attribute3,
          p_attribute4             => l_complete_doc_rec.attribute4,
          p_attribute5             => l_complete_doc_rec.attribute5,
          p_attribute6             => l_complete_doc_rec.attribute6,
          p_attribute7             => l_complete_doc_rec.attribute7,
          p_attribute8             => l_complete_doc_rec.attribute8,
          p_attribute9             => l_complete_doc_rec.attribute9,
          p_attribute10            => l_complete_doc_rec.attribute10,
          p_attribute11            => l_complete_doc_rec.attribute11,
          p_attribute12            => l_complete_doc_rec.attribute12,
          p_attribute13            => l_complete_doc_rec.attribute13,
          p_attribute14            => l_complete_doc_rec.attribute14,
          p_attribute15            => l_complete_doc_rec.attribute15,
          p_org_id                 => l_claim_rec.org_id,
          p_payment_reference_id    => l_complete_doc_rec.payment_reference_id,
          p_payment_reference_number => l_complete_doc_rec.payment_reference_number,
          p_payment_status           => l_complete_doc_rec.payment_status,
          p_group_claim_id           => l_complete_doc_rec.group_claim_id,
          p_gl_date                  => TRUNC(l_complete_doc_rec.gl_date),
          p_wo_rec_trx_id            => l_complete_doc_rec.wo_rec_trx_id
    );
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
        FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
  END;


/*
  UPDATE ozf_settlement_docs_all SET
       object_version_number     = l_object_version_number,
       last_update_date          = SYSDATE,
       last_updated_by           = l_last_updated_by,
       last_update_login         = l_last_update_login,
       request_id                = FND_GLOBAL.CONC_REQUEST_ID,
       program_application_id    = FND_GLOBAL.PROG_APPL_ID,
       program_update_date       = SYSDATE,
       program_id                = FND_GLOBAL.CONC_PROGRAM_ID,
       created_from              = l_complete_doc_rec.created_from,
       claim_id                  = l_complete_doc_rec.claim_id,
       claim_line_id             = l_complete_doc_rec.claim_line_id,
       payment_method            = l_complete_doc_rec.payment_method,
       settlement_id             = l_complete_doc_rec.settlement_id,
       settlement_type           = l_complete_doc_rec.settlement_type,
       settlement_type_id        = l_complete_doc_rec.settlement_type_id,
       settlement_number         = l_complete_doc_rec.settlement_number,
       settlement_date           = l_complete_doc_rec.settlement_date,
       settlement_amount         = l_complete_doc_rec.settlement_amount,
       status_code               = l_complete_doc_rec.status_code,
       attribute_category        = l_complete_doc_rec.attribute_category,
       attribute1                = l_complete_doc_rec.attribute1,
       attribute2                = l_complete_doc_rec.attribute2,
       attribute3                = l_complete_doc_rec.attribute3,
       attribute4                = l_complete_doc_rec.attribute4,
       attribute5                = l_complete_doc_rec.attribute5,
       attribute6                = l_complete_doc_rec.attribute6,
       attribute7                = l_complete_doc_rec.attribute7,
       attribute8                = l_complete_doc_rec.attribute8,
       attribute9                = l_complete_doc_rec.attribute9,
       attribute10               = l_complete_doc_rec.attribute10,
       attribute11               = l_complete_doc_rec.attribute11,
       attribute12               = l_complete_doc_rec.attribute12,
       attribute13               = l_complete_doc_rec.attribute13,
       attribute14               = l_complete_doc_rec.attribute14,
       attribute15               = l_complete_doc_rec.attribute15,
       org_id                    = l_complete_doc_rec.org_id
  WHERE settlement_doc_id = p_settlement_doc_rec.settlement_doc_id
  AND object_version_number = p_settlement_doc_rec.object_version_number;
*/

  -------------------- finish --------------------------
  x_object_version_number := l_object_version_number;

  -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Update_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

End Update_Settlement_Doc;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Settlement_Doc
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Delete_Settlement_Doc(
    p_api_version_number      IN   NUMBER,
    p_init_msg_list           IN   VARCHAR2,
    p_commit                  IN   VARCHAR2,
    p_validation_level        IN   NUMBER,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_settlement_doc_id       IN  NUMBER,
    p_object_version_number   IN   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Settlement_Doc';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_object_version       NUMBER;

CURSOR csr_settle_obj_ver(cv_settle_doc_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_settlement_docs_all
  WHERE settlement_doc_id = cv_settle_doc_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Settlement_Doc;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version_number,
         l_api_name,
         G_PKG_NAME
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  -- Validate object_version_number
  OPEN csr_settle_obj_ver(p_settlement_doc_id);
  FETCH csr_settle_obj_ver INTO l_object_version;
  CLOSE csr_settle_obj_ver;

  ------------------------ delete ------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': delete');
  END IF;

  IF p_object_version_number = l_object_version THEN
    BEGIN
      OZF_SETTLEMENT_DOCS_PKG.Delete_Row(
          p_settlement_doc_id  => p_settlement_doc_id
      );
    EXCEPTION
      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
    END;
  ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_REC_VERSION_CHANGED');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

/*
  DELETE FROM ozf_settlement_docs_all
    WHERE settlement_doc_id = p_settlement_doc_id
    AND   object_version_number = p_object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
*/
  -------------------- finish --------------------------
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Delete_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Settlement_Doc;
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );
End Delete_Settlement_Doc;



---------------------------------------------------------------------
-- PROCEDURE
--    Lock_Settlement_Doc
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Lock_Settlement_Doc(
    p_api_version_number   IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2,

    x_return_status        OUT NOCOPY  VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2,

    p_settlement_doc_id    IN   NUMBER,
    p_object_version       IN   NUMBER
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_settlement_doc_id     NUMBER;

CURSOR c_Settlement_Doc IS
   SELECT settlement_doc_id
   FROM ozf_settlement_docs_all
   WHERE settlement_doc_id = p_settlement_doc_id
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN
  -------------------- initialize ------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
       l_api_version,
       p_api_version_number,
       l_api_name,
       g_pkg_name
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  ------------------------ lock -------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': lock');
  END IF;

  OPEN c_Settlement_Doc;
  FETCH c_Settlement_Doc INTO l_settlement_doc_id;
  IF (c_Settlement_Doc%NOTFOUND) THEN
    CLOSE c_Settlement_Doc;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_Settlement_Doc;

  -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN OZF_Utility_PVT.resource_locked THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
       FND_MSG_PUB.add;
    END IF;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

End Lock_Settlement_Doc;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_Uk_Items
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_Uk_Items(
    p_settlement_doc_rec    IN  settlement_doc_rec_type,
    p_validation_mode       IN  VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
  x_return_status := FND_API.g_ret_sts_success;
/*
  IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                      'OZF_SETTLEMENT_DOCS_ALL',
                      'SETTLEMENT_DOC_ID = ''' || p_settlement_doc_rec.SETTLEMENT_DOC_ID ||''''
                   );
  ELSE
    l_valid_flag := OZF_Utility_PVT.check_uniqueness(
                      'OZF_SETTLEMENT_DOCS_ALL',
                      'SETTLEMENT_DOC_ID = ''' || p_settlement_doc_rec.SETTLEMENT_DOC_ID ||
                      ''' AND SETTLEMENT_DOC_ID <> ' || p_settlement_doc_rec.SETTLEMENT_DOC_ID
                   );
  END IF;

  IF l_valid_flag = FND_API.g_false THEN
    OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_SETTLEMENT_DOC_ID_DUPLICATE');
    x_return_status := FND_API.g_ret_sts_error;
    RETURN;
  END IF;
*/
END Check_Settle_Doc_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_Req_Items
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_Req_Items(
    p_settlement_doc_rec     IN  settlement_doc_rec_type,
    p_validation_mode        IN  VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  IF p_validation_mode = JTF_PLSQL_API.g_create THEN
    /*
    IF p_settlement_doc_rec.settlement_doc_id = FND_API.g_miss_num OR
       p_settlement_doc_rec.settlement_doc_id IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.object_version_number = FND_API.g_miss_num OR
       p_settlement_doc_rec.object_version_number IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.last_update_date = FND_API.g_miss_date OR
       p_settlement_doc_rec.last_update_date IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.last_updated_by = FND_API.g_miss_num OR
       p_settlement_doc_rec.last_updated_by IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.creation_date = FND_API.g_miss_date OR
       p_settlement_doc_rec.creation_date IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.created_by = FND_API.g_miss_num OR
       p_settlement_doc_rec.created_by IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    */
    IF p_settlement_doc_rec.claim_id = FND_API.g_miss_num OR
       p_settlement_doc_rec.claim_id IS NULL THEN
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
    END IF;
  ELSE
    IF p_settlement_doc_rec.settlement_doc_id IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    /*
    IF p_settlement_doc_rec.object_version_number IS NULL THEN
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
    END IF;

    IF p_settlement_doc_rec.last_update_date IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.last_updated_by IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.creation_date IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    IF p_settlement_doc_rec.created_by IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    */
   IF p_settlement_doc_rec.claim_id IS NULL THEN
     x_return_status := FND_API.g_ret_sts_error;
     RETURN;
   END IF;
 END IF;

END Check_Settle_Doc_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_FK_Items
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_FK_Items(
    p_settlement_doc_rec  IN  settlement_doc_rec_type,
    x_return_status       OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- Enter custom code here

END Check_Settle_Doc_FK_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_Lk_Items
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_Lk_Items(
    p_settlement_doc_rec IN settlement_doc_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- Enter custom code here

END Check_Settle_Doc_Lk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_Items
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_Items (
    P_settlement_doc_rec     IN    settlement_doc_rec_type,
    p_validation_mode        IN    VARCHAR2,
    x_return_status          OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

  -- Check Items Uniqueness API calls
  Check_Settle_Doc_UK_Items(
      p_settlement_doc_rec => p_settlement_doc_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
  );
  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  -- Check Items Required/NOT NULL API calls
  Check_Settle_Doc_Req_Items(
      p_settlement_doc_rec => p_settlement_doc_rec,
      p_validation_mode    => p_validation_mode,
      x_return_status      => x_return_status
  );
  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  -- Check Items Foreign Keys API calls
  Check_Settle_Doc_FK_Items(
      p_settlement_doc_rec => p_settlement_doc_rec,
      x_return_status      => x_return_status
  );
  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  -- Check Items Lookups
  Check_Settle_Doc_LK_Items(
    p_settlement_doc_rec  => p_settlement_doc_rec,
    x_return_status       => x_return_status
  );
  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END Check_Settle_doc_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Settle_Doc_Rec
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Complete_Settle_Doc_Rec(
   p_settlement_doc_rec  IN  settlement_doc_rec_type,
   x_complete_rec        OUT NOCOPY settlement_doc_rec_type
)
IS
l_return_status  VARCHAR2(1);

CURSOR c_complete IS
  SELECT *
  FROM ozf_settlement_docs_all
  WHERE settlement_doc_id = p_settlement_doc_rec.settlement_doc_id;

l_settlement_doc_rec c_complete%ROWTYPE;

BEGIN
  x_complete_rec := p_settlement_doc_rec;

  OPEN c_complete;
  FETCH c_complete INTO l_settlement_doc_rec;
  CLOSE c_complete;

  -- settlement_doc_id
  IF p_settlement_doc_rec.settlement_doc_id = FND_API.g_miss_num THEN
    x_complete_rec.settlement_doc_id := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_doc_id IS NULL THEN
    x_complete_rec.settlement_doc_id := l_settlement_doc_rec.settlement_doc_id;
  END IF;

  -- object_version_number
  IF p_settlement_doc_rec.object_version_number = FND_API.g_miss_num THEN
    x_complete_rec.object_version_number := NULL;
  END IF;
  IF p_settlement_doc_rec.object_version_number IS NULL THEN
    x_complete_rec.object_version_number := l_settlement_doc_rec.object_version_number;
  END IF;

  -- last_update_date
  IF p_settlement_doc_rec.last_update_date = FND_API.g_miss_date THEN
    x_complete_rec.last_update_date := NULL;
  END IF;
  IF p_settlement_doc_rec.last_update_date IS NULL THEN
    x_complete_rec.last_update_date := l_settlement_doc_rec.last_update_date;
  END IF;

  -- last_updated_by
  IF p_settlement_doc_rec.last_updated_by = FND_API.g_miss_num THEN
    x_complete_rec.last_updated_by := NULL;
  END IF;
  IF p_settlement_doc_rec.last_updated_by IS NULL THEN
    x_complete_rec.last_updated_by := l_settlement_doc_rec.last_updated_by;
  END IF;

  -- creation_date
  IF p_settlement_doc_rec.creation_date = FND_API.g_miss_date THEN
    x_complete_rec.creation_date := NULL;
  END IF;
  IF p_settlement_doc_rec.creation_date IS NULL THEN
    x_complete_rec.creation_date := l_settlement_doc_rec.creation_date;
  END IF;

  -- created_by
  IF p_settlement_doc_rec.created_by = FND_API.g_miss_num THEN
    x_complete_rec.created_by := NULL;
  END IF;
  IF p_settlement_doc_rec.created_by IS NULL THEN
    x_complete_rec.created_by := l_settlement_doc_rec.created_by;
  END IF;

  -- last_update_login
  IF p_settlement_doc_rec.last_update_login = FND_API.g_miss_num THEN
    x_complete_rec.last_update_login := NULL;
  END IF;
  IF p_settlement_doc_rec.last_update_login IS NULL THEN
    x_complete_rec.last_update_login := l_settlement_doc_rec.last_update_login;
  END IF;

  -- request_id
  IF p_settlement_doc_rec.request_id = FND_API.g_miss_num THEN
    x_complete_rec.request_id := NULL;
  END IF;
  IF p_settlement_doc_rec.request_id IS NULL THEN
    x_complete_rec.request_id := l_settlement_doc_rec.request_id;
  END IF;

  -- program_application_id
  IF p_settlement_doc_rec.program_application_id = FND_API.g_miss_num THEN
    x_complete_rec.program_application_id := NULL;
  END IF;
  IF p_settlement_doc_rec.program_application_id IS NULL THEN
    x_complete_rec.program_application_id := l_settlement_doc_rec.program_application_id;
  END IF;

  -- program_update_date
  IF p_settlement_doc_rec.program_update_date = FND_API.g_miss_date THEN
    x_complete_rec.program_update_date := NULL;
  END IF;
  IF p_settlement_doc_rec.program_update_date IS NULL THEN
    x_complete_rec.program_update_date := l_settlement_doc_rec.program_update_date;
  END IF;

  -- program_id
  IF p_settlement_doc_rec.program_id = FND_API.g_miss_num THEN
    x_complete_rec.program_id := NULL;
  END IF;
  IF p_settlement_doc_rec.program_id IS NULL THEN
    x_complete_rec.program_id := l_settlement_doc_rec.program_id;
  END IF;

  -- created_from
  IF p_settlement_doc_rec.created_from = FND_API.g_miss_char THEN
    x_complete_rec.created_from := NULL;
  END IF;
  IF p_settlement_doc_rec.created_from IS NULL THEN
    x_complete_rec.created_from := l_settlement_doc_rec.created_from;
  END IF;

  -- claim_id
  IF p_settlement_doc_rec.claim_id = FND_API.g_miss_num THEN
    x_complete_rec.claim_id := NULL;
  END IF;
  IF p_settlement_doc_rec.claim_id IS NULL THEN
    x_complete_rec.claim_id := l_settlement_doc_rec.claim_id;
  END IF;

  -- claim_line_id
  IF p_settlement_doc_rec.claim_line_id = FND_API.g_miss_num THEN
    x_complete_rec.claim_line_id := NULL;
  END IF;
  IF p_settlement_doc_rec.claim_line_id IS NULL THEN
    x_complete_rec.claim_line_id := l_settlement_doc_rec.claim_line_id;
  END IF;

  -- payment_method
  IF p_settlement_doc_rec.payment_method = FND_API.g_miss_char THEN
    x_complete_rec.payment_method := NULL;
  END IF;
  IF p_settlement_doc_rec.payment_method IS NULL THEN
    x_complete_rec.payment_method := l_settlement_doc_rec.payment_method;
  END IF;

  -- settlement_id
  IF p_settlement_doc_rec.settlement_id = FND_API.g_miss_num THEN
    x_complete_rec.settlement_id := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_id IS NULL THEN
    x_complete_rec.settlement_id := l_settlement_doc_rec.settlement_id;
  END IF;

  -- settlement_type
  IF p_settlement_doc_rec.settlement_type = FND_API.g_miss_char THEN
    x_complete_rec.settlement_type := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_type IS NULL THEN
    x_complete_rec.settlement_type := l_settlement_doc_rec.settlement_type;
  END IF;

  -- settlement_type_id
  IF p_settlement_doc_rec.settlement_type_id = FND_API.g_miss_num THEN
    x_complete_rec.settlement_type_id := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_type_id IS NULL THEN
    x_complete_rec.settlement_type_id := l_settlement_doc_rec.settlement_type_id;
  END IF;

  -- settlement_number
  IF p_settlement_doc_rec.settlement_number = FND_API.g_miss_char THEN
    x_complete_rec.settlement_number := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_number IS NULL THEN
    x_complete_rec.settlement_number := l_settlement_doc_rec.settlement_number;
  END IF;

  -- settlement_date
  IF p_settlement_doc_rec.settlement_date = FND_API.g_miss_date THEN
    x_complete_rec.settlement_date := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_date IS NULL THEN
    x_complete_rec.settlement_date := l_settlement_doc_rec.settlement_date;
  END IF;

  -- settlement_amount
  IF p_settlement_doc_rec.settlement_amount = FND_API.g_miss_num THEN
    x_complete_rec.settlement_amount := NULL;
  END IF;
  IF p_settlement_doc_rec.settlement_amount IS NULL THEN
    x_complete_rec.settlement_amount := l_settlement_doc_rec.settlement_amount;
  END IF;

  -- status_code
  IF p_settlement_doc_rec.status_code = FND_API.g_miss_char THEN
    x_complete_rec.status_code := NULL;
  END IF;
  IF p_settlement_doc_rec.status_code IS NULL THEN
    x_complete_rec.status_code := l_settlement_doc_rec.status_code;
  END IF;

  -- attribute_category
  IF p_settlement_doc_rec.attribute_category = FND_API.g_miss_char THEN
    x_complete_rec.attribute_category := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute_category IS NULL THEN
    x_complete_rec.attribute_category := l_settlement_doc_rec.attribute_category;
  END IF;

  -- attribute1
  IF p_settlement_doc_rec.attribute1 = FND_API.g_miss_char THEN
    x_complete_rec.attribute1 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute1 IS NULL THEN
    x_complete_rec.attribute1 := l_settlement_doc_rec.attribute1;
  END IF;

  -- attribute2
  IF p_settlement_doc_rec.attribute2 = FND_API.g_miss_char THEN
    x_complete_rec.attribute2 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute2 IS NULL THEN
    x_complete_rec.attribute2 := l_settlement_doc_rec.attribute2;
  END IF;

  -- attribute3
  IF p_settlement_doc_rec.attribute3 = FND_API.g_miss_char THEN
    x_complete_rec.attribute3 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute3 IS NULL THEN
    x_complete_rec.attribute3 := l_settlement_doc_rec.attribute3;
  END IF;

  -- attribute4
  IF p_settlement_doc_rec.attribute4 = FND_API.g_miss_char THEN
    x_complete_rec.attribute4 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute4 IS NULL THEN
    x_complete_rec.attribute4 := l_settlement_doc_rec.attribute4;
  END IF;

  -- attribute5
  IF p_settlement_doc_rec.attribute5 = FND_API.g_miss_char THEN
    x_complete_rec.attribute5 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute5 IS NULL THEN
    x_complete_rec.attribute5 := l_settlement_doc_rec.attribute5;
  END IF;

  -- attribute6
  IF p_settlement_doc_rec.attribute6 = FND_API.g_miss_char THEN
    x_complete_rec.attribute6 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute6 IS NULL THEN
    x_complete_rec.attribute6 := l_settlement_doc_rec.attribute6;
  END IF;

  -- attribute7
  IF p_settlement_doc_rec.attribute7 = FND_API.g_miss_char THEN
    x_complete_rec.attribute7 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute7 IS NULL THEN
    x_complete_rec.attribute7 := l_settlement_doc_rec.attribute7;
  END IF;

  -- attribute8
  IF p_settlement_doc_rec.attribute8 = FND_API.g_miss_char THEN
    x_complete_rec.attribute8 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute8 IS NULL THEN
    x_complete_rec.attribute8 := l_settlement_doc_rec.attribute8;
  END IF;

  -- attribute9
  IF p_settlement_doc_rec.attribute9 = FND_API.g_miss_char THEN
    x_complete_rec.attribute9 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute9 IS NULL THEN
    x_complete_rec.attribute9 := l_settlement_doc_rec.attribute9;
  END IF;

  -- attribute10
  IF p_settlement_doc_rec.attribute10 = FND_API.g_miss_char THEN
    x_complete_rec.attribute10 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute10 IS NULL THEN
    x_complete_rec.attribute10 := l_settlement_doc_rec.attribute10;
  END IF;

  -- attribute11
  IF p_settlement_doc_rec.attribute11 = FND_API.g_miss_char THEN
    x_complete_rec.attribute11 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute11 IS NULL THEN
    x_complete_rec.attribute11 := l_settlement_doc_rec.attribute11;
  END IF;

  -- attribute12
  IF p_settlement_doc_rec.attribute12 = FND_API.g_miss_char THEN
    x_complete_rec.attribute12 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute12 IS NULL THEN
    x_complete_rec.attribute12 := l_settlement_doc_rec.attribute12;
  END IF;

  -- attribute13
  IF p_settlement_doc_rec.attribute13 = FND_API.g_miss_char THEN
    x_complete_rec.attribute13 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute13 IS NULL THEN
    x_complete_rec.attribute13 := l_settlement_doc_rec.attribute13;
  END IF;

  -- attribute14
  IF p_settlement_doc_rec.attribute14 = FND_API.g_miss_char THEN
    x_complete_rec.attribute14 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute14 IS NULL THEN
    x_complete_rec.attribute14 := l_settlement_doc_rec.attribute14;
  END IF;

  -- attribute15
  IF p_settlement_doc_rec.attribute15 = FND_API.g_miss_char THEN
    x_complete_rec.attribute15 := NULL;
  END IF;
  IF p_settlement_doc_rec.attribute15 IS NULL THEN
    x_complete_rec.attribute15 := l_settlement_doc_rec.attribute15;
  END IF;

  -- org_id
  IF p_settlement_doc_rec.org_id = FND_API.g_miss_num THEN
    x_complete_rec.org_id := NULL;
  END IF;
  IF p_settlement_doc_rec.org_id IS NULL THEN
    x_complete_rec.org_id := l_settlement_doc_rec.org_id;
  END IF;


  --      payment_reference_id
  IF p_settlement_doc_rec.payment_reference_id = FND_API.g_miss_num THEN
    x_complete_rec.payment_reference_id := NULL;
  END IF;
  IF p_settlement_doc_rec.payment_reference_id IS NULL THEN
    x_complete_rec.payment_reference_id := l_settlement_doc_rec.payment_reference_id;
  END IF;

  --     payment_reference_number
  IF p_settlement_doc_rec.payment_reference_number = FND_API.g_miss_char THEN
    x_complete_rec.payment_reference_number := NULL;
  END IF;
  IF p_settlement_doc_rec.payment_reference_number IS NULL THEN
    x_complete_rec.payment_reference_number := l_settlement_doc_rec.payment_reference_number;
  END IF;

  --     payment_status
  IF p_settlement_doc_rec.payment_status = FND_API.g_miss_char THEN
    x_complete_rec.payment_status := NULL;
  END IF;
  IF p_settlement_doc_rec.payment_status IS NULL THEN
    x_complete_rec.payment_status := l_settlement_doc_rec.payment_status;
  END IF;

  --     group_claim_id
  IF p_settlement_doc_rec.group_claim_id = FND_API.g_miss_num THEN
    x_complete_rec.group_claim_id := NULL;
  END IF;
  IF p_settlement_doc_rec.group_claim_id IS NULL THEN
    x_complete_rec.group_claim_id := l_settlement_doc_rec.group_claim_id;
  END IF;

  -- gl_date
  IF p_settlement_doc_rec.gl_date = FND_API.g_miss_date THEN
    x_complete_rec.gl_date := NULL;
  END IF;
  IF p_settlement_doc_rec.gl_date IS NULL THEN
    x_complete_rec.gl_date := l_settlement_doc_rec.gl_date;
  END IF;

  -- wo_rec_trx_id
  IF p_settlement_doc_rec.wo_rec_trx_id = FND_API.g_miss_num THEN
    x_complete_rec.wo_rec_trx_id := NULL;
  END IF;
  IF p_settlement_doc_rec.wo_rec_trx_id IS NULL THEN
    x_complete_rec.wo_rec_trx_id := l_settlement_doc_rec.wo_rec_trx_id;
  END IF;

END Complete_Settle_Doc_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Settlement_Doc
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Validate_Settlement_Doc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    p_settlement_doc_rec         IN   settlement_doc_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Settlement_Doc';
l_full_name   CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);

l_object_version_number     NUMBER;
l_settlement_doc_rec  OZF_Settlement_Doc_PVT.settlement_doc_rec_type;

 BEGIN
  ----------------------- initialize --------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
       l_api_version,
       p_api_version_number,
       l_api_name,
       g_pkg_name
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  ---------------------- validate ------------------------
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    Check_Settle_Doc_Items(
       p_settlement_doc_rec  => p_settlement_doc_rec,
       p_validation_mode     => JTF_PLSQL_API.g_create,
       x_return_status       => x_return_status
    );
    IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    Check_Settle_Doc_Record(
       p_settlement_doc_rec   => p_settlement_doc_rec,
       p_complete_rec         => NULL,
       x_return_status        => l_return_status
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false,
       p_count   => x_msg_count,
       p_data    => x_msg_data
  );

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data
    );

End Validate_Settlement_Doc;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Settle_Doc_Record
--
-- HISTORY
--                pnerella  Create.
--    05/30/2001  mchang    Modified.
---------------------------------------------------------------------
PROCEDURE Check_Settle_Doc_Record(
    p_settlement_doc_rec   IN    settlement_doc_rec_type,
    p_complete_rec         IN    settlement_doc_rec_type,
    x_return_status        OUT NOCOPY   VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- do other record level checkings

END Check_Settle_Doc_Record;

PROCEDURE Create_Settlement_Doc_Tbl(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_validation_level      IN   NUMBER,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_settlement_doc_tbl    IN   settlement_doc_tbl_type,
    x_settlement_doc_id_tbl             OUT NOCOPY  JTF_NUMBER_TABLE
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Settlement_Doc_Tbl';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_settlement_doc             settlement_doc_rec_type;
l_settlement_doc_id          NUMBER;

l_msg_data         varchar2(2000);
l_msg_count         number;
l_return_status     varchar2(30);

BEGIN

   -- Standard begin of API savepoint
    SAVEPOINT  Create_Settlement_Doc_Tbl;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
        l_api_version,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
        FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_settlement_doc_id_tbl := JTF_NUMBER_TABLE();

    For i in 1..p_settlement_doc_tbl.count LOOP

       l_settlement_doc := p_settlement_doc_tbl(i);

        OZF_SETTLEMENT_DOC_PVT.Create_Settlement_Doc(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_settlement_doc_rec    => l_settlement_doc,
            x_settlement_doc_id     => l_settlement_doc_id
        );

      -- Check return status from the above procedure call
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

        x_settlement_doc_id_tbl.extend(i);
        x_settlement_doc_id_tbl(i) := l_settlement_doc_id;


    END LOOP;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
        FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Settlement_Doc_Tbl;
   x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Settlement_Doc_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Settlement_Doc_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data       );

END Create_Settlement_Doc_Tbl;

PROCEDURE Update_Settlement_Doc_Tbl(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2,
    p_commit                 IN   VARCHAR2,
    p_validation_level       IN   NUMBER,

    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2,

    p_settlement_doc_tbl     IN   settlement_doc_tbl_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Settlement_Doc_Tbl';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_settlement_doc             settlement_doc_rec_type;
l_object_version_number  number;

l_msg_data         varchar2(2000);
l_msg_count         number;
l_return_status     varchar2(30);
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Update_Settlement_Doc_Tbl;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version_number,
       l_api_name,
       G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
     FND_MSG_PUB.Add;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    For i in 1..p_settlement_doc_tbl.count LOOP

       l_settlement_doc := p_settlement_doc_tbl(i);

    OZF_SETTLEMENT_DOC_PVT.Update_Settlement_Doc(
        p_api_version_number     => l_api_version,
        p_init_msg_list          => FND_API.G_FALSE,
        p_commit                 => FND_API.G_FALSE,
        p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
        x_return_status          => l_return_status,
        x_msg_count              => l_msg_count,
        x_msg_data               => l_msg_data,

        p_settlement_doc_rec     => l_settlement_doc,
        x_object_version_number  => l_object_version_number
        );

     IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END LOOP;

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
     FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
     FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
   );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_Settlement_Doc_Tbl;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Settlement_Doc_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Settlement_Doc_Tbl;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Update_Settlement_Doc_Tbl;


END OZF_SETTLEMENT_DOC_PVT;

/
