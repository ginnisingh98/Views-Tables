--------------------------------------------------------
--  DDL for Package Body OZF_AR_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AR_PAYMENT_PVT" AS
/* $Header: ozfvarpb.pls 120.15.12010000.8 2010/03/05 09:29:01 muthsubr ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_AR_PAYMENT_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(15) := 'ozfvcarpb.pls';

G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

/*=======================================================================*
 | PROCEDURE
 |    Query_Claim
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Query_Claim(
    p_claim_id           IN    NUMBER
   ,x_claim_rec          OUT NOCOPY   OZF_Claim_PVT.claim_rec_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   SELECT
       CLAIM_ID
      ,OBJECT_VERSION_NUMBER
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,REQUEST_ID
      ,PROGRAM_APPLICATION_ID
      ,PROGRAM_UPDATE_DATE
      ,PROGRAM_ID
      ,CREATED_FROM
      ,BATCH_ID
      ,CLAIM_NUMBER
      ,CLAIM_TYPE_ID
      ,CLAIM_CLASS
      ,CLAIM_DATE
      ,DUE_DATE
      ,OWNER_ID
      ,HISTORY_EVENT
      ,HISTORY_EVENT_DATE
      ,HISTORY_EVENT_DESCRIPTION
      ,SPLIT_FROM_CLAIM_ID
      ,DUPLICATE_CLAIM_ID
      ,SPLIT_DATE
      ,ROOT_CLAIM_ID
      ,AMOUNT
      ,AMOUNT_ADJUSTED
      ,AMOUNT_REMAINING
      ,AMOUNT_SETTLED
      ,ACCTD_AMOUNT
      ,ACCTD_AMOUNT_REMAINING
      ,TAX_AMOUNT
      ,TAX_CODE
      ,TAX_CALCULATION_FLAG
      ,CURRENCY_CODE
      ,EXCHANGE_RATE_TYPE
      ,EXCHANGE_RATE_DATE
      ,EXCHANGE_RATE
      ,SET_OF_BOOKS_ID
      ,ORIGINAL_CLAIM_DATE
      ,SOURCE_OBJECT_ID
      ,SOURCE_OBJECT_CLASS
      ,SOURCE_OBJECT_TYPE_ID
      ,SOURCE_OBJECT_NUMBER
      ,CUST_ACCOUNT_ID
      ,CUST_BILLTO_ACCT_SITE_ID
      ,CUST_SHIPTO_ACCT_SITE_ID
      ,LOCATION_ID
      ,PAY_RELATED_ACCOUNT_FLAG
      ,RELATED_CUST_ACCOUNT_ID
      ,RELATED_SITE_USE_ID
      ,RELATIONSHIP_TYPE
      ,VENDOR_ID
      ,VENDOR_SITE_ID
      ,REASON_TYPE
      ,REASON_CODE_ID
      ,TASK_TEMPLATE_GROUP_ID
      ,STATUS_CODE
      ,USER_STATUS_ID
      ,SALES_REP_ID
      ,COLLECTOR_ID
      ,CONTACT_ID
      ,BROKER_ID
      ,TERRITORY_ID
      ,CUSTOMER_REF_DATE
      ,CUSTOMER_REF_NUMBER
      ,ASSIGNED_TO
      ,RECEIPT_ID
      ,RECEIPT_NUMBER
      ,DOC_SEQUENCE_ID
      ,DOC_SEQUENCE_VALUE
      ,GL_DATE
      ,PAYMENT_METHOD
      ,VOUCHER_ID
      ,VOUCHER_NUMBER
      ,PAYMENT_REFERENCE_ID
      ,PAYMENT_REFERENCE_NUMBER
      ,PAYMENT_REFERENCE_DATE
      ,PAYMENT_STATUS
      ,APPROVED_FLAG
      ,APPROVED_DATE
      ,APPROVED_BY
      ,SETTLED_DATE
      ,SETTLED_BY
      ,EFFECTIVE_DATE
      ,CUSTOM_SETUP_ID
      ,TASK_ID
      ,COUNTRY_ID
      ,COMMENTS
      ,ATTRIBUTE_CATEGORY
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,DEDUCTION_ATTRIBUTE_CATEGORY
      ,DEDUCTION_ATTRIBUTE1
      ,DEDUCTION_ATTRIBUTE2
      ,DEDUCTION_ATTRIBUTE3
      ,DEDUCTION_ATTRIBUTE4
      ,DEDUCTION_ATTRIBUTE5
      ,DEDUCTION_ATTRIBUTE6
      ,DEDUCTION_ATTRIBUTE7
      ,DEDUCTION_ATTRIBUTE8
      ,DEDUCTION_ATTRIBUTE9
      ,DEDUCTION_ATTRIBUTE10
      ,DEDUCTION_ATTRIBUTE11
      ,DEDUCTION_ATTRIBUTE12
      ,DEDUCTION_ATTRIBUTE13
      ,DEDUCTION_ATTRIBUTE14
      ,DEDUCTION_ATTRIBUTE15
      ,ORG_ID
      ,wo_rec_trx_id
      ,legal_entity_id
   INTO
       x_claim_rec.claim_id
      ,x_claim_rec.object_version_number
      ,x_claim_rec.last_update_date
      ,x_claim_rec.last_updated_by
      ,x_claim_rec.creation_date
      ,x_claim_rec.created_by
      ,x_claim_rec.last_update_login
      ,x_claim_rec.request_id
      ,x_claim_rec.program_application_id
      ,x_claim_rec.program_update_date
      ,x_claim_rec.program_id
      ,x_claim_rec.created_from
      ,x_claim_rec.batch_id
      ,x_claim_rec.claim_number
      ,x_claim_rec.claim_type_id
      ,x_claim_rec.claim_class
      ,x_claim_rec.claim_date
      ,x_claim_rec.due_date
      ,x_claim_rec.owner_id
      ,x_claim_rec.history_event
      ,x_claim_rec.history_event_date
      ,x_claim_rec.history_event_description
      ,x_claim_rec.split_from_claim_id
      ,x_claim_rec.duplicate_claim_id
      ,x_claim_rec.split_date
      ,x_claim_rec.root_claim_id
      ,x_claim_rec.amount
      ,x_claim_rec.amount_adjusted
      ,x_claim_rec.amount_remaining
      ,x_claim_rec.amount_settled
      ,x_claim_rec.acctd_amount
      ,x_claim_rec.acctd_amount_remaining
      ,x_claim_rec.tax_amount
      ,x_claim_rec.tax_code
      ,x_claim_rec.tax_calculation_flag
      ,x_claim_rec.currency_code
      ,x_claim_rec.exchange_rate_type
      ,x_claim_rec.exchange_rate_date
      ,x_claim_rec.exchange_rate
      ,x_claim_rec.set_of_books_id
      ,x_claim_rec.original_claim_date
      ,x_claim_rec.source_object_id
      ,x_claim_rec.source_object_class
      ,x_claim_rec.source_object_type_id
      ,x_claim_rec.source_object_number
      ,x_claim_rec.cust_account_id
      ,x_claim_rec.cust_billto_acct_site_id
      ,x_claim_rec.cust_shipto_acct_site_id
      ,x_claim_rec.location_id
      ,x_claim_rec.pay_related_account_flag
      ,x_claim_rec.related_cust_account_id
      ,x_claim_rec.related_site_use_id
      ,x_claim_rec.relationship_type
      ,x_claim_rec.vendor_id
      ,x_claim_rec.vendor_site_id
      ,x_claim_rec.reason_type
      ,x_claim_rec.reason_code_id
      ,x_claim_rec.task_template_group_id
      ,x_claim_rec.status_code
      ,x_claim_rec.user_status_id
      ,x_claim_rec.sales_rep_id
      ,x_claim_rec.collector_id
      ,x_claim_rec.contact_id
      ,x_claim_rec.broker_id
      ,x_claim_rec.territory_id
      ,x_claim_rec.customer_ref_date
      ,x_claim_rec.customer_ref_number
      ,x_claim_rec.assigned_to
      ,x_claim_rec.receipt_id
      ,x_claim_rec.receipt_number
      ,x_claim_rec.doc_sequence_id
      ,x_claim_rec.doc_sequence_value
      ,x_claim_rec.gl_date
      ,x_claim_rec.payment_method
      ,x_claim_rec.voucher_id
      ,x_claim_rec.voucher_number
      ,x_claim_rec.payment_reference_id
      ,x_claim_rec.payment_reference_number
      ,x_claim_rec.payment_reference_date
      ,x_claim_rec.payment_status
      ,x_claim_rec.approved_flag
      ,x_claim_rec.approved_date
      ,x_claim_rec.approved_by
      ,x_claim_rec.settled_date
      ,x_claim_rec.settled_by
      ,x_claim_rec.effective_date
      ,x_claim_rec.custom_setup_id
      ,x_claim_rec.task_id
      ,x_claim_rec.country_id
      ,x_claim_rec.comments
      ,x_claim_rec.attribute_category
      ,x_claim_rec.attribute1
      ,x_claim_rec.attribute2
      ,x_claim_rec.attribute3
      ,x_claim_rec.attribute4
      ,x_claim_rec.attribute5
      ,x_claim_rec.attribute6
      ,x_claim_rec.attribute7
      ,x_claim_rec.attribute8
      ,x_claim_rec.attribute9
      ,x_claim_rec.attribute10
      ,x_claim_rec.attribute11
      ,x_claim_rec.attribute12
      ,x_claim_rec.attribute13
      ,x_claim_rec.attribute14
      ,x_claim_rec.attribute15
      ,x_claim_rec.deduction_attribute_category
      ,x_claim_rec.deduction_attribute1
      ,x_claim_rec.deduction_attribute2
      ,x_claim_rec.deduction_attribute3
      ,x_claim_rec.deduction_attribute4
      ,x_claim_rec.deduction_attribute5
      ,x_claim_rec.deduction_attribute6
      ,x_claim_rec.deduction_attribute7
      ,x_claim_rec.deduction_attribute8
      ,x_claim_rec.deduction_attribute9
      ,x_claim_rec.deduction_attribute10
      ,x_claim_rec.deduction_attribute11
      ,x_claim_rec.deduction_attribute12
      ,x_claim_rec.deduction_attribute13
      ,x_claim_rec.deduction_attribute14
      ,x_claim_rec.deduction_attribute15
      ,x_claim_rec.org_id
      ,x_claim_rec.wo_rec_trx_id
      ,x_claim_rec.legal_entity_id
   FROM  ozf_claims_all
   WHERE claim_id = p_claim_id ;
   x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_QUERY_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Query_Claim;


/*=======================================================================*
 | PROCEDURE
 |    Close_Claim
 |
 | NOTES
 |
 | HISTORY
 |    15-MAY-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Close_Claim(
       p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Close_Claim';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   OZF_SETTLEMENT_DOC_PVT.Update_Claim_From_Settlement(
         p_api_version_number    => l_api_version,
         p_init_msg_list         => FND_API.g_false,
         p_commit                => FND_API.g_false,
         p_validation_level      => FND_API.g_valid_level_full,
         x_return_status         => l_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_claim_id              => p_claim_rec.claim_id,
         p_object_version_number => p_claim_rec.object_version_number,
         p_status_code           => 'CLOSED',
         p_payment_status        => 'PAID'
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Close_Claim;


/*=======================================================================*
 | PROCEDURE
 |    Unapply_Claim_Investigation
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Unapply_Claim_Investigation(
       p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
      ,p_reapply_amount        IN  NUMBER

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Unapply_Claim_Investigation';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message('Reapply amount='||p_reapply_amount);
   END IF;
   -- For partical settlement
   ARP_DEDUCTION_COVER.split_claim_reapplication(
        p_claim_id                 => p_claim_rec.root_claim_id,
        p_customer_trx_id          => p_claim_rec.source_object_id,
        p_amount                   => p_reapply_amount,
        p_init_msg_list            => FND_API.g_false,
        p_cash_receipt_id          => p_claim_rec.receipt_id,
        p_ussgl_transaction_code   => NULL,
        x_return_status            => l_return_status,
        x_msg_count                => x_msg_count,
        x_msg_data                 => x_msg_data
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_SPLIT_REAPP_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_SPLIT_REAPP_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Unapply_Claim_Investigation;


/*=======================================================================*
 | PROCEDURE
 |    Apply_On_Account_Credit
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Apply_On_Account_Credit(
       p_claim_rec             IN  OZF_CLAIM_PVT.claim_rec_type
      ,p_credit_amount         IN  NUMBER DEFAULT NULL

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Apply_On_Account_Credit';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_application_ref_num   VARCHAR2(30);   --Bug:2781186
   l_secondary_appl_ref_id NUMBER;         --Bug:2781186
   l_customer_reference    VARCHAR2(30);   --Bug:2781186

   l_amount_applied        NUMBER;

   -- bug#9279072
   l_attribute_rec   ar_receipt_api_pub.attribute_rec_type;


   --Start:Bug:2781186
   --Cursor to get customer reason,customer ref, reason code id
   CURSOR csr_get_more_root_clm_dtls (cv_claim_id IN NUMBER) IS
     SELECT claim_number, claim_id, customer_ref_number
     FROM   ozf_claims_all
     WHERE  claim_id = cv_claim_id;


   --Cursor to get customer reason,customer ref, reason code id in case of child cliam
   CURSOR csr_get_more_chld_clm_dtls (cv_claim_id IN NUMBER) IS
     SELECT p.claim_number, p.claim_id, c.customer_ref_number
     FROM   ozf_claims c , ozf_claims p
     WHERE  c.claim_id      = cv_claim_id
     AND    c.root_claim_id = p.claim_id;
   --End:Bug:2781186


   -- bug#9279072(+)
   CURSOR csr_rec_flex_flds (p_claim_id IN NUMBER) IS
     SELECT deduction_attribute1
       , deduction_attribute2
       , deduction_attribute3
       , deduction_attribute4
       , deduction_attribute5
       , deduction_attribute6
       , deduction_attribute7
       , deduction_attribute8
       , deduction_attribute9
       , deduction_attribute10
       , deduction_attribute11
       , deduction_attribute12
       , deduction_attribute13
       , deduction_attribute14
       , deduction_attribute15
    FROM ozf_claims_all
    WHERE claim_id = p_claim_id;
   -- bug#9279072(-)

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   --Bug:2781186 Get more claim details
   IF p_claim_rec.claim_id = p_claim_rec.root_claim_id THEN
     OPEN csr_get_more_root_clm_dtls(p_claim_rec.claim_id);
     FETCH csr_get_more_root_clm_dtls INTO l_application_ref_num,l_secondary_appl_ref_id,l_customer_reference;
     CLOSE csr_get_more_root_clm_dtls;
   ELSE
     OPEN csr_get_more_chld_clm_dtls(p_claim_rec.claim_id);
     FETCH csr_get_more_chld_clm_dtls INTO l_application_ref_num,l_secondary_appl_ref_id,l_customer_reference;
     CLOSE csr_get_more_chld_clm_dtls;
   END IF;

   -- bug#9279072(+)
   OPEN  csr_rec_flex_flds(p_claim_rec.claim_id);
   FETCH csr_rec_flex_flds INTO l_attribute_rec.attribute1
                                , l_attribute_rec.attribute2
                                , l_attribute_rec.attribute3
                                , l_attribute_rec.attribute4
                                , l_attribute_rec.attribute5
                                , l_attribute_rec.attribute6
                                , l_attribute_rec.attribute7
                                , l_attribute_rec.attribute8
                                , l_attribute_rec.attribute9
                                , l_attribute_rec.attribute10
                                , l_attribute_rec.attribute11
                                , l_attribute_rec.attribute12
                                , l_attribute_rec.attribute13
                                , l_attribute_rec.attribute14
                                , l_attribute_rec.attribute15;
   CLOSE csr_rec_flex_flds;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute1 = '||l_attribute_rec.attribute1);
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute2 = '||l_attribute_rec.attribute2);
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute3 = '||l_attribute_rec.attribute3);
   END IF;
   -- bug#9279072(-)

   l_amount_applied := NVL(p_credit_amount, p_claim_rec.amount_settled) * -1;

   ------------------------ start -------------------------
   AR_RECEIPT_API_COVER.Apply_on_account(
         -- Standard API parameters
         p_api_version                  => l_api_version,
         p_init_msg_list                => FND_API.g_false,
         p_commit                       => FND_API.g_false,
         p_validation_level             => FND_API.g_valid_level_full,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         -- Receipt application parameters.
         p_cash_receipt_id              => p_claim_rec.receipt_id,
         p_receipt_number               => NULL, --p_claim_rec.receipt_number,
         p_amount_applied               => l_amount_applied,
         --p_apply_date                   => SYSDATE, --AR should default
         --p_apply_gl_date                => p_claim_rec.gl_date, --11.5.10 Enhancements. AR should default
         --p_ussgl_transaction_code  IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
         --p_attribute_rec      IN attribute_rec_type DEFAULT attribute_rec_const,
         -- Global Flexfield parameters
         --p_global_attribute_rec IN global_attribute_rec_type DEFAULT global_attribute_rec_const,
	 -- bug#9279072 (+)
         p_attribute_rec                => l_attribute_rec,
	 -- bug#9279072 (-)
         p_comments                     => SUBSTRB(p_claim_rec.comments, 1, 240),
         p_application_ref_num          => l_application_ref_num,
         p_secondary_application_ref_id => l_secondary_appl_ref_id,
         p_customer_reference           => l_customer_reference --11.5.10 enhancements. TM should pass.
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_REC_APPACC_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_REC_APPACC_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Apply_On_Account_Credit;


/*=======================================================================*
 | PROCEDURE
 |    Unapply_from_Receipt
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Unapply_from_Receipt(
       p_cash_receipt_id       IN  NUMBER
      ,p_customer_trx_id       IN  NUMBER

      ,x_return_status         OUT NOCOPY VARCHAR2
      ,x_msg_data              OUT NOCOPY VARCHAR2
      ,x_msg_count             OUT NOCOPY NUMBER
 )
 IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Unapply_from_Receipt';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_payment_schedule_id  NUMBER;

   CURSOR csr_payment_schedule(cv_customer_trx_id IN NUMBER) IS
     SELECT payment_schedule_id
     FROM ar_payment_schedules
     WHERE customer_trx_id = cv_customer_trx_id;

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   OPEN csr_payment_schedule(p_customer_trx_id);
   FETCH csr_payment_schedule INTO l_payment_schedule_id;
   CLOSE csr_payment_schedule;

   AR_RECEIPT_API_COVER.Unapply(
         -- Standard API parameters
         p_api_version                  => l_api_version,
         p_init_msg_list                => FND_API.g_false,
         p_commit                       => FND_API.g_false,
         p_validation_level             => FND_API.g_valid_level_full,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         -- Receipt Info. parameters
         p_receipt_number               => NULL,
         p_cash_receipt_id              => p_cash_receipt_id,
         p_trx_number                   => NULL,
         p_customer_trx_id              => p_customer_trx_id,
         p_installment                  => NULL,
         p_applied_payment_schedule_id  => l_payment_schedule_id,
         p_receivable_application_id    => NULL,
         p_reversal_gl_date             => NULL,
         p_called_from                  => NULL,
         p_cancel_claim_flag            => 'N'
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_REC_UNAPP_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_REC_UNAPP_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Unapply_from_Receipt;


/*=======================================================================*
 | PROCEDURE
 |    Apply_on_Receipt
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Apply_on_Receipt(
       p_cash_receipt_id              IN  NUMBER
      ,p_receipt_number               IN  VARCHAR2
      ,p_customer_trx_id              IN  NUMBER
      ,p_trx_number                   IN  VARCHAR2
      ,p_new_applied_amount           IN  NUMBER
      ,p_new_applied_from_amount      IN  NUMBER  --4684931
      ,p_comments                     IN  VARCHAR2
      ,p_payment_set_id               IN  NUMBER
      ,p_application_ref_type         IN  VARCHAR2
      ,p_application_ref_id           IN  NUMBER
      ,p_application_ref_num          IN  VARCHAR2
      ,p_secondary_application_ref_id IN  NUMBER
      ,p_application_ref_reason       IN  VARCHAR2
      ,p_customer_reference           IN  VARCHAR2
      ,p_apply_date                   IN  DATE -- Fix for Bug 3091401. TM passes old apply date
      ,p_claim_id                     IN NUMBER -- Added For Rule Based Settlement ER
      ,x_return_status                OUT NOCOPY VARCHAR2
      ,x_msg_data                     OUT NOCOPY VARCHAR2
      ,x_msg_count                    OUT NOCOPY NUMBER
 )
 IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Apply_on_Receipt';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_payment_schedule_id  NUMBER;
   l_balance_amount       NUMBER;

   -- Added For Rule Based Settlement ER
   l_attribute_rec ar_receipt_api_pub.attribute_rec_type;
   l_claim_trx_id   NUMBER;
   l_payment_method VARCHAR2(60);

   CURSOR csr_payment_schedule(cv_customer_trx_id IN NUMBER) IS
     SELECT payment_schedule_id
     FROM ar_payment_schedules
     WHERE customer_trx_id = cv_customer_trx_id;

   CURSOR csr_trx_balance(cv_customer_trx_id IN NUMBER) IS
     SELECT ABS(amount_due_remaining)
     FROM ar_payment_schedules
     WHERE customer_trx_id = cv_customer_trx_id;

-- Added For Rule Based Settlement ER
CURSOR csr_claim_trx(cv_claim_id IN NUMBER) IS
     SELECT source_object_id, payment_method     -- For bug#9279072
     FROM ozf_claims_all
     WHERE claim_id = cv_claim_id;

CURSOR csr_rec_flex_flds (p_cash_receipt_id IN NUMBER, p_customer_trx_id IN NUMBER) IS
  SELECT attribute_category
       , attribute1
       , attribute2
       , attribute3
       , attribute4
       , attribute5
       , attribute6
       , attribute7
       , attribute8
       , attribute9
       , attribute10
       , attribute11
       , attribute12
       , attribute13
       , attribute14
       , attribute15
   FROM  ar_receivable_applications_all
   WHERE cash_receipt_id = p_cash_receipt_id
   AND applied_customer_trx_id = p_customer_trx_id
   AND status = 'APP'
   AND display = 'Y';

   -- bug#9279072(+)
   CURSOR csr_rec_dffs (p_claim_id IN NUMBER) IS
     SELECT deduction_attribute1
       , deduction_attribute2
       , deduction_attribute3
       , deduction_attribute4
       , deduction_attribute5
       , deduction_attribute6
       , deduction_attribute7
       , deduction_attribute8
       , deduction_attribute9
       , deduction_attribute10
       , deduction_attribute11
       , deduction_attribute12
       , deduction_attribute13
       , deduction_attribute14
       , deduction_attribute15
    FROM ozf_claims_all
    WHERE claim_id = p_claim_id;
   -- bug#9279072(-)


-- End For Rule Based Settlement ER


BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   -- CM/DM open balance checking
   OPEN csr_trx_balance(p_customer_trx_id);
   FETCH csr_trx_balance INTO l_balance_amount;
   CLOSE csr_trx_balance;

   IF ABS(p_new_applied_amount) > l_balance_amount THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_TRX_BAL_ERR');
         FND_MESSAGE.set_token('APPLY_AMT', p_new_applied_amount);
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN csr_payment_schedule(p_customer_trx_id);
   FETCH csr_payment_schedule INTO l_payment_schedule_id;
   CLOSE csr_payment_schedule;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('cash_receipt_id='||p_cash_receipt_id);
      OZF_Utility_PVT.debug_message('receipt_number='||p_receipt_number);
      OZF_Utility_PVT.debug_message('customer_trx_id='||p_customer_trx_id);
      OZF_Utility_PVT.debug_message('trx_number='||p_trx_number);
      OZF_Utility_PVT.debug_message('applied_payment_schedule_id='||l_payment_schedule_id);
      OZF_Utility_PVT.debug_message('new_applied_amount='||p_new_applied_amount);
      OZF_Utility_PVT.debug_message('new_applied_from_amount='||p_new_applied_from_amount); --4684931
      OZF_Utility_PVT.debug_message('Claim_ID='||p_claim_id); --4684931
   END IF;

   OPEN csr_claim_trx(p_claim_id);
   FETCH csr_claim_trx INTO l_claim_trx_id, l_payment_method;
   CLOSE csr_claim_trx;

    IF g_debug THEN
      OZF_Utility_PVT.debug_message('Claim Transaction Number ='||l_claim_trx_id);
      OZF_Utility_PVT.debug_message('Claim Payment Method ='||l_payment_method);
    END IF;


   IF l_payment_method IS NOT NULL
   AND l_payment_method IN ('PREV_OPEN_DEBIT', 'DEBIT_MEMO') THEN

	   -- bug#9279072(+)
	   OPEN  csr_rec_dffs(p_claim_id);
	   FETCH csr_rec_dffs INTO l_attribute_rec.attribute1
					, l_attribute_rec.attribute2
					, l_attribute_rec.attribute3
					, l_attribute_rec.attribute4
					, l_attribute_rec.attribute5
					, l_attribute_rec.attribute6
					, l_attribute_rec.attribute7
					, l_attribute_rec.attribute8
					, l_attribute_rec.attribute9
					, l_attribute_rec.attribute10
					, l_attribute_rec.attribute11
					, l_attribute_rec.attribute12
					, l_attribute_rec.attribute13
					, l_attribute_rec.attribute14
					, l_attribute_rec.attribute15;
	   CLOSE csr_rec_dffs;

   ELSE
	      -- Added For Rule Based Settlement ER
	   OPEN  csr_rec_flex_flds(p_cash_receipt_id,l_claim_trx_id);
	   FETCH csr_rec_flex_flds INTO l_attribute_rec.attribute_category
					, l_attribute_rec.attribute1
					, l_attribute_rec.attribute2
					, l_attribute_rec.attribute3
					, l_attribute_rec.attribute4
					, l_attribute_rec.attribute5
					, l_attribute_rec.attribute6
					, l_attribute_rec.attribute7
					, l_attribute_rec.attribute8
					, l_attribute_rec.attribute9
					, l_attribute_rec.attribute10
					, l_attribute_rec.attribute11
					, l_attribute_rec.attribute12
					, l_attribute_rec.attribute13
					, l_attribute_rec.attribute14
					, l_attribute_rec.attribute15;
	   CLOSE csr_rec_flex_flds;
   END IF;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute1 = '||l_attribute_rec.attribute1);
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute2 = '||l_attribute_rec.attribute2);
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute3 = '||l_attribute_rec.attribute3);
   END IF;
   -- bug#9279072(-)

    IF g_debug THEN
      OZF_Utility_PVT.debug_message('p_comments ='||p_comments);
      OZF_Utility_PVT.debug_message('p_payment_set_id='||p_payment_set_id);
      OZF_Utility_PVT.debug_message('p_application_ref_type='||p_application_ref_type);
      OZF_Utility_PVT.debug_message('p_application_ref_id='||p_application_ref_id);
      OZF_Utility_PVT.debug_message('p_application_ref_num='||p_application_ref_num);
      OZF_Utility_PVT.debug_message('p_secondary_application_ref_id='||p_secondary_application_ref_id);
      OZF_Utility_PVT.debug_message('p_application_ref_reason='||p_application_ref_reason); --4684931
      OZF_Utility_PVT.debug_message('p_customer_reference='||p_customer_reference); --4684931
      OZF_Utility_PVT.debug_message('l_attribute_rec.attribute3 = '||l_attribute_rec.attribute3); --4684931
   END IF;

   AR_RECEIPT_API_COVER.Apply(
         -- Standard API parameters.
         p_api_version                 => l_api_version,
         p_init_msg_list               => FND_API.g_false,
         p_commit                      => FND_API.g_false,
         p_validation_level            => FND_API.g_valid_level_full,
         x_return_status               => l_return_status,
         x_msg_count                   => x_msg_count,
         x_msg_data                    => x_msg_data,
         -- Receipt application parameters.
         p_cash_receipt_id             => p_cash_receipt_id,
         p_receipt_number              => p_receipt_number, --NULL,
         p_customer_trx_id             => p_customer_trx_id,
         p_trx_number                  => p_trx_number, --NULL,
         p_installment                 => NULL,
         p_applied_payment_schedule_id => NULL, --l_payment_schedule_id,
         p_amount_applied              => p_new_applied_amount,
         p_amount_applied_from         => p_new_applied_from_amount,--4684931
         p_apply_date                  => p_apply_date, -- Fix for Bug 3091401. TM passes old apply date
         -- this is the allocated receipt amount
         /*
         p_amount_applied_from          IN ar_receivable_applications.amount_applied_from%TYPE DEFAULT NULL,
         p_trans_to_receipt_rate        IN ar_receivable_applications.trans_to_receipt_rate%TYPE DEFAULT NULL,
         p_discount                     IN ar_receivable_applications.earned_discount_taken%TYPE DEFAULT NULL,
         p_apply_date                   IN ar_receivable_applications.apply_date%TYPE DEFAULT NULL,
         p_apply_gl_date                IN ar_receivable_applications.gl_date%TYPE DEFAULT NULL,
         p_ussgl_transaction_code       IN ar_receivable_applications.ussgl_transaction_code%TYPE DEFAULT NULL,
         p_customer_trx_line_id          IN ar_receivable_applications.applied_customer_trx_line_id%TYPE DEFAULT NULL,
         p_line_number                  IN ra_customer_trx_lines.line_number%TYPE DEFAULT NULL,
         p_show_closed_invoices         IN VARCHAR2 DEFAULT 'FALSE',
         p_called_from                  IN VARCHAR2 DEFAULT NULL,
         p_move_deferred_tax            IN VARCHAR2 DEFAULT 'Y',
         p_link_to_trx_hist_id          IN ar_receivable_applications.link_to_trx_hist_id%TYPE DEFAULT NULL,
         p_attribute_rec                IN attribute_rec_type DEFAULT attribute_rec_const,
         */
         -- ******* Global Flexfield parameters *******
         --p_global_attribute_rec         => p_global_attribute_rec,
	 -- Added For Rule Based Settlement ER
	 p_attribute_rec                => l_attribute_rec,
	 p_comments                     => p_comments,
         p_payment_set_id               => p_payment_set_id,
         p_application_ref_type         => p_application_ref_type,
         p_application_ref_id           => p_application_ref_id,
         p_application_ref_num          => p_application_ref_num,
         p_secondary_application_ref_id => p_secondary_application_ref_id,
         p_application_ref_reason       => p_application_ref_reason,
         p_customer_reference           => p_customer_reference,
         p_called_from   => NULL
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_REC_APP_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_REC_APP_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Apply_on_Receipt;


