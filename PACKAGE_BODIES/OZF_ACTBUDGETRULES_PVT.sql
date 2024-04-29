--------------------------------------------------------
--  DDL for Package Body OZF_ACTBUDGETRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACTBUDGETRULES_PVT" AS
/*$Header: ozfvarub.pls 120.6.12010000.4 2010/02/17 08:19:24 nepanda ship $*/
   -- NAME
   --   OZF_ACTBUDGETRULES_PVT
   --
   -- HISTORY
   -- 04/16/2000  feliu    created by separated from ozf_actbudgets_pvt.
   -- 5/10/2002   mpande   Updated can_plan_more_budget function
   -- 11/23/2005  kdass    fixed bug 4658021
   -- 12/08/2005  kdass    Bug 4870218 - sql repository fix SQL ID 14892411
   -- 14/04/2008  psomyaju Bug 6654242 - FP:11510-R12 6495406: ORACLE ERROR -01400 WHEN
   --                                    ATTEMPTING TO RECONCILE ACCRUAL O
   -- 01/15/2009  nirprasa fixed bug 7697861.

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_cat_activity_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   Category and activity  should match for the budget and the campaign or schedule
-- 06/08/2005 kdass    Bug 4415878 SQL Repository Fix
-- 2/17/2010  nepanda  Bug 9131648 : multi currency changes
/*****************************************************************************************/
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

