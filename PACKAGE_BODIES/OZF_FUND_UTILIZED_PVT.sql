--------------------------------------------------------
--  DDL for Package Body OZF_FUND_UTILIZED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_UTILIZED_PVT" AS
/* $Header: ozfvfutb.pls 120.17.12010000.25 2010/05/20 07:10:06 nepanda ship $ */
   g_pkg_name         CONSTANT VARCHAR2 (30) := 'OZF_Fund_Utilized_PVT';
   g_cons_fund_mode   CONSTANT VARCHAR2 (30) := 'ADJUST'; --JTF_PLSQL_API.G_UPDATE
   g_universal_currency   CONSTANT VARCHAR2 (15) := fnd_profile.VALUE ('OZF_UNIV_CURR_CODE');
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);


-----------------------------------------------------------------------
-- PROCEDURE
--    raise_business_event
--
-- HISTORY
--    05/08/2004  feliu  Created.
-----------------------------------------------------------------------


PROCEDURE raise_business_event(p_object_id IN NUMBER)
IS
l_item_key varchar2(30);
l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_object_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();


  IF G_DEBUG THEN
    ozf_utility_pvt.debug_message(' utilization Id is :'||p_object_id );
  END IF;

    wf_event.AddParameterToList(p_name           => 'P_UTIL_ID',
                              p_value          => p_object_id,
                              p_parameterlist  => l_parameter_list);

   IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Item Key is  :'||l_item_key);
  END IF;

    wf_event.raise( p_event_name =>'oracle.apps.ozf.fund.adjustment.approval',
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);


EXCEPTION
WHEN OTHERS THEN
RAISE Fnd_Api.g_exc_error;
ozf_utility_pvt.debug_message('Exception in raising business event');
END;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilization
--
-- HISTORY
--    04/25/2001  Mumu Pande  Create.
--   p_create_gl_entry   IN VARCHAR2 := FND_API.g_false this flag indicates wether to
--                create gl entry or not . Right now the entry is only for utilization type 'adjustment'
-- Requirements for 11.5.5- hornet
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu Pande    Updated for Hornet requirements
--    02/09/2001  Mumu Pande    Added validation routine for adjsutment_type_id
--                              Created Subroutines to create committed amount record in ozf_act_budgets
--    08/28/2001  Mumu Pande    Bug#1950117
--    09/05/2001  Mumu Pande    Bug#1970359
--    02/28/2002  Feliu         Added create_act_utilization procedure and remove
--                              recal_comm_flag. Modify create_utilzation.
--    28-OCT-2002 Feliu         added scan_unit,scan_unit_remaining,activity_product_id,
--                              scan_type_id for utilization_rec_type for 11.5.9.
--    12/23/2002  feliu         Changed for chargback.
--    04/25/2003  feliu         fixed bug 2925302 for source from sales accrual budget.
--    10/20/2003  yzhao         fixed TEVA bug - customer accrual budget committed amount remains 0 when third party accrual happens
--    11/14/2003  yzhao         11.5.10 populate both utilized_amt and earned_amt, added CHARGEBACK
--    02/24/2004  yzhao         11.5.10 fix bug 3461280 - manual adj for off-invoice, should update paid amount
--                                customer accrual without liability: no gl posting, do not update earned amount
--                              use constant ozf_accrual_engine.G_GL_FLAG_* for gl_posted_flag
--    19-AUG-2008 ateotia       Bug # 7337263 fixed.
--                              FP:11510-R12 7129397 - GOT ERROR ON OBJECT_VERSION_NUMBER IN INITIATE PAYMENT
--                              Added a condition for Chargeback Batch using Fully Accrued budget.
---------------------------------------------------------------------

PROCEDURE create_utilization (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_create_gl_entry    IN       VARCHAR2 := fnd_api.g_false
     ,p_utilization_rec    IN       utilization_rec_type
     ,x_utilization_id     OUT NOCOPY      NUMBER
   ) IS
      l_api_version         CONSTANT NUMBER                                     := 1.0;
      l_api_name            CONSTANT VARCHAR2 (30)                              := 'Create_Utilization';
      l_full_name           CONSTANT VARCHAR2 (60)                              :=    g_pkg_name
                                                                                   || '.'
                                                                                   || l_api_name;
      l_return_status                VARCHAR2 (1);
      l_utilization_rec              utilization_rec_type                       := p_utilization_rec;
      l_object_version_number        NUMBER                                     := 1;
      l_utilization_check            VARCHAR2 (10);
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_utilized_amt                 NUMBER;
      l_earned_amt                   NUMBER;
      l_gl_rec                       ozf_gl_interface_pvt.gl_interface_rec_type;
      l_event_id                     NUMBER;
      l_obj_num                      NUMBER;
      l_committed_amt                NUMBER;
      l_act_budget_id                NUMBER;
      l_act_budget_objver            NUMBER;
      l_fund_type                    VARCHAR2 (30);
      l_accrual_basis                VARCHAR2 (30);
      l_original_budget              NUMBER;
      l_set_of_book_id               NUMBER;
      l_sob_type_code                VARCHAR2 (30);
      l_fc_code                      VARCHAR2 (150);
      l_paid_amt                     NUMBER;
      l_util_rec                     ozf_actbudgets_pvt.act_util_rec_type;
      l_gl_posted_flag               VARCHAR2(1);
      l_offer_type                   VARCHAR2 (30);
      l_volume_offer_type            VARCHAR2 (30);
      l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
      l_custom_setup_id              NUMBER;

      /*
      -- Cursor to get the org_id for budget
      CURSOR c_fund_org_id (p_fund_id IN NUMBER)IS
         SELECT org_id, ledger_id
         FROM ozf_funds_all_b
         WHERE fund_id = p_fund_id;
       */

 --     l_activity_product_id          NUMBER;
      -- Cursor to get the sequence for utilization_id
      CURSOR c_utilization_seq IS
         SELECT ozf_funds_utilized_s.NEXTVAL
           FROM DUAL;

      -- Cursor to validate the uniqueness of the utilization_id
      CURSOR c_utilization_count (cv_utilization_id IN NUMBER) IS
         SELECT 'X'
           FROM ozf_funds_utilized_all_b
          WHERE utilization_id = cv_utilization_id;

      -- Cursor to get original utilization gl_posted_flag
      CURSOR c_get_orig_gl_flag (p_utilization_id IN NUMBER) IS
         SELECT gl_posted_flag
           FROM ozf_funds_utilized_all_b
          WHERE utilization_id = p_utilization_id;

      -- Cursor to get fund earned amount and object_version_number
      CURSOR c_fund_b (p_fund_id IN NUMBER) IS
         SELECT utilized_amt
               ,earned_amt
               ,object_version_number
               ,committed_amt
               ,accrual_basis
               ,fund_type
               ,original_budget
               ,paid_amt
               ,plan_id
               ,liability_flag            -- yzhao: 10/20/2003 added
               ,recal_committed           -- yzhao: 10/20/2003 added
           FROM ozf_funds_all_b
          WHERE fund_id = p_fund_id;

      --- Cursor to get the adjustment_type from adjustmentId
      CURSOR c_adj_type (p_adj_type_id IN NUMBER) IS
         SELECT adjustment_type
           FROM ozf_claim_types_all_b
          WHERE claim_type_id = p_adj_type_id;

      /* 10/20/2003  yzhao  Fix TEVA bug - customer fully accrual budget committed amount is always 0 when third party accrual happens
                       update ozf_act_budgets REQUEST between fully accrual budget and its offer when accrual happens
         */
      CURSOR c_accrual_budget_reqeust(p_fund_id IN NUMBER, p_plan_id IN NUMBER) IS
         SELECT activity_budget_id
              , object_version_number
         FROM   ozf_act_budgets
         WHERE  arc_act_budget_used_by = 'OFFR'
         AND    act_budget_used_by_id = p_plan_id
         AND    budget_source_type = 'FUND'
         AND    budget_source_id = p_fund_id
         AND    transfer_type = 'REQUEST'
         AND    status_code = 'APPROVED';

     /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
     CURSOR c_budget_request_utilrec(p_fund_id IN NUMBER, p_plan_id IN NUMBER, p_actbudget_id IN NUMBER) IS
        SELECT utilization_id
             , object_version_number
        FROM   ozf_funds_utilized_all_b
        WHERE  utilization_type = 'REQUEST'
        AND    fund_id = p_fund_id
        AND    plan_type = 'FUND'
        AND    plan_id = p_fund_id
        AND    component_type = 'OFFR'
        AND    component_id = p_plan_id
        AND    ams_activity_budget_id = p_actbudget_id;
    */

     CURSOR c_get_deal_accrual_flag(p_qp_list_header_id IN NUMBER, p_product_type IN VARCHAR2, p_product_id IN NUMBER) IS
        SELECT 1
        FROM   DUAL
        WHERE  EXISTS (SELECT 1
                       FROM   qp_list_lines line, qp_pricing_attributes attr
                       WHERE  attr.list_header_id = p_qp_list_header_id
                       AND    line.list_line_id = attr.list_line_id
                       AND    NVL(line.accrual_flag, 'N') = 'Y'
                       AND    attr.product_attribute = DECODE(NVL(p_product_type, 'OTHER')
                                                             , 'PRODUCT', 'ITEM', 'FAMILY', 'CATEGORY', attr.product_attribute)
                       AND    attr.product_attr_value = NVL(p_product_id, attr.product_attr_value)
                       AND    attr.product_attribute_context = 'ITEM'
                      );

     /*fix for bug 4778995
     -- yzhao: 11.5.10 get time_id
     CURSOR c_get_time_id(p_date IN DATE) IS
        SELECT month_id, ent_qtr_id, ent_year_id
        FROM   ozf_time_day
        WHERE  report_date = trunc(p_date);
     */

     -- yzhao: 11.5.10 get offer's beneficiary account id
     CURSOR c_offer_info (p_offer_id IN NUMBER) IS
        SELECT offer_type, volume_offer_type, custom_setup_id
        FROM   ozf_offers
        WHERE  qp_list_header_id = p_offer_id;


     CURSOR c_sd_request_header_id(p_list_header_id IN NUMBER) IS
         SELECT request_header_id
         FROM   ozf_sd_request_headers_all_b
         WHERE  offer_id =p_list_header_id;

     /*
     -- yzhao: 11.5.10 check if post to gl for off invoice discount
     CURSOR c_offinvoice_gl_post_flag(p_fund_id IN NUMBER) IS
        SELECT  NVL(sob.gl_acct_for_offinv_flag, 'F')
        FROM    ozf_sys_parameters_all sob
               ,ozf_funds_all_b  fun
        WHERE fun.fund_id = p_fund_id
        AND   sob.org_id = fun.ORG_id ;
      */
     CURSOR c_offinvoice_gl_post_flag(p_org_id IN NUMBER) IS
        SELECT  NVL(sob.gl_acct_for_offinv_flag, 'F')
        FROM    ozf_sys_parameters_all sob
        WHERE   sob.org_id = p_org_id;

     -- yzhao: R12 update ozf_object_fund_summary table
     CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT objfundsum_id
              , object_version_number
              , committed_amt
              , recal_committed_amt
              , utilized_amt
              , earned_amt
              , paid_amt
              , plan_curr_committed_amt
              , plan_curr_recal_committed_amt
              , plan_curr_utilized_amt
              , plan_curr_earned_amt
              , plan_curr_paid_amt
              , univ_curr_committed_amt
              , univ_curr_recal_committed_amt
              , univ_curr_utilized_amt
              , univ_curr_earned_amt
              , univ_curr_paid_amt
        FROM   ozf_object_fund_summary
        WHERE  object_type = p_object_type
        AND    object_id = p_object_id
        AND    fund_id = p_fund_id;

      --nirprasa, added for bug 8940036
        CURSOR c_getClosedPeriods(c_sob_id    NUMBER,
                                  c_gl_date   DATE) IS
        SELECT   gps.period_name, gps.start_date,
                 gps.end_date, gps.closing_status
        FROM     gl_period_statuses gps
        WHERE    gps.application_id  = 101
        AND      gps.set_of_books_id = c_sob_id
        AND      Nvl(gps.adjustment_period_flag,'N') = 'N'
        AND      gps.closing_status = 'C'
        AND      to_date(c_gl_date) between gps.start_date and gps.end_date
        ORDER BY gps.start_date desc;

        l_periods            VARCHAR2(30);
        l_begin_date         DATE;
        l_end_date           DATE;
        l_period_status      VARCHAR2(1);

        -- end for bug 8940036

      l_recal_comm_amt               NUMBER;
      l_plan_curr_amount             NUMBER := 0;
      l_plan_curr_amount_remaining   NUMBER := 0;
      l_plan_currency                VARCHAR2 (150);
      l_univ_curr_amount             NUMBER := 0;
      l_rate                         NUMBER;
      l_plan_id                      NUMBER;
      l_liability_flag               VARCHAR2(1);
      l_offinvoice_gl_post_flag      VARCHAR2(1);
      l_tmp_id                       NUMBER;
      l_offer_accrual_flag           BOOLEAN;
      l_gl_posted                    BOOLEAN;
      l_orig_gl_flag                 VARCHAR2(1);
      l_objfundsum_id                NUMBER;
      l_event_type_code             VARCHAR2(30);
      l_adjustment_type              VARCHAR2(1);
     -- l_skip_acct_gen_flag           VARCHAR2(1);
      x_event_id                     NUMBER;
      l_ledger_id                    NUMBER;
      l_ledger_name                  VARCHAR2(30);

      l_order_gl_phase               VARCHAR2(15);
      l_gl_date                      DATE;
      l_line_category_code           VARCHAR2(30);
      l_shipped_quantity             NUMBER;
      l_flow_status_code             VARCHAR2(30);
      l_invoice_status_code          VARCHAR2(30);
      l_invoiced_quantity            NUMBER;
      l_actual_shipment_date         DATE;
      l_order_number                 NUMBER;


      CURSOR c_order_line (p_line_id IN NUMBER) IS
         SELECT line_category_code, shipped_quantity, flow_status_code,
                invoice_interface_status_code, invoiced_quantity, actual_shipment_date
           FROM oe_order_lines_all
          WHERE line_id = p_line_id;

      CURSOR c_order_num (p_header_id IN NUMBER) IS
         SELECT order_number
           FROM oe_order_headers_all
          WHERE header_id = p_header_id;

      CURSOR c_invoice_date(p_line_id IN NUMBER, p_order_number IN VARCHAR2) IS
        SELECT cust.trx_date     -- transaction(invoice) date
          FROM ra_customer_trx_all cust
              ,ra_customer_trx_lines_all cust_lines
        WHERE cust.customer_trx_id = cust_lines.customer_trx_id
          AND cust_lines.sales_order = p_order_number
          AND cust_lines.interface_line_attribute6 = TO_CHAR(p_line_id);

    --Added for bug 7030415
       CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
          SELECT exchange_rate_type
          FROM   ozf_sys_parameters_all
          WHERE  org_id = p_org_id;

      CURSOR c_offer_org_id (p_plan_id IN NUMBER) IS
         SELECT orig_org_id
           FROM qp_list_headers_b
          WHERE list_header_id = p_plan_id;

      CURSOR c_adj_org_id (p_adj_id IN NUMBER) IS
         SELECT org_id
           FROM ozf_claim_types_all_b
          WHERE claim_type_id = p_adj_id;

        -- Cursor to get the org_id for cust acct
      CURSOR c_cust_acct_org_id (p_site_use_id IN NUMBER) IS
         SELECT org_id
           FROM hz_cust_site_uses_all
          WHERE site_use_id = p_site_use_id;

      CURSOR c_plan_curr_amount (p_utilization_id IN NUMBER) IS
         SELECT plan_curr_amount,plan_curr_amount_remaining
           FROM ozf_funds_utilized_all_b
          WHERE utilization_id = p_utilization_id;

      CURSOR c_plan_curr_amount_remaining (p_utilization_id IN NUMBER) IS
         SELECT plan_curr_amount_remaining
           FROM ozf_funds_utilized_all_b
          WHERE utilization_id = p_utilization_id;

      l_org_id NUMBER;
      l_qlf_type                     VARCHAR2 (30);
      l_qlf_id                       NUMBER;
      l_fund_reconc_msg              VARCHAR2(4000);
      l_act_bud_cst_msg              VARCHAR2(4000);

   BEGIN
      --------------------- initialize -----------------------
      SAVEPOINT create_utilization;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start' || p_utilization_rec.utilization_type);
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

