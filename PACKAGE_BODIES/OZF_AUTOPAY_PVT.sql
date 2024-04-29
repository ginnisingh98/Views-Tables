--------------------------------------------------------
--  DDL for Package Body OZF_AUTOPAY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AUTOPAY_PVT" AS
/* $Header: ozfvatob.pls 120.9.12010000.3 2010/04/05 11:28:14 nepanda ship $ */
-- Start of Comments
-- Package name     : OZF_AUTOPAY_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'OZF_AUTOPAY_PVT';
G_UPDATE_EVENT          CONSTANT VARCHAR2(30) := 'UPDATE';
G_DAILY                 CONSTANT VARCHAR2(30) := 'DAYS';
G_WEEKLY                CONSTANT VARCHAR2(30) := 'WEEKS';
G_MONTHLY               CONSTANT VARCHAR2(30) := 'MONTHS';
G_QUARTERLY             CONSTANT VARCHAR2(30) := 'QUARTERS';
G_ANNUAL                CONSTANT VARCHAR2(30) := 'YEAR';
G_OFFER_TYPE            CONSTANT VARCHAR2(30) := 'OFFR';
G_CAMPAIGN_TYPE         CONSTANT VARCHAR2(30) := 'CAMP';
G_AUTOPAY_FLAG_OFF      CONSTANT VARCHAR2(40) := 'Autopay flag is not turned on.';
G_AUTOPAY_PERIOD_MISS   CONSTANT VARCHAR2(40) := 'Autopay period information missing.';
G_AUTOPAY_PLAN_TYPE_ERR CONSTANT VARCHAR2(40) := 'Can not hanlde this plan type.';
G_CLAIM_SETUP_ID        CONSTANT NUMBER       := 2001;
G_CLAIM_STATUS          CONSTANT VARCHAR2(30) := 'OZF_CLAIM_STATUS';
G_OPEN_STATUS           CONSTANT VARCHAR2(30) := 'OPEN';
G_CLOSED_STATUS         CONSTANT VARCHAR2(30) := 'CLOSED';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
-- Definitions of some packagewise cursors.
---------------------------------------------------------------------
CURSOR g_site_info_csr(p_id in number) IS
  SELECT trade_profile_id,
         cust_account_id,
         site_use_id,
         payment_method,
         vendor_id,
         vendor_site_id,
         last_paid_date,
         autopay_periodicity,
         autopay_periodicity_type,
         autopay_flag,
         claim_threshold,
         claim_currency,
         org_id
  FROM ozf_cust_trd_prfls_all
  WHERE site_use_id = p_id;

CURSOR g_customer_info_csr(p_id in number) IS
  SELECT trade_profile_id,
         cust_account_id,
         site_use_id,
         payment_method,
         vendor_id,
         vendor_site_id,
         last_paid_date,
         autopay_periodicity,
         autopay_periodicity_type,
         autopay_flag,
         claim_threshold,
         claim_currency,
         org_id
  FROM ozf_cust_trd_prfls
  WHERE cust_account_id = p_id
  AND site_use_id IS NULL;

CURSOR g_party_trade_info_csr(p_id in number) IS
  SELECT trade_profile_id,
         cust_account_id,
         site_use_id,
         payment_method,
         vendor_id,
         vendor_site_id,
         last_paid_date,
         autopay_periodicity,
         autopay_periodicity_type,
         autopay_flag,
         claim_threshold,
         claim_currency,
         org_id
  FROM ozf_cust_trd_prfls
  WHERE party_id = p_id
  AND cust_account_id IS NULL;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_customer_info
--
-- PURPOSE
--    This procedure validates customer info
--
-- PARAMETERS
--    p_cust_account : custome account id
--    x_days_due     : days due
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE validate_customer_info (
     p_customer_info   in  g_customer_info_csr%rowtype,
     x_return_status   OUT NOCOPY varchar2
)
IS
CURSOR csr_cust_name(cv_cust_account_id IN NUMBER) IS
  SELECT CONCAT(CONCAT(party.party_name, ' ('), CONCAT(ca.account_number, ') '))
  FROM hz_cust_accounts ca
  ,    hz_parties party
  WHERE ca.party_id = party.party_id
  AND ca.cust_account_id = cv_cust_account_id;

l_cust_account_id  number := p_customer_info.cust_account_id;
l_cust_name_num    VARCHAR2(70);

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_customer_info.claim_currency is null THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         OPEN csr_cust_name(l_cust_account_id);
         FETCH csr_cust_name INTO l_cust_name_num;
         CLOSE csr_cust_name;

         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_CURRENCY_MISS');
         FND_MESSAGE.Set_Token('ID',l_cust_name_num);
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;

   IF p_customer_info.payment_method is null THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         OPEN csr_cust_name(l_cust_account_id);
         FETCH csr_cust_name INTO l_cust_name_num;
         CLOSE csr_cust_name;

         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_PYMTHD_MISS');
         FND_MESSAGE.Set_Token('ID',l_cust_name_num);
         FND_MSG_PUB.ADD;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;

   IF p_customer_info.payment_method = 'CHECK' THEN
      IF p_customer_info.vendor_id is NULL OR
         p_customer_info.vendor_site_id is NULL  THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OPEN csr_cust_name(l_cust_account_id);
            FETCH csr_cust_name INTO l_cust_name_num;
            CLOSE csr_cust_name;

            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_VENDOR_MISS');
            FND_MESSAGE.Set_Token('ID',l_cust_name_num);
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
--nepanda : fix for bug # 9539273 - issue #2
  /* ELSIF p_customer_info.payment_method = 'CREDIT_MEMO' THEN
      IF p_customer_info.site_use_id is NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OPEN csr_cust_name(l_cust_account_id);
            FETCH csr_cust_name INTO l_cust_name_num;
            CLOSE csr_cust_name;

            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_SITEID_MISS');
            FND_MESSAGE.Set_Token('ID',l_cust_name_num);
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;*/
   END IF;

   /*
   IF p_customer_info.org_id is null THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         OPEN csr_cust_name(l_cust_account_id);
         FETCH csr_cust_name INTO l_cust_name_num;
         CLOSE csr_cust_name;

         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_ORG_ID_MISS');
         FND_MESSAGE.Set_Token('ID',l_cust_name_num);
         FND_MSG_PUB.add;
      END IF;FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END IF;
   */

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ATPY_CUSTOMER_ERR');
        FND_MSG_PUB.add;
     END IF;
END validate_customer_info;