PROCEDURE check_cat_activity_match (
      p_used_by_id         IN       NUMBER
     ,p_used_by_type       IN       VARCHAR2
     ,p_budget_source_id   IN       NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_get_activity_id (p_used_by_id IN NUMBER) IS
         SELECT activity_id
           FROM ams_campaign_schedules_b
          WHERE schedule_id = p_used_by_id;
      -- 03/28/2002 added for Offer
      CURSOR c_get_off_activity_id (p_used_by_id IN NUMBER) IS
         SELECT activity_media_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_used_by_id;

      CURSOR c_get_cat_activity (p_category_id IN NUMBER, p_activity_id IN NUMBER) IS
         SELECT 'X'
           FROM ams_cat_activities
          WHERE category_id = p_category_id
            AND activity_id = p_activity_id;

      CURSOR c_cat_activity_count (p_category_id IN NUMBER) IS
         SELECT COUNT(cat_activity_id) count
           FROM ams_cat_activities
          WHERE category_id = p_category_id;

      CURSOR c_get_category_id (p_budget_source_id IN NUMBER) IS
         SELECT category_id
           FROM ozf_funds_all_b
          WHERE fund_id = p_budget_source_id;

      l_activity_id   NUMBER;
      l_category_id   NUMBER;
      l_dummy         VARCHAR2 (3);
      l_cat_act_count  NUMBER;

   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      OPEN c_get_category_id (p_budget_source_id);
      FETCH c_get_category_id INTO l_category_id;
      CLOSE c_get_category_id;
      -- check if category has a record in ams_cat_activities table
      OPEN c_cat_activity_count (l_category_id);
      FETCH c_cat_activity_count INTO l_cat_act_count;
      CLOSE c_cat_activity_count;
      -- if cat activity association is there then match for the activity id
      IF l_cat_act_count <> 0 THEN
         IF p_used_by_type = 'CSCH' THEN
            OPEN c_get_activity_id (p_used_by_id);
            FETCH c_get_activity_id INTO l_activity_id;
            CLOSE c_get_activity_id;
         ELSIF p_used_by_type = 'OFFR' THEN
            OPEN c_get_off_activity_id (p_used_by_id);
            FETCH c_get_off_activity_id INTO l_activity_id;
            CLOSE c_get_off_activity_id;
         END IF;

         OPEN c_get_cat_activity (l_category_id, l_activity_id);
         FETCH c_get_cat_activity INTO l_dummy;
         CLOSE c_get_cat_activity;
         IF l_dummy IS NULL THEN
            ozf_utility_pvt.error_message ( 'OZF_CAT_ACTIVITY_MISMATCH');
            x_return_status            := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
   END check_cat_activity_match;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_transfer_amount_exists
-- PARAMETERS
--   p_object_id           IN       NUMBER -- in case of transfer it is the budget_source_id
--  ,p_object_type         IN       VARCHAR2
--  ,p_budget_source_id     IN       NUMBER
--  ,p_budget_source_type   IN       VARCHAR2

   -- PURPOSE
   --   This procedure is to validate budget record
   --
   -- NOTES
   -- HISTORY
   -- 04/10/2001 mpande   Cannot tranfer to a budget if he does not have it from that particular budget
   -- 08/05/2005 feliu    modified for R12.
/*****************************************************************************************/
   PROCEDURE check_transfer_amount_exists (
      p_object_id            IN       NUMBER
     ,p_object_type          IN       VARCHAR2
     ,p_budget_source_id     IN       NUMBER
     ,p_budget_source_type   IN       VARCHAR2
     ,p_transfer_amt         IN       NUMBER
     ,p_transfer_type        IN       VARCHAR2
     ,x_return_status        OUT NOCOPY      VARCHAR2
   ) IS
      -- for TRANSFER type, check for individual budget.
      CURSOR c_transfer_allowed IS
        /*
        SELECT (NVL(plan_curr_committed_amt,0)-NVL(plan_curr_utilized_amt,0)) total_amount
        FROM ozf_object_fund_summary
        WHERE object_id =p_object_id
        AND object_type = p_object_type
        AND fund_id = p_budget_source_id;
*/
       SELECT   SUM (amount) total_amount
       FROM(
              SELECT   --- request amount
              NVL (SUM (a1.approved_amount), 0) amount
              FROM ozf_act_budgets a1
              WHERE a1.act_budget_used_by_id = p_object_id
              AND a1.arc_act_budget_used_by = p_object_type
              AND a1.budget_source_type = 'FUND'
              AND a1.budget_source_id  = p_budget_source_id
              AND a1.status_code = 'APPROVED'
              AND a1.transfer_type ='REQUEST'
              UNION
              SELECT   -NVL (SUM (a2.approved_original_amount), 0) amount
              FROM ozf_act_budgets a2
              WHERE a2.budget_source_id = p_object_id
              AND a2.budget_source_type = p_object_type
              AND a2.act_budget_used_by_id = p_budget_source_id
              AND a2.arc_act_budget_used_by = 'FUND'
              AND a2.status_code = 'APPROVED'
              AND a2.transfer_type = 'TRANSFER'
              UNION
              SELECT SUM(fund_request_amount) amount --nirprasa,12.2 ER 8399134 replace plan_curr_amount
              FROM ozf_funds_utilized_all_b
              where plan_type = p_object_type
              and plan_id = p_object_id
              and fund_id = p_budget_source_id);


      -- for UTILIZED type, check for total committed amount.
      CURSOR c_transfer_allowed_util IS
        SELECT SUM(NVL(plan_curr_committed_amt,0)-NVL(plan_curr_utilized_amt,0)) total_amount
        FROM ozf_object_fund_summary
        WHERE object_id =p_object_id
        AND object_type = p_object_type;

      /*
         SELECT   parent_source, parent_curr, SUM (amount) total_amount
             FROM (SELECT   a1.fund_id parent_source, a1.currency_code parent_curr
                           ,NVL (SUM (a1.amount), 0) amount
                       FROM ozf_funds_utilized_all_b a1
                      WHERE a1.component_id = p_budget_source_id
                        AND a1.component_type = p_budget_source_type
--                        AND a1.status_code = 'APPROVED' -- only approved record are present here
                        AND a1.utilization_type IN ('TRANSFER', 'REQUEST')
                        AND a1.fund_id = DECODE (p_object_type,'FUND',p_object_id ,  a1.fund_id  )
--                        AND a1.budget_source_type = DECODE (p_object_type, 'FUND', p_object_type, a1.budget_source_type  )
                   GROUP BY a1.fund_id, a1.currency_code
                   UNION
                   SELECT   a2.fund_id parent_source, a2.currency_code parent_curr
                           ,-NVL (SUM (a2.amount), 0) amount
                       FROM ozf_funds_utilized_all_b a2
                      WHERE a2.plan_id = p_budget_source_id
                        AND a2.plan_type = p_budget_source_type
                        -- yzhao: 12/02/2003 11.5.10 added CHARGEBACK
                        AND a2.utilization_type IN ('TRANSFER', 'REQUEST', 'UTILIZED','ADJUSTMENT','ACCRUAL','SALES_ACCRUAL', 'CHARGEBACK')
                        AND a2.fund_id = DECODE (p_object_type,'FUND',p_object_id ,  a2.fund_id )
--                        AND a2.arc_act_budget_used_by = DECODE (p_object_type, 'FUND', p_object_type, a2.arc_act_budget_used_by  )
--                        AND a2.status_code = 'APPROVED' -- -- only approved record are present here
                   GROUP BY a2.fund_id, a2.currency_code)
         GROUP BY parent_source, parent_curr
         ORDER BY parent_source;

      l_parent_src_rec     c_transfer_allowed%ROWTYPE;
      */
      l_existing_amt       NUMBER                       := 0;
      --l_curr               VARCHAR2 (30)                := p_transfer_currency;
      --l_converted_amount   NUMBER                       := 0;
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      IF p_transfer_type ='TRANSFER' THEN
        OPEN c_transfer_allowed;
        FETCH c_transfer_allowed INTO l_existing_amt;
        CLOSE c_transfer_allowed;
    ELSE
        OPEN c_transfer_allowed_util;
        FETCH c_transfer_allowed_util INTO l_existing_amt;
        CLOSE c_transfer_allowed_util;
      END IF;

/*
      LOOP
         FETCH c_transfer_allowed INTO l_parent_src_rec;
         EXIT WHEN c_transfer_allowed%NOTFOUND;

         IF l_curr <> l_parent_src_rec.parent_curr THEN
            ozf_utility_pvt.convert_currency (
               x_return_status=> x_return_status
              ,p_from_currency=> l_parent_src_rec.parent_curr
              ,p_to_currency=> l_curr
              ,p_from_amount=> l_parent_src_rec.total_amount
              ,x_to_amount=> l_converted_amount
            );

            IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSE
            l_converted_amount         := l_parent_src_rec.total_amount;
         END IF;

         l_existing_amt             :=   l_existing_amt
                                       + l_converted_amount;
      END LOOP;
  */

     -- IF p_object_type NOT IN ('FUND','PTNR','PRIC','WKST') THEN
         IF NVL (p_transfer_amt, 0) > NVL (l_existing_amt, 0) THEN
            IF G_DEBUG THEN
            ozf_utility_pvt.debug_message ('p_transfer_amt: ' || p_transfer_amt);
            ozf_utility_pvt.debug_message ('p_transfer_type ' || p_transfer_type);
            ozf_utility_pvt.debug_message ('l_existing_amt: ' || l_existing_amt);
            ozf_utility_pvt.debug_message ('p_object_id: ' || p_object_id);
            ozf_utility_pvt.debug_message ('p_budget_source_id: ' || p_budget_source_id);
            END IF;

            ozf_utility_pvt.error_message ('OZF_TRANSFER_NOT_ALLOWED');
            x_return_status            := fnd_api.g_ret_sts_error;
         END IF;
     -- END IF;

   END check_transfer_amount_exists;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_market_elig_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   MArket Eligibility  should match for the budget and the campaign or schedule or offer
-- 8/7/2002   mpande   commetend
/*****************************************************************************************
   PROCEDURE check_market_elig_match (
      p_used_by_id         IN       NUMBER
     ,p_used_by_type       IN       VARCHAR2
     ,p_budget_source_id   IN       NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_get_market_elig (
         p_used_by_id         IN   NUMBER
        ,p_used_by_type       IN   VARCHAR2
        ,p_budget_source_id   IN   NUMBER
      ) IS
         SELECT 'X'
           FROM ams_act_market_segments mkt1
          WHERE mkt1.arc_act_market_segment_used_by = p_used_by_type
            AND mkt1.act_market_segment_used_by_id = p_used_by_id
            AND mkt1.exclude_flag = 'N'
            AND EXISTS ( SELECT mkt1.market_segment_id
                           FROM ams_act_market_segments mkt2
                          WHERE mkt2.arc_act_market_segment_used_by = 'FUND'
                            AND mkt2.act_market_segment_used_by_id = p_budget_source_id
                            AND mkt2.exclude_flag = 'N');

      /* yzhao: 07/17/2001  check qp_modifiers for offer
      CURSOR c_get_offer_market_elig (
         p_used_by_id         IN   NUMBER
        ,p_budget_source_id   IN   NUMBER
      ) IS
         SELECT 'X'
                   FROM qp_qualifiers qp
          WHERE list_header_id = p_used_by_id
            AND EXISTS ( SELECT 1
                           FROM ams_act_market_segments
                          WHERE arc_act_market_segment_used_by = 'FUND'
                            AND act_market_segment_used_by_id = p_budget_source_id
                            AND exclude_flag = qp.excluder_flag);

      CURSOR c_market_elig_exists (p_budget_source_id IN NUMBER) IS
         SELECT 'X'
           FROM ams_act_market_segments mkt2
          WHERE mkt2.arc_act_market_segment_used_by = 'FUND'
            AND mkt2.act_market_segment_used_by_id = p_budget_source_id;

      l_dummy1   VARCHAR2 (3);
      l_dummy    VARCHAR2 (3);
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      OPEN c_market_elig_exists (p_budget_source_id);
      FETCH c_market_elig_exists INTO l_dummy1;
      CLOSE c_market_elig_exists;
--dbms_output.put_line('yzhao: market eligibility l_dummy1=' || l_dummy1 || ' used_by_type=' || p_used_by_type);

      IF l_dummy1 IS NOT NULL THEN
         /* yzhao: 07/17/2001  for offer check qp_modifiers, for others check ams_act_market_segments
         IF p_used_by_type = 'OFFR' THEN
            OPEN c_get_offer_market_elig (p_used_by_id, p_budget_source_id);
            FETCH c_get_offer_market_elig INTO l_dummy;
            CLOSE c_get_offer_market_elig;
         ELSE
            OPEN c_get_market_elig (p_used_by_id, p_used_by_type, p_budget_source_id);
            FETCH c_get_market_elig INTO l_dummy;
            CLOSE c_get_market_elig;
         END IF;

--dbms_output.put_line('yzhao: market/offer eligibility l_dummy=' || l_dummy);
         IF l_dummy IS NULL THEN
            ozf_utility_pvt.error_message ( 'OZF_MARKET_ELIG_MISMATCH');
            x_return_status            := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
   END check_market_elig_match;


/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   check_product_elig_match
--
-- PURPOSE
--   This procedure is to validate budget record
--
-- NOTES
-- HISTORY
-- 04/10/2001 mpande   Product Eiligibility should match for the budget and the campaign or schedule
-- 8/7/2002 mpande  Commented
/*****************************************************************************************

   PROCEDURE check_prod_elig_match (
      p_used_by_id         IN       NUMBER
     ,p_used_by_type       IN       VARCHAR2
     ,p_budget_source_id   IN       NUMBER
     ,x_return_status      OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_get_product_elig (
         p_used_by_id         IN   NUMBER
        ,p_used_by_type       IN   VARCHAR2
        ,p_budget_source_id   IN   NUMBER
      ) IS
         SELECT 'X'
           FROM ams_act_products pdt1
          WHERE pdt1.arc_act_product_used_by = p_used_by_type
            AND pdt1.act_product_used_by_id = p_used_by_id
            AND pdt1.excluded_flag = 'N'
            AND EXISTS ( SELECT 1
                           FROM ams_act_products pdt2
                          WHERE pdt2.arc_act_product_used_by = 'FUND'
                            AND pdt2.act_product_used_by_id = p_budget_source_id
                            AND pdt2.excluded_flag = 'N');

      CURSOR c_get_offer_product_elig (
         p_used_by_id         IN   NUMBER
        ,p_budget_source_id   IN   NUMBER
      ) IS
         SELECT 'X'
           FROM qp_modifier_summary_v qp
          WHERE list_header_id = p_used_by_id
            AND EXISTS ( SELECT 1
                           FROM ams_act_products
                          WHERE arc_act_product_used_by = 'FUND'
                            AND act_product_used_by_id = p_budget_source_id
                            AND excluded_flag = qp.excluder_flag);

      CURSOR c_product_elig_exists (p_budget_source_id IN NUMBER) IS
         SELECT 'X'
           FROM ams_act_products pdt2
          WHERE pdt2.arc_act_product_used_by = 'FUND'
            AND pdt2.act_product_used_by_id = p_budget_source_id;

      l_dummy1   VARCHAR2 (3);
      l_dummy    VARCHAR2 (3);
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      OPEN c_product_elig_exists (p_budget_source_id);
      FETCH c_product_elig_exists INTO l_dummy1;
      CLOSE c_product_elig_exists;

      IF l_dummy1 IS NOT NULL THEN
         IF p_used_by_type <> 'OFFR' THEN
            OPEN c_get_product_elig (p_used_by_id, p_used_by_type, p_budget_source_id);
            FETCH c_get_product_elig INTO l_dummy;
            CLOSE c_get_product_elig;
         ELSE
            /* yzhao: 07/17/2001  for offer check qp_list_lines, for others check ams_act_products
            OPEN c_get_offer_product_elig (p_used_by_id, p_budget_source_id);
            FETCH c_get_offer_product_elig INTO l_dummy;
            CLOSE c_get_offer_product_elig;
         END IF;

         IF l_dummy IS NULL THEN
            ozf_utility_pvt.error_message ('OZF_PRODUCT_ELIG_MISMATCH');
            x_return_status := fnd_api.g_ret_sts_error;
         END IF;
      END IF;
   END check_prod_elig_match;
*/

/*****************************************************************************************/
-- Start of Comments

   -- NAME
   --    source_has_enough_money
   -- PURPOSE
   --    Return Y if the budget source has enough
   --    money to fund the approved amount for a
   --    budget request; return N, otherwise.
   -- HISTORY
   -- 20-Aug-2000 choang   Created.
   -- 08/05/2005  feliu   changed for R12 by using ozf_object_fund_summary.
/*****************************************************************************************/
   FUNCTION source_has_enough_money (
      p_source_type       IN   VARCHAR2
     ,p_source_id         IN   NUMBER
     ,p_approved_amount   IN   NUMBER
   )
      RETURN VARCHAR2 IS
      l_approved_amount   NUMBER;
/*
      CURSOR c_approved_amount IS
         SELECT NVL (SUM (approved_amount), 0)
           FROM ams_act_budgets
          WHERE arc_act_budget_used_by = p_source_type
            AND act_budget_used_by_id = p_source_id;
  */
      CURSOR c_approved_amount IS
        SELECT SUM(NVL(committed_amt,0)-NVL(utilized_amt,0)) total_amount
        FROM ozf_object_fund_summary
        WHERE object_id =p_source_id
        AND object_type = p_source_type;

-- change by feliu on 03/26/04
/*
      SELECT  SUM (amount) total_amount
             FROM (SELECT   NVL (SUM (a1.amount), 0) amount
                   FROM ozf_funds_utilized_all_b a1
                   WHERE a1.component_id = p_source_id
                   AND a1.component_type = p_source_type
                   AND a1.utilization_type NOT IN
                                           ('ADJUSTMENT',  'UTILIZED')
                   GROUP BY a1.fund_id, a1.currency_code
                   UNION
                   SELECT   -NVL (SUM (a2.amount), 0) amount
                   FROM ozf_funds_utilized_all_b a2
                   WHERE a2.plan_id = p_source_id
                   AND a2.plan_type = p_source_type
                   GROUP BY a2.fund_id, a2.currency_code);
*/

   BEGIN
      OPEN c_approved_amount;
      FETCH c_approved_amount INTO l_approved_amount;
      CLOSE c_approved_amount;

      IF l_approved_amount >= p_approved_amount THEN
         RETURN fnd_api.g_true;
      ELSE
         RETURN fnd_api.g_false;
      END IF;
   END source_has_enough_money;


/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    check_approval_required
   -- PURPOSE
   --    Return T if the budget approval required
   -- HISTORY
   -- 20-Feb-2001 mpande   Created.
/*****************************************************************************************/
   FUNCTION check_approval_required (
      p_object          IN   VARCHAR2
     ,p_object_id       IN   NUMBER
     ,p_source_type     IN   VARCHAR2
     ,p_source_id       IN   NUMBER
     ,p_transfer_type   IN   VARCHAR2
   )
      RETURN VARCHAR2 IS
      CURSOR c_campaign (p_object_id IN NUMBER) IS
         SELECT custom_setup_id, owner_user_id
           FROM ams_campaigns_vl
          WHERE campaign_id = p_object_id;

      CURSOR c_campaign_schl (p_object_id IN NUMBER) IS
         SELECT custom_setup_id, owner_user_id
           FROM ams_campaign_schedules_vl
          WHERE schedule_id = p_object_id;

      CURSOR c_eheader (p_object_id IN NUMBER) IS
         SELECT setup_type_id, owner_user_id
           FROM ams_event_headers_vl
          WHERE event_header_id = p_object_id;

      CURSOR c_eoffer (p_object_id IN NUMBER) IS
         SELECT setup_type_id, owner_user_id
           FROM ams_event_offers_vl
          WHERE event_offer_id = p_object_id;

      CURSOR c_deliverable (p_object_id IN NUMBER) IS
         SELECT custom_setup_id, owner_user_id
           FROM ams_deliverables_vl
          WHERE deliverable_id = p_object_id;

      CURSOR c_fund (p_object_id IN NUMBER) IS
         SELECT custom_setup_id, owner
           FROM ozf_funds_all_vl
          WHERE fund_id = p_object_id;

      CURSOR c_offer (p_object_id IN NUMBER) IS
         SELECT custom_setup_id, owner_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_object_id;

      l_custom_setup_id       NUMBER;
      l_flag                  VARCHAR2 (1);
      l_object_owner_id       NUMBER;
      l_source_owner_id       NUMBER;
      l_src_custom_setup_id   NUMBER;
      l_return_status         VARCHAR2(1);
      l_must_preview          VARCHAR2(1) := 'Y';

      --- the flag is null then no approval required
      CURSOR c_appvl_reqd_flag (p_custom_setup_id IN NUMBER) IS
         SELECT NVL (attr_available_flag, 'N')
           FROM ams_custom_setup_attr
          WHERE custom_setup_id = p_custom_setup_id
            AND object_attribute = 'BAPL';
   BEGIN
      -- approval is required only for budget request
      IF p_transfer_type = 'REQUEST' THEN
         -- Campaign
         IF p_object = 'CAMP' THEN
            OPEN c_campaign (p_object_id);
            FETCH c_campaign INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_campaign;
         -- Campaign Schdules
         ELSIF p_object = 'CSCH' THEN
            OPEN c_campaign_schl (p_object_id);
            FETCH c_campaign_schl INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_campaign_schl;
         -- Event Header/Rollup Event
         ELSIF p_object = 'EVEH' THEN
            OPEN c_eheader (p_object_id);
            FETCH c_eheader INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_eheader;
         -- Event Offer/Execution Event
         ELSIF p_object IN ('EONE','EVEO') THEN
            OPEN c_eoffer (p_object_id);
            FETCH c_eoffer INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_eoffer;
         -- Deliverable
         ELSIF p_object = 'DELV' THEN
            OPEN c_deliverable (p_object_id);
            FETCH c_deliverable INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_deliverable;
         ELSIF p_object = 'FUND' THEN
            OPEN c_fund (p_object_id);
            FETCH c_fund INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_fund;
         ELSIF p_object = 'OFFR' THEN
            OPEN c_offer (p_object_id);
            FETCH c_offer INTO l_custom_setup_id, l_object_owner_id;
            CLOSE c_offer;
         END IF;

         --- checking for source type
         -- Campaign
         IF p_source_type = 'CAMP' THEN
            OPEN c_campaign (p_source_id);
            FETCH c_campaign INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_campaign;
         -- Campaign Schdules
         ELSIF p_source_type = 'CSCH' THEN
            OPEN c_campaign_schl (p_source_id);
            FETCH c_campaign_schl INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_campaign_schl;
         -- Event Header/Rollup Event
         ELSIF p_source_type = 'EVEH' THEN
            OPEN c_eheader (p_source_id);
            FETCH c_eheader INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_eheader;
         -- Event Offer/Execution Event
         ELSIF p_source_type IN ('EONE','EVEO') THEN
            OPEN c_eoffer (p_source_id);
            FETCH c_eoffer INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_eoffer;
         -- Deliverable
         ELSIF p_source_type = 'DELV' THEN
            OPEN c_deliverable (p_source_id);
            FETCH c_deliverable INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_deliverable;
         ELSIF p_source_type = 'FUND' THEN
            OPEN c_fund (p_source_id);
            FETCH c_fund INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_fund;
         ELSIF p_source_type = 'OFFR' THEN
            OPEN c_offer (p_source_id);
            FETCH c_offer INTO l_src_custom_setup_id, l_source_owner_id;
            CLOSE c_offer;
         END IF;

         --
         OPEN c_appvl_reqd_flag (l_custom_setup_id);
         FETCH c_appvl_reqd_flag INTO l_flag;
         CLOSE c_appvl_reqd_flag;

         --kdass 23-NOV-2005 bug 4658021 - when the approver for a campaign or campaign schedule is the same
         --person as the requestor, budget request approval is not required
         IF l_flag = 'Y' AND p_object IN ('CAMP', 'CSCH') AND p_source_type = 'FUND' THEN

            ams_approval_pvt.must_preview(p_activity_id   => p_object_id
                                         ,p_activity_type => p_object
                                         ,p_approval_type => 'BUDGET'
                                         ,p_act_budget_id => null
                                         ,p_requestor_id  => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id)
                                         ,x_must_preview  => l_must_preview
                                         ,x_return_status => l_return_status
                                         );
            IF l_must_preview = 'N' THEN
               l_flag := NULL;
            END IF;
         END IF;

         -- if owner is different then check for approval flag
         --10/30/2001  commented owner code for later release, we ahve to change workflow approvals API also
         -- for owner approval logic
