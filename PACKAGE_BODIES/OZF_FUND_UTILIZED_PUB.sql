--------------------------------------------------------
--  DDL for Package Body OZF_FUND_UTILIZED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_UTILIZED_PUB" AS
/* $Header: OZFPFUTB.pls 120.6.12010000.9 2010/04/09 18:39:52 kdass ship $ */

g_pkg_name    CONSTANT VARCHAR2(30) := 'OZF_FUND_UTILIZED_PUB';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Items
--
-- PURPOSE
--    Validate adjustment record.
--
-- PARAMETERS
--    p_adj_rec: adjustment record to be validated
--    x_return_status: return status
--
-- HISTORY
--    04/05/2005  kdass         Created
--    03/14/2005  psomyaju      ER-6858324
---------------------------------------------------------------------
PROCEDURE Validate_Items (
   p_adj_rec            IN OUT NOCOPY   OZF_FUND_UTILIZED_PUB.adjustment_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'Validate_Items';
l_fund_exists           NUMBER := NULL;
l_fund_id               NUMBER := NULL;
l_activity_id           NUMBER := NULL;
l_valid_csch            NUMBER := NULL;
l_valid_scantype_id     NUMBER := NULL;
l_cust_type             NUMBER := NULL;
l_dummy                 NUMBER := 0;
l_inv_org_id            NUMBER := FND_PROFILE.VALUE ('AMS_ITEM_ORGANIZATION_ID');
l_site_org_id           NUMBER := NULL;
l_org_for_product       NUMBER := NULL;
l_offer_org_id          NUMBER := NULL;
l_adjustment_type       VARCHAR2(30);
l_adjustment_type_id    NUMBER;
l_fund_curr_code        VARCHAR(30);

CURSOR c_fund_exists (p_fund_id IN NUMBER) IS
   SELECT 1
   FROM ozf_funds_all_b
   WHERE fund_id = p_fund_id;

CURSOR c_fund_num_exists (p_fund_num IN VARCHAR2) IS
   SELECT fund_id
   FROM ozf_funds_all_b
   WHERE fund_number = p_fund_num;

CURSOR c_valid_campaign (p_activity_id IN NUMBER) IS
   SELECT campaign_id
   FROM  ams_campaigns_vl
   WHERE active_flag = 'Y'
     AND show_campaign_flag = 'Y'
     AND campaign_id = p_activity_id;

CURSOR c_valid_event (p_activity_id IN NUMBER, p_approver_id IN NUMBER) IS
   SELECT event.event_header_id
   FROM  ams_event_headers_vl event,
         jtf_loc_hierarchies_vl loc,
         ams_act_access_denorm acc
   WHERE loc.location_type_code = 'COUNTRY'
     AND event.active_flag='Y'
     AND event.event_level='MAIN'
     AND event.event_standalone_flag='N'
     AND event.user_status_id NOT IN (6,9,7,27)
     AND TO_NUMBER(event.country_code) = loc.location_hierarchy_id
     AND acc.object_type = 'EVEH'
     AND acc.object_id = event.event_header_id
     AND acc.resource_id = p_approver_id
     AND event.event_header_id = p_activity_id;

CURSOR c_valid_deliverable (p_activity_id IN NUMBER) IS
   SELECT b.deliverable_id
   FROM  ams_deliverables_all_b b,
         ams_deliverables_all_tl tl,
         jtf_loc_hierarchies_vl c
   WHERE c.location_type_code = 'COUNTRY'
     AND b.active_flag='Y'
     AND c.location_hierarchy_id = b.country_id
     AND b.deliverable_id = tl.deliverable_id
     AND tl.language =userenv('LANG')
     AND b.deliverable_id = p_activity_id;

CURSOR c_valid_offer (p_activity_id IN NUMBER) IS
   SELECT list_header_id, orig_org_id
   FROM  qp_list_headers_all_b
   WHERE list_header_id = p_activity_id;

CURSOR c_valid_csch (p_activity_id IN NUMBER) IS
   SELECT 1
   FROM  ams_campaign_schedules_vl
   WHERE campaign_id = p_activity_id;

CURSOR c_valid_cust_type (p_cust_type IN VARCHAR2) IS
   SELECT 1
   FROM  ozf_lookups
   WHERE lookup_type = 'OZF_VO_CUSTOMER_TYPES'
     AND enabled_flag = 'Y'
     AND lookup_code = p_cust_type;

CURSOR c_cust_id_buyer (p_cust_id IN NUMBER) IS
   SELECT max(cust_account_id)
   FROM  hz_cust_accounts
   WHERE party_id = p_cust_id
     AND status= 'A';

CURSOR c_cust_id_billto (p_cust_id IN NUMBER) IS
   SELECT hzas.cust_account_id, hzas.org_id
   FROM  hz_cust_site_uses_all hzs,
         hz_cust_acct_sites_all hzas
   WHERE hzs.cust_acct_site_id = hzas.cust_acct_site_id
     AND hzs.site_use_id = p_cust_id;

CURSOR c_cust_id_shipto (p_cust_id IN NUMBER) IS
   SELECT hzas.cust_account_id, hzs.bill_to_site_use_id, hzas.org_id
   FROM  hz_cust_site_uses_all hzs,
         hz_cust_acct_sites_all hzas
   WHERE hzs.cust_acct_site_id = hzas.cust_acct_site_id
     AND hzs.site_use_id = p_cust_id;

CURSOR c_valid_scantype_id (p_activity_id IN NUMBER, p_scan_type_id IN NUMBER) IS
   SELECT 1
   FROM  ams_media_channels_vl med, ozf_offers off
   WHERE med.media_id = off.activity_media_id(+)
     AND qp_list_header_id = p_activity_id
     AND channel_id = p_scan_type_id;

--08-MAY-2006 kdass bug 5199585 SQL ID# 17777526 - added last condition so that table uses index
/*CURSOR c_valid_prod_family (p_prod_name IN VARCHAR2) IS
   SELECT category_id
   FROM  eni_prod_den_hrchy_parents_v
   WHERE category_desc = p_prod_name
   AND NVL(category_id, 0) = category_id;*/

--nirprasa, the category passed to the API was being validated incorrectly.
--Bug 8785946, FP of 8779543
CURSOR c_valid_prod_family (p_prod_name IN VARCHAR2) IS
SELECT c.category_id
  FROM    mtl_default_category_sets a ,
  mtl_category_sets_b b ,
  mtl_categories_v c ,
  ENI_PROD_DEN_HRCHY_PARENTS_V d
  WHERE a.functional_area_id in (7,11)
  AND a.category_set_id = b.category_set_id
  AND b.structure_id = c.structure_id
  AND c.category_id = d.category_id(+)
  AND UPPER(NVL(d.category_desc, c.category_concat_segs)) = UPPER(p_prod_name);

CURSOR c_valid_product (p_prod_name IN VARCHAR2, p_org_id IN NUMBER) IS
   SELECT inventory_item_id
   FROM  mtl_system_items_kfv
   WHERE organization_id = p_org_id
     AND trim(padded_concatenated_segments) = p_prod_name;

CURSOR c_adj_type_id (p_adj_type IN VARCHAR2, p_org_id IN NUMBER) IS
   SELECT max(claim_type_id)
   FROM ozf_claim_types_all_vl
   WHERE adjustment_type = p_adj_type
     AND claim_class = 'ADJ'
     AND claim_type_id > -1
     AND org_id = p_org_id;
--nirprasa,ER 8399134
CURSOR c_adj_type (p_adj_type_id IN NUMBER, p_org_id IN NUMBER) IS
   SELECT adjustment_type
   FROM ozf_claim_types_all_vl
   WHERE claim_type_id = p_adj_type_id
     AND claim_class = 'ADJ'
     AND org_id = p_org_id;


CURSOR c_approver_id (p_fund_id IN NUMBER) IS
   SELECT owner
   FROM  ozf_funds_all_vl
   WHERE fund_id = p_fund_id;

CURSOR c_curr_code (p_fund_id IN NUMBER) IS
   SELECT currency_code_tc
   FROM    ozf_funds_all_b
   WHERE fund_id = p_fund_id;

--Order_Line_Id validation added for ER-6858324
CURSOR c_order_line (p_order_line_id IN NUMBER, p_header_id IN NUMBER) IS
   SELECT  1
   FROM    oe_order_lines_all
   WHERE   line_id = p_order_line_id
     AND   header_id = p_header_id;

CURSOR c_org_id (p_org_id IN NUMBER, p_fund_id IN NUMBER) IS
   SELECT 1
   FROM hr_operating_units hr, ozf_funds_all_b fund
   WHERE fund.fund_id = p_fund_id
    AND  hr.organization_id = p_org_id
    AND  hr.set_of_books_id = fund.ledger_id;

CURSOR c_org_order (p_header_id IN NUMBER) IS
   SELECT org_id
   FROM oe_order_headers_all
   WHERE header_id = p_header_id;

CURSOR c_inventory_org (p_org_id IN NUMBER) IS
   SELECT parameter_value
    FROM  oe_sys_parameters_all
    WHERE parameter_code = 'MASTER_ORGANIZATION_ID'
      AND org_id = p_org_id;

--nirprasa,ER 8399134
CURSOR c_org_order_line (p_order_line_id IN NUMBER) IS
   SELECT h.org_id
   FROM   oe_order_headers_all h, oe_order_lines_all l
   WHERE  h.header_id = l.header_id
   AND    l.line_id = p_order_line_id ;

CURSOR c_offer_info (p_activity_id IN NUMBER) IS
   SELECT beneficiary_account_id,autopay_party_attr,autopay_party_id
   FROM ozf_offers
   WHERE qp_list_header_id = p_activity_id;

  -- Cursor to get the org_id for third party order
CURSOR c_tp_order_org_id (p_line_id IN NUMBER) IS
 SELECT org_id FROM ozf_resale_lines_all
 WHERE resale_line_id = p_line_id;

 -- Cursor to get the org_id for purchase order
CURSOR c_purchase_order_org_id (p_header_id IN NUMBER) IS
 SELECT org_id FROM po_headers_all
 WHERE po_header_id = p_header_id;

-- Cursor to get the org_id for invoice
CURSOR c_invoice_org_id (p_cust_trx_id IN NUMBER)IS
 SELECT org_id FROM ar_payment_schedules_all
 WHERE customer_trx_id = p_cust_trx_id;

 -- get sites org id type
CURSOR c_benef_org_id (p_site_use_id IN NUMBER) IS
  SELECT org_id
  FROM hz_cust_site_uses_all
  WHERE site_use_id = p_site_use_id;

--nirprasa,ER 8399134
CURSOR c_get_offer_currency (p_activity_id IN NUMBER) IS
   SELECT NVL(transaction_currency_code,fund_request_curr_code) fund_request_curr_code,
          transaction_currency_code
   FROM ozf_offers
   WHERE qp_list_header_id=p_activity_id;

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
   SELECT currency_code FROM po_headers_all
   WHERE po_header_id = p_document_number;

CURSOR c_get_header_id(p_order_line_id IN NUMBER) IS
   SELECT oh.transactional_curr_code
   FROM oe_order_lines_all ol,  oe_order_headers_all oh
   WHERE ol.line_id = p_order_line_id
   AND ol.header_id = oh.header_id;

CURSOR c_get_camp_currency (p_activity_id IN NUMBER) IS
   SELECT transaction_currency_code FROM ams_campaigns_vl
   WHERE campaign_id = p_activity_id;

CURSOR c_get_csch_currency (p_activity_id IN NUMBER) IS
   SELECT transaction_currency_code F
   FROM ams_campaign_schedules_vl
   WHERE schedule_id = p_activity_id;

CURSOR c_get_delv_currency (p_activity_id IN NUMBER) IS
   SELECT transaction_currency_code
   FROM ams_deliverables_vl
   WHERE deliverable_id = p_activity_id;

CURSOR c_get_eveh_currency (p_activity_id IN NUMBER) IS
   SELECT currency_code_tc FROM ams_event_headers_vl
   WHERE event_header_id = p_activity_id;

CURSOR c_get_eveo_currency (p_activity_id IN NUMBER) IS
   SELECT currency_code_tc FROM ams_event_offers_vl
   WHERE event_offer_id = p_activity_id;

l_offer_info       c_offer_info%ROWTYPE;
l_offer_currency   c_get_offer_currency%ROWTYPE;
l_document_curr    VARCHAR2(30);
l_header_id        NUMBER;
--end ER 8399134 code
BEGIN

   --check if the fund id or fund number is valid
   IF p_adj_rec.fund_id <> fnd_api.g_miss_num AND p_adj_rec.fund_id IS NOT NULL THEN
      --check if the input fund_id is valid
      OPEN c_fund_exists (p_adj_rec.fund_id);
      FETCH c_fund_exists INTO l_fund_exists;
      CLOSE c_fund_exists;

      IF l_fund_exists IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_FUND_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   ELSIF p_adj_rec.fund_number <> fnd_api.g_miss_num AND p_adj_rec.fund_number IS NOT NULL THEN
      --check if the input fund_number is valid
      OPEN c_fund_num_exists (p_adj_rec.fund_number);
      FETCH c_fund_num_exists INTO l_fund_id;
      CLOSE c_fund_num_exists;

      IF l_fund_id IS NOT NULL THEN
         p_adj_rec.fund_id := l_fund_id;
      ELSE
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_FUND_NUM');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_FUND_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
   END IF;

   IF p_adj_rec.adjustment_type = fnd_api.g_miss_char OR p_adj_rec.adjustment_type IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_ADJ_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_adj_rec.adjustment_type NOT IN ('DECREASE_COMM_EARNED', 'DECREASE_COMMITTED', 'DECREASE_EARNED',
                                        'STANDARD', 'DECREASE_PAID', 'INCREASE_PAID') THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ADJ_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   mo_global.init('OZF');


   IF (p_adj_rec.amount = fnd_api.g_miss_num OR p_adj_rec.amount IS NULL)
      --nirprasa,ER 8399134 add this condition since user can now pass plan_amount also
      AND (p_adj_rec.plan_amount = fnd_api.g_miss_num OR p_adj_rec.plan_amount IS NULL) THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_FUND_NO_ADJ_AMT');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_adj_rec.fund_id IS NOT NULL THEN
      OPEN c_curr_code(p_adj_rec.fund_id);
      FETCH c_curr_code INTO l_fund_curr_code;
      CLOSE c_curr_code;
      --nirprasa,ER 8399134 validate if p_adj_rec.currency_code is passed
      IF p_adj_rec.currency_code IS NULL OR p_adj_rec.currency_code = fnd_api.g_miss_char THEN
         p_adj_rec.currency_code := l_fund_curr_code;
      ELSIF p_adj_rec.currency_code <> l_fund_curr_code THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_FUND_CURR_CODE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
   --end ER 8399134 code changes

   IF p_adj_rec.activity_type NOT IN ('CAMP', 'DELV', 'EVEH', 'OFFR') THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ACTIVITY_TYPE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;

   IF p_adj_rec.activity_type = 'CAMP' THEN
      OPEN c_valid_campaign (p_adj_rec.activity_id);
      FETCH c_valid_campaign INTO l_activity_id;
      CLOSE c_valid_campaign;
   ELSIF p_adj_rec.activity_type = 'DELV' THEN
      OPEN c_valid_deliverable (p_adj_rec.activity_id);
      FETCH c_valid_deliverable INTO l_activity_id;
      CLOSE c_valid_deliverable;
   ELSIF p_adj_rec.activity_type = 'EVEH' THEN
      OPEN c_valid_event (p_adj_rec.activity_id, p_adj_rec.approver_id);
      FETCH c_valid_event INTO l_activity_id;
      CLOSE c_valid_event;
   ELSIF p_adj_rec.activity_type = 'OFFR' THEN
      OPEN c_valid_offer (p_adj_rec.activity_id);
      FETCH c_valid_offer INTO l_activity_id, l_offer_org_id;
      CLOSE c_valid_offer;
   END IF;

   IF l_activity_id IS NULL THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_ACTIVITY_ID');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;


   IF p_adj_rec.activity_type = 'CAMP' AND p_adj_rec.camp_schedule_id <> fnd_api.g_miss_num
      AND p_adj_rec.camp_schedule_id IS NOT NULL THEN

      OPEN c_valid_csch (p_adj_rec.activity_id);
      FETCH c_valid_csch INTO l_valid_csch;
      CLOSE c_valid_csch;

      IF l_valid_csch IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CSCH_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_adj_rec.customer_type <> fnd_api.g_miss_char AND p_adj_rec.customer_type IS NOT NULL THEN

      OPEN c_valid_cust_type (p_adj_rec.customer_type);
      FETCH c_valid_cust_type INTO l_cust_type;
      CLOSE c_valid_cust_type;

      IF l_cust_type IS NULL THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CUST_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_adj_rec.customer_type = 'CUSTOMER' THEN
         p_adj_rec.cust_account_id     := p_adj_rec.cust_id;
         p_adj_rec.bill_to_site_use_id := NULL;
         p_adj_rec.ship_to_site_use_id := NULL;
      ELSIF p_adj_rec.customer_type = 'BUYER' THEN

         OPEN c_cust_id_buyer (p_adj_rec.cust_id);
         FETCH c_cust_id_buyer INTO p_adj_rec.cust_account_id;
         CLOSE c_cust_id_buyer;

         p_adj_rec.bill_to_site_use_id := NULL;
         p_adj_rec.ship_to_site_use_id := NULL;
      ELSIF p_adj_rec.customer_type = 'CUSTOMER_BILL_TO' THEN

         OPEN c_cust_id_billto (p_adj_rec.cust_id);
         FETCH c_cust_id_billto INTO p_adj_rec.cust_account_id, l_site_org_id;
         CLOSE c_cust_id_billto;

         p_adj_rec.bill_to_site_use_id := p_adj_rec.cust_id;
         p_adj_rec.ship_to_site_use_id := NULL;
      ELSIF p_adj_rec.customer_type = 'SHIP_TO' THEN

         OPEN c_cust_id_shipto (p_adj_rec.cust_id);
         FETCH c_cust_id_shipto INTO p_adj_rec.cust_account_id, p_adj_rec.bill_to_site_use_id, l_site_org_id;
         CLOSE c_cust_id_shipto;

         p_adj_rec.ship_to_site_use_id := p_adj_rec.cust_id;
      END IF;

      IF p_adj_rec.cust_account_id = fnd_api.g_miss_num OR p_adj_rec.cust_account_id IS NULL THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_CUST_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   END IF;

   IF p_adj_rec.document_type <> fnd_api.g_miss_char AND p_adj_rec.document_type IS NOT NULL THEN
      IF p_adj_rec.document_type NOT IN ('INVOICE', 'ORDER', 'PCHO', 'TP_ORDER') THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_DOCUMENT_TYPE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_adj_rec.document_number = fnd_api.g_miss_num OR p_adj_rec.document_number IS NULL THEN

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_DOCUMENT_NUM');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   -- for SCAN_DATA type of offer
   IF p_adj_rec.scan_type_id <> fnd_api.g_miss_num AND p_adj_rec.scan_type_id IS NOT NULL THEN

      OPEN c_valid_scantype_id (p_adj_rec.activity_id, p_adj_rec.scan_type_id);
      FETCH c_valid_scantype_id INTO l_valid_scantype_id;
      CLOSE c_valid_scantype_id;

      IF l_valid_scantype_id IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_SCANTYPE_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   IF p_adj_rec.activity_type = 'OFFR' THEN
      IF p_adj_rec.product_level_type <> fnd_api.g_miss_char AND p_adj_rec.product_level_type IS NOT NULL THEN

         IF p_adj_rec.product_level_type NOT IN ('FAMILY', 'PRODUCT') THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_INVALID_PROD_LEVEL');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('p_adj_rec.product_id: ' || p_adj_rec.product_id);
            ozf_utility_pvt.debug_message('p_adj_rec.product_name: ' || p_adj_rec.product_name);
            ozf_utility_pvt.debug_message('l_inv_org_id: ' || l_inv_org_id);
         END IF;

         IF p_adj_rec.product_name = fnd_api.g_miss_char OR p_adj_rec.product_name IS NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('OZF', 'OZF_NO_PROD_NAME');
               fnd_msg_pub.add;
            END IF;
            x_return_status := fnd_api.g_ret_sts_error;
            RETURN;
         ELSE
            IF p_adj_rec.product_level_type = 'FAMILY' THEN
               OPEN c_valid_prod_family (p_adj_rec.product_name);
               FETCH c_valid_prod_family INTO p_adj_rec.product_id;
               CLOSE c_valid_prod_family;
            ELSIF p_adj_rec.product_level_type = 'PRODUCT' THEN

               /*07-APR-09 kdass bug 8402334 - used Inventory Org instead of Operating Unit
                 Derive Inventory Org in precedence - Order's OU, Offer's OU, profile AMS_ITEM_ORGANIZATION_ID
               */
               IF    p_adj_rec.document_type <> fnd_api.g_miss_char AND p_adj_rec.document_type IS NOT NULL
                 AND p_adj_rec.document_type = 'ORDER' THEN

                  OPEN c_org_order (p_adj_rec.document_number);
                  FETCH c_org_order INTO l_org_for_product;
                  CLOSE c_org_order;

               ELSIF l_offer_org_id IS NOT NULL THEN
                  l_org_for_product := l_offer_org_id;
               END IF;

               IF l_org_for_product IS NOT NULL THEN
                  OPEN c_inventory_org (l_org_for_product);
                  FETCH c_inventory_org INTO l_inv_org_id;
                  CLOSE c_inventory_org;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('l_inv_org_id: ' || l_inv_org_id);
                  END IF;
               END IF;

               OPEN c_valid_product (p_adj_rec.product_name, l_inv_org_id);
               FETCH c_valid_product INTO p_adj_rec.product_id;
               CLOSE c_valid_product;
            END IF;

            IF p_adj_rec.product_id IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_INVALID_PROD');
                  fnd_msg_pub.add;
               END IF;
               x_return_status := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
      END IF;
   ELSE
      p_adj_rec.product_level_type := NULL;
      p_adj_rec.product_id := NULL;
   END IF;

   IF p_adj_rec.adjustment_type IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
      IF p_adj_rec.gl_account_credit = fnd_api.g_miss_num OR p_adj_rec.gl_account_credit IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_GL_CREDIT_ACCT');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_adj_rec.gl_account_debit = fnd_api.g_miss_num OR p_adj_rec.gl_account_debit IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_NO_GL_DEBIT_ACCT');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   OPEN c_approver_id (p_adj_rec.fund_id);
   FETCH c_approver_id INTO p_adj_rec.approver_id;
   CLOSE c_approver_id;

   --ER 9382547
   /*
   IF p_adj_rec.skip_acct_gen_flag <> fnd_api.g_miss_char AND p_adj_rec.skip_acct_gen_flag IS NOT NULL THEN

      IF p_adj_rec.skip_acct_gen_flag NOT IN ('F', 'T') THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_ACCT_GEN_FLAG');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;
 */
   IF p_adj_rec.document_type <> fnd_api.g_miss_char AND p_adj_rec.document_type IS NOT NULL
      AND p_adj_rec.document_type = 'ORDER' AND p_adj_rec.order_line_id <> fnd_api.g_miss_num
      AND p_adj_rec.order_line_id IS NOT NULL THEN

     --07-APR-09 kdass bug 8402334 - added document_number to the cursor
     OPEN c_order_line(p_adj_rec.order_line_id, p_adj_rec.document_number);
     FETCH c_order_line INTO l_dummy;
     IF c_order_line%NOTFOUND THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_ORDER_LINE');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
     END IF;
     CLOSE c_order_line;
   END IF;

   /*07-APR-09 kdass bug 8402334
     OU validation rules:
     1) OU should be part of Budget's ledger
     2) OU should be same as bill to/ ship to site's OU
     3) OU should be same as Offer's OU
   */
   IF p_adj_rec.org_id <> fnd_api.g_miss_num AND p_adj_rec.org_id IS NOT NULL THEN

     --nirprasa,ER 8399134 if fund_id is not passed then this will always evaluate to false.
     IF p_adj_rec.fund_id <> fnd_api.g_miss_num AND p_adj_rec.fund_id IS NOT NULL THEN
     OPEN c_org_id(p_adj_rec.org_id, p_adj_rec.fund_id);
     FETCH c_org_id INTO l_dummy;
     IF c_org_id%NOTFOUND THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_INVALID_ORG_LEDGER');
           fnd_msg_pub.add;
           END IF;
           x_return_status := fnd_api.g_ret_sts_error;
           RETURN;
        END IF;
        CLOSE c_org_id;
     END IF;

     IF l_site_org_id IS NOT NULL AND l_site_org_id <> p_adj_rec.org_id THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_INVALID_ORG_SITE');
           fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;

     IF l_offer_org_id IS NOT NULL AND l_offer_org_id <> p_adj_rec.org_id THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
           fnd_message.set_name('OZF', 'OZF_INVALID_ORG_OFFER');
           fnd_msg_pub.add;
        END IF;
        x_return_status := fnd_api.g_ret_sts_error;
        RETURN;
     END IF;

  ELSE
     --nirprasa,ER 8399134
     /* Order for OU assignemnt
     1) Beneficiary OU
     2) Document OU
     3) Offer OU
     Added else condition to identify the org_id if not passed to the API.
     org_id will be used to validate adjustment_type_id id passed to the API.
     */
     OPEN c_offer_info (p_adj_rec.activity_id);
     FETCH c_offer_info INTO l_offer_info;
     CLOSE c_offer_info;

     IF l_offer_info.beneficiary_account_id IS NOT NULL AND
        l_offer_info.autopay_party_attr <> 'CUSTOMER' AND
        l_offer_info.autopay_party_attr IS NOT NULL THEN
           OPEN c_benef_org_id (l_offer_info.autopay_party_id);
           FETCH c_benef_org_id INTO p_adj_rec.org_id ;
           CLOSE c_benef_org_id;
     ELSIF p_adj_rec.document_type <> fnd_api.g_miss_char AND p_adj_rec.document_type IS NOT NULL THEN
        IF p_adj_rec.document_type = 'ORDER' THEN
           OPEN c_org_order (p_adj_rec.document_number);
           FETCH c_org_order INTO p_adj_rec.org_id ;
           CLOSE c_org_order;
         ELSIF p_adj_rec.document_type = 'PCHO' THEN
           OPEN c_purchase_order_org_id( p_adj_rec.document_number) ;
           FETCH c_purchase_order_org_id INTO p_adj_rec.org_id ;
           CLOSE c_purchase_order_org_id ;
         ELSIF p_adj_rec.document_type = 'TP_ORDER' THEN
            OPEN c_tp_order_org_id( p_adj_rec.document_number) ;
            FETCH c_tp_order_org_id INTO p_adj_rec.org_id ;
            CLOSE c_tp_order_org_id ;
         ELSIF p_adj_rec.document_type = 'INVOICE' THEN
            OPEN c_invoice_org_id( p_adj_rec.document_number) ;
            FETCH c_invoice_org_id INTO p_adj_rec.org_id ;
            CLOSE c_invoice_org_id ;
         END IF;
     ELSIF p_adj_rec.order_line_id <> fnd_api.g_miss_num AND p_adj_rec.order_line_id IS NOT NULL THEN
           OPEN c_org_order_line (p_adj_rec.order_line_id);
           FETCH c_org_order_line INTO p_adj_rec.org_id ;
           CLOSE c_org_order_line;
     END IF;
     IF l_offer_org_id IS NOT NULL AND l_offer_org_id <> p_adj_rec.org_id THEN
        p_adj_rec.org_id := l_offer_org_id;
     END IF;
  END IF;

   IF p_adj_rec.adjustment_type = 'INCREASE_PAID' THEN
      p_adj_rec.adjustment_type_id := -12;

   ELSIF p_adj_rec.adjustment_type = 'DECREASE_PAID' THEN
      p_adj_rec.adjustment_type_id := -13;

   ELSE

   --nirprasa,ER 8399134 use the adjustment_type_id passed to the API. Currently it is ignored.
   OPEN c_adj_type_id(p_adj_rec.adjustment_type,p_adj_rec.org_id);
   FETCH c_adj_type_id INTO l_adjustment_type_id;
   CLOSE c_adj_type_id;

   IF p_adj_rec.adjustment_type_id IS NULL THEN
      p_adj_rec.adjustment_type_id := l_adjustment_type_id;
   ELSE
      OPEN c_adj_type(p_adj_rec.adjustment_type_id,p_adj_rec.org_id);
      FETCH c_adj_type INTO l_adjustment_type;
      IF c_adj_type%NOTFOUND THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_ADJ_TYPE_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
      CLOSE c_adj_type;

      IF p_adj_rec.adjustment_type <> l_adjustment_type THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_INVALID_ADJ_TYPE_ID');
            fnd_msg_pub.add;
         END IF;
         x_return_status := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

   END IF;


 IF p_adj_rec.activity_type = 'OFFR' THEN
    OPEN c_get_offer_currency(p_adj_rec.activity_id);
    FETCH c_get_offer_currency INTO l_offer_currency;
    CLOSE c_get_offer_currency;

    IF l_offer_currency.transaction_currency_code IS NULL
    OR l_offer_currency.transaction_currency_code = fnd_api.g_miss_char THEN
    IF p_adj_rec.adjustment_type NOT IN ('DECREASE_COMMITTED') THEN
       IF p_adj_rec.order_line_id IS NULL
       OR p_adj_rec.order_line_id = fnd_api.g_miss_num THEN
          IF p_adj_rec.document_type IS NULL
          OR p_adj_rec.document_type = fnd_api.g_miss_char
          OR p_adj_rec.document_number IS NULL
          OR p_adj_rec.document_number = fnd_api.g_miss_num THEN
              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
              fnd_message.set_name('OZF', 'OZF_NO_DOCUMENT_INFO');
              fnd_msg_pub.add;
              END IF;
              x_return_status := fnd_api.g_ret_sts_error;
              RETURN;
           ELSE
              IF p_adj_rec.document_type = 'ORDER' THEN
                 OPEN c_get_order_currency(p_adj_rec.document_number);
                 FETCH c_get_order_currency INTO l_document_curr;
                 CLOSE c_get_order_currency;
              ELSIF p_adj_rec.document_type = 'TP_ORDER' THEN
                 OPEN c_get_tp_order_currency(p_adj_rec.document_number);
                 FETCH c_get_tp_order_currency INTO l_document_curr;
                 CLOSE c_get_tp_order_currency;
              ELSIF p_adj_rec.document_type = 'INVOICE' THEN
                 OPEN c_get_txn_currency(p_adj_rec.document_number);
                 FETCH c_get_txn_currency INTO l_document_curr;
                 CLOSE c_get_txn_currency;
              ELSIF p_adj_rec.document_type = 'PCHO' THEN
                 OPEN c_get_pcho_currency(p_adj_rec.document_number);
                 FETCH c_get_pcho_currency INTO l_document_curr;
                 CLOSE c_get_pcho_currency;
              END IF;
           END IF;
         ELSE
           OPEN c_get_header_id(p_adj_rec.order_line_id);
           FETCH c_get_header_id INTO l_document_curr;
           CLOSE c_get_header_id;
         END IF;
      ELSE
        l_document_curr := l_offer_currency.fund_request_curr_code;
      END IF; --end of IF p_adj_rec.adjustment_type NOT IN ( 'DECREASE_COMMITTED')
   ELSE
      l_document_curr := l_offer_currency.fund_request_curr_code;
   END IF; --end of IF l_offer_currency.transaction_currency_code
