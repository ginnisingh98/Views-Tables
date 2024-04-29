--------------------------------------------------------
--  DDL for Package Body OZF_GL_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_GL_INTERFACE_PVT" AS
/* $Header: ozfvglib.pls 120.17.12010000.16 2010/03/31 04:11:56 kpatro ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_GL_INTERFACE_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvglib.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
--G_CLAIM_ID     NUMBER;

---------------------------------------------------------------------
--Bugfix 7431334 - Pushed get_org_id function at top for forward declaration as
--many procedures refering this function in this package.
/*FUNCTION get_org_id (
  p_source_id in number
, p_source_table in varchar2
)
RETURN NUMBER
IS
l_org_id number;

CURSOR claim_org_id_csr (p_id in number) IS
select org_id
from   ozf_claims_all
where  claim_id = p_id;

CURSOR util_org_id_csr (p_id in number) IS
select org_id
from   ozf_funds_utilized_all_b
where  utilization_id = p_id;

BEGIN

  IF p_source_table = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
    OPEN util_org_id_csr (p_source_id);
    FETCH util_org_id_csr INTO l_org_id;
    CLOSE util_org_id_csr;
  ELSIF p_source_table = 'OZF_CLAIMS_ALL' THEN
    OPEN claim_org_id_csr (p_source_id);
    FETCH claim_org_id_csr INTO l_org_id;
    CLOSE claim_org_id_csr;
  END IF;

  RETURN l_org_id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END;
*/
---------------------------------------------------------------------
PROCEDURE Get_GL_Account(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_source_id         IN  NUMBER
   ,p_source_table      IN  VARCHAR2
   ,p_account_type      IN  VARCHAR2
   ,p_event_type        IN  VARCHAR2 DEFAULT NULL
   ,x_cc_id_tbl         OUT NOCOPY CC_ID_TBL)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Get_GL_Account';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
-- in variables
l_account_type  varchar2(80);
l_claim_id      number;
-- accounts
l_expense_account  number;
l_accrual_liability  number;
l_ven_clearing  number;
l_rec_clearing  number;
-- claim type accounts
l_ct_ven_clearing  number;
l_ct_rec_clearing  number;

-- table and counter
TYPE acct_gen_rec IS RECORD (
                          amount              number,
                          acctd_amount        number,
                          currency_code       varchar2(15),
                          utilization_id      number,
                          line_util_id        number,
                          claim_id            number,
                          budget_id           number,
                          offer_type          varchar2(30),
                          offer_id            number,
                          line_type           varchar2(80),
                          line_id             number,
                          item_type           varchar2(30),
                          item_id             number,
                          price_adj_id        number,
                          cust_account_id     number
                     );

TYPE acct_gen_tbl is TABLE of acct_gen_rec;

l_acct_gen_tbl acct_gen_tbl;
l_rec_num      number := 1;

-- get claim_id for a claim line
CURSOR get_claim_id_csr(cv_claim_line_id in number) IS
select claim_id
from   ozf_claim_lines_all
where  claim_line_id = cv_claim_line_id;

-- default accounts from claim type
CURSOR get_claim_type_acc_csr(cv_claim_id in number) IS
select ct.gl_id_ded_clearing       -- vendor clearing account
,      ct.gl_id_ded_adj_clearing   -- receivables clearing account
from   ozf_claim_types_all_b ct
,      ozf_claims_all c
where  ct.claim_type_id = c.claim_type_id
and    c.claim_id = cv_claim_id;

-- default accounts from System Parameter
CURSOR claim_get_sys_param_csr(p_id in number) IS
select osp.gl_id_ded_adj            -- expense account
,      osp.gl_id_accr_promo_liab    -- accrual liability account
,      osp.gl_id_ded_clearing       -- vendor clearing account
,      osp.gl_rec_clearing_account  -- receivables clearing account
FROM   ozf_sys_parameters_all osp
,      ozf_claims_all oc
WHERE  osp.org_id = NVL(oc.org_id, -99)
AND    oc.claim_id = p_id;

-- get accrual totals based on a claim and accrual currency
-- (used for posting to clearing accounts)
CURSOR get_claim_line_amt_csr(p_id in number) IS
SELECT l.claim_currency_amount
,      l.acctd_amount
,      c.currency_code
,      c.claim_id
FROM   ozf_claim_lines_all l
,      ozf_claims_all c
WHERE  l.claim_id = c.claim_id
--AND    l.earnings_associated_flag = 'T'
AND    l.claim_line_id = p_id;


--l_budget_id     number;
--l_offer_type    varchar2(30);
--l_offer_id      number;
--l_order_id      number;
--l_line_type     varchar2(30);
--l_line_id       number;
--l_item_id       number;
--l_price_adj_id  number;
--l_source_id     number;
--l_source_table  varchar2(30) := 'OZF_FUNDS_UTILIZED_ALL_B';
--l_revenue_acct  number;
-- out variables
--l_ccid          number;
--l_concat_segs   varchar2(2000);
--l_concat_ids    varchar2(2000);
--l_concat_descrs varchar2(2000);
-- order info
--l_order_number  number;
--l_line_number   number;

--l_use_acct_gen varchar2(3) := 'Y';
--l_bg_process_mode varchar2(3) := 'Y';

-- get accrual details for one accrual
--(used when creating accruals/adjustements)
-- Fix for Bug 8846853
/*CURSOR get_util_acc_csr(p_id in number) IS
select u.plan_curr_amount
,      u.acctd_amount
--,      u.currency_code
,      u.utilization_id
,      u.fund_id
,      u.component_type
,      u.component_id
,      u.object_type
,      u.object_id
,      u.product_level_type
,      u.product_id
,      u.price_adjustment_id
,      u.cust_account_id
,      u.plan_id
,      u.object_type
,      u.object_id
,      u.exchange_rate
,      u.exchange_rate_type
,      u.exchange_rate_date
from   ozf_funds_utilized_all_b u
where  u.utilization_id = p_id;
*/

--l_plan_id               NUMBER;
--l_object_type           VARCHAR2(30);
--l_object_id             NUMBER;
--l_exchange_rate         NUMBER;
--l_exchange_rate_type    VARCHAR2(150);
--l_exchange_rate_date    DATE;

/*CURSOR offer_code_csr(cv_utilization_id IN NUMBER, cv_plan_id IN NUMBER) IS
select o.transaction_currency_code,
       o.fund_request_curr_code
from   ozf_funds_utilized_all_b fu
,      ozf_offers o
where  fu.plan_id = o.qp_list_header_id
and    fu.plan_id = cv_plan_id
and    fu.utilization_id = cv_utilization_id;

l_tran_curr_code        VARCHAR2(15);
l_fund_req_curr_code    VARCHAR2(30);
*

CURSOR c_get_order_currency (p_document_number IN NUMBER) IS
SELECT transactional_curr_code
FROM oe_order_headers_all
WHERE header_id = p_document_number;

CURSOR c_get_tp_order_currency (p_document_number IN NUMBER) IS
SELECT currency_code
FROM ozf_resale_lines_all
WHERE resale_line_id = p_document_number;

CURSOR c_get_txn_currency (p_document_number IN NUMBER) IS
SELECT invoice_currency_code
FROM ra_customer_trx_all
WHERE customer_trx_id = p_document_number;

CURSOR c_get_pcho_currency (p_document_number IN NUMBER) IS
SELECT currency_code
FROM po_headers_all
WHERE po_header_id = p_document_number;

l_object_curr_code VARCHAR2(30);
l_conv_plan_amount NUMBER;
l_return_status    VARCHAR2 (30);
l_rate             NUMBER;
*/
-- End og Fix for 8846853

-- get accrual details based on a claim
--(used when off-setting accruals paid through claims)
/*CURSOR get_claim_acc_csr(p_id in number) IS
select u.amount
,      u.utilized_acctd_amount
,      u.currency_code
,      u.utilization_id
,      u.claim_line_util_id
,      f.fund_id
,      f.component_type
,      f.component_id
,      f.object_type
,      f.object_id
,      f.product_level_type
,      f.product_id
,      f.price_adjustment_id
,      f.cust_account_id
from   ozf_claim_lines_util_all u
,      ozf_claim_lines_all l
,      ozf_claims_all c
,      ozf_funds_utilized_all_b f
where  u.claim_line_id = l.claim_line_id
and    u.utilization_id = f.utilization_id
and    l.claim_id = c.claim_id
and    c.claim_id = p_id;
*/

-- get accrual totals based on a claim and accrual currency
-- (used for posting to clearing accounts)
/*CURSOR get_claim_amt_csr(p_id in number) IS
-- [BEGIN OF 11.5.9 BUG 4021967 Fixing]
--SELECT SUM(l.claim_currency_amount)
--,      SUM(l.acctd_amount)
SELECT SUM(u.amount)
,      SUM(u.acctd_amount)
,      c.currency_code
FROM   ozf_claim_lines_util_all u
,      ozf_claim_lines_all l
,      ozf_claims_all c
WHERE  l.claim_id = c.claim_id
AND    l.earnings_associated_flag = 'T'
AND    l.claim_line_id = u.claim_line_id
-- [END OF 11.5.9 BUG 4021967 Fixing]
AND    c.claim_id = p_id
GROUP BY c.currency_code;
*/

-- get accrual details based on a claim
--(used when off-setting accruals paid through claims)
/*CURSOR get_claim_line_acc_csr(p_id in number) IS
select u.amount
,      u.utilized_acctd_amount
,      u.currency_code
,      u.utilization_id
,      f.fund_id
,      f.component_type
,      f.component_id
,      f.object_type
,      f.object_id
,      f.product_level_type
,      f.product_id
,      f.price_adjustment_id
,      f.cust_account_id
,      c.claim_id
from   ozf_claim_lines_util_all u
,      ozf_claim_lines_all l
,      ozf_claims_all c
,      ozf_funds_utilized_all_b f
where  u.claim_line_id = l.claim_line_id
and    u.utilization_id = f.utilization_id
and    c.claim_id = l.claim_id
and    l.claim_line_id = p_id;
*/


-- get accrual totals based on accrual associated to a claim
-- (used for posting to product account)
/*CURSOR get_line_util_csr(p_id in number) IS
select u.amount
,      u.utilized_acctd_amount
,      u.currency_code
,      u.utilization_id
,      f.fund_id
,      f.component_type
,      f.component_id
,      f.object_type
,      f.object_id
,      l.item_type
,      l.item_id
,      f.price_adjustment_id
,      f.cust_account_id
,      c.claim_id
from   ozf_claim_lines_util_all u
,      ozf_claim_lines_all l
,      ozf_claims_all c
,      ozf_funds_utilized_all_b f
where  u.claim_line_id = l.claim_line_id
and    u.utilization_id = f.utilization_id
and    c.claim_id = l.claim_id
and    u.claim_line_util_id = p_id;
*/

-- default accounts
/*CURSOR accrual_get_sys_param_csr(p_id in number) IS
select osp.gl_id_ded_adj            -- expense account
,      osp.gl_id_accr_promo_liab    -- accrual liability account
,      osp.gl_id_ded_clearing       -- vendor clearing account
,      osp.gl_rec_clearing_account  -- receivables clearing account
FROM   ozf_sys_parameters_all osp
,      ozf_funds_utilized_all_b ofa
WHERE  osp.org_id = NVL(ofa.org_id, -99)
AND    ofa.utilization_id = p_id;
*/

/*CURSOR util_accrual_account_csr (cv_source_table in varchar2,
                                 cv_source_id in number,
                                 cv_account_type in varchar2)
IS
select code_combination_id
from   ozf_ae_lines_all
where  source_table = cv_source_table
and    source_id    = cv_source_id
and    ae_line_type_code = cv_account_type;
*/
-- Start of fix for bug 4701206
-- get revenue account as defined in AR
--(used when posting off-invoice discounts)
--(and when profile 'OM: Show Discount Details on Invoice' is set to 'No')
-- Replaced Sales_Order Column with interface_line_attribute1 for Bug 8463331
/*CURSOR get_revenue_acct_csr1(p_utiz_id in number) IS
select cgl.code_combination_id
from   ozf_funds_utilized_all_b fu
,      oe_price_adjustments pa
,      oe_order_lines_all ol
,      oe_order_headers_all oh
,      ra_customer_trx_lines_all ctl
,      ra_cust_trx_line_gl_dist_all cgl
where fu.price_adjustment_id = pa.price_adjustment_id
and   ol.line_id = pa.line_id
and   ol.header_id = oh.header_id
and   ctl.interface_line_attribute1 = to_char(oh.order_number)
and   ctl.sales_order_line = ol.line_number
and   cgl.customer_trx_line_id = ctl.customer_trx_line_id
and   cgl.account_class = 'REV'
and   fu.utilization_id = p_utiz_id
and   fu.order_line_id = ctl.interface_line_attribute6; --fix for bug 7431334
*/

-- get revenue account as defined in AR
--(used when posting off-invoice discounts)
--(and when profile 'OM: Show Discount Details on Invoice' is set to 'Yes')
-- Replaced Sales_Order Column with interface_line_attribute1 for Bug 8463331
/*CURSOR get_revenue_acct_csr2(p_utiz_id in number) IS
select cgl.code_combination_id
from   ozf_funds_utilized_all_b fu
,      oe_price_adjustments pa
,      oe_order_lines_all ol
,      oe_order_headers_all oh
,      ra_customer_trx_lines_all ctl
,      ra_cust_trx_line_gl_dist_all cgl
where fu.price_adjustment_id = pa.price_adjustment_id
and   ol.line_id = pa.line_id
and   ol.header_id = oh.header_id
and   ctl.interface_line_attribute1 = to_char(oh.order_number)
and   ctl.sales_order_line = ol.line_number
and   ctl.INTERFACE_LINE_ATTRIBUTE11 = TO_CHAR(pa.price_adjustment_id)
and   cgl.customer_trx_line_id = ctl.customer_trx_line_id
and   cgl.account_class = 'REV'
and   fu.utilization_id = p_utiz_id;
*/
-- End of fix for bug 4701206


-- get order number and order line number for a utilization
/*CURSOR get_order_line_csr(p_utiz_id in number) IS
select oh.order_number
,      ol.line_number
from   ozf_funds_utilized_all_b fu
,      oe_price_adjustments pa
,      oe_order_lines_all ol
,      oe_order_headers_all oh
where fu.price_adjustment_id = pa.price_adjustment_id
and   ol.line_id = pa.line_id
and   ol.header_id = oh.header_id
and   fu.utilization_id = p_utiz_id;
*/

-- R12.1 Enhancement
/*CURSOR get_claim_payment_method_csr(cv_claim_id in number) IS
select c.payment_method
from   ozf_claims_all c
where  c.claim_id = cv_claim_id;
*/

--l_payment_method varchar2(30);

--Added for bug 7431334
/*CURSOR get_om_profle(p_org_id IN NUMBER) IS
select parameter_value from oe_sys_parameters_all
where parameter_code = 'OE_DISCOUNT_DETAILS_ON_INVOICE'
and org_id = p_org_id;
*/