--         IF l_source_owner_id <> l_object_owner_id THEN
            IF l_flag IS NULL THEN
               RETURN fnd_api.g_false;  --change to false by feliu from 11.5.10
            ELSIF l_flag = 'Y' THEN
               RETURN fnd_api.g_true;
            ELSIF l_flag = 'N' THEN
               RETURN fnd_api.g_false;
            ELSE
               RETURN fnd_api.g_false;
            END IF;
          /*
         -- if owner is the same then donot submit for approval
         ELSE
         -- IMP mpande 08/10/2001 made it to true for a workaround in approvals workflow
            RETURN fnd_api.g_true;
         END IF;
         */
      ELSE -- else for transfer type  'TRANSFER'
         RETURN fnd_api.g_false;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_campaign%ISOPEN THEN
            CLOSE c_campaign;
         END IF;

         IF c_campaign_schl%ISOPEN THEN
            CLOSE c_campaign_schl;
         END IF;

         IF c_eheader%ISOPEN THEN
            CLOSE c_eheader;
         END IF;

         IF c_eoffer%ISOPEN THEN
            CLOSE c_eoffer;
         END IF;

         IF c_deliverable%ISOPEN THEN
            CLOSE c_deliverable;
         END IF;

         IF c_offer%ISOPEN THEN
            CLOSE c_offer;
         END IF;

         IF c_fund%ISOPEN THEN
            CLOSE c_fund;
         END IF;

         RAISE;
   END check_approval_required;

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    can_plan_more_budget
   -- PURPOSE
   --    Return T if the object(CAMP, EVEH) total request amount is greater than the planned amount
   -- in the active state only
   -- HISTORY
   -- 05/01/2001 mpande   Created.
