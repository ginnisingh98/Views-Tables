--------------------------------------------------------
--  DDL for Package Body OZF_CLAIMS_HISTORY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIMS_HISTORY_PVT" as
/* $Header: ozfvchib.pls 120.1 2005/09/15 22:40:06 appldev ship $ */
-- Start of Comments
-- Package name     : OZF_claims_history_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'OZF_claims_history_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvchib.pls';

G_UPDATE_EVENT       CONSTANT VARCHAR2(30) := 'UPDATE';
G_LINE_EVENT         CONSTANT VARCHAR2(30) := 'LINE';
G_LINE_EVENT_DESC    CONSTANT VARCHAR2(30) := 'LINE';
G_SPLIT_EVENT        CONSTANT VARCHAR2(30) := 'SPLIT';
G_SETTLEMENT_EVENT   CONSTANT VARCHAR2(30) := 'SETL';
G_NEW_EVENT          CONSTANT VARCHAR2(30) := 'NEW';
G_NO_CHANGE_EVENT  CONSTANT VARCHAR2(30) := 'NOCHANGE';

--Start Bug:2781186
G_SUBSEQUENT_APPLY_EVENT       CONSTANT VARCHAR2(30) := 'SUBSEQUENT_APPLY';
G_SUBSEQUENT_UNAPPLY_EVENT     CONSTANT VARCHAR2(30) := 'SUBSEQUENT_UNAPPLY';
--End Bug:2781186

G_CHANGE_EVENT       CONSTANT VARCHAR2(30) :='CHANGES';  -- This event is returned to the caller.
--Start Bug:2781186
G_SUBSEQUENT_APPLY_CHG_EVENT   CONSTANT VARCHAR2(30) :='APPLY';    -- This event is returned to the caller.
G_SUBSEQUENT_UNAPPLY_CHG_EVENT CONSTANT VARCHAR2(30) :='UNAPPLY';  -- This event is returned to the caller.
--End Bug:2781186

G_NEW_STATUS        CONSTANT VARCHAR2(30) :='NEW';
G_CLAIM_TYPE         CONSTANT VARCHAR2(30) :='OZF_CLAM';
G_CLAIM_HIST_OBJ_TYPE CONSTANT VARCHAR2(30) :='CLAMHIST';

OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

-- define types private to this package.

---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_History_Rec
--
-- PURPOSE
--    For Update_Claim_history, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_claim_history_rec  : the record which may contain attributes as
--                    FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--                    have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE Complete_Claim_History_Rec (
   p_claim_history_rec  IN   claims_history_rec_type
  ,x_complete_rec     OUT NOCOPY  claims_history_rec_type
  ,x_return_status    OUT NOCOPY  varchar2
)
IS
CURSOR c_claim_history_csr (p_id in NUMBER) IS
SELECT * FROM ozf_claims_history_all
WHERE claim_history_id = p_id;