--l_org_id        NUMBER;
--l_oe_disc_dtls_on_invoice VARCHAR2(1);

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_GL_Account_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
       OZF_Utility_PVT.debug_message('p_account_type : '||p_account_type);
    END IF;

   l_acct_gen_tbl := acct_gen_tbl();

   --ER#9382547    ChRM-SLA Uptake
   IF (upper(p_source_table) = 'OZF_CLAIM_LINES_ALL' )THEN

      -- get the claim id
      OPEN get_claim_id_csr(p_source_id);
         FETCH get_claim_id_csr INTO l_claim_id;
      CLOSE get_claim_id_csr;


       -- get default accounts from Claim Type
      OPEN get_claim_type_acc_csr(l_claim_id);
      FETCH get_claim_type_acc_csr INTO l_ct_ven_clearing,
                                        l_ct_rec_clearing;
      CLOSE get_claim_type_acc_csr;

      -- get default accounts from system parameters
      OPEN claim_get_sys_param_csr(l_claim_id);
         FETCH claim_get_sys_param_csr INTO l_expense_account,
                                            l_accrual_liability,
                                            l_ven_clearing,
                                            l_rec_clearing;
      CLOSE claim_get_sys_param_csr;

       -- take vendor clearing from claim type if available
      IF l_ct_ven_clearing is not null AND
         l_ct_ven_clearing <> -10
      THEN
         l_ven_clearing := l_ct_ven_clearing;
      END IF;

      -- take receivable clearing from claim type if available
      IF l_ct_rec_clearing is not null AND
         l_ct_rec_clearing <> -10
      THEN
         l_rec_clearing := l_ct_rec_clearing;
      END IF;

      IF p_account_type = 'VEN_CLEARING'  OR
            p_account_type = 'REC_CLEARING'
      THEN
         -- returns only one record
         OPEN get_claim_line_amt_csr(p_source_id);
            l_acct_gen_tbl.extend;
            FETCH get_claim_line_amt_csr INTO
               l_acct_gen_tbl(l_rec_num).amount,
               l_acct_gen_tbl(l_rec_num).acctd_amount,
               l_acct_gen_tbl(l_rec_num).currency_code,
               l_acct_gen_tbl(l_rec_num).claim_id;
         CLOSE get_claim_line_amt_csr;
      END IF;

   END IF;

   -- initialize the table
   x_cc_id_tbl := CC_ID_TBL();
   FOR i in 1..l_acct_gen_tbl.count LOOP
      IF p_account_type = 'VEN_CLEARING'  OR
         p_account_type = 'REC_CLEARING'
      THEN
         IF l_acct_gen_tbl(i).amount is not null THEN
         -- populate the cc id
         x_cc_id_tbl.extend();
         x_cc_id_tbl(i).amount := l_acct_gen_tbl(i).amount;
         x_cc_id_tbl(i).acctd_amount := l_acct_gen_tbl(i).acctd_amount;
         x_cc_id_tbl(i).currency_code := l_acct_gen_tbl(i).currency_code;
            IF p_account_type = 'VEN_CLEARING' THEN
               x_cc_id_tbl(i).code_combination_id := l_ven_clearing;
            ELSIF p_account_type = 'REC_CLEARING' THEN
               x_cc_id_tbl(i).code_combination_id := l_rec_clearing;
            END IF;
          END IF;
        END IF;
   END LOOP;


  /* IF upper(p_source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN

      -- get default accounts from system parameters
      OPEN accrual_get_sys_param_csr(p_source_id);
         FETCH accrual_get_sys_param_csr INTO l_expense_account,
                                              l_accrual_liability,
                                              l_ven_clearing,
                                              l_rec_clearing;
      CLOSE accrual_get_sys_param_csr;

      IF p_account_type = 'ACCRUAL_LIABILITY' OR
         p_account_type = 'EXPENSE ACCOUNT' OR
         p_account_type = 'REVENUE_ACCOUNT'
      THEN
         OPEN get_util_acc_csr(p_source_id);
            l_acct_gen_tbl.extend;
            FETCH get_util_acc_csr INTO
               l_acct_gen_tbl(l_rec_num).amount,
               l_acct_gen_tbl(l_rec_num).acctd_amount,
               --l_acct_gen_tbl(l_rec_num).currency_code,
               l_acct_gen_tbl(l_rec_num).utilization_id,
               l_acct_gen_tbl(l_rec_num).budget_id,
               l_acct_gen_tbl(l_rec_num).offer_type,
               l_acct_gen_tbl(l_rec_num).offer_id,
               l_acct_gen_tbl(l_rec_num).line_type,
               l_acct_gen_tbl(l_rec_num).line_id,
               l_acct_gen_tbl(l_rec_num).item_type,
               l_acct_gen_tbl(l_rec_num).item_id,
               l_acct_gen_tbl(l_rec_num).price_adj_id,
               l_acct_gen_tbl(l_rec_num).cust_account_id,
               l_plan_id,
               l_object_type,
               l_object_id,
               l_exchange_rate,
               l_exchange_rate_type,
               l_exchange_rate_date;

            -- send offer id if the type if OFFR
            IF l_acct_gen_tbl(l_rec_num).offer_type <> 'OFFR' THEN
               l_acct_gen_tbl(l_rec_num).offer_id := null;
            END IF;
            IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('p_source_id : '||p_source_id);
                   OZF_Utility_PVT.debug_message('l_plan_id : '||l_plan_id);
            END IF;

            -- Added For Bug Fix 8846853
            OPEN offer_code_csr(p_source_id, l_plan_id);
            FETCH offer_code_csr INTO l_tran_curr_code, l_fund_req_curr_code;
            CLOSE offer_code_csr;

             IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('l_tran_curr_code : '||l_tran_curr_code);
                   OZF_Utility_PVT.debug_message('l_fund_req_curr_code : '||l_fund_req_curr_code);
                   OZF_Utility_PVT.debug_message('l_object_type : '||l_object_type);
                   OZF_Utility_PVT.debug_message('l_object_id : '||l_object_id);
             END IF;


            l_acct_gen_tbl(l_rec_num).currency_code := NVL(l_tran_curr_code, l_fund_req_curr_code);

            IF( l_tran_curr_code IS NULL AND l_object_type IS NOT NULL
                  AND  l_object_id IS NOT NULL) THEN
               IF(l_object_type = 'ORDER') THEN
                  OPEN  c_get_order_currency(l_object_id);
                  FETCH c_get_order_currency INTO l_object_curr_code;
                  CLOSE c_get_order_currency;
               ELSIF (l_object_type = 'TP_ORDER') THEN
                  OPEN  c_get_tp_order_currency(l_object_id);
                  FETCH c_get_tp_order_currency INTO l_object_curr_code;
                  CLOSE c_get_tp_order_currency;
               ELSIF (l_object_type = 'INVOICE') THEN
                   OPEN  c_get_txn_currency(l_object_id);
                   FETCH c_get_txn_currency INTO l_object_curr_code;
                   CLOSE c_get_txn_currency;
               ELSIF (l_object_type = 'PCHO') THEN
                   OPEN  c_get_pcho_currency(l_object_id);
                   FETCH c_get_pcho_currency INTO l_object_curr_code;
                   CLOSE c_get_pcho_currency;
               END IF;

               IF OZF_DEBUG_LOW_ON THEN
                   OZF_Utility_PVT.debug_message('l_object_curr_code : '||l_object_curr_code);
                   OZF_Utility_PVT.debug_message('l_fund_req_curr_code : '||l_fund_req_curr_code);
                   OZF_Utility_PVT.debug_message('l_acct_gen_tbl(l_rec_num).amount : '||l_acct_gen_tbl(l_rec_num).amount);
               END IF;

               IF (l_object_curr_code <> l_fund_req_curr_code) THEN

                   ozf_utility_pvt.convert_currency (
                                    p_from_currency  => l_fund_req_curr_code
                                   ,p_to_currency    => l_object_curr_code
                                   ,p_conv_type      => l_exchange_rate_type
                                   ,p_conv_date      => l_exchange_rate_date
                                   ,p_from_amount    => l_acct_gen_tbl(l_rec_num).amount
                                   ,x_return_status  => l_return_status
                                   ,x_to_amount      => l_conv_plan_amount
                                   ,x_rate           => l_rate
                                  );
                     IF l_return_status = fnd_api.g_ret_sts_success THEN

                        IF OZF_DEBUG_LOW_ON THEN
                             OZF_Utility_PVT.debug_message('l_conv_plan_amount : '||l_conv_plan_amount);
                             OZF_Utility_PVT.debug_message('l_object_curr_code : '||l_object_curr_code);
                        END IF;

                          l_acct_gen_tbl(l_rec_num).amount := l_conv_plan_amount;
                          l_acct_gen_tbl(l_rec_num).currency_code := l_object_curr_code;
                     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                          RAISE fnd_api.g_exc_unexpected_error;
                     ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                          RAISE fnd_api.g_exc_error;
                     END IF;
                END IF;

           END IF;
             -- End for Bug Fix 8846853
         CLOSE get_util_acc_csr;
      END IF;
   ELSIF upper(p_source_table) = 'OZF_CLAIMS_ALL' THEN
         l_claim_id := p_source_id;

      -- get default accounts from system parameters
      OPEN claim_get_sys_param_csr(l_claim_id);
         FETCH claim_get_sys_param_csr INTO l_expense_account,
                                            l_accrual_liability,
                                            l_ven_clearing,
                                            l_rec_clearing;
      CLOSE claim_get_sys_param_csr;
      -- Added for Bug 6751352
      IF p_account_type = 'ACCRUAL_LIABILITY'
      OR p_account_type = 'EXPENSE ACCOUNT' THEN
         OPEN get_claim_acc_csr(p_source_id);
            LOOP
               l_acct_gen_tbl.extend;
               FETCH get_claim_acc_csr INTO
                  l_acct_gen_tbl(l_rec_num).amount,
                  l_acct_gen_tbl(l_rec_num).acctd_amount,
                  l_acct_gen_tbl(l_rec_num).currency_code,
                  l_acct_gen_tbl(l_rec_num).utilization_id,
                  l_acct_gen_tbl(l_rec_num).line_util_id,
                  l_acct_gen_tbl(l_rec_num).budget_id,
                  l_acct_gen_tbl(l_rec_num).offer_type,
                  l_acct_gen_tbl(l_rec_num).offer_id,
                  l_acct_gen_tbl(l_rec_num).line_type,
                  l_acct_gen_tbl(l_rec_num).line_id,
                  l_acct_gen_tbl(l_rec_num).item_type,
                  l_acct_gen_tbl(l_rec_num).item_id,
                  l_acct_gen_tbl(l_rec_num).price_adj_id,
                  l_acct_gen_tbl(l_rec_num).cust_account_id;

               -- send offer id if the type if OFFR
               IF l_acct_gen_tbl(l_rec_num).offer_type <> 'OFFR' THEN
                  l_acct_gen_tbl(l_rec_num).offer_id := null;
               END IF;
               -- set the claim id
               l_acct_gen_tbl(l_rec_num).claim_id := p_source_id;
               EXIT WHEN get_claim_acc_csr%notfound;
               l_rec_num := l_rec_num + 1;
            END LOOP;
         CLOSE get_claim_acc_csr;
      ELSIF p_account_type = 'VEN_CLEARING'  OR
            p_account_type = 'REC_CLEARING'
      THEN
         -- returns only one record
         OPEN get_claim_amt_csr(p_source_id);
            LOOP
               l_acct_gen_tbl.extend;
               FETCH get_claim_amt_csr INTO
                  l_acct_gen_tbl(l_rec_num).amount,
                  l_acct_gen_tbl(l_rec_num).acctd_amount,
                  l_acct_gen_tbl(l_rec_num).currency_code;

               -- set the claim id
               l_acct_gen_tbl(l_rec_num).claim_id := p_source_id;
               EXIT WHEN get_claim_amt_csr%notfound;
               l_rec_num := l_rec_num + 1;
            END LOOP;
         CLOSE get_claim_amt_csr;
      END IF;
   ELSIF upper(p_source_table) = 'OZF_CLAIM_LINES_ALL' THEN
         -- get the claim id
         OPEN get_claim_id_csr(p_source_id);
            FETCH get_claim_id_csr INTO l_claim_id;
         CLOSE get_claim_id_csr;

      -- get default accounts from system parameters
      OPEN claim_get_sys_param_csr(l_claim_id);
         FETCH claim_get_sys_param_csr INTO l_expense_account,
                                            l_accrual_liability,
                                            l_ven_clearing,
                                            l_rec_clearing;
      CLOSE claim_get_sys_param_csr;

      IF p_account_type = 'ACCRUAL_LIABILITY' THEN
         OPEN get_claim_line_acc_csr(p_source_id);
            LOOP
               l_acct_gen_tbl.extend;
               FETCH get_claim_line_acc_csr INTO
                  l_acct_gen_tbl(l_rec_num).amount,
                  l_acct_gen_tbl(l_rec_num).acctd_amount,
                  l_acct_gen_tbl(l_rec_num).currency_code,
                  l_acct_gen_tbl(l_rec_num).utilization_id,
                  l_acct_gen_tbl(l_rec_num).budget_id,
                  l_acct_gen_tbl(l_rec_num).offer_type,
                  l_acct_gen_tbl(l_rec_num).offer_id,
                  l_acct_gen_tbl(l_rec_num).line_type,
                  l_acct_gen_tbl(l_rec_num).line_id,
                  l_acct_gen_tbl(l_rec_num).item_type,
                  l_acct_gen_tbl(l_rec_num).item_id,
                  l_acct_gen_tbl(l_rec_num).price_adj_id,
                  l_acct_gen_tbl(l_rec_num).cust_account_id,
                  l_acct_gen_tbl(l_rec_num).claim_id;

               -- send offer id if the type if OFFR
               IF l_acct_gen_tbl(l_rec_num).offer_type <> 'OFFR' THEN
                  l_acct_gen_tbl(l_rec_num).offer_id := null;
               END IF;

               EXIT WHEN get_claim_line_acc_csr%notfound;
               l_rec_num := l_rec_num + 1;
            END LOOP;
         CLOSE get_claim_line_acc_csr;
      ELSIF p_account_type = 'VEN_CLEARING'  OR
            p_account_type = 'REC_CLEARING'
      THEN
         -- returns only one record
         OPEN get_claim_line_amt_csr(p_source_id);
            l_acct_gen_tbl.extend;
            FETCH get_claim_line_amt_csr INTO
               l_acct_gen_tbl(l_rec_num).amount,
               l_acct_gen_tbl(l_rec_num).acctd_amount,
               l_acct_gen_tbl(l_rec_num).currency_code,
               l_acct_gen_tbl(l_rec_num).claim_id;
         CLOSE get_claim_line_amt_csr;
      END IF;
   ELSIF upper(p_source_table) = 'OZF_CLAIM_LINES_UTIL_ALL' THEN
      IF p_account_type = 'ACCRUAL_LIABILITY' OR
         p_account_type = 'EXPENSE ACCOUNT'
      THEN
         OPEN get_line_util_csr(p_source_id);
            LOOP
               l_acct_gen_tbl.extend;
               FETCH get_line_util_csr INTO
                  l_acct_gen_tbl(l_rec_num).amount,
                  l_acct_gen_tbl(l_rec_num).acctd_amount,
                  l_acct_gen_tbl(l_rec_num).currency_code,
                  l_acct_gen_tbl(l_rec_num).utilization_id,
                  l_acct_gen_tbl(l_rec_num).budget_id,
                  l_acct_gen_tbl(l_rec_num).offer_type,
                  l_acct_gen_tbl(l_rec_num).offer_id,
                  l_acct_gen_tbl(l_rec_num).line_type,
                  l_acct_gen_tbl(l_rec_num).line_id,
                  l_acct_gen_tbl(l_rec_num).item_type,
                  l_acct_gen_tbl(l_rec_num).item_id,
                  l_acct_gen_tbl(l_rec_num).price_adj_id,
                  l_acct_gen_tbl(l_rec_num).cust_account_id,
                  l_acct_gen_tbl(l_rec_num).claim_id;

               -- send offer id if the type if OFFR
               IF l_acct_gen_tbl(l_rec_num).offer_type <> 'OFFR' THEN
                  l_acct_gen_tbl(l_rec_num).offer_id := null;
               END IF;
               EXIT WHEN get_line_util_csr%notfound;
               l_rec_num := l_rec_num + 1;
            END LOOP;
         CLOSE get_line_util_csr;
      END IF;
   END IF;
*/


        /*
      ELSIF p_account_type = 'REVENUE_ACCOUNT' THEN
         IF l_acct_gen_tbl(i).amount IS NOT NULL THEN
            -- Start of fix for bug 4701206

            --Bugfix - 7431334 (Start)
            l_org_id := 204;
            get_org_id(p_source_id => p_source_id,
                           p_source_table => upper(p_source_table));
            ozf_utility_pvt.write_conc_log ('l_org_id ' || l_org_id);

            OPEN get_om_profle(l_org_id);
            FETCH get_om_profle INTO l_oe_disc_dtls_on_invoice;
            CLOSE get_om_profle;

            l_oe_disc_dtls_on_invoice := NVL(l_oe_disc_dtls_on_invoice,'N');
            ozf_utility_pvt.write_conc_log ('l_oe_disc_dtls_on_invoice ' || l_oe_disc_dtls_on_invoice);
            --Bugfix - 7431334 (End)

            IF fnd_profile.value('OE_DISCOUNT_DETAILS_ON_INVOICE') = 'Y' THEN
               OPEN get_revenue_acct_csr2(p_source_id);
                  FETCH get_revenue_acct_csr2 INTO l_revenue_acct;
               CLOSE get_revenue_acct_csr2;
            ELSE
               OPEN get_revenue_acct_csr1(p_source_id);
                  FETCH get_revenue_acct_csr1 INTO l_revenue_acct;
               CLOSE get_revenue_acct_csr1;
            END IF;
            -- End of fix for bug 4701206


            IF l_revenue_acct IS NULL THEN
               OPEN get_order_line_csr(p_source_id);
               FETCH get_order_line_csr INTO l_order_number, l_line_number;
               CLOSE get_order_line_csr;

               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_GL_REVENUE_ACCT_NOT_FOUND');
                  FND_MESSAGE.set_token('ORDER_NUM', l_order_number);
                  FND_MESSAGE.set_token('LINE_NUM', l_line_number);
                  FND_MSG_PUB.add;
               END IF;
               x_return_status := FND_API.g_ret_sts_error;
            END IF;

            x_cc_id_tbl.extend();
            x_cc_id_tbl(i).amount := l_acct_gen_tbl(i).amount;
            x_cc_id_tbl(i).acctd_amount := l_acct_gen_tbl(i).acctd_amount;
            x_cc_id_tbl(i).currency_code := l_acct_gen_tbl(i).currency_code;
            x_cc_id_tbl(i).code_combination_id := l_revenue_acct;
         END IF;
      ELSE
       BEGIN
         if l_acct_gen_tbl(i).amount is not null THEN

         -- send line id/order_id if the type is LINE or ORDER
         IF l_acct_gen_tbl(i).line_type = 'ORDER' THEN
            l_line_id := null;
            l_order_id := l_acct_gen_tbl(i).line_id;
         ELSIF l_acct_gen_tbl(i).line_type = 'LINE' THEN
            l_line_id := l_acct_gen_tbl(i).line_id;
            l_order_id := null;
         ELSE
            l_line_id := null;
            l_order_id := null;
         END IF;

         -- get the profile value for GL Accounting mode
         --l_use_acct_gen := nvl(fnd_profile.value('OZF_USE_ACCT_GEN'),'Y');
         -- get the profile value for GL Accounting mode
         l_bg_process_mode := nvl(fnd_profile.value('OZF_CLAIM_SETL_ACCT_BG'),'Y');

         IF l_bg_process_mode = 'N' THEN
            IF upper(p_source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
               l_bg_process_mode := 'Y';
            END IF;
         END IF;

        --R12.1 Enhancement : Checking the payment method
        OPEN get_claim_payment_method_csr(l_claim_id);
            FETCH get_claim_payment_method_csr INTO l_payment_method;
        CLOSE get_claim_payment_method_csr;

         IF upper(p_source_table) = 'OZF_CLAIM_LINES_UTIL_ALL' THEN
            -- use account generator for reposting utilization;
            -- otherwise use the utilization's original account
            -- R12.1 Enhancement : Call the Account Generator for clearing Account
            IF (p_account_type = 'EXPENSE ACCOUNT' AND p_event_type = 'DR') OR
               (p_account_type = 'ACCRUAL_LIABILITY' AND p_event_type = 'CR')OR
               (p_account_type = 'REC_CLEARING' AND p_event_type = 'CR' AND l_payment_method = 'ACCOUNTING_ONLY')
            THEN
               l_bg_process_mode := 'Y';
            ELSE
               l_bg_process_mode := 'N';
            END IF;
         END IF;

         IF l_bg_process_mode = 'Y' THEN
            IF l_use_acct_gen = 'Y' THEN
            Ozf_Acct_Generator.Start_Process (
               p_api_version_number => 1.0,
               p_init_msg_list      => FND_API.G_FALSE,
               p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
               x_return_status      => x_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data,
               p_account_type       => p_account_type,
               p_claim_id           => l_acct_gen_tbl(i).claim_id,
               p_budget_id          => l_acct_gen_tbl(i).budget_id,
               p_utilization_id     => l_acct_gen_tbl(i).utilization_id,
               p_offer_id           => l_acct_gen_tbl(i).offer_id,
               p_order_id           => l_order_id,
               p_line_id            => l_line_id,
               p_item_type          => l_acct_gen_tbl(i).item_type,
               p_item_id            => l_acct_gen_tbl(i).item_id,
               p_price_adj_id       => l_acct_gen_tbl(i).price_adj_id,
               p_cust_account_id    => l_acct_gen_tbl(i).cust_account_id,
               x_return_ccid        => l_ccid,
               x_concat_segs        => l_concat_segs,
               x_concat_ids         => l_concat_ids,
               x_concat_descrs      => l_concat_descrs
            );
            ELSE
            l_ccid := Ozf_Acct_Generator.gl_post_account(
                        p_api_version_number => 1.0,
                        p_account_type  => p_account_type,
                        p_budget_id     => l_acct_gen_tbl(i).budget_id,
                        p_utilization_id => l_acct_gen_tbl(i).utilization_id,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        x_return_status => x_return_status);
            END IF;
         ELSE
            l_source_id := l_acct_gen_tbl(i).utilization_id;
            OPEN util_accrual_account_csr (l_source_table, l_source_id, p_account_type);
              FETCH util_accrual_account_csr INTO l_ccid;
            CLOSE util_accrual_account_csr;
         END IF;

         -- populate the cc id
         x_cc_id_tbl.extend();
         x_cc_id_tbl(i).amount := l_acct_gen_tbl(i).amount;
         x_cc_id_tbl(i).acctd_amount := l_acct_gen_tbl(i).acctd_amount;
         x_cc_id_tbl(i).currency_code := l_acct_gen_tbl(i).currency_code;
         x_cc_id_tbl(i).code_combination_id := l_ccid;
         x_cc_id_tbl(i).utilization_id := l_acct_gen_tbl(i).utilization_id;
         x_cc_id_tbl(i).line_util_id := l_acct_gen_tbl(i).line_util_id;

         end if; -- end amount is not null

       EXCEPTION
         WHEN OTHERS THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('OZF', 'OZF_GL_ACCT_GEN_ERROR');
               FND_MSG_PUB.add;
            END IF;
            x_return_status := FND_API.g_ret_sts_unexp_error;
       END;
       IF OZF_DEBUG_HIGH_ON THEN
       OZF_UTILITY_PVT.debug_message('St and Id '||x_return_status||'-'||l_ccid);
       END IF;
       IF  x_return_status = FND_API.g_ret_sts_error OR
           x_return_status = FND_API.g_ret_sts_unexp_error
       THEN
          EXIT;
       END IF;
      END IF;

   END LOOP;
   */

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_GL_Account_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_GL_Account_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Get_GL_Account_PVT;
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
--
END Get_GL_Account;
---------------------------------------------------------------------
/*PROCEDURE  get_ae_category (p_source_table  IN  VARCHAR2,
                            p_source_id     IN  NUMBER,
                            x_ae_category   OUT NOCOPY VARCHAR2,
                            x_sob_id        OUT NOCOPY NUMBER,
                            x_period_name   OUT NOCOPY VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
l_type       varchar2(30);

CURSOR get_fund_type_csr(p_id in number) IS
SELECT f.fund_type
,      f.ledger_id
,      g.period_set_name
FROM   ozf_funds_all_b f
,      gl_sets_of_books g
,      ozf_funds_utilized_all_b u
WHERE  f.ledger_id = g.set_of_books_id
AND    f.fund_id = u.fund_id
AND    u.utilization_id = p_id;

CURSOR get_claim_class_csr(p_id in number) IS
SELECT c.claim_class
,      c.set_of_books_id
,      g.period_set_name
FROM   ozf_claims_all c
,      gl_sets_of_books g
WHERE  c.set_of_books_id = g.set_of_books_id
AND    c.claim_id = p_id;

BEGIN
   IF upper(p_source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
      OPEN get_fund_type_csr(p_source_id);
         FETCH get_fund_type_csr into l_type, x_sob_id, x_period_name;
      CLOSE get_fund_type_csr;
      IF l_type = 'FIXED' THEN
         x_ae_category := 'Fixed Budgets';
      ELSIF l_type = 'FULLY_ACCRUED' THEN
         x_ae_category := 'Accrual Budgets';
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_FUND_TYPE_ERROR');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   ELSIF upper(p_source_table) = 'OZF_CLAIMS_ALL' THEN
      OPEN get_claim_class_csr(p_source_id);
         FETCH get_claim_class_csr into l_type, x_sob_id, x_period_name;
      CLOSE get_claim_class_csr;

      -- ae category is settlement when settling any claims
      x_ae_category := 'Settlement';

      /*
      IF l_type = 'CLAIM' THEN
         x_ae_category := 'Claims';
      ELSIF l_type = 'DEDUCTION' THEN
         x_ae_category := 'Deductions';
      END IF;

   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_SOURCE_TABLE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_AE_CATG_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END get_ae_category;
*/
---------------------------------------------------------------------
/*FUNCTION  get_event_number(
             p_event_type_code IN  VARCHAR2,
             p_adjustment_type IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
BEGIN
   IF upper(p_event_type_code) = 'ACCRUAL' THEN
      IF p_adjustment_type = 'P' THEN
         return 1;
      ELSIF p_adjustment_type = 'N' THEN
         return 6;
      END IF;
   ELSIF p_event_type_code = 'ACCRUAL_ADJUSTMENT' THEN
      IF p_adjustment_type = 'P' THEN
         return 2;
      ELSIF p_adjustment_type = 'N' THEN
         return 3;
      END IF;
   ELSIF p_event_type_code = 'SETTLE_BY_CHECK' THEN
      return 4;
   ELSIF p_event_type_code = 'SETTLE_BY_CREDIT' THEN
      return 5;
   ELSIF  p_event_type_code = 'CONTRA_CHARGE' THEN
      return 7;
   ELSIF  p_event_type_code = 'SETTLE_BY_DEBIT' THEN
      return 8;
   ELSIF  p_event_type_code = 'SETTLE_BY_WO' THEN
      IF p_adjustment_type = 'P' THEN
         return 9;
      ELSIF p_adjustment_type = 'N' THEN
         return 10;
      END IF;
   ELSIF p_event_type_code = 'OFF_INVOICE' THEN
      IF p_adjustment_type = 'P' THEN
         return 11;
      ELSIF p_adjustment_type = 'N' THEN
         return 12;
      END IF;
   -- R12 changes start
   ELSIF  p_event_type_code = 'SETTLE_BY_AP_DEBIT' THEN
      IF p_adjustment_type = 'P' THEN
         return 13;
      ELSIF p_adjustment_type = 'N' THEN
         return 14;
      END IF;
   ELSIF  p_event_type_code = 'SETTLE_BY_AP_INVOICE' THEN
      return 15;
   ELSIF  p_event_type_code = 'SETTLE_BY_OTHER' THEN
      return 16;
   -- R12 changes end
   -- R12.1 Changes Start
   ELSIF  p_event_type_code = 'SETTLE_BY_ACCOUNTING_ONLY' THEN
      return 17;
   -- R12.1 Changes End
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_ACCT_EVENT');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      return null;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_EVE_NUM_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END get_event_number;
*/
---------------------------------------------------------------------