----------------------- validate -----------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_full_name
         || ': validate'
         || l_utilization_rec.adjustment_type_id
      );
      END IF;

      --Added for bug 7425189
      l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
      l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');

      -- if the  utlization type is adjustment then the adjustment type is mandatory
      IF l_utilization_rec.utilization_type IN ('ADJUSTMENT', 'CHARGEBACK', 'LEAD_ADJUSTMENT') THEN   -- yzhao: 11.5.10 added CHARGEBACK, LEAD_ADJUSTMENT
         OPEN c_adj_type (l_utilization_rec.adjustment_type_id);
         FETCH c_adj_type INTO l_utilization_rec.adjustment_type;
         CLOSE c_adj_type;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            l_full_name
         || ': adjustment_type: '
         || l_utilization_rec.adjustment_type
      );
      END IF;
      validate_utilization (
         p_api_version=> l_api_version
        ,p_init_msg_list=> fnd_api.g_false
        ,p_validation_level=> p_validation_level
        ,x_return_status=> l_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_utilization_rec=> l_utilization_rec
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      -- Here we should check for adjustment_type , if the adjustment_type is DECREASE_COMMITTMENT or DECREASE_EARNED_COMMITTED
      -- we go and create a debit record for that amount in Ozf_ACT_budgets
/*      IF    NVL (l_utilization_rec.adjustment_type, 'STANDARD') <> ('DECREASE_COMMITTED')
         -- this is a temporary fix have to fix it from the UI
         OR l_utilization_rec.utilization_type = 'TRANSFER'
         --OR NVL (l_utilization_rec.recal_comm_flag, 'N') = 'Y'
     THEN
  */
-------------------------- insert --------------------------
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_full_name || ': insert');
            ozf_utility_pvt.debug_message ('currency_code '||l_utilization_rec.currency_code);
            ozf_utility_pvt.debug_message ('plan_currency_code '||l_utilization_rec.plan_currency_code);
         END IF;

   /*      IF l_utilization_rec.adjustment_type IN ('DECREASE_EARNED', 'DECREASE_COMM_EARNED') THEN
            l_utilization_rec.amount   := -l_utilization_rec.amount;
            l_utilization_rec.amount_remaining   := -l_utilization_rec.amount_remaining;
         END IF;
*/
         IF l_utilization_rec.utilization_id IS NULL THEN
            LOOP
               -- Get the identifier
               OPEN c_utilization_seq;
               FETCH c_utilization_seq INTO l_utilization_rec.utilization_id;
               CLOSE c_utilization_seq;
               -- Check the uniqueness of the identifier
               OPEN c_utilization_count (l_utilization_rec.utilization_id);
               FETCH c_utilization_count INTO l_utilization_check;
               -- Exit when the identifier uniqueness is established
               EXIT WHEN c_utilization_count%ROWCOUNT = 0;
               CLOSE c_utilization_count;
            END LOOP;
         END IF;

         IF l_utilization_rec.amount = 0 THEN
            l_utilization_rec.acctd_amount := 0;
         ELSE

            l_utilization_rec.amount  := ozf_utility_pvt.currround(l_utilization_rec.amount , l_utilization_rec.currency_code);  -- round amount to fix bug 3615680;
            l_utilization_rec.plan_curr_amount  := ozf_utility_pvt.currround(l_utilization_rec.plan_curr_amount , l_utilization_rec.plan_currency_code);
         END IF;


         IF G_DEBUG THEN
             ozf_utility_pvt.debug_message (   l_api_name
                                             || ': ozf_funds_utilized_pvt create_utilization   org_id passed in is'
                                             || l_utilization_rec.org_id);
             ozf_utility_pvt.debug_message (   l_api_name
                                             || ': ozf_funds_utilized_pvt create_utilization   plan amount is'
                                             || l_utilization_rec.plan_curr_amount);
         END IF;

         /*07-APR-09 kdass bug 8402334
           If OU is not passed to Budget Adjustment API, then default it based on the following precedence:
           1) Bill to/ Ship to site OU
           2) Offer OU
           3) Adjustment Type's OU
         */
         IF l_utilization_rec.utilization_type IN ('ADJUSTMENT')
            AND l_utilization_rec.adjustment_type IS NOT NULL
            AND l_utilization_rec.org_id IS NULL THEN

            l_org_id := NULL;

            IF l_utilization_rec.site_use_id IS NOT NULL THEN

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message('l_utilization_rec.site_use_id '|| l_utilization_rec.site_use_id );
               END IF;

               OPEN c_cust_acct_org_id(l_utilization_rec.site_use_id);
               FETCH c_cust_acct_org_id INTO l_org_id ;
               CLOSE c_cust_acct_org_id;
               l_utilization_rec.org_id := l_org_id;

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message('l_utilization_rec.org_id '|| l_utilization_rec.org_id);
               END IF;
            END IF;

            IF l_utilization_rec.org_id IS NULL THEN
               IF l_utilization_rec.plan_type IS NOT NULL AND l_utilization_rec.plan_type = 'OFFR' THEN

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('l_utilization_rec.plan_type '|| l_utilization_rec.plan_type );
                     ozf_utility_pvt.debug_message('l_utilization_rec.plan_id '|| l_utilization_rec.plan_id );
                  END IF;

                  OPEN c_offer_org_id(l_utilization_rec.plan_id);
                  FETCH c_offer_org_id INTO l_org_id ;
                  CLOSE c_offer_org_id;
                  l_utilization_rec.org_id := l_org_id;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('l_utilization_rec.org_id '|| l_utilization_rec.org_id);
                  END IF;
               END IF;
            END IF;

            IF l_utilization_rec.org_id IS NULL THEN
               IF l_utilization_rec.adjustment_type_id IS NOT NULL THEN

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('l_utilization_rec.adjustment_type_id '|| l_utilization_rec.adjustment_type_id);
                  END IF;

                  OPEN c_adj_org_id(l_utilization_rec.adjustment_type_id);
                  FETCH c_adj_org_id INTO l_org_id ;
                  CLOSE c_adj_org_id;
                  l_utilization_rec.org_id := l_org_id;

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message('l_utilization_rec.org_id '|| l_utilization_rec.org_id);
                  END IF;
               END IF;
            END IF;
         END IF;
            IF l_utilization_rec.org_id IS NULL THEN
               -- R12 yzhao: org_id is required for ozf_funds_utilized_all. get offer's org_id, otherwise user's default org
               ozf_utility_pvt.get_object_org_ledger(p_object_type => l_utilization_rec.plan_type
                                                    ,p_object_id => l_utilization_rec.plan_id
                                                    ,x_org_id => l_utilization_rec.org_id
                                                    ,x_ledger_id => l_ledger_id
                                                    ,x_return_status => l_return_status);

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
               END IF;

            ELSE
                --kdass R12 bug 4635529
                MO_UTILS.Get_Ledger_Info (
                    p_operating_unit     =>  l_utilization_rec.org_id,
                    p_ledger_id          =>  l_ledger_id,
                    p_ledger_name        =>  l_ledger_name
                );
            END IF;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   l_api_name
                                             || ': create_utilization  final org_id = '
                                             || l_utilization_rec.org_id
                                             || '  ledger_id='
                                             || l_ledger_id);
            END IF;

             --Added for bug 7030415, get the conversion type based on utilizations org_id

             --nirprasa,ER 8399134
             IF l_utilization_rec.exchange_rate_type IS NULL
             OR l_utilization_rec.exchange_rate_type = FND_API.G_MISS_CHAR THEN

             OPEN c_get_conversion_type(l_utilization_rec.org_id);
             FETCH c_get_conversion_type INTO l_utilization_rec.exchange_rate_type;
             CLOSE c_get_conversion_type;
             END IF;


            -- yzhao: R12 Oct 19 2005 No need to calculate functional currency if it is for marketing use
            IF l_ledger_id IS NULL THEN
               IF l_utilization_rec.plan_type IN ('CAMP', 'CSCH', 'EVEO', 'EVEH') AND
                  l_utilization_rec.component_type IN ('CAMP', 'CSCH', 'EVEO', 'EVEH') THEN
                  l_utilization_rec.org_id := -3116;            -- marketing object is not org aware
               ELSE
                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_api_name
                                                 || ': create_utilization   ledger not found for '
                                                 || l_utilization_rec.plan_type
                                                 || '  id('
                                                 || l_utilization_rec.plan_id);
                  END IF;
                  IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name ('OZF', 'OZF_NO_LEDGER_FOUND');
                     fnd_message.set_token('OBJECT_TYPE', l_utilization_rec.plan_type);
                     fnd_message.set_token('OBJECT_ID', l_utilization_rec.plan_id);
                     fnd_msg_pub.ADD;
                  END IF;
                  x_return_status            := fnd_api.g_ret_sts_error;
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                             || ' l_utilization_rec.exchange_rate_date1: ' || l_utilization_rec.exchange_rate_date);
               END IF;

            --nirprasa for bug 7425189, adjustment_desc is populated with justification column
            --of act_budgets recocrd.
            IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
            AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN
                l_utilization_rec.exchange_rate_type := NULL;
                ozf_utility_pvt.calculate_functional_currency (
                   p_from_amount        => l_utilization_rec.plan_curr_amount --nirprasa,ER 8399134 (replace amount by plan_curr_amount)
                  ,p_conv_date          => l_utilization_rec.exchange_rate_date
                  ,p_tc_currency_code   => l_utilization_rec.plan_currency_code
                  ,p_ledger_id          => l_ledger_id
                  ,x_to_amount          => l_utilization_rec.acctd_amount
                  ,x_mrc_sob_type_code  => l_sob_type_code
                  ,x_fc_currency_code   => l_fc_code
                  ,x_exchange_rate_type => l_utilization_rec.exchange_rate_type --Added for bug 7030415
                  ,x_exchange_rate      => l_utilization_rec.exchange_rate
                  ,x_return_status      => l_return_status
               );
            ELSE
                ozf_utility_pvt.calculate_functional_currency (
                   --nirprasa,ER 8399134 replaced amount by plan_curr_amount, currency_code
                   --by plan_currency_code. Pass exchange_rate_date, to be used for decrease earned adjustment flows
                   p_from_amount        => l_utilization_rec.plan_curr_amount
                  ,p_conv_date          => l_utilization_rec.exchange_rate_date
                  ,p_tc_currency_code   => l_utilization_rec.plan_currency_code
                  ,p_ledger_id          => l_ledger_id
                  ,x_to_amount          => l_utilization_rec.acctd_amount
                  ,x_mrc_sob_type_code  => l_sob_type_code
                  ,x_fc_currency_code   => l_fc_code
                  ,x_exchange_rate_type => l_utilization_rec.exchange_rate_type --Added for bug 7030415
                  ,x_exchange_rate      => l_utilization_rec.exchange_rate
                  ,x_return_status      => l_return_status
               );
            END IF;


               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;

         l_plan_currency        :=
            ozf_actbudgets_pvt.get_object_currency (
            l_utilization_rec.plan_type
           ,l_utilization_rec.plan_id
           ,l_return_status
         );

         l_plan_curr_amount := 0;
         l_univ_curr_amount := 0;
         IF NVL (l_utilization_rec.amount, 0) <> 0 THEN
         --Added for bug 7030415, This call will only be in case of utilization
         --So use the utilization records exchange_rate_type.
         --Added for bug 7425189,
         IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
         AND l_utilization_rec.exchange_rate_date IS NOT NULL
         AND l_utilization_rec.orig_utilization_id IS NOT NULL THEN

         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('l_utilization_rec.amount '|| l_utilization_rec.amount);
                 ozf_utility_pvt.debug_message('l_plan_curr_amount 1 '||l_plan_curr_amount);
         END IF;



            OPEN c_plan_curr_amount(l_utilization_rec.orig_utilization_id);
            FETCH c_plan_curr_amount INTO l_plan_curr_amount,l_plan_curr_amount_remaining;
            CLOSE c_plan_curr_amount;

            IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message('l_plan_curr_amount 2 '||l_plan_curr_amount);
            END IF;

             IF l_plan_curr_amount_remaining < l_plan_curr_amount THEN
                l_plan_curr_amount := nvl(l_plan_curr_amount_remaining,0);
             END IF;

             l_plan_curr_amount := nvl(-l_plan_curr_amount,0);
            IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_plan_curr_amount 3 '||l_plan_curr_amount);
            END IF;


         ELSE
            -- nirprasa, ER 8399134 Skip conversion, plan_curr_amount is
            -- already populated by calling API
         IF p_utilization_rec.plan_curr_amount IS NULL
         OR p_utilization_rec.plan_curr_amount = fnd_api.g_miss_num THEN

            IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message(' plan_curr_amount  '|| p_utilization_rec.plan_curr_amount);
                    ozf_utility_pvt.debug_message(' plan_currency_code  '|| l_utilization_rec.plan_currency_code);
                    ozf_utility_pvt.debug_message(' currency_code  '|| l_utilization_rec.currency_code);
            END IF;
            ozf_utility_pvt.convert_currency (
               p_from_currency => l_utilization_rec.currency_code
                      ,p_to_currency=> l_utilization_rec.plan_currency_code
                      --nirprasa, ER 8399134 pass exchange date also. This has value for
                      -- decrease earned adjustment type for increase_earned it is NULL.
                      ,p_conv_date=> l_utilization_rec.exchange_rate_date
                      ,p_conv_type=> l_utilization_rec.exchange_rate_type
                      ,p_from_amount=> l_utilization_rec.amount
                      ,x_return_status=> l_return_status
                      ,x_to_amount=> l_plan_curr_amount
                      ,x_rate=> l_rate
            );
          ELSE
                  l_plan_curr_amount := l_utilization_rec.plan_curr_amount;
             END IF;
             l_plan_curr_amount := l_utilization_rec.plan_curr_amount;
          END IF;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            -- R12 yzhao: convert universal currency
            IF g_universal_currency = l_utilization_rec.currency_code THEN
                l_univ_curr_amount := l_utilization_rec.amount;
            ELSIF g_universal_currency = l_utilization_rec.plan_currency_code THEN
                l_univ_curr_amount := l_plan_curr_amount;
            ELSE
               --Added for bug 7425189,
               IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
               AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN
               ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_conv_date=> l_utilization_rec.exchange_rate_date
                  ,p_from_amount=> l_plan_curr_amount
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_univ_curr_amount
                  ,x_rate=> l_rate
                );
               ELSE
               IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message('convert_currency  '|| l_utilization_rec.plan_currency_code);
                 ozf_utility_pvt.debug_message('g_universal_currency  '|| g_universal_currency);
                 ozf_utility_pvt.debug_message('exchange_rate_date  '|| l_utilization_rec.exchange_rate_date);
                 ozf_utility_pvt.debug_message('exchange_rate_type  '|| l_utilization_rec.exchange_rate_type);
               END IF;
               ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                  ,p_to_currency   => g_universal_currency
                  --nirprasa, ER 8399134 pass exchange date also. This has value for
                  --decrease earned adjustment type for increase_earned it is NULL.
                  ,p_conv_type     => l_utilization_rec.exchange_rate_type
                  ,p_conv_date     => l_utilization_rec.exchange_rate_date --bug 8532055
                  ,p_from_amount=> l_plan_curr_amount
                  ,x_return_status => l_return_status
                  ,x_to_amount     => l_univ_curr_amount
                  ,x_rate          => l_rate
                );
               END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
            END IF;
         END IF;

         -- yzhao: 11/25/2003 11.5.10 populate adjustment_date and time_id
         IF l_utilization_rec.adjustment_date IS NULL THEN
            l_utilization_rec.adjustment_date := SYSDATE;
         END IF;

         /*fix for bug 4778995
         OPEN c_get_time_id(l_utilization_rec.adjustment_date);
         FETCH c_get_time_id INTO l_utilization_rec.month_id, l_utilization_rec.quarter_id, l_utilization_rec.year_id;
         CLOSE c_get_time_id;
         */


         IF l_utilization_rec.component_type = 'OFFR' THEN
            OPEN c_offer_info(l_utilization_rec.component_id);
            FETCH c_offer_info INTO  l_offer_type, l_volume_offer_type, l_custom_setup_id;
            CLOSE c_offer_info;
         END IF;


         -- kdass bug 7835764 - added reference_id and reference_type to adjustments linked to Ship & Debit Requests
         IF l_custom_setup_id = 118 THEN
            OPEN c_sd_request_header_id(l_utilization_rec.component_id);
            FETCH c_sd_request_header_id INTO l_utilization_rec.reference_id;
            CLOSE c_sd_request_header_id;
            l_utilization_rec.reference_type := 'SD_REQUEST';
         END IF;

         -- yzhao: 11.5.10 populate cust_account_id with offer's beneficiary account, otherwise billto cust account id
        IF l_utilization_rec.cust_account_id IS NULL THEN
            l_utilization_rec.cust_account_id := l_utilization_rec.billto_cust_account_id;
         /*    IF l_utilization_rec.component_type = 'OFFR' THEN
               IF l_beneficiary_account_id IS NOT NULL THEN
                  l_utilization_rec.cust_account_id := l_beneficiary_account_id;
               END IF;
             END IF;
        */
        END IF;

         -- add by feliu on 12/31/2003
         IF l_utilization_rec.gl_date IS NULL THEN
            IF l_utilization_rec.adjustment_date IS NULL THEN
               l_utilization_rec.gl_date := SYSDATE;
            ELSE
               l_utilization_rec.gl_date := l_utilization_rec.adjustment_date;
            END IF;
         END IF;

          --nirprasa, fix for bug 8940036. Make sure that the utilization record is not for marketing objects
         --and the adjustment is only for budget adjustment from public API/UI.
         IF l_ledger_id IS NOT NULL AND l_utilization_rec.adjustment_type_id > -1
            AND l_utilization_rec.utilization_type = 'ADJUSTMENT' THEN
            OPEN c_getClosedPeriods (l_ledger_id,l_utilization_rec.gl_date);
            LOOP
            FETCH c_getClosedPeriods INTO l_periods, l_begin_date, l_end_date, l_period_status;
            EXIT WHEN c_getClosedPeriods%NOTFOUND;

               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name ('OZF', 'OZF_GLT_PERIOD_CLOSED');
                  fnd_message.set_token('PERIOD', l_periods);
                  fnd_message.set_token('SOB_NAME', l_ledger_name);
                  fnd_msg_pub.ADD;
               END IF;
               RAISE fnd_api.g_exc_error;
            END LOOP;
            CLOSE c_getClosedPeriods;
         END IF;
         --nirprasa, end of fix for bug 8940036.

         OPEN c_fund_b (l_utilization_rec.fund_id);
         FETCH c_fund_b INTO l_utilized_amt
                            ,l_earned_amt
                            ,l_obj_num
                            ,l_committed_amt
                            ,l_accrual_basis
                            ,l_fund_type
                            ,l_original_budget
                            ,l_paid_amt
                            ,l_plan_id
                            ,l_liability_flag
                            ,l_recal_comm_amt;
         IF (c_fund_b%NOTFOUND) THEN
            CLOSE c_fund_b;

            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.ADD;
            END IF;

            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE c_fund_b;

         IF l_fund_type = 'FULLY_ACCRUED' AND
            l_plan_id IS NOT NULL AND l_plan_id <> FND_API.g_miss_num THEN
            -- Bug # 7337263 fixed by ateotia (+)
            -- Added a condition for Chargeback Batch using Fully Accrued budget.
            --IF l_utilization_rec.component_type = 'OFFR' AND
            IF l_utilization_rec.component_type IN ('OFFR','PRIC') AND
            -- Bug # 7337263 fixed by ateotia (-)
               l_plan_id <>  l_utilization_rec.component_id  THEN
               l_fund_type := 'FIXED' ;
            END IF;
         END IF;

        --nirprasa,ER 8399134. Added this conversion for null currency offers
        IF G_DEBUG THEN
        ozf_utility_pvt.debug_message(' fund_request_currency_code  '|| l_utilization_rec.fund_request_currency_code);
        ozf_utility_pvt.debug_message(' plan_currency_code  '|| l_utilization_rec.plan_currency_code);
        END IF;

        IF l_utilization_rec.plan_currency_code <> l_utilization_rec.fund_request_currency_code THEN
                ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                              ,p_from_currency => l_utilization_rec.plan_currency_code
                              ,p_to_currency   => l_utilization_rec.fund_request_currency_code
                              ,p_conv_type     => l_utilization_rec.exchange_rate_type -- Added for bug 7030415
                              --nirprasa, ER 8399134 pass exchange date also. This has value for
                              --decrease earned adjustment type for increase_earned it is NULL.
                              ,p_conv_date     => l_utilization_rec.exchange_rate_date
                              ,p_from_amount   => l_utilization_rec.plan_curr_amount
                              ,x_to_amount     => l_utilization_rec.fund_request_amount
                              ,x_rate          => l_rate
                             );
        ELSE
                l_utilization_rec.fund_request_amount := l_utilization_rec.plan_curr_amount;
        END IF;

        l_utilization_rec.fund_request_amount := ozf_utility_pvt.currround(l_utilization_rec.fund_request_amount , l_utilization_rec.fund_request_currency_code);


         --l_utilization_rec.gl_posted_flag := NULL; --could have value for adjustment.
         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
         IF p_utilization_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST') THEN
          */
             ozf_funds_pvt.init_fund_rec (x_fund_rec => l_fund_rec);

             -- R12: yzhao ozf_object_fund_summary
             l_objfundsum_rec := NULL;
             OPEN c_get_objfundsum_rec(l_utilization_rec.component_type
                                     , l_utilization_rec.component_id
                                     , l_utilization_rec.fund_id);
             FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                           , l_objfundsum_rec.object_version_number
                                           , l_objfundsum_rec.committed_amt
                                           , l_objfundsum_rec.recal_committed_amt
                                           , l_objfundsum_rec.utilized_amt
                                           , l_objfundsum_rec.earned_amt
                                           , l_objfundsum_rec.paid_amt
                                           , l_objfundsum_rec.plan_curr_committed_amt
                                           , l_objfundsum_rec.plan_curr_recal_committed_amt
                                           , l_objfundsum_rec.plan_curr_utilized_amt
                                           , l_objfundsum_rec.plan_curr_earned_amt
                                           , l_objfundsum_rec.plan_curr_paid_amt
                                           , l_objfundsum_rec.univ_curr_committed_amt
                                           , l_objfundsum_rec.univ_curr_recal_committed_amt
                                           , l_objfundsum_rec.univ_curr_utilized_amt
                                           , l_objfundsum_rec.univ_curr_earned_amt
                                           , l_objfundsum_rec.univ_curr_paid_amt;
             CLOSE c_get_objfundsum_rec;
             -- R12: yzhao END ozf_object_fund_summary

            -- yzhao: 27-JUL-2005 - R12 paid adjustment can be done through public api
            IF l_utilization_rec.utilization_type = 'ADJUSTMENT' AND
               NVL(l_utilization_rec.adjustment_type, ' ') IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
               l_gl_posted := true;
            ELSE
                 IF l_fund_type = 'FULLY_ACCRUED' THEN  -- for fully accrual budget
                      -- for a fully accrued custoemr fund the budgeted and utilized column and committed column get populated
                      --  gl_posted_flag is 'N'
                      IF l_accrual_basis = 'CUSTOMER' AND NVL(l_liability_flag, 'N') = 'Y' THEN
                         l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;     -- 'N', waiting for gl posting
                         l_gl_posted := true;
                         IF p_utilization_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') AND
                            l_utilization_rec.orig_utilization_id IS NOT NULL THEN
                             -- fix bug 3348955 - gl posting to adjustment should be in sync with original order's utilization
                             l_orig_gl_flag := NULL;
                             OPEN c_get_orig_gl_flag(l_utilization_rec.orig_utilization_id);
                             FETCH c_get_orig_gl_flag INTO l_orig_gl_flag;
                             CLOSE c_get_orig_gl_flag;
                             IF l_orig_gl_flag = ozf_accrual_engine.G_GL_FLAG_NO THEN
                                -- do not post to gl now, wait for the original utilization's posting
                                l_gl_posted := false;
                             END IF;
                         END IF;   -- IF orig_utilization_id IS NOT NULL

                         l_fund_rec.original_budget :=
                                      (  NVL (l_original_budget, 0)
                                       + NVL (l_utilization_rec.amount, 0)
                                      );
                         l_fund_rec.utilized_amt      :=
                                                NVL (l_utilized_amt, 0)
                                              + NVL (l_utilization_rec.amount, 0);

                         -- yzhao: 10/20/2003 committed column gets populated too
                         --        11/06/2003 for manual adjustment, DECREASE_COMM_EARNED, java does not create transfer record for fully accrual budget any more
                         l_fund_rec.committed_amt   := NVL (l_committed_amt, 0) + NVL (l_utilization_rec.amount, 0);
                         l_fund_rec.recal_committed := NVL (l_recal_comm_amt, 0) + NVL (l_utilization_rec.amount, 0);

                         -- R12: yzhao ozf_object_fund_summary update utilized/committed amt
                         l_objfundsum_rec.utilized_amt := NVL(l_objfundsum_rec.utilized_amt, 0) + NVL(l_utilization_rec.amount, 0);
                         l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_objfundsum_rec.plan_curr_utilized_amt, 0)
                                                                  + NVL(l_utilization_rec.fund_request_amount, 0);
                         l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_objfundsum_rec.univ_curr_utilized_amt, 0)
                                                                  + NVL(l_univ_curr_amount, 0);
                         l_objfundsum_rec.committed_amt := NVL(l_objfundsum_rec.committed_amt, 0) + NVL(l_utilization_rec.amount, 0);
                         l_objfundsum_rec.plan_curr_committed_amt := NVL(l_objfundsum_rec.plan_curr_committed_amt, 0)
                                                                  + NVL(l_plan_curr_amount, 0);
                         l_objfundsum_rec.univ_curr_committed_amt := NVL(l_objfundsum_rec.univ_curr_committed_amt, 0)
                                                                  + NVL(l_univ_curr_amount, 0);
                         l_objfundsum_rec.recal_committed_amt := NVL(l_objfundsum_rec.recal_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.amount, 0);
                         l_objfundsum_rec.plan_curr_recal_committed_amt := NVL(l_objfundsum_rec.plan_curr_recal_committed_amt, 0)
                                                                  + NVL(l_plan_curr_amount, 0);
                         l_objfundsum_rec.univ_curr_recal_committed_amt := NVL(l_objfundsum_rec.univ_curr_recal_committed_amt, 0)
                                                                  + NVL(l_univ_curr_amount, 0);
                         -- R12: yzhao END ozf_object_fund_summary update

                         -- 10/14/2003  update ozf_act_budgets REQUEST between fully accrual budget and its offer when accrual happens
                         OPEN  c_accrual_budget_reqeust(l_utilization_rec.fund_id, l_plan_id);
                         FETCH c_accrual_budget_reqeust INTO l_act_budget_id, l_act_budget_objver;
                         IF (c_accrual_budget_reqeust%NOTFOUND) THEN
                            CLOSE c_accrual_budget_reqeust;
                            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                               fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
                               fnd_msg_pub.ADD;
                            END IF;
                            RAISE fnd_api.g_exc_error;
                         END IF;
                         CLOSE c_accrual_budget_reqeust;

                         UPDATE ozf_act_budgets
                         SET    request_amount = NVL(request_amount, 0) + l_plan_curr_amount
                              , src_curr_request_amt = NVL(src_curr_request_amt, 0) + l_utilization_rec.amount
                              , approved_amount = NVL(approved_amount, 0) + l_plan_curr_amount
                              , approved_original_amount = NVL(approved_original_amount, 0) + l_utilization_rec.amount
                              , approved_amount_fc = NVL(approved_amount_fc, 0) + l_utilization_rec.acctd_amount
                              , last_update_date = sysdate
                              , last_updated_by = NVL (fnd_global.user_id, -1)
                              , last_update_login = NVL (fnd_global.conc_login_id, -1)
                              , object_version_number = l_act_budget_objver + 1
                         WHERE  activity_budget_id = l_act_budget_id
                         AND    object_version_number = l_act_budget_objver;

                         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
                         OPEN c_budget_request_utilrec(l_utilization_rec.fund_id, l_plan_id, l_act_budget_id);
                         FETCH c_budget_request_utilrec INTO l_act_budget_id, l_act_budget_objver;
                         IF (c_budget_request_utilrec%NOTFOUND) THEN
                             CLOSE c_budget_request_utilrec;
                             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                                fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
                                fnd_msg_pub.ADD;
                             END IF;
                             RAISE fnd_api.g_exc_error;
                         END IF;
                         CLOSE c_budget_request_utilrec;

                         -- populate request amount in ozf_funds_utilized_all_b record
                         UPDATE ozf_funds_utilized_all_b
                         SET    amount = NVL(amount, 0) + NVL(l_utilization_rec.amount, 0)
                               , plan_curr_amount = NVL(plan_curr_amount, 0) + NVL(l_plan_curr_amount, 0)
                               , univ_curr_amount = NVL(univ_curr_amount, 0) + NVL(l_univ_curr_amount, 0)
                               , acctd_amount = NVL(acctd_amount, 0) + NVL(l_utilization_rec.acctd_amount, 0)
                               , last_update_date = sysdate
                               , last_updated_by = NVL (fnd_global.user_id, -1)
                               , last_update_login = NVL (fnd_global.conc_login_id, -1)
                               , object_version_number = l_act_budget_objver + 1
                         WHERE  utilization_id = l_act_budget_id
                         AND    object_version_number = l_act_budget_objver;
                           yzhao END: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
                         */
                         -- yzhao: 10/20/2003 END Fix TEVA bug - customer fully accrual budget committed amount is always 0

                         IF l_utilization_rec.orig_utilization_id IS NOT NULL THEN
                             -- fix bug 3348955 - gl posting to adjustment should be in sync with original order's utilization
                             OPEN c_get_orig_gl_flag(l_utilization_rec.orig_utilization_id);
                             FETCH c_get_orig_gl_flag INTO l_orig_gl_flag;
                             CLOSE c_get_orig_gl_flag;
                             IF l_orig_gl_flag = ozf_accrual_engine.G_GL_FLAG_NO THEN
                                -- do not post to gl now, wait for the original utilization's posting
                                l_gl_posted := false;
                             END IF;
                         END IF;   -- IF orig_utilization_id IS NOT NULL

                      /* yzhao: 10/20/2003 sales accrual and customer accrual with liability_flag off, only total column gets populated
                                           no gl posting
                      ELSIF l_accrual_basis = 'SALES' THEN
                       */
                      ELSE
                         IF l_utilization_rec.orig_utilization_id IS NOT NULL THEN
                             -- fix bug 3348955 - gl posting to adjustment should be in sync with original order's utilization
                            OPEN c_get_orig_gl_flag(l_utilization_rec.orig_utilization_id);
                            FETCH c_get_orig_gl_flag INTO l_orig_gl_flag;
                            CLOSE c_get_orig_gl_flag;
                         END IF;

                         IF l_orig_gl_flag = ozf_accrual_engine.G_GL_FLAG_NO THEN
                                -- do not post to gl now, wait for the original utilization's posting
                               l_gl_posted := false;
                               l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;
                               l_utilization_rec.amount_remaining := NULL;     -- no amount remaining
                         ELSE
                            l_utilization_rec.amount_remaining := NULL;     -- no amount remaining
                            l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NOLIAB;  -- 'X', do not post to gl
                            l_fund_rec.original_budget :=
                                      (  NVL (l_original_budget, 0)
                                       + NVL (l_utilization_rec.amount, 0)
                                      );
                         END IF;   -- IF orig_utilization_id IS NOT NULL
                      END IF;

                 ELSE  -- for fixed budget
                     l_fund_rec.utilized_amt := NVL (l_utilized_amt, 0) + NVL (l_utilization_rec.amount, 0);
                     -- R12: yzhao ozf_object_fund_summary update utilized_amt
                     l_objfundsum_rec.utilized_amt := NVL(l_objfundsum_rec.utilized_amt, 0) + NVL(l_utilization_rec.amount, 0);
                     l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_objfundsum_rec.plan_curr_utilized_amt, 0)
                                                              + NVL(l_utilization_rec.fund_request_amount, 0);
                     l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_objfundsum_rec.univ_curr_utilized_amt, 0)
                                                              + NVL(l_univ_curr_amount, 0);
                     IF p_utilization_rec.utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL', 'CHARGEBACK') THEN
                        l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;  -- 'N', waiting for posting to gl
                        l_gl_posted := true;
                     ELSE  -- p_utilization_rec.utilization_type IN ('UTILIZED', 'ADJUSTMENT', 'LEAD_ADJUSTMENT')
                        IF p_utilization_rec.component_type <> 'OFFR' THEN

                            IF p_utilization_rec.component_type = 'PRIC' THEN
                                 l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;  -- 'N', waiting for posting to gl
                                 l_utilization_rec.amount_remaining := l_utilization_rec.amount;
                                 l_gl_posted := true;
                            ELSE
                                 -- no gl posting for marketing objects, increase earned and paid amount immediately
                                 l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NULL;  -- null
                                 l_utilization_rec.amount_remaining := NULL;     -- no amount remaining for off-invoice utilization/adjustment
                                 l_fund_rec.earned_amt := NVL (l_earned_amt, 0) + NVL (l_utilization_rec.amount, 0);
                                 l_fund_rec.paid_amt := NVL (l_paid_amt, 0) + NVL (l_utilization_rec.amount, 0);
                                 -- R12: yzhao ozf_object_fund_summary update earned and paid amt
                                 l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0) + NVL(l_utilization_rec.amount, 0);
                                 l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                                                          + NVL(l_utilization_rec.fund_request_amount, 0);
                                 l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                                                          + NVL(l_univ_curr_amount, 0);
                                 l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(l_utilization_rec.amount, 0);
                                 l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                          + NVL(l_utilization_rec.fund_request_amount, 0);
                                 l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                          + NVL(l_univ_curr_amount, 0);
                                 -- R12: yzhao END ozf_object_fund_summary update
                             END IF;  -- end of PRIC type

                        ELSE  -- offer utilization
                             IF p_utilization_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') THEN
                                 --always post to gl for offer's adjustment, regardless of accrual offer or off-invoice offer
                                 l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;  -- 'N', waiting for posting to gl
                                 l_utilization_rec.amount_remaining := l_utilization_rec.amount;
                                 l_gl_posted := true;
                                 IF l_utilization_rec.orig_utilization_id IS NOT NULL THEN
                                     -- fix bug 3348955 - gl posting to adjustment should be in sync with original order's utilization
                                     l_orig_gl_flag := NULL;
                                     OPEN c_get_orig_gl_flag(l_utilization_rec.orig_utilization_id);
                                     FETCH c_get_orig_gl_flag INTO l_orig_gl_flag;
                                     CLOSE c_get_orig_gl_flag;
                                     IF l_orig_gl_flag = ozf_accrual_engine.G_GL_FLAG_NO THEN
                                        -- do not post to gl now, wait for the original utilization's posting
                                        l_gl_posted := false;
                                     END IF;
                                    IF l_utilization_rec.orig_utilization_id = -1 THEN -- for bug 6021635
                                        l_gl_posted := false;
                                      END IF;
                                 END IF;   -- IF orig_utilization_id IS NOT NULL
                             ELSE  -- 'UTILIZED' for offer
                                 IF l_offer_type IN ('ACCRUAL', 'NET_ACCRUAL', 'LUMPSUM', 'SCAN_DATA') THEN
                                    -- handle case for reconcile when l_utilization_rec.gl_posted_flag passed.
                                    IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_YES OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := true;
                                    END IF;
                                 ELSIF l_offer_type = 'VOLUME_OFFER' THEN
                                    IF l_volume_offer_type = 'OFF_INVOICE'  THEN
                                       IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_NO OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := false;
                                       END IF;
                                    ELSE
                                       IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_YES OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := true;
                                       END IF;
                                    END IF;
                                 ELSIF l_offer_type = 'DEAL' THEN
                                    l_tmp_id := NULL;
                                    OPEN c_get_deal_accrual_flag(l_utilization_rec.component_id
                                                               , l_utilization_rec.product_level_type, l_utilization_rec.product_id);
                                    FETCH c_get_deal_accrual_flag INTO l_tmp_id;
                                    CLOSE c_get_deal_accrual_flag;
                                    IF l_tmp_id = 1 THEN
                                       IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_YES OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := true;
                                       END IF;
                                    ELSE
                                       IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_NO OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := false;
                                       END IF;
                                    END IF;
                                 ELSE  -- 'OFF_INVOICE', 'OID', 'ORDER', 'TERMS'
                                       IF l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_NO OR
                                         l_utilization_rec.gl_posted_flag is NULL THEN
                                         l_offer_accrual_flag := false;
                                       END IF;
                                 END IF;

                                 IF l_offer_accrual_flag THEN
                                    l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;     -- 'N', waiting for gl posting
                                    l_utilization_rec.amount_remaining := l_utilization_rec.amount;
                                    l_gl_posted := true;
                                 ELSIF l_offer_accrual_flag = false THEN
                                    IF p_utilization_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') THEN
                                        l_utilization_rec.amount_remaining := l_utilization_rec.amount;     -- wait for claim for adjustment
                                    ELSE  -- 'UTILIZED'
                                        l_utilization_rec.amount_remaining := NULL;     -- no amount remaining for off-invoice utilization
                                    END IF;
                                    OPEN c_offinvoice_gl_post_flag(l_utilization_rec.org_id);
                                    FETCH c_offinvoice_gl_post_flag INTO l_offinvoice_gl_post_flag;
                                    CLOSE c_offinvoice_gl_post_flag;
                                    IF (l_offinvoice_gl_post_flag = 'F') THEN
                                        l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NULL;  -- null
                                        l_fund_rec.earned_amt := NVL (l_earned_amt, 0) + NVL (l_utilization_rec.amount, 0);
                                        -- R12: yzhao ozf_object_fund_summary update earned and paid amt
                                        l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0) + NVL(l_utilization_rec.amount, 0);
                                        l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                                                               + NVL(l_plan_curr_amount, 0);
                                        l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                                                               + NVL(l_univ_curr_amount, 0);
                                        -- R12: yzhao END ozf_object_fund_summary update
                                        -- yzhao: fix bug 3741127 do not update paid amount for off-invoice offer adjustment
                                        IF p_utilization_rec.utilization_type NOT IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') THEN  -- 'UTILIZED'
                                           l_fund_rec.paid_amt := NVL (l_paid_amt, 0) + NVL (l_utilization_rec.amount, 0);
                                           -- R12: yzhao
                                           l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(l_utilization_rec.amount, 0);
                                           l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                                + NVL(l_plan_curr_amount, 0);
                                           l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                                + NVL(l_univ_curr_amount, 0);
                                        END IF;
                                    ELSE
                                       l_utilization_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;  -- 'N', waiting for posting to gl
                                       l_gl_posted := true;
                                    END IF;
                                 ELSE  -- for reconcile when original gl_posted_flag = 'N' and  'F'
                                    l_gl_posted := false;
                                 END IF;  -- l_offer_accrual_flag
                            END IF;  -- IF p_utilization_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT')
                        END IF;    -- IF p_utilization_rec.plan_type <> 'OFFR'
                     END IF; -- IF p_utilization_rec.utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL', 'CHARGEBACK')
                 END IF;  -- IF l_fund_type = 'FULLY_ACCRUED'
             END IF;  -- IF l_utilization_rec.utilization_type <> 'ADJUSTMENT' OR
                      --    NVL(l_utilization_rec.adjustment_type, ' ') NOT IN ('INCREASE_PAID', 'DECREASE_PAID')
         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
         END IF;  -- IF p_utilization_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST')
          */

         /*kdass 07-FEB-2006 bug 5008257 - Post to GL for offer adjustment on order's adjustment.
           -> if profile 'Post to Gl' is set to 'shipped', post to GL after order is shipped.
           -> if profile 'Post to Gl' is set to 'invoiced', post to GL after order is invoiced.
           -> for returned order, post to gl only after order is invoiced.
         */

         /*ozf_utility_pvt.write_conc_log('NP orig_utilization_id '|| p_utilization_rec.orig_utilization_id);
         ozf_utility_pvt.write_conc_log('NP object_type '|| p_utilization_rec.object_type);
         ozf_utility_pvt.write_conc_log('NP object_type '|| p_utilization_rec.object_id);
         ozf_utility_pvt.write_conc_log('NP object_type '|| p_utilization_rec.order_line_id);
         ozf_utility_pvt.write_conc_log('NP object_type '|| p_utilization_rec.component_type);*/

         --nirprasa,ER 8399134 comment this code since its not needed now.gl_date should be sysdate
         --for all types of adjustments as per multi currency enhancement
         /*IF l_gl_posted AND p_utilization_rec.utilization_type = 'ADJUSTMENT'
            AND p_utilization_rec.orig_utilization_id IS NULL AND p_utilization_rec.component_type = 'OFFR'
            AND p_utilization_rec.object_type = 'ORDER' AND p_utilization_rec.object_id IS NOT NULL
            AND p_utilization_rec.order_line_id IS NOT NULL
            AND p_utilization_rec.adjustment_type_id < 0
         THEN

            l_gl_date := NULL;
            l_order_gl_phase := NVL(fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE'), 'SHIPPED');

            ozf_utility_pvt.write_conc_log('gl posting phase: ' || l_order_gl_phase);

            OPEN c_order_line (l_utilization_rec.order_line_id);
            FETCH c_order_line INTO l_line_category_code, l_shipped_quantity, l_flow_status_code,
                                    l_invoice_status_code, l_invoiced_quantity, l_actual_shipment_date;
            CLOSE c_order_line;

            IF (l_order_gl_phase = 'SHIPPED' AND l_line_category_code <> 'RETURN' AND
                NVL(l_shipped_quantity,0) <> 0 AND  l_flow_status_code = 'SHIPPED') THEN

               l_gl_date := l_actual_shipment_date;
               ozf_utility_pvt.write_conc_log('use actual shipment date for gl date');
            END IF;

            IF l_gl_date IS NULL THEN
               IF (l_invoice_status_code = 'YES' OR NVL(l_invoiced_quantity,0) <> 0) THEN

                  -- get order_number
                  OPEN c_order_num (l_utilization_rec.object_id);
                  FETCH c_order_num INTO l_order_number;
                  CLOSE c_order_num;

                  OPEN c_invoice_date(l_utilization_rec.order_line_id, l_order_number);
                  FETCH c_invoice_date INTO l_gl_date;
                  CLOSE c_invoice_date;

                  IF l_gl_date IS NULL THEN
                     l_gl_date := sysdate;
                     ozf_utility_pvt.write_conc_log('auto-invoice not complete. use sysdate for gl date');
                  END IF;
               END IF;
            END IF;

            IF l_gl_date IS NULL THEN
               l_gl_posted := FALSE;
               ozf_utility_pvt.write_conc_log('adjustment will not be posted to gl');
            ELSE
               l_utilization_rec.gl_date := l_gl_date;
               ozf_utility_pvt.write_conc_log('gl date: ' || l_gl_date);
            END IF;

         END IF; --IF l_gl_posted AND p_utilization_rec.utilization_type = 'ADJUSTMENT' .....
        */
        --end of comments
         l_utilization_rec.univ_curr_amount := l_univ_curr_amount;
         IF NVL(l_utilization_rec.amount_remaining, 0) = 0 THEN
            l_utilization_rec.acctd_amount_remaining := l_utilization_rec.amount_remaining;
            l_utilization_rec.univ_curr_amount_remaining := l_utilization_rec.amount_remaining;
            l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.amount_remaining;
         ELSE
            l_utilization_rec.amount_remaining :=  ozf_utility_pvt.currround(l_utilization_rec.amount_remaining
                                                 , l_utilization_rec.currency_code);
            -- nirprasa,12.1.1 retreive acctd_amount_remaining from plan_curr_amount_remaining
            -- and round it.
	    --nepanda : 9662148 : moving the calculation of acctd_amt_rem to below as plan_curr_amt_rem is not yet calculated here and is null
           /*
            l_utilization_rec.acctd_amount_remaining :=
               l_utilization_rec.exchange_rate * l_utilization_rec.plan_curr_amount_remaining ;
            l_utilization_rec.acctd_amount_remaining :=  ozf_utility_pvt.currround(l_utilization_rec.acctd_amount_remaining
                                                 , l_fc_code);     */

            --Added for bug 7425189
            IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
            AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN

            OPEN c_plan_curr_amount_remaining(l_utilization_rec.orig_utilization_id);
            FETCH c_plan_curr_amount_remaining INTO l_plan_curr_amount_remaining;
            CLOSE c_plan_curr_amount_remaining;

            l_plan_curr_amount_remaining := nvl(-l_plan_curr_amount_remaining,0);

            ELSE

                IF p_utilization_rec.plan_curr_amount_remaining IS NULL
                OR p_utilization_rec.plan_curr_amount_remaining = fnd_api.g_miss_num THEN
                   ozf_utility_pvt.convert_currency (
                       p_from_currency => l_utilization_rec.currency_code
                      ,p_to_currency   => l_plan_currency
                      --nirprasa, ER 8399134 pass exchange date also. This has value for
                      --decrease earned adjustment type. for increase_earned it is NULL
                      ,p_conv_type     => l_utilization_rec.exchange_rate_type
                      ,p_conv_date     => l_utilization_rec.exchange_rate_date --bug 8532055
                      ,p_from_amount   => l_utilization_rec.amount_remaining
                      ,x_return_status => l_return_status
                      ,x_to_amount     => l_plan_curr_amount_remaining
                      ,x_rate          => l_rate
                    );
                ELSE
                  l_plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount_remaining;
                END IF;
            END IF;

            l_plan_curr_amount_remaining := ozf_utility_pvt.currround(l_plan_curr_amount_remaining
                                                              , l_utilization_rec.plan_currency_code);
            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

	    --nepanda : 9662148 : moved the calculation of acctd_amt_rem here from above
	    --calculating with l_plan_curr_amount_remaining instead of l_utilization_rec.plan_curr_amount_remaining
	    l_utilization_rec.acctd_amount_remaining :=
               l_utilization_rec.exchange_rate * l_plan_curr_amount_remaining ;
            l_utilization_rec.acctd_amount_remaining :=  ozf_utility_pvt.currround(l_utilization_rec.acctd_amount_remaining
                                                 , l_fc_code);

            --nirprasa,ER 8399134
            --fix for bug 8586014 added AND
                IF (p_utilization_rec.fund_request_amount_remaining IS NULL
                OR p_utilization_rec.fund_request_amount_remaining = fnd_api.g_miss_num) THEN
                        IF l_utilization_rec.fund_request_currency_code = l_utilization_rec.plan_currency_code THEN
                                l_utilization_rec.fund_request_amount_remaining := l_plan_curr_amount_remaining;
                        ELSIF l_utilization_rec.fund_request_currency_code = l_utilization_rec.currency_code THEN
                                l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.amount_remaining;
                        ELSIF  l_utilization_rec.fund_request_currency_code = l_fc_code THEN
                                l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.acctd_amount_remaining;
                        ELSE
                                ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                              ,p_from_currency => l_utilization_rec.plan_currency_code
                              --nirprasa, ER 8399134 pass exchange date also. This has value for
                              --decrease earned adjustment type for increase_earned it is NULL.
                              ,p_conv_date     => l_utilization_rec.exchange_rate_date
                              ,p_to_currency   => l_utilization_rec.fund_request_currency_code
                              ,p_conv_type     => l_utilization_rec.exchange_rate_type -- Added for bug 7030415
                              ,p_from_amount   => l_utilization_rec.plan_curr_amount_remaining
                              ,x_to_amount     => l_utilization_rec.fund_request_amount_remaining
                              ,x_rate          => l_rate
                             );
                        END IF;
                END IF;

            -- R12 yzhao: convert universal currency
            IF g_universal_currency = l_utilization_rec.currency_code THEN
                l_utilization_rec.univ_curr_amount_remaining := l_utilization_rec.amount_remaining;
             ELSIF g_universal_currency = l_utilization_rec.plan_currency_code THEN
                l_utilization_rec.univ_curr_amount_remaining := l_plan_curr_amount_remaining;
             ELSE
                --Added for bug 7425189,
                IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN
                ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_conv_date=> l_utilization_rec.exchange_rate_date
                  ,p_from_amount=> l_plan_curr_amount_remaining
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_utilization_rec.univ_curr_amount_remaining
                  ,x_rate=> l_rate
                );
                ELSE
                   ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                     ,p_to_currency   => g_universal_currency
                  --nirprasa, ER 8399134 pass exchange date also. This has value for
                  --decrease earned adjustment type for increase_earned it is NULL.
                     ,p_conv_type     => l_utilization_rec.exchange_rate_type
                     ,p_conv_date     => l_utilization_rec.exchange_rate_date --bug 8532055
                  ,p_from_amount=> l_plan_curr_amount_remaining
                     ,x_return_status => l_return_status
                     ,x_to_amount     => l_utilization_rec.univ_curr_amount_remaining
                     ,x_rate          => l_rate
                   );
                END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
             END IF;

         END IF;

         /*--kdass 27-JUL-2005 - R12 change for paid adjustments
         IF l_utilization_rec.utilization_type = 'ADJUSTMENT' AND
            NVL(l_utilization_rec.adjustment_type, ' ') IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
            l_utilization_rec.amount_remaining := - l_utilization_rec.amount_remaining;
            l_utilization_rec.acctd_amount_remaining := - l_utilization_rec.acctd_amount_remaining;
            l_utilization_rec.univ_curr_amount_remaining := - l_utilization_rec.univ_curr_amount_remaining;
            l_plan_curr_amount_remaining := - l_plan_curr_amount_remaining;
            l_utilization_rec.amount := 0;
            l_utilization_rec.acctd_amount := 0;
            l_plan_curr_amount := 0;
            l_utilization_rec.univ_curr_amount := 0;
         END IF;
          */
         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl amount '||l_utilization_rec.amount);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl acctd amount '||l_utilization_rec.acctd_amount);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl plan_curr_amount '|| l_plan_curr_amount);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl fund_request_amount '||l_utilization_rec.fund_request_amount);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl amount_remaining '||l_utilization_rec.amount_remaining);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl acctd_amount_remaining '||l_utilization_rec.acctd_amount_remaining);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl plan_curr_amount_remaining '||l_plan_curr_amount_remaining);
         ozf_utility_pvt.debug_message('amount in ozf_funds util tbl fund_request_amount_remaining '||l_utilization_rec.fund_request_amount_remaining);
         ozf_utility_pvt.debug_message ('exchange_rate l_converted_amt ' || l_utilization_rec.exchange_rate);
         ozf_utility_pvt.debug_message ('l_utilization_rec.org_id ' || l_utilization_rec.org_id);
         END IF;

         INSERT INTO ozf_funds_utilized_all_b
                     (utilization_id
                     ,last_update_date
                     ,last_updated_by
                     ,last_update_login
                     ,creation_date
                     ,created_by
                     ,created_from
                     ,request_id
                     ,program_application_id
                     ,program_id
                     ,program_update_date
                     ,utilization_type
                     ,fund_id
                     ,plan_type
                     ,plan_id
                     ,component_type
                     ,component_id
                     ,object_type
                     ,object_id
                     ,order_id
                     ,invoice_id
                     ,amount
                     ,acctd_amount
                     ,currency_code
                     ,exchange_rate_type
                     ,exchange_rate_date
                     ,exchange_rate
                     ,adjustment_type
                     ,adjustment_date
                     ,object_version_number
                     ,attribute_category
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,attribute4
                     ,attribute5
                     ,attribute6
                     ,attribute7
                     ,attribute8
                     ,attribute9
                     ,attribute10
                     ,attribute11
                     ,attribute12
                     ,attribute13
                     ,attribute14
                     ,attribute15
                     ,org_id
                     ,adjustment_type_id
                     ,camp_schedule_id
                     ,gl_date
                     ,product_level_type
                     ,product_id
                     ,ams_activity_budget_id
                     ,amount_remaining
                     ,acctd_amount_remaining
                     ,cust_account_id
                     ,price_adjustment_id
                     ,plan_curr_amount
                     ,plan_curr_amount_remaining
                     ,scan_unit
                     ,scan_unit_remaining
                     ,activity_product_id
                     ,volume_offer_tiers_id
                     ,gl_posted_flag
                     --  11/04/2003   yzhao     11.5.10: added
                     ,billto_cust_account_id
                     ,reference_type
                     ,reference_id
                     /*fix for bug 4778995
                     ,month_id
                     ,quarter_id
                     ,year_id
                     */
                     -- 01/02/2004 kdass added for 11.5.10
                     ,order_line_id
                     ,orig_utilization_id
                     ,bill_to_site_use_id
                     ,ship_to_site_use_id
                     ,univ_curr_amount
                     ,univ_curr_amount_remaining
                     ,fund_request_currency_code
                     ,fund_request_amount
                     ,fund_request_amount_remaining
                     ,plan_currency_code
             )
              VALUES (l_utilization_rec.utilization_id
                     ,SYSDATE -- LAST_UPDATE_DATE
                     ,NVL (fnd_global.user_id, -1) -- LAST_UPDATED_BY
                     ,NVL (fnd_global.conc_login_id, -1) -- LAST_UPDATE_LOGIN
                     ,SYSDATE -- CREATION_DATE
                     ,NVL (fnd_global.user_id, -1) -- CREATED_BY
                     ,l_utilization_rec.created_from -- CREATED_FROM
                     ,fnd_global.conc_request_id -- REQUEST_ID
                     ,fnd_global.prog_appl_id -- PROGRAM_APPLICATION_ID
                     ,fnd_global.conc_program_id -- PROGRAM_ID
                     ,SYSDATE -- PROGRAM_UPDATE_DATE
                     ,l_utilization_rec.utilization_type
                     ,l_utilization_rec.fund_id
                     ,l_utilization_rec.plan_type
                     ,l_utilization_rec.plan_id
                     ,l_utilization_rec.component_type
                     ,l_utilization_rec.component_id
                     ,l_utilization_rec.object_type
                     ,l_utilization_rec.object_id
                     ,l_utilization_rec.order_id
                     ,l_utilization_rec.invoice_id
                     ,l_utilization_rec.amount
                     ,l_utilization_rec.acctd_amount
                     ,l_utilization_rec.currency_code
                     ,l_utilization_rec.exchange_rate_type
                     ,NVL (l_utilization_rec.exchange_rate_date, SYSDATE)
                     ,l_utilization_rec.exchange_rate
                     ,l_utilization_rec.adjustment_type
                     ,NVL(l_utilization_rec.adjustment_date,SYSDATE)
                     ,l_object_version_number -- object_version_number
                     ,l_utilization_rec.attribute_category
                     ,l_utilization_rec.attribute1
                     ,l_utilization_rec.attribute2
                     ,l_utilization_rec.attribute3
                     ,l_utilization_rec.attribute4
                     ,l_utilization_rec.attribute5
                     ,l_utilization_rec.attribute6
                     ,l_utilization_rec.attribute7
                     ,l_utilization_rec.attribute8
                     ,l_utilization_rec.attribute9
                     ,l_utilization_rec.attribute10
                     ,l_utilization_rec.attribute11
                     ,l_utilization_rec.attribute12
                     ,l_utilization_rec.attribute13
                     ,l_utilization_rec.attribute14
                     ,l_utilization_rec.attribute15
                     ,l_utilization_rec.org_id
                     ,l_utilization_rec.adjustment_type_id
                     ,l_utilization_rec.camp_schedule_id
                     ,l_utilization_rec.gl_date
                     ,l_utilization_rec.product_level_type
                     ,l_utilization_rec.product_id
                     ,l_utilization_rec.ams_activity_budget_id
                     ,l_utilization_rec.amount_remaining
                     ,l_utilization_rec.acctd_amount_remaining
                     ,l_utilization_rec.cust_account_id
                     ,l_utilization_rec.price_adjustment_id
                     ,l_plan_curr_amount
                     ,l_plan_curr_amount_remaining
                     ,l_utilization_rec.scan_unit
                     ,l_utilization_rec.scan_unit_remaining
                     ,l_utilization_rec.activity_product_id
                     ,l_utilization_rec.volume_offer_tiers_id
                     ,l_utilization_rec.gl_posted_flag                      -- yzhao: 03/20/2003  added
                     --  11/04/2003   yzhao     11.5.10: added
                     ,l_utilization_rec.billto_cust_account_id
                     ,l_utilization_rec.reference_type
                     ,l_utilization_rec.reference_id
                     /*fix for bug 4778995
                     ,l_utilization_rec.month_id
                     ,l_utilization_rec.quarter_id
                     ,l_utilization_rec.year_id
                     */
                     -- 01/02/2004 kdass added for 11.5.10
                     ,l_utilization_rec.order_line_id
                     ,l_utilization_rec.orig_utilization_id
                     -- 06/15/2005 Ribha added for R12
                     ,l_utilization_rec.bill_to_site_use_id
                     ,l_utilization_rec.ship_to_site_use_id
                     ,l_utilization_rec.univ_curr_amount
                     ,l_utilization_rec.univ_curr_amount_remaining
                     ,l_utilization_rec.fund_request_currency_code
                     ,l_utilization_rec.fund_request_amount
                     ,l_utilization_rec.fund_request_amount_remaining
                     ,l_utilization_rec.plan_currency_code
             );

         INSERT INTO ozf_funds_utilized_all_tl
                     (utilization_id
                     ,last_update_date
                     ,last_updated_by
                     ,last_update_login
                     ,creation_date
                     ,created_by
                     ,created_from
                     ,request_id
                     ,program_application_id
                     ,program_id
                     ,program_update_date
                     ,adjustment_desc
                     ,source_lang
                     ,language
                     ,org_id
                     )
            SELECT l_utilization_rec.utilization_id
                  ,SYSDATE -- LAST_UPDATE_DATE
                  ,NVL (fnd_global.user_id, -1) -- LAST_UPDATED_BY
                  ,NVL (fnd_global.conc_login_id, -1) -- LAST_UPDATE_LOGIN
                  ,SYSDATE -- CREATION_DATE
                  ,NVL (fnd_global.user_id, -1) -- CREATED_BY
                  ,l_utilization_rec.created_from -- CREATED_FROM
                  ,fnd_global.conc_request_id -- REQUEST_ID
                  ,fnd_global.prog_appl_id -- PROGRAM_APPLICATION_ID
                  ,fnd_global.conc_program_id -- PROGRAM_ID
                  ,SYSDATE -- PROGRAM_UPDATE_DATE
                  ,l_utilization_rec.adjustment_desc -- ADJUSTMENT_DESCRIPTION
                  ,USERENV ('LANG') -- SOURCE_LANGUAGE
                  ,l.language_code -- LANGUAGE
                  ,l_utilization_rec.org_id  -- fix for 3640740
              FROM fnd_languages l
             WHERE l.installed_flag IN ('I', 'B')
               AND NOT EXISTS ( SELECT NULL
                                  FROM ozf_funds_utilized_all_tl t
                                 WHERE t.utilization_id = l_utilization_rec.utilization_id
                                   AND t.language = l.language_code);


         x_utilization_id           := l_utilization_rec.utilization_id;

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   l_full_name || ': inserted:'  || ': Utilization_id: ' || l_utilization_rec.utilization_id || ': amount:'  || l_utilization_rec.amount);
         END IF;

         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
         IF p_utilization_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST') THEN
          */

            --------------------------complete fund update-------------------------
            -- post to GL immediately for manual earning adjustments, and utilized offer type with 'post to gl' profile as yes
            -- the accrual type adjustment is taken care of in ozfacreb.pls
           IF l_gl_posted AND l_utilization_rec.gl_posted_flag = ozf_accrual_engine.G_GL_FLAG_NO AND
               l_utilization_rec.plan_type IN ( 'OFFR' , 'PRIC')  THEN
                /* yzhao: 11.5.10 11/17/2003 create gl entry for off-invoice discount when profile is on
                -- IF l_utilization_rec.utilization_type NOT IN ('REQUEST', 'TRANSFER', 'SALES_ACCRUAL','UTILIZED')
                IF l_utilization_rec.utilization_type NOT IN ('REQUEST', 'TRANSFER', 'SALES_ACCRUAL') THEN
                 */
                IF l_utilization_rec.utilization_type <> 'SALES_ACCRUAL' THEN
                     --kdass R12 accounting enhancement
                     --Bugfix : 9656307
                     IF l_utilization_rec.utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL','CHARGEBACK') THEN
                       --//ER 9382547
                        --l_utilization_type := 'ACCRUAL';
                        l_event_type_code  :='ACCRUAL_CREATION';
                     ELSIF l_utilization_rec.utilization_type = 'UTILIZED' THEN
                        --//ER 9382547
                        --l_utilization_type := 'OFF_INVOICE';
                        l_event_type_code := 'INVOICE_DISCOUNT';

                     ELSIF l_utilization_rec.utilization_type = 'ADJUSTMENT' THEN
                        IF l_utilization_rec.adjustment_type IN ('DECREASE_PAID' ,'INCREASE_PAID' ) THEN
                           l_event_type_code := 'PAID_ADJUSTMENT';
                        ELSE
                           l_event_type_code := 'ACCRUAL_ADJUSTMENT';
                        END IF;
                     END IF;

                     --//ER 9382547
                     /*
                             IF NVL(l_utilization_rec.amount,0) >= 0 THEN
                                l_adjustment_type := 'P'; -- positive
                             ELSE
                                l_adjustment_type := 'N'; -- negative adjustment
                             END IF;

                             l_skip_acct_gen_flag := NVL(ozf_fund_utilized_pub.g_skip_acct_gen_flag, 'F');
                     */

                     IF G_DEBUG THEN
                        --ozf_utility_pvt.debug_message(l_full_name || ': l_skip_acct_gen_flag: ' || l_skip_acct_gen_flag);
                        ozf_utility_pvt.debug_message(l_full_name || ': gl_account_credit: ' || l_utilization_rec.gl_account_credit);
                        ozf_utility_pvt.debug_message(l_full_name || ': gl_account_debit: ' || l_utilization_rec.gl_account_debit);
                     END IF;

                     -- Fix For Bug 8466615
                     ozf_gl_interface_pvt.Post_Accrual_To_GL(p_api_version            => 1.0
                                                            ,p_init_msg_list          => fnd_api.g_false
                                                            ,p_commit                 => fnd_api.g_false
                                                            ,p_validation_level       => fnd_api.g_valid_level_full
                                                            ,x_return_status          => l_return_status
                                                            ,x_msg_data               => x_msg_data
                                                            ,x_msg_count              => x_msg_count
                                                            ,p_utilization_id         => x_utilization_id
                                                            ,p_event_type_code       => l_event_type_code
                                                           -- ,p_adjustment_type        => l_adjustment_type
                                                            ,p_dr_code_combination_id => l_utilization_rec.gl_account_debit
                                                            ,p_cr_code_combination_id => l_utilization_rec.gl_account_credit
                                                            --,p_skip_acct_gen_flag     => l_skip_acct_gen_flag
                                                            --,x_event_id               => x_event_id
                                                            );

                    IF G_DEBUG THEN
                          ozf_utility_pvt.debug_message (   l_full_name || ': posted GL: '  || l_return_status);
                    END IF;

                     -- yzhao: 03/27/2003 when gl posting succeeds, set the flag 'Y', otherwise 'F', ignore error and reprocess later
                     IF l_return_status = fnd_api.g_ret_sts_success THEN
                        l_gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_YES;  -- 'Y';
                        --kdass 27-JUL-2005 - R12 change for paid adjustments
                        IF l_utilization_rec.utilization_type = 'ADJUSTMENT' AND
                           l_utilization_rec.adjustment_type IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
                            l_fund_rec.paid_amt := NVL(l_paid_amt,0) - NVL (l_utilization_rec.amount_remaining, 0);
                            l_fund_rec.utilized_amt := l_utilized_amt;
                            l_fund_rec.earned_amt := l_earned_amt;
                            l_fund_rec.committed_amt := l_committed_amt;
                            l_fund_rec.original_budget := l_original_budget;
                            l_fund_rec.recal_committed := l_recal_comm_amt;
                            l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(-l_utilization_rec.amount_remaining, 0);
                            l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                 --nirprasa,12.1.1 + NVL(-l_plan_curr_amount_remaining, 0);
                                                                 + NVL(-l_utilization_rec.fund_request_amount_remaining, 0);

                            l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                 + NVL(-l_utilization_rec.univ_curr_amount_remaining, 0);
                        ELSE
                            -- yzhao: 11/14/2003 update budget earned amount when gl post success for accrual offers
                            --        02/24/2004 11.5.10 update budget earned and paid amount for utilization against off-invoice offers
                            --        07/02/2004 11.5.10 update budget earned amount for adjustment against off-invoice offers
                            l_fund_rec.earned_amt := NVL (l_earned_amt, 0) + NVL (l_utilization_rec.amount, 0);
                            -- R12: yzhao
                            l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0) + NVL(l_utilization_rec.amount, 0);
                            l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                                                 -- nirprasa,ER 8399134 + NVL(l_plan_curr_amount, 0);
                                                                 + NVL(l_utilization_rec.fund_request_amount, 0);
                            l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                                                 + NVL(l_univ_curr_amount, 0);
                            IF l_utilization_rec.component_type = 'OFFR' AND NOT l_offer_accrual_flag AND
                               -- yzhao: fix bug 3741127 do not update paid amount for off-invoice offer manual adjustment
                                l_utilization_rec.utilization_type NOT IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') THEN
                                l_fund_rec.paid_amt := NVL (l_paid_amt, 0) + NVL (l_utilization_rec.amount, 0);
                                l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(l_utilization_rec.amount, 0);
                                l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                     --nirprasa,ER 8399134 + NVL(l_plan_curr_amount, 0);
                                                                     + NVL(l_utilization_rec.fund_request_amount, 0);
                                l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                     + NVL(l_univ_curr_amount, 0);
                            END IF;
                        END IF;
                     ELSE
                        l_gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_FAIL;   -- 'F';
                        -- yzhao: 11/20 raise exception if gl posting failed for manual adjust earned amount
                        IF l_utilization_rec.utilization_type IN ('ADJUSTMENT', 'CHARGEBACK', 'LEAD_ADJUSTMENT') AND
                           l_utilization_rec.adjustment_type IN ('STANDARD', 'DECREASE_EARNED', 'DECREASE_COMM_EARNED') THEN
                           fnd_message.set_name ('OZF', 'OZF_GL_POST_FAILURE');
                           fnd_msg_pub.ADD;
                           RAISE fnd_api.g_exc_error;
                        ELSE
                            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                               fnd_message.set_name ('OZF', 'OZF_API_DEBUG_MESSAGE');
                               fnd_message.set_token ('TEXT', 'Failed to post to GL for utilization id ' || l_utilization_rec.utilization_id);
                               fnd_msg_pub.ADD;
                            END IF;
                        END IF;
                     END IF;
                END IF;  -- END IF

                UPDATE ozf_funds_utilized_all_b
                SET last_update_date = SYSDATE
                  , last_updated_by = NVL (fnd_global.user_id, -1)
                  , last_update_login = NVL (fnd_global.conc_login_id, -1)
                  , gl_posted_flag = l_gl_posted_flag
                  --, gl_date = sysdate
                WHERE utilization_id = l_utilization_rec.utilization_id
                AND   object_version_number = l_object_version_number;

            END IF; -- for gl entry

            l_fund_rec.fund_id         := l_utilization_rec.fund_id;
            l_fund_rec.object_version_number := l_obj_num;

            --nirprasa for bug 7425189, use these 2 columns to distinguish the
            -- reconcile flow in fund's API.
            IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
            AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN
                --l_fund_rec.exchange_rate_date := l_utilization_rec.exchange_rate_date;
                l_fund_rec.description := l_utilization_rec.adjustment_desc;
            END IF;

            --bug 8532055
            l_fund_rec.exchange_rate_date := l_utilization_rec.exchange_rate_date;

            ozf_funds_pvt.update_fund (
               p_api_version=> l_api_version
              ,p_init_msg_list=> fnd_api.g_false
              ,p_commit=> fnd_api.g_false
              ,p_validation_level=> p_validation_level
              ,x_return_status=> l_return_status
              ,x_msg_count=> x_msg_count
              ,x_msg_data=> x_msg_data
              ,p_fund_rec=> l_fund_rec
              ,p_mode=> g_cons_fund_mode
            );

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            -- R12: yzhao ozf_object_fund_summary update amount
            IF l_objfundsum_rec.objfundsum_id IS NULL THEN
                l_objfundsum_rec.fund_id := l_utilization_rec.fund_id;
                l_objfundsum_rec.fund_currency := l_utilization_rec.currency_code;
                l_objfundsum_rec.object_type := l_utilization_rec.component_type;
                l_objfundsum_rec.object_id := l_utilization_rec.component_id;
                ozf_objfundsum_pvt.create_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       p_conv_date                  => l_utilization_rec.exchange_rate_date, --bug 8532055
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data,
                       x_objfundsum_id              => l_objfundsum_id
                );
                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
            ELSE
                /*
                --Added for bug 7425189, Call update_reconcile_objfundsum for reconcile flow.
                IF l_utilization_rec.adjustment_desc IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                AND l_utilization_rec.exchange_rate_date IS NOT NULL THEN
                OZF_ACTBUDGETS_PVT.update_reconcile_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       p_conv_date                  => l_utilization_rec.exchange_rate_date,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                );
                ELSE
                */
                ozf_objfundsum_pvt.update_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       p_conv_date                  => l_utilization_rec.exchange_rate_date, --bug 7425189, 8532055
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                );
                --END IF;

                IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                END IF;
            END IF;
            -- R12: yzhao END ozf_object_fund_summary update amount

         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
         END IF; -- end IF p_utilization_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST') THEN
          */

         -- raise business event for adjustment
         IF l_utilization_rec.utilization_type = 'ADJUSTMENT' THEN
             raise_business_event(p_object_id => l_utilization_rec.utilization_id );
         END IF;


    -- Check for commit
    IF fnd_api.to_boolean (p_commit) THEN
       COMMIT;
    END IF;

    fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
    );
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
    END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_utilization;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO create_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END create_utilization;


