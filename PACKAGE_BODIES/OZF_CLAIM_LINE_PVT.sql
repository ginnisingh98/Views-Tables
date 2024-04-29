--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_LINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_LINE_PVT" AS
/* $Header: ozfvclnb.pls 120.23.12010000.7 2010/04/30 09:53:13 kpatro ship $ */

g_pkg_name   CONSTANT VARCHAR2(30):='OZF_Claim_Line_PVT';

g_delete     CONSTANT VARCHAR2(30):='DELETE';

G_FUNCTIONAL_CURRENCY           VARCHAR2(15) := NULL;
G_OFFER_CURRENCY                VARCHAR2(15) := NULL;
G_CLAIM_SET_OF_BOOKS_ID         NUMBER       := NULL;
G_CLAIM_CURRENCY                VARCHAR2(15) := NULL;
G_CLAIM_EXC_TYPE                VARCHAR2(30) := NULL;
G_CLAIM_EXC_DATE                DATE         := NULL;
G_CLAIM_EXC_RATE                NUMBER       := NULL;

-- object_type
G_CLAIM_OBJECT_TYPE    CONSTANT VARCHAR2(30) := 'CLAM';

OZF_DEBUG_HIGH_ON      CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON       CONSTANT BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);



---------------------------------------------------------------------
-- FUNCTION
--   Compare_Line_Items
--
-- NOTES
--    1. Compare_Line_Items function will return FND_API.g_true/false;
--    2. Return FND_API.g_true: Compare is the same;
--    3. Return FND_API.g_false: Compare is not the same;
--
-- HISTORY
--   02/01/2001  mchang  Created.
--   07/02/2001  mchang  Incorporated with AMS_COLUMN_RULES to look up history
--                       rule setting by user.
--   07/26/2001  mchang  Add Tax_Code as a comparing column.
---------------------------------------------------------------------
FUNCTION Compare_Line_Items(
    p_old_rec           IN  claim_line_rec_type
  , p_new_rec           IN  claim_line_rec_type
  , p_object_attribute  IN  VARCHAR2
)
RETURN VARCHAR2
IS
CURSOR  csr_user_hist_cols(cv_object_attribute IN VARCHAR2) IS
  SELECT  db_column_name
  --,       ak_attribute_code
  FROM    ams_column_rules
  WHERE   db_table_name = 'OZF_CLAIM_LINES_ALL'
  AND     rule_type = 'HISTORY'
  AND     object_type = 'CLAM'
  AND     object_attribute = cv_object_attribute;

l_line_hist_col   VARCHAR2(80);
l_return          VARCHAR2(1)     := FND_API.g_true;

BEGIN
  OPEN csr_user_hist_cols(p_object_attribute);
  LOOP
    FETCH csr_user_hist_cols INTO l_line_hist_col;
    EXIT WHEN csr_user_hist_cols%NOTFOUND;
    EXIT WHEN l_return = FND_API.g_false;
    IF l_line_hist_col = 'VALID_FLAG' AND
       p_old_rec.valid_flag <> p_new_rec.valid_flag THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'PERFORMANCE_COMPLETE_FLAG' AND
          p_old_rec.performance_complete_flag <> p_new_rec.performance_complete_flag THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'PERFORMANCE_ATTACHED_FLAG' AND
          p_old_rec.performance_attached_flag <> p_new_rec.performance_attached_flag THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'EARNINGS_ASSOCIATED_FLAG' AND
          p_old_rec.earnings_associated_flag <> p_new_rec.earnings_associated_flag THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'CLAIM_CURRENCY_AMOUNT' AND
          p_old_rec.claim_currency_amount <> p_new_rec.claim_currency_amount THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'ACTIVITY_TYPE' AND
          p_old_rec.activity_type <> p_new_rec.activity_type THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'ACTIVITY_ID' AND
          p_old_rec.activity_id <> p_new_rec.activity_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'PLAN_ID' AND
          p_old_rec.plan_id <> p_new_rec.plan_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'OFFER_ID' AND
          p_old_rec.offer_id <> p_new_rec.offer_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'SOURCE_OBJECT_ID' AND
          p_old_rec.source_object_id <> p_new_rec.source_object_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'SOURCE_OBJECT_LINE_ID' AND
          p_old_rec.source_object_line_id <> p_new_rec.source_object_line_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'SOURCE_OBJECT_CLASS' AND
          p_old_rec.source_object_class <> p_new_rec.source_object_class THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'QUANTITY' AND
          p_old_rec.quantity <> p_new_rec.quantity THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'RATE' AND
          p_old_rec.rate <> p_new_rec.rate THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'QUANTITY_UOM' AND
          p_old_rec.quantity_uom <> p_new_rec.quantity_uom THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'ITEM_ID' AND
          p_old_rec.item_id <> p_new_rec.item_id THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'ITEM_DESCRIPTION' AND
          p_old_rec.item_description <> p_new_rec.item_description THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'COMMENTS' AND
          p_old_rec.comments <> p_new_rec.comments THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'TAX_CODE' AND
          p_old_rec.tax_code <> p_new_rec.tax_code THEN
      l_return := FND_API.g_false;
    ELSIF l_line_hist_col = 'CREDIT_TO' AND
          p_old_rec.credit_to <> p_new_rec.credit_to THEN
      l_return := FND_API.g_false;
--    ELSE
--      l_return := FND_API.g_true;
    END IF;
  END LOOP;
  CLOSE csr_user_hist_cols;

  RETURN l_return;

END Compare_Line_Items;

---------------------------------------------------------------------
-- FUNCTION
--    get_default_product_uom
--
-- PURPOSE
--    This returns default uom for a product
--
-- PARAMETERS
--    p_reason_code_id
--    p_org_id
--
-- NOTES
---------------------------------------------------------------------
FUNCTION Get_Default_Product_UOM(p_product_id in NUMBER
                       , p_org_id     in NUMBER
                       )
RETURN VARCHAR2
IS

CURSOR default_uom_csr (p_id in number, p_orgid in number) is
select primary_uom_code
from mtl_system_items
where inventory_item_id = p_id
and organization_id = p_orgid;

l_default_uom varchar2(30);
BEGIN

   If ((p_product_id is not null and p_product_id <> FND_API.G_MISS_NUM)
       AND (p_org_id is not null and p_org_id <> FND_API.G_MISS_NUM))
   THEN
       OPEN default_uom_csr(p_product_id, p_org_id);
       FETCH default_uom_csr into l_default_uom;
       CLOSE default_uom_csr;

   ELSE
      l_default_uom := null;
   END IF;
        return l_default_uom;