/*FUNCTION  get_account_type_code(p_event_type_code  IN  VARCHAR2,
              p_event_type       IN  VARCHAR2,
              p_adjustment_type IN  VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

CURSOR taxfor_csr (p_claim_id IN NUMBER)IS
   SELECT tax_for
   FROM ozf_claim_sttlmnt_methods_all csm,ozf_claims_all c
   WHERE csm.settlement_method = c.payment_method
   AND c.claim_id =p_claim_id
   AND csm.org_id = c.org_id;

l_taxfor             VARCHAR2(2);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
   OZF_UTILITY_PVT.debug_message('Get_Account_Type_Code procedure');
   END IF;
   IF p_event_type_code = 'ACCRUAL' OR
      p_event_type_code = 'ACCRUAL_ADJUSTMENT' THEN
      IF p_adjustment_type = 'P' THEN
         IF p_event_type = 'DR' THEN
            return 'EXPENSE ACCOUNT';
         ELSIF p_event_type = 'CR' THEN
            return 'ACCRUAL_LIABILITY';
         END IF;
      ELSIF p_adjustment_type = 'N' THEN
         IF p_event_type = 'DR' THEN
            return 'ACCRUAL_LIABILITY';
         ELSIF p_event_type = 'CR' THEN
            return 'EXPENSE ACCOUNT';
         END IF;
      END IF;
   -- R12: Changed check to AP invoice
   ELSIF p_event_type_code = 'SETTLE_BY_AP_INVOICE' THEN
      IF p_event_type = 'DR' THEN
         return 'ACCRUAL_LIABILITY';
      ELSIF p_event_type = 'CR' THEN
         return 'VEN_CLEARING';
      END IF;
   -- R12.1 Enhancement: checking the evet code for Accounting only
  ELSIF p_event_type_code = 'SETTLE_BY_CREDIT' OR
         p_event_type_code = 'CONTRA_CHARGE' OR
         p_event_type_code = 'SETTLE_BY_ACCOUNTING_ONLY'
   THEN
      IF p_event_type = 'DR' THEN
         return 'ACCRUAL_LIABILITY';
      ELSIF p_event_type = 'CR' THEN
         return 'REC_CLEARING';
      END IF;
   ELSIF p_event_type_code = 'SETTLE_BY_DEBIT' THEN
      IF p_event_type = 'DR' THEN
         return 'REC_CLEARING';
      ELSIF p_event_type = 'CR' THEN
         return 'ACCRUAL_LIABILITY';
      END IF;
   -- R12 changes start
   ELSIF p_event_type_code = 'SETTLE_BY_AP_DEBIT' THEN
      IF p_adjustment_type = 'P' THEN
         IF p_event_type = 'DR' THEN
            return 'VEN_CLEARING';
         ELSIF p_event_type = 'CR' THEN
            return 'EXPENSE ACCOUNT';
         END IF;
      ELSIF p_adjustment_type = 'N' THEN
         IF p_event_type = 'DR' THEN
            return 'VEN_CLEARING';
         ELSIF p_event_type = 'CR' THEN
            return 'ACCRUAL_LIABILITY';
         END IF;
      END IF;
   -- R12 changes end
   ELSIF  p_event_type_code = 'SETTLE_BY_WO' THEN
      IF p_adjustment_type = 'P' THEN
         IF p_event_type = 'DR' THEN
            return 'ACCRUAL_LIABILITY';
         ELSIF p_event_type = 'CR' THEN
            return 'REC_CLEARING';
         END IF;
      ELSIF p_adjustment_type = 'N' THEN
         IF p_event_type = 'DR' THEN
            return 'DED_ADJUSTMENT';
         ELSIF p_event_type = 'CR' THEN
            return 'RECEIVABLES';
         END IF;
      END IF;
   ELSIF p_event_type_code = 'OFF_INVOICE' THEN
      IF p_adjustment_type = 'P' THEN
         IF p_event_type = 'DR' THEN
            return 'EXPENSE ACCOUNT';
         ELSIF p_event_type = 'CR' THEN
            return 'REVENUE_ACCOUNT';
         END IF;
      ELSIF p_adjustment_type = 'N' THEN
         IF p_event_type = 'DR' THEN
            return 'REVENUE_ACCOUNT';
         ELSIF p_event_type = 'CR' THEN
            return 'EXPENSE ACCOUNT';
         END IF;
      END IF;

   -- R12 changes start
    --//Bug 7160927
   --//For settlement method SETTLE_BY_OTHER, set the accounting entries with respect to tax_to value (AR/AP)
   ELSIF p_event_type_code = 'SETTLE_BY_OTHER' THEN

      OPEN taxfor_csr(G_CLAIM_ID);
      FETCH taxfor_csr INTO l_taxfor;
      CLOSE taxfor_csr;

      IF l_taxfor = 'AR' THEN
         IF p_adjustment_type ='P' THEN
            IF p_event_type = 'DR' THEN
               return 'ACCRUAL_LIABILITY';
            ELSIF p_event_type = 'CR' THEN
                return  'REC_CLEARING';
            END IF;
         ELSIF   p_adjustment_type ='N' THEN
            IF p_event_type = 'DR' THEN
               return 'REC_CLEARING';
            ELSIF p_event_type = 'CR' THEN
                return  'ACCRUAL_LIABILITY';
            END IF;
         END IF;
      ELSIF l_taxfor = 'AP' THEN
         IF p_adjustment_type ='P' THEN
            IF p_event_type = 'DR' THEN
               return  'ACCRUAL_LIABILITY';
            ELSIF p_event_type = 'CR' THEN
                return  'VEN_CLEARING';
            END IF;
         ELSIF   p_adjustment_type ='N' THEN
            IF p_event_type = 'DR' THEN
               return 'VEN_CLEARING';
            ELSIF p_event_type = 'CR' THEN
                return  'ACCRUAL_LIABILITY';
            END IF;
         END IF;
      END IF;
   -- R12 changes end

   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_ACCT_EVENT');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      return null;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_ACC_TYPE_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END get_account_type_code;
*/
---------------------------------------------------------------------
/*FUNCTION get_account_description(
              p_gl_rec            IN  gl_interface_rec_type,
              p_account_type_code IN VARCHAR2,
              x_return_status     OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS
l_fund_number   varchar2(30);
l_claim_number  varchar2(30);
l_offer_code    varchar2(30);
l_ae_category   varchar2(80);
l_period_name   varchar2(80);
l_sob           number;

CURSOR offer_code_csr(cv_utilization_id IN NUMBER) IS
select o.offer_code
from   ozf_funds_utilized_all_b fu
,      ozf_offers o
where  fu.plan_type = 'OFFR'
and    fu.plan_id = o.qp_list_header_id
and    fu.utilization_id = cv_utilization_id;

CURSOR fund_number_csr(cv_utilization_id IN NUMBER) IS
select f.fund_number
from   ozf_funds_utilized_all_b fu
,      ozf_funds_all_b f
where  fu.fund_id = f.fund_id
and    fu.utilization_id = cv_utilization_id;

CURSOR claim_number_csr(cv_claim_id IN NUMBER) IS
select claim_number
from   ozf_claims_all
where  claim_id = cv_claim_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
   OZF_UTILITY_PVT.debug_message('Get_Account_Description procedure');
   END IF;
   get_ae_category (p_source_table   => p_gl_rec.source_table,
                    p_source_id      => p_gl_rec.source_id,
                    x_ae_category    => l_ae_category,
                    x_sob_id         => l_sob,
                    x_period_name    => l_period_name,
                    x_return_status  => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF l_ae_category = 'Fixed Budgets' THEN
      OPEN offer_code_csr(p_gl_rec.source_id);
      FETCH offer_code_csr INTO l_offer_code;
      CLOSE offer_code_csr;

      IF l_offer_code IS NOT NULL THEN
         IF p_account_type_code = 'EXPENSE ACCOUNT' THEN
            FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_FB_EXPENSE');
            FND_MESSAGE.SET_TOKEN('OFFER', l_offer_code, FALSE);
            RETURN FND_MESSAGE.GET;
         ELSIF p_account_type_code = 'ACCRUAL_LIABILITY' THEN
            FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_FB_ACCRUAL');
            FND_MESSAGE.SET_TOKEN('OFFER', l_offer_code, FALSE);
            RETURN FND_MESSAGE.GET;
         END IF;
      END IF;
   ELSIF l_ae_category = 'Accrual Budgets' THEN
      OPEN fund_number_csr(p_gl_rec.source_id);
      FETCH fund_number_csr INTO l_fund_number;
      CLOSE fund_number_csr;

      IF p_account_type_code = 'EXPENSE ACCOUNT' THEN
         FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_AB_EXPENSE');
         FND_MESSAGE.SET_TOKEN('FUND', l_fund_number, FALSE);
         RETURN FND_MESSAGE.GET;
      ELSIF p_account_type_code = 'ACCRUAL_LIABILITY' THEN
         FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_AB_ACCRUAL');
         FND_MESSAGE.SET_TOKEN('FUND', l_fund_number, FALSE);
         RETURN FND_MESSAGE.GET;
      END IF;
   ELSIF l_ae_category = 'Settlement' THEN
      OPEN claim_number_csr(p_gl_rec.source_id);
      FETCH claim_number_csr INTO l_claim_number;
      CLOSE claim_number_csr;

      IF p_account_type_code = 'ACCRUAL_LIABILITY' THEN
         FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_STL_ACCRUAL');
         FND_MESSAGE.SET_TOKEN('CLAIM', l_claim_number, FALSE);
         RETURN FND_MESSAGE.GET;
      ELSIF p_account_type_code = 'REC_CLEARING' OR
            p_account_type_code = 'VEN_CLEARING'
      THEN
         FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_STL_CLEARING');
         FND_MESSAGE.SET_TOKEN('CLAIM', l_claim_number, FALSE);
         RETURN FND_MESSAGE.GET;
      -- Added for Bug 6751352
      ELSIF p_account_type_code = 'EXPENSE ACCOUNT' THEN
         FND_MESSAGE.SET_NAME('OZF', 'OZF_GL_DESC_STL_EXPENSE');
         FND_MESSAGE.SET_TOKEN('CLAIM', l_claim_number, FALSE);
         RETURN FND_MESSAGE.GET;
      END IF;
   END IF;

   RETURN null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_ACC_DESC_ERROR');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_unexp_error;
END get_account_description;
*/
---------------------------------------------------------------------

