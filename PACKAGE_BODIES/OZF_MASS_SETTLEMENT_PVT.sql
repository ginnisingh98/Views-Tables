--------------------------------------------------------
--  DDL for Package Body OZF_MASS_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_MASS_SETTLEMENT_PVT" AS
/* $Header: ozfvmstb.pls 120.15.12010000.8 2009/07/27 06:53:46 kpatro ship $ */
-- Start of Comments
-- Package name     : OZF_MASS_SETTLEMENT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME                 CONSTANT  VARCHAR2(30) := 'OZF_MASS_SETTLEMENT_PVT';
G_FILE_NAME                CONSTANT  VARCHAR2(12) := 'ozfvmstb.pls';

OZF_DEBUG_HIGH_ON          CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON           CONSTANT  BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

/*=======================================================================*
 | PROCEDURE
 |    Close_Claim
 |
 | NOTES
 |
 | HISTORY
 |    6-May-2005   Sahana    Create
 *=======================================================================*/
 PROCEDURE close_claim( p_group_claim_id IN NUMBER
                       ,p_claim_id IN NUMBER
                       ,x_return_status  OUT NOCOPY   VARCHAR2)
 IS
 BEGIN
      x_return_status := FND_API.g_ret_sts_success;


      UPDATE ozf_claims_all
          SET   payment_status = 'PAID'
            ,   status_code = 'CLOSED'
            ,   user_status_id = OZF_UTILITY_PVT.get_default_user_status(
                                    'OZF_CLAIM_STATUS'
                                   ,'CLOSED'
                                 )
            WHERE group_claim_id = p_group_claim_id
            AND claim_id = p_claim_id;
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
   x_return_status := FND_API.g_ret_sts_unexp_error;
 END;




