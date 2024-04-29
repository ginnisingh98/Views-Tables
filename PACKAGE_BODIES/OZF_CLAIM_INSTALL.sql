--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_INSTALL" AS
/* $Header: ozfgcinb.pls 120.0.12010000.2 2008/12/30 04:56:07 psomyaju ship $ */
-- Start of Comments
-- Package name     : OZF_CLAIM_INSTALL
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

---------------------------------------------------------------------
--   PROCEDURE:  Check_Installed
--
--   PURPOSE: This function checks if claims module is installed
--
--   PARAMETERS:
--
--   NOTES:
--
---------------------------------------------------------------------
--Bugfix : 7668608 - p_org_id parameter added
FUNCTION Check_Installed (p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN
IS
l_cm_trx_type_id    NUMBER;
l_bb_trx_type_id    NUMBER;
l_sql_stmt          VARCHAR2(1000);

CURSOR csr_query IS
  SELECT cm_trx_type_id
  ,      billback_trx_type_id
  FROM   ozf_sys_parameters
  WHERE  org_id = NVL(p_org_id, org_id);

BEGIN

  OPEN csr_query;
  FETCH csr_query INTO l_cm_trx_type_id, l_bb_trx_type_id;
  CLOSE csr_query;

  IF l_cm_trx_type_id is NULL  AND
     l_bb_trx_type_id is NULL
  THEN
     return FALSE;
  ELSE
     return TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN FALSE;

END CHECK_INSTALLED;


---------------------------------------------------------------------
--   PROCEDURE:  Get_Amount_Remaining
--
--   PURPOSE: This API returns the amount_remaing of the root claim.
--
--   PARAMETERS:
--     IN
--       p_claim+id                IN   NUMBER              Required
--
--   OUT:
--       x_amount_remaining        OUT  NUMBER
--       x_acctd_amount_remaining  OUT  NUMBER
--       x_currency_code           OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--
--   NOTES:
--
---------------------------------------------------------------------
PROCEDURE Get_Amount_Remaining (
  p_claim_id               IN  NUMBER,
  x_amount_remaining       OUT NOCOPY NUMBER,
  x_acctd_amount_remaining OUT NOCOPY NUMBER,
  x_currency_code          OUT NOCOPY VARCHAR2,
  x_return_status          OUT NOCOPY VARCHAR2
)
IS

l_claim_id                            NUMBER;
l_payment_method                      VARCHAR2(30);
l_status_code                         VARCHAR2(30);
l_claim_amt_rem                       NUMBER;
l_claim_acctd_amo_rem                 NUMBER;
l_sdc_amt_rem                         NUMBER;
l_sdc_acctd_amo_rem                   NUMBER;
l_amount_remaining                    NUMBER := 0;
l_acctd_amount_remaining              NUMBER := 0;
l_currency_code                       VARCHAR2(15);

CURSOR csr_claim_amount_rem(cv_claim_id IN NUMBER) IS
  SELECT claim_id
  ,      payment_method
  ,      status_code
  ,      NVL(SUM(amount_remaining + amount_settled),0)
  ,      NVL(SUM(acctd_amount_remaining + acctd_amount_settled),0)
  ,      currency_code
  FROM   ozf_claims_all
  WHERE  root_claim_id = cv_claim_id
  GROUP BY claim_id, payment_method, status_code, currency_code;

CURSOR csr_settlement_amount(cv_claim_id IN NUMBER) IS
  SELECT settlement_amount
  FROM ozf_settlement_docs_all
  WHERE claim_id = cv_claim_id
  AND payment_status = 'PENDING';


BEGIN
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OZF_Utility_PVT.debug_message('claim_id = '||p_claim_id);

   OPEN csr_claim_amount_rem(p_claim_id);
   LOOP
      l_claim_amt_rem         := 0;
      l_claim_acctd_amo_rem   := 0;
      l_sdc_amt_rem           := 0;
      l_sdc_acctd_amo_rem     := 0;

      FETCH csr_claim_amount_rem INTO l_claim_id
                                    , l_payment_method
                                    , l_status_code
                                    , l_claim_amt_rem
                                    , l_claim_acctd_amo_rem
                                    , l_currency_code;
      EXIT WHEN csr_claim_amount_rem%NOTFOUND;

      IF l_status_code = 'CLOSED' AND
         l_payment_method = 'MASS_SETTLEMENT' THEN
         OZF_Utility_PVT.debug_message('mass_settlement');
         OPEN csr_settlement_amount(l_claim_id);
         LOOP
            FETCH csr_settlement_amount INTO l_sdc_amt_rem;
            EXIT WHEN csr_settlement_amount%NOTFOUND;
            l_amount_remaining := l_amount_remaining + (l_sdc_amt_rem * -1);
            l_acctd_amount_remaining := l_acctd_amount_remaining + (l_sdc_amt_rem * -1);
         END LOOP;
         CLOSE csr_settlement_amount;
      ELSIF l_status_code <> 'CLOSED' THEN
         OZF_Utility_PVT.debug_message('non mass_settlement');
         l_amount_remaining := l_amount_remaining + l_claim_amt_rem;
         l_acctd_amount_remaining := l_acctd_amount_remaining + l_claim_acctd_amo_rem;
      END IF;
   END LOOP;
   CLOSE csr_claim_amount_rem;

   OZF_Utility_PVT.debug_message('l_amount_remaining='||l_amount_remaining);
   OZF_Utility_PVT.debug_message('l_acctd_amount_remaining='||l_acctd_amount_remaining);
   OZF_Utility_PVT.debug_message('l_currency_code='||l_currency_code);

   x_amount_remaining := l_amount_remaining;
   x_acctd_amount_remaining := l_acctd_amount_remaining;
   x_currency_code := l_currency_code;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_amount_remaining := 0;
      x_acctd_amount_remaining := 0;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MESSAGE.set_name('AMS', 'AMS_CLAM_GET_AMTREM_ERR');
         FND_MSG_PUB.add;
      END IF;

END Get_Amount_Remaining;


---------------------------------------------------------------------
--   PROCEDURE:  Check_Default_Setup
--
--   PURPOSE: This function checks if claim system parameters is setup.
--
--   PARAMETERS:
--
--   NOTES:
--
---------------------------------------------------------------------
--Bugfix : 7668608 - p_org_id parameter added
FUNCTION Check_Default_Setup (p_org_id IN NUMBER DEFAULT NULL)
RETURN BOOLEAN
IS
l_cm_trx_type_id    NUMBER;
l_bb_trx_type_id    NUMBER;
l_claim_type_id     NUMBER;
l_reason_code_id    NUMBER;
l_default_owner_id  NUMBER;

CURSOR csr_claim_def_setup IS
   SELECT cm_trx_type_id
   ,      billback_trx_type_id
   ,      claim_type_id
   ,      reason_code_id
   ,      default_owner_id
   FROM   ozf_sys_parameters
   WHERE  org_id = NVL(p_org_id, org_id);

BEGIN


   OPEN csr_claim_def_setup;
   FETCH csr_claim_def_setup INTO l_cm_trx_type_id
                                , l_bb_trx_type_id
                                , l_claim_type_id
                                , l_reason_code_id
                                , l_default_owner_id;
   CLOSE csr_claim_def_setup;

   IF l_cm_trx_type_id is NULL AND
      l_bb_trx_type_id is NULL THEN
      RETURN FALSE;
   ELSE
      --Check for other Default Parameters.
      IF l_claim_type_id    is NULL OR
         l_reason_code_id   is NULL OR
         l_default_owner_id is NULL THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     RETURN FALSE;

END Check_Default_Setup;

---------------------------------------------------------------------
--   PROCEDURE:  Netting_Claims_Allowed
--
--   PURPOSE:   This function returns TRUE or FALSE depending on whether
--              Netting (Subsequent Receipt Application) function is
--              allowed in TM or not.
--
--   PARAMETERS:
--
--   NOTES:
--              It returns FALSE for TM pre 11.5.10
--              It returns TRUE if TM 11.5.10 is installed.
--
---------------------------------------------------------------------
FUNCTION Netting_Claims_Allowed
RETURN BOOLEAN
IS
BEGIN
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
     RETURN TRUE;

END Netting_Claims_Allowed;



END OZF_CLAIM_INSTALL;

/