/*PROCEDURE get_line_amount(
           p_gl_rec        IN  gl_interface_rec_type,
           x_amount_tbl    OUT NOCOPY amount_tbl_type,
           x_return_status OUT NOCOPY VARCHAR2 )
IS

l_msg_data         varchar2(2000);
l_msg_count        number;

l_cl_tot           number;

l_expense_account   number;
l_accrual_liability number;
l_ven_clearing      number;
l_rec_clearing      number;
l_rec_deduction     number;

l_debit_event      varchar2(3) := 'DR';
l_credit_event      varchar2(3) := 'CR';
l_dr_cc_id_tbl         CC_ID_TBL;
l_cr_cc_id_tbl         CC_ID_TBL;
l_dr_account_type_code  varchar2(30);
l_cr_account_type_code  varchar2(30);

l_amount       number;
l_acctd_amount number;
l_currency_code varchar2(15);
l_code_combination_id number;

CURSOR get_product_line_csr(p_claim_id in number) IS
select lu.claim_line_util_id
from   ozf_claim_lines_all ln
,      ozf_claim_lines_util_all lu
,      ozf_funds_utilized_all_b fu
,      ozf_offers o
,      ams_custom_setup_attr c
where  ln.claim_line_id = lu.claim_line_id
and    fu.utilization_id = lu.utilization_id
and    ln.item_type = 'PRODUCT'
and    ln.item_id is not null
and    fu.product_level_type = 'FAMILY'
and    fu.plan_type = 'OFFR'
and    fu.plan_id = o.qp_list_header_id
and    o.custom_setup_id = c.custom_setup_id
and    c.object_attribute = 'RVGL'
and    c.attr_available_flag = 'Y'
and    ln.claim_id = p_claim_id;

l_utilization_id     number;
l_claim_line_util_id number;
l_prod_dr_cc_id_tbl_1 CC_ID_TBL := CC_ID_TBL();
l_prod_cr_cc_id_tbl_1 CC_ID_TBL := CC_ID_TBL();
l_prod_dr_cc_id_tbl_2 CC_ID_TBL := CC_ID_TBL();
l_prod_cr_cc_id_tbl_2 CC_ID_TBL := CC_ID_TBL();

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
   OZF_UTILITY_PVT.debug_message('Get_Line_Amount procedure');
   END IF;

   G_CLAIM_ID := p_gl_rec.source_id;

   l_dr_account_type_code := get_account_type_code(
                              p_event_type_code => p_gl_rec.event_type_code,
                              p_event_type      => l_debit_event,
                              p_adjustment_type => p_gl_rec.adjustment_type,
                              x_return_status   => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   l_cr_account_type_code := get_account_type_code(
                              p_event_type_code => p_gl_rec.event_type_code,
                              p_event_type      => l_credit_event,
                              p_adjustment_type => p_gl_rec.adjustment_type,
                              x_return_status   => x_return_status);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
   OZF_UTILITY_PVT.debug_message('Getting GL Account for debiting');
   END IF;
   -- get accounts from account generator for debiting
   Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id       => p_gl_rec.source_id,
                  p_source_table    => p_gl_rec.source_table,
                  p_account_type    => l_dr_account_type_code,
                  x_cc_id_tbl       => l_dr_cc_id_tbl);
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
   OZF_UTILITY_PVT.debug_message('Getting GL Account for crediting');
   END IF;
   -- get accounts from account generator for crediting
   Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id      => p_gl_rec.source_id,
                  p_source_table    => p_gl_rec.source_table,
                  p_account_type    => l_cr_account_type_code,
                  x_cc_id_tbl       => l_cr_cc_id_tbl);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Unexp Error in getting CR account');
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- R12 changes start
   -- If skip_acc_gen flag is true and debit and credit cc_ids are passed,
   --   update the cc_id with the passed values
   IF p_gl_rec.skip_account_gen_flag = 'T'
      AND p_gl_rec.dr_code_combination_id IS NOT NULL
      AND p_gl_rec.cr_code_combination_id IS NOT NULL
   THEN
      FOR i in 1..l_dr_cc_id_tbl.count LOOP
        l_dr_cc_id_tbl(i).code_combination_id := p_gl_rec.dr_code_combination_id;
        l_cr_cc_id_tbl(i).code_combination_id := p_gl_rec.cr_code_combination_id;
      END LOOP;
   END IF;
   -- R12 changes end

   -- post to product on claim settlement if utilization is for product family
   -- R12.1 Enhancement: Checking for Accounting only
   IF upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN
      IF p_gl_rec.event_type_code = 'SETTLE_BY_CHECK' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_AP_INVOICE' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_AP_DEBIT' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_ACCOUNTING_ONLY' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_CREDIT' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_DEBIT' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_OTHER'
      THEN
         OPEN get_product_line_csr(p_gl_rec.source_id);
         LOOP
            FETCH get_product_line_csr INTO l_claim_line_util_id;
            EXIT WHEN get_product_line_csr%notfound;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_UTILITY_PVT.debug_message('Getting GL Account for reverse debiting');
            END IF;
            -- get accounts from account generator for debiting
            Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id       => l_claim_line_util_id,
                  p_source_table    => 'OZF_CLAIM_LINES_UTIL_ALL',
                  p_account_type    => 'ACCRUAL_LIABILITY',
                  p_event_type      => l_debit_event,
                  x_cc_id_tbl       => l_prod_dr_cc_id_tbl_1);
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_UTILITY_PVT.debug_message('Getting GL Account for reverse crediting');
            END IF;
            -- get accounts from account generator for crediting
            Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id       => l_claim_line_util_id,
                  p_source_table    => 'OZF_CLAIM_LINES_UTIL_ALL',
                  p_account_type    => 'EXPENSE ACCOUNT',
                  p_event_type      => l_credit_event,
                  x_cc_id_tbl       => l_prod_cr_cc_id_tbl_1);
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_UTILITY_PVT.debug_message('Getting GL Account for product debiting');
            END IF;
            -- get accounts from account generator for debiting
            Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id       => l_claim_line_util_id,
                  p_source_table    => 'OZF_CLAIM_LINES_UTIL_ALL',
                  p_account_type    => 'EXPENSE ACCOUNT',
                  p_event_type      => l_debit_event,
                  x_cc_id_tbl       => l_prod_dr_cc_id_tbl_2);
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_UTILITY_PVT.debug_message('Getting GL Account for product crediting');
            END IF;
            -- get accounts from account generator for crediting
            Get_GL_Account(
                  p_api_version     => 1.0,
                  p_init_msg_list   => FND_API.G_FALSE,
                  p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
                  x_msg_data        => l_msg_data,
                  x_msg_count       => l_msg_count,
                  x_return_status   => x_return_status,
                  p_source_id       => l_claim_line_util_id,
                  p_source_table    => 'OZF_CLAIM_LINES_UTIL_ALL',
                  p_account_type    => 'ACCRUAL_LIABILITY',
                  p_event_type      => l_credit_event,
                  x_cc_id_tbl       => l_prod_cr_cc_id_tbl_2);
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END LOOP;
         CLOSE get_product_line_csr;
      END IF;
   END IF;

   x_amount_tbl := amount_tbl_type();
   -- for accruals and accrual adjustments
   IF upper(p_gl_rec.source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
      IF p_gl_rec.event_type_code = 'ACCRUAL' OR
         p_gl_rec.event_type_code = 'ACCRUAL_ADJUSTMENT' OR
         p_gl_rec.event_type_code = 'OFF_INVOICE' THEN
         IF p_gl_rec.adjustment_type = 'P' THEN
            -- debit line -- expense account
            FOR i in 1..l_dr_cc_id_tbl.count  LOOP
               x_amount_tbl.extend;
               x_amount_tbl(i).entered_dr := l_dr_cc_id_tbl(i).amount;
               x_amount_tbl(i).accounted_dr := l_dr_cc_id_tbl(i).acctd_amount;
               x_amount_tbl(i).curr_code_tc := l_dr_cc_id_tbl(i).currency_code;
               x_amount_tbl(i).code_combination_id := l_dr_cc_id_tbl(i).code_combination_id;
               x_amount_tbl(i).line_type_code := l_dr_account_type_code;
            END LOOP;
            l_cl_tot := l_dr_cc_id_tbl.count;
            -- credit line -- accrual liability
            FOR i in 1..l_cr_cc_id_tbl.count  LOOP
               x_amount_tbl.extend;
               x_amount_tbl(l_cl_tot + i).entered_cr := l_cr_cc_id_tbl(i).amount;
               x_amount_tbl(l_cl_tot + i).accounted_cr := l_cr_cc_id_tbl(i).acctd_amount;
               x_amount_tbl(l_cl_tot + i).curr_code_tc := l_cr_cc_id_tbl(i).currency_code;
               x_amount_tbl(l_cl_tot + i).code_combination_id := l_cr_cc_id_tbl(i).code_combination_id;
               x_amount_tbl(l_cl_tot + i).line_type_code := l_cr_account_type_code;
            END LOOP;
         ELSIF p_gl_rec.adjustment_type = 'N' THEN
            FOR i in 1..l_dr_cc_id_tbl.count  LOOP
               -- debit line -- accrual liabilty
               x_amount_tbl.extend;
               x_amount_tbl(i).entered_dr := (l_dr_cc_id_tbl(i).amount)*-1;
               x_amount_tbl(i).accounted_dr := (l_dr_cc_id_tbl(i).acctd_amount)*-1;
               x_amount_tbl(i).curr_code_tc := l_dr_cc_id_tbl(i).currency_code;
               x_amount_tbl(i).code_combination_id := l_dr_cc_id_tbl(i).code_combination_id;
               x_amount_tbl(i).line_type_code := l_dr_account_type_code;
            END LOOP;
            l_cl_tot := l_dr_cc_id_tbl.count;
            -- credit line -- expense account
            FOR i in 1..l_cr_cc_id_tbl.count  LOOP
               x_amount_tbl.extend;
               x_amount_tbl(l_cl_tot + i).entered_cr := (l_cr_cc_id_tbl(i).amount)*-1;
               x_amount_tbl(l_cl_tot + i).accounted_cr := (l_cr_cc_id_tbl(i).acctd_amount)*-1;
               x_amount_tbl(l_cl_tot + i).curr_code_tc := l_cr_cc_id_tbl(i).currency_code;
               x_amount_tbl(l_cl_tot + i).code_combination_id := l_cr_cc_id_tbl(i).code_combination_id;
               x_amount_tbl(l_cl_tot + i).line_type_code := l_cr_account_type_code;
            END LOOP;
         END IF;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_SOURCE_EVENT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   -- for settlement by check and credit memos
   ELSIF upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN
      --R12.1 Enhancement : checking for Accounting only
      IF p_gl_rec.event_type_code = 'SETTLE_BY_CHECK'  OR
         p_gl_rec.event_type_code = 'SETTLE_BY_AP_INVOICE' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_AP_DEBIT' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_ACCOUNTING_ONLY' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_CREDIT' OR
         p_gl_rec.event_type_code = 'CONTRA_CHARGE' OR
         p_gl_rec.event_type_code = 'SETTLE_BY_OTHER'
      THEN
         -- debit line -- accrual liability
         FOR i in 1..l_dr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(i).entered_dr := l_dr_cc_id_tbl(i).amount;
            x_amount_tbl(i).accounted_dr := l_dr_cc_id_tbl(i).acctd_amount;
            x_amount_tbl(i).curr_code_tc := l_dr_cc_id_tbl(i).currency_code;
            x_amount_tbl(i).code_combination_id := l_dr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(i).line_type_code := l_dr_account_type_code;
            x_amount_tbl(i).utilization_id := l_dr_cc_id_tbl(i).utilization_id;
            x_amount_tbl(i).line_util_id := l_dr_cc_id_tbl(i).line_util_id;
         END LOOP;
         l_cl_tot := l_dr_cc_id_tbl.count;
         -- credit line -- receivable clearing / vendor clearing
         FOR i in 1..l_cr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_cr := l_cr_cc_id_tbl(i).amount;
            x_amount_tbl(l_cl_tot+i).accounted_cr := l_cr_cc_id_tbl(i).acctd_amount;
            x_amount_tbl(l_cl_tot + i).curr_code_tc := l_cr_cc_id_tbl(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_cr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := l_cr_account_type_code;
            --//Bugfix: 7633112
            x_amount_tbl(l_cl_tot+i).utilization_id := l_cr_cc_id_tbl(i).utilization_id;
            x_amount_tbl(l_cl_tot+i).line_util_id := l_cr_cc_id_tbl(i).line_util_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_dr_cc_id_tbl_1.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_dr := l_prod_dr_cc_id_tbl_1(i).amount;
            x_amount_tbl(l_cl_tot+i).accounted_dr := l_prod_dr_cc_id_tbl_1(i).acctd_amount;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_dr_cc_id_tbl_1(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_dr_cc_id_tbl_1(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'ACCRUAL_LIABILITY';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_dr_cc_id_tbl_1(i).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_cr_cc_id_tbl_1.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_cr := l_prod_cr_cc_id_tbl_1(i).amount;
            x_amount_tbl(l_cl_tot+i).accounted_cr := l_prod_cr_cc_id_tbl_1(i).acctd_amount;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_cr_cc_id_tbl_1(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_cr_cc_id_tbl_1(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'EXPENSE ACCOUNT';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_cr_cc_id_tbl_1(i).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_dr_cc_id_tbl_2.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_dr := l_prod_dr_cc_id_tbl_2(i).amount;
            x_amount_tbl(l_cl_tot+i).accounted_dr := l_prod_dr_cc_id_tbl_2(i).acctd_amount;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_dr_cc_id_tbl_2(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_dr_cc_id_tbl_2(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'EXPENSE ACCOUNT';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_dr_cc_id_tbl_2(i).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_cr_cc_id_tbl_2.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_cr := l_prod_cr_cc_id_tbl_2(i).amount;
            x_amount_tbl(l_cl_tot+i).accounted_cr := l_prod_cr_cc_id_tbl_2(i).acctd_amount;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_cr_cc_id_tbl_2(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_cr_cc_id_tbl_2(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'ACCRUAL_LIABILITY';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_cr_cc_id_tbl_2(i).utilization_id;
         END LOOP;
      ELSIF p_gl_rec.event_type_code = 'SETTLE_BY_WO' THEN
         -- debit line -- accrual liability
         FOR i in 1..l_dr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(i).entered_dr := l_dr_cc_id_tbl(i).amount;
            x_amount_tbl(i).accounted_dr := l_dr_cc_id_tbl(i).acctd_amount;
            x_amount_tbl(i).curr_code_tc := l_dr_cc_id_tbl(i).currency_code;
            x_amount_tbl(i).code_combination_id := l_dr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(i).line_type_code := l_dr_account_type_code;
         END LOOP;
         l_cl_tot := l_dr_cc_id_tbl.count;
         -- credit line - receivable clearing
         FOR i in 1..l_cr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot + i).entered_cr := l_cr_cc_id_tbl(i).amount;
            x_amount_tbl(l_cl_tot + i).accounted_cr := l_cr_cc_id_tbl(i).acctd_amount;
            x_amount_tbl(l_cl_tot + i).curr_code_tc := l_cr_cc_id_tbl(i).currency_code;
            x_amount_tbl(l_cl_tot + i).code_combination_id := l_cr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(l_cl_tot + i).line_type_code := l_cr_account_type_code;
         END LOOP;
         /*
         -- debit line -- deduction adjustment
         FOR i in 1..l_claim_acc_tbl.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+1+i).entered_dr := l_claim_acc_tbl(i).amount;
            x_amount_tbl(l_cl_tot+1+i).accounted_dr := l_claim_acc_tbl(i).acctd_amount;
            x_amount_tbl(l_cl_tot+1+i).code_combination_id:=l_claim_acc_tbl(i).ded_adjustment_account;
            x_amount_tbl(l_cl_tot+1+i).line_type_code := l_dr_account_type_code;
         END LOOP;
         -- credit line -- receivable deduction
         x_amount_tbl.extend;
         x_amount_tbl((l_cl_tot*2)+2).entered_cr := l_claim_amt.amount_settled;
         x_amount_tbl((l_cl_tot*2)+2).accounted_cr := l_claim_amt.acctd_amount;
         x_amount_tbl((l_cl_tot*2)+2).code_combination_id := l_rec_deduction;
         x_amount_tbl((l_cl_tot*2)+2).line_type_code := l_cr_account_type_code;

      ELSIF p_gl_rec.event_type_code = 'SETTLE_BY_DEBIT' THEN
         -- debit line -- receivable clearing
         FOR i in 1..l_dr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(i).entered_dr := (l_dr_cc_id_tbl(i).amount)*-1;
            x_amount_tbl(i).accounted_dr := (l_dr_cc_id_tbl(i).acctd_amount)*-1;
            x_amount_tbl(i).curr_code_tc := l_dr_cc_id_tbl(i).currency_code;
            x_amount_tbl(i).code_combination_id := l_dr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(i).line_type_code := l_dr_account_type_code;
         END LOOP;
         l_cl_tot := l_dr_cc_id_tbl.count;
         -- credit line -- receivable deduction
         FOR i in 1..l_cr_cc_id_tbl.count  LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot + i).entered_cr := (l_cr_cc_id_tbl(i).amount)*-1;
            x_amount_tbl(l_cl_tot + i).accounted_cr := (l_cr_cc_id_tbl(i).acctd_amount)*-1;
            x_amount_tbl(l_cl_tot + i).curr_code_tc := l_cr_cc_id_tbl(i).currency_code;
            x_amount_tbl(l_cl_tot + i).code_combination_id := l_cr_cc_id_tbl(i).code_combination_id;
            x_amount_tbl(l_cl_tot + i).line_type_code := l_cr_account_type_code;
            x_amount_tbl(l_cl_tot + i).utilization_id := l_cr_cc_id_tbl(i).utilization_id;
            x_amount_tbl(l_cl_tot + i).line_util_id := l_cr_cc_id_tbl(i).line_util_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_dr_cc_id_tbl_1.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_dr := l_prod_dr_cc_id_tbl_1(i).amount*-1;
            x_amount_tbl(l_cl_tot+i).accounted_dr := l_prod_dr_cc_id_tbl_1(i).acctd_amount*-1;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_dr_cc_id_tbl_1(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_dr_cc_id_tbl_1(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'ACCRUAL_LIABILITY';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_dr_cc_id_tbl_1(1).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_cr_cc_id_tbl_1.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_cr := l_prod_cr_cc_id_tbl_1(i).amount*-1;
            x_amount_tbl(l_cl_tot+i).accounted_cr := l_prod_cr_cc_id_tbl_1(i).acctd_amount*-1;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_cr_cc_id_tbl_1(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_cr_cc_id_tbl_1(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'EXPENSE ACCOUNT';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_cr_cc_id_tbl_1(1).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_dr_cc_id_tbl_2.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_dr := l_prod_dr_cc_id_tbl_2(i).amount*-1;
            x_amount_tbl(l_cl_tot+i).accounted_dr := l_prod_dr_cc_id_tbl_2(i).acctd_amount*-1;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_dr_cc_id_tbl_2(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_dr_cc_id_tbl_2(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'EXPENSE ACCOUNT';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_dr_cc_id_tbl_2(1).utilization_id;
         END LOOP;
         l_cl_tot := x_amount_tbl.count;
         FOR i in 1..l_prod_cr_cc_id_tbl_2.count LOOP
            x_amount_tbl.extend;
            x_amount_tbl(l_cl_tot+i).entered_cr := l_prod_cr_cc_id_tbl_2(i).amount*-1;
            x_amount_tbl(l_cl_tot+i).accounted_cr := l_prod_cr_cc_id_tbl_2(i).acctd_amount*-1;
            x_amount_tbl(l_cl_tot+i).curr_code_tc := l_prod_cr_cc_id_tbl_2(i).currency_code;
            x_amount_tbl(l_cl_tot+i).code_combination_id := l_prod_cr_cc_id_tbl_2(i).code_combination_id;
            x_amount_tbl(l_cl_tot+i).line_type_code := 'ACCRUAL_LIABILITY';
            x_amount_tbl(l_cl_tot+i).utilization_id := l_prod_cr_cc_id_tbl_2(1).utilization_id;
         END LOOP;
      ELSE
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_SOURCE_EVENT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   -- if source table is different
   ELSE
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_INVALID_SOURCE_TABLE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_LINE_AMOUNT_CALC_ERROR');
            FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_unexp_error;
END;
*/
---------------------------------------------------------------------