---------------------------------------------------------------
-- PROCEDURE
--    Delete_Utilization
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
---------------------------------------------------------------
   PROCEDURE delete_utilization (
      p_api_version      IN       NUMBER
     ,p_init_msg_list    IN       VARCHAR2 := fnd_api.g_false
     ,p_commit           IN       VARCHAR2 := fnd_api.g_false
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_utilization_id   IN       NUMBER
     ,p_object_version   IN       NUMBER
   ) IS
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30) := 'Delete_Utilization';
      l_full_name     CONSTANT VARCHAR2 (60) :=    g_pkg_name
                                                || '.'
                                                || l_api_name;
   BEGIN
      --------------------- initialize -----------------------
      SAVEPOINT delete_utilization;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

------------------------ delete ------------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': delete');
      END IF;

      DELETE FROM ozf_funds_utilized_all_b
            WHERE utilization_id = p_utilization_id
              AND object_version_number = p_object_version;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      DELETE FROM ozf_funds_utilized_all_tl
            WHERE utilization_id = p_utilization_id;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;


-------------------- finish --------------------------
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO delete_utilization;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO delete_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO delete_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END delete_utilization;


-------------------------------------------------------------------
-- PROCEDURE
--    Lock_Utilization
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
--------------------------------------------------------------------
   PROCEDURE lock_utilization (
      p_api_version      IN       NUMBER
     ,p_init_msg_list    IN       VARCHAR2 := fnd_api.g_false
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_utilization_id   IN       NUMBER
     ,p_object_version   IN       NUMBER
   ) IS
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30) := 'Lock_Utilization';
      l_full_name     CONSTANT VARCHAR2 (60) :=    g_pkg_name
                                                || '.'
                                                || l_api_name;
      l_utilization_id         NUMBER;

      CURSOR c_utilization_b IS
         SELECT        utilization_id
                  FROM ozf_funds_utilized_all_b
                 WHERE utilization_id = p_utilization_id
                   AND object_version_number = p_object_version
         FOR UPDATE OF utilization_id NOWAIT;

      CURSOR c_utilization_tl IS
         SELECT        utilization_id
                  FROM ozf_funds_utilized_all_tl
                 WHERE utilization_id = p_utilization_id
                   AND USERENV ('LANG') IN (language, source_lang)
         FOR UPDATE OF utilization_id NOWAIT;
   BEGIN
      -------------------- initialize ------------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