/*****************************************************************************************/
   FUNCTION can_plan_more_budget (
      p_object_type      IN   VARCHAR2
     ,p_object_id        IN   NUMBER
     ,p_request_amount   IN   NUMBER
     ,p_act_budget_id    IN   NUMBER
   )
      RETURN VARCHAR2 IS
      CURSOR c_campaign IS
         SELECT budget_amount_tc, status_code
           FROM ams_campaigns_vl
          WHERE campaign_id = p_object_id;

      CURSOR c_campaign_schl IS
         SELECT budget_amount_tc, status_code
           FROM ams_campaign_schedules_vl
          WHERE schedule_id = p_object_id;

      CURSOR c_eheader IS
         SELECT fund_amount_tc, system_status_code
           FROM ams_event_headers_vl
          WHERE event_header_id = p_object_id;

      CURSOR c_eoffer IS
         SELECT fund_amount_tc, system_status_code
           FROM ams_event_offers_vl
          WHERE event_offer_id = p_object_id;

      CURSOR c_deliverable IS
         SELECT budget_amount_tc, status_code
           FROM ams_deliverables_vl
          WHERE deliverable_id = p_object_id;

      --   this amount column would change
      CURSOR c_offer IS
         SELECT budget_amount_tc, status_code
           FROM ozf_offers
          WHERE qp_list_header_id = p_object_id;

      l_amount            NUMBER;
      l_existing_amount   NUMBER;
      l_status_code       VARCHAR2 (30);

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      CURSOR c_obj_amount IS
         SELECT SUM (amount) amount FROM (
               SELECT DECODE(a1.status_code ,'NEW',a1.request_amount,'APPROVED', a1.approved_amount,0) amount
                 FROM ozf_act_budgets a1
                 WHERE a1.act_budget_used_by_id = p_object_id
                   AND a1.arc_act_budget_used_by = p_object_type
                   AND a1.transfer_type = 'REQUEST'
                   AND a1.activity_budget_id <> NVL (p_act_budget_id, 0)
                   AND status_code <> 'REJECTED'
               UNION ALL
               SELECT DECODE(a1.status_code ,'NEW',a1.src_curr_request_amt,'APPROVED', -a1.approved_original_amount) amount
                 FROM ozf_act_budgets a1
                 WHERE a1.budget_source_id = p_object_id
                   AND a1.budget_source_type = p_object_type
                   AND a1.transfer_type = 'TRANSFER'
                   AND a1.activity_budget_id <> NVL (p_act_budget_id, 0)
                   AND status_code <> 'REJECTED');

      /*
      CURSOR c_obj_amount IS
         SELECT SUM( NVL(
                    DECODE(a1.transfer_type ,
                             'REQUEST',
                                DECODE(a1.status_code ,'NEW',a1.request_amount,'APPROVED', a1.approved_amount,0),
                       'TRANSFER' ,
                                DECODE(a1.status_code ,'NEW',a1.src_curr_request_amt,'APPROVED', -a1.approved_original_amount))
                       ,0)
                    )  amount
           FROM ozf_act_budgets a1
          WHERE DECODE(a1.transfer_type , 'REQUEST', a1.act_budget_used_by_id, 'TRANSFER' , a1.budget_source_id ) = p_object_id
             AND DECODE(a1.transfer_type , 'REQUEST', a1.arc_act_budget_used_by, 'TRANSFER' , a1.budget_source_type ) = p_object_type
             AND a1.transfer_type <> 'UTILIZED'
             AND a1.activity_budget_id <> NVL (p_act_budget_id, 0)
               AND status_code <> 'REJECTED' ;
      */