-- Start of fix for bug 4582919
/*FUNCTION get_gl_period (
  p_sob_id     IN NUMBER
, p_acc_date   IN DATE
, p_dflt_period IN VARCHAR2
)
RETURN VARCHAR2
IS

l_gl_period VARCHAR2(30); -- size of 15 is enough

CURSOR gl_period_csr (p_sob_id IN NUMBER, p_acc_date IN DATE) IS
SELECT G.period_name
FROM gl_period_statuses G
WHERE G.application_id = 101
AND G.closing_status in ('O', 'F')
AND NVL(G.adjustment_period_flag, 'N') = 'N'
AND G.set_of_books_id = p_sob_id
AND trunc(p_acc_date) between G.start_date and G.end_date;

BEGIN

   OPEN gl_period_csr (p_sob_id, p_acc_date);
          FETCH gl_period_csr INTO l_gl_period;
   CLOSE gl_period_csr;

   IF l_gl_period IS NULL THEN
      l_gl_period := p_dflt_period;
   END IF;

   RETURN l_gl_period;

EXCEPTION
  WHEN OTHERS THEN
     RETURN p_dflt_period;
END;
*/
---------------------------------------------------------------------
-- End of fix for bug 4582919

/*FUNCTION get_gl_date (
  p_source_id in number
, p_source_table in varchar2
)
RETURN DATE
IS

l_gl_date date := SYSDATE;
l_claim_date date;
l_org_id number;
l_gl_date_type varchar2(30);

CURSOR claim_gl_date_csr (p_id in number) IS
select gl_date
,      claim_date
,      org_id
from   ozf_claims_all
where  claim_id = p_id;

CURSOR util_gl_date_csr (p_id in number) IS
select gl_date
from   ozf_funds_utilized_all_b
where  utilization_id = p_id;

CURSOR csr_get_gl_date_type(p_id IN NUMBER) IS
SELECT gl_date_type
FROM ozf_sys_parameters_all
WHERE org_id = NVL(p_id, -99);

BEGIN

  IF p_source_table = 'OZF_FUNDS_UTILIZED_ALL_B' THEN

        OPEN util_gl_date_csr (p_source_id);
           FETCH util_gl_date_csr INTO l_gl_date;
        CLOSE util_gl_date_csr;

        IF l_gl_date IS NULL THEN
        l_gl_date := SYSDATE;
        END IF;

  ELSIF p_source_table = 'OZF_CLAIMS_ALL' THEN

        OPEN claim_gl_date_csr (p_source_id);
           FETCH claim_gl_date_csr INTO l_gl_date, l_claim_date, l_org_id;
        CLOSE claim_gl_date_csr;

        IF l_gl_date IS NULL THEN

        OPEN csr_get_gl_date_type(l_org_id);
           FETCH csr_get_gl_date_type INTO l_gl_date_type;
        CLOSE csr_get_gl_date_type;

        IF l_gl_date_type = 'CLAIM_DATE' THEN
           l_gl_date := l_claim_date;
        END IF;

        IF l_gl_date_type = 'SYSTEM_DATE' THEN
           l_gl_date := SYSDATE;
        END IF;

        END IF;
  END IF;

  RETURN trunc(l_gl_date);

EXCEPTION
  WHEN OTHERS THEN
     l_gl_date := SYSDATE;
     RETURN trunc(l_gl_date);
END;
*/
---------------------------------------------------------------------
/*
Moved this function to top of package for forward declaration purpose
Bugfix 7431334
FUNCTION get_org_id (
  p_source_id in number
, p_source_table in varchar2
)
RETURN NUMBER
IS
l_org_id number;

CURSOR claim_org_id_csr (p_id in number) IS
select org_id
from   ozf_claims_all
where  claim_id = p_id;

CURSOR util_org_id_csr (p_id in number) IS
select org_id
from   ozf_funds_utilized_all_b
where  utilization_id = p_id;

BEGIN

  IF p_source_table = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
    OPEN util_org_id_csr (p_source_id);
    FETCH util_org_id_csr INTO l_org_id;
    CLOSE util_org_id_csr;
  ELSIF p_source_table = 'OZF_CLAIMS_ALL' THEN
    OPEN claim_org_id_csr (p_source_id);
    FETCH claim_org_id_csr INTO l_org_id;
    CLOSE claim_org_id_csr;
  END IF;

  RETURN l_org_id;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END;
*/
---------------------------------------------------------------------
/*PROCEDURE  Construct_Acctng_Event_Rec(
    p_gl_rec               IN  gl_interface_rec_type
   ,x_return_status        OUT NOCOPY VARCHAR2
   ,x_accounting_event_rec OUT NOCOPY OZF_acctng_events_PVT.acctng_event_rec_type
) IS
l_created       varchar2(30) := 'CREATED';
l_event_number  number;
l_gl_date       date;
l_org_id        number;
BEGIN

    -- accounting header rec
    l_event_number := get_event_number(
                           p_event_type_code => p_gl_rec.event_type_code,
                           p_adjustment_type => p_gl_rec.adjustment_type,
                           x_return_status   => x_return_status);

    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_gl_date := get_gl_date(p_source_id => p_gl_rec.source_id,
                                            p_source_table => upper(p_gl_rec.source_table));
    l_org_id  := get_org_id(p_source_id => p_gl_rec.source_id,
                            p_source_table => upper(p_gl_rec.source_table));

    x_accounting_event_rec.accounting_date := l_gl_date;
    x_accounting_event_rec.event_number := l_event_number;
    x_accounting_event_rec.event_status_code := nvl(p_gl_rec.event_status_code, l_created);
    x_accounting_event_rec.event_type_code := p_gl_rec.event_type_code;
    x_accounting_event_rec.source_id := p_gl_rec.source_id;
    x_accounting_event_rec.source_table := upper(p_gl_rec.source_table);
    x_accounting_event_rec.org_id := l_org_id;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_ACCTNG_EVENT_ERROR');
            FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_unexp_error;
END Construct_Acctng_Event_Rec;
*/
---------------------------------------------------------------------
/*PROCEDURE  Construct_Header_Rec(
    p_gl_rec               IN  gl_interface_rec_type
   ,x_return_status        OUT NOCOPY VARCHAR2
   ,x_ae_header_rec        OUT NOCOPY OZF_ae_header_PVT.ae_header_rec_type
) IS
l_ae_category   varchar2(80);
l_event_desc    varchar2(160);
l_event_type    varchar2(80);
l_event_status  varchar2(80);
l_period_name   varchar2(80);   -- get from profile
l_gl_period     varchar2(30); -- Fix for bug 4582919
l_sob           number; --get from profile
l_org_id        number;
l_gl_date       date;

CURSOR  meaning_csr(p_type in varchar2) IS
select  meaning
from    fnd_lookup_types_tl
where   lookup_type = p_type;

BEGIN
    -- get AE Category, SOB and Period
    get_ae_category (p_source_table   => p_gl_rec.source_table,
                     p_source_id      => p_gl_rec.source_id,
                     x_ae_category    => l_ae_category,
                     x_sob_id         => l_sob,
                     x_period_name    => l_period_name,
                     x_return_status  => x_return_status);

    IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message('AE Category'||l_ae_category);
    END IF;
    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    --- get event status meaning
    open meaning_csr(p_gl_rec.event_status_code);
       fetch meaning_csr into l_event_status;
    close meaning_csr;

    -- get event type meaning
    open meaning_csr(p_gl_rec.event_type_code);
       fetch meaning_csr into l_event_type;
    close meaning_csr;

    -- event description
    l_event_desc := l_event_type || ' '|| l_event_status;

    -- org id
    l_org_id := get_org_id(p_source_id => p_gl_rec.source_id,
                           p_source_table => upper(p_gl_rec.source_table));

    l_gl_date := get_gl_date(p_source_id => p_gl_rec.source_id,
                             p_source_table => upper(p_gl_rec.source_table));

    -- Start of fix for bug 4582919
    l_gl_period := get_gl_period(p_sob_id => l_sob,
                             p_acc_date => l_gl_date,
                             p_dflt_period => l_period_name );
    -- End of fix for bug 4582919

    x_ae_header_rec.accounting_date := l_gl_date; --sysdate; changed by feliu on 12/30/2003
    x_ae_header_rec.ae_category := l_ae_category;
    x_ae_header_rec.cross_currency_flag := 'N';
    x_ae_header_rec.description := l_event_desc;
    x_ae_header_rec.gl_reversal_flag := 'N';
    x_ae_header_rec.period_name := l_gl_period; -- Fix for bug 4582919
    x_ae_header_rec.set_of_books_id := l_sob;
    x_ae_header_rec.gl_transfer_flag := 'N';
    x_ae_header_rec.gl_transfer_run_id := -1;
    x_ae_header_rec.org_id := l_org_id;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_AE_HEADER_ERROR');
            FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_unexp_error;
END Construct_Header_Rec;
*/
---------------------------------------------------------------------
/*
PROCEDURE  Construct_Line_Rec(
    p_gl_rec               IN  gl_interface_rec_type
   ,x_return_status        OUT NOCOPY VARCHAR2
   ,x_ae_line_tbl          OUT NOCOPY OZF_ae_line_PVT.ae_line_tbl_type
) IS
l_num_dr_lines number := 1;
l_num_cr_lines number := 1;
l_num_lines number := 1;
l_amount_tbl   amount_tbl_type;
l_org_id number;

CURSOR get_fxgl_gain_ccid_csr( p_org_id in number ) is
select code_combination_id_gain
from   ar_system_parameters_all
where org_id = p_org_id;

CURSOR get_fxgl_loss_ccid_csr( p_org_id in number ) is
select code_combination_id_loss
from   ar_system_parameters_all
where org_id = p_org_id;

CURSOR get_fxgl_amt_csr( p_claim_id in number) IS
SELECT SUM(u.amount)
,      SUM(u.fxgl_acctd_amount)
,      c.currency_code
FROM   ozf_claim_lines_util_all u
,      ozf_claim_lines_all l
,      ozf_claims_all c
WHERE  l.claim_id = c.claim_id
AND    l.earnings_associated_flag = 'T'
AND    l.claim_line_id = u.claim_line_id
AND    c.claim_id = p_claim_id
GROUP BY c.currency_code;

l_fxgl_gain_ccid      number;
l_fxgl_loss_ccid      number;

l_amount       number;
l_acctd_amount number;
l_currency_code varchar2(15);
l_line_type_code varchar2(30);

l_ae_line_tbl  OZF_ae_line_PVT.ae_line_tbl_type;
l_rec_num  number;

BEGIN
    -- get line amounts for credit and debit lines
    get_line_amount(
            p_gl_rec         => p_gl_rec,
            x_amount_tbl     => l_amount_tbl,
            x_return_status  => x_return_status );

    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- org id
    l_org_id := get_org_id(p_source_id => p_gl_rec.source_id,
                           p_source_table => upper(p_gl_rec.source_table));

    OPEN get_fxgl_gain_ccid_csr( l_org_id );
       FETCH get_fxgl_gain_ccid_csr INTO l_fxgl_gain_ccid;
    CLOSE get_fxgl_gain_ccid_csr;

    OPEN get_fxgl_loss_ccid_csr( l_org_id );
       FETCH get_fxgl_loss_ccid_csr INTO l_fxgl_loss_ccid;
    CLOSE get_fxgl_loss_ccid_csr;

    IF l_fxgl_gain_ccid is null THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_NO_FXGL_ACCOUNT_SETUP');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      return;
    END IF;

    IF l_fxgl_loss_ccid is null THEN
       l_fxgl_loss_ccid := l_fxgl_gain_ccid;
    END IF;

    -- ae lines
    x_ae_line_tbl := OZF_ae_line_PVT.ae_line_tbl_type();
    l_num_lines := l_amount_tbl.count;
    IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message('Number of Lines: ' || l_num_lines);
    END IF;
    FOR i in 1..l_num_lines LOOP
       x_ae_line_tbl.extend;
       x_ae_line_tbl(i) := null;
       --OZF_UTILITY_PVT.debug_message('Line Number before entering: ' || x_ae_line_tbl(i).ae_line_number);
       --if x_ae_line_tbl(i).ae_line_type_code = FND_API.G_MISS_CHAR then
       --OZF_UTILITY_PVT.debug_message('Line Type Code before entering - miss char: ' || x_ae_line_tbl(i).ae_line_type_code);
       --else
       --OZF_UTILITY_PVT.debug_message('Line Type Code before entering: ' || x_ae_line_tbl(i).ae_line_type_code);
       --end if;
       --OZF_UTILITY_PVT.debug_message('Line Type Code assigned value: ' || x_amount_tbl(i).line_type_code);
       --OZF_UTILITY_PVT.debug_message('Processing Line: ' || i);

       -- Fix for Bug 7430768
       -- Fix for Bug 8274064, This will only valid for -ve adjustment for claims
       -- Fix for Bug 8666602
       IF (upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' AND p_gl_rec.adjustment_type = 'N'
           AND p_gl_rec.event_type_code <> 'SETTLE_BY_DEBIT') THEN
               x_ae_line_tbl(i).entered_dr := (l_amount_tbl(i).entered_dr)*-1;
               x_ae_line_tbl(i).entered_cr := (l_amount_tbl(i).entered_cr)*-1;
               x_ae_line_tbl(i).accounted_dr := (l_amount_tbl(i).accounted_dr)*-1;
               x_ae_line_tbl(i).accounted_cr := (l_amount_tbl(i).accounted_cr)*-1;
       ELSE
               x_ae_line_tbl(i).entered_dr := l_amount_tbl(i).entered_dr;
               x_ae_line_tbl(i).entered_cr := l_amount_tbl(i).entered_cr;
               x_ae_line_tbl(i).accounted_dr := l_amount_tbl(i).accounted_dr;
               x_ae_line_tbl(i).accounted_cr := l_amount_tbl(i).accounted_cr;
       END IF;
       x_ae_line_tbl(i).ae_line_number := i;
       x_ae_line_tbl(i).ae_line_type_code := l_amount_tbl(i).line_type_code;
       x_ae_line_tbl(i).code_combination_id := l_amount_tbl(i).code_combination_id;
       x_ae_line_tbl(i).source_id := p_gl_rec.source_id;
       x_ae_line_tbl(i).source_table := upper(p_gl_rec.source_table);

       x_ae_line_tbl(i).currency_code := l_amount_tbl(i).curr_code_tc;
       x_ae_line_tbl(i).org_id := l_org_id;
       --x_ae_line_tbl(i).currency_conversion_type := l_amount_tbl(i).currency_conversion_type;
       --x_ae_line_tbl(i).currency_conversion_rate := l_amount_tbl(i).currency_conversion_rate;
       --x_ae_line_tbl(i).currency_conversion_date := l_amount_tbl(i).currency_conversion_date;

       -- use REFERENCE2 for utilization_id, and REFERENCE3 for claim_line_util_id
       x_ae_line_tbl(i).reference2 := l_amount_tbl(i).utilization_id;
       x_ae_line_tbl(i).reference3 := l_amount_tbl(i).line_util_id;

       x_ae_line_tbl(i).description := get_account_description(
               p_gl_rec            => p_gl_rec,
               p_account_type_code => l_amount_tbl(i).line_type_code,
               x_return_status     => x_return_status );

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       --OZF_UTILITY_PVT.debug_message('Line Number after entering: ' || x_ae_line_tbl(i).ae_line_number);
       --if x_ae_line_tbl(i).ae_line_type_code = FND_API.G_MISS_CHAR then
       --OZF_UTILITY_PVT.debug_message('Line Type Code after entering - miss char: ' || x_ae_line_tbl(i).ae_line_type_code);
       --else
       --OZF_UTILITY_PVT.debug_message('Line Type Code after entering: ' || x_ae_line_tbl(i).ae_line_type_code);
       --end if;
    END LOOP;
    --x_ae_line_tbl := l_ae_line_tbl;

   -- R12 FXGL Enhancement
   IF upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN
       G_CLAIM_ID := p_gl_rec.source_id;
      l_rec_num := x_ae_line_tbl.count;

      l_line_type_code := get_account_type_code(
                              p_event_type_code => p_gl_rec.event_type_code,
                              p_event_type      => 'CR',
                              p_adjustment_type => p_gl_rec.adjustment_type,
                              x_return_status   => x_return_status);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      OPEN get_fxgl_amt_csr(p_gl_rec.source_id);
         LOOP
            FETCH get_fxgl_amt_csr INTO l_amount, l_acctd_amount, l_currency_code;
            EXIT WHEN get_fxgl_amt_csr%notfound;

            l_rec_num := l_rec_num + 1;

            IF l_acctd_amount < 0 THEN
               x_ae_line_tbl.extend;
               x_ae_line_tbl( l_rec_num ) := null;
               x_ae_line_tbl( l_rec_num ).ae_line_number := l_rec_num;
               x_ae_line_tbl( l_rec_num ).ae_line_type_code := l_line_type_code;
               x_ae_line_tbl( l_rec_num ).code_combination_id := l_fxgl_gain_ccid;
               x_ae_line_tbl( l_rec_num ).source_id := p_gl_rec.source_id;
               x_ae_line_tbl( l_rec_num ).source_table := upper(p_gl_rec.source_table);
               x_ae_line_tbl( l_rec_num ).entered_dr := 0;
               x_ae_line_tbl( l_rec_num ).entered_cr := 0;
               x_ae_line_tbl( l_rec_num ).accounted_dr := 0;
               x_ae_line_tbl( l_rec_num ).accounted_cr := l_acctd_amount * -1;
               x_ae_line_tbl( l_rec_num ).currency_code := l_currency_code;
               x_ae_line_tbl( l_rec_num ).org_id := l_org_id;
               x_ae_line_tbl( l_rec_num ).description := get_account_description(
                      p_gl_rec            => p_gl_rec,
                      p_account_type_code => l_line_type_code,
                      x_return_status     => x_return_status );

              IF x_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
            ELSIF l_acctd_amount > 0 THEN
               x_ae_line_tbl.extend;
               x_ae_line_tbl( l_rec_num ) := null;
               x_ae_line_tbl( l_rec_num ).ae_line_number := l_rec_num;
               x_ae_line_tbl( l_rec_num ).ae_line_type_code := l_line_type_code;
               x_ae_line_tbl( l_rec_num ).code_combination_id := l_fxgl_loss_ccid;
               x_ae_line_tbl( l_rec_num ).source_id := p_gl_rec.source_id;
               x_ae_line_tbl( l_rec_num ).source_table := upper(p_gl_rec.source_table);
               x_ae_line_tbl( l_rec_num ).entered_dr := 0;
               x_ae_line_tbl( l_rec_num ).entered_cr := 0;
               x_ae_line_tbl( l_rec_num ).accounted_cr := 0;
               x_ae_line_tbl( l_rec_num ).accounted_dr := l_acctd_amount;
               x_ae_line_tbl( l_rec_num ).currency_code := l_currency_code;
               x_ae_line_tbl( l_rec_num ).org_id := l_org_id;
               x_ae_line_tbl( l_rec_num ).description := get_account_description(
                      p_gl_rec            => p_gl_rec,
                      p_account_type_code => l_line_type_code,
                      x_return_status     => x_return_status );

              IF x_return_status = FND_API.g_ret_sts_error THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
            END IF;
         END LOOP;
      CLOSE get_fxgl_amt_csr;
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('OZF', 'OZF_GL_AE_LINE_ERROR');
            FND_MSG_PUB.add;
       END IF;
       x_return_status := FND_API.g_ret_sts_unexp_error;
END Construct_Line_Rec;
*/
---------------------------------------------------------------------
/*PROCEDURE  Set_Accounting_Rules(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_msg_data    OUT NOCOPY VARCHAR2
   ,x_msg_count      OUT NOCOPY NUMBER
   ,x_return_status  OUT NOCOPY VARCHAR2

   ,p_gl_rec           IN  gl_interface_rec_type
   ,p_acctng_entries   IN varchar2
   ,x_accounting_event_rec  OUT NOCOPY OZF_acctng_events_PVT.acctng_event_rec_type
   ,x_ae_header_rec  OUT NOCOPY OZF_ae_header_PVT.ae_header_rec_type
   ,x_ae_line_tbl OUT NOCOPY OZF_ae_line_PVT.ae_line_tbl_type )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Set_Accounting_Rule';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- construct accounting event
    Construct_Acctng_Event_Rec(
       p_gl_rec                => p_gl_rec
      ,x_return_status         => x_return_status
      ,x_accounting_event_rec  => x_accounting_event_rec);

    IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF p_acctng_entries = 'T' THEN
       -- ae header rec
       Construct_Header_Rec(
          p_gl_rec         => p_gl_rec
         ,x_return_status  => x_return_status
         ,x_ae_header_rec  => x_ae_header_rec);

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       -- ae lines
       Construct_Line_Rec(
          p_gl_rec          => p_gl_rec
         ,x_return_status   => x_return_status
         ,x_ae_line_tbl     => x_ae_line_tbl);

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END IF;

    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
       FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
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
END set_accounting_rules;
*/