END Get_Default_Product_UOM;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Create_Line_Hist
--
-- NOTES
--    1. p_mode should be JTF_PLSQL_API.g_create/update, or g_delete
--    2. x_create_hist_flag will be set to 'Y' or 'N'
--    3. p_object_attribute could be 'LINE' or 'LNDT'.
--
-- HISTORY
--    02/01/2001  mchang  Create.
--    07/26/2001  mchang  Add Tax_Code as a history rule checking column.
--    08/13/2001  mchang  Add p_object_attribute as passing in parameter.
---------------------------------------------------------------------
PROCEDURE Check_Create_Line_Hist(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_mode              IN  VARCHAR2
  ,p_claim_line_rec    IN  claim_line_rec_type
  ,p_object_attribute  IN  VARCHAR2
  ,x_create_hist_flag  OUT NOCOPY VARCHAR2
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Check_Create_Line_Hist';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_return_status        VARCHAR2(1);
l_new_line_rec         claim_line_rec_type;
l_old_line_rec         claim_line_rec_type;
l_compare_result       VARCHAR2(1);

CURSOR c_claim_old_line(cv_claim_line_id  IN NUMBER) IS
  SELECT claim_id
      , valid_flag
      , performance_complete_flag
      , performance_attached_flag
      , earnings_associated_flag
      , set_of_books_id
      , claim_currency_amount
      , amount
      , acctd_amount
      , activity_type
      , activity_id
      , plan_id
      , offer_id
      , source_object_id
      , source_object_line_id
      , source_object_class
      , quantity
      , rate
      , quantity_uom
      , item_id
      , item_description
      , comments
      , tax_code
      , credit_to
  FROM  ozf_claim_lines_hist
  WHERE  claim_line_id = cv_claim_line_id
  order by claim_line_history_id desc;

BEGIN
   --------------------- initialize -----------------------
   SAVEPOINT Check_Create_Line_Hist;

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

   IF p_mode <> 'CREATE' THEN
      -- replace g_miss_char/num/date with current column values
      Complete_Claim_Line_Rec(
            p_claim_line_rec     =>  p_claim_line_rec
           ,x_complete_rec       =>  l_new_line_rec
      );
   ELSE
      l_new_line_rec := p_claim_line_rec;
   END IF;


   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ start -------------------------
   -- fetch out old claim line record
   IF p_mode = JTF_PLSQL_API.g_create THEN
      l_old_line_rec := null;
   ELSE
      IF p_claim_line_rec.claim_line_id <> FND_API.g_miss_num
        AND p_claim_line_rec.claim_line_id IS NOT NULL  THEN
         OPEN c_claim_old_line(p_claim_line_rec.claim_line_id);
         FETCH c_claim_old_line INTO l_old_line_rec.claim_id
                                   , l_old_line_rec.valid_flag
                                   , l_old_line_rec.performance_complete_flag
                                   , l_old_line_rec.performance_attached_flag
                                   , l_old_line_rec.earnings_associated_flag
                                   , l_old_line_rec.set_of_books_id
                                   , l_old_line_rec.claim_currency_amount
                                   , l_old_line_rec.amount
                                   , l_old_line_rec.acctd_amount
                                   , l_old_line_rec.activity_type
                                   , l_old_line_rec.activity_id
                                   , l_old_line_rec.plan_id
                                   , l_old_line_rec.offer_id
                                   , l_old_line_rec.source_object_id
                                   , l_old_line_rec.source_object_line_id
                                   , l_old_line_rec.source_object_class
                                   , l_old_line_rec.quantity
                                   , l_old_line_rec.rate
                                   , l_old_line_rec.quantity_uom
                                   , l_old_line_rec.item_id
                                   , l_old_line_rec.item_description
                                   , l_old_line_rec.comments
                                   , l_old_line_rec.tax_code
                                   , l_old_line_rec.credit_to;
         CLOSE c_claim_old_line;
      END IF;
   END IF;
   ------------------------ comparison -------------------------
   IF p_mode = JTF_PLSQL_API.g_create
   THEN
      x_create_hist_flag := 'Y';

   --In create mode always create a history record.

   --   Init_Claim_Line_Rec(
   --       x_claim_line_rec   => l_old_line_rec
   --   );
   --   l_compare_result := Compare_Line_Items(
   --                          p_old_rec          =>  l_old_line_rec
   --                        ,p_new_rec          =>  l_new_line_rec
   --                         ,p_object_attribute =>  p_object_attribute
   --                      );
   --   IF l_compare_result = FND_API.g_true  THEN
   --      x_create_hist_flag := 'N';
   --   ELSE
   --      x_create_hist_flag := 'Y';
   --   END IF;


   ELSIF p_mode = g_delete THEN
      --x_create_hist_flag := 'Y';
      l_compare_result := Compare_Line_Items(
                             p_old_rec          =>  l_old_line_rec
                            ,p_new_rec          =>  l_new_line_rec
                            ,p_object_attribute =>  p_object_attribute
                         );
      IF l_compare_result = FND_API.g_true  THEN
         x_create_hist_flag := 'N';
      ELSE
         x_create_hist_flag := 'Y';
      END IF;
   ELSIF p_mode = JTF_PLSQL_API.g_update THEN
      l_compare_result := Compare_Line_Items(
                             p_old_rec          =>  l_old_line_rec
                            ,p_new_rec          =>  l_new_line_rec
                            ,p_object_attribute =>  p_object_attribute
                         );
      IF l_compare_result = FND_API.g_true  THEN
         x_create_hist_flag := 'N';
      ELSE
         x_create_hist_flag := 'Y';
      END IF;
   ELSE
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message(l_full_name||': p_mode should be CREATE, UPDATE, or DELETE');
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   ------------------------- finish -------------------------------
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
      ROLLBACK TO Check_Create_Line_Hist;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Check_Create_Line_Hist;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN OTHERS THEN
      ROLLBACK TO Check_Create_Line_Hist;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
                THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Check_Create_Line_Hist;

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Line_Amount
--
-- HISTORY
--    29-AUG-2001  mchang  Create.
--    06-AUG-2001  mchang  Updated :  Convert Line Amount from Acctd_Amount
---------------------------------------------------------------------
PROCEDURE Convert_Line_Amount(
    p_claim_line_rec    IN  claim_line_rec_type
   ,x_claim_line_rec    OUT NOCOPY claim_line_rec_type
   ,x_return_status     OUT NOCOPY VARCHAR2
) IS
l_api_name     CONSTANT VARCHAR2(30) := 'Convert_Line_Amount';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

-- fix for bug 5042046
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

CURSOR csr_claim_currency(cv_claim_id IN NUMBER) IS
  SELECT currency_code
  FROM   ozf_claims
  WHERE  claim_id = cv_claim_id;

CURSOR csr_order_default_exc(cv_doc_id IN NUMBER) IS
  SELECT transactional_curr_code
  ,      conversion_type_code
  ,      conversion_rate
  ,      conversion_rate_date
  FROM oe_order_headers
  WHERE header_id = cv_doc_id;

CURSOR csr_invoice_default_exc(cv_doc_id IN NUMBER) IS
  SELECT invoice_currency_code
  ,      exchange_rate_type
  ,      exchange_rate
  ,      exchange_date
  FROM ra_customer_trx
  WHERE customer_trx_id = cv_doc_id;
/*
CURSOR csr_invline_default_exc(cv_doc_id IN NUMBER) IS
  SELECT h.invoice_currency_code
  ,      h.exchange_rate_type
  ,      h.exchange_rate
  ,      h.exchange_date
  FROM ra_customer_trx h, ra_customer_trx_lines ln
  WHERE h.customer_trx_id = ln.customer_trx_id
  AND ln.customer_trx_line_id = cv_doc_id;
*/
CURSOR csr_pcho_default_exc(cv_doc_id IN NUMBER) IS
  SELECT currency_code
  ,      rate_type
  ,      rate
  ,      rate_date
  FROM po_headers
  WHERE po_header_id = cv_doc_id;

l_return_status          VARCHAR2(1);
l_claim_currency         VARCHAR2(15);
l_function_currency      VARCHAR2(15);
l_default_currency       VARCHAR2(15)     := NULL;
l_default_exc_type       VARCHAR2(30);
l_default_exc_date       DATE;
l_default_exc_rate       NUMBER;
l_line_amount            NUMBER;
l_rate                   NUMBER;
l_tri_denominator        NUMBER;
l_tri_numerator          NUMBER;

l_claim_line_rec         claim_line_rec_type := p_claim_line_rec;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  IF p_claim_line_rec.source_object_id IS NOT NULL THEN
    IF p_claim_line_rec.source_object_class IN ('INVOICE', 'CB', 'DM') THEN
      OPEN csr_invoice_default_exc(p_claim_line_rec.source_object_id);
      FETCH csr_invoice_default_exc INTO l_default_currency,
                                         l_default_exc_type,
                                         l_default_exc_rate,
                                         l_default_exc_date;
      CLOSE csr_invoice_default_exc;
    ELSIF p_claim_line_rec.source_object_class = 'ORDER' THEN
      OPEN csr_order_default_exc(p_claim_line_rec.source_object_id);
      FETCH csr_order_default_exc INTO l_default_currency,
                                       l_default_exc_type,
                                       l_default_exc_rate,
                                       l_default_exc_date;
      CLOSE csr_order_default_exc;
    ELSIF p_claim_line_rec.source_object_class = 'PCHO' THEN
      OPEN csr_pcho_default_exc(p_claim_line_rec.source_object_id);
      FETCH csr_pcho_default_exc INTO l_default_currency,
                                      l_default_exc_type,
                                      l_default_exc_rate,
                                      l_default_exc_date;
      CLOSE csr_pcho_default_exc;
    END IF;
  END IF;

  IF l_default_currency IS NOT NULL THEN
    OPEN csr_claim_currency(p_claim_line_rec.claim_id);
    FETCH csr_claim_currency INTO l_claim_currency;
    CLOSE csr_claim_currency;

    /*
    BEGIN
      GL_CURRENCY_API.get_triangulation_rate (
          x_from_currency   => l_default_currency,
          x_to_currency     => l_claim_currency,
          x_conversion_date => l_default_exc_date,
          x_conversion_type => l_default_exc_type,
          x_denominator     => l_tri_denominator,
          x_numerator       => l_tri_numerator,
          x_rate            => l_rate
      );
    EXCEPTION
      WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TRIANG_API_ERR');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
    END;

    l_line_amount := p_claim_line_rec.claim_currency_amount * l_rate;
    */
     IF l_default_currency = l_claim_currency THEN
          l_claim_line_rec.amount := l_claim_line_rec.claim_currency_amount;
          l_claim_line_rec.currency_code := l_default_currency;
          l_claim_line_rec.exchange_rate_type := l_default_exc_type;
          l_claim_line_rec.exchange_rate_date := l_default_exc_date;
          l_claim_line_rec.exchange_rate := l_default_exc_rate;
       ELSE
        OPEN csr_function_currency;
        FETCH csr_function_currency INTO l_function_currency;
        CLOSE csr_function_currency;
        OZF_UTILITY_PVT.Convert_Currency(
         p_from_currency   => l_function_currency
        ,p_to_currency     => l_default_currency
        ,p_conv_type       => l_default_exc_type
        ,p_conv_rate       => 1/l_default_exc_rate -- Bug4437696
        ,p_conv_date       => l_default_exc_date
        ,p_from_amount     => p_claim_line_rec.acctd_amount
        ,x_return_status   => l_return_status
        ,x_to_amount       => l_line_amount
        ,x_rate            => l_rate
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_claim_line_rec.currency_code := l_default_currency;
        l_claim_line_rec.exchange_rate_type := l_default_exc_type;
        l_claim_line_rec.exchange_rate_date := l_default_exc_date;
        l_claim_line_rec.exchange_rate := 1/l_rate; -- Bug4437696
        l_claim_line_rec.amount := l_line_amount;
     END IF;
  END IF;

  x_claim_line_rec := l_claim_line_rec;

EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_return_status := FND_API.g_ret_sts_error;

  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.set_token('TEXT', l_full_name||': An error happened while converting line amount');
      FND_MSG_PUB.add;
    END IF;

END Convert_Line_Amount;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Line_Fm_Claim
--
-- HISTORY
--    07/26/2001  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Update_Line_Fm_Claim(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_new_claim_rec          IN    OZF_CLAIM_PVT.claim_rec_type
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Update_Line_Fm_Claim';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_old_claim_rec         OZF_CLAIM_PVT.claim_rec_type;
l_upd_line_flag         VARCHAR2(1)  := FND_API.g_false;
l_remove_tax_code       VARCHAR2(1)  := FND_API.g_false;
l_remove_related_cust   VARCHAR2(1)  := FND_API.g_false;
l_amount_change_flag    VARCHAR2(1)  := FND_API.g_false;   --Bug:2781186

l_claim_line_tbl        claim_line_tbl_type;
l_line_counter          NUMBER       := 1;
l_object_version        NUMBER;
l_claim_line_count      NUMBER := 0;   --Bug:2781186
l_claim_line_amount     NUMBER := 0;   --Bug:2781186


CURSOR csr_claim_old_rec(cv_claim_id IN NUMBER) IS
  SELECT currency_code
       , exchange_rate_type
       , exchange_rate_date
       , exchange_rate
       , cust_account_id
       , payment_method
       , tax_code
       , set_of_books_id
       , amount         -- Bug:2781186
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

CURSOR csr_line_rec_upd(cv_claim_id IN NUMBER) IS
  SELECT claim_line_id
       , object_version_number
       , claim_currency_amount
       , tax_code
       , earnings_associated_flag   --Bug:2781186
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id;


   --Start:Bug:2781186
-- get how many claim lines for the given claim. If count is greate than 1 means
-- user has modified the line amount and he must be investigating this claim.
CURSOR csr_claim_line_count(cv_claim_id IN NUMBER) IS
SELECT count(*)
FROM   ozf_claim_lines
WHERE  claim_id = cv_claim_id;

CURSOR csr_get_line_amount(cv_claim_id IN NUMBER) IS
SELECT claim_currency_amount
FROM   ozf_claim_lines
WHERE  claim_id = cv_claim_id;
--End:Bug:2781186


BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Update_Line_Fm_Claim;

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

  -------------------------- start ----------------------------
  OPEN csr_claim_old_rec(p_new_claim_rec.claim_id);
  FETCH csr_claim_old_rec INTO l_old_claim_rec.currency_code
                             , l_old_claim_rec.exchange_rate_type
                             , l_old_claim_rec.exchange_rate_date
                             , l_old_claim_rec.exchange_rate
                             , l_old_claim_rec.cust_account_id
                             , l_old_claim_rec.payment_method
                             , l_old_claim_rec.tax_code
                             , G_CLAIM_SET_OF_BOOKS_ID
                             , l_old_claim_rec.amount;   --Bug:2781186
  CLOSE csr_claim_old_rec;

  -- change in currency_code and exchange_rates
  IF (  p_new_claim_rec.currency_code <> FND_API.g_miss_char
      AND
        p_new_claim_rec.currency_code <> l_old_claim_rec.currency_code )
  THEN
      l_upd_line_flag := FND_API.g_true;
      G_CLAIM_CURRENCY := p_new_claim_rec.currency_code;
  ELSE
      G_CLAIM_CURRENCY := l_old_claim_rec.currency_code;
  END IF;


  IF ( p_new_claim_rec.exchange_rate_type <> FND_API.g_miss_char
       AND
       NVL(p_new_claim_rec.exchange_rate_type,FND_API.g_miss_char) <> NVL(l_old_claim_rec.exchange_rate_type,FND_API.g_miss_char))
  THEN
      l_upd_line_flag := FND_API.g_true;
      G_CLAIM_EXC_TYPE := p_new_claim_rec.exchange_rate_type;
  ELSE
      G_CLAIM_EXC_TYPE := l_old_claim_rec.exchange_rate_type;
  END IF;

  IF ( p_new_claim_rec.exchange_rate_date <> FND_API.g_miss_date
       AND
       NVL(p_new_claim_rec.exchange_rate_date,FND_API.g_miss_date) <> NVL(l_old_claim_rec.exchange_rate_date,FND_API.g_miss_date))
  THEN
      l_upd_line_flag := FND_API.g_true;
      G_CLAIM_EXC_DATE := p_new_claim_rec.exchange_rate_date;
  ELSE
      G_CLAIM_EXC_DATE := l_old_claim_rec.exchange_rate_date;
  END IF;

 IF ( p_new_claim_rec.exchange_rate <> FND_API.g_miss_num
       AND
      NVL(p_new_claim_rec.exchange_rate,FND_API.g_miss_num) <> NVL(l_old_claim_rec.exchange_rate,FND_API.g_miss_num))
 THEN
     l_upd_line_flag := FND_API.g_true;
      G_CLAIM_EXC_RATE := p_new_claim_rec.exchange_rate;
 ELSE
      G_CLAIM_EXC_RATE := l_old_claim_rec.exchange_rate;
 END IF;


  -- change in cust_account_id
  IF (  p_new_claim_rec.cust_account_id <> FND_API.g_miss_num
     AND p_new_claim_rec.cust_account_id <> l_old_claim_rec.cust_account_id) THEN
    l_upd_line_flag := FND_API.g_true;
    l_remove_related_cust := FND_API.g_true;
  END IF;

  -- change in settlement method
  IF ( p_new_claim_rec.payment_method <> FND_API.g_miss_char
     AND
       NVL(p_new_claim_rec.payment_method,FND_API.g_miss_char) <> NVL(l_old_claim_rec.payment_method,FND_API.g_miss_char))
 THEN
      l_upd_line_flag := FND_API.g_true;
      l_remove_tax_code := FND_API.g_true;
 END IF;

 -- change in tax_code
 IF (  p_new_claim_rec.tax_code <> FND_API.g_miss_char
     AND
       NVL(p_new_claim_rec.tax_code,FND_API.g_miss_char) <> NVL(l_old_claim_rec.tax_code,FND_API.g_miss_char))
 THEN
    l_upd_line_flag := FND_API.g_true;
 END IF;


  -- Bug4489415: Pass tax_action to claim line
  IF (p_new_claim_rec.tax_action is not null  AND p_new_claim_rec.tax_action <> FND_API.g_miss_char)     THEN
    l_upd_line_flag := FND_API.g_true;
  END IF;

-- ----------------------------------------------------------------------------
  -- Bug        : 2781186
  -- Changed by : Uday Poluri  Date: 03-Jun-2003
  -- Comments   : Check for change in deduction amount
  -- ----------------------------------------------------------------------------
  IF (p_new_claim_rec.amount is not null AND p_new_claim_rec.amount <> FND_API.g_miss_num)
     AND p_new_claim_rec.amount <> l_old_claim_rec.amount THEN

    --Count how many records are present in claim_lines
    OPEN csr_claim_line_count(p_new_claim_rec.claim_id);
    FETCH csr_claim_line_count INTO l_claim_line_count;
    CLOSE csr_claim_line_count;

    -- if l_claim_line_count is 1 means claim user has not touch this line.so it is ok to update.
    IF l_claim_line_count = 1 THEN
      --Get line Amount1
      OPEN csr_get_line_amount(p_new_claim_rec.claim_id);
      FETCH csr_get_line_amount INTO l_claim_line_amount;
      CLOSe csr_get_line_amount;

      --Compare new deduction amount with line amount if it is less then only update.
      --IF p_new_claim_rec.amount < l_claim_line_amount THEN
      --IF p_new_claim_rec.amount_remaining <> l_claim_line_amount THEN   --Changed on 11-Mar-03
      IF p_new_claim_rec.amount <> l_claim_line_amount THEN   --Changed on 12-Mar-03
        l_upd_line_flag      := FND_API.g_true;
        l_amount_change_flag := FND_API.g_true;
      END IF;

    END IF;
  END IF;
  -- End Bug: 2781186 -----------------------------------------------------------


  -------------------- Update Claim Line ----------------------
  IF l_upd_line_flag = FND_API.g_true THEN
    OPEN csr_line_rec_upd(p_new_claim_rec.claim_id);
    LOOP
      Init_Claim_Line_Rec(
          x_claim_line_rec   => l_claim_line_tbl(l_line_counter)
      );
      FETCH csr_line_rec_upd INTO l_claim_line_tbl(l_line_counter).claim_line_id
                                , l_claim_line_tbl(l_line_counter).object_version_number
                                , l_claim_line_tbl(l_line_counter).claim_currency_amount
                                , l_claim_line_tbl(l_line_counter).tax_code
                                , l_claim_line_tbl(l_line_counter).earnings_associated_flag;   --Bug:2781186
      IF OZF_DEBUG_HIGH_ON THEN
         OZF_Utility_PVT.debug_message('ULFC:STEP 4:'||'line_tbl('||l_line_counter||')'||
                               l_claim_line_tbl(l_line_counter).claim_currency_amount);
      END IF;
      l_line_counter := l_line_counter + 1;
      EXIT WHEN csr_line_rec_upd%NOTFOUND;
    END LOOP;
    CLOSE csr_line_rec_upd;

    -- assign new value in claim line rec
    FOR i IN l_claim_line_tbl.FIRST..l_claim_line_tbl.LAST LOOP

      IF l_claim_line_tbl(i).claim_line_id IS NOT NULL AND
         l_claim_line_tbl(i).claim_line_id <> FND_API.g_miss_num THEN

         -- Modified for Bug4489415
        IF l_remove_tax_code = FND_API.g_true THEN
          l_claim_line_tbl(i).tax_code   := NVL(p_new_claim_rec.tax_code,FND_API.g_miss_char);
          l_claim_line_tbl(i).tax_amount := FND_API.g_miss_num;
          l_claim_line_tbl(i).acctd_tax_amount := FND_API.g_miss_num;
          l_claim_line_tbl(i).claim_curr_tax_amount := FND_API.g_miss_num;
        ELSE
          IF l_claim_line_tbl(i).tax_code = l_old_claim_rec.tax_code
                    OR l_claim_line_tbl(i).tax_code IS NULL THEN
            l_claim_line_tbl(i).tax_code := p_new_claim_rec.tax_code;
          END IF;
        END IF;



        l_claim_line_tbl(i).tax_action :=  p_new_claim_rec.tax_action; -- Bug4489415

        IF l_remove_related_cust = FND_API.g_true THEN
          l_claim_line_tbl(i).earnings_associated_flag := FND_API.g_false;
          l_claim_line_tbl(i).relationship_type := FND_API.g_miss_char;
          l_claim_line_tbl(i).related_cust_account_id := FND_API.g_miss_num;
        END IF;

        -- ----------------------------------------------------------------------------
        -- Bug        : 2781186
        -- Comments   : Check for amount_change_flag
        -- ----------------------------------------------------------------------------
        IF l_amount_change_flag = FND_API.g_true THEN
        l_claim_line_tbl(i).claim_currency_amount := p_new_claim_rec.amount;
          IF l_claim_line_tbl(i).earnings_associated_flag = 'T' THEN
            --Delete associated earnings lines.
            l_claim_line_tbl(i).earnings_associated_flag := FND_API.g_false;
          END IF;
        END IF;
        -- End Bug: 2781186 -----------------------------------------------------------


        l_claim_line_tbl(i).update_from_tbl_flag := FND_API.g_true;

        -- Call the update_claim_line API
        Update_Claim_Line(
                   p_api_version       => 1.0
                 , p_init_msg_list     => FND_API.g_false
                 , p_commit            => FND_API.g_false
                 , p_validation_level  => p_validation_level
                 , x_return_status     => l_return_status
                 , x_msg_data          => x_msg_data
                 , x_msg_count         => x_msg_count
                 , p_claim_line_rec    => l_claim_line_tbl(i)
                 , x_object_version    => l_object_version
        );
        IF l_return_status =  fnd_api.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
      END IF;
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
    ROLLBACK TO Update_Line_Fm_Claim;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Line_Fm_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Line_Fm_Claim;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Update_Line_Fm_Claim;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Line_Tbl
--
-- HISTORY
--    02/02/2001  mchang  Create.
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver_tbl
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver_tbl
--    23/01/2002  slkrishn modified amount checking conditions
--    07/22/2002  yizhang add p_mode for security check
---------------------------------------------------------------------
PROCEDURE Create_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_claim_line_rec        claim_line_rec_type;
l_claim_line_tbl        claim_line_tbl_type;
l_claim_line_id         NUMBER;
l_utiz_obj_ver          NUMBER;
l_create_total_amt      NUMBER := 0;
l_exist_total_amt       NUMBER;
l_claim_amount          NUMBER;
l_claim_class           VARCHAR2(30);
l_claim_id              NUMBER;
l_currency_code         VARCHAR2(15);
l_access                VARCHAR2(1) := 'N';

-- Cursor to get claim amount
CURSOR c_claim_amount(cv_claim_id IN NUMBER) IS
 SELECT amount_remaining, claim_class
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

-- Cursor to get claim amount
CURSOR c_exist_total_line_amt(cv_claim_id IN NUMBER) IS
 SELECT NVL(SUM(claim_currency_amount), 0)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id;

CURSOR c_claim(cv_claim_id IN NUMBER) IS
 SELECT currency_code
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_Line_Tbl;

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

  l_claim_line_tbl := p_claim_line_tbl;

  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_claim_line_tbl.count > 0 THEN
    FOR j IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
      IF p_claim_line_tbl.EXISTS(j) THEN
        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => p_claim_line_tbl(j).claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => l_msg_count
             , X_Msg_Data           => l_msg_data
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

  ------------ Default Claim Line by Settlement Method ----------------
  OZF_CLAIM_SETTLEMENT_VAL_PVT.Default_Claim_Line_Tbl(
    p_api_version           => l_api_version
   ,p_init_msg_list         => FND_API.g_false
   ,p_validation_level      => p_validation_level
   ,x_return_status         => l_return_status
   ,x_msg_data              => x_msg_data
   ,x_msg_count             => x_msg_count
   ,p_x_claim_line_tbl      => l_claim_line_tbl
  );
   IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  --------------------- Amount Checking -----------------------
  IF l_claim_line_tbl.count > 0 THEN
    OPEN c_claim(l_claim_line_tbl(1).claim_id);
    FETCH c_claim INTO l_currency_code;
    CLOSE c_claim;

    FOR j IN l_claim_line_tbl.FIRST..l_claim_line_tbl.LAST LOOP
      IF l_claim_line_tbl.EXISTS(j) THEN
        -- calculate claim currency amount from qty and rate if they exist
        -- added by slkrishn
        IF l_claim_line_tbl(j).quantity IS NOT NULL AND
           l_claim_line_tbl(j).rate IS NOT NULL
        THEN
           l_claim_line_tbl(j).claim_currency_amount :=
                    l_claim_line_tbl(j).quantity * l_claim_line_tbl(j).rate;
        END IF;

        -- raise error if claim currency amount is null
        -- added by slkrishn
        IF l_claim_line_tbl(j).claim_currency_amount IS NULL THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_NULL');
             FND_MSG_PUB.add;
          END IF;
          x_error_index := j;
          RAISE FND_API.g_exc_error;
        ELSE
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Before CurrRound :: claim line currency_currency_amount = '||l_claim_line_tbl(j).claim_currency_amount);
            OZF_Utility_PVT.debug_message('Before CurrRound :: claim currency code = '||l_currency_code);
         END IF;
         l_claim_line_tbl(j).claim_currency_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_tbl(j).claim_currency_amount, l_currency_code);
        END IF;

        l_create_total_amt := l_create_total_amt + l_claim_line_tbl(j).claim_currency_amount;
        l_claim_id := p_claim_line_tbl(j).claim_id;
      END IF;
    END LOOP;

    OPEN c_claim_amount(l_claim_id);
    FETCH c_claim_amount INTO l_claim_amount, l_claim_class;
    CLOSE c_claim_amount;

    OPEN c_exist_total_line_amt(l_claim_id);
    FETCH c_exist_total_line_amt INTO l_exist_total_amt;
    CLOSE c_exist_total_line_amt;


     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('exist_total_amt:' || l_exist_total_amt );
        OZF_Utility_PVT.debug_message('create_total_amt:' || l_create_total_amt );
        OZF_Utility_PVT.debug_message('claim_amount:' || l_claim_amount );
     END IF;
    --Check for the sum of line amount sign. It should be same as that claims remaining amount.
    --Skip the check in case of Subsequent Receipt Application.
    IF l_claim_class <> 'GROUP' THEN
      IF sign(l_exist_total_amt + l_create_total_amt) <> sign(l_claim_amount)
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_SIGN_ERR');
           FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;
    END IF;


    IF ABS((l_exist_total_amt + l_create_total_amt)) > ABS(l_claim_amount) AND
       l_claim_class <> 'GROUP' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
        FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  --------------------- Create Claim Line Table -----------------------
  IF p_claim_line_tbl.count > 0 THEN
    FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
      IF p_claim_line_tbl.EXISTS(i) THEN

        l_claim_line_rec := l_claim_line_tbl(i);

        --If all values in line overview is null, line record will not be created.
        IF l_claim_line_rec.activity_type IS NOT NULL OR
           l_claim_line_rec.source_object_class IS NOT NULL OR
           l_claim_line_rec.source_object_id IS NOT NULL OR
           l_claim_line_rec.source_object_line_id IS NOT NULL OR
           l_claim_line_rec.quantity_uom IS NOT NULL OR
           l_claim_line_rec.claim_currency_amount IS NOT NULL OR
           l_claim_line_rec.quantity IS NOT NULL OR
           l_claim_line_rec.rate IS NOT NULL OR
           l_claim_line_rec.tax_code IS NOT NULL OR
           l_claim_line_rec.item_description IS NOT NULL THEN
           l_claim_line_rec.update_from_tbl_flag := FND_API.g_true;

          -- Call the create claim line API
          Create_Claim_Line(
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => p_validation_level
               , x_return_status     => l_return_status
               , x_msg_data          => x_msg_data
               , x_msg_count         => x_msg_count
               , p_claim_line_rec    => l_claim_line_rec
               , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
               , x_claim_line_id     => l_claim_line_id
          );
          IF l_return_status =  fnd_api.g_ret_sts_error THEN
            x_error_index := i;
            RAISE FND_API.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            x_error_index := i;
            RAISE FND_API.g_exc_unexpected_error;
          END IF;
        END IF;
      END IF;
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
    ROLLBACK TO Create_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_Line_Tbl;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_Line
--
-- HISTORY
--    07/11/2000  mchang  Create.
--    07/31/2000  mchang  Add amount checking: Claim amount >= Existing Lines Total + New Line amount.
--                        If lines does not exist, Claim amount >= New Line amount.
--    02/02/2001  mchang  Remove passing in parameters - p_claim_amount and p_claim_version.
--    03/20/2001  mchang  Remove claim amount checking; Add currency conversion
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver
--                        conver acctd_amount and amount.
--    08/06-2001  mchang  Updated: convert line amount from acctd_amount
--    23/01/2002  slkrishn modified amount checking conditions
--    07/22/2002  yizhang add p_mode for security check
---------------------------------------------------------------------
PROCEDURE Create_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2   := FND_API.g_false
  ,p_commit            IN  VARCHAR2   := FND_API.g_false
  ,p_validation_level  IN  NUMBER     := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_rec    IN  claim_line_rec_type
  ,p_mode              IN  VARCHAR2   := OZF_CLAIM_UTILITY_PVT.g_auto_mode
  ,x_claim_line_id     OUT NOCOPY NUMBER
)
IS
-- Cursor to get the sequence for claim_line_id
CURSOR c_claim_line_seq IS
 SELECT ozf_claim_lines_all_s.NEXTVAL
 FROM DUAL;

-- Cursor to validate the uniqueness of the claim_line_id
CURSOR c_claim_line_count(cv_claim_line_id IN NUMBER) IS
 SELECT  COUNT(claim_line_id)
 FROM  ozf_claim_lines
 WHERE claim_line_id = cv_claim_line_id;

-- Cursor to check the maximum of line_number in order to set line_number value
CURSOR c_line_number(cv_claim_id IN NUMBER) IS
 SELECT MAX(line_number)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id;

-- Cursor to get set_of_books_id, and tax_code from Claim
CURSOR csr_default_fm_claim(cv_claim_id IN NUMBER) IS
 SELECT set_of_books_id, tax_code, org_id
 FROM ozf_claims
 WHERE CLAIM_ID = cv_claim_id;

-- Cursor to get claim amount
CURSOR c_claim_amount(cv_claim_id IN NUMBER) IS
 SELECT amount_remaining
 , claim_class
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

-- Cursor to sum of claim line amount
CURSOR c_line_sum_amt(cv_claim_id IN NUMBER) IS
 SELECT SUM(claim_currency_amount)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id;

-- Cursor to get default exchange_rate data from claim
CURSOR c_claim_default_exc(cv_claim_id IN NUMBER) IS
 SELECT currency_code
      , exchange_rate_type
      , exchange_rate_date
      , exchange_rate
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

-- fix for bug 5042046
-- Cursor to get functional currency
CURSOR csr_function_currency IS
  SELECT gs.currency_code
  FROM   gl_sets_of_books gs
  ,      ozf_sys_parameters org
  WHERE  org.set_of_books_id = gs.set_of_books_id
  AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();


l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Create_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_created_by            NUMBER;
l_updated_by            NUMBER;
l_last_update_login     NUMBER;
l_org_id                NUMBER;
l_valid_flag            VARCHAR2(1);

l_return_status         VARCHAR2(1);

l_claim_line_rec        claim_line_rec_type := p_claim_line_rec;
l_x_claim_line_rec      claim_line_rec_type;
l_object_version_number NUMBER       := 1;
l_line_number           NUMBER       := 1;

l_claim_line_count      NUMBER;
l_claim_amount          NUMBER;
l_claim_class           VARCHAR2(30);
l_line_sum_amt          NUMBER;
l_claim_currency_amount NUMBER;

l_set_of_books_id       NUMBER;
l_tax_code              VARCHAR2(50);

l_claim_currency        VARCHAR2(15);
l_claim_exc_rate        NUMBER;
l_claim_exc_type        VARCHAR2(30);
l_claim_exc_date        DATE;
l_functional_currency   VARCHAR2(15);

l_access                VARCHAR2(1) := 'N';

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Create_Claim_Line;

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

  l_claim_line_rec := p_claim_line_rec;

  ----------------- check claim access -------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode THEN
    OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
           P_Api_Version_Number => 1.0
         , P_Init_Msg_List      => FND_API.G_FALSE
         , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         , P_Commit             => FND_API.G_FALSE
         , P_object_id          => l_claim_line_rec.claim_id
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

 /*-------------------------------------------------------*
  | set default value for claim line                      |
  *-------------------------------------------------------*/
  l_created_by := NVL(FND_GLOBAL.user_id,-1);
  l_updated_by := NVL(FND_GLOBAL.user_id,-1);
  l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);
  l_valid_flag := NVL(l_claim_line_rec.valid_flag, FND_API.g_false);

  -- get org_id, set_of_books_id and tax_code from claim
  OPEN csr_default_fm_claim(l_claim_line_rec.claim_id);
  FETCH csr_default_fm_claim INTO l_set_of_books_id
                                , l_tax_code
                                , l_org_id;
  CLOSE csr_default_fm_claim;

  -- generate the value of line_number
  IF l_claim_line_rec.line_number is NULL THEN
    -- get existing max line_number
    OPEN c_line_number(l_claim_line_rec.claim_id);
    FETCH c_line_number INTO l_line_number;
    CLOSE c_line_number;

    IF (l_line_number IS NOT NULL) THEN
      l_line_number := l_line_number + 1;
    ELSE
      l_line_number := 1;
    END IF;

    l_claim_line_rec.line_number := l_line_number;
  END IF;

  -- Default UOM for product.
  IF l_claim_line_rec.item_type = 'PRODUCT'
  AND (l_claim_line_rec.item_id is not null
       AND l_claim_line_rec.item_id <> FND_API.G_MISS_NUM )
  AND (l_claim_line_rec.quantity_uom is null
       OR l_claim_line_rec.quantity_uom = FND_API.G_MISS_CHAR)
  THEN
   --Bugfix 5182181
   l_claim_line_rec.quantity_uom := Get_Default_Product_UOM
                                    ( p_product_id => l_claim_line_rec.item_id
                                    , p_org_id     =>  FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID')
                                    );
  END IF;



  -- default set_of_books_id
  IF l_claim_line_rec.set_of_books_id IS NULL THEN
    l_claim_line_rec.set_of_books_id := l_set_of_books_id;
  END IF;


  -- default tax_code
  IF l_claim_line_rec.tax_code IS NULL THEN
    l_claim_line_rec.tax_code  := l_tax_code;
  END IF;

   -- default claim line by settlement method
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
       OZF_CLAIM_SETTLEMENT_VAL_PVT.Default_Claim_Line(
           p_api_version           => l_api_version
          ,p_init_msg_list         => FND_API.g_false
          ,p_validation_level      => FND_API.g_valid_level_full
          ,x_return_status         => l_return_status
          ,x_msg_data              => x_msg_data
          ,x_msg_count             => x_msg_count
          ,p_x_claim_line_rec      => l_claim_line_rec
     );
     IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  -- get functional currency
  OPEN csr_function_currency;
  FETCH csr_function_currency INTO l_functional_currency;
  CLOSE csr_function_currency;

  ------------------ checking quantity * rate  -------------------
  -- added by slkrishn since the condition below is moved to tbl api
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
    IF l_claim_line_rec.quantity IS NOT NULL AND
       l_claim_line_rec.rate IS NOT NULL THEN
      l_claim_line_rec.claim_currency_amount := l_claim_line_rec.quantity * l_claim_line_rec.rate;
    END IF;
  END IF;

  ------------------ convert currency --------------------
  IF l_claim_line_rec.claim_currency_amount IS NOT NULL THEN
    OPEN c_claim_default_exc(l_claim_line_rec.claim_id);
    FETCH c_claim_default_exc INTO l_claim_currency
                                 , l_claim_exc_type
                                 , l_claim_exc_date
                                 , l_claim_exc_rate;
    CLOSE c_claim_default_exc;

    -- Convert ACCTD_AMOUNT
    OZF_UTILITY_PVT.Convert_Currency(
           P_SET_OF_BOOKS_ID => l_claim_line_rec.set_of_books_id,
           P_FROM_CURRENCY   => l_claim_currency,
           P_CONVERSION_DATE => l_claim_exc_date,
           P_CONVERSION_TYPE => l_claim_exc_type,
           P_CONVERSION_RATE => l_claim_exc_rate,
           P_AMOUNT          => l_claim_line_rec.claim_currency_amount,
           X_RETURN_STATUS   => l_return_status,
           X_ACC_AMOUNT      => l_claim_line_rec.acctd_amount,
           X_RATE            => l_claim_line_rec.exchange_rate
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Convert Line AMOUNT
    -- bug fix for #2528435
    --IF p_claim_line_rec.source_object_class IS NULL AND
    -- Bugfix 7811671
    IF l_claim_line_rec.source_object_id IS NULL OR l_claim_line_rec.source_object_class = 'SD_SUPPLIER' THEN
      l_claim_line_rec.currency_code := l_claim_currency;
      l_claim_line_rec.exchange_rate := l_claim_exc_rate;
      l_claim_line_rec.exchange_rate_type := l_claim_exc_type;
      l_claim_line_rec.exchange_rate_date := l_claim_exc_date;
      l_claim_line_rec.amount := l_claim_line_rec.claim_currency_amount;
    ELSE
      Convert_Line_Amount(
            p_claim_line_rec    => l_claim_line_rec
           ,x_claim_line_rec    => l_x_claim_line_rec
           ,x_return_status     => l_return_status
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
      l_claim_line_rec := l_x_claim_line_rec;
    END IF;
  -- raise error if claim currency amount is null
  ELSE
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_NULL');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

 /*-------------------------------------------------------*
  |                validate                               |
  *-------------------------------------------------------*/
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': validate');
  END IF;

  Validate_Claim_Line(
      p_api_version         => l_api_version,
      p_init_msg_list       => p_init_msg_list,
      p_validation_level    => p_validation_level,
      x_return_status       => l_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_claim_line_rec      => l_claim_line_rec
  );
  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  ------------------- amount rounding --------------------
  IF l_claim_line_rec.claim_currency_amount IS NOT NULL THEN
    l_claim_line_rec.claim_currency_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.claim_currency_amount, l_claim_currency);
  END IF;

  IF l_claim_line_rec.amount IS NOT NULL THEN
    l_claim_line_rec.amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.amount, l_claim_line_rec.currency_code);
  END IF;

  IF l_claim_line_rec.acctd_amount IS NOT NULL THEN
    l_claim_line_rec.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.acctd_amount, l_functional_currency);
  END IF;

  ------------------- amount checking --------------------
  IF l_claim_line_rec.claim_currency_amount IS NOT NULL THEN
    -- Get the claim amount from database (amount_remaining)
    OPEN c_claim_amount(l_claim_line_rec.claim_id);
    FETCH c_claim_amount INTO l_claim_amount, l_claim_class;
    CLOSE c_claim_amount;

    -- Sign of claim_currency_amount should be the same as claim amount_remaining
    -- 20-APR-04 Commenting the sign check for the claim amounts, as for a claim negative line amount
    -- can be specified to associate negative accruals. Similarily valid for DED/OPM.
    --IF SIGN(l_claim_line_rec.claim_currency_amount) <> SIGN(l_claim_amount) THEN
    --  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    --    FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_SIGN_ERR');
    --    FND_MSG_PUB.add;
    --  END IF;
    --  RAISE FND_API.g_exc_error;
    --END IF;

    -- skip amount comparison if it's updating from tbl.
    -- update_from_tbl_flag condition commented by slkrishn
    -- amount condition not working at table
    -- mchnag: open the checking again to fix BUG#2242664
    IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false AND
       l_claim_class <> 'GROUP' THEN
      -- get total of existing line amount (sum of claim_currency_amount)
      OPEN c_line_sum_amt(l_claim_line_rec.claim_id);
      FETCH c_line_sum_amt INTO l_line_sum_amt;
      CLOSE c_line_sum_amt;

      -- comparison of claim amount and line amount (claim_currency_amount)
      IF l_line_sum_amt IS NOT NULL THEN
        IF ABS((l_line_sum_amt + l_claim_line_rec.claim_currency_amount)) > ABS(l_claim_amount) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;
      ELSIF ABS(l_claim_line_rec.claim_currency_amount) > ABS(l_claim_amount) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
    END IF;
  END IF;

  OZF_CLAIM_SETTLEMENT_VAL_PVT.Validate_Claim_Line(
        p_api_version           => l_api_version
       ,p_init_msg_list         => FND_API.g_false
       ,p_validation_level      => FND_API.g_valid_level_full
       ,x_return_status         => l_return_status
       ,x_msg_data              => x_msg_data
       ,x_msg_count             => x_msg_count
       ,p_claim_line_rec        => l_claim_line_rec
  );
  IF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF l_claim_line_rec.claim_line_id IS NULL THEN
    LOOP
      -- Get the identifier
      OPEN  c_claim_line_seq;
      FETCH c_claim_line_seq INTO l_claim_line_rec.claim_line_id;
      CLOSE c_claim_line_seq;
      -- Check the uniqueness of the identifier
      OPEN  c_claim_line_count(l_claim_line_rec.claim_line_id);
      FETCH c_claim_line_count INTO l_claim_line_count;
      CLOSE c_claim_line_count;
      -- Exit when the identifier uniqueness is established
      EXIT WHEN l_claim_line_count = 0;
   END LOOP;
  END IF;

  -- Bug4489415: Make the Tax Call
  IF  l_claim_line_rec.tax_action IS NOT NULL AND
     l_claim_line_rec.amount IS NOT NULL  THEN

      OZF_CLAIM_TAX_PVT.Calculate_Claim_Line_Tax(
          p_api_version           => l_api_version
         ,p_init_msg_list         => FND_API.g_false
         ,p_validation_level      => FND_API.g_valid_level_full
         ,x_return_status         => l_return_status
         ,x_msg_data              => x_msg_data
         ,x_msg_count             => x_msg_count
         ,p_x_claim_line_rec      => l_claim_line_rec
      );
      IF l_return_status =  FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF;

 /*-------------------------------------------------------*
  |                insert                                 |
  *-------------------------------------------------------*/
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': insert');
  END IF;


  INSERT INTO ozf_claim_lines_all (
       claim_line_id,
       object_version_number,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_update_date,
       program_id,
       created_from,
       claim_id,
       line_number,
       split_from_claim_line_id,
       amount,
       claim_currency_amount,
       acctd_amount,
       currency_code,
       exchange_rate_type,
       exchange_rate_date,
       exchange_rate,
       set_of_books_id,
       valid_flag,
       source_object_id,
       source_object_line_id,
       source_object_class,
       source_object_type_id,
       plan_id,
       offer_id,
       utilization_id,
       payment_method,
       payment_reference_id,
       payment_reference_number,
       payment_reference_date,
       voucher_id,
       voucher_number,
       payment_status,
       approved_flag,
       approved_date,
       approved_by,
       settled_date,
       settled_by,
       performance_complete_flag,
       performance_attached_flag,
       select_cust_children_flag,
       item_id,
       item_description,
       quantity,
       quantity_uom,
       rate,
       activity_type,
       activity_id,
       related_cust_account_id,
       buy_group_cust_account_id,
       relationship_type,
       earnings_associated_flag,
       comments,
       tax_code,
       credit_to,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       org_id,
       sale_date,
       item_type,
       tax_amount,
       claim_curr_tax_amount,
       acctd_tax_amount,
       activity_line_id,
       offer_type,
       prorate_earnings_flag,
       earnings_end_date,
       buy_group_party_id,
       dpp_cust_account_id, --12.1 Enhancement : Price Protection
       batch_line_id        --Bugfix : 7811671
  )
  VALUES (
      l_claim_line_rec.claim_line_id,
      l_object_version_number,                -- OBJECT_VERSION_NUMBER
      SYSDATE,                                -- LAST_UPDATE_DATE
      l_updated_by,                           -- LAST_UPDATED_BY
      SYSDATE,                                -- CREATION_DATE
      l_created_by,                           -- CREATED_BY
      l_last_update_login,                    -- LAST_UPDATE_LOGIN
      FND_GLOBAL.CONC_REQUEST_ID,             -- REQUEST_ID
      FND_GLOBAL.PROG_APPL_ID,                -- PROGRAM_APPLICATION_ID
      SYSDATE,                                -- PROGRAM_UPDATE_DATE
      FND_GLOBAL.CONC_PROGRAM_ID,             -- PROGRAM_ID
      l_claim_line_rec.created_from,          -- CREATED_FROM
      l_claim_line_rec.claim_id,
      l_claim_line_rec.line_number,
      l_claim_line_rec.split_from_claim_line_id,
      l_claim_line_rec.amount,
      l_claim_line_rec.claim_currency_amount,
      l_claim_line_rec.acctd_amount,
      l_claim_line_rec.currency_code,
      l_claim_line_rec.exchange_rate_type,
      l_claim_line_rec.exchange_rate_date,
      l_claim_line_rec.exchange_rate,
      l_claim_line_rec.set_of_books_id,
      l_valid_flag,
      l_claim_line_rec.source_object_id,
      l_claim_line_rec.source_object_line_id,
      l_claim_line_rec.source_object_class,
      l_claim_line_rec.source_object_type_id,
      l_claim_line_rec.plan_id,
      l_claim_line_rec.offer_id,
      l_claim_line_rec.utilization_id,
      l_claim_line_rec.payment_method,
      l_claim_line_rec.payment_reference_id,
      l_claim_line_rec.payment_reference_number,
      l_claim_line_rec.payment_reference_date,
      l_claim_line_rec.voucher_id,
      l_claim_line_rec.voucher_number,
      l_claim_line_rec.payment_status,
      l_claim_line_rec.approved_flag,
      l_claim_line_rec.approved_date,
      l_claim_line_rec.approved_by,
      l_claim_line_rec.settled_date,
      l_claim_line_rec.settled_by,
      l_claim_line_rec.performance_complete_flag,
      l_claim_line_rec.performance_attached_flag,
      l_claim_line_rec.select_cust_children_flag,
      l_claim_line_rec.item_id,
      l_claim_line_rec.item_description,
      l_claim_line_rec.quantity,
      l_claim_line_rec.quantity_uom,
      l_claim_line_rec.rate,
      l_claim_line_rec.activity_type,
      l_claim_line_rec.activity_id,
      l_claim_line_rec.related_cust_account_id,
      l_claim_line_rec.buy_group_cust_account_id,
      l_claim_line_rec.relationship_type,
      l_claim_line_rec.earnings_associated_flag,
      l_claim_line_rec.comments,
      l_claim_line_rec.tax_code,
      l_claim_line_rec.credit_to,
      l_claim_line_rec.attribute_category,
      l_claim_line_rec.attribute1,
      l_claim_line_rec.attribute2,
      l_claim_line_rec.attribute3,
      l_claim_line_rec.attribute4,
      l_claim_line_rec.attribute5,
      l_claim_line_rec.attribute6,
      l_claim_line_rec.attribute7,
      l_claim_line_rec.attribute8,
      l_claim_line_rec.attribute9,
      l_claim_line_rec.attribute10,
      l_claim_line_rec.attribute11,
      l_claim_line_rec.attribute12,
      l_claim_line_rec.attribute13,
      l_claim_line_rec.attribute14,
      l_claim_line_rec.attribute15,
      l_org_id,                                      -- ORG_ID
      l_claim_line_rec.sale_date,
      l_claim_line_rec.item_type,
      l_claim_line_rec.tax_amount,
      l_claim_line_rec.claim_curr_tax_amount,
      l_claim_line_rec.acctd_tax_amount, --Bug4489415
      l_claim_line_rec.activity_line_id,
      l_claim_line_rec.offer_type,
      l_claim_line_rec.prorate_earnings_flag,
      l_claim_line_rec.earnings_end_date,
      l_claim_line_rec.buy_group_party_id,
      l_claim_line_rec.dpp_cust_account_id, --12.1 Enhancement : Price Protection
      l_claim_line_rec.batch_line_id        --Bugfix : 7811671
  );

  ------------------------- finish -------------------------------
  x_claim_line_id := l_claim_line_rec.claim_line_id;

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
    ROLLBACK TO Create_Claim_Line;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Create_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Create_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
    );