------------------------ lock -------------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': lock');
      END IF;
      OPEN c_utilization_b;
      FETCH c_utilization_b INTO l_utilization_id;

      IF (c_utilization_b%NOTFOUND) THEN
         CLOSE c_utilization_b;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_utilization_b;
      OPEN c_utilization_tl;
      CLOSE c_utilization_tl;

-------------------- finish --------------------------
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;
   EXCEPTION
      WHEN ozf_utility_pvt.resource_locked THEN
         x_return_status            := fnd_api.g_ret_sts_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RESOURCE_LOCKED');
            fnd_msg_pub.ADD;
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END lock_utilization;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_Utilization
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
----------------------------------------------------------------------
   PROCEDURE update_utilization (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_utilization_rec    IN       utilization_rec_type
     ,p_mode               IN       VARCHAR2 := 'UPDATE'
   ) IS
      l_api_version         CONSTANT NUMBER                      := 1.0;
      l_api_name            CONSTANT VARCHAR2 (30)               := 'Update_Utilization';
      l_full_name           CONSTANT VARCHAR2 (60)               :=    g_pkg_name
                                                                    || '.'
                                                                    || l_api_name;
      l_utilization_rec              utilization_rec_type;
      l_mode                         VARCHAR2 (30);
      l_return_status                VARCHAR2 (1)                := fnd_api.g_ret_sts_success;
      l_obj_num                      NUMBER                      := 1;
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_utilized_amt                   NUMBER;
      l_old_util_amt                 NUMBER;
      l_plan_curr_amount             NUMBER;
      l_plan_curr_amount_remaining   NUMBER;
      l_plan_currency                VARCHAR2 (150);
      l_rate                         NUMBER;
      l_univ_curr_amount             NUMBER;
      l_univ_curr_amount_remaining   NUMBER;

      CURSOR c_fund_b (p_fund_id IN NUMBER) IS
         SELECT utilized_amt
               ,object_version_number
           FROM ozf_funds_all_b
          WHERE fund_id = p_fund_id;

      CURSOR c_old_util_amt (p_util_id IN NUMBER) IS
         SELECT amount
           FROM ozf_funds_utilized_all_b
          WHERE utilization_id = p_util_id;
   BEGIN
      -------------------- initialize -------------------------
      SAVEPOINT update_utilization;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