l_claim_history_rec    c_claim_history_csr%ROWTYPE;
l_api_name  varchar2(30) := 'Complete_Claim_History_Rec';
BEGIN
--	letter_id                       NUMBER := FND_API.G_MISS_NUM,
--       letter_date                     DATE := FND_API.G_MISS_DATE,

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Api body
   --
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   x_complete_rec  := p_claim_history_rec;

  OPEN c_claim_history_csr(p_claim_history_rec.claim_history_id);
  FETCH c_claim_history_csr INTO l_claim_history_rec;
     IF c_claim_history_csr%NOTFOUND THEN
        CLOSE c_claim_history_csr;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.set_name('OZF','OZF_API_RECORD_NOT_FOUND');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
     END IF;
  CLOSE c_claim_history_csr;

  IF p_claim_history_rec.claim_history_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_history_id       := NULL;
  END IF;
  IF p_claim_history_rec.claim_history_id         IS NULL THEN
     x_complete_rec.claim_history_id       := l_claim_history_rec.claim_history_id;
  END IF;
  IF p_claim_history_rec.object_version_number  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.object_version_number       := NULL;
  END IF;
  IF p_claim_history_rec.object_version_number  IS NULL THEN
     x_complete_rec.object_version_number       := l_claim_history_rec.object_version_number;
  END IF;
  IF p_claim_history_rec.claim_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_id       := NULL;
  END IF;
  IF p_claim_history_rec.claim_id         IS NULL THEN
     x_complete_rec.claim_id       := l_claim_history_rec.claim_id;
  END IF;
  IF p_claim_history_rec.batch_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.batch_id       := NULL;
  END IF;
  IF p_claim_history_rec.batch_id         IS NULL THEN
     x_complete_rec.batch_id       := l_claim_history_rec.batch_id;
  END IF;
  IF p_claim_history_rec.claim_number         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.claim_number       := NULL;
  END IF;
  IF p_claim_history_rec.claim_number         IS NULL THEN
     x_complete_rec.claim_number       := l_claim_history_rec.claim_number;
  END IF;
  IF p_claim_history_rec.claim_type_id         = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_type_id       := NULL;
  END IF;
  IF p_claim_history_rec.claim_type_id         IS NULL THEN
     x_complete_rec.claim_type_id       := l_claim_history_rec.claim_type_id;
  END IF;
  IF p_claim_history_rec.claim_class         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.claim_class       := NULL;
  END IF;
  IF p_claim_history_rec.claim_class         IS NULL THEN
     x_complete_rec.claim_class       := l_claim_history_rec.claim_class;
  END IF;
  IF p_claim_history_rec.claim_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.claim_date       := NULL;
  END IF;
  IF p_claim_history_rec.claim_date         IS NULL THEN
     x_complete_rec.claim_date       := l_claim_history_rec.claim_date;
  END IF;
  IF p_claim_history_rec.due_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.due_date       := NULL;
  END IF;
  IF p_claim_history_rec.due_date         IS NULL THEN
     x_complete_rec.due_date       := l_claim_history_rec.due_date;
  END IF;
  IF p_claim_history_rec.owner_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.owner_id := NULL;
  END IF;
  IF p_claim_history_rec.owner_id  IS NULL THEN
     x_complete_rec.owner_id := l_claim_history_rec.owner_id;
  END IF;
  IF p_claim_history_rec.history_event  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.history_event := NULL;
  END IF;
  IF p_claim_history_rec.history_event  IS NULL THEN
     x_complete_rec.history_event := l_claim_history_rec.history_event;
  END IF;
  IF p_claim_history_rec.history_event_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.history_event_date := NULL;
  END IF;
  IF p_claim_history_rec.history_event_date  IS NULL THEN
     x_complete_rec.history_event_date := l_claim_history_rec.history_event_date;
  END IF;
  IF p_claim_history_rec.history_event_description  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.history_event_description := NULL;
  END IF;
  IF p_claim_history_rec.history_event_description  IS NULL THEN
     x_complete_rec.history_event_description := l_claim_history_rec.history_event_description;
  END IF;
  IF p_claim_history_rec.split_from_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.split_from_claim_id       := NULL;
  END IF;
  IF p_claim_history_rec.split_from_claim_id  IS NULL THEN
     x_complete_rec.split_from_claim_id       := l_claim_history_rec.split_from_claim_id;
  END IF;
  IF p_claim_history_rec.duplicate_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.duplicate_claim_id       := NULL;
  END IF;
  IF p_claim_history_rec.duplicate_claim_id  IS NULL THEN
     x_complete_rec.duplicate_claim_id       := l_claim_history_rec.duplicate_claim_id;
  END IF;
  IF p_claim_history_rec.split_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.split_date := NULL;
  END IF;
  IF p_claim_history_rec.split_date  IS NULL THEN
     x_complete_rec.split_date := l_claim_history_rec.split_date;
  END IF;
  IF p_claim_history_rec.root_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.root_claim_id       := NULL;
  END IF;
  IF p_claim_history_rec.root_claim_id  IS NULL THEN
     x_complete_rec.root_claim_id       := l_claim_history_rec.root_claim_id;
  END IF;
  IF p_claim_history_rec.amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount       := NULL;
  END IF;
  IF p_claim_history_rec.amount  IS NULL THEN
     x_complete_rec.amount       := l_claim_history_rec.amount;
  END IF;
  IF p_claim_history_rec.amount_adjusted  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_adjusted       := NULL;
  END IF;
  IF p_claim_history_rec.amount_adjusted  IS NULL THEN
     x_complete_rec.amount_adjusted       := l_claim_history_rec.amount_adjusted;
  END IF;
  IF p_claim_history_rec.amount_remaining  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_remaining       := NULL;
  END IF;
  IF p_claim_history_rec.amount_remaining  IS NULL THEN
     x_complete_rec.amount_remaining       := l_claim_history_rec.amount_remaining;
  END IF;
  IF p_claim_history_rec.amount_settled  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_settled       := NULL;
  END IF;
  IF p_claim_history_rec.amount_settled  IS NULL THEN
     x_complete_rec.amount_settled       := l_claim_history_rec.amount_settled;
  END IF;
  IF p_claim_history_rec.acctd_amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount       := NULL;
  END IF;
  IF p_claim_history_rec.acctd_amount  IS NULL THEN
     x_complete_rec.acctd_amount       := l_claim_history_rec.acctd_amount;
  END IF;
  IF p_claim_history_rec.acctd_amount_remaining   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_remaining        := NULL;
  END IF;
  IF p_claim_history_rec.acctd_amount_remaining   IS NULL THEN
     x_complete_rec.acctd_amount_remaining        := l_claim_history_rec.acctd_amount_remaining ;
  END IF;
  IF p_claim_history_rec.acctd_amount_adjusted  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_adjusted       := NULL;
  END IF;
  IF p_claim_history_rec.acctd_amount_adjusted  IS NULL THEN
     x_complete_rec.acctd_amount_adjusted       := l_claim_history_rec.acctd_amount_adjusted;
  END IF;
  IF p_claim_history_rec.acctd_amount_settled  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount_settled       := NULL;
  END IF;
  IF p_claim_history_rec.acctd_amount_settled  IS NULL THEN
     x_complete_rec.acctd_amount_settled       := l_claim_history_rec.acctd_amount_settled;
  END IF;
  IF p_claim_history_rec.tax_amount   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.tax_amount        := NULL;
  END IF;
  IF p_claim_history_rec.tax_amount   IS NULL THEN
     x_complete_rec.tax_amount        := l_claim_history_rec.tax_amount ;
  END IF;
  IF p_claim_history_rec.tax_code   = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_code        := NULL;
  END IF;
  IF p_claim_history_rec.tax_code   IS NULL THEN
     x_complete_rec.tax_code        := l_claim_history_rec.tax_code ;
  END IF;
  IF p_claim_history_rec.tax_calculation_flag   = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_calculation_flag        := NULL;
  END IF;
  IF p_claim_history_rec.tax_calculation_flag   IS NULL THEN
     x_complete_rec.tax_calculation_flag        := l_claim_history_rec.tax_calculation_flag ;
  END IF;
  IF p_claim_history_rec.currency_code         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.currency_code       := NULL;
  END IF;
  IF p_claim_history_rec.currency_code         IS NULL THEN
     x_complete_rec.currency_code       := l_claim_history_rec.currency_code;
  END IF;
  IF p_claim_history_rec.exchange_rate_type         = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.exchange_rate_type       := NULL;
  END IF;
  IF p_claim_history_rec.exchange_rate_type         IS NULL THEN
     x_complete_rec.exchange_rate_type       := l_claim_history_rec.exchange_rate_type;
  END IF;
  IF p_claim_history_rec.exchange_rate_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.exchange_rate_date       := NULL;
  END IF;
  IF p_claim_history_rec.exchange_rate_date         IS NULL THEN
     x_complete_rec.exchange_rate_date       := l_claim_history_rec.exchange_rate_date;
  END IF;
  IF p_claim_history_rec.exchange_rate  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.exchange_rate       := NULL;
  END IF;
  IF p_claim_history_rec.exchange_rate  IS NULL THEN
     x_complete_rec.exchange_rate       := l_claim_history_rec.exchange_rate;
  END IF;
  IF p_claim_history_rec.set_of_books_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.set_of_books_id       := NULL;
  END IF;
  IF p_claim_history_rec.set_of_books_id  IS NULL THEN
     x_complete_rec.set_of_books_id       := l_claim_history_rec.set_of_books_id;
  END IF;
  IF p_claim_history_rec.original_claim_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.original_claim_date       := NULL;
  END IF;
  IF p_claim_history_rec.original_claim_date         IS NULL THEN
     x_complete_rec.original_claim_date       := l_claim_history_rec.original_claim_date;
  END IF;
  IF p_claim_history_rec.source_object_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_id       := NULL;
  END IF;
  IF p_claim_history_rec.source_object_id  IS NULL THEN
     x_complete_rec.source_object_id       := l_claim_history_rec.source_object_id;
  END IF;
  IF p_claim_history_rec.source_object_class  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.source_object_class       := NULL;
  END IF;
  IF p_claim_history_rec.source_object_class  IS NULL THEN
     x_complete_rec.source_object_class       := l_claim_history_rec.source_object_class;
  END IF;
  IF p_claim_history_rec.source_object_type_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_type_id       := NULL;
  END IF;
  IF p_claim_history_rec.source_object_type_id  IS NULL THEN
     x_complete_rec.source_object_type_id       := l_claim_history_rec.source_object_type_id;
  END IF;
  IF p_claim_history_rec.source_object_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.source_object_number       := NULL;
  END IF;
  IF p_claim_history_rec.source_object_number  IS NULL THEN
     x_complete_rec.source_object_number       := l_claim_history_rec.source_object_number;
  END IF;
  IF p_claim_history_rec.cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_account_id       := NULL;
  END IF;
  IF p_claim_history_rec.cust_account_id  IS NULL THEN
     x_complete_rec.cust_account_id       := l_claim_history_rec.cust_account_id;
  END IF;
  IF p_claim_history_rec.cust_billto_acct_site_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_billto_acct_site_id       := NULL;
  END IF;
  IF p_claim_history_rec.cust_billto_acct_site_id  IS NULL THEN
     x_complete_rec.cust_billto_acct_site_id       := l_claim_history_rec.cust_billto_acct_site_id;
  END IF;
  IF p_claim_history_rec.cust_shipto_acct_site_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.cust_shipto_acct_site_id := NULL;
  END IF;
  IF p_claim_history_rec.cust_shipto_acct_site_id  IS NULL THEN
     x_complete_rec.cust_shipto_acct_site_id := l_claim_history_rec.cust_shipto_acct_site_id;
  END IF;
  IF p_claim_history_rec.location_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.location_id       := NULL;
  END IF;
  IF p_claim_history_rec.location_id  IS NULL THEN
     x_complete_rec.location_id       := l_claim_history_rec.location_id;
  END IF;
  IF p_claim_history_rec.pay_related_account_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.pay_related_account_flag := NULL;
  END IF;
  IF p_claim_history_rec.pay_related_account_flag  IS NULL THEN
     x_complete_rec.pay_related_account_flag := l_claim_history_rec.pay_related_account_flag;
  END IF;
  IF p_claim_history_rec.related_cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.related_cust_account_id := NULL;
  END IF;
  IF p_claim_history_rec.related_cust_account_id  IS NULL THEN
     x_complete_rec.related_cust_account_id := l_claim_history_rec.related_cust_account_id;
  END IF;
  IF p_claim_history_rec.related_site_use_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.related_site_use_id := NULL;
  END IF;
  IF p_claim_history_rec.related_site_use_id  IS NULL THEN
     x_complete_rec.related_site_use_id := l_claim_history_rec.related_site_use_id;
  END IF;
  IF p_claim_history_rec.relationship_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.relationship_type := NULL;
  END IF;
  IF p_claim_history_rec.relationship_type IS NULL THEN
     x_complete_rec.relationship_type := l_claim_history_rec.relationship_type;
  END IF;
  IF p_claim_history_rec.vendor_id   = FND_API.G_MISS_NUM  THEN
     x_complete_rec.vendor_id := NULL;
  END IF;
  IF p_claim_history_rec.vendor_id   IS NULL THEN
     x_complete_rec.vendor_id := l_claim_history_rec.vendor_id;
  END IF;
  IF p_claim_history_rec.vendor_site_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.vendor_site_id := NULL;
  END IF;
  IF p_claim_history_rec.vendor_site_id IS NULL THEN
     x_complete_rec.vendor_site_id := l_claim_history_rec.vendor_site_id;
  END IF;
  IF p_claim_history_rec.reason_type  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.reason_type       := NULL;
  END IF;
  IF p_claim_history_rec.reason_type  IS NULL THEN
     x_complete_rec.reason_type       := l_claim_history_rec.reason_type;
  END IF;
  IF p_claim_history_rec.reason_code_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.reason_code_id       := NULL;
  END IF;
  IF p_claim_history_rec.reason_code_id  IS NULL THEN
     x_complete_rec.reason_code_id       := l_claim_history_rec.reason_code_id;
  END IF;
  IF p_claim_history_rec.task_template_group_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_template_group_id       := NULL;
  END IF;
  IF p_claim_history_rec.task_template_group_id  IS NULL THEN
     x_complete_rec.task_template_group_id       := l_claim_history_rec.task_template_group_id;
  END IF;
  IF p_claim_history_rec.status_code  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.status_code       := NULL;
  END IF;
  IF p_claim_history_rec.status_code  IS NULL THEN
     x_complete_rec.status_code       := l_claim_history_rec.status_code;
  END IF;
  IF p_claim_history_rec.user_status_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.user_status_id       := NULL;
  END IF;
  IF p_claim_history_rec.user_status_id  IS NULL THEN
     x_complete_rec.user_status_id       := l_claim_history_rec.user_status_id;
  END IF;
  IF p_claim_history_rec.sales_rep_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.sales_rep_id       := NULL;
  END IF;
  IF p_claim_history_rec.sales_rep_id  IS NULL THEN
     x_complete_rec.sales_rep_id       := l_claim_history_rec.sales_rep_id;
  END IF;
  IF p_claim_history_rec.collector_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.collector_id       := NULL;
  END IF;
  IF p_claim_history_rec.collector_id  IS NULL THEN
     x_complete_rec.collector_id       := l_claim_history_rec.collector_id;
  END IF;
  IF p_claim_history_rec.contact_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.contact_id       := NULL;
  END IF;
  IF p_claim_history_rec.contact_id  IS NULL THEN
     x_complete_rec.contact_id       := l_claim_history_rec.contact_id;
  END IF;
  IF p_claim_history_rec.broker_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.broker_id       := NULL;
  END IF;
  IF p_claim_history_rec.broker_id  IS NULL THEN
     x_complete_rec.broker_id       := l_claim_history_rec.broker_id;
  END IF;
  IF p_claim_history_rec.territory_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.territory_id       := NULL;
  END IF;
  IF p_claim_history_rec.territory_id  IS NULL THEN
     x_complete_rec.territory_id       := l_claim_history_rec.territory_id;
  END IF;
  IF p_claim_history_rec.customer_ref_date         = FND_API.G_MISS_DATE  THEN
     x_complete_rec.customer_ref_date       := NULL;
  END IF;
  IF p_claim_history_rec.customer_ref_date         IS NULL THEN
     x_complete_rec.customer_ref_date       := l_claim_history_rec.customer_ref_date;
  END IF;
  IF p_claim_history_rec.customer_ref_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.customer_ref_number       := NULL;
  END IF;
  IF p_claim_history_rec.customer_ref_number  IS NULL THEN
     x_complete_rec.customer_ref_number       := l_claim_history_rec.customer_ref_number;
  END IF;
  IF p_claim_history_rec.receipt_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.receipt_id       := NULL;
  END IF;
  IF p_claim_history_rec.receipt_id  IS NULL THEN
     x_complete_rec.receipt_id       := l_claim_history_rec.receipt_id;
  END IF;
  IF p_claim_history_rec.receipt_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.receipt_number       := NULL;
  END IF;
  IF p_claim_history_rec.receipt_number  IS NULL THEN
     x_complete_rec.receipt_number       := l_claim_history_rec.receipt_number;
  END IF;
  IF p_claim_history_rec.doc_sequence_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.doc_sequence_id       := NULL;
  END IF;
  IF p_claim_history_rec.doc_sequence_id  IS NULL THEN
     x_complete_rec.doc_sequence_id       := l_claim_history_rec.doc_sequence_id;
  END IF;
  IF p_claim_history_rec.doc_sequence_value  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.doc_sequence_value       := NULL;
  END IF;
  IF p_claim_history_rec.doc_sequence_value  IS NULL THEN
     x_complete_rec.doc_sequence_value       := l_claim_history_rec.doc_sequence_value;
  END IF;
  IF p_claim_history_rec.gl_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.gl_date       := NULL;
  END IF;
  IF p_claim_history_rec.gl_date  IS NULL THEN
     x_complete_rec.gl_date       := l_claim_history_rec.gl_date;
  END IF;
  IF p_claim_history_rec.payment_method  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_method       := NULL;
  END IF;
  IF p_claim_history_rec.payment_method  IS NULL THEN
     x_complete_rec.payment_method       := l_claim_history_rec.payment_method;
  END IF;
  IF p_claim_history_rec.voucher_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.voucher_id       := NULL;
  END IF;
  IF p_claim_history_rec.voucher_id  IS NULL THEN
     x_complete_rec.voucher_id       := l_claim_history_rec.voucher_id;
  END IF;
  IF p_claim_history_rec.voucher_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.voucher_number       := NULL;
  END IF;
  IF p_claim_history_rec.voucher_number  IS NULL THEN
     x_complete_rec.voucher_number       := l_claim_history_rec.voucher_number;
  END IF;
  IF p_claim_history_rec.payment_reference_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.payment_reference_id       := NULL;
  END IF;
  IF p_claim_history_rec.payment_reference_id  IS NULL THEN
     x_complete_rec.payment_reference_id       := l_claim_history_rec.payment_reference_id;
  END IF;
  IF p_claim_history_rec.payment_reference_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_reference_number := NULL;
  END IF;
  IF p_claim_history_rec.payment_reference_number  IS NULL THEN
     x_complete_rec.payment_reference_number := l_claim_history_rec.payment_reference_number;
  END IF;
  IF p_claim_history_rec.payment_reference_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.payment_reference_date := NULL;
  END IF;
  IF p_claim_history_rec.payment_reference_date  IS NULL THEN
     x_complete_rec.payment_reference_date := l_claim_history_rec.payment_reference_date;
  END IF;
  IF p_claim_history_rec.payment_status  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_status := NULL;
  END IF;
  IF p_claim_history_rec.payment_status  IS NULL THEN
     x_complete_rec.payment_status := l_claim_history_rec.payment_status;
  END IF;
  IF p_claim_history_rec.approved_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.approved_flag := NULL;
  END IF;
  IF p_claim_history_rec.approved_flag  IS NULL THEN
     x_complete_rec.approved_flag := l_claim_history_rec.approved_flag;
  END IF;
  IF p_claim_history_rec.approved_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.approved_date := NULL;
  END IF;
  IF p_claim_history_rec.approved_date  IS NULL THEN
     x_complete_rec.approved_date := l_claim_history_rec.approved_date;
  END IF;
  IF p_claim_history_rec.approved_by  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.approved_by := NULL;
  END IF;
  IF p_claim_history_rec.approved_by  IS NULL THEN
     x_complete_rec.approved_by := l_claim_history_rec.approved_by;
  END IF;
  IF p_claim_history_rec.settled_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.settled_date := NULL;
  END IF;
  IF p_claim_history_rec.settled_date  IS NULL THEN
     x_complete_rec.settled_date := l_claim_history_rec.settled_date;
  END IF;
  IF p_claim_history_rec.settled_by  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.settled_by := NULL;
  END IF;
  IF p_claim_history_rec.settled_by  IS NULL THEN
     x_complete_rec.settled_by := l_claim_history_rec.settled_by;
  END IF;
  IF p_claim_history_rec.effective_date  = FND_API.G_MISS_DATE  THEN
     x_complete_rec.effective_date := NULL;
  END IF;
  IF p_claim_history_rec.effective_date  IS NULL THEN
     x_complete_rec.effective_date := l_claim_history_rec.effective_date;
  END IF;
  IF p_claim_history_rec.custom_setup_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.custom_setup_id := NULL;
  END IF;
  IF p_claim_history_rec.custom_setup_id IS NULL THEN
     x_complete_rec.custom_setup_id := l_claim_history_rec.custom_setup_id;
  END IF;
  IF p_claim_history_rec.task_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_id := NULL;
  END IF;
  IF p_claim_history_rec.task_id  IS NULL THEN
     x_complete_rec.task_id := l_claim_history_rec.task_id;
  END IF;
  IF p_claim_history_rec.country_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.country_id := NULL;
  END IF;
  IF p_claim_history_rec.country_id IS NULL THEN
     x_complete_rec.country_id := l_claim_history_rec.country_id;
  END IF;
  IF p_claim_history_rec.order_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.order_type_id := NULL;
  END IF;
  IF p_claim_history_rec.order_type_id IS NULL THEN
     x_complete_rec.order_type_id := l_claim_history_rec.order_type_id;
  END IF;
  IF p_claim_history_rec.comments  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.comments := NULL;
  END IF;
  IF p_claim_history_rec.comments  IS NULL THEN
     x_complete_rec.comments := l_claim_history_rec.comments;
  END IF;
  IF p_claim_history_rec.task_source_object_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.task_source_object_id := NULL;
  END IF;
  IF p_claim_history_rec.task_source_object_id IS NULL THEN
     x_complete_rec.task_source_object_id := l_claim_history_rec.task_source_object_id;
  END IF;
  IF p_claim_history_rec.task_source_object_type_code  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.task_source_object_type_code := NULL;
  END IF;
  IF p_claim_history_rec.task_source_object_type_code  IS NULL THEN
     x_complete_rec.task_source_object_type_code := l_claim_history_rec.task_source_object_type_code;
  END IF;
  IF p_claim_history_rec.attribute_category  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute_category := NULL;
  END IF;
  IF p_claim_history_rec.attribute_category  IS NULL THEN
     x_complete_rec.attribute_category := l_claim_history_rec.attribute_category;
  END IF;
  IF p_claim_history_rec.attribute1  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute1 := NULL;
  END IF;
  IF p_claim_history_rec.attribute1  IS NULL THEN
     x_complete_rec.attribute1 := l_claim_history_rec.attribute1;
  END IF;
  IF p_claim_history_rec.attribute2  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute2 := NULL;
  END IF;
  IF p_claim_history_rec.attribute2  IS NULL THEN
     x_complete_rec.attribute2 := l_claim_history_rec.attribute2;
  END IF;
  IF p_claim_history_rec.attribute3  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute3 := NULL;
  END IF;
  IF p_claim_history_rec.attribute3  IS NULL THEN
     x_complete_rec.attribute3 := l_claim_history_rec.attribute3;
  END IF;
  IF p_claim_history_rec.attribute4  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute4 := NULL;
  END IF;
  IF p_claim_history_rec.attribute4  IS NULL THEN
     x_complete_rec.attribute4 := l_claim_history_rec.attribute4;
  END IF;
  IF p_claim_history_rec.attribute5  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute5 := NULL;
  END IF;
  IF p_claim_history_rec.attribute5  IS NULL THEN
     x_complete_rec.attribute5 := l_claim_history_rec.attribute5;
  END IF;
  IF p_claim_history_rec.attribute6  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute6 := NULL;
  END IF;
  IF p_claim_history_rec.attribute6  IS NULL THEN
     x_complete_rec.attribute6 := l_claim_history_rec.attribute6;
  END IF;
  IF p_claim_history_rec.attribute7  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute7 := NULL;
  END IF;
  IF p_claim_history_rec.attribute7  IS NULL THEN
     x_complete_rec.attribute7 := l_claim_history_rec.attribute7;
  END IF;
  IF p_claim_history_rec.attribute8  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute8 := NULL;
  END IF;
  IF p_claim_history_rec.attribute8  IS NULL THEN
     x_complete_rec.attribute8 := l_claim_history_rec.attribute8;
  END IF;
  IF p_claim_history_rec.attribute9  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute9 := NULL;
  END IF;
  IF p_claim_history_rec.attribute9  IS NULL THEN
     x_complete_rec.attribute9 := l_claim_history_rec.attribute9;
  END IF;
  IF p_claim_history_rec.attribute10  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute10 := NULL;
  END IF;
  IF p_claim_history_rec.attribute10  IS NULL THEN
     x_complete_rec.attribute10 := l_claim_history_rec.attribute10;
  END IF;
  IF p_claim_history_rec.attribute11  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute11 := NULL;
  END IF;
  IF p_claim_history_rec.attribute11  IS NULL THEN
     x_complete_rec.attribute11 := l_claim_history_rec.attribute11;
  END IF;
  IF p_claim_history_rec.attribute12  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute12 := NULL;
  END IF;
  IF p_claim_history_rec.attribute12  IS NULL THEN
     x_complete_rec.attribute12 := l_claim_history_rec.attribute12;
  END IF;
  IF p_claim_history_rec.attribute13  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute13 := NULL;
  END IF;
  IF p_claim_history_rec.attribute13  IS NULL THEN
     x_complete_rec.attribute13 := l_claim_history_rec.attribute13;
  END IF;
  IF p_claim_history_rec.attribute14  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute14 := NULL;
  END IF;
  IF p_claim_history_rec.attribute14  IS NULL THEN
     x_complete_rec.attribute14 := l_claim_history_rec.attribute14;
  END IF;
  IF p_claim_history_rec.attribute15  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.attribute15 := NULL;
  END IF;
  IF p_claim_history_rec.attribute15  IS NULL THEN
     x_complete_rec.attribute15 := l_claim_history_rec.attribute15;
  END IF;
  IF p_claim_history_rec.deduction_attribute_category  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute_category := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute_category  IS NULL THEN
     x_complete_rec.deduction_attribute_category := l_claim_history_rec.deduction_attribute_category;
  END IF;
  IF p_claim_history_rec.deduction_attribute1  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute1 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute1  IS NULL THEN
     x_complete_rec.deduction_attribute1 := l_claim_history_rec.deduction_attribute1;
  END IF;
  IF p_claim_history_rec.deduction_attribute2  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute2 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute2  IS NULL THEN
     x_complete_rec.deduction_attribute2 := l_claim_history_rec.deduction_attribute2;
  END IF;
  IF p_claim_history_rec.deduction_attribute3  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute3 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute3  IS NULL THEN
     x_complete_rec.deduction_attribute3 := l_claim_history_rec.deduction_attribute3;
  END IF;
  IF p_claim_history_rec.deduction_attribute4  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute4 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute4  IS NULL THEN
     x_complete_rec.deduction_attribute4 := l_claim_history_rec.deduction_attribute4;
  END IF;
  IF p_claim_history_rec.deduction_attribute5  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute5 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute5  IS NULL THEN
     x_complete_rec.deduction_attribute5 := l_claim_history_rec.deduction_attribute5;
  END IF;
  IF p_claim_history_rec.attribute6  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute6 := NULL;
  END IF;
  IF p_claim_history_rec.attribute6  IS NULL THEN
     x_complete_rec.deduction_attribute6 := l_claim_history_rec.deduction_attribute6;
  END IF;
  IF p_claim_history_rec.deduction_attribute7  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute7 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute7  IS NULL THEN
     x_complete_rec.deduction_attribute7 := l_claim_history_rec.deduction_attribute7;
  END IF;
  IF p_claim_history_rec.deduction_attribute8  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute8 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute8  IS NULL THEN
     x_complete_rec.deduction_attribute8 := l_claim_history_rec.deduction_attribute8;
  END IF;
  IF p_claim_history_rec.deduction_attribute9  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute9 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute9  IS NULL THEN
     x_complete_rec.deduction_attribute9 := l_claim_history_rec.deduction_attribute9;
  END IF;
  IF p_claim_history_rec.deduction_attribute10  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute10 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute10  IS NULL THEN
     x_complete_rec.deduction_attribute10 := l_claim_history_rec.deduction_attribute10;
  END IF;
  IF p_claim_history_rec.deduction_attribute11  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute11 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute11  IS NULL THEN
     x_complete_rec.deduction_attribute11 := l_claim_history_rec.deduction_attribute11;
  END IF;
  IF p_claim_history_rec.deduction_attribute12  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute12 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute12  IS NULL THEN
     x_complete_rec.deduction_attribute12 := l_claim_history_rec.deduction_attribute12;
  END IF;
  IF p_claim_history_rec.deduction_attribute13  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute13 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute13  IS NULL THEN
     x_complete_rec.deduction_attribute13 := l_claim_history_rec.deduction_attribute13;
  END IF;
  IF p_claim_history_rec.deduction_attribute14  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute14 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute14  IS NULL THEN
     x_complete_rec.deduction_attribute14 := l_claim_history_rec.deduction_attribute14;
  END IF;
  IF p_claim_history_rec.deduction_attribute15  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.deduction_attribute15 := NULL;
  END IF;
  IF p_claim_history_rec.deduction_attribute15  IS NULL THEN
     x_complete_rec.deduction_attribute15 := l_claim_history_rec.deduction_attribute15;
  END IF;
  IF p_claim_history_rec.org_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.org_id := NULL;
  END IF;
  IF p_claim_history_rec.org_id  IS NULL THEN
     x_complete_rec.org_id := l_claim_history_rec.org_id;
  END IF;

  IF p_claim_history_rec.write_off_flag  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.write_off_flag := NULL;
  END IF;
  IF p_claim_history_rec.write_off_flag  IS NULL THEN
     x_complete_rec.write_off_flag := l_claim_history_rec.write_off_flag;
  END IF;

  IF p_claim_history_rec.write_off_threshold_amount  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.write_off_threshold_amount := NULL;
  END IF;
  IF p_claim_history_rec.write_off_threshold_amount  IS NULL THEN
     x_complete_rec.write_off_threshold_amount := l_claim_history_rec.write_off_threshold_amount;
  END IF;

  IF p_claim_history_rec.under_write_off_threshold  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.under_write_off_threshold := NULL;
  END IF;
  IF p_claim_history_rec.under_write_off_threshold  IS NULL THEN
     x_complete_rec.under_write_off_threshold := l_claim_history_rec.under_write_off_threshold;
  END IF;

  IF p_claim_history_rec.customer_reason  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.customer_reason := NULL;
  END IF;
  IF p_claim_history_rec.customer_reason  IS NULL THEN
     x_complete_rec.customer_reason := l_claim_history_rec.customer_reason;
  END IF;

  IF p_claim_history_rec.ship_to_cust_account_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.ship_to_cust_account_id       := NULL;
  END IF;
  IF p_claim_history_rec.ship_to_cust_account_id  IS NULL THEN
     x_complete_rec.ship_to_cust_account_id       := l_claim_history_rec.ship_to_cust_account_id;
  END IF;

  -- Start Bug:2781186
  IF p_claim_history_rec.amount_applied  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount_applied := NULL;
  END IF;
  IF p_claim_history_rec.amount_applied  IS NULL THEN
     x_complete_rec.amount_applied := l_claim_history_rec.amount_applied;
  END IF;

  IF p_claim_history_rec.applied_receipt_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.applied_receipt_id := NULL;
  END IF;
  IF p_claim_history_rec.applied_receipt_id  IS NULL THEN
     x_complete_rec.applied_receipt_id := l_claim_history_rec.applied_receipt_id;
  END IF;

  IF p_claim_history_rec.applied_receipt_number  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.applied_receipt_number := NULL;
  END IF;
  IF p_claim_history_rec.applied_receipt_number  IS NULL THEN
     x_complete_rec.applied_receipt_number := l_claim_history_rec.applied_receipt_number;
  END IF;

  IF p_claim_history_rec.wo_rec_trx_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.wo_rec_trx_id := NULL;
  END IF;
  IF p_claim_history_rec.wo_rec_trx_id  IS NULL THEN
     x_complete_rec.wo_rec_trx_id := l_claim_history_rec.wo_rec_trx_id;
  END IF;
  -- End Bug:2781186

  IF p_claim_history_rec.group_claim_id  = FND_API.G_MISS_NUM  THEN
     x_complete_rec.group_claim_id := NULL;
  END IF;
  IF p_claim_history_rec.group_claim_id  IS NULL  THEN
     x_complete_rec.group_claim_id := l_claim_history_rec.group_claim_id;
  END IF;
  IF p_claim_history_rec.appr_wf_item_key  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.appr_wf_item_key := NULL;
  END IF;
  IF p_claim_history_rec.appr_wf_item_key  IS NULL  THEN
     x_complete_rec.appr_wf_item_key := l_claim_history_rec.appr_wf_item_key;
  END IF;
  IF p_claim_history_rec.cstl_wf_item_key  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.cstl_wf_item_key := NULL;
  END IF;
  IF p_claim_history_rec.cstl_wf_item_key  IS NULL  THEN
     x_complete_rec.cstl_wf_item_key := l_claim_history_rec.cstl_wf_item_key;
  END IF;
  IF p_claim_history_rec.batch_type  = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.batch_type := NULL;
  END IF;
  IF p_claim_history_rec.batch_type  IS NULL  THEN
     x_complete_rec.batch_type := l_claim_history_rec.batch_type;
  END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
      FND_MSG_PUB.Add;
   END IF;
 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_HIST_COMPLETE_ERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Complete_Claim_History_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claims_History