-- 5/10/2002 mpande commented the code
/*
      CURSOR c_obj_amount IS
         SELECT NVL (SUM (NVL (a1.approved_amount, a1.request_amount)), 0) amount
           FROM ozf_act_budgets a1
          WHERE a1.act_budget_used_by_id = p_object_id
            AND a1.arc_act_budget_used_by = p_object_type
            AND a1.transfer_type <> 'UTILIZED'
            AND a1.activity_budget_id <> NVL (p_act_budget_id, 0)
            AND status_code <> 'REJECTED';
*/
   BEGIN
      -- Campaign
      IF p_object_type = 'CAMP' THEN
         OPEN c_campaign;
         FETCH c_campaign INTO l_amount, l_status_code;
         CLOSE c_campaign;
      -- Campaign Schdules
      ELSIF p_object_type = 'CSCH' THEN
         OPEN c_campaign_schl;
         FETCH c_campaign_schl INTO l_amount, l_status_code;
         CLOSE c_campaign_schl;
      -- Event Header/Rollup Event
      ELSIF p_object_type = 'EVEH' THEN
         OPEN c_eheader;
         FETCH c_eheader INTO l_amount, l_status_code;
         CLOSE c_eheader;
      -- Event Offer/Execution Event
      ELSIF p_object_type IN ('EONE','EVEO') THEN
         OPEN c_eoffer;
         FETCH c_eoffer INTO l_amount, l_status_code;
         CLOSE c_eoffer;
      -- Deliverable
      ELSIF p_object_type = 'DELV' THEN
         OPEN c_deliverable;
         FETCH c_deliverable INTO l_amount, l_status_code;
         CLOSE c_deliverable;

         -- making the tem variable status_code = ACTIVE to make a cleaner code
         IF l_status_code = 'AVAILABLE' THEN
            l_status_code              := 'ACTIVE';
         END IF;
      -- we do not need to check this for fund
      ELSIF p_object_type = 'OFFR' THEN
         OPEN c_offer;
         FETCH c_offer INTO l_amount, l_status_code;
         CLOSE c_offer;
      -- have to add for EONE
      END IF;

      OPEN c_obj_amount;
      FETCH c_obj_amount INTO l_existing_amount;
      CLOSE c_obj_amount;

      IF      p_object_type <> 'FUND'
          AND l_status_code <> 'ACTIVE' THEN
         IF   NVL (l_existing_amount, 0)
            + NVL (p_request_amount, 0) > NVL (l_amount, 0) THEN
            RETURN fnd_api.g_false;
         ELSE
            RETURN fnd_api.g_true;
         END IF;
      ELSE
         RETURN fnd_api.g_true;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_campaign%ISOPEN THEN
            CLOSE c_campaign;
         END IF;

         IF c_campaign_schl%ISOPEN THEN
            CLOSE c_campaign_schl;
         END IF;

         IF c_eheader%ISOPEN THEN
            CLOSE c_eheader;
         END IF;

         IF c_eoffer%ISOPEN THEN
            CLOSE c_eoffer;
         END IF;

         IF c_deliverable%ISOPEN THEN
            CLOSE c_deliverable;
         END IF;

         IF c_offer%ISOPEN THEN
            CLOSE c_offer;
         END IF;

         RAISE;
   END can_plan_more_budget;