---------------------------------------------------------------------
-- PROCEDURE
--    get_pay_date
--
-- PURPOSE
--    This procedure computes the date a payment has to be made based on last_paid_date and periodicity.
--
-- PARAMETERS
--    p_type: type of peroidicity
--    p_period: how many period
--    p_last_date: last date a payment is made
--    x_pay_date:  date a payment should be made based on the last_paid_date and periodicity
--    x_return_status
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE get_pay_date(p_type      IN VARCHAR2,
                       p_period    IN NUMBER,
                       p_last_date IN DATE,
                       x_pay_date  OUT NOCOPY DATE,
                       x_return_status OUT NOCOPY VARCHAR2
)
IS
l_return_date date;
BEGIN
  -- Initialize API return status to sucess
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_type = G_DAILY THEN
     l_return_date := p_last_date + p_period;
  ELSIF p_type = G_WEEKLY THEN
     l_return_date := p_last_date + p_period*7;
  ELSIF p_type = G_MONTHLY THEN
     l_return_date := add_months(p_last_date, p_period);
  ELSIF p_type = G_QUARTERLY THEN
     l_return_date := add_months(p_last_date, p_period*3);
--  ELSIF p_type = G_SEMI_ANNUAL THEN
--     l_return_date := add_months(p_last_date, p_period*6);
  ELSIF p_type = G_ANNUAL THEN
     l_return_date := add_months(p_last_date, p_period*12);
  ELSE
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ATPY_AUPD_MISS');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  x_pay_date := l_return_date;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END get_pay_date;

---------------------------------------------------------------------
-- PROCEDURE
--    create_claim_for_cust
--
-- PURPOSE
--    This procedure creates a claim and its lines for a customer based on the utilization table.
--    It will then settle it based on different payment method.
--
-- PARAMETERS
--    p_customer_info IN g_customer_info_csr%rowtype
--    p_amount IN number,
--    p_mode IN varchar2
--    p_auto_reason_code_id IN number
--    p_auto_claim_type_id  IN number
--    p_autopay_periodicity IN number
--    p_autopay_periodicity_type IN VARCHAR2
--    p_offer_payment_method IN VARCHAR2
--    p_funds_util_flt      IN OZF_Claim_Accrual_PVT.funds_util_flt_type
--    x_return_status       OUT VARCHAR2
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE create_claim_for_cust(
    p_customer_info            IN g_customer_info_csr%rowtype,
    p_amount                   IN number,
    p_mode                     IN varchar2,
    p_auto_reason_code_id      IN number,
    p_auto_claim_type_id       IN number,
    p_autopay_periodicity      IN number,
    p_autopay_periodicity_type IN VARCHAR2,
    p_offer_payment_method     IN VARCHAR2,
    p_funds_util_flt           IN OZF_Claim_Accrual_PVT.funds_util_flt_type,
    x_return_status            OUT NOCOPY VARCHAR2
)
IS
l_amount                   number  := p_amount;
l_cust_account_id          number;
l_last_pay_date            date;
l_claim_id                 number;
l_claim_rec                OZF_CLAIM_PVT.claim_rec_type;
l_claim_settle_rec         OZF_CLAIM_PVT.claim_rec_type;
l_funds_util_flt           OZF_Claim_Accrual_PVT.funds_util_flt_type := p_funds_util_flt;
l_plan_type                VARCHAR2(30);

CURSOR csr_cust_name(cv_cust_account_id IN NUMBER) IS
  SELECT CONCAT(CONCAT(party.party_name, ' ('), CONCAT(ca.account_number, ') '))
  FROM hz_cust_accounts ca
  ,    hz_parties party
  WHERE ca.party_id = party.party_id
  AND ca.cust_account_id = cv_cust_account_id;

l_cust_name_num    VARCHAR2(70);

CURSOR claim_info_csr(p_claim_id in number) IS
  select object_version_number, sales_rep_id
  from ozf_claims_all
  where claim_id = p_claim_id;

l_object_version_number    number;
l_return_status            varchar2(1);
l_msg_data                 varchar2(2000);
l_msg_count                number;

l_autopay_periodicity      number;
l_autopay_periodicity_type VARCHAR2(30);

CURSOR csr_ar_system_options IS
  SELECT salesrep_required_flag
  FROM ar_system_parameters;
l_salesrep_req_flag        VARCHAR2(1);
l_sales_rep_id             NUMBER;

CURSOR csr_claim_num(cv_claim_id IN NUMBER) IS
  SELECT claim_number, amount, cust_billto_acct_site_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;
l_claim_num              varchar2(30);
l_claim_amt              number;
l_cust_billto_acct_site_id              number;

l_eligible_flag          varchar2(1);