/*=======================================================================*
 | PROCEDURE
 |    Update_Dispute_Amount
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Update_dispute_amount(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_dispute_amount         IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Update_Dispute_Amount';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_root_claim_number    VARCHAR2(30);

   CURSOR csr_root_claim_number(cv_root_claim_id IN NUMBER) IS
     SELECT claim_number
     FROM ozf_claims
     WHERE claim_id = cv_root_claim_id;

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_claim_rec.claim_id = p_claim_rec.root_claim_id THEN
      l_root_claim_number := p_claim_rec.claim_number;
   ELSE
      OPEN csr_root_claim_number(p_claim_rec.root_claim_id);
      FETCH csr_root_claim_number INTO l_root_claim_number;
      CLOSE csr_root_claim_number;
   END IF;

   ARP_DEDUCTION_COVER.update_amount_in_dispute(
          p_customer_trx_id     => p_claim_rec.source_object_id,
          p_claim_number        => l_root_claim_number,
          p_amount              => p_dispute_amount,
          p_init_msg_list       => FND_API.g_false,
          x_return_status       => l_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_UPD_DISPUTE_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_UPD_DISPUTE_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Update_Dispute_Amount;


/*=======================================================================*
 | PROCEDURE
 |    Create_AR_Credit_Memo
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Create_AR_Credit_Memo(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_customer_trx_id        IN    NUMBER
   ,p_deduction_type         IN    VARCHAR2
   ,p_line_remaining         IN    NUMBER
   ,p_tax_remaining          IN    NUMBER
   ,p_freight_remaining      IN    NUMBER
   ,p_line_credit            IN    NUMBER
   ,p_tax_credit             IN    NUMBER
   ,p_freight_credit         IN    NUMBER
   ,p_total_credit           IN    NUMBER
   ,p_cm_line_tbl            IN    AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE
   ,p_upd_dispute_flag       IN    VARCHAR2
   ,x_cm_customer_trx_id     OUT NOCOPY   NUMBER
   ,x_cm_amount              OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Create_AR_Credit_Memo';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);

l_batch_source_name    VARCHAR2(50);
l_reason_code          VARCHAR2(30);
l_request_id           NUMBER;
l_cm_line_tbl          AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE;
l_line_credit_flag     VARCHAR2(1)  := 'N';
l_line_amount          NUMBER;
l_tax_amount           NUMBER;
l_freight_amount       NUMBER;

l_inv_line_amount          NUMBER;
l_inv_tax_amount           NUMBER;
l_inv_freight_amount       NUMBER;

l_total_credit         NUMBER;
l_root_claim_number    VARCHAR2(30);
l_credit_installments  VARCHAR2(30);
l_credit_rules         VARCHAR2(30);

l_x_status_meaning     VARCHAR2(60);
l_x_reason_meaning     VARCHAR2(60);
l_x_customer_trx_id    RA_CUSTOMER_TRX.customer_trx_id%TYPE;
--l_x_cm_customer_trx_id RA_CUSTOMER_TRX.customer_trx_id%TYPE:
l_x_line_amount        RA_CM_REQUESTS.line_amount%TYPE;
l_x_tax_amount         RA_CM_REQUESTS.tax_amount%TYPE;
l_x_freight_amount     RA_CM_REQUESTS.freight_amount%TYPE;
l_x_line_credits_flag  VARCHAR2(1);
l_x_created_by         WF_USERS.display_name%TYPE;
l_x_creation_date      DATE;
l_x_approval_date      DATE;
l_x_comments           RA_CM_REQUESTS.comments%TYPE;
l_x_cm_line_tbl        AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE;
l_x_cm_activity_tbl    AR_CREDIT_MEMO_API_PUB.x_cm_activity_tbl%TYPE;
l_x_cm_notes_tbl       AR_CREDIT_MEMO_API_PUB.x_cm_notes_tbl%TYPE;
l_attribute_rec        arw_cmreq_cover.pq_attribute_rec_type;

CURSOR csr_batch_source(cv_set_of_books_id IN NUMBER) IS
  SELECT name
  FROM ra_batch_sources bs
  ,    ozf_sys_parameters sys
  WHERE sys.batch_source_id = bs.batch_source_id
  AND sys.set_of_books_id = cv_set_of_books_id;

CURSOR csr_reason_code(cv_reason_code_id IN NUMBER) IS
  SELECT reason_code
  FROM ozf_reason_codes_all_b
  WHERE reason_code_id = cv_reason_code_id;

CURSOR csr_root_claim_number(cv_root_claim_id IN NUMBER) IS
  SELECT claim_number
  FROM ozf_claims
  WHERE claim_id = cv_root_claim_id;

CURSOR csr_credit_amount(cv_customer_trx_id IN NUMBER) IS
  SELECT SUM(NVL(amount_line_items_remaining, 0))
  ,      SUM(NVL(tax_remaining, 0))
  ,      SUM(NVL(freight_remaining, 0))
  FROM ar_payment_schedules
  WHERE customer_trx_id = cv_customer_trx_id;

--Bugfix 8452740: Added flexfields to pass information from TM to AR
CURSOR csr_claim_flex_flds (cv_cust_trx_id NUMBER) IS
  SELECT attribute_category
       , attribute1
       , attribute2
       , attribute3
       , attribute4
       , attribute5
       , attribute6
       , attribute7
       , attribute8
       , attribute9
       , attribute10
       , attribute11
       , attribute12
       , attribute13
       , attribute14
       , attribute15
   FROM  ra_customer_trx
   WHERE customer_trx_id = cv_cust_trx_id;

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   /* Logic Changed for Bug3963604 */
   IF p_total_credit = 0 AND p_line_credit = 0 AND
      p_tax_credit = 0 AND p_freight_credit = 0 AND p_cm_line_tbl IS NOT NULL THEN
         -- Line Level Credit Memo
         l_cm_line_tbl := p_cm_line_tbl;
         l_line_amount := NULL;
         l_tax_amount := NULL;
         l_freight_amount := NULL;
         l_line_credit_flag := 'Y';
   ELSE
      l_cm_line_tbl(1).customer_trx_line_id := NULL;
      l_cm_line_tbl(1).extended_amount := NULL;
      l_cm_line_tbl(1).quantity_credited :=NULL;
      l_cm_line_tbl(1).price := NULL;
      l_line_credit_flag := 'N';

      IF p_total_credit = 0  AND
      (p_line_credit <> 0 OR p_tax_credit <> 0 OR p_freight_credit <> 0) THEN
         -- Header Level Credit Memo with Credit to Line/Tax/Freight
         l_line_amount := p_line_credit * -1;
         l_tax_amount := p_tax_credit * -1;
         l_freight_amount := p_freight_credit * -1;
      ELSE
         -- Header Level Credit Memo. Modified for Bug4308173
         OPEN csr_credit_amount(p_customer_trx_id);
         FETCH csr_credit_amount INTO l_inv_line_amount , l_inv_tax_amount , l_inv_freight_amount;
         CLOSE csr_credit_amount;

         l_total_credit := p_total_credit;
         l_line_amount  := LEAST(l_total_credit,l_inv_line_amount);
         l_total_credit := l_total_credit - l_line_amount;

         IF l_total_credit > 0 THEN
             l_tax_amount   := LEAST(l_total_credit,l_inv_tax_amount);
             l_total_credit := l_total_credit - l_tax_amount;
         END IF;

         IF l_total_credit > 0 THEN
             l_freight_amount := LEAST(l_total_credit,l_inv_freight_amount);
         END IF;

         l_line_amount    := l_line_amount * -1;
         l_tax_amount     := l_tax_amount * -1;
         l_freight_amount := l_freight_amount * -1;
      END IF;
   END IF;


   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': request credit memo amount = '||p_claim_rec.amount_settled);
      OZF_Utility_PVT.debug_message(l_full_name||': request credit to line amount = '||l_line_amount);
      OZF_Utility_PVT.debug_message(l_full_name||': request credit to tax amount = '||l_tax_amount);
      OZF_Utility_PVT.debug_message(l_full_name||': request credit to freight amount = '||l_freight_amount);
      OZF_Utility_PVT.debug_message(l_full_name||': Line Level Credit = '||l_line_credit_flag);
   END IF;

   OPEN csr_batch_source(p_claim_rec.set_of_books_id);
   FETCH csr_batch_source INTO l_batch_source_name;
   CLOSE csr_batch_source;

   OPEN csr_reason_code(p_claim_rec.reason_code_id);
   FETCH csr_reason_code INTO l_reason_code;
   CLOSE csr_reason_code;


   l_credit_installments := NVL(FND_PROFILE.value('OZF_CLAIM_CREDIT_METHOD_INSTALLMENT'), 'PRORATE');
   l_credit_rules := NVL(FND_PROFILE.value('OZF_CLAIM_CREDIT_METHOD_RULE'), 'PRORATE');

   --Bugfix 8452740: Added flexfields to pass information from TM to AR
   OPEN  csr_claim_flex_flds(p_customer_trx_id);
   FETCH csr_claim_flex_flds INTO l_attribute_rec.attribute_category
                                , l_attribute_rec.attribute1
                                , l_attribute_rec.attribute2
                                , l_attribute_rec.attribute3
                                , l_attribute_rec.attribute4
                                , l_attribute_rec.attribute5
                                , l_attribute_rec.attribute6
                                , l_attribute_rec.attribute7
                                , l_attribute_rec.attribute8
                                , l_attribute_rec.attribute9
                                , l_attribute_rec.attribute10
                                , l_attribute_rec.attribute11
                                , l_attribute_rec.attribute12
                                , l_attribute_rec.attribute13
                                , l_attribute_rec.attribute14
                                , l_attribute_rec.attribute15;
   CLOSE csr_claim_flex_flds;

  /*------------------------------------------------------------*
   | 1. Create a credit memo in AR
   *------------------------------------------------------------*/
   AR_CREDIT_MEMO_API_PUB.create_request (
         -- standard API parameters
         p_api_version          => l_api_version,
         p_init_msg_list        => FND_API.G_FALSE,
         p_commit               => FND_API.G_FALSE,
         p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
         x_return_status        => l_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         -- credit memo request parameters
         p_customer_trx_id      => p_customer_trx_id,
         p_line_credit_flag     => l_line_credit_flag,
         p_line_amount          => l_line_amount,
         p_tax_amount           => l_tax_amount,
         p_freight_amount       => l_freight_amount,
         p_cm_reason_code       => l_reason_code,
         p_comments             => SUBSTRB(p_claim_rec.comments, 1, 240),
         p_orig_trx_number      => NULL,--p_claim_rec.source_object_number,
         p_tax_ex_cert_num      => NULL,
         p_request_url          => NULL,
         p_transaction_url      => NULL,
         p_trans_act_url        => NULL,
         p_cm_line_tbl          => l_cm_line_tbl,
         p_skip_workflow_flag   => 'Y',
         p_credit_method_installments => l_credit_installments,
         p_credit_method_rules  => l_credit_rules,
         p_batch_source_name    => l_batch_source_name,
	 p_attribute_rec        => l_attribute_rec,
         x_request_id           => l_request_id
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_CM_REQ_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_CM_REQ_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  /*------------------------------------------------------------*
   | 2. Get creidt memo request information
   *------------------------------------------------------------*/
   AR_CREDIT_MEMO_API_PUB.get_request_status(
         -- standard API parameters
         p_api_version          => l_api_version,
         p_init_msg_list        => FND_API.G_false,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         x_return_status       => l_return_status,
         -- credit memo request parameters
         p_request_id          => l_request_id,
         x_status_meaning      => l_x_status_meaning,
         x_reason_meaning       => l_x_reason_meaning,
         x_customer_trx_id      => l_x_customer_trx_id,
         x_cm_customer_trx_id   => x_cm_customer_trx_id,
         x_line_amount          => l_x_line_amount,
         x_tax_amount           => l_x_tax_amount,
         x_freight_amount       => l_x_freight_amount,
         x_line_credits_flag    => l_x_line_credits_flag,
         x_created_by           => l_x_created_by,
         x_creation_date        => l_x_creation_date,
         x_approval_date        => l_x_approval_date,
         x_comments             => l_x_comments,
         x_cm_line_tbl          => l_x_cm_line_tbl,
         x_cm_activity_tbl      => l_x_cm_activity_tbl,
         x_cm_notes_tbl         => l_x_cm_notes_tbl
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF x_cm_customer_trx_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CRE_ARCM_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
      -- [04/29/2002]: due to the rollback problem on ar credit memo api, instead of
      --               raising error to rollback, calling settlement workflow to proceed.
      BEGIN
        OZF_AR_SETTLEMENT_PVT.Start_Settlement(
             p_claim_id                => p_claim_rec.claim_id
            ,p_prev_status             => 'OPEN' -- hard code
            ,p_curr_status             => 'PENDING_CLOSE'
            ,p_next_status             => 'CLOSED'
        );
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
          FND_MESSAGE.Set_Token('TEXT',sqlerrm);
          FND_MSG_PUB.Add;
          RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;

   x_cm_amount := l_x_line_amount + l_x_tax_amount + l_x_freight_amount;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': credit memo id => '||x_cm_customer_trx_id);
      OZF_Utility_PVT.debug_message(l_full_name||': credit memo amount => '||x_cm_amount);
   END IF;

   --IF p_deduction_type = 'SOURCE_DED' THEN
   IF p_upd_dispute_flag = FND_API.g_true THEN
     /*------------------------------------------------------------*
      | 3. For Invoice Deduction only -> Taking invoice out of dispute
      *------------------------------------------------------------*/
      Update_dispute_amount(
          p_claim_rec          => p_claim_rec
         ,p_dispute_amount     => x_cm_amount
         ,x_return_status      => l_return_status
         ,x_msg_data           => x_msg_data
         ,x_msg_count          => x_msg_count
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF; -- end if p_deduction_type = 'SOURCE_DED'

   IF g_debug THEN
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

END Create_AR_Credit_Memo;


/*=======================================================================*
 | PROCEDURE
 |    Create_AR_Chargeback
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Create_AR_Chargeback(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_chargeback_amount      IN    NUMBER
   ,p_gl_date                IN    DATE

   ,x_cb_customer_trx_id     OUT NOCOPY   NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_AR_Chargeback';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_chargeback_rec       ARP_CHARGEBACK_COVER.Chargeback_Rec_Type;
   l_x_doc_seq_id         NUMBER;
   l_x_doc_seq_value      NUMBER;
   l_x_trx_number         VARCHAR2(20);
   l_reason_type          VARCHAR2(30);
   l_reason_code          VARCHAR2(30);
   l_cb_trx_type_id       NUMBER;
   l_check_inv_bal        BOOLEAN;
   l_cb_ref_field         VARCHAR2(80);
   l_reason_code_id       NUMBER;           --Bug:2781186
   l_gl_date_open_count   NUMBER   := 1;

   -- Cust_trx_type_id for Chargeback
   CURSOR csr_cust_trx_type(cv_claim_type_id IN NUMBER) IS
     SELECT cb_trx_type_id
     FROM ozf_claim_types_vl
     WHERE claim_type_id = cv_claim_type_id;

  CURSOR csr_sysparam_trx(cv_set_of_books_id IN NUMBER) IS
    --SELECT billback_trx_type_id --Modified by Padma as per 11.5.10 enhancements for system parameters.
    SELECT CB_TRX_TYPE_ID
    FROM ozf_sys_parameters
    WHERE set_of_books_id = cv_set_of_books_id;

   -- R12 Enhancements
   CURSOR csr_reason_code(cv_reason_code_id IN NUMBER) IS
     SELECT invoicing_reason_code
     FROM ozf_reason_codes_all_b
     WHERE reason_code_id = cv_reason_code_id;

   -- Cursor to get reference field value
   CURSOR csr_cb_ref_field IS
     SELECT default_reference
     FROM ra_batch_sources
     WHERE batch_source_id = 12;

--Start:Bug:2781186
   -- Cursor to get customer reason,customer ref, reason code id
   CURSOR csr_get_interface_attr_dtls (cv_claim_id IN NUMBER) IS
     SELECT customer_reason, customer_ref_number, reason_code_id
     --, customer_ref_date --11.5.10 enhancements -  TM should pass
     -- Uncomment and Corresponding change for this has to be done while assigning to code after
     -- AR enhancement for this is done.
     FROM   ozf_claims_all
     WHERE  claim_id = cv_claim_id;

   -- Cursor to get claim reason name
   CURSOR csr_get_reason_name (cv_reason_code_id IN NUMBER) IS
     SELECT SUBSTRB(name,1,30) name
     FROM   ozf_reason_codes_vl
     WHERE  reason_code_id = cv_reason_code_id;
--End:Bug:2781186


   CURSOR csr_gl_date_open( p_set_of_books_id  IN NUMBER
                          , p_gl_date          IN DATE
                          ) IS
     SELECT DECODE(MAX(gl.period_name), '', 0, 1)
     FROM   gl_period_statuses gl
     WHERE  gl.application_id = 222
     AND    gl.set_of_books_id = p_set_of_books_id
     AND    gl.adjustment_period_flag = 'N'
     AND    p_gl_date BETWEEN gl.start_date AND gl.end_date
     AND    gl.closing_status IN ('O', 'F');


BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   OPEN csr_cust_trx_type(p_claim_rec.claim_type_id);
   FETCH csr_cust_trx_type INTO l_cb_trx_type_id;
   CLOSE csr_cust_trx_type;

   IF l_cb_trx_type_id IS NULL THEN
      OPEN csr_sysparam_trx(p_claim_rec.set_of_books_id);
      FETCH csr_sysparam_trx INTO l_cb_trx_type_id;
      CLOSE csr_sysparam_trx;
   END IF;

   IF l_cb_trx_type_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CB_TRX_ID_REQ');
         FND_MSG_PUB.add;
      END IF;
   ELSE
      l_chargeback_rec.cust_trx_type_id := l_cb_trx_type_id;
   END IF;

   OPEN csr_reason_code(p_claim_rec.reason_code_id);
   FETCH csr_reason_code INTO l_chargeback_rec.reason_code;
   CLOSE csr_reason_code;

   l_chargeback_rec.amount := p_chargeback_amount;
   l_chargeback_rec.cash_receipt_id := p_claim_rec.receipt_id;
   l_chargeback_rec.secondary_application_ref_id := p_claim_rec.root_claim_id;
   l_chargeback_rec.new_second_application_ref_id := p_claim_rec.root_claim_id;

   --11.5.10 Enhancements. TM passes only if AR period is Open (I.e. not when it's
   --Closed or Close Pending, in which cases AR will default)
   IF p_gl_date IS NULL OR
      p_gl_date = FND_API.g_miss_date THEN
      IF OZF_CLAIM_SETTLEMENT_VAL_PVT.gl_date_in_open(222, p_claim_rec.claim_id) THEN
         l_chargeback_rec.gl_date := p_claim_rec.gl_date;
      END IF;
   ELSE
      OPEN csr_gl_date_open(p_claim_rec.set_of_books_id, p_gl_date);
      FETCH csr_gl_date_open INTO l_gl_date_open_count;
      CLOSE csr_gl_date_open;

      IF l_gl_date_open_count <> 0 THEN
         l_chargeback_rec.gl_date := p_gl_date;
      END IF;
   END IF;

   --11.5.10 Enhancements. AR should default, TM Enh 2655917
   --l_chargeback_rec.due_date := p_claim_rec.due_date;

   l_chargeback_rec.application_ref_type := 'CLAIM';
   -- [ BEGIN BUG246517 fixing 17-JUL-2002 ]: pass in bill to site id to chargeback rec.
   l_chargeback_rec.bill_to_site_use_id := p_claim_rec.cust_billto_acct_site_id;
   -- [ END BUG246517 fixing ]

   -- [BEGIN of BUG2569355 fixing]: pass claim number to chargeback reference field
   OPEN csr_cb_ref_field;
   FETCH csr_cb_ref_field INTO l_cb_ref_field;
   CLOSE csr_cb_ref_field;

   IF 1 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute1 := p_claim_rec.claim_number;
   ELSIF 2 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute2 := p_claim_rec.claim_number;
   ELSIF 3 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute3 := p_claim_rec.claim_number;
   ELSIF 4 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute4 := p_claim_rec.claim_number;
   ELSIF 5 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute5 := p_claim_rec.claim_number;
   ELSIF 6 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute6 := p_claim_rec.claim_number;
   ELSIF 7 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute7 := p_claim_rec.claim_number;
   ELSIF 8 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute8 := p_claim_rec.claim_number;
   ELSIF 9 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute9 := p_claim_rec.claim_number;
   ELSIF 10 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute10 := p_claim_rec.claim_number;
   ELSIF 11 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute11 := p_claim_rec.claim_number;
   ELSIF 12 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute12 := p_claim_rec.claim_number;
   ELSIF 13 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute13 := p_claim_rec.claim_number;
   ELSIF 14 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute14 := p_claim_rec.claim_number;
   ELSIF 15 = TO_NUMBER(l_cb_ref_field) THEN
      l_chargeback_rec.interface_header_attribute15 := p_claim_rec.claim_number;
   END IF;
   -- [END of BUG2569355 fixing]

   l_chargeback_rec.interface_header_context    := 'CLAIM';
   l_chargeback_rec.interface_header_attribute1 := p_claim_rec.claim_number;

   OPEN csr_get_interface_attr_dtls(p_claim_rec.claim_id);
   FETCH csr_get_interface_attr_dtls INTO l_chargeback_rec.interface_header_attribute6,  --customer reason
                                          l_chargeback_rec.interface_header_attribute5,  --customer reference
                                          l_reason_code_id;                              --reason code id
   CLOSE csr_get_interface_attr_dtls;

   OPEN  csr_get_reason_name(l_reason_code_id);
   FETCH csr_get_reason_name INTO l_chargeback_rec.interface_header_attribute7;   --reason name
   CLOSE csr_get_reason_name;

   --Pass customer reference to separate field customer_reference in chargeback_rec.
   l_chargeback_rec.CUSTOMER_REFERENCE := l_chargeback_rec.interface_header_attribute5;

   --Pass deduction attributes.
   l_chargeback_rec.attribute_category := p_claim_rec.deduction_attribute_category;
   l_chargeback_rec.attribute1         := p_claim_rec.deduction_attribute1;
   l_chargeback_rec.attribute2         := p_claim_rec.deduction_attribute2;
   l_chargeback_rec.attribute3         := p_claim_rec.deduction_attribute3;
   l_chargeback_rec.attribute4         := p_claim_rec.deduction_attribute4;
   l_chargeback_rec.attribute5         := p_claim_rec.deduction_attribute5;
   l_chargeback_rec.attribute6         := p_claim_rec.deduction_attribute6;
   l_chargeback_rec.attribute7         := p_claim_rec.deduction_attribute7;
   l_chargeback_rec.attribute8         := p_claim_rec.deduction_attribute8;
   l_chargeback_rec.attribute9         := p_claim_rec.deduction_attribute9;
   l_chargeback_rec.attribute10        := p_claim_rec.deduction_attribute10;
   l_chargeback_rec.attribute11        := p_claim_rec.deduction_attribute11;
   l_chargeback_rec.attribute12        := p_claim_rec.deduction_attribute12;
   l_chargeback_rec.attribute13        := p_claim_rec.deduction_attribute13;
   l_chargeback_rec.attribute14        := p_claim_rec.deduction_attribute14;
   l_chargeback_rec.attribute15        := p_claim_rec.deduction_attribute15;

   --Pass Comments
   l_chargeback_rec.comments           := SUBSTRB(p_claim_rec.comments,1,240);

  -- Pass LE
 l_chargeback_rec.legal_entity_id           := p_claim_rec.legal_entity_id;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': chargeback amount='||l_chargeback_rec.amount);
   END IF;

   ARP_CHARGEBACK_COVER.create_chargeback (
         p_chargeback_rec           => l_chargeback_rec,
         p_init_msg_list            => FND_API.g_false,
         x_doc_sequence_id          => l_x_doc_seq_id,
         x_doc_sequence_value       => l_x_doc_seq_value,
         x_trx_number               => l_x_trx_number,
         x_customer_trx_id          => x_cb_customer_trx_id,
         x_return_status            => l_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_CRE_CB_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AR_CRE_CB_UERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
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

END Create_AR_Chargeback;


/*=======================================================================*
 | PROCEDURE
 |    Create_AR_Write_Off
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 |    17-Oct-2008  ateotia bug # 7484916 fixed.
 |                         FP:11510-R12 7371116 - OZF_AR_PAYMENT_PUT.CREATE_AR_WRITE_OFF ERRORS OUT
 *=======================================================================*/
PROCEDURE Create_AR_Write_Off(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2
   ,p_write_off_amount       IN    NUMBER
   ,p_gl_date                IN    DATE
   ,p_wo_rec_trx_id          IN    NUMBER

   ,x_wo_adjust_id           OUT   NOCOPY NUMBER
   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Create_AR_Write_Off';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_receivables_trx_id    NUMBER := NULL;
   l_adj_rec               AR_ADJUSTMENTS%ROWTYPE;
   l_x_new_adjust_number   VARCHAR2(20);
   l_payment_schedule_id   NUMBER;
   l_asso_rec_app_id       NUMBER;
   l_reason_code           VARCHAR2(30);
   l_root_claim_number     VARCHAR2(30);

   l_application_ref_num   VARCHAR2(30);
   l_secondary_appl_ref_id NUMBER;
   l_customer_reference    VARCHAR2(30);

   l_adj_rec_trx_id        NUMBER;
   l_wo_rec_trx_id         NUMBER;
   l_neg_wo_rec_trx_id     NUMBER;
   l_sp_adj_rec_trx_id     NUMBER;
   l_sp_wo_rec_trx_id      NUMBER;
   l_sp_neg_wo_rec_trx_id  NUMBER;

   l_amt_line_items_rem    NUMBER;
   l_tax_remaining         NUMBER;
   l_freight_remaining     NUMBER;
   l_amount_due_remaining  NUMBER;
   l_rem_amount            NUMBER;
   l_idx                   NUMBER := 1;
   t_adj_rec               AR_ADJUSTMENTS%ROWTYPE;
   l_x_wo_adjust_id          NUMBER;

   TYPE writeoff_dtls_type IS RECORD (
     type  VARCHAR2(15),
     writeoff_amount NUMBER
   );

   TYPE writeoff_dtls_tab IS TABLE OF writeoff_dtls_type
    INDEX BY BINARY_INTEGER;

   l_writeoff_dtls writeoff_dtls_tab;

   -- associated receivable application is
   CURSOR csr_ar_rec_application( cv_cash_receipt_id     IN NUMBER
                                , cv_customer_trx_id     IN NUMBER
                                , cv_claim_id            IN NUMBER
                                ) IS
     SELECT receivable_application_id
     ,      applied_payment_schedule_id
     FROM ar_receivable_applications
     WHERE cash_receipt_id = cv_cash_receipt_id
     AND applied_customer_trx_id = cv_customer_trx_id
     AND application_ref_type = 'CLAIM'
     ANd secondary_application_ref_id = cv_claim_id
     AND display = 'Y';

   CURSOR csr_reason_code(cv_reason_code_id IN NUMBER) IS
     SELECT adjustment_reason_code
     FROM ozf_reason_codes_vl
     WHERE reason_code_id = cv_reason_code_id;

   CURSOR csr_root_claim_number(cv_root_claim_id IN NUMBER) IS
     SELECT claim_number
     FROM ozf_claims
     WHERE claim_id = cv_root_claim_id;

   CURSOR csr_claim_type_rec_trx(cv_claim_type_id IN NUMBER) IS
     SELECT adj_rec_trx_id
     ,      wo_rec_trx_id
     ,      neg_wo_rec_trx_id
     FROM ozf_claim_types_vl
     WHERE claim_type_id = cv_claim_type_id;

   CURSOR csr_sys_param_rec_trx IS
     SELECT adj_rec_trx_id
     ,      wo_rec_trx_id
     ,      neg_wo_rec_trx_id
     FROM ozf_sys_parameters;

   --Start:Bug:2781186
   -- Cursor to get customer reason,customer ref, reason code id
   CURSOR csr_get_more_root_clm_dtls (cv_claim_id IN NUMBER) IS
     SELECT claim_number, claim_id, customer_ref_number
     FROM   ozf_claims_all
     WHERE  claim_id = cv_claim_id;

   --Cursor to get customer reason,customer ref, reason code id in case of child cliam
   CURSOR csr_get_more_chld_clm_dtls (cv_claim_id IN NUMBER) IS
     SELECT p.claim_number, p.claim_id, c.customer_ref_number
     FROM   ozf_claims c , ozf_claims p
     WHERE  c.claim_id      = cv_claim_id
     AND    c.root_claim_id = p.claim_id;
   --End:Bug:2781186

   --Cursor to get amount details
   CURSOR csr_get_amount_dtls (    cv_cash_receipt_id  IN NUMBER
                                 , cv_customer_trx_id  IN NUMBER
                                 , cv_root_claim_id    IN NUMBER ) IS
    SELECT pay.amount_due_remaining,
           pay.amount_line_items_remaining,
           pay.tax_remaining,
           pay.freight_remaining
    FROM ar_receivable_applications rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_root_claim_id;

BEGIN
   -------------------- initialize -----------------------
   AMS_Utility_PVT.debug_message(l_full_name||': start');

   x_return_status := FND_API.g_ret_sts_success;

    --//Bug 5345095
   IF p_wo_rec_trx_id IS NULL THEN
      l_receivables_trx_id := p_claim_rec.wo_rec_trx_id;
   ELSE
      l_receivables_trx_id := p_wo_rec_trx_id;
   END IF;

   IF l_receivables_trx_id IS NULL THEN
      OPEN csr_claim_type_rec_trx(p_claim_rec.claim_type_id);
      FETCH csr_claim_type_rec_trx INTO l_adj_rec_trx_id
                                      , l_wo_rec_trx_id
                                      , l_neg_wo_rec_trx_id;
      CLOSE csr_claim_type_rec_trx;

      OPEN csr_sys_param_rec_trx;
      FETCH csr_sys_param_rec_trx INTO l_sp_adj_rec_trx_id
                                     , l_sp_wo_rec_trx_id
                                     , l_sp_neg_wo_rec_trx_id;
      CLOSE csr_sys_param_rec_trx;

      l_adj_rec_trx_id    := NVL(l_adj_rec_trx_id   , l_sp_adj_rec_trx_id);
      l_wo_rec_trx_id     := NVL(l_wo_rec_trx_id    , l_sp_wo_rec_trx_id);
      l_neg_wo_rec_trx_id := NVL(l_neg_wo_rec_trx_id, l_sp_neg_wo_rec_trx_id);
   END IF;

   ------------------------ start -------------------------
   IF p_deduction_type = 'SOURCE_DED' THEN
     /*------------------------------------------------------------*
      | Invoice Deduction -> 1. Create a negative adjustment.
      |                      2. Take invoice out of dispute
      *------------------------------------------------------------*/
      -- 1. Create a negative adjustment
      OPEN csr_ar_rec_application( p_claim_rec.receipt_id
                                 , p_claim_rec.source_object_id
                                 , p_claim_rec.root_claim_id
                                 );
      FETCH csr_ar_rec_application INTO l_asso_rec_app_id
                                      , l_payment_schedule_id;
      CLOSE csr_ar_rec_application;

      OPEN csr_reason_code(p_claim_rec.reason_code_id);
      FETCH csr_reason_code INTO l_reason_code;
      CLOSE csr_reason_code;

      OPEN csr_get_amount_dtls( p_claim_rec.receipt_id
                              , p_claim_rec.source_object_id
                              , p_claim_rec.root_claim_id
                              );
      FETCH csr_get_amount_dtls INTO l_amount_due_remaining, l_amt_line_items_rem,
                                     l_tax_remaining, l_freight_remaining;
      CLOSE csr_get_amount_dtls;

      IF l_receivables_trx_id IS NULL THEN
         l_receivables_trx_id := l_adj_rec_trx_id;
      END IF;

      l_adj_rec.payment_schedule_id := l_payment_schedule_id;
      l_adj_rec.amount              := p_write_off_amount * -1;
      -- l_adj_customer_trx_line_id :=  -- for type other then 'INVOICE' only.
      l_adj_rec.receivables_trx_id  := l_receivables_trx_id;
      l_adj_rec.apply_date          := SYSDATE;
      IF p_gl_date IS NULL OR
         p_gl_date = FND_API.g_miss_date THEN
         l_adj_rec.gl_date             := p_claim_rec.gl_date;
      ELSE
         l_adj_rec.gl_date             := p_gl_date;
      END IF;
      l_adj_rec.reason_code         := l_reason_code;
      l_adj_rec.comments            := SUBSTRB(p_claim_rec.comments, 1, 240);
      l_adj_rec.associated_application_id  := l_asso_rec_app_id;
      l_adj_rec.associated_cash_receipt_id := p_claim_rec.receipt_id;
      l_adj_rec.created_from        := 'CLAIMS';

      IF l_amount_due_remaining = p_write_off_amount THEN
         l_writeoff_dtls(1).type := 'INVOICE';
         l_writeoff_dtls(1).writeoff_amount := p_write_off_amount;
      ELSE
         l_rem_amount := p_write_off_amount;
         IF l_amt_line_items_rem > 0 THEN
           IF l_amt_line_items_rem >= l_rem_amount THEN
               l_writeoff_dtls(l_idx).type := 'LINE';
               l_writeoff_dtls(l_idx).writeoff_amount := l_rem_amount;
               l_rem_amount := 0;
            ELSE
               l_writeoff_dtls(l_idx).type := 'LINE';
               l_writeoff_dtls(l_idx).writeoff_amount := l_amt_line_items_rem;
               l_rem_amount := l_rem_amount - l_amt_line_items_rem;
            END IF;
            l_idx := l_idx + 1;
         END IF;

         IF l_rem_amount > 0 AND l_tax_remaining > 0 THEN
            IF l_tax_remaining >= l_rem_amount THEN
               l_writeoff_dtls(l_idx).type := 'TAX';
               l_writeoff_dtls(l_idx).writeoff_amount := l_rem_amount;
               l_rem_amount := 0;
            ELSE
               l_writeoff_dtls(l_idx).type := 'TAX';
               l_writeoff_dtls(l_idx).writeoff_amount := l_tax_remaining;
               l_rem_amount := p_write_off_amount - l_tax_remaining;
            END IF;
            l_idx := l_idx + 1;
         END IF;

         IF l_rem_amount > 0 AND l_freight_remaining > 0 THEN
            IF l_freight_remaining >= l_rem_amount THEN
               l_writeoff_dtls(l_idx).type := 'FREIGHT';
               l_writeoff_dtls(l_idx).writeoff_amount := l_rem_amount;
               l_rem_amount := 0;
            ELSE
               l_writeoff_dtls(l_idx).type := 'FREIGHT';
               l_writeoff_dtls(l_idx).writeoff_amount := l_freight_remaining;
               l_rem_amount := l_rem_amount - l_freight_remaining;
            END IF;
         END IF;
      END IF;

      -- bug # 7484916 fixed by ateotia (+)
      --FOR l_idx IN l_writeoff_dtls.FIRST..l_writeoff_dtls.LAST LOOP
      IF (l_writeoff_dtls.COUNT > 0) THEN
      FOR rowCount IN l_writeoff_dtls.FIRST..l_writeoff_dtls.LAST LOOP
        t_adj_rec := l_adj_rec;
        --t_adj_rec.type := l_writeoff_dtls(l_idx).type;
        --t_adj_rec.amount := l_writeoff_dtls(l_idx).writeoff_amount * -1;
        t_adj_rec.type := l_writeoff_dtls(rowCount).type;
        t_adj_rec.amount := l_writeoff_dtls(rowCount).writeoff_amount * -1;
      -- bug # 7484916 fixed by ateotia (-)

      AR_ADJUST_PUB.Create_Adjustment (
           p_api_name             => 'AR_ADJUST_PUB.Create_Adjustment',
           p_api_version          => l_api_version,
           p_init_msg_list        => FND_API.g_false,
           p_commit_flag          => FND_API.g_false,
           p_validation_level     => FND_API.g_valid_level_full,
           p_msg_count            => x_msg_count,
           p_msg_data             => x_msg_data,
           p_return_status        => l_return_status,
           p_adj_rec              => t_adj_rec,
           p_chk_approval_limits  => FND_API.g_false,
           p_check_amount         => FND_API.g_true,
           p_move_deferred_tax    => 'Y',     --??
           p_new_adjust_number    => l_x_new_adjust_number,
           p_new_adjust_id        => l_x_wo_adjust_id,
           p_called_from          => 'CLAIMS',
           p_old_adjust_id        => NULL
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_CRE_ADJ_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_CRE_ADJ_UERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

        /*------------------------------------------------------------*
        | Update Deduction payment detail
        *------------------------------------------------------------*/
       IF l_x_wo_adjust_id IS NOT NULL THEN
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
            ,p_payment_method         => 'WRITE_OFF'
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => p_claim_rec.source_object_id
            ,p_adjust_id              => l_x_wo_adjust_id
          );

          IF l_return_status =  FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
       END IF;
     END LOOP;
     END IF; -- bug # 7484916 fixed by ateotia

      -- 2. Taking invoice out of dispute
      IF p_claim_rec.claim_id <> p_claim_rec.root_claim_id THEN
         OPEN csr_root_claim_number(p_claim_rec.root_claim_id);
         FETCH csr_root_claim_number INTO l_root_claim_number;
         CLOSE csr_root_claim_number;
      ELSE
         l_root_claim_number := p_claim_rec.claim_number;
      END IF;

      ARP_DEDUCTION_COVER.update_amount_in_dispute(
             p_customer_trx_id     => p_claim_rec.source_object_id,
             p_claim_number        => l_root_claim_number,
             p_amount              => p_write_off_amount * -1,
             p_init_msg_list       => FND_API.g_false,
             x_return_status       => l_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_UPD_DISPUTE_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_UPD_DISPUTE_UERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_deduction_type in ('RECEIPT_OPM','RECEIPT_DED') THEN
     /*------------------------------------------------------------*
      | Claim Investigation -> 1. Cover API :: Create Receipt Write_Off
      *------------------------------------------------------------*/
      IF p_claim_rec.claim_id = p_claim_rec.root_claim_id THEN
         OPEN csr_get_more_root_clm_dtls(p_claim_rec.claim_id);
         FETCH csr_get_more_root_clm_dtls INTO l_application_ref_num
                                             , l_secondary_appl_ref_id
                                             , l_customer_reference;
         CLOSE csr_get_more_root_clm_dtls;
      ELSE
         OPEN csr_get_more_chld_clm_dtls(p_claim_rec.claim_id);
         FETCH csr_get_more_chld_clm_dtls INTO l_application_ref_num
                                             , l_secondary_appl_ref_id
                                             , l_customer_reference;
         CLOSE csr_get_more_chld_clm_dtls;
      END IF;

      IF p_wo_rec_trx_id IS NULL OR
         p_wo_rec_trx_id = FND_API.g_miss_num THEN

         IF l_receivables_trx_id IS NULL THEN
            IF p_deduction_type = 'RECEIPT_OPM' THEN
               l_receivables_trx_id := l_wo_rec_trx_id;
            ELSIF p_deduction_type = 'RECEIPT_DED' THEN
               l_receivables_trx_id := l_neg_wo_rec_trx_id;
            END IF;
         END IF;
      ELSE
         l_receivables_trx_id := p_wo_rec_trx_id;
      END IF;

      ARP_DEDUCTION_COVER.create_receipt_writeoff(
           p_claim_id                     =>  p_claim_rec.root_claim_id,
           p_amount                       =>  (p_write_off_amount * -1),
           p_new_claim_id                 =>  p_claim_rec.root_claim_id,
           p_init_msg_list                =>  FND_API.g_false,
           p_cash_receipt_id              =>  p_claim_rec.receipt_id,
           p_receivables_trx_id           =>  l_receivables_trx_id,
           p_ussgl_transaction_code       =>  NULL,
           p_application_ref_num          =>  l_application_ref_num,
           p_secondary_application_ref_id =>  l_secondary_appl_ref_id,
           p_customer_reference           =>  l_customer_reference,
           x_return_status                =>  l_return_status,
           x_msg_count                    =>  x_msg_count,
           x_msg_data                     =>  x_msg_data
     );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_CRE_REC_WO_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('AMS', 'AMS_SETL_AR_CRE_REC_WO_UERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- There is no write_off number populating in case of receipt write_off.
      l_x_wo_adjust_id := -3;
      OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => p_claim_rec.claim_id
            ,p_payment_method         => 'WRITE_OFF'
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => p_claim_rec.source_object_id
            ,p_adjust_id              => l_x_wo_adjust_id
          );

      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   --//Bug 5345095 BK Modif
   IF l_receivables_trx_id IS NOT NULL THEN
      BEGIN
        UPDATE ozf_claims_all
        SET wo_rec_trx_id = l_receivables_trx_id
        WHERE claim_id = p_claim_rec.claim_id
          AND wo_rec_trx_id IS NULL;

      EXCEPTION
        WHEN OTHERS THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_GRP_UPD_DEDU_ERR');
              FND_MSG_PUB.add;
           END IF;

           IF g_debug THEN
              FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
              FND_MESSAGE.Set_Token('TEXT',sqlerrm);
              FND_MSG_PUB.Add;
           END IF;
           RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;

 AMS_Utility_PVT.debug_message(l_full_name||': end');

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

END Create_AR_Write_Off;



/*=======================================================================*
 | PROCEDURE
 |    Process_Settlement_WF
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Process_Settlement_WF(
    p_claim_id               IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Process_Settlement_WF';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   BEGIN
   OZF_AR_SETTLEMENT_PVT.Start_Settlement(
        p_claim_id                => p_claim_id
       ,p_prev_status             => 'APPROVED'
       ,p_curr_status             => 'PENDING_CLOSE'
       ,p_next_status             => 'CLOSED'
       ,p_promotional_claim       => 'N'
       ,p_process                 => 'OZF_CLAIM_SETTLEMENT'
   );
   EXCEPTION
      WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
         RAISE FND_API.g_exc_unexpected_error;
   END;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Process_Settlement_WF;

/*=======================================================================*
 | Function
 |    Get_Inv_Credit_Details
 |
 | Return
 |    FND_API.g_true / FND_API.g_false
 |
 | HISTORY
 |    14-Jun-2005  Sahana  Created for R12
 *=======================================================================*/
PROCEDURE Get_Inv_Credit_Details(
    p_claim_id               IN  NUMBER
   ,p_invoice_id             IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_line_credit            OUT NOCOPY   NUMBER
   ,x_tax_credit             OUT NOCOPY   NUMBER
   ,x_freight_credit         OUT NOCOPY   NUMBER
   ,x_total_credit           OUT NOCOPY   NUMBER
   ,x_cm_line_tbl            OUT NOCOPY   AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE
) IS

 CURSOR csr_claim_line_invoice(cv_claim_id IN NUMBER, cv_inv_id IN NUMBER) IS
    SELECT source_object_id
    ,      source_object_line_id
    ,      credit_to
    ,      SUM(quantity) qty
    ,      AVG(rate)  rate
    ,      SUM(NVL(claim_currency_amount,0)) amount
    FROM  ozf_claim_lines
    WHERE claim_id = cv_claim_id
    AND   source_object_id = cv_inv_id
    GROUP BY source_object_id,source_object_line_id,credit_to;
  l_trx_lines  csr_claim_line_invoice%ROWTYPE;

l_api_name     CONSTANT VARCHAR2(30) := 'Get_Inv_Credit_Details()';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_line_credit                    NUMBER   := 0;
l_tax_credit                     NUMBER   := 0;
l_freight_credit                 NUMBER   := 0;
l_total_credit                   NUMBER   := 0;

l_counter                        NUMBER         := 1;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   IF g_debug THEN
          OZF_Utility_PVT.debug_message( l_full_name || ' : Start');
   END IF;

   OPEN csr_claim_line_invoice(p_claim_id, p_invoice_id);
   LOOP
      FETCH csr_claim_line_invoice INTO l_trx_lines;
      EXIT WHEN csr_claim_line_invoice%NOTFOUND;

      IF l_trx_lines.source_object_line_id IS NOT NULL THEN
            x_cm_line_tbl(l_counter).customer_trx_line_id := l_trx_lines.source_object_line_id;
            x_cm_line_tbl(l_counter).quantity_credited    := l_trx_lines.qty * -1;
            x_cm_line_tbl(l_counter).price                := l_trx_lines.rate;
            x_cm_line_tbl(l_counter).extended_amount      := l_trx_lines.amount * -1;

            IF g_debug THEN
               OZF_Utility_PVT.debug_message('x_cm_line_tbl('||l_counter||').customer_trx_line_id='||x_cm_line_tbl(l_counter).customer_trx_line_id);
               OZF_Utility_PVT.debug_message('x_cm_line_tbl('||l_counter||').extended_amount='||x_cm_line_tbl(l_counter).extended_amount);
            END IF;
            l_counter := l_counter +1;
      END IF;

      IF l_trx_lines.credit_to IS NOT NULL THEN
              IF l_trx_lines.credit_to = 'LINE' THEN
            l_line_credit := l_line_credit + l_trx_lines.amount ;
              ELSIF l_trx_lines.credit_to = 'TAX' THEN
            l_tax_credit := l_tax_credit + l_trx_lines.amount ;
              ELSIF l_trx_lines.credit_to = 'FREIGHT' THEN
            l_freight_credit := l_freight_credit + l_trx_lines.amount ;
            END IF;
      END IF;

      IF l_trx_lines.credit_to IS NULL AND l_trx_lines.source_object_line_id IS NULL THEN
               l_total_credit  := l_total_credit + l_trx_lines.amount ;
      END IF;

   END LOOP;
   IF g_debug THEN
            OZF_Utility_PVT.debug_message('l_line_credit = '||l_line_credit);
            OZF_Utility_PVT.debug_message('l_tax_credit = '||l_tax_credit);
            OZF_Utility_PVT.debug_message('l_freight_credit = '||l_freight_credit);
            OZF_Utility_PVT.debug_message('l_total_credit = '||l_total_credit);
   END IF;
   CLOSE csr_claim_line_invoice;


   x_line_credit := l_line_credit;
   x_tax_credit := l_tax_credit;
   x_freight_credit := l_freight_credit;
   x_total_credit := l_total_credit;

   IF g_debug THEN
          OZF_Utility_PVT.debug_message( l_full_name || ' : End');
   END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Get_Inv_Credit_Details;

/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Single_Invoice_Credit
 |
 | NOTES
 |
 | HISTORY
 |    15-JUN-2005  Sahana  Created for R12.
 *=======================================================================*/
PROCEDURE Pay_by_Single_Invoice_Credit(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_sttlmnt_amt          IN    NUMBER
   ,p_invoice_id             IN    NUMBER
   ,p_deduction_type         IN    VARCHAR2
   ,p_line_credit            IN    NUMBER
   ,p_tax_credit             IN    NUMBER
   ,p_freight_credit         IN    NUMBER
   ,p_total_credit           IN    NUMBER
   ,p_cm_line_tbl            IN    AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Pay_by_Single_Invoice_Credit';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status            VARCHAR2(1);

  l_cm_customer_trx_id       NUMBER       := NULL;
  l_cm_amount                NUMBER       := 0;
  l_new_applied_amount       NUMBER;
  l_old_applied_amount       NUMBER;
  l_claim_line_count         NUMBER;
  l_apply_receipt_id         NUMBER;
  l_old_applied_claim_amount NUMBER;
  l_reapply_claim_amount     NUMBER;
  l_line_remaining           NUMBER;
  l_tax_remaining            NUMBER;
  l_freight_remaining        NUMBER;



  CURSOR csr_old_applied_amount( cv_cash_receipt_id  IN NUMBER
                               , cv_customer_trx_id  IN NUMBER
                               ) IS
    SELECT rec.amount_applied
    ,      pay.amount_due_remaining
    ,      NVL(pay.amount_line_items_remaining, 0) amount_line_items_remaining
    ,      NVL(pay.tax_remaining, 0) tax_remaining
    ,      NVL(pay.freight_remaining, 0) freight_remaining
    ,      rec.comments
    ,      rec.payment_set_id
    ,      rec.application_ref_type
    ,      rec.application_ref_id
    ,      rec.application_ref_num
    ,      rec.secondary_application_ref_id
    ,      rec.application_ref_reason
    ,      rec.customer_reference
    FROM ar_receivable_applications rec
    , ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.display = 'Y';

l_old_applied_invoice    csr_old_applied_amount%ROWTYPE;

  CURSOR csr_count_claim_line(cv_claim_id IN NUMBER) IS
    SELECT COUNT(claim_line_id)
    FROM ozf_claim_lines
    WHERE claim_id = cv_claim_id;

  CURSOR csr_invoice_apply_receipt(cv_invoice_id IN NUMBER) IS
    SELECT rec.cash_receipt_id
    FROM ar_receivable_applications_all rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND pay.customer_trx_id = cv_invoice_id;

  CURSOR csr_old_claim_investigation( cv_cash_receipt_id IN NUMBER
                                    , cv_root_claim_id IN NUMBER) IS
    SELECT rec.amount_applied
    FROM ar_receivable_applications rec
    WHERE rec.applied_payment_schedule_id = -4
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_root_claim_id;

   CURSOR csr_customer_trx_lines(cv_invoice_line_id IN NUMBER) IS
      SELECT customer_trx_id
      FROM ra_customer_trx_lines
      WHERE customer_trx_line_id = cv_invoice_line_id;

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   IF p_deduction_type = 'SOURCE_DED' THEN
           /*------------------------------------------------------------*
            | Remove invoice from dispute.
            | Invoice Deduction - Credit to Tax/Line/Freight
            |    -> 1. Unapply invoice from receipt.
            |    -> 2. Create credit memo for the invoice.
            |    -> 3. Apply invoice back on receipt.
            |    -> 4. Update dispute amount.
            | Invoice Deduction - Credit to Invoice
            |    -> create credit memo for the invoice
            *------------------------------------------------------------*/

            --  Update dispute amount.
            IF g_debug THEN
                 OZF_Utility_PVT.debug_message('Source Deduction -> Update dispute amount');
            END IF;
            Update_dispute_amount(
                   p_claim_rec          => p_claim_rec
                  ,p_dispute_amount     => l_cm_amount
                  ,x_return_status      => l_return_status
                  ,x_msg_data           => x_msg_data
                  ,x_msg_count          => x_msg_count
            );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
            END IF;


            -- -------------------------------------
            -- Invoice Deduction - Credit to Invoice
            -- -------------------------------------
            IF p_line_credit = 0 AND
               p_tax_credit = 0 AND
               p_freight_credit = 0 AND
               p_total_credit <> 0 THEN
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction[Credit to --] -> Create Credit Memo');
               END IF;
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_claim_rec.source_object_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => 0
                  ,p_tax_remaining       => 0
                  ,p_freight_remaining   => 0
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_true
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

            -- ----------------------------------------------
            -- Invoice Deduction - Credit to Tax/Line/Freight
            -- ----------------------------------------------
            ELSE
               OPEN csr_old_applied_amount( p_claim_rec.receipt_id
                                          , p_claim_rec.source_object_id
                                          );
               FETCH csr_old_applied_amount INTO l_old_applied_invoice;
               CLOSE csr_old_applied_amount;


               -- 1. Unapply invoice from receipt.
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction[Credit to Line/Tax/Freight] -> 1. Unapply invoice from receipt.');
               END IF;
               -- Bug4118351: Do not unapply if original amount applied is zero.
               IF l_old_applied_invoice.amount_applied <> 0 THEN
                 Unapply_from_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_claim_rec.source_object_id
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

               -- 2. Create credit memo for the invoice
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction[Credit to Line/Tax/Freight] -> 2. Create credit memo for the invoice');
               END IF;
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_claim_rec.source_object_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => 0
                  ,p_tax_remaining       => 0
                  ,p_freight_remaining   => 0
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_false
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               -- 3. Apply invoice back on receipt.
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction[Credit to Line/Tax/Freight] -> 3. Apply invoice back on receipt');
               END IF;
               --IF (l_old_applied_invoice.amount_due_remaining + l_cm_amount) = 0 THEN
               IF l_old_applied_invoice.amount_due_remaining = p_claim_rec.amount_settled THEN
                  l_old_applied_invoice.application_ref_type := NULL;
                  l_old_applied_invoice.application_ref_id := NULL;
                  l_old_applied_invoice.application_ref_num := NULL;
                  l_old_applied_invoice.secondary_application_ref_id := NULL;
                  l_old_applied_invoice.application_ref_reason := NULL;
               END IF;

               -- Bug4118351: Reapply invoice only if original applied amount was not 0.
               IF l_old_applied_invoice.amount_applied <> 0 THEN
                 Apply_on_Receipt(
                   p_cash_receipt_id              => p_claim_rec.receipt_id
                  ,p_customer_trx_id              => p_claim_rec.source_object_id
                  ,p_new_applied_amount           => l_old_applied_invoice.amount_applied
                  ,p_comments                     => l_old_applied_invoice.comments
                  ,p_payment_set_id               => l_old_applied_invoice.payment_set_id
                  ,p_application_ref_type         => l_old_applied_invoice.application_ref_type
                  ,p_application_ref_id           => l_old_applied_invoice.application_ref_id
                  ,p_application_ref_num          => l_old_applied_invoice.application_ref_num
                  ,p_secondary_application_ref_id => l_old_applied_invoice.secondary_application_ref_id
                  ,p_application_ref_reason       => l_old_applied_invoice.application_ref_reason
                  ,p_customer_reference           => l_old_applied_invoice.customer_reference
		  ,p_claim_id                     => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status                => l_return_status
                  ,x_msg_data                     => x_msg_data
                  ,x_msg_count                    => x_msg_count
                );
                IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
                ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
                END IF;
              END IF;

            END IF;

  ELSIF p_deduction_type = 'RECEIPT_DED' THEN
           /*------------------------------------------------------------*
            | Receipt Deduction
            |                      1. Unapply associated invoice from receipt.
            |                      2. Unapply_Claim_Investigation.
            |                      3. Validate Invoice
            |  -> Credit to Invoice
            |                      4. Apply same associated invoice even if balance amount is zero
            |                      5. Create credit memo for the invoice.
            |
            |  -> Credit to Tax/Line/Freight or specific line
            |                      4. Reapply at this point if balance is zero
            |                      5. Create credit memo for the invoice.
            |                      6. Reapply same associated invoice with reduced amount if balance not zero
            | Modified for 4308173
            *------------------------------------------------------------*/

            IF g_debug THEN
               OZF_Utility_PVT.debug_message('Receipt Deduction -> 1. Unapply associated invoice from receipt');
            END IF;


            OPEN csr_old_applied_amount( p_claim_rec.receipt_id, p_invoice_id);
            FETCH csr_old_applied_amount INTO l_old_applied_invoice;
            CLOSE csr_old_applied_amount;

            Unapply_from_Receipt(
                p_cash_receipt_id    => p_claim_rec.receipt_id
               ,p_customer_trx_id    => p_invoice_id
               ,x_return_status      => l_return_status
               ,x_msg_data           => x_msg_data
               ,x_msg_count          => x_msg_count
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;


            IF g_debug THEN
               OZF_Utility_PVT.debug_message('Receipt Deduction -> 2. Unapply_Claim_Investigation.');
            END IF;
            OPEN csr_old_claim_investigation(p_claim_rec.receipt_id, p_claim_rec.root_claim_id);
            FETCH csr_old_claim_investigation INTO l_old_applied_claim_amount;
            CLOSE csr_old_claim_investigation;

            l_reapply_claim_amount := l_old_applied_claim_amount + p_sttlmnt_amt;

            Unapply_Claim_Investigation(
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


            IF g_debug THEN
               OZF_Utility_PVT.debug_message('Receipt Deduction -> 3. Validate Invoice.');
            END IF;
            OZF_AR_VALIDATION_PVT.Validate_CreditTo_Information(
                  p_claim_rec       => p_claim_rec
                 ,p_invoice_id      => p_invoice_id
                 ,x_return_status   => l_return_status
                 );
            IF l_return_status =  FND_API.g_ret_sts_error THEN
                         RAISE FND_API.g_exc_error;
                ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
                END IF;

            -- ----------------------------------------------
            -- Claim Investigation (Deduction) - Invoice
            -- ----------------------------------------------
            IF p_line_credit = 0 AND
               p_tax_credit = 0 AND
               p_freight_credit = 0 AND
               p_total_credit <> 0 THEN

               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 4. Apply same associated invoice with reduced amount');
               END IF;
               l_new_applied_amount := l_old_applied_invoice.amount_applied - p_sttlmnt_amt;


               Apply_on_Receipt(
                   p_cash_receipt_id              => p_claim_rec.receipt_id
                  ,p_customer_trx_id              => p_invoice_id
                  ,p_new_applied_amount           => l_new_applied_amount
                  ,p_comments                     => l_old_applied_invoice.comments
                  ,p_payment_set_id               => l_old_applied_invoice.payment_set_id
                  ,p_application_ref_type         => l_old_applied_invoice.application_ref_type
                  ,p_application_ref_id           => l_old_applied_invoice.application_ref_id
                  ,p_application_ref_num          => l_old_applied_invoice.application_ref_num
                  ,p_secondary_application_ref_id => l_old_applied_invoice.secondary_application_ref_id
                  ,p_application_ref_reason       => l_old_applied_invoice.application_ref_reason
                  ,p_customer_reference           => l_old_applied_invoice.customer_reference
		  ,p_claim_id                     => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status                => l_return_status
                  ,x_msg_data                     => x_msg_data
                  ,x_msg_count                    => x_msg_count
                     );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               -- 4. Create credit memo for the invoice.
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 5. Create credit memo for the invoice.');
               END IF;
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_invoice_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => l_old_applied_invoice.amount_line_items_remaining
                  ,p_tax_remaining       => l_old_applied_invoice.tax_remaining
                  ,p_freight_remaining   => l_old_applied_invoice.freight_remaining
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_false
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

            ELSE
            -- ----------------------------------------------
            -- Claim Investigation (Deduction) - Credit to Tax/Line/Freight
            -- ----------------------------------------------
               -- 3. Apply same associated invoice if balance amount is zero.
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 3. Apply same associated invoice if balance amount is zero.');
               END IF;
               l_new_applied_amount := l_old_applied_invoice.amount_applied - p_claim_rec.amount_settled;

               IF l_new_applied_amount = 0 THEN
                   Apply_on_Receipt(
                   p_cash_receipt_id              => p_claim_rec.receipt_id
                  ,p_customer_trx_id              => p_invoice_id
                  ,p_new_applied_amount           => l_new_applied_amount
                  ,p_comments                     => l_old_applied_invoice.comments
                  ,p_payment_set_id               => l_old_applied_invoice.payment_set_id
                  ,p_application_ref_type         => l_old_applied_invoice.application_ref_type
                  ,p_application_ref_id           => l_old_applied_invoice.application_ref_id
                  ,p_application_ref_num          => l_old_applied_invoice.application_ref_num
                  ,p_secondary_application_ref_id => l_old_applied_invoice.secondary_application_ref_id
                  ,p_application_ref_reason       => l_old_applied_invoice.application_ref_reason
                  ,p_customer_reference           => l_old_applied_invoice.customer_reference
		  ,p_claim_id                     => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status                => l_return_status
                  ,x_msg_data                     => x_msg_data
                  ,x_msg_count                    => x_msg_count
                  );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                 END IF;
               END IF;

               -- 4. Create credit memo for the invoice.
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 4. Create credit memo for the invoice.');
               END IF;
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_invoice_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => l_old_applied_invoice.amount_line_items_remaining
                  ,p_tax_remaining       => l_old_applied_invoice.tax_remaining
                  ,p_freight_remaining   => l_old_applied_invoice.freight_remaining
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_false
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;


               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 5. Apply same associated invoice with reduced amount');
               END IF;
               l_new_applied_amount := l_old_applied_invoice.amount_applied - p_sttlmnt_amt;

               IF l_new_applied_amount <> 0 THEN
                   Apply_on_Receipt(
                   p_cash_receipt_id              => p_claim_rec.receipt_id
                  ,p_customer_trx_id              => p_invoice_id
                  ,p_new_applied_amount           => l_new_applied_amount
                  ,p_comments                     => l_old_applied_invoice.comments
                  ,p_payment_set_id               => l_old_applied_invoice.payment_set_id
                  ,p_application_ref_type         => l_old_applied_invoice.application_ref_type
                  ,p_application_ref_id           => l_old_applied_invoice.application_ref_id
                  ,p_application_ref_num          => l_old_applied_invoice.application_ref_num
                  ,p_secondary_application_ref_id => l_old_applied_invoice.secondary_application_ref_id
                  ,p_application_ref_reason       => l_old_applied_invoice.application_ref_reason
                  ,p_customer_reference           => l_old_applied_invoice.customer_reference
		  ,p_claim_id                     => p_claim_rec.claim_id -- Added For Rule Based Settlement ER
                  ,x_return_status                => l_return_status
                  ,x_msg_data                     => x_msg_data
                  ,x_msg_count                    => x_msg_count
                  );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                 END IF;
               END IF;
              END IF;

  ELSIF p_deduction_type = 'CLAIM' THEN
           /*------------------------------------------------------------*
            | Claim - Credit to Tax/Line/Freight
            |    -> Create credit memo for the invoice.
            | Claim - Credit to --
            |    -> create credit memo for the invoice
            *------------------------------------------------------------*/

            IF p_line_credit = 0 AND
               p_tax_credit = 0 AND
               p_freight_credit = 0 AND
               p_total_credit <> 0 THEN
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Claim [Invoice Credit to --] -> 1. Create Credit Memo');
               END IF;
               -- 1. Create credit memo for the invoice
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_invoice_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => 0
                  ,p_tax_remaining       => 0
                  ,p_freight_remaining   => 0
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_false
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            ELSE
               -- 1. Create credit memo for the invoice
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Claim [Invoice Credit to Line/Tax/Freight] -> 1. Create credit memo for the invoice');
               END IF;
               Create_AR_Credit_Memo(
                   p_claim_rec           => p_claim_rec
                  ,p_customer_trx_id     => p_invoice_id
                  ,p_deduction_type      => p_deduction_type
                  ,p_line_remaining      => 0
                  ,p_tax_remaining       => 0
                  ,p_freight_remaining   => 0
                  ,p_line_credit         => p_line_credit
                  ,p_tax_credit          => p_tax_credit
                  ,p_freight_credit      => p_freight_credit
                  ,p_total_credit        => p_total_credit
                  ,p_cm_line_tbl         => p_cm_line_tbl
                  ,p_upd_dispute_flag    => FND_API.g_false
                  ,x_cm_customer_trx_id  => l_cm_customer_trx_id
                  ,x_cm_amount           => l_cm_amount
                  ,x_return_status       => l_return_status
                  ,x_msg_data            => x_msg_data
                  ,x_msg_count           => x_msg_count
               );
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
     END IF;

  /*------------------------------------------------------------*
   | Update Deduction payment detail
   *------------------------------------------------------------*/
   IF l_cm_customer_trx_id IS NOT NULL THEN
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
         ,p_payment_method         => p_claim_rec.payment_method
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => NULL
         ,p_customer_trx_id        => l_cm_customer_trx_id
         ,p_adjust_id              => NULL
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF g_debug THEN
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

END Pay_by_Single_Invoice_Credit;




/*=======================================================================*
 | PROCEDURE
 |    Pay_by_Invoice_Credit
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Invoice_Credit(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Pay_by_Invoice_Credit';
  l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status            VARCHAR2(1);

  l_cm_customer_trx_id       NUMBER       := NULL;
  l_cm_amount                NUMBER       := 0;
  l_new_applied_amount       NUMBER;
  l_old_applied_amount       NUMBER;
  l_claim_line_count         NUMBER;
  l_apply_receipt_id         NUMBER;
  l_line_activity_type       VARCHAR2(30);
  l_line_invoice_id          NUMBER;
  l_line_invoice_line_id     NUMBER;
  l_old_applied_claim_amount NUMBER;
  l_reapply_claim_amount     NUMBER;
  l_line_remaining           NUMBER;
  l_tax_remaining            NUMBER;
  l_freight_remaining        NUMBER;
  l_line_credit              NUMBER;
  l_tax_credit               NUMBER;
  l_freight_credit           NUMBER;
  l_total_credit             NUMBER;
  l_cm_line_tbl              AR_CREDIT_MEMO_API_PUB.cm_line_tbl_type_cover%TYPE;

  l_process_setl_wf          BOOLEAN;
  l_process_line_cr          BOOLEAN;


  CURSOR csr_old_applied_amount( cv_cash_receipt_id  IN NUMBER
                               , cv_customer_trx_id  IN NUMBER
                               ) IS
    SELECT rec.amount_applied
    ,      pay.amount_due_remaining
    ,      NVL(pay.amount_line_items_remaining, 0) amount_line_items_remaining
    ,      NVL(pay.tax_remaining, 0) tax_remaining
    ,      NVL(pay.freight_remaining, 0) freight_remaining
    ,      rec.comments
    ,      rec.payment_set_id
    ,      rec.application_ref_type
    ,      rec.application_ref_id
    ,      rec.application_ref_num
    ,      rec.secondary_application_ref_id
    ,      rec.application_ref_reason
    ,      rec.customer_reference
    FROM ar_receivable_applications rec
    , ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.display = 'Y';

l_old_applied_invoice    csr_old_applied_amount%ROWTYPE;

  CURSOR csr_count_claim_line(cv_claim_id IN NUMBER) IS
    SELECT COUNT(claim_line_id)
    FROM ozf_claim_lines
    WHERE claim_id = cv_claim_id;

  CURSOR csr_claim_line_invoice(cv_claim_id IN NUMBER) IS
    SELECT source_object_class
    ,      source_object_id
    ,      source_object_line_id
    FROM ozf_claim_lines
    WHERE claim_id = cv_claim_id;


  CURSOR csr_invoice_apply_receipt(cv_invoice_id IN NUMBER) IS
    SELECT rec.cash_receipt_id
    FROM ar_receivable_applications_all rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND pay.customer_trx_id = cv_invoice_id;

  CURSOR csr_old_claim_investigation( cv_cash_receipt_id IN NUMBER
                                    , cv_root_claim_id IN NUMBER) IS
    SELECT rec.amount_applied
    FROM ar_receivable_applications rec
    WHERE rec.applied_payment_schedule_id = -4
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_root_claim_id;

   CURSOR csr_customer_trx_lines(cv_invoice_line_id IN NUMBER) IS
      SELECT customer_trx_id
      FROM ra_customer_trx_lines
      WHERE customer_trx_line_id = cv_invoice_line_id;

   CURSOR csr_claim_lines(cv_claim_id IN NUMBER) IS
      SELECT source_object_id, sum(claim_currency_amount) amt
      FROM   ozf_claim_lines_all
      WHERE claim_id = cv_claim_id
      GROUP BY source_object_id;
   l_lines_rec csr_claim_lines%ROWTYPE;


BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   SAVEPOINT  Pay_by_Invoice_Credit;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
  /*------------------------------------------------------------*
   | Check Claim Line invoice to see if need to process settement workflow
   *------------------------------------------------------------*/
   IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED' , 'CLAIM') THEN
      l_process_setl_wf := OZF_AR_VALIDATION_PVT.Check_to_Process_SETL_WF(
                                     p_claim_rec      => p_claim_rec
                                    ,x_return_status  => l_return_status
                                    );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;


      IF g_debug THEN
         IF l_process_setl_wf THEN
             OZF_Utility_PVT.debug_message('Process Settlement Workflow? -> Yes' );
         ELSE
             OZF_Utility_PVT.debug_message('Process Settlement Workflow? -> No' );
         END IF;
      END IF;

      IF l_process_setl_wf THEN
        /*------------------------------------------------------------*
         | Process Settlement Workflow
         *------------------------------------------------------------*/
         Process_Settlement_WF(
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
         l_cm_customer_trx_id := NULL;
      ELSE

        /*------------------------------------------------------------*
         | Update Claim Status to CLOSED.
         *------------------------------------------------------------*/
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


         -- For each invoice to be credited, get credit details and create creditmemo.
         OPEN csr_claim_lines(p_claim_rec.claim_id);
         LOOP
           FETCH csr_claim_lines INTO l_lines_rec;
           EXIT WHEN csr_claim_lines%NOTFOUND;

               Get_Inv_Credit_Details(
                             p_claim_id       => p_claim_rec.claim_id
                            ,p_invoice_id     => l_lines_rec.source_object_id
                            ,x_return_status  => l_return_status
                            ,x_line_credit    => l_line_credit
                            ,x_tax_credit     => l_tax_credit
                            ,x_freight_credit => l_freight_credit
                            ,x_total_credit   => l_total_credit
                            ,x_cm_line_tbl    => l_cm_line_tbl);
               IF l_return_status =  FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
               END IF;

               Pay_by_Single_Invoice_Credit(
                             p_claim_rec       => p_claim_rec
                            ,p_sttlmnt_amt     =>  l_lines_rec.amt
                            ,p_invoice_id      => l_lines_rec.source_object_id
                            ,p_deduction_type  => p_deduction_type
                            ,p_line_credit     => l_line_credit
                            ,p_tax_Credit      => l_tax_credit
                            ,p_freight_credit  => l_freight_credit
                            ,p_total_credit    => l_total_credit
                            ,p_cm_line_tbl     => l_cm_line_tbl
                            ,x_return_status   => l_return_status
                            ,x_msg_data        => x_msg_data
                            ,x_msg_count       => x_msg_count
                       );
              IF l_return_status =  FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
              END IF;
         END LOOP;
         CLOSE csr_claim_lines;
     END IF;
  ELSE --p_deduction_type NOT IN ('SOURCE_DED', 'RECEIPT_DED', 'CLAIM')
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MESSAGE.set_token('CLAIM_NUMBER', p_claim_rec.claim_number);
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
  END IF;
EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      ROLLBACK  TO Pay_by_Invoice_Credit;

    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ROLLBACK  TO Pay_by_Invoice_Credit;

    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      ROLLBACK  TO Pay_by_Invoice_Credit;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Pay_By_Invoice_credit;




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

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Credit_Memo';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

   l_invoice_applied_count  NUMBER;
--   l_old_applied_amount     NUMBER;
   l_new_applied_amount     NUMBER;
   l_cm_customer_trx_id     NUMBER;
   l_cm_amount              NUMBER;
   l_online_upd_ded_status  BOOLEAN    := FALSE;
   l_orig_dispute_amount    NUMBER;
   l_p_new_applied_amount          NUMBER; --4684931
   l_p_new_applied_from_amount     NUMBER;
   l_receipt_currency              VARCHAR2(15);
   l_trx_currency                  VARCHAR2(15);
   l_cm_applied_on_rec_amt  NUMBER;
   l_apply_date ar_receivable_applications.apply_date%TYPE; -- Fix for Bug 3091401. TM passes old apply date
   l_cm_applied_on_rec_amt_from NUMBER;

    -- Fix for Bug 7494234
   CURSOR csr_old_applied_invoice( cv_cash_receipt_id  IN NUMBER
                                 , cv_customer_trx_id  IN NUMBER
                                 , cv_root_claim_id    IN NUMBER ) IS
    SELECT rec.application_ref_type
    ,      rec.application_ref_id
    ,      rec.application_ref_num
    ,      rec.secondary_application_ref_id
    ,      sum(rec.amount_applied) amount_applied
    ,      sum(rec.amount_applied_from) amount_applied_from --4684931
    FROM ar_receivable_applications rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_root_claim_id
    group by rec.application_ref_type, rec.application_ref_id, rec.application_ref_num,
             rec.secondary_application_ref_id;
    /*SELECT rec.comments
    ,      rec.payment_set_id
    ,      rec.application_ref_type
    ,      rec.application_ref_id
    ,      rec.application_ref_num
    ,      rec.secondary_application_ref_id
    ,      rec.application_ref_reason
    ,      rec.customer_reference
    ,      rec.amount_applied
    ,      rec.amount_applied_from --4684931
    ,      pay.amount_due_remaining
    FROM ar_receivable_applications rec
    ,    ar_payment_schedules pay
    WHERE rec.applied_payment_schedule_id = pay.payment_schedule_id
    AND rec.cash_receipt_id = cv_cash_receipt_id
    AND pay.customer_trx_id = cv_customer_trx_id
    AND rec.application_ref_type = 'CLAIM'
    AND rec.display = 'Y'
    AND rec.secondary_application_ref_id = cv_root_claim_id;
    */

  l_old_applied_invoice    csr_old_applied_invoice%ROWTYPE;

  CURSOR csr_claim_investigation_amount(cv_root_claim_id IN NUMBER) IS
     SELECT amount_applied
     FROM ar_receivable_applications
     WHERE application_ref_type = 'CLAIM'
     AND applied_payment_schedule_id = -4
     AND display = 'Y'
     AND secondary_application_ref_id = cv_root_claim_id;

  CURSOR csr_cm_exist_on_rec(cv_cash_receipt_id IN NUMBER, cv_customer_trx_id IN NUMBER) IS
     SELECT amount_applied,
            amount_applied_from,  --4684931
            apply_date -- Fix for Bug 3091401. TM passes old apply date
     FROM ar_receivable_applications
     WHERE cash_receipt_id = cv_cash_receipt_id
     AND applied_customer_trx_id = cv_customer_trx_id
     AND display = 'Y'
     AND status = 'APP';

  --4684931
  CURSOR csr_trx_currency(cv_customer_trx_id IN NUMBER) IS
        SELECT invoice_currency_code
        FROM ra_customer_trx
        WHERE customer_trx_id = cv_customer_trx_id;

  CURSOR csr_rec_currency(cv_cash_receipt_id IN NUMBER) IS
        SELECT currency_code
        FROM ar_cash_receipts
        WHERE cash_receipt_id = cv_cash_receipt_id;

  l_settlement_amount NUMBER := NULL;

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
      IF p_payment_reference_id IS NULL OR
         p_payment_reference_id = FND_API.g_miss_num THEN
        /*------------------------------------------------------------*
         | No payment reference specified (No open credit memo specified) -> AutoInvoice
         *------------------------------------------------------------*/
         IF g_debug THEN
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

         IF p_claim_rec.receipt_id IS NOT NULL THEN
            OPEN csr_cm_exist_on_rec(p_claim_rec.receipt_id, p_claim_rec.payment_reference_id);
            FETCH csr_cm_exist_on_rec INTO l_cm_applied_on_rec_amt, l_cm_applied_on_rec_amt_from, l_apply_date; -- Fix for Bug 3091401. TM passes old apply date
            CLOSE csr_cm_exist_on_rec;
         END IF;

         IF p_deduction_type = 'CLAIM' THEN
            l_online_upd_ded_status := TRUE;

         ELSIF p_deduction_type = 'SOURCE_DED' THEN
           /*------------------------------------------------------------*
            | <<OLD>>
            | Invoice Deduction -> 1. Update amount in dispute
            |                      2. Unapply invoice from receipt.
            |                      3. Apply credit memo with amount_settled on receipt.
            |                      4. Apply original invoice with old balance + amount_settled.
            | <<NEW: AR One off patch 2367036>>
            | Invoice Deduction -> 1. Update amount in dispute
            |                      2. Apply credit memo with amount_settled on receipt.
            |                      3. Reapply invoice related deduction.
            | <<Pay by Previous Open Credit Memo which already exists on the receipt>>:
            | Invoice Deduction -> 1. Update amount in dispute
            |                      1.5. Unapply existing credit memo
            |                      2. ReApply credit memo with increase amount on receipt.
            |                      3. Reapply invoice related deduction.
            *------------------------------------------------------------*/

            OPEN csr_old_applied_invoice( p_claim_rec.receipt_id
                                        , p_claim_rec.source_object_id
                                        , p_claim_rec.root_claim_id
                                        );
            FETCH csr_old_applied_invoice INTO l_old_applied_invoice;
            CLOSE csr_old_applied_invoice;

            --4684931
            OPEN csr_rec_currency(p_claim_rec.receipt_id);
            FETCH csr_rec_currency INTO l_receipt_currency;
            CLOSE csr_rec_currency;

            OPEN csr_trx_currency(p_payment_reference_id);
            FETCH csr_trx_currency INTO l_trx_currency;
            CLOSE csr_trx_currency;

            IF g_debug THEN
               OZF_Utility_PVT.debug_message('Invoice Deduction -> 1. Update amount in dispute');
            END IF;
            -- 1. Update amount in dispute
            Update_dispute_amount(
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
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction -> 2. Apply creit memo on receipt');
               END IF;
               --4684931
               IF l_trx_currency = p_claim_rec.currency_code THEN
                  l_p_new_applied_amount       := p_credit_memo_amount * -1;
                  l_p_new_applied_from_amount  := NULL;
               /*
               ELSE
                 ??
               */
               END IF;

               -- 2. Apply creit memo on receipt
               Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  --,p_receipt_number     => p_claim_rec.receipt_number
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount      => l_p_new_applied_amount --4684931
                  ,p_new_applied_from_amount => l_p_new_applied_from_amount
                  ,p_comments           => SUBSTRB(p_claim_rec.comments, 1, 240)
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
                 IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Invoice Deduction: Pay by Previous Open Credit Memo which already exists on the receipt');
                   OZF_Utility_PVT.debug_message('Invoice Deduction -> 2. Reapply credit memo with new amount on receipt');
               END IF;

              l_settlement_amount := (p_credit_memo_amount * -1) ; -- Bug4308188

              --4684931
              IF l_trx_currency = p_claim_rec.currency_code THEN
                l_p_new_applied_amount       := l_cm_applied_on_rec_amt + (p_credit_memo_amount * -1);
                l_p_new_applied_from_amount  := NULL;
              END IF;

              -- 2. Reapply credit memo on receipt
              arp_deduction_cover2.reapply_credit_memo(
                                p_customer_trx_id => p_payment_reference_id ,
                                p_cash_receipt_id => p_claim_rec.receipt_id,
                                p_amount_applied  =>  l_p_new_applied_amount,  --4684931
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

            IF g_debug THEN
               OZF_Utility_PVT.debug_message('Invoice Deduction -> 3. Unapply claim investigation');
               OZF_Utility_PVT.debug_message('original invoice deduction amount = '||l_old_applied_invoice.amount_applied);
               OZF_Utility_PVT.debug_message('reapply invoice deduction amount = '||(l_old_applied_invoice.amount_applied + p_credit_memo_amount));
            END IF;
            -- 3. Reapply claim investigation
            Unapply_Claim_Investigation(
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
            --4684931
                l_receipt_currency := p_claim_rec.currency_code;

            OPEN csr_trx_currency(p_payment_reference_id);
            FETCH csr_trx_currency INTO l_trx_currency;
            CLOSE csr_trx_currency;

            IF l_cm_applied_on_rec_amt IS NULL THEN
              /*------------------------------------------------------------*
               | Receipt Deduction -> 1. Apply credit memo on receipt.
               |                      2. Unapply claim investigation
               | <<Pay by Previous Open Credit Memo which already exists on the receipt>>:
               | Receipt Deduction -> 0.5. Unapply credit memo on receipt
               |                      1. Apply credit memo with increased amount on receipt
               |                      2. Unapply claim investigation
               *------------------------------------------------------------*/
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 1. Apply creit memo on receipt');
               END IF;

               --4684931
               IF l_receipt_currency = l_trx_currency THEN
                        l_p_new_applied_amount       := p_credit_memo_amount * -1;
                        l_p_new_applied_from_amount  := NULL;
                     ELSE
                        l_p_new_applied_amount       := NULL;
                        l_p_new_applied_from_amount  := p_credit_memo_amount * -1;
                     END IF;

               -- 1. Apply creit memo on receipt
               Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount      => l_p_new_applied_amount --4684931
                  ,p_new_applied_from_amount => l_p_new_applied_from_amount
                  ,p_comments           => SUBSTRB(p_claim_rec.comments, 1, 240)
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
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 2. Unapply claim investigation');
               END IF;
            ELSE
              /*------------------------------------------------------------*
               | Receipt Deduction
               *------------------------------------------------------------*/
               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction: Pay by Previous Open Credit Memo which already exists on the receipt');
               END IF;

               IF g_debug THEN
                  OZF_Utility_PVT.debug_message('Receipt Deduction -> 1. Reapply creit memo with increased amount on receipt');
               END IF;

               l_settlement_amount := (p_credit_memo_amount * -1); -- Bug4308188
               --4684931
               IF l_receipt_currency = l_trx_currency THEN
                  l_p_new_applied_amount       := l_cm_applied_on_rec_amt + (p_credit_memo_amount * -1);
                  l_p_new_applied_from_amount  := NULL;
               ELSE
                  l_p_new_applied_amount       := NULL;
                  l_p_new_applied_from_amount  := l_cm_applied_on_rec_amt + (p_credit_memo_amount * -1);
               END IF;

               arp_deduction_cover2.reapply_credit_memo(
                                p_customer_trx_id => p_payment_reference_id ,
                                p_cash_receipt_id => p_claim_rec.receipt_id,
                                p_amount_applied  =>  l_p_new_applied_amount,
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

            IF g_debug THEN
               OZF_Utility_PVT.debug_message('original claim investigation amount = '||l_orig_dispute_amount);
               OZF_Utility_PVT.debug_message('reapply claim investigation amount = '||(l_orig_dispute_amount + p_credit_memo_amount));
            END IF;
            Unapply_Claim_Investigation(
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
         END IF; -- end if p_deduction_type
      END IF; -- end if payment_reference_id is null

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
            ,p_payment_method         => p_claim_rec.payment_method
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => p_payment_reference_id
            ,p_adjust_id              => NULL
            ,p_settlement_amount      => l_settlement_amount    -- Bug4308188
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;

   IF g_debug THEN
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
                                    , cv_root_claim_id IN NUMBER) IS
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
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
  /*------------------------------------------------------------*
   | Update Claim Status to CLOSED.
   *------------------------------------------------------------*/
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

   IF p_deduction_type = 'RECEIPT_OPM' THEN
     /*------------------------------------------------------------*
      | Overpayment -> 1. Unapply claim investigation
      |                2. Apply On Account Credit
      *------------------------------------------------------------*/
      IF g_debug THEN
         OZF_Utility_PVT.debug_message('Overpayment -> 1. Unapply claim investigation.');
      END IF;
      -- 1. Unapply claim investigation
      OPEN csr_old_claim_investigation(p_claim_rec.receipt_id, p_claim_rec.root_claim_id);
      FETCH csr_old_claim_investigation INTO l_old_applied_claim_amount;
      CLOSE csr_old_claim_investigation;

      l_reapply_claim_amount := l_old_applied_claim_amount - (p_claim_rec.amount_settled * -1);

      Unapply_Claim_Investigation(
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

      IF g_debug THEN
         OZF_Utility_PVT.debug_message('Overpayment -> 2. Apply On Account Credit.');
      END IF;
      --2. Apply On Account Credit
      Apply_On_Account_Credit(
          p_claim_rec          => p_claim_rec
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
      IF g_debug THEN
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
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   IF g_debug THEN
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
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
  /*------------------------------------------------------------*
   | Update Claim Status to CLOSED.
   *------------------------------------------------------------*/
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

   IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
      IF p_deduction_type = 'SOURCE_DED'THEN
         l_chargeback_amount := p_claim_rec.amount_settled;
      ELSIF p_deduction_type = 'RECEIPT_DED'THEN
         l_chargeback_amount := p_claim_rec.amount_settled * -1;
      END IF;

      Create_AR_Chargeback(
          p_claim_rec          => p_claim_rec
         ,p_chargeback_amount  => l_chargeback_amount
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
            ,p_payment_method         => p_claim_rec.payment_method
            ,p_deduction_type         => p_deduction_type
            ,p_cash_receipt_id        => p_claim_rec.receipt_id
            ,p_customer_trx_id        => l_cb_customer_trx_id
            ,p_adjust_id              => NULL
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


   IF g_debug THEN
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
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type = 'RECEIPT_DED' AND
      NOT ARP_DEDUCTION_COVER.negative_rct_writeoffs_allowed THEN
     /*------------------------------------------------------------
      | Receipt Deduction -> Invoke Settlement Workflow
      *-----------------------------------------------------------*/
      Process_Settlement_WF(
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

   ELSIF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED', 'RECEIPT_OPM') THEN
     /*------------------------------------------------------------*
      | Update Claim Status to CLOSED.
      *------------------------------------------------------------*/
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

      Create_AR_Write_Off(
          p_claim_rec          => p_claim_rec
         ,p_deduction_type     => p_deduction_type
         ,p_write_off_amount   => p_claim_rec.amount_settled
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

   IF g_debug THEN
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
  l_p_new_applied_amount           NUMBER;
  l_p_new_applied_from_amount      NUMBER; --bug 4684931
  l_receipt_currency               VARCHAR2(15);
  l_trx_currency                   VARCHAR2(15);
  l_dm_applied_on_rec_amt   NUMBER ;
  l_apply_date ar_receivable_applications.apply_date%TYPE; -- Fix for Bug 3091401. TM passes old apply date
  l_dm_applied_on_rec_amt_from NUMBER;

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
     SELECT amount_applied,
            amount_applied_from,--bug 4684931
            apply_date -- Fix for Bug 3091401. TM passes old apply date
     FROM ar_receivable_applications
     WHERE cash_receipt_id = cv_cash_receipt_id
     AND applied_customer_trx_id = cv_customer_trx_id
     AND display = 'Y'
     AND status = 'APP';

l_settlement_amount NUMBER := NULL ;

-- Start Fix for Bug4324426
CURSOR csr_ded_details(p_customer_trx_id IN NUMBER) IS
   SELECT claim_id, amount_due_remaining FROM ozf_claims_all, ar_payment_schedules_all
   WHERE source_object_id = customer_trx_id
   AND   source_object_class = class
   AND   claim_class  = 'DEDUCTION'
   AND   cust_account_id = customer_id
   AND   customer_trx_id = p_customer_trx_id;

--bug 4684931
CURSOR csr_trx_currency(cv_customer_trx_id IN NUMBER) IS
      SELECT invoice_currency_code
      FROM ra_customer_trx
      WHERE customer_trx_id = cv_customer_trx_id;

l_deduction_id          NUMBER;
l_amt_due_remaining     NUMBER;
l_object_ver_number NUMBER;

l_deduction_rec          OZF_CLAIM_GRP.DEDUCTION_REC_TYPE;
l_stlmnt_amount          NUMBER;
-- End Fix for Bug4324426

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type IN ('RECEIPT_OPM', 'CHARGE') THEN
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

         --bug 4684931
         l_receipt_currency := p_claim_rec.currency_code;
         OPEN csr_trx_currency(p_payment_reference_id);
         FETCH csr_trx_currency INTO l_trx_currency;
         CLOSE csr_trx_currency;

         IF p_deduction_type = 'CHARGE' THEN
            l_online_upd_ded_status := TRUE;

         ELSIF p_deduction_type = 'RECEIPT_OPM' THEN
           /*------------------------------------------------------------*
            | Overpayment -> 1. Apply debit memo on receipt.
            |                2. Unapply claim investigation
            | <<Pay by Previous Open Debit Memo which already exists on the receipt>>:
            | Overpayment -> 1. Unapply claim investigation
            |                1.5. Unapply debit memo on receipt
            |                2. Apply debit memo on receipt.
            *------------------------------------------------------------*/
            OPEN csr_dm_exist_on_rec(p_claim_rec.receipt_id, p_payment_reference_id);
            FETCH csr_dm_exist_on_rec INTO l_dm_applied_on_rec_amt, l_dm_applied_on_rec_amt_from, l_apply_date; -- Fix for Bug 3091401. TM passes old apply date
            CLOSE csr_dm_exist_on_rec;

            OZF_Utility_PVT.debug_message('Overpayment -> 1. Unapply claim investigation');
            -- 1. Unapply claim investigation
            OPEN csr_claim_investigation_amount(p_claim_rec.root_claim_id);
            FETCH csr_claim_investigation_amount INTO l_orig_dispute_amount;
            CLOSE csr_claim_investigation_amount;

            OZF_Utility_PVT.debug_message('original overpayment amount = '||l_orig_dispute_amount);
            OZF_Utility_PVT.debug_message('reapply overpayment amount = '||(l_orig_dispute_amount + p_debit_memo_amount));

            Unapply_Claim_Investigation(
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

            l_stlmnt_amount := NVL(l_dm_applied_on_rec_amt,0) + (p_debit_memo_amount * -1);
            IF l_dm_applied_on_rec_amt IS NULL THEN
               OZF_Utility_PVT.debug_message('Overpayment -> 2. Apply debit memo on receipt');
              --bug4684931
              IF l_receipt_currency = l_trx_currency THEN
                  l_p_new_applied_amount       := NVL(l_dm_applied_on_rec_amt,0) + (p_debit_memo_amount * -1);
                  l_p_new_applied_from_amount  := NULL;
              ELSE
                  l_p_new_applied_amount       := NULL;
                  l_p_new_applied_from_amount  := NVL(l_dm_applied_on_rec_amt_from,0) + (p_debit_memo_amount * -1);
              END IF;

               -- 2. Apply debit memo on receipt
               Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount      => l_p_new_applied_amount --bug4684931
                  ,p_new_applied_from_amount => l_p_new_applied_from_amount --bug4684931
                  ,p_comments           => SUBSTRB(p_claim_rec.comments, 1, 240)
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
               Unapply_from_Receipt(
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
               l_settlement_amount := (p_debit_memo_amount * -1); -- Bug4308188

               --bug 4684931
               IF l_receipt_currency = l_trx_currency THEN
                  l_p_new_applied_amount       := NVL(l_dm_applied_on_rec_amt,0) + (p_debit_memo_amount * -1);
                  l_p_new_applied_from_amount  := NULL;
               ELSE
                  l_p_new_applied_amount       := NULL;
                  l_p_new_applied_from_amount  := NVL(l_dm_applied_on_rec_amt,0) + (p_debit_memo_amount * -1);
               END IF;

               -- 2. Apply creit memo on receipt
               Apply_on_Receipt(
                   p_cash_receipt_id    => p_claim_rec.receipt_id
                  ,p_customer_trx_id    => p_payment_reference_id
                  ,p_new_applied_amount => l_p_new_applied_amount
                  ,p_new_applied_from_amount  =>   l_p_new_applied_from_amount
                  ,p_comments           => SUBSTRB(p_claim_rec.comments, 1, 240)
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
      END IF;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
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
         ,p_payment_method         => p_claim_rec.payment_method
         ,p_deduction_type         => p_deduction_type
         ,p_cash_receipt_id        => p_claim_rec.receipt_id
         ,p_customer_trx_id        => p_payment_reference_id
         ,p_adjust_id              => NULL
         ,p_settlement_amount      => l_settlement_amount -- Bug4308188
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   IF g_debug THEN
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
 |    Pay_by_Contra_Charge
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Pay_by_Contra_Charge(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_deduction_type         IN    VARCHAR2

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_Contra_Charge';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);


BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   IF p_deduction_type IN ('SOURCE_DED', 'RECEIPT_DED') THEN
      -- invoke claim settlement workflow
      BEGIN
      OZF_AR_SETTLEMENT_PVT.Start_Settlement(
           p_claim_id                => p_claim_rec.claim_id
          ,p_prev_status             => 'APPROVED'
          ,p_curr_status             => 'PENDING_CLOSE'
          ,p_next_status             => 'CLOSED'
      );
      EXCEPTION
         WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',sqlerrm);
            FND_MSG_PUB.Add;
            RAISE FND_API.g_exc_unexpected_error;
      END;
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_AR_PAYMENT_NOTMATCH');
        FND_MSG_PUB.add;
      END IF;
   END IF;

   IF g_debug THEN
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

END Pay_by_Contra_Charge;


/*=======================================================================*
 | PROCEDURE
 |    Create_AR_Payment
 |
 | NOTES
 |
 | HISTORY
 |    15-MAR-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Create_AR_Payment(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'Create_AR_Payment';
  l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
  l_return_status        VARCHAR2(1);

  l_claim_rec            OZF_Claim_PVT.claim_rec_type;
  l_deduction_type       VARCHAR2(30) := NULL;

BEGIN
   -------------------- initialize -----------------------
   SAVEPOINT Create_AR_Payment;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   Query_Claim(
        p_claim_id           => p_claim_id
       ,x_claim_rec          => l_claim_rec
       ,x_return_status      => l_return_status
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF g_debug THEN
      OZF_Utility_PVT.debug_message('Create Payment for ==> '||l_claim_rec.claim_number);
   END IF;

   IF l_claim_rec.claim_class = 'DEDUCTION' THEN
      IF l_claim_rec.source_object_class IS NOT NULL AND
         l_claim_rec.source_object_id IS NOT NULL AND
         l_claim_rec.source_object_number IS NOT NULL THEN
         l_deduction_type := 'SOURCE_DED';
      ELSE
         l_deduction_type := 'RECEIPT_DED';
      END IF;
   ELSIF l_claim_rec.claim_class = 'OVERPAYMENT' THEN
      IF l_claim_rec.source_object_class IS NOT NULL AND
         l_claim_rec.source_object_id IS NOT NULL AND
         l_claim_rec.source_object_number IS NOT NULL THEN
         l_deduction_type := 'SOURCE_OPM';
      ELSE
         l_deduction_type := 'RECEIPT_OPM';
      END IF;
   ELSIF l_claim_rec.claim_class = 'CLAIM' THEN
      l_deduction_type := 'CLAIM';
   ELSIF l_claim_rec.claim_class = 'CHARGE' THEN
      l_deduction_type := 'CHARGE';
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DED_TYPE_ERR');
        FND_MSG_PUB.add;
      END IF;
   END IF;

--R12.1 Enhancement start :Close the claim contains the payment method as ACCOUNTING_ONLY
-- Introduced the class CHARGE for RMA internal Ship and Debit claim
IF l_deduction_type IN ('CLAIM','CHARGE') THEN
   IF l_claim_rec.payment_method = 'ACCOUNTING_ONLY' THEN

     Close_Claim(
          p_claim_rec        => l_claim_rec
         ,x_return_status    => l_return_status
         ,x_msg_data         => x_msg_data
         ,x_msg_count        => x_msg_count
      );

      OZF_Utility_PVT.debug_message('After calling the close_claim  ==> '||l_return_status);
      OZF_Utility_PVT.debug_message('After calling the close_claim  ==> '||l_claim_rec.claim_id);
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
OZF_Utility_PVT.debug_message('Before calling the update_payment_detail  ==> '||l_claim_rec.claim_id);
-- To create the settlement doc.
       OZF_SETTLEMENT_DOC_PVT.Update_Payment_Detail(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_data               => x_msg_data
            ,x_msg_count              => x_msg_count
            ,p_claim_id               => l_claim_rec.claim_id
            ,p_payment_method         => 'ACCOUNTING_ONLY'
            ,p_deduction_type         => 'CLAIM'
            ,p_cash_receipt_id        => NULL
            ,p_customer_trx_id        => NULL --l_claim_rec.source_object_id
            ,p_adjust_id              => NULL
          );
        OZF_Utility_PVT.debug_message('After calling update_payment_detail  ==> '||l_return_status);
        OZF_Utility_PVT.debug_message('After calling update_payment_detail  ==> '||l_claim_rec.claim_id);
          IF l_return_status =  FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
    END IF;
END IF;
--R12.1 Enhancement end

   IF l_deduction_type = 'SOURCE_OPM' THEN
      Process_Settlement_WF(
          p_claim_id         => p_claim_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => x_msg_data
         ,x_msg_count        => x_msg_count
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
--R12.1 Enhancement : Check for ACCOUNTING_ONLY
   ELSIF l_claim_rec.payment_method <> 'ACCOUNTING_ONLY' THEN
      IF l_claim_rec.payment_method = 'REG_CREDIT_MEMO' THEN
         Pay_by_Invoice_Credit(
             p_claim_rec          => l_claim_rec
            ,p_deduction_type     => l_deduction_type
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_claim_rec.payment_method in ( 'CREDIT_MEMO', 'PREV_OPEN_CREDIT') THEN
         Pay_by_Credit_Memo(
             p_claim_rec             => l_claim_rec
            ,p_deduction_type        => l_deduction_type
            ,p_payment_reference_id  => l_claim_rec.payment_reference_id
            ,p_credit_memo_amount    => l_claim_rec.amount_settled
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_claim_rec.payment_method = 'ON_ACCT_CREDIT' THEN
         Pay_by_On_Account_Credit(
             p_claim_rec          => l_claim_rec
            ,p_deduction_type     => l_deduction_type
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_claim_rec.payment_method = 'CHARGEBACK' THEN
         Pay_by_Chargeback(
             p_claim_rec          => l_claim_rec
            ,p_deduction_type     => l_deduction_type
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF (l_claim_rec.payment_method = 'WRITE_OFF')
      THEN
         Pay_by_Write_Off(
             p_claim_rec          => l_claim_rec
            ,p_deduction_type     => l_deduction_type
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_claim_rec.payment_method  IN ( 'DEBIT_MEMO', 'PREV_OPEN_DEBIT') THEN
         Pay_by_Debit_Memo(
             p_claim_rec            => l_claim_rec
            ,p_deduction_type       => l_deduction_type
            ,p_payment_reference_id => l_claim_rec.payment_reference_id
            ,p_debit_memo_amount    => l_claim_rec.amount_settled
            ,x_return_status        => l_return_status
            ,x_msg_data             => x_msg_data
            ,x_msg_count            => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSIF l_claim_rec.payment_method = 'CONTRA_CHARGE' THEN
         Pay_by_Contra_Charge(
             p_claim_rec          => l_claim_rec
            ,p_deduction_type     => l_deduction_type
            ,x_return_status      => l_return_status
            ,x_msg_data           => x_msg_data
            ,x_msg_count          => x_msg_count
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

      ELSE
      OZF_Utility_PVT.debug_message('KP1 Test: end');
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_DED_PAYMETHOD_ERR');
            FND_MESSAGE.set_token('PAYMENT_METHOD', l_claim_rec.payment_method);
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   ------------------------ finish ------------------------
   FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Create_AR_Payment;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Create_AR_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN OTHERS THEN
      ROLLBACK TO Create_AR_Payment;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Create_AR_Payment;

/*======================================================================*
 | PROCEDURE
 |    Pay_by_RMA_Inv_CM
 |
 | NOTES
 |
 | HISTORY
 |    22-NOV-2004  Sahana  Created for Bug3951827
 *=======================================================================*/
PROCEDURE Pay_by_RMA_Inv_CM(
    p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,p_credit_memo_amount     IN    NUMBER

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Pay_by_RMA_Inv_CM';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_return_status        VARCHAR2(1);

BEGIN
   -------------------- initialize -----------------------
   IF g_debug THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;
   x_return_status := FND_API.g_ret_sts_success;

  /*------------------------------------------------------------*
  | Update Claim Status to CLOSED.
  *------------------------------------------------------------*/

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


  -- Update amount in dispute
  Update_dispute_amount(
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

  IF g_debug THEN
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

END Pay_by_RMA_Inv_CM;

END OZF_AR_PAYMENT_PVT;

/
