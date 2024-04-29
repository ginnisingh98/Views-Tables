--------------------------------------------------------
--  DDL for Package Body OZF_AR_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AR_VALIDATION_PVT" AS
/* $Header: ozfvarvb.pls 120.2 2005/10/24 00:48:09 sshivali ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'OZF_AR_VALIDATION_PVT';
G_FILE_NAME         CONSTANT VARCHAR2(12) := 'ozfvarvb.pls';

OZF_DEBUG_HIGH_ON   CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON    CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);



/*=======================================================================*
 | Function
 |    Check_to_Process_SETL_WF
 |
 | Return
 |    FND_API.g_true / FND_API.g_false
 |
 | NOTES
 |   When settling by invoice creditmemo, settlement should be done by
 |   receivable role in the following cases:
 |   1. Different credit types are mixed.
 |   2. Credit is not to source invoice.
 |
 |
 | HISTORY
 |    16-May-2005  Sahana  Created for Bug4308173
 |
 *=======================================================================*/
FUNCTION Check_to_Process_SETL_WF(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_return_status          OUT NOCOPY   VARCHAR2
) RETURN BOOLEAN IS

 CURSOR csr_claim_line_invoice(cv_claim_id IN NUMBER) IS
    SELECT source_object_id
    ,      source_object_line_id
    ,      credit_to
    ,      SUM(quantity) qty
    ,      AVG(rate)  rate
    ,      SUM(NVL(claim_currency_amount,0)) amount
    FROM ozf_claim_lines
    WHERE claim_id = cv_claim_id
    GROUP BY source_object_id, source_object_line_id, credit_to;
  l_trx_lines  csr_claim_line_invoice%ROWTYPE;

  CURSOR csr_invoice_apply_count(cv_receipt_id IN NUMBER, cv_invoice_id IN NUMBER) IS
    SELECT COUNT(rec.cash_receipt_id)
    FROM ar_receivable_applications rec
    WHERE rec.applied_customer_trx_id = cv_invoice_id
    AND   rec.cash_receipt_id = cv_receipt_id
    AND rec.display = 'Y';
  l_apply_receipt_count            NUMBER;

l_api_name     CONSTANT VARCHAR2(30) := 'Check_to_Process_SETL_WF()';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_process_setl_wf                BOOLEAN   := FALSE;
l_line_level_crediting           BOOLEAN   := FALSE;
l_type_crediting                 BOOLEAN   := FALSE;
l_header_crediting               BOOLEAN   := FALSE;

l_prev_source_object_id          NUMBER ;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   IF OZF_DEBUG_LOW_ON THEN
          OZF_Utility_PVT.debug_message(l_full_name || ': Start');
   END IF;

   OPEN csr_claim_line_invoice(p_claim_rec.claim_id);
   LOOP
      FETCH csr_claim_line_invoice INTO l_trx_lines;
      EXIT WHEN csr_claim_line_invoice%NOTFOUND;

      IF l_trx_lines.source_object_id <> l_prev_source_object_id THEN
         l_process_setl_wf      := FALSE;
         l_line_level_crediting := FALSE;
         l_type_crediting       := FALSE;
         l_header_crediting     := FALSE;

         IF OZF_DEBUG_LOW_ON THEN
             OZF_Utility_PVT.debug_message('Credit to more then one invoice');
         END IF;
         EXIT ;
      END IF;
      l_prev_source_object_id := l_trx_lines.source_object_id ;

      IF p_claim_rec.claim_class = 'DEDUCTION' AND p_claim_rec.source_object_id IS NOT NULL THEN
           IF l_trx_lines.source_object_id <> p_claim_rec.source_object_id THEN
              l_process_setl_wf := TRUE;
              IF OZF_DEBUG_LOW_ON THEN
                 OZF_Utility_PVT.debug_message('Credit to Invoice other then Source Invoice');
              END IF;
              EXIT ;
           END IF;
      ELSIF p_claim_rec.claim_class = 'DEDUCTION' AND p_claim_rec.source_object_id IS NULL THEN
            OPEN csr_invoice_apply_count(p_claim_rec.receipt_id, l_trx_lines.source_object_id);
            FETCH csr_invoice_apply_count INTO l_apply_receipt_count;
            CLOSE csr_invoice_apply_count;

            IF l_apply_receipt_count = 0 THEN
                l_process_setl_wf := TRUE;
                IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('Credit to Invoice not on the Source Receipt');
                END IF;
                EXIT;
            END IF;
      END IF;

      IF l_trx_lines.credit_to IS NOT NULL THEN
            l_type_crediting := TRUE;
          OZF_Utility_PVT.debug_message(l_full_name || ': End1');

      END IF;

      IF l_trx_lines.credit_to IS NULL AND l_trx_lines.source_object_line_id IS NULL THEN
             l_header_crediting := TRUE;
          OZF_Utility_PVT.debug_message(l_full_name || ': End2');

      END IF;

      IF l_trx_lines.source_object_line_id IS NOT NULL THEN
             l_line_level_crediting := TRUE;
            OZF_Utility_PVT.debug_message(l_full_name || ': End3');

      END IF;


      -- Check evaluates if there is more then one line.
      IF  l_line_level_crediting AND l_header_crediting THEN
           l_process_setl_wf := TRUE;
           EXIT;
      ELSIF  l_line_level_crediting AND l_type_crediting  THEN
           l_process_setl_wf := TRUE;
           EXIT;
      ELSIF l_header_crediting AND l_type_crediting  THEN
           l_process_setl_wf := TRUE;
           EXIT;
      END IF;

   END LOOP;
   CLOSE csr_claim_line_invoice;

   IF OZF_DEBUG_LOW_ON THEN
          OZF_Utility_PVT.debug_message(l_full_name || ': End');
   END IF;

   RETURN l_process_setl_wf;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