/*****************************************************************************************/
-- Start of Comments
   --
   -- NAME
   --    budget_has_enough_money
   -- PURPOSE
   --    Return Y if the budget source has enough
   --    money to fund the approved amount for a
   --    budget request; return N, otherwise.
   -- HISTORY
   -- 20-Feb-2001 mpande   Created.
   -- 12/17/2001 mpande    UPdated put = clause
/*****************************************************************************************/

   FUNCTION budget_has_enough_money (p_source_id IN NUMBER, p_approved_amount IN NUMBER)
      RETURN VARCHAR2 IS
      l_approved_amount   NUMBER;

      --12/08/2005 kdass - sql repository fix SQL ID 14892411 - query the base table directly
      CURSOR c_approved_amount IS
         SELECT (NVL(original_budget, 0) - NVL(holdback_amt, 0)
                 + NVL(transfered_in_amt, 0) - NVL(transfered_out_amt, 0))
                - NVL (committed_amt, 0)
           FROM ozf_funds_all_b
          WHERE fund_id = p_source_id;
      /*
      CURSOR c_approved_amount IS
         SELECT   NVL (available_budget, 0)
                - NVL (committed_amt, 0)
           FROM ozf_fund_details_v
          WHERE fund_id = p_source_id;
      */
   BEGIN
      OPEN c_approved_amount;
      FETCH c_approved_amount INTO l_approved_amount;
      CLOSE c_approved_amount;

      IF l_approved_amount >= p_approved_amount THEN
         RETURN fnd_api.g_true;
      ELSE
         RETURN fnd_api.g_false;
      END IF;
   END budget_has_enough_money;


