--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_SETTLEMENT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_SETTLEMENT_VAL_PVT" AS
/* $Header: ozfvcsvb.pls 120.5.12010000.3 2010/05/17 16:57:36 kpatro ship $ */

G_PKG_NAME           CONSTANT VARCHAR2(30) := 'OZF_CLAIM_SETTLEMENT_VAL_PVT';
G_FILE_NAME          CONSTANT VARCHAR2(12) := 'ozfvcsvb.pls';

OZF_DEBUG_HIGH_ON    CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON     CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

/*=======================================================================*
 | PROCEDURE
 |    Default_Claim_Line
 |
 | NOTES
 |    This API default claim line recored against different settlement method.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Default_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_rec      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_rec_type
   ,p_def_from_tbl_flag     IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Default_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_settlement_method(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_settlement_method     VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   ------------------------------------------------
   IF p_x_claim_line_rec.source_object_class IS NULL THEN
      p_x_claim_line_rec.source_object_id := NULL;
   END IF;

   IF p_x_claim_line_rec.source_object_id IS NULL THEN
      p_x_claim_line_rec.source_object_line_id := NULL;
   END IF;

   --
   OPEN csr_settlement_method(p_x_claim_line_rec.claim_id);
   FETCH csr_settlement_method INTO l_settlement_method;
   CLOSE csr_settlement_method;

   IF p_def_from_tbl_flag = FND_API.g_false THEN
      IF l_settlement_method = 'RMA' THEN
         OZF_OM_VALIDATION_PVT.Default_Claim_Line(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_x_claim_line_rec      => p_x_claim_line_rec
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Default_Claim_Line;


/*=======================================================================*
 | PROCEDURE
 |    Default_Claim_Line_Tbl
 |
 | NOTES
 |    This API default claim line table for RMA settlement method.
 |
 | HISTORY
 |    14-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Default_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,p_validation_level      IN  NUMBER

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_x_claim_line_tbl      IN OUT NOCOPY OZF_CLAIM_LINE_PVT.claim_line_tbl_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Default_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_settlement_method(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_claim_line_rec        OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_settlement_method     VARCHAR2(30);
i                       NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   i := p_x_claim_line_tbl.FIRST;
   IF i IS NOT NULL THEN
      LOOP
         l_claim_line_rec := p_x_claim_line_tbl(i);
         Default_Claim_Line(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_x_claim_line_rec      => l_claim_line_rec
            ,p_def_from_tbl_flag     => FND_API.g_true
         );
         p_x_claim_line_tbl(i) := l_claim_line_rec;
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         EXIT WHEN i = p_x_claim_line_tbl.LAST;
         i := p_x_claim_line_tbl.NEXT(i);
      END LOOP;

      OPEN csr_settlement_method(p_x_claim_line_tbl(1).claim_id);
      FETCH csr_settlement_method INTO l_settlement_method;
      CLOSE csr_settlement_method;

      IF l_settlement_method = 'RMA' THEN
         OZF_OM_VALIDATION_PVT.Default_Claim_Line_Tbl(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_x_claim_line_tbl      => p_x_claim_line_tbl
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
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
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Default_Claim_Line_Tbl;


/*=======================================================================*
 | PROCEDURE
 |    Validate_Claim_Line
 |
 | NOTES
 |    This API validate claim line recored against RMA settlement.
 |
 | HISTORY
 |    30-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Validate_Claim_Line(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_rec        IN  OZF_CLAIM_LINE_PVT.claim_line_rec_type
   ,p_val_from_tbl_flag     IN  VARCHAR2
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_settlement_method(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

l_error                 BOOLEAN   := FALSE;
l_settlement_method     VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   OPEN csr_settlement_method(p_claim_line_rec.claim_id);
   FETCH csr_settlement_method INTO l_settlement_method;
   CLOSE csr_settlement_method;

   IF p_val_from_tbl_flag = FND_API.g_false THEN
      IF l_settlement_method = 'RMA' THEN
         OZF_OM_VALIDATION_PVT.Validate_Claim_Line(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_claim_line_rec        => p_claim_line_rec
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
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
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Validate_Claim_Line;


/*=======================================================================*
 | PROCEDURE
 |    Validate_Claim_Line_Tbl
 |
 | NOTES
 |    This API validate claim line recored against RMA settlement.
 |
 | HISTORY
 |    30-NOV-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Validate_Claim_Line_Tbl(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.g_false
   ,p_validation_level      IN  NUMBER   := FND_API.g_valid_level_full

   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER

   ,p_claim_line_tbl        IN  OZF_CLAIM_LINE_PVT.claim_line_tbl_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Validate_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1);

CURSOR csr_settlement_method(cv_claim_id IN NUMBER) IS
  SELECT payment_method
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

i                       NUMBER;
l_error                 BOOLEAN   := FALSE;
l_claim_line_rec        OZF_CLAIM_LINE_PVT.claim_line_rec_type;
l_settlement_method     VARCHAR2(15);


BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   i := p_claim_line_tbl.FIRST ;
   IF i IS NOT NULL THEN
      LOOP
         l_claim_line_rec := p_claim_line_tbl(i);
         Validate_Claim_Line(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_claim_line_rec        => l_claim_line_rec
            ,p_val_from_tbl_flag     => FND_API.g_true
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
         EXIT WHEN i = p_claim_line_tbl.LAST;
         i := p_claim_line_tbl.NEXT(i);
      END LOOP;

      OPEN csr_settlement_method(p_claim_line_tbl(1).claim_id);
      FETCH csr_settlement_method INTO l_settlement_method;
      CLOSE csr_settlement_method;

      IF l_settlement_method = 'RMA' THEN
         OZF_OM_VALIDATION_PVT.Validate_Claim_Line_Tbl(
             p_api_version           => l_api_version
            ,p_init_msg_list         => p_init_msg_list
            ,p_validation_level      => p_validation_level
            ,x_return_status         => l_return_status
            ,x_msg_data              => x_msg_data
            ,x_msg_count             => x_msg_count
            ,p_claim_line_tbl        => p_claim_line_tbl
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
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
     IF OZF_DEBUG_LOW_ON THEN
        FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT',l_full_name||' : Error');
        FND_MSG_PUB.Add;
     END IF;
     x_return_status := FND_API.g_ret_sts_unexp_error;

END Validate_Claim_Line_Tbl;


FUNCTION gl_date_in_open(
    p_application_id        IN NUMBER
   ,p_claim_id              IN NUMBER
)
RETURN BOOLEAN
IS

-- Fix for Bug 7717206
CURSOR csr_gl_date_validate( cv_app_id    IN NUMBER
                           , cv_claim_id  IN NUMBER
                           ) IS
  SELECT DECODE(MAX(gl.period_name), '', 0, 1)
  FROM   gl_period_statuses gl
  ,      ozf_claims c
  WHERE  gl.application_id = cv_app_id
  AND    c.claim_id= cv_claim_id
  AND    gl.set_of_books_id = c.set_of_books_id
  AND    gl.adjustment_period_flag = 'N'
  AND    trunc(c.gl_date) BETWEEN gl.start_date AND gl.end_date
  AND    gl.closing_status IN ('O', 'F');

l_gl_date_count   NUMBER   := 1;

BEGIN
   OPEN csr_gl_date_validate(p_application_id, p_claim_id);
   FETCH csr_gl_date_validate INTO l_gl_date_count;
   CLOSE csr_gl_date_validate;

   IF l_gl_date_count = 0 THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF OZF_DEBUG_LOW_ON THEN
         FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
         FND_MESSAGE.Set_Token('TEXT',sqlerrm);
         FND_MSG_PUB.Add;
      END IF;
      RETURN FALSE;
END gl_date_in_open;


/*=======================================================================*
 | Procedure
 |    Complete_Claim_Validation
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    24-OCT-2002  mchang  Create.
 *=======================================================================*/
