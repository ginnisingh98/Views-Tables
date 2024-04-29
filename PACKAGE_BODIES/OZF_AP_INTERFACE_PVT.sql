--------------------------------------------------------
--  DDL for Package Body OZF_AP_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_AP_INTERFACE_PVT" AS
/* $Header: ozfvapib.pls 120.9.12010000.5 2010/01/22 09:34:28 muthsubr ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'OZF_AP_INTERFACE_PVT';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'ozfvapib.pls';

OZF_DEBUG_HIGH_ON  CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON   CONSTANT BOOLEAN      := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

---------------------------------------------------------------------
-- PROCEDURE
--    Create_ap_invoice
--
-- PURPOSE
--    Create a payabels invoice into payables open interface table.
--
-- PARAMETERS
--    p_claim_id : Will be passed as Invoice id
--    p_claim_number : Will be passed as Invoice number
--    p_settled_date : Will be passed as Invoice_date
--    p_vendor_id    : Supplier id
--    p_vendor_site_id : Supplier site id
--    p_amount_settled : Will be passed as Invoive amount
--    p_currency_code  : Will be passed as Invoice currency code
--    p_exchange_rate  : Invoice exchange rate
--    p_exchange_rate_type : Invoice exchange rate type
--    p_exchange_rate_date : Invoice exchange rate date
--    p_terms_id :  Payment Term id
--    p_payment_method  : Payment method type
--    p_gl_date  : Gl date
--
-- NOTES
--    1. creates an invoice header and invoice line in payables open
--       interface table.
--    2. Passes the claim number and settled date to invoice number
--       and invoice date.
--    3. Source = 'CLAIMS'

---   Sahana    20-Jul-2005   R12: Support for EFT, WIRE, AP_DEFAULR
---                           and AP_DEBIT payment methods.
---                           Handling of AP document cancellation.
---------------------------------------------------------------------
PROCEDURE Query_Claim(
    p_claim_id           IN    NUMBER
   ,x_claim_rec          OUT NOCOPY   OZF_Claim_PVT.claim_rec_type
   ,x_return_status      OUT NOCOPY   VARCHAR2
)
IS
BEGIN
   SELECT
       CLAIM_ID
      ,CLAIM_NUMBER
      ,CLAIM_TYPE_ID
      ,CLAIM_CLASS
      ,CLAIM_DATE
      ,DUE_DATE
      ,AMOUNT
      ,AMOUNT_ADJUSTED
      ,AMOUNT_REMAINING
      ,AMOUNT_SETTLED
      ,ACCTD_AMOUNT
      ,ACCTD_AMOUNT_REMAINING
      ,TAX_CODE
      ,TAX_CALCULATION_FLAG
      ,CURRENCY_CODE
      ,EXCHANGE_RATE_TYPE
      ,EXCHANGE_RATE_DATE
      ,EXCHANGE_RATE
      ,SET_OF_BOOKS_ID
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
      ,STATUS_CODE
      ,CUSTOMER_REF_DATE
      ,CUSTOMER_REF_NUMBER
      ,GL_DATE
      ,PAYMENT_METHOD
      ,PAYMENT_REFERENCE_ID
      ,PAYMENT_REFERENCE_NUMBER
      ,PAYMENT_REFERENCE_DATE
      ,PAYMENT_STATUS
      ,SETTLED_DATE
      ,EFFECTIVE_DATE
      ,COMMENTS
      ,ORG_ID
      ,LEGAL_ENTITY_ID
   INTO
       x_claim_rec.claim_id
      ,x_claim_rec.claim_number
      ,x_claim_rec.claim_type_id
      ,x_claim_rec.claim_class
      ,x_claim_rec.claim_date
      ,x_claim_rec.due_date
      ,x_claim_rec.amount
      ,x_claim_rec.amount_adjusted
      ,x_claim_rec.amount_remaining
      ,x_claim_rec.amount_settled
      ,x_claim_rec.acctd_amount
      ,x_claim_rec.acctd_amount_remaining
      ,x_claim_rec.tax_code
      ,x_claim_rec.tax_calculation_flag
      ,x_claim_rec.currency_code
      ,x_claim_rec.exchange_rate_type
      ,x_claim_rec.exchange_rate_date
      ,x_claim_rec.exchange_rate
      ,x_claim_rec.set_of_books_id
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
      ,x_claim_rec.status_code
      ,x_claim_rec.customer_ref_date
      ,x_claim_rec.customer_ref_number
      ,x_claim_rec.gl_date
      ,x_claim_rec.payment_method
      ,x_claim_rec.payment_reference_id
      ,x_claim_rec.payment_reference_number
      ,x_claim_rec.payment_reference_date
      ,x_claim_rec.payment_status
      ,x_claim_rec.settled_date
      ,x_claim_rec.effective_date
      ,x_claim_rec.comments
      ,x_claim_rec.org_id
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

PROCEDURE  Create_ap_invoice (
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_claim_id               IN    NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Create_ap_invoice';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id       NUMBER;
l_login_id      NUMBER;
l_sys_date      DATE;


l_Error_Msg              varchar2(2000);
l_Error_Token            varchar2(80);

l_invoice_line_num  number := 1;
l_invoice_id        number;
l_invoice_line_id   number;

l_reference VARCHAR2(240);

CURSOR csr_claim_ref_detail(cv_claim_id IN NUMBER) IS
SELECT customer_ref_number
FROM ozf_claims
WHERE claim_id = cv_claim_id;

CURSOR invoice_int_seq_csr IS
select ap_invoices_interface_s.nextval
from   dual;

CURSOR invoice_line_int_seq_csr IS
select ap_invoice_lines_interface_s.nextval
from   dual;

--Bug8531963: Commented CCID
CURSOR csr_system_param_details(cv_org_id IN NUMBER) IS
SELECT --ap.accts_pay_code_combination_id,
       ozf.gl_id_ded_clearing,
       ozf.payables_source,
       ozf.ap_payment_term_id
FROM   ap_system_parameters_all ap,
       ozf_sys_parameters_all ozf
WHERE  ozf.set_of_books_id = ap.set_of_books_id
AND    ozf.org_id = cv_org_id;
l_accts_pay_code_comb_id NUMBER;
l_dist_code_comb_id      NUMBER;
l_source                 VARCHAR2(30);
l_term_id                NUMBER;

-- kishore

CURSOR Get_Invoicenum_csr(cv_invoice_num IN VARCHAR2, cv_vendor_id IN NUMBER) IS
select invoice_num
from   AP_INVOICES
where  INVOICE_NUM = cv_invoice_num
and    VENDOR_ID = cv_vendor_id;

CURSOR csr_get_claim_lines(cv_claim_id IN NUMBER) IS
SELECT claim_currency_amount
,      acctd_amount
,      tax_code
,      claim_line_id
,      item_type
,      item_id
,      item_description
,      source_object_class
,      source_object_id
,      activity_type
,      activity_id
FROM   ozf_claim_lines_all
WHERE  claim_id = cv_claim_id;
l_claim_line_rec  csr_get_claim_lines%ROWTYPE;

l_cc_id_tbl 	OZF_Gl_Interface_PVT.cc_id_tbl;
l_vendor_clearing_account  NUMBER;
l_source_object_name varchar2(30);
l_account_type       varchar2(30);

l_claim_rec      OZF_Claim_PVT.claim_rec_type;
l_amount_settled NUMBER;

l_payment_method  VARCHAR2(30);
l_claim_number    VARCHAR2(30);
l_last_count      NUMBER;

-- To derive line description
l_line_description  VARCHAR2(2000);
l_item_type         VARCHAR2(30);
l_final_descr       VARCHAR2(240);

-- kishore
l_x_claim_number           VARCHAR2(50) := null;

CURSOR csr_item_desc(cv_item_id IN NUMBER) IS
 SELECT description
   FROM mtl_system_items_vl
  WHERE inventory_item_id = cv_item_id;

CURSOR csr_category_desc(cv_category_id IN NUMBER) IS
   SELECT SUBSTRB(category_desc,1,240)
    FROM  eni_prod_den_hrchy_parents_v
    WHERE category_id = cv_category_id;

CURSOR csr_media_desc(cv_media_channel_id IN NUMBER) IS
   SELECT  channel_name
     FROM  ams_media_channels_vl
    WHERE  channel_id = cv_media_channel_id;

CURSOR csr_trx_number(cv_trx_id IN NUMBER) IS
  SELECT trx_number
   FROM  ra_customer_trx_all
  WHERE  customer_trx_id = cv_trx_id;

CURSOR csr_order_number(cv_header_id IN NUMBER) IS
  SELECT order_number
   FROM  oe_order_headers_all
  WHERE  header_id = cv_header_id;

CURSOR csr_request_number(cv_request_id IN NUMBER) IS
  SELECT  request_number
    FROM  ozf_request_headers_vl
   WHERE  request_header_id = cv_request_id;

CURSOR csr_offer_code(cv_list_id IN NUMBER) IS
  SELECT offer_code
    FROM ozf_offers
   WHERE qp_list_header_id = cv_list_id;

CURSOR csr_type_meaning(cv_code IN VARCHAR2) IS
 SELECT meaning
   FROM ozf_lookups
  WHERE lookup_type = 'OZF_LINE_OVER_TYPE'
    AND lookup_code = cv_code;

CURSOR csr_item_type_meaning(cv_code IN VARCHAR2) IS
 SELECT meaning
   FROM ozf_lookups
  WHERE lookup_type = 'OZF_CLAIM_ITEM_TYPE'
    AND lookup_code = cv_code;

--Bug8531963
CURSOR csr_ven_sites(cv_vendor_site_id IN NUMBER) IS
SELECT accts_pay_code_combination_id
FROM   po_vendor_sites
WHERE  vendor_site_id = cv_vendor_site_id;

--Bug8531963
CURSOR csr_fin_sys_param(cv_org_id IN NUMBER) IS
SELECT accts_pay_code_combination_id
FROM   financials_system_params_all
WHERE  org_id = cv_org_id;

-- To derive terms id
/*CURSOR csr_fin_pay_method(cv_org_id IN NUMBER) IS
SELECT payment_method_lookup_code
  FROM FINANCIALS_SYSTEM_PARAMS_ALL
 WHERE org_id = cv_org_id;

CURSOR csr_vendor_pay_method(cv_vendor_id IN NUMBER) IS
SELECT payment_method_lookup_code
  FROM po_vendors
 WHERE vendor_id = cv_vendor_id;

CURSOR csr_vendor_site_pay_method(cv_vendor_site_id IN NUMBER) IS
SELECT payment_method_lookup_code
  FROM po_vendor_sites
 WHERE vendor_site_id = cv_vendor_site_id; */