/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Create Note
-- PURPOSE
--  Create Note fro justification and comments
-- HISTORY
-- 02/23/2001  mpande  CREATED
/*****************************************************************************************/
   PROCEDURE create_note (
      p_activity_type   IN       VARCHAR2
     ,p_activity_id     IN       NUMBER
     ,p_note            IN       VARCHAR2
     ,p_note_type       IN       VARCHAR2
     ,p_user            IN       NUMBER
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_id        NUMBER;
      l_user      NUMBER;
      l_note_id   NUMBER;

      CURSOR c_resource IS
         SELECT user_id user_id
           FROM ams_jtf_rs_emp_v
          WHERE resource_id = p_user;

      CURSOR c_note (p_activity_type IN VARCHAR2, p_activity_id IN NUMBER, p_note_type IN VARCHAR2) IS
         SELECT jtf_note_id
           FROM jtf_notes_b
          WHERE source_object_code =    'AMS_'
                                     || p_activity_type
            AND source_object_id = p_activity_id
            AND note_type = p_note_type;
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      OPEN c_resource;
      FETCH c_resource INTO l_user;

      IF c_resource%NOTFOUND THEN
         fnd_message.set_name ('OZF', 'OZF_API_DEBUG_MESSAGE');
         fnd_message.set_token ('ROW', SQLERRM);
         fnd_msg_pub.ADD;
      END IF;

      CLOSE c_resource;
      OPEN c_note (p_activity_type, p_activity_id, p_note_type);
      FETCH c_note INTO l_note_id;
      CLOSE c_note;

      --Bugfix:6654242 - Added l_user check
      IF l_user IS NULL THEN
         l_user  := NVL(fnd_global.user_id, -1);
      END IF;


      IF l_note_id IS NOT NULL THEN
         jtf_notes_pub.update_note (
            p_api_version=> 1.0
           ,x_return_status=> x_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_jtf_note_id=> l_note_id
           ,p_entered_by=> l_user
           ,p_last_updated_by=> l_user
           ,p_notes=> p_note
           ,p_note_type=> p_note_type
         );
      ELSE
         jtf_notes_pub.create_note (
            p_api_version=> 1.0
           ,x_return_status=> x_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_source_object_id=> p_activity_id
           ,p_source_object_code=>    'AMS_'
                                   || p_activity_type
           ,p_notes=> p_note
           ,p_note_status=> NULL
           ,p_entered_by=> l_user
           ,p_entered_date=> SYSDATE
           ,p_last_updated_by=> l_user
           ,x_jtf_note_id=> l_id
           ,p_note_type=> p_note_type
           ,p_last_update_date=> SYSDATE
           ,p_creation_date=> SYSDATE
         );
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         fnd_message.set_name ('OZF', 'OZF_API_DEBUG_MESSAGE');
         fnd_message.set_token ('ROW', SQLERRM);
         fnd_msg_pub.ADD;
      END IF;
   END create_note;

END OZF_ACTBUDGETRULES_PVT;

/
