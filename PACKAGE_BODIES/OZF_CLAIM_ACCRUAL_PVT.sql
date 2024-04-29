--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_ACCRUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_ACCRUAL_PVT" AS
/* $Header: ozfvcacb.pls 120.60.12010000.43 2010/06/10 11:35:50 bkunjan ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_Claim_Accrual_PVT';

G_SCAN_VALUE                    NUMBER       := 0;
G_ENTERED_AMOUNT                NUMBER :=0;

-- object_type
G_CLAIM_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'CLAM';

OZF_DEBUG_HIGH_ON      CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON       CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

CURSOR g_site_trade_profile_csr(p_id in number) IS
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
  WHERE site_use_id = p_id;

CURSOR g_cust_trade_profile_csr(p_id in number) IS
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
  WHERE cust_account_id = p_id;

CURSOR g_party_trade_profile_csr(p_id in number) IS
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

 -- l_original_total_amount NUMBER :=0;
 -- entered_amount NUMBER :=0;
















TYPE funds_rem_rec_type IS RECORD (
  utilization_id         NUMBER,
  amount_remaining       NUMBER,
  scan_unit_remaining    NUMBER
);
TYPE funds_rem_tbl_type is TABLE OF funds_rem_rec_type
INDEX BY BINARY_INTEGER;
---------------------------------------------------------------------
-- PROCEDURE
--   Update_Fund_utils
--   22-Oct-2005    Created     Sahana
--   08-Aug-06      azahmed     Modified for FXGL Er
--   21-Jan-08      psomyaju    Modified for Ship - Debit Claims
--   19-Apr-09      psomyaju    Re-organized code for R12 multicurrency ER.
--   24-Jun-09      BKUNJAN     Added parameter px_currency_rec.
---------------------------------------------------------------------
PROCEDURE  Update_Fund_Utils(
                p_line_util_rec   IN  OUT NOCOPY  line_util_rec_type
              , p_asso_amount     IN  NUMBER
              , p_mode            IN  VARCHAR2 := 'CALCULATE'
              , px_currency_rec   IN  OUT NOCOPY currency_rec_type
              , x_return_status   OUT NOCOPY VARCHAR2
              , x_msg_count       OUT NOCOPY NUMBER
              , x_msg_data        OUT NOCOPY VARCHAR2
 )
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := ' Update_Fund_Utils';
l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);
l_line_util_rec          line_util_rec_type := p_line_util_rec;
l_fu_req_currency        VARCHAR2(15);
l_fu_fund_currency       VARCHAR2(15);
l_claim_currency         VARCHAR2(15);
l_fu_exc_date            DATE;
l_fu_exc_type            VARCHAR2(30);
l_fu_amt_rem             NUMBER         := 0;
l_fu_acctd_amt_rem       NUMBER         := 0;
l_fu_plan_amt_rem        NUMBER         := 0;
l_fu_univ_amt_rem        NUMBER         := 0;
l_fu_req_amt_rem         NUMBER         := 0;
l_rate                   NUMBER         := 0;
l_reference_id           NUMBER         := 0;
l_source_object_class    VARCHAR2(15);
l_fu_plan_id             NUMBER;
l_fu_plan_type           VARCHAR2(15);

l_currency_rec          currency_rec_type := px_currency_rec;

CURSOR csr_fu_amt_rem(cv_utilization_id IN NUMBER) IS
  SELECT currency_code
       , fund_request_currency_code
       , exchange_rate_date
       , exchange_rate_type
       , NVL(acctd_amount_remaining,0)
       , NVL(plan_curr_amount_remaining,0)
       , reference_id
       , plan_id
       , plan_type
       , plan_currency_code
  FROM   ozf_funds_utilized_all_b
  WHERE  utilization_id = cv_utilization_id;

--csr_object_class added for Ship - Debit claims / Pranay
--Bug# 8513457 fixed by ateotia (+)
  /*
  CURSOR  csr_object_class (cv_request_id IN NUMBER) IS
  SELECT  cla.source_object_class
  FROM    ozf_claims cla
        , ozf_claim_lines line
  WHERE   cla.claim_id = line.claim_id
    AND   line.activity_id = cv_request_id;
  */
  CURSOR  csr_object_class (cv_claim_line_id IN NUMBER) IS
  SELECT  cla.source_object_class
  FROM    ozf_claims_all cla
        , ozf_claim_lines_all line
  WHERE   cla.claim_id = line.claim_id
    AND   line.claim_line_id = cv_claim_line_id;
--Bug# 8513457 fixed by ateotia (-)

  CURSOR csr_claim_currency(cv_claim_line_id NUMBER) IS
  SELECT currency_code
  FROM   ozf_claim_lines
  WHERE  claim_line_id = cv_claim_line_id;
BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT  Update_Fund_Utils;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  OPEN csr_fu_amt_rem(l_line_util_rec.utilization_id);
  FETCH csr_fu_amt_rem INTO l_fu_fund_currency
                          , l_fu_req_currency
                          , l_fu_exc_date
                          , l_fu_exc_type
                          , l_fu_acctd_amt_rem
                          , l_fu_plan_amt_rem
                          , l_reference_id
                          , l_fu_plan_id
                          , l_fu_plan_type
                          , l_currency_rec.transaction_currency_code;
  CLOSE csr_fu_amt_rem;

  --Bug# 8513457 fixed by ateotia (+)
  --OPEN csr_object_class(l_reference_id);
  OPEN csr_object_class(l_line_util_rec.claim_line_id);
  FETCH csr_object_class INTO l_source_object_class;
  CLOSE csr_object_class;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('l_line_util_rec.claim_line_id: ' || l_line_util_rec.claim_line_id);
     OZF_Utility_PVT.debug_message('l_source_object_class: ' || l_source_object_class);
  END IF;
  --Bug# 8513457 fixed by ateotia (-)

  --association_currency_code set in Update_Group_Line_Util program unit. In some processes, like
  --public API which use other route for association this global variable will not set.
  --Below logic will handle those scenarios.

  IF l_currency_rec.association_currency_code IS NULL THEN
     OPEN  csr_claim_currency(l_line_util_rec.claim_line_id);
     FETCH csr_claim_currency INTO l_currency_rec.claim_currency_code;
     CLOSE csr_claim_currency;

     IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
        l_currency_rec.association_currency_code := l_currency_rec.transaction_currency_code;
     ELSE
        l_currency_rec.association_currency_code := l_currency_rec.functional_currency_code;
     END IF;
  END IF;

  --Set UNIVERSAL currency from profile.
  l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('Currencies at Update_Fund_Utils API...');
    OZF_Utility_PVT.debug_message('p_asso_amount = '||p_asso_amount);
    OZF_Utility_PVT.debug_message('l_line_util_rec.amount = '||l_line_util_rec.amount);
    OZF_Utility_PVT.debug_message('l_line_util_rec.claim_line_id = '||l_line_util_rec.claim_line_id);
    OZF_Utility_PVT.debug_message('l_currency_rec.association_currency_code = '||l_currency_rec.association_currency_code);
    OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code = '||l_currency_rec.claim_currency_code);
    OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code = '||l_currency_rec.transaction_currency_code);
    OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code = '||l_currency_rec.functional_currency_code);
    OZF_Utility_PVT.debug_message('l_currency_rec.universal_currency_code  = '||l_currency_rec.universal_currency_code );
  END IF;
  --p_asso_amount (earning/adjustment amount) passed in TRANSACTIONAL or FUNCTIONAL
  --currency. Need to calculate amount remaining to be reduced accordingly.
    IF l_currency_rec.association_currency_code  = l_currency_rec.transaction_currency_code THEN
      --l_fu_plan_amt_rem :=  l_fu_plan_amt_rem + NVL(p_asso_amount,0);
        l_fu_plan_amt_rem :=  - NVL(p_asso_amount,0);
      IF l_fu_plan_amt_rem IS NOT NULL AND l_fu_plan_amt_rem <> 0 THEN
         OZF_UTILITY_PVT.Convert_Currency
                     ( p_from_currency   => l_currency_rec.transaction_currency_code
                     , p_to_currency     => l_currency_rec.functional_currency_code
                     , p_conv_date       => l_fu_exc_date
                     , p_conv_type       => l_fu_exc_type
                     , p_from_amount     => l_fu_plan_amt_rem
                     , x_return_status   => l_return_status
                     , x_to_amount       => l_fu_acctd_amt_rem
                     , x_rate            => l_rate
                     );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
        IF l_fu_acctd_amt_rem IS NOT NULL THEN
          l_fu_acctd_amt_rem  := OZF_UTILITY_PVT.CurrRound(l_fu_acctd_amt_rem, l_currency_rec.functional_currency_code);
        END IF;
      ELSE
        l_fu_acctd_amt_rem := 0;
      END IF;
         ELSE
      --l_fu_acctd_amt_rem := l_fu_acctd_amt_rem + NVL(p_asso_amount,0);
      l_fu_acctd_amt_rem := - NVL(p_asso_amount,0);
      IF l_fu_acctd_amt_rem IS NOT NULL AND l_fu_acctd_amt_rem <> 0 THEN
         OZF_UTILITY_PVT.Convert_Currency
                     ( p_from_currency   => l_currency_rec.functional_currency_code
                     , p_to_currency     => l_currency_rec.transaction_currency_code
                     , p_conv_date       => l_fu_exc_date
                     , p_conv_type       => l_fu_exc_type
                     , p_from_amount     => l_fu_acctd_amt_rem
                     , x_return_status   => l_return_status
                     , x_to_amount       => l_fu_plan_amt_rem
                     , x_rate            => l_rate
                     );
            IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
            END IF;
        IF l_fu_plan_amt_rem IS NOT NULL THEN
          l_fu_plan_amt_rem := OZF_UTILITY_PVT.CurrRound(l_fu_plan_amt_rem, l_currency_rec.transaction_currency_code);
        END IF;
      ELSE
        l_fu_plan_amt_rem := 0;
      END IF;
    END IF;

    IF l_fu_plan_amt_rem  <> 0 OR
       l_fu_acctd_amt_rem <> 0
    THEN
      IF l_fu_fund_currency = l_currency_rec.transaction_currency_code THEN
         l_fu_amt_rem := l_fu_plan_amt_rem;
      ELSIF l_fu_fund_currency = l_currency_rec.functional_currency_code THEN
        l_fu_amt_rem := l_fu_acctd_amt_rem;
      ELSE
        IF l_fu_plan_amt_rem IS NOT NULL AND l_fu_plan_amt_rem <> 0 THEN
           OZF_UTILITY_PVT.Convert_Currency
                       ( p_from_currency   => l_currency_rec.transaction_currency_code
                       , p_to_currency     => l_fu_fund_currency
                       , p_conv_date       => l_fu_exc_date
                       , p_conv_type       => l_fu_exc_type
                       , p_from_amount     => l_fu_plan_amt_rem
                       , x_return_status   => l_return_status
                       , x_to_amount       => l_fu_amt_rem
                       , x_rate            => l_rate
                       );
          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
          IF l_fu_amt_rem IS NOT NULL THEN
            l_fu_amt_rem := OZF_UTILITY_PVT.CurrRound(l_fu_amt_rem, l_fu_fund_currency);
          END IF;
        ELSE
          l_fu_amt_rem := 0;
        END IF;
      END IF;

      IF l_currency_rec.universal_currency_code = l_currency_rec.transaction_currency_code THEN
        l_fu_univ_amt_rem := l_fu_plan_amt_rem;
      ELSIF l_currency_rec.universal_currency_code = l_currency_rec.functional_currency_code THEN
        l_fu_univ_amt_rem := l_fu_acctd_amt_rem;
      ELSIF l_currency_rec.universal_currency_code = l_fu_fund_currency THEN
        l_fu_univ_amt_rem := l_fu_amt_rem;
      ELSE
        IF l_fu_plan_amt_rem IS NOT NULL AND l_fu_plan_amt_rem <> 0 THEN
           OZF_UTILITY_PVT.Convert_Currency
                         ( p_from_currency   => l_currency_rec.transaction_currency_code
                         , p_to_currency     => l_currency_rec.universal_currency_code
                         , p_conv_date       => l_fu_exc_date
                         , p_conv_type       => l_fu_exc_type
                         , p_from_amount     => l_fu_plan_amt_rem
                         , x_return_status   => l_return_status
                         , x_to_amount       => l_fu_univ_amt_rem
                         , x_rate            => l_rate
                         );
          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
          IF l_fu_univ_amt_rem IS NOT NULL THEN
            l_fu_univ_amt_rem := OZF_UTILITY_PVT.CurrRound(l_fu_univ_amt_rem, l_currency_rec.universal_currency_code);
          END IF;
        ELSE
          l_fu_univ_amt_rem := 0;
        END IF;
      END IF;

      IF l_fu_req_currency = l_currency_rec.transaction_currency_code THEN
        l_fu_req_amt_rem := l_fu_plan_amt_rem;
      ELSIF l_fu_req_currency = l_currency_rec.functional_currency_code THEN
        l_fu_req_amt_rem := l_fu_acctd_amt_rem;
      ELSIF l_fu_req_currency = l_fu_fund_currency THEN
        l_fu_req_amt_rem := l_fu_amt_rem;
      ELSIF l_fu_req_currency = l_currency_rec.universal_currency_code THEN
        l_fu_req_amt_rem := l_fu_univ_amt_rem;
      ELSE
        IF l_fu_plan_amt_rem IS NOT NULL AND l_fu_plan_amt_rem <> 0 THEN
           OZF_UTILITY_PVT.Convert_Currency
                         ( p_from_currency   => l_currency_rec.transaction_currency_code
                         , p_to_currency     => l_fu_req_currency
                         , p_conv_date       => l_fu_exc_date
                         , p_conv_type       => l_fu_exc_type
                         , p_from_amount     => l_fu_plan_amt_rem
                         , x_return_status   => l_return_status
                         , x_to_amount       => l_fu_req_amt_rem
                         , x_rate            => l_rate
                         );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
            IF l_fu_req_amt_rem IS NOT NULL THEN
              l_fu_req_amt_rem := OZF_UTILITY_PVT.CurrRound(l_fu_req_amt_rem, l_fu_req_currency);
            END IF;
        ELSE
          l_fu_req_amt_rem := 0;
        END IF;
      END IF;

    ELSE
      l_fu_amt_rem := 0;
      l_fu_univ_amt_rem := 0;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_fu_amt_rem  : '||l_fu_amt_rem);
      OZF_Utility_PVT.debug_message('l_fu_acctd_amt_rem  : '||l_fu_acctd_amt_rem);
      OZF_Utility_PVT.debug_message('l_fu_plan_amt_rem  : '||l_fu_plan_amt_rem);
      OZF_Utility_PVT.debug_message('l_fu_univ_amt_rem  : '||l_fu_univ_amt_rem);
      OZF_Utility_PVT.debug_message('l_fu_req_amt_rem  : '||l_fu_req_amt_rem);
      OZF_Utility_PVT.debug_message('l_line_util_rec.utilization_id  : '||l_line_util_rec.utilization_id);
    END IF;
    --Reduce utilization amount remaining columns of respective currencies.
   -- Fix for Bug 9776744
  IF NVL(l_source_object_class,'X') <> 'SD_SUPPLIER' THEN
      UPDATE ozf_funds_utilized_all_b
      SET    amount_remaining                  = amount_remaining - l_fu_amt_rem
           , acctd_amount_remaining          = acctd_amount_remaining - l_fu_acctd_amt_rem
           , plan_curr_amount_remaining      = plan_curr_amount_remaining - l_fu_plan_amt_rem
           , univ_curr_amount_remaining      = univ_curr_amount_remaining - l_fu_univ_amt_rem
           , fund_request_amount_remaining   = fund_request_amount_remaining - l_fu_req_amt_rem
     WHERE utilization_id = l_line_util_rec.utilization_id;

  END IF; --SD_SUPPLIER check

  -- Calculate FXGL for association amount.
  IF  p_mode = 'CALCULATE' THEN

    l_line_util_rec.fxgl_acctd_amount := Calculate_FXGL_Amount(l_line_util_rec,l_currency_rec);
    l_line_util_rec.utilized_acctd_amount := l_line_util_rec.acctd_amount - l_line_util_rec.fxgl_acctd_amount;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_line_util_rec.fxgl_acctd_amount  : '||l_line_util_rec.fxgl_acctd_amount );
      OZF_Utility_PVT.debug_message('l_line_util_rec.utilized_acctd_amount : '||l_line_util_rec.utilized_acctd_amount );
    END IF;
--nepanda : fix for bug # 9508390  - issue # 1
     l_line_util_rec.util_curr_amount := NVL(l_line_util_rec.util_curr_amount, 0) + l_fu_amt_rem;
     l_line_util_rec.plan_curr_amount := NVL(l_line_util_rec.plan_curr_amount, 0) + l_fu_req_amt_rem;
     l_line_util_rec.univ_curr_amount := NVL(l_line_util_rec.univ_curr_amount, 0) + l_fu_univ_amt_rem;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_line_util_rec.util_curr_amount  : '||l_line_util_rec.util_curr_amount );
        OZF_Utility_PVT.debug_message('l_line_util_rec.plan_curr_amount : '||l_line_util_rec.plan_curr_amount );
        OZF_Utility_PVT.debug_message('l_line_util_rec.univ_curr_amount : '||l_line_util_rec.univ_curr_amount );
     END IF;

  END IF;  --'CALCULATE' check

  p_line_util_rec :=  l_line_util_rec;



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
    ROLLBACK TO Update_Fund_Utils;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Fund_Utils;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Fund_Utils;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Update_Fund_Utils;


---------------------------------------------------------------------
-- PROCEDURE
--   Get_Customer_For_Earnings
--    Helper procedure called by Get_Utiz_Sql_Stmt only.
--
-- PARAMETERS
--    p_cust_account_id   : Claiming customer account id
--    p_relationship_type : Relationship_type
--    p_related_cust_account_id : Related customer account id
--    p_buy_group_party_id : Buying group/member party id
--    p_select_cust_children_flag : Include all member earnings
--
-- HISTORY
--   14-FEB-2003  yizhang  Create.
--   05-MAY-2003  yizhang  Use FND_DSQL for dynamic sql and bind vars
--   28-feb-06   azahmed   modified for bugfix 4958714
---------------------------------------------------------------------
PROCEDURE Get_Customer_For_Earnings(
   p_cust_account_id           IN  NUMBER
  ,p_relationship_type         IN  VARCHAR2
  ,p_related_cust_account_id   IN  NUMBER
  ,p_buy_group_party_id        IN  NUMBER
  ,p_select_cust_children_flag IN  VARCHAR2
)
IS

l_bg_is_parent_of_cust      NUMBER        := 0;
l_bg_is_parent_of_relcust   NUMBER        := 0;

CURSOR csr_buy_group (cv_bg_party_id IN NUMBER, cv_cust_account_id IN NUMBER) IS
  SELECT COUNT(seg.party_id)
  FROM ams_party_market_segments seg
     , hz_cust_accounts hca2
  WHERE seg.market_qualifier_reference = cv_bg_party_id
  AND hca2.party_id = seg.party_id
  AND seg.market_qualifier_type = 'BG'
  AND hca2.cust_account_id = cv_cust_account_id
  AND seg.market_qualifier_reference <> seg.party_id;


BEGIN
  IF p_select_cust_children_flag IS NULL OR
     p_select_cust_children_flag = 'F' OR
     p_select_cust_children_flag = 'N' THEN
    -- not to include member earnings
    IF p_buy_group_party_id IS NOT NULL THEN
      FND_DSQL.add_text(' IN (SELECT c.cust_account_id FROM hz_cust_accounts c');
      FND_DSQL.add_text(' WHERE c.party_id = ');
      FND_DSQL.add_bind(p_buy_group_party_id);
      FND_DSQL.add_text(')');
    ELSIF p_relationship_type IS NOT NULL AND
       p_related_cust_account_id IS NULL
    THEN
      FND_DSQL.add_text(' IN (SELECT related_cust_account_id FROM hz_cust_acct_relate');
      FND_DSQL.add_text(' WHERE cust_account_id = ');
      FND_DSQL.add_bind(p_cust_account_id);
      FND_DSQL.add_text(' AND relationship_type = ');
      FND_DSQL.add_bind(p_relationship_type);
      FND_DSQL.add_text(')');
    ELSE
      FND_DSQL.add_text(' = ');
      IF p_related_cust_account_id IS NOT NULL THEN
        FND_DSQL.add_bind(p_related_cust_account_id);
      ELSE
        FND_DSQL.add_bind(p_cust_account_id);
      END IF;
    END IF;

  ELSIF p_select_cust_children_flag = 'T' OR p_select_cust_children_flag = 'Y' THEN
    -- to include member earnings
    IF p_buy_group_party_id IS NOT NULL THEN
      -- if buying group is parent of customer, do not include members
      OPEN csr_buy_group(p_buy_group_party_id, p_cust_account_id);
      FETCH csr_buy_group INTO l_bg_is_parent_of_cust;
      CLOSE csr_buy_group;

      IF l_bg_is_parent_of_cust <> 1 THEN
        -- if buying group is parent of related customer, do not include members
        IF p_related_cust_account_id IS NOT NULL THEN
          OPEN csr_buy_group(p_buy_group_party_id, p_related_cust_account_id);
          FETCH csr_buy_group INTO l_bg_is_parent_of_relcust;
          CLOSE csr_buy_group;
        END IF;
      END IF;
    END IF;

    IF l_bg_is_parent_of_cust = 1 OR l_bg_is_parent_of_relcust = 1 THEN
      FND_DSQL.add_text(' IN (SELECT c.cust_account_id ');
      FND_DSQL.add_text(' FROM hz_cust_accounts c ');
      FND_DSQL.add_text(' WHERE c.party_id = ');
      FND_DSQL.add_bind(p_buy_group_party_id);
      FND_DSQL.add_text('  OR  c.cust_account_id = ');
        IF  p_related_cust_account_id is not NULL THEN
                FND_DSQL.add_bind(p_related_cust_account_id);
        ELSE
                FND_DSQL.add_bind(p_cust_account_id);
        END IF;
     FND_DSQL.add_text(')');

    ELSE
      IF p_buy_group_party_id IS NOT NULL THEN
        FND_DSQL.add_text(' IN (SELECT c2.cust_account_id ');
        FND_DSQL.add_text(' FROM ams_party_market_segments sg, hz_cust_accounts c2 ');
        FND_DSQL.add_text(' WHERE sg.market_qualifier_type = ''BG'' ');
        FND_DSQL.add_text(' AND sg.party_id = c2.party_id ');
        FND_DSQL.add_text(' AND sg.market_qualifier_reference = ');
        FND_DSQL.add_bind(p_buy_group_party_id);
        FND_DSQL.add_text(')');
      ELSE
      -- Modified for Bugfix 5346249
        FND_DSQL.add_text(' IN (SELECT cust2.cust_account_id FROM  hz_cust_accounts cust2  ');
        FND_DSQL.add_text(' WHERE cust2.party_id IN (SELECT seg.party_id from ');
        FND_DSQL.add_text(' ams_party_market_segments seg ,hz_cust_accounts cust1 ');
        FND_DSQL.add_text(' where seg.market_qualifier_type = ''BG'' ');
        FND_DSQL.add_text(' and seg.market_qualifier_reference =  cust1.party_id ');
        FND_DSQL.add_text(' and cust1.cust_account_id = ');
        IF p_related_cust_account_id IS NOT NULL THEN
          FND_DSQL.add_bind(p_related_cust_account_id);
        ELSE
          FND_DSQL.add_bind(p_cust_account_id);
        END IF;
        FND_DSQL.add_text(')');
        FND_DSQL.add_text(')');
      END IF;
    END IF;
  END IF;

END Get_Customer_For_Earnings;

---------------------------------------------------------------------
-- PROCEDURE
--   Copy_Util_Flt
--    Helper procedure called by Get_Utiz_Sql_Stmt only.
--
-- PARAMETERS
--
-- HISTORY
--   16-FEB-2004  yizhang  Create.
---------------------------------------------------------------------
PROCEDURE Copy_Util_Flt(
   px_funds_util_flt           IN OUT NOCOPY funds_util_flt_type
)
IS

l_line_util_flt     funds_util_flt_type;
l_offer_id          NUMBER;
l_offer_type        VARCHAR2(30);
l_reference_type    VARCHAR2(30);
l_reference_id      NUMBER;

CURSOR csr_line_flt(cv_claim_line_id IN NUMBER) IS
  SELECT ln.activity_type
  ,      ln.activity_id
  ,      ln.offer_type
  ,      ln.source_object_class
  ,      ln.source_object_id
  ,      ln.item_type
  ,      ln.item_id
  ,      ln.relationship_type
  ,      ln.related_cust_account_id
  ,      ln.buy_group_party_id
  ,      ln.select_cust_children_flag
  ,      cla.cust_account_id
  ,      ln.earnings_end_date
  ,      ln.claim_currency_amount
  ,      cla.source_object_class
  ,      cla.source_object_id
  FROM ozf_claim_lines ln
  ,    ozf_claims cla
  WHERE ln.claim_id = cla.claim_id
  AND ln.claim_line_id = cv_claim_line_id;

CURSOR csr_offer_id(cv_request_id IN NUMBER) IS
  SELECT offer_id
  FROM ozf_request_headers_all_b
  WHERE request_header_id = cv_request_id;

CURSOR csr_offer_type(cv_offer_id IN NUMBER) IS
  SELECT offer_type
  FROM ozf_offers
  WHERE qp_list_header_id = cv_offer_id;

--Ship - Debit Enhancements / Added by Pranay
CURSOR csr_sd_offer_id(cv_request_id IN NUMBER) IS
  SELECT offer_id
  FROM ozf_sd_request_headers_all_b
  WHERE request_header_id = cv_request_id;
--Bug# 8632964 fixed by anuj & muthsubr (+)
CURSOR sysparam_accrual_flag_csr (p_resale_batch_id IN NUMBER)
IS
SELECT NVL(ospa.ship_debit_accrual_flag, 'F')
FROM ozf_sys_parameters_all ospa,
     ozf_resale_batches_all orba
WHERE ospa.org_id = orba.org_id
AND orba.resale_batch_id = p_resale_batch_id;

l_accrual_flag VARCHAR2(1);
--Bug# 8632964 fixed by anuj & muthsubr (-)

BEGIN
   OPEN csr_line_flt(px_funds_util_flt.claim_line_id);
   FETCH csr_line_flt INTO l_line_util_flt.activity_type
                         , l_line_util_flt.activity_id
                         , l_line_util_flt.offer_type
                         , l_line_util_flt.document_class
                         , l_line_util_flt.document_id
                         , l_line_util_flt.product_level_type
                         , l_line_util_flt.product_id
                         , l_line_util_flt.relationship_type
                         , l_line_util_flt.related_cust_account_id
                         , l_line_util_flt.buy_group_party_id
                         , l_line_util_flt.select_cust_children_flag
                         , l_line_util_flt.cust_account_id
                         , l_line_util_flt.end_date
                         , l_line_util_flt.total_amount
                         , l_reference_type
                         , l_reference_id;
   CLOSE csr_line_flt;

   IF px_funds_util_flt.activity_type IS NULL THEN
      px_funds_util_flt.activity_type := l_line_util_flt.activity_type;
   END IF;
   IF px_funds_util_flt.activity_id IS NULL THEN
      px_funds_util_flt.activity_id := l_line_util_flt.activity_id;
   END IF;
   IF px_funds_util_flt.offer_type IS NULL THEN
      px_funds_util_flt.offer_type := l_line_util_flt.offer_type;
   END IF;
   IF px_funds_util_flt.document_class IS NULL THEN
      px_funds_util_flt.document_class := l_line_util_flt.document_class;
   END IF;
   IF px_funds_util_flt.document_id IS NULL THEN
      px_funds_util_flt.document_id := l_line_util_flt.document_id;
   END IF;
   IF px_funds_util_flt.product_level_type IS NULL THEN
      px_funds_util_flt.product_level_type := l_line_util_flt.product_level_type;
   END IF;
   IF px_funds_util_flt.product_id IS NULL THEN
      px_funds_util_flt.product_id := l_line_util_flt.product_id;
   END IF;
   IF px_funds_util_flt.relationship_type IS NULL THEN
      px_funds_util_flt.relationship_type := l_line_util_flt.relationship_type;
   END IF;
   IF px_funds_util_flt.related_cust_account_id IS NULL THEN
      px_funds_util_flt.related_cust_account_id := l_line_util_flt.related_cust_account_id;
   END IF;
   IF px_funds_util_flt.buy_group_party_id IS NULL THEN
      px_funds_util_flt.buy_group_party_id := l_line_util_flt.buy_group_party_id;
   END IF;
   IF px_funds_util_flt.select_cust_children_flag IS NULL THEN
      px_funds_util_flt.select_cust_children_flag := l_line_util_flt.select_cust_children_flag;
   END IF;
   IF px_funds_util_flt.cust_account_id IS NULL THEN
      px_funds_util_flt.cust_account_id := l_line_util_flt.cust_account_id;
   END IF;
   IF px_funds_util_flt.end_date IS NULL THEN
      px_funds_util_flt.end_date := l_line_util_flt.end_date;
   END IF;
   IF px_funds_util_flt.total_amount IS NULL THEN
--      px_funds_util_flt.total_amount := l_line_util_flt.total_amount;
        NULL; -- If null, then leave as null implies line is to be deleted. Bugfix 5101106

   END IF;

   IF px_funds_util_flt.reference_type IS NULL THEN
      IF l_reference_type = 'REFERRAL' THEN
         px_funds_util_flt.reference_type := 'LEAD_REFERRAL';
         px_funds_util_flt.reference_id := l_reference_id;
         ELSIF l_reference_type = 'BATCH' THEN
         --Bug# 8632964 fixed by anuj & muthsubr (+)
         OPEN sysparam_accrual_flag_csr (l_reference_id);
         FETCH sysparam_accrual_flag_csr INTO l_accrual_flag;
         CLOSE sysparam_accrual_flag_csr;
         IF l_accrual_flag = 'T' THEN
         -- Added for Bug 4997509
         px_funds_util_flt.reference_type := l_reference_type;
         px_funds_util_flt.reference_id := l_reference_id;
         END IF;
         --Bug# 8632964 fixed by anuj & muthsubr (-)
      END IF;
   END IF;

   -- for special price request and soft fund, search by offer
   IF px_funds_util_flt.activity_type IN ('SPECIAL_PRICE', 'SOFT_FUND') THEN
      px_funds_util_flt.activity_type := 'OFFR';

      IF px_funds_util_flt.activity_id IS NOT NULL THEN
         OPEN csr_offer_id(px_funds_util_flt.activity_id);
         FETCH csr_offer_id INTO l_offer_id;
         CLOSE csr_offer_id;

         px_funds_util_flt.activity_id := l_offer_id;
      END IF;
   END IF;

--Ship - Debit Enhancements / Added by Pranay
   IF px_funds_util_flt.activity_type = 'SD_REQUEST' THEN
     px_funds_util_flt.activity_type := 'OFFR';

     IF px_funds_util_flt.activity_id IS NOT NULL THEN
       OPEN csr_sd_offer_id(px_funds_util_flt.activity_id);
       FETCH csr_sd_offer_id INTO l_offer_id;
       CLOSE csr_sd_offer_id;
       px_funds_util_flt.activity_id := l_offer_id;
     END IF;
   END IF;

   -- set offer_type
   IF px_funds_util_flt.offer_type IS NULL AND
      px_funds_util_flt.activity_type = 'OFFR' AND
      px_funds_util_flt.activity_id IS NOT NULL
   THEN
      OPEN csr_offer_type(px_funds_util_flt.activity_id);
      FETCH csr_offer_type INTO l_offer_type;
      CLOSE csr_offer_type;

      px_funds_util_flt.offer_type := l_offer_type;
   END IF;

END Copy_Util_Flt;

---------------------------------------------------------------------
-- PROCEDURE
--   Get_Utiz_Sql_Stmt_Where_Clause
--
-- PARAMETERS
--
-- NOTE
--
-- HISTORY
--   17-FEB-2004  yizhang  Create.
--   08-AUg-2006  azahmed Modified for FXGL ER: Added condition fu.currency_code = claim_curr
--   26-Jun-2009  kpatro  Corrected the GSCC Error.
---------------------------------------------------------------------
PROCEDURE Get_Utiz_Sql_Stmt_Where_Clause(
   p_summary_view        IN  VARCHAR2  := NULL
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,px_currency_rec       IN OUT  NOCOPY currency_rec_type
)
IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Utiz_Sql_Stmt_Where_Clause';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(1);

l_funds_util_flt        funds_util_flt_type  := NULL;
l_cust_account_id       NUMBER         := NULL;
l_scan_data_flag        VARCHAR2(1)    := 'N';
l_org_id                NUMBER;
l_currency_rec          currency_rec_type := px_currency_rec;

CURSOR csr_claim_currency(cv_claim_line_id IN NUMBER) IS
SELECT currency_code
FROM ozf_claim_lines
where claim_line_id = cv_claim_line_id;


BEGIN
   --------------------- start -----------------------
   l_org_id := FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

   l_funds_util_flt := p_funds_util_flt;

    -- get claim currency
    OPEN csr_claim_currency(l_funds_util_flt.claim_line_id);
   FETCH csr_claim_currency INTO l_currency_rec.claim_currency_code;
    CLOSE csr_claim_currency;
    -- bug fix 4338584
   -- when a fund line utilization is updated from the UI the account id should be picked up from the record
   l_cust_account_id := l_funds_util_flt.cust_account_id;

   IF l_funds_util_flt.offer_type = 'SCAN_DATA' THEN
      l_scan_data_flag := 'Y';
   END IF;

   -- Added Debug For Multi Currency - kpatro
    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('----- Get_Utiz_Sql_Stmt_Where_Clause:Start -----');
      OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code        : ' || l_currency_rec.claim_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code   : ' || l_currency_rec.functional_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code  : ' || l_currency_rec.transaction_currency_code);
      OZF_Utility_PVT.debug_message('p_summary_view         : ' || p_summary_view);
      OZF_Utility_PVT.debug_message('l_funds_util_flt.utiz_currency_code         : ' || l_funds_util_flt.utiz_currency_code);
      OZF_Utility_PVT.debug_message('Process_By         : ' || l_funds_util_flt.autopay_check);
      OZF_Utility_PVT.debug_message('----------------------------Get_Utiz_Sql_Stmt_Where_Clause:End ------------');
   END IF;
    -- Bug5059770: Allow pay over for offers with zero available amount
  --Bug 5154157 : Reverted change made for bug 4927201 as this will not be called if
   --  total amount is to be overpaid
   -- Modified for FXGL ER: only accruals in claim currency must be returned
   -- Modified conditions for R12 Multicurrency / Pranay
   IF p_summary_view IS NULL OR p_summary_view <> 'DEL_GRP_LINE_UTIL' THEN

      -- Added For Multi Currency - kpatro
      IF (p_summary_view IN ('AUTOPAY','AUTOPAY_LINE') AND l_funds_util_flt.autopay_check = 'AUTOPAY') THEN
         FND_DSQL.add_text(' AND fu.plan_curr_amount_remaining <> 0 ');
      ELSE
         FND_DSQL.add_text(' AND (DECODE(NVL('''||l_currency_rec.claim_currency_code||''',fu.plan_currency_code), fu.plan_currency_code, fu.plan_curr_amount_remaining, fu.acctd_amount_remaining))<> 0 ');
      END IF;

   END IF;

     IF l_currency_rec.transaction_currency_code IS NOT NULL THEN --restrict for public API
         FND_DSQL.add_text(' AND fu.plan_currency_code = '''||l_currency_rec.transaction_currency_code||''''); --kdass
     END IF;


   -- for lead referral accruals, set utilization_type as LEAD_ACCRUAL
   -- Fixed for Bug4576309
   -- Modified for Bug4997509 to match ClaimAssoVO.getCommonWhereClause
   IF l_funds_util_flt.utilization_type IS NULL OR l_funds_util_flt.utilization_type = 'ACCRUAL' THEN
       IF l_funds_util_flt.reference_type = 'LEAD_REFERRAL' THEN
           FND_DSQL.add_text(' AND fu.utilization_type IN (''LEAD_ACCRUAL'', ''LEAD_ADJUSTMENT'') ' );
       ELSIF l_funds_util_flt.reference_type = 'BATCH' THEN
           FND_DSQL.add_text(' AND fu.utilization_type = ''CHARGEBACK'' ');
       ELSE
           FND_DSQL.add_text('  AND fu.utilization_type IN (''ACCRUAL'', ''ADJUSTMENT'') ' );
       END IF;
   ELSE
       FND_DSQL.add_text(' AND fu.utilization_type = ');
       FND_DSQL.add_bind(l_funds_util_flt.utilization_type);
   END IF;

   IF l_funds_util_flt.utilization_type = 'ADJUSTMENT' THEN
      FND_DSQL.add_text(' AND fu.cust_account_id IS NULL ');
   ELSE
      -- bug fix 4338584
      IF l_funds_util_flt.cust_account_id IS NOT NULL AND l_scan_data_flag = 'N' AND l_funds_util_flt.run_mode is not null THEN
         FND_DSQL.add_text(' AND fu.cust_account_id');

         Get_Customer_For_Earnings(
            p_cust_account_id           => l_funds_util_flt.cust_account_id
           ,p_relationship_type         => l_funds_util_flt.relationship_type
           ,p_related_cust_account_id   => l_funds_util_flt.related_cust_account_id
           ,p_buy_group_party_id        => l_funds_util_flt.buy_group_party_id
           ,p_select_cust_children_flag => l_funds_util_flt.select_cust_children_flag
         );

      ELSIF l_cust_account_id IS NOT NULL AND l_scan_data_flag = 'N' THEN
         FND_DSQL.add_text(' AND fu.cust_account_id = ');
         FND_DSQL.add_bind(l_cust_account_id);
      END IF;
   END IF;

   -- Add fund_id as search filter for claim autopay program.
   IF l_funds_util_flt.fund_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND fu.fund_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.fund_id);
   END IF;

   IF l_funds_util_flt.activity_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND fu.plan_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.activity_id);
   END IF;

   IF l_funds_util_flt.reference_type IS NOT NULL THEN
      FND_DSQL.add_text(' AND fu.reference_type = ');
      FND_DSQL.add_bind(l_funds_util_flt.reference_type);
   END IF;

   IF l_funds_util_flt.reference_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND fu.reference_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.reference_id);
   END IF;

   IF l_funds_util_flt.activity_product_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND fu.activity_product_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.activity_product_id);
   END IF;

   IF l_funds_util_flt.schedule_id IS NOT NULL AND l_scan_data_flag = 'N' THEN
      FND_DSQL.add_text(' AND fu.component_type = ''CSCH'' ');
      FND_DSQL.add_text(' AND fu.component_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.schedule_id);
   END IF;

   -- fix for 4308165
        -- modified for bugfix 4990767
   IF l_funds_util_flt.document_class IS NOT NULL AND l_scan_data_flag = 'N' THEN
       IF l_funds_util_flt.document_class IN ('ORDER','TP_ORDER') THEN
         FND_DSQL.add_text(' AND fu.object_type = ');
         FND_DSQL.add_bind(l_funds_util_flt.document_class);
      END IF;
   END IF;

   IF l_funds_util_flt.document_id IS NOT NULL AND l_scan_data_flag = 'N' THEN
      IF l_funds_util_flt.document_class = 'TP_ORDER' THEN
         FND_DSQL.add_text(' AND fu.object_id IN (SELECT chargeback_line_id FROM ozf_chargeback_lines WHERE chargeback_header_id = ');
         FND_DSQL.add_bind(l_funds_util_flt.document_id);
         FND_DSQL.add_text(') ');
      ELSE
       IF l_funds_util_flt.document_class = 'ORDER' THEN
         FND_DSQL.add_text(' AND fu.object_id = ');
         FND_DSQL.add_bind(l_funds_util_flt.document_id);
      END IF;
      END IF;
   END IF;

   IF (l_funds_util_flt.product_level_type = 'PRODUCT' OR
      l_funds_util_flt.product_level_type IS NULL) AND
      l_funds_util_flt.product_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND ((fu.product_level_type = ''PRODUCT'' ');
      FND_DSQL.add_text(' AND fu.product_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.product_id);
      FND_DSQL.add_text(' ) OR (fu.product_level_type = ''FAMILY'' ');
      FND_DSQL.add_text(' AND fu.product_id IN (select category_id from mtl_item_categories ');
      FND_DSQL.add_text(' where inventory_item_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.product_id);
      FND_DSQL.add_text(' and organization_id = ');
      FND_DSQL.add_bind(l_org_id);
      FND_DSQL.add_text(' ))) ');
   ELSIF l_funds_util_flt.product_level_type = 'FAMILY' AND
      l_funds_util_flt.product_id IS NOT NULL THEN
      FND_DSQL.add_text(' AND ((fu.product_level_type = ''FAMILY'' ');
      FND_DSQL.add_text(' AND fu.product_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.product_id);
      FND_DSQL.add_text(' ) OR (fu.product_level_type = ''PRODUCT'' ');
      FND_DSQL.add_text(' AND fu.product_id IN (select b.inventory_item_id from eni_denorm_hierarchies a, mtl_item_categories b  ');
      FND_DSQL.add_text(' where a.parent_id = ');
      FND_DSQL.add_text(l_funds_util_flt.product_id);
      FND_DSQL.add_text(' and b.organization_id = ');
      FND_DSQL.add_bind(l_org_id);
      FND_DSQL.add_text(' and a.object_type = ''CATEGORY_SET'' and b.category_id = a.child_id ');
      FND_DSQL.add_text(' ))) ');
   ELSIF l_funds_util_flt.product_level_type = 'MEDIA' THEN
      FND_DSQL.add_text(' AND fu.product_level_type = ''MEDIA'' ');
      IF l_funds_util_flt.product_id IS NOT NULL THEN
         FND_DSQL.add_text(' AND fu.product_id = ');
         FND_DSQL.add_bind(l_funds_util_flt.product_id);
      END IF;
   END IF;

   IF l_funds_util_flt.end_date IS NOT NULL THEN
      FND_DSQL.add_text(' AND trunc(fu.creation_date) <= ');
      FND_DSQL.add_bind(l_funds_util_flt.end_date);
   END IF;

   -- Fix for Bug 8402328
   IF (l_funds_util_flt.utilization_id IS NOT NULL) THEN
      FND_DSQL.add_text(' AND fu.utilization_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.utilization_id );
   END IF;

   FND_DSQL.add_text(' AND fu.gl_posted_flag = ''Y'' ');

END Get_Utiz_Sql_Stmt_Where_Clause;

---------------------------------------------------------------------
-- PROCEDURE
--   Get_Utiz_Sql_Stmt_From_Clause
--
-- PARAMETERS
--
-- NOTE
--
-- HISTORY
--   17-FEB-2004  yizhang  Create.
---------------------------------------------------------------------
PROCEDURE Get_Utiz_Sql_Stmt_From_Clause(
   p_summary_view        IN  VARCHAR2
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_currency_rec        IN  currency_rec_type
)
IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Utiz_Sql_Stmt_From_Clause';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;

l_funds_util_flt        funds_util_flt_type  := NULL;
l_cust_account_id       NUMBER         := NULL;
l_scan_data_flag        VARCHAR2(1)    := 'N';
l_offer_flag            VARCHAR2(1)    := 'Y';
l_price_list_flag       VARCHAR2(1)    := 'Y';
l_resource_id           NUMBER;
l_sales_rep             VARCHAR2(1)    := FND_API.g_false;
l_is_admin              BOOLEAN        :=  FALSE;
l_orgId                 NUMBER;
l_claim_line_id         NUMBER;
l_currency_rec          currency_rec_type := p_currency_rec;
BEGIN
   --------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   --------------------- start -----------------------
   l_funds_util_flt := p_funds_util_flt;

   IF l_funds_util_flt.offer_type = 'SCAN_DATA' THEN
      l_scan_data_flag := 'Y';
   END IF;

   IF l_funds_util_flt.activity_type IS NOT NULL THEN
      IF l_funds_util_flt.activity_type = 'OFFR' THEN
         l_price_list_flag := 'N';
      ELSE
         l_offer_flag := 'N';
      END IF;
   END IF;

   IF l_funds_util_flt.run_mode IN ('OFFER_AUTOPAY', 'OFFER_NO_AUTOPAY') THEN
      l_price_list_flag := 'N';
   END IF;

   IF l_funds_util_flt.offer_type IS NOT NULL THEN
      l_price_list_flag := 'N';
   END IF;

   l_resource_id := ozf_utility_pvt.get_resource_id(fnd_global.user_id);
   l_is_admin := ams_access_PVT.Check_Admin_Access(l_resource_id);
   l_orgId := MO_GLOBAL.GET_CURRENT_ORG_ID();

   -- Added Debug For Multi Currency - kpatro
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('----- Get_Utiz_Sql_Stmt_From_Clause:Start -----');
      OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code        : ' || l_currency_rec.claim_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code   : ' || l_currency_rec.functional_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code  : ' || l_currency_rec.transaction_currency_code);
      OZF_Utility_PVT.debug_message('p_summary_view         : ' || p_summary_view);
      OZF_Utility_PVT.debug_message('Process_By         : ' || l_funds_util_flt.autopay_check);
      OZF_Utility_PVT.debug_message('----------------------------Get_Utiz_Sql_Stmt_From_Clause:End ------------');
   END IF;
   IF l_offer_flag = 'Y' THEN
      -- restrict offer access if user is sales rep
      IF l_funds_util_flt.reference_type = 'LEAD_REFERRAL' THEN
         l_sales_rep := FND_API.g_false;
      ELSE
         l_resource_id := ozf_utility_pvt.get_resource_id(fnd_global.user_id);
         l_sales_rep := ozf_utility_pvt.has_sales_rep_role(l_resource_id);
      END IF;


      FND_DSQL.add_text('SELECT fu.utilization_id, fu.cust_account_id '||
                        ', fu.plan_type, fu.plan_id, o.offer_type, o.autopay_method '||
                        ', fu.product_level_type, fu.product_id, fu.acctd_amount_remaining, ');

      -- Added For Multi Currency - kpatro
      IF (p_summary_view IN ('AUTOPAY','AUTOPAY_LINE') AND l_funds_util_flt.autopay_check = 'AUTOPAY') THEN
          FND_DSQL.add_text( 'fu.plan_curr_amount_remaining amount_remaining, ');
      ELSE
         FND_DSQL.add_text('DECODE(NVL('''||l_currency_rec.claim_currency_code||''',fu.plan_currency_code), fu.plan_currency_code, fu.plan_curr_amount_remaining, fu.acctd_amount_remaining) amount_remaining, ');
      END IF;

          FND_DSQL.add_text('fu.scan_unit_remaining , fu.creation_date, ');

       -- Added For Multi Currency - kpatro
      IF (p_summary_view IN ('AUTOPAY','AUTOPAY_LINE') AND l_funds_util_flt.autopay_check = 'AUTOPAY') THEN
          FND_DSQL.add_text( 'fu.PLAN_CURRENCY_CODE currency_code, ');
      ELSE
          FND_DSQL.add_text('DECODE(NVL('''||l_currency_rec.claim_currency_code||''',fu.PLAN_CURRENCY_CODE), fu.PLAN_CURRENCY_CODE, fu.PLAN_CURRENCY_CODE, '''||l_currency_rec.functional_currency_code||''') currency_code, ');
      END IF;

          FND_DSQL.add_text( 'fu.bill_to_site_use_id ' ||
                        'FROM ozf_funds_utilized_all_b fu, ozf_offers o ');

      --Modified for Bugfix 5346249
      FND_DSQL.add_text('WHERE fu.plan_type = ''OFFR'' '||
                        'AND fu.plan_id = o.qp_list_header_id ' ||
                        'AND fu.org_id = ');
      FND_DSQL.add_bind(l_orgId);

     IF l_funds_util_flt.offer_type IS NOT NULL THEN
         FND_DSQL.add_text(' AND o.offer_type = ');
         FND_DSQL.add_bind(l_funds_util_flt.offer_type);
      ELSE
         FND_DSQL.add_text(' AND o.offer_type <> ''SCAN_DATA'' ');
      END IF;

      IF l_funds_util_flt.run_mode = 'OFFER_AUTOPAY' THEN
         FND_DSQL.add_text(' AND o.autopay_flag = ''Y'' ');
      ELSIF l_funds_util_flt.run_mode = 'OFFER_NO_AUTOPAY' THEN
         FND_DSQL.add_text(' AND (o.autopay_flag IS NULL OR o.autopay_flag = ''N'') ');
      END IF;

      IF l_funds_util_flt.offer_payment_method IS NOT NULL THEN
         IF l_funds_util_flt.offer_payment_method = 'NULL' THEN
            FND_DSQL.add_text(' AND o.autopay_method IS NULL ');
         ELSE
            FND_DSQL.add_text(' AND o.autopay_method = ');
            FND_DSQL.add_bind(l_funds_util_flt.offer_payment_method);
         END IF;
      END IF;

      IF (l_sales_rep = FND_API.g_true  AND  NOT l_is_admin ) THEN
         FND_DSQL.add_text(' AND (o.confidential_flag =''N'' OR ');
         FND_DSQL.add_text(' o.confidential_flag IS NULL OR ');
         FND_DSQL.add_text(' ( NVL(o.budget_offer_yn, ''N'') = ''N'' AND ');
         FND_DSQL.add_text(' EXISTS ( SELECT 1 FROM    ams_act_access_denorm act ');
         FND_DSQL.add_text(' WHERE act.object_id = o.qp_list_header_id ');
         FND_DSQL.add_text(' AND  act.object_type = ''OFFR'' ');
         FND_DSQL.add_text(' AND   act.resource_id= ');
         FND_DSQL.add_bind(l_resource_id);
         FND_DSQL.add_text('))');
         FND_DSQL.add_text(' OR ( NVL(o.budget_offer_yn, ''N'') = ''Y'' ');
         FND_DSQL.add_text(' AND EXISTS ( SELECT 1 FROM ams_act_access_denorm act ');
         FND_DSQL.add_text(' WHERE act.object_id = fu.fund_id ');
         FND_DSQL.add_text(' AND   act.object_type = ''FUND'' ');
         FND_DSQL.add_text(' AND   act.resource_id= ' );
         FND_DSQL.add_bind(l_resource_id);
         FND_DSQL.add_text(')))');
      END IF;

      Get_Utiz_Sql_Stmt_Where_Clause (
         p_summary_view        => p_summary_view
        ,p_funds_util_flt      => l_funds_util_flt
        ,px_currency_rec       => l_currency_rec
      );

   END IF;

   IF l_offer_flag = 'Y' AND l_price_list_flag = 'Y' THEN
      FND_DSQL.add_text('UNION ALL ');
   END IF;

   IF l_price_list_flag = 'Y' THEN
      FND_DSQL.add_text('SELECT fu.utilization_id, fu.cust_account_id '||
                        ', fu.plan_type, fu.plan_id, null, null '||
                        ', fu.product_level_type, fu.product_id '||
                        ', fu.acctd_amount_remaining,' );
      -- Added For Multii Currency - kpatro
    IF (p_summary_view IN ('AUTOPAY','AUTOPAY_LINE') AND l_funds_util_flt.autopay_check = 'AUTOPAY' ) THEN
       FND_DSQL.add_text( 'fu.plan_curr_amount_remaining amount_remaining, ');
    ELSE
        FND_DSQL.add_text('DECODE(NVL('''||l_currency_rec.claim_currency_code||''',fu.plan_currency_code), fu.plan_currency_code, fu.plan_curr_amount_remaining, fu.acctd_amount_remaining) amount_remaining, ');
    END IF;

       FND_DSQL.add_text('fu.scan_unit_remaining , fu.creation_date, ');

    -- Added For Multii Currency - kpatro
    IF (p_summary_view IN ('AUTOPAY','AUTOPAY_LINE') AND l_funds_util_flt.autopay_check = 'AUTOPAY') THEN
       FND_DSQL.add_text( 'fu.PLAN_CURRENCY_CODE currency_code, ');
    ELSE
       FND_DSQL.add_text('DECODE(NVL('''||l_currency_rec.claim_currency_code||''',fu.PLAN_CURRENCY_CODE), fu.PLAN_CURRENCY_CODE, fu.PLAN_CURRENCY_CODE, '''||l_currency_rec.functional_currency_code||''') currency_code, ');
    END IF;

      FND_DSQL.add_text('fu.bill_to_site_use_id ' ||
                        'FROM ozf_funds_utilized_all_b fu '||
                        'WHERE fu.plan_type = ''PRIC'' ' ||
                        'AND fu.org_id =');
      FND_DSQL.add_bind(l_orgId);
      FND_DSQL.add_text(' AND fu.cust_account_id = ');
      FND_DSQL.add_bind(l_funds_util_flt.cust_account_id);


      Get_Utiz_Sql_Stmt_Where_Clause(
         p_summary_view        => p_summary_view
        ,p_funds_util_flt      => l_funds_util_flt
        ,px_currency_rec        => l_currency_rec
      );
   END IF;

END Get_Utiz_Sql_Stmt_From_Clause;

---------------------------------------------------------------------
-- PROCEDURE
--   Get_Utiz_Sql_Stmt
--
-- PARAMETERS
--    p_summary_view     : Available values
--                          1. OZF_AUTOPAY_PVT -- 'AUTOPAY'
--                          2. OZF_CLAIM_LINE_PVT --'ACTIVITY', 'PRODUCT', 'SCHEDULE'
--    p_funds_util_flt   :
--    p_cust_account_id  : Only be used for OZF_AUTOPAY_PVT
--    x_utiz_sql_stmt    : Return datatype is VARCHAR2(500)
--
-- NOTE
--   1. This statement will be used for both OZF_AUTOPAY_PVT and OZF_CLAIM_LINE_PVT
--      to get funds_utilized SQL statement by giving in search criteria.
--
-- HISTORY
--   25-JUN-2002  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Get_Utiz_Sql_Stmt(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_summary_view        IN  VARCHAR2  := NULL
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,px_currency_rec       IN  OUT NOCOPY currency_rec_type
  ,p_cust_account_id     IN  NUMBER    := NULL

  ,x_utiz_sql_stmt       OUT NOCOPY VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER         := 1.0;
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Utiz_Sql_Stmt';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(1);

l_utiz_sql              VARCHAR2(4000) := NULL;
l_utiz_sql_from_clause  VARCHAR2(2000) := NULL;
l_funds_util_flt        funds_util_flt_type  := NULL;
l_line_util_flt         funds_util_flt_type  := NULL;
l_cust_account_id       NUMBER         := NULL;
l_scan_data_flag        VARCHAR2(1)    := 'N';
l_org_id                NUMBER;
l_currency_rec          currency_rec_type := px_currency_rec;

CURSOR csr_request_offer(cv_request_id IN NUMBER) IS
  SELECT o.qp_list_header_id
  ,      o.offer_type
  FROM   ozf_offers o
  ,      ozf_request_headers_all_b r
  WHERE  o.qp_list_header_id = r.offer_id
  AND    r.request_header_id = cv_request_id;
-- Added For Multi Currency - kpatro (As For Public API this is the starting point)
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
       , ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
   AND  org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
   --------------------- initialize -----------------------
   IF OZF_DEBUG_HIGH_ON THEN
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
    -- Added For Multi Currency - kpatro
     OPEN  csr_function_currency;
    FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
    CLOSE csr_function_currency;

   l_org_id := FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

   --------------------- start -----------------------
   l_funds_util_flt := p_funds_util_flt;

   -- default filter parameters based on claim line properties
   IF l_funds_util_flt.claim_line_id IS NOT NULL THEN
      IF p_summary_view IS NULL OR p_summary_view <> 'DEL_GRP_LINE_UTIL' THEN
         copy_util_flt(px_funds_util_flt => l_funds_util_flt);
      END IF;
   END IF;

   -- for special pricing requests, set offer id
   IF l_funds_util_flt.reference_type = 'SPECIAL_PRICE' AND
      l_funds_util_flt.reference_id IS NOT NULL AND
      l_funds_util_flt.activity_id IS NULL
   THEN
      l_funds_util_flt.activity_type := 'OFFR';
      OPEN csr_request_offer(l_funds_util_flt.reference_id);
      FETCH csr_request_offer INTO l_funds_util_flt.activity_id
                                 , l_funds_util_flt.offer_type;
      CLOSE csr_request_offer;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('----- p_funds_util_flt -----');
      OZF_Utility_PVT.debug_message('cust_account_id    : ' || l_funds_util_flt.cust_account_id);
      OZF_Utility_PVT.debug_message('activity_type      : ' || l_funds_util_flt.activity_type);
      OZF_Utility_PVT.debug_message('activity_id        : ' || l_funds_util_flt.activity_id);
      OZF_Utility_PVT.debug_message('offer_type         : ' || l_funds_util_flt.offer_type);
      OZF_Utility_PVT.debug_message('product_level_type : ' || l_funds_util_flt.product_level_type);
      OZF_Utility_PVT.debug_message('product_id         : ' || l_funds_util_flt.product_id);
      OZF_Utility_PVT.debug_message('Process_By         : ' || l_funds_util_flt.autopay_check); -- Added For Multi Currency - kpatro
      OZF_Utility_PVT.debug_message('l_currency_rec.universal_currency_code :' || l_currency_rec.universal_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code :' || l_currency_rec.claim_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code :' || l_currency_rec.functional_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code :' || l_currency_rec.transaction_currency_code);
      OZF_Utility_PVT.debug_message('l_currency_rec.association_currency_code :' || l_currency_rec.association_currency_code);
      OZF_Utility_PVT.debug_message('----------------------------');
   END IF;

   -- use FND_DSQL package to handle dynamic sql and bind variables
   FND_DSQL.init;

   IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
      l_scan_data_flag := 'Y';
   END IF;

   IF p_summary_view = 'AUTOPAY' THEN
      -- if cust account is specified in autopay parameter, do
      -- not group by cust_account_id in query
      -- R12 Group By Offer Enhancement
      -- Modified for FXGL Enhancement, Need to derive amount_remaining instead of acctd_amount_remaining
      -- Also need to group by currency as amount of different currencies cannot be added
      -- Modified for R12.1 enhancements, Need to select the value of bill_to_site_use_id.

      IF p_cust_account_id IS NOT NULL AND l_funds_util_flt.group_by_offer = 'N' THEN
         FND_DSQL.add_text('SELECT autopay_method, sum(amount_remaining), currency_code, bill_to_site_use_id  ');
      ELSIF p_cust_account_id IS NULL AND l_funds_util_flt.group_by_offer = 'N' THEN
         FND_DSQL.add_text('SELECT autopay_method, sum(amount_remaining), currency_code , bill_to_site_use_id , cust_account_id ');
      ELSIF p_cust_account_id IS NOT NULL AND l_funds_util_flt.group_by_offer = 'Y' THEN
         FND_DSQL.add_text('SELECT autopay_method, sum(amount_remaining), currency_code , bill_to_site_use_id , plan_id ');
      ELSIF p_cust_account_id IS NULL AND l_funds_util_flt.group_by_offer = 'Y' THEN
         FND_DSQL.add_text('SELECT autopay_method, sum(amount_remaining), currency_code , bill_to_site_use_id , cust_account_id, plan_id ');
      END IF;
      FND_DSQL.add_text( 'FROM (');
   ELSIF p_summary_view = 'AUTOPAY_LINE' THEN
      FND_DSQL.add_text( 'SELECT cust_account_id, plan_type, plan_id, bill_to_site_use_id '||
                         ', product_level_type, product_id '||
                         ', sum(amount_remaining), currency_code '||
                         'FROM ('||
                         'SELECT cust_account_id, plan_type, plan_id '||
                         ', decode(product_id, null, null, product_level_type) product_level_type '||
                         ', product_id product_id '||
                         ', acctd_amount_remaining , amount_remaining, currency_code, bill_to_site_use_id  '||
                         'FROM (');
   ELSIF p_summary_view = 'DEL_GRP_LINE_UTIL' THEN
     -- Modified for FXGL ER(amount selected)
      FND_DSQL.add_text( 'SELECT lu.claim_line_util_id, lu.utilization_id, lu.amount, lu.scan_unit, lu.currency_code  '||
                         'FROM (');
   ELSE
   -- Modified for FXGL ER
   -- R12 Multicurrency Enhancements: Amount Remaining changed from BUDGET to TRANSACTIONAL currency
      FND_DSQL.add_text( 'SELECT utilization_id, amount_remaining, scan_unit_remaining, currency_code '||
                         'FROM (');
   END IF;

   Get_Utiz_Sql_Stmt_From_Clause(
      p_summary_view        => p_summary_view
     ,p_funds_util_flt      => l_funds_util_flt
     ,p_currency_rec        => l_currency_rec
   );

        -- R12.1 autopay enhancement,  Need to select and group by bill_to_site_use_id.
        -- for p_summary_view = AUTOPAY and AUTOPAY_LINE.

   IF p_summary_view = 'AUTOPAY' THEN
      FND_DSQL.add_text( ') utiz ');
      -- R12 Enhancements: Group By Offer for Autopay.
      IF p_cust_account_id IS NOT NULL AND l_funds_util_flt.group_by_offer = 'N' THEN
         FND_DSQL.add_text('GROUP BY utiz.autopay_method, utiz.currency_code, utiz.bill_to_site_use_id ');
      ELSIF p_cust_account_id IS NULL AND l_funds_util_flt.group_by_offer = 'N' THEN
         FND_DSQL.add_text('GROUP BY utiz.cust_account_id, utiz.autopay_method, utiz.currency_code, utiz.bill_to_site_use_id ');
      ELSIF p_cust_account_id IS NOT NULL AND l_funds_util_flt.group_by_offer = 'Y' THEN
         FND_DSQL.add_text('GROUP BY utiz.plan_id, utiz.autopay_method , utiz.currency_code, utiz.bill_to_site_use_id ');
      ELSIF p_cust_account_id IS NULL AND l_funds_util_flt.group_by_offer = 'Y' THEN
         FND_DSQL.add_text('GROUP BY utiz.cust_account_id,utiz.plan_id, utiz.autopay_method , utiz.currency_code, utiz.bill_to_site_use_id ');
      END IF;
   ELSIF p_summary_view = 'AUTOPAY_LINE' THEN
      FND_DSQL.add_text( ') utiz ) '||
                         'GROUP BY cust_account_id, plan_type, plan_id, bill_to_site_use_id, product_level_type, product_id, currency_code '||
                         'ORDER BY cust_account_id, plan_type, plan_id, bill_to_site_use_id, product_level_type, product_id ');
   ELSIF p_summary_view = 'DEL_GRP_LINE_UTIL' THEN
      FND_DSQL.add_text( ') utiz, ozf_claim_lines_util lu '||
                         'WHERE lu.utilization_id = utiz.utilization_id '||
                         'AND lu.claim_line_id = ');
      FND_DSQL.add_bind( l_funds_util_flt.claim_line_id );
      FND_DSQL.add_text( ' ORDER BY utiz.creation_date desc ');
   ELSE
      FND_DSQL.add_text( ') utiz ');
      IF l_funds_util_flt.total_amount IS NOT NULL THEN
         IF l_funds_util_flt.total_amount >= 0 THEN
            FND_DSQL.add_text(' ORDER BY sign(utiz.amount_remaining) asc, utiz.creation_date asc');
         ELSE
            FND_DSQL.add_text(' ORDER BY sign(utiz.amount_remaining) desc, utiz.creation_date asc');
         END IF;
      ELSE
         FND_DSQL.add_text(' ORDER BY utiz.creation_date asc');
      END IF;
   END IF;

   x_utiz_sql_stmt := FND_DSQL.get_text(FALSE);

   IF OZF_DEBUG_HIGH_ON THEN
      --l_utiz_sql := FND_DSQL.get_text(TRUE);
      l_utiz_sql := SUBSTR(FND_DSQL.get_text(TRUE),1,4000);
      OZF_Utility_PVT.debug_message('----- UTIZ SQL -----');
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 1, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 251, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 501, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 751, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 1001, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 1251, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 1501, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 1751, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 2001, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 2251, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 2751, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 3001, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 3251, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 3501, 250));
      OZF_Utility_PVT.debug_message(SUBSTR(l_utiz_sql, 3751, 250));
      OZF_Utility_PVT.debug_message('--------------------');
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;



EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ATPY_UTIZ_STMT_ERR');
         FND_MSG_PUB.add;
      END IF;
END Get_Utiz_Sql_Stmt;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Cust_Trade_Profile
--
-- HISTORY
--    15/12/2003  yizhang  Create.
--    05-Sep-08   ateotia  Bug # 7379700 fixed.
--                Claim does not get closed if customer trade profile is set at account level only.
---------------------------------------------------------------------
PROCEDURE Get_Cust_Trade_Profile(
    p_cust_account_id        IN NUMBER
   ,x_cust_trade_profile     OUT NOCOPY g_cust_trade_profile_csr%rowtype
   ,p_site_use_id            IN NUMBER := NULL
) IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Cust_Trade_Profile';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;

l_cust_trade_profile   g_cust_trade_profile_csr%rowtype;
l_party_id             NUMBER;

CURSOR csr_get_party_id(cv_cust_account_id IN NUMBER) IS
  SELECT party_id
  FROM hz_cust_accounts
  WHERE cust_account_id = cv_cust_account_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- bug # 7379700 fixed by ateotia (+)
   IF p_site_use_id is not null THEN
      -- 1. get trade profile by site_use_id
      OPEN g_site_trade_profile_csr(p_site_use_id);
      FETCH g_site_trade_profile_csr into l_cust_trade_profile;
      CLOSE g_site_trade_profile_csr;
   END IF;

   IF p_cust_account_id is not null
   AND l_cust_trade_profile.trade_profile_id IS NULL THEN
      -- 2. if trade profile is not there for site,
      --    then get trade profile at customer account level
      OPEN g_cust_trade_profile_csr(p_cust_account_id);
      FETCH g_cust_trade_profile_csr into l_cust_trade_profile;
      CLOSE g_cust_trade_profile_csr;

      -- 3. if trade profile is not there for customer,
      --    then get trade profile by party_id level
      IF l_cust_trade_profile.trade_profile_id IS NULL THEN
         OPEN csr_get_party_id(p_cust_account_id);
         FETCH csr_get_party_id INTO l_party_id;
         CLOSE csr_get_party_id;

         IF l_party_id IS NOT NULL THEN
            OPEN g_party_trade_profile_csr(l_party_id);
            FETCH g_party_trade_profile_csr INTO l_cust_trade_profile;
            CLOSE g_party_trade_profile_csr;
         END IF;
      END IF;
   END IF;
   -- bug # 7379700 fixed by ateotia (-)

   x_cust_trade_profile := l_cust_trade_profile;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
END Get_Cust_Trade_Profile;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_Payment_Detail
--
-- PURPOSE
--    This procedure will return the payment method, vendor ID,vendor
--    site ID from customer trade profile
--
-- PARAMETERS
-- p_cust_account       - Cust Account ID
-- x_payment_method     - Payment Method
-- x_vendor_id          - Vendor ID
-- x_vendor_site_id     - Vendor Site ID
--
-- NOTES
-- HISTORY
--   30-APR-2010  KPATRO  Created for ER#9453443.
---------------------------------------------------------------------
PROCEDURE Get_Payment_Detail(
         p_cust_account        IN  NUMBER,
         p_billto_site_use_id  IN NUMBER,
         x_payment_method      OUT NOCOPY VARCHAR2,
         x_vendor_id           OUT NOCOPY NUMBER,
         x_vendor_site_id      OUT NOCOPY NUMBER,
         x_return_status       OUT NOCOPY VARCHAR2
) IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Payment_Detail';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;

l_cust_trade_profile   g_cust_trade_profile_csr%rowtype;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- get payment method information from trade profile
    Get_Cust_Trade_Profile(
      p_cust_account_id     => p_cust_account
     ,x_cust_trade_profile  => l_cust_trade_profile
     ,p_site_use_id         => p_billto_site_use_id
    );

    IF l_cust_trade_profile.trade_profile_id IS NOT NULL THEN
       x_payment_method := l_cust_trade_profile.payment_method;
      IF l_cust_trade_profile.payment_method <> FND_API.G_MISS_CHAR THEN

         IF (l_cust_trade_profile.payment_method IN ('CHECK', 'EFT','WIRE','AP_DEBIT','AP_DEFAULT')) THEN
           x_vendor_id := l_cust_trade_profile.vendor_id;
           x_vendor_site_id := l_cust_trade_profile.vendor_site_id;
         END IF;
      END IF;

     END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Get_Payment_Detail;

-- Start - Fix for ER#9453443

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Cust_Trade_Profile
--
-- HISTORY
--    15/12/2003  yizhang  Create.
---------------------------------------------------------------------
PROCEDURE Validate_Cust_Trade_Profile(
    p_cust_trade_profile     IN g_cust_trade_profile_csr%rowtype
   ,x_return_status          OUT NOCOPY VARCHAR2
) IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Validate_Cust_Trade_Profile';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;

CURSOR csr_cust_name(cv_cust_account_id IN NUMBER) IS
  SELECT CONCAT(CONCAT(party.party_name, ' ('), CONCAT(ca.account_number, ') '))
  FROM hz_cust_accounts ca
  ,    hz_parties party
  WHERE ca.party_id = party.party_id
  AND ca.cust_account_id = cv_cust_account_id;

l_cust_account_id  number := p_cust_trade_profile.cust_account_id;
l_cust_name_num    VARCHAR2(70);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_cust_trade_profile.claim_currency is null OR
      p_cust_trade_profile.claim_currency = FND_API.G_MISS_CHAR THEN -- [BUG 4217781 FIXING]
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

   IF p_cust_trade_profile.payment_method is null OR
      p_cust_trade_profile.payment_method = FND_API.G_MISS_CHAR THEN -- [BUG 4217781 FIXING]
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

   IF p_cust_trade_profile.payment_method = 'CHECK' THEN
      IF p_cust_trade_profile.vendor_id is NULL OR
         p_cust_trade_profile.vendor_site_id is NULL  THEN
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
   ELSIF p_cust_trade_profile.payment_method = 'CREDIT_MEMO' THEN
      IF p_cust_trade_profile.site_use_id is NULL THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            OPEN csr_cust_name(l_cust_account_id);
            FETCH csr_cust_name INTO l_cust_name_num;
            CLOSE csr_cust_name;

            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ATPY_SITEID_MISS');
            FND_MESSAGE.Set_Token('ID',l_cust_name_num);
            FND_MSG_PUB.ADD;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ATPY_CUSTOMER_ERR');
        FND_MSG_PUB.add;
     END IF;
END Validate_Cust_Trade_Profile;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Prorate_Earnings_Flag
--
-- HISTORY
--    01/21/2003  yizhang  Create.
---------------------------------------------------------------------
PROCEDURE Get_Prorate_Earnings_Flag(
    p_funds_util_flt         IN funds_util_flt_type
   ,x_prorate_earnings_flag  OUT NOCOPY VARCHAR2
) IS
l_api_name     CONSTANT VARCHAR2(30)   := 'Get_Prorate_Earnings_Flag';
l_full_name    CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;

l_prorate_earnings_flag     VARCHAR2(1);

CURSOR csr_line_flag(cv_claim_line_id IN NUMBER) IS
  SELECT prorate_earnings_flag
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

 -- fix for bug 5042046
CURSOR csr_system_flag IS
  SELECT NVL(prorate_earnings_flag, 'F')
  FROM ozf_sys_parameters
  WHERE org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF p_funds_util_flt.prorate_earnings_flag IS NOT NULL THEN
      l_prorate_earnings_flag := p_funds_util_flt.prorate_earnings_flag;
   ELSE
      OPEN csr_line_flag(p_funds_util_flt.claim_line_id);
      FETCH csr_line_flag INTO l_prorate_earnings_flag;
      CLOSE csr_line_flag;

      IF l_prorate_earnings_flag IS NULL THEN
         OPEN csr_system_flag;
         FETCH csr_system_flag INTO l_prorate_earnings_flag;
         CLOSE csr_system_flag;
      END IF;
   END IF;
   x_prorate_earnings_flag := l_prorate_earnings_flag;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
   END IF;
END Get_Prorate_Earnings_Flag;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund_Adjustment
--
-- PURPOSE
--    This procedure creates a fund adjustment with amount zero
--    for the given offer.
--    Unlike Adjust_Fund_Utilization, which is called after claim
--    is approved, this procedure is called when earnings are
--    associated to the claim.
--
-- HISTORY
--    07/22/2004  yizhang  Create.
--    07/29/2005  sshivali Cleared GSCC warning
--    14/06/06    azahmed  Bugfix 5333804
--     06/08/06   azahmed  Modified for FXGL ER: Adjustments must be created in
--                          fund currency and not in plan currrency
---------------------------------------------------------------------
PROCEDURE Create_Fund_Adjustment(
   p_offer_id           IN  NUMBER
  ,p_cust_account_id    IN  NUMBER
  ,p_product_id         IN  NUMBER
  ,p_product_level_type IN  VARCHAR2
  ,p_fund_id            IN  NUMBER
  ,p_reference_type     IN  VARCHAR2
  ,p_reference_id       IN  NUMBER
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,x_adj_util_id         OUT  NOCOPY NUMBER
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'Create_Fund_Adjustment';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_currOrgId            NUMBER     := MO_GLOBAL.GET_CURRENT_ORG_ID();
l_cust_account_id      NUMBER;
l_fund_id              NUMBER;
l_act_budget_id        NUMBER;
l_fund_curr_code       VARCHAR2(15);
l_plan_curr_code       VARCHAR2(15);
l_accrual_curr_code    VARCHAR2(15);

l_act_budgets_rec      ozf_actbudgets_pvt.act_budgets_rec_type;
l_act_util_rec         ozf_actbudgets_pvt.act_util_rec_type ;

--Bug5333804
-- Reverted back for Bugfix 5154157
CURSOR csr_source_fund(cv_offer_id IN NUMBER, cv_fund_id IN NUMBER) IS
SELECT  budget_source_id,
         request_currency,
         ARC_ACT_BUDGET_USED_BY,
         ACT_BUDGET_USED_BY_ID,
         APPROVED_IN_CURRENCY
 FROM  ozf_act_budgets
 WHERE transfer_type = 'REQUEST'
 AND   act_budget_used_by_id = cv_offer_id
 AND   budget_source_id  =  cv_fund_id;



l_fu_plan_type  VARCHAR2(30);
l_fu_plan_id      NUMBER;

CURSOR csr_acc_adjustment(cv_offer_id IN NUMBER, cv_cust_account_id IN NUMBER, cv_fund_id IN NUMBER,
                          cv_product_id IN NUMBER, cv_product_level_type IN VARCHAR2) IS
  SELECT utilization_id
  FROM   ozf_funds_utilized_all_b
  WHERE  plan_type = 'OFFR'
  AND  org_id =   l_currOrgId
  AND    plan_id   = cv_offer_id
  AND    fund_id  = cv_fund_id
  AND    adjustment_type_id IN ( -11, -1)
  AND    ( ( cv_product_id IS NULL AND product_id IS NULL )
            OR product_id = cv_product_id )
  AND    (  (cv_product_level_type IS NULL AND product_level_type IS NULL )
           OR product_level_type = cv_product_level_type )
  AND    utilization_type IN ( 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
  AND    cust_account_id = cv_cust_account_id;

BEGIN
  ----------------------- initialize --------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  -- This package is called only for non scan data offer adjustments


  -- Check if adjustment preexists
  OPEN csr_acc_adjustment(p_offer_id, p_cust_account_id, p_fund_id, p_product_id, p_product_level_type);
  FETCH csr_acc_adjustment INTO x_adj_util_id;
  CLOSE csr_acc_adjustment;

   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('x_adj_util_id:' || x_adj_util_id);
   END IF;
  IF x_adj_util_id IS NOT NULL THEN
     RETURN;
  END IF;

  -- create adjustment
  OPEN csr_source_fund(p_offer_id, p_fund_id);
  FETCH csr_source_fund INTO l_fund_id, l_plan_curr_code, l_fu_plan_type, l_fu_plan_id, l_fund_curr_code;
  CLOSE csr_source_fund;

  l_act_util_rec.fund_request_currency_code := OZF_ACTBUDGETS_PVT.Get_Object_Currency
                                                  ( p_object          => l_fu_plan_type
                                                  , p_object_id       => l_fu_plan_id
                                                  , x_return_status   => l_return_status
                                                  );

   IF OZF_DEBUG_HIGH_ON THEN
           OZF_Utility_PVT.debug_message('Offer sourcing budget: '||l_fund_id);
   END IF;


   l_act_budgets_rec.parent_src_apprvd_amt := 0;
   l_act_budgets_rec.request_amount := 0;
   l_act_budgets_rec.act_budget_used_by_id := p_offer_id;
   l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
   l_act_budgets_rec.budget_source_type := 'OFFR';
   l_act_budgets_rec.budget_source_id := p_offer_id;
   l_act_budgets_rec.request_currency := l_plan_curr_code;
   l_act_budgets_rec.request_date := SYSDATE;
   l_act_budgets_rec.status_code := 'APPROVED';
   l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status (
                                      'OZF_BUDGETSOURCE_STATUS'
                                      ,l_act_budgets_rec.status_code
                                      );
   l_act_budgets_rec.transfer_type := 'UTILIZED';
   l_act_budgets_rec.approval_date := SYSDATE;
   l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
   l_act_budgets_rec.parent_source_id := l_fund_id;

   l_act_util_rec.gl_date := SYSDATE;
   IF p_reference_type = 'LEAD_REFERRAL' THEN
       l_act_util_rec.utilization_type := 'LEAD_ADJUSTMENT';
       l_act_util_rec.adjustment_type_id := -1;
   ELSE
      l_act_util_rec.utilization_type := 'ADJUSTMENT';
      l_act_util_rec.adjustment_type_id := -11;
   END IF;

   l_act_util_rec.adjustment_type := 'STANDARD';

   l_act_util_rec.cust_account_id := p_cust_account_id;
   l_act_util_rec.product_id := p_product_id;
   l_act_util_rec.product_level_type := p_product_level_type;

    -- Bug 4729839
   l_act_util_rec.org_id := l_currOrgId;

   l_act_util_rec.reference_type := p_reference_type;
   l_act_util_rec.reference_id := p_reference_id;
   l_act_util_rec.plan_currency_code := l_plan_curr_code; --Added for multicurrency ER

   OZF_Fund_Adjustment_PVT.process_act_budgets (
                       x_return_status  => l_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data   => x_msg_data,
                       p_act_budgets_rec => l_act_budgets_rec,
                       p_act_util_rec   =>l_act_util_rec,
                       x_act_budget_id  => l_act_budget_id
                      );
   IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE fnd_api.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
   END IF;


  -- Query the adjustment created and return the util id
  OPEN csr_acc_adjustment(p_offer_id, p_cust_account_id, p_fund_id, p_product_id, p_product_level_type);
  FETCH csr_acc_adjustment INTO x_adj_util_id;
  CLOSE csr_acc_adjustment;
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(' New - 1:x_adj_util_id:' || x_adj_util_id);
  END IF;


  ------------------------- finish -------------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
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

END Create_Fund_Adjustment;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Line_Util_Tbl
--
-- HISTORY
--    05/11/2001  mchang  Create.
--    05/08/2006  azahmed  Modified for FXGL ER
--    01/09/2009  kpatro   Modified for Bug 7658894
---------------------------------------------------------------------
PROCEDURE Create_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_currency_rec           IN    currency_rec_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version       CONSTANT NUMBER       := 1.0;
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Line_Util_Tbl';
l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_return_status              VARCHAR2(1);

l_claim_id                   NUMBER;
l_access                     VARCHAR2(1) := 'N';
l_line_util_amount           NUMBER;
l_claim_currency_code        VARCHAR2(15);
l_claim_exc_rate             NUMBER;
l_claim_exc_date             DATE;
l_claim_exc_type             VARCHAR2(30);
l_org_id                     NUMBER;
l_line_util_rec              line_util_rec_type;
l_line_util_id               NUMBER;
l_currency_rec               currency_rec_type := p_currency_rec;


CURSOR csr_claim_exc(cv_claim_line_id IN NUMBER) IS
  SELECT cla.currency_code
  ,      cla.exchange_rate_type
  ,      cla.exchange_rate_date
  ,      cla.exchange_rate
  FROM ozf_claims cla
  ,    ozf_claim_lines ln
  WHERE ln.claim_id = cla.claim_id
  AND ln.claim_line_id = cv_claim_line_id;

CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

 -- Bug fix 7463302
 CURSOR csr_claim_line_util_amount(cv_claim_line_util_id IN NUMBER) IS
  SELECT nvl(amount,0)
  FROM ozf_claim_lines_util
  WHERE claim_line_util_id = cv_claim_line_util_id;

CURSOR csr_function_currency(cv_org_id NUMBER) IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = cv_org_id;

--nepanda Fix for Bug 9075792 - this code is moved to java layer to ClaimAssoVO
/* CURSOR csr_line_util_amount(cv_claim_line_id      IN NUMBER,
                             cv_claim_line_util_id IN NUMBER) IS
  SELECT SUM(amount)
  FROM  ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id
  AND   claim_line_util_id <> cv_claim_line_util_id;

CURSOR csr_total_util_lines (cv_claim_line_id      IN NUMBER)IS
   SELECT COUNT(1),
          MAX(claim_line_util_id)
   FROM  ozf_claim_lines_util_all
   WHERE claim_line_id = cv_claim_line_id; */

  l_sum_amount           NUMBER :=0;
  l_last_record_num      NUMBER := 0;
  l_entered_diff_amount  NUMBER := 0;
  l_line_util_tot_amt    NUMBER := 0;
  l_last_line_util_id    NUMBER;
  l_line_util_count      NUMBER := 0;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Line_Util_Tbl;

  IF OZF_DEBUG_HIGH_ON THEN
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
         )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  --Claim Access Check: Abort process, if current user doesnt have access on claim.
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_line_util_tbl.count > 0 THEN
    FOR j IN p_line_util_tbl.FIRST..p_line_util_tbl.LAST LOOP
      IF p_line_util_tbl.EXISTS(j) THEN

        OPEN csr_claim_id(p_line_util_tbl(j).claim_line_id);
        FETCH csr_claim_id INTO l_claim_id;
        CLOSE csr_claim_id;

        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => l_claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => x_msg_count
             , X_Msg_Data           => x_msg_data
             , X_access             => l_access);

        IF l_access = 'N' THEN
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.set_name('OZF','OZF_CLAIM_NO_ACCESS');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  --------------------- Create Line Util Table -----------------------
  IF p_line_util_tbl.FIRST IS NOT NULL THEN

    --Get currency and exchange rate details of claim line.
    OPEN csr_claim_exc(p_line_util_tbl(p_line_util_tbl.FIRST).claim_line_id);
    FETCH csr_claim_exc INTO  l_claim_currency_code
                            , l_claim_exc_type
                            , l_claim_exc_date
                            , l_claim_exc_rate;
    CLOSE csr_claim_exc;

    IF l_currency_rec.claim_currency_code IS NULL THEN
       l_currency_rec.claim_currency_code := l_claim_currency_code;
    END IF;

  --Get FUNCTIONAL currency from system parameters
  IF l_currency_rec.functional_currency_code IS NULL THEN
     OPEN  csr_function_currency(MO_GLOBAL.GET_CURRENT_ORG_ID());
     FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
     CLOSE csr_function_currency;
  END IF;

  --Set UNIVERSAL currency from profile.
  IF l_currency_rec.universal_currency_code IS NULL THEN
     l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');
   END IF;
  IF l_currency_rec.transaction_currency_code IS NULL THEN
     l_currency_rec.transaction_currency_code :=  l_currency_rec.claim_currency_code;
  END IF;
    --Association process started for all earnings/adjustments of current
    --claim line.
    FOR i IN p_line_util_tbl.FIRST..p_line_util_tbl.LAST LOOP
      IF p_line_util_tbl.exists(i) THEN
        l_line_util_rec := p_line_util_tbl(i);
        l_line_util_rec.currency_code := l_claim_currency_code;
        l_line_util_rec.exchange_rate_type := l_claim_exc_type;
        l_line_util_rec.exchange_rate_date := l_claim_exc_date;
        l_line_util_rec.exchange_rate := l_claim_exc_rate;
        l_line_util_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

        l_line_util_rec.object_version_number := 1;
        l_line_util_rec.last_updated_by := NVL(FND_GLOBAL.user_id,-1);
        l_line_util_rec.created_by := NVL(FND_GLOBAL.user_id,-1);
        l_line_util_rec.last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);


        Create_Line_Util(
               p_api_version       => 1.0
             , p_init_msg_list     => FND_API.g_false
             , p_commit            => FND_API.g_false
             , p_validation_level  => p_validation_level
             , x_return_status     => l_return_status
             , x_msg_count         => x_msg_count
             , x_msg_data          => x_msg_data
             , p_line_util_rec     => l_line_util_rec
             , p_currency_rec      => l_currency_rec
             , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
             , x_line_util_id      => l_line_util_id
        );

        --l_last_line_util_id := l_line_util_id;
        --OZF_Utility_PVT.debug_message('l_last_line_util_id :'|| l_last_line_util_id );

        IF l_return_status =  fnd_api.g_ret_sts_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF;
    END LOOP;

    --nepanda Fix for Bug 9075792 - this code is moved to java layer to ClaimAssoVO
    --//BKUNJAN 7463302 - Rounding Issue : Modified the Code
/*   OPEN  csr_total_util_lines(l_line_util_rec.claim_line_id);
    FETCH csr_total_util_lines INTO l_line_util_count,l_last_line_util_id;
    CLOSE csr_total_util_lines;

    IF OZF_DEBUG_HIGH_ON THEN
       OZF_Utility_PVT.debug_message('l_line_util_count :'|| l_line_util_count );
       OZF_Utility_PVT.debug_message('l_last_line_util_id :'|| l_last_line_util_id );
       OZF_Utility_PVT.debug_message('G_ENTERED_AMOUNT :'|| G_ENTERED_AMOUNT );
    END IF;


    IF l_line_util_count = 1 THEN
       l_line_util_amount := G_ENTERED_AMOUNT;

    ELSIF l_line_util_count > 1 THEN
       OPEN  csr_line_util_amount(l_line_util_rec.claim_line_id,l_last_line_util_id);
       FETCH csr_line_util_amount INTO l_line_util_tot_amt;
       CLOSE csr_line_util_amount;

       l_line_util_amount := G_ENTERED_AMOUNT - l_line_util_tot_amt;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
       OZF_Utility_PVT.debug_message('l_line_util_tot_amt :'|| l_line_util_tot_amt );
       OZF_Utility_PVT.debug_message('l_line_util_amount :'|| l_line_util_amount );
    END IF;

    -- Update Last record of Claim line Util
    UPDATE ozf_claim_lines_util_all
    SET amount                = l_line_util_amount
    WHERE claim_line_util_id = l_last_line_util_id;
  */

    -- Update Claim Line: set earnings_associated_flag to TRUE
    UPDATE ozf_claim_lines_all
      SET earnings_associated_flag = 'T'
      WHERE claim_line_id = l_line_util_rec.claim_line_id;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Create_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Line_Util_Tbl;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Line_Util
--
-- HISTORY
--    05/10/2001  mchang  Create.
--    07/22/2002  yizhang add p_mode for security check
--    05/08/2006  azahmed Modified for FXGL ER
---------------------------------------------------------------------
PROCEDURE Create_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_line_util_rec       IN  line_util_rec_type
  ,p_currency_rec        IN  currency_rec_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
  ,x_line_util_id        OUT NOCOPY NUMBER
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Create_Line_Util';
l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);

l_line_util_rec          line_util_rec_type := p_line_util_rec;
l_currency_rec           currency_rec_type := p_currency_rec;
l_line_util_count        NUMBER;
l_line_acctd_amount      NUMBER;

l_line_util_amount       NUMBER;
l_exchange_rate_type     VARCHAR2(30);
l_exchange_rate_date     DATE;
l_exchange_rate          NUMBER;
l_convert_exchange_rate  NUMBER;


CURSOR csr_line_util_seq IS
 SELECT ozf_claim_lines_util_all_s.NEXTVAL
 FROM DUAL;

CURSOR csr_line_util_count(cv_line_util_id IN NUMBER) IS
 SELECT COUNT(claim_line_util_id)
 FROM  ozf_claim_lines_util
 WHERE claim_line_util_id = cv_line_util_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Line_Util;

  IF OZF_DEBUG_HIGH_ON THEN
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

  IF p_line_util_rec.amount IS NOT NULL THEN

      IF l_line_util_rec.utilization_id > -1 THEN
        IF l_currency_rec.association_currency_code = l_currency_rec.transaction_currency_code THEN
          IF l_line_util_rec.amount IS NOT NULL AND l_line_util_rec.amount <> 0 THEN
            -- Bugfix 5528210
            OZF_UTILITY_PVT.Convert_Currency
                    ( p_from_currency => l_currency_rec.association_currency_code
                    , p_to_currency   => l_currency_rec.functional_currency_code
                    , p_conv_type     => l_line_util_rec.exchange_rate_type
                    , p_conv_date     => l_line_util_rec.exchange_rate_date
                    , p_from_amount   => l_line_util_rec.amount
                    , x_return_status => l_return_status
                    , x_to_amount     => l_line_util_rec.acctd_amount
                    , x_rate          => l_convert_exchange_rate
                    );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
          ELSE
            l_line_util_rec.acctd_amount := 0;
          END IF;
        ELSE
          l_line_util_rec.acctd_amount := l_line_util_rec.amount;
        END IF;
      END IF;

      l_line_util_rec.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_line_util_rec.acctd_amount, l_currency_rec.functional_currency_code);
      l_line_util_rec.amount       := OZF_UTILITY_PVT.CurrRound(l_line_util_rec.amount, l_currency_rec.association_currency_code);

      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_line_util_rec.acctd_amount = '||l_line_util_rec.acctd_amount);
        OZF_Utility_PVT.debug_message('l_line_util_rec.utilization_id = '||l_line_util_rec.utilization_id);
        OZF_Utility_PVT.debug_message('l_line_util_rec.amount - Before Update_Fund_Utils() : '||l_line_util_rec.amount);
      END IF;

      Update_Fund_Utils(
              p_line_util_rec  => l_line_util_rec
            , p_asso_amount    => -NVL(l_line_util_rec.amount,0)
            , p_mode           => 'CALCULATE'
            , px_currency_rec  => l_currency_rec
            , x_return_status  => l_return_status
            , x_msg_count      => x_msg_count
            , x_msg_data       => x_msg_data
            );

          IF l_return_status =  fnd_api.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
          END IF;

     IF OZF_DEBUG_HIGH_ON THEN
       OZF_Utility_PVT.debug_message('l_line_util_rec.amount - After Update_Fund_Utils() : '||l_line_util_rec.amount);
     END IF;

 END IF;  --l_utilization_id > -1 check

 --Since, amount column of OZF_CLAIM_LINES_UTIL table expect amount in CLAIM currency. Hence, need to convert
 --l_line_util_rec.amount into CLAIM currency, before creation of association record.
 IF l_line_util_rec.amount IS NOT NULL AND l_line_util_rec.amount <> 0 THEN
   IF l_currency_rec.association_currency_code <> l_currency_rec.claim_currency_code THEN
     OZF_UTILITY_PVT.Convert_Currency
                    ( p_from_currency => l_currency_rec.association_currency_code
                    , p_to_currency   => l_currency_rec.claim_currency_code
                    , p_conv_type     => l_line_util_rec.exchange_rate_type
                    --, p_conv_rate     => l_line_util_rec.exchange_rate
                    , p_conv_date     => l_line_util_rec.exchange_rate_date
                    , p_from_amount   => l_line_util_rec.amount
                    , x_return_status => l_return_status
                    , x_to_amount     => l_line_util_amount
                    , x_rate          => l_convert_exchange_rate
                    );

     IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('p_from_currency : '||l_currency_rec.association_currency_code);
         OZF_Utility_PVT.debug_message('p_to_currency   : '||l_currency_rec.claim_currency_code);
         OZF_Utility_PVT.debug_message('p_conv_type     : '||l_line_util_rec.exchange_rate_type);
         OZF_Utility_PVT.debug_message('p_conv_rate     : '||l_line_util_rec.exchange_rate);
         OZF_Utility_PVT.debug_message('p_conv_date     : '||l_line_util_rec.exchange_rate_date);
         OZF_Utility_PVT.debug_message('p_from_amount   : '||l_line_util_rec.amount);
         OZF_Utility_PVT.debug_message('x_to_amount     : '||l_line_util_amount);
     END IF;

     IF l_line_util_amount IS NOT NULL AND l_line_util_amount <> 0 THEN
       l_line_util_rec.amount := OZF_UTILITY_PVT.CurrRound(l_line_util_amount, l_currency_rec.claim_currency_code);
     END IF;
   END IF;
 ELSE
   l_line_util_rec.amount := 0;
 END IF;
 IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('Inserting association record...');
     OZF_Utility_PVT.debug_message('claim_line_id : '||l_line_util_rec.claim_line_id);
     OZF_Utility_PVT.debug_message('utilization_id : '||l_line_util_rec.utilization_id);
     OZF_Utility_PVT.debug_message('amount         : '||l_line_util_rec.amount);
     OZF_Utility_PVT.debug_message('acctd amount         : '||l_line_util_rec.acctd_amount);
 END IF;


  IF l_line_util_rec.claim_line_util_id IS NULL THEN
    LOOP
      OPEN  csr_line_util_seq;
      FETCH csr_line_util_seq INTO l_line_util_rec.claim_line_util_id;
      CLOSE csr_line_util_seq;
      -- Check the uniqueness of the identifier
      OPEN  csr_line_util_count(l_line_util_rec.claim_line_util_id);
      FETCH csr_line_util_count INTO l_line_util_count;
      CLOSE csr_line_util_count;
      -- Exit when the identifier uniqueness is established
      EXIT WHEN l_line_util_count = 0;
   END LOOP;
  END IF;

  INSERT INTO ozf_claim_lines_util_all (
      claim_line_util_id,
      object_version_number,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      claim_line_id,
      utilization_id,
      amount,
      currency_code,
      exchange_rate_type,
      exchange_rate_date,
      exchange_rate,
      acctd_amount,
      util_curr_amount,
      plan_curr_amount,
      univ_curr_amount,
      scan_unit,
      activity_product_id,
      uom_code,
      quantity,
      org_id,
      fxgl_acctd_amount,
      utilized_acctd_amount
  )
  VALUES (
      l_line_util_rec.claim_line_util_id,
      l_line_util_rec.object_version_number,
      SYSDATE,
      l_line_util_rec.last_updated_by,
      SYSDATE,
      l_line_util_rec.created_by,
      l_line_util_rec.last_update_login,
      l_line_util_rec.claim_line_id,
      l_line_util_rec.utilization_id,
      l_line_util_rec.amount,
      l_line_util_rec.currency_code,
      l_line_util_rec.exchange_rate_type,
      l_line_util_rec.exchange_rate_date,
      l_line_util_rec.exchange_rate,
      l_line_util_rec.acctd_amount,
      l_line_util_rec.util_curr_amount,
      l_line_util_rec.plan_curr_amount,
      l_line_util_rec.univ_curr_amount,
      l_line_util_rec.scan_unit,
      l_line_util_rec.activity_product_id,
      l_line_util_rec.uom_code,
      l_line_util_rec.quantity,
      l_line_util_rec.org_id,
      l_line_util_rec.fxgl_acctd_amount,
      l_line_util_rec.utilized_acctd_amount

  );

  ------------------------- finish -------------------------------
  x_line_util_id := l_line_util_rec.claim_line_util_id;

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
    ROLLBACK TO Create_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Line_Util;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Util_Tbl
--
-- HISTORY
--    05/12/2001  mchang  Create.
--    07/22/2002  yizhang add p_mode for security check
--   7-Aug-06     azahmed Modified for FXGL ER
---------------------------------------------------------------------
PROCEDURE Update_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_mode                   IN    VARCHAr2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version       CONSTANT NUMBER       := 1.0;
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Line_Util_Tbl';
l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_return_status              VARCHAR2(1);

l_line_util_rec              line_util_rec_type;
l_claim_id                   NUMBER;
l_object_version             NUMBER;
l_access                     VARCHAR2(1) := 'N';
i                            PLS_INTEGER;


-- Cursor to get claim_id
CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Update_Line_Util_Tbl;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_line_util_tbl.count > 0 THEN
    FOR j IN p_line_util_tbl.FIRST..p_line_util_tbl.LAST LOOP
      IF p_line_util_tbl.EXISTS(j) THEN

        OPEN csr_claim_id(p_line_util_tbl(j).claim_line_id);
        FETCH csr_claim_id INTO l_claim_id;
        CLOSE csr_claim_id;

        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => l_claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => x_msg_count
             , X_Msg_Data           => x_msg_data
             , X_access             => l_access);

        IF l_access = 'N' THEN
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.set_name('OZF','OZF_CLAIM_NO_ACCESS');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  --------------------- Update Claim Line Table -----------------------

  i := p_line_util_tbl.FIRST;
  IF i IS NOT NULL THEN
    LOOP
      l_line_util_rec := p_line_util_tbl(i);
      IF l_line_util_rec.claim_line_util_id IS NOT NULL THEN
        l_line_util_rec.amount := OZF_UTILITY_PVT.CurrRound(l_line_util_rec.amount, l_line_util_rec.currency_code);
        l_line_util_rec.update_from_tbl_flag := FND_API.g_true;
        Update_Line_Util(
                 p_api_version       => l_api_version
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => p_validation_level
               , x_return_status     => l_return_status
               , x_msg_count         => x_msg_count
               , x_msg_data          => x_msg_data
               , p_line_util_rec     => l_line_util_rec
               , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
               , x_object_version    => l_object_version
        );
        IF l_return_status =  fnd_api.g_ret_sts_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;
      EXIT WHEN i = p_line_util_tbl.LAST;
      i := p_line_util_tbl.NEXT(i);
    END LOOP;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Update_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

END Update_Line_Util_Tbl;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Util
--
-- HISTORY
--    05/10/2001  mchang  Create.
--    07/22/2002  yizhang add p_mode for security check
--    15-Mar-06   azahmed  Bugfix 5101106 added condition to update fu only when util_id > -1
--    08-Aug-06   azahmed  Modifed for FXGL ER
----------------------------------------------------------------------
PROCEDURE Update_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_line_util_rec       IN  line_util_rec_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
  ,x_object_version      OUT NOCOPY NUMBER
)
IS
l_api_version       CONSTANT NUMBER       := 1.0;
l_api_name          CONSTANT VARCHAR2(30) := 'Update_Line_Util';
l_full_name         CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status              VARCHAR2(1);

l_line_util_rec              line_util_rec_type;
l_claim_id                   NUMBER;
l_lu_old_amt                 NUMBER;
l_lu_old_scan_unit           NUMBER;
l_utilization_rec            OZF_Fund_Utilized_PVT.utilization_rec_type;
l_currency_rec               currency_rec_type ;

l_access                     VARCHAR2(1) := 'N';
l_total_exist_util_amt       NUMBER;
l_line_acctd_amount          NUMBER;
l_exchange_rate              NUMBER;
l_claim_date                 DATE;
l_utiz_currency              VARCHAR2(15);
l_old_utiz_amount            NUMBER;
l_update_fund_amount         NUMBER;
l_update_acctd_fund_amount   NUMBER;
l_rate                       NUMBER;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id, acctd_amount
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

--Cursor changed for Claims-Multicurrency ER
CURSOR csr_lu_old_amt(cv_line_util_id IN NUMBER) IS
  SELECT lu.amount
       , lu.scan_unit
       , lu.util_curr_amount
       , lu.currency_code
       , fu.plan_currency_code
  FROM ozf_claim_lines_util lu
     , ozf_funds_utilized_all_b fu
  WHERE lu.claim_line_util_id = cv_line_util_id
    AND fu.utilization_id = lu.utilization_id;

CURSOR csr_total_exist_util_amt(cv_claim_line_id IN NUMBER) IS
  SELECT nvl(SUM(acctd_amount),0)
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

  CURSOR csr_claim_date(cv_claim_line_id IN NUMBER) IS
  SELECT cla.creation_date
  FROM ozf_claims cla, ozf_claim_lines cl
  WHERE cla.claim_id = cl.claim_id
  AND cl.claim_line_id  = cv_claim_line_id;

BEGIN
  -------------------- initialize -------------------------
  SAVEPOINT Update_Line_Util;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------------- validate ----------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': validate');
  END IF;

  -- replace g_miss_char/num/date with current column values
  Complete_Line_Util_Rec(
         p_line_util_rec      => p_line_util_rec
        ,x_complete_rec       => l_line_util_rec
  );

  l_line_util_rec.object_version_number := l_line_util_rec.object_version_number + 1;
  l_line_util_rec.last_updated_by := NVL(FND_GLOBAL.user_id,-1);
  l_line_util_rec.last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);

  -- get claim_id
  OPEN csr_claim_id(p_line_util_rec.claim_line_id);
  FETCH csr_claim_id INTO l_claim_id, l_line_acctd_amount;
  CLOSE csr_claim_id;

  OPEN csr_claim_date(p_line_util_rec.claim_line_id);
  FETCH csr_claim_date INTO l_claim_date;
  CLOSE csr_claim_date;


  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode THEN
    OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
           P_Api_Version_Number => 1.0
         , P_Init_Msg_List      => FND_API.G_FALSE
         , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         , P_Commit             => FND_API.G_FALSE
         , P_object_id          => l_claim_id
         , P_object_type        => G_CLAIM_OBJECT_TYPE
         , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
         , X_Return_Status      => l_return_status
         , X_Msg_Count          => x_msg_count
         , X_Msg_Data           => x_msg_data
         , X_access             => l_access);

    IF l_access = 'N' THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.set_name('OZF','OZF_CLAIM_NO_ACCESS');
          FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --IF p_line_util_rec.update_from_tbl_flag = FND_API.g_false THEN
    -- get functional_currency
    OPEN csr_function_currency;
    FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
    CLOSE csr_function_currency;
  --END IF;

  IF (p_line_util_rec.amount is not null
    AND p_line_util_rec.amount <> FND_API.g_miss_num) THEN
    OPEN  csr_lu_old_amt(p_line_util_rec.claim_line_util_id);
    FETCH csr_lu_old_amt INTO l_lu_old_amt, l_lu_old_scan_unit, l_old_utiz_amount ,l_currency_rec.claim_currency_code,l_currency_rec.transaction_currency_code;
    CLOSE csr_lu_old_amt;

    IF l_line_util_rec.amount <> l_lu_old_amt THEN
      ------------------ convert currency ----------------------
      -- mOdified for FXGL Enhancement
      -- Convert amount --> acctd_amount(functional currency)
      IF l_currency_rec.functional_currency_code = l_line_util_rec.currency_code THEN
        l_line_util_rec.acctd_amount := l_line_util_rec.amount  ;
      ELSE
        OZF_UTILITY_PVT.Convert_Currency(
             p_from_currency   => l_line_util_rec.currency_code
            ,p_to_currency     => l_currency_rec.functional_currency_code
            ,p_conv_type       => l_line_util_rec.exchange_rate_type
            ,p_conv_rate       => l_line_util_rec.exchange_rate
            ,p_conv_date       => l_line_util_rec.exchange_rate_date
            ,p_from_amount     => l_line_util_rec.amount
            ,x_return_status   => l_return_status
            ,x_to_amount       => l_line_util_rec.acctd_amount
            ,x_rate            => l_exchange_rate
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
        IF l_line_util_rec.acctd_amount IS NOT NULL THEN
          l_line_util_rec.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_line_util_rec.acctd_amount, l_currency_rec.functional_currency_code);
        END IF;

      END IF;


      --------------------- update utilization ----------------------
      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message(l_full_name ||': update funds utilized');
      END IF;

      l_update_fund_amount := l_lu_old_amt - l_line_util_rec.amount;

      IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
        l_currency_rec.association_currency_code := l_currency_rec.transaction_currency_code;
      ELSE
        l_currency_rec.association_currency_code := l_currency_rec.functional_currency_code;
        IF l_update_fund_amount IS NOT NULL and l_update_fund_amount <> 0 THEN
          OZF_UTILITY_PVT.Convert_Currency
                     ( p_from_currency   => l_currency_rec.claim_currency_code
                     , p_to_currency     => l_currency_rec.functional_currency_code
                     , p_conv_date       => l_line_util_rec.exchange_rate_date
                     , p_conv_type       => l_line_util_rec.exchange_rate_type
                     , p_from_amount     => l_update_fund_amount
                     , x_return_status   => l_return_status
                     , x_to_amount       => l_update_acctd_fund_amount
                     , x_rate            => l_rate
                     );

          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
          l_update_fund_amount := l_update_acctd_fund_amount;
        END IF;
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_line_util_rec.acctd_amount1 = '||l_line_util_rec.acctd_amount);
        OZF_Utility_PVT.debug_message('l_line_util_rec.amount1 - Before Update_Fund_Utils() : '||l_line_util_rec.amount);
        OZF_Utility_PVT.debug_message('l_update_fund_amount : '|| l_update_fund_amount);
      END IF;
      Update_Fund_Utils(
                p_line_util_rec  => l_line_util_rec
              , p_asso_amount    => NVL(l_update_fund_amount,0)
              , p_mode           => 'CALCULATE'
              , px_currency_rec  => l_currency_rec
              , x_return_status  => l_return_status
              , x_msg_count      => x_msg_count
              , x_msg_data       => x_msg_data
              );
           IF l_return_status =  fnd_api.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
           END IF;

    END IF;
  END IF;


  -------------------------- update -------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': update lines utilized');
  END IF;

  UPDATE ozf_claim_lines_util_all SET
      object_version_number  = l_line_util_rec.object_version_number,
      last_update_date       = SYSDATE,
      last_updated_by        = l_line_util_rec.last_updated_by,
      last_update_login      = l_line_util_rec.last_update_login,
      claim_line_id          = l_line_util_rec.claim_line_id,
      utilization_id         = l_line_util_rec.utilization_id,
      amount                 = l_line_util_rec.amount,
      currency_code          = l_line_util_rec.currency_code,
      exchange_rate_type     = l_line_util_rec.exchange_rate_type,
      exchange_rate_date     = l_line_util_rec.exchange_rate_date,
      exchange_rate          = l_line_util_rec.exchange_rate,
      acctd_amount           = l_line_util_rec.acctd_amount,
      util_curr_amount       = l_line_util_rec.util_curr_amount,
      plan_curr_amount       = l_line_util_rec.plan_curr_amount,
      univ_curr_amount       = l_line_util_rec.univ_curr_amount,
      uom_code               = l_line_util_rec.uom_code,
      quantity               = l_line_util_rec.quantity,
      scan_unit              = l_line_util_rec.scan_unit,
      fxgl_acctd_amount      = l_line_util_rec.fxgl_acctd_amount,
      utilized_acctd_amount  = l_line_util_rec.utilized_acctd_amount
  WHERE claim_line_util_id = p_line_util_rec.claim_line_util_id;
  --AND   object_version_number = p_line_util_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  -------------------- finish --------------------------
  x_object_version := l_line_util_rec.object_version_number;

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
    ROLLBACK TO Update_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END Update_Line_Util;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_All_Line_Utils
--
-- HISTORY
--    04-Jul-2005  Sahana  Created for Bug4348163
--    08-Aug-06    azahmed Modified for FXGL ER
---------------------------------------------------------------------
PROCEDURE Delete_All_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_currency_rec        IN  currency_rec_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Delete_All_Line_Util';
l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);

TYPE FundsUtilCsrTyp IS REF CURSOR;
l_funds_util_csr         NUMBER; --FundsUtilCsrTyp;
l_funds_util_sql         VARCHAR2(3000);
l_line_util_tbl          line_util_tbl_type;
l_lu_line_util_id        NUMBER;
l_lu_utilization_id      NUMBER;
l_lu_amt           NUMBER;
l_lu_scan_unit           NUMBER;
l_counter                PLS_INTEGER := 1;
l_object_version_number  NUMBER;
l_ignore              NUMBER;
l_utiz_amount       NUMBER;
l_lu_currency_code       VARCHAR2(15);
l_currency_rec       currency_rec_type := p_currency_rec;

CURSOR csr_util_obj_ver(cv_line_util_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_claim_lines_util_all
  WHERE claim_line_util_id = cv_line_util_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_All_Line_Util;

  IF OZF_DEBUG_HIGH_ON THEN
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


  --------------------- start -----------------------
  Get_Utiz_Sql_Stmt(
      p_api_version         => l_api_version
     ,p_init_msg_list       => FND_API.g_false
     ,p_commit              => FND_API.g_false
     ,p_validation_level    => FND_API.g_valid_level_full
     ,x_return_status       => l_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     ,p_summary_view        => 'DEL_GRP_LINE_UTIL'
     ,p_funds_util_flt      => p_funds_util_flt
     ,px_currency_rec        => l_currency_rec
     ,p_cust_account_id     => p_funds_util_flt.cust_account_id
     ,x_utiz_sql_stmt       => l_funds_util_sql
  );
  IF l_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;

    -- use FND_DSQL package for dynamic sql and bind variables
  l_funds_util_csr := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_funds_util_csr);
  DBMS_SQL.parse(l_funds_util_csr, l_funds_util_sql, DBMS_SQL.native);
  DBMS_SQL.define_column(l_funds_util_csr, 1, l_lu_line_util_id);
  DBMS_SQL.define_column(l_funds_util_csr, 2, l_lu_utilization_id);
  DBMS_SQL.define_column(l_funds_util_csr, 3, l_lu_amt);
  DBMS_SQL.define_column(l_funds_util_csr, 4, l_lu_scan_unit);
  DBMS_SQL.define_column(l_funds_util_csr, 5, l_lu_currency_code, 15);
--  DBMS_SQL.define_column(l_funds_util_csr, 5, l_utiz_amount);
  FND_DSQL.do_binds;

  l_ignore := DBMS_SQL.execute(l_funds_util_csr);
  LOOP
   IF DBMS_SQL.fetch_rows(l_funds_util_csr) > 0 THEN
    DBMS_SQL.column_value(l_funds_util_csr, 1, l_lu_line_util_id);
    DBMS_SQL.column_value(l_funds_util_csr, 2, l_lu_utilization_id);
    DBMS_SQL.column_value(l_funds_util_csr, 3, l_lu_amt);
    DBMS_SQL.column_value(l_funds_util_csr, 4, l_lu_scan_unit);
    DBMS_SQL.column_value(l_funds_util_csr, 5, l_lu_currency_code);
--    DBMS_SQL.define_column(l_funds_util_csr, 5, l_utiz_amount);

    OPEN  csr_util_obj_ver(l_lu_line_util_id);
    FETCH csr_util_obj_ver INTO l_object_version_number;
    CLOSE csr_util_obj_ver;

    Delete_Line_Util(
         p_api_version            => l_api_version
        ,p_init_msg_list          => FND_API.g_false
        ,p_commit                 => FND_API.g_false
        ,x_return_status          => l_return_status
        ,x_msg_data               => x_msg_data
        ,x_msg_count              => x_msg_count
        ,p_line_util_id           => l_lu_line_util_id
        ,p_object_version         => l_object_version_number
        ,p_mode                   => OZF_CLAIM_UTILITY_PVT.g_auto_mode
    );
    IF l_return_status =  fnd_api.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
   ELSE
    EXIT;
   END IF;
  END LOOP;
  DBMS_SQL.close_cursor(l_funds_util_csr);

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
    ROLLBACK TO Delete_All_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_All_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_All_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Delete_All_Line_Util;

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Line_Util_Tbl
--
-- HISTORY
--    05/12/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Delete_Line_Util_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_line_util_tbl          IN    line_util_tbl_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Line_Util_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
l_return_status         VARCHAR2(1);

i                       PLS_INTEGER;

l_line_util_id          NUMBER;
l_claim_id              NUMBER;
l_object_version        NUMBER;
l_access                VARCHAR2(1) := 'N';
l_final_lu_acctd_amt    NUMBER;

-- Cursor to get claim_id
CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

CURSOR csr_final_lu_acctd_amt(cv_claim_line_id IN NUMBER) IS
  SELECT SUM(acctd_amount)
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Line_Util_Tbl;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_line_util_tbl.count > 0 THEN
    FOR j IN p_line_util_tbl.FIRST..p_line_util_tbl.LAST LOOP
      IF p_line_util_tbl.EXISTS(j) THEN

        OPEN csr_claim_id(p_line_util_tbl(j).claim_line_id);
        FETCH csr_claim_id INTO l_claim_id;
        CLOSE csr_claim_id;

        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => l_claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => x_msg_count
             , X_Msg_Data           => x_msg_data
             , X_access             => l_access);

        IF l_access = 'N' THEN
          IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.set_name('OZF','OZF_CLAIM_NO_ACCESS');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  --------------------- Delete Claim Line Table -----------------------
  i := p_line_util_tbl.FIRST;
  IF i IS NOT NULL THEN

    LOOP
      l_line_util_id := p_line_util_tbl(i).claim_line_util_id;
      l_object_version := p_line_util_tbl(i).object_version_number;
      IF l_line_util_id IS NOT NULL THEN
        Delete_Line_Util(
                  p_api_version       => 1.0
                , p_init_msg_list     => FND_API.g_false
                , p_commit            => FND_API.g_false
                , x_return_status     => l_return_status
                , x_msg_count         => x_msg_count
                , x_msg_data          => x_msg_data
                , p_line_util_id      => l_line_util_id
                , p_object_version    => l_object_version
                , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
        );
        IF l_return_status =  fnd_api.g_ret_sts_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          x_error_index := i;
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;
    EXIT WHEN i = p_line_util_tbl.LAST;
    i := p_line_util_tbl.NEXT(i);
    END LOOP;

    -- update claim line earnings_associated_flag
    -- if there is no more earnings associated.
    OPEN csr_final_lu_acctd_amt(p_line_util_tbl(1).claim_line_id);
    FETCH csr_final_lu_acctd_amt INTO l_final_lu_acctd_amt;
    CLOSE csr_final_lu_acctd_amt;

    IF l_final_lu_acctd_amt = 0 OR l_final_lu_acctd_amt IS NULL THEN
      UPDATE ozf_claim_lines_all
        SET earnings_associated_flag = 'F'
        WHERE claim_line_id = p_line_util_tbl(1).claim_line_id;
    END IF;

  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Delete_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

END Delete_Line_Util_Tbl;


---------------------------------------------------------------
-- PROCEDURE
--    Delete_Line_Util
--
-- HISTORY
--    05/11/2001  mchang  Create.
--    07/22/2002  yizhang add p_mode for security check
--    08-Aug-06   azahmed Modified for FXGL ER (Amount passed to Update_Funds_Util)
---------------------------------------------------------------
PROCEDURE Delete_Line_Util(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_line_util_id      IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,p_mode              IN  VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version     CONSTANT NUMBER       := 1.0;
l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Line_Util';
l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status            VARCHAR2(1);

l_claim_line_id            NUMBER;
l_claim_id                 NUMBER;
l_utilization_id           NUMBER;
l_del_line_util_amt  NUMBER;
l_del_line_util_scan_unit  NUMBER;
l_claim_currency           VARCHAR2(15);
l_utiz_currency             VARCHAR2(15);
l_plan_curr_amount         NUMBER;

l_access                   VARCHAR2(1) := 'N';

CURSOR csr_claim_line_details(cv_line_util_id IN NUMBER) IS
  SELECT clu.claim_line_id , clu.currency_code
  FROM  ozf_claim_lines_util clu
  WHERE claim_line_util_id = cv_line_util_id;

CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

--Cursor changed for Claims-Multicurrency ER / Pranay
CURSOR csr_old_line_util_amt(cv_line_util_id IN NUMBER) IS
  SELECT lu.claim_line_id
  ,      lu.utilization_id
  ,      Decode(lu.currency_code,fu.plan_currency_code, lu.plan_curr_amount, lu.acctd_amount)
  ,      lu.scan_unit
  FROM  ozf_claim_lines_util lu
      , ozf_funds_utilized_all_b fu
  WHERE claim_line_util_id = cv_line_util_id
    AND lu.utilization_id = fu.utilization_id;


l_line_util_rec          line_util_rec_type;
l_currency_rec           currency_rec_type;

CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs
  ,    ozf_sys_parameters org
  WHERE org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Line_Util;

  IF OZF_DEBUG_HIGH_ON THEN
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

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN csr_function_currency;
  FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
  CLOSE csr_function_currency;

  OPEN csr_claim_line_details(p_line_util_id);
  FETCH csr_claim_line_details INTO l_claim_line_id , l_claim_currency;
  CLOSE csr_claim_line_details;

  OPEN csr_claim_id(l_claim_line_id);
  FETCH csr_claim_id INTO l_claim_id;
  CLOSE csr_claim_id;

  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode THEN
    OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
           P_Api_Version_Number => 1.0
         , P_Init_Msg_List      => FND_API.G_FALSE
         , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         , P_Commit             => FND_API.G_FALSE
         , P_object_id          => l_claim_id
         , P_object_type        => G_CLAIM_OBJECT_TYPE
         , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
         , X_Return_Status      => l_return_status
         , X_Msg_Count          => x_msg_count
         , X_Msg_Data           => x_msg_data
         , X_access             => l_access);

    IF l_access = 'N' THEN
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.set_name('OZF','OZF_CLAIM_NO_ACCESS');
          FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  --------------------- Start  -----------------------
  OPEN csr_old_line_util_amt(p_line_util_id);
  FETCH csr_old_line_util_amt INTO l_claim_line_id
                                 , l_utilization_id
                                 , l_del_line_util_amt
                                 , l_del_line_util_scan_unit;
  CLOSE csr_old_line_util_amt;

  ----------------- Update Utilization -----------------
  -- skip dummy utils
 IF l_utilization_id <> -1 THEN
        IF OZF_DEBUG_HIGH_ON THEN
           OZF_Utility_PVT.debug_message(l_full_name ||': update funds_utilized');
        END IF;

        l_line_util_rec.utilization_id := l_utilization_id;
        l_line_util_rec.claim_line_id := l_claim_line_id;

        IF OZF_DEBUG_LOW_ON THEN
          OZF_Utility_PVT.debug_message('l_utilization_id' || l_utilization_id);
          OZF_Utility_PVT.debug_message('l_claim_line_id' || l_claim_line_id);
          OZF_Utility_PVT.debug_message('l_del_line_util_amt' || l_del_line_util_amt);
        END IF;

        Update_Fund_Utils(
                p_line_util_rec  => l_line_util_rec
              , p_asso_amount    => NVL(l_del_line_util_amt,0)
              , p_mode           => 'NONE'
              , px_currency_rec  => l_currency_rec
              , x_return_status  => l_return_status
              , x_msg_count      => x_msg_count
              , x_msg_data       => x_msg_data
              );

             IF l_return_status =  fnd_api.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
         END IF;

 END IF;  -- IF l_utilization_rec.utilization_id <> -1

  ------------------------ delete ------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': delete');
  END IF;

  DELETE FROM ozf_claim_lines_util_all
    WHERE claim_line_util_id = p_line_util_id
    AND   object_version_number = p_object_version;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

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
    ROLLBACK TO Delete_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END Delete_Line_Util;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Line_Util_Rec
--
-- HISTORY
--    05/10/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Init_Line_Util_Rec(
   x_line_util_rec   OUT NOCOPY  line_util_rec_type
)
IS
BEGIN

   RETURN;
END Init_Line_Util_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Line_Util_Rec
--
-- HISTORY
--    05/10/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Line_Util_Rec(
   p_line_util_rec      IN  line_util_rec_type
  ,x_complete_rec       OUT NOCOPY line_util_rec_type
)
IS
CURSOR csr_line_util(cv_line_util_id  IN NUMBER) IS
SELECT object_version_number,
       claim_line_id,
       utilization_id,
       amount,
       currency_code,
       exchange_rate_type,
       exchange_rate_date,
       exchange_rate,
       acctd_amount,
       scan_unit,
       activity_product_id,
       uom_code,
       quantity,
       org_id,
       fxgl_acctd_amount,
       utilized_acctd_amount,
       util_curr_amount, --nepanda : fix for bug # 9508390  - issue # 1
       univ_curr_amount,
       plan_curr_amount
FROM  ozf_claim_lines_util
WHERE  claim_line_util_id = cv_line_util_id;

l_line_util_rec  csr_line_util%ROWTYPE;

BEGIN
  x_complete_rec := p_line_util_rec;

  OPEN csr_line_util(p_line_util_rec.claim_line_util_id);
  FETCH csr_line_util INTO l_line_util_rec;
  IF csr_line_util%NOTFOUND THEN
    CLOSE csr_line_util;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE csr_line_util;

  IF p_line_util_rec.object_version_number = FND_API.G_MISS_NUM THEN
     x_complete_rec.object_version_number := NULL;
  END IF;
  IF p_line_util_rec.object_version_number IS NULL THEN
     x_complete_rec.object_version_number := l_line_util_rec.object_version_number;
  END IF;

  IF p_line_util_rec.claim_line_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.claim_line_id := NULL;
  END IF;
  IF p_line_util_rec.claim_line_id IS NULL THEN
     x_complete_rec.claim_line_id := l_line_util_rec.claim_line_id;
  END IF;

  IF p_line_util_rec.utilization_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.utilization_id := NULL;
  END IF;
  IF p_line_util_rec.utilization_id IS NULL THEN
     x_complete_rec.utilization_id := l_line_util_rec.utilization_id;
  END IF;

  IF p_line_util_rec.amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.amount := NULL;
  END IF;
  IF p_line_util_rec.amount IS NULL THEN
     x_complete_rec.amount := l_line_util_rec.amount;
  END IF;

  IF p_line_util_rec.currency_code = FND_API.G_MISS_CHAR THEN
     x_complete_rec.currency_code := NULL;
  END IF;
  IF p_line_util_rec.currency_code IS NULL THEN
     x_complete_rec.currency_code := l_line_util_rec.currency_code;
  END IF;

  IF p_line_util_rec.exchange_rate_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.exchange_rate_type := NULL;
  END IF;
  IF p_line_util_rec.exchange_rate_type IS NULL THEN
     x_complete_rec.exchange_rate_type := l_line_util_rec.exchange_rate_type;
  END IF;

  IF p_line_util_rec.exchange_rate_date = FND_API.G_MISS_DATE THEN
     x_complete_rec.exchange_rate_date := NULL;
  END IF;
  IF p_line_util_rec.exchange_rate_date IS NULL THEN
     x_complete_rec.exchange_rate_date := l_line_util_rec.exchange_rate_date;
  END IF;

  IF p_line_util_rec.exchange_rate = FND_API.G_MISS_NUM THEN
     x_complete_rec.exchange_rate := NULL;
  END IF;
  IF p_line_util_rec.exchange_rate IS NULL THEN
     x_complete_rec.exchange_rate := l_line_util_rec.exchange_rate;
  END IF;

  IF p_line_util_rec.acctd_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.acctd_amount := NULL;
  END IF;
  IF p_line_util_rec.acctd_amount IS NULL THEN
     x_complete_rec.acctd_amount := l_line_util_rec.acctd_amount;
  END IF;
--nepanda : fix for bug # 9508390  - issue # 1
  IF p_line_util_rec.util_curr_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.util_curr_amount := NULL;
  END IF;
  IF p_line_util_rec.util_curr_amount IS NULL THEN
     x_complete_rec.util_curr_amount := l_line_util_rec.util_curr_amount;
  END IF;
  IF p_line_util_rec.univ_curr_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.univ_curr_amount := NULL;
  END IF;
  IF p_line_util_rec.univ_curr_amount IS NULL THEN
     x_complete_rec.univ_curr_amount := l_line_util_rec.univ_curr_amount;
  END IF;
  IF p_line_util_rec.plan_curr_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.plan_curr_amount := NULL;
  END IF;
  IF p_line_util_rec.plan_curr_amount IS NULL THEN
     x_complete_rec.plan_curr_amount := l_line_util_rec.plan_curr_amount;
  END IF;
  IF p_line_util_rec.scan_unit = FND_API.G_MISS_NUM THEN
     x_complete_rec.scan_unit := NULL;
  END IF;
  IF p_line_util_rec.scan_unit IS NULL THEN
     x_complete_rec.scan_unit := l_line_util_rec.scan_unit;
  END IF;

  IF p_line_util_rec.activity_product_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.activity_product_id := NULL;
  END IF;
  IF p_line_util_rec.activity_product_id IS NULL THEN
     x_complete_rec.activity_product_id := l_line_util_rec.activity_product_id;
  END IF;

  IF p_line_util_rec.uom_code = FND_API.G_MISS_CHAR THEN
     x_complete_rec.uom_code := NULL;
  END IF;
  IF p_line_util_rec.uom_code IS NULL THEN
     x_complete_rec.uom_code := l_line_util_rec.uom_code;
  END IF;

  IF p_line_util_rec.quantity = FND_API.G_MISS_NUM THEN
     x_complete_rec.quantity := NULL;
  END IF;
  IF p_line_util_rec.quantity IS NULL THEN
     x_complete_rec.quantity := l_line_util_rec.quantity;
  END IF;

  IF p_line_util_rec.org_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.org_id := NULL;
  END IF;
  IF p_line_util_rec.org_id IS NULL THEN
     x_complete_rec.org_id := l_line_util_rec.org_id;
  END IF;

  IF p_line_util_rec.fxgl_acctd_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.fxgl_acctd_amount := NULL;
  END IF;
  IF p_line_util_rec.fxgl_acctd_amount IS NULL THEN
     x_complete_rec.fxgl_acctd_amount := l_line_util_rec.fxgl_acctd_amount;
  END IF;


  IF p_line_util_rec.utilized_acctd_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.utilized_acctd_amount := NULL;
  END IF;
  IF p_line_util_rec.utilized_acctd_amount IS NULL THEN
     x_complete_rec.utilized_acctd_amount := l_line_util_rec.utilized_acctd_amount;
  END IF;

END Complete_Line_Util_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Performance
--
-- PARAMETERS
--    p_cust_account_id   : customer account id
--    p_offer_id          : offer id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Performance(
   p_cust_account_id           IN  NUMBER
  ,p_offer_id                  IN  NUMBER
  ,p_resale_flag               IN  VARCHAR2
  ,p_check_all_flag            IN  VARCHAR2

  ,x_performance_flag          OUT NOCOPY VARCHAR2
  ,x_offer_perf_tbl            OUT NOCOPY offer_performance_tbl_type
)
IS
l_offer_performance_id NUMBER;
l_product_attr_context VARCHAR2(30);
l_product_attribute   VARCHAR2(30);
l_product_attr_value  VARCHAR2(240);
l_start_date          DATE;
l_end_date            DATE;
l_requirement_type    VARCHAR2(30);
l_requirement_value   NUMBER;
l_uom_code            VARCHAR2(30);
l_common_quantity     NUMBER;
l_common_amount       NUMBER;
l_common_uom_code     VARCHAR2(3);
l_common_curr_code    VARCHAR2(15);
l_comm_curr_req_amt   NUMBER;
l_offer_currency      VARCHAR2(15);
l_return_status       VARCHAR2(1);
l_temp_sql            VARCHAR2(2000);
l_emp_csr             NUMBER;
l_ignore              NUMBER;
l_counter             PLS_INTEGER := 0;
l_performance_flag    VARCHAR2(1);
l_offer_perf_tbl      offer_performance_tbl_type;

CURSOR csr_offer_perfs(cv_offer_id IN NUMBER) IS
  SELECT offer_performance_id
       , product_attribute_context
       , product_attribute
       , product_attr_value
       , start_date
       , end_date
       , requirement_type
       , estimated_value
       , uom_code
  FROM ozf_offer_performances
  WHERE required_flag = 'Y'
  AND product_attribute_context = 'ITEM'
  AND requirement_type IN ('AMOUNT', 'VOLUME')
  AND list_header_id = cv_offer_id;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs
  ,    ozf_sys_parameters org
  WHERE org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
   x_performance_flag := FND_API.g_true;

   OPEN csr_offer_perfs(p_offer_id);
   LOOP
      FETCH csr_offer_perfs INTO l_offer_performance_id
                               , l_product_attr_context
                               , l_product_attribute
                               , l_product_attr_value
                               , l_start_date
                               , l_end_date
                               , l_requirement_type
                               , l_requirement_value
                               , l_uom_code;
      EXIT WHEN csr_offer_perfs%NOTFOUND;

      l_performance_flag := 'T';

      IF p_resale_flag IS NULL OR p_resale_flag = 'F' THEN
         FND_DSQL.init;
         FND_DSQL.add_text('SELECT NVL(sum(common_quantity), 0), NVL(sum(common_amount), 0), ');
         FND_DSQL.add_text(' common_uom_code, common_currency_code ');
         FND_DSQL.add_text(' FROM ozf_sales_transactions ');
         FND_DSQL.add_text(' WHERE sold_to_cust_account_id = ');
         FND_DSQL.add_bind(p_cust_account_id);
         FND_DSQL.add_text(' AND transaction_date between ');
         FND_DSQL.add_bind(l_start_date);
         FND_DSQL.add_text(' and ');
         FND_DSQL.add_bind(l_end_date);
         FND_DSQL.add_text(' AND inventory_item_id IN (SELECT s.product_id FROM ( ');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql(
            p_context         => l_product_attr_context,
            p_attribute       => l_product_attribute,
            p_attr_value_from => l_product_attr_value,
            p_attr_value_to   => NULL,
            p_comparison      => NULL,
            p_type            => 'PROD'
         );
         FND_DSQL.add_text(') s) ');
         FND_DSQL.add_text(' GROUP BY common_uom_code, common_currency_code ');

         IF OZF_DEBUG_HIGH_ON THEN
            l_temp_sql := FND_DSQL.get_text(TRUE);
            OZF_Utility_PVT.debug_message('----- Check_Offer_Performance SQL -----');
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 1, 254));
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 255, 254));
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 509, 254));
            OZF_Utility_PVT.debug_message('---------------------------------------');
         END IF;

         l_emp_csr := DBMS_SQL.open_cursor;
         FND_DSQL.set_cursor(l_emp_csr);
         DBMS_SQL.parse(l_emp_csr, FND_DSQL.get_text(FALSE), DBMS_SQL.native);
         DBMS_SQL.define_column(l_emp_csr, 1, l_common_quantity);
         DBMS_SQL.define_column(l_emp_csr, 2, l_common_amount);
         DBMS_SQL.define_column(l_emp_csr, 3, l_common_uom_code, 3);
         DBMS_SQL.define_column(l_emp_csr, 4, l_common_curr_code, 15);
         FND_DSQL.do_binds;

         l_ignore := DBMS_SQL.execute(l_emp_csr);
         IF DBMS_SQL.fetch_rows(l_emp_csr) > 0 THEN
            DBMS_SQL.column_value(l_emp_csr, 1, l_common_quantity);
            DBMS_SQL.column_value(l_emp_csr, 2, l_common_amount);
            DBMS_SQL.column_value(l_emp_csr, 3, l_common_uom_code);
            DBMS_SQL.column_value(l_emp_csr, 4, l_common_curr_code);

            IF l_requirement_type = 'VOLUME' THEN
               IF l_uom_code = l_common_uom_code THEN
                  IF l_common_quantity < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               ELSE
                  l_requirement_value := inv_convert.inv_um_convert(
                        item_id         => NULL
                       ,precision       => 2
                       ,from_quantity   => l_requirement_value
                       ,from_unit       => l_uom_code
                       ,to_unit         => l_common_uom_code
                       ,from_name       => NULL
                       ,to_name         => NULL
                  );
                  IF l_requirement_value = -99999 THEN
                      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
                         FND_MSG_PUB.add;
                      END IF;
                      RAISE FND_API.g_exc_error;
                  END IF;

                  IF l_common_quantity < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               END IF;
            ELSIF l_requirement_type = 'AMOUNT' THEN
               l_offer_currency := OZF_ACTBUDGETS_PVT.Get_Object_Currency(
                     p_object          => 'OFFR'
                    ,p_object_id       => p_offer_id
                    ,x_return_status   => l_return_status
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               IF l_offer_currency = l_common_curr_code THEN
                  IF l_common_amount < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               ELSE
                  OZF_UTILITY_PVT.Convert_Currency(
                      p_from_currency   => l_offer_currency
                     ,p_to_currency     => l_common_curr_code
                     ,p_conv_date       => SYSDATE
                     ,p_from_amount     => l_requirement_value
                     ,x_return_status   => l_return_status
                     ,x_to_amount       => l_comm_curr_req_amt
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  IF l_common_amount < l_comm_curr_req_amt THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               END IF;
            END IF;
         ELSE
            -- no rows returned
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message('No sales transactions found');
            END IF;
            l_performance_flag := FND_API.g_false;
         END IF;
         DBMS_SQL.close_cursor(l_emp_csr);

      ELSE
         /********** Check resale data ***********/
         FND_DSQL.init;
         FND_DSQL.add_text('SELECT NVL(sum(quantity), 0), NVL(sum(quantity*acctd_selling_price), 0), ');
         FND_DSQL.add_text(' uom_code ');
         FND_DSQL.add_text(' FROM ozf_resale_lines ');
         FND_DSQL.add_text(' WHERE sold_from_cust_account_id = ');
         FND_DSQL.add_bind(p_cust_account_id);
         FND_DSQL.add_text(' AND date_ordered between ');
         FND_DSQL.add_bind(l_start_date);
         FND_DSQL.add_text(' and ');
         FND_DSQL.add_bind(l_end_date);
         FND_DSQL.add_text(' AND inventory_item_id IN (SELECT s.product_id FROM ( ');
         l_temp_sql := OZF_OFFR_ELIG_PROD_DENORM_PVT.get_sql(
            p_context         => l_product_attr_context,
            p_attribute       => l_product_attribute,
            p_attr_value_from => l_product_attr_value,
            p_attr_value_to   => NULL,
            p_comparison      => NULL,
            p_type            => 'PROD'
         );
         FND_DSQL.add_text(') s) ');
         FND_DSQL.add_text(' GROUP BY uom_code ');

         IF OZF_DEBUG_HIGH_ON THEN
            l_temp_sql := FND_DSQL.get_text(TRUE);
            OZF_Utility_PVT.debug_message('----- Check_Offer_Performance SQL -----');
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 1, 254));
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 255, 254));
            OZF_Utility_PVT.debug_message(SUBSTR(l_temp_sql, 509, 254));
            OZF_Utility_PVT.debug_message('---------------------------------------');
         END IF;

         l_emp_csr := DBMS_SQL.open_cursor;
         FND_DSQL.set_cursor(l_emp_csr);
         DBMS_SQL.parse(l_emp_csr, FND_DSQL.get_text(FALSE), DBMS_SQL.native);
         DBMS_SQL.define_column(l_emp_csr, 1, l_common_quantity);
         DBMS_SQL.define_column(l_emp_csr, 2, l_common_amount);
         DBMS_SQL.define_column(l_emp_csr, 3, l_common_uom_code, 3);
         FND_DSQL.do_binds;

         l_ignore := DBMS_SQL.execute(l_emp_csr);
         IF DBMS_SQL.fetch_rows(l_emp_csr) > 0 THEN
            DBMS_SQL.column_value(l_emp_csr, 1, l_common_quantity);
            DBMS_SQL.column_value(l_emp_csr, 2, l_common_amount);
            DBMS_SQL.column_value(l_emp_csr, 3, l_common_uom_code);

            IF l_requirement_type = 'VOLUME' THEN
               IF l_uom_code = l_common_uom_code THEN
                  IF l_common_quantity < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               ELSE
                  l_requirement_value := inv_convert.inv_um_convert(
                        item_id         => NULL
                       ,precision       => 2
                       ,from_quantity   => l_requirement_value
                       ,from_unit       => l_uom_code
                       ,to_unit         => l_common_uom_code
                       ,from_name       => NULL
                       ,to_name         => NULL
                  );
                  IF l_requirement_value = -99999 THEN
                      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
                         FND_MSG_PUB.add;
                      END IF;
                      RAISE FND_API.g_exc_error;
                  END IF;

                  IF l_common_quantity < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               END IF;
            ELSIF l_requirement_type = 'AMOUNT' THEN
               l_offer_currency := OZF_ACTBUDGETS_PVT.Get_Object_Currency(
                     p_object          => 'OFFR'
                    ,p_object_id       => p_offer_id
                    ,x_return_status   => l_return_status
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;

               OPEN csr_function_currency;
               FETCH csr_function_currency INTO l_common_curr_code;
               CLOSE csr_function_currency;

               IF l_offer_currency = l_common_curr_code THEN
                  IF l_common_amount < l_requirement_value THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               ELSE
                  OZF_UTILITY_PVT.Convert_Currency(
                      p_from_currency   => l_offer_currency
                     ,p_to_currency     => l_common_curr_code
                     ,p_conv_date       => SYSDATE
                     ,p_from_amount     => l_requirement_value
                     ,x_return_status   => l_return_status
                     ,x_to_amount       => l_comm_curr_req_amt
                  );
                  IF l_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  IF l_common_amount < l_comm_curr_req_amt THEN
                     l_performance_flag := FND_API.g_false;
                  END IF;
               END IF;
            END IF;
         ELSE
            -- no rows returned
            IF OZF_DEBUG_HIGH_ON THEN
               OZF_Utility_PVT.debug_message('No sales transactions found');
            END IF;
            l_performance_flag := FND_API.g_false;
         END IF;
         DBMS_SQL.close_cursor(l_emp_csr);

      END IF;

      IF l_performance_flag = 'F' THEN
         x_performance_flag := FND_API.g_false;

         l_counter := l_counter + 1;
         l_offer_perf_tbl(l_counter).offer_id := p_offer_id;
         l_offer_perf_tbl(l_counter).offer_performance_id := l_offer_performance_id;
         l_offer_perf_tbl(l_counter).product_attribute := l_product_attribute;
         l_offer_perf_tbl(l_counter).product_attr_value := l_product_attr_value;
         l_offer_perf_tbl(l_counter).start_date := l_start_date;
         l_offer_perf_tbl(l_counter).end_date := l_end_date;
         l_offer_perf_tbl(l_counter).requirement_type := l_requirement_type;
         l_offer_perf_tbl(l_counter).estimated_value := l_requirement_value;
         l_offer_perf_tbl(l_counter).uom_code := l_uom_code;

         IF p_check_all_flag = 'F' THEN
            EXIT;
         END IF;
      END IF;

   END LOOP;
   CLOSE csr_offer_perfs;
   x_offer_perf_tbl := l_offer_perf_tbl;

END Check_Offer_Performance;

---------------------------------------------------------------------
-- PROCEDURE
--    Settle_Claim
--
-- PURPOSE
--    Close a claim
--
-- PARAMETERS
--    p_claim_id: claim id
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Settle_Claim(
   p_claim_id            IN  NUMBER
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Settle_Claim';
l_return_status VARCHAR2(1);

l_claim_id           NUMBER         := p_claim_id;
l_claim_rec          OZF_CLAIM_PVT.claim_rec_type;
l_object_version_number NUMBER;
l_sales_rep_id       NUMBER;
l_salesrep_req_flag  VARCHAR2(1);

CURSOR csr_claim_info(cv_claim_id in number) IS
  select object_version_number, sales_rep_id
  from ozf_claims_all
  where claim_id = cv_claim_id;

CURSOR csr_ar_system_options IS
  SELECT salesrep_required_flag
  FROM ar_system_parameters;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Settle_Claim;

  x_return_status := FND_API.g_ret_sts_success;

  ----------------- start ----------------
  OPEN csr_claim_info(l_claim_id);
  FETCH csr_claim_info into l_object_version_number, l_sales_rep_id;
  CLOSE csr_claim_info;

  l_claim_rec.claim_id              := l_claim_id;
  l_claim_rec.object_version_number := l_object_version_number;
  l_claim_rec.USER_STATUS_ID        := to_number( ozf_utility_pvt.GET_DEFAULT_USER_STATUS(
                                                    P_STATUS_TYPE=> 'OZF_CLAIM_STATUS',
                                                    P_STATUS_CODE=> 'CLOSED'
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
      l_claim_rec.sales_rep_id := -3;  -- No Sales Credit
    END IF;
  END IF;

  OZF_claim_PVT.Update_claim(
     P_Api_Version                => l_api_version,
     P_Init_Msg_List              => FND_API.g_false,
     P_Commit                     => FND_API.g_false,
     P_Validation_Level           => FND_API.g_valid_level_full,
     X_Return_Status              => l_return_status,
     X_Msg_Count                  => x_msg_count,
     X_Msg_Data                   => x_msg_data,
     P_claim                      => l_claim_Rec,
     p_event                      => 'UPDATE',
     p_mode                       => OZF_claim_Utility_pvt.G_AUTO_MODE,
     X_Object_Version_Number      => l_object_version_number
  );
  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Settle_Claim;
    x_return_status := FND_API.g_ret_sts_error;
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Settle_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
  WHEN OTHERS THEN
    ROLLBACK TO Settle_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
END Settle_Claim;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_For_Accruals
--
-- PURPOSE
--    Create a claim and associate earnings based on search filters.
--
-- PARAMETERS
--    p_claim_rec: claim record
--    p_funds_util_flt: search filter for earnings
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Create_Claim_For_Accruals(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_rec           IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt      IN  ozf_claim_accrual_pvt.funds_util_flt_type

  ,x_claim_id            OUT NOCOPY NUMBER
) IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Create_Claim_For_Accruals';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_funds_util_flt      ozf_claim_accrual_pvt.funds_util_flt_type;
l_line_tbl            OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_claim_rec           OZF_CLAIM_PVT.claim_rec_type := p_claim_rec;
l_claim_id            NUMBER;
l_cust_account_id     NUMBER;
l_plan_type           VARCHAR2(30);
l_plan_id             NUMBER;
l_product_level_type  VARCHAR2(30);
l_product_id          NUMBER;
l_amount              NUMBER;
l_total_acctd_amount_rem NUMBER;
l_performance_flag    VARCHAR2(1) := FND_API.g_true;

l_emp_csr             NUMBER;
l_stmt                VARCHAR2(3000);
l_ignore              NUMBER;
l_counter             PLS_INTEGER := 1;
l_error_index         NUMBER;
l_ignore_text         VARCHAR2(240);
l_dummy               NUMBER;
l_offer_perf_tbl      offer_performance_tbl_type;
l_currency_code       VARCHAR2(15);
l_amount_ut_curr      NUMBER; -- amount in utilization currency (source budget currency)
l_bill_to_site_id     NUMBER;

l_currency_rec       currency_rec_type;
l_currOrgId            NUMBER     := MO_GLOBAL.GET_CURRENT_ORG_ID();

--Change the amount for multi currency - kpatro - 5/22/2009
CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
      -- , acctd_amount
     , claim_currency_amount
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_uom_code(cv_item_id IN NUMBER) IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE inventory_item_id = cv_item_id
  AND organization_id = FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

CURSOR csr_offer_perf(cv_list_header_id IN NUMBER) IS
  SELECT 1
  FROM ozf_offer_performances
  WHERE list_header_id = cv_list_header_id;

--Added for bug 7030415
CURSOR c_get_conversion_type IS
  SELECT exchange_rate_type
  FROM   ozf_sys_parameters_all
  WHERE  org_id = l_currOrgId;

CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs
  ,    ozf_sys_parameters org
  WHERE org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = l_currOrgId;
l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;
l_rate                    NUMBER;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_For_Accruals;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
     OZF_Utility_PVT.debug_message('l_claim_rec.claim_number :  ' || l_claim_rec.claim_number);
  END IF;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(
              l_api_version,
              p_api_version,
              l_api_name,
              g_pkg_name
         )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  -------------------- start -------------------
  l_funds_util_flt := p_funds_util_flt;
  l_total_acctd_amount_rem := 0;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('Claim Currency Code in Create Claim For Accruals :' || l_claim_rec.currency_code);
  END IF;

  -- Added For Multi Currency - kpatro
  IF(l_claim_rec.currency_code IS NOT NULL) THEN
        l_currency_rec.claim_currency_code := l_claim_rec.currency_code;
  END IF;

  l_currency_rec.transaction_currency_code := l_funds_util_flt.utiz_currency_code;

  OPEN csr_function_currency;
  FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
  CLOSE csr_function_currency;


   IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
      l_currency_rec.association_currency_code := l_currency_rec.transaction_currency_code;
   ELSE
     l_currency_rec.association_currency_code := l_currency_rec.functional_currency_code;
   END IF;

   --Set UNIVERSAL currency from profile.
  l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('l_currency_rec.universal_currency_code :' || l_currency_rec.universal_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code :' || l_currency_rec.claim_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code :' || l_currency_rec.functional_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code :' || l_currency_rec.transaction_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.association_currency_code :' || l_currency_rec.association_currency_code);
  END IF;

  Get_Utiz_Sql_Stmt(
     p_api_version         => 1.0
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data
    ,p_summary_view        => 'AUTOPAY_LINE'
    ,p_funds_util_flt      => l_funds_util_flt
    ,px_currency_rec       => l_currency_rec
    ,p_cust_account_id     => l_funds_util_flt.cust_account_id
    ,x_utiz_sql_stmt       => l_stmt
  );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_error;
  END IF;

  l_emp_csr := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_emp_csr);
  DBMS_SQL.parse(l_emp_csr, l_stmt, DBMS_SQL.native);
  DBMS_SQL.define_column(l_emp_csr, 1, l_cust_account_id);
  DBMS_SQL.define_column(l_emp_csr, 2, l_plan_type, 30);
  DBMS_SQL.define_column(l_emp_csr, 3, l_plan_id);
  DBMS_SQL.define_column(l_emp_csr, 4, l_bill_to_site_id); --R12.1 enhancements
  DBMS_SQL.define_column(l_emp_csr, 5, l_product_level_type, 30);
  DBMS_SQL.define_column(l_emp_csr, 6, l_product_id);
  DBMS_SQL.define_column(l_emp_csr, 7, l_amount);
  DBMS_SQL.define_column(l_emp_csr, 8, l_currency_code, 15);
  FND_DSQL.do_binds;

  l_ignore := DBMS_SQL.execute(l_emp_csr);
  LOOP
    IF DBMS_SQL.fetch_rows(l_emp_csr) > 0 THEN
      DBMS_SQL.column_value(l_emp_csr, 1, l_cust_account_id);
      DBMS_SQL.column_value(l_emp_csr, 2, l_plan_type);
      DBMS_SQL.column_value(l_emp_csr, 3, l_plan_id);
      DBMS_SQL.column_value(l_emp_csr, 4, l_bill_to_site_id); --R12.1 enhancements
      DBMS_SQL.column_value(l_emp_csr, 5, l_product_level_type);
      DBMS_SQL.column_value(l_emp_csr, 6, l_product_id);
      DBMS_SQL.column_value(l_emp_csr, 7, l_amount);
      DBMS_SQL.column_value(l_emp_csr, 8, l_currency_code);

      IF l_currency_code <> l_claim_rec.currency_code THEN
        l_amount_ut_curr := l_amount;

        --Added for bug 7030415, get exchange_rate type
        OPEN c_get_conversion_type;
        FETCH c_get_conversion_type INTO l_exchange_rate_type;
        CLOSE c_get_conversion_type;
        --end

        OZF_UTILITY_PVT.Convert_Currency(
             p_from_currency   => l_currency_code
            ,p_to_currency     => l_claim_rec.currency_code
            ,p_conv_type       => l_exchange_rate_type
            ,p_conv_date       => SYSDATE
            ,p_from_amount     => l_amount_ut_curr -- amount in utilization currency (func currency)
            ,x_return_status   => l_return_status
            ,x_to_amount       => l_amount -- amount in claim currency
            ,x_rate            => l_rate
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;

      IF l_amount IS NOT NULL AND l_amount <> 0 THEN
        IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('---------------------------------');
          OZF_Utility_PVT.debug_message('Line ' || l_counter || ': Amount='||l_amount);
          OZF_Utility_PVT.debug_message('Plan Type         :  ' || l_plan_type);
          OZF_Utility_PVT.debug_message('Plan Id           :  ' || l_plan_id);
          OZF_Utility_PVT.debug_message('Product Level Type:  ' || l_product_level_type);
          OZF_Utility_PVT.debug_message('Product Id        :  ' || l_product_id);
          -- Added For Bug 8402328
          OZF_Utility_PVT.debug_message('l_funds_util_flt.utilization_id        :  ' || l_funds_util_flt.utilization_id);
        END IF;
        IF p_claim_rec.created_from = 'AUTOPAY' THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------------------------');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Line ' || l_counter || ': Amount='||l_amount);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Plan Type         :  ' || l_plan_type);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Plan Id           :  ' || l_plan_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Product Level Type:  ' || l_product_level_type);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Product Id        :  ' || l_product_id);
        END IF;

        IF l_plan_type = 'OFFR' THEN
          Check_Offer_Performance(
             p_cust_account_id      => l_cust_account_id
            ,p_offer_id             => l_plan_id
            ,p_resale_flag          => 'F'
            ,p_check_all_flag       => 'F'
            ,x_performance_flag     => l_performance_flag
            ,x_offer_perf_tbl       => l_offer_perf_tbl
          );
        END IF;

         --Added Debug For Multi Currency - kpatro
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('l_bill_to_site_id         :  ' || l_bill_to_site_id);
            OZF_Utility_PVT.debug_message('l_funds_util_flt.bill_to_site_use_id           :  ' || l_funds_util_flt.bill_to_site_use_id);
            OZF_Utility_PVT.debug_message('l_funds_util_flt.utiz_currency_code           :  ' || l_funds_util_flt.utiz_currency_code);
            OZF_Utility_PVT.debug_message('l_currency_code           :  ' || l_currency_code);
         END IF;
        --R12.1 enhancements. Added condition so that earnings accrued only against
        --the respective bill_to_site_id should be added.

         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('l_bill_to_site_id         :  ' || l_bill_to_site_id);
            OZF_Utility_PVT.debug_message('l_funds_util_flt.bill_to_site_use_id           :  ' || l_funds_util_flt.bill_to_site_use_id);
            OZF_Utility_PVT.debug_message('l_funds_util_flt.utiz_currency_code           :  ' || l_funds_util_flt.utiz_currency_code);
         END IF;
        -- The Claim Created From Autopay should be grouped based on Currency Code Also - kpatro
        IF l_performance_flag = FND_API.g_true THEN
           IF l_bill_to_site_id IS NOT NULL
           AND l_bill_to_site_id = l_funds_util_flt.bill_to_site_use_id
           AND l_currency_code = l_funds_util_flt.utiz_currency_code -- Added the check for Multi Currency - kpatro
           THEN --nirma

                  -- assume single currency for now; add multi-curr later
                  l_line_tbl(l_counter).claim_currency_amount     := l_amount;
                  l_line_tbl(l_counter).activity_type             := l_plan_type;
                  l_line_tbl(l_counter).activity_id               := l_plan_id;
                  l_line_tbl(l_counter).item_type                 := l_product_level_type;
                  l_line_tbl(l_counter).item_id                   := l_product_id;
                  l_line_tbl(l_counter).relationship_type         := l_funds_util_flt.relationship_type;
                  l_line_tbl(l_counter).related_cust_account_id   := l_funds_util_flt.related_cust_account_id;
                  l_line_tbl(l_counter).buy_group_party_id        := l_funds_util_flt.buy_group_party_id;
                  l_line_tbl(l_counter).select_cust_children_flag := l_funds_util_flt.select_cust_children_flag;
                  -- Added For Bug 8402328
                  l_line_tbl(l_counter).utilization_id := l_funds_util_flt.utilization_id;

                  IF l_product_level_type = 'PRODUCT' AND l_product_id IS NOT NULL THEN
                    OPEN csr_uom_code(l_line_tbl(l_counter).item_id);
                    FETCH csr_uom_code INTO l_line_tbl(l_counter).quantity_uom;
                    IF csr_uom_code%NOTFOUND THEN
                      CLOSE csr_uom_code;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('OZF', 'OZF_PRODUCT_UOM_MISSING');
                        FND_MESSAGE.Set_Token('ITEM_ID', l_line_tbl(l_counter).item_id);
                        FND_MSG_PUB.ADD;
                      END IF;
                      RAISE FND_API.g_exc_unexpected_error;
                    END IF;
                    CLOSE csr_uom_code;
                  END IF;

                  l_total_acctd_amount_rem := l_total_acctd_amount_rem + l_amount;

                  IF l_plan_type = 'OFFR' AND l_plan_id IS NOT NULL THEN
                    OPEN csr_offer_perf(l_plan_id);
                    FETCH csr_offer_perf INTO l_dummy;
                    CLOSE csr_offer_perf;

                    IF l_dummy = 1 THEN
                      l_line_tbl(l_counter).performance_attached_flag := FND_API.G_TRUE;
                      l_line_tbl(l_counter).performance_complete_flag := FND_API.G_TRUE;
                    END IF;
                  END IF;

                  l_counter := l_counter + 1;

            -- Fix for Bug 8501176
            ELSIF l_funds_util_flt.bill_to_site_use_id IS NULL THEN

                  l_line_tbl(l_counter).claim_currency_amount     := l_amount;
                  l_line_tbl(l_counter).activity_type             := l_plan_type;
                  l_line_tbl(l_counter).activity_id               := l_plan_id;
                  l_line_tbl(l_counter).item_type                 := l_product_level_type;
                  l_line_tbl(l_counter).item_id                   := l_product_id;
                  l_line_tbl(l_counter).relationship_type         := l_funds_util_flt.relationship_type;
                  l_line_tbl(l_counter).related_cust_account_id   := l_funds_util_flt.related_cust_account_id;
                  l_line_tbl(l_counter).buy_group_party_id        := l_funds_util_flt.buy_group_party_id;
                  l_line_tbl(l_counter).select_cust_children_flag := l_funds_util_flt.select_cust_children_flag;
                  -- Added For Bug 8402328
                  l_line_tbl(l_counter).utilization_id := l_funds_util_flt.utilization_id;

                  IF l_product_level_type = 'PRODUCT' AND l_product_id IS NOT NULL THEN
                    OPEN csr_uom_code(l_line_tbl(l_counter).item_id);
                    FETCH csr_uom_code INTO l_line_tbl(l_counter).quantity_uom;
                    IF csr_uom_code%NOTFOUND THEN
                      CLOSE csr_uom_code;
                      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                        FND_MESSAGE.Set_Name('OZF', 'OZF_PRODUCT_UOM_MISSING');
                        FND_MESSAGE.Set_Token('ITEM_ID', l_line_tbl(l_counter).item_id);
                        FND_MSG_PUB.ADD;
                      END IF;
                      RAISE FND_API.g_exc_unexpected_error;
                    END IF;
                    CLOSE csr_uom_code;
                  END IF;

                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'NP l_total_acctd_amount_rem        :  ' || l_total_acctd_amount_rem);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'NP l_amount        :  ' || l_amount);


                  l_total_acctd_amount_rem := l_total_acctd_amount_rem + l_amount;

                  IF l_plan_type = 'OFFR' AND l_plan_id IS NOT NULL THEN
                    OPEN csr_offer_perf(l_plan_id);
                    FETCH csr_offer_perf INTO l_dummy;
                    CLOSE csr_offer_perf;

                    IF l_dummy = 1 THEN
                      l_line_tbl(l_counter).performance_attached_flag := FND_API.G_TRUE;
                      l_line_tbl(l_counter).performance_complete_flag := FND_API.G_TRUE;
                    END IF;
                  END IF;

                  l_counter := l_counter + 1;

          END IF;--nirma
        ELSE
          IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Performance requirements not met.');
          END IF;
          IF p_claim_rec.created_from = 'AUTOPAY' THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Performance requirements not met.');
          END IF;
        END IF;
      END IF;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(l_emp_csr);

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('l_total_acctd_amount_rem:  ' || l_total_acctd_amount_rem);
  END IF;

   -- Fix for Bug 8501176
  IF l_total_acctd_amount_rem <> 0 THEN
    l_claim_rec.amount := l_total_acctd_amount_rem;

    -- create claim in OPEN status, ignoring the status passed in
    l_claim_rec.status_code    := 'OPEN';
    l_claim_rec.user_status_id := to_number(ozf_utility_pvt.get_default_user_status(
              p_status_type   => 'OZF_CLAIM_STATUS',
              p_status_code   => l_claim_rec.status_code));

    OZF_CLAIM_PVT.Create_Claim(
       p_api_version            => l_api_version
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count
      ,p_claim                  => l_claim_rec
      ,x_claim_id               => l_claim_id
    );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('Claim created id: ' || l_claim_id);
    END IF;

    FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST LOOP
      IF l_line_tbl.exists(i) IS NOT NULL THEN
        l_line_tbl(i).claim_id := l_claim_id;
      END IF;
    END LOOP;

    OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
       p_api_version       => 1.0
      ,p_init_msg_list     => FND_API.g_false
      ,p_commit            => FND_API.g_false
      ,p_validation_level  => FND_API.g_valid_level_full
      ,x_return_status     => l_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_claim_line_tbl    => l_line_tbl
      ,x_error_index       => l_error_index
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_error;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('Claim lines created for claim_id=' || l_claim_id);
    END IF;

    OPEN csr_claim_line(l_claim_id);
    LOOP
      FETCH csr_claim_line INTO l_funds_util_flt.claim_line_id
                              , l_funds_util_flt.activity_type
                              , l_funds_util_flt.activity_id
                              , l_funds_util_flt.product_level_type
                              , l_funds_util_flt.product_id
                              , l_funds_util_flt.total_amount;
      EXIT WHEN csr_claim_line%NOTFOUND;

      Update_Group_Line_Util(
         p_api_version         => 1.0
        ,p_init_msg_list       => FND_API.g_false
        ,p_commit              => FND_API.g_false
        ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status       => l_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        ,p_summary_view        => 'ACTIVITY'
        ,p_funds_util_flt      => l_funds_util_flt
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
      END IF;
    END LOOP;
    CLOSE csr_claim_line;
  ELSIF l_claim_rec.created_from = 'PROMO_CLAIM' and l_claim_rec.amount <> 0 THEN
    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('Created Form: ' || l_claim_rec.created_from);
      OZF_Utility_PVT.debug_message('Amount: ' || l_claim_rec.amount);
   END IF;

   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_ACCRUAL_SCAN_DATA_ERROR');
      FND_MSG_PUB.ADD;
    END IF;

    RAISE FND_API.g_exc_unexpected_error;
  ELSE
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_ACCRUAL_REM_AMOUNT_LT_ZERO');
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_claim_id := l_claim_id;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Create_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_For_Accruals;

-------------------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Existing_Accruals
--
-- PURPOSE
--    This procedure creates a claim, associates the existing earnings with
--    claim lines.
--
-- PARAMETERS
--    p_claim_rec: claim record
--
-- NOTES
--
-- HISTORY
--    09-Jul-2009  anuj & muthsubr   Created.
--    Bug# 8632964 fixed.
-------------------------------------------------------------------------------
PROCEDURE Create_Claim_Existing_Accruals(
   p_api_version      IN  NUMBER
  ,p_init_msg_list    IN  VARCHAR2 := FND_API.g_false
  ,p_commit           IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level IN  NUMBER   := FND_API.g_valid_level_full
  ,x_return_status    OUT NOCOPY VARCHAR2
  ,x_msg_count        OUT NOCOPY NUMBER
  ,x_msg_data         OUT NOCOPY VARCHAR2
  ,p_claim_rec        IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt   IN  ozf_claim_accrual_pvt.funds_util_flt_type
  ,x_claim_id         OUT NOCOPY NUMBER
)
IS
l_api_version CONSTANT   NUMBER       := 1.0;
l_api_name    CONSTANT   VARCHAR2(30) := 'Create_Claim_Existing_Accruals';
l_full_name   CONSTANT   VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);
l_funds_util_flt         OZF_CLAIM_ACCRUAL_PVT.funds_util_flt_type;
l_line_tbl               OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_claim_rec              OZF_CLAIM_PVT.claim_rec_type := p_claim_rec;
l_claim_id               NUMBER;
l_cust_account_id        NUMBER;
l_plan_type              VARCHAR2(30);
l_plan_id                NUMBER;
l_product_level_type     VARCHAR2(30);
l_product_id             NUMBER;
l_amount                 NUMBER;
l_total_acctd_amount_rem NUMBER;
l_performance_flag       VARCHAR2(1) := FND_API.g_true;
l_emp_csr                NUMBER;
l_counter                PLS_INTEGER := 1;
l_error_index            NUMBER;
l_dummy                  NUMBER;
l_offer_perf_tbl         offer_performance_tbl_type;
l_currency_code          VARCHAR2(15);

l_batch_settlement_flag  VARCHAR2(1) := 'F';
l_batch_product_id       NUMBER;
l_batch_product_amount   NUMBER;
l_batch_fund_id          NUMBER;
l_batch_currency_code    VARCHAR2(15);
l_accrual_amount         NUMBER;
l_amount_utilized        NUMBER := 0;
l_total_amount_utilized  NUMBER := 0;
l_resale_line_int_id     NUMBER;
error_no_rollback        EXCEPTION;


CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
       , acctd_amount
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_uom_code(cv_item_id IN NUMBER) IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE inventory_item_id = cv_item_id
  AND organization_id = FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

CURSOR csr_offer_perf(cv_list_header_id IN NUMBER) IS
  SELECT 1
  FROM ozf_offer_performances
  WHERE list_header_id = cv_list_header_id;

l_pass_acctd_amount     VARCHAR2(1) := 'F';

CURSOR csr_batch_lines(p_resale_batch_id IN NUMBER)
IS
SELECT
  SUM(orl.total_accepted_amount) total_amount,
  orl.inventory_item_id product_id,
  orb.currency_code currency_code
FROM
  ozf_resale_batches_all orb,
  ozf_resale_lines_int_all orl
WHERE
  orb.batch_type = 'CHARGEBACK'
  AND orb.resale_batch_id = orl.resale_batch_id
  AND orb.resale_batch_id = p_resale_batch_id
  AND NVL(orl.tracing_flag, 'F') <> 'T'
  AND orl.status_code = 'PROCESSED'
GROUP BY orl.inventory_item_id, orb.currency_code;

CURSOR csr_resale_line(p_resale_batch_id IN NUMBER)
IS
SELECT
  orl.resale_line_int_id
FROM
  ozf_resale_batches_all orb,
  ozf_resale_lines_int_all orl
WHERE
  orb.batch_type = 'CHARGEBACK'
  AND orb.resale_batch_id = orl.resale_batch_id
  AND orb.resale_batch_id = p_resale_batch_id
  AND NVL(orl.tracing_flag, 'F') <> 'T'
  AND orl.status_code = 'PROCESSED';

CURSOR csr_get_utils(p_cust_account_id IN NUMBER, p_fund_id IN VARCHAR2, p_product_id IN NUMBER)
IS
SELECT fu.cust_account_id cust_account_id, fu.plan_type plan_type, fu.plan_id plan_id,
fu.product_id product_id, sum(fu.acctd_amount_remaining) amount, fu.currency_code currency_code
FROM ozf_funds_utilized_all_b fu
WHERE fu.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID()
AND fu.acctd_amount_remaining <> 0
AND fu.utilization_type IN ('ACCRUAL', 'ADJUSTMENT')
AND fu.cust_account_id = p_cust_account_id
AND fu.fund_id = p_fund_id
AND fu.product_level_type = 'PRODUCT'
AND fu.product_id = p_product_id
AND fu.gl_posted_flag = 'Y'
AND fu.plan_type = 'OFFR'
GROUP BY cust_account_id, plan_type, plan_id, product_id, currency_code;


BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_Existing_Accruals;

  IF OZF_DEBUG_HIGH_ON THEN
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
         )
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  -------------------- start -------------------
  l_funds_util_flt := p_funds_util_flt;
  l_total_acctd_amount_rem := 0;
  l_product_level_type := 'PRODUCT';

  -- Fetching Product (product_id) and its correponding amount (l_product_amount) for the batch.
  FOR batch_lines_rec IN csr_batch_lines(l_claim_rec.source_object_id)
  LOOP

     l_batch_product_id := batch_lines_rec.product_id;
     l_batch_product_amount := batch_lines_rec.total_amount;
     l_batch_fund_id := l_funds_util_flt.fund_id;
     l_batch_currency_code := batch_lines_rec.currency_code;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Customer Account Id      : ' || l_funds_util_flt.cust_account_id);
        OZF_UTILITY_PVT.debug_message('Fund_id                  : ' || l_batch_fund_id);
        OZF_UTILITY_PVT.debug_message('Product Amount           : ' || l_batch_product_amount);
        OZF_UTILITY_PVT.debug_message('Product id               : ' || l_batch_product_id);
     END IF;

         -- Fetching cust_account_id, plan_type, plan_id, product_id, amount for the utilization based on the batch's cust_account_id, Fund_id, Product_id.
         FOR get_utils_rec IN csr_get_utils(l_funds_util_flt.cust_account_id, l_batch_fund_id, l_batch_product_id)
         LOOP

           l_cust_account_id := get_utils_rec.cust_account_id;
           l_plan_type := get_utils_rec.plan_type;
           l_plan_id := get_utils_rec.plan_id;
           l_product_id := get_utils_rec.product_id;
           l_accrual_amount := get_utils_rec.amount;
           l_currency_code := get_utils_rec.currency_code;

           IF OZF_DEBUG_HIGH_ON THEN
                OZF_Utility_PVT.debug_message('get_utils_rec.cust_account_id    : ' || l_cust_account_id);
                OZF_UTILITY_PVT.debug_message('get_utils_rec.plan_type          : ' || l_plan_type);
                OZF_UTILITY_PVT.debug_message('get_utils_rec.plan_id            : ' || l_plan_id);
                OZF_UTILITY_PVT.debug_message('get_utils_rec.product_id         : ' || l_product_id);
                OZF_UTILITY_PVT.debug_message('get_utils_rec.amount             : ' || l_accrual_amount);
                OZF_UTILITY_PVT.debug_message('get_utils_rec.currency_code      : ' || l_currency_code);
           END IF;

           -- Calling Currency_conversion for converting accrual to batch currency

           IF l_currency_code <> l_batch_currency_code THEN
              OZF_UTILITY_PVT.Convert_Currency(
                 p_from_currency   => l_currency_code
                ,p_to_currency     => l_batch_currency_code
                ,p_conv_date       => SYSDATE
                ,p_from_amount     => l_accrual_amount                  -- accrual amount
                ,x_return_status   => l_return_status
                ,x_to_amount       => l_amount                          -- accrual amount in batch currency
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
           ELSE
             l_amount := l_accrual_amount;                              -- accrual amount in batch currency
           END IF;

           IF l_amount IS NOT NULL AND l_amount <> 0 THEN

              IF OZF_DEBUG_HIGH_ON THEN
                 OZF_Utility_PVT.debug_message('-------------Before using Accruals Logic------------');
                 OZF_Utility_PVT.debug_message('Line No ' || l_counter);
                 OZF_Utility_PVT.debug_message('l_cust_account_id = ' || l_cust_account_id);
                 OZF_Utility_PVT.debug_message('l_plan_type = ' || l_plan_type);
                 OZF_Utility_PVT.debug_message('l_plan_id = ' || l_plan_id);
                 OZF_Utility_PVT.debug_message('l_product_id = ' || l_product_id);
                 OZF_Utility_PVT.debug_message('l_amount = ' || l_amount);
                 OZF_Utility_PVT.debug_message('l_currency_code = ' || l_currency_code);
                 OZF_Utility_PVT.debug_message('----------------------------------------------------');
              END IF;

              -- USE l_amount from Accruals and continue with the ITERATION

              IF l_batch_product_amount >= l_amount THEN
                 l_batch_product_amount := l_batch_product_amount - l_amount;
                 l_amount_utilized := l_amount;

              ELSE
                 l_amount_utilized := l_batch_product_amount;
                 l_batch_product_amount := 0;
              END IF;

              IF OZF_DEBUG_HIGH_ON THEN
                 OZF_Utility_PVT.debug_message('-------------After using Accruals ------------');
                 OZF_Utility_PVT.debug_message('l_batch_product_amount = ' || l_batch_product_amount);
                 OZF_Utility_PVT.debug_message('l_amount_utilized = ' || l_amount_utilized);
                 OZF_Utility_PVT.debug_message('l_amount = ' || l_amount);
                 OZF_Utility_PVT.debug_message('----------------------------------------------');
              END IF;

              -- Processing utilization amount logic goes here
              -- We are taking l_amount_utilized for Processing of l_line_tbl(l_counter).XXXX.

                 l_line_tbl(l_counter).claim_currency_amount     := l_amount_utilized;
                 l_line_tbl(l_counter).activity_type             := l_plan_type;
                 l_line_tbl(l_counter).activity_id               := l_plan_id;
                 l_line_tbl(l_counter).item_type                 := l_product_level_type;
                 l_line_tbl(l_counter).item_id                   := l_product_id;

                 IF l_product_level_type = 'PRODUCT' AND l_product_id IS NOT NULL THEN
                    OPEN csr_uom_code(l_line_tbl(l_counter).item_id);
                    FETCH csr_uom_code INTO l_line_tbl(l_counter).quantity_uom;
                    IF csr_uom_code%NOTFOUND THEN
                       CLOSE csr_uom_code;
                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('OZF', 'OZF_PRODUCT_UOM_MISSING');
                          FND_MESSAGE.Set_Token('ITEM_ID', l_line_tbl(l_counter).item_id);
                          FND_MSG_PUB.ADD;
                       END IF;
                       RAISE FND_API.g_exc_unexpected_error;
                    END IF;
                    CLOSE csr_uom_code;
                 END IF;

                 IF l_plan_type = 'OFFR' AND l_plan_id IS NOT NULL THEN
                    OPEN csr_offer_perf(l_plan_id);
                    FETCH csr_offer_perf INTO l_dummy;
                    CLOSE csr_offer_perf;

                    IF l_dummy = 1 THEN
                       l_line_tbl(l_counter).performance_attached_flag := FND_API.G_TRUE;
                       l_line_tbl(l_counter).performance_complete_flag := FND_API.G_TRUE;
                    END IF;
                 END IF;

                 l_counter := l_counter + 1;
                 l_total_amount_utilized := l_total_amount_utilized + l_amount_utilized;

              ELSE
                 IF OZF_DEBUG_HIGH_ON THEN
                    OZF_Utility_PVT.debug_message('Performance requirements not met.');
                 END IF;
                 IF p_claim_rec.created_from = 'AUTOPAY' THEN
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Performance requirements not met.');
                 END IF;

           END IF;      -- End of l_amount <> 0


           -- Breaking the loop, since l_batch_product_amount of product is successfully utilized.
           -- else continue with the utilization loop until l_batch_product_amount becomes 0.

           EXIT WHEN l_batch_product_amount = 0;

        END LOOP;               -- Ending loop of utilization


     -- suppose after utilizing all the accruals and still there is some batch_amount to be settled
     -- i.e., l_batch_product_amount > 0, set the flag as 'f' and dispute the batch by exiting the loops.

     IF l_batch_product_amount > 0 THEN
        l_batch_settlement_flag := 'F';
        EXIT;                   -- If l_batch_settlement_flag = 'f' break the batch loop
     ELSE
        l_batch_settlement_flag := 'T';
     END IF;

  END LOOP;             -- Ending loop of batch

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('-------------After Ending batch loop ------------');
        OZF_Utility_PVT.debug_message('l_batch_product_amount = ' || l_batch_product_amount);
        OZF_Utility_PVT.debug_message('l_batch_settlement_flag = ' || l_batch_settlement_flag);
        OZF_Utility_PVT.debug_message('l_total_amount_utilized = ' || l_total_amount_utilized);
        OZF_Utility_PVT.debug_message('-------------------------------------------------');
     END IF;

    -- If flag = f then dispute the batch and batch lines
    IF l_batch_settlement_flag = 'F' THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('OZF', 'OZF_CHBK_NO_FUNDS');
        FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

  IF l_total_amount_utilized <> 0 THEN
     l_claim_rec.amount := l_total_amount_utilized;
     IF l_total_amount_utilized < 0 THEN
        l_claim_rec.payment_method := 'DEBIT_MEMO';
     END IF;

     -- create claim in OPEN status, ignoring the status passed in
     l_claim_rec.status_code    := 'OPEN';
     l_claim_rec.user_status_id := to_number(ozf_utility_pvt.get_default_user_status(
                                                p_status_type   => 'OZF_CLAIM_STATUS',
                                                p_status_code   => l_claim_rec.status_code));

     l_claim_rec.source_object_class := NULL;
     l_claim_rec.source_object_id := NULL;
     l_claim_rec.source_object_number := NULL;

     OZF_CLAIM_PVT.Create_Claim(
        p_api_version            => l_api_version
       ,x_return_status          => l_return_status
       ,x_msg_data               => x_msg_data
       ,x_msg_count              => x_msg_count
       ,p_claim                  => l_claim_rec
       ,x_claim_id               => l_claim_id
     );
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Claim created id: ' || l_claim_id);
     END IF;

     FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST LOOP
        IF l_line_tbl.exists(i) IS NOT NULL THEN
           l_line_tbl(i).claim_id := l_claim_id;
        END IF;
     END LOOP;

     OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
        p_api_version       => 1.0
       ,p_init_msg_list     => FND_API.g_false
       ,p_commit            => FND_API.g_false
       ,p_validation_level  => FND_API.g_valid_level_full
       ,x_return_status     => l_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_claim_line_tbl    => l_line_tbl
       ,x_error_index       => l_error_index
     );

     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
     END IF;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Claim lines created for claim_id=' || l_claim_id);
     END IF;

     OPEN csr_claim_line(l_claim_id);
     LOOP
        FETCH csr_claim_line INTO l_funds_util_flt.claim_line_id
                                , l_funds_util_flt.activity_type
                                , l_funds_util_flt.activity_id
                                , l_funds_util_flt.product_level_type
                                , l_funds_util_flt.product_id
                                , l_funds_util_flt.total_amount;
        EXIT WHEN csr_claim_line%NOTFOUND;

        Update_Group_Line_Util(
           p_api_version         => 1.0
          ,p_init_msg_list       => FND_API.g_false
          ,p_commit              => FND_API.g_false
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_summary_view        => 'ACTIVITY'
          ,p_funds_util_flt      => l_funds_util_flt
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_error;
        END IF;
     END LOOP;
     CLOSE csr_claim_line;

  END IF;  -- end of l_amount_utilized <> 0

  x_claim_id := l_claim_id;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Create_Claim_Existing_Accruals;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_Existing_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_Existing_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_Existing_Accruals;

---------------------------------------------------------------------
-- PROCEDURE
--    Pay_Claim_For_Accruals
--
-- PURPOSE
--    Create a claim, associate earnings based on search filters, and
--    close the claim
--
-- PARAMETERS
--    p_claim_rec: claim record
--    p_funds_util_flt: search filter for earnings
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Pay_Claim_For_Accruals(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full
  ,p_accrual_flag        IN  VARCHAR2

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_rec           IN  ozf_claim_pvt.claim_rec_type
  ,p_funds_util_flt      IN  ozf_claim_accrual_pvt.funds_util_flt_type

  ,x_claim_id            OUT NOCOPY NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Pay_Claim_For_Accruals';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_funds_util_flt     funds_util_flt_type;
l_claim_rec          OZF_CLAIM_PVT.claim_rec_type;
l_claim_id           NUMBER;
l_cust_trade_profile g_cust_trade_profile_csr%rowtype;
l_party_name         VARCHAR2(360);
l_close_claim_flag   VARCHAR2(1);
l_accrual_flag       VARCHAR2(1):= p_accrual_flag;

CURSOR csr_party_name(cv_cust_account_id IN NUMBER) IS
  SELECT p.party_name
  FROM hz_parties p, hz_cust_accounts c
  WHERE p.party_id = c.party_id
  AND c.cust_account_id = cv_cust_account_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Pay_Claim_For_Accruals;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- start ----------------
  l_claim_rec := p_claim_rec;

  l_close_claim_flag := 'T';

  IF l_claim_rec.payment_method IS NULL THEN
    -- get payment method information from trade profile
    Get_Cust_Trade_Profile(
      p_cust_account_id     => p_claim_rec.cust_account_id
     ,x_cust_trade_profile  => l_cust_trade_profile
     ,p_site_use_id         => p_claim_rec.cust_billto_acct_site_id
    );

    IF l_cust_trade_profile.trade_profile_id IS NOT NULL THEN
      Validate_Cust_Trade_Profile(
        p_cust_trade_profile  => l_cust_trade_profile
       ,x_return_status       => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_error or
        l_return_status = FND_API.g_ret_sts_unexp_error THEN
        -- trade profile has errors. do not close claim in batch process
        -- and raise error in other cases
        IF l_claim_rec.source_object_class = OZF_RESALE_COMMON_PVT.G_BATCH_OBJECT_CLASS THEN
          l_close_claim_flag := 'F';
        ELSE
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;

      -- [BEGIN OF BUG 4217781 FIXING]
      IF l_claim_rec.source_object_class = OZF_RESALE_COMMON_PVT.G_BATCH_OBJECT_CLASS AND
         l_cust_trade_profile.autopay_flag <> 'T' THEN
         l_close_claim_flag := 'F';
      END IF;
      -- [END OF BUG 4217781 FIXING]

      IF l_cust_trade_profile.payment_method <> FND_API.G_MISS_CHAR THEN -- [BUG 4217781 FIXING]
         l_claim_rec.payment_method := l_cust_trade_profile.payment_method;
      END IF;
      l_claim_rec.cust_billto_acct_site_id := l_cust_trade_profile.site_use_id;
      l_claim_rec.vendor_id := l_cust_trade_profile.vendor_id;
      l_claim_rec.vendor_site_id := l_cust_trade_profile.vendor_site_id;
    ELSE
      -- trade profile does not exists. do not close claim in batch process
      -- and raise error in other cases
      IF l_claim_rec.source_object_class = OZF_RESALE_COMMON_PVT.G_BATCH_OBJECT_CLASS THEN
        l_close_claim_flag := 'F';
      ELSE
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          OPEN csr_party_name(p_claim_rec.cust_account_id);
          FETCH csr_party_name INTO l_party_name;
          CLOSE csr_party_name;

          FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_NO_TRADE_PROFILE');
          FND_MESSAGE.Set_Token('CUST_NAME', l_party_name);
          FND_MSG_PUB.ADD;
        END IF;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('Payment method is '||l_claim_rec.payment_method);
     OZF_Utility_PVT.debug_message('Autopay Flag is '||l_cust_trade_profile.autopay_flag);
     OZF_Utility_PVT.debug_message('Close Claim Flag is '||l_close_claim_flag);
     OZF_Utility_PVT.debug_message('Invokes Create_Claim_For_Accruals ');
  END IF;

  --Bug# 8632964 fixed by anuj & muthsubr (+)
  IF l_claim_rec.source_object_class = OZF_RESALE_COMMON_PVT.G_BATCH_OBJECT_CLASS AND
     l_claim_rec.batch_type = OZF_RESALE_COMMON_PVT.G_BATCH_REF_TYPE AND
     l_accrual_flag = 'T'
  THEN
  Create_Claim_For_Accruals(
     p_api_version         => l_api_version
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => p_validation_level
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data
    ,p_claim_rec           => l_claim_rec
    ,p_funds_util_flt      => p_funds_util_flt
    ,x_claim_id            => l_claim_id
  );
          IF l_return_status =  fnd_api.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
   ELSE
           Create_Claim_Existing_Accruals(
                p_api_version         => l_api_version
               ,p_init_msg_list       => FND_API.g_false
               ,p_commit              => FND_API.g_false
               ,p_validation_level    => p_validation_level
               ,x_return_status       => l_return_status
               ,x_msg_count           => x_msg_count
               ,x_msg_data            => x_msg_data
               ,p_claim_rec           => l_claim_rec
               ,p_funds_util_flt      => p_funds_util_flt
               ,x_claim_id            => l_claim_id
             );
  IF l_return_status =  fnd_api.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  END IF;
  --Bug# 8632964 fixed by anuj & muthsubr (-)


  IF l_claim_id IS NOT NULL AND l_close_claim_flag = 'T' THEN
    Settle_Claim(
       p_claim_id            => l_claim_id
      ,x_return_status       => l_return_status
      ,x_msg_count           => x_msg_count
      ,x_msg_data            => x_msg_data
    );
    IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  x_claim_id := l_claim_id;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Pay_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Pay_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Pay_Claim_For_Accruals;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Pay_Claim_For_Accruals;


---------------------------------------------------------------------
-- PROCEDURE
--    Asso_Accruals_To_Claim
--
-- PURPOSE
--    Associate earnings to the given claim based on given filters.
--
-- PARAMETERS
--    p_claim_id:
--    p_funds_util_flt:
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_id            IN  NUMBER
  ,p_funds_util_flt      IN  funds_util_flt_type
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Asso_Accruals_To_Claim';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

-- Added For Bug 7509079
l_funds_util_flt     funds_util_flt_type := p_funds_util_flt;

l_line_tbl           OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_cust_account_id    NUMBER;
l_plan_type          VARCHAR2(30);
l_plan_id            NUMBER;
l_product_level_type VARCHAR2(30);
l_product_id         NUMBER;
l_total_amount       NUMBER;
l_amount             NUMBER;

l_emp_csr            NUMBER;
l_error_index        NUMBER;
l_counter            PLS_INTEGER := 1;
l_ignore             NUMBER;
l_dummy              VARCHAR2(1);
l_stmt               VARCHAR2(3000);
l_currency_code      VARCHAR2(15);
--Added For Bug 7605745
l_bill_to_site_id      NUMBER;

-- Fix for Bug 7632911
l_claim_class         VARCHAR2(15);

-- Added For Multi Currency - kpatro
l_claim_currency_code VARCHAR2(15);

l_currency_rec       currency_rec_type;
-- Added For Bug 7611966
CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_uom_code(cv_item_id IN NUMBER) IS
  SELECT primary_uom_code
  FROM mtl_system_items
  WHERE inventory_item_id = cv_item_id
  AND organization_id = FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID');

-- Fix for Bug 7632911
-- Added the currency_code for Multi Currency - kpatro
CURSOR csr_claim_info(cv_claim_id IN NUMBER) IS
  SELECT cust_account_id, amount,claim_class,currency_code
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

 --Fix For Bug 7611966
CURSOR csr_claim_line_util(cv_claim_line_id IN NUMBER, cv_claim_id NUMBER) IS
  SELECT claim_line_id
       , activity_type
       , activity_id
       , item_id
       , claim_currency_amount
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id
  AND claim_id = cv_claim_id;
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs
  ,    ozf_sys_parameters org
  WHERE org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Asso_Accruals_To_Claim;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- start ----------------

 -- Added the currency_code for Multi Currency - kpatro
  OPEN csr_claim_info(p_claim_id);
  FETCH csr_claim_info INTO l_cust_account_id, l_total_amount,l_claim_class,l_claim_currency_code;
  IF csr_claim_info%NOTFOUND THEN
    CLOSE csr_claim_info;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_ID_NOT_EXIST');
      FND_MESSAGE.Set_Token('CLAIM_ID', p_claim_id);
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  CLOSE csr_claim_info;

  -- Assigning the Claim Currency for Multi Currency - kpatro
  l_currency_rec.claim_currency_code       := l_claim_currency_code;
  l_currency_rec.transaction_currency_code := l_funds_util_flt.utiz_currency_code;

  OPEN csr_function_currency;
  FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
  CLOSE csr_function_currency;


   IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
      l_currency_rec.association_currency_code := l_currency_rec.transaction_currency_code;
   ELSE
     l_currency_rec.association_currency_code := l_currency_rec.functional_currency_code;
   END IF;

   --Set UNIVERSAL currency from profile.
  l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('l_currency_rec.universal_currency_code :' || l_currency_rec.universal_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.claim_currency_code :' || l_currency_rec.claim_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.functional_currency_code :' || l_currency_rec.functional_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.transaction_currency_code :' || l_currency_rec.transaction_currency_code);
     OZF_Utility_PVT.debug_message('l_currency_rec.association_currency_code :' || l_currency_rec.association_currency_code);
  END IF;


  -- default cust_account_id if not given in parameters
  IF l_funds_util_flt.cust_account_id IS NULL THEN
    l_funds_util_flt.cust_account_id := l_cust_account_id;
  END IF;

   -- Fix for Bug 7632911
  IF l_funds_util_flt.total_amount IS NULL OR
     SIGN(l_funds_util_flt.total_amount) > SIGN(l_total_amount)
  THEN
    l_funds_util_flt.total_amount := l_total_amount;
  ELSE
    l_total_amount := l_funds_util_flt.total_amount;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_funds_util_flt.utilization_id||': Before dynamic');
  END IF;

  Get_Utiz_Sql_Stmt(
     p_api_version         => 1.0
    ,p_init_msg_list       => FND_API.g_false
    ,p_commit              => FND_API.g_false
    ,p_validation_level    => FND_API.g_valid_level_full
    ,x_return_status       => l_return_status
    ,x_msg_count           => x_msg_count
    ,x_msg_data            => x_msg_data
    ,p_summary_view        => 'AUTOPAY_LINE'
    ,p_funds_util_flt      => l_funds_util_flt
    ,px_currency_rec       => l_currency_rec
    ,p_cust_account_id     => l_funds_util_flt.cust_account_id
    ,x_utiz_sql_stmt       => l_stmt
  );

  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_error;
  END IF;

  l_emp_csr := DBMS_SQL.open_cursor;
  FND_DSQL.set_cursor(l_emp_csr);
   DBMS_SQL.parse(l_emp_csr, l_stmt, DBMS_SQL.native);
  DBMS_SQL.define_column(l_emp_csr, 1, l_cust_account_id);
  DBMS_SQL.define_column(l_emp_csr, 2, l_plan_type, 30);
  DBMS_SQL.define_column(l_emp_csr, 3, l_plan_id);
  DBMS_SQL.define_column(l_emp_csr, 4, l_bill_to_site_id); --Fix for Bug 7605745
  DBMS_SQL.define_column(l_emp_csr, 5, l_product_level_type, 30);
  DBMS_SQL.define_column(l_emp_csr, 6, l_product_id);
  DBMS_SQL.define_column(l_emp_csr, 7, l_amount);
  DBMS_SQL.define_column(l_emp_csr, 8, l_currency_code, 15);
  FND_DSQL.do_binds;

  l_ignore := DBMS_SQL.execute(l_emp_csr);
  LOOP
    IF DBMS_SQL.fetch_rows(l_emp_csr) > 0 AND l_total_amount <> 0 THEN
       DBMS_SQL.column_value(l_emp_csr, 1, l_cust_account_id);
      DBMS_SQL.column_value(l_emp_csr, 2, l_plan_type);
      DBMS_SQL.column_value(l_emp_csr, 3, l_plan_id);
      DBMS_SQL.column_value(l_emp_csr, 4, l_bill_to_site_id); --Fix for Bug 7605745
      DBMS_SQL.column_value(l_emp_csr, 5, l_product_level_type);
      DBMS_SQL.column_value(l_emp_csr, 6, l_product_id);
      DBMS_SQL.column_value(l_emp_csr, 7, l_amount);
      DBMS_SQL.column_value(l_emp_csr, 8, l_currency_code);

      IF l_amount IS NOT NULL AND l_amount <> 0 THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Line ' || l_counter || ': Amount='||l_amount);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Plan Type         :  ' || l_plan_type);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Plan Id           :  ' || l_plan_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Product Level Type:  ' || l_product_level_type);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Product Id        :  ' || l_product_id);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------------------------');

        -- Fix for Bug 7632911
        IF (l_total_amount >= l_amount AND l_claim_class <>'CHARGE') THEN
          l_line_tbl(l_counter).claim_currency_amount   := l_amount;
          l_total_amount := l_total_amount - l_amount;
        ELSE
          l_line_tbl(l_counter).claim_currency_amount   := l_total_amount;
          -- Fix for Bug 7632911
          IF (l_claim_class = 'CHARGE') THEN
           l_total_amount := l_total_amount - l_amount;
          ELSE
          l_total_amount := 0;
          END IF;
        END IF;

        l_line_tbl(l_counter).claim_id                  := p_claim_id;
        l_line_tbl(l_counter).activity_type             := l_plan_type;
        l_line_tbl(l_counter).activity_id               := l_plan_id;
        l_line_tbl(l_counter).relationship_type         := l_funds_util_flt.relationship_type;
        l_line_tbl(l_counter).related_cust_account_id   := l_funds_util_flt.related_cust_account_id;
        l_line_tbl(l_counter).buy_group_party_id        := l_funds_util_flt.buy_group_party_id;
        l_line_tbl(l_counter).select_cust_children_flag := l_funds_util_flt.select_cust_children_flag;
        -- Added For Bug 8402328
        l_line_tbl(l_counter).utilization_id := l_funds_util_flt.utilization_id;
        IF l_product_level_type = 'PRODUCT' AND l_product_id IS NOT NULL THEN
          l_line_tbl(l_counter).item_id                   := l_product_id;
          OPEN csr_uom_code(l_line_tbl(l_counter).item_id);
          FETCH csr_uom_code INTO l_line_tbl(l_counter).quantity_uom;
          IF csr_uom_code%NOTFOUND THEN
            CLOSE csr_uom_code;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_PRODUCT_UOM_MISSING');
              FND_MESSAGE.Set_Token('ITEM_ID', l_product_id);
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
          CLOSE csr_uom_code;
        END IF;

        /*
        IF l_funds_util_flt.activity_type = 'OFFR' THEN
          l_dummy := Check_for_Offer_Performance ( p_cust_account_id   => l_funds_util_flt.cust_account_id
                                                 , p_funds_util_flt    => l_funds_util_flt
                                                 , x_return_status     => l_return_status
                                                 );

          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_error;
          END IF;

          IF l_dummy = FND_API.G_TRUE THEN
            l_line_tbl(l_counter).performance_attached_flag := FND_API.G_TRUE;
            l_line_tbl(l_counter).performance_complete_flag := FND_API.G_TRUE;
          END IF;
        END IF;
        */

        l_counter := l_counter + 1;
      END IF;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.close_cursor(l_emp_csr);

  -- if earnings are found
  IF l_counter > 1 THEN
    OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
       p_api_version       => 1.0
      ,p_init_msg_list     => FND_API.g_false
      ,p_commit            => FND_API.g_false
      ,p_validation_level  => FND_API.g_valid_level_full
      ,x_return_status     => l_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_claim_line_tbl    => l_line_tbl
      ,x_error_index       => l_error_index
    );

    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_error;
    END IF;

    -- Added For Bug 7611966
    OPEN csr_claim_line(p_claim_id);
    LOOP
      FETCH csr_claim_line INTO l_funds_util_flt.claim_line_id;
      EXIT WHEN csr_claim_line%NOTFOUND;
    END  LOOP;
    CLOSE csr_claim_line;

      -- Fix For Bug 7611966
     OPEN csr_claim_line_util(l_funds_util_flt.claim_line_id,p_claim_id);
     LOOP
      FETCH csr_claim_line_util INTO l_funds_util_flt.claim_line_id
                              , l_funds_util_flt.activity_type
                              , l_funds_util_flt.activity_id
                              , l_funds_util_flt.product_id
                              , l_funds_util_flt.total_amount;
      EXIT WHEN csr_claim_line_util%NOTFOUND;

      Update_Group_Line_Util(
         p_api_version         => 1.0
        ,p_init_msg_list       => FND_API.g_false
        ,p_commit              => FND_API.g_false
        ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status       => l_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        ,p_summary_view        => 'ACTIVITY'
        ,p_funds_util_flt      => l_funds_util_flt
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
      END IF;
    END LOOP;
    CLOSE csr_claim_line_util;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Asso_Accruals_To_Claim;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Asso_Accruals_To_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Asso_Accruals_To_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Asso_Accruals_To_Claim;


---------------------------------------------------------------------
-- PROCEDURE
--    Asso_Accruals_To_Claim_Line
--
-- PURPOSE
--    Associate earnings to the given claim line based on line
--    properties
--
-- PARAMETERS
--    p_claim_line_id:
--
-- NOTES
-- modified for Bugfix 5182452 l_funds_util populated with claim line info.
---------------------------------------------------------------------
PROCEDURE Asso_Accruals_To_Claim_Line(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_line_id       IN  NUMBER
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Asso_Accruals_To_Claim_Line';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_funds_util_flt     funds_util_flt_type;
l_line_id            NUMBER;

--start of bugfix 5182452
CURSOR csr_line_info(cv_claim_line_id IN NUMBER) IS
 select  claim_line_id
, plan_id
, activity_type
, activity_id
, offer_type
, source_object_class --> document_class
, source_object_id  -->    document_id
, item_id -->product_id
, amount -->total_amount
, quantity
, quantity_uom -->uom_code
, relationship_type
, related_cust_account_id
, buy_group_cust_account_id
, buy_group_party_id
, select_cust_children_flag
, prorate_earnings_flag
, utilization_id -- Added For Bug 8402328
from ozf_claim_lines_all
WHERE claim_line_id = cv_claim_line_id;

--used to derive old_total_amount
CURSOR csr_sum_util_amounts(cv_claim_line_id IN NUMBER) IS
select sum(amount)
from ozf_claim_lines_util
where claim_line_id = cv_claim_line_id;

--used to derive old_total_units
CURSOR csr_sum_scan_units(cv_claim_line_id IN NUMBER) IS
select sum(scan_unit)
from ozf_claim_lines_util
where claim_line_id = cv_claim_line_id;
--end of bugfix 5182452

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Asso_Accruals_To_Claim_Line;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- Associate earnings ----------------
  -- verify the claim exists
  --start of bugfix 5182452

 OPEN csr_line_info(p_claim_line_id);
  FETCH csr_line_info INTO l_funds_util_flt.claim_line_id,
      l_funds_util_flt.fund_id
     ,l_funds_util_flt.activity_type
     ,l_funds_util_flt.activity_id
     , l_funds_util_flt.offer_type
     , l_funds_util_flt.document_class
     , l_funds_util_flt.document_id
     ,l_funds_util_flt.product_id
     , l_funds_util_flt.total_amount
     , l_funds_util_flt.quantity
     , l_funds_util_flt.uom_code
     , l_funds_util_flt.relationship_type
     , l_funds_util_flt.related_cust_account_id
     , l_funds_util_flt.buy_group_cust_account_id
     , l_funds_util_flt.buy_group_party_id
     , l_funds_util_flt.select_cust_children_flag
     ,l_funds_util_flt.prorate_earnings_flag
     ,l_funds_util_flt.utilization_id; -- Added For Bug 8402328

  IF csr_line_info%NOTFOUND THEN
    CLOSE csr_line_info;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_LINEID_NOT_EXIST');
      FND_MESSAGE.Set_Token('LINE_ID', p_claim_line_id);
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  CLOSE csr_line_info;

   OPEN csr_sum_util_amounts(p_claim_line_id);
   FETCH csr_sum_util_amounts INTO l_funds_util_flt.old_total_amount;

    IF csr_sum_util_amounts%NOTFOUND THEN
    CLOSE csr_line_info;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_LINEID_NOT_EXIST');
      FND_MESSAGE.Set_Token('LINE_ID', p_claim_line_id);
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  CLOSE csr_sum_util_amounts;

   OPEN csr_sum_scan_units(p_claim_line_id);
   FETCH csr_sum_scan_units INTO l_funds_util_flt.old_total_units;

    IF csr_sum_scan_units%NOTFOUND THEN
    CLOSE csr_line_info;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_LINEID_NOT_EXIST');
      FND_MESSAGE.Set_Token('LINE_ID', p_claim_line_id);
      FND_MSG_PUB.ADD;
    END IF;
    RAISE FND_API.g_exc_unexpected_error;
  END IF;
  CLOSE csr_sum_scan_units;
  --end of bugfix 5182452

  Update_Group_Line_Util(
     p_api_version            => l_api_version
    ,p_init_msg_list          => FND_API.g_false
    ,p_commit                 => FND_API.g_false
    ,p_validation_level       => p_validation_level
    ,x_return_status          => l_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data               => x_msg_data
    ,p_summary_view           => null
    ,p_funds_util_flt         => l_funds_util_flt
    ,p_mode                   => OZF_CLAIM_UTILITY_PVT.g_auto_mode
  );
  IF l_return_status =  fnd_api.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Asso_Accruals_To_Claim_Line;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Asso_Accruals_To_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Asso_Accruals_To_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Asso_Accruals_To_Claim_Line;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Per_SPR
--
-- PURPOSE
--    Create claim for each SPR in Ship and Debit batch.
--
-- PARAMETERS
--    p_resale_batch_id: resale batch id
--
-- NOTES
--
-- HISTORY
-- 03-Jun-09  ateotia  Created.
--                     Bug# 8571085 fixed.
---------------------------------------------------------------------
PROCEDURE Create_Claim_Per_SPR(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_resale_batch_id   IN  NUMBER
)
IS
l_api_version    CONSTANT  NUMBER       := 1.0;
l_api_name       CONSTANT  VARCHAR2(30) := 'Create_Claim_Per_SPR';
l_full_name      CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status            VARCHAR2(1);
l_cust_account_id          NUMBER;
l_partner_id               NUMBER;
l_claim_curr_code          VARCHAR2(15);
l_line_curr_code           VARCHAR2(15);
l_request_header_id        NUMBER;
l_request_number           VARCHAR2(30);
l_agreement_number         VARCHAR2(240);
l_product_id               NUMBER;
l_uom_code                 VARCHAR2(3);
l_quantity                 NUMBER;
l_line_amount              NUMBER;
l_new_line_amount          NUMBER;
l_claim_amount             NUMBER;
l_claim_id                 NUMBER;
l_claim_rec                OZF_CLAIM_PVT.claim_rec_type;
l_line_tbl                 OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_cust_trade_profile       g_cust_trade_profile_csr%rowtype;
l_payment_method           VARCHAR2(30);
l_cust_billto_acct_site_id NUMBER;
l_vendor_id                NUMBER;
l_vendor_site_id           NUMBER;
l_claim_line_id            NUMBER;
l_party_name               VARCHAR2(360);
l_close_claim_flag         VARCHAR2(1);
l_partner_claim_num        VARCHAR2(30);
l_counter                  PLS_INTEGER := 1;
l_error_index              NUMBER;
l_scan_value               NUMBER;
l_offer_uom_code           VARCHAR2(3);
l_offer_quantity           NUMBER;
l_trans_curr_code          VARCHAR2(15);
l_new_claim_quantity       NUMBER;
l_exchange_rate_type       VARCHAR2(30) := FND_API.G_MISS_CHAR;
l_rate                     NUMBER;

--POS Batch Processing by profiles by ateotia (+)
l_ship_from_stock_flag     VARCHAR2(1);
l_offer_type               VARCHAR2(30);
--POS Batch Processing by profiles by ateotia (-)

CURSOR csr_resale_batch(cv_batch_id IN NUMBER) IS
  SELECT partner_cust_account_id
       , partner_id
       , currency_code
       , partner_claim_number
  FROM ozf_resale_batches
  WHERE resale_batch_id = cv_batch_id;

CURSOR csr_batch_request(cv_batch_id IN NUMBER, cv_partner_id IN NUMBER) IS
  SELECT r.request_header_id
       , r.request_number
       --POS Batch Processing by profiles by ateotia (+)
       , r.ship_from_stock_flag
       , r.offer_type
       --POS Batch Processing by profiles by ateotia (-)
       , s.agreement_name
  FROM   ozf_resale_lines_int s
       , ozf_request_headers_all_b r
  WHERE  s.resale_batch_id = cv_batch_id
  AND    s.agreement_name = r.agreement_number
  AND    r.partner_id = cv_partner_id
  AND    r.status_code = 'APPROVED'
  AND    r.request_class = 'SPECIAL_PRICE'
  GROUP BY r.request_header_id
         , r.request_number
         , s.agreement_name
         , r.ship_from_stock_flag
         , r.offer_type;

CURSOR csr_batch_line(cv_batch_id IN NUMBER, cv_agreement_number IN VARCHAR2) IS
  SELECT inventory_item_id
       , uom_code
       , sum(quantity)
       , currency_code
       , sum(total_accepted_amount)
  FROM ozf_resale_lines_int
  WHERE resale_batch_id = cv_batch_id
  AND agreement_name = cv_agreement_number
  AND status_code = 'PROCESSED'
  GROUP BY inventory_item_id
         , uom_code
         , currency_code;

-- added for Bugfix 5404951
CURSOR csr_ams_act_products(cv_agreement_number IN VARCHAR2 ,cv_product_id IN NUMBER) IS
  SELECT act.SCAN_VALUE
       , act.UOM_CODE
       , act.Quantity
       , off.TRANSACTION_CURRENCY_CODE
  FROM ozf_offers off
     , ams_act_products act
  WHERE offer_code  = cv_agreement_number
  AND   ARC_ACT_PRODUCT_USED_BY = 'OFFR'
  AND   ACT_PRODUCT_USED_BY_ID = off.qp_list_header_id
  AND   INVENTORY_ITEM_ID = cv_product_id;

CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_party_name(cv_cust_account_id IN NUMBER) IS
  SELECT p.party_name
  FROM hz_parties p
     , hz_cust_accounts c
  WHERE p.party_id = c.party_id
  AND   c.cust_account_id = cv_cust_account_id;

CURSOR c_get_conversion_type IS
  SELECT exchange_rate_type
  FROM   ozf_sys_parameters_all
  WHERE  org_id = MO_GLOBAL.GET_CURRENT_ORG_ID;

   --POS Batch Processing by profiles by rsatyava (+)
  l_auto_claim_profile varchar2(1):= FND_PROFILE.value('OZF_AUTO_CLAIM_POS');
  --POS Batch Processing by profiles by rsatyava (+)

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_Per_SPR;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- Process batch ----------------
  OPEN csr_resale_batch(p_resale_batch_id);
  FETCH csr_resale_batch INTO l_cust_account_id
                            , l_partner_id
                            , l_claim_curr_code
                            , l_partner_claim_num;
  CLOSE csr_resale_batch;

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('Process batch for customer id '||l_cust_account_id);
  END IF;

  l_close_claim_flag := 'T';

  -- get payment method information from trade profile
  Get_Cust_Trade_Profile(
      p_cust_account_id     => l_cust_account_id
     ,x_cust_trade_profile  => l_cust_trade_profile
  );

  IF l_cust_trade_profile.trade_profile_id IS NOT NULL THEN
     Validate_Cust_Trade_Profile(
        p_cust_trade_profile  => l_cust_trade_profile
       ,x_return_status       => l_return_status
     );

     -- do not settle claim if trade profile has errors
     IF l_return_status = FND_API.g_ret_sts_error or
        l_return_status = FND_API.g_ret_sts_unexp_error THEN
        l_close_claim_flag := 'F';
     END IF;

     l_payment_method := l_cust_trade_profile.payment_method;
     l_cust_billto_acct_site_id := l_cust_trade_profile.site_use_id;
     l_vendor_id := l_cust_trade_profile.vendor_id;
     l_vendor_site_id := l_cust_trade_profile.vendor_site_id;
  ELSE
     -- do not settle claim if trade profile does not exists
     l_close_claim_flag := 'F';
  END IF;

  OPEN csr_batch_request(p_resale_batch_id, l_partner_id);
  LOOP
     FETCH csr_batch_request INTO l_request_header_id
                                , l_request_number
                                --POS Batch Processing by profiles by ateotia (+)
                                , l_ship_from_stock_flag
                                , l_offer_type
                                --POS Batch Processing by profiles by ateotia (-)
                                , l_agreement_number;
     EXIT WHEN csr_batch_request%NOTFOUND;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('request id:'||l_request_header_id);
     END IF;


 --POS batch Profile change.added logic to create claim line only if the auto claim profile is set /offer type is scan data

    IF (l_auto_claim_profile='Y' ) OR (l_offer_type='SCAN_DATA') THEN
     -- create a claim per request(agreement)
     l_claim_amount := 0;
     l_counter := 1;

     --Added for 7360703
     IF l_line_tbl.EXISTS(1) THEN
        l_line_tbl.DELETE;
     END IF;

     OPEN csr_batch_line(p_resale_batch_id, l_agreement_number);
     LOOP
        FETCH csr_batch_line INTO l_product_id
                                , l_uom_code
                                , l_quantity
                                , l_line_curr_code
                                , l_line_amount;
        EXIT WHEN csr_batch_line%NOTFOUND;

        OPEN csr_ams_act_products(l_agreement_number, l_product_id );
        FETCH csr_ams_act_products INTO l_scan_value
                                      , l_offer_uom_code
                                      , l_offer_quantity
                                      , l_trans_curr_code;
        CLOSE csr_ams_act_products;

        -- calculate claim amount
        IF l_line_curr_code = l_claim_curr_code THEN
           l_new_line_amount := l_line_amount;
        ELSE
           --Added for bug 7030415, get exchange_rate type
           OPEN c_get_conversion_type;
           FETCH c_get_conversion_type INTO l_exchange_rate_type;
           CLOSE c_get_conversion_type;
           OZF_UTILITY_PVT.Convert_Currency(
              p_from_currency   => l_line_curr_code
             ,p_to_currency     => l_claim_curr_code
             ,p_conv_type       => l_exchange_rate_type
             ,p_conv_date       => SYSDATE
             ,p_from_amount     => l_line_amount
             ,x_return_status   => l_return_status
             ,x_to_amount       => l_new_line_amount
             ,x_rate            => l_rate);
           IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;
        END IF;
        l_claim_amount := l_claim_amount + l_new_line_amount;

        -- Bugfix 5404951
        IF l_offer_uom_code <> l_uom_code THEN
           --POS Batch Processing by profiles by ateotia (+)
           IF (l_ship_from_stock_flag = 'Y' AND l_offer_type = 'ACCRUAL') THEN
              l_new_claim_quantity := l_quantity;
           ELSE
           l_new_claim_quantity := (l_line_amount * l_offer_quantity) / l_scan_value ; -- correct qty in offer_uom
           END IF;
           --POS Batch Processing by profiles by ateotia (-)
           -- convert this to claim line uom
           l_quantity := inv_convert.inv_um_convert(
                            item_id         => l_product_id
                           ,precision       => 2
                           ,from_quantity   => l_new_claim_quantity
                           ,from_unit       => l_offer_uom_code
                           ,to_unit         => l_uom_code
                           ,from_name       => NULL
                           ,to_name         => NULL);
           IF l_quantity = -99999 THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                 FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
                 FND_MSG_PUB.add;
              END IF;
              RAISE FND_API.g_exc_error;
           END IF;

        ELSE
           -- the uom is same, only need to recalculate the correct quantity
             --POS Batch Processing by profiles by ateotia (+)
           IF (l_ship_from_stock_flag = 'Y' AND l_offer_type = 'SCAN_DATA') THEN
           l_quantity := (l_line_amount * l_offer_quantity) / l_scan_value;
           l_quantity := ROUND(l_quantity,2);
            END IF;
           --POS Batch Processing by profiles by ateotia (-)
        END IF;

        l_line_tbl(l_counter).activity_type             := 'SPECIAL_PRICE';
        l_line_tbl(l_counter).activity_id               := l_request_header_id;
        l_line_tbl(l_counter).item_type                 := 'PRODUCT';
        l_line_tbl(l_counter).item_id                   := l_product_id;
        l_line_tbl(l_counter).quantity_uom              := l_uom_code;
        l_line_tbl(l_counter).quantity                  := l_quantity;
        l_line_tbl(l_counter).currency_code             := l_line_curr_code;
        l_line_tbl(l_counter).amount                    := l_line_amount;
        l_line_tbl(l_counter).claim_currency_amount     := l_new_line_amount;

        l_counter := l_counter + 1;
     END LOOP;
     CLOSE csr_batch_line;
     END IF;

     -- create claim
     l_claim_rec.cust_account_id       := l_cust_account_id;
     l_claim_rec.source_object_class   := 'SPECIAL_PRICE';
     l_claim_rec.source_object_id      := l_request_header_id;
     l_claim_rec.source_object_number  := l_request_number;
     l_claim_rec.batch_id              := p_resale_batch_id;
     l_claim_rec.batch_type            := OZF_Resale_Common_PVT.G_BATCH_REF_TYPE;
     l_claim_rec.currency_code         := l_claim_curr_code;
     l_claim_rec.amount                := l_claim_amount;
     l_claim_rec.payment_method        := l_payment_method;
     --bug # 6690147 julou FP 6276634(+)
     --For -ve claim the settlement method defined in trade profile is not valid.
     --So, hard coded to DEBIT_MEMO.
     IF l_claim_rec.amount < 0 AND l_payment_method IS NOT NULL AND l_payment_method <> FND_API.G_MISS_CHAR THEN
        l_claim_rec.payment_method := 'DEBIT_MEMO';
     END IF;
     --bug # 6690147 (-)
     l_claim_rec.cust_billto_acct_site_id := l_cust_billto_acct_site_id;
     l_claim_rec.vendor_id             := l_vendor_id;
     l_claim_rec.vendor_site_id        := l_vendor_site_id;
     l_claim_rec.status_code           := 'OPEN';
     l_claim_rec.user_status_id        := to_number(
                                             ozf_utility_pvt.get_default_user_status(
                                             p_status_type   => 'OZF_CLAIM_STATUS',
                                             p_status_code   => l_claim_rec.status_code));
     -- save batch's partner claim number as customer reference
     l_claim_rec.customer_ref_number   := l_partner_claim_num;

     OZF_CLAIM_PVT.Create_Claim(
        p_api_version            => l_api_version
       ,x_return_status          => l_return_status
       ,x_msg_data               => x_msg_data
       ,x_msg_count              => x_msg_count
       ,p_claim                  => l_claim_rec
       ,x_claim_id               => l_claim_id);
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Created claim id:'||l_claim_id);
     END IF;

     FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST LOOP
        IF l_line_tbl.exists(i) IS NOT NULL THEN
           l_line_tbl(i).claim_id := l_claim_id;
        END IF;
     END LOOP;

     OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
        p_api_version       => 1.0
       ,p_init_msg_list     => FND_API.g_false
       ,p_commit            => FND_API.g_false
       ,p_validation_level  => FND_API.g_valid_level_full
       ,x_return_status     => l_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
       ,p_claim_line_tbl    => l_line_tbl
       ,x_error_index       => l_error_index);
     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
     END IF;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Claim lines created for claim_id=' || l_claim_id);
     END IF;

     OPEN csr_claim_line(l_claim_id);
     LOOP
        FETCH csr_claim_line INTO l_claim_line_id;
        EXIT WHEN csr_claim_line%NOTFOUND;

        Asso_Accruals_To_Claim_Line(
           p_api_version         => 1.0
          ,p_init_msg_list       => FND_API.g_false
          ,p_commit              => FND_API.g_false
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data
          ,p_claim_line_id       => l_claim_line_id
        );

        IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_error;
        END IF;
     END LOOP;
     CLOSE csr_claim_line;

     IF l_close_claim_flag = 'T' THEN
        Settle_Claim(
           p_claim_id            => l_claim_id
          ,x_return_status       => l_return_status
          ,x_msg_count           => x_msg_count
          ,x_msg_data            => x_msg_data);
        IF l_return_status =  fnd_api.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;
     END IF;

  END LOOP;
  CLOSE csr_batch_request;

  ------------------------- finish -------------------------------
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data);

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Create_Claim_Per_SPR;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_Per_SPR;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_Per_SPR;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_Per_SPR;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Per_Batch
--
-- PURPOSE
--    Create consolidated claim for all SPR in Ship and Debit batch.
--
-- PARAMETERS
--    p_resale_batch_id: resale batch id
--
-- NOTES
--
-- HISTORY
-- 03-Jun-09  ateotia  Created.
--                     Bug# 8571085 fixed.
---------------------------------------------------------------------
PROCEDURE Create_Claim_Per_Batch(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_resale_batch_id   IN  NUMBER
)
IS
l_api_version    CONSTANT  NUMBER       := 1.0;
l_api_name       CONSTANT  VARCHAR2(30) := 'Create_Claim_Per_Batch';
l_full_name      CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status            VARCHAR2(1);
l_cust_account_id          NUMBER;
l_partner_id               NUMBER;
l_claim_curr_code          VARCHAR2(15);
l_line_curr_code           VARCHAR2(15);
l_request_header_id        NUMBER;
l_request_number           VARCHAR2(30);
l_agreement_number         VARCHAR2(240);
l_product_id               NUMBER;
l_uom_code                 VARCHAR2(3);
l_quantity                 NUMBER;
l_line_amount              NUMBER;
l_new_line_amount          NUMBER;
l_claim_amount             NUMBER;
l_claim_id                 NUMBER;
l_claim_rec                OZF_CLAIM_PVT.claim_rec_type;
l_line_tbl                 OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_cust_trade_profile       g_cust_trade_profile_csr%rowtype;
l_payment_method           VARCHAR2(30);
l_cust_billto_acct_site_id NUMBER;
l_vendor_id                NUMBER;
l_vendor_site_id           NUMBER;
l_claim_line_id            NUMBER;
l_party_name               VARCHAR2(360);
l_close_claim_flag         VARCHAR2(1);
l_partner_claim_num        VARCHAR2(30);
l_counter                  PLS_INTEGER := 1;
l_error_index              NUMBER;
l_scan_value               NUMBER;
l_offer_uom_code           VARCHAR2(3);
l_offer_quantity           NUMBER;
l_trans_curr_code          VARCHAR2(15);
l_new_claim_quantity       NUMBER;
l_exchange_rate_type       VARCHAR2(30) := FND_API.G_MISS_CHAR;
l_rate                     NUMBER;

--POS Batch Processing by profiles by ateotia (+)
l_ship_from_stock_flag     VARCHAR2(1);
l_offer_type               VARCHAR2(30);
--POS Batch Processing by profiles by ateotia (-)


CURSOR csr_resale_batch(cv_batch_id IN NUMBER) IS
  SELECT partner_cust_account_id
       , partner_id
       , currency_code
       , partner_claim_number
  FROM ozf_resale_batches
  WHERE resale_batch_id = cv_batch_id;

CURSOR csr_batch_line(cv_batch_id IN NUMBER, cv_partner_id IN NUMBER) IS
  SELECT r.request_header_id
       , r.request_number
      --POS Batch Processing by profiles by ateotia (+)
       , r.ship_from_stock_flag
       , r.offer_type
      --POS Batch Processing by profiles by ateotia (-)
       , s.agreement_name
       , s.inventory_item_id
       , s.uom_code
       , s.currency_code
       , sum(s.quantity)
       , sum(s.total_accepted_amount)

  FROM   ozf_resale_lines_int_all s,
         ozf_request_headers_all_b r
  WHERE  s.resale_batch_id = cv_batch_id
  AND    s.status_code = 'PROCESSED'
  AND    s.agreement_name = r.agreement_number
  AND    r.partner_id = cv_partner_id
  AND    r.status_code = 'APPROVED'
  AND    r.request_class = 'SPECIAL_PRICE'
  GROUP BY
         r.request_header_id
       , r.request_number
       , s.agreement_name
       , s.inventory_item_id
       , s.uom_code
       , s.currency_code
       , r.ship_from_stock_flag
       , r.offer_type  ;


-- added for Bugfix 5404951
CURSOR csr_ams_act_products(cv_agreement_number IN VARCHAR2 ,cv_product_id IN NUMBER) IS
  SELECT act.SCAN_VALUE
       , act.UOM_CODE
       , act.Quantity
       , off.TRANSACTION_CURRENCY_CODE
  FROM ozf_offers off
     , ams_act_products act
  WHERE offer_code  = cv_agreement_number
  AND   ARC_ACT_PRODUCT_USED_BY = 'OFFR'
  AND   ACT_PRODUCT_USED_BY_ID = off.qp_list_header_id
  AND   INVENTORY_ITEM_ID = cv_product_id;

CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_party_name(cv_cust_account_id IN NUMBER) IS
  SELECT p.party_name
  FROM hz_parties p
     , hz_cust_accounts c
  WHERE p.party_id = c.party_id
  AND   c.cust_account_id = cv_cust_account_id;

CURSOR c_get_conversion_type IS
  SELECT exchange_rate_type
  FROM   ozf_sys_parameters_all
  WHERE  org_id = MO_GLOBAL.GET_CURRENT_ORG_ID;

   --POS Batch Processing by profiles by rsatyava (+)
  l_auto_claim_profile varchar2(1):= FND_PROFILE.value('OZF_AUTO_CLAIM_POS');
  --POS Batch Processing by profiles by rsatyava (+)


BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_Per_Batch;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- Process batch ----------------
  OPEN csr_resale_batch(p_resale_batch_id);
  FETCH csr_resale_batch INTO l_cust_account_id
                            , l_partner_id
                            , l_claim_curr_code
                            , l_partner_claim_num;
  CLOSE csr_resale_batch;

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('Process batch for customer id '||l_cust_account_id);
  END IF;

  l_close_claim_flag := 'T';

  -- get payment method information from trade profile
  Get_Cust_Trade_Profile(
      p_cust_account_id     => l_cust_account_id
     ,x_cust_trade_profile  => l_cust_trade_profile
  );

  IF l_cust_trade_profile.trade_profile_id IS NOT NULL THEN
     Validate_Cust_Trade_Profile(
        p_cust_trade_profile  => l_cust_trade_profile
       ,x_return_status       => l_return_status
     );

     -- do not settle claim if trade profile has errors
     IF l_return_status = FND_API.g_ret_sts_error or
        l_return_status = FND_API.g_ret_sts_unexp_error THEN
        l_close_claim_flag := 'F';
     END IF;

     l_payment_method := l_cust_trade_profile.payment_method;
     l_cust_billto_acct_site_id := l_cust_trade_profile.site_use_id;
     l_vendor_id := l_cust_trade_profile.vendor_id;
     l_vendor_site_id := l_cust_trade_profile.vendor_site_id;
  ELSE
     -- do not settle claim if trade profile does not exists
     l_close_claim_flag := 'F';
  END IF;

  l_claim_amount := 0;
  l_counter := 1;

  --Added for 7360703
  IF l_line_tbl.EXISTS(1) THEN
     l_line_tbl.DELETE;
  END IF;

  OPEN csr_batch_line(p_resale_batch_id, l_partner_id);
  LOOP
     FETCH csr_batch_line INTO l_request_header_id
                             , l_request_number
                             --POS Batch Processing by profiles by ateotia (+)
                             , l_ship_from_stock_flag
                             , l_offer_type
                             --POS Batch Processing by profiles by ateotia (-)
                             , l_agreement_number
                             , l_product_id
                             , l_uom_code
                             , l_line_curr_code
                             , l_quantity
                             , l_line_amount;


     EXIT WHEN csr_batch_line%NOTFOUND;

-- Added logic to create claim line only when the auto claim profile is set/offer type is scan data
  IF(l_auto_claim_profile = 'Y') OR (l_offer_type='SCAN_DATA') THEN
     OPEN csr_ams_act_products(l_agreement_number ,l_product_id );
     FETCH csr_ams_act_products INTO l_scan_value
                                   , l_offer_uom_code
                                   , l_offer_quantity
                                   , l_trans_curr_code;
     CLOSE csr_ams_act_products;

     -- calculate claim amount
     IF l_line_curr_code = l_claim_curr_code THEN
        l_new_line_amount := l_line_amount;
     ELSE
        --Added for bug 7030415, get exchange_rate type
        OPEN c_get_conversion_type;
        FETCH c_get_conversion_type INTO l_exchange_rate_type;
        CLOSE c_get_conversion_type;
        OZF_UTILITY_PVT.Convert_Currency(
             p_from_currency   => l_line_curr_code
            ,p_to_currency     => l_claim_curr_code
            ,p_conv_type       => l_exchange_rate_type
            ,p_conv_date       => SYSDATE
            ,p_from_amount     => l_line_amount
            ,x_return_status   => l_return_status
            ,x_to_amount       => l_new_line_amount
            ,x_rate            => l_rate);
        IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;
     END IF;
     l_claim_amount := l_claim_amount + l_new_line_amount;

     -- Bugfix 5404951
     IF l_offer_uom_code <> l_uom_code THEN
             --POS Batch Processing by profiles by ateotia (+)
        IF (l_ship_from_stock_flag = 'Y' AND l_offer_type = 'ACCRUAL') THEN
           l_new_claim_quantity := l_quantity;
        ELSE
        l_new_claim_quantity := (l_line_amount * l_offer_quantity) / l_scan_value ; -- correct qty in offer_uom
        END IF;
        --POS Batch Processing by profiles by ateotia (-)

        -- convert this to claim line uom
        l_quantity := inv_convert.inv_um_convert(
                                item_id         => l_product_id
                               ,precision       => 2
                               ,from_quantity   => l_new_claim_quantity
                               ,from_unit       => l_offer_uom_code
                               ,to_unit         => l_uom_code
                               ,from_name       => NULL
                               ,to_name         => NULL
                               );
         IF l_quantity = -99999 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;

     ELSE
        -- the uom is same, only need to recalculate the correct quantity
        --POS Batch Processing by profiles by ateotia (+)
        IF (l_ship_from_stock_flag = 'Y' AND l_offer_type = 'SCAN_DATA') THEN
           l_quantity := (l_line_amount * l_offer_quantity) / l_scan_value;
           l_quantity := ROUND(l_quantity,2);
        END IF;
        --POS Batch Processing by profiles by ateotia (-)

     END IF;

     l_line_tbl(l_counter).activity_type             := 'SPECIAL_PRICE';
     l_line_tbl(l_counter).activity_id               := l_request_header_id;
     l_line_tbl(l_counter).item_type                 := 'PRODUCT';
     l_line_tbl(l_counter).item_id                   := l_product_id;
     l_line_tbl(l_counter).quantity_uom              := l_uom_code;
     l_line_tbl(l_counter).quantity                  := l_quantity;
     l_line_tbl(l_counter).currency_code             := l_line_curr_code;
     l_line_tbl(l_counter).amount                    := l_line_amount;
     l_line_tbl(l_counter).claim_currency_amount     := l_new_line_amount;

     l_counter := l_counter + 1;
       END IF;
  END LOOP;
  CLOSE csr_batch_line;

  -- create claim
  l_claim_rec.cust_account_id       := l_cust_account_id;
  l_claim_rec.source_object_class   := 'SPECIAL_PRICE';
  l_claim_rec.source_object_id      := NULL;
  l_claim_rec.source_object_number  := NULL;
  l_claim_rec.batch_id              := p_resale_batch_id;
  l_claim_rec.batch_type            := OZF_Resale_Common_PVT.G_BATCH_REF_TYPE;
  l_claim_rec.currency_code         := l_claim_curr_code;
  l_claim_rec.amount                := l_claim_amount;
  l_claim_rec.payment_method        := l_payment_method;
  --bug # 6690147 julou FP 6276634(+)
  --For -ve claim the settlement method defined in trade profile is not valid.
  --So, hard coded to DEBIT_MEMO.
  IF l_claim_rec.amount < 0 AND l_payment_method IS NOT NULL AND l_payment_method <> FND_API.G_MISS_CHAR THEN
     l_claim_rec.payment_method := 'DEBIT_MEMO';
  END IF;
  --bug # 6690147 (-)
  l_claim_rec.cust_billto_acct_site_id := l_cust_billto_acct_site_id;
  l_claim_rec.vendor_id             := l_vendor_id;
  l_claim_rec.vendor_site_id        := l_vendor_site_id;
  l_claim_rec.status_code           := 'OPEN';
  l_claim_rec.user_status_id        := to_number(
                                          ozf_utility_pvt.get_default_user_status(
                                             p_status_type   => 'OZF_CLAIM_STATUS',
                                             p_status_code   => l_claim_rec.status_code));
  -- save batch's partner claim number as customer reference
  l_claim_rec.customer_ref_number   := l_partner_claim_num;

  OZF_CLAIM_PVT.Create_Claim(
       p_api_version            => l_api_version
      ,x_return_status          => l_return_status
      ,x_msg_data               => x_msg_data
      ,x_msg_count              => x_msg_count
      ,p_claim                  => l_claim_rec
      ,x_claim_id               => l_claim_id);
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('Created claim id:'||l_claim_id);
  END IF;

  FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST LOOP
     IF l_line_tbl.exists(i) IS NOT NULL THEN
        l_line_tbl(i).claim_id := l_claim_id;
     END IF;
  END LOOP;

  OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
       p_api_version       => 1.0
      ,p_init_msg_list     => FND_API.g_false
      ,p_commit            => FND_API.g_false
      ,p_validation_level  => FND_API.g_valid_level_full
      ,x_return_status     => l_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_claim_line_tbl    => l_line_tbl
      ,x_error_index       => l_error_index);
  IF l_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_error;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('Claim lines created for claim_id=' || l_claim_id);
  END IF;

  OPEN csr_claim_line(l_claim_id);
  LOOP
     FETCH csr_claim_line INTO l_claim_line_id;
     EXIT WHEN csr_claim_line%NOTFOUND;

     Asso_Accruals_To_Claim_Line(
         p_api_version         => 1.0
        ,p_init_msg_list       => FND_API.g_false
        ,p_commit              => FND_API.g_false
        ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status       => l_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        ,p_claim_line_id       => l_claim_line_id);
     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
     END IF;
  END LOOP;
  CLOSE csr_claim_line;

  IF l_close_claim_flag = 'T' THEN
     Settle_Claim(
         p_claim_id            => l_claim_id
        ,x_return_status       => l_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data);
     IF l_return_status =  fnd_api.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  ------------------------- finish -------------------------------
  IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
  END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Create_Claim_Per_Batch;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_Per_Batch;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_Per_Batch;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_Per_Batch;

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Batch_Payment
--
-- PURPOSE
--    Create claim for ship and debit batch based on
--    'OZF: Consolidate Ship and Debit Claim' profile.
--
-- PARAMETERS
--    p_resale_batch_id: resale batch id
--
-- NOTES
--
-- HISTORY
-- 03-Jun-09  ateotia  Bug# 8571085 fixed.
---------------------------------------------------------------------
PROCEDURE Initiate_Batch_Payment(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_resale_batch_id   IN  NUMBER
)
IS
l_api_version    CONSTANT  NUMBER       := 1.0;
l_api_name       CONSTANT  VARCHAR2(30) := 'Initiate_Batch_Payment';
l_full_name      CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status            VARCHAR2(1);
l_consolidate_flag         VARCHAR2(1);

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Initiate_Batch_Payment;

  IF OZF_DEBUG_HIGH_ON THEN
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

  ----------------- Process batch ----------------
  l_consolidate_flag  := FND_PROFILE.VALUE('OZF_CONSOLIDATE_SHIP_DEBIT_CLAIM');
  IF NVL(l_consolidate_flag,'N') = 'N' THEN
     Create_Claim_Per_SPR(
         p_api_version      => 1.0
        ,p_init_msg_list    => FND_API.g_false
        ,p_commit           => FND_API.g_false
        ,p_validation_level => FND_API.g_valid_level_full
        ,x_return_status    => l_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_resale_batch_id  => p_resale_batch_id
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  ELSIF NVL(l_consolidate_flag,'N') = 'Y' THEN
     Create_Claim_Per_Batch(
         p_api_version      => 1.0
        ,p_init_msg_list    => FND_API.g_false
        ,p_commit           => FND_API.g_false
        ,p_validation_level => FND_API.g_valid_level_full
        ,x_return_status    => l_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data         => x_msg_data
        ,p_resale_batch_id  => p_resale_batch_id
      );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END IF;
  --------------------- finish -------------------
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
    ROLLBACK TO Initiate_Batch_Payment;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Initiate_Batch_Payment;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Initiate_Batch_Payment;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Initiate_Batch_Payment;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Over_Utilization
--
-- HISTORY
--    10/15/2002  yizhang  Create.
---------------------------------------------------------------------
PROCEDURE Validate_Over_Utilization(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
  ,p_currency_rec       IN  currency_rec_type
  ,p_funds_util_flt     IN  funds_util_flt_type
  ,p_over_paid_amount   IN  NUMBER --nepanda : fix for bug # 9508390  - issue # 3
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Over_Utilization';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_adjustment_flag    VARCHAR2(1);
l_count_workflow     NUMBER;

l_un_earned_pay_allow_to     VARCHAR2(30);
l_un_earned_pay_thold_type   VARCHAR2(30);
l_un_earned_pay_thold_amount NUMBER;
l_un_earned_pay_thold_flag   VARCHAR2(1);
l_threshold_amount           NUMBER;
l_over_paid_amount           NUMBER;
l_trd_prf_exist              BOOLEAN;
l_total_amt_earned           NUMBER;
l_total_amt_remaining        NUMBER;
l_currOrgId                  NUMBER     := MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_auto_adjust(cv_activity_product_id IN NUMBER) IS
  SELECT adjustment_flag
  FROM ams_act_products
  WHERE activity_product_id = cv_activity_product_id;

CURSOR csr_count_workflow(cv_claim_line_id IN NUMBER) IS
  SELECT count(*)
  FROM ozf_claim_lines_util lu, ams_act_products ap
      ,ozf_claim_lines cln1, ozf_claim_lines cln2
  WHERE cln1.claim_line_id = cv_claim_line_id
  AND   cln1.claim_id = cln2.claim_id
  AND   lu.claim_line_id = cln2.claim_line_id
  AND   lu.activity_product_id = ap.activity_product_id
  AND   lu.utilization_id = -1
  AND   ap.adjustment_flag = 'N';

CURSOR csr_cust_pay_unearned(cv_cust_account_id IN NUMBER) IS
  SELECT tp.un_earned_pay_allow_to, tp.un_earned_pay_thold_type
       , tp.un_earned_pay_thold_amount, tp.un_earned_pay_thold_flag
  FROM ozf_cust_trd_prfls tp
  WHERE tp.cust_account_id = cv_cust_account_id;

CURSOR csr_party_pay_unearned(cv_cust_account_id IN NUMBER) IS
  SELECT tp.un_earned_pay_allow_to, tp.un_earned_pay_thold_type
       , tp.un_earned_pay_thold_amount, tp.un_earned_pay_thold_flag
  FROM ozf_cust_trd_prfls tp, hz_cust_accounts hca
  WHERE tp.party_id = hca.party_id
  AND   tp.cust_account_id IS NULL
  AND   hca.cust_account_id = cv_cust_account_id;

 -- fix for bug 5042046
CURSOR csr_sys_pay_unearned IS
  SELECT un_earned_pay_allow_to, un_earned_pay_thold_type
       , un_earned_pay_thold_amount, un_earned_pay_thold_flag
  FROM ozf_sys_parameters
  WHERE  org_id = l_currOrgId;

CURSOR csr_earnings(cv_cust_account_id IN NUMBER, cv_plan_id IN NUMBER) IS
  SELECT SUM(DECODE(p_currency_rec.association_currency_code,p_currency_rec.transaction_currency_code, plan_curr_amount,acctd_amount))
       , SUM(DECODE(p_currency_rec.association_currency_code,p_currency_rec.transaction_currency_code, plan_curr_amount_remaining,acctd_amount_remaining))
  FROM ozf_funds_utilized_all_b
  WHERE utilization_type IN ('ACCRUAL', 'ADJUSTMENT')
  AND org_id =l_currOrgId
  AND plan_type = 'OFFR'
  AND plan_id = cv_plan_id
  AND cust_account_id = cv_cust_account_id;


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
       p_api_version,
       l_api_name,
       g_pkg_name
  ) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;

  ----------------------- validate ----------------------
  -- Scan Data over-utilization is configured in offer line
  IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
    -- Check if auto-adjustment is set
    OPEN csr_auto_adjust(p_funds_util_flt.activity_product_id);
    FETCH csr_auto_adjust INTO l_adjustment_flag;
    CLOSE csr_auto_adjust;

    IF l_adjustment_flag = 'N' THEN
      -- As of 15-JAN-2003, adjustment workflow is not supported. An error is raised
      -- if the offer is not auto-adjustable.
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_ADJUST_SCANUNIT');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;

      /*
      -- Adjustment workflow can be invoked only when profile is set
      IF NVL(fnd_profile.value('OZF_CLAIM_SCAN_ADJUST_WORKFLOW'),'N') <> 'Y' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_NO_ADJUST_WORKFLOW');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;

      -- At most one workflow can be invoked per claim
      OPEN csr_count_workflow(p_funds_util_flt.claim_line_id);
      FETCH csr_count_workflow INTO l_count_workflow;
      CLOSE csr_count_workflow;

      IF l_count_workflow > 0 THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MULTI_ADJ_WORKFLOW');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
      */
    END IF;
  ELSE
    -- non-scandata offers:
    -- offer must be specified for pay over earnings
    IF p_funds_util_flt.activity_id IS NULL OR
       p_funds_util_flt.activity_type IS NULL OR
       p_funds_util_flt.activity_type <> 'OFFR'
    THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_EARN_OVERPAY_NO_OFFER');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;

    --eligibility is in trade profile or system parameter
    l_trd_prf_exist := FALSE;

    IF p_funds_util_flt.cust_account_id IS NOT NULL THEN
      -- first check cust account's trade profile
      OPEN csr_cust_pay_unearned(p_funds_util_flt.cust_account_id);
      FETCH csr_cust_pay_unearned INTO l_un_earned_pay_allow_to
                                     , l_un_earned_pay_thold_type
                                     , l_un_earned_pay_thold_amount
                                     , l_un_earned_pay_thold_flag;
      IF NOT csr_cust_pay_unearned%NOTFOUND THEN
        l_trd_prf_exist := TRUE;
      END IF;
      CLOSE csr_cust_pay_unearned;

      -- if account has no trade profile, check party's trade profile
      IF NOT l_trd_prf_exist THEN
        OPEN csr_party_pay_unearned(p_funds_util_flt.cust_account_id);
        FETCH csr_party_pay_unearned INTO l_un_earned_pay_allow_to
                                        , l_un_earned_pay_thold_type
                                        , l_un_earned_pay_thold_amount
                                        , l_un_earned_pay_thold_flag;
        IF NOT csr_party_pay_unearned%NOTFOUND THEN
          l_trd_prf_exist := TRUE;
        END IF;
        CLOSE csr_party_pay_unearned;
      END IF;

      IF l_un_earned_pay_allow_to = 'DISALLOW' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_EARN_OVERPAY_NOT_ALLOWED');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;

    -- if no trade profile exists for the party, check sys parameters
    IF l_un_earned_pay_allow_to IS NULL THEN
      OPEN csr_sys_pay_unearned;
      FETCH csr_sys_pay_unearned INTO l_un_earned_pay_allow_to
                                    , l_un_earned_pay_thold_type
                                    , l_un_earned_pay_thold_amount
                                    , l_un_earned_pay_thold_flag;
      CLOSE csr_sys_pay_unearned;

      IF l_un_earned_pay_allow_to IS NULL OR
         l_un_earned_pay_allow_to = 'ALLOW_SELECTED'
      THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_EARN_OVERPAY_NOT_ALLOWED');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;

    IF l_un_earned_pay_thold_type IS NULL OR
       l_un_earned_pay_thold_type <> 'UNCONDITIONAL'
    THEN
      OPEN csr_earnings(p_funds_util_flt.cust_account_id, p_funds_util_flt.activity_id);
      FETCH csr_earnings INTO l_total_amt_earned, l_total_amt_remaining;
      CLOSE csr_earnings;

      IF l_un_earned_pay_thold_type = 'PERCENT' THEN
        l_threshold_amount := l_un_earned_pay_thold_amount * l_total_amt_earned / 100.0;
      ELSIF l_un_earned_pay_thold_type = 'AMOUNT' THEN
        l_threshold_amount := l_un_earned_pay_thold_amount;
      ELSE
        l_threshold_amount := 0.0;
      END IF;

    -- Fix for Bug 8716894
    --nepanda : fix for bug # 9508390  - issue # 3
    l_over_paid_amount := p_over_paid_amount; --p_funds_util_flt.total_amount - l_total_amt_remaining;

    IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('l_over_paid_amount :' || l_over_paid_amount);
    END IF;

      IF l_over_paid_amount > l_threshold_amount THEN
        IF l_un_earned_pay_thold_flag IS NULL OR l_un_earned_pay_thold_flag <> 'T' THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_EARN_OVERPAY_OVER_THOLD');
            FND_MSG_PUB.add;
          END IF;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;
      END IF;
    END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('l_un_earned_pay_allow_to = '||l_un_earned_pay_allow_to);
    OZF_Utility_PVT.debug_message('l_un_earned_pay_thold_type = '||l_un_earned_pay_thold_type);
    OZF_Utility_PVT.debug_message('l_over_paid_amount = '||l_over_paid_amount);
    OZF_Utility_PVT.debug_message('l_threshold_amount = '||l_threshold_amount);
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': end');
  END IF;
END Validate_Over_Utilization;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Pay_Over_Adjustments
--
-- HISTORY
--    11/03/2009  psomyaju  Create.
--    10/06/2009  kpatro    Fix for Bug#8583847
---------------------------------------------------------------------

PROCEDURE Create_Pay_Over_Adjustments ( px_line_util_tbl         IN OUT NOCOPY line_util_tbl_type
                                      , p_funds_util_flt         funds_util_flt_type
                                      , p_tot_accrual_amt        NUMBER
                                      , p_pay_over_amount        NUMBER
                                      , p_prorate_earnings_flag  VARCHAR2
                                      , p_new_total_amount       NUMBER
                                      , p_currency_rec           IN currency_rec_type
                                      , x_return_status          OUT NOCOPY VARCHAR2
                                      , x_msg_data               OUT NOCOPY VARCHAR2
                                      , x_msg_count              OUT NOCOPY NUMBER
                                      ) IS

TYPE NumberTab   IS TABLE OF NUMBER;
TYPE Varchar2Tab IS TABLE OF VARCHAR2(30);

l_item_id     NumberTab;
l_fund_id     NumberTab;
l_accrued_amt NumberTab;
l_level_type  Varchar2Tab;

-- Bugfix 5059770
-- Bugfix 5191444
CURSOR csr_offer_products ( cv_offer_id           NUMBER
                          , cv_product_id         NUMBER
                          , cv_product_level_type VARCHAR2
                          , cv_cust_account_id    NUMBER
                          , cv_plan_currency_code VARCHAR2
                          ) IS
  SELECT  product_level_type
        , product_id
        , fund_id
        , SUM(amount)
  FROM  ozf_funds_utilized_all_b
  WHERE utilization_type = 'ACCRUAL'
    AND org_id = MO_GLOBAL.GET_CURRENT_ORG_ID()
    AND gl_posted_flag = 'Y'
    AND plan_type = 'OFFR'
    AND plan_id = cv_offer_id
    AND cust_account_id = cv_cust_account_id
    AND (cv_product_id IS NULL OR product_id = cv_product_id)
    AND (cv_product_level_type IS NULL OR product_level_type = cv_product_level_type)
    AND plan_currency_code = cv_plan_currency_code
  GROUP BY product_level_type,product_id,fund_id;

CURSOR csr_funds_util_info(cv_utilization_id IN NUMBER) IS
  SELECT product_id, product_level_type, fund_id
  FROM ozf_funds_utilized_all_b
  WHERE utilization_id = cv_utilization_id;

CURSOR csr_source_fund_tot ( cv_offer_id NUMBER ) IS
  SELECT  SUM(approved_original_amount)
  FROM    ozf_act_budgets a
  WHERE   transfer_type = 'REQUEST'
    AND   act_budget_used_by_id = cv_offer_id
    AND   EXISTS ( SELECT 1
                   FROM  ozf_funds_all_vl
                   WHERE fund_id = budget_source_id
                   AND   CURRENCY_CODE_TC = a.approved_in_currency);

-- Bugfix 4493735
CURSOR csr_source_fund(cv_offer_id NUMBER) IS
  SELECT budget_source_id
       , approved_original_amount
       , count(*) over () total_funds
  FROM   ozf_act_budgets a
  WHERE  transfer_type = 'REQUEST'
    AND  act_budget_used_by_id = cv_offer_id
    AND  EXISTS ( SELECT 1
                   FROM  ozf_funds_all_vl
                   WHERE fund_id = budget_source_id
                   AND   currency_code_tc = a.approved_in_currency);

l_adj_util_id             NUMBER := 0;
l_prorate_adj_amt         NUMBER := 0;
l_tot_accrual_amt         NUMBER := 0;
l_fund_tot_amount         NUMBER := 0;
l_tot_prorate_adj_amt     NUMBER := 0;
l_util_product_id         NUMBER := 0;
l_util_fund_id            NUMBER := 0;
l_util_product_level_type VARCHAR2(15);
l_tot_amt_rem             NUMBER := 0;
l_last_asso_index         NUMBER := 0;
i                         NUMBER := 0;
j                         NUMBER := 0;

l_api_version   CONSTANT  NUMBER       := 1.0;
l_api_name      CONSTANT  VARCHAR2(30) := 'Create_Pay_Over_Adjustments';
l_full_name     CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status           VARCHAR2(15);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(15);

l_new_line_amount NUMBER := p_new_total_amount;

BEGIN


  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  SAVEPOINT Create_Pay_Over_Adjustments;

  /*
  Adjustments Creation:
  For Scan Data offer, single adjustment should be created for entire pay over amount, since prorate is not applicable
  to Scan Data offers.
  If prorate flag is set and its NOT total pay over earnings case, then create adjustments on prorate basis, i.e.
  pay over amount must be distributed uniformly across utilizations based on total amount remaining of all qualified
  utilizations w.r.t. association amount for each utilization.
  If prorate flag is set and its total pay over earnings case, then entire pay over amount will be consider as pay over
  earnings amount. Identify all the utilizations on the basis of customer, offer and product combination and calculate
  adjustment amount such that entire pay over amount should be distribute uniformly among all the qualified utilzations
  w.r.t. each utilization amount.
  If prorate flag is not set, then calculate adjustment amount such that pay over amount should be distributed uniformly
  among all the funds associate with offer. If single fund associated with offer then single adjustment should be created
  for entire pay over amount.
  */


   l_new_line_amount := NVL (l_new_line_amount,0);

  j := px_line_util_tbl.COUNT + 1;
  l_last_asso_index := px_line_util_tbl.LAST;

  IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
    IF px_line_util_tbl.COUNT > 0 THEN
      px_line_util_tbl(j).utilization_id := -1;
      px_line_util_tbl(j).amount  := p_pay_over_amount;
      px_line_util_tbl(j).scan_unit := p_funds_util_flt.total_units;
      px_line_util_tbl(j).claim_line_id := p_funds_util_flt.claim_line_id;
      px_line_util_tbl(j).activity_product_id := p_funds_util_flt.activity_product_id;
      px_line_util_tbl(j).uom_code := p_funds_util_flt.uom_code;
      px_line_util_tbl(j).quantity := p_funds_util_flt.quantity;
      px_line_util_tbl(j).update_from_tbl_flag := FND_API.g_true;
    END IF;
  ELSE
  IF p_prorate_earnings_flag = 'T' THEN
    IF px_line_util_tbl.COUNT > 0 THEN
      FOR i IN px_line_util_tbl.FIRST..px_line_util_tbl.LAST
      LOOP

          --Fix for Bug 8583847
          IF SIGN(px_line_util_tbl(i).amount) = SIGN(NVL (l_new_line_amount,0)) THEN
           l_prorate_adj_amt := px_line_util_tbl(i).amount * (l_new_line_amount / p_tot_accrual_amt);
           l_prorate_adj_amt := OZF_UTILITY_PVT.CurrRound(l_prorate_adj_amt, p_currency_rec.association_currency_code);


                  OPEN  csr_funds_util_info(px_line_util_tbl(i).utilization_id);
                  FETCH csr_funds_util_info INTO l_util_product_id
                                               , l_util_product_level_type
                                               , l_util_fund_id;
                  CLOSE csr_funds_util_info;

          IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('px_line_util_tbl(i).amount = '||px_line_util_tbl(i).amount);
            OZF_Utility_PVT.debug_message('p_pay_over_amount = '||p_pay_over_amount);
            OZF_Utility_PVT.debug_message('p_tot_accrual_amt = '||p_tot_accrual_amt);
            OZF_Utility_PVT.debug_message('l_prorate_adj_amt = '||l_prorate_adj_amt);
            OZF_Utility_PVT.debug_message('l_util_product_id = '||l_util_product_id);
            OZF_Utility_PVT.debug_message('l_util_product_level_type = '||l_util_product_level_type);
            OZF_Utility_PVT.debug_message('l_util_fund_id = '||l_util_fund_id);
          END IF;

          Create_Fund_Adjustment ( p_offer_id             => p_funds_util_flt.activity_id
                                 , p_cust_account_id      => p_funds_util_flt.cust_account_id
                                 , p_product_id           => l_util_product_id
                                 , p_product_level_type   => l_util_product_level_type
                                 , p_fund_id              => l_util_fund_id
                                 , p_reference_type       => p_funds_util_flt.reference_type
                                 , p_reference_id         => p_funds_util_flt.reference_id
                                 , x_return_status        => l_return_status
                                 , x_msg_count            => l_msg_count
                                 , x_msg_data             => l_msg_data
                                 , x_adj_util_id          => l_adj_util_id
                                 );

          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_error;
          END IF;

          IF i = l_last_asso_index THEN
            --Fix for Bug 8583847
            px_line_util_tbl(j).amount := l_new_line_amount - l_tot_prorate_adj_amt;
          ELSE
            px_line_util_tbl(j).amount := l_prorate_adj_amt;
          END IF;

          l_tot_prorate_adj_amt := NVL(l_tot_prorate_adj_amt,0) + l_prorate_adj_amt;

          IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Prorate Partial Pay Over Earnings Adjustments ...');
            OZF_Utility_PVT.debug_message('Utilization_Id = '||px_line_util_tbl(j).utilization_id);
            OZF_Utility_PVT.debug_message('Claim_Line_Id = '||px_line_util_tbl(j).claim_line_id);
            OZF_Utility_PVT.debug_message('Adjustment Amount = '||px_line_util_tbl(j).amount);
            OZF_Utility_PVT.debug_message('l_tot_prorate_adj_amt = '||l_tot_prorate_adj_amt);
          END IF;

          px_line_util_tbl(j).amount := OZF_UTILITY_PVT.CurrRound(px_line_util_tbl(j).amount, p_currency_rec.association_currency_code);
          px_line_util_tbl(j).utilization_id := l_adj_util_id;
          px_line_util_tbl(j).claim_line_id  := p_funds_util_flt.claim_line_id;
          px_line_util_tbl(j).update_from_tbl_flag := FND_API.g_true;

        END IF;
        j := j + 1;
      END LOOP;
    ELSE  -- px_line_util_tbl.COUNT = 0
      OPEN csr_offer_products ( p_funds_util_flt.activity_id
                              , NVL(p_funds_util_flt.activity_product_id,p_funds_util_flt.product_id)
                              , p_funds_util_flt.product_level_type
                              , p_funds_util_flt.cust_account_id
                              , p_currency_rec.transaction_currency_code
                              );
      FETCH csr_offer_products BULK COLLECT INTO l_level_type
                                               , l_item_id
                                               , l_fund_id
                                               , l_accrued_amt;
      CLOSE csr_offer_products;

      FOR i IN l_level_type.FIRST..l_level_type.LAST
      LOOP
        l_tot_accrual_amt := NVL(l_tot_accrual_amt,0) + l_accrued_amt(i);
      END LOOP;


      FOR i IN l_level_type.FIRST..l_level_type.LAST
      LOOP

        --Fix for Bug 8583847
        --l_tot_accrual_amt := NVL(l_tot_accrual_amt,0) + l_accrued_amt(i);

        --Fix for Bug 8583847
        l_prorate_adj_amt := l_accrued_amt(i) * (l_new_line_amount / l_tot_accrual_amt);
        l_prorate_adj_amt := OZF_UTILITY_PVT.CurrRound(l_prorate_adj_amt, p_currency_rec.association_currency_code);

        l_tot_prorate_adj_amt := NVL(l_tot_prorate_adj_amt,0) + l_prorate_adj_amt ;

          Create_Fund_Adjustment ( p_offer_id               => p_funds_util_flt.activity_id
                               , p_cust_account_id        => p_funds_util_flt.cust_account_id
                               , p_product_id             => l_item_id(i)
                               , p_product_level_type     => l_level_type(i)
                               , p_fund_id                => l_fund_id(i)
                               , p_reference_type         => p_funds_util_flt.reference_type
                               , p_reference_id           => p_funds_util_flt.reference_id
                               , x_return_status          => l_return_status
                               , x_msg_count              => l_msg_count
                               , x_msg_data               => l_msg_data
                               , x_adj_util_id            => l_adj_util_id
                              );

                IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
                ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_error;
                END IF;

        IF i = l_level_type.LAST THEN
             px_line_util_tbl(j).amount := l_prorate_adj_amt;
        ELSE
          --Fix for Bug 8583847
          px_line_util_tbl(j).amount := px_line_util_tbl(j).amount + (l_new_line_amount - l_tot_prorate_adj_amt);

        END IF;

        px_line_util_tbl(j).amount := OZF_UTILITY_PVT.CurrRound(px_line_util_tbl(j).amount, p_currency_rec.association_currency_code);
        px_line_util_tbl(j).utilization_id := l_adj_util_id;
        px_line_util_tbl(j).claim_line_id  := p_funds_util_flt.claim_line_id;
        px_line_util_tbl(j).update_from_tbl_flag := FND_API.g_true;

        IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('Prorate Total Pay Over Earnings Adjustments ...');
          OZF_Utility_PVT.debug_message('Utilization_Id = '||px_line_util_tbl(j).utilization_id);
          OZF_Utility_PVT.debug_message('Claim_Line_Id = '||px_line_util_tbl(j).claim_line_id);
          OZF_Utility_PVT.debug_message('Adjustment Amount = '||px_line_util_tbl(j).amount);
        END IF;
        j := j + 1;
      END LOOP;
    END IF;
  ELSE --p_prorate_earnings_flag = 'F'

    OPEN  csr_source_fund_tot(p_funds_util_flt.activity_id);
    FETCH csr_source_fund_tot INTO l_fund_tot_amount;
    CLOSE csr_source_fund_tot;

    FOR r_source_fund IN csr_source_fund(p_funds_util_flt.activity_id)
    LOOP
      Create_Fund_Adjustment ( p_offer_id            => p_funds_util_flt.activity_id
                             , p_cust_account_id     => p_funds_util_flt.cust_account_id
                             , p_product_id          => NULL
                             , p_product_level_type  => NULL
                             , p_fund_id             => r_source_fund.budget_source_id
                             , p_reference_type      => p_funds_util_flt.reference_type
                             , p_reference_id        => p_funds_util_flt.reference_id
                             , x_return_status       => l_return_status
                             , x_msg_count           => l_msg_count
                             , x_msg_data            => l_msg_data
                             , x_adj_util_id         => l_adj_util_id
                             );

      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
      END IF;

      IF csr_source_fund%ROWCOUNT = r_source_fund.total_funds THEN
        px_line_util_tbl(j).amount := p_pay_over_amount - l_tot_amt_rem;
      ELSE
        IF l_fund_tot_amount = 0 THEN
          px_line_util_tbl(j).amount := p_pay_over_amount;
        ELSE
          px_line_util_tbl(j).amount := p_pay_over_amount * (r_source_fund.approved_original_amount/l_fund_tot_amount);
          l_tot_amt_rem := l_tot_amt_rem + px_line_util_tbl(j).amount;
        END IF;
      END IF;

      px_line_util_tbl(j).amount := OZF_UTILITY_PVT.CurrRound(px_line_util_tbl(j).amount, p_currency_rec.association_currency_code);
      px_line_util_tbl(j).utilization_id := l_adj_util_id;
      px_line_util_tbl(j).claim_line_id  := p_funds_util_flt.claim_line_id;
      px_line_util_tbl(j).update_from_tbl_flag := FND_API.g_true;

      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Non-Prorate Pay Over Earnings Adjustments ...');
        OZF_Utility_PVT.debug_message('Utilization_Id = '||px_line_util_tbl(j).utilization_id);
        OZF_Utility_PVT.debug_message('Claim_Line_Id = '||px_line_util_tbl(j).claim_line_id);
        OZF_Utility_PVT.debug_message('Adjustment Amount = '||px_line_util_tbl(j).amount);
      END IF;
      j := j + 1;
    END LOOP;
  END IF;  --p_prorate_earnings_flag
  END IF;  --SCAN_DATA check

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Create_Pay_Over_Adjustments;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Pay_Over_Adjustments;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Pay_Over_Adjustments;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Pay_Over_Adjustments;

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_Line_Util_Tbl
--
-- HISTORY
--    11-Mar-2009  psomyaju  Create.
--    10-Jun-2009  kpatro   Fix for Bug 8583847
---------------------------------------------------------------------
PROCEDURE Populate_Line_Util_Tbl ( p_funds_util_flt         funds_util_flt_type
                                 , p_source_object_class    IN VARCHAR2
                                 , p_source_object_id       IN NUMBER
                                 , p_request_header_id      IN NUMBER
                                 , p_batch_line_id          IN NUMBER
                                 , p_batch_type             IN VARCHAR2
                                 , p_summary_view           IN VARCHAR2
                                 , p_cre_util_amount        IN NUMBER
                                 , p_prorate_earnings_flag  IN VARCHAR2
                                 , p_currency_rec           IN currency_rec_type
                                 , x_funds_rem_tbl          OUT NOCOPY funds_rem_tbl_type
                                 , x_tot_accrual_amt        OUT NOCOPY NUMBER
                                 , x_line_amount            OUT NOCOPY NUMBER
                                 , x_line_util_tbl          OUT NOCOPY line_util_tbl_type
                                 , x_return_status          OUT NOCOPY VARCHAR2
                                 , x_msg_data               OUT NOCOPY VARCHAR2
                                 , x_msg_count              OUT NOCOPY NUMBER
                                 ) IS

l_funds_util_csr        NUMBER;
l_funds_util_sql        VARCHAR2(3000);
l_total_pay_over_flag   BOOLEAN := FALSE;
l_util_id               NUMBER  := 0;
l_fu_amt_rem            NUMBER  := 0;
l_total_amt_rem         NUMBER  := 0;
l_tot_accrual_amt       NUMBER  := 0;
l_total_prorate_amount  NUMBER  := 0;
l_prorate_amount        NUMBER  := 0;
l_fu_scan_unit_rem      NUMBER  := 0;
l_total_scan_unit_rem   NUMBER  := 0;
l_fu_currency_code      VARCHAR2(15);
l_util_uom_code         VARCHAR2(15);
l_util_quantity         NUMBER  := 0;
l_ignore                NUMBER  := 0;
l_funds_used_units      NUMBER  := 0;
j                       NUMBER  := 0;
l_exit                  BOOLEAN := FALSE;
l_line_rem_amount       NUMBER  := 0;
l_fu_exchange_rate      NUMBER  := 0;
l_fu_exc_rate_type      VARCHAR2(30);
l_fu_exc_rate_date      DATE;
l_conv_exchange_rate    NUMBER  := 0;
l_batch_curr_claim_amt  NUMBER  := 0;

l_api_version   CONSTANT  NUMBER       := 1.0;
l_api_name      CONSTANT  VARCHAR2(30) := 'Populate_Line_Util_Tbl';
l_full_name     CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status         VARCHAR2(15);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(15);

l_line_util_tbl         line_util_tbl_type;
l_funds_rem_tbl         funds_rem_tbl_type;
l_currency_rec          currency_rec_type := p_currency_rec;

-- Bugfix 4926327
-- Bugfix 5101106
CURSOR csr_funds_used_units(cv_activity_product_id IN NUMBER) IS
  SELECT NVL(SUM(scan_unit * amp.quantity ), 0)
  FROM   ozf_claim_lines_util lu,
         ozf_claims c,
         ozf_claim_lines cl,
         ams_act_products amp
  WHERE  lu.activity_product_id = cv_activity_product_id
  AND    cl.claim_line_id = lu.claim_line_id
  AND    cl.claim_id =  c.claim_id
  AND    c.status_code <> 'CLOSED'
  AND    lu.activity_product_id = amp.activity_product_id
  AND    lu.utilization_id <> -1;

/* ER 9226258
CURSOR csr_sd_accruals ( cv_batch_id          NUMBER
                       , cv_product_id        NUMBER
                       , cv_request_header_id NUMBER
                       , cv_batch_line_id     NUMBER
                       ) IS
 SELECT  util.utilization_id
       , line.batch_curr_claim_amount
       , offr.transaction_currency_code
 FROM    ozf_funds_utilized_all_b util
       , ozf_sd_batch_lines_all   line
       , ozf_offers offr
 WHERE   util.utilization_id = line.utilization_id
   AND   util.plan_id = offr.qp_list_header_id
   AND   line.batch_id = cv_batch_id
   AND   line.item_id = cv_product_id
   AND   util.reference_id = cv_request_header_id
   AND   line.batch_line_id = NVL(cv_batch_line_id,batch_line_id)
   AND   util.reference_type = 'SD_REQUEST'
   AND   line.batch_curr_claim_amount <> 0;
*/

CURSOR csr_sd_accruals ( cv_batch_id          NUMBER
                       , cv_product_id        NUMBER
                       , cv_request_header_id NUMBER
                       , cv_batch_line_id     NUMBER
                       ) IS
 SELECT  util.utilization_id
       , util.exchange_rate
       , util.exchange_rate_date
       , util.exchange_rate_type
       , line.batch_curr_claim_amount
 FROM    ozf_funds_utilized_all_b util
       , ozf_sd_batch_lines_all   line
 WHERE   util.utilization_id = line.utilization_id
   AND   line.batch_id = cv_batch_id
   AND   line.item_id = cv_product_id
   AND   util.reference_id = cv_request_header_id
   AND   line.batch_line_id = NVL(cv_batch_line_id,batch_line_id)
   AND   util.reference_type = 'SD_REQUEST'
   AND   line.batch_curr_claim_amount <> 0;
BEGIN

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

 -- Fix for Bug 8583847
 l_line_rem_amount := p_cre_util_amount;

 SAVEPOINT Populate_Line_Util_Tbl;

  --For Supplier Ship Debit claims, since we already know the utilizations during batch creation.
  --Hence, with batch lines, we can get the qualified utilizations directly.
  IF NVL(p_source_object_class,'X') = 'SD_SUPPLIER' THEN

  --//ER 9226258
    OPEN csr_sd_accruals ( p_source_object_id
                         , p_funds_util_flt.product_id
                         , p_request_header_id
                         , p_batch_line_id
                         );
    j := 0;
    LOOP
      FETCH csr_sd_accruals INTO l_util_id,l_fu_exchange_rate,l_fu_exc_rate_date,l_fu_exc_rate_type,l_batch_curr_claim_amt;
      EXIT WHEN csr_sd_accruals%NOTFOUND;

      x_line_util_tbl(j).utilization_id         := l_util_id;
      x_line_util_tbl(j).claim_line_id          := p_funds_util_flt.claim_line_id;
      x_line_util_tbl(j).activity_product_id    := p_funds_util_flt.activity_product_id;
      x_line_util_tbl(j).uom_code               := l_util_uom_code;
      x_line_util_tbl(j).update_from_tbl_flag   := FND_API.g_true;

      IF (l_currency_rec.transaction_currency_code = l_currency_rec.claim_currency_code) THEN
         x_line_util_tbl(j).amount := l_batch_curr_claim_amt;
      ELSE
         IF l_currency_rec.claim_currency_code <> l_currency_rec.functional_currency_code THEN
            OZF_UTILITY_PVT.Convert_Currency (
                        p_from_currency   => l_currency_rec.claim_currency_code
                      , p_to_currency     => l_currency_rec.functional_currency_code
                      , p_conv_type       => l_fu_exc_rate_type
                      , p_conv_rate       => l_fu_exchange_rate
                      , p_conv_date       => SYSDATE
                      , p_from_amount     => l_batch_curr_claim_amt
                      , x_return_status   => l_return_status
                      , x_to_amount       => x_line_util_tbl(j).amount
                      , x_rate            => l_conv_exchange_rate
            );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            x_line_util_tbl(j).amount := OZF_UTILITY_PVT.CurrRound( x_line_util_tbl(j).amount, l_currency_rec.functional_currency_code);

         ELSE
            x_line_util_tbl(j).amount := l_batch_curr_claim_amt;
         END IF;
      END IF;
      j := j + 1;
    END LOOP;
    CLOSE csr_sd_accruals;


    /*
    OPEN csr_sd_accruals ( p_source_object_id
                         , p_funds_util_flt.product_id
                         , p_request_header_id
                         , p_batch_line_id
                         );
    j := 0;
    LOOP
      FETCH csr_sd_accruals INTO l_util_id,l_fu_amt_rem,l_fu_currency_code;
      EXIT WHEN csr_sd_accruals%NOTFOUND;
      x_line_util_tbl(j).utilization_id := l_util_id;
      x_line_util_tbl(j).amount := OZF_UTILITY_PVT.CurrRound(l_fu_amt_rem, l_currency_rec.association_currency_code);
      x_line_util_tbl(j).claim_line_id := p_funds_util_flt.claim_line_id;
      x_line_util_tbl(j).activity_product_id := p_funds_util_flt.activity_product_id;
      x_line_util_tbl(j).uom_code := l_util_uom_code;
      x_line_util_tbl(j).update_from_tbl_flag := FND_API.g_true;
      j := j + 1;
    END LOOP;
    CLOSE csr_sd_accruals;
    */
  ELSE

    IF p_funds_util_flt.pay_over_all_flag IS NULL THEN
       l_total_pay_over_flag := FALSE;
    ELSE
       l_total_pay_over_flag := p_funds_util_flt.pay_over_all_flag;
    END IF;


    --Get all the qualified utilizations for current claim line association on the basis of
    --customer, offer and product. If pay over earnings is allowed, then no need to identify
    --utilizations. We will create adjustments for entire pay over earnings.
    --Bugfix 5144750
    IF NOT (l_total_pay_over_flag) THEN
      Get_Utiz_Sql_Stmt ( p_api_version         => 1.0
                        , p_init_msg_list       => FND_API.g_false
                        , p_commit              => FND_API.g_false
                        , p_validation_level    => FND_API.g_valid_level_full
                        , x_return_status       => l_return_status
                        , x_msg_count           => l_msg_count
                        , x_msg_data            => l_msg_data
                        , p_summary_view        => p_summary_view
                        , p_funds_util_flt      => p_funds_util_flt
                        , px_currency_rec        => l_currency_rec
                        , p_cust_account_id     => p_funds_util_flt.cust_account_id
                        , x_utiz_sql_stmt       => l_funds_util_sql
                        );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
      END IF;

      j := 0;
      l_funds_util_csr := DBMS_SQL.open_cursor;
      FND_DSQL.set_cursor(l_funds_util_csr);
      DBMS_SQL.parse(l_funds_util_csr, l_funds_util_sql, DBMS_SQL.native);
      DBMS_SQL.define_column(l_funds_util_csr, 1, l_util_id);
      DBMS_SQL.define_column(l_funds_util_csr, 2, l_fu_amt_rem);
      DBMS_SQL.define_column(l_funds_util_csr, 3, l_fu_scan_unit_rem);
      DBMS_SQL.define_column(l_funds_util_csr, 4, l_fu_currency_code, 15);
      FND_DSQL.do_binds;

      l_ignore := DBMS_SQL.execute(l_funds_util_csr);
      LOOP
        IF DBMS_SQL.fetch_rows(l_funds_util_csr) > 0 THEN
          DBMS_SQL.column_value(l_funds_util_csr, 1, l_util_id);
          DBMS_SQL.column_value(l_funds_util_csr, 2, l_fu_amt_rem);
          DBMS_SQL.column_value(l_funds_util_csr, 3, l_fu_scan_unit_rem);
          DBMS_SQL.column_value(l_funds_util_csr, 4, l_fu_currency_code);

          OPEN  csr_funds_used_units(p_funds_util_flt.activity_product_id);
          FETCH csr_funds_used_units INTO l_funds_used_units;
          CLOSE csr_funds_used_units;

          l_funds_rem_tbl(j).utilization_id := l_util_id;
          l_funds_rem_tbl(j).amount_remaining := l_fu_amt_rem;
          l_funds_rem_tbl(j).scan_unit_remaining := l_fu_scan_unit_rem - l_funds_used_units;
          l_total_amt_rem := l_total_amt_rem + l_fu_amt_rem;
          l_total_scan_unit_rem := l_total_scan_unit_rem + l_funds_rem_tbl(j).scan_unit_remaining;

          j := j + 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
      DBMS_SQL.close_cursor(l_funds_util_csr);

      --If total amount remaining for all the qualified adjustments is zero, then raise warning.
      --Raise error, if negative assocation is taking place for positive amount remaining.
      IF l_total_amt_rem = 0 AND
        NVL(p_funds_util_flt.offer_type,'X') NOT IN ('ACCRUAL','DEAL','LUMPSUM','NET_ACCRUAL','VOLUME_OFFER', 'SCAN_DATA') THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_EARN_AVAIL_AMT_ZERO');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      -- Bugfix 8198443
      ELSIF (p_cre_util_amount < 0 and l_total_amt_rem >0) AND p_batch_type <> 'BATCH' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_ASSO_NEG_AMT');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      /* Earnings Calculation:
      If prorate earnigns flag is set, then calculate earnings on prorate basis i.e. distribute association amount uniformly
      across qualified utilizations based on amount remaining of utilizations.
      Otherwise, earnings should be calculated in FIFO basis, i.e. in set of qualified utilizations, first utilization will
      consume association amount for its entire amount remaining value. Remaining amount will be used by next utilization in
      similar fashion and so on until either association amount exhaust or all utilizations processed. In this case, if association
      amount left after all utilizations process, this amount will be considered as pay over earnings and adjustment need to be
      created for this amount.
      */

      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_funds_rem_tbl.COUNT = '||l_funds_rem_tbl.COUNT);
        OZF_Utility_PVT.debug_message('p_cre_util_amount = '||p_cre_util_amount);
        OZF_Utility_PVT.debug_message('l_total_amt_rem = '||l_total_amt_rem);
        OZF_Utility_PVT.debug_message('p_prorate_earnings_flag = '||p_prorate_earnings_flag);
      END IF;

      -- Bugfix 6042226
      IF l_funds_rem_tbl.COUNT > 0 THEN
        IF l_funds_rem_tbl.COUNT > 1     AND
           p_prorate_earnings_flag = 'T' AND
           ABS(p_cre_util_amount) <= ABS(l_total_amt_rem)
        THEN

           FOR i IN l_funds_rem_tbl.FIRST..l_funds_rem_tbl.LAST
           LOOP

             IF i = l_funds_rem_tbl.LAST THEN
              -- Modified the logic for multiple lines - kpatro

                l_prorate_amount := l_funds_rem_tbl(i).amount_remaining * (p_cre_util_amount / l_total_amt_rem);
                l_prorate_amount := OZF_UTILITY_PVT.CurrRound(l_prorate_amount,l_currency_rec.association_currency_code);

               -- modified the condition to <> to account for either less or greater condition

                IF (l_total_prorate_amount + l_prorate_amount) <> p_cre_util_amount THEN
                     l_prorate_amount := p_cre_util_amount - l_total_prorate_amount;
                END IF;
                x_line_util_tbl(i).amount := l_prorate_amount;
             ELSE
                 l_prorate_amount := l_funds_rem_tbl(i).amount_remaining * (p_cre_util_amount / l_total_amt_rem);
                 x_line_util_tbl(i).amount := OZF_UTILITY_PVT.CurrRound(l_prorate_amount, l_currency_rec.association_currency_code);
             END IF;

             l_total_prorate_amount := l_total_prorate_amount + x_line_util_tbl(i).amount;

             -- commented the below code as it is calcualted above --by kpatro
             --x_line_util_tbl(i).amount := l_prorate_amount;
             x_line_util_tbl(i).utilization_id := l_funds_rem_tbl(i).utilization_id;
             x_line_util_tbl(i).claim_line_id := p_funds_util_flt.claim_line_id;
             x_line_util_tbl(i).activity_product_id := p_funds_util_flt.activity_product_id;
             x_line_util_tbl(i).uom_code := p_funds_util_flt.uom_code;
             x_line_util_tbl(i).quantity := p_funds_util_flt.quantity;
             x_line_util_tbl(i).update_from_tbl_flag := FND_API.g_true;
           END LOOP;
        ELSE
          -- Fix for Bug 8583847
          --l_line_rem_amount := p_cre_util_amount;
          FOR i IN l_funds_rem_tbl.FIRST..l_funds_rem_tbl.LAST
          LOOP
            l_fu_amt_rem := l_funds_rem_tbl(i).amount_remaining;
            IF ((SIGN(p_cre_util_amount) = -1 AND SIGN(l_total_amt_rem) = -1) AND
                (p_cre_util_amount > l_total_amt_rem)) OR
               ((SIGN(p_cre_util_amount) = 1 AND SIGN(l_total_amt_rem) = 1) AND
                (p_cre_util_amount < l_total_amt_rem))
            THEN
              IF l_line_rem_amount >= l_fu_amt_rem THEN
                x_line_util_tbl(i).amount := l_fu_amt_rem;
              ELSE
                x_line_util_tbl(i).amount := l_line_rem_amount;
              END IF;
            ELSE
              -- Bugfix 5404951
              IF (p_batch_type = 'BATCH' AND p_source_object_class = 'SPECIAL_PRICE' AND p_funds_util_flt.offer_type = 'SCAN_DATA') THEN
                x_line_util_tbl(i).amount := p_cre_util_amount;
                l_exit := TRUE;
              END IF;
              IF SIGN(p_cre_util_amount) = SIGN(l_fu_amt_rem) THEN
                 l_tot_accrual_amt  := NVL(l_tot_accrual_amt,0) + l_fu_amt_rem;
              END IF;
            END IF;

            --Last utilization amount rounding
            -- Fix for non prorate condition -- kpatro
            --IF ABS(l_line_rem_amount) >= ABS(l_fu_amt_rem) THEN
            IF l_line_rem_amount >= l_fu_amt_rem THEN  --nepanda : fix for bug # 9508390  - issue # 5
              x_line_util_tbl(i).amount := l_fu_amt_rem;
            ELSE
              x_line_util_tbl(i).amount := l_line_rem_amount;
            END IF;

            IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
               x_line_util_tbl(i).scan_unit := x_line_util_tbl(i).amount / G_SCAN_VALUE;
               x_line_util_tbl(i).quantity  := p_funds_util_flt.quantity;
            END IF;

            x_line_util_tbl(i).utilization_id           := l_funds_rem_tbl(i).utilization_id;
            x_line_util_tbl(i).claim_line_id            := p_funds_util_flt.claim_line_id;
            x_line_util_tbl(i).activity_product_id      := p_funds_util_flt.activity_product_id;
            x_line_util_tbl(i).uom_code                 := p_funds_util_flt.uom_code;
            x_line_util_tbl(i).update_from_tbl_flag     := FND_API.g_true;

            l_line_rem_amount := l_line_rem_amount - l_fu_amt_rem;
            IF l_line_rem_amount <= 0 THEN
              EXIT;
            END IF;
          END LOOP;
        END IF; --l_prorate_earnings_flag = 'T'
      END IF;   --l_funds_rem_tbl.COUNT > 0

      x_tot_accrual_amt := l_total_amt_rem;

    END IF;  --l_total_pay_over_flag = FALSE
  END IF;  --SD_SUPPLIER Check

  IF OZF_DEBUG_HIGH_ON THEN
    IF x_line_util_tbl.COUNT > 0 THEN
      FOR i IN x_line_util_tbl.FIRST..x_line_util_tbl.LAST
      LOOP
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').utilization_id = '||x_line_util_tbl(i).utilization_id);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').claim_line_id = '||x_line_util_tbl(i).claim_line_id);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').activity_product_id = '||x_line_util_tbl(i).activity_product_id);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').uom_code = '||x_line_util_tbl(i).uom_code);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').amount = '||x_line_util_tbl(i).amount);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').quantity = '||x_line_util_tbl(i).quantity);
        OZF_Utility_PVT.debug_message('x_line_util_tbl('||i||').scan_unit = '||x_line_util_tbl(i).scan_unit);
      END LOOP;
    END IF;
  END IF;

   -- Fix for Bug 8583847
    x_line_amount := l_line_rem_amount;

   IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message(l_full_name||': end');
    OZF_Utility_PVT.debug_message('x_line_amount :' || x_line_amount);
  END IF;

  x_funds_rem_tbl := l_funds_rem_tbl;


EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Populate_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Populate_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Populate_Line_Util_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Populate_Line_Util_Tbl;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Scan_Data_Details
--
-- HISTORY
--    06/04/2009  psomyaju  Create.
--    07/26/2009  BKUNJAN   Modified.
---------------------------------------------------------------------
PROCEDURE Get_Scan_Data_Details ( p_offer_status                       VARCHAR2
                                , p_batch_type                         VARCHAR2
                                , p_source_object_class                VARCHAR2
                                , px_funds_util_flt      IN OUT NOCOPY funds_util_flt_type
                                , px_currency_rec        IN OUT NOCOPY currency_rec_type
                                , x_return_status        OUT    NOCOPY VARCHAR2
                                , x_msg_count            OUT    NOCOPY NUMBER
                                , x_msg_data             OUT    NOCOPY VARCHAR2
                                )
IS

l_api_version   CONSTANT  NUMBER       := 1.0;
l_api_name      CONSTANT  VARCHAR2(30) := 'Get_Scan_Data_Details';
l_full_name     CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_asso_total_units        NUMBER;
l_asso_uom_code           VARCHAR2(30);
l_asso_total_quantity     NUMBER;
l_net_asso_amount         NUMBER;
l_net_total_units         NUMBER;
l_offer_uom_code          VARCHAR2(30);
l_offer_quantity          NUMBER;
l_product_id              NUMBER;
l_offer_status            VARCHAR2(30);

CURSOR csr_activity_product_id(cv_plan_id IN NUMBER, cv_product_id IN NUMBER) IS
  SELECT activity_product_id
  FROM ozf_funds_utilized_all_b
  WHERE plan_type = 'OFFR'
  AND org_id = MO_GLOBAL.GET_CURRENT_ORG_ID()
  AND plan_id = cv_plan_id
  AND product_level_type = 'PRODUCT'
  AND product_id = cv_product_id;

CURSOR csr_offer_profile(cv_activity_product_id IN NUMBER) IS
  SELECT uom_code
  ,      quantity
  ,      scan_value
  ,      inventory_item_id
  FROM ams_act_products
  WHERE activity_product_id = cv_activity_product_id;

CURSOR csr_offer_status(cv_offer_id IN NUMBER) IS
  SELECT status_code
       , transaction_currency_code
  FROM   ozf_offers
  WHERE  qp_list_header_id = cv_offer_id;

BEGIN

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
    END IF;

    SAVEPOINT Get_Scan_Data_Details;

    IF px_funds_util_flt.activity_product_id IS NULL THEN
      OPEN csr_activity_product_id(px_funds_util_flt.activity_id, px_funds_util_flt.product_id);
      FETCH csr_activity_product_id INTO px_funds_util_flt.activity_product_id;
      CLOSE csr_activity_product_id;
    END IF;

    --For given offer and product, get the UOM, quantity, scan value.
    OPEN  csr_offer_profile(px_funds_util_flt.activity_product_id);
    FETCH csr_offer_profile INTO l_offer_uom_code
                               , l_offer_quantity
                               , G_SCAN_VALUE
                               , l_product_id;
    CLOSE csr_offer_profile;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_offer_uom_code = '||l_offer_uom_code);
      OZF_Utility_PVT.debug_message('l_offer_quantity = '||l_offer_quantity);
      OZF_Utility_PVT.debug_message('l_product_id = '||l_product_id);
    END IF;
    --Get offer details for which accruals need to associated with claim.
    OPEN  csr_offer_status(px_funds_util_flt.activity_id);
    FETCH csr_offer_status INTO l_offer_status,px_currency_rec.transaction_currency_code;
    CLOSE csr_offer_status;

    --If UOM is not supplied to program unit, then product UOM defined for offer should be derived.
    IF px_funds_util_flt.uom_code IS NULL THEN
       l_asso_uom_code :=  l_offer_uom_code;
    ELSE
       l_asso_uom_code :=  px_funds_util_flt.uom_code;
    END IF;
    --Assign Coupon Count
    l_asso_total_units := px_funds_util_flt.total_units;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('px_funds_util_flt.quantity = '||px_funds_util_flt.quantity);
      OZF_Utility_PVT.debug_message('px_funds_util_flt.total_units = '||px_funds_util_flt.total_units);
      OZF_Utility_PVT.debug_message('px_funds_util_flt.total_amount = '||px_funds_util_flt.total_amount);
      OZF_Utility_PVT.debug_message('l_asso_uom_code = '||l_asso_uom_code);
      OZF_Utility_PVT.debug_message('l_asso_total_units = '||l_asso_total_units);
      OZF_Utility_PVT.debug_message('l_offer_uom_code = '||l_offer_uom_code);
      OZF_Utility_PVT.debug_message('G_SCAN_VALUE = '||G_SCAN_VALUE);
    END IF;

    /*SCAN DATA Quantity Calculation:
      If there is mismatch between UOM supplied to program unit and derived from offer, then convert
      supplied quantity from supplied UOM to derived offer UOM. Otherwise, consider the quantity supplied
      to program unit.
      If quantity not supplied to program unit, then derive quantity from offer and calculate quantity as
      units times offer quantity. If there is mismatch between UOM supplied to program unit and UOM derived
      from offer, then convert quantity from offer UOM to UOM supplied to program unit.

      SCAN DATA Prorate Condition:
      If prorate flag is not checked, then re-calculate quantity on the basis of net units. Here, net units is
      difference of units between current association process and already associated lines. If there is UOM
      mismatch between supplied and derived from offer, then convert quantity from offer UOM to supplied UOM.
    */

    IF px_funds_util_flt.quantity IS NOT NULL THEN
      IF l_asso_uom_code <> l_offer_uom_code THEN
          l_asso_total_quantity := inv_convert.inv_um_convert ( item_id         => l_product_id
                                                              , precision       => 2
                                                              , from_quantity   => px_funds_util_flt.quantity
                                                              , from_unit       => px_funds_util_flt.uom_code
                                                              , to_unit         => l_offer_uom_code
                                                              , from_name       => NULL
                                                              , to_name         => NULL
                                                              );
          IF l_asso_total_quantity = -99999 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
          END IF;
      ELSE
         l_asso_total_quantity := px_funds_util_flt.quantity;
      END IF;
       l_asso_total_units := l_asso_total_quantity / l_offer_quantity;
    ELSE
      IF l_asso_total_units IS NOT NULL THEN
        --IF p_prorate_req_flag THEN
            --l_asso_total_quantity := l_asso_total_units * l_offer_quantity;
        --ELSE
        --  l_net_total_units := NVL(l_asso_total_units, 0) - NVL(px_funds_util_flt.old_total_units, 0);
        --  l_asso_total_quantity := l_net_total_units * l_offer_quantity;
        --END IF;
        IF l_asso_uom_code <> l_offer_uom_code THEN
          l_asso_total_quantity := inv_convert.inv_um_convert ( item_id         => l_product_id
                                                              , precision       => 2
                                                              , from_quantity   => l_asso_total_units * l_offer_quantity
                                                              , from_unit       => l_offer_uom_code
                                                              , to_unit         => px_funds_util_flt.uom_code
                                                              , from_name       => NULL
                                                              , to_name         => NULL
                                                              );
          IF l_asso_total_quantity = -99999 THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CANT_CONVERT_UOM');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
          END IF;
        ELSE
            l_asso_total_quantity := l_asso_total_units * l_offer_quantity;
        END IF;
      --ELSE --//BKUNJAN
      --   l_asso_total_units := px_funds_util_flt.total_amount / G_SCAN_VALUE;
      END IF;
    END IF;  -- IF px_funds_util_flt.quantity IS NOT NULL THEN


    --SCAN DATA offers, which are not processed from IDSM Batch ,
    --re-calculate association amount as unit times scan value.
    IF (p_batch_type = 'BATCH' and p_source_object_class = 'SPECIAL_PRICE') THEN
       NULL;
    ELSE
       px_funds_util_flt.total_amount := l_asso_total_units * G_SCAN_VALUE;
    END IF;

    --//BKUNJAN moved this code to down
   --If no units supplied to program unit, then unit will be association amount per scan value.
    IF px_funds_util_flt.total_units IS NULL THEN
        --l_asso_total_units := l_asso_total_quantity / G_SCAN_VALUE;
        --Added by BKUNJAN
        l_asso_total_units := px_funds_util_flt.total_amount / G_SCAN_VALUE;

    ELSE
        l_asso_total_units := px_funds_util_flt.total_units;
    END IF;

    --Calculate net associate amount as difference between association amount and
    --already associated amount with current claim line.
    l_net_asso_amount :=  NVL(ABS(px_funds_util_flt.total_amount), 0) - NVL(ABS(px_funds_util_flt.old_total_amount),0);

    --Raise error, if net association amount exists and offer is COMPLETED.
    IF l_net_asso_amount <> 0 THEN
      IF p_offer_status = 'COMPLETED' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ASSO_COMPLETE_OFFER');
            FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
    END IF;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_asso_total_quantity = '||l_asso_total_quantity);
      OZF_Utility_PVT.debug_message('l_asso_total_units = '||l_asso_total_units);
      OZF_Utility_PVT.debug_message('l_asso_uom_code = '||l_asso_uom_code);
    END IF;

    px_funds_util_flt.total_units := l_asso_total_units;
    px_funds_util_flt.quantity    := l_asso_total_quantity;
    px_funds_util_flt.uom_code    := l_asso_uom_code;

    IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': end');
    END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Get_Scan_Data_Details;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Get_Scan_Data_Details;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Get_Scan_Data_Details;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Get_Scan_Data_Details;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Pay_Over_Amount
-- PURPOSE
--    If pay over earnings is allowed then this program unit
--    calculates pay over amount for each qualified accrual of
--    current association process
-- HISTORY
--    08/04/2009  psomyaju  Created.
---------------------------------------------------------------------

PROCEDURE  Get_Pay_Over_Amount   ( p_util              IN  funds_rem_tbl_type
                                 , p_claim_amt         IN  NUMBER
                                 , p_claim_exc_rate    IN  NUMBER  DEFAULT 1
                                 , p_claim_exc_date    IN  DATE
                                 , p_claim_exc_type    IN  VARCHAR2
                                 , p_currency_rec      IN  currency_rec_type
                                 , x_pay_over_flag     OUT NOCOPY BOOLEAN
                                 , x_pay_over_amount   OUT NOCOPY NUMBER
                                 , x_return_status     OUT NOCOPY VARCHAR2
                                 , x_msg_count         OUT NOCOPY NUMBER
                                 , x_msg_data          OUT NOCOPY VARCHAR2
                                 )
IS

l_api_version   CONSTANT  NUMBER       := 1.0;
l_api_name      CONSTANT  VARCHAR2(30) := 'Get_Pay_Over_Amount';
l_full_name     CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_accrual_exchange_rate   NUMBER       := 1;
l_accrual_exchange_date   DATE;
l_accrual_exchange_type   VARCHAR2(30);
l_plan_curr_amount_rem    NUMBER       := 0;
l_plan_curr_amount        NUMBER       := 0;
l_exec_curr_amount_rem    NUMBER       := 0;
l_total_amt_rem           NUMBER       := 0;
l_acctd_amount_remaining  NUMBER       := 0;
l_plan_currency_code      VARCHAR2(30);
l_return_status           VARCHAR2(1);

CURSOR c_util_dtls (cv_util_id IN NUMBER) IS
  SELECT   plan_currency_code
         , plan_curr_amount_remaining
         , plan_curr_amount
         , acctd_amount_remaining
  FROM     ozf_funds_utilized_all_b   util
  WHERE    utilization_id = cv_util_id;


BEGIN

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
  END IF;

  SAVEPOINT Get_Pay_Over_Amount;

  -- Amount remaining will be calculated for all the utilizations qualified for associate earnings.
  IF p_util.COUNT > 0 THEN
    FOR i IN  p_util.FIRST..p_util.LAST
    LOOP
      OPEN  c_util_dtls(p_util(i).utilization_id);
      FETCH c_util_dtls INTO  l_plan_currency_code              -- Transactional Currency
                            , l_plan_curr_amount_rem            -- Accrual amount remaining in transactional currency
                            , l_plan_curr_amount                -- Accrual amount in transactional currency
                            , l_acctd_amount_remaining;
      CLOSE c_util_dtls;

      IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_plan_currency_code = ' ||l_plan_currency_code);
        OZF_Utility_PVT.debug_message('l_plan_curr_amount_rem = ' ||l_plan_curr_amount_rem);
        OZF_Utility_PVT.debug_message('l_plan_curr_amount = ' ||l_plan_curr_amount);
        OZF_Utility_PVT.debug_message('l_acctd_amount_remaining = ' ||l_acctd_amount_remaining);
      END IF;

      IF  p_currency_rec.association_currency_code = p_currency_rec.transaction_currency_code THEN
        l_total_amt_rem := l_total_amt_rem + NVL(l_plan_curr_amount_rem,0);
      ELSE
        l_total_amt_rem := l_total_amt_rem + NVL(l_acctd_amount_remaining,0);
      END IF;
    END LOOP;
  END IF;

--nepanda : fix for bug # 9508390  - issue # 3
x_pay_over_amount := p_claim_amt - l_total_amt_rem;
IF x_pay_over_amount > 0 THEN
   x_pay_over_flag := TRUE;
ELSE
   x_pay_over_amount := 0;
END IF;
  /*
  -- Pay over validation
  IF ( l_total_amt_rem >= 0 AND
       p_claim_amt > l_total_amt_rem
     ) OR
     ( l_total_amt_rem < 0 AND
       p_claim_amt < l_total_amt_rem
     ) THEN

       x_pay_over_flag := TRUE;

       x_pay_over_amount := p_claim_amt - l_total_amt_rem; --kdass

  ELSE

      x_pay_over_amount := 0; --kdass
  END IF;

  */
  --x_pay_over_amount := p_claim_amt - l_total_amt_rem; --kdass

  IF OZF_DEBUG_HIGH_ON THEN
    OZF_Utility_PVT.debug_message('l_exec_curr_amount_rem = ' || l_exec_curr_amount_rem);
    OZF_Utility_PVT.debug_message('l_total_amt_rem = ' || l_total_amt_rem);
    OZF_Utility_PVT.debug_message('p_claim_amt = ' || p_claim_amt);
    OZF_Utility_PVT.debug_message('x_pay_over_amount = ' || x_pay_over_amount);
    IF x_pay_over_flag THEN
      OZF_Utility_PVT.debug_message('x_pay_over_flag = TRUE');
    ELSE
      OZF_Utility_PVT.debug_message('x_pay_over_flag = FALSE');
    END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': end');
  END IF;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Get_Pay_Over_Amount;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Get_Pay_Over_Amount;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Get_Pay_Over_Amount;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Get_Pay_Over_Amount;

---------------------------------------------------------------------
-- PROCEDURE
















--    Update_Group_Line_Util
--
-- HISTORY
--    10/05/2001  mchang  Create.
--    11/03/2009  psomyaju  Re-organized code for R12 multicurrency ER
---------------------------------------------------------------------
PROCEDURE Update_Group_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_summary_view        IN  VARCHAR2  := NULL
  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Update_Group_Line_Util';
l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(30);

l_funds_util_flt          funds_util_flt_type   :=  p_funds_util_flt;
l_line_util_tbl           line_util_tbl_type;
l_funds_rem_tbl           funds_rem_tbl_type;
l_currency_rec            currency_rec_type;


l_asso_amount             NUMBER;
l_exists_asso_amount      NUMBER := 0;
--l_exists_asso_amount      NUMBER;
l_net_asso_amount         NUMBER;
l_cre_util_amount         NUMBER;
l_create_util             BOOLEAN := TRUE;
l_claim_status            VARCHAR2(15);
l_source_object_class     VARCHAR2(1024);
l_batch_type              VARCHAR2(1024);
l_claim_date              DATE;
l_claim_exc_type          VARCHAR2(1024);
l_claim_exc_date          DATE;
l_claim_exc_rate          NUMBER;
l_source_object_id        NUMBER;
l_request_header_id       NUMBER;       --Bugfix : 7717638
l_batch_line_id           NUMBER;       --Bugfix : 7811671
l_convert_exchange_rate   NUMBER;
l_prorate_earnings_flag   VARCHAR2(15);
l_prorate_req_flag        BOOLEAN := FALSE;
l_pay_over_amount         NUMBER;
l_tot_accrual_amt         NUMBER := 0;
l_error_index             NUMBER;
l_asso_total_units        NUMBER;
l_asso_uom_code           VARCHAR2(15);
l_asso_total_quantity     NUMBER;
l_org_id                  NUMBER;
l_claim_amt               NUMBER := 0;
l_offer_currency          VARCHAR2(15);
l_offer_status            VARCHAR2(30);
l_pay_over_flag           BOOLEAN := FALSE;
l_created_from            VARCHAR2(30);

l_new_line_amount NUMBER := 0;

CURSOR csr_function_currency(cv_org_id NUMBER) IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = cv_org_id;

-- Bugfix 5404951
CURSOR csr_claim_status(cv_claim_line_id IN NUMBER) IS
  SELECT cla.status_code
       , cla.source_object_class
       , cla.batch_type
       , cla.currency_code
       , cla.creation_date
       , cla.exchange_rate_type
       , cla.exchange_rate_date
       , cla.exchange_rate
       , cla.source_object_id
       , cln.activity_id
       , cln.batch_line_id
       , cla.created_from
       , cla.org_id
  FROM   ozf_claims cla, ozf_claim_lines cln
  WHERE  cla.claim_id = cln.claim_id
    AND  cln.claim_line_id = cv_claim_line_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Update_Group_Line_Util;
  x_return_status := FND_API.g_ret_sts_success;

  --Set to handle rounding issue at Update_Fund_Utils
 G_ENTERED_AMOUNT        := l_funds_util_flt.total_amount;

  IF OZF_DEBUG_HIGH_ON THEN
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



  --Get claim details of claim for which association is taking place.
  OPEN csr_claim_status(l_funds_util_flt.claim_line_id);
  FETCH csr_claim_status INTO   l_claim_status
                              , l_source_object_class
                              , l_batch_type
                              , l_currency_rec.claim_currency_code
                              , l_claim_date
                              , l_claim_exc_type
                              , l_claim_exc_date
                              , l_claim_exc_rate
                              , l_source_object_id
                              , l_request_header_id
                              , l_batch_line_id
                              , l_created_from
                              , l_org_id;
  CLOSE csr_claim_status;

  --Get FUNCTIONAL currency from system parameters
  OPEN  csr_function_currency(l_org_id);
  FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
  CLOSE csr_function_currency;

  --Set UNIVERSAL currency from profile.
  l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');
  IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message('l_claim_status = '||l_claim_status);
    ozf_utility_pvt.debug_message('l_claim_date = '||l_claim_date);
    ozf_utility_pvt.debug_message('l_claim_exc_type = '||l_claim_exc_type);
    ozf_utility_pvt.debug_message('l_claim_exc_date = '||l_claim_exc_date);
    ozf_utility_pvt.debug_message('l_claim_exc_rate = '||l_claim_exc_rate);
    ozf_utility_pvt.debug_message('l_source_object_id = '||l_source_object_id);
    ozf_utility_pvt.debug_message('l_source_object_class = '||l_source_object_class);
    ozf_utility_pvt.debug_message('l_request_header_id = '||l_request_header_id);
    ozf_utility_pvt.debug_message('l_batch_line_id = '||l_batch_line_id);
    ozf_utility_pvt.debug_message('l_batch_type = '||l_batch_type);
    ozf_utility_pvt.debug_message('l_created_from = '||l_created_from);
    ozf_utility_pvt.debug_message('p_summary_view = '||p_summary_view);
    ozf_utility_pvt.debug_message('l_org_id = '||l_org_id);
    ozf_utility_pvt.debug_message('Passed Association Amount = '||l_funds_util_flt.total_amount);
    ozf_utility_pvt.debug_message('Existing Association Amount = '||l_funds_util_flt.old_total_amount);
  END IF;

  --Raise error, if claim is not OPEN status and associate earnings is happening.
  IF l_claim_status <> 'OPEN' THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_ASSO_NOT_OPEN');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;


  ----------------- copy line info to filter ---------------
  IF l_funds_util_flt.claim_line_id IS NOT NULL THEN
    Copy_Util_Flt(px_funds_util_flt => l_funds_util_flt);
  END IF;


  --Association processing depends on prorate condition. Get the details of prorate check
  --at system parameter level and claim lines level.
  Get_Prorate_Earnings_Flag ( p_funds_util_flt         => l_funds_util_flt
                            , x_prorate_earnings_flag  => l_prorate_earnings_flag
                            );



  --For SCAN DATA offers prorate is not required. Also, if claim line is not associated with any
  --earnings then we need not require to do earnings on prorate basis.
  IF  l_funds_util_flt.offer_type = 'SCAN_DATA' OR
      NVL(l_prorate_earnings_flag,'F') = 'F' OR
      NVL(l_funds_util_flt.old_total_amount ,0) = 0 THEN
        l_prorate_req_flag := FALSE;
  ELSE
        l_prorate_req_flag := TRUE;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message('l_prorate_earnings_flag = '||l_prorate_earnings_flag);
    ozf_utility_pvt.debug_message('l_funds_util_flt.offer_type = '||l_funds_util_flt.offer_type);
    ozf_utility_pvt.debug_message('l_funds_util_flt.old_total_amount = '||l_funds_util_flt.old_total_amount);
  END IF;

  --In case of SCAN DATA offers, association amount based on quantity, UOM and units accrured. Hence,
  --we need to retrieve these specific information for SCAN DATA offers processing.
  IF l_funds_util_flt.offer_type = 'SCAN_DATA' THEN
     --Calculate association amount, quantity, total units and TRANSACTIONAL currency of SCAN DATA offer.
     --Since, association amount calculated for SCAN DATA offers based on offer quantity and scan units,
     --Hence, this amount will always be in TRANSACTIONAL currency.

    Get_Scan_Data_Details ( p_offer_status         => l_offer_status
                           , p_batch_type           => l_batch_type
                           , p_source_object_class  => l_source_object_class
                           , px_funds_util_flt      => l_funds_util_flt
                           , px_currency_rec        => l_currency_rec
                           , x_return_status        => l_return_status
                           , x_msg_count            => l_msg_count
                           , x_msg_data             => l_msg_data
                           );

     IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
     END IF;

     --For SCAN DATA offers, if units or quantity will be NULL then association amount will be NULL.
     --Abort process, as without these entities, association cannot be done.
     IF l_funds_util_flt.total_units IS NULL OR
        l_funds_util_flt.quantity IS NULL OR
        l_funds_util_flt.total_amount IS NULL THEN
        RETURN;
     END IF;

  ELSE
    --Transactional currency (OFFER or ORDER currency) supposed to be passed to this program unit.
    IF l_funds_util_flt.utiz_currency_code IS NOT NULL THEN
       l_currency_rec.transaction_currency_code :=  l_funds_util_flt.utiz_currency_code;
    END IF;
    IF OZF_DEBUG_HIGH_ON THEN
       ozf_utility_pvt.debug_message('l_funds_util_flt.utiz_currency_code  = '||l_funds_util_flt.utiz_currency_code);
       ozf_utility_pvt.debug_message('l_currency_rec.transaction_currency_code = '||l_currency_rec.transaction_currency_code);
    END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message('l_funds_util_flt.total_units = '||l_funds_util_flt.total_units);
    ozf_utility_pvt.debug_message('l_funds_util_flt.quantity  = '||l_funds_util_flt.quantity );
    ozf_utility_pvt.debug_message('l_funds_util_flt.total_amount = '||l_funds_util_flt.total_amount);
    ozf_utility_pvt.debug_message('l_currency_rec.transaction_currency_code = '||l_currency_rec.transaction_currency_code);
    ozf_utility_pvt.debug_message('l_currency_rec.claim_currency_code =  '||l_currency_rec.claim_currency_code);
    ozf_utility_pvt.debug_message('l_currency_rec.functional_currency_code = '||l_currency_rec.functional_currency_code);
  END IF;

  --Association can be done in either TRANSACTIONAL currency or FUNCTIONAL currency. We will set GLOBAL variable
  --G_ASSO_CURRENCY accordingly, so that entire association will be in single known currency and we need NOT to
  --convert them on case by case basis.
   IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
      l_currency_rec.association_currency_code  := l_currency_rec.transaction_currency_code;
      l_asso_amount                             := l_funds_util_flt.total_amount;
      l_exists_asso_amount                      := l_funds_util_flt.old_total_amount;
      l_net_asso_amount                         := NVL(ABS(l_asso_amount), 0) - NVL(ABS(l_exists_asso_amount),0);
  ELSE
      IF l_funds_util_flt.total_amount IS NOT NULL AND l_funds_util_flt.total_amount <> 0 THEN
         l_currency_rec.association_currency_code       := l_currency_rec.functional_currency_code;

        IF l_currency_rec.claim_currency_code <> l_currency_rec.functional_currency_code THEN
           OZF_UTILITY_PVT.Convert_Currency ( p_from_currency   => l_currency_rec.claim_currency_code
                                            , p_to_currency     => l_currency_rec.functional_currency_code
                                            , p_conv_type       => l_claim_exc_type
                                            , p_conv_rate       => l_claim_exc_rate
                                            , p_conv_date       => l_claim_exc_date
                                            , p_from_amount     => l_funds_util_flt.total_amount
                                            , x_return_status   => l_return_status
                                            , x_to_amount       => l_asso_amount
                                            , x_rate            => l_convert_exchange_rate
                                            );

          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_error;
          END IF;
          IF l_asso_amount IS NOT NULL THEN
            l_asso_amount := OZF_UTILITY_PVT.CurrRound(l_asso_amount, l_currency_rec.association_currency_code);
          END IF;
        ELSE
          l_asso_amount := l_funds_util_flt.total_amount;
        END IF;
      ELSE
        l_asso_amount := 0;
      END IF;

      IF l_funds_util_flt.old_total_amount IS NOT NULL AND l_funds_util_flt.old_total_amount <> 0 THEN
        IF l_currency_rec.claim_currency_code <> l_currency_rec.association_currency_code THEN
          OZF_UTILITY_PVT.Convert_Currency ( p_from_currency   => l_currency_rec.claim_currency_code
                                           , p_to_currency     => l_currency_rec.functional_currency_code
                                           , p_conv_type       => l_claim_exc_type
                                           , p_conv_rate       => l_claim_exc_rate
                                           , p_conv_date       => l_claim_exc_date
                                           , p_from_amount     => l_funds_util_flt.old_total_amount
                                           , x_return_status   => l_return_status
                                           , x_to_amount       => l_exists_asso_amount
                                           , x_rate            => l_convert_exchange_rate
                                           );

          IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_error;
          END IF;
          IF l_exists_asso_amount IS NOT NULL THEN
            l_exists_asso_amount := OZF_UTILITY_PVT.CurrRound(l_exists_asso_amount, l_currency_rec.association_currency_code);
          END IF;
        ELSE
          l_exists_asso_amount := l_funds_util_flt.old_total_amount;
        END IF;
      ELSE
        l_exists_asso_amount := 0;
      END IF;

      l_net_asso_amount := NVL(ABS(l_asso_amount), 0) - NVL(ABS(l_exists_asso_amount),0);
  END IF;

  IF l_net_asso_amount IS NOT NULL THEN
    l_net_asso_amount := OZF_UTILITY_PVT.CurrRound(l_net_asso_amount, l_currency_rec.association_currency_code);
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message('l_currency_rec.association_currency_code = '||l_currency_rec.association_currency_code);
    ozf_utility_pvt.debug_message('l_asso_amount  = '||l_asso_amount);
    ozf_utility_pvt.debug_message('l_exists_asso_amount = '||l_exists_asso_amount);
    ozf_utility_pvt.debug_message('l_net_asso_amount = '||l_net_asso_amount);
  END IF;

  /* Prorate Condition:
  If prorate flag is set, then identify all the qualified utilizations for current association
  and reduce amount remaining with current association amount. Remove existing associations with
  current claim line and calculate fresh association earnings for claim line..
  Otherwise, if prorate flag is not set, and association amount is smaller than already associated
  amount with current claim line then reduce amount remaining of qualified utilizations as well as
  already associated amounts. Re-calculate FXGL for reduced associated amounts. No fresh association
  should be done.
  If prorate is not set and association amount is larger than already associated amount, then do association
  with supplied association amount.
  */

  IF l_prorate_req_flag THEN
         Delete_All_Line_Util ( p_api_version       => l_api_version
                              , p_init_msg_list     => FND_API.g_false
                              , p_commit            => FND_API.g_false
                              , p_validation_level  => FND_API.g_valid_level_full
                              , x_return_status     => l_return_status
                              , x_msg_data          => x_msg_data
                              , x_msg_count         => x_msg_count
                              , p_currency_rec      => l_currency_rec
                              , p_funds_util_flt    => l_funds_util_flt
                              );

         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_error;
         END IF;
         l_cre_util_amount := NVL(l_asso_amount, 0);
  ELSE
      IF l_net_asso_amount < 0 THEN
         Delete_Group_Line_Util ( p_api_version       => l_api_version
                                , p_init_msg_list     => FND_API.g_false
                                , p_commit            => FND_API.g_false
                                , p_validation_level  => FND_API.g_valid_level_full
                                , x_return_status     => l_return_status
                                , x_msg_data          => x_msg_data
                                , x_msg_count         => x_msg_count
                                , p_funds_util_flt    => l_funds_util_flt
                                );

         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_error;
         END IF;
         l_create_util := FALSE;
      ELSE
         l_cre_util_amount := NVL(l_asso_amount, 0) - NVL(l_exists_asso_amount ,0);
         l_cre_util_amount := OZF_UTILITY_PVT.CurrRound(l_cre_util_amount, l_currency_rec.association_currency_code);
      END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message('l_cre_util_amount  = '||l_cre_util_amount);
    IF l_create_util THEN
      ozf_utility_pvt.debug_message('l_create_util = TRUE');
    ELSE
      ozf_utility_pvt.debug_message('l_create_util = FALSE');
    END IF;
  END IF;

  /* Associate Earnings:
  Identify all the utilizations qualifies for current association based on customer, offer
  and product combinations. If prorate is checked, then calculate association amount based
  on prorate basis.
  */

  IF l_create_util THEN
      Populate_Line_Util_Tbl ( p_funds_util_flt         => l_funds_util_flt
                             , p_source_object_class    => l_source_object_class
                             , p_source_object_id       => l_source_object_id
                             , p_request_header_id      => l_request_header_id
                             , p_batch_line_id          => l_batch_line_id
                             , p_batch_type             => l_batch_type
                             , p_summary_view           => p_summary_view
                             , p_cre_util_amount        => l_cre_util_amount
                             , p_prorate_earnings_flag  => l_prorate_earnings_flag
                             , p_currency_rec           => l_currency_rec
                             , x_funds_rem_tbl          => l_funds_rem_tbl
                             , x_tot_accrual_amt        => l_tot_accrual_amt
                             , x_line_amount            => l_new_line_amount
                             , x_line_util_tbl          => l_line_util_tbl
                             , x_msg_data               => x_msg_data
                             , x_msg_count              => x_msg_count
                             , x_return_status          => l_return_status
                             );


      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_error;
      END IF;

      --For Supplier Ship Debit claims, claim line amount will always be total association
      --amount and never fall into pay over earnings category. Hence, skip pay over earnings
      --these type of claims.

      IF NVL(l_source_object_class,'X') = 'SD_SUPPLIER' THEN
        GOTO Create_Line_Util;
      END IF;

      l_claim_amt := l_asso_amount - NVL(l_exists_asso_amount,0);

      /* Validate Over Utilization:
      Pay over earnings will take place only for Normal claims created from Trade Management
      UI. Since, utilizations amount remaining in BUDGET currency, while association amount
      is in CLAIM currency. Hence, need to validate over utilizations w.r.t. association amount
      in CLAIM currency.
      */

      IF (( NVL(l_created_from, 'NONE') <> 'AUTOPAY')
         AND (NVL(l_batch_type, 'NONE') <> 'BATCH'
         AND  NVL(l_source_object_class, 'NONE') NOT IN ('BATCH','SPECIAL_PRICE') --//Bug fix : 9751679
         AND  l_funds_util_flt.offer_type IS NOT NULL))
      THEN
          Get_Pay_Over_Amount  ( p_util             => l_funds_rem_tbl
                               , p_claim_amt        => l_cre_util_amount
                               , p_claim_exc_rate   => l_claim_exc_rate
                               , p_claim_exc_date   => l_claim_exc_date
                               , p_claim_exc_type   => l_claim_exc_type
                               , p_currency_rec     => l_currency_rec
                               , x_pay_over_flag    => l_pay_over_flag
                               , x_pay_over_amount  => l_pay_over_amount
                               , x_return_status    => l_return_status
                               , x_msg_data         => x_msg_data
                               , x_msg_count        => x_msg_count
                               );
      END IF;

      IF OZF_DEBUG_HIGH_ON THEN
        IF l_pay_over_flag THEN
           OZF_Utility_PVT.debug_message('l_pay_over_flag = TRUE');
        ELSE
           OZF_Utility_PVT.debug_message('l_pay_over_flag = FALSE');
        END IF;
        OZF_Utility_PVT.debug_message('l_claim_amt = '||l_claim_amt);
        OZF_Utility_PVT.debug_message('l_cre_util_amount = '||l_cre_util_amount);
        OZF_Utility_PVT.debug_message('l_pay_over_amount = '||l_pay_over_amount);
        OZF_Utility_PVT.debug_message('l_tot_accrual_amt = '|| NVL(l_tot_accrual_amt,0));
        OZF_Utility_PVT.debug_message('l_new_line_amount = '|| NVL(l_new_line_amount,0));
        OZF_Utility_PVT.debug_message('l_funds_rem_tbl.count = '|| l_funds_rem_tbl.count);
      END IF;

      IF l_pay_over_flag THEN
        Validate_Over_Utilization(
           p_api_version            => l_api_version
          ,p_init_msg_list          => FND_API.g_false
          ,p_validation_level       => p_validation_level
          ,x_return_status          => l_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_currency_rec           => l_currency_rec
          ,p_funds_util_flt         => l_funds_util_flt
          ,p_over_paid_amount       => l_pay_over_amount --nepanda : fix for bug # 9508390  - issue # 3
        );
        IF l_return_status = fnd_api.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF;

      --If pay over earnings is allowed, then create adjustments for over paid earnings w.r.t.
      --association amount.
      -- Changed the code to create the adjustment for multiple and single product lines -- kpatro
        IF (NVL(l_new_line_amount,0) <> 0 AND l_pay_over_amount > 0) THEN
        Create_Pay_Over_Adjustments ( px_line_util_tbl        => l_line_util_tbl
                                    , p_funds_util_flt        => l_funds_util_flt
                                    , p_tot_accrual_amt       => NVL(l_tot_accrual_amt,0)
                                    , p_pay_over_amount       => l_pay_over_amount
                                    , p_prorate_earnings_flag => l_prorate_earnings_flag
                                    , p_new_total_amount      => l_new_line_amount
                                    , p_currency_rec          => l_currency_rec
                                    , x_return_status         => l_return_status
                                    , x_msg_data              => x_msg_data
                                    , x_msg_count             => x_msg_count

                                    );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_error;
        END IF;
             END IF;
  END IF;

     <<create_line_util>>

  --Do associate earnings for qualified utilizations with current claim line. Calculate
  --FXGL. Reduce amount remaining of utilizations w.r.t. corresponding association amounts.

  IF l_line_util_tbl.COUNT > 0 THEN
    Create_Line_Util_Tbl ( p_api_version            => l_api_version
                         , p_init_msg_list          => FND_API.g_false
                         , p_commit                 => FND_API.g_false
                         , p_validation_level       => p_validation_level
                         , x_return_status          => l_return_status
                         , x_msg_data               => x_msg_data
                         , x_msg_count              => x_msg_count
                         , p_currency_rec           => l_currency_rec
                         , p_line_util_tbl          => l_line_util_tbl
                         , x_error_index            => l_error_index
                         );

    IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Update_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Update_Group_Line_Util;

---------------------------------------------------------------
-- PROCEDURE
--    Del_Line_Util_By_Group
--
-- NOTE
--    p_line_util_rec contains claim_line_util_id
--                           , utilization_id
--                           , claim_line_id
--                           , acctd_amount
--
-- HISTORY
--    10/30/2002  mchang  Create.
--    08-Aug-06   azahmed  Modified for FXGL ER
--                         amount passed to Update_funds_util
---------------------------------------------------------------
PROCEDURE Del_Line_Util_By_Group(
   x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_line_util_rec     IN  line_util_rec_type
  ,px_currency_rec      IN OUT NOCOPY currency_rec_type
)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'Del_Line_Util_By_Group';
l_full_name       CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status            VARCHAR2(1);

l_line_util_rec          line_util_rec_type := p_line_util_rec;
l_amount          NUMBER;
l_currency_rec   currency_rec_type := px_currency_rec;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Del_Line_Util_By_Group;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_line_util_rec.utilization_id > 0 THEN
          ------------------ Update Uitlization ------------------


  --Set UNIVERSAL currency from profile.
  l_currency_rec.universal_currency_code := FND_PROFILE.VALUE('OZF_TP_COMMON_CURRENCY');

   IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
      l_currency_rec.association_currency_code := l_currency_rec.transaction_currency_code;
     --l_amount := p_line_util_rec.amount; --kdass
   ELSE
     l_currency_rec.association_currency_code := l_currency_rec.functional_currency_code;
     --l_amount := p_line_util_rec.acctd_amount; --kdass
   END IF;
   l_amount := p_line_util_rec.amount; --kdass
     Update_Fund_Utils(
                p_line_util_rec  => l_line_util_rec
              , p_asso_amount    => NVL(l_amount,0)
              , p_mode           => 'NONE'
              , px_currency_rec  => l_currency_rec
              , x_return_status  => l_return_status
              , x_msg_count      => x_msg_count
              , x_msg_data       => x_msg_data
              );
          IF l_return_status =  fnd_api.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
      END IF;

 END IF; -- p_line_util_rec.utilization_id > 0

  ------------------------ delete ------------------------
  DELETE FROM ozf_claim_lines_util_all
    WHERE claim_line_util_id = p_line_util_rec.claim_line_util_id;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data
  );

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Del_Line_Util_By_Group;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Del_Line_Util_By_Group;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Del_Line_Util_By_Group;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END Del_Line_Util_By_Group;

---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Group_Line_Util
--
-- HISTORY
--    10/05/2001  mchang  Create.
--    15-Mar-06   azahmed  Bugfix 5101106
--    08-Aug-06  azahmed  Modified for FXGL ER
---------------------------------------------------------------------
PROCEDURE Delete_Group_Line_Util(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_funds_util_flt      IN  funds_util_flt_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'Delete_Group_Line_Util';
l_full_name     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status          VARCHAR2(1);

l_funds_util_flt funds_util_flt_type := p_funds_util_flt;

TYPE FundsUtilCsrTyp IS REF CURSOR;
l_funds_util_csr         NUMBER; --FundsUtilCsrTyp;
l_funds_util_sql         VARCHAR2(3000);
l_line_util_tbl          line_util_tbl_type;
l_upd_line_util_rec      line_util_rec_type;
l_lu_line_util_id        NUMBER;
l_lu_utilization_id      NUMBER;
l_lu_amt                 NUMBER;
l_lu_scan_unit           NUMBER;
l_del_total_amount       NUMBER;
l_del_total_units        NUMBER;
l_counter                PLS_INTEGER := 1;
i                        PLS_INTEGER;
l_funds_util_end         VARCHAR2(1) := 'N';
l_final_lu_amt     NUMBER;
l_object_version_number  NUMBER;
l_ignore                 NUMBER;
l_offer_uom_code         VARCHAR2(3);
l_offer_quantity         NUMBER;
l_scan_value             NUMBER;
l_product_id             NUMBER;
l_lu_acctd_amt           NUMBER;
l_utiz_currency          VARCHAR2(15);
l_utiz_amount            NUMBER;
l_lu_currency_code       VARCHAR2(15);

l_currency_rec           currency_rec_type;

CURSOR csr_final_lu_amt(cv_claim_line_id IN NUMBER) IS
  SELECT SUM(amount)
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND   org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_claim_currency(cv_claim_line_id IN NUMBER) IS
SELECT currency_code from ozf_claim_lines
where claim_line_id = cv_claim_line_id;

CURSOR csr_offer_currency(cv_plan_id IN NUMBER) IS
  SELECT transaction_currency_code
  FROM ozf_offers
  WHERE qp_list_header_id = cv_plan_id;

CURSOR csr_over_util(cv_claim_line_id IN NUMBER, cv_act_product_id IN NUMBER) IS
  SELECT claim_line_util_id, acctd_amount, scan_unit
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id
  AND activity_product_id = cv_act_product_id
  AND utilization_id = -1;

CURSOR csr_acc_over_util(cv_claim_line_id IN NUMBER, cv_offer_id IN NUMBER) IS
  SELECT claim_line_util_id, acctd_amount
  FROM   ozf_claim_lines_util util
  WHERE  claim_line_id = cv_claim_line_id
  AND    activity_product_id = cv_offer_id
  AND    utilization_id = -2;

-- Bugfix 5101106: Recalculate qty
CURSOR csr_offer_profile(cv_activity_product_id IN NUMBER) IS
  SELECT uom_code
  ,      quantity
  ,      scan_value
  ,      inventory_item_id
  FROM ams_act_products
  WHERE activity_product_id = cv_activity_product_id;

--Changed cursor csr_utiz_amount currency for Multicurrency ER.
/*
CURSOR csr_utiz_amount(cv_line_util_id IN NUMBER) IS
SELECT util_curr_amount
FROM ozf_claim_lines_util
WHERE claim_line_util_id = cv_line_util_id;
*/

CURSOR csr_utiz_amount(cv_line_util_id IN NUMBER) IS
SELECT DECODE(ln.currency_code,fu.plan_currency_code,ln.plan_curr_amount,ln.acctd_amount)
FROM ozf_claim_lines_util ln
   , ozf_funds_utilized_all_b fu
WHERE claim_line_util_id = cv_line_util_id
  AND fu.utilization_id = ln.utilization_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Group_Line_Util;

  IF OZF_DEBUG_HIGH_ON THEN
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

  OPEN  csr_function_currency;
  FETCH csr_function_currency INTO l_currency_rec.functional_currency_code;
  CLOSE csr_function_currency;


  Init_Line_Util_Rec(
     x_line_util_rec   => l_upd_line_util_rec
  );

  ----------------- copy line info to filter ---------------

  IF p_funds_util_flt.claim_line_id IS NOT NULL THEN
    Copy_Util_Flt(px_funds_util_flt => l_funds_util_flt);
  END IF;

-- derive claim currency
  OPEN csr_claim_currency(l_funds_util_flt.claim_line_id);
  FETCH csr_claim_currency INTO l_currency_rec.claim_currency_code;
  CLOSE csr_claim_currency;

   --kdass
  l_currency_rec.transaction_currency_code := l_funds_util_flt.utiz_currency_code;

  IF l_currency_rec.claim_currency_code = l_currency_rec.transaction_currency_code THEN
     l_currency_rec.association_currency_code  := l_currency_rec.transaction_currency_code;
  ELSE
      l_currency_rec.association_currency_code  := l_currency_rec.functional_currency_code;
  END IF;

 IF OZF_DEBUG_HIGH_ON THEN
   ozf_utility_pvt.debug_message('l_currency_rec.claim_currency_code       :' || l_currency_rec.claim_currency_code);
   ozf_utility_pvt.debug_message('l_currency_rec.transaction_currency_code :' || l_currency_rec.transaction_currency_code);
   ozf_utility_pvt.debug_message('l_currency_rec.association_currency_code :' || l_currency_rec.association_currency_code);
   ozf_utility_pvt.debug_message('l_currency_rec.functional_currency_code  :' || l_currency_rec.functional_currency_code);
 END IF;
  -- Modified for FXGL ER
  -- deletion also to take place in amount and not acctd_amount

  --------------------- start -----------------------
  l_del_total_amount := NVL(l_funds_util_flt.old_total_amount, 0) - NVL(l_funds_util_flt.total_amount ,0);
  l_del_total_amount := OZF_UTILITY_PVT.CurrRound(l_del_total_amount, l_currency_rec.claim_currency_code);
  l_del_total_units := NVL(l_funds_util_flt.old_total_units, 0) - NVL(l_funds_util_flt.total_units, 0);

  ------------ reduce the over-utilization first ---------
  IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
    OPEN csr_over_util(l_funds_util_flt.claim_line_id, l_funds_util_flt.activity_product_id);
    LOOP
      FETCH csr_over_util INTO l_lu_line_util_id, l_lu_amt, l_lu_scan_unit;
      EXIT WHEN csr_over_util%NOTFOUND;

      IF l_funds_util_flt.total_amount IS NULL THEN
        l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).utilization_id := -1;
        l_line_util_tbl(l_counter).amount := l_lu_amt;
        l_line_util_tbl(l_counter).scan_unit := l_lu_scan_unit;
        l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;
      ELSIF l_del_total_amount >= l_lu_acctd_amt THEN
        l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).utilization_id := -1;
        l_line_util_tbl(l_counter).amount := l_lu_amt;
        l_line_util_tbl(l_counter).scan_unit := l_lu_scan_unit;
        l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;

        l_del_total_amount := l_del_total_amount - l_lu_amt;
        l_del_total_units := l_del_total_units - l_lu_scan_unit;
      ELSE
        l_upd_line_util_rec.claim_line_util_id := l_lu_line_util_id;
        l_upd_line_util_rec.amount := l_lu_amt - l_del_total_amount;
        l_upd_line_util_rec.scan_unit := l_lu_scan_unit - l_del_total_units;

        l_del_total_amount := 0;
        l_del_total_units := 0;
      END IF;

      l_counter := l_counter + 1;

      EXIT WHEN l_del_total_amount = 0;
    END LOOP;
    CLOSE csr_over_util;
  ELSIF p_funds_util_flt.activity_type = 'OFFR' AND
        p_funds_util_flt.activity_id IS NOT NULL
  THEN
        NULL;
/* -- We do not create -2 utilizations for non scan offers currently
    OPEN csr_acc_over_util(l_funds_util_flt.claim_line_id, l_funds_util_flt.activity_id);
    LOOP
      FETCH csr_acc_over_util INTO l_lu_line_util_id, l_lu_acctd_amt;
      EXIT WHEN csr_acc_over_util%NOTFOUND;

      IF p_funds_util_flt.total_amount IS NULL THEN
        l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).utilization_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).acctd_amount := l_lu_acctd_amt;
        l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;
      ELSIF l_del_total_amount >= l_lu_acctd_amt THEN
        l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).utilization_id := l_lu_line_util_id;
        l_line_util_tbl(l_counter).acctd_amount := l_lu_acctd_amt;
        l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;

        l_del_total_amount := l_del_total_amount - l_lu_acctd_amt;
      ELSE
        l_upd_line_util_rec.claim_line_util_id := l_lu_line_util_id;
        l_upd_line_util_rec.acctd_amount := l_lu_acctd_amt - l_del_total_amount;

        l_del_total_amount := 0;
      END IF;

      l_counter := l_counter + 1;

      EXIT WHEN l_del_total_amount = 0;
    END LOOP;
    CLOSE csr_acc_over_util;
    */
  END IF;


 IF l_del_total_amount <> 0 THEN  -- added for bugfix 4448859
     Get_Utiz_Sql_Stmt(
       p_api_version         => l_api_version
      ,p_init_msg_list       => FND_API.g_false
      ,p_commit              => FND_API.g_false
      ,p_validation_level    => FND_API.g_valid_level_full
      ,x_return_status       => l_return_status
      ,x_msg_count           => x_msg_count
      ,x_msg_data            => x_msg_data
      ,p_summary_view        => 'DEL_GRP_LINE_UTIL'
      ,p_funds_util_flt      => l_funds_util_flt
      ,px_currency_rec        => l_currency_rec
      ,p_cust_account_id     => l_funds_util_flt.cust_account_id
      ,x_utiz_sql_stmt       => l_funds_util_sql
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- use FND_DSQL package for dynamic sql and bind variables
    l_funds_util_csr := DBMS_SQL.open_cursor;
    FND_DSQL.set_cursor(l_funds_util_csr);
    DBMS_SQL.parse(l_funds_util_csr, l_funds_util_sql, DBMS_SQL.native);
    DBMS_SQL.define_column(l_funds_util_csr, 1, l_lu_line_util_id);
    DBMS_SQL.define_column(l_funds_util_csr, 2, l_lu_utilization_id);
    DBMS_SQL.define_column(l_funds_util_csr, 3, l_lu_amt);
    DBMS_SQL.define_column(l_funds_util_csr, 4, l_lu_scan_unit);
    DBMS_SQL.define_column(l_funds_util_csr, 5, l_lu_currency_code, 15);
--    DBMS_SQL.define_column(l_funds_util_csr, 5, l_utiz_amount);
    FND_DSQL.do_binds;

    l_ignore := DBMS_SQL.execute(l_funds_util_csr);
    --OPEN l_funds_util_csr FOR l_funds_util_sql;
    LOOP
      /*
      FETCH l_funds_util_csr INTO l_lu_line_util_id
                              , l_lu_utilization_id
                              , l_lu_acctd_amt
                              , l_lu_scan_unit;
    EXIT WHEN l_funds_util_csr%NOTFOUND;
    */

      IF DBMS_SQL.fetch_rows(l_funds_util_csr) > 0 THEN
        DBMS_SQL.column_value(l_funds_util_csr, 1, l_lu_line_util_id);
        DBMS_SQL.column_value(l_funds_util_csr, 2, l_lu_utilization_id);
        DBMS_SQL.column_value(l_funds_util_csr, 3, l_lu_amt);
        DBMS_SQL.column_value(l_funds_util_csr, 4, l_lu_scan_unit);
        DBMS_SQL.column_value(l_funds_util_csr, 5, l_lu_currency_code);
--        DBMS_SQL.define_column(l_funds_util_csr, 5, l_utiz_amount);

        --If CLAIM and TRANSACTIONAL currencies are same, then l_utiz_amount will be
        --in TRANSACTIONAL currency otherwise it will be in FUNCTIONAL currency.
        --Changed for Claims Multicurrency ER.
        OPEN csr_utiz_amount(l_lu_line_util_id);
        FETCH csr_utiz_amount INTO l_utiz_amount;
        CLOSE csr_utiz_amount;

        IF OZF_DEBUG_LOW_ON THEN
        OZF_Utility_PVT.debug_message('l_lu_line_util_id. : '||l_lu_line_util_id);
        OZF_Utility_PVT.debug_message('l_lu_utilization_id. : '||l_lu_utilization_id);
        OZF_Utility_PVT.debug_message('l_lu_amt. : '||l_lu_amt);
        OZF_Utility_PVT.debug_message('l_utiz_amount. : '||l_utiz_amount);
        OZF_Utility_PVT.debug_message('l_del_total_amount. : '||l_del_total_amount);
        END IF;

        IF p_funds_util_flt.total_amount IS NULL THEN
           l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
           l_line_util_tbl(l_counter).utilization_id := l_lu_utilization_id;
           l_line_util_tbl(l_counter).amount := l_utiz_amount;
           IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
               l_line_util_tbl(l_counter).scan_unit := l_lu_scan_unit;
               l_line_util_tbl(l_counter).uom_code := l_funds_util_flt.uom_code;
               l_line_util_tbl(l_counter).quantity := l_funds_util_flt.quantity;
           END IF;
        l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;
        l_counter := l_counter + 1;
        ELSE
           IF ABS(l_del_total_amount) >= ABS(l_lu_amt) THEN
              l_line_util_tbl(l_counter).claim_line_util_id := l_lu_line_util_id;
              l_line_util_tbl(l_counter).utilization_id := l_lu_utilization_id;
              l_line_util_tbl(l_counter).amount := l_utiz_amount;
              IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
                  l_line_util_tbl(l_counter).scan_unit := l_lu_scan_unit;
                  l_line_util_tbl(l_counter).uom_code := l_funds_util_flt.uom_code;
                  l_line_util_tbl(l_counter).quantity := l_funds_util_flt.quantity;
                  l_del_total_units := l_del_total_units - l_lu_scan_unit;
              END IF;
              l_line_util_tbl(l_counter).claim_line_id := l_funds_util_flt.claim_line_id;

              l_del_total_amount := l_del_total_amount - l_lu_amt;

           ELSE
              l_upd_line_util_rec.claim_line_util_id := l_lu_line_util_id;
              l_upd_line_util_rec.amount := l_lu_amt - l_del_total_amount;
              IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
                   l_upd_line_util_rec.scan_unit := l_lu_scan_unit - l_del_total_units;
                   l_upd_line_util_rec.uom_code := l_funds_util_flt.uom_code;
                   l_upd_line_util_rec.quantity := l_funds_util_flt.quantity;
              END IF;

              l_funds_util_end := 'Y';
          END IF;

          l_counter := l_counter + 1;

          EXIT WHEN l_del_total_amount = 0;
          EXIT WHEN l_funds_util_end = 'Y';
      END IF;
    ELSE
     EXIT;
     END IF;
    END LOOP;
  --CLOSE l_funds_util_csr;
  DBMS_SQL.close_cursor(l_funds_util_csr);
  END IF; -- l_del_total_amount <> 0

  --------------------- 1. delete -----------------------
  i := l_line_util_tbl.FIRST;
  IF i IS NOT NULL THEN
     IF p_funds_util_flt.activity_type = 'OFFR' AND
        p_funds_util_flt.activity_id IS NOT NULL THEN
        OPEN csr_offer_currency(p_funds_util_flt.activity_id);
        FETCH csr_offer_currency INTO l_currency_rec.offer_currency_code; -- BKUNJAN Need to check where it is used ?
        CLOSE csr_offer_currency;
     END IF;

     LOOP
        IF l_line_util_tbl(i).claim_line_util_id IS NOT NULL THEN
        ozf_utility_pvt.debug_message('kd: calling Del_Line_Util_By_Group');
           Del_Line_Util_By_Group(
                 x_return_status     => l_return_status
                ,x_msg_count         => x_msg_count
                ,x_msg_data          => x_msg_data
                ,p_line_util_rec     => l_line_util_tbl(i)
                ,px_currency_rec      => l_currency_rec
           );
           IF l_return_status =  fnd_api.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;
        END IF;
     EXIT WHEN i = l_line_util_tbl.LAST;
     i := l_line_util_tbl.NEXT(i);
     END LOOP;
  END IF;

  --------------------- 2. update -----------------------
  IF (l_upd_line_util_rec.claim_line_util_id is not null
  AND l_upd_line_util_rec.claim_line_util_id <> FND_API.G_MISS_NUM) THEN
        -- Bugfix 5101106: Recalculate qty
    IF p_funds_util_flt.offer_type = 'SCAN_DATA' THEN
         OPEN csr_offer_profile(l_funds_util_flt.activity_product_id);
         FETCH csr_offer_profile INTO l_offer_uom_code
                               , l_offer_quantity
                               , l_scan_value
                               , l_product_id;
         CLOSE csr_offer_profile;
         IF l_funds_util_flt.uom_code <> l_offer_uom_code THEN
           l_upd_line_util_rec.quantity := inv_convert.inv_um_convert(
                 item_id         => l_product_id
                 ,precision       => 2
                 ,from_quantity   => l_upd_line_util_rec.scan_unit * l_offer_quantity
                 ,from_unit       => l_offer_uom_code
                 ,to_unit         => l_funds_util_flt.uom_code
                 ,from_name       => NULL
                 ,to_name         => NULL
                );
          ELSE
             l_upd_line_util_rec.quantity := l_upd_line_util_rec.scan_unit * l_offer_quantity;
          END IF;
     END IF;

     Update_Line_Util(
         p_api_version         => l_api_version
        ,p_init_msg_list       => FND_API.g_false
        ,p_commit              => FND_API.g_false
        ,p_validation_level    => FND_API.g_valid_level_full
        ,x_return_status       => l_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
        ,p_line_util_rec       => l_upd_line_util_rec
        ,x_object_version      => l_object_version_number
     );
     IF l_return_status =  fnd_api.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
     l_upd_line_util_rec.object_version_number := l_object_version_number;
  END IF;

  -- 3. update claim line earnings_associated_flag -------
  -- if there is no more earnings associated.
  OPEN csr_final_lu_amt(p_funds_util_flt.claim_line_id);
  FETCH csr_final_lu_amt INTO l_final_lu_amt;
  CLOSE csr_final_lu_amt;

  IF l_final_lu_amt = 0 OR
     l_final_lu_amt IS NULL THEN
     UPDATE ozf_claim_lines_all
       SET earnings_associated_flag = 'F'
       WHERE claim_line_id = p_funds_util_flt.claim_line_id;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Delete_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Group_Line_Util;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Delete_Group_Line_Util;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Dummy_Utilizations
--
-- HISTORY
--    10/15/2002  yizhang  Create.
--   08-Aug-06    azahmed  Modified for FXGL ER
--
---------------------------------------------------------------------
PROCEDURE Update_Dummy_Utilizations(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_commit             IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_claim_line_util_id IN  NUMBER
  ,p_mode               IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Update_Dummy_Utilizations';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);
l_error_index          NUMBER;

l_line_util_tbl       line_util_tbl_type;
l_amount_rem    NUMBER;
l_scan_unit_rem       NUMBER;
l_total_amount        NUMBER;
l_total_units         NUMBER;
l_counter             NUMBER         := 1;

l_claim_line_id       NUMBER;
l_activity_product_id NUMBER;
l_utilization_id      NUMBER;
l_uom_code            VARCHAR2(3);
l_quantity            NUMBER;
l_currency_rec        currency_rec_type;

CURSOR csr_line_util_info(cv_claim_line_util_id IN NUMBER) IS
  SELECT claim_line_id
        ,activity_product_id
        ,uom_code
        ,quantity
        ,amount
        ,scan_unit
        ,utilization_id
  FROM ozf_claim_lines_util
  WHERE claim_line_util_id = cv_claim_line_util_id;

CURSOR csr_funds_utilized(cv_activity_product_id IN NUMBER) IS
  SELECT utilization_id
        ,amount_remaining
        ,scan_unit_remaining
  FROM ozf_funds_utilized_all_vl
  WHERE activity_product_id = cv_activity_product_id
  AND   adjustment_type_id = -8
  AND   utilization_type ='ADJUSTMENT'
  AND   amount_remaining <> 0;

/*
CURSOR csr_acc_adjustment(cv_offer_id IN NUMBER) IS
  SELECT utilization_id
        ,acctd_amount_remaining
  FROM ozf_funds_utilized_all_vl
  WHERE plan_type = 'OFFR'
  AND   plan_id = cv_offer_id
  AND   adjustment_type_id = -11
  AND   utilization_type = 'ADJUSTMENT';
*/

BEGIN
  ----------------------- initialize --------------------
  SAVEPOINT Update_Dummy_Utilizations;

  IF OZF_DEBUG_HIGH_ON THEN
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

  -------------------- update -----------------------
  OPEN csr_line_util_info(p_claim_line_util_id);
  FETCH csr_line_util_info INTO l_claim_line_id
                               ,l_activity_product_id
                               ,l_uom_code
                               ,l_quantity
                               ,l_total_amount
                               ,l_total_units
                               ,l_utilization_id;
  CLOSE csr_line_util_info;

  -- associate adjustment for scan data
  -- amounts are reduced in claim currency and not in functional currency
  IF l_utilization_id = -1 THEN
    OPEN csr_funds_utilized(l_activity_product_id);
    LOOP
      FETCH csr_funds_utilized INTO l_line_util_tbl(l_counter).utilization_id
                                  , l_amount_rem
                                  , l_scan_unit_rem;
      EXIT WHEN csr_funds_utilized%NOTFOUND;
      IF l_total_amount > l_amount_rem THEN
         l_line_util_tbl(l_counter).amount := l_amount_rem;
         l_total_amount := l_total_amount - l_amount_rem;
         l_line_util_tbl(l_counter).scan_unit := l_scan_unit_rem;
         l_total_units := l_total_units - l_scan_unit_rem;
      ELSE
         l_line_util_tbl(l_counter).amount := l_total_amount;
         l_total_amount := 0;
         l_line_util_tbl(l_counter).scan_unit := l_total_units;
         l_total_units := 0;
      END IF;

      l_line_util_tbl(l_counter).claim_line_id := l_claim_line_id;
      l_line_util_tbl(l_counter).activity_product_id := l_activity_product_id;
      l_line_util_tbl(l_counter).uom_code := l_uom_code;
      l_line_util_tbl(l_counter).quantity := l_quantity;
      l_counter := l_counter + 1;
      EXIT WHEN l_total_amount = 0;
    END LOOP;
    CLOSE csr_funds_utilized;

  -- associate adjustment for accrual offer
  /*
  ELSIF l_utilization_id = -2 THEN
    OPEN csr_acc_adjustment(l_activity_product_id);
    LOOP
      FETCH csr_acc_adjustment INTO l_line_util_tbl(l_counter).utilization_id
                                  , l_acctd_amount_rem;
      EXIT WHEN csr_acc_adjustment%NOTFOUND;
      IF l_total_amount > l_acctd_amount_rem THEN
         l_line_util_tbl(l_counter).acctd_amount := l_acctd_amount_rem;
         l_total_amount := l_total_amount - l_acctd_amount_rem;
      ELSE
         l_line_util_tbl(l_counter).acctd_amount := l_total_amount;
         l_total_amount := 0;
      END IF;

      l_line_util_tbl(l_counter).claim_line_id := l_claim_line_id;
      l_counter := l_counter + 1;
      EXIT WHEN l_total_amount = 0;
    END LOOP;
    CLOSE csr_acc_adjustment;
  */
  END IF;

  -- delete dummy utilizations
  DELETE FROM ozf_claim_lines_util_all
  WHERE claim_line_util_id = p_claim_line_util_id;

  ---------- Create Group Line Utils -------------------
  --Need to check
  IF l_counter > 1 THEN
    Create_Line_Util_Tbl(
        p_api_version            => l_api_version
       ,p_init_msg_list          => FND_API.g_false
       ,p_commit                 => FND_API.g_false
       ,p_validation_level       => p_validation_level
       ,x_return_status          => l_return_status
       ,x_msg_data               => x_msg_data
       ,x_msg_count              => x_msg_count
       ,p_line_util_tbl          => l_line_util_tbl
       ,p_currency_rec           => l_currency_rec
       ,p_mode                   => p_mode
       ,x_error_index            => l_error_index
    );
    IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Update_Dummy_Utilizations;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Dummy_Utilizations;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Dummy_Utilizations;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Update_Dummy_Utilizations;

---------------------------------------------------------------------
-- PROCEDURE
--    Adjust_Fund_Utilization
--
-- HISTORY
--    10/15/2002  yizhang  Create.
--    01/15/2003  yizhang  Calling point moved from post-approval to
--                         post-closed
--    03/24/2003  yizhang  p_mode is used to indicate the calling point
--                         of the procedure.
--   16/03/06     azahmed  Bugfix 5101106
--   27/03/06     azahmed  Bugfix 5119143
---------------------------------------------------------------------
PROCEDURE Adjust_Fund_Utilization(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_commit             IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_claim_id           IN  NUMBER
  ,p_mode               IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_next_status        OUT NOCOPY VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Adjust_Fund_Utilization';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status VARCHAR2(1);

l_next_status          VARCHAR2(15) := 'CLOSED';
l_cust_account_id      NUMBER;
l_claim_line_util_id   NUMBER;
l_activity_product_id  NUMBER;
l_scan_unit            NUMBER;
l_acctd_amount         NUMBER;
l_plan_id              NUMBER;
l_fund_id              NUMBER;
l_act_budget_id        NUMBER;
l_bill_to_site_id      NUMBER;
l_ship_to_site_id      NUMBER;
l_fund_curr_code       VARCHAR2(15);
l_plan_curr_code       VARCHAR2(15);
l_adjustment_flag      VARCHAR2(1);

l_utilization_id       NUMBER;
l_total_scan_unit      NUMBER;
l_old_scan_unit_rem    NUMBER;
l_new_scan_unit_rem    NUMBER;
l_act_budgets_rec      ozf_actbudgets_pvt.act_budgets_rec_type;
l_act_util_rec         ozf_actbudgets_pvt.act_util_rec_type ;

CURSOR csr_scan_over_utilized(cv_claim_id IN NUMBER) IS
  SELECT lu.claim_line_util_id
        ,lu.activity_product_id
        ,lu.scan_unit
        ,ap.act_product_used_by_id
        ,ap.adjustment_flag
  FROM ozf_claim_lines_util lu, ams_act_products ap
      ,ozf_claim_lines cln
  WHERE cln.claim_id = cv_claim_id
  AND   lu.claim_line_id = cln.claim_line_id
  AND   lu.activity_product_id = ap.activity_product_id
  AND   lu.utilization_id = -1
  ORDER BY ap.adjustment_flag DESC;

-- cursor modified for bugfix 5101106  :  coupon count * offer quantity = quantity
-- the coupon count(scan_unit) is independent of the offer and claim uom code
CURSOR csr_line_utils(cv_claim_id IN NUMBER) IS
 SELECT SUM(lu.scan_unit * amp.quantity)
        ,lu.utilization_id
  FROM  ozf_claim_lines_util_all lu
       ,ozf_claim_lines_all cln
       ,ams_act_products amp
  WHERE cln.claim_id = cv_claim_id
  AND   lu.claim_line_id = cln.claim_line_id
  AND   lu.activity_product_id = amp.activity_product_id
  GROUP BY lu.utilization_id;

--modified for bugfix 5119143
CURSOR csr_claim_info(cv_claim_id IN NUMBER) IS
select CUST_ACCOUNT_ID , CUST_BILLTO_ACCT_SITE_ID ,  CUST_SHIPTO_ACCT_SITE_ID
from ozf_claims_all
where claim_id = cv_claim_id;


BEGIN
  ----------------------- initialize --------------------
  SAVEPOINT Adjust_Fund_Utilization;

  IF OZF_DEBUG_HIGH_ON THEN
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

  -- initialized x_next_status; Settlement process needs to be contine if there is no
  -- associated earnings attached to claim line.
  x_next_status := 'CLOSED';

  ------------------ dummy utilizations -------------------
 IF p_mode = 'ADJ_FUND' THEN
  -- create adjustment for scan data offers
  OPEN csr_scan_over_utilized(p_claim_id);
  LOOP
    FETCH csr_scan_over_utilized INTO l_claim_line_util_id
                                ,l_activity_product_id
                                ,l_scan_unit
                                ,l_plan_id
                                ,l_adjustment_flag;
    EXIT WHEN csr_scan_over_utilized%NOTFOUND;

    --Bugfix 5119143 get customer Info
    OPEN csr_claim_info(p_claim_id);
    FETCH csr_claim_info INTO l_cust_account_id , l_bill_to_site_id  , l_ship_to_site_id ;
    CLOSE csr_claim_info;

    IF l_adjustment_flag = 'Y' THEN
      --modified for Bugfix 5119143
      Ozf_Fund_Adjustment_Pvt.adjust_utilized_budget(
       p_claim_id             => p_claim_id
      ,p_offer_id             => l_plan_id
      ,p_product_activity_id  => l_activity_product_id
      ,p_amount               => l_scan_unit
      ,p_cust_acct_id         => l_cust_account_id
      ,p_bill_to_cust_acct_id => l_cust_account_id
      ,p_bill_to_site_use_id  => l_bill_to_site_id
      ,p_ship_to_site_use_id  => l_ship_to_site_id
      ,p_api_version          => l_api_version
      ,p_init_msg_list        => FND_API.g_false
      ,p_commit               => FND_API.g_false
      ,x_msg_count            => x_msg_count
      ,x_msg_data             => x_msg_data
      ,x_return_status        => l_return_status
      );
      IF l_return_status =  fnd_api.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      Update_Dummy_Utilizations(
          p_api_version          => l_api_version
         ,p_init_msg_list        => FND_API.g_false
         ,p_commit               => FND_API.g_false
         ,p_validation_level     => p_validation_level
         ,x_return_status        => l_return_status
         ,x_msg_count            => x_msg_count
         ,x_msg_data             => x_msg_data
         ,p_claim_line_util_id   => l_claim_line_util_id
         ,p_mode                 => p_mode
      );
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_next_status := 'CLOSED';
    ELSE
      x_next_status := 'PENDING_CLOSED';

      -- yizhang: 15-JAN-2003: should we decide to support adjustment workflow, we need to
      --          change the settlement fetcher process
      -- mchang: As of 24-OCT-2002, we don't support manual adjust over utilization. TM raise
      --         error everytime if ams_act_products.adjustment_flag is 'N'.
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Manual Adjust Over Utilization is not supported.');
         FND_MSG_PUB.Add;
      END IF;

      RAISE FND_API.g_exc_unexpected_error;
      --Invoke_Adjustment_Workflow();
    END IF;

  END LOOP;
  CLOSE csr_scan_over_utilized;
 ELSIF p_mode = 'UPD_SCAN' THEN
  ----------------- update scan_unit_remaining -------------------
   --modified for bugfix 5101106
  OPEN csr_line_utils(p_claim_id);
  LOOP
    FETCH csr_line_utils INTO l_total_scan_unit
                             ,l_utilization_id
;

    EXIT WHEN csr_line_utils%NOTFOUND;

    IF l_total_scan_unit IS NOT NULL THEN

        UPDATE ozf_funds_utilized_all_b
        SET scan_unit_remaining =   scan_unit_remaining - l_total_scan_unit
        WHERE utilization_id = l_utilization_id;
    END IF;

  END LOOP;
  CLOSE csr_line_utils;
 END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Adjust_Fund_Utilization;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Adjust_Fund_Utilization;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Adjust_Fund_Utilization;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Adjust_Fund_Utilization;
---------------------------------------------------------------------
-- FUNCTION
--    Calculate_FXGL_Amount
--
-- PURPOSE
--    Returns FXGL amount of the claim line util
--
-- PARAMETERS
--
--
-- NOTES
-- created by azahmed For FXGL ER:
-- 16-04-2009  psomyaju  Modified for Multicurrency ER.
---------------------------------------------------------------------
FUNCTION Calculate_FXGL_Amount(
   p_line_util_rec       IN  line_util_rec_type
  ,p_currency_rec        IN  currency_rec_type
) RETURN NUMBER
IS

CURSOR csr_funds_util_details(cv_utilization_id IN NUMBER) IS
  SELECT exchange_rate_type
       , exchange_rate_date
       , exchange_rate
  FROM   ozf_funds_utilized_all_b
  WHERE  utilization_id = cv_utilization_id;

l_fu_plan_currency_code   VARCHAR2(15);
l_fu_exc_rate             NUMBER;
l_fu_exc_date             DATE;
l_fu_exc_type             VARCHAR2(30);
l_return_status           VARCHAR2(1);
l_utilized_amount         NUMBER := 0;
l_fxgl_acctd_amount       NUMBER := 0;
l_fu_plan_amount          NUMBER := 0;

BEGIN

   IF p_currency_rec.claim_currency_code = p_currency_rec.transaction_currency_code AND
      p_currency_rec.claim_currency_code <> p_currency_rec.functional_currency_code
   THEN

      OPEN csr_funds_util_details(p_line_util_rec.utilization_id);
      FETCH csr_funds_util_details INTO l_fu_exc_type, l_fu_exc_date, l_fu_exc_rate;
      CLOSE csr_funds_util_details;


        IF p_line_util_rec.exchange_rate <> l_fu_exc_rate AND l_fu_exc_rate IS NOT NULL THEN
               OZF_UTILITY_PVT.Convert_Currency(
                 p_from_currency   => p_currency_rec.transaction_currency_code
                ,p_to_currency     => p_currency_rec.functional_currency_code
                ,p_conv_type       => l_fu_exc_type
                ,p_conv_date       => l_fu_exc_date
                ,p_from_amount     => p_line_util_rec.amount
                ,x_return_status   => l_return_status
                ,x_to_amount       => l_utilized_amount
                ,x_rate            => l_fu_exc_rate
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                      RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
        END IF;
        l_fxgl_acctd_amount := p_line_util_rec.acctd_amount - l_utilized_amount;

      END IF;
   ELSE
      l_fxgl_acctd_amount := 0;
   END IF;


      RETURN l_fxgl_acctd_amount;
END Calculate_FXGL_Amount;


---------------------------------------------------------------------
-- FUNCTION
--    Perform_Approval_Required
--
-- PURPOSE
--    Returns TRUE if the claim requires performance approval.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Perform_Approval_Required(
   p_claim_id           IN  NUMBER
) RETURN VARCHAR2
IS

l_offer_id               NUMBER;
l_cust_account_id        NUMBER;
l_performance_flag       VARCHAR2(1);
l_resale_flag            VARCHAR2(1);
l_offer_perf_tbl         offer_performance_tbl_type;
l_activity_type          VARCHAR2(30);
l_perf_appr_require      VARCHAR2(1);
l_cust_setup_id          NUMBER;

CURSOR csr_line_util(cv_claim_id IN NUMBER) IS
  SELECT fu.plan_id, fu.cust_account_id, ln.activity_type
  FROM ozf_claim_lines_util lu, ozf_funds_utilized_all_b fu, ozf_claim_lines ln
  WHERE lu.utilization_id = fu.utilization_id
  AND lu.claim_line_id = ln.claim_line_id
  AND ln.claim_id = cv_claim_id
  GROUP BY fu.plan_id, fu.cust_account_id, ln.activity_type;

CURSOR csr_claim_setup_info(cv_claim_id IN NUMBER) IS
  SELECT custom_setup_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_claim_perf_req_attr(cv_custom_setup_id IN NUMBER) IS
  SELECT NVL(attr_available_flag, 'N')
  FROM ams_custom_setup_attr
  WHERE custom_setup_id = cv_custom_setup_id
  AND object_attribute = 'PAPR';

BEGIN

   -- Fix for bug 5177341
  OPEN csr_claim_setup_info(p_claim_id);
  FETCH csr_claim_setup_info INTO l_cust_setup_id;
  CLOSE csr_claim_setup_info;

  OPEN csr_claim_perf_req_attr(l_cust_setup_id);
  FETCH csr_claim_perf_req_attr INTO l_perf_appr_require;
  CLOSE csr_claim_perf_req_attr;

  -- Approval is not required if claim performance approval is false
  -- in Claim Custom set up.
  IF l_perf_appr_require = 'N' THEN
      RETURN FND_API.g_false;
  END IF;

   -- Approval is not required if override profile is Yes
   IF FND_PROFILE.VALUE('OZF_OFFR_OVERRIDE_PERF_FLAG') = 'Y' THEN
      RETURN FND_API.g_false;
   END IF;

   OPEN csr_line_util(p_claim_id);
   LOOP
      FETCH csr_line_util INTO l_offer_id, l_cust_account_id, l_activity_type;
      EXIT WHEN csr_line_util%NOTFOUND;

      -- check resale data for speical pricing requests
      IF l_activity_type = 'SPECIAL_PRICE' THEN
         l_resale_flag := 'T';
      ELSE
         l_resale_flag := 'F';
      END IF;

      IF l_offer_id IS NOT NULL AND l_cust_account_id IS NOT NULL THEN
         Check_Offer_Performance(
             p_cust_account_id      => l_cust_account_id
            ,p_offer_id             => l_offer_id
            ,p_resale_flag          => l_resale_flag
            ,p_check_all_flag       => 'F'
            ,x_performance_flag     => l_performance_flag
            ,x_offer_perf_tbl       => l_offer_perf_tbl
         );

         IF l_performance_flag = FND_API.g_false THEN
            -- update ozf_claims.approved_flag
            UPDATE ozf_claims_all
            SET approved_flag = 'F'
            WHERE claim_id = p_claim_id;

            RETURN FND_API.g_true;
         END IF;
      END IF;
   END LOOP;
   CLOSE csr_line_util;

   -- update ozf_claims.approved_flag
   UPDATE ozf_claims_all
   SET approved_flag = 'T'
   WHERE claim_id = p_claim_id;

   RETURN FND_API.g_false;
END Perform_Approval_Required;


---------------------------------------------------------------------
-- FUNCTION
--    Earnings_Approval_Required
--
-- PURPOSE
--    Returns TRUE if the claim requires earnings approval.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Earnings_Approval_Required(
   p_claim_id           IN  NUMBER
) RETURN VARCHAR2
IS

l_cust_account_id            NUMBER;
l_un_earned_pay_thold_type   VARCHAR2(30);
l_un_earned_pay_thold_amount NUMBER;
l_plan_id                    NUMBER;
l_amount_claim_asso          NUMBER;
l_amount_earned              NUMBER;
l_amount_remaining           NUMBER;
l_amount_threshold           NUMBER;
l_util_cust_account_id       NUMBER;
l_un_earned_pay_thold_flag   VARCHAR2(1) := 'F';
l_currOrgId                  NUMBER     := MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_claim_info(cv_claim_id IN NUMBER) IS
  SELECT cust_account_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_cust_trd_prfl_info(cv_cust_account_id IN NUMBER) IS
  SELECT un_earned_pay_thold_type, un_earned_pay_thold_amount, un_earned_pay_thold_flag
  FROM ozf_cust_trd_prfls
  WHERE cust_account_id = cv_cust_account_id;

CURSOR csr_pty_trd_prfl_info(cv_cust_account_id IN NUMBER) IS
  SELECT p.un_earned_pay_thold_type, p.un_earned_pay_thold_amount, p.un_earned_pay_thold_flag
  FROM ozf_cust_trd_prfls p, hz_cust_accounts c
  WHERE p.party_id = c.party_id
  AND p.cust_account_id IS NULL
  AND c.cust_account_id = cv_cust_account_id;

 -- fix for bug 5042046
CURSOR csr_sys_param_info IS
  SELECT un_earned_pay_thold_type, un_earned_pay_thold_amount, un_earned_pay_thold_flag
  FROM ozf_sys_parameters
  WHERE  org_id = l_currOrgId;

CURSOR csr_line_util(cv_claim_id IN NUMBER) IS
  SELECT fu.plan_id, fu.cust_account_id, sum(lu.acctd_amount)
  FROM ozf_claim_lines_util lu, ozf_funds_utilized_all_b fu
     , ozf_claim_lines ln
  WHERE lu.utilization_id = fu.utilization_id
  AND lu.claim_line_id = ln.claim_line_id
  AND ln.claim_id = cv_claim_id
  GROUP BY fu.plan_id, fu.cust_account_id;

CURSOR csr_funds_util(cv_cust_account_id IN NUMBER, cv_plan_id IN NUMBER) IS
  SELECT sum(acctd_amount), sum(acctd_amount_remaining)
  FROM ozf_funds_utilized_all_b
  WHERE utilization_type in ('ACCRUAL', 'ADJUSTMENT')
  AND org_id = l_currOrgId
  AND gl_posted_flag = 'Y'
  AND plan_type = 'OFFR'
  AND plan_id = cv_plan_id
  AND cust_account_id = cv_cust_account_id;

BEGIN
   -- get claim info
   OPEN csr_claim_info(p_claim_id);
   FETCH csr_claim_info INTO l_cust_account_id;
   CLOSE csr_claim_info;

   l_un_earned_pay_thold_type := NULL;
   l_un_earned_pay_thold_amount := NULL;

   OPEN csr_cust_trd_prfl_info(l_cust_account_id);
   FETCH csr_cust_trd_prfl_info INTO l_un_earned_pay_thold_type,
                                     l_un_earned_pay_thold_amount,
                                     l_un_earned_pay_thold_flag;
   CLOSE csr_cust_trd_prfl_info;

   IF l_un_earned_pay_thold_type IS NULL THEN
      OPEN csr_pty_trd_prfl_info(l_cust_account_id);
      FETCH csr_pty_trd_prfl_info INTO l_un_earned_pay_thold_type,
                                       l_un_earned_pay_thold_amount,
                                       l_un_earned_pay_thold_flag;
      CLOSE csr_pty_trd_prfl_info;

      IF l_un_earned_pay_thold_type IS NULL THEN
         OPEN csr_sys_param_info;
         FETCH csr_sys_param_info INTO l_un_earned_pay_thold_type,
                                       l_un_earned_pay_thold_amount,
                                       l_un_earned_pay_thold_flag;
         CLOSE csr_sys_param_info;
      END IF;
   END IF;

   -- Fix for bug 5177341
   IF l_un_earned_pay_thold_type = 'UNCONDITIONAL' OR
           l_un_earned_pay_thold_flag = 'F' THEN
      RETURN FND_API.g_false;
   END IF;

   OPEN csr_line_util(p_claim_id);
   LOOP
      FETCH csr_line_util INTO l_plan_id,
                               l_util_cust_account_id,
                               l_amount_claim_asso;
      EXIT WHEN csr_line_util%NOTFOUND;

      OPEN csr_funds_util(l_util_cust_account_id, l_plan_id);
      FETCH csr_funds_util INTO l_amount_earned, l_amount_remaining;
      CLOSE csr_funds_util;

      --Fix for bug 7527018
      IF l_amount_remaining < 0 THEN
         IF l_un_earned_pay_thold_type = 'PERCENT' THEN
            l_amount_threshold := l_amount_earned * (l_un_earned_pay_thold_amount / 100.0);
         ELSE
            l_amount_threshold := l_un_earned_pay_thold_amount;
         END IF;

         --Fix for bug 7527018
         IF ABS(l_amount_remaining) > l_amount_threshold THEN
            RETURN FND_API.g_true;
         END IF;
      END IF;
   END LOOP;
   CLOSE csr_line_util;

   RETURN FND_API.g_false;
END Earnings_Approval_Required;


---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Performance_Tbl
--
-- PURPOSE
--    For the associated earnings in the given claim, find the offer
--    performance requirements that the customer has not met.
--
-- PARAMETERS
--    p_claim_id          : customer account id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Performance_Tbl(
   p_claim_id                  IN  NUMBER

  ,x_offer_perf_tbl            OUT NOCOPY offer_performance_tbl_type
)
IS

l_offer_id               NUMBER;
l_cust_account_id        NUMBER;
l_performance_flag       VARCHAR2(1);
l_resale_flag            VARCHAR2(1);
l_offer_perf_tbl         offer_performance_tbl_type;
l_x_offer_perf_tbl       offer_performance_tbl_type;
l_activity_type          VARCHAR2(30);
l_counter                PLS_INTEGER := 0;

CURSOR csr_line_util(cv_claim_id IN NUMBER) IS
  SELECT fu.plan_id, fu.cust_account_id, ln.activity_type
  FROM ozf_claim_lines_util lu, ozf_funds_utilized_all_b fu, ozf_claim_lines ln
  WHERE lu.utilization_id = fu.utilization_id
  AND lu.claim_line_id = ln.claim_line_id
  AND ln.claim_id = cv_claim_id
  GROUP BY fu.plan_id, fu.cust_account_id, ln.activity_type;

BEGIN
   OPEN csr_line_util(p_claim_id);
   LOOP
      FETCH csr_line_util INTO l_offer_id, l_cust_account_id, l_activity_type;
      EXIT WHEN csr_line_util%NOTFOUND;

      -- check resale data for speical pricing requests
      IF l_activity_type = 'SPECIAL_PRICE' THEN
         l_resale_flag := 'T';
      ELSE
         l_resale_flag := 'F';
      END IF;

      IF l_offer_id IS NOT NULL AND l_cust_account_id IS NOT NULL THEN
         Check_Offer_Performance(
             p_cust_account_id      => l_cust_account_id
            ,p_offer_id             => l_offer_id
            ,p_resale_flag          => l_resale_flag
            ,p_check_all_flag       => 'F'
            ,x_performance_flag     => l_performance_flag
            ,x_offer_perf_tbl       => l_offer_perf_tbl
         );

         IF l_performance_flag = FND_API.g_false AND
            l_offer_perf_tbl.count > 0
         THEN
            FOR j IN l_offer_perf_tbl.FIRST..l_offer_perf_tbl.LAST LOOP
               l_counter := l_counter + 1;
               l_x_offer_perf_tbl(l_counter) := l_offer_perf_tbl(j);
            END LOOP;
         END IF;
      END IF;
   END LOOP;
   CLOSE csr_line_util;

   x_offer_perf_tbl := l_x_offer_perf_tbl;
END Check_Offer_Performance_Tbl;


---------------------------------------------------------------------
-- PROCEDURE
--   Check_Offer_Earning_Tbl
--
-- PURPOSE
--    For the associated earnings in the given claim, find the offers
--    whose paid amount is greater than the available amount
--
-- PARAMETERS
--    p_claim_id          : customer account id
--
-- HISTORY
---------------------------------------------------------------------
PROCEDURE Check_Offer_Earning_Tbl(
   p_claim_id                  IN  NUMBER

  ,x_offer_earn_tbl            OUT NOCOPY offer_earning_tbl_type
)
IS
l_plan_id                    NUMBER;
l_acctd_amount               NUMBER;
l_counter                    PLS_INTEGER := 0;

CURSOR csr_pay_over_earn(cv_claim_id IN NUMBER) IS
  SELECT lu.activity_product_id, sum(lu.acctd_amount)
  FROM ozf_claim_lines_util lu, ozf_claim_lines ln
  WHERE lu.claim_line_id = ln.claim_line_id
  AND lu.utilization_id = -2
  AND ln.claim_id = cv_claim_id
  GROUP BY lu.activity_product_id;

BEGIN
   OPEN csr_pay_over_earn(p_claim_id);
   LOOP
      FETCH csr_pay_over_earn INTO l_plan_id, l_acctd_amount;
      EXIT WHEN csr_pay_over_earn%NOTFOUND;

      l_counter := l_counter + 1;
      x_offer_earn_tbl(l_counter).offer_id := l_plan_id;
      x_offer_earn_tbl(l_counter).acctd_amount_over := l_acctd_amount;

   END LOOP;
   CLOSE csr_pay_over_earn;

END Check_Offer_Earning_Tbl;

---------------------------------------------------------------------
-- PROCEDURE
--   Initiate_SD_Payment
--   R12.1 Enhancements
--
-- PARAMETERS
--    p_ship_debit_id   : Ship - Debit Request/Batch Id
--    p_ship_debit_type : Request Type (SUPPLIER/INTERNAL)
--    p_claim_number    : For SUPPLIER type ONLY
--
-- NOTE
--   Functionally, each request/batch will create only one claim at a time.
--   Although, this API is designed to create multiple claims for each S-D
--   request/batch process.
--
-- HISTORY
--   19-OCT-2007  psomyaju  Created.
---------------------------------------------------------------------

PROCEDURE Initiate_SD_Payment(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,p_ship_debit_id       IN  NUMBER
  ,p_ship_debit_type     IN  VARCHAR2
  ,x_claim_id            OUT NOCOPY NUMBER
)
IS
l_api_version                   CONSTANT NUMBER       := 1.0;
l_api_name                      CONSTANT VARCHAR2(30) := 'Initiate_SD_Payment';
l_full_name                     CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status                 VARCHAR2(1);

l_cust_account_id               NUMBER;
l_product_id                    NUMBER;
l_total_amount                  NUMBER   := 0;
l_claim_id                      NUMBER;
l_payment_method                VARCHAR2(30);
l_cust_billto_acct_site_id      NUMBER;
l_claim_line_id                 NUMBER;
l_counter                       PLS_INTEGER := 1;
l_error_index                   NUMBER;
l_activity_type                 VARCHAR2(30);
l_activity_id                   NUMBER;
l_bill_to_site_id               NUMBER;
l_product_level_type            VARCHAR2(30);
l_amount                        NUMBER;
l_amount_offr_curr              NUMBER;
l_batch_id                      NUMBER;
l_source_object_class           VARCHAR2(30);
l_claim_number                  VARCHAR2(30);
l_rec_num                       NUMBER := 1;
l_check                         NUMBER := 0;
l_batch_type                    VARCHAR2(30);
l_resource_id                   NUMBER;
l_access_id                     NUMBER;
l_claim_currency_code           VARCHAR2(15);
l_rate                          NUMBER;
l_trans_currency_code           VARCHAR2(15);
l_sd_org_id                     NUMBER;
l_func_currency_code            VARCHAR2(15);
l_acctd_amount                  NUMBER := 0;
l_exchange_rate_type            VARCHAR2(30);
l_conv_exc_rate                 NUMBER;

--Vendor details added for bug 6921727
l_vendor_id                     NUMBER;
l_vendor_site_id                NUMBER;

--Claim lines with/without grouping w.r.t. SDR/Product - Bugfix 7811671
l_sd_claim_lines_grouping       VARCHAR2(30) := NVL(FND_PROFILE.VALUE('OZF_SD_CLAIM_LINES_GROUPING'),'Y');
l_batch_line_id                 NUMBER;

l_funds_util_flt                ozf_claim_accrual_pvt.funds_util_flt_type;
l_claim_rec                     OZF_CLAIM_PVT.claim_rec_type;
l_line_tbl                      OZF_CLAIM_LINE_PVT.claim_line_tbl_type;
l_access_rec                    ams_access_pvt.access_rec_type;

--User details added for bug 7578152
l_resp_name                     VARCHAR2(100) := 'Oracle Trade Management User';
l_appl_id                       NUMBER;
l_resp_id                       NUMBER;
l_user_id                       NUMBER;

TYPE cust_util_rec_type IS RECORD
( cust_account_id   NUMBER
, bill_to_site_id   NUMBER
, claim_number      VARCHAR2(30)
);

TYPE cust_util_tbl_type is TABLE OF cust_util_rec_type
INDEX BY BINARY_INTEGER;

l_cust_util_tbl  cust_util_tbl_type;

CURSOR csr_uom_code(cv_item_id IN NUMBER) IS
  SELECT  ms.primary_uom_code
  FROM    mtl_system_items ms
        , mtl_parameters mp
        , org_organization_definitions ood
  WHERE  ms.inventory_item_id = cv_item_id
    AND  ms.organization_id = mp.organization_id
    AND  mp.organization_id = mp.master_organization_Id
    AND  mp.organization_id = ood.organization_id
    AND  ood.operating_unit = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_req_uom_code ( cv_request_id IN NUMBER
                        , cv_product_id IN NUMBER
                        ) IS
  SELECT item_uom
  FROM   ozf_sd_request_lines_all
  WHERE  request_header_id = cv_request_id
    AND  inventory_item_id = cv_product_id;

CURSOR csr_batch_uom_code ( cv_batch_id IN NUMBER
                          , cv_product_id IN NUMBER
                          ) IS
  SELECT shipped_quantity_uom
  FROM   ozf_sd_batch_lines_all
  WHERE  batch_id = cv_batch_id
    AND  item_id = cv_product_id;

--Bugfix:7169388
--For associate earnings, claim amount and not functional amount
--should be use.
--Bugfix:7231613
--For associate earnings, accrual currency must be passed. Derived
--it from budget currency as for Ship-Debit, offer sourced from
--single budget retrieved from profile.
/* ER 9226258
CURSOR csr_claim_lines(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
       , activity_type
       , activity_id
       , item_type
       , item_id
--     , acctd_amount
       , amount                             --7169388
       , fund.approved_in_currency          --7231613  --//SD MC
  FROM   ozf_claim_lines_all lines
       , ozf_offers offr
       , ozf_act_budgets fund
       , ozf_sd_request_headers_all_b req
  WHERE  claim_id = cv_claim_id
    AND  lines.activity_id = req.request_header_id
    AND  req.offer_id = offr.qp_list_header_id
    AND  offr.qp_list_header_id = fund.act_budget_used_by_id
    AND  arc_act_budget_used_by = 'OFFR'
    AND  transfer_type = 'REQUEST';
*/
--// ER 9226258 - Modified
CURSOR csr_claim_lines(cv_claim_id IN NUMBER) IS
  SELECT lines.claim_line_id
       , lines.activity_type
       , lines.activity_id
       , lines.item_type
       , lines.item_id
       , lines.amount
       , offr.transaction_currency_code
  FROM   ozf_claim_lines_all lines
       , ozf_offers offr
       , ozf_sd_request_headers_all_b req
  WHERE  claim_id = cv_claim_id
    AND  lines.activity_id = req.request_header_id
    AND  req.offer_id = offr.qp_list_header_id;

--Added created_by for bug 7578152
CURSOR csr_request_currency(cv_request_id IN NUMBER) IS
  SELECT request_currency_code, org_id, created_by
  FROM   ozf_sd_request_headers_all_b
  WHERE  request_header_id = cv_request_id;

CURSOR csr_request_header(cv_request_id IN NUMBER) IS
  SELECT  DISTINCT
          util.cust_account_id
        , util.bill_to_site_use_id
  FROM    ozf_funds_utilized_all_b util
  WHERE   util.reference_id = cv_request_id;

--RMA (-ive accruals) support for bugfix: 6913855
CURSOR csr_request_lines(cv_request_id IN NUMBER
                        ,cv_cust_account_id IN NUMBER
                        ,cv_bill_to_site_id IN NUMBER) IS
  SELECT  cust_account_id
        , reference_type
        , reference_id
        , bill_to_site_use_id
        , product_level_type
        , product_id
        , exchange_rate_type
        , SUM(plan_curr_amount_remaining)
        , SUM(acctd_amount_remaining) --// ER 9226258
  FROM    ozf_funds_utilized_all_b
  WHERE   reference_id = cv_request_id
    AND   cust_account_id = cv_cust_account_id
    AND   NVL(bill_to_site_use_id,1) = NVL(cv_bill_to_site_id,1)
    AND   reference_type = 'SD_REQUEST'
    AND   gl_posted_flag = 'Y'
  GROUP BY
          cust_account_id
        , reference_type
        , reference_id
        , bill_to_site_use_id
        , product_level_type
        , product_id
        , exchange_rate_type;

CURSOR cur_offer_currency(cv_request_id IN NUMBER) IS
  SELECT  offr.transaction_currency_code
  FROM    ozf_sd_request_headers_all_b req
        , ozf_offers offr
  WHERE   offr.qp_list_header_id = req.offer_id
    AND   req.request_header_id = cv_request_id;

--Vendor details added for bug 6921727
--Added created_by for bug 7578152
CURSOR csr_batch_currency(cv_batch_id IN NUMBER) IS
  SELECT currency_code, org_id, vendor_id, vendor_site_id, created_by
  FROM   ozf_sd_batch_headers_all
  WHERE  batch_id = cv_batch_id;

CURSOR csr_batch_header(cv_batch_id IN NUMBER) IS
  SELECT  DISTINCT
          util.cust_account_id
        , util.bill_to_site_use_id
        , head.claim_number
  FROM    ozf_funds_utilized_all_b util
        , ozf_sd_batch_headers_all head
        , ozf_sd_batch_lines_all   line
  WHERE   head.batch_id = cv_batch_id
    AND   head.batch_id = line.batch_id
    AND   util.utilization_id = line.utilization_id;

CURSOR csr_batch_lines(cv_batch_id IN NUMBER
                      ,cv_cust_account_id IN NUMBER
                      ,cv_bill_to_site_id IN NUMBER) IS
  SELECT   util.cust_account_id
         , util.reference_type
         , util.reference_id
         , util.bill_to_site_use_id
         , util.product_level_type
         , util.product_id
         , sum(line.batch_curr_claim_amount)
  FROM     ozf_funds_utilized_all_b     util
         , ozf_sd_batch_lines_all       line
  WHERE    line.batch_id = cv_batch_id
    AND    util.cust_account_id = cv_cust_account_id
    AND    NVL(util.bill_to_site_use_id,1) = NVL(cv_bill_to_site_id,1)
    AND    util.utilization_id = line.utilization_id
  GROUP BY cust_account_id
         , bill_to_site_use_id
         , reference_type
         , reference_id
         , product_level_type
         , product_id;

--Added for bugfix 7811671
CURSOR csr_batch_nongrp_lines(cv_batch_id IN NUMBER
                             ,cv_cust_account_id IN NUMBER
                             ,cv_bill_to_site_id IN NUMBER) IS
  SELECT   util.cust_account_id
         , util.reference_type
         , util.reference_id
         , util.bill_to_site_use_id
         , util.product_level_type
         , util.product_id
         , line.batch_curr_claim_amount
         , line.batch_line_id
  FROM     ozf_funds_utilized_all_b     util
         , ozf_sd_batch_lines_all       line
  WHERE    line.batch_id = cv_batch_id
    AND    util.cust_account_id = cv_cust_account_id
    AND    NVL(util.bill_to_site_use_id,1) = NVL(cv_bill_to_site_id,1)
    AND    util.utilization_id = line.utilization_id;

CURSOR csr_access(cv_claim_id IN NUMBER) IS
  SELECT  resource_id
  FROM    ozf_sd_request_access req
        , ozf_claim_lines       line
        , ozf_claims            cla
  WHERE   cla.claim_id = cv_claim_id
    AND   cla.claim_id = line.claim_id
    AND   line.activity_id = req.request_header_id
    AND   req.enabled_flag = 'Y'
    AND   NOT EXISTS ( SELECT NULL
                       FROM   ams_act_access
                       WHERE  user_or_role_id = req.resource_id
                         AND  arc_user_or_role_type = 'USER'
                         AND  arc_act_access_to_object = 'CLAM'
                      );

--Added csr_resp for bug 7578152
CURSOR csr_resp IS
  SELECT application_id, responsibility_id
  FROM   fnd_responsibility_vl
  WHERE  responsibility_name = l_resp_name;

--// ER 9226258 : to get the functional currency
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
       , ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
   AND  org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Initiate_SD_Payment;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': start');
     OZF_Utility_PVT.debug_message('p_ship_debit_id : '||p_ship_debit_id);
     OZF_Utility_PVT.debug_message('p_ship_debit_type : '||p_ship_debit_type);
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

  ----------------- Process batch ----------------

  IF p_ship_debit_id IS NULL OR p_ship_debit_type IS NULL THEN
    RETURN;
  END IF;

  --Added csr_resp for bug 7578152
  OPEN  csr_resp;
  FETCH csr_resp INTO l_appl_id, l_resp_id;
  CLOSE csr_resp;

  IF p_ship_debit_type = 'INTERNAL' THEN

  --Defaulting values for INTERNAL claim
        l_payment_method := 'ACCOUNTING_ONLY';
        l_source_object_class := 'SD_INTERNAL';
        l_batch_id := NULL;
        l_batch_type := NULL;

  --For INTERNAL claims, claim currency will be request header currency
  --Added l_user_id for bug 7578152
        OPEN  csr_request_currency(p_ship_debit_id);
        FETCH csr_request_currency INTO l_claim_currency_code, l_sd_org_id, l_user_id;
        CLOSE csr_request_currency;

  --For supplied request, get customer account/bill to site combinations of
  --qualified accruals
        IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('bill_to_site_id duplicate check verification on following cust_account_id/bill_to_site_id');
        END IF;

        OPEN csr_request_header(p_ship_debit_id);
        LOOP
         FETCH csr_request_header INTO  l_cust_util_tbl(l_counter).cust_account_id
                                       ,l_cust_util_tbl(l_counter).bill_to_site_id;

         EXIT WHEN csr_request_header%NOTFOUND;

         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('cust_account_id : '||l_cust_util_tbl(l_counter).cust_account_id);
            OZF_Utility_PVT.debug_message('bill_to_site_id : '||l_cust_util_tbl(l_counter).bill_to_site_id);
         END IF;

         l_counter := l_counter + 1;
        END LOOP;
        CLOSE csr_request_header;

  ELSIF p_ship_debit_type = 'SUPPLIER' THEN

  --Default values for SUPPLIER claim
        l_payment_method := 'AP_DEBIT';
        l_source_object_class := 'SD_SUPPLIER';
        l_batch_id := p_ship_debit_id;
        l_batch_type := 'SD_BATCH';

  --For SUPPLIER claims, claim currency will be batch header currency
  --Vendor details added for bug 6921727
  --Added l_user_id for bug 7578152
        OPEN  csr_batch_currency(p_ship_debit_id);
        FETCH csr_batch_currency INTO l_claim_currency_code, l_sd_org_id, l_vendor_id, l_vendor_site_id, l_user_id;
        CLOSE csr_batch_currency;

  --For supplied batch_id, get customer accounts, respective bill to site id and
  --claim number defined in batch header. If claim number doesn't exists, system
  --will use default claim number generation mechanism.

        IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('bill_to_site_id duplicate check verification on following cust_account_id/bill_to_site_id');
        END IF;

        OPEN csr_batch_header(p_ship_debit_id);
        LOOP
         FETCH csr_batch_header INTO  l_cust_util_tbl(l_counter).cust_account_id
                                    , l_cust_util_tbl(l_counter).bill_to_site_id
                                    , l_cust_util_tbl(l_counter).claim_number;
         EXIT WHEN csr_batch_header%NOTFOUND;

         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('cust_account_id : '||l_cust_util_tbl(l_counter).cust_account_id);
            OZF_Utility_PVT.debug_message('bill_to_site_id : '||l_cust_util_tbl(l_counter).bill_to_site_id);
            OZF_Utility_PVT.debug_message('claim_number : '||l_cust_util_tbl(l_counter).claim_number);
         END IF;

         l_counter := l_counter + 1;
        END LOOP;
        CLOSE csr_batch_header;

  END IF;

  --Initialization of organization context
  MO_GLOBAL.init('OZF');
  MO_GLOBAL.set_policy_context('S', l_sd_org_id);

  -- Initialization added for bug 7578152
  IF Nvl(fnd_global.user_id,-1) IN (0,-1) THEN
    FND_GLOBAL.APPS_INITIALIZE(l_user_id, l_resp_id, l_appl_id);
  END IF;

  OZF_Utility_PVT.debug_message('Org Id : OZF_CLAIM_ACCRUAL_PVT - '||MO_GLOBAL.GET_CURRENT_ORG_ID());
  OZF_Utility_PVT.debug_message('User Id : OZF_CLAIM_ACCRUAL_PVT - '||fnd_global.user_id);

  IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_payment_method : '||l_payment_method);
        OZF_Utility_PVT.debug_message('l_source_object_class : '||l_source_object_class);
        OZF_Utility_PVT.debug_message('l_batch_id : '||l_batch_id);
        OZF_Utility_PVT.debug_message('l_batch_type : '||l_batch_type);
        OZF_Utility_PVT.debug_message('l_claim_currency_code : '||l_claim_currency_code);
  END IF;

  l_counter := 1;

 --If customer accounts have multiple bill to sites, then process will be aborted.
 --Since, INTERNAL claims always have 1:1 mapping with customer accounts and bill
 --to sites, so below validation will fail only for SUPPLIER claims.
  IF l_cust_util_tbl.COUNT > 1 THEN
     FOR i IN l_cust_util_tbl.FIRST..l_cust_util_tbl.LAST
     LOOP
        l_cust_account_id := l_cust_util_tbl(i).cust_account_id;
        l_check := 0;
        FOR j IN l_cust_util_tbl.FIRST..l_cust_util_tbl.LAST
        LOOP
           IF l_cust_account_id = l_cust_util_tbl(j).cust_account_id THEN
              l_check := l_check + 1;
           END IF;
        END LOOP;
        IF l_check > 1 THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('OZF', 'OZF_DUP_CUST_ACCTS');
              FND_MESSAGE.Set_Token('CUST_ACCOUNT_ID', l_cust_util_tbl(i).cust_account_id);
              FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.g_exc_unexpected_error;
        END IF;
     END LOOP;
  END IF;

  --Create claims for cust_account_id and bill_to_site_id
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('bill_to_site_id duplicate check passed: Creating claims for each cust_account_id/bill_to_site_id');
  END IF;

  IF l_cust_util_tbl.COUNT > 0 THEN
    FOR i IN l_cust_util_tbl.FIRST..l_cust_util_tbl.LAST
    LOOP
      l_cust_account_id   := l_cust_util_tbl(i).cust_account_id;
      l_bill_to_site_id   := l_cust_util_tbl(i).bill_to_site_id;
      l_claim_number      := l_cust_util_tbl(i).claim_number;

      IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('l_cust_account_id : '||l_cust_account_id);
          OZF_Utility_PVT.debug_message('l_bill_to_site_id : '||l_bill_to_site_id);
          OZF_Utility_PVT.debug_message('l_claim_number : '||l_claim_number);
      END IF;

      IF p_ship_debit_type = 'INTERNAL' THEN
         --Get all accurals which are qualifying for supplied request and
         --customer account and bill to sites combinations.
         OPEN  csr_request_lines(p_ship_debit_id
                                ,l_cust_account_id
                                ,l_bill_to_site_id);

      ELSIF p_ship_debit_type = 'SUPPLIER' THEN
         --Get all accruals which are qualifying for supplied batch and
         --customer account and bill to sites combinations.
         --l_sd_claim_lines_grouping check added for bugfix 7811671
         IF l_sd_claim_lines_grouping = 'Y' THEN
         OPEN  csr_batch_lines(p_ship_debit_id
                              ,l_cust_account_id
                              ,l_bill_to_site_id);
         ELSIF l_sd_claim_lines_grouping = 'N' THEN
           OPEN  csr_batch_nongrp_lines(p_ship_debit_id
                                       ,l_cust_account_id
                                       ,l_bill_to_site_id);
         END IF;
      END IF;

      LOOP
      IF  p_ship_debit_type = 'INTERNAL' THEN
            FETCH csr_request_lines INTO l_cust_account_id
                                       , l_activity_type
                                       , l_activity_id
                                       , l_bill_to_site_id
                                       , l_product_level_type
                                       , l_product_id
                                       , l_exchange_rate_type
                                       , l_amount
                                       , l_acctd_amount;  --// ER 9226258

            EXIT WHEN csr_request_lines%NOTFOUND;
      ELSIF p_ship_debit_type = 'SUPPLIER' THEN
        IF l_sd_claim_lines_grouping = 'Y' THEN
            FETCH csr_batch_lines INTO   l_cust_account_id
                                       , l_activity_type
                                       , l_activity_id
                                       , l_bill_to_site_id
                                       , l_product_level_type
                                       , l_product_id
                                       , l_amount;

            EXIT WHEN csr_batch_lines%NOTFOUND;
        ELSIF l_sd_claim_lines_grouping = 'N' THEN
            FETCH csr_batch_nongrp_lines INTO   l_cust_account_id
                                              , l_activity_type
                                              , l_activity_id
                                              , l_bill_to_site_id
                                              , l_product_level_type
                                              , l_product_id
                                              , l_amount
                                              , l_batch_line_id;

            EXIT WHEN csr_batch_nongrp_lines%NOTFOUND;
        END IF;
      END IF;

     IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message(' l_cust_account_id : '||l_cust_account_id);
          OZF_Utility_PVT.debug_message(' l_activity_type : '||l_activity_type);
          OZF_Utility_PVT.debug_message(' l_activity_id : '||l_activity_id);
          OZF_Utility_PVT.debug_message(' l_bill_to_site_id : '||l_bill_to_site_id);
          OZF_Utility_PVT.debug_message(' l_product_level_type : '||l_product_level_type);
          OZF_Utility_PVT.debug_message(' l_product_id : '||l_product_id);
          OZF_Utility_PVT.debug_message(' l_amount : '||l_amount);
          OZF_Utility_PVT.debug_message(' l_batch_line_id : '||l_batch_line_id);
     END IF;

      --If claim currency and accrual(offer) currency is not same, then convert
      --offer accounted amount from functional currency to claim currency.
      --This case is applicable only for INTERNAL claims as for SUPPLIER claims
      --amount in claim (batch header) currency retrieved.
      IF p_ship_debit_type = 'INTERNAL' THEN
        OPEN cur_offer_currency(p_ship_debit_id);
        FETCH cur_offer_currency INTO l_trans_currency_code;
        CLOSE cur_offer_currency;

        --// ER 9226258 : Get Functional Currency code
        OPEN  csr_function_currency;
        FETCH csr_function_currency INTO l_func_currency_code;
        CLOSE csr_function_currency;


        IF OZF_DEBUG_HIGH_ON THEN
           OZF_Utility_PVT.debug_message('Starts Currency Conversion for INTERNAL Claims ');
           OZF_Utility_PVT.debug_message(' l_trans_currency_code  : '|| l_trans_currency_code);
           OZF_Utility_PVT.debug_message(' l_claim_currency_code : '|| l_claim_currency_code);
           OZF_Utility_PVT.debug_message(' l_func_currency_code  : '|| l_func_currency_code);
        END IF;

        IF (l_trans_currency_code <> l_claim_currency_code) THEN
           IF (l_claim_currency_code = l_func_currency_code) THEN
              l_amount := l_acctd_amount;
           ELSE
               OZF_UTILITY_PVT.Convert_Currency(
                         p_from_currency   => l_func_currency_code
                        ,p_to_currency     => l_claim_currency_code
                        ,p_conv_type       => l_exchange_rate_type
                        ,p_conv_date       => SYSDATE
                        ,p_from_amount     => l_acctd_amount
                        ,x_return_status   => l_return_status
                        ,x_to_amount       => l_amount
                        ,x_rate            => l_conv_exc_rate
                      );

               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
           END IF;
        END IF;
      END IF;
        /*
        IF l_trans_currency_code <> l_claim_currency_code THEN
            l_amount_offr_curr := l_amount;
            OZF_UTILITY_PVT.Convert_Currency(
                 p_from_currency   => l_trans_currency_code
                ,p_to_currency     => l_claim_currency_code
                ,p_conv_date       => SYSDATE   --SD MC
                ,p_from_amount     => l_amount_offr_curr
                ,x_return_status   => l_return_status
                ,x_to_amount       => l_amount
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
        END IF;
        */


      --Ship-Debit doesn't require Prorate Earnings.
      --Setting line level attributes w.r.t. accrual details
      l_line_tbl(l_counter).prorate_earnings_flag     := 'F';
      l_line_tbl(l_counter).claim_currency_amount     := l_amount;
      l_line_tbl(l_counter).activity_type             := l_activity_type;
      l_line_tbl(l_counter).activity_id               := l_activity_id;
      l_line_tbl(l_counter).item_type                 := l_product_level_type;
      l_line_tbl(l_counter).item_id                   := l_product_id;
      l_line_tbl(l_counter).batch_line_id             := l_batch_line_id;

      --If product UOM is not defined then get primary UOM of product.
      IF l_product_level_type = 'PRODUCT' AND l_product_id IS NOT NULL THEN
        IF p_ship_debit_type = 'INTERNAL' THEN
          OPEN  csr_req_uom_code(p_ship_debit_id,l_line_tbl(l_counter).item_id);
          FETCH csr_req_uom_code INTO l_line_tbl(l_counter).quantity_uom;
          CLOSE csr_req_uom_code;
        ELSIF p_ship_debit_type = 'SUPPLIER' THEN
          OPEN  csr_batch_uom_code(p_ship_debit_id,l_line_tbl(l_counter).item_id);
          FETCH csr_batch_uom_code INTO l_line_tbl(l_counter).quantity_uom;
          CLOSE csr_batch_uom_code;
        END IF;

        IF l_line_tbl(l_counter).quantity_uom IS NULL THEN
            OPEN csr_uom_code(l_line_tbl(l_counter).item_id);
            FETCH csr_uom_code INTO l_line_tbl(l_counter).quantity_uom;
            IF csr_uom_code%NOTFOUND THEN
              CLOSE csr_uom_code;
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.Set_Name('OZF', 'OZF_PRODUCT_UOM_MISSING');
                FND_MESSAGE.Set_Token('ITEM_ID', l_line_tbl(l_counter).item_id);
                FND_MSG_PUB.ADD;
              END IF;
              RAISE FND_API.g_exc_unexpected_error;
            END IF;
            CLOSE csr_uom_code;
        END IF;
      END IF;

      --Calculate claim header amount in claim currency
      l_total_amount := l_total_amount + l_amount;
      l_counter := l_counter + 1;

      END LOOP;

      --Raise error, if no accrual exists, may happen for INTERNAL claims only
      IF l_counter = 1 THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_ACCRUAL_NOT_EXISTS');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF p_ship_debit_type = 'INTERNAL' THEN
        CLOSE csr_request_lines;
      ELSIF p_ship_debit_type = 'SUPPLIER' THEN
        IF l_sd_claim_lines_grouping = 'Y' THEN
        CLOSE csr_batch_lines;
        ELSIF l_sd_claim_lines_grouping = 'N' THEN
          CLOSE csr_batch_nongrp_lines;
        END IF;
      END IF;

      --If multiple claims are created then claim number of batch will be used for first claim only.
      IF l_rec_num > 1 THEN
        l_claim_number := NULL;
      END IF;

      --Setting values for claim header attributes
      --Vendor details added for bug 6921727
      l_claim_rec.cust_account_id          := l_cust_account_id;
      l_claim_rec.claim_class              := 'CLAIM';
      l_claim_rec.source_object_class      := l_source_object_class;
      l_claim_rec.source_object_id         := p_ship_debit_id;
      l_claim_rec.batch_id                 := l_batch_id;
      l_claim_rec.batch_type               := l_batch_type;
      l_claim_rec.currency_code            := l_claim_currency_code;
      l_claim_rec.amount                   := l_total_amount;
      l_claim_rec.payment_method           := l_payment_method;
      l_claim_rec.cust_billto_acct_site_id := l_cust_billto_acct_site_id;
      l_claim_rec.status_code              := 'OPEN';
      l_claim_rec.claim_number             := l_claim_number;
      l_claim_rec.vendor_id                := l_vendor_id;
      l_claim_rec.vendor_site_id           := l_vendor_site_id;
      l_claim_rec.org_id                   := l_sd_org_id;
      l_claim_rec.user_status_id           := to_number(
                                              ozf_utility_pvt.get_default_user_status(
                                              p_status_type   => 'OZF_CLAIM_STATUS',
                                              p_status_code   => l_claim_rec.status_code));

      IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('Claim header information:');
          OZF_Utility_PVT.debug_message('l_cust_account_id : '||l_claim_rec.cust_account_id);
          OZF_Utility_PVT.debug_message('claim_class : '||l_claim_rec.claim_class);
          OZF_Utility_PVT.debug_message('source_object_class : '||l_claim_rec.source_object_class);
          OZF_Utility_PVT.debug_message('source_object_number : '||l_claim_rec.source_object_number);
          OZF_Utility_PVT.debug_message('batch_id : '||l_claim_rec.batch_id);
          OZF_Utility_PVT.debug_message('batch_type : '||l_claim_rec.batch_type);
          OZF_Utility_PVT.debug_message('currency_code : '||l_claim_rec.currency_code);
          OZF_Utility_PVT.debug_message('amount : '||l_claim_rec.amount);
          OZF_Utility_PVT.debug_message('payment_method : '||l_claim_rec.payment_method);
          OZF_Utility_PVT.debug_message('cust_billto_acct_site_id : '||l_claim_rec.cust_billto_acct_site_id);
          OZF_Utility_PVT.debug_message('status_code : '||l_claim_rec.status_code);
          OZF_Utility_PVT.debug_message('claim_number : '||l_claim_rec.claim_number);
          OZF_Utility_PVT.debug_message('vendor_id : '||l_claim_rec.vendor_id);
          OZF_Utility_PVT.debug_message('vendor_site_id : '||l_claim_rec.vendor_site_id);
          OZF_Utility_PVT.debug_message('org_id : '||l_claim_rec.org_id);
          OZF_Utility_PVT.debug_message('user_status_id : '||l_claim_rec.user_status_id);
      END IF;


      --For INTERNAL negative claims, claim class need to be changed.
      IF p_ship_debit_type = 'INTERNAL' and l_claim_rec.amount < 0 THEN
          l_claim_rec.claim_class := 'CHARGE';
      END IF;

      --Create negative claims only for INTERNAL requests. For SUPPLIER, if
      --amount is negative, raise error.
      IF (p_ship_debit_type = 'SUPPLIER' and l_claim_rec.amount > 0) OR
         (p_ship_debit_type = 'INTERNAL' and l_claim_rec.amount <> 0) THEN

            --Claim header creation
            OZF_CLAIM_PVT.Create_Claim(
                 p_api_version            => l_api_version
                ,x_return_status          => l_return_status
                ,x_msg_data               => x_msg_data
                ,x_msg_count              => x_msg_count
                ,p_claim                  => l_claim_rec
                ,x_claim_id               => l_claim_id
                );

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF l_rec_num = 1 THEN
              x_claim_id := l_claim_id;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('Created claim id:'||l_claim_id);
            END IF;

            FOR i IN l_line_tbl.FIRST..l_line_tbl.LAST
            LOOP
              IF l_line_tbl.exists(i) IS NOT NULL THEN
                l_line_tbl(i).claim_id := l_claim_id;
              END IF;
            END LOOP;

            --Claim line creation
            OZF_CLAIM_LINE_PVT.Create_Claim_Line_Tbl(
                 p_api_version       => 1.0
                ,p_init_msg_list     => FND_API.g_false
                ,p_commit            => FND_API.g_false
                ,p_validation_level  => FND_API.g_valid_level_full
                ,x_return_status     => l_return_status
                ,x_msg_count         => x_msg_count
                ,x_msg_data          => x_msg_data
                ,p_claim_line_tbl    => l_line_tbl
                ,x_error_index       => l_error_index
                );

            IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_error;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('Claim lines created for claim_id=' || l_claim_id);
            END IF;

            OPEN csr_claim_lines(l_claim_id);
            LOOP
              FETCH csr_claim_lines INTO l_funds_util_flt.claim_line_id
                                       , l_funds_util_flt.activity_type
                                       , l_funds_util_flt.activity_id
                                       , l_funds_util_flt.product_level_type
                                       , l_funds_util_flt.product_id
                                       , l_funds_util_flt.total_amount
                                       , l_funds_util_flt.utiz_currency_code;  --7231613
              EXIT WHEN csr_claim_lines%NOTFOUND;

              --Claim Line/Utilizations association
              Update_Group_Line_Util(
                     p_api_version            => l_api_version
                    ,p_init_msg_list          => FND_API.g_false
                    ,p_commit                 => FND_API.g_false
                    ,p_validation_level       => p_validation_level
                    ,x_return_status          => l_return_status
                    ,x_msg_count              => x_msg_count
                    ,x_msg_data               => x_msg_data
                    ,p_summary_view           => 'ACTIVITY'
                    ,p_funds_util_flt         => l_funds_util_flt
                    ,p_mode                   => OZF_CLAIM_UTILITY_PVT.g_auto_mode
                    );

              IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_error;
              END IF;

            END LOOP;
            CLOSE csr_claim_lines;

            --Settle claim using settlement method as ACCOUNTING_ONLY/AP_DEBIT as per case.
            Settle_Claim(
                     p_claim_id            => l_claim_id
                    ,x_return_status       => l_return_status
                    ,x_msg_count           => x_msg_count
                    ,x_msg_data            => x_msg_data
                    );


            IF l_return_status =  fnd_api.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            END IF;
       ELSIF l_claim_rec.amount = 0 THEN
          --Raise error, if claim amount is zero. Claim header is not allowed with
          --zero amount.
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_EARN_AVAIL_AMT_ZERO');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.g_exc_unexpected_error;
       ELSE
          --Raise error, if claim amount is negative.
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('OZF', 'OZF_CLAIM_AMOUNT_NEGATIVE');
            FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       --Set Claim Access
       OPEN  csr_access(l_claim_id);
       LOOP
         FETCH csr_access INTO l_resource_id;
         EXIT WHEN csr_access%NOTFOUND;
         l_access_rec.user_or_role_id := l_resource_id;
         l_access_rec.arc_user_or_role_type := 'USER';
         l_access_rec.act_access_to_object_id := l_claim_id;
         l_access_rec.arc_act_access_to_object := 'CLAM';

         IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('Claim access information:');
              OZF_Utility_PVT.debug_message('user_or_role_id : '||l_access_rec.user_or_role_id);
              OZF_Utility_PVT.debug_message('arc_user_or_role_type : '||l_access_rec.arc_user_or_role_type);
              OZF_Utility_PVT.debug_message('act_access_to_object_id : '||l_access_rec.act_access_to_object_id);
              OZF_Utility_PVT.debug_message('arc_act_access_to_object : '||l_access_rec.arc_act_access_to_object);
         END IF;

         ams_access_pvt.create_access ( p_api_version => l_api_version
                                      , p_init_msg_list => fnd_api.g_false
                                      , p_validation_level => fnd_api.g_valid_level_full
                                      , x_return_status => x_return_status
                                      , x_msg_count => x_msg_count
                                      , x_msg_data => x_msg_data
                                      , p_commit => fnd_api.g_false
                                      , p_access_rec => l_access_rec
                                      , x_access_id => l_access_id
                                      );
       END LOOP;
       CLOSE csr_access;

       l_rec_num := l_rec_num + 1;

    END LOOP;
  ELSE
      --Raise error, if no accrual exists, may happen for INTERNAL claims only
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('OZF', 'OZF_ACCRUAL_NOT_EXISTS');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

  ------------------------- finish -------------------------------
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
    ROLLBACK TO Initiate_SD_Payment;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Initiate_SD_Payment;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Initiate_SD_Payment;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Initiate_SD_Payment;

END OZF_Claim_Accrual_PVT;

/