BEGIN

   IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('create_claim_for_cust START');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- For this customer: check whether there is a need to create a claim
   -- check sum of acctd_amount from utiliztion only create claims with positvit amount
   IF l_amount is NOT NULL AND l_amount > 0 THEN
      IF p_mode = 'B' THEN
         -- IF the mode is 'Backdated'
         l_eligible_flag := FND_API.g_true;
      ELSE
         IF p_customer_info.autopay_flag = FND_API.G_TRUE THEN
            -- create a claim for this customer
            IF (p_customer_info.claim_threshold is NOT NULL AND
                l_amount > p_customer_info.claim_threshold) THEN
               -- create a claim record based on l_cust_id_tbl(i).amount > l_cust_id_tbl(i).claim_threshold
               l_eligible_flag := FND_API.g_true;
            ELSE
               -- create a claim based on frequency.
               -- Need to get last pay date
               IF p_customer_info.LAST_PAID_DATE is NULL THEN
                  --  Will pay it now
                  l_last_pay_date := sysdate;
               ELSE
                  -- assign p_autopay_periodicity and p_autopay_periodicity_type
                  IF p_customer_info.autopay_periodicity_type is NULL OR
                     p_customer_info.autopay_periodicity is NULL THEN
                     IF p_autopay_periodicity is NULL OR
                        p_autopay_periodicity_type is NULL THEN
                        -- write to a log file
                        -- skip this customer
                        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                           OPEN csr_cust_name(p_customer_info.cust_account_id);
                           FETCH csr_cust_name INTO l_cust_name_num;
                           CLOSE csr_cust_name;

                           FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_PERIOD_MISS');
                           FND_MESSAGE.Set_Token('ID', l_cust_name_num);
                           FND_MSG_PUB.ADD;
                        END IF;
                        RAISE FND_API.g_exc_unexpected_error;
                        --goto end_loop;
                     END IF;
                     l_autopay_periodicity := p_autopay_periodicity;
                     l_autopay_periodicity_type := p_autopay_periodicity_type;
                  ELSE
                     l_autopay_periodicity := p_customer_info.autopay_periodicity;
                     l_autopay_periodicity_type := p_customer_info.autopay_periodicity_type;
                  END IF;
               END IF;

               IF l_last_pay_date is NULL THEN
                  -- get last pay date
                  get_pay_date(
                      p_type          => l_autopay_periodicity_type,
                      p_period        => l_autopay_periodicity,
                      p_last_date     => p_customer_info.last_paid_date,
                      x_pay_date      => l_last_pay_date,
                      x_return_status => l_return_status
                  );
                  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        OPEN csr_cust_name(p_customer_info.cust_account_id);
                        FETCH csr_cust_name INTO l_cust_name_num;
                        CLOSE csr_cust_name;

                        FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_PAY_DATE_MISS');
                        FND_MESSAGE.Set_Token('ID', l_cust_name_num);
                        FND_MSG_PUB.ADD;
                     END IF;
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;

               -- pay customer is last_pay_date has passed.
               IF l_last_pay_date <= sysdate THEN
                  -- create a claim record based on frequency
                  -- NOTE: There is not exchange info here since the functional
                  --       currency is the default claim currency.
                  l_eligible_flag := FND_API.g_true;
               END IF;
            END IF;
         END IF; -- end of if p_customer_info.autopay_flag checking
      END IF; -- end of if p_mode checking

      IF l_eligible_flag = FND_API.g_true THEN
         l_claim_rec.claim_class         := 'CLAIM';
         l_claim_rec.claim_type_id       := p_auto_claim_type_id;
         l_claim_rec.reason_code_id      := p_auto_reason_code_id;
         -- Modified for FXGL Enhancement
         -- The claim currency will be the accrual currency and not the customer
         -- currency. As no cross currency associtaion is supported
         -- For a particular accrual in X currerncy to be associated
         -- claim must also be in X currency
         l_claim_rec.currency_code       := l_funds_util_flt.utiz_currency_code;
         l_claim_rec.cust_account_id     := p_customer_info.cust_account_id;
         l_claim_rec.cust_billto_acct_site_id := p_customer_info.site_use_id;
         l_claim_rec.vendor_id           := p_customer_info.vendor_id;
         l_claim_rec.vendor_site_id      := p_customer_info.vendor_site_id;
         -- offer's payment method overrides trade profile
	 --nepanda : fix for bug # 9539273 - issue #3
	 --Added G_MISS_CHAR check and assigned null to payment method in case both offer and trade profile payment methods are null or G_MISS_CHAR
         /*IF p_offer_payment_method IS NOT NULL THEN
            l_claim_rec.payment_method   := p_offer_payment_method;
         ELSE
            l_claim_rec.payment_method   := p_customer_info.payment_method;
         END IF;*/
	 IF p_offer_payment_method IS NOT NULL AND
	    p_offer_payment_method <> FND_API.G_MISS_CHAR THEN
		l_claim_rec.payment_method   := p_offer_payment_method;
         ELSIF p_customer_info.payment_method IS NOT NULL AND
	       p_customer_info.payment_method <> FND_API.G_MISS_CHAR THEN
	            l_claim_rec.payment_method   := p_customer_info.payment_method;
	 ELSE
		    l_claim_rec.payment_method   := NULL;
         END IF;
         l_claim_rec.created_from        := 'AUTOPAY';

         l_funds_util_flt.cust_account_id := p_customer_info.cust_account_id;
         IF p_offer_payment_method IS NOT NULL THEN
            l_funds_util_flt.offer_payment_method := p_offer_payment_method;
         ELSE
            l_funds_util_flt.offer_payment_method := 'NULL';
         END IF;

         OZF_CLAIM_ACCRUAL_PVT.Create_Claim_For_Accruals(
            p_api_version         => 1.0
           ,p_init_msg_list       => FND_API.g_false
           ,p_commit              => FND_API.g_false
           ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
           ,x_return_status       => l_return_status
           ,x_msg_count           => l_msg_count
           ,x_msg_data            => l_msg_data
           ,p_claim_rec           => l_claim_rec
           ,p_funds_util_flt      => l_funds_util_flt
           ,x_claim_id            => l_claim_id
         );
         IF l_return_status <> FND_API.g_ret_sts_success THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
         END IF;

         IF l_claim_id is not NULL THEN
            -- update to settle the claim
            OPEN claim_info_csr(l_claim_id);
            FETCH claim_info_csr into l_object_version_number, l_sales_rep_id;
            CLOSE claim_info_csr;

            l_claim_settle_rec.claim_id              := l_claim_id;
            l_claim_settle_rec.object_version_number := l_object_version_number;
            l_claim_settle_rec.USER_STATUS_ID        := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                              P_STATUS_TYPE=> G_CLAIM_STATUS,
                                                              P_STATUS_CODE=> G_CLOSED_STATUS
                                                          ));

            ------------------------------------------------------
            -- Sales Credit
            --   Bug 2950241 fixing: default Sales Rep in Claims
            --   if "Requires Salesperson" in AR system options.
            ------------------------------------------------------
            IF l_sales_rep_id IS NULL THEN
               OPEN csr_ar_system_options;
               FETCH csr_ar_system_options INTO l_salesrep_req_flag;
               CLOSE csr_ar_system_options;

               IF l_salesrep_req_flag = 'Y' THEN
                  l_claim_settle_rec.sales_rep_id := -3;  -- No Sales Credit
               END IF;
            END IF;

            OZF_claim_PVT.Update_claim(
               P_Api_Version                => 1.0,
               P_Init_Msg_List              => FND_API.G_FALSE,
               P_Commit                     => FND_API.G_FALSE,
               P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
               X_Return_Status              => l_return_status,
               X_Msg_Count                  => l_msg_count,
               X_Msg_Data                   => l_msg_data,
               P_claim                      => l_claim_settle_Rec,
               p_event                      => 'UPDATE',
               p_mode                       => OZF_claim_Utility_pvt.G_AUTO_MODE,
               X_Object_Version_Number      => l_object_version_number
            );
            IF l_return_status <> FND_API.g_ret_sts_success THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            END IF;
         END IF;

      ELSE
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OPEN csr_cust_name(p_customer_info.cust_account_id);
            FETCH csr_cust_name INTO l_cust_name_num;
            CLOSE csr_cust_name;

            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_CUST_INELIG');
            FND_MESSAGE.Set_Token('ID', l_cust_name_num);
            FND_MSG_PUB.ADD;
         END IF;
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         OPEN csr_cust_name(p_customer_info.cust_account_id);
         FETCH csr_cust_name INTO l_cust_name_num;
         CLOSE csr_cust_name;

         FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_AMT_SMALL');
         FND_MESSAGE.Set_Token('ID', l_cust_name_num);
         FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OPEN csr_claim_num(l_claim_id);
   FETCH csr_claim_num INTO l_claim_num, l_claim_amt,l_cust_billto_acct_site_id;
   CLOSE csr_claim_num;


   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Number: '||l_claim_num);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Amount: '||l_claim_amt);

   IF l_cust_billto_acct_site_id IS NOT NULL
   OR l_cust_billto_acct_site_id<>0 THEN

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'The claim is created for bill_to site: '||l_cust_billto_acct_site_id);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'The claim is created for bill_to site: '|| l_cust_billto_acct_site_id );

   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim Number               : '||l_claim_num );
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim Amount               : '||l_claim_amt );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
END create_claim_for_cust;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_for_BD_Offer
--
-- PURPOSE
--    Create a claim for a backdated offer.
--
-- PARAMETERS
--    p_offer_tbl : list of offers info that a claim will be created on.
--
---------------------------------------------------------------------
PROCEDURE  Create_Claim_for_BD_Offer(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_offer_tbl              IN    offer_tbl_type
)
IS
l_return_status           varchar2(1);
l_msg_data                varchar2(2000);
l_msg_count               number;

l_api_name       CONSTANT VARCHAR2(30) := 'Create_Claim_for_BD_Offer';
l_api_version    CONSTANT NUMBER := 1.0;
l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