--
BEGIN

    -- Standard begin of API savepoint
    SAVEPOINT  Create_ap_invoice_PVT;


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

    -- Query the claim
   Query_Claim(
        p_claim_id      => p_claim_id
       ,x_claim_rec     => l_claim_rec
       ,x_return_status => x_return_status);
   IF x_return_status =  FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


   l_user_id          := NVL(FND_GLOBAL.user_id,-1);
   l_login_id         := NVL(FND_GLOBAL.conc_login_id,-1);
   l_sys_date         := SYSDATE;

   -- Get Accts. Payables code combination id to populate Liability account
   -- in Invoice Header.
   --Bug8531963
   OPEN  csr_system_param_details( l_claim_rec.org_id);
   FETCH csr_system_param_details INTO -- l_accts_pay_code_comb_id
                                       l_dist_code_comb_id
                                     , l_source
                                     , l_term_id;
   CLOSE csr_system_param_details;

   --Bug8531963
   OPEN  csr_ven_sites(l_claim_rec.vendor_site_id);
   FETCH csr_ven_sites INTO l_accts_pay_code_comb_id;
   CLOSE csr_ven_sites;

   --Bug8531963
   IF l_accts_pay_code_comb_id IS NULL THEN
     OPEN  csr_fin_sys_param(l_claim_rec.org_id);
     FETCH csr_fin_sys_param INTO l_accts_pay_code_comb_id;
     CLOSE csr_fin_sys_param;
   END IF;


   IF l_claim_rec.payment_reference_number IS NULL THEN
       l_claim_number := l_claim_rec.claim_number;
   ELSE  -- This is a retry of settlement
       BEGIN
         l_last_count := TO_NUMBER(SUBSTRB(l_claim_rec.payment_reference_number,
                                    INSTRB(l_claim_rec.payment_reference_number,'.',-1,1)+1,
                                    LENGTHB(l_claim_rec.payment_reference_number)));
         l_claim_number := l_claim_rec.claim_number ||'.'||(l_last_count+1);
       EXCEPTION
       WHEN OTHERS THEN
           l_claim_number := l_claim_rec.payment_reference_number ||'.'||1;
       END;
     END IF;

   -- BUG 4754076 BEGIN
   OPEN Get_Invoicenum_csr(l_claim_number, l_claim_rec.vendor_id);
   FETCH Get_Invoicenum_csr INTO l_x_claim_number;
   CLOSE Get_Invoicenum_csr;

  -- If already exists do not insert record into Interface table else
  -- verify if the invoice has already been created for this claim.

  IF l_x_claim_number is NULL THEN

       -- get invoice id from sequence
       OPEN  invoice_int_seq_csr;
       FETCH invoice_int_seq_csr INTO l_invoice_id;
       CLOSE invoice_int_seq_csr;

       -- exchange rate to be populated only when the type is User
       IF l_claim_rec.exchange_rate_type <> 'User' THEN
            l_claim_rec.exchange_rate := null;
       END IF;

       IF l_claim_rec.payment_method IN ( 'CHECK','EFT','WIRE') THEN
          l_payment_method := l_claim_rec.payment_method;
       ELSE
          NULL;
          -- Payment Method derived by Payables.
       END IF;

       -- populate the invoice interface line for the claim
       OPEN csr_get_claim_lines(l_claim_rec.claim_id);
       LOOP
            FETCH csr_get_claim_lines INTO l_claim_line_rec;
            EXIT WHEN csr_get_claim_lines%NOTFOUND;

            IF l_claim_rec.payment_method = 'AP_DEBIT'
               AND SIGN(l_claim_line_rec.claim_currency_Amount) <> -1 THEN
                  l_claim_line_rec.claim_currency_amount := l_claim_line_rec.claim_currency_amount  * -1;
            END IF;

            l_amount_settled := NVL(l_amount_settled,0) + l_claim_line_rec.claim_currency_amount ;


            -- Derive Line Description
            IF  l_claim_line_rec.item_type in ( 'PRODUCT', 'FAMILY','MEDIA','ITEM') THEN
                OPEN  csr_item_type_meaning(NVL(l_claim_line_rec.source_object_class,l_claim_line_rec.activity_type));
                FETCH csr_item_type_meaning INTO l_item_type;
                CLOSE csr_item_type_meaning;
                l_final_descr := l_item_type || ':';
            ELSIF l_claim_line_rec.source_object_class IS NOT NULL OR
                   l_claim_line_rec.activity_type IS NOT NULL  THEN
                OPEN  csr_type_meaning(NVL(l_claim_line_rec.source_object_class,l_claim_line_rec.activity_type));
                FETCH csr_type_meaning INTO l_item_type;
                CLOSE csr_type_meaning;
                l_final_descr := l_item_type || ':';
            END IF;

            IF    l_claim_line_rec.item_type = 'PRODUCT' THEN
                OPEN  csr_item_desc(l_claim_line_rec.item_id);
                FETCH csr_item_desc INTO l_line_description;
                CLOSE csr_item_desc;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.item_type = 'FAMILY' THEN
                OPEN  csr_category_desc(l_claim_line_rec.item_id);
                FETCH csr_category_desc INTO l_line_description;
                CLOSE csr_category_desc;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.item_type = 'MEDIA' THEN
                OPEN  csr_media_desc(l_claim_line_rec.item_id);
                FETCH csr_media_desc INTO l_line_description;
                CLOSE csr_media_desc;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.source_object_class <> 'ORDER' THEN
                OPEN  csr_trx_number(l_claim_line_rec.source_object_id);
                FETCH csr_trx_number INTO l_line_description;
                CLOSE csr_trx_number;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.source_object_class = 'ORDER' THEN
                OPEN  csr_order_number(l_claim_line_rec.source_object_id);
                FETCH csr_order_number INTO l_line_description;
                CLOSE csr_order_number;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.activity_type = 'OFFR' THEN
                OPEN  csr_offer_code(l_claim_line_rec.activity_id);
                FETCH csr_offer_code INTO l_line_description;
                CLOSE csr_offer_code;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSIF l_claim_line_rec.activity_type in ('SOFT_FUND','SPECIAL_PRICE' ) THEN
                OPEN  csr_request_number(l_claim_line_rec.activity_id);
                FETCH csr_request_number INTO l_line_description;
                CLOSE csr_request_number;
                l_final_descr := SUBSTRB(l_final_descr || l_line_description,1,240);
            ELSE
                l_final_descr := NVL(l_claim_line_rec.item_description, l_claim_rec.claim_number);
            END IF;


            -- get the vendor clearing account from gl api
            OZF_Gl_Interface_PVT.Get_GL_Account(
                     p_api_version       => p_api_version
                    ,p_init_msg_list     => FND_API.G_FALSE
                    ,p_commit            => FND_API.G_FALSE
                    ,p_validation_level  => p_validation_level
                    ,x_return_status     => x_return_status
                    ,x_msg_data          => x_msg_data
                    ,x_msg_count         => x_msg_count
                    ,p_source_id         => l_claim_line_rec.claim_line_id
                    ,p_source_table      => 'OZF_CLAIM_LINES_ALL'
                    ,p_account_type      => 'VEN_CLEARING'
                    ,x_cc_id_tbl         => l_cc_id_tbl);
           IF x_return_status =  FND_API.g_ret_sts_error THEN
              RAISE FND_API.g_exc_error;
           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
              RAISE FND_API.g_exc_unexpected_error;
           END IF;

            FOR i in 1..l_cc_id_tbl.count LOOP
                 l_vendor_clearing_account := l_cc_id_tbl(i).code_combination_id;
            END LOOP;


            -- get invoice line id from sequence
            OPEN invoice_line_int_seq_csr;
            FETCH invoice_line_int_seq_csr INTO l_invoice_line_id;
            CLOSE invoice_line_int_seq_csr;

            INSERT INTO AP_INVOICE_LINES_INTERFACE (
                          INVOICE_ID
                         ,INVOICE_LINE_ID
                         ,LINE_NUMBER
                         ,LINE_TYPE_LOOKUP_CODE
                         ,AMOUNT
                         ,ACCOUNTING_DATE
                         ,TAX_CLASSIFICATION_CODE
                         ,LAST_UPDATED_BY
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATE_LOGIN
                         ,CREATED_BY
                         ,CREATION_DATE
                         ,DIST_CODE_COMBINATION_ID
                         ,ORG_ID
                         ,DESCRIPTION
                         ,APPLICATION_ID
                         ,PRODUCT_TABLE
                         ,REFERENCE_KEY1
                         ,REFERENCE_KEY2
                         ,REFERENCE_KEY3
                         ,REFERENCE_KEY4
                         ,REFERENCE_KEY5
			 ,SOURCE_APPLICATION_ID
			 ,SOURCE_ENTITY_CODE
			 ,SOURCE_EVENT_CLASS_CODE
			 ,INVENTORY_ITEM_ID --Fix for bug # 8576443
			 ,ITEM_DESCRIPTION -- Fix for Bug#8885844
                        )
                 VALUES (
                          l_invoice_id
                         ,l_invoice_line_id
                         ,l_invoice_line_num
                         ,'ITEM'
                         ,l_claim_line_rec.claim_currency_amount
                         ,l_claim_rec.gl_date
                         ,l_claim_line_rec.tax_code
                         ,l_user_id
                         ,l_sys_date
                         ,l_login_id
                         ,l_user_id
                         ,l_sys_date
                         ,l_vendor_clearing_account
                         ,l_claim_rec.org_id
                         ,l_final_descr
                         ,682
                         ,'OZF_CLAIMS_ALL'
                         ,l_claim_rec.claim_id
                         ,l_claim_rec.customer_ref_date
                         ,l_claim_rec.customer_ref_number
                         ,l_claim_rec.customer_reason
                         ,l_claim_line_rec.claim_line_id
			 ,682
			 ,'OZF_CLAIMS'
			 , 'TRADE_MGT_PAYABLES'
			 , l_claim_line_rec.item_id --Fix for bug # 8576443
			 , l_claim_line_rec.item_description -- Fix for Bug#8885844
                 );
                 l_invoice_line_num := l_invoice_line_num + 1;
       END LOOP;
       CLOSE csr_get_claim_lines;

          -- Added For Bug 7384640
	  OPEN csr_claim_ref_detail(p_claim_id);
          FETCH csr_claim_ref_detail INTO l_reference;
          CLOSE csr_claim_ref_detail;

          IF l_reference IS NOT NULL THEN
              l_claim_number := l_reference;
          END IF;

       -- Inserting an Invoice header record into AP_INVOICE_INTERFACE table.
       INSERT INTO AP_INVOICES_INTERFACE (
                            INVOICE_ID
                          , INVOICE_NUM
                          , INVOICE_DATE
                          , VENDOR_ID
                          , VENDOR_SITE_ID
                          , INVOICE_AMOUNT
                          , INVOICE_CURRENCY_CODE
                          , EXCHANGE_RATE
                          , EXCHANGE_RATE_TYPE
                          , EXCHANGE_DATE
                          , TERMS_ID
                          , DESCRIPTION
                          , LAST_UPDATE_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_LOGIN
                          , CREATION_DATE
                          , CREATED_BY
                          , SOURCE
                          , GROUP_ID
                          --, WORKFLOW_FLAG
                          , PAYMENT_METHOD_CODE
                          , GL_DATE
                          , ACCTS_PAY_CODE_COMBINATION_ID
                          , ORG_ID
                          , LEGAL_ENTITY_ID
                          , APPLICATION_ID
                          , PRODUCT_TABLE
                          , REFERENCE_KEY1
                          , REFERENCE_KEY2
                          , REFERENCE_KEY3
                          , REFERENCE_KEY4
                          , REFERENCE_KEY5
			  ,CALC_TAX_DURING_IMPORT_FLAG
                          ,ADD_TAX_TO_INV_AMT_FLAG
        )
        VALUES (
                           l_invoice_id
                          ,l_claim_number
                          ,l_claim_rec.settled_date
                          ,l_claim_rec.vendor_id
                          ,l_claim_rec.vendor_site_id
                          ,l_amount_settled
                          ,l_claim_rec.currency_code
                          ,l_claim_rec.exchange_rate
                          ,l_claim_rec.exchange_rate_type
                          ,l_claim_rec.exchange_rate_date
                          ,l_term_id
                          ,l_claim_rec.customer_ref_number
                          ,l_sys_date
                          ,l_user_id
                          ,l_login_id
                          ,l_sys_date
                          ,l_user_id
                          ,l_source
                          ,l_source|| ' '||l_claim_rec.claim_id
                          --,'Y'
                          ,l_payment_method
                          ,l_claim_rec.gl_date
                          ,l_accts_pay_code_comb_id
                          ,l_claim_rec.org_id
                          ,l_claim_rec.legal_entity_id
                          ,682
                          ,'OZF_CLAIMS_ALL'
                          ,l_claim_rec.claim_id
                          ,l_claim_rec.customer_ref_date
                          ,l_claim_rec.customer_ref_number
                          ,l_claim_rec.customer_reason
                          ,NULL
			  , 'Y'
			  , 'Y'
       );

       --Update payment information in Claim after invoice is been created.
       UPDATE ozf_claims_all
          SET payment_reference_id = l_invoice_id
          ,   payment_reference_number = l_claim_number
          ,   payment_reference_date = l_claim_rec.settled_date
          ,   payment_status = 'INTERFACED'
          WHERE claim_id = p_claim_id;
    -- if invoice is already created, update payment_status and payment_reference_number only
    ELSE  -- [ if l_x_claim_number is NOT NULL  ]
         UPDATE ozf_claims_all
          SET  payment_status = 'INTERFACED'
          , payment_reference_number = l_claim_number
          , payment_reference_date = l_claim_rec.settled_date
          , payment_reference_id = l_invoice_id
          WHERE claim_id = p_claim_id;
   END IF;    -- BUG 4754076  END.

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
      ROLLBACK TO  Create_ap_invoice_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Create_ap_invoice_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO  Create_ap_invoice_PVT;
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
END Create_ap_invoice;

END OZF_AP_INTERFACE_PVT;

/