END Create_Claim_Line;


---------------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Line_Tbl
--
-- HISTORY
--    02/02/2001  mchang  Create.
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver_tbl
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver_tbl
--    07/22/2002  yizhang add p_mode for security check
---------------------------------------------------------------------
PROCEDURE Delete_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Delete_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_claim_line_id         NUMBER;
l_object_version        NUMBER;

l_access                VARCHAR2(1) := 'N';

CURSOR csr_line_obj_ver(cv_claim_line_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;


--(Addded by Uday) For Amount check
l_claim_amount       NUMBER;
l_exist_total_line_amount NUMBER;
l_effective_line_amount   NUMBER;
l_del_total_line_amount NUMBER := 0;
l_claim_class        VARCHAR2(30);


CURSOR csr_claim_amount(cv_claim_id IN NUMBER) IS
   SELECT amount_remaining, claim_class
   FROM ozf_claims
   WHERE claim_id = cv_claim_id;

CURSOR csr_exist_total_line_amt(cv_claim_id IN NUMBER) IS
   SELECT nvl(sum(claim_currency_amount), 0)
   FROM ozf_claim_lines
   WHERE claim_id = cv_claim_id;

--End of Amount check declarations

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Claim_Line_Tbl;

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
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_claim_line_tbl.count > 0 THEN
    FOR j IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
      IF p_claim_line_tbl.EXISTS(j) THEN
        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => p_claim_line_tbl(j).claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => l_msg_count
             , X_Msg_Data           => l_msg_data
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

  --------------------- Amount Checking -----------------------
  IF p_claim_line_tbl.count > 0 THEN
      --Get the claim amount.
      OPEN csr_claim_amount(p_claim_line_tbl(1).claim_id);
      FETCH csr_claim_amount INTO l_claim_amount, l_claim_class;
      CLOSE csr_claim_amount;

      --Get the existing line amount
      OPEN csr_exist_total_line_amt(p_claim_line_tbl(1).claim_id);
      FETCH csr_exist_total_line_amt INTO l_exist_total_line_amount;
      CLOSE csr_exist_total_line_amt;

      --Get the sum of line amounts to be deleted.
      FOR j IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
         IF p_claim_line_tbl.EXISTS(j) THEN
            l_del_total_line_amount :=  l_del_total_line_amount + nvl(p_claim_line_tbl(j).claim_currency_amount, 0);
         END IF;
      END LOOP;

      l_effective_line_amount := l_exist_total_line_amount - l_del_total_line_amount;

     IF l_claim_class <> 'GROUP' THEN
         IF (sign(l_effective_line_amount) <> sign(l_claim_amount))
         AND l_effective_line_amount <> 0
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_SIGN_ERR');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;

         IF ABS(l_effective_line_amount) > ABS(l_claim_amount)
         THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
       END IF;
  END IF;
  --------------------- End of Amount Checking -----------------------

  --------------------- Delete Claim Line Table -----------------------
  IF p_claim_line_tbl.count > 0 THEN
    FOR i IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
      IF p_claim_line_tbl.EXISTS(i) THEN
        l_claim_line_id := p_claim_line_tbl(i).claim_line_id;
        IF p_change_object_version = FND_API.g_true THEN
          --l_object_version := p_claim_line_tbl(i).object_version_number + 1;
          OPEN csr_line_obj_ver(p_claim_line_tbl(i).claim_line_id);
          FETCH csr_line_obj_ver INTO l_object_version;
          CLOSE csr_line_obj_ver;
	    IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('l_object_version11:' || l_object_version);
            END IF;
        ELSE
          l_object_version := p_claim_line_tbl(i).object_version_number;
	   IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('l_object_version22:' || l_object_version);
            END IF;
        END IF;

	 IF OZF_DEBUG_HIGH_ON THEN
              OZF_Utility_PVT.debug_message('l_object_version33:' || l_object_version);
            END IF;
        -- Call the delete claim line API
        Delete_Claim_Line(
                  p_api_version       => 1.0
                , p_init_msg_list     => FND_API.g_false
                , p_commit            => FND_API.g_false
                , x_return_status     => l_return_status
                , x_msg_data          => x_msg_data
                , x_msg_count         => x_msg_count
                , p_claim_line_id     => l_claim_line_id
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
    ROLLBACK TO Delete_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

END Delete_Claim_Line_Tbl;


---------------------------------------------------------------
-- PROCEDURE
--    Delete_Claim_Line
--
-- HISTORY
--    07/11/2000  mchang  Create.
--    07/31/2000  mchang  Add amount checking: Claim Amount >= (Existing Lines Total - to be Deleted Line Amount).
--                        If Claim amount is different from DB, update Claim amount to new amount.
--    02/02/2001  mchang  Remove passing in parameters - p_claim_amount and p_claim_version.
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver
--    08/06/2001  mchang  remove associate earnings by calling OZF_Claim_Accrual_PVT.Delete_Line_Util_Tbl
--    07/22/2002  yizhang add p_mode for security check
---------------------------------------------------------------
PROCEDURE Delete_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_id     IN  NUMBER
  ,p_object_version    IN  NUMBER
  ,p_mode              IN  VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Delete_Claim_Line';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_return_status        VARCHAR2(1);
l_access               VARCHAR2(1)  := 'N';

-- Cursor to get claim_id
CURSOR csr_claim_id(cv_claim_line_id IN NUMBER) IS
  SELECT claim_id
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

-- Cursor to get claim amount
CURSOR c_claim_amount(cv_claim_id IN NUMBER) IS
  SELECT amount_remaining
  FROM ozf_claims
  WHERE claim_id = cv_claim_id;

-- Cursor to sum of claim line amount
CURSOR c_line_sum_amt(cv_claim_id IN NUMBER, cv_line_id IN NUMBER) IS
  SELECT SUM(claim_currency_amount)
  FROM ozf_claim_lines
  WHERE claim_id = cv_claim_id
  AND claim_line_id <> cv_line_id;

-- Cursor to get earnings associated with this line
CURSOR csr_get_lines_util(cv_claim_line_id IN NUMBER) IS
  SELECT claim_line_util_id
  ,      object_version_number
  ,      currency_code
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

l_claim_id              NUMBER;
l_claim_amount          NUMBER;
l_line_sum_amt          NUMBER;
l_line_util_tbl         OZF_Claim_Accrual_PVT.line_util_tbl_type;
l_counter               NUMBER := 1;
l_error_index           NUMBER;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Delete_Claim_Line;

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

  OPEN csr_claim_id(p_claim_line_id);
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

  --------------------- claim amount checking -----------------------
  -- get claim amount from database (amount_remaining)
  --OPEN c_claim_amount(l_claim_id);
  --FETCH c_claim_amount INTO l_claim_amount;
  --CLOSE c_claim_amount;

  -- get total of existing line amount (sum of claim_currency_amount)
  --OPEN c_line_sum_amt(l_claim_id, p_claim_line_id);
  --FETCH c_line_sum_amt INTO l_line_sum_amt;
  --CLOSE c_line_sum_amt;

  -- comparison of claim amount and line amount (claim_currency_amount)
  --IF l_line_sum_amt IS NOT NULL THEN
   --IF ABS(l_line_sum_amt) > ABS(l_claim_amount) THEN
     --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      -- FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
       --FND_MSG_PUB.add;
     --END IF;
     --RAISE FND_API.g_exc_error;
   --END IF;
  --END IF;

  ------------------ Remove Associate Earnings ----------------
  OPEN csr_get_lines_util(p_claim_line_id);
  LOOP
    FETCH csr_get_lines_util INTO l_line_util_tbl(l_counter).claim_line_util_id
                                , l_line_util_tbl(l_counter).object_version_number
                                , l_line_util_tbl(l_counter).currency_code;
    EXIT WHEN csr_get_lines_util%NOTFOUND;
    l_line_util_tbl(l_counter).claim_line_id := p_claim_line_id;
    l_counter := l_counter + 1;
  END LOOP;
  CLOSE csr_get_lines_util;

  IF l_counter > 1 THEN
    OZF_Claim_Accrual_PVT.Delete_Line_Util_Tbl(
        p_api_version            => l_api_version
       ,p_init_msg_list          => FND_API.g_false
       ,p_commit                 => FND_API.g_false
       ,p_validation_level       => FND_API.g_valid_level_full
       ,x_return_status          => l_return_status
       ,x_msg_data               => x_msg_data
       ,x_msg_count              => x_msg_count
       ,p_line_util_tbl          => l_line_util_tbl
       ,p_mode                   => OZF_CLAIM_UTILITY_PVT.g_auto_mode
       ,x_error_index            => l_error_index
    );
    IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  ------------------------ Delete ------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': delete');
     OZF_Utility_PVT.debug_message(p_claim_line_id ||': delete : p_claim_line_id');
     OZF_Utility_PVT.debug_message(p_object_version ||': delete : p_object_version');
  END IF;

  DELETE FROM ozf_claim_lines_all
    WHERE claim_line_id = p_claim_line_id
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
    ROLLBACK TO Delete_Claim_Line;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Delete_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Delete_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END Delete_Claim_Line;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Claim_Line
--
-- HISTORY
--    07/11/2000  mchang  Create.
--------------------------------------------------------------------
PROCEDURE Lock_Claim_Line(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_claim_line_id     IN  NUMBER
  ,p_object_version    IN  NUMBER
)
IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Lock_Claim_Line';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_claim_line_id      NUMBER;

CURSOR c_claim_line IS
 SELECT  claim_line_id
 FROM  ozf_claim_lines_all
 WHERE claim_line_id = p_claim_line_id
 AND   object_version_number = p_object_version
 FOR UPDATE OF claim_line_id NOWAIT;

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
       p_api_version,
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

  OPEN  c_claim_line;
  FETCH c_claim_line INTO l_claim_line_id;
  IF (c_claim_line%NOTFOUND) THEN
    CLOSE c_claim_line;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_claim_line;

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

END Lock_Claim_Line;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Lock_Items
--
-- HISTORY
--    04/27/2002  yizhang  Create.
--    05/30/2005  kdhulipa fix for 4400825
--    01/16/2006  kdhulipa  fix for 4954996
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Lock_Items(
   p_claim_line_rec  IN  claim_line_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
l_source_object_id      NUMBER        := NULL;
l_source_object_class   VARCHAR2(15);
l_source_object_type_id NUMBER        := NULL;
l_plan_id               NUMBER        := NULL;
l_item_id               NUMBER        := NULL;
l_item_description      VARCHAR2(240);
l_activity_type         VARCHAR2(30);
l_activity_id           NUMBER        := NULL;
l_earnings_associated_flag VARCHAR2(1);

CURSOR csr_line_lock_items(cv_claim_line_id IN NUMBER) IS
  SELECT NVL(source_object_id, FND_API.g_miss_num)
  ,      NVL(source_object_class, FND_API.g_miss_char)
  ,      NVL(source_object_type_id, FND_API.g_miss_num)
  ,      NVL(plan_id, FND_API.g_miss_num)
  ,      NVL(item_id, FND_API.g_miss_num)
  ,      NVL(item_description, FND_API.g_miss_char)
  ,      NVL(activity_type, FND_API.g_miss_char)
  ,      NVL(activity_id, FND_API.g_miss_num)
  ,      earnings_associated_flag
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- get old claim line values
  OPEN csr_line_lock_items(p_claim_line_rec.claim_line_id);
  FETCH csr_line_lock_items INTO l_source_object_id
                               , l_source_object_class
                               , l_source_object_type_id
                               , l_plan_id
                               , l_item_id
                               , l_item_description
                               , l_activity_type
                               , l_activity_id
                               , l_earnings_associated_flag;
  CLOSE csr_line_lock_items;

  -------------- Lock items when earnings is associated --------------
  IF l_earnings_associated_flag = FND_API.g_true THEN
    IF NVL(p_claim_line_rec.source_object_id,FND_API.g_miss_num) <> l_source_object_id THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Name OR Line / Product');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    IF NVL(p_claim_line_rec.source_object_class,FND_API.g_miss_char) <> l_source_object_class THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Type');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    IF NVL(p_claim_line_rec.source_object_type_id,FND_API.g_miss_num) <> l_source_object_type_id THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Type');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    IF NVL(p_claim_line_rec.plan_id,FND_API.g_miss_num) <> l_plan_id THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Type');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    IF NVL(p_claim_line_rec.item_id,FND_API.g_miss_num) <> l_item_id THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Line / Product');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    /*
    IF NVL(p_claim_line_rec.item_description,FND_API.g_miss_char) <> l_item_description THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'ITEM_DESCRIPTION');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    */
    IF NVL(p_claim_line_rec.activity_type,FND_API.g_miss_char) <> l_activity_type THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Name');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
    IF NVL(p_claim_line_rec.activity_id,FND_API.g_miss_num) <> l_activity_id THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_LOCK');
        FND_MESSAGE.set_token('LOCK', 'Name');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