CURSOR sys_parameter_info_csr IS
SELECT autopay_flag
,      autopay_reason_code_id
,      autopay_claim_type_id
,      autopay_periodicity
,      autopay_periodicity_type
FROM ozf_sys_parameters;

l_autopay_flag             varchar2(1);
l_auto_reason_code_id      number;
l_auto_claim_type_id       number;
l_autopay_periodicity      number;
l_autopay_periodicity_type VARCHAR2(30);
l_cust_account_id          number;
l_amount                   number;

CURSOR settlement_method_CSR(p_id in number) is
  select settlement_code
  from ozf_offer_adjustments_b
  where list_header_id = p_id;

l_customer_info g_customer_info_csr%rowtype;
l_funds_util_flt           OZF_CLAIM_ACCRUAL_PVT.funds_util_flt_type   := NULL;

BEGIN

SAVEPOINT BDOffer;

-- Debug Message
IF OZF_DEBUG_LOW_ON THEN
   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
   FND_MSG_PUB.Add;
END IF;

-- get autopay_flag, reason_code_id
OPEN sys_parameter_info_csr;
FETCH sys_parameter_info_csr INTO l_autopay_flag
                                , l_auto_reason_code_id
                                , l_auto_claim_type_id
                                , l_autopay_periodicity
                                , l_autopay_periodicity_type;
CLOSE sys_parameter_info_csr;

-- check reason_code and claim_type from sys_parameters.
IF l_auto_reason_code_id is NULL THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_REASON_CD_MISSING');
      FND_MSG_PUB.add;
   END IF;
   RAISE FND_API.g_exc_unexpected_error;
END IF;

IF l_auto_claim_type_id is NULL THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CLAIM_TYPE_MISSING');
      FND_MSG_PUB.add;
   END IF;
   RAISE FND_API.g_exc_unexpected_error;
END IF;

-- Loop through p_offer table
For i in p_offer_tbl.FIRST..p_offer_tbl.COUNT LOOP
   IF l_cust_account_id is not null THEN
      -- Get customer information
      OPEN g_customer_info_csr(l_cust_account_id);
      FETCH g_customer_info_csr into l_customer_info;
      CLOSE g_customer_info_csr;

      validate_customer_info (
              p_customer_info => l_customer_info,
              x_return_status => l_return_status
      );
      -- skip this customer if we can not get all the info.
      IF l_return_status = FND_API.g_ret_sts_error or
         l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
         --goto end_loop;
      END IF;

      -- But, we need to overwrite the payment method for the customer;
      OPEN settlement_method_CSR(p_offer_tbl(i).offer_id);
      FETCH settlement_method_CSR into l_customer_info.payment_method;
      CLOSE settlement_method_CSR;

      l_funds_util_flt := null;
      l_funds_util_flt.activity_id := p_offer_tbl(i).offer_id;
      l_funds_util_flt.activity_type := G_OFFER_TYPE;
      l_funds_util_flt.adjustment_type_id := p_offer_tbl(i).adjustment_type_id;

      create_claim_for_cust(p_customer_info       => l_customer_info,
                            p_amount              => p_offer_tbl(i).amount,
                            p_mode                => 'B',
                            p_auto_reason_code_id => l_auto_reason_code_id,
                            p_auto_claim_type_id  => l_auto_claim_type_id,
                            p_autopay_periodicity => l_autopay_periodicity,
                            p_autopay_periodicity_type => l_autopay_periodicity_type,
                            p_offer_payment_method=> null,
                            p_funds_util_flt       => l_funds_util_flt,
                            x_return_status       => l_return_status
                           );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;
END LOOP;

-- Debug Message
IF OZF_DEBUG_LOW_ON THEN
   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
   FND_MSG_PUB.Add;
END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO BDOffer;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO BDOffer;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO BDOffer;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => l_msg_count
        ,p_data    => l_msg_data
    );
END Create_claim_for_bd_offer;


--------------------------------------------------------------------------------
--    API name   : Start_Autopay
--    Type       : Public
--    Pre-reqs   : None
--    Function   :
--    Parameters :
--
--    IN         : p_run_mode                       IN VARCHAR2  Optional
--               : p_customer_id                    IN NUMBER    Optional
--               : p_relationship_type              IN VARCHAR2   Optional
--               : p_related_cust_account_id        IN NUMBER     Optional
--               : p_buy_group_party_id             IN NUMBER     Optional
--               : p_select_cust_children_flag      IN VARCHAR2   Optional
--               : p_pay_to_customer                IN VARCHAR2   Optional
--               : p_fund_id                        IN NUMBER    Optional
--               : p_plan_type                      IN NUMBER    Optional
--               : p_offer_type                     IN VARCHAR2  Optional
--               : p_plan_id                        IN NUMBER    Optional
--               : p_product_category_id            IN NUMBER    Optional
--               : p_product_id                     IN NUMBER    Optional
--               : p_end_date                       IN VARCHAR2  Optional
--               : p_org_id                         IN NUMBER    Optional
--
--    Version    : Current version     1.0
--
--   Note: This program automatically creates a claim for a set of customers
--   The customer set is selected based on the input paramter. Also, we will pay a cusomter:
--       if a customer utiliztion amount summation is greater than his threshold_amount
--   or if the current date passes last_paid_date + threshold period.
--   End of Comments
--------------------------------------------------------------------------------
PROCEDURE Start_Autopay (
    ERRBUF                          OUT NOCOPY VARCHAR2,
    RETCODE                         OUT NOCOPY NUMBER,
    p_org_id                        IN NUMBER  DEFAULT NULL,
    p_run_mode                      IN VARCHAR2 := NULL,
    p_customer_id                   IN NUMBER   := NULL,
    p_relationship_type             IN VARCHAR2 := NULL,
    p_related_cust_account_id       IN NUMBER   := NULL,
    p_buy_group_party_id            IN NUMBER   := NULL,
    p_select_cust_children_flag     IN VARCHAR2  := 'N',
    p_pay_to_customer               IN VARCHAR2 := NULL,
    p_fund_id                       IN NUMBER   := NULL,
    p_plan_type                     IN VARCHAR2 := NULL,
    p_offer_type                    IN VARCHAR2 := NULL,
    p_plan_id                       IN NUMBER   := NULL,
    p_product_category_id           IN NUMBER   := NULL,
    p_product_id                    IN NUMBER   := NULL,
    p_end_date                      IN VARCHAR2,
    p_group_by_offer                IN VARCHAR2
)
IS
l_return_status          varchar2(1);
l_msg_data               varchar2(2000);
l_msg_count              number;

l_api_name      CONSTANT VARCHAR2(30) := 'Start_Autopay';
l_api_version   CONSTANT NUMBER := 1.0;
l_full_name     CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