ELSIF p_adj_rec.activity_type = 'CAMP' THEN
   OPEN c_get_camp_currency(p_adj_rec.activity_id);
   FETCH c_get_camp_currency INTO l_document_curr;
   CLOSE c_get_camp_currency;
ELSIF p_adj_rec.activity_type = 'CSCH' THEN
   OPEN c_get_csch_currency(p_adj_rec.activity_id);
   FETCH c_get_csch_currency INTO l_document_curr;
   CLOSE c_get_csch_currency;
ELSIF p_adj_rec.activity_type = 'DELV' THEN
   OPEN c_get_delv_currency(p_adj_rec.activity_id);
   FETCH c_get_delv_currency INTO l_document_curr;
   CLOSE c_get_delv_currency;
ELSIF p_adj_rec.activity_type = 'EVEH' THEN
   OPEN c_get_eveh_currency(p_adj_rec.activity_id);
   FETCH c_get_eveh_currency INTO l_document_curr;
   CLOSE c_get_eveh_currency;
ELSIF p_adj_rec.activity_type = 'EVEO' OR p_adj_rec.activity_type = 'EONE' THEN
   OPEN c_get_eveo_currency(p_adj_rec.activity_id);
   FETCH c_get_eveo_currency INTO l_document_curr;
   CLOSE c_get_eveo_currency;