END Check_to_Process_SETL_WF;


FUNCTION Check_Credit_To_Balance(
     p_cash_receipt_id     IN NUMBER
   , p_customer_trx_id     IN NUMBER
   , p_line_type           IN VARCHAR2
   , p_claim_line_amount   IN NUMBER
) RETURN BOOLEAN
IS

CURSOR csr_transaction_balance(cv_customer_trx_id IN NUMBER) IS
   SELECT payment_schedule_id
   ,      trx_number
   ,      amount_line_items_remaining
   ,      tax_remaining
   ,      freight_remaining
   FROM ar_payment_schedules
   WHERE customer_trx_id = cv_customer_trx_id;


l_payment_schedule_id         NUMBER;
l_trx_number                  VARCHAR2(30);
l_line_remaining              NUMBER;
l_tax_remaining               NUMBER;
l_freight_remaining           NUMBER;

BEGIN
   OPEN csr_transaction_balance(p_customer_trx_id);
   FETCH csr_transaction_balance INTO l_payment_schedule_id
                                    , l_trx_number
                                    , l_line_remaining
                                    , l_tax_remaining
                                    , l_freight_remaining;
   CLOSE csr_transaction_balance;


   IF p_line_type = 'LINE' AND
      p_claim_line_amount > l_line_remaining  THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CR_TO_LINE_AMT_ERR');
         FND_MESSAGE.set_token('TRX_NUMBER', l_trx_number);
         FND_MSG_PUB.add;
      END IF;
      RETURN FALSE;
   ELSIF p_line_type = 'TAX' AND
         p_claim_line_amount > l_tax_remaining  THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CR_TO_TAX_AMT_ERR');
         FND_MESSAGE.set_token('TRX_NUMBER', l_trx_number);
         FND_MSG_PUB.add;
      END IF;
      RETURN FALSE;
   ELSIF p_line_type = 'FREIGHT' AND
         p_claim_line_amount > l_freight_remaining  THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CR_TO_FREIGHT_AMT_ERR');
         FND_MESSAGE.set_token('TRX_NUMBER', l_trx_number);
         FND_MSG_PUB.add;
      END IF;
      RETURN FALSE;
   END IF;

   RETURN TRUE;
END Check_Credit_To_Balance;


/*=======================================================================*
 | PROCEDURE
 |    Validate_CreditTo_Information
 |
 | NOTES
 | Credit Memo-Invoice settlement validation
 |   1. When credit to specific types, check balance
 |   2. When credit to line, check line balance
 |   3. Check overall invoice balance
 |
 |
 | HISTORY
 |    03-May-2005   Sahana   Created for Bug4308173
 *=======================================================================*/