--//Start ChRM SLA Uptake
---------------------------------------------------------------------
-- PROCEDURE
--    Create_SLA_Accrual_Extract
--
-- PURPOSE
--    Tis procedure will create event for Accruals and populate SLA Extract
--    table for Accruals,Adjustments and Off-Invoice Offers
--
-- PARAMETERS
-- p_utilization_id  - Utilization id
-- p_event_type_code - Event type code
-- p_adj_cr_ccid     - Adjustment credit account ccid
-- p_adj_dr_cc_id    - Adjustment debit account ccid
--
-- NOTES
--
-- HISTORY
-- 12-Feb-10  BKUNJAN    ER#9382547    ChRM-SLA Uptake -Created
---------------------------------------------------------------------
PROCEDURE Create_SLA_Accrual_Extract (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_utilization_id      IN  NUMBER
   ,p_event_type_code     IN  VARCHAR2
   ,p_adj_cr_ccid         IN  NUMBER   := NULL
   ,p_adj_dr_cc_id        IN  NUMBER   := NULL
   )

IS
l_api_name              CONSTANT VARCHAR2(30) := 'Create_SLA_Accrual_Extract';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_event_source_info     xla_events_pub_pkg.t_event_source_info;
l_reference_info        xla_events_pub_pkg.t_event_reference_info;
l_security_context      xla_events_pub_pkg.t_security;
l_event_date            DATE;
l_xla_event_id          NUMBER := 0;
l_event_type_code       VARCHAR2(30);
l_org_id                NUMBER;
l_gl_date               DATE;

CURSOR c_hr_operating_unit (p_org_id IN NUMBER)IS
   SELECT TO_NUMBER(hou.default_legal_context_id) legal_entity,
          TO_NUMBER(hou.set_of_books_id) ledger_id
    FROM HR_OPERATING_UNITS HOU
    WHERE HOU.ORGANIZATION_ID = p_org_id;

CURSOR c_util_details IS
   SELECT org_id, gl_date
     FROM ozf_funds_utilized_all_b
    WHERE utilization_id = p_utilization_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Create_SLA_Accrual_Extract;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- Create_SLA_Accrual_Extract ----------');
      OZF_Utility_PVT.debug_message('utilization_id    : '||p_utilization_id);
      OZF_Utility_PVT.debug_message('event_type_code   : '||p_event_type_code);
    END IF;

   OPEN c_util_details;
   FETCH c_util_details INTO l_org_id, l_gl_date;
   CLOSE c_util_details;

   OPEN c_hr_operating_unit (l_org_id);
   FETCH c_hr_operating_unit INTO l_event_source_info.legal_entity_id,
                                  l_event_source_info.ledger_id;
   CLOSE c_hr_operating_unit;


   l_event_source_info.application_id       := 682;
   l_event_source_info.entity_type_code     := 'ACCRUAL';
   l_event_source_info.source_id_int_1      := p_utilization_id;
   l_security_context.security_id_int_1     := l_org_id;

   --Raise SLA event for the event type
   l_xla_event_id := XLA_EVENTS_PUB_PKG.create_event(
                           p_event_source_info  => l_event_source_info,
                           p_event_type_code    => p_event_type_code,
                           p_event_date         => l_gl_date,
                           p_event_status_code  => xla_events_pub_pkg.c_event_unprocessed,
                           p_event_number       => NULL,
                           p_reference_info     => l_reference_info,
                           p_valuation_method   => '',
                           p_transaction_date   => INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(TRUNC(l_gl_date),l_org_id),
                           p_security_context   => l_security_context);


   --Populate TM SLA Accrual extract table
   INSERT INTO OZF_XLA_ACCRUALS
                   (XLA_ACCRUAL_ID
                   ,EVENT_TYPE_CODE
                   ,ENTITY_CODE
                   ,EVENT_ID
                   ,UTILIZATION_ID
                   ,ADJUSTMENT_CR_ACCT_CCID
                   ,ADJUSTMENT_DR_ACCT_CCID
                   ,ORG_ID
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,LAST_UPDATE_LOGIN)

       VALUES (    OZF_XLA_ACCRUALS_S.NEXTVAL
                  ,p_event_type_code
                  ,l_event_source_info.entity_type_code
                  ,l_xla_event_id
                  ,p_utilization_id
                  ,p_adj_cr_ccid
                  ,p_adj_dr_cc_id
                  ,l_org_id
                  ,SYSDATE
                  ,NVL (fnd_global.user_id, -1)
                  ,SYSDATE
                  ,NVL (fnd_global.user_id, -1)
                  ,NVL (fnd_global.conc_login_id, -1)
             );


   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_SLA_Accrual_Extract;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_SLA_Accrual_Extract;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO Create_SLA_Accrual_Extract;
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

END Create_SLA_Accrual_Extract;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_SLA_Claim_Extract
--
-- PURPOSE
--    To trigger the SLA events and create Extract entries
--    for promotional claim settlement
-- PARAMETERS
--    p_claim_id  : claim_id for which the event is raised.
--    p_event_type_code : event_type_code for the claim.
--    p_reversal_flag : Reversal flag will be used for account
--                      reversal.
--
-- NOTES
--
-- HISTORY
-- 05/03/2010  kpatro    Created for ER#9382547 ChRM-SLA Uptake
---------------------------------------------------------------------
PROCEDURE Create_SLA_Claim_Extract (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_claim_id            IN  NUMBER
   ,p_event_type_code     IN  VARCHAR2
   )
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Create_SLA_Claim_Extract';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_event_source_info     xla_events_pub_pkg.t_event_source_info;
l_reference_info        xla_events_pub_pkg.t_event_reference_info;
l_security_context      xla_events_pub_pkg.t_security;
l_xla_event_id          NUMBER := 0;
l_event_type_code       VARCHAR2(30);
l_xla_claim_hed_seq NUMBER;

l_org_id NUMBER ;
l_gl_date  DATE;
l_claim_date DATE;
l_count_claim_utils NUMBER;
l_claim_line_util_id NUMBER;
l_gl_date_type varchar2(30);
l_counter NUMBER :=0;

l_reversal_flag VARCHAR2(1);



CURSOR c_hr_operating_unit (p_org_id IN NUMBER) IS
   SELECT TO_NUMBER(hou.default_legal_context_id) legal_entity,
          TO_NUMBER(hou.set_of_books_id) ledger_id
   FROM HR_OPERATING_UNITS HOU
   WHERE HOU.ORGANIZATION_ID = p_org_id;

CURSOR c_claim_info (p_claim_id IN NUMBER)IS
   SELECT cla.gl_date, cla.org_id, cla.claim_date, osp.gl_date_type
     FROM ozf_claims_all cla, ozf_sys_parameters_all osp
    WHERE claim_id = p_claim_id
      AND cla.org_id = osp.org_id;

CURSOR c_count_claim_utils(p_id IN NUMBER) IS
  SELECT count(*)
    FROM ozf_claim_lines_util_all
   WHERE claim_line_id IN (SELECT claim_line_id
                               FROM ozf_claim_lines_all
                              WHERE claim_id = p_id);

CURSOR c_get_claim_line_util(p_claim_id IN NUMBER) IS
  SELECT clu.claim_line_util_id
    FROM ozf_claim_lines_util_all clu,
         ozf_claim_lines_all cln
   WHERE clu.claim_line_id = cln.claim_line_id
     AND cln.claim_id = p_claim_id;


CURSOR c_xla_claims_header_seq IS
   SELECT OZF_XLA_CLAIM_HEADERS_S.NEXTVAL
   FROM DUAL;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Create_SLA_Claim_Extract;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_count_claim_utils (p_claim_id);
   FETCH c_count_claim_utils INTO l_count_claim_utils;
   CLOSE c_count_claim_utils;

   IF OZF_DEBUG_LOW_ON THEN
     OZF_Utility_PVT.debug_message('Number of Claim Line Utils: ' || l_count_claim_utils);
   END IF;

    -- If Association is there then raise the event
 IF(l_count_claim_utils > 0) THEN

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- Create_SLA_Claim_Extract ----------');
      OZF_Utility_PVT.debug_message('Claim_ID    : '||p_claim_id);
      OZF_Utility_PVT.debug_message('event_type_code   : '||p_event_type_code);

    END IF;

   OPEN c_claim_info(p_claim_id);
   FETCH c_claim_info INTO l_gl_date,l_org_id,l_claim_date,l_gl_date_type;
   CLOSE c_claim_info;

   OPEN c_hr_operating_unit(l_org_id);
   FETCH c_hr_operating_unit INTO l_event_source_info.legal_entity_id,
                                  l_event_source_info.ledger_id;
   CLOSE c_hr_operating_unit;


   IF OZF_DEBUG_LOW_ON THEN
    OZF_Utility_PVT.debug_message('l_gl_date : '||l_gl_date);
    OZF_Utility_PVT.debug_message('l_org_id  : '||l_org_id);
    OZF_Utility_PVT.debug_message('l_claim_date : '||l_claim_date);
   END IF;

   IF l_gl_date IS NULL THEN

        IF l_gl_date_type = 'CLAIM_DATE' THEN
           l_gl_date := l_claim_date;
        ELSE --l_gl_date_type = 'SYSTEM_DATE'
           l_gl_date := SYSDATE;
        END IF;

    END IF;

    l_gl_date := trunc(l_gl_date);


   l_event_source_info.application_id       := 682;
   l_event_source_info.entity_type_code     := 'CLAIM_SETTLEMENT';
   l_event_source_info.source_id_int_1      := p_claim_id;
   l_security_context.security_id_int_1     := l_org_id;

   l_xla_event_id := XLA_EVENTS_PUB_PKG.create_event(
                           p_event_source_info  => l_event_source_info,
                           p_event_type_code    => p_event_type_code,
                           p_event_date         => l_gl_date,
                           p_event_status_code  => xla_events_pub_pkg.c_event_unprocessed,
                           p_event_number       => NULL,
                           p_reference_info     => l_reference_info,
                           p_valuation_method   => '',
                           p_transaction_date   => INV_LE_TIMEZONE_PUB.get_le_day_time_for_ou(trunc(l_gl_date),l_org_id),
                           p_security_context   => l_security_context);


   IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('l_xla_event_id    : '||l_xla_event_id);
      OZF_Utility_PVT.debug_message('p_event_type_code    : '||p_event_type_code);
   END IF;

   IF (p_event_type_code IS NOT NULL AND p_event_type_code = 'CLAIM_SETTLEMENT_REVERSAL') THEN
        l_reversal_flag := 'Y';
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('l_reversal_flag    : '||l_reversal_flag);
   END IF;

   OPEN c_xla_claims_header_seq;
   FETCH c_xla_claims_header_seq INTO l_xla_claim_hed_seq;
   CLOSE c_xla_claims_header_seq;

   INSERT INTO OZF_XLA_CLAIM_HEADERS
                   (XLA_CLAIM_HEADER_ID
                   ,EVENT_TYPE_CODE
                   ,ENTITY_CODE
                   ,EVENT_ID
                   ,CLAIM_ID
                   ,ORG_ID
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,LAST_UPDATE_LOGIN
                   ,REVERSAL_FLAG)

       VALUES (l_xla_claim_hed_seq
                  ,p_event_type_code
                  ,l_event_source_info.entity_type_code
                  ,l_xla_event_id
                  ,p_claim_id
                  ,l_org_id
                  ,SYSDATE
                  ,NVL (fnd_global.user_id, -1)
                  ,SYSDATE
                  ,NVL (fnd_global.user_id, -1)
                  ,NVL (fnd_global.conc_login_id, -1)
                  ,l_reversal_flag
             );

  IF (p_event_type_code IS NOT NULL AND p_event_type_code <> 'CLAIM_SETTLEMENT_REVERSAL') THEN

     OPEN c_get_claim_line_util(p_claim_id);
      LOOP
        FETCH c_get_claim_line_util INTO l_claim_line_util_id;
      EXIT WHEN c_get_claim_line_util%notfound;

      l_counter := l_counter +1;

      INSERT INTO OZF_XLA_CLAIM_LINES
                   (XLA_CLAIM_LINE_ID
                   ,XLA_CLAIM_HEADER_ID
                   ,LINE_NUMBER
                   ,CLAIM_LINE_UTIL_ID
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,LAST_UPDATE_LOGIN)

       VALUES (OZF_XLA_CLAIM_LINES_S.NEXTVAL
                    ,l_xla_claim_hed_seq
                    ,l_counter
                    ,l_claim_line_util_id
                    ,SYSDATE
                    ,NVL (fnd_global.user_id, -1)
                    ,SYSDATE
                    ,NVL (fnd_global.user_id, -1)
                    ,NVL (fnd_global.conc_login_id, -1)
               );
      END LOOP;
     CLOSE c_get_claim_line_util;

 END IF;