END IF; -- IF p_adj_rec.activity_type = 'OFFR' THEN


IF p_adj_rec.plan_currency_code IS NULL OR p_adj_rec.plan_currency_code = fnd_api.g_miss_char THEN
   p_adj_rec.plan_currency_code := l_document_curr;
ELSE
   IF l_document_curr <> p_adj_rec.plan_currency_code THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('OZF', 'OZF_INVALID_PLAN_CURR_CODE');
         fnd_msg_pub.add;
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      RETURN;
   END IF;
END IF;
--end ER 8399134 code changes
END Validate_Items;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Fund_Adjustment
--
-- PURPOSE
--    Create fund adjustment.
--
-- PARAMETERS
--    p_adj_rec: the new record to be inserted
--
-- HISTORY
--    04/05/2005  kdass         Created
--    03/14/2008  psomyaju      ER-6858324
---------------------------------------------------------------------
PROCEDURE Create_Fund_Adjustment(
   p_api_version        IN              NUMBER
  ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
  ,p_commit             IN              VARCHAR2 := fnd_api.g_false
  ,p_validation_level   IN              NUMBER := fnd_api.g_valid_level_full
  ,p_adj_rec            IN              OZF_FUND_UTILIZED_PUB.adjustment_rec_type
  ,x_return_status      OUT NOCOPY      VARCHAR2
  ,x_msg_count          OUT NOCOPY      NUMBER
  ,x_msg_data           OUT NOCOPY      VARCHAR2
  )