----------------------- validate ----------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': validate');
      END IF;
      -- replace g_miss_char/num/date with current column values
      complete_utilization_rec (p_utilization_rec, l_utilization_rec);

      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         check_utilization_items (
            p_utilization_rec=> p_utilization_rec
           ,p_validation_mode=> jtf_plsql_api.g_update
           ,x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;


      IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
         check_utilization_record (
            p_utilization_rec=> p_utilization_rec
           ,p_complete_rec=> l_utilization_rec
           ,p_mode=> p_mode
           ,x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;


-------------------------- update --------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': update');
      END IF;
      l_plan_currency            :=
            ozf_actbudgets_pvt.get_object_currency (
               l_utilization_rec.plan_type
              ,l_utilization_rec.plan_id
              ,l_return_status
            );

      IF NVL (l_utilization_rec.amount, 0) <> 0 THEN
         ozf_utility_pvt.convert_currency (
            p_from_currency=> l_utilization_rec.currency_code
           ,p_to_currency=> l_plan_currency
           ,p_from_amount=> l_utilization_rec.amount
           ,x_return_status=> l_return_status
           ,x_to_amount=> l_plan_curr_amount
           ,x_rate=> l_rate
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      IF NVL (l_utilization_rec.amount_remaining, 0) <> 0 THEN
         ozf_utility_pvt.convert_currency (
            p_from_currency=> l_utilization_rec.currency_code
           ,p_to_currency=> l_plan_currency
           ,p_from_amount=> l_utilization_rec.amount_remaining
           ,x_return_status=> l_return_status
           ,x_to_amount=> l_plan_curr_amount_remaining
           ,x_rate=> l_rate
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;


      -- R12 yzhao: convert universal currency
      IF g_universal_currency = l_utilization_rec.currency_code THEN
          l_univ_curr_amount := l_utilization_rec.amount;
          l_univ_curr_amount_remaining := l_utilization_rec.amount_remaining;
      ELSIF g_universal_currency = l_plan_currency THEN
          l_univ_curr_amount := l_plan_curr_amount;
          l_univ_curr_amount_remaining := l_plan_curr_amount_remaining;
      ELSE
          IF NVL (l_utilization_rec.amount, 0) = 0 THEN
            l_univ_curr_amount := 0;
          ELSE
              ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_from_amount=> l_utilization_rec.amount
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_univ_curr_amount
                  ,x_rate=> l_rate
              );
              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                 RAISE fnd_api.g_exc_error;
              END IF;
          END IF;

          IF NVL (l_utilization_rec.amount_remaining, 0) = 0 THEN
            l_univ_curr_amount_remaining := 0;
          ELSE
              ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_from_amount=> l_utilization_rec.amount_remaining
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_univ_curr_amount_remaining
                  ,x_rate=> l_rate
              );

              IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                 RAISE fnd_api.g_exc_error;
              END IF;
          END IF;
       END IF;

      UPDATE ozf_funds_utilized_all_b
         SET last_update_date = SYSDATE
            ,last_updated_by = NVL (fnd_global.user_id, -1)
            ,last_update_login = NVL (fnd_global.conc_login_id, -1)
            ,created_from = l_utilization_rec.created_from
            ,request_id = fnd_global.conc_request_id
            ,program_application_id = fnd_global.prog_appl_id
            ,program_id = fnd_global.conc_program_id
            ,program_update_date = SYSDATE
            ,utilization_type = l_utilization_rec.utilization_type
            ,fund_id = l_utilization_rec.fund_id
            ,plan_type = l_utilization_rec.plan_type
            ,plan_id = l_utilization_rec.plan_id
            ,component_type = l_utilization_rec.component_type
            ,component_id = l_utilization_rec.component_id
            ,object_type = l_utilization_rec.object_type
            ,object_id = l_utilization_rec.object_id
            ,order_id = l_utilization_rec.order_id
            ,invoice_id = l_utilization_rec.invoice_id
            ,amount = l_utilization_rec.amount
            ,acctd_amount = l_utilization_rec.acctd_amount
            ,currency_code = l_utilization_rec.currency_code
            ,exchange_rate_type = l_utilization_rec.exchange_rate_type
            ,exchange_rate_date = l_utilization_rec.exchange_rate_date
            ,exchange_rate = l_utilization_rec.exchange_rate
            ,adjustment_type = l_utilization_rec.adjustment_type
            ,adjustment_date = l_utilization_rec.adjustment_date
            ,object_version_number =   l_utilization_rec.object_version_number
                                     + 1
            ,attribute_category = l_utilization_rec.attribute_category
            ,attribute1 = l_utilization_rec.attribute1
            ,attribute2 = l_utilization_rec.attribute2
            ,attribute3 = l_utilization_rec.attribute3
            ,attribute4 = l_utilization_rec.attribute4
            ,attribute5 = l_utilization_rec.attribute5
            ,attribute6 = l_utilization_rec.attribute6
            ,attribute7 = l_utilization_rec.attribute7
            ,attribute8 = l_utilization_rec.attribute8
            ,attribute9 = l_utilization_rec.attribute9
            ,attribute10 = l_utilization_rec.attribute10
            ,attribute11 = l_utilization_rec.attribute11
            ,attribute12 = l_utilization_rec.attribute12
            ,attribute13 = l_utilization_rec.attribute13
            ,attribute14 = l_utilization_rec.attribute14
            ,attribute15 = l_utilization_rec.attribute15
            ,adjustment_type_id = l_utilization_rec.adjustment_type_id
            ,camp_schedule_id = l_utilization_rec.camp_schedule_id
            ,gl_date = l_utilization_rec.gl_date
            ,product_level_type = l_utilization_rec.product_level_type
            ,product_id = l_utilization_rec.product_id
            ,ams_activity_budget_id = l_utilization_rec.ams_activity_budget_id
            ,amount_remaining = l_utilization_rec.amount_remaining
            ,acctd_amount_remaining = l_utilization_rec.acctd_amount_remaining
            ,cust_account_id = l_utilization_rec.cust_account_id
            ,price_adjustment_id = l_utilization_rec.price_adjustment_id
            ,plan_curr_amount = l_plan_curr_amount
            ,plan_curr_amount_remaining = l_plan_curr_amount_remaining
            ,scan_unit = l_utilization_rec.scan_unit
            ,scan_unit_remaining = l_utilization_rec.scan_unit_remaining
            ,activity_product_id = l_utilization_rec.activity_product_id
            ,gl_posted_flag = l_utilization_rec.gl_posted_flag          -- yzhao: 03/20/2003  added
            --  11/04/2003   yzhao     11.5.10: added
            ,billto_cust_account_id = l_utilization_rec.billto_cust_account_id
            ,reference_type = l_utilization_rec.reference_type
            ,reference_id = l_utilization_rec.reference_id
            /*fix for bug 4778995
            ,month_id = l_utilization_rec.month_id
            ,quarter_id = l_utilization_rec.quarter_id
            ,year_id = l_utilization_rec.year_id
            */
            -- R12 yzhao added universal currency
            ,bill_to_site_use_id = l_utilization_rec.bill_to_site_use_id
            ,ship_to_site_use_id = l_utilization_rec.ship_to_site_use_id
            ,univ_curr_amount = l_univ_curr_amount
            ,univ_curr_amount_remaining = l_univ_curr_amount_remaining
       WHERE utilization_id = l_utilization_rec.utilization_id
         AND object_version_number = l_utilization_rec.object_version_number;

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      UPDATE ozf_funds_utilized_all_tl
         SET last_update_date = SYSDATE
            ,last_updated_by = NVL (fnd_global.user_id, -1)
            ,last_update_login = NVL (fnd_global.conc_login_id, -1)
            ,created_from = l_utilization_rec.created_from
            ,request_id = fnd_global.conc_request_id
            ,program_application_id = fnd_global.prog_appl_id
            ,program_id = fnd_global.conc_program_id
            ,program_update_date = SYSDATE
            ,adjustment_desc = l_utilization_rec.adjustment_desc
            ,source_lang = USERENV ('LANG')
       WHERE utilization_id = l_utilization_rec.utilization_id
         AND USERENV ('LANG') IN (language, source_lang);

      IF (SQL%NOTFOUND) THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN c_fund_b (l_utilization_rec.fund_id);
      FETCH c_fund_b INTO l_utilized_amt, l_obj_num;

      IF (c_fund_b%NOTFOUND) THEN
         CLOSE c_fund_b;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_fund_b;
      OPEN c_old_util_amt (l_utilization_rec.utilization_id);
      FETCH c_old_util_amt INTO l_old_util_amt;
      CLOSE c_old_util_amt;
      -------------------------update master fund table-------------------
      ozf_funds_pvt.init_fund_rec (x_fund_rec => l_fund_rec);
      -- new utilzed amount = fund_utilized_amount - old_util_Amount + new util amount
      l_fund_rec.utilized_amt      :=
                    NVL (l_utilized_amt, 0)
                  - NVL (l_old_util_amt, 0)
                  + NVL (l_utilization_rec.amount, 0);
      l_fund_rec.fund_id         := l_utilization_rec.fund_id;
      l_fund_rec.object_version_number := l_obj_num;
      ozf_funds_pvt.update_fund (
         p_api_version=> l_api_version
        ,p_init_msg_list=> fnd_api.g_false
        ,p_commit=> fnd_api.g_false
        ,p_validation_level=> p_validation_level
        ,x_return_status=> l_return_status
        ,x_msg_count=> x_msg_count
        ,x_msg_data=> x_msg_data
        ,p_fund_rec=> l_fund_rec
        ,p_mode=> g_cons_fund_mode
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;


-------------------- finish --------------------------

      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_utilization;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO update_utilization;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END update_utilization;


--------------------------------------------------------------------
-- PROCEDURE
--    Validate_Utilization
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
--------------------------------------------------------------------
   PROCEDURE validate_utilization (
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_utilization_rec    IN       utilization_rec_type
   ) IS
      l_api_version   CONSTANT NUMBER        := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30) := 'Validate_Utilization';
      l_full_name     CONSTANT VARCHAR2 (60) :=    g_pkg_name
                                                || '.'
                                                || l_api_name;
      l_return_status          VARCHAR2 (1);
   BEGIN
      ----------------------- initialize --------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

---------------------- validate ------------------------
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': check items');
      END IF;

      IF p_validation_level >= jtf_plsql_api.g_valid_level_item THEN
         check_utilization_items (
            p_utilization_rec=> p_utilization_rec
           ,p_validation_mode=> jtf_plsql_api.g_create
           ,x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': check record');
      END IF;

      IF p_validation_level >= jtf_plsql_api.g_valid_level_record THEN
         check_utilization_record (
            p_utilization_rec=> p_utilization_rec
           ,p_complete_rec=> p_utilization_rec
           ,x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;


-------------------- finish --------------------------
      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false
           ,p_count=> x_msg_count
           ,p_data=> x_msg_data
         );
   END validate_utilization;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilized_Req_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilized_req_items (
      p_utilization_rec   IN       utilization_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;


------------------------ fund_id --------------------------
      IF p_utilization_rec.fund_id IS NULL THEN -- check for fund id
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_NO_FUND_ID');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         RETURN;

------------------------ AMOUNT -------------------------------
      ELSIF p_utilization_rec.amount IS NULL THEN -- check for amount
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_NO_UTILIZED_AMOUNT');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         RETURN;
      ELSIF p_utilization_rec.utilization_type IN ('ADJUSTMENT', 'CHARGEBACK', 'LEAD_ADJUSTMENT') THEN
         IF p_utilization_rec.adjustment_type IS NULL THEN -- check for utilization
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_FUND_NO_ADJUSTMENT_TYPE');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      -- added for customer id for offers 8/14/2002 mpande
         IF p_utilization_rec.adjustment_type IN ('DECREASE_EARNED' ,'DECREASE_COMM_EARNED','STANDARD')
            AND p_utilization_rec.plan_type = 'OFFR' AND p_utilization_rec.cust_account_id IS NULL THEN -- check for utilization type
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_FUND_NO_CUST_ID');
               fnd_msg_pub.ADD;
            END IF;
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      ELSIF p_utilization_rec.utilization_type IS NULL THEN -- check for utilization type
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_FUND_NO_UTILIZATION_TYPE');
            fnd_msg_pub.ADD;
         END IF;

         x_return_status            := fnd_api.g_ret_sts_error;
         RETURN;
      END IF;

   END check_utilized_req_items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilized_Uk_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilized_uk_items (
      p_utilization_rec   IN       utilization_rec_type
     ,p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      l_valid_flag   VARCHAR2 (1);
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      -- For Create_Utilization, when utilization_id is passed in, we need to
      -- check if this utilization_id is unique.
      IF      p_validation_mode = jtf_plsql_api.g_create
          AND p_utilization_rec.utilization_id IS NOT NULL THEN
         IF ozf_utility_pvt.check_uniqueness (
               'ozf_funds_UTILIZED_all_b'
              ,   'utilization_id = '
               || p_utilization_rec.utilization_id
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_UTILIZED_DUPLICATE_ID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

-- check other unique items

   END check_utilized_uk_items;


--------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilized_Fk_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilized_fk_items (
      p_utilization_rec   IN       utilization_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;


----------------------- fund_id ------------------------
      IF p_utilization_rec.fund_id <> fnd_api.g_miss_num THEN
         IF ozf_utility_pvt.check_fk_exists (
               'ozf_funds_all_b'
              , -- Parent schema object having the primary key
               'fund_id'
              , -- Column name in the parent object that maps to the fk value
               p_utilization_rec.fund_id -- Value of fk to be validated against the parent object's pk column
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_BAD_FUND_ID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      ----------------------- adjustment_id ------------------------
      IF p_utilization_rec.adjustment_type_id <> fnd_api.g_miss_num THEN
         IF ozf_utility_pvt.check_fk_exists (
               'ozf_claim_types_all_b'
              , -- Parent schema object having the primary key
               'claim_type_id'
              , -- Column name in the parent object that maps to the fk value
               p_utilization_rec.adjustment_type_id -- Value of fk to be validated against the parent object's pk column
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZFBAD_ADJUSTMENT_ID');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

-- check other fk items

   END check_utilized_fk_items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilized_Lookup_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilized_lookup_items (
      p_utilization_rec   IN       utilization_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      ----------------------- utilization_type ------------------------
      IF      p_utilization_rec.utilization_type <> fnd_api.g_miss_char THEN
         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
          AND p_utilization_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST') THEN
          */
         IF ozf_utility_pvt.check_lookup_exists (
               p_lookup_table_name=> 'OZF_LOOKUPS'
              ,p_lookup_type=> 'OZF_UTILIZATION_TYPE'
              ,p_lookup_code=> p_utilization_rec.utilization_type
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_BAD_UTILIZED_CODE');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      --------------------02/08/2001 mpande added----------------
      IF p_utilization_rec.adjustment_type <> fnd_api.g_miss_char THEN
         IF ozf_utility_pvt.check_lookup_exists (
               p_lookup_table_name=> 'OZF_LOOKUPS'
              ,p_lookup_type=> 'OZF_ADJUSTMENT_TYPE'
              ,p_lookup_code=> p_utilization_rec.adjustment_type
            ) = fnd_api.g_false THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_BAD_ADJUSTMENT_CODE');
               fnd_msg_pub.ADD;
            END IF;

            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

-- check other lookup codes

   END check_utilized_lookup_items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilized_Flag_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilized_flag_items (
      p_utilization_rec   IN       utilization_rec_type
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

-- check other flags

   END check_utilized_flag_items;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilization_Items
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilization_items (
      p_validation_mode   IN       VARCHAR2 := jtf_plsql_api.g_create
     ,x_return_status     OUT NOCOPY      VARCHAR2
     ,p_utilization_rec   IN       utilization_rec_type
   ) IS
   BEGIN
      check_utilized_req_items (
         p_utilization_rec=> p_utilization_rec
        ,x_return_status=> x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      check_utilized_uk_items (
         p_utilization_rec=> p_utilization_rec
        ,p_validation_mode=> p_validation_mode
        ,x_return_status=> x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      check_utilized_fk_items (
         p_utilization_rec=> p_utilization_rec
        ,x_return_status=> x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      check_utilized_lookup_items (
         p_utilization_rec=> p_utilization_rec
        ,x_return_status=> x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;

      check_utilized_flag_items (
         p_utilization_rec=> p_utilization_rec
        ,x_return_status=> x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         RETURN;
      END IF;
   END check_utilization_items;


---------------------------------------------------------------------
-- FUNCTION
--    Check_committed_amount_exists
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------

   FUNCTION check_committed_amount_exists (
      p_amount          IN   NUMBER
     ,p_activity_id     IN   NUMBER
     ,p_activity_type   IN   VARCHAR2
     ,p_fund_id         IN   NUMBER
     ,p_cust_account_id IN   NUMBER := NULL
   )
      RETURN VARCHAR2 IS
      l_amount          NUMBER;
      l_recal_flag      VARCHAR2(1);

      CURSOR c_transfer_allowed (
         p_object_id     IN   NUMBER
        ,p_object_type   IN   VARCHAR2
        ,p_fund_src_id   IN   NUMBER
      ) IS
      /* yzhao: 09/29/2005 R12
         SELECT SUM (total_amount) existing_amount
           FROM (SELECT   parent_source
                         ,SUM (amount) total_amount
                     FROM (SELECT   a1.fund_id parent_source
                                   ,NVL (SUM (a1.amount), 0) amount
                               FROM ozf_funds_utilized_all_b a1
                              WHERE a1.component_id = p_object_id
                                AND a1.component_type = p_object_type
                                AND a1.utilization_type IN ('TRANSFER', 'REQUEST')
                           GROUP BY a1.fund_id
                           UNION
                           SELECT   a2.fund_id parent_source
                                   ,-NVL (SUM (a2.amount), 0) amount
                               FROM ozf_funds_utilized_all_b a2
                              WHERE a2.plan_id = p_object_id
                                AND a2.plan_type = p_object_type
                                AND a2.utilization_type NOT IN ('TRANSFER', 'REQUEST')
                           GROUP BY a2.fund_id)
                    WHERE parent_source = p_fund_src_id
                 GROUP BY parent_source);
        */
        SELECT SUM(NVL(committed_amt,0)-NVL(utilized_amt,0)) total_amount
        FROM   ozf_object_fund_summary
        WHERE  object_id =p_object_id
        AND    object_type = p_object_type
        and    fund_id = p_fund_src_id;

   BEGIN
      -- if no offer id then chekc against the activity

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (
            ': check record'
         || p_cust_account_id
         || '-'
         || p_amount
         || p_fund_id
         || p_activity_id
         || p_activity_type
      );
      END IF;

--   IF p_component_id IS NULL THEN
  --    ozf_utility_pvt.debug_message(': check record1' || p_component_id ||'-'|| p_amount||p_fund_id||p_activity_id||p_activity_type);
      IF p_activity_type <> 'OFFR' THEN
          l_recal_flag := 'N' ;
      ELSE
          l_recal_flag := NVL(fnd_profile.value('OZF_BUDGET_ADJ_ALLOW_RECAL'),'N');
      END IF;
      -- if offer id present then check against the amount
      -- if recal flag is on then can adjsut more than committed

      IF l_recal_flag = 'N' THEN
         OPEN c_transfer_allowed (p_activity_id, p_activity_type, p_fund_id);
         FETCH c_transfer_allowed INTO l_amount;

         IF c_transfer_allowed%NOTFOUND THEN
            RETURN fnd_api.g_false;
         END IF;

         CLOSE c_transfer_allowed;
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (
               ': check record2'
            || p_cust_account_id
            || '-'
            || p_amount
            || p_fund_id
            || p_activity_id
            || p_activity_type
         );
         END IF;
         IF NVL (p_amount, 0) > NVL (l_amount, 0) THEN
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   ': check record'
                                           || l_amount
                                           || p_amount);
            END IF;
            RETURN fnd_api.g_false;
         END IF;
      ELSE
         RETURN fnd_api.g_true;
      END IF ;

      RETURN fnd_api.g_true;
   EXCEPTION
      WHEN OTHERS THEN
         IF c_transfer_allowed%ISOPEN THEN
            CLOSE c_transfer_allowed;
            RETURN fnd_api.g_false;
         END IF;

         RAISE;
   END check_committed_amount_exists;


---------------------------------------------------------------------
-- FUNCTION
--    Check_earned_amount_positive
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
--    8/14/2002   Mumu Pande    Added Customer Account
---------------------------------------------------------------------
   FUNCTION check_earned_amount_positive (
      p_amount         IN   NUMBER
     ,p_fund_id        IN   NUMBER
     ,p_act_id         IN   NUMBER
     ,p_act_type       IN   VARCHAR2
     ,p_cust_account_id   IN   NUMBER := NULL
   )
      RETURN VARCHAR2 IS
      l_amount   NUMBER;

      CURSOR c_budget_earn_rec (p_act_id IN NUMBER, p_act_type IN VARCHAR2, p_fund_id IN NUMBER) IS
         SELECT SUM (amount)
           FROM ozf_funds_utilized_all_b
          WHERE fund_id = p_fund_id
            AND plan_type = p_act_type
            AND plan_id = p_act_id
            -- AND utilization_type NOT IN ('REQUEST', 'TRANSFER')    R12 no REQUEST/TRANSFER in util table
            AND NVL(cust_account_id,-1)  = NVL(p_cust_account_id,-2);

/*
      CURSOR c_budget_off_earn_rec (p_offer_id IN NUMBER) IS
         SELECT SUM (amount)
           FROM ozf_funds_utilized_all_b
          WHERE fund_id = p_fund_id
            AND component_type = 'OFFR'
            AND component_id = p_offer_id
            AND utilization_type NOT IN ('REQUEST', 'TRANSFER');
  */
   BEGIN
      -- if no offer id then chekc against the activity

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   ': check record'
                                     || p_cust_account_id
                                     || p_amount);
      END IF;

    --  IF p_component_id IS NULL THEN
         OPEN c_budget_earn_rec (p_act_id, p_act_type, p_fund_id);
         FETCH c_budget_earn_rec INTO l_amount;

         IF c_budget_earn_rec%NOTFOUND THEN
            CLOSE c_budget_earn_rec;
            RETURN fnd_api.g_false;
         END IF;

         CLOSE c_budget_earn_rec;
    /*  ELSE
         OPEN c_budget_off_earn_rec (p_component_id);
         FETCH c_budget_off_earn_rec INTO l_amount;

         IF c_budget_off_earn_rec%NOTFOUND THEN
            CLOSE c_budget_off_earn_rec;
            RETURN fnd_api.g_false;
         END IF;

         CLOSE c_budget_off_earn_rec;
      END IF;
*/
      -- if offer id present then check against the amount
      IF ABS(NVL (p_amount, 0)) > NVL (l_amount, 0) THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   ': check record'
                                        || l_amount
                                        || p_amount);
         END IF;
         RETURN fnd_api.g_false;
      END IF;

      RETURN fnd_api.g_true;
   END check_earned_amount_positive;


---------------------------------------------------------------------
-- FUNCTION
--    Check_fund_active
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   FUNCTION check_fund_active (p_fund_id IN NUMBER)
      RETURN VARCHAR2 IS
      l_status   VARCHAR2 (30);

      CURSOR c_budget_rec (p_fund_id IN NUMBER) IS
         SELECT status_code
           FROM ozf_funds_all_b
          WHERE fund_id = p_fund_id;
   BEGIN
      OPEN c_budget_rec (p_fund_id);
      FETCH c_budget_rec INTO l_status;

      IF c_budget_rec%NOTFOUND THEN
         CLOSE c_budget_rec;
         RETURN fnd_api.g_false;
      END IF;

      -- check against the amount
      IF l_status <> 'ACTIVE' THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (   ': check record'
                                        || l_status);
         END IF;
         RETURN fnd_api.g_false;
      END IF;

      RETURN fnd_api.g_true;
   END check_fund_active;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Utilization_Record
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE check_utilization_record (
      p_utilization_rec   IN       utilization_rec_type
     ,p_complete_rec      IN       utilization_rec_type := NULL
     ,p_mode              IN       VARCHAR2 := 'INSERT'
     ,x_return_status     OUT NOCOPY      VARCHAR2
   ) IS
      CURSOR c_fund_type (p_fund_id IN NUMBER) IS
         SELECT 'X'
           FROM ozf_funds_all_b ozf
          WHERE ozf.fund_type = 'FULLY_ACCRUED'
            AND ozf.fund_id = p_fund_id;

      l_dummy   VARCHAR2 (3) := 'X';
   BEGIN
     /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
      IF p_complete_rec.utilization_type IN ('REQUEST', 'TRANSFER') THEN
      */
         OPEN c_fund_type (p_complete_rec.fund_id);
         FETCH c_fund_type INTO l_dummy;
         CLOSE c_fund_type;
      -- END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

      IF p_mode <> 'UPDATE' THEN
       -- Check for committed amount exists all offers except FULLY ACCRUED budget offer
         /* yzhao: 09/29/2005 R12 no TRANSFER/REQUEST in utilization table
         IF p_complete_rec.utilization_type NOT IN ('TRANSFER', 'REQUEST')
            AND l_dummy IS NULL  AND
          */
         IF l_dummy IS NULL AND
            NVL(p_complete_rec.adjustment_type,'N') NOT IN  ( 'DECREASE_EARNED' ,'DECREASE_COMM_EARNED') THEN
            IF check_committed_amount_exists (
                  p_complete_rec.amount
                 ,p_complete_rec.plan_id
                 ,p_complete_rec.plan_type
                 ,p_complete_rec.fund_id
                 ,p_complete_rec.component_id
               ) = fnd_api.g_false THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name ('OZF', 'OZF_FUND_NO_COMMITTMENT');
                  fnd_msg_pub.ADD;
               END IF;

               x_return_status            := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;


      IF check_fund_active (p_complete_rec.fund_id) = fnd_api.g_false THEN
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_FUND_NO_ADJUST');
               fnd_msg_pub.ADD;
            END IF;
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;

      END IF; -- end if for p_mode

      IF l_dummy IS NULL THEN
         IF p_complete_rec.adjustment_type = ('DECREASE_EARNED') THEN
            -- amount should be positive always
            IF NVL (p_complete_rec.amount, 0) <= 0 THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name ('OZF', 'OZF_UTIL_NO_AMOUNT');
                  fnd_msg_pub.ADD;
               END IF;

               x_return_status            := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
         ELSE
            IF NVL (p_complete_rec.amount, 0) = 0 THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name ('OZF', 'OZF_UTIL_NO_AMOUNT');
                  fnd_msg_pub.ADD;
               END IF;

               x_return_status            := fnd_api.g_ret_sts_error;
               RETURN;
            END IF;
         END IF;
      END IF;
   END check_utilization_record;


---------------------------------------------------------------------
-- PROCEDURE
--    Init_Utilization_Rec
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements
---------------------------------------------------------------------
   PROCEDURE init_utilization_rec (x_utilization_rec OUT NOCOPY utilization_rec_type) IS
   BEGIN
      RETURN;
   END init_utilization_rec;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Utilization_Rec
--
-- HISTORY
--    04/25/2000  Mumu Pande  Create.
--    02/08/2001  Mumu Pande    Updated for 11.5.5 requirements
--    02/23/2001  Mumu PAnde    Updated for Hornet requirements

---------------------------------------------------------------------
   PROCEDURE complete_utilization_rec (
      p_utilization_rec   IN       utilization_rec_type
     ,x_complete_rec      OUT NOCOPY      utilization_rec_type
   ) IS
      CURSOR c_utilization IS
         SELECT *
           FROM ozf_funds_utilized_all_vl
          WHERE utilization_id = p_utilization_rec.utilization_id;

      l_utilization_rec   c_utilization%ROWTYPE;
   BEGIN
      x_complete_rec             := p_utilization_rec;
      OPEN c_utilization;
      FETCH c_utilization INTO l_utilization_rec;

      IF c_utilization%NOTFOUND THEN
         CLOSE c_utilization;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_utilization;

      IF p_utilization_rec.utilization_type = fnd_api.g_miss_char THEN
         x_complete_rec.utilization_type := NULL;
      END IF;
      IF p_utilization_rec.utilization_type IS NULL THEN
         x_complete_rec.utilization_type := l_utilization_rec.utilization_type;
      END IF;

      IF p_utilization_rec.fund_id = fnd_api.g_miss_num THEN
         x_complete_rec.fund_id     := NULL;
      END IF;
      IF p_utilization_rec.fund_id IS NULL THEN
         x_complete_rec.fund_id     := l_utilization_rec.fund_id;
      END IF;

      IF p_utilization_rec.plan_type = fnd_api.g_miss_char THEN
         x_complete_rec.plan_type   := NULL;
      END IF;
      IF p_utilization_rec.plan_type IS NULL THEN
         x_complete_rec.plan_type   := l_utilization_rec.plan_type;
      END IF;

      IF p_utilization_rec.plan_id = fnd_api.g_miss_num THEN
         x_complete_rec.plan_id     := NULL;
      END IF;
      IF p_utilization_rec.plan_id IS NULL THEN
         x_complete_rec.plan_id     := l_utilization_rec.plan_id;
      END IF;

      IF p_utilization_rec.component_type = fnd_api.g_miss_char THEN
         x_complete_rec.component_type := NULL;
      END IF;
      IF p_utilization_rec.component_type IS NULL THEN
         x_complete_rec.component_type := l_utilization_rec.component_type;
      END IF;

      IF p_utilization_rec.component_id = fnd_api.g_miss_num THEN
         x_complete_rec.component_id := NULL;
      END IF;
      IF p_utilization_rec.component_id IS NULL THEN
         x_complete_rec.component_id := l_utilization_rec.component_id;
      END IF;

      IF p_utilization_rec.object_type = fnd_api.g_miss_char THEN
         x_complete_rec.object_type := NULL;
      END IF;
      IF p_utilization_rec.object_type IS NULL THEN
         x_complete_rec.object_type := l_utilization_rec.object_type;
      END IF;

      IF p_utilization_rec.object_id = fnd_api.g_miss_num THEN
         x_complete_rec.object_id   := NULL;
      END IF;
      IF p_utilization_rec.object_id IS NULL THEN
         x_complete_rec.object_id   := l_utilization_rec.object_id;
      END IF;

      IF p_utilization_rec.order_id = fnd_api.g_miss_num THEN
         x_complete_rec.order_id    := NULL;
      END IF;
      IF p_utilization_rec.order_id IS NULL THEN
         x_complete_rec.order_id    := l_utilization_rec.order_id;
      END IF;

      IF p_utilization_rec.invoice_id = fnd_api.g_miss_num THEN
         x_complete_rec.invoice_id  := NULL;
      END IF;
      IF p_utilization_rec.invoice_id IS NULL THEN
         x_complete_rec.invoice_id  := l_utilization_rec.invoice_id;
      END IF;

      IF p_utilization_rec.amount = fnd_api.g_miss_num THEN
         x_complete_rec.amount      := NULL;
      END IF;
      IF p_utilization_rec.amount IS NULL THEN
         x_complete_rec.amount      := l_utilization_rec.amount;
      END IF;

      IF p_utilization_rec.acctd_amount = fnd_api.g_miss_num THEN
         x_complete_rec.acctd_amount := NULL;
      END IF;
      IF p_utilization_rec.acctd_amount IS NULL THEN
         x_complete_rec.acctd_amount := l_utilization_rec.acctd_amount;
      END IF;

      IF p_utilization_rec.currency_code = fnd_api.g_miss_char THEN
         x_complete_rec.currency_code := NULL;
      END IF;
      IF p_utilization_rec.currency_code IS NULL THEN
         x_complete_rec.currency_code := l_utilization_rec.currency_code;
      END IF;


----------------------------------------------------------------------------
--02/09/2001 ADDEd by mpande for 11.5.5 reqmnts.--
      IF p_utilization_rec.adjustment_type_id = fnd_api.g_miss_num THEN
         x_complete_rec.adjustment_type_id := NULL;
      END IF;
      IF p_utilization_rec.adjustment_type_id IS NULL THEN
         x_complete_rec.adjustment_type_id := l_utilization_rec.adjustment_type_id;
      END IF;

      IF p_utilization_rec.camp_schedule_id = fnd_api.g_miss_num THEN
         x_complete_rec.camp_schedule_id := NULL;
      END IF;
      IF p_utilization_rec.camp_schedule_id IS NULL THEN
         x_complete_rec.camp_schedule_id := l_utilization_rec.camp_schedule_id;
      END IF;

      IF p_utilization_rec.gl_date = fnd_api.g_miss_date THEN
         x_complete_rec.gl_date     := NULL;
      END IF;
      IF p_utilization_rec.gl_date IS NULL THEN
         x_complete_rec.gl_date     := l_utilization_rec.gl_date;
      END IF;

      IF p_utilization_rec.product_level_type = fnd_api.g_miss_char THEN
         x_complete_rec.product_level_type := NULL;
      END IF;
      IF p_utilization_rec.product_level_type IS NULL THEN
         x_complete_rec.product_level_type := l_utilization_rec.product_level_type;
      END IF;

      IF p_utilization_rec.product_id = fnd_api.g_miss_num THEN
         x_complete_rec.product_id  := NULL;
      END IF;
      IF p_utilization_rec.product_id IS NULL THEN
         x_complete_rec.product_id  := l_utilization_rec.product_id;
      END IF;

      IF p_utilization_rec.ams_activity_budget_id = fnd_api.g_miss_num THEN
         x_complete_rec.ams_activity_budget_id := NULL;
      END IF;
      IF p_utilization_rec.ams_activity_budget_id IS NULL THEN
         x_complete_rec.ams_activity_budget_id := l_utilization_rec.ams_activity_budget_id;
      END IF;

      IF p_utilization_rec.amount_remaining = fnd_api.g_miss_num THEN
         x_complete_rec.amount_remaining := NULL;
      END IF;
      IF p_utilization_rec.amount_remaining IS NULL THEN
         x_complete_rec.amount_remaining := l_utilization_rec.amount_remaining;
      END IF;

      IF p_utilization_rec.acctd_amount_remaining = fnd_api.g_miss_num THEN
         x_complete_rec.acctd_amount_remaining := NULL;
      END IF;
      IF p_utilization_rec.acctd_amount_remaining IS NULL THEN
         x_complete_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount_remaining;
      END IF;

      IF p_utilization_rec.cust_account_id = fnd_api.g_miss_num THEN
         x_complete_rec.cust_account_id := NULL;
      END IF;
      IF p_utilization_rec.cust_account_id IS NULL THEN
         x_complete_rec.cust_account_id := l_utilization_rec.cust_account_id;
      END IF;

      IF p_utilization_rec.price_adjustment_id = fnd_api.g_miss_num THEN
         x_complete_rec.price_adjustment_id := NULL;
      END IF;
      IF p_utilization_rec.price_adjustment_id IS NULL THEN
         x_complete_rec.price_adjustment_id := l_utilization_rec.price_adjustment_id;
      END IF;


--------------------------------------------------------------------------------
      IF p_utilization_rec.exchange_rate_type = fnd_api.g_miss_char THEN
         x_complete_rec.exchange_rate_type := NULL;
      END IF;
      IF p_utilization_rec.exchange_rate_type IS NULL THEN
         x_complete_rec.exchange_rate_type := l_utilization_rec.exchange_rate_type;
      END IF;

      IF p_utilization_rec.exchange_rate_date = fnd_api.g_miss_date THEN
         x_complete_rec.exchange_rate_date := NULL;
      END IF;
      IF p_utilization_rec.exchange_rate_date IS NULL THEN
         x_complete_rec.exchange_rate_date := l_utilization_rec.exchange_rate_date;
      END IF;

      IF p_utilization_rec.exchange_rate = fnd_api.g_miss_num THEN
         x_complete_rec.exchange_rate := NULL;
      END IF;
      IF p_utilization_rec.exchange_rate IS NULL THEN
         x_complete_rec.exchange_rate := l_utilization_rec.exchange_rate;
      END IF;

      IF p_utilization_rec.adjustment_type = fnd_api.g_miss_char THEN
         x_complete_rec.adjustment_type := NULL;
      END IF;
      IF p_utilization_rec.adjustment_type IS NULL THEN
         x_complete_rec.adjustment_type := l_utilization_rec.adjustment_type;
      END IF;

      IF p_utilization_rec.adjustment_date = fnd_api.g_miss_date THEN
         x_complete_rec.adjustment_date := NULL;
      END IF;
      IF p_utilization_rec.adjustment_date IS NULL THEN
         x_complete_rec.adjustment_date := l_utilization_rec.adjustment_date;
      END IF;

      IF p_utilization_rec.object_version_number = fnd_api.g_miss_num THEN
         x_complete_rec.object_version_number := NULL;
      END IF;
      IF p_utilization_rec.object_version_number IS NULL THEN
         x_complete_rec.object_version_number := l_utilization_rec.object_version_number;
      END IF;

      IF p_utilization_rec.attribute_category = fnd_api.g_miss_char THEN
         x_complete_rec.attribute_category := NULL;
      END IF;
      IF p_utilization_rec.attribute_category IS NULL THEN
         x_complete_rec.attribute_category := l_utilization_rec.attribute_category;
      END IF;

      IF p_utilization_rec.attribute1 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute1  := NULL;
      END IF;
      IF p_utilization_rec.attribute1 IS NULL THEN
         x_complete_rec.attribute1  := l_utilization_rec.attribute1;
      END IF;

      IF p_utilization_rec.attribute2 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute2  := NULL;
      END IF;
      IF p_utilization_rec.attribute2 IS NULL THEN
         x_complete_rec.attribute2  := l_utilization_rec.attribute2;
      END IF;

      IF p_utilization_rec.attribute3 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute3  := NULL;
      END IF;
      IF p_utilization_rec.attribute3 IS NULL THEN
         x_complete_rec.attribute3  := l_utilization_rec.attribute3;
      END IF;

      IF p_utilization_rec.attribute4 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute4  := NULL;
      END IF;
      IF p_utilization_rec.attribute4 IS NULL THEN
         x_complete_rec.attribute4  := l_utilization_rec.attribute4;
      END IF;

      IF p_utilization_rec.attribute5 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute5  := NULL;
      END IF;
      IF p_utilization_rec.attribute5 IS NULL THEN
         x_complete_rec.attribute5  := l_utilization_rec.attribute5;
      END IF;

      IF p_utilization_rec.attribute6 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute6  := NULL;
      END IF;
      IF p_utilization_rec.attribute6 IS NULL THEN
         x_complete_rec.attribute6  := l_utilization_rec.attribute6;
      END IF;

      IF p_utilization_rec.attribute7 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute7  := NULL;
      END IF;
      IF p_utilization_rec.attribute7 IS NULL THEN
         x_complete_rec.attribute7  := l_utilization_rec.attribute7;
      END IF;

      IF p_utilization_rec.attribute8 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute8  := NULL;
      END IF;
      IF p_utilization_rec.attribute8 IS NULL THEN
         x_complete_rec.attribute8  := l_utilization_rec.attribute8;
      END IF;

      IF p_utilization_rec.attribute9 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute9  := NULL;
      END IF;
      IF p_utilization_rec.attribute9 IS NULL THEN
         x_complete_rec.attribute9  := l_utilization_rec.attribute9;
      END IF;

      IF p_utilization_rec.attribute10 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute10 := NULL;
      END IF;
      IF p_utilization_rec.attribute10 IS NULL THEN
         x_complete_rec.attribute10 := l_utilization_rec.attribute10;
      END IF;

      IF p_utilization_rec.attribute11 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute11 := NULL;
      END IF;
      IF p_utilization_rec.attribute11 IS NULL THEN
         x_complete_rec.attribute11 := l_utilization_rec.attribute11;
      END IF;

      IF p_utilization_rec.attribute12 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute12 := NULL;
      END IF;
      IF p_utilization_rec.attribute12 IS NULL THEN
         x_complete_rec.attribute12 := l_utilization_rec.attribute12;
      END IF;

      IF p_utilization_rec.attribute13 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute13 := NULL;
      END IF;
      IF p_utilization_rec.attribute13 IS NULL THEN
         x_complete_rec.attribute13 := l_utilization_rec.attribute13;
      END IF;

      IF p_utilization_rec.attribute14 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute14 := NULL;
      END IF;
      IF p_utilization_rec.attribute14 IS NULL THEN
         x_complete_rec.attribute14 := l_utilization_rec.attribute14;
      END IF;

      IF p_utilization_rec.attribute15 = fnd_api.g_miss_char THEN
         x_complete_rec.attribute15 := NULL;
      END IF;
      IF p_utilization_rec.attribute15 IS NULL THEN
         x_complete_rec.attribute15 := l_utilization_rec.attribute15;
      END IF;

      IF p_utilization_rec.adjustment_desc = fnd_api.g_miss_char THEN
         x_complete_rec.adjustment_desc := NULL;
      END IF;
      IF p_utilization_rec.adjustment_desc IS NULL THEN
         x_complete_rec.adjustment_desc := l_utilization_rec.adjustment_desc;
      END IF;

      IF p_utilization_rec.plan_curr_amount = fnd_api.g_miss_num THEN
        x_complete_rec.plan_curr_amount := NULL;
      END IF;
      IF p_utilization_rec.plan_curr_amount IS NULL THEN
        x_complete_rec.plan_curr_amount := l_utilization_rec.plan_curr_amount;
      END IF;

      IF p_utilization_rec.plan_curr_amount_remaining = fnd_api.g_miss_num THEN
         x_complete_rec.plan_curr_amount_remaining := NULL;
      END IF;
      IF p_utilization_rec.plan_curr_amount_remaining IS NULL THEN
         x_complete_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount_remaining;
      END IF;

      -- added for 11.5.9
      IF p_utilization_rec.scan_unit = fnd_api.g_miss_num THEN
         x_complete_rec.scan_unit := NULL;
      END IF;
      IF p_utilization_rec.scan_unit IS NULL THEN
         x_complete_rec.scan_unit := l_utilization_rec.scan_unit;
      END IF;

      IF p_utilization_rec.scan_unit_remaining = fnd_api.g_miss_num THEN
         x_complete_rec.scan_unit_remaining := NULL;
      END IF;
      IF p_utilization_rec.scan_unit_remaining IS NULL THEN
         x_complete_rec.scan_unit_remaining := l_utilization_rec.scan_unit_remaining;
      END IF;

      IF p_utilization_rec.activity_product_id = fnd_api.g_miss_num THEN
         x_complete_rec.activity_product_id := NULL;
      END IF;
      IF p_utilization_rec.activity_product_id IS NULL THEN
         x_complete_rec.activity_product_id := l_utilization_rec.activity_product_id;
      END IF;

      IF p_utilization_rec.volume_offer_tiers_id = fnd_api.g_miss_num THEN
         x_complete_rec.volume_offer_tiers_id := NULL;
      END IF;
      IF p_utilization_rec.volume_offer_tiers_id IS NULL THEN
         x_complete_rec.volume_offer_tiers_id := l_utilization_rec.volume_offer_tiers_id;
      END IF;

      -- yzhao: 03/20/2003 added gl_posted_flag
      IF p_utilization_rec.gl_posted_flag = fnd_api.g_miss_char THEN
         x_complete_rec.gl_posted_flag := NULL;
      END IF;
      IF p_utilization_rec.gl_posted_flag IS NULL THEN
         x_complete_rec.gl_posted_flag := l_utilization_rec.gl_posted_flag;
      END IF;

      --  11/04/2003   yzhao     11.5.10: added
      IF p_utilization_rec.billto_cust_account_id = fnd_api.g_miss_num THEN
         x_complete_rec.billto_cust_account_id := NULL;
      END IF;
      IF p_utilization_rec.billto_cust_account_id IS NULL THEN
         x_complete_rec.billto_cust_account_id := l_utilization_rec.billto_cust_account_id;
      END IF;

      IF p_utilization_rec.reference_type = fnd_api.g_miss_char THEN
         x_complete_rec.reference_type := NULL;
      END IF;
      IF p_utilization_rec.reference_type IS NULL THEN
         x_complete_rec.reference_type := l_utilization_rec.reference_type;
      END IF;

      IF p_utilization_rec.reference_id = fnd_api.g_miss_num THEN
         x_complete_rec.reference_id := NULL;
      END IF;
      IF p_utilization_rec.reference_id IS NULL THEN
         x_complete_rec.reference_id := l_utilization_rec.reference_id;
      END IF;

      /*fix for bug 4778995
      IF p_utilization_rec.month_id = fnd_api.g_miss_num THEN
         x_complete_rec.month_id := NULL;
      END IF;
      IF p_utilization_rec.month_id IS NULL THEN
         x_complete_rec.month_id := l_utilization_rec.month_id;
      END IF;

      IF p_utilization_rec.quarter_id = fnd_api.g_miss_num THEN
         x_complete_rec.quarter_id := NULL;
      END IF;
      IF p_utilization_rec.quarter_id IS NULL THEN
         x_complete_rec.quarter_id := l_utilization_rec.quarter_id;
      END IF;

      IF p_utilization_rec.year_id = fnd_api.g_miss_num THEN
         x_complete_rec.year_id := NULL;
      END IF;
      IF p_utilization_rec.year_id IS NULL THEN
         x_complete_rec.year_id := l_utilization_rec.year_id;
      END IF;
      */

      IF p_utilization_rec.order_line_id = fnd_api.g_miss_num THEN
         x_complete_rec.order_line_id := NULL;
      END IF;
      IF p_utilization_rec.order_line_id IS NULL THEN
         x_complete_rec.order_line_id := l_utilization_rec.order_line_id;
      END IF;

      IF p_utilization_rec.orig_utilization_id = fnd_api.g_miss_num THEN
         x_complete_rec.orig_utilization_id := NULL;
      END IF;
      IF p_utilization_rec.orig_utilization_id IS NULL THEN
         x_complete_rec.orig_utilization_id := l_utilization_rec.orig_utilization_id;
      END IF;

      -- R12: yzhao add
      IF p_utilization_rec.univ_curr_amount = fnd_api.g_miss_num THEN
        x_complete_rec.univ_curr_amount := NULL;
      END IF;
      IF p_utilization_rec.univ_curr_amount IS NULL THEN
        x_complete_rec.univ_curr_amount := l_utilization_rec.univ_curr_amount;
      END IF;

      IF p_utilization_rec.univ_curr_amount_remaining = fnd_api.g_miss_num THEN
         x_complete_rec.univ_curr_amount_remaining := NULL;
      END IF;
      IF p_utilization_rec.univ_curr_amount_remaining IS NULL THEN
         x_complete_rec.univ_curr_amount_remaining := l_utilization_rec.univ_curr_amount_remaining;
      END IF;

      IF p_utilization_rec.bill_to_site_use_id = fnd_api.g_miss_num THEN
        x_complete_rec.bill_to_site_use_id := NULL;
      END IF;
      IF p_utilization_rec.bill_to_site_use_id IS NULL THEN
        x_complete_rec.bill_to_site_use_id := l_utilization_rec.bill_to_site_use_id;
      END IF;

      IF p_utilization_rec.ship_to_site_use_id = fnd_api.g_miss_num THEN
        x_complete_rec.ship_to_site_use_id := NULL;
      END IF;
      IF p_utilization_rec.ship_to_site_use_id IS NULL THEN
        x_complete_rec.ship_to_site_use_id := l_utilization_rec.ship_to_site_use_id;
      END IF;
   END complete_utilization_rec;

---------------------------------------------------------------------
-- PROCEDURE
--    create_act_utilization
--
-- PURPOSE
--    For create act budgets and utilization record.
--    Called by manual fund adjustment.
--
-- PARAMETERS
--    p_act_util_rec: the act budget record which contain information
---                   create act bugets record.
--    p_act_util_rec: the act utilization record which contain information
--                    for utilization.
-- NOTES
--    1. created by feliu on 02/25/2002.
---------------------------------------------------------------------

PROCEDURE create_act_utilization(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,p_act_util_rec       IN       ozf_actbudgets_pvt.act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
 ) IS
     l_utilization_id        NUMBER;
   BEGIN

      --kdass - added for Bug 8726683
      create_act_utilization(
         p_api_version        => p_api_version
        ,p_init_msg_list      => p_init_msg_list
        ,p_commit             => p_commit
        ,p_validation_level   => p_validation_level
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
        ,p_act_budgets_rec    => p_act_budgets_rec
        ,p_act_util_rec       => p_act_util_rec
        ,x_act_budget_id      => x_act_budget_id
        ,x_utilization_id     => l_utilization_id
       );

   END create_act_utilization;


PROCEDURE create_act_utilization(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,p_act_budgets_rec    IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,p_act_util_rec       IN       ozf_actbudgets_pvt.act_util_rec_type
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,x_utilization_id     OUT NOCOPY      NUMBER
)IS
      l_api_version         CONSTANT NUMBER                                     := 1.0;
      l_api_name            CONSTANT VARCHAR2 (30)                              := 'create_act_utilization';
      l_full_name           CONSTANT VARCHAR2 (60)                              :=    g_pkg_name
                                                                                   || '.'
                                                                                   || l_api_name;
      l_return_status                VARCHAR2 (1);
      l_activity_id               NUMBER;
      l_obj_ver_num               NUMBER;
      l_old_request_amount       NUMBER;
      l_old_parent_amount       NUMBER;

/*
      CURSOR c_act_util_rec (
         p_used_by_id      IN   NUMBER
        ,p_used_by_type    IN   VARCHAR2
        ,p_parent_src_id   IN   NUMBER
      ) IS
         SELECT activity_budget_id, object_version_number,request_amount,parent_src_apprvd_amt
         FROM ozf_act_budgets
         WHERE act_budget_used_by_id = p_used_by_id
         AND arc_act_budget_used_by = p_used_by_type
         AND parent_source_id = p_parent_src_id
         AND transfer_type = 'UTILIZED';
*/


      l_act_budgets_rec              ozf_actbudgets_pvt.act_budgets_rec_type := p_act_budgets_rec;
      l_act_util_rec                 ozf_actbudgets_pvt.act_util_rec_type := p_act_util_rec;
      l_offer_type                   VARCHAR2 (30);
      l_activity_product_id          NUMBER;
      l_scan_value                   NUMBER;
      l_utilized_amount              NUMBER;

      CURSOR c_offer_type(p_offer_id IN NUMBER) IS
        SELECT offer_type FROM ozf_offers
        WHERE qp_list_header_id = p_offer_id;

     CURSOR c_off_products (p_offer_id IN NUMBER,p_product_type VARCHAR2,
                            p_product_id NUMBER,p_channel_id NUMBER) IS
        SELECT act.activity_product_id,act.scan_value
        FROM
            (SELECT activity_product_id,level_type_code level_code,
                DECODE (level_type_code, 'PRODUCT', inventory_item_id, category_id) product_id
                    ,scan_value,channel_id
             FROM ams_act_products
             WHERE act_product_used_by_id = p_offer_id
             AND arc_act_product_used_by = 'OFFR'
            ) act
       WHERE act.level_code = p_product_type
       AND act.product_id = p_product_id
       AND act.channel_id = p_channel_id;

       --Added for bug 7030415
       CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
          SELECT exchange_rate_type
          FROM   ozf_sys_parameters_all
          WHERE  org_id = p_org_id;

       CURSOR c_offer_currency (p_activity_id IN NUMBER) IS
          SELECT NVL(transaction_currency_code,fund_request_curr_code) fund_request_curr_code,
          transaction_currency_code
          FROM ozf_offers
          WHERE qp_list_header_id = p_activity_id;
       l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;
       l_rate               NUMBER;
       l_offer_currency   c_offer_currency%ROWTYPE;
       l_conv_plan_amount NUMBER;


   BEGIN
      --------------------- initialize -----------------------
      SAVEPOINT create_act_utilization;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': start');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

      IF l_act_budgets_rec.transfer_type = 'UTILIZED' THEN


         -- Now the amount will be in transactional currency instead of budget currency.
         -- So, convert from transactional to
         --IF l_act_budgets_rec.parent_src_apprvd_amt IS NOT NULL THEN
         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_act_budgets_rec.parent_src_curr'|| l_act_budgets_rec.parent_src_curr);
            ozf_utility_pvt.debug_message('l_act_budgets_rec.arc_act_budget_used_by'|| l_act_budgets_rec.arc_act_budget_used_by);
            ozf_utility_pvt.debug_message('l_act_budgets_rec.arc_act_budget_used_id'|| l_act_budgets_rec.act_budget_used_by_id);
            ozf_utility_pvt.debug_message('l_act_budgets_rec.parent_src_curr'|| l_act_budgets_rec.parent_src_curr);
            ozf_utility_pvt.debug_message('l_act_budgets_rec.request_amount'|| l_act_budgets_rec.request_amount);
            ozf_utility_pvt.debug_message('l_act_budgets_rec.parent_src_apprvd_amt'|| l_act_budgets_rec.parent_src_apprvd_amt);
         END IF;

               --Added for bug 7030415
               OPEN c_get_conversion_type(l_act_util_rec.org_id);
               FETCH c_get_conversion_type INTO l_exchange_rate_type;
               CLOSE c_get_conversion_type;

         IF l_act_budgets_rec.request_amount IS NOT NULL THEN
            IF ((l_act_budgets_rec.parent_src_apprvd_amt IS NULL
                   OR l_act_budgets_rec.parent_src_apprvd_amt = fnd_api.g_miss_num)
                   AND l_act_budgets_rec.request_currency <> l_act_budgets_rec.parent_src_curr) THEN
                 --nirprasa,ER 8399134
                 -- convert the src_curr_request amount to the act_used_by  currency request amount.

                 ozf_utility_pvt.convert_currency (
                  x_return_status=> l_return_status
                 ,p_from_currency=> l_act_budgets_rec.request_currency
                 ,p_to_currency=> l_act_budgets_rec.parent_src_curr
                 ,p_conv_type=>l_exchange_rate_type --Added for bug 7030415
                 ,p_conv_date  => l_act_budgets_rec.exchange_rate_date --kdass added for bug 9613872
                 ,p_from_amount=> l_act_budgets_rec.request_amount
                 ,x_to_amount=> l_act_budgets_rec.parent_src_apprvd_amt
                 ,x_rate=> l_rate
                 );

               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
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
                          x_return_status=> l_return_status
                         ,p_from_currency=> l_act_budgets_rec.parent_src_curr
                         ,p_to_currency=> l_act_budgets_rec.request_currency
                         ,p_conv_type=>l_exchange_rate_type --Added for bug 7030415
                 ,p_conv_date     => l_act_budgets_rec.exchange_rate_date --bug 8532055
                         ,p_from_amount=> l_act_budgets_rec.parent_src_apprvd_amt
                         ,x_to_amount=> l_act_budgets_rec.request_amount
                         ,x_rate=> l_rate
                         );
                       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                          RAISE fnd_api.g_exc_unexpected_error;
                       ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                          RAISE fnd_api.g_exc_error;
                       END IF;
             ELSE
                l_act_budgets_rec.request_amount := l_act_budgets_rec.parent_src_apprvd_amt;
             END IF;
         END IF;
         END IF;

         IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('transfer_type '|| l_act_budgets_rec.transfer_type);
            ozf_utility_pvt.debug_message('adjustment_type '|| l_act_util_rec.adjustment_type);
            ozf_utility_pvt.debug_message('budget_source_type '|| l_act_budgets_rec.budget_source_type);
            ozf_utility_pvt.debug_message('request_currency '|| l_act_budgets_rec.request_currency);
            ozf_utility_pvt.debug_message('request_amount '|| l_act_budgets_rec.request_amount);
            ozf_utility_pvt.debug_message('approved_amount '|| l_act_budgets_rec.approved_amount);
            ozf_utility_pvt.debug_message('parent_src_curr '|| l_act_budgets_rec.parent_src_curr);
            ozf_utility_pvt.debug_message('plan_currency_code '|| l_act_util_rec.plan_currency_code);
            ozf_utility_pvt.debug_message('parent_src_apprvd_amt '|| l_act_budgets_rec.parent_src_apprvd_amt);
       END IF;
        IF l_act_budgets_rec.transfer_type = 'TRANSFER'
        AND l_act_util_rec.adjustment_type IN ('DECREASE_COMM_EARNED','DECREASE_COMMITTED' ) THEN
        -- The condition given below differentiates b/w the UI and Public API flow.
        -- l_act_budgets_rec.request_amount from UI for API its populated in src_curr_req_amt.
        -- So make the UI call simialr to Public API.
         IF l_act_budgets_rec.request_amount IS NOT NULL
         OR l_act_budgets_rec.request_amount <> FND_API.G_MISS_NUM THEN
            l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
            l_act_budgets_rec.request_currency := l_act_budgets_rec.parent_src_curr;
            l_act_budgets_rec.src_curr_req_amt := l_act_budgets_rec.request_amount;
            l_act_budgets_rec.request_amount := null;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message(' src_curr_req_amt '|| l_act_budgets_rec.src_curr_req_amt);
               ozf_utility_pvt.debug_message(' request_currency '|| l_act_budgets_rec.request_currency);
            END IF;
         END IF;
        END IF;


/*
       OPEN c_act_util_rec (p_act_budgets_rec.act_budget_used_by_id,
                           p_act_budgets_rec.arc_act_budget_used_by,
                           p_act_budgets_rec.parent_source_id);
      FETCH c_act_util_rec INTO l_activity_id, l_obj_ver_num, l_old_request_amount,l_old_parent_amount;
      CLOSE c_act_util_rec;
*/
       --get offer type
       IF l_act_budgets_rec.budget_source_type = 'OFFR' THEN
          OPEN c_offer_type(l_act_budgets_rec.budget_source_id);
          FETCH c_offer_type INTO l_offer_type;
          CLOSE c_offer_type;
       END IF;

       --for scan data offer, activity_product_id, scan_unit,scan_unit_remaining are required.
       IF l_offer_type = 'SCAN_DATA' THEN
          --check if scan_type_id is null;
          IF l_act_util_rec.scan_type_id is null  THEN
             ozf_utility_pvt.error_message('OZF_FUND_NO_SCAN_DATA_TYPE');
          END IF;

          IF l_act_util_rec.product_id is null THEN
             ozf_utility_pvt.error_message('OZF_FUND_NO_PROD_ID');
          END IF;

          OPEN c_off_products(l_act_budgets_rec.budget_source_id,l_act_util_rec.product_level_type,
                             l_act_util_rec.product_id,l_act_util_rec.scan_type_id);

          FETCH c_off_products INTO l_activity_product_id,l_scan_value;
          IF c_off_products%NOTFOUND THEN
             ozf_utility_pvt.error_message('OZF_FUND_ACT_PROD_ID_NOT_FOUND');
          END IF;

          CLOSE c_off_products;

          l_act_util_rec.activity_product_id := l_activity_product_id;
          --nirprasa,12.1.1
          l_act_util_rec.scan_unit := ozf_utility_pvt.currround(l_act_budgets_rec.request_amount/l_scan_value
                                                                ,l_act_budgets_rec.request_currency);
          l_act_util_rec.scan_unit_remaining := l_act_util_rec.scan_unit;
       END IF;

       --For decrease utilization, request amount will be negative in act_budgets record.
       IF l_act_budgets_rec.transfer_type = 'UTILIZED' AND
          p_act_util_rec.adjustment_type IN ('DECREASE_EARNED', 'DECREASE_COMM_EARNED')
       THEN
             l_act_budgets_rec.request_amount := - l_act_budgets_rec.request_amount;
             l_act_budgets_rec.parent_src_apprvd_amt := - l_act_budgets_rec.parent_src_apprvd_amt;
         l_act_budgets_rec.src_curr_req_amt := - l_act_budgets_rec.src_curr_req_amt;
      END IF;

      IF l_act_util_rec.plan_currency_code IS NULL
      OR l_act_util_rec.plan_currency_code = FND_API.G_MISS_CHAR THEN
         l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
       END IF;
      l_act_util_rec.fund_request_currency_code := OZF_ACTBUDGETS_PVT.get_object_currency (
                                                    l_act_budgets_rec.arc_act_budget_used_by
                                                   ,l_act_budgets_rec.act_budget_used_by_id
                                                   ,l_return_status
                                                   );

      IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('request_amount '|| l_act_budgets_rec.request_amount);
      END IF;

       ozf_fund_adjustment_pvt.process_act_budgets (
         x_return_status=> l_return_status,
         x_msg_count=> x_msg_count,
         x_msg_data=> x_msg_data,
         p_act_budgets_rec=> l_act_budgets_rec,
         p_act_util_rec=> l_act_util_rec,
         x_act_budget_id=> x_act_budget_id,
         x_utilized_amount => l_utilized_amount,
         x_utilization_id => x_utilization_id --kdass - added for Bug 8726683
       );

       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
       END IF;

      -- Check for commit
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name
                                     || ': end');
      END IF;

      EXCEPTION
        WHEN fnd_api.g_exc_error THEN
           ROLLBACK TO create_act_utilization;
           x_return_status            := fnd_api.g_ret_sts_error;
           fnd_msg_pub.count_and_get (
               p_encoded=> fnd_api.g_false
              ,p_count=> x_msg_count
              ,p_data=> x_msg_data
              );
        WHEN fnd_api.g_exc_unexpected_error THEN
           ROLLBACK TO create_act_utilization;
           x_return_status            := fnd_api.g_ret_sts_unexp_error;
           fnd_msg_pub.count_and_get (
              p_encoded=> fnd_api.g_false
             ,p_count=> x_msg_count
             ,p_data=> x_msg_data
           );
        WHEN OTHERS THEN
           ROLLBACK TO create_act_utilization;
           x_return_status            := fnd_api.g_ret_sts_unexp_error;

           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
              fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
           END IF;

           fnd_msg_pub.count_and_get (
              p_encoded=> fnd_api.g_false
             ,p_count=> x_msg_count
             ,p_data=> x_msg_data
            );


   END create_act_utilization;

END ozf_fund_utilized_pvt;


/