END IF;
   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_SLA_Claim_Extract;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_SLA_Claim_Extract;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO Create_SLA_Claim_Extract;
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

END Create_SLA_Claim_Extract;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Gl_Entry
--
-- PURPOSE
--    Create a gl entry.
--
-- PARAMETERS
--    p_gl_rec   : the new record to be inserted
--    x_event_id  : return the claim_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.

-- HISTORY
-- 05/03/2010  kpatro    Updated for ER#9382547 ChRM-SLA Uptake
--
---------------------------------------------------------------------
PROCEDURE  Create_Gl_Entry (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_gl_rec                 IN    gl_interface_rec_type
  )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Gl_Entry';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_post_to_gl            varchar2(1);
l_off_inv_gl            varchar2(1);

CURSOR accrual_gl_posting_csr(p_id in number) IS
SELECT NVL(osp.post_to_gl, 'F')
,      NVL(osp.gl_acct_for_offinv_flag, 'F')
FROM   ozf_sys_parameters_all osp
,      ozf_funds_utilized_all_b ofa
WHERE  osp.org_id = ofa.org_id
AND    ofa.utilization_id = p_id;

CURSOR claim_gl_posting_csr(p_id in number) IS
SELECT NVL(osp.post_to_gl, 'F')
FROM   ozf_sys_parameters_all osp
,      ozf_claims_all oc
WHERE  osp.org_id = oc.org_id
AND    oc.claim_id = p_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Create_Gl_Entry_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- create_gl_entry ----------');
      OZF_Utility_PVT.debug_message('event_type_code   : '||p_gl_rec.event_type_code);
      OZF_Utility_PVT.debug_message('source_id         : '||p_gl_rec.source_id);
      OZF_Utility_PVT.debug_message('source_table      : '||p_gl_rec.source_table);
    END IF;


--//ER#9382547 ChRM-SLA Uptake
/*
    -- [BEGIN OF BUG 4039894 FIXING]
    -- Avoid GL entry creation if posting was done before for utilization.
    IF p_gl_rec.source_table = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
       OPEN chk_ae_exist(p_gl_rec.source_id, 'OZF_FUNDS_UTILIZED_ALL_B');
       FETCH chk_ae_exist INTO l_acc_event_id;
       CLOSE chk_ae_exist;

       IF l_acc_event_id IS NOT NULL THEN
          IF OZF_DEBUG_HIGH_ON THEN
             FND_MESSAGE.set_name('OZF', 'OZF_ACCT_GL_ENTRY_EXIST');
             FND_MESSAGE.set_token('SOURCE_ID', p_gl_rec.source_id);
             FND_MESSAGE.set_token('SOURCE_TABLE', p_gl_rec.source_table);
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
    -- [END OF BUG 4039894 FIXING]
*/


   -- check if post to gl flag in system parameter is set to T
   IF upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN
     OPEN claim_gl_posting_csr(p_gl_rec.source_id);
     FETCH claim_gl_posting_csr INTO l_post_to_gl;
     CLOSE claim_gl_posting_csr;
   ELSIF upper(p_gl_rec.source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN
     OPEN accrual_gl_posting_csr(p_gl_rec.source_id);
     FETCH accrual_gl_posting_csr INTO l_post_to_gl, l_off_inv_gl;
     CLOSE accrual_gl_posting_csr;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('SYSPARAM: Post to GL is ' || l_post_to_gl);
      OZF_Utility_PVT.debug_message('SYSPARAM: Post to Offinvoice is ' || l_off_inv_gl);
   END IF;

   -- check if event type is off_invoice. create gl entries only when system
   -- parameters requires so
   IF p_gl_rec.event_type_code = 'OFF_INVOICE_ACCRUAL_CREATION' AND l_off_inv_gl = 'F' THEN
      l_post_to_gl := 'F';
   END IF;

  --//ER#9382547 ChRM-SLA Uptake
  /*
   -- check if claim has promotions. create gl entries only for promotional claims
   IF upper(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN
      OPEN promo_claim_csr(p_gl_rec.source_id);
         FETCH promo_claim_csr INTO l_asso_amount;
      CLOSE promo_claim_csr;

      IF l_asso_amount = 0 THEN
         l_post_to_gl := 'F';
         IF OZF_DEBUG_LOW_ON THEN
            OZF_Utility_PVT.debug_message('Claim has no earnings associated');
         END IF;
      END IF;
   END IF;
  */
   -- create entries in GL interface tables only when post_to_gl is T

   --//ER#9382547 ChRM-SLA Uptake
   -- Here we check the post to General ledger flag from system parameter.
   -- If it us cheked and based on the source table we trigger SLA event and
   -- create the extract table for accrual and claim settlement
   IF l_post_to_gl = 'T' THEN
       IF UPPER(p_gl_rec.source_table) = 'OZF_FUNDS_UTILIZED_ALL_B' THEN

          Create_SLA_Accrual_Extract (
                 p_api_version          => 1.0
                ,p_init_msg_list        => FND_API.G_FALSE
                ,p_commit               => FND_API.G_FALSE
                ,p_validation_level     => FND_API.G_VALID_LEVEL_FULL
                ,x_return_status        => x_return_status
                ,x_msg_data             => x_msg_data
                ,x_msg_count            => x_msg_count
                ,p_utilization_id       => p_gl_rec.source_id
                ,p_event_type_code      => p_gl_rec.event_type_code
                ,p_adj_cr_ccid          => p_gl_rec.cr_code_combination_id
                ,p_adj_dr_cc_id         => p_gl_rec.dr_code_combination_id
           );

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       ELSIF UPPER(p_gl_rec.source_table) = 'OZF_CLAIMS_ALL' THEN

          Create_SLA_Claim_Extract (
              p_api_version         => 1.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
             ,x_return_status       => x_return_status
             ,x_msg_data            => x_msg_data
             ,x_msg_count           => x_msg_count
             ,p_claim_id            => p_gl_rec.source_id
             ,p_event_type_code     => p_gl_rec.event_type_code
          );

          IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;
   END IF; --IF l_post_to_gl = 'T' THEN

    --//ER#9382547 ChRM-SLA Uptake
    --//Start Skipping Existing code for GL Interfacing
    /*
      --l_acctng_entries := nvl(fnd_profile.value('OZF_ACCT_GEN_ONLINE'),'T');

      -- get the SLA table values populated
      Set_Accounting_Rules(
         P_Api_Version                => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         X_Msg_Data                   => x_msg_data,
         X_Msg_Count                  => x_msg_count,
         X_Return_Status              => x_return_status,
         p_gl_rec                     => p_gl_rec,
         p_acctng_entries             => l_acctng_entries,
         x_accounting_event_rec       => l_acctng_event_rec,
         x_ae_header_rec              => l_ae_header_rec,
         x_ae_line_tbl                => l_ae_line_tbl );

      IF x_return_status = FND_API.g_ret_sts_error THEN
         --IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         --   FND_MESSAGE.set_name('OZF', 'OZF_GL_ACCT_RULE_ERROR');
         --   FND_MSG_PUB.add;
         --END IF;
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- populate interface tables for GL enter creation
      -- Create accounting event
      OZF_acctng_events_PVT.Create_acctng_events(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data,
          P_ACCTNG_EVENT_Rec           => l_ACCTNG_EVENT_Rec,
          X_ACCOUNTING_EVENT_ID        => l_ACCOUNTING_EVENT_ID);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_acctng_entries = 'T' THEN

      -- Create account event header
      l_ae_header_rec.accounting_event_id := l_accounting_event_id;
      OZF_ae_header_PVT.Create_ae_header(
         P_Api_Version_Number         => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => FND_API.G_FALSE,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data,
         P_AE_HEADER_Rec              => l_AE_HEADER_Rec,
         X_AE_HEADER_ID               => l_AE_HEADER_ID);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Create account event lines
      FOR i in 1..l_AE_LINE_Tbl.count LOOP
         l_AE_LINE_Tbl(i).ae_header_id := l_ae_header_id;
         IF OZF_DEBUG_HIGH_ON THEN
         OZF_UTILITY_PVT.debug_message('Line Number before calling api: ' ||
                                         l_ae_line_tbl(i).ae_line_number);
         END IF;
      END LOOP;

      OZF_ae_line_PVT.Create_ae_line(
         P_Api_Version_Number         => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => FND_API.G_FALSE,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data,
         P_AE_LINE_Tbl                => l_AE_LINE_Tbl,
         X_AE_LINE_ID                 => l_AE_LINE_ID_Tbl);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      END IF;  -- if l_acctng_entries = 'T'

      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Accounting event: id = '||l_accounting_event_id);
      END IF;
     */
     --//End Skipping Existing code for GL Interfacing

      -- pass accounting event id
      --//ER#9382547 ChRM-SLA Uptake

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Gl_Entry_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Gl_Entry_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Create_Gl_Entry_PVT;
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
--
END Create_Gl_Entry;
---------------------------------------------------------------------
-- PROCEDURE
--    Create_Acctng_Entries
--
-- PURPOSE
--    Create accounting headers and lines
--
-- PARAMETERS
--    p_gl_rec   : the new record to be inserted
--    x_event_id  : return the claim_id of the new reason code
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
/*PROCEDURE  Create_Acctng_Entries (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_event_id               IN    NUMBER
   ,p_gl_rec                 IN    gl_interface_rec_type
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_Acctng_Entries';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_acctng_event_rec   OZF_acctng_events_PVT.acctng_event_rec_type;
l_ae_header_rec         OZF_ae_header_PVT.ae_header_rec_type;
l_ae_line_tbl           OZF_ae_line_PVT.ae_line_tbl_type;

l_accounting_event_id   number := p_event_id;
l_ae_header_id          number;
l_ae_line_id_tbl        OZF_ae_line_PVT.number_tbl_type;
--
l_acctng_entries        varchar2(3);
l_event_status_code     varchar2(30);

CURSOR check_acct_status_csr (p_id in number) IS
select event_status_code
from   ozf_acctng_events_all
where  accounting_event_id = p_id;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Create_Acctng_Entries;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           p_api_version,
           l_api_name,
           G_PKG_NAME)
   THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
           FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
           FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
           FND_MSG_PUB.Add;
   END IF;
   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
           FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN check_acct_status_csr(l_accounting_event_id);
      FETCH check_acct_status_csr INTO l_event_status_code;
   CLOSE check_acct_status_csr;

   -- raise error if the event status code is already accounted
   IF l_event_status_code = 'ACCOUNTED' THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_GL_INCORR_EVENT_STATUS');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Construct Header Rec
   -- ae header rec
   Construct_Header_Rec(
      p_gl_rec         => p_gl_rec
     ,x_return_status  => x_return_status
     ,x_ae_header_rec  => l_ae_header_rec);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- ae lines
   Construct_Line_Rec(
      p_gl_rec          => p_gl_rec
     ,x_return_status   => x_return_status
     ,x_ae_line_tbl     => l_ae_line_tbl);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Create account event header
   l_ae_header_rec.accounting_event_id := l_accounting_event_id;
   OZF_ae_header_PVT.Create_ae_header(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data,
      P_AE_HEADER_Rec              => l_AE_HEADER_Rec,
      X_AE_HEADER_ID               => l_AE_HEADER_ID);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Create account event lines
   FOR i in 1..l_AE_LINE_Tbl.count LOOP
      l_AE_LINE_Tbl(i).ae_header_id := l_ae_header_id;
      IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('Line Number before calling api: ' ||
                                      l_ae_line_tbl(i).ae_line_number);
      END IF;
   END LOOP;

   OZF_ae_line_PVT.Create_ae_line(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data,
      P_AE_LINE_Tbl                => l_AE_LINE_Tbl,
      X_AE_LINE_ID                 => l_AE_LINE_ID_Tbl);

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Update accounting events table
   UPDATE ozf_acctng_events_all
   SET    event_status_code = 'ACCOUNTED'
   where  accounting_event_id = l_accounting_event_id;

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Acctng_Entries;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Acctng_Entries;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Create_Acctng_Entries;
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
--
END Create_Acctng_Entries;
*/
---------------------------------------------------------------------

-- Start R12 Enhancements

---------------------------------------------------------------------
-- PROCEDURE
--    Revert_GL_Entry
--
-- PURPOSE
--    When promotional claims are cancelled, this API is called to
--      delete corresponding accounting entries. If the entries
--      are already interfaced to GL, entries in reverse will be
--      created to undo the posting.
--
-- PARAMETERS
--    p_claim_id : the claim that is cancelled
--
-- NOTES
---------------------------------------------------------------------
/*PROCEDURE Revert_GL_Entry (
    p_api_version         IN    NUMBER
   ,p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_claim_id            IN    NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Revert_GL_Entry';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_acctng_event_rec     OZF_ACCTNG_EVENTS_PVT.acctng_event_rec_type;
l_ae_header_rec        OZF_AE_HEADER_PVT.ae_header_rec_type;
l_ae_line_tbl          OZF_AE_LINE_PVT.ae_line_tbl_type;

l_new_event_id         NUMBER;
l_new_header_id        NUMBER;
l_new_line_id_tbl      OZF_AE_LINE_PVT.number_tbl_type;

l_ae_header_id           NUMBER;
l_aeh_object_version_num NUMBER;
l_gl_transfer_yn         VARCHAR2(1);
l_ae_line_id             NUMBER;
l_ael_object_version_num NUMBER;
l_accounting_event_id    NUMBER;
l_ae_object_version_num  NUMBER;

k                        PLS_INTEGER := 1;

l_accounted_cr         NUMBER;
l_accounted_dr         NUMBER;
l_ae_line_number       NUMBER;
l_ae_line_type_code    VARCHAR2(30);
l_ccid                 NUMBER;
l_currency_code        VARCHAR2(30);
l_description          VARCHAR2(240);
l_entered_cr           NUMBER;
l_entered_dr           NUMBER;
l_source_id            NUMBER;
l_source_table         VARCHAR2(30);
l_org_id               NUMBER;

--//Bug 7633112
l_reference2           VARCHAR2(240);
l_reference3           VARCHAR2(240);

--Bug7391920
l_period_closed        VARCHAR2(1);
l_set_of_books_id      NUMBER;

-- Get account event details for given source_id
-- For now accounting entries are reverted only for CLAIMS
-- *TODO* scope to make this generic
CURSOR get_accounting_event_csr( p_source_id in NUMBER ) IS
    SELECT accounting_event_id
         , event_number
         , event_status_code
         , event_type_code
         , source_id
         , source_table
         , org_id
         , accounting_date
         , object_version_number
    from ozf_acctng_events_all
    where source_table = 'OZF_CLAIMS_ALL'
    and source_id = p_source_id;

-- Get header details for given accounting event
CURSOR get_ae_header_csr( p_accounting_event_id in NUMBER ) IS
   select ae_header_id
         , ae_category
         , cross_currency_flag
         , description
         , gl_reversal_flag
         , period_name
         , set_of_books_id
         , gl_transfer_flag
         , org_id
         , object_version_number
   from ozf_ae_headers_all
   where accounting_event_id = p_accounting_event_id;

-- Get line ids for given header
CURSOR get_ae_lines_csr( p_ae_header_id in NUMBER ) IS
   select ae_line_id
          , object_version_number
   from ozf_ae_lines_all
   where ae_header_id = p_ae_header_id;

-- Get line details for given header
--//Bug 7633112
CURSOR get_ae_lines_dtl_csr( p_ae_header_id in NUMBER ) IS
   select accounted_cr
         , accounted_dr
         , entered_cr
         , entered_dr
         , ae_line_number
         , ae_line_type_code
         , code_combination_id
         , currency_code
         , description
         , source_id
         , source_table
         , org_id
         , reference2
         , reference3
   from ozf_ae_lines_all
   where ae_header_id = p_ae_header_id;

--Bug7391920 - Added cursor c_period_closed
CURSOR c_period_closed ( l_acct_date DATE ) IS
SELECT closing_status
FROM   gl_period_statuses a
     , ozf_sys_parameters b
WHERE  application_id = 222
  AND  a.set_of_books_id = b.set_of_books_id
  AND  l_acct_date BETWEEN start_date AND end_date
  AND  NVL(adjustment_period_flag,'N') = 'N';


--Bug7391920 - Added cursor c_open_period
CURSOR c_open_period IS
SELECT MIN(start_date)
FROM   gl_period_statuses a
     , ozf_sys_parameters b
WHERE  a.application_id = 222
AND    a.set_of_books_id =  b.set_of_books_id
AND    nvl(a.adjustment_period_flag,'N') = 'N'
AND    a.closing_status IN ( 'O','F');

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Revert_GL_Entry;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- Revert_GL_Entry ----------');
      OZF_Utility_PVT.debug_message('claim_id          : '||p_claim_id);
    END IF;

   OPEN get_accounting_event_csr( p_claim_id );
      FETCH get_accounting_event_csr INTO l_accounting_event_id
                                      , l_acctng_event_rec.event_number
                                      , l_acctng_event_rec.event_status_code
                                      , l_acctng_event_rec.event_type_code
                                      , l_acctng_event_rec.source_id
                                      , l_acctng_event_rec.source_table
                                      , l_acctng_event_rec.org_id
                                      , l_acctng_event_rec.accounting_date
                                      , l_ae_object_version_num;
   CLOSE get_accounting_event_csr;

   IF l_accounting_event_id IS NULL OR l_accounting_event_id = FND_API.G_MISS_NUM THEN
      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('There is no accounting event for the source. Return to the caller.');
      END IF;

      RETURN;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
     OZF_Utility_PVT.debug_message('Found matching event id     : '||l_accounting_event_id);
   END IF;

   OPEN get_ae_header_csr( l_accounting_event_id );
      FETCH get_ae_header_csr INTO l_ae_header_id
                                   , l_ae_header_rec.ae_category
                                   , l_ae_header_rec.cross_currency_flag
                                   , l_ae_header_rec.description
                                   , l_ae_header_rec.gl_reversal_flag
                                   , l_ae_header_rec.period_name
                                   , l_ae_header_rec.set_of_books_id
                                   , l_gl_transfer_yn
                                   , l_ae_header_rec.org_id
                                   , l_aeh_object_version_num;
   CLOSE get_ae_header_csr;

   IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('Found matching header id     : '||l_ae_header_id);
   END IF;

   IF l_gl_transfer_yn = 'Y' THEN
      -- Create reverse entries in the SLA
      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Transferred to GL, create reverse entries');
      END IF;

      -- First create accounting event for the reversal event
      /*OZF_ACCTNG_EVENTS_PVT.Create_Acctng_Events(
                    P_Api_Version_Number         => 1.0,
                    P_Init_Msg_List              => FND_API.G_FALSE,
                    P_Commit                     => FND_API.G_FALSE,
                    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    P_Acctng_Event_Rec           => l_acctng_event_rec,
                    X_Accounting_Event_Id        => l_new_event_id);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Created new accounting event');
      END IF;

      -- Create a new header for reversal entries
      l_ae_header_rec.gl_transfer_flag := 'N';
      l_ae_header_rec.gl_transfer_run_id := -1;
      l_ae_header_rec.accounting_event_id := l_new_event_id;
      l_ae_header_rec.accounting_date := l_acctng_event_rec.accounting_date;

      --Bug7391920 - Added cursor FETCH c_period_closed
      OPEN  c_period_closed(l_acctng_event_rec.accounting_date);
      FETCH c_period_closed INTO l_period_closed;
      CLOSE c_period_closed;

      --Bug7391920 - Added IF block
      IF l_period_closed <> 'O' THEN
        OPEN  c_open_period;
        FETCH c_open_period INTO l_ae_header_rec.accounting_date;
        CLOSE c_open_period;
      END IF;

      /*OZF_ae_header_PVT.Create_ae_header(
                   P_Api_Version_Number         => 1.0,
                   P_Init_Msg_List              => FND_API.G_FALSE,
                   P_Commit                     => FND_API.G_FALSE,
                   P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status              => x_return_status,
                   x_msg_count                  => x_msg_count,
                   x_msg_data                   => x_msg_data,
                   P_AE_HEADER_Rec              => l_ae_header_rec,
                   X_AE_HEADER_ID               => l_new_header_id);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Created new accounting header');
      END IF;

      -- Create new lines for the reverse entries, by switching credit/debit amounts
      k := 1;
      l_ae_line_tbl := null;
      l_ae_line_tbl := OZF_ae_line_PVT.ae_line_tbl_type();

      OPEN get_ae_lines_dtl_csr( l_ae_header_id );
      LOOP
        FETCH get_ae_lines_dtl_csr INTO l_accounted_cr
                                          , l_accounted_dr
                                          , l_entered_cr
                                          , l_entered_dr
                                          , l_ae_line_number
                                          , l_ae_line_type_code
                                          , l_ccid
                                          , l_currency_code
                                          , l_description
                                          , l_source_id
                                          , l_source_table
                                          , l_org_id
                                          , l_reference2 --//Bug 7633112
                                          , l_reference3;
         EXIT WHEN get_ae_lines_dtl_csr%NOTFOUND;

         l_ae_line_tbl.extend;
         l_ae_line_tbl(k) := null;
         l_ae_line_tbl(k).ae_line_number      := l_ae_line_number;
         l_ae_line_tbl(k).ae_line_type_code   := l_ae_line_type_code;
         l_ae_line_tbl(k).code_combination_id := l_ccid;
         l_ae_line_tbl(k).currency_code       := l_currency_code;
         l_ae_line_tbl(k).description         := l_description;
         l_ae_line_tbl(k).source_id           := l_source_id;
         l_ae_line_tbl(k).source_table        := l_source_table;
         l_ae_line_tbl(k).org_id              := l_org_id;
         l_ae_line_tbl(k).ae_header_id        := l_new_header_id;
         --//Bug 7633112
         l_ae_line_tbl(k).reference2          := l_reference2;
         l_ae_line_tbl(k).reference3          := l_reference3;

           -- Reverse debit/credit amounts
         IF l_accounted_cr IS NOT NULL THEN
            l_ae_line_tbl(k).accounted_cr := NULL;
            l_ae_line_tbl(k).accounted_dr := l_accounted_cr;
            l_ae_line_tbl(k).entered_cr   := NULL;
            l_ae_line_tbl(k).entered_dr   := l_entered_cr;
         ELSIF l_accounted_dr IS NOT NULL THEN
            l_ae_line_tbl(k).accounted_cr := l_accounted_dr;
            l_ae_line_tbl(k).accounted_dr := NULL;
            l_ae_line_tbl(k).entered_cr   := l_entered_dr;
            l_ae_line_tbl(k).entered_dr   := NULL;
         END IF;

         k := k + 1;
      END LOOP;
      CLOSE get_ae_lines_dtl_csr;

     /* OZF_ae_line_PVT.Create_ae_line(
                    P_Api_Version_Number         => 1.0,
                    P_Init_Msg_List              => FND_API.G_FALSE,
                    P_Commit                     => FND_API.G_FALSE,
                    P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status              => x_return_status,
                    x_msg_count                  => x_msg_count,
                    x_msg_data                   => x_msg_data,
                    P_AE_LINE_Tbl                => l_ae_line_tbl,
                    X_AE_LINE_ID                 => l_new_line_id_tbl);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Created new accounting lines with reversed amounts');
      END IF;

      -- Finally, mark original header as reversed
      UPDATE ozf_ae_headers_all
         SET gl_reversal_flag = 'Y'
      WHERE ae_header_id = l_ae_header_id;
   ELSE
      -- Delete SLA entries not transferred to GL
      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Not transferred to GL, delete SLA entries');
      END IF;
      --//Bugfix :7297267
      OPEN get_ae_lines_csr( l_ae_header_id );
         LOOP
            FETCH get_ae_lines_csr INTO l_ae_line_id, l_ael_object_version_num;
            EXIT WHEN get_ae_lines_csr%notfound;

            IF OZF_DEBUG_HIGH_ON THEN
               OZF_UTILITY_PVT.debug_message('Delting SLA line, line_id:' || l_ae_line_id);
            END IF;

            -- Delete SLA lines not transferred
            /*OZF_AE_LINE_PVT.Delete_Ae_Line(
                  p_api_version_number    => 1.0,
                  p_init_msg_list         => FND_API.G_FALSE,
                  p_commit                => FND_API.G_FALSE,
                  p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                  x_return_status         => x_return_status,
                  x_msg_count             => x_msg_count,
                  x_msg_data              => x_msg_data,
                  p_ae_line_id            => l_ae_line_id,
                  p_object_version_number => l_ael_object_version_num);

            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END LOOP;
      CLOSE get_ae_lines_csr;

      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Deleted lines');
      END IF;

      -- Delete SLA header not transferred
      /*OZF_AE_HEADER_PVT.Delete_Ae_Header(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_ae_header_id          => l_ae_header_id,
            p_object_version_number => l_aeh_object_version_num);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Deleted header');
      END IF;

      -- Delete SLA accounting event not transferred
      /*OZF_ACCTNG_EVENTS_PVT.Delete_Acctng_Events(
            p_api_version_number    => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_commit                => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_accounting_event_id   => l_accounting_event_id,
            p_object_version_number => l_ae_object_version_num);

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF OZF_DEBUG_LOW_ON THEN
         OZF_Utility_PVT.debug_message('Deleted header');
         OZF_Utility_PVT.debug_message('Accounting entries successfully reverted.');
      END IF;

   END IF;

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Revert_GL_Entry;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Revert_GL_Entry;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO Revert_GL_Entry;
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

END Revert_GL_Entry;
*/

---------------------------------------------------------------------
-- PROCEDURE
--    Post_Accrual_To_GL
--
-- PURPOSE
--    For budget adjustment/utilization, the API will be called.
--
-- PARAMETERS
--   p_utilization_id           Funds utilization_id
--   p_event_type_code          SLA Event type code
--   p_dr_code_combination_id   Debit code combination id
--   p_cr_code_combination_id   Credit code combination id
--
-- NOTES
-- 8-Mar-10  BKUNJAN    ER#9382547 ChRM-SLA Uptake - Removed the OUT parameter
--                      x_event_id and IN Parameter p_adjustment_type.
--                      renamed  p_utilization_type to p_event_type_code
--                      removed p_skip_acct_gen_flag.
---------------------------------------------------------------------
PROCEDURE Post_Accrual_To_GL (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_utilization_id          IN  NUMBER
   ,p_event_type_code         IN  VARCHAR2
   ,p_dr_code_combination_id  IN  NUMBER   := NULL
   ,p_cr_code_combination_id  IN  NUMBER   := NULL
   )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Post_Accrual_To_GL';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_gl_rec  OZF_GL_INTERFACE_PVT.gl_interface_rec_type;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Post_Accrual_To_GL;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- Post_Accrual_To_GL ----------');
      OZF_Utility_PVT.debug_message('utilization_id    : '||p_utilization_id);
      OZF_Utility_PVT.debug_message('utilization_type  : '|| p_event_type_code);
      OZF_Utility_PVT.debug_message('debit_cc_id       : '||p_dr_code_combination_id);
      OZF_Utility_PVT.debug_message('credit_cc_id      : '||p_cr_code_combination_id);
    END IF;

   -- construct gl interface record
   l_gl_rec.event_type_code        := p_event_type_code;
   l_gl_rec.event_status_code      := 'ACCOUNTED';
   l_gl_rec.source_id              := p_utilization_id;
   l_gl_rec.source_table           := 'OZF_FUNDS_UTILIZED_ALL_B';
  -- l_gl_rec.adjustment_type        := p_adjustment_type;
   l_gl_rec.dr_code_combination_id := p_dr_code_combination_id;
   l_gl_rec.cr_code_combination_id := p_cr_code_combination_id;


   OZF_GL_INTERFACE_PVT.Create_Gl_Entry (
            p_api_version          => l_api_version
           ,p_init_msg_list        => FND_API.g_false
           ,p_commit               => FND_API.g_false
           ,p_validation_level     => FND_API.g_valid_level_full
           ,x_return_status        => x_return_status
           ,x_msg_data             => x_msg_data
           ,x_msg_count            => x_msg_count
           ,p_gl_rec               => l_gl_rec
        );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Post_Accrual_To_GL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Post_Accrual_To_GL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO Post_Accrual_To_GL;
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