CURSOR sys_parameter_info_csr IS
SELECT autopay_flag
,      autopay_reason_code_id
,      autopay_claim_type_id
,      autopay_periodicity
,      autopay_periodicity_type
FROM ozf_sys_parameters;
l_autopay_flag             varchar2(1);
l_auto_reason_code_id      number;
l_auto_claim_type_id       number;
l_autopay_periodicity      number;
l_autopay_periodicity_type VARCHAR2(30);
l_run_mode                  VARCHAR2(80);
l_pay_to                  VARCHAR2(80);
l_rel_cust_name             VARCHAR2(70);
l_cust_name             VARCHAR2(70);
l_rlship                   VARCHAR2(80);
l_fund_name                VARCHAR2(240);
l_plan_type_name           VARCHAR2(240);
l_plan_name                VARCHAR2(240);
l_prod_cat_name                VARCHAR2(240);
l_prod_name                VARCHAR2(240);
l_buy_gp_name             VARCHAR2(70);
l_members_flag                  VARCHAR2(80);
l_offer_type_name               VARCHAR2(80);

l_bill_to_site_use_id      NUMBER;
l_prev_site_use_id         NUMBER;

CURSOR csr_meaning(lkup_type IN VARCHAR2, lkup_code IN VARCHAR2) IS
SELECT MEANING
FROM OZF_LOOKUPS
WHERE lookup_type = lkup_type
AND LOOKUP_CODE = lkup_code;

CURSOR csr_rlship(lkup_code IN VARCHAR2) IS
SELECT ar.MEANING
FROM ar_lookups ar
WHERE ar.lookup_type = 'RELATIONSHIP_TYPE'
AND ar.lookup_code = lkup_code;

CURSOR csr_members(lkup_type IN VARCHAR2, lkup_code IN VARCHAR2) IS
SELECT MEANING
FROM FND_LOOKUPS
WHERE lookup_type = lkup_type
AND LOOKUP_CODE = lkup_code;

CURSOR csr_fund_name(p_fund_id IN NUMBER) IS
SELECT f.SHORT_NAME
FROM OZF_FUNDS_VL f
WHERE f.FUND_ID = p_fund_id;

CURSOR csr_offer_name(off_id IN NUMBER) IS
SELECT QP.DESCRIPTION
FROM QP_LIST_HEADERS_VL qp
WHERE qp.list_header_id = off_id;

CURSOR csr_prod_cat_name(prod_cat_id IN NUMBER) IS
SELECT  MCT.DESCRIPTION
FROM MTL_CATEGORIES_TL MCT
WHERE  MCT.CATEGORY_ID = prod_cat_id;

CURSOR csr_prod_name(p_product_id IN NUMBER) IS
SELECT DESCRIPTION
FROM MTL_SYSTEM_ITEMS_KFV
WHERE INVENTORY_ITEM_ID = p_product_id
AND organization_id = FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

CURSOR csr_cust_name(cv_cust_account_id IN NUMBER) IS
  SELECT CONCAT(CONCAT(party.party_name, ' ('), CONCAT(ca.account_number, ') '))
  FROM hz_cust_accounts ca
  ,    hz_parties party
  WHERE ca.party_id = party.party_id
  AND ca.cust_account_id = cv_cust_account_id;

CURSOR csr_get_party_id(cv_cust_account_id IN NUMBER) IS
  SELECT party_id
  FROM hz_cust_accounts
  WHERE cust_account_id = cv_cust_account_id;

CURSOR csr_party_name(cv_party_id IN NUMBER) IS
  SELECT party_name
  FROM hz_parties
  WHERE party_id = cv_party_id;

CURSOR csr_offer_pay_name(cv_payment_method IN VARCHAR2) IS
  SELECT meaning
  FROM ozf_lookups
  WHERE lookup_type = 'OZF_AUTOPAY_METHOD'
  AND lookup_code = cv_payment_method;

--Multiorg Changes
CURSOR operating_unit_csr IS
    SELECT ou.organization_id   org_id
    FROM hr_operating_units ou
    WHERE mo_global.check_access(ou.organization_id) = 'Y';

TYPE EmpCurType IS REF CURSOR;
l_emp_csr                  NUMBER; --EmpCurType;

l_stmt                     VARCHAR2(3000);
l_funds_util_flt           OZF_CLAIM_ACCRUAL_PVT.funds_util_flt_type   := NULL;

l_cust_account_id          number;
l_amount                   number;
l_customer_info            g_customer_info_csr%rowtype;
l_cust_name_num            VARCHAR2(70);
l_offer_pay_method         VARCHAR2(30);
l_offer_pay_name           VARCHAR2(80);
l_party_id                 NUMBER;
l_trade_prf_exist          BOOLEAN   := FALSE;
l_ignore                   NUMBER;

l_cust_info_invalid        BOOLEAN   := FALSE;
l_prev_cust_account_id     NUMBER;
l_utiz_currency            VARCHAR2(15);

TYPE  trd_prf_tbl_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;
l_trd_prof_tbl  trd_prf_tbl_type;
i                BINARY_INTEGER := 1;

l_plan_id                  NUMBER;

--Multiorg Changes
m NUMBER := 0;
l_org_id     OZF_UTILITY_PVT.operating_units_tbl;

l_currency_rec             OZF_CLAIM_ACCRUAL_PVT.currency_rec_type;
BEGIN

SAVEPOINT AutoPay;

FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------ Claims Autopay Execution Report ------------------------------*');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

-- Debug Message
IF OZF_DEBUG_LOW_ON THEN
   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
   FND_MSG_PUB.Add;