END Check_Claim_Line_Lock_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Line_Tbl
--
-- HISTORY
--    02/02/2001  mchang  Create.
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver_tbl
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver_tbl
--    23/01/2002  slkrishn modified amount checking conditions
---------------------------------------------------------------------
PROCEDURE Update_Claim_Line_Tbl(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.g_false
   ,p_commit                 IN    VARCHAR2 := FND_API.g_false
   ,p_validation_level       IN    NUMBER   := FND_API.g_valid_level_full

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_line_tbl         IN    claim_line_tbl_type
   ,p_change_object_version  IN    VARCHAR2 := FND_API.g_false
   ,p_mode                   IN    VARCHAR2 := OZF_CLAIM_UTILITY_PVT.g_auto_mode

   ,x_error_index            OUT NOCOPY   NUMBER
) IS
l_api_version  CONSTANT NUMBER       := 1.0;
l_api_name     CONSTANT VARCHAR2(30) := 'Update_Claim_Line_Tbl';
l_full_name    CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_claim_line_rec        claim_line_rec_type;
l_claim_line_tbl        claim_line_tbl_type;
l_object_version        NUMBER;

l_old_upd_total_amt     NUMBER := 0;
l_new_upd_total_amt     NUMBER := 0;
l_exist_total_amt       NUMBER;
l_old_line_amt          NUMBER;
l_claim_amount          NUMBER;
l_claim_class           VARCHAR2(30);
l_claim_id              NUMBER;
l_currency_code         VARCHAR2(15);
l_access                VARCHAR2(1) := 'N';
l_offer_id              NUMBER;


CURSOR csr_line_obj_ver(cv_claim_line_id IN NUMBER) IS
  SELECT object_version_number
  FROM ozf_claim_lines
  WHERE claim_line_id = cv_claim_line_id;

--ER#9453443
CURSOR c_claim(cv_claim_id IN NUMBER) IS
 SELECT amount_remaining
 ,      set_of_books_id
 ,      currency_code
 ,      exchange_rate_type
 ,      exchange_rate_date
 ,      exchange_rate
 ,      claim_class
 ,      offer_id
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

CURSOR c_old_line_amt(cv_claim_line_id IN NUMBER) IS
 SELECT claim_currency_amount, currency_code
 FROM ozf_claim_lines
 WHERE claim_line_id = cv_claim_line_id;

CURSOR c_exist_total_line_amt(cv_claim_id IN NUMBER) IS
 SELECT NVL(SUM(claim_currency_amount), 0)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id;