PROCEDURE  Validate_CreditTo_Information(
    p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
   ,p_invoice_id            IN  NUMBER DEFAULT NULL
   ,x_return_status         OUT NOCOPY VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_CreditTo_Information';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;


CURSOR csr_get_inv_info(cv_claim_id IN NUMBER, cv_invoice_id IN NUMBER) IS
  SELECT  source_object_id, SUM(NVL(claim_currency_amount,0))
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
  AND ( cv_invoice_id IS NULL OR source_object_id = cv_invoice_id )
  GROUP BY source_object_id;

CURSOR csr_get_creditto_info(cv_claim_id IN NUMBER, cv_invoice_id IN NUMBER) IS
   SELECT source_object_id
   ,      credit_to
   ,      SUM(NVL(claim_currency_amount,0))
   FROM  ozf_claim_lines
   WHERE claim_id = cv_claim_id
   AND   source_object_class IN ('INVOICE', 'DM', 'CB')
   AND ( cv_invoice_id IS NULL OR source_object_id = cv_invoice_id )
   GROUP BY source_object_id, credit_to;

CURSOR csr_get_lineid_info(cv_claim_id IN NUMBER, cv_invoice_id IN NUMBER) IS
   SELECT source_object_id
   ,      source_object_line_id
   ,      SUM(NVL(claim_currency_amount,0))
   FROM ozf_claim_lines
   WHERE claim_id = cv_claim_id
   AND ( cv_invoice_id IS NULL OR source_object_id = cv_invoice_id )
   GROUP BY source_object_id,source_object_line_id;

CURSOR csr_trx_line_amount(cv_invoice_line_id IN NUMBER) IS
   SELECT extended_amount
   FROM   ra_customer_trx_lines
   WHERE  customer_trx_line_id = cv_invoice_line_id;

CURSOR csr_trx_details(cv_customer_trx_id IN NUMBER) IS
   SELECT trx_number from ar_payment_schedules_all
   WHERE  customer_trx_id = cv_customer_trx_id;

l_credit_to_type      VARCHAR2(15);
l_object_class        VARCHAR2(15);
l_sum_line_amt        NUMBER;
l_invoice_id          NUMBER;
l_trx_line_amt        NUMBER;
l_invoice_line_id     NUMBER;
l_error               BOOLEAN;
l_process_setl_wf     BOOLEAN;
l_trx_number          AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;


   -- Proceed with validation only if settlement is not by receivable role

   -- This check is skipped for non invoice deductions since
   -- the check is performed before this procedure is called.
   IF p_claim_rec.claim_class = 'CLAIM' OR
         ( p_claim_rec.claim_class = 'DEDUCTION' AND   p_claim_rec.source_object_id IS NOT NULL )  THEN
         l_process_setl_wf := Check_to_Process_SETL_WF(
                            p_claim_rec      => p_claim_rec
                           ,x_return_status  => x_return_status
                         );
        IF x_return_status =  FND_API.g_ret_sts_error THEN
   	       RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
 	       RAISE FND_API.g_exc_unexpected_error;
        END IF;
        IF l_process_setl_wf THEN
           RETURN;
        END IF;
   END IF;


   OPEN csr_get_inv_info(p_claim_rec.claim_id, p_invoice_id);
   LOOP
       FETCH csr_get_inv_info INTO l_invoice_id, l_sum_line_amt;
       EXIT WHEN csr_get_inv_info%NOTFOUND;

       OZF_CLAIM_SETTLEMENT_PVT.Check_Transaction_Balance(
          p_customer_trx_id    => l_invoice_id
         ,p_claim_amount       => l_sum_line_amt
         ,p_claim_number       => p_claim_rec.claim_number
         ,x_return_status      => x_return_status    );
       IF x_return_status <>  FND_API.g_ret_sts_success THEN
           RETURN;
       END IF;
   END LOOP;
   CLOSE csr_get_inv_info;


   OPEN csr_get_creditto_info(p_claim_rec.claim_id, p_invoice_id);
   LOOP
       FETCH csr_get_creditto_info INTO l_invoice_id, l_credit_to_type,l_sum_line_amt;
  	   EXIT WHEN csr_get_creditto_info%NOTFOUND;

   	   IF l_credit_to_type IS NOT NULL THEN
            l_error :=  Check_Credit_To_Balance(
                     p_cash_receipt_id   => p_claim_rec.receipt_id
                   , p_customer_trx_id   => l_invoice_id
                   , p_line_type         => l_credit_to_type
                   , p_claim_line_amount => l_sum_line_amt);
         	 IF NOT l_error THEN
         		x_return_status := FND_API.g_ret_sts_error;
                RETURN;
	         END IF;
       END IF;
  END LOOP;
  CLOSE csr_get_creditto_info;

  OPEN csr_get_lineid_info(p_claim_rec.claim_id, p_invoice_id);
  LOOP
      FETCH csr_get_lineid_info INTO l_invoice_id, l_invoice_line_id,l_sum_line_amt;
      EXIT WHEN csr_get_lineid_info%NOTFOUND;

      OPEN csr_trx_line_amount(l_invoice_line_id);
   	  FETCH csr_trx_line_amount INTO l_trx_line_amt;
	  CLOSE csr_trx_line_amount;
      IF ABS(l_trx_line_amt) < l_sum_line_amt THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            OPEN  csr_trx_details(l_invoice_id);
            FETCH csr_trx_details INTO l_trx_number;
            CLOSE csr_trx_details;
        	FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_TRX_BAL_ERR');
        	FND_MESSAGE.set_token('TRX_NUMBER',l_trx_number);
	        FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
	END IF;
   END LOOP;
   CLOSE csr_get_lineid_info;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    x_return_status := FND_API.g_ret_sts_unexp_error;
END Validate_CreditTo_Information;




/*=======================================================================*
 | Procedure
 |    Complete_AR_Validation
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    21-JUL-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Complete_AR_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_AR_Validation';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

CURSOR csr_sum_line_amt(cv_claim_id IN NUMBER) IS
  SELECT NVL(SUM(claim_currency_amount), 0)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_sysparam_defaults(cv_set_of_books_id IN NUMBER) IS
  SELECT batch_source_id
  ,      post_to_gl
  ,      gl_rec_clearing_account
  ,      cm_trx_type_id
  ,      billback_trx_type_id
  ,      cb_trx_type_id
  ,      adj_rec_trx_id
  ,      wo_rec_trx_id
  ,      neg_wo_rec_trx_id
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_set_of_books_id;

CURSOR csr_sysparam_trx(cv_set_of_books_id IN NUMBER) IS
  SELECT billback_trx_type_id, cm_trx_type_id
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_set_of_books_id;

CURSOR csr_chk_trx_type(cv_trx_type_id IN NUMBER) IS
  SELECT type, creation_sign
  FROM ra_cust_trx_types
  WHERE cust_trx_type_id = cv_trx_type_id;

CURSOR csr_reason(cv_reason_code_id IN NUMBER) IS
  SELECT reason_code
  ,      adjustment_reason_code
  ,      name
  FROM   ozf_reason_codes_vl
  WHERE  reason_code_id = cv_reason_code_id;

CURSOR csr_trx_type(cv_claim_type_id IN NUMBER) IS
   SELECT cm_trx_type_id
   ,      dm_trx_type_id
   ,      cb_trx_type_id
   ,      wo_rec_trx_id
   ,      neg_wo_rec_trx_id
   ,      adj_rec_trx_id
   FROM ozf_claim_types_vl
   WHERE claim_type_id = cv_claim_type_id;

CURSOR csr_trx_balance(cv_customer_trx_id IN NUMBER) IS
   SELECT SUM(amount_due_remaining),
          invoice_currency_code
   FROM ar_payment_schedules
   WHERE customer_trx_id = cv_customer_trx_id
   GROUP BY invoice_currency_code;

CURSOR csr_chk_line_product(cv_claim_id IN NUMBER) IS
  SELECT item_id
  ,      quantity_uom
  --,      org_id
  ,      FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID')
  FROM ozf_claim_lines
  WHERE item_type = 'PRODUCT'
  AND claim_id = cv_claim_id;

CURSOR csr_validate_primary_uom( cv_item_id IN NUMBER, cv_org_id  IN NUMBER) IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE inventory_item_id = cv_item_id
  AND organization_id = cv_org_id;

CURSOR csr_validate_uom_class(cv_uom_code IN VARCHAR2) IS
  SELECT uom_class
  FROM mtl_units_of_measure
  WHERE uom_code = cv_uom_code;

CURSOR csr_ar_system_options IS
  SELECT salesrep_required_flag
  FROM ar_system_parameters;

CURSOR csr_get_inv_info(cv_claim_id IN NUMBER) IS
  SELECT  source_object_id, source_object_class, SUM(NVL(claim_currency_amount,0))
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
  GROUP BY source_object_id, source_object_class;

l_object_class        VARCHAR2(15);
l_invoice_id          NUMBER;

l_sum_line_amt        NUMBER;
l_sum_util_amt        NUMBER;
l_line_acctd_amt      NUMBER;
l_line_util_err       VARCHAR2(1)   := FND_API.g_false;
l_return_status       VARCHAR2(1);
l_complete_flag       VARCHAR2(1);
l_complete_yet        VARCHAR2(1)   := FND_API.g_true;
l_line_currency       VARCHAR2(3);
l_line_amount         NUMBER;
l_line_claim_curr_amt NUMBER;
l_claim_line_id       NUMBER;
l_line_amt_err_flag   VARCHAR2(1)   := FND_API.g_true;
l_asso_earning_exist  VARCHAR2(1)   := FND_API.g_false;
l_asso_earning        VARCHAR2(1);
l_vendor_in_sys       NUMBER        := NULL;
l_rec_clr_in_sys      NUMBER        := NULL;
l_trx_type_id         NUMBER        := NULL;
l_trx_type            VARCHAR2(20);
l_creation_sign       VARCHAR2(30);
l_gl_count            NUMBER := 0;
l_gl_date_type        VARCHAR2(30);
l_gl_acc_checking     VARCHAR2(1);
l_batch_source_id     NUMBER;
l_dummy               NUMBER;
l_credit_memo_reason  VARCHAR2(30);
l_adjust_reason       VARCHAR2(30);
l_claim_reason_name   VARCHAR2(60);
l_reason_type         VARCHAR2(30);
l_cm_trx_type_id      NUMBER;
l_dm_trx_type_id      NUMBER;
l_cb_trx_type_id      NUMBER;
l_wo_rec_trx_id       NUMBER;
l_neg_wo_rec_trx_id   NUMBER;
l_adj_rec_trx_id      NUMBER;
l_sp_cm_trx_type_id   NUMBER;
l_sp_dm_trx_type_id   NUMBER;
l_sp_cb_trx_type_id   NUMBER;
l_sp_adj_rec_trx_id   NUMBER;
l_sp_wo_rec_trx_id    NUMBER;
l_sp_neg_wo_rec_trx_id NUMBER;
l_error               BOOLEAN  := FALSE;
l_trx_balance         NUMBER;
l_process_setl_wf     VARCHAR2(1);
l_count               NUMBER;
l_line_item_id        NUMBER;
l_line_uom_code       VARCHAR2(30);
l_line_quantity       NUMBER;
l_line_rate           NUMBER;
l_line_org_id         NUMBER;
l_primary_uom_code    VARCHAR2(3);
l_primary_uom_class   VARCHAR2(10);
l_line_uom_class      VARCHAR2(10);
l_prod_uom_code       VARCHAR2(30);
l_prod_inv_flag       VARCHAR2(1);
l_asso_offr_perf_id   NUMBER;
l_offr_perf_flag_err  BOOLEAN  := FALSE;
l_promo_distinct_err  BOOLEAN  := FALSE;
l_earnings_asso_flag  VARCHAR2(1);
l_payment_schedule_id NUMBER;
l_salesrep_req_flag   VARCHAR2(1);
l_trx_currency        VARCHAR2(15);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   l_return_status := FND_API.g_ret_sts_success;

   OPEN csr_sum_line_amt(p_claim_rec.claim_id);
   FETCH csr_sum_line_amt INTO l_sum_line_amt;
   CLOSE csr_sum_line_amt;

   -- check if GL Accounting Flg is turning on in System Parameer.
   OPEN csr_sysparam_defaults(p_claim_rec.set_of_books_id);
   FETCH csr_sysparam_defaults INTO l_batch_source_id
                                  , l_gl_acc_checking
                                  , l_rec_clr_in_sys
                                  , l_sp_cm_trx_type_id
                                  , l_sp_dm_trx_type_id
                                  , l_sp_cb_trx_type_id
                                  , l_sp_adj_rec_trx_id
                                  , l_sp_wo_rec_trx_id
                                  , l_sp_neg_wo_rec_trx_id;
   CLOSE csr_sysparam_defaults;


  /*-----------------------------------------------------*
   | CREDIT_MEMO / DEBIT_MEMO: Receivables Batch Source is required for Interface
   *-----------------------------------------------------*/
   IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO') AND
      l_batch_source_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF','OZF_BATCH_SRC_REQ_FOR_INTF');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   ------------------------------------------------------
   -- Sales Credit
   --   Bug 2851466 fixing: Sales Rep is required in Claims
   --   if "Requires Salesperson" in AR system options.
   ------------------------------------------------------
   IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO')
      OR  p_claim_rec.payment_method = 'RMA' THEN
      OPEN csr_ar_system_options;
      FETCH csr_ar_system_options INTO l_salesrep_req_flag;
      CLOSE csr_ar_system_options;

      IF l_salesrep_req_flag = 'Y' AND
         p_claim_rec.sales_rep_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_MISS_SALESREP');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /*------------------------------------------------------
    | Claim Type / Creation Sign / Reason Code
    *-----------------------------------------------------*/
    OPEN csr_trx_type(p_claim_rec.claim_type_id);
    FETCH csr_trx_type INTO l_cm_trx_type_id
                       ,    l_dm_trx_type_id
                       ,    l_cb_trx_type_id
                       ,    l_wo_rec_trx_id
                       ,    l_neg_wo_rec_trx_id
                       ,    l_adj_rec_trx_id;
    CLOSE csr_trx_type;

    l_cm_trx_type_id    := NVL(l_cm_trx_type_id    ,l_sp_cm_trx_type_id);
    l_dm_trx_type_id    := NVL(l_dm_trx_type_id    ,l_sp_dm_trx_type_id);
    l_cb_trx_type_id    := NVL(l_cb_trx_type_id    ,l_sp_cb_trx_type_id);
    l_wo_rec_trx_id     := NVL(NVL(p_claim_rec.wo_rec_trx_id,l_wo_rec_trx_id),l_sp_wo_rec_trx_id);
    l_neg_wo_rec_trx_id := NVL(NVL(p_claim_rec.wo_rec_trx_id,l_neg_wo_rec_trx_id) ,l_sp_neg_wo_rec_trx_id);
    l_adj_rec_trx_id    := NVL(NVL(p_claim_rec.wo_rec_trx_id,l_adj_rec_trx_id),l_sp_adj_rec_trx_id);


    OPEN csr_reason(p_claim_rec.reason_code_id);
    FETCH csr_reason INTO l_credit_memo_reason
                        , l_adjust_reason
                        , l_claim_reason_name;
    CLOSE csr_reason;

    -- creation sign should match the claim settlement amount sign
    IF p_claim_rec.payment_method IN ( 'CREDIT_MEMO'
                                     , 'DEBIT_MEMO'
                                     , 'CHARGEBACK'
                                     ) THEN
       IF p_claim_rec.payment_method = 'CREDIT_MEMO' AND
          l_cm_trx_type_id IS NOT NULL THEN
          OPEN csr_chk_trx_type(l_cm_trx_type_id);
          FETCH csr_chk_trx_type INTO l_trx_type, l_creation_sign;
          CLOSE csr_chk_trx_type;
       ELSIF p_claim_rec.payment_method = 'DEBIT_MEMO' AND
          l_dm_trx_type_id IS NOT NULL THEN
          OPEN csr_chk_trx_type(l_dm_trx_type_id);
          FETCH csr_chk_trx_type INTO l_trx_type, l_creation_sign;
          CLOSE csr_chk_trx_type;
       ELSIF p_claim_rec.payment_method = 'CHARGEBACK' AND
          l_cb_trx_type_id IS NOT NULL THEN
          OPEN csr_chk_trx_type(l_cb_trx_type_id);
          FETCH csr_chk_trx_type INTO l_trx_type, l_creation_sign;
          CLOSE csr_chk_trx_type;
       END IF;

       IF p_claim_rec.amount > 0 AND
          l_creation_sign = 'P' THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_TRX_TYPE_CS_WRONG');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       ELSIF p_claim_rec.amount < 0 AND
             l_creation_sign = 'N' THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_TRX_TYPE_CS_WRONG');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;
    END IF;

    -- Receivable Transaction Type should match to payment method.
    -- Credit Memo Reason is required for CREDIT_MEMO and RMA settlement
    -- Adjustment Reason can't be ENDORSEMENT or EXCHANGE for CHARGEBACK settlement
    ------------ REG_CREDIT_MEMO ----------------
    IF p_claim_rec.payment_method = 'REG_CREDIT_MEMO' THEN
       IF l_credit_memo_reason IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_CM_REASON_ERR');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;

    ------------ CREDIT_MEMO ----------------
    ELSIF p_claim_rec.payment_method = 'CREDIT_MEMO' THEN
       IF l_cm_trx_type_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_CM_TRX_ID_REQ');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;
       IF p_claim_rec.claim_class = 'DEDUCTION' AND
          p_claim_rec.source_object_id IS NOT NULL AND
          l_sum_line_amt < p_claim_rec.amount_remaining THEN
          -- adj_rec_trx_id is required later in case of tax_impact transaction
          IF l_adj_rec_trx_id IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SETL_ADJ_TRX_ID_REQ');
                FND_MSG_PUB.add;
             END IF;
             l_error := TRUE;
          END IF;
       END IF;

    ------------ DEBIT_MEMO ----------------
    ELSIF p_claim_rec.payment_method = 'DEBIT_MEMO' THEN
       IF l_dm_trx_type_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_DM_TRX_ID_REQ');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;

    ------------ CHARGEBACK ----------------
    ELSIF p_claim_rec.payment_method = 'CHARGEBACK' THEN
       IF l_adjust_reason IN ('ENDORSEMENT', 'EXCHANGE') THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_CB_REACODE_ERR');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;
       IF l_cb_trx_type_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_CB_TRX_ID_REQ');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;

    ------------ WRITE_OFF ----------------
    ELSIF p_claim_rec.payment_method = 'WRITE_OFF' THEN
       IF p_claim_rec.claim_class = 'DEDUCTION' THEN
          IF p_claim_rec.source_object_id IS NOT NULL AND
             l_adj_rec_trx_id IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SETL_ADJ_TRX_ID_REQ');
                FND_MSG_PUB.add;
             END IF;
             l_error := TRUE;
          -- 11.5.10 Negative Receipt Write Off
          ELSIF p_claim_rec.source_object_id IS NULL AND
                ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed() AND
                l_neg_wo_rec_trx_id IS NULL THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SETL_NEG_WO_TRX_ID_REQ');
                FND_MSG_PUB.add;
             END IF;
             l_error := TRUE;
          END IF;
       ELSIF p_claim_rec.claim_class = 'OVERPAYMENT' AND
             l_wo_rec_trx_id IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_WO_TRX_ID_REQ');
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;
    ------------ RMA ----------------
    ELSIF p_claim_rec.payment_method = 'RMA' THEN
       IF l_credit_memo_reason IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_RMA_REASON_REQ');
             FND_MESSAGE.set_token('REASON', l_claim_reason_name);
             FND_MSG_PUB.add;
          END IF;
          l_error := TRUE;
       END IF;
    END IF;

    IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   /*-----------------------------------------------------
    | Related Customer and Site checking
    *-----------------------------------------------------*/
    -- related customer and site check
    IF p_claim_rec.pay_related_account_flag = FND_API.g_true THEN
      -- related_cust_acct_id should exist if pay_related_customer_flag is 'T'
      IF p_claim_rec.related_cust_account_id IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SETL_RELCUST_REQ');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- related_site_use_id should exist if pay_related_customer_flag is 'T'
      IF p_claim_rec.related_site_use_id IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SETL_RELCUST_SITE_REQ');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
     /*-----------------------------------------------------
      | Bill To Site is required
      *-----------------------------------------------------*/
      IF p_claim_rec.cust_billto_acct_site_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_SETL_BILLTO_SITE_REQ');
           FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
   /*-----------------------------------------------------
    | Ship To Site is required for RMA settlement
    *-----------------------------------------------------*/
    IF p_claim_rec.payment_method = 'RMA' AND
       p_claim_rec.cust_shipto_acct_site_id IS NULL THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SETL_SHIPTO_SITE_REQ');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


   /*-----------------------------------------------------
    | Receivable Clearing Account
    *-----------------------------------------------------*/
    -- receivable clearning account must exist in system parameter
    IF l_gl_acc_checking = FND_API.g_true AND
       l_rec_clr_in_sys IS NULL AND
       p_claim_rec.payment_method <> 'RMA' THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_SETL_RECCLRACC_REQ');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   /*-----------------------------------------------------
    | Prev Open Credit Memo/Debit Memo: open balance amount checking
    *-----------------------------------------------------*/
    IF p_claim_rec.payment_method IN ('PREV_OPEN_CREDIT', 'PREV_OPEN_DEBIT') THEN
      IF p_claim_rec.payment_reference_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF','OZF_PAY_REFERENCE_REQD');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         OPEN csr_trx_balance(p_claim_rec.payment_reference_id);
         FETCH csr_trx_balance INTO l_trx_balance, l_trx_currency;
         CLOSE csr_trx_balance;

         IF p_claim_rec.currency_code = l_trx_currency AND
            ABS(p_claim_rec.amount_remaining) > ABS(l_trx_balance) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_CM_DM_OP_BAL_ERR');
             FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
    END IF;


   /*-----------------------------------------------------*
    | Credit Memo-Invoice settlement validation
    |   Modified for 4308173
    *-----------------------------------------------------*/
    IF p_claim_rec.payment_method = 'REG_CREDIT_MEMO' THEN

       -- Invoice information needs to exist on claim line.
       OPEN  csr_get_inv_info(p_claim_rec.claim_id);
       LOOP
          FETCH csr_get_inv_info INTO l_invoice_id, l_object_class,l_sum_line_amt;
          EXIT WHEN csr_get_inv_info%NOTFOUND;
          IF l_invoice_id IS NULL THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_INV_CR_TRX_MISS');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          ELSIF  l_object_class IS NULL OR l_object_class NOT IN ('INVOICE','DM', 'CB') THEN
             FND_MESSAGE.set_name('OZF', 'OZF_SETL_INVALID_OBJ_CLASS');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END LOOP;
       CLOSE csr_get_inv_info;

       -- Validation for non invoice deductions is done during payment.
       IF p_claim_rec.claim_class = 'CLAIM' OR
         ( p_claim_rec.claim_class = 'DEDUCTION' AND   p_claim_rec.source_object_id IS NOT NULL )  THEN
           Validate_CreditTo_Information(
                  p_claim_rec       => p_claim_rec
		         ,x_return_status   => l_return_status
             );
           IF l_return_status =  FND_API.g_ret_sts_error THEN
         		RAISE FND_API.g_exc_error;
	       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      	        RAISE FND_API.g_exc_unexpected_error;
           END IF;
       END IF;

    END IF; -- REG_CREDIT_MEMO


   /*-----------------------------------------------------
    | Product Information Validation
    | Check only for CREDIT_MEMO / DEBIT_MEMO / RMA settlement.
    *-----------------------------------------------------*/
    IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO', 'RMA') THEN
       OPEN csr_chk_line_product(p_claim_rec.claim_id);
       LOOP
          FETCH csr_chk_line_product INTO l_line_item_id
                                        , l_line_uom_code
                                        , l_line_org_id;
          EXIT WHEN csr_chk_line_product%NOTFOUND;

          IF l_line_item_id IS NOT NULL THEN
             IF l_line_uom_code IS NOT NULL THEN
                -- Primary UOM validation
                OPEN csr_validate_primary_uom(l_line_item_id, l_line_org_id);
                FETCH csr_validate_primary_uom INTO l_primary_uom_code;
                CLOSE csr_validate_primary_uom;

                -- UOM class sharing validation
                IF l_primary_uom_code <> l_line_uom_code THEN
                   OPEN csr_validate_uom_class(l_primary_uom_code);
                   FETCH csr_validate_uom_class INTO l_primary_uom_class;
                   CLOSE csr_validate_uom_class;
                   OPEN csr_validate_uom_class(l_line_uom_code);
                   FETCH csr_validate_uom_class INTO l_line_uom_class;
                   CLOSE csr_validate_uom_class;
                   IF l_primary_uom_class <> l_line_uom_class THEN
                      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_SETL_PROD_UOM_INVALID');
                         FND_MSG_PUB.add;
                      END IF;
                      l_error := TRUE;
                   END IF;
                END IF;
             ELSE
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('OZF', 'OZF_SETL_PROD_UOM_MISSING');
                   FND_MSG_PUB.add;
                END IF;
                l_error := TRUE;
             END IF;
          END IF;
       END LOOP;
       CLOSE csr_chk_line_product;
    END IF;

    IF l_error THEN
       RAISE FND_API.G_EXC_ERROR;
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
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
END Complete_AR_Validation;


END OZF_AR_VALIDATION_PVT;

/