PROCEDURE Complete_Claim_Validation(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_claim_rec              IN    OZF_CLAIM_PVT.claim_rec_type
   ,x_claim_rec              OUT   NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_Claim_Validation';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1)  := FND_API.g_ret_sts_success;

--Added claim_currency_amount check for bug 6828924.
CURSOR csr_claim_line(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
  ,      currency_code
  ,      amount
  ,      claim_currency_amount
  ,      acctd_amount
  ,      earnings_associated_flag
  ,      performance_complete_flag
  ,      source_object_class
  ,      source_object_id
  ,      source_object_line_id
  ,      item_id
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
    AND claim_currency_amount <> 0;

CURSOR csr_asso_offr_performance(cv_claim_line_id IN NUMBER) IS
  SELECT op.offer_performance_id
  FROM ozf_claim_lines_util lu
  ,    ozf_funds_utilized fu
  ,    ozf_offer_performances op
  WHERE lu.utilization_id = fu.utilization_id
  AND fu.component_type = 'OFFR'
  AND fu.component_id = op.list_header_id
  AND (op.requirement_type IS NULL OR op.requirement_type NOT IN ('AMOUNT', 'VOLUME'))
  AND op.required_flag = 'Y'
  AND lu.claim_line_id = cv_claim_line_id;

CURSOR csr_line_offr_performance(cv_claim_line_id IN NUMBER) IS
  SELECT op.offer_performance_id
  FROM ozf_claim_lines ln
  ,    ozf_offer_performances op
  WHERE ln.activity_type = 'OFFR'
  AND ln.activity_id = op.list_header_id
  AND (op.requirement_type IS NULL OR op.requirement_type NOT IN ('AMOUNT', 'VOLUME'))
  AND op.required_flag = 'Y'
  AND ln.claim_line_id = cv_claim_line_id;

-- Modified for FXGL Enhancement
-- Need to compare line amount with associated util_amounts
CURSOR csr_sum_util_amt(cv_claim_line_id IN NUMBER) IS
  SELECT NVL(SUM(amount), 0)
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

CURSOR csr_sum_line_amt(cv_claim_id IN NUMBER) IS
  SELECT NVL(SUM(claim_currency_amount), 0)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;

--Added claim_currency_amount check for bug 6828924.
CURSOR csr_line_prom_distinct_chk(cv_claim_id IN NUMBER) IS
  SELECT distinct earnings_associated_flag
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
    AND claim_currency_amount <> 0;

CURSOR csr_gl_date_validate(cv_app_id IN NUMBER, cv_set_of_books_id IN NUMBER) IS
  SELECT DECODE(MAX(period_name), '', 0, 1)
  FROM   gl_period_statuses
  WHERE  application_id = cv_app_id
  AND    set_of_books_id = cv_set_of_books_id
  AND    adjustment_period_flag = 'N'
  AND    SYSDATE BETWEEN start_date AND end_date
  AND    closing_status IN ('O', 'F');

CURSOR csr_sysparam_defaults IS
  SELECT post_to_gl
  ,      payables_source
  ,      batch_source_id
  ,      gl_id_ded_clearing
  ,      gl_rec_clearing_account
  ,      gl_date_type
  FROM ozf_sys_parameters;

CURSOR csr_inv_line(cv_invoice_line_id IN NUMBER) IS
  SELECT inventory_item_id
  ,      uom_code
  ,      quantity_invoiced
  FROM ra_customer_trx_lines
  WHERE customer_trx_line_id = cv_invoice_line_id;

CURSOR csr_inv_line_exist(cv_invoice_id IN NUMBER, cv_invoice_line_id IN NUMBER) IS
  SELECT customer_trx_line_id
  FROM ra_customer_trx_lines
  WHERE customer_trx_id = cv_invoice_id
  AND customer_trx_line_id = cv_invoice_line_id;

l_claim_line_id         NUMBER;
l_line_src_obj_class    VARCHAR2(15);
l_line_src_obj_id       NUMBER;
l_line_src_obj_line_id  NUMBER;
l_line_item_id          NUMBER;
l_line_currency         VARCHAR2(15);
l_line_amount           NUMBER;
l_line_claim_curr_amt   NUMBER;
l_line_acctd_amount     NUMBER;
l_line_earnings_flag    VARCHAR2(1);
l_line_perf_comp_flag   VARCHAR2(1);
l_line_sum_curr_amt     NUMBER;
l_sum_line_util_amt     NUMBER;
l_asso_earnings_exist   BOOLEAN      := FALSE;
l_promo_distinct_err    BOOLEAN      := FALSE;
l_line_amount_err       BOOLEAN      := FALSE;
l_line_util_err         BOOLEAN      := FALSE;
l_offr_perf_flag_err    BOOLEAN      := FALSE;
l_error                 BOOLEAN      := FALSE;
l_asso_offr_perf_id     NUMBER;
l_gl_count              NUMBER;
l_gl_acc_checking       VARCHAR2(1);
l_batch_source_id       NUMBER;
l_payables_source       VARCHAR2(30);
l_vendor_in_sys         NUMBER;
l_rec_clr_in_sys        NUMBER;
l_inv_item_id           RA_CUSTOMER_TRX_LINES.inventory_item_id%TYPE;
l_inv_uom_code          RA_CUSTOMER_TRX_LINES.uom_code%TYPE;
l_inv_quantity          RA_CUSTOMER_TRX_LINES.quantity_invoiced%TYPE;
l_inv_line_id           RA_CUSTOMER_TRX_LINES.customer_trx_line_id%TYPE;
l_gl_date_type          VARCHAR2(30);
l_line_mix_amt_sign     BOOLEAN      := FALSE;

-- R12: Earnings are supported for custom settlement
CURSOR csr_payment_type(cv_claim_id IN NUMBER) IS
SELECT  ocs.seeded_flag
FROM    ozf_claim_sttlmnt_methods_all  ocs,
              ozf_claims_all oc
WHERE   claim_id =  cv_claim_id
AND     ocs.claim_class = oc.claim_class
AND     NVL(ocs.source_object_class,'NULL') = NVL(oc.source_object_class,'NULL')
AND     ocs.settlement_method = oc.payment_method ;
l_seeded_flag  VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   x_claim_rec := p_claim_rec;

   ---------------------------
   -- System Parameters
   ---------------------------
   OPEN csr_sysparam_defaults;
   FETCH csr_sysparam_defaults INTO l_gl_acc_checking
                                  , l_payables_source
                                  , l_batch_source_id
                                  , l_vendor_in_sys
                                  , l_rec_clr_in_sys
                                  , l_gl_date_type;
   CLOSE csr_sysparam_defaults;

   ---------------------------
   -- Settlement Method: Required
   ---------------------------

   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message('p_claim_rec.payment_method:' || p_claim_rec.payment_method);
   END IF;

   IF (p_claim_rec.payment_method IS NULL OR p_claim_rec.payment_method = FND_API.G_MISS_CHAR
       OR p_claim_rec.payment_method = '' ) THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_PAYMETHOD_REQ');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Query Claim Line records
   OPEN csr_claim_line(p_claim_rec.claim_id);
   LOOP
      FETCH csr_claim_line INTO l_claim_line_id
                              , l_line_currency
                              , l_line_amount
                              , l_line_claim_curr_amt
                              , l_line_acctd_amount
                              , l_line_earnings_flag
                              , l_line_perf_comp_flag
                              , l_line_src_obj_class
                              , l_line_src_obj_id
                              , l_line_src_obj_line_id
                              , l_line_item_id;
      EXIT WHEN csr_claim_line%NOTFOUND;

      IF l_line_earnings_flag = FND_API.g_true THEN
         l_asso_earnings_exist :=TRUE;

         IF NOT l_offr_perf_flag_err THEN
            -- offer performance checking (1)
            OPEN csr_asso_offr_performance(l_claim_line_id);
            LOOP
               FETCH csr_asso_offr_performance INTO l_asso_offr_perf_id;
               EXIT WHEN csr_asso_offr_performance%NOTFOUND;
               IF l_line_perf_comp_flag <> FND_API.g_true THEN
                  l_offr_perf_flag_err := TRUE;
                  EXIT;
               END IF;
            END LOOP;
            CLOSE csr_asso_offr_performance;
         END IF;
      END IF;

      -- offer performance checking (2)
      IF NOT l_offr_perf_flag_err THEN
         OPEN csr_line_offr_performance(l_claim_line_id);
         LOOP
            FETCH csr_line_offr_performance INTO l_asso_offr_perf_id;
            EXIT WHEN csr_line_offr_performance%NOTFOUND;
            IF l_line_perf_comp_flag <> FND_API.g_true THEN
               l_offr_perf_flag_err := TRUE;
            EXIT;
            END IF;
         END LOOP;
         CLOSE csr_line_offr_performance;
      END IF;

      ------------------------------------
      -- If earnings are associated with Claim,
      -- claim line acctd Amount has to equal to associated earnings
      ------------------------------------
      IF l_asso_earnings_exist THEN
         OPEN csr_sum_util_amt(l_claim_line_id);
         FETCH csr_sum_util_amt INTO l_sum_line_util_amt;
         CLOSE csr_sum_util_amt;

        -- Modified for FXGL Enhancement
        -- Need to compare line amount with associated util amounts
         IF l_line_amount <> l_sum_line_util_amt THEN
            l_line_util_err := TRUE;
            EXIT;
         END IF;
      END IF;

      IF l_line_currency = p_claim_rec.currency_code THEN
         IF l_line_amount <> l_line_claim_curr_amt THEN
            l_line_amount_err := TRUE;
         END IF;
      END IF;

      -- Invoice/Order Line and Product should be the same.
      IF l_line_src_obj_class = 'INVOICE' AND
         l_line_src_obj_id IS NOT NULL THEN
         IF l_line_src_obj_line_id IS NOT NULL THEN
            OPEN csr_inv_line(l_line_src_obj_line_id);
            FETCH csr_inv_line INTO l_inv_item_id
                                  , l_inv_uom_code
                                  , l_inv_quantity;
            CLOSE csr_inv_line;

            OPEN csr_inv_line_exist(l_line_src_obj_id, l_line_src_obj_line_id);
            FETCH csr_inv_line_exist INTO l_inv_line_id;
            CLOSE csr_inv_line_exist;

            IF l_inv_line_id IS NULL THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_INV_LINE_ERR');
                  FND_MSG_PUB.add;
               END IF;
               l_error := TRUE;
            END IF;

            IF l_line_item_id IS NOT NULL AND
               l_line_item_id <> l_inv_item_id THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_SETL_VAL_LINE_ITEM_DIFF');
                  FND_MSG_PUB.add;
               END IF;
               l_error := TRUE;
            END IF;
         END IF;
      END IF;

      ------------------------------------
      -- Only promotional claims are allowed to
      -- have both positive and negative lines.
      ------------------------------------
      IF NOT l_asso_earnings_exist AND
         SIGN(p_claim_rec.amount_remaining) <> SIGN(l_line_claim_curr_amt) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_LINE_AMT_SIGN_ERR');
            FND_MSG_PUB.add;
         END IF;
         l_error := TRUE;
      END IF;

   END LOOP;
   CLOSE csr_claim_line;

   IF l_error THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   ---------------------- Validation -----------------------------
   -----------------------------------------------------
   -- If earnings are associated with Claim, Claim can only be settled by
   --     Check
   --     Credit Memo-On Account
   --     Debit Memo (for Charge claim class)
   --     Contra Charge
   -- Bug4241187: Support RMA, REG_CREDIT_MEMO, PREV CM/DM if
   -- post_to_gl flag is N.
   -- R12: Support EFT, WIRE, AP_DEBIT, PREV_OPEN_CREDIT
  --  and PREV_OPEN_DEBIT
  --- R12: Support earnings for custom settlement methods
   -----------------------------------------------------
   OPEN    csr_payment_type(p_claim_rec.claim_id);
   FETCH   csr_payment_type INTO l_seeded_flag;
   CLOSE  csr_payment_type;

   IF  l_asso_earnings_exist AND NVL(l_seeded_flag, 'N') = 'N' THEN
         NULL;
   ELSIF l_asso_earnings_exist AND NVL(l_seeded_flag, 'N') = 'Y' THEN
      IF p_claim_rec.payment_method IN ( 'CREDIT_MEMO'
                                       , 'CHECK'
                                       , 'DEBIT_MEMO'
                                       , 'CONTRA_CHARGE'
                                       , 'EFT'
                                       , 'WIRE'
                                       , 'AP_DEBIT'
                                       , 'AP_DEFAULT'
				       , 'ACCOUNTING_ONLY' --For R12.1 Enhancement
                                       ) THEN
            NULL;
       ELSIF  p_claim_rec.payment_method IN ( 'REG_CREDIT_MEMO'
                                       , 'RMA'
                                       , 'PREV_OPEN_CREDIT'
                                       , 'PREV_OPEN_DEBIT'
                                       ) THEN
            IF NVL(l_gl_acc_checking,'F') = 'T' THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_POST_ASSO_PAYMETHOD_ERR');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
      ELSE
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_SETL_ASSO_PAYMETHOD_ERR');
                FND_MSG_PUB.add;
             END IF;
             RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   ---------------------------
   -- Claim Line Validation
   ---------------------------
   -- raise error when line amount not equal to utilizations associated
   IF l_line_util_err THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_COMP_LINE_UTIL_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- raise error if performance complete is required.
   IF l_offr_perf_flag_err THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_COMP_LINE_PERF_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   OPEN csr_sum_line_amt(p_claim_rec.claim_id);
   FETCH csr_sum_line_amt INTO l_line_sum_curr_amt;
   CLOSE csr_sum_line_amt;

   -- line amount should be equal to claim_currency_amount
   -- if curreny code is the same as claim.
   IF l_line_amount_err THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_LINE_AMT_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- For payment_method other then credit memo or debit memo without specifying payment_reference,
   -- sum of line.claim_currency_amount should be equal to amount_remaining in claim.
   -- sum of line.claim_currency_amount could not be equal to amount_remaining in claim
   -- in case of 1. CREDIT_MEMO settlement
   --            2. DEBIT_MEMO settlement
   --            3. CHECK settlement
   --            4. RMA settlement
   --- R12: Also EFT, WIRE, AP_DEBIT
   IF l_line_sum_curr_amt IS NULL OR
      l_line_sum_curr_amt = 0 THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SETL_AMOUNT_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
   ELSIF l_line_sum_curr_amt <> p_claim_rec.amount_remaining THEN
      IF p_claim_rec.payment_method IN ('CREDIT_MEMO',
                                        'DEBIT_MEMO',
                                        'RMA',
                                        'CHECK',
                                        'EFT',
                                        'WIRE',
                                        'AP_DEBIT',
                                        'AP_DEFAULT',
					'ACCOUNTING_ONLY') THEN --R12.1 Enhancement
         NULL;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_SETL_AMOUNT_ERR');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   ---------------------------
   -- Fully Promotional Line Check:
   --    either promotional or non-promontial check
   ---------------------------
   OPEN csr_line_prom_distinct_chk(p_claim_rec.claim_id);
   LOOP
      FETCH csr_line_prom_distinct_chk INTO l_line_earnings_flag;
      EXIT WHEN csr_line_prom_distinct_chk%NOTFOUND;
      IF csr_line_prom_distinct_chk%ROWCOUNT > 1 THEN
         l_promo_distinct_err := TRUE;
         EXIT;
      END IF;
   END LOOP;
   CLOSE csr_line_prom_distinct_chk;

   -- raise error if earning associated flag is not distinct.
   IF l_promo_distinct_err THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_COMP_LINE_PROM_ERR');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


   ---------------------------
   -- Owner Id: Required
   ---------------------------
   IF p_claim_rec.owner_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_SETL_OWNER_REQ');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   ---------------------------
   -- GL Date: should fall into an open period if entered.
   ---------------------------
   IF p_claim_rec.gl_date IS NOT NULL THEN
         IF p_claim_rec.payment_method IN ( 'CREDIT_MEMO'
                                          , 'DEBIT_MEMO'
                                          , 'CHARGEBACK'
                                          , 'REG_CREDIT_MEMO'
                                          , 'ON_ACCT_CREDIT'
                                          , 'WRITE_OFF'
                                          , 'CONTRA_CHARGE'
					  , 'ACCOUNTING_ONLY' -- R12.1 Enhancement: For validating GL date
                                          ) THEN
            IF NOT gl_date_in_open(
                      p_application_id => 222
                    , p_claim_id       => p_claim_rec.claim_id
                   ) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_SETL_GLDATE_INVALID');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSIF p_claim_rec.payment_method IN ('CHECK', 'CONTRA_CHARGE','EFT','WIRE','AP_DEBIT','AP_DEFAULT') THEN
            IF NOT gl_date_in_open(
                      p_application_id => 200
                    , p_claim_id       => p_claim_rec.claim_id
                   ) THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_SETL_GLDATE_INVALID');
                  FND_MSG_PUB.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
   ELSE
         IF l_gl_date_type IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_GLDATE_DRIVE_ERR');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
	 END IF;
   END IF;


  /*------------------------------------------------------------------------------*
   |                           AR  Validation                                     |
   *------------------------------------------------------------------------------*/
   IF p_claim_rec.payment_method IN ( 'CREDIT_MEMO'
                                    , 'DEBIT_MEMO'
                                    , 'CHARGEBACK'
                                    , 'REG_CREDIT_MEMO'
                                    , 'ON_ACCT_CREDIT'
                                    , 'WRITE_OFF'
                                    , 'PREV_OPEN_CREDIT'
                                    , 'PREV_OPEN_DEBIT'
                                    ) THEN

      OZF_AR_VALIDATION_PVT.Complete_AR_Validation(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_rec              => p_claim_rec
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

  /*------------------------------------------------------------------------------*
   |                       RMA  Validation                                        |
   *------------------------------------------------------------------------------*/
   ELSIF p_claim_rec.payment_method = 'RMA' THEN
      OZF_AR_VALIDATION_PVT.Complete_AR_Validation(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_rec              => p_claim_rec
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      OZF_OM_VALIDATION_PVT.Complete_RMA_Validation(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_claim_rec              => p_claim_rec
         ,x_claim_rec              => x_claim_rec
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

  /*------------------------------------------------------------------------------*
   |                       AP  Validation  (CHECK,EFT,WIRE,AP_DEBIT,AP_DEFAULT    |
   *------------------------------------------------------------------------------*/
   ELSIF p_claim_rec.payment_method IN ( 'CHECK', 'EFT','WIRE','AP_DEBIT','AP_DEFAULT')  THEN
      -----------------------------------------------------
      -- Payable Source
      -----------------------------------------------------
      IF l_payables_source IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_PAYABLES_SOURCE_NULL');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -----------------------------------------------------
      -- Vendor_Id
      -----------------------------------------------------
      IF p_claim_rec.vendor_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VENDOR_REQ');
            FND_MESSAGE.set_token('PAY_METHOD', OZF_Utility_Pvt.get_lookup_meaning('OZF_PAYMENT_METHOD', p_claim_rec.payment_method));
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -----------------------------------------------------
      -- Vendor_Site_Id
      -----------------------------------------------------
      IF p_claim_rec.vendor_site_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VENDOR_SITE_REQ');
            FND_MESSAGE.set_token('PAY_METHOD', OZF_Utility_Pvt.get_lookup_meaning('OZF_PAYMENT_METHOD', p_claim_rec.payment_method));
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -----------------------------------------------------
      -- Vendor Clearing Account
      -----------------------------------------------------
      -- vendor clearing account must exist in system parameter
      IF l_gl_acc_checking = FND_API.g_true THEN
         IF l_vendor_in_sys IS NULL THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_SETL_VENCLRACC_REQ');
               FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

  /*------------------------------------------------------------------------------*
   |                         CONTRA_CHARGE                                        |
   *------------------------------------------------------------------------------*/
   ELSIF p_claim_rec.payment_method = 'CONTRA_CHARGE' THEN

      -- check vendor_id
      IF p_claim_rec.vendor_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VENDOR_REQ');
	    FND_MESSAGE.set_token('PAY_METHOD', OZF_Utility_Pvt.get_lookup_meaning('OZF_PAYMENT_METHOD', p_claim_rec.payment_method));
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check vendor_site_id
      IF p_claim_rec.vendor_site_id IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_SETL_VENDOR_SITE_REQ');
	    FND_MESSAGE.set_token('PAY_METHOD', OZF_Utility_Pvt.get_lookup_meaning('OZF_PAYMENT_METHOD', p_claim_rec.payment_method));
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


  /*------------------------------------------------------------------------------*
   |             NON-SEEDED PAYMENT METHOD                                        |
   *------------------------------------------------------------------------------*/
   ELSE

      -- R12: Validate depending on AR or AP Settlement
      NULL;

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

END Complete_Claim_Validation;

/*=======================================================================*
 | Procedure
 |    Complete_Claim
 |
 | Return
 |
 | NOTES
 |
 | HISTORY
 |    16-JAN-2003  mchang  Create.
 *=======================================================================*/
PROCEDURE Complete_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_validation_level       IN    NUMBER

   ,x_return_status          OUT   NOCOPY VARCHAR2
   ,x_msg_data               OUT   NOCOPY VARCHAR2
   ,x_msg_count              OUT   NOCOPY NUMBER

   ,p_x_claim_rec            IN OUT NOCOPY OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Complete_Claim';
l_full_name    CONSTANT VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
l_return_status         VARCHAR2(1)  := FND_API.g_ret_sts_success;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_Utility_PVT.debug_message(l_full_name||' : start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.g_ret_sts_success;

   IF p_x_claim_rec.payment_method = 'RMA' THEN
      IF p_x_claim_rec.order_type_id IS NULL THEN
         OZF_OM_VALIDATION_PVT.Get_Default_Order_Type(
             p_api_version          => l_api_version
            ,p_init_msg_list        => FND_API.g_false
            ,p_validation_level     => FND_API.g_valid_level_full
            ,x_return_status        => l_return_status
            ,x_msg_data             => x_msg_data
            ,x_msg_count            => x_msg_count
            ,p_reason_code_id       => p_x_claim_rec.reason_code_id
            ,p_claim_type_id        => p_x_claim_rec.claim_type_id
            ,p_set_of_books_id      => p_x_claim_rec.set_of_books_id
            ,x_order_type_id        => p_x_claim_rec.order_type_id
         );
         IF l_return_status =  FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
   ELSE
      -- erase RMA transaction type if not for RMA settlement.
      p_x_claim_rec.order_type_id := NULL;
   END IF;

   IF p_x_claim_rec.payment_method NOT IN ('PREV_OPEN_CREDIT', 'PREV_OPEN_DEBIT', 'CHECK', 'RMA','EFT',
                       'AP_DEFAULT','WIRE','AP_DEBIT') THEN
      p_x_claim_rec.payment_reference_id := NULL;
      p_x_claim_rec.payment_reference_number := NULL;
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

END Complete_Claim;


END OZF_CLAIM_SETTLEMENT_VAL_PVT;

/