IS
l_api_name              VARCHAR(30) := 'Create_Fund_Adjustment';
l_act_budgets_rec       ozf_actbudgets_pvt.act_budgets_rec_type;
l_act_util_rec          ozf_actbudgets_pvt.act_util_rec_type;
l_act_budget_util_rec   ozf_actbudgets_pvt.act_budgets_rec_type;
l_parent_src_tbl        ozf_fund_adjustment_pvt.parent_src_tbl_type;
l_accrual_flag          NUMBER := 0;
l_adj_type_id           NUMBER;
l_flagDecCommitted      BOOLEAN := TRUE; -- flag for adjustment type DECREASE_COMM_EARNED
l_adj_rec               OZF_FUND_UTILIZED_PUB.adjustment_rec_type := p_adj_rec;
l_api_version           NUMBER := p_api_version;
l_init_msg_list         VARCHAR2(100) := p_init_msg_list;
l_validation_level      NUMBER := p_validation_level;
l_act_budget_id         NUMBER;
l_utilized_amount       NUMBER;
l_fund_id               NUMBER;
l_gl_posted_flag        VARCHAR2(1);
l_rate                    NUMBER;

CURSOR c_fund_type (p_fund_id IN NUMBER) IS
   SELECT 1 FROM ozf_funds_all_b
   WHERE fund_id = p_fund_id
     AND fund_type = 'FULLY_ACCRUED'
     AND accrual_basis= 'CUSTOMER'
     AND liability_flag= 'Y';