END IF;

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
      BEGIN
        MO_GLOBAL.set_policy_context('S',l_org_id(m));
            -- Write OU info to OUT file
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '-----------------------------------------------------');
            -- Write OU info to LOG file
            FND_FILE.PUT_LINE(FND_FILE.LOG,  'Operating Unit: ' || MO_GLOBAL.get_ou_name(l_org_id(m)));
            FND_FILE.PUT_LINE(FND_FILE.LOG,  '-----------------------------------------------------');

                IF p_run_mode IS NOT NULL THEN
                   OPEN csr_meaning('OZF_CLAIM_AUTOPAY_RUNMODE', p_run_mode);
                   FETCH csr_meaning INTO l_run_mode;
                   CLOSE csr_meaning;
                END IF;

                IF p_customer_id IS NOT NULL THEN
                   OPEN csr_cust_name(p_customer_id);
                   FETCH csr_cust_name INTO l_cust_name;
                   CLOSE csr_cust_name;

                   IF p_relationship_type IS NOT NULL THEN
                          OPEN csr_rlship(p_relationship_type);
                          FETCH csr_rlship INTO l_rlship;
                          CLOSE csr_rlship;

                          IF p_related_cust_account_id IS NOT NULL THEN
                         OPEN csr_cust_name(p_related_cust_account_id);
                         FETCH csr_cust_name INTO l_rel_cust_name;
                         CLOSE csr_cust_name;

                         IF p_pay_to_customer IS NOT NULL THEN
                                OPEN csr_meaning('OZF_CLAIM_PAYTO_TYPE', p_pay_to_customer);
                                FETCH csr_meaning INTO l_pay_to;
                                CLOSE csr_meaning;
                         END IF;

                          END IF;

                   END IF;

                   IF p_buy_group_party_id IS NOT NULL THEN
                          OPEN csr_party_name(p_buy_group_party_id);
                          FETCH csr_party_name INTO l_buy_gp_name;
                          CLOSE csr_party_name;
                   END IF;

                   IF p_select_cust_children_flag IS NOT NULL THEN
                          OPEN csr_members('YES_NO', p_select_cust_children_flag);
                          FETCH csr_members INTO l_members_flag;
                          CLOSE csr_members;
                   END IF;

                END IF;

                IF p_fund_id IS NOT NULL THEN
                   OPEN csr_fund_name(p_fund_id);
                   FETCH csr_fund_name INTO l_fund_name;
                   CLOSE csr_fund_name;
                END IF;

                IF p_plan_type IS NOT NULL THEN
                   OPEN csr_meaning('OZF_CLAIM_ASSO_ACT_TYPE', p_plan_type);
                   FETCH csr_meaning INTO l_plan_type_name;
                   CLOSE csr_meaning;

                   IF p_plan_id IS NOT NULL THEN
                          OPEN csr_offer_name(p_plan_id);
                          FETCH csr_offer_name INTO l_plan_name;
                          CLOSE csr_offer_name;
                   END IF;
                END IF;

                IF p_offer_type IS NOT NULL THEN
                   OPEN csr_meaning('OZF_OFFER_TYPE', p_offer_type);
                   FETCH csr_meaning INTO l_offer_type_name;
                   CLOSE csr_meaning;
                END IF;

                IF p_product_category_id IS NOT NULL THEN
                   OPEN csr_prod_cat_name(p_product_category_id);
                   FETCH csr_prod_cat_name INTO l_prod_cat_name;
                   CLOSE csr_prod_cat_name;
                END IF;

                IF p_product_id IS NOT NULL THEN
                   OPEN csr_prod_name(p_product_id);
                   FETCH csr_prod_name INTO l_prod_name;
                   CLOSE csr_prod_name;
                END IF;

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Run Mode', 40, ' ') || ': ' || l_run_mode);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Customer Name', 40, ' ') || ': '|| l_cust_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Relationship', 40, ' ') || ': ' || l_rlship);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Related Customer', 40, ' ') || ': ' || l_rel_cust_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Buying Group and Members', 40, ' ') || ': ' || l_buy_gp_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Include All Member Earnings', 40, ' ') || ': ' || l_members_flag);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Pay To', 40, ' ') || ': ' || l_pay_to);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Fund Name', 40, ' ') || ': ' || l_fund_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Activity Type', 40, ' ') || ': ' || l_plan_type_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Offer Type', 40, ' ') || ': ' || l_offer_type_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Activity Name', 40, ' ') || ': ' || l_plan_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Product Category', 40, ' ') || ': ' || l_prod_cat_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Product', 40, ' ') || ': ' || l_prod_name);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('End Date', 40, ' ') || ': ' || p_end_date);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('Group By Offer', 40, ' ') || ': ' || p_group_by_offer);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

                   /*------------ Autopay starts ---------------*/

                   -- get autopay_flag, reason_code_id
                   OPEN sys_parameter_info_csr;
                   FETCH sys_parameter_info_csr INTO l_autopay_flag
                                                   , l_auto_reason_code_id
                                                   , l_auto_claim_type_id
                                                   , l_autopay_periodicity
                                                   , l_autopay_periodicity_type;
                   CLOSE sys_parameter_info_csr;

                   -- check reason_code and claim_type from sys_parameters.
                   IF l_auto_reason_code_id is NULL THEN
                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_REASON_CD_MISSING');
                         FND_MSG_PUB.add;
                          END IF;
                          RAISE FND_API.g_exc_unexpected_error;
                   END IF;

                   IF l_auto_claim_type_id is NULL THEN
                          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CLAIM_TYPE_MISSING');
                         FND_MSG_PUB.add;
                          END IF;
                          RAISE FND_API.g_exc_unexpected_error;
                   END IF;

                   -- construct the following sql based on the inputs
                   l_funds_util_flt.run_mode := p_run_mode;
                   l_funds_util_flt.utilization_type := null;
                   l_funds_util_flt.offer_type := p_offer_type;
                   l_funds_util_flt.activity_type := p_plan_type;
                   l_funds_util_flt.activity_id := p_plan_id;
                   l_funds_util_flt.fund_id := p_fund_id;
                   l_funds_util_flt.adjustment_type_id := null;
                   IF p_product_id IS NOT NULL THEN
                          l_funds_util_flt.product_level_type := 'PRODUCT';
                          l_funds_util_flt.product_id := p_product_id;
                   ELSIF p_product_category_id IS NOT NULL THEN
                          l_funds_util_flt.product_level_type := 'FAMILY';
                          l_funds_util_flt.product_id := p_product_category_id;
                   END IF;

                   -- additional filter conditions
                   l_funds_util_flt.cust_account_id := p_customer_id;
                   l_funds_util_flt.relationship_type := p_relationship_type;
                   l_funds_util_flt.related_cust_account_id := p_related_cust_account_id;
                   l_funds_util_flt.buy_group_party_id := p_buy_group_party_id;
                   l_funds_util_flt.select_cust_children_flag := p_select_cust_children_flag;
                   l_funds_util_flt.pay_to_customer := p_pay_to_customer;
                   l_funds_util_flt.end_date := FND_DATE.CANONICAL_TO_DATE(p_end_date);
                   l_funds_util_flt.group_by_offer := NVL(p_group_by_offer,'N'); --R12

                   -- Changes for FXGL Enhancement
           -- l_funds_util_flt.utiz_currency_code is null here
                   -- and all currency records are retrieved but they are
                   -- grouped by currency_code
                   -- The amount_remaining is in utiz_curency and not in functional currency
                   -- Added For Multi Currency - kpatro
                   l_funds_util_flt.autopay_check := 'AUTOPAY'; --R12

                   --//Populating Currency record set
                   l_currency_rec.universal_currency_code   := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

                   OZF_Claim_Accrual_Pvt.Get_Utiz_Sql_Stmt(
                          p_api_version         => 1.0
                         ,p_init_msg_list       => FND_API.g_false
                         ,p_commit              => FND_API.g_false
                         ,p_validation_level    => FND_API.g_valid_level_full
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data
                         ,p_summary_view        => 'AUTOPAY'
                         ,p_funds_util_flt      => l_funds_util_flt
                         ,px_currency_rec       => l_currency_rec
                         ,p_cust_account_id     => p_customer_id
                         ,x_utiz_sql_stmt       => l_stmt
                   );

                   IF l_return_status <> FND_API.g_ret_sts_success THEN
                          RAISE FND_API.g_exc_error;
                   END IF;

                   -- log query for debugging
                   IF OZF_DEBUG_LOW_ON THEN
                          OZF_UTILITY_PVT.write_conc_log;
                   END IF;

                   l_emp_csr := DBMS_SQL.open_cursor;
                   FND_DSQL.set_cursor(l_emp_csr);
                   DBMS_SQL.parse(l_emp_csr, l_stmt, DBMS_SQL.native);
                   DBMS_SQL.define_column(l_emp_csr, 1, l_offer_pay_method, 30);
                   DBMS_SQL.define_column(l_emp_csr, 2, l_amount);
                   DBMS_SQL.define_column(l_emp_csr, 3, l_utiz_currency, 15 );


                         --R12.1 enhancement add l_bill_to_site_use_id and fetch its value
                         -- This will be used to group the customer earnings.
                   DBMS_SQL.define_column(l_emp_csr, 4, l_bill_to_site_use_id );


                   IF p_customer_id IS NULL THEN
                          DBMS_SQL.define_column(l_emp_csr, 5, l_cust_account_id);
                   END IF;

                   IF NVL(p_group_by_offer,'N') = 'Y'  AND p_customer_id IS NULL THEN
                          DBMS_SQL.define_column(l_emp_csr, 6, l_plan_id);
                   ELSIF NVL(p_group_by_offer,'N') = 'Y' AND p_customer_id IS NOT NULL THEN
                         DBMS_SQL.define_column(l_emp_csr, 5, l_plan_id);
                   END IF;

                   FND_DSQL.do_binds;

                   l_ignore := DBMS_SQL.execute(l_emp_csr);
                   LOOP
                          FND_MSG_PUB.initialize;

                          IF DBMS_SQL.fetch_rows(l_emp_csr) > 0 THEN
                         DBMS_SQL.column_value(l_emp_csr, 1, l_offer_pay_method);
                         DBMS_SQL.column_value(l_emp_csr, 2, l_amount);
                         DBMS_SQL.column_value(l_emp_csr, 3, l_utiz_currency);
                         DBMS_SQL.column_value(l_emp_csr, 4, l_bill_to_site_use_id); --R12.1 enhancement nirprasa

                         IF p_customer_id IS NULL THEN
                                DBMS_SQL.column_value(l_emp_csr, 5, l_cust_account_id);
                         ELSE
                                l_cust_account_id := p_customer_id;
                         END IF;

                         IF NVL(p_group_by_offer,'N') = 'Y'  AND p_customer_id IS NULL THEN
                                DBMS_SQL.column_value(l_emp_csr, 6, l_plan_id);
                                l_funds_util_flt.activity_id := l_plan_id;
                         ELSIF NVL(p_group_by_offer,'N') = 'Y' AND p_customer_id IS NOT NULL THEN
                                DBMS_SQL.column_value(l_emp_csr, 5, l_plan_id);
                                l_funds_util_flt.activity_id := l_plan_id;
                         -- Fix for multi currency --kpatro
                         ELSIF (NVL(p_group_by_offer,'N') = 'N' AND p_customer_id IS NOT NULL  AND p_plan_id IS NOT NULL) THEN
                                l_funds_util_flt.activity_id := p_plan_id;
                         ELSE
                                l_funds_util_flt.activity_id := NULL;
                         END IF;

            -- FXGL Enhancement : Add utiz_currency_code to l_funds_util_flt
            -- This is a required filter
            -- This will ensure assoc happens for each currency line

               l_funds_util_flt.utiz_currency_code := l_utiz_currency;


                         -- In case of buying group/related customer accruals,
                         -- the amount can be paid either to buying group/related customer or
                         -- to claiming customer based on p_pay_to_customer.
                         IF p_pay_to_customer = 'RELATED'
                         THEN
                                IF p_related_cust_account_id IS NOT NULL THEN
                                   l_cust_account_id := p_related_cust_account_id;
                                END IF;
                         END IF;

                         BEGIN
                         SAVEPOINT AUTOPAY_CUST;

                         IF l_cust_account_id is not null THEN

                         --R12.1 enhancement the call should once per site instead of onec per account.



                          /*IF  l_prev_cust_account_id IS NULL OR
                                           l_cust_account_id <> l_prev_cust_account_id THEN*/

                           IF  l_prev_site_use_id IS NULL OR
                                     l_bill_to_site_use_id <> l_prev_site_use_id THEN

                                 l_cust_name_num := NULL;
                                 l_customer_info := NULL;
                                 l_party_id := NULL;

                                -- Get customer information for log message purpose
                                OPEN csr_cust_name(l_cust_account_id);
                                FETCH csr_cust_name INTO l_cust_name_num;
                                CLOSE csr_cust_name;


                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, rpad('l_bill_to_site_use_id', 40, ' ') || ': ' || l_bill_to_site_use_id);

                                -- 1. get trade profile by site_use_id
                                OPEN g_site_info_csr(l_bill_to_site_use_id);
                                FETCH g_site_info_csr into l_customer_info;
                                IF g_site_info_csr%NOTFOUND THEN
                                   l_trade_prf_exist := FALSE;
                                ELSE
                                   l_trade_prf_exist := TRUE;
                                END IF;
                                CLOSE g_site_info_csr;

                                -- 2. if trade profile is not there for site,
                                --    then get trade profile by account level
                                IF NOT l_trade_prf_exist THEN




                                OPEN g_customer_info_csr(l_cust_account_id);
                                FETCH g_customer_info_csr into l_customer_info;
                                IF g_customer_info_csr%NOTFOUND THEN
                                   l_trade_prf_exist := FALSE;
                                ELSE
                                   l_trade_prf_exist := TRUE;
                                END IF;
                                CLOSE g_customer_info_csr;

                                END IF;

                                -- 3. if trade profile is not there for customer,
                                --    then get trade profile by party_id level
                                IF NOT l_trade_prf_exist THEN
                                   OPEN csr_get_party_id(l_cust_account_id);
                                   FETCH csr_get_party_id INTO l_party_id;
                                   CLOSE csr_get_party_id;

                                   IF l_party_id IS NOT NULL THEN
                                          OPEN g_party_trade_info_csr(l_party_id);
                                          FETCH g_party_trade_info_csr INTO l_customer_info;
                                          IF g_party_trade_info_csr%NOTFOUND THEN
                                         l_trade_prf_exist := FALSE;
                                          ELSE
                                         l_trade_prf_exist := TRUE;
                                          END IF;
                                          CLOSE g_party_trade_info_csr;
                                   END IF;
                                END IF;

                                l_customer_info.cust_account_id := l_cust_account_id;

                                -- Added For Multi Currency - kpatro
                                l_customer_info.claim_currency := l_utiz_currency;
                                validate_customer_info (
                                          p_customer_info => l_customer_info,
                                          x_return_status => l_return_status
                                  );
                                 -- skip this customer if we can not get all the info.
                                IF l_return_status = FND_API.g_ret_sts_error or
                                         l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                        l_cust_info_invalid := true;
                                ELSE
                                        l_cust_info_invalid := FALSE;
                                END IF;

                                END IF;
                                l_prev_site_use_id := l_bill_to_site_use_id;

                                IF p_customer_id IS NULL THEN
                                   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Customer Name : '||l_cust_name_num );
                                END IF;
                                IF l_offer_pay_method IS NOT NULL THEN
                                   OPEN csr_offer_pay_name(l_offer_pay_method);
                                   FETCH csr_offer_pay_name INTO l_offer_pay_name;
                                   CLOSE csr_offer_pay_name;
                                   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Offer Payment Method: '||l_offer_pay_name);
                                END IF;

                                IF l_cust_info_invalid THEN
                                   RAISE FND_API.g_exc_unexpected_error;
                                END IF;

                                IF l_trade_prf_exist THEN

                                   IF l_customer_info.autopay_flag = FND_API.g_true THEN
                                   l_funds_util_flt.bill_to_site_use_id := l_bill_to_site_use_id; --R12.1 enhancements
                                  /*
                                  l_funds_util_flt.run_mode := p_run_mode;
                   l_funds_util_flt.utilization_type := null;
                   l_funds_util_flt.offer_type := p_offer_type;
                   l_funds_util_flt.activity_type := p_plan_type;
                   l_funds_util_flt.activity_id := p_plan_id;
                   l_funds_util_flt.fund_id := p_fund_id;
                   l_funds_util_flt.adjustment_type_id := null;
                   IF p_product_id IS NOT NULL THEN
                          l_funds_util_flt.product_level_type := 'PRODUCT';
                          l_funds_util_flt.product_id := p_product_id;
                   ELSIF p_product_category_id IS NOT NULL THEN
                          l_funds_util_flt.product_level_type := 'FAMILY';
                          l_funds_util_flt.product_id := p_product_category_id;
                   END IF;

                   -- additional filter conditions
                   l_funds_util_flt.cust_account_id := p_customer_id;
                   l_funds_util_flt.relationship_type := p_relationship_type;
                   l_funds_util_flt.related_cust_account_id := p_related_cust_account_id;
                   l_funds_util_flt.buy_group_party_id := p_buy_group_party_id;
                   l_funds_util_flt.select_cust_children_flag := p_select_cust_children_flag;
                   l_funds_util_flt.pay_to_customer := p_pay_to_customer;
                   l_funds_util_flt.end_date := FND_DATE.CANONICAL_TO_DATE(p_end_date);
                   l_funds_util_flt.group_by_offer := NVL(p_group_by_offer,'N'); --R12
                                  */

                                  FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Start AUTOPAY for customer '||l_cust_name_num||' ---*/');
                                  create_claim_for_cust(p_customer_info            => l_customer_info,
                                                        p_amount                   => l_amount,
                                                        p_mode                     => 'N',
                                                        p_auto_reason_code_id      => l_auto_reason_code_id,
                                                        p_auto_claim_type_id       => l_auto_claim_type_id,
                                                        p_autopay_periodicity      => l_autopay_periodicity,
                                                        p_autopay_periodicity_type => l_autopay_periodicity_type,
                                                        p_offer_payment_method     => l_offer_pay_method,
                                                        p_funds_util_flt           => l_funds_util_flt,
                                                        x_return_status            => l_return_status
                                  );
                                  IF l_return_status = FND_API.g_ret_sts_error THEN
                                  RAISE FND_API.g_exc_error;
                          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                                  RAISE FND_API.g_exc_unexpected_error;
                          END IF;

                                  -- Store Trade Profile for later updation
                                  IF  l_trade_prf_exist THEN
                                           l_trd_prof_tbl(i) := l_customer_info.trade_profile_id;
                                  END IF;

                                  --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Claim Amount = '||l_amount);
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Success.');
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Claim Amount               : '||l_amount );
                                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Success. ');
                                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                                  OZF_UTILITY_PVT.write_conc_log;
                                   ELSE
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Start AUTOPAY for customer '||l_cust_name_num||' ---*/');
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Autopay flag is not turned on in Trade Profile for customer '||l_cust_name_num);
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Failed. ');
                                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Autopay flag is not turned on in Trade Profile for this customer. ');
                                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                                   END IF; -- end of if autopay flag is turning on
                                ELSE
                                   FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Start AUTOPAY for customer '||l_cust_name_num||' ---*/');
                                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Trade Profile is not existing for customer '||l_cust_name_num);
                                   FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                   FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Failed. ');
                                   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Trade Profile is not existing for this customer.');
                                   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                                END IF; -- end of if l_trade_prf_exist
                         END IF; -- end of if l_cust_account_id is not null

                         EXCEPTION
                         WHEN FND_API.G_EXC_ERROR THEN
                                ROLLBACK TO AUTOPAY_CUST;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
                                OZF_UTILITY_PVT.write_conc_log;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Failed. ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || FND_MSG_PUB.get(FND_MSG_PUB.count_msg, FND_API.g_false));
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                                ROLLBACK TO AUTOPAY_CUST;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
                                OZF_UTILITY_PVT.write_conc_log;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Failed. ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || FND_MSG_PUB.get(FND_MSG_PUB.count_msg, FND_API.g_false));
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

                         WHEN OTHERS THEN
                                ROLLBACK TO AUTOPAY_CUST;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '===> Failed.');
                                IF OZF_DEBUG_LOW_ON THEN
                                   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                                   FND_MESSAGE.Set_Token('TEXT',sqlerrm);
                                   FND_MSG_PUB.Add;
                                END IF;
                                OZF_UTILITY_PVT.write_conc_log;
                                FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End ---*/');
                                FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Status : Auto Pay Failed. ');
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : ' || SQLCODE||SQLERRM);
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
                         END;

                          ELSE
                         EXIT;
                          END IF;
                   END LOOP;
                   --CLOSE l_emp_csr;
                   DBMS_SQL.close_cursor(l_emp_csr);

                   -- update the trade_profiles together
                   FORALL i IN 1..l_trd_prof_tbl.COUNT
                        UPDATE OZF_CUST_TRD_PRFLS_ALL
                           SET last_paid_date   = SYSDATE
                         WHERE trade_profile_id = l_trd_prof_tbl(i) ;


                -- Debug Message
                IF OZF_DEBUG_LOW_ON THEN
                   FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
                   FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
                   FND_MSG_PUB.Add;
                END IF;

                -- Write all messages to a log
                OZF_UTILITY_PVT.Write_Conc_Log;

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Successful' );
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

     EXCEPTION
      WHEN FND_API.g_exc_error THEN
      ROLLBACK TO AutoPay;

      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;
      RETCODE := 2;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' || FND_MSG_PUB.get(1, FND_API.g_false)||')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

      WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO AutoPay;

      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;
      RETCODE := 1; -- show status as warning if claim type/reason is missing,  Fix for 5158782
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: ( Warning:' || FND_MSG_PUB.get(1, FND_API.g_false)||')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

      WHEN OTHERS THEN
      ROLLBACK TO AutoPay;

      OZF_UTILITY_PVT.Write_Conc_Log;
      ERRBUF  := l_msg_data;
      RETCODE := 2;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Status: Failure (Error:' ||SQLCODE||SQLERRM || ')');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*---------------------------------------------------------------------------------------------*');

     END;
   END LOOP;
 END IF;
END Start_Autopay;

END OZF_AUTOPAY_PVT;

/
