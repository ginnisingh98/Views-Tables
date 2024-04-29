--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_SETTLEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_SETTLEMENT_PVT" AS
/* $Header: ozfvcstb.pls 120.8.12010000.11 2010/04/05 11:24:38 nepanda ship $ */

G_PKG_NAME                 CONSTANT VARCHAR2(30) := 'OZF_CLAIM_SETTLEMENT_PVT';
G_FILE_NAME                CONSTANT VARCHAR2(12) := 'ozfvcstb.pls';
G_CLAIM_CLASS_NAME         CONSTANT VARCHAR2(30) := 'CLAIM';
G_DEDUCTION_CLASS_NAME     CONSTANT VARCHAR2(30) := 'DEDUCTION';
G_OVERPAYMENT_CLASS_NAME   CONSTANT VARCHAR2(30) := 'OVERPAYMENT';
G_CHARGE_CLASS_NAME        CONSTANT VARCHAR2(30) := 'CHARGE';
G_APPROVAL_TYPE            CONSTANT VARCHAR2(30) := 'CLAIM';

OZF_DEBUG_HIGH_ON          CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON           CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   -------------------- initialize -----------------------
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   BEGIN
      OZF_AR_SETTLEMENT_PVT.Start_Settlement(
           p_claim_id                => p_claim_id
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

   IF OZF_DEBUG_HIGH_ON THEN
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
 | Procedure
 |    Check_Transaction_Balance
 |
 | NOTES
 |
 | HISTORY
 |    23-JUL-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Check_Transaction_Balance(
    p_customer_trx_id        IN    NUMBER
   ,p_claim_amount           IN    NUMBER
   ,p_claim_number           IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
)
IS
l_invoice_balance_due  NUMBER;
l_trx_number           AR_PAYMENT_SCHEDULES_ALL.TRX_NUMBER%TYPE;

CURSOR csr_invoice_balance(cv_trx_id IN NUMBER) IS
  SELECT SUM(amount_due_remaining), trx_number
  FROM ar_payment_schedules pay
  WHERE customer_trx_id = cv_trx_id
  GROUP BY trx_number;

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   -- Check Claim Line number
   OPEN csr_invoice_balance(p_customer_trx_id);
   FETCH csr_invoice_balance INTO l_invoice_balance_due,l_trx_number;
   CLOSE csr_invoice_balance;

   IF p_claim_amount > l_invoice_balance_due THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_INVOICE_BAL_ERR');
         FND_MESSAGE.set_token('TRX_NUMBER', l_trx_number);
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.g_ret_sts_error;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CHK_TRANS_BAL_UERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Check_Transaction_Balance;



/*=======================================================================*
 | Procedure
 |    Reopen_Claim_for_Completion
 |
 | Return
 |    x_claim_rec
 |
 | NOTES
 |
 | HISTORY
 |    08-JUL-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Reopen_Claim_for_Completion(
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_return_status         VARCHAR2(1);
l_api_name    CONSTANT VARCHAR2(30) := 'Reopen_Claim_for_Completion';

BEGIN
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

   -- move amount_settled back to amount_remaining, and calculated acctd_amount_remaining also.
   x_claim_rec.amount_settled := 0;

   x_claim_rec.acctd_amount_settled := 0;

   x_claim_rec.amount_remaining := x_claim_rec.amount - x_claim_rec.amount_adjusted - x_claim_rec.amount_settled - NVL(x_claim_rec.tax_amount, 0);

   OZF_UTILITY_PVT.Convert_Currency(
         P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
         P_FROM_CURRENCY   => p_claim_rec.currency_code,
         P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
         P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
         P_CONVERSION_RATE => p_claim_rec.exchange_rate,
         P_AMOUNT          => x_claim_rec.amount_remaining,
         X_RETURN_STATUS   => l_return_status,
         X_ACC_AMOUNT      => x_claim_rec.acctd_amount_remaining,
         X_RATE            => x_claim_rec.exchange_rate
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_claim_rec.settled_by := NULL;
   x_claim_rec.settled_date := NULL;

   x_claim_rec.approved_by := NULL;
   x_claim_rec.approved_date := NULL;

   x_claim_rec.payment_status := NULL;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Reopen_Claim_for_Completion;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Create_Trd_Prfl
--
-- PURPOSE
--    For 'CHECK' and 'CONTRA_CHARGE' payment_method, Create a trade profile
--    for a customer if it does not has a trade profile existing.
--
-- PARAMETERS
--    p_claim_id
--
-- NOTES
--
----------------------------------------------------------------------
PROCEDURE  Check_Create_Trd_Prfl (
    p_claim_id          IN   NUMBER
   ,x_return_status     OUT NOCOPY  VARCHAR2
   ,x_msg_count         IN   NUMBER
   ,x_msg_data          IN   VARCHAR2
)
IS
l_api_version      CONSTANT NUMBER         := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Check_Create_Trd_Prfl';
l_full_name        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status             VARCHAR2(1);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);

--//Bugfix : 8774738
CURSOR trd_prfl_count_csr(p_id IN NUMBER) is
   SELECT NVL(COUNT(trade_profile_id), 0)
   FROM   ozf_cust_trd_prfls cust, hz_cust_accounts hz
   WHERE  cust.party_id      = hz.party_id
   AND    hz.cust_account_id = p_id;

l_count             NUMBER := 0;
l_trd_prfl          OZF_Trade_Profile_PVT.trade_profile_rec_type;
l_trade_profile_id  NUMBER;

CURSOR sys_parameter_csr IS
  SELECT autopay_flag
  ,      autopay_periodicity
  ,      autopay_periodicity_type
  ,      days_due
  FROM ozf_sys_parameters;

l_autopay_flag             VARCHAR2(1);
l_autopay_periodicity      NUMBER;
l_autopay_periodicity_type VARCHAR2(30);
l_days_due                 NUMBER;

CURSOR cust_info_csr (p_id in NUMBER)IS
  SELECT payment_method
  ,      cust_account_id
  ,      cust_billto_acct_site_id
  ,      vendor_id
  ,      vendor_site_id
  FROM ozf_claims
  WHERE  claim_id = p_id;

l_payment_method            VARCHAR2(30);
l_cust_account_id           NUMBER;
l_cust_billto_acct_site_id  NUMBER;
l_vendor_id                 NUMBER;
l_vendor_site_id            NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN cust_info_csr(p_claim_id);
   FETCH cust_info_csr INTO l_payment_method
                          , l_cust_account_id
                          , l_cust_billto_acct_site_id
                          , l_vendor_id
                          , l_vendor_site_id;
   CLOSE cust_info_csr;

   IF l_payment_method IN ('CHECK', 'CONTRA_CHARGE','EFT','WIRE','AP_DEBIT','AP_DEFAULT') THEN
      OPEN trd_prfl_count_csr (l_cust_account_id);
      FETCH trd_prfl_count_csr INTO l_count;
      CLOSE trd_prfl_count_csr;

      -- IF customer doesn't have a trade profile, create one.
      IF l_count = 0 THEN
         OPEN sys_parameter_csr;
         FETCH sys_parameter_csr INTO l_autopay_flag
                                    , l_autopay_periodicity
                                    , l_autopay_periodicity_type
                                    , l_days_due;
         CLOSE sys_parameter_csr;

         l_trd_prfl.autopay_flag               := l_autopay_flag;
         l_trd_prfl.autopay_periodicity        := l_autopay_periodicity;
         l_trd_prfl.autopay_periodicity_type   := l_autopay_periodicity_type;
         l_trd_prfl.days_due                   := l_days_due;
         l_trd_prfl.cust_account_id            := l_cust_account_id;
         l_trd_prfl.site_use_id                := l_cust_billto_acct_site_id;
         l_trd_prfl.vendor_id                  := l_vendor_id;
         l_trd_prfl.vendor_site_id             := l_vendor_site_id;
         l_trd_prfl.payment_method             := l_payment_method;

         OZF_Trade_Profile_PVT.Create_Trade_Profile(
            p_api_version_number         => l_api_version,
            p_init_msg_list              => FND_API.G_FALSE,
            p_commit                     => FND_API.G_FALSE,
            p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
            x_return_status              => l_return_status,
            x_msg_count                  => l_msg_count,
            x_msg_data                   => l_msg_data,
            p_trade_profile_rec          => l_trd_prfl,
            x_trade_profile_id           => l_trade_profile_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
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
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Check_Create_Trd_Prfl;


---------------------------------------------------------------------
-- PROCEDURE
--   Remove_Utilization
--
-- NOTES
--
-- HISTORY
--   03/22/2001  mchang  Create.
--   10/24/2001  mchang  Remove_Utilization: Init claim_line rec before update_claim_line
---------------------------------------------------------------------
PROCEDURE Remove_Utilization (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
)
IS
l_api_name         CONSTANT VARCHAR2(30) := 'Remove_Utilization';
l_full_name        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_api_version      CONSTANT NUMBER         := 1.0;
l_return_status             VARCHAR2(1);

CURSOR csr_claim_line_asso(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  ,      object_version_number
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

TYPE claim_line_asso_tbl IS TABLE OF csr_claim_line_asso%ROWTYPE
INDEX BY BINARY_INTEGER;
l_claim_line_asso  claim_line_asso_tbl;
l_counter          NUMBER   :=1;
l_claim_line_rec   OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_line_obj_ver     NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_claim_line_asso(p_claim_id);
      LOOP
         FETCH csr_claim_line_asso INTO l_claim_line_asso(l_counter);
         EXIT WHEN csr_claim_line_asso%NOTFOUND;
         l_counter := l_counter + 1;
      END LOOP;
   CLOSE csr_claim_line_asso;

   IF l_claim_line_asso.count > 0 THEN
      FOR i IN 1..l_claim_line_asso.count LOOP
         OZF_Claim_Line_Pvt.Init_Claim_Line_Rec(
             x_claim_line_rec   =>  l_claim_line_rec
         );

         l_claim_line_rec.claim_line_id            := l_claim_line_asso(i).claim_line_id;
         l_claim_line_rec.object_version_number    := l_claim_line_asso(i).object_version_number;
         l_claim_line_rec.earnings_associated_flag := 'F';

         OZF_CLAIM_LINE_PVT.Update_Claim_Line(
             p_api_version            => l_api_version
            ,p_init_msg_list          => FND_API.g_false
            ,p_commit                 => FND_API.g_false
            ,p_validation_level       => FND_API.g_valid_level_full
            ,x_return_status          => l_return_status
            ,x_msg_count              => x_msg_data
            ,x_msg_data               => x_msg_count
            ,p_claim_line_rec         => l_claim_line_rec
            ,x_object_version         => l_line_obj_ver
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END LOOP;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Remove_Utilization;


---------------------------------------------------------------------
-- PROCEDURE
--   Duplicate_Claim_for_Completion
--
-- NOTES
--
-- HISTORY
--   04/10/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Duplicate_Claim_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
)
IS
l_api_name         CONSTANT VARCHAR2(30) := 'Duplicate_Claim_for_Completion';
l_full_name        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status       VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   Remove_Utilization (
       x_return_status     => l_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_claim_id          => p_claim_id

   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Duplicate_Claim_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Cancel_Claim_for_Completion
--
-- NOTES
--
-- HISTORY
--   03/26/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Cancel_Claim_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
)
IS
l_api_name         CONSTANT VARCHAR2(30) := 'Cancel_Claim_for_Completion';
l_full_name        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status       VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   Remove_Utilization (
       x_return_status     => l_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
      ,p_claim_id          => p_claim_id

   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Cancel_Claim_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Cancel_Claim_for_Settlement
--
-- NOTES
--
-- HISTORY
--   10/29/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Cancel_Claim_for_Settlement (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
   ,p_prev_status            IN  VARCHAR2
   ,p_curr_status            IN  VARCHAR2
)
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Cancel_Claim_for_Settlement';
l_full_name  CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status       VARCHAR2(1);

CURSOR csr_claim_class(cv_claim_id IN NUMBER) IS
  SELECT claim_class
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_claim_class         VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;
   /*
   OPEN csr_claim_class(p_claim_id);
   FETCH csr_claim_class INTO l_claim_class;
   CLOSE csr_claim_class;

   IF l_claim_class = G_DEDUCTION_CLASS_NAME THEN
      --------- Settlement Wrokflow : Send Notificatino to AR ---------------
      BEGIN
         OZF_AR_SETTLEMENT_PVT.Start_Settlement(
            p_claim_id                => p_claim_id
           ,p_prev_status             => p_prev_status
           ,p_curr_status             => 'CANCELLED'
           ,p_next_status             => p_curr_status
         );
      EXCEPTION
         WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',sqlerrm);
            FND_MSG_PUB.Add;
            RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;
   */
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

END Cancel_Claim_for_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Reject_Claim_for_Completion
--
-- NOTES
--   1. Update amount_settled, acctd_amount_settled
--           , amount_remaining, acctd_amount_remaining
--
-- HISTORY
--   03/26/2001  mchang  Create.
--   02/07/2001  mchang  revert amount_remaining to amount_settled while claim status from REJECT to OPEN.
---------------------------------------------------------------------
PROCEDURE Reject_Claim_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_name         CONSTANT VARCHAR2(30) := 'Reject_Claim_for_Completion';
l_full_name        CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status     VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;
   x_claim_rec := p_claim_rec;

   -- move amount_settled back to amount_remaining, and calculated acctd_amount_remaining also.
   x_claim_rec.amount_settled := 0;

   x_claim_rec.acctd_amount_settled := 0;

   x_claim_rec.amount_remaining := x_claim_rec.amount - x_claim_rec.amount_adjusted - x_claim_rec.amount_settled - NVL(x_claim_rec.tax_amount, 0);

   OZF_UTILITY_PVT.Convert_Currency(
         P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
         P_FROM_CURRENCY   => p_claim_rec.currency_code,
         P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
         P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
         P_CONVERSION_RATE => p_claim_rec.exchange_rate,
         P_AMOUNT          => x_claim_rec.amount_remaining,
         X_RETURN_STATUS   => l_return_status,
         X_ACC_AMOUNT      => x_claim_rec.acctd_amount_remaining,
         X_RATE            => x_claim_rec.exchange_rate
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
     x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

END Reject_Claim_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Reject_Claim_for_Settlement
--
-- NOTES
--
-- HISTORY
--   10/29/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Reject_Claim_for_Settlement (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
   ,p_prev_status            IN  VARCHAR2
   ,p_curr_status            IN  VARCHAR2
)
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Reject_Claim_for_Settlement';
l_full_name  CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status       VARCHAR2(1);

CURSOR csr_claim_class(cv_claim_id IN NUMBER) IS
  SELECT claim_class
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_claim_class         VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;
   /*
   OPEN csr_claim_class(p_claim_id);
   FETCH csr_claim_class INTO l_claim_class;
   CLOSE csr_claim_class;

   IF l_claim_class = G_DEDUCTION_CLASS_NAME THEN
      --------- Settlement Wrokflow : Send Notificatino to AR ---------------
      BEGIN
         OZF_AR_SETTLEMENT_PVT.Start_Settlement(
            p_claim_id                => p_claim_id
           ,p_prev_status             => p_prev_status
           ,p_curr_status             => 'REJECTED'
           ,p_next_status             => p_curr_status
         );
      EXCEPTION
         WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',sqlerrm);
            FND_MSG_PUB.Add;
            RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;
   */
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Reject_Claim_for_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Complete_Claim_for_Completion
--
-- NOTES
--
-- HISTORY
--   26-MAR-2001  mchang  Create.
--   09-AUG-2001  mchang  add validation: gl_date should fall into an open period if entered.
--   24-JAN-2001  slkrishn added reason_code validation:
--                         reason_code passed to AR should be
--                         invoicing_reason for CM and
--                         adjust_reason for Writeoff
---------------------------------------------------------------------
PROCEDURE Complete_Claim_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_Claim_for_Completion';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1)  := FND_API.g_ret_sts_success;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

   OZF_CLAIM_SETTLEMENT_VAL_PVT.Complete_Claim_Validation(
       p_api_version        => l_api_version
      ,p_init_msg_list      => FND_API.g_false
      ,p_validation_level   => FND_API.g_valid_level_full
      ,x_return_status      => l_return_status
      ,x_msg_data           => x_msg_data
      ,x_msg_count          => x_msg_count
      ,p_claim_rec          => p_claim_rec
      ,x_claim_rec          => x_claim_rec
   );
   IF l_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Complete_Claim_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Complete_Claim_for_Settlement
--
-- NOTES
--
-- HISTORY
--   03/26/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Claim_for_Settlement (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_Claim_for_Settlement';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   -- create trade profile if need
   Check_Create_Trd_Prfl (
        p_claim_id          => p_claim_id
       ,x_return_status     => l_return_status
       ,x_msg_count         => x_msg_count
       ,x_msg_data          => x_msg_data
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Complete_Claim_for_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Approve_Claim_for_Completion
--
-- NOTES
--   1. Update status_code, user_status_id
--           , amount_settled, acctd_amount_settled
--           , amount_remaining, acctd_amount_remaining
--           , settled_by, settled_date
--
-- HISTORY
--   03/26/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Approve_Claim_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Approve_Claim_for_Completion';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status         VARCHAR2(1);

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  default_flag = 'Y'
  AND  system_status_code = cv_status_code;

CURSOR csr_line_sum_amt(cv_claim_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_claim_perf_appr_req(cv_custom_setup_id IN NUMBER) IS
  SELECT NVL(attr_available_flag, 'N')
  FROM ams_custom_setup_attr
  WHERE custom_setup_id = cv_custom_setup_id
  AND object_attribute = 'PAPR';


l_claim_amount_remaining NUMBER;
l_claim_lines_sum        NUMBER;
l_perf_appr_req          VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

   OPEN csr_claim_perf_appr_req(p_claim_rec.custom_setup_id);
   FETCH csr_claim_perf_appr_req INTO l_perf_appr_req;
   CLOSE csr_claim_perf_appr_req;

   IF p_claim_rec.approved_flag = 'N' AND
      l_perf_appr_req = 'N' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_PERF_APPR_REQ');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   -- status_code/user_status_id : update claim_status to 'PENDING_APPROVAL'
   OPEN csr_user_status_id('PENDING_APPROVAL');
   FETCH csr_user_status_id INTO x_claim_rec.user_status_id;
   CLOSE csr_user_status_id;
   x_claim_rec.status_code := 'PENDING_APPROVAL';

   -- amount_settled
   -- R12.1 Enhancement : Checking for payment method ACCOUNTING_ONLY
   IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO','AP_DEBIT','CHECK','EFT','WIRE','AP_DEFAULT','RMA','ACCOUNTING_ONLY') THEN
      OPEN csr_line_sum_amt(p_claim_rec.claim_id);
      FETCH csr_line_sum_amt INTO x_claim_rec.amount_settled;
      CLOSE csr_line_sum_amt;
   ELSE
      x_claim_rec.amount_settled := p_claim_rec.amount_remaining;
   END IF;

   -- acctd_amount_settled
   OZF_UTILITY_PVT.Convert_Currency(
      P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
      P_FROM_CURRENCY   => p_claim_rec.currency_code,
      P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
      P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
      P_CONVERSION_RATE => p_claim_rec.exchange_rate,
      P_AMOUNT          => x_claim_rec.amount_settled,
      X_RETURN_STATUS   => l_return_status,
      X_ACC_AMOUNT      => x_claim_rec.acctd_amount_settled,
      X_RATE            => x_claim_rec.exchange_rate
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- amount_remaining
   x_claim_rec.amount_remaining := x_claim_rec.amount - x_claim_rec.amount_adjusted - x_claim_rec.amount_settled - NVL(x_claim_rec.tax_amount, 0);

   -- acctd_amount_remaining
   OZF_UTILITY_PVT.Convert_Currency(
      P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
      P_FROM_CURRENCY   => p_claim_rec.currency_code,
      P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
      P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
      P_CONVERSION_RATE => p_claim_rec.exchange_rate,
      P_AMOUNT          => x_claim_rec.amount_remaining,
      X_RETURN_STATUS   => l_return_status,
      X_ACC_AMOUNT      => x_claim_rec.acctd_amount_remaining,
      X_RATE            => x_claim_rec.exchange_rate
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   ------- amount remaining checking --------
   l_claim_amount_remaining := x_claim_rec.amount - x_claim_rec.amount_adjusted - x_claim_rec.amount_settled - NVL(x_claim_rec.tax_amount, 0);
   /*
   -- ABS(l_claim_amount_remaining) should be >= 0 now

   IF ABS(l_claim_amount_remaining) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_AMT_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;
   */

   -- settled_by / settled_date
   x_claim_rec.settled_by := OZF_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);
   x_claim_rec.settled_date := SYSDATE;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Approve_Claim_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Approve_Claim_for_Settlement
--
-- NOTES
--
-- HISTORY
--   03/26/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Approve_Claim_for_Settlement (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
   ,p_prev_status            IN  VARCHAR2
   ,p_curr_status            IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Approve_Claim_for_Settlement';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;

l_return_status         VARCHAR2(1);

l_object_version_number NUMBER;
l_requester_id          NUMBER; -- Fix for bug 4754509
l_comments              VARCHAR2(2000);
l_orig_status_id        NUMBER;
l_orig_status_code      VARCHAR2(30) := p_prev_status;
l_new_status_id         NUMBER;
l_reject_status_code    VARCHAR2(30) := 'REJECTED';
l_reject_status_id      NUMBER;

l_status_type           VARCHAR2(30) := 'OZF_CLAIM_STATUS';
l_approval_workflow     VARCHAR2(30) := 'AMSGAPP';
l_item_type             VARCHAR2(30) := 'AMSGAPP';
l_approval_type         VARCHAR2(30);
l_approval_require      VARCHAR2(1);
CURSOR claim_rec_csr(l_claim_id in number) IS
 SELECT object_version_number
 --,      user_status_id
 ,      settled_by   -- Fix for Bug 4754509
 ,      comments
 FROM   ozf_claims
 WHERE  claim_id = l_claim_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN claim_rec_csr(p_claim_id);
   FETCH claim_rec_csr INTO l_object_version_number,
                            --l_new_status_id,
                            l_requester_id,   --  Fix for Bug 4754509
                            l_comments;
   CLOSE claim_rec_csr;

   l_orig_status_id := OZF_UTILITY_PVT.get_default_user_status(
                               l_status_type
                              ,l_orig_status_code
                       );

   l_new_status_id := OZF_UTILITY_PVT.get_default_user_status(
                               l_status_type
                              ,p_curr_status
                      );

   l_reject_status_id := OZF_UTILITY_PVT.get_default_user_status(
                               l_status_type
                              ,l_reject_status_code
                         );
   IF OZF_Claim_Accrual_PVT.Earnings_Approval_Required(p_claim_id) = FND_API.g_true THEN
      l_approval_type := 'EARNING';
   ELSIF OZF_Claim_Accrual_PVT.Perform_Approval_Required(p_claim_id) = FND_API.g_true THEN
      l_approval_type := 'PERFORMANCE';
   ELSE
      l_approval_type := 'CLAIM';
   END IF;

   ----------------------------
   -- Call Approval Workflow --
   ----------------------------
   -- the approval API would  start claim approval process
   AMS_GEN_APPROVAL_PVT.StartProcess(
      p_activity_type         => 'CLAM'
     ,p_activity_id           => p_claim_id
     ,p_approval_type         => l_approval_type
     ,p_object_version_number => l_object_version_number
     ,p_orig_stat_id          => l_orig_status_id
     ,p_new_stat_id           => l_new_status_id
     ,p_reject_stat_id        => l_reject_status_id
     ,p_requester_userid      => l_requester_id    -- Fix for Bug 4754509
     ,p_notes_from_requester  => l_comments
     ,p_workflowprocess       => l_approval_workflow
     ,p_item_type             => l_item_type
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Approve_Claim_for_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Create_Payment_for_Completion
--
-- NOTES
--   1. If General Approval Workflow skipped,
--         Update amount_settled, acctd_amount_settled
--              , amount_remaining, acctd_amount_remaining
--              , settled_by, settled_date
--   --2. Adjust over utilization for scan data
--   3. Default GL Date based on System Parameters
--   4. Credit Memo/Debit Memo: open balance amount checking
--   5. Credit Memo-Invoice settlement: Invoice balance checking.
--   6. Update user_status_id and status_code to PENDING_CLOSE
--   7. Update payment_status to PENDING.
--
-- HISTORY
--   04/04/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Create_Payment_for_Completion (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_approval_require       IN  VARCHAR2
   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,p_prev_status            IN  VARCHAR2
   ,p_curr_status            IN  VARCHAR2

   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Payment_for_Completion';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_payment_term(cv_books_id IN NUMBER) IS
  SELECT ap_payment_term_id
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_books_id;

CURSOR csr_get_gl_date_type(cv_set_of_books_id IN NUMBER) IS
  SELECT gl_date_type
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_set_of_books_id;

CURSOR csr_user_status_id(cv_status_code IN VARCHAR2) IS
  SELECT user_status_id
  FROM ams_user_statuses_vl
  WHERE system_status_type = 'OZF_CLAIM_STATUS'
  AND  default_flag = 'Y'
  AND  system_status_code = cv_status_code;

CURSOR csr_line_sum_amt(cv_claim_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

CURSOR csr_trx_balance(cv_customer_trx_id IN NUMBER) IS
  SELECT SUM(amount_due_remaining),
         invoice_currency_code
  FROM ar_payment_schedules
  WHERE customer_trx_id = cv_customer_trx_id
  GROUP BY invoice_currency_code;

l_gl_date_type           VARCHAR2(30);
l_claim_amount_remaining NUMBER;
l_trx_balance            NUMBER;
l_process_setl_wf        VARCHAR2(1);
l_invoice_id             NUMBER;
l_deduction_type         VARCHAR2(20);
l_adj_util_result_status VARCHAR2(15);
l_trx_currency           VARCHAR2(15);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

  /*----------------------------------------------------------
   | 1. If General Approval Workflow skipped,
   |         Update claim settled/remaining amount
   |         and settled by/date information
   |
   | mchang fix @11.5.9: the following logic needs to confirm for the status flow
   |                     PENDING_APPROVAL
   |                     --(approval workflow)--> CLOSED
   |                     -> PENDING_APPROVAL
   |                     --(adjust over util workflow)--> CLOSED
   *---------------------------------------------------------*/
   IF p_approval_require = 'N' AND
      p_prev_status <> 'APPROVED' THEN
      -- claim settled/remaining amount is been updated already
      -- for status order PENDING_APPROVAL -> (CLOSED) -> APPROVED

      -- update amount_settled
      -- R12.1 Enhancement: Checking for ACCOUNTING_ONLY payment method
      IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO','AP_DEBIT','CHECK','EFT','WIRE','AP_DEFAULT','RMA','ACCOUNTING_ONLY') THEN
         OPEN csr_line_sum_amt(p_claim_rec.claim_id);
         FETCH csr_line_sum_amt INTO x_claim_rec.amount_settled;
         CLOSE csr_line_sum_amt;
      ELSE
         x_claim_rec.amount_settled := p_claim_rec.amount_remaining;
      END IF;

      -- update acctd_amount_settled
      OZF_UTILITY_PVT.Convert_Currency(
            P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
            P_FROM_CURRENCY   => p_claim_rec.currency_code,
            P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
            P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
            P_CONVERSION_RATE => p_claim_rec.exchange_rate,
            P_AMOUNT          => x_claim_rec.amount_settled,
            X_RETURN_STATUS   => l_return_status,
            X_ACC_AMOUNT      => x_claim_rec.acctd_amount_settled,
            X_RATE            => x_claim_rec.exchange_rate
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      -- update amount_remaining
      x_claim_rec.amount_remaining := x_claim_rec.amount
                                    - x_claim_rec.amount_adjusted
                                    - x_claim_rec.amount_settled
                                    - NVL(x_claim_rec.tax_amount,0);

      -- update acctd_amount_remaining
      OZF_UTILITY_PVT.Convert_Currency(
            P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
            P_FROM_CURRENCY   => p_claim_rec.currency_code,
            P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
            P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
            P_CONVERSION_RATE => p_claim_rec.exchange_rate,
            P_AMOUNT          => x_claim_rec.amount_remaining,
            X_RETURN_STATUS   => l_return_status,
            X_ACC_AMOUNT      => x_claim_rec.acctd_amount_remaining,
            X_RATE            => x_claim_rec.exchange_rate
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      ------ check amount_remaining ------
      -- l_claim_amount_remaining should be >= 0 now
      -- (ps: convert amount sign for overpayment)
      l_claim_amount_remaining := x_claim_rec.amount
                                - x_claim_rec.amount_adjusted
                                - x_claim_rec.amount_settled
                                - NVL(x_claim_rec.tax_amount, 0);
      /*
      IF x_claim_rec.claim_class IN ('OVERPAYMENT', 'CHARGE') THEN
         l_claim_amount_remaining := l_claim_amount_remaining * -1;
      END IF;

      IF (l_claim_amount_remaining < 0) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_AMT_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
      */

      x_claim_rec.settled_by := OZF_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);
      x_claim_rec.settled_date := SYSDATE;

   END IF;
   /*
   -- settled_by/date needs to update for claim status order
   -- for status order   PENDING_APPROVAL
   --                 -> (CLOSED)
   --                 -> APPROVED
   --                 --(time gap)--> CLOSED
   IF p_prev_status = 'APPROVED' THEN
      x_claim_rec.settled_by := OZF_Utility_PVT.get_resource_id(FND_GLOBAL.user_id);
      x_claim_rec.settled_date := SYSDATE;
   END IF;
   */

   -- -----------------------------------------------
   -- Referral Claim Status Order:
   --   OPEN --> (CLOSED) --> PENDING_APPROVAL <claim approval> -- (time gap) --> (CLOSED)
   --                     --> PENDING_APPROVAL <partner approval> -- (time gap)
   --                     --> (APPROVED) <ozf_partner_claim_grp> --> (CLOSED)
   --                     --> PENDING_CLOSE --> CLOSED
   -- Referral Claim Payment Status Order:
   --   WAITING_ACCEPTANCE --> PENDING --> INTERFACED --> PAID
   -- ------------------------------------------------
   IF p_claim_rec.source_object_class = 'REFERRAL' AND
      p_claim_rec.source_object_id IS NOT NULL AND
      p_prev_status <> 'APPROVED' THEN
     /*----------------------------------------------------------
      | 2. Raise Business Event for Referral Claim Approval
      *---------------------------------------------------------*/
      Raise_Business_Event(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_id               => p_claim_rec.claim_id
         ,p_old_status             => p_prev_status
         ,p_new_status             => 'PENDING_APPROVAL'
         ,p_event_name             => 'oracle.apps.ozf.claim.referralApproval'
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      x_claim_rec.status_code := 'PENDING_APPROVAL';
      x_claim_rec.payment_status := 'WAITING_ACCEPTANCE';

   -- -----------------------------------------------
   -- Mass Settlement
   -- ----------------------------------------------
   ELSIF p_claim_rec.payment_method = 'MASS_SETTLEMENT' THEN
      IF p_claim_rec.gl_date IS NULL THEN
         OPEN csr_get_gl_date_type(p_claim_rec.set_of_books_id);
         FETCH csr_get_gl_date_type INTO l_gl_date_type;
         CLOSE csr_get_gl_date_type;

         IF l_gl_date_type = 'CLAIM_DATE' THEN
            x_claim_rec.gl_date := p_claim_rec.claim_date;
         ELSIF l_gl_date_type = 'DUE_DATE' THEN
            x_claim_rec.gl_date := p_claim_rec.due_date;
         ELSIF l_gl_date_type = 'SYSTEM_DATE' THEN
            x_claim_rec.gl_date := SYSDATE;
         END IF;
      END IF;

      x_claim_rec.status_code := 'PENDING_CLOSE';
      x_claim_rec.payment_status := 'PENDING';

   ELSE
     /*----------------------------------------------------------
      | 3. Adjust over utilization for scan data purpose.
      |    Settlement(payment) will continue only when
      |    Adjust_Fund_Utilization is fully completed.
      *---------------------------------------------------------*/
      Ozf_Claim_Accrual_Pvt.Adjust_Fund_Utilization(
            p_api_version       => l_api_version
           ,p_init_msg_list     => FND_API.g_false
           ,p_commit            => FND_API.g_false
           ,p_validation_level  => FND_API.g_valid_level_full
           ,x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           ,p_claim_id          => p_claim_rec.claim_id
           ,p_mode              => 'ADJ_FUND'
           ,x_next_status       => l_adj_util_result_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF l_adj_util_result_status = 'PENDING_APPROVAL' THEN
         x_claim_rec.status_code := 'PENDING_APPROVAL';

      ELSIF l_adj_util_result_status = 'CLOSED' THEN

        /*----------------------------------------------------------
         | 4. Defautl GL_Date: GL Date has to be defaulted based on the system parameters setup.
         *---------------------------------------------------------*/
         IF p_claim_rec.gl_date IS NULL THEN
            OPEN csr_get_gl_date_type(p_claim_rec.set_of_books_id);
            FETCH csr_get_gl_date_type INTO l_gl_date_type;
            CLOSE csr_get_gl_date_type;

            IF l_gl_date_type = 'CLAIM_DATE' THEN
              x_claim_rec.gl_date := p_claim_rec.claim_date;
            END IF;
            IF l_gl_date_type = 'DUE_DATE' THEN
              x_claim_rec.gl_date := p_claim_rec.due_date;
            END IF;
            IF l_gl_date_type = 'SYSTEM_DATE' THEN
              x_claim_rec.gl_date := SYSDATE;
            END IF;
         END IF;

        /*----------------------------------------------------------
         | 5. Previouse Open Credit Memo/Debit Memo: balance checking
         *---------------------------------------------------------*/
        IF p_claim_rec.payment_method IN ('PREV_CREDIT_MEMO', 'PREV_DEBIT_MEMO') THEN
                IF p_claim_rec.payment_reference_id IS NULL THEN
                         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                        FND_MESSAGE.set_name('OZF', 'OZF_PAY_REFERENCE_REQD');
                            FND_MSG_PUB.add;
                         END IF;
                 RAISE FND_API.G_EXC_ERROR;
            ELSE
                   OPEN csr_trx_balance(p_claim_rec.payment_reference_id);
                 FETCH csr_trx_balance INTO l_trx_balance, l_trx_currency;
           CLOSE csr_trx_balance;

                 IF x_claim_rec.currency_code = l_trx_currency AND
                    ABS(p_claim_rec.amount_remaining) > ABS(l_trx_balance) THEN
              IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CM_DM_OP_BAL_ERR');
                             FND_MSG_PUB.add;
                END IF;
                    RAISE FND_API.G_EXC_ERROR;
           END IF;
             END IF;
        END IF;

        /*----------------------------------------------------------
         | 6. Credit Memo-Invoice settlement: invoice balance checking
         *---------------------------------------------------------*/
         IF p_claim_rec.payment_method = 'REG_CREDIT_MEMO' THEN
               -- Validation for non invoice deductions is done during payment.
         IF p_claim_rec.claim_class = 'CLAIM' OR
                 ( p_claim_rec.claim_class = 'DEDUCTION' AND   p_claim_rec.source_object_id IS NOT NULL )  THEN
             OZF_AR_VALIDATION_PVT.Validate_CreditTo_Information(
                          p_claim_rec       => p_claim_rec
                             ,x_return_status   => l_return_status
                 );
                   IF l_return_status =  FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                      RAISE FND_API.g_exc_unexpected_error;
                     END IF;
         END IF;
         END IF;

        /*----------------------------------------------------------
         | 7. Update payment_status and claim status_code by settlement method.
         *---------------------------------------------------------*/
         x_claim_rec.status_code := 'PENDING_CLOSE';
        /*----------------------------------------------------------
         | 8. Update payment_status to PENDING
         *---------------------------------------------------------*/
         x_claim_rec.payment_status := 'PENDING';

      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_ADJ_OVER_UTIZ_ERR');
            FND_MSG_PUB.add;
         END IF;
         IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT', 'Status return from OZF_CLAIM_LINE_PVT.Adjust_Fund_Utilization = '||l_adj_util_result_status);
            FND_MSG_PUB.Add;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; -- end of if l_adj_util_result_status
   END IF; -- enf of if referral claim approval

   -- Set returning user_status_id
   OPEN csr_user_status_id(x_claim_rec.status_code);
   FETCH csr_user_status_id INTO x_claim_rec.user_status_id;
   CLOSE csr_user_status_id;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;

END Create_Payment_for_Completion;


---------------------------------------------------------------------
-- PROCEDURE
--   Create_Payment_for_Settlement
--
-- NOTES
--
-- HISTORY
--   04/04/2001  mchang  Create.
--   11/14/2001  mchang  Call GL interface API to create GL entry for all settlement_method
---------------------------------------------------------------------
PROCEDURE Create_Payment_for_Settlement (
    x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2

   ,p_claim_id               IN  NUMBER
   ,p_prev_status            IN  VARCHAR2
   ,p_curr_status            IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Payment_for_Settlement';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_payment_term(cv_books_id IN NUMBER) IS
  SELECT ap_payment_term_id
  FROM ozf_sys_parameters
  WHERE set_of_books_id = cv_books_id;

--R12.1 Price Protection Enhancement : Added the source object class
CURSOR csr_claim_settle(cv_claim_id IN NUMBER) IS
  SELECT claim_number
  ,      object_version_number
  ,      settled_date
  ,      effective_date
  ,      vendor_id
  ,      vendor_site_id
  ,      amount_settled
  ,      currency_code
  ,      exchange_rate
  ,      exchange_rate_type
  ,      exchange_rate_date
  ,      payment_method
  ,      set_of_books_id
  ,      gl_date
  ,      claim_class
  ,      payment_reference_id
  ,     source_object_class
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_payment_ref_settlement(cv_customer_trx_id IN NUMBER) IS
  SELECT cust_trx_type_id
  ,      trx_number
  ,      status
  FROM ar_payment_schedules
  WHERE customer_trx_id = cv_customer_trx_id;

l_automate_settlement VARCHAR2(1);

CURSOR promo_claim_csr(p_id IN NUMBER) IS
  SELECT NVL(SUM(lu.amount), 0)
  FROM ozf_claim_lines_util lu
  WHERE lu.claim_line_id IN (
     SELECT l.claim_line_id
     FROM ozf_claim_lines l
     WHERE l.claim_id = p_id);

l_asso_amount         NUMBER;
l_bg_process          VARCHAR2(1) := 'N';
l_bg_process_mode     VARCHAR2(3) := 'Y';
l_claim_settle        csr_claim_settle%ROWTYPE;
l_payment_term        NUMBER;
l_settlement_doc_rec  OZF_SETTLEMENT_DOC_PVT.settlement_doc_rec_type;

-- Bug4308173
CURSOR claim_gl_posting_csr(p_id in number) IS
SELECT osp.post_to_gl
FROM   ozf_sys_parameters_all osp
,      ozf_claims_all oc
WHERE  osp.org_id = oc.org_id
AND    oc.claim_id = p_id;
l_post_to_gl VARCHAR2(1);

l_event_id NUMBER;
l_ccid       NUMBER;


BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_claim_settle(p_claim_id);
   FETCH csr_claim_settle INTO l_claim_settle;
   CLOSE csr_claim_settle;

   l_bg_process_mode := NVL(FND_PROFILE.value('OZF_CLAIM_SETL_ACCT_BG'),'Y');

   OPEN promo_claim_csr(p_claim_id);
   FETCH promo_claim_csr INTO l_asso_amount;
   CLOSE promo_claim_csr;

   OPEN  claim_gl_posting_csr(p_claim_id);
   FETCH claim_gl_posting_csr INTO l_post_to_gl;
   CLOSE claim_gl_posting_csr;

   -- Added for Multi Currency

   IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('l_bg_process_mode 1:'||l_bg_process_mode);
         OZF_Utility_PVT.debug_message('l_asso_amount 1:'||l_asso_amount);
         OZF_Utility_PVT.debug_message('l_post_to_gl 1:'||l_post_to_gl);
   END IF;

   IF l_bg_process_mode = 'Y' THEN
      IF l_asso_amount <> 0 AND NVL(l_post_to_gl,'F') = 'T' THEN -- Bug4308173
         l_bg_process := 'Y';
      ELSE
         l_bg_process := 'N';
      END IF;
   END IF;

   -- Added for Multi Currency
   IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('l_bg_process_mode 2:'||l_bg_process_mode);
         OZF_Utility_PVT.debug_message('l_claim_settle.payment_method:'||l_claim_settle.payment_method);
   END IF;

   --R12.1 Enhancement:Checking for claim which have accrual and payment method ACCOUNTING_ONLY
   IF ((l_bg_process  = 'Y') and (l_claim_settle.payment_method <> 'ACCOUNTING_ONLY'))THEN
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message(l_full_name||' : promo claim');
      END IF;
      -- promotional claims settled by workflow
      BEGIN
         OZF_AR_SETTLEMENT_PVT.Start_Settlement(
              p_claim_id                => p_claim_id
             ,p_prev_status             => p_prev_status
             ,p_curr_status             => 'PENDING_CLOSE'
             ,p_next_status             => p_curr_status
             ,p_promotional_claim       => 'Y'
         );
      EXCEPTION
         WHEN OTHERS THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT','Promo Err: ' || sqlerrm);
            FND_MSG_PUB.Add;
            RAISE FND_API.g_exc_unexpected_error;
      END;
   ELSE -- non promotional claims
     /*---------------------------------------------------------*
      |                       CHECK   (AP)                      |
      *---------------------------------------------------------*/
      IF l_claim_settle.payment_method IN ( 'CHECK','EFT','WIRE','AP_DEFAULT','AP_DEBIT') THEN

        --R12.1 Price Protection changes: Bypass GL for vendor claim
        -- Fix for bug 7443072
        -- fix for 7654529
        -- ER#9382547 ChRM-SLA Uptake: Removed the Event_ID, x_clear_code_combination_id
        -- Out Parameter and claim_class as IN Parameter
        IF ((l_claim_settle.source_object_class <> 'PPVENDOR'
         OR l_claim_settle.source_object_class <> 'PPINCVENDOR')
         OR l_claim_settle.source_object_class IS NULL) THEN
        OZF_GL_INTERFACE_PVT.Post_Claim_To_GL (
                   p_api_version    =>  1.0,
                   x_return_status  => l_return_status,
                   x_msg_data     => x_msg_data,
                   x_msg_count    => x_msg_count,
                   p_claim_id       =>  p_claim_id,
                   p_settlement_method   => l_claim_settle.payment_method
                 );
         END IF;
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
        IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Accounting Event Id :'||l_event_id );
            OZF_Utility_PVT.debug_message('Code Combination Id :'||l_ccid );
       END IF;

         OPEN csr_payment_term(l_claim_settle.set_of_books_id);
         FETCH csr_payment_term INTO l_payment_term;
         CLOSE csr_payment_term;

         -- create AP invoice
         OZF_AP_INTERFACE_PVT.Create_AP_Invoice (
                p_api_version            => l_api_version
               ,p_init_msg_list          => FND_API.g_false
               ,p_commit                 => FND_API.g_false
               ,p_validation_level       => FND_API.g_valid_level_full
               ,x_return_status          => l_return_status
               ,x_msg_data               => x_msg_data
               ,x_msg_count              => x_msg_count
               ,p_claim_id               => p_claim_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

     /*---------------------------------------------------------*
      |                       AR Settlement
      | CREDIT_MEMO / REG_CREDIT_MEMO / DEBIT_MEMO / ON_ACCT_CREDIT/ CHARGEBACK / WRITE_OFF
      *---------------------------------------------------------*/
      ELSIF l_claim_settle.payment_method IN ( 'CREDIT_MEMO'
                                             , 'REG_CREDIT_MEMO'
                                             , 'ON_ACCT_CREDIT'
                                             , 'DEBIT_MEMO'
                                             , 'CHARGEBACK'
                                             , 'WRITE_OFF'
                                             , 'PREV_OPEN_CREDIT'
                                             , 'PREV_OPEN_DEBIT'
                                             , 'ACCOUNTING_ONLY' --R12.1 Enhancement
                                             ) THEN

       --R12.1 Price Protection: Bypass the Gl entry for Customer Claim
       -- fix for 7654529
       -- ER#9382547 ChRM-SLA Uptake: Removed the Event_ID, x_clear_code_combination_id
       -- Out Parameter and claim_class as IN Parameter
       IF (l_claim_settle.source_object_class <> 'PPCUSTOMER'
       OR l_claim_settle.source_object_class IS NULL) THEN
        OZF_GL_INTERFACE_PVT.Post_Claim_To_GL (
                   p_api_version    =>  1.0,
                   x_return_status  => l_return_status,
                   x_msg_data     => x_msg_data,
                   x_msg_count    => x_msg_count,
                   p_claim_id       =>  p_claim_id,
                   p_settlement_method   => l_claim_settle.payment_method
                   );
       END IF;
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
        IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Accounting Event Id :'||l_event_id );
            OZF_Utility_PVT.debug_message('Code Combination Id :'||l_ccid );
       END IF;

        l_automate_settlement := NVL(FND_PROFILE.value('OZF_CLAIM_USE_AR_AUTOMATION'), 'Y');

        --R12.1 Enhancement: Checking for pyment_method as ACCOUNTING_ONLY
       IF ((l_automate_settlement = 'Y') OR (l_claim_settle.payment_method = 'ACCOUNTING_ONLY'))
        THEN
               OZF_AR_PAYMENT_PVT.Create_AR_Payment(
                      p_api_version            => l_api_version
                     ,p_init_msg_list          => FND_API.g_false
                     ,p_commit                 => FND_API.g_false
                     ,p_validation_level       => FND_API.g_valid_level_full
                     ,x_return_status          => l_return_status
                     ,x_msg_data               => x_msg_data
                     ,x_msg_count              => x_msg_count
                     ,p_claim_id               => p_claim_id
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
          ELSE
               Process_Settlement_WF(
                      p_claim_id               => p_claim_id
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

     /*---------------------------------------------------------*
      |                       RMA (OM)                          |
      *---------------------------------------------------------*/
      ELSIF l_claim_settle.payment_method = 'RMA' THEN
         l_automate_settlement := NVL(FND_PROFILE.value('OZF_CLAIM_USE_OM_AUTOMATION'), 'Y');

         IF l_automate_settlement = 'Y' THEN
            OZF_OM_PAYMENT_PVT.Create_OM_Payment(
                   p_api_version            => l_api_version
                  ,p_init_msg_list          => FND_API.g_false
                  ,p_commit                 => FND_API.g_false
                  ,p_validation_level       => FND_API.g_valid_level_full
                  ,x_return_status          => l_return_status
                  ,x_msg_data               => x_msg_data
                  ,x_msg_count              => x_msg_count
                  ,p_claim_id               => p_claim_id
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            Process_Settlement_WF(
                   p_claim_id               => p_claim_id
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

     /*---------------------------------------------------------*
      |                     CONTRA_CHARGE                       |
      *---------------------------------------------------------*/
      ELSIF l_claim_settle.payment_method = 'CONTRA_CHARGE' THEN

        -- ER#9382547 ChRM-SLA Uptake: Removed the Event_ID, x_clear_code_combination_id
        -- Out Parameter and claim_class as IN Parameter
        OZF_GL_INTERFACE_PVT.Post_Claim_To_GL (
                   p_api_version    =>  1.0,
                   x_return_status  => l_return_status,
                   x_msg_data     => x_msg_data,
                   x_msg_count    => x_msg_count,
                   p_claim_id       =>  p_claim_id,
                   p_settlement_method   => l_claim_settle.payment_method
                   );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
        IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Accounting Event Id :'||l_event_id );
            OZF_Utility_PVT.debug_message('Code Combination Id :'||l_ccid );
       END IF;

       -- Kickoff Settlement Workflow for contra charge
         Process_Settlement_WF(
                p_claim_id               => p_claim_id
               ,x_return_status          => l_return_status
               ,x_msg_data               => x_msg_data
               ,x_msg_count              => x_msg_count
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

     /*---------------------------------------------------------*
      |                   MASS_SETTLEMENT                       |
      *---------------------------------------------------------*/
      ELSIF l_claim_settle.payment_method = 'MASS_SETTLEMENT' THEN
         OZF_Mass_Settlement_PVT.Start_Mass_Payment(
                p_group_claim_id         => p_claim_id
               ,x_return_status          => l_return_status
               ,x_msg_data               => x_msg_data
               ,x_msg_count              => x_msg_count
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

     /*---------------------------------------------------------*
      |                 Non-seeded payment_method               |
      *---------------------------------------------------------*/
      -- Ivoke Claim Settlement Workflow to support non-seeded payment_method
      ELSE
         Process_Settlement_WF(
                p_claim_id               => p_claim_id
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

   END IF; -- end l_bg_process = 'Y'

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Create_Payment_for_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Update_Claim_Remaining_Amount
--
-- PURPOSE
--
-- NOTES
--
-- HISTORY
--   28-MAR-2002  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Update_Claim_Remaining_Amount(
      x_return_status     OUT NOCOPY VARCHAR2
     ,x_msg_count         OUT NOCOPY NUMBER
     ,x_msg_data          OUT NOCOPY VARCHAR2
     ,p_claim_rec         IN  OZF_CLAIM_PVT.claim_rec_type
     ,x_claim_rec         OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Update_Claim_Remaining_Amount';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_calcuate_tax(cv_claim_id IN NUMBER) IS
  SELECT ABS(pay.tax_original)
  FROM ar_payment_schedules pay
  ,    ozf_settlement_docs sd
  WHERE pay.customer_trx_id = sd.settlement_id
  AND sd.claim_id = cv_claim_id;

CURSOR csr_sum_line_amount(cv_claim_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;


BEGIN
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||' : start');
  END IF;
  -- Initialize API return status to sucess
  x_return_status := FND_API.g_ret_sts_success;

  x_claim_rec := p_claim_rec;

  /*
  IF p_claim_rec.payment_method IN ('CREDIT_MEMO', 'DEBIT_MEMO') AND
     p_claim_rec.payment_reference_id IS NULL THEN -- calculate tax
     OPEN csr_sum_line_amount(p_claim_rec.claim_id);
     FETCH csr_sum_line_amount INTO x_claim_rec.amount_settled;
     CLOSE csr_sum_line_amount;

     OPEN csr_calcuate_tax(p_claim_rec.claim_id);
     FETCH csr_calcuate_tax INTO x_claim_rec.tax_amount;
     CLOSE csr_calcuate_tax;
  END IF;

  x_claim_rec.amount_remaining := x_claim_rec.amount - x_claim_rec.amount_adjusted - x_claim_rec.amount_settled - NVL(x_claim_rec.tax_amount, 0);

   OZF_UTILITY_PVT.Convert_Currency(
      P_SET_OF_BOOKS_ID => p_claim_rec.set_of_books_id,
      P_FROM_CURRENCY   => p_claim_rec.currency_code,
      P_CONVERSION_DATE => p_claim_rec.exchange_rate_date,
      P_CONVERSION_TYPE => p_claim_rec.exchange_rate_type,
      P_CONVERSION_RATE => p_claim_rec.exchange_rate,
      P_AMOUNT          => x_claim_rec.amount_remaining,
      X_RETURN_STATUS   => l_return_status,
      X_ACC_AMOUNT      => x_claim_rec.acctd_amount_remaining,
      X_RATE            => x_claim_rec.exchange_rate
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   */

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||' : end');
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Update_Claim_Remaining_Amount;


---------------------------------------------------------------------
-- PROCEDURE
--   Dispose_Invalid_Status_Order
--
-- PURPOSE
--   This procedure will populate error message for invalid claim status order.
--
-- NOTES
--
-- HISTORY
--   08-FEB-2002  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Dispose_Invalid_Status_Order(
    p_prev_status     IN   VARCHAR2
   ,p_curr_status     IN   VARCHAR2
)
IS
l_prev_status_meaning      VARCHAR2(80);
l_curr_status_meaning      VARCHAR2(80);

CURSOR csr_status_meaning(c_status_code IN VARCHAR2) IS
  SELECT meaning
  FROM   ozf_lookups
  WHERE  lookup_type = 'OZF_CLAIM_STATUS'
  AND    lookup_code = c_status_code;

BEGIN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      OPEN csr_status_meaning(p_prev_status);
      FETCH csr_status_meaning INTO l_prev_status_meaning;
      IF csr_status_meaning%NOTFOUND THEN
         CLOSE csr_status_meaning;
         l_prev_status_meaning := p_prev_status;
      ELSE
         CLOSE csr_status_meaning;
      END IF;

      OPEN csr_status_meaning(p_curr_status);
      FETCH csr_status_meaning INTO l_curr_status_meaning;
      IF csr_status_meaning%NOTFOUND THEN
         CLOSE csr_status_meaning;
         l_curr_status_meaning := p_curr_status;
      ELSE
         CLOSE csr_status_meaning;
      END IF;

      FND_MESSAGE.set_name('OZF', 'OZF_SETL_STATUS_RULE_ERR');
      FND_MESSAGE.set_token('PREV_STATUS', l_prev_status_meaning);
      FND_MESSAGE.set_token('CURR_STATUS', l_curr_status_meaning);
      FND_MSG_PUB.add;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF csr_status_meaning%ISOPEN THEN
         CLOSE csr_status_meaning;
      END IF;
END Dispose_Invalid_Status_Order;

/*=======================================================================*
 | PROCEDURE
 |    Claim_Approval_Required
 |
 | RETURN
 |    Y / N
 |
 | NOTES
 |
 | HISTORY
 |    09-AUG-2005  SSHIVALI  Create
 *=======================================================================*/
PROCEDURE Claim_Approval_Required(
    p_claim_id                   IN  NUMBER

   ,x_return_status              OUT NOCOPY VARCHAR2
   ,x_msg_data                   OUT NOCOPY VARCHAR2
   ,x_msg_count                  OUT NOCOPY NUMBER

   ,x_approval_require           OUT NOCOPY VARCHAR2
)
IS
CURSOR csr_check_approval_require(cv_custom_setup_id IN NUMBER) IS
  SELECT NVL(attr_available_flag, 'N')
  FROM ams_custom_setup_attr
  WHERE custom_setup_id = cv_custom_setup_id
  AND object_attribute = 'APPR';

l_approval_require               VARCHAR2(1) := 'Y'; --//Bugfix : 8479176 , Changed from T to Y
l_auto_wrtoff_appr_req           VARCHAR2(1);

CURSOR csr_claim_approval_attr(cv_claim_id IN NUMBER) IS
  SELECT custom_setup_id
  ,      payment_method
  ,      write_off_flag
  ,      under_write_off_threshold
  ,      status_code
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_claim_approval_attr   csr_claim_approval_attr%ROWTYPE;
BEGIN
   OPEN csr_claim_approval_attr(p_claim_id);
   FETCH csr_claim_approval_attr INTO l_claim_approval_attr.custom_setup_id
                                    , l_claim_approval_attr.payment_method
                                    , l_claim_approval_attr.write_off_flag
                                    , l_claim_approval_attr.under_write_off_threshold
                                    , l_claim_approval_attr.status_code;
   CLOSE csr_claim_approval_attr;

   OPEN csr_check_approval_require(l_claim_approval_attr.custom_setup_id);
   FETCH csr_check_approval_require INTO l_approval_require;
   CLOSE csr_check_approval_require;

   -- ----------------------------------------------------------------------------
   -- Comments   : Check if versus writeoff threshold is UNDER or OVER
   -- Notes      : 1.Check value of Profile option to determine whether claims under
   --                the writeofff threshold will require approval:
   --                If YES, approval will be required as dictated by custom setup.
   --                If NO, approaval will not be required even if custom setup dictated approval.
   --              2.For Claims over the write off threshold, users are allowed to include them
   --                in the auto-writeoffs. These claims will require approval as dictated by
   --                custom setup.
   -- ----------------------------------------------------------------------------
   IF l_claim_approval_attr.payment_method = 'WRITE_OFF' AND
      l_claim_approval_attr.write_off_flag = 'T' AND
      l_claim_approval_attr.under_write_off_threshold = 'UNDER' THEN
      l_auto_wrtoff_appr_req := FND_PROFILE.value('OZF_UNDER_WRITEOFF_THRESHOLD_APPROVAL');
      IF l_auto_wrtoff_appr_req = 'N' THEN
         l_approval_require := 'N';
      END IF;
   ELSIF l_claim_approval_attr.payment_method = 'MASS_SETTLEMENT' THEN
      l_approval_require := 'N';
   END IF;

    x_approval_require := l_approval_require;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_CHK_APPR_UNEXPERR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Claim_Approval_Required;


---------------------------------------------------------------------
-- PROCEDURE
--   Recalculate_FXGL
--
-- NOTES
--
-- HISTORY
--   05/26/2009  psomyaju  Create.
--   06/08/2009  kpatro    Updated.
--   06/25/2009  kpatro    Changed the Parameter set
--                         Removed the updation of claim line and header
--   03/08/2010  kpatro    ER#9382547 ChRM-SLA Uptake
---------------------------------------------------------------------

PROCEDURE Recalculate_FXGL ( p_claim_id      NUMBER
                           , p_claim_org_id  NUMBER
                           , p_settled_date  DATE
                           , p_claim_exchange_date IN OUT NOCOPY DATE
                           , p_claim_rate IN OUT NOCOPY NUMBER
                           , x_return_status OUT NOCOPY VARCHAR2
                           )
IS

l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Recalculate_FXGL';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

l_claim_line_id         NUMBER;
l_line_util_id          NUMBER;
l_claim_amount          NUMBER;
l_claim_line_amount     NUMBER;
l_cl_acctd_amount       NUMBER;
l_ln_acctd_amount       NUMBER;
l_line_util_amount      NUMBER;
l_claim_currency_code   VARCHAR2(30);
l_claim_settled_date    DATE;
l_claim_exc_rate        NUMBER;
l_claim_exc_type        VARCHAR2(30);
-- Fix for numeric or value error:
--character to number conversion error --kpatro
l_plan_currency_code    VARCHAR2(30);
l_fu_exc_type           VARCHAR2(30);
l_fu_exc_rate           NUMBER;
l_fu_exc_date           DATE;
l_lu_acctd_amount       NUMBER;
l_util_acctd_amount     NUMBER;
l_fxgl_amount           NUMBER;
l_functional_currency   VARCHAR2(30);

CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
       , ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
   AND  org.org_id = p_claim_org_id;

CURSOR c_claim_line_util_dtls IS
  SELECT  lu.claim_line_util_id
        , lu.amount
        , lu.currency_code
        , lu.exchange_rate_type
        , lu.exchange_rate
        , fu.plan_currency_code
        , fu.exchange_rate_type
        , fu.exchange_rate
        , fu.exchange_rate_date
  FROM    ozf_claim_lines_all ln
        , ozf_claim_lines_util_all lu
        , ozf_funds_utilized_all_b fu
  WHERE  ln.claim_id = p_claim_id
    AND  ln.claim_line_id = lu.claim_line_id
    AND  lu.utilization_id = fu.utilization_id;

BEGIN

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
      OZF_Utility_PVT.debug_message('trunc(p_settled_date)' || trunc(p_settled_date));
      OZF_Utility_PVT.debug_message('trunc(p_claim_exchange_date)' || trunc(p_claim_exchange_date));
      OZF_Utility_PVT.debug_message('p_claim_rate' || p_claim_rate);
   END IF;

   x_return_status := FND_API.g_ret_sts_success;

   l_claim_settled_date := p_settled_date;

   IF  (trunc(p_settled_date) = trunc(p_claim_exchange_date)) THEN
       RETURN;
   END IF;


   OPEN  csr_function_currency;
   FETCH csr_function_currency INTO l_functional_currency;
   CLOSE csr_function_currency;

   -- Fix the issue numeric or value error: character to number conversion error --kpatro
   OPEN c_claim_line_util_dtls;
   LOOP
     FETCH c_claim_line_util_dtls INTO l_line_util_id
                                     , l_line_util_amount
                                     , l_claim_currency_code
                                     , l_claim_exc_type
                                     , l_claim_exc_rate
                                     , l_plan_currency_code
                                     , l_fu_exc_type
                                     , l_fu_exc_rate
                                     , l_fu_exc_date;
     EXIT WHEN c_claim_line_util_dtls%NOTFOUND;

      -- ER#9382547 ChRM-SLA Uptake
      -- populate the claim line util exchange date when the claim currency
      -- and fucntional currency is same.
      IF (p_claim_rate = 1) THEN

           p_claim_exchange_date := l_claim_settled_date;
           -- Update the claim line util table with the settled date.
           UPDATE ozf_claim_lines_util_all
           SET    exchange_rate_date = l_claim_settled_date
           WHERE claim_line_util_id = l_line_util_id;

      END IF;




     IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message('p_claim_id = '||p_claim_id);
     OZF_Utility_PVT.debug_message('l_line_util_id = '||l_line_util_id);
     OZF_Utility_PVT.debug_message('l_line_util_amount = '||l_line_util_amount);
     OZF_Utility_PVT.debug_message('l_claim_currency_code = '||l_claim_currency_code);
     OZF_Utility_PVT.debug_message('l_claim_exc_rate = '||l_claim_exc_rate);
     OZF_Utility_PVT.debug_message('l_claim_exc_type = '||l_claim_exc_type);
     OZF_Utility_PVT.debug_message('l_plan_currency_code = '||l_plan_currency_code);
     OZF_Utility_PVT.debug_message('l_fu_exc_type = '||l_fu_exc_type);
     OZF_Utility_PVT.debug_message('l_fu_exc_rate = '||l_fu_exc_rate);
     OZF_Utility_PVT.debug_message('l_fu_exc_date = '||l_fu_exc_date);
     END IF;

     IF l_claim_currency_code = l_plan_currency_code AND
        l_claim_currency_code <> l_functional_currency THEN
        IF l_claim_exc_rate <> l_fu_exc_rate AND l_fu_exc_rate IS NOT NULL THEN

           OZF_UTILITY_PVT.Convert_Currency(
                 p_from_currency   => l_claim_currency_code
                ,p_to_currency     => l_functional_currency
                ,p_conv_type       => l_claim_exc_type
                ,p_conv_date       => l_claim_settled_date
                ,p_from_amount     => l_line_util_amount
                ,x_return_status   => l_return_status
                ,x_to_amount       => l_lu_acctd_amount
                ,x_rate            => l_claim_exc_rate
              );

           IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

           OZF_UTILITY_PVT.Convert_Currency(
                 p_from_currency   => l_plan_currency_code
                ,p_to_currency     => l_functional_currency
                ,p_conv_type       => l_fu_exc_type
                ,p_conv_date       => l_fu_exc_date
                ,p_from_amount     => l_line_util_amount
                ,x_return_status   => l_return_status
                ,x_to_amount       => l_util_acctd_amount
                ,x_rate            => l_fu_exc_rate
              );

           IF l_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
           ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

           l_fxgl_amount := l_lu_acctd_amount - l_util_acctd_amount;

           IF OZF_DEBUG_HIGH_ON THEN
           OZF_Utility_PVT.debug_message('l_line_util_id = '||l_line_util_id);
           OZF_Utility_PVT.debug_message('l_lu_acctd_amount = '||l_lu_acctd_amount);
           OZF_Utility_PVT.debug_message('l_util_acctd_amount = '||l_util_acctd_amount);
           OZF_Utility_PVT.debug_message('l_fxgl_amount = '||l_fxgl_amount);
           OZF_Utility_PVT.debug_message('l_claim_settled_date = '||l_claim_settled_date);
           OZF_Utility_PVT.debug_message('l_claim_exc_rate = '||l_claim_exc_rate);
           END IF;

           UPDATE ozf_claim_lines_util_all
           SET    acctd_amount = l_lu_acctd_amount
                , exchange_rate_date = l_claim_settled_date
                , exchange_rate  = l_claim_exc_rate
               -- , utilized_acctd_amount = l_util_acctd_amount
                , fxgl_acctd_amount = l_fxgl_amount
           WHERE claim_line_util_id = l_line_util_id;
        END IF;
     END IF;
   END LOOP;

   CLOSE c_claim_line_util_dtls;

   p_claim_exchange_date := l_claim_settled_date;
   p_claim_rate := l_claim_exc_rate;


   IF OZF_DEBUG_HIGH_ON THEN
   OZF_Utility_PVT.debug_message(l_full_name||' : end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END Recalculate_FXGL;


---------------------------------------------------------------------
-- PROCEDURE
--   Complete_Settlement
--
-- NOTES
--
-- HISTORY
--   03/22/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Settlement(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_rec              IN  OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_Settlement';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

l_curr_status           VARCHAR2(30);
l_prev_status           VARCHAR2(30);

l_claim_rec             OZF_CLAIM_PVT.claim_rec_type;
l_complete_claim_rec    OZF_CLAIM_PVT.claim_rec_type;
l_approval_require      VARCHAR2(1);

CURSOR csr_claim_prev_status(cv_claim_id IN NUMBER) IS
  SELECT status_code
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

-- Added For Rule Based Settlement ER
CURSOR csr_rule_based_approval(p_claim_id IN NUMBER) IS
SELECT NVL(approval_matched_credit, 'F'),NVL(approval_new_credit,'F')
FROM   ozf_sys_parameters os, ozf_claims_all oc
WHERE  oc.org_id = os.org_id
and    oc.claim_id = p_claim_id;

l_app_match_cr VARCHAR2(1);
l_app_new_cr VARCHAR2(1);
-- End For Rule Based Settlement ER

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Complete_Settlement;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
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

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_claim_prev_status(p_claim_rec.claim_id);
   FETCH csr_claim_prev_status INTO l_prev_status;
   CLOSE csr_claim_prev_status;

   -- Added For Rule Based Settlement ER
   OPEN csr_rule_based_approval(p_claim_rec.claim_id);
   FETCH csr_rule_based_approval INTO l_app_match_cr,l_app_new_cr;
   CLOSE csr_rule_based_approval;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('l_app_match_cr :'||l_app_match_cr);
      OZF_Utility_PVT.debug_message('l_app_new_cr :'|| l_app_new_cr);
      OZF_Utility_PVT.debug_message('p_claim_rec.settled_from :'|| p_claim_rec.settled_from);
      OZF_Utility_PVT.debug_message('p_claim_rec.payment_reference_number :'|| p_claim_rec.payment_reference_number);
      OZF_Utility_PVT.debug_message('p_claim_rec.payment_reference_id:'|| p_claim_rec.payment_reference_id);
   END IF;

   -- End of Rule Based Settlement
   l_curr_status := p_claim_rec.status_code;

   l_claim_rec := p_claim_rec;

  --------------------- Start -----------------------
  /*-------------------------+
   | 1. Complete Claim
   +-------------------------*/
   --nepanda : fix for bug # 9539273 - issue #3
   IF p_claim_rec.status_code IN ('NEW', 'OPEN') AND
      p_claim_rec.payment_method IS NOT NULL AND
      p_claim_rec.payment_method <> FND_API.G_MISS_CHAR THEN
      OZF_CLAIM_SETTLEMENT_VAL_PVT.Complete_Claim(
          p_api_version          => l_api_version
         ,p_init_msg_list        => FND_API.g_false
         ,p_validation_level     => FND_API.g_valid_level_full
         ,x_return_status        => l_return_status
         ,x_msg_data             => x_msg_data
         ,x_msg_count            => x_msg_count
         ,p_x_claim_rec          => l_claim_rec
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   x_claim_rec := l_claim_rec;

  /*-------------------------+
   | 2. Complete Settlement
   +-------------------------*/
   IF l_prev_status <> l_curr_status THEN
      -------- CANCELLED --------
      -- NEW      --->  CANCELLED
      -- OPEN     --->  CANCELLED
      -- COMPLETE --->  CANCELLED
      -- 11.5.10 subsequent receipt application ehancement
      -- PENDING_APPROVAL  ---> CANCELLED
      -- APPROVED          ---> CANCELLED
      -- REJECTED          ---> CANCELLED
      IF l_curr_status = 'CANCELLED' THEN
         IF l_prev_status IN ('NEW', 'OPEN', 'COMPLETE', 'REJECTED', 'PENDING_APPROVAL', 'APPROVED') THEN
            Cancel_Claim_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_id          => l_claim_rec.claim_id
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;

      -------- REJECTED --------
      -- NEW              --->  REJECTED
      -- OPEN             --->  REJECTED
      -- COMPLETE         --->  REJECTED
      -- PENDING_APPROVAL --->  REJECTED
      ELSIF l_curr_status = 'REJECTED' THEN
         IF l_prev_status IN ('NEW', 'OPEN', 'COMPLETE', 'PENDING_APPROVAL') THEN
            Reject_Claim_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;

      -------- DUPLICATE --------
      -- NEW      --->  DUPLICATE
      -- OPEN     --->  DUPLICATE
       ELSIF l_curr_status = 'DUPLICATE' THEN
         IF l_prev_status IN ('OPEN', 'COMPLETE') THEN
            Duplicate_Claim_for_Completion (
                x_return_status    => l_return_status
               ,x_msg_count        => x_msg_count
               ,x_msg_data         => x_msg_data
               ,p_claim_id         => l_claim_rec.claim_id
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;
      -------- COMPLETE --------
      -- OPEN     --->  COMPLETE
      ELSIF l_curr_status = 'COMPLETE' THEN
         IF l_prev_status = 'OPEN' THEN
            Complete_Claim_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSIF l_prev_status <> 'PENDING_APPROVAL' THEN
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;

      -------- CLOSED --------
      ELSIF l_curr_status = 'CLOSED' THEN
        -- Added For Rule Based Settlement ER

        IF NVL(p_claim_rec.settled_from,'X') <> 'RULEBASED' THEN
              Claim_Approval_Required(
                     p_claim_id                   => p_claim_rec.claim_id
                    ,x_return_status              => l_return_status
                    ,x_msg_data                   => x_msg_data
                    ,x_msg_count                  => x_msg_count
                    ,x_approval_require           => l_approval_require
                 );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                 END IF;
         ELSE
             -- For Credit Match
             IF (p_claim_rec.payment_reference_number IS NOT NULL
                 AND p_claim_rec.payment_reference_id IS NOT NULL
                 AND l_app_match_cr = 'T') THEN
                      l_approval_require := 'Y';
             -- For Accrual match
             ELSIF(p_claim_rec.payment_reference_number IS NULL
                 AND p_claim_rec.payment_reference_id IS NULL
                 AND l_app_new_cr = 'T') THEN
                      l_approval_require := 'Y';
             END IF;

             IF OZF_DEBUG_HIGH_ON THEN
             OZF_Utility_PVT.debug_message('l_approval_require:' || l_approval_require);
             END IF;
              IF l_approval_require = 'Y' THEN
                       Approve_Claim_for_Completion (
                            x_return_status     => l_return_status
                           ,x_msg_count         => x_msg_count
                           ,x_msg_data          => x_msg_data
                           ,p_claim_rec         => l_claim_rec
                           ,x_claim_rec         => x_claim_rec
                       );
                       IF l_return_status = FND_API.g_ret_sts_error THEN
                          RAISE FND_API.g_exc_error;
                       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                          RAISE FND_API.g_exc_unexpected_error;
                       END IF;
              END IF;

         END IF;

        /*-------------------------------*
         |  OPEN --> CLOSED  :Completion
         *-------------------------------*/
         IF l_prev_status = 'OPEN' THEN
            Complete_Claim_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => l_complete_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            l_claim_rec := l_complete_claim_rec;


            IF l_approval_require = 'Y' THEN
               Approve_Claim_for_Completion (
                    x_return_status     => l_return_status
                   ,x_msg_count         => x_msg_count
                   ,x_msg_data          => x_msg_data
                   ,p_claim_rec         => l_claim_rec
                   ,x_claim_rec         => x_claim_rec
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            ELSE -- skip approval workflow
               Create_Payment_for_Completion (
                    x_return_status     => l_return_status
                   ,x_msg_count         => x_msg_count
                   ,x_msg_data          => x_msg_data
                   ,p_approval_require  => 'N'
                   ,p_claim_rec         => l_claim_rec
                   ,p_prev_status       => l_prev_status
                   ,p_curr_status       => l_curr_status
                   ,x_claim_rec         => x_claim_rec
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;

        /*-----------------------------------*
         |  COMPLETE --> CLOSED  :Completion
         *-----------------------------------*/
         ELSIF l_prev_status = 'COMPLETE' THEN
            IF l_approval_require = 'Y' THEN
               Approve_Claim_for_Completion (
                  x_return_status     => l_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 ,p_claim_rec         => l_claim_rec
                 ,x_claim_rec         => x_claim_rec
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            ELSE -- skip approval workflow
               Create_Payment_for_Completion (
                  x_return_status     => l_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 ,p_approval_require  => 'N'
                 ,p_claim_rec         => l_claim_rec
                 ,p_prev_status       => l_prev_status
                 ,p_curr_status       => l_curr_status
                 ,x_claim_rec         => x_claim_rec
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;

        /*----------------------------------------------------*
         | APPROVED / PENDING_APPROVAL --> CLOSED  :Completion
         *----------------------------------------------------*/
         ELSIF l_prev_status = 'APPROVED' OR
               l_prev_status = 'PENDING_APPROVAL' THEN
            Create_Payment_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_approval_require  => 'Y'
              ,p_claim_rec         => l_claim_rec
              ,p_prev_status       => l_prev_status
              ,p_curr_status       => l_curr_status
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

        /*----------------------------------------*
         | PENDING_CLOSE --> CLOSED  :Completion
         *----------------------------------------*/
         ELSIF l_prev_status = 'PENDING_CLOSE' THEN
            Update_Claim_Remaining_Amount (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

         ELSE
            IF l_prev_status <> 'PENDING_CLOSE' THEN
               Dispose_Invalid_Status_Order(
                  p_prev_status     => l_prev_status
                 ,p_curr_status     => l_curr_status
               );
            RAISE FND_API.g_exc_error;
            END IF;
         END IF;

      -------- PENDING_APPROVAL (for Mass Settlement) --------
      ELSIF l_curr_status = 'PENDING_APPROVAL' THEN
         IF l_prev_status = 'COMPLETE' THEN
            Approve_Claim_for_Completion (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;

      /*
        The following status flow will not invoke any settlement process.
        but we need to check if the status flow is right.
      */
      -------- APPROVED --------
      ELSIF l_curr_status = 'APPROVED' THEN
         IF l_prev_status IN ( 'NEW'
                             , 'OPEN'
                             , 'COMPLETE'
                             , 'CANCELLED'
                             , 'REJECTED'
                             , 'DUPLICATE'
                             , 'APPROVED'
                             , 'ARCHIVED') THEN
            -- commented 'CLOSED' from above slkrishn
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;
      -------- ARCHIVED --------
      ELSIF l_curr_status = 'ARCHIVED' THEN
         IF l_prev_status IN ( 'NEW'
                             , 'OPEN'
                             , 'COMPLETE'
                             , 'DUPLICATE'
                             , 'APPROVED'
                             , 'PENDING_APPROVAL'
                             , 'PENDING_CLOSE') THEN
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;
      -------- OPEN --------
      ELSIF l_curr_status = 'OPEN' THEN
         IF l_prev_status IN ( --'COMPLETE'
                               --'APPROVED'
                               --, 'PENDING_APPROVAL'
                               --, 'PENDING_CLOSE'
                             'ARCHIVED') THEN
            Dispose_Invalid_Status_Order(
               p_prev_status     => l_prev_status
              ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
        /*---------------------------*
         | PENDING_APPROVAL --> OPEN
         | PENDING_CLOSE --> OPEN
         *---------------------------*/
         ELSIF l_prev_status IN ('PENDING_APPROVAL', 'PENDING_CLOSE') THEN
            Reopen_Claim_for_Completion(
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_rec         => l_claim_rec
              ,x_claim_rec         => x_claim_rec
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;

      -------- PENDING_CLOSED --------
      ELSIF l_curr_status = 'PENDING_CLOSED' THEN
         IF l_prev_status IN ( 'NEW'
                             --, 'OPEN'
                             , 'COMPLETE'
                             , 'CLOSED'
                             , 'CANCELLED'
                             , 'REJECTED'
                             , 'DUPLICATE'
                             , 'PENDING_CLOSE'
                             , 'ARCHIVED') THEN
            Dispose_Invalid_Status_Order(
                p_prev_status     => l_prev_status
               ,p_curr_status     => l_curr_status
            );
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
      --Printing the values for Claim Multi Currency

     IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('x_claim_rec.settled_date' || x_claim_rec.settled_date);
      OZF_Utility_PVT.debug_message('x_claim_rec.claim_id' || x_claim_rec.claim_id);
      OZF_Utility_PVT.debug_message('x_claim_rec.org_id' || x_claim_rec.org_id);
      OZF_Utility_PVT.debug_message('x_claim_rec.claim_number' || x_claim_rec.claim_number);
      OZF_Utility_PVT.debug_message('x_claim_rec.exchange_rate_date' || x_claim_rec.exchange_rate_date);
      OZF_Utility_PVT.debug_message('x_claim_rec.exchange_rate_date' || x_claim_rec.exchange_rate);
     END IF;
     -- Added For Multi currency ER - kpatro
     IF(x_claim_rec.settled_date IS NOT NULL) THEN

        Recalculate_FXGL( p_claim_id  => x_claim_rec.claim_id
                    , p_claim_org_id  =>  x_claim_rec.org_id
                    , p_settled_date  => x_claim_rec.settled_date
                    , p_claim_exchange_date => x_claim_rec.exchange_rate_date
                    , p_claim_rate => x_claim_rec.exchange_rate
                    , x_return_status => l_return_status
                    );
       IF OZF_DEBUG_HIGH_ON THEN
          OZF_Utility_PVT.debug_message('l_return_status' ||l_return_status);
       END IF;

       IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
       END IF;

     END IF;
   END IF; -- end of complete settlement

   ------------------------- finish -------------------------------
   /*
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   */

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
      ROLLBACK TO Complete_Settlement;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Complete_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Complete_Settlement;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Complete_Settlement;


---------------------------------------------------------------------
-- PROCEDURE
--   Settle_Claim
--
-- NOTES
--
-- HISTORY
--   10-AUG-2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Settle_Claim(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_id               IN  NUMBER
   ,p_curr_status            IN  VARCHAR2
   ,p_prev_status            IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Settle_Claim';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

-- Added the settled_from for Rule Based Settlement ER
CURSOR csr_claim_approval_attr(cv_claim_id IN NUMBER) IS
  SELECT custom_setup_id
  ,      payment_method
  ,      write_off_flag
  ,      under_write_off_threshold
  ,      status_code
  ,      settled_from
  ,      payment_reference_number
  ,      payment_reference_id
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_claim_approval_attr   csr_claim_approval_attr%ROWTYPE;
l_approval_require      VARCHAR2(1);

-- Added For Rule Based Settlement ER
CURSOR csr_rule_based_approval(p_claim_id IN NUMBER) IS
SELECT NVL(approval_matched_credit, 'F'),NVL(approval_new_credit,'F')
FROM   ozf_sys_parameters os, ozf_claims_all oc
WHERE  oc.org_id = os.org_id
and    oc.claim_id = p_claim_id;

l_app_match_cr VARCHAR2(1);
l_app_new_cr VARCHAR2(1);

--End of Rule Based Settlement

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Settle_Claim;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
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

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   --------------------- Start -----------------------
   IF p_curr_status = 'CANCELLED' THEN
      Cancel_Claim_for_Settlement (
          x_return_status     => l_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_claim_id          => p_claim_id
         ,p_prev_status       => p_prev_status
         ,p_curr_status       => p_curr_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_curr_status = 'REJECTED' THEN
      Reject_Claim_for_Settlement (
          x_return_status     => l_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_claim_id          => p_claim_id
         ,p_prev_status       => p_prev_status
         ,p_curr_status       => p_curr_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_curr_status = 'DUPLICATE' THEN
      /* empty implementation */
       l_return_status := FND_API.g_ret_sts_success;

   ELSIF p_curr_status = 'COMPLETE' THEN
      Complete_Claim_for_Settlement (
          x_return_status     => l_return_status
         ,x_msg_count         => x_msg_count
         ,x_msg_data          => x_msg_data
         ,p_claim_id          => p_claim_id
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   ELSIF p_curr_status = 'CLOSED' THEN
      -- Added For Rule Based Settlement ER
      OPEN csr_claim_approval_attr(p_claim_id);
      FETCH csr_claim_approval_attr INTO l_claim_approval_attr.custom_setup_id
                                       , l_claim_approval_attr.payment_method
                                       , l_claim_approval_attr.write_off_flag
                                       , l_claim_approval_attr.under_write_off_threshold
                                       , l_claim_approval_attr.status_code
                                       , l_claim_approval_attr.settled_from
                                       , l_claim_approval_attr.payment_reference_number
                                       , l_claim_approval_attr.payment_reference_id;

      CLOSE csr_claim_approval_attr;


      -- Added For Rule Based Settlement ER
      OPEN csr_rule_based_approval(p_claim_id);
      FETCH csr_rule_based_approval INTO l_app_match_cr,l_app_new_cr;
      CLOSE csr_rule_based_approval;

      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('l_app_match_cr :'||l_app_match_cr);
         OZF_Utility_PVT.debug_message('l_app_new_cr :'|| l_app_new_cr);
         OZF_Utility_PVT.debug_message('l_claim_approval_attr.payment_reference_number :'|| l_claim_approval_attr.payment_reference_number);
         OZF_Utility_PVT.debug_message('l_claim_approval_attr.payment_reference_id :'|| l_claim_approval_attr.payment_reference_id);
      END IF;

        IF NVL(l_claim_approval_attr.settled_from,'X') <> 'RULEBASED' THEN
                 Claim_Approval_Required(
                     p_claim_id                   => p_claim_id
                    ,x_return_status              => l_return_status
                    ,x_msg_data                   => x_msg_data
                    ,x_msg_count                  => x_msg_count
                    ,x_approval_require           => l_approval_require
                 );
                 IF l_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                 ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                 END IF;
         ELSE
             -- For Credit Match
             IF (l_claim_approval_attr.payment_reference_number IS NOT NULL
                 AND l_claim_approval_attr.payment_reference_id IS NOT NULL
                 AND l_app_match_cr = 'T') THEN
                      l_approval_require := 'Y';
             -- For Accrual match
             ELSIF(l_claim_approval_attr.payment_reference_number IS NULL
                 AND l_claim_approval_attr.payment_reference_id IS NULL
                 AND l_app_new_cr = 'T') THEN
                      l_approval_require := 'Y';
             END IF;
        END IF;
         -- End of Rule Based Settlement

      /*-------------------------------*
      |  OPEN --> CLOSED  :Settlement
      *-------------------------------*/
      IF p_prev_status = 'OPEN' THEN
         Complete_Claim_for_Settlement (
            x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           ,p_claim_id          => p_claim_id
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF l_approval_require = 'Y' THEN
            -- call marketing general approval workflow
            Approve_Claim_for_Settlement (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_id          => p_claim_id
              ,p_prev_status       => p_prev_status
              ,p_curr_status       => p_curr_status
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE -- skip approval workflow and create payment directly
              -- payment process won't start if claim will go for referral approval.
            IF l_claim_approval_attr.status_code <> 'PENDING_APPROVAL' THEN
               Create_Payment_for_Settlement (
                  x_return_status     => l_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 ,p_claim_id          => p_claim_id
                 ,p_prev_status       => p_prev_status
                 ,p_curr_status       => p_curr_status
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
         END IF;

     /*---------------------------------*
      |  COMPLETE --> CLOSED :Settlement
      *---------------------------------*/
      ELSIF p_prev_status = 'COMPLETE' THEN
         IF l_approval_require = 'Y' THEN
            -- call marketing general approval workflow
            Approve_Claim_for_Settlement (
               x_return_status     => l_return_status
              ,x_msg_count         => x_msg_count
              ,x_msg_data          => x_msg_data
              ,p_claim_id          => p_claim_id
              ,p_prev_status       => p_prev_status
              ,p_curr_status       => p_curr_status
            );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE -- skip approval workflow and create payment directly
              -- payment process won't start if claim will go for referral approval.
            IF l_claim_approval_attr.status_code <> 'PENDING_APPROVAL' THEN
               Create_Payment_for_Settlement (
                  x_return_status     => l_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 ,p_claim_id          => p_claim_id
                 ,p_prev_status       => p_prev_status
                 ,p_curr_status       => p_curr_status
               );
               IF l_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
         END IF;

     /*---------------------------------------------------*
      | APPROVED / PENDING_APPROVAL --> CLOSED :Settlement
      *---------------------------------------------------*/
      ELSIF p_prev_status = 'APPROVED' OR
            p_prev_status = 'PENDING_APPROVAL' THEN
         Create_Payment_for_Settlement (
            x_return_status     => l_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           ,p_claim_id          => p_claim_id
           ,p_prev_status       => p_prev_status
           ,p_curr_status       => p_curr_status
         );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
   ELSIF p_curr_status = 'OPEN' THEN
      /* mchang fix for 1159
      IF p_prev_status = 'COMPLETE' AND
         payment_method= 'RMA' THEN
         -- Delete RMA Order
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      */
       NULL;
   END IF;

   ------------------------- finish -------------------------------
  /*
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;
   */

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
      ROLLBACK TO Settle_Claim;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Settle_Claim;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Settle_Claim;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Settle_Claim;


---------------------------------------------------------------------
-- PROCEDURE
--   Raise_Business_Event
--
-- NOTES
--
-- HISTORY
--   10-OCT-2003  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Raise_Business_Event(
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY VARCHAR2
   ,x_msg_data               OUT NOCOPY VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER

   ,p_claim_id               IN  NUMBER
   ,p_old_status             IN  VARCHAR2
   ,p_new_status             IN  VARCHAR2
   ,p_event_name             IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Raise_Business_Event';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);
---

l_parameter_list                 WF_PARAMETER_LIST_T;
l_new_item_key                   VARCHAR2(30);
l_event_name                     VARCHAR2(60);

CURSOR  csr_claim_org(p_claim_id IN NUMBER) IS
     SELECT  org_id
       FROM   ozf_claims_all
      WHERE claim_id = p_claim_id;
l_org_id      NUMBER;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Raise_Business_Event;

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
      OZF_Utility_PVT.debug_message(l_full_name||' : event = '||p_event_name);
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

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   --------------------- Start -----------------------
   l_new_item_key := p_claim_id||'_'||TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');

   l_parameter_list := WF_PARAMETER_LIST_T();

   WF_EVENT.AddParameterToList( p_name            => 'CLAIM_ID'
                              , p_value           => p_claim_id
                              , p_parameterlist   => l_parameter_list
                              );

   WF_EVENT.AddParameterToList( p_name            => 'STATUS_CODE'
                              , p_value           => p_new_status
                              , p_parameterlist   => l_parameter_list
                              );

   OPEN    csr_claim_org(p_claim_id);
   FETCH  csr_claim_org   INTO l_org_id;
   CLOSE  csr_claim_org;

   WF_EVENT.AddParameterToList( p_name            => 'ORG_ID'
                              , p_value           =>  l_org_id
                              , p_parameterlist   => l_parameter_list
                              );


   WF_EVENT.Raise(
      p_event_name   =>  p_event_name
     ,p_event_key    =>  l_new_item_key
     ,p_parameters   =>  l_parameter_list
   );

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
      ROLLBACK TO Raise_Business_Event;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Raise_Business_Event;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO Raise_Business_Event;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
      );

END Raise_Business_Event;

END OZF_CLAIM_SETTLEMENT_PVT;

/