BEGIN
  --------------------- initialize -----------------------
  SAVEPOINT Update_Claim_Line_Tbl;

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

  l_claim_line_tbl := p_claim_line_tbl;

  ---------------------- check claim access ------------------------
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode AND p_claim_line_tbl.count > 0 THEN
    FOR j IN p_claim_line_tbl.FIRST..p_claim_line_tbl.LAST LOOP
      IF p_claim_line_tbl.EXISTS(j) THEN
        OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
               P_Api_Version_Number => 1.0
             , P_Init_Msg_List      => FND_API.G_FALSE
             , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
             , P_Commit             => FND_API.G_FALSE
             , P_object_id          => p_claim_line_tbl(j).claim_id
             , P_object_type        => G_CLAIM_OBJECT_TYPE
             , P_user_id            => OZF_UTILITY_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
             , X_Return_Status      => l_return_status
             , X_Msg_Count          => l_msg_count
             , X_Msg_Data           => l_msg_data
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

  ------------ Default Claim Line by Settlement Method ----------------
  OZF_CLAIM_SETTLEMENT_VAL_PVT.Default_Claim_Line_Tbl(
    p_api_version           => l_api_version
   ,p_init_msg_list         => FND_API.g_false
   ,p_validation_level      => p_validation_level
   ,x_return_status         => l_return_status
   ,x_msg_data              => x_msg_data
   ,x_msg_count             => x_msg_count
   ,p_x_claim_line_tbl      => l_claim_line_tbl
  );
   IF l_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

  --------------------- Amount Checking -----------------------

  IF l_claim_line_tbl.count > 0 THEN

    --ER#9453443
    OPEN c_claim(l_claim_line_tbl(1).claim_id);
    FETCH c_claim INTO l_claim_amount
                     , G_CLAIM_SET_OF_BOOKS_ID
                     , G_CLAIM_CURRENCY
                     , G_CLAIM_EXC_TYPE
                     , G_CLAIM_EXC_DATE
                     , G_CLAIM_EXC_RATE
                     , l_claim_class
		     , l_offer_id;
    CLOSE c_claim;


    OPEN c_exist_total_line_amt(l_claim_line_tbl(1).claim_id);
    FETCH c_exist_total_line_amt INTO l_exist_total_amt;
    CLOSE c_exist_total_line_amt;

    FOR j IN l_claim_line_tbl.FIRST..l_claim_line_tbl.LAST LOOP
      IF l_claim_line_tbl.EXISTS(j) THEN
        OPEN c_old_line_amt(l_claim_line_tbl(j).claim_line_id);
        FETCH c_old_line_amt INTO l_old_line_amt, l_currency_code;
        CLOSE c_old_line_amt;

        -- added by slkrishn
        IF (l_claim_line_tbl(j).quantity IS NOT NULL AND
            l_claim_line_tbl(j).quantity <> FND_API.g_miss_num)
        AND (l_claim_line_tbl(j).rate IS NOT NULL AND
            l_claim_line_tbl(j).rate <> FND_API.g_miss_num)
        THEN
          l_claim_line_tbl(j).claim_currency_amount :=
                 l_claim_line_tbl(j).quantity * l_claim_line_tbl(j).rate;
        END IF;

        -------- raise error if claim currency amount is null ----------
        IF l_claim_line_tbl(j).claim_currency_amount IS NULL THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_NULL');
            FND_MSG_PUB.add;
         END IF;
         x_error_index := j;
         RAISE FND_API.g_exc_error;
        ELSE
         IF OZF_DEBUG_HIGH_ON THEN
            OZF_Utility_PVT.debug_message('Before CurrRound :: claim line currency_currency_amount = '||l_claim_line_tbl(j).claim_currency_amount);
            OZF_Utility_PVT.debug_message('Before CurrRound :: claim currency code = '||l_currency_code);
         END IF;
         l_claim_line_tbl(j).claim_currency_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_tbl(j).claim_currency_amount, l_currency_code);
        END IF;

        --l_new_upd_total_amt := l_new_upd_total_amt + OZF_UTILITY_PVT.CurrRound(l_claim_line_tbl(j).claim_currency_amount, l_currency_code);
        l_new_upd_total_amt := l_new_upd_total_amt + l_claim_line_tbl(j).claim_currency_amount;

        l_old_upd_total_amt := l_old_upd_total_amt + l_old_line_amt;
        --l_claim_id := p_claim_line_tbl(j).claim_id;
      END IF;
    END LOOP;


     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('Sign check :: exist_total_amt:' || l_exist_total_amt );
        OZF_Utility_PVT.debug_message('Sign check :: old_upd_total_amt:' || l_old_upd_total_amt );
        OZF_Utility_PVT.debug_message('Sign check :: new_upd_total_amt:' || l_new_upd_total_amt );
        OZF_Utility_PVT.debug_message('Sign check :: claim_amount:' || l_claim_amount );
	OZF_Utility_PVT.debug_message('l_offer_id:' || l_offer_id );
     END IF;
     --Check for the sum of line amount sign. It should be same as that claims remaining amount.
    --Skip the check in case of Subsequent Receipt Application.
    --ER#9453443 : Added the Offer ID check
    IF (l_claim_class <> 'GROUP' AND l_offer_id IS NULL) THEN
      IF sign(l_exist_total_amt - l_old_upd_total_amt + l_new_upd_total_amt) <> sign(l_claim_amount)
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_SIGN_ERR');
           FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

    END IF;

       -- Skip this check if the Claim line is updated from Request.
    --ER#9453443 : Added the Offer ID check
    IF ((p_mode <> OZF_CLAIM_UTILITY_PVT.g_request_mode OR
       l_claim_class <> 'GROUP') AND l_offer_id IS NULL) THEN
       IF ABS(l_exist_total_amt - l_old_upd_total_amt + l_new_upd_total_amt) > ABS(l_claim_amount) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
           FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
       END IF;
    END IF;

  END IF;


  --------------------- Update Claim Line Table -----------------------
  IF l_claim_line_tbl.count > 0 THEN
    FOR i IN l_claim_line_tbl.FIRST..l_claim_line_tbl.LAST LOOP
      IF l_claim_line_tbl.EXISTS(i) THEN
        l_claim_line_rec := l_claim_line_tbl(i);
        IF p_change_object_version = FND_API.g_true THEN
          --l_claim_line_rec.object_version_number := l_claim_line_rec.object_version_number + 1;
          OPEN csr_line_obj_ver(l_claim_line_tbl(i).claim_line_id);
          FETCH csr_line_obj_ver INTO l_claim_line_rec.object_version_number;
          CLOSE csr_line_obj_ver;
        END IF;
        l_claim_line_rec.update_from_tbl_flag := FND_API.g_true;

        -- Call the update claim line API
        Update_Claim_Line(
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => p_validation_level
               , x_return_status     => l_return_status
               , x_msg_data          => x_msg_data
               , x_msg_count         => x_msg_count
               , p_claim_line_rec    => l_claim_line_rec
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
    ROLLBACK TO Update_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get (
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Claim_Line_Tbl;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
    );

END Update_Claim_Line_Tbl;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Claim_Line
--
-- HISTORY
--    07/11/2000  mchang  Create.
--    07/31/2000  mchang  Add amount checking: Claim amount >= (Existing Lines total-claim line updated)+updated line amount.
--                        If Claim amount is different from DB, update Claim amount to new amount.
--    02/02/2001  mchang  Remove passing in parameters - p_claim_amount and p_claim_version.
--    03/20/2001  mchang  Add claim_currency_amount conversion
--    03/28/2001  mchang  add passing_in parameter: p_utiz_obj_ver
--    04/30/2001  mchang  remove passing_in parameter: p_utiz_obj_ver
--    08/06/2001  mchang  convert acctd_amount from claim_currency_amount
--                        remove associate earnings by calling OZF_Claim_Accrual_PVT.Delete_Line_Util_Tbl
--    23/01/2002  slkrishn modified amount checking conditions
--    07/22/2002  yizhang add p_mode for security check
----------------------------------------------------------------------
PROCEDURE Update_Claim_Line(
   p_api_version         IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2  := FND_API.g_false
  ,p_commit              IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level    IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2

  ,p_claim_line_rec      IN  claim_line_rec_type
  ,p_mode                IN  VARCHAR2  := OZF_CLAIM_UTILITY_PVT.g_auto_mode

  ,x_object_version      OUT NOCOPY NUMBER
)
IS
-- Cursor to get claim amount
-- ER#9453443
CURSOR c_claim_amount(cv_claim_id IN NUMBER) IS
 SELECT amount_remaining
 , claim_class, offer_id
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

 -- cursor to get payment_method
CURSOR c_claim_payment_method(cv_claim_id IN NUMBER) IS
 SELECT payment_method
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

-- Cursor to sum of line util associations
-- Chage the cursor for bug 7658894
CURSOR csr_claim_line_util_amt(cv_claim_line_id IN NUMBER) IS
 SELECT nvl(SUM(acctd_amount),0), nvl(SUM(amount),0)
 FROM ozf_claim_lines_util
 WHERE claim_line_id = cv_claim_line_id;

-- Cursor to sum of claim line amount
CURSOR c_line_sum_amt(cv_claim_id IN NUMBER, cv_line_id IN NUMBER) IS
 SELECT SUM(claim_currency_amount)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id
 AND claim_line_id <> cv_line_id;

-- Cursor to get default exchange_rate data from claim
CURSOR c_claim_default_exc(cv_claim_id IN NUMBER) IS
 SELECT set_of_books_id
      , currency_code
      , exchange_rate_type
      , exchange_rate_date
      , exchange_rate
 FROM ozf_claims
 WHERE claim_id = cv_claim_id;

-- fix for bug 5042046
CURSOR csr_function_currency IS
 SELECT gs.currency_code
 FROM   gl_sets_of_books gs
 ,      ozf_sys_parameters org
 WHERE  org.set_of_books_id = gs.set_of_books_id
 AND    org.org_id = MO_GLOBAL.GET_CURRENT_ORG_ID();

-- Cursor to get earnings associated with this line
CURSOR csr_get_lines_util(cv_claim_line_id IN NUMBER) IS
  SELECT claim_line_util_id
  ,      object_version_number
  ,      currency_code
  FROM ozf_claim_lines_util
  WHERE claim_line_id = cv_claim_line_id;

-- Fix for bug 7658894
l_line_util_sum NUMBER :=0;

l_api_version  CONSTANT  NUMBER := 1.0;
l_api_name     CONSTANT  VARCHAR2(30) := 'Update_Claim_Line';
l_full_name    CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_last_updated_by        NUMBER;
l_last_update_login      NUMBER;

l_claim_line_rec         claim_line_rec_type;
l_x_claim_line_rec       claim_line_rec_type;
l_return_status          VARCHAR2(1);
l_mode                   VARCHAR2(30);
l_object_version_number  NUMBER;
l_old_utilization_id     NUMBER;
l_old_line_amount        NUMBER;
l_line_util_acc_amt      NUMBER;

l_claim_amount           NUMBER;
l_claim_class            VARCHAR2(30);
l_line_sum_amt           NUMBER;
l_claim_currency_amount  NUMBER;
l_payment_method         VARCHAR2(30);

l_rate                   NUMBER;

l_tri_denominator        NUMBER;
l_tri_numerator          NUMBER;
l_tri_rate               NUMBER;
l_function_currency      VARCHAR2(15);

l_line_util_tbl         OZF_Claim_Accrual_PVT.line_util_tbl_type;
l_counter               NUMBER :=1;
l_error_index           NUMBER;

l_access                VARCHAR2(1) := 'N';
-- Added for Rule Based Settlement
l_offer_id NUMBER :=0;

BEGIN
  -------------------- initialize -------------------------
  SAVEPOINT Update_Claim_Line;

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
  IF p_mode = OZF_CLAIM_UTILITY_PVT.g_manu_mode THEN
    OZF_CLAIM_UTILITY_PVT.Check_Claim_access(
           P_Api_Version_Number => 1.0
         , P_Init_Msg_List      => FND_API.G_FALSE
         , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
         , P_Commit             => FND_API.G_FALSE
         , P_object_id          => p_claim_line_rec.claim_id
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

  l_object_version_number := p_claim_line_rec.object_version_number + 1;
  l_last_updated_by := NVL(FND_GLOBAL.user_id,-1);
  l_last_update_login := NVL(FND_GLOBAL.conc_login_id,-1);


  -- Default UOM for product.
  IF l_claim_line_rec.item_type = 'PRODUCT'
  AND (l_claim_line_rec.item_id is not null
       AND l_claim_line_rec.item_id <> FND_API.G_MISS_NUM )
  AND (l_claim_line_rec.quantity_uom is null
       OR l_claim_line_rec.quantity_uom = FND_API.G_MISS_CHAR)
  THEN
  -- Bugfix 5182181
   l_claim_line_rec.quantity_uom := Get_Default_Product_UOM
                                    ( p_product_id => l_claim_line_rec.item_id
                                    , p_org_id     =>  FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID')
                                    );

  END IF;


  -- item level validation
  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    Check_Claim_Line_Items(
         p_claim_line_rec       => l_claim_line_rec,
         p_validation_mode      => JTF_PLSQL_API.g_update,
         x_return_status        => l_return_status
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  -- replace g_miss_char/num/date with current column values
  Complete_Claim_Line_Rec(
         p_claim_line_rec     =>  p_claim_line_rec
        ,x_complete_rec       =>  l_claim_line_rec
  );

  -- default claim line based on claim settlement method
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
     OZF_CLAIM_SETTLEMENT_VAL_PVT.Default_Claim_Line(
           p_api_version           => l_api_version
          ,p_init_msg_list         => FND_API.g_false
          ,p_validation_level      => FND_API.g_valid_level_full
          ,x_return_status         => l_return_status
          ,x_msg_data              => x_msg_data
          ,x_msg_count             => x_msg_count
          ,p_x_claim_line_rec      => l_claim_line_rec
     );
     IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  -- lock line items when earning is associated
  Check_Claim_Line_Lock_Items(
         p_claim_line_rec     => l_claim_line_rec
        ,x_return_status      => l_return_status
  );

  IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
    RAISE FND_API.g_exc_unexpected_error;
  ELSIF l_return_status = FND_API.g_ret_sts_error THEN
    RAISE FND_API.g_exc_error;
  END IF;

  -- record level validation
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
       Check_Claim_Line_Record(
         p_claim_line_rec     => p_claim_line_rec,
         p_complete_rec       => l_claim_line_rec,
         x_return_status      => l_return_status
       );
      IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF l_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      END IF;
    END IF;
 END IF;

  -- skip qty*rate calc if it's updating from tbl.
  -- updated by slkrishn
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
     ------------------ checking quantity * rate -------------------
     IF (p_claim_line_rec.quantity IS NOT NULL AND
         p_claim_line_rec.quantity <> FND_API.g_miss_num) AND
        (p_claim_line_rec.rate IS NOT NULL
         AND p_claim_line_rec.rate <> FND_API.g_miss_num)
     THEN
       l_claim_line_rec.claim_currency_amount := l_claim_line_rec.quantity * l_claim_line_rec.rate;
     END IF;

     -------- raise error if claim currency amount is null ----------
     IF l_claim_line_rec.claim_currency_amount IS NULL THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_NULL');
          FND_MSG_PUB.add;
       END IF;
       RAISE FND_API.g_exc_error;
     END IF;
  END IF;

  ---------------- get claim exchange data -------------------
  -- No need to set global claim exc info if it's updating from tbl
  IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
     OPEN c_claim_default_exc(l_claim_line_rec.claim_id);
     FETCH c_claim_default_exc INTO G_CLAIM_SET_OF_BOOKS_ID
                                  , G_CLAIM_CURRENCY
                                  , G_CLAIM_EXC_TYPE
                                  , G_CLAIM_EXC_DATE
                                  , G_CLAIM_EXC_RATE;
     CLOSE c_claim_default_exc;
  END IF;

  OPEN csr_function_currency;
  FETCH csr_function_currency INTO l_function_currency;
  CLOSE csr_function_currency;

  -------------------- convert currency --------------------------------------
  --  Note1: Accounted Amount is recalculated at every update to allow for change
  --  of amount/exchange rate at the claim header
  --  Note2: Amount is recalculated at every update to allow for change of
  --  amount/exchange rate at the claim header and change of source object
  --  information.
  --  Modified for Bug4437696

   IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_claim_line_rec.claim_line_id =' ||l_claim_line_rec.claim_line_id);
   END IF;

   OPEN csr_claim_line_util_amt(l_claim_line_rec.claim_line_id);
   FETCH csr_claim_line_util_amt INTO l_line_util_acc_amt,l_line_util_sum;
   CLOSE csr_claim_line_util_amt;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_line_util_acc_amt =' ||l_line_util_acc_amt);
        OZF_Utility_PVT.debug_message('l_line_util_sum =' ||l_line_util_sum);
        OZF_Utility_PVT.debug_message('l_claim_line_rec.claim_currency_amount =' ||l_claim_line_rec.claim_currency_amount);
      END IF;

  IF (p_claim_line_rec.acctd_amount IS NULL OR p_claim_line_rec.acctd_amount = FND_API.g_miss_num) THEN
    IF l_claim_line_rec.claim_currency_amount IS NULL THEN
        l_claim_line_rec.acctd_amount := NULL;
        l_claim_line_rec.amount := NULL;
    ELSE

       -- fix for bug 7658894
     IF (l_line_util_sum = l_claim_line_rec.claim_currency_amount) THEN
                l_claim_line_rec.acctd_amount := l_line_util_acc_amt;

      ELSE

              -- Convert ACCTD_AMOUNT
              OZF_UTILITY_PVT.Convert_Currency(
                     P_SET_OF_BOOKS_ID => G_CLAIM_SET_OF_BOOKS_ID,
                     P_FROM_CURRENCY   => G_CLAIM_CURRENCY,
                     P_CONVERSION_DATE => G_CLAIM_EXC_DATE,
                     P_CONVERSION_TYPE => G_CLAIM_EXC_TYPE,
                     P_CONVERSION_RATE => G_CLAIM_EXC_RATE,
                     P_AMOUNT          => l_claim_line_rec.claim_currency_amount,
                     X_RETURN_STATUS   => l_return_status,
                     X_ACC_AMOUNT      => l_claim_line_rec.acctd_amount,
                     X_RATE            => l_rate
              );
              IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
              ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
              END IF;
      END IF;

      -- Convert Line Amount
      -- For Price Protection
      -- Fix for 7443072
      -- Bugfix 7811671
      IF ((l_claim_line_rec.source_object_class IS NULL OR l_claim_line_rec.source_object_class IN('PPCUSTOMER','PPVENDOR','PPINCVENDOR','SD_SUPPLIER'))
       AND l_claim_line_rec.source_object_id IS NULL) THEN
        IF (p_claim_line_rec.claim_currency_amount <> FND_API.g_miss_num
           AND p_claim_line_rec.claim_currency_amount IS NOT NULL ) THEN
          l_claim_line_rec.currency_code := G_CLAIM_CURRENCY;
          l_claim_line_rec.exchange_rate_type := G_CLAIM_EXC_TYPE;
          l_claim_line_rec.exchange_rate_date := G_CLAIM_EXC_DATE;
          l_claim_line_rec.exchange_rate := G_CLAIM_EXC_RATE;
          l_claim_line_rec.amount := l_claim_line_rec.claim_currency_amount;
        END IF;
      ELSE
        Convert_Line_Amount(
              p_claim_line_rec    => l_claim_line_rec
             ,x_claim_line_rec    => l_x_claim_line_rec
             ,x_return_status     => l_return_status
        );
        IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
        l_claim_line_rec := l_x_claim_line_rec;
      END IF;
    END IF;

  END IF;

  ------------------- amount rounding --------------------
  IF l_claim_line_rec.claim_currency_amount IS NOT NULL THEN
    l_claim_line_rec.claim_currency_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.claim_currency_amount, G_CLAIM_CURRENCY);
  END IF;

  IF l_claim_line_rec.amount IS NOT NULL THEN
    l_claim_line_rec.amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.amount, l_claim_line_rec.currency_code);
  END IF;

  IF l_claim_line_rec.acctd_amount IS NOT NULL THEN
    l_claim_line_rec.acctd_amount := OZF_UTILITY_PVT.CurrRound(l_claim_line_rec.acctd_amount, l_function_currency);
  END IF;

  -------------------- amount checking --------------------------------
  IF l_claim_line_rec.claim_currency_amount IS NOT NULL THEN
    -- get claim amount from database (amount_remaining)
    OPEN c_claim_amount(l_claim_line_rec.claim_id);
    FETCH c_claim_amount INTO l_claim_amount, l_claim_class,l_offer_id;
    CLOSE c_claim_amount;

    -- -------------------------------------------------------------------------------------------
    -- Bug        : 2781186
    -- Changed by : (uday poluri)  Date: 03-Jun-2003
    -- Comments   : Following if condition (IF l_claim_line_rec.claim_currency_amount <> 0 THEN)
    --              is added, because subsequent application can update the claim amount as Zero
    --              so as claim_line_amount.
    -- -------------------------------------------------------------------------------------------
    -- 20-APR-04 Commenting the sign check for the claim amounts, as for a claim negative line amount
    -- can be specified to associate negative accruals. Similarily valid for DED/OPM.
    --IF l_claim_line_rec.claim_currency_amount <> 0 THEN   --Bug:2781186
       -- Sign of claim_currency_amount should be the same as claim amount_remaining
      --DATE : 03-jun-2003 [Changed for Sign erro in case of partial application for claim investigation.]
     -- IF l_claim_amount <> 0 THEN
       -- Sign of claim_currency_amount should be the same as claim amount_remaining
      -- IF SIGN(l_claim_line_rec.claim_currency_amount) <> SIGN(l_claim_amount) THEN
      --   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      --     FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_AMT_SIGN_ERR');
      --     FND_MSG_PUB.add;
      --   END IF;
      --   RAISE FND_API.g_exc_error;
      -- END IF;
      --END IF;
    --END IF;   --Bug:2781186

    -- skip amount comparison if it's updating from tbl.
    -- commenting update_from_tbl_flag since checking does not happen
    -- updated by skrishn
    -- mchang: open the cursor again to fix BUG#2242644
    IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
      -- get total of existing line amount (sum of claim_currency_amount)
      OPEN c_line_sum_amt(l_claim_line_rec.claim_id, l_claim_line_rec.claim_line_id);
      FETCH c_line_sum_amt INTO l_line_sum_amt;
      CLOSE c_line_sum_amt;

   -- -------------------------------------------------------------------------------------------
   -- Bug        : 2781186
   -- Changed by : (Uday Poluri)  Date: 03-Jun-2003
   -- Comments   : Add p_mode check, If it is AUTO then allow amount change on claim.
   --              PLEASE check with Michelle about this
   -- -------------------------------------------------------------------------------------------

   IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message('l_offer_id =' ||l_offer_id);
   END IF;
    -- ER#9453443 : Added the offer id check
   IF p_mode <> OZF_claim_Utility_pvt.G_AUTO_MODE
   AND p_mode <> OZF_claim_Utility_pvt.G_REQUEST_MODE
   AND l_claim_class <> 'GROUP' AND l_offer_id IS NULL
   THEN    --Bug:2781186
      -- comparison of claim amount and line amount
      IF l_line_sum_amt IS NOT NULL THEN
        IF ABS(l_line_sum_amt + l_claim_line_rec.claim_currency_amount) > ABS(l_claim_amount) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
            FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;
      ELSIF ABS(l_claim_line_rec.claim_currency_amount) > ABS(l_claim_amount) THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_EXCESS_AMOUNT');
          FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;
     END IF;
    END IF;
  END IF;

  ---------------- check associate earnings flag ------------------------
  IF p_claim_line_rec.earnings_associated_flag = FND_API.g_false THEN
    -- remove associated earnings
    OPEN csr_get_lines_util(l_claim_line_rec.claim_line_id);
    LOOP
      FETCH csr_get_lines_util INTO l_line_util_tbl(l_counter).claim_line_util_id
                                  , l_line_util_tbl(l_counter).object_version_number
                                  , l_line_util_tbl(l_counter).currency_code;
      EXIT WHEN csr_get_lines_util%NOTFOUND;
      l_line_util_tbl(l_counter).claim_line_id := l_claim_line_rec.claim_line_id;
      l_counter := l_counter + 1;
    END LOOP;
    CLOSE csr_get_lines_util;

    IF l_counter > 1 THEN
      OZF_Claim_Accrual_PVT.Delete_Line_Util_Tbl(
          p_api_version            => l_api_version
         ,p_init_msg_list          => FND_API.g_false
         ,p_commit                 => FND_API.g_false
         ,p_validation_level       => FND_API.g_valid_level_full
         ,x_return_status          => l_return_status
         ,x_msg_data               => x_msg_data
         ,x_msg_count              => x_msg_count
         ,p_line_util_tbl          => l_line_util_tbl
         ,p_mode                   => OZF_CLAIM_UTILITY_PVT.g_auto_mode
         ,x_error_index            => l_error_index
      );
      IF l_return_status =  fnd_api.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

 ELSE
     ------- check line acctd amount is more then earnings acctd amount -------

     IF ABS(nvl(l_claim_line_rec.acctd_amount,0)) < ABS(l_line_util_acc_amt) THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_EXCESS_LINE_AMT');
          FND_MSG_PUB.add;
                END IF;
             RAISE FND_API.g_exc_error;
     END IF;

 END IF;

 -- validate claim line record based on claim settlement method
IF l_claim_line_rec.update_from_tbl_flag = FND_API.g_false THEN
    OZF_CLAIM_SETTLEMENT_VAL_PVT.Validate_Claim_Line(
        p_api_version           => l_api_version
       ,p_init_msg_list         => FND_API.g_false
       ,p_validation_level      => FND_API.g_valid_level_full
       ,x_return_status         => l_return_status
       ,x_msg_data              => x_msg_data
       ,x_msg_count             => x_msg_count
       ,p_claim_line_rec        => l_claim_line_rec
    );
    IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
 END IF;



  -- Bug4489415: Make the Tax Call
  IF  l_claim_line_rec.tax_action IS NOT NULL AND
     l_claim_line_rec.amount IS NOT NULL  THEN

     OPEN c_claim_payment_method(l_claim_line_rec.claim_id);
     FETCH c_claim_payment_method INTO l_payment_method;
     CLOSE c_claim_payment_method;

     IF OZF_DEBUG_HIGH_ON THEN
        OZF_Utility_PVT.debug_message(' Tax Action =' ||l_claim_line_rec.tax_action);
        OZF_Utility_PVT.debug_message(' Payment Method =' ||l_payment_method);
     END IF;

     IF l_payment_method IS NOT NULL THEN

        OZF_CLAIM_TAX_PVT.Calculate_Claim_Line_Tax(
            p_api_version           => l_api_version
           ,p_init_msg_list         => FND_API.g_false
           ,p_validation_level      => FND_API.g_valid_level_full
           ,x_return_status         => l_return_status
           ,x_msg_data              => x_msg_data
           ,x_msg_count             => x_msg_count
           ,p_x_claim_line_rec      => l_claim_line_rec
        );
        IF l_return_status =  FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF;

  END IF;
 --//Bugfix: 8829808
 l_object_version_number := l_claim_line_rec.object_version_number + 1;
 -------------------------- update --------------------
 IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name ||': update');
 END IF;

 UPDATE ozf_claim_lines_all SET
       object_version_number         = l_object_version_number,
       last_update_date              = SYSDATE,
       last_updated_by               = l_last_updated_by,
       last_update_login             = l_last_update_login,
       request_id                    = FND_GLOBAL.CONC_REQUEST_ID,
       program_application_id        = FND_GLOBAL.PROG_APPL_ID,
       program_update_date           = SYSDATE,
       program_id                    = FND_GLOBAL.CONC_PROGRAM_ID,
       created_from                  = l_claim_line_rec.created_from,
       claim_id                     = l_claim_line_rec.claim_id,
       line_number                  = l_claim_line_rec.line_number,
       split_from_claim_line_id     = l_claim_line_rec.split_from_claim_line_id,
       amount                       = l_claim_line_rec.amount,
       claim_currency_amount        = l_claim_line_rec.claim_currency_amount,
       acctd_amount                 = l_claim_line_rec.acctd_amount,
       currency_code                = l_claim_line_rec.currency_code,
       exchange_rate_type           = l_claim_line_rec.exchange_rate_type,
       exchange_rate_date           = l_claim_line_rec.exchange_rate_date,
       exchange_rate                = l_claim_line_rec.exchange_rate,
       set_of_books_id              = l_claim_line_rec.set_of_books_id,
       valid_flag                   = l_claim_line_rec.valid_flag,
       source_object_id             = l_claim_line_rec.source_object_id,
       source_object_line_id        = l_claim_line_rec.source_object_line_id,
       source_object_class          = l_claim_line_rec.source_object_class,
       source_object_type_id        = l_claim_line_rec.source_object_type_id,
       plan_id                      = l_claim_line_rec.plan_id,
       offer_id                     = l_claim_line_rec.offer_id,
       utilization_id               = l_claim_line_rec.utilization_id,
       payment_method               = l_claim_line_rec.payment_method,
       payment_reference_id         = l_claim_line_rec.payment_reference_id,
       payment_reference_number     = l_claim_line_rec.payment_reference_number,
       payment_reference_date       = l_claim_line_rec.payment_reference_date,
       voucher_id                   = l_claim_line_rec.voucher_id,
       voucher_number               = l_claim_line_rec.voucher_number,
       payment_status               = l_claim_line_rec.payment_status,
       approved_flag                = l_claim_line_rec.approved_flag,
       approved_date                = l_claim_line_rec.approved_date,
       approved_by                  = l_claim_line_rec.approved_by,
       settled_date                 = l_claim_line_rec.settled_date,
       settled_by                   = l_claim_line_rec.settled_by,
       performance_complete_flag    = l_claim_line_rec.performance_complete_flag,
       performance_attached_flag    = l_claim_line_rec.performance_attached_flag,
       select_cust_children_flag    = l_claim_line_rec.select_cust_children_flag,
       item_id                      = l_claim_line_rec.item_id,
       item_description             = l_claim_line_rec.item_description,
       quantity                     = l_claim_line_rec.quantity,
       quantity_uom                 = l_claim_line_rec.quantity_uom,
       rate                         = l_claim_line_rec.rate,
       activity_type                = l_claim_line_rec.activity_type,
       activity_id                  = l_claim_line_rec.activity_id,
       related_cust_account_id      = l_claim_line_rec.related_cust_account_id,
       buy_group_cust_account_id    = l_claim_line_rec.buy_group_cust_account_id,
       relationship_type            = l_claim_line_rec.relationship_type,
       earnings_associated_flag     = l_claim_line_rec.earnings_associated_flag,
       comments                     = l_claim_line_rec.comments,
       tax_code                     = l_claim_line_rec.tax_code,
       credit_to                    = l_claim_line_rec.credit_to,
       attribute_category           = l_claim_line_rec.attribute_category,
       attribute1                   = l_claim_line_rec.attribute1,
       attribute2                   = l_claim_line_rec.attribute2,
       attribute3                   = l_claim_line_rec.attribute3,
       attribute4                   = l_claim_line_rec.attribute4,
       attribute5                   = l_claim_line_rec.attribute5,
       attribute6                   = l_claim_line_rec.attribute6,
       attribute7                   = l_claim_line_rec.attribute7,
       attribute8                   = l_claim_line_rec.attribute8,
       attribute9                   = l_claim_line_rec.attribute9,
       attribute10                  = l_claim_line_rec.attribute10,
       attribute11                  = l_claim_line_rec.attribute11,
       attribute12                  = l_claim_line_rec.attribute12,
       attribute13                  = l_claim_line_rec.attribute13,
       attribute14                  = l_claim_line_rec.attribute14,
       attribute15                  = l_claim_line_rec.attribute15,
       sale_date                    = l_claim_line_rec.sale_date,
       item_type                    = l_claim_line_rec.item_type,
       tax_amount                   = l_claim_line_rec.tax_amount,
       acctd_tax_amount             = l_claim_line_rec.acctd_tax_amount,
       claim_curr_tax_amount        = l_claim_line_rec.claim_curr_tax_amount,
       activity_line_id             = l_claim_line_rec.activity_line_id,
       offer_type                   = l_claim_line_rec.offer_type,
       prorate_earnings_flag        = l_claim_line_rec.prorate_earnings_flag,
       earnings_end_date            = l_claim_line_rec.earnings_end_date,
       buy_group_party_id           = l_claim_line_rec.buy_group_party_id,
       --12.1 Enhancement : Price Protection
       dpp_cust_account_id          = l_claim_line_rec.dpp_cust_account_id

  WHERE claim_line_id = l_claim_line_rec.claim_line_id
  AND   object_version_number = l_claim_line_rec.object_version_number;

  IF (SQL%NOTFOUND) THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  -------------------- finish --------------------------
  x_object_version := l_object_version_number;

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
    ROLLBACK TO Update_Claim_Line;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Update_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO Update_Claim_Line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END Update_Claim_Line;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Claim_Line