/* 07-APR-09 kdass bug 8402334
CURSOR c_org_order (p_doc_number IN NUMBER) IS
   SELECT org_id
   FROM  oe_order_headers_all
   WHERE header_id = p_doc_number;

CURSOR c_org_fund (p_fund_id IN NUMBER) IS
   SELECT org_id
   FROM  ozf_funds_all_b
   WHERE fund_id = p_fund_id;
*/

CURSOR c_orig_util_id (p_activity_id IN NUMBER, p_activity_type IN VARCHAR2,
            p_fund_id IN NUMBER, p_product_id IN NUMBER, p_cust_acct_id IN NUMBER) IS
   SELECT utilization_id, NVL(gl_posted_flag,'N')
   FROM  ozf_funds_utilized_all_b
   WHERE plan_id = p_activity_id
     AND plan_type = p_activity_type
     AND fund_id = p_fund_id
     AND NVL(product_id,0) = NVL(p_product_id,0)
     AND NVL(cust_account_id,0) = NVL(p_cust_acct_id,0)
     AND utilization_type NOT IN ('REQUEST', 'TRANSFER');

CURSOR c_get_fund_currency(p_fund_id IN NUMBER, p_budget_source_id IN NUMBER,
          p_budget_source_type VARCHAR2) IS
   SELECT fund_currency
   FROM ozf_object_fund_summary
   WHERE fund_id = p_fund_id
   AND object_id = p_budget_source_id
   AND object_type = p_budget_source_type;

CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
  SELECT exchange_rate_type
  FROM   ozf_sys_parameters_all
  WHERE  org_id = p_org_id;