--
-- PURPOSE
--    This procedure inserts a record in ozf_claims_history_all table by calling
--    the table handler package.
--
-- PARAMETERS
--    p_CLAIMS_HISTORY_Rec: The record that you want to insert.
--    x_CLAIM_HISTORY_ID:   Primary key of the new record in the table.
--
-- NOTES:
--
---------------------------------------------------------------------

PROCEDURE Create_Claims_History(
    p_Api_Version_Number         IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    p_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_Return_Status              OUT NOCOPY  VARCHAR2,
    x_Msg_Count                  OUT NOCOPY  NUMBER,
    x_Msg_Data                   OUT NOCOPY  VARCHAR2,

    p_CLAIMS_HISTORY_Rec         IN   CLAIMS_HISTORY_Rec_Type  := G_MISS_CLAIMS_HISTORY_REC,
    x_CLAIM_HISTORY_ID           OUT NOCOPY  NUMBER
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_claims_history';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full      VARCHAR2(1);
l_object_version_number   NUMBER := 1;
l_org_id                  NUMBER;
l_CLAIM_HISTORY_ID        NUMBER;

l_return_status           varchar2(30);
l_msg_data                varchar2(2000);
l_msg_count               number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CLAIMS_HISTORY_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
         FND_MSG_PUB.Add;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF (FND_GLOBAL.User_Id IS NULL) THEN
          IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
             FND_MESSAGE.Set_Name('OZF', 'USER_PROFILE_MISSING');
             FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

	  -- Invoke validation procedures
          Validate_claims_history(
             p_api_version_number  => 1.0,
             p_init_msg_list       => FND_API.G_FALSE,
             p_validation_level    => p_validation_level,
             P_CLAIMS_HISTORY_Rec  => p_CLAIMS_HISTORY_Rec,
             x_return_status       => l_return_status,
             x_msg_count           => l_msg_count,
             x_msg_data            => l_msg_data
	  );
      END IF;
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- Check whether claim_history_id exists
      IF (p_claims_history_rec.claim_history_id is NOT NULL AND
          p_claims_history_rec.claim_history_id <> FND_API.G_MISS_NUM) THEN
         l_claim_history_id := p_claims_history_rec.claim_history_id;
      END IF;

      l_org_id :=   p_claims_history_rec.org_id;

      -- Invoke table handler(OZF_claims_history_PKG.Insert_Row)
      BEGIN
        OZF_claims_history_PKG.Insert_Row(
          px_CLAIM_HISTORY_ID       => l_claim_history_id,
          px_OBJECT_VERSION_NUMBER  => l_object_version_number,
          p_LAST_UPDATE_DATE        => SYSDATE,
          p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
          p_CREATION_DATE           => SYSDATE,
          p_CREATED_BY              => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID              => p_CLAIMS_HISTORY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_CLAIMS_HISTORY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_UPDATE_DATE     => p_CLAIMS_HISTORY_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_ID              => p_CLAIMS_HISTORY_rec.PROGRAM_ID,
          p_CREATED_FROM            => p_CLAIMS_HISTORY_rec.CREATED_FROM,
          p_BATCH_ID                => p_CLAIMS_HISTORY_rec.BATCH_ID,
          p_CLAIM_ID                => p_CLAIMS_HISTORY_rec.CLAIM_ID,
          p_CLAIM_NUMBER            => p_CLAIMS_HISTORY_rec.CLAIM_NUMBER,
          p_CLAIM_TYPE_ID           => p_CLAIMS_HISTORY_rec.CLAIM_TYPE_ID,
          p_CLAIM_CLASS             => p_CLAIMS_HISTORY_REC.CLAIM_CLASS,
	       p_CLAIM_DATE              => p_CLAIMS_HISTORY_rec.CLAIM_DATE,
          p_DUE_DATE                => p_CLAIMS_HISTORY_rec.DUE_DATE,
          p_OWNER_ID                => p_CLAIMS_HISTORY_rec.OWNER_ID,
          p_HISTORY_EVENT           => p_CLAIMS_HISTORY_rec.HISTORY_EVENT,
          p_HISTORY_EVENT_DATE      => p_CLAIMS_HISTORY_rec.HISTORY_EVENT_DATE,
          p_HISTORY_EVENT_DESCRIPTION => p_CLAIMS_HISTORY_rec.HISTORY_EVENT_DESCRIPTION,
          p_SPLIT_FROM_CLAIM_ID     => p_CLAIMS_HISTORY_rec.SPLIT_FROM_CLAIM_ID,
          p_duplicate_claim_id  => p_claims_history_rec.duplicate_claim_id,
	       p_SPLIT_DATE              => p_CLAIMS_HISTORY_rec.SPLIT_DATE,
          p_ROOT_CLAIM_ID           => p_claims_history_rec.ROOT_CLAIM_ID,
          p_AMOUNT                  => p_CLAIMS_HISTORY_rec.AMOUNT,
          p_AMOUNT_ADJUSTED         => p_CLAIMS_HISTORY_rec.AMOUNT_ADJUSTED,
          p_AMOUNT_REMAINING        => p_CLAIMS_HISTORY_rec.AMOUNT_REMAINING,
          p_AMOUNT_SETTLED          => p_CLAIMS_HISTORY_rec.AMOUNT_SETTLED,
          p_ACCTD_AMOUNT            => p_CLAIMS_HISTORY_rec.ACCTD_AMOUNT,
	       p_acctd_amount_remaining  => p_claims_history_rec.acctd_amount_remaining,
          p_acctd_AMOUNT_ADJUSTED   => p_CLAIMS_HISTORY_rec.acctd_AMOUNT_ADJUSTED,
          p_acctd_AMOUNT_SETTLED    => p_CLAIMS_HISTORY_rec.acctd_AMOUNT_SETTLED,
          p_tax_amount  => p_claims_history_rec.tax_amount,
          p_tax_code  => p_claims_history_rec.tax_code,
          p_tax_calculation_flag  => p_claims_history_rec.tax_calculation_flag,
          p_CURRENCY_CODE           => p_CLAIMS_HISTORY_rec.CURRENCY_CODE,
          p_EXCHANGE_RATE_TYPE      => p_CLAIMS_HISTORY_rec.EXCHANGE_RATE_TYPE,
          p_EXCHANGE_RATE_DATE      => p_CLAIMS_HISTORY_rec.EXCHANGE_RATE_DATE,
          p_EXCHANGE_RATE           => p_CLAIMS_HISTORY_rec.EXCHANGE_RATE,
          p_SET_OF_BOOKS_ID         => p_CLAIMS_HISTORY_rec.SET_OF_BOOKS_ID,
          p_ORIGINAL_CLAIM_DATE     => p_CLAIMS_HISTORY_rec.ORIGINAL_CLAIM_DATE,
          p_SOURCE_OBJECT_ID        => p_CLAIMS_HISTORY_rec.SOURCE_OBJECT_ID,
          p_SOURCE_OBJECT_CLASS     => p_CLAIMS_HISTORY_rec.SOURCE_OBJECT_CLASS,
          p_SOURCE_OBJECT_TYPE_ID   => p_CLAIMS_HISTORY_rec.SOURCE_OBJECT_TYPE_ID,
          p_SOURCE_OBJECT_NUMBER    => p_CLAIMS_HISTORY_rec.SOURCE_OBJECT_NUMBER,
          p_CUST_ACCOUNT_ID         => p_CLAIMS_HISTORY_rec.CUST_ACCOUNT_ID,
          p_CUST_BILLTO_ACCT_SITE_ID=> p_CLAIMS_HISTORY_rec.CUST_BILLTO_ACCT_SITE_ID,
          p_cust_shipto_acct_site_id  => p_claims_history_rec.cust_shipto_acct_site_id,
          p_LOCATION_ID              => p_CLAIMS_HISTORY_rec.LOCATION_ID,
          p_PAY_RELATED_ACCOUNT_FLAG => p_claims_history_rec.PAY_RELATED_ACCOUNT_FLAG,
          p_RELATED_CUST_ACCOUNT_ID  => p_claims_history_rec.RELATED_CUST_ACCOUNT_ID,
          p_RELATED_SITE_USE_ID      => p_claims_history_rec.RELATED_SITE_USE_ID,
          p_RELATIONSHIP_TYPE        => p_claims_history_rec.RELATIONSHIP_TYPE,
          p_VENDOR_ID                => p_claims_history_rec.VENDOR_ID,
          p_VENDOR_SITE_ID           => p_claims_history_rec.VENDOR_SITE_ID,
	       p_REASON_TYPE             => p_CLAIMS_HISTORY_rec.REASON_TYPE,
          p_REASON_CODE_ID          => p_CLAIMS_HISTORY_rec.REASON_CODE_ID,
          p_TASK_TEMPLATE_GROUP_ID  => p_claims_history_rec.TASK_TEMPLATE_GROUP_ID,
          p_STATUS_CODE             => p_CLAIMS_HISTORY_rec.STATUS_CODE,
          p_USER_STATUS_ID          => p_CLAIMS_HISTORY_rec.USER_STATUS_ID,
          p_SALES_REP_ID            => p_CLAIMS_HISTORY_rec.SALES_REP_ID,
          p_COLLECTOR_ID            => p_CLAIMS_HISTORY_rec.COLLECTOR_ID,
          p_CONTACT_ID              => p_CLAIMS_HISTORY_rec.CONTACT_ID,
          p_BROKER_ID               => p_CLAIMS_HISTORY_rec.BROKER_ID,
          p_TERRITORY_ID            => p_CLAIMS_HISTORY_rec.TERRITORY_ID,
          p_CUSTOMER_REF_DATE       => p_CLAIMS_HISTORY_rec.CUSTOMER_REF_DATE,
          p_CUSTOMER_REF_NUMBER     => p_CLAIMS_HISTORY_rec.CUSTOMER_REF_NUMBER,
          p_ASSIGNED_TO             => p_CLAIMS_HISTORY_rec.ASSIGNED_TO,
          p_RECEIPT_ID              => p_CLAIMS_HISTORY_rec.RECEIPT_ID,
          p_RECEIPT_NUMBER          => p_CLAIMS_HISTORY_rec.RECEIPT_NUMBER,
          p_DOC_SEQUENCE_ID         => p_CLAIMS_HISTORY_rec.DOC_SEQUENCE_ID,
          p_DOC_SEQUENCE_VALUE      => p_CLAIMS_HISTORY_rec.DOC_SEQUENCE_VALUE,
          p_GL_DATE                 => p_CLAIMS_HISTORY_rec.GL_DATE,
          p_PAYMENT_METHOD          => p_CLAIMS_HISTORY_rec.PAYMENT_METHOD,
          p_VOUCHER_ID              => p_CLAIMS_HISTORY_rec.VOUCHER_ID,
          p_VOUCHER_NUMBER          => p_CLAIMS_HISTORY_rec.VOUCHER_NUMBER,
          p_PAYMENT_REFERENCE_ID    => p_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_ID,
          p_PAYMENT_REFERENCE_NUMBER => p_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_NUMBER,
          p_PAYMENT_REFERENCE_DATE  => p_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_DATE,
          p_PAYMENT_STATUS          => p_CLAIMS_HISTORY_rec.PAYMENT_STATUS,
          p_APPROVED_FLAG           => p_CLAIMS_HISTORY_rec.APPROVED_FLAG,
          p_APPROVED_DATE           => p_CLAIMS_HISTORY_rec.APPROVED_DATE,
          p_APPROVED_BY             => p_CLAIMS_HISTORY_rec.APPROVED_BY,
          p_SETTLED_DATE            => p_CLAIMS_HISTORY_rec.SETTLED_DATE,
          p_SETTLED_BY              => p_CLAIMS_HISTORY_rec.SETTLED_BY,
          p_effective_date  => p_claims_history_rec.effective_date,
          p_CUSTOM_SETUP_ID         => p_claims_history_rec.CUSTOM_SETUP_ID,
          p_TASK_ID                 => p_claims_history_rec.TASK_ID,
          p_COUNTRY_ID              => p_claims_history_rec.COUNTRY_ID,
	       p_ORDER_TYPE_ID              => p_claims_history_rec.ORDER_TYPE_ID,
          p_COMMENTS                => p_CLAIMS_HISTORY_rec.COMMENTS,
          p_LETTER_ID               => p_CLAIMS_HISTORY_rec.LETTER_ID,
          p_LETTER_DATE             => p_CLAIMS_HISTORY_rec.LETTER_DATE,
          p_TASK_SOURCE_OBJECT_ID   => p_CLAIMS_HISTORY_rec.TASK_SOURCE_OBJECT_ID,
          p_TASK_SOURCE_OBJECT_TYPE_CODE => p_CLAIMS_HISTORY_rec.TASK_SOURCE_OBJECT_TYPE_CODE,
          p_ATTRIBUTE_CATEGORY      => p_CLAIMS_HISTORY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1              => p_CLAIMS_HISTORY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2              => p_CLAIMS_HISTORY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3              => p_CLAIMS_HISTORY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4              => p_CLAIMS_HISTORY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5              => p_CLAIMS_HISTORY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6              => p_CLAIMS_HISTORY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7              => p_CLAIMS_HISTORY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8              => p_CLAIMS_HISTORY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9              => p_CLAIMS_HISTORY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10             => p_CLAIMS_HISTORY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11             => p_CLAIMS_HISTORY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12             => p_CLAIMS_HISTORY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13             => p_CLAIMS_HISTORY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14             => p_CLAIMS_HISTORY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15             => p_CLAIMS_HISTORY_rec.ATTRIBUTE15,
          p_DEDUCTION_ATTRIBUTE_CATEGORY  => p_claims_history_rec.DEDUCTION_ATTRIBUTE_CATEGORY,
          p_DEDUCTION_ATTRIBUTE1  => p_claims_history_rec.DEDUCTION_ATTRIBUTE1,
          p_DEDUCTION_ATTRIBUTE2  => p_claims_history_rec.DEDUCTION_ATTRIBUTE2,
          p_DEDUCTION_ATTRIBUTE3  => p_claims_history_rec.DEDUCTION_ATTRIBUTE3,
          p_DEDUCTION_ATTRIBUTE4  => p_claims_history_rec.DEDUCTION_ATTRIBUTE4,
          p_DEDUCTION_ATTRIBUTE5  => p_claims_history_rec.DEDUCTION_ATTRIBUTE5,
          p_DEDUCTION_ATTRIBUTE6  => p_claims_history_rec.DEDUCTION_ATTRIBUTE6,
          p_DEDUCTION_ATTRIBUTE7  => p_claims_history_rec.DEDUCTION_ATTRIBUTE7,
          p_DEDUCTION_ATTRIBUTE8  => p_claims_history_rec.DEDUCTION_ATTRIBUTE8,
          p_DEDUCTION_ATTRIBUTE9  => p_claims_history_rec.DEDUCTION_ATTRIBUTE9,
          p_DEDUCTION_ATTRIBUTE10  => p_claims_history_rec.DEDUCTION_ATTRIBUTE10,
          p_DEDUCTION_ATTRIBUTE11  => p_claims_history_rec.DEDUCTION_ATTRIBUTE11,
          p_DEDUCTION_ATTRIBUTE12  => p_claims_history_rec.DEDUCTION_ATTRIBUTE12,
          p_DEDUCTION_ATTRIBUTE13  => p_claims_history_rec.DEDUCTION_ATTRIBUTE13,
          p_DEDUCTION_ATTRIBUTE14  => p_claims_history_rec.DEDUCTION_ATTRIBUTE14,
          p_DEDUCTION_ATTRIBUTE15  => p_claims_history_rec.DEDUCTION_ATTRIBUTE15,
	       px_ORG_ID                 => l_org_id,
          p_WRITE_OFF_FLAG  => p_claims_history_rec.WRITE_OFF_FLAG,
          p_WRITE_OFF_THRESHOLD_AMOUNT  => p_claims_history_rec.WRITE_OFF_THRESHOLD_AMOUNT,
          p_UNDER_WRITE_OFF_THRESHOLD  => p_claims_history_rec.UNDER_WRITE_OFF_THRESHOLD,
          p_CUSTOMER_REASON  => p_claims_history_rec.CUSTOMER_REASON,
          p_SHIP_TO_CUST_ACCOUNT_ID         => p_CLAIMS_HISTORY_rec.SHIP_TO_CUST_ACCOUNT_ID,
          p_AMOUNT_APPLIED             => p_claims_history_rec.AMOUNT_APPLIED,              --BUG:2781186
          p_APPLIED_RECEIPT_ID         => p_claims_history_rec.APPLIED_RECEIPT_ID,          --BUG:2781186
          p_APPLIED_RECEIPT_NUMBER     => p_claims_history_rec.APPLIED_RECEIPT_NUMBER,      --BUG:2781186
          p_WO_REC_TRX_ID              => p_claims_history_rec.WO_REC_TRX_ID,
          p_GROUP_CLAIM_ID             => p_claims_history_rec.GROUP_CLAIM_ID,
          p_APPR_WF_ITEM_KEY           => p_claims_history_rec.APPR_WF_ITEM_KEY,
          p_CSTL_WF_ITEM_KEY           => p_claims_history_rec.CSTL_WF_ITEM_KEY,
          p_BATCH_TYPE                 => p_claims_history_rec.BATCH_TYPE

      );
      EXCEPTION
        WHEN OTHERS THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
              FND_MSG_PUB.add;
           END IF;
           RAISE FND_API.g_exc_error;
      END;

      x_claim_history_id := l_claim_history_id;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;

      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
         FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
      OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Claims_History_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Claims_History_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO CREATE_Claims_History_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
End Create_Claims_History;
---------------------------------------------------------------------
-- PROCEDURE
--    change_description
--
-- PURPOSE
--    This procedure creates a description of an event.
--
-- PARAMETERS
--    px_description:  description that has been generated.
--    p_column_name:  column name that you want to add to the event description
--
-- NOTES:
--
---------------------------------------------------------------------
PROCEDURE change_description (px_description   IN OUT NOCOPY VARCHAR2,
                              p_column_desc   IN  VARCHAR2)
IS
l_description varchar2(2000);
BEGIN
   IF px_description is null THEN
      l_description := p_column_desc;
   ELSE
      l_description := px_description || ',' || p_column_desc;
   END IF;
   px_description := l_description;

End change_description;
---------------------------------------------------------------------
-- PROCEDURE
--    Check_Create_History
--
-- PURPOSE
--    This procedure check whether we should create a history snapshot
--    of a claim.
--
-- PARAMETERS
--    p_claim   :  claim record.
--    p_event   :  Indicator to show whether the current caller is from
--                 a claim update, which is "UPDATE" OR
--                 a claim line update which is "LINE"
--    x_history_event : This is the event that will be recorded in the
--                      database.
--    x_history_event_description : Event description based on what happend.
--    x_needed_to_create : Whether we need to create a snapshot or not.
--
-- NOTES:
--
---------------------------------------------------------------------
/*
PROCEDURE Check_Create_History_test(p_claim            IN  OZF_CLAIM_PVT.claim_rec_type,
                               p_event            IN  VARCHAR2,
                               x_history_event    OUT NOCOPY VARCHAR2,
                               x_history_event_description OUT NOCOPY VARCHAR2,
                               x_needed_to_create OUT NOCOPY VARCHAR2,
			       x_return_status    OUT NOCOPY VARCHAR2
)
IS
CURSOR column_names_csr
SELECT db_table_name, db_column_name, ak_attribute_code
FROM ams_column_rules
WHERE rule_type = 'HISTORY';

TYPE column_names_table_tye is table of column_names_csr%rowtype;
l_column_names_tbl column_names_table_type;

l_index number = 0;
l_count number = null;
l_select varchar2(500);
l_from  varchar2(100);
l_where varchar2(500);
l_stmt varchar2(1200);

l_count number;
BEGIN

  OPEN column_names_csr;
  LOOP
    FETCH column_names_csr INTO l_column_names_tbl(l_index);
    EXIT WHEN column_names_crs%NOTFOUND;
    l_index := l_index +1;
  END LOOP;
  CLOSE column_names_csr;

  FOR i in l..l_column_names_tbl.COUNT LOOP
  l_str := 'p_claim'.db_column_name;

    l_column_name_table(i).db_column_name
    l_stmt :=          'SELECT count(claim_id) ';
    l_stmt := l_stmt ||' from ' || l_column_names_tbl(i).db_table_name;
    l_stmt := l_stmt ||' where '|| l_column_name_table(i).db_column_name ||'= :1';
    l_stmt := l_stmt ||' AND '  || 'claim_id = '|| p_claim.claim_id;

    EXECUTE IMMEDIATE l_stmt USING p_claim.amount OUT NOCOPY l_count;


  END LOOP;

 change_description (
	        p_description => l_event_description,
                p_column_name => 'reason_type',
                x_description => l_event_description
	     );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CHK_CRT_HIST_ERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END check_create_history;
*/

---------------------------------------------------------------------
PROCEDURE Check_Create_History(p_claim            IN  OZF_CLAIM_PVT.claim_rec_type,
                               p_event            IN  VARCHAR2,
                               x_history_event    OUT NOCOPY VARCHAR2,
                               x_history_event_description OUT NOCOPY VARCHAR2,
                               x_needed_to_create OUT NOCOPY VARCHAR2,
			       x_return_status    OUT NOCOPY VARCHAR2
)
IS
l_system_status     varchar2(30);
l_claim_hist_id     number;
l_event_description varchar2(2000) := null;
l_history_event     varchar2(30)   := null;
l_return            boolean := FALSE; -- return value default to be FLASE.
                                      -- Its value will be changed to TRUE if we need to create history

l_return_status  varchar2(30);
l_msg_data       varchar2(2000);
l_msg_count      number;

--Variables to track the repetitions of the column rules.
l_payment_method_rule   boolean := false;
l_user_status_id_rule   boolean := false;
--l_claim_number_rule     boolean := false;
--l_tax_code_rule         boolean := false;
l_amount_rule           boolean := false;
l_claim_type_id_rule    boolean := false;
l_reason_code_id_rule   boolean := false;
l_duplicate_claim_id_rule    boolean := false;
l_currency_code_rule         boolean := false;
l_claim_date_rule            boolean := false;
l_due_date_rule              boolean := false;
l_task_template_group_id_rule boolean := false;
l_owner_id_rule               boolean := false;


CURSOR  user_selected_columns_csr IS
SELECT  db_column_name, ak_attribute_code
FROM    ams_column_rules
WHERE   object_type = 'CLAM'
AND db_table_name = 'OZF_CLAIMS_ALL'
AND     rule_type = 'HISTORY';

l_column_info user_selected_columns_csr%rowtype;

CURSOR claim_rec_csr(p_id in number) IS
SELECT claim_type_id,
       claim_date,
       due_date,
       task_template_group_id,
       reason_code_id,
       owner_id,
       sales_rep_id,
       broker_id,
       status_code,
       user_status_id,
       cust_account_id,
       cust_billto_acct_site_id,
       cust_shipto_acct_site_id,
       contact_id,
       customer_ref_number,
       customer_ref_date,
       amount,
       currency_code,
       exchange_rate_type,
       exchange_rate,
       exchange_rate_date,
       duplicate_claim_id,
       order_type_id,
       comments,
       effective_date,
       gl_date,
       payment_method,
       pay_related_account_flag,
       related_cust_account_id,
       related_site_use_id,
       relationship_type,
       vendor_id,
       vendor_site_id
FROM   ozf_claims_history_all
WHERE  claim_id = p_id
order by claim_history_id desc;

l_claim_rec claim_rec_csr%rowtype;

CURSOR history_exists_csr(p_id in number) IS
SELECT claim_history_id
FROM   ozf_claims_history_all
WHERE  claim_id = p_id;

l_api_name varchar2(30):='Check_Create_history';
l_status_changed boolean := false;
BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
      FND_MSG_PUB.Add;
   END IF;

   -- First based on event, we check history
   IF (p_event = G_NEW_EVENT) THEN
      l_history_event := G_NEW_EVENT;
      change_description (
         px_description => l_event_description,
         p_column_desc =>  'OZF_CLAIM_CREATE'
      );
      l_return := TRUE;
   ELSIF (p_event = G_LINE_EVENT) THEN
      l_history_event := G_LINE_EVENT;
      change_description (
         px_description => l_event_description,
         p_column_desc => 'OZF_CLAIM_LINES'
      );
      l_return := TRUE;
   ELSIF (p_event = G_SPLIT_EVENT)  THEN
      l_history_event := G_SPLIT_EVENT;
      change_description (
         px_description => l_event_description,
         p_column_desc => 'OZF_CLAIM_SPLIT'
      );
     l_return := TRUE;
   ELSIF (p_event = G_NO_CHANGE_EVENT) THEN
     l_history_event := null;
     l_event_description := null;
     l_return := FALSE;
   -- -------------------------------------------------------------------------------------------
   -- Bug        : 2781186
   -- Changed by : (Uday Poluri)  Date: 03-Jun-2003
   -- Comments   : Follwing two ELSEIF are added to create history incase of APPLY/UNAPPLY
   --              Subsequent receipt application.
   -- -------------------------------------------------------------------------------------------
   ELSIF (p_event = G_SUBSEQUENT_APPLY_EVENT)  THEN
      l_history_event := G_SUBSEQUENT_APPLY_CHG_EVENT;
      change_description (
         px_description => l_event_description,
         p_column_desc => 'OZF_CLAIM_SUBSEQUENT_APPN'
      );
     l_return := TRUE;
   ELSIF (p_event = G_SUBSEQUENT_UNAPPLY_EVENT)  THEN
      l_history_event := G_SUBSEQUENT_UNAPPLY_CHG_EVENT;
      change_description (
         px_description => l_event_description,
         p_column_desc => 'OZF_CLAIM_SUBSEQUENT_UNAPPN'
      );
     l_return := TRUE;
   -- End Bug: 2781186 --------------------------------------------------------------------------
   ELSIF (p_event = G_UPDATE_EVENT) THEN
   -- If it is an update event and the claim is in NEW status
   -- then no need to create/update the history record (uday)
     IF p_claim.status_code = 'NEW' THEN
        l_history_event := null;
         l_event_description := null;
         l_return := FALSE;
     ELSE
         -- If event is change, we need to check each column
         OPEN CLAIM_REC_CSR(p_claim.claim_id);
         FETCH CLAIM_REC_CSR INTO l_claim_rec;
         CLOSE CLAIM_REC_CSR;

         OPEN user_selected_columns_csr;
         LOOP
             FETCH user_selected_columns_csr INTO l_column_info;
             EXIT WHEN user_selected_columns_csr%NOTFOUND;
             IF l_column_info.db_column_name = 'CLAIM_TYPE_ID' AND l_claim_type_id_rule = false
             AND
            ((p_claim.claim_type_id is null      and  l_claim_rec.claim_type_id is not null) OR
            (p_claim.claim_type_id is not null  and  l_claim_rec.claim_type_id is null) OR
            (p_claim.claim_type_id is not null  and  l_claim_rec.claim_type_id is not null AND
             p_claim.claim_type_id <> l_claim_rec.claim_type_id))
             THEN
                 l_history_event := G_CHANGE_EVENT;
                 change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
             );
                 l_claim_type_id_rule := TRUE;
                 l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CLAIM_DATE' AND l_claim_date_rule = false
                AND ((p_claim.claim_date is null     and  l_claim_rec.claim_date is not null) OR
               (p_claim.claim_date is not null and  l_claim_rec.claim_date is null) OR
               (p_claim.claim_date is not null and  l_claim_rec.claim_date is not null AND
                to_char(p_claim.claim_date,'DD-MM-YYYY') <>  to_char(l_claim_rec.claim_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_claim_date_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'DUE_DATE' AND l_due_date_rule = false
                AND ((p_claim.due_date is null     and  l_claim_rec.due_date is not null) OR
               (p_claim.due_date is not null and  l_claim_rec.due_date is null) OR
               (p_claim.due_date is not null and  l_claim_rec.due_date is not null AND
                to_char(p_claim.due_date,'DD-MM-YYYY') <> to_char(l_claim_rec.due_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_due_date_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'TASK_TEMPLATE_GROUP_ID' AND  l_task_template_group_id_rule = false
              AND ((p_claim.task_template_group_id is null     and  l_claim_rec.task_template_group_id is not null) OR
               (p_claim.task_template_group_id is not null and  l_claim_rec.task_template_group_id is null) OR
               (p_claim.task_template_group_id is not null and  l_claim_rec.task_template_group_id is not null AND
                p_claim.task_template_group_id <> l_claim_rec.task_template_group_id)) THEN
              l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_task_template_group_id_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'REASON_CODE_ID' AND l_reason_code_id_rule = false
             AND
              ((p_claim.reason_code_id is null     and  l_claim_rec.reason_code_id is not null) OR
               (p_claim.reason_code_id is not null and  l_claim_rec.reason_code_id is null) OR
               (p_claim.reason_code_id is not null and  l_claim_rec.reason_code_id is not null AND
                p_claim.reason_code_id <> l_claim_rec.reason_code_id))
                THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_reason_code_id_rule := TRUE;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'OWNER_ID' AND l_owner_id_rule = false
              AND ((p_claim.owner_id is null     and  l_claim_rec.owner_id is not null) OR
               (p_claim.owner_id is not null and  l_claim_rec.owner_id is null) OR
               (p_claim.owner_id is not null and  l_claim_rec.owner_id is not null AND
                p_claim.owner_id <> l_claim_rec.owner_id))  THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_owner_id_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'SALES_REP_ID' AND
              ((p_claim.sales_rep_id is null     and  l_claim_rec.sales_rep_id is not null) OR
               (p_claim.sales_rep_id is not null and  l_claim_rec.sales_rep_id is null) OR
               (p_claim.sales_rep_id is not null and  l_claim_rec.sales_rep_id is not null AND
                p_claim.sales_rep_id <> l_claim_rec.sales_rep_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'BROKER_ID' AND
                   ((p_claim.broker_id is null     and  l_claim_rec.broker_id is not null) OR
               (p_claim.broker_id is not null and  l_claim_rec.broker_id is null) OR
               (p_claim.broker_id is not null and  l_claim_rec.broker_id is not null AND
                p_claim.broker_id <> l_claim_rec.broker_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
        /*     ELSIF l_column_info.db_column_name = 'STATUS_CODE' AND
                   (p_claim.status_code <> FND_API.G_MISS_CHAR AND p_claim.status_code <> l_claim_rec.status_code)THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'USER_STATUS_ID' AND
                   ((p_claim.user_status_id <> FND_API.G_MISS_NUM AND p_claim.user_status_id is not null)
                   AND p_claim.user_status_id <> l_claim_rec.user_status_id) AND
                   l_status_changed = false THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
              l_status_changed := true;
                   l_return := TRUE;*/
             ELSIF l_column_info.db_column_name = 'CUST_ACCOUNT_ID' AND
                   ((p_claim.cust_account_id <> FND_API.G_MISS_NUM AND p_claim.cust_account_id is not null)
                   AND p_claim.cust_account_id <> l_claim_rec.cust_account_id) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CUST_BILLTO_ACCT_SITE_ID' AND
              ((p_claim.cust_billto_acct_site_id is null     and  l_claim_rec.cust_billto_acct_site_id is not null) OR
               (p_claim.cust_billto_acct_site_id is not null and  l_claim_rec.cust_billto_acct_site_id is null) OR
               (p_claim.cust_billto_acct_site_id is not null and  l_claim_rec.cust_billto_acct_site_id is not null AND
                p_claim.cust_billto_acct_site_id <> l_claim_rec.cust_billto_acct_site_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CUST_SHIPTO_ACCT_SITE_ID' AND
              ((p_claim.cust_shipto_acct_site_id is null     and  l_claim_rec.cust_shipto_acct_site_id is not null) OR
               (p_claim.cust_shipto_acct_site_id is not null and  l_claim_rec.cust_shipto_acct_site_id is null) OR
               (p_claim.cust_shipto_acct_site_id is not null and  l_claim_rec.cust_shipto_acct_site_id is not null AND
                p_claim.cust_shipto_acct_site_id <> l_claim_rec.cust_shipto_acct_site_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CONTACT_ID' AND
                   ((p_claim.contact_id is null     and  l_claim_rec.contact_id is not null) OR
               (p_claim.contact_id is not null and  l_claim_rec.contact_id is null) OR
               (p_claim.contact_id is not null and  l_claim_rec.contact_id is not null AND
                p_claim.contact_id <> l_claim_rec.contact_id)) THEN
              l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CUSTOMER_REF_NUMBER' AND
                   ((p_claim.customer_ref_number is null     and  l_claim_rec.customer_ref_number is not null) OR
               (p_claim.customer_ref_number is not null and  l_claim_rec.customer_ref_number is null) OR
               (p_claim.customer_ref_number is not null and  l_claim_rec.customer_ref_number is not null AND
                p_claim.customer_ref_number <> l_claim_rec.customer_ref_number)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CUSTOMER_REF_DATE' AND
                   ((p_claim.customer_ref_date is null     and  l_claim_rec.customer_ref_date is not null) OR
               (p_claim.customer_ref_date is not null and  l_claim_rec.customer_ref_date is null) OR
               (p_claim.customer_ref_date is not null and  l_claim_rec.customer_ref_date is not null AND
                to_char(p_claim.customer_ref_date,'DD-MM-YYYY') <> to_char(l_claim_rec.customer_ref_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'AMOUNT' AND
                   ((p_claim.amount <>FND_API.G_MISS_NUM AND p_claim.amount is not null)
                   AND p_claim.amount <> l_claim_rec.amount)
                   AND l_amount_rule = false
                   THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
               );
                    l_amount_rule := TRUE;
                    l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'CURRENCY_CODE' AND l_currency_code_rule = false
                   AND ((p_claim.currency_code <> FND_API.G_MISS_CHAR  AND p_claim.currency_code is not null )
                   AND p_claim.currency_code <> l_claim_rec.currency_code) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_currency_code_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'EXCHANGE_RATE_TYPE' AND
              ((p_claim.exchange_rate_type is null     and  l_claim_rec.exchange_rate_type is not null) OR
               (p_claim.exchange_rate_type is not null and  l_claim_rec.exchange_rate_type is null) OR
               (p_claim.exchange_rate_type is not null and  l_claim_rec.exchange_rate_type is not null AND
                p_claim.exchange_rate_type <> l_claim_rec.exchange_rate_type)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'EXCHANGE_RATE' AND
                   ((p_claim.exchange_rate is null     and  l_claim_rec.exchange_rate is not null) OR
               (p_claim.exchange_rate is not null and  l_claim_rec.exchange_rate is null) OR
               (p_claim.exchange_rate is not null and  l_claim_rec.exchange_rate is not null AND
                p_claim.exchange_rate <> l_claim_rec.exchange_rate)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'EXCHANGE_RATE_DATE' AND
                   ((p_claim.exchange_rate_date is null     and  l_claim_rec.exchange_rate_date is not null) OR
               (p_claim.exchange_rate_date is not null and  l_claim_rec.exchange_rate_date is null) OR
               (p_claim.exchange_rate_date is not null and  l_claim_rec.exchange_rate_date is not null AND
                to_char(p_claim.exchange_rate_date,'DD-MM-YYYY') <> to_char(l_claim_rec.exchange_rate_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'DUPLICATE_CLAIM_ID' AND l_duplicate_claim_id_rule = false
                AND ((p_claim.duplicate_claim_id is null     and  l_claim_rec.duplicate_claim_id is not null) OR
               (p_claim.duplicate_claim_id is not null and  l_claim_rec.duplicate_claim_id is null) OR
               (p_claim.duplicate_claim_id is not null and  l_claim_rec.duplicate_claim_id is not null AND
                p_claim.duplicate_claim_id <> l_claim_rec.duplicate_claim_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_duplicate_claim_id_rule := true;
                   l_return := TRUE;
             ELSIF l_column_info.db_column_name = 'ORDER_TYPE_ID' AND
                   ((p_claim.order_type_id is null     and  l_claim_rec.order_type_id is not null) OR
               (p_claim.order_type_id is not null and  l_claim_rec.order_type_id is null) OR
               (p_claim.order_type_id is not null and  l_claim_rec.order_type_id is not null AND
                p_claim.order_type_id <> l_claim_rec.order_type_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'COMMENTS' AND
                   ((p_claim.comments is null     and  l_claim_rec.comments is not null) OR
               (p_claim.comments is not null and  l_claim_rec.comments is null) OR
               (p_claim.comments is not null and  l_claim_rec.comments is not null AND
                p_claim.comments <> l_claim_rec.comments)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'EFFECTIVE_DATE' AND
                   ((p_claim.effective_date is null     and  l_claim_rec.effective_date is not null) OR
               (p_claim.effective_date is not null and  l_claim_rec.effective_date is null) OR
               (p_claim.effective_date is not null and  l_claim_rec.effective_date is not null AND
                to_char(p_claim.effective_date,'DD-MM-YYYY') <> to_char(l_claim_rec.effective_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'GL_DATE' AND
                   ((p_claim.gl_date is null     and  l_claim_rec.gl_date is not null) OR
               (p_claim.gl_date is not null and  l_claim_rec.gl_date is null) OR
               (p_claim.gl_date is not null and  l_claim_rec.gl_date is not null AND
                to_char(p_claim.gl_date,'DD-MM-YYYY') <> to_char(l_claim_rec.gl_date,'DD-MM-YYYY'))) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'PAYMENT_METHOD' AND
                   ((p_claim.payment_method is null     and  l_claim_rec.payment_method is not null) OR
               (p_claim.payment_method is not null and  l_claim_rec.payment_method is null) OR
               (p_claim.payment_method is not null and  l_claim_rec.payment_method is not null AND
                p_claim.payment_method <> l_claim_rec.payment_method))
                AND l_payment_method_rule = false
                THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_payment_method_rule := TRUE;
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'PAY_RELATED_ACCOUNT_FLAG' AND
                   ((p_claim.pay_related_account_flag is null     and  l_claim_rec.pay_related_account_flag is not null) OR
               (p_claim.pay_related_account_flag is not null and  l_claim_rec.pay_related_account_flag is null) OR
               (p_claim.pay_related_account_flag is not null and  l_claim_rec.pay_related_account_flag is not null AND
                p_claim.pay_related_account_flag <> l_claim_rec.pay_related_account_flag)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'RELATED_CUST_ACCOUNT_ID' AND
                   ((p_claim.related_cust_account_id is null     and  l_claim_rec.related_cust_account_id is not null) OR
               (p_claim.related_cust_account_id is not null and  l_claim_rec.related_cust_account_id is null) OR
               (p_claim.related_cust_account_id is not null and  l_claim_rec.related_cust_account_id is not null AND
                p_claim.related_cust_account_id <> l_claim_rec.related_cust_account_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'RELATED_SITE_USE_ID' AND
                   ((p_claim.related_site_use_id is null     and  l_claim_rec.related_site_use_id is not null) OR
               (p_claim.related_site_use_id is not null and  l_claim_rec.related_site_use_id is null) OR
               (p_claim.related_site_use_id is not null and  l_claim_rec.related_site_use_id is not null AND
                p_claim.related_site_use_id <> l_claim_rec.related_site_use_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'RELATIONSHIP_TYPE' AND
                   ((p_claim.relationship_type is null     and  l_claim_rec.relationship_type is not null) OR
               (p_claim.relationship_type is not null and  l_claim_rec.relationship_type is null) OR
               (p_claim.relationship_type is not null and  l_claim_rec.relationship_type is not null AND
                p_claim.relationship_type <> l_claim_rec.relationship_type)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'USER_STATUS_ID' AND
                   ((p_claim.user_status_id is null     and  l_claim_rec.user_status_id is not null) OR
               (p_claim.user_status_id is not null and  l_claim_rec.user_status_id is null) OR
               (p_claim.user_status_id is not null and  l_claim_rec.user_status_id is not null AND
                p_claim.user_status_id <> l_claim_rec.user_status_id))
                AND l_user_status_id_rule = false
                THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
                   l_user_status_id_rule := TRUE;
            ELSIF l_column_info.db_column_name = 'VENDOR_ID' AND
                   ((p_claim.vendor_id is null     and  l_claim_rec.vendor_id is not null) OR
               (p_claim.vendor_id is not null and  l_claim_rec.vendor_id is null) OR
               (p_claim.vendor_id is not null and  l_claim_rec.vendor_id is not null AND
                p_claim.vendor_id <> l_claim_rec.vendor_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
            ELSIF l_column_info.db_column_name = 'VENDOR_SITE_ID' AND
                   ((p_claim.vendor_site_id is null     and  l_claim_rec.vendor_site_id is not null) OR
               (p_claim.vendor_site_id is not null and  l_claim_rec.vendor_site_id is null) OR
               (p_claim.vendor_site_id is not null and  l_claim_rec.vendor_site_id is not null AND
                p_claim.vendor_site_id <> l_claim_rec.vendor_site_id)) THEN
                   l_history_event := G_CHANGE_EVENT;
                   change_description (
                px_description => l_event_description,
                     p_column_desc => l_column_info.ak_attribute_code
              );
                   l_return := TRUE;
             END IF;
         END LOOP;
         CLOSE user_selected_columns_csr;
    END IF;
   --end (uday)
   END IF;

   x_history_event := l_history_event;
   x_history_event_description := l_event_description;
   IF l_return THEN
      x_needed_to_create := 'Y';
   ELSE
      x_needed_to_create := 'N';
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
      FND_MSG_PUB.Add;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CHK_CREATE_HIST_ERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END check_create_history;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_History
--
-- PURPOSE
--    This procedure checks whether if a history record of a claim is
--    needed based on the previous event. If there is a need, it then
--    creates a snapshot (or history) of claim. The snapshot includes
--    claim detail information, claim line information and tasks information
--
-- PARAMETERS
--    p_claim_id: Id to identify a claim
--    x_claim_history_id:  Id of a claim history
--
-- NOTES:
--
---------------------------------------------------------------------
PROCEDURE Create_History(p_claim_id         IN  NUMBER,
                         p_history_event    IN  VARCHAR2,
			                p_history_event_description IN VARCHAR2,
                         x_claim_history_id OUT NOCOPY NUMBER,
                         x_return_status    OUT NOCOPY VARCHAR2)
IS
l_msg_count       number;
l_msg_data        varchar2(2000);
l_return_status   varchar2(30);
l_api_name        varchar2(30) := 'Create_History';

l_claims_history_rec      OZF_claims_history_PVT.claims_history_rec_type;
l_claim_history_id        number := null;

l_claim_lines_hist_rec    OZF_claim_line_hist_PVT.claim_line_hist_rec_type;
l_claim_line_history_id   number;
l_claim_line_rec          OZF_Claim_Line_PVT.claim_line_rec_type;
l_event_description       varchar2(2000);

CURSOR custom_setup_id_csr (p_claim_class in varchar2) IS
SELECT custom_setup_id
FROM ams_custom_setups_vl
WHERE object_type = G_CLAIM_HIST_OBJ_TYPE
AND  activity_type_code = p_claim_class;

CURSOR claim_csr(pid in number) IS
SELECT *
FROM ozf_claims_all
WHERE claim_id = pid;
l_claim_rec             claim_csr%ROWTYPE;

CURSOR claim_line_csr(p_id in number) IS
SELECT *
FROM   ozf_claim_lines_all
WHERE  claim_id = p_id;

--CURSOR history_ids_csr(p_claim_id) IS
--SELECT line_claim_history_id, task_claim_history_id
--FROM ozf_claims_history
--WHERE claim_id = p_claim_id
--AND event_date = max(event_date);

--CURSOR history_ids_csr(p_claim_id) IS
--SELECT line_claim_history_id
--FROM ozf_claims_history
--WHERE claim_id = p_claim_id
--AND event_date = max(event_date);

CURSOR claim_history_sequence_cur IS
SELECT ozf_claims_history_all_s.nextval
FROM dual;

CURSOR check_csr (pid in number)is
select history_event, history_event_description
from ozf_claims_all
where claim_id = pid;

CURSOR c_claim_hist_id_count(p_id in number) is
select count(*)
from ozf_claims_history
where claim_history_id =p_id;
l_claim_hist_id_count number:=0;

l_history_event      varchar2(40);
l_history_event_desc varchar2(60);

BEGIN
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
         FND_MSG_PUB.Add;
    END IF;

    OPEN claim_csr(p_claim_id);
    FETCH claim_csr INTO l_claim_rec;
    CLOSE claim_csr;

    -- Here we need to chang the custom_setup_id from CLAM to CLAMHIST
    OPEN custom_setup_id_csr(l_claim_rec.claim_class);
    FETCH custom_setup_id_csr INTO l_claim_rec.custom_setup_id;
    CLOSE custom_setup_id_csr;

    -- Get the value for claim_history_id


    LOOP
      -- Get the identifier
      OPEN claim_history_sequence_cur;
      FETCH claim_history_sequence_cur INTO l_claim_history_id;
      CLOSE claim_history_sequence_cur;
      -- Check the uniqueness of the identifier
      OPEN  c_claim_hist_id_count(l_claim_history_id);
      FETCH c_claim_hist_id_count INTO l_claim_hist_id_count;
      CLOSE c_claim_hist_id_count;
      -- Exit when the identifier uniqueness is established
      EXIT WHEN l_claim_hist_id_count = 0;
    END LOOP;

    --Construct claim history rec for the rest of the columns
    l_claims_history_rec.claim_history_id   := l_claim_history_id;
    l_claims_history_rec.batch_id            := l_claim_rec.batch_id;
    l_claims_history_rec.claim_id            := l_claim_rec.claim_id;
    l_claims_history_rec.claim_number        := l_claim_rec.claim_number;
    l_claims_history_rec.claim_type_id       := l_claim_rec.claim_type_id;
    l_claims_history_rec.claim_class         := l_claim_rec.claim_class;
    l_claims_history_rec.claim_date          := l_claim_rec.claim_date;
    l_claims_history_rec.due_date            := l_claim_rec.due_date;
    l_claims_history_rec.owner_id            := l_claim_rec.owner_id;
    l_claims_history_rec.history_event_date  := l_claim_rec.history_event_date;
    --Code changes (uday)
    l_claims_history_rec.history_event       := p_history_event;
    l_claims_history_rec.history_event_description   := p_history_event_description;
    --end (-uday)

    l_claims_history_rec.split_from_claim_id := l_claim_rec.split_from_claim_id;
    l_claims_history_rec.duplicate_claim_id  := l_claim_rec.duplicate_claim_id;
    l_claims_history_rec.split_date          := l_claim_rec.split_date;
    l_claims_history_rec.root_claim_id       := l_claim_rec.root_claim_id;
    l_claims_history_rec.amount              := l_claim_rec.amount;
    l_claims_history_rec.amount_adjusted     := l_claim_rec.amount_adjusted;
    l_claims_history_rec.amount_settled      := l_claim_rec.amount_settled;
    l_claims_history_rec.amount_remaining    := l_claim_rec.amount_remaining;
    l_claims_history_rec.acctd_amount        := l_claim_rec.acctd_amount;
    l_claims_history_rec.acctd_amount_remaining := l_claim_rec.acctd_amount_remaining;
    l_claims_history_rec.acctd_amount_adjusted  := l_claim_rec.acctd_amount_adjusted;
    l_claims_history_rec.acctd_amount_settled   := l_claim_rec.acctd_amount_settled;
    l_claims_history_rec.tax_amount          := l_claim_rec.tax_amount;
    l_claims_history_rec.tax_code            := l_claim_rec.tax_code;
    l_claims_history_rec.tax_calculation_flag := l_claim_rec.tax_calculation_flag;
    l_claims_history_rec.currency_code       := l_claim_rec.currency_code;
    l_claims_history_rec.exchange_rate_type  := l_claim_rec.exchange_rate_type;
    l_claims_history_rec.exchange_rate_date  := l_claim_rec.exchange_rate_date;
    l_claims_history_rec.exchange_rate       := l_claim_rec.exchange_rate;
    l_claims_history_rec.set_of_books_id     := l_claim_rec.set_of_books_id;
    l_claims_history_rec.original_claim_date := l_claim_rec.original_claim_date;
    l_claims_history_rec.source_object_id    := l_claim_rec.source_object_id;
    l_claims_history_rec.source_object_class := l_claim_rec.source_object_class;
    l_claims_history_rec.source_object_type_id := l_claim_rec.source_object_type_id;
    l_claims_history_rec.source_object_number:= l_claim_rec.source_object_number;
    l_claims_history_rec.cust_account_id     := l_claim_rec.cust_account_id;
    l_claims_history_rec.cust_billto_acct_site_id := l_claim_rec.cust_billto_acct_site_id;
    l_claims_history_rec.cust_shipto_acct_site_id := l_claim_rec.cust_shipto_acct_site_id;
    l_claims_history_rec.location_id         := l_claim_rec.location_id;
    l_claims_history_rec.pay_related_account_flag := l_claim_rec.pay_related_account_flag;
    l_claims_history_rec.related_cust_account_id:= l_claim_rec.related_cust_account_id;
    l_claims_history_rec.related_site_use_id := l_claim_rec.related_site_use_id;
    l_claims_history_rec.relationship_type   := l_claim_rec.relationship_type;
    l_claims_history_rec.vendor_id           := l_claim_rec.vendor_id;
    l_claims_history_rec.vendor_site_id      := l_claim_rec.vendor_site_id;
    l_claims_history_rec.reason_type         := l_claim_rec.reason_type;
    l_claims_history_rec.reason_code_id      := l_claim_rec.reason_code_id;
    l_claims_history_rec.task_template_group_id := l_claim_rec.task_template_group_id;
    l_claims_history_rec.status_code         := l_claim_rec.status_code;
    l_claims_history_rec.user_status_id      := l_claim_rec.user_status_id;
    l_claims_history_rec.sales_rep_id        := l_claim_rec.sales_rep_id;
    l_claims_history_rec.collector_id        := l_claim_rec.collector_id;
    l_claims_history_rec.contact_id          := l_claim_rec.contact_id;
    l_claims_history_rec.broker_id           := l_claim_rec.broker_id;
    l_claims_history_rec.territory_id        := l_claim_rec.territory_id;
    l_claims_history_rec.customer_ref_date   := l_claim_rec.customer_ref_date;
    l_claims_history_rec.customer_ref_number := l_claim_rec.customer_ref_number;
    l_claims_history_rec.assigned_to         := l_claim_rec.assigned_to;
    l_claims_history_rec.receipt_id          := l_claim_rec.receipt_id;
    l_claims_history_rec.receipt_number      := l_claim_rec.receipt_number;
    l_claims_history_rec.doc_sequence_id     := l_claim_rec.doc_sequence_id;
    l_claims_history_rec.doc_sequence_value  := l_claim_rec.doc_sequence_value;
    l_claims_history_rec.gl_date             := l_claim_rec.gl_date;
    l_claims_history_rec.payment_method      := l_claim_rec.payment_method;
    l_claims_history_rec.voucher_id          := l_claim_rec.voucher_id;
    l_claims_history_rec.voucher_number      := l_claim_rec.voucher_number;
    l_claims_history_rec.payment_reference_id:= l_claim_rec.payment_reference_id;
    l_claims_history_rec.payment_reference_number:= l_claim_rec.payment_reference_number;
    l_claims_history_rec.payment_reference_date  := l_claim_rec.payment_reference_date;
    l_claims_history_rec.payment_status      := l_claim_rec.payment_status;
    l_claims_history_rec.approved_flag       := l_claim_rec.approved_flag;
    l_claims_history_rec.approved_date       := l_claim_rec.approved_date;
    l_claims_history_rec.approved_by         := l_claim_rec.approved_by;
    l_claims_history_rec.settled_date        := l_claim_rec.settled_date;
    l_claims_history_rec.settled_by          := l_claim_rec.settled_by;
    l_claims_history_rec.effective_date      := l_claim_rec.effective_date;
    l_claims_history_rec.custom_setup_id     := l_claim_rec.custom_setup_id;
    l_claims_history_rec.task_id             := l_claim_rec.task_id;
    l_claims_history_rec.country_id          := l_claim_rec.country_id;
    l_claims_history_rec.order_type_id       := l_claim_rec.order_type_id;
    l_claims_history_rec.comments            := l_claim_rec.comments;
    l_claims_history_rec.task_source_object_id := l_claim_rec.claim_id;
    l_claims_history_rec.task_source_object_type_code := G_CLAIM_TYPE;
    l_claims_history_rec.attribute_category  := l_claim_rec.attribute_category;
    l_claims_history_rec.attribute1          := l_claim_rec.attribute1;
    l_claims_history_rec.attribute2          := l_claim_rec.attribute2;
    l_claims_history_rec.attribute3          := l_claim_rec.attribute3;
    l_claims_history_rec.attribute4          := l_claim_rec.attribute4;
    l_claims_history_rec.attribute5          := l_claim_rec.attribute5;
    l_claims_history_rec.attribute6          := l_claim_rec.attribute6;
    l_claims_history_rec.attribute7          := l_claim_rec.attribute7;
    l_claims_history_rec.attribute8          := l_claim_rec.attribute8;
    l_claims_history_rec.attribute9          := l_claim_rec.attribute9;
    l_claims_history_rec.attribute10         := l_claim_rec.attribute10;
    l_claims_history_rec.attribute11         := l_claim_rec.attribute11;
    l_claims_history_rec.attribute12         := l_claim_rec.attribute12;
    l_claims_history_rec.attribute13         := l_claim_rec.attribute13;
    l_claims_history_rec.attribute14         := l_claim_rec.attribute14;
    l_claims_history_rec.attribute15         := l_claim_rec.attribute15;
    l_claims_history_rec.deduction_attribute_category := l_claim_rec.deduction_attribute_category;
     l_claims_history_rec.deduction_attribute1 := l_claim_rec.deduction_attribute1;
    l_claims_history_rec.deduction_attribute2 := l_claim_rec.deduction_attribute2;
    l_claims_history_rec.deduction_attribute3 := l_claim_rec.deduction_attribute3;
    l_claims_history_rec.deduction_attribute4 := l_claim_rec.deduction_attribute4;
    l_claims_history_rec.deduction_attribute5 := l_claim_rec.deduction_attribute5;
    l_claims_history_rec.deduction_attribute6 := l_claim_rec.deduction_attribute6;
    l_claims_history_rec.deduction_attribute7 := l_claim_rec.deduction_attribute7;
    l_claims_history_rec.deduction_attribute8 := l_claim_rec.deduction_attribute8;
    l_claims_history_rec.deduction_attribute9 := l_claim_rec.deduction_attribute9;
    l_claims_history_rec.deduction_attribute10 := l_claim_rec.deduction_attribute10;
    l_claims_history_rec.deduction_attribute11 := l_claim_rec.deduction_attribute11;
    l_claims_history_rec.deduction_attribute12 := l_claim_rec.deduction_attribute12;
    l_claims_history_rec.deduction_attribute13 := l_claim_rec.deduction_attribute13;
    l_claims_history_rec.deduction_attribute14 := l_claim_rec.deduction_attribute14;
    l_claims_history_rec.deduction_attribute15 := l_claim_rec.deduction_attribute15;
    l_claims_history_rec.org_id                := l_claim_rec.org_id;
    l_claims_history_rec.write_off_flag              := l_claim_rec.write_off_flag;
    l_claims_history_rec.write_off_threshold_amount  := l_claim_rec.write_off_threshold_amount;
    l_claims_history_rec.under_write_off_threshold   := l_claim_rec.under_write_off_threshold;
    l_claims_history_rec.customer_reason             := l_claim_rec.customer_reason;
    l_claims_history_rec.ship_to_cust_account_id     := l_claim_rec.ship_to_cust_account_id;
    l_claims_history_rec.amount_applied              := l_claim_rec.amount_applied;
    l_claims_history_rec.applied_receipt_id          := l_claim_rec.applied_receipt_id;
    l_claims_history_rec.applied_receipt_number      := l_claim_rec.applied_receipt_number;
    l_claims_history_rec.wo_rec_trx_id               := l_claim_rec.wo_rec_trx_id;

    l_claims_history_rec.group_claim_id               := l_claim_rec.group_claim_id;
    l_claims_history_rec.appr_wf_item_key             := l_claim_rec.appr_wf_item_key;
    l_claims_history_rec.cstl_wf_item_key             := l_claim_rec.cstl_wf_item_key;
    l_claims_history_rec.batch_type                   := l_claim_rec.batch_type;


    OZF_claims_history_PVT.Create_claims_history(
       P_Api_Version_Number         => 1.0,
       P_Init_Msg_List              => FND_API.G_FALSE,
       P_Commit                     => FND_API.G_FALSE,
       P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
       X_Return_Status              => l_return_status,
       X_Msg_Count                  => l_msg_count,
       X_Msg_Data                   => l_msg_data,
       P_CLAIMS_HISTORY_Rec         => l_CLAIMS_HISTORY_Rec,
       X_CLAIM_HISTORY_ID           => l_CLAIM_HISTORY_ID
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

   -- update the history related columns for the claim
     UPDATE ozf_claims_all
     SET history_event = p_history_event,
         history_event_date = SYSDATE,
         history_event_description = p_history_event_description
     WHERE claim_id = p_claim_id;

    -- Create a history for the lines.
    -- Get line detail
    FOR l_claim_line_rec IN claim_line_csr(p_claim_id) LOOP
 --       EXIT WHEN claim_line_csr%NOTFOUND;

	--Construct claim history line rec
        l_claim_lines_hist_rec.claim_history_id          := l_claim_history_id;
        l_claim_lines_hist_rec.claim_id                  := p_claim_id;
        l_claim_lines_hist_rec.claim_line_id             := l_claim_line_rec.claim_line_id;
        l_claim_lines_hist_rec.line_number               := l_claim_line_rec.line_number;
        l_claim_lines_hist_rec.split_from_claim_line_id  := l_claim_line_rec.split_from_claim_line_id;
        l_claim_lines_hist_rec.amount                    := l_claim_line_rec.amount;
	     l_claim_lines_hist_rec.acctd_amount              := l_claim_line_rec.acctd_amount;
        l_claim_lines_hist_rec.currency_code             := l_claim_line_rec.currency_code;
        l_claim_lines_hist_rec.exchange_rate_type        := l_claim_line_rec.exchange_rate_type;
        l_claim_lines_hist_rec.exchange_rate_date        := l_claim_line_rec.exchange_rate_date;
        l_claim_lines_hist_rec.exchange_rate             := l_claim_line_rec.exchange_rate;
        l_claim_lines_hist_rec.set_of_books_id           := l_claim_line_rec.set_of_books_id;
        l_claim_lines_hist_rec.valid_flag                := l_claim_line_rec.valid_flag;
        l_claim_lines_hist_rec.source_object_id          := l_claim_line_rec.source_object_id;
        l_claim_lines_hist_rec.source_object_class       := l_claim_line_rec.source_object_class;
        l_claim_lines_hist_rec.source_object_type_id     := l_claim_line_rec.source_object_type_id;
        l_claim_lines_hist_rec.source_object_line_id     := l_claim_line_rec.source_object_line_id;
        l_claim_lines_hist_rec.plan_id                   := l_claim_line_rec.plan_id;
        l_claim_lines_hist_rec.offer_id                  := l_claim_line_rec.offer_id;
        l_claim_lines_hist_rec.payment_method            := l_claim_line_rec.payment_method;
        l_claim_lines_hist_rec.payment_reference_id      := l_claim_line_rec.payment_reference_id;
        l_claim_lines_hist_rec.payment_reference_number  := l_claim_line_rec.payment_reference_number;
        l_claim_lines_hist_rec.payment_reference_date    := l_claim_line_rec.payment_reference_date;
        l_claim_lines_hist_rec.voucher_id                := l_claim_line_rec.voucher_id;
        l_claim_lines_hist_rec.voucher_number            := l_claim_line_rec.voucher_number;
        l_claim_lines_hist_rec.payment_status            := l_claim_line_rec.payment_status;
        l_claim_lines_hist_rec.approved_flag             := l_claim_line_rec.approved_flag;
        l_claim_lines_hist_rec.approved_date             := l_claim_line_rec.approved_date;
        l_claim_lines_hist_rec.approved_by               := l_claim_line_rec.approved_by;
        l_claim_lines_hist_rec.settled_date              := l_claim_line_rec.settled_date;
        l_claim_lines_hist_rec.settled_by                := l_claim_line_rec.settled_by;
        l_claim_lines_hist_rec.performance_complete_flag := l_claim_line_rec.performance_complete_flag;
        l_claim_lines_hist_rec.performance_attached_flag := l_claim_line_rec.performance_attached_flag;
        l_claim_lines_hist_rec.attribute_category        := l_claim_line_rec.attribute_category;
        l_claim_lines_hist_rec.attribute1                := l_claim_line_rec.attribute1;
        l_claim_lines_hist_rec.attribute2                := l_claim_line_rec.attribute2;
        l_claim_lines_hist_rec.attribute3                := l_claim_line_rec.attribute3;
        l_claim_lines_hist_rec.attribute4                := l_claim_line_rec.attribute4;
        l_claim_lines_hist_rec.attribute5                := l_claim_line_rec.attribute5;
        l_claim_lines_hist_rec.attribute6                := l_claim_line_rec.attribute6;
        l_claim_lines_hist_rec.attribute7                := l_claim_line_rec.attribute7;
        l_claim_lines_hist_rec.attribute8                := l_claim_line_rec.attribute8;
        l_claim_lines_hist_rec.attribute9                := l_claim_line_rec.attribute9;
        l_claim_lines_hist_rec.attribute10               := l_claim_line_rec.attribute10;
        l_claim_lines_hist_rec.attribute11               := l_claim_line_rec.attribute11;
        l_claim_lines_hist_rec.attribute12               := l_claim_line_rec.attribute12;
        l_claim_lines_hist_rec.attribute13               := l_claim_line_rec.attribute13;
        l_claim_lines_hist_rec.attribute14               := l_claim_line_rec.attribute14;
        l_claim_lines_hist_rec.attribute15               := l_claim_line_rec.attribute15;
        l_claim_lines_hist_rec.org_id                    := l_claim_line_rec.org_id;
        l_claim_lines_hist_rec.utilization_id            := l_claim_line_rec.utilization_id;
        l_claim_lines_hist_rec.claim_currency_amount     := l_claim_line_rec.claim_currency_amount;
        l_claim_lines_hist_rec.item_id                   := l_claim_line_rec.item_id;
       	l_claim_lines_hist_rec.item_description          := l_claim_line_rec.item_description;
         l_claim_lines_hist_rec.quantity                  := l_claim_line_rec.quantity;
       	l_claim_lines_hist_rec.quantity_uom              := l_claim_line_rec.quantity_uom;
       	l_claim_lines_hist_rec.rate                      := l_claim_line_rec.rate;
       	l_claim_lines_hist_rec.activity_type             := l_claim_line_rec.activity_type;
       	l_claim_lines_hist_rec.activity_id               := l_claim_line_rec.activity_id;
       	l_claim_lines_hist_rec.earnings_associated_flag  := l_claim_line_rec.earnings_associated_flag;
       	l_claim_lines_hist_rec.comments                  := l_claim_line_rec.comments;
       	l_claim_lines_hist_rec.related_cust_account_id   := l_claim_line_rec.related_cust_account_id;
       	l_claim_lines_hist_rec.relationship_type         := l_claim_line_rec.relationship_type;
        l_claim_lines_hist_rec.buy_group_cust_account_id := l_claim_line_rec.buy_group_cust_account_id;
        l_claim_lines_hist_rec.select_cust_children_flag := l_claim_line_rec.select_cust_children_flag;
        l_claim_lines_hist_rec.tax_code                  := l_claim_line_rec.tax_code;
        l_claim_lines_hist_rec.credit_to                 := l_claim_line_rec.credit_to;

        l_claim_lines_hist_rec.sale_date                 := l_claim_line_rec.sale_date;
        l_claim_lines_hist_rec.item_type                 := l_claim_line_rec.item_type;
        l_claim_lines_hist_rec.tax_amount                := l_claim_line_rec.tax_amount;
        l_claim_lines_hist_rec.claim_curr_tax_amount     := l_claim_line_rec.claim_curr_tax_amount;
        l_claim_lines_hist_rec.activity_line_id          := l_claim_line_rec.activity_line_id;
        l_claim_lines_hist_rec.offer_type                := l_claim_line_rec.offer_type;
        l_claim_lines_hist_rec.prorate_earnings_flag     := l_claim_line_rec.prorate_earnings_flag;
        l_claim_lines_hist_rec.earnings_end_date         := l_claim_line_rec.earnings_end_date;



        OZF_claim_line_hist_PVT.Create_claim_line_hist(
           P_Api_Version_Number         => 1.0,
           P_Init_Msg_List              => FND_API.G_FALSE,
           P_Commit                     => FND_API.G_FALSE,
           P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
           X_Return_Status              => l_return_status,
           X_Msg_Count                  => l_msg_count,
           X_Msg_Data                   => l_msg_data,
           P_CLAIM_LINE_HIST_Rec       => l_CLAIM_LINES_HIST_Rec,
           X_CLAIM_LINE_HISTORY_ID      => l_CLAIM_LINE_HISTORY_ID
	);
        IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

    END LOOP;
    x_claim_history_id := l_claim_history_id;

    IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
         FND_MSG_PUB.Add;
    END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CREATE_HIST_ERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END create_history;

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claims_History
--
-- PURPOSE
--    This procedure deletes a record in ozf_claims_history_all table by calling
--    the table handler package.
--
-- PARAMETERS
--    p_CLAIMS_HISTORY_Rec: The record that you want to delete.
--
-- NOTES:
--
---------------------------------------------------------------------
PROCEDURE Delete_claims_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    P_CLAIM_HISTORY_ID           IN  NUMBER,
    P_Object_Version_Number      IN   NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_claims_history';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

CURSOR version_csr (p_claim_history_id in number)IS
SELECT object_version_number
FROM   ozf_claims_history_all
WHERE  claim_history_id = p_claim_history_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CLAIMS_HISTORY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
         FND_MSG_PUB.Add;
      END IF;

      -- Invoke table handler(OZF_claims_history_PKG.Delete_Row)
      OPEN version_csr(p_claim_history_id);
      FETCH version_csr INTO l_object_version_number;
      CLOSE version_csr;

      IF p_object_version_number = l_object_version_number THEN
         BEGIN
           OZF_claims_history_PKG.Delete_Row(
              p_CLAIM_HISTORY_ID  => p_CLAIM_HISTORY_ID);
         EXCEPTION
           WHEN OTHERS THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
                FND_MSG_PUB.add;
             END IF;
             RAISE FND_API.g_exc_error;
           END;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_API_RESOURCE_LOCKED');
            FND_MSG_PUB.add;
            END IF;
         RAISE FND_API.g_exc_error;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
         FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO DELETE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Delete_claims_history;

---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claims_History
--
-- PURPOSE
--    This procedure updates a record in ozf_claims_history_all table by calling
--    the table handler package.
--
-- PARAMETERS
--    p_CLAIMS_HISTORY_Rec: The record that you want to update.
--
-- NOTES:
--
---------------------------------------------------------------------
PROCEDURE Update_Claims_History(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,

    P_CLAIMS_HISTORY_Rec         IN   CLAIMS_HISTORY_Rec_Type,
    X_Object_Version_Number      OUT NOCOPY  NUMBER
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_Claims_History';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number   NUMBER;
l_CLAIM_HISTORY_ID        NUMBER;
l_return_status           varchar2(30);
l_claims_history_rec      claims_history_rec_type;

CURSOR object_version_number_csr (p_id in number) is
select object_version_number
from ozf_claims_history_all
where claim_history_id = p_id;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CLAIMS_HISTORY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': START');
         FND_MSG_PUB.Add;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      If (P_CLAIMS_HISTORY_Rec.object_version_number is NULL or
          P_CLAIMS_HISTORY_Rec.object_version_number = FND_API.G_MISS_NUM ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
             FND_MESSAGE.Set_Name('OZF', 'OZF_API_NO_OBJ_VER_NUM');
             FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      OPEN object_version_number_csr(P_CLAIMS_HISTORY_Rec.claim_history_id);
      FETCH object_version_number_csr INTO l_object_version_number;
      CLOSE object_version_number_csr;

      IF l_object_version_number <> P_CLAIMS_HISTORY_Rec.object_version_number THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_API_RESOURCE_LOCKED');
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      Complete_Claim_History_Rec (
         p_claim_history_rec  => p_claims_history_rec
        ,x_complete_rec       => l_claims_history_rec
        ,x_return_status      => l_return_status
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

	  -- Invoke validation procedures
          Validate_claims_history(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            P_CLAIMS_HISTORY_Rec  =>  l_CLAIMS_HISTORY_Rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;


      -- Invoke table handler(OZF_claims_history_PKG.Update_Row)
      Begin
        OZF_claims_history_PKG.Update_Row(
          p_CLAIM_HISTORY_ID       => l_CLAIMS_HISTORY_rec.CLAIM_HISTORY_ID,
          p_OBJECT_VERSION_NUMBER  => l_CLAIMS_HISTORY_rec.OBJECT_VERSION_NUMBER +1 ,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID             => l_CLAIMS_HISTORY_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID => l_CLAIMS_HISTORY_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_UPDATE_DATE    => l_CLAIMS_HISTORY_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_ID             => l_CLAIMS_HISTORY_rec.PROGRAM_ID,
          p_CREATED_FROM           => l_CLAIMS_HISTORY_rec.CREATED_FROM,
          p_BATCH_ID               => l_CLAIMS_HISTORY_rec.BATCH_ID,
          p_CLAIM_ID               => l_CLAIMS_HISTORY_rec.CLAIM_ID,
          p_CLAIM_NUMBER           => l_CLAIMS_HISTORY_rec.CLAIM_NUMBER,
          p_CLAIM_TYPE_ID          => l_CLAIMS_HISTORY_rec.CLAIM_TYPE_ID,
          p_CLAIM_CLASS            => l_CLAIMS_HISTORY_REC.CLAIM_CLASS,
          p_CLAIM_DATE             => l_CLAIMS_HISTORY_rec.CLAIM_DATE,
          p_DUE_DATE               => l_CLAIMS_HISTORY_rec.DUE_DATE,
          p_OWNER_ID               => l_CLAIMS_HISTORY_rec.OWNER_ID,
          p_HISTORY_EVENT          => l_CLAIMS_HISTORY_rec.HISTORY_EVENT,
          p_HISTORY_EVENT_DATE     => l_CLAIMS_HISTORY_rec.HISTORY_EVENT_DATE,
          p_HISTORY_EVENT_DESCRIPTION  => l_CLAIMS_HISTORY_rec.HISTORY_EVENT_DESCRIPTION,
          p_SPLIT_FROM_CLAIM_ID    => l_CLAIMS_HISTORY_rec.SPLIT_FROM_CLAIM_ID,
          p_duplicate_claim_id     => l_claims_history_rec.duplicate_claim_id,
          p_SPLIT_DATE             => l_CLAIMS_HISTORY_rec.SPLIT_DATE,
          p_ROOT_CLAIM_ID          => l_claims_history_rec.ROOT_CLAIM_ID,
          p_AMOUNT                 => l_CLAIMS_HISTORY_rec.AMOUNT,
          p_AMOUNT_ADJUSTED        => l_CLAIMS_HISTORY_rec.AMOUNT_ADJUSTED,
          p_AMOUNT_REMAINING       => l_CLAIMS_HISTORY_rec.AMOUNT_REMAINING,
          p_AMOUNT_SETTLED         => l_CLAIMS_HISTORY_rec.AMOUNT_SETTLED,
          p_ACCTD_AMOUNT           => l_CLAIMS_HISTORY_rec.ACCTD_AMOUNT,
          p_acctd_amount_remaining => l_claims_history_rec.acctd_amount_remaining,
          p_acctd_AMOUNT_ADJUSTED  => l_CLAIMS_HISTORY_rec.acctd_AMOUNT_ADJUSTED,
          p_acctd_AMOUNT_SETTLED   => l_CLAIMS_HISTORY_rec.acctd_AMOUNT_SETTLED,
          p_tax_amount             => l_claims_history_rec.tax_amount,
          p_tax_code               => l_claims_history_rec.tax_code,
          p_tax_calculation_flag   => l_claims_history_rec.tax_calculation_flag,
          p_CURRENCY_CODE          => l_CLAIMS_HISTORY_rec.CURRENCY_CODE,
          p_EXCHANGE_RATE_TYPE     => l_CLAIMS_HISTORY_rec.EXCHANGE_RATE_TYPE,
          p_EXCHANGE_RATE_DATE     => l_CLAIMS_HISTORY_rec.EXCHANGE_RATE_DATE,
          p_EXCHANGE_RATE          => l_CLAIMS_HISTORY_rec.EXCHANGE_RATE,
          p_SET_OF_BOOKS_ID        => l_CLAIMS_HISTORY_rec.SET_OF_BOOKS_ID,
          p_ORIGINAL_CLAIM_DATE    => l_CLAIMS_HISTORY_rec.ORIGINAL_CLAIM_DATE,
          p_SOURCE_OBJECT_ID       => l_CLAIMS_HISTORY_rec.SOURCE_OBJECT_ID,
          p_SOURCE_OBJECT_CLASS    => l_CLAIMS_HISTORY_rec.SOURCE_OBJECT_CLASS,
          p_SOURCE_OBJECT_TYPE_ID  => l_CLAIMS_HISTORY_rec.SOURCE_OBJECT_TYPE_ID,
          p_SOURCE_OBJECT_NUMBER   => l_CLAIMS_HISTORY_rec.SOURCE_OBJECT_NUMBER,
          p_CUST_ACCOUNT_ID        => l_CLAIMS_HISTORY_rec.CUST_ACCOUNT_ID,
          p_CUST_BILLTO_ACCT_SITE_ID  => l_CLAIMS_HISTORY_rec.CUST_BILLTO_ACCT_SITE_ID,
          p_cust_shipto_acct_site_id  => l_claims_history_rec.cust_shipto_acct_site_id,
          p_LOCATION_ID            => l_CLAIMS_HISTORY_rec.LOCATION_ID,
          p_PAY_RELATED_ACCOUNT_FLAG => l_claims_history_rec.PAY_RELATED_ACCOUNT_FLAG,
          p_RELATED_CUST_ACCOUNT_ID  => l_claims_history_rec.RELATED_CUST_ACCOUNT_ID,
          p_RELATED_SITE_USE_ID      => l_claims_history_rec.RELATED_SITE_USE_ID,
          p_RELATIONSHIP_TYPE        => l_claims_history_rec.RELATIONSHIP_TYPE,
          p_VENDOR_ID                => l_claims_history_rec.VENDOR_ID,
          p_VENDOR_SITE_ID           => l_claims_history_rec.VENDOR_SITE_ID,
          p_REASON_TYPE              => l_CLAIMS_HISTORY_rec.REASON_TYPE,
          p_REASON_CODE_ID           => l_CLAIMS_HISTORY_rec.REASON_CODE_ID,
          p_TASK_TEMPLATE_GROUP_ID   => l_claims_history_rec.TASK_TEMPLATE_GROUP_ID,
          p_STATUS_CODE              => l_CLAIMS_HISTORY_rec.STATUS_CODE,
          p_USER_STATUS_ID           => l_CLAIMS_HISTORY_rec.USER_STATUS_ID,
          p_SALES_REP_ID             => l_CLAIMS_HISTORY_rec.SALES_REP_ID,
          p_COLLECTOR_ID             => l_CLAIMS_HISTORY_rec.COLLECTOR_ID,
          p_CONTACT_ID               => l_CLAIMS_HISTORY_rec.CONTACT_ID,
          p_BROKER_ID                => l_CLAIMS_HISTORY_rec.BROKER_ID,
          p_TERRITORY_ID             => l_CLAIMS_HISTORY_rec.TERRITORY_ID,
          p_CUSTOMER_REF_DATE        => l_CLAIMS_HISTORY_rec.CUSTOMER_REF_DATE,
          p_CUSTOMER_REF_NUMBER      => l_CLAIMS_HISTORY_rec.CUSTOMER_REF_NUMBER,
          p_ASSIGNED_TO              => l_CLAIMS_HISTORY_rec.ASSIGNED_TO,
          p_RECEIPT_ID               => l_CLAIMS_HISTORY_rec.RECEIPT_ID,
          p_RECEIPT_NUMBER           => l_CLAIMS_HISTORY_rec.RECEIPT_NUMBER,
          p_DOC_SEQUENCE_ID          => l_CLAIMS_HISTORY_rec.DOC_SEQUENCE_ID,
          p_DOC_SEQUENCE_VALUE       => l_CLAIMS_HISTORY_rec.DOC_SEQUENCE_VALUE,
          p_GL_DATE                  => l_CLAIMS_HISTORY_rec.GL_DATE,
          p_PAYMENT_METHOD           => l_CLAIMS_HISTORY_rec.PAYMENT_METHOD,
          p_VOUCHER_ID               => l_CLAIMS_HISTORY_rec.VOUCHER_ID,
          p_VOUCHER_NUMBER           => l_CLAIMS_HISTORY_rec.VOUCHER_NUMBER,
          p_PAYMENT_REFERENCE_ID     => l_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_ID,
          p_PAYMENT_REFERENCE_NUMBER => l_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_NUMBER,
          p_PAYMENT_REFERENCE_DATE   => l_CLAIMS_HISTORY_rec.PAYMENT_REFERENCE_DATE,
          p_PAYMENT_STATUS           => l_CLAIMS_HISTORY_rec.PAYMENT_STATUS,
          p_APPROVED_FLAG            => l_CLAIMS_HISTORY_rec.APPROVED_FLAG,
          p_APPROVED_DATE            => l_CLAIMS_HISTORY_rec.APPROVED_DATE,
          p_APPROVED_BY              => l_CLAIMS_HISTORY_rec.APPROVED_BY,
          p_SETTLED_DATE             => l_CLAIMS_HISTORY_rec.SETTLED_DATE,
          p_SETTLED_BY               => l_CLAIMS_HISTORY_rec.SETTLED_BY,
          p_CUSTOM_SETUP_ID          => l_claims_history_rec.CUSTOM_SETUP_ID,
          p_effective_date           => l_claims_history_rec.effective_date,
          p_TASK_ID                  => l_claims_history_rec.TASK_ID,
          p_COUNTRY_ID               => l_claims_history_rec.COUNTRY_ID,
          p_ORDER_TYPE_ID               => l_claims_history_rec.ORDER_TYPE_ID,
          p_COMMENTS                 => l_CLAIMS_HISTORY_rec.COMMENTS,
          p_LETTER_ID                => l_CLAIMS_HISTORY_rec.LETTER_ID,
          p_LETTER_DATE              => l_CLAIMS_HISTORY_rec.LETTER_DATE,
          p_TASK_SOURCE_OBJECT_ID    => l_CLAIMS_HISTORY_rec.TASK_SOURCE_OBJECT_ID,
          p_TASK_SOURCE_OBJECT_TYPE_CODE  => l_CLAIMS_HISTORY_rec.TASK_SOURCE_OBJECT_TYPE_CODE,
          p_ATTRIBUTE_CATEGORY       => l_CLAIMS_HISTORY_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_CLAIMS_HISTORY_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_CLAIMS_HISTORY_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_CLAIMS_HISTORY_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_CLAIMS_HISTORY_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_CLAIMS_HISTORY_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_CLAIMS_HISTORY_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_CLAIMS_HISTORY_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_CLAIMS_HISTORY_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_CLAIMS_HISTORY_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_CLAIMS_HISTORY_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_CLAIMS_HISTORY_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_CLAIMS_HISTORY_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_CLAIMS_HISTORY_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_CLAIMS_HISTORY_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_CLAIMS_HISTORY_rec.ATTRIBUTE15,
          p_DEDUCTION_ATTRIBUTE_CATEGORY  => l_claims_history_rec.DEDUCTION_ATTRIBUTE_CATEGORY,
          p_DEDUCTION_ATTRIBUTE1  => l_claims_history_rec.DEDUCTION_ATTRIBUTE1,
          p_DEDUCTION_ATTRIBUTE2  => l_claims_history_rec.DEDUCTION_ATTRIBUTE2,
          p_DEDUCTION_ATTRIBUTE3  => l_claims_history_rec.DEDUCTION_ATTRIBUTE3,
          p_DEDUCTION_ATTRIBUTE4  => l_claims_history_rec.DEDUCTION_ATTRIBUTE4,
          p_DEDUCTION_ATTRIBUTE5  => l_claims_history_rec.DEDUCTION_ATTRIBUTE5,
          p_DEDUCTION_ATTRIBUTE6  => l_claims_history_rec.DEDUCTION_ATTRIBUTE6,
          p_DEDUCTION_ATTRIBUTE7  => l_claims_history_rec.DEDUCTION_ATTRIBUTE7,
          p_DEDUCTION_ATTRIBUTE8  => l_claims_history_rec.DEDUCTION_ATTRIBUTE8,
          p_DEDUCTION_ATTRIBUTE9  => l_claims_history_rec.DEDUCTION_ATTRIBUTE9,
          p_DEDUCTION_ATTRIBUTE10  => l_claims_history_rec.DEDUCTION_ATTRIBUTE10,
          p_DEDUCTION_ATTRIBUTE11  => l_claims_history_rec.DEDUCTION_ATTRIBUTE11,
          p_DEDUCTION_ATTRIBUTE12  => l_claims_history_rec.DEDUCTION_ATTRIBUTE12,
          p_DEDUCTION_ATTRIBUTE13  => l_claims_history_rec.DEDUCTION_ATTRIBUTE13,
          p_DEDUCTION_ATTRIBUTE14  => l_claims_history_rec.DEDUCTION_ATTRIBUTE14,
          p_DEDUCTION_ATTRIBUTE15  => l_claims_history_rec.DEDUCTION_ATTRIBUTE15,
          p_ORG_ID                 => l_CLAIMS_HISTORY_rec.ORG_ID,
	       p_WRITE_OFF_FLAG                => l_CLAIMS_HISTORY_rec.WRITE_OFF_FLAG,
	       p_WRITE_OFF_THRESHOLD_AMOUNT    => l_CLAIMS_HISTORY_rec.WRITE_OFF_THRESHOLD_AMOUNT,
	       p_UNDER_WRITE_OFF_THRESHOLD     => l_CLAIMS_HISTORY_rec.UNDER_WRITE_OFF_THRESHOLD,
	       p_CUSTOMER_REASON               => l_CLAIMS_HISTORY_rec.CUSTOMER_REASON,
          p_SHIP_TO_CUST_ACCOUNT_ID   => l_CLAIMS_HISTORY_rec.SHIP_TO_CUST_ACCOUNT_ID,
          p_AMOUNT_APPLIED => l_claims_history_rec.AMOUNT_APPLIED,                          --Bug:2781186
          p_APPLIED_RECEIPT_ID => l_claims_history_rec.APPLIED_RECEIPT_ID,                  --Bug:2781186
          p_APPLIED_RECEIPT_NUMBER => l_claims_history_rec.APPLIED_RECEIPT_NUMBER,           --Bug:2781186
          p_WO_REC_TRX_ID          => l_CLAIMS_HISTORY_rec.WO_REC_TRX_ID,
          p_GROUP_CLAIM_ID          => l_CLAIMS_HISTORY_rec.GROUP_CLAIM_ID,
          p_APPR_WF_ITEM_KEY          => l_CLAIMS_HISTORY_rec.APPR_WF_ITEM_KEY,
          p_CSTL_WF_ITEM_KEY          => l_CLAIMS_HISTORY_rec.CSTL_WF_ITEM_KEY,
          p_BATCH_TYPE          => l_CLAIMS_HISTORY_rec.BATCH_TYPE
          );
      EXCEPTION
       WHEN OTHERS THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_TABLE_HANDLER_ERROR');
             FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
        FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO UPDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Update_claims_history;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claims_History
--
-- PURPOSE
--    This procedure validates a claim history record.
--
-- PARAMETERS
--    p_CLAIMS_HISTORY_Rec: The record that you want to validate.
--
-- NOTES:
--    Currently, there is no criteria that we need to check.
--
---------------------------------------------------------------------
PROCEDURE Validate_claims_history(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_CLAIMS_HISTORY_Rec         IN    CLAIMS_HISTORY_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Validate_claims_history';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_object_version_number   NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_CLAIMS_HISTORY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Api body
      --
      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
         FND_MSG_PUB.Add;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_api_name||': End');
         FND_MSG_PUB.Add;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO VALIDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO VALIDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
             p_data  => x_msg_data
    );
   WHEN OTHERS THEN
    ROLLBACK TO VALIDATE_CLAIMS_HISTORY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
    );
End Validate_claims_history;

End OZF_claims_history_PVT;

/