--
-- HISTORY
--    07/11/2000  mchang  Create.
--------------------------------------------------------------------
PROCEDURE Validate_Claim_Line(
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2  := FND_API.g_false
  ,p_validation_level   IN  NUMBER    := FND_API.g_valid_level_full

  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2

  ,p_claim_line_rec     IN  claim_line_rec_type
)
IS
l_api_version CONSTANT NUMBER       := 1.0;
l_api_name    CONSTANT VARCHAR2(30) := 'Validate_Claim_Line';
l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

l_return_status VARCHAR2(1);

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

  ---------------------- validate ------------------------
  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': check items');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
    Check_Claim_Line_Items(
       p_claim_line_rec       => p_claim_line_rec,
       p_validation_mode      => JTF_PLSQL_API.g_create,
       x_return_status        => l_return_status
    );

    IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    ELSIF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    END IF;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     OZF_Utility_PVT.debug_message(l_full_name||': check record');
  END IF;

  IF p_validation_level >= JTF_PLSQL_API.g_valid_level_record THEN
    Check_Claim_Line_Record(
       p_claim_line_rec       => p_claim_line_rec,
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

END Validate_Claim_Line;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Req_Items
--
-- HISTORY
--    07/11/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Req_Items(
   p_claim_line_rec     IN  claim_line_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   ------------------------ CLAIM_ID -------------------------------
   IF p_claim_line_rec.claim_id <> FND_API.g_miss_num AND
      p_claim_line_rec.claim_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'CLAIM_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ LINE_NUMBER -------------------------------
   ELSIF p_claim_line_rec.line_number <> FND_API.g_miss_num AND
         p_claim_line_rec.line_number IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'LINE_NUMBER');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   ------------------------ SET_OF_BOOKS_ID -------------------------------
   ELSIF p_claim_line_rec.set_of_books_id <> FND_API.g_miss_num AND
         p_claim_line_rec.set_of_books_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_MISSING_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'SET_OF_BOOKS_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

END Check_Claim_Line_Req_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Uk_Items
--
-- HISTORY
--    07/11/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Uk_Items(
   p_claim_line_rec     IN  claim_line_rec_type
  ,p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- For Create_Claim_Line, when claim_line_id is passed in, we need to
  -- check if this claim_line_id is unique.
  IF p_validation_mode = JTF_PLSQL_API.g_create AND
     p_claim_line_rec.claim_line_id IS NOT NULL THEN
    IF OZF_Utility_PVT.check_uniqueness(
                'ozf_claim_lines',
                'claim_line_id = ' || p_claim_line_rec.claim_line_id
       ) = FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_DUPLICATE_VALUE');
        FND_MESSAGE.set_token('COLLUMN', 'CLAIM_LINE_ID');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  -- check other unique items

END Check_Claim_Line_Uk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Fk_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Fk_Items(
   p_claim_line_rec     IN  claim_line_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  -- check other fk items

END Check_Claim_Line_Fk_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Lookup_Items
--
-- HISTORY
--    04/25/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Lookup_Items(
   p_claim_line_rec     IN  claim_line_rec_type
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
BEGIN

  x_return_status := FND_API.g_ret_sts_success;

  -- check other lookup codes

END Check_Claim_Line_Lookup_Items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Flag_Items
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Flag_Items(
   p_claim_line_rec  IN  claim_line_rec_type
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  ----------------------- VALID_FLAG ------------------------
  IF p_claim_line_rec.valid_flag <> FND_API.g_miss_char AND
     p_claim_line_rec.valid_flag IS NOT NULL THEN
    IF p_claim_line_rec.valid_flag <> FND_API.g_true AND
       p_claim_line_rec.valid_flag <> FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
        FND_MESSAGE.set_token('FLAG', 'VALID_FLAG');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  ----------------------- APPROVED_FLAG ------------------------
  IF p_claim_line_rec.approved_flag <> FND_API.g_miss_char AND
     p_claim_line_rec.approved_flag IS NOT NULL THEN
    IF p_claim_line_rec.approved_flag <> FND_API.g_true AND
       p_claim_line_rec.approved_flag <> FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
        FND_MESSAGE.set_token('FLAG', 'APPROVED_FLAG');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  ----------------------- PERFORMANCE_COMPLETE_FLAG ------------------------
  IF p_claim_line_rec.performance_complete_flag <> FND_API.g_miss_char AND
     p_claim_line_rec.performance_complete_flag IS NOT NULL THEN
    IF p_claim_line_rec.performance_complete_flag <> FND_API.g_true AND
       p_claim_line_rec.performance_complete_flag <> FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
        FND_MESSAGE.set_token('FLAG', 'PERFORMANCE_COMPLETE_FLAG');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  ----------------------- PERFORMANCE_ATTACHED_FLAG ------------------------
  IF p_claim_line_rec.performance_attached_flag <> FND_API.g_miss_char AND
     p_claim_line_rec.performance_attached_flag IS NOT NULL THEN
    IF p_claim_line_rec.performance_attached_flag <> FND_API.g_true AND
       p_claim_line_rec.performance_attached_flag <> FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
        FND_MESSAGE.set_token('FLAG', 'PERFORMANCE_ATTACHED_FLAG');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  ----------------------- EARNINGS_ASSOCIATED_FLAG ------------------------
  IF p_claim_line_rec.earnings_associated_flag <> FND_API.g_miss_char AND
     p_claim_line_rec.earnings_associated_flag IS NOT NULL THEN
    IF p_claim_line_rec.earnings_associated_flag <> FND_API.g_true AND
       p_claim_line_rec.earnings_associated_flag <> FND_API.g_false THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_BAD_FLAG');
        FND_MESSAGE.set_token('FLAG', 'EARNINGS_ASSOCIATED_FLAG');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  -- check other flags

END Check_Claim_Line_Flag_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Items
--
-- HISTORY
--    07/11/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Items(
   p_claim_line_rec  IN  claim_line_rec_type
  ,p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
  ,x_return_status   OUT NOCOPY VARCHAR2
)
IS
BEGIN
  Check_Claim_Line_Req_Items(
    p_claim_line_rec      => p_claim_line_rec
   ,x_return_status       => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  Check_Claim_Line_Uk_Items(
    p_claim_line_rec      => p_claim_line_rec
   ,p_validation_mode     => p_validation_mode
   ,x_return_status       => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  Check_Claim_Line_Fk_Items(
    p_claim_line_rec      => p_claim_line_rec
   ,x_return_status       => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  Check_Claim_Line_Lookup_Items(
    p_claim_line_rec      => p_claim_line_rec
   ,x_return_status       => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

  Check_Claim_Line_Flag_Items(
    p_claim_line_rec      => p_claim_line_rec
   ,x_return_status       => x_return_status
  );

  IF x_return_status <> FND_API.g_ret_sts_success THEN
    RETURN;
  END IF;

END Check_Claim_Line_Items;



---------------------------------------------------------------------
-- PROCEDURE
--    Check_Claim_Line_Record
--
-- HISTORY
--    07/11/2000  mchang  Create.
--    03/20/2001  mchang  Remove utilization amount checking.
---------------------------------------------------------------------
PROCEDURE Check_Claim_Line_Record(
   p_claim_line_rec     IN  claim_line_rec_type
  ,p_complete_rec       IN  claim_line_rec_type := NULL
  ,x_return_status      OUT NOCOPY VARCHAR2
)
IS
l_tax_for            VARCHAR2(15);
l_tax_code           VARCHAR2(30);
l_source_object_id  NUMBER;

CURSOR csr_claim_settle_method(cv_claim_id IN NUMBER) IS
SELECT  ocs.tax_for
FROM     ozf_claim_sttlmnt_methods_all  ocs,
              ozf_claims_all oc
WHERE  claim_id =  cv_claim_id
AND     ocs.claim_class = oc.claim_class
AND     NVL(ocs.source_object_class,'NULL') = NVL(oc.source_object_class,'NULL')
AND     ocs.settlement_method = oc.payment_method ;

CURSOR csr_ap_tax_code(cv_tax_code IN VARCHAR2) IS
  SELECT lookup_code
  FROM    fnd_lookups lkp
  WHERE  lkp.lookup_type in ( 'ZX_INPUT_CLASSIFICATIONS', 'ZX_WEB_EXP_TAX_CLASSIFICATIONS' )
  AND       lkp.enabled_flag = 'Y'  ;

CURSOR csr_ar_tax_code(cv_tax_code IN VARCHAR2) IS
  SELECT lookup_code
  FROM    fnd_lookups lkp
  WHERE  lkp.lookup_type = 'ZX_OUTPUT_CLASSIFICATIONS'
  AND       lkp.enabled_flag = 'Y'  ;


CURSOR csr_customer_trx_id(cv_customer_trx_line_id IN NUMBER) IS
  SELECT customer_trx_id
  FROM ra_customer_trx_lines
  WHERE customer_trx_line_id = cv_customer_trx_line_id;

BEGIN
  x_return_status := FND_API.g_ret_sts_success;

  -- check if tax code belonging to the right settlement method
  IF p_complete_rec.tax_code IS NOT NULL THEN
    OPEN csr_claim_settle_method(p_complete_rec.claim_id);
    FETCH csr_claim_settle_method INTO l_tax_for;
    CLOSE csr_claim_settle_method;

    IF l_tax_for = 'AP' THEN
      OPEN csr_ap_tax_code(p_complete_rec.tax_code);
      FETCH csr_ap_tax_code INTO l_tax_code;
      CLOSE csr_ap_tax_code;

      IF l_tax_code IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TAX_CODE_ERR');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    ELSIF  l_tax_for = 'AR' THEN
      OPEN csr_ar_tax_code(p_complete_rec.tax_code);
      FETCH csr_ar_tax_code INTO l_tax_code;
      CLOSE csr_ar_tax_code;

      IF l_tax_code IS NULL THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TAX_CODE_ERR');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    ELSIF l_tax_for IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_LINE_TAX_CODE_ERR');
        FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
    END IF;
  END IF;

  -- check if source_object_line_id belongs to source_object_id
  IF p_complete_rec.source_object_line_id IS NOT NULL THEN
    IF p_complete_rec.source_object_class = 'INVOICE' AND
       p_complete_rec.source_object_id IS NOT NULL THEN
      OPEN csr_customer_trx_id(p_complete_rec.source_object_line_id);
      FETCH csr_customer_trx_id INTO l_source_object_id;
      CLOSE csr_customer_trx_id;

      IF l_source_object_id <> p_complete_rec.source_object_id THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
          FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_INVLINE_NOT_IN_INV');
          FND_MSG_PUB.add;
        END IF;
        x_return_status := FND_API.g_ret_sts_error;
        RETURN;
      END IF;
    END IF;
  END IF;

END Check_Claim_Line_Record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Claim_Line_Rec
--
-- HISTORY
--    06/12/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Init_Claim_Line_Rec(
   x_claim_line_rec   OUT NOCOPY  claim_line_rec_type
)
IS
BEGIN


   RETURN;
END Init_Claim_Line_Rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Claim_Line_Rec
--
-- HISTORY
--    07/11/2000  mchang  Create.
---------------------------------------------------------------------
PROCEDURE Complete_Claim_Line_Rec(
   p_claim_line_rec     IN  claim_line_rec_type
  ,x_complete_rec       OUT NOCOPY claim_line_rec_type
)
IS
CURSOR c_claim_line(cv_claim_line_id  IN NUMBER) IS
SELECT  object_version_number,
       claim_id,
       line_number,
       split_from_claim_line_id,
       amount,
       claim_currency_amount,
       acctd_amount,
       currency_code,
       exchange_rate_type,
       exchange_rate_date,
       exchange_rate,
       set_of_books_id,
       valid_flag,
       source_object_id,
       source_object_line_id,
       source_object_class,
       source_object_type_id,
       plan_id,
       offer_id,
       utilization_id,
       payment_method,
       payment_reference_id,
       payment_reference_number,
       payment_reference_date,
       voucher_id,
       voucher_number,
       payment_status,
       approved_flag,
       approved_date,
       approved_by,
       settled_date,
       settled_by,
       performance_complete_flag,
       performance_attached_flag,
       select_cust_children_flag,
       item_id,
       item_description,
       quantity,
       quantity_uom,
       rate,
       activity_type,
       activity_id,
       related_cust_account_id,
       buy_group_cust_account_id,
       relationship_type,
       earnings_associated_flag,
       comments,
       tax_code,
       credit_to,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       sale_date,
       item_type,
       tax_amount,
       claim_curr_tax_amount,
       acctd_tax_amount, -- Bug4489415
       activity_line_id,
       offer_type,
       prorate_earnings_flag,
       earnings_end_date,
       buy_group_party_id,
       dpp_cust_account_id --12.1 Enhancement : Price Protection
FROM  ozf_claim_lines
WHERE  claim_line_id = cv_claim_line_id;

l_claim_line_rec  c_claim_line%ROWTYPE;

BEGIN

  x_complete_rec := p_claim_line_rec;

  OPEN c_claim_line(p_claim_line_rec.claim_line_id);
  FETCH c_claim_line INTO l_claim_line_rec;
  IF c_claim_line%NOTFOUND THEN
    CLOSE c_claim_line;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('OZF', 'OZF_API_RECORD_NOT_FOUND');
      FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;
  CLOSE c_claim_line;

  IF p_claim_line_rec.object_version_number = FND_API.G_MISS_NUM THEN
     x_complete_rec.object_version_number := NULL;
  END IF;
  IF p_claim_line_rec.object_version_number IS NULL THEN
     x_complete_rec.object_version_number := l_claim_line_rec.object_version_number;
  END IF;

  IF p_claim_line_rec.claim_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_id := NULL;
  END IF;
  IF p_claim_line_rec.claim_id IS NULL THEN
     x_complete_rec.claim_id := l_claim_line_rec.claim_id;
  END IF;

  IF p_claim_line_rec.line_number = FND_API.G_MISS_NUM THEN
     x_complete_rec.line_number := NULL;
  END IF;
  IF p_claim_line_rec.line_number IS NULL THEN
     x_complete_rec.line_number := l_claim_line_rec.line_number;
  END IF;

  IF p_claim_line_rec.split_from_claim_line_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.split_from_claim_line_id := NULL;
  END IF;
  IF p_claim_line_rec.split_from_claim_line_id IS NULL THEN
     x_complete_rec.split_from_claim_line_id := l_claim_line_rec.split_from_claim_line_id;
  END IF;

  IF p_claim_line_rec.amount = FND_API.G_MISS_NUM  THEN
     x_complete_rec.amount := NULL;
  END IF;
  IF p_claim_line_rec.amount IS NULL THEN
     x_complete_rec.amount := l_claim_line_rec.amount;
  END IF;

  IF p_claim_line_rec.claim_currency_amount = FND_API.G_MISS_NUM  THEN
     x_complete_rec.claim_currency_amount := NULL;
  END IF;
  IF p_claim_line_rec.claim_currency_amount IS NULL THEN
     x_complete_rec.claim_currency_amount := l_claim_line_rec.claim_currency_amount;
  END IF;

  IF p_claim_line_rec.acctd_amount = FND_API.G_MISS_NUM  THEN
     x_complete_rec.acctd_amount := NULL;
  END IF;
  IF p_claim_line_rec.acctd_amount IS NULL THEN
     x_complete_rec.acctd_amount := l_claim_line_rec.acctd_amount;
  END IF;

  IF p_claim_line_rec.currency_code = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.currency_code := NULL;
  END IF;
  IF p_claim_line_rec.currency_code IS NULL THEN
     x_complete_rec.currency_code := l_claim_line_rec.currency_code;
  END IF;

  IF p_claim_line_rec.exchange_rate_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.exchange_rate_type := NULL;
  END IF;
  IF p_claim_line_rec.exchange_rate_type IS NULL THEN
     x_complete_rec.exchange_rate_type := l_claim_line_rec.exchange_rate_type;
  END IF;

  IF p_claim_line_rec.exchange_rate_date = FND_API.G_MISS_DATE  THEN
     x_complete_rec.exchange_rate_date := NULL;
  END IF;
  IF p_claim_line_rec.exchange_rate_date IS NULL THEN
     x_complete_rec.exchange_rate_date := l_claim_line_rec.exchange_rate_date;
  END IF;

  IF p_claim_line_rec.exchange_rate = FND_API.G_MISS_NUM  THEN
     x_complete_rec.exchange_rate := NULL;
  END IF;
  IF p_claim_line_rec.exchange_rate IS NULL THEN
     x_complete_rec.exchange_rate := l_claim_line_rec.exchange_rate;
  END IF;

  IF p_claim_line_rec.set_of_books_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.set_of_books_id := NULL;
  END IF;
  IF p_claim_line_rec.set_of_books_id IS NULL THEN
     x_complete_rec.set_of_books_id := l_claim_line_rec.set_of_books_id;
  END IF;

  IF p_claim_line_rec.valid_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.valid_flag := NULL;
  END IF;
  IF p_claim_line_rec.valid_flag IS NULL THEN
     x_complete_rec.valid_flag := l_claim_line_rec.valid_flag;
  END IF;

  IF p_claim_line_rec.source_object_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_id := NULL;
  END IF;
  IF p_claim_line_rec.source_object_id IS NULL THEN
     x_complete_rec.source_object_id := l_claim_line_rec.source_object_id;
  END IF;

  IF p_claim_line_rec.source_object_line_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.source_object_line_id := NULL;
  END IF;
  IF p_claim_line_rec.source_object_line_id IS NULL THEN
     x_complete_rec.source_object_line_id := l_claim_line_rec.source_object_line_id;
  END IF;

  IF p_claim_line_rec.source_object_class = FND_API.G_MISS_CHAR THEN
     x_complete_rec.source_object_class := NULL;
  END IF;
  IF p_claim_line_rec.source_object_class IS NULL THEN
     x_complete_rec.source_object_class := l_claim_line_rec.source_object_class;
  END IF;

  IF p_claim_line_rec.source_object_type_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.source_object_type_id := NULL;
  END IF;
  IF p_claim_line_rec.source_object_type_id IS NULL THEN
     x_complete_rec.source_object_type_id := l_claim_line_rec.source_object_type_id;
  END IF;

  IF p_claim_line_rec.plan_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.plan_id := NULL;
  END IF;
  IF p_claim_line_rec.plan_id IS NULL THEN
     x_complete_rec.plan_id := l_claim_line_rec.plan_id;
  END IF;

  IF p_claim_line_rec.offer_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.offer_id := NULL;
  END IF;
  IF p_claim_line_rec.offer_id IS NULL THEN
     x_complete_rec.offer_id := l_claim_line_rec.offer_id;
  END IF;

  IF p_claim_line_rec.utilization_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.utilization_id := NULL;
  END IF;
  IF p_claim_line_rec.utilization_id IS NULL THEN
     x_complete_rec.utilization_id := l_claim_line_rec.utilization_id;
  END IF;

  IF p_claim_line_rec.payment_method = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_method := NULL;
  END IF;
  IF p_claim_line_rec.payment_method IS NULL THEN
     x_complete_rec.payment_method := l_claim_line_rec.payment_method;
  END IF;

  IF p_claim_line_rec.payment_reference_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.payment_reference_id := NULL;
  END IF;
  IF p_claim_line_rec.payment_reference_id IS NULL THEN
     x_complete_rec.payment_reference_id := l_claim_line_rec.payment_reference_id;
  END IF;

  IF p_claim_line_rec.payment_reference_number = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_reference_number := NULL;
  END IF;
  IF p_claim_line_rec.payment_reference_number IS NULL THEN
     x_complete_rec.payment_reference_number := l_claim_line_rec.payment_reference_number;
  END IF;

  IF p_claim_line_rec.payment_reference_date = FND_API.G_MISS_DATE THEN
     x_complete_rec.payment_reference_date := NULL;
  END IF;
  IF p_claim_line_rec.payment_reference_date IS NULL THEN
     x_complete_rec.payment_reference_date := l_claim_line_rec.payment_reference_date;
  END IF;

  IF p_claim_line_rec.voucher_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.voucher_id := NULL;
  END IF;
  IF p_claim_line_rec.voucher_id IS NULL THEN
     x_complete_rec.voucher_id := l_claim_line_rec.voucher_id;
  END IF;

  IF p_claim_line_rec.voucher_number = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.voucher_number := NULL;
  END IF;
  IF p_claim_line_rec.voucher_number IS NULL THEN
     x_complete_rec.voucher_number := l_claim_line_rec.voucher_number;
  END IF;

  IF p_claim_line_rec.payment_status = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.payment_status := NULL;
  END IF;
  IF p_claim_line_rec.payment_status IS NULL THEN
     x_complete_rec.payment_status := l_claim_line_rec.payment_status;
  END IF;

  IF p_claim_line_rec.approved_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.approved_flag := NULL;
  END IF;
  IF p_claim_line_rec.approved_flag IS NULL THEN
     x_complete_rec.approved_flag := l_claim_line_rec.approved_flag;
  END IF;

  IF p_claim_line_rec.approved_date = FND_API.G_MISS_DATE  THEN
     x_complete_rec.approved_date := NULL;
  END IF;
  IF p_claim_line_rec.approved_date IS NULL THEN
     x_complete_rec.approved_date := l_claim_line_rec.approved_date;
  END IF;

  IF p_claim_line_rec.approved_by = FND_API.G_MISS_NUM  THEN
     x_complete_rec.approved_by := NULL;
  END IF;
  IF p_claim_line_rec.approved_by IS NULL THEN
     x_complete_rec.approved_by := l_claim_line_rec.approved_by;
  END IF;

  IF p_claim_line_rec.settled_date = FND_API.G_MISS_DATE  THEN
     x_complete_rec.settled_date := NULL;
  END IF;
  IF p_claim_line_rec.settled_date IS NULL THEN
     x_complete_rec.settled_date := l_claim_line_rec.settled_date;
  END IF;

  IF p_claim_line_rec.settled_by = FND_API.G_MISS_NUM  THEN
     x_complete_rec.settled_by := NULL;
  END IF;
  IF p_claim_line_rec.settled_by IS NULL THEN
     x_complete_rec.settled_by := l_claim_line_rec.settled_by;
  END IF;

  IF p_claim_line_rec.performance_complete_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.performance_complete_flag := NULL;
  END IF;
  IF p_claim_line_rec.performance_complete_flag IS NULL THEN
     x_complete_rec.performance_complete_flag := l_claim_line_rec.performance_complete_flag;
  END IF;

  IF p_claim_line_rec.performance_attached_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.performance_attached_flag := NULL;
  END IF;
  IF p_claim_line_rec.performance_attached_flag IS NULL THEN
     x_complete_rec.performance_attached_flag := l_claim_line_rec.performance_attached_flag;
  END IF;

  IF p_claim_line_rec.select_cust_children_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.select_cust_children_flag := NULL;
  END IF;
  IF p_claim_line_rec.select_cust_children_flag IS NULL THEN
     x_complete_rec.select_cust_children_flag := l_claim_line_rec.select_cust_children_flag;
  END IF;

  IF p_claim_line_rec.attribute_category = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute_category := NULL;
  END IF;
  IF p_claim_line_rec.attribute_category IS NULL THEN
     x_complete_rec.attribute_category := l_claim_line_rec.attribute_category;
  END IF;

  IF p_claim_line_rec.item_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.item_id := NULL;
  END IF;
  IF p_claim_line_rec.item_id IS NULL THEN
     x_complete_rec.item_id := l_claim_line_rec.item_id;
  END IF;

  IF p_claim_line_rec.item_description = FND_API.G_MISS_CHAR THEN
     x_complete_rec.item_description := NULL;
  END IF;
  IF p_claim_line_rec.item_description IS NULL THEN
     x_complete_rec.item_description := l_claim_line_rec.item_description;
  END IF;

  IF p_claim_line_rec.quantity = FND_API.G_MISS_NUM  THEN
     x_complete_rec.quantity := NULL;
  END IF;
  IF p_claim_line_rec.quantity IS NULL THEN
     x_complete_rec.quantity := l_claim_line_rec.quantity;
  END IF;

  IF p_claim_line_rec.quantity_uom = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.quantity_uom := NULL;
  END IF;
  IF p_claim_line_rec.quantity_uom IS NULL THEN
     x_complete_rec.quantity_uom := l_claim_line_rec.quantity_uom;
  END IF;

  IF p_claim_line_rec.rate = FND_API.G_MISS_NUM  THEN
     x_complete_rec.rate := NULL;
  END IF;
  IF p_claim_line_rec.rate IS NULL THEN
     x_complete_rec.rate := l_claim_line_rec.rate;
  END IF;

  IF p_claim_line_rec.activity_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.activity_type := NULL;
  END IF;
  IF p_claim_line_rec.activity_type IS NULL THEN
     x_complete_rec.activity_type := l_claim_line_rec.activity_type;
  END IF;

  IF p_claim_line_rec.activity_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.activity_id := NULL;
  END IF;
  IF p_claim_line_rec.activity_id IS NULL THEN
     x_complete_rec.activity_id := l_claim_line_rec.activity_id;
  END IF;

  IF p_claim_line_rec.related_cust_account_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.related_cust_account_id := NULL;
  END IF;
  IF p_claim_line_rec.related_cust_account_id IS NULL THEN
     x_complete_rec.related_cust_account_id := l_claim_line_rec.related_cust_account_id;
  END IF;

  IF p_claim_line_rec.buy_group_cust_account_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.buy_group_cust_account_id := NULL;
  END IF;
  IF p_claim_line_rec.buy_group_cust_account_id IS NULL THEN
     x_complete_rec.buy_group_cust_account_id := l_claim_line_rec.buy_group_cust_account_id;
  END IF;

  IF p_claim_line_rec.relationship_type = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.relationship_type := NULL;
  END IF;
  IF p_claim_line_rec.relationship_type IS NULL THEN
     x_complete_rec.relationship_type := l_claim_line_rec.relationship_type;
  END IF;

  IF p_claim_line_rec.earnings_associated_flag = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.earnings_associated_flag := NULL;
  END IF;
  IF p_claim_line_rec.earnings_associated_flag IS NULL THEN
     x_complete_rec.earnings_associated_flag := l_claim_line_rec.earnings_associated_flag;
  END IF;

  IF p_claim_line_rec.comments = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.comments := NULL;
  END IF;
  IF p_claim_line_rec.comments IS NULL THEN
     x_complete_rec.comments := l_claim_line_rec.comments;
  END IF;

  IF p_claim_line_rec.tax_code = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_code := NULL;
  END IF;
  IF p_claim_line_rec.tax_code IS NULL THEN
     x_complete_rec.tax_code := l_claim_line_rec.tax_code;
  END IF;

  IF p_claim_line_rec.credit_to = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.credit_to := NULL;
  END IF;
  IF p_claim_line_rec.credit_to IS NULL THEN
     x_complete_rec.credit_to := l_claim_line_rec.credit_to;
  END IF;

  IF p_claim_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute1 := NULL;
  END IF;
  IF p_claim_line_rec.attribute1 IS NULL THEN
     x_complete_rec.attribute1 := l_claim_line_rec.attribute1;
  END IF;

  IF p_claim_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute2 := NULL;
  END IF;
  IF p_claim_line_rec.attribute2 IS NULL THEN
     x_complete_rec.attribute2 := l_claim_line_rec.attribute2;
  END IF;

  IF p_claim_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute3 := NULL;
  END IF;
  IF p_claim_line_rec.attribute3 IS NULL THEN
     x_complete_rec.attribute3 := l_claim_line_rec.attribute3;
  END IF;

  IF p_claim_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute4 := NULL;
  END IF;
  IF p_claim_line_rec.attribute4 IS NULL THEN
     x_complete_rec.attribute4 := l_claim_line_rec.attribute4;
  END IF;

  IF p_claim_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute5 := NULL;
  END IF;
  IF p_claim_line_rec.attribute5 IS NULL THEN
     x_complete_rec.attribute5 := l_claim_line_rec.attribute5;
  END IF;

  IF p_claim_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute6 := NULL;
  END IF;
  IF p_claim_line_rec.attribute6 IS NULL THEN
     x_complete_rec.attribute6 := l_claim_line_rec.attribute6;
  END IF;

  IF p_claim_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute7 := NULL;
  END IF;
  IF p_claim_line_rec.attribute7 IS NULL THEN
     x_complete_rec.attribute7 := l_claim_line_rec.attribute7;
  END IF;

  IF p_claim_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute8 := NULL;
  END IF;
  IF p_claim_line_rec.attribute8 IS NULL THEN
     x_complete_rec.attribute8 := l_claim_line_rec.attribute8;
  END IF;

  IF p_claim_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute9 := NULL;
  END IF;
  IF p_claim_line_rec.attribute9 IS NULL THEN
     x_complete_rec.attribute9 := l_claim_line_rec.attribute9;
  END IF;

  IF p_claim_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute10 := NULL;
  END IF;
  IF p_claim_line_rec.attribute10 IS NULL THEN
     x_complete_rec.attribute10 := l_claim_line_rec.attribute10;
  END IF;

  IF p_claim_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute11 := NULL;
  END IF;
  IF p_claim_line_rec.attribute11 IS NULL THEN
     x_complete_rec.attribute11 := l_claim_line_rec.attribute11;
  END IF;

  IF p_claim_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute12 := NULL;
  END IF;
  IF p_claim_line_rec.attribute12 IS NULL THEN
     x_complete_rec.attribute12 := l_claim_line_rec.attribute12;
  END IF;

  IF p_claim_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute13 := NULL;
  END IF;
  IF p_claim_line_rec.attribute13 IS NULL THEN
     x_complete_rec.attribute13 := l_claim_line_rec.attribute13;
  END IF;

  IF p_claim_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute14 := NULL;
  END IF;
  IF p_claim_line_rec.attribute14 IS NULL THEN
     x_complete_rec.attribute14 := l_claim_line_rec.attribute14;
  END IF;

  IF p_claim_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
     x_complete_rec.attribute15 := NULL;
  END IF;
  IF p_claim_line_rec.attribute15 IS NULL THEN
     x_complete_rec.attribute15 := l_claim_line_rec.attribute15;
  END IF;

  IF p_claim_line_rec.update_from_tbl_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.update_from_tbl_flag := NULL;
  END IF;
  IF p_claim_line_rec.update_from_tbl_flag IS NULL THEN
     x_complete_rec.update_from_tbl_flag := FND_API.g_false;
  END IF;

  IF p_claim_line_rec.sale_date = FND_API.G_MISS_DATE THEN
     x_complete_rec.sale_date := NULL;
  END IF;
  IF p_claim_line_rec.sale_date IS NULL THEN
     x_complete_rec.sale_date := l_claim_line_rec.sale_date;
  END IF;

  IF p_claim_line_rec.item_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.item_type := NULL;
  END IF;
  IF p_claim_line_rec.item_type IS NULL THEN
     x_complete_rec.item_type := l_claim_line_rec.item_type;
  END IF;

  IF p_claim_line_rec.tax_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.tax_amount := NULL;
  END IF;
  IF p_claim_line_rec.tax_amount IS NULL THEN
     x_complete_rec.tax_amount := l_claim_line_rec.tax_amount;
  END IF;

  IF p_claim_line_rec.claim_curr_tax_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.claim_curr_tax_amount := NULL;
  END IF;
  IF p_claim_line_rec.claim_curr_tax_amount IS NULL THEN
     x_complete_rec.claim_curr_tax_amount := l_claim_line_rec.claim_curr_tax_amount;
  END IF;

  -- Added for Bug4489415
  IF p_claim_line_rec.acctd_tax_amount = FND_API.G_MISS_NUM THEN
     x_complete_rec.acctd_tax_amount := NULL;
  END IF;
  IF p_claim_line_rec.acctd_tax_amount IS NULL THEN
     x_complete_rec.acctd_tax_amount := l_claim_line_rec.acctd_tax_amount;
  END IF;

  IF p_claim_line_rec.activity_line_id = FND_API.G_MISS_NUM THEN
     x_complete_rec.activity_line_id := NULL;
  END IF;
  IF p_claim_line_rec.activity_line_id IS NULL THEN
     x_complete_rec.activity_line_id := l_claim_line_rec.activity_line_id;
  END IF;

  IF p_claim_line_rec.offer_type = FND_API.G_MISS_CHAR THEN
     x_complete_rec.offer_type := NULL;
  END IF;
  IF p_claim_line_rec.offer_type IS NULL THEN
     x_complete_rec.offer_type := l_claim_line_rec.offer_type;
  END IF;

  IF p_claim_line_rec.prorate_earnings_flag = FND_API.G_MISS_CHAR THEN
     x_complete_rec.prorate_earnings_flag := NULL;
  END IF;
  IF p_claim_line_rec.prorate_earnings_flag IS NULL THEN
     x_complete_rec.prorate_earnings_flag := l_claim_line_rec.prorate_earnings_flag;
  END IF;


  IF p_claim_line_rec.earnings_end_date = FND_API.G_MISS_DATE THEN
     x_complete_rec.earnings_end_date := NULL;
  END IF;
  IF p_claim_line_rec.earnings_end_date IS NULL THEN
     x_complete_rec.earnings_end_date := l_claim_line_rec.earnings_end_date;
  END IF;

  IF p_claim_line_rec.buy_group_party_id = FND_API.G_MISS_NUM  THEN
     x_complete_rec.buy_group_party_id := NULL;
  END IF;
  IF p_claim_line_rec.buy_group_party_id IS NULL THEN
     x_complete_rec.buy_group_party_id := l_claim_line_rec.buy_group_party_id;
  END IF;

  -- Bug4489415
  IF p_claim_line_rec.tax_action = FND_API.G_MISS_CHAR  THEN
     x_complete_rec.tax_action := NULL;
  END IF;

--12.1 Enhancement : Price Protection
  IF p_claim_line_rec.dpp_cust_account_id IS NULL THEN
     x_complete_rec.dpp_cust_account_id := l_claim_line_rec.dpp_cust_account_id;
  END IF;
END Complete_Claim_Line_Rec;

---------------------------------------------------------------------
-- PROCEDURE
--    Split_Claim_Lines
--
-- PURPOSE
--    Split claim lines so as to associate each claim line with
--    earnings from only one offer-product combination.
--
--
-- Date         UID     Description
-- 29-Jul-2005  Sahana  Created for Bug4348163
-- 03-Mar-06    azahmed  bugfix 5075837 line number increment
---------------------------------------------------------------------
PROCEDURE split_claim_line(
   p_api_version            IN    NUMBER
  ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,p_claim_line_id       IN  NUMBER
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
)
IS

l_api_version  CONSTANT  NUMBER := 1.0;
l_api_name     CONSTANT  VARCHAR2(30) := 'split_claim_line';
l_full_name    CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


CURSOR csr_line(cv_line_id IN NUMBER) IS
SELECT  object_version_number,
       claim_id,
       line_number,
       split_from_claim_line_id,
       amount,
       claim_currency_amount,
       acctd_amount,
       currency_code,
       exchange_rate_type,
       exchange_rate_date,
       exchange_rate,
       set_of_books_id,
       valid_flag,
       source_object_id,
       source_object_line_id,
       source_object_class,
       source_object_type_id,
       plan_id,
       offer_id,
       utilization_id,
       payment_method,
       payment_reference_id,
       payment_reference_number,
       payment_reference_date,
       voucher_id,
       voucher_number,
       payment_status,
       approved_flag,
       approved_date,
       approved_by,
       settled_date,
       settled_by,
       performance_complete_flag,
       performance_attached_flag,
       select_cust_children_flag,
       item_id,
       item_description,
       quantity,
       quantity_uom,
       rate,
       activity_type,
       activity_id,
       related_cust_account_id,
       buy_group_cust_account_id,
       relationship_type,
       earnings_associated_flag,
       comments,
       tax_code,
       credit_to,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       sale_date,
       item_type,
       tax_amount,
       claim_curr_tax_amount,
       activity_line_id,
       offer_type,
       prorate_earnings_flag,
       earnings_end_date,
       buy_group_party_id,
       org_id
FROM  ozf_claim_lines
WHERE  claim_line_id = cv_line_id;


-- Cursor modified for Bug4997509
-- Selected activity_type from fu
CURSOR csr_line_utils(cv_line_id IN NUMBER) IS
   SELECT offer_id,
          activity_type,
          product_level_type,
          product_id,
          SUM(amount),
          SUM(acctd_amount),
          SUM(util_curr_amount)
   FROM
 (SELECT fu.plan_id offer_id,
         fu.plan_type activity_type,
         fu.product_level_type product_level_type,
         fu.product_id product_id,
         utl.amount amount,
         utl.acctd_amount acctd_amount,
         utl.util_curr_amount util_curr_amount
  FROM   ozf_funds_utilized_all_b fu, ozf_claim_lines_util utl
  WHERE  utl.utilization_id = fu.utilization_id
  AND    utl.claim_line_id = cv_line_id
  AND    utl.utilization_id <> -1
  UNION ALL
  SELECT act.act_product_used_by_id offer_id,
         'OFFR' activity_type,
         act.level_type_code product_level_type,
         NVL(act.inventory_item_id, act.category_id) product_id,
         utl.amount amount,
         utl.acctd_amount acctd_amount,
         NVL(utl.util_curr_amount,utl.amount) util_curr_amount
  FROM   ams_act_products act, ozf_claim_lines_util utl
  WHERE  utl.activity_product_id = act.activity_product_id
  AND    utl.claim_line_id = cv_line_id
  AND    utl.utilization_id = -1)
  GROUP BY offer_id,activity_type, product_level_type, product_id;


CURSOR    csr_claim_status(cv_claim_id IN NUMBER) IS
  SELECT  status_code
   FROM   ozf_claims_all
  WHERE   claim_id = cv_claim_id;

  -- added for bugfix 5075837 to get max line number
  CURSOR c_line_number(cv_claim_id IN NUMBER) IS
 SELECT MAX(line_number)
 FROM ozf_claim_lines
 WHERE claim_id = cv_claim_id;

 -- Fix for bug 7658894
CURSOR  csr_claim_line_util_sum(cv_claim_line_id IN NUMBER) IS
SELECT sum(amount), sum(acctd_amount)
FROM    ozf_claim_lines_util_all
WHERE   claim_line_id = cv_claim_line_id;

CURSOR  csr_claim_line_sum(cv_claim_line_id IN NUMBER) IS
SELECT  nvl(amount,0), nvl(acctd_amount,0)
FROM    ozf_claim_lines_all
WHERE   claim_line_id = cv_claim_line_id;

l_sum_util_amount NUMBER :=0;
l_sum_util_acctd_amount NUMBER :=0;
l_line_amount NUMBER :=0;
l_line_acctd_amount NUMBER :=0;

l_old_line_rec          csr_line%ROWTYPE;
l_claim_line_rec        OZF_CLAIM_LINE_PVT.claim_line_rec_type;

l_status_code            VARCHAR2(30);
l_offer_id               NUMBER;
l_util_product_id        NUMBER;
l_util_product_level     VARCHAR2(30);
l_claim_line_amount      NUMBER;
l_acctd_amount           NUMBER;
l_currency_amount        NUMBER;
l_line_return_status     VARCHAR2(1);
l_claim_line_id          NUMBER;
l_activity_product_id    NUMBER;
l_uom_code               VARCHAR2(30);
l_activity_type          VARCHAR2(30);
l_max_line_number        NUMBER;



BEGIN


     -------------------- initialize -------------------------
     SAVEPOINT split_claim_line;

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



     -- Get the line being processed
     OPEN  csr_line(p_claim_line_id);
     FETCH csr_line INTO l_old_line_rec;
     CLOSE csr_line;

     OPEN  csr_claim_status(l_old_line_rec.claim_id);
     FETCH csr_claim_status INTO l_status_code;
     CLOSE csr_claim_status;

     -- No need to process if prorate flag is N
     IF (NVL(l_old_line_rec.prorate_earnings_flag,'F') = 'F' OR
            l_status_code IN ('PENDING_CLOSE','CLOSED') ) THEN
        RETURN;
     END IF;


     -- Get all the utilz for the line
     OPEN csr_line_utils(p_claim_line_id);
     LOOP
          FETCH csr_line_utils INTO l_offer_id, l_activity_type,
                                    l_util_product_level, l_util_product_id,
                                    l_claim_line_amount , l_acctd_amount,
                                    l_currency_amount;
          EXIT WHEN csr_line_utils%NOTFOUND;


          IF l_util_product_level = 'PRODUCT' THEN
                --Bugfix 5182181
                l_uom_code :=   Get_Default_Product_UOM
                                    ( p_product_id => l_util_product_id
                                    , p_org_id     => FND_PROFILE.VALUE('AMS_ITEM_ORGANIZATION_ID')
                                );
          END IF;


          IF  csr_line_utils%ROWCOUNT =  1 THEN  -- bugfix 4953092

             -- Update original line with offer-product information
             -- Leave the utilizations with the original line
             UPDATE ozf_claim_lines
               SET  item_id   = l_util_product_id,
                    item_type = l_util_product_level,
                    activity_id  = NVL(l_old_line_rec.activity_id,l_offer_id),
                    activity_type = NVL(l_old_line_rec.activity_type,l_activity_type),
                    offer_id = NVL(l_old_line_rec.offer_id,l_offer_id),
                    quantity_uom = l_uom_code
             WHERE  claim_line_id = p_claim_line_id;
             l_old_line_rec.item_id   := l_util_product_id;
             l_old_line_rec.item_type := l_util_product_level;
             l_old_line_rec.offer_id := l_offer_id;


         ELSE
             --Create a new claim line and move the earnings
             -- Modified: reduce claim currency amount by l_claim_line_amount
             UPDATE ozf_claim_lines
             SET amount = amount - l_claim_line_amount,
                 acctd_amount = acctd_amount - l_acctd_amount,
                 claim_currency_amount= claim_currency_amount - l_claim_line_amount
             WHERE claim_line_id = p_claim_line_id;

            -- get existing max line_number bugfix 5075837
             OPEN c_line_number(l_old_line_rec.claim_id);
             FETCH c_line_number INTO l_max_line_number;
             CLOSE c_line_number;

             l_claim_line_rec.claim_id := l_old_line_rec.claim_id;
             l_claim_line_rec.line_number := l_max_line_number + 1;  --bugfix 5075837
             l_claim_line_rec.split_from_claim_line_id := l_old_line_rec.split_from_claim_line_id;
             l_claim_line_rec.currency_code := l_old_line_rec.currency_code;
             l_claim_line_rec.exchange_rate_type := l_old_line_rec.exchange_rate_type;
             l_claim_line_rec.exchange_rate_date := l_old_line_rec.exchange_rate_date;
             l_claim_line_rec.exchange_rate := l_old_line_rec.exchange_rate;
             l_claim_line_rec.set_of_books_id := l_old_line_rec.set_of_books_id;
             l_claim_line_rec.valid_flag := l_old_line_rec.valid_flag;
             l_claim_line_rec.source_object_id := l_old_line_rec.source_object_id;
             l_claim_line_rec.source_object_line_id := l_old_line_rec.source_object_line_id;
             l_claim_line_rec.source_object_class := l_old_line_rec.source_object_class;
             l_claim_line_rec.source_object_type_id := l_old_line_rec.source_object_type_id;
             l_claim_line_rec.plan_id :=  l_old_line_rec.plan_id;
             l_claim_line_rec.offer_id := l_offer_id;
             l_claim_line_rec.utilization_id := l_old_line_rec.utilization_id;
             l_claim_line_rec.payment_method := l_old_line_rec.payment_method;
             l_claim_line_rec.payment_reference_id := l_old_line_rec.payment_reference_id;
             l_claim_line_rec.payment_reference_number := l_old_line_rec.payment_reference_number;
             l_claim_line_rec.payment_reference_date := l_old_line_rec.payment_reference_date;
             l_claim_line_rec.voucher_id := l_old_line_rec.voucher_id;
             l_claim_line_rec.voucher_number := l_old_line_rec.voucher_number;
             l_claim_line_rec.payment_status := l_old_line_rec.payment_status;
             l_claim_line_rec.approved_flag := l_old_line_rec.approved_flag;
             l_claim_line_rec.approved_date := l_old_line_rec.approved_date;
             l_claim_line_rec.approved_by := l_old_line_rec.approved_by;
             l_claim_line_rec.settled_date := l_old_line_rec.settled_date;
             l_claim_line_rec.settled_by := l_old_line_rec.settled_by;
             l_claim_line_rec.performance_complete_flag := l_old_line_rec.performance_complete_flag;
             l_claim_line_rec.performance_attached_flag := l_old_line_rec.performance_attached_flag;
             l_claim_line_rec.select_cust_children_flag := l_old_line_rec.select_cust_children_flag;
             l_claim_line_rec.related_cust_account_id := l_old_line_rec.related_cust_account_id;
             l_claim_line_rec.buy_group_cust_account_id := l_old_line_rec.buy_group_cust_account_id;
             l_claim_line_rec.relationship_type := l_old_line_rec.relationship_type;
             l_claim_line_rec.earnings_associated_flag := l_old_line_rec.earnings_associated_flag;
             l_claim_line_rec.comments := l_old_line_rec.comments;
             l_claim_line_rec.tax_code := l_old_line_rec.tax_code;
             l_claim_line_rec.credit_to := l_old_line_rec.credit_to;
             l_claim_line_rec.attribute_category := l_old_line_rec.attribute_category;
             l_claim_line_rec.attribute1 := l_old_line_rec.attribute1;
             l_claim_line_rec.attribute2 := l_old_line_rec.attribute2;
             l_claim_line_rec.attribute3 := l_old_line_rec.attribute3;
             l_claim_line_rec.attribute4 := l_old_line_rec.attribute4;
             l_claim_line_rec.attribute5 := l_old_line_rec.attribute5;
             l_claim_line_rec.attribute6 := l_old_line_rec.attribute6;
             l_claim_line_rec.attribute7 := l_old_line_rec.attribute7;
             l_claim_line_rec.attribute8 := l_old_line_rec.attribute8;
             l_claim_line_rec.attribute9 := l_old_line_rec.attribute9;
             l_claim_line_rec.attribute10 := l_old_line_rec.attribute10;
             l_claim_line_rec.attribute11 := l_old_line_rec.attribute11;
             l_claim_line_rec.attribute12 := l_old_line_rec.attribute12;
             l_claim_line_rec.attribute13 := l_old_line_rec.attribute13;
             l_claim_line_rec.attribute14 := l_old_line_rec.attribute14;
             l_claim_line_rec.attribute15 := l_old_line_rec.attribute15;
             l_claim_line_rec.sale_date := l_old_line_rec.sale_date;
             l_claim_line_rec.item_type := l_old_line_rec.item_type;
             l_claim_line_rec.tax_amount := l_old_line_rec.tax_amount;
             l_claim_line_rec.prorate_earnings_flag := l_old_line_rec.prorate_earnings_flag;
             l_claim_line_rec.earnings_end_date := l_old_line_rec.earnings_end_date;
             l_claim_line_rec.buy_group_party_id := l_old_line_rec.buy_group_party_id;
             l_claim_line_rec.item_id := l_util_product_id;
             l_claim_line_rec.item_type := l_util_product_level;
             l_claim_line_rec.amount := l_claim_line_amount;
             l_claim_line_rec.acctd_amount := l_acctd_amount;
             l_claim_line_rec.claim_currency_amount := l_claim_line_amount; -- Modified
             l_claim_line_rec.activity_id  := NVL(l_old_line_rec.activity_id, l_offer_id);
             l_claim_line_rec.activity_type  := NVL(l_old_line_rec.activity_type, 'OFFR');
             l_claim_line_rec.update_from_tbl_flag := FND_API.g_true;


             -- Call API to create new claim line
             ozf_claim_line_pvt.Create_Claim_Line(
                 p_api_version       => 1.0
               , p_init_msg_list     => FND_API.g_false
               , p_commit            => FND_API.g_false
               , p_validation_level  => p_validation_level
               , x_return_status     => x_return_status
               , x_msg_data          => x_msg_data
               , x_msg_count         => x_msg_count
               , p_claim_line_rec    => l_claim_line_rec
               , p_mode              => OZF_CLAIM_UTILITY_PVT.g_auto_mode
               , x_claim_line_id     => l_claim_line_id
              );
             IF x_return_status =  fnd_api.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
             ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
             END IF;

             -- Point the utilizations to the new claim line
             IF l_util_product_id IS NULL AND l_util_product_level IS NULL THEN
                    -- These are adjustment records without product info
                    UPDATE  ozf_claim_lines_util_all
                       SET  claim_line_id = l_claim_line_id
                     WHERE  claim_line_util_id IN ( SELECT util.claim_line_util_id
                                  FROM  ozf_funds_utilized_all_b fu, ozf_claim_lines_util_all util
                                  WHERE fu.utilization_id = util.utilization_id
                                  AND   fu.product_id IS NULL
                                  AND   util.claim_line_id = p_claim_line_id
                                  AND   fu.product_level_type IS NULL
                                  AND   fu.plan_id  = l_offer_id
                                  AND   util.utilization_id > -1);
             ELSE
                   UPDATE  ozf_claim_lines_util_all
                      SET  claim_line_id = l_claim_line_id
                    WHERE  claim_line_util_id in ( SELECT util.claim_line_util_id
                                  FROM  ozf_funds_utilized_all_b fu, ozf_claim_lines_util_all util
                                  WHERE fu.utilization_id = util.utilization_id
                                  AND   fu.product_id = l_util_product_id
                                  AND   util.claim_line_id = p_claim_line_id
                                  AND   fu.product_level_type = l_util_product_level
                                  AND   fu.plan_id  = l_offer_id
                                  AND   util.utilization_id > -1);

                   UPDATE  ozf_claim_lines_util_all
                      SET  claim_line_id = l_claim_line_id
                    WHERE  claim_line_util_id IN (  SELECT utl.claim_line_util_id
                            FROM   ams_act_products act, ozf_claim_lines_util_all utl
                           WHERE   utl.activity_product_id = act.activity_product_id
                             AND   utl.claim_line_id = p_claim_line_id
                             AND   act.level_type_code = l_util_product_level
                             AND   NVL(act.inventory_item_id, act.category_id) = l_util_product_id
                             AND   act.act_product_used_by_id = l_offer_id
                             AND   utilization_id = -1);
             END IF; -- product id is null

             IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('l_claim_line_id'||l_claim_line_id);
             END IF;

             -- Fix for bug 7658894
             OPEN  csr_claim_line_util_sum(l_claim_line_id);
             FETCH csr_claim_line_util_sum INTO l_sum_util_amount,l_sum_util_acctd_amount;
             CLOSE csr_claim_line_util_sum;

             IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('l_sum_util_amount'||l_sum_util_amount);
                   OZF_Utility_PVT.debug_message('l_sum_util_acctd_amount'||l_sum_util_acctd_amount);
             END IF;

             OPEN  csr_claim_line_sum(l_claim_line_id);
             FETCH csr_claim_line_sum INTO l_line_amount,l_line_acctd_amount;
             CLOSE csr_claim_line_sum;

             IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('l_line_amount'||l_line_amount);
                   OZF_Utility_PVT.debug_message('l_sum_util_amount'||l_sum_util_amount);
             END IF;

            IF (l_line_amount = l_sum_util_amount) THEN
                update ozf_claim_lines_all
                set acctd_amount = l_sum_util_acctd_amount
                where claim_line_id = l_claim_line_id;
             END IF;
        END IF; -- update/create claim line
      END LOOP;
  CLOSE csr_line_utils;


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
    ROLLBACK TO split_claim_line;
    x_return_status := FND_API.g_ret_sts_error;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO split_claim_line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO split_claim_line;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false,
            p_count   => x_msg_count,
            p_data    => x_msg_data
    );

END  split_claim_line;

END OZF_Claim_Line_PVT;

/