END Post_Accrual_To_GL;

---------------------------------------------------------------------
-- PROCEDURE
--    Post_Claim_To_GL

--
-- PURPOSE
--    For Claim settlement to be posted to GL, use this API.
--
-- PARAMETERS
--   p_claim_id                   Claim_id
--   p_claim_class                'CLAIM''CHARGE''DEDUCTION''OVERPAYMENT'
--   p_settlement_method          'CREDIT_MEMO''DEBIT_MEMO''CHECK''AP_DEBIT'
--   x_clear_code_combination_id  Code combination id of AR or AP clearing account
--
-- NOTES
-- 05/03/2010  kpatro    Updated for ER#9382547 ChRM-SLA Uptake
--                       Updated the Event Type Code,
--                       Removed the Event_ID,x_clear_code_combination_id
--                       OUT parameter and p_claim_class IN parameter
--                       Removed the Adjustment Type checks
---------------------------------------------------------------------
PROCEDURE Post_Claim_To_GL (
    p_api_version         IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status       OUT NOCOPY   VARCHAR2
   ,x_msg_data            OUT NOCOPY   VARCHAR2
   ,x_msg_count           OUT NOCOPY   NUMBER

   ,p_claim_id            IN  NUMBER
   ,p_settlement_method   IN  VARCHAR2
    )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Post_Claim_To_GL';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

CURSOR taxfor_csr (p_claim_id IN NUMBER)IS
   SELECT tax_for
   FROM ozf_claim_sttlmnt_methods_all csm,ozf_claims_all c
   WHERE csm.settlement_method = c.payment_method
   AND c.claim_id =p_claim_id
   AND csm.org_id = c.org_id;


l_gl_rec  OZF_GL_INTERFACE_PVT.gl_interface_rec_type;
l_taxfor             VARCHAR2(2);

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT Post_Claim_To_GL;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_full_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF OZF_DEBUG_LOW_ON THEN
      OZF_Utility_PVT.debug_message('--------- Post_Claim_To_GL ----------');
      OZF_Utility_PVT.debug_message('claim_id          : '||p_claim_id);
      OZF_Utility_PVT.debug_message('settlement method : '||p_settlement_method);
    END IF;

    OPEN taxfor_csr(p_claim_id);
    FETCH taxfor_csr INTO l_taxfor;
    CLOSE taxfor_csr;

   -- construct gl interface record
   -- R12.1 Enhancement : GL rec for Accounting only
   -- ER#9382547 Constructed the Event Type Codes of claims based on the settlement
   -- methods and pass the event type code to SLA
       IF p_settlement_method = 'CREDIT_MEMO' THEN
             l_gl_rec.event_type_code   := 'SETTLE_BY_CREDIT_MEMO';
       ELSIF p_settlement_method = 'DEBIT_MEMO' THEN
             l_gl_rec.event_type_code   := 'SETTLE_BY_DEBIT_MEMO';
       ELSIF p_settlement_method IN ('CHECK', 'WIRE', 'EFT','AP_DEFAULT') THEN
             l_gl_rec.event_type_code   := 'SETTLE_BY_AP_INVOICE';
       ELSIF p_settlement_method = 'AP_DEBIT' THEN
             l_gl_rec.event_type_code   := 'SETTLE_BY_AP_DEBIT';
       ELSIF p_settlement_method = 'ACCOUNTING_ONLY' THEN
             l_gl_rec.event_type_code   := 'SETTLE_INTERNAL_SHIP_DEBIT';
       -- Fix for Bug 9536761
       ELSIF p_settlement_method = 'CONTRA_CHARGE' THEN
             l_gl_rec.event_type_code   := 'SETTLE_BY_AR_AP_NETTING';
       ELSIF p_settlement_method = 'CLAIM_SETTLEMENT_REVERSAL' THEN
             l_gl_rec.event_type_code   := 'CLAIM_SETTLEMENT_REVERSAL';
       ELSE
             IF(l_taxfor = 'AR') THEN
                 l_gl_rec.event_type_code   := 'SETTLE_BY_AR_CUSTOM';
             ELSIF (l_taxfor = 'AP') THEN
                 l_gl_rec.event_type_code   := 'SETTLE_BY_AP_CUSTOM';
             END IF;
       END IF;

   l_gl_rec.event_status_code := 'ACCOUNTED';
   l_gl_rec.source_id         := p_claim_id;
   l_gl_rec.source_table      := 'OZF_CLAIMS_ALL';
   -- Adjutment Type Logic is now seeded with JLTs via switch
   /*IF p_claim_class IN ('CLAIM', 'DEDUCTION') THEN
      l_gl_rec.adjustment_type  := 'P';
   ELSIF p_claim_class IN ('CHARGE', 'OVERPAYMENT') THEN
      l_gl_rec.adjustment_type  := 'N';
   END IF;
   */
   OZF_GL_INTERFACE_PVT.Create_Gl_Entry (
            p_api_version          => l_api_version
           ,p_init_msg_list        => FND_API.g_false
           ,p_commit               => FND_API.g_false
           ,p_validation_level     => FND_API.g_valid_level_full
           ,x_return_status        => x_return_status
           ,x_msg_data             => x_msg_data
           ,x_msg_count            => x_msg_count
           ,p_gl_rec               => l_gl_rec
       );

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF  x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Standard check of commit
   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Post_Claim_To_GL;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Post_Claim_To_GL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO Post_Claim_To_GL;
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

END Post_Claim_To_GL;

---------------------------------------------------------------------
-- PROCEDURE
--    Defer_Claim_GL_Posting (Function)
--
-- PURPOSE
--    Function to be used by Claims to test if 'OZF: Claim
--     Settlement Workflow' should be called to defer GL posting
--
-- PARAMETERS
--    p_claim_id  : claim_id for which the check is done.
--
-- NOTES
---------------------------------------------------------------------
/*FUNCTION Defer_Claim_GL_Posting (
   p_claim_id          IN  NUMBER
) RETURN BOOLEAN
IS
l_return                 BOOLEAN := FALSE;

BEGIN

   RETURN l_return;

END Defer_Claim_GL_Posting;
*/
-- End R12 Enhancements
END OZF_GL_INTERFACE_PVT;

/