/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Open_Receipt
 |
 | NOTES
 |
 | HISTORY
 |    30-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Open_Receipt(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_open_receipt_id        IN    NUMBER

   ,p_payment_claim_id       IN    NUMBER
   ,p_amount_applied         IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Open_Receipt';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);
---
l_application_ref_num           AR_RECEIVABLE_APPLICATIONS.application_ref_num%TYPE;
l_receivable_application_id     NUMBER;
l_applied_rec_app_id            NUMBER;

l_payment_claim_rec             OZF_Claim_PVT.claim_rec_type;

l_recpt_old_applied_amt         NUMBER;
l_recpt_new_applied_amt         NUMBER;

CURSOR csr_old_claim_investigation( cv_cash_receipt_id IN NUMBER
                                  , cv_root_claim_id IN NUMBER) IS
  SELECT rec.amount_applied
  FROM ar_receivable_applications rec
  WHERE rec.applied_payment_schedule_id = -4
  AND rec.cash_receipt_id = cv_cash_receipt_id
  AND rec.application_ref_type = 'CLAIM'
  AND rec.display = 'Y'
  AND rec.secondary_application_ref_id = cv_root_claim_id;

CURSOR csr_old_applied_invoice( cv_cash_receipt_id  IN NUMBER
                                 , cv_customer_trx_id  IN NUMBER
                                 , cv_root_claim_id    IN NUMBER ) IS
 SELECT rec.comments
 ,      rec.payment_set_id
 ,      rec.application_ref_type
 ,      rec.application_ref_id
 ,      rec.application_ref_num
 ,      rec.secondary_application_ref_id
 ,      rec.application_ref_reason
 ,      rec.customer_reference
 ,      rec.amount_applied
 ,      pay.amount_due_remaining
 FROM ar_receivable_applications rec
 ,    ar_payment_schedules pay
 WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
 AND rec.cash_receipt_id = cv_cash_receipt_id
 AND pay.customer_trx_id = cv_customer_trx_id
 AND rec.application_ref_type = 'CLAIM'
 AND rec.display = 'Y'
 AND rec.secondary_application_ref_id = cv_root_claim_id;

l_old_applied_invoice    csr_old_applied_invoice%ROWTYPE;
l_new_applied_amount     NUMBER;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   OZF_AR_Payment_PVT.Query_Claim(
       p_claim_id           => p_payment_claim_id
      ,x_claim_rec          => l_payment_claim_rec
      ,x_return_status      => l_return_status
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON  THEN
     OZF_Utility_PVT.debug_message('p_deduction_type ='||p_deduction_type);
   END IF;


   IF  ( p_deduction_type IN ( 'RECEIPT_DED', 'SOURCE_DED') AND
         l_payment_claim_rec.claim_class = 'OVERPAYMENT' ) THEN
      -- ------------------------------
      -- 1. Unapply Claim Investigation(Payment) from Open Receipt
      -- ------------------------------
      OPEN csr_old_claim_investigation( l_payment_claim_rec.receipt_id
                                      , l_payment_claim_rec.root_claim_id
                                        );
      FETCH csr_old_claim_investigation INTO l_recpt_old_applied_amt;
      CLOSE csr_old_claim_investigation;

      l_recpt_new_applied_amt := l_recpt_old_applied_amt
                               - (p_amount_applied * -1);
      IF OZF_DEBUG_HIGH_ON  THEN
           OZF_Utility_PVT.debug_message('1. Unapply overpayment claim investigation');
           OZF_Utility_PVT.debug_message('original overpayment amount = '||l_recpt_old_applied_amt);
      END IF;

      OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
          p_claim_rec       => l_payment_claim_rec
         ,p_reapply_amount  => l_recpt_new_applied_amt
         ,x_return_status   => l_return_status
         ,x_msg_data        => x_msg_data
         ,x_msg_count       => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      -- ------------------------------
      -- 2. Apply Open Receipt
      -- Bug4079177: Apply open receipt before unapplying claim.
      -- ------------------------------
      IF OZF_DEBUG_HIGH_ON  THEN
           OZF_Utility_PVT.debug_message('2. Apply open receipt ');
           OZF_Utility_PVT.debug_message('Amount applied = '||p_amount_applied);
           OZF_Utility_PVT.debug_message('Payment Cash Receipt Id = '|| l_payment_claim_rec.receipt_id);
           OZF_Utility_PVT.debug_message('Claim Receipt Id = '|| p_claim_rec.receipt_id);
      END IF;

      --Fix for bug 5325645
      IF l_payment_claim_rec.receipt_id <> p_claim_rec.receipt_id THEN
         AR_RECEIPT_API_COVER.Apply_Open_Receipt(
            -- Standard API parameters.
            p_api_version                => l_api_version,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            --  Receipt application parameters.
            p_cash_receipt_id            => p_claim_rec.receipt_id,
            p_receipt_number             => NULL,
            p_applied_payment_schedule_id=> NULL,
            p_open_cash_receipt_id       => l_payment_claim_rec.receipt_id,
            p_open_receipt_number        => NULL,
            p_open_rec_app_id            => NULL,
            p_amount_applied             => p_amount_applied,
            p_apply_date                 => SYSDATE,
            p_apply_gl_date              => NULL,
            p_ussgl_transaction_code     => NULL,
            p_called_from                => 'CLAIM',
            p_attribute_rec              => NULL,
            /*
    	      -- ******* Global Flexfield parameters *******
            p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
            p_comments                     IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
            */
            x_application_ref_num        => l_application_ref_num,
            x_receivable_application_id  => l_receivable_application_id,
            x_applied_rec_app_id         => l_applied_rec_app_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;


      -- ------------------------------
      -- 3. Unapply Claim Investigation(Deduction) from Receipt
      -- ------------------------------
      IF p_deduction_type = 'SOURCE_DED' THEN

            OPEN csr_old_applied_invoice( p_claim_rec.receipt_id
                                        , p_claim_rec.source_object_id
                                        , p_claim_rec.root_claim_id
                                        );
            FETCH csr_old_applied_invoice INTO l_old_applied_invoice;
            CLOSE csr_old_applied_invoice;

            -- 3.1. Update amount in dispute
            OZF_AR_Payment_PVT.Update_dispute_amount(
                p_claim_rec          => p_claim_rec
               ,p_dispute_amount     => (p_amount_applied * -1)
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF OZF_DEBUG_HIGH_ON  THEN
               OZF_Utility_PVT.debug_message('3. Unapply Invoice Deduction');
               OZF_Utility_PVT.debug_message('original amount applied to invoice  = '||l_old_applied_invoice.amount_applied);
            END IF;

            -- 3. Reapply claim investigation
            OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
                p_claim_rec          => p_claim_rec
               ,p_reapply_amount     => l_old_applied_invoice.amount_applied +(p_amount_applied * -1)
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;


      ELSIF p_deduction_type = 'RECEIPT_DED' THEN
            OPEN csr_old_claim_investigation( p_claim_rec.receipt_id
                                      , p_claim_rec.root_claim_id
                                        );
            FETCH csr_old_claim_investigation INTO l_recpt_old_applied_amt;
            CLOSE csr_old_claim_investigation;

            l_recpt_new_applied_amt := l_recpt_old_applied_amt + (p_amount_applied * -1);

            IF OZF_DEBUG_HIGH_ON  THEN
               OZF_Utility_PVT.debug_message('3. Unapply Non Invoice Deduction');
               OZF_Utility_PVT.debug_message('original claim investigation amount = '||l_recpt_old_applied_amt);
            END IF;


	      OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
      	    p_claim_rec       => p_claim_rec
	         ,p_reapply_amount  => l_recpt_new_applied_amt
      	   ,x_return_status   => l_return_status
	         ,x_msg_data        => x_msg_data
      	   ,x_msg_count       => x_msg_count
	      );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
      END IF; -- end if p_deduction_type

      -- ----------------------------------------------------------
      -- 4. Update Payment Detail
      -- ----------------------------------------------------------
      OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_id               => p_claim_rec.claim_id
         ,p_payment_method         => 'RECEIPT'
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => p_claim_rec.receipt_id
         ,p_customer_trx_id        => NULL
         ,p_adjust_id              => NULL
         ,p_settlement_doc_id      => NULL
         ,p_settlement_mode        => 'MASS_SETTLEMENT'
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


   /* Bug4079177: Receipt Application error when netting */
   ELSIF ( p_deduction_type = 'RECEIPT_OPM' AND
         l_payment_claim_rec.claim_class = 'DEDUCTION'  ) THEN

      -- ------------------------------
      -- 1. Unapply Claim Investigation(Payment) from Open Receipt
      -- ------------------------------

      OPEN csr_old_claim_investigation( p_claim_rec.receipt_id
                                      , p_claim_rec.root_claim_id
                                        );
      FETCH csr_old_claim_investigation INTO l_recpt_old_applied_amt;
      CLOSE csr_old_claim_investigation;

      l_recpt_new_applied_amt := l_recpt_old_applied_amt
                               + (p_amount_applied * -1);
      IF OZF_DEBUG_HIGH_ON  THEN
           OZF_Utility_PVT.debug_message('1. Unapply overpayment claim investigation');
           OZF_Utility_PVT.debug_message('original overpayment amount = '||l_recpt_old_applied_amt);
      END IF;

      OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
          p_claim_rec       => p_claim_rec
         ,p_reapply_amount  => l_recpt_new_applied_amt
         ,x_return_status   => l_return_status
         ,x_msg_data        => x_msg_data
         ,x_msg_count       => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;


      -- ------------------------------
      -- 2. Apply Open Receipt
      -- ------------------------------
      IF OZF_DEBUG_HIGH_ON  THEN
           OZF_Utility_PVT.debug_message('2. Apply open receipt ');
           OZF_Utility_PVT.debug_message('Amount applied = '||p_amount_applied);
      END IF;

      --Fix for bug 5325645
      IF l_payment_claim_rec.receipt_id <> p_claim_rec.receipt_id THEN
         AR_RECEIPT_API_COVER.Apply_Open_Receipt(
            -- Standard API parameters.
            p_api_version                => l_api_version,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => l_return_status,
            x_msg_count                  => x_msg_count,
            x_msg_data                   => x_msg_data,
            --  Receipt application parameters.
            p_cash_receipt_id            => l_payment_claim_rec.receipt_id,
            p_receipt_number             => NULL,
            p_applied_payment_schedule_id=> NULL,
            p_open_cash_receipt_id       => p_claim_rec.receipt_id,
            p_open_receipt_number        => NULL,
            p_open_rec_app_id            => NULL,
            p_amount_applied             => p_amount_applied * -1,
            p_apply_date                 => SYSDATE,
            p_apply_gl_date              => NULL,
            p_ussgl_transaction_code     => NULL,
            p_called_from                => 'CLAIM',
            p_attribute_rec              => NULL,
            /*
    	      -- ******* Global Flexfield parameters *******
            p_global_attribute_rec         IN ar_receipt_api_pub.global_attribute_rec_type DEFAULT ar_receipt_api_pub.global_attribute_rec_const,
            p_comments                     IN ar_receivable_applications.comments%TYPE DEFAULT NULL,
            */
            x_application_ref_num        => l_application_ref_num,
            x_receivable_application_id  => l_receivable_application_id,
            x_applied_rec_app_id         => l_applied_rec_app_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;


      -- ------------------------------
      -- 3. Unapply Claim Investigation(Deduction) from Receipt
      -- ------------------------------
      -- ------------------------------
      IF l_payment_claim_rec.source_object_id IS NOT NULL THEN

            OPEN csr_old_applied_invoice( l_payment_claim_rec.receipt_id
                                        , l_payment_claim_rec.source_object_id
                                        , l_payment_claim_rec.root_claim_id
                                        );
            FETCH csr_old_applied_invoice INTO l_old_applied_invoice;
            CLOSE csr_old_applied_invoice;

            -- 3.1. Update amount in dispute
            OZF_AR_Payment_PVT.Update_dispute_amount(
                p_claim_rec          => l_payment_claim_rec
               ,p_dispute_amount     => (p_amount_applied * -1)
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF OZF_DEBUG_HIGH_ON  THEN
               OZF_Utility_PVT.debug_message('3. Unapply Invoice Deduction');
               OZF_Utility_PVT.debug_message('original amount applied to invoice = '||l_old_applied_invoice.amount_applied);
            END IF;

            -- 3. Reapply claim investigation
            OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
                p_claim_rec          => l_payment_claim_rec
               ,p_reapply_amount     => l_old_applied_invoice.amount_applied -(p_amount_applied * -1)
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;


      ELSIF l_payment_claim_rec.source_object_id IS NULL THEN
            OPEN csr_old_claim_investigation( l_payment_claim_rec.receipt_id
                                      , l_payment_claim_rec.root_claim_id
                                        );
            FETCH csr_old_claim_investigation INTO l_recpt_old_applied_amt;
            CLOSE csr_old_claim_investigation;

            l_recpt_new_applied_amt := l_recpt_old_applied_amt - (p_amount_applied * -1);

            IF OZF_DEBUG_HIGH_ON  THEN
               OZF_Utility_PVT.debug_message('3. Unapply Non Invoice Deduction');
               OZF_Utility_PVT.debug_message('original claim investigation amount = '||l_recpt_old_applied_amt);
            END IF;

	      OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
      	    p_claim_rec       => l_payment_claim_rec
	         ,p_reapply_amount  => l_recpt_new_applied_amt
      	   ,x_return_status   => l_return_status
	         ,x_msg_data        => x_msg_data
      	   ,x_msg_count       => x_msg_count
	      );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
      END IF; -- end if l_payment_claim_rec.claim_class


      -- ----------------------------------------------------------
      -- 4. Update Payment Detail
      -- ----------------------------------------------------------
      OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_id               => p_claim_rec.claim_id
         ,p_payment_method         => 'RECEIPT'
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => p_claim_rec.receipt_id
         ,p_customer_trx_id        => NULL
         ,p_adjust_id              => NULL
         ,p_settlement_doc_id      => NULL
         ,p_settlement_mode        => 'MASS_SETTLEMENT'
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF;


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

END Pay_by_Open_Receipt;


/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Credit_Memo
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Credit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_payment_reference_id   IN    NUMBER
   ,p_credit_memo_amount     IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Credit_Memo';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);
---
l_invoice_applied_count  NUMBER;
--   l_old_applied_amount     NUMBER;
l_new_applied_amount     NUMBER;
l_cm_customer_trx_id     NUMBER;
l_cm_amount              NUMBER;
l_online_upd_ded_status  BOOLEAN    := FALSE;
l_orig_dispute_amount    NUMBER;
l_cm_applied_on_rec_amt  NUMBER;
l_apply_date ar_receivable_applications.apply_date%TYPE; -- Fix for Bug 3091401. TM passes old apply date

CURSOR csr_old_applied_invoice( cv_cash_receipt_id  IN NUMBER
                              , cv_customer_trx_id  IN NUMBER
                              , cv_root_claim_id    IN NUMBER ) IS
 SELECT rec.comments
 ,      rec.payment_set_id
 ,      rec.application_ref_type
 ,      rec.application_ref_id
 ,      rec.application_ref_num
 ,      rec.secondary_application_ref_id
 ,      rec.application_ref_reason
 ,      rec.customer_reference
 ,      rec.amount_applied
 ,      pay.amount_due_remaining
 FROM ar_receivable_applications rec
 ,    ar_payment_schedules pay
 WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
 AND rec.cash_receipt_id = cv_cash_receipt_id
 AND pay.customer_trx_id = cv_customer_trx_id
 AND rec.application_ref_type = 'CLAIM'
 AND rec.display = 'Y'
 AND rec.secondary_application_ref_id = cv_root_claim_id;

l_old_applied_invoice    csr_old_applied_invoice%ROWTYPE;

CURSOR csr_claim_investigation_amount(cv_root_claim_id IN NUMBER) IS
  SELECT amount_applied
  FROM ar_receivable_applications
  WHERE application_ref_type = 'CLAIM'
  AND applied_payment_schedule_id = -4
  AND display = 'Y'
  AND secondary_application_ref_id = cv_root_claim_id;

CURSOR csr_cm_exist_on_rec(cv_cash_receipt_id IN NUMBER, cv_customer_trx_id IN NUMBER) IS
  SELECT amount_applied, apply_date -- Fix for Bug 3091401. TM passes old apply date
  FROM ar_receivable_applications
  WHERE cash_receipt_id = cv_cash_receipt_id
  AND applied_customer_trx_id = cv_customer_trx_id
  AND display = 'Y'
  AND status = 'APP';

l_settlement_amount NUMBER := NULL;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type = 'RECEIPT_OPM' THEN
     /*------------------------------------------------------------*
      | OVERPAYMENT -> Settle By Credit Memo --> Process Settlement Workflow
      *------------------------------------------------------------*/
      /*
      Process_Settlement_WF(
          p_claim_id         => p_claim_rec.claim_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => x_msg_data
         ,x_msg_count        => x_msg_count
      );
      */
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      IF p_payment_reference_id IS NULL OR
         p_payment_reference_id = FND_API.g_miss_num THEN
        /*------------------------------------------------------------*
         | No payment reference specified (No open credit memo specified) -> AutoInvoice
         *------------------------------------------------------------*/
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('No payment reference specified (No open credit memo specified) -> AutoInvoice.');
         END IF;
         -- 1. AutoInvoice
         OZF_AR_INTERFACE_PVT.Interface_Claim(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => p_claim_rec.claim_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

         --2. Update Deduction payment detail -- <Batch Process>: Fetcher program
         l_online_upd_ded_status := FALSE;

      ELSE -- payment_reference_id is not null and deduction_type IN ('SOURCE_DED', 'RECEIPT_DED')
        /*------------------------------------------------------------*
         | Update Claim Status to CLOSED.
         *------------------------------------------------------------*/
         /*
         Close_Claim(
             p_claim_rec        => p_claim_rec
            ,x_return_status    => l_return_status
            ,x_msg_data         => x_msg_data
            ,x_msg_count        => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         */

         OPEN csr_cm_exist_on_rec(p_claim_rec.receipt_id, p_payment_reference_id);
         FETCH csr_cm_exist_on_rec INTO l_cm_applied_on_rec_amt, l_apply_date; -- Fix for Bug 3091401. TM passes old apply date
         CLOSE csr_cm_exist_on_rec;


         IF p_deduction_type = 'SOURCE_DED' THEN
           /*------------------------------------------------------------*
            | Invoice Deduction -> 1. Update amount in dispute
            |                      2. Apply credit memo with amount_settled on receipt.
            |                      3. Reapply invoice related deduction.
            | <<Pay by Previous Open Credit Memo which already exists on the receipt>>:
            | Invoice Deduction -> 1. Update amount in dispute
            |                      2. Reapply credit memo with increase amount on receipt.
            |                      3. Reapply invoice related deduction.
            *------------------------------------------------------------*/

            OPEN csr_old_applied_invoice( p_claim_rec.receipt_id
                                        , p_claim_rec.source_object_id
                                        , p_claim_rec.root_claim_id
                                        );
            FETCH csr_old_applied_invoice INTO l_old_applied_invoice;
            CLOSE csr_old_applied_invoice;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message('Invoice Deduction -> 1. Update amount in dispute');
            END IF;
            -- 1. Update amount in dispute
            OZF_AR_Payment_PVT.Update_dispute_amount(
                p_claim_rec          => p_claim_rec
               ,p_dispute_amount     => (p_credit_memo_amount * -1)
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_cm_applied_on_rec_amt IS NULL THEN
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction -> 2. Apply creit memo on receipt');
               END IF;
               -- 2. Apply creit memo on receipt
               OZF_AR_Payment_PVT.Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount => (p_credit_memo_amount * -1)
                  ,p_comments           => p_claim_rec.comments
                  ,p_customer_reference => p_claim_rec.customer_ref_number
		  ,p_claim_id           => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status      => l_return_status
                  ,x_msg_data           => x_msg_data
                  ,x_msg_count          => x_msg_count
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;
            ELSE
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction: Pay by Previous Open Credit Memo which already exists on the receipt');
                  OZF_Utility_PVT.debug_message('Invoice Deduction -> 2. Reapply creit memo on receipt');
               END IF;

              l_settlement_amount := (p_credit_memo_amount * -1);--Bug4308188
              -- 2. Reapply credit memo on receipt
              arp_deduction_cover2.reapply_credit_memo(
		                p_customer_trx_id => p_payment_reference_id ,
		                p_cash_receipt_id => p_claim_rec.receipt_id,
		                p_amount_applied  => l_cm_applied_on_rec_amt + (p_credit_memo_amount * -1),
		                p_init_msg_list    => FND_API.g_false,
		                x_return_status   => l_return_status,
		                x_msg_count      => x_msg_count,
		                x_msg_data        => x_msg_data);
              IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message('Invoice Deduction -> 3. Unapply claim investigation');
               OZF_Utility_PVT.debug_message('original invoice deduction amount = '||l_old_applied_invoice.amount_applied);
               OZF_Utility_PVT.debug_message('reapply invoice deduction amount = '||(l_old_applied_invoice.amount_applied + p_credit_memo_amount));
            END IF;
            -- 3. Reapply claim investigation
            OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
                p_claim_rec          => p_claim_rec
               ,p_reapply_amount     => l_old_applied_invoice.amount_applied + p_credit_memo_amount
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

            l_online_upd_ded_status := TRUE;

         ELSIF p_deduction_type = 'RECEIPT_DED' THEN
            IF l_cm_applied_on_rec_amt IS NULL THEN
              /*------------------------------------------------------------*
               | Receipt Deduction -> 1. Apply credit memo on receipt.
               |                      2. Unapply claim investigation
               | <<Pay by Previous Open Credit Memo which already exists on the receipt>>:
               | Receipt Deduction -> 0.5. Unapply credit memo on receipt
               |                      1. Apply credit memo with increased amount on receipt
               |                      2. Unapply claim investigation
               *------------------------------------------------------------*/
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 1. Apply creit memo on receipt');
               END IF;
               -- 1. Apply creit memo on receipt
               OZF_AR_Payment_PVT.Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount => (p_credit_memo_amount * -1)
                  ,p_comments           => p_claim_rec.comments
                  ,p_customer_reference => p_claim_rec.customer_ref_number
		  ,p_claim_id           => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status      => l_return_status
                  ,x_msg_data           => x_msg_data
                  ,x_msg_count          => x_msg_count
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 2. Unapply claim investigation');
               END IF;
            ELSE
              /*------------------------------------------------------------*
               | Receipt Deduction
               *------------------------------------------------------------*/
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction: Pay by Previous Open Credit Memo which already exists on the receipt');
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 1. Reapply credit memo with increased amount on receipt');
               END IF;

               l_settlement_amount := (p_credit_memo_amount * -1); --Bug4308188
               -- 2. Reapply credit memo on receipt
               arp_deduction_cover2.reapply_credit_memo(
		                p_customer_trx_id => p_payment_reference_id ,
		                p_cash_receipt_id => p_claim_rec.receipt_id,
		                p_amount_applied  => l_cm_applied_on_rec_amt + (p_credit_memo_amount * -1),
		                p_init_msg_list    => FND_API.g_false,
		                x_return_status   => l_return_status,
		                x_msg_count      => x_msg_count,
 		                x_msg_data        => x_msg_data);
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;

            -- 2. Unapply claim investigation
            OPEN csr_claim_investigation_amount(p_claim_rec.root_claim_id);
            FETCH csr_claim_investigation_amount INTO l_orig_dispute_amount;
            CLOSE csr_claim_investigation_amount;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message('original claim investigation amount = '||l_orig_dispute_amount);
               OZF_Utility_PVT.debug_message('reapply claim investigation amount = '||(l_orig_dispute_amount + p_credit_memo_amount));
            END IF;
            OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
                p_claim_rec          => p_claim_rec
               ,p_reapply_amount     => l_orig_dispute_amount + p_credit_memo_amount --(l_orig_reapply_amount - p_credit_memo_amount) * -1
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
            l_online_upd_ded_status := TRUE;
         END IF; -- end if p_deduction_type = 'SOURCE_DED', elsif p_deduction_type = 'DEDUCTION_DED'
      END IF; -- end if payment_reference_id is null

     /*------------------------------------------------------------*
      | Update payment detail
      *------------------------------------------------------------*/
      IF l_online_upd_ded_status THEN
         -- Update Deduction payment detail
         OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => p_claim_rec.claim_id
            ,p_payment_method         => 'PREV_OPEN_CREDIT'
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => p_payment_reference_id
            ,p_adjust_id              => NULL
            ,p_settlement_doc_id      => p_settlement_doc_id
            ,p_settlement_mode        => 'MASS_SETTLEMENT'
            ,p_settlement_amount      => l_settlement_amount --Bug4308188
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

   END IF;

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

END Pay_by_Credit_Memo;


/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Debit_Memo
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Debit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_payment_reference_id   IN    NUMBER
   ,p_debit_memo_amount      IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version    CONSTANT NUMBER       := 1.0;
  l_api_name       CONSTANT VARCHAR2(30) := 'Pay_by_Debit_Memo';
  l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status           VARCHAR2(1);

  l_dm_trx_type_id          NUMBER;
  l_online_upd_ded_status   BOOLEAN     := FALSE;
  l_orig_dispute_amount     NUMBER;
  l_payment_trx_number      VARCHAR2(30);
  l_dm_applied_on_rec_amt   NUMBER;
  l_apply_date ar_receivable_applications.apply_date%TYPE; -- Fix for Bug 3091401. TM passes old apply date

  CURSOR csr_dm_trx_type_id(cv_claim_type_id IN NUMBER) IS
    SELECT dm_trx_type_id
    FROM ozf_claim_types_all_b
    WHERE claim_type_id = cv_claim_type_id;

  CURSOR csr_claim_investigation_amount(cv_root_claim_id IN NUMBER) IS
     SELECT amount_applied
     FROM ar_receivable_applications
     WHERE application_ref_type = 'CLAIM'
     AND applied_payment_schedule_id = -4
     AND display = 'Y'
     AND secondary_application_ref_id = cv_root_claim_id;

   CURSOR csr_payment_trx_number(cv_customer_trx_id IN NUMBER) IS
     SELECT trx_number
     FROM ra_customer_trx
     WHERE customer_trx_id = cv_customer_trx_id;

  CURSOR csr_dm_exist_on_rec(cv_cash_receipt_id IN NUMBER, cv_customer_trx_id IN NUMBER) IS
     SELECT amount_applied, apply_date -- Fix for Bug 3091401. TM passes old apply date
     FROM ar_receivable_applications
     WHERE cash_receipt_id = cv_cash_receipt_id
     AND applied_customer_trx_id = cv_customer_trx_id
     AND display = 'Y'
     AND status = 'APP';

l_settlement_amount NUMBER := NULL;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type = 'RECEIPT_OPM' THEN
      IF p_payment_reference_id IS NULL THEN
        /*------------------------------------------------------------*
         | OVERPAYMENT -> No open debit memo specified --> AutoInvoice
         *------------------------------------------------------------*/
         -- 1. AutoInvoice
         OZF_AR_INTERFACE_PVT.Interface_Claim(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => p_claim_rec.claim_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

         --2. Update Deduction payment detail -- <Batch Process>: Fetcher program
         l_online_upd_ded_status := FALSE;
      ELSE
        /*------------------------------------------------------------*
         | Update Claim Status to CLOSED.
         *------------------------------------------------------------*/
         /*
         Close_Claim(
             p_claim_rec        => p_claim_rec
            ,x_return_status    => l_return_status
            ,x_msg_data         => x_msg_data
            ,x_msg_count        => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         */

        /*------------------------------------------------------------*
         | Overpayment -> 1. Unapply claim investigation
         |                2. Apply debit memo on receipt.
         | <<Pay by Previous Open Debit Memo which already exists on the receipt>>:
         | Overpayment -> 1. Unapply claim investigation
         |                1.5. Unapply debit memo on receipt
         |                2. Apply debit memo on receipt.
         *------------------------------------------------------------*/
         OPEN csr_dm_exist_on_rec(p_claim_rec.receipt_id, p_payment_reference_id);
         FETCH csr_dm_exist_on_rec INTO l_dm_applied_on_rec_amt, l_apply_date; -- Fix for Bug 3091401. TM passes old apply date
         CLOSE csr_dm_exist_on_rec;

         OZF_Utility_PVT.debug_message('Overpayment -> 1. Unapply claim investigation');
         -- 1. Unapply claim investigation
         OPEN csr_claim_investigation_amount(p_claim_rec.root_claim_id);
         FETCH csr_claim_investigation_amount INTO l_orig_dispute_amount;
         CLOSE csr_claim_investigation_amount;

         OZF_Utility_PVT.debug_message('original overpayment amount = '||l_orig_dispute_amount);
         OZF_Utility_PVT.debug_message('reapply overpayment amount = '||(l_orig_dispute_amount + p_debit_memo_amount));

         OZF_AR_Payment_PVT.Unapply_Claim_Investigation(
             p_claim_rec          => p_claim_rec
            ,p_reapply_amount     => (l_orig_dispute_amount + p_debit_memo_amount)
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;


         IF l_dm_applied_on_rec_amt IS NULL THEN
            OZF_Utility_PVT.debug_message('Overpayment -> 2. Apply debit memo on receipt');
            -- 2. Apply debit memo on receipt
            OZF_AR_Payment_PVT.Apply_on_Receipt(
                p_cash_receipt_id    => p_claim_rec.receipt_id
               ,p_customer_trx_id    => p_payment_reference_id
               ,p_new_applied_amount => p_debit_memo_amount * -1
               ,p_comments           => p_claim_rec.comments
               ,p_customer_reference => p_claim_rec.customer_ref_number --11.5.10 enhancements. TM should pass.
	       ,p_claim_id           => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            OZF_Utility_PVT.debug_message('Overpayment: Pay by Previous Open Debit Memo which already exists on the receipt');
            OZF_Utility_PVT.debug_message('Overpayment -> 1.5. Unapply debit memo on receipt');
            -- 1.5. Unapply creit memo on receipt
            OZF_AR_Payment_PVT.Unapply_from_Receipt(
                p_cash_receipt_id    => p_claim_rec.receipt_id
               ,p_customer_trx_id    => p_payment_reference_id
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

            OZF_Utility_PVT.debug_message('Overpayment -> 2. Apply debit memo with increased amount on receipt');
            l_settlement_amount := (p_debit_memo_amount * -1); --Bug4308188
            -- 2. Apply creit memo on receipt
            OZF_AR_Payment_PVT.Apply_on_Receipt(
                p_cash_receipt_id    => p_claim_rec.receipt_id
               ,p_customer_trx_id    => p_payment_reference_id
               ,p_new_applied_amount => l_dm_applied_on_rec_amt + (p_debit_memo_amount * -1)
               ,p_comments           => p_claim_rec.comments
               ,p_apply_date         => l_apply_date -- Fix for Bug 3091401. TM passes old apply date
	       ,p_claim_id           => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;

         l_online_upd_ded_status := TRUE;
      END IF;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
   END IF;


  /*------------------------------------------------------------*
   | Update Deduction payment detail
   *------------------------------------------------------------*/
   IF l_online_upd_ded_status THEN
      -- Update Deduction payment detail
      OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_id               => p_claim_rec.claim_id
         ,p_payment_method         => 'PREV_OPEN_DEBIT'
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => p_claim_rec.receipt_id
         ,p_customer_trx_id        => p_payment_reference_id
         ,p_adjust_id              => NULL
         ,p_settlement_doc_id      => p_settlement_doc_id
         ,p_settlement_mode        => 'MASS_SETTLEMENT'
         ,p_settlement_amount      => l_settlement_amount --Bug4308188
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

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

END Pay_by_Debit_Memo;


/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Chargeback
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Chargeback(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_chargeback_amount      IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER
   ,p_gl_date                IN    DATE

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Chargeback';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);

  l_cb_customer_trx_id   NUMBER;
  l_chargeback_amount    NUMBER;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
  /*------------------------------------------------------------*
   | Update Claim Status to CLOSED.
   *------------------------------------------------------------*/
   /*
   Close_Claim(
       p_claim_rec        => p_claim_rec
      ,x_return_status    => l_return_status
      ,x_msg_data         => x_msg_data
      ,x_msg_count        => x_msg_count
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   */
   IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
      IF p_deduction_type = 'SOURCE_DED'THEN
         l_chargeback_amount := p_chargeback_amount;
      ELSIF p_deduction_type = 'RECEIPT_DED'THEN
         l_chargeback_amount := p_chargeback_amount * -1;
      END IF;

      OZF_AR_Payment_PVT.Create_AR_Chargeback(
          p_claim_rec          => p_claim_rec
         ,p_chargeback_amount  => l_chargeback_amount
         ,p_gl_date            => p_gl_date
         ,x_cb_customer_trx_id => l_cb_customer_trx_id
         ,x_return_status      => l_return_status
         ,x_msg_data           => x_msg_data
         ,x_msg_count          => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('x_cb_customer_trx_id = '||l_cb_customer_trx_id);
      END IF;

     /*------------------------------------------------------------*
      | Update Deduction payment detail
      *------------------------------------------------------------*/
      IF l_cb_customer_trx_id IS NOT NULL THEN
         -- Update Deduction payment detail
         OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => p_claim_rec.claim_id
            ,p_payment_method         => 'CHARGEBACK'
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => l_cb_customer_trx_id
            ,p_adjust_id              => NULL
            ,p_settlement_doc_id      => p_settlement_doc_id
            ,p_settlement_mode        => 'MASS_SETTLEMENT'
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
   END IF;


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

END Pay_by_Chargeback;


/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Write_Off
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Write_Off(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_write_off_amount       IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER
   ,p_gl_date                IN    DATE
   ,p_wo_rec_trx_id          IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Write_Off';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);

  l_wo_adjust_id         NUMBER;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type = 'RECEIPT_DED' AND
      NOT ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed THEN
     /*------------------------------------------------------------
      | Receipt Deduction -> Invoke Settlement Workflow
      *-----------------------------------------------------------*/
      OZF_AR_PAYMENT_PVT.Process_Settlement_WF(
          p_claim_id         => p_claim_rec.claim_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => x_msg_data
         ,x_msg_count        => x_msg_count
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

         BEGIN
            UPDATE ozf_claims_all
            SET payment_status = 'PENDING'
            ,   status_code = 'PENDING_CLOSE'
            ,   user_status_id = OZF_UTILITY_PVT.get_default_user_status(
                                    'OZF_CLAIM_STATUS'
                                   ,'PENDING_CLOSE'
                                 )
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

   ELSIF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED', 'RECEIPT_OPM') THEN
     /*------------------------------------------------------------*
      | Update Claim Status to CLOSED.
      *------------------------------------------------------------*/
      /*
      Close_Claim(
          p_claim_rec        => p_claim_rec
         ,x_return_status    => l_return_status
         ,x_msg_data         => x_msg_data
         ,x_msg_count        => x_msg_count
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
      */

      OZF_AR_Payment_PVT.Create_AR_Write_Off(
          p_claim_rec          => p_claim_rec
         ,p_deduction_type     => p_deduction_type
         ,p_write_off_amount   => p_write_off_amount
         ,p_gl_date            => p_gl_date
         ,p_wo_rec_trx_id      => p_wo_rec_trx_id
         ,x_wo_adjust_id       => l_wo_adjust_id
         ,x_return_status      => l_return_status
         ,x_msg_data           => x_msg_data
         ,x_msg_count          => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

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

END Pay_by_Write_Off;


/*=======================================================================*
 | PROCEDURE
 |    Pay_by_On_Account_Credit
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_On_Account_Credit(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_credit_amount          IN    NUMBER
   ,p_settlement_doc_id      IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_On_Account_Credit';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);

CURSOR csr_old_claim_investigation( cv_cash_receipt_id IN NUMBER
                                  , cv_root_claim_id IN NUMBER
                                  ) IS
 SELECT rec.amount_applied
 FROM ar_receivable_applications rec
 WHERE rec.applied_payment_schedule_id = -4
 AND rec.cash_receipt_id = cv_cash_receipt_id
 AND rec.application_ref_type = 'CLAIM'
 AND rec.display = 'Y'
 AND rec.secondary_application_ref_id = cv_root_claim_id;

l_old_applied_claim_amount NUMBER;
l_reapply_claim_amount     NUMBER;

BEGIN
   -------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
  /*------------------------------------------------------------*
   | Update Claim Status to CLOSED.
   *------------------------------------------------------------*/
   /*
   Close_Claim(
       p_claim_rec        => p_claim_rec
      ,x_return_status    => l_return_status
      ,x_msg_data         => x_msg_data
      ,x_msg_count        => x_msg_count
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   */

   IF p_deduction_type = 'RECEIPT_OPM' THEN
     /*------------------------------------------------------------*
      | Overpayment -> 1. Unapply claim investigation
      |                2. Apply On Account Credit
      *------------------------------------------------------------*/
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('Overpayment -> 1. Unapply claim investigation.');
      END IF;
      -- 1. Unapply claim investigation
      OPEN csr_old_claim_investigation(p_claim_rec.receipt_id, p_claim_rec.root_claim_id);
      FETCH csr_old_claim_investigation INTO l_old_applied_claim_amount;
      CLOSE csr_old_claim_investigation;

      l_reapply_claim_amount := l_old_applied_claim_amount - (p_credit_amount * -1);

      OZF_AR_PAYMENT_PVT.Unapply_Claim_Investigation(
          p_claim_rec          => p_claim_rec
         ,p_reapply_amount     => l_reapply_claim_amount --0
         ,x_return_status      => l_return_status
         ,x_msg_data           => x_msg_data
         ,x_msg_count          => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('Overpayment -> 2. Apply On Account Credit.');
      END IF;
      --2. Apply On Account Credit
      OZF_AR_PAYMENT_PVT.Apply_On_Account_Credit(
          p_claim_rec          => p_claim_rec
         ,p_credit_amount      => p_credit_amount
         ,x_return_status      => l_return_status
         ,x_msg_data           => x_msg_data
         ,x_msg_count          => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

     /*------------------------------------------------------------*
      | Update Deduction payment detail
      *------------------------------------------------------------*/
      -- Update Deduction payment detail
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('cash_receipt_id = '||p_claim_rec.receipt_id);
      END IF;
      OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_id               => p_claim_rec.claim_id
         ,p_payment_method         => p_claim_rec.payment_method
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => p_claim_rec.receipt_id
         ,p_customer_trx_id        => NULL --p_claim_rec.payment_reference_id
         ,p_adjust_id              => NULL
         ,p_settlement_doc_id      => p_settlement_doc_id
         ,p_settlement_mode        => 'MASS_SETTLEMENT'
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

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

END Pay_by_On_Account_Credit;


/*=======================================================================*
 | PROCEDURE
 |    Break_Mass_Settlement
 |
 | NOTES
 |
 | HISTORY
 |    20-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Break_Mass_Settlement(
   p_group_claim_id          IN  NUMBER,
   p_settlement_type         IN  VARCHAR2,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER
)
IS
l_api_version           CONSTANT NUMBER       := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Break_Mass_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);
l_source_object_id               NUMBER;
l_wo_rec_trx_id                  NUMBER;
---

CURSOR csr_claims( cv_group_claim_id IN NUMBER
                 , cv_claim_class IN VARCHAR2
                 ) IS
   SELECT claim_id
   ,      claim_number
   ,      claim_class
   ,      receipt_id
   ,      receipt_number
   ,      source_object_id
   ,      source_object_number
   ,      amount_remaining
   FROM ozf_claims_all
   WHERE group_claim_id = cv_group_claim_id
   AND claim_class = cv_claim_class
   ORDER BY claim_date, group_claim_id;


CURSOR csr_settle_docs_group(cv_group_claim_id IN NUMBER) IS
   SELECT settlement_doc_id
   ,      payment_method
   ,      settlement_id
   ,      settlement_number
   ,      settlement_type_id
   ,      settlement_amount
   ,      gl_date
   ,      wo_rec_trx_id
   FROM ozf_settlement_docs_all
   WHERE claim_id = cv_group_claim_id;
   -- add addtional order by clause for mass settlement ordering rule criteria

CURSOR csr_get_source_object_id(cv_claim_id IN NUMBER) IS
   SELECT source_object_id
   FROM ozf_claims
   WHERE claim_id = cv_claim_id;

TYPE l_csr_claim_tbl IS TABLE OF csr_claims%ROWTYPE
   INDEX BY BINARY_INTEGER;
--l_claim_group_tbl                l_csr_claim_tbl;
--l_claim_netting_tbl              l_csr_claim_tbl;
l_claim_group_tbl                OZF_Claim_PVT.claim_tbl_type;
l_claim_netting_tbl              OZF_Claim_PVT.claim_tbl_type;
l_settle_doc_group_tbl           OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_settle_doc_tbl                 OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_settle_doc_tbl2                OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_settle_doc_id_tbl              JTF_NUMBER_TABLE;
l_group_claim_line_rec           OZF_Claim_line_Pvt.claim_line_rec_type;
l_group_claim_line_tbl           OZF_Claim_line_Pvt.claim_line_tbl_type;
l_idx_netting_claim              NUMBER;
l_idx_settle_doc_group           NUMBER;
l_idx                            NUMBER := 1;
l_idx_setl_doc                   NUMBER := 1;
l_idx_setl_doc2                  NUMBER := 1;
l_amount_settled                 NUMBER;
i                                BINARY_INTEGER;
l_err_idx                        NUMBER;

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Break_Mass_Settlement;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ start -------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('Settlement Type = '||p_settlement_type);
   END IF;

   IF p_settlement_type <> 'NETTING' THEN
      l_idx := 1;
      OPEN csr_settle_docs_group(p_group_claim_id);
      LOOP
         FETCH csr_settle_docs_group INTO l_settle_doc_group_tbl(l_idx).settlement_doc_id
                                        , l_settle_doc_group_tbl(l_idx).payment_method
                                        , l_settle_doc_group_tbl(l_idx).settlement_id
                                        , l_settle_doc_group_tbl(l_idx).settlement_number
                                        , l_settle_doc_group_tbl(l_idx).settlement_type_id
                                        , l_settle_doc_group_tbl(l_idx).settlement_amount
                                        , l_settle_doc_group_tbl(l_idx).gl_date
                                        , l_settle_doc_group_tbl(l_idx).wo_rec_trx_id;
         EXIT WHEN csr_settle_docs_group%NOTFOUND;
         l_idx := l_idx + 1;
      END LOOP;
      CLOSE csr_settle_docs_group;
   END IF;


   l_idx := 1;
   IF p_settlement_type = 'NETTING' THEN
      OPEN csr_claims(p_group_claim_id, 'DEDUCTION');
      LOOP
         FETCH csr_claims INTO l_claim_group_tbl(l_idx).claim_id
                             , l_claim_group_tbl(l_idx).claim_number
                             , l_claim_group_tbl(l_idx).claim_class
                             , l_claim_group_tbl(l_idx).receipt_id
                             , l_claim_group_tbl(l_idx).receipt_number
                             , l_claim_group_tbl(l_idx).source_object_id
                             , l_claim_group_tbl(l_idx).source_object_number
                             , l_claim_group_tbl(l_idx).amount_remaining;
         EXIT WHEN csr_claims%NOTFOUND;
         l_idx := l_idx + 1;
      END LOOP;
      CLOSE csr_claims;
   ELSE
      OPEN csr_claims(p_group_claim_id, p_settlement_type);
      LOOP
         FETCH csr_claims INTO l_claim_group_tbl(l_idx).claim_id
                             , l_claim_group_tbl(l_idx).claim_number
                             , l_claim_group_tbl(l_idx).claim_class
                             , l_claim_group_tbl(l_idx).receipt_id
                             , l_claim_group_tbl(l_idx).receipt_number
                             , l_claim_group_tbl(l_idx).source_object_id
                             , l_claim_group_tbl(l_idx).source_object_number
                             , l_claim_group_tbl(l_idx).amount_remaining;
         EXIT WHEN csr_claims%NOTFOUND;
         l_idx := l_idx + 1;
      END LOOP;
      CLOSE csr_claims;
   END IF;

   l_idx := 1;
   IF p_settlement_type IN ('DEDUCTION', 'NETTING') THEN
      OPEN csr_claims(p_group_claim_id, 'OVERPAYMENT');
      LOOP
         FETCH csr_claims INTO l_claim_netting_tbl(l_idx).claim_id
                             , l_claim_netting_tbl(l_idx).claim_number
                             , l_claim_netting_tbl(l_idx).claim_class
                             , l_claim_netting_tbl(l_idx).receipt_id
                             , l_claim_netting_tbl(l_idx).receipt_number
                             , l_claim_netting_tbl(l_idx).source_object_id
                             , l_claim_netting_tbl(l_idx).source_object_number
                             , l_claim_netting_tbl(l_idx).amount_remaining;
         EXIT WHEN csr_claims%NOTFOUND;
         l_idx := l_idx + 1;
      END LOOP;
      CLOSE csr_claims;
   ELSIF p_settlement_type = 'OVERPAYMENT' THEN
      OPEN csr_claims(p_group_claim_id, 'DEDUCTION');
      LOOP
         FETCH csr_claims INTO l_claim_netting_tbl(l_idx).claim_id
                             , l_claim_netting_tbl(l_idx).claim_number
                             , l_claim_netting_tbl(l_idx).claim_class
                             , l_claim_netting_tbl(l_idx).receipt_id
                             , l_claim_netting_tbl(l_idx).receipt_number
                             , l_claim_netting_tbl(l_idx).source_object_id
                             , l_claim_netting_tbl(l_idx).source_object_number
                             , l_claim_netting_tbl(l_idx).amount_remaining;
         EXIT WHEN csr_claims%NOTFOUND;
         l_idx := l_idx + 1;
      END LOOP;
      CLOSE csr_claims;
   END IF;

   l_idx_netting_claim := l_claim_netting_tbl.FIRST;
   l_idx_settle_doc_group := l_settle_doc_group_tbl.FIRST;

   l_idx_setl_doc := 1;
   i := l_claim_group_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_group_claim_line_tbl(i).claim_id := p_group_claim_id;
         l_group_claim_line_tbl(i).claim_currency_amount := l_claim_group_tbl(i).amount_remaining;
         l_group_claim_line_tbl(i).payment_reference_id := l_claim_group_tbl(i).claim_id;
         l_group_claim_line_tbl(i).payment_reference_number := l_claim_group_tbl(i).claim_number;
         l_group_claim_line_tbl(i).payment_method := 'MASS_SETTLEMENT';

         --------------------------------------
         -- Assign Settlement Docs for Claim --
         --------------------------------------
         l_amount_settled := l_claim_group_tbl(i).amount_remaining;

         WHILE ABS(l_amount_settled) > 0 LOOP
            -- Get settlement docs from netting claims
            WHILE l_idx_netting_claim IS NOT NULL AND
                  l_amount_settled <> 0 LOOP
               l_settle_doc_tbl(l_idx_setl_doc).claim_id                 := l_claim_group_tbl(i).claim_id;
               l_settle_doc_tbl(l_idx_setl_doc).settlement_id            := l_claim_netting_tbl(l_idx_netting_claim).receipt_id;
               --l_settle_doc_tbl(l_idx_setl_doc).settlement_type_id     := ??;
               l_settle_doc_tbl(l_idx_setl_doc).settlement_number        := l_claim_netting_tbl(l_idx_netting_claim).receipt_number;
               l_settle_doc_tbl(l_idx_setl_doc).payment_method           := l_claim_netting_tbl(l_idx_netting_claim).claim_class;
               l_settle_doc_tbl(l_idx_setl_doc).payment_reference_id     := l_claim_netting_tbl(l_idx_netting_claim).claim_id;
               l_settle_doc_tbl(l_idx_setl_doc).payment_reference_number := l_claim_netting_tbl(l_idx_netting_claim).claim_number;
               l_settle_doc_tbl(l_idx_setl_doc).payment_status           := 'PENDING';
               l_settle_doc_tbl(l_idx_setl_doc).group_claim_id           := p_group_claim_id;

               l_settle_doc_tbl2(l_idx_setl_doc2).claim_id                 := l_claim_netting_tbl(l_idx_netting_claim).claim_id;
               l_settle_doc_tbl2(l_idx_setl_doc2).settlement_id            := l_claim_group_tbl(i).receipt_id;
               --l_settle_doc_tbl2(l_idx_setl_doc2).settlement_type_id     := ??;
               l_settle_doc_tbl2(l_idx_setl_doc2).settlement_number        := l_claim_group_tbl(i).receipt_number;
               l_settle_doc_tbl2(l_idx_setl_doc2).payment_method           := l_claim_group_tbl(i).claim_class;
               l_settle_doc_tbl2(l_idx_setl_doc2).payment_reference_id     := l_claim_group_tbl(i).claim_id;
               l_settle_doc_tbl2(l_idx_setl_doc2).payment_reference_number := l_claim_group_tbl(i).claim_number;
               l_settle_doc_tbl2(l_idx_setl_doc2).payment_status           := 'PENDING';
               l_settle_doc_tbl2(l_idx_setl_doc2).group_claim_id           := p_group_claim_id;


               IF l_claim_netting_tbl(l_idx_netting_claim).amount_remaining = 0 THEN
                   -- Bug4386869: Amount is already utilized

                  l_settle_doc_tbl2.delete(l_idx_setl_doc2);
                  l_idx_setl_doc2 := l_idx_setl_doc2 - 1;
                  EXIT WHEN l_idx_netting_claim = l_claim_netting_tbl.LAST;
                  l_idx_netting_claim := l_claim_netting_tbl.NEXT(l_idx_netting_claim);

               ELSIF ABS(l_amount_settled) >= ABS(l_claim_netting_tbl(l_idx_netting_claim).amount_remaining) THEN
                  l_settle_doc_tbl(l_idx_setl_doc).settlement_amount := l_claim_netting_tbl(l_idx_netting_claim).amount_remaining;

                  l_settle_doc_tbl2(l_idx_setl_doc2).settlement_amount:= l_settle_doc_tbl(l_idx_setl_doc).settlement_amount * -1;

                  l_amount_settled := l_amount_settled
                                    - (l_claim_netting_tbl(l_idx_netting_claim).amount_remaining * -1);


                  l_claim_netting_tbl(l_idx_netting_claim).amount_remaining := 0;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('('||l_idx_setl_doc||')'||
                                                   l_group_claim_line_tbl(i).payment_reference_number||
                                                   ' ... '||
                                                   l_settle_doc_tbl(l_idx_setl_doc).settlement_amount||
                                                   ' >>> '||l_settle_doc_tbl(l_idx_setl_doc).payment_reference_number||
                                                   '('||l_settle_doc_tbl(l_idx_setl_doc).settlement_number||
                                                   ')'
                                                  );
                  END IF;

                  l_idx_setl_doc := l_idx_setl_doc + 1;
                  l_idx_setl_doc2 := l_idx_setl_doc2 + 1;

                  EXIT WHEN l_idx_netting_claim = l_claim_netting_tbl.LAST;
                  l_idx_netting_claim := l_claim_netting_tbl.NEXT(l_idx_netting_claim);
                  l_idx_setl_doc2 := 1;
               ELSE
                  l_settle_doc_tbl(l_idx_setl_doc).settlement_amount := l_amount_settled * -1;

                  l_settle_doc_tbl2(l_idx_setl_doc2).settlement_amount:= l_settle_doc_tbl(l_idx_setl_doc).settlement_amount * -1;

                  l_claim_netting_tbl(l_idx_netting_claim).amount_remaining := l_claim_netting_tbl(l_idx_netting_claim).amount_remaining
                                                                             - (l_amount_settled * -1);


                  l_amount_settled := 0;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('('||l_idx_setl_doc||')'||
                                                   l_group_claim_line_tbl(i).payment_reference_number||
                                                   ' ... '||
                                                   l_settle_doc_tbl(l_idx_setl_doc).settlement_amount||
                                                   ' >>> '||l_settle_doc_tbl(l_idx_setl_doc).payment_reference_number||
                                                   '('||l_settle_doc_tbl(l_idx_setl_doc).settlement_number||
                                                   ')'
                                                  );
                  END IF;

                  l_idx_setl_doc := l_idx_setl_doc + 1;
                  l_idx_setl_doc2 := l_idx_setl_doc2 + 1;

                  EXIT WHEN l_amount_settled = 0;
                  EXIT WHEN l_idx_netting_claim = l_claim_netting_tbl.LAST;
                  --l_idx_netting_claim := l_claim_netting_tbl.NEXT(l_idx_netting_claim);
               END IF;
            END lOOP;

            -- Get settlement docs from open/new transactions
            WHILE l_idx_settle_doc_group IS NOT NULL AND
                  l_amount_settled <> 0 LOOP
               l_settle_doc_tbl(l_idx_setl_doc).claim_id           := l_claim_group_tbl(i).claim_id;
               l_settle_doc_tbl(l_idx_setl_doc).settlement_id      := l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_id;
               l_settle_doc_tbl(l_idx_setl_doc).settlement_type_id := l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_type_id;
               l_settle_doc_tbl(l_idx_setl_doc).settlement_number  := l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_number;
               l_settle_doc_tbl(l_idx_setl_doc).payment_method     := l_settle_doc_group_tbl(l_idx_settle_doc_group).payment_method;
               l_settle_doc_tbl(l_idx_setl_doc).gl_date            := l_settle_doc_group_tbl(l_idx_settle_doc_group).gl_date;
               l_settle_doc_tbl(l_idx_setl_doc).wo_rec_trx_id      := l_settle_doc_group_tbl(l_idx_settle_doc_group).wo_rec_trx_id;
               l_settle_doc_tbl(l_idx_setl_doc).payment_status     := 'PENDING';
               l_settle_doc_tbl(l_idx_setl_doc).group_claim_id     := p_group_claim_id;

               IF l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount = 0 THEN
                   -- Bug4386869: Amount is already utilized

                  EXIT WHEN l_idx_settle_doc_group = l_settle_doc_group_tbl.LAST;
                  l_idx_settle_doc_group := l_settle_doc_group_tbl.NEXT(l_idx_settle_doc_group);

               ELSIF ABS(l_amount_settled) >= ABS(l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount) THEN
                  l_settle_doc_tbl(l_idx_setl_doc).settlement_amount := l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount;

                  l_amount_settled := l_amount_settled + l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount;

                  l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount := 0;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('('||l_idx_setl_doc||')'||
                                                   l_group_claim_line_tbl(i).payment_reference_number||
                                                   ' ... '||
                                                   l_settle_doc_tbl(l_idx_setl_doc).settlement_amount||
                                                   ' >>> '||l_settle_doc_tbl(l_idx_setl_doc).payment_method||
                                                   '('||l_settle_doc_tbl(l_idx_setl_doc).settlement_number||
                                                   ')'
                                                  );
                  END IF;

                  l_idx_setl_doc := l_idx_setl_doc + 1;

                  EXIT WHEN l_idx_settle_doc_group = l_settle_doc_group_tbl.LAST;
                  l_idx_settle_doc_group := l_settle_doc_group_tbl.NEXT(l_idx_settle_doc_group);
               ELSE

                  l_settle_doc_tbl(l_idx_setl_doc).settlement_amount := l_amount_settled * -1;

                  l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount := l_settle_doc_group_tbl(l_idx_settle_doc_group).settlement_amount
                                                                                 + l_amount_settled;

                  l_amount_settled := 0;

                  IF OZF_DEBUG_HIGH_ON THEN
                     OZF_Utility_PVT.debug_message('('||l_idx_setl_doc||')'||
                                                   l_group_claim_line_tbl(i).payment_reference_number||
                                                   ' ... '||
                                                   l_settle_doc_tbl(l_idx_setl_doc).settlement_amount||
                                                   ' >>> '||l_settle_doc_tbl(l_idx_setl_doc).payment_method||
                                                   '('||l_settle_doc_tbl(l_idx_setl_doc).settlement_number||
                                                   ')'
                                                  );
                  END IF;

                  l_idx_setl_doc := l_idx_setl_doc + 1;

                  EXIT WHEN l_amount_settled = 0;
                  EXIT WHEN l_idx_settle_doc_group = l_settle_doc_group_tbl.LAST;
                  l_idx_settle_doc_group := l_settle_doc_group_tbl.NEXT(l_idx_settle_doc_group);
               END IF;

            END lOOP;
         END LOOP;
         EXIT WHEN i = l_claim_group_tbl.LAST;
         i := l_claim_group_tbl.NEXT(i);
      END LOOP;
   END IF;
   --//Bug 5345095
    i := l_settle_doc_tbl.FIRST;
    IF i IS NOT NULL THEN
      LOOP
          IF(l_settle_doc_tbl(i).payment_method = 'WRITE_OFF') THEN
             OPEN  csr_get_source_object_id(l_settle_doc_tbl(i).claim_id);
             FETCH csr_get_source_object_id INTO l_source_object_id;
             CLOSE csr_get_source_object_id;


            IF(l_source_object_id IS NULL) THEN
               l_wo_rec_trx_id := l_settle_doc_tbl(i).wo_rec_trx_id;
            ELSE
               l_wo_rec_trx_id := l_settle_doc_tbl(i).settlement_type_id;
            END IF;

            IF l_wo_rec_trx_id IS NOT NULL THEN
               l_settle_doc_tbl(i).wo_rec_trx_id := l_wo_rec_trx_id;
               l_settle_doc_tbl(i).settlement_type_id := null;
            END IF;
          END IF;

          EXIT WHEN i = l_settle_doc_tbl.LAST;
          i := l_settle_doc_tbl.NEXT(i);
      END LOOP;
   END IF;


   IF OZF_DEBUG_HIGH_ON THEN
      i := l_group_claim_line_tbl.FIRST;
      IF i IS NOT NULL THEN
         OZF_Utility_PVT.debug_message('--- Mass Settlement Claims ---');
         LOOP
            OZF_Utility_PVT.debug_message('--- '||i||' ---');
            OZF_Utility_PVT.debug_message('l_group_claim_line_tbl('||i||').claim_currency_amount    = '||l_group_claim_line_tbl(i).claim_currency_amount);
            OZF_Utility_PVT.debug_message('l_group_claim_line_tbl('||i||').payment_reference_number = '||l_group_claim_line_tbl(i).payment_reference_number);
            EXIT WHEN i = l_group_claim_line_tbl.LAST;
            i := l_group_claim_line_tbl.NEXT(i);
         END LOOP;
      END IF;
   END IF;

   -----------------------------------------------
   -- Create break Claim Lines for Master Claim --
   -----------------------------------------------
   IF l_group_claim_line_tbl.COUNT IS NOT NULL AND
      l_group_claim_line_tbl.COUNT > 0 THEN
      OZF_Claim_Line_PVT.Create_Claim_Line_Tbl(
         p_api_version       => l_api_version
        ,p_init_msg_list     => FND_API.g_false
        ,p_commit            => FND_API.g_false
        ,p_validation_level  => FND_API.g_valid_level_full
        ,x_return_status     => l_return_status
        ,x_msg_data          => x_msg_data
        ,x_msg_count         => x_msg_count
        ,p_claim_line_tbl    => l_group_claim_line_tbl
        ,p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
        ,x_error_index       => l_err_idx
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;


   IF OZF_DEBUG_HIGH_ON THEN
      i := l_settle_doc_tbl.FIRST;
      IF i IS NOT NULL THEN
         OZF_Utility_PVT.debug_message('--- Mass Settlement Payment Details ---');
         LOOP
            OZF_Utility_PVT.debug_message('--- '||i||' ---');
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').claim_id                 = '||l_settle_doc_tbl(i).claim_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').settlement_id            = '||l_settle_doc_tbl(i).settlement_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').settlement_number        = '||l_settle_doc_tbl(i).settlement_number);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').settlement_amount        = '||l_settle_doc_tbl(i).settlement_amount);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').payment_method           = '||l_settle_doc_tbl(i).payment_method);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').payment_reference_id     = '||l_settle_doc_tbl(i).payment_reference_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl('||i||').payment_reference_number = '||l_settle_doc_tbl(i).payment_reference_number);
            EXIT WHEN i = l_settle_doc_tbl.LAST;
            i := l_settle_doc_tbl.NEXT(i);
         END LOOP;
      END IF;
      i := l_settle_doc_tbl2.FIRST;
      IF i IS NOT NULL THEN
         OZF_Utility_PVT.debug_message('--- Mass Settlement Group Payment Details ---');
         LOOP
            OZF_Utility_PVT.debug_message('--- '||i||' ---');
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').claim_id                 = '||l_settle_doc_tbl2(i).claim_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').settlement_id            = '||l_settle_doc_tbl2(i).settlement_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').settlement_number        = '||l_settle_doc_tbl2(i).settlement_number);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').settlement_amount        = '||l_settle_doc_tbl2(i).settlement_amount);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').payment_method           = '||l_settle_doc_tbl2(i).payment_method);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').payment_reference_id     = '||l_settle_doc_tbl2(i).payment_reference_id);
            OZF_Utility_PVT.debug_message('l_settle_doc_tbl2('||i||').payment_reference_number = '||l_settle_doc_tbl2(i).payment_reference_number);
            EXIT WHEN i = l_settle_doc_tbl2.LAST;
            i := l_settle_doc_tbl2.NEXT(i);
         END LOOP;
      END IF;
   END IF;

   ----------------------------------
   -- Create break Settlement Docs --
   ----------------------------------
   IF l_settle_doc_tbl.COUNT IS NOT NULL AND
      l_settle_doc_tbl.COUNT > 0 THEN
      OZF_Settlement_Doc_PVT.Create_Settlement_Doc_Tbl(
          p_api_version_number    => l_api_version,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          x_return_status         => l_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_settlement_doc_tbl    => l_settle_doc_tbl,
          x_settlement_doc_id_tbl => l_settle_doc_id_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF l_settle_doc_tbl2.COUNT IS NOT NULL AND
      l_settle_doc_tbl2.COUNT > 0 THEN
      OZF_Settlement_Doc_PVT.Create_Settlement_Doc_Tbl(
          p_api_version_number    => l_api_version,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
          x_return_status         => l_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data,
          p_settlement_doc_tbl    => l_settle_doc_tbl2,
          x_settlement_doc_id_tbl => l_settle_doc_id_tbl
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Break_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Break_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Break_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Break_Mass_Settlement;


/*=======================================================================*
 | PROCEDURE
 |    Complete_Mass_Settlement
 |
 | NOTES
 |
 | HISTORY
 |    20-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Complete_Mass_Settlement(
   p_group_claim_id          IN  NUMBER,
   x_claim_tbl               OUT NOCOPY OZF_Claim_PVT.claim_tbl_type,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_data                OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER
)
IS
l_api_version           CONSTANT NUMBER       := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Complete_Mass_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);
---

CURSOR csr_claims_group( cv_group_claim_id IN NUMBER) IS
   SELECT claim_id
   ,      claim_number
   ,      object_version_number
   FROM ozf_claims_all
   WHERE group_claim_id = cv_group_claim_id;

-- Fix for 5376466
CURSOR csr_sysparam_defaults IS
  SELECT gl_date_type
  FROM ozf_sys_parameters;

i                                NUMBER := 1;
l_claim_obj_ver_num              NUMBER;
l_gl_date_type                   VARCHAR2(30);

l_claim_pvt_rec                  OZF_Claim_PVT.claim_rec_type;


BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Complete_Mass_Settlement;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ start -------------------------

   OPEN csr_sysparam_defaults;
   FETCH csr_sysparam_defaults INTO l_gl_date_type;
   CLOSE csr_sysparam_defaults;

   OPEN csr_claims_group(p_group_claim_id);
   LOOP
      FETCH csr_claims_group INTO x_claim_tbl(i).claim_id
                                , x_claim_tbl(i).claim_number
                                , x_claim_tbl(i).object_version_number;
      EXIT WHEN csr_claims_group%NOTFOUND;

      IF l_gl_date_type IS NULL THEN
          x_claim_tbl(i).gl_date := sysdate;
      END IF;

      x_claim_tbl(i).payment_method := 'MASS_SETTLEMENT';
      x_claim_tbl(i).status_code := 'COMPLETE';
      x_claim_tbl(i).user_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                                'OZF_CLAIM_STATUS'
                                               ,'COMPLETE'
                                       );
      i := i + 1;
   END LOOP;
   CLOSE csr_claims_group;



   i := x_claim_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT', x_claim_tbl(i).claim_number);
            FND_MSG_PUB.Add;
         END IF;

         OZF_Claim_PVT.Update_Claim (
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_commit                 => FND_API.G_FALSE
            ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim                  => x_claim_tbl(i)
            ,p_event                  => 'UPDATE'
         	,p_mode                   => OZF_claim_Utility_pvt.G_AUTO_MODE
            ,x_object_version_number  => l_claim_obj_ver_num
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         x_claim_tbl(i).object_version_number := l_claim_obj_ver_num;
         EXIT WHEN i = x_claim_tbl.LAST;
         i := x_claim_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Complete_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Complete_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Complete_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Complete_Mass_Settlement;


/*=======================================================================*
 | PROCEDURE
 |    Approve_Mass_Settlement
 |
 | NOTES
 |
 | HISTORY
 |    20-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Approve_Mass_Settlement(
   p_group_claim_id           IN  NUMBER,
   p_complete_claim_group_tbl IN  OZF_Claim_PVT.claim_tbl_type,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER
)
IS
l_api_version           CONSTANT NUMBER       := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Approve_Mass_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);
---
l_complete_claim_group_tbl       OZF_Claim_PVT.claim_tbl_type := p_complete_claim_group_tbl;
l_claim_pvt_rec                  OZF_Claim_PVT.claim_rec_type;
l_claim_obj_ver_num              NUMBER;
i                                BINARY_INTEGER;
l_group_claim_obj_ver            NUMBER;
l_orig_status_id                 NUMBER;
l_new_status_id                  NUMBER;
l_reject_status_id               NUMBER;
l_owner_id                       NUMBER;
l_appr_req                       VARCHAR2(1);

CURSOR csr_claim_obj_ver(cv_claim_id IN NUMBER) IS
   SELECT object_version_number
   FROM ozf_claims_all
   WHERE claim_id = cv_claim_id;

CURSOR csr_mass_setl_appr_req IS
   SELECT NVL(attr_available_flag, 'N')
     FROM ams_custom_setup_attr
    WHERE object_attribute = 'APPR'
      AND custom_setup_id =( SELECT custom_setup_id
                             FROM ams_custom_setups_b
                             WHERE activity_type_code = 'GROUP'
                               AND object_type = 'CLAM'
                               AND enabled_flag = 'Y' );

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Approve_Mass_Settlement;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ start -------------------------

   OPEN csr_mass_setl_appr_req;
   FETCH csr_mass_setl_appr_req INTO l_appr_req;
   CLOSE csr_mass_setl_appr_req;

   i := p_complete_claim_group_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_claim_pvt_rec := p_complete_claim_group_tbl(i);
         OPEN csr_claim_obj_ver(p_complete_claim_group_tbl(i).claim_id);
         FETCH csr_claim_obj_ver INTO l_claim_pvt_rec.object_version_number;
         CLOSE csr_claim_obj_ver;

         l_claim_pvt_rec.user_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                              'OZF_CLAIM_STATUS'
                                             ,'PENDING_APPROVAL'
                                           );
         l_claim_pvt_rec.status_code := 'PENDING_APPROVAL';

         OZF_Claim_PVT.Update_Claim (
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.G_FALSE
            ,p_commit                 => FND_API.G_FALSE
            ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim                  => l_claim_pvt_rec --l_complete_claim_group_tbl(i)
            ,p_event                  => 'UPDATE'
         	,p_mode                   => OZF_claim_Utility_pvt.G_AUTO_MODE
            ,x_object_version_number  => l_claim_obj_ver_num
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         EXIT WHEN i = p_complete_claim_group_tbl.LAST;
         i := p_complete_claim_group_tbl.NEXT(i);
      END LOOP;
   END IF;

   ------------------------------
   -- Mass Settlement Approval --
   ------------------------------
   IF l_appr_req = 'Y' THEN
      OPEN csr_claim_obj_ver(p_group_claim_id);
      FETCH csr_claim_obj_ver INTO l_group_claim_obj_ver;
      CLOSE csr_claim_obj_ver;

      l_orig_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                  'OZF_CLAIM_STATUS'
                                 ,'OPEN'
                          );

      l_new_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                  'OZF_CLAIM_STATUS'
                                 ,'CLOSED'
                         );

      l_reject_status_id := OZF_UTILITY_PVT.get_default_user_status(
                                  'OZF_CLAIM_STATUS'
                                 ,'REJECTED'
                            );

      l_owner_id := OZF_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);

       --//Added by BKUNJAN Bug#5686706
	  UPDATE ozf_claims_all
	      SET payment_status = 'PENDING'
	      ,   status_code = 'PENDING_APPROVAL'
	      ,   user_status_id = OZF_UTILITY_PVT.get_default_user_status(
					  'OZF_CLAIM_STATUS'
					 ,'PENDING_APPROVAL'
				   )
	      WHERE claim_id = p_group_claim_id;
	--End of Addition

      AMS_GEN_APPROVAL_PVT.StartProcess(
         p_activity_type         => 'CLAM'
        ,p_activity_id           => p_group_claim_id
        ,p_approval_type         => 'CLAIM'
        ,p_object_version_number => l_group_claim_obj_ver
        ,p_orig_stat_id          => l_orig_status_id
        ,p_new_stat_id           => l_new_status_id
        ,p_reject_stat_id        => l_reject_status_id
        ,p_requester_userid      => l_owner_id
        ,p_notes_from_requester  => null
        ,p_workflowprocess       => 'AMSGAPP'
        ,p_item_type             => 'AMSGAPP'
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

     --//Commented by BKUNJAN Bug#5686706
    /*
      UPDATE ozf_claims_all
      SET payment_status = 'PENDING'
      ,   status_code = 'PENDING_APPROVAL'
      ,   user_status_id = OZF_UTILITY_PVT.get_default_user_status(
                                  'OZF_CLAIM_STATUS'
                                 ,'PENDING_APPROVAL'
                           )
      WHERE claim_id = p_group_claim_id;
    */
    -- End of Comments

   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;


EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Approve_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Approve_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Approve_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Approve_Mass_Settlement;

/*=======================================================================*
 | PROCEDURE
 |    Reject_Mass_Payment
 |
 | NOTES
 |
 | HISTORY
 |    17-FEB-2006  sshivali  Create.
 *=======================================================================*/
PROCEDURE Reject_Mass_Payment(
   p_group_claim_id           IN  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER
)
IS
l_api_version            CONSTANT NUMBER       := 1.0;
l_api_name               CONSTANT VARCHAR2(30) := 'Reject_Mass_Payment';
l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                   VARCHAR2(1);
l_rejected_user_status_id         NUMBER;
l_open_user_status_id             NUMBER;

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  default_flag = 'Y'
  AND  system_status_code = cv_status_code;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   OPEN csr_user_status_id('REJECTED');
   FETCH csr_user_status_id INTO l_rejected_user_status_id;
   CLOSE csr_user_status_id;

   OPEN csr_user_status_id('OPEN');
   FETCH csr_user_status_id INTO l_open_user_status_id;
   CLOSE csr_user_status_id;

   BEGIN
      SAVEPOINT Reject_Mass_Payment;

      UPDATE ozf_claims_all
      SET status_code = 'REJECTED'
      ,   user_status_id = l_rejected_user_status_id
      WHERE claim_id = p_group_claim_id;

      --bug5460095
      UPDATE ozf_claims_all
      SET status_code = 'OPEN'
      ,   user_status_id = l_open_user_status_id
      ,   amount_remaining = amount - NVL(amount_adjusted,0)
      ,   acctd_amount_remaining = acctd_amount - NVL(acctd_amount_adjusted,0)
      ,   amount_settled = 0
      ,   acctd_amount_settled = 0
      ,   group_claim_id = null
      ,   payment_method = null
      WHERE group_claim_id = p_group_claim_id;

      UPDATE ozf_settlement_docs_all
      SET payment_status = 'CANCELLED'
      WHERE  group_claim_id = p_group_claim_id;

   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO Reject_Mass_Payment;
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
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Reject_Mass_Payment;

/*=======================================================================*
 | PROCEDURE
 |    Start_Mass_Payment
 |
 | NOTES
 |
 | HISTORY
 |    20-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Start_Mass_Payment(
   p_group_claim_id           IN  NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER
)
IS
l_api_version            CONSTANT NUMBER       := 1.0;
l_api_name               CONSTANT VARCHAR2(30) := 'Start_Mass_Payment';
l_full_name              CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                   VARCHAR2(1);
---

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  default_flag = 'Y'
  AND  system_status_code = cv_status_code;

CURSOR csr_master_claim_lines(cv_group_claim_id IN NUMBER) IS
   SELECT payment_reference_id
   FROM ozf_claim_lines_all
   WHERE claim_id = cv_group_claim_id;

CURSOR csr_settle_docs(cv_claim_id IN NUMBER, cv_group_claim_id IN NUMBER) IS
   SELECT settlement_doc_id
   ,      payment_method
   ,      settlement_id
   ,      settlement_number
   ,      settlement_type_id
   ,      settlement_amount
   ,      payment_reference_id
   ,      payment_reference_number
   ,      group_claim_id
   ,      gl_date
   ,      wo_rec_trx_id
   FROM ozf_settlement_docs_all
   WHERE claim_id = cv_claim_id
   AND   group_claim_id = cv_group_claim_id
   AND   payment_status <> 'CANCELLED';

TYPE number_tbl IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

l_claim_id_tbl                    number_tbl;
l_claim_rec                       OZF_Claim_PVT.claim_rec_type;
l_settlement_doc_tbl              OZF_Settlement_Doc_PVT.settlement_doc_tbl_type;
l_deduction_type                  VARCHAR2(30);
l_settlement_id                   NUMBER;
i                                 NUMBER := 1;
j                                 NUMBER := 1;
l_close_user_status_id            NUMBER;

--//Bugfix :8202109
l_history_event_description VARCHAR2(2000);
l_history_event             VARCHAR2(30);
l_needed_to_create          VARCHAR2(1) := 'N';
l_claim_history_id          NUMBER := null;

l_status_code               VARCHAR2(30) := NULL;
l_user_status_id            NUMBER := NULL;
l_claim_rec_hist            OZF_CLAIM_PVT.claim_rec_type;

CURSOR cur_current_status (p_claim_id IN NUMBER)IS
   SELECT status_code,
          user_status_id
   FROM   ozf_claims_all
   WHERE  claim_id =p_claim_id;

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Start_Mass_Payment;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ start -------------------------
   OPEN csr_master_claim_lines(p_group_claim_id);
   LOOP
      FETCH csr_master_claim_lines INTO l_claim_id_tbl(i);
      EXIT WHEN csr_master_claim_lines%NOTFOUND;
      i := i + 1;
   END LOOP;
   CLOSE csr_master_claim_lines;

   i := l_claim_id_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         OZF_AR_Payment_PVT.Query_Claim(
             p_claim_id           => l_claim_id_tbl(i)
            ,x_claim_rec          => l_claim_rec
            ,x_return_status      => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         -- Bug435194: Close claim before making payment
         Close_Claim(
             p_group_claim_id     => p_group_claim_id
            ,p_claim_id           => l_claim_id_tbl(i)
            ,x_return_status      => l_return_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
          --//Bugfix :8202109
          --//Populate History tables after Closing the Claim
          --===================

         OPEN  cur_current_status(l_claim_id_tbl(i));
         FETCH cur_current_status INTO l_status_code,l_user_status_id;
         CLOSE cur_current_status;

         IF l_status_code ='CLOSED' THEN
            l_claim_rec.status_code       :=l_status_code;
            l_claim_rec.user_status_id    :=l_user_status_id;

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
                        p_claim_id                   => l_claim_id_tbl(i),
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
       --//End

         IF l_claim_rec.claim_class = 'DEDUCTION' THEN
            IF l_claim_rec.source_object_class IS NULL AND
               l_claim_rec.source_object_id IS NULL THEN
               l_deduction_type := 'RECEIPT_DED';
            ELSE
               l_deduction_type := 'SOURCE_DED';
            END IF;
         ELSIF l_claim_rec.claim_class = 'OVERPAYMENT' THEN
            IF l_claim_rec.source_object_class IS NULL AND
               l_claim_rec.source_object_id IS NULL THEN
               l_deduction_type := 'RECEIPT_OPM';
            ELSE
               l_deduction_type := 'SOURCE_OPM';
            END IF;
         END IF;

         j := 1;
         OPEN csr_settle_docs(l_claim_id_tbl(i), p_group_claim_id);
         LOOP
            FETCH csr_settle_docs INTO l_settlement_doc_tbl(j).settlement_doc_id
                                     , l_settlement_doc_tbl(j).payment_method
                                     , l_settlement_doc_tbl(j).settlement_id
                                     , l_settlement_doc_tbl(j).settlement_number
                                     , l_settlement_doc_tbl(j).settlement_type_id
                                     , l_settlement_doc_tbl(j).settlement_amount
                                     , l_settlement_doc_tbl(j).payment_reference_id
                                     , l_settlement_doc_tbl(j).payment_reference_number
                                     , l_settlement_doc_tbl(j).group_claim_id
                                     , l_settlement_doc_tbl(j).gl_date
                                     , l_settlement_doc_tbl(j).wo_rec_trx_id;
            EXIT WHEN csr_settle_docs%NOTFOUND;
            j := j + 1;
         END LOOP;
         CLOSE csr_settle_docs;


         j := l_settlement_doc_tbl.FIRST;
         IF j IS NOT NULL THEN
            LOOP
               IF OZF_DEBUG_HIGH_ON THEN
                  OZF_Utility_PVT.debug_message('Payment -- ('||j||')');
                  OZF_Utility_PVT.debug_message('Payment -- payment_method    = '||l_settlement_doc_tbl(j).payment_method);
                  OZF_Utility_PVT.debug_message('Payment -- settlement_doc_id = '||l_settlement_doc_tbl(j).settlement_doc_id);
                  OZF_Utility_PVT.debug_message('Payment -- settlement_id     = '||l_settlement_doc_tbl(j).settlement_id);
                  OZF_Utility_PVT.debug_message('Payment -- settlement_number = '||l_settlement_doc_tbl(j).settlement_number);
                  OZF_Utility_PVT.debug_message('Payment -- settlement_amount = '||l_settlement_doc_tbl(j).settlement_amount);
                  OZF_Utility_PVT.debug_message('Payment -- payment_reference_id = '||l_settlement_doc_tbl(j).payment_reference_id);
                  OZF_Utility_PVT.debug_message('Payment -- payment_reference_number = '||l_settlement_doc_tbl(j).payment_reference_number);
               END IF;

               BEGIN
                  UPDATE ozf_settlement_docs_all
                  SET payment_status = 'PENDING_PAID'
                  WHERE settlement_doc_id = l_settlement_doc_tbl(j).settlement_doc_id;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                        FND_MESSAGE.set_name('OZF', 'OZF_SETL_DOC_UPD_ERR');
                        FND_MSG_PUB.add;
                     END IF;
                     IF OZF_DEBUG_LOW_ON THEN
                        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                        FND_MESSAGE.Set_Token('TEXT',sqlerrm);
                        FND_MSG_PUB.Add;
                     END IF;
                     RAISE FND_API.g_exc_unexpected_error;
               END;

               IF l_settlement_doc_tbl(j).payment_method = 'CREDIT_MEMO' THEN
                  Pay_by_Credit_Memo(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_payment_reference_id   => l_settlement_doc_tbl(j).settlement_id
                     ,p_credit_memo_amount     => (l_settlement_doc_tbl(j).settlement_amount * -1)
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               ELSIF l_settlement_doc_tbl(j).payment_method = 'DEBIT_MEMO' THEN
                  Pay_by_Debit_Memo(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_payment_reference_id   => l_settlement_doc_tbl(j).settlement_id
                     ,p_debit_memo_amount      => (l_settlement_doc_tbl(j).settlement_amount * -1)
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               ELSIF l_settlement_doc_tbl(j).payment_method = 'CHARGEBACK' THEN
                  Pay_by_Chargeback(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_chargeback_amount      => (l_settlement_doc_tbl(j).settlement_amount * -1)
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,p_gl_date                => l_settlement_doc_tbl(j).gl_date
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               ELSIF l_settlement_doc_tbl(j).payment_method = 'WRITE_OFF' THEN
                  Pay_by_Write_Off(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_write_off_amount       => (l_settlement_doc_tbl(j).settlement_amount * -1)
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,p_gl_date                => l_settlement_doc_tbl(j).gl_date
                     ,p_wo_rec_trx_id          => l_settlement_doc_tbl(j).wo_rec_trx_id
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               ELSIF l_settlement_doc_tbl(j).payment_method = 'ON_ACCT_CREDIT' THEN
                  Pay_by_On_Account_Credit(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_credit_amount          => (l_settlement_doc_tbl(j).settlement_amount * -1)
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               ELSIF l_settlement_doc_tbl(j).payment_method IN ('DEDUCTION', 'OVERPAYMENT') THEN
                  Pay_by_Open_Receipt(
                      p_claim_rec              => l_claim_rec
                     ,p_deduction_type         => l_deduction_type
                     ,p_open_receipt_id        => l_settlement_doc_tbl(j).settlement_id
                     ,p_payment_claim_id       => l_settlement_doc_tbl(j).payment_reference_id
                     ,p_amount_applied         => l_settlement_doc_tbl(j).settlement_amount
                     ,p_settlement_doc_id      => l_settlement_doc_tbl(j).settlement_doc_id
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  --//Bugfix: 8202109
                  OPEN  cur_current_status(l_settlement_doc_tbl(j).payment_reference_id);
                  FETCH cur_current_status INTO l_status_code,l_user_status_id;
                  CLOSE cur_current_status;

               -- Bug4124810: Close payment claim
                  Close_Claim(
                    p_group_claim_id     => p_group_claim_id
                   ,p_claim_id           => l_settlement_doc_tbl(j).payment_reference_id
                  ,x_return_status      => l_return_status
      	      );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                 END IF;

		 --//Update Claim History
		 IF l_status_code <>'CLOSED' THEN
		    l_claim_rec_hist.claim_id       :=l_settlement_doc_tbl(j).payment_reference_id;
		    l_claim_rec_hist.status_code    :='CLOSED';
		    l_claim_rec_hist.user_status_id :=OZF_UTILITY_PVT.get_default_user_status('OZF_CLAIM_STATUS','CLOSED');

		    OZF_claims_history_PVT.Check_Create_History(
			p_claim                     => l_claim_rec_hist,
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
				p_claim_id                   => l_settlement_doc_tbl(j).payment_reference_id,
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
		--//End

               END IF;
               EXIT WHEN j = l_settlement_doc_tbl.LAST;
               j := l_settlement_doc_tbl.NEXT(j);
            END LOOP;
         END IF;
         EXIT WHEN i = l_claim_id_tbl.LAST;
         i := l_claim_id_tbl.NEXT(i);
         l_settlement_doc_tbl.DELETE;
      END LOOP;
   END IF;

   -----------------------
   -- Close Claim Group --
   -----------------------
   OPEN csr_user_status_id('CLOSED');
   FETCH csr_user_status_id INTO l_close_user_status_id;
   CLOSE csr_user_status_id;

   BEGIN
      UPDATE ozf_claims_all
      SET payment_status = 'PAID'
      ,   status_code = 'CLOSED'
      ,   user_status_id = l_close_user_status_id
      WHERE claim_id = p_group_claim_id;
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
      ROLLBACK TO Start_Mass_Payment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Start_Mass_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
     ROLLBACK TO Start_Mass_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Start_Mass_Payment;



/*=======================================================================
 | PROCEDURE
 |    Settle_Mass_Settlement
 |
 | NOTES
 |
 | HISTORY
 |    20-OCT-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Settle_Mass_Settlement(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2
   ,p_commit                 IN  VARCHAR2
   ,p_validation_level       IN  NUMBER

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_group_claim_rec        IN  group_claim_rec
   ,p_open_claim_tbl         IN  open_claim_tbl
   ,p_open_transaction_tbl   IN  open_transaction_tbl
   ,p_payment_method_tbl     IN  claim_payment_method_tbl

   ,x_claim_group_id         OUT NOCOPY NUMBER
   ,x_claim_group_number     OUT NOCOPY VARCHAR2
   --,x_split_claim_tbl        OUT NOCOPY open_claim_tbl
)
IS
l_api_version           CONSTANT NUMBER       := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Settle_Mass_Settlement';
l_full_name             CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                  VARCHAR2(1);
---

CURSOR csr_claim_amount_rem(cv_claim_id IN NUMBER) IS
   SELECT amount_remaining
   ,      object_version_number
   FROM ozf_claims_all
   WHERE claim_id = cv_claim_id;

CURSOR csr_get_set_of_books IS
   SELECT set_of_books_id
   FROM ozf_sys_parameters;

CURSOR csr_mass_setl_appr_req IS
   SELECT NVL(attr_available_flag, 'N')
   FROM ams_custom_setup_attr
   WHERE object_attribute = 'APPR'
     AND custom_setup_id = ( SELECT custom_setup_id
                             FROM ams_custom_setups_b
                             WHERE activity_type_code = 'GROUP'
                               AND object_type = 'CLAM'
                               AND enabled_flag = 'Y' );


CURSOR csr_get_gl_date_type(cv_set_of_books_id IN NUMBER) IS
     SELECT gl_date_type
     FROM ozf_sys_parameters
     WHERE set_of_books_id = cv_set_of_books_id;

--//Bugfix : 7661712
CURSOR p_acctd_claim_amts(p_claim_id IN NUMBER) IS
   SELECT acctd_amount,
          acctd_amount_adjusted,
          amount,
          amount_adjusted
   FROM ozf_claims_all
   WHERE claim_id =p_claim_id;

l_ded_claim_tbl                  OZF_Claim_PVT.claim_tbl_type;
l_opm_claim_tbl                  OZF_Claim_PVT.claim_tbl_type;
l_settle_doc_tbl                 OZF_Settlement_Doc_Pvt.settlement_doc_tbl_type;
l_split_claim_tbl                OZF_Split_Claim_PVT.child_claim_tbl_type;
l_idx_ded                        NUMBER := 1;
l_idx_opm                        NUMBER := 1;

l_group_claim_rec                OZF_Claim_PVT.claim_rec_type;
l_group_claim_id                 NUMBER;
l_group_claim_line_tbl           OZF_Claim_Line_PVT.claim_line_tbl_type;
l_group_settle_doc_tbl           OZF_Settlement_Doc_Pvt.settlement_doc_tbl_type;
l_group_settle_doc_id_tbl        JTF_NUMBER_TABLE;
l_idx_claim_line                 NUMBER := 1;
l_idx_setl_doc                   NUMBER := 1;

l_open_claim_tbl                 open_claim_tbl := p_open_claim_tbl;

l_open_claim_amt                 NUMBER := 0;
l_open_trx_amt                   NUMBER := 0;
l_pay_method_amt                 NUMBER := 0;

l_group_claim_amt                NUMBER := 0;
l_group_trx_amt                  NUMBER := 0;
l_group_settle_amt               NUMBER := 0;
l_group_rem_amt                  NUMBER := 0;

l_settlement_type                VARCHAR2(30);
l_claim_amount_rem               NUMBER;
l_obj_ver_num                    NUMBER;

l_complete_claim_group_tbl       OZF_Claim_PVT.claim_tbl_type;
i                                BINARY_INTEGER;
l_appr_req                       VARCHAR2(1);


l_overpay_amt                    NUMBER := 0;
l_total_settle_amt               NUMBER := 0;
l_gl_date_type                   VARCHAR2(30);

--bug4768031
l_deduction_count                NUMBER := 0;
l_overpayment_count              NUMBER := 0;

--//Bugfix : 7439145
l_act_amt                        NUMBER :=0;
l_act_amt_settled                NUMBER :=0;
l_act_amt_adjusted               NUMBER :=0;

--//Bugfix : 7661712
l_amt                           NUMBER :=0;
l_amt_settled                   NUMBER :=0;
l_amt_adjusted                  NUMBER :=0;

/*
l_gl_date                        DATE;
l_wo_rec_trx_id                  NUMBER;
*/

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Settle_Mass_Settlement;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ------------------------ start -------------------------
   -------------------
   -- 1. Validation --
   -------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('1. Validation');
   END IF;

   i := p_open_claim_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_open_claim_amt := l_open_claim_amt + p_open_claim_tbl(i).amount_settled;

         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('open_claim_amt('||i||') = '||p_open_claim_tbl(i).amount_settled);
         END IF;
         IF p_open_claim_tbl(i).claim_class = l_settlement_type THEN
            l_overpay_amt := l_overpay_amt + l_open_claim_tbl(i).amount_settled * -1 ;
         END IF;

         --bug4768031
         IF p_open_claim_tbl(i).claim_class = 'DEDUCTION' THEN
            l_deduction_count := l_deduction_count + 1;
         ELSIF p_open_claim_tbl(i).claim_class = 'OVERPAYMENT' THEN
            l_overpayment_count := l_overpayment_count + 1;
         END IF;

         EXIT WHEN i = p_open_claim_tbl.LAST;
         i := p_open_claim_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF p_open_claim_tbl.LAST > 1 AND
      NOT ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_SETL_MUL_CLA_NS');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF SIGN(l_open_claim_amt) = 1 THEN
      l_settlement_type := 'DEDUCTION';
   ELSIF SIGN(l_open_claim_amt) = -1 THEN
     l_settlement_type := 'OVERPAYMENT';
   ELSIF SIGN(l_open_claim_amt) = 0 THEN
     l_settlement_type := 'NETTING';
   END IF;

   i := p_open_transaction_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF l_settlement_type = 'DEDUCTION' AND
            p_open_transaction_tbl(i).trx_class <> 'CM' THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_SETL_DED_POCM');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_error;
         ELSIF l_settlement_type = 'OVERPAYMENT' AND
            p_open_transaction_tbl(i).trx_class NOT IN ('INVOICE', 'INV', 'DM', 'CB') THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_SETL_OPM_PODM');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;

         l_open_trx_amt := l_open_trx_amt + p_open_transaction_tbl(i).amount_settled;
         EXIT WHEN i = p_open_transaction_tbl.LAST;
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('open_trx_amt('||i||') = '||p_open_transaction_tbl(i).amount_settled);
         END IF;
         i := p_open_transaction_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF ABS(l_open_claim_amt) < ABS(l_open_trx_amt) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_SETL_TRX_AMT_ERR');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   i := p_payment_method_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF l_settlement_type = 'DEDUCTION' AND
            p_payment_method_tbl(i).payment_method NOT IN ('WRITE_OFF', 'CHARGEBACK') THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_SETL_DED_ERR');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_error;
         ELSIF l_settlement_type = 'OVERPAYMENT' AND
            p_payment_method_tbl(i).payment_method NOT IN ('WRITE_OFF', 'ON_ACCT_CREDIT') THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_SETL_OPM_ERR');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;

         l_pay_method_amt := l_pay_method_amt + (p_payment_method_tbl(i).amount_settled * -1);
         EXIT WHEN i = p_payment_method_tbl.LAST;
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('pay_method_amt('||i||') = '||p_payment_method_tbl(i).amount_settled);
         END IF;
         /*
         l_gl_date := p_payment_method_tbl(i).gl_date;
         l_wo_rec_trx_id := p_payment_method_tbl(i).wo_rec_trx_id;
         */
         i := p_payment_method_tbl.NEXT(i);
      END LOOP;
   END IF;



   IF ABS(l_open_claim_amt) < (ABS(l_open_trx_amt) + ABS(l_pay_method_amt)) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_SETL_OPN_CLA_AMT_ERR');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   --bug4768031
   IF (ABS(l_open_trx_amt) = 0 AND ABS(l_pay_method_amt) = 0 AND
       ((l_overpayment_count = 0 AND l_deduction_count > 0) OR
       (l_overpayment_count > 0 AND l_deduction_count = 0))) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.Set_Name('OZF','OZF_SETL_DED_OPM_ERR');
         FND_MSG_PUB.Add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   /* Bug4079177: Claims should be split if the settlement amount is less then
      the settlement amount on the group. If the group is a deduction group,
      then the deductions should be split. Else the overpayments should be
      split.*/

   i := l_open_claim_tbl.FIRST;
   IF i IS NOT NULL AND l_settlement_type <> 'NETTING' THEN
      LOOP
         IF l_open_claim_tbl(i).claim_class <> l_settlement_type THEN
            l_overpay_amt := l_overpay_amt - ABS(l_open_claim_tbl(i).amount_settled)  ;
         END IF;
         EXIT WHEN i = l_open_claim_tbl.LAST;
         i := l_open_claim_tbl.NEXT(i);
      END LOOP;
   END IF;

   l_total_settle_amt := ABS(l_open_trx_amt) + ABS(l_pay_method_amt) + ABS(l_overpay_amt);
   i := l_open_claim_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF l_open_claim_tbl(i).claim_class = l_settlement_type THEN
            IF ABS(l_open_claim_tbl(i).amount_settled) < l_total_settle_amt THEN
                l_total_settle_amt := l_total_settle_amt - ABS(l_open_claim_tbl(i).amount_settled) ;
            ELSIF l_total_settle_amt = 0 THEN
                 l_open_claim_amt := l_open_claim_amt - l_open_claim_tbl(i).amount_settled;
                 l_open_claim_tbl.DELETE(i);
            ELSIF ABS(l_open_claim_tbl(i).amount_settled) > l_total_settle_amt THEN
                IF l_open_claim_tbl(i).claim_class = 'DEDUCTION' THEN
                   l_open_claim_tbl(i).amount_settled := l_total_settle_amt ;
                ELSE
                   l_open_claim_tbl(i).amount_settled := l_total_settle_amt * -1 ;
                END IF;
                l_total_settle_amt := 0;
            END IF;
         END IF;
         EXIT WHEN i = p_open_claim_tbl.LAST;
         i := l_open_claim_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('total open_claim_amt = '||l_open_claim_amt);
      OZF_Utility_PVT.debug_message('total open_trx_amt = '||l_open_trx_amt);
      OZF_Utility_PVT.debug_message('total pay_method_amt = '||l_pay_method_amt);
      OZF_Utility_PVT.debug_message('total claim_pay_amt = '||l_overpay_amt);
   END IF;


   ----------------------------
   -- 2. Create Master Claim --
   ----------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('2. Create Master Claim');
   END IF;

   -- Get Claim Type/Reason from Claim Defaulting Rule
   l_group_claim_rec.claim_class     := 'GROUP';
   l_group_claim_rec.cust_account_id := p_group_claim_rec.cust_account_id;
   l_group_claim_rec.claim_type_id   := p_group_claim_rec.claim_type_id;
   l_group_claim_rec.reason_code_id  := p_group_claim_rec.reason_code_id;
   l_group_claim_rec.amount          := l_open_claim_amt; --l_open_trx_amt + l_pay_method_amt;
   l_group_claim_rec.currency_code   := p_group_claim_rec.currency_code;
   l_group_claim_rec.cust_billto_acct_site_id := p_group_claim_rec.bill_to_site_id;
   l_group_claim_rec.org_id := p_group_claim_rec.org_id;
   l_group_claim_rec.user_status_id := 2006;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('group claim amount = '||l_group_claim_rec.amount);
   END IF;

   l_group_claim_rec.claim_date := SYSDATE;
   OPEN csr_get_set_of_books;
   FETCH csr_get_set_of_books INTO l_group_claim_rec.set_of_books_id;
   CLOSE csr_get_set_of_books;
   --l_group_claim_rec.currency_code := 'USD';
   l_group_claim_rec.payment_method := 'MASS_SETTLEMENT';

   OZF_Claim_PVT.Create_Claim (
       p_api_version            => l_api_version
      ,p_init_msg_list          => FND_API.G_FALSE
      ,p_commit                 => FND_API.G_FALSE
      ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count
      ,p_claim                  => l_group_claim_rec
      ,x_claim_id               => l_group_claim_id
   );
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('group claim id = '||l_group_claim_id);
   END IF;

   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   ---------------------
   -- 3. Group Claims --
   ---------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('3. Group Claims');
   END IF;

   i := l_open_claim_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Update Claim Id:'||l_open_claim_tbl(i).claim_id);
         END IF;

         BEGIN
            UPDATE ozf_claims_all
            SET   group_claim_id = l_group_claim_id
            --,   gl_date = l_gl_date
            --,   wo_rec_trx_id = l_wo_rec_trx_id
            WHERE claim_id = l_open_claim_tbl(i).claim_id;
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

         OPEN csr_claim_amount_rem(l_open_claim_tbl(i).claim_id);
         FETCH csr_claim_amount_rem INTO l_claim_amount_rem
                                       , l_obj_ver_num;
         CLOSE csr_claim_amount_rem;

         l_group_claim_amt := l_group_claim_amt + l_claim_amount_rem;

         -- -------------
         -- Split Claims
         -- -------------
         --ozf_utility_pvt.debug_message(l_open_claim_tbl(i).amount_settled||'amount settled');
         IF ABS(l_open_claim_tbl(i).amount_settled) < ABS(l_claim_amount_rem) THEN
            --l_split_claim_tbl(1).claim_type_id := p_claim_rec.claim_type_id;
            --l_split_claim_tbl(1).reason_code_id := p_claim_rec.reason_code_id;
            l_split_claim_tbl(1).amount := l_claim_amount_rem
                                         - l_open_claim_tbl(i).amount_settled;
            l_split_claim_tbl(1).line_amount_sum := 0;
            l_split_claim_tbl(1).parent_claim_id := l_open_claim_tbl(i).claim_id;
            l_split_claim_tbl(1).parent_object_ver_num := l_obj_ver_num;
            l_split_claim_tbl(1).line_table := NULL;

            OZF_Utility_PVT.debug_message('Split Claim '||l_open_claim_tbl(i).claim_number||' for '||l_split_claim_tbl(1).amount);

            l_group_rem_amt := l_group_rem_amt + l_split_claim_tbl(1).amount;

            OZF_SPLIT_CLAIM_PVT.create_child_claim_tbl (
                 p_api_version           => l_api_version
                ,p_init_msg_list         => FND_API.g_false
                ,p_commit                => FND_API.g_false
                ,p_validation_level      => FND_API.g_valid_level_full
                ,x_return_status         => l_return_status
                ,x_msg_data              => x_msg_data
                ,x_msg_count             => x_msg_count
                ,p_child_claim_tbl       => l_split_claim_tbl
                ,p_mode                  => 'AUTO'
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSIF ABS(l_open_claim_tbl(i).amount_settled) > ABS(l_claim_amount_rem) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_SETL_CLA_AMT_ERR');
               FND_MSG_PUB.Add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
         EXIT WHEN i = l_open_claim_tbl.LAST;
         i := l_open_claim_tbl.NEXT(i);
      END LOOP;
   END IF;

   ------------------------------
   -- 4. Group Settlement Docs --
   ------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('4. Group Settlement Docs');
   END IF;

   i := p_open_transaction_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_group_trx_amt := l_group_trx_amt + p_open_transaction_tbl(i).amount_settled;

         IF p_open_transaction_tbl(i).trx_class IN ('INV', 'DM', 'CB') THEN
            l_group_settle_doc_tbl(l_idx_setl_doc).payment_method := 'DEBIT_MEMO';
         ELSIF p_open_transaction_tbl(i).trx_class IN ('CM') THEN
            l_group_settle_doc_tbl(l_idx_setl_doc).payment_method := 'CREDIT_MEMO';
         END IF;
         l_group_settle_doc_tbl(l_idx_setl_doc).settlement_id      := p_open_transaction_tbl(i).customer_trx_id;
         l_group_settle_doc_tbl(l_idx_setl_doc).settlement_number  := p_open_transaction_tbl(i).trx_number;
         l_group_settle_doc_tbl(l_idx_setl_doc).settlement_type_id := p_open_transaction_tbl(i).cust_trx_type_id;
         l_group_settle_doc_tbl(l_idx_setl_doc).settlement_amount  := p_open_transaction_tbl(i).amount_settled;
         l_group_settle_doc_tbl(l_idx_setl_doc).payment_status     := 'PENDING';
         l_group_settle_doc_tbl(l_idx_setl_doc).claim_id           := l_group_claim_id;
         l_idx_setl_doc := l_idx_setl_doc + 1;
         EXIT WHEN i = p_open_transaction_tbl.LAST;
         i := p_open_transaction_tbl.NEXT(i);
      END LOOP;
   END IF;

   i := p_payment_method_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_group_settle_amt := l_group_settle_amt + p_payment_method_tbl(i).amount_settled;

         l_group_settle_doc_tbl(l_idx_setl_doc).payment_method     := p_payment_method_tbl(i).payment_method;
         l_group_settle_doc_tbl(l_idx_setl_doc).settlement_amount  := p_payment_method_tbl(i).amount_settled * -1;
         l_group_settle_doc_tbl(l_idx_setl_doc).gl_date            := p_payment_method_tbl(i).gl_date;
         --//Bug 5345095
	       IF p_payment_method_tbl(i).payment_method = 'WRITE_OFF' THEN
	          l_group_settle_doc_tbl(l_idx_setl_doc).settlement_type_id := p_payment_method_tbl(i).wo_adj_trx_id;
	       END IF;
         l_group_settle_doc_tbl(l_idx_setl_doc).wo_rec_trx_id      := p_payment_method_tbl(i).wo_rec_trx_id;
         l_group_settle_doc_tbl(l_idx_setl_doc).payment_status     := 'PENDING';
         l_group_settle_doc_tbl(l_idx_setl_doc).claim_id           := l_group_claim_id;

          IF l_group_settle_doc_tbl(l_idx_setl_doc).gl_date IS NULL AND
               l_group_settle_doc_tbl(l_idx_setl_doc).payment_method IN ('WRITE_OFF', 'CHARGEBACK') THEN
               OPEN csr_get_gl_date_type(l_group_claim_rec.set_of_books_id);
               FETCH csr_get_gl_date_type INTO l_gl_date_type;
               CLOSE csr_get_gl_date_type;

               IF l_gl_date_type = 'CLAIM_DATE' THEN
                  l_group_settle_doc_tbl(l_idx_setl_doc).gl_date := l_group_claim_rec.claim_date;
               ELSIF l_gl_date_type = 'DUE_DATE' THEN
                  l_group_settle_doc_tbl(l_idx_setl_doc).gl_date := l_group_claim_rec.due_date;
               ELSIF l_gl_date_type = 'SYSTEM_DATE' THEN
                  l_group_settle_doc_tbl(l_idx_setl_doc).gl_date := SYSDATE;
               END IF;

                 IF l_group_settle_doc_tbl(l_idx_setl_doc).gl_date IS NULL THEN
                    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                       FND_MESSAGE.Set_Name('OZF','OZF_CLAIM_NO_GL_DATE');
                       FND_MSG_PUB.Add;
                    END IF;
                    RAISE FND_API.g_exc_error;
                 END IF;
            END IF;

         l_idx_setl_doc := l_idx_setl_doc + 1;
         EXIT WHEN i = p_payment_method_tbl.LAST;
         i := p_payment_method_tbl.NEXT(i);
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      i := l_group_settle_doc_tbl.FIRST;
      IF i IS NOT NULL THEN
         LOOP
            OZF_Utility_PVT.debug_message('--- '||i||' ---');
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').claim_id (group)  = '||l_group_settle_doc_tbl(i).claim_id);
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').settlement_id     = '||l_group_settle_doc_tbl(i).settlement_id);
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').settlement_number = '||l_group_settle_doc_tbl(i).settlement_number);
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').settlement_amount = '||l_group_settle_doc_tbl(i).settlement_amount);
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').payment_method    = '||l_group_settle_doc_tbl(i).payment_method);
            OZF_Utility_PVT.debug_message('l_group_settle_doc_tbl('||i||').payment_status    = '||l_group_settle_doc_tbl(i).payment_status);
            EXIT WHEN i = l_group_settle_doc_tbl.LAST;
            i := l_group_settle_doc_tbl.NEXT(i);
         END LOOP;
      END IF;
   END IF;

   ---------------------------------------------
   -- 5. Create Settlement Docs of Mass Claim --
   ---------------------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('5. Create Settlement Docs of Mass Claim');
   END IF;

   OZF_Settlement_Doc_PVT.Create_Settlement_Doc_Tbl(
       p_api_version_number    => l_api_version,
       p_init_msg_list         => FND_API.G_FALSE,
       p_commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       x_return_status         => l_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data,
       p_settlement_doc_tbl    => l_group_settle_doc_tbl,
       x_settlement_doc_id_tbl => l_group_settle_doc_id_tbl
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ------------------------------
   -- 6. Break Mass Settlement --
   ------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('6. Break Mass Settlement');
   END IF;

   Break_Mass_Settlement(
      p_group_claim_id    => l_group_claim_id,
      p_settlement_type   => l_settlement_type,
      x_return_status     => l_return_status,
      x_msg_data          => x_msg_data,
      x_msg_count         => x_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   ---------------------------------
   -- 7. Complete Mass Settlement --
   ---------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('7. Complete Mass Settlement');
   END IF;

   Complete_Mass_Settlement(
      p_group_claim_id    => l_group_claim_id,
      x_claim_tbl         => l_complete_claim_group_tbl,
      x_return_status     => l_return_status,
      x_msg_data          => x_msg_data,
      x_msg_count         => x_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   BEGIN
      UPDATE ozf_claims_all
      SET amount = l_group_claim_amt
      ,   amount_remaining = l_group_trx_amt
      ,   amount_settled = l_group_settle_amt
      ,   amount_adjusted = l_group_rem_amt
      ,   settled_by      = NVL(FND_GLOBAL.user_id,-1) --//Bugfix : 8202109
      ,   settled_date    = TRUNC(SYSDATE)
      WHERE claim_id = l_group_claim_id;

       --//Bugfix : 7439145
       i := p_open_claim_tbl.FIRST;
       IF i IS NOT NULL THEN
          LOOP
	     BEGIN
	        --//Bugfix : 7661712
                OPEN p_acctd_claim_amts(p_open_claim_tbl(i).claim_id);
                FETCH p_acctd_claim_amts INTO l_act_amt,l_act_amt_adjusted,l_amt,l_amt_adjusted;
                CLOSE p_acctd_claim_amts;

		l_amt_settled     := l_act_amt - l_act_amt_adjusted;
                l_act_amt_settled := l_act_amt - l_act_amt_adjusted;

	        UPDATE ozf_claims_all
	        SET amount_settled          = l_amt_settled,
		    amount_remaining        = l_amt -(l_amt_adjusted + l_amt_settled),
                    acctd_amount_settled    = l_act_amt_settled,
                    acctd_amount_remaining  = l_act_amt - (l_act_amt_adjusted + l_act_amt_settled),
		    settled_by              = NVL(FND_GLOBAL.user_id,-1), --//Bugfix : 8202109
                    settled_date            = TRUNC(SYSDATE)
	       WHERE claim_id =p_open_claim_tbl(i).claim_id;

	     EXCEPTION
	       WHEN Others THEN
		 RAISE FND_API.g_exc_unexpected_error;
	     END;
	  EXIT WHEN i = p_open_claim_tbl.LAST;
	    i := p_open_claim_tbl.NEXT(i);
	  END LOOP;
	END IF;
	--//End Bugfix# 7439145

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


/*   --------------------------------
   -- 8. Approve Mass Settlement --
   --------------------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('8. Approve Mass Settlement');
   END IF;

   Approve_Mass_Settlement(
      p_group_claim_id           => l_group_claim_id,
      p_complete_claim_group_tbl => l_complete_claim_group_tbl,
      x_return_status            => l_return_status,
      x_msg_data                 => x_msg_data,
      x_msg_count                => x_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;*/

   OPEN csr_mass_setl_appr_req;
   FETCH csr_mass_setl_appr_req INTO l_appr_req;
   CLOSE csr_mass_setl_appr_req;


   IF l_appr_req = 'N' THEN
      ---------------------------
      -- 9. Start Mass Payment --
      ---------------------------
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('9. Start Mass Payment');
      END IF;

      Start_Mass_Payment(
         p_group_claim_id    => l_group_claim_id,
         x_return_status     => l_return_status,
         x_msg_data          => x_msg_data,
         x_msg_count         => x_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('8. Approve Mass Settlement');
      END IF;

      Approve_Mass_Settlement(
          p_group_claim_id           => l_group_claim_id,
          p_complete_claim_group_tbl => l_complete_claim_group_tbl,
          x_return_status            => l_return_status,
          x_msg_data                 => x_msg_data,
          x_msg_count                => x_msg_count
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;


   ------------------------ finish ------------------------
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );



EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Settle_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Settle_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Settle_Mass_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
      );

END Settle_Mass_Settlement;


END OZF_MASS_SETTLEMENT_PVT;

/