l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;
--nirprasa,ER 8399134
BEGIN
   SAVEPOINT Create_Fund_Adjustment;

   validate_items(p_adj_rec       => l_adj_rec
                 ,x_return_status => x_return_status);
      --nirprasa,ER 8399134 decide on plan_currency_code


   /*fund_id is mandatory now. In R12 fund_id is optional but currency_code is mandatory.
     Hence the fails if offer has multiple budgets because there is no provision of
     passing currency for all budgets sourced by the offer.*/

      --ER 8399134 Since fund_id is passed, validate_items() defaults the currency_code
      --if it is not passed. If currency_code is passed then validate it.
      --If plan_amount is passed then ignore amount column.
      IF l_adj_rec.plan_amount IS NOT NULL OR l_adj_rec.plan_amount <> fnd_api.g_miss_num THEN
         l_adj_rec.amount := NULL;
         l_act_budgets_rec.request_amount :=  l_adj_rec.plan_amount;
      END IF;


      l_act_util_rec.plan_currency_code := l_adj_rec.plan_currency_code;
      l_act_budgets_rec.request_currency := l_act_util_rec.plan_currency_code;


   /* 07-APR-09 kdass bug 8402334
   IF l_adj_rec.org_id = fnd_api.g_miss_num OR l_adj_rec.org_id IS NULL THEN
      IF l_adj_rec.document_type = 'ORDER' THEN
         OPEN c_org_order (l_adj_rec.document_number);
         FETCH c_org_order INTO l_adj_rec.org_id;
         CLOSE c_org_order;
      ELSE
         OPEN c_org_fund (NVL(l_adj_rec.fund_id,l_fund_id));
         FETCH c_org_fund INTO l_adj_rec.org_id;
         CLOSE c_org_fund;
      END IF;
   END IF;
   */

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   l_act_util_rec.adjustment_type_id := l_adj_rec.adjustment_type_id;
   l_act_util_rec.adjustment_type := l_adj_rec.adjustment_type;
   l_act_util_rec.adjustment_date := l_adj_rec.adjustment_date;
   l_act_util_rec.gl_date := l_adj_rec.gl_date;
   l_act_util_rec.gl_account_credit := l_adj_rec.gl_account_credit;
   l_act_util_rec.gl_account_debit := l_adj_rec.gl_account_debit;
   l_act_util_rec.camp_schedule_id := l_adj_rec.camp_schedule_id;
   l_act_util_rec.object_type := l_adj_rec.document_type;
   l_act_util_rec.object_id := l_adj_rec.document_number;
   l_act_util_rec.product_level_type := l_adj_rec.product_level_type;
   l_act_util_rec.product_id := l_adj_rec.product_id;
   l_act_util_rec.cust_account_id := l_adj_rec.cust_account_id;
   l_act_util_rec.bill_to_site_use_id := l_adj_rec.bill_to_site_use_id;
   l_act_util_rec.ship_to_site_use_id := l_adj_rec.ship_to_site_use_id;
   l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_ADJ_PUB_API');
   l_act_budgets_rec.budget_source_type := l_adj_rec.activity_type;
   l_act_budgets_rec.budget_source_id := l_adj_rec.activity_id;
   l_act_budgets_rec.transaction_type := 'DEBIT';
   l_act_budgets_rec.status_code := 'APPROVED';
   l_act_budgets_rec.approver_id :=  l_adj_rec.approver_id;
   --ER 9382547
   --g_skip_acct_gen_flag := l_adj_rec.skip_acct_gen_flag;

   l_act_budgets_rec.exchange_rate_date     := l_adj_rec.exchange_rate_date; --bug 8532055
   l_act_budget_util_rec.exchange_rate_date := l_adj_rec.exchange_rate_date; --bug 8532055

   --DFFs/order_line_id added for ER-6858324
   l_act_util_rec.order_line_id         := l_adj_rec.order_line_id;
   l_act_util_rec.attribute_category    := l_adj_rec.attribute_category;
   l_act_util_rec.attribute1            := l_adj_rec.attribute1;
   l_act_util_rec.attribute2            := l_adj_rec.attribute2;
   l_act_util_rec.attribute3            := l_adj_rec.attribute3;
   l_act_util_rec.attribute4            := l_adj_rec.attribute4;
   l_act_util_rec.attribute5            := l_adj_rec.attribute5;
   l_act_util_rec.attribute6            := l_adj_rec.attribute6;
   l_act_util_rec.attribute7            := l_adj_rec.attribute7;
   l_act_util_rec.attribute8            := l_adj_rec.attribute8;
   l_act_util_rec.attribute9            := l_adj_rec.attribute9;
   l_act_util_rec.attribute10           := l_adj_rec.attribute10;
   l_act_util_rec.attribute11           := l_adj_rec.attribute11;
   l_act_util_rec.attribute12           := l_adj_rec.attribute12;
   l_act_util_rec.attribute13           := l_adj_rec.attribute13;
   l_act_util_rec.attribute14           := l_adj_rec.attribute14;
   l_act_util_rec.attribute15           := l_adj_rec.attribute15;

   --07-APR-09 kdass bug 8402334 - add OU to the adjustment record
   l_act_util_rec.org_id                := l_adj_rec.org_id;

   -- if adjustment type is 'Decrease Committed and Earned Amounts'
   IF l_act_util_rec.adjustment_type = 'DECREASE_COMM_EARNED' THEN
      l_act_budgets_rec.transfer_type := 'TRANSFER';
      l_act_budgets_rec.act_budget_used_by_id := l_adj_rec.fund_id;
      l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
      l_act_budget_util_rec.justification := l_act_budgets_rec.justification;
      l_act_budget_util_rec.budget_source_type := l_act_budgets_rec.budget_source_type;
      l_act_budget_util_rec.budget_source_id := l_act_budgets_rec.budget_source_id;
      l_act_budget_util_rec.transaction_type := l_act_budgets_rec.transaction_type;
      l_act_budget_util_rec.request_currency := l_act_budgets_rec.request_currency;
      l_act_budget_util_rec.request_amount := l_act_budgets_rec.request_amount;
      l_act_budget_util_rec.status_code := l_act_budgets_rec.status_code;
      l_act_budget_util_rec.approver_id := l_act_budgets_rec.approver_id;
      l_act_budget_util_rec.transfer_type := 'UTILIZED';
      l_act_budget_util_rec.act_budget_used_by_id := l_act_budgets_rec.budget_source_id;
      l_act_budget_util_rec.arc_act_budget_used_by := l_act_budgets_rec.budget_source_type;
      l_act_util_rec.utilization_type := 'ADJUSTMENT';
      l_act_budget_util_rec.parent_source_id := l_adj_rec.fund_id;
      --nirprasa,ER 8399134
      --l_act_budget_util_rec.parent_src_curr := l_act_budgets_rec.request_currency;
      --l_act_budget_util_rec.parent_src_apprvd_amt := l_act_budgets_rec.request_amount;
      l_act_budget_util_rec.parent_src_curr := l_adj_rec.currency_code;
      l_act_budget_util_rec.parent_src_apprvd_amt := l_adj_rec.amount;

      -- for customer fully accrual budget with liability flag on, do not decrease committed in java,
      -- instead let pl/sql api handle it along with other cases
      OPEN c_fund_type(l_adj_rec.fund_id);
      FETCH c_fund_type INTO l_accrual_flag;
      CLOSE c_fund_type;

      IF l_accrual_flag = 1 THEN
         l_flagDecCommitted := FALSE;
      END IF;

      IF l_adj_rec.fund_id IS NOT NULL THEN

         ozf_fund_utilized_pvt.create_act_utilization(p_api_version       => l_api_version
                                                     ,p_init_msg_list     => l_init_msg_list
                                                     ,p_validation_level  => l_validation_level
                                                     ,x_return_status     => x_return_status
                                                     ,x_msg_count         => x_msg_count
                                                     ,x_msg_data          => x_msg_data
                                                     ,p_act_budgets_rec   => l_act_budget_util_rec
                                                     ,p_act_util_rec      => l_act_util_rec
                                                     ,x_act_budget_id     => l_act_budget_id
                                                     );
       --ER 8399134 This will be used to created dec comm record.
      l_act_budgets_rec.request_currency := l_adj_rec.currency_code;
      l_act_budgets_rec.request_amount := l_adj_rec.amount;

      IF l_adj_rec.plan_amount IS NOT NULL OR l_adj_rec.plan_amount <> FND_API.G_MISS_NUM THEN
         l_act_budgets_rec.src_curr_req_amt := l_adj_rec.plan_amount;
      END IF;

      /*OPEN c_offer_currency(l_adj_rec.activity_id);
      FETCH c_offer_currency INTO l_offer_currency;
      CLOSE c_offer_currency;

      IF l_offer_currency.transaction_currency_code IS NULL
      OR l_offer_currency.transaction_currency_code = FND_API.G_MISS_CHAR THEN
         IF  l_adj_rec.plan_currency_code <> l_offer_currency.fund_request_curr_code THEN
             ozf_utility_pvt.convert_currency (
                               x_return_status => x_return_status
                              ,p_from_currency => l_adj_rec.plan_currency_code
                              ,p_to_currency   => l_offer_currency.fund_request_curr_code
                              ,p_from_amount   => l_adj_rec.plan_amount
                              ,x_to_amount     => l_conv_plan_amount
                              ,x_rate          => l_rate
                               );
            l_adj_rec.plan_amount := l_conv_plan_amount;
         END IF;
         l_adj_rec.plan_currency_code := l_offer_currency.fund_request_curr_code;
      END IF;*/

       --nirprasa, ER 8399134 remove this code, since fund_id is mandatory now.
      /*ELSE --if fund id is null, then post proportionately to the budgets which the offer is sourcing from
         FOR i IN NVL (l_parent_src_tbl.FIRST, 1) .. NVL (l_parent_src_tbl.LAST, 0)
         LOOP
            --nirprasa,ER 8399134 change the assignments as the modified private API.
            l_act_budgets_rec.act_budget_used_by_id := l_parent_src_tbl (i).fund_id;
            l_act_budget_util_rec.request_currency := l_act_util_rec.plan_currency_code;
            l_act_budget_util_rec.request_amount := l_parent_src_tbl (i).plan_amount;
            l_act_budget_util_rec.parent_source_id := l_parent_src_tbl (i).fund_id;
            l_act_budget_util_rec.parent_src_curr := l_parent_src_tbl (i).fund_curr;
            l_act_budget_util_rec.parent_src_apprvd_amt := l_parent_src_tbl (i).fund_amount;

            ozf_fund_utilized_pvt.create_act_utilization(p_api_version       => l_api_version
                                                        ,p_init_msg_list     => l_init_msg_list
                                                        ,p_validation_level  => l_validation_level
                                                        ,x_return_status     => x_return_status
                                                        ,x_msg_count         => x_msg_count
                                                        ,x_msg_data          => x_msg_data
                                                        ,p_act_budgets_rec   => l_act_budget_util_rec
                                                        ,p_act_util_rec      => l_act_util_rec
                                                        ,x_act_budget_id     => l_act_budget_id
                                                        );
         END LOOP;*/

      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.g_exc_unexpected_error;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      --reset utilization_type for decrease committed amount
      l_act_util_rec.utilization_type := NULL;

   -- if adjustment type is 'Decrease Committed Amount'
   ELSIF l_act_util_rec.adjustment_type = 'DECREASE_COMMITTED' THEN
      l_act_util_rec.utilization_type := null;
      l_act_budgets_rec.transfer_type := 'TRANSFER';
      l_act_budgets_rec.act_budget_used_by_id := l_adj_rec.fund_id;
      l_act_budgets_rec.arc_act_budget_used_by := 'FUND';
      --nirprasa,ER 8399134
      l_act_budgets_rec.request_currency := l_adj_rec.currency_code;
      l_act_budgets_rec.request_amount := l_adj_rec.amount;
      IF l_adj_rec.plan_amount IS NOT NULL AND l_adj_rec.plan_amount <> FND_API.G_MISS_NUM THEN
         l_act_budgets_rec.src_curr_req_amt := l_adj_rec.plan_amount;
      END IF;

   -- if adjustment type is 'Increase Earned Amount' (STANDARD) or 'Decrease Earned Amount' (DECREASE_EARNED)
   -- or 'Increase Paid Amount' (INCREASE_PAID) or 'Decrease Paid Amount' (DECREASE_PAID)
   ELSE
      l_act_budgets_rec.transfer_type := 'UTILIZED';
      l_act_budgets_rec.act_budget_used_by_id := l_act_budgets_rec.budget_source_id;
      l_act_budgets_rec.arc_act_budget_used_by := l_act_budgets_rec.budget_source_type;
      l_act_util_rec.utilization_type := 'ADJUSTMENT';
      l_act_util_rec.scan_type_id := l_adj_rec.scan_type_id;
      l_act_budgets_rec.parent_source_id := l_adj_rec.fund_id;
      --nirprasa,ER 8399134
      l_act_budgets_rec.parent_src_curr := l_adj_rec.currency_code;
      l_act_budgets_rec.parent_src_apprvd_amt := l_adj_rec.amount;
      --l_act_util_rec.orig_utilization_id := l_adj_rec.orig_utilization_id;
   END IF;

   --for all adjustment types
   IF (l_flagDecCommitted) THEN

      IF l_adj_rec.fund_id IS NOT NULL THEN
         IF l_act_util_rec.adjustment_type NOT IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
            ozf_fund_utilized_pvt.create_act_utilization(p_api_version      => l_api_version
                                                        ,p_init_msg_list    => l_init_msg_list
                                                        ,p_validation_level => l_validation_level
                                                        ,x_return_status    => x_return_status
                                                        ,x_msg_count        => x_msg_count
                                                        ,x_msg_data         => x_msg_data
                                                        ,p_act_budgets_rec  => l_act_budgets_rec
                                                        ,p_act_util_rec     => l_act_util_rec
                                                        ,x_act_budget_id    => l_act_budget_id
                                                        );
         ELSE

            --get the original utilization id
            OPEN c_orig_util_id (l_adj_rec.activity_id, l_adj_rec.activity_type, l_adj_rec.fund_id,
                                 l_adj_rec.product_id, l_adj_rec.cust_account_id);
            FETCH c_orig_util_id INTO l_act_util_rec.orig_utilization_id, l_gl_posted_flag;
            CLOSE c_orig_util_id;

            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message('orig_utilization_id: ' || l_act_util_rec.orig_utilization_id);
               ozf_utility_pvt.debug_message('activity_id: ' || l_adj_rec.activity_id);
               ozf_utility_pvt.debug_message('activity_type: ' || l_adj_rec.activity_type);
               ozf_utility_pvt.debug_message('fund_id: ' || l_adj_rec.fund_id);
               ozf_utility_pvt.debug_message('product_id: ' || l_adj_rec.product_id);
               ozf_utility_pvt.debug_message('cust_account_id: ' || l_adj_rec.cust_account_id);
            END IF;

            IF l_act_util_rec.orig_utilization_id IS NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_NO_ORIG_UTIL_ID');
                  fnd_msg_pub.add;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            --if the original utilization is not posted to GL(e.g. marketing cost, or off invoice offer
            --where gl posting is not required), then paid adjustment should not be allowed.
            IF l_gl_posted_flag <> 'Y' THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name('OZF', 'OZF_ADJ_PAID_NOT_ALLOWED');
                  fnd_msg_pub.add;
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

            IF l_act_util_rec.adjustment_type = 'DECREASE_PAID' THEN
               l_act_budgets_rec.parent_src_apprvd_amt := - l_act_budgets_rec.parent_src_apprvd_amt;
               l_act_budgets_rec.request_amount := - l_act_budgets_rec.request_amount;
            END IF;

            --kdass fixed bug 9432297
            l_act_util_rec.fund_request_currency_code := OZF_ACTBUDGETS_PVT.get_object_currency (
                                                                l_act_budgets_rec.arc_act_budget_used_by
                                                               ,l_act_budgets_rec.act_budget_used_by_id
                                                               ,x_return_status
                                                               );

            IF l_act_budgets_rec.request_amount IS NOT NULL THEN
            IF ((l_act_budgets_rec.parent_src_apprvd_amt IS NULL
                   OR l_act_budgets_rec.parent_src_apprvd_amt = fnd_api.g_miss_num)
                   AND l_act_budgets_rec.request_currency <> l_act_budgets_rec.parent_src_curr) THEN

                 ozf_utility_pvt.convert_currency (
                  x_return_status=> x_return_status
                 ,p_from_currency=> l_act_budgets_rec.request_currency
                 ,p_to_currency=> l_act_budgets_rec.parent_src_curr
                 ,p_conv_type=>l_exchange_rate_type --Added for bug 7030415
                 ,p_from_amount=> l_act_budgets_rec.request_amount
                 ,x_to_amount=> l_act_budgets_rec.parent_src_apprvd_amt
                 ,x_rate=> l_rate
                 );

               IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               l_act_budgets_rec.parent_src_apprvd_amt := l_act_budgets_rec.request_amount;
            END IF;
         ELSIF l_act_budgets_rec.parent_src_apprvd_amt IS NOT NULL  THEN
             IF l_act_budgets_rec.request_currency <> l_act_budgets_rec.parent_src_curr
               AND (l_act_budgets_rec.request_amount IS NULL
                   OR l_act_budgets_rec.request_amount = fnd_api.g_miss_num) THEN
                      --nirprasa,ER 8399134
                         ozf_utility_pvt.convert_currency (
                          x_return_status=> x_return_status
                         ,p_from_currency=> l_act_budgets_rec.parent_src_curr
                         ,p_to_currency=> l_act_budgets_rec.request_currency
                         ,p_conv_type=>l_exchange_rate_type --Added for bug 7030415
                         ,p_conv_date     => l_act_budgets_rec.exchange_rate_date --bug 8532055
                         ,p_from_amount=> l_act_budgets_rec.parent_src_apprvd_amt
                         ,x_to_amount=> l_act_budgets_rec.request_amount
                         ,x_rate=> l_rate
                         );
                       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                          RAISE fnd_api.g_exc_unexpected_error;
                       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
                          RAISE fnd_api.g_exc_error;
                       END IF;
             ELSE
                l_act_budgets_rec.request_amount := l_act_budgets_rec.parent_src_apprvd_amt;
             END IF;
         END IF;

            ozf_fund_adjustment_pvt.create_fund_utilization(p_act_budget_rec  => l_act_budgets_rec
                                                           ,x_return_status   => x_return_status
                                                           ,x_msg_count       => x_msg_count
                                                           ,x_msg_data        => x_msg_data
                                                           ,p_act_util_rec    => l_act_util_rec
                                                           ,x_utilized_amount => l_utilized_amount
                                                           );
         END IF;
       --nirprasa, ER 8399134 remove this code, since fund_id is mandatory now.
      /*ELSE --if fund id is null, then post proportionately to the budgets which the offer is sourcing from

         FOR i IN NVL (l_parent_src_tbl.FIRST, 1) .. NVL (l_parent_src_tbl.LAST, 0)
         LOOP
            --nirprasa,12.2 changed the assignments
            l_act_budgets_rec.request_currency := l_act_util_rec.plan_currency_code;
            l_act_budgets_rec.request_amount := l_parent_src_tbl (i).plan_amount;

            IF l_adj_rec.adjustment_type IN ('DECREASE_COMM_EARNED', 'DECREASE_COMMITTED') THEN
               l_act_budgets_rec.act_budget_used_by_id := l_parent_src_tbl (i).fund_id;
            ELSE
               l_act_budgets_rec.parent_src_curr := l_parent_src_tbl (i).fund_curr;
               l_act_budgets_rec.parent_src_apprvd_amt := l_parent_src_tbl (i).fund_amount;
               l_act_budgets_rec.parent_source_id := l_parent_src_tbl (i).fund_id;
            END IF;

            IF l_act_util_rec.adjustment_type NOT IN ('INCREASE_PAID', 'DECREASE_PAID') THEN

               ozf_fund_utilized_pvt.create_act_utilization(p_api_version      => l_api_version
                                                           ,p_init_msg_list    => l_init_msg_list
                                                           ,p_validation_level => l_validation_level
                                                           ,x_return_status    => x_return_status
                                                           ,x_msg_count        => x_msg_count
                                                           ,x_msg_data         => x_msg_data
                                                           ,p_act_budgets_rec  => l_act_budgets_rec
                                                           ,p_act_util_rec     => l_act_util_rec
                                                           ,x_act_budget_id    => l_act_budget_id
                                                           );
            ELSE

               --get the original utilization id
               OPEN c_orig_util_id (l_adj_rec.activity_id, l_adj_rec.activity_type, l_parent_src_tbl (i).fund_id,
                                    l_adj_rec.product_id, l_adj_rec.cust_account_id);
               FETCH c_orig_util_id INTO l_act_util_rec.orig_utilization_id, l_gl_posted_flag;
               CLOSE c_orig_util_id;

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message('orig_utilization_id: ' || l_act_util_rec.orig_utilization_id);
                  ozf_utility_pvt.debug_message('activity_id: ' || l_adj_rec.activity_id);
                  ozf_utility_pvt.debug_message('activity_type: ' || l_adj_rec.activity_type);
                  ozf_utility_pvt.debug_message('fund_id: ' || l_parent_src_tbl (i).fund_id);
                  ozf_utility_pvt.debug_message('product_id: ' || l_adj_rec.product_id);
                  ozf_utility_pvt.debug_message('cust_account_id: ' || l_adj_rec.cust_account_id);
               END IF;

               IF l_act_util_rec.orig_utilization_id IS NULL THEN
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name('OZF', 'OZF_NO_ORIG_UTIL_ID');
                     fnd_msg_pub.add;
                  END IF;
                  RAISE fnd_api.g_exc_error;
               END IF;

               --if the original utilization is not posted to GL(e.g. marketing cost, or off invoice offer
               --where gl posting is not required), then paid adjustment should not be allowed.
               IF l_gl_posted_flag <> 'Y' THEN
                  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name('OZF', 'OZF_ADJ_PAID_NOT_ALLOWED');
                     fnd_msg_pub.add;
                  END IF;
                  RAISE fnd_api.g_exc_error;
               END IF;

               IF l_act_util_rec.adjustment_type = 'DECREASE_PAID' THEN
                  l_act_budgets_rec.parent_src_apprvd_amt := - l_act_budgets_rec.parent_src_apprvd_amt;
                  l_act_budgets_rec.request_amount := - l_act_budgets_rec.request_amount;
               END IF;

               ozf_fund_adjustment_pvt.create_fund_utilization(p_act_budget_rec  => l_act_budgets_rec
                                                              ,x_return_status   => x_return_status
                                                              ,x_msg_count       => x_msg_count
                                                              ,x_msg_data        => x_msg_data
                                                              ,p_act_util_rec    => l_act_util_rec
                                                              ,x_utilized_amount => l_utilized_amount
                                                              );
            END IF;
         END LOOP;*/
      END IF;

   END IF;

   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
   END IF;

   FND_MSG_PUB.Count_And_Get (
    p_encoded => FND_API.G_FALSE,
    p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Create_Fund_Adjustment;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data  => x_msg_data
                            );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Create_Fund_Adjustment;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data  => x_msg_data
                            );
WHEN OTHERS THEN
   ROLLBACK TO Create_Fund_Adjustment;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                            ,p_count   => x_msg_count
                            ,p_data  => x_msg_data
                            );
END Create_Fund_Adjustment;
--------------------------------------------------------------------

END OZF_FUND_UTILIZED_PUB;

/
